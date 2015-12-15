--[[
	Until Blizzard adds an easier solution, this function can be used to get the true upgraded itemLevel.
	The Lua file is easily portable between addons. The function is placed in the global namespace.
	Syntax:
		GetUpgradedItemLevelFromItemLink(itemLink)
		= (number) return value is the modified itemLevel based on the item's upgrade
		= (nil) invalid input
	Changelog:
	* REV-08 (15.09.08) Patch 6.2.3:	Added patterns, tables, etc for Timewarped and Timewarped Warforged items to work. (Cidrei)
	* REV-07 (15.07.02) Patch 6.2:		A new field in the item string was added "specializationID", pushing the "upgradeId" field to the 11th place.
	* REV-06 (14.10.15) Patch 6.0.2:	Updated the pattern match for "upgradeId" to work for WoD.
	* REV-05 (14.05.24) Patch 5.4.8:	Added IDs 504 to 507.
	* REV-04 (13.09.21) Patch 5.4:		Added IDs 491 to 498 to the table.
	* REV-03 (13.05.22) Patch 5.3:		Added the 465/466/467 IDs (0/4/8 lvls) to the table.
	* REV-02 (13.xx.xx) Patch 5.2:		Added the 470 ID (8 lvls) to the table.
--]]

-- Make sure we do not override a newer revision. NOTE: Make sure to ALWAYS increase the REVISION number when changing code
local REVISION = 8;
if (type(GET_UPGRADED_ITEM_LEVEL_REV) == "number") and (GET_UPGRADED_ITEM_LEVEL_REV >= REVISION) then
	return;
end
GET_UPGRADED_ITEM_LEVEL_REV = REVISION;

--[[
	[Item links data change in 6.0, WoD]
		itemID:enchant:gem1:gem2:gem3:gem4:suffixID:uniqueID:level:reforgeId:upgradeId
		itemID:enchant:gem1:gem2:gem3:gem4:suffixID:uniqueID:level:upgradeId:instanceDifficultyID:numBonusIDs:bonusID1:bonusID2
	[ItemLinks in 6.2 -- Added: 10th param, specializationID]
		itemID:enchant:gem1:gem2:gem3:gem4:suffixID:uniqueID:level:specializationID:upgradeId:instanceDifficultyID:numBonusIDs:bonusID1:bonusID2
	[ItemLinks in 6.2.x -- Added: numBonusIDs? -- The number of bonus IDs are now dynamic, the 13th parameter tells how many there are -- Total Count (???): 14 + numBonusIDs (???)]
		itemID:enchant:gemID1:gemID2:gemID3:gemID4:suffixID:uniqueID:linkLevel:specializationID:upgradeTypeID:instanceDifficultyID:numBonusIDs:bonusID1:bonusID2:...:upgradeID
--]]

-- Extraction pattern for the complete itemLink, including all its properties
local ITEMLINK_PATTERN = "(item:[^|]+)";
-- Matches the 11th property, upgradeId, of an itemLink. This pattern now scans from the start of the itemLink to make it future-proof with further property additions to itemLinks.
local ITEMLINK_PATTERN_UPGRADE = "item:"..("[^:]+:"):rep(10).."(%d+)";
-- Matches the 14th property, which is used for Timewarped items.
local ITEMLINK_PATTERN_TIMEWARP = "item:"..("[^:]+:"):rep(13).."(%d+)";
-- Matches the 15th property, which is used for Timewarped Warforged items.
local ITEMLINK_PATTERN_TWWF = "item:"..("[^:]+:"):rep(14).."(%d+)";

-- Table for adjustment of levels due to upgrade -- Source: http://www.wowinterface.com/forums/showthread.php?t=45388
local UPGRADED_LEVEL_ADJUST = {
	[001] = 8, -- 1/1
	-- Patch 5.1 --
	[373] = 4, -- 1/2
	[374] = 8, -- 2/2
	[375] = 4, -- 1/3
	[376] = 4, -- 2/3
	[377] = 4, -- 3/3
	[379] = 4, -- 1/2
	[380] = 4, -- 2/2
--	[445] = 0, -- 0/2
	[446] = 4, -- 1/2
	[447] = 8, -- 2/2
--	[451] = 0, -- 0/1
	[452] = 8, -- 1/1
--	[453] = 0, -- 0/2
	[454] = 4, -- 1/2
	[455] = 8, -- 2/2
--	[456] = 0, -- 0/1
	[457] = 8, -- 1/1
--	[458] = 0, -- 0/4
	[459] = 4, -- 1/4
	[460] = 8, -- 2/4
	[461] = 12, -- 3/4
	[462] = 16, -- 4/4
	-- Patch 5.3 --
--	[465] = 0,
	[466] = 4,
	[467] = 8,
	-- Patch ?? --
--	[468] = 0,
	[469] = 4,
	[470] = 8,
	[471] = 12,
	[472] = 16,
	-- Patch 5.4 --
--	[491] = 0,
	[492] = 4,
	[493] = 8,
--	[494] = 0,
	[495] = 4,
	[496] = 8,
	[497] = 12,
	[498] = 16,
	-- Patch 5.4.8 --
	[504] = 12,	-- US/EU upgrade 3/4
	[505] = 16,	-- US/EU upgrade 4/4
	[506] = 20,	-- Asia upgrade 5/6
	[507] = 24,	-- Asis upgrade 6/6
	-- Patch 6.2.3 --
	[530] = 5,	-- WoD upgrade 1/2
	[531] = 10,	-- WoD upgrade 2/2
};

-- Table for adjustment of levels due to Timewarped. These are fixed itemLevels, not upgrade amounts.
local TIMEWARPED_LEVEL_ADJUST = {
	-- Patch 6.2 --
	[615] = 660, -- Dungeon drops.
	[692] = 675, -- Timewarped badge vendors.
};

-- Table for adjustment of levels due to Timewarped Warforged. These are fixed itemLevels, not upgrade amounts.
local TIMEWARPED_WARFORGED_LEVEL_ADJUST = {
	-- Patch 6.2 --
	[656] = 675, -- Dungeon drops.
};

-- Analyses the itemLink and checks for upgrades that affects itemLevel -- Only itemLevel 450 and above will have this
function GetUpgradedItemLevelFromItemLink(itemLink)
	-- Ensure we only have the raw itemLink, and not the full itemString
	itemLink = itemLink:match(ITEMLINK_PATTERN);
	local _, _, _, itemLevel = GetItemInfo(itemLink);
	local upgradeId = tonumber(itemLink:match(ITEMLINK_PATTERN_UPGRADE));
	local tw = tonumber(itemLink:match(ITEMLINK_PATTERN_TIMEWARP));
	local twwf = tonumber(itemLink:match(ITEMLINK_PATTERN_TWWF));
	-- Return the actual itemLevel based on the itemLink properties
	if not (itemLevel) then
		return nil;
	elseif (itemLevel >= 450) and (upgradeId) and (UPGRADED_LEVEL_ADJUST[upgradeId]) then
		return itemLevel + UPGRADED_LEVEL_ADJUST[upgradeId];
	elseif (TIMEWARPED_WARFORGED_LEVEL_ADJUST[twwf]) then
		return TIMEWARPED_WARFORGED_LEVEL_ADJUST[twwf];
	elseif (TIMEWARPED_LEVEL_ADJUST[tw]) then
		return TIMEWARPED_LEVEL_ADJUST[tw];
	else
		return itemLevel;
	end
end