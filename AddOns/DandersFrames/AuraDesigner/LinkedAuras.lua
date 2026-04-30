local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER - LINKED AURA INFERENCE
-- Handles auras where only one side (caster or target) has a
-- readable spell ID, and infers the other side.
--
-- Currently supports:
--   caster_to_target: Player has readable source buff (e.g.
--     Symbiotic Relationship 474754), infer onto target by
--     scanning for the target-side buff OOC or parsing tooltip.
-- ============================================================

-- ============================================================
-- LOCAL CACHES
-- ============================================================

local pairs, ipairs, wipe, type = pairs, ipairs, wipe, type
local GetTime = GetTime
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local InCombatLockdown = InCombatLockdown
local issecretvalue = issecretvalue or function() return false end

local C_UnitAuras = C_UnitAuras
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras
local GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID
local GetSpecialization = GetSpecialization or C_SpecializationInfo and C_SpecializationInfo.GetSpecialization

-- ============================================================
-- MODULE TABLE
-- ============================================================

DF.AuraDesigner = DF.AuraDesigner or {}
local LinkedAuras = {}
DF.AuraDesigner.LinkedAuras = LinkedAuras

-- ============================================================
-- RUNTIME STATE
-- ============================================================

local state = {
    spec = nil,
    -- Symbiotic Relationship: caster → target inference
    sr = {
        targetUnit = nil,           -- e.g. "party2"
        targetName = nil,           -- character name for re-mapping on roster change
        sourceAuraData = nil,       -- player's 474754 aura data (set by adapter)
        sourceInstanceID = nil,     -- auraInstanceID of player's 474754
        cachedInstanceIDs = {},     -- { [auraInstanceID] = true } for target-side buffs (dedup)
    },
}

-- Forward references to config (set in Init)
local LinkedAuraRules   -- DF.AuraDesigner.LinkedAuraRules
local SpellIDs          -- DF.AuraDesigner.SpellIDs
local IconTextures      -- DF.AuraDesigner.IconTextures

-- Debug throttle
local debugLastLog = 0
local DEBUG_INTERVAL = 3

-- ============================================================
-- SPEC RESOLUTION
-- ============================================================

local function UpdatePlayerSpec()
    local _, englishClass = UnitClass("player")
    local specIndex = GetSpecialization and GetSpecialization() or nil
    if not englishClass or not specIndex then
        state.spec = nil
        return
    end
    local key = englishClass .. "_" .. specIndex
    state.spec = DF.AuraDesigner.SpecMap and DF.AuraDesigner.SpecMap[key]
end

-- Forward declarations for functions defined later
local ResolveSRTarget

-- ============================================================
-- INITIAL SCAN
-- On login/reload, check if SR or EM auras are already active.
-- Delayed slightly so aura data is available.
-- ============================================================

local function InitialScan()
    if not LinkedAuraRules or not state.spec then return end

    -- SR: check if player already has 474754
    local srRules = LinkedAuraRules[state.spec]
    if srRules and srRules.SymbioticRelationship then
        local sourceSpellID = srRules.SymbioticRelationship.sourceSpellID
        if sourceSpellID and GetUnitAuras then
            local auras = GetUnitAuras("player", "HELPFUL", 100)
            if auras then
                for _, auraData in ipairs(auras) do
                    local sid = auraData.spellId
                    if sid and not issecretvalue(sid) and sid == sourceSpellID then
                        state.sr.sourceInstanceID = auraData.auraInstanceID
                        state.sr.sourceAuraData = {
                            spellId = sid,
                            icon = auraData.icon,
                            duration = auraData.duration,
                            expirationTime = auraData.expirationTime,
                            stacks = auraData.applications or 0,
                            caster = auraData.sourceUnit,
                            auraInstanceID = auraData.auraInstanceID,
                            selfOnly = true,
                        }
                        DF:Debug("AD", "LinkedAuras: SR source found on login (instanceID=%s)", tostring(auraData.auraInstanceID))
                        ResolveSRTarget()
                        break
                    end
                end
            end
        end
    end

end

-- ============================================================
-- FORCE REFRESH
-- Triggers an immediate re-render of all AD frames so inferred
-- aura changes (target gained/lost) are reflected instantly.
-- ============================================================

