local addonName, DF = ...

-- ============================================================
-- AURA FILTERING SYSTEM
-- Hooks into Blizzard's raid frame aura filtering to capture results
-- ============================================================

-- Local caching of frequently used globals and WoW API for performance
local pairs, ipairs, type, pcall, wipe = pairs, ipairs, type, pcall, wipe
local tinsert, tremove = table.insert, table.remove
local C_UnitAuras = C_UnitAuras
local UnitIsUnit = UnitIsUnit
local GetTime = GetTime

-- Additional cached API for direct aura update (Tier 1 optimization)
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected
local InCombatLockdown = InCombatLockdown
local issecretvalue = issecretvalue
local strsplit = strsplit
local C_CurveUtil = C_CurveUtil
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras
local IsAuraFilteredOut = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID
-- Fix A additions: slot-based iteration APIs (used by ScanUnitFull)
local GetAuraSlots = C_UnitAuras and C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras and C_UnitAuras.GetAuraDataBySlot
local strfind = string.find

-- Roster-unit allowlist guard. The 12.0.5 C_UnitAuras.GetUnitAuras API
-- rejects compound unit tokens like `boss1targetpet` with a hard error,
-- so any aura-scanning function that gets called from a Blizzard frame
-- hook (where the unit token can be anything) needs to early-return on
-- non-roster tokens before touching GetUnitAuras. This is the same
-- allowlist pattern that v4.2.6 added to SecretAuras as an interim
-- filter — same problem, different code path.
local function IsRosterUnit(unit)
    if not unit then return false end
    if unit == "player" then return true end
    if strfind(unit, "^party%d$") then return true end
    if strfind(unit, "^raid%d+$") then return true end
    if strfind(unit, "^boss%d$") then return true end
    return false
end

-- Safe texture setter that handles secret values
local function SafeSetTexture(icon, texture)
    if icon and icon.texture and texture then
        icon.texture:SetTexture(texture)
        return true
    end
    return false
end

-- Safe cooldown setter (secret-safe via Duration objects)
local function SafeSetCooldown(cooldown, auraData, unit)
    if not cooldown then return end

    -- Path 1: Real unit — get Duration object from the API (handles secrets)
    if unit and auraData.auraInstanceID
       and C_UnitAuras.GetAuraDuration
       and cooldown.SetCooldownFromDurationObject then
        local durationObj = C_UnitAuras.GetAuraDuration(unit, auraData.auraInstanceID)
        if durationObj then
            cooldown:SetCooldownFromDurationObject(durationObj)
            return
        end
    end

    -- Path 2: Non-secret fallback (preview/test mode)
    local dur = auraData.duration
    local exp = auraData.expirationTime
    if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
        if cooldown.SetCooldownFromExpirationTime then
            cooldown:SetCooldownFromExpirationTime(exp, dur)
        end
    end
end

-- Table pool to reduce garbage collection
-- PERFORMANCE FIX 2025-01-20: Reuse aura entry tables instead of creating new ones
local tablePool = {}
local poolSize = 0

local function AcquireTable()
    if poolSize > 0 then
        local t = tablePool[poolSize]
        tablePool[poolSize] = nil
        poolSize = poolSize - 1
        return t
    end
    return {}
end

local function ReleaseTable(t)
    if t then
        wipe(t)
        poolSize = poolSize + 1
        tablePool[poolSize] = t
    end
end

-- Helper to release all entry tables in an array before wiping
-- This returns entries to the pool so they can be reused
local function ReleaseAndWipe(arr)
    for i = 1, #arr do
        ReleaseTable(arr[i])
        arr[i] = nil
    end
end

-- Reusable result arrays for aura collection (reduces garbage)
-- These get wiped and reused each call instead of creating new tables
local reusableBuffs = {}
local reusableDebuffs = {}

-- ============================================================
-- SHARED AURA TIMER SYSTEM
-- Replaces per-icon OnUpdate scripts with a single shared timer
-- ============================================================

local trackedIcons = {}  -- [icon] = true

-- Create timer using AnimationGroup (same pattern as Range.lua)
local auraTimerFrame = CreateFrame("Frame")
local auraTimerGroup = auraTimerFrame:CreateAnimationGroup()
local auraTimerAnim = auraTimerGroup:CreateAnimation()
auraTimerAnim:SetDuration(0.2)
auraTimerGroup:SetLooping("REPEAT")

-- Performance tracking
local timerCallCount = 0
local iconsProcessedCount = 0
local lastReportTime = 0
local peakTrackedIcons = 0
local iconsByFrameType = { party = 0, raid = 0, highlight = 0, unknown = 0 }

-- Timer callback
auraTimerGroup:SetScript("OnLoop", function()
    timerCallCount = timerCallCount + 1
    
    -- Only skip if PerfTest explicitly disables the aura timer
    if DF.PerfTest and DF.PerfTest.enableAuraTimer == false then 
        return 
    end
    
    -- Track peak icons
    local currentCount = 0
    for _ in pairs(trackedIcons) do currentCount = currentCount + 1 end
    if currentCount > peakTrackedIcons then peakTrackedIcons = currentCount end
    
    for icon, _ in pairs(trackedIcons) do
        -- Skip hidden icons (includes icons on hidden parent frames)
        if not icon:IsShown() then
            trackedIcons[icon] = nil
        elseif icon.auraData and icon.auraData.auraInstanceID then
            iconsProcessedCount = iconsProcessedCount + 1
            
            -- Track frame type
            local frameType = "unknown"
            if icon.unitFrame then
                if icon.unitFrame.isPinnedFrame then
                    frameType = "highlight"
                elseif icon.unitFrame.isRaidFrame then
                    frameType = "raid"
                else
                    frameType = "party"
                end
            end
            iconsByFrameType[frameType] = iconsByFrameType[frameType] + 1
            -- Check if features are enabled
            local needsDurationColor = icon.showDuration and icon.durationColorByTime
            local needsDurationHide = icon.showDuration and icon.durationHideAboveEnabled
            local needsExpiring = icon.expiringEnabled

            if needsDurationColor or needsDurationHide or needsExpiring then
                local unit = icon.unitFrame and icon.unitFrame.unit
                local auraInstanceID = icon.auraData.auraInstanceID
                
                if unit and auraInstanceID then
                    -- Get hasExpiration as a secret boolean — ONLY for use with
                    -- secret-aware APIs (SetAlphaFromBoolean, SetShownFromBoolean).
                    -- Secret values CANNOT be tested with if/else/~=nil in Lua.
                    local hasExpiration = nil
                    if C_UnitAuras and C_UnitAuras.DoesAuraHaveExpirationTime then
                        hasExpiration = C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID)
                    end

                    do
                        -- Find native cooldown text if needed (safety net — rendering function usually discovers first)
                        if not icon.nativeCooldownText and icon.cooldown then
                            local regions = {icon.cooldown:GetRegions()}
                            for _, region in pairs(regions) do
                                if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                                    icon.nativeCooldownText = region
                                    -- Create wrapper for hide-above-threshold alpha control
                                    if not icon.durationHideWrapper then
                                        icon.durationHideWrapper = CreateFrame("Frame", nil, icon.cooldown)
                                        icon.durationHideWrapper:SetAllPoints(icon)
                                        icon.durationHideWrapper:SetFrameLevel(icon.cooldown:GetFrameLevel() + 2)
                                        icon.durationHideWrapper:EnableMouse(false)
                                        region:SetParent(icon.durationHideWrapper)
                                    end
                                    break
                                end
                            end
                        end

                        -- Native text visibility is controlled by the cooldown frame's own Show/Hide
                        -- (SetShownFromBoolean on cooldown hides both swipe and text for permanent buffs)
                        -- No manual Show/Hide on nativeCooldownText needed here

                        -- Throttle expensive APIs to 1 FPS
                        local now = GetTime()
                        local auraChanged = icon.lastColorAuraID ~= auraInstanceID
                        if auraChanged then
                            icon.lastColorUpdate = nil
                            icon.lastColorAuraID = auraInstanceID
                        end
                        
                        if not icon.lastColorUpdate or (now - icon.lastColorUpdate) >= 1.0 then
                            icon.lastColorUpdate = now
                            
                            -- Get duration object
                            local durationObj = nil
                            if C_UnitAuras and C_UnitAuras.GetAuraDuration then
                                durationObj = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
                            end
                            
                            local useNewAPI = durationObj and durationObj.EvaluateRemainingDuration
                            
                            -- Duration color — pipe curve result directly to SetTextColor
                            -- No intermediate locals to avoid secret value comparisons
                            if needsDurationColor and icon.nativeCooldownText and useNewAPI then
                                if C_CurveUtil and C_CurveUtil.CreateColorCurve then
                                    if not DF.durationColorCurve then
                                        local curve = C_CurveUtil.CreateColorCurve()
                                        curve:SetType(Enum.LuaCurveType.Linear)
                                        curve:AddPoint(0, CreateColor(1, 0, 0, 1))
                                        curve:AddPoint(0.3, CreateColor(1, 0.5, 0, 1))
                                        curve:AddPoint(0.5, CreateColor(1, 1, 0, 1))
                                        curve:AddPoint(1, CreateColor(0, 1, 0, 1))
                                        DF.durationColorCurve = curve
                                    end

                                    local result = durationObj:EvaluateRemainingPercent(DF.durationColorCurve)
                                    if result and result.GetRGBA then
                                        icon.nativeCooldownText:SetTextColor(result:GetRGBA())
                                    end
                                end
                            end

                            -- Duration hide above threshold — use SetAlphaFromBoolean on wrapper
                            -- The wrapper frame controls visibility of the native cooldown text
                            -- Curve alpha is secret, so pass through SetAlphaFromBoolean with
                            -- hasExpiration as the gate (permanent buffs hidden by cooldown already)
                            if needsDurationHide and icon.nativeCooldownText and useNewAPI and icon.durationHideWrapper then
                                local threshold = icon.durationHideAboveThreshold or 10
                                if C_CurveUtil and C_CurveUtil.CreateColorCurve then
                                    DF.durationHideCurves = DF.durationHideCurves or {}
                                    if not DF.durationHideCurves[threshold] then
                                        local curve = C_CurveUtil.CreateColorCurve()
                                        curve:SetType(Enum.LuaCurveType.Step)
                                        curve:AddPoint(0, CreateColor(1, 1, 1, 1))
                                        curve:AddPoint(threshold, CreateColor(1, 1, 1, 0))
                                        curve:AddPoint(600, CreateColor(1, 1, 1, 0))
                                        DF.durationHideCurves[threshold] = curve
                                    end

                                    if durationObj.EvaluateRemainingDuration then
                                        local hideResult = durationObj:EvaluateRemainingDuration(DF.durationHideCurves[threshold])
                                        -- hideResult is a ColorMixin (has GetRGBA, not GetAlpha)
                                        -- Extract alpha via select(4, GetRGBA()) and pipe to SetAlphaFromBoolean
                                        if hideResult and hideResult.GetRGBA and icon.durationHideWrapper.SetAlphaFromBoolean then
                                            icon.durationHideWrapper:SetAlphaFromBoolean(hasExpiration, select(4, hideResult:GetRGBA()), 0)
                                        end
                                    end
                                end
                            end
                            
                            -- Expiring indicators
                            if not icon.testAuraData and needsExpiring and useNewAPI then
                                local threshold = icon.expiringThreshold or 30
                                local useSeconds = icon.expiringThresholdMode == "SECONDS"

                                if C_CurveUtil and C_CurveUtil.CreateColorCurve then
                                    DF.expiringCurves = DF.expiringCurves or {}
                                    local cacheKey = (useSeconds and "s" or "p") .. threshold
                                    if not DF.expiringCurves[cacheKey] then
                                        local curve = C_CurveUtil.CreateColorCurve()
                                        curve:SetType(Enum.LuaCurveType.Step)
                                        if useSeconds then
                                            curve:AddPoint(0, CreateColor(1, 1, 1, 1))
                                            curve:AddPoint(threshold, CreateColor(0, 0, 0, 0))
                                            curve:AddPoint(600, CreateColor(0, 0, 0, 0))
                                        else
                                            local thresholdDecimal = threshold / 100
                                            curve:AddPoint(0, CreateColor(1, 1, 1, 1))
                                            curve:AddPoint(thresholdDecimal, CreateColor(0, 0, 0, 0))
                                            curve:AddPoint(1, CreateColor(0, 0, 0, 0))
                                        end
                                        DF.expiringCurves[cacheKey] = curve
                                    end

                                    local expireResult
                                    if useSeconds and durationObj.EvaluateRemainingDuration then
                                        -- EvaluateRemainingDuration handles non-expiring auras safely
                                        -- (their cooldown is hidden via SetShownFromBoolean)
                                        expireResult = durationObj:EvaluateRemainingDuration(DF.expiringCurves[cacheKey])
                                    else
                                        expireResult = durationObj:EvaluateRemainingPercent(DF.expiringCurves[cacheKey])
                                    end
                                    
                                    if expireResult and expireResult.GetRGBA then
                                        local expiringAlpha = select(4, expireResult:GetRGBA())
                                        
                                        -- Tint
                                        if icon.expiringTint and icon.expiringTintEnabled then
                                            icon.expiringTint:Show()
                                            if icon.expiringTint.SetAlphaFromBoolean then
                                                icon.expiringTint:SetAlphaFromBoolean(hasExpiration, expiringAlpha, 0)
                                            else
                                                icon.expiringTint:SetAlpha(expiringAlpha)
                                            end
                                        elseif icon.expiringTint then
                                            icon.expiringTint:Hide()
                                        end
                                        
                                        -- Border
                                        if icon.expiringBorderAlphaContainer and icon.expiringBorderEnabled then
                                            icon.expiringBorderAlphaContainer:Show()
                                            
                                            if icon.expiringBorderColorByTime then
                                                if icon.expiringBorderAlphaContainer.SetAlphaFromBoolean then
                                                    icon.expiringBorderAlphaContainer:SetAlphaFromBoolean(hasExpiration, 1, 0)
                                                else
                                                    icon.expiringBorderAlphaContainer:SetAlpha(1)
                                                end
                                                
                                                if not DF.expiringBorderColorCurve then
                                                    local curve = C_CurveUtil.CreateColorCurve()
                                                    curve:SetType(Enum.LuaCurveType.Linear)
                                                    curve:AddPoint(0, CreateColor(1, 0, 0, 1))
                                                    curve:AddPoint(0.3, CreateColor(1, 0.5, 0, 1))
                                                    curve:AddPoint(0.5, CreateColor(1, 1, 0, 1))
                                                    curve:AddPoint(1, CreateColor(0, 1, 0, 1))
                                                    DF.expiringBorderColorCurve = curve
                                                end
                                                
                                                local colorResult = durationObj:EvaluateRemainingPercent(DF.expiringBorderColorCurve)
                                                if colorResult and colorResult.GetRGBA and icon.expiringBorderTop then
                                                    icon.expiringBorderTop:SetColorTexture(colorResult:GetRGBA())
                                                    icon.expiringBorderBottom:SetColorTexture(colorResult:GetRGBA())
                                                    icon.expiringBorderLeft:SetColorTexture(colorResult:GetRGBA())
                                                    icon.expiringBorderRight:SetColorTexture(colorResult:GetRGBA())
                                                end
                                            else
                                                if icon.expiringBorderAlphaContainer.SetAlphaFromBoolean then
                                                    icon.expiringBorderAlphaContainer:SetAlphaFromBoolean(hasExpiration, expiringAlpha, 0)
                                                else
                                                    icon.expiringBorderAlphaContainer:SetAlpha(expiringAlpha)
                                                end
                                            end
                                            
                                            if icon.expiringBorderPulsate and icon.expiringBorderPulse and not icon.expiringBorderPulse:IsPlaying() then
                                                icon.expiringBorderPulse:Play()
                                            end
                                        elseif icon.expiringBorderAlphaContainer then
                                            icon.expiringBorderAlphaContainer:Hide()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Start timer
C_Timer.After(1, function()
    auraTimerGroup:Play()
    DF.AuraTimer = auraTimerGroup
    lastReportTime = GetTime()
end)

-- Stats function for /df auratimer
function DF:GetAuraTimerStats()
    local iconCount = 0
    for _ in pairs(trackedIcons) do iconCount = iconCount + 1 end
    
    local now = GetTime()
    local elapsed = now - lastReportTime
    if elapsed < 1 then elapsed = 1 end
    
    local callsPerSec = timerCallCount / elapsed
    local iconsPerSec = iconsProcessedCount / elapsed
    
    -- Average icons per timer call
    local avgIconsPerCall = timerCallCount > 0 and (iconsProcessedCount / timerCallCount) or 0
    
    -- Compare to old system: 
    -- Old: Each icon runs OnUpdate at ~60fps
    -- New: Our timer runs at 5fps
    -- So old system = avgIcons * 60, new = avgIcons * 5
    local oldSystemCallsPerSec = avgIconsPerCall * 60
    local newSystemCallsPerSec = avgIconsPerCall * 5
    local savings = oldSystemCallsPerSec > 0 and ((oldSystemCallsPerSec - newSystemCallsPerSec) / oldSystemCallsPerSec * 100) or 0
    
    return {
        timerCalls = timerCallCount,
        iconsProcessed = iconsProcessedCount,
        trackedIcons = iconCount,
        peakIcons = peakTrackedIcons,
        avgIconsPerCall = avgIconsPerCall,
        callsPerSec = callsPerSec,
        iconsPerSec = iconsPerSec,
        oldSystemCallsPerSec = oldSystemCallsPerSec,
        newSystemCallsPerSec = newSystemCallsPerSec,
        savingsPercent = savings,
        elapsed = elapsed,
        byFrameType = iconsByFrameType
    }
end

function DF:PrintAuraTimerStats()
    local stats = self:GetAuraTimerStats()
    print("|cFF00FFFF[DF AuraTimer Stats]|r")
    print(string.format("  Icons: %d current, %d peak, %.1f avg/call", stats.trackedIcons, stats.peakIcons, stats.avgIconsPerCall))
    print(string.format("  Timer calls: %d (%.1f/sec)", stats.timerCalls, stats.callsPerSec))
    print(string.format("  Icons processed: %d (%.1f/sec)", stats.iconsProcessed, stats.iconsPerSec))
    print(string.format("  |cFFAAAAFF  Party: %d, Raid: %d, Highlight: %d, Unknown: %d|r", 
        stats.byFrameType.party, stats.byFrameType.raid, stats.byFrameType.highlight, stats.byFrameType.unknown))
    print(string.format("  |cFFFFFF00Old system (60fps): %.0f calls/sec|r", stats.oldSystemCallsPerSec))
    print(string.format("  |cFF00FF00New system (5fps): %.0f calls/sec|r", stats.newSystemCallsPerSec))
    print(string.format("  |cFF00FF00Reduction: %.1f%%|r", stats.savingsPercent))
end

function DF:ResetAuraTimerStats()
    timerCallCount = 0
    iconsProcessedCount = 0
    peakTrackedIcons = 0
    iconsByFrameType = { party = 0, raid = 0, highlight = 0, unknown = 0 }
    lastReportTime = GetTime()
    print("|cFF00FFFF[DF AuraTimer]|r Stats reset")
end

-- Register icon
function DF:RegisterIconForAuraTimer(icon)
    if icon then
        trackedIcons[icon] = true
    end
end

-- Unregister icon
function DF:UnregisterIconFromAuraTimer(icon)
    if icon then
        trackedIcons[icon] = nil
    end
end

-- Per-unit aura cache, the single source of truth for aura data across
-- all DF consumers (Direct mode aura pipeline, Aura Designer, defensive
-- icon, dispel overlay, sound engine, missing-buff detection, etc.).
--
-- Originally named DF.BlizzardAuraCache because it was populated only
-- from Blizzard's compact frame state. Since Direct mode was added and
-- Blizzard mode is being removed in the upcoming 12.0.5 patch, the
-- cache is no longer Blizzard-specific. `DF.AuraCache` is the new
-- canonical name; `DF.BlizzardAuraCache` is kept as an alias for the
-- ~35 existing call sites and for third-party code that may reference
-- the old name. Both names reference the same underlying table.
--
-- Cache entry shape (per unit):
--
--   buffs             = { [auraInstanceID] = true }   -- buffs that pass the user's buff filter
--   debuffs           = { [auraInstanceID] = true }   -- debuffs that pass the user's debuff filter
--   buffOrder         = { [i] = auraInstanceID }      -- sorted display order for buffs
--   debuffOrder       = { [i] = auraInstanceID }      -- sorted display order for debuffs
--   buffData          = { [i] = auraData }            -- legacy sorted array (Direct mode only)
--   debuffData        = { [i] = auraData }            -- legacy sorted array (Direct mode only)
--   playerDispellable = { [auraInstanceID] = true }   -- debuffs the player can dispel
--   allDispellable    = { [auraInstanceID] = true }   -- debuffs anyone can dispel
--   defensives        = { [auraInstanceID] = true }   -- tracked defensive auras
--
-- Fix A extensions (added 2026-04-08, consumers not yet migrated):
--
--   buffsByID         = { [auraInstanceID] = auraData }  -- raw aura data, unsorted, keyed by ID
--   debuffsByID       = { [auraInstanceID] = auraData }  -- raw aura data, unsorted, keyed by ID
--   hasFullScan       = boolean                          -- true once ScanUnitFull has run for this unit
--   buffOrderDirty    = boolean                          -- true if buffOrder needs to be re-sorted
--   debuffOrderDirty  = boolean                          -- true if debuffOrder needs to be re-sorted
--
-- Fix A commit 1 (infrastructure): the new ScanUnitFull and
-- ApplyAuraDelta helpers populate the new fields, but the hot path
-- (directModeSubscriber:OnUnitAura) still calls the old ScanUnitDirect
-- which populates the legacy fields. Both old and new fields coexist
-- until commit 2 flips the hot path to the incremental model.
DF.AuraCache = {}
DF.BlizzardAuraCache = DF.AuraCache  -- backward-compat alias, same table

