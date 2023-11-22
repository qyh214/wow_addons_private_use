-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local RSConstants = private.NewLib("RareScannerConstants")

---============================================================================
-- DEBUG MODE
---============================================================================

RSConstants.DEBUG_MODE = false

-- Use this constant to logger information about an specific entity while
-- displaying on the map. This is handy to find bugs in the POI filters
RSConstants.MAP_ENTITY_ID = nil

-- Use this constant to logger information about an specific item whie
-- displaying on the loot bar under the main button or the map. This is handy to find bugs
-- with the loot filters
RSConstants.LOOT_ITEM_ID = nil

---============================================================================
-- Current versions
---============================================================================

RSConstants.CURRENT_DB_VERSION = 118
RSConstants.CURRENT_LOOT_DB_VERSION = 130

---============================================================================
-- Current maps (newer)
---============================================================================

RSConstants.CURRENT_MAP_ID = 1978 --Dragon Isles
RSConstants.CURRENT_SUBMAP_ID = 2200 --Emerald Dream

---============================================================================
-- Default filtered entities by version
---============================================================================

RSConstants.DEFAULT_FILTERED_ENTITIES = {
	version = 67,
	containers = {382029, 383733, 383734, 383735, 376386, 376587}
}

---============================================================================
-- Special events
---============================================================================

RSConstants.SHADOWLANDS_PRE_PATCH_EVENT = 1
RSConstants.DIABLO_4_GOBLIN_EVENT = 2
RSConstants.WARCRAFT_RUMBLE_CROSSOVER_EVENT = 3

RSConstants.EVENTS = {
	[RSConstants.SHADOWLANDS_PRE_PATCH_EVENT] = false;
	[RSConstants.DIABLO_4_GOBLIN_EVENT] = false;
	[RSConstants.WARCRAFT_RUMBLE_CROSSOVER_EVENT] = true;
}

---============================================================================
-- Mini events
---============================================================================

RSConstants.DRAGONFLIGHT_DREAMSURGE_MINIEVENT = 1
RSConstants.DRAGONFLIGHT_STORM_INVASTION_FIRE_MINIEVENT = 2
RSConstants.DRAGONFLIGHT_STORM_INVASTION_WATER_MINIEVENT = 3
RSConstants.DRAGONFLIGHT_STORM_INVASTION_EARTH_MINIEVENT = 4
RSConstants.DRAGONFLIGHT_STORM_INVASTION_AIR_MINIEVENT = 5
RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT = 6
RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT = 7
RSConstants.DRAGONFLIGHT_WARCRAFT_RUMBLE_MINIEVENT = 8
RSConstants.DRAGONFLIGHT_DREAMSEED_MINIEVENT = 9

-- Minievents that will have an option to filter/unfilter the icons from the worldmap
RSConstants.MINIEVENTS_WORLDMAP_FILTERS = {
	[RSConstants.DRAGONFLIGHT_DREAMSURGE_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_STORM_INVASTION_FIRE_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_STORM_INVASTION_WATER_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_STORM_INVASTION_EARTH_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_STORM_INVASTION_AIR_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_WARCRAFT_RUMBLE_MINIEVENT] = true;
	[RSConstants.DRAGONFLIGHT_DREAMSEED_MINIEVENT] = true;
}

---============================================================================
-- Timers
---============================================================================

RSConstants.CHECK_RESET_RECENTLY_SEEN_TIMER = 5 --5 seconds
RSConstants.RECENTLY_SEEN_RESET_TIMER = 120 --2 minutes
RSConstants.RECENTLY_SEEN_PING_ANIMATION_TIMER = 5 --5 seconds
RSConstants.CACHE_ALL_COMPLETED_QUEST_IDS_TIMER = 60 --1 minute
RSConstants.FIND_HIDDEN_QUESTS_TIMER = 5 --5 seconds after killing a NPC or opening a container
RSConstants.CHECK_RESPAWN_THRESHOLD = 150 --2.5 minutes
RSConstants.CHECK_RESPAWN_TIMER = 60 --1 minute
RSConstants.CHECK_RESET_NOTIFICATIONS_TIMER = 10 --10 seconds
RSConstants.CHECK_TARGETS_TIMER = 2 --2 seconds
RSConstants.BUTTON_TIMER = 1 --1 seconds

---============================================================================
-- Collections enumerators
---============================================================================

RSConstants.ITEM_SOURCE = {
	NPC = 1,
	CONTAINER = 2
}

RSConstants.ITEM_TYPE = {
	APPEARANCE = 1,
	TOY = 2,
	PET = 3,
	MOUNT = 4,
	DRAKEWATCHER = 5
}

---============================================================================
-- Types of entity filters
---============================================================================

RSConstants.ENTITY_FILTER_ALL = 1
RSConstants.ENTITY_FILTER_WORLDMAP = 2
RSConstants.ENTITY_FILTER_ALERTS = 3

---============================================================================
-- Events when adding animations to the world map
---============================================================================

RSConstants.MAP_ANIMATIONS_ON_FOUND = 1
RSConstants.MAP_ANIMATIONS_ON_CLICK = 2
RSConstants.MAP_ANIMATIONS_ON_BOTH = 3

---============================================================================
-- Addons default settings
---============================================================================

