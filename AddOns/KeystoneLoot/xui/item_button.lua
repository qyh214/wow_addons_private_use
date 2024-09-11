local AddonName, KeystoneLoot = ...;




local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT');

	local itemLink = KeystoneLoot:GetUpgradeItemLink(self.itemId);
	if (itemLink) then
		GameTooltip:SetHyperlink(itemLink);
	else
		GameTooltip:SetText(RETRIEVING_ITEM_INFO, RED_FONT_COLOR:GetRGB());
	end

	if (self.OtherSpec:IsShown()) then
		local specNames = self.specNames;
		local numSpecs = #specNames;

		GameTooltip:AddLine(' ');
		if (numSpecs == 2) then
			GameTooltip:AddLine('|A:quest-important-available:16:16:0:0|a '..FOR_OR_SPECIALIZATIONS:format(specNames[1], specNames[2]));
		elseif (numSpecs == 1) then
				GameTooltip:AddLine('|A:quest-important-available:16:16:0:0|a '..FOR_SPECIALIZATION:format(specNames[1]));
		else
			GameTooltip:AddLine('|A:quest-important-available:16:16:0:0|a '..FOR_SPECIALIZATION:format(table.concat(self.specNames, '/')));
		end
	end

	GameTooltip:Show();

	local _, _, playerClassId = UnitClass('player');
	local classId = KeystoneLootCharDB.selectedClassId;
	local slotId = KeystoneLootCharDB.selectedSlotId;

	if (not self.isFavorite and (classId == playerClassId or slotId == -1) and not self.reminderBlocked) then
		local FavoriteStar = self.FavoriteStar;

		FavoriteStar:SetDesaturated(true);
		FavoriteStar:Show();
	end

	if (IsModifiedClick('DRESSUP')) then
		ShowInspectCursor();
	else
		ResetCursor();
	end

	KeystoneLoot:GetOverview().TooltipFrame:Hide();
end

local function OnLeave(self)
	GameTooltip:Hide();

	if (not self.isFavorite) then
		self.FavoriteStar:Hide();
	end

	ResetCursor();
end

local function OnClick(self)
	local itemId = self.itemId;

	if (IsModifierKeyDown()) then
		local _, itemLink = C_Item.GetItemInfo(itemId); -- NOTE: Man kann keine modifizierten Items posten
		HandleModifiedItemClick(itemLink);
		return;
	end

	local _, _, playerClassId = UnitClass('player');
	local classId = KeystoneLootCharDB.selectedClassId;
	local slotId = KeystoneLootCharDB.selectedSlotId;

	if (classId ~= playerClassId and slotId ~= -1 or self.reminderBlocked) then
		return;
	end

	local specId = KeystoneLootCharDB.selectedSpecId;
	if ((slotId == -1 and KeystoneLootDB.favoritesShowAllSpecs) or self.lootReminder) then
		specId = self.specId;
	end

	local isFavoriteItem = KeystoneLoot:IsFavoriteItem(itemId, specId);
	if (not isFavoriteItem) then
		self.isFavorite = true;
		self.FavoriteStar:SetDesaturated(false);

		local challengeModeId = self:GetParent().challengeModeId or self:GetParent().bossId;
		local icon = self.Icon:GetTexture();
		KeystoneLoot:AddFavoriteItem(challengeModeId, specId, itemId, icon);
	else
		self.isFavorite = false;
		self.FavoriteStar:SetDesaturated(true);

		if (slotId == -1 and KeystoneLootDB.favoritesShowAllSpecs) then
			specId = nil;
		end
		KeystoneLoot:RemoveFavoriteItem(itemId, specId);
	end
end

local function UpdateFavoriteStarIcon(self)
	local itemId = self.itemId;
	local specId = self.specId;

	local isFavoriteItem = KeystoneLoot:IsFavoriteItem(itemId, specId);
	self.isFavorite = isFavoriteItem;

	local FavoriteStar = self.FavoriteStar;
	FavoriteStar:SetDesaturated(not isFavoriteItem);
	FavoriteStar:SetShown(isFavoriteItem);
end