-- Ensure a cache entry exists for a unit. Creates the full shape (old
-- legacy fields + new Fix A fields) on first access. Safe to call
-- multiple times — no-op if the entry already exists. Returns the
-- entry table.
local function EnsureAuraCacheEntry(unit)
    local entry = DF.AuraCache[unit]
    if entry then return entry end
    entry = {
        -- Legacy fields (populated by old ScanUnitDirect / Blizzard capture)
        buffs             = {},
        debuffs           = {},
        buffOrder         = {},
        debuffOrder       = {},
        buffData          = {},
        debuffData        = {},
        playerDispellable = {},
        allDispellable    = {},
        defensives        = {},
        -- Fix A new fields (populated by ScanUnitFull / ApplyAuraDelta)
        buffsByID         = {},
        debuffsByID       = {},
        hasFullScan       = false,
        buffOrderDirty    = false,
        debuffOrderDirty  = false,
    }
    DF.AuraCache[unit] = entry
    return entry
end

-- Track if we've successfully hooked Blizzard's frames
DF.BlizzardHookActive = false

-- ============================================================
-- SCAN BLIZZARD FRAMES FOR APPROVED AURAS
-- ============================================================

-- ============================================================
-- TRIGGER AURA UPDATES FOR ALL DF FRAMES SHOWING A UNIT
-- Shared by both Blizzard hook and Direct UNIT_AURA handler
-- ============================================================

local function TriggerAuraUpdateForUnit(unit)
    -- Fast unit→frame lookup via exposed unitFrameMap
    local ourFrame = DF.unitFrameMap and DF.unitFrameMap[unit]

    DF:Debug("BLIZAURA", "TriggerUpdate for %s — unitFrameMap hit: %s", unit, ourFrame and ourFrame:GetName() or "nil")

    -- Fallback: iterate if unitFrameMap not yet available (early init)
    if not ourFrame then
        DF:Debug("BLIZAURA", "TriggerUpdate fallback iterate for %s", unit)
        -- Check arena first (IsInRaid()=true in arena)
        if DF.IsInArena and DF:IsInArena() then
            if DF.IterateArenaFrames then
                DF:IterateArenaFrames(function(f)
                    if f and f.unit == unit then
                        ourFrame = f
                        return true
                    end
                end)
            end
        else
            if DF.IteratePartyFrames then
                DF:IteratePartyFrames(function(f)
                    if f and f.unit == unit then
                        ourFrame = f
                        return true
                    end
                end)
            end
            if not ourFrame and DF.IterateRaidFrames then
                DF:IterateRaidFrames(function(f)
                    if f and f.unit == unit then
                        ourFrame = f
                        return true
                    end
                end)
            end
        end
        if ourFrame then
            DF:Debug("BLIZAURA", "TriggerUpdate fallback found: %s", ourFrame:GetName())
        else
            DF:DebugWarn("BLIZAURA", "TriggerUpdate NO frame found for %s", unit)
        end
    end

    if ourFrame and ourFrame:IsVisible() then
        if DF.UpdateAuras_Enhanced then
            DF:Debug("BLIZAURA", "Calling UpdateAuras_Enhanced for %s on %s", unit, ourFrame:GetName())
            DF:UpdateAuras_Enhanced(ourFrame)
        end
        if DF.UpdateDefensiveBar then
            DF:UpdateDefensiveBar(ourFrame)
        end
        if DF.UpdateMyBuffIndicator then
            DF:UpdateMyBuffIndicator(ourFrame)
        end
        if DF.UpdateMissingBuffIcon then
            DF:UpdateMissingBuffIcon(ourFrame)
        end
        if DF.UpdateDispelOverlay then
            DF:UpdateDispelOverlay(ourFrame)
        end
    elseif ourFrame then
        DF:DebugWarn("BLIZAURA", "TriggerUpdate SKIPPED for %s — frame %s not visible", unit, ourFrame:GetName())
    end

    -- Also update pinned frames showing this unit
    -- (Pinned frames share units with main frames but are excluded from unitFrameMap)
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        local pinnedDB = DF.db and DF.db[IsInRaid() and "raid" or "party"]
        pinnedDB = pinnedDB and pinnedDB.pinnedFrames
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            local set = pinnedDB and pinnedDB.sets and pinnedDB.sets[setIndex]
            if header and header:IsShown() and set and set.enabled then
                for i = 1, 40 do
                    local child = header:GetAttribute("child" .. i)
                    if child and child:IsVisible() and child.unit == unit then
                        if DF.UpdateAuras_Enhanced then
                            DF:UpdateAuras_Enhanced(child)
                        end
                        if DF.UpdateDefensiveBar then
                            DF:UpdateDefensiveBar(child)
                        end
                        if DF.UpdateMyBuffIndicator then
                            DF:UpdateMyBuffIndicator(child)
                        end
                        if DF.UpdateMissingBuffIcon then
                            DF:UpdateMissingBuffIcon(child)
                        end
                        if DF.UpdateDispelOverlay then
                            DF:UpdateDispelOverlay(child)
                        end
                    end
                end
            end
        end
    end

    -- Also update pinned boss frames
    if DF.PinnedFrames and DF.PinnedFrames.bossFrames then
        for setIndex = 1, 2 do
            local frames = DF.PinnedFrames.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    local f = frames[i]
                    if f and f:IsVisible() and f.unit == unit then
                        if DF.UpdateAuras_Enhanced then DF:UpdateAuras_Enhanced(f) end
                        if DF.UpdateDefensiveBar then DF:UpdateDefensiveBar(f) end
                    end
                end
            end
        end
    end
end

-- Forward declarations: these helpers are defined later in the file (used by
-- the Direct API path), but CaptureAurasFromBlizzardFrame also calls them to
-- compute defensive auras via the secret-safe IsAuraFilteredOutByInstanceID,
-- avoiding the broken-in-12.0.5 frame.CenterDefensiveBuff read.
local BuildDirectDefensiveFilters
local AuraPassesAnyFilter

-- ============================================================
-- API COMPATIBILITY: Blizzard aura source removed in 12.0.5
-- ------------------------------------------------------------
-- WoW 12.0.5 removed party-frame buff/debuff rendering from the default
-- compact party/raid frames entirely. The aura containers (frame.buffs,
-- frame.debuffs), the Lua update functions (CompactUnitFrame_UpdateAuras,
-- UpdateBuffs, UpdateDebuffs), and every hook point the Blizzard capture
-- path depended on are gone. The configuration fields (maxBuffs, auraSize,
-- etc.) remain on the frame, but the actual aura data never enters Lua —
-- rendering is done entirely in native code now.
--
-- Since "Blizzard data source" mode works by mirroring Blizzard's display
-- decisions, and there are no more decisions to mirror, that mode is
-- architecturally impossible on 12.0.5+. We detect the condition at addon
-- init, force both party and raid profiles to DIRECT mode, persist the
-- flag to SavedVariables so the migration only happens once, and show a
-- one-time popup explaining the change.
--
-- Detection: CompactUnitFrame_UpdateAuras is the cleanest single indicator.
-- On live retail it's a Lua function; on 12.0.5+ it's nil. No other state
-- is required — if the function exists, Blizzard still has a Lua aura
-- pipeline; if it doesn't, they don't.
-- ============================================================

local function IsBlizzardAuraSourceAvailable()
    -- Force-disabled: Blizzard aura data source is being removed in 12.0.5
    -- and is already causing issues. Returning false unconditionally so all
    -- users migrate to Direct API now rather than waiting for the patch.
    return false
end

-- Applies the forced migration to both party and raid profiles. Called both
-- at first detection (new flag) and on every subsequent load where the flag
-- is already set (so the setting can't drift back to BLIZZARD via profile
-- import, reset, or copy).
local function ForceDirectAuraSourceMode()
    if not DF.db then return end
    if DF.db.party then DF.db.party.auraSourceMode = "DIRECT" end
    if DF.db.raid  then DF.db.raid.auraSourceMode  = "DIRECT" end
end

-- One-time detection + migration. Runs once after DF.db is available.
-- Safe to call multiple times — the first call flips the flag and shows
-- the popup, subsequent calls only re-apply the forced setting.
function DF:CheckBlizzardAuraSourceAvailable()
    -- Already migrated this session — nothing to do.
    if DF.BlizzardAuraSourceUnavailable then
        ForceDirectAuraSourceMode()
        return
    end

    -- Blizzard's pipeline is still present — nothing to migrate.
    if IsBlizzardAuraSourceAvailable() then
        return
    end

    -- Detection positive. Set the in-memory flag immediately so the rest
    -- of this file's early-returns see it.
    DF.BlizzardAuraSourceUnavailable = true

    -- Force the setting on both profiles right now, before anything else
    -- tries to read it.
    ForceDirectAuraSourceMode()

    -- Persist so we don't re-run detection (and re-show the popup) on every
    -- reload. Also persists the migration across reloads even if the user
    -- somehow flips auraSourceMode back (e.g. via profile import).
    if DandersFramesDB_v2 then
        DandersFramesDB_v2.apiBlocked = DandersFramesDB_v2.apiBlocked or {}
        local first = not DandersFramesDB_v2.apiBlocked.blizzardAuraSource
        DandersFramesDB_v2.apiBlocked.blizzardAuraSource = true

        -- Only show the popup the first time we detect this, so users don't
        -- get spammed on every reload after the initial migration.
        if first then
            -- Defer the popup until after the GUI is ready (popup system lives
            -- in Popup.lua which loads later in the TOC and needs ADDON_LOADED
            -- to finish).
            C_Timer.After(2, function()
                if DF.ShowPopupAlert then
                    -- Inline arrow icon for bullet points. Uses a texture
                    -- escape sequence so we're not relying on unicode symbols
                    -- (WoW's font doesn't render ► / ▸ etc. — they show as
                    -- tofu squares). The 14:14:0:0 sizing lines the icon up
                    -- with the GameFontNormal baseline.
                    local arrow = "|TInterface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right:14:14:0:0|t"

                    -- Filter settings we'll highlight when the user clicks
                    -- "Show Me" — same list the old Aura Filter Setup wizard
                    -- used. Covers every Direct API buff + debuff filter plus
                    -- the sort-order dropdowns so users can review everything
                    -- in one place.
                    local directFilterKeys = {
                        "directBuffShowAll", "directBuffOnlyMine",
                        "directBuffFilterRaid", "directBuffFilterRaidInCombat",
                        "directBuffFilterCancelable", "directBuffFilterNotCancelable",
                        "directBuffFilterImportant", "directBuffFilterBigDefensive",
                        "directBuffFilterExternalDefensive", "directBuffSortOrder",
                        "directDebuffShowAll", "directDebuffFilterRaid",
                        "directDebuffFilterRaidInCombat", "directDebuffFilterCrowdControl",
                        "directDebuffFilterImportant",
                        "directDebuffDispellableMode",
                        "directDebuffSortOrder",
                    }

                    local function openAuraFiltersTabAndHighlight()
                        -- Open GUI if not already open
                        local guiOpen = DF.GUIFrame and DF.GUIFrame:IsShown()
                        if not guiOpen and DF.ToggleGUI then
                            DF:ToggleGUI()
                        end
                        -- Give the GUI a tick to finish building, then switch
                        -- to the Aura Filters tab and highlight the filter
                        -- controls.
                        C_Timer.After(0.3, function()
                            if DF.GUI and DF.GUI.SelectTab then
                                DF.GUI.SelectTab("auras_filters")
                            end
                            C_Timer.After(0.3, function()
                                if DF.HighlightSettings then
                                    DF:HighlightSettings("auras_filters", directFilterKeys)
                                end
                            end)
                        end)
                    end

                    DF:ShowPopupAlert({
                        title = "|cffff3333!!! PLEASE READ !!!|r",
                        icon  = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
                        width = 500,
                        message =
                            "|cffff9900Aura Data Source changed — action may be required|r\n\n"
                            .. "Blizzard has removed the ability for addons to read buff and debuff data from their default compact party/raid frames in WoW 12.0.5.\n\n"
                            .. "This breaks the |cffffffff\"Blizzard\"|r aura data source in DandersFrames. To keep your buffs, debuffs, and dispels working, DandersFrames has automatically switched you to the |cff88ff88\"Direct API\"|r source, which reads aura data directly from the game and is unaffected by this change.\n\n"
                            .. arrow .. " |cffccccccYour buffs and debuffs should appear normally on DandersFrames.|r\n"
                            .. arrow .. " |cffccccccYou may want to review the Direct API filter options in the Aura Filters settings tab.|r\n"
                            .. arrow .. " |cffccccccGoing forward, unless Blizzard reverses this change, Direct API will be the only supported aura data source.|r",
                        buttons = {
                            { label = "Show Me",       onClick = openAuraFiltersTabAndHighlight },
                            { label = "I Understand" },
                        },
                    })
                end
            end)
        end
    end

    DF:Debug("BLIZAURA", "CompactUnitFrame_UpdateAuras is nil — forced DIRECT aura source mode (Blizzard pipeline removed in 12.0.5)")
end

-- Iterate a Blizzard aura container (frame.buffs / frame.debuffs / etc).
-- Calls visit(aura) for each aura table in the container.
--
-- Blizzard's container :Iterate API differs across builds:
--   * Retail (live): callback form — `container:Iterate(function(key, aura) end)`
--     Calling without a callback errors with "attempt to call local 'callback' (a nil value)".
--   * PTR 12.0.5: stateless form — `for key, aura in container:Iterate() do end`
--     Calling with a callback silently does nothing (the first yielded
--     pair is (key, auraTable); a single loop variable would get the key).
--
-- We detect which form this build uses once (cached) by inspecting the
-- Iterate function's declared parameter count via debug.getinfo. The
-- callback form is defined as `:Iterate(callback)` → nparams >= 2 (self,
-- callback). The stateless form is `:Iterate()` → nparams == 1 (self).
-- If detection fails (debug unavailable), default to "callback" since
-- that's the currently-shipping retail API.
local iterateApiMode  -- "callback" | "stateless" | nil (unknown)

local function DetectIterateApi(container)
    if iterateApiMode then return iterateApiMode end
    if not container or not container.Iterate then return nil end
    local info = debug and debug.getinfo and debug.getinfo(container.Iterate, "u")
    if info and info.nparams and info.nparams >= 1 then
        if info.nparams >= 2 then
            iterateApiMode = "callback"
        else
            iterateApiMode = "stateless"
        end
    else
        -- Detection failed — default to callback form (retail).
        iterateApiMode = "callback"
    end
    return iterateApiMode
end

local function IterateAuraContainer(container, visit)
    if not container or not container.Iterate then return end
    local mode = DetectIterateApi(container)
    if mode == "callback" then
        container:Iterate(function(key, aura)
            -- Callback form passes (key, aura) where key is the
            -- auraInstanceID and aura is the aura data table.
            local auraTable = (type(aura) == "table") and aura or { auraInstanceID = key }
            visit(auraTable)
            return false  -- continue iterating (true would stop)
        end)
    else
        -- Stateless form: `for key, aura in container:Iterate() do`.
        -- We capture both values and pick whichever is the table.
        for a, b in container:Iterate() do
            if type(b) == "table" then
                visit(b)
            elseif type(a) == "table" then
                visit(a)
            end
        end
    end
end

