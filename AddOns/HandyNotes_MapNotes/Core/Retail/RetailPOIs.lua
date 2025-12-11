local ADDON_NAME, ns = ...

ns.AreaPOIHooked = ns.AreaPOIHooked or setmetatable({}, { __mode = "k" })

local function MN_Post(fn)
  C_Timer.After(0, function()
    pcall(fn)
  end)
end

local function MN_MapHasRelevantActivePins()
  if not (WorldMapFrame and WorldMapFrame.pinPools) then return false end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then
    return false
  end

  ns.BlizzAreaPoisLookup = ns.BlizzAreaPoisLookup or {}
  if next(ns.BlizzAreaPoisLookup) == nil then
    for _, poiID in pairs(ns.BlizzAreaPoisInfo or {}) do
      if poiID then ns.BlizzAreaPoisLookup[poiID] = true end
    end
  end

  ns.BlizzAreaPoisLookupZidormi = ns.BlizzAreaPoisLookupZidormi or {}
  if next(ns.BlizzAreaPoisLookupZidormi) == nil then
    for _, poiID in pairs(ns.BlizzAreaPoisInfoZidormi or {}) do
      if poiID then ns.BlizzAreaPoisLookupZidormi[poiID] = true end
    end
  end

  for _, pool in pairs(WorldMapFrame.pinPools) do
    for pin in pool:EnumerateActive() do
      local info = pin.poiInfo
      local areaPoiID = pin.areaPoiID or (info and info.areaPoiID)

      if areaPoiID then
        if cfg.RemoveBlizzPOIs and ns.BlizzAreaPoisLookup[areaPoiID] then return true end
        if cfg.RemoveBlizzPOIsZidormi and ns.BlizzAreaPoisLookupZidormi[areaPoiID] then return true end
      end

      if cfg.RemoveBlizzPOIsZidormi and pin.objectGUID then
        for _, id in ipairs(ns.BlizzAreaPoisInfoZidormi or {}) do
          if id and string.find(pin.objectGUID, tostring(id), 1, true) then
            return true
          end
        end
      end
    end
  end

  return false
end

function ns.RemovePOIs()
  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg then return end
  if cfg.HideMapNote then return end
  if not (WorldMapFrame and WorldMapFrame.pinPools) then return end

  ns.BlizzAreaPoisLookup = ns.BlizzAreaPoisLookup or {}
  if next(ns.BlizzAreaPoisLookup) == nil then
    for _, poiID in pairs(ns.BlizzAreaPoisInfo or {}) do
      if poiID then ns.BlizzAreaPoisLookup[poiID] = true end
    end
  end

  ns.BlizzAreaPoisLookupZidormi = ns.BlizzAreaPoisLookupZidormi or {}
  if next(ns.BlizzAreaPoisLookupZidormi) == nil then
    for _, poiID in pairs(ns.BlizzAreaPoisInfoZidormi or {}) do
      if poiID then ns.BlizzAreaPoisLookupZidormi[poiID] = true end
    end
  end

  for _, pinPool in pairs(WorldMapFrame.pinPools) do
    for pin in pinPool:EnumerateActive() do
      local info = pin.poiInfo
      local areaPoiID = pin.areaPoiID or (info and info.areaPoiID)
      local isBlizzPOI = areaPoiID and ns.BlizzAreaPoisLookup[areaPoiID]
      local isZidormiPOI = areaPoiID and ns.BlizzAreaPoisLookupZidormi[areaPoiID]

      local isZidormiGUID = false
      if pin.objectGUID and not isZidormiPOI then
        for _, id in ipairs(ns.BlizzAreaPoisInfoZidormi or {}) do
          if id and string.find(pin.objectGUID, tostring(id), 1, true) then
            isZidormiGUID = true
            break
          end
        end
      end

      if isBlizzPOI then
        if cfg.RemoveBlizzPOIs then
          if pin:IsShown() then pin:Hide() end
        else
          if not pin:IsShown() then pin:Show() end
        end
      
      elseif (isZidormiPOI or isZidormiGUID) then
        if cfg.RemoveBlizzPOIsZidormi then
          if pin:IsShown() then pin:Hide() end
        else
          if not pin:IsShown() then pin:Show() end
        end
      end
    end
  end
end

