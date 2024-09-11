local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;

local _raidTabInfos = {};
local difficultyIds = {
	[DifficultyUtil.ID.PrimaryRaidLFR] = true,
	[DifficultyUtil.ID.PrimaryRaidNormal] = true,
	[DifficultyUtil.ID.PrimaryRaidHeroic] = true,
	[DifficultyUtil.ID.PrimaryRaidMythic] = true,
};


local TabFrame = KeystoneLoot:CreateTab('raids', 2, RAIDS);

function TabFrame:Update()
	local slotId = KeystoneLootCharDB.selectedSlotId;

	KeystoneLoot:UpdateCatalyst();

	local currentTab = KeystoneLoot:GetCurrentRaidTab();
	if (currentTab == nil)then
		TabFrame.TabDivider:Hide();
		return;
	end

	local raidTabInfos = _raidTabInfos[currentTab.id];

	for _, RaidBossFrame in next, raidTabInfos.frames do
		local bossId = RaidBossFrame.bossId;
		local itemList;
		if (slotId == -1) then
			itemList = KeystoneLoot:GetFavoriteItemList(bossId);
		else
			itemList = KeystoneLoot:GetRaidBossItemList(bossId);
		end

		RaidBossFrame:SetItems(itemList);
	end

	self:SetSize(36 + (raidTabInfos.column * 290), 146 + (raidTabInfos.row * 90));
end


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
	local currentTab = KeystoneLoot:GetCurrentRaidTab();
	local journalInstanceId = currentTab and currentTab.id or 0;
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

		local hasSlotItems = KeystoneLoot:HasRaidSlotItems(journalInstanceId, id);
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
	KeystoneLootCharDB.selectedRaidItemLevel = categoryId..'-'..categoryRank;

	ItemLevelDropdownButton:UpdateText();
	TabFrame:Update();
end

function ItemLevelDropdownButton:UpdateText()
	self.Text:SetText(KeystoneLoot:UpdateUpgradeTooltip() or EMPTY);
end

function ItemLevelDropdownButton:GetList()
	local selectedCategoryId, selectedCategoryRank = ('-'):split(KeystoneLootCharDB.selectedRaidItemLevel);
	local _list = {};
	local _itemLevels = KeystoneLoot:GetRaidItemLevels();

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


local TabDivider = TabFrame:CreateTexture(nil, 'BACKGROUND');
TabFrame.TabDivider = TabDivider;
TabDivider:SetHeight(2);
TabDivider:SetPoint('TOPLEFT', 12, -102);
TabDivider:SetPoint('TOPRIGHT', -12, -102);
TabDivider:SetColorTexture(0.1, 0.1, 0.1);


local function CreateBossFrames(parent, bossList)
	local raidTabInfos = { row = 1, column = 1, frames = {} };
	if (_raidTabInfos[parent.id] == nil) then
		_raidTabInfos[parent.id] = raidTabInfos;
	end

	local breakPoint = 2;
	if (#bossList == 9) then
		breakPoint = 3;
	end

	for index, bossInfo in next, bossList do

		local RaidBossFrame = KeystoneLoot:CreateRaidFrame(parent);
		RaidBossFrame.bossId = bossInfo.bossId;

		if (index == 1) then
			RaidBossFrame:SetPoint('TOPLEFT', 38, -140);
		elseif (mod(index, breakPoint) == 1) then
			RaidBossFrame:SetPoint('TOP', raidTabInfos.frames[index - breakPoint], 'BOTTOM', 0, -40);

			raidTabInfos.row = raidTabInfos.row + 1;
			raidTabInfos.column = 1;
		else
			RaidBossFrame:SetPoint('LEFT', raidTabInfos.frames[index - 1], 'RIGHT', 40, 0);

			raidTabInfos.column = raidTabInfos.column + 1;
		end

		local name = EJ_GetEncounterInfo(bossInfo.bossId);
		RaidBossFrame.Title:SetText(Translate[name]);

		local _, _, _, bossTexture = EJ_GetCreatureInfo(1, bossInfo.bossId);
		SetPortraitTextureFromCreatureDisplayID(RaidBossFrame.BossIcon, bossTexture);

		table.insert(raidTabInfos.frames, RaidBossFrame);
	end
end

local function CreateRaidFrames()
	for index, raidInfo in next, KeystoneLoot:GetRaidList() do
		local name = EJ_GetInstanceInfo(raidInfo.journalInstanceId);
		local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(raidInfo.instanceId);
		if (modifiedInstanceInfo) then
			local atlasName = GetFinalNameFromTextureKit('%s-large', modifiedInstanceInfo.uiTextureKit);
			name = '|A:'..atlasName..':16:16:0:0|a '..name;
		end

		local TabFrame = KeystoneLoot:CreateRaidTab(raidInfo.journalInstanceId, index, name);
		CreateBossFrames(TabFrame, raidInfo.bossList);
	end
end

do
	local firstTime = true;
	local function OnShow(self)
		if (firstTime) then
			firstTime = false;
			CreateRaidFrames();
		end

		ClassDropdownButton:UpdateText();
		SlotDropdownButton:UpdateText();
		ItemLevelDropdownButton:UpdateText();

		self:Update();

		local currentTab = KeystoneLoot:GetCurrentRaidTab();
		if (currentTab) then
			currentTab:UpdateSize();
		end
	end
	TabFrame:SetScript('OnShow', OnShow);

	local blacklistedNpc = {};
	local function OnEvent(self, event, ...)
		if (not KeystoneLootDB.raidLootReminderEnabled) then
			return;
		end

		local guid = UnitGUID('target') or '';
		local _, type, difficultyId = GetInstanceInfo();
		local unitType, _, _, _, _, npcId = ('-'):split(guid);
		if (InCombatLockdown() or unitType ~= 'Creature' or type ~= 'raid' or (npcId and blacklistedNpc[npcId]) or not difficultyIds[difficultyId] or UnitIsDead('target')) then
			return;
		end

		local bossId = KeystoneLoot:GetRaidBossId(tonumber(npcId));
		if (bossId == 0) then
			return;
		end

		KeystoneLoot:UpdateLootReminder(bossId);

		blacklistedNpc[npcId] = true;
	end
	TabFrame:RegisterEvent('PLAYER_TARGET_CHANGED');
	TabFrame:SetScript('OnEvent', OnEvent);
end