STATS_PLUS_CHANGELOG_CURRENT = [[|cff99FFAA1.55:
Removed Auto Hide Tertiaries (no longer possible)
Fixed Versatility display (doesn't update mid-combat/M+ key)
Re-enabled auto width calculation
TOC update

]]

STATS_PLUS_CHANGELOG = [[1.54:
Fixed colors in options

1.53:
Bugfixes for latest API changes
- Removed Armor % for current target - only Rating is shown now
- some vers changes, need more testing
- some throtteling removes - rip secret values
- speed will most likely not work anmore - dont use it for now (untick show speed)

PS: If u reload mid combat/M+ Run, u will get an error, ignore that.

1.52:
Additional temporary fixxes for the latest API changes

1.51:
Temporary fix for the latest API changes

1.50:
Adjusted Stat Priorities (19.04.26 - based on Murlok M+ Data)

1.49:
Adjusted Stat Priorities (10.04.26 - based on Murlok M+ Data)

1.48:
Adjusted Stat Priorities (03.04.26 - based on Murlok M+ Data)

1.47:
Adjusted Stat Priorities (27.03.26 - based on Murlok M+ Data)

1.46:
Fixed rare cases where Itemlevel is not updated after changing gear
Adjusted Stat Priorities (20.03.26 - based on Archon Heroic Raid Data - only for this week because Murlok has no Data) (It uses the Murlok dropdown, you dont have to change anything)
Its pre season, so dont take it 100% serious. We dont have access to much gear right now

1.45:
Adjusted Stat Priorities (13.03.26 - based on Murlok M+ Data)
Its pre season, so dont take it 100% serious. We dont have access to much gear right now

1.44:
Fixed Speed stat while using one line layout

1.43:
Adjusted Stat Priorities (06.03.26 - based on Murlok M+ Data)
Its pre season, so dont take it 100% serious. We dont have access to much gear right now

1.42:
Fixed font on some localizations (colors)

1.41:
Added missing translations
Fixed a bug with lock frame

1.40:
Forgot to change the Tooltip for Tank Stats :)
Fixed Speed toggle not activatiing Speed updating instantly
Added Background Customization (Appearence Tab)
Adjusted Stat Priorities (26.2.26 - based on Murlok M+ Data)

1.39:
Added/Changed tooptip infos for (AutoHideTankStats, AutoHideTertiaries, Show Speed)
Added a label to stat ordering
Fixed frame strata loading on profile change
Removed default text in stat ordering, for less confusion (u can instanly use the dropdown)

1.38:
Changed Armor Percent to be against current Target
New Option: Use Global Position (Checkbox)
New Option: Armor Formating (Dropdown)
New Tab: Infos (for Infos, Changelog & more)
Fixed Auto Hide Tank Stats, to hide all stats while DPS/HEAL
Fixed Tooltipinfo (Show Speed, Auto Hide Tank Stats) to not hook on other Widgets
Added Korean Localizations (thanks to ssal)|r
Adjusted Stat Priorities (19.2.26 - based on Murlok M+ Data) -> Appearance/Stat Ordering/Secondaries/Priority base(murlok.io)

1.37:
Added a new event "UNIT_SPELLCAST_SENT" (active for Tanks only), to track defensive stats more frequent.
Fixed, rightclick not toggeling "locked" mode

1.36:
Fixed right clicking Minimapbutton correctly set values in the GUI
Changed Text for the Unlocked Frame State for better understanding
Less confusion for Lock Frame Position and Use Background 
   (Use Background and Background Opacity is disabled as long as Lock Frame Position is enabled)

1.35:
TOC Update
Adjusted Stat Priorities (11.2.26 - based on Murlok M+ Data)

1.34:
Mini GUI Adjustments
Preview in Font Dropdown
Reworked DB Reset (only popups for older versions now <1.30)

1.33:
Added Minimap Button
Added LibDBIcon + LibDataBroker

1.32:
Changed arround some defaults (especially speed is off by default)
Adjusted Stat Priorities (05.2.26 - based on Murlok M+ Data)

1.31:
Changed with calculation for background to not be extra huge
Added Background and Opacity as an option

1.30:
Added LibDualSpec for Auto Profile Switching
Custom Text for all Stats
Added Autohide Tertiaries
Added Autohide "main" defensive stat
Changed position to be global (for now) - let me know if u dont like this
Fixed showing %% on speed sometimes

1.29:
For this Update you have to reset your DB, to avoid corruption. This will be displayed once u update it.
Switch to AceDB
Profiles setup

1.28:
Strata fixxed :) surely - also added 2 missing ones
Itemlevel Display (Overall Itemlevel) showing properly again
Added Armor, Dodge, Parry, Block
Toggle Secondaries
Reordered Dropdown Options just for visuals

1.27:
Fixed New and Prio based Localizations not showing for all available languages
Fixed Defaults not showing for some Settings

1.26:
Dropdown menu of Strata Options Sorted from lowest->highest option
Visibility option added
Speed Format option added
Custom Stat Ordering for "All Stats" and "Secondary Stats"
Adjusted Stat Priorities (28.1.26 - based on Murlok M+ Data)

1.25:
Added Decimal places as a slider
Fixed Background-Scaling if Speed is enabled
Fixed Frame Strata not working properly
Even less performance hit while using Speed
Adjusted min and max value for Update Interval

1.24:
Added missing Chinese Translations
Replaced some Russian Translations

1.23:
Added Speed Tertiary
[Important] The Update Interval (Speed) can only be changed via chat command. This is done to make sure everyone is aware that enabling it may have a slight performance impact.

1.22:
Raised the Color Picker frame strata for easier navigation
Added a scrollframe so content now stays inside the optionsframe
Colors that are normally hidden will now temporarily be shown when changed

1.21:
Added Devourer Demonhunter to specpriority
Adjusted IDs for all Demonhunter specs
Removed unwanted text shadow (thanks to Liam)
Reworked whole GUI
Added Russian (ruRU) support -> ty to Hollicsh for contributing
Fixed an issue with click through (stats frame)

1.20:
Fixed Lua Error caused by 1.19

1.19:
Added Tertiaries Leech and Avoidance with extra customizability
Added a Colorpicker
Adjusted the Optionsframe

1.1.8:
Added Traditional Chinese (zhTW) support -> ty to SGSwdzgr for contributing
Added Simplified Chinese (zhCN) support -> ty to SGSwdzgr for contributing

1.1.7:
Added Stats+ in Blizzard Options
Adjusted Stat Priorities (17.1.26 - based on Murlok M+ Data)
Fixed Frame Strata (options frame)
Changed Name in Addons Module (Stats -> Stats+)

1.1.6:
Added Frame Strata
Added One Line Layout

1.1.5.2:
Adjusted Stat Priorities (3.1.26 - based on Murlok M+ Data)

1.1.5.1:
Fixed a bug where the optionsframe will show old values after changing them

1.1.5:
Adjusted Options Frame (Size and Text)
Added HeroTalent based Sorting (like in my Weakaura - based on murlok.io)


1.1.4:
Changed command /s to /st (you can also use /stats) -> prevented to use the say chat - thanks to Odysseus68
Added an option to Ilvl display (Auto) -> If your equipped Ilvl is equal to your bag ilvl it only shows equipped ilvl


1.1.3.1:
Fixed Frame not updating after swichting Fonts


1.1.3:
Added Font Changer
Added Secondary Stat Ordering per Spec (based of murlok.io)
Fixed Versatility not showing in Legion Remix


1.1.2:
Added a background box while in edit mode

Adjusted font size settings
Added an option to disable Item Level
Added an option to disable Main Stat


1.1.1:
Fixed text not updating after changing alignment
Added one more line to Secondaries text


1.1:
Added customizable text for Secondaries
Added customizable text for Versatility
Fixed scaling/anchoring bug

]]