# v1.20.9

- Fixed an error switching specializations

# v1.20.8

- Updated for 11.1.0
- Fixed a bug where adding Equipment Set tooltip lines could break other lines wrapping

# v1.20.7

- Updated for 11.0.7

# v1.20.6

- Fixed a issue showing some debug info

# v1.20.5

- Fixed error trying to get hero talents when unavailable
- Fixed an issue trying to activate talent sets on characters below level 10

# v1.20.4

- Fixed an issue where Hero Talent trees would be considered active when there are still points available

# v1.20.3

- Updated for 11.0.5

# v1.20.2

- Fixed missing Dracthyr and Earthern from the race restrictions

# v1.20.1

- Updated the maximum width of the talent pane
- Updated the Hero Talents pane to no longer allowed horizontal resizing

# v1.20.0

- Added support for instance and difficulty filtering in the conditions sidebar
- Added delves option to scenario conditions
- Fixed raid difficulty order for Nerub-ar Palace

# v1.19.3

- Fixed Delete Character Data not deleting character data
- Fixed issues selecting specialization restrictions for hero talents

# v1.19.2

- Fixed the order of action bars 2 through 5

# v1.19.1

- Updated conditions for Nerub-ar Palace
- Fixed The War Within expansion check
- Fixed hero talents showing errors when the current character is missing a required talent

# v1.19.0

- Added support for Skyriding action bar
- Fixed an issue importing Blizzard talent loadouts

# v1.18.3

- Updated talent sets to be automatically deleted if they are not in use when they are removed from the Blizzard loadouts
- Fixed an error when toggling ignore on or off for action bar 8

# v1.18.2

- Fixed an issue with processing action bar items from the spell book

# v1.18.1

- Updated verison for 11.0.0

# v1.18.0-beta

- Added support for Hero Talent sets
- Updated to cancel loading switching when the talent change spell is cancelled
- Fixed an error when empty item links are found in Blizzard equipment sets

# v1.17.1

- Updated for 10.2.7

# v1.17.0

- Updated internal events to use the global EventRegistry and added events for all sets
- Updated action bar restrictions dropdown items to be checkboxes
- Fixed an error when creating conditions for Aberrus, the Shadowed Crucible raid
- Fixed some errors with missing functions in The War Within

# v1.16.0

- Fixed an error when getting the current season for wow versions that dont support seasons
- Fixed an error when viewing Dragonflight talent trees with nodes that have no cost
- Fixed an error when viewing equipment sets for other characters
- Fixed an issue where equipment sets could not be filtered by class unless they had a specialization restriction set
- Fixed an issue where specialization restrictions would block Exile's Reach characters
- Fixed some errors for characters in Exile's Reach
- Updated for initial support on The War Within alpha
- Updated for Dragonflight Season 4 and boilerplate The War Within season 1
- Updated to only allow updating action bar sets when the set restrictions match the current character

# v1.15.8

- Fixed an issue with unique-equipped items not being categorized correctly

# v1.15.7

- Updated verison for 10.2.5

# v1.15.6

- Updated verison for 10.2.5

# v1.15.5

- Fixed an issue where macros were not being placed in action slots that already had macros

# v1.15.4

- Fixed an issue where loadouts wouldnt show as active if they contained action bar sets with macros

# v1.15.3

- Fixed error creating and updating action bars
- Updated verison for 10.2

# v1.15.2

- Updated for 10.2
- Fixed error selecting mythic plus affix in conditions

# v1.15.2

- Updated for 10.1.7

# v1.15.1

- Fixed an issue importing loadouts using Blizzard loadout string

# v1.15.0

- Updated talent tree caching to be more accurate
- Updated for 10.1.5

# v1.14.2

- Updated interface number for 10.1.0
- Fixed an error where the sidebar wouldnt always show the correct number of buttons
- Updated pvptalents for 10.1.0

# v1.14.1

- Fixed an error while getting the current season on first login

