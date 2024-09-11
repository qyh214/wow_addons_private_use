local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;


local OverviewFrame = KeystoneLoot:GetOverview();

local Frame = CreateFrame('Frame', nil, OverviewFrame);
OverviewFrame.CatalystFrame = Frame;
Frame.challengeModeId = 'catalyst';
Frame:Hide();
Frame:SetFrameLevel(0);
Frame:SetSize(70, 140);
Frame:SetPoint('TOPLEFT', OverviewFrame, 'TOPRIGHT', -10, -40);

local Border = CreateFrame('Frame', nil, Frame, 'DialogBorderTemplate');
Border.Bg:SetTexture('Interface\\FrameGeneral\\UI-Background-Marble');


local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
	GameTooltip:SetText(Translate['Revival Catalyst'], HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:Show();
end

local function OnLeave(self)
	GameTooltip:Hide();
end

local CatalystIconFrame = CreateFrame('Frame', nil, Frame);
CatalystIconFrame:SetSize(32, 32);
CatalystIconFrame:SetPoint('TOP', 0, -20);
CatalystIconFrame:SetScript('OnEnter', OnEnter);
CatalystIconFrame:SetScript('OnLeave', OnLeave);

local CatalystIcon = CatalystIconFrame:CreateTexture(nil, 'ARTWORK');
CatalystIcon:SetAllPoints();
CatalystIcon:SetAtlas('CreationCatalyst-32x32');

local Arrow = CatalystIconFrame:CreateTexture(nil, 'ARTWORK');
Arrow:SetSize(20, 40);
Arrow:SetPoint('TOP', 0, -31);
Arrow:SetAtlas('ItemUpgrade_HelpTipArrow');
Arrow:SetRotation(29.85);

local _itemButtons = {};
local function CreateItemButton()
	local index = #_itemButtons + 1;

	local ItemButton = KeystoneLoot:CreateItemButton(Frame);

	if (index == 1) then
		ItemButton:SetPoint('TOP', 0, -90);
	else
		ItemButton:SetPoint('TOP', _itemButtons[index - 1], 'BOTTOM', 0, -8);
	end

	table.insert(_itemButtons, ItemButton);

	return ItemButton;
end

local function SetItems(itemList)
	local numItems = #itemList;
	for index=1, numItems do
		local ItemButton = _itemButtons[index] or CreateItemButton();
		local itemInfo = itemList[index];

		ItemButton.itemId = itemInfo.itemId;
		ItemButton.specId = itemInfo.specId;

		ItemButton.Icon:SetTexture(itemInfo.icon);
		ItemButton:UpdateFavoriteStarIcon();
		ItemButton:UpdateOtherSpecIcon();
		ItemButton:UpdateStatVisibility();
		ItemButton:Show();
	end

	for index=(numItems + 1), #_itemButtons do
		local ItemButton = _itemButtons[index];
		ItemButton:Hide();
	end

	Frame:SetHeight(104 + (numItems * 40));
	Frame:SetShown(numItems ~= 0);
end

function KeystoneLoot:UpdateCatalyst()
	local slotId = KeystoneLootCharDB.selectedSlotId;
	local challengeModeId = Frame.challengeModeId;

	local itemList;
	if (slotId == -1) then
		itemList = KeystoneLoot:GetFavoriteItemList(challengeModeId);
	else
		itemList = KeystoneLoot:GetCatalystItemList();
	end

	SetItems(itemList);
end