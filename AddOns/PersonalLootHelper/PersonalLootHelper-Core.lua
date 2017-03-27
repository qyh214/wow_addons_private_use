--[[

-----------------------------------------------
Announce logic psuedocode 

Default isAnnouncer to false

In PerformNotify:
	If Notify Group
		If self is group lead
			isAnnouncer = true
		Else	
			Request announce via SendAddonMessage, telling them whether you're the group lead
			Wait 300ms, queue responses
			If no response in 300ms
				isAnnouncer = true
			else
				Loop through responses
				If other addon is already announcer
					isAnnouncer = false
				Else
					If you are character with lowest (!assistant + name) then
						isAnnouncer = true
					Else
						isAnnouncer = false

In AddonMessage listener:
	If received request to announce:
		If Notify Group
			If you are group lead tell other addon you're the announcer
			If you are announcer
				If other addon is not group leader, tell other addon you're the announcer
				Else isAnnouncer = false
			Else tell other addon your character name
	
When you change your options to turn Notify Group off, set isAnnouncer back to false
When PLH becomes disabled, set isAnnouncer to false	
-----------------------------------------------	
	
Changelog

20170323 - 1.23
	Added 7.2 trinkets
	
20170312 - 1.22
	Fixed bug that could cause raid frames to be non-responsive after PLH showed loot in them
		note:  hide tooltip in UnhighlightRaidFrames()

20170301 - 1.21
	Added option to display items that can be traded to you directly in the raid frames to make it easier to find people who have loot that
		you may want and to make it easier to compare that loot to what you have equipped (hold shift over item for comparison).
		A future version of PLH will also indicate players who can receive items you've looted directly in the raid frames.
	note:  added PLH_HIGHLIGHT_RAID_FRAMES, HighlightRaidFrames(), and related
		
	Added option to exclude notifications if character level is too low to equip an item
		note: added PLH_CHECK_CHARACTER_LEVEL

	Decoupled "coordinate rolls" mode from "notify group" mode, and enabled raid assistants to perform roll coordination
		note: added PLH_COORDINATE_ROLLS and PLH_NOTIFY_GROUP; removed references to PLH_NOTIFY_MODE except to set values of the new global variables
		
	Removed case sensitivity from trade whispers when "coordinate rolls" is active; also permitted "[item] trade" in addition to existing "trade [item]"
		note: in ProcessWhisper()
	
20170218 - 1.20
	Added check to see if a character is a high enough level to equip an item that drops (to fix recommendations in holiday and TW dungeons)
		note:  added check in IsEquippableItemForCharacter

20170126 - 1.19
	Resolved "script ran too long" error
		note:  Reduced calls to PLH_GetRelicType() in IsAnUpgradeForCharacter()

20170125 - 1.18
	Fixed bug that was cauing PLH to activate even if loot method was set to "Master Looter"

	Disabled PLH in BGs & arena
	
	Removed PLH enabled/PLH disabled announcements

	Removed PLH whispers (for coordinate rolls mode);
		players can still whisper "trade" or "trade [item]" to initiate rolls, but there will be less whisper spam now

	Fixed bug in "coordinate rolls" mode where PLH would sometimes tell players that PLH did not have a record of the item they looted
		note:  fixed by moving the addition of the looted item to whisperedItems[] earlier in PerformNotify()

	Fixed bug that was causing trinkets to not be evaluated properly
		note:  moved the trinket eligibility check before the primary attribute check in IsEquippableItemForCharacter

	Added missing ToV and Nightbane (Karazhan) trinkets

	Fixed bug that was causing rolls for off-spec relics to be incorrectly ignored
		note:  added off-spec relic check back into IsEquippableItemForCharacter
		
20161025 - 1.17
	Updated for 7.1
	
20161015 - 1.16
	Public
		Added ability for players to whisper the roll coordinator with 'trade [item]' in Coordinate Rolls mode to initiate rolls for a specific item; for example, when PLH can't determine their item is tradeable because they have lower ilvl equipped but higher ilvl in their bags
		Resolved bug where PLH would ignore 'trade' whispers from looters in Coordinate Rolls mode when PLH only found one other group member for whom the item would be an upgrade
		Resolved bug where PLH would sometimes declare people's rolls as ineligible in Coordinate Rolls mode even though they could equip the item
		Added support for BNET whispers in Coordinate Rolls mode (note: only works for 'trade' whispers, not 'trade [item]' whispers)
		Added support for 7.1 trinkets
	Private
		In WhisperReceivedEvent, add functionality for 'trade [item]'
		In PerformNotify, add looted item to whisperedItems array even if only 1 other person can use the item
		Added 'or groupInfoCache[name] == nil' check for initial class/etc population in UpdateGroupInfoCache
		Added BNWhisperReceivedEvent and related - note that it won't work when the bnet whisper is 'trade [item]' because bnet whispers strip off the color-coding of the item link

20161015 - 1.15
	Public
		Removed group notification from LFR, regardless of whether or not Notify Group is set
		Set default Notify Mode to "self" instead of "group" for new users
		Resolved bug where sometimes PLH would tell someone their loot wasn't found after notifying them in Coordinate Rolls mode
		Resolved bug where sometimes high rolls would be incorrectly ignored in Coordinate Rolls mode
		
	Private
		Added LFR check to PerformNotify
		Changed value of DEFAULT_NOTIFY_MODE to "self"
		Added realm checked to sender name in WhisperReceivedEvent
		Added tonumber in PLH_EndRolls()
	
20160921 - 1.14
	Public
		Fixed bug that caused options to reset upon login for users who also have the addon Oilvl (or other addons that call the options panel 'okay' behind the scenes) installed
		
	Private
		Create options panel after ADDON_LOADED event
		Set checkboxes on options panel during panel creation vs. waiting for the OnShow event

20160920 - 1.13
	Public
		Fixed bug that was causing PLH to evaluate loot received via bonus roll
	
	Detailed
		Added LOOT_ITEM_SELF_PATTERN and LOOT_ITEM_PATTERN

20160919 - 1.12
	Public
		Limited the maximum number of times that we inspect a character vs. continually trying to inspect them if they're missing a relic or piece of gear
		Redesigned the interface options screen to update checkboxes when the frame is displayed vs. updating for each checkbox
	
	Detailed
		Added InspectCount to groupInfoCache
		Many changes to config
			change OptionsBaseCheckButtonTemplate into InterfaceOptionsCheckButtonTemplate
			set all values in parent frame's onShow event vs. onShow events for each checkbox
			add version to display

20160917 - 1.11
	Public
		Fixed options panel to use unique names for each checkbox frame, hopefully resolving the issue that some users experienced of settings resetting
	
	Detailed
		Changed to expect 2 relics instead of 1 relic at level 110
		Fix taint error on _ in GetEquippedRelic
		Removed test file from .toc
		Call OpenToCategory twice instead of using BlizzBugsSuck work-around
		Fixed frame names in -Config; it was naming many frames the same, which may have caused peoples' settings to reset

20160914 - 1.10
	Public
		Added international client support
	
	Detailed
		Localization in:
			LootReceivedEvent (use arguments vs. string parse)
			RollReceivedEvent (use PLH_RANDOM_ROLL_RESULT_PATTERN)
			util - PLH_GetRealILVL (use PLH_ITEM_LEVEL_PATTERN)
			util - PLH_IsBoundToPlayer (use binding constants from _G)
			util - PLH_GetRelicType (use PLH_RELIC_TOOLTIP_TYPE_PATTERN)
			IsRelic (use item class/subclass)
			ValidGear (use item class/subclass)
			IsTrinketUsable - use item ID instead of item name
			
20160913 - 1.9
	Public
		Fixed bug that caused relics to be ignored
		Eliminated loading of unit test file - saves memory and may prevent the setting reset issue that some are having
		
	Detailed
		Added relic check to ShouldBeEvaluated
		Added hack to UpdateGroupInfoCache to check item 2nd time to hopefully fully cache it
		Reverted back to setting default options based on ADDON_LOADED instead of PLAYER_ENTERING_WORLD
		Commented out PersonalLootHelper-test.lua in toc file

20160912 - 1.8
	Public
		Added support for trinkets that Wowhead identifies as being usable by "unknown":  Ettin Fingernail, Padawsen's Unlucky Charm, Unstable Arcanocrystal, Thrice-Accursed Compass, Chrono Shard, and Horn of Valor
		Fixed bug when checking eligibility during rolls in Coordinate Rolls mode
		Fixed LUA error reported in ticket #2
	
	Detailed
		Added trinkets that have an "unknown" usable by attribute per wowhead:  http://www.wowhead.com/items/armor/trinkets/role:6?filter=166;7;0
		Check for fullname in RollReceivedEvent
		Added nil check to GroupMemberInfoChangedEvent

20160912 - 1.7
	Public
		Changed timing for saved variables being initialized to hopefully address reports of saved variables being reset
			(note: I have been unable to duplicate this reported bug on my end; if your options still reset after version 1.7,
			please let me know via comment or ticket on curse!)
		Added error checking to resolve reported LUA error

	Detailed
		Changed initialize to fire after PLAYER_ENTERING_WORLD instead of ADDON_LOADED since people are reporting variables being reset
		Added nil checking to PLH_GetFullName
		Removed non-localized reference to spec variable in UpdateGroupInfoCache
		Localized itemPrimaryAttribute in IsEquippableItemForCharacter
		Localized _ in LootReceivedEvent

20160910 - 1.6
	Public
		Fixed bugs that could rarely cause LUA errors
		Fixed issue that could result in an excessive number of requests to inspect players who only have 1 relic slotted
	
	Detailed
		Added nil check to PLH_GetUnitNameWithRealm
		Made variable local in PLH_GetUnitGUIDFromFullname
		Reduced NUM_EXPECTED_RELICS from 2 to 1 since many people still seem to only have 1 relic equipped even at level 110!
	
20160908 - 1.5
	Public
		Fixed bug that could cause addon options to reset (for real this time!)
		
	Detailed
		Added check to Initialize to ensure this addon was the source of the ADDON_LOADED event

20160908 - 1.4
	Public
		Added support for Artifact Relics
		Fixed bug whereby sometimes multiple notifications would be given for the same item

	Known Limitations
		Personal Loot Helper cannot determine whether an Artifact Relic is an upgrade for a character's offspec since it has no way of determining what relics are slotted into the offspec Artifact
	
	Detailed
		Added ValidRelics, PLH_GetRelicType, GetEquippedRelic
		Added relic evaluation to IsEquippableItemForCharacter and IsAnUpgradeForCharacter
		Added relics to cache and expected item count
		Checked if frames already exist in Initialize() to prevent creating duplicate listeners

20160903 - 1.3
	Public
		Fixed bug that could result in incorrect recommendations for rings, trinkets, and weapons
		Fixed bug that could cause addon options to reset
		Increased number of group member names that PLH will show a recommendation for from 3 to 4; beyond that, it will state "and others"
		Modified notification text to say "...[item] is an ilvl upgrade..." vs. "...[item] is an upgrade..." to avoid the impression that the addon is doing any type of dps simultation to determine whether an item is truly an upgrade

	Detailed
		Fixed slot IDs to use numbers instead of strings in IsAnUpgradeForCharacter
		Changed Initialize() to be called by an event listener on ADDON_LOADED instead of called directly
		Increased MAX_NAMES_TO_SHOW from 3 to 4
		Commented out some debug statements and calls to PLH_PrintCache to reduce debug spam
		Modified text in PerformNotify
	
20160901 - 1.2
	Public
		Added ability for users to limit evaluations to characters' current spec only (in interface options); by default, PLH will consider an item as a possible upgrade as long as it is usable by ANY of the character's possible specilizations
		Added cache refreshes when players change specs or change equipped gear to ensure evaluations are done with up-to-date spec/gear
		Added support for evaluating whether Legion trinkets are upgrades based on class/spec.  Note that pre-Legion trinkets will not be evaluated.
	
	Detailed
		Added PLH_CURRENT_SPEC_ONLY to IsAnUpgradeForCharacter and interface options screen
		Added PLAYER_SPECIALIZATION_CHANGED listener to update cache when a group member's spec changes
		Added UNIT_INVENTORY_CHANGED listener to update cache when a player's gear changes
		Cleaned up comments to reflect current logic
		Added GetExpectedItemCount to determine how many items should be cached by class/spec instead of assuming 15 for everyone
		Added TRINKET_arrays, IsTrinketUsable, and logic in IsEquippableItemForCharacter to evaluate trinkets

20160830 - 1.1
	Public
		Added logic to limit the upgrade evaluation to gear that is appropriate for the character's possible specs based on the item's primary attribute (str/int/agi)
			Note: will add future enhancement to allow users to select an "evaluate current spec only" option; for now I
			default it to consider items if they're equippable by ANY of the character's specs since players may queue for a spec other than their main spec
		Fixed evaluation of cloaks; previously only considered cloth-wearers as eligible to equip cloaks
		Minor performance improvements, particularly when in a large raid group
		Fixed /plh to open directly to Personal Loot Helper options on first try
		
	Detailed
		In PopulateGroupCache(), only refresh cache if it has been more than 3 seconds since the last refresh
		In IsCharacterInGroup, eliminate redundant call to GetRaidRosterInfo()
		Copy code from BlizzBugsSuck.lua to fix InterfaceOptionsFrame_OpenToCategory not opening to addon
		In UpdateGroupInfoCache(unit), cache the character's Spec, and in PLH_GetItemCountFromCache subtract 2 since we added Spec
		In IsEquippableItemForCharacter, consider the item equippable for every class if it's a cloak
		In IsEquippableItemForCharacter, evaluate the character's spec vs. the primary attribute of the item
		Added PLH_TestItems()
		
The general flow is as follows:
LootReceivedEvent()				triggered when loot is received by anyone in the group
  --> PerformNotify()			if loot is a tradeable and is an upgrade for someone in group, notifies based on users' preferred Notify Mode
								if Coordinate Rolls mode then flow continues as follows:
    --> WhisperReceivedEvent()  triggered when we receive a 'TRADE' whisper from a person who looted a tradeable item
      --> AskForRolls()			prompts the group to roll for the item
        --> PLH_EndRolls()			notifies the group who won the roll

Known Limitations:
	As of version 1.10, Personal Loot Helper works on non-english clients!  However, the notifications provided by
		PLH are all in english.
	If the user reloads their UI or logs out, all state is lost - the cache will be lost and any pending rolls will remain uncompleted
	If a player receives more than 1 item of personal loot, only their last item will be eligible for rolls when they
	   reply to the addon's request to trade the item(s)
	The addon assumes everyone in the group is eligible to receive tradeable loot; it doesn't check whether everyone
		was within range of the kill and not already loot-locked
	The addon doesn't properly check if tier tokens can be used or are upgrades, but that should be a moot point for
	   Legion since tier will drop as actual gear vs. tier tokens when loot method is personal
	If multiple people are running the addon in Notify Group mode, then each of them will send a message notifying the
	   group of the loot.  There's no straightforward foolproof way around this, so users will have to coordinate
	   among themselves to switch to Notify Self mode if it becomes too spammy.
	Players cannot inspect other characters while the player is dead.  If you die & reload, the item cache will be
	   empty until the next time an event that triggers a cache refresh is received.
	The addon assumes that any loot received is part of the Personal Loot system, if Personal Loot is enabled.  However,
	   items can be obtained other ways - for example, someone using a baleful token to create a baleful item.  Those
	   items are not part of the Personal Loot system, but PLHelper cannot distinguish them from regular loot.
	Trinket evaluation is hardcoded for Legion items only; trinkets prior to Legion will not be evaluated

TODO Refactoring
	refactor - get constants for slotid, spec, etc. from _G instead of hard-coding
	refactor - make sure we properly use name/character/unit/guid everywhere to avoid confusion...
			don't even use 'character'; it's confusing; just use name, unit, or guid
	refactor - rename all uses of PLHelper to PLH
	refactor - can probably change queuedRollOwner and queuedRollItem now that I understand lua arrays better; search 'key', for example
	refactor - clean up unit test lua
	refactor - clean up comments; reflect current logic
	refactor - since PLH_GetUnitNameWithRealm() operates on units, can we replace all of its calls with UnitFullName(unit)?
			easy way to test this:  change implementation of PLH_GetUnitNameWithRealm(unit) to call UnitFullName(unit) and see
			what happens!
	comments - update to reflect the approach to looping logic; just using outer loop now; no inner retry logic
  
Future enhancement ideas:
	if you have addon installed, get a popup to decide what to do vs. a whisper?
	option for roll timers - auto-finish rolls after [X] seconds or never, timers for roll warnings
	add ability to cancel rolls?
	add localization; see http://lua-users.org/wiki/StringLibraryTutorial for defining string constants
	add a 'Who Else is Running PLHelper?' button to the config screen, which will use SendAddonMessage to query
	   for other instances of PLHelper, and report back the selected Notify Mode of each (to help coordinate with
	   making sure only 1 person is running in Notify Group mode)
	also check for gem slots & tertiary stats when determining if an item is an upgrade
]]--

