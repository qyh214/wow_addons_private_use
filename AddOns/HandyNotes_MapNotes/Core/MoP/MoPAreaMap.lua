--[[
    HandyNotes_MapNotes
    Copyright (c) 2025 BadBoyBarny
    All rights reserved.
]]

local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
ns.FogOfWarDataMists = ns.FogOfWarDataMists or _G.FogOfWarDataMistsGlobal

function ns.AreaMap()
  if not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu then return end
  ns.AreaMapFrame = BattlefieldMapFrame

  ns.savedDropdownStates = ns.savedDropdownStates or {
    showZoneIcons = true,
    showCapitalIcons = true,
    showCoords = true,
  }

  local AreaMapIcons = ns.AreaMapIcons or {}
  local AreaMapIconPool = ns.AreaMapIconPool or {}

  ns.AreaMapIcons = AreaMapIcons
  ns.AreaMapIconPool = AreaMapIconPool

  local areaMapTicker

  local function StartAreaMapTicker()
    if areaMapTicker then return end
    areaMapTicker = C_Timer.NewTicker(3, function()
      if ns.AreaMapFrame:IsShown() and WorldMapFrame:IsShown() then
        ns.UpdateAreaMapIcons()
      end
    end)
  end

  local function StopAreaMapTicker()
    if areaMapTicker then
      areaMapTicker:Cancel()
      areaMapTicker = nil
    end
  end

  ns.childMapIDs = {
    1454, 1456, 1458, 1954, 1947, 1457, 1453, 1455, 1955, 86, 125, 126
  }

  local function LoadAreaMapSetting()
    if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate then
      ns.showAreaMapDropDownMenu = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu

      if ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons == nil then
        ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons = false
      end

      if ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons == nil then
        ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons = false
      end

      ns.areaMapScale = ns.Addon.db.profile.areaMap.areaMapScale or 1.0
    end
  end

  local lastUpdate = 0

  local function GetScrollContainer()
    local mapID = C_Map.GetBestMapForUnit("player")
    local isChildMap = tContains(ns.childMapIDs, mapID)
    return ns.AreaMapFrame.ScrollContainer.Child, isChildMap
  end

  function ns.UpdateAreaMapIcons()
    local now = GetTime()
    if now - lastUpdate < 0.5 then return end
    lastUpdate = now
    if not ns.AreaMapFrame or not ns.AreaMapFrame:IsShown() then return end

    for _, pin in ipairs(AreaMapIcons) do
      pin:Hide()
      table.insert(AreaMapIconPool, pin)
    end
    wipe(AreaMapIcons)

    if not ns.showAreaMapDropDownMenu then return end
    local mapID = BattlefieldMapFrame:GetMapID()
    if not mapID or not ns.nodes[mapID] then return end

    local ScrollContainer, isChildMap = GetScrollContainer()

    if ScrollContainer:GetWidth() == 0 or ScrollContainer:GetHeight() == 0 then
      C_Timer.After(0.1, ns.UpdateAreaMapIcons)
      return
    end

    for coord, node in pairs(ns.nodes[mapID]) do
      if node and node.showInZone then
        local shouldShow = false
        if isChildMap and ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons then
          shouldShow = true
        elseif not isChildMap and ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons then
          shouldShow = true
        end

        if shouldShow then
          local x, y = HandyNotes:getXY(coord)
          if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
            local pin = tremove(AreaMapIconPool) or CreateFrame("Button", nil, ScrollContainer)
            pin:SetParent(ScrollContainer)
            pin:SetFrameStrata("HIGH")

            local width = ScrollContainer:GetWidth()
            local height = ScrollContainer:GetHeight()
            local scaleFactor = math.min(width, height)
            local size = (scaleFactor * 0.05) * (ns.areaMapScale or 1.0)
            pin:SetSize(size, size)

            local tex = pin.texture
            if not tex then
              tex = pin:CreateTexture(nil, "OVERLAY")
              tex:SetAllPoints()
              pin.texture = tex
            end

            local iconPath = ns.icons[node.type] or "Interface\\Icons\\INV_Misc_QuestionMark"
            if tex:GetTexture() ~= iconPath then
              tex:SetTexture(iconPath)
            end

            tex:Show()
            tex:SetAlpha(1)
            pin:Show()
            pin:SetAlpha(1)

            pin.coord = coord
            pin.uiMapID = mapID
            pin:SetPoint("CENTER", ScrollContainer, "TOPLEFT", x * width, -y * height)

            pin:SetScript("OnEnter", function(self)
              if self.lastTooltipCoord ~= self.coord or self.lastTooltipMapID ~= self.uiMapID then
                ns.pluginHandler.OnEnter(self, self.uiMapID, self.coord)
                self.lastTooltipCoord = self.coord
                self.lastTooltipMapID = self.uiMapID
              end
            end)

            pin:SetScript("OnLeave", function(self)
              ns.pluginHandler.OnLeave(self, self.uiMapID, self.coord)
              self.lastTooltipCoord = nil
              self.lastTooltipMapID = nil
            end)

            pin:SetScript("OnClick", function(self, button)
              local coord = self.coord
              local uiMapID = self.uiMapID
              local node = ns.nodes[uiMapID] and ns.nodes[uiMapID][coord]
              if not node then return end
              if node.mnID then
                BattlefieldMapFrame:SetMapID(node.mnID)
                ns.UpdateAreaMapIcons()
              else
                ns.pluginHandler.OnClick(ns.pluginHandler, button, true, uiMapID, coord)
              end
            end)

            table.insert(AreaMapIcons, pin)
          end
        end
      end
    end
  end

  local function loadAreaMapMapNotes()
    LoadAreaMapSetting()

    C_Timer.After(1, function()
      if not ns.AreaMapFrame then return end
    
      local eventFrame = CreateFrame("Frame")
      eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
      eventFrame:RegisterEvent("MAP_EXPLORATION_UPDATED")
      eventFrame:SetScript("OnEvent", function()
        if ns.AreaMapFrame:IsShown() then
          ns.ResetAreaMapToPlayerLocation()
        end
      end)
    
      ns.AreaMapFrame:HookScript("OnShow", function()
        ns.UpdateAreaMapIcons()
        ns.UpdateAreaMapFogOfWar()
      end)
      
    
      hooksecurefunc(ns.AreaMapFrame, "SetMapID", function()
        ns.UpdateAreaMapIcons()
        ns.UpdateAreaMapFogOfWar()
      end)
    
      hooksecurefunc(ns.AreaMapFrame.ScrollContainer, "SetPanTarget", ns.UpdateAreaMapIcons)
    
      BattlefieldMapFrame:HookScript("OnHide", function()
        StopAreaMapTicker()
      end)

      WorldMapFrame:HookScript("OnHide", function()
        StopAreaMapTicker()
      end)

      if ns.AreaMapFrame:IsShown() then
        ns.UpdateAreaMapIcons()
      end
    end)

    WorldMapFrame:HookScript("OnShow", function()

      if ns.AreaMapFrame and ns.AreaMapFrame:IsShown() then
        StartAreaMapTicker()
      end

      if ns.AreaMapFrame and ns.AreaMapFrame:IsShown() then
        C_Timer.After(0.05, ns.UpdateAreaMapIcons)
      end
    end)

  end

  loadAreaMapMapNotes()
  ns.UpdateAreaMapFogOfWar()
