local ADDON_NAME,Internal = ...
local L = Internal.L

local ClearCursor = ClearCursor
local PickupInventoryItem = PickupInventoryItem
local PickupContainerItem = C_Container and C_Container.PickupContainerItem or PickupContainerItem
local GetContainerFreeSlots = C_Container and C_Container.GetContainerFreeSlots or GetContainerFreeSlots
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local GetInventoryItemLink = GetInventoryItemLink
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetVoidItemHyperlinkString = GetVoidItemHyperlinkString
local GetItemUniqueness = GetItemUniqueness
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local GetItemGem = C_Item and C_Item.GetItemGem or GetItemGem
local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo

local HelpTipBox_Anchor = Internal.HelpTipBox_Anchor;
local HelpTipBox_SetText = Internal.HelpTipBox_SetText;

local AddSet = Internal.AddSet

local sort = table.sort
local format = string.format

local GetCharacterSlug = Internal.GetCharacterSlug
local GetCharacterInfo = Internal.GetCharacterInfo

local AddSetToMapData, RemoveSetFromMapData, UpdateSetItemInMapData

local function PackLocation(bag, slot)
	if bag == nil then -- Inventory slot
		if slot >= 52 and slot <= 79 then -- Bank Slot
            return bit.bor(ITEM_INVENTORY_LOCATION_BANK, slot);
		else -- Equipment slot
			return bit.bor(ITEM_INVENTORY_LOCATION_PLAYER, slot);
		end
	else
        if bag == BANK_CONTAINER then
            return bit.bor(ITEM_INVENTORY_LOCATION_BANK, slot + 51); -- Bank slots are stored as inventory slots, and start at 52
        elseif bag >= 0 and bag <= NUM_BAG_SLOTS then
            return bit.bor(ITEM_INVENTORY_LOCATION_PLAYER, ITEM_INVENTORY_LOCATION_BAGS, bit.lshift(bag, ITEM_INVENTORY_BAG_BIT_OFFSET), slot);
        elseif bag >= NUM_BAG_SLOTS+1 and bag <= NUM_BAG_SLOTS+NUM_BANKBAGSLOTS then
            return bit.bor(ITEM_INVENTORY_LOCATION_BANK, ITEM_INVENTORY_LOCATION_BAGS, bit.lshift(bag - ITEM_INVENTORY_BANK_BAG_OFFSET, ITEM_INVENTORY_BAG_BIT_OFFSET), slot);
        end
	end
end
local function LocationIsInventory(location, slot)
	if slot then
		return PackLocation(nil, slot) == location
	else
		return bit.band(ITEM_INVENTORY_LOCATION_PLAYER, location) ~= 0 and bit.band(ITEM_INVENTORY_LOCATION_BAGS, location) == 0
	end
end
local function LocationIsBag(location, bag, slot)
	if bag and slot then
		return PackLocation(bag, slot) == location
	elseif bag then
		local bagmask = PackLocation(bag, 0)
		return bit.band(location, bagmask) == bagmask
	else
		return bit.band(ITEM_INVENTORY_LOCATION_PLAYER, ITEM_INVENTORY_LOCATION_BAG, location) ~= 0 and bit.band(ITEM_INVENTORY_LOCATION_BAGS, location) == 0
	end
end
local function LocationIsBank(location, slot)
	if slot then
		return bit.band(ITEM_INVENTORY_LOCATION_BANK, location) ~= 0 and (location - ITEM_INVENTORY_LOCATION_BANK) == slot
	else
		return bit.band(ITEM_INVENTORY_LOCATION_BANK, location) ~= 0 and bit.band(ITEM_INVENTORY_LOCATION_BAGS, location) == 0
	end
end
local function LocationIsBankBag(location, bag, slot)
	if bag and slot then
		return PackLocation(bag, slot) == location
	elseif bag then
		local bagmask = PackLocation(bag, 0)
		return bit.band(location, bagmask) == bagmask
	else
		return bit.band(ITEM_INVENTORY_LOCATION_BANK, ITEM_INVENTORY_LOCATION_BAG, location) ~= 0 and bit.band(ITEM_INVENTORY_LOCATION_BAGS, location) == 0
	end
end
-- Convert an ItemLocationMixin into a location number
local function GetLocationFromItemLocation(itemLocation)
	if itemLocation:IsEquipmentSlot() then
		return PackLocation(nil, itemLocation:GetEquipmentSlot())
	elseif itemLocation:IsBagAndSlot() then
		return PackLocation(itemLocation:GetBagAndSlot())
	end
end
-- Updated an ItemLocationMixin with location from a numeric location
local function SetItemLocationFromLocation(itemLocation, location)
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
	if not player and not bank and not bags and not voidStorage then
		itemLocation:Clear()
	elseif bags then
		itemLocation:SetBagAndSlot(bag, slot)
	elseif player then
		itemLocation:SetEquipmentSlot(slot)
	elseif bank then
		itemLocation:SetBagAndSlot(BANK_CONTAINER, slot - 51)
	else
		error("@TODO")
	end
	
	return itemLocation
end
local function IsLocationEquipmentSlot(location)
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
	if player and not bags then
		return true
	end
	return false
end


-- Get azerite item data from a location
local function GetAzeriteDataForItemLocation(itemLocation)
	if itemLocation and itemLocation:HasAnyLocation() and itemLocation:IsValid() and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
		local azerite = {};

		local tiers = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation);
		for index,tier in ipairs(tiers) do
			for _,powerID in ipairs(tier.azeritePowerIDs) do
				if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
					azerite[index] = powerID;
					break;
				end
			end
		end

		return "-azerite:" .. #azerite .. ":" .. table.concat(azerite, ":")
	end

	return ""
end
Internal.GetAzeriteDataForItemLocation = GetAzeriteDataForItemLocation
local GetAzeriteDataForLocation
do
	local itemLocation = ItemLocation:CreateEmpty()
	function GetAzeriteDataForLocation(location)
		SetItemLocationFromLocation(itemLocation, location)
		return GetAzeriteDataForItemLocation(itemLocation)
	end
end
local function GetExtrasForItemLocation(itemLocation, extras)
	extras = extras or {}

	if itemLocation and itemLocation:HasAnyLocation() and itemLocation:IsValid() and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
		local azerite = {};

		local tiers = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation);
		for index,tier in ipairs(tiers) do
			for _,powerID in ipairs(tier.azeritePowerIDs) do
				if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
					azerite[index] = powerID;
					break;
				end
			end
		end

		extras.azerite = azerite
	else
		extras.azerite = nil -- Clear azerite data
	end

	return extras
end
local GetExtrasForLocation
do
	local itemLocation = ItemLocation:CreateEmpty()
	function GetExtrasForLocation(location, extras)
		SetItemLocationFromLocation(itemLocation, location)
		return GetExtrasForItemLocation(itemLocation, extras)
	end
end
Internal.GetExtrasForLocation = GetExtrasForLocation

local function GetItemString(itemLink)
	local itemString = string.match(itemLink, "item[%-?%d:]+Player%-[%d]+%-[%dA-F]+[%-?%d:]+")
	if itemString == nil then -- Without GUID match
		itemString = string.match(itemLink, "item[%-?%d:]+")
	end
	return itemString;
end
local function DeEnchantItemLink(itemLink)
	local itemString = GetItemString(itemLink)
	return string.format("%s::::::%s:::%s", string.match(itemString, "^(item:%d+):[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:([^:]*:[^:]*):[^:]*:[^:]*:(.*)$"))