-- slash command
SLASH_PLHelperCommand1 = '/plh'

local NOTIFY_MODE_SELF = 1
local NOTIFY_MODE_GROUP = 2
local NOTIFY_MODE_COORDINATE_ROLLS = 3

local DEFAULT_NOTIFY_MODE = NOTIFY_MODE_SELF
local DEFAULT_INCLUDE_BOE = false
local DEFAULT_MIN_ILVL = 528  -- personal loot was introduced with Siege of Orgrimmar, which started at ilvl 528
local DEFAULT_MIN_QUALITY = 3  -- Rare
local DEFAULT_DEBUG = false
local DEFAULT_CURRENT_SPEC_ONLY = false
local DEFAULT_CHECK_CHARACTER_LEVEL = true
local DEFAULT_HIGHLIGHT_RAID_FRAMES = true
local DEFAULT_HIGHLIGHT_SIZE = 20

local TRADE_MESSAGE = 'TRADE'  -- added some hardcording in ProcessWhisper for various way people may offer to trade items; customize text there if needed (ex: foreign languages)
local DELAY_BETWEEN_ROLLS = 4 -- in seconds
local UNHIGHLIGHT_DELAY = 105  -- in seconds
local DELAY_BETWEEN_INSPECTIONS = 3  -- in seconds
local MAX_INSPECT_LOOPS = 3    -- maximum # of times to retry calling NotifyInspect on all members in the roster for whom we've cached fewer than the expected number of items
local NUM_EXPECTED_ITEMS = 15 -- number of items we expect each person to have equipped (based on having something in every gear) plus 3 relics
	-- slot; if we've cached fewer than that amount of items for a character, we'll include that character in additional
	-- inspect loops.
--local MAX_INSPECT_RETRIES = 2  -- maximum # of times to retry calling NotifyInspect for a specific character if we don't get an INSPECT_READY
local NUM_EXPECTED_RELICS_110 = 3
local NUM_EXPECTED_RELICS_101 = 1
local MAX_INSPECTS_PER_CHARACTER = 5
local MAX_NAMES_TO_SHOW = 4
local PLH_RELICSLOT = 1000  -- for indexing relics in groupInfoCache

local DEATH_KNIGHT = select(2, GetClassInfo(6))
local DEMON_HUNTER = select(2, GetClassInfo(12))
local DRUID = select(2, GetClassInfo(11))
local HUNTER = select(2, GetClassInfo(3))
local MAGE = select(2, GetClassInfo(8))
local MONK = select(2, GetClassInfo(10))
local PALADIN = select(2, GetClassInfo(2))
local PRIEST = select(2, GetClassInfo(5))
local ROGUE = select(2, GetClassInfo(4))
local SHAMAN = select(2, GetClassInfo(7))
local WARLOCK = select(2, GetClassInfo(9))
local WARRIOR = select(2, GetClassInfo(1))

local ValidGear = {
--	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
--	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },

--	{ DEMON_HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ DEMON_HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ DEMON_HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WARGLAIVE },

--	{ DRUID, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ DRUID, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ DRUID, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },

--	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS },

	{ MAGE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ MAGE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND },

--	{ MONK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ MONK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ MONK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },

--	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
--	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE },
	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },

	{ PRIEST, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ PRIEST, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND },

--	{ ROGUE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ ROGUE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ ROGUE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS },

--	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },

	{ WARLOCK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ WARLOCK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND },

--	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
--	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE },
	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS }
}

local ValidRelics = {
	[250] = {RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_IRON}, -- Blood DK
	[251] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FROST}, -- Frost DK
	[252] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_BLOOD}, -- Unholy DK

	[577] = {RELIC_SLOT_TYPE_FEL, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FEL}, -- Havoc DH
	[581] = {RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FEL}, -- Vengeance DH

	[102] = {RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_ARCANE}, -- Balance Druid
	[103] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_LIFE}, -- Feral Druid
	[104] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_LIFE}, -- Guardian Druid
	[105] = {RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_LIFE}, -- Restoration Druid

	[253] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_IRON}, -- Beast Mastery Hunter
	[254] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_LIFE}, -- Marksmanship Hunter
	[255] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD}, -- Survival Hunter

	[62] = {RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_ARCANE}, -- Arcane Mage
	[63] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FIRE}, -- Fire Mage
	[64] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FROST}, -- Frost Mage

	[268] = {RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON}, -- Brewmaster Monk
	[270] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_WIND}, -- Mistweaver Monk
	[269] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_WIND}, -- Windwalker Monk

	[65] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_HOLY}, -- Holy Paladin
	[66] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_ARCANE}, -- Protection Paladin
	[70] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_HOLY}, -- Retribution Paladin

	[256] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_HOLY}, -- Discipline Priest
	[257] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_HOLY}, -- Holy Priest
	[258] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW}, -- Shadow Priest

	[259] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD}, -- Assassination Rogue
	[260] = {RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_WIND}, -- Outlaw Rogue
	[261] = {RELIC_SLOT_TYPE_FEL, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FEL}, -- Subtlety Rogue

	[262] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_WIND}, -- Elemental Shaman
	[263] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_WIND}, -- Enhancement Shaman
	[264] = {RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_LIFE}, -- Restoration Shaman

	[265] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW}, -- Affliction Warlock
	[266] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_FEL}, -- Demonology Warlock
	[267] = {RELIC_SLOT_TYPE_FEL, RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_FEL}, -- Destruction Warlock

	[71] = {RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW}, -- Arms Warrior
	[72] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON}, -- Fury Warrior
	[73] = {RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_FIRE}, -- Protection Warrior
}

-- IDs for following are from http://wow.gamepedia.com/API_GetInspectSpecialization
local PrimaryAttributes = {
	{ DEATH_KNIGHT, 'Any', ITEM_MOD_STRENGTH_SHORT },
	
	{ DEMON_HUNTER, 'Any', ITEM_MOD_AGILITY_SHORT },
	
	{ DRUID, 102, ITEM_MOD_INTELLECT_SHORT },			-- balance
	{ DRUID, 103, ITEM_MOD_AGILITY_SHORT },			-- feral
	{ DRUID, 104, ITEM_MOD_AGILITY_SHORT },			-- guardian
	{ DRUID, 105, ITEM_MOD_INTELLECT_SHORT },			-- restoration
	
	{ HUNTER, 'Any', ITEM_MOD_AGILITY_SHORT },
	
	{ MAGE, 'Any', ITEM_MOD_INTELLECT_SHORT },

	{ MONK, 268, ITEM_MOD_AGILITY_SHORT },				-- brewmaster
	{ MONK, 270, ITEM_MOD_INTELLECT_SHORT },			-- mistweaver
	{ MONK, 269, ITEM_MOD_AGILITY_SHORT },				-- windwalker
	
	{ PALADIN, 65, ITEM_MOD_INTELLECT_SHORT },			-- holy
	{ PALADIN, 66, ITEM_MOD_STRENGTH_SHORT },			-- protection
	{ PALADIN, 70, ITEM_MOD_STRENGTH_SHORT },			-- retribution

	{ PRIEST, 'Any', ITEM_MOD_INTELLECT_SHORT },
	
	{ ROGUE, 'Any', ITEM_MOD_AGILITY_SHORT },

	{ SHAMAN, 262, ITEM_MOD_INTELLECT_SHORT },			-- elemental
	{ SHAMAN, 263, ITEM_MOD_AGILITY_SHORT },			-- enhancement
	{ SHAMAN, 264, ITEM_MOD_INTELLECT_SHORT },			-- restoration
	
	{ WARLOCK, 'Any', ITEM_MOD_INTELLECT_SHORT },
	
	{ WARRIOR, 'Any', ITEM_MOD_STRENGTH_SHORT }
}
	
local OffspecAttributes = {
	{ DRUID, 102, ITEM_MOD_AGILITY_SHORT },			-- balance
	{ DRUID, 103, ITEM_MOD_INTELLECT_SHORT },			-- feral
	{ DRUID, 104, ITEM_MOD_INTELLECT_SHORT },			-- guardian
	{ DRUID, 105, ITEM_MOD_AGILITY_SHORT },			-- restoration

	{ MONK, 268, ITEM_MOD_INTELLECT_SHORT },			-- brewmaster
	{ MONK, 270, ITEM_MOD_AGILITY_SHORT },				-- mistweaver
	{ MONK, 269, ITEM_MOD_INTELLECT_SHORT },			-- windwalker

	{ PALADIN, 65, ITEM_MOD_STRENGTH_SHORT },			-- holy
	{ PALADIN, 66, ITEM_MOD_INTELLECT_SHORT },			-- protection
	{ PALADIN, 70, ITEM_MOD_INTELLECT_SHORT },			-- retribution

	{ SHAMAN, 262, ITEM_MOD_AGILITY_SHORT },			-- elemental
	{ SHAMAN, 263, ITEM_MOD_INTELLECT_SHORT },			-- enhancement
	{ SHAMAN, 264, ITEM_MOD_AGILITY_SHORT }			-- restoration
	
}

-- note that the following is only valid for Legion; previously different weapons were possible (ex: feral staff vs. 2 fist weapons)
-- adding 3 for relics
local ExpectedItemCount = {			-- number of items expected by spec, assuming person has gear in every slot
	{ DEATH_KNIGHT, 250, 15 },			-- blood
	{ DEATH_KNIGHT, 251, 16 },			-- frost
	{ DEATH_KNIGHT, 252, 15 },			-- unholy
	
	{ DEMON_HUNTER, 577, 16 },			-- havoc
	{ DEMON_HUNTER, 581, 16 },			-- vengeance
	
	{ DRUID, 102, 15 },					-- balance
	{ DRUID, 103, 16 },					-- feral
	{ DRUID, 104, 16 },					-- guardian
	{ DRUID, 105, 15 },					-- restoration
	
	{ HUNTER, 253, 15 },					-- beast mastery
	{ HUNTER, 254, 15 },					-- marksmanship
	{ HUNTER, 255, 15 },					-- survival
	
	{ MAGE, 62, 15 },						-- arcane
	{ MAGE, 63, 16 },						-- fire
	{ MAGE, 64, 15 },						-- frost

	{ MONK, 268, 15 },					-- brewmaster
	{ MONK, 270, 15 },					-- mistweaver
	{ MONK, 269, 16 },					-- windwalker
	
	{ PALADIN, 65, 15 },					-- holy
	{ PALADIN, 66, 16 },					-- protection
	{ PALADIN, 70, 15 },					-- retribution

	{ PRIEST, 256, 15 },					-- discipline
	{ PRIEST, 257, 15 },					-- holy
	{ PRIEST, 258, 16 },					-- shadow
	
	{ ROGUE, 259, 16 },					-- assassination
	{ ROGUE, 260, 16 },					-- outlaw
	{ ROGUE, 261, 16 },					-- subtlety

	{ SHAMAN, 262, 16 },					-- elemental
	{ SHAMAN, 263, 16 },					-- enhancement
	{ SHAMAN, 264, 16 },					-- restoration
	
	{ WARLOCK, 256, 15 },					-- affliction
	{ WARLOCK, 266, 16 },					-- demonology
	{ WARLOCK, 267, 15 },					-- destruction
	
	{ WARRIOR, 71, 15 },					-- arms
	{ WARRIOR, 72, 16 },					-- fury
	{ WARRIOR, 73, 16 }					-- protection
}

