local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER - DATA SOURCE ADAPTER
-- Bridges the Aura Designer to Blizzard's C_UnitAuras API.
-- Scans ALL auras on a unit directly via C_UnitAuras.GetUnitAuras,
-- so the designer sees every aura regardless of what Blizzard's
-- compact frames choose to display.
--
-- Normalized aura data format:
--   {
--     spellId        = number,   -- spell ID
--     icon           = number,   -- texture ID
--     duration       = number,   -- total duration (0 = permanent)
--     expirationTime = number,   -- GetTime()-based expiry
--     stacks         = number,   -- stack/application count
--     caster         = string,   -- who applied it
--     auraInstanceID = number,   -- unique instance ID for C_UnitAuras API
--   }
-- ============================================================

local pairs, ipairs, type = pairs, ipairs, type
local GetTime = GetTime
local UnitIsUnit = UnitIsUnit
local issecretvalue = issecretvalue or function() return false end
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras
-- Fix A commit 4: IsAuraFilteredOutByInstanceID is the secret-safe C++
-- classifier we use to reproduce the HELPFUL|PLAYER filter semantics
-- from the cached helpful set (cache.buffsByID contains ALL helpful
-- auras, not just player-cast ones).
local IsAuraFilteredOut = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID

DF.AuraDesigner = DF.AuraDesigner or {}

local AuraAdapter = {}
DF.AuraDesigner.Adapter = AuraAdapter

-- ============================================================
-- BLIZZARD AURA PROVIDER
-- Scans all auras on a unit directly via C_UnitAuras.GetUnitAuras.
-- This sees every buff/debuff on the unit, not just what
-- Blizzard's compact frames choose to display.
--
-- The auras we track (healing HoTs, class buffs, defensives) are
-- on Blizzard's whitelist — their spellId is readable even in
-- combat. Auras with secret spellIds are not ours, so we skip
-- them entirely. No caching or fallback needed.
-- ============================================================

local Provider = {}

function Provider:IsAvailable()
    return true  -- Always available
end

function Provider:GetSourceName()
    return "Blizzard Aura API"
end

-- Build a reverse lookup: spellId → auraName for fast matching
local spellIdLookup = {}  -- { [spec] = { [spellId] = auraName } }

local function GetSpellIdLookup(spec)
    if spellIdLookup[spec] then return spellIdLookup[spec] end
    local lookup = {}
    local ids = DF.AuraDesigner.SpellIDs[spec]
    if ids then
        for auraName, spellId in pairs(ids) do
            lookup[spellId] = auraName
        end
    end
    -- Merge alternate spell IDs (e.g., Earth Shield 974 → "EarthShield")
    local alts = DF.AuraDesigner.AlternateSpellIDs and DF.AuraDesigner.AlternateSpellIDs[spec]
    if alts then
        for altSpellId, auraName in pairs(alts) do
            lookup[altSpellId] = auraName
        end
    end
    spellIdLookup[spec] = lookup
    return lookup
end

-- Clear the per-spec spellId→auraName cache. Called on spec change so the
-- new spec's spell IDs (e.g., Earth Shield for Resto Shaman) get rebuilt
-- from DF.AuraDesigner.SpellIDs / AlternateSpellIDs on next lookup.
function AuraAdapter:InvalidateSpecCache()
    spellIdLookup = {}
end

-- Debug throttle for adapter (shares interval with engine)
local adapterDebugLast = 0
local ADAPTER_DEBUG_INTERVAL = 3

-- Fix A commit 4: shared per-aura classification helper.
-- Takes one auraData entry, runs it through the spec's spellId → auraName
-- lookup (or secret-aura fingerprint matching for non-whitelisted IDs),
-- and writes a result entry if matched. Returns true on match so callers
-- can increment counters. All three scan paths below (cached helpful,
-- cached harmful, legacy fallback) share this helper so the secret/normal
-- branching lives in exactly one place.
local function ClassifyAuraForSpec(result, unit, spec, auraData, lookup, forwardLookup)
    local sid = auraData.spellId
    local auraInstanceID = auraData.auraInstanceID

    if not sid or issecretvalue(sid) then
        -- Secret aura — try inline fingerprint matching (same tick as
        -- indicator rendering, avoids race condition).
        local SecretModule = DF.AuraDesigner.SecretAuras
        if SecretModule and auraInstanceID then
            local matchedName = SecretModule:MatchAura(unit, auraData, spec)
            if matchedName then
                local knownSpellId = forwardLookup and forwardLookup[matchedName]
                local iconTex = DF.AuraDesigner.IconTextures and DF.AuraDesigner.IconTextures[matchedName]
                result[matchedName] = {
                    spellId = knownSpellId or 0,
                    icon = iconTex or auraData.icon,
                    duration = auraData.duration,
                    expirationTime = auraData.expirationTime,
                    stacks = auraData.applications,
                    caster = auraData.sourceUnit,
                    auraInstanceID = auraInstanceID,
                    secret = true,
                }
                -- Update state cache for disambiguation engines
                SecretModule:RecordMatch(unit, auraInstanceID, matchedName)
                return true
            end
        end
    else
        local auraName = lookup[sid]
        if auraName then
            result[auraName] = {
                spellId = forwardLookup and forwardLookup[auraName] or sid,
                icon = auraData.icon,
                duration = auraData.duration,
                expirationTime = auraData.expirationTime,
                stacks = auraData.applications,
                caster = auraData.sourceUnit,
                auraInstanceID = auraInstanceID,
            }
            return true
        end
    end
    return false
