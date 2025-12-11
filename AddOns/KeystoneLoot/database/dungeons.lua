local AddonName, KeystoneLoot = ...;

-- Generated automatically by KeystoneLoot Updater v2.0
-- Timestamp: 2025-08-06 14:53:19
-- WoW Build: 11.2.0 (62417)
-- Season: 15
-- WARNING: This file is auto-generated - manual changes will be overwritten!

local _dungeonList = {
  [15] = {
    { --[[name = "Hallen der Sühne",]] challengeModeId = 378, teleportSpellId = 354465, bgTexture = 3759908, lootTable = { 178812, 178814, 178815, 178816, 178818, 178819, 178821, 178822, 178823, 178824, 178826, 178827, 178829, 178830, 178831, 178832, 178833, 178834, 246273, 246276, 246284, 246286, 246344 } },
    { --[[name = "Tazavesh: Wundersame Straßen",]] challengeModeId = 391, teleportSpellId = 367416, bgTexture = 4182022, lootTable = { 185777, 185778, 185780, 185782, 185783, 185786, 185787, 185789, 185791, 185792, 185793, 185798, 185802, 185804, 185807, 185808, 185809, 185811, 185812, 185814, 185815, 185816, 185817, 185821, 185824, 185836, 185842, 185845, 185846, 186534, 190652, 246281, 246282, 246285, 246287 } },
    { --[[name = "Tazavesh: So'leahs Schachzug",]] challengeModeId = 392, teleportSpellId = 367416, bgTexture = 4182022, lootTable = { 185779, 185795, 185796, 185797, 185799, 185801, 185803, 185805, 185810, 185813, 185819, 185820, 185822, 185823, 185841, 186638, 190958, 246275, 246280, 246283 } },
    { --[[name = "Priorat der Heiligen Flamme",]] challengeModeId = 499, teleportSpellId = 445444, bgTexture = 5912551, lootTable = { 219308, 219309, 219310, 221117, 221118, 221119, 221120, 221121, 221122, 221123, 221124, 221125, 221126, 221127, 221128, 221129, 221130, 221131, 221200, 221203, 252009 } },
    { --[[name = "Ara-Kara, Stadt der Echos",]] challengeModeId = 503, teleportSpellId = 445417, bgTexture = 5912546, lootTable = { 219314, 219316, 219317, 221150, 221151, 221152, 221153, 221155, 221156, 221157, 221158, 221159, 221161, 221162, 221163, 221164, 221165 } },
    { --[[name = "Die Morgenbringer",]] challengeModeId = 505, teleportSpellId = 445414, bgTexture = 5912552, lootTable = { 219311, 219312, 219313, 221132, 221133, 221134, 221135, 221136, 221137, 221138, 221139, 221140, 221141, 221142, 221143, 221144, 221145, 221146, 221147, 221148, 221149, 221202 } },
    { --[[name = "Operation: Schleuse",]] challengeModeId = 525, teleportSpellId = 1216786, bgTexture = 6422412, lootTable = { 232541, 232542, 232543, 232545, 234490, 234491, 234492, 234493, 234494, 234495, 234496, 234497, 234498, 234499, 234500, 234501, 234502, 234503, 234504, 234505, 234506, 236768, 246274, 246277, 246278, 246279, 251880 } },
    { --[[name = "Biokuppel Al'dani",]] challengeModeId = 542, teleportSpellId = 1237215, bgTexture = 7074042, lootTable = { 242464, 242468, 242470, 242472, 242473, 242475, 242476, 242477, 242479, 242481, 242482, 242483, 242484, 242486, 242487, 242488, 242490, 242491, 242493, 242494, 242495, 242497 } },
  }
};

function KeystoneLoot:GetDungeonList()
	return _dungeonList[self:GetSeasonId()] or {};
end

function KeystoneLoot:GetDungeonItemList(challengeModeId)
	local slotId = KeystoneLootCharDB.selectedSlotId;
	local classId = KeystoneLootCharDB.selectedClassId;
	local specId = KeystoneLootCharDB.selectedSpecId;
	local _itemList = {};

	for _, dungeonInfo in next, self:GetDungeonList() do
		if (dungeonInfo.challengeModeId == challengeModeId) then
			for _, itemId in next, dungeonInfo.lootTable do
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

	return _itemList;
end

function KeystoneLoot:HasDungeonSlotItems(slotId)
	local classId = KeystoneLootCharDB.selectedClassId;
	local specId = KeystoneLootCharDB.selectedSpecId;

	for _, dungeonInfo in next, self:GetDungeonList() do
		for _, itemId in next, dungeonInfo.lootTable do
			local itemInfo = self:GetItemInfo(itemId);
			if (itemInfo and itemInfo.classes[classId] and itemInfo.slotId == slotId) then
				for _, itemSpecId in next, itemInfo.classes[classId] do
					if (itemSpecId == specId) then
						return true;
					end
				end
			end
		end
	end

	return false;
end