--[[
to easily populate these arrays:
	wowhead search trinkets -> usable by "whichever" -> added in expansion/patch; also ID > 0
	paste into OpenOffice
	=concatenate(b1;", -- ";d1)
	ensure curly quotes are off in tools -> autocorrect options -> localized options
	to obtain IDs: http://www.wowhead.com/items/armor/trinkets/role:1?filter=166:151;7:1;0:0#0-3+2
]]--	
local TRINKET_AGILITY_DPS = {

	-- 7.2 trinkets
	147275, -- Beguiler's Talisman
	144477, -- Splinters of Agronax
	147011, -- Vial of Ceaseless Toxins
	147012, -- Umbral Moonglaives
	147016, -- Terror From Below
	147017, -- Tarnished Sentinel Medallion
	147018, -- Spectral Thurible
	147009, -- Infernal Cinders
	147015, -- Engine of Eradication
	147010, -- Cradle of Anguish
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142506, -- Eye of Guarm
	142166, -- Ethereal Urn
	
	-- 7.1 trinkets
	140027, -- Ley Spark
	142164, -- Toe Knee's Promise
	142160, -- Mrrgria's Favor
	142167, -- Eye of Command
	142165, -- Deteriorated Construct Core
	142159, -- Bloodstained Handkerchief
	142157, -- Aran's Relaxing Ruby

	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141537, -- Thrice-Accursed Compass
	141482, -- Unstable Arcanocrystal
	140794, -- Arcanogolem Digit
	140806, -- Convergence of Fates
	140808, -- Draught of Souls
	140796, -- Entwined Elemental Foci
	140801, -- Fury of the Burning Sky
	140798, -- Icon of Rot
	140802, -- Nightblooming Frond
	136258, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	136145, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	139329, -- Bloodthirsty Instinct
	139334, -- Nature's Call
	139320, -- Ravaged Seed Pod
	139325, -- Spontaneous Appendages
	139323, -- Twisting Wind
	138224, -- Unstable Horrorslime
	135806, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	135693, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	136716, -- Caged Horror
	137459, -- Chaos Talisman
	137446, -- Elementium Bomb Squirrel Generator
	133641, -- Eye of Skovald
	137539, -- Faulty Countermeasure
	137329, -- Figurehead of the Naglfar
	137369, -- Giant Ornamental Pearl
	136975, -- Hunger of the Pack
	137357, -- Mark of Dargrul
	133644, -- Memento of Angerboda
	137541, -- Moonlit Prism
	137349, -- Naraxas' Spiked Tongue
	137312, -- Nightmare Egg Shell
	137306, -- Oakheart's Gnarled Root
	137433, -- Obelisk of the Void
	136715, -- Spiked Counterweight
	137367, -- Stormsinger Fulmination Charge
	137373, -- Tempered Egg of Serpentrix
	137406, -- Terrorbound Nexus
	140026, -- The Devilsaur's Bite
	137439, -- Tiny Oozeling in a Jar
	137537, -- Tirathon's Betrayal
	137486, -- Windscar Whetstone
	135919, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	136032, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	139630, -- Etching of SargerasDemon Hunter
	128958, -- Lekos' LeashDemon Hunter
	129044, -- Frothing Helhound's Fury
	131803 -- Spine of Barax
}

local TRINKET_INTELLECT_DPS = {
	-- 7.2 trinkets
	147276, -- Spellbinder's Seal
	144480, -- Dreadstone of Endless Shadows
	147019, -- Tome of Unraveling Sanity
	147016, -- Terror From Below
	147017, -- Tarnished Sentinel Medallion
	147018, -- Spectral Thurible
	147002, -- Charm of the Rising Tide
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142166, -- Ethereal Urn

	-- 7.1 trinkets
	140031, -- Mana Spark
	142160, -- Mrrgria's Favor
	142165, -- Deteriorated Construct Core
	142157, -- Aran's Relaxing Ruby
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	141536, -- Padawsen's Unlucky Charm
	132970, -- Runas' Nearly Depleted Ley Crystal
	136038, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	135925, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	132895, -- The Watcher's Divine Inspiration
	137367, -- Stormsinger Fulmination Charge
	137398, -- Portable Manacracker
	121810, -- Pocket Void Portal
	137433, -- Obelisk of the Void
	137306, -- Oakheart's Gnarled Root
	137349, -- Naraxas' Spiked Tongue
	137541, -- Moonlit Prism
	137485, -- Infernal Writ
	137329, -- Figurehead of the Naglfar
	133641, -- Eye of Skovald
	137446, -- Elementium Bomb Squirrel Generator
	140030, -- Devilsaur Shock-Baton
	137301, -- Corrupted Starlight
	136716, -- Caged Horror
	121652, -- Ancient Leaf
	139326, -- Wriggling Sinew
	140809, -- Whispers in the Dark
	135699, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136151, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	135812, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136264, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	138224, -- Unstable Horrorslime
	139323, -- Twisting Wind
	139321, -- Swarming Plaguehive
	140804, -- Star Gate
	140800, -- Pharamere's Forbidden Grimore
	140798, -- Icon of Rot
	140801, -- Fury of the Burning Sky
	140792, -- Erratic Metronome
	139336 -- Bough of Corruption
}

local TRINKET_STRENGTH_DPS = {
	-- 7.2 trinkets
	147278, -- Stalwart Crest
	144482, -- Fel-Oiled Infernal Machine
	147011, -- Vial of Ceaseless Toxins
	147012, -- Umbral Moonglaives
	147009, -- Infernal Cinders
	147015, -- Engine of Eradication
	147010, -- Cradle of Anguish
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142166, -- Ethereal Urn
	142508, -- Chains of the Valorous

	-- 7.1 trinkets
	140035, -- Fluctuating Arc Capacitor
	142164, -- Toe Knee's Promise
	142167, -- Eye of Command
	142159, -- Bloodstained Handkerchief
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	141535, -- Ettin Fingernail
	137486, -- Windscar Whetstone
	136041, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	135928, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	137439, -- Tiny Oozeling in a Jar
	137406, -- Terrorbound Nexus
	129260, -- Tenacity of Cursed Blood
	136715, -- Spiked Counterweight
	137312, -- Nightmare Egg Shell
	121806, -- Mountain Rage Shaker
	121570, -- Might of the Forsaken
	133644, -- Memento of Angerboda
	137357, -- Mark of Dargrul
	140034, -- Impact Tremor
	136975, -- Hunger of the Pack
	137369, -- Giant Ornamental Pearl
	137539, -- Faulty Countermeasure
	137459, -- Chaos Talisman
	135815, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	135702, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	136154, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	136267, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	139328, -- Ursoc's Rending Paw
	139325, -- Spontaneous Appendages
	139320, -- Ravaged Seed Pod
	139334, -- Nature's Call
	140799, -- Might of Krosus
	140796, -- Entwined Elemental Foci
	140808, -- Draught of Souls
	140806, -- Convergence of Fates
	140790 -- Claw of the Crystalline Scorpid
}

local TRINKET_HEALER = {
	-- 7.2 trinkets
	147276, -- Spellbinder's Seal
	144480, -- Dreadstone of Endless Shadows
	147019, -- Tome of Unraveling Sanity
	147007, -- The Deceiver's Grand Design
	147016, -- Terror From Below
	147017, -- Tarnished Sentinel Medallion
	147018, -- Spectral Thurible
	147004, -- Sea Star of the Depthmother
	147002, -- Charm of the Rising Tide
	147005, -- Chalice of Moonlight
	147003, -- Barbaric Mindslaver
	147006, -- Archive of Faith
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142166, -- Ethereal Urn
	142507, -- Brinewater Slime in a Bottle

	-- 7.1 trinkets
	140031, -- Mana Spark
	142160, -- Mrrgria's Favor
	142162, -- Fluctuating Energy
	142158, -- Faith's Crucible
	142165, -- Deteriorated Construct Core
	142157, -- Aran's Relaxing Ruby
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	141536, -- Padawsen's Unlucky Charm
	132970, -- Runas' Nearly Depleted Ley Crystal
	136038, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	135925, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	137452, -- Thrumming Gossamer
	132895, -- The Watcher's Divine Inspiration
	137367, -- Stormsinger Fulmination Charge
	137398, -- Portable Manacracker
	121810, -- Pocket Void Portal
	137433, -- Obelisk of the Void
	137306, -- Oakheart's Gnarled Root
	133766, -- Nether Anti-Toxin
	137349, -- Naraxas' Spiked Tongue
	133645, -- Naglfar Fare
	133646, -- Mote of Sanctification
	137541, -- Moonlit Prism
	137462, -- Jewel of Insatiable Desire
	137485, -- Infernal Writ
	137484, -- Flask of the Solemn Night
	137329, -- Figurehead of the Naglfar
	133641, -- Eye of Skovald
	137446, -- Elementium Bomb Squirrel Generator
	140030, -- Devilsaur Shock-Baton
	137301, -- Corrupted Starlight
	137540, -- Concave Reflecting Lens
	136716, -- Caged Horror
	137378, -- Bottled Hurricane
	121652, -- Ancient Leaf
	136714, -- Amalgam's Seventh Spine
	139326, -- Wriggling Sinew
	135812, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136264, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	135699, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136151, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	138222, -- Vial of Nightmare Fog
	138224, -- Unstable Horrorslime
	139323, -- Twisting Wind
	139321, -- Swarming Plaguehive
	140793, -- Perfectly Preserved Cake
	139333, -- Horn of Cenarius
	139330, -- Heightened Senses
	140803, -- Etraeus' Celestial Map
	140805, -- Ephemeral Paradox
	139322, -- Cocoon of Enforced Solitude
	139336, -- Bough of Corruption
	140795 -- Aluriel's Mirror
}

local TRINKET_TANK = {
	-- 7.2 trinkets
	147278, -- Stalwart Crest
	147275, -- Beguiler's Talisman
	144477, -- Splinters of Agronax
	144482, -- Fel-Oiled Infernal Machine
	147026, -- Shifting Cosmic Sliver
	147024, -- Reliquary of the Damned
	147025, -- Recompiled Guardian Module
	147023, -- Leviathan's Hunger
	147022, -- Feverish Carapace
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142506, -- Eye of Guarm
	142166, -- Ethereal Urn

	-- 7.1 trinkets
	140027, -- Ley Spark
	140035, -- Fluctuating Arc Capacitor
	142169, -- Raven Eidolon
	142168, -- Majordomo's Dinner Bell
	142161, -- Inescapable Dread
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	137315, -- Writhing Heart of Darkness
	136041, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	135928, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	136032, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	135919, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	140026, -- The Devilsaur's Bite
	129260, -- Tenacity of Cursed Blood
	137344, -- Talisman of the Cragshaper
	131803, -- Spine of Barax
	137440, -- Shivermaw's Jawbone
	137338, -- Shard of Rokmora
	137362, -- Parjesh's Medallion
	137538, -- Orb of Torment
	121806, -- Mountain Rage Shaker
	121570, -- Might of the Forsaken
	128958, -- Lekos' LeashDemon Hunter
	137430, -- Impenetrable Nerubian Husk
	140034, -- Impact Tremor
	133647, -- Gift of Radiance
	129044, -- Frothing Helhound's Fury
	136978, -- Ember of Nullification
	137400, -- Coagulated Nightwell Residue
	135702, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	136267, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	135815, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	136154, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	135693, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	136258, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	135806, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	136145, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	139327, -- Unbridled Fury
	140791, -- Royal Dagger Haft
	138225, -- Phantasmal Echo
	140807, -- Infernal Contract
	139335, -- Grotesque Statuette
	139324, -- Goblet of Nightmarish Ichor
	140797, -- Fang of Tichcondrius
	139630, -- Etching of SargerasDemon Hunter
	140789 -- Animated Exoskeleton
}

-- set up Frames that will listen for events
local addonLoadedFrame
local lootReceivedEventFrame
local whisperReceivedEventFrame
local bnWhisperReceivedEventFrame
local rollReceivedEventFrame
local inspectReadyEventFrame
local rosterUpdatedEventFrame
local combatStatusChangedEventFrame
local rollDelayFrame
local highlightDelayFrame
local groupMemberInfoChangedEventFrame

-- set up variables that will track addon's status
local isEnabled = false
local delay = 0
local nextRollDelay = 0
local unhighlightDelay = 0
local priorCacheRefreshTime = 0

local whisperedItems = {}  -- list of items we've whispered to people; index is character name-realm, content is item

local numOfQueuedRollItems = 0;
local queuedRollOwners = {}
local queuedRollItems = {}

local currentRollOwner = nil
local currentRollItem = nil
local currentRolls = {}
local PLH_RANDOM_ROLL_RESULT_PATTERN = _G.RANDOM_ROLL_RESULT
	  PLH_RANDOM_ROLL_RESULT_PATTERN = PLH_RANDOM_ROLL_RESULT_PATTERN:gsub('%%s', '(.+)')
	  PLH_RANDOM_ROLL_RESULT_PATTERN = PLH_RANDOM_ROLL_RESULT_PATTERN:gsub('%%d %(%%d%-%%d%)', '(%%d+) %%((%%d+)%%-(%%d+)%%)')
	  PLH_RANDOM_ROLL_RESULT_PATTERN = '^' .. PLH_RANDOM_ROLL_RESULT_PATTERN .. '$'