end


local function CreateAreaMapScaleSliderFrame()
  if ns.AreaMapSliderFrame then return end

  local clickCatcher = CreateFrame("Frame", nil, UIParent)
  clickCatcher:SetAllPoints(UIParent)
  clickCatcher:SetFrameStrata("BACKGROUND")
  clickCatcher:EnableMouse(true)
  clickCatcher:Hide()
  clickCatcher:SetScript("OnMouseDown", function()
    ns.AreaMapSliderFrame:Hide()
    clickCatcher:Hide()
  end)

  local function SliderToActual(slider, value)
    local min, max = slider:GetMinMaxValues()
    return max - (value - min)
  end

  local function ActualToSlider(slider, actual)
    local min, max = slider:GetMinMaxValues()
    return max - (actual - min)
  end

  local SliderFrame = CreateFrame("Frame", "MapNotesAreaMapScaleFrame", BattlefieldMapFrame, "BackdropTemplate")
  SliderFrame:SetSize(74, 174)
  SliderFrame:SetPoint("TOPLEFT", BattlefieldMapFrame, "TOPRIGHT", 0, 32)
  SliderFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 25, edgeSize = 25,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  SliderFrame:SetBackdropColor(0, 0, 0, 0.85)
  SliderFrame:EnableMouse(true)
  clickCatcher:SetFrameStrata("BACKGROUND")
  SliderFrame:SetFrameStrata("DIALOG")

  local title = SliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
  title:SetPoint("TOP", 0, -12)
  title:SetText("|cffffff00" .. L["symbol size"] .. "|r")

  local sliderBackdrop = CreateFrame("Frame", nil, SliderFrame, "BackdropTemplate")
  sliderBackdrop:SetSize(16, 130)
  sliderBackdrop:SetPoint("LEFT", SliderFrame, "LEFT", 24, -10)
  sliderBackdrop:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = false, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  sliderBackdrop:SetBackdropColor(0, 0, 0, 0.7)

  local slider = CreateFrame("Slider", "MapNotesAreaMapScaleSlider", sliderBackdrop)
  slider:SetOrientation("VERTICAL")
  slider:SetSize(8, 120)
  slider:SetPoint("CENTER", sliderBackdrop, "CENTER", 0, 0)
  slider:SetMinMaxValues(0.3, 2.0)
  slider:SetValueStep(0.1)
  slider:SetObeyStepOnDrag(true)
  slider:SetValue(ActualToSlider(slider, ns.areaMapScale or 1.0))

  local inputBox = CreateFrame("EditBox", nil, SliderFrame, "InputBoxTemplate")
  inputBox:SetSize(50, 20)
  inputBox:SetPoint("TOP", sliderBackdrop, "BOTTOM", 7, -8)
  inputBox:SetAutoFocus(false)
  inputBox:SetJustifyH("CENTER")
  inputBox:SetFontObject("GameFontHighlight")
  inputBox:SetText(string.format("%.2f", ns.areaMapScale or 1.0))

  inputBox:SetScript("OnEnterPressed", function(self)
    local val = tonumber(self:GetText())
    if val and val >= 0.3 and val <= 2.0 then
      slider:SetValue(ActualToSlider(slider, val))
      self:ClearFocus()
    else
      self:SetText(string.format("%.2f", ns.areaMapScale or 1.0))
    end
  end)

  slider:SetScript("OnValueChanged", function(self, value)
    local actual = SliderToActual(self, value)
    ns.areaMapScale = actual
    ns.Addon.db.profile.areaMap.areaMapScale = actual
    inputBox:SetText(string.format("%.2f", actual))
    ns.UpdateAreaMapIcons()
  end)

  local thumb = slider:CreateTexture(nil, "OVERLAY")
  thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
  thumb:SetSize(35, 35)
  slider:SetThumbTexture(thumb)

  local plusBtn = CreateFrame("Button", nil, SliderFrame)
  plusBtn:SetSize(18, 18)
  plusBtn:SetPoint("RIGHT", slider, "RIGHT", 20, 50)

  plusBtn.text = plusBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  plusBtn.text:SetFont("Fonts\\FRIZQT__.TTF", 20, "")
  plusBtn.text:SetPoint("CENTER")
  plusBtn.text:SetText("+")

  plusBtn:SetScript("OnClick", function()
    local min, max = slider:GetMinMaxValues()
    local new = math.min((ns.areaMapScale or 1.0) + 0.1, 2.0)
    slider:SetValue(ActualToSlider(slider, new))
  end)

  local minusBtn = CreateFrame("Button", nil, SliderFrame)
  minusBtn:SetSize(18, 18)
  minusBtn:SetPoint("RIGHT", slider, "RIGHT", 20, -50)

  minusBtn.text = minusBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  minusBtn.text:SetFont("Fonts\\FRIZQT__.TTF", 20, "")
  minusBtn.text:SetPoint("CENTER")
  minusBtn.text:SetText("-")

  minusBtn:SetScript("OnClick", function()
    local min, max = slider:GetMinMaxValues()
    local new = math.max((ns.areaMapScale or 1.0) - 0.1, 0.3)
    slider:SetValue(ActualToSlider(slider, new))
  end)

  clickCatcher:SetFrameStrata("BACKGROUND")
  clickCatcher:EnableMouse(true)
  clickCatcher:Hide()
  clickCatcher:SetScript("OnMouseDown", function()
    SliderFrame:Hide()
    clickCatcher:Hide()
  end)

  SliderFrame:HookScript("OnShow", function()
    SliderFrame:SetFrameStrata("DIALOG")
    clickCatcher:SetFrameStrata("BACKGROUND")
    clickCatcher:Show()
  end)

  SliderFrame:HookScript("OnHide", function()
    clickCatcher:Hide()
  end)

  table.insert(UISpecialFrames, "MapNotesAreaMapScaleFrame")

  SliderFrame:Hide()
  ns.AreaMapSliderFrame = SliderFrame