local function ForceRefresh()
    local Engine = DF.AuraDesigner.Engine
    if Engine and Engine.ForceRefreshAllFrames then
        Engine:ForceRefreshAllFrames()
    end
    -- Also refresh buff bars so dedup changes (dfAD_activeInstanceIDs) take effect
    if DF.UpdateAuras_Enhanced then
        local function RefreshAuras(frame)
            if frame and frame:IsVisible() and frame.unit and UnitExists(frame.unit) then
                DF:UpdateAuras_Enhanced(frame)
            end
        end
        if DF.IteratePartyFrames then DF:IteratePartyFrames(RefreshAuras) end
        if DF.IterateRaidFrames then DF:IterateRaidFrames(RefreshAuras) end
    end
end

-- ============================================================
-- SYMBIOTIC RELATIONSHIP - TARGET RESOLUTION
-- ============================================================

-- Build a fast lookup set from targetSpellIDs config
local srTargetIDSet = nil
local function GetSRTargetIDSet()
    if srTargetIDSet then return srTargetIDSet end
    local rules = LinkedAuraRules and LinkedAuraRules.RestorationDruid
    local ids = rules and rules.SymbioticRelationship and rules.SymbioticRelationship.targetSpellIDs
    if not ids then return nil end
    srTargetIDSet = {}
    for _, id in ipairs(ids) do
        srTargetIDSet[id] = true
    end
    return srTargetIDSet
end

-- Strategy 1: OOC direct scan — scan party members for target-side buffs
local function ResolveSRTargetDirect()
    local idSet = GetSRTargetIDSet()
    if not idSet then return end

    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local auras = GetUnitAuras and GetUnitAuras(unit, "HELPFUL", 100)
            if auras then
                local found = false
                wipe(state.sr.cachedInstanceIDs)
                for _, auraData in ipairs(auras) do
                    local sid = auraData.spellId
                    if sid and not issecretvalue(sid) and idSet[sid] then
                        state.sr.cachedInstanceIDs[auraData.auraInstanceID] = true
                        found = true
                    end
                end
                if found then
                    state.sr.targetUnit = unit
                    state.sr.targetName = UnitName(unit)
                    DF:Debug("AD", "LinkedAuras: SR target resolved (direct): %s (%s)", tostring(state.sr.targetName), unit)
                    return true
                end
            end
        end
    end
    return false
end

-- Strategy 2: Tooltip parsing — read tooltip of player's 474754
local function ResolveSRTargetTooltip()
    if not state.sr.sourceInstanceID then return false end
    if not C_TooltipInfo or not C_TooltipInfo.GetUnitAura then return false end

    -- Find the buff index for our auraInstanceID
    local buffIndex = nil
    for i = 1, 40 do
        local aura = GetAuraDataByIndex and GetAuraDataByIndex("player", i, "HELPFUL")
        if not aura then break end
        if aura.auraInstanceID == state.sr.sourceInstanceID then
            buffIndex = i
            break
        end
    end
    if not buffIndex then return false end

    local tooltipData = C_TooltipInfo.GetUnitAura("player", buffIndex, "HELPFUL")
    if not tooltipData or not tooltipData.lines then return false end

    -- Match party member names in tooltip text
    for _, line in ipairs(tooltipData.lines) do
        local text = line.leftText
        if text then
            for i = 1, 4 do
                local unit = "party" .. i
                if UnitExists(unit) then
                    local name = UnitName(unit)
                    if name and text:find(name, 1, true) then
                        state.sr.targetUnit = unit
                        state.sr.targetName = name
                        DF:Debug("AD", "LinkedAuras: SR target resolved (tooltip): %s (%s)", name, unit)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Attempt to resolve SR target using best available strategy
ResolveSRTarget = function()
    local hadTarget = state.sr.targetUnit
    -- Prefer direct scan when OOC (474750 is readable)
    if not InCombatLockdown() then
        if ResolveSRTargetDirect() then
            ForceRefresh()
            return
        end
    end
    -- Fallback: tooltip parsing (works in and out of combat)
    if ResolveSRTargetTooltip() then
        ForceRefresh()
        return
    end
    -- Target was cleared but not re-resolved — refresh to hide old indicators
    if hadTarget and not state.sr.targetUnit then
        ForceRefresh()
    end
end

-- Re-map SR target unit token by name after roster change
local function RemapSRTarget()
    if not state.sr.targetName then return end
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and UnitName(unit) == state.sr.targetName then
            if state.sr.targetUnit ~= unit then
                DF:Debug("AD", "LinkedAuras: SR target remapped: %s -> %s", tostring(state.sr.targetUnit), unit)
                state.sr.targetUnit = unit
            end
            return
        end
    end
    -- Target no longer in group
    DF:Debug("AD", "LinkedAuras: SR target %s no longer in group, clearing", tostring(state.sr.targetName))
    state.sr.targetUnit = nil
    state.sr.targetName = nil
    wipe(state.sr.cachedInstanceIDs)