local LOOT_ITEM_SELF_PATTERN = _G.LOOT_ITEM_SELF
	  LOOT_ITEM_SELF_PATTERN = LOOT_ITEM_SELF_PATTERN:gsub('%%s', '(.+)')
local LOOT_ITEM_PATTERN = _G.LOOT_ITEM
	  LOOT_ITEM_PATTERN = LOOT_ITEM_PATTERN:gsub('%%s', '(.+)')

-- set up variables that will cache group member's information
local groupInfoCache = {}  -- array keyed by name-realm paired with a list of slotid-items
local maxInspectIndex = 0  -- the index of the last character in GetRaidRosterInfo(); must be < inspectIndex to start with so PopulateGroupInfoCache can start inspections
local inspectIndex = maxInspectIndex + 1    -- the index of the character within GetRaidRosterInfo() that we're currently inspecting
											-- defaulting to a higher value so PopulateGroupCache() knows to start a new inspection loop the first time it is called
local notifyInspectName = nil -- valued if we sent a request to inspect someone, nil otherwise
--local inspectRetries = 0  -- tracks how many times we've attempted to inspect a specific character without getting an INSPECT_READY result
local inspectLoop = MAX_INSPECT_LOOPS + 1 -- defaulting to a higher value so PopulateGroupCache() knows to start a new inspection loop the first time it is called

local raidFrameTextures = {}  -- array indexed by characterName-realmName, containing texture to be shown in raid frames (for loot identification)
local raidFrameTooltips = {}  -- array indexed by characterName-realmName, containing tooltip to be shown in raid frames (for loot identification)

local function GetExpectedRelicCount(level)
	if level ~= nil then
		if level == 110 then
			return NUM_EXPECTED_RELICS_110
		elseif level >= 101 and level < 110 then
			return NUM_EXPECTED_RELICS_101
		end
	end
	return 0
end

local function GetExpectedItemCount(class, spec, level)
	if class ~= nil and spec ~= nil and level ~= nil then
		if level >= 101 then   -- pre-Legion, classes could use different weapons; ex: feral used a staff instead of 2 fist weapons
								-- technically the change happens once the person gets their artifact, but we'll just simplify and
								-- expect Legion counts at 101 and above, and 15 items for 100 and earlier
			local i = 1
			while ExpectedItemCount[i] do
				if class == ExpectedItemCount[i][1] and spec == ExpectedItemCount[i][2] then
					return ExpectedItemCount[i][3]
				end
				i = i + 1
			end
		end
	end
	return NUM_EXPECTED_ITEMS
end

function PLH_GetRelicCountFromCache(name)
	local relicCount = 0
	local characterDetails = groupInfoCache[name]
	if characterDetails ~= nil then
		if characterDetails[PLH_RELICSLOT + 1] ~= nil then
			relicCount = relicCount + 1
		end
		if characterDetails[PLH_RELICSLOT + 2] ~= nil then
			relicCount = relicCount + 1
		end
		if characterDetails[PLH_RELICSLOT + 3] ~= nil then
			relicCount = relicCount + 1
		end
	end
	return relicCount
end

-- only returns count of equippable items from cache; excludes relics and other cached info such as ClassName/Spec/Level
function PLH_GetItemCountFromCache(name)
	local itemCount = 0
	if groupInfoCache[name] ~= nil then
		for slotID, item in pairs (groupInfoCache[name]) do
			itemCount = itemCount + 1
		end
		itemCount = itemCount - 4 -- subtract 3 since everyone has ClassName and Spec and Level and InspectCount elements
		itemCount = itemCount - PLH_GetRelicCountFromCache(name)
	else
		PLH_SendDebugMessage('groupInfoCache[name] is nil for ', name)	
	end
	return itemCount
end

-- Returns the item that character has equipped in slotID, based on the cache
local function GetEquippedItem(characterName, slotID)
	local item = nil
	if characterName == PLH_GetUnitNameWithRealm('player') then
		-- we can get the item directly
		item = GetInventoryItemLink('player', slotID)
	else
		-- we have to get the item from the cache
		local characterDetails = groupInfoCache[characterName]
		if characterDetails ~= nil then
			item = characterDetails[slotID]
		end
	end
	return item
end

local function GetEquippedRelic(characterName, relicNumber)
	local _, relic = nil
	if characterName == PLH_GetUnitNameWithRealm('player') then
		-- we can get the item directly
		local weapon = GetInventoryItemLink('player', INVSLOT_MAINHAND)
		_, relic = GetItemGem(weapon, relicNumber)
	else
		-- we have to get the item from the cache
		local characterDetails = groupInfoCache[characterName]
		if characterDetails ~= nil then
			relic = characterDetails[PLH_RELICSLOT + relicNumber]
		end
	end
	return relic
end

-- note that this will return a value based on player's class/spec, so it will switch if the primary attribute is mutable!
-- thus only use for cloaks/rings/necks/trinkets, sine those things are not mutable
local function GetItemPrimaryAttribute(item)
	local stats = GetItemStats(item)
	if stats ~= nil then
		for stat, value in pairs(stats) do
			if _G[stat] == ITEM_MOD_STRENGTH_SHORT or _G[stat] == ITEM_MOD_INTELLECT_SHORT or _G[stat] == ITEM_MOD_AGILITY_SHORT then
				return _G[stat]
			end
		end
	end
	return nil
end

-- TODO may need to limit this by ilvl?  ex: did cloaks only become mutable in Legion?
local function IsMutablePrimaryAttribute(itemEquipLoc)
	return itemEquipLoc == 'INVTYPE_HEAD'
		or itemEquipLoc == 'INVTYPE_SHOULDER'
		or itemEquipLoc == 'INVTYPE_CLOAK'
		or itemEquipLoc == 'INVTYPE_CHEST'
		or itemEquipLoc == 'INVTYPE_ROBE'
		or itemEquipLoc == 'INVTYPE_WAIST'
		or itemEquipLoc == 'INVTYPE_LEGS'
		or itemEquipLoc == 'INVTYPE_FEET'
		or itemEquipLoc == 'INVTYPE_WRIST'
		or itemEquipLoc == 'INVTYPE_HAND'
end

local function IsTrinketUsable(item, role)
	local itemLink = select(2, GetItemInfo(item))
	local itemID = string.match(itemLink, 'item:(%d+):')

	local trinketList = nil
	if role == 'AgilityDPS' then
		trinketList = TRINKET_AGILITY_DPS
	elseif role == 'IntellectDPS' then
		trinketList = TRINKET_INTELLECT_DPS
	elseif role == 'StrengthDPS' then
		trinketList = TRINKET_STRENGTH_DPS
	elseif role == 'Healer' then
		trinketList = TRINKET_HEALER
	elseif role == 'Tank' then
		trinketList = TRINKET_TANK
	end
	
	local i
	if trinketList ~= nil then
		for i = 1, #trinketList do
			if tostring(trinketList[i]) == itemID then
				return true
			end
		end
	end
	
	return false
end

local function IsRelic(item)
	local _, _, _, _, _, _, _, _, _, _, _, itemClass, itemSubclass = GetItemInfo(item)
	return itemClass == LE_ITEM_CLASS_GEM and itemSubclass == LE_ITEM_ARMOR_RELIC
end

local function IsValidRelicTypeForSpec(relicType, spec)
	local specRelics = ValidRelics[spec]
	if specRelics ~= nil then
		return ValidRelics[spec][1] == relicType or ValidRelics[spec][2] == relicType or ValidRelics[spec][3] == relicType
	else
		return false
	end
end

-- Returns false if the character cannot use the item.
local function IsEquippableItemForCharacter(item, characterName)
	local isEquippableForClass = false
	local isEquippableForSpec = false
	local isEquippableForOffspec = false
	if item ~= nil and characterName ~= nil then
		if IsEquippableItem(item) or IsRelic(item) then
			local _, _, _, _, requiredLevel, _, _, _, itemEquipLoc, _, _, itemClass, itemSubclass = GetItemInfo(item)
			local class
			local spec
			local characterLevel
			if characterName == PLH_GetUnitNameWithRealm('player') then
				_, class = UnitClass('player')
				spec = GetSpecializationInfo(GetSpecialization())
				characterLevel = UnitLevel('player')
			elseif groupInfoCache[characterName] ~= nil then
				class = groupInfoCache[characterName]['ClassName']
				spec = groupInfoCache[characterName]['Spec']
				characterLevel = groupInfoCache[characterName]['Level']
			else
				PLH_SendDebugMessage('Unable to determine class and spec in InEquippableItemForCharacter()!!!!')
				return false  -- should never reach here, but if we do it means we're not looking up the player or anyone in cache
			end
			
			-- check if character is a high enough level to equip the item
			if PLH_CHECK_CHARACTER_LEVEL and requiredLevel > characterLevel then
				return false
			end
			
			local isRelic = IsRelic(item)
			isEquippableForClass = itemEquipLoc == 'INVTYPE_CLOAK' -- cloaks show up as type=armor, subtype=cloth, but they're equippable by all, so set to true if cloak
			local i = 1
			
			while not isEquippableForClass and ValidGear[i] do
				if class == ValidGear[i][1] and itemClass == ValidGear[i][2] and itemSubclass == ValidGear[i][3] then
					isEquippableForClass = true
				end
				i = i + 1
			end

			if isEquippableForClass then
				if itemEquipLoc == 'INVTYPE_TRINKET' then
					if spec == 105 or spec == 270 or spec == 65 or spec == 256 or spec == 257 or spec == 264 then
						isEquippableForSpec = IsTrinketUsable(item, 'Healer')					
					elseif spec == 250 or spec == 581 or spec == 104 or spec == 268 or spec == 66 or spec == 73 then
						isEquippableForSpec = IsTrinketUsable(item, 'Tank')
					elseif spec == 577 or spec == 103 or spec == 253 or spec == 254 or spec == 255 or spec == 269 or spec == 259 or spec == 260 or spec == 261 or spec == 263 then
						isEquippableForSpec = IsTrinketUsable(item, 'AgilityDPS')
					elseif spec == 251 or spec == 252 or spec == 70 or spec == 71 or spec == 72 then
						isEquippableForSpec = IsTrinketUsable(item, 'StrengthDPS')
					elseif spec == 102 or spec == 62 or spec == 63 or spec == 64 or spec == 258 or spec == 262 or spec == 265 or spec == 266 or spec == 267 then
						isEquippableForSpec = IsTrinketUsable(item, 'IntellectDPS')
					end
						
					if not PLH_CURRENT_SPEC_ONLY and not isEquippableForSpec then
						if class == DEATH_KNIGHT or class == WARRIOR then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'StrengthDPS')
						elseif class == DEMON_HUNTER then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'AgilityDPS')
						elseif class == DRUID then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'AgilityDPS') or IsTrinketUsable(item, 'Healer') or IsTrinketUsable(item, 'IntellectDPS')
						elseif class == MONK then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'AgilityDPS') or IsTrinketUsable(item, 'Healer')
						elseif class == PALADIN then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'StrengthDPS') or IsTrinketUsable(item, 'Healer')
						elseif class == PRIEST then
							isEquippableForOffspec = IsTrinketUsable(item, 'Healer') or IsTrinketUsable(item, 'IntellectDPS')
						elseif class == SHAMAN then
							isEquippableForOffspec = IsTrinketUsable(item, 'Healer') or IsTrinketUsable(item, 'IntellectDPS') or IsTrinketUsable(item, 'AgilityDPS')
						end
					end
				else
					local itemPrimaryAttribute = GetItemPrimaryAttribute(item)
					if itemPrimaryAttribute == nil then
						isEquippableForSpec = true  -- if there's no primary attr (ex: ring/neck), then the item is equippable by everyone
					elseif IsMutablePrimaryAttribute(itemEquipLoc) then
						isEquippableForSpec = true	-- if the item is a piece of gear that has mutable primary stats then return true
					else
						-- otherwise we're going to check if the item's primary attribute is applicable for the character's spec
						i = 1
						while not isEquippableForSpec and PrimaryAttributes[i] do
							if class == PrimaryAttributes[i][1] and PrimaryAttributes[i][3] == itemPrimaryAttribute and (PrimaryAttributes[i][2] == 'Any' or PrimaryAttributes[i][2] == spec) then
								isEquippableForSpec = true
							end
							i = i + 1
						end

						if not PLH_CURRENT_SPEC_ONLY and not isEquippableForSpec then
							-- now check to see if it's usable by an offspec
							i = 1
							while not isEquippableForSpec and OffspecAttributes[i] do
								if class == OffspecAttributes[i][1] and OffspecAttributes[i][3] == itemPrimaryAttribute and OffspecAttributes[i][2] == spec then
									isEquippableForOffspec = true
								end
								i = i + 1
							end
						end
					end
				end
			elseif isRelic then
				local relicType = PLH_GetRelicType(item)
				isEquippableForSpec = IsValidRelicTypeForSpec(relicType, spec)
				isEquippableForClass = isEquippableForSpec
				if not PLH_CURRENT_SPEC_ONLY and not isEquippableForSpec then
					if class == DEATH_KNIGHT then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 250) or IsValidRelicTypeForSpec(relicType, 251) or IsValidRelicTypeForSpec(relicType, 252)
					elseif class == DEMON_HUNTER then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 577) or IsValidRelicTypeForSpec(relicType, 581)
					elseif class == DRUID then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 102) or IsValidRelicTypeForSpec(relicType, 103) or IsValidRelicTypeForSpec(relicType, 104) or IsValidRelicTypeForSpec(relicType, 105)
					elseif class == HUNTER then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 253) or IsValidRelicTypeForSpec(relicType, 254) or IsValidRelicTypeForSpec(relicType, 255)
					elseif class == MAGE then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 62) or IsValidRelicTypeForSpec(relicType, 63) or IsValidRelicTypeForSpec(relicType, 64)
					elseif class == MONK then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 268) or IsValidRelicTypeForSpec(relicType, 270) or IsValidRelicTypeForSpec(relicType, 269)
					elseif class == PALADIN then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 65) or IsValidRelicTypeForSpec(relicType, 66) or IsValidRelicTypeForSpec(relicType, 70)
					elseif class == PRIEST then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 256) or IsValidRelicTypeForSpec(relicType, 257) or IsValidRelicTypeForSpec(relicType, 258)
					elseif class == ROGUE then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 259) or IsValidRelicTypeForSpec(relicType, 260) or IsValidRelicTypeForSpec(relicType, 261)
					elseif class == SHAMAN then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 262) or IsValidRelicTypeForSpec(relicType, 263) or IsValidRelicTypeForSpec(relicType, 264)
					elseif class == WARLOCK then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 265) or IsValidRelicTypeForSpec(relicType, 266) or IsValidRelicTypeForSpec(relicType, 267)
					elseif class == WARRIOR then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 71) or IsValidRelicTypeForSpec(relicType, 72) or IsValidRelicTypeForSpec(relicType, 73)
					end
					isEquippableForClass = isEquippableForSpec or isEquippableForOffspec
				end
			end
		end
	end
