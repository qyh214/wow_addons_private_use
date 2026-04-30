-- =============================================================
-- [[ ExwindTools 核心组件：队友专精/钥石同步 (PartySync) ]]
-- 设计目标：
-- 1. 不使用自定义插件通信，统一依赖外部库同步队友专精与钥石
-- 2. PartySync 仅负责队伍映射、缓存统一与 Inspect 补齐
-- 3. 进入受限环境后，仅消费已有缓存；专精允许继续通过 Inspect 补齐
-- 4. 被动兼容 LibSpecialization / LibKeystone / LibOpenRaid，统一写入同一缓存
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local PartySync = {}
ExwindTools.PartySync = PartySync

local CACHE_TTL = 600
local GC_INTERVAL = 60
local INSPECT_TIMEOUT = 1.5

local Cache = {}          -- [guid] = data
local GuidToUnit = {}     -- [guid] = "partyN"
local NameToGUID = {}     -- [full/short/plain] = guid
local PendingInspect = {} -- 顺序队列，元素为 unit
local PendingLookup = {}  -- [guid] = true

local activeInspectGUID
local inspectTimeoutTimer
local LibSpecialization = _G.LibStub and _G.LibStub("LibSpecialization", true)
local LibKeystone = _G.LibStub and _G.LibStub("LibKeystone", true)
local LibOpenRaid = _G.LibStub and _G.LibStub("LibOpenRaid-1.0", true)
local libSpecReceiver = {}
local libKeystoneReceiver = {}
local libOpenRaidReceiver = {}
local libSpecRegistered = false
local libKeystoneRegistered = false
local libOpenRaidRegistered = false
local EMPTY_CACHE = {}

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function IsPlainString(value)
    return type(value) == "string" and not IsSecretValue(value)
end

local function NormalizeGUIDKey(guid)
    if type(guid) ~= "string" or guid == "" then
        return nil
    end
    return guid
end

local function GetUnitGUIDSafe(unit)
    if type(unit) ~= "string" or unit == "" or not _G.UnitGUID then
        return nil
    end

    local ok, guid = pcall(_G.UnitGUID, unit)
    if not ok then
        return nil
    end

    return NormalizeGUIDKey(guid)
end

local function NormalizeName(name)
    if not IsPlainString(name) then
        return nil
    end
    local ok, normalized = pcall(_G.Ambiguate, name, "none")
    if ok and type(normalized) == "string" then
        return normalized
    end
    return nil
end

local function GetPlayerSpecID()
    local specIndex = _G.GetSpecialization and _G.GetSpecialization()
    if not specIndex then return 0 end
    return _G.GetSpecializationInfo(specIndex) or 0
end

local function GetPlayerKeystoneInfo()
    local keyLevel = (_G.C_MythicPlus and _G.C_MythicPlus.GetOwnedKeystoneLevel and _G.C_MythicPlus.GetOwnedKeystoneLevel()) or 0
    local keyMapID = (_G.C_MythicPlus and _G.C_MythicPlus.GetOwnedKeystoneChallengeMapID and _G.C_MythicPlus.GetOwnedKeystoneChallengeMapID()) or 0
    local rating = 0
    if _G.C_PlayerInfo and _G.C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
        local summary = _G.C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
        if type(summary) == "table" and type(summary.currentSeasonScore) == "number" then
            rating = summary.currentSeasonScore
        end
    end
    return keyLevel or 0, keyMapID or 0, rating or 0
end

local function HasRealPlayerPartyMembers()
    if not (_G.IsInGroup and _G.IsInGroup()) then
        return false
    end

    for i = 1, 4 do
        local unit = "party" .. i
        if _G.UnitExists(unit) and _G.UnitIsPlayer(unit) then
            return true
        end
    end

    return false
end

local function IsInGroupNow()
    if _G.IsInGroup then
        return _G.IsInGroup()
    end
    local state = ExwindTools.State or {}
    return state.IsInParty and true or false
end

local function IsInRaidNow()
    if _G.IsInRaid then
        return _G.IsInRaid()
    end
    local state = ExwindTools.State or {}
    return state.IsInRaid and true or false
end

local function ShouldDiscardPartyCache()
    if not IsInGroupNow() then
        return true
    end

    if not IsInRaidNow() and not HasRealPlayerPartyMembers() then
        return true
    end

    return false
