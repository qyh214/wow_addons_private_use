local ADDON_NAME, ns = ...

ns.AreaPOIHooked = ns.AreaPOIHooked or setmetatable({}, { __mode = "k" })

local function MN_Post(fn)
  if type(fn) ~= "function" then return end
  C_Timer.After(0, function()
    pcall(fn)
  end)
end

local function MN_BuildLookups()
  ns.BlizzAreaPoisLookup = ns.BlizzAreaPoisLookup or {}
  if next(ns.BlizzAreaPoisLookup) == nil then
    for _, poiID in pairs(ns.BlizzAreaPoisInfo or {}) do
      if poiID then
        ns.BlizzAreaPoisLookup[poiID] = true
      end
    end
  end

  ns.BlizzAreaPoisLookupZidormi = ns.BlizzAreaPoisLookupZidormi or {}
  if next(ns.BlizzAreaPoisLookupZidormi) == nil then
    for _, poiID in pairs(ns.BlizzAreaPoisInfoZidormi or {}) do
      if poiID then
        ns.BlizzAreaPoisLookupZidormi[poiID] = true
      end
    end
  end
end

local function MN_IsValidPin(pin)
  if not pin then return false end
  if InCombatLockdown and InCombatLockdown() then return false end
  if pin.IsForbidden and pin:IsForbidden() then return false end
  if pin.IsProtected and pin:IsProtected() then return false end

  local ot = pin.GetObjectType and pin:GetObjectType()
  if ot and ot ~= "Frame" and ot ~= "Button" then
    return false
  end

  return true
end

local function MN_GetAreaPoiID(pin)
  if not pin then return nil end
  local info = pin.poiInfo
  return pin.areaPoiID or (info and info.areaPoiID)
end

local function MN_IsAreaPOIPin(pin)
  if not pin then return false end

  local areaPoiID = MN_GetAreaPoiID(pin)
  if not areaPoiID then return false end
  if not pin.poiInfo then return false end

  return true
end

local function MN_GetVignetteIDFromPin(pin)
  if not pin then return nil end

  if pin.vignetteGUID and C_VignetteInfo and C_VignetteInfo.GetVignetteInfo then
    local ok, info = pcall(C_VignetteInfo.GetVignetteInfo, pin.vignetteGUID)
    if ok and info and info.vignetteID then
      return info.vignetteID
    end
  end

  return pin.vignetteID
end

local function MN_IsTrackedVignettePin(pin)
  if not pin then return false end
  if not ns.HiddenBlizzVignetteIDs then return false end

  local vignetteID = MN_GetVignetteIDFromPin(pin)
  return vignetteID and ns.HiddenBlizzVignetteIDs[vignetteID] or false
end

local function MN_GetPinIdentity(pin)
  if not pin then return nil end

  if MN_IsAreaPOIPin(pin) then
    local areaPoiID = MN_GetAreaPoiID(pin)
    if areaPoiID then
      return "area", areaPoiID
    end
  end

  local vignetteID = MN_GetVignetteIDFromPin(pin)
  if vignetteID then
    return "vignette", vignetteID
  end

  return nil
end

local function MN_ShouldHideIdentity(kind, id)
  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg then return false end
  if cfg.HideMapNote then return false end

  MN_BuildLookups()

  if kind == "area" then
    if cfg.RemoveBlizzPOIs and ns.BlizzAreaPoisLookup[id] then
      return true
    end
    if cfg.RemoveBlizzPOIsZidormi and ns.BlizzAreaPoisLookupZidormi[id] then
      return true
    end
    return false
  end

  if kind == "vignette" then
    if cfg.RemoveBlizzPOIs and ns.HiddenBlizzVignetteIDs and ns.HiddenBlizzVignetteIDs[id] then
      return true
    end
    return false
  end

  return false
end