# v1.14.0

- Initial support for 10.1

# v1.13.5

- Updated action bar item handling to allow placing missing items on action bars unless they are equippable
- Fixed a typo

# v1.13.4

- Fixed an error where old, removed talent nodes were not being removed from talent sets

# v1.13.3

- Fixed an issue where some talents could incorrectly be treated as choice nodes

# v1.13.2

- Updated so action bar sets will ignore items if none are available
- Fixed an issue where equipment set errors could break other parts of the UI
- Fixed an issue where some unused action bar slots were not being ignored
- Fixed an issue where deleting a characters data would not delete the related Blizzard talent sets

# v1.13.1

- Updated for 10.0.7

# v1.13.0-beta

- Added support for resizing the main window, including horizontal resizing for the talents tab.
- Fixed a slight gap in the background of the main window

# v1.12.4

- Added log message for the internal trait tree version when changing Dragonflight Talents
- Updated trait tree data with missing multi-choice node for Rogues
- Fixed WoW Icon in the sidebar overlapping text when no category filters were enabled
- Fixed a bug where trait tree cache could be update before the players specialization had completely changed causing it to become temporarily corrupted
- Fixed new Blizzard talent trees not being tracked instantly
- Fixed an error where changing pvp talents would require a rested area or a tome

# v1.12.3

- Fixed clearing blizzard talent trees incorrectly when switch specialization

# v1.12.2

- Fixed an issue that could sometimes cause the active talent loadout to be saved like a normal loadout
- Fixed an issue causing the Blizzard talent tree window to sometimes lose the class icon

# v1.12.1

- Fixed an issue causing some invalid Blizzard loadouts to be saved incorrectly

# v1.12.0-beta

- Added support for importing Blizzard talent loadout strings directly in to BtWLoadouts

# v1.11.1

- Added buttons to swap between Class and Spec talent trees

# v1.11.0-beta

- Added buttons to swap between Class and Spec talent trees

# v1.10.3

- Updated for 10.0.5

# v1.10.2

- Added support for using Blizzard talent trees
- Updated to support 10.0.5

# v1.10.1-beta

- Fixed storing profession trait trees as talent trees

# v1.10.0-beta

- Added support for using built in talent tree loadouts

# v1.9.2

- Added some debug data to the minimap tooltip when holding Shift
- Fixed conditions not working correctly for multiple Vault of the Incarnates bosses
- Fixed an error when reading Blizzard equipment sets
- Fixed an issue with imported talent sets not being activatable

# v1.9.1

- Disable tracking macro changes to due to bug that was overwriting macros
- Updated action bar tab tooltips to show macro name and text

# v1.9.0

- Added an option to hide settings from showing in the loadouts menu
- Updated conditions for Dragonflight release

# v1.8.13

- Fixed an error clearing inventory slot with equipment sets

# v1.8.12

- Fixed trying to cache Dragonflight talent data while on characters that have not unlocked talents
- Fixed Shadowlands Covenants restrictions and Soulbinds trying to including Dragonflight Major Factions
- Fixed a bug with the Demon Hunter talents layout

# v1.8.11

- Updated talent data for 10.0.2

# v1.8.10

- Updated for 10.0.2

# v1.8.9

- Fixed not correctly switching to Default Loadout when activating talents on 10.0.2
- Updated Action Bars sets with the 3 new action bars
- Updated available talent points to better match the maximum level of the account

# v1.8.8

- Fixed trying to load pvp talents that are higher level than the player
- Updated talent and pvp talen data

# v1.8.7

- Fixed a bug where the Blizzard talent tree may not always update correctly after activating a talent set
- Fixed treating some spells as unknown even though they are available
- Fixed error updating equipement manager sets when an item link is unavailable

# v1.8.6

- Fixed some errors reading talent trees for some specs
- Updated dragonflight talents to select Default Loadout after talent switching
- Updated talent tree data for all specs

# v1.8.5

