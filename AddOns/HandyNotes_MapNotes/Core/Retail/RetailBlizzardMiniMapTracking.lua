local ADDON_NAME, ns = ...

local function GetNumTracking()
  if C_Minimap and C_Minimap.GetNumTrackingTypes then
    return C_Minimap.GetNumTrackingTypes() or 0
  elseif GetNumTrackingTypes then
    return GetNumTrackingTypes() or 0
  end
  return 0
end

local function GetInfo(index)
  if C_Minimap and C_Minimap.GetTrackingInfo then
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = C_Minimap.GetTrackingInfo(index)
    if type(arg1) == "table" then
      local trackingData = arg1
      return trackingData.name, trackingData.active, (trackingData.textureFileID or trackingData.texture), trackingData.nested, trackingData.group
    else
      return arg1, arg3, arg2, arg7, arg8
    end
  elseif GetTrackingInfo then
    local name, texture, active, _, _, _, nested, group = GetTrackingInfo(index)
    return name, active, texture, nested, group
  end
  return nil
end

ns.GS = ns.GS or {
  AUCTIONEER = _G.MINIMAP_TRACKING_AUCTIONEER,
  BANKER = _G.MINIMAP_TRACKING_BANKER,
  BARBER = _G.MINIMAP_TRACKING_BARBER,
  BATTLEMASTER = _G.MINIMAP_TRACKING_BATTLEMASTER,
  INNKEEPER = _G.MINIMAP_TRACKING_INNKEEPER,
  MAILBOX = _G.MINIMAP_TRACKING_MAILBOX,
  ITEM_UPGRADE = _G.ITEM_UPGRADE or _G.UPGRADE,
  TRAINER_PROF = _G.MINIMAP_TRACKING_TRAINER_PROFESSION,
  STABLEMASTER = _G.MINIMAP_TRACKING_STABLEMASTER,
  TRANSMOGRIFIER = _G.MINIMAP_TRACKING_TRANSMOGRIFIER,
  FOOD_DRINK = _G.MINIMAP_TRACKING_VENDOR_FOOD,
  REAGENTS = _G.MINIMAP_TRACKING_VENDOR_REAGENT,
  REPAIR = _G.MINIMAP_TRACKING_REPAIR,
}

local function norm(inputString)
  inputString = tostring(inputString or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  inputString = inputString:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  return inputString:lower()
end

local function FindAllIndicesByGSName(gsName)
  local matchingIndices = {}
  if not gsName then return matchingIndices end

  local wantedName = norm(gsName)
  local totalTrackingTypes = GetNumTracking()
  for index = 1, totalTrackingTypes do
    local trackingName = GetInfo(index)
    if trackingName and norm(trackingName) == wantedName then
      matchingIndices[#matchingIndices + 1] = index
    end
  end

  return matchingIndices
end

local function Backups()
  ns.Addon = ns.Addon or {}
  ns.Addon.db = ns.Addon.db or { profile = {}, char = {} }

  ns.Addon.db.char = ns.Addon.db.char or {}
  ns.Addon.db.char._minimapBackup = ns.Addon.db.char._minimapBackup or {}
  local charBackups = ns.Addon.db.char._minimapBackup

  local profileDB = ns.Addon.db.profile
  if profileDB and profileDB._minimapBackup and next(profileDB._minimapBackup) ~= nil then
    for key, value in pairs(profileDB._minimapBackup) do
      if charBackups[key] == nil then
        charBackups[key] = value
      end
    end
    profileDB._minimapBackup = nil
  end

  return charBackups
end

local function BackupIfMissingPersist(gsName, wasActive)
  local charBackups = Backups()
  if charBackups[gsName] == nil then
    charBackups[gsName] = not not wasActive
  end
end

local KeyToGS = {
  HideBlizzAuctioneer = "AUCTIONEER",
  HideBlizzBanker = "BANKER",
  HideBlizzBarber = "BARBER",
  HideBlizzBattlemaster = "BATTLEMASTER",
  HideBlizzInnkeeper = "INNKEEPER",
  HideBlizzItemUpgrade = "ITEM_UPGRADE",
  HideBlizzMailbox = "MAILBOX",
  HideBlizzProfTrainers = "TRAINER_PROF",
  HideBlizzStablemaster = "STABLEMASTER",
  HideBlizzTransmog = "TRANSMOGRIFIER",
  HideBlizzFoodDrink = "FOOD_DRINK",
  HideBlizzReagents = "REAGENTS",
  HideBlizzRepair = "REPAIR",
}

function ns.EnforceActiveHides()
  if GetNumTracking() == 0 then
    local f = CreateFrame("Frame")
    f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    f:SetScript("OnEvent", function(self)
      self:UnregisterEvent("MINIMAP_UPDATE_TRACKING")
      ns.EnforceActiveHides()
    end)
    return
  end

  local profileActivate = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate or {}
  local charBackups = Backups()
  for dbKey, gsKey in pairs(KeyToGS) do
    local gsText = ns.GS[gsKey]
    if gsText then
      local matchingIndices = FindAllIndicesByGSName(gsText)
      if #matchingIndices > 0 then
        if profileActivate[dbKey] then
          local anyActive = false
          for _, index in ipairs(matchingIndices) do
            local _, isActive = GetInfo(index)
            anyActive = anyActive or isActive
          end
        
          BackupIfMissingPersist(gsText, anyActive)
        
          for _, index in ipairs(matchingIndices) do
            local _, isActive = GetInfo(index)
            if isActive then
              C_Minimap.SetTracking(index, false)
            end
          end
        else
          local previousState = charBackups[gsText]
          if previousState ~= nil then
            for _, index in ipairs(matchingIndices) do
              local _, isActive = GetInfo(index)
              if isActive ~= previousState then
                C_Minimap.SetTracking(index, previousState)
              end
            end
            charBackups[gsText] = nil
          end
        end
      end
    end
  end
end

function ns.SetHideFlagAndApply(databaseKey, shouldHide)
  if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile) then return end
  ns.Addon.db.profile.activate = ns.Addon.db.profile.activate or {}
  ns.Addon.db.profile.activate[databaseKey] = shouldHide and true or false

  local gsKey = KeyToGS[databaseKey]
  local gsText = gsKey and ns.GS[gsKey]
  if not gsText then return end

  if GetNumTracking() == 0 then
    local f = CreateFrame("Frame")
    f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    f:SetScript("OnEvent", function(self)
      self:UnregisterEvent("MINIMAP_UPDATE_TRACKING")
      ns.SetHideFlagAndApply(databaseKey, shouldHide)
    end)
    return
  end

  local matchingIndices = FindAllIndicesByGSName(gsText)
  if #matchingIndices == 0 then return end

  if shouldHide then
    local anyActive = false
    for _, index in ipairs(matchingIndices) do
      local _, isActive = GetInfo(index)
      anyActive = anyActive or isActive
    end
    BackupIfMissingPersist(gsText, anyActive)
    for _, index in ipairs(matchingIndices) do
      local _, isActive = GetInfo(index)
      if isActive then
        C_Minimap.SetTracking(index, false)
      end
    end
  else
    local charBackups = Backups()
    local previousState = charBackups[gsText]
    if previousState ~= nil then
      for _, index in ipairs(matchingIndices) do
        local _, isActive = GetInfo(index)
        if isActive ~= previousState then
          C_Minimap.SetTracking(index, previousState)
        end
      end
      charBackups[gsText] = nil
    end
  end
end

do
  local f = CreateFrame("Frame")
  f:RegisterEvent("PLAYER_LOGIN")
  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
  f:SetScript("OnEvent", function()
    ns.EnforceActiveHides()
  end)
end