--	PLH_SendDebugMessage('For ' .. characterName .. ' item ' .. item .. ' isEquippableForClass = ' .. tostring(isEquippableForClass) .. ' and isEquippableForSpec = ' .. tostring(isEquippableForSpec)  .. ' and isEquippableForOffspec = ' .. tostring(isEquippableForOffspec))
	
	return isEquippableForClass and (isEquippableForSpec or isEquippableForOffspec)
end

-- returns two variables:  true if the item is an upgrade over equippedItem (based on ilvl), equipped ilvl
local function IsAnUpgrade(item, equippedItem)
	local equippedILVL = PLH_GetRealILVL(equippedItem)
	if equippedILVL == 0 then
		-- this means we couldn't find an equippedItem
		return false, 0
	else
		return PLH_GetRealILVL(item) > PLH_GetRealILVL(equippedItem), equippedILVL
	end
end

-- returns an appropriate SlotID for the given itemEquipLoc, or nil if it's not an item
-- if itemEquipLoc is a finger slot or trinket slot, we'll just return the first item
-- if itemEquipLoc is a weapon that can be in either slot (INVTYPE_WEAPON), we'll return the main hand
local function GetSlotID(itemEquipLoc)
	if itemEquipLoc == 'INVTYPE_HEAD' then return INVSLOT_HEAD
	elseif itemEquipLoc == 'INVTYPE_NECK' then return INVSLOT_NECK
	elseif itemEquipLoc == 'INVTYPE_SHOULDER' then return INVSLOT_SHOULDER
	elseif itemEquipLoc == 'BODY' then return INVSLOT_BODY
	elseif itemEquipLoc == 'INVTYPE_CHEST' then return INVSLOT_CHEST
	elseif itemEquipLoc == 'INVTYPE_ROBE' then return INVSLOT_CHEST
	elseif itemEquipLoc == 'INVTYPE_WAIST' then return INVSLOT_WAIST
	elseif itemEquipLoc == 'INVTYPE_LEGS' then return INVSLOT_LEGS
	elseif itemEquipLoc == 'INVTYPE_FEET' then return INVSLOT_FEET
	elseif itemEquipLoc == 'INVTYPE_WRIST' then return INVSLOT_WRIST
	elseif itemEquipLoc == 'INVTYPE_HAND' then return INVSLOT_HAND
	elseif itemEquipLoc == 'INVTYPE_FINGER' then return INVSLOT_FINGER1
	elseif itemEquipLoc == 'INVTYPE_TRINKET' then return INVSLOT_TRINKET1
	elseif itemEquipLoc == 'INVTYPE_CLOAK' then return INVSLOT_BACK
	elseif itemEquipLoc == 'INVTYPE_WEAPON' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_SHIELD' then return INVSLOT_OFFHAND
	elseif itemEquipLoc == 'INVTYPE_2HWEAPON' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_WEAPONMAINHAND' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_WEAPONOFFHAND' then return INVSLOT_OFFHAND
	elseif itemEquipLoc == 'INVTYPE_HOLDABLE' then return INVSLOT_OFFHAND
	elseif itemEquipLoc == 'INVTYPE_RANGED' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_THROWN' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_RANGEDRIGHT' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_RELIC' then return INVSLOT_MAINHAND
	elseif itemEquipLoc == 'INVTYPE_TABARD' then return INVSLOT_TABARD
	else return nil
	end
end

-- returns two variables:  true if the item is an upgrade over equippedItem (based on ilvl), equipped ilvl
-- note: doesn't check if item is equippable, so make sure you do that check beforehand
local function IsAnUpgradeForCharacter(item, characterName)
	local isAnUpgrade = false
	local equippedILVL = 0
	local _, _, _, _, _, _, _, _, itemEquipLoc, _, _ = GetItemInfo(item)
	if itemEquipLoc ~= nil and itemEquipLoc ~= '' then
		if itemEquipLoc == 'INVTYPE_FINGER' then
			local equippedItem0 = GetEquippedItem(characterName, 11)	-- 1st ring
			local equippedItem1 = GetEquippedItem(characterName, 12)  	-- 2nd ring
			isAnUpgrade = IsAnUpgrade(item, equippedItem0) or IsAnUpgrade(item, equippedItem1)
			equippedILVL = min(PLH_GetRealILVL(equippedItem0), PLH_GetRealILVL(equippedItem1))
		elseif itemEquipLoc == 'INVTYPE_TRINKET' then
			local equippedItem0 = GetEquippedItem(characterName, 13)	-- 1st trinket
			local equippedItem1 = GetEquippedItem(characterName, 14)	-- 2nd trinket
			isAnUpgrade = IsAnUpgrade(item, equippedItem0) or IsAnUpgrade(item, equippedItem1)
			equippedILVL = min(PLH_GetRealILVL(equippedItem0), PLH_GetRealILVL(equippedItem1))
		elseif itemEquipLoc == 'INVTYPE_WEAPON' then
			local equippedItem0 = GetEquippedItem(characterName, 16)		-- main hand
			local equippedItem1 = GetEquippedItem(characterName, 17)		-- off hand
			isAnUpgrade = IsAnUpgrade(item, equippedItem0) or IsAnUpgrade(item, equippedItem1)
			equippedILVL = min(PLH_GetRealILVL(equippedItem0), PLH_GetRealILVL(equippedItem1))
		else
			local slotID = GetSlotID(itemEquipLoc)
			local equippedItem =  GetEquippedItem(characterName, slotID)
			isAnUpgrade, equippedILVL = IsAnUpgrade(item, equippedItem)
		end
	elseif IsRelic(item) then
		local relicType = PLH_GetRelicType(item)

		local relic1 = GetEquippedRelic(characterName, 1)
		local relic1ILVL = PLH_GetRealILVL(relic1)
		local relic1Type = PLH_GetRelicType(relic1)
		local relic2 = GetEquippedRelic(characterName, 2)
		local relic2ILVL = PLH_GetRealILVL(relic2)
		local relic2Type = PLH_GetRelicType(relic2)
		local relic3 = GetEquippedRelic(characterName, 3)
		local relic3ILVL = PLH_GetRealILVL(relic3)
		local relic3Type = PLH_GetRelicType(relic3)
		isAnUpgrade = (relicType == relic1Type and IsAnUpgrade(item, relic1))
			or (relicType == relic2Type and IsAnUpgrade(item, relic2))
			or (relicType == relic3Type and IsAnUpgrade(item, relic3))
		if relicType == relic1Type then
			equippedILVL = relic1ILVL
		end
		if relicType == relic2Type and (equippedILVL == 0 or relic2ILVL < equippedILVL) then
			equippedILVL = relic2ILVL
		end
		if relicType == relic3Type and (equippedILVL == 0 or relic3ILVL < equippedILVL) then
			equippedILVL = relic3ILVL
		end
	end
	return isAnUpgrade, equippedILVL
end

-- returns two variables:  first is true or false, second is list of people for whom the item may is an upgrade (by ilvl)
local function IsAnUpgradeForAnyCharacter(item)
	local isAnUpgrade, equippedILVL
	local isAnUpgradeForAnyCharacterNames = {}

	local index = 1
	local characterName
	while GetRaidRosterInfo(index) ~= nil do
		characterName = select(1, GetRaidRosterInfo(index))
		-- this characterName may be a full name-realm or it may just be a name, but the functions we're calling expect name-realm
		if not string.find(characterName, '-') then
			characterName = PLH_GetFullName(characterName, GetRealmName())
		end
		if IsEquippableItemForCharacter(item, characterName) then
			isAnUpgrade, equippedILVL = IsAnUpgradeForCharacter(item, characterName)
			if isAnUpgrade then