- Fixed error displaying conduit list
- Fixed error tracking macro changes

# v1.8.4

- Updated for Dragonflight prepatch
- Fixed title bar settings button appearing behind the title bar 

# v1.8.3

- Fixed adding equipment errors to tooltips for Dragonflight

# v1.8.2-beta

- Fixed error while loading Dragonflight talents on 9.2.7
- Fixed error adding equipment sets to tooltips

# v1.8.1-beta

- Added import/export of Dragonflight talent trees
- Updated macros for sets to support soulbinds and Dragonflight talents
- Fixed not correctly updating which loadouts are active after changing Dragonflight talents
- Fixed error on loadout change for Dragonflight Talents on 9.2

# v1.8.0-beta

- Initial support for Dragonflight Talent trees

# v1.7.11

- Removed some debug code, bad Breeni

# v1.7.10

- Updated talents and pvp talents
- Updated for latest Dragonflight Beta build

# v1.7.9

- Added support for Dragonflight tabs
- Fixed displaying Adventurer class in Dragonflight

# v1.7.8

- Fixed error setting title text on Dragonflight Beta 

# v1.7.7

- Initial changes for Dragonflight

# v1.7.6

- Updated for 9.2.7

# v1.7.5

- Updated world conditions to support Oribos and Exile's Reach for zone

# v1.7.4-beta

- Fixed an issue where a Forge of Bonds would sometimes be requested even though conduits

# v1.7.3-beta

- Fixed an error while displaying soulbind conduit list under some circumstances

# v1.7.2-beta

- Fixed an error while activating a soulbind set that is already active

# v1.7.1-beta

- Added support for switching conduits

# v1.7.0-beta

- Updated how activating loadouts decides when to wait or offer partial continuation

# v1.6.6

- Added an settings option to disabled Soulbinds
- Updated Essence support to be disabled by default, can be enabled from the settings menu in the main window
- Fixed issues with some settings options causing errors

# v1.6.5

- Updated interface number for 9.2.5

# v1.6.4

- Updated so soulbinds are changed at the Forge of Bonds within Zereth Mortis without a tome
- Fixed zone conditions not sometimes displaying when moving between zones

# v1.6.3-beta

- Updated with bug fixes from stable branch

# v1.6.2-beta

- Fixed showing condition dropdown when all conditions are active
- Fixed an error with zone condition checking

# v1.6.1-beta

- Fixed zone condition checking not always matching correctly

# v1.6.0-beta

- Added an optional zone match for world conditions

# v1.5.7

- Fixed Unity not working correctly in all slots

# v1.5.6

- Fixed Unity legendary not being equipped correctly

# v1.5.5

- Updated equipment to allow for covenant and race restrictions
- Updated conditions to support Lords of Dread and Rygelon

# v1.5.4

- Updated interface number for 9.2

# v1.5.3

- Updated for Eternity's End
- Fixed an error caused by the loadout character dropdown
- Fixed an error where the introduction display is not hidden when switching to the import tab
- Fixed import tooltip background being coloured incorrectly

# v1.5.2

- Fixed incorrect talent and pvp talent information

# v1.5.1

- Updated interface for 9.1.5
- Fixed error when updating restrictions

# v1.5.0

- Added option to sort classes by name

# v1.4.0

- Added Import/Export for loadouts, talents, pvp talents, essences, soulbinds, and action bars.

# v1.3.1

- Fixed an issue that was causing duplicate sets from the Blizzard Equipment Manager, duplicated sets should be removed

# v1.3.0

- Fixed a bug where some disabled conditions would be checked for activation
- Added new api method BtWLoadouts.ActivateLoadout(id)

# v1.2.5

- Fixed an issue where some unique items would not be swapped correctly
- Fixed issue where slots from Blizzard Equipment Manager would not always be emptied correctly

# v1.2.4

- Fixed a bug where the Activate button would be disabled on the Loadouts tab after viewing the Conditions tab