end
-- Updates an item string, correcting the number of parts
local function FixItemString(itemString)
	local parts = {strsplit(':', itemString)}
	local count = 14

	local numBonusIDs = tonumber(parts[count])
	if numBonusIDs then
		count = count + numBonusIDs
	end
	count = count + 1

	local numModifiers = tonumber(parts[count])
	if numModifiers then
		count = count + (numModifiers * 2)
	end
	count = count + 1

	local relic1NumBonusIDs = tonumber(parts[count])
	if relic1NumBonusIDs then
		count = count + relic1NumBonusIDs
	end
	count = count + 1

	local relic2NumBonusIDs = tonumber(parts[count])
	if relic2NumBonusIDs then
		count = count + relic2NumBonusIDs
	end
	count = count + 1

	local relic3NumBonusIDs = tonumber(parts[count])
	if relic3NumBonusIDs then
		count = count + relic3NumBonusIDs
	end
	count = count + 1

	-- Add crafterGUID, added in 9.1
	if count > #parts then
		parts[#parts+1] = ''
	end
	count = count + 1

	-- Add extraEnchantID, added in 9.1
	if count > #parts then
		parts[#parts+1] = ''
	end
	count = count + 1

	return table.concat(parts, ':')
end
-- Remove parts of the item string that dont reflect item variations, including linkLevel, specializationID, and crafterGUID
local function SanitiseItemString(itemString)
	return string.format("%s:::%s::%s", string.match(FixItemString(itemString), "^(item:%d+:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*):[^:]*:[^:]*:(.*):[^:]*:([^:]*)$"))
end
local function UnsanitiseItemString(itemString)
	local a, b = string.match(itemString, "^(item:%d+:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*):[^:]*:[^:]*:(.*)$")
	return string.format("%s:%d:%d:%s", a, UnitLevel("player"), (GetSpecializationInfo(GetSpecialization())), b)
end

local function FixItemData(itemData)
	local itemString, azeriteString = string.match(itemData, "^(.+)-azerite([^-]+)$")
	if azeriteString then
		return FixItemString(itemString) .. "-azerite" .. azeriteString
	end
	return FixItemString(itemData)
end
local function EncodeItemData(itemLink, azerite)
	local itemString = GetItemString(itemLink)

	if type(azerite) == "table" then
		if #azerite == 0 then
			azerite = "-azerite:0"
		else
			azerite = "-azerite:" .. #azerite .. ":" .. table.concat(azerite, ":")
		end
	elseif type(azerite) ~= "string" then
		azerite = ""
	end

	return SanitiseItemString(itemString) .. azerite
end
Internal.EncodeItemData = EncodeItemData
local function GetEncodedItemDataForItemLocation(itemLocation)
	if itemLocation:IsValid() then
		local itemLink = C_Item.GetItemLink(itemLocation)
		if itemLink then -- Some items in inventory dont have item links, keystones, battlepets
			local itemString = GetItemString(itemLink)
			if itemString then
				local azerite = GetAzeriteDataForItemLocation(itemLocation)

				return SanitiseItemString(itemString) .. azerite
			end
		end
	end
end
local GetEncodedItemDataForLocation
do
	local itemLocation = ItemLocation:CreateEmpty()
	function GetEncodedItemDataForLocation(location)
		SetItemLocationFromLocation(itemLocation, location)
		return GetEncodedItemDataForItemLocation(itemLocation)
	end
end
-- takes a list of locations and itemData and finds the matching item
local function GetItemWithinLocationsByItemData(locations, itemData)
	local itemID = GetItemInfoInstant(itemData)
	for location,locationItemID in pairs(locations) do
		if itemID == locationItemID and itemData == GetEncodedItemDataForLocation(location) then
			return location
		end
	end
end

local freeSlotsCache = {}
local function GetContainerItemLocked(bag, slot)
	local locked = select(3, GetContainerItemInfo(bag, slot))
	return locked and true or false
end
local function IsLocationLocked(location)
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location);
	if not player and not bank and not bags and not voidStorage then -- Invalid location
		return;
	end

	local locked;
	if voidStorage then
		locked = select(3, GetVoidItemInfo(tab, voidSlot))
	elseif not bags then -- and (player or bank)
		locked = IsInventoryItemLocked(slot)
	else -- bags
		locked = select(3, GetContainerItemInfo(bag, slot))
	end

	return locked;
end
local function EmptyInventorySlot(inventorySlotId, reason)
    local itemBagType = GetItemFamily(GetInventoryItemLink("player", inventorySlotId))

    local foundSlot = false
    local containerId, slotId
	for i = NUM_BAG_SLOTS, 0, -1 do
        local _, bagType = C_Container.GetContainerNumFreeSlots(i)
		local freeSlots = freeSlotsCache[i]
		if #freeSlots > 0 and (bit.band(bagType, itemBagType) > 0 or bagType == 0) then
            foundSlot = true
			containerId = i
			slotId = freeSlots[#freeSlots]
			freeSlots[#freeSlots] = nil

            break
        end
    end

	local complete = false;
	if foundSlot then
        ClearCursor()

        PickupInventoryItem(inventorySlotId)
		if CursorHasItem() then
			PickupContainerItem(containerId, slotId)

			-- If the swap succeeded then the cursor should be empty
			if not CursorHasItem() then
				complete = true;
			end
		end

		Internal.LogMessage("Empty inventory slot %d (%s,%s)", inventorySlotId, reason or "default", complete and "true" or "false")

        ClearCursor();
	else
		Internal.LogMessage("Empty inventory slot %d (%s,%s)", inventorySlotId, reason or "default", "false")
    end

    return complete, foundSlot
end
-- Modified version of EquipmentManager_GetItemInfoByLocation but gets the item link instead
local function GetItemLinkByLocation(location)
	local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location);
	if not player and not bank and not bags and not voidStorage then -- Invalid location
		return;
	end

	local itemLink;
	if voidStorage then
		itemLink = GetVoidItemHyperlinkString(tab, voidSlot);
	elseif not bags then -- and (player or bank)
		itemLink = GetInventoryItemLink("player", slot);
	else -- bags
		itemLink = GetContainerItemLink(bag, slot);
	end

	return itemLink;
end
local function SwapInventorySlot(inventorySlotId, itemLink, location, reason)
	local complete = false;
	local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location);
	if not voidStorage and not (player and not bags and slot == inventorySlotId) and not IsLocationLocked(location) then
        ClearCursor()
        if bag == nil then
            PickupInventoryItem(slot)
        else
			PickupContainerItem(bag, slot)
		end

		if CursorHasItem() then
			PickupInventoryItem(inventorySlotId)

			-- If the swap succeeded then the cursor should be empty
			if not CursorHasItem() then
				complete = true;
			end
		end

		Internal.LogMessage("Switching inventory slot %d to %s (%s,%s)", inventorySlotId, GetItemLinkByLocation(location), reason or "default", complete and "true" or "false")

		ClearCursor();
    end

    return complete
end
Internal.GetItemLinkByLocation = GetItemLinkByLocation;
local function CompareItemLinks(a, b)
	local itemIDA = GetItemInfoInstant(a);
	local itemIDB = GetItemInfoInstant(b);

	return itemIDA == itemIDB;
end
-- item:127454::::::::120::::1:0:
-- item:127454::::::::120::512::1:5473:120
-- item:127454::::::::120:268:512:22:2:6314:6313:120:::
local function GetCompareItemInfo(itemLink)
	local itemString = GetItemString(itemLink)
	local linkData = {strsplit(":", itemString)};

	local itemID = tonumber(linkData[2]);
	local enchantID = tonumber(linkData[3]);
	local gemIDs = {n = 4, [tonumber(linkData[4]) or 0] = true, [tonumber(linkData[5]) or 0] = true, [tonumber(linkData[6]) or 0] = true, [tonumber(linkData[7]) or 0] = true};
	local suffixID = tonumber(linkData[8]);
	local uniqueID = tonumber(linkData[9]);
	local upgradeTypeID = tonumber(linkData[12]);

	local index = 14;
	local numBonusIDs = tonumber(linkData[index]) or 0;

	local bonusIDs = {n = numBonusIDs};
	for i=1,numBonusIDs do
		local id = tonumber(linkData[index + i])
		if id then
			bonusIDs[id] = true;
		end
	end
	index = index + numBonusIDs + 1;

	local numModifiers = tonumber(linkData[index]) or 0;
	index = index + 1;

	local upgradeTypeIDs = {n = numModifiers};
	for i=1,numModifiers do
		local id = tonumber(linkData[index + 1]);
		local value = tonumber(linkData[index + 2]);
		if id then
			upgradeTypeIDs[id] = value
		end
		index = index + 2;
	end

	local relic1NumBonusIDs = tonumber(linkData[index]) or 0;
	local relic1BonusIDs = {n = relic1NumBonusIDs};
	for i=1,relic1NumBonusIDs do
		local id = tonumber(linkData[index + i])
		if id then
			relic1BonusIDs[id] = true;
		end
	end
	index = index + relic1NumBonusIDs + 1;

	local relic2NumBonusIDs = tonumber(linkData[index]) or 0;
	local relic2BonusIDs = {n = relic2NumBonusIDs};
	for i=1,relic2NumBonusIDs do
		local id = tonumber(linkData[index + i])
		if id then
			relic2BonusIDs[id] = true;
		end
	end
	index = index + relic2NumBonusIDs + 1;

	local relic3NumBonusIDs = tonumber(linkData[index]) or 0;
	local relic3BonusIDs = {n = relic3NumBonusIDs};
	for i=1,relic3NumBonusIDs do
		local id = tonumber(linkData[index + i])
		if id then
			relic3BonusIDs[id] = true;
		end
	end
	index = index + relic3NumBonusIDs + 1;

	-- These were added in 9.1, we return false for links that were saved pre-9.1
	-- When testing these items we check if the saved version is false and then ignore
	-- comparing these values
	local crafter = false
	if linkData[index] ~= nil then
		crafter = linkData[index]
	end
	index = index + 1;
	local enchantID2 = false
	if linkData[index] ~= nil then
		enchantID2 = tonumber(linkData[index])
	end

	return itemID, enchantID, gemIDs, suffixID, uniqueID, upgradeTypeID, bonusIDs, upgradeTypeIDs, relic1BonusIDs, relic2BonusIDs, relic3BonusIDs, crafter, enchantID2;
end

--[[
    GetItemUniqueness will sometimes return Unique-Equipped info instead of Legion Legendary info,
    this is a cache of items with that or similar issues
]]
local itemUniquenessCache = {
    [144259] = {357, 2},
    [144258] = {357, 2},
    [144249] = {357, 2},
    [152626] = {357, 2},
    [151650] = {357, 2},
    [151649] = {357, 2},
    [151647] = {357, 2},
    [151646] = {357, 2},
    [151644] = {357, 2},
    [151643] = {357, 2},
    [151642] = {357, 2},
    [151641] = {357, 2},
    [151640] = {357, 2},
    [151639] = {357, 2},
    [151636] = {357, 2},
    [150936] = {357, 2},
    [138854] = {357, 2},
    [137382] = {357, 2},
    [137276] = {357, 2},
    [137223] = {357, 2},
    [137220] = {357, 2},
    [137055] = {357, 2},
    [137054] = {357, 2},
    [137052] = {357, 2},
    [137051] = {357, 2},
    [137050] = {357, 2},
    [137049] = {357, 2},
    [137048] = {357, 2},
    [137047] = {357, 2},
    [137046] = {357, 2},
    [137045] = {357, 2},
    [137044] = {357, 2},
    [137043] = {357, 2},
    [137042] = {357, 2},
    [137041] = {357, 2},
    [137040] = {357, 2},
    [137039] = {357, 2},
    [137038] = {357, 2},
    [137037] = {357, 2},
    [133974] = {357, 2},
    [133973] = {357, 2},
    [132460] = {357, 2},
    [132452] = {357, 2},
    [132449] = {357, 2},
    [132410] = {357, 2},
    [132378] = {357, 2},
    [132369] = {357, 2},
}
local GetItemUniquenessByID = C_Item and C_Item.GetItemUniquenessByID;
local GetItemUniqueness = GetItemUniquenessByID and function (itemInfo)
	local isUnique, limitCategoryName, limitCategoryCount, limitCategoryID = GetItemUniquenessByID(itemInfo)

	if not isUnique then
		return nil, nil
	end

	if not limitCategoryName then
		return -1, 1
	end

	return limitCategoryID, limitCategoryCount
end or GetItemUniqueness;
-- Returns the same as GetItemUniqueness except uses the above cache, also converts -1 family to itemID
local function GetItemUniquenessCached(itemLink)
	local itemID = GetItemInfoInstant(itemLink)
	local uniqueFamily, maxEquipped

	local _, _, _, _, _, _, bonusIDs = GetCompareItemInfo(itemLink)
	if bonusIDs then -- Unity Lego
		for i=8119,8130 do
			if bonusIDs[i] then
				return 496, 1
			end
		end
	end

	if itemUniquenessCache[itemID] then
		uniqueFamily, maxEquipped = unpack(itemUniquenessCache[itemID])
	else
		uniqueFamily, maxEquipped = GetItemUniqueness(itemLink)
	end

	if uniqueFamily == -1 then
		uniqueFamily = -itemID
	end

	return uniqueFamily, maxEquipped
end

local GetBestMatch;
do
	local itemLocation = ItemLocation:CreateEmpty();
	local function GetMatchValue(itemLink, extras, location)
		local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location);
		if not player and not bank and not bags and not voidStorage then -- Invalid location
			return 0;
		end

		SetItemLocationFromLocation(itemLocation, location)
		local locationItemLink = C_Item.GetItemLink(itemLocation)
		-- if voidStorage then
		-- 	locationItemLink = GetVoidItemHyperlinkString(tab, voidSlot);
		-- 	itemLocation:Clear();
		-- elseif not bags then -- and (player or bank)
		-- 	locationItemLink = GetInventoryItemLink("player", slot);
		-- 	itemLocation:SetEquipmentSlot(slot);
		-- else -- bags
		-- 	locationItemLink = GetContainerItemLink(bag, slot);
		-- 	itemLocation:SetBagAndSlot(bag, slot);
		-- end

		local match = 0;
		local itemID, enchantID, gemIDs, suffixID, uniqueID, upgradeTypeID, bonusIDs, upgradeTypeIDs, relic1BonusIDs, relic2BonusIDs, relic3BonusIDs, crafter, enchantID2 = GetCompareItemInfo(itemLink);
		local locationItemID, locationEnchantID, locationGemIDs, locationSuffixID, locationUniqueID, locationUpgradeTypeID, locationBonusIDs, locationUpgradeTypeIDs, locationRelic1BonusIDs, locationRelic2BonusIDs, locationRelic3BonusIDs, locationCrafter, locationEnchantID2 = GetCompareItemInfo(locationItemLink);

		if enchantID == locationEnchantID then
			match = match + 1;
		end
		if suffixID == suffixID then
			match = match + 1;
		end
		if uniqueID == locationUniqueID then
			match = match + 1;
		end
		if upgradeTypeID == locationUpgradeTypeID then
			match = match + 1;
		end
		local id = nil
		for i=1,math.max(gemIDs.n,locationGemIDs.n) do
			id = next(gemIDs, id)
			if id and locationGemIDs[id] then
				match = match + 1;
			end
		end
		id = nil
		for i=1,math.max(bonusIDs.n,locationBonusIDs.n) do
			id = next(bonusIDs, id)
			if id and locationBonusIDs[id] then
				match = match + 1;
			end
		end
		id = nil
		for i=1,math.max(upgradeTypeIDs.n,locationUpgradeTypeIDs.n) do
			id = next(upgradeTypeIDs, id)
			if upgradeTypeIDs[id] == locationUpgradeTypeIDs[id] then
				match = match + 1;
			end
		end
		id = nil
		for i=1,math.max(relic1BonusIDs.n,locationRelic1BonusIDs.n) do
			id = next(relic1BonusIDs, id)
			if id and locationRelic1BonusIDs[id] then
				match = match + 1;
			end
		end
		id = nil
		for i=1,math.max(relic2BonusIDs.n,locationRelic2BonusIDs.n) do
			id = next(relic2BonusIDs, id)
			if id and locationRelic2BonusIDs[id] then
				match = match + 1;
			end
		end
		id = nil
		for i=1,math.max(relic3BonusIDs.n,locationRelic3BonusIDs.n) do
			id = next(relic3BonusIDs, id)
			if id and locationRelic3BonusIDs[id] then
				match = match + 1;
			end
		end
		if crafter == locationCrafter then
			match = match + 1;
		end
		if enchantID2 == locationEnchantID2 then
			match = match + 1;
		end

		if extras and extras.azerite and itemLocation:HasAnyLocation() and itemLocation:IsValid() and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
			for _,powerID in ipairs(extras.azerite) do
				if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
					match = match + 1;
				end
			end
		end

		return match;
	end

	local locationMatchValue, locationFiltered = {}, {};
	function GetBestMatch(itemLink, extras, locations)
		local itemID = GetItemInfoInstant(itemLink);
		wipe(locationMatchValue);
		wipe(locationFiltered);
		for location,locationItemLink in pairs(locations) do
			local locationItemID = GetItemInfoInstant(locationItemLink)
			if itemID == locationItemID then
				locationMatchValue[location] = GetMatchValue(itemLink, extras, location);
				locationFiltered[#locationFiltered+1] = location;
			end
		end
		sort(locationFiltered, function (a,b)
			if locationMatchValue[a] == locationMatchValue[b] then
				return a < b
			end
			return locationMatchValue[a] > locationMatchValue[b];
		end);

		return locationFiltered[1];
	end
end
local function CompareTables(a, b)
	if a.n ~= b.n then
		return false
	end
	for k in pairs(a) do
		if not b[k] then
			return false
		end
	end
	return true
end
local function CompareItems(itemLinkA, itemLinkB, extrasA, extrasB)
	if itemLinkA == nil and itemLinkB == nil then
		return true
	end
	if itemLinkA == nil or itemLinkB == nil then
		return false
	end
	if (extrasA ~= nil and extrasB == nil) or (extrasA == nil and extrasB ~= nil) then
		return false
	end

	if GetItemInfoInstant(itemLinkA) ~= GetItemInfoInstant(itemLinkB) then
		return false
	end

	local itemIDA, enchantIDA, gemIDsA, suffixIDA, uniqueIDA, upgradeTypeIDA, bonusIDsA, upgradeTypeIDsA, relic1BonusIDsA, relic2BonusIDsA, relic3BonusIDsA = GetCompareItemInfo(itemLinkA)
	local itemIDB, enchantIDB, gemIDsB, suffixIDB, uniqueIDB, upgradeTypeIDB, bonusIDsB, upgradeTypeIDsB, relic1BonusIDsB, relic2BonusIDsB, relic3BonusIDsB = GetCompareItemInfo(itemLinkB)

	if itemIDA ~= itemIDB then
		return false
	end
	if enchantIDA ~= enchantIDB or #gemIDsA ~= #gemIDsB or suffixIDA ~= suffixIDB or
	   uniqueIDA ~= uniqueIDB or upgradeTypeIDA ~= upgradeTypeIDB or
	   #bonusIDsA ~= #bonusIDsB or #relic1BonusIDsA ~= #relic1BonusIDsB or #relic2BonusIDsA ~= #relic2BonusIDsB or #relic3BonusIDsA ~= #relic3BonusIDsB then
		return false;
	end
	if not CompareTables(gemIDsA, gemIDsB) then
		return false
	end
	if not CompareTables(bonusIDsA, bonusIDsB) then
		return false
	end
	if not CompareTables(upgradeTypeIDsA, upgradeTypeIDsB) then
		return false
	end
	if not CompareTables(relic1BonusIDsA, relic1BonusIDsB) then
		return false
	end
	if not CompareTables(relic2BonusIDsA, relic2BonusIDsB) then
		return false
	end
	if not CompareTables(relic3BonusIDsA, relic3BonusIDsB) then
		return false
	end

	if extrasA and extrasA.azerite and extrasB and extrasB.azerite then
		if #extrasA.azerite ~= #extrasB.azerite then
			return false
		end

		for index,powerID in ipairs(extrasA.azerite) do
			if powerID ~= extrasB.azerite[index] then
				return false
			end
		end
	end

	return true
end
local IsItemInLocation;
do
	local itemLocation = ItemLocation:CreateEmpty();
	function IsItemInLocation(itemLink, extras, player, bank, bags, voidStorage, slot, bag, tab, voidSlot)
		if type(player) == "number" then
			player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(player);
		end

		if not player and not bank and not bags and not voidStorage then -- Invalid location
			return false;
		end

		local locationItemLink;
		if voidStorage then
			locationItemLink = GetVoidItemHyperlinkString(tab, voidSlot);
			itemLocation:Clear();
		elseif not bags then -- and (player or bank)
			locationItemLink = GetInventoryItemLink("player", slot);
			itemLocation:SetEquipmentSlot(slot);
		else -- bags
			locationItemLink = GetContainerItemLink(bag, slot);
			itemLocation:SetBagAndSlot(bag, slot);
		end

		if itemLink ~= nil and locationItemLink == nil then
			return false;
		end
		if itemLink == nil and locationItemLink ~= nil then
			return false;
		end

		local itemID, enchantID, gemIDs, suffixID, uniqueID, upgradeTypeID, bonusIDs, upgradeTypeIDs, relic1BonusIDs, relic2BonusIDs, relic3BonusIDs, crafter, enchantID2 = GetCompareItemInfo(itemLink);
		local locationItemID, locationEnchantID, locationGemIDs, locationSuffixID, locationUniqueID, locationUpgradeTypeID, locationBonusIDs, locationUpgradeTypeIDs, locationRelic1BonusIDs, locationRelic2BonusIDs, locationRelic3BonusIDs, locationCrafter, locationEnchantID2 = GetCompareItemInfo(locationItemLink);
		if itemID ~= locationItemID or enchantID ~= locationEnchantID or #gemIDs ~= #locationGemIDs or suffixID ~= locationSuffixID or uniqueID ~= locationUniqueID or upgradeTypeID ~= locationUpgradeTypeID or #bonusIDs ~= #bonusIDs or #relic1BonusIDs ~= #locationRelic1BonusIDs or #relic2BonusIDs ~= #locationRelic2BonusIDs or #relic3BonusIDs ~= #locationRelic3BonusIDs or (crafter ~= false and crafter ~= locationCrafter) or (enchantID2 ~= false and enchantID2 ~= locationEnchantID2) then
			return false;
		end
		if not CompareTables(gemIDs, locationGemIDs) then
			return false
		end
		if not CompareTables(bonusIDs, locationBonusIDs) then
			return false
		end
		if not CompareTables(upgradeTypeIDs, locationUpgradeTypeIDs) then
			return false
		end
		if not CompareTables(relic1BonusIDs, locationRelic1BonusIDs) then
			return false
		end
		if not CompareTables(relic2BonusIDs, locationRelic2BonusIDs) then
			return false
		end
		if not CompareTables(relic3BonusIDs, locationRelic3BonusIDs) then
			return false
		end

		local itemHasAzerite = (extras and extras.azerite) and true or false
		local locationItemHasAzerite = itemLocation:HasAnyLocation() and itemLocation:IsValid() and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)

		if itemHasAzerite ~= locationItemHasAzerite then
			return false
		end

		if itemHasAzerite and locationItemHasAzerite then
			for _,powerID in ipairs(extras.azerite) do
				if not C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
					return false;
				end
			end
		end

		return true;
	end
