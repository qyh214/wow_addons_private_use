local addonName, DF = ...

-- ============================================================
-- DANDERSFRAMES FUNCTION PROFILER
--
-- Zero overhead when disabled: uses function-swapping to wrap
-- DF:Method() calls with debugprofilestop() timing. When stopped,
-- original functions are fully restored — no runtime checks,
-- no wrappers, no cost.
--
-- Usage:
--   /df profiler             Toggle the profiler UI
--   /df profile [seconds]    Quick run for N seconds (default 10)
-- ============================================================

local debugprofilestop = debugprofilestop
local collectgarbage = collectgarbage
local format = string.format
local sort = table.sort
local floor = math.floor
local max = math.max
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local CreateFrame = CreateFrame

-- Shared tick counter, incremented once per OnUpdate frame.
-- Wrapped functions read this via upvalue to detect "new tick" without
-- needing access to any timer state.
local tickRef = { 0 }

-- ============================================================
-- STATE
-- ============================================================

local Profiler = {
    active = false,
    startTime = 0,          -- debugprofilestop() ms when started
    stopTime = 0,           -- debugprofilestop() ms when stopped (for accurate elapsed)
    combatAuto = false,     -- auto start/stop on combat enter/leave
    splitByFrame = false,   -- show per-frame-type breakdown
    viewMode = "functions", -- "functions" | "events"
    data = {},              -- [funcName|type] = { calls, total, max, mem }
    tickStats = {},         -- [funcName] = { lastTick, calls, maxPerTick }
    originals = {},         -- [funcPath] = { table, key, original }
    eventData = {},         -- [eventName] = { calls, total, max, mem, source }
    eventOriginals = {},    -- [dispatcherKey] = { container, key, original }
    updateData = {},        -- [frameLabel] = { calls, total, max, mem }
    sortColumn = "total",
    sortDesc = true,
}

DF.Profiler = Profiler

-- Forward declarations (referenced by combat handler before defined below)
local profilerFrame = nil
local dataRows = {}
local headerTexts = {}
local UpdateUI  -- assigned later when UI functions are defined

-- Combat auto-profile event frame (created once, persists)
local combatFrame = CreateFrame("Frame")
combatFrame:Hide()

-- Per-tick driver: increments tickRef[1] every OnUpdate frame so wrapped
-- functions can detect "new tick" and aggregate per-tick call counts.
-- Hidden when profiler is stopped (no OnUpdate runs).
local tickFrame = CreateFrame("Frame")
tickFrame:Hide()
tickFrame:SetScript("OnUpdate", function()
    tickRef[1] = tickRef[1] + 1
end)

-- ============================================================
-- ONUPDATE REGISTRY + SETSCRIPT HOOK
-- ----------------------------------------------------------
-- Tracking OnUpdate handlers requires a different mechanism than
-- function or event wrapping. OnUpdate scripts are bound directly to
-- frames via SetScript, so there's no DF-owned function we can swap.
--
-- Strategy: hook Frame:SetScript at addon load. Whenever a *DF-owned*
-- frame installs/removes an OnUpdate handler, we record the latest
-- handler in a registry. The registry alone has effectively zero
-- overhead — just one table assignment per SetScript call. No wrapping,
-- no instrumentation.
--
-- On Profiler:Start, we walk the registry and replace each recorded
-- handler with a wrapped version that records timing + memory. New
-- OnUpdate handlers installed *after* Start are wrapped on the spot
-- by the same hook. On Stop, all originals are restored.
--
-- The `installingOnUpdate` guard prevents the hook from re-wrapping
-- our own wrapper as we install it (otherwise infinite recursion).
--
-- CRITICAL: we must filter to DF-owned frames only. If we wrap a
-- non-DF frame's OnUpdate (especially Blizzard's CompactRaidFrame
-- secure frames), our wrapper closure runs inside that frame's
-- update cascade and the execution context gets marked as
-- "tainted by DandersFrames". That taint propagates to every
-- UnitIsConnected / UnitHealthMax / etc. secret-value return and
-- every protected Show()/Hide() call downstream — breaking secure
-- Blizzard code and producing ADDON_ACTION_BLOCKED errors. This was
-- the cause of a raid-session bug report on 2026-04-08.
--
-- The filter walks the frame's parent chain looking for any ancestor
-- whose name starts with "Danders" or "DF" — DF's named containers
-- and headers all use these prefixes (DandersPartyHeader,
-- DandersArenaHeader, DandersRaidGroupN, DFTestHeader, etc.). If no
-- ancestor has a DF name, the frame is foreign and must be skipped.
-- ============================================================

local onUpdateRegistry = {}      -- [frame] = handler ref currently bound (or nil)
local onUpdateLabels = {}        -- [frame] = stable label for display
local onUpdateDFCheck = {}       -- [frame] = true/false cached IsDFFrame result
local onUpdateWrapped = {}       -- [frame] = { original, stats } (only while active)
local installingOnUpdate = false -- re-entry guard for the SetScript hook

-- Is this frame owned by DandersFrames? Walks up the parent chain
-- looking for an ancestor whose name starts with "Danders" or "DF".
-- DF's secure headers and containers are all explicitly named with
-- one of these prefixes (see Frames/Headers.lua). Anonymous DF child
-- frames inherit their DF-ness from a named ancestor, so the walk
-- catches them too.
--
-- Results are cached per-frame because this is called from the
-- SetScript hook on every OnUpdate (re)bind and we don't want to
-- re-walk the parent chain every time.
local function IsDFFrame(frame)
    local cached = onUpdateDFCheck[frame]
    if cached ~= nil then return cached end

    local walker = frame
    local depth = 0  -- safety cap against pathological cycles
    while walker and depth < 32 do
        -- pcall because some Blizzard template frames (e.g. RadialWheel
        -- wedge buttons) error on :GetName() with "bad self".
        local ok, name = pcall(walker.GetName, walker)
        if ok and name then
            local p2 = name:sub(1, 2)
            local p7 = name:sub(1, 7)
            if p7 == "Danders" or p2 == "DF" then
                onUpdateDFCheck[frame] = true
                return true
            end
        end
        local ok2, parent = pcall(walker.GetParent, walker)
        walker = (ok2 and parent) or nil
        depth = depth + 1
    end

    onUpdateDFCheck[frame] = false
    return false
end

-- Best-effort label for a frame. Uses GetDebugName() when available
-- (modern WoW gives a parent-chain path), falls back to GetName(),
-- finally a generic "<anon>". Captured once at first sighting so it
-- stays stable across renames.
local function ResolveFrameLabel(frame)
    local existing = onUpdateLabels[frame]
    if existing then return existing end
    local label
    if frame.GetDebugName then
        label = frame:GetDebugName()
    end
    if (not label or label == "") and frame.GetName then
        label = frame:GetName()
    end
    if not label or label == "" then
        label = "<anon:" .. tostring(frame):match("0x[%x]+") .. ">"
    end
    onUpdateLabels[frame] = label
    return label
end

-- Forward declaration so the SetScript hook can call WrapFrameOnUpdate
-- before it's defined further down (it lives inside Profiler:Start's
-- closure scope and needs to share state with this hook).
local WrapFrameOnUpdate

