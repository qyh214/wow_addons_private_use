local GlobalAddonName, ExRT = ...

ExRT.Options.Changelog = [=[
v.5150
* Reminder: added timelines for Liberation of Undermine mythic bosses
* Raid check: added custom ilvl column
* Raid check: added sort by name

v.5140
* Note: added autoload support for Liberation of Undermine
* Reminder: updated timelines for Liberation of Undermine HC bosses

v.5120
* 11.1 update
* Raid groups: added "split raid" option
* Note: added "text align" option
* Reminder: added option to send timeline history after boss fight 

v.5100
* Reminder: you can directly select only boss from recorded m+ run 
* Reminder: added players from custom roster to advanced settings window if it opened via shift-click on assignments page with "custom roster" selected
* Raid Cooldowns: added custom icon option for spells that was added by users
* Loot History: added icon for roll type (need/greed/transmog/pass)
* Added profiling
* Fixes

v.5080
* Reminder: changed load conditions logic for reminders with both boss+zone load
* Reminder: "assignments"/"timeline": added dungeon bosses to list
* Raid groups: server name in not required
* Raid Inspect: added option to set custom minimum ilvl for highlight
* Interrupts: added option to autoreset based on maximum assigned number for each mark (be sure that your assigned kickers have v5080+ before using this option)
* Note: added custom roster
* Note: added role icons for tanks and healers for list with names
* Fixes

v.5060
* Reminder: "assignments": added "live session" option (multiple people can add/remove/change reminders at same time with immediate progress visualisation)
* Reminder: "assignments": added option for filtering existed reminders with same filter as enabled spell groups (enabled by default)
* Reminder: "assignments": added charges support (right click on spell from right menu to setup number of chargers for spell)
* Reminder: "assignments": added option to add custom spells to class list
* Reminder: overhauled load conditions for names/class/roles/note pattern (now all need to met (if any) instead of any)
* Reminder: rework for sharing method. Now shared profile and selected personal profile can be active together. Current reminders from shared profile moved to profile#6
* Reminder: added option for custom icon size in text
* Reminder: added option for custom text size on raidframe/nameplate
* WeakAuras checks: quickshare button will send selected wa to players with no wa/different version of wa
* Fixes

v.5040
* Reminder: added "assignments" page for quick raid cooldowns organization for your roster
* Reminder: queen ansurek p3 start was moved (only for timeline, reminders are unaffected)
* WeakAuras checks: now able to check if aura is same
* Note: added option for using autoload for personal note
* Fixes

v.5020
* Reminder: added "sound delay" option
* Raid groups: added option "Keep changes" for autosave any editing for selected preset
* Fixes

v.5005
* Raid Inspect: added "cheap" option for minimum rank for gems/enchants
* Major fixes

v.5000
* Raid Inspect: added option for minimum rank for gems/enchants
* Fixes

v.4990
* Reminder: added option to grow upwards
* Raid Check: add option for using only unlimited rune (old one for now)
* Raid Check: add option for using custom oil itemid
* Fixes

v.4990-Cata
* Reminder: added option to grow upwards
* Fixes

v.4980
* Reminder: timeline updates
* Reminder: added m+ support
* Note: added option to autoload note before boss
* Fixes

v.4980-Cata
* Note: added option to autoload note before boss
* Reminder: added "boss timeline" feature with simplified setup and quick exchange to/from notes 
* Raid Cooldowns: added option to grow by columns
* Raid Cooldowns: added option for animation style "Starts Full for active and empty for cd"
* Fixes

v.4960
* Reminder: added option to show message before timer ends instead of after. This option is enabled by default for new reminders from "boss timeline"
* Reminder: updates
* Raid Cooldowns: added option to grow by columns

v.4950
* Reminder: added "boss timeline" feature with simplified setup and quick exchange to/from notes 
* Raid Cooldowns: added option for animation style "Starts Full for active and empty for cd"

v.4930
* Reminder: added triggers test tab
* Saving log: fixed Grim Batol logging
* Raid Check: added support for more weapon buffs
* Fixes

v.4920
* Raid Check: TWW updates

v.4910
* Fixes

v.4900
* Raid cooldowns: added "column for raid/party role" option
* Fixes

v.4900-Cata
* Raid cooldowns: added "column for raid/party role" option

v.4890
* TWW updates

v.4880
* Fixes for 11.0 beta
* Added Italian translation (by Grifo92)
* Reminder: added load condition: always
* Minor fixes

v.4870
* Note: added profiles
* Reminder: all bosses are grouped in instance folders
* Minor fixes

v.4870-Cata
* Note: added profiles
* Minor fixes

v.4870-Classic
* Note: added profiles
* Minor fixes

v.4860
* toc update
* Raid cooldowns: added "Add spell" for class categories
* Raid Groups: added role icons

v.4860-Cata
* fixes
* Raid Groups: added role icons

v.4850
* Minor fixes

v.4850-Cata
* Cataclysm update
* Raid cooldowns: added new spells
* Marks Bar: added world marks
* Note: added support for spec role
* Inspect viewer: added specs

v.4850-Classic
* Minor fixes
* toc update

v.4840
* New module: Reminder
* Minor fixes

v.4840-LK
* New module: Reminder
* Minor fixes

v.4840-Classic
* New module: Reminder
* Minor fixes

v.4825
* Fixes

v.4825-LK
* Fixes

v.4825-Classic
* Fixes

v.4820
* New module: Interrupts
* New module: Automarking
* Raid cooldowns: added separate dispel spell for evoker healer
* Raid Check: added DF rune
* Fixes

v.4820-LK
* New module: Interrupts
* New module: Automarking
* toc update

v.4820-Classic
* New module: Interrupts
* New module: Automarking
* Saving log: added SoD raids
* toc update

v.4810
* Minor fixes

v.4800
* 10.2 update
* Note: added option "Personal note in separate window"
* Note: added ability to show any draft in separate window (as many as you want), until reload

v.4785
* Raid cooldowns: added option for key mod for clicks (whispers)
* Major fixes

v.4785-LK
* Raid cooldowns: added option for key mod for clicks (whispers)
* Major fixes

v.4781
* Fixes

v.4780
* Marks Bar: added ping buttons
* Raid cooldowns: added option for spell target
* Fixes

v.4780-LK
* Visual Note: Added ICC room maps

v.4770
* Fixed /rt pull timer for DBM
* Raid cooldowns: added autoswap profiles for specs

v.4770-LK
* Minor fixes

v.4770-Classic
* Fixes

v.4760
* 10.1.5 Update
* Minor updates
* Marks: added support for multiple names

v.4760-LK
* toc update

v.4740
* 10.1 Update

v.4720
* Added temporary fix for sending long notes (beware: sending takes some time)
* Loot History: added support for group loot
* Fixes

v.4720-LK
* Visual Note: added ulduar visual maps
* Fixes

v.4710
* 10.0.2 Update
* Fixes

v.4700
* Raid cooldowns: updated all classes for DF
* Marks Bar: fixed world markers buttons
* Fixes

v.4690
* Raid Check: added vers & movement buffs
* Raid cooldowns: updated paladin and priest spells for DF
* Major fixes

v.4680
* Updated for 10.0 Dragonflight

v.4660
* Updated for 10.0 Dragonflight beta
* Updated 9.2.7 toc
* Raid cooldowns: added option to growth from left to right
* Raid Check: added option to disable chat report outside raids
* Invite Tools: Fixed invite opposite faction via bnet
* WeakAuras checks: fixed disconnect on requesting for people with huge number of weakauras [outdated MRT versions not supported]
* WeakAuras checks: click on name will request info only for single line
* Saving log: added all mop+wod+legion 5ppl for <5ppl mythic> logging

v.4660-LK
* Inspect/Raid cooldowns: Added support for talents
* Raid cooldowns: added option to growth from left to right
* Raid Check: added chat report options

v.4650-LK
* Updated to WotLK version
* Marks Bar: second click on consumables button will hide consumables window

v.4630
* Raid Check: consumables on ready check: added support for Eternal Augment Rune
* Minor fixes

v.4620
* 9.2 Update

v.4610
* Updated Chinese translation (by martinkerth)

v.4610-BC
* Raid cooldowns: Fixed and added feign death cd
* Raid cooldowns: added power infusion, ice block, evasion cds
* Marks Bar: Removed world marks from marks bar [Not available in tbc]
* Invite Tools: Fixed auto loot method

v.4610-Classic
* Fixed maximum raid groups for ready checks
* Removed world marks from marks bar [Not available in classic]
* Invite Tools: Fixed auto loot method

v.4600
* 9.1.5 update

v.4600-BC
* Minor fixes

v.4600-Classic
* Minor fixes

v.4580
* Note: added option "Hide lines with timers but without my name". You can bypass this option with "all" or "glowall" keywords, ex.: {time:1:20,all}
* Raid Check: added font settings for raid overview window
* Raid Check: removed food gained by couduit power from raid overview check 
* Raid Check: consumables on ready check: added enhancement shamans weapon enchants
* Raid cooldowns: added support for 9.1 trinkets
* Raid cooldowns: added Masque support
* Raid Inspect: added SoD achievements
* Minor fixes

v.4580-BC
* toc update
* Invite tools: added options for loot method
* Raid Check: added font settings for raid overview window
* Note: added some icons to list for raids from current phase
* Minor fixes

v.4560
* Raid cooldowns: Added support for new covenant legendaries
* Minor fixes

v.4560-BC
* Raid Attendance: fixed BC raids to log attendance
* Saving log: added options for arena/5ppl hc/5ppl normal
* Bugfixes

v.4550
* Addon renamed from "Exorsus Raid Tools" to "Method Raid Tools". Be sure that addon "Method Raid Tools [Storage]" is enabled to keep all your saved options/data.
* 9.1 Update
* Note: slightly changed phase/stage condition to match with DBM/BW functionality (will be fine with 9.1 bosses, 9.0 bosses requires actual update for DBM/BW)
* Note: fixed {p1} condition
* Note: added autocoloring for raid/group player names
* Raid cooldowns: Strata can be changed manually for attached columns (autostrata is set by default)
* Bugfixes

v.4550-BC
* Added tbc support

v.4550-Classic
* Bugfixes

v.4520
* Raid cooldowns: Added profiles options
* Raid cooldowns: Added option "Autochange profile in zones"
* Raid cooldowns: Added option "Priority frames" for attached icons
* Raid cooldowns: Fixed "Feign death" cooldown
* Raid cooldowns: Fixed "Phial of Serenity" (kyrian pot), now it must be on cooldown until combat ends
* Raid cooldowns: Added "Healthstone" and "Healing potion" cooldowns
* Raid cooldowns: Added option "Show only without cd"
* Raid Check: consumables on ready check: added button for offhand enchant
* Raid Check: consumables on ready check: clicking on weapon enchant with low time remaining now cancel enchant (i.e. double click for re-enchant) (only for shadowcore/embalmer oil and one-handed weapons with shield/offhand)
* Note: fixed numeric phase condition
* Invite tools: added option to invite by any message (via "ANYKEYWORD" keyword)
* Minor fixes

v.4520-Classic
* Raid Groups: added option "Keep positions in groups"
* Raid Groups: added chat command "/rt raidgroup GROUPNAME"
* Invite tools: added option to invite by any message (via "ANYKEYWORD" keyword)
* Added "/rt help" command for list all chat commands
* Minor fixes

v.4500
* Raid cooldowns: Added options for custom (customizable) cooldown text on icons
* Raid cooldowns: Added option "Ignore active time for texts"
* Raid cooldowns: Added option "Column strata"
* Raid cooldowns: Added option "Unavailable only via timer"
* Raid Check: added option for soulstone buff for raid overview window
* Note: WA firing events are unique by line data now instead only by name (this will be possible now: {time:1:30,wa:defCD} Def CD {time:3:00,wa:defCD} Def CD)
* Added "/rt help" command for list all chat commands
* Bugfixes

v.4490
* Raid Check: fixed Sharpened & Weighted weapon buffs
* Raid Check: added option "Use flask only from cauldron"
* Raid cooldowns: fixed frame strata for icons that attaches to raidframes
* Note: added support for glow syntax (ex. {time:1:30,glow} - shows non-disabled glow if players name is in line and timer is less than 5 seconds, {time:1:30,glowall} - shows non-disabled glow for all players if timer is less than 5 seconds)
* Bugfixes

v.4480
* 9.0.5 update
* Note: added support for multiple WA events per line with timer (ex. {time:1:30,SCC:17:2,wa:eventName1,wa:eventName2})
* Note: added support for phases with name (ex. {time:1:30,p:Shade of Kael'thas})
* Note: added support for custom phases (ex. {p,SCC:17:2}Until end of the fight{/p} or {p,SCC:17:2,SCC:17:3}Until second condition{/p})
* Note: added option "Completely hide lines with passed timers"
* Note: added option "Glowing note with own timer less than 5 seconds"
* Raid cooldowns: fixed frame strata for icons that attaches to raidframes
* Raid Check: added option for chat report for missing armor kits and weapon temporary enchants (players without an addon will be marked as "no addon", but included to missing list)
* Minor fixes

v.4460
* Raid check: consumables on ready check: flask icon is clickable now
* Note: added "Set as personal note" button
* Bugfixes
* Minor updates

v.4460-Classic
* Note: added "Set as personal note" button
* Raid Groups: now does not keep exact position in groups to reduce swap events
* Bugfixes
* Minor updates

v.4440
* Note: increased performance for huge notes with timers
* Visual Note: added pvp battlegrounds
* Raid Groups: added import from spreadsheet string
* Saving log: added option for autologging torghast
* Minor fixes

v.4440-Classic
* Raid Groups: added import from spreadsheet string
* Note: added {classunique:mage,priest}message{/classunique} syntax
* Marks bar: fixed locked/unlocked option
* Raid check: Blessed Sunfruit and Blessed Sunfruit Juice buffs
* Minor fixes

v.4420
* Raid Inspect: fixed query stuck
* Raid check: consumables on ready check are clickable now
* Raid check: consumables on ready check: fix for elvui users
* Raid cooldowns: fixed typhoon
* Note: added {classunique:monk,priest}message{/classunique} syntax
* Minor fixes

v.4400
* Raid check: added new food consumables
* Raid check: added ap weapon buffs to ready check window
* Raid check: readded runes to ready check window
* Raid check: added personal icons for consumable buffs on ready check
* Raid cooldowns: fixed mw & ww monk talents
* Raid cooldowns: fixed dh silence cd timer
* Raid cooldowns: added kick category for demonology warlock kick
* Marks bar: fixed locked/unlocked option
* Raid inspect: fixed highlight for dk weapon enchants
* Loot History: now records only epic quality items

v.4390
* Raid cooldowns: added avenger's shield reset support
* Raid cooldowns: added "only visual" option for import
* Raid cooldowns: added pvp talents support
* Raid cooldowns: options "Sort By Availability" and "Reverse Sorting" now can be different for each column
* Visual Note: added "custom image" object
* Visual Note: added new type of lines
* Visual Note: added option to lock/unlock objects for moving/removing
* Raid Groups: added import/export current roster buttons
* Added global names for major frames (note, cooldowns columns, battle res, marks bar)
* Updated localizations
* Minor fixes

v.4390-Classic
* Raid cooldowns: added "only visual" option for import
* Raid cooldowns: options "Sort By Availability" and "Reverse Sorting" now can be different for each column
* Visual Note: added "custom image" object
* Visual Note: added new type of lines
* Visual Note: added option to lock/unlock objects for moving/removing
* Raid Groups: added import/export current roster buttons
* Added global names for major frames (note, cooldowns columns, battle res, marks bar)
* Updated localizations
* Minor fixes

v.4370-Classic
* Fixed consumables check for raid check windows
* Minor fixes

v.4360
* Added import/export profiles
* Visual Note: popup window now saves its state (size and position)
* Raid Groups: added option for quick-list with guild roster
* Raid cooldowns: Added import/export profiles just for cooldowns module
* Raid cooldowns: Fixed cooldowns/durations for some spells during prepatch
* Raid cooldowns: Fixed vision of perfection cdr
* Raid cooldowns: Readded option to set column for general class abilities
* Raid cooldowns: [options] Spells now sorted by spec for class categories
* Raid cooldowns: Added glow options for icons with active cooldowns
* Invite tools: fixed massinvite feature
* Updated Traditional Chinese translation
* Updated Chinese translation
* Minor fixes
* Bugfixes

v.4360-Classic
* Added import/export profiles
* Visual Note: popup window now saves its state (size and position)
* Raid Groups: added option for quick-list with guild roster
* Raid cooldowns: Added import/export profiles just for cooldowns module
* Raid cooldowns: Added glow options for icons with active cooldowns
* Invite tools: fixed massinvite feature
* Fixed error on autoaccept invite
* Updated Traditional Chinese translation
* Updated Chinese translation
* Minor fixes
* Bugfixes

v.4330
* Shadowlands update
* Options: now can be closed on esc, also added option to disable this
* Raid cooldowns: added attach to raidframe option [beta]
* Raid cooldowns: added favorites button/category for options
* Raid cooldowns: added sort by column for options
* Raid cooldowns: added options for custom items/equip
* Marks Bar: added option "Show only on hover"
* Note: added "{!p:playerName}...{/p}" template (for all except "playerName")
* Note: added "{!c:class}...{/c}" template (for all except "class")
* Note: added "{race:raceName}...{/race}" template (only for race "raceName")
* Battle Res: added option to change frame strata
* Fight log: added timeline for players casts
* Fight log: added raid frames page
* Bonus Loot: module is removed
* Updated Traditional Chinese translation
* Minor fixes
* Bugfixes

v.4330-Classic
* Options UI updates
* Options: now can be closed on esc, also added option to disable this
* New module: Raid Groups
* Raid cooldowns: updated options UI, now more user friendly
* Raid cooldowns: added "/rt cd" command for quick enable/disable
* Raid cooldowns: added favorites button/category for options
* Invite tools: added option to invite via "/say" or "/yell"
* Visual Note: added option to disable updates for specific note
* Visual Note: added more backgrounds with solid color
* Timers: added scale/alpha options
* Marks Bar: added option "Show only on hover"
* Note: added option to change note position in list via drag&drop
* Note: added "/rt note set notename" command for quick update
* Note: added "{!p:playerName}...{/p}" template (for all except "playerName")
* Note: added "{!c:class}...{/c}" template (for all except "class")
* Note: added "{race:raceName}...{/race}" template (only for race "raceName")
* Battle Res: added option to change frame strata
* Raid Inspect: added ranged slot
* Updated german translation
* Updated Traditional Chinese translation
* Minor fixes
* Bugfixes

v.4300
* Options UI updates
* New module: Loot History
* New module: Raid Groups
* Many shadowlands updates
* Raid cooldowns: updated options UI, now more user friendly
* Raid cooldowns: added "/rt cd" command for quick enable/disable
* Invite tools: added option to invite via "/say" or "/yell"
* Visual Note: added option to disable updates for specific note
* Visual Note: added more backgrounds with solid color
* Timers: added option for default game timer (note: this timer is inaccurate now)
* Timers: added scale/alpha options
* Note: added "{p2}...{/p}" template for specific boss phase
* Note: added option to change note position in list via drag&drop
* Note: fixed fps lag for truncated note with a lot timers
* Note: added dbm support for timers with phase
* Note: added help for some timer constructions
* Note: added "/rt note set notename" command for quick update
* Bonus Loot: module is planned to be removed in future updates, export data if you need to save it
* Updated german translation
* Minor fixes

v.4180
* Update for possibility use addon on beta client (9.0)

v.4170
* Raid cooldowns: Added Ineffable Truth support
* Raid check: added option to sort by class

v.4160
* Raid Inspect: added nzoth curve achievement
* Saving log: fixed motherlode instance
* Bugfixes

v.4160-Classic
* Bugfixes

v.4150
* Raid Inspect: added current corruption level
* Note: fixed raid markers for duplicating in chat option
* Saving log: removed Legion raids and dungeons
* Minor fixes

v.4150-Classic
* Visual Note: added maps for AQ20, AQ40, Naxx (by Wollie)
* Note: fixed raid markers for duplicating in chat option

v.4145-Classic
* Visual Note: added maps for BWL (by Wollie81), MC, ZG

v.4140
* Note: added format restrictions for players class {c:Paladin}Press bubble{/c}
* Note: added 8th group for quick name select
* Raid check: added Lightning Forged Augment rune for tracking
* Minor fixes

v.4140-Classic
* Note: added format restrictions for players class {c:Paladin}Press bubble{/c}
* Note: added 8th group for quick name select
* Minor fixes

v.4130
* Note: fixed colorizing highlighted text
* Battle Res: fixed visualization for max combat res stacks (5 for M+)
* Raid cooldowns: fixed cd reset during skitra encounter
* Raid cooldowns: fixed disappearing cooldowns for druids 
* Raid Inspect: fixed corruption counting (still showing character's max corruption number without corruption resistance)
* Minor fixes

v.4120
* 8.3 Update
* Marks Bar: added option for different pull timers for left and right clicks
* Note: clicking on the raid names with highlighted text now successfully remove highlighted part from note
* Raid check: minimized/non-minimized state now can be saved
* Minor fixes

v.4110
* Invite tools: fixed bug with massinvite/invites by list
* Raid check: added closing on right click
* Raid check: added minimize button

v.4110-Classic
* Invite tools: fixed bug with massinvite/invites by list
* Raid check: more icon slots for flasks
* Raid check: added closing on right click
* Raid check: added minimize button
* Minor fixes

v.4101
* Bugfixes

v.4100
* Raid Check: added durability check (only for players with an addon)
* Raid Check: added notification on icon for food/flasks with expiration time lower than 10 mins
* Raid Inspect: list now sorted by class
* Raid cooldowns: fix bug with fonts on first load
* Invite tools: added invites by list
* Added ingame changelog
* Minor fixes

v.4100-Classic
* Raid Check: added durability check (only for players with an addon)
* Invite tools: added invites by list
* Bugfixes

v.4080
* Raid Check: reworked ready check frame
* Raid Check: added option for ready check frame only for raid leaders
* Raid Check: ready check frame option switched to enabled for raid leaders
* Marks Bar: added raid check button
* Minor fixes

v.4080-Classic
* Raid Check: Readded module
* Marks Bar: added raid check button
* Minor fixes

v.4060
* 8.2.5 toc update

v.4060-Classic
* Minor fixes

v.4055-Classic
* Readded Loot link module
* Fixed mass invite
* Fixed "Out of range" error for inspect module

v.4050-Classic
* More classic fixes/updates

v.4040
* Raid Cooldowns: Fixed Vision of perfection essence
* Timers: Added new skin
* Fight log: fixed The Queen's Court encounter healing
* Invite tools: guild ranks for mass invite can be selected manually
* Classic: fixed bug with game talents tab
* Raid Inspect: added new ench/gems
* WeakAuras checks: added filter
* Minor fixes

v.4030
* 8.2.0 Update
* Raid check: added support for new food/flasks
* Raid Cooldowns: Added essences
* Raid Inspect: Added essences
* Can be launched on classic (1.12.1/1.13) client

v.4010
* toc update
* Removed combat restrictions for loading for some modules

v.4000
* 8.1 Update
* Note: added ability to move notes position in list
* Note: added "{time:2:45}" template for dynamic timer
* Visual note: added movement tool
* Fight log: short boss pulls are not recorded

v.3990
* Note: copy-pasting with colors must be much easier
* Note: added button "Duplicate"
* Note: added 5ppl dungeons to bosses list
* Note: added highlighting drafts for nearest bosses
* Note: added {icon:PATH} format for any ingame icon (older format for spells still works ({spell:SPELL_ID}))
* Visual note: fixes
* Visual note: outdated versions no longer supports
* Raid Inspect: added bfa achievements (BFA 5ppl, Uldir)
* Raid Inspect: fixed weapon enchants for dk & hunters

v.3975
* Fixes for note editing

v.3970
* New module: Visual note [test mode]
* Note: parts of note can be shown only for specific role. Use {D}...{/D},{H}...{/H},{T}...{/T} format
* Note: parts of note can be shown only for specific players. Use {p:PlayerName,OtherPlayerName}...{/p} format
* Note: autoload removed
* Note: added option for text colors in edit mode
* Raid Inspect: You can check all alternate azerite choices in tier if you hover azerite icon
* Fight log: fixed calculations for players in mind control
* Removed outdated modules
* Minor fixes

v.3950
* Raid Inspect: ilvl fix
* Minor fixes

v.3940
* Raid Cooldowns: Some tweak for quick setup spells
* Raid Cooldowns: fixes for test mode
* Invite tools: removed loot method options
* Minor fixes

v.3930
* BFA Update


]=]