end
local CheckEquipmentSetForIssues
do
	local uniqueFamilies = {}
	local uniqueFamilyItems = {}
	function CheckEquipmentSetForIssues(set)
		local ignored = set.ignored
		local expected = set.equipment
		local locations = set.locations
		local errors = set.errors or {}
		wipe(uniqueFamilies)
		wipe(uniqueFamilyItems)

		local firstEquipped = INVSLOT_FIRST_EQUIPPED
		local lastEquipped = INVSLOT_LAST_EQUIPPED

		for inventorySlotId = firstEquipped, lastEquipped do
			errors[inventorySlotId] = nil

			if not ignored[inventorySlotId] and expected[inventorySlotId] then
				local itemLink = expected[inventorySlotId]
				local uniqueFamily, maxEquipped = GetItemUniquenessCached(itemLink)

				if uniqueFamily ~= nil then
					uniqueFamilies[uniqueFamily] = (uniqueFamilies[uniqueFamily] or maxEquipped) - 1

					if uniqueFamilyItems[uniqueFamily] then
						uniqueFamilyItems[uniqueFamily][#uniqueFamilyItems[uniqueFamily]+1] = inventorySlotId
					else
						uniqueFamilyItems[uniqueFamily] = {inventorySlotId}
					end
				end

				local index = 1
				local gemName, gemLink = GetItemGem(itemLink, index)
				while gemName do
					uniqueFamily, maxEquipped = GetItemUniquenessCached(gemLink)

					if uniqueFamily ~= nil then
						uniqueFamilies[uniqueFamily] = (uniqueFamilies[uniqueFamily] or maxEquipped) - 1

						if uniqueFamilyItems[uniqueFamily] then
							uniqueFamilyItems[uniqueFamily][#uniqueFamilyItems[uniqueFamily]+1] = inventorySlotId
						else
							uniqueFamilyItems[uniqueFamily] = {inventorySlotId}
						end
					end

					index = index + 1
					gemName, gemLink = GetItemGem(itemLink, index)
				end
			end
		end

		for uniqueFamily, maxEquipped in pairs(uniqueFamilies) do
			if maxEquipped < 0 then
				for _,inventorySlotId in ipairs(uniqueFamilyItems[uniqueFamily]) do
					if errors[inventorySlotId] then
						errors[inventorySlotId] = format("%s\n%s", errors[inventorySlotId], ERR_ITEM_UNIQUE_EQUIPPABLE)
					elseif uniqueFamily < 0 then -- Item
						errors[inventorySlotId] = ERR_ITEM_UNIQUE_EQUIPPABLE
					else
						errors[inventorySlotId] = ERR_ITEM_UNIQUE_EQUIPPABLE
					end
				end
			end
		end

		local character = GetCharacterSlug()
		if character == set.character then
			for inventorySlotId = firstEquipped, lastEquipped do
				if not ignored[inventorySlotId] and expected[inventorySlotId] then
					local location = locations[inventorySlotId]
					if not location then
						errors[inventorySlotId] = L["Exact item is missing and may not be equippable"]
					elseif not BankFrame:IsShown() and bit.band(location, ITEM_INVENTORY_LOCATION_BANK) == ITEM_INVENTORY_LOCATION_BANK then
						errors[inventorySlotId] = L["Exact item is in the bank"]
					end
				end
			end
		end

		set.errors = errors
		return errors
	end
end
local function IsEquipmentSetActive(set)
	local expected = set.equipment;
	local extras = set.extras;
	local locations = set.locations;
	local ignored = set.ignored;

    local firstEquipped = INVSLOT_FIRST_EQUIPPED;
    local lastEquipped = INVSLOT_LAST_EQUIPPED;

    -- if combatSwap then
    --     firstEquipped = INVSLOT_MAINHAND;
    --     lastEquipped = INVSLOT_RANGED;
	-- end

	for inventorySlotId=firstEquipped,lastEquipped do
		if not ignored[inventorySlotId] then
			if expected[inventorySlotId] then
				if locations[inventorySlotId] then
					local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(locations[inventorySlotId]);
					if not (player and not bags and slot == inventorySlotId) then
						return false;
					end
				else
					local itemLink = GetInventoryItemLink("player", inventorySlotId)
					if not itemLink or not CompareItemLinks(itemLink, expected[inventorySlotId]) then
						return false;
					end
				end
			elseif GetInventoryItemLink("player", inventorySlotId) ~= nil then
				return false;
			end
		end
	end
    return true;
end
local ActivateEquipmentSet;
do
	local correctSlots = {};
	local possibleItems = {};
	local bestMatchForSlot = {};
	local uniqueFamilies = {};
	-- This function is destructive to the set
	function ActivateEquipmentSet(set, state)
		if not state or not state.allowPartial then
			local ignored = set.ignored;
			local expected = set.equipment;
			local extras = set.extras;
			local locations = set.locations;
			local errors = set.errors;
			local anyLockedSlots, anyFoundFreeSlots, anyChangedSlots = nil, nil, nil
			wipe(correctSlots)
			wipe(uniqueFamilies)

			local firstEquipped = INVSLOT_FIRST_EQUIPPED
			local lastEquipped = INVSLOT_LAST_EQUIPPED

			-- if combatSwap then
			-- 	firstEquipped = INVSLOT_MAINHAND
			-- 	lastEquipped = INVSLOT_RANGED
			-- end

			-- Store a list of all available empty slots
			local totalFreeSlots = 0
			for i=BACKPACK_CONTAINER,NUM_BAG_SLOTS do
				if not freeSlotsCache[i] then
					freeSlotsCache[i] = {}
				else
					wipe(freeSlotsCache[i])
				end

				if GetContainerFreeSlots(i, freeSlotsCache[i]) then
					totalFreeSlots = totalFreeSlots + #freeSlotsCache[i]
				end
			end

			-- Loop through and empty slots that should be empty, also store locations for other slots
			for inventorySlotId = firstEquipped, lastEquipped do
				if errors and errors[inventorySlotId] then -- If there is an error in a slot, normally due to unique-equipped items then just ignore it
					ignored[inventorySlotId] = true
				end

				-- Update the expected item link by location, if the target location is empty than ignore the slot, this does NOT effect the original set
				if not ignored[inventorySlotId] and locations[inventorySlotId] and locations[inventorySlotId] > 0 and not expected[inventorySlotId] then
					expected[inventorySlotId] = GetItemLinkByLocation(locations[inventorySlotId])

					if not expected[inventorySlotId] then
						ignored[inventorySlotId] = true
					end
				end

				if not ignored[inventorySlotId] then
					local slotLocked = IsInventoryItemLocked(inventorySlotId)
					anyLockedSlots = anyLockedSlots or slotLocked

					local itemLink = expected[inventorySlotId];
					if itemLink then -- Get the location of the best match for the slot
						local location = locations[inventorySlotId];
						if location and location > 0 and IsItemInLocation(itemLink, extras[inventorySlotId], location) then
							local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location);
							if player and not bags and slot == inventorySlotId then -- The item is already in the desired location
								correctSlots[inventorySlotId] = true;
								ignored[inventorySlotId] = true;
							else
								bestMatchForSlot[inventorySlotId] = location;
							end
						else
							-- The item is already in the desired location
							if IsItemInLocation(itemLink, extras[inventorySlotId], true, false, false, false, inventorySlotId, false) then
								correctSlots[inventorySlotId] = true;
								ignored[inventorySlotId] = true;
							else
								GetInventoryItemsForSlot(inventorySlotId, possibleItems)

								for completedSlotId in pairs(correctSlots) do
									possibleItems[PackLocation(nil, completedSlotId)] = nil
								end

								location = GetBestMatch(itemLink, extras[inventorySlotId], possibleItems)
								wipe(possibleItems);
								if location == nil then -- Could not find the requested item @TODO Error
									ignored[inventorySlotId] = true;
								else
									local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location);
									if player and not bags and slot == inventorySlotId then -- The item is already in the desired location, this shouldnt happen
										correctSlots[inventorySlotId] = true;
										ignored[inventorySlotId] = true;
									end
									bestMatchForSlot[inventorySlotId] = location;
								end
							end
						end
					else -- Unequip
						if GetInventoryItemLink("player", inventorySlotId) ~= nil then
							if not IsInventoryItemLocked(inventorySlotId) then
								local complete, foundSlot = EmptyInventorySlot(inventorySlotId)
								anyChangedSlots = anyChangedSlots or complete
								anyFoundFreeSlots = anyFoundFreeSlots or foundSlot
							end
						else -- Already unequipped
							ignored[inventorySlotId] = true;
						end
					end
				end

				-- If we arent swapping an item out and its in some way unique we may need to skip swapping another unique item in
				if ignored[inventorySlotId] then
					local itemLink = GetInventoryItemLink("player", inventorySlotId)
					if itemLink then
						local itemID = GetItemInfoInstant(itemLink)
						local uniqueFamily, maxEquipped = GetItemUniquenessCached(itemLink)

						if uniqueFamily ~= nil then
							uniqueFamilies[uniqueFamily] = (uniqueFamilies[uniqueFamily] or maxEquipped) - 1
						end

						local index = 1
						local gemName, gemLink = GetItemGem(itemLink, index)
						while gemName do
							itemID = GetItemInfoInstant(gemLink)
							uniqueFamily, maxEquipped = GetItemUniquenessCached(gemLink)

							if uniqueFamily ~= nil then
								uniqueFamilies[uniqueFamily] = (uniqueFamilies[uniqueFamily] or maxEquipped) - 1
							end

							index = index + 1
							gemName, gemLink = GetItemGem(itemLink, index)
						end
					end
				end
			end

			-- Check expected items uniqueness
			for inventorySlotId = firstEquipped, lastEquipped do
				if not ignored[inventorySlotId] and expected[inventorySlotId] then
					local itemLink = expected[inventorySlotId];
					local itemID = GetItemInfoInstant(itemLink);
					local uniqueFamily, maxEquipped = GetItemUniquenessCached(itemLink)

					if uniqueFamily then
						if uniqueFamilies[uniqueFamily] then
							if uniqueFamilies[uniqueFamily] <= 0 then
								ignored[inventorySlotId] = true -- To many of the unique items already equipped
							else
								uniqueFamilies[uniqueFamily] = uniqueFamilies[uniqueFamily] - 1
							end
						else
							uniqueFamilies[uniqueFamily] = maxEquipped - 1
						end
					end

					if not ignored[inventorySlotId] then
						local index = 1
						local gemName, gemLink = GetItemGem(itemLink, index)
						while gemName do
							itemID = GetItemInfoInstant(gemLink);
							uniqueFamily, maxEquipped = GetItemUniquenessCached(gemLink)

							if uniqueFamily then
								if uniqueFamilies[uniqueFamily] then
									if uniqueFamilies[uniqueFamily] <= 0 then
										ignored[inventorySlotId] = true -- To many of the unique gems already equipped
									else
										uniqueFamilies[uniqueFamily] = uniqueFamilies[uniqueFamily] - 1
									end
								else
									uniqueFamilies[uniqueFamily] = maxEquipped - 1
								end
							end

							index = index + 1
							gemName, gemLink = GetItemGem(itemLink, index)
						end
					end
				end
			end

			-- Swap currently equipped "unique" items that need to be swapped out before others can be swapped in
			for inventorySlotId = firstEquipped, lastEquipped do
				local itemLink = GetInventoryItemLink("player", inventorySlotId)

				if not ignored[inventorySlotId] and not IsInventoryItemLocked(inventorySlotId) and expected[inventorySlotId] and itemLink ~= nil then
					local itemID = GetItemInfoInstant(itemLink);
					local uniqueFamily, maxEquipped = GetItemUniquenessCached(itemLink)

					local swapSlot = uniqueFamilies[uniqueFamily] ~= nil and uniqueFamilies[uniqueFamily] <= 0
					if not swapSlot then
						local index = 1
						local gemName, gemLink = GetItemGem(itemLink, index)
						while gemName do
							itemID = GetItemInfoInstant(gemLink)
							uniqueFamily, maxEquipped = GetItemUniquenessCached(gemLink)

							swapSlot = uniqueFamilies[uniqueFamily] ~= nil and uniqueFamilies[uniqueFamily] <= 0

							if swapSlot then
								break
							end

							index = index + 1
							gemName, gemLink = GetItemGem(itemLink, index)
						end
					end

					if swapSlot then
						local expectedUniqueFamily = GetItemUniquenessCached(expected[inventorySlotId])
						-- Under some situations we need to just remove a unique item before equipping its replacement, this is emptying slots more than I'd like
						if expectedUniqueFamily and expectedUniqueFamily ~= uniqueFamily and not IsLocationEquipmentSlot(bestMatchForSlot[inventorySlotId]) then
							local complete, foundSlot = EmptyInventorySlot(inventorySlotId, "unique")
							anyChangedSlots = anyChangedSlots or complete
							anyFoundFreeSlots = anyFoundFreeSlots or foundSlot
						elseif SwapInventorySlot(inventorySlotId, expected[inventorySlotId], bestMatchForSlot[inventorySlotId], "unique") then
							anyChangedSlots = true
						end
					end
				end
			end

			-- Swap out items
			for inventorySlotId = firstEquipped, lastEquipped do
				if not ignored[inventorySlotId] and not IsInventoryItemLocked(inventorySlotId) and expected[inventorySlotId] then
					if SwapInventorySlot(inventorySlotId, expected[inventorySlotId], bestMatchForSlot[inventorySlotId]) then
						anyChangedSlots = true
					end
				end
			end

			ClearCursor()

			-- We assume that if we have any locked slots or any changed slots we are not complete yet
			local complete = not anyLockedSlots and not anyChangedSlots
			if complete then
				-- If there are no locked slots and not changed slots and we never found a free slot
				-- to remove an item, we will consider ourselves complete but with an error
				if anyFoundFreeSlots == false then
					return complete, L["Failed to change equipment set"]
				end
				for inventorySlotId = firstEquipped, lastEquipped do
					-- We mark slots as ignored when they are finished
					if not ignored[inventorySlotId] then
						complete = false
					end
				end
			end

			return complete, false;
		end
		return true, false
	end