-- OnUpdate hook toggle. Stored in the global SavedVariables table so it
-- persists across sessions and can be read at file-load time (before
-- DF.db / profiles are initialized). The hook can only be installed at
-- load time — toggling requires a /rl.
local onUpdateHookEnabled = DandersFramesDB_v2
    and DandersFramesDB_v2.profilerOnUpdateHook == true
Profiler.onUpdateHookEnabled = onUpdateHookEnabled

-- The hook itself. Runs after every Frame:SetScript call in the game.
-- Only installed when the user has opted in via /df profiler hook.
if onUpdateHookEnabled then
    local frameMeta = getmetatable(CreateFrame("Frame")).__index
    hooksecurefunc(frameMeta, "SetScript", function(frame, scriptType, handler)
        if installingOnUpdate then return end
        if scriptType ~= "OnUpdate" then return end
        if not IsDFFrame(frame) then return end  -- skip non-DF frames (taint safety)

        if handler then
            onUpdateRegistry[frame] = handler
            ResolveFrameLabel(frame)
            -- If profiler is currently recording, wrap the new handler
            -- right now so this newly added OnUpdate is visible from its
            -- first frame.
            if Profiler.active and WrapFrameOnUpdate then
                WrapFrameOnUpdate(frame, handler)
            end
        else
            -- nil handler = OnUpdate removed; drop bookkeeping.
            onUpdateRegistry[frame] = nil
            if onUpdateWrapped[frame] then
                onUpdateWrapped[frame] = nil
            end
        end
    end)
end

combatFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat
        if not Profiler.active then
            Profiler:Start()
            if profilerFrame and profilerFrame:IsShown() and UpdateUI then
                UpdateUI()
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leaving combat
        if Profiler.active then
            Profiler:Stop()
            Profiler:PrintResults()
            if profilerFrame and profilerFrame:IsShown() and UpdateUI then
                UpdateUI()
            end
        end
    end
end)

function Profiler:SetCombatAuto(enabled)
    self.combatAuto = enabled
    if enabled then
        combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        print("|cff00ff00DF Profiler:|r Combat auto-profile |cff00ff00ON|r — will start on combat, stop + print on combat end.")
    else
        combatFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        combatFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        print("|cff00ff00DF Profiler:|r Combat auto-profile |cffff4444OFF|r")
    end
end

-- ============================================================
-- PROFILED FUNCTIONS
-- Each entry is a path string. Plain "Name" resolves to DF[Name].
-- Dotted "Mod.Sub.Name" resolves to DF.Mod.Sub.Name. Missing entries
-- are silently skipped, so it's safe to list optional features here.
-- ============================================================

local PROFILED_FUNCTIONS = {
    -- ----------------------------------------------------------
    -- Core per-unit updates (event hot path)
    -- ----------------------------------------------------------
    "UpdateUnitFrame",
    "UpdateHealthFast",        -- Lean UNIT_HEALTH hot path
    "UpdateHealth",
    "UpdatePower",
    "UpdateName",
    "UpdateFrame",
    "UpdateResourceBar",

    -- ----------------------------------------------------------
    -- Aura pipeline
    -- ----------------------------------------------------------
    "UpdateAuras",                  -- Entry point (alias for Enhanced)
    "UpdateAuras_Enhanced",
    "UpdateAuraIcons",              -- Legacy path (kept for comparison)
    "UpdateAuraIcons_Enhanced",
    "UpdateAuraIconsDirect",        -- Merged collect+display (Tier 3)
    "CollectBuffs",
    "CollectDebuffs",
    "RepositionCenterGrowthIcons",
    "DirectModeRosterUpdate",
    "RebuildDirectFilterStrings",

    -- ----------------------------------------------------------
    -- Dispel
    -- ----------------------------------------------------------
    "UpdateDispelOverlay",
    "UpdateDispelGradientHealth",
    "UpdateAllDispelOverlays",

    -- ----------------------------------------------------------
    -- Absorb / Heal Prediction
    -- ----------------------------------------------------------
    "UpdateAbsorb",
    "UpdateHealAbsorb",
    "UpdateHealPrediction",

    -- ----------------------------------------------------------
    -- Range
    -- ----------------------------------------------------------
    "UpdateRange",
    "UpdatePetRange",
    "RefreshRangeSpell",

    -- ----------------------------------------------------------
    -- Visual / Highlights / Health Fade
    -- ----------------------------------------------------------
    "UpdateHighlights",
    "UpdateAnimatedBorder",
    "ApplyDeadFade",
    "ApplyHealthColors",
    "ApplyBarOrientation",
    "ApplyHealthFadeAlpha",
    "UpdateHealthFade",
    "UpdatePetHealthFade",

    -- ----------------------------------------------------------
    -- Status icons (legacy + enhanced + per-unit)
    -- ----------------------------------------------------------
    "UpdateRoleIcon",
    "UpdateLeaderIcon",
    "UpdateRaidTargetIcon",
    "UpdateReadyCheckIcon",
    "UpdateCenterStatusIcon",
    "UpdateRoleIconEnhanced",
    "UpdateLeaderIconEnhanced",
    "UpdateRaidTargetIconEnhanced",
    "UpdateReadyCheckIconEnhanced",
    "UpdateSummonIcon",
    "UpdateResurrectionIcon",
    "UpdatePhasedIcon",
    "UpdateAFKIcon",
    "UpdateVehicleIcon",
    "UpdateRaidRoleIcon",
    "UpdateAllStatusIcons",         -- per-frame sweep of all icons
    "UpdateRestedIndicator",

    -- ----------------------------------------------------------
    -- Defensive / external def icons + missing-buff
    -- ----------------------------------------------------------
    "UpdateMissingBuffIcon",
    "UpdateExternalDefIcon",
    "UpdateDefensiveBar",

    -- ----------------------------------------------------------
    -- My-Buff Indicators
    -- ----------------------------------------------------------
    "UpdateMyBuffIndicator",
    "UpdateMyBuffGradientHealth",

    -- ----------------------------------------------------------
    -- Aura Designer (per-frame)
    -- ----------------------------------------------------------
    "UpdateADTintHealth",

    -- ----------------------------------------------------------
    -- Targeted Spells
    -- ----------------------------------------------------------
    "UpdateTargetedSpellAnimatedBorder",
    "UpdateTargetedSpellLayout",

    -- ----------------------------------------------------------
    -- Pets
    -- ----------------------------------------------------------
    "UpdatePetFrame",
    "UpdatePetHealth",
    "UpdatePetName",
    "ApplyPetFrameStyle",

    -- ----------------------------------------------------------
    -- Layout / Style (called per-frame on layout changes)
    -- ----------------------------------------------------------
    "ApplyFrameLayout",
    "ApplyFrameStyle",
    "ApplyAuraLayout",
    "FullFrameRefresh",

    -- ----------------------------------------------------------
    -- Bulk sweeps (called on roster / settings events)
    -- ----------------------------------------------------------
    "UpdateAllFrames",
    "UpdateAllPetFrames",
    "UpdateAllRaidPetFrames",
    "UpdateAllPetFramePositions",
    "UpdateAllAuras",
    "UpdateAllMissingBuffIcons",
    "UpdateAllFramesStatusIcons",
    "UpdateAllRoleIcons",
    "UpdateAllMyBuffIndicators",
    "UpdateAllDefensiveBars",
    "UpdateAllExternalDefIcons",
    "UpdateAllElementAppearances",
    "UpdateAllFrameAppearances",
    "RefreshLiveFrames",
    "RefreshAllVisibleFrames",
    "RefreshRaidGroupFrames",
    "RefreshPartyFrames",
    "RefreshAllHeaderChildFrames",
    "RefreshRaidFlatFrames",
    "UpdateLiveRaidFrames",

    -- ----------------------------------------------------------
    -- Roster handling (called on GROUP_ROSTER_UPDATE)
    -- ----------------------------------------------------------
    "ProcessRosterUpdate",
    "ProcessRoleUpdate",
    "RebuildUnitFrameMap",
    "UpdateHeaderFrameCount",
    "UpdateRaidGroupOrderAttributes",
    "ApplyRaidGroupSorting",
    "ApplyPartyGroupSorting",

    -- ----------------------------------------------------------
    -- Power event registration (changes when role/spec/group changes)
    -- ----------------------------------------------------------
    "UpdatePowerEventRegistration",
    "UpdateAllPowerEventRegistration",

    -- ----------------------------------------------------------
    -- Blizzard integration
    -- ----------------------------------------------------------
    "CaptureAurasFromBlizzardFrame",
    "UpdateBlizzardFrameVisibility",
}