# v1.2.3

- Fixed issue with removing domination sockets not being tracked correctly

# v1.2.2

- Fixed an issue where exact item locations could be lost for non-blizzard equipment sets

# v1.2.1

- Fixed boss checking not always matching correctly
- Fixed classes in the sidebar not being sorted correctly or colour coded
- Fixed an issue where node lines would sometimes not be cleared correctly
- Added scrollable soulbinds to handle increased size
- Added Tazavesh dungeon condition
- Added Sanctum of Domination raid conditions

# v1.1.2

- Added support for setting specific battlegrounds in conditions

# v1.0.0

- Fixed an issue where empty equipment slots would not be displayed correctly

# v89.1-beta

- Renamed Profiles to Loadouts
- Fixed an issue with parsing item links, comparing items should be more accurate now
- Added new user UI for each tab

# v88.4

- Fixed dragging items into equipment sets not working in some situations

# v88.3

- Fixed an issue where enabling the option to prevent offering conditions for different specializations would prevent offering conditions with no specialization
- Fixed issue with race restrictions

# v87.1

- Added the option to disable essences

# v86.1

- Added settings button to main UI.
- Added delete character menu to the main UI settings button.
- Fixed not being able to clear the selected essence when clicking the background
- Fixed an issue where the specialization dropdown list for loadouts would sometimes be the incorrect width

# v85.3

- Fixed an issue where the minimap icon would sometimes not display correctly when using ElvUI Enhanced Again
- Updated localizations

# v85.2

- Added the option to partially activate loadouts, skipping anything that would require a tome
- Added an option to prevent offering conditions for different specializations
- Fixed an issue where condition drop down would sometimes not be visible
- Fixed trying to change specializations for characters below level 10
- Fixed requesting a tome for talent rows without an already selected talent

# v84.10

- Updated for Shadowlands 9.0.5

# v84.9

- Updated translations
- Fixed a tooltip error on German clients
- Fixed an issue where macros in action bar sets would sometimes not update when macros were edited

# v84.8

- Updated talent changing to no longer require a tome when no talent was previously selected
- Fixed showing location information on tooltips
- Fixed an issue with Tooltips not updating correctly to show Equipment Sets
- Fixed asking for a tome for talent rows that are not unlocked yet

# v84.7

- Fixed an issue where changes to equipment items would sometimes not be saved correctly

# v84.6

- Updated equipment set handling to track item changes like gems and enchants.
- Updated equipment set tab to show missing items.

# v83.14

- Fixed Conditions not triggering correctly for Sire Denathrius

# v83.13

- Fixed a possible cause of UI taint

# v83.12

- Fixed an error with macro tracking when macros are edited or added

# v83.11

- Removed debug code

# v83.10

- Updated some error messages for changing action bar actions
- Fixed an issue where macros would not track changes correctly when there were empty lines at the end
- Fixed a error where equipment set information wasn't available during first player login

# v83.9

- Fixed an issue caused by corrupted equipment sets, anything left over from the corrupted sets should be gone now

# v83.8

- Fixed an error caused by some corrupted and unusable equipment sets, this may result in missing sets that were corrupted. Sorry for the inconvenience.

# v83.7

- Fixed a error with equipment set handling

# v83.6

- Fixed an issue where switching sets would sometimes not work after changing zones

# v83.5

- Fixed asking for a tome while in the talent change aura in Torghast
- Fixed asking for a tome while changing talents with the Kyrian Steward

# v83.4

- Fixed essences being taken into account when check if a loadout is active while not using the Heart of Azeroth
- Fixed waiting for a tome unnecessarily when an essence set is in a loadout but the Heart of Azeroth wont be active
- Fixed an error with soulbind handling
- Fixed an error with the soulbinds tab when deleting the last set

# v83.3

- Added soulbinds tab to allow changing soulbind tree path
- Override affix rotation for SL until known

# v83.2

- Fixed issue causing a gap in ElvUI Enhanced minimap buttons