local function UpdateOtherSpecIcon(self)
	self.specNames = nil;
	local OtherSpec = self.OtherSpec;

	if (not self.isFavorite or not KeystoneLootDB.favoritesShowAllSpecs) then
		OtherSpec:Hide();
		return;
	end

	local itemId = self.itemId;
	local itemInfo = KeystoneLoot:GetItemInfo(itemId);
	if (itemInfo == nil) then
		OtherSpec:Hide();
		return;
	end

	local specNames = {};
	local showIcon = true;
	local selectedSpecId = KeystoneLootCharDB.selectedSpecId;
	local _, _, playerClassId = UnitClass('player');

	local specList = itemInfo.classes[playerClassId];
	for index, specId in next, specList do
		if (selectedSpecId == specId) then
			showIcon = false;
		else
			local _, specName = GetSpecializationInfoByID(specId);
			table.insert(specNames, specName);
		end
	end

	self.specNames = specNames;
	OtherSpec:SetShown(showIcon);
end

local function UpdateStatVisibility(self)
	local itemId = self.itemId;
	local itemInfo = KeystoneLoot:GetItemInfo(itemId);
	if (itemInfo == nil) then
		return;
	end

	local hasItemStat;
    if (not itemInfo.stats) then
        hasItemStat = KeystoneLootCharDB.statHighlightingNoStatsEnabled;
    end

	if (hasItemStat == nil) then
		local critEnabled = KeystoneLootCharDB.statHighlightingCritEnabled;
		local hasteEnabled = KeystoneLootCharDB.statHighlightingHasteEnabled;
		local masteryEnabled = KeystoneLootCharDB.statHighlightingMasteryEnabled;
		local versatilityEnabled = KeystoneLootCharDB.statHighlightingVersatilityEnabled;

		for _, stat in next, itemInfo.stats do
			if (
				(stat == 0 and critEnabled) or
				(stat == 1 and hasteEnabled) or
				(stat == 2 and masteryEnabled) or
				(stat == 3 and versatilityEnabled)
			) then
				hasItemStat = true;
				break;
			end
		end
	end

	self.OtherSpec:SetDesaturated(not hasItemStat);
	self.Icon:SetDesaturated(not hasItemStat);
	self:SetAlpha(hasItemStat and 1 or 0.6);
end

function KeystoneLoot:CreateItemButton(parent)
	local Button = CreateFrame('Button', nil, parent);
	Button:SetSize(32, 32);

	Button.UpdateFavoriteStarIcon = UpdateFavoriteStarIcon;
	Button.UpdateOtherSpecIcon = UpdateOtherSpecIcon;
	Button.UpdateStatVisibility = UpdateStatVisibility;
	Button.UpdateTooltip = OnEnter;
	Button:SetScript('OnEnter', OnEnter);
	Button:SetScript('OnLeave', OnLeave);
	Button:SetScript('OnClick', OnClick);

	local Icon = Button:CreateTexture(nil, 'ARTWORK', nil, 1);
	Button.Icon = Icon;
	Icon:SetAllPoints();
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

	local IconBorder = Button:CreateTexture(nil, 'ARTWORK', nil, 2);
	Button.IconBorder = IconBorder;
	IconBorder:SetSize(58, 58);
	IconBorder:SetPoint('CENTER', Icon);
	IconBorder:SetTexture('Interface\\Buttons\\UI-Quickslot2');

	local FavoriteStar = Button:CreateTexture(nil, 'ARTWORK', nil, 3);
	Button.FavoriteStar = FavoriteStar;
	FavoriteStar:SetSize(24, 24);
	FavoriteStar:SetPoint('TOPRIGHT', 8, 8);
	FavoriteStar:SetAtlas('PetJournal-FavoritesIcon');
	FavoriteStar:Hide();

	local OtherSpec = Button:CreateTexture(nil, 'ARTWORK', nil, 3);
	Button.OtherSpec = OtherSpec;
	OtherSpec:SetSize(18, 18);
	OtherSpec:SetPoint('TOPLEFT', -6, 4);
	OtherSpec:SetAtlas('quest-important-available');
	OtherSpec:Hide();

	return Button;
end