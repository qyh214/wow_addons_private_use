local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;

local dbVersion = 6;
local dbCharacterVersion = 3;


local function RemoveOldSeason()
	local currentSeasonDB = KeystoneLootCharDB.currentSeason;
	local currentSeason = KeystoneLoot:GetSeasonId();

	if (currentSeason ~= currentSeasonDB) then
		wipe(KeystoneLootCharDB.favoriteLoot);

		KeystoneLootCharDB.currentSeason = currentSeason;
	end
end


function KeystoneLoot:CheckDB()
	if (KeystoneLootDB == nil or KeystoneLootDB.dbVersion == nil) then
		KeystoneLootDB = {
			dbVersion = 0
		};
	end

	if (dbVersion > KeystoneLootDB.dbVersion) then
		if (KeystoneLootDB.dbVersion == 0) then
			KeystoneLootDB.minimapButtonEnabled = true;
			KeystoneLootDB.minimapButtonPosition = 195;
			KeystoneLootDB.lootReminderEnabled = true;
			KeystoneLootDB.showNewText = false;
			KeystoneLootDB.favoritesShowAllSpecs = false;
		elseif (KeystoneLootDB.dbVersion == 1) then
			KeystoneLootDB.showNewText = true;
		elseif (KeystoneLootDB.dbVersion == 2) then
			KeystoneLootDB.showNewText = true;
			KeystoneLootDB.raidLootReminderEnabled = true;
		elseif (KeystoneLootDB.dbVersion == 3) then
			KeystoneLootDB.showNewText = true;
			KeystoneLootDB.keystoneItemLevelEnabled = true;
		elseif (KeystoneLootDB.dbVersion == 4) then
			KeystoneLootDB.showNewText = true;
		elseif (KeystoneLootDB.dbVersion == 5) then
			KeystoneLootDB.showNewText = true;
		end

		KeystoneLootDB.dbVersion = KeystoneLootDB.dbVersion + 1;
		self:CheckDB();
	end
end

function KeystoneLoot:CheckCharacterDB()
	if (KeystoneLootCharDB == nil or KeystoneLootCharDB.dbVersion == nil) then
		KeystoneLootCharDB = {
			dbVersion = 0
		};
	end

	if (dbCharacterVersion > KeystoneLootCharDB.dbVersion) then
		if (KeystoneLootCharDB.dbVersion == 0) then
			KeystoneLootCharDB.currentSeason = self:GetSeasonId();
			KeystoneLootCharDB.selectedSlotId = 0;
			KeystoneLootCharDB.selectedClassId = select(3, UnitClass('player'));
			KeystoneLootCharDB.selectedSpecId = (GetSpecializationInfo(GetSpecialization() or 1)) or 0;
			KeystoneLootCharDB.selectedDungeonItemLevel = 0;
			KeystoneLootCharDB.favoriteLoot = {};
		elseif (KeystoneLootCharDB.dbVersion == 1) then
			KeystoneLootCharDB.selectedRaidItemLevel = 0;
		elseif (KeystoneLootCharDB.dbVersion == 2) then
			KeystoneLootCharDB.statHighlightingCritEnabled = true;
			KeystoneLootCharDB.statHighlightingHasteEnabled = true;
			KeystoneLootCharDB.statHighlightingMasteryEnabled = true;
			KeystoneLootCharDB.statHighlightingVersatilityEnabled = true;
			KeystoneLootCharDB.statHighlightingNoStatsEnabled = true;
		end

		KeystoneLootCharDB.dbVersion = KeystoneLootCharDB.dbVersion + 1;
		self:CheckCharacterDB();
		return;
	end

	RemoveOldSeason();
end

function KeystoneLoot:GetFavoriteItemList(challengeModeId)
	local _, _, playerClassId = UnitClass('player');
	local specId = KeystoneLootCharDB.selectedSpecId;
	local classId = KeystoneLootCharDB.selectedClassId;
	local favoriteLoot = KeystoneLootCharDB.favoriteLoot;
	local _itemList = {};

	if (favoriteLoot[challengeModeId] == nil) then
		return _itemList;
	end

	if (playerClassId == classId and KeystoneLootDB.favoritesShowAllSpecs) then
		local _tmp = {};

		for specId, specList in next, favoriteLoot[challengeModeId] do
			for itemId, itemInfo in next, specList do
				if (challengeModeId == 'catalyst' or KeystoneLoot:GetItemInfo(itemId)) then
					_tmp[itemId] = {
						itemId = itemId,
						specId = specId,
						icon = itemInfo.icon
					};
				end
			end
		end

		for _, itemInfo in next, _tmp do
			table.insert(_itemList, itemInfo);
		end
	elseif (favoriteLoot[challengeModeId][specId]) then
		for itemId, itemInfo in next, favoriteLoot[challengeModeId][specId] do
			if (challengeModeId == 'catalyst' or KeystoneLoot:GetItemInfo(itemId)) then
				table.insert(_itemList, {
					itemId = itemId,
					icon = itemInfo.icon
				});
			end
		end
	end

	return _itemList;