# v83.1

- Fixed missing pvp talent for Affliction Warlocks
- Fixed conditions not reacting correctly to some bosses
- Fixed tome request not checking level requirements for tomes
- Fixed errors when activating an action bar set that attempts to create macros while full
- Fixed a bug where activating an equipment set that had 2 of the same item when only 1 was available would cause constant swapping of the item
- Fixed showing shadowlands data to early

# v83

- Fixed a bug where equipping only essences would fail

# v82

- Fixed saved variables not being set up correctly for new users
- Fixed an error with hovering over essence slot

# v81

- Fixed a bug where equipment sets would not switch correctly

# v80

- Fixed some issues with updating talent sets and pvp talent sets for 9.0 release

# v79

- Added support for Shadowlands, including Soulbinds.
- Fixed loadouts being stuck not swapping in some situations
- Fixed action bar macros getting corrupted when a new macro is created by an addon while the macro ui is open
- Fixed an error while viewing the pvp talents tab with no available sets

# v78

- Updated instance data

# v77

- Updated the action bar ui so ignored items are less visible and don't show errors
- Updated instance lists to support Shadowlands
- Fixed an issue where the macro ui would not be updated when creating macros
- Fixed newly created sets not displaying on the sidebar when Current Character filtering is enabled

# v76

- Added option to create macros from action bar screen
- Added support automatic covenant ability updating for action bars
- Updated talent switching to block new spells from flying onto the bars
- Updated how pvp talents are handled ready for Shadowlands
- Updated talent and pvp talent cache
- Fixed LDB-Icon not working correctly
- Fixed an issue with some LDB displays where the tooltip backdrop was sized incorrectly

# v75

- Updated equipment set drop down menu to show a * for built in equipment sets
- Fixed the equipment set sidebar to correctly show the wow icon for sets from the built in manager

# v74

- Fixed an issue where equipment sets would get disconnected from the built in manager 
- Fixed an issue where the minimap icon would reappear after relogging

# v73

- Fixed an intermittent error during character login
- Fixed a bug where tabs were not switching when add a new set
- Fixed a bug with empty macros in action slots

# v72

- Updated sorting for sidebar to better handle numbers

# v71

- Fixed a error while deleting Loadouts with Essences sets

# v70

- Updated translations

# v69

- Fixed an issue where Specialisation drop down menu would not show
- Fixed an error where equipment manager sets would sometimes return empty locations

# v68

- Added an option to disable talent change messages while switching loadouts
- Fixed an error with macro tracking

# v67

- Added support for combining multiple sets together within a loadout. The lower set of each type override the settings for previous sets. This has special effects on equipment sets, they no longer cause character restrictions on loadouts and it is now possible to add equipment sets from multiple characters.
- Added macro change tracking, when a macro that is on an action bar set is changed the action bar set is updated with the new macro text
- Updated the minimap icon to use LibDBIcon when available
- Updated the sidebar with new filtering, changeable categories and a search
- Updated log to better handle appending loadouts
- Updated action bar error messages
- Updated support for lower level characters
- Updated loadout activation to wait for taxi rides to end


# v66

- Updated macro handling so whitespaces at the start and end of the body are ignored

# v65

- Added error highlight for unavailable actions in the action bar tab
- Added version message to log
- Updated log messages for switching action bars

# v64

- Fixed an issue where action bars would not always switch macros correctly
- Fixed an error while switch to any set that isn't a loadout

# v63

- Updated loadout save data in preparation for larger changes later

# v62

- Fixed an error with activating equipment sets

# v61

- Added instance overrides, garrisons will now be treated like World
- Updated slash commands, can now use first letter for commands as well as shortened /btwl
- Fixed an issue when displaying conditions with no affixes

# v60

- Added the option to select specific scenarios
- Updated affix handling for conditions allowing for more precise selections

# v59

