-- This is a modified version of the Storyline Quest Data Provider code but using BtWQuests data instead of C_QuestLine data to get a list of quests
-- /run BtWQuests_QuestDataProvider = CreateFromMixins(BtWQuests_QuestDataProviderMixin);WorldMapFrame:AddDataProvider(BtWQuests_QuestDataProvider);
BtWQuestsQuestDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);
function BtWQuestsQuestDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	mapCanvas:SetPinTemplateType("BtWQuestsQuestPinTemplate", "BUTTON");
end

function BtWQuestsQuestDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("BtWQuestsQuestPinTemplate");
end

function BtWQuestsQuestDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if BtWQuests.Settings.showMapPins then
		local mapID = self:GetMap():GetMapID();
		local mapInfo = C_Map.GetMapInfo(mapID);
		if mapInfo and mapInfo.mapType ~= Enum.UIMapType.Continent and mapInfo.mapType ~= Enum.UIMapType.World and mapInfo.mapType ~= Enum.UIMapType.Cosmic then
			local items = BtWQuestsDatabase:GetAvailableMapItems(mapID, BtWQuestsCharacters:GetPlayer())
			for _,item in ipairs(items) do
				local pin = self:GetMap():AcquirePin("BtWQuestsQuestPinTemplate", item.itemName);
				pin:SetPosition(item.x, item.y);
				if BtWQuests.Settings.smallMapPins then
					pin:SetSize(16, 16);
				else
					pin:SetSize(22, 22);
				end
				pin:Show();
			end
		end
	end
end

BtWQuestsQuestPinMixin = CreateFromMixins(MapCanvasPinMixin);
function BtWQuestsQuestPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_PING");
end
function BtWQuestsQuestPinMixin:OnAcquired(itemName)
	self.itemName = itemName;
	self.mapID = self:GetMap():GetMapID();
end
function BtWQuestsQuestPinMixin:SetName(value)
    self.itemName = value
end
function BtWQuestsQuestPinMixin:IsMouseWithin()
    return MouseIsOver(self)
end
function BtWQuestsQuestPinMixin:OnUpdate()
    local x, y = GetCursorPosition()
    if x == self.lastMouseX and y == self.lastMouseY then
        return
    end
    self.lastMouseX, self.lastMouseY = x, y

	local quests = {}
    for pin in self:GetMap():EnumeratePinsByTemplate("BtWQuestsQuestPinTemplate") do
        if pin:IsMouseWithin() then
			quests[#quests+1] = pin.itemName
        end
    end
    local tooltip = WorldMapTooltip or GameTooltip
	tooltip:SetOwner(self, "ANCHOR_LEFT");
	if #quests == 1 then
		tooltip:AddLine(quests[1]);
		tooltip:AddLine(AVAILABLE_QUEST, 1, 1, 1, true);
	else
		tooltip:AddLine(AVAILABLE_QUESTS, 1, 1, 1, true);
		for _,itemName in ipairs(quests) do
			tooltip:AddLine(itemName);
		end
	end
	tooltip:Show();
end
function BtWQuestsQuestPinMixin:OnMouseEnter()
	self:SetScript("OnUpdate", self.OnUpdate)
end
function BtWQuestsQuestPinMixin:OnMouseLeave()
    self:SetScript("OnUpdate", nil)

    local tooltip = WorldMapTooltip or GameTooltip
	tooltip:Hide();
end
function BtWQuestsQuestPinMixin:OnClick()
	local x, y = self:GetPosition()
	BtWQuests_AddWaypoint(self.mapID, x, y, self.itemName)
end