end

function ns.SetFogOfWarColor(info, r, g, b, a)
    local db = ns.Addon.db.profile
    db.FogOfWarColorR = r
    db.FogOfWarColorG = g
    db.FogOfWarColorB = b
    db.FogOfWarColorA = a
    db.areaMap.areaMapFogOfWarColorR = r
    db.areaMap.areaMapFogOfWarColorG = g
    db.areaMap.areaMapFogOfWarColorB = b
    db.areaMap.areaMapFogOfWarColorA = a

    ns.UpdateWorldMapFogOfWar()
    ns.UpdateAreaMapFogOfWar()
end


function ns.UpdateAreaMapFogOfWar()
  if not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu then return end
  if not ns.Addon.db.profile.areaMap.showAreaMapUnexploredAreas then return end
  if not ns.AreaMapFrame or not ns.AreaMapFrame:IsShown() then return end

  ns.AreaMapOverlayPool = ns.AreaMapOverlayPool or CreateTexturePool(ns.AreaMapFrame.ScrollContainer.Child, "ARTWORK")
  ns.AreaMapOverlayPool:ReleaseAll()

  local mapID = ns.AreaMapFrame:GetMapID()
  if not mapID then return end

  local artID = C_Map.GetMapArtID(mapID)
  local mapData = ns.FogOfWarDataMists
  if not artID or not mapData or not mapData[artID] then return end

  local TILE_SIZE_WIDTH = 256
  local TILE_SIZE_HEIGHT = 256

  local fogColors = ns.Addon.db.profile.FogOfWarColor or {}
  local fogR = fogColors.FogOfWarColorR or 1
  local fogG = fogColors.FogOfWarColorG or 0
  local fogB = fogColors.FogOfWarColorB or 0
  local fogA = fogColors.FogOfWarColorA or 1

  local explored = {}
  local exploredTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
  if exploredTextures then
    for _, info in ipairs(exploredTextures) do
      local key = info.textureWidth * 2 ^ 39 + info.textureHeight * 2 ^ 26 + info.offsetX * 2 ^ 13 + info.offsetY
      explored[key] = true
    end
  end

  for key, files in pairs(mapData[artID]) do
    if not explored[key] then
      local width = math.fmod(math.floor(key / 2 ^ 39), 2 ^ 13)
      local height = math.fmod(math.floor(key / 2 ^ 26), 2 ^ 13)
      local offsetX = math.fmod(math.floor(key / 2 ^ 13), 2 ^ 13)
      local offsetY = math.fmod(key, 2 ^ 13)
      local fileDataIDs = { strsplit(",", files) }

      local numWide = math.ceil(width / TILE_SIZE_WIDTH)
      local numTall = math.ceil(height / TILE_SIZE_HEIGHT)

      for j = 1, numTall do
        for k = 1, numWide do
          local tex = ns.AreaMapOverlayPool:Acquire()
          tex:SetParent(ns.AreaMapFrame.ScrollContainer.Child)
          tex:SetDrawLayer("ARTWORK")

          local textureWidth = (k < numWide) and TILE_SIZE_WIDTH or math.fmod(width, TILE_SIZE_WIDTH)
          if textureWidth == 0 then textureWidth = TILE_SIZE_WIDTH end

          local textureHeight = (j < numTall) and TILE_SIZE_HEIGHT or math.fmod(height, TILE_SIZE_HEIGHT)
          if textureHeight == 0 then textureHeight = TILE_SIZE_HEIGHT end

          local fileWidth, fileHeight = 16, 16
          while fileWidth < textureWidth do fileWidth = fileWidth * 2 end
          while fileHeight < textureHeight do fileHeight = fileHeight * 2 end

          local texIndex = ((j - 1) * numWide) + k
          local fileDataID = tonumber(fileDataIDs[texIndex])
          if fileDataID then
            tex:SetTexture(fileDataID, nil, nil, "TRILINEAR")
            tex:SetSize(textureWidth, textureHeight)
            tex:SetTexCoord(0, textureWidth / fileWidth, 0, textureHeight / fileHeight)
            tex:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
            tex:SetVertexColor(fogR, fogG, fogB, fogA)
            tex:Show()
          end
        end
      end
    end
  end