- Updated dragging set macros to now update the macros names
- Updated dragging equipment sets to no longer use the built in equipment set manager
- Updated macro support so activating a set by name will now prioritise sets for the current specialization or class
- Fixed an issue with action bars tab, double clicking sets will now activate them
- Fixed an issue where activating built in equipment sets through the slash command would sometimes fail
- Fixed a error when switching equipment sets with empty slots

# v58

- Fixed an issue where switching loadouts without the Heart of Azeroth unlocked would cause errors

# v57

- Updated sort order for conditions to prioritise current specialisation when there are multiple matches

# v56

- Fixed an issue where Azerite traits would sometimes not be taken into account when switching equipment sets (Bugged equipment sets will have to be updated with the azerite pieces again)

# v55

- Fixed an issue where the incorrect version of an item would be equipped

# v54

- Fixed an issue with the New Set option not working for condition loadouts
- Fixed an issue where deleting a loadout would break connected conditions
- Fixed an issue where the first time minimap icon glow did not hide correctly on mouseover

# v53

- Added a timeout for switch loadouts to prevent infinite loops
- Added a log to track what changes when switching loadouts
- Fixed an issue where switching action bars was not prioritising macro names over id

# v52

- Fixed an issue where spec changing would sometimes double switch spec or requesting tomes unneeded
- Fixed an error caused by deleting an equipment when the ui hasnt been visible since login
- Fixed an issue where conditions would trigger for N'Zoth encounter while doing Carapace

# v51

- Fixed an issue where switching talents on action bars would work correctly when switching to the talent as well
- Fixed an issue where Ra-den and Vexiona loadouts were being suggested early

# v50

- Added update button to refresh sets from current character
- Updated conditions to no longer give suggestions for unavailable bosses
- Fixed a bug where new equipment manager sets would sometimes cause an error while being equipped

# v49

- Fixed an issue where boss suggestions were not being offered correctly

# v48

- Fixed a bug sometimes prevented switching spells and flyouts on action bars

# v47

- Updated action bar handling to support macro text changing
- Fixed an issue where switching action bars would not fail when the spell is unavailable
- Fixed an issue where there tooltip was incorrectly saying it was waiting to change specialization
- Fixed an issue where sets for dead bosses was being suggested

# v46

- Added setting to allow limiting condition suggestions, while active condition suggestions will only be offered if you are not wearing any of your best match loadouts
- Updated equipment management, sets are now deleted when removed from the builtin equipment manager unless in use by a loadout
- Fixed an issue where double clicking a header in the sidebar would attempt to activate a set that didnt exist

# v45

- Added loadout disabling, disabled loadouts will not display in the minimap menu or on the LDB data source, does not effect Conditions
- Updated loadout changing to wait for player to stop moving
- Updated slash command to support action bar switching
- Fixed conditions offering to swap to or from healer inside a battleground

# v44

- Added progress display on the minimap button, tooltip also shows any delays
- Fixed an issue where tomes were being requests unnecessarily

# v43

- Fixed an issue where equipment error text was showing incorrectly

# v42

- Added item error overlay for invalid equipment
- Updated minimap menu to separate loadouts by specialization

# v41

- Fixed a never ending loop caused by trying to equip unique equipped gems

# v40

- Updated to display currently selected loadouts in some LDB enabled addons

# v39

- Fixed a bug where invalid loadouts were suggested in arena

# v38

- Fixed an error while displaying conditions

# v37

- Fixed an issue where incorrect loadouts were being offered when entering an instance

# v36

- Fixed an issue with activating loadouts by name

# v35

- Added new essence slot
- Added Ny'alotha boss conditions
- Added Scenario condition
- Updated Affixes with Awakened
- Updated how seasonal affixes are handled, conditions with previous seasons affixes will trigger for new seasonal affix
- Updated localizations

# v34

- Fixed an issue with essence slots on action bars being replaced over and over
- Fixed an issue where loadout suggestions were being made in Mythic Plus

# v33

- Fixed being unable to delete conditions

