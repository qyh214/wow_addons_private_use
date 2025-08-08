local AddonName, KeystoneLoot = ...;

-- Generated automatically by KeystoneLoot Updater v2.0
-- Timestamp: 2025-08-06 06:11:32
-- WoW Build: 11.2.0 (62417)
-- Season: 15
-- WARNING: This file is auto-generated - manual changes will be overwritten!

local _raidList = {
  [15] = {
    { --[[name = "Manaschmiede Omega",]] journalInstanceId = 1302, instanceId = 2810, bossList = {
      { --[[name = "Plexuswache",]] npcId = 0, bossId = 2684, lootTable = {
        [14] = { 237523, 237525, 237528, 237533, 237534, 237543, 237547, 237551, 237567, 237736, 237739, 237813, 242394 },
        [16] = { 237523, 237525, 237528, 237533, 237534, 237543, 237547, 237551, 237567, 237736, 237739, 237813, 242394 },
        [17] = { 237523, 237525, 237528, 237533, 237534, 237543, 237547, 237551, 237567, 237736, 237739, 237813, 242394 },
        [15] = { 237523, 237525, 237528, 237533, 237534, 237543, 237547, 237551, 237567, 237736, 237739, 237813, 242394 },
      } },
      { --[[name = "Seelenbinderin Naazindhri",]] npcId = 0, bossId = 2685, lootTable = {
        [14] = { 237527, 237539, 237546, 237550, 237568, 237585, 237586, 237587, 237588, 237730, 237738, 242391, 242398, 250104 },
        [16] = { 237527, 237539, 237546, 237550, 237568, 237585, 237586, 237587, 237588, 237730, 237738, 242391, 242398, 250104 },
        [17] = { 237527, 237539, 237546, 237550, 237568, 237585, 237586, 237587, 237588, 237730, 237738, 242391, 242398, 250104 },
        [15] = { 237527, 237539, 237546, 237550, 237568, 237585, 237586, 237587, 237588, 237730, 237738, 242391, 242398, 250104 },
      } },
      { --[[name = "Loom'ithar",]] npcId = 0, bossId = 2686, lootTable = {
        [14] = { 237522, 237524, 237545, 237552, 237593, 237594, 237595, 237596, 237723, 237729, 237732, 242393, 242395 },
        [16] = { 237522, 237524, 237545, 237552, 237593, 237594, 237595, 237596, 237723, 237729, 237732, 242393, 242395 },
        [17] = { 237522, 237524, 237545, 237552, 237593, 237594, 237595, 237596, 237723, 237729, 237732, 242393, 242395 },
        [15] = { 237522, 237524, 237545, 237552, 237593, 237594, 237595, 237596, 237723, 237729, 237732, 242393, 242395 },
      } },
      { --[[name = "Schmiedeweber Araz",]] npcId = 0, bossId = 2687, lootTable = {
        [14] = { 237526, 237529, 237538, 237553, 237570, 237589, 237590, 237591, 237592, 237724, 237726, 237737, 242402 },
        [16] = { 237526, 237529, 237538, 237553, 237570, 237589, 237590, 237591, 237592, 237724, 237726, 237737, 242402 },
        [17] = { 237526, 237529, 237538, 237553, 237570, 237589, 237590, 237591, 237592, 237724, 237726, 237737, 242402 },
        [15] = { 237526, 237529, 237538, 237553, 237570, 237589, 237590, 237591, 237592, 237724, 237726, 237737, 242402 },
      } },
      { --[[name = "Der Leerenjäger",]] npcId = 0, bossId = 2688, lootTable = {
        [14] = { 237541, 237549, 237554, 237561, 237569, 237597, 237598, 237599, 237600, 237727, 237741, 242397, 242401, 243305, 243306, 243307, 243308 },
        [16] = { 237541, 237549, 237554, 237561, 237569, 237597, 237598, 237599, 237600, 237727, 237741, 242397, 242401, 243305, 243306, 243307, 243308 },
        [17] = { 237541, 237549, 237554, 237561, 237569, 237597, 237598, 237599, 237600, 237727, 237741, 242397, 242401, 243305, 243306, 243307, 243308 },
        [15] = { 237541, 237549, 237554, 237561, 237569, 237597, 237598, 237599, 237600, 237727, 237741, 242397, 242401, 243305, 243306, 243307, 243308 },
      } },
      { --[[name = "Nexuskönig Salhadaar",]] npcId = 0, bossId = 2690, lootTable = {
        [14] = { 237531, 237532, 237544, 237548, 237555, 237556, 237557, 237564, 237734, 237735, 237740, 242400, 242403, 242406, 243365 },
        [16] = { 237531, 237532, 237544, 237548, 237555, 237556, 237557, 237564, 237734, 237735, 237740, 242400, 242403, 242406, 243365 },
        [17] = { 237531, 237532, 237544, 237548, 237555, 237556, 237557, 237564, 237734, 237735, 237740, 242400, 242403, 242406, 243365 },
        [15] = { 237531, 237532, 237544, 237548, 237555, 237556, 237557, 237564, 237734, 237735, 237740, 242400, 242403, 242406, 243365 },
      } },
      { --[[name = "Dimensius der alles Verschlingende",]] npcId = 0, bossId = 2691, lootTable = {
        [14] = { 237535, 237537, 237540, 237542, 237559, 237560, 237562, 237563, 237602, 237725, 237731, 242399, 242404, 242405, 246565 },
        [16] = { 237535, 237537, 237540, 237542, 237559, 237560, 237562, 237563, 237602, 237725, 237731, 242399, 242404, 242405, 243061, 246565 },
        [17] = { 237535, 237537, 237540, 237542, 237559, 237560, 237562, 237563, 237602, 237725, 237731, 242399, 242404, 242405, 246565 },
        [15] = { 237535, 237537, 237540, 237542, 237559, 237560, 237562, 237563, 237602, 237725, 237731, 242399, 242404, 242405, 246565 },
      } },
      { --[[name = "Fraktillus",]] npcId = 0, bossId = 2747, lootTable = {
        [14] = { 237530, 237536, 237558, 237565, 237581, 237582, 237583, 237584, 237728, 237733, 237742, 242392, 242396 },
        [16] = { 237530, 237536, 237558, 237565, 237581, 237582, 237583, 237584, 237728, 237733, 237742, 242392, 242396 },
        [17] = { 237530, 237536, 237558, 237565, 237581, 237582, 237583, 237584, 237728, 237733, 237742, 242392, 242396 },
        [15] = { 237530, 237536, 237558, 237565, 237581, 237582, 237583, 237584, 237728, 237733, 237742, 242392, 242396 },
      } },
    } }
  }
};

