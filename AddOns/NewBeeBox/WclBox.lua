local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local GetAddOnMetadata = GetAddOnMetadata or (C_AddOns and C_AddOns.GetAddOnMetadata)
local addon_version = ""
if GetAddOnMetadata then
    addon_version = GetAddOnMetadata("NewBeeBox", "Version")
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        local name = UnitName("player")
        local _, class = UnitClass("player")
        local faction = UnitFactionGroup("player")
        local level = UnitLevel("player")
        local realmID = GetRealmID()
        local realmName = GetRealmName()
        local playerGUID = UnitGUID("player")
        local loginTime = time()
        local race = UnitRace("player")
        local gold = GetMoney()

        local key = playerGUID
        local hash = NewBeeHash32(realmName .. name .. class .. faction)

        WclBoxGlobal = WclBoxGlobal or {}
        WclBoxCharacter = WclBoxCharacter or {}
        WclBoxGlobal.version = addon_version
        WclBoxGlobal[key] = {}
        WclBoxGlobal[key].name = name
        WclBoxGlobal[key].hash = hash
        WclBoxGlobal[key].class = class
        WclBoxGlobal[key].faction = faction
        WclBoxGlobal[key].level = level
        WclBoxGlobal[key].realmID = realmID
        WclBoxGlobal[key].realmName = realmName
        WclBoxGlobal[key].playerGUID = playerGUID
        WclBoxGlobal[key].loginTime = loginTime
        WclBoxGlobal[key].race = race
        WclBoxGlobal[key].gold = gold


        WclBoxCharacter.version = addon_version
        WclBoxCharacter.name = name
        WclBoxCharacter.hash = hash
        WclBoxCharacter.class = class
        WclBoxCharacter.faction = faction
        WclBoxCharacter.level = level
        WclBoxCharacter.realmID = realmID
        WclBoxCharacter.realmName = realmName
        WclBoxCharacter.playerGUID = playerGUID
        WclBoxCharacter.loginTime = loginTime
        WclBoxCharacter.race = race
        WclBoxCharacter.gold = gold

        -- Unregister the PLAYER_LOGIN event after handling it
        eventFrame:UnregisterEvent("PLAYER_LOGIN")
    end
end)


-- WA功能模块
local loadedFrame = CreateFrame("FRAME")
loadedFrame:RegisterEvent("ADDON_LOADED")
loadedFrame:SetScript("OnEvent", function(_, _, addonName)
  if addonName == "NewBeeBox" then
    if WeakAuras and WeakAuras.AddCompanionData and WagoAppCompanionData then
      WeakAuras.AddCompanionData(WagoAppCompanionData)
    end
  end
end)