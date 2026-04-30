local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local HBDP = LibStub("HereBeDragons-Pins-2.0", true)
ns.MN_DelveActivePins = ns.MN_DelveActivePins or setmetatable({}, { __mode = "k" })

ns.continentDelveToggles = ns.continentDelveToggles or {
  [2274] = "showContinentKhazAlgar",
  [13]   = "showContinentEasternKingdom",
  [2537] = "showContinentQuelThalas",
}

ns.zoneDelveToggles = ns.zoneDelveToggles or {
  [2248] = "showZoneKhazAlgar",
  [2214] = "showZoneKhazAlgar",
  [2215] = "showZoneKhazAlgar",
  [2255] = "showZoneKhazAlgar",
  [2256] = "showZoneKhazAlgar",
  [2213] = "showZoneKhazAlgar",
  [2216] = "showZoneKhazAlgar",
  [2369] = "showZoneKhazAlgar",
  [2322] = "showZoneKhazAlgar",
  [2346] = "showZoneKhazAlgar",
  [2371] = "showZoneKhazAlgar",
  [2472] = "showZoneKhazAlgar",

  [2395] = "showZoneQuelThalas",
  [2437] = "showZoneQuelThalas",
  [2424] = "showZoneQuelThalas",
  [2405] = "showZoneQuelThalas",
  [2444] = "showZoneQuelThalas",
  [2413] = "showZoneQuelThalas",
  [2536] = "showZoneQuelThalas",
  [2576] = "showZoneQuelThalas",
}

ns.capitalDelveToggles = ns.capitalDelveToggles or {
  [2393] = true,
}

local function MN_IsBountiful(atlasName)
  return atlasName and atlasName:lower():find("bountiful") ~= nil
end

local function MN_DB()
  return ns.Addon and ns.Addon.db and ns.Addon.db.profile
end

local function MN_ShouldShow(kind, mapID, atlasName)
  local db = MN_DB()
  if not db then return false end
  if db.activate and db.activate.HideMapNote then return false end

  local isB = MN_IsBountiful(atlasName)

  if kind == "capital" then
    if not db.activate.Capitals then return false end
    if not db.activate.CapitalsInstances then return false end
    if not db.showCapitalsDelve and not db.showCapitalsBountyDelve then return false end
    if isB and not db.showCapitalsBountyDelve then return false end
    if (not isB) and not db.showCapitalsDelve then return false end
    return true
  end

  if kind == "zone" then
    if not db.activate.ZoneMap then return false end
    if not db.activate.ZoneInstances then return false end
    if not db.showZoneDelve and not db.showZoneBountyDelve then return false end
    if isB and not db.showZoneBountyDelve then return false end
    if (not isB) and not db.showZoneDelve then return false end
    local k = ns.zoneDelveToggles and ns.zoneDelveToggles[mapID]
    if k and not db[k] then return false end
    return true
  end

  if kind == "continent" then
    if not db.activate.Continent then return false end
    if not db.showContinentDelves and not db.showContinentBountyDelves then return false end
    if isB and not db.showContinentBountyDelves then return false end
    if (not isB) and not db.showContinentDelves then return false end
    local k = ns.continentDelveToggles and ns.continentDelveToggles[mapID]
    if k and not db[k] then return false end
    return true
  end

  return false
end

local function MN_ApplyDelveScaleAlpha(pin, pinInfo)
  local db = MN_DB()
  if not db or not pin or not pinInfo then return end

  local kind = pinInfo.mnMapNotesKind or pin.mnKind
  local atlas = pinInfo.atlasName
  local isBountiful = MN_IsBountiful(atlas)

  local scale, alpha
  if kind == "continent" then
    scale = (db.continentScale or 1) * 1.5
    if isBountiful then
      scale = scale * 0.75
    end
    alpha = db.continentAlpha or 1
  elseif kind == "capital" then
    scale = (db.CapitalsInstanceScale or 1) * 1.5
    alpha = db.CapitalsInstanceAlpha or 1
  else
    scale = isBountiful and ((db.ZoneScaleBountyDelve or 1) * 1.5) or ((db.ZoneScaleDelve or 1) * 1.5)
    if isBountiful then
      scale = scale * 0.75
    end
    alpha = isBountiful and (db.ZoneAlphaBountyDelve or 1) or (db.ZoneAlphaDelve or 1)
  end

  pin:SetAlpha(alpha)
  pin:SetScale(scale)

  if pin.texture then
    pin.texture:SetAlpha(1)
  end
end