-- ============================================================
-- PROFILED EVENT DISPATCHERS
-- Each entry points at a function on DF that the addon's event frames
-- call through. Wrapping these gives us per-event timing for everything
-- those frames receive — without touching individual modules.
-- ============================================================

local PROFILED_EVENT_DISPATCHERS = {
    -- Roster UNIT_* events: every UNIT_AURA / UNIT_HEALTH / UNIT_POWER
    -- for every roster member flows through this single trampoline.
    { container = DF, key = "_RouteRosterEvent",   source = "Roster" },
    -- Main eventFrame: ADDON_LOADED, GROUP_ROSTER_UPDATE,
    -- PLAYER_REGEN_*, PLAYER_SPECIALIZATION_CHANGED, etc.
    { container = DF, key = "_MainEventDispatcher", source = "Main" },
}

-- ============================================================
-- FORMAT HELPERS
-- ============================================================

local function CommaNumber(n)
    local s = tostring(floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function FormatMs(ms)
    if ms >= 1000 then
        return format("%.1fs", ms / 1000)
    elseif ms >= 0.1 then
        return format("%.1f", ms)
    else
        return format("%.2f", ms)
    end
end

local function FormatUs(ms)
    local us = ms * 1000
    if us >= 100 then return format("%.0f", us)
    elseif us >= 10 then return format("%.1f", us)
    else return format("%.2f", us) end
end

-- Bytes per call: small numbers as raw bytes, larger as KB.
-- "0" -> "·" so the row reads cleanly when there's no allocation.
local function FormatBytes(b)
    if b <= 0 then return "·" end
    if b >= 1024 * 10 then
        return format("%.0fk", b / 1024)
    elseif b >= 1024 then
        return format("%.1fk", b / 1024)
    elseif b >= 100 then
        return format("%.0f", b)
    else
        return format("%.0f", b)
    end
end

local function FormatPeak(n)
    if n <= 0 then return "·" end
    if n >= 1000 then return format("%.1fk", n / 1000) end
    return tostring(n)
end

local function FormatElapsed(seconds)
    if seconds >= 60 then
        return format("%dm %ds", floor(seconds / 60), floor(seconds % 60))
    else
        return format("%.1fs", seconds)
    end
end

-- ============================================================
-- CORE PROFILING
-- ============================================================

-- Resolve a dotted path like "Mod.Sub.Name" against the DF table.
-- Returns: container_table, leaf_key, current_value (or nil if anything is missing).
local function ResolveFunctionPath(path)
    local container = DF
    local lastDot = 1
    while true do
        local dot = path:find(".", lastDot, true)
        if not dot then
            local key = path:sub(lastDot)
            return container, key, container[key]
        end
        local segment = path:sub(lastDot, dot - 1)
        container = container[segment]
        if type(container) ~= "table" then return nil end
        lastDot = dot + 1
    end
end

-- Wrap a single frame's OnUpdate handler. Idempotent: a second call on
-- the same frame is a no-op so prospective wrapping from the SetScript
-- hook can't double-instrument. Stats are keyed by the frame's label,
-- which means multiple frames sharing a name (rare, e.g. pooled frames)
-- aggregate into one row — usually what you want.
WrapFrameOnUpdate = function(frame, original)
    if onUpdateWrapped[frame] then return end

    local label = ResolveFrameLabel(frame)
    local stats = Profiler.updateData[label]
    if not stats then
        stats = { calls = 0, total = 0, max = 0, mem = 0 }
        Profiler.updateData[label] = stats
    end

    local wrapped = function(self, elapsed, ...)
        local m0 = collectgarbage("count")
        local t0 = debugprofilestop()
        original(self, elapsed, ...)
        local elapsedMs = debugprofilestop() - t0
        local mDelta = collectgarbage("count") - m0
        if mDelta < 0 then mDelta = 0 end
        stats.calls = stats.calls + 1
        stats.total = stats.total + elapsedMs
        stats.mem = stats.mem + mDelta
        if elapsedMs > stats.max then stats.max = elapsedMs end
    end

    onUpdateWrapped[frame] = { original = original, wrapped = wrapped }

    installingOnUpdate = true
    frame:SetScript("OnUpdate", wrapped)
    installingOnUpdate = false
end

function Profiler:Start()
    if self.active then
        print("|cff00ff00DF Profiler:|r Already recording.")
        return
    end

    self.active = true
    self.startTime = debugprofilestop()
    self.stopTime = 0
    wipe(self.data)
    wipe(self.tickStats)
    wipe(self.originals)
    wipe(self.eventData)
    wipe(self.eventOriginals)
    wipe(self.updateData)
    tickRef[1] = 0

    local wrapped = 0
    local typeCheck = type  -- cache as upvalue

    for _, path in ipairs(PROFILED_FUNCTIONS) do
        local container, key, original = ResolveFunctionPath(path)
        if container and type(original) == "function" then
            -- Save originals so Stop() can fully restore.
            self.originals[path] = { container = container, key = key, original = original }

            -- Per-frame-type buckets. Each entry tracks: calls, total ms,
            -- max single-call ms, and total memory delta (KB).
            local dP  = { calls = 0, total = 0, max = 0, mem = 0 }
            local dR  = { calls = 0, total = 0, max = 0, mem = 0 }
            local dHP = { calls = 0, total = 0, max = 0, mem = 0 }
            local dHR = { calls = 0, total = 0, max = 0, mem = 0 }
            local dU  = { calls = 0, total = 0, max = 0, mem = 0 }

            self.data[path .. "|P"]  = dP
            self.data[path .. "|R"]  = dR
            self.data[path .. "|HP"] = dHP
            self.data[path .. "|HR"] = dHR
            self.data[path .. "|?"]  = dU

            -- Per-function tick stats: how many times has this function been
            -- called within the current frame tick? Tracks the worst tick.
            local ts = { lastTick = -1, calls = 0, maxPerTick = 0 }
            self.tickStats[path] = ts

            local orig = original
            local tref = tickRef  -- upvalue cache

            container[key] = function(selfArg, a1, ...)
                -- Tick spike accounting (cheap: 1 table read + 2 compares)
                local cur = tref[1]
                if ts.lastTick ~= cur then
                    ts.lastTick = cur
                    ts.calls = 0
                end
                ts.calls = ts.calls + 1
                if ts.calls > ts.maxPerTick then
                    ts.maxPerTick = ts.calls
                end

                -- Time + memory delta around the call.
                -- collectgarbage("count") returns kilobytes; deltas are exact
                -- between calls, but a GC cycle running mid-call shows as
                -- negative — we clamp to 0 to avoid skew.
                local m0 = collectgarbage("count")
                local t0 = debugprofilestop()
                local r1, r2, r3, r4, r5 = orig(selfArg, a1, ...)
                local elapsed = debugprofilestop() - t0
                local mDelta = collectgarbage("count") - m0
                if mDelta < 0 then mDelta = 0 end

                -- Classify: 2-3 field lookups on the first argument
                local bucket
                if typeCheck(a1) == "table" and a1.unit then
                    if a1.isPinnedFrame then
                        bucket = a1.isRaidFrame and dHR or dHP
                    else
                        bucket = a1.isRaidFrame and dR or dP
                    end
                else
                    bucket = dU
                end
                bucket.calls = bucket.calls + 1
                bucket.total = bucket.total + elapsed
                bucket.mem = bucket.mem + mDelta
                if elapsed > bucket.max then bucket.max = elapsed end

                return r1, r2, r3, r4, r5
            end

            wrapped = wrapped + 1
        end
    end

    -- ----------------------------------------------------------
    -- Wrap event dispatchers. Each wrapped dispatcher records into
    -- self.eventData[eventName], indexed by the event name (the second
    -- argument the dispatcher receives). One dispatcher feeds many
    -- event names, so the bucket is created lazily on first occurrence.
    -- ----------------------------------------------------------
    local eventData = self.eventData
    local eventsWrapped = 0
    for _, dispatcher in ipairs(PROFILED_EVENT_DISPATCHERS) do
        local container = dispatcher.container
        local key = dispatcher.key
        local original = container[key]
        if type(original) == "function" then
            self.eventOriginals[key] = { container = container, key = key, original = original }
            local orig = original
            local source = dispatcher.source

            container[key] = function(selfArg, event, ...)
                local m0 = collectgarbage("count")
                local t0 = debugprofilestop()
                local r1, r2, r3, r4, r5 = orig(selfArg, event, ...)
                local elapsed = debugprofilestop() - t0
                local mDelta = collectgarbage("count") - m0
                if mDelta < 0 then mDelta = 0 end

                local bucket = eventData[event]
                if not bucket then
                    bucket = { calls = 0, total = 0, max = 0, mem = 0, source = source }
                    eventData[event] = bucket
                end
                bucket.calls = bucket.calls + 1
                bucket.total = bucket.total + elapsed
                bucket.mem = bucket.mem + mDelta
                if elapsed > bucket.max then bucket.max = elapsed end

                return r1, r2, r3, r4, r5
            end
            eventsWrapped = eventsWrapped + 1
        end
    end

    -- ----------------------------------------------------------
    -- Wrap all currently-known DF OnUpdate handlers. The SetScript
    -- hook has been recording these since addon load, so this catches
    -- every handler installed before the profiler started. Handlers
    -- added AFTER this point are wrapped on the spot by the same hook.
    --
    -- Defense in depth: re-run IsDFFrame on each registry entry here.
    -- The filter was added partway through the profiler's life, so the
    -- registry may contain stale non-DF frames recorded before the
    -- filter existed. Scrub them out instead of wrapping them, which
    -- would cause taint errors in Blizzard's secure frame updates.
    -- ----------------------------------------------------------
    local updatesWrapped = 0
    local toRemove
    for frame, handler in pairs(onUpdateRegistry) do
        if frame == tickFrame then
            -- don't profile our own tick driver
        elseif not IsDFFrame(frame) then
            -- Stale non-DF entry (recorded pre-filter). Drop it.
            toRemove = toRemove or {}
            toRemove[#toRemove + 1] = frame
        else
            WrapFrameOnUpdate(frame, handler)
            updatesWrapped = updatesWrapped + 1
        end
    end
    if toRemove then
        for i = 1, #toRemove do
            onUpdateRegistry[toRemove[i]] = nil
        end
    end

    -- Start the per-tick OnUpdate that drives spike detection.
    tickFrame:Show()

    print(format("|cff00ff00DF Profiler:|r Recording. %d functions, %d events, %d OnUpdate handlers instrumented.",
        wrapped, eventsWrapped, updatesWrapped))
end

function Profiler:Stop()
    if not self.active then return end
    self.stopTime = debugprofilestop()
    self.active = false

    -- Restore originals on their actual container tables (supports dotted paths)
    for _, entry in pairs(self.originals) do
        entry.container[entry.key] = entry.original
    end
    for _, entry in pairs(self.eventOriginals) do
        entry.container[entry.key] = entry.original
    end

    -- Restore OnUpdate handlers. The installingOnUpdate guard suppresses
    -- the SetScript hook so it doesn't immediately re-wrap them.
    for frame, entry in pairs(onUpdateWrapped) do
        installingOnUpdate = true
        frame:SetScript("OnUpdate", entry.original)
        installingOnUpdate = false
    end
    wipe(onUpdateWrapped)

    -- Stop the per-tick OnUpdate so profiler has zero idle cost when stopped.
    tickFrame:Hide()

    print(format("|cff00ff00DF Profiler:|r Stopped after %s.", FormatElapsed(self:GetElapsedSeconds())))
end

function Profiler:Reset()
    for _, d in pairs(self.data) do
        d.calls = 0
        d.total = 0
        d.max = 0
        d.mem = 0
    end
    for _, ts in pairs(self.tickStats) do
        ts.lastTick = -1
        ts.calls = 0
        ts.maxPerTick = 0
    end
    -- Event + update buckets are created lazily so just wipe them.
    wipe(self.eventData)
    for _, d in pairs(self.updateData) do
        d.calls = 0
        d.total = 0
        d.max = 0
        d.mem = 0
    end
    if self.active then
        self.startTime = debugprofilestop()
    end
end

function Profiler:Toggle()
    if self.active then self:Stop() else self:Start() end
end

function Profiler:GetElapsedSeconds()
    if self.startTime == 0 then return 0 end
    local endTime = self.active and debugprofilestop() or self.stopTime
    return (endTime - self.startTime) / 1000
end

local function GetActiveSource(self)
    if self.viewMode == "events" then return self.eventData end
    if self.viewMode == "updates" then return self.updateData end
    return self.data
end

function Profiler:GetTotalCalls()
    local total = 0
    for _, d in pairs(GetActiveSource(self)) do total = total + d.calls end
    return total
end

function Profiler:GetGrandTotalMs()
    local total = 0
    for _, d in pairs(GetActiveSource(self)) do total = total + d.total end
    return total
end

-- Display name suffixes for frame types
local TYPE_LABELS = {
    ["|P"]  = "  [Party]",
    ["|R"]  = "  [Raid]",
    ["|HP"] = "  [HL-P]",
    ["|HR"] = "  [HL-R]",
    ["|?"]  = "",  -- no suffix for "other" (functions that don't take a frame)
}

function Profiler:GetSortedResults()
    if self.viewMode == "events" then
        return self:GetSortedEventResults()
    end
    if self.viewMode == "updates" then
        return self:GetSortedUpdateResults()
    end

    local results = {}
    local grandTotal = 0
    local tickStats = self.tickStats

    if self.splitByFrame then
        -- Split mode: one row per function+type combination (only those with calls)
        for key, d in pairs(self.data) do
            if d.calls > 0 then
                grandTotal = grandTotal + d.total
                -- Parse "funcName|type" into base name + suffix
                local baseName, suffix = key:match("^(.+)(|.+)$")
                if not baseName then
                    baseName = key
                    suffix = ""
                end
                local displayName = baseName .. (TYPE_LABELS[suffix] or suffix)
                local ts = tickStats[baseName]
                results[#results + 1] = {
                    name = displayName,
                    calls = d.calls,
                    total = d.total,
                    avg = d.total / d.calls,
                    max = d.max,
                    -- Memory: bytes per call (KB delta * 1024 / calls)
                    mem = d.calls > 0 and (d.mem * 1024 / d.calls) or 0,
                    -- Peak/tick is per-function, not per-bucket; show the same
                    -- value on every split row for that function.
                    peak = ts and ts.maxPerTick or 0,
                }
            end
        end
    else
        -- Aggregate mode: combine all frame types into one row per function
        local aggregated = {}
        local aggOrder = {}  -- preserve insertion order for deterministic iteration
        for key, d in pairs(self.data) do
            if d.calls > 0 then
                local baseName = key:match("^(.+)|") or key
                if not aggregated[baseName] then
                    aggregated[baseName] = { calls = 0, total = 0, max = 0, mem = 0 }
                    aggOrder[#aggOrder + 1] = baseName
                end
                local agg = aggregated[baseName]
                agg.calls = agg.calls + d.calls
                agg.total = agg.total + d.total
                agg.mem = agg.mem + d.mem
                if d.max > agg.max then agg.max = d.max end
            end
        end

        for _, baseName in ipairs(aggOrder) do
            local agg = aggregated[baseName]
            grandTotal = grandTotal + agg.total
            local ts = tickStats[baseName]
            results[#results + 1] = {
                name = baseName,
                calls = agg.calls,
                total = agg.total,
                avg = agg.total / agg.calls,
                max = agg.max,
                mem = agg.calls > 0 and (agg.mem * 1024 / agg.calls) or 0,
                peak = ts and ts.maxPerTick or 0,
            }
        end
    end

    for _, r in ipairs(results) do
        r.pct = grandTotal > 0 and (r.total / grandTotal * 100) or 0
    end

    local col = self.sortColumn
    local desc = self.sortDesc
    sort(results, function(a, b)
        if col == "name" then
            if desc then return a.name > b.name else return a.name < b.name end
        end
        if desc then return a[col] > b[col] else return a[col] < b[col] end
    end)

    return results, grandTotal
end

-- Build sorted rows from OnUpdate handler data. Same shape as the
-- function/event variants. Frame label is shortened to avoid blowing
-- out the name column when GetDebugName returns a long parent chain.
function Profiler:GetSortedUpdateResults()
    local results = {}
    local grandTotal = 0

    for label, d in pairs(self.updateData) do
        if d.calls > 0 then
            grandTotal = grandTotal + d.total
            -- Trim very long parent-chain labels: keep the last segment.
            local short = label
            if #label > 36 then
                local tail = label:match("([^%.]+)$")
                short = tail and ("…" .. tail) or label:sub(-36)
            end
            results[#results + 1] = {
                name = short,
                calls = d.calls,
                total = d.total,
                avg = d.total / d.calls,
                max = d.max,
                mem = d.calls > 0 and (d.mem * 1024 / d.calls) or 0,
                peak = 0,
            }
        end
    end

    for _, r in ipairs(results) do
        r.pct = grandTotal > 0 and (r.total / grandTotal * 100) or 0
    end

    local col = self.sortColumn
    local desc = self.sortDesc
    sort(results, function(a, b)
        if col == "name" then
            if desc then return a.name > b.name else return a.name < b.name end
        end
        if desc then return a[col] > b[col] else return a[col] < b[col] end
    end)

    return results, grandTotal
end

-- Build sorted rows from event dispatcher data. The shape matches the
-- function results so the existing UI code can render either without a
-- branch, except that the "peak" column is unused (always 0) for events
-- and the "name" carries the event name plus a small source tag.
function Profiler:GetSortedEventResults()
    local results = {}
    local grandTotal = 0

    for eventName, d in pairs(self.eventData) do
        if d.calls > 0 then
            grandTotal = grandTotal + d.total
            results[#results + 1] = {
                name = eventName .. (d.source and ("  [" .. d.source .. "]") or ""),
                calls = d.calls,
                total = d.total,
                avg = d.total / d.calls,
                max = d.max,
                mem = d.calls > 0 and (d.mem * 1024 / d.calls) or 0,
                peak = 0,
            }
        end
    end

    for _, r in ipairs(results) do
        r.pct = grandTotal > 0 and (r.total / grandTotal * 100) or 0
    end

    local col = self.sortColumn
    local desc = self.sortDesc
    sort(results, function(a, b)
        if col == "name" then
            if desc then return a.name > b.name else return a.name < b.name end
        end
        if desc then return a[col] > b[col] else return a[col] < b[col] end
    end)

    return results, grandTotal
end

-- ============================================================
-- QUICK PROFILE (timed auto-run, prints to chat)
-- ============================================================

function Profiler:QuickProfile(duration)
    duration = duration or 10
    if self.active then self:Stop() end

    self:Start()
    print(format("|cff00ff00DF Profiler:|r Auto-stopping in %ds...", duration))

    C_Timer.After(duration, function()
        if self.active then
            self:Stop()
            self:PrintResults()
            if profilerFrame and profilerFrame:IsShown() then
                UpdateUI()
            end
        end
    end)
end

-- ============================================================
-- PRINT TO CHAT
-- ============================================================

function Profiler:PrintResults()
    local results, grandTotal = self:GetSortedResults()
    local elapsed = self:GetElapsedSeconds()
    local totalCalls = self:GetTotalCalls()

    if #results == 0 then
        print("|cff00ff00DF Profiler:|r No data collected.")
        return
    end

    print(" ")
    print(format("|cff00ff00DF Profiler:|r [%s] %s | %s calls | %sms profiled CPU",
        self.viewMode, FormatElapsed(elapsed), CommaNumber(totalCalls), FormatMs(grandTotal)))
    print("|cffaaaaaa------------------------------------------------------------|r")

    for i, r in ipairs(results) do
        local color
        if r.pct >= 25 then color = "|cffff6666"
        elseif r.pct >= 10 then color = "|cffffff88"
        else color = "|cff88ff88" end

        print(format("  %s%2d. %-36s|r  %s calls  %sms  %sus avg  %sus max  pk %s  %sB  %s%5.1f%%|r",
            color, i, r.name,
            CommaNumber(r.calls),
            FormatMs(r.total),
            FormatUs(r.avg),
            FormatUs(r.max),
            FormatPeak(r.peak),
            FormatBytes(r.mem),
            color, r.pct
        ))
    end

    print("|cffaaaaaa------------------------------------------------------------|r")
    print(" ")
end

-- ============================================================
-- SUMMARY (top-N across all three categories)
-- ============================================================

-- Helper: temporarily switch viewMode, run GetSortedResults, restore.
-- Used by PrintSummary so it can collect results from each category
-- without permanently flipping the user's UI view.
local function TopN(self, mode, n)
    local prev = self.viewMode
    self.viewMode = mode
    local results, grand = self:GetSortedResults()
    self.viewMode = prev
    local out = {}
    for i = 1, math.min(n, #results) do
        out[i] = results[i]
    end
    return out, grand
end

function Profiler:PrintSummary()
    local elapsed = self:GetElapsedSeconds()
    if elapsed <= 0 then
        print("|cff00ff00DF Profiler:|r No data collected.")
        return
    end

    -- Aggregate totals across all three sources independently. Note
    -- these will overlap (events drive functions which drive OnUpdate
    -- ticks) — they're shown as separate lenses, not sums.
    local _,  funcGrand = TopN(self, "functions", 0)
    local _,  evtGrand  = TopN(self, "events", 0)
    local _,  updGrand  = TopN(self, "updates", 0)

    print(" ")
    print(format("|cff00ff00DF Profiler Summary:|r %s elapsed", FormatElapsed(elapsed)))
    print(format("  Functions: %sms total CPU across wrapped DF methods", FormatMs(funcGrand)))
    print(format("  Events:    %sms total CPU across event handlers", FormatMs(evtGrand)))
    print(format("  OnUpdate:  %sms total CPU across every-frame handlers", FormatMs(updGrand)))
    print("|cffaaaaaa------------------------------------------------------------|r")

    local function dump(label, mode)
        local rows = TopN(self, mode, 5)
        if #rows == 0 then
            print(format("  |cffaaaaaaTop 5 %s:|r (none)", label))
            return
        end
        print(format("  |cffffd700Top 5 %s:|r", label))
        for i, r in ipairs(rows) do
            print(format("    %d. %-34s  %s calls  %sms  %sus avg  %s%%",
                i, r.name,
                CommaNumber(r.calls),
                FormatMs(r.total),
                FormatUs(r.avg),
                format("%.1f", r.pct)))
        end
    end
    dump("Functions (by total ms)", "functions")
    dump("Events (by total ms)",    "events")
    dump("OnUpdate (by total ms)",  "updates")

    print("|cffaaaaaa------------------------------------------------------------|r")
    print(" ")
end

-- ============================================================
-- UI
-- ============================================================

local ROW_HEIGHT = 18
local MAX_ROWS = 30
local FRAME_WIDTH = 720
local CONTENT_LEFT = 10
local CONTENT_RIGHT = -10
local HEADER_Y = -66
local DATA_START_Y = -86

-- Column layout
local COLUMNS = {
    { key = "name",  label = "Function",  width = 210, align = "LEFT" },
    { key = "calls", label = "Calls",     width = 54,  align = "RIGHT" },
    { key = "total", label = "Total ms",  width = 60,  align = "RIGHT" },
    { key = "avg",   label = "Avg us",    width = 52,  align = "RIGHT" },
    { key = "max",   label = "Max us",    width = 52,  align = "RIGHT" },
    { key = "peak",  label = "Peak/tk",   width = 52,  align = "RIGHT" },
    { key = "mem",   label = "Bytes",     width = 56,  align = "RIGHT" },
    { key = "pct",   label = "%",         width = 46,  align = "RIGHT" },
}

local CONTENT_WIDTH = 0
for _, col in ipairs(COLUMNS) do
    CONTENT_WIDTH = CONTENT_WIDTH + col.width + 4
end

local function UpdateColumnHeaders()
    for _, col in ipairs(COLUMNS) do
        local label = col.label
        if Profiler.sortColumn == col.key then
            label = label .. (Profiler.sortDesc and " v" or " ^")
        end
        if headerTexts[col.key] then
            headerTexts[col.key]:SetText(label)
        end
    end
end

local function CreateRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("LEFT", parent, "LEFT", CONTENT_LEFT, 0)
    row:SetPoint("RIGHT", parent, "RIGHT", CONTENT_RIGHT, 0)

    -- Alternating background
    row.bg = row:CreateTexture(nil, "BACKGROUND", nil, 0)
    row.bg:SetAllPoints()
    row.bg:SetColorTexture(index % 2 == 0 and 0.13 or 0.08, index % 2 == 0 and 0.13 or 0.08, index % 2 == 0 and 0.13 or 0.08, 1)

    -- Percentage bar (visual indicator behind text)
    row.pctBar = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.pctBar:SetPoint("LEFT")
    row.pctBar:SetHeight(ROW_HEIGHT)
    row.pctBar:SetWidth(1)
    row.pctBar:Hide()

    -- Column font strings
    row.cols = {}
    local xOffset = 2
    for _, col in ipairs(COLUMNS) do
        local fs = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        fs:SetJustifyH(col.align)
        fs:SetPoint("LEFT", row, "LEFT", xOffset, 0)
        fs:SetWidth(col.width)
        row.cols[col.key] = fs
        xOffset = xOffset + col.width + 4
    end

    row:Hide()
    return row
end

-- Assign to the forward-declared upvalue so the combat handler can call it
UpdateUI = function()
    if not profilerFrame or not profilerFrame:IsShown() then return end

    local elapsed = Profiler:GetElapsedSeconds()
    local totalCalls = Profiler:GetTotalCalls()
    local grandTotal = Profiler:GetGrandTotalMs()

    -- Status line
    if Profiler.active then
        profilerFrame.statusText:SetText(format(
            "|cff00ff00Recording|r  %s  |  %s calls  |  %sms CPU",
            FormatElapsed(elapsed), CommaNumber(totalCalls), FormatMs(grandTotal)
        ))
        profilerFrame.toggleBtn:SetText("Stop")
    else
        if totalCalls > 0 then
            local combatTag = Profiler.combatAuto and "  |  |cff00ff00Combat Armed|r" or ""
            profilerFrame.statusText:SetText(format(
                "|cffff4444Stopped|r  %s  |  %s calls  |  %sms CPU%s",
                FormatElapsed(elapsed), CommaNumber(totalCalls), FormatMs(grandTotal), combatTag
            ))
        else
            local combatTag = Profiler.combatAuto and "|cff00ff00Combat Armed|r  Waiting for combat..." or "|cff888888Ready|r  Press Start to begin profiling"
            profilerFrame.statusText:SetText(combatTag)
        end
        profilerFrame.toggleBtn:SetText("Start")
    end

    -- Data rows
    local results = Profiler:GetSortedResults()

    for i = 1, MAX_ROWS do
        local row = dataRows[i]
        if not row then break end

        local r = results[i]
        if r then
            -- Color based on cost share
            local cr, cg, cb
            local barR, barG, barB
            if r.pct >= 25 then
                cr, cg, cb = 1, 0.5, 0.5
                barR, barG, barB = 0.5, 0.15, 0.15
            elseif r.pct >= 10 then
                cr, cg, cb = 1, 1, 0.6
                barR, barG, barB = 0.4, 0.4, 0.1
            else
                cr, cg, cb = 0.7, 0.9, 0.7
                barR, barG, barB = 0.15, 0.35, 0.15
            end

            -- Percentage bar width
            local barWidth = max(1, (CONTENT_WIDTH - 4) * (r.pct / 100))
            row.pctBar:SetWidth(barWidth)
            row.pctBar:SetColorTexture(barR, barG, barB, 0.35)
            row.pctBar:Show()

            row.cols.name:SetText(r.name)
            row.cols.name:SetTextColor(cr, cg, cb)

            row.cols.calls:SetText(CommaNumber(r.calls))
            row.cols.calls:SetTextColor(0.8, 0.8, 0.8)

            row.cols.total:SetText(FormatMs(r.total))
            row.cols.total:SetTextColor(0.8, 0.8, 0.8)

            row.cols.avg:SetText(FormatUs(r.avg))
            row.cols.avg:SetTextColor(0.7, 0.7, 0.7)

            row.cols.max:SetText(FormatUs(r.max))
            row.cols.max:SetTextColor(0.7, 0.7, 0.7)

            row.cols.peak:SetText(FormatPeak(r.peak))
            -- Tint Peak/tick yellow when it's high (>=20 calls in one frame)
            -- — that's the cascade signal we're hunting.
            if r.peak >= 20 then
                row.cols.peak:SetTextColor(1, 0.85, 0.4)
            else
                row.cols.peak:SetTextColor(0.7, 0.7, 0.7)
            end

            row.cols.mem:SetText(FormatBytes(r.mem))
            -- Tint Mem yellow when bytes/call >= 256, red when >= 1024
            if r.mem >= 1024 then
                row.cols.mem:SetTextColor(1, 0.5, 0.5)
            elseif r.mem >= 256 then
                row.cols.mem:SetTextColor(1, 0.85, 0.4)
            else
                row.cols.mem:SetTextColor(0.7, 0.7, 0.7)
            end

            row.cols.pct:SetText(format("%.1f%%", r.pct))
            row.cols.pct:SetTextColor(cr, cg, cb)

            row:Show()
        else
            row:Hide()
        end
    end

    -- Keep combat button text in sync
    if profilerFrame.combatBtn then
        if Profiler.combatAuto then
            profilerFrame.combatBtn:SetText("|cff00ff00Combat|r")
        else
            profilerFrame.combatBtn:SetText("Combat")
        end
    end

    -- Keep split button text in sync
    if profilerFrame.splitBtn then
        if Profiler.splitByFrame then
            profilerFrame.splitBtn:SetText("|cff00ff00Split|r")
        else
            profilerFrame.splitBtn:SetText("Split")
        end
    end

    -- Keep view button text in sync
    if profilerFrame.viewBtn then
        if Profiler.viewMode == "events" then
            profilerFrame.viewBtn:SetText("|cff00ff00Events|r")
        elseif Profiler.viewMode == "updates" then
            profilerFrame.viewBtn:SetText("|cff00ff00OnUpdate|r")
        else
            profilerFrame.viewBtn:SetText("Functions")
        end
    end
end

function Profiler:CreateUI()
    if profilerFrame then
        profilerFrame:Show()
        return
    end

    -- Main frame
    local f = CreateFrame("Frame", "DFProfilerFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_WIDTH, DATA_START_Y * -1 + MAX_ROWS * ROW_HEIGHT + 30)
    f:SetPoint("CENTER", 0, 50)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    f:SetBackdropColor(0.06, 0.06, 0.06, 0.98)
    f:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    profilerFrame = f

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("|cff00ff00DF|r Profiler")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f)
    closeBtn:SetSize(18, 18)
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Status line
    f.statusText = f:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    f.statusText:SetPoint("TOPLEFT", 12, -32)
    f.statusText:SetJustifyH("LEFT")
    f.statusText:SetText("|cff888888Ready|r  Press Start to begin profiling")

    -- Buttons
    local btnY = -46
    local btnH = 20
    local btnW = 68

    f.toggleBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.toggleBtn:SetSize(btnW, btnH)
    f.toggleBtn:SetPoint("TOPLEFT", 10, btnY)
    f.toggleBtn:SetText("Start")
    f.toggleBtn:SetScript("OnClick", function()
        Profiler:Toggle()
        UpdateUI()
        UpdateColumnHeaders()
    end)

    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(btnW, btnH)
    resetBtn:SetPoint("LEFT", f.toggleBtn, "RIGHT", 4, 0)
    resetBtn:SetText("Reset")
    resetBtn:SetScript("OnClick", function()
        Profiler:Reset()
        UpdateUI()
    end)

    local printBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    printBtn:SetSize(88, btnH)
    printBtn:SetPoint("LEFT", resetBtn, "RIGHT", 4, 0)
    printBtn:SetText("Print to Chat")
    printBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    printBtn:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            Profiler:PrintSummary()
        else
            Profiler:PrintResults()
        end
    end)
    printBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Print to Chat", 1, 1, 1)
        GameTooltip:AddLine("Left-click: dump the current view (functions/events/onupdate)", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("Right-click: print Top 5 across all categories (summary)", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    printBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Custom duration input box
    local durationInput = CreateFrame("EditBox", nil, f, "BackdropTemplate")
    durationInput:SetSize(36, btnH)
    durationInput:SetPoint("LEFT", printBtn, "RIGHT", 12, 0)
    durationInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    durationInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
    durationInput:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    durationInput:SetFontObject(DFFontHighlightSmall)
    durationInput:SetJustifyH("CENTER")
    durationInput:SetAutoFocus(false)
    durationInput:SetNumeric(true)
    durationInput:SetMaxLetters(4)
    durationInput:SetText("30")
    -- Allow clicking away to clear focus
    durationInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    durationInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local dur = tonumber(self:GetText()) or 30
        if dur < 1 then dur = 1 end
        Profiler:QuickProfile(dur)
        UpdateUI()
        UpdateColumnHeaders()
    end)
    f.durationInput = durationInput

    -- "s Run" button (triggers timed profile with input value)
    local runBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    runBtn:SetSize(48, btnH)
    runBtn:SetPoint("LEFT", durationInput, "RIGHT", 2, 0)
    runBtn:SetText("s Run")
    runBtn:SetScript("OnClick", function()
        durationInput:ClearFocus()
        local dur = tonumber(durationInput:GetText()) or 30
        if dur < 1 then dur = 1 end
        Profiler:QuickProfile(dur)
        UpdateUI()
        UpdateColumnHeaders()
    end)

    -- Combat Auto toggle button
    f.combatBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.combatBtn:SetSize(78, btnH)
    f.combatBtn:SetPoint("LEFT", runBtn, "RIGHT", 8, 0)
    local function UpdateCombatBtnText()
        if Profiler.combatAuto then
            f.combatBtn:SetText("|cff00ff00Combat|r")
        else
            f.combatBtn:SetText("Combat")
        end
    end
    f.combatBtn:SetScript("OnClick", function()
        Profiler:SetCombatAuto(not Profiler.combatAuto)
        UpdateCombatBtnText()
        UpdateUI()
    end)
    f.combatBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Combat Auto-Profile", 1, 1, 1)
        if Profiler.combatAuto then
            GameTooltip:AddLine("ON: Profiling starts on combat, stops + prints on combat end.", 0, 1, 0, true)
        else
            GameTooltip:AddLine("OFF: Click to enable automatic combat profiling.", 0.7, 0.7, 0.7, true)
        end
        GameTooltip:Show()
    end)
    f.combatBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    UpdateCombatBtnText()

    -- View cycle button (Functions / Events / OnUpdate). Top-right, left of Split.
    f.viewBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.viewBtn:SetSize(82, btnH)
    f.viewBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -84, btnY)
    local VIEW_LABELS = {
        functions = "Functions",
        events    = "|cff00ff00Events|r",
        updates   = "|cff00ff00OnUpdate|r",
    }
    local VIEW_NEXT = {
        functions = "events",
        events    = "updates",
        updates   = "functions",
    }
    local function UpdateViewBtnText()
        f.viewBtn:SetText(VIEW_LABELS[Profiler.viewMode] or "Functions")
    end
    f.viewBtn:SetScript("OnClick", function()
        Profiler.viewMode = VIEW_NEXT[Profiler.viewMode] or "functions"
        UpdateViewBtnText()
        UpdateUI()
        UpdateColumnHeaders()
    end)
    f.viewBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("View Mode", 1, 1, 1)
        GameTooltip:AddLine("Click to cycle: Functions → Events → OnUpdate.", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("Functions: time per DF method", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("Events: time per WoW event (UNIT_AURA, etc.)", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("OnUpdate: time per OnUpdate handler (every-frame ticks)", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    f.viewBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    UpdateViewBtnText()

    -- Split by Frame Type toggle button
    f.splitBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.splitBtn:SetSize(50, btnH)
    f.splitBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -28, btnY)
    local function UpdateSplitBtnText()
        if Profiler.splitByFrame then
            f.splitBtn:SetText("|cff00ff00Split|r")
        else
            f.splitBtn:SetText("Split")
        end
    end
    f.splitBtn:SetScript("OnClick", function()
        Profiler.splitByFrame = not Profiler.splitByFrame
        UpdateSplitBtnText()
        UpdateUI()
    end)
    f.splitBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Split by Frame Type", 1, 1, 1)
        if Profiler.splitByFrame then
            GameTooltip:AddLine("ON: Showing per-type breakdown (Party, Raid, HL-Party, HL-Raid).", 0, 1, 0, true)
        else
            GameTooltip:AddLine("OFF: Click to split results by frame type.", 0.7, 0.7, 0.7, true)
        end
        GameTooltip:Show()
    end)
    f.splitBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    UpdateSplitBtnText()

    -- OnUpdate Hook warning banner (shown when hook is disabled)
    -- Positioned at the bottom of the profiler window, above the data rows
    local hookBanner = CreateFrame("Frame", nil, f, "BackdropTemplate")
    hookBanner:SetHeight(28)
    hookBanner:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 6)
    hookBanner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 6)
    hookBanner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    hookBanner:SetBackdropColor(0.3, 0.15, 0, 0.9)
    hookBanner:SetBackdropBorderColor(0.8, 0.5, 0, 1)
    f.hookBanner = hookBanner

    local hookText = hookBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    hookText:SetPoint("LEFT", 8, 0)
    hookText:SetTextColor(1, 0.8, 0.2)
    f.hookBannerText = hookText

    local hookCheckbox = CreateFrame("CheckButton", nil, hookBanner, "UICheckButtonTemplate")
    hookCheckbox:SetSize(22, 22)
    hookCheckbox:SetPoint("RIGHT", -6, 0)
    hookCheckbox:SetChecked(self.onUpdateHookEnabled)
    hookCheckbox:SetScript("OnClick", function(cb)
        if not DandersFramesDB_v2 then DandersFramesDB_v2 = {} end
        local newState = cb:GetChecked()
        DandersFramesDB_v2.profilerOnUpdateHook = newState
        -- Update banner to show pending state
        if newState == self.onUpdateHookEnabled then
            -- Back to current state, no reload needed
            UpdateHookBanner()
        else
            hookText:SetText(newState
                and "OnUpdate hook enabled — type /rl to apply"
                or "OnUpdate hook disabled — type /rl to apply")
        end
    end)
    f.hookCheckbox = hookCheckbox

    local hookLabel = hookBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    hookLabel:SetPoint("RIGHT", hookCheckbox, "LEFT", -2, 0)
    hookLabel:SetText("Enable")
    hookLabel:SetTextColor(1, 0.8, 0.2)

    local function UpdateHookBanner()
        if self.onUpdateHookEnabled then
            hookBanner:Hide()
        else
            hookText:SetText("OnUpdate tracking is disabled. Enable and /rl to use the OnUpdate tab.")
            hookCheckbox:SetChecked(DandersFramesDB_v2 and DandersFramesDB_v2.profilerOnUpdateHook or false)
            hookBanner:Show()
        end
    end
    f.UpdateHookBanner = UpdateHookBanner
    UpdateHookBanner()

    -- Column headers
    local xOffset = CONTENT_LEFT + 2
    for _, col in ipairs(COLUMNS) do
        local hdr = CreateFrame("Button", nil, f)
        hdr:SetHeight(18)
        hdr:SetPoint("TOPLEFT", f, "TOPLEFT", xOffset, HEADER_Y)
        hdr:SetWidth(col.width)

        local text = hdr:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        text:SetAllPoints()
        text:SetJustifyH(col.align)
        text:SetTextColor(0.5, 0.75, 1.0)

        local label = col.label
        if Profiler.sortColumn == col.key then
            label = label .. (Profiler.sortDesc and " v" or " ^")
        end
        text:SetText(label)
        headerTexts[col.key] = text

        -- Click to sort
        local colKey = col.key
        hdr:SetScript("OnClick", function()
            if Profiler.sortColumn == colKey then
                Profiler.sortDesc = not Profiler.sortDesc
            else
                Profiler.sortColumn = colKey
                Profiler.sortDesc = true
            end
            UpdateColumnHeaders()
            UpdateUI()
        end)
        hdr:SetScript("OnEnter", function() text:SetTextColor(0.8, 1.0, 1.0) end)
        hdr:SetScript("OnLeave", function() text:SetTextColor(0.5, 0.75, 1.0) end)

        xOffset = xOffset + col.width + 4
    end

    -- Header divider
    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.3, 0.3, 0.3, 0.6)
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", f, "TOPLEFT", CONTENT_LEFT, HEADER_Y - 18)
    divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", CONTENT_RIGHT, HEADER_Y - 18)

    -- Data rows
    for i = 1, MAX_ROWS do
        local row = CreateRow(f, i)
        row:SetPoint("TOP", f, "TOP", 0, DATA_START_Y - (i - 1) * ROW_HEIGHT)
        dataRows[i] = row
    end

    -- Info label at bottom
    local infoLabel = f:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    infoLabel:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 12, 8)
    infoLabel:SetTextColor(0.4, 0.4, 0.4)
    infoLabel:SetText("Inclusive times  |  Peak/tk = max calls in one frame  |  Bytes = avg alloc per call")

    -- Live refresh via OnUpdate
    f.elapsed = 0
    f:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed < 0.5 then return end
        self.elapsed = 0
        UpdateUI()
    end)

    UpdateUI()
end

function Profiler:ToggleUI()
    if profilerFrame and profilerFrame:IsShown() then
        profilerFrame:Hide()
    else
        self:CreateUI()
    end
end
