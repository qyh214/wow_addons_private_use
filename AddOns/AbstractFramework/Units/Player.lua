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

local playerInfoHandler = AF.CreateSimpleEventHandler("PLAYER_LOGIN")

function playerInfoHandler:PLAYER_LOGIN()
    AF.player.name = UnitName("player")
    AF.player.fullName = AF.UnitFullName("player")
    AF.player.localizedClass, AF.player.class, AF.player.classID = UnitClass("player")
    AF.player.level = UnitLevel("player")
    AF.player.guid = UnitGUID("player")
    AF.player.realm = GetRealmName()
    AF.player.normalizedRealm = GetNormalizedRealmName()
    AF.player.faction = UnitFactionGroup("player")
    AF.player.localizedRace, AF.englishRace, AF.player.raceID = UnitRace("player")
    AF.player.sex = UnitSex("player")

    if AF.isRetail then
        playerInfoHandler:ACTIVE_TALENT_GROUP_CHANGED()
    end

    -- connected realms
    AF.connectedRealms = AF.TransposeTable(GetAutoCompleteRealms())
    AF.connectedRealms[AF.player.normalizedRealm] = true
end

if AF.isRetail then
    playerInfoHandler:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    function playerInfoHandler:ACTIVE_TALENT_GROUP_CHANGED()
        AF.player.specIndex = GetSpecialization()
        AF.player.specID = GetSpecializationInfo(AF.player.specIndex)
    end
end