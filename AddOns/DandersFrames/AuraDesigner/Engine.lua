local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER - ENGINE
-- Runtime loop that reads per-aura config, queries the adapter
-- for active auras, and dispatches to indicator renderers.
--
-- Called from the frame update cycle (UpdateAuras) when the
-- Aura Designer is enabled for a frame's mode.
-- ============================================================

local pairs, ipairs, type = pairs, ipairs, type
local tinsert = table.insert
local sort = table.sort
local wipe = table.wipe
local floor = math.floor
local strsplit = strsplit
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local issecretvalue = issecretvalue or function() return false end

-- Debug throttle: only log once per N seconds to avoid spam
local debugLastLog = 0
local DEBUG_INTERVAL = 3  -- seconds between debug dumps

-- Track which spec aura tables have been sanitized this session
local sanitizedSpecAuras = {}

DF.AuraDesigner = DF.AuraDesigner or {}
DF.adConfigVersion = 0

local Engine = {}
DF.AuraDesigner.Engine = Engine

local Adapter   -- Set during init
local Indicators -- Set during init (AuraDesigner/Indicators.lua)
local SoundEngine -- Set during init (AuraDesigner/SoundEngine.lua)

-- ============================================================
-- GROUP GRID LAYOUT HELPER
-- Computes X/Y offsets for a group member based on growth
-- direction, icons per row, and active index.
-- ============================================================

local function GetGroupGrowthOffset(direction, step)
    if direction == "LEFT" then      return -step, 0
    elseif direction == "RIGHT" then return step, 0
    elseif direction == "UP" then    return 0, step
    elseif direction == "DOWN" then  return 0, -step
    end
    return 0, 0
end

local function ComputeGroupOffset(group, activeIdx, step, totalCount)
    local growth = group.growDirection or "RIGHT"
    local primary, secondary = strsplit("_", growth)
    -- Legacy single-direction compat: if no underscore, default secondary
    if not secondary then
        if primary == "RIGHT" or primary == "LEFT" then
            secondary = "DOWN"
        else
            secondary = "RIGHT"
        end
    end

    local wrap = group.iconsPerRow or 8
    if wrap < 1 then wrap = 1 end

    local col = activeIdx % wrap
    local row = floor(activeIdx / wrap)

    local sX, sY = GetGroupGrowthOffset(secondary, step)

    if primary == "CENTER" then
        -- Center icons within each row
        local iconsInRow = wrap
        if totalCount then
            local lastRow = floor((totalCount - 1) / wrap)
            if row == lastRow then
                iconsInRow = ((totalCount - 1) % wrap) + 1
            end
        end
        local centerOffset = -((iconsInRow - 1) * step) / 2
        -- Determine center axis from secondary direction
        local cX, cY
        if sX ~= 0 then
            -- Secondary is horizontal, so center vertically
            cX = 0
            cY = centerOffset + (col * step)
        else
            -- Secondary is vertical (or zero), so center horizontally
            cX = centerOffset + (col * step)
            cY = 0
        end
        return (group.offsetX or 0) + cX + (row * sX),
               (group.offsetY or 0) + cY + (row * sY)
    else
        local pX, pY = GetGroupGrowthOffset(primary, step)
        return (group.offsetX or 0) + (col * pX) + (row * sX),
               (group.offsetY or 0) + (col * pY) + (row * sY)
    end
end

-- ============================================================
-- INDICATOR TYPE DEFINITIONS
-- Ordered: placed types first, then frame-level types
-- ============================================================

local INDICATOR_TYPES = {
    { key = "icon",       placed = true  },
    { key = "square",     placed = true  },
    { key = "bar",        placed = true  },
    { key = "border",     placed = false },
    { key = "healthbar",  placed = false },
    { key = "nametext",   placed = false },
    { key = "healthtext", placed = false },
    { key = "framealpha", placed = false },
    { key = "sound",      placed = false },
}