end

local function IsPartySyncContextAllowed()
    if IsInRaidNow() then
        return false
    end
    if not IsInGroupNow() then
        return false
    end
    if not HasRealPlayerPartyMembers() then
        return false
    end
    return true
end

local function IsPartyCommAllowed()
    return IsPartySyncContextAllowed()
end

local function EnsureCache(guid, unit)
    local entry = Cache[guid]
    if not entry then
        entry = {
            guid = guid,
            specID = 0,
            keyLevel = 0,
            keyMapID = 0,
            rating = 0,
            class = nil,
            name = nil,
            shortName = nil,
            unit = nil,
            specTS = 0,
            keyTS = 0,
            sourceSpec = nil,
            sourceKey = nil,
        }
        Cache[guid] = entry
    end

    if unit and _G.UnitExists(unit) then
        entry.unit = unit
        local fullName = _G.GetUnitName(unit, true)
        if IsPlainString(fullName) then
            entry.name = fullName
        end

        local plainName = _G.UnitName(unit)
        if not IsPlainString(plainName) then
            plainName = nil
        end

        entry.shortName = NormalizeName(entry.name) or plainName or entry.shortName
        local _, classTag = _G.UnitClass(unit)
        entry.class = classTag or entry.class
    end

    return entry
end

local function IndexUnit(unit)
    if not _G.UnitExists(unit) then return end

    local guid = GetUnitGUIDSafe(unit)
    if not guid then return end

    GuidToUnit[guid] = unit
    local entry = EnsureCache(guid, unit)
    if IsPlainString(entry.name) then
        NameToGUID[entry.name] = guid
    end
    if IsPlainString(entry.shortName) then
        NameToGUID[entry.shortName] = guid
    end
    local plain = _G.UnitName(unit)
    if IsPlainString(plain) then
        NameToGUID[plain] = guid
    end
end

local function FindGUIDBySender(sender)
    if not IsPlainString(sender) then return nil end
    return NameToGUID[sender] or NameToGUID[NormalizeName(sender)]
end

local function FindPartyUnitByName(name)
    if not IsPlainString(name) then return nil end

    local guid = FindGUIDBySender(name)
    if guid then
        return guid, GuidToUnit[guid]
    end

    local normalized = NormalizeName(name)
    for i = 1, 4 do
        local unit = "party" .. i
        if _G.UnitExists(unit) then
            local unitName = _G.GetUnitName(unit, true)
            local plainName = _G.UnitName(unit)
            local matched = false
            if IsPlainString(unitName) then
                matched = (unitName == name) or (NormalizeName(unitName) == normalized)
            end
            if not matched and IsPlainString(plainName) then
                matched = plainName == name
            end
            if matched then
                local unitGUID = GetUnitGUIDSafe(unit)
                if unitGUID then
                    IndexUnit(unit)
                    return unitGUID, unit
                end
            end
        end
    end
end

local function ResolvePartyMember(unitHint, nameHint)
    if type(unitHint) == "string" and unitHint ~= "" and _G.UnitExists(unitHint) then
        local guid = GetUnitGUIDSafe(unitHint)
        if guid then
            IndexUnit(unitHint)
            return guid, unitHint
        end
    end

    return FindPartyUnitByName(nameHint or unitHint)
end

local function FireInfoEvent(unit, guid)
    ExwindTools:SendEvent("EX_PARTY_INFO_UPDATED", unit, guid)
end

local function UpdateSpec(guid, unit, specID, source)
    specID = tonumber(specID) or 0
    if not guid or specID <= 0 then return end

    local entry = EnsureCache(guid, unit)
    local oldSpecID = entry.specID
    entry.specID = specID
    entry.specTS = _G.GetTime()
    entry.sourceSpec = source or "Unknown"

    local resolvedUnit = unit or GuidToUnit[guid]
    if oldSpecID ~= specID then
        ExwindTools:SendEvent("EX_PARTY_SPEC_UPDATED", resolvedUnit, specID, guid)
        FireInfoEvent(resolvedUnit, guid)
    end
end