--				PLH_SendDebugMessage(item .. ' is an ilvl upgrade for ' .. characterName)
				isAnUpgradeForAnyCharacterNames[#isAnUpgradeForAnyCharacterNames + 1] = PLH_GetNameWithoutRealm(characterName) .. ' (' .. equippedILVL .. ')'
			end
		end
		index = index + 1
	end

	return #isAnUpgradeForAnyCharacterNames > 0, isAnUpgradeForAnyCharacterNames
end

local function IsPlayerInUpgradeList(list)
	if list ~= nil then
		local playerName = UnitName('player')
		for i = 1, #list do
			if string.sub(list[i], 1, string.len(playerName)) == playerName then  -- see if string starts with 'playername '; ex: 'Madone (690)'
				return true
			end
		end
	end
	return false
end

-- returns the names from the given array, with 'and others' if array size > limit
local function GetNames(namelist, limit)
	local names = ''
	if namelist ~= nil then
		if limit == nil then  -- no limit; show all names
			limit = #namelist
		end
		if namelist[1] ~= nil then
			names = namelist[1]
			local maxnames = min(#namelist, limit)
			for i = 2, maxnames do
				if #namelist == 2 then
					names = names .. ' '
				else
					names = names .. ', '
				end
				if i == #namelist then -- last person
					names = names .. 'and '
				end
				names = names .. namelist[i]
			end
			if #namelist > limit then
				names = names .. ', and others'
			end
		end
	end
	return names
end

local function PlayerCanCoordinateRolls()
	return (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player')) and not PLH_IsInLFR()
end

local function UnhighlightRaidFrames()
	for characterName, texture in pairs(raidFrameTextures) do
		texture:Hide()
	end
	for characterName, tooltip in pairs(raidFrameTooltips) do
		tooltip:SetScript("OnEnter", nil)
		tooltip:SetScript("OnEvent", nil)
		tooltip:UnregisterAllEvents()
		tooltip:Hide()
	end
end

local function StartUnhighlightRaidFramesTimer()
	highlightDelayFrame:SetScript('OnUpdate', function(self, elapsed)
		unhighlightDelay = unhighlightDelay + elapsed
		if unhighlightDelay >= UNHIGHLIGHT_DELAY then
			UnhighlightRaidFrames()
			highlightDelayFrame:SetScript('OnUpdate', nil)
			unhighlightDelay = 0
		end
	end)
end

function PLH_ResizeHighlights()
	for characterName, texture in pairs(raidFrameTextures) do
		raidFrameTextures[characterName]:SetWidth(PLH_HIGHLIGHT_SIZE)
		raidFrameTextures[characterName]:SetHeight(PLH_HIGHLIGHT_SIZE)
	end
	for characterName, tooltip in pairs(raidFrameTooltips) do
		raidFrameTooltips[characterName]:SetWidth(PLH_HIGHLIGHT_SIZE)
		raidFrameTooltips[characterName]:SetHeight(PLH_HIGHLIGHT_SIZE)
	end
end

function PLH_ApplyFrameTexture(frame, characterName, item)
	local unitName = PLH_GetUnitNameWithRealm(frame.unit)

	if characterName == unitName then
		-- create the texture to display in the raid frames
		if not raidFrameTextures[characterName] then
			raidFrameTextures[characterName] = frame:CreateTexture(nil, "OVERLAY")
			raidFrameTextures[characterName]:SetPoint("BOTTOM", 0, 2) 
			raidFrameTextures[characterName]:SetWidth(PLH_HIGHLIGHT_SIZE)
			raidFrameTextures[characterName]:SetHeight(PLH_HIGHLIGHT_SIZE)
		end
--		local file_id = GetSpellTexture(60650)  -- spell id for "titanium seal of dalaran"
		local itemTexture = select(10, GetItemInfo(item))
		raidFrameTextures[characterName]:SetTexture(itemTexture)

		-- create the tooltip to display when the cursor is over the texture
		if not raidFrameTooltips[characterName] then
			raidFrameTooltips[characterName] = CreateFrame("Frame", frame:GetName() .. "itemTooltip", frame)
			raidFrameTooltips[characterName]:SetPoint("BOTTOM", 0, 2)
			raidFrameTooltips[characterName]:SetWidth(PLH_HIGHLIGHT_SIZE)
			raidFrameTooltips[characterName]:SetHeight(PLH_HIGHLIGHT_SIZE)
		end

		raidFrameTooltips[characterName]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetHyperlink(item)
			GameTooltip:Show()
			-- the following sets up the listener for the shift key to toggle display of the item comparison
			raidFrameTooltips[characterName]:SetScript("OnEvent", function(self, event, arg, ...)
				if raidFrameTooltips[characterName]:IsShown() and event == "MODIFIER_STATE_CHANGED" and (arg == "LSHIFT" or arg == "RSHIFT") then
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:SetHyperlink(item)
					GameTooltip:Show()
				end
			end)
			raidFrameTooltips[characterName]:RegisterEvent("MODIFIER_STATE_CHANGED")
		end)		

		raidFrameTooltips[characterName]:SetScript("OnLeave", function(self)
			raidFrameTooltips[characterName]:SetScript("OnEvent", nil)
			raidFrameTooltips[characterName]:UnregisterAllEvents()
			GameTooltip:Hide()
		end)

		raidFrameTextures[characterName]:Show()
		raidFrameTooltips[characterName]:Show()
		
	end
end

-- TODO implement for players to whom you can trade as well (keep in mind someone may both trade and receive an item)
-- TODO what if a single person loots multiple useful items?  (ex: end of m+)
local function HighlightRaidFrames(characterName, item)
	if PLH_HIGHLIGHT_RAID_FRAMES then
		CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", PLH_ApplyFrameTexture, characterName, item)
		StartUnhighlightRaidFramesTimer()
	end
end

-- Determines whether item is not an upgrade for the person who looted the item, and is an upgrade for someone else in the group
-- If that's the case, performs the action based on the users' selected Notify Mode
local function PerformNotify(item, characterName)
	local isAnUpgradeForLooter, equippedILVL = IsAnUpgradeForCharacter(item, characterName)
	if PLH_COORDINATE_ROLLS and PlayerCanCoordinateRolls() then
		whisperedItems[characterName] = item  -- use full name-realm since that what we'll get when we look it up from the whisper
--		if #isAnUpgradeForAnyCharacterNames > 1 then  -- more than 1 person can use the item
--					PLH_SendWhisper('You can trade ' .. item .. ', which is an ilvl upgrade for ' .. names .. '. Reply \'' .. TRADE_MESSAGE .. '\' to initiate rolls for this item.', characterName)
--		end
	end
	if equippedILVL > 0 and not isAnUpgradeForLooter then
		-- we now know the item can be traded by the person who received it, so let's check to see if anyone can actually
		--    use the item as an upgrade
		local isAnUpgradeForAnyCharacter, isAnUpgradeForAnyCharacterNames = IsAnUpgradeForAnyCharacter(item)
		if isAnUpgradeForAnyCharacter then
			local names = GetNames(isAnUpgradeForAnyCharacterNames, MAX_NAMES_TO_SHOW)

			if PLH_NOTIFY_GROUP then
				if not PLH_IsInLFR() then
					PLH_SendBroadcast(PLH_GetNameWithoutRealm(characterName) .. ' can trade ' .. item .. ', which is an ilvl upgrade for ' .. names)
				end
			end

			if characterName == PLH_GetUnitNameWithRealm('player') then  -- player can trade an item
				PLH_SendAlert('You can trade ' .. item .. ', which is an ilvl upgrade for ' .. names)
				PlaySound('GLUECREATECHARACTERBUTTON')
			elseif IsPlayerInUpgradeList(isAnUpgradeForAnyCharacterNames) then  -- player can receive an item
				PLH_SendAlert(PLH_GetNameWithoutRealm(characterName) .. ' can trade ' .. item .. ', which is an ilvl upgrade for you!')
				PlaySound('LEVELUP')
				HighlightRaidFrames(characterName, item)
			end
		end
	end
end

-- returns true if the item should be evaluated for potential trades based on the following criteria:
--   1. item is equippable
--   2. ilvl is >= min ilvl from preferences
--   3. quality is >= min quality from preferences
--   4. item is BoP, or user specified to include BoE items in preferences
local function ShouldBeEvaluated(item)
	if not IsEquippableItem(item) and not IsRelic(item) then
		return false
	else
		local ilvl = PLH_GetRealILVL(item)
		if ilvl < PLH_MIN_ILVL then
			return false
		else
			local quality = select(3, GetItemInfo(item))
			if quality < PLH_MIN_QUALITY then
				return false
			else
				if not PLH_INCLUDE_BOE and not PLH_IsBoundToPlayer(item) then
					return false
				else
					return true
				end
			end
		end
	end
end

local function LootReceivedEvent(self, event, ...)
	local message, _, _, _, looter = ...
	
--	local _, _, lootedItem = string.find(message, '(|.+|r)')
	
	local lootedItem = message:match(LOOT_ITEM_SELF_PATTERN)
	if lootedItem == nil then
		_, lootedItem = message:match(LOOT_ITEM_PATTERN)
	end
	
	if lootedItem then
		if ShouldBeEvaluated(lootedItem) then
			if not string.find(looter, '-') then
				looter = PLH_GetUnitNameWithRealm(looter)
			end
			PerformNotify(lootedItem, looter)
		end
	end
			
--[[			
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
	local owner

	local message = arg1			
	local _, _, lootedItem = string.find(message, 'You receive loot: (|.+|r)')
	if lootedItem then
		if ShouldBeEvaluated(lootedItem) then
			PerformNotify(lootedItem, PLH_GetUnitNameWithRealm('player'))
		end
	else
		local _, _, owner, lootedItem = string.find(message, '(.+) receives loot: (|.+|r)')

		if lootedItem then
			if ShouldBeEvaluated(lootedItem) then
				owner = PLH_GetUnitNameWithRealm(owner)
				PerformNotify(lootedItem, owner)
			end
		end
	end
]]--	
end	

local function QueueItem(sender, item)
	queuedRollOwners[numOfQueuedRollItems] = sender
	queuedRollItems[numOfQueuedRollItems] = item
	numOfQueuedRollItems = numOfQueuedRollItems + 1
end

local function AskForRolls()
	if currentRollItem == nil and numOfQueuedRollItems > 0 then
		currentRollOwner = queuedRollOwners[numOfQueuedRollItems - 1]
		currentRollItem = queuedRollItems[numOfQueuedRollItems - 1]
		numOfQueuedRollItems = numOfQueuedRollItems - 1
		PLH_SendBroadcast('Roll for ' .. currentRollItem .. ' from ' .. PLH_GetNameWithoutRealm(currentRollOwner), true)

		local FiveSecondWarningDisplayed = false
		local FifteenSecondWarningDisplayed = false
		
		rollDelayFrame:SetScript('OnUpdate', function(self, elapsed)
			delay = delay + elapsed
--			if currentRollItem == nil then
				-- that means the user forced rolls to end, so we can stop the countdown; relying on PLH_EndRolls() to clean us up
--			elseif delay >= 15 and not FifteenSecondWarningDisplayed then
			if delay >= 15 and not FifteenSecondWarningDisplayed then
				PLH_SendBroadcast('15 seconds remaining to roll for ' .. currentRollItem, false)
				FifteenSecondWarningDisplayed = true
			elseif delay >= 25 and not FiveSecondWarningDisplayed then
				PLH_SendBroadcast('5 seconds remaining to roll for ' .. currentRollItem, false)
				FiveSecondWarningDisplayed = true
			elseif delay >= 30 then
				-- force an end to the rolls
				PLH_EndRolls()
			end
		end)
	end
end

local function ClearRolls()
	currentRollOwner = nil
	currentRollItem = nil
	currentRolls = {}
	queuedRollOwners[numOfQueuedRollItems] = nil
	queuedRollItems[numOfQueuedRollItems] = nil
end

-- not local, because it has to be callable by the global slash command
function PLH_EndRolls()
	-- clear the countdown for the existing roll
	rollDelayFrame:SetScript('OnUpdate', nil)
	delay = 0
	
	-- determine the winner(s)
	local winners = nil
	local highRoll = 0
	for name, roll in pairs(currentRolls) do
		roll = tonumber(roll)
		if winners == nil or roll > highRoll then
			winners = { name }
			highRoll = roll
		elseif winners ~= nil and roll == highRoll then
			table.insert(winners, name)
		end
	end
	
	-- notify everyone of the results of the rolls
	if winners ~= nil then
		if #winners > 1 then
			PLH_SendBroadcast(GetNames(winners) .. ' tied for ' .. currentRollItem .. ' from ' .. PLH_GetNameWithoutRealm(currentRollOwner) .. ' with a ' .. highRoll, true)
		else
			PLH_SendBroadcast(winners[1] .. ' won ' .. currentRollItem .. ' from ' .. PLH_GetNameWithoutRealm(currentRollOwner) .. ' with a ' .. highRoll, true)
		end
	else
		PLH_SendBroadcast('Nobody rolled for ' .. currentRollItem .. ' from ' .. PLH_GetNameWithoutRealm(currentRollOwner), true)
	end

	-- if there's another roll to do, let's delay a few seconds before starting the next roll
	if (numOfQueuedRollItems > 0) then
		rollDelayFrame:SetScript('OnUpdate', function(self, elapsed)
			nextRollDelay = nextRollDelay + elapsed
			if nextRollDelay >= DELAY_BETWEEN_ROLLS then
				rollDelayFrame:SetScript('OnUpdate', nil)
				nextRollDelay = 0
				ClearRolls()
				AskForRolls()
			end
		end)
	else			
		ClearRolls()
	end	
end

local function GetItemFromQueueByPlayer(player)
	for key, value in pairs(queuedRollOwners) do
		if value == player then
			return queuedRollItems[key]
		end
	end
	return nil
end

local function ProcessWhisper(message, sender)
	if PLH_COORDINATE_ROLLS and PlayerCanCoordinateRolls() then
		if not string.find(sender, '-') then
			sender = PLH_GetUnitNameWithRealm(sender)
		end

		-- if the person whispered 'trade [item]' or '[item] trade', then add the item to the array so we can process it
		local _, _, whisperedItem = string.find(message, 'trade  (|.+|r)')
		if whisperedItem == nil then
			_, _, whisperedItem = string.find(message, 'Trade  (|.+|r)')
		end
		if whisperedItem == nil then
			_, _, whisperedItem = string.find(message, 'TRADE  (|.+|r)')
		end
		if whisperedItem == nil then
			_, _, whisperedItem = string.find(message, '(|.+|r) trade')
		end
		if whisperedItem == nil then
			_, _, whisperedItem = string.find(message, '(|.+|r) Trade')
		end
		if whisperedItem == nil then
			_, _, whisperedItem = string.find(message, '(|.+|r) TRADE')
		end
		if whisperedItem ~= nil then
			whisperedItems[sender] = whisperedItem
		end

		message = string.upper(message)
		if whisperedItem ~= nil or message == TRADE_MESSAGE or message == '\'' .. TRADE_MESSAGE .. '\'' then
			if whisperedItems[sender] ~= nil then
				local item = whisperedItems[sender]
				whisperedItems[sender] = nil
				QueueItem(sender, item)
				-- if we're still rolling for another item, let the person know their item is queued
				if currentRollItem ~= nil then
					PLH_SendWhisper('Thank you! ' .. item .. ' will be rolled for after current rolls are done.', sender)
				else 
					AskForRolls()
				end
			elseif currentRollOwner == sender then
				PLH_SendWhisper('Your ' .. currentRollItem .. ' is currently being rolled for', sender)
			else
				local item = GetItemFromQueueByPlayer(sender)
				if item then
					PLH_SendWhisper('Your ' .. item .. ' is already in queue to be rolled for', sender)
				else
					PLH_SendWhisper('No record of which item you looted! Whisper \'trade [item]\' to ' .. UnitName('player') .. ' if you would still like to trade the item.', sender)
				end
			end
		end
	end
end

local function WhisperReceivedEvent(self, event, ...)
	local message, sender = ...

	ProcessWhisper(message, sender)
end

local function BNWhisperReceivedEvent(self, event, ...)
	local message = ...

	local bnetIDAccount = select(13, ...)
	local bnetIDGameAccount = select(6, BNGetFriendInfoByID(bnetIDAccount));
	local _, sender, _, realmName = BNGetGameAccountInfo(bnetIDGameAccount)

	if realmName ~= nil then
		sender = sender .. '-' .. realmName
	end
	
	ProcessWhisper(message, sender)
end

local function RollReceivedEvent(self, event, ...)
	if currentRollItem ~= nil then
		local message = select(1, ...)
		if message then
--			local name, roll, minRoll, maxRoll = message:match('^(.+) rolls (%d+) %((%d+)%-(%d+)%)$')
			local name, roll, minRoll, maxRoll = message:match(PLH_RANDOM_ROLL_RESULT_PATTERN)
			if name then
				local fullname = PLH_GetUnitNameWithRealm(name)
				if minRoll ~= '1' or maxRoll ~= '100' then
					PLH_SendBroadcast(name .. ' rolled ' .. minRoll .. ' - ' .. maxRoll .. '; roll ignored', false)
				elseif currentRolls[name] ~= nil then
					PLH_SendBroadcast(name .. ' rolled multiple times; only the first roll of ' .. currentRolls[name] .. ' counts', false)
				elseif fullname ~= nil and not IsEquippableItemForCharacter(currentRollItem, fullname) then
					PLH_SendBroadcast(name .. ' is not eligible for ' .. currentRollItem .. '; roll ignored', false)
				else 
					currentRolls[name] = roll
				end
			end		
		end
	end
end

-- note that GetLootMethod() only works if you're in a party or in a raid.  If you're in an instance (i.e. queued via LFR),
--   then loot method is automatically personal loot
local function IsPersonalLoot()
	local isInstance, instanceType = IsInInstance()
	return (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or (IsInGroup() and GetLootMethod() == 'personalloot'))
		and (instanceType == "party" or instanceType == "raid")
end

local function ResetVariables()
	delay = 0
	nextRollDelay = 0

	whisperedItems = {}

	numOfQueuedRollItems = 0;
	queuedRollOwners = {}
	queuedRollItems = {}

	currentRollOwner = nil
	currentRollItem = nil
	currentRolls = {}

	groupInfoCache = {}
end

-- The following uses GetInventoryItemLink() to look up unit's equipped items.  That method can only be called for
--   the player, or within the scope of an INSPECT_READY event for other group members.
local function UpdateGroupInfoCache(unit)
	local name = PLH_GetUnitNameWithRealm(unit)

	if name ~= nil then
--		PLH_SendDebugMessage('   Updating GroupInfoCache for ' .. name .. ', inspectIndex = ' .. inspectIndex)
		local characterDetails
		if groupInfoCache[name] == nil then
			characterDetails = {}
			local _, class = UnitClass(unit)
			characterDetails['ClassName'] = class
			local spec = GetInspectSpecialization(unit)
			characterDetails['Spec'] = spec
			local level = UnitLevel(unit)
			characterDetails['Level'] = level
			characterDetails['InspectCount'] = 0
		else
			characterDetails = groupInfoCache[name]
--			spec = GetInspectSpecialization(unit)
			if characterDetails['InspectCount'] ~= nil then
				characterDetails['InspectCount'] = characterDetails['InspectCount'] + 1
			end
		end
		
		local updatedItemCount = 0
		local item
		for i = _G.INVSLOT_FIRST_EQUIPPED, _G.INVSLOT_LAST_EQUIPPED do
			if i ~= _G.INVSLOT_BODY and i ~= INVSLOT_TABARD then -- ignore shirt and tabard slots
				item = GetInventoryItemLink(UnitName(unit), i)
				if item ~= nil then
					if characterDetails[i] == nil or characterDetails[i] ~= item then
--					PLH_SendDebugMessage('      adding/updating item ' .. item)			
						updatedItemCount = updatedItemCount + 1
						characterDetails[i] = nil  -- remove existing first
						characterDetails[i] = item
						characterDetails['InspectCount'] = 0  -- if we actually updated something, reset the inspect counter
					end
					
					-- if we're adding the weapon, also add relics
					if i == _G.INVSLOT_MAINHAND or i == _G.INVSLOT_OFFHAND then
						item = select(2, GetItemInfo(item))  -- hack since relics may not be loaded into cache right away, query the item again
						local _, relic1 = GetItemGem(item, 1)
						if relic1 ~= nil then
							characterDetails[PLH_RELICSLOT + 1] = relic1
						end
						local _, relic2 = GetItemGem(item, 2)
						if relic2 ~= nil then
							characterDetails[PLH_RELICSLOT + 2] = relic2
						end
						local _, relic3 = GetItemGem(item, 3)
						if relic3 ~= nil then
							characterDetails[PLH_RELICSLOT + 3] = relic3
						end
					end
				end
			end
		end

		-- If we didn't find any items (ex: when player first starts the game), don't add this person to the cache unless it's first time (for class/etc)
		if updatedItemCount > 0 or groupInfoCache[name] == nil then
			groupInfoCache[name] = nil  -- remove any existing entry first
			groupInfoCache[name] = characterDetails
		end
		PLH_SendDebugMessage('   Updated ' .. updatedItemCount .. ' items for ' .. name .. '; loop ' .. inspectLoop .. '; char ' .. (inspectIndex - 1))
	end
end

-- returns true if the characterName is in the raid/party
local function IsCharacterInGroup(characterFullname)
	local index = 1
	local name = select(1, GetRaidRosterInfo(index))
	while name ~= nil do
		if name == characterFullname then
			return true
		end
		-- RaidRosterInfo will only give us name by itself if the character is on the same realm as the player, so check that scenario too
		if PLH_GetFullName(name, GetRealmName()) == characterFullname then
			return true
		end
		index = index + 1
		name = select(1, GetRaidRosterInfo(index))
	end
	return false
end

-- returns true if group member was able to be inspected; false otherwise
local function InspectGroupMember(characterName)
	if characterName ~= nil and characterName ~= UnitName('player') then   -- no need to inspect ourselves
		if CanInspect(characterName) then -- and UnitIsConnected(characterName) - not necessary to include this check since we're including distance check
--			if CheckInteractDistance(characterName, 1) then  -- this API call has not been changed by Blizz to match the new larger inspect radius
			if UnitIsVisible(characterName) then
				NotifyInspect(characterName)
				notifyInspectName = characterName
				PLH_wait(DELAY_BETWEEN_INSPECTIONS, PLH_InspectNextGroupMember)
				return true
			else
				PLH_SendDebugMessage('   ' .. characterName .. ' out of range for inspect')
			end
		else
			PLH_SendDebugMessage('   Unable to inspect ' .. characterName)
		end
	end
	return false
end

-- An Inspect Loop (managed by inspectLoop) is a complete iteration of inspection for every member in the group.  
-- 		Will only attempt to inspect characters whose count of cached items is lower than expected.
--      The goal of this loop is to work around the limitation whereby the inspect API doesn't necessarily provide us
--      all items equipped by the character.
-- not local, because it is called by (and calls) InspectGroupMember(characterName), which is defined above
function PLH_InspectNextGroupMember()
	-- attempt the inspect the next person; if they're not inspectable, move onto the next

	-- Removed this inside-loop retry logic.  It works, but in testing it very rarely accomplished its goal; usually the retry attempts
	--    to inspect failed just like the original attempt.  We now have inspectLoop logic build in, which will still
	--    give the cache more opportunities to be updated - so no need for the retries here
	-- Retry logic
--	if notifyInspectName ~= nil then   -- InspectReady didn't get called for the person we queued
--		if inspectRetries < MAX_INSPECT_RETRIES then
--			PLH_SendDebugMessage('Retrying inspection for ' .. notifyInspectName)
--			inspectRetries = inspectRetries + 1
--			if InspectGroupMember(notifyInspectName) then  -- we triggered a notify, so don't do the while loop
--				return true  -- exit this function so we don't attempt to inspect the next character
--			end
--		end
		-- if we get to here, then it's time to give up on inspecting this character - either we couldn't even trigger a
		--    NotifyInspect, or we already triggered the max # of NotifyInspects and didn't get an InspectReady response
		notifyInspectName = nil  -- even though we commented out the retry logic, we still want to nullify notifyInspectName
			-- since it's unlikely we'll get an INSPECT_READY at this point (3 seconds after calling NotifyInspect)
--		inspectRetries = 0
--	end

	-- Call InspectGroupMember for the next person in the group
	local characterName
	local queuedAnInspection = false
	local expectedItemCount
	local expectedRelicCount
	local class
	local spec
	local level
	local inspectCount
	while inspectIndex <= maxInspectIndex  and not queuedAnInspection do
		characterName = select(1, GetRaidRosterInfo(inspectIndex))
		if characterName ~= nil then  -- safeguard; character may have left the roster between the time we started the call and now
			local numCachedItems = 0
			local numCachedRelics = 0
			local fullname = characterName 		--characterName may or may not have realm.  we want to preserve it the way it is for the call to InspectGroupMember,
												--   but need the name-realm version of the name to look up the element in the cache
			if not string.find(fullname, '-') then
				fullname = PLH_GetFullName(characterName, GetRealmName())
			end
			
			if fullname ~= nil then
				expectedItemCount = NUM_EXPECTED_ITEMS
				expectedRelicCount = 0
				inspectCount = 0
				if groupInfoCache[fullname] ~= nil then
					numCachedItems = PLH_GetItemCountFromCache(fullname)
					numCachedRelics = PLH_GetRelicCountFromCache(fullname)
					class = groupInfoCache[fullname]['ClassName']
					spec = groupInfoCache[fullname]['Spec']
					level = groupInfoCache[fullname]['Level']
					inspectCount = groupInfoCache[fullname]['InspectCount']
					expectedItemCount = GetExpectedItemCount(class, spec, level)
					expectedRelicCount = GetExpectedRelicCount(level)
				end

--				if inspectCount >= MAX_INSPECTS_PER_CHARACTER then
--					PLH_SendDebugMessage('Discontinuing inspections for ' .. fullname .. ' due to max inspect limit')
--				end
				
				if inspectCount < MAX_INSPECTS_PER_CHARACTER and (numCachedItems < expectedItemCount or numCachedRelics < expectedRelicCount) then  -- if we've already cached 15 or more items, don't bother refreshing
					queuedAnInspection = InspectGroupMember(characterName)
				end
			end
		end
		inspectIndex = inspectIndex + 1
	end
	
	-- The following logic is meant to work around a limitation of the inspect API.  When you inspect a character, you're
	-- not guaranteed to actually receive all of their equipped items back!  To work around this limitation, we will
	-- perform additional loops of inspecting each character if the number of items we've cached for them is fewer than
	-- the expected number of items that someone would equip (15 items for a person using a 1-hander, +1 element for the
	-- ClassName that we're storing in the cache)
	if inspectIndex > maxInspectIndex then -- that means we just completed our current loop
		if inspectLoop < MAX_INSPECT_LOOPS then
			-- let's start the next loop
			inspectIndex = 1  -- we're triggering the call to the 1st member via PLH_InspectNextGroupMember below; increment
				-- the inspectIndex counter so the next element that gets picked up when we come back into PLH_InspectNextGroupMember
				-- is the 2nd
			inspectLoop = inspectLoop + 1
			if queuedAnInspection then  -- if we just queued someone for inspection, wait before we start the new loop
				PLH_wait(DELAY_BETWEEN_INSPECTIONS, PLH_InspectNextGroupMember)
			else  -- otherwise start the new loop immediately
				PLH_InspectNextGroupMember()
			end
		elseif not queuedAnInspection then
			-- we've finished all loops
--			PLH_PrintCache()
		end
	end
	
end

-- note that the INSPECT_READY event may have been triggered by WoW or by another addon
--   for example, WoW triggers it when a person in inspect range swaps their gear
local function InspectReadyEvent(self, event, ...)
	local guid = select(1, ...)
	local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid)

	if notifyInspectName ~= nil and (notifyInspectName == name or notifyInspectName == PLH_GetFullName(name, realm)) then  -- confirm this InspectReadyEvent is for the person we triggered for inspection.
		UpdateGroupInfoCache(name)  -- only update the cache if we requested the inspect, otherwise the wrong cache entry could be updated!
		-- if we triggered the inspection, clear the flags that we had set
		ClearInspectPlayer()  -- note that we only want to call ClearInspectPlayer() if we're the ones who queued up
			-- the inspection; otherwise, we'll prevent whoever wanted to inspect the player from seeing data...for
			-- example, a player using the UI to inpect a player would see all empty slots if we called ClearInspectPlayer()!
		notifyInspectName = nil  -- clear this flag since we're done inspecting the person
	end
end

local function PopulateGroupInfoCache()
	local now = time()
	
	if now - priorCacheRefreshTime > 3 then  -- only refresh if prior refresh was more than 3 seconds ago
		priorCacheRefreshTime = now
	
		-- remove characters from the cache if they're no long in the raid/party
		for name, details in pairs (groupInfoCache) do
			if not IsCharacterInGroup(name) then
				PLH_SendDebugMessage('Removing entry for ' .. name .. ' from cache')
				groupInfoCache[name] = nil
			end
		end

		if IsInGroup() then
			-- If we're already doing an inspect loop, don't interupt it; just do nothing with the request to
			-- PopulateGroupInfoCache() and let the inspect loop continuue on its way!  If the inspectIndex > maxInspectIndex
			-- and inspectLoop > MAX_INSPECT_LOOPS, then we know we've finished all inspections for all loops, so
			-- we can start a brand new loop!
			if inspectIndex > maxInspectIndex and inspectLoop >= MAX_INSPECT_LOOPS then
--				PLH_SendDebugMessage('Refreshing cache')
				inspectIndex = 1
				inspectLoop = 1
				maxInspectIndex = GetNumGroupMembers()
				PLH_InspectNextGroupMember()
			end
		end
	end
end

local function Enable()
	ResetVariables()
	isEnabled = true
	lootReceivedEventFrame:RegisterEvent('CHAT_MSG_LOOT')
	--whisperReceivedEventFrame:RegisterEvent('CHAT_MSG_WHISPER')
	--bnWhisperReceivedEventFrame:RegisterEvent('CHAT_MSG_BN_WHISPER')
	rollReceivedEventFrame:RegisterEvent('CHAT_MSG_SYSTEM')
	inspectReadyEventFrame:RegisterEvent('INSPECT_READY')
	combatStatusChangedEventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')   -- player entered combat
	groupMemberInfoChangedEventFrame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	groupMemberInfoChangedEventFrame:RegisterEvent('UNIT_INVENTORY_CHANGED')
end

local function Disable()
	isEnabled = false
	lootReceivedEventFrame:UnregisterAllEvents()
	-- keep the following listeners enabled so people can still use the roll coordinate mode during master looter (ex: for BoE drops)
	--whisperReceivedEventFrame:UnregisterAllEvents()
	--bnWhisperReceivedEventFrame:UnregisterAllEvents()
	rollReceivedEventFrame:UnregisterAllEvents()
	inspectReadyEventFrame:UnregisterAllEvents()
	combatStatusChangedEventFrame:UnregisterAllEvents()
	groupMemberInfoChangedEventFrame:UnregisterAllEvents()
	groupInfoCache = {}
end

local function EnableOrDisable()
	local shouldBeEnabled = IsPersonalLoot()
	if not isEnabled and shouldBeEnabled then	
		Enable()
	elseif isEnabled and not shouldBeEnabled then
		Disable()
	end
	if isEnabled then 
		PopulateGroupInfoCache()
	end
end

local function GroupMemberInfoChangedEvent(self, event, ...)
	local unit = ...
	if unit == 'player' then
		-- do nothing
	else
		-- update cache
		local name = PLH_GetUnitNameWithRealm(unit)
		if name ~= nil then
			groupInfoCache[name] = nil
			if event == 'UNIT_INVENTORY_CHANGED' then
				-- we need to do another inspect to refresh the cache
				PopulateGroupInfoCache()  -- don't want to mess with any existing cache refresh flow by inspecting this specific character,
					-- so trigger general refresh, which will refresh this character since we've nullified their entry
			else  -- PLAYER_SPECIALIZATION_CHANGED
				-- spec change already gives us the inspect info
				UpdateGroupInfoCache(unit)
			end
		end
	end
end

local function RosterUpdatedEvent(self, event, ...)
	-- the following is a bit of a hack to work around a Blizzard issue.  While the player is logging in, IsInGroup()
	-- is false.  If the user is already in a group (for example, logging back in after a disconnect or doing a /reload),
	-- A ROSTER_UPDATE event triggers.  However, IsInGroup() is not immediately set to true when the event fires!
	-- So if we get a ROSTER_UPDATE event and we're currently disabled, lets wait 1 second to make sure IsInGroup()
	-- gives us the correct value.  Similar behavoir occurred in LFR testing where people joining/leaving the group
	-- may not have been automatically available.  Hence the delay.
	PLH_wait(2, EnableOrDisable)
end

-- triggered when the player enters or leaves combat status, which are the perfect times to refresh the cache since
--    the people who will be eligible for loot should be close enough to be inspected
local function CombatStatusChangedEvent(self, event, ...)
	if isEnabled then
		PopulateGroupInfoCache()
	end
end

function SlashCmdList.PLHelperCommand(msg, editbox)
	if msg == nil or msg == '' then
		InterfaceOptionsFrame_OpenToCategory(PLH_LONG_ADDON_NAME)
		InterfaceOptionsFrame_OpenToCategory(PLH_LONG_ADDON_NAME)  -- hack; called twice to get around Blizz bug of it not opening to correct page right away
	elseif msg == 'endroll' then
		if currentRollItem ~= nil then
			if nextRollDelay > 0 then
				PLH_SendUserMessage('Please wait until the next roll begins')
			else
--				PLH_SendBroadcast(UnitName('player') .. ' ended rolls', false)
				PLH_EndRolls()
			end
		else
			PLH_SendUserMessage('There are currently no items being rolled for')
		end
--	elseif msg == 'test' then
--		PLH_UnitTest()
	else
		PLH_SendUserMessage('Unknown parameter. Options are:\n  [/plh]  :  open interface options\n  [/plh endroll]  :  force current roll to end')
	end
end

local function Initialize(self, event, addonName, ...)
	if addonName == 'PersonalLootHelper' then
	
		PLH_SendDebugMessage('PLH Initializing')
		
		if PLH_MIN_QUALITY == nil then
			PLH_NOTIFY_MODE = DEFAULT_NOTIFY_MODE
			PLH_INCLUDE_BOE = DEFAULT_INCLUDE_BOE
			PLH_MIN_ILVL = DEFAULT_MIN_ILVL
			PLH_MIN_QUALITY = DEFAULT_MIN_QUALITY
			PLH_DEBUG = DEFAULT_DEBUG
			PLH_CURRENT_SPEC_ONLY = DEFAULT_CURRENT_SPEC_ONLY
		end
		
		-- need global variable option added in version 1.21
		if PLH_CHECK_CHARACTER_LEVEL == nil then
			PLH_CHECK_CHARACTER_LEVEL = DEFAULT_CHECK_CHARACTER_LEVEL
			PLH_COORDINATE_ROLLS = (PLH_NOTIFY_MODE == NOTIFY_MODE_COORDINATE_ROLLS)
			PLH_NOTIFY_GROUP = (PLH_NOTIFY_MODE == NOTIFY_MODE_GROUP or PLH_NOTIFY_MODE == NOTIFY_MODE_COORDINATE_ROLLS)
			PLH_HIGHLIGHT_RAID_FRAMES = DEFAULT_HIGHLIGHT_RAID_FRAMES
			PLH_HIGHLIGHT_SIZE = DEFAULT_HIGHLIGHT_SIZE
		end
		
		if lootReceivedEventFrame == nil then

			lootReceivedEventFrame = CreateFrame('Frame')
			lootReceivedEventFrame:SetScript('OnEvent', LootReceivedEvent)

			whisperReceivedEventFrame = CreateFrame('Frame')
			whisperReceivedEventFrame:SetScript('OnEvent', WhisperReceivedEvent)

			bnWhisperReceivedEventFrame = CreateFrame('Frame')
			bnWhisperReceivedEventFrame:SetScript('OnEvent', BNWhisperReceivedEvent)

			rollReceivedEventFrame = CreateFrame('Frame')
			rollReceivedEventFrame:SetScript('OnEvent', RollReceivedEvent)

			inspectReadyEventFrame = CreateFrame('Frame')
			inspectReadyEventFrame:SetScript('OnEvent', InspectReadyEvent)

			rosterUpdatedEventFrame = CreateFrame('Frame')
			rosterUpdatedEventFrame:SetScript('OnEvent', RosterUpdatedEvent)
			rosterUpdatedEventFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
			
			groupMemberInfoChangedEventFrame = CreateFrame('Frame')
			groupMemberInfoChangedEventFrame:SetScript('OnEvent', GroupMemberInfoChangedEvent)
			
			combatStatusChangedEventFrame = CreateFrame('Frame')
			combatStatusChangedEventFrame:SetScript('OnEvent', CombatStatusChangedEvent)

			rollDelayFrame = CreateFrame('Frame')
			highlightDelayFrame = CreateFrame('Frame')

			-- enable listeners here so people can use the loot coordination feature even for master loot (ex: for BoE drops)
			whisperReceivedEventFrame:RegisterEvent('CHAT_MSG_WHISPER')
			bnWhisperReceivedEventFrame:RegisterEvent('CHAT_MSG_BN_WHISPER')
		end
		
		PLH_CreateOptionsPanel()		
	end
end

--Initialize()
addonLoadedFrame = CreateFrame('Frame')
addonLoadedFrame:SetScript('OnEvent', Initialize)
addonLoadedFrame:RegisterEvent('ADDON_LOADED')

--[[
*********************************************************
Debug/Testing functions
*********************************************************
]]--

function PLH_PrintCache(showDetails, characterName)
	if PLH_DEBUG then
		local num_characters = 0
		local item_msg = ''
		for name, characterDetails in pairs(groupInfoCache) do
			num_characters = num_characters + 1
			item_msg = item_msg .. PLH_GetItemCountFromCache(name) .. '/' .. PLH_GetRelicCountFromCache(name) .. ' ' 
--			item_msg = item_msg .. (#groupInfoCache[name] -1) .. ' '  -- subtracting 1 since everyone will have a ClassName element
		end
		PLH_SendDebugMessage('Cache contains ' .. num_characters .. ' member(s). Item count per member: ' .. item_msg)

		if (showDetails) then
			for name, details in pairs (groupInfoCache) do
				if name == nil or name == characterName then
					PLH_SendDebugMessage('Cache information for ' .. name)
					if details == nil then	
						PLH_SendDebugMessage('   details is nil')
					else
						for slotID, item in pairs(details) do
							PLH_SendDebugMessage('   ' .. slotID .. ' = ' .. item)
						end
					end
				end
			end
		end
	end
end

function PLH_EnableDebug()
	PLH_DEBUG = true
end

function PLH_DisableDebug()
	PLH_DEBUG = false
end

function PLH_RefreshCache()
	groupInfoCache = {}
	PopulateGroupInfoCache()
end

function PLH_TestItems(characterIndex)
	if characterIndex == nil then
		PLH_SendDebugMessage('Usage: PLH_TestItems(characterIndex)')
	else
		characterName = select(1, GetRaidRosterInfo(characterIndex))
		if not string.find(characterName, '-') then
			characterName = PLH_GetFullName(characterName, GetRealmName())
		end
		
		PLH_SendDebugMessage('Evaluating items equipped by ' .. characterName)

		local item
		for itemIndex = 1, 19 do
			if characterName == PLH_GetUnitNameWithRealm('player') then
				item = GetInventoryItemLink('player', itemIndex)	
			else
				item = groupInfoCache[characterName][itemIndex]
			end

			if item ~= nil then
				PLH_SendDebugMessage('   evaluating ' .. item)
				
				local isEquippable
				for evalIndex = 1, GetNumGroupMembers() do
					evalName = select(1, GetRaidRosterInfo(evalIndex))
					if not string.find(evalName, '-') then
						evalName = PLH_GetFullName(evalName, GetRealmName())
					end
				
					isEquippable = IsEquippableItemForCharacter(item, evalName)
					PLH_SendDebugMessage('      For ' .. evalName ..
						' equippable = ' .. tostring(isEquippable) ..
						'; upgrade = ' .. tostring(isEquippable and IsAnUpgradeForCharacter(item, evalName))
						)
				end
			end
		end
		
		local relic
		for relicIndex = 1, 3 do
			if characterName == PLH_GetUnitNameWithRealm('player') then
				local weapon = GetInventoryItemLink('player', INVSLOT_MAINHAND)
				_, relic = GetItemGem(weapon, relicIndex)
			else
				relic = groupInfoCache[characterName][PLH_RELICSLOT + relicIndex]
			end

			if relic ~= nil then
				PLH_SendDebugMessage('   evaluating ' .. relic)
				
				local isEquippable
				for evalIndex = 1, GetNumGroupMembers() do
					evalName = select(1, GetRaidRosterInfo(evalIndex))
					if not string.find(evalName, '-') then
						evalName = PLH_GetFullName(evalName, GetRealmName())
					end
				
					isEquippable = IsEquippableItemForCharacter(relic, evalName)
					PLH_SendDebugMessage('      For ' .. evalName ..
						' equippable = ' .. tostring(isEquippable) ..
						'; upgrade = ' .. tostring(isEquippable and IsAnUpgradeForCharacter(relic, evalName))
						)
				end
			end
		end
	end
end

function PLH_TestRelic(relic, item)
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(relic)
	print('name ', name)
	print('class ', class)  -- 'Gem'
--	print('iLevel ', iLevel)  -- gives wrong value
	print('subclass ', subclass)  -- 'Artifact Relic'
--	print('equipSlot ', equipSlot)  -- nil
	print('real ilvl is ', PLH_GetRealILVL(relic))  -- correct
	print('IsEquippableItem	is ', IsEquippableItem(relic))  -- false, so we'll need to change where we do this check!
	print('IsArtifactRelicItem is ', IsArtifactRelicItem(relic))  -- true; can add this where we check isEquippable
	
	local gemname, gemlink = GetItemGem(item, 1)  -- 2nd arg is index; does return gem link from artifact
	print('gemname ', gemname)
	print('gemlink ', gemlink)
	print('real ilvl is ', PLH_GetRealILVL(gemlink))  -- correct

	local gemname, gemlink = GetItemGem(item, 2)  -- 2nd arg is index; does return gem link from artifact
	print('gemname ', gemname)
	print('gemlink ', gemlink)
	print('real ilvl is ', PLH_GetRealILVL(gemlink))  -- correct

	local gemname, gemlink = GetItemGem(item, 3)  -- 2nd arg is index; does return gem link from artifact
	print('gemname ', gemname)
	print('gemlink ', gemlink)
	print('real ilvl is ', PLH_GetRealILVL(gemlink))  -- correct

--	local slotId, texture, checkRelic = GetInventorySlotInfo("MainHandSlot")
--	print('checkRelic1 ', checkRelic)  -- false
	
--	local slotId, texture, checkRelic = GetInventorySlotInfo("RangedSlot")
--	print('checkRelic2 ', checkRelic)  -- invalid slot error

	-- following method not found even though it's in API docs
--	local gem1, gem2, gem3 = GetInventoryItemGems(INVSLOT_RANGED)	--18
--	local gem1, gem2, gem3 = GetInventoryItemGems(18)	--18
--	print('gem1 ', gem1)
--	print('gem2 ', gem2)
--	print('gem3 ', gem3)
end

function PLH_Test(item)
	print(IsEquippableItemForCharacter(item, "Madone-Zul'jin"))
end

--[[
*********************************************************
Code from BlizzBugsSuck.lua to resolve known blizzard bug when opening interface options
*********************************************************
]]--
-- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
-- Confirmed still broken in 6.2.2.20490 (6.2.2a)
--[[
local doNotRun = false

do
	local function get_panel_name(panel)
		local tp = type(panel)
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		if tp == "string" then
			for i = 1, #cat do
				local p = cat[i]
				if p.name == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel
					end
				end
			end
		elseif tp == "table" then
			for i = 1, #cat do
				local p = cat[i]
				if p == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel.name
					end
				end
			end
		end
	end

	local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
		if doNotRun or InCombatLockdown() then return end
		local panelName = get_panel_name(panel)
		if not panelName then return end -- if its not part of our list return early
		local noncollapsedHeaders = {}
		local shownpanels = 0
		local mypanel
		local t = {}
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, #cat do
			local panel = cat[i]
			if not panel.parent or noncollapsedHeaders[panel.parent] then
				if panel.name == panelName then
					panel.collapsed = true
					t.element = panel
					InterfaceOptionsListButton_ToggleSubCategories(t)
					noncollapsedHeaders[panel.name] = true
					mypanel = shownpanels + 1
				end
				if not panel.collapsed then
					noncollapsedHeaders[panel.name] = true
				end
				shownpanels = shownpanels + 1
			end
		end
		local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
		if shownpanels > 15 and Smin < Smax then
			local val = (Smax/(shownpanels-15))*(mypanel-2)
			InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
		end
		doNotRun = true
		InterfaceOptionsFrame_OpenToCategory(panel)
		doNotRun = false
	end

	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end
]]--
--[[
-- following only returns for some items (notably trinkets), and only returns spec IDs relevant to the player
function PrintItemSpecInfo(item)
	specs = {}
	results = GetItemSpecInfo(item, specs)
	print('results is ', results)
	print('#results is ', #results)
	print('#specs is ', #specs)
	for i = 1, #results do
		print(results[i])
	end
	for i = 1, #specs do
		print(results[i])
	end
	for key, value in pairs(results) do
		print('key = ', key)
		print('value = ', value)
	end
	for key, value in pairs(specs) do
		print('key2 = ', key)
		print('value2 = ', value)
	end
end
]]--

function PLH_TestHighlight(item)
	HighlightRaidFrames("Madone-Zul'jin", item)
end
