local AddonName, KeystoneLoot = ...;

local _dungeonList = {
	[13] = {
		{ --[[name = "Ara-Kara, Stadt der Echos",]] challengeModeId = 503, teleportSpellId = 445417, bgTexture = 5912546, lootTable = { 221152, 221156, 221160, 221164, 219316, 221153, 221157, 221161, 221165, 219317, 221150, 221154, 221158, 221162, 219314, 221151, 221155, 221159, 221163 } },
		{ --[[name = "Das Steingewölbe,]] challengeModeId = 501, teleportSpellId = 445269, bgTexture = 5912554, lootTable = { 221090, 221094, 219300, 221075, 221079, 221083, 221087, 221091, 221095, 219301, 226683, 221076, 221080, 221084, 221088, 221092, 219302, 221073, 221077, 221081, 221085, 221089, 219303, 221074, 221078, 219315, 221086, 221082 } },
		{ --[[name = "Die Morgenbringer",]] challengeModeId = 505, teleportSpellId = 445414, bgTexture = 5912552, lootTable = { 221133, 221137, 221141, 221145, 221149, 221134, 221138, 221142, 221146, 221135, 221139, 221143, 221147, 219313, 221140, 219311, 221132, 221136, 221202, 221144, 221148, 219312 } },
		{ --[[name = "Stadt der Fäden",]] challengeModeId = 502, teleportSpellId = 445416, bgTexture = 5912548, lootTable = { 221183, 221187, 221168, 221172, 221176, 219320, 221184, 221188, 221169, 221173, 221177, 219321, 221185, 221189, 219319, 221166, 221170, 221174, 219318, 221182, 221186, 221180, 221181, 221167, 221171, 221175, 221179, 221178 } },
		{ --[[name = "Die Nebel von Tirna Scithe",]] challengeModeId = 375, teleportSpellId = 354464, bgTexture = 3759909, lootTable = { 178692, 178700, 178708, 182142, 183473, 178693, 178701, 178709, 183253, 181844, 182206, 182384, 178694, 178702, 178710, 183491, 183514, 183485, 183229, 183199, 178695, 178703, 178711, 181466, 182129, 182767, 182964, 181775, 178696, 178704, 178712, 182754, 181734, 183266, 182335, 181539, 178697, 178705, 178713, 182143, 182347, 183336, 182651, 181462, 178698, 183494, 182305, 183132, 180935, 183463, 178714, 178691, 178699, 178707, 178715, 178706, 182448, 182582, 182686 } },
		{ --[[name = "Die Nekrotische Schneise",]] challengeModeId = 376, teleportSpellId = 354462, bgTexture = 3759910, lootTable = { 182646, 182385, 183481, 181641, 182622, 183512, 178732, 183402, 181709, 181843, 183471, 178772, 178780, 183387, 178733, 178741, 178749, 183482, 181600, 181759, 178781, 181700, 178734, 178742, 178750, 182772, 182750, 183373, 178782, 182633, 178735, 178743, 181712, 182960, 183492, 181383, 178783, 183278, 178736, 178744, 181738, 182136, 182111, 183505, 178748, 182201, 178737, 178745, 182295, 181974, 181982, 178777, 178740, 178730, 178738, 182778, 182345, 182321, 178779, 178778, 182440, 178731, 178739, 178751 } },
		{ --[[name = "Die Belagerung von Boralus",]] challengeModeId = 353, teleportSpellId = (UnitFactionGroup("player") == "Alliance" and 445418 or 464256), bgTexture = 2178272, lootTable = { 159973, 231825, 159320, 162541, 159651, 231818, 231826, 231827, 159322, 159968, 159622, 159386, 159969, 159237, 159434, 159379, 159427, 231822, 231830, 159428, 159251, 159650, 159372, 159649, 159972, 159623, 159250, 159429, 231824, 159256, 159309, 159965, 159461 } },
		{ --[[name = "Grim Batol",]] challengeModeId = 507, teleportSpellId = 445424, bgTexture = 522354, lootTable = { 133298, 133302, 133306, 157614, 133283, 133287, 133291, 133295, 133299, 133303, 133354, 157615, 133284, 133288, 133292, 133296, 133300, 133304, 157612, 133374, 133285, 133289, 133293, 133297, 133301, 133305, 157613, 133282, 133286, 133290, 133294, 133363 } },
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
	[13] = {
		[2] = { endOfRun = { level = 597, text = 'Champion' }, greatVault = { level = 606, text = 'Champion' } },
		[3] = { endOfRun = { level = 597, text = 'Champion' }, greatVault = { level = 610, text = 'Hero' } },
		[4] = { endOfRun = { level = 600, text = 'Champion' }, greatVault = { level = 610, text = 'Hero' } },
		[5] = { endOfRun = { level = 603, text = 'Champion' }, greatVault = { level = 613, text = 'Hero' } },
		[6] = { endOfRun = { level = 606, text = 'Champion' }, greatVault = { level = 613, text = 'Hero' } },
		[7] = { endOfRun = { level = 610, text = 'Hero' }, greatVault = { level = 616, text = 'Hero' } },
		[8] = { endOfRun = { level = 610, text = 'Hero' }, greatVault = { level = 619, text = 'Hero' } },
		[9] = { endOfRun = { level = 613, text = 'Hero' }, greatVault = { level = 619, text = 'Hero' } },
		[10] = { endOfRun = { level = 613, text = 'Hero' }, greatVault = { level = 623, text = 'Myth' } }
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
	[13] = {
		{ id = 'champion', text = 'Champion', entries = {
			{ itemLevel = 597, bonusId = 10313, text = ITEM_GOOD_COLOR_CODE..'597|r | +2 +3' },
			{ itemLevel = 600, bonusId = 10314, text = ITEM_GOOD_COLOR_CODE..'600|r | +4' },
			{ itemLevel = 603, bonusId = 10315, text = ITEM_GOOD_COLOR_CODE..'603|r | +5' },
			{ itemLevel = 606, bonusId = 10316, text = ITEM_GOOD_COLOR_CODE..'606|r | +6' },
			{ itemLevel = 610, bonusId = 10317, text = ITEM_SUPERIOR_COLOR_CODE..'610|r | '..ITEM_UPGRADE },
			{ itemLevel = 613, bonusId = 10318, text = ITEM_SUPERIOR_COLOR_CODE..'613|r | '..ITEM_UPGRADE },
			{ itemLevel = 616, bonusId = 10319, text = ITEM_SUPERIOR_COLOR_CODE..'616|r | '..ITEM_UPGRADE },
			{ itemLevel = 619, bonusId = 10320, text = ITEM_SUPERIOR_COLOR_CODE..'619|r | '..ITEM_UPGRADE }
		} },
		{ id = 'hero', text = 'Hero', entries = {
			{ itemLevel = 610, bonusId = 10329, text = ITEM_SUPERIOR_COLOR_CODE..'610|r | +7 +8' },
			{ itemLevel = 613, bonusId = 10330, text = ITEM_SUPERIOR_COLOR_CODE..'613|r | +9 +10' },
			{ itemLevel = 616, bonusId = 10331, text = ITEM_SUPERIOR_COLOR_CODE..'616|r | '..ITEM_UPGRADE },
			{ itemLevel = 619, bonusId = 10332, text = ITEM_SUPERIOR_COLOR_CODE..'619|r | '..ITEM_UPGRADE },
			{ itemLevel = 623, bonusId = 10333, text = ITEM_EPIC_COLOR_CODE..'623|r | '..ITEM_UPGRADE },
			{ itemLevel = 626, bonusId = 10334, text = ITEM_EPIC_COLOR_CODE..'626|r | '..ITEM_UPGRADE }
		} },
		{ id = 'myth', text = 'Great Vault', entries = {
			{ itemLevel = 623, bonusId = 10260, text = ITEM_EPIC_COLOR_CODE..'623|r | +10' },
			{ itemLevel = 626, bonusId = 10259, text = ITEM_EPIC_COLOR_CODE..'626|r | '..ITEM_UPGRADE },
			{ itemLevel = 629, bonusId = 10258, text = ITEM_EPIC_COLOR_CODE..'629|r | '..ITEM_UPGRADE },
			{ itemLevel = 632, bonusId = 10257, text = ITEM_EPIC_COLOR_CODE..'632|r | '..ITEM_UPGRADE },
			{ itemLevel = 636, bonusId = 10298, text = ITEM_LEGENDARY_COLOR_CODE..'636|r | '..ITEM_UPGRADE },
			{ itemLevel = 639, bonusId = 10299, text = ITEM_LEGENDARY_COLOR_CODE..'639|r | '..ITEM_UPGRADE }
		} }
	}
};

function KeystoneLoot:GetDungeonItemLevels()
	return _itemlevels[self:GetSeasonId()] or {};
end