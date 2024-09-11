local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;

local _specializationFrames = {};
local SPEC_FORMAT_STRINGS = { -- https://www.townlong-yak.com/framexml/live/Blizzard_ClassTalentUI/Blizzard_ClassTalentSpecTab.lua
	[62] = 'mage-arcane',
	[63] = 'mage-fire',
	[64] = 'mage-frost',
	[65] = 'paladin-holy',
	[66] = 'paladin-protection',
	[70] = 'paladin-retribution',
	[71] = 'warrior-arms',
	[72] = 'warrior-fury',
	[73] = 'warrior-protection',
	[102] = 'druid-balance',
	[103] = 'druid-feral',
	[104] = 'druid-guardian',
	[105] = 'druid-restoration',
	[250] = 'deathknight-blood',
	[251] = 'deathknight-frost',
	[252] = 'deathknight-unholy',
	[253] = 'hunter-beastmastery',
	[254] = 'hunter-marksmanship',
	[255] = 'hunter-survival',
	[256] = 'priest-discipline',
	[257] = 'priest-holy',
	[258] = 'priest-shadow',
	[259] = 'rogue-assassination',
	[260] = 'rogue-outlaw',
	[261] = 'rogue-subtlety',
	[262] = 'shaman-elemental',
	[263] = 'shaman-enhancement',
	[264] = 'shaman-restoration',
	[265] = 'warlock-affliction',
	[266] = 'warlock-demonology',
	[267] = 'warlock-destruction',
	[268] = 'monk-brewmaster',
	[269] = 'monk-windwalker',
	[270] = 'monk-mistweaver',
	[577] = 'demonhunter-havoc',
	[581] = 'demonhunter-vengeance',
	[1467] = 'evoker-devastation',
	[1468] = 'evoker-preservation',
	[1473] = 'evoker-augmentation',
}


local function OnShow(self)
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end

local function OnHide(self)
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
end


local Frame = CreateFrame('Frame', nil, UIParent, 'SimplePanelTemplate');
Frame:Hide();
Frame:SetSize(520, 217);
Frame:SetPoint('CENTER', 0, 217);

Frame:SetToplevel(true);
Frame:SetMovable(true);
Frame:SetUserPlaced(true);
Frame:SetClampedToScreen(true);

Frame:EnableMouse(true);
Frame:RegisterForDrag('LeftButton');

Frame:SetScript('OnDragStart', Frame.StartMoving);
Frame:SetScript('OnDragStop', Frame.StopMovingOrSizing);
Frame:SetScript('OnShow', OnShow);
Frame:SetScript('OnHide', OnHide);

Frame.Inset:Hide();

Frame.Bg:SetPoint('TOPLEFT', 0, -6);
Frame.Bg:SetPoint('BOTTOMRIGHT', -4, 3);

local HeadlineBg = Frame:CreateTexture(nil, 'BACKGROUND');
HeadlineBg:SetHeight(26);
HeadlineBg:SetPoint('TOPLEFT', 40, -21);
HeadlineBg:SetPoint('TOPRIGHT', -40, -21);
HeadlineBg:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight');
HeadlineBg:SetBlendMode('ADD');
HeadlineBg:SetVertexColor(0.1, 0.1, 0.1, 1);

local HeadlineText = Frame:CreateFontString('ARTWORK', nil, 'GameFontNormal');
HeadlineText:SetHeight(26);
HeadlineText:SetPoint('TOPLEFT', 18, -21);
HeadlineText:SetPoint('TOPRIGHT', -20, -21);
HeadlineText:SetText(Translate['Correct loot specialization set?']);


local function CloseButton_OnClick(self)
	self:GetParent():Hide();
end

local CloseButton = CreateFrame('Button', nil, Frame, 'UIPanelCloseButtonDefaultAnchors');
CloseButton:SetScript('OnClick', CloseButton_OnClick);




local function LootSpec_OnClick(self)
	SetLootSpecialization(self:GetParent().specId);

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_SPEC_ACTIVATE);
end