end

function KeystoneLoot:IsFavoriteItem(itemId, overrideSpecId)
	local specId = overrideSpecId or KeystoneLootCharDB.selectedSpecId;
	local favoriteLoot = KeystoneLootCharDB.favoriteLoot;

	for _, specList in next, favoriteLoot do
		if (specList[specId] and specList[specId][itemId]) then
			return true;
		end
	end
end

function KeystoneLoot:AddFavoriteItem(challengeModeId, specId, itemId, icon)
	local favoriteLoot = KeystoneLootCharDB.favoriteLoot;

	if (favoriteLoot[challengeModeId] == nil) then
		favoriteLoot[challengeModeId] = {};
	end

	if (favoriteLoot[challengeModeId][specId] == nil) then
		favoriteLoot[challengeModeId][specId] = {};
	end

	favoriteLoot[challengeModeId][specId][itemId] = {
		icon = icon
	};
end

function KeystoneLoot:RemoveFavoriteItem(itemId, specId)
	local favoriteLoot = KeystoneLootCharDB.favoriteLoot;

	if (specId == nil) then
		for _, specList in next, favoriteLoot do
			for _, itemList in next, specList do
				if (itemList[itemId]) then
					itemList[itemId] = nil;
				end
			end
		end
	else
		for _, specList in next, favoriteLoot do
			if (specList[specId] and specList[specId][itemId]) then
				specList[specId][itemId] = nil;
				break;
			end
		end
	end
end

function KeystoneLoot:ExportFavorites()
	local exportTable = {}
	local exportStr = 'KeystoneLoot:v1';

	for _, specTable in pairs(KeystoneLootCharDB.favoriteLoot) do
		for specId, itemTable in pairs(specTable) do
			if (not exportTable[specId]) then
				exportTable[specId] = {};
			end

			for itemId, _ in pairs(itemTable) do
				table.insert(exportTable[specId], itemId);
			end
		end
	end

	for specId, itemList in pairs(exportTable) do
		local numItemList = #itemList;

		if (numItemList > 0) then
			exportStr = exportStr .. ',' .. specId .. ':';

			for i, itemId in ipairs(itemList) do
				exportStr = exportStr .. itemId;
				if (i < numItemList) then
					exportStr = exportStr .. ':';
				end
			end
		end
	end

	return exportStr;
end

local function IsItemValid(specId, itemId)
	local _, _, classId = UnitClass('player');

	local catalystItems = KeystoneLoot:GetCatalystItems();
	if (catalystItems[itemId] and catalystItems[itemId].classId == classId) then
		return true;
	end

	local itemInfo = KeystoneLoot:GetItemInfo(itemId);
	if (itemInfo and itemInfo.classes[classId]) then
		for _, itemSpecId in pairs(itemInfo.classes[classId]) do
			if (specId == itemSpecId) then
				return true;
			end
		end
	end
end

function KeystoneLoot:ImportFavorites(importStr, overwrite)
	if (not importStr:match('^KeystoneLoot:v1')) then
		print(RED_FONT_COLOR:WrapTextInColorCode(Translate['Invalid import string.']));
		return;
	end

	local dataStr = importStr:gsub('%s+', ''):gsub('^KeystoneLoot:v1,', '');
	local importedItems = {};
	local hasImport = false;
	local totalImported = 0;

	for specSection in dataStr:gmatch('([^,]+)') do
		local specId, itemsStr = specSection:match('^(%d+):(.+)$');

		if (specId and itemsStr) then
			specId = tonumber(specId);
			if (not importedItems[specId]) then
				importedItems[specId] = {};
			end

			for itemId in itemsStr:gmatch('([^:]+)') do
				itemId = tonumber(itemId);
				if (itemId) then
					table.insert(importedItems[specId], itemId);
					hasImport = true;
				end
			end
		end
	end

	if (hasImport) then
		if (overwrite) then
			KeystoneLootCharDB.favoriteLoot = {}
		end

		for specId, itemList in pairs(importedItems) do
			for _, itemId in ipairs(itemList) do
				local sourceId = self:GetItemSource(itemId);

				if (sourceId and IsItemValid(specId, itemId)) then
					totalImported = totalImported + 1;

					local icon = (self:GetCatalystItems()[itemId] or self:GetItemInfo(itemId)).icon;
					self:AddFavoriteItem(sourceId, specId, itemId, icon);
				end
			end
		end

		if (totalImported > 0) then
			self:GetCurrentTab():Update();
			print((YELLOW_FONT_COLOR:WrapTextInColorCode(Translate['Successfully imported %d |4item:items;.'])):format(totalImported));
			return;
		end
	end

	print(RED_FONT_COLOR:WrapTextInColorCode(Translate['Invalid import string.']));
end