end
local function UpdateSetFilters(set)
	set.filters = set.filters or {}
	
    Internal.UpdateRestrictionFilters(set)

	set.filters.character = set.character
	local characterInfo = GetCharacterInfo(set.character);
	set.filters.class = characterInfo and characterInfo.class;

    return set
end
local function GetEquipmentSet(id)
    if type(id) == "table" then
		return id;
	else
		return BtWLoadoutsSets.equipment[id];
	end
end
local function GetSetsForCharacter(tbl, slug)
	tbl = tbl or {}
	for _,set in pairs(BtWLoadoutsSets.equipment) do
		if type(set) == "table" and set.character == slug then
			tbl[#tbl+1] = set
		end
	end
	return tbl
end
-- returns isValid and isValidForPlayer
local function EquipmentSetIsValid(set)
	local set = GetEquipmentSet(set);
	local isValidForPlayer = (set.character == GetCharacterSlug())
	return true, isValidForPlayer
end
-- Adds a blank equipment set for the current character
local function AddBlankEquipmentSet()
    local set = {
		setID = Internal.GetNextSetID(BtWLoadoutsSets.equipment),
        character = GetCharacterSlug(),
        name = "",
		equipment = {},
		ignored = {},
		extras = {},
		locations = {},
		data = {},
		filters = {character = GetCharacterSlug()},
		useCount = 0,
    };
	UpdateSetFilters(set)
    BtWLoadoutsSets.equipment[set.setID] = set;
    return set;
end
-- Update an equipment set with the currently equipped gear
local function RefreshEquipmentSet(set)
	if set.character ~= GetCharacterSlug() then
		return
	end

	for inventorySlotId=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
		local previousLocation = set.locations[inventorySlotId]

		set.equipment[inventorySlotId] = GetInventoryItemLink("player", inventorySlotId);
		set.locations[inventorySlotId] = set.equipment[inventorySlotId] and PackLocation(nil, inventorySlotId) or nil; -- Only set location if there is an item

		local itemLocation = ItemLocation:CreateFromEquipmentSlot(inventorySlotId);
		if itemLocation and itemLocation:HasAnyLocation() and itemLocation:IsValid() and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
			set.extras[inventorySlotId] = set.extras[inventorySlotId] or {};
			local extras = set.extras[inventorySlotId];
			extras.azerite = extras.azerite or {};
			wipe(extras.azerite);

			local tiers = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation);
			for index,tier in ipairs(tiers) do
				for _,powerID in ipairs(tier.azeritePowerIDs) do
					if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
						extras.azerite[index] = powerID;
						break;
					end
				end
			end
		else
			set.extras[inventorySlotId] = nil;
		end

		-- We want this to supersede the other 2, but need those for fallback still
		set.data[inventorySlotId] = set.equipment[inventorySlotId] and EncodeItemData(set.equipment[inventorySlotId], set.extras[inventorySlotId] and set.extras[inventorySlotId].azerite) or nil
		if set.setID then -- Only do this for previously created sets
			UpdateSetItemInMapData(set, inventorySlotId, previousLocation, set.locations[inventorySlotId])
		end
	end

	-- Need to update the built in manager too
	if set.managerID then
		C_EquipmentSet.SaveEquipmentSet(set.managerID)
	end

	UpdateSetFilters(set)
	
	Internal.Call("EquipmentSetUpdated", set.setID);

	return set
end
local function AddEquipmentSet()
    local characterName, characterRealm = UnitFullName("player");
    local result = AddSet("equipment", RefreshEquipmentSet({
		character = characterRealm .. "-" .. characterName,
		name = format(L["New %s Equipment Set"], characterName),
		useCount = 0,
        equipment = {},
        ignored = {
			[INVSLOT_BODY] = true,
			[INVSLOT_TABARD] = true,
		},
		extras = {},
		locations = {},
        data = {},
	}))
	AddSetToMapData(result)
    Internal.Call("EquipmentSetCreated", result.setID);
	return result
end
local function GetEquipmentSetsByName(name)
	return Internal.GetSetsByName("equipment", name)
end
local function GetEquipmentSetByName(name)
	return Internal.GetSetByName("equipment", name, EquipmentSetIsValid)
end
local function GetEquipmentSets(id, ...)
	if id ~= nil then
		return BtWLoadoutsSets.equipment[id], Internal.GetEquipmentSets(...);
	end
end
function Internal.GetEquipmentSetIfNeeded(id)
	if id == nil then
		return;
	end

	local set = Internal.GetEquipmentSet(id);
	if IsEquipmentSetActive(set) then
		return;
	end

    return set;
end
local function CombineEquipmentSets(result, state, ...)
	result = result or {};

	local playerCharacter = GetCharacterSlug()

	result.equipment = {};
	result.extras = {};
	result.locations = {};
	result.ignored = {};
	result.data = {};
	for slot=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
		result.ignored[slot] = true;
	end
	for i=1,select('#', ...) do
		local set = select(i, ...);
		if set.character == playerCharacter and Internal.AreRestrictionsValidForPlayer(set.restrictions) then -- Skip other characters
			if set.managerID then -- Just making sure everything is up to date
				local ignored = C_EquipmentSet.GetIgnoredSlots(set.managerID);
				local locations = C_EquipmentSet.GetItemLocations(set.managerID);
				if ignored and locations then
					for inventorySlotId=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
						set.ignored[inventorySlotId] = ignored[inventorySlotId] and true or nil;

						local location = locations[inventorySlotId] or 0;
						if location > -1 then -- If location is -1 we ignore it as we cant get the item link for the item
							set.equipment[inventorySlotId] = GetItemLinkByLocation(location)
							set.extras[inventorySlotId] = Internal.GetExtrasForLocation(location, set.extras[inventorySlotId] or {})
							set.data[inventorySlotId] = set.equipment[inventorySlotId] and Internal.EncodeItemData(set.equipment[inventorySlotId], set.extras[inventorySlotId] and set.extras[inventorySlotId].azerite) or nil
						end
						set.locations[inventorySlotId] = location;
						if set.extras[inventorySlotId] then
							wipe(set.extras[inventorySlotId])
						end
					end
				end
			end
			for inventorySlotId=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
				if not set.ignored[inventorySlotId] then
					result.ignored[inventorySlotId] = nil;
					result.equipment[inventorySlotId] = set.equipment[inventorySlotId];
					result.extras[inventorySlotId] = set.extras[inventorySlotId] or nil;
					result.locations[inventorySlotId] = set.locations[inventorySlotId] or nil;
					result.data[inventorySlotId] = set.data[inventorySlotId] or nil;
				end
			end
		end
	end

    if state then
		if state.blockers and not IsEquipmentSetActive(result) then
			state.blockers[Internal.GetCombatBlocker()] = true
			state.blockers[Internal.GetMythicPlusBlocker()] = true
			state.blockers[Internal.GetJailersChainBlocker()] = true
		end

		if result.ignored[INVSLOT_NECK] then
			state.heartEquipped = GetInventoryItemID("player", INVSLOT_NECK) == 158075
		elseif result.equipment[INVSLOT_NECK] then
			state.heartEquipped = GetItemInfoInstant(result.equipment[INVSLOT_NECK]) == 158075
		else
			state.heartEquipped = false
		end
    end

	return result;
end
local function DeleteEquipmentSet(id)
	do
		local set = GetEquipmentSet(id)
		if set.character == Internal.GetCharacterSlug() and set.locations then
			RemoveSetFromMapData(set)
		end
	end
	Internal.DeleteSet(BtWLoadoutsSets.equipment, id)

	if type(id) == "table" then
		id = id.setID;
	end
	for _,set in pairs(BtWLoadoutsSets.profiles) do
        if type(set) == "table" then
            for index,setID in ipairs(set.equipment) do
                if setID == id then
                    table.remove(set.equipment, index)
                end
			end
			set.character = nil
		end
	end
    
	Internal.Call("EquipmentSetDeleted", id);

	local frame = BtWLoadoutsFrame.Equipment;
	local set = frame.set;
	if set and set.setID == id then
		frame.set = nil;
		BtWLoadoutsFrame:Update();
	end
end
local function EquipementSetContainsItem(set, itemLink, extras, ignoreSlotsWithLocation)
	for slot=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
		if not set.ignored[slot] then
			if (not ignoreSlotsWithLocation or not set.locations[slot]) and CompareItems(set.equipment[slot], itemLink, set.extras[slot], extras) then
				return slot
			end
		end
	end

	return false
end
local function CheckErrors(errorState, set)
    set = GetEquipmentSet(set)

	if errorState.specID then
		errorState.role, errorState.class = select(5, GetSpecializationInfoByID(errorState.specID))
	end

	local characterInfo = GetCharacterInfo(set.character);
	errorState.class = errorState.class or characterInfo.class;

	if errorState.class ~= characterInfo.class then
        return L["Incompatible Class"]
    end

	if not Internal.AreRestrictionsValidFor(set.restrictions, errorState.specID) then
        return L["Incompatible Restrictions"]
	end
end

Internal.GetEquipmentSet = GetEquipmentSet
Internal.GetEquipmentSetsByName = GetEquipmentSetsByName
Internal.GetEquipmentSetByName = GetEquipmentSetByName
Internal.AddBlankEquipmentSet = AddBlankEquipmentSet
Internal.AddEquipmentSet = AddEquipmentSet
Internal.RefreshEquipmentSet = RefreshEquipmentSet
Internal.DeleteEquipmentSet = DeleteEquipmentSet
Internal.ActivateEquipmentSet = ActivateEquipmentSet
Internal.IsEquipmentSetActive = IsEquipmentSetActive
Internal.CombineEquipmentSets = CombineEquipmentSets
Internal.CheckEquipmentSetForIssues = CheckEquipmentSetForIssues
Internal.IsItemInLocation = IsItemInLocation
Internal.GetEquipmentSets = GetEquipmentSets

