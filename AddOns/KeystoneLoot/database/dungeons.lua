local AddonName, KeystoneLoot = ...;

local _dungeonList = {
	[14] = {
		{ --[[name = "Operation: Schleuse",]] challengeModeId = 525, teleportSpellId = 1216786, bgTexture = 6422412, lootTable = { 234490, 234494, 234498, 234502, 234506, 234491, 232542, 234499, 234503, 234507, 234492, 232543, 234500, 234504, 232545, 234496, 234495, 234493, 234497, 234501, 236768, 232541, 234505 } },
		{ --[[name = "Metbrauerei Glutbräu",]] challengeModeId = 506, teleportSpellId = 445440, bgTexture = 5912547, lootTable = { 221059, 221063, 221067, 221071, 221052, 221056, 221060, 219297, 221068, 221072, 221053, 221057, 221061, 221065, 221069, 221201, 221054, 221058, 221062, 219299, 221070, 221198, 221064, 221051, 221055, 219298 } },
		{ --[[name = "Die Brutstätte",]] challengeModeId = 500, teleportSpellId = 445443, bgTexture = 5912553, lootTable = { 219296, 221036, 221040, 221044, 221048, 221033, 221037, 221041, 221045, 221049, 219294, 221034, 221038, 221197, 221046, 221050, 219295, 221035, 221039, 221043, 221047, 221032, 221042 } },
		{ --[[name = "Dunkelflammenspalt",]] challengeModeId = 504, teleportSpellId = 445441, bgTexture = 5912549, lootTable = { 221098, 219304, 221106, 221110, 221114, 221099, 221103, 221107, 221111, 225548, 221096, 221100, 219306, 221108, 221112, 221102, 221104, 221115, 221097, 221101, 221105, 221109, 221113, 219307, 219305 } },
		{ --[[name = "Priorat der Heiligen Flamme",]] challengeModeId = 499, teleportSpellId = 445444, bgTexture = 5912551, lootTable = { 221121, 221125, 221129, 219308, 221203, 221118, 221122, 221126, 221130, 221200, 221119, 221123, 221127, 221131, 219310, 221116, 221120, 221124, 221128, 221117, 219309 } },
		{ --[[name = "Das RIESENFLÖZ!!",]] challengeModeId = 247, teleportSpellId = (UnitFactionGroup("player") == "Alliance" and 467553 or 467555), bgTexture = 2178274, lootTable = { 159611, 158359, 235416, 159462, 159226, 159612, 159305, 235417, 155864, 159361, 235418, 235419, 159638, 159725, 161135, 235420, 159639, 159663, 235460, 159679, 159451, 158341, 159357, 158357, 159641, 159287, 158350, 159240, 235415, 159235, 159231, 159336, 158353 } },
		{ --[[name = "Mechagon - Werkstatt,]] challengeModeId = 370, teleportSpellId = 373274, bgTexture = 3025325, lootTable = { 168982, 168967, 168975, 168983, 235811, 168976, 169378, 235812, 168985, 235222, 168962, 168978, 168986, 235223, 168955, 168971, 232546, 235224, 168964, 168972, 168980, 199921, 168969, 168988, 235809, 168957, 168965, 168973, 169608, 168989, 168966, 168968, 235226, 168958, 169344, 168974, 235810 } },
		{ --[[name = "Theater der Schmerzen",]] challengeModeId = 382, teleportSpellId = 354467, bgTexture = 3759914, lootTable = { 178806, 178872, 178868, 178801, 178795, 178799, 178865, 178869, 178811, 178804, 178803, 178792, 178796, 178800, 178866, 178808, 178864, 178805, 178789, 178793, 178797, 178863, 178867, 178809, 178810, 178871, 178807, 178794, 178798, 178802, 178870 } },
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
	[14] = {
		[2] = { endOfRun = { level = 639, text = 'Champion' }, greatVault = { level = 649, text = 'Hero' } },
		[3] = { endOfRun = { level = 639, text = 'Champion' }, greatVault = { level = 649, text = 'Hero' } },
		[4] = { endOfRun = { level = 642, text = 'Champion' }, greatVault = { level = 652, text = 'Hero' } },
		[5] = { endOfRun = { level = 645, text = 'Champion' }, greatVault = { level = 652, text = 'Hero' } },
		[6] = { endOfRun = { level = 649, text = 'Hero' }, greatVault = { level = 655, text = 'Hero' } },
		[7] = { endOfRun = { level = 649, text = 'Hero' }, greatVault = { level = 658, text = 'Hero' } },
		[8] = { endOfRun = { level = 652, text = 'Hero' }, greatVault = { level = 658, text = 'Hero' } },
		[9] = { endOfRun = { level = 652, text = 'Hero' }, greatVault = { level = 658, text = 'Hero' } },
		[10] = { endOfRun = { level = 655, text = 'Hero' }, greatVault = { level = 662, text = 'Myth' } }
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
	[14] = {
		{ id = 'champion', text = 'Champion', entries = {
			{ itemLevel = 636, bonusId = 11977, text = ITEM_GOOD_COLOR_CODE..'636|r | +0' },
			{ itemLevel = 639, bonusId = 11978, text = ITEM_GOOD_COLOR_CODE..'639|r | +2 +3' },
			{ itemLevel = 642, bonusId = 11979, text = ITEM_GOOD_COLOR_CODE..'642|r | +4' },
			{ itemLevel = 645, bonusId = 11980, text = ITEM_GOOD_COLOR_CODE..'645|r | +5' },
			{ itemLevel = 649, bonusId = 11981, text = ITEM_SUPERIOR_COLOR_CODE..'649|r | '..ITEM_UPGRADE },
			{ itemLevel = 652, bonusId = 11982, text = ITEM_SUPERIOR_COLOR_CODE..'652|r | '..ITEM_UPGRADE },
			{ itemLevel = 655, bonusId = 11983, text = ITEM_SUPERIOR_COLOR_CODE..'655|r | '..ITEM_UPGRADE },
			{ itemLevel = 658, bonusId = 11984, text = ITEM_SUPERIOR_COLOR_CODE..'658|r | '..ITEM_UPGRADE }
		} },
		{ id = 'hero', text = 'Hero', entries = {
			{ itemLevel = 649, bonusId = 11985, text = ITEM_SUPERIOR_COLOR_CODE..'649|r | +6 +7' },
			{ itemLevel = 652, bonusId = 11986, text = ITEM_SUPERIOR_COLOR_CODE..'652|r | +8 +9' },
			{ itemLevel = 655, bonusId = 11987, text = ITEM_SUPERIOR_COLOR_CODE..'655|r | +10' },
			{ itemLevel = 658, bonusId = 11988, text = ITEM_SUPERIOR_COLOR_CODE..'658|r | '..ITEM_UPGRADE },
			{ itemLevel = 662, bonusId = 11989, text = ITEM_EPIC_COLOR_CODE..'662|r | '..ITEM_UPGRADE },
			{ itemLevel = 665, bonusId = 11990, text = ITEM_EPIC_COLOR_CODE..'665|r | '..ITEM_UPGRADE }
		} },
		{ id = 'myth', text = 'Great Vault', entries = {
			{ itemLevel = 662, bonusId = 11991, text = ITEM_EPIC_COLOR_CODE..'662|r | +10' },
			{ itemLevel = 665, bonusId = 11992, text = ITEM_EPIC_COLOR_CODE..'665|r | '..ITEM_UPGRADE },
			{ itemLevel = 668, bonusId = 11993, text = ITEM_EPIC_COLOR_CODE..'668|r | '..ITEM_UPGRADE },
			{ itemLevel = 672, bonusId = 11994, text = ITEM_EPIC_COLOR_CODE..'672|r | '..ITEM_UPGRADE },
			{ itemLevel = 675, bonusId = 11995, text = ITEM_LEGENDARY_COLOR_CODE..'675|r | '..ITEM_UPGRADE },
			{ itemLevel = 678, bonusId = 11996, text = ITEM_LEGENDARY_COLOR_CODE..'678|r | '..ITEM_UPGRADE }
		} }
	}
};

function KeystoneLoot:GetDungeonItemLevels()
	return _itemlevels[self:GetSeasonId()] or {};
end