end

-- ============================================================
-- PUBLIC API
-- Called by AuraAdapter to set source aura data for SR
-- ============================================================

-- SR recast threshold: if remaining duration jumps above this,
-- it was recast (fresh 1-hour duration = 3600s)
local SR_RECAST_THRESHOLD = 3500

function LinkedAuras:SetSourceAura(auraName, auraData)
    if auraName == "SymbioticRelationship" then
        local oldData = state.sr.sourceAuraData
        state.sr.sourceAuraData = auraData
        local newInstanceID = auraData and auraData.auraInstanceID

        -- Detect recast: auraInstanceID changed OR duration jumped back to ~1 hour
        local recast = false
        if newInstanceID ~= state.sr.sourceInstanceID then
            recast = true
        elseif oldData and auraData then
            local oldRemaining = oldData.expirationTime and (oldData.expirationTime - GetTime()) or 0
            local newRemaining = auraData.expirationTime and (auraData.expirationTime - GetTime()) or 0
            if newRemaining > SR_RECAST_THRESHOLD and oldRemaining < SR_RECAST_THRESHOLD then
                recast = true
            end
        end

        if recast then
            -- Clear old target before resolving new one
            local oldTarget = state.sr.targetUnit
            state.sr.sourceInstanceID = newInstanceID
            state.sr.targetUnit = nil
            state.sr.targetName = nil
            wipe(state.sr.cachedInstanceIDs)
            if oldTarget then
                DF:Debug("AD", "LinkedAuras: SR recast detected, cleared old target %s", oldTarget)
            end
            ResolveSRTarget()
        elseif not state.sr.targetUnit and newInstanceID then
            -- Have source but no target yet — retry resolution
            ResolveSRTarget()
        end
    end
end

-- Called when SR source aura is no longer present on player
function LinkedAuras:ClearSourceAura(auraName)
    if auraName == "SymbioticRelationship" then
        local hadTarget = state.sr.targetUnit
        state.sr.sourceAuraData = nil
        state.sr.sourceInstanceID = nil
        state.sr.targetUnit = nil
        state.sr.targetName = nil
        wipe(state.sr.cachedInstanceIDs)
        if hadTarget then
            ForceRefresh()
        end
    end
end

-- ============================================================
-- PUBLIC API - GetUnitAuras
-- Returns inferred auras for a unit, merged by AuraAdapter.
-- ============================================================

function LinkedAuras:GetUnitAuras(unit, spec)
    if not unit or not spec then return nil end
    if not LinkedAuraRules then return nil end

    local result = nil

    -- SR: if this unit is the inferred target, return mirrored aura
    local srRules = LinkedAuraRules[spec]
    if srRules and srRules.SymbioticRelationship and srRules.SymbioticRelationship.type == "caster_to_target" then
        if state.sr.targetUnit and state.sr.sourceAuraData and UnitIsUnit(unit, state.sr.targetUnit) then
            local src = state.sr.sourceAuraData
            result = result or {}
            result["SymbioticRelationship"] = {
                spellId = srRules.SymbioticRelationship.sourceSpellID,
                icon = IconTextures and IconTextures["SymbioticRelationship"] or src.icon,
                duration = src.duration,
                expirationTime = src.expirationTime,
                stacks = src.stacks or 0,
                caster = "player",
                auraInstanceID = nil,
                inferred = true,
                dedupInstanceIDs = state.sr.cachedInstanceIDs,
            }
        end
    end

    return result
end

-- ============================================================
-- EVENT HANDLING
-- ============================================================

local eventFrame = CreateFrame("Frame")