local function UpdateKeystone(guid, unit, keyLevel, keyMapID, rating, source)
    if not guid then return end

    local entry = EnsureCache(guid, unit)
    keyLevel = tonumber(keyLevel) or 0
    keyMapID = tonumber(keyMapID) or 0
    rating = tonumber(rating) or 0

    local changed = entry.keyLevel ~= keyLevel or entry.keyMapID ~= keyMapID or entry.rating ~= rating
    entry.keyLevel = keyLevel
    entry.keyMapID = keyMapID
    entry.rating = rating
    entry.keyTS = _G.GetTime()
    entry.sourceKey = source or "Unknown"

    if changed then
        local resolvedUnit = unit or GuidToUnit[guid]
        ExwindTools:SendEvent("EX_PARTY_KEYSTONE_UPDATED", resolvedUnit, keyLevel, keyMapID, rating, guid)
        FireInfoEvent(resolvedUnit, guid)
    end
end

local function ImportOpenRaidUnitInfo(unitHint, unitInfo, source)
    if type(unitInfo) ~= "table" then return end

    local guid, unit = ResolvePartyMember(unitHint, unitInfo.nameFull or unitInfo.name)
    if not guid then return end

    local entry = EnsureCache(guid, unit)
    if unitInfo.class and unitInfo.class ~= "" then
        entry.class = unitInfo.class
    end

    local specID = tonumber(unitInfo.specId) or 0
    if specID > 0 then
        UpdateSpec(guid, unit, specID, source or "OpenRaidUnit")
    end
end

local function ImportOpenRaidKeystone(unitHint, unitName, keystoneInfo, source)
    if type(keystoneInfo) ~= "table" then return end

    local guid, unit = ResolvePartyMember(unitHint, unitName)
    if not guid then return end

    local entry = EnsureCache(guid, unit)
    if tonumber(keystoneInfo.classID) and tonumber(keystoneInfo.classID) > 0 and not entry.class and unit and _G.UnitExists(unit) then
        local _, classTag = _G.UnitClass(unit)
        entry.class = classTag or entry.class
    end

    local specID = tonumber(keystoneInfo.specID) or 0
    if specID > 0 then
        UpdateSpec(guid, unit, specID, source or "OpenRaidKey")
    end

    UpdateKeystone(
        guid,
        unit,
        tonumber(keystoneInfo.level) or 0,
        tonumber(keystoneInfo.challengeMapID) or 0,
        tonumber(keystoneInfo.rating) or 0,
        source or "OpenRaid"
    )
end

local function ImportOpenRaidCache()
    if not LibOpenRaid then return end

    if LibOpenRaid.GetAllUnitsInfo then
        local allUnitsInfo = LibOpenRaid.GetAllUnitsInfo()
        if type(allUnitsInfo) == "table" then
            for unitName, unitInfo in pairs(allUnitsInfo) do
                ImportOpenRaidUnitInfo(unitName, unitInfo, "OpenRaidUnit")
            end
        end
    end

    if LibOpenRaid.GetAllKeystonesInfo then
        local allKeystonesInfo = LibOpenRaid.GetAllKeystonesInfo()
        if type(allKeystonesInfo) == "table" then
            for unitName, keystoneInfo in pairs(allKeystonesInfo) do
                ImportOpenRaidKeystone(nil, unitName, keystoneInfo, "OpenRaid")
            end
        end
    end
end

local function ClearInspectState()
    activeInspectGUID = nil
    if inspectTimeoutTimer then
        inspectTimeoutTimer:Cancel()
        inspectTimeoutTimer = nil
    end
    if _G.ClearInspectPlayer then
        _G.ClearInspectPlayer()
    end
end

local function ClearDetachedPartyCache()
    local hadData = next(Cache) ~= nil

    _G.wipe(GuidToUnit)
    _G.wipe(NameToGUID)
    _G.wipe(PendingInspect)
    _G.wipe(PendingLookup)
    _G.wipe(Cache)

    ClearInspectState()

    if hadData then
        ExwindTools:SendEvent("EX_PARTY_INFO_UPDATED", nil, nil)
    end
end

local function TryInspectNext()
    if activeInspectGUID or _G.InCombatLockdown() then return end

    while #PendingInspect > 0 do
        local unit = table.remove(PendingInspect, 1)
        if _G.UnitExists(unit) then
            local guid = GetUnitGUIDSafe(unit)
            if guid then
                PendingLookup[guid] = nil
                if _G.CanInspect(unit) then
                    activeInspectGUID = guid
                    _G.NotifyInspect(unit)
                    inspectTimeoutTimer = _G.C_Timer.NewTimer(INSPECT_TIMEOUT, function()
                        ClearInspectState()
                        TryInspectNext()
                    end)
                    return
                end
            end
        end
    end
