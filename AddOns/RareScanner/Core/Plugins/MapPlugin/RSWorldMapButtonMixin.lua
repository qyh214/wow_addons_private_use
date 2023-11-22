-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local LibStub = _G.LibStub
local ADDON_NAME, private = ...

-- RareScanner libraries
local RSConstants = private.ImportLib("RareScannerConstants")

-- RareScanner database libraries
local RSConfigDB = private.ImportLib("RareScannerConfigDB")

-- RareScanner service libraries
local RSMinimap = private.ImportLib("RareScannerMinimap")

-- Locales
local AL = LibStub("AceLocale-3.0"):GetLocale("RareScanner");

-- Thirdparty
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

-- Constants
local SHOW_RARE_NPC_ICONS = "rsHideRareNpcs"
local SHOW_DEAD_RARE_NPC_ICONS = "rsHideDeadRareNpcs"
local SHOW_NOT_DISCOVERED_RARE_NPC_ICONS = "rsHideNotDiscoveredRareNpcs"
local SHOW_FRIENDLY_RARE_NPC_ICONS = "rsHideFriendlyRareNpcs"
local SHOW_ACHIEVEMENT_NPC_ICONS = "rsHideAchievementRareNpcs"
local SHOW_PROFESSION_NPC_ICONS = "rsHideProfessionRareNPCs"
local SHOW_HUNTING_PARTY_NPC_ICONS = "rsHideHuntingPartyRareNpcs"
local SHOW_PRIMAL_STORM_NPC_ICONS = "rsHidePrimalStormRareNpcs"
local SHOW_DREAMSURGE_NPC_ICONS = "rsHideDreamsurgeRareNpcs"
local SHOW_FYRAKK_NPC_ICONS = "rsHideFyrakkRareNpcs"
local SHOW_OTHER_NPC_ICONS = "rsHideOtherRareNpcs"
local DISABLE_LAST_SEEN_FILTER = "rsDisableLastSeenFilter"

local SHOW_CONTAINER_ICONS = "rsHideContainers"
local SHOW_OPEN_CONTAINER_ICONS = "rsHideOpenContainers"
local SHOW_NOT_DISCOVERED_CONTAINER_ICONS = "rsHideNotDiscoveredContainers"
local SHOW_NOT_TRACKEABLE_CONTAINER_ICONS = "rsHideNotTrackeableContainers"
local SHOW_ACHIEVEMENT_CONTAINER_ICONS = "rsHideAchievementContainers"
local SHOW_PROFESSION_CONTAINER_ICONS = "rsHideProfessionContainers"
local SHOW_OTHER_CONTAINER_ICONS = "rsHideOtherContainers"
local SHOW_WARCRAFT_RUMBLE_CONTAINER_ICONS = "rsHideWarcraftRumbleContainers"
local SHOW_DREAMSEED_CONTAINER_ICONS = "rsHideDreamseedContainers"
local DISABLE_LAST_SEEN_CONTAINER_FILTER = "rsDisableLastSeenContainerFilter"

local SHOW_EVENT_ICONS = "rsHideEvents"
local SHOW_COMPLETED_EVENT_ICONS = "rsHideCompletedEvents"
local SHOW_NOT_DISCOVERED_EVENT_ICONS = "rsHideNotDiscoveredEvents"
local DISABLE_LAST_SEEN_EVENT_FILTER = "rsDisableLastSeenEventFilter"

local SHOW_DRAGON_GLYPHS_ICONS = "rsHideDragonGlyphs"

local SHOW_NOT_DISCOVERED_ICONS_OLD = "rsHideNotDiscoveredOld"


RSWorldMapButtonMixin = { }

local rareNPCsID = 1
local containersID = 2
local eventsID = 3
local othersID = 4

