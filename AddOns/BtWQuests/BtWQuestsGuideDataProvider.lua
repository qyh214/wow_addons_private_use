local Guide = {Waypoints = {}, Focus = nil, UserWaypoint = nil}
BtWQuests.Guide = Guide;

function Guide:AddWayPoint(mapId, x, y, name)
    if not self.DataProvider then
        self.DataProvider = CreateFromMixins(BtWQuestsGuideDataProviderMixin)
        LibMapPinHandler[WorldMapFrame]:AddDataProvider(self.DataProvider);
    end

    local continentMapId = mapId
    local mapInfo = C_Map.GetMapInfo(continentMapId)
    while mapInfo and mapInfo.mapType > Enum.UIMapType.Continent do
        continentMapId = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(continentMapId)
    end

    if not continentMapId or not mapInfo then
        return
    end

    local continentId, position = C_Map.GetWorldPosFromMapPos(mapId, {
        x = x,
        y = y,
    })
    if not continentId or not position then
        return
    end
    position.mapId = continentId
    local _, mapPosition = C_Map.GetMapPosFromWorldPos(continentId, position, continentMapId)
    if not mapPosition then
        continentMapId = mapId
        mapPosition = select(2, C_Map.GetMapPosFromWorldPos(continentId, position, continentMapId))
    end
    if not mapPosition then
        return
    end

    local waypoints = self.Waypoints[continentMapId]
    if not waypoints then
        waypoints = {}
        self.Waypoints[continentMapId] = waypoints
    end

    mapPosition.mapId = continentMapId
    mapPosition.itemName = name
    mapPosition.world = position
    waypoints[mapPosition] = true
    self:SetFocus(mapPosition)
end
function Guide:SetFocus(item)
    assert(item and item.mapId and self.Waypoints[item.mapId])
    self.Focus = item

    if C_Map and C_Map.SetUserWaypoint then
        local waypoint = UiMapPoint.CreateFromVector2D(item.mapId, item)
        self.UserWaypoint = waypoint
        C_Map.SetUserWaypoint(waypoint)
		C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end

    if WorldMapFrame:IsShown() then
        self.DataProvider:RefreshAllData()
    end
end

-- /run BtWQuests_QuestDataProvider = CreateFromMixins(BtWQuests_QuestDataProviderMixin);WorldMapFrame:AddDataProvider(BtWQuests_QuestDataProvider);
BtWQuestsGuideDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);
function BtWQuestsGuideDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	mapCanvas:SetPinTemplateType("BtWQuestsGuidePinTemplate", "BUTTON");
end
function BtWQuestsGuideDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("BtWQuestsGuidePinTemplate");
end
function BtWQuestsGuideDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

    local mapId = self:GetMap():GetMapID();
    if not mapId then
        return
    end

    local continentMapId = mapId
    local mapInfo = C_Map.GetMapInfo(continentMapId)
    while mapInfo and mapInfo.mapType > Enum.UIMapType.Continent do
        continentMapId = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(continentMapId)
    end

    local waypoints = Guide.Waypoints[continentMapId]
    if not waypoints then
        continentMapId = mapId
        waypoints = Guide.Waypoints[continentMapId]
    end
    if not waypoints then
        return
    end
    for item in pairs(waypoints) do
        local position = item
        if continentMapId ~= mapId then
            local continentId, continentPosition = C_Map.GetWorldPosFromMapPos(continentMapId, item)
            position = select(2, C_Map.GetMapPosFromWorldPos(continentId, continentPosition, mapId))
        end

        if position and position.x > 0 and position.x < 1 and position.y > 0 and position.y < 1 then
            local pin = self:GetMap():AcquirePin("BtWQuestsGuidePinTemplate", item.itemName);
            pin.waypoints = waypoints
            pin.item = item

            pin:SetPosition(position.x, position.y);
            pin.Focus:SetShown(false);--item == Guide.Focus)
            pin:Show();
        end
    end
end

BtWQuestsGuidePinMixin = CreateFromMixins(MapCanvasPinMixin);
function BtWQuestsGuidePinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_TRACKED_CONTENT");
end
function BtWQuestsGuidePinMixin:OnAcquired(itemName)
	self.itemName = itemName;
	self.mapID = self:GetMap():GetMapID();
end
function BtWQuestsGuidePinMixin:SetName(value)
    self.name = value
end
function BtWQuestsGuidePinMixin:OnMouseEnter()
    local tooltip = WorldMapTooltip or GameTooltip
    if self.itemName then
        tooltip:SetOwner(self, "ANCHOR_LEFT");
        tooltip:SetText(self.itemName);
        tooltip:Show();
    end
end
function BtWQuestsGuidePinMixin:OnMouseLeave()
    local tooltip = WorldMapTooltip or GameTooltip
	tooltip:Hide();
end
function BtWQuestsGuidePinMixin:OnClick(button)
    if button == "RightButton" or (button == "LeftButton" and IsControlKeyDown()) then
        self.waypoints[self.item] = nil
		self:GetMap():RemovePin(self);
    elseif button == "LeftButton" then
        Guide:SetFocus(self.item)
    end
end

if C_Map and C_Map.SetUserWaypoint then
    hooksecurefunc(C_Map, "SetUserWaypoint", function (waypoint)
        if Guide.UserWaypoint ~= waypoint then
            Guide.UserWaypoint = nil
        end
    end)
    hooksecurefunc(C_Map, "ClearUserWaypoint", function ()
        if Guide.UserWaypoint then
            Guide.UserWaypoint = nil
            Guide.Waypoints[Guide.Focus.mapId][Guide.Focus] = nil
            Guide.DataProvider:RefreshAllData()
        end
    end);
end

local function GetClosestWaypoint(playerX, playerY, playerMapId)
    local closestWaypoint, closestDistanceSq = nil, 0xffffffff;
    for _,waypoints in pairs(Guide.Waypoints) do
        for waypoint in pairs(waypoints) do
            local targetX, targetY, targetMapId = waypoint.world.x, waypoint.world.y, waypoint.world.mapId;
            if playerMapId == targetMapId then
                local x = playerX - targetX;
                local y = playerY - targetY;
                local distanceSq = x * x + y * y;

                if closestDistanceSq > distanceSq then
                    closestDistanceSq = distanceSq
                    closestWaypoint = waypoint
                end
            end
        end
    end
    return closestWaypoint;
end

local maxDistanceSq = 100
local function CheckGuideDistance()
    while true do
        if not Guide.Focus then
            return;
        end

        local playerX, playerY, _, playerMapId = UnitPosition("player");
        local targetX, targetY, targetMapId = Guide.Focus.world.x, Guide.Focus.world.y, Guide.Focus.world.mapId;
        if playerMapId ~= targetMapId then
            return;
        end

        local x = playerX - targetX;
        local y = playerY - targetY;
        local distanceSq = x * x + y * y;

        if distanceSq > maxDistanceSq then
            return
        end

        C_Map.ClearUserWaypoint(); -- We dont need to remove the Guide data because it hooks C_Map.ClearUserWaypoint

        local waypoint = GetClosestWaypoint(playerX, playerY, playerMapId);
        if not waypoint then
            return;
        end
        Guide:SetFocus(waypoint);
    end
end

local timer;
EventRegistry:RegisterFrameEventAndCallback("PLAYER_STARTED_MOVING", function ()
    timer = C_Timer.NewTicker(0.5, CheckGuideDistance)
end);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_STOPPED_MOVING", function ()
    if timer then
        CheckGuideDistance()
        timer:Cancel()
    end
end);