local function MN_AttachPinGuard(pin)
  if not MN_IsValidPin(pin) then return end
  if pin.MN_GuardHooked then return end
  pin.MN_GuardHooked = true

  local function MN_GuardRefresh(self)
    if not self.MN_HiddenByMapNotes then return end

    local currentKind, currentID = MN_GetPinIdentity(self)

    if currentKind ~= self.MN_HiddenKind or currentID ~= self.MN_HiddenID then
      local restoreAlpha = self.MN_OldAlpha or 1
      local restoreMouse = self.MN_OldMouseEnabled ~= false
    
      self.MN_HiddenByMapNotes = nil
      self.MN_HiddenKind = nil
      self.MN_HiddenID = nil
      self.MN_OldAlpha = nil
      self.MN_OldMouseEnabled = nil
    
      if self.SetAlpha then
        self:SetAlpha(restoreAlpha)
      end
      if self.EnableMouse then
        self:EnableMouse(restoreMouse)
      end
      return
    end

    if not MN_ShouldHideIdentity(currentKind, currentID) then
      local restoreAlpha = self.MN_OldAlpha or 1
      local restoreMouse = self.MN_OldMouseEnabled ~= false
    
      self.MN_HiddenByMapNotes = nil
      self.MN_HiddenKind = nil
      self.MN_HiddenID = nil
      self.MN_OldAlpha = nil
      self.MN_OldMouseEnabled = nil
    
      if self.SetAlpha then
        self:SetAlpha(restoreAlpha)
      end
      if self.EnableMouse then
        self:EnableMouse(restoreMouse)
      end
      return
    end

    if self.SetAlpha and self:GetAlpha() ~= 0 then
      self:SetAlpha(0)
    end
    if self.EnableMouse and self:IsMouseEnabled() then
      self:EnableMouse(false)
    end
  end

  if pin.HookScript then
    pin:HookScript("OnShow", MN_GuardRefresh)
  end

  hooksecurefunc(pin, "SetAlpha", function(self, alpha)
    if self.MN_HiddenByMapNotes and alpha and alpha > 0 then
      MN_GuardRefresh(self)
    end
  end)

  if pin.EnableMouse then
    hooksecurefunc(pin, "EnableMouse", function(self, enabled)
      if self.MN_HiddenByMapNotes and enabled then
        MN_GuardRefresh(self)
      end
    end)
  end

  if pin.Show then
    hooksecurefunc(pin, "Show", function(self)
      if self.MN_HiddenByMapNotes then
        MN_GuardRefresh(self)
      end
    end)
  end
end

local function MN_HidePin(pin)
  if not MN_IsValidPin(pin) then return end

  local kind, id = MN_GetPinIdentity(pin)
  if not kind or not id then return end

  if not pin.MN_HiddenByMapNotes then
    pin.MN_HiddenByMapNotes = true
    pin.MN_HiddenKind = kind
    pin.MN_HiddenID = id
    pin.MN_OldAlpha = pin.GetAlpha and pin:GetAlpha() or 1
    pin.MN_OldMouseEnabled = pin.IsMouseEnabled and pin:IsMouseEnabled() or true
    MN_AttachPinGuard(pin)
  else
    pin.MN_HiddenKind = kind
    pin.MN_HiddenID = id
  end

  if pin.SetAlpha and pin:GetAlpha() ~= 0 then
    pin:SetAlpha(0)
  end

  if pin.EnableMouse and pin:IsMouseEnabled() then
    pin:EnableMouse(false)
  end
end

local function MN_RestorePin(pin)
  if not MN_IsValidPin(pin) then return end
  if not pin.MN_HiddenByMapNotes then return end

  if pin.SetAlpha then
    pin:SetAlpha(pin.MN_OldAlpha or 1)
  end

  if pin.EnableMouse then
    pin:EnableMouse(pin.MN_OldMouseEnabled ~= false)
  end

  pin.MN_HiddenByMapNotes = nil
  pin.MN_HiddenKind = nil
  pin.MN_HiddenID = nil
  pin.MN_OldAlpha = nil
  pin.MN_OldMouseEnabled = nil
end

function ns.QueueRemovePOIs()
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or cfg.HideMapNote then return end
  if not (cfg.RemoveBlizzPOIs or cfg.RemoveBlizzPOIsZidormi) then return end

  if InCombatLockdown and InCombatLockdown() then
    ns._RemovePOIsAfterCombat = true

    if not ns._RemovePOIsCombatFrame then
      ns._RemovePOIsCombatFrame = CreateFrame("Frame")
      ns._RemovePOIsCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
      ns._RemovePOIsCombatFrame:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        ns._RemovePOIsCombatFrame = nil

        if ns._RemovePOIsAfterCombat then
          ns._RemovePOIsAfterCombat = nil
          ns.QueueRemovePOIs()
        end
      end)
    end

    return
  end

  if ns._RemovePOIsQueued then return end
  ns._RemovePOIsQueued = true

  MN_Post(function()
    ns._RemovePOIsQueued = nil
    if ns.RemovePOIs then
      ns.RemovePOIs()
    end
  end)
end

local function MN_ApplyVignetteVisibility(pin)
  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or not cfg.RemoveBlizzPOIs then return end
  if not MN_IsTrackedVignettePin(pin) then return end

  ns.QueueRemovePOIs()
end

if VignettePinMixin then
  if VignettePinMixin.SetVignette then
    hooksecurefunc(VignettePinMixin, "SetVignette", MN_ApplyVignetteVisibility)
  end
  if VignettePinMixin.OnAcquired then
    hooksecurefunc(VignettePinMixin, "OnAcquired", MN_ApplyVignetteVisibility)
  end
  if VignettePinMixin.OnRefresh then
    hooksecurefunc(VignettePinMixin, "OnRefresh", MN_ApplyVignetteVisibility)
  end
end

