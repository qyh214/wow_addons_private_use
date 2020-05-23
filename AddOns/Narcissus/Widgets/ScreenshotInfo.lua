local floor = math.floor;
local format = string.format;
local DECIMAL = "%.2f";

local GetPlayerMapPosition = C_Map.GetPlayerMapPosition;
local GetBestMapForUnit = C_Map.GetBestMapForUnit;
local GetMapInfo = C_Map.GetMapInfo;

local PositionFrame;
--Get coordinates when pressing ALT+Z
NarciScreenshotInfoMixin = {};

function NarciScreenshotInfoMixin:OnLoad()
    PositionFrame = self;
    
    self.t = 0;
    self.gate = 0.25;
end

function NarciScreenshotInfoMixin:OnShow()
    self:RegisterEvent("PLAYER_STARTED_MOVING");
    self:RegisterEvent("PLAYER_STOPPED_MOVING");
end

function NarciScreenshotInfoMixin:OnHide()
    self.t = 0;
    self:UnregisterEvent("PLAYER_STARTED_MOVING");
    self:UnregisterEvent("PLAYER_STOPPED_MOVING");
end

function NarciScreenshotInfoMixin:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= self.gate then
        self.t = 0;
        self:GetPlayerPosition();
    end
end

function NarciScreenshotInfoMixin:GetPlayerPosition()
    local mapID = GetBestMapForUnit("player");
    if mapID then
        local position = GetPlayerMapPosition(mapID, "player");
        local x = position.x or 0;
        local y = position.y or 0;
        self.Coordinates:SetText( format(DECIMAL, 100 * x) .." , ".. format(DECIMAL, 100 * y) );

        local mapInfo = GetMapInfo(mapID);
        local zoneName = GetMinimapZoneText();
        if mapInfo and mapInfo.name then
            self.MapName:SetText(zoneName ..", ".. mapInfo.name);
        else
            self.MapName:SetText(zoneName);
        end
    end
end

function NarciScreenshotInfoMixin:OnEvent(event)

end

local function ToggleGPS(show)
    PositionFrame:SetShown(show);
end

hooksecurefunc("SetUIVisibility", function(visible)
    ToggleGPS(not visible);
end);


function SetMapPiece(layerIndex, texIndex)
    local layerIndex = 1;
    PositionFrame:Show()
    local mapID = GetBestMapForUnit("player");
	local layers = C_Map.GetMapArtLayers(mapID);
	local layerInfo = layers[layerIndex];
	local numDetailTilesRows = math.ceil(layerInfo.layerHeight / layerInfo.tileHeight);
	local numDetailTilesCols = math.ceil(layerInfo.layerWidth / layerInfo.tileWidth);
    local textures = C_Map.GetMapArtLayerTextures(mapID, layerIndex);
    PositionFrame.Map:SetTexture(textures[texIndex])
end
--[[
84 Stormwind

function MapCanvasMixin:RefreshDetailLayers()
	if not self.areDetailLayersDirty then return end;
	self.detailLayerPool:ReleaseAll();

	local layers = C_Map.GetMapArtLayers(self.mapID);
	for layerIndex, layerInfo in ipairs(layers) do
		local detailLayer = self.detailLayerPool:Acquire();
		detailLayer:SetAllPoints(self:GetCanvas());
		detailLayer:SetMapAndLayer(self.mapID, layerIndex);
		detailLayer:SetGlobalAlpha(self:GetGlobalAlpha());
		detailLayer:Show();
	end

	self:AdjustDetailLayerAlpha();

	self.areDetailLayersDirty = false;
end

--]]

