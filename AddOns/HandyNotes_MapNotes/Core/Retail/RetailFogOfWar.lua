local ADDON_NAME, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

ns.FogOfWar = HandyNotes:NewModule("FogOfWarButton")

local mod, floor, ceil, tonumber = math.fmod, math.floor, math.ceil, tonumber
local ipairs, pairs = ipairs, pairs

function ns.FogOfWar:SyncColorsFromDB(doRefresh)
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  local color = db and db.FogOfWarColor
  if not color then return end

  self.colorR = color.colorR or 1
  self.colorG = color.colorG or 1
  self.colorB = color.colorB or 1
  self.colorA = color.colorA or 1

  self.FogOfWarColorR = color.FogOfWarColorR or 1
  self.FogOfWarColorG = color.FogOfWarColorG or 0
  self.FogOfWarColorB = color.FogOfWarColorB or 0
  self.FogOfWarColorA = color.FogOfWarColorA or 1

  if doRefresh then self:Refresh() end
end

ns.hookedPins = ns.hookedPins or {}
ns.hookCheckTicker = ns.hookCheckTicker or nil

local function HookAllExplorationPinsOnce()
  if not WorldMapFrame or not WorldMapFrame.EnumeratePinsByTemplate then return end
  for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
    if not ns.hookedPins[pin] then
      hooksecurefunc(pin, "RefreshOverlays", function(p, ...)
        if ns.FogOfWar:IsEnabled() then
          ns.FogOfWar:MapExplorationPin_RefreshOverlays(p, ...)
        end
      end)
      ns.hookedPins[pin] = true
    end
  end
end

function ns.FogOfWar:OnInitialize()
  self:SyncColorsFromDB(false)
end

function ns.FogOfWar:OnEnable()
  self:SyncColorsFromDB(false)
  HookAllExplorationPinsOnce()

  if not ns.hookCheckTicker then
    ns.hookCheckTicker = C_Timer.NewTicker(3, function()
      if WorldMapFrame and WorldMapFrame:IsShown() then
        HookAllExplorationPinsOnce()
      end
    end)
  end
end

function ns.FogOfWar:OnDisable()
  if ns.hookCheckTicker then
    ns.hookCheckTicker:Cancel()
    ns.hookCheckTicker = nil
  end
end

function ns.FogOfWar:Refresh()
  if not self:IsEnabled() then return end
  if WorldMapFrame and WorldMapFrame:IsShown() then
    for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
      if pin.RefreshOverlays then
        pin:RefreshOverlays(true)
      end
    end
  end
end

local mapData = ns.FogOfWarDataRetail or {}

function ns.FogOfWar:MapExplorationPin_RefreshOverlays(pin, fullUpdate)
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile 
  if not (db and (db.activate.FogOfWar or db.activate.MistOfTheUnexplored)) then return end

  for overlay in pin.overlayTexturePool:EnumerateActive() do
    overlay:SetVertexColor(1,1,1)
    overlay:SetAlpha(1)
  end

  local mapCanvas = pin:GetMap()
  local mapID = mapCanvas and mapCanvas:GetMapID()
  if not mapID then return end

  local artID = C_Map.GetMapArtID(mapID)
  if not artID or not mapData[artID] then return end
  local data = mapData[artID]

  local exploredTilesKeyed = {}
  local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
  if exploredMapTextures then
    for _, info in ipairs(exploredMapTextures) do
      local key = info.textureWidth * 2 ^ 39 + info.textureHeight * 2 ^ 26 + info.offsetX * 2 ^ 13 + info.offsetY exploredTilesKeyed[key] = true
    end
  end

  pin.layerIndex = mapCanvas:GetCanvasContainer():GetCurrentLayerIndex()
  local layers = C_Map.GetMapArtLayers(mapID)
  local layerInfo = layers and layers[pin.layerIndex]
  if not layerInfo then return end

  local TILE_SIZE_WIDTH = layerInfo.tileWidth
  local TILE_SIZE_HEIGHT = layerInfo.tileHeight

  local r, g, b, a = self:GetOverlayColor()
  local FoWr, FoWg, FoWb, FoWa = self:GetFogOfWarColor()
  local drawLayer, subLevel = pin.dataProvider:GetDrawLayer()

  for key, files in pairs(data) do
    if not exploredTilesKeyed[key] then
      local width = mod(floor(key / 2 ^ 39), 2 ^ 13)
      local height = mod(floor(key / 2 ^ 26), 2 ^ 13)
      local offsetX = mod(floor(key / 2 ^ 13), 2 ^ 13)
      local offsetY = mod(key, 2 ^ 13)

      local fileDataIDs = { strsplit(",", files) }
      local numTexturesWide = ceil(width  / TILE_SIZE_WIDTH)
      local numTexturesTall = ceil(height / TILE_SIZE_HEIGHT)

      local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

      for j = 1, numTexturesTall do
        if j < numTexturesTall then
          texturePixelHeight = TILE_SIZE_HEIGHT
          textureFileHeight  = TILE_SIZE_HEIGHT
        else
          texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
          if texturePixelHeight == 0 then texturePixelHeight = TILE_SIZE_HEIGHT end
          textureFileHeight = 16
          while textureFileHeight < texturePixelHeight do
            textureFileHeight = textureFileHeight * 2
          end
        end

        for k = 1, numTexturesWide do
          local texture = pin.overlayTexturePool:Acquire()

          if k < numTexturesWide then
            texturePixelWidth = TILE_SIZE_WIDTH
            textureFileWidth  = TILE_SIZE_WIDTH
          else
            texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
            if texturePixelWidth == 0 then texturePixelWidth = TILE_SIZE_WIDTH end
            textureFileWidth = 16
            while textureFileWidth < texturePixelWidth do
              textureFileWidth = textureFileWidth * 2
            end
          end

          if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate.FogOfWar then
            texture:Show()
            texture:SetVertexColor(r, g, b)
            texture:SetAlpha(a)
            texture:SetWidth(texturePixelWidth)
            texture:SetHeight(texturePixelHeight)
            texture:SetTexCoord(0, texturePixelWidth / textureFileWidth,
                                0, texturePixelHeight / textureFileHeight)
            texture:SetPoint("TOPLEFT",
              offsetX + (TILE_SIZE_WIDTH * (k - 1)),
             -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
            texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]),
            nil, nil, "TRILINEAR")
            texture:SetDrawLayer(drawLayer, subLevel - 1)
          end

          if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate.MistOfTheUnexplored then
            texture:SetVertexColor(FoWr, FoWg, FoWb)
            texture:SetAlpha(FoWa)
          end

          if fullUpdate then
            pin.textureLoadGroup:AddTexture(texture)
          end
        end
      end
    end
  end