local function OnEvent(self, event, ...)
    if event == "UNIT_AURA" then
        local unit, updateInfo = ...
        if not unit or not UnitExists(unit) then return end

        -- SR: track source aura on player via UNIT_AURA
        if state.spec == "RestorationDruid" and UnitIsUnit(unit, "player") then
            local rules = LinkedAuraRules and LinkedAuraRules.RestorationDruid
            local sourceSpellID = rules and rules.SymbioticRelationship and rules.SymbioticRelationship.sourceSpellID

            -- Detect removal of source aura
            if state.sr.sourceInstanceID and updateInfo and updateInfo.removedAuraInstanceIDs then
                for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
                    if id == state.sr.sourceInstanceID then
                        LinkedAuras:ClearSourceAura("SymbioticRelationship")
                        break
                    end
                end
            end

            -- Detect addition or update of source aura (474754)
            if sourceSpellID and updateInfo then
                -- Check added auras
                if updateInfo.addedAuras then
                    for _, aura in ipairs(updateInfo.addedAuras) do
                        local sid = aura.spellId
                        if sid and not issecretvalue(sid) and sid == sourceSpellID then
                            local isRecast = state.sr.sourceInstanceID and aura.auraInstanceID ~= state.sr.sourceInstanceID
                            if isRecast and state.sr.targetUnit then
                                -- Clear old target immediately and refresh to hide old indicators
                                DF:Debug("AD", "LinkedAuras: SR recast detected (new instance), cleared old target %s", tostring(state.sr.targetUnit))
                                state.sr.targetUnit = nil
                                state.sr.targetName = nil
                                wipe(state.sr.cachedInstanceIDs)
                                ForceRefresh()
                            end
                            state.sr.sourceInstanceID = aura.auraInstanceID
                            state.sr.sourceAuraData = {
                                spellId = sid,
                                icon = aura.icon,
                                duration = aura.duration,
                                expirationTime = aura.expirationTime,
                                stacks = aura.applications or 0,
                                caster = aura.sourceUnit,
                                auraInstanceID = aura.auraInstanceID,
                                selfOnly = true,
                            }
                            ResolveSRTarget()
                        end
                    end
                end

                -- Check updated auras for duration reset (recast with same instance)
                if updateInfo.updatedAuraInstanceIDs and state.sr.sourceInstanceID then
                    for _, id in ipairs(updateInfo.updatedAuraInstanceIDs) do
                        if id == state.sr.sourceInstanceID then
                            local live = GetAuraDataByAuraInstanceID and GetAuraDataByAuraInstanceID("player", id)
                            if live then
                                local remaining = live.expirationTime and (live.expirationTime - GetTime()) or 0
                                local oldRemaining = state.sr.sourceAuraData and state.sr.sourceAuraData.expirationTime
                                    and (state.sr.sourceAuraData.expirationTime - GetTime()) or 0
                                -- Duration jumped back to near 1 hour = recast
                                if remaining > SR_RECAST_THRESHOLD and oldRemaining < SR_RECAST_THRESHOLD then
                                    if state.sr.targetUnit then
                                        DF:Debug("AD", "LinkedAuras: SR recast detected (duration reset), cleared old target %s", tostring(state.sr.targetUnit))
                                        state.sr.targetUnit = nil
                                        state.sr.targetName = nil
                                        wipe(state.sr.cachedInstanceIDs)
                                        ForceRefresh()
                                    end
                                end
                                -- Update cached source data
                                state.sr.sourceAuraData = {
                                    spellId = live.spellId,
                                    icon = live.icon,
                                    duration = live.duration,
                                    expirationTime = live.expirationTime,
                                    stacks = live.applications or 0,
                                    caster = live.sourceUnit,
                                    auraInstanceID = id,
                                    selfOnly = true,
                                }
                                if not state.sr.targetUnit then
                                    ResolveSRTarget()
                                end
                            end
                            break
                        end
                    end
                end
            end
        end

    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        -- Combat transition: force refresh all AD frames so blacklist
        -- combat/ooc rules re-evaluate immediately
        ForceRefresh()

        -- Leaving combat: re-resolve SR target and cache target-side instance IDs
        if event == "PLAYER_REGEN_ENABLED" then
            if state.spec == "RestorationDruid" and state.sr.sourceAuraData then
                ResolveSRTarget()
            end
        end

    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Re-map SR target by name
        if state.sr.targetName then
            RemapSRTarget()
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        UpdatePlayerSpec()
        -- Wipe all state on spec change
        state.sr.targetUnit = nil
        state.sr.targetName = nil
        state.sr.sourceAuraData = nil
        state.sr.sourceInstanceID = nil
        wipe(state.sr.cachedInstanceIDs)

    elseif event == "PLAYER_LOGIN" then
        LinkedAuraRules = DF.AuraDesigner.LinkedAuraRules
        SpellIDs = DF.AuraDesigner.SpellIDs
        IconTextures = DF.AuraDesigner.IconTextures
        UpdatePlayerSpec()
        -- Delayed initial scan: auras may not be available immediately on login
        C_Timer.After(1, InitialScan)
    end
end

eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