# v32

- Added the ability to keybind showing and hiding the main ui
- Added the ability to disable Conditions
- Updated the width of the sidebar list
- Updated translations
- Fixed suggesting loadouts for different specialization than the active in arena
- Fixed an issue where profiles with no specialization set would cause an error when displaying some profile lists
- Fixed an issue where conditions would sometimes not trigger for previously invalid loadouts

# v31

- Added Action Bar support

# v30

- Fixed an issue where changing equipment would sometimes not change every part of a set

# v29

- Fixed an issue where unequipping multiple items would fail
- Fixed an issue where equipping an item into an empty slot would cause an error and fail
- Fixed an issue where the Talent Set menu for profiles would show None selected incorrectly
- Fixed an issue where the sidebar would sometimes display a profile under an incorrect header
- Fixed an issue where Conditions would not react to the players target

# v28

- Added some functions for other addons to get basic Loadout data
- Fixed an issue the set name for newly create sets would sometimes keep the name of the previously selected set

# v27

- Fixed an issue where some items would not appear on the end of the side scroll area
- Fixed an issue where the name would not change when viewing sets
- Fixed an issue where switching away from Restoration Druid would prevent talent and essence swapping
- Fixed an issue where error messages would sometimes be displayed incorrectly

# v26

- Fixed an issue with duplicate equipment sets from the built in manager

# v25

- Fixed login errors effecting conditions and equipment sets

# v24

- Fixed an issue where profiles with equipment sets would be considered invalid for character on some realms

# v23

- Fixed an issue sometimes preventing profiles from displaying correctly

# v22

- Fixed issues with Conflict and Strife preventing learning related PvP talents
- Fixed error message spam

# v21

- Fixed an issue where a tome would be requested unnecessarily
- Updated LDB Launcher to display active profile

# v20

- Fixed the Yes button for the tome require dialog not reacting to mouse events

# v19

- Fixed Tome of the Quiet Mind not being used and added support for Tome of the Clear Mind

# v18

- Added support for OPie
- Updated minimap and LibDataBroker menu to allows changing profiles
- Updated the minimap button to better handle minimap addons

# v17

- Fixed an issue causing an error with CompactRaidFrame

# v16

- Updated item handling, Timewalking items should no longer cause an error

# v15

- Added missing Mythic Keystone Affix combination

# v14

- Updated for patch 8.2.5
- Added LibDatabroker support

# v13

- Added missing affix combination
- Fixed an error when logging onto lower level characters

# v12

- Updated affixes list with new possible affix combinations
- Updated sidebar to remember which headers are open/closed between sessions
- Updated Chinese translations

# v11

- Fixed an issue with typing in Chinese names

# v10

- Fixed an issue with the essence tab when clicking an essence while no set was selected
- Updated Chinese Traditional translations, thanks to BNS

# v9

- Fixed a bug with conditions not show the boss and affix lists correctly
- Added Traditional Chinese translations, thanks to BNS

# v8

- Fixed a bug with minimap position, this may cause your minimap icon to be in the wrong position next load.
- Updated the default minimap position to just below the tracking icon.
- Added a glow to the minimap icon on first launch to help new users find it.

# v7

- Fixed an issue where conditions weren't activating correctly

# v6

- Update equipment sets to track azerite traits
- Added double clicking sets within the sidebar to activate them
- Added slash command for activating sets
- Added dragging sets to the bar

# v5

- Updated equipment handling to match items on more than just id

# v4

- Fixed essence swapping sometimes not switching when changing specialization
- Fixed profiles dropdown not showing the correctly selected item
- Fixed condition name not updating in the dropdown

# v3

- Fixed an issue where character data wasn't available
- Fixed an issue with equipment swapping where it would give up half way through
- Added boss and affix conditions (still needs more work)

# v2

- Fixed Other categorised profiles causing issues with Conditions
- Fixed an issue with conditions tab not being enabled/disabled properly