end

function ns.CreateMapNotesDropdown()
  if not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu then return end
  if not BattlefieldMapFrame then return end
  if BattlefieldMapFrame.MapNotesDropdown then return end

  if not ns.UpdateAreaMapIcons then
    ns.AreaMap()
  end

  local dropdown = CreateFrame("Frame", "MapNotesAreaMapScaleDropdown", BattlefieldMapFrame, "UIDropDownMenuTemplate")
  dropdown:SetPoint("BOTTOM", BattlefieldMapFrame, "TOP", 98, 0)
  dropdown:SetScale(0.93)
  BattlefieldMapFrame.MapNotesDropdown = dropdown

  local function ToggleCapitalsIcons()
    ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons = not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons

    ns.UpdateAreaMapIcons()
    ns.RefreshDropdown()

    if ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " |cffffff00" .. L["Capitals"] .. " " .. L["icons"] .. " |cff00ff00" .. L["are shown"])
    else
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " |cffffff00" .. L["Capitals"] .. " " .. L["icons"] .. " |cffff0000" .. L["are hidden"])
    end
  end

  local function ToggleZoneIcons()
    ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons = not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons

    ns.UpdateAreaMapIcons()
    ns.RefreshDropdown()

    if ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " |cffffff00" .. L["Zones"] .. " " .. L["icons"] .. " |cff00ff00" .. L["are shown"])
    else
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " |cffffff00" .. L["Zones"] .. " " .. L["icons"] .. " |cffff0000" .. L["are hidden"])
    end
  end  

  function ToggleAreaMapUnexploredAreas()
    local db = ns.Addon.db.profile.areaMap
    db.showAreaMapUnexploredAreas = not db.showAreaMapUnexploredAreas
  
    if not db.showAreaMapUnexploredAreas and ns.AreaMapOverlayPool then
      ns.AreaMapOverlayPool:ReleaseAll()
    else
      ns.UpdateAreaMapFogOfWar()
    end
  
    ns.RefreshDropdown()
  end
  
  

  function InitializeDropdown(self, level)

    UIDropDownMenu_AddButton({
      text = L["Capitals"] .. " " .. L["icons"],
      func = ToggleCapitalsIcons,
      checked = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons,
      keepShownOnClick = false,
    }, level)

    UIDropDownMenu_AddButton({
      text = L["Zones"] .. " " .. L["icons"],
      func = ToggleZoneIcons,
      checked = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons,
      keepShownOnClick = false,
    }, level)

    UIDropDownMenu_AddButton({
      text = L["symbol size"],
      func = function()
        CreateAreaMapScaleSliderFrame()
        ns.AreaMapSliderFrame:Show()
      end,
      notCheckable = false,
    }, level)

    UIDropDownMenu_AddSeparator(level)

    UIDropDownMenu_AddButton({
      text = L["Unexplored Areas"],
      func = ToggleAreaMapUnexploredAreas,
      checked = ns.Addon.db.profile.areaMap.showAreaMapUnexploredAreas,
      keepShownOnClick = false,
    }, level)

    UIDropDownMenu_AddButton({
      text = L["Fog"] .. " - " .. COLOR,
      func = function()
          ns.OpenSharedFogOfWarColorPicker()
      end,
      notCheckable = false,
  }, level)

  end

  UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
  UIDropDownMenu_SetWidth(dropdown, 110)
  UIDropDownMenu_SetText(dropdown, ns.COLORED_ADDON_NAME .. " ")
  ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