local function MN_ExtractWidgetText(widgetSetID)
  if not widgetSetID then return end
  local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID)
  if not widgets then return end

  local lines = {}

  for _, w in ipairs(widgets) do
    if w.widgetType == Enum.UIWidgetVisualizationType.TextWithState then
      local info = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(w.widgetID)
      if info and info.text and info.text ~= "" then
        lines[#lines + 1] = {
          orderIndex = info.orderIndex or 999,
          text = info.text,
        }
      end
    end
  end

  table.sort(lines, function(a, b)
    return a.orderIndex < b.orderIndex
  end)

  local firstLine = lines[1] and lines[1].text or nil
  local secondLine = lines[2] and lines[2].text or nil
  return firstLine, secondLine
end

local function MN_DelveSetWaypoint(self)
  local db = MN_DB()
  if not db or not db.WayPoints then return false end

  local info = self.mnPinInfo
  if not info then return false end

  local uiMapID = info.mnWaypointMapID
  local x = info.mnWaypointX
  local y = info.mnWaypointY

  if not uiMapID or not x or not y then return false end
  if uiMapID == 946 then return false end
  if not C_Map.GetMapInfo(uiMapID) then return false end

  if TomTom then
    local title = (info.name and info.name ~= "" and info.name) or (DELVES_LABEL or "Delve")
    TomTom:AddWaypoint(uiMapID, x, y, {
      title = title,
      persistent = nil,
      minimap = true,
      world = true,
    })
    return true
  end

  if ns.MN_SetTrackedUserWaypoint then
    return ns.MN_SetTrackedUserWaypoint(uiMapID, x, y)
  end

  return false
end

local PinMixin = {}
function PinMixin:OnLoad()
  self:SetSize(18, 18)
  self.texture = self:CreateTexture(nil, "ARTWORK")
  self.texture:SetAllPoints()
  self:SetScript("OnEnter", self.OnMouseEnter)
  self:SetScript("OnLeave", self.OnMouseLeave)
  self:SetScript("OnMouseUp", self.OnMouseUp)
  self:EnableMouse(true)
end

function PinMixin:OnAcquire(kind, info)
  self.mnKind = kind
  self.mnPinInfo = info

  info.mnMapNotesKind = kind

  if info.atlasName and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(info.atlasName) then
    self.texture:SetAtlas(info.atlasName, true)
  else
    self.texture:SetTexture(nil)
  end

  MN_ApplyDelveScaleAlpha(self, info)
end

function PinMixin:OnMouseEnter()
  local info = self.mnPinInfo
  if not info then return end

  local tooltip = GetAppropriateTooltip()
  tooltip:SetOwner(self, "ANCHOR_RIGHT")

  local line1, line2 = MN_ExtractWidgetText(info.widgetSetID or info.tooltipWidgetSet)

  if info.name and info.name ~= "" then
    GameTooltip_SetTitle(tooltip, info.name, HIGHLIGHT_FONT_COLOR)
  elseif line1 and line1 ~= "" then
    GameTooltip_SetTitle(tooltip, line1, HIGHLIGHT_FONT_COLOR)
    line1 = nil
  end

  local typeText
  if MN_IsBountiful(info.atlasName) then
    typeText = "Bountiful Delve"
  else
    typeText = DELVES_LABEL or "Delve"
  end

  GameTooltip_AddColoredLine(tooltip, typeText, NORMAL_FONT_COLOR, true)

  if line1 and line1 ~= "" then
    GameTooltip_AddColoredLine(tooltip, line1, NORMAL_FONT_COLOR, true)
  elseif info.description and info.description ~= "" then
    GameTooltip_AddColoredLine(tooltip, info.description, NORMAL_FONT_COLOR, true)
  end

  if line2 and line2 ~= "" then
    GameTooltip_AddColoredLine(tooltip, line2, NORMAL_FONT_COLOR, true)
  end

  if ns.Addon.db.profile.TooltipInformations and not ns.Addon.db.profile.activate.HideMapNote then
    if ns.Addon.db.profile.activate.ToggleMap then
      tooltip:AddLine(" ")
      local mapButtonText = (ns.Addon.db.profile.activate.SwapButtons and KEY_BUTTON2) or KEY_BUTTON1
      tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " |cff00ff00< " .. mapButtonText .. " " .. L["to show delve map"] .. " >|r", nil, nil, nil, false)
    elseif ns.Addon.db.profile.activate.ToggleMapInfo and WorldMapFrame and WorldMapFrame:IsShown() then
      tooltip:AddLine(" ")
      tooltip:AddDoubleLine( "|cff00ff00" .. L["Toggle Maps function is disabled"] .. "|r",  nil, nil, nil, false )
    end
  end

  tooltip:Show()
end

function PinMixin:OnMouseLeave()
  GetAppropriateTooltip():Hide()
end