RSConstants.PROFILE_DEFAULTS = {
	profile = {
		general = {
			scanRares = true,
			scanContainers = true,
			scanEvents = true,
			scanChatAlerts = true,
			scanGarrison = false,
			scanInstances = false,
			scanOnTaxi = true,
			scanOnPetBattle = true,
			scanOnRacingQuest = true,
			scanWorldmapVignette = true,
			scanTargetUnit = false,
			ignoreCompletedEntities = true,
			filteredRares = {},
			filteredContainers = {},
			filteredEvents = {},
			filteredZones = {},
			enableTomtomSupport = false,
			autoTomtomWaypoints = false,
			enableWaypointsSupport = false,
			autoWaypoints = false,
			showMaker = true,
			marker = 8,
			rescanTimer = 5
		},
		sound = {
			soundDisabled = false,
			soundPlayed = "Horn",
			soundObjectDisabled = false,
			soundObjectPlayed = "PVP Horde",
			soundVolume = 4,
			soundChannel = "Master",
			soundCustomFolder = "RareScannerSounds"
		},
		display = {
			displayButton = true,
			displayMiniature = true,
			displayButtonContainers = true,
			scale = 0.8,
			autoHideButton = 0,
			displayRaidWarning = true,
			displayChatMessage = true,
			displayTimestampChatMessage = true,
			enableNavigation = true,
			navigationLockEntity = false,
			lockPosition = false,
			minimapButton = {
				hide = false
			},
			worldmapButton = true
		},
		rareFilters = {
			defaultNpcFilterType = RSConstants.ENTITY_FILTER_ALL
		},
		containerFilters = {
			defaultContainerFilterType = RSConstants.ENTITY_FILTER_ALL
		},
		eventFilters = {
			defaultEventFilterType = RSConstants.ENTITY_FILTER_ALL
		},
		zoneFilters = {
			filtersToggled = true,
			filterOnlyMap = false
		},
		collections = {
			filteredOnlyOnWorldMap = false,
			autoFilteringOnCollect = false,
			createProfileBackup = true,
			searchingPets = true,
			searchingMounts = true,
			searchingToys = true,
			searchingAppearances = true,
			searchingDrakewatcher = true,
			showFiltered = true,
			showDead = true,
			showWithoutCollectibles = false,
			lockingMap = false
		},
		map = {
			displayNpcIcons = true,
			displayNotDiscoveredNpcIcons = true,
			displayAlreadyKilledNpcIcons = false,
			displayAlreadyKilledNpcIconsReseteable = false,
			displayProfessionRaresNpcIcons = true,
			displayAchievementRaresNpcIcons = true,
			displayMinieventsNpcIcons = {
				[RSConstants.DRAGONFLIGHT_HUNTING_PARTY_MINIEVENT] = false;
				[RSConstants.DRAGONFLIGHT_FYRAKK_MINIEVENT] = false;
			},
			displayOtherRaresNpcIcons = true,
			displayContainerIcons = true,
			displayAlreadyOpenedContainersIcons = false,
			displayNotDiscoveredContainerIcons = true,
			displayNotTrackeableContainerIcons = true,
			displayAchievementContainerIcons = true,
			displayProfessionContainerIcons = true,
			displayOtherContainerIcons = true,
			displayEventIcons = true,
			displayNotDiscoveredEventIcons = true,
			disableLastSeenFilter = false,
			displayFriendlyNpcIcons = false,
			displayOldNotDiscoveredMapIcons = true,
			displayDragonGlyphsIcons = true,
			displayAlreadyCompletedEventIcons = false,
			maxSeenTime = 0,
			maxSeenTimeContainer = 0,
			maxSeenTimeEvent = 5,
			scale = 0.8,
			minimapscale = 0.7,
			showingWorldMapSearcher = true,
			cleanWorldMapSearcherOnChange = true,
			displayMinimapIcons = true,
			waypointTomtom = false,
			waypointIngame = true,
			tooltipsScale = 1.0,
			tooltipsOnIngameIcons = true,
			tooltipsAchievements = true,
			tooltipsNotes = true,
			tooltipsState = true,
			tooltipsSeen = true,
			tooltipsCommands = true,
			lootAchievTooltipsScale = 0.7,
			lootAchievementsPosition = "ANCHOR_LEFT",
			overlayMaxColours = 10,
			overlayColour1 = { 1, 0.2, 1 },
			overlayColour2 = { 0.23, 0.943, 1 },
			overlayColour3 = { 0.98, 0.99, 0.19 },
			overlayColour4 = { 0, 0.12, 1 },
			overlayColour5 = { 0.317, 1, 0.1 },
			overlayColour6 = { 1, 0.35, 0.11 },
			overlayColour7 = { 0.08, 0.55, 1 },
			overlayColour8 = { 0.18, 1, 0.42 },
			overlayColour9 = { 1, 0.04, 0.4 },
			overlayColour10 = { 0.4, 0.007, 1 },
			animationNpcs = true,
			animationNpcsType = RSConstants.MAP_ANIMATIONS_ON_BOTH,
			animationContainers = true,
			animationContainersType = RSConstants.MAP_ANIMATIONS_ON_CLICK,
			animationEvents = true,
			animationEventsType = RSConstants.MAP_ANIMATIONS_ON_CLICK,
			animationVignettes = true,
			highlightReputation = true
		},
		loot = {
			filteredLootCategories = {},
			filteredItems = {},
			displayLoot = true,
			displayLootOnMap = true,
			lootTooltipPosition = "ANCHOR_LEFT",
			lootMinQuality = 0,
			filterItemsCompletedQuest = true,
			filterNotMatchingClass = false,
			filterNotMatchingFaction = true,
			filterAnimaItems = true,
			filterConduitItems = true,
			filterByExplorerResults = false,
			showingMissingMounts = true,
			showingMissingPets = true,
			showingMissingToys = true,
			showingMissingAppearances = true,
			showingMissingDrakewatcher = true,
			numItems = 10,
			numItemsPerRow = 10,
			tooltipsCommands = true,
			tooltipsCanImogit = false,
			covenantRequirement = true
		}
	}
}

---============================================================================
-- Sounds
---============================================================================

RSConstants.DEFAULT_SOUNDS = {
	["Achievement Sound"] = "Interface\\AddOns\\RareScanner\\Media\\achievmentsound1-4.ogg",
	["Alarm Clock"] = "Interface\\AddOns\\RareScanner\\Media\\alarmclockwarning2-4.ogg",
	["Boat Docking"] = "Interface\\AddOns\\RareScanner\\Media\\boatdockedwarning-4.ogg",
	["Siege Engineer Weapon"] = "Interface\\AddOns\\RareScanner\\Media\\fx_ograid_siege_weaponmachine_warning-4.ogg",
	["PVP Alliance"] = "Interface\\AddOns\\RareScanner\\Media\\pvpwarningalliance-4.ogg",
	["PVP Horde"] = "Interface\\AddOns\\RareScanner\\Media\\pvpwarninghorde-4.ogg",
	["Ready Check"] = "Interface\\AddOns\\RareScanner\\Media\\readycheck-4.ogg",
	["Horn"] = "Interface\\AddOns\\RareScanner\\Media\\gruntling_horn_bb-4.ogg",
	["Event Wardrum Ogre"] = "Interface\\AddOns\\RareScanner\\Media\\Event_wardrum_ogre-4.ogg",
	["Level Up"] = "Interface\\AddOns\\RareScanner\\Media\\levelup2-4.ogg",
}