-- https://gist.github.com/sapphyrus/fd9aeb871e3ce966cc4b0b969f62f539
local function deep_equals(o1, o2, ignore_mt)
    if (o1 == o2) then
		return true;
	end

    local o1Type = type(o1);
    local o2Type = type(o2);

    if (o1Type ~= o2Type) then
		return false;
	end

    if (o1Type ~= 'table') then
		return false;
	end

    if (not ignore_mt) then
        local mt1 = getmetatable(o1);
        if (mt1 and mt1.__eq) then
            return o1 == o2;
        end
    end

    for key1, value1 in next, o1 do
        local value2 = o2[key1];
        if (value2 == nil or deep_equals(value1, value2, ignore_mt) == false) then
            return false;
        end
    end

    for key2 in next, o2 do
        if (o1[key2] == nil) then
			return false;
		end
    end

    return true;
end

local function IsOnItemList(specItemList, itemId)
	for index, item in next, specItemList do
		if (item.itemId == itemId) then
			return true;
		end
	end
end

local function IsEverythingTheSame(itemList)
	local _tmp = {};
	for specId, items in next, itemList do
		_tmp[specId] = {};

		for _, item in next, items do
			table.insert(_tmp[specId], item.itemId);
		end

		table.sort(_tmp[specId], function(a, b)
			return a < b;
		end);
	end

    local firstSubtable;
    for _, subtable in next, _tmp do
        if (not firstSubtable) then
            firstSubtable = subtable
        elseif (not deep_equals(firstSubtable, subtable)) then
            return false
        end
    end

    return true
end

local function GetLootReminderItemList(challengeModeId)
	local favoriteLoot = KeystoneLootCharDB.favoriteLoot;
	local _itemList = {};

	if (favoriteLoot[challengeModeId] == nil) then
		return {};
	end

	local _, _, classId = UnitClass('player');
	local numSpecs = GetNumSpecializations();
	for i=1, numSpecs do
		local specId = GetSpecializationInfo(i);

		for itemId, itemInfo in next, favoriteLoot[challengeModeId][specId] or {} do
			local specList = KeystoneLoot:GetItemInfo(itemId).classes[classId];
			local numItemSpecs = #specList;

			if (numItemSpecs ~= numSpecs) then
				for index, specId in next, specList do
					if (_itemList[specId] == nil) then
						_itemList[specId] = {};
					end

					if (not IsOnItemList(_itemList[specId], itemId)) then
						table.insert(_itemList[specId], {
							itemId = itemId,
							specId = specId,
							icon = itemInfo.icon
						});
					end
				end
			end
		end
	end

	local lootSpecId = GetLootSpecialization();
	if (lootSpecId == 0) then
		lootSpecId = GetSpecializationInfo(GetSpecialization());
	end

	local countSpecs = 0;
	for specId in next, _itemList do
		countSpecs = countSpecs + 1;
	end

	if ((countSpecs == 1 and _itemList[lootSpecId]) or (countSpecs > 1 and _itemList[lootSpecId] and IsEverythingTheSame(_itemList))) then
		return {};
	end

	return _itemList;
end

