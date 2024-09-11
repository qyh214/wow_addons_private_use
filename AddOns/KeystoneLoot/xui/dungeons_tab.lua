local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;

local _dungeonFrames = {};
local _rows = 1;


local TabFrame = KeystoneLoot:CreateTab('dungeons', 1, DUNGEONS);

function TabFrame:Update()
	local slotId = KeystoneLootCharDB.selectedSlotId;

	KeystoneLoot:UpdateCatalyst();

	for _, DungeonFrame in next, _dungeonFrames do
		local challengeModeId = DungeonFrame.challengeModeId;
		local itemList;
		if (slotId == -1) then
			itemList = KeystoneLoot:GetFavoriteItemList(challengeModeId);
		else
			itemList = KeystoneLoot:GetDungeonItemList(challengeModeId);
		end

		DungeonFrame:SetItems(itemList);
		DungeonFrame:UpdateTeleport();
	end
end

local NoSeasonText = TabFrame:CreateFontString('ARTWORK', nil, 'GameFontHighlightLarge');
NoSeasonText:Hide();
NoSeasonText:SetPoint('TOPLEFT', 20, -80);
NoSeasonText:SetPoint('BOTTOMRIGHT', -20, 26);
NoSeasonText:SetText(MYTHIC_PLUS_TAB_DISABLE_TEXT);

local FilterBg = TabFrame:CreateTexture(nil, 'BACKGROUND');
FilterBg:SetSize(340, 34);
FilterBg:SetPoint('TOP', 0, -30);
FilterBg:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight');
FilterBg:SetBlendMode('ADD');
FilterBg:SetVertexColor(0.1, 0.1, 0.1, 1);


local ClassDropdownButton = KeystoneLoot:CreateDropdownButton(TabFrame);
ClassDropdownButton:SetPoint('TOP', -120, -35);

local function SetClassAndSpec(classId, specId)
	if (specId == 0) then
		local _, _, playerClassId = UnitClass('player');
		specId = playerClassId == classId and (GetSpecializationInfo(GetSpecialization() or 1)) or (GetSpecializationInfoForClassID(classId, 1));
	end

	KeystoneLootCharDB.selectedClassId = classId;
	KeystoneLootCharDB.selectedSpecId = specId;

	ClassDropdownButton:UpdateText();
	TabFrame:Update();
end

function ClassDropdownButton:UpdateText()
	local classId = KeystoneLootCharDB.selectedClassId;
	local specId = KeystoneLootCharDB.selectedSpecId;

	local classInfo = C_CreatureInfo.GetClassInfo(classId);
	local classColorStr = RAID_CLASS_COLORS[classInfo.classFile].colorStr;
	local specName = GetSpecializationNameForSpecID(specId);

	local text;
	if (specName == nil or specName =='') then
		text = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classInfo.className);
	else
		text = HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT:format(classColorStr, classInfo.className, specName);
	end

	self.Text:SetText(text);
end

function ClassDropdownButton:GetList()
	local selectedClassId = KeystoneLootCharDB.selectedClassId;
	local selectedSpecId = KeystoneLootCharDB.selectedSpecId;
	local _list = {};

	local numClasses = GetNumClasses();
	for classIndex=1, numClasses do
		local classDisplayName, classFile, classId = GetClassInfo(classIndex);
		local classColorStr = RAID_CLASS_COLORS[classFile].colorStr;
		local isSelectedClass = classId == selectedClassId;

		if (isSelectedClass and classIndex ~= 1) then
			local info = {};
			info.divider = true;
			table.insert(_list, info);
		end

		local info = {};
		info.text = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classDisplayName)..(isSelectedClass and '' or ' ...');
		info.checked = isSelectedClass;
		info.notCheckable = isSelectedClass;
		info.disabled = isSelectedClass;
		info.args = { classId, 0 };
		info.func = SetClassAndSpec;
		info.keepShownOnClick = true;
		table.insert(_list, info);

		if (isSelectedClass) then
			for specIndex=1, GetNumSpecializationsForClassID(classId) do
				local specId, specName = GetSpecializationInfoForClassID(classId, specIndex);

				local info = {};
				info.leftPadding = 10;
				info.text = specName;
				info.checked = selectedSpecId == specId;
				info.disabled = info.checked;
				info.args = { classId, specId };
				info.func = SetClassAndSpec;
				table.insert(_list, info);
			end

			if (classIndex ~= numClasses) then
				local info = {};
				info.divider = true;
				table.insert(_list, info);
			end
		end
	end

	return _list;
end


local SlotDropdownButton = KeystoneLoot:CreateDropdownButton(TabFrame);
SlotDropdownButton:SetPoint('TOP', 0, -35);

local function SetSlot(slotId)
	KeystoneLootCharDB.selectedSlotId = slotId;

	SlotDropdownButton:UpdateText();
	TabFrame:Update();
end

function SlotDropdownButton:UpdateText()
	local slotId = KeystoneLootCharDB.selectedSlotId;

	local slotList = KeystoneLoot:GetSlotList();
	local text = slotId == -1 and FAVORITES or slotList[slotId + 1];

	self.Text:SetText(text);
end