local function MN_TryHookProvider(dp)
  if not dp or ns.AreaPOIHooked[dp] then return end

  if (not dp.GetPinTemplates and type(dp.GetPinTemplate) == "function") then
    local ok, tmpl = pcall(dp.GetPinTemplate, dp)
    if ok and tmpl == "AreaPOIPinTemplate" then
      ns.AreaPOIHooked[dp] = true

      hooksecurefunc(dp, "RefreshAllData", function()
        local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
        if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then
          return
        end

        if WorldMapFrame and WorldMapFrame:IsShown() and MN_MapHasRelevantActivePins() then
          ns.RemovePOIs()
          if ns.RebindPOIEvent then ns.RebindPOIEvent() end
        end
      end)
    end
  end
end

for dp in pairs((WorldMapFrame and WorldMapFrame.dataProviders) or {}) do
  MN_TryHookProvider(dp)
end

ns.AddDataProviderHooked = ns.AddDataProviderHooked or false
if WorldMapFrame and not ns.AddDataProviderHooked then
  ns.AddDataProviderHooked = true
  hooksecurefunc(WorldMapFrame, "AddDataProvider", function(_, dp)
    MN_TryHookProvider(dp)
  end)
end

local eventFrame = CreateFrame("Frame")
eventFrame._registered = false

eventFrame:SetScript("OnEvent", function(self, eventName)
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then
    return
  end

  if not MN_MapHasRelevantActivePins() then return end
  --print("test 3 AREA_POIS_UPDATED")
  C_Timer.After(0, function()
    if ns.RemovePOIs then ns.RemovePOIs() end
  end)
end)

local function MN_ShouldListenPOIEvent()
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return false end
  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then return false end
  return MN_MapHasRelevantActivePins()
end

function ns.RegisterPOIEvent()
  if not eventFrame._registered and MN_ShouldListenPOIEvent() then
    eventFrame:RegisterEvent("AREA_POIS_UPDATED")
    eventFrame._registered = true
  end
end

function ns.UnregisterPOIEvent()
  if eventFrame._registered then
    eventFrame:UnregisterEvent("AREA_POIS_UPDATED")
    eventFrame._registered = false
  end
end

function ns.RebindPOIEvent()
  if MN_ShouldListenPOIEvent() then
    ns.RegisterPOIEvent()
  else
    ns.UnregisterPOIEvent()
  end
end

local function MN_OnMapChanged()
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end
  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg then return end

  if (cfg.RemoveBlizzPOIs or cfg.RemoveBlizzPOIsZidormi) then
    ns.BlizzAreaPoisLookup = nil
    ns.BlizzAreaPoisLookupZidormi = nil
  end

  ns.RebindPOIEvent()

  if (cfg.RemoveBlizzPOIs or cfg.RemoveBlizzPOIsZidormi) and MN_MapHasRelevantActivePins() then
    C_Timer.After(0, function()
      --print("test 2 On_Map_Changed")
      if ns.RemovePOIs then ns.RemovePOIs() end
    end)
  end
end

ns.POIShowHooked = ns.POIShowHooked or false
ns.POIHideHooked = ns.POIHideHooked or false
ns.MapChangeHooked = ns.MapChangeHooked or false
C_Timer.After(0, function()
  if not WorldMapFrame then return end

  if not ns.MapChangeHooked then
    ns.MapChangeHooked = true
    if type(WorldMapFrame.OnMapChanged) == "function" then
      hooksecurefunc(WorldMapFrame, "OnMapChanged", MN_OnMapChanged)
    else
      hooksecurefunc(WorldMapFrame, "SetMapID", MN_OnMapChanged)
    end
  end

  if not ns.POIShowHooked then
    ns.POIShowHooked = true
    hooksecurefunc(WorldMapFrame, "Show", function(self)
      MN_Post(function() ns.RegisterPOIEvent(self) end)
    end)
  end

  if not ns.POIHideHooked then
    ns.POIHideHooked = true
    hooksecurefunc(WorldMapFrame, "Hide", function(self)
      MN_Post(function() ns.UnregisterPOIEvent(self) end)
    end)
  end

  if WorldMapFrame:IsShown() then
    MN_Post(function() ns.RegisterPOIEvent(WorldMapFrame) end)
  end
end)