RSConstants.EXTERNAL_SOUND_FOLDER = "Interface\\AddOns\\%s\\%s"

---============================================================================
-- CMD commands
---============================================================================

RSConstants.CMD_HELP = "help"
RSConstants.CMD_TOGGLE_MAP_ICONS = "tmi"
RSConstants.CMD_TOGGLE_ALERTS = "ta"
RSConstants.CMD_TOGGLE_RARES = "tr"
RSConstants.CMD_TOGGLE_RARES_ALERTS = "tra"
RSConstants.CMD_TOGGLE_EVENTS = "te"
RSConstants.CMD_TOGGLE_EVENTS_ALERTS = "tea"
RSConstants.CMD_TOGGLE_TREASURES = "tt"
RSConstants.CMD_TOGGLE_TREASURES_ALERTS = "tta"
RSConstants.CMD_TOGGLE_SCANNING_WORLD_MAP_VIGNETTES = "swmv"
RSConstants.CMD_TOMTOM_WAYPOINT = "waypoint"
RSConstants.CMD_TOGGLE_DRAGON_GLYPHS = "tdg"
RSConstants.CMD_OPEN_EXPLORER = "explorer"
RSConstants.CMD_RECENTLY_SEEN = "rseen"

---============================================================================
-- AtlasNames
---============================================================================

RSConstants.NPC_VIGNETTE = "VignetteKill"
RSConstants.NPC_VIGNETTE_ELITE = "VignetteKillElite"
RSConstants.NPC_LEGION_VIGNETTE = "DemonInvasion5"
RSConstants.NPC_NAZJATAR_VIGNETTE = "nazjatar-nagaevent"
RSConstants.NPC_WARFRONT_NEUTRAL_HERO_VIGNETTE = "Warfront-NeutralHero"
RSConstants.NPC_TORMENTORS_VIGNETTE = "Tormentors-Boss"
RSConstants.NPC_DIABLO_GOBLIN = "BuildanAbomination-32x32"
RSConstants.NPC_WARLOCK_PORTAL_GOBLIN = "WarlockPortal-Yellow-32x32"

RSConstants.CONTAINER_VIGNETTE = "VignetteLoot"
RSConstants.CONTAINER_ELITE_VIGNETTE = "VignetteLootElite"
RSConstants.CONTAINER_LOCKED_VIGNETTE = "vignetteloot-locked"
RSConstants.CONTAINER_ELITE_LOCKED_VIGNETTE = "vignettelootelite-locked"

RSConstants.EVENT_VIGNETTE = "VignetteEvent"
RSConstants.EVENT_ELITE_VIGNETTE = "VignetteEventElite"
RSConstants.EVENT_TORMENTORS_VIGNETTE = "Tormentors-Event"
RSConstants.EVENT_ZARALEK_CAVERN = "minimap-genericevent-hornicon-small"

---============================================================================
-- SpellIDs
---============================================================================

RSConstants.RACING_SPELL_ID = 369968

---============================================================================
-- MapIDS
---============================================================================

RSConstants.ALL_ZONES_CUSTOM_NPC = 0
RSConstants.ALL_ZONES = "all"
RSConstants.UNKNOWN_ZONE_ID = 0
RSConstants.TANAAN_JUNGLE_MAPID = 534
RSConstants.MECHAGON_MAPID = 1462
RSConstants.VALLEY_OF_ETERNAL_BLOSSOMS_MAPID = 1530
RSConstants.ULDUM_MAPID = 1527
RSConstants.THE_MAW_MAPID = 1543
RSConstants.ZERETH_MORTIS_MAPID = 1970
RSConstants.DRAGON_ISLES = 1978
RSConstants.THE_AZURE_SPAN = 2024
RSConstants.VALDRAKKEN = 2025
RSConstants.THE_PRIMALIST_FUTURE = 2085
RSConstants.ZARALEK_CAVERN = 2133

---============================================================================
-- NpcIDS
---============================================================================