end

function ns.OpenSharedFogOfWarColorPicker()
  local fog = ns.Addon.db.profile.FogOfWarColor or {}
  local r = fog.FogOfWarColorR or 1
  local g = fog.FogOfWarColorG or 0
  local b = fog.FogOfWarColorB or 0
  local a = fog.FogOfWarColorA or 1

  local function applyColor(nr, ng, nb, na)
    local db = ns.Addon.db.profile
    db.FogOfWarColor = db.FogOfWarColor or {}
    db.FogOfWarColor.FogOfWarColorR = nr
    db.FogOfWarColor.FogOfWarColorG = ng
    db.FogOfWarColor.FogOfWarColorB = nb
    db.FogOfWarColor.FogOfWarColorA = na
  
    db.areaMap.areaMapFogOfWarColorR = nr
    db.areaMap.areaMapFogOfWarColorG = ng
    db.areaMap.areaMapFogOfWarColorB = nb
    db.areaMap.areaMapFogOfWarColorA = na
  
    if ns.UpdateAreaMapFogOfWar then
      ns.UpdateAreaMapFogOfWar()
    end
  
    local fog = ns.FogOfWar or HandyNotes:GetModule("FogOfWarButton", true)
    if fog and type(fog.Refresh) == "function" and (not fog.IsEnabled or fog:IsEnabled()) then
      fog:Refresh()
    else
      for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
        if pin.RefreshOverlays then
          pcall(function() pin:RefreshOverlays(true) end)
        end
      end
    end
  end

  local function callback()
    local nr, ng, nb = ColorPickerFrame:GetColorRGB()
    local na = 1 - (ColorPickerFrame.opacity or 0)
    applyColor(nr, ng, nb, na)
  end

  local function cancelCallback(prev)
    local na = 1 - (prev.opacity or 0)
    applyColor(prev.r, prev.g, prev.b, na)
  end

  ColorPickerFrame:SetupColorPickerAndShow({
    r = r,
    g = g,
    b = b,
    opacity = 1 - a,
    hasOpacity = false,
    swatchFunc = callback,
    opacityFunc = callback,
    cancelFunc = cancelCallback,
  })
