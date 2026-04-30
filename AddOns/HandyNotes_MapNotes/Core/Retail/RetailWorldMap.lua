local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.ChangingMapToPlayerZone()
  if ns.MapChangeInit then return end
  ns.MapChangeInit = true

  local lastBestMapID = C_Map.GetBestMapForUnit("player")
  local function SetToPlayerMap()
    local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
    if not (db and db.MapChanging) then return end

    local target = C_Map.GetBestMapForUnit("player")
    if not target then return end

    if target == lastBestMapID then return end
    lastBestMapID = target

    if WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame:GetMapID() ~= target then
      ns.MapNotesOpenMap(target)
      if db.DeveloperMode then
        local mi = C_Map.GetMapInfo(target)
        print("Switched map to:", target, mi and mi.name)
      end
    end
  end

  local Worldmap = CreateFrame("Frame")
  Worldmap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  Worldmap:RegisterEvent("ZONE_CHANGED")
  Worldmap:RegisterEvent("ZONE_CHANGED_INDOORS")
  Worldmap:RegisterEvent("NEW_WMO_CHUNK") -- micro maps
  Worldmap:SetScript("OnEvent", SetToPlayerMap)
end

function ns.ShowPlayersMap(targetType)
  local PlayerMapID = C_Map.GetBestMapForUnit("player")
  if not PlayerMapID then return end

  local info = C_Map.GetMapInfo(PlayerMapID)
  while info and info.mapType and info.mapType > targetType and info.parentMapID do
    info = C_Map.GetMapInfo(info.parentMapID)
  end

  if info and info.mapType == targetType then
    ns.MapNotesOpenMap(info.mapID)
  end
end

do
  local GroupMembersPin
  local ArrowSizesTable
  local function EnsureArrowData()
    if GroupMembersPin and ArrowSizesTable then return true end
    if not (WorldMapFrame and WorldMapFrame.EnumeratePinsByTemplate) then return false end
    for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
      if pin.dataProvider and pin.dataProvider.GetUnitPinSizesTable then
        GroupMembersPin = pin
        ArrowSizesTable = pin.dataProvider:GetUnitPinSizesTable()
        return true
      end
    end
    return false
  end

  function ns.ApplyWorldMapArrowSize()
    if not EnsureArrowData() then return end
  
    local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
    local activate = db and db.activate
  
    if activate and activate.HideMapNote then
      ArrowSizesTable.player = 27
      GroupMembersPin:SynchronizePinSizes()
      return
    end
  
    if activate and activate.WorldMapArrow then
      ArrowSizesTable.player = 27 * (activate.WorldMapArrowScale or 1)
    else
      ArrowSizesTable.player = 27
    end
    GroupMembersPin:SynchronizePinSizes()
  end
end

local f = CreateFrame("Frame")
local function HookWorldMap()
  if f._hooked then return end
  if not WorldMapFrame then return end
  WorldMapFrame:HookScript("OnShow", ns.ApplyWorldMapArrowSize)
  f._hooked = true
end

HookWorldMap()

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, addon)
  if addon == "Blizzard_WorldMap" then
    HookWorldMap()
  end
end)

ns._wmArrowPingActive = ns._wmArrowPingActive or false
ns._wmArrowPingPin = ns._wmArrowPingPin or nil
ns._wmArrowRestartTimer = ns._wmArrowRestartTimer or nil
ns._wmArrowHighlightHooked = ns._wmArrowHighlightHooked or false
local function GetWorldMapPlayerPingPin()
  if not (WorldMapFrame and WorldMapFrame.dataProviders) then return nil end

  for provider in pairs(WorldMapFrame.dataProviders) do
    if type(provider) == "table" and provider.ShouldShowUnit and provider:ShouldShowUnit("player") then
      if provider.pin and provider.pin.StartPlayerPing then
        return provider.pin
      end
      break
    end
  end

  return nil
end

local function StopWorldMapArrowHighlight()
  if ns._wmArrowRestartTimer and ns._wmArrowRestartTimer.Cancel then
    ns._wmArrowRestartTimer:Cancel()
  end
  ns._wmArrowRestartTimer = nil

  if ns._wmArrowPingPin and ns._wmArrowPingPin.StartPlayerPing then
    ns._wmArrowPingPin:StartPlayerPing(0.01)
  end

  ns._wmArrowPingActive = false
  ns._wmArrowPingPin = nil
end

function ns.RefreshWorldMapArrowHighlight()
  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  local enabled = act and act.WorldMapArrowHighlight
  if not enabled or not (WorldMapFrame and WorldMapFrame:IsShown()) then
    StopWorldMapArrowHighlight()
    return
  end

  if ns._wmArrowPingActive then return end

  local pin = GetWorldMapPlayerPingPin()
  if pin and pin.StartPlayerPing then
    ns._wmArrowPingPin = pin
    ns._wmArrowPingActive = true
    pin:StartPlayerPing(99999)
  end
end

local function RestartWorldMapArrowHighlight()
  if ns._wmArrowRestartTimer and ns._wmArrowRestartTimer.Cancel then
    ns._wmArrowRestartTimer:Cancel()
  end
  ns._wmArrowRestartTimer = nil

  StopWorldMapArrowHighlight()

  local tries = 0
  local function TryStart()
    tries = tries + 1

    local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
    local enabled = act and act.WorldMapArrowHighlight
    if not enabled or not (WorldMapFrame and WorldMapFrame:IsShown()) then
      StopWorldMapArrowHighlight()
      return
    end

    ns.RefreshWorldMapArrowHighlight()

    if ns._wmArrowPingActive then
      ns._wmArrowRestartTimer = nil
      return
    end

    if tries < 12 then
      ns._wmArrowRestartTimer = C_Timer.NewTimer(0.05, TryStart)
    else
      ns._wmArrowRestartTimer = nil
    end
  end

  ns._wmArrowRestartTimer = C_Timer.NewTimer(0.01, TryStart)
end

local function HookWorldMapArrowHighlight()
  if ns._wmArrowHighlightHooked then return end
  if not WorldMapFrame then return end

  WorldMapFrame:HookScript("OnShow", function()
    ns.RefreshWorldMapArrowHighlight()
  end)

  WorldMapFrame:HookScript("OnHide", function()
    StopWorldMapArrowHighlight()
  end)

  hooksecurefunc(WorldMapFrame, "SetMapID", function()
    local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
    if act and act.WorldMapArrowHighlight and WorldMapFrame and WorldMapFrame:IsShown() then
      RestartWorldMapArrowHighlight()
    end
  end)

  ns._wmArrowHighlightHooked = true
end

if WorldMapFrame then
  HookWorldMapArrowHighlight()
else
  if not ns._wmArrowLoadFrame then
    ns._wmArrowLoadFrame = CreateFrame("Frame")
    ns._wmArrowLoadFrame:RegisterEvent("ADDON_LOADED")
    ns._wmArrowLoadFrame:SetScript("OnEvent", function(_, _, addonName)
      if addonName == "Blizzard_WorldMap" then
        HookWorldMapArrowHighlight()
      end
    end)
  end
end