RSConstants.CATACOMBS_CACHE = 358040
RSConstants.DOOMROLLER_ID = 95056
RSConstants.DEATHTALON = 95053
RSConstants.TERRORFIST = 95044
RSConstants.VENGEANCE = 95054
RSConstants.WINGFLAYER_CRUEL = 167078
RSConstants.GIEGER = 162741
RSConstants.FORGEMASTER_MADALAV = 159496
RSConstants.HARIKA_HORRID = 165290
RSConstants.VALFIR_UNRELENTING = 168647
RSConstants.ORATOR_KLOE_NPCS = { 161527, 161528, 161529, 161530 }
RSConstants.CRAFTING_NPCS = { 157294, 157308, 157307, 157312, 157309, 157310, 157311 }
RSConstants.DAFFODIL_NPCS = { 171690, 167724 }
RSConstants.ABUSE_POWER_GI_NPCS = { 159156, 159157 }
RSConstants.ABUSE_POWER_I_NPCS = { 159151, 156919, 156916, 156918 }
RSConstants.ABUSE_POWER_HI_NPCS = { 159153, 159152, 159155, 159154 }
RSConstants.RUNE_CONSTRUCTS_CONTAINERS = { 355036, 355037, 355038, 364531 }
RSConstants.GRAPPLING_GROWTH_CONTAINERS = { 352596, 354852, 354853 }
RSConstants.GREEDSTONE_CONTAINERS = { 354211, 354206 }
RSConstants.LUNARLIGHT_CONTAINERS = { 353771, 353770, 353772, 353773, 353769 }
RSConstants.CITADEL_LOYALTY_NPCS = { 156339, 156340 }
RSConstants.SWELLING_TEAR_NPCS = { 171040, 171013, 171041 }
RSConstants.VESPER_REPAIR_NPCS = { 160882, 160985 }
RSConstants.THEATER_PAIN_NPCS = { 168147, 168148 }
RSConstants.DAPPERDEW_NPCS = { 168135, 164415, 166135, 166138, 166139, 166140, 166142, 166145, 166146 }
RSConstants.ASCENDED_COUNCIL_NPCS = { 170832, 170833, 170834, 170835, 170836 }
RSConstants.FOUR_PEOPLE_NPCS = { 170301, 169827, 170301, 170302 }
RSConstants.BOUNDING_SHRROM_CONTAINERS = { 349793, 349797, 353330 }
RSConstants.RIPE_PURIAN_CONTAINERS = { 353643, 353503, 353205, 353500, 352754, 353516, 353325, 353019, 353252, 353314, 352998 }
RSConstants.RIFT_HIDDEN_ENTITIES = { 179883, 368645, 368646, 368647, 368648, 368649, 368650 }
RSConstants.RIFT_NPCS = { 179608, 179911, 179913, 179914, 369437, 369438, 369439, 369440 }
RSConstants.RIFT_NPCS_MAW = { 179735, 179853, 179851 }
RSConstants.RELIC_CACHE = { 369292, 369294, 369310 }
RSConstants.PILE_BONES = { 369297, 369295 }
RSConstants.SHARDHIDE_STASH = { 369296 }
RSConstants.CACHES_SWAGSNOUT_GROMIT = { 369292, 369294, 369310, 369297, 369295, 369296 }
RSConstants.STOLEN_ANIMA_VESSEL = { 368946, 368947, 368948, 368949, 368950, 368951, 368952, 368953 }
RSConstants.STOLEN_ANIMA_VESSEL_RIFT = { 369227, 369235, 369236 }
RSConstants.DISTURBED_DIRT = { 382029, 376386, 383733, 383734, 383735 }
RSConstants.OMINOUS_CONCHS_NPCS = { 193735, 193634, 193710, 197371, 193708, 193706 } --197411
RSConstants.CONTAINERS_WITHOUT_VIGNETTE = { 376582, 376583, 376585, 376579, 376584, 377587, 378010, 376580 }
RSConstants.MAGIC_BOUND_CHEST = { 376426, 385075, 385074 }
RSConstants.CONTAINER_WITH_NPC_VIGNETTE = { 192243 }
RSConstants.CONTAINERS_FORBIDDEN_REACH = { 386214, 386165, 386166, 386167, 386168, 386172, 386174, 386179, 386208, 386212, 386213 }
RSConstants.FORBIDDEN_REACH_ANCESTRAL_SPIRIT = 203388
RSConstants.GOBLIN_PORTAL = 205722
RSConstants.ZARALEK_CAVERN_LOAM_SCOUT = 204657
RSConstants.ELUSIVE_NPCS = { 204821, 204831, 202436, 202441, 194489, 194491, 195465, 195472, 195492, 195509, 195518, 195541 }
RSConstants.CONTAINERS_UNWAKING_ECHO = { 411447, 411463, 411465, 411466 }
RSConstants.RUMBLE_FOIL_BAG = { 386158, 386140, 386157, 387718, 387720, 387721, 405585, 392031, 405586, 392032, 405587, 387722, 405584, 387719 }
RSConstants.RUMBLE_COIN_BAG = { 387696, 387697, 385961, 386138, 386139, 387695, 385958 }
RSConstants.CONTAINERS_INFESTED_CACHE = { 339247, 339248, 339249, 339250, 339251 }
RSConstants.CONTAINERS_JANIS_STASH = { 281176, 281365, 281381, 281388, 281390, 282647, 282668 }
RSConstants.CONTAINERS_BLACK_EMPIRE_CACHE = { 335707, 335709, 335711, 335712, 335717, 334189, 334213, 334215, 334216, 334220, 334223 }
RSConstants.CONTAINERS_DARKSHORE_CACHE = { 320514, 320515, 320516, 320517, 320518 }
RSConstants.CONTAINERS_INVASIVE_MAWSHROOM = { 369327, 369329, 369330, 369331, 369332 }
RSConstants.CONTAINERS_LUNARLIGHT_POD = { 353681, 353683, 353684, 353685, 353686 }
RSConstants.CONTAINERS_AMATHET_CACHE = { 324413, 325973, 325974, 325981, 325984 }
RSConstants.CONTAINERS_VOID_SEEPED_CACHE = { 273443, 277637 }
RSConstants.CONTAINERS_LEGION_WAR_SUPPLIES = { 273519, 273521, 273523, 273524, 273527, 273528, 273533, 273535, 273538 }
RSConstants.CONTAINERS_STOLEN_ANIMA_VESSEL = { 369227, 369235, 369236 }
RSConstants.CONTAINERS_CURIOUS_GRAIN_SACK = { 303039, 303170 }
RSConstants.CONTAINERS_PUGILISTS_PRIZE = { 354115, 354116, 354121, 354122, 354123 }
RSConstants.CONTAINERS_SKYWARD_BELL = { 353690, 353691, 353867 }
RSConstants.CONTAINERS_BROKEN_BELL = { 353687, 353688, 353689 }
RSConstants.CONTAINERS_ENCHANTED_CHEST = { 297881, 353233 }
RSConstants.CONTAINERS_TEST_OF_PENITENCE = { 353875, 356819 }
RSConstants.CONTAINERS_DECAYED_HUSK = { 353306, 353323, 353324, 353326, 353327 }
RSConstants.CONTAINERS_SECRET_TREASURE = { 351487, 351540, 351541, 351542, 351543, 351544, 351545, 353336 }
RSConstants.CONTAINERS_MECHANIZED_CHEST = { 325659, 325660, 325661, 325662, 325663, 325664, 325665, 325666, 325667, 325668 }
RSConstants.CONTAINERS_TREASURE_CHEST = { 278456, 278459, 278460, 278461, 278462, 278694, 278713, 278716, 278793, 278795, 281903, 281904, 281905, 281906, 288604, 279325, 279352, 279366, 279367, 279373, 279378, 279379, 282721, 282722, 282723, 284408, 284409, 284410, 284411, 284412, 284413, 284414, 284415, 284416, 284417, 284418, 284419, 284420, 284421, 290770, 277336 }
RSConstants.CONTAINERS_ARCANE_CHEST = { 326394, 326401, 326402, 326403, 326404, 326405, 326406, 326407, 326408, 326409, 326410, 326411, 326412, 326413, 326414, 326415, 326416, 326417, 326418, 326419 }
RSConstants.CONTAINERS_EREDAR_WAR_SUPPLIES = { 271849, 272455, 272456, 272770, 272771, 273222 }
RSConstants.CONTAINERS_SHIMMERING_ANCIENT_MANA_CLUSTER = { 252448, 252450 }
RSConstants.CONTAINERS_SPROUTING_GROWTH = { 352596, 354852, 354853 }
RSConstants.CONTAINERS_BURIED_TREASURE_CHEST = { 293852, 293880, 293881, 293884 }
RSConstants.CONTAINERS_LOOSE_PARTS = { 311902, 311903 }
RSConstants.CONTAINERS_SMALL_TREASURE_CHEST = { 273900, 273902, 273903, 273905, 273910, 273917, 273918, 273919, 273955, 273956, 275070, 275071, 275074, 275076, 280751, 284469, 291201, 291204, 291211, 291213, 291217, 291222, 291223, 291224, 291225, 291226, 291227, 291228, 291229, 291230, 287531, 291244, 291246, 291254, 291255, 291257, 291258, 291259, 291263, 291264, 291265, 291266, 291267, 294311, 273901 }
RSConstants.CONTAINERS_FULL_GARRISON_CACHE = { 237722, 237724 }
RSConstants.CONTAINERS_MOGU_PLUNDER = { 334227, 334228, 334229, 334232, 334237, 334238 }
RSConstants.CONTAINERS_AMBERED_CACHE = { 339464, 339465, 339466, 339467, 339468 }
RSConstants.CONTAINERS_SILVER_STRONGBOX = { 352754, 352998, 353019, 353205, 353252, 353314, 353325, 353500, 353503, 353516, 353643 }
RSConstants.CONTAINERS_GARRISON_CACHE = { 236916, 237191 }
RSConstants.CONTAINERS_CURSED_TREASURE = { 272622, 287493 }
RSConstants.CONTAINERS_RUNEBOUND_COFFER = { 297893, 355036, 355037, 355038, 364531 }
RSConstants.CONTAINERS_HIDDEN_HOARD = { 353868, 353869, 353870, 353871, 353872, 353873 }
RSConstants.CONTAINERS_FAERIE_STASH = { 353329, 353330, 353331, 353332, 353333 }
RSConstants.CONTAINERS_A_DAMP_SCROLL = { 292673, 292674, 292675, 292676, 292677 }
RSConstants.CONTAINERS_DISTURBED_DIRT = { 376386, 382029, 383733, 383735, 383734 }
RSConstants.CONTAINERS_RIFTBOUND_CACHE = { 369437, 369438, 369439, 369440 }
RSConstants.CONTAINERS_GLOWING_ARCANE_TRUNK = { 326395, 326396, 326397, 326398, 326399, 326400, 329783, 332220 }
RSConstants.CONTAINERS_ELIXIR_OF_SHADOW_SIGHT = { 234703, 234704, 234705, 234734, 234735, 234736 }
RSConstants.CONTAINERS_RIFT_HIDDEN_CACHE = { 368645, 368646, 368647, 368648, 368649, 368650 }
RSConstants.CONTAINERS_DIM_LUNARLIGHT_POD = { 353769, 353770, 353771, 353772, 353773 }
RSConstants.CONTAINERS_MAGIC_BOUND_CHEST = { 376426, 385074, 385075 }
RSConstants.CONTAINERS_ANCIENT_EREDAR_CACHE = { 273301, 273407, 273412, 273414, 273415, 273439 }
RSConstants.CONTAINERS_NEST_OF_UNUSUAL_MATERIALS = { 369333, 369334, 369335, 369336, 369337 }
RSConstants.CONTAINERS_WAR_SUPPLY_CHEST = { 290135, 324043 }
RSConstants.CONTAINERS_MAWSWORN_CACHE = { 368205, 368206, 368207, 368208, 368213, 368214, 369141, 368876, 369339, 369341, 375272 }
RSConstants.CONTAINERS_HARMONIC_CHEST = { 355358, 380556 }
RSConstants.CONTAINERS_STONEBORN_SATCHEL = { 354108, 354109, 354110, 354111, 354112, 354113, 354114, 354186, 354187, 354188, 354189, 354190, 354191, 354192, 354193 }
RSConstants.CONTAINERS_DREAMSEED_CACHE = { 406117, 406138, 406121, 406106, 409220, 406129, 406354, 406119, 405303, 409224, 409227, 405930, 406134, 406116, 409848, 405487, 406142, 406956, 406130, 409225, 409844, 406977, 406124, 406143, 407006, 406123, 406148, 409223, 409221, 405932, 405321, 409226, 405929, 406107, 405931, 406356, 405320, 407001, 406128, 406954, 406120, 406118, 409847, 405488, 406135, 406147, 409228, 406955, 406355, 406139, 406998 }