end


function ns.CreateResetMapIDButton()
  if ns.ResetMapIDButton or not ns.AreaMapFrame or not ns.AreaMapFrame.BorderFrame then return end

  ns.ResetMapIDButton = CreateFrame("Button", "MapNotesResetMapButton", ns.AreaMapFrame.BorderFrame)
  ns.ResetMapIDButton:SetSize(31, 31)
  ns.ResetMapIDButton:SetPoint("TOPRIGHT", ns.AreaMapFrame.BorderFrame.CloseButton, "BOTTOMRIGHT", -25, 30) -- left from X
  --ns.ResetMapIDButton:SetPoint("TOPRIGHT", ns.AreaMapFrame.BorderFrame.CloseButton, "BOTTOMRIGHT", 3, 5) -- under X
  ns.ResetMapIDButton:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
  ns.ResetMapIDButton:SetPushedTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
  ns.ResetMapIDButton:SetHighlightTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
  ns.ResetMapIDButton:SetScript("OnClick", function()
    ns.ResetAreaMapToPlayerLocation()
  end)

  ns.ResetMapIDButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine(L["Resets the displayed map to the map of the player's position"], 1, 1, 1)
    GameTooltip:Show()
  end)

  ns.ResetMapIDButton:SetScript("OnLeave", GameTooltip_Hide)
