local AddonName, KeystoneLoot = ...;

local _items = {
	[13] = {
		[212065] = { classId = 12, icon = 5426092, slotId = 0 },
		[212081] = { classId = 5, icon = 5490405, slotId = 2 },
		[212002] = { classId = 6, icon = 5758041, slotId = 0 },
		[212018] = { classId = 3, icon = 5832954, slotId = 2 },
		[212050] = { classId = 10, icon = 5517869, slotId = 4 },
		[212066] = { classId = 12, icon = 5426091, slotId = 6 },
		[212082] = { classId = 5, icon = 5490403, slotId = 8 },
		[211987] = { classId = 1, icon = 5661391, slotId = 4 },
		[212003] = { classId = 6, icon = 5758040, slotId = 6 },
		[212019] = { classId = 3, icon = 5832953, slotId = 8 },
		[212083] = { classId = 5, icon = 5490402, slotId = 0 },
		[212020] = { classId = 3, icon = 5832952, slotId = 0 },
		[212036] = { classId = 4, icon = 5771691, slotId = 2 },
		[212068] = { classId = 12, icon = 5426090, slotId = 4 },
		[212084] = { classId = 5, icon = 5490401, slotId = 6 },
		[212005] = { classId = 6, icon = 5758039, slotId = 4 },
		[212021] = { classId = 3, icon = 5832951, slotId = 6 },
		[212037] = { classId = 4, icon = 5771690, slotId = 8 },
		[212038] = { classId = 4, icon = 5771689, slotId = 0 },
		[212054] = { classId = 11, icon = 5771896, slotId = 2 },
		[212086] = { classId = 5, icon = 5490400, slotId = 4 },
		[211991] = { classId = 2, icon = 5567640, slotId = 2 },
		[212023] = { classId = 3, icon = 5832950, slotId = 4 },
		[212039] = { classId = 4, icon = 5771688, slotId = 6 },
		[212055] = { classId = 11, icon = 5771894, slotId = 8 },
		[211992] = { classId = 2, icon = 5567639, slotId = 8 },
		[212056] = { classId = 11, icon = 5771893, slotId = 0 },
		[212072] = { classId = 9, icon = 5870623, slotId = 2 },
		[211993] = { classId = 2, icon = 5567638, slotId = 0 },
		[212009] = { classId = 7, icon = 5871930, slotId = 2 },
		[212041] = { classId = 4, icon = 5771687, slotId = 4 },
		[212057] = { classId = 11, icon = 5771892, slotId = 6 },
		[212073] = { classId = 9, icon = 5870620, slotId = 8 },
		[211994] = { classId = 2, icon = 5567636, slotId = 6 },
		[212010] = { classId = 7, icon = 5871939, slotId = 8 },
		[212074] = { classId = 9, icon = 5870615, slotId = 0 },
		[212090] = { classId = 8, icon = 5890659, slotId = 2 },
		[212011] = { classId = 7, icon = 5871937, slotId = 0 },
		[212027] = { classId = 13, icon = 5636573, slotId = 2 },
		[212059] = { classId = 11, icon = 5771891, slotId = 4 },
		[212075] = { classId = 9, icon = 5870613, slotId = 6 },
		[212091] = { classId = 8, icon = 5890658, slotId = 8 },
		[211996] = { classId = 2, icon = 5567635, slotId = 4 },
		[212012] = { classId = 7, icon = 5871936, slotId = 6 },
		[212028] = { classId = 13, icon = 5636572, slotId = 8 },
		[212092] = { classId = 8, icon = 5890657, slotId = 0 },
		[212029] = { classId = 13, icon = 5636571, slotId = 0 },
		[212045] = { classId = 10, icon = 5517873, slotId = 2 },
		[212077] = { classId = 9, icon = 5870622, slotId = 4 },
		[212093] = { classId = 8, icon = 5890656, slotId = 6 },
		[211982] = { classId = 1, icon = 5661395, slotId = 2 },
		[212014] = { classId = 7, icon = 5871935, slotId = 4 },
		[212030] = { classId = 13, icon = 5636570, slotId = 6 },
		[212046] = { classId = 10, icon = 5517872, slotId = 8 },
		[211983] = { classId = 1, icon = 5661394, slotId = 8 },
		[212047] = { classId = 10, icon = 5517871, slotId = 0 },
		[212063] = { classId = 12, icon = 5426094, slotId = 2 },
		[212095] = { classId = 8, icon = 5890655, slotId = 4 },
		[211984] = { classId = 1, icon = 5661393, slotId = 0 },
		[212000] = { classId = 6, icon = 5758043, slotId = 2 },
		[212032] = { classId = 13, icon = 5636569, slotId = 4 },
		[212048] = { classId = 10, icon = 5517870, slotId = 6 },
		[212064] = { classId = 12, icon = 5426093, slotId = 8 },
		[211985] = { classId = 1, icon = 5661392, slotId = 6 },
		[212001] = { classId = 6, icon = 5758042, slotId = 8 }
	}
};

local function GetCatalystItems()
	return _items[KeystoneLoot:GetSeasonId()] or {};
end

function KeystoneLoot:GetCatalystItemList()
	local classId = KeystoneLootCharDB.selectedClassId;
	local slotId = KeystoneLootCharDB.selectedSlotId;
	local _itemList = {};

	for itemId, itemInfo in next, GetCatalystItems() do
		if (itemInfo.classId == classId and itemInfo.slotId == slotId) then
			table.insert(_itemList, {
				itemId = itemId,
				icon = itemInfo.icon
			});
		end
	end

	return _itemList;
end