-- NPCs that spawn after completing an event
RSConstants.NPCS_WITH_PRE_EVENT = {
-- EVENTID = NPCID
	-- Korthia
	[179759] = 179760;
	[180145] = 179859;
	[369247] = 179859;
	[180144] = 179802;
	[369130] = 179802;
	[179464] = 179472;
	[369444] = 180162;
	[180064] = 180042;
	[179969] = 179985;
	[180028] = 180032;
	[180013] = 180014;
	-- Zereth Mortis
	[183505] = 183516;
	[183781] = 183764;
	[182156] = 182155;
	[185612] = 181249;
	[182120] = 182114;
	[182161] = 182158;
	[182156] = 182155;
	[185836] = 180924;
	-- Bation
	[176543] = 171008;
	[171012] = 171040;
	[356756] = 167078;
	-- Revendredth
	[165230] = 165206;
	[166483] = 166521;
	[176347] = 160675;
	-- Ardenweald
	[164102] = 164093;
	[167874] = 167851;
	[168053] = 167721;
	-- Talador
	[84037] = 88494; 
	[77764] = 77750;
	-- Tanaan Jungle
	[90524] = 90519; 
	[243386] = 91227;
	-- Shadowlands (Draenor)
	[82426] = 75434; 
	-- Spires of Arak
	[82084] = 82050;
	[84918] = 84912;
	[84821] = 84833;
	[85758] = 85037;
	-- Nagrand (Draenor)
	[84275] = 84263;
	-- Frostfire Ridge
	[75235] = 72156;
	[74970] = 74971;
	-- Timeless Isle
	[71944] = 71919;
	[55421] = 72048;
	[220815] = 71864;
	-- The Maw
	[170315] = 170302;
	[169828] = 169827;
	[170305] = 170301;
	-- The Azure Span
	[379234] = 194270;
	-- Ohn'ahran Plains
	[193166] = 187559;
	-- The Azure Span
	[192747] = 192749;
	[190971] = 189822;
	-- The Forbidden Reach
	[386342] = 200619;
	[386343] = 200620;
	[386344] = 200621;
	[386345] = 200622;
	[386360] = 200722;
	[386358] = 200725;
	[386350] = 200730;
	[386348] = 200737;
	[386347] = 200738;
	[386351] = 200739;
	[386346] = 200740;
	[386340] = 200742;
	[386338] = 200743;
	[205722] = 205490;
	--Emerald Dream
	[209264] = 209113;
	[210300] = 209936;
	[210516] = 209893;
	[210132] = 209929;
	[214131] = 209929;
	[209980] = 209913;
	[210155] = 209898;
	[210083] = 209912;
	[210063] = 209915;
}