end

function ns.FogOfWar:GetOverlayColor()
  return self.colorR or 1, self.colorG or 1, self.colorB or 1, self.colorA or 1
end

function ns.FogOfWar:SetOverlayColor(info, r, g, b, a)
  self.colorR, self.colorG, self.colorB, self.colorA = r, g, b, a
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  if db then
    db.FogOfWarColor = db.FogOfWarColor or {}
    db.FogOfWarColor.colorR = r
    db.FogOfWarColor.colorG = g
    db.FogOfWarColor.colorB = b
    db.FogOfWarColor.colorA = a
  end
  if self:IsEnabled() then
    self:Refresh()
  end
end

function ns.FogOfWar:GetFogOfWarColor()
  return self.FogOfWarColorR or 1,
         self.FogOfWarColorG or 0,
         self.FogOfWarColorB or 0,
         self.FogOfWarColorA or 1
end

function ns.FogOfWar:SetFogOfWarColor(info, r, g, b, a)
  self.FogOfWarColorR, self.FogOfWarColorG, self.FogOfWarColorB, self.FogOfWarColorA = r, g, b, a
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  if db then
    db.FogOfWarColor = db.FogOfWarColor or {}
    db.FogOfWarColor.FogOfWarColorR = r
    db.FogOfWarColor.FogOfWarColorG = g
    db.FogOfWarColor.FogOfWarColorB = b
    db.FogOfWarColor.FogOfWarColorA = a
  end
  if WorldMapFrame and WorldMapFrame:IsShown() and self:IsEnabled() then
    self:Refresh()
  end
  if ns.UpdateAreaMapFogOfWar then
    ns.UpdateAreaMapFogOfWar()
  end
end

function ns.FogOfWar:ResetFogOfWarColors()
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  if not db then return end

  db.FogOfWarColor = db.FogOfWarColor or {}

  db.FogOfWarColor.colorR = 1
  db.FogOfWarColor.colorG = 1
  db.FogOfWarColor.colorB = 1
  db.FogOfWarColor.colorA = 1

  db.FogOfWarColor.FogOfWarColorR = 1
  db.FogOfWarColor.FogOfWarColorG = 0
  db.FogOfWarColor.FogOfWarColorB = 0
  db.FogOfWarColor.FogOfWarColorA = 1

  self:SyncColorsFromDB(false)

  if WorldMapFrame and WorldMapFrame:IsShown() and self:IsEnabled() then
    self:Refresh()
  end
  if ns.UpdateAreaMapFogOfWar then
    ns.UpdateAreaMapFogOfWar()
  end
end

ns.FogOfWarDataRetail = nil