end

local function QueueInspect(unit)
    if not IsPartySyncContextAllowed() then return end
    if _G.IsInRaid() then return end
    if not _G.UnitExists(unit) or _G.UnitIsUnit(unit, "player") then return end

    local guid = GetUnitGUIDSafe(unit)
    if not guid or PendingLookup[guid] then return end

    local entry = Cache[guid]
    if entry and entry.specID and entry.specID > 0 and (_G.GetTime() - (entry.specTS or 0) < CACHE_TTL) then
        return
    end

    PendingLookup[guid] = true
    PendingInspect[#PendingInspect + 1] = unit
    TryInspectNext()
end

local function RebuildRoster()
    _G.wipe(GuidToUnit)
    _G.wipe(NameToGUID)

    if ShouldDiscardPartyCache() then
        ClearDetachedPartyCache()
        return
    end

    if not IsPartySyncContextAllowed() then
        _G.wipe(PendingInspect)
        _G.wipe(PendingLookup)
        ClearInspectState()
        return
    end

    for i = 1, 4 do
        local unit = "party" .. i
        if _G.UnitExists(unit) then
            IndexUnit(unit)
            QueueInspect(unit)
        end
    end
end

local function OnInspectReady(guid)
    if not IsPartySyncContextAllowed() then
        if guid == activeInspectGUID then
            ClearInspectState()
        end
        return
    end
    guid = NormalizeGUIDKey(guid)
    if not guid then return end

    local unit = GuidToUnit[guid]
    if unit and _G.UnitExists(unit) then
        local specID = _G.GetInspectSpecialization(unit)
        if specID and specID > 0 then
            UpdateSpec(guid, unit, specID, "Inspect")
        end
    end

    if guid == activeInspectGUID then
        ClearInspectState()
        TryInspectNext()
    end
end

local function RefreshOwnData()
    local specID = GetPlayerSpecID()
    local keyLevel, keyMapID, rating = GetPlayerKeystoneInfo()
    if specID > 0 then
        PartySync.playerSpecID = specID
    end
    PartySync.playerKeyLevel = keyLevel
    PartySync.playerKeyMapID = keyMapID
    PartySync.playerRating = rating
end

local function TryHookExternalLibs()
    if not LibSpecialization and _G.LibStub then
        LibSpecialization = _G.LibStub("LibSpecialization", true)
    end
    if not LibKeystone and _G.LibStub then
        LibKeystone = _G.LibStub("LibKeystone", true)
    end
    if not LibOpenRaid and _G.LibStub then
        LibOpenRaid = _G.LibStub("LibOpenRaid-1.0", true)
    end

    if LibSpecialization and not libSpecRegistered then
        LibSpecialization.RegisterGroup(libSpecReceiver, function(specID, _, _, playerName)
            local guid, unit = FindPartyUnitByName(playerName)
            if guid and specID and specID > 0 then
                UpdateSpec(guid, unit, specID, "LibSpec")
            end
        end)
        libSpecRegistered = true
    end

    if LibKeystone and not libKeystoneRegistered then
        LibKeystone.Register(libKeystoneReceiver, function(keyLevel, keyMapID, rating, playerName, channel)
            if channel ~= "PARTY" then return end
            local guid, unit = FindPartyUnitByName(playerName)
            if guid then
                UpdateKeystone(guid, unit, keyLevel, keyMapID, rating, "LibKeystone")
            end
        end)
        libKeystoneRegistered = true
    end

    if LibOpenRaid and not libOpenRaidRegistered and LibOpenRaid.RegisterCallback then
        function libOpenRaidReceiver.OnUnitInfoUpdate(unitID, unitInfo)
            ImportOpenRaidUnitInfo(unitID, unitInfo, "OpenRaidUnit")
        end

        function libOpenRaidReceiver.OnKeystoneUpdate(unitName, keystoneInfo)
            ImportOpenRaidKeystone(nil, unitName, keystoneInfo, "OpenRaid")
        end

        LibOpenRaid.RegisterCallback(libOpenRaidReceiver, "UnitInfoUpdate", "OnUnitInfoUpdate")
        LibOpenRaid.RegisterCallback(libOpenRaidReceiver, "KeystoneUpdate", "OnKeystoneUpdate")
        libOpenRaidRegistered = true
    end

    if LibOpenRaid then
        ImportOpenRaidCache()
    end
end

local function RequestExternalLibData()
    TryHookExternalLibs()
    ImportOpenRaidCache()

    if not IsInGroupNow() or not HasRealPlayerPartyMembers() then
        return
    end

    if LibSpecialization and LibSpecialization.RequestGroupSpecialization then
        LibSpecialization.RequestGroupSpecialization()
    end
    if LibKeystone and LibKeystone.Request then
        LibKeystone.Request("PARTY")
    end
    if LibOpenRaid then
        if LibOpenRaid.RequestAllData then
            LibOpenRaid.RequestAllData()
        end
        if LibOpenRaid.RequestKeystoneDataFromParty then
            LibOpenRaid.RequestKeystoneDataFromParty()
        end
    end
end

local function CollectGarbage()
    local now = _G.GetTime()

    for guid, entry in pairs(Cache) do
        if not GuidToUnit[guid] then
            local newestTS = math.max(entry.specTS or 0, entry.keyTS or 0)
            if now - newestTS > CACHE_TTL then
                Cache[guid] = nil
            end
        end
    end
end

local function OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        TryHookExternalLibs()
    elseif event == "GROUP_ROSTER_UPDATE" then
        TryHookExternalLibs()
        RebuildRoster()
        RefreshOwnData()
        RequestExternalLibData()
    elseif event == "PLAYER_ENTERING_WORLD" then
        _G.C_Timer.After(0.3, function()
            TryHookExternalLibs()
            RebuildRoster()
            RefreshOwnData()
            RequestExternalLibData()
        end)
    elseif event == "INSPECT_READY" then
        OnInspectReady(...)
    elseif event == "PLAYER_REGEN_ENABLED" then
        TryInspectNext()
    elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" or event == "TRAIT_CONFIG_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        RefreshOwnData()
        RequestExternalLibData()
    elseif event == "BAG_UPDATE_DELAYED" or event == "ITEM_CHANGED" or event == "CHALLENGE_MODE_MAPS_UPDATE" then
        RefreshOwnData()
        RequestExternalLibData()
    end
end

function PartySync:GetSpec(unit)
    if unit == "player" then
        return GetPlayerSpecID()
    end

    local guid = GetUnitGUIDSafe(unit)
    local entry = guid and Cache[guid]
    if not entry then return 0 end
    return entry.specID or 0
end

function PartySync:GetKeystone(unit)
    if unit == "player" then
        return GetPlayerKeystoneInfo()
    end

    local guid = GetUnitGUIDSafe(unit)
    local entry = guid and Cache[guid]
    if not entry then
        return 0, 0, 0
    end
    return entry.keyLevel or 0, entry.keyMapID or 0, entry.rating or 0
end

function PartySync:GetMember(unit)
    local guid = GetUnitGUIDSafe(unit)
    if not guid then return nil end
    return Cache[guid]
end

function PartySync:GetCache()
    if ShouldDiscardPartyCache() then
        return EMPTY_CACHE
    end
    return Cache
end

function PartySync:IsPartyCommAllowed()
    return IsPartyCommAllowed()
end

function PartySync:HasRealPartyMembers()
    return HasRealPlayerPartyMembers()
end

function PartySync:RequestPartyData()
    RefreshOwnData()
    RequestExternalLibData()
end

function PartySync:BroadcastSelf()
    RefreshOwnData()
    RequestExternalLibData()
end

ExwindTools:RegisterEvent("ADDON_LOADED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("GROUP_ROSTER_UPDATE", "PartySync", OnEvent)
ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", "PartySync", OnEvent)
ExwindTools:RegisterEvent("INSPECT_READY", "PartySync", OnEvent)
ExwindTools:RegisterEvent("PLAYER_REGEN_ENABLED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("TRAIT_CONFIG_UPDATED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("BAG_UPDATE_DELAYED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("ITEM_CHANGED", "PartySync", OnEvent)
ExwindTools:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", "PartySync", OnEvent)

_G.C_Timer.NewTicker(GC_INTERVAL, CollectGarbage)
TryHookExternalLibs()
RefreshOwnData()