local function CaptureAurasFromBlizzardFrame(frame, triggerUpdate)
    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableBlizzardAuraCache then return end

    -- 12.0.5+ short-circuit: if Blizzard removed the aura pipeline, there is
    -- literally no data to capture from the frame. Exit immediately before
    -- touching frame.buffs / frame.debuffs (which are nil on these builds).
    -- Also catches the load-time ScanAllBlizzardFrames() call which runs
    -- before the delayed detection in InitializeEnhancedAuras has had a
    -- chance to set DF.BlizzardAuraSourceUnavailable — hence the direct
    -- function check as a fallback.
    if DF.BlizzardAuraSourceUnavailable
       or type(_G.CompactUnitFrame_UpdateAuras) ~= "function" then
        return
    end

    if not frame or not frame.unit then return end
    
    -- CRITICAL GUARD: Skip frames where unitExists is false
    -- This can happen during rapid roster changes (e.g., joining a BG) where the frame
    -- has a unit assigned but the unit doesn't actually exist yet. Processing such frames
    -- can cause Blizzard's CompactUnitFrame code to error on nil tables.
    if frame.unitExists == false then return end
    
    -- PERFORMANCE FIX 2025-01-20: Check for nameplate FIRST before calling GetName()
    -- Nameplates pass through CompactUnitFrame_UpdateAuras hooks but we don't need their data
    -- and calling GetName() on them can error. Check unit string first (safe operation).
    local unit = frame.unit
    if unit and type(unit) == "string" and unit:find("nameplate") then
        return
    end
    -- Also check displayedUnit which nameplates may use
    local displayedUnit = frame.displayedUnit
    if displayedUnit and type(displayedUnit) == "string" and displayedUnit:find("nameplate") then
        return
    end

    -- Roster-only guard: arena enemy frames and boss frames pass compound
    -- tokens like `boss1targetpet` through this hook, and the 12.0.5
    -- GetUnitAuras API hard-errors on those. We only ever care about
    -- player/partyN/raidN auras anyway.
    if not IsRosterUnit(unit) then return end

    -- Now safe to try GetName since we've filtered out nameplates
    local frameName = nil
    if frame.GetName and type(frame.GetName) == "function" then
        frameName = frame:GetName()
    end
    
    -- Skip preview frames and settings frames by name
    if frameName then
        if frameName:find("Preview") or frameName:find("Settings") or frameName:find("NamePlate") then
            return
        end
    end

    -- Skip Blizzard cache population when Direct mode is active for this unit.
    -- Three resolution paths, in order:
    --   1. Unit is mapped to a DF frame → check that frame's mode db
    --   2. DF.db is built but unit isn't mapped yet (race during init) →
    --      check both party and raid profile dbs
    --   3. DF.db isn't built yet (file-load-time scan from
    --      InitializeEnhancedAuras, before Core.lua wires up the profile) →
    --      read SavedVariables directly
    local function IsDirectModeActiveForUnit(u)
        local mf = DF.unitFrameMap and DF.unitFrameMap[u]
        if mf then
            local modeDb = DF:GetFrameDB(mf)
            return modeDb and modeDb.auraSourceMode == "DIRECT"
        end

        local partyDb = DF.db and DF.db.party
        local raidDb = DF.db and DF.db.raid
        if partyDb or raidDb then
            return (partyDb and partyDb.auraSourceMode == "DIRECT")
                or (raidDb and raidDb.auraSourceMode == "DIRECT")
        end

        -- Pre-init: dig into SavedVariables directly
        if DandersFramesDB_v2 and DandersFramesDB_v2.profiles then
            local profileName = DandersFramesDB_v2.currentProfile or "Default"
            local profile = DandersFramesDB_v2.profiles[profileName]
            if profile then
                if profile.party and profile.party.auraSourceMode == "DIRECT" then return true end
                if profile.raid and profile.raid.auraSourceMode == "DIRECT" then return true end
            end
        end
        return false
    end

    if IsDirectModeActiveForUnit(unit) then
        DF:Debug("BLIZAURA", "Capture SKIPPED for %s — Direct mode active", unit)
        return
    end

    DF:Debug("BLIZAURA", "Capture START for %s (frame: %s, trigger: %s)", unit, frameName or "?", tostring(triggerUpdate))

    -- Initialize cache for this unit (helper creates the full shape)
    local cache = EnsureAuraCacheEntry(unit)

    -- Clear previous cache for this unit (wipe instead of new table to reduce GC)
    if not cache.allDispellable then cache.allDispellable = {} end
    wipe(cache.buffs)
    wipe(cache.debuffs)
    wipe(cache.buffOrder)
    wipe(cache.debuffOrder)
    wipe(cache.buffData)
    wipe(cache.debuffData)
    wipe(cache.playerDispellable)
    wipe(cache.allDispellable)
    wipe(cache.defensives)

    -- Capture buff auraInstanceIDs from Blizzard's container.
    --
    -- Blizzard's aura containers expose :Iterate, but the API shape differs
    -- between builds: live uses a callback form `container:Iterate(callback)`,
    -- PTR 12.0.5 uses a stateless iterator `for key, aura in container:Iterate()`.
    -- IterateAuraContainer auto-detects which form this build supports (via
    -- debug.getinfo on the Iterate function) and routes to the right path.
    --
    -- frame.buffs returns only the auras Blizzard chose to display (a heavily
    -- filtered subset). We use this for the buff bar display only — defensive
    -- classification is done separately below against the FULL helpful aura
    -- list so the dedup set isn't biased.
    if frame.buffs and frame.buffs.Iterate then
        IterateAuraContainer(frame.buffs, function(aura)
            local id = aura.auraInstanceID
            if id then
                cache.buffs[id] = true
                cache.buffOrder[#cache.buffOrder + 1] = id
            end
        end)
    else
        DF:DebugWarn("BLIZAURA", "No buffs container on frame for %s (buffs: %s, Iterate: %s)", unit, tostring(frame.buffs ~= nil), tostring(frame.buffs and frame.buffs.Iterate ~= nil))
    end

    -- Defensives are populated below via DF:PopulateDefensiveCache (called
    -- right before TriggerAuraUpdateForUnit). The capture iteration here
    -- only fills cache.buffs/debuffs — defensive classification is done
    -- separately so it works on any build / both source modes.

    -- Capture debuff auraInstanceIDs from Blizzard's container.
    -- All aura data fields are secret/tainted in combat, so we only read
    -- auraInstanceID (a non-secret integer). For dispel detection we run
    -- each ID through IsAuraFilteredOutByInstanceID which is secret-safe.
    -- See IterateAuraContainer above for how we handle the callback vs
    -- stateless API difference between retail and PTR builds.
    local dispelFilterStr = "HARMFUL|RAID_PLAYER_DISPELLABLE"
    if frame.debuffs and frame.debuffs.Iterate then
        IterateAuraContainer(frame.debuffs, function(aura)
            local id = aura.auraInstanceID
            if id then
                cache.debuffs[id] = true
                cache.debuffOrder[#cache.debuffOrder + 1] = id
                -- Nil-check on secret values is safe (verified) — dispelName
                -- is nil for non-dispellable debuffs, non-nil (possibly secret)
                -- for dispellable ones. Populates allDispellable so the Dispel
                -- overlay works in Blizzard mode's "All Dispellable" setting.
                if aura.dispelName ~= nil then
                    cache.allDispellable[id] = true
                end
                if IsAuraFilteredOut and not IsAuraFilteredOut(unit, id, dispelFilterStr) then
                    cache.playerDispellable[id] = true
                end
            end
        end)
    else
        DF:DebugWarn("BLIZAURA", "No debuffs container on frame for %s (debuffs: %s, Iterate: %s)", unit, tostring(frame.debuffs ~= nil), tostring(frame.debuffs and frame.debuffs.Iterate ~= nil))
    end

    -- LEGACY (pre-12.0.8): Blizzard used frame arrays for aura data.
    -- Kept for reference in case Blizzard reverts. See new container implementation above.
    --[[ OLD BUFF FRAMES METHOD:
    if frame.buffFrames and type(frame.buffFrames) == "table" then
        for i, buffFrame in ipairs(frame.buffFrames) do
            if buffFrame and buffFrame.IsShown and buffFrame:IsShown() and buffFrame.auraInstanceID then
                cache.buffs[buffFrame.auraInstanceID] = true
                cache.buffOrder[#cache.buffOrder + 1] = buffFrame.auraInstanceID
            end
        end
    end
    ]]

    --[[ OLD DEBUFF FRAMES METHOD:
    if frame.debuffFrames and type(frame.debuffFrames) == "table" then
        for i, debuffFrame in ipairs(frame.debuffFrames) do
            if debuffFrame and debuffFrame.IsShown and debuffFrame:IsShown() and debuffFrame.auraInstanceID then
                cache.debuffs[debuffFrame.auraInstanceID] = true
                cache.debuffOrder[#cache.debuffOrder + 1] = debuffFrame.auraInstanceID
            end
        end
    end
    ]]

    --[[ OLD DISPEL DEBUFF FRAMES METHOD:
    if frame.dispelDebuffFrames and type(frame.dispelDebuffFrames) == "table" then
        for i, debuffFrame in ipairs(frame.dispelDebuffFrames) do
            if debuffFrame and debuffFrame.IsShown and debuffFrame:IsShown() and debuffFrame.auraInstanceID then
                if not cache.debuffs[debuffFrame.auraInstanceID] then
                    cache.debuffs[debuffFrame.auraInstanceID] = true
                    cache.debuffOrder[#cache.debuffOrder + 1] = debuffFrame.auraInstanceID
                end
                cache.playerDispellable[debuffFrame.auraInstanceID] = true
            end
        end
    end
    ]]
    
    local dispelCount = 0
    for _ in pairs(cache.playerDispellable) do dispelCount = dispelCount + 1 end
    DF:Debug("BLIZAURA", "Capture DONE for %s — buffs: %d, debuffs: %d, dispel: %d", unit, #cache.buffOrder, #cache.debuffOrder, dispelCount)

    -- Defensive classification: populate cache.defensives via the secret-safe
    -- Direct API path. This MUST happen before TriggerAuraUpdateForUnit fires
    -- because the buff bar (UpdateAuras_Enhanced) reads cache.defensives for
    -- defensive deduplication. If we leave it until UpdateDefensiveBar (which
    -- runs AFTER UpdateAuras_Enhanced in the trigger chain), the dedup set is
    -- empty and defensive auras show up in BOTH the buff bar and the
    -- defensive icon. UpdateDefensiveBar still calls PopulateDefensiveCache
    -- itself for the standalone case (options refresh, test mode, etc.).
    if DF.PopulateDefensiveCache then
        DF:PopulateDefensiveCache(unit)
    end

    -- Cache is now populated. Trigger display update if requested.
    --
    -- ARCHITECTURE: This hooksecurefunc callback fires AFTER
    -- Blizzard's CompactUnitFrame_UpdateAuras handler, so the cache is always
    -- fresh. This hook is the SOLE trigger for aura display updates — DF's own
    -- UNIT_AURA event handler does NOT call UpdateAuras, avoiding both race
    -- conditions (stale cache reads) and redundant double-updates.
    if triggerUpdate then
        TriggerAuraUpdateForUnit(unit)
    end
end

-- Scan ALL Blizzard compact frames to build cache
local function ScanAllBlizzardFrames()
    -- Scan party frames
    for i = 1, 4 do
        local frame = _G["CompactPartyFrameMember" .. i]
        -- Only scan frames that exist and have a valid unit
        if frame and frame.unit and frame.unitExists ~= false then
            CaptureAurasFromBlizzardFrame(frame, true)
        end
    end
    
    -- Scan raid frames
    for i = 1, 40 do
        local frame = _G["CompactRaidFrame" .. i]
        if frame and frame.unit and frame.unitExists ~= false then
            CaptureAurasFromBlizzardFrame(frame, true)
        end
    end
    
    -- Scan raid group frames
    for group = 1, 8 do
        for member = 1, 5 do
            local frame = _G["CompactRaidGroup" .. group .. "Member" .. member]
            if frame and frame.unit and frame.unitExists ~= false then
                CaptureAurasFromBlizzardFrame(frame, true)
            end
        end
    end
end

-- Find Blizzard frame for a specific unit and capture its auras
local function ScanBlizzardFrameForUnit(unit)
    if not unit then return end
    
    -- Check all possible Blizzard frame locations for this unit
    
    -- Party frames
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. i]
        if frame and frame.unit == unit and frame.unitExists ~= false then
            CaptureAurasFromBlizzardFrame(frame, true)
            return
        end
    end
    
    -- Raid frames
    for i = 1, 40 do
        local frame = _G["CompactRaidFrame" .. i]
        if frame and frame.unit == unit and frame.unitExists ~= false then
            CaptureAurasFromBlizzardFrame(frame, true)
            return
        end
    end
    
    -- Raid group frames
    for group = 1, 8 do
        for member = 1, 5 do
            local frame = _G["CompactRaidGroup" .. group .. "Member" .. member]
            if frame and frame.unit == unit and frame.unitExists ~= false then
                CaptureAurasFromBlizzardFrame(frame, true)
                return
            end
        end
    end
end

-- ============================================================
-- DIRECT AURA API PROVIDER
-- Queries C_UnitAuras directly with user-configured filter strings
-- Writes results to DF.BlizzardAuraCache (same structure as Blizzard provider)
-- ============================================================

-- Cache AuraUtil filter constants (available in 11.1+)
local AuraFilters = AuraUtil and AuraUtil.AuraFilters or {}

-- Cached filter tables per mode (rebuilt only when settings change)
-- Each is nil (show all / unavailable) or a table of individual filter strings
-- e.g. {"HELPFUL|PLAYER", "HELPFUL|RAID", "HELPFUL|BIG_DEFENSIVE"}
local cachedPartyBuffFilters = nil
local cachedPartyDebuffFilters = nil
local cachedRaidBuffFilters = nil
local cachedRaidDebuffFilters = nil
local cachedDefensiveFilters = nil   -- mode-independent
local cachedDispelFilter = nil       -- mode-independent (single string, no OR needed)

-- Build individual filter strings for buffs (OR logic via post-classification)
-- Returns nil (show all) or table of "HELPFUL|CLASSIFICATION" strings
local function BuildDirectBuffFilters(db)
    local onlyMine = db.directBuffOnlyMine
    local playerSuffix = onlyMine and "|PLAYER" or ""

    if db.directBuffShowAll then
        return onlyMine and {"HELPFUL|PLAYER"} or nil
    end

    local filters = {}
    if db.directBuffFilterRaid then filters[#filters + 1] = "HELPFUL|RAID" .. playerSuffix end
    if db.directBuffFilterRaidInCombat and AuraFilters.RaidInCombat then
        filters[#filters + 1] = "HELPFUL|" .. AuraFilters.RaidInCombat .. playerSuffix
    end
    if db.directBuffFilterCancelable then filters[#filters + 1] = "HELPFUL|CANCELABLE" .. playerSuffix end
    if db.directBuffFilterNotCancelable then filters[#filters + 1] = "HELPFUL|NOT_CANCELABLE" .. playerSuffix end
    if db.directBuffFilterImportant then
        filters[#filters + 1] = "HELPFUL|" .. (AuraFilters.Important or "IMPORTANT") .. playerSuffix
    end
    if db.directBuffFilterBigDefensive and AuraFilters.BigDefensive then
        filters[#filters + 1] = "HELPFUL|" .. AuraFilters.BigDefensive .. playerSuffix
    end
    if db.directBuffFilterExternalDefensive and AuraFilters.ExternalDefensive then
        filters[#filters + 1] = "HELPFUL|" .. AuraFilters.ExternalDefensive .. playerSuffix
    end
    -- No sub-filters selected: show all mine or show all
    if #filters == 0 then
        return onlyMine and {"HELPFUL|PLAYER"} or nil
    end
    return filters
end

-- Build individual filter strings for debuffs (OR logic via post-classification)
-- Returns nil (show all) or table of "HARMFUL|CLASSIFICATION" strings
local function BuildDirectDebuffFilters(db)
    if db.directDebuffShowAll then return nil end
    local filters = {}
    if db.directDebuffFilterRaid then filters[#filters + 1] = "HARMFUL|RAID" end
    if db.directDebuffFilterRaidInCombat and AuraFilters.RaidInCombat then
        filters[#filters + 1] = "HARMFUL|" .. AuraFilters.RaidInCombat
    end
    if db.directDebuffFilterCrowdControl and AuraFilters.CrowdControl then
        filters[#filters + 1] = "HARMFUL|" .. AuraFilters.CrowdControl
    end
    if db.directDebuffFilterImportant then
        filters[#filters + 1] = "HARMFUL|" .. (AuraFilters.Important or "IMPORTANT")
    end
    if db.directDebuffDispellableMode == "PLAYER" then
        filters[#filters + 1] = "HARMFUL|" .. (AuraFilters.RaidPlayerDispellable or "RAID_PLAYER_DISPELLABLE")
    end
    -- Note: directDebuffDispellableMode == "ALL" has no Blizzard filter constant —
    -- it's post-classified in ScanUnitDirect via auraData.dispelName ~= nil.
    -- No sub-filters selected = show all (backward compat)
    if #filters == 0 then return nil end
    return filters
end

-- Build defensive filter table (BIG_DEFENSIVE + EXTERNAL_DEFENSIVE, nil if unavailable)
-- Assigned to the forward-declared local at the top of the file so it is
-- visible inside CaptureAurasFromBlizzardFrame.
function BuildDirectDefensiveFilters()
    if cachedDefensiveFilters then return cachedDefensiveFilters end
    local filters = {}
    if AuraFilters.BigDefensive then filters[#filters + 1] = "HELPFUL|" .. AuraFilters.BigDefensive end
    if AuraFilters.ExternalDefensive then filters[#filters + 1] = "HELPFUL|" .. AuraFilters.ExternalDefensive end
    if #filters == 0 then return nil end
    cachedDefensiveFilters = filters
    return cachedDefensiveFilters
end

-- Build dispel filter (HARMFUL + RAID_PLAYER_DISPELLABLE, single string)
local function BuildDirectDispelFilter()
    if cachedDispelFilter then return cachedDispelFilter end
    local dispelConst = AuraFilters.RaidPlayerDispellable or "RAID_PLAYER_DISPELLABLE"
    cachedDispelFilter = "HARMFUL|" .. dispelConst
    return cachedDispelFilter
end

-- Check if an aura passes any filter in a table (OR logic)
-- Returns true if IsAuraFilteredOutByInstanceID says the aura is NOT filtered out
-- for at least one of the provided filter strings.
-- Assigned to the forward-declared local at the top of the file so it is
-- visible inside CaptureAurasFromBlizzardFrame.
function AuraPassesAnyFilter(unit, auraInstanceID, filters)
    if not IsAuraFilteredOut then return true end
    for i = 1, #filters do
        if not IsAuraFilteredOut(unit, auraInstanceID, filters[i]) then
            return true
        end
    end
    return false
end

-- ============================================================
-- FIX A: INCREMENTAL AURA CACHE HELPERS
-- ============================================================
--
-- These two helpers implement the oUF-style incremental aura update
-- pattern. See _Reference/fix-a-plan.md for the full design.
--
-- ScanUnitFull(unit)
--     Full aura scan for a unit. Wipes and rebuilds the entire
--     AuraCache entry from scratch via GetAuraSlots + GetAuraDataBySlot.
--     Called on first access, on isFullUpdate, on mode transitions,
--     and on filter settings changes. Sets cache.hasFullScan = true.
--
-- ApplyAuraDelta(unit, updateInfo)
--     Incremental update for a unit. Applies updateInfo.addedAuras,
--     updateInfo.updatedAuraInstanceIDs, and updateInfo.removedAuraInstanceIDs
--     to the existing cache entry. Called on UNIT_AURA when
--     updateInfo is present and isFullUpdate is false.
--
-- COMMIT 1 STATUS: infrastructure only. These helpers are defined but
-- the hot path (directModeSubscriber:OnUnitAura) still calls the old
-- ScanUnitDirect. Commit 2 will flip the hot path to use these.
--
-- Both helpers populate the NEW cache fields (buffsByID, debuffsByID,
-- classification sets, hasFullScan, buffOrderDirty, debuffOrderDirty)
-- but do NOT touch the legacy fields (buffOrder, buffData, etc.) that
-- the current hot path depends on. Commit 3 and 4 migrate consumers
-- off the legacy fields.
--
-- COMMIT 2 UPDATE: ScanUnitFull and ApplyAuraDelta now ALSO populate
-- the legacy cache.buffOrder / cache.buffData / cache.debuffOrder /
-- cache.debuffData arrays in sorted order via RebuildLegacySortedArrays,
-- so they are drop-in replacements for the old ScanUnitDirect.
-- UpdateAuraIconsDirect (the icon renderer at ~line 2528) continues to
-- read cache.buffData unchanged. Legacy and new fields both stay fresh.
-- ============================================================

-- Sort comparators for Direct mode — moved here (from below) so
-- RebuildLegacySortedArrays can reference them. The pcall wrappers
-- are deliberately left in place per audit finding #8 — some aura
-- data fields may be secret values on Midnight and would silently
-- fail sort comparisons without the guard.
local function SortByTimeRemaining(a, b)
    local ok, result = pcall(function()
        local aExp = a.expirationTime or 0
        local bExp = b.expirationTime or 0
        if aExp == 0 and bExp == 0 then return false end
        if aExp == 0 then return false end
        if bExp == 0 then return true end
        return aExp < bExp
    end)
    if ok then return result end
    return false
end

local function SortByName(a, b)
    local ok, result = pcall(function()
        return (a.name or "") < (b.name or "")
    end)
    if ok then return result end
    return false
end

-- Module-level scratch tables for RebuildLegacySortedArrays — reused
-- across every rebuild to avoid per-call allocation. wipe()'d at the
-- start of each rebuild.
local sortScratchBuffs  = {}
local sortScratchDebuffs = {}

-- ============================================================
-- FIX A DIAGNOSTIC COUNTERS
-- ============================================================
-- Track how often the hot path takes ScanUnitFull vs ApplyAuraDelta.
-- Goal: verify the incremental path is actually being used in steady
-- state, not just falling through to full rescans. Reset via /dfscan
-- (or manually via DF.AuraCacheStats:Reset()) before a test run.
--
-- TEMPORARY DIAGNOSTIC — remove or demote to debug-only after Fix A
-- is verified working in raid content.
-- ============================================================
DF.AuraCacheStats = {
    scanFull       = 0,  -- ScanUnitFull invocations
    deltaApplied   = 0,  -- ApplyAuraDelta invocations that succeeded
    deltaFallback  = 0,  -- ApplyAuraDelta returned false → fell back to ScanUnitFull
    eventsSeen     = 0,  -- total UNIT_AURA events that reached directModeSubscriber:OnUnitAura
}
function DF.AuraCacheStats:Reset()
    self.scanFull = 0
    self.deltaApplied = 0
    self.deltaFallback = 0
    self.eventsSeen = 0
end

-- Rebuild cache.buffData / cache.buffOrder / cache.debuffData /
-- cache.debuffOrder from cache.buffsByID + cache.debuffsByID + the
-- classification sets. Sorted according to the user's sort preference
-- (TIME, NAME, or DEFAULT = insertion order from buffsByID).
--
-- This is the single place where the legacy sorted arrays get
-- populated. Called from both ScanUnitFull (after a full rebuild)
-- and ApplyAuraDelta (after an incremental update).
--
-- Typical N is small (5-20 auras per unit), so the sort cost is
-- negligible. The module-level scratch tables avoid allocation.
local function RebuildLegacySortedArrays(cache, unit, db)
    if not db then return end

    -- ----- BUFFS -----
    wipe(sortScratchBuffs)
    for id, auraData in pairs(cache.buffsByID) do
        -- Only include auras that passed the user's buff filter
        -- (cache.buffs is the set of classified instance IDs)
        if cache.buffs[id] then
            sortScratchBuffs[#sortScratchBuffs + 1] = auraData
        end
    end

    local buffSort = db.directBuffSortOrder or "DEFAULT"
    if buffSort == "TIME" and #sortScratchBuffs > 1 then
        table.sort(sortScratchBuffs, SortByTimeRemaining)
    elseif buffSort == "NAME" and #sortScratchBuffs > 1 then
        table.sort(sortScratchBuffs, SortByName)
    end

    wipe(cache.buffOrder)
    wipe(cache.buffData)
    for i = 1, #sortScratchBuffs do
        local auraData = sortScratchBuffs[i]
        cache.buffOrder[i] = auraData.auraInstanceID
        cache.buffData[i] = auraData
    end
    cache.buffOrderDirty = false

    -- ----- DEBUFFS -----
    wipe(sortScratchDebuffs)
    for id, auraData in pairs(cache.debuffsByID) do
        if cache.debuffs[id] then
            sortScratchDebuffs[#sortScratchDebuffs + 1] = auraData
        end
    end

    local debuffSort = db.directDebuffSortOrder or "DEFAULT"
    if debuffSort == "TIME" and #sortScratchDebuffs > 1 then
        table.sort(sortScratchDebuffs, SortByTimeRemaining)
    elseif debuffSort == "NAME" and #sortScratchDebuffs > 1 then
        table.sort(sortScratchDebuffs, SortByName)
    end

    wipe(cache.debuffOrder)
    wipe(cache.debuffData)
    for i = 1, #sortScratchDebuffs do
        local auraData = sortScratchDebuffs[i]
        cache.debuffOrder[i] = auraData.auraInstanceID
        cache.debuffData[i] = auraData
    end
    cache.debuffOrderDirty = false
end

-- Resolve a unit's filter arrays (per-mode-cached).
-- Returns: buffFilters, debuffFilters, defensiveFilters, dispelFilter
-- Any of these can be nil meaning "show all" for that category.
local function ResolveFiltersForUnit(unit)
    local frame = DF.unitFrameMap and DF.unitFrameMap[unit]
    local db, isRaid
    if frame then
        isRaid = frame.isRaidFrame
        db = isRaid and DF:GetRaidDB() or DF:GetDB()
    else
        db = DF:GetDB()
        isRaid = false
    end
    if not db then return nil, nil, nil, nil end

    local buffFilters = isRaid
        and (cachedRaidBuffFilters or BuildDirectBuffFilters(db))
        or (cachedPartyBuffFilters or BuildDirectBuffFilters(db))
    local debuffFilters = isRaid
        and (cachedRaidDebuffFilters or BuildDirectDebuffFilters(db))
        or (cachedPartyDebuffFilters or BuildDirectDebuffFilters(db))
    local defFilters = BuildDirectDefensiveFilters()
    local dispelFilter = BuildDirectDispelFilter()

    return buffFilters, debuffFilters, defFilters, dispelFilter, db
end

-- Classify a single aura against all filter categories and write the
-- result into the cache's classification sets. Called from both
-- ScanUnitFull (bulk) and ApplyAuraDelta (incremental) so classification
-- logic lives in exactly one place.
--
-- `kind` is either "buff" (helpful auras) or "debuff" (harmful auras).
-- The caller has already done the HELPFUL/HARMFUL split.
local function ClassifyAura(cache, unit, auraData, kind, buffFilters, debuffFilters, defFilters, dispelFilter, db)
    local id = auraData.auraInstanceID
    if not id then return end

    if kind == "buff" then
        -- User-configurable buff filter (nil means show all)
        if not buffFilters or AuraPassesAnyFilter(unit, id, buffFilters) then
            cache.buffs[id] = true
        end
        -- Defensive classification (filter-list, independent of user buff filter)
        if defFilters and AuraPassesAnyFilter(unit, id, defFilters) then
            cache.defensives[id] = true
        end
    else  -- "debuff"
        -- All-dispellable classification (independent of debuff filters).
        -- Used by the dispel overlay's "All Dispellable" mode.
        local isAllDispellable = auraData.dispelName ~= nil
        if isAllDispellable then
            cache.allDispellable[id] = true
        end
        -- User-configurable debuff filter (nil means show all)
        local passesFilters = not debuffFilters or AuraPassesAnyFilter(unit, id, debuffFilters)
        local passesAllDispellable = db and db.directDebuffDispellableMode == "ALL" and isAllDispellable
        if passesFilters or passesAllDispellable then
            cache.debuffs[id] = true
        end
        -- Player-dispellable bookkeeping (dispel overlay reads this)
        if dispelFilter and (not IsAuraFilteredOut or not IsAuraFilteredOut(unit, id, dispelFilter)) then
            cache.playerDispellable[id] = true
        end
    end
end

-- Remove a single aura from all classification sets.
local function UnclassifyAura(cache, id)
    cache.buffs[id] = nil
    cache.debuffs[id] = nil
    cache.defensives[id] = nil
    cache.playerDispellable[id] = nil
    cache.allDispellable[id] = nil
end

-- Full scan — wipes and rebuilds the entire cache entry for a unit.
local function ScanUnitFull(unit)
    if not unit or not UnitExists(unit) then return end
    if not IsRosterUnit(unit) then return end
    if not GetAuraSlots or not GetAuraDataBySlot then return end

    local cache = EnsureAuraCacheEntry(unit)

    -- Don't wipe aura cache for out-of-range units — the API returns nothing
    -- for OOR units, so rescanning would destroy valid cached data.
    -- When they come back in range, UNIT_AURA fires again with real data.
    local frame = DF.unitFrameMap and DF.unitFrameMap[unit]
    if frame then
        local inRange = frame.dfInRange
        local isSecret = issecretvalue and issecretvalue(inRange)
        if not isSecret and inRange == false then
            -- Only skip if we already have data cached (don't skip first scan)
            if cache.hasFullScan then
                return
            end
        end
    end

    -- Wipe the new Fix A fields
    wipe(cache.buffsByID)
    wipe(cache.debuffsByID)
    -- Wipe the classification sets (shared with legacy fields)
    wipe(cache.buffs)
    wipe(cache.debuffs)
    wipe(cache.defensives)
    wipe(cache.playerDispellable)
    wipe(cache.allDispellable)

    local buffFilters, debuffFilters, defFilters, dispelFilter, db = ResolveFiltersForUnit(unit)

    -- HELPFUL pass
    -- GetAuraSlots returns (continuationToken, slot1, slot2, ...) as varargs.
    -- We don't use continuation beyond the first 40-ish slots because our
    -- max aura count is 40. Ignore the continuation token by starting at i=2
    -- in oUF's pattern, but since we use select() we can just iterate all
    -- returns and skip the first one.
    do
        local helpfulReturns = { GetAuraSlots(unit, "HELPFUL") }
        -- helpfulReturns[1] is the continuation token; slots start at [2]
        for i = 2, #helpfulReturns do
            local slot = helpfulReturns[i]
            local auraData = GetAuraDataBySlot(unit, slot)
            if auraData and auraData.auraInstanceID then
                cache.buffsByID[auraData.auraInstanceID] = auraData
                ClassifyAura(cache, unit, auraData, "buff",
                    buffFilters, debuffFilters, defFilters, dispelFilter, db)
            end
        end
    end

    -- HARMFUL pass
    do
        local harmfulReturns = { GetAuraSlots(unit, "HARMFUL") }
        for i = 2, #harmfulReturns do
            local slot = harmfulReturns[i]
            local auraData = GetAuraDataBySlot(unit, slot)
            if auraData and auraData.auraInstanceID then
                cache.debuffsByID[auraData.auraInstanceID] = auraData
                ClassifyAura(cache, unit, auraData, "debuff",
                    buffFilters, debuffFilters, defFilters, dispelFilter, db)
            end
        end
    end

    -- Rebuild legacy sorted arrays so consumers that read cache.buffData /
    -- cache.buffOrder still work (the icon renderer at UpdateAuraIconsDirect
    -- is the primary reader). Uses module-level scratch tables — no allocation.
    RebuildLegacySortedArrays(cache, unit, db)

    cache.hasFullScan = true
end

-- Incremental delta — process updateInfo.addedAuras,
-- updatedAuraInstanceIDs, and removedAuraInstanceIDs.
local function ApplyAuraDelta(unit, updateInfo)
    if not unit or not updateInfo then return end
    if not IsRosterUnit(unit) then return end

    local cache = EnsureAuraCacheEntry(unit)

    -- If we've never done a full scan for this unit, the classification
    -- sets are empty — incremental updates alone would produce an
    -- incomplete cache. Bail out and let the caller run ScanUnitFull.
    if not cache.hasFullScan then return false end

    local buffFilters, debuffFilters, defFilters, dispelFilter, db = ResolveFiltersForUnit(unit)

    -- Added auras: Blizzard provides full auraData in the event payload.
    -- Zero API calls on our side for the data itself.
    --
    -- addedAuras is a FLAT list containing both helpful and harmful auras.
    -- We cannot use auraData.isHarmful to categorize because it is a
    -- secret value on Midnight (see oUF auras.lua:276 — "isHarmful is a
    -- secret, use a different name"). Instead, categorize via the
    -- secret-safe IsAuraFilteredOutByInstanceID with the base filters
    -- "HELPFUL" and "HARMFUL". If the aura matches HELPFUL (not filtered
    -- out), it's a buff; otherwise check HARMFUL.
    if updateInfo.addedAuras then
        for _, auraData in ipairs(updateInfo.addedAuras) do
            local id = auraData.auraInstanceID
            if id and IsAuraFilteredOut then
                if not IsAuraFilteredOut(unit, id, "HELPFUL") then
                    cache.buffsByID[id] = auraData
                    ClassifyAura(cache, unit, auraData, "buff",
                        buffFilters, debuffFilters, defFilters, dispelFilter, db)
                    cache.buffOrderDirty = true
                elseif not IsAuraFilteredOut(unit, id, "HARMFUL") then
                    cache.debuffsByID[id] = auraData
                    ClassifyAura(cache, unit, auraData, "debuff",
                        buffFilters, debuffFilters, defFilters, dispelFilter, db)
                    cache.debuffOrderDirty = true
                end
            end
        end
    end

    -- Updated auras: we only get the instance IDs, so fetch fresh data
    -- via GetAuraDataByAuraInstanceID. Typically 1-3 entries.
    if updateInfo.updatedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.updatedAuraInstanceIDs) do
            if cache.buffsByID[id] then
                local fresh = GetAuraDataByAuraInstanceID and GetAuraDataByAuraInstanceID(unit, id)
                if fresh then
                    cache.buffsByID[id] = fresh
                    -- Re-classify: filter matches may have changed
                    UnclassifyAura(cache, id)
                    ClassifyAura(cache, unit, fresh, "buff",
                        buffFilters, debuffFilters, defFilters, dispelFilter, db)
                    cache.buffOrderDirty = true
                end
            elseif cache.debuffsByID[id] then
                local fresh = GetAuraDataByAuraInstanceID and GetAuraDataByAuraInstanceID(unit, id)
                if fresh then
                    cache.debuffsByID[id] = fresh
                    UnclassifyAura(cache, id)
                    ClassifyAura(cache, unit, fresh, "debuff",
                        buffFilters, debuffFilters, defFilters, dispelFilter, db)
                    cache.debuffOrderDirty = true
                end
            end
        end
    end

    -- Removed auras: delete from cache and classification sets.
    if updateInfo.removedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
            if cache.buffsByID[id] then
                cache.buffsByID[id] = nil
                UnclassifyAura(cache, id)
                cache.buffOrderDirty = true
            elseif cache.debuffsByID[id] then
                cache.debuffsByID[id] = nil
                UnclassifyAura(cache, id)
                cache.debuffOrderDirty = true
            end
        end
    end

    -- Rebuild legacy sorted arrays if any delta touched them.
    -- Typical N is 5-20 per unit so the sort cost is negligible, and
    -- the rebuild only runs when at least one aura actually changed.
    if cache.buffOrderDirty or cache.debuffOrderDirty then
        RebuildLegacySortedArrays(cache, unit, db)
    end

    return true
end

-- Expose on DF so the dev slash command and tests can call them directly
DF.ScanUnitFull   = function(self, unit) ScanUnitFull(unit) end
DF.ApplyAuraDelta = function(self, unit, updateInfo) return ApplyAuraDelta(unit, updateInfo) end
DF.TriggerAuraUpdateForUnit = function(self, unit) TriggerAuraUpdateForUnit(unit) end

-- ============================================================
-- DEFENSIVE CACHE POPULATOR (mode-independent)
-- ============================================================
-- Rebuilds cache.defensives for a unit by scanning every helpful aura via
-- GetUnitAuras and running each through the secret-safe IsAuraFilteredOut
-- against BIG_DEFENSIVE / EXTERNAL_DEFENSIVE filters.
--
-- This is called from UpdateDefensiveBar (in Frames/Icons.lua) directly
-- so the defensive icon is fully decoupled from either capture path —
-- Blizzard's frame.buffs:Iterate doesn't have to succeed for defensive
-- icons to render. The icon renderer always reads fresh data, regardless
-- of whether the Blizzard or Direct capture ran (or failed) first.
function DF:PopulateDefensiveCache(unit)
    if not unit then return end
    -- Early-return on non-roster tokens (e.g. boss1targetpet from arena
    -- enemy frame hooks). GetUnitAuras hard-errors on these in 12.0.5.
    if not IsRosterUnit(unit) then return end

    -- Fix A commit 3: cache.defensives is now maintained incrementally
    -- by ScanUnitFull and ApplyAuraDelta via ClassifyAura's defensive-
    -- filter classification pass. If the cache has a fresh full scan,
    -- cache.defensives is already up to date and there is nothing to do.
    -- This is the common-case early-return for Direct mode — the path
    -- UpdateDefensiveBar takes on every render (~184 calls/sec in a
    -- 25-player raid). Old behavior: full GetUnitAuras scan every time,
    -- ~26 KB allocation per call. New behavior: one table lookup, zero
    -- allocation.
    local cache = DF.AuraCache[unit]
    if cache and cache.hasFullScan then
        return
    end

    -- --------------------------------------------------------------
    -- TODO (post-Blizzard-removal, ~2026-04-15): delete the rest of
    -- this function. The fallback path below is only reachable from:
    --   (a) Blizzard mode's CaptureAurasFromBlizzardFrame, which calls
    --       PopulateDefensiveCache to populate cache.defensives because
    --       the Blizzard frame.buffs container doesn't have defensive
    --       classification info.
    --   (b) Rare Direct-mode edge cases where UpdateDefensiveBar fires
    --       before the first UNIT_AURA event for a unit (initial load
    --       before ScanUnitFull has run). hasFullScan is false in this
    --       window and we need some way to populate the cache.
    --
    -- Once Blizzard mode is removed next week, case (a) goes away and
    -- case (b) can be handled by calling ScanUnitFull(unit) here
    -- instead of doing the legacy GetUnitAuras scan. For now, keep the
    -- legacy scan so Blizzard mode users still get defensive icons.
    -- --------------------------------------------------------------
    cache = EnsureAuraCacheEntry(unit)
    wipe(cache.defensives)

    local defFilters = BuildDirectDefensiveFilters()
    if not defFilters or not GetUnitAuras then return end
    local helpfulAuras = GetUnitAuras(unit, "HELPFUL", 40)
    if not helpfulAuras then return end
    for _, auraData in ipairs(helpfulAuras) do
        local id = auraData.auraInstanceID
        if id and AuraPassesAnyFilter(unit, id, defFilters) then
            cache.defensives[id] = true
        end
    end
end

-- Rebuild cached filter tables from current settings (per mode)
function DF:RebuildDirectFilterStrings()
    local partyDb = DF:GetDB("party")
    local raidDb = DF:GetDB("raid")
    if partyDb then
        cachedPartyBuffFilters = BuildDirectBuffFilters(partyDb)
        cachedPartyDebuffFilters = BuildDirectDebuffFilters(partyDb)
    end
    if raidDb then
        cachedRaidBuffFilters = BuildDirectBuffFilters(raidDb)
        cachedRaidDebuffFilters = BuildDirectDebuffFilters(raidDb)
    end
    -- Defensive and dispel are mode-independent, clear to rebuild on next use
    cachedDefensiveFilters = nil
    cachedDispelFilter = nil

    -- Fix A: classification sets are built against the OLD filters and
    -- are now stale. Mark every cache entry as needing a fresh full
    -- scan so the next UNIT_AURA event re-classifies everything from
    -- scratch. We use hasFullScan = false rather than wiping the cache
    -- so off-event readers (options page preview, etc.) still see data
    -- until the next event lands.
    for _, entry in pairs(DF.AuraCache) do
        entry.hasFullScan = false
    end
end

-- Scan a single unit with Direct API and populate DF.AuraCache.
--
-- COMMIT 2: ScanUnitDirect is now a thin delegation to ScanUnitFull.
-- The legacy body (which did its own GetUnitAuras scans + sorted +
-- classified + called PopulateDefensiveCache) has been replaced by
-- the new cache-based pipeline. ScanUnitFull is a strict superset —
-- it populates both the new (buffsByID, debuffsByID, hasFullScan)
-- and legacy (buffData, buffOrder via RebuildLegacySortedArrays)
-- cache fields in one pass.
--
-- This delegation keeps DirectScanAllUnits + DirectModeRosterUpdate
-- working unchanged — they call ScanUnitDirect in a roster loop and
-- now get ScanUnitFull behavior for free. Also means the initial
-- bulk scan sets hasFullScan = true, so the first UNIT_AURA event
-- per unit after login can take the cheap delta path instead of
-- falling back to a full rescan.
local function ScanUnitDirect(unit)
    -- Mode guard — ScanUnitFull doesn't check auraSourceMode itself
    -- because it's a lower-level primitive. Keep the check here so
    -- DirectScanAllUnits doesn't run ScanUnitFull when the user is
    -- still in Blizzard mode.
    if not unit then return end
    local frame = DF.unitFrameMap and DF.unitFrameMap[unit]
    local db
    if frame then
        db = frame.isRaidFrame and DF:GetRaidDB() or DF:GetDB()
    else
        db = DF:GetDB()
    end
    if not db or db.auraSourceMode ~= "DIRECT" then return end

    ScanUnitFull(unit)
end

-- ============================================================
-- DIRECT MODE EVENT HANDLING
-- ============================================================

-- Direct-mode UNIT_AURA subscriber. Routed through the roster dispatcher
-- (RosterEvents.lua) so we only see player/partyN/raidN events — never
-- nameplates, target, focus, mouseover, etc. The dispatcher uses
-- RegisterUnitEvent at the C++ level for filtering.
local directModeSubscriber = {}
local directModeActive = false

function directModeSubscriber:OnUnitAura(event, unit, updateInfo)
    if not unit then return end
    -- Only process units we care about (party/raid members with DF frames)
    if not DF.unitFrameMap or not DF.unitFrameMap[unit] then return end

    DF.AuraCacheStats.eventsSeen = DF.AuraCacheStats.eventsSeen + 1

    -- Fix A hot path: decide between a full scan and an incremental
    -- delta based on updateInfo. Full scans happen only on first-access,
    -- isFullUpdate, or if a delta fails (hasFullScan == false).
    -- Every other UNIT_AURA event flows through the cheap delta path.
    --
    -- See _Reference/fix-a-plan.md for the full architecture.
    local cache = DF.AuraCache[unit]
    local needsFull = not updateInfo
                      or updateInfo.isFullUpdate
                      or not cache
                      or not cache.hasFullScan

    if needsFull then
        DF.AuraCacheStats.scanFull = DF.AuraCacheStats.scanFull + 1
        ScanUnitFull(unit)
    else
        -- Try the incremental path. If it returns false (cache in
        -- a state where delta isn't safe), fall back to full scan.
        if ApplyAuraDelta(unit, updateInfo) then
            DF.AuraCacheStats.deltaApplied = DF.AuraCacheStats.deltaApplied + 1
        else
            DF.AuraCacheStats.deltaFallback = DF.AuraCacheStats.deltaFallback + 1
            ScanUnitFull(unit)
        end
    end

    TriggerAuraUpdateForUnit(unit)
end

function DF:EnableDirectAuraMode()
    if directModeActive then return end
    directModeActive = true

    DF:RegisterRosterUnitEvent(directModeSubscriber, "UNIT_AURA", "OnUnitAura")

    -- Rebuild filter strings from current settings
    DF:RebuildDirectFilterStrings()

    -- Do an initial full scan
    DF:DirectScanAllUnits()
end

function DF:DisableDirectAuraMode()
    if not directModeActive then return end
    directModeActive = false

    DF:UnregisterRosterUnitEvent(directModeSubscriber, "UNIT_AURA")
end

-- Full scan of all units currently in the frame map
function DF:DirectScanAllUnits()
    if not DF.unitFrameMap then return end
    for unit in pairs(DF.unitFrameMap) do
        ScanUnitDirect(unit)
        TriggerAuraUpdateForUnit(unit)
    end
end

-- Re-scan when roster changes (units may change)
function DF:DirectModeRosterUpdate()
    if not directModeActive then return end
    if not DF.unitFrameMap then return end

    -- The roster dispatcher handles add/remove of units automatically when
    -- GROUP_ROSTER_UPDATE fires, so no re-registration is needed here — just
    -- rescan to populate state for the new roster.
    DF:DirectScanAllUnits()
end

-- Switch between Blizzard and Direct modes
-- Always forces a full teardown + reinit so profile switches with
-- different data sources (or different filter settings) take effect.
function DF:SetAuraSourceMode(mode)
    -- Clear all caches so stale data doesn't persist
    wipe(DF.BlizzardAuraCache)

    -- Force-teardown current mode first so Enable/Disable don't early-return
    -- when the mode hasn't changed (filters or profile may still differ)
    if directModeActive then
        directModeActive = false
        DF:UnregisterRosterUnitEvent(directModeSubscriber, "UNIT_AURA")
    end

    if mode == "DIRECT" then
        DF:EnableDirectAuraMode()
    else
        -- Restore events on Blizzard frames that were fully stripped during Direct mode
        -- Without this, UNIT_AURA never fires and the Blizzard hook can't repopulate the cache
        if DF.RestoreStrippedFrameEvents then
            DF:RestoreStrippedFrameEvents()
        end
        -- Re-prime Blizzard cache
        ScanAllBlizzardFrames()
    end

    -- Update Blizzard frame visibility (fully disable in Direct mode, restore in Blizzard mode)
    C_Timer.After(0.1, function()
        if DF.UpdateBlizzardFrameVisibility then
            DF:UpdateBlizzardFrameVisibility()
        end
    end)
end

-- ============================================================
-- HOOK BLIZZARD'S COMPACT RAID FRAMES
-- ============================================================

local function SetupBlizzardHooks()
    -- Hook the main aura update function - capture and trigger our update
    if CompactUnitFrame_UpdateAuras then
        hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
            -- Skip frames in invalid states
            if not frame or frame.unitExists == false then return end
            CaptureAurasFromBlizzardFrame(frame, true)
        end)
        DF.BlizzardHookActive = true
    end
    
    -- Also hook UpdateBuffs and UpdateDebuffs if they exist separately
    if CompactUnitFrame_UpdateBuffs then
        hooksecurefunc("CompactUnitFrame_UpdateBuffs", function(frame)
            if not frame or frame.unitExists == false then return end
            CaptureAurasFromBlizzardFrame(frame, true)
        end)
    end
    
    if CompactUnitFrame_UpdateDebuffs then
        hooksecurefunc("CompactUnitFrame_UpdateDebuffs", function(frame)
            if not frame or frame.unitExists == false then return end
            CaptureAurasFromBlizzardFrame(frame, true)
        end)
    end
end

-- ============================================================
-- EVENT FRAME FOR PROACTIVE UPDATES
-- ============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

-- Apply our saved Blizzard frame settings via CVars only (not optionTable)
-- Modifying optionTable causes protected value errors in combat
local function ApplyBlizzardFrameSettings()
    if not DF.db or not DF.db.party then return end
    
    local db = DF.db.party
    
    local dispelIndicator = db._blizzDispelIndicator
    local onlyDispellable = db._blizzOnlyDispellable
    
    -- Force dispel indicator to be at least 1 (never disabled)
    if dispelIndicator == nil or dispelIndicator == 0 then
        dispelIndicator = 1
        db._blizzDispelIndicator = 1
    end
    
    -- Set via CVar only - do NOT modify optionTable
    SetCVar("raidFramesDispelIndicatorType", dispelIndicator)
    
    if onlyDispellable ~= nil then
        SetCVar("raidFramesDisplayOnlyDispellableDebuffs", onlyDispellable and 1 or 0)
    end
end

-- Export for use elsewhere
DF.ApplyBlizzardFrameSettings = ApplyBlizzardFrameSettings

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "GROUP_ROSTER_UPDATE" then
        if DF.RosterDebugEvent then DF:RosterDebugEvent("Auras.lua(blizz):GROUP_ROSTER_UPDATE") end
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
        -- Mark hooks as initializing (kept for potential future use)
        DF.blizzardHooksFullyActive = false

        -- Full scan after delays to let Blizzard frames initialize
        C_Timer.After(0.1, ScanAllBlizzardFrames)
        C_Timer.After(0.5, ScanAllBlizzardFrames)
        C_Timer.After(1.5, function()
            ScanAllBlizzardFrames()
            DF.blizzardHooksFullyActive = true
        end)

        -- Also apply our saved Blizzard settings
        C_Timer.After(0.2, ApplyBlizzardFrameSettings)
        C_Timer.After(1.0, ApplyBlizzardFrameSettings)

        -- Direct mode: re-register unit events for new roster
        local db = DF.db and DF.db.party
        local raidDb = DF.db and DF.db.raid
        local isDirectMode = (db and db.auraSourceMode == "DIRECT") or (raidDb and raidDb.auraSourceMode == "DIRECT")
        if isDirectMode then
            C_Timer.After(0.2, function() DF:DirectModeRosterUpdate() end)
        end
    end
end)

-- ============================================================
-- CHECK IF AURA SHOULD BE SHOWN (Using Blizzard's decisions)
-- ============================================================

local function IsAuraApprovedByBlizzard(unit, auraInstanceID, auraType)
    local cache = DF.BlizzardAuraCache[unit]
    if not cache then return false end  -- No cache = don't show aura (no fallback)
    
    if auraType == "BUFF" then
        return cache.buffs[auraInstanceID] == true
    else
        return cache.debuffs[auraInstanceID] == true
    end
end

-- Check if a debuff is dispellable by the current player
-- This uses Blizzard's dispelDebuffFrames which only show debuffs the player can dispel
-- Returns: true = player can dispel, false = player cannot dispel, nil = no cache data
local function IsPlayerDispellable(unit, auraInstanceID)
    local cache = DF.BlizzardAuraCache[unit]
    if not cache then return nil end
    
    return cache.playerDispellable[auraInstanceID] == true
end

-- Export for use in other modules (e.g., Features/Dispel.lua)
DF.IsPlayerDispellable = IsPlayerDispellable

-- Check if the current player has any buff applied to a unit
-- Blizzard's buffFrames on raid frames already only shows buffs YOU cast
-- DEPRECATED: My Buff Indicator feature is hidden from the UI and force-disabled.
-- This function is kept for potential future re-enablement.
--
-- So we just check if there's anything in the buffs cache
-- Out of combat: filter out raid buffs (like Mark of the Wild) by checking icon texture
-- In combat: can't read aura data, so trust the cache as-is
-- In encounter (M+/boss): aura data is protected even out of combat
--   - In combat: skip filtering, trust cache (same as normal combat)
--   - Out of combat: return false to hide indicators (can't filter, showing raid buff indicators would be misleading)
-- Returns: true = player has a (non-raid) buff on unit, false = no relevant buffs from player
local function UnitHasMyBuff(unit)
    local cache = DF.BlizzardAuraCache and DF.BlizzardAuraCache[unit]
    if not cache then return false end
    
    -- Quick check - if no buffs at all, return false
    if not next(cache.buffs) then return false end
    
    -- Encounter check (M+ keystones, boss fights) - aura data is protected
    local inEncounter = IsEncounterInProgress and IsEncounterInProgress()
    if inEncounter then
        if InCombatLockdown() then
            -- In encounter + in combat: can't filter, trust cache as-is
            return true
        else
            -- In encounter + out of combat: disable to avoid raid buff false positives
            return false
        end
    end
    
    -- In combat (non-encounter), aura data is secret - just check if any buff exists
    if InCombatLockdown() then
        return true
    end
    
    -- Out of combat, not in encounter - safe to filter out raid buffs by icon texture
    local raidBuffIcons = DF.GetRaidBuffIcons and DF:GetRaidBuffIcons()
    
    for auraInstanceID in pairs(cache.buffs) do
        -- Safety: skip secret auraInstanceIDs (shouldn't happen but belt-and-suspenders)
        if issecretvalue(auraInstanceID) then
            return true
        end
        
        local auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
        if auraData then
            local auraIconTexture = auraData.icon
            -- Check if it's a raid buff by icon texture
            local isRaidBuff = false
            if raidBuffIcons and auraIconTexture and not issecretvalue(auraIconTexture) then
                isRaidBuff = raidBuffIcons[auraIconTexture] == true
            end
            
            if not isRaidBuff then
                -- Found a non-raid buff (HoT, shield, etc.)
                return true
            end
        end
    end
    
    -- Only raid buffs found (or couldn't read data)
    return false
end

-- Export for use in other modules (e.g., Features/MyBuffIndicators.lua)
DF.UnitHasMyBuff = UnitHasMyBuff

-- ============================================================
-- AURA COLLECTION FUNCTIONS
-- ============================================================

-- Collect buffs using Blizzard's cached decisions
-- We ONLY check auraInstanceID against our cache - no reading aura properties
local function CollectBuffs_Blizzard(unit, maxAuras)
    ReleaseAndWipe(reusableBuffs)  -- Return entries to pool before reusing array
    local buffs = reusableBuffs
    local filter = "HELPFUL"
    local slot = 1
    local cache = DF.BlizzardAuraCache[unit]
    
    if not cache then return buffs end
    
    while #buffs < maxAuras and slot <= 40 do
        local auraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex(unit, slot, filter)
        if not auraData then break end
        
        -- Get auraInstanceID - this is safe, it's just an integer
        local auraInstanceID = auraData.auraInstanceID
        
        -- Check if Blizzard approved this aura
        if auraInstanceID and cache.buffs[auraInstanceID] then
            local entry = AcquireTable()
            entry.slot = slot
            entry.data = auraData
            buffs[#buffs + 1] = entry
        end
        
        slot = slot + 1
    end
    
    return buffs
end

-- Collect debuffs using Blizzard's cached decisions
local function CollectDebuffs_Blizzard(unit, maxAuras)
    ReleaseAndWipe(reusableDebuffs)  -- Return entries to pool before reusing array
    local debuffs = reusableDebuffs
    local filter = "HARMFUL"
    local slot = 1
    local cache = DF.BlizzardAuraCache[unit]
    
    if not cache then return debuffs end
    
    while #debuffs < maxAuras and slot <= 40 do
        local auraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex(unit, slot, filter)
        if not auraData then break end
        
        local auraInstanceID = auraData.auraInstanceID
        
        if auraInstanceID and cache.debuffs[auraInstanceID] then
            local entry = AcquireTable()
            entry.slot = slot
            entry.data = auraData
            debuffs[#debuffs + 1] = entry
        end
        
        slot = slot + 1
    end
    
    return debuffs
end

-- ============================================================
-- MAIN COLLECTION API
-- ============================================================

-- Collect buffs using Blizzard's cached decisions only
-- Returns empty array if Blizzard cache not available (NO FALLBACK)
function DF:CollectBuffs(unit, maxAuras)
    local cache = DF.BlizzardAuraCache[unit]
    if not cache then
        -- CRITICAL: Must wipe before returning to avoid stale data
        ReleaseAndWipe(reusableBuffs)
        return reusableBuffs
    end
    return CollectBuffs_Blizzard(unit, maxAuras)
end

-- Collect debuffs using Blizzard's cached decisions only
-- Returns empty array if Blizzard cache not available (NO FALLBACK)
function DF:CollectDebuffs(unit, maxAuras)
    local cache = DF.BlizzardAuraCache[unit]
    if not cache then
        -- CRITICAL: Must wipe before returning to avoid stale data
        ReleaseAndWipe(reusableDebuffs)
        return reusableDebuffs
    end
    return CollectDebuffs_Blizzard(unit, maxAuras)
end

-- ============================================================
-- ENHANCED AURA ICON UPDATE
-- ============================================================

function DF:UpdateAuraIcons_Enhanced(frame, icons, auraType, maxAuras)
    local unit = frame.unit
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    local auras
    if auraType == "BUFF" then
        auras = DF:CollectBuffs(unit, maxAuras)
    else
        auras = DF:CollectDebuffs(unit, maxAuras)
    end
    
    -- Get raid buff icons for filtering (only for buffs, out of combat, not in encounter, when option enabled)
    local raidBuffIcons = nil
    local inEncounter = IsEncounterInProgress and IsEncounterInProgress()
    local shouldFilterRaidBuffs = auraType == "BUFF" and db.missingBuffHideFromBar and not InCombatLockdown() and not inEncounter
    if shouldFilterRaidBuffs then
        raidBuffIcons = DF:GetRaidBuffIcons()
    end

    -- Defensive/AD deduplication: skip buffs already shown in defensive bar or Aura Designer
    local dedupSet = nil
    local cache = DF.BlizzardAuraCache[unit]
    if auraType == "BUFF" and db.buffDeduplicateDefensives then
        if db.defensiveIconEnabled and cache and cache.defensives and next(cache.defensives) then
            dedupSet = cache.defensives
        end
        local adIDs = frame.dfAD_activeInstanceIDs
        if adIDs and next(adIDs) then
            if dedupSet then
                if not frame.dfDedup then frame.dfDedup = {} end
                wipe(frame.dfDedup)
                for id in pairs(dedupSet) do frame.dfDedup[id] = true end
                for id in pairs(adIDs) do frame.dfDedup[id] = true end
                dedupSet = frame.dfDedup
            else
                dedupSet = adIDs
            end
        end
    end

    local displayedCount = 0
    for i, auraInfo in ipairs(auras) do
        if displayedCount >= maxAuras then break end

        -- Dedup: skip buffs already shown in defensive bar or Aura Designer
        local auraInstanceID = auraInfo.data and auraInfo.data.auraInstanceID
        if dedupSet and auraInstanceID and dedupSet[auraInstanceID] then
            -- skip this aura entirely
        else

        local icon = icons[displayedCount + 1]
        if not icon then break end

        local auraData = auraInfo.data
        local canDisplay = false
        local skipAura = false

        -- Check aura blacklist (spell ID based, works even with secret icons)
        if auraData and auraData.spellId and not issecretvalue(auraData.spellId) then
            local blTable = DF.db and DF.db.auraBlacklist
            if blTable then
                local blSet = auraType == "BUFF" and blTable.buffs or blTable.debuffs
                if DF.AuraBlacklist and DF.AuraBlacklist.IsBlacklisted(blSet, auraData.spellId) then
                    skipAura = true
                end
            end
        end

        -- Set icon texture
        local auraIconTexture = auraData.icon
        if not skipAura and auraIconTexture then
            canDisplay = SafeSetTexture(icon, auraIconTexture)
        end

        -- Check if this is a raid buff we should skip
        -- Note: auraIconTexture may be a secret value - can't use secrets as table keys
        if canDisplay and not skipAura and shouldFilterRaidBuffs and raidBuffIcons and auraIconTexture then
            -- Only do lookup if not a secret value
            if not issecretvalue(auraIconTexture) and raidBuffIcons[auraIconTexture] then
                skipAura = true
            end
        end

        if canDisplay and not skipAura then
            displayedCount = displayedCount + 1
            
            -- PERFORMANCE FIX: Reuse auraData table instead of creating new one every update
            if not icon.auraData then
                icon.auraData = { index = 0, auraInstanceID = nil }
            end
            icon.auraData.index = auraInfo.slot
            icon.auraData.auraInstanceID = nil  -- Reset before setting
            
            local auraInstanceID = auraData.auraInstanceID
            icon.auraData.auraInstanceID = auraInstanceID

            -- Compute hasExpiration BEFORE SafeSetCooldown so we can pre-hide native text
            -- This prevents flickering when a timed aura's icon slot gets reassigned to a permanent aura
            icon.expirationTime = nil
            icon.auraDuration = nil
            icon.hasExpiration = false

            if auraInstanceID and C_UnitAuras and C_UnitAuras.DoesAuraHaveExpirationTime then
                icon.hasExpiration = C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID)
                icon.expirationTime = auraData.expirationTime
                icon.auraDuration = auraData.duration
            else
                if auraData.expirationTime and auraData.expirationTime > 0 then
                    icon.expirationTime = auraData.expirationTime
                    icon.hasExpiration = true
                end
                if auraData.duration and auraData.duration > 0 then
                    icon.auraDuration = auraData.duration
                end
            end

            -- Set cooldown
            SafeSetCooldown(icon.cooldown, auraData, unit)

            -- Set stack count using new API if available
            icon.count:SetText("")
            local stackMinimum = icon.stackMinimum or 2

            if auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
                -- Use new API - pass min and max display count
                -- API returns empty string if below min, "*" if above max, otherwise the count
                local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, stackMinimum, 99)
                if stackText then
                    -- SetText can handle the secret value directly
                    icon.count:SetText(stackText)
                end
            end
            
            -- Show/hide cooldown (swipe + native countdown text) based on whether aura expires
            -- Hiding the cooldown frame also hides the native countdown text (as its child)
            -- This is the primary mechanism for hiding duration text on permanent buffs
            if icon.cooldown then
                if icon.cooldown.SetShownFromBoolean then
                    icon.cooldown:SetShownFromBoolean(icon.hasExpiration, true, false)
                else
                    icon.cooldown:Show()
                end
            end

            -- Our custom duration FontString (separate from native text) — show/hide based on hasExpiration
            if icon.duration then
                if icon.showDuration then
                    if icon.duration.SetShownFromBoolean then
                        icon.duration:SetShownFromBoolean(icon.hasExpiration, true, false)
                    else
                        icon.duration:Show()
                    end
                else
                    icon.duration:Hide()
                end
            end

            -- Note: Expiring indicators are managed by the icon's OnUpdate script
            -- We don't hide/reset them here to avoid flickering when auras refresh
            
            -- Check if Masque is actually controlling borders (enabled in settings AND Masque group is active)
            local masqueGroup = auraType == "BUFF" and DF.MasqueGroup_Buffs or DF.MasqueGroup_Debuffs
            local masqueActive = masqueGroup and masqueGroup.IsDisabled and not masqueGroup:IsDisabled()
            local masqueBorderControl = db.masqueBorderControl and DF.Masque and masqueActive
            
            -- Check if unit is dead/offline - use neutral border color to prevent
            -- colored border showing through faded icon texture
            local unitDeadOrOffline = UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)
            
            -- Set border color (normal border, not expiring) - only if we control borders
            local borderEnabled = (auraType == "DEBUFF" and db.debuffBorderEnabled ~= false) or (auraType ~= "DEBUFF" and db.buffBorderEnabled ~= false)
            if borderEnabled and not masqueBorderControl then
                if auraType == "DEBUFF" and not unitDeadOrOffline then
                    -- Use custom dispel type colors if enabled, via color curve API
                    -- Only for living units - dead units can't be dispelled so colored border is meaningless
                    if db.debuffBorderColorByType ~= false and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor and C_CurveUtil and C_CurveUtil.CreateColorCurve then
                        -- Build or get cached debuff border color curve
                        DF.debuffBorderCurve = DF.debuffBorderCurve or nil
                        if not DF.debuffBorderCurve then
                            local curve = C_CurveUtil.CreateColorCurve()
                            curve:SetType(Enum.LuaCurveType.Step)
                            
                            -- Dispel type enum values from wago.tools/db2/SpellDispelType
                            -- None = 0, Magic = 1, Curse = 2, Disease = 3, Poison = 4, Enrage = 9, Bleed = 11
                            local noneColor = db.debuffBorderColorNone or {r = 0.8, g = 0.0, b = 0.0}
                            local magicColor = db.debuffBorderColorMagic or {r = 0.2, g = 0.6, b = 1.0}
                            local curseColor = db.debuffBorderColorCurse or {r = 0.6, g = 0.0, b = 1.0}
                            local diseaseColor = db.debuffBorderColorDisease or {r = 0.6, g = 0.4, b = 0.0}
                            local poisonColor = db.debuffBorderColorPoison or {r = 0.0, g = 0.6, b = 0.0}
                            local bleedColor = db.debuffBorderColorBleed or {r = 1.0, g = 0.0, b = 0.0}
                            
                            curve:AddPoint(0, CreateColor(noneColor.r, noneColor.g, noneColor.b, 1.0))   -- None
                            curve:AddPoint(1, CreateColor(magicColor.r, magicColor.g, magicColor.b, 1.0))   -- Magic
                            curve:AddPoint(2, CreateColor(curseColor.r, curseColor.g, curseColor.b, 1.0))   -- Curse
                            curve:AddPoint(3, CreateColor(diseaseColor.r, diseaseColor.g, diseaseColor.b, 1.0)) -- Disease
                            curve:AddPoint(4, CreateColor(poisonColor.r, poisonColor.g, poisonColor.b, 1.0))   -- Poison
                            curve:AddPoint(9, CreateColor(bleedColor.r, bleedColor.g, bleedColor.b, 1.0))   -- Enrage
                            curve:AddPoint(11, CreateColor(bleedColor.r, bleedColor.g, bleedColor.b, 1.0))  -- Bleed
                            
                            DF.debuffBorderCurve = curve
                        end
                        
                        -- Get color from API
                        local borderColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, DF.debuffBorderCurve)
                        if borderColor then
                            local r, g, b = 0.8, 0, 0
                            if borderColor.GetRGBA then
                                r, g, b = borderColor:GetRGB()
                            elseif borderColor.r then
                                r, g, b = borderColor.r, borderColor.g, borderColor.b
                            end
                            icon.border:SetColorTexture(r, g, b, 1.0)
                        else
                            -- Fallback to none color
                            local c = db.debuffBorderColorNone or {r = 0.8, g = 0, b = 0}
                            icon.border:SetColorTexture(c.r, c.g, c.b, 1.0)
                        end
                    else
                        -- Color by type disabled or API not available - use default red
                        icon.border:SetColorTexture(0.8, 0, 0, 1.0)
                    end
                else
                    icon.border:SetColorTexture(0, 0, 0, 1.0)  -- Black for buffs and dead/offline debuffs
                end
                icon.border:SetAlpha(0.8)
                icon.border:Show()
            elseif not masqueBorderControl then
                icon.border:Hide()
            end
            -- When masqueBorderControl is true, border visibility is handled by ApplyAuraLayout
            
            -- Find native cooldown text if not already cached (for duration text)
            if not icon.nativeCooldownText and icon.cooldown then
                local regions = {icon.cooldown:GetRegions()}
                for _, region in ipairs(regions) do
                    if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                        icon.nativeCooldownText = region

                        -- IMMEDIATELY apply font settings to prevent large default font flash
                        -- This fixes the "big numbers" issue on first buff application
                        local prefix = auraType == "BUFF" and "buff" or "debuff"
                        local durationScale = db[prefix .. "DurationScale"] or 1.0
                        local durationFont = db[prefix .. "DurationFont"] or "Fonts\\FRIZQT__.TTF"
                        local durationOutline = db[prefix .. "DurationOutline"] or "OUTLINE"
                        if durationOutline == "NONE" then durationOutline = "" end
                        local durationSize = 10 * durationScale
                        local durationX = db[prefix .. "DurationX"] or 0
                        local durationY = db[prefix .. "DurationY"] or 0
                        local durationAnchor = db[prefix .. "DurationAnchor"] or "CENTER"

                        if DF.SafeSetFont then
                            DF:SafeSetFont(region, durationFont, durationSize, durationOutline)
                        end

                        -- Create wrapper frame for parent-level alpha control (hide duration above threshold).
                        -- Blizzard's CooldownFrame resets both SetTextColor alpha and SetAlpha on its
                        -- FontString every frame, so the only reliable hide is via a parent frame's alpha.
                        if not icon.durationHideWrapper then
                            icon.durationHideWrapper = CreateFrame("Frame", nil, icon.cooldown)
                            icon.durationHideWrapper:SetAllPoints(icon)
                            icon.durationHideWrapper:SetFrameLevel(icon.cooldown:GetFrameLevel() + 2)
                            icon.durationHideWrapper:EnableMouse(false)
                        end
                        region:SetParent(icon.durationHideWrapper)

                        -- Position it where the user configured
                        region:ClearAllPoints()
                        region:SetPoint(durationAnchor, icon, durationAnchor, durationX, durationY)

                        -- Tell Blizzard's cooldown to show/hide countdown numbers based on user setting
                        -- This prevents Blizzard's C code from overriding our visibility control
                        if icon.cooldown.SetHideCountdownNumbers then
                            icon.cooldown:SetHideCountdownNumbers(not icon.showDuration)
                        end

                        break
                    end
                end
            end
            
            icon:Show()
            
            -- Register for shared timer updates
            DF:RegisterIconForAuraTimer(icon)
        end
        end -- dedup else
    end

    -- Hide remaining icons
    for i = displayedCount + 1, #icons do
        local icon = icons[i]
        icon.auraData = nil
        icon.testAuraData = nil  -- Clear test mode flag too
        icon.expirationTime = nil
        icon.auraDuration = nil
        if icon.duration then icon.duration:Hide() end
        if icon.expiringTint then icon.expiringTint:Hide() end
        if icon.expiringBorderAlphaContainer then
            icon.expiringBorderAlphaContainer:Hide()
            if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                icon.expiringBorderPulse:Stop()
            end
        end
        icon:Hide()
    end
    
    -- Store displayed count for center growth repositioning
    local countKey = auraType == "BUFF" and "buffDisplayedCount" or "debuffDisplayedCount"
    frame[countKey] = displayedCount
    
    -- Reposition icons if using center growth (now that we know the count)
    local db = DF:GetFrameDB(frame)
    local prefix = auraType == "BUFF" and "buff" or "debuff"
    local growth = db[prefix .. "Growth"] or (auraType == "BUFF" and "LEFT_UP" or "RIGHT_UP")
    local primary = strsplit("_", growth)
    
    if primary == "CENTER" and displayedCount > 0 then
        DF:RepositionCenterGrowthIcons(frame, icons, auraType, displayedCount)
    end
end

-- ============================================================
-- DIRECT AURA UPDATE (Merged Tier 1+2+3 optimization)
--
-- Merges collection and display into a single pass:
--   - Iterates approved auraInstanceIDs from BlizzardAuraCache directly (Tier 2 flip)
--   - Calls GetAuraDataByAuraInstanceID per ID instead of scanning slots 1-40 (Tier 2)
--   - Applies data directly to icon frames with no intermediate tables (Tier 3)
--   - All API lookups cached as file-scope locals (Tier 1)
--
-- Typical cost: O(approved_auras) ≈ 3-4 API calls per aura type
-- Old cost:     O(total_unit_auras) ≈ 30+ API calls per aura type
-- ============================================================

function DF:UpdateAuraIconsDirect(frame, icons, auraType, maxAuras)
    local unit = frame.unit
    local db = DF:GetFrameDB(frame)
    
    -- Quick out: no cache = no approved auras = hide everything
    local cache = DF.BlizzardAuraCache[unit]
    local cacheSet = cache and (auraType == "BUFF" and cache.buffs or cache.debuffs)
    if not cacheSet then
        for i = 1, #icons do
            local icon = icons[i]
            icon.auraData = nil
            icon.testAuraData = nil
            icon.expirationTime = nil
            icon.auraDuration = nil
            if icon.duration then icon.duration:Hide() end
            if icon.expiringTint then icon.expiringTint:Hide() end
            if icon.expiringBorderAlphaContainer then
                icon.expiringBorderAlphaContainer:Hide()
                if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                    icon.expiringBorderPulse:Stop()
                end
            end
            icon:Hide()
        end
        local countKey = auraType == "BUFF" and "buffDisplayedCount" or "debuffDisplayedCount"
        frame[countKey] = 0
        return
    end
    
    -- Raid buff filtering (buffs only, out of combat, not in encounter, when option enabled)
    local raidBuffIcons = nil
    local inEncounter = IsEncounterInProgress and IsEncounterInProgress()
    local shouldFilterRaidBuffs = auraType == "BUFF" and db.missingBuffHideFromBar and not InCombatLockdown() and not inEncounter
    if shouldFilterRaidBuffs then
        raidBuffIcons = DF:GetRaidBuffIcons()
    end

    -- Defensive/AD deduplication: skip buffs already shown in defensive bar or Aura Designer
    local dedupSet = nil
    if auraType == "BUFF" and db.buffDeduplicateDefensives then
        -- Defensive bar auraInstanceIDs (only dedup if bar is actually enabled)
        if db.defensiveIconEnabled and cache and cache.defensives and next(cache.defensives) then
            dedupSet = cache.defensives
        end
        -- Aura Designer active auraInstanceIDs
        local adIDs = frame.dfAD_activeInstanceIDs
        if adIDs and next(adIDs) then
            if dedupSet then
                -- Merge: build a combined set (defensive + AD)
                if not frame.dfDedup then frame.dfDedup = {} end
                wipe(frame.dfDedup)
                for id in pairs(dedupSet) do frame.dfDedup[id] = true end
                for id in pairs(adIDs) do frame.dfDedup[id] = true end
                dedupSet = frame.dfDedup
            else
                dedupSet = adIDs
            end
        end
    end

    -- Pre-fetch: Masque state (once per call, not per icon)
    local masqueGroup = auraType == "BUFF" and DF.MasqueGroup_Buffs or DF.MasqueGroup_Debuffs
    local masqueActive = masqueGroup and masqueGroup.IsDisabled and not masqueGroup:IsDisabled()
    local masqueBorderControl = db.masqueBorderControl and DF.Masque and masqueActive

    -- Pre-fetch: border enabled (once per call)
    local borderEnabled = (auraType == "DEBUFF" and db.debuffBorderEnabled ~= false) or (auraType ~= "DEBUFF" and db.buffBorderEnabled ~= false)

    -- Pre-fetch: dead/offline state (once per call, not per icon)
    local unitDeadOrOffline = UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)

    -- Pre-fetch: duration font settings for nativeCooldownText first-time setup
    local prefix = auraType == "BUFF" and "buff" or "debuff"
    local durationScale = db[prefix .. "DurationScale"] or 1.0
    local durationFont = db[prefix .. "DurationFont"] or "Fonts\\FRIZQT__.TTF"
    local durationOutline = db[prefix .. "DurationOutline"] or "OUTLINE"
    if durationOutline == "NONE" then durationOutline = "" end
    local durationSize = 10 * durationScale
    local durationX = db[prefix .. "DurationX"] or 0
    local durationY = db[prefix .. "DurationY"] or 0
    local durationAnchor = db[prefix .. "DurationAnchor"] or "CENTER"
    
    -- Iterate aura data in display order
    -- Direct mode: uses pre-fetched full AuraData (no fallbacks — API returns nothing, we show nothing)
    -- Blizzard mode: uses ID list and re-fetches per aura
    local displayedCount = 0
    local isDirect = db.auraSourceMode == "DIRECT"
    local dataList = cache and (auraType == "BUFF" and cache.buffData or cache.debuffData)
    local useDataList = dataList and #dataList > 0
    -- Blizzard mode only: fall back to ID-based iteration when no pre-fetched data
    local orderList = (not isDirect and not useDataList) and cache and (auraType == "BUFF" and cache.buffOrder or cache.debuffOrder) or nil
    local iterList = useDataList and dataList or orderList

    if iterList then
        for i = 1, #iterList do
            if displayedCount >= maxAuras then break end

            -- Resolve auraData: Direct mode has it pre-fetched, Blizzard mode re-fetches by ID
            local auraData, auraInstanceID
            if useDataList then
                auraData = iterList[i]
                auraInstanceID = auraData and auraData.auraInstanceID
            else
                auraInstanceID = iterList[i]
                auraData = auraInstanceID and GetAuraDataByAuraInstanceID and GetAuraDataByAuraInstanceID(unit, auraInstanceID)
            end

            if not auraInstanceID then break end

            -- Self-clean stale cache entries. Direct mode trusts cache.buffData
            -- without a live recheck, so a missed UNIT_AURA "removed" event
            -- (e.g. during an OOR window where the API stops sending updates)
            -- can leave an icon stuck on the bar until /reload. Mirrors the
            -- defensive bar's pattern at Frames/Icons.lua.
            if useDataList and auraData and GetAuraDataByAuraInstanceID then
                local live = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                if not live then
                    if auraType == "BUFF" then
                        cache.buffsByID[auraInstanceID] = nil
                        cache.buffOrderDirty = true
                    else
                        cache.debuffsByID[auraInstanceID] = nil
                        cache.debuffOrderDirty = true
                    end
                    UnclassifyAura(cache, auraInstanceID)
                    auraData = nil
                end
            end

            if not auraData then
                -- Blizzard mode: aura may have expired between scan and display, skip it.
                -- Also reaches here when the self-clean above evicted a stale entry.
            else

            -- Dedup: skip buffs already shown in defensive bar or Aura Designer
            if dedupSet and dedupSet[auraInstanceID] then
                -- skip this aura entirely
            else

            if auraData then
                -- Guard: ensure we have an icon slot available
                local nextIcon = icons[displayedCount + 1]
                if not nextIcon then break end

                -- Check aura blacklist (spell ID based, works even with secret icons)
                local skipAura = false
                if auraData.spellId and not issecretvalue(auraData.spellId) then
                    local blTable = DF.db and DF.db.auraBlacklist
                    if blTable then
                        local blSet = auraType == "BUFF" and blTable.buffs or blTable.debuffs
                        if DF.AuraBlacklist and DF.AuraBlacklist.IsBlacklisted(blSet, auraData.spellId) then
                            skipAura = true
                        end
                    end
                end

                -- Set texture (validates the aura is displayable)
                local auraIconTexture = auraData.icon
                local canDisplay = false
                if not skipAura and auraIconTexture then
                    canDisplay = SafeSetTexture(nextIcon, auraIconTexture)
                end

                -- Check raid buff filtering
                if canDisplay and not skipAura and shouldFilterRaidBuffs and raidBuffIcons and auraIconTexture then
                    if not issecretvalue(auraIconTexture) and raidBuffIcons[auraIconTexture] then
                        skipAura = true
                    end
                end

                if canDisplay and not skipAura then
                    displayedCount = displayedCount + 1
                    local icon = icons[displayedCount]
                    -- Note: texture already set by SafeSetTexture above

                    -- Store aura tracking data (reuse existing table)
                    if not icon.auraData then
                        icon.auraData = { index = 0, auraInstanceID = nil }
                    end
                    icon.auraData.index = i
                    icon.auraData.auraInstanceID = auraInstanceID

                    -- Compute hasExpiration BEFORE SafeSetCooldown so we can pre-hide native text
                    -- This prevents flickering when a timed aura's icon slot gets reassigned to a permanent aura
                    icon.expirationTime = nil
                    icon.auraDuration = nil
                    icon.hasExpiration = false

                    if C_UnitAuras.DoesAuraHaveExpirationTime then
                        icon.hasExpiration = C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID)
                        icon.expirationTime = auraData.expirationTime
                        icon.auraDuration = auraData.duration
                    else
                        if auraData.expirationTime and auraData.expirationTime > 0 then
                            icon.expirationTime = auraData.expirationTime
                            icon.hasExpiration = true
                        end
                        if auraData.duration and auraData.duration > 0 then
                            icon.auraDuration = auraData.duration
                        end
                    end

                    -- Set cooldown
                    SafeSetCooldown(icon.cooldown, auraData, unit)

                    -- Stack count
                    icon.count:SetText("")
                    local stackMinimum = icon.stackMinimum or 2
                    if C_UnitAuras.GetAuraApplicationDisplayCount then
                        local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, stackMinimum, 99)
                        if stackText then
                            icon.count:SetText(stackText)
                        end
                    end

                    -- Show/hide cooldown (swipe + native countdown text) based on whether aura expires
                    -- Hiding the cooldown frame also hides the native countdown text (as its child)
                    if icon.cooldown then
                        if icon.cooldown.SetShownFromBoolean then
                            icon.cooldown:SetShownFromBoolean(icon.hasExpiration, true, false)
                        else
                            icon.cooldown:Show()
                        end
                    end

                    -- Our custom duration FontString — show/hide based on hasExpiration
                    if icon.duration then
                        if icon.showDuration then
                            if icon.duration.SetShownFromBoolean then
                                icon.duration:SetShownFromBoolean(icon.hasExpiration, true, false)
                            else
                                icon.duration:Show()
                            end
                        else
                            icon.duration:Hide()
                        end
                    end

                    -- Border color (normal, not expiring)
                    if borderEnabled and not masqueBorderControl then
                        if auraType == "DEBUFF" and not unitDeadOrOffline then
                            if db.debuffBorderColorByType ~= false and C_UnitAuras.GetAuraDispelTypeColor and C_CurveUtil and C_CurveUtil.CreateColorCurve then
                                if not DF.debuffBorderCurve then
                                    local curve = C_CurveUtil.CreateColorCurve()
                                    curve:SetType(Enum.LuaCurveType.Step)

                                    local noneColor = db.debuffBorderColorNone or {r = 0.8, g = 0.0, b = 0.0}
                                    local magicColor = db.debuffBorderColorMagic or {r = 0.2, g = 0.6, b = 1.0}
                                    local curseColor = db.debuffBorderColorCurse or {r = 0.6, g = 0.0, b = 1.0}
                                    local diseaseColor = db.debuffBorderColorDisease or {r = 0.6, g = 0.4, b = 0.0}
                                    local poisonColor = db.debuffBorderColorPoison or {r = 0.0, g = 0.6, b = 0.0}
                                    local bleedColor = db.debuffBorderColorBleed or {r = 1.0, g = 0.0, b = 0.0}

                                    curve:AddPoint(0, CreateColor(noneColor.r, noneColor.g, noneColor.b, 1.0))
                                    curve:AddPoint(1, CreateColor(magicColor.r, magicColor.g, magicColor.b, 1.0))
                                    curve:AddPoint(2, CreateColor(curseColor.r, curseColor.g, curseColor.b, 1.0))
                                    curve:AddPoint(3, CreateColor(diseaseColor.r, diseaseColor.g, diseaseColor.b, 1.0))
                                    curve:AddPoint(4, CreateColor(poisonColor.r, poisonColor.g, poisonColor.b, 1.0))
                                    curve:AddPoint(9, CreateColor(bleedColor.r, bleedColor.g, bleedColor.b, 1.0))
                                    curve:AddPoint(11, CreateColor(bleedColor.r, bleedColor.g, bleedColor.b, 1.0))

                                    DF.debuffBorderCurve = curve
                                end

                                local borderColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, DF.debuffBorderCurve)
                                if borderColor then
                                    local r, g, b = 0.8, 0, 0
                                    if borderColor.GetRGBA then
                                        r, g, b = borderColor:GetRGB()
                                    elseif borderColor.r then
                                        r, g, b = borderColor.r, borderColor.g, borderColor.b
                                    end
                                    icon.border:SetColorTexture(r, g, b, 1.0)
                                else
                                    local c = db.debuffBorderColorNone or {r = 0.8, g = 0, b = 0}
                                    icon.border:SetColorTexture(c.r, c.g, c.b, 1.0)
                                end
                            else
                                icon.border:SetColorTexture(0.8, 0, 0, 1.0)
                            end
                        else
                            icon.border:SetColorTexture(0, 0, 0, 1.0)
                        end
                        icon.border:SetAlpha(0.8)
                        icon.border:Show()
                    elseif not masqueBorderControl then
                        icon.border:Hide()
                    end

                    -- Find native cooldown text (first time only, cached on icon)
                    if not icon.nativeCooldownText and icon.cooldown then
                        local regions = {icon.cooldown:GetRegions()}
                        for _, region in ipairs(regions) do
                            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                                icon.nativeCooldownText = region

                                -- Immediately apply font settings to prevent large default font flash
                                if DF.SafeSetFont then
                                    DF:SafeSetFont(region, durationFont, durationSize, durationOutline)
                                end

                                -- Create wrapper frame for parent-level alpha control (hide duration above threshold)
                                if not icon.durationHideWrapper then
                                    icon.durationHideWrapper = CreateFrame("Frame", nil, icon.cooldown)
                                    icon.durationHideWrapper:SetAllPoints(icon)
                                    icon.durationHideWrapper:SetFrameLevel(icon.cooldown:GetFrameLevel() + 2)
                                    icon.durationHideWrapper:EnableMouse(false)
                                end
                                region:SetParent(icon.durationHideWrapper)

                                region:ClearAllPoints()
                                region:SetPoint(durationAnchor, icon, durationAnchor, durationX, durationY)

                                -- Tell Blizzard's cooldown to show/hide countdown numbers based on user setting
                                if icon.cooldown.SetHideCountdownNumbers then
                                    icon.cooldown:SetHideCountdownNumbers(not icon.showDuration)
                                end

                                break
                            end
                        end
                    end

                    icon:Show()

                    -- Register for shared timer updates
                    DF:RegisterIconForAuraTimer(icon)
                end
            end
            end -- dedup else
            end -- auraData nil guard
        end
    end

    -- Legacy: slot-ordered iteration (walks aura slots 1-40, which is application order, not Blizzard's display order)
    -- Kept for reference in case we want a slot-based option in the future
    --[[
    local auraFilter = auraType == "BUFF" and "HELPFUL" or "HARMFUL"
    local slot = 1
    while displayedCount < maxAuras and slot <= 40 do
        local auraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex(unit, slot, auraFilter)
        if not auraData then break end
        local auraInstanceID = auraData.auraInstanceID
        if auraInstanceID and cacheSet[auraInstanceID] then
            -- ... display logic ...
        end
        slot = slot + 1
    end
    --]]
    
    -- Hide remaining icons
    for i = displayedCount + 1, #icons do
        local icon = icons[i]
        icon.auraData = nil
        icon.testAuraData = nil
        icon.expirationTime = nil
        icon.auraDuration = nil
        if icon.duration then icon.duration:Hide() end
        if icon.expiringTint then icon.expiringTint:Hide() end
        if icon.expiringBorderAlphaContainer then
            icon.expiringBorderAlphaContainer:Hide()
            if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                icon.expiringBorderPulse:Stop()
            end
        end
        icon:Hide()
    end
    
    -- Store displayed count for center growth repositioning
    local countKey = auraType == "BUFF" and "buffDisplayedCount" or "debuffDisplayedCount"
    frame[countKey] = displayedCount
    
    -- Reposition icons if using center growth
    local growth = db[prefix .. "Growth"] or (auraType == "BUFF" and "LEFT_UP" or "RIGHT_UP")
    local primary = strsplit("_", growth)
    
    if primary == "CENTER" and displayedCount > 0 then
        DF:RepositionCenterGrowthIcons(frame, icons, auraType, displayedCount)
    end
end

-- ============================================================
-- CENTER GROWTH REPOSITIONING
-- ============================================================

-- Reposition icons for center growth after we know the actual visible count
-- This calculates total width/height and offsets icons so they're centered as a group
function DF:RepositionCenterGrowthIcons(frame, icons, auraType, visibleCount)
    if not frame or not icons or visibleCount <= 0 then return end
    
    local db = DF:GetFrameDB(frame)
    local prefix = auraType == "BUFF" and "buff" or "debuff"
    
    local size = db[prefix .. "Size"] or 18
    local scale = db[prefix .. "Scale"] or 1.0
    local anchor = db[prefix .. "Anchor"] or (auraType == "BUFF" and "BOTTOMRIGHT" or "BOTTOMLEFT")
    local growth = db[prefix .. "Growth"] or (auraType == "BUFF" and "LEFT_UP" or "RIGHT_UP")
    local wrap = db[prefix .. "Wrap"] or 3
    local offsetX = db[prefix .. "OffsetX"] or 0
    local offsetY = db[prefix .. "OffsetY"] or 0
    local paddingX = db[prefix .. "PaddingX"] or 2
    local paddingY = db[prefix .. "PaddingY"] or 2
    local borderThickness = db[prefix .. "BorderThickness"] or 1
    
    -- Apply pixel-perfect sizing
    if db.pixelPerfect then
        size, scale, borderThickness = DF:PixelPerfectSizeAndScaleForBorder(size, scale, borderThickness)
    end
    
    -- Parse growth direction
    local primary, secondary = strsplit("_", growth)
    secondary = secondary or "UP"
    
    local scaledSize = size * scale
    
    -- For CENTER_LEFT and CENTER_RIGHT, icons stack vertically (centered) and grow horizontally
    -- For CENTER_UP and CENTER_DOWN, icons stack horizontally (centered) and grow vertically
    local isHorizontalGrowth = (secondary == "LEFT" or secondary == "RIGHT")
    
    if isHorizontalGrowth then
        -- Vertical stacking (icons in a column), horizontal growth direction
        local secondaryX = 0
        if secondary == "LEFT" then
            secondaryX = -(scaledSize + paddingX)
        elseif secondary == "RIGHT" then
            secondaryX = scaledSize + paddingX
        end
        
        -- Reposition each visible icon with proper vertical centering
        for i = 1, visibleCount do
            local icon = icons[i]
            if icon then
                local idx = i - 1
                local col = math.floor(idx / wrap)  -- Which column (horizontal position)
                local row = idx % wrap              -- Which row within the column (vertical position)
                
                -- Count icons in this column (for centering calculation)
                local iconsInCol = math.min(wrap, visibleCount - (col * wrap))
                
                -- Calculate center offset for this column (vertical centering)
                local centerOffset = (iconsInCol - 1) * (scaledSize + paddingY) / 2
                
                -- Position relative to center
                local x = offsetX + (col * secondaryX)
                local y = offsetY - (row * (scaledSize + paddingY)) + centerOffset
                
                icon:ClearAllPoints()
                icon:SetPoint(anchor, frame, anchor, x, y)
            end
        end
    else
        -- Horizontal stacking (icons in a row), vertical growth direction (original behavior)
        local secondaryY = 0
        if secondary == "UP" then
            secondaryY = scaledSize + paddingY
        elseif secondary == "DOWN" then
            secondaryY = -(scaledSize + paddingY)
        end
        
        -- Reposition each visible icon with proper horizontal centering
        for i = 1, visibleCount do
            local icon = icons[i]
            if icon then
                local idx = i - 1
                local row = math.floor(idx / wrap)
                local col = idx % wrap
                
                -- Count icons in this row (for centering calculation)
                local iconsInRow = math.min(wrap, visibleCount - (row * wrap))
                
                -- Calculate center offset for this row
                local centerOffset = (iconsInRow - 1) * (scaledSize + paddingX) / 2
                
                -- Position relative to center
                local x = offsetX + (col * (scaledSize + paddingX)) - centerOffset
                local y = offsetY + (row * secondaryY)
                
                icon:ClearAllPoints()
                icon:SetPoint(anchor, frame, anchor, x, y)
            end
        end
    end
end

-- ============================================================
-- REPLACEMENT UPDATE FUNCTION
-- ============================================================

function DF:UpdateAuras_Enhanced(frame)
    if not frame or not frame.unit then return end

    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableAuras then return end

    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)

    -- Aura Designer runs when enabled; standard buffs can coexist if showBuffs is on.
    local adEnabled = DF:IsAuraDesignerEnabled(frame)
    if adEnabled then
        -- Run AD engine (indicators, frame effects, etc.)
        if DF.AuraDesigner and DF.AuraDesigner.Engine then
            DF.AuraDesigner.Engine:UpdateFrame(frame)
        end

        -- If standard buffs are NOT coexisting, hide their icons
        if not db.showBuffs and frame.buffIcons then
            for _, icon in ipairs(frame.buffIcons) do icon:Hide() end
        end
    end

    -- PERFORMANCE: Only re-apply layout when settings have changed (version mismatch).
    -- Layout (icon positioning, sizing, fonts, borders) is expensive and rarely changes.
    -- It gets invalidated by DF:InvalidateAuraLayout() when GUI/profile settings change.
    local layoutVersion = DF.auraLayoutVersion or 0
    if frame.dfAuraLayoutVersion ~= layoutVersion then
        if DF.ApplyAuraLayout then
            DF:ApplyAuraLayout(frame, "BUFF")
            DF:ApplyAuraLayout(frame, "DEBUFF")
        end
        -- Note: dfAuraLayoutVersion is set inside ApplyAuraLayout
    end

    -- Buff display (standard buff icons)
    -- Shown when: AD is off, OR AD is on with showBuffs enabled (coexistence)
    if not adEnabled or db.showBuffs then
        if db.showBuffs then
            DF:UpdateAuraIconsDirect(frame, frame.buffIcons, "BUFF", db.buffMax or 4)
        else
            if frame.buffIcons then
                for _, icon in ipairs(frame.buffIcons) do icon:Hide() end
            end
        end
    end

    -- Debuff display (always runs — AD doesn't manage debuffs)
    if db.showDebuffs then
        DF:UpdateAuraIconsDirect(frame, frame.debuffIcons, "DEBUFF", db.debuffMax or 4)
    else
        for _, icon in ipairs(frame.debuffIcons) do icon:Hide() end
    end
    
    -- Refresh tooltip if mouse is over an aura that may have changed
    -- This handles the case where auras shift and a new aura is now under cursor
    -- PERFORMANCE FIX: Try GetMouseFocus first (returns single frame, no allocation)
    -- Only fall back to GetMouseFoci (returns table) if GetMouseFocus unavailable
    local focus = GetMouseFocus and GetMouseFocus() or GetMouseFoci and GetMouseFoci()[1]
    if focus and focus.unitFrame == frame and focus.auraType then
        -- Mouse is over one of our aura icons
        if focus:IsShown() and focus.auraData then
            -- Aura is still visible - refresh tooltip via parent-driven helper
            if DF.ShowDFAuraTooltip then
                DF.ShowDFAuraTooltip(focus)
            else
                local onEnter = focus:GetScript("OnEnter")
                if onEnter then
                    onEnter(focus)
                end
            end
        else
            -- Aura icon is now hidden - hide tooltip
            GameTooltip:Hide()
        end
    end
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

local OriginalUpdateAuras = nil
local enhancedAurasInitialized = false

local function InitializeEnhancedAuras()
    if enhancedAurasInitialized then return end
    
    -- Setup hooks to capture Blizzard's filtering decisions
    SetupBlizzardHooks()
    
    -- Replace UpdateAuras with enhanced version
    if DF.UpdateAuras and not OriginalUpdateAuras then
        OriginalUpdateAuras = DF.UpdateAuras
        DF.UpdateAuras = DF.UpdateAuras_Enhanced
    elseif not DF.UpdateAuras then
        -- DF.UpdateAuras doesn't exist yet - define it directly
        DF.UpdateAuras = DF.UpdateAuras_Enhanced
    end
    
    enhancedAurasInitialized = true

    -- Do an initial scan
    ScanAllBlizzardFrames()

    -- Check if Direct mode should be active on load
    -- Delayed slightly to ensure unitFrameMap is populated
    C_Timer.After(0.5, function()
        -- Re-apply persisted "Blizzard aura source unavailable" state first,
        -- so the forced DIRECT mode is set BEFORE EnableDirectAuraMode reads
        -- the setting. This restores the flag across reloads.
        if DandersFramesDB_v2 and DandersFramesDB_v2.apiBlocked
           and DandersFramesDB_v2.apiBlocked.blizzardAuraSource then
            DF.BlizzardAuraSourceUnavailable = true
            ForceDirectAuraSourceMode()
        end

        -- Runtime detection: on a fresh install / first encounter with
        -- 12.0.5+, CompactUnitFrame_UpdateAuras is nil and we flip the
        -- flag + show the popup.
        DF:CheckBlizzardAuraSourceAvailable()

        local db = DF.db and DF.db.party
        local raidDb = DF.db and DF.db.raid
        if (db and db.auraSourceMode == "DIRECT") or (raidDb and raidDb.auraSourceMode == "DIRECT") then
            DF:EnableDirectAuraMode()
        end
    end)
end

-- ============================================================
-- CRITICAL: Initialize synchronously, not with delay!
-- During combat reload, delayed initialization would fire AFTER combat
-- lockdown re-establishes, causing UpdateAuras to use the old (non-cached)
-- version instead of the Blizzard-cache-based enhanced version.
-- ============================================================
InitializeEnhancedAuras()

-- ============================================================
-- SAFEGUARD: Ensure enhanced version is used even if Icons.lua
-- loads after Auras.lua (shouldn't happen, but be defensive)
-- ============================================================
local auraInitFrame = CreateFrame("Frame")
auraInitFrame:RegisterEvent("ADDON_LOADED")
auraInitFrame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "DandersFrames" then
        -- Double-check that enhanced version is active
        if DF.UpdateAuras ~= DF.UpdateAuras_Enhanced then
            if DF.UpdateAuras then
                OriginalUpdateAuras = DF.UpdateAuras
            end
            DF.UpdateAuras = DF.UpdateAuras_Enhanced
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- ============================================================
-- DEBUG FUNCTION
-- ============================================================

function DF:DebugAuraFiltering()
    print("|cff00ccffDandersFrames Aura Filter Debug:|r")
    print("")
    print("|cffffcc00Hook Status:|r")
    print("  Blizzard Hook Active:", DF.BlizzardHookActive and "Yes" or "No")
    print("  CompactUnitFrame_UpdateAuras exists:", CompactUnitFrame_UpdateAuras and "Yes" or "No")
    print("")
    
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    print("|cffffcc00Current Settings:|r")
    print("  Filter Mode: BLIZZARD (uses Blizzard's aura filtering)")
    print("  Hide Blizzard Party Frames:", db.hideBlizzardPartyFrames and "Yes" or "No")
    print("  Hide Blizzard Raid Frames:", raidDb.hideBlizzardRaidFrames and "Yes" or "No")
    print("")
    
    print("|cffffcc00Blizzard Aura Cache:|r")
    local cacheCount = 0
    for unit, cache in pairs(DF.BlizzardAuraCache) do
        local buffCount, debuffCount = 0, 0
        for _ in pairs(cache.buffs) do buffCount = buffCount + 1 end
        for _ in pairs(cache.debuffs) do debuffCount = debuffCount + 1 end
        print("  " .. unit .. ": " .. buffCount .. " buffs, " .. debuffCount .. " debuffs cached")
        cacheCount = cacheCount + 1
    end
    if cacheCount == 0 then
        print("  (empty - Blizzard frames may not have updated yet)")
        print("  Try: /dfauras scan")
    end
end

-- Force a scan of all Blizzard frames
function DF:ForceScanBlizzardFrames()
    ScanAllBlizzardFrames()
    print("|cff00ff00DandersFrames:|r Scanned Blizzard frames for auras")
    
    -- Also update our frames
    if DF.UpdateAllFrames then
        DF:UpdateAllFrames()
    end
end

-- ============================================================
-- HIDE/SHOW BLIZZARD RAID FRAMES
-- Blizzard mode: hide containers, strip events but keep UNIT_AURA
-- Direct mode: fully disable frames (unregister ALL events,
--   reparent party frames to hidden parent — Grid2 pattern)
-- ============================================================

-- Track if we've installed hooks (only do once)
local blizzardHooksInstalled = false

-- Track which frames have been stripped so we can restore them
local strippedFrames = {}

-- Track frames that have been reparented to the hidden frame
local reparentedFrames = {}

-- Hidden parent frame for fully disabling Blizzard frames (Grid2 pattern)
local blizzardHiddenParent = CreateFrame("Frame")
blizzardHiddenParent:Hide()

-- Track if Direct-mode full disable is active
DF.blizzardFramesFullyDisabled = false

-- Function to strip events from a Blizzard unit frame
-- fullDisable=true: unregister ALL events (Direct mode, no Blizzard aura data needed)
-- fullDisable=false: keep UNIT_AURA + combat events (Blizzard mode, need aura cache)
local function StripUnitFrameEvents(frame, fullDisable)
    if not frame then return end
    local unit = frame.unit
    if unit then
        pcall(function()
            frame:UnregisterAllEvents()
            if not fullDisable then
                -- Re-register UNIT_AURA so Blizzard's aura cache keeps updating
                frame:RegisterUnitEvent("UNIT_AURA", unit)
                -- Keep combat events for proper updates
                frame:RegisterEvent("PLAYER_REGEN_ENABLED")
                frame:RegisterEvent("PLAYER_REGEN_DISABLED")
            end
        end)
        strippedFrames[frame] = true
    end
end

-- Reparent a frame to the hidden parent (fully removes it from the visual tree)
local function ReparentToHidden(frame)
    if not frame then return end
    if InCombatLockdown() then return end
    pcall(function()
        if frame.GetParent then
            reparentedFrames[frame] = frame:GetParent()
        end
        frame:SetParent(blizzardHiddenParent)
        frame:Hide()
    end)
end

-- Restore a reparented frame back to its original parent
local function RestoreParent(frame)
    if not frame then return end
    if InCombatLockdown() then return end
    local originalParent = reparentedFrames[frame]
    if originalParent then
        pcall(function()
            frame:SetParent(originalParent)
        end)
        reparentedFrames[frame] = nil
    end
end

-- Function to restore all events on a frame (call Blizzard's setup function)
local function RestoreUnitFrameEvents(frame)
    if not frame then return end
    if not strippedFrames[frame] then return end

    -- Restore parent first if it was reparented
    RestoreParent(frame)

    pcall(function()
        -- Call Blizzard's function to restore all events
        if CompactUnitFrame_UpdateUnitEvents then
            CompactUnitFrame_UpdateUnitEvents(frame)
        end
    end)
    strippedFrames[frame] = nil
end

-- Restore events on ALL stripped frames (called when switching away from Direct mode)
function DF:RestoreStrippedFrameEvents()
    for frame in pairs(strippedFrames) do
        RestoreUnitFrameEvents(frame)
    end
end

-- Install hooks once to intercept Blizzard's event registration
local function InstallBlizzardHooks()
    if blizzardHooksInstalled then return end
    
    -- Hook CompactUnitFrame_UpdateUnitEvents to strip events but keep UNIT_AURA
    if CompactUnitFrame_UpdateUnitEvents then
        hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", function(frame)
            -- Only strip events if we're hiding Blizzard frames
            local raidDb = DF:GetRaidDB()
            local partyDb = DF:GetDB()
            local shouldStrip = false
            
            if frame.unit then
                if frame.unit:match("^raid") and raidDb.hideBlizzardRaidFrames then
                    shouldStrip = true
                elseif frame.unit:match("^party") and partyDb.hideBlizzardPartyFrames then
                    shouldStrip = true
                elseif frame.unit == "player" and partyDb.hideBlizzardPartyFrames then
                    shouldStrip = true
                end
            end
            
            if shouldStrip then
                -- In Direct mode, fully disable (no events at all)
                local isDirectMode = false
                if frame.unit then
                    if frame.unit:match("^raid") then
                        isDirectMode = raidDb.auraSourceMode == "DIRECT"
                    else
                        isDirectMode = partyDb.auraSourceMode == "DIRECT"
                    end
                end
                StripUnitFrameEvents(frame, isDirectMode)
            end
        end)
    end

    -- Hook side menu frames to forcibly re-hide when Blizzard re-shows them
    -- SetAlpha(0) alone is insufficient — Blizzard code resets alpha on various events
    local function ShouldHideSideMenu()
        -- Always hide side menu when solo — it's a party/raid UI element
        if not IsInGroup() and not IsInRaid() then return true end
        local raidDb = DF:GetRaidDB()
        local partyDb = DF:GetDB()
        if not raidDb or not partyDb then return false end
        if IsInRaid() then
            return raidDb.hideBlizzardRaidFrames and not raidDb.showBlizzardSideMenu
        else
            return partyDb.hideBlizzardPartyFrames and not partyDb.showBlizzardSideMenu
        end
    end

    local function ForceHideSideMenuFrame(frame)
        if not frame then return end
        pcall(function()
            if not InCombatLockdown() then
                frame:Hide()
            else
                frame:SetAlpha(0)
            end
        end)
    end

    if CompactRaidFrameManager then
        hooksecurefunc(CompactRaidFrameManager, "Show", function()
            if ShouldHideSideMenu() then
                ForceHideSideMenuFrame(CompactRaidFrameManager)
            end
        end)
        if CompactRaidFrameManager.displayFrame then
            hooksecurefunc(CompactRaidFrameManager.displayFrame, "Show", function()
                if ShouldHideSideMenu() then
                    ForceHideSideMenuFrame(CompactRaidFrameManager.displayFrame)
                end
            end)
        end
    end

    blizzardHooksInstalled = true
end

function DF:UpdateBlizzardFrameVisibility()
    local partyDb = DF:GetDB()
    local raidDb = DF:GetRaidDB()

    -- Separate settings for party and raid frames
    local hidePartyFrames = partyDb.hideBlizzardPartyFrames
    local hideRaidFrames = raidDb.hideBlizzardRaidFrames

    -- Check if Direct mode is active (allows full disable instead of just hiding)
    local partyDirectMode = partyDb.auraSourceMode == "DIRECT"
    local raidDirectMode = raidDb.auraSourceMode == "DIRECT"
    DF.blizzardFramesFullyDisabled = (hidePartyFrames and partyDirectMode) or (hideRaidFrames and raidDirectMode)
    
    -- Side menu visibility - hide when solo, respect setting when grouped
    local showSideMenu
    if not IsInGroup() and not IsInRaid() then
        showSideMenu = false
    elseif IsInRaid() then
        showSideMenu = raidDb.showBlizzardSideMenu
    else
        showSideMenu = partyDb.showBlizzardSideMenu
    end
    
    -- Install hooks if we're hiding frames
    if hidePartyFrames or hideRaidFrames then
        InstallBlizzardHooks()
    end
    
    -- Function to safely apply visibility using SetAlpha only
    local function SafeHideFrame(frame, hide)
        if not frame then return end
        pcall(function()
            if hide then
                frame:SetAlpha(0)
            else
                frame:SetAlpha(1)
            end
        end)
    end
    
    -- Function to safely scale container frames
    local function SafeScaleContainer(frame, hide)
        if not frame then return end
        if InCombatLockdown() then return end
        pcall(function()
            if hide then
                frame:SetAlpha(0)
                frame:SetScale(0.001)
            else
                frame:SetAlpha(1)
                frame:SetScale(1)
            end
        end)
    end
    
    -- Function to safely apply just alpha
    local function SafeSetAlpha(frame, alpha)
        if frame and frame.SetAlpha then
            pcall(function() frame:SetAlpha(alpha) end)
        end
    end
    
    -- Function to hide selection highlights
    local function HideSelectionHighlights(frame)
        if not frame then return end
        pcall(function()
            if frame.selectionHighlight and frame.selectionHighlight.SetShown then
                frame.selectionHighlight:SetShown(false)
            end
            if frame.selectionIndicator and frame.selectionIndicator.SetShown then
                frame.selectionIndicator:SetShown(false)
            end
        end)
    end
    
    -- Hide/show the main container frames (raid-style)
    SafeScaleContainer(CompactRaidFrameContainer, hideRaidFrames)
    
    -- Handle CompactPartyFrame (raid-style party frames)
    if CompactPartyFrame then
        SafeSetAlpha(CompactPartyFrame, hidePartyFrames and 0 or 1)
        SafeSetAlpha(CompactPartyFrame.title, hidePartyFrames and 0 or 1)
        SafeSetAlpha(CompactPartyFrame.borderFrame, hidePartyFrames and 0 or 1)
        if hidePartyFrames then
            HideSelectionHighlights(CompactPartyFrame)
        end
    end
    
    -- Handle traditional portrait-style party frames
    if hidePartyFrames and partyDirectMode then
        -- Direct mode: fully disable (reparent to hidden frame)
        ReparentToHidden(PartyFrame)
    else
        RestoreParent(PartyFrame)
        SafeScaleContainer(PartyFrame, hidePartyFrames)
    end

    -- Handle individual traditional party member frames (PartyMemberFrame1-4)
    for i = 1, 4 do
        local frame = _G["PartyMemberFrame" .. i]
        if frame then
            if hidePartyFrames and partyDirectMode then
                ReparentToHidden(frame)
            else
                RestoreParent(frame)
                SafeHideFrame(frame, hidePartyFrames)
                local petFrame = _G["PartyMemberFrame" .. i .. "PetFrame"]
                SafeSetAlpha(petFrame, hidePartyFrames and 0 or 1)
                local buffFrame = _G["PartyMemberFrame" .. i .. "BuffFrame"]
                SafeSetAlpha(buffFrame, hidePartyFrames and 0 or 1)
                local debuffFrame = _G["PartyMemberFrame" .. i .. "DebuffFrame"]
                SafeSetAlpha(debuffFrame, hidePartyFrames and 0 or 1)
            end
        end
    end

    -- Handle individual compact party member frames
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. i]
        if frame then
            if hidePartyFrames then
                SafeHideFrame(frame, true)
                HideSelectionHighlights(frame)
                StripUnitFrameEvents(frame, partyDirectMode)
            else
                -- Restore events when showing
                RestoreUnitFrameEvents(frame)
            end
        end
    end
    
    -- Handle raid frames
    for i = 1, 40 do
        local frame = _G["CompactRaidFrame" .. i]
        if frame then
            SafeHideFrame(frame, hideRaidFrames)
            if hideRaidFrames then
                HideSelectionHighlights(frame)
                StripUnitFrameEvents(frame, raidDirectMode)
            else
                -- Restore events when showing
                RestoreUnitFrameEvents(frame)
            end
        end
    end

    for group = 1, 8 do
        for member = 1, 5 do
            local frame = _G["CompactRaidGroup" .. group .. "Member" .. member]
            if frame then
                SafeHideFrame(frame, hideRaidFrames)
                if hideRaidFrames then
                    HideSelectionHighlights(frame)
                    StripUnitFrameEvents(frame, raidDirectMode)
                else
                    -- Restore events when showing
                    RestoreUnitFrameEvents(frame)
                end
            end
        end
        -- Also hide group headers
        local groupFrame = _G["CompactRaidGroup" .. group]
        SafeHideFrame(groupFrame, hideRaidFrames)
    end
    
    -- Force hide/show a frame using actual Hide()/Show() outside combat,
    -- falling back to SetAlpha inside combat to avoid taint.
    -- The hooks on Show() only re-hide when ShouldHideSideMenu() is true,
    -- so calling Show() here is safe — if we're showing, the setting is on
    -- and the hook will be a no-op.
    local function ForceHideShow(frame, hide)
        if not frame then return end
        pcall(function()
            if InCombatLockdown() then
                frame:SetAlpha(hide and 0 or 1)
            else
                if hide then
                    frame:Hide()
                else
                    frame:SetAlpha(1)
                    frame:Show()
                end
            end
        end)
    end

    -- Handle raid frame manager
    if CompactRaidFrameManager then
        local sideMenuVisible = showSideMenu or not hideRaidFrames

        SafeHideFrame(CompactRaidFrameManager.container, hideRaidFrames)
        SafeHideFrame(CompactRaidFrameManager.toggleButton, hideRaidFrames)

        -- Handle the display frame (side panel with settings/pings) separately
        -- Use actual Hide() to prevent Blizzard from re-showing via alpha resets
        ForceHideShow(CompactRaidFrameManager.displayFrame, not sideMenuVisible)

        -- The main manager frame itself
        ForceHideShow(CompactRaidFrameManager, not sideMenuVisible)
    end

    -- Handle the side menu elements for party frames
    local partySideMenuVisible = showSideMenu or not hidePartyFrames

    if CompactPartyFrame then
        -- Only adjust title if we want to show/hide the side menu differently
        if not partySideMenuVisible then
            SafeSetAlpha(CompactPartyFrame.title, 0)
        else
            SafeSetAlpha(CompactPartyFrame.title, 1)
        end
        ForceHideShow(CompactPartyFrame.dropdown, not partySideMenuVisible)
        ForceHideShow(CompactPartyFrame.menuButton, not partySideMenuVisible)
    end

    if PartyFrame then
        ForceHideShow(PartyFrame.DropdownButton, not partySideMenuVisible)
        SafeSetAlpha(PartyFrame.PartyMemberFrameDropDown, partySideMenuVisible and 1 or 0)
    end

    if EditModeManagerFrame and EditModeManagerFrame.PartyFramesSidePanel then
        ForceHideShow(EditModeManagerFrame.PartyFramesSidePanel, not sideMenuVisible)
    end
end

-- Apply visibility on load and when group changes
local blizzFrameEventHandler = CreateFrame("Frame")
blizzFrameEventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
blizzFrameEventHandler:RegisterEvent("GROUP_ROSTER_UPDATE")
blizzFrameEventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
blizzFrameEventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
blizzFrameEventHandler:RegisterEvent("RAID_ROSTER_UPDATE")
blizzFrameEventHandler:RegisterEvent("PARTY_MEMBER_ENABLE")
blizzFrameEventHandler:RegisterEvent("PARTY_MEMBER_DISABLE")

-- Coalesce rapid-fire events into a single deferred update to prevent
-- the multiple timer callbacks from fighting each other and causing flicker
local blizzVisibilityPending = false

blizzFrameEventHandler:SetScript("OnEvent", function(self, event)
    if event == "GROUP_ROSTER_UPDATE" then
        if DF.RosterDebugEvent then DF:RosterDebugEvent("Auras.lua(visibility):GROUP_ROSTER_UPDATE") end
    end
    -- Debounced update — first event arms the timer, subsequent events within
    -- the window are ignored; the single callback fires once Blizzard has settled
    if not blizzVisibilityPending then
        blizzVisibilityPending = true
        C_Timer.After(0.3, function()
            blizzVisibilityPending = false
            if DF.UpdateBlizzardFrameVisibility then
                DF:UpdateBlizzardFrameVisibility()
            end
        end)
    end
    
    -- For target changes, also do an immediate check to hide selection highlights
    if event == "PLAYER_TARGET_CHANGED" then
        local db = DF.GetDB and DF:GetDB()
        local raidDb = DF.GetRaidDB and DF:GetRaidDB()
        local hideParty = db and db.hideBlizzardPartyFrames
        local hideRaid = raidDb and raidDb.hideBlizzardRaidFrames
        
        if hideParty or hideRaid then
            -- Hide selection highlights on all Blizzard frames
            local function HideSelectionHighlight(frame)
                if frame then
                    if frame.selectionHighlight and frame.selectionHighlight.SetShown then
                        frame.selectionHighlight:SetShown(false)
                    end
                    if frame.selectionIndicator and frame.selectionIndicator.SetShown then
                        frame.selectionIndicator:SetShown(false)
                    end
                end
            end
            
            if hideParty then
                for i = 1, 5 do
                    HideSelectionHighlight(_G["CompactPartyFrameMember" .. i])
                end
            end
            if hideRaid then
                for i = 1, 40 do
                    HideSelectionHighlight(_G["CompactRaidFrame" .. i])
                end
                for group = 1, 8 do
                    for member = 1, 5 do
                        HideSelectionHighlight(_G["CompactRaidGroup" .. group .. "Member" .. member])
                    end
                end
            end
        end
    end
end)

-- Hook Blizzard's selection highlight function to hide it when our option is enabled
if CompactUnitFrame_UpdateSelectionHighlight then
    hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
        local db = DF.GetDB and DF:GetDB()
        local raidDb = DF.GetRaidDB and DF:GetRaidDB()
        
        -- Only affect party/raid frames, not nameplates
        local unit = frame.unit or frame.displayedUnit
        if unit then
            local isParty = unit:match("^party") or unit == "player"
            local isRaid = unit:match("^raid")
            
            local shouldHide = false
            if isParty and db and db.hideBlizzardPartyFrames then
                shouldHide = true
            elseif isRaid and raidDb and raidDb.hideBlizzardRaidFrames then
                shouldHide = true
            end
            
            if shouldHide and frame.selectionHighlight and frame.selectionHighlight.SetShown then
                frame.selectionHighlight:SetShown(false)
            end
        end
    end)
end

-- Slash command
SLASH_DFAURAS1 = "/dfauras"
SlashCmdList["DFAURAS"] = function(msg)
    if msg == "scan" then
        DF:ForceScanBlizzardFrames()
    elseif msg == "hideparty" then
        local db = DF:GetDB()
        db.hideBlizzardPartyFrames = not db.hideBlizzardPartyFrames
        DF:UpdateBlizzardFrameVisibility()
        print("|cff00ff00DandersFrames:|r Blizzard party frames " .. (db.hideBlizzardPartyFrames and "hidden" or "visible"))
    elseif msg == "hideraid" then
        local raidDb = DF:GetRaidDB()
        raidDb.hideBlizzardRaidFrames = not raidDb.hideBlizzardRaidFrames
        DF:UpdateBlizzardFrameVisibility()
        print("|cff00ff00DandersFrames:|r Blizzard raid frames " .. (raidDb.hideBlizzardRaidFrames and "hidden" or "visible"))
    elseif msg == "hideblizz" or msg == "hide" then
        -- Toggle both for convenience
        local db = DF:GetDB()
        local raidDb = DF:GetRaidDB()
        local newState = not (db.hideBlizzardPartyFrames or raidDb.hideBlizzardRaidFrames)
        db.hideBlizzardPartyFrames = newState
        raidDb.hideBlizzardRaidFrames = newState
        DF:UpdateBlizzardFrameVisibility()
        print("|cff00ff00DandersFrames:|r Blizzard frames " .. (newState and "hidden" or "visible"))
    elseif msg == "sidemenu" then
        -- Debug: list potential side menu frames
        print("|cff00ff00DandersFrames:|r Searching for side menu frames...")
        local framesToCheck = {
            "CompactPartyFrame",
            "CompactPartyFrameTitle",
            "CompactPartyFrameBorderFrame", 
            "PartyFrame",
            "CompactRaidFrameManager",
            "CompactRaidFrameManagerDisplayFrame",
            "CompactRaidFrameManagerContainerResizeFrame",
        }
        for _, name in ipairs(framesToCheck) do
            local frame = _G[name]
            if frame then
                print("  Found: " .. name .. " (shown: " .. tostring(frame:IsShown()) .. ", alpha: " .. tostring(frame:GetAlpha()) .. ")")
                -- List children
                if frame.GetChildren then
                    for i, child in ipairs({frame:GetChildren()}) do
                        local childName = child:GetName() or ("unnamed_" .. i)
                        if child:IsShown() then
                            print("    Child: " .. childName .. " (alpha: " .. tostring(child:GetAlpha()) .. ")")
                        end
                    end
                end
            end
        end
        -- Also check for any visible frame with "party" in name at UIParent level
        print("  Checking UIParent children for party-related frames...")
        for i, child in ipairs({UIParent:GetChildren()}) do
            local name = child:GetName()
            if name and (name:lower():find("party") or name:lower():find("compact")) and child:IsShown() then
                print("    UIParent child: " .. name .. " (alpha: " .. tostring(child:GetAlpha()) .. ")")
            end
        end
    else
        DF:DebugAuraFiltering()
    end
end

-- ============================================================
-- LIVE DEBUFF DEBUG MODE
-- Prints Blizzard's internal debuff/dispel data in real-time
-- Usage: /dfauras debuglive
-- ============================================================

DF.debugLiveAuras = false

local function PrintBlizzardFrameData(frame, frameName)
    if not frame then return end
    
    local unit = frame.unit
    if not unit then return end
    
    print("|cff00ccff[" .. frameName .. "]|r Unit: " .. unit)
    
    -- Check debuffs container
    if frame.debuffs and frame.debuffs.Size then
        local count = frame.debuffs:Size()
        print("  |cffff8800debuffs container:|r Size = " .. count)
        if count > 0 and frame.debuffs.Iterate then
            pcall(function()
                for aura in frame.debuffs:Iterate() do
                    local dispelInfo = ""
                    if aura.dispelName then
                        dispelInfo = "|cff00ff00" .. aura.dispelName .. "|r"
                    else
                        dispelInfo = "|cffff0000NOT DISPELLABLE|r"
                    end
                    print("    - " .. (aura.name or "?") .. " | ID: " .. tostring(aura.auraInstanceID) .. " | dispelName: " .. dispelInfo .. " | dispelType: " .. tostring(aura.dispelType or "nil"))
                end
            end)
        end
    else
        print("  |cffff0000debuffs container: NOT FOUND|r")
    end
    
    -- Check buffs container (for comparison)
    if frame.buffs and frame.buffs.Size then
        local count = frame.buffs:Size()
        print("  |cff88ff88buffs container:|r Size = " .. count)
    end
    
    -- Check bigDefensives container
    if frame.bigDefensives and frame.bigDefensives.Size then
        local count = frame.bigDefensives:Size()
        print("  |cffff00ffbigDefensives container:|r Size = " .. count)
        if count > 0 and frame.bigDefensives.Iterate then
            pcall(function()
                for aura in frame.bigDefensives:Iterate() do
                    print("    - " .. (aura.name or "?") .. " | ID: " .. tostring(aura.auraInstanceID))
                end
            end)
        end
    end
    
    -- Check for private auras
    if frame.privateAuraSize and frame.privateAuraSize > 0 then
        print("  |cffff00ffPrivate Auras:|r " .. frame.privateAuraSize .. " (hidden from addons)")
    end
    if frame.PrivateAuraAnchors then
        local anchorCount = 0
        for _ in pairs(frame.PrivateAuraAnchors) do anchorCount = anchorCount + 1 end
        if anchorCount > 0 then
            print("  |cffff00ffPrivateAuraAnchors:|r " .. anchorCount .. " anchors")
        end
    end
    
    -- Check dispels container (by type)
    if frame.dispels then
        local hasAny = false
        for dispelType, container in pairs(frame.dispels) do
            if type(container) == "table" and container.Size and container:Size() > 0 then
                hasAny = true
                break
            end
        end
        if hasAny then
            print("  |cff00ff00dispels container:|r (YOUR class can dispel these)")
            for dispelType, container in pairs(frame.dispels) do
                if type(container) == "table" and container.Size then
                    local count = container:Size()
                    if count > 0 then
                        print("    |cff00ff00" .. dispelType .. ":|r " .. count .. " auras")
                        if container.Iterate then
                            pcall(function()
                                for aura in container:Iterate() do
                                    print("      - " .. (aura.name or "?") .. " | ID: " .. tostring(aura.auraInstanceID))
                                end
                            end)
                        end
                    end
                end
            end
        else
            print("  |cffffff00dispels container:|r (empty - no debuffs YOUR class can dispel)")
        end
    else
        print("  |cffff0000dispels container: NOT FOUND|r")
    end
    
    -- Check old-style debuffFrames (what we currently use)
    if frame.debuffFrames then
        local shownCount = 0
        local totalCount = #frame.debuffFrames
        local shownDetails = {}
        for i, df in ipairs(frame.debuffFrames) do
            if df:IsShown() and df.auraInstanceID then
                shownCount = shownCount + 1
                table.insert(shownDetails, tostring(df.auraInstanceID))
            end
        end
        print("  |cffffff00debuffFrames (UI):|r " .. shownCount .. "/" .. totalCount .. " shown with auraInstanceID")
        if shownCount > 0 then
            print("    IDs: " .. table.concat(shownDetails, ", "))
        end
    end
    
    -- Check dispelDebuffFrames
    if frame.dispelDebuffFrames then
        local shownCount = 0
        local totalCount = #frame.dispelDebuffFrames
        local shownDetails = {}
        for i, df in ipairs(frame.dispelDebuffFrames) do
            if df:IsShown() and df.auraInstanceID then
                shownCount = shownCount + 1
                table.insert(shownDetails, tostring(df.auraInstanceID))
            end
        end
        print("  |cffffff00dispelDebuffFrames (UI):|r " .. shownCount .. "/" .. totalCount .. " shown with auraInstanceID")
        if shownCount > 0 then
            print("    IDs: " .. table.concat(shownDetails, ", "))
        end
    end
    
    -- NEW: Check for any other aura-related containers we might have missed
    -- Look for anything with "boss", "debuff", "aura" in the name that's a table with Size method
    local checkedKeys = {debuffs=true, buffs=true, dispels=true, bigDefensives=true, debuffFrames=true, dispelDebuffFrames=true, buffFrames=true, PrivateAuraAnchors=true}
    local foundOther = false
    for key, value in pairs(frame) do
        if type(key) == "string" and type(value) == "table" and not checkedKeys[key] then
            local keyLower = key:lower()
            if keyLower:find("boss") or keyLower:find("aura") or keyLower:find("debuff") then
                if value.Size and type(value.Size) == "function" then
                    local count = 0
                    pcall(function() count = value:Size() end)
                    if count > 0 then
                        if not foundOther then
                            print("  |cffff00ff=== OTHER CONTAINERS ===|r")
                            foundOther = true
                        end
                        print("    |cffff00ff" .. key .. ":|r Size = " .. count)
                        if value.Iterate then
                            pcall(function()
                                for aura in value:Iterate() do
                                    print("      - " .. (aura.name or "?") .. " | ID: " .. tostring(aura.auraInstanceID or "?"))
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
    
    -- Also check raw API for what debuffs the unit actually has
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local hasHarmful = false
        for i = 1, 10 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
            if aura then
                if not hasHarmful then
                    print("  |cffff5500=== RAW API HARMFUL AURAS ===|r")
                    hasHarmful = true
                end
                local dispelInfo = aura.dispelName and ("|cff00ff00" .. aura.dispelName .. "|r") or "|cffff0000none|r"
                local bossInfo = ""
                pcall(function()
                    if aura.isBossAura then bossInfo = " |cffff0000[BOSS]|r" end
                end)
                print("    [" .. i .. "] " .. (aura.name or "?") .. " | ID: " .. tostring(aura.auraInstanceID) .. " | dispel: " .. dispelInfo .. bossInfo)
            else
                break
            end
        end
        if not hasHarmful then
            print("  |cffffff00RAW API: No HARMFUL auras on " .. unit .. "|r")
        end
    end
    
    print("")
end

local function DebugAllBlizzardFrames()
    print("|cff00ff00=== BLIZZARD FRAME DEBUFF DEBUG ===|r")
    print("")
    
    -- Party frames
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. i]
        if frame and frame.unit then
            PrintBlizzardFrameData(frame, "CompactPartyFrameMember" .. i)
        end
    end
    
    -- Raid frames (just first 10 to avoid spam)
    for i = 1, 10 do
        local frame = _G["CompactRaidFrame" .. i]
        if frame and frame.unit then
            PrintBlizzardFrameData(frame, "CompactRaidFrame" .. i)
        end
    end
    
    print("|cff00ff00=== END DEBUG ===|r")
end

-- Hook for live monitoring
local debugHookInstalled = false
local function InstallDebugHook()
    if debugHookInstalled then return end
    
    if CompactUnitFrame_UpdateAuras then
        hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
            if not DF.debugLiveAuras then return end
            if not frame or not frame.unit then return end
            
            -- PERFORMANCE FIX 2025-01-20: Check for nameplate BEFORE calling GetName()
            -- Nameplates can error on GetName() - check unit string first
            local unit = frame.unit
            if unit and type(unit) == "string" and unit:find("nameplate") then
                return
            end
            local displayedUnit = frame.displayedUnit
            if displayedUnit and type(displayedUnit) == "string" and displayedUnit:find("nameplate") then
                return
            end
            
            -- Now safe to call GetName
            local name = frame:GetName()
            if not name then return end
            if name:find("NamePlate") then return end
            
            PrintBlizzardFrameData(frame, name)
        end)
        debugHookInstalled = true
        print("|cff00ff00DandersFrames:|r Debug hook installed")
    end
end

-- Slash command handler for debug
SLASH_DFAURASDEBUG1 = "/dfaurasdebug"
SlashCmdList["DFAURASDEBUG"] = function(msg)
    msg = msg:lower():trim()
    
    if msg == "live" or msg == "on" then
        DF.debugLiveAuras = true
        InstallDebugHook()
        print("|cff00ff00DandersFrames:|r Live aura debug ENABLED - debuff data will print when auras change")
    elseif msg == "off" then
        DF.debugLiveAuras = false
        print("|cff00ff00DandersFrames:|r Live aura debug DISABLED")
    elseif msg == "now" or msg == "snap" or msg == "snapshot" then
        DebugAllBlizzardFrames()
    else
        print("|cff00ccffDandersFrames Aura Debug Commands:|r")
        print("  /dfaurasdebug live - Enable live monitoring (prints on every aura update)")
        print("  /dfaurasdebug off - Disable live monitoring")
        print("  /dfaurasdebug now - Print current snapshot of all Blizzard frame data")
    end
end

-- ============================================================
-- DEFENSIVE / BUFF DEDUPLICATION DEBUG
-- Dumps auraInstanceIDs from both caches to check for overlap
-- Usage: /dfdefdup
-- ============================================================

SLASH_DFDEFDUP1 = "/dfdefdup"
SlashCmdList["DFDEFDUP"] = function()
    local issecret = issecretvalue or function() return false end
    local header = "|cff00ff00DandersFrames|r |cff00ccff[Defensive/Buff Dedup Debug]|r"
    print(header)

    local anyUnit = false
    for unit, cache in pairs(DF.BlizzardAuraCache) do
        if cache and (next(cache.defensives) or next(cache.buffs)) then
            anyUnit = true
            local unitName = UnitName(unit) or unit
            print("|cffffcc00--- " .. unit .. " (" .. unitName .. ") ---|r")

            -- Defensive IDs
            local defCount = 0
            local defIDs = {}
            for id in pairs(cache.defensives) do
                defCount = defCount + 1
                local isSecret = issecret(id)
                defIDs[defCount] = { id = id, secret = isSecret }
            end

            if defCount > 0 then
                print("  |cff00ff00Defensives (" .. defCount .. "):|r")
                for i, entry in ipairs(defIDs) do
                    if entry.secret then
                        print("    [" .. i .. "] SECRET (cannot read)")
                    else
                        -- Try to get aura data for extra info
                        local info = ""
                        local ok, data = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, entry.id)
                        if ok and data then
                            local iconStr = data.icon
                            if iconStr and not issecret(iconStr) then
                                info = " icon=" .. tostring(iconStr)
                            end
                            local nameStr = data.name
                            if nameStr and not issecret(nameStr) then
                                info = info .. " name=" .. tostring(nameStr)
                            end
                            local spellStr = data.spellId
                            if spellStr and not issecret(spellStr) then
                                info = info .. " spellId=" .. tostring(spellStr)
                            end
                        end
                        print("    [" .. i .. "] ID=" .. tostring(entry.id) .. info)
                    end
                end
            else
                print("  |cff888888Defensives: (none)|r")
            end

            -- Buff IDs
            local buffCount = #(cache.buffOrder or {})
            if buffCount > 0 then
                print("  |cff3399ffBuffs (" .. buffCount .. "):|r")
                for i, id in ipairs(cache.buffOrder) do
                    local isSecret = issecret(id)
                    if isSecret then
                        print("    [" .. i .. "] SECRET (cannot read)")
                    else
                        local info = ""
                        local ok, data = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, id)
                        if ok and data then
                            local iconStr = data.icon
                            if iconStr and not issecret(iconStr) then
                                info = " icon=" .. tostring(iconStr)
                            end
                            local nameStr = data.name
                            if nameStr and not issecret(nameStr) then
                                info = info .. " name=" .. tostring(nameStr)
                            end
                            local spellStr = data.spellId
                            if spellStr and not issecret(spellStr) then
                                info = info .. " spellId=" .. tostring(spellStr)
                            end
                        end
                        print("    [" .. i .. "] ID=" .. tostring(id) .. info)
                    end
                end
            else
                print("  |cff888888Buffs: (none)|r")
            end

            -- Check for overlaps
            local overlapCount = 0
            local overlaps = {}
            for id in pairs(cache.defensives) do
                if not issecret(id) and cache.buffs[id] then
                    overlapCount = overlapCount + 1
                    overlaps[overlapCount] = id
                end
            end

            if overlapCount > 0 then
                print("  |cffff3333DUPLICATES FOUND (" .. overlapCount .. "):|r")
                for i, id in ipairs(overlaps) do
                    local info = ""
                    local ok, data = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, id)
                    if ok and data then
                        local nameStr = data.name
                        if nameStr and not issecret(nameStr) then
                            info = " name=" .. tostring(nameStr)
                        end
                    end
                    print("    |cffff3333" .. tostring(id) .. info .. "|r")
                end
            else
                print("  |cff00ff00No duplicates between defensive and buff caches|r")
            end
        end
    end

    if not anyUnit then
        print("  |cffff8800No cached aura data found. Are you in a group?|r")
    end
end

-- ============================================================
-- FIX A DEV COMMAND: manually trigger a full scan + dump the cache
-- Usage: /dfscan <unit>
--   e.g. /dfscan player
--   e.g. /dfscan party1
-- ============================================================

SLASH_DFSCAN1 = "/dfscan"
SlashCmdList["DFSCAN"] = function(msg)
    msg = msg and msg:match("^%s*(.-)%s*$") or ""

    -- /dfscan stats       — print the scan counter breakdown
    -- /dfscan reset       — reset the scan counters to zero
    -- /dfscan <unit>      — run ScanUnitFull on <unit> and dump the cache entry
    if msg == "stats" or msg == "" then
        local s = DF.AuraCacheStats
        print("|cff00ff00DandersFrames|r |cff00ccff[AuraCache Stats]|r")
        print(string.format("  events seen:     %d", s.eventsSeen))
        print(string.format("  scanFull:        %d", s.scanFull))
        print(string.format("  deltaApplied:    %d", s.deltaApplied))
        print(string.format("  deltaFallback:   %d", s.deltaFallback))
        if s.eventsSeen > 0 then
            local deltaPct = (s.deltaApplied / s.eventsSeen) * 100
            print(string.format("  delta hit rate:  %.1f%% (higher = better)", deltaPct))
        end
        print("  |cffaaaaaaTip: /dfscan reset to zero the counters, then do a sustained combat test|r")
        print("  |cffaaaaaaUsage: /dfscan <unit> to dump the cache entry for a unit|r")
        return
    end

    if msg == "reset" then
        DF.AuraCacheStats:Reset()
        print("|cff00ff00DandersFrames|r AuraCache counters reset.")
        return
    end

    local unit = msg
    local header = "|cff00ff00DandersFrames|r |cff00ccff[Fix A ScanUnitFull]|r " .. unit
    print(header)

    if not UnitExists(unit) then
        print("  |cffff8800Unit does not exist|r")
        return
    end

    -- Trigger a full scan
    DF:ScanUnitFull(unit)

    local cache = DF.AuraCache[unit]
    if not cache then
        print("  |cffff8800No cache entry after scan|r")
        return
    end

    print(string.format("  hasFullScan = %s, buffOrderDirty = %s, debuffOrderDirty = %s",
        tostring(cache.hasFullScan), tostring(cache.buffOrderDirty), tostring(cache.debuffOrderDirty)))

    local function countKeys(t)
        local n = 0
        if t then for _ in pairs(t) do n = n + 1 end end
        return n
    end

    print(string.format("  buffsByID: %d entries", countKeys(cache.buffsByID)))
    print(string.format("  debuffsByID: %d entries", countKeys(cache.debuffsByID)))
    print(string.format("  classification sets: buffs=%d defensives=%d debuffs=%d playerDispellable=%d allDispellable=%d",
        countKeys(cache.buffs), countKeys(cache.defensives),
        countKeys(cache.debuffs), countKeys(cache.playerDispellable), countKeys(cache.allDispellable)))

    -- Dump a few sample aura names if non-secret
    local issecret = issecretvalue or function() return false end
    local shown = 0
    for id, auraData in pairs(cache.buffsByID) do
        if shown >= 5 then break end
        local name = auraData.name
        if name and not issecret(name) then
            print(string.format("    buff[%s] = %s", tostring(id), tostring(name)))
            shown = shown + 1
        end
    end
    shown = 0
    for id, auraData in pairs(cache.debuffsByID) do
        if shown >= 5 then break end
        local name = auraData.name
        if name and not issecret(name) then
            print(string.format("    debuff[%s] = %s", tostring(id), tostring(name)))
            shown = shown + 1
        end
    end
end