-- Contains that spawn after completing an event
RSConstants.CONTAINERS_WITH_PRE_EVENT = {
-- EVENTID = CONTAINERID
	-- Ardenweald
	[171475] = 354662;
	-- Zereth Mortis
	[185265] = 375403;
	[185502] = 375403;
	[185285] = 375413;
	[180507] = 369757;
	[185416] = 375493;
	-- Talador
	[77664] = 227793;
	-- Shadowlands (Draenor)
	[79805] = 230664;
	-- Frostfire Ridge
	[229366] = 229367;
	-- Dragonflight
	[191861] = 385074;
	[203225] = 396339;
	--Emerald Dream
	[212009] = 411065;
	[210732] = 409222;
	[212012] = 411067;
	[210538] = 408719;
	[212011] = 411066;
	[210060] = 407739;
}

-- NPCs that spawn after killing another NPC
RSConstants.NPCS_WITH_PRE_NPCS = {
	[165175] = 165152;
	[165206] = 165230;
	[166521] = 166483;
	[160675] = 176347;
}
	
-- 156480 Next door entity inside Torghast
-- 155660 Summons from the Depths
RSConstants.IGNORED_VIGNETTES = { 156480, 155660, 163373, 370467, 370466, 182160, 182668, 182667, 185261, 376210, 200002, 190034, 191125, 210081, 210084, 210544, 210550 }
RSConstants.NPCS_WITH_EVENT_VIGNETTE = { 72156, 154154, 154330, 164547, 164477, 160629, 175012, 157833, 166398, 164064, 162829, 157964, 162844, 171317, 170774, 162849, 170301, 170302, 170711, 170634, 170731, 172862, 172577, 158025, 158278, 170303, 179684, 179791, 179805, 177444, 180246, 179108, 179853, 179755, 179768, 179779, 179460, 179851, 179735, 169827, 203280 }
RSConstants.NPCS_WITH_CONTAINER_VIGNETTE = { 179883 }
RSConstants.CONTAINERS_WITH_NPC_VIGNETTE = { 369435, 398828 }
RSConstants.EVENTS_WITH_NPC_VIGNETTE = { 204131, 204211, 204747, 204768, 203278, 203950, 204101, 203065, 203702, 203889, 205006, 204710, 204967, 204732, 204389, 204423, 204460, 204763 }
RSConstants.NPCS_WITH_MULTIPLE_SPAWNS = { 69768, 69769, 69841, 69842, 70323 }
RSConstants.CONTAINERS_WITH_MULTIPLE_SPAWNS = { 375366, 375530, 375362, 375363, 375373, 375290, 376587, 382029, 376386, 383733, 383734, 383735, 383732, 386214, 386165, 386166, 386167, 386168, 386172, 386174, 386179, 386208, 386212, 386213, 401844, 401845, 408719 }
RSConstants.FIRIM_EXILE_OBJECTS = { 375973, 375982, 375983, 375984, 375985, 375986, 375987 }

---============================================================================
-- ItemIDs
---============================================================================

RSConstants.ITEMS_REQUIRE_NECROLORD = { 181815, 182080, 186489 }
RSConstants.ITEMS_REQUIRE_NIGHT_FAE = { 180730, 186492 }
RSConstants.ITEMS_REQUIRE_VENTHYR = { 180581, 180461, 186479 }
RSConstants.ITEMS_REQUIRE_KYRIAN = { 186483 }

---============================================================================
-- Achievements
---============================================================================

RSConstants.TALES_OF_EXILE_ACHIEVEMENT_ID = 15509

---============================================================================
-- Garrison cache
---============================================================================

RSConstants.GARRISON_CACHE_IDS = { 236916, 237191, 237724, 237722, 237723, 237720 }

---============================================================================
-- Eternal states
---============================================================================

RSConstants.ETERNAL_DEATH = -1
RSConstants.ETERNAL_OPENED = -1
RSConstants.ETERNAL_COMPLETED = -1
RSConstants.ETERNAL_COLLECTED = -1

---============================================================================
-- Textures
---============================================================================

