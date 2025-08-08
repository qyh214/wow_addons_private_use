local ADDON_NAME, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
ns.FogOfWar = HandyNotes:NewModule("FogOfWarButton", "AceHook-3.0", "AceEvent-3.0")

local mod, floor, ceil, tonumber = math.fmod, math.floor, math.ceil, tonumber
local ipairs, pairs = ipairs, pairs

function ns.FogOfWar:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("FogOfWarColorDB", ns.defaults)
	self:SetEnabledState(HandyNotes:GetModule("FogOfWarButton"))
end

ns.hookedPins = ns.hookedPins or {}
ns._hookCheckTicker = ns._hookCheckTicker or nil

function ns.FogOfWar:OnEnable()
	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		if not ns.hookedPins[pin] then
			self:SecureHook(pin, "RefreshOverlays", "MapExplorationPin_RefreshOverlays")
			ns.hookedPins[pin] = true
		end
	end

	if not ns._hookCheckTicker then
		ns._hookCheckTicker = C_Timer.NewTicker(3, function()
			if not WorldMapFrame:IsShown() then return end
			for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				if not ns.hookedPins[pin] then
					ns.FogOfWar:SecureHook(pin, "RefreshOverlays", "MapExplorationPin_RefreshOverlays")
					ns.hookedPins[pin] = true
				end
			end
		end)
	end
end

function ns.FogOfWar:OnDisable()
	self:UnhookAll()
	if ns._hookCheckTicker then
		ns._hookCheckTicker:Cancel()
		ns._hookCheckTicker = nil
	end
end

function ns.FogOfWar:Refresh()
	if not self:IsEnabled() then return end

	if WorldMapFrame:IsShown() then
		for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
			pin:RefreshOverlays(true)
		end
	end
end

local mapData = ns.FogOfWarDataRetail or {}
function ns.FogOfWar:MapExplorationPin_RefreshOverlays(pin, fullUpdate)

	for overlay in pin.overlayTexturePool:EnumerateActive() do
		overlay:SetVertexColor(1,1,1)
		overlay:SetAlpha(1)
	end

	local mapCanvas = pin:GetMap()

	local mapID = mapCanvas:GetMapID()
	if not mapID then
		return
	end

	local artID = C_Map.GetMapArtID(mapID)
	if not artID or not mapData[artID] then
		return
	end

	local data = mapData[artID]
	local exploredTilesKeyed = {}
	local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
	if exploredMapTextures then
		for i, exploredTextureInfo in ipairs(exploredMapTextures) do
			local key = exploredTextureInfo.textureWidth * 2 ^ 39 +	exploredTextureInfo.textureHeight * 2 ^ 26 + exploredTextureInfo.offsetX * 2 ^ 13 +	exploredTextureInfo.offsetY
			exploredTilesKeyed[key] = true
		end
	end

	pin.layerIndex = mapCanvas:GetCanvasContainer():GetCurrentLayerIndex()
	local layers = C_Map.GetMapArtLayers(mapID)
	local layerInfo = layers and layers[pin.layerIndex]
	if not layerInfo then
		return
	end

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight
	local r, g, b, a = self:GetOverlayColor()
	local FoWr, FoWg, FoWb, FoWa = self:GetFogOfWarColor()
	local drawLayer, subLevel = pin.dataProvider:GetDrawLayer()
	for key, files in pairs(data) do
		if not exploredTilesKeyed[key] then
		local width, height, offsetX, offsetY =	mod(floor(key / 2 ^ 39), 2 ^ 13), mod(floor(key / 2 ^ 26), 2 ^ 13),	mod(floor(key / 2 ^ 13), 2 ^ 13), mod(key, 2 ^ 13)
		local fileDataIDs = {strsplit(",", files)}
		local numTexturesWide = ceil(width / TILE_SIZE_WIDTH)
		local numTexturesTall = ceil(height / TILE_SIZE_HEIGHT)
		local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
		
			for j = 1, numTexturesTall do
				if (j < numTexturesTall) then
					texturePixelHeight = TILE_SIZE_HEIGHT
					textureFileHeight = TILE_SIZE_HEIGHT
				else
					texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
					if (texturePixelHeight == 0) then
						texturePixelHeight = TILE_SIZE_HEIGHT
					end
					textureFileHeight = 16
					while (textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2
					end
				end

				for k = 1, numTexturesWide do
					local texture = pin.overlayTexturePool:Acquire()
					if (k < numTexturesWide) then
						texturePixelWidth = TILE_SIZE_WIDTH
						textureFileWidth = TILE_SIZE_WIDTH
					else
						texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
						if (texturePixelWidth == 0) then
							texturePixelWidth = TILE_SIZE_WIDTH
						end
						textureFileWidth = 16
						while (textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2
						end
					end

                    if ns.Addon.db.profile.activate.FogOfWar then
                        texture:Show()
						texture:SetVertexColor(r, g, b)
						texture:SetAlpha(a)
						texture:SetWidth(texturePixelWidth)
						texture:SetHeight(texturePixelHeight)
						texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
						texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
						texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
						texture:SetDrawLayer(drawLayer, subLevel - 1)
					end

					if ns.Addon.db.profile.activate.MistOfTheUnexplored then
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
	return ns.FogOfWar.colorR, ns.FogOfWar.colorG, ns.FogOfWar.colorB, ns.FogOfWar.colorA
end

function ns.FogOfWar:SetOverlayColor(info, r, g, b, a)
	ns.FogOfWar.colorR, ns.FogOfWar.colorG, ns.FogOfWar.colorB, ns.FogOfWar.colorA = r, g, b, a
	if self:IsEnabled() then self:Refresh() end
end

function ns.FogOfWar:GetFogOfWarColor()
	return ns.FogOfWar.FogOfWarColorR, ns.FogOfWar.FogOfWarColorG, ns.FogOfWar.FogOfWarColorB, ns.FogOfWar.FogOfWarColorA
end

ns.lastFogRefresh = 0

function ns.FogOfWar:SetFogOfWarColor(info, FoWr, FoWg, FoWb, FoWa)
	ns.FogOfWar.FogOfWarColorR, ns.FogOfWar.FogOfWarColorG, ns.FogOfWar.FogOfWarColorB, ns.FogOfWar.FogOfWarColorA = FoWr, FoWg, FoWb, FoWa

	local now = GetTime()
	if WorldMapFrame:IsShown() and self:IsEnabled() and (now - (ns.lastFogRefresh or 0) > 0.1) then
		self:Refresh()
		ns.lastFogRefresh = now
	end

	if ns.AreaMapFrame and ns.AreaMapFrame:IsShown() then
		ns.UpdateAreaMapFogOfWar()
	end

	if ns.StartFogOfWarColorSyncTicker then
		ns.StartFogOfWarColorSyncTicker()
	end
end
-- remove data from global scope
ns.FogOfWarDataRetail = nil