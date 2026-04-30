local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER - SECRET AURA TRACKING
-- Identifies auras with secret spell IDs using filter fingerprinting
-- and cast tracking. Secret auras are those Blizzard does not
-- whitelist — their spellId is an opaque secret value at runtime.
--
-- This module uses two techniques to identify them:
--   1. Filter fingerprinting — each aura has a unique combination
--      of which WoW filter strings it passes (RAID, RAID_IN_COMBAT,
--      EXTERNAL_DEFENSIVE, RAID_PLAYER_DISPELLABLE). The 4-filter
--      result forms a signature string (e.g. "1:1:1:0") that maps
--      to a known aura name via hash lookup.
--   2. Spec-specific engines — for specs where signatures overlap,
--      custom logic disambiguates (e.g. VerdantEmbrace vs Lifebind).
--
-- Credit: Filter fingerprinting technique and aura data derived from
-- Harrek's Advanced Raid Frames (used with permission).
-- https://www.curseforge.com/wow/addons/harreks-advanced-raid-frames
-- ============================================================

-- ============================================================
-- LOCAL CACHES
-- ============================================================

local pairs, ipairs, wipe, type = pairs, ipairs, wipe, type
local GetTime = GetTime
local issecretvalue = issecretvalue or function() return false end
local canaccesstable = canaccesstable or function() return true end

local C_UnitAuras = C_UnitAuras
local IsAuraFilteredOutByInstanceID = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras
local C_Timer = C_Timer
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitClassBase = UnitClassBase
local GetSpecialization = GetSpecialization or C_SpecializationInfo and C_SpecializationInfo.GetSpecialization

-- ============================================================
-- MODULE TABLE
-- ============================================================

local SecretAuras = {}
DF.AuraDesigner.SecretAuras = SecretAuras

-- ============================================================
-- RUNTIME STATE
-- Tracks cast timestamps, identified auras per unit, and
-- spec-specific disambiguation data.
-- ============================================================

local state = {
    casts   = {},       -- [castSpellId] = GetTime() timestamp
    auras   = {},       -- [unit] = { [auraInstanceID] = "AuraName" }
    extras  = {},       -- spec-specific disambiguation state
    spec    = nil,      -- current player spec key (e.g. "RestorationDruid")
}

-- Forward reference to config data (set in Init)
local SecretAuraInfo    -- DF.AuraDesigner.SecretAuraInfo
local SpellIDs          -- DF.AuraDesigner.SpellIDs
local IconTextures      -- DF.AuraDesigner.IconTextures

-- Signature lookup cache: [spec] = { ["1:1:1:0"] = "AuraName", ... }
-- Built once per spec from SecretAuraInfo, only includes secret auras.
-- Credit: Signature approach from Harrek's Advanced Raid Frames.
local signatureCache = {}

-- ============================================================
-- SIGNATURE HELPERS
-- Builds a 4-character signature string from filter results and
-- looks it up in a per-spec hash table for O(1) matching.
-- Credit: MakeAuraSignature / GetAuraSignatures from Harrek's ARF.
-- ============================================================

local FILTER_RAID     = "PLAYER|HELPFUL|RAID"
local FILTER_RIC      = "PLAYER|HELPFUL|RAID_IN_COMBAT"
local FILTER_EXT      = "PLAYER|HELPFUL|EXTERNAL_DEFENSIVE"
local FILTER_DISP     = "PLAYER|HELPFUL|RAID_PLAYER_DISPELLABLE"

--- Build a signature string from 4 filter booleans.
-- @return string e.g. "1:1:0:0"
local function MakeAuraSignature(passesRaid, passesRic, passesExt, passesDisp)
    return (passesRaid and "1" or "0") .. ":" .. (passesRic and "1" or "0") .. ":"
        .. (passesExt and "1" or "0") .. ":" .. (passesDisp and "1" or "0")
end

--- Get or build the signature → auraName lookup for a spec.
-- Only includes auras with a non-empty signature field.
local function GetAuraSignatures(spec)
    if signatureCache[spec] then return signatureCache[spec] end

    local signatures = {}
    local specData = SecretAuraInfo and SecretAuraInfo[spec]
    if specData and specData.auras then
        for auraName, auraData in pairs(specData.auras) do
            local sig = auraData.signature
            if sig and sig ~= "" then
                signatures[sig] = auraName
            end
        end
    end
    signatureCache[spec] = signatures
    return signatures
end

