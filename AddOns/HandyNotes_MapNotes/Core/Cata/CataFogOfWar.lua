local ADDON_NAME, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")
local FogOfWar = HandyNotes:NewModule("FogOfWarButton", "AceHook-3.0", "AceEvent-3.0")

local mod, floor, ceil, tonumber = math.fmod, math.floor, math.ceil, tonumber
local ipairs, pairs = ipairs, pairs
local db

function FogOfWar:OnInitialize()
	self.db = HandyNotes.db:RegisterNamespace("FogOfWarButton", ns.defaults)
	db = self.db.profile
end

local function TexturePool_ResetVertexColor(pool, texture)
	texture:SetVertexColor(1, 1, 1)
	texture:SetAlpha(1)
	return TexturePool_HideAndClearAnchors(pool, texture)
end

function FogOfWar:OnEnable()
	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		self:SecureHook(pin, "RefreshOverlays", "MapExplorationPin_RefreshOverlays")
		pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
	end
end

function FogOfWar:OnDisable()
	self:UnhookAll()
end

function FogOfWar:Refresh()
	db = self.db.profile
	if not self:IsEnabled() then return end

	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		pin:RefreshOverlays(true)
	end
end

function FogOfWar:MapExplorationPin_RefreshOverlays(pin, fullUpdate)
	local mapID = pin:GetMap():GetMapID()
	if not mapID then
		return
	end
	local mapData = ns.FogOfWarDataCataclysm
	local artID = C_Map.GetMapArtID(mapID)
	if not artID or not mapData[artID] then
		return
	end
	local data = mapData[artID]

	local exploredTilesKeyed = {}
	local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
	if exploredMapTextures then
		for i, exploredTextureInfo in ipairs(exploredMapTextures) do
			local key =
				exploredTextureInfo.textureWidth * 2 ^ 39 + exploredTextureInfo.textureHeight * 2 ^ 26 +
				exploredTextureInfo.offsetX * 2 ^ 13 +
				exploredTextureInfo.offsetY
			exploredTilesKeyed[key] = true
		end
	end

	pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
	local layers = C_Map.GetMapArtLayers(mapID)
	local layerInfo = layers and layers[pin.layerIndex]

	if not layerInfo then
		return
	end

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight
	local r, g, b, a, r_Reduce, g_Reduce, b_Reduce, a_Reduce = self:GetOverlayColor()

	for key, files in pairs(data) do
		if not exploredTilesKeyed[key] then
			local width, height, offsetX, offsetY =
				mod(floor(key / 2 ^ 39), 2 ^ 13),
				mod(floor(key / 2 ^ 26), 2 ^ 13),
				mod(floor(key / 2 ^ 13), 2 ^ 13),
				mod(key, 2 ^ 13)
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
					texture:SetWidth(texturePixelWidth)
					texture:SetHeight(texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
					texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")

					if ns.Addon.db.profile.activate.FogOfWar then
						texture:SetVertexColor(a, r, g, b)
					end
					if ns.Addon.db.profile.activate.FogOfWarAlphaReduce then
						texture:SetVertexColor(a_Reduce, r_Reduce, g_Reduce, b_Reduce)
					end
					if ns.Addon.db.profile.activate.FogOfWar then
						texture:SetAlpha(a)
					end
					if ns.Addon.db.profile.activate.FogOfWarAlphaReduce then
						texture:SetAlpha(a_Reduce)
					end
					texture:SetDrawLayer("ARTWORK", -1)
                    if ns.Addon.db.profile.activate.FogOfWar then
                        texture:Show()
                    else
                        texture:Hide()
                    end

					if fullUpdate then
						pin.textureLoadGroup:AddTexture(texture)
					end
				end
			end
		end
	end
end

function FogOfWar:GetOverlayColor()
	return db.colorR, db.colorG, db.colorB, db.colorA, db.colorR_Reduce, db.colorG_Reduce, db.colorB_Reduce, db.colorA_Reduce
end

function FogOfWar:SetOverlayColor(info, r, g, b, a, r_Reduce,g_Reduce,b_Reduce,a_Reduce)
	db.colorR_Reduce, db.colorG_Reduce, db.colorB_Reduce, db.colorA_Reduce = r_Reduce, g_Reduce, b_Reduce, a_Reduce
	db.colorR, db.colorG, db.colorB, db.colorA = r, g, b, a
	if self:IsEnabled() then self:Refresh() end
end