local GetCursorItemSource
do
	local currentCursorSource = {};
	local function Hook_PickupContainerItem(bag, slot)
		if CursorHasItem() then
			currentCursorSource.bag = bag;
			currentCursorSource.slot = slot;
		else
			wipe(currentCursorSource);
		end
	end
	if C_Container and C_Container.PickupContainerItem then
		hooksecurefunc(C_Container, "PickupContainerItem", Hook_PickupContainerItem);
	else
		hooksecurefunc("PickupContainerItem", Hook_PickupContainerItem);
	end
	local function Hook_PickupInventoryItem(slot)
		if CursorHasItem() then
			currentCursorSource.slot = slot;
		else
			wipe(currentCursorSource);
		end
	end
	hooksecurefunc("PickupInventoryItem", Hook_PickupInventoryItem);
	function GetCursorItemSource()
		return currentCursorSource.bag or false, currentCursorSource.slot or false;
	end
end

-- Initializes the set dropdown menu for the Loadouts page
local function SetDropDownInit(self, set, index)
    Internal.SetDropDownInit(self, set, index, "equipment", BtWLoadoutsFrame.Equipment)
end

Internal.AddLoadoutSegment({
    id = "equipment",
    name = L["Equipment"],
    events = "PLAYER_EQUIPMENT_CHANGED",
    add = AddEquipmentSet,
    get = GetEquipmentSets,
	getByName = GetEquipmentSetByName,
    combine = CombineEquipmentSets,
    isActive = IsEquipmentSetActive,
	activate = ActivateEquipmentSet,
	dropdowninit = SetDropDownInit,
	checkerrors = CheckErrors,
})

local gameTooltipErrorLink;
local gameTooltipErrorText;

local equipLocToInvSlot = {
	["INVTYPE_HEAD"]			=	{[1]  = true},
	["INVTYPE_NECK"]			=	{[2]  = true},
	["INVTYPE_SHOULDER"]		=	{[3]  = true},
	["INVTYPE_BODY"]			=	{[4]  = true},
	["INVTYPE_CHEST"]			=	{[5]  = true},
	["INVTYPE_ROBE"]			=	{[5]  = true},
	["INVTYPE_WAIST"]			=	{[6]  = true},
	["INVTYPE_LEGS"]			=	{[7]  = true},
	["INVTYPE_FEET"]			=	{[8]  = true},
	["INVTYPE_WRIST"]			=	{[9]  = true},
	["INVTYPE_HAND"]			=	{[10] = true},
	["INVTYPE_FINGER"]			=	{[11] = true, [12] = true},
	["INVTYPE_TRINKET"]			=	{[13] = true, [14] = true},
	["INVTYPE_CLOAK"]			=	{[15] = true},
	["INVTYPE_RANGED"]			=	{[16] = true},
	["INVTYPE_2HWEAPON"]		=	{[16] = true},
	["INVTYPE_WEAPONMAINHAND"]	=	{[16] = true},
	["INVTYPE_WEAPONOFFHAND"]	=	{[16] = true},
	["INVTYPE_THROWN"]			=	{[16] = true},
	["INVTYPE_RANGEDRIGHT"]		=	{[16] = true},
	["INVTYPE_WEAPON"]			=	{[16] = true},
	["INVTYPE_SHIELD"]			=	{[17] = true},
	["INVTYPE_HOLDABLE"]		=	{[17] = true},
	["INVTYPE_TABARD"]			=	{[19] = true},
	-- ["INVTYPE_BAG"]
	-- ["INVTYPE_AMMO"]
	-- ["INVTYPE_QUIVER"]
	-- ["INVTYPE_RELIC"]
}
local function IsItemValidForSlot(itemLink, invSlot, classID)
	local _, _, _, itemEquipLoc = GetItemInfoInstant(itemLink)

	if itemEquipLoc == "INVTYPE_2HWEAPON" and invSlot == 17 and classID == 1 then -- Double 2 handers for fury
		return true
	elseif itemEquipLoc == "INVTYPE_WEAPON" and invSlot == 17 and (classID == 1 or classID == 4 or classID == 6 or classID == 7 or classID == 10 or classID == 11 or classID == 12) then -- Duel Weilders
		return true
	end

	return (equipLocToInvSlot[itemEquipLoc] and equipLocToInvSlot[itemEquipLoc][invSlot]) and true or false
end

BtWLoadoutsItemSlotButtonMixin = {};
function BtWLoadoutsItemSlotButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	-- self:RegisterEvent("GET_ITEM_INFO_RECEIVED");

	local id, textureName, checkRelic = GetInventorySlotInfo(self:GetSlot());
	self:SetID(id);
	self.icon:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.ignoreTexture:Hide();

	local popoutButton = self.popoutButton;
	if ( popoutButton ) then
		if ( self.verticalFlyout ) then
			popoutButton:SetHeight(16);
			popoutButton:SetWidth(38);

			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("TOP", self, "BOTTOM", 0, 4);
		else
			popoutButton:SetHeight(38);
			popoutButton:SetWidth(16);

			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("LEFT", self, "RIGHT", -8, 0);
		end

		-- popoutButton:Show();
	end
end
function BtWLoadoutsItemSlotButtonMixin:OnClick()
	local cursorType, _, itemLink = GetCursorInfo();
	if cursorType == "item" then
		if self:SetItem(itemLink, GetCursorItemSource()) then
			ClearCursor();
		end
	elseif IsModifiedClick("SHIFT") then
		local set = self:GetParent().set;
		self:SetIgnored(not set.ignored[self:GetID()]);
	else
		self:SetItem(nil);
	end
end
function BtWLoadoutsItemSlotButtonMixin:OnReceiveDrag()
	if not self:IsEnabled() then
		return
	end

	local cursorType, _, itemLink = GetCursorInfo();
	if self:GetParent().set and cursorType == "item" then
		if self:SetItem(itemLink, GetCursorItemSource()) then
			ClearCursor();
		end
	end
end
function BtWLoadoutsItemSlotButtonMixin:OnEvent(event, itemID, success)
	if success then
		local set = self:GetParent().set;
		local slot = self:GetID();
		local itemLink = set.equipment[slot];

		if itemLink and itemID == GetItemInfoInstant(itemLink) then
			self:Update();
			self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	end
end
function BtWLoadoutsItemSlotButtonMixin:OnEnter()
	local character = GetCharacterSlug()
	local set = self:GetParent().set;
	local slot = self:GetID();
	local location = set.locations[slot];
	local itemLink = set.equipment[slot];

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if set.character == character and location and location > 0 and (BankFrame:IsShown() or bit.band(location, ITEM_INVENTORY_LOCATION_BANK) ~= ITEM_INVENTORY_LOCATION_BANK) then
		local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location);
		if not bags then
			GameTooltip:SetInventoryItem("player", slot)
		else
			GameTooltip:SetBagItem(bag, slot)
		end
	elseif itemLink then
		GameTooltip:SetHyperlink(itemLink);
		itemLink = select(2, GameTooltip:GetItem())
	else
		return
	end
	if self.errors then
		gameTooltipErrorLink = itemLink
		gameTooltipErrorText = self.errors
	else
		gameTooltipErrorLink = nil
		gameTooltipErrorText = nil
	end
end
function BtWLoadoutsItemSlotButtonMixin:OnLeave()
	gameTooltipErrorLink = nil
	gameTooltipErrorText = nil
	GameTooltip:Hide();
end
function BtWLoadoutsItemSlotButtonMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		self:OnEnter();
	end
end
function BtWLoadoutsItemSlotButtonMixin:GetSlot()
	return self.slot;
end
function BtWLoadoutsItemSlotButtonMixin:SetItem(itemLink, bag, slot)
	local set = self:GetParent().set;
	if itemLink == nil then -- Clearing slot
		local previousLocation = set.locations[self:GetID()]

		set.equipment[self:GetID()] = nil;
		set.locations[self:GetID()] = nil;
		set.data[self:GetID()] = nil;

		Internal.UpdateEquipmentSetItemInMapData(set, self:GetID(), previousLocation, nil)

		Internal.Call("EquipmentSetUpdated", set.setID);
		self:Update();
		return true;
	else
		if IsItemValidForSlot(itemLink, self:GetID(), select(3, UnitClass("player"))) then
			local previousLocation = set.locations[self:GetID()]

			set.equipment[self:GetID()] = itemLink;

			local itemLocation;
			if bag and slot then
				itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
			elseif slot then
				itemLocation = ItemLocation:CreateFromEquipmentSlot(slot);
			end

			set.locations[self:GetID()] = GetLocationFromItemLocation(itemLocation)

			if itemLocation and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
				set.extras[self:GetID()] = set.extras[self:GetID()] or {};
				local extras = set.extras[self:GetID()];
				extras.azerite = extras.azerite or {};
				wipe(extras.azerite);

				local tiers = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation);
				for index,tier in ipairs(tiers) do
					for _,powerID in ipairs(tier.azeritePowerIDs) do
						if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
							extras.azerite[index] = powerID;
							break;
						end
					end
				end
			else
				set.extras[self:GetID()] = nil;
			end
			set.data[self:GetID()] = EncodeItemData(itemLink, set.extras[self:GetID()] and set.extras[self:GetID()].azerite);

			Internal.UpdateEquipmentSetItemInMapData(set, self:GetID(), previousLocation, set.locations[self:GetID()])
			
			Internal.Call("EquipmentSetUpdated", set.setID);

			BtWLoadoutsFrame:Update(); -- Refresh everything, this'll update the error handling too
			return true;
		end
	end
	return false;
end
function BtWLoadoutsItemSlotButtonMixin:SetIgnored(ignored)
	local set = self:GetParent().set;
	set.ignored[self:GetID()] = ignored and true or nil;
	Internal.Call("EquipmentSetUpdated", set.setID);
	BtWLoadoutsFrame:Update(); -- Refresh everything, this'll update the error handling too
end
function BtWLoadoutsItemSlotButtonMixin:Update()
	local set = self:GetParent().set;
	local slot = self:GetID();
	local ignored = set and set.ignored[slot] or false;
	local errors = set and set.errors[slot];
	local itemLink = set and set.equipment[slot];

	if itemLink then
		local itemID = GetItemInfoInstant(itemLink);
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemLink);
		if quality == nil or texture == nil then
			self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		end

		SetItemButtonTexture(self, texture);
		SetItemButtonQuality(self, quality, itemID);
	else
		SetItemButtonTexture(self, self.backgroundTextureName);
		SetItemButtonQuality(self, nil, nil);
	end

	self.errors = errors -- For tooltip display
	self.ErrorBorder:SetShown(errors ~= nil)
	self.ErrorOverlay:SetShown(errors ~= nil)
	self.ignoreTexture:SetShown(ignored);
end
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function (self, data)
		if self ~= GameTooltip then
			return
		end
		local name, link = self:GetItem()
		if gameTooltipErrorLink == link and gameTooltipErrorText then
			self:AddLine(format("\n|cffff0000%s|r", gameTooltipErrorText))
		end
	end)
else
	GameTooltip:HookScript("OnTooltipSetItem", function (self)
		local name, link = self:GetItem()
		if gameTooltipErrorLink == link and gameTooltipErrorText then
			self:AddLine(format("\n|cffff0000%s|r", gameTooltipErrorText))
		end
	end)
end

BtWLoadoutsEquipmentMixin = {}
function BtWLoadoutsEquipmentMixin:OnLoad()
    self.RestrictionsDropDown:SetSupportedTypes("covenant", "spec", "race")
    self.RestrictionsDropDown:SetScript("OnChange", function ()
		Internal.Call("EquipmentSetUpdated", self.set.setID);
        self:Update()
    end)
end
function BtWLoadoutsEquipmentMixin:ChangeSet(set)
    self.set = set
    self:Update()
end
function BtWLoadoutsEquipmentMixin:UpdateSetName(value)
	if self.set and self.set.name ~= not value then
		self.set.name = value;
		self:Update();
	end
end
function BtWLoadoutsEquipmentMixin:OnButtonClick(button)
	CloseDropDownMenus()
	if button.isAdd then
		self.Name:ClearFocus();
		self:ChangeSet(AddEquipmentSet())
		C_Timer.After(0, function ()
			self.Name:HighlightText();
			self.Name:SetFocus();
		end);
	elseif button.isDelete then
		local set = self.set;
		if set.useCount > 0 then
			StaticPopup_Show("BTWLOADOUTS_DELETEINUSESET", set.name, nil, {
				set = set,
				func = Internal.DeleteEquipmentSet,
			});
		else
			StaticPopup_Show("BTWLOADOUTS_DELETESET", set.name, nil, {
				set = set,
				func = Internal.DeleteEquipmentSet,
			});
		end
	elseif button.isRefresh then
		local set = self.set;
		RefreshEquipmentSet(set)
		self:Update()
	elseif button.isActivate then
		Internal.ActivateProfile({
			equipment = {self.set.setID}
		});
	end
end
function BtWLoadoutsEquipmentMixin:OnSidebarItemClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		button.collapsed[button.id] = not button.collapsed[button.id]
		self:Update()
	else
		if IsModifiedClick("SHIFT") then
			Internal.ActivateProfile({
				equipment = {button.id}
			});
		else
			self.Name:ClearFocus();
			self:ChangeSet(GetEquipmentSet(button.id))
		end
	end
end
function BtWLoadoutsEquipmentMixin:OnSidebarItemDoubleClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

	Internal.ActivateProfile({
		equipment = {button.id}
	});