--- Check if an aura passes at least one player filter (RAID or RAID_IN_COMBAT).
-- This confirms the aura is from the player and not random noise.
-- Credit: IsAuraFromPlayer pattern from Harrek's Advanced Raid Frames.
local function IsAuraFromPlayer(unit, auraInstanceID)
    if not IsAuraFilteredOutByInstanceID then return false end
    local passesRaid = not IsAuraFilteredOutByInstanceID(unit, auraInstanceID, FILTER_RAID)
    local passesRic  = not IsAuraFilteredOutByInstanceID(unit, auraInstanceID, FILTER_RIC)
    return passesRaid or passesRic
end

--- Match an aura against known secret signatures for the given spec.
-- Uses canaccesstable/issecretvalue to skip non-secret auras (handled
-- by AuraAdapter's whitelisted path), then builds a filter signature
-- and looks it up in the spec's hash table.
-- Credit: MatchAuraInfo approach from Harrek's Advanced Raid Frames.
-- @param unit  Unit token (e.g. "party1")
-- @param aura  AuraData table (must have .auraInstanceID)
-- @param spec  Spec key (e.g. "PreservationEvoker")
-- @return auraName String name of matched aura, or nil
local function MatchAuraSignature(unit, aura, spec)
    if not IsAuraFilteredOutByInstanceID then return nil end
    if not aura or not aura.auraInstanceID then return nil end

    -- Skip non-secret auras — AuraAdapter handles those via spell ID
    if canaccesstable(aura) and not issecretvalue(aura.spellId) then
        return nil
    end

    local instanceID = aura.auraInstanceID

    -- Early exit: must pass at least RAID or RIC to be a player aura
    local passesRaid = not IsAuraFilteredOutByInstanceID(unit, instanceID, FILTER_RAID)
    local passesRic  = not IsAuraFilteredOutByInstanceID(unit, instanceID, FILTER_RIC)
    if not (passesRaid or passesRic) then return nil end

    -- Build full signature and look up in hash table
    local passesExt  = not IsAuraFilteredOutByInstanceID(unit, instanceID, FILTER_EXT)
    local passesDisp = not IsAuraFilteredOutByInstanceID(unit, instanceID, FILTER_DISP)

    local signature = MakeAuraSignature(passesRaid, passesRic, passesExt, passesDisp)
    local signatures = GetAuraSignatures(spec)
    return signatures[signature]
end

-- ============================================================
-- TIMESTAMP HELPERS
-- ============================================================

local CAST_TOLERANCE = 0.1  -- seconds

--- Check if two timestamps are within tolerance of each other.
-- Credit: AreTimestampsEqual pattern from Harrek's Advanced Raid Frames.
local function AreTimestampsEqual(time1, time2, delay)
    local tolerance = delay or CAST_TOLERANCE
    if time1 and time2 then
        return time1 >= time2 and time1 <= time2 + tolerance
    end
    return false
end

-- ============================================================
-- SPEC-SPECIFIC DISAMBIGUATION ENGINES
-- Only needed for specs where multiple auras share the same
-- filter signature. Written fresh following Harrek's approach.
-- ============================================================

--- Preservation Evoker: VerdantEmbrace vs Lifebind disambiguation.
-- Spell 360995 can produce either Lifebind or VerdantEmbrace.
-- If two auras with VerdantEmbrace's signature land on the same unit
-- within 0.1s, the first is Lifebind. A single one on the player is also Lifebind.
-- Credit: Timing disambiguation approach from Harrek's Advanced Raid Frames.
local function ParsePreservationEvokerBuffs(unit, addedAuras)
    if not addedAuras then return end

    local unitAuras = state.auras[unit]
    if not unitAuras then return end

    if not state.extras.ve then state.extras.ve = {} end

    for _, aura in ipairs(addedAuras) do
        if IsAuraFromPlayer(unit, aura.auraInstanceID) and unitAuras[aura.auraInstanceID] == "VerdantEmbrace" then
            if not state.extras.ve[unit] then
                state.extras.ve[unit] = { buffs = {}, timer = false }
            end
            local veTable = state.extras.ve[unit]
            veTable.buffs[#veTable.buffs + 1] = aura.auraInstanceID
            if not veTable.timer then
                veTable.timer = true
                C_Timer.After(0.1, function()
                    if #veTable.buffs == 2 then
                        -- Two VE-signature auras = one is Lifebind
                        unitAuras[veTable.buffs[1]] = "Lifebind"
                    elseif #veTable.buffs == 1 then
                        if UnitIsUnit(unit, "player") then
                            unitAuras[veTable.buffs[1]] = "Lifebind"
                        end
                    end
                    wipe(veTable.buffs)
                    veTable.timer = false
                end)
            end
        end
    end
end

--- Augmentation Evoker: EbonMight vs SensePower disambiguation.
-- Both share signature "0:1:0:0". EbonMight (395296) only appears
-- on the player (caster self-buff). SensePower only appears on
-- party members (never on the player). Simple unit check.
local function ParseAugmentationEvokerBuffs(unit, addedAuras)
    if not addedAuras then return end

    local unitAuras = state.auras[unit]
    if not unitAuras then return end

    local isPlayer = UnitIsUnit(unit, "player")

    for _, aura in ipairs(addedAuras) do
        local name = unitAuras[aura.auraInstanceID]
        if isPlayer and name == "SensePower" then
            -- Player only gets EbonMight (self-buff), never SensePower
            unitAuras[aura.auraInstanceID] = "EbonMight"
        elseif not isPlayer and name == "EbonMight" then
            -- Party members only get SensePower, never EbonMight
            unitAuras[aura.auraInstanceID] = "SensePower"
        end
    end
end

-- Map spec keys to their disambiguation engine function
local specEngines = {
    PreservationEvoker = ParsePreservationEvokerBuffs,
    AugmentationEvoker = ParseAugmentationEvokerBuffs,
}

-- ============================================================
-- UNIT INITIALIZATION
-- Scans all current auras on a unit and fingerprints secret ones.
-- Called on first access or when the group changes.
-- ============================================================

local function InitUnit(unit, spec)
    if not GetUnitAuras then return end
    if not SecretAuraInfo or not SecretAuraInfo[spec] then return end

    state.auras[unit] = state.auras[unit] or {}
    local unitAuras = state.auras[unit]

    local auras = GetUnitAuras(unit, "PLAYER|HELPFUL", 100)
    if not auras then return end

    for _, auraData in ipairs(auras) do
        local matched = MatchAuraSignature(unit, auraData, spec)
        if matched then
            unitAuras[auraData.auraInstanceID] = matched
        end
    end

    -- Run disambiguation engine on initial scan results
    local engine = specEngines[spec]
    if engine then
        -- Build a fake addedAuras list from all matched auras for the engine
        local fakeAdded = {}
        for instanceID in pairs(unitAuras) do
            fakeAdded[#fakeAdded + 1] = { auraInstanceID = instanceID }
        end
        if #fakeAdded > 0 then
            engine(unit, fakeAdded)
        end
    end
end

-- ============================================================
-- EVENT HANDLING
-- Cast tracker + UNIT_AURA handler for real-time tracking.
-- ============================================================

local eventFrame = CreateFrame("Frame")

local function UpdatePlayerSpec()
    if not UnitClassBase or not GetSpecialization then return end
    local class = UnitClassBase("player")
    local specNum = GetSpecialization()
    if class and specNum then
        local key = class .. "_" .. specNum
        state.spec = DF.AuraDesigner.SpecMap and DF.AuraDesigner.SpecMap[key] or nil
    end
end

-- UNIT_AURA handler. Subscribed via the roster dispatcher
-- (DF:RegisterRosterUnitEvent), so this only fires for player/partyN/raidN —
-- never for nameplates, targettarget, focus, mouseover, etc. The C++ filter
-- in the dispatcher means we don't need an in-handler unit guard, and we're
-- safe to use UnitIsUnit downstream because we know `unit` is a clean token
-- that the new (post-2026-04-07) UnitIsUnit rules permit comparing to "player".
function SecretAuras:OnUnitAura(event, unit, updateInfo)
    if not state.spec or not unit then return end
    if not SecretAuraInfo or not SecretAuraInfo[state.spec] then return end
    if not UnitExists(unit) then return end

    -- Ensure unit state exists
    if not state.auras[unit] then
        InitUnit(unit, state.spec)
        return  -- InitUnit already scanned all auras
    end

    local unitAuras = state.auras[unit]

    -- Remove expired auras
    if updateInfo and updateInfo.removedAuraInstanceIDs then
        for _, auraId in ipairs(updateInfo.removedAuraInstanceIDs) do
            unitAuras[auraId] = nil
        end
    end

    -- Match newly added auras via signature fingerprinting
    if updateInfo and updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if not unitAuras[aura.auraInstanceID] then
                local matched = MatchAuraSignature(unit, aura, state.spec)
                if matched then
                    unitAuras[aura.auraInstanceID] = matched
                end
            end
        end
    end

    -- Run spec-specific disambiguation engine
    local engine = specEngines[state.spec]
    if engine and updateInfo and updateInfo.addedAuras then
        engine(unit, updateInfo.addedAuras)
    end
end

local function OnEvent(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellId = ...
        if not state.spec or not spellId then return end
        local info = SecretAuraInfo and SecretAuraInfo[state.spec]
        if info and info.casts and info.casts[spellId] then
            state.casts[spellId] = GetTime()
        end

    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Wipe state for units that no longer exist
        for unit in pairs(state.auras) do
            if not UnitExists(unit) then
                state.auras[unit] = nil
            end
        end

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        UpdatePlayerSpec()
        -- Spec changed — wipe all state and re-init
        wipe(state.casts)
        wipe(state.auras)
        wipe(state.extras)
        wipe(signatureCache)

    elseif event == "PLAYER_LOGIN" then
        -- Initialize config references
        SecretAuraInfo = DF.AuraDesigner.SecretAuraInfo
        SpellIDs       = DF.AuraDesigner.SpellIDs
        IconTextures   = DF.AuraDesigner.IconTextures
        UpdatePlayerSpec()
    end
end

eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

-- UNIT_AURA is routed through the roster dispatcher (RosterEvents.lua) so
-- this module only sees aura updates for player/partyN/raidN. The dispatcher
-- uses RegisterUnitEvent at the C++ level — never fires for nameplates,
-- targettarget, focus, mouseover, etc. — which both eliminates wasted work
-- and avoids the secret-boolean taint case from UnitIsUnit on compound tokens
-- that necessitated the v4.2.6 interim filter.
DF:RegisterRosterUnitEvent(SecretAuras, "UNIT_AURA", "OnUnitAura")

-- ============================================================
-- PUBLIC API
-- Returns identified secret auras for a unit in the same format
-- as AuraAdapter's GetUnitAuras result.
-- ============================================================

--- Get all identified secret auras for a unit.
-- @param unit  Unit token (e.g. "party1")
-- @param spec  Spec key (e.g. "RestorationDruid")
-- @return table { [auraName] = auraData } or empty table
function SecretAuras:GetUnitAuras(unit, spec)
    if not unit or not spec then return {} end
    if not SecretAuraInfo or not SecretAuraInfo[spec] then return {} end

    -- Lazy init: first access for this unit triggers a full scan
    if not state.auras[unit] then
        InitUnit(unit, spec)
    end

    local unitAuras = state.auras[unit]
    if not unitAuras then return {} end

    local result = {}
    local spellIDs = SpellIDs and SpellIDs[spec]

    for auraInstanceID, auraName in pairs(unitAuras) do
        -- Verify the aura still exists on the unit
        local live = GetAuraDataByAuraInstanceID and GetAuraDataByAuraInstanceID(unit, auraInstanceID)
        if live then
            local knownSpellId = spellIDs and spellIDs[auraName]
            local iconTex = IconTextures and IconTextures[auraName]
            result[auraName] = {
                spellId         = knownSpellId or 0,
                icon            = iconTex or (live.icon),
                duration        = live.duration,
                expirationTime  = live.expirationTime,
                stacks          = live.applications,
                caster          = live.sourceUnit,
                auraInstanceID  = auraInstanceID,
                secret          = true,
            }
        else
            -- Aura expired — clean up stale state
            unitAuras[auraInstanceID] = nil
        end
    end

    return result
end

--- Match a single aura against known secret signatures for the given spec.
-- Exposed for inline use by AuraAdapter during its scan loop so that
-- secret aura detection and indicator rendering happen on the same tick.
-- @param unit  Unit token (e.g. "party1")
-- @param auraData  AuraData table from C_UnitAuras (must have .auraInstanceID)
-- @param spec  Spec key (e.g. "RestorationDruid")
-- @return auraName String name of matched aura, or nil
function SecretAuras:MatchAura(unit, auraData, spec)
    return MatchAuraSignature(unit, auraData, spec)
end

--- Record an inline-matched aura into the state cache.
-- Called by AuraAdapter after a successful inline match so that the
-- disambiguation engines (e.g. VerdantEmbrace/Lifebind) and state
-- cleanup (removedAuraInstanceIDs) continue to work correctly.
-- @param unit  Unit token
-- @param auraInstanceID  Blizzard aura instance ID
-- @param auraName  Matched aura name
function SecretAuras:RecordMatch(unit, auraInstanceID, auraName)
    if not state.auras[unit] then state.auras[unit] = {} end
    state.auras[unit][auraInstanceID] = auraName
end