local _keystoneItemLevel = {
	[15] = {
		[2] = { endOfRun = { level = 684, text = 'Champion' }, greatVault = { level = 694, text = 'Hero' } },
		[3] = { endOfRun = { level = 684, text = 'Champion' }, greatVault = { level = 694, text = 'Hero' } },
		[4] = { endOfRun = { level = 688, text = 'Champion' }, greatVault = { level = 697, text = 'Hero' } },
		[5] = { endOfRun = { level = 691, text = 'Champion' }, greatVault = { level = 697, text = 'Hero' } },
		[6] = { endOfRun = { level = 694, text = 'Hero' }, greatVault = { level = 701, text = 'Hero' } },
		[7] = { endOfRun = { level = 694, text = 'Hero' }, greatVault = { level = 704, text = 'Hero' } },
		[8] = { endOfRun = { level = 697, text = 'Hero' }, greatVault = { level = 704, text = 'Hero' } },
		[9] = { endOfRun = { level = 697, text = 'Hero' }, greatVault = { level = 704, text = 'Hero' } },
		[10] = { endOfRun = { level = 701, text = 'Hero' }, greatVault = { level = 707, text = 'Myth' } }
	}
};

function KeystoneLoot:GetKeystoneItemLevels(keystoneLevel)
	keystoneLevel = tonumber(keystoneLevel) or 0;
	if (keystoneLevel > 10) then
		keystoneLevel = 10;
	end

	return _keystoneItemLevel[self:GetSeasonId()][keystoneLevel];
end


local _itemlevels = {
	[15] = {
		{ id = 'champion', text = 'Champion', entries = {
			{ itemLevel = 681, bonusId = 12290, text = ITEM_GOOD_COLOR_CODE..'681|r | +0' },
			{ itemLevel = 684, bonusId = 12291, text = ITEM_GOOD_COLOR_CODE..'684|r | +2 +3' },
			{ itemLevel = 688, bonusId = 12292, text = ITEM_GOOD_COLOR_CODE..'688|r | +4' },
			{ itemLevel = 691, bonusId = 12293, text = ITEM_GOOD_COLOR_CODE..'691|r | +5' },
			{ itemLevel = 694, bonusId = 12294, text = ITEM_SUPERIOR_COLOR_CODE..'694|r | '..ITEM_UPGRADE },
			{ itemLevel = 697, bonusId = 12295, text = ITEM_SUPERIOR_COLOR_CODE..'697|r | '..ITEM_UPGRADE },
			{ itemLevel = 701, bonusId = 12296, text = ITEM_SUPERIOR_COLOR_CODE..'701|r | '..ITEM_UPGRADE },
			{ itemLevel = 704, bonusId = 12297, text = ITEM_SUPERIOR_COLOR_CODE..'704|r | '..ITEM_UPGRADE }
		} },
		{ id = 'hero', text = 'Hero', entries = {
			{ itemLevel = 694, bonusId = 12350, text = ITEM_SUPERIOR_COLOR_CODE..'694|r | +6 +7' },
			{ itemLevel = 697, bonusId = 12351, text = ITEM_SUPERIOR_COLOR_CODE..'697|r | +8 +9' },
			{ itemLevel = 701, bonusId = 12352, text = ITEM_SUPERIOR_COLOR_CODE..'701|r | +10' },
			{ itemLevel = 704, bonusId = 12353, text = ITEM_SUPERIOR_COLOR_CODE..'704|r | '..ITEM_UPGRADE },
			{ itemLevel = 707, bonusId = 12354, text = ITEM_EPIC_COLOR_CODE..'707|r | '..ITEM_UPGRADE },
			{ itemLevel = 710, bonusId = 12355, text = ITEM_EPIC_COLOR_CODE..'710|r | '..ITEM_UPGRADE },
			{ itemLevel = 714, bonusId = 13443, text = ITEM_EPIC_COLOR_CODE..'714|r | '..ITEM_UPGRADE },
			{ itemLevel = 717, bonusId = 13444, text = ITEM_EPIC_COLOR_CODE..'717|r | '..ITEM_UPGRADE }
		} },
		{ id = 'myth', text = 'Great Vault', entries = {
			{ itemLevel = 707, bonusId = 12356, text = ITEM_EPIC_COLOR_CODE..'707|r | +10' },
			{ itemLevel = 710, bonusId = 12357, text = ITEM_EPIC_COLOR_CODE..'710|r | '..ITEM_UPGRADE },
			{ itemLevel = 714, bonusId = 12358, text = ITEM_EPIC_COLOR_CODE..'714|r | '..ITEM_UPGRADE },
			{ itemLevel = 717, bonusId = 12359, text = ITEM_EPIC_COLOR_CODE..'717|r | '..ITEM_UPGRADE },
			{ itemLevel = 720, bonusId = 12360, text = ITEM_LEGENDARY_COLOR_CODE..'720|r | '..ITEM_UPGRADE },
			{ itemLevel = 723, bonusId = 12361, text = ITEM_LEGENDARY_COLOR_CODE..'723|r | '..ITEM_UPGRADE },
			{ itemLevel = 727, bonusId = 13445, text = ITEM_LEGENDARY_COLOR_CODE..'727|r | '..ITEM_UPGRADE },
			{ itemLevel = 730, bonusId = 13446, text = ITEM_LEGENDARY_COLOR_CODE..'730|r | '..ITEM_UPGRADE }
		} }
	}
};

function KeystoneLoot:GetDungeonItemLevels()
	return _itemlevels[self:GetSeasonId()] or {};
end