local function MN_MapHasRelevantActivePins()
  if not (WorldMapFrame and WorldMapFrame.pinPools) then return false end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then
    return false
  end

  MN_BuildLookups()

  for _, pool in pairs(WorldMapFrame.pinPools) do
    for pin in pool:EnumerateActive() do
      if MN_IsValidPin(pin) then
        if cfg.RemoveBlizzPOIs and MN_IsTrackedVignettePin(pin) then
          return true
        end

        if MN_IsAreaPOIPin(pin) then
          local areaPoiID = MN_GetAreaPoiID(pin)
          if areaPoiID then
            if cfg.RemoveBlizzPOIs and ns.BlizzAreaPoisLookup[areaPoiID] then
              return true
            end
            if cfg.RemoveBlizzPOIsZidormi and ns.BlizzAreaPoisLookupZidormi[areaPoiID] then
              return true
            end
          end
        end
      end
    end
  end

  return false
end

function ns.RemovePOIs()
  if InCombatLockdown and InCombatLockdown() then return end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg then return end
  if cfg.HideMapNote then return end
  if not (cfg.RemoveBlizzPOIs or cfg.RemoveBlizzPOIsZidormi) then return end
  if not (WorldMapFrame and WorldMapFrame.pinPools) then return end

  MN_BuildLookups()

  for _, pinPool in pairs(WorldMapFrame.pinPools) do
    for pin in pinPool:EnumerateActive() do
      if MN_IsValidPin(pin) then
        local shouldHide = false
        local isManagedByUs = false
        local kind, id = MN_GetPinIdentity(pin)

        if kind and id then
          shouldHide = MN_ShouldHideIdentity(kind, id)

          if shouldHide then
            isManagedByUs = true
          elseif pin.MN_HiddenByMapNotes then
            isManagedByUs = true
          end
        elseif pin.MN_HiddenByMapNotes then
          isManagedByUs = true
        end

        if isManagedByUs then
          if shouldHide then
            MN_HidePin(pin)
          else
            MN_RestorePin(pin)
          end
        end
      end
    end
  end
end

local function MN_TryHookProvider(dp)
  if not dp or ns.AreaPOIHooked[dp] then return end
  if type(dp.RefreshAllData) ~= "function" then return end
  if type(dp.GetPinTemplate) ~= "function" then return end
  if dp.GetPinTemplates then return end

  local ok, tmpl = pcall(dp.GetPinTemplate, dp)
  if not ok or tmpl ~= "AreaPOIPinTemplate" then
    return
  end

  ns.AreaPOIHooked[dp] = true

  hooksecurefunc(dp, "RefreshAllData", function()
    local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
    if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then
      return
    end

    if WorldMapFrame and WorldMapFrame:IsShown() and MN_MapHasRelevantActivePins() then
      ns.QueueRemovePOIs()
    end
  end)
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

eventFrame:SetScript("OnEvent", function()
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then return end
  if not MN_MapHasRelevantActivePins() then return end

  ns.QueueRemovePOIs()
end)

local function MN_ShouldListenPOIEvent()
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return false end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg or (not cfg.RemoveBlizzPOIs and not cfg.RemoveBlizzPOIsZidormi) then
    return false
  end

  if cfg.RemoveBlizzPOIs and ns.HiddenBlizzVignetteIDs and next(ns.HiddenBlizzVignetteIDs) then
    return true
  end

  return MN_MapHasRelevantActivePins()
end

function ns.RegisterPOIEvent()
  if eventFrame._registered then return end
  if not MN_ShouldListenPOIEvent() then return end

  eventFrame:RegisterEvent("AREA_POIS_UPDATED")
  eventFrame:RegisterEvent("VIGNETTES_UPDATED")
  eventFrame._registered = true
end

function ns.UnregisterPOIEvent()
  if not eventFrame._registered then return end

  eventFrame:UnregisterEvent("AREA_POIS_UPDATED")
  eventFrame:UnregisterEvent("VIGNETTES_UPDATED")
  eventFrame._registered = false
end

function ns.RebindPOIEvent()
  if MN_ShouldListenPOIEvent() then
    if ns.RegisterPOIEvent then
      ns.RegisterPOIEvent()
    end
  else
    if ns.UnregisterPOIEvent then
      ns.UnregisterPOIEvent()
    end
  end
end

local function MN_OnMapChanged()
  if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end

  local cfg = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not cfg then return end

  if cfg.RemoveBlizzPOIs or cfg.RemoveBlizzPOIsZidormi then
    ns.BlizzAreaPoisLookup = nil
    ns.BlizzAreaPoisLookupZidormi = nil
  end

  ns.RebindPOIEvent()

  if (cfg.RemoveBlizzPOIs or cfg.RemoveBlizzPOIsZidormi) and MN_MapHasRelevantActivePins() then
    ns.QueueRemovePOIs()
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
    hooksecurefunc(WorldMapFrame, "Show", function()
      MN_Post(function()
        ns.RegisterPOIEvent()
        ns.QueueRemovePOIs()
      end)
    end)
  end

  if not ns.POIHideHooked then
    ns.POIHideHooked = true
    hooksecurefunc(WorldMapFrame, "Hide", function()
      MN_Post(function()
        ns.UnregisterPOIEvent()
      end)
    end)
  end

  if WorldMapFrame:IsShown() then
    MN_Post(function()
      ns.RegisterPOIEvent()
      ns.QueueRemovePOIs()
    end)
  end
end)