end
function BtWLoadoutsEquipmentMixin:OnSidebarItemDragStart(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

	local icon = "INV_Misc_QuestionMark";
	local set = GetEquipmentSet(button.id);
	local command = format("/btwloadouts activate equipment %d", button.id);
	if set.managerID then
		icon = select(2, C_EquipmentSet.GetEquipmentSetInfo(set.managerID))
	end

	if command then
		local macroId;
		local numMacros = GetNumMacros();
		for i=1,numMacros do
			if GetMacroBody(i):trim() == command then
				macroId = i;
				break;
			end
		end

		if not macroId then
			if numMacros == MAX_ACCOUNT_MACROS then
				print(L["Cannot create any more macros"]);
				return;
			end
			if InCombatLockdown() then
				print(L["Cannot create macros while in combat"]);
				return;
			end

			macroId = CreateMacro(set.name, icon, command, false);
		else
			-- Rename the macro while not in combat
			if not InCombatLockdown() then
				icon = select(2,GetMacroInfo(macroId))
				EditMacro(macroId, set.name, icon, command)
			end
		end

		if macroId then
			PickupMacro(macroId);
		end
	end
end
function BtWLoadoutsEquipmentMixin:Update()
	self:GetParent():SetTitle(L["Equipment"]);
	local sidebar = BtWLoadoutsFrame.Sidebar

	sidebar:SetSupportedFilters("covenant", "spec", "class", "role", "race", "character")
	sidebar:SetSets(BtWLoadoutsSets.equipment)
	sidebar:SetCollapsed(BtWLoadoutsCollapsed.equipment)
	sidebar:SetCategories(BtWLoadoutsCategories.equipment)
	sidebar:SetFilters(BtWLoadoutsFilters.equipment)
	sidebar:SetSelected(self.set)

	sidebar:Update()
	self.set = sidebar:GetSelected()
	local set = self.set
	
	local showingNPE = BtWLoadoutsFrame:SetNPEShown(set == nil, L["Equipment"], L["Create gear sets or use the Blizzard equipment set manager."])

	self:GetParent().ExportButton:SetEnabled(false)
	
	if not showingNPE then
		UpdateSetFilters(set)
		sidebar:Update()
        
        set.restrictions = set.restrictions or {}
		self.RestrictionsButton:SetEnabled(true);
        self.RestrictionsDropDown:SetSelections(set.restrictions)
        self.RestrictionsDropDown:SetLimitations("character", set.character)

		local errors = CheckEquipmentSetForIssues(set)

		local character = set.character;
		local characterInfo = Internal.GetCharacterInfo(character);
		local equipment = set.equipment;

		local characterName, characterRealm = UnitFullName("player");
		local playerCharacter = characterRealm .. "-" .. characterName;

		-- Update the name for the built in equipment set, but only for the current player
		if set.character == playerCharacter and set.managerID then
			local managerName = C_EquipmentSet.GetEquipmentSetInfo(set.managerID);
			if managerName ~= set.name then
				C_EquipmentSet.ModifyEquipmentSet(set.managerID, set.name);
			end
		end

		if not self.Name:HasFocus() then
			self.Name:SetText(set.name or "");
		end
		self.Name:SetEnabled(set.managerID == nil or set.character == playerCharacter);

		local model = self.Model;
		if not characterInfo or character == playerCharacter or not model.SetCustomRace then
			model:SetUnit("player");
		else
			model:SetCustomRace(characterInfo.race, characterInfo.sex);
		end
		model:Undress();

		for _,item in pairs(self.Slots) do
			if equipment[item:GetID()] then
				model:TryOn(equipment[item:GetID()]);
			end

			item:Update();
			item:SetEnabled(character == playerCharacter and set.managerID == nil);
		end

		self:GetParent().RefreshButton:SetEnabled(set.character == GetCharacterSlug())
		self:GetParent().ActivateButton:SetEnabled(character == playerCharacter);
		self:GetParent().DeleteButton:SetEnabled(set.managerID == nil);

		local helpTipBox = self:GetParent().HelpTipBox;
		if character ~= playerCharacter then
			if not BtWLoadoutsHelpTipFlags["INVALID_PLAYER"] then
				helpTipBox.closeFlag = "INVALID_PLAYER";

				HelpTipBox_Anchor(helpTipBox, "TOP", self:GetParent().ActivateButton);

				helpTipBox:Show();
				HelpTipBox_SetText(helpTipBox, L["Can not equip sets for other characters."]);
			else
				helpTipBox.closeFlag = nil;
				helpTipBox:Hide();
			end
		elseif set.managerID ~= nil then
			if not BtWLoadoutsHelpTipFlags["EQUIPMENT_MANAGER_BLOCK"] then
				helpTipBox.closeFlag = "EQUIPMENT_MANAGER_BLOCK";

				HelpTipBox_Anchor(helpTipBox, "RIGHT", self.HeadSlot);

				helpTipBox:Show();
				HelpTipBox_SetText(helpTipBox, L["Can not edit equipment manager sets."]);
			else
				helpTipBox.closeFlag = nil;
				helpTipBox:Hide();
			end
		else
			if not BtWLoadoutsHelpTipFlags["EQUIPMENT_IGNORE"] then
				helpTipBox.closeFlag = "EQUIPMENT_IGNORE";

				HelpTipBox_Anchor(helpTipBox, "RIGHT", self.HeadSlot);

				helpTipBox:Show();
				HelpTipBox_SetText(helpTipBox, L["Shift+Left Mouse Button to ignore a slot."]);
			else
				helpTipBox.closeFlag = nil;
				helpTipBox:Hide();
			end
		end
	else
		local characterName = UnitFullName("player");
		self.Name:SetText(format(L["New %s Equipment Set"], characterName))

		local model = self.Model;
		model:SetUnit("player");

		for _,item in pairs(self.Slots) do
			item:Update()
		end

		local helpTipBox = self:GetParent().HelpTipBox;
		helpTipBox:Hide();
	end
end

-- Inventory item tracking
local GetSetsForLocation, GetEnabledSetsForLocation, GetLocationForItem, GetEnabledSetsForItem, GetEnabledSetsForItemID
do
	local itemLocation = ItemLocation:CreateEmpty(); -- Reusable item location, be careful not to double use it
	local possibleItems = {} -- Reused for storing lists of items

	--[[
		`itemData` == `itemLink`-azerite:::::
		`locationItems` is a map of `location` => `itemData`
		`locationSets` is a map of `location` => {"set:slot" => true}
	]]
	local locationItems = {}
	local locationSets = setmetatable({}, {
		__index = function (self, key)
			if type(key) == "number" then
				local result = {}
				self[key] = result
				return result
			end
		end
	})

	function AddSetToMapData(set)
		for slot=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
			if set.equipment[slot] then
				local location = set.locations[slot]
				if location and location <= 0 then
					location = nil
				end

				if location and location > 0 then
					local data = set.data[slot] and FixItemData(set.data[slot]) or EncodeItemData(set.equipment[slot], set.extras[slot] and set.extras[slot].azerite)

					if locationItems[location] == nil or locationItems[location] == data then
						locationItems[location] = locationItems[location] or data
						locationSets[location][(set.setID .. ":" .. slot)] = true
					else
						location = nil -- Somehow 2 equipment sets are expecting different items in the same slot
					end
				end

				set.locations[slot] = location
			end
		end
	end
	Internal.AddEquipmentSetToMapData = AddSetToMapData
	function RemoveSetFromMapData(set)
		for _,location in pairs(set.locations) do
			local sets = locationSets[location]
			if sets then
				for setLocation in pairs(sets) do
					local setID = tonumber((strsplit(":", setLocation)))
					if setID == set.setID then
						sets[setLocation] = nil
					end
				end

				if next(sets) == nil then
					locationItems[location] = nil
				end
			end
		end
	end
	Internal.RemoveEquipmentSetFromMapData = RemoveSetFromMapData
	function UpdateSetItemInMapData(set, inventorySlotId, oldLocation, newLocation, force)
		-- Remove it from the old location
		if oldLocation ~= nil then
			local sets = locationSets[oldLocation]
			for setLocation in pairs(sets) do
				if setLocation == (set.setID .. ":" .. inventorySlotId) then
					sets[setLocation] = nil
				end
			end
			if next(sets) == nil then
				locationItems[oldLocation] = nil
			end
		end

		-- Add it to the new location
		if newLocation ~= nil then
			local sets = locationSets[newLocation]
			local data = set.data[inventorySlotId]
			if locationItems[newLocation] == nil or locationItems[newLocation] == data then
				locationItems[newLocation] = locationItems[newLocation] or data
				locationSets[newLocation][(set.setID .. ":" .. inventorySlotId)] = true
			elseif force then
				locationItems[newLocation] = locationItems[newLocation] or data
				locationSets[newLocation][(set.setID .. ":" .. inventorySlotId)] = true
			else
				Internal.LogMessage(format("2 or more items have the same location but different data (setID: %d, slotID: %d) - %s ~= %s", set.setID, inventorySlotId, data or "nil", locationItems[newLocation] or "nil"))
			end
		end
	end
	Internal.UpdateEquipmentSetItemInMapData = UpdateSetItemInMapData

	--[[
		2 locations have had their items swap, update sets and data store with swapped locations
	]]
	local function SwapItems(fromLocation, toLocation)
		local fromSets, toSets = locationSets[fromLocation], locationSets[toLocation]

		-- Update the sets
		for setLocation in pairs(fromSets) do
			local setID, setSlot = strsplit(":", setLocation)
			setID, setSlot = tonumber(setID), tonumber(setSlot)

			local set = GetEquipmentSet(setID)
			assert(set)
			set.locations[setSlot] = toLocation
		end

		for setLocation in pairs(toSets) do
			local setID, setSlot = strsplit(":", setLocation)
			setID, setSlot = tonumber(setID), tonumber(setSlot)

			local set = GetEquipmentSet(setID)
			assert(set)
			set.locations[setSlot] = fromLocation
		end
		
		-- Swap the data store
		locationItems[fromLocation], locationItems[toLocation] = locationItems[toLocation], locationItems[fromLocation]
		locationSets[fromLocation], locationSets[toLocation] = toSets, fromSets
	end
	--[[
		Generic update funciton for when inventory items have been moved.
		Veryifies all items are correct and if not updates the data store with new locations
	]]
	local UpdateLocations, UpdateAllLocations
	do
		local newLocationItems = {}
		local newLocationSets = setmetatable({}, {
			__index = function (self, key)
				if type(key) == "number" then
					local result = {}
					self[key] = result
					return result
				end
			end
		})
		local missingItemDatas = {}
		local missingItemDatasLocationSets = {}

		local function UpdateLocation(newLocation)
			SetItemLocationFromLocation(itemLocation, newLocation)

			if not newLocationItems[newLocation] and itemLocation:IsValid() then
				local itemData = GetEncodedItemDataForItemLocation(itemLocation)
				if missingItemDatas[itemData] then
					local oldLocation = missingItemDatas[itemData]
					local delete = true
					if type(oldLocation) == "table" then
						if #oldLocation > 1 then
							delete = false
						end

						oldLocation = table.remove(oldLocation, 1)
					end

					if oldLocation == 0 then
						local sets = missingItemDatasLocationSets[itemData]
						for setLocation in pairs(sets) do
							local setId, slotId = strsplit(":", setLocation)
							setId, slotId = tonumber(setId), tonumber(slotId)
							local set = GetEquipmentSet(setId)
							assert(set)
							set.locations[slotId] = newLocation
						end

						newLocationItems[newLocation] = itemData
						newLocationSets[newLocation] = sets
					else
						local sets = locationSets[oldLocation]
						for setLocation in pairs(sets) do
							local setId, slotId = strsplit(":", setLocation)
							setId, slotId = tonumber(setId), tonumber(slotId)
							local set = GetEquipmentSet(setId)
							assert(set)
							set.locations[slotId] = newLocation
						end
	
						newLocationItems[newLocation] = locationItems[oldLocation]
						newLocationSets[newLocation] = locationSets[oldLocation]
					end
						
					if delete then
						missingItemDatas[itemData] = nil
					end
				end
			end
		end
		local function ScanDataMapForMissingItems(newLocationItems, newLocationSets, missingItemDatas)
			for location,expectedItemData in pairs(locationItems) do
				local actualItemData = GetEncodedItemDataForLocation(location)
				if actualItemData == expectedItemData then -- item is in location
					newLocationItems[location] = locationItems[location]
					newLocationSets[location] = locationSets[location]
				elseif missingItemDatas[expectedItemData] then
					local tbl = missingItemDatas[expectedItemData]
					if type(tbl) == "table" then
						tbl[#tbl+1] = location
					else
						missingItemDatas[expectedItemData] = {tbl, location}
					end
				else
					local foundInManager = false
					local sets = locationSets[location]
					for setLocation in pairs(sets) do
						local setID, setSlot = strsplit(":", setLocation)
						setID, setSlot = tonumber(setID), tonumber(setSlot)
						
						local set = GetEquipmentSet(setID)
						if set.managerID then
							-- Item is in blizzard manager set, they know the knew location
							local locations = C_EquipmentSet.GetItemLocations(set.managerID)
							
							if locations and locations[setSlot] and locations[setSlot] > -1 then
								newLocationItems[locations[setSlot]] = locationItems[location]
								newLocationSets[locations[setSlot]] = locationSets[location]

								-- Update the location for every set using this exact item
								local location = locations[setSlot]
								for setLocation in pairs(sets) do
									local setID, setSlot = strsplit(":", setLocation)
									setID, setSlot = tonumber(setID), tonumber(setSlot)
									
									local set = GetEquipmentSet(setID)
									set.locations[setSlot] = location
								end

								foundInManager = true
							end

							break
						end
					end

					if not foundInManager then
						missingItemDatas[expectedItemData] = location
					end
				end
			end
		end
		function UpdateLocations(inventorySlots, bags)
			wipe(newLocationItems)
			wipe(newLocationSets)
			wipe(missingItemDatas)

			ScanDataMapForMissingItems(newLocationItems, newLocationSets, missingItemDatas)

			if next(missingItemDatas) ~= nil then
				for inventorySlotId in pairs(inventorySlots) do
					if next(missingItemDatas) == nil then
						break
					end

					local newLocation = PackLocation(nil, inventorySlotId)
					UpdateLocation(newLocation)
				end
			end

			if next(missingItemDatas) ~= nil then
				for bagId in pairs(bags) do
					if next(missingItemDatas) == nil then
						break
					end

					for slotId=1,GetContainerNumSlots(bagId) do
						if next(missingItemDatas) == nil then
							break
						end

						local newLocation = PackLocation(bagId, slotId)
						UpdateLocation(newLocation)
					end
				end
			end

			locationItems, newLocationItems = newLocationItems, locationItems
			locationSets, newLocationSets = newLocationSets, locationSets
		end
		function UpdateAllLocations(skipInventory, skipBags, skipBank, includeMissingLocations)
			wipe(newLocationItems)
			wipe(newLocationSets)
			wipe(missingItemDatas)

			ScanDataMapForMissingItems(newLocationItems, newLocationSets, missingItemDatas)

			if includeMissingLocations then
				local character = GetCharacterSlug()
				for setID,set in pairs(BtWLoadoutsSets.equipment) do
					if type(set) == "table" and set.character == character and set.managerID == nil then
						for slot=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
							if set.equipment[slot] and set.locations[slot] == nil then
								local data = set.data[slot] or EncodeItemData(set.equipment[slot], set.extras[slot] and set.extras[slot].azerite)

								do
									local tbl = missingItemDatas[data]
									if type(tbl) == "table" then
										tbl[#tbl+1] = 0
									elseif tbl ~= nil then
										missingItemDatas[data] = {tbl, 0}
									else
										missingItemDatas[data] = 0
									end
								end
								
								do
									local tbl = missingItemDatasLocationSets[data] or {}
									tbl[(set.setID .. ":" .. slot)] = true
									missingItemDatasLocationSets[data] = tbl
								end
							end
						end
					end
				end
			end

			if not skipInventory and next(missingItemDatas) ~= nil then
				for inventorySlotId=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
					if next(missingItemDatas) == nil then
						break
					end

					local newLocation = PackLocation(nil, inventorySlotId)
					UpdateLocation(newLocation)
				end
			end

			if not skipBags and next(missingItemDatas) ~= nil then
				for bagId=BACKPACK_CONTAINER,NUM_BAG_SLOTS do
					if next(missingItemDatas) == nil then
						break
					end

					for slotId=1,GetContainerNumSlots(bagId) do
						if next(missingItemDatas) == nil then
							break
						end

						local newLocation = PackLocation(bagId, slotId)
						UpdateLocation(newLocation)
					end
				end
			end

			if not skipBank and next(missingItemDatas) ~= nil then
				for slotId=1,GetContainerNumSlots(BANK_CONTAINER) do
					if next(missingItemDatas) == nil then
						break
					end

					local newLocation = PackLocation(BANK_CONTAINER, slotId)
					UpdateLocation(newLocation)
				end
				
				for bagId=NUM_BAG_SLOTS+1,NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
					if next(missingItemDatas) == nil then
						break
					end

					for slotId=1,GetContainerNumSlots(bagId) do
						if next(missingItemDatas) == nil then
							break
						end

						local newLocation = PackLocation(bagId, slotId)
						UpdateLocation(newLocation)
					end
				end
			end

			for itemData,tbl in pairs(missingItemDatas) do
				if type(tbl) == "number" then
					tbl = {tbl}
				end
				for _,location in ipairs(tbl) do
					if location > 0 then
						local isInventory = bit.band(ITEM_INVENTORY_LOCATION_PLAYER, location) ~= 0 and bit.band(ITEM_INVENTORY_LOCATION_BAGS, location) == 0
						local isBags = bit.band(ITEM_INVENTORY_LOCATION_PLAYER, location) ~= 0 and bit.band(ITEM_INVENTORY_LOCATION_BAGS, location) ~= 0
						local isBank = bit.band(ITEM_INVENTORY_LOCATION_BANK, location) ~= 0
						if (skipInventory ~= isInventory) or (skipBags ~= isBags) or (skipBank ~= isBank) then
							for setLocation in pairs(locationSets[location]) do
								local setID, setSlot = strsplit(":", setLocation)
								setID, setSlot = tonumber(setID), tonumber(setSlot)
					
								local set = GetEquipmentSet(setID)
								assert(set)
								set.locations[setSlot] = nil
							end
						end
					end
				end
			end

			locationItems, newLocationItems = newLocationItems, locationItems
			locationSets, newLocationSets = newLocationSets, locationSets
		end
	end

	do -- Event handling for inventory changes
		local frame = CreateFrame("Frame")

		local changedBags = {}
		local changedInventorySlots = {}
		function frame:BAG_UPDATE(bagId)
			changedBags[bagId] = true
			self:Show()
		end
		function frame:PLAYERBANKSLOTS_CHANGED(slotId)
			changedInventorySlots[51 + slotId] = true
			self:Show()
		end
		function frame:PLAYER_EQUIPMENT_CHANGED(slotId)
			changedInventorySlots[slotId] = true
			self:Show()
		end
		function frame:OnEvent(event, ...)
			self[event](self, ...)
		end
		function frame:OnUpdate()
			self:Hide()
			UpdateLocations(changedInventorySlots, changedBags)
			wipe(changedBags)
			wipe(changedInventorySlots)
		end

		frame:SetScript("OnEvent", frame.OnEvent)
		frame:SetScript("OnUpdate", frame.OnUpdate)

		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		frame:Hide()
	end

	--[[
		Takes an itemLink and extra data with a list of item locations, returns the first location that matches the itemLink and extras
		Needs a better name
	]]
	local function GetItemFromLocations(itemLink, extras, locations)
		local itemID = GetItemInfoInstant(itemLink);
		for location,locationItemLink in pairs(locations) do
			if itemID == GetItemInfoInstant(locationItemLink) and IsItemInLocation(itemLink, extras, location) then
				return location
			end
		end
	end
	-- Populate item data maps from empty
	local function InitializeEquipmentTracking()
		local character = GetCharacterSlug()

		--[[
			It might be worth doing this in a few stages.

			First we loop through all the equipment sets and fill in `locationItems` and `locationSets`,
			verifying they have the item that we expect. If so the location is flagged as being in use
			We then loop through each item that isnt correct and look for the correct item. Flagging them
			as in use when found.
			
			Doing it this way means we dont cross-contaminate sets that have the same itemData but were
			actually different items in the inventory.
			We should probably take into account sets from the built in manager though. Those should always
			be correct and could maybe allow us to detect item movements while we were disabled.

			In the case of bank items we just leave them as is and let `InitializeBankItems` deal with it.
		]]
		for setID,set in pairs(BtWLoadoutsSets.equipment) do
			if type(set) == "table" and set.character == character then
				AddSetToMapData(set)
			end
		end

		UpdateAllLocations(false, false, true, true) -- Skip banks, check items without locations
	end
	-- Run when the bank is first opened, verifies items are where we expect them to be and if not updates locations with the correct place
	-- Also look for items with missing locations and check if they are in the bank
	local bankInitialized
	local function InitializeBankItems()
		if bankInitialized then
			return
		end
		bankInitialized = true

		local character = GetCharacterSlug()

		UpdateAllLocations(true, true, false, true) -- Skip inventory and bags, check items without locations
	end
	-- Gets the sets items are used for
	local temp = {}
	function GetSetsForLocation(location, result)
		result = result or {}

		local sets = locationSets[location]
		if sets then
			for setLocation in pairs(sets) do
				local setID = tonumber((strsplit(":", setLocation)))
				if not temp[setID] then
					local set = GetEquipmentSet(setID)
					for slot,targetLocation in pairs(set.locations) do
						if location == targetLocation and not set.ignored[slot] then
							result[#result+1] = set
							temp[setID] = true
							break
						end
					end
				end
			end
		end

		wipe(temp)

		table.sort(result, function (a, b)
			return a.name < b.name
		end)

		return result
	end
	function GetEnabledSetsForLocation(location, result)
		result = result or {}

		local sets = locationSets[location]
		if sets then
			for setLocation in pairs(sets) do
				local setID, setInventorySlotID = strsplit(":", setLocation)
				setID, setInventorySlotID = tonumber(setID), tonumber(setInventorySlotID)
				if not temp[setID] then
					local set = GetEquipmentSet(setID)
					if not set.disabled and not set.ignored[setInventorySlotID] then
						result[#result+1] = set
					end
					temp[setID] = true
				end
			end
		end

		wipe(temp)

		table.sort(result, function (a, b)
			return a.name < b.name
		end)

		return result
	end
	function GetLocationForItem(itemLink, extras)
		
	end
	function GetEnabledSetsForItemID(itemID, result)
		result = result or {}

		local character = GetCharacterSlug()
		local sets = BtWLoadoutsSets.equipment
		for _,set in pairs(sets) do
			if type(set) == "table" and set.character == character and not set.disabled then
				for slot=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
					if not set.ignored[slot] and set.equipment[slot] and GetItemInfoInstant(set.equipment[slot]) == itemID then
						result[#result+1] = set
						break;
					end
				end
			end
		end

		table.sort(result, function (a, b)
			return a.name < b.name
		end)

		return result
	end
	function GetEnabledSetsForItem(itemLink, result)
		if type(itemLink) == "number" then
			return GetEnabledSetsForItemID(itemLink, result)
		end

		result = result or {}

		local character = GetCharacterSlug()
		local sets = BtWLoadoutsSets.equipment
		for _,set in pairs(sets) do
			if type(set) == "table" and set.character == character and not set.disabled then
				for slot=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do
					if not set.ignored[slot] and set.equipments[slot] == itemLink then
						result[#result+1] = set
						break;
					end
				end
			end
		end

		table.sort(result, function (a, b)
			return a.name < b.name
		end)

		return result
	end

	--[[
		The item at the locations has been changed, for example, selecting azerite traits or upgrading legendary cloak
	]]
	local function UpdateItemAtLocation(location)
		local itemLink = GetItemLinkByLocation(location)
		if not itemLink or not IsEquippableItem(itemLink) then
			return
		end

		SetItemLocationFromLocation(itemLocation, location)
		
		local extras = GetExtrasForItemLocation(itemLocation)
		local itemData = EncodeItemData(itemLink, extras and extras.azerite)

		if itemData ~= locationItems[location] then -- Item has actually changed
			locationItems[location] = itemData

			local sets = locationSets[location]
			for setLocation in pairs(sets) do
				local setID, setSlot = strsplit(":", setLocation)
				setID, setSlot = tonumber(setID), tonumber(setSlot)

				local set = GetEquipmentSet(setID)
				set.data[setSlot] = itemData
				set.equipment[setSlot] = itemLink
				set.extras[setSlot] = extras
			end
		end
	end
	-- Triggered by the AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED event
	local function AzeriteItemUpdated(itemLocation)
		UpdateItemAtLocation(GetLocationFromItemLocation(itemLocation))
	end
	-- Triggered by the ITEM_CHANGED, followed by a BAG_UPDATE_DELAYED or UNIT_INVENTORY_CHANGED
	local function RuneforgeItemUpdated(previousHyperlink, newHyperlink)
		local previousItemData, newItemData = DeEnchantItemLink(previousHyperlink), DeEnchantItemLink(newHyperlink)
		for location,itemData in pairs(locationItems) do
			if DeEnchantItemLink(itemData) == previousItemData and DeEnchantItemLink(GetEncodedItemDataForLocation(location)) == newItemData then
				UpdateItemAtLocation(location)
				return
			end
		end
	end
	Internal.RuneforgeItemUpdated = RuneforgeItemUpdated
	local function SwapItemDataEnchantID(itemData, enchantID)
		local prefix, itemID, previousEnchantID, rest = strsplit(":", itemData, 4)
		return prefix .. ":" .. itemID .. ":" .. enchantID .. ":".. rest
	end
	-- Triggered by UNIT_SPELLCAST_SUCCESSFUL followed by a BAG_UPDATE_DELAYED or UNIT_INVENTORY_CHANGED,
	-- Searched through items looking for the one with the previous
	local function EnchantApplied(enchantID)
		for location,previousItemData in pairs(locationItems) do
			local currentItemData = GetEncodedItemDataForLocation(location)
			-- Items itemData has changed, the only change is the enchantID swapping to what we just cast
			if previousItemData ~= currentItemData and SwapItemDataEnchantID(previousItemData, enchantID) == currentItemData then
				UpdateItemAtLocation(location)
				break
			end
		end
	end
	Internal.EnchantApplied = EnchantApplied
	do -- Update items from socketing gems
		local function HasGem(itemLink)
			for i=1,3 do
				local itemLink = GetItemGem(itemLink, i)
				if itemLink then
					return true
				end
			end
			return false
		end

		local itemLocation = ItemLocation:CreateEmpty();
		local function GemApplied()
			if itemLocation:HasAnyLocation() and itemLocation:IsValid() then
				local itemLink = C_Item.GetItemLink(itemLocation)
				if itemLink and HasGem(itemLink) then
					UpdateItemAtLocation(GetLocationFromItemLocation(itemLocation))
					itemLocation:Clear()
				end
			end
		end
		local function hook_SocketInventoryItem(slotId)
			itemLocation:SetEquipmentSlot(slotId)
		end
		hooksecurefunc("SocketInventoryItem", hook_SocketInventoryItem)
		local function hook_SocketContainerItem(bagId, slotId)
			itemLocation:SetBagAndSlot(bagId, slotId)
		end
		if C_Container and C_Container.SocketContainerItem then
			hooksecurefunc(C_Container, "SocketContainerItem", hook_SocketContainerItem)
		else
			hooksecurefunc("SocketContainerItem", hook_SocketContainerItem)
		end
		Internal.GemApplied = GemApplied
	end
	do
		local dominationGems = {
			[187284] = true,
			[187295] = true,
			[187286] = true,
	
			[187287] = true,
			[187288] = true,
			[187289] = true,
			
			[187299] = true,
	
			[187308] = true,
			[187309] = true,
			[187310] = true,
		}
		local function IsDominationGem(itemLink)
			local itemID = GetItemInfoInstant(itemLink)
			return dominationGems[itemID] and true or false
		end
		local function HasDominationGem(itemLink)
			for i=1,3 do
				local itemLink = GetItemGem(itemLink, i)
				if itemLink and IsDominationGem(itemLink) then
					return true
				end
			end
			return false
		end

		local itemLocation = ItemLocation:CreateEmpty();
		local function hook_PickupInventoryItem(slotId)
			itemLocation:SetEquipmentSlot(slotId)
		end
		hooksecurefunc("PickupInventoryItem", hook_PickupInventoryItem)
		local function hook_UseContainerItem(bagId, slotId)
			itemLocation:SetBagAndSlot(bagId, slotId)
		end
		if C_Container and C_Container.UseContainerItem then
			hooksecurefunc(C_Container, "UseContainerItem", hook_UseContainerItem)
		else
			hooksecurefunc("UseContainerItem", hook_UseContainerItem)
		end
		
		local isRemovingDominationSocket = false
		function Internal.CastedSoulFireChisel()
			if itemLocation:HasAnyLocation() and itemLocation:IsValid() then
				local itemLink = C_Item.GetItemLink(itemLocation)
				if itemLink and HasDominationGem(itemLink) then
					isRemovingDominationSocket = true
					return true
				end
			end
		end
		function Internal.RemovedDominationGem()
			if isRemovingDominationSocket then
				if itemLocation:HasAnyLocation() and itemLocation:IsValid() then
					UpdateItemAtLocation(GetLocationFromItemLocation(itemLocation))
				end
				itemLocation:Clear()
				isRemovingDominationSocket = false
			end
		end
	end
	--[[@TODO
		Handle events for inventory items moving, there is a lot
		BAG_UPDATE, bagId - May fire multiple times, wait for BAG_UPDATE_DELAYED or maybe end of frame?
		BAG_UPDATE_DELAYED
		PLAYERBANKSLOTS_CHANGED, slotId - May fire multiple times per frame, way of end of frame?
		PLAYER_EQUIPMENT_CHANGED, slotId - May fire multiple times per frame, way of end of frame?

		All the ways to move items:
			Bag/Bank sort, fires BAG_UPDATE and PLAYERBANKSLOTS_CHANGED events
			Moving bags, fires BAG_UPDATE event
			Moving items within bank, fires PLAYERBANKSLOTS_CHANGED event
			Moving items within inventory, fires PLAYER_EQUIPMENT_CHANGED event
			Moving items between the previous 3, fires combinations of their events
			Right clicking item in inventory, fires BAG_UPDATE and PLAYER_EQUIPMENT_CHANGED
			Clicking item on actionbar, fires BAG_UPDATE and PLAYER_EQUIPMENT_CHANGED
			Trading, fires BAG_UPDATE and PLAYER_EQUIPMENT_CHANGED
			Equiping Manager set, fires EQUIPMENT_SWAP_FINISHED, but also BAG_UPDATE and PLAYER_EQUIPMENT_CHANGED

		React to equipment set changes
	]]

	Internal.BuildEquipmentMap = InitializeEquipmentTracking
	Internal.InitializeBankItems = InitializeBankItems
end

-- GameTooltip
if TooltipDataProcessor then
	local equipmentSetPattern = "^" .. string.gsub(EQUIPMENT_SETS, "%%s", "(.*)") .. "$"
	local itemCreatedPattern = "^" .. (ITEM_CREATED_BY:gsub("%%s", ".*")) .. "$"
	local durabilityPattern = "^" .. (DURABILITY_TEMPLATE:gsub("%%d", "%%d+"):gsub("%%%d%$d", "%%d+")) .. "$"

	local added = true
	TooltipDataProcessor.AddTooltipPreCall(Enum.TooltipDataType.Item, function (self, data)
		added = false
	end)

	local function GetEquipmentSetLine(processingInfo)
		local location = 0
		if processingInfo.getterName == "GetInventoryItem" then
			location = PackLocation(nil, processingInfo.getterArgs[2])
		elseif processingInfo.getterName == "GetBagItem" then
			location = PackLocation(unpack(processingInfo.getterArgs))
		end
		if location == 0 then
			return
		end

		local sets = GetSetsForLocation(location, {})
		if #sets == 0 then
			return
		end

		for index,set in ipairs(sets) do
			sets[index] = set.name
		end

		return string.format(EQUIPMENT_SETS, table.concat(sets, ", "))
	end

	TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function (self, lineData)
		if added then
			return
		end

		if lineData.leftText:match(equipmentSetPattern) then
			local sets = GetEquipmentSetLine(self.processingInfo)
			if sets then
				lineData.leftText = sets
				added = true
			end
		end
	end)

	local function AddEquipmentSetLine (self)
		if added then
			return
		end

		local tooltipData = self.processingInfo.tooltipData
		for _,line in ipairs(tooltipData.lines) do
			if line.leftText:match(equipmentSetPattern) then
				return -- Already has equipment set line
			end
		end

		local sets = GetEquipmentSetLine(self.processingInfo)
		if sets then
			self:AddLine(sets)
			added = true
		end
	end
	TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.SellPrice, AddEquipmentSetLine)
	TooltipDataProcessor.AddLinePostCall(Enum.TooltipDataLineType.None, function (self, lineData)
		local leftText = lineData.leftText
		if leftText == ITEM_SOCKETABLE or leftText == ITEM_ARTIFACT_VIEWABLE or leftText == ITEM_AZERITE_EMPOWERED_VIEWABLE or leftText == ITEM_AZERITE_ESSENCES_VIEWABLE or leftText:match(itemCreatedPattern) or leftText:match(durabilityPattern) then
			AddEquipmentSetLine(self)
		end
	end)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function (self, data)
		if not added then
			AddEquipmentSetLine(self)
		end
	end)
else
	local tooltipMatch = "^" .. string.gsub(EQUIPMENT_SETS, "%%s", "(.*)") .. "$"
	local tooltipSellMatch = "^" .. SELL_PRICE .. ": .*$"
	local location

	--[[
		Searches an item tooltip looking for important lines, like Equipment Sets, Sell Price and similar

		returns "Equipment Sets: ..." line number, last line number before equipment set line should be added, first line number after equipment set line should be added, any money frame that needs moving
	]]
	local equipmentSetPattern = "^" .. string.gsub(EQUIPMENT_SETS, "%%s", "(.*)") .. "$"
	local itemCreatedPattern = "^" .. (ITEM_CREATED_BY:gsub("%%s", ".*")) .. "$"
	local durabilityPattern = "^" .. (DURABILITY_TEMPLATE:gsub("%%d", "%%d+"):gsub("%%%d%$d", "%%d+")) .. "$"
	local sellPricePrefix = string.format("%s:", SELL_PRICE)
	local function GetTooltipLineNumbers(tooltip)
		local equipmentSetLine, beforeLine, afterLine, sellPriceFrameResult, sellPriceFrameXOffsetResult
		local tooltipName = tooltip:GetName()

		local sellPriceFrame, sellPriceFrameAnchor, sellPriceFrameXOffset, _
		if tooltip.shownMoneyFrames and tooltip.shownMoneyFrames >= 1 then
			for i=1,tooltip.shownMoneyFrames do
				local name = tooltipName.."MoneyFrame" .. i
				local moneyFrame = _G[name];
				
				if _G[name .. "PrefixText"]:GetText() == sellPricePrefix then
					sellPriceFrame = moneyFrame
					if sellPriceFrame.GetPointByName then
						_, sellPriceFrameAnchor, _, sellPriceFrameXOffset = sellPriceFrame:GetPointByName("LEFT")
					else
						_, sellPriceFrameAnchor, _, sellPriceFrameXOffset = sellPriceFrame:GetPoint("LEFT")
					end
					break
				end
			end
		end

		for i=1,tooltip:NumLines() do
			local left, right = _G[tooltipName .. "TextLeft" .. i], _G[tooltipName .. "TextRight" .. i]
			local leftText = left:GetText()
			if leftText then
				if leftText:match(equipmentSetPattern) then
					equipmentSetLine = i
					break
				elseif leftText == ITEM_SOCKETABLE or leftText == ITEM_ARTIFACT_VIEWABLE or leftText == ITEM_AZERITE_EMPOWERED_VIEWABLE or leftText == ITEM_AZERITE_ESSENCES_VIEWABLE or leftText:match(itemCreatedPattern) or leftText:match(durabilityPattern) then
					beforeLine = i
				elseif left == sellPriceFrameAnchor then
					afterLine = i
					sellPriceFrameResult, sellPriceFrameXOffsetResult = sellPriceFrame, sellPriceFrameXOffset
				elseif leftText == ITEM_UNSELLABLE then
					afterLine = i
				end
			end
		end
		if beforeLine and not afterLine then
			afterLine = beforeLine + 1
		end
		return equipmentSetLine, beforeLine, afterLine, sellPriceFrameResult, sellPriceFrameXOffsetResult
	end

	local function UpdateTooltip(self, location)
		local sets = GetSetsForLocation(location, {})
		if #sets == 0 then
			return
		end

		for index,set in ipairs(sets) do
			sets[index] = set.name
		end

		sets = string.format(EQUIPMENT_SETS, table.concat(sets, ", "))

		local tooltipName = self:GetName()
		local equipmentSetLine, beforeLine, afterLine, sellPriceFrame, sellPriceFrameXOffset = GetTooltipLineNumbers(self)
		if equipmentSetLine then
			_G[tooltipName .. "TextLeft" .. equipmentSetLine]:SetText(sets)
		elseif afterLine and afterLine < self:NumLines() then
			local left, right = _G[tooltipName .. "TextLeft" .. self:NumLines()], _G[tooltipName .. "TextRight" .. self:NumLines()]
			local leftText, leftR, leftG, leftB  = left:GetText(), left:GetTextColor()
			local rightText, rightR, rightG, rightB = right:GetText(), right:GetTextColor()

			self:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB)

			for i=self:NumLines()-1,afterLine,-1 do
				local left, right = _G[tooltipName .. "TextLeft" .. (i - 1)], _G[tooltipName .. "TextRight" .. (i - 1)]
				local leftNext, rightNext = _G[tooltipName .. "TextLeft" .. i], _G[tooltipName .. "TextRight" .. i]
				
				leftNext:SetTextColor(left:GetTextColor())
				leftNext:SetText(left:GetText())
				leftNext:SetShown(left:IsShown())
				rightNext:SetTextColor(right:GetTextColor())
				rightNext:SetText(right:GetText())
				rightNext:SetShown(right:IsShown())
			end

			left, right = _G[tooltipName .. "TextLeft" .. afterLine], _G[tooltipName .. "TextRight" .. afterLine]
			left:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
			left:SetText(sets)
			right:SetText("")

			if sellPriceFrame then
				sellPriceFrame:ClearAllPoints()
				sellPriceFrame:SetPoint("LEFT", _G[tooltipName .. "TextLeft" .. (afterLine + 1)], "LEFT", sellPriceFrameXOffset, 0);
			end
		else
			self:AddLine(sets)
		end

		self:Show()
	end
	-- GameTooltip:HookScript("OnTooltipSetItem", function (self, ...)
	-- 	if location then

	-- 	end
	-- end)
	hooksecurefunc(GameTooltip, "SetInventoryItem", function (self, unit, slot, nameOnly)
		if not nameOnly and unit == "player" then
			location = PackLocation(nil, slot)
			UpdateTooltip(self, location)
		else
			location = nil
		end
	end)
	hooksecurefunc(GameTooltip, "SetBagItem", function (self, bag, slot)
		location = PackLocation(bag, slot)
		UpdateTooltip(self, location)
	end)
	hooksecurefunc(ItemRefTooltip, "SetInventoryItem", function (self, unit, slot, nameOnly)
		if not nameOnly and unit == "player" then
			location = PackLocation(nil, slot)
			UpdateTooltip(self, location)
		else
			location = nil
		end
	end)
	hooksecurefunc(ItemRefTooltip, "SetBagItem", function (self, bag, slot)
		location = PackLocation(bag, slot)
		UpdateTooltip(self, location)
	end)
end

-- Adibags
if LibStub and LibStub:GetLibrary("AceAddon-3.0", true) then
	local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags", true)

	if AdiBags then
		local setFilter = AdiBags:RegisterFilter("BtWLoadouts", 94, "ABEvent-1.0")
		setFilter.uiName = L["BtWLoadouts"]
		setFilter.uiDesc = L["BtWLoadouts."]
		
		function setFilter:Update()
			self:SendMessage("AdiBags_FiltersChanged")
		end
		
		function setFilter:OnEnable()
			AdiBags:UpdateFilters()
		end
		
		function setFilter:OnDisable()
			AdiBags:UpdateFilters()
		end
		
		function setFilter:Filter(slotData)
			local location = PackLocation(slotData.bag, slotData.slot)
			local sets = {}
			local set = GetEnabledSetsForLocation(location, sets)[1]
			if set then
				return format(L["Set: %s"], set.name), L["Equipment"]
			end
		end
	end
end

-- LibItemSearch, used by Bagnon to display borders around items within equipment sets
if LibStub and LibStub:GetLibrary("LibItemSearch-1.2", true) then
	local Lib = LibStub("LibItemSearch-1.2")
	local Search = LibStub('CustomSearch-1.0')

	-- I dont really like replacing this, maybe there is a better solution?
	function Lib:BelongsToSet(id, search)
		local result = GetEnabledSetsForItemID(id)
		for _,set in ipairs(result) do
			if Search:Find(search, set.name) then
				return true
			end
		end
	end
end

-- Character deletion
Internal.OnEvent("CharacterDeleted", function (event, slug)
	local sets = GetSetsForCharacter({}, slug)
	for _,set in ipairs(sets) do
		DeleteEquipmentSet(set.setID)
	end
end)