local function WorldMapButtonDropDownMenu_Initialize(dropDown)
	local OnSelection = function(self, value)
	
		-- Rare NPCs (general)
		if (value == SHOW_RARE_NPC_ICONS) then
			if (RSConfigDB.IsShowingNpcs()) then
				RSConfigDB.SetShowingNpcs(false)
			else
				RSConfigDB.SetShowingNpcs(true)
			end
			LibDD:UIDropDownMenu_Initialize(dropDown)
		elseif (value == DISABLE_LAST_SEEN_FILTER) then
			if (RSConfigDB.IsMaxSeenTimeFilterEnabled()) then
				RSConfigDB.DisableMaxSeenTimeFilter()
			else
				RSConfigDB.EnableMaxSeenTimeFilter()
			end
		elseif (value == SHOW_DEAD_RARE_NPC_ICONS) then
			if (RSConfigDB.IsShowingAlreadyKilledNpcs()) then
				RSConfigDB.SetShowingAlreadyKilledNpcs(false)
			else
				RSConfigDB.SetShowingAlreadyKilledNpcs(true)
			end
		elseif (value == SHOW_NOT_DISCOVERED_RARE_NPC_ICONS) then
			if (RSConfigDB.IsShowingNotDiscoveredNpcs()) then
				RSConfigDB.SetShowingNotDiscoveredNpcs(false)
			else
				RSConfigDB.SetShowingNotDiscoveredNpcs(true)
			end
		elseif (value == SHOW_FRIENDLY_RARE_NPC_ICONS) then
			if (RSConfigDB.IsShowingFriendlyNpcs()) then
				RSConfigDB.SetShowingFriendlyNpcs(false)
			else
				RSConfigDB.SetShowingFriendlyNpcs(true)
			end
		
		-- Rare NPCs (types)
		elseif (value == SHOW_HUNTING_PARTY_NPC_ICONS) then
			if (RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT)) then
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT, false)
			else
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT, true)
			end
		elseif (value == SHOW_ACHIEVEMENT_NPC_ICONS) then
			if (RSConfigDB.IsShowingAchievementRareNPCs()) then
				RSConfigDB.SetShowingAchievementRareNPCs(false)
			else
				RSConfigDB.SetShowingAchievementRareNPCs(true)
			end
		elseif (value == SHOW_PROFESSION_NPC_ICONS) then
			if (RSConfigDB.IsShowingProfessionRareNPCs()) then
				RSConfigDB.SetShowingProfessionRareNPCs(false)
			else
				RSConfigDB.SetShowingProfessionRareNPCs(true)
			end
		elseif (value == SHOW_PRIMAL_STORM_NPC_ICONS) then
			if (RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_FIRE_MINIEVENT) and RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_WATER_MINIEVENT) and RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_EARTH_MINIEVENT) and RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_AIR_MINIEVENT)) then
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_FIRE_MINIEVENT, false)
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_WATER_MINIEVENT, false)
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_EARTH_MINIEVENT, false)
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_AIR_MINIEVENT, false)
			else
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_FIRE_MINIEVENT, true)
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_WATER_MINIEVENT, true)
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_EARTH_MINIEVENT, true)
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_AIR_MINIEVENT, true)
			end
		elseif (value == SHOW_DREAMSURGE_NPC_ICONS) then
			if (RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSURGE_MINIEVENT)) then
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSURGE_MINIEVENT, false)
			else
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSURGE_MINIEVENT, true)
			end
		elseif (value == SHOW_FYRAKK_NPC_ICONS) then
			if (RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT)) then
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT, false)
			else
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT, true)
			end
		elseif (value == SHOW_OTHER_NPC_ICONS) then
			if (RSConfigDB.IsShowingOtherRareNPCs()) then
				RSConfigDB.SetShowingOtherRareNPCs(false)
			else
				RSConfigDB.SetShowingOtherRareNPCs(true)
			end
			
		-- Containers (general)
		elseif (value == SHOW_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingContainers()) then
				RSConfigDB.SetShowingContainers(false)
			else
				RSConfigDB.SetShowingContainers(true)
			end
			LibDD:UIDropDownMenu_Initialize(dropDown)
		elseif (value == DISABLE_LAST_SEEN_CONTAINER_FILTER) then
			if (RSConfigDB.IsMaxSeenTimeContainerFilterEnabled()) then
				RSConfigDB.DisableMaxSeenContainerTimeFilter()
			else
				RSConfigDB.EnableMaxSeenContainerTimeFilter()
			end
		elseif (value == SHOW_OPEN_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingAlreadyOpenedContainers()) then
				RSConfigDB.SetShowingAlreadyOpenedContainers(false)
			else
				RSConfigDB.SetShowingAlreadyOpenedContainers(true)
			end
		elseif (value == SHOW_NOT_DISCOVERED_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingNotDiscoveredContainers()) then
				RSConfigDB.SetShowingNotDiscoveredContainers(false)
			else
				RSConfigDB.SetShowingNotDiscoveredContainers(true)
			end
			
		-- Containers (types)
		elseif (value == SHOW_ACHIEVEMENT_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingAchievementContainers()) then
				RSConfigDB.SetShowingAchievementContainers(false)
			else
				RSConfigDB.SetShowingAchievementContainers(true)
			end
		elseif (value == SHOW_PROFESSION_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingProfessionContainers()) then
				RSConfigDB.SetShowingProfessionContainers(false)
			else
				RSConfigDB.SetShowingProfessionContainers(true)
			end
		elseif (value == SHOW_NOT_TRACKEABLE_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingNotTrackeableContainers()) then
				RSConfigDB.SetShowingNotTrackeableContainers(false)
			else
				RSConfigDB.SetShowingNotTrackeableContainers(true)
			end
		elseif (value == SHOW_WARCRAFT_RUMBLE_CONTAINER_ICONS) then
			if (RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_WARCRAFT_RUMBLE_MINIEVENT)) then
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_WARCRAFT_RUMBLE_MINIEVENT, false)
			else
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_WARCRAFT_RUMBLE_MINIEVENT, true)
			end
		elseif (value == SHOW_DREAMSEED_CONTAINER_ICONS) then
			if (RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSEED_MINIEVENT)) then
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSEED_MINIEVENT, false)
			else
				RSConfigDB.SetMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSEED_MINIEVENT, true)
			end
		elseif (value == SHOW_OTHER_CONTAINER_ICONS) then
			if (RSConfigDB.IsShowingOtherContainers()) then
				RSConfigDB.SetShowingOtherContainers(false)
			else
				RSConfigDB.SetShowingOtherContainers(true)
			end
		
		-- Events
		elseif (value == SHOW_EVENT_ICONS) then
			if (RSConfigDB.IsShowingEvents()) then
				RSConfigDB.SetShowingEvents(false)
			else
				RSConfigDB.SetShowingEvents(true)
			end
			LibDD:UIDropDownMenu_Initialize(dropDown)
		elseif (value == DISABLE_LAST_SEEN_EVENT_FILTER) then
			if (RSConfigDB.IsMaxSeenTimeEventFilterEnabled()) then
				RSConfigDB.DisableMaxSeenEventTimeFilter()
			else
				RSConfigDB.EnableMaxSeenEventTimeFilter()
			end
		elseif (value == SHOW_COMPLETED_EVENT_ICONS) then
			if (RSConfigDB.IsShowingCompletedEvents()) then
				RSConfigDB.SetShowingCompletedEvents(false)
			else
				RSConfigDB.SetShowingCompletedEvents(true)
			end
		elseif (value == SHOW_NOT_DISCOVERED_EVENT_ICONS) then
			if (RSConfigDB.IsShowingNotDiscoveredEvents()) then
				RSConfigDB.SetShowingNotDiscoveredEvents(false)
			else
				RSConfigDB.SetShowingNotDiscoveredEvents(true)
			end
		
		-- Dragon glyphs
		elseif (value == SHOW_DRAGON_GLYPHS_ICONS) then
			if (RSConfigDB.IsShowingDragonGlyphs()) then
				RSConfigDB.SetShowingDragonGlyphs(false)
			else
				RSConfigDB.SetShowingDragonGlyphs(true)
			end
			
		-- Not discovered
		elseif (value == SHOW_NOT_DISCOVERED_ICONS_OLD) then
			if (RSConfigDB.IsShowingOldNotDiscoveredMapIcons()) then
				RSConfigDB.SetShowingOldNotDiscoveredMapIcons(false)
			else
				RSConfigDB.SetShowingOldNotDiscoveredMapIcons(true)
			end
		end
		
		RSMinimap.RefreshAllData(true)
		WorldMapFrame:RefreshAllDataProviders();
	end
		
	LibDD:UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
		if ((level or 1) == 1) then
  			local info = LibDD:UIDropDownMenu_CreateInfo()
  			info.text = "|TInterface\\AddOns\\RareScanner\\Media\\Icons\\OriginalSkull:18:18:::::0:32:0:32|t "..AL["MAP_MENU_RARE_NPCS"]
  			info.menuList = rareNPCsID
  			info.hasArrow = true
  			info.notCheckable = true
  			LibDD:UIDropDownMenu_AddButton(info)
  			
  			info = LibDD:UIDropDownMenu_CreateInfo()
  			info.text = "|TInterface\\AddOns\\RareScanner\\Media\\Icons\\OriginalChest:18:18:::::0:32:0:32|t "..AL["MAP_MENU_CONTAINERS"]
  			info.menuList = containersID
  			info.hasArrow = true
  			info.notCheckable = true
  			LibDD:UIDropDownMenu_AddButton(info)
  			
  			info = LibDD:UIDropDownMenu_CreateInfo()
  			info.text = "|TInterface\\AddOns\\RareScanner\\Media\\Icons\\OriginalStar:18:18:::::0:32:0:32|t "..AL["MAP_MENU_EVENTS"]
  			info.menuList = eventsID
  			info.hasArrow = true
  			info.notCheckable = true
  			LibDD:UIDropDownMenu_AddButton(info)
  			
  			info = LibDD:UIDropDownMenu_CreateInfo()
  			info.text = "|TInterface\\AddOns\\RareScanner\\Media\\Icons\\DragonGlyphSmall:18:18:::::0:32:0:32|t "..AL["MAP_MENU_OTHERS"]
  			info.menuList = othersID
  			info.hasArrow = true
  			info.notCheckable = true
  			LibDD:UIDropDownMenu_AddButton(info)
			
			local info = LibDD:UIDropDownMenu_CreateInfo();
			info.isNotRadio = true;
			info.keepShownOnClick = false;
			info.func = OnSelection;
		
			info.text = AL["MAP_MENU_SHOW_NOT_DISCOVERED_OLD"];
			info.arg1 = SHOW_NOT_DISCOVERED_ICONS_OLD;
			info.checked = RSConfigDB.IsShowingOldNotDiscoveredMapIcons()
			LibDD:UIDropDownMenu_AddButton(info, level);
		else
			local info = LibDD:UIDropDownMenu_CreateInfo();
			info.isNotRadio = true;
			info.keepShownOnClick = true;
			info.func = OnSelection;
				
			if (menuList == rareNPCsID) then
				info.text = AL["MAP_MENU_SHOW_RARE_NPCS"];
				info.arg1 = SHOW_RARE_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = AL["MAP_MENU_DISABLE_LAST_SEEN_FILTER"];
				info.arg1 = DISABLE_LAST_SEEN_FILTER;
				info.checked = not RSConfigDB.IsMaxSeenTimeFilterEnabled()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
  				info.text = "|T"..RSConstants.BLUE_NPC_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_DEAD_RARE_NPCS"]
				info.arg1 = SHOW_DEAD_RARE_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingAlreadyKilledNpcs()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|T"..RSConstants.RED_NPC_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_NOT_DISCOVERED_RARE_NPCS"]
				info.arg1 = SHOW_NOT_DISCOVERED_RARE_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingNotDiscoveredNpcs()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|T"..RSConstants.LIGHT_BLUE_NPC_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_FRIENDLY_RARE_NPCS"]
				info.arg1 = SHOW_FRIENDLY_RARE_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingFriendlyNpcs()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				LibDD:UIDropDownMenu_AddSeparator(level)
			
				info.text = "|A:"..RSConstants.ACHIEVEMENT_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_ACHIEVEMENT_RARE_NPCS"];
				info.arg1 = SHOW_ACHIEVEMENT_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingAchievementRareNPCs()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.PROFFESION_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_PROFESSION_RARE_NPCS"];
				info.arg1 = SHOW_PROFESSION_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingProfessionRareNPCs()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|A:"..RSConstants.HUNTING_PARTY_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_HUNTING_PARTY_RARE_NPCS"];
				info.arg1 = SHOW_HUNTING_PARTY_NPC_ICONS;
				info.checked = not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT)
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.PRIMAL_STORM_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_PRIMAL_STORM_RARE_NPCS"];
				info.arg1 = SHOW_PRIMAL_STORM_NPC_ICONS;
				info.checked = not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_FIRE_MINIEVENT) and not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_WATER_MINIEVENT) and not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_EARTH_MINIEVENT) and not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_STORM_INVASTION_AIR_MINIEVENT)
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.DREAMSURGE_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_DREAMSURGE_RARE_NPCS"];
				info.arg1 = SHOW_DREAMSURGE_NPC_ICONS;
				info.checked = not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSURGE_MINIEVENT)
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.FYRAKK_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_FYRAKK_RARE_NPCS"];
				info.arg1 = SHOW_FYRAKK_NPC_ICONS;
				info.checked = not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT)
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = AL["MAP_MENU_SHOW_OTHER_RARE_NPCS"];
				info.arg1 = SHOW_OTHER_NPC_ICONS;
				info.checked = RSConfigDB.IsShowingOtherRareNPCs()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			elseif (menuList == containersID) then
				info.text = AL["MAP_MENU_SHOW_CONTAINERS"];
				info.arg1 = SHOW_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = AL["MAP_MENU_DISABLE_LAST_SEEN_CONTAINER_FILTER"];
				info.arg1 = DISABLE_LAST_SEEN_CONTAINER_FILTER;
				info.checked = not RSConfigDB.IsMaxSeenTimeContainerFilterEnabled()
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|T"..RSConstants.BLUE_CONTAINER_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_OPEN_CONTAINERS"];
				info.arg1 = SHOW_OPEN_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingAlreadyOpenedContainers()
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|T"..RSConstants.RED_CONTAINER_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_NOT_DISCOVERED_CONTAINERS"];
				info.arg1 = SHOW_NOT_DISCOVERED_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingNotDiscoveredContainers()
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				LibDD:UIDropDownMenu_AddSeparator(level)
			
				info.text = "|A:"..RSConstants.ACHIEVEMENT_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_ACHIEVEMENT_CONTAINERS"];
				info.arg1 = SHOW_ACHIEVEMENT_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingAchievementContainers()
				info.disabled = not RSConfigDB.IsShowingNpcs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.PROFFESION_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_PROFESSION_CONTAINERS"];
				info.arg1 = SHOW_PROFESSION_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingProfessionContainers()
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.NOT_TRACKABLE_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_NOT_TRACKABLE_CONTAINERS"];
				info.arg1 = SHOW_NOT_TRACKEABLE_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingNotTrackeableContainers()
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.WARCRAFT_RUMBLE_ICON_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_WARCRAFT_RUMBLE_CONTAINERS"];
				info.arg1 = SHOW_WARCRAFT_RUMBLE_CONTAINER_ICONS;
				info.checked = not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_WARCRAFT_RUMBLE_MINIEVENT)
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = "|A:"..RSConstants.DREAMSEED_ATLAS..":18:18::::|a "..AL["MAP_MENU_SHOW_DREAMSEED_CONTAINERS"];
				info.arg1 = SHOW_DREAMSEED_CONTAINER_ICONS;
				info.checked = not RSConfigDB.IsMinieventFiltered(RSConstants.DRAGONFLIGHT_DREAMSEED_MINIEVENT)
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = AL["MAP_MENU_SHOW_OTHER_CONTAINERS"];
				info.arg1 = SHOW_OTHER_CONTAINER_ICONS;
				info.checked = RSConfigDB.IsShowingOtherContainers()
				info.disabled = not RSConfigDB.IsShowingContainers()
				LibDD:UIDropDownMenu_AddButton(info, level);
			elseif (menuList == eventsID) then
				info.text = AL["MAP_MENU_SHOW_EVENTS"];
				info.arg1 = SHOW_EVENT_ICONS;
				info.checked = RSConfigDB.IsShowingEvents()
				LibDD:UIDropDownMenu_AddButton(info, level);
			
				info.text = AL["MAP_MENU_DISABLE_LAST_SEEN_EVENT_FILTER"];
				info.arg1 = DISABLE_LAST_SEEN_EVENT_FILTER;
				info.checked = not RSConfigDB.IsMaxSeenTimeEventFilterEnabled()
				info.disabled = not RSConfigDB.IsShowingEvents()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|T"..RSConstants.BLUE_EVENT_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_COMPLETED_EVENTS"];
				info.arg1 = SHOW_COMPLETED_EVENT_ICONS;
				info.checked = RSConfigDB.IsShowingCompletedEvents()
				info.disabled = not RSConfigDB.IsShowingEvents()
				LibDD:UIDropDownMenu_AddButton(info, level);
				
				info.text = "|T"..RSConstants.RED_EVENT_TEXTURE..":18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_NOT_DISCOVERED_EVENTS"];
				info.arg1 = SHOW_NOT_DISCOVERED_EVENT_ICONS;
				info.checked = RSConfigDB.IsShowingNotDiscoveredEvents()
				info.disabled = not RSConfigDB.IsShowingEvents()
				LibDD:UIDropDownMenu_AddButton(info, level);
			elseif (menuList == othersID) then
				info.text = "|TInterface\\AddOns\\RareScanner\\Media\\Icons\\DragonGlyphSmall:18:18:::::0:32:0:32|t "..AL["MAP_MENU_SHOW_DRAGON_GLYPHS"];
				info.arg1 = SHOW_DRAGON_GLYPHS_ICONS;
				info.checked = RSConfigDB.IsShowingDragonGlyphs()
				LibDD:UIDropDownMenu_AddButton(info, level);
			end
		end
	end)
end

function RSWorldMapButtonMixin:OnLoad()
	self.DropDown = LibDD:Create_UIDropDownMenu("WorldMapButtonDropDownMenu", self)
	self.DropDown:SetClampedToScreen(true)
	WorldMapButtonDropDownMenu_Initialize(self.DropDown)
end

function RSWorldMapButtonMixin:OnMouseDown(button)
    self.Icon:SetPoint('TOPLEFT', self, "TOPLEFT", 7, -6)
    local xOffset = WorldMapFrame.isMaximized and 30 or 0
    self.DropDown.point = WorldMapFrame.isMaximized and 'TOPRIGHT' or 'TOPLEFT'
    LibDD:ToggleDropDownMenu(1, nil, self.DropDown, self, xOffset, -5)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function RSWorldMapButtonMixin:OnMouseUp()
	self.Icon:SetPoint('TOPLEFT', 7.2, -6)
end

function RSWorldMapButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, "RareScanner")
    GameTooltip:Show()
end

function RSWorldMapButtonMixin:Refresh()
	-- Needed even if not used
end