local function CreateSpecializationFrame()
	local index = #_specializationFrames + 1;

	local SpecFrame = CreateFrame('Frame', nil, Frame, 'InsetFrameTemplate');
	SpecFrame:SetSize(180, 90);

	if (index == 1) then
		SpecFrame:SetPoint('TOPLEFT', 20, -80);
	else
		SpecFrame:SetPoint('LEFT', _specializationFrames[index - 1], 'RIGHT', 20, 0);
	end

	local FrameBg = SpecFrame.Bg;
	FrameBg:SetHorizTile(false);
	FrameBg:SetVertTile(false);

	local Title = SpecFrame:CreateFontString('ARTWORK', nil, 'GameFontHighlightLarge');
	SpecFrame.Title = Title;
	Title:SetPoint('BOTTOM', SpecFrame, 'TOP', 0, 5);

	local Button = CreateFrame('Button', nil, SpecFrame, 'SharedButtonSmallTemplate');
	SpecFrame.Button = Button;
	Button:SetSize(120, 22);
	Button:SetPoint('TOP', SpecFrame, 'BOTTOM', 0, -10);
	Button:SetScript('OnClick', LootSpec_OnClick);
	Button:SetText(TALENT_SPEC_ACTIVATE);

	local Active = SpecFrame:CreateFontString('ARTWORK', nil, 'GameFontHighlightLarge');
	SpecFrame.Active = Active;
	Active:SetTextColor(0, 1, 0);
	Active:SetPoint('TOP', SpecFrame, 'BOTTOM', 0, -12);
	Active:SetText(SPEC_ACTIVE);

	SpecFrame.itemFrames = {};
	for index=1, 8 do
		local ItemButton = KeystoneLoot:CreateItemButton(SpecFrame);
		ItemButton.lootReminder = true;

		if (index == 1) then
			ItemButton:SetPoint('TOPLEFT', 11, -10);
		elseif (mod(index, 4) == 1) then
			ItemButton:SetPoint('TOP', SpecFrame.itemFrames[index - 4], 'BOTTOM', 0, -8);
		else
			ItemButton:SetPoint('LEFT', SpecFrame.itemFrames[index - 1], 'RIGHT', 10, 0);
		end

		table.insert(SpecFrame.itemFrames, ItemButton);
	end

	function SpecFrame:SetItems(itemList)
		for index, ItemButton in next, self.itemFrames do
			local itemInfo = itemList[index];
			if (itemInfo) then
				ItemButton.itemId = itemInfo.itemId;
				ItemButton.specId = itemInfo.specId;
				ItemButton.reminderBlocked = not KeystoneLoot:IsFavoriteItem(itemInfo.itemId, itemInfo.specId);

				ItemButton.Icon:SetTexture(itemInfo.icon);
				ItemButton:UpdateFavoriteStarIcon();
				ItemButton.specNames = nil;
				ItemButton.OtherSpec:Hide();
				ItemButton:Show();
			else
				ItemButton:Hide();
			end
		end
	end

	table.insert(_specializationFrames, SpecFrame);

	return SpecFrame;
end

function KeystoneLoot:UpdateLootReminder(challengeModeId)
	local numSpec = 0;
	for specId, itemList in next, GetLootReminderItemList(challengeModeId) do
		numSpec = numSpec + 1;

		local SpecFrame = _specializationFrames[numSpec] or CreateSpecializationFrame();
		SpecFrame.specId = specId;
		SpecFrame.challengeModeId = challengeModeId;

		local _, specName = GetSpecializationInfoByID(specId);
		SpecFrame.Title:SetText(specName);
		SpecFrame.Bg:SetAtlas('spec-thumbnail-'..(SPEC_FORMAT_STRINGS[specId] or 'mage-arcane'));

		local lootSpecId = GetLootSpecialization();
		if (lootSpecId == 0) then
			lootSpecId = GetSpecializationInfo(GetSpecialization());
		end

		SpecFrame.Button:SetShown(lootSpecId ~= specId);
		SpecFrame.Active:SetShown(lootSpecId == specId);

		SpecFrame:SetItems(itemList);
		SpecFrame:Show();
	end

	if (numSpec == 0) then
		return;
	end

	for index=(numSpec + 1), #_specializationFrames do
		local SpecFrame = _specializationFrames[index];
		SpecFrame:Hide();
	end

	Frame:SetWidth(23 + (numSpec * 200));
	Frame:Show();
end

hooksecurefunc('SetLootSpecialization', function(newLootSpecID)
	if (Frame:IsShown()) then
		for _, SpecFrame in next, _specializationFrames do
			local specId = SpecFrame.specId;

			SpecFrame.Button:SetShown(newLootSpecID ~= specId);
			SpecFrame.Active:SetShown(newLootSpecID == specId);
		end
	end
end);