RSConstants.TEXTURE_PATH = "Interface\\AddOns\\RareScanner\\Media\\Icons\\%s.blp"
RSConstants.GROUP_TOP_TEXTURE_FILE = "GroupT"
RSConstants.GROUP_RIGHT_TEXTURE_FILE = "GroupR"
RSConstants.GROUP_LEFT_TEXTURE_FILE = "GroupL"
RSConstants.NORMAL_NPC_TEXTURE_FILE = "OriginalSkull"
RSConstants.RED_NPC_TEXTURE_FILE = "RedSkullDark"
RSConstants.PINK_NPC_TEXTURE_FILE = "PinkSkullDark"
RSConstants.BLUE_NPC_TEXTURE_FILE = "BlueSkullDark"
RSConstants.LIGHT_BLUE_NPC_TEXTURE_FILE = "BlueSkullLight"
RSConstants.NORMAL_CONTAINER_TEXTURE_FILE = "OriginalChest"
RSConstants.RED_CONTAINER_TEXTURE_FILE = "RedChest"
RSConstants.PINK_CONTAINER_TEXTURE_FILE = "PinkChest"
RSConstants.BLUE_CONTAINER_TEXTURE_FILE = "BlueChest"
RSConstants.NORMAL_EVENT_TEXTURE_FILE = "OriginalStar"
RSConstants.RED_EVENT_TEXTURE_FILE = "RedStar"
RSConstants.PINK_EVENT_TEXTURE_FILE = "PinkStar"
RSConstants.BLUE_EVENT_TEXTURE_FILE = "BlueStar"
RSConstants.OVERLAY_SPOT_TEXTURE_FILE = "Overlay"
RSConstants.GUIDE_TRANSPORT_FILE = "Transport"
RSConstants.GUIDE_ENTRANCE_FILE = "Entrance"
RSConstants.GUIDE_FLAG_FILE = "Flag"
RSConstants.GUIDE_DOT_FILE = "Dot"
RSConstants.GUIDE_STEP1_FILE = "Number1"
RSConstants.GUIDE_STEP2_FILE = "Number2"
RSConstants.GUIDE_STEP3_FILE = "Number3"
RSConstants.GUIDE_STEP4_FILE = "Number4"
RSConstants.GUIDE_STEP5_FILE = "Number5"
RSConstants.GUIDE_STEP6_FILE = "Number6"
RSConstants.GUIDE_STEP7_FILE = "Number7"
RSConstants.GUIDE_STEP8_FILE = "Number8"
RSConstants.GUIDE_STEP9_FILE = "Number9"
RSConstants.DRAGON_GLYFH_FILE = "DragonGlyphSmall"
RSConstants.FIRE_STORM_ATLAS = "ElementalStorm-Lesser-Fire"
RSConstants.AIR_STORM_ATLAS = "ElementalStorm-Lesser-Air"
RSConstants.EARTH_STORM_ATLAS = "ElementalStorm-Lesser-Earth"
RSConstants.WATER_STORM_ATLAS = "ElementalStorm-Lesser-Water"
RSConstants.PROFFESION_ICON_ATLAS = "Professions-Crafting-Orders-Icon"
RSConstants.ACHIEVEMENT_ICON_ATLAS = "UI-Achievement-Shield-2"
RSConstants.HUNTING_PARTY_ICON_ATLAS = "Vehicle-Trap-Gold"
RSConstants.PRIMAL_STORM_ICON_ATLAS = "ElementalStorm-Lesser-Water"
RSConstants.NOT_TRACKABLE_ICON_ATLAS = "Islands-MarkedArea"
RSConstants.DREAMSURGE_ICON_ATLAS = "dreamsurge_hub-icon"
RSConstants.FYRAKK_ICON_ATLAS = "Fyrakk-Head-Icon-Grey"
RSConstants.WARCRAFT_RUMBLE_ICON_ATLAS = "Battlenet-ClientIcon-GRY"
RSConstants.DREAMSEED_ATLAS = "SeedPlanting-Full"

RSConstants.NORMAL_NPC_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.NORMAL_NPC_TEXTURE_FILE);
RSConstants.GROUP_NORMAL_NPC_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_NPC_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_NORMAL_NPC_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_NPC_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_NORMAL_NPC_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_NPC_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.RED_NPC_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.RED_NPC_TEXTURE_FILE);
RSConstants.GROUP_RED_NPC_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_NPC_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_RED_NPC_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_NPC_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_RED_NPC_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_NPC_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.PINK_NPC_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.PINK_NPC_TEXTURE_FILE);
RSConstants.GROUP_PINK_NPC_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_NPC_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_PINK_NPC_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_NPC_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_PINK_NPC_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_NPC_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.BLUE_NPC_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.BLUE_NPC_TEXTURE_FILE);
RSConstants.GROUP_BLUE_NPC_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_NPC_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_BLUE_NPC_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_NPC_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_BLUE_NPC_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_NPC_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.LIGHT_BLUE_NPC_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.LIGHT_BLUE_NPC_TEXTURE_FILE);
RSConstants.GROUP_LIGHT_BLUE_NPC_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.LIGHT_BLUE_NPC_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_LIGHT_BLUE_NPC_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.LIGHT_BLUE_NPC_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_LIGHT_BLUE_NPC_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.LIGHT_BLUE_NPC_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.NORMAL_CONTAINER_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.NORMAL_CONTAINER_TEXTURE_FILE);
RSConstants.GROUP_NORMAL_CONTAINER_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_NORMAL_CONTAINER_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_NORMAL_CONTAINER_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.RED_CONTAINER_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.RED_CONTAINER_TEXTURE_FILE);
RSConstants.GROUP_RED_CONTAINER_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_RED_CONTAINER_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_RED_CONTAINER_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.PINK_CONTAINER_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.PINK_CONTAINER_TEXTURE_FILE);
RSConstants.GROUP_PINK_CONTAINER_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_PINK_CONTAINER_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_PINK_CONTAINER_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.BLUE_CONTAINER_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.BLUE_CONTAINER_TEXTURE_FILE);
RSConstants.GROUP_BLUE_CONTAINER_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_BLUE_CONTAINER_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_BLUE_CONTAINER_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_CONTAINER_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.NORMAL_EVENT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.NORMAL_EVENT_TEXTURE_FILE);
RSConstants.GROUP_NORMAL_EVENT_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_EVENT_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_NORMAL_EVENT_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_EVENT_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_NORMAL_EVENT_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.NORMAL_EVENT_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.RED_EVENT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.RED_EVENT_TEXTURE_FILE);
RSConstants.GROUP_RED_EVENT_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_EVENT_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_RED_EVENT_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_EVENT_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_RED_EVENT_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.RED_EVENT_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.PINK_EVENT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.PINK_EVENT_TEXTURE_FILE);
RSConstants.GROUP_PINK_EVENT_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_EVENT_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_PINK_EVENT_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_EVENT_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_PINK_EVENT_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.PINK_EVENT_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.BLUE_EVENT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.BLUE_EVENT_TEXTURE_FILE);
RSConstants.GROUP_BLUE_EVENT_T_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_EVENT_TEXTURE_FILE, RSConstants.GROUP_TOP_TEXTURE_FILE));
RSConstants.GROUP_BLUE_EVENT_L_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_EVENT_TEXTURE_FILE, RSConstants.GROUP_LEFT_TEXTURE_FILE));
RSConstants.GROUP_BLUE_EVENT_R_TEXTURE = string.format(RSConstants.TEXTURE_PATH, string.format("%s%s", RSConstants.BLUE_EVENT_TEXTURE_FILE, RSConstants.GROUP_RIGHT_TEXTURE_FILE));
RSConstants.OVERLAY_SPOT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.OVERLAY_SPOT_TEXTURE_FILE);
RSConstants.GUIDE_TRANSPORT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_TRANSPORT_FILE);
RSConstants.GUIDE_ENTRANCE_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_ENTRANCE_FILE);
RSConstants.GUIDE_FLAG_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_FLAG_FILE);
RSConstants.GUIDE_DOT_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_DOT_FILE);
RSConstants.GUIDE_STEP1_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP1_FILE);
RSConstants.GUIDE_STEP2_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP2_FILE);
RSConstants.GUIDE_STEP3_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP3_FILE);
RSConstants.GUIDE_STEP4_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP4_FILE);
RSConstants.GUIDE_STEP5_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP5_FILE);
RSConstants.GUIDE_STEP6_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP6_FILE);
RSConstants.GUIDE_STEP7_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP7_FILE);
RSConstants.GUIDE_STEP8_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP8_FILE);
RSConstants.GUIDE_STEP9_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.GUIDE_STEP9_FILE);
RSConstants.DRAGON_GLYPH_TEXTURE = string.format(RSConstants.TEXTURE_PATH, RSConstants.DRAGON_GLYFH_FILE);