function KeystoneLoot:GetRaidList()
	return _raidList[self:GetSeasonId()] or {};
end

function KeystoneLoot:GetRaidBossItemList(bossId)
	local slotId = KeystoneLootCharDB.selectedSlotId;
	local classId = KeystoneLootCharDB.selectedClassId;
	local specId = KeystoneLootCharDB.selectedSpecId;
	local difficultyId = KeystoneLoot:GetRaidDifficultyId();
	local _itemList = {};

	for _, raidInfo in next, self:GetRaidList() do
		for _, bossInfo in next, raidInfo.bossList do
			if (bossInfo.bossId == bossId) then
				for _, itemId in next, bossInfo.lootTable[difficultyId] or {} do
					local itemInfo = self:GetItemInfo(itemId);

					if (itemInfo and itemInfo.classes[classId] and itemInfo.slotId == slotId) then
						for _, itemSpecId in next, itemInfo.classes[classId] do
							if (itemSpecId == specId) then
								table.insert(_itemList, {
									itemId = itemId,
									icon = itemInfo.icon
								});
							end
						end
					end
				end
				break;
			end
		end
	end

	return _itemList;
end

function KeystoneLoot:HasRaidSlotItems(journalInstanceId, slotId)
	local selectedClassId = KeystoneLootCharDB.selectedClassId;
	local selectedSpecId = KeystoneLootCharDB.selectedSpecId;
	local difficultyId = KeystoneLoot:GetRaidDifficultyId();

	for _, raidInfo in next, self:GetRaidList() do
		if (raidInfo.journalInstanceId == journalInstanceId) then
			for _, bossInfo in next, raidInfo.bossList do
				for _, itemId in next, bossInfo.lootTable[difficultyId] or {} do
					local itemInfo = self:GetItemInfo(itemId);
					if (itemInfo and itemInfo.classes[selectedClassId] and itemInfo.slotId == slotId) then
						for _, itemSpecId in next, itemInfo.classes[selectedClassId] do
							if (itemSpecId == selectedSpecId) then
								return true;
							end
						end
					end
				end
			end
			break;
		end
	end

	return false;
end


