---@class AbstractFramework
local AF = _G.AbstractFramework

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
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo

---------------------------------------------------------------------
-- player info
---------------------------------------------------------------------
AF.player = {}
AF.player.localizedClass, AF.player.class, AF.player.classID = UnitClass("player")

--* AF_PLAYER_DATA_UPDATE
-- payload: isLogin boolean, if true, this is the first time the player data is loaded

local function PLAYER_LOGIN()
    AF.player.name = UnitName("player")
    AF.player.fullName = AF.UnitFullName("player")
    AF.player.level = UnitLevel("player")
    AF.player.guid = UnitGUID("player")
    AF.player.realm = GetRealmName()
    AF.player.normalizedRealm = GetNormalizedRealmName()
    AF.player.faction = UnitFactionGroup("player")
    AF.player.localizedRace, AF.englishRace, AF.player.raceID = UnitRace("player")
    AF.player.sex = UnitSex("player")

    if AF.isRetail then
        AF.player.specIndex = GetSpecialization()
        AF.player.specID = GetSpecializationInfo(AF.player.specIndex)
    end

    -- connected realms
    AF.connectedRealms = AF.TransposeTable(GetAutoCompleteRealms())
    AF.connectedRealms[AF.player.normalizedRealm] = true

    AF.Fire("AF_PLAYER_DATA_UPDATE", true)
end
AF.RegisterCallback("AF_PLAYER_LOGIN", PLAYER_LOGIN, "high")

if AF.isRetail then
    local function ACTIVE_TALENT_GROUP_CHANGED()
        AF.player.specIndex = GetSpecialization()
        AF.player.specID = GetSpecializationInfo(AF.player.specIndex)
        AF.Fire("AF_PLAYER_DATA_UPDATE")
    end
    AF.CreateBasicEventHandler(AF.GetDelayedInvoker(0.1, ACTIVE_TALENT_GROUP_CHANGED), "ACTIVE_TALENT_GROUP_CHANGED")
end

-- TODO: level, sex ... changed