---============================================================================
-- Guide constants
---============================================================================

RSConstants.TRANSPORT = "T"
RSConstants.ENTRANCE = "E"
RSConstants.PATH_START = "P"
RSConstants.FLAG = "F"
RSConstants.DOT = "D"
RSConstants.STEP1 = "1"
RSConstants.STEP2 = "2"
RSConstants.STEP3 = "3"
RSConstants.STEP4 = "4"
RSConstants.STEP5 = "5"
RSConstants.STEP6 = "6"
RSConstants.STEP7 = "7"

---============================================================================
-- Dialogs
---============================================================================

RSConstants.APPLY_COLLECTIONS_LOOT_FILTERS = "RARESCANNER_APPLY_COLLECTIONS_LOOT_FILTERS"
RSConstants.EXPLORER_FILTERING_DIALOG = "RARESCANNER_EXPLORER_FILTERING_DIALOG"
RSConstants.EXPLORER_SCAN_NOT_DONE = "RARESCANNER_EXPLORER_SCAN_NOT_DONE"
RSConstants.TARGET_UNIT_WARNING = "RARESCANNER_TARGET_UNIT_WARNING"

---============================================================================
-- Explorer filters
---============================================================================

RSConstants.EXPLORER_FILTER_DROP_MOUNTS = 1
RSConstants.EXPLORER_FILTER_DROP_PETS = 2
RSConstants.EXPLORER_FILTER_DROP_TOYS = 3
RSConstants.EXPLORER_FILTER_DROP_APPEARANCES = 4
RSConstants.EXPLORER_FILTER_DROP_DRAKEWATCHER = 9
RSConstants.EXPLORER_FILTER_PART_ACHIEVEMENT = 5
RSConstants.EXPLORER_FILTER_DEAD = 6
RSConstants.EXPLORER_FILTER_FILTERED = 7
RSConstants.EXPLORER_FILTER_WITHOUT_COLLECTIBLES = 8

---============================================================================
-- Others
---============================================================================

RSConstants.RAID_WARNING_SHOWING_TIME = 3
RSConstants.MINIMUM_DISTANCE_PINS_WORLD_MAP = 0.005
RSConstants.TOOLTIP_MAX_WIDTH = 300

---============================================================================
-- Auxiliar functions
---============================================================================

function RSConstants.IsScanneableAtlas(atlasName)
	return RSConstants.IsEventAtlas(atlasName) or RSConstants.IsNpcAtlas(atlasName) or RSConstants.IsContainerAtlas(atlasName)
end

function RSConstants.IsEventAtlas(atlasName)
	return atlasName == RSConstants.EVENT_VIGNETTE or atlasName == RSConstants.EVENT_ELITE_VIGNETTE or atlasName == RSConstants.EVENT_TORMENTORS_VIGNETTE or atlasName == RSConstants.EVENT_ZARALEK_CAVERN
end

function RSConstants.IsNpcAtlas(atlasName)
	return atlasName == RSConstants.NPC_VIGNETTE or atlasName == RSConstants.NPC_LEGION_VIGNETTE or atlasName == RSConstants.NPC_VIGNETTE_ELITE or atlasName == RSConstants.NPC_NAZJATAR_VIGNETTE or atlasName == RSConstants.NPC_WARFRONT_NEUTRAL_HERO_VIGNETTE or atlasName == RSConstants.NPC_TORMENTORS_VIGNETTE or atlasName == RSConstants.NPC_DIABLO_GOBLIN or atlasName == RSConstants.NPC_WARLOCK_PORTAL_GOBLIN
end

function RSConstants.IsContainerAtlas(atlasName)
	return atlasName == RSConstants.CONTAINER_VIGNETTE or atlasName == RSConstants.CONTAINER_ELITE_VIGNETTE or atlasName == RSConstants.CONTAINER_LOCKED_VIGNETTE or atlasName == RSConstants.CONTAINER_ELITE_LOCKED_VIGNETTE
end