local _itemlevels = {
	[15] = {
		{ id = 'veteran', text = 'Raid Finder', difficultyId = DifficultyUtil.ID.PrimaryRaidLFR, entries = {
			{ itemLevel = 671, bonusId = 12283, text = ITEM_POOR_COLOR_CODE..'671|r | '..BOSS..' 1-3' },
			{ itemLevel = 675, bonusId = 12284, text = ITEM_POOR_COLOR_CODE..'675|r | '..BOSS..' 4-6' },
			{ itemLevel = 678, bonusId = 12285, text = ITEM_POOR_COLOR_CODE..'678|r | '..BOSS..' 7-8' },
			{ itemLevel = 681, bonusId = 12286, text = ITEM_GOOD_COLOR_CODE..'681|r | '..ITEM_UPGRADE },
			{ itemLevel = 684, bonusId = 12287, text = ITEM_GOOD_COLOR_CODE..'684|r | '..ITEM_UPGRADE },
			{ itemLevel = 688, bonusId = 12288, text = ITEM_GOOD_COLOR_CODE..'688|r | '..ITEM_UPGRADE },
			{ itemLevel = 691, bonusId = 12289, text = ITEM_GOOD_COLOR_CODE..'691|r | '..ITEM_UPGRADE }
		} },
		{ id = 'champion', text = 'Normal', difficultyId = DifficultyUtil.ID.PrimaryRaidNormal, entries = {
			{ itemLevel = 684, bonusId = 12291, text = ITEM_GOOD_COLOR_CODE..'684|r | '..BOSS..' 1-3' },
			{ itemLevel = 688, bonusId = 12292, text = ITEM_GOOD_COLOR_CODE..'688|r | '..BOSS..' 4-6' },
			{ itemLevel = 691, bonusId = 12293, text = ITEM_GOOD_COLOR_CODE..'691|r | '..BOSS..' 7-8' },
			{ itemLevel = 694, bonusId = 12294, text = ITEM_SUPERIOR_COLOR_CODE..'694|r | '..ITEM_UPGRADE },
			{ itemLevel = 697, bonusId = 12295, text = ITEM_SUPERIOR_COLOR_CODE..'697|r | '..ITEM_UPGRADE },
			{ itemLevel = 701, bonusId = 12296, text = ITEM_SUPERIOR_COLOR_CODE..'701|r | '..ITEM_UPGRADE },
			{ itemLevel = 704, bonusId = 12297, text = ITEM_SUPERIOR_COLOR_CODE..'704|r | '..ITEM_UPGRADE }
		} },
		{ id = 'hero', text = 'Heroic', difficultyId = DifficultyUtil.ID.PrimaryRaidHeroic, entries = {
			{ itemLevel = 697, bonusId = 12351, text = ITEM_SUPERIOR_COLOR_CODE..'697|r | '..BOSS..' 1-3' },
			{ itemLevel = 701, bonusId = 12352, text = ITEM_SUPERIOR_COLOR_CODE..'701|r | '..BOSS..' 4-6' },
			{ itemLevel = 704, bonusId = 12353, text = ITEM_SUPERIOR_COLOR_CODE..'704|r | '..BOSS..' 7-8' },
			{ itemLevel = 707, bonusId = 12354, text = ITEM_EPIC_COLOR_CODE..'707|r | '..ITEM_UPGRADE },
			{ itemLevel = 710, bonusId = 12355, text = ITEM_EPIC_COLOR_CODE..'710|r | '..ITEM_UPGRADE }
		} },
		{ id = 'myth', text = 'Mythic', difficultyId = DifficultyUtil.ID.PrimaryRaidMythic, entries = {
			{ itemLevel = 710, bonusId = 12357, text = ITEM_EPIC_COLOR_CODE..'710|r | '..BOSS..' 1-3' },
			{ itemLevel = 714, bonusId = 12358, text = ITEM_EPIC_COLOR_CODE..'714|r | '..BOSS..' 4-6' },
			{ itemLevel = 717, bonusId = 12359, text = ITEM_EPIC_COLOR_CODE..'717|r | '..BOSS..' 7-8' },
			{ itemLevel = 720, bonusId = 12360, text = ITEM_LEGENDARY_COLOR_CODE..'720|r | '..ITEM_UPGRADE },
			{ itemLevel = 723, bonusId = 12361, text = ITEM_LEGENDARY_COLOR_CODE..'723|r | '..ITEM_UPGRADE }
		} }
	}
};

function KeystoneLoot:GetRaidItemLevels()
	return _itemlevels[self:GetSeasonId()] or {};
end


function KeystoneLoot:GetRaidDifficultyId()
	local selectedCategoryId = ('-'):split(KeystoneLootCharDB.selectedRaidItemLevel);
	local _itemLevels = self:GetRaidItemLevels();

	if (#_itemLevels > 0 and selectedCategoryId == '0') then
		selectedCategoryId = _itemLevels[1].id;
	end

	for index, category in next, _itemLevels do
		if (selectedCategoryId == category.id) then
			return category.difficultyId;
		end
	end

	return 0;
end

function KeystoneLoot:GetRaidBossId(npcId)
	for _, raidInfo in next, self:GetRaidList() do
		for _, bossInfo in next, raidInfo.bossList do
			local npcIds = bossInfo.npcId;
			if (type(npcIds) ~= 'table') then
				npcIds = { npcIds };
			end

			for _, id in next, npcIds do
				if (id == npcId) then
					return bossInfo.bossId;
				end
			end
		end
	end

	return 0;
end