function PinMixin:OnMouseUp(button)
  local db = MN_DB()
  if not db then return end
  if db.activate and db.activate.HideMapNote then return end

  local info = self.mnPinInfo
  if not info or not info.areaPoiID then return end

  local swapButtons = db.activate and db.activate.SwapButtons
  local useShift = db.WayPointsShift
  local waypointButton = swapButtons and "LeftButton" or "RightButton"
  local mapButton = swapButtons and "RightButton" or "LeftButton"

  if db.WayPoints then
    local waypointClicked
    if useShift then
      waypointClicked = (button == waypointButton and IsShiftKeyDown())
    else
      waypointClicked = (button == waypointButton)
    end

    if waypointClicked then
      if MN_DelveSetWaypoint(self) then
        return
      end
    end
  end

  if button == mapButton and not IsShiftKeyDown() then
    local id = info.areaPoiID
    local target =
      (ns.BlizzDelveAreaPoisInfoIDs and ns.BlizzDelveAreaPoisInfoIDs[id]) or
      (ns.BlizzBountifulDelveAreaPoisInfoIDs and ns.BlizzBountifulDelveAreaPoisInfoIDs[id])

    if target then
      ns.MapNotesOpenMap(target)
    end
  end
end

local pool = CreateFramePool(
  "Frame",
  nil,
  nil,
  function(_, frame)
    frame:SetScale(1)
    frame:SetAlpha(1)
    if frame.texture then
      frame.texture:SetVertexColor(1, 1, 1, 1)
    end
  end,
  nil,
  function(frame)
    Mixin(frame, PinMixin)
    frame:OnLoad()
  end
)

local function MN_GetRect(fromMapID, toMapID)
  local a, b, c, d = C_Map.GetMapRectOnMap(fromMapID, toMapID)
  if not a then return end
  if type(a) == "table" and b and type(b) == "table" then
    local minX, minY, maxX, maxY
    if a.GetXY then
      minX, minY = a:GetXY()
      maxX, maxY = b:GetXY()
    else
      minX, minY = a.x, a.y
      maxX, maxY = b.x, b.y
    end
    if minX and maxX and minY and maxY then
      return minX, maxX, minY, maxY
    end
    return
  end
  return a, b, c, d
end

local function MN_IsCapitalMap(mapID)
  return ns.capitalDelveToggles and ns.capitalDelveToggles[mapID] and true or false
end

local function MN_AddDelvesOnSameMap(kind, mapID)
  local delves = C_AreaPoiInfo.GetDelvesForMap(mapID) or {}
  for _, areaPoiID in ipairs(delves) do
    local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
    if info and info.position then
      local x, y = info.position:GetXY()
      if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
        if MN_ShouldShow(kind, mapID, info.atlasName) then
          local pinInfo = CopyTable(info)
          pinInfo.areaPoiID = areaPoiID
          pinInfo.mnMapNotesKind = kind
          pinInfo.mnWaypointMapID = mapID
          pinInfo.mnWaypointX = x
          pinInfo.mnWaypointY = y

          local icon = pool:Acquire()
          icon:OnAcquire(kind, pinInfo)
          ns.MN_DelveActivePins[icon] = true

          if HBDP then
            HBDP:AddWorldMapIconMap(ADDON_NAME, icon, mapID, x, y)
            icon:SetFrameLevel(math.max(icon:GetFrameLevel() - 5, 5))
          
            C_Timer.After(0, function()
              if icon then
                icon:SetFrameLevel(math.max(icon:GetFrameLevel() - 5, 5))
              end
            end)
          end
        end
      end
    end
  end
end

local function MN_ProjectZoneDelvesToContinent(continentMapID, zoneMapID)
  local minX, maxX, minY, maxY = MN_GetRect(zoneMapID, continentMapID)
  if not minX then return end

  local delves = C_AreaPoiInfo.GetDelvesForMap(zoneMapID) or {}
  for _, areaPoiID in ipairs(delves) do
    local info = C_AreaPoiInfo.GetAreaPOIInfo(zoneMapID, areaPoiID)
    if info and info.position then
      if MN_ShouldShow("continent", continentMapID, info.atlasName) then
        local x, y = info.position:GetXY()
        if x and y then
          local tx = Lerp(minX, maxX, x)
          local ty = Lerp(minY, maxY, y)
          if tx and ty and tx >= 0 and tx <= 1 and ty >= 0 and ty <= 1 then
            local pinInfo = CopyTable(info)
            pinInfo.areaPoiID = areaPoiID
            pinInfo.mnMapNotesKind = "continent"
            pinInfo.mnWaypointMapID = continentMapID
            pinInfo.mnWaypointX = tx
            pinInfo.mnWaypointY = ty
          
            local icon = pool:Acquire()
            icon:OnAcquire("continent", pinInfo)
            ns.MN_DelveActivePins[icon] = true
          
            if HBDP then
              HBDP:AddWorldMapIconMap(ADDON_NAME, icon, continentMapID, tx, ty)
              icon:SetFrameLevel(math.max(icon:GetFrameLevel() - 5, 5))
            
              C_Timer.After(0, function()
                if icon then
                  icon:SetFrameLevel(math.max(icon:GetFrameLevel() - 5, 5))
                end
              end)
            end
          end
        end
      end
    end
  end