end

function Provider:GetUnitAuras(unit, spec)
    local lookup = GetSpellIdLookup(spec)  -- { [spellId] = auraName }
    if not lookup or not next(lookup) then return {} end

    local forwardLookup = DF.AuraDesigner.SpellIDs[spec]  -- { [auraName] = spellId }

    local now = GetTime()
    local shouldLog = (now - adapterDebugLast) >= ADAPTER_DEBUG_INTERVAL

    local result = {}
    local scannedCount = 0
    local matchedCount = 0

    -- Fix A commit 4: read from DF.AuraCache (populated incrementally
    -- by ScanUnitFull / ApplyAuraDelta in Features/Auras.lua) instead
    -- of scanning C_UnitAuras.GetUnitAuras ourselves. The cache already
    -- has every aura on the unit — we just iterate, filter, and classify.
    --
    -- This eliminates the 2-3 redundant GetUnitAuras calls per AD update
    -- that were the largest remaining allocation source after commits 1-3.
    local cache = DF.AuraCache and DF.AuraCache[unit]
    if cache and cache.hasFullScan then
        -- ------------------------------------------------------------
        -- FAST PATH — read from shared cache
        -- ------------------------------------------------------------

        -- HELPFUL|PLAYER subset: iterate cache.buffsByID (ALL helpful
        -- auras on the unit) and filter via the secret-safe C++
        -- classifier to reproduce the old HELPFUL|PLAYER semantics.
        -- IsAuraFilteredOutByInstanceID returns false when the aura
        -- matches the filter string (confusing name; "filtered out"
        -- means "does NOT match the filter").
        for id, auraData in pairs(cache.buffsByID) do
            if not IsAuraFilteredOut or not IsAuraFilteredOut(unit, id, "HELPFUL|PLAYER") then
                scannedCount = scannedCount + 1
                if ClassifyAuraForSpec(result, unit, spec, auraData, lookup, forwardLookup) then
                    matchedCount = matchedCount + 1
                end
            end
        end

        -- HARMFUL: iterate cache.debuffsByID (already contains only
        -- harmful auras, no filter needed).
        for id, auraData in pairs(cache.debuffsByID) do
            scannedCount = scannedCount + 1
            if ClassifyAuraForSpec(result, unit, spec, auraData, lookup, forwardLookup) then
                matchedCount = matchedCount + 1
            end
        end

        -- Self-only aura scan: auras that appear on the caster but have
        -- a different sourceUnit (e.g. Symbiotic Relationship). Iterate
        -- cache.buffsByID again (ALL helpful, no player filter) for the
        -- player unit only.
        if UnitIsUnit(unit, "player") then
            local selfOnly = DF.AuraDesigner.SelfOnlySpellIDs and DF.AuraDesigner.SelfOnlySpellIDs[spec]
            if selfOnly then
                for id, auraData in pairs(cache.buffsByID) do
                    local sid = auraData.spellId
                    if sid and not issecretvalue(sid) then
                        local auraName = selfOnly[sid]
                        if auraName and not result[auraName] then
                            matchedCount = matchedCount + 1
                            local entry = {
                                spellId = forwardLookup and forwardLookup[auraName] or sid,
                                icon = auraData.icon,
                                duration = auraData.duration,
                                expirationTime = auraData.expirationTime,
                                stacks = auraData.applications,
                                caster = auraData.sourceUnit,
                                auraInstanceID = auraData.auraInstanceID,
                                selfOnly = true,
                            }
                            result[auraName] = entry
                            -- Notify LinkedAuras of source aura for inference
                            local LinkedAurasModule = DF.AuraDesigner.LinkedAuras
                            if LinkedAurasModule then
                                LinkedAurasModule:SetSourceAura(auraName, entry)
                            end
                        end
                    end
                end
            end
        end

    elseif GetUnitAuras then
        -- ------------------------------------------------------------
        -- LEGACY FALLBACK — direct GetUnitAuras scan
        -- ------------------------------------------------------------
        -- TODO (post-Blizzard-removal, ~2026-04-15): delete this entire
        -- else branch. It's only reachable when:
        --   (a) Blizzard mode is active and DF.AuraCache[unit] has no
        --       buffsByID (because CaptureAurasFromBlizzardFrame doesn't
        --       populate the Fix A fields), or
        --   (b) Direct mode edge case where Provider:GetUnitAuras fires
        --       before the first UNIT_AURA event for a unit.
        -- After Blizzard mode is removed, case (a) goes away and case
        -- (b) can be handled by calling DF:ScanUnitFull(unit) here.
        local filters = { "HELPFUL|PLAYER", "HARMFUL" }
        for _, filter in ipairs(filters) do
            local auras = GetUnitAuras(unit, filter, 100)
            if auras then
                for _, auraData in ipairs(auras) do
                    scannedCount = scannedCount + 1
                    if ClassifyAuraForSpec(result, unit, spec, auraData, lookup, forwardLookup) then
                        matchedCount = matchedCount + 1
                    end
                end
            end
        end

        -- Self-only scan on player unit (legacy path)
        if UnitIsUnit(unit, "player") then
            local selfOnly = DF.AuraDesigner.SelfOnlySpellIDs and DF.AuraDesigner.SelfOnlySpellIDs[spec]
            if selfOnly then
                local selfAuras = GetUnitAuras(unit, "HELPFUL", 100)
                if selfAuras then
                    for _, auraData in ipairs(selfAuras) do
                        local sid = auraData.spellId
                        if sid and not issecretvalue(sid) then
                            local auraName = selfOnly[sid]
                            if auraName and not result[auraName] then
                                matchedCount = matchedCount + 1
                                local entry = {
                                    spellId = forwardLookup and forwardLookup[auraName] or sid,
                                    icon = auraData.icon,
                                    duration = auraData.duration,
                                    expirationTime = auraData.expirationTime,
                                    stacks = auraData.applications,
                                    caster = auraData.sourceUnit,
                                    auraInstanceID = auraData.auraInstanceID,
                                    selfOnly = true,
                                }
                                result[auraName] = entry
                                local LinkedAurasModule = DF.AuraDesigner.LinkedAuras
                                if LinkedAurasModule then
                                    LinkedAurasModule:SetSourceAura(auraName, entry)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Merge disambiguation overrides from SecretAuras state cache
    -- (e.g. VerdantEmbrace → Lifebind reclassification after 0.1s timer).
    -- This is independent of the scan path above — both fast and
    -- fallback paths need the merge.
    local SecretAurasModule = DF.AuraDesigner.SecretAuras
    if SecretAurasModule then
        local secretResult = SecretAurasModule:GetUnitAuras(unit, spec)
        if secretResult then
            for auraName, auraData in pairs(secretResult) do
                if not result[auraName] then
                    result[auraName] = auraData
                    matchedCount = matchedCount + 1
                end
            end
        end
    end

    -- Merge linked/inferred aura overrides
    -- (e.g. SR mirrored onto target, EM inferred onto player)
    local LinkedAurasModule = DF.AuraDesigner.LinkedAuras
    if LinkedAurasModule then
        local linkedResult = LinkedAurasModule:GetUnitAuras(unit, spec)
        if linkedResult then
            for auraName, auraData in pairs(linkedResult) do
                if not result[auraName] then
                    result[auraName] = auraData
                    matchedCount = matchedCount + 1
                end
            end
        end
    end

    if shouldLog then
        adapterDebugLast = now
        DF:Debug("AD", "unit=%s spec=%s scanned=%d matched=%d",
            unit, spec, scannedCount, matchedCount)
        -- Log unmatched non-secret spell IDs (helps identify missing
        -- alternates). Read from the cache if we have it; fall back to
        -- the old scan otherwise.
        local unmatched = {}
        if cache and cache.hasFullScan then
            for _, auraData in pairs(cache.buffsByID) do
                local sid = auraData.spellId
                if sid and not issecretvalue(sid) and not lookup[sid] then
                    unmatched[#unmatched + 1] = sid
                end
            end
            for _, auraData in pairs(cache.debuffsByID) do
                local sid = auraData.spellId
                if sid and not issecretvalue(sid) and not lookup[sid] then
                    unmatched[#unmatched + 1] = sid
                end
            end
        elseif GetUnitAuras then
            for _, filter in ipairs({ "HELPFUL|PLAYER", "HARMFUL" }) do
                local auras = GetUnitAuras(unit, filter, 100)
                if auras then
                    for _, ad in ipairs(auras) do
                        local sid = ad.spellId
                        if sid and not issecretvalue(sid) and not lookup[sid] then
                            unmatched[#unmatched + 1] = sid
                        end
                    end
                end
            end
        end
        if #unmatched > 0 then
            DF:Debug("AD", "  unmatched IDs on %s: %s", unit, table.concat(unmatched, ", "))
        end
    end

    return result
end

-- UNIT_AURA is routed through the roster dispatcher (RosterEvents.lua) so
-- we only see updates for player/partyN/raidN — never nameplates, target,
-- focus, mouseover, etc. The dispatcher uses RegisterUnitEvent at the C++
-- level for filtering.
local callbacks = {}
local subscribed = false

function Provider:OnUnitAura(event, unit)
    for _, cb in pairs(callbacks) do
        cb(unit)
    end
end

function Provider:RegisterCallback(owner, callback)
    callbacks[owner] = callback
    if not subscribed then
        DF:RegisterRosterUnitEvent(Provider, "UNIT_AURA", "OnUnitAura")
        subscribed = true
    end
end

function Provider:UnregisterCallback(owner)
    callbacks[owner] = nil
    -- Tear down the dispatcher subscription if no callbacks remain.
    if subscribed and not next(callbacks) then
        DF:UnregisterRosterUnitEvent(Provider, "UNIT_AURA")
        subscribed = false
    end
end

-- ============================================================
-- PUBLIC ADAPTER API
-- These methods delegate to the provider.
-- ============================================================

-- Returns true if a data source is available
function AuraAdapter:IsAvailable()
    return Provider:IsAvailable()
end

-- Returns a display name for the current data source
function AuraAdapter:GetSourceName()
    return Provider:GetSourceName()
end

-- ============================================================
-- SPEC / AURA QUERIES (uses local Config data)
-- These are provider-independent — always sourced from
-- DF.AuraDesigner tables in Config.lua.
-- ============================================================

-- Returns a list of supported spec keys
function AuraAdapter:GetSupportedSpecs()
    local specs = {}
    for spec in pairs(DF.AuraDesigner.SpecInfo) do
        specs[#specs + 1] = spec
    end
    return specs
end

-- Returns the display name for a spec key
function AuraAdapter:GetSpecDisplayName(specKey)
    local info = DF.AuraDesigner.SpecInfo[specKey]
    return info and info.display or specKey
end

-- Returns the list of trackable auras for a spec
-- Each entry: { name = "InternalName", display = "Display Name", color = {r,g,b} }
function AuraAdapter:GetTrackableAuras(specKey)
    return DF.AuraDesigner.TrackableAuras[specKey] or {}
end

-- ============================================================
-- PLAYER SPEC DETECTION
-- ============================================================

-- Returns the spec key for the current player, or nil if not supported
function AuraAdapter:GetPlayerSpec()
    local _, englishClass = UnitClass("player")
    local specIndex = GetSpecialization and GetSpecialization() or nil
    if not englishClass or not specIndex then return nil end

    local key = englishClass .. "_" .. specIndex
    return DF.AuraDesigner.SpecMap[key]
end

-- ============================================================
-- RUNTIME DATA
-- Delegates to the provider for live aura queries.
-- ============================================================

-- Returns a table of currently active tracked auras for a unit
-- Format: { [auraName] = { spellId, icon, duration, expirationTime, stacks, caster } }
function AuraAdapter:GetUnitAuras(unit, spec)
    if not spec then spec = self:GetPlayerSpec() end
    if not spec then return {} end
    return Provider:GetUnitAuras(unit, spec)
end

-- Registers a callback for when a unit's auras change
-- callback(unit) is called whenever unit auras may have changed
function AuraAdapter:RegisterCallback(owner, callback)
    Provider:RegisterCallback(owner, callback)
end

function AuraAdapter:UnregisterCallback(owner)
    Provider:UnregisterCallback(owner)
end

-- ============================================================
-- UTILITY
-- ============================================================

-- Check if Aura Designer is enabled for a frame
function DF:IsAuraDesignerEnabled(frame)
    local frameDB = frame and DF.GetFrameDB and DF:GetFrameDB(frame)
    if frameDB and frameDB.auraDesigner then
        return frameDB.auraDesigner.enabled
    end
    return false
end
