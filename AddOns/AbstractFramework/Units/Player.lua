---@class AbstractFramework
local AF = _G.AbstractFramework

local BNGetInfo = BNGetInfo
local UnitName = UnitName
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitGUID = UnitGUID
local UnitFactionGroup = UnitFactionGroup
local UnitRace = UnitRace
local UnitSex = UnitSex
local GetRealmName = GetRealmName
local GetNormalizedRealmName = GetNormalizedRealmName
local GetAutoCompleteRealms = GetAutoCompleteRealms
local GetSpecialization = C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo

---------------------------------------------------------------------
-- UnitClassBase --! fix wrong class for AI
---------------------------------------------------------------------
---@param unit string
---@return string classFileName
---@return string classID
function AF.UnitClassBase(unit)
    return select(2, UnitClass(unit))
end

---------------------------------------------------------------------
-- player info
---------------------------------------------------------------------
AF.player = {}
AF.player.localizedClass, AF.player.class, AF.player.classID = UnitClass("player")

--* AF_PLAYER_DATA_UPDATE
-- payload: isLogin boolean, if true, this is the first time the player data is loaded

--* AF_PLAYER_SPEC_UPDATE
-- payload: newSpecID number, lastSpecID number

local function PLAYER_LOGIN()
    local battleTag = select(2, BNGetInfo())
    AF.player.battleTagMD5 = AF.MD5(battleTag or "")

    AF.player.name = UnitName("player")
    AF.player.fullName = AF.UnitFullName("player")
    AF.player.level = UnitLevel("player")
    AF.player.guid = UnitGUID("player")
    AF.player.realm = GetRealmName()
    AF.player.normalizedRealm = GetNormalizedRealmName()
    AF.player.faction = UnitFactionGroup("player")
    AF.player.localizedRace, AF.englishRace, AF.player.raceID = UnitRace("player")
    AF.player.sex = UnitSex("player")

    if AF.isRetail or AF.isMists then
        AF.player.specIndex = GetSpecialization()
        AF.player.specID, AF.player.specName, _, AF.player.specIcon, AF.player.specRole = GetSpecializationInfo(AF.player.specIndex)
    end

    -- connected realms
    AF.connectedRealms = AF.TransposeTable(GetAutoCompleteRealms())
    AF.connectedRealms[AF.player.normalizedRealm] = true

    AF.Fire("AF_PLAYER_SPEC_UPDATE", AF.player.specID)
    AF.Fire("AF_PLAYER_DATA_UPDATE", true)
    AF.Fire("AF_PLAYER_LOGIN_DELAYED")
end
AF.RegisterCallback("AF_PLAYER_LOGIN", PLAYER_LOGIN, "high")

if AF.isRetail or AF.isMists then
    local function UpdateSpecData()
        local lastSpecID = AF.player.specID
        AF.player.specIndex = GetSpecialization()
        AF.player.specID, AF.player.specName, _, AF.player.specIcon, AF.player.specRole = GetSpecializationInfo(AF.player.specIndex)
        if AF.player.specID ~= lastSpecID then
            AF.Fire("AF_PLAYER_SPEC_UPDATE", AF.player.specID, lastSpecID)
            AF.Fire("AF_PLAYER_DATA_UPDATE")
        end
    end
    AF.CreateBasicEventHandler(AF.GetDelayedInvoker(0.1, UpdateSpecData), "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_SPECIALIZATION_CHANGED")
end

-- TODO: level, sex ... changed