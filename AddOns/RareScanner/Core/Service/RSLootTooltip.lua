-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local RSLootTooltip = private.NewLib("RareScannerLootTooltip")

-- Locales
local AL = LibStub("AceLocale-3.0"):GetLocale("RareScanner");

-- RareScanner database libraries
local RSConfigDB = private.ImportLib("RareScannerConfigDB")
local RSCollectionsDB = private.ImportLib("RareScannerCollectionsDB")

-- RareScanner general libraries
local RSConstants = private.ImportLib("RareScannerConstants")
local RSUtils = private.ImportLib("RareScannerUtils")
local RSLogger = private.ImportLib("RareScannerLogger")
local RSTooltipScanners = private.ImportLib("RareScannerTooltipScanners")

---============================================================================
-- Handle item events
---============================================================================

function RSLootTooltip.HandleInputEvents(button, itemLink, itemClassID, itemSubClassID, itemID)
	if (button == "LeftButton" and IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown()) then
		DressUpItemLink(itemLink)
		DressUpBattlePetLink(itemLink)
		DressUpMountLink(itemLink)
	-- Filter by category
	elseif (button == "LeftButton" and not IsControlKeyDown() and IsAltKeyDown() and IsShiftKeyDown()) then
		if (RSConfigDB.GetLootFilterByCategory(itemClassID, itemSubClassID)) then
			RSConfigDB.SetLootFilterByCategory(itemClassID, itemSubClassID, false)
			RSLogger:PrintMessage(string.format(AL["LOOT_CATEGORY_FILTERED"], GetItemClassInfo(itemClassID), GetItemSubClassInfo(itemClassID, itemSubClassID)))
		else
			RSConfigDB.SetLootFilterByCategory(itemClassID, itemSubClassID, true)
			RSLogger:PrintMessage(string.format(AL["LOOT_CATEGORY_NOT_FILTERED"], GetItemClassInfo(itemClassID), GetItemSubClassInfo(itemClassID, itemSubClassID)))
		end
	-- Individual filter
	elseif (button == "RightButton" and not IsControlKeyDown() and IsAltKeyDown() and not IsShiftKeyDown()) then
		if (not RSConfigDB.GetItemFiltered(itemID)) then
			RSConfigDB.SetItemFiltered(itemID, true)
			RSLogger:PrintMessage(string.format(AL["LOOT_INDIVIDUAL_FILTERED"], itemLink))
		else
			RSConfigDB.SetItemFiltered(itemID, false)
			RSLogger:PrintMessage(string.format(AL["LOOT_INDIVIDUAL_NOT_FILTERED"], itemLink))
		end
		-- Refresh options panel (if its being initialized)
		if (private.loadFilteredItems) then
			private.loadFilteredItems()
		end
	end
end

---============================================================================
-- Adds extra information to loot tooltips
---============================================================================

function RSLootTooltip.AddRareScannerInformation(tooltip, itemLink, itemID, itemClassID, itemSubClassID)
	-- Adds transmog unknown appearance message if the game doesnt add it
	if (not RSTooltipScanners.ScanLoot(itemLink, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN) and RSCollectionsDB.IsNotcollectedAppearance(itemID)) then
		GameTooltip_AddColoredLine(tooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN, LIGHTBLUE_FONT_COLOR);
	end

	-- Adds commands	
	if (itemClassID and itemSubClassID and RSConfigDB.IsShowingLootTooltipsCommands()) then
		tooltip:AddLine(" ")
		tooltip:AddLine("|TInterface\\AddOns\\RareScanner\\Media\\Textures\\tooltip_shortcuts:18:60:::256:256:0:96:0:32|t "..RSUtils.TextColor(string.format(AL["LOOT_TOGGLE_FILTER"], GetItemClassInfo(itemClassID), GetItemSubClassInfo(itemClassID, itemSubClassID)), "00FF00"))
		tooltip:AddLine("|TInterface\\AddOns\\RareScanner\\Media\\Textures\\tooltip_shortcuts:18:60:::256:256:0:96:128:160|t "..RSUtils.TextColor(AL["LOOT_TOGGLE_INDIVIDUAL_FILTER"], "FFFF00"))
	end
	
	-- Adds covenant requirement
	if (RSConfigDB.IsShowingCovenantRequirement()) then
		if (RSUtils.Contains(RSConstants.ITEMS_REQUIRE_NECROLORD, itemID)) then
			tooltip:AddLine(string.format(AL["LOOT_COVENANT_REQUIREMENT"], AL["NOTE_NECROLORDS"]), 0.3,0.7,0.2)
		elseif (RSUtils.Contains(RSConstants.ITEMS_REQUIRE_NIGHT_FAE, itemID)) then
			tooltip:AddLine(string.format(AL["LOOT_COVENANT_REQUIREMENT"], AL["NOTE_NIGHT_FAE"]), 0.6,0.2,0.7)
		elseif (RSUtils.Contains(RSConstants.ITEMS_REQUIRE_VENTHYR, itemID)) then
			tooltip:AddLine(string.format(AL["LOOT_COVENANT_REQUIREMENT"], AL["NOTE_VENTHYR"]), 0.7,0,0)
		elseif (RSUtils.Contains(RSConstants.ITEMS_REQUIRE_KYRIAN, itemID)) then
			tooltip:AddLine(string.format(AL["LOOT_COVENANT_REQUIREMENT"], AL["NOTE_KYRIAN"]), 0,0.7,1)
		end
	end
	
	-- Adds DEBUG information
	if (RSConstants.DEBUG_MODE) then
		tooltip:AddLine(itemID, 1,1,0)
	end
	
	-- Other addons support
	if (CanIMogIt and RSConfigDB.IsShowingLootCanimogitTooltip()) then
		tooltip:AddLine(CanIMogIt:GetTooltipText(itemLink))
	end
end