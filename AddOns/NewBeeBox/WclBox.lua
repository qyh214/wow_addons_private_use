local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

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

        WclBoxGlobal = WclBoxGlobal or {}
        WclBoxCharacter = WclBoxCharacter or {}
        WclBoxGlobal[key] = {}
        WclBoxGlobal[key].name = name
        WclBoxGlobal[key].class = class
        WclBoxGlobal[key].faction = faction
        WclBoxGlobal[key].level = level
        WclBoxGlobal[key].realmID = realmID
        WclBoxGlobal[key].realmName = realmName
        WclBoxGlobal[key].playerGUID = playerGUID
        WclBoxGlobal[key].loginTime = loginTime
        WclBoxGlobal[key].race = race
        WclBoxGlobal[key].gold = gold

        WclBoxCharacter.name = name
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