end

function ns.ResetAreaMapToPlayerLocation()
  ns._autoCorrected = false
  local mapID = C_Map.GetBestMapForUnit("player")
  if mapID then
    if BattlefieldMapFrame and BattlefieldMapFrame:IsShown() then
      BattlefieldMapFrame:SetMapID(mapID)     
    end
  end
end

local function InitBattlefieldMapFeatures()
  if not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu then return end
  if not BattlefieldMapFrame or BattlefieldMapFrame.MapNotesInitialized then return end

  ns.AreaMap()

  local function WaitForAreaMapFrame()
    if BattlefieldMapFrame and BattlefieldMapFrame.BorderFrame then
      ns.CreateMapNotesDropdown()
      ns.CreateResetMapIDButton()
      ns.UpdateAreaMapIcons()
      BattlefieldMapFrame.MapNotesInitialized = true
    else
      C_Timer.After(0.1, WaitForAreaMapFrame)
    end
  end

  WaitForAreaMapFrame()
end

local function WaitForBattlefieldMap()
  if BattlefieldMapFrame then
    if BattlefieldMapFrame:IsShown() then
      InitBattlefieldMapFeatures()
    else

      if not BattlefieldMapFrame.MapNotesShowHooked then
        BattlefieldMapFrame:HookScript("OnShow", InitBattlefieldMapFeatures)
        BattlefieldMapFrame.MapNotesShowHooked = true
      end
    end
  else

    C_Timer.After(1, WaitForBattlefieldMap)
  end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
  WaitForBattlefieldMap()
end)

function ns.SaveDropDownStates()
  ns.savedDropdownStates = {
    showZoneIcons = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons,
    showCapitalIcons = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons,
    showUnexplored = ns.Addon.db.profile.areaMap.showAreaMapUnexploredAreas,
  }
end

function ns.LoadDropDownStates()
  if not ns.savedDropdownStates then return end

  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons = ns.savedDropdownStates.showZoneIcons
  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons = ns.savedDropdownStates.showCapitalIcons
  ns.Addon.db.profile.areaMap.showAreaMapUnexploredAreas = ns.savedDropdownStates.showUnexplored

  if ns.ResetMapIDButton then
    ns.ResetMapIDButton:Show()
  end

  if ns.UpdateAreaMapIcons then
    ns.UpdateAreaMapIcons()
  end
end

function ns.ReloadAreaMapSettings()
  if not ns.Addon or not ns.Addon.db or not ns.Addon.db.profile then return end
  if type(ns.UpdateAreaMapIcons) ~= "function" then return end

  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons
  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons = ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons
  ns.areaMapScale = ns.Addon.db.profile.areaMap.areaMapScale or 1.0

  ns.UpdateAreaMapIcons()

  ns.RefreshDropdown()
  ns.UpdateAreaMapFogOfWar()
end


function ns.SetAreaMapCapitalsIconsVisibility(state)
  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuCapitalsIcons = state

  if ns.RefreshDropdown then ns.RefreshDropdown() end
  if ns.UpdateAreaMapIcons then ns.UpdateAreaMapIcons() end
end

function ns.SetAreaMapZoneIconsVisibility(state)
  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenuZonesIcons = state

  if ns.RefreshDropdown then ns.RefreshDropdown() end
  if ns.UpdateAreaMapIcons then ns.UpdateAreaMapIcons() end
end

function ns.UpdateAreaMapSettings()
  ns.RefreshDropdown()
end