end

local function MN_ClearAll()
  if ns.MN_DelveActivePins then
    for pin in pairs(ns.MN_DelveActivePins) do
      ns.MN_DelveActivePins[pin] = nil
    end
  end
  pool:ReleaseAll()
  if HBDP then
    HBDP:RemoveAllWorldMapIcons(ADDON_NAME)
  end
end

local function MN_RefreshMap(mapID)
  if not HBDP then return end
  if not mapID then return end

  local db = MN_DB()
  if not db or (db.activate and db.activate.HideMapNote) then
    MN_ClearAll()
    return
  end

  MN_ClearAll()

  local mapInfo = C_Map.GetMapInfo(mapID)
  if not mapInfo then return end

  if MN_IsCapitalMap(mapID) then
    MN_AddDelvesOnSameMap("capital", mapID)
    return
  end

  if mapInfo.mapType == Enum.UIMapType.Zone then
    MN_AddDelvesOnSameMap("zone", mapID)
    return
  end

  if mapInfo.mapType ~= Enum.UIMapType.Continent then
    return
  end

  local key = ns.continentDelveToggles[mapID]
  if key and not db[key] then return end

  local children = C_Map.GetMapChildrenInfo(mapID, nil, true) or {}
  for _, child in ipairs(children) do
    if child and child.mapID then
      if mapID ~= 13 or child.mapID ~= 2537 then
        if MN_GetRect(child.mapID, mapID) then
          MN_ProjectZoneDelvesToContinent(mapID, child.mapID)
        end
      end
    end
  end
end

local function MN_WireRefresh()
  if ns.MN_Delve_Wired then return end
  ns.MN_Delve_Wired = true

  EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    if EventRegistry and EventRegistry.RegisterCallback then
      EventRegistry:RegisterCallback("MapCanvas.MapSet", function(_, mapID)
        if mapID then MN_RefreshMap(mapID) end
      end)
    end

    if WorldMapFrame and WorldMapFrame.ScrollContainer and not ns.MN_Delve_HookedSize then
      ns.MN_Delve_HookedSize = true
      WorldMapFrame.ScrollContainer:HookScript("OnSizeChanged", function()
        if WorldMapFrame and WorldMapFrame:IsVisible() then
          local id = WorldMapFrame:GetMapID()
          if id then MN_RefreshMap(id) end
        end
      end)
    end

    if WorldMapFrame and not ns.MN_Delve_HookedShow then
      ns.MN_Delve_HookedShow = true
      WorldMapFrame:HookScript("OnShow", function()
        local id = WorldMapFrame:GetMapID()
        if id then MN_RefreshMap(id) end
      end)
    end

    if WorldMapFrame and WorldMapFrame:IsVisible() then
      local id = WorldMapFrame:GetMapID()
      if id then MN_RefreshMap(id) end
    end
  end)
end

function ns.RefreshContinentDelvesPins(opts)
  MN_WireRefresh()

  if opts and opts.remove then
    MN_ClearAll()
    return
  end

  if WorldMapFrame then
    local id = WorldMapFrame:GetMapID()
    if id then
      MN_RefreshMap(id)
    end
  end
end

function ns.RefreshCapitalsDelvesOnly(opts)
  MN_WireRefresh()
  if opts and opts.remove then
    MN_ClearAll()
    return
  end
  if WorldMapFrame then
    local id = WorldMapFrame:GetMapID()
    if id then MN_RefreshMap(id) end
  end
end

function ns.RefreshZoneDelvesOnly(opts)
  MN_WireRefresh()
  if opts and opts.remove then
    MN_ClearAll()
    return
  end
  if WorldMapFrame then
    local id = WorldMapFrame:GetMapID()
    if id then MN_RefreshMap(id) end
  end
end

function ns.RefreshContinentDelvesOnly(opts)
  MN_WireRefresh()
  if opts and opts.remove then
    MN_ClearAll()
    return
  end
  if WorldMapFrame then
    local id = WorldMapFrame:GetMapID()
    if id then MN_RefreshMap(id) end
  end
end

function ns.BlizzardDelvesAddFunction()
  MN_WireRefresh()
  if ns.RefreshContinentDelvesPins then
    ns.RefreshContinentDelvesPins()
  end
end