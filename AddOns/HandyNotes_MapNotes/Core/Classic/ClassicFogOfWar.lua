local ADDON_NAME, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

ns.FogOfWar = HandyNotes:NewModule("FogOfWarButton")

local mod, floor, ceil, tonumber = math.fmod, math.floor, math.ceil, tonumber
local ipairs, pairs = ipairs, pairs

function ns.FogOfWar:SyncColorsFromDB(doRefresh)
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  local t = db and db.FogOfWarColor
  if not t then return end

  self.colorR = t.colorR or 1
  self.colorG = t.colorG or 1
  self.colorB = t.colorB or 1
  self.colorA = t.colorA or 1

  self.FogOfWarColorR = t.FogOfWarColorR or 1
  self.FogOfWarColorG = t.FogOfWarColorG or 0
  self.FogOfWarColorB = t.FogOfWarColorB or 0
  self.FogOfWarColorA = t.FogOfWarColorA or 1

  if doRefresh then self:Refresh() end
end

ns.hookedPins = ns.hookedPins or {}
ns._hookCheckTicker = ns._hookCheckTicker or nil
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

function ns.FogOfWar:OnEnable()
  self:SyncColorsFromDB(false)
  HookAllExplorationPinsOnce()
  if not ns._hookCheckTicker then
    ns._hookCheckTicker = C_Timer.NewTicker(3, function()
      if WorldMapFrame and WorldMapFrame:IsShown() then
        HookAllExplorationPinsOnce()
      end
    end)
  end
end

function ns.FogOfWar:OnInitialize()
  self:SyncColorsFromDB(false)
end

function ns.FogOfWar:OnDisable()
  if ns._hookCheckTicker then
    ns._hookCheckTicker:Cancel()
    ns._hookCheckTicker = nil
  end
  if WorldMapFrame and WorldMapFrame:IsShown() then
    for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
      if pin.RefreshOverlays then pin:RefreshOverlays(true) end
    end
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

local mapData = ns.FogOfWarDataClassic or {}
function ns.FogOfWar:MapExplorationPin_RefreshOverlays(pin, fullUpdate)
  local db = ns.Addon and ns.Addon.db and ns.Addon.db.profile
  local activate = db and db.activate
  if not (activate and (activate.FogOfWar or activate.MistOfTheUnexplored)) then return end

  for overlay in pin.overlayTexturePool:EnumerateActive() do
    overlay:SetVertexColor(1, 1, 1)
    overlay:SetAlpha(1)
  end

  local mapCanvas = pin:GetMap()
  local mapID = mapCanvas and mapCanvas:GetMapID()
  if not mapID then return end

  local artID = C_Map.GetMapArtID(mapID)
  if not artID or not mapData[artID] then return end
  local data = mapData[artID]

  local explored = {}
  local exploredTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
  if exploredTextures then
    for _, info in ipairs(exploredTextures) do
      local key = info.textureWidth * 2 ^ 39 + info.textureHeight * 2 ^ 26 + info.offsetX * 2 ^ 13 + info.offsetY
      explored[key] = true
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

  for key, files in pairs(data) do
    if not explored[key] then
      local width = mod(floor(key / 2 ^ 39), 2 ^ 13)
      local height = mod(floor(key / 2 ^ 26), 2 ^ 13)
      local offsetX= mod(floor(key / 2 ^ 13), 2 ^ 13)
      local offsetY= mod(key, 2 ^ 13)

      local fileDataIDs = { strsplit(",", files) }
      local numWide = ceil(width / TILE_SIZE_WIDTH)
      local numTall = ceil(height / TILE_SIZE_HEIGHT)

      local texPixW, texFileW, texPixH, texFileH

      for j = 1, numTall do
        if j < numTall then
          texPixH = TILE_SIZE_HEIGHT
          texFileH = TILE_SIZE_HEIGHT
        else
          texPixH = mod(height, TILE_SIZE_HEIGHT)
          if texPixH == 0 then texPixH = TILE_SIZE_HEIGHT end
          texFileH = 16
          while (texFileH < texPixH) do texFileH = texFileH * 2 end
        end

        for k = 1, numWide do
          local texture = pin.overlayTexturePool:Acquire()
          if k < numWide then
            texPixW = TILE_SIZE_WIDTH
            texFileW = TILE_SIZE_WIDTH
          else
            texPixW = mod(width, TILE_SIZE_WIDTH)
            if texPixW == 0 then texPixW = TILE_SIZE_WIDTH end
            texFileW = 16
            while (texFileW < texPixW) do texFileW = texFileW * 2 end
          end

          if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate.FogOfWar then
            texture:Show()
            texture:SetVertexColor(1, 1, 1)
            texture:SetAlpha(a)
            texture:SetWidth(texPixW)
            texture:SetHeight(texPixH)
            texture:SetTexCoord(0, texPixW / texFileW, 0, texPixH / texFileH)
            texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
            texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numWide) + k]), nil, nil, "TRILINEAR")
          end

          if activate.FogOfWar and activate.MistOfTheUnexplored then
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

  if self:IsEnabled() then self:Refresh() end
end

function ns.FogOfWar:GetFogOfWarColor()
  return self.FogOfWarColorR or 1, self.FogOfWarColorG or 0, self.FogOfWarColorB or 0, self.FogOfWarColorA or 1
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

  if ns.UpdateAreaMapFogOfWar then ns.UpdateAreaMapFogOfWar() end
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

ns.FogOfWarDataClassic = nil