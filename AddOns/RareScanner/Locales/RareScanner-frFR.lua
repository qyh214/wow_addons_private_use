-- Locale
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("RareScanner", "frFR", false);

if AL then
	AL["ALARM_MESSAGE"] = "Un PNJ rare vient d'apparaître, vérifiez votre carte!"
	AL["ALARM_SOUND"] = "Son d'avertissement pour les PNJ rares"
	AL["ALARM_SOUND_DESC"] = "Son joué lorsqu'un PNJ rare apparaît dans votre minicarte"
	AL["ALARM_TREASURES_SOUND"] = "Son d'avertissement pour les événements / trésors"
	AL["ALARM_TREASURES_SOUND_DESC"] = "Son émis lorsqu'un trésor / coffre ou événement apparaît sur votre mini-carte"
	--[[Translation missing --]]
	AL["AUTO_HIDE_BUTTON"] = "Autohide button and miniature"
	--[[Translation missing --]]
	AL["AUTO_HIDE_BUTTON_DESC"] = "Hides the button and the miniature automatically after the time selected (in seconds). If you select zero seconds the button and the miniature won't autohide"
	--[[Translation missing --]]
	AL["CLASS_HALLS"] = "Class Halls"
	--[[Translation missing --]]
	AL["CLEAR_FILTERS_SEARCH"] = "Clear"
	--[[Translation missing --]]
	AL["CLEAR_FILTERS_SEARCH_DESC"] = "Resets the form to the initial state"
	--[[Translation missing --]]
	AL["CLICK_TARGET"] = "Click to target NPC"
	--[[Translation missing --]]
	AL["CMD_HELP1"] = "List of commands"
	--[[Translation missing --]]
	AL["CMD_HELP2"] = "- Type \"/rarescanner show\" to show all the icons on the world map"
	--[[Translation missing --]]
	AL["CMD_HELP3"] = "- Type \"/rarescanner hide\" to hide all the icons on the world map"
	--[[Translation missing --]]
	AL["CMD_HELP4"] = "- Type \"/rarescanner toggle\" to show/hide all the icons on the world map"
	--[[Translation missing --]]
	AL["CMD_HELP5"] = "- Type \"/rarescanner toggle rares\" or \"/rarescanner tr\" to show/hide icons of NPCs on the world map"
	--[[Translation missing --]]
	AL["CMD_HELP6"] = "- Type \"/rarescanner toggle events\" or \"/rarescanner te\" to show/hide icons of events on the world map"
	--[[Translation missing --]]
	AL["CMD_HELP7"] = "- Type \"/rarescanner toggle treasures\" or \"/rarescanner tt\" to show/hide icons of treasures on the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE"] = "Hiding RareScanner icons in the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE_EVENTS"] = "Hiding RareScanner event icons in the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE_RARES"] = "Hiding RareScanner rare icons in the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE_TREASURES"] = "Hiding RareScanner treasure icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW"] = "Showing RareScanner icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW_EVENTS"] = "Showing RareScanner event icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW_RARES"] = "Showing RareScanner rare icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW_TREASURES"] = "Showing RareScanner treasure icons in the world map"
	--[[Translation missing --]]
	AL["CONTAINER"] = "Container"
	--[[Translation missing --]]
	AL["DATABASE_HARD_RESET"] = "Since the most recient expansion and with the last version of RareScanner big changes have occured in the database, which required a database reset in order to avoid inconsistencies. Sorry for the inconvenience."
	--[[Translation missing --]]
	AL["DISABLE_SEARCHING_RARE_TOOLTIP"] = "Disable alerts for this rare NPC"
	--[[Translation missing --]]
	AL["DISABLE_SOUND"] = "Disable audio alerts"
	--[[Translation missing --]]
	AL["DISABLE_SOUND_DESC"] = "When this is activated you won't receive audio alerts"
	--[[Translation missing --]]
	AL["DISABLED_SEARCHING_RARE"] = "Disabled alerts for this rare NPC: "
	--[[Translation missing --]]
	AL["DISPLAY"] = "Display"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON"] = "Toggle showing the button and the miniature"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_CONTAINERS"] = "Toggle showing the button for treasures/chests"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_CONTAINERS_DESC"] = "Toggle showing the button for treasures/chests. It doesn't affect the alarm sound and the chat alerts"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_DESC"] = "When disabled the button and the miniature won't be shown again. It doesn't affect the alarm sound and the chat alerts"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_SCALE"] = "Scale of the button and miniature"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_SCALE_DESC"] = "This will adjust the scale of the button and miniature, being the value of 0.85 the original size"
	--[[Translation missing --]]
	AL["DISPLAY_CONTAINER_ICONS"] = "Toggle showing container icons on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_CONTAINER_ICONS_DESC"] = "When disabled, icons of containers/treasures won't be shown on the world map."
	--[[Translation missing --]]
	AL["DISPLAY_EVENT_ICONS"] = "Toggle showing event icons on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_EVENT_ICONS_DESC"] = "When disabled, icons of events won't be shown on the world map."
	--[[Translation missing --]]
	AL["DISPLAY_LOG_WINDOW"] = "Toggle showing the log window"
	--[[Translation missing --]]
	AL["DISPLAY_LOG_WINDOW_DESC"] = "When disabled the log window won't be shown again."
	--[[Translation missing --]]
	AL["DISPLAY_LOOT_ON_MAP"] = "Display loot on map tooltips"
	--[[Translation missing --]]
	AL["DISPLAY_LOOT_ON_MAP_DESC"] = "Toggle showing NPC/containers loot on the tooltip that shows up when you move the mouse over the icons"
	--[[Translation missing --]]
	AL["DISPLAY_LOOT_PANEL"] = "Toggle showing loot bar"
	--[[Translation missing --]]
	AL["DISPLAY_LOOT_PANEL_DESC"] = "When this is activated it will show a bar with the loot dropped by the NPC found"
	--[[Translation missing --]]
	AL["DISPLAY_MAP_NOT_DISCOVERED_ICONS"] = "Toggle showing not discovered icons on the map."
	--[[Translation missing --]]
	AL["DISPLAY_MAP_NOT_DISCOVERED_ICONS_DESC"] = "When disabled, icons of not discovered rare NPCs (the red and orange icons), containers or events won't be shown on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_MAP_OLD_NOT_DISCOVERED_ICONS"] = "Toggle showing not discovered icons on the map for older expansions."
	--[[Translation missing --]]
	AL["DISPLAY_MAP_OLD_NOT_DISCOVERED_ICONS_DESC"] = "When disabled, icons of not discovered rare NPCs (the red and orange icons), containers or events won't be shown on the world map for areas that belong to older expansions."
	--[[Translation missing --]]
	AL["DISPLAY_MINIATURE"] = "Toggle showing the miniature"
	--[[Translation missing --]]
	AL["DISPLAY_MINIATURE_DESC"] = "When disabled the miniature won't be shown again."
	--[[Translation missing --]]
	AL["DISPLAY_NPC_ICONS"] = "Toggle showing rare NPC icons on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_NPC_ICONS_DESC"] = "When disabled, icons of rare NPCs won't be shown on the world map."
	--[[Translation missing --]]
	AL["DISPLAY_OPTIONS"] = "Display options"
	--[[Translation missing --]]
	AL["DUNGEONS_SCENARIOS"] = "Dungeons/Scenarios"
	--[[Translation missing --]]
	AL["ENABLE_MARKER"] = "Toggle target marker"
	--[[Translation missing --]]
	AL["ENABLE_MARKER_DESC"] = "When this is activated it will show a marker on top of the target when you click the main button"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_CHAT"] = "Toggle searching for rare NPCs through chat messages"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_CHAT_DESC"] = "When this is activated you will be warned visually and with a sound everytime a rare NPC yells or a chat message related with a rare NPCs is detected."
	--[[Translation missing --]]
	AL["ENABLE_SCAN_CONTAINERS"] = "Toggle searching treasures or chests"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_CONTAINERS_DESC"] = "When this is activated you will be warned visually and with a sound everytime a treasure or chest shows up in your minimap"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_EVENTS"] = "Toggle searching events"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_EVENTS_DESC"] = "When this is activated you will be warned visually and with a sound everytime an event shows up in your minimap"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_GARRISON_CHEST"] = "Toggle searching garrison treasure"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_GARRISON_CHEST_DESC"] = "When this is activated you will be warned visually and with a sound everytime your garrison chest shows up in your minimap"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_IN_INSTANCE"] = "Toggle scanning in instances"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_IN_INSTANCE_DESC"] = "When this is activated the addon will work as usual while you are in an instance (dungeon, raid, etc)"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_ON_TAXI"] = "Toggle scanning while using a transportation"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_ON_TAXI_DESC"] = "When this is activated the addon will work as usual while you are using a transportation (flight, boat, etc.)"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_RARES"] = "Toggle searching rare NPCs"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_RARES_DESC"] = "When this is activated you will be warned visually and with a sound everytime a rare NPC shows up in your minimap"
	--[[Translation missing --]]
	AL["ENABLE_SEARCHING_RARE_TOOLTIP"] = "Enable alerts for this rare NPC"
	--[[Translation missing --]]
	AL["ENABLE_TOMTOM_SUPPORT"] = "Toggle Tomtom's support"
	--[[Translation missing --]]
	AL["ENABLE_TOMTOM_SUPPORT_DESC"] = "When this is activated it will add a Tomtom's waypoint at the entitie's found coordinates"
	--[[Translation missing --]]
	AL["ENABLED_SEARCHING_RARE"] = "Enabled alerts for this rare NPC: "
	--[[Translation missing --]]
	AL["EVENT"] = "Event"
	--[[Translation missing --]]
	AL["FILTER"] = "NPC filters"
	--[[Translation missing --]]
	AL["FILTER_CONTINENT"] = "Continent/Category"
	--[[Translation missing --]]
	AL["FILTER_CONTINENT_DESC"] = "Continent or category name"
	--[[Translation missing --]]
	AL["FILTER_NPCS_ONLY_MAP"] = "Enable filters only in the world map"
	--[[Translation missing --]]
	AL["FILTER_NPCS_ONLY_MAP_DESC"] = "When enabled you will still get alerts from filtered NPCs but they won't show up in your world map. When disabled you won't get alerts from filtered NPCs at all."
	--[[Translation missing --]]
	AL["FILTER_RARE_LIST"] = "Filter searching for rare NPCs"
	--[[Translation missing --]]
	AL["FILTER_RARE_LIST_DESC"] = "Toggle searching for this rare NPC. When disabled you won't get an alert when this NPC is found."
	--[[Translation missing --]]
	AL["FILTER_ZONE"] = "Zone"
	--[[Translation missing --]]
	AL["FILTER_ZONE_DESC"] = "Zone inside the continent or category"
	--[[Translation missing --]]
	AL["FILTER_ZONES_LIST"] = "Zone list"
	--[[Translation missing --]]
	AL["FILTER_ZONES_LIST_DESC"] = "Toggle alerts in this zone. When disabled you won't get an alert when a rare NPC, event or treasure is found in this zone."
	--[[Translation missing --]]
	AL["FILTER_ZONES_ONLY_MAP"] = "Enable filters only in the world map"
	--[[Translation missing --]]
	AL["FILTER_ZONES_ONLY_MAP_DESC"] = "When enabled you will still get alerts from NPCs that belong to filtered zones but they won't show up in your world map. When disabled you won't get alerts from NPCs that belong to filtered zones at all."
	--[[Translation missing --]]
	AL["FILTERS"] = "Rare NPCs filters"
	--[[Translation missing --]]
	AL["FILTERS_SEARCH"] = "Search"
	--[[Translation missing --]]
	AL["FILTERS_SEARCH_DESC"] = "Type the name of the NPC to filter the list below"
	--[[Translation missing --]]
	AL["GENERAL_OPTIONS"] = "General options"
	--[[Translation missing --]]
	AL["JUST_SPAWNED"] = "%s just showed up. Check your map!"
	--[[Translation missing --]]
	AL["LEFT_BUTTON"] = "Left-click"
	--[[Translation missing --]]
	AL["LOG_WINDOW_AUTOHIDE"] = "Autohide logged NPC buttons"
	--[[Translation missing --]]
	AL["LOG_WINDOW_AUTOHIDE_DESC"] = "Hides each NPC button after the time selected (in minutes). If you select zero minutes the buttons will remain until you close the log window, or it reaches the maximun number of buttons (in which case the oldest will be replaced)."
	--[[Translation missing --]]
	AL["LOG_WINDOW_OPTIONS"] = "Log window options"
	--[[Translation missing --]]
	AL["LOOT_CATEGORY_FILTERED"] = "Filter enabled for the category/subcategory: %s/%s. You can disable this filter by clicking again on the loot icon or from the RareScanner addon's menu"
	--[[Translation missing --]]
	AL["LOOT_CATEGORY_FILTERS"] = "Category filters"
	--[[Translation missing --]]
	AL["LOOT_CATEGORY_FILTERS_DESC"] = "Filter the loot shown by category"
	--[[Translation missing --]]
	AL["LOOT_CATEGORY_NOT_FILTERED"] = "Filter disabled for the category/subcategory: %s/%s"
	--[[Translation missing --]]
	AL["LOOT_DISPLAY_OPTIONS"] = "Display options"
	--[[Translation missing --]]
	AL["LOOT_DISPLAY_OPTIONS_DESC"] = "Display options for the loot bar"
	--[[Translation missing --]]
	AL["LOOT_FILTER_COLLECTED"] = "Filter collected pets, mounts and toys."
	--[[Translation missing --]]
	AL["LOOT_FILTER_COLLECTED_DESC"] = "When activated, only mounts, pets and toys that you haven't collected yet will be show on the loot bar. This filter doesn't affect other kinds of lootable items, whatsoever."
	--[[Translation missing --]]
	AL["LOOT_FILTER_COMPLETED_QUEST"] = "Filter quest items that don't begin a new quest"
	--[[Translation missing --]]
	AL["LOOT_FILTER_COMPLETED_QUEST_DESC"] = "When activated, any item that is a requirement for a quest, or that begins an already completed quest, won't show up on the loot bar."
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_EQUIPABLE"] = "Filter non-equipable items"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_EQUIPABLE_DESC"] = "When activated, armor and weapons that this character cannot wear won't show up on the loot bar. This filter doesn't affect other kinds of lootable items, whatsoever."
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_MATCHING_CLASS"] = "Filter items that require a different class than yours"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_MATCHING_CLASS_DESC"] = "When activated, any item that requires a specific class to be used that doesn't match yours, won't show up on the loot bar."
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_TRANSMOG"] = "Show only transmog armor and weapons"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_TRANSMOG_DESC"] = "When activated, only armor and weapons that you haven't collected yet will be shown on the loot bar. This filter doesn't affect other kinds of lootable items, whatsoever."
	--[[Translation missing --]]
	AL["LOOT_FILTER_SUBCATEGORY_DESC"] = "Toggle showing this kind of loot on the loot bar. When disabled you won't see any item that matches this category on the loot shown when you find a rare NPC."
	--[[Translation missing --]]
	AL["LOOT_FILTER_SUBCATEGORY_LIST"] = "Subcategories"
	--[[Translation missing --]]
	AL["LOOT_ITEMS_PER_ROW"] = "Number of items per row to display"
	--[[Translation missing --]]
	AL["LOOT_ITEMS_PER_ROW_DESC"] = "Sets the number of items to display per row on the loot bar. If the number is less than the maximum several rows will be displayed."
	--[[Translation missing --]]
	AL["LOOT_MAIN_CATEGORY"] = "Main category"
	--[[Translation missing --]]
	AL["LOOT_MAX_ITEMS"] = "Number of items to display"
	--[[Translation missing --]]
	AL["LOOT_MAX_ITEMS_DESC"] = "Sets the maximum number of items to display on the loot bar."
	--[[Translation missing --]]
	AL["LOOT_MIN_QUALITY"] = "Minimum loot quality"
	--[[Translation missing --]]
	AL["LOOT_MIN_QUALITY_DESC"] = "Defines the minimum loot quality to show in the loot bar"
	--[[Translation missing --]]
	AL["LOOT_OPTIONS"] = "Loot options"
	--[[Translation missing --]]
	AL["LOOT_OTHER_FILTERS"] = "Other filters"
	--[[Translation missing --]]
	AL["LOOT_OTHER_FILTERS_DESC"] = "Other filters"
	--[[Translation missing --]]
	AL["LOOT_PANEL_OPTIONS"] = "Loot bar options"
	--[[Translation missing --]]
	AL["LOOT_SUBCATEGORY_FILTERS"] = "Subcategory filters"
	--[[Translation missing --]]
	AL["LOOT_TOGGLE_FILTER"] = "Alt-Left-Click to toggle filter"
	--[[Translation missing --]]
	AL["LOOT_TOOLTIP_POSITION"] = "Loot tooltip position"
	--[[Translation missing --]]
	AL["LOOT_TOOLTIP_POSITION_DESC"] = "Defines where to show the loot tooltip that appears when you move the mouse over an icon, in respect to the button"
	--[[Translation missing --]]
	AL["MAIN_BUTTON_OPTIONS"] = "Main button options"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_CONTAINER_FILTER"] = "Show containers that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_EVENT_FILTER"] = "Show events that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_FILTER"] = "Show rare NPCs that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_CONTAINERS"] = "Show container icons on map"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_EVENTS"] = "Show event icons on map"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_NOT_DISCOVERED"] = "Not discovered entities"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_NOT_DISCOVERED_OLD"] = "Not discovered entities (older expansions)"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_RARE_NPCS"] = "Show rare NPC icons on map"
	--[[Translation missing --]]
	AL["MAP_NEVER"] = "Never"
	--[[Translation missing --]]
	AL["MAP_OPTIONS"] = "Map options"
	--[[Translation missing --]]
	AL["MAP_SCALE_ICONS"] = "Scale of the icons"
	--[[Translation missing --]]
	AL["MAP_SCALE_ICONS_DESC"] = "This will adjust the scale of the icons, being the value of 1 the original size."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COLLECTED"] = "Keep showing container icons after looted"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COLLECTED_DESC"] = "When disabled the icon will disappear after you loot the container."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COMPLETED"] = "Keep showing event icons after completion"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COMPLETED_DESC"] = "When disabled the icon will disappear after you complete the event."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD"] = "Keep showing NPC icons after death"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_DESC"] = "When disabled the icon will disappear after you kill the NPC. The icon will reappear as soon as you find the NPC again. This option only works with NPCs that keep being rares after killing them."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_RESETEABLE"] = "Keep showing NPC icons after death (only in resetable zones)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_RESETEABLE_DESC"] = "When disabled the icon will disappear after you kill the NPC. The icon will reappear as soon as you find the NPC again. This option only works with NPCs that keep being rares after killing them in zones that reset with world quests."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_CONTAINER_MAX_SEEN_TIME"] = "Timer to hide container icons (in minutes)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_CONTAINER_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of minutes since you have seen the container. After that time, the icon won't be shown on the world map until you find the container again. If you select zero minutes the icons will be shown regardless of how long since you have seen the container. This filter doesn't apply to containers that are part of an achievement."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_EVENT_MAX_SEEN_TIME"] = "Timer to hide event icons (in minutes)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_EVENT_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of minutes since you have seen the event. After that time, the icon won't be shown on the world map until you find the event again. If you select zero minutes the icons will be shown regardless of how long since you have seen the event."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_MAX_SEEN_TIME"] = "Timer to hide rare NPC icons (in hours)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of hours since you have seen the NPC. After that time, the icon won't be shown on the world map until you find the NPC again. If you select zero hours the icons will be shown regardless of how long since you have seen the rare NPC."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ACHIEVEMENT"] = "This is an objective of the achievement %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_COMPLETED"] = "This event is already completed. Restart on: %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_KILLED"] = "This NPC is already killed. Restart on: %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_OPENED"] = "This container is already opened. Restart on: %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_CONTAINER_LOOTED"] = "Shift-Left-Click to set as looted."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_DAYS"] = "days"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_EVENT_DONE"] = "Shift-Left-Click to set as completed"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_IGNORE_ICON"] = "Shift-Left-Click to hide this icon forever if it shouldn't be here."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_KILLED"] = "Shift-Left-Click to set as killed"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_NOT_FOUND"] = "You haven't seen this NPC and no one has shared it with you yet."
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_SEEN"] = "Seen before: %s"
	--[[Translation missing --]]
	AL["MARKER"] = "Target marker"
	--[[Translation missing --]]
	AL["MARKER_DESC"] = "Choose the marker to add on top of the target when you click the main button."
	--[[Translation missing --]]
	AL["MESSAGE_OPTIONS"] = "Messages options"
	--[[Translation missing --]]
	AL["MIDDLE_BUTTON"] = "Middle-click"
	--[[Translation missing --]]
	AL["NAVIGATION_ENABLE"] = "Toggle navigation"
	--[[Translation missing --]]
	AL["NAVIGATION_ENABLE_DESC"] = "When enabled the navigation arrows will show up beside the main button to allow you access to newer or older entities found"
	--[[Translation missing --]]
	AL["NAVIGATION_LOCK_ENTITY"] = "Block display of new entities if one is already shown"
	--[[Translation missing --]]
	AL["NAVIGATION_LOCK_ENTITY_DESC"] = "When enabled, if the main button is displaying an entity in your screen, it won't update to a newer one automatically. An arrow will appear allowing you to access the new entity whenever you are ready"
	--[[Translation missing --]]
	AL["NAVIGATION_OPTIONS"] = "Navigation options"
	--[[Translation missing --]]
	AL["NAVIGATION_SHOW_NEXT"] = "Show next entity found"
	--[[Translation missing --]]
	AL["NAVIGATION_SHOW_PREVIOUS"] = "Show previous entity found"
	--[[Translation missing --]]
	AL["NOT_TARGETEABLE"] = "Not targeteable"
	--[[Translation missing --]]
	AL["NOTE_130350"] = "You have to ride this rare to the container that you will find by following the path to the right of this position."
	--[[Translation missing --]]
	AL["NOTE_131453"] = "You have to ride [Guardian of the Spring] to this position. The horse is a friendly rare that you will find by following the path to the left of this container."
	--[[Translation missing --]]
	AL["NOTE_135497"] = "Only available while doing the daily quest [Aid from Nordrassil] obtained from Mylune. While you are on this quest you will find mushrooms under the trees. Clicking on them might spawn this NPC."
	--[[Translation missing --]]
	AL["NOTE_149847"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_150342"] = "Only available during the event [Drill Rig DR-TR35]."
	--[[Translation missing --]]
	AL["NOTE_150394"] = "In order to kill him you have to bring him to the coordinates 63.38, where there is a device with blue lightning. Once the NPC is touched by lightning, it will explode and you will be able to loot him."
	--[[Translation missing --]]
	AL["NOTE_151124"] = "You have to loot a [Smashed Transport Relay] from the enemies that appear during the event [Drill Rig DR-JD99] (coordinates 59.67) and then use it on the machine that is found on the platform."
	--[[Translation missing --]]
	AL["NOTE_151159"] = "He is available only when [Oglethorpe Obnoticus] is in Mechagon (coordinates 72.37). He wanders around Mechagon, so check in every street. Killing him makes [OOX-Avenger/MG] to spawn."
	--[[Translation missing --]]
	AL["NOTE_151202"] = "In order to summon him you have to connect the [Wires] on the shore, with the [Pylons] inside the water."
	--[[Translation missing --]]
	AL["NOTE_151296"] = "First check if [Oglethorpe Obnoticus] is in Mechagon (coordinates 72.37). If he is there, then you have to find and kill [OOX-Fleetfoot/MG] (it is a chicken robot wandering around Mechagon). Once you find him and kill him, come back to this icon's coordinates."
	--[[Translation missing --]]
	AL["NOTE_151308"] = "Only available during [Drill Rig] events."
	--[[Translation missing --]]
	AL["NOTE_151569"] = "You require a [Hundred-Fathom Lure] to summon it."
	--[[Translation missing --]]
	AL["NOTE_151627"] = "You need to use a [Exothermic Evaporator Coil] on the machine that is found on the platform."
	--[[Translation missing --]]
	AL["NOTE_151933"] = "In order to kill him you have to use [Beastbot Powerpack] (you can get the schema at the coordinates 60.41)."
	--[[Translation missing --]]
	AL["NOTE_152007"] = "It is wandering in this area, so the coordinates might not be very accurate."
	--[[Translation missing --]]
	AL["NOTE_152113"] = "Only available during the event [Drill Rig DR-CC88]."
	--[[Translation missing --]]
	AL["NOTE_152569"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_152570"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_153000"] = "Only available while the daily quest [Bugs, Lots of 'Em!] is active."
	--[[Translation missing --]]
	AL["NOTE_153200"] = "Only available during the event [Drill Rig DR-JD41]."
	--[[Translation missing --]]
	AL["NOTE_153205"] = "Only available during the event [Drill Rig DR-JD99]."
	--[[Translation missing --]]
	AL["NOTE_153206"] = "Only available during the event [Drill Rig DR-TR28]."
	--[[Translation missing --]]
	AL["NOTE_153228"] = "It shows up after killing a LOT of [Upgraded Sentry] that wander around the area."
	--[[Translation missing --]]
	AL["NOTE_154225"] = "He is available only on the interface that you can access using [Personal Time Displacer] that you can create with resources collected in Mechagon. Important: He won't spawn while Chromie's daily quest is available."
	--[[Translation missing --]]
	AL["NOTE_154332"] = "It is in a cave. The entrance is located at the coordinates 57,38."
	--[[Translation missing --]]
	AL["NOTE_154333"] = "It is in a cave. The entrance is located at the coordinates 57,38."
	--[[Translation missing --]]
	AL["NOTE_154342"] = "He is available only on the interface that you can access using [Personal Time Displacer] that you can create with resources collected in Mechagon."
	--[[Translation missing --]]
	AL["NOTE_154559"] = "It is in a cave. The entrance is located at the coordinates 70,58."
	--[[Translation missing --]]
	AL["NOTE_154604"] = "It is in a cave. The entrance is located at the coordinates 36,20."
	--[[Translation missing --]]
	AL["NOTE_154701"] = "Only available during the event [Drill Rig DR-CC61]."
	--[[Translation missing --]]
	AL["NOTE_154739"] = "Only available during the event [Drill Rig DR-CC73]."
	--[[Translation missing --]]
	AL["NOTE_155531"] = "You have to use the orb above him (Essence of the Sun) to get [Aura of the Sun] and be able to attack him."
	--[[Translation missing --]]
	AL["NOTE_156709"] = "You have to kill Faceless Despoiler (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_157162"] = "Inside the temple. The entrance is located at the coordinates 22,24."
	--[[Translation missing --]]
	AL["NOTE_158531"] = "You have to kill Voidwarped Neferset (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_158632"] = "You have to kill Burbling Fleshbeast (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_158706"] = "You have to kill Oozing Putrefaction (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_159087"] = "You have to kill N'Zoth Bonestripper (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_160968"] = "Inside the temple. The entrance is located at the coordinates 22,24."
	--[[Translation missing --]]
	AL["NOTE_162171"] = "It is in a cave. The entrance is located at the coordinates 45,58."
	--[[Translation missing --]]
	AL["NOTE_162352"] = "It is in a cave. The entrance is underwater at the coordinates 52,40."
	--[[Translation missing --]]
	AL["NOTE_280951"] = "Follow the railway until you find a cart. Ride it to discover the treasure."
	--[[Translation missing --]]
	AL["NOTE_287239"] = "If you are horde you have to complete Vol'dun campaign in order to have access to the temple."
	--[[Translation missing --]]
	AL["NOTE_289647"] = "The treasure is in a cave. The entrance is at the coordinates 65.11, between some trees almost on top of the mountain."
	--[[Translation missing --]]
	AL["NOTE_292673"] = "1 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in the basement. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292674"] = "2 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is under the wood floor, in the corner beside a bunch of candles. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292675"] = "3 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in the basement. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292676"] = "4 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in the top floor. Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292677"] = "5 of 5 scrolls. Read all of them to discover the treasure [Secret of the Depths]. It is in an underground cave. The entrance is under water at the coordinates 72.40 (water pool at the monastery). Hide this icon manually once you read it."
	--[[Translation missing --]]
	AL["NOTE_292686"] = "After reading the 5 scrolls, use the [Ominous Altar] to obtain [Secret of the Depths]. Warning: Using the altar will teleport you to the middle of the sea. Hide this icon manually once you use it."
	--[[Translation missing --]]
	AL["NOTE_293349"] = "It is inside the shed, on top of a shelf."
	--[[Translation missing --]]
	AL["NOTE_293350"] = "This treasure is hidden in a cave underneath. Go to the coordinates 61.38, and set the camera on top, then jump backwards through the little crack on the floor and land on the ledge."
	--[[Translation missing --]]
	AL["NOTE_293852"] = "You won't see this until you collect [Soggy Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_293880"] = "You won't see this until you collect [Fading Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_293881"] = "You won't see this until you collect [Yellowed Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_293884"] = "You won't see this until you collect [Singed Treasure Map] from the pirates at Freehold"
	--[[Translation missing --]]
	AL["NOTE_297828"] = "The raven flying on top holds the key. Kill it."
	--[[Translation missing --]]
	AL["NOTE_297891"] = "You have to disable the runes in this order: Left, Down, Up, Right"
	--[[Translation missing --]]
	AL["NOTE_297892"] = "You have to disable the runes in this order: Left, Right, Down, Up"
	--[[Translation missing --]]
	AL["NOTE_297893"] = "You have to disable the runes in this order: Right, Up, Left, Down"
	--[[Translation missing --]]
	AL["NOTE_326395"] = "You have to enable the [Arcane device] that is found on top of a table beside the chest in order to start the minigame. To pass the game you have to separate the three triangles. Click on the orbs to switch their positions."
	--[[Translation missing --]]
	AL["NOTE_326396"] = "You have to enable the [Arcane device] that is found on the ground beside the chest in order to start the minigame. To pass the game you have to separate the two rectangles. Click on the orbs to switch their positions."
	--[[Translation missing --]]
	AL["NOTE_326397"] = "You have to enable the [Arcane device] that is found on the ground beside the chest in order to start the minigame. To pass the game you have to line up three red runes."
	--[[Translation missing --]]
	AL["NOTE_326398"] = "You have to enable the [Arcane device] that is found on top of a table beside the chest in order to start the minigame. To pass the game you have to line up four cyan runes."
	--[[Translation missing --]]
	AL["NOTE_326399"] = "It's in a cave underwater. You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_326400"] = "It is in a cave. You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_326403"] = "It is inside the building. You have to access it from the back."
	--[[Translation missing --]]
	AL["NOTE_326405"] = "It is between some ruins in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326406"] = "It is on top of a mountain in the highest level of the map. It's hard to get there on foot, but it's possible from the south side."
	--[[Translation missing --]]
	AL["NOTE_326407"] = "It is on top of a mountain in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326408"] = "It is in a cave underwater. The entrance is in the lake to the south (coordinates 57,39)."
	--[[Translation missing --]]
	AL["NOTE_326410"] = "It is in a cave in the lower level of the map."
	--[[Translation missing --]]
	AL["NOTE_326411"] = "It is between some stones in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326413"] = "It is in a cave in the lower level of the map."
	--[[Translation missing --]]
	AL["NOTE_326415"] = "It requires flying or you can use a [Goblin Glider Kit] from the tall mountain beside. The chest is on top of the coral bridge."
	--[[Translation missing --]]
	AL["NOTE_326416"] = "It is in the highest level of the map, inside a tower in ruins."
	--[[Translation missing --]]
	AL["NOTE_329783"] = "It is on the roof (access at coordinates 83.33). You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_332220"] = "You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["PROFILES"] = "Profiles"
	--[[Translation missing --]]
	AL["RAIDS"] = "Raids"
	--[[Translation missing --]]
	AL["RESET_POSITION"] = "Reset position"
	--[[Translation missing --]]
	AL["RESET_POSITION_DESC"] = "Restores the original position of the main button."
	--[[Translation missing --]]
	AL["SHOW_CHAT_ALERT"] = "Toggle showing chat alerts"
	--[[Translation missing --]]
	AL["SHOW_CHAT_ALERT_DESC"] = "Shows a private message in the chat every time a treasure, chest or NPC is found"
	--[[Translation missing --]]
	AL["SHOW_RAID_WARNING"] = "Toggle showing raid warnings"
	--[[Translation missing --]]
	AL["SHOW_RAID_WARNING_DESC"] = "Shows a raid warning on your screen every time a treasure, chest or NPC is found"
	--[[Translation missing --]]
	AL["SOUND"] = "Sound"
	--[[Translation missing --]]
	AL["SOUND_OPTIONS"] = "Sound options"
	--[[Translation missing --]]
	AL["SOUND_VOLUME"] = "Volume"
	--[[Translation missing --]]
	AL["SOUND_VOLUME_DESC"] = "Sets the sound volume level"
	--[[Translation missing --]]
	AL["SYNCRONIZATION_COMPLETED"] = "Syncronization completed"
	--[[Translation missing --]]
	AL["SYNCRONIZE"] = "Sync database"
	--[[Translation missing --]]
	AL["SYNCRONIZE_DESC"] = "This will analize which rare NPCs and treasures that are part of an achievement you have killed/collected already, and they will disappear from your map. There is no way to know the state of non-achievement rare NPCs and treasures, so they will remain in your map as they are currently shown."
	--[[Translation missing --]]
	AL["TEST"] = "Launch Test"
	AL["TEST_DESC"] = "Appuyez sur le bouton pour afficher un exemple d'alerte. Vous pouvez faire glisser et déposer le panneau vers une autre position où il sera désormais affiché."
	AL["TOC_NOTES"] = "Scanner mini-carte. Vous avertit visuellement avec un bouton et une miniature et émet un son à chaque fois qu'un PNJ, un trésor / coffre ou un événement rare apparaît dans votre mini-carte"
	AL["TOGGLE_FILTERS"] = "Basculer les filtres"
	AL["TOGGLE_FILTERS_DESC"] = "Basculer tous les filtres à la fois"
	AL["TOOLTIP_BOTTOM"] = "Côté inférieur"
	AL["TOOLTIP_CURSOR"] = "Suivre le curseur"
	AL["TOOLTIP_LEFT"] = "Côté gauche"
	AL["TOOLTIP_RIGHT"] = "Côté droit"
	AL["TOOLTIP_TOP"] = "Face supérieure"
	AL["UNKNOWN"] = "Inconnue"
	AL["UNKNOWN_TARGET"] = "Cible inconnue"
	--[[Translation missing --]]
	AL["ZONES_FILTER"] = "Zone filters"
	AL["ZONES_FILTERS_SEARCH_DESC"] = "Tapez le nom de la zone pour filtrer la liste ci-dessous"

	-- CONTINENT names
	AL["ZONES_CONTINENT_LIST"] = {
		[9999] = "Class Halls"; --Class Halls
		[9998] = "Île de Sombrelune"; --Darkmoon Island
		[9997] = "Dungeons/Scenarios"; --Dungeons/Scenarios
		[9996] = "Raids"; --Raids
		[9995] = "Unknown"; --Unknown
	}
end