function ns.RefreshDropdown()
  if BattlefieldMapFrame and BattlefieldMapFrame.MapNotesDropdown then
    UIDropDownMenu_Refresh(BattlefieldMapFrame.MapNotesDropdown, 1)
    UIDropDownMenu_SetText(BattlefieldMapFrame.MapNotesDropdown, ns.COLORED_ADDON_NAME .. " ")
  end
end

function ns.SetAreaMapMenuVisibility(state)
  ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu = state

  if state then
    if BattlefieldMapFrame and BattlefieldMapFrame:IsShown() and not BattlefieldMapFrame.MapNotesDropdown then
      ns.CreateMapNotesDropdown()
    end
    if ns.ResetMapIDButton == nil and ns.CreateResetMapIDButton then
      ns.CreateResetMapIDButton()
    end
  end

  if BattlefieldMapFrame and BattlefieldMapFrame.MapNotesDropdown then
    BattlefieldMapFrame.MapNotesDropdown:SetShown(state)
  end
  
  if ns.ResetMapIDButton then
    ns.ResetMapIDButton:SetShown(state)
  end
end

function ns.showAreaMapDropDownMenuSettingsforOptionsFile(val)
  ns.SetAreaMapMenuVisibility(val)

  if val then
    if BattlefieldMapFrame then
      if not ns.AreaMapFrame then
        ns.AreaMap()
      end

      if not BattlefieldMapFrame.MapNotesDropdown then
        ns.CreateMapNotesDropdown()
      else
        BattlefieldMapFrame.MapNotesDropdown:Show()
      end

      if not ns.ResetMapIDButton then
        ns.CreateResetMapIDButton()
      else
        ns.ResetMapIDButton:Show()
      end

      if BattlefieldMapFrame:IsShown() then
        ns.LoadDropDownStates()

        if ns.Addon.db.profile.areaMap.showAreaMapUnexploredAreas then
          ns.UpdateAreaMapFogOfWar()
        end

      end
      
    end
  else
    ns.SaveDropDownStates()

    if ns.AreaMapOverlayPool then
      ns.AreaMapOverlayPool:ReleaseAll()
    end

    if ns.UpdateAreaMapIcons then
      ns.UpdateAreaMapIcons()
    end

    if ns.ResetMapIDButton then
      ns.ResetMapIDButton:Hide()
    end

    if BattlefieldMapFrame and BattlefieldMapFrame.MapNotesDropdown then
      BattlefieldMapFrame.MapNotesDropdown:Hide()
    end

    if ns.DisableAreaMapUpdate then
      ns.DisableAreaMapUpdate()
    end

    if ns.UpdateAreaMapIcons then
      ns.UpdateAreaMapIcons()
    end
  end

end

function ns.StartFogOfWarColorSyncTicker()
  if ns._fogColorTicker then return end

  local lastR, lastG, lastB, lastA = 0, 0, 0, 0
  local noChangeCounter = 0

  ns._fogColorTicker = C_Timer.NewTicker(0.3, function()
    local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
    if not db or not db.FogOfWarColor then return end

    local r = db.FogOfWarColor.FogOfWarColorR or 0
    local g = db.FogOfWarColor.FogOfWarColorG or 0
    local b = db.FogOfWarColor.FogOfWarColorB or 0
    local a = db.FogOfWarColor.FogOfWarColorA or 0

    if r ~= lastR or g ~= lastG or b ~= lastB or a ~= lastA then
      lastR, lastG, lastB, lastA = r, g, b, a
      noChangeCounter = 0

      if ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu and ns.AreaMapFrame and ns.AreaMapFrame:IsShown() then
        ns.UpdateAreaMapFogOfWar()
      end
    else
      noChangeCounter = noChangeCounter + 1
      if noChangeCounter >= 10 then 
        ns.StopFogOfWarColorSyncTicker()
      end
    end
  end)
end

function ns.StopFogOfWarColorSyncTicker()
  if ns._fogColorTicker then
    ns._fogColorTicker:Cancel()
    ns._fogColorTicker = nil
  end
end