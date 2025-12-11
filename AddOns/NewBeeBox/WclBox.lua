local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")


eventFrame:SetScript("OnEvent", function(self, event, addonName)
  if event == "PLAYER_LOGIN" then
    -- 获取插件信息
    local GetAddOnMetadata = GetAddOnMetadata or (C_AddOns and C_AddOns.GetAddOnMetadata)
    local addon_version = ""
    if GetAddOnMetadata then
      addon_version = GetAddOnMetadata("NewBeeBox", "Version")
    end

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
    WclBoxGlobal.version = addon_version
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


    WclBoxCharacter.version = addon_version
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

  -- 处理插件加载事件 加载WA字符串
  if event == "ADDON_LOADED" then
    if addonName == "NewBeeBox" then
      if WeakAuras and WeakAuras.AddCompanionData and WagoAppCompanionData then
        -- 如果WagoAppCompanionData中不存在ids属性则添加
        if not WagoAppCompanionData.ids then
          WagoAppCompanionData["ids"] = {}
        end
        -- 如果没有slug属性则添加
        if not WagoAppCompanionData.slugs then
          WagoAppCompanionData["slugs"] = {}
        end
        -- 如果没有uids属性则添加
        if not WagoAppCompanionData.uids then
          WagoAppCompanionData["uids"] = {}
        end

        WeakAuras.AddCompanionData(WagoAppCompanionData)
      end
    end
  end
end)