function SlotDropdownButton:GetList()
	local selectedSlotId = KeystoneLootCharDB.selectedSlotId;
	local _list = {};

	local info = {};
	info.text = FAVORITES;
	info.checked = selectedSlotId == -1;
	info.disabled = info.checked;
	info.args = -1;
	info.func = SetSlot;
	table.insert(_list, info);

	local info = {};
	info.divider = true;
	table.insert(_list, info);

	for slotId, slotName in next, KeystoneLoot:GetSlotList() do
		local id = slotId - 1;

		local hasSlotItems = KeystoneLoot:HasDungeonSlotItems(id);
		local info = {};
		info.text = slotName;
		info.hasGrayColor = not hasSlotItems;
		info.checked = selectedSlotId == id;
		info.disabled = info.hasGrayColor or info.checked;
		info.args = id;
		info.func = SetSlot;
		table.insert(_list, info);
	end

	return _list;
end


local ItemLevelDropdownButton = KeystoneLoot:CreateDropdownButton(TabFrame);
ItemLevelDropdownButton:SetPoint('TOP', 120, -35);

local function SetItemLevel(categoryId, categoryRank)
	KeystoneLootCharDB.selectedDungeonItemLevel = categoryId..'-'..categoryRank;

	ItemLevelDropdownButton:UpdateText();
end

function ItemLevelDropdownButton:UpdateText()
	self.Text:SetText(KeystoneLoot:UpdateUpgradeTooltip() or EMPTY);
end

function ItemLevelDropdownButton:GetList()
	local selectedCategoryId, selectedCategoryRank = ('-'):split(KeystoneLootCharDB.selectedDungeonItemLevel);
	local _list = {};
	local _itemLevels = KeystoneLoot:GetDungeonItemLevels();

	if (#_itemLevels > 0 and selectedCategoryId == '0') then
		selectedCategoryId, selectedCategoryRank = _itemLevels[1].id, 1;
	end

	local numMenuList = #_itemLevels;
	for index, category in next, _itemLevels do
		local isSelectedCategoryId = selectedCategoryId == category.id;

		if (isSelectedCategoryId and index ~= 1) then
			local info = {};
			info.divider = true;
			table.insert(_list, info);
		end

		local info = {};
		info.text = Translate[category.text]..(isSelectedCategoryId and '' or ' ...');
		info.checked = isSelectedCategoryId;
		info.notCheckable = isSelectedCategoryId;
		info.disabled = isSelectedCategoryId;
		info.args = { category.id, 1 };
		info.func = SetItemLevel;
		info.keepShownOnClick = true;
		table.insert(_list, info);

		if (isSelectedCategoryId) then
			for index, entry in next, category.entries do
				local info = {};
				info.leftPadding = 10;
				info.text = entry.text;
				info.checked = tonumber(selectedCategoryRank) == index;
				info.disabled = info.checked;
				info.args = { category.id, index };
				info.func = SetItemLevel;
				table.insert(_list, info);
			end

			if (index ~= numMenuList) then
				local info = {};
				info.divider = true;
				table.insert(_list, info);
			end
		end

	end

	return _list;
end


local function CreateDungeonFrames()
	local dungeonList = KeystoneLoot:GetDungeonList();
	if (#dungeonList == 0) then
		NoSeasonText:Show();
		return;
	end

	for index, dungeonInfo in next, dungeonList do
		local DungeonFrame = KeystoneLoot:CreateDungeonFrame(TabFrame);
		DungeonFrame.challengeModeId = dungeonInfo.challengeModeId;
		DungeonFrame.teleportSpellId = dungeonInfo.teleportSpellId;

		if (index == 1) then
			DungeonFrame:SetPoint('TOP', -110, -100);
		elseif (mod(index, 2) == 1) then
			DungeonFrame:SetPoint('TOP', _dungeonFrames[index - 2], 'BOTTOM', 0, -40);

			_rows = _rows + 1;
		else
			DungeonFrame:SetPoint('LEFT', _dungeonFrames[index - 1], 'RIGHT', 40, 0);
		end

		local name = C_ChallengeMode.GetMapUIInfo(dungeonInfo.challengeModeId);
		DungeonFrame.Title:SetText(Translate[name]);
		DungeonFrame.Bg:SetTexture(dungeonInfo.bgTexture);

		table.insert(_dungeonFrames, DungeonFrame);
	end
end

do
	local firstTime = true;
	local function OnShow(self)
		if (firstTime) then
			firstTime = false;
			CreateDungeonFrames();
		end

		ClassDropdownButton:UpdateText();
		SlotDropdownButton:UpdateText();
		ItemLevelDropdownButton:UpdateText();

		self:Update();
		self:SetSize(476, 100 + (_rows * 130));
	end
	TabFrame:SetScript('OnShow', OnShow);

	local function OnEvent(self, event, ...)
		if (not KeystoneLootDB.lootReminderEnabled) then
			return;
		end

		local challengeModeId = C_ChallengeMode.GetActiveChallengeMapID();
		KeystoneLoot:UpdateLootReminder(challengeModeId);
	end
	TabFrame:RegisterEvent('CHALLENGE_MODE_START');
	TabFrame:SetScript('OnEvent', OnEvent);
end