-- Frame-level types only (for gathering loop — placed types come from indicators array)
local FRAME_LEVEL_TYPES = {}
for _, typeDef in ipairs(INDICATOR_TYPES) do
    if not typeDef.placed then
        FRAME_LEVEL_TYPES[#FRAME_LEVEL_TYPES + 1] = typeDef
    end
end

-- ============================================================
-- REUSABLE TABLES (avoid per-frame allocation)
-- ============================================================

local activeIndicators = {}  -- Reused each frame: { { auraName, typeKey, config, auraData, priority } }
local groupLookup = {}       -- Reused: "auraName#indicatorID" → { group, memberIdx }
local groupActiveMembers = {} -- Reused: groupID → { ordered active members }

local function prioritySort(a, b)
    return a.priority < b.priority  -- Lower number = higher priority (1 wins over 10)
end

-- Hoisted from an inline closure inside ResolveLayoutGroups' sort call.
-- Module-level so table.sort doesn't allocate a fresh closure every
-- Engine:UpdateFrame call.
local function memberIdxSort(a, b)
    return a.memberIdx < b.memberIdx
end

-- ============================================================
-- INDICATOR ENTRY POOL
-- ============================================================
-- activeIndicators is a list of small tables, each describing one
-- tracked-aura indicator for a single frame update. Old code did
-- `tinsert(activeIndicators, { auraName=..., instanceKey=..., ... })`
-- at 2-4 sites per Engine:UpdateFrame call, allocating a fresh 7-8
-- field table per tinsert. For a Restoration Druid with ~15 tracked
-- auras and a few active at any given time, that's 3-10 fresh tables
-- per call at 1-5 calls/sec per unit in raid — a real contributor to
-- the 10-15 KB/call observed in UpdateAuras_Enhanced's profile row
-- after Fix A commit 4 landed.
--
-- Pool strategy: reuse entries across calls. At the start of each
-- Engine:UpdateFrame, return all entries from the previous run to
-- the pool before wiping activeIndicators. New entries come from
-- AcquireIndicatorEntry which either pulls from the pool or
-- allocates a single table.
--
-- Fields MUST be explicitly set by the caller — the acquire step
-- does not clear them, and stale values from a previous use would
-- leak if the caller relies on nil. The release step clears all
-- known fields so the table is safe to reuse.
local indicatorEntryPool = {}
local INDICATOR_POOL_MAX = 64  -- generous cap for any realistic AD config

local function AcquireIndicatorEntry()
    local n = #indicatorEntryPool
    if n > 0 then
        local entry = indicatorEntryPool[n]
        indicatorEntryPool[n] = nil
        return entry
    end
    return {}
end

local function ReleaseIndicatorEntry(entry)
    -- Clear all fields that any tinsert site sets — prevents stale
    -- values leaking when the entry is reused for a different code
    -- path (e.g. a placed-indicator entry being reused for a
    -- frame-level-indicator entry that doesn't have instanceKey).
    entry.auraName = nil
    entry.instanceKey = nil
    entry.typeKey = nil
    entry.placed = nil
    entry.config = nil
    entry.auraData = nil
    entry.isMissingAura = nil
    entry.priority = nil
    if #indicatorEntryPool < INDICATOR_POOL_MAX then
        indicatorEntryPool[#indicatorEntryPool + 1] = entry
    end
    -- else: drop the entry, let GC collect it (only if pool is saturated)
end

-- Release all entries currently in the active list and wipe it.
-- Called at the start of Engine:UpdateFrame before the new run
-- rebuilds the list.
local function ReleaseAndWipeActiveIndicators()
    for i = 1, #activeIndicators do
        ReleaseIndicatorEntry(activeIndicators[i])
    end
    wipe(activeIndicators)
end

-- ============================================================
-- INSTANCE KEY CACHE
-- ============================================================
-- `instanceKey` is the string "auraName#indicatorID" used by
-- Indicators:Configure/Apply for pool lookup and by the layout
-- group system for member identification. The old code built this
-- string fresh every call via concatenation — each concat allocates
-- a new Lua string.
--
-- Cache the string per (auraName, indicatorID) pair. For a typical
-- AD config the set of unique keys is small (one per indicator,
-- ~15-50 total) and never grows during normal play. After warmup,
-- GetInstanceKey is a pure two-level table lookup with zero
-- allocation.
local instanceKeyCache = {}  -- [auraName] = { [indicatorID] = "auraName#indicatorID" }

local function GetInstanceKey(auraName, indicatorID)
    local sub = instanceKeyCache[auraName]
    if not sub then
        sub = {}
        instanceKeyCache[auraName] = sub
    end
    local key = sub[indicatorID]
    if not key then
        key = auraName .. "#" .. indicatorID
        sub[indicatorID] = key
    end
    return key
end

-- ============================================================
-- LAYOUT GROUP RESOLUTION
-- Builds lookup tables for layout group membership and computes
-- which grouped indicators are currently active.
-- ============================================================

local function ResolveLayoutGroups(adDB, activeInds, spec)
    wipe(groupLookup)
    wipe(groupActiveMembers)

    local specGroups = adDB.layoutGroups and adDB.layoutGroups[spec]
    if not specGroups then return end

    -- Build lookup from all group members
    for _, group in ipairs(specGroups) do
        if group.members then
            groupActiveMembers[group.id] = {}
            for memberIdx, member in ipairs(group.members) do
                local key = member.auraName .. "#" .. member.indicatorID
                groupLookup[key] = { group = group, memberIdx = memberIdx }
            end
        end
    end

    -- Identify which group members are active (in display order)
    for _, ind in ipairs(activeInds) do
        if ind.placed and ind.instanceKey then
            local entry = groupLookup[ind.instanceKey]
            if entry and groupActiveMembers[entry.group.id] then
                tinsert(groupActiveMembers[entry.group.id], { indicator = ind, memberIdx = entry.memberIdx })
            end
        end
    end

    -- Sort each group's active members by their member order
    for _, actives in pairs(groupActiveMembers) do
        if #actives > 1 then
            sort(actives, memberIdxSort)
        end
    end
end

-- ============================================================
-- SYNTHETIC AURA DATA (Show When Missing)
-- ============================================================

local function buildSyntheticAuraData(auraName, spec)
    local spellIds = DF.AuraDesigner.SpellIDs and DF.AuraDesigner.SpellIDs[spec]
    local sidRaw = spellIds and spellIds[auraName]
    local sid = type(sidRaw) == "number" and sidRaw or (type(sidRaw) == "table" and sidRaw[1] or 0)
    local iconTextures = DF.AuraDesigner.IconTextures
    local icon = iconTextures and iconTextures[auraName] or 136243
    return {
        spellId = sid,
        icon = icon,
        duration = 0,
        expirationTime = 0,
        stacks = 0,
        caster = nil,
        auraInstanceID = nil,
        isMissingAura = true,
    }
end

-- Check if an aura is within its indicator's expiring threshold
local function IsAuraExpiring(auraData, config)
    if not config.expiringEnabled then return false end
    local duration = auraData.duration
    local expirationTime = auraData.expirationTime
    if not expirationTime or expirationTime == 0 or not duration or duration == 0 then
        return false  -- permanent aura, never expires
    end
    local remaining = expirationTime - GetTime()
    if remaining <= 0 then return false end
    local threshold = config.expiringThreshold or 5
    local mode = config.expiringThresholdMode or "PERCENT"
    if mode == "PERCENT" then
        return (remaining / duration * 100) <= threshold
    else
        return remaining <= threshold
    end
end

-- ============================================================
-- SPEC RESOLUTION
-- ============================================================

function Engine:ResolveSpec(adDB)
    if adDB.spec == "auto" then
        if not Adapter then
            Adapter = DF.AuraDesigner.Adapter
        end
        if not Adapter then return nil end
        return Adapter:GetPlayerSpec()
    end
    return adDB.spec
end

-- ============================================================
-- MAIN UPDATE FUNCTION
-- Called per frame from UpdateAuras when Aura Designer is enabled.
-- ============================================================

function Engine:UpdateFrame(frame)
    -- Lazy init references
    if not Adapter then
        Adapter = DF.AuraDesigner.Adapter
    end
    if not Indicators then
        Indicators = DF.AuraDesigner.Indicators
    end
    if not SoundEngine then
        SoundEngine = DF.AuraDesigner.SoundEngine
        if SoundEngine then
            SoundEngine:Init()
        end
    end
    if not Adapter or not Indicators then return end

    -- Skip invisible frames (e.g. disabled pinned frame children)
    if not frame:IsVisible() then return end

    local unit = frame.unit
    if not unit or not UnitExists(unit) then
        Indicators:HideAll(frame)
        return
    end

    local db = DF:GetFrameDB(frame)
    if not db then return end
    local adDB = db.auraDesigner
    if not adDB then return end

    local spec = self:ResolveSpec(adDB)
    if not spec then
        Indicators:HideAll(frame)
        return
    end

    -- Lazy migration: ensure spec-scoped format
    if (not adDB._specScopedV1 or not adDB._specScopedV2) and DF.MigrateAuraDesignerSpecScope then
        DF.MigrateAuraDesignerSpecScope(adDB)
    end

    -- Debug: throttled diagnostic dump
    local now = GetTime()
    local shouldLog = (now - debugLastLog) >= DEBUG_INTERVAL

    -- Query adapter for active auras on this unit
    local activeAuras = Adapter:GetUnitAuras(unit, spec)

    -- Spec-scoped aura configs
    local specAuras = adDB.auras and adDB.auras[spec]

    -- One-time cleanup: remove non-table entries (e.g. stray nextIndicatorID)
    if specAuras and not sanitizedSpecAuras[specAuras] then
        local toRemove
        for k, v in pairs(specAuras) do
            if type(v) ~= "table" then
                if not toRemove then toRemove = {} end
                toRemove[#toRemove + 1] = k
            end
        end
        if toRemove then
            for _, k in ipairs(toRemove) do
                specAuras[k] = nil
            end
        end
        sanitizedSpecAuras[specAuras] = true
    end

    if shouldLog then
        debugLastLog = now
        -- Count active auras from adapter
        local activeCount = 0
        for k in pairs(activeAuras) do activeCount = activeCount + 1 end
        -- Count configured auras and indicators
        local configCount = 0
        local configIndicators = 0
        if specAuras then
            for auraName, auraCfg in pairs(specAuras) do
                if type(auraCfg) == "table" then
                    configCount = configCount + 1
                    if auraCfg.indicators then
                        configIndicators = configIndicators + #auraCfg.indicators
                    end
                    for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
                        if auraCfg[typeDef.key] then configIndicators = configIndicators + 1 end
                    end
                end
            end
        end
        local providerName = Adapter:GetSourceName() or "none"
        DF:Debug("AD", "Engine: unit=%s spec=%s provider=%s active=%d configured=%d indicators=%d", unit, tostring(spec), providerName, activeCount, configCount, configIndicators)
        -- Log active aura names
        for auraName in pairs(activeAuras) do
            DF:Debug("AD", "  active: %s", auraName)
        end
        -- Log configured auras with their indicators
        if specAuras then
            for auraName, auraCfg in pairs(specAuras) do
                if type(auraCfg) == "table" then
                    local types = {}
                    if auraCfg.indicators then
                        for _, ind in ipairs(auraCfg.indicators) do
                            types[#types+1] = ind.type .. "#" .. ind.id
                        end
                    end
                    for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
                        local typeCfg = auraCfg[typeDef.key]
                        if typeCfg then
                            local trigStr = typeDef.key
                            if typeCfg.triggers and #typeCfg.triggers > 1 then
                                trigStr = trigStr .. "(triggers:" .. table.concat(typeCfg.triggers, ",") .. ")"
                            end
                            types[#types+1] = trigStr
                        end
                    end
                    DF:Debug("AD", "  config: %s -> %s", auraName, #types > 0 and table.concat(types, ", ") or "(no indicators)")
                end
            end
        end
    end

    -- Gather configured auras that are currently active.
    -- Release entries from the previous run back to the pool before
    -- wiping — they're small and reusable across every call.
    ReleaseAndWipeActiveIndicators()
    local auras = specAuras
    if auras then
        for auraName, auraCfg in pairs(auras) do
          if type(auraCfg) == "table" then
            local auraData = activeAuras[auraName]
            local wasBlacklisted = false
            if auraData then
                -- Skip blacklisted auras
                local blTable = DF.db and DF.db.auraBlacklist
                if blTable and auraData.spellId and not issecretvalue(auraData.spellId) and DF.AuraBlacklist and DF.AuraBlacklist.IsBlacklisted(blTable.buffs, auraData.spellId) then
                    auraData = nil
                    wasBlacklisted = true
                end
            end

            local priority = auraCfg.priority or 5

            -- Placed indicators (must run even without auraData for showWhenMissing)
            if auraCfg.indicators then
                for _, indicator in ipairs(auraCfg.indicators) do
                    local isMissing = not auraData
                    local wantMissing = indicator.showWhenMissing
                    -- Bar indicators don't support missing mode (no duration data)
                    if indicator.type == "bar" then wantMissing = false end
                    -- Blacklisted aura is present, don't treat as missing
                    if wantMissing and wasBlacklisted then wantMissing = false end

                    if wantMissing then
                        -- Always add: missing → synthetic, present → real (ticker handles expiring visibility)
                        local effectiveAuraData = auraData
                        if isMissing then
                            effectiveAuraData = buildSyntheticAuraData(auraName, spec)
                        end
                        local entry = AcquireIndicatorEntry()
                        entry.auraName      = auraName
                        entry.instanceKey   = GetInstanceKey(auraName, indicator.id)
                        entry.typeKey       = indicator.type
                        entry.placed        = true
                        entry.config        = indicator
                        entry.auraData      = effectiveAuraData
                        entry.isMissingAura = isMissing
                        entry.priority      = priority
                        tinsert(activeIndicators, entry)
                    elseif auraData then
                        local entry = AcquireIndicatorEntry()
                        entry.auraName    = auraName
                        entry.instanceKey = GetInstanceKey(auraName, indicator.id)
                        entry.typeKey     = indicator.type
                        entry.placed      = true
                        entry.config      = indicator
                        entry.auraData    = auraData
                        -- isMissingAura intentionally left nil (not a missing-aura entry)
                        entry.priority    = priority
                        tinsert(activeIndicators, entry)
                    end
                end
            end

            -- Frame-level indicators: check triggers array if present,
            -- otherwise fall back to owning aura only (legacy behavior)
            for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
                local typeCfg = auraCfg[typeDef.key]
                if typeCfg then
                    local triggerAuraData = nil
                    local triggers = typeCfg.triggers
                    if triggers then
                        local useAnd = typeCfg.triggerOperator == "AND"
                        local pickLowest = typeCfg.triggerDurationPriority ~= "HIGHEST"  -- LOWEST is default
                        if useAnd then
                            -- AND mode: fire only if ALL trigger auras are active.
                            local allActive = true
                            local bestRemaining = pickLowest and math.huge or -1
                            local candidate = nil
                            local secretFallback = nil  -- first active secret aura as fallback
                            for _, trigName in ipairs(triggers) do
                                local trigData = activeAuras[trigName]
                                if not trigData then
                                    allActive = false
                                    break
                                end
                                if trigData.secret then
                                    -- Secret aura: can't compare duration in Lua
                                    -- Keep as fallback only if no whitelist aura is found
                                    if not secretFallback then
                                        secretFallback = trigData
                                    end
                                else
                                    local expTime = trigData.expirationTime
                                    if not expTime or expTime == 0 then
                                        if not candidate then
                                            candidate = trigData
                                        end
                                        if not pickLowest then
                                            bestRemaining = math.huge
                                            candidate = trigData
                                        end
                                    else
                                        local remaining = expTime - now
                                        if pickLowest then
                                            if remaining < bestRemaining then
                                                bestRemaining = remaining
                                                candidate = trigData
                                            end
                                        else
                                            if remaining > bestRemaining then
                                                bestRemaining = remaining
                                                candidate = trigData
                                            end
                                        end
                                    end
                                end
                            end
                            if allActive then
                                triggerAuraData = candidate or secretFallback
                            end
                        else
                            -- OR mode (default): fire if ANY trigger aura is active.
                            local bestRemaining = pickLowest and math.huge or -1
                            local secretFallback = nil
                            for _, trigName in ipairs(triggers) do
                                local trigData = activeAuras[trigName]
                                if trigData then
                                    if trigData.secret then
                                        -- Secret aura: can't compare duration in Lua
                                        if not secretFallback then
                                            secretFallback = trigData
                                        end
                                    else
                                        local expTime = trigData.expirationTime
                                        if not expTime or expTime == 0 then
                                            if not pickLowest then
                                                triggerAuraData = trigData
                                                bestRemaining = math.huge
                                            elseif not triggerAuraData then
                                                triggerAuraData = trigData
                                            end
                                        else
                                            local remaining = expTime - now
                                            if pickLowest then
                                                if remaining < bestRemaining then
                                                    bestRemaining = remaining
                                                    triggerAuraData = trigData
                                                end
                                            else
                                                if remaining > bestRemaining then
                                                    bestRemaining = remaining
                                                    triggerAuraData = trigData
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            -- Use secret fallback only if no whitelist aura was picked
                            if not triggerAuraData and secretFallback then
                                triggerAuraData = secretFallback
                            end
                        end
                    else
                        -- Legacy: just use owning aura
                        triggerAuraData = auraData
                    end

                    local showWhenMissing = typeCfg.showWhenMissing
                    -- Blacklisted aura is present, don't treat as missing
                    if showWhenMissing and wasBlacklisted then showWhenMissing = false end

                    if showWhenMissing then
                        -- Always add: missing → synthetic, present → real (ticker handles expiring visibility)
                        local isTriggerMissing = not triggerAuraData
                        local effectiveTrigger = triggerAuraData
                        if isTriggerMissing then
                            effectiveTrigger = buildSyntheticAuraData(auraName, spec)
                        end
                        local entry = AcquireIndicatorEntry()
                        entry.auraName      = auraName
                        -- instanceKey intentionally left nil (frame-level indicator)
                        entry.typeKey       = typeDef.key
                        entry.placed        = false
                        entry.config        = typeCfg
                        entry.auraData      = effectiveTrigger
                        entry.isMissingAura = isTriggerMissing
                        entry.priority      = priority
                        tinsert(activeIndicators, entry)
                    elseif triggerAuraData then
                        local entry = AcquireIndicatorEntry()
                        entry.auraName    = auraName
                        -- instanceKey intentionally left nil (frame-level indicator)
                        entry.typeKey     = typeDef.key
                        entry.placed      = false
                        entry.config      = typeCfg
                        entry.auraData    = triggerAuraData
                        -- isMissingAura intentionally left nil
                        entry.priority    = priority
                        tinsert(activeIndicators, entry)
                    end
                end
            end
          end
        end
    end

    -- Expose active auraInstanceIDs on the frame for buff bar deduplication.
    -- Include auras with ANY indicator type (placed or frame-level) so the
    -- buff bar doesn't show duplicates of tracked auras.
    -- Also dedup trigger auras for multi-trigger frame effects.
    if not frame.dfAD_activeInstanceIDs then
        frame.dfAD_activeInstanceIDs = {}
    end
    wipe(frame.dfAD_activeInstanceIDs)
    if auras then
        for auraName, auraCfg in pairs(auras) do
          if type(auraCfg) == "table" then
            local auraData = activeAuras[auraName]
            if auraData and (auraData.auraInstanceID or auraData.dedupInstanceIDs) then
                local hasIndicator = auraCfg.indicators and #auraCfg.indicators > 0
                if not hasIndicator then
                    for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
                        if auraCfg[typeDef.key] then
                            hasIndicator = true
                            break
                        end
                    end
                end
                if hasIndicator then
                    if auraData.auraInstanceID then
                        frame.dfAD_activeInstanceIDs[auraData.auraInstanceID] = true
                    end
                    -- Dedup inferred aura target-side instance IDs (e.g. SR 474750/474760)
                    if auraData.dedupInstanceIDs then
                        for id in pairs(auraData.dedupInstanceIDs) do
                            frame.dfAD_activeInstanceIDs[id] = true
                        end
                    end
                end
            end
            -- Also mark trigger auras for dedup when multi-trigger is configured
            for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
                local typeCfg = auraCfg[typeDef.key]
                if typeCfg and typeCfg.triggers then
                    for _, trigName in ipairs(typeCfg.triggers) do
                        local trigData = activeAuras[trigName]
                        if trigData and trigData.auraInstanceID then
                            frame.dfAD_activeInstanceIDs[trigData.auraInstanceID] = true
                        end
                    end
                end
            end
          end
        end
    end

    -- Sort by priority (higher priority wins frame-level conflicts)
    if #activeIndicators > 1 then
        sort(activeIndicators, prioritySort)
    end

    if shouldLog then
        local inCombat = InCombatLockdown() and "yes" or "no"
        if #activeIndicators > 0 then
            DF:Debug("AD", "Dispatching %d indicators for %s (combat=%s)", #activeIndicators, unit, inCombat)
        else
            DF:Debug("AD", "No active indicators for %s (combat=%s)", unit, inCombat)
        end
    end

    -- Resolve layout group membership and compute active members
    ResolveLayoutGroups(adDB, activeIndicators, spec)

    -- Dispatch to indicator renderers
    Indicators:BeginFrame(frame)

    local setmetatable = setmetatable
    for _, ind in ipairs(activeIndicators) do
        -- Placed indicators use instanceKey (e.g., "Rejuvenation#1") for pool lookup
        -- Frame-level indicators use auraName
        local key = ind.placed and ind.instanceKey or ind.auraName
        local config = ind.config

        -- Check if this indicator belongs to a layout group
        if ind.placed and ind.instanceKey then
            local entry = groupLookup[ind.instanceKey]
            if entry then
                local group = entry.group
                local actives = groupActiveMembers[group.id]

                -- Find this indicator's position among active members
                local activeIdx = 0
                if actives then
                    for i, am in ipairs(actives) do
                        if am.indicator == ind then activeIdx = i - 1; break end
                    end
                end

                -- Compute offset based on grow direction + active index
                local size = config.size or (adDB.defaults and adDB.defaults.iconSize) or 24
                local scale = config.scale or (adDB.defaults and adDB.defaults.iconScale) or 1.0
                local step = (size * scale) + (group.spacing or 2)
                local oX, oY = ComputeGroupOffset(group, activeIdx, step, actives and #actives or 0)

                -- Create a lightweight metatable wrapper so we don't mutate saved config
                config = setmetatable({
                    anchor = group.anchor or "TOPLEFT",
                    offsetX = oX,
                    offsetY = oY,
                }, { __index = ind.config })
            end
        end

        -- Configure-once: only reconfigure when AD settings have changed
        if ind.typeKey == "icon" or ind.typeKey == "square" or ind.typeKey == "bar" then
            local indicatorFrame = nil
            if ind.typeKey == "icon" then
                indicatorFrame = frame.dfAD_icons and frame.dfAD_icons[key]
            elseif ind.typeKey == "square" then
                indicatorFrame = frame.dfAD_squares and frame.dfAD_squares[key]
            elseif ind.typeKey == "bar" then
                indicatorFrame = frame.dfAD_bars and frame.dfAD_bars[key]
            end
            -- Configure if version is stale.  Protected calls
            -- (SetPropagateMouseMotion/Clicks) are individually guarded inside
            -- each Configure function, so we can safely run Configure mid-combat
            -- to ensure indicators always have correct static settings (size,
            -- color, font, etc.) even when first seen during combat.
            if not indicatorFrame or indicatorFrame.dfAD_configVersion ~= (DF.adConfigVersion or 0) then
                Indicators:Configure(frame, ind.typeKey, config, adDB.defaults, key, ind.priority)
            end
        end

        Indicators:Apply(frame, ind.typeKey, config, ind.auraData, adDB.defaults, key, ind.priority)
    end

    -- Hide/revert anything not applied this frame
    Indicators:EndFrame(frame)
end

-- ============================================================
-- HIDE ALL INDICATORS
-- Called when Aura Designer is disabled or unit doesn't exist.
-- ============================================================

function Engine:ClearFrame(frame)
    if not Indicators then
        Indicators = DF.AuraDesigner.Indicators
    end
    if Indicators then
        Indicators:HideAll(frame)
    end
    -- Stop sound engine when AD is disabled
    if not SoundEngine then
        SoundEngine = DF.AuraDesigner.SoundEngine
    end
    if SoundEngine then
        SoundEngine:StopAll()
    end
    -- Clear active instance IDs so buff bar dedup doesn't stale-filter
    if frame.dfAD_activeInstanceIDs then
        wipe(frame.dfAD_activeInstanceIDs)
    end
end

-- ============================================================
-- TEST MODE UPDATE
-- Renders AD indicators on test frames using mock aura data
-- built from the user's configured auras for their spec.
-- ============================================================

function Engine:UpdateTestFrame(frame)
    -- Lazy init references
    if not Adapter then
        Adapter = DF.AuraDesigner.Adapter
    end
    if not Indicators then
        Indicators = DF.AuraDesigner.Indicators
    end
    if not Indicators then return end

    -- Skip invisible frames (e.g. disabled pinned frame children)
    if not frame:IsVisible() then return end

    local db = DF:GetFrameDB(frame)
    if not db then return end
    local adDB = db.auraDesigner
    if not adDB or not adDB.enabled then
        Indicators:HideAll(frame)
        return
    end

    local spec = self:ResolveSpec(adDB)
    if not spec then
        Indicators:HideAll(frame)
        return
    end

    -- Lazy migration
    if (not adDB._specScopedV1 or not adDB._specScopedV2) and DF.MigrateAuraDesignerSpecScope then
        DF.MigrateAuraDesignerSpecScope(adDB)
    end

    local specAuras = adDB.auras and adDB.auras[spec]
    if not specAuras then
        Indicators:HideAll(frame)
        return
    end

    -- Build mock activeAuras from configured auras
    local specSpellIDs = DF.AuraDesigner.SpellIDs and DF.AuraDesigner.SpellIDs[spec] or {}
    local iconTextures = DF.AuraDesigner.IconTextures or {}
    local now = GetTime()
    local mockCounter = 99000

    -- Release entries from the previous call back to the pool before
    -- rebuilding. Same pattern as Engine:UpdateFrame.
    ReleaseAndWipeActiveIndicators()

    for auraName, auraCfg in pairs(specAuras) do
      if type(auraCfg) == "table" then
        -- Build mock aura data for this configured aura
        local spellId = specSpellIDs[auraName] or 0
        local icon = iconTextures[auraName]
        if not icon and spellId > 0 and C_Spell and C_Spell.GetSpellTexture then
            icon = C_Spell.GetSpellTexture(spellId)
        end
        mockCounter = mockCounter + 1

        local auraData = {
            spellId = spellId,
            icon = icon or 136243,  -- question mark fallback
            duration = 0,           -- 0 = permanent (bars show full fill, no countdown)
            expirationTime = 0,
            stacks = 0,
            caster = "player",
            auraInstanceID = nil,   -- nil so bar OnUpdate skips expiration guard
        }

        local priority = auraCfg.priority or 5

        -- Check if ALL indicators want missing mode — if so, nil out mock data
        -- so showWhenMissing indicators render in test mode
        local allMissing = true
        if auraCfg.indicators then
            for _, indicator in ipairs(auraCfg.indicators) do
                if not indicator.showWhenMissing or indicator.type == "bar" then
                    allMissing = false
                    break
                end
            end
        else
            allMissing = false
        end
        if allMissing then
            for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
                local typeCfg = auraCfg[typeDef.key]
                if typeCfg and not typeCfg.showWhenMissing then
                    allMissing = false
                    break
                end
            end
        end
        if allMissing then
            auraData = nil
        end

        -- Placed indicators (handles showWhenMissing)
        if auraCfg.indicators then
            for _, indicator in ipairs(auraCfg.indicators) do
                local isMissing = not auraData
                local wantMissing = indicator.showWhenMissing
                if indicator.type == "bar" then wantMissing = false end

                if wantMissing then
                    -- Always add: missing → synthetic, present → real (Apply handles visibility)
                    local effectiveAuraData = auraData
                    if isMissing then
                        effectiveAuraData = buildSyntheticAuraData(auraName, spec)
                    end
                    local entry = AcquireIndicatorEntry()
                    entry.auraName      = auraName
                    entry.instanceKey   = GetInstanceKey(auraName, indicator.id)
                    entry.typeKey       = indicator.type
                    entry.placed        = true
                    entry.config        = indicator
                    entry.auraData      = effectiveAuraData
                    entry.isMissingAura = isMissing
                    entry.priority      = priority
                    tinsert(activeIndicators, entry)
                elseif auraData then
                    local entry = AcquireIndicatorEntry()
                    entry.auraName    = auraName
                    entry.instanceKey = GetInstanceKey(auraName, indicator.id)
                    entry.typeKey     = indicator.type
                    entry.placed      = true
                    entry.config      = indicator
                    entry.auraData    = auraData
                    -- isMissingAura intentionally left nil
                    entry.priority    = priority
                    tinsert(activeIndicators, entry)
                end
            end
        end

        -- Frame-level indicators (handles showWhenMissing)
        for _, typeDef in ipairs(FRAME_LEVEL_TYPES) do
            local typeCfg = auraCfg[typeDef.key]
            if typeCfg then
                local wantMissing = typeCfg.showWhenMissing
                local isMissing = not auraData
                if wantMissing then
                    -- Always add: missing → synthetic, present → real (Apply handles visibility)
                    local effectiveAuraData = auraData
                    if isMissing then
                        effectiveAuraData = buildSyntheticAuraData(auraName, spec)
                    end
                    local entry = AcquireIndicatorEntry()
                    entry.auraName    = auraName
                    -- instanceKey intentionally left nil (frame-level indicator)
                    entry.typeKey     = typeDef.key
                    entry.placed      = false
                    entry.config      = typeCfg
                    entry.auraData    = effectiveAuraData
                    -- isMissingAura intentionally left nil (legacy test-mode behavior
                    -- didn't set this — matches the pre-refactor state)
                    entry.priority    = priority
                    tinsert(activeIndicators, entry)
                elseif auraData then
                    local entry = AcquireIndicatorEntry()
                    entry.auraName    = auraName
                    -- instanceKey intentionally left nil (frame-level indicator)
                    entry.typeKey     = typeDef.key
                    entry.placed      = false
                    entry.config      = typeCfg
                    entry.auraData    = auraData
                    -- isMissingAura intentionally left nil
                    entry.priority    = priority
                    tinsert(activeIndicators, entry)
                end
            end
        end
      end
    end

    -- Sort by priority
    if #activeIndicators > 1 then
        sort(activeIndicators, prioritySort)
    end

    -- Resolve layout groups
    ResolveLayoutGroups(adDB, activeIndicators, spec)

    -- Dispatch to indicator renderers (using ApplyTest to skip aura validation)
    Indicators:BeginFrame(frame)

    local setmetatable = setmetatable
    for _, ind in ipairs(activeIndicators) do
        local key = ind.placed and ind.instanceKey or ind.auraName
        local config = ind.config

        -- Layout group position override (same as production)
        if ind.placed and ind.instanceKey then
            local entry = groupLookup[ind.instanceKey]
            if entry then
                local group = entry.group
                local actives = groupActiveMembers[group.id]
                local activeIdx = 0
                if actives then
                    for i, am in ipairs(actives) do
                        if am.indicator == ind then activeIdx = i - 1; break end
                    end
                end
                local size = config.size or (adDB.defaults and adDB.defaults.iconSize) or 24
                local scale = config.scale or (adDB.defaults and adDB.defaults.iconScale) or 1.0
                local step = (size * scale) + (group.spacing or 2)
                local oX, oY = ComputeGroupOffset(group, activeIdx, step, actives and #actives or 0)
                config = setmetatable({
                    anchor = group.anchor or "TOPLEFT",
                    offsetX = oX,
                    offsetY = oY,
                }, { __index = ind.config })
            end
        end

        Indicators:ApplyTest(frame, ind.typeKey, config, ind.auraData, adDB.defaults, key, ind.priority)
    end

    Indicators:EndFrame(frame)
end

-- ============================================================
-- PRE-WARM INDICATOR FRAMES
-- Pre-creates and configures all indicator frames defined in
-- AD config so they are ready before combat. This ensures
-- SetPropagateMouseMotion/Clicks (protected functions) are
-- called outside combat, avoiding ADDON_ACTION_BLOCKED errors.
-- ============================================================

function Engine:PreWarmIndicators(frame)
    if not Adapter then
        Adapter = DF.AuraDesigner.Adapter
    end
    if not Adapter then return end
    if not Indicators then
        Indicators = DF.AuraDesigner.Indicators
    end
    if not Indicators then return end

    local db = DF:GetFrameDB(frame)
    if not db then return end
    local adDB = db.auraDesigner
    if not adDB then return end

    -- Resolve spec
    local spec = self:ResolveSpec(adDB)
    if not spec then return end

    local specAuras = adDB.auras and adDB.auras[spec]
    if not specAuras then return end

    -- Iterate all configured auras and their placed indicators
    for auraName, auraCfg in pairs(specAuras) do
        if type(auraCfg) == "table" and auraCfg.indicators then
            for _, indicator in ipairs(auraCfg.indicators) do
                local typeKey = indicator.type
                if typeKey == "icon" or typeKey == "square" or typeKey == "bar" then
                    local key = auraName .. "#" .. indicator.id
                    Indicators:Configure(frame, typeKey, indicator, adDB.defaults, key, auraCfg.priority or 5)
                end
            end
        end
    end
end

-- ============================================================
-- FORCE REFRESH ALL AD-ENABLED FRAMES
-- Re-runs UpdateFrame on every visible AD frame so changed
-- global defaults (fonts, sizes, etc.) take effect immediately.
-- ============================================================

function Engine:ForceRefreshAllFrames()
    -- Bump config version so all indicators reconfigure on next UpdateFrame
    DF.adConfigVersion = (DF.adConfigVersion or 0) + 1

    -- Pre-warm: create and configure all indicator frames outside combat
    -- so SetPropagateMouseMotion/Clicks are set before combat starts
    local function TryPreWarm(frame)
        if frame and DF:IsAuraDesignerEnabled(frame) then
            Engine:PreWarmIndicators(frame)
        end
    end

    if not InCombatLockdown() then
        if DF.IteratePartyFrames then
            DF:IteratePartyFrames(TryPreWarm)
        end
        if DF.IterateRaidFrames then
            DF:IterateRaidFrames(TryPreWarm)
        end
        if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
            for setIndex = 1, 2 do
                local header = DF.PinnedFrames.headers[setIndex]
                if header and header:IsShown() then
                    for i = 1, 40 do
                        local child = header:GetAttribute("child" .. i)
                        if child then TryPreWarm(child) end
                    end
                end
            end
        end
    end

    local function TryUpdate(frame)
        if frame and frame:IsVisible() and DF:IsAuraDesignerEnabled(frame) then
            Engine:UpdateFrame(frame)
        end
    end

    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(TryUpdate)
    end
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(TryUpdate)
    end

    -- Also refresh pinned frames
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header and header:IsShown() then
                for i = 1, 40 do
                    local child = header:GetAttribute("child" .. i)
                    if child then TryUpdate(child) end
                end
            end
        end
    end
end
