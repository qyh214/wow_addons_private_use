# AllTheThings

## [4.3.11](https://github.com/ATTWoWAddon/AllTheThings/tree/4.3.11) (2025-03-28)
[Full Changelog](https://github.com/ATTWoWAddon/AllTheThings/compare/4.3.10...4.3.11) [Previous Releases](https://github.com/ATTWoWAddon/AllTheThings/releases)

- [Config] Update for SoD P8.  
- [DB] SoD: Add raid: Scarlet Enclave.  
    Scarlet Enclave is a new raid introduced in SoD P8.  
- [Logic] Retail: Slight improvement to collected check for Criteria based on completed Achievement  
- [Logic] Adjusted app.LocalizeGlobal to fit its purpose and usage more accurately  
    [Logic] Fixed a few calls to app.LocalizeGlobal which would fail to assign an initial value  
- [Logic] Removed static filterID's for defined Classes [This doesn't change any filtering since these filterID's can't be toggled by the User so they're always un-filtered, and having a filterID returned just slows down regular filter checks with a 100% true outcome]  
- [Parser] Fixed PresetsDB to use direct keys instead of ambiguous arrays (also don't need to define 'false' when defining keys directly)  
- [Parser] Retail: Consolidated the PresetsDB setup  
- [DB] Added 'sourceAchievements' to Argent Tournament data  
    [DB] Retail: Removed extraneous custom logic from Argent Tournament for Retail now that 'sourceAchievements' are handled inherently  
- [Logic] Retail: Required Achievements (sourceAchievements) are now shown in popouts if applicable  
- [Logic] Cleaned up and localized some Event handling logic for those itty-bitty performance improvements  
- [Logic] Retail: Migrated 'sourceAchievements' to information type within Achievements module  
- [Parser] Another tiny whitespace reduction in DB function exports (not compiled)  
    [Parser] TODO for 'WithRequiredAchievement' OnTooltip function remediation  
- [Parser] Cleaned up a few trailing-comma situations from ReferenceDB exports  
- [Parser] Compressed ReferenceDBs are now slightly more compressed  
    [Parser] Messages about missing data in sharedData or bubbleDown are now considered errors  
- [DB] Fixed a preprocessor which caused 'crs' to disappear for 4.0.3. to 10.1.7 parses  
- [DB] Sourced 'Faithless Wingrider's Focus'  
- [DB] Some coords and ignored object  
- [Contrib] Object coord checks can be relative now (sometimes we list object with no coords inside object with accurate coords if the situation calls for it)  
- [Locale] Fix misc.  
- Nazjatar and parsed  
- [Logic] Refactored a few places to utilize .keyval directly  
- [Logic] Retail: Fill now utilizes ForceFillDB to ignore skipping previously-filled matched groups  
- [Parser] Added a 'ForceFillDB' which is a set of Things which are allowed to be filled even when encountered multiple times within the same Fill context. [Initially used for Naxx tokens since they show under their Source boss & Gluth, so typically only one boss would then fill the respective Token within the minilist]  
- [Logic] Added base Class field 'keyval' since it seems pretty common we need to use the key value of a group (not replaced usages yet)  
- [DB] Fixed Warosh's name  
- [Logic] Minor improvements to Build Search Response performance  
    [Logic] Fixed display in /att filters when searching for 'nil' in a field  
- [Contrib] The Runecarver's Oubliette is a tiny map  
- [DB] Cleaned up handling for 'Chronicle of Lost Memories' so the symlink is only listed in one place (maybe idea for future to compress symlinks which are shared)  
- [Logic] Retail: min/max reputation now only show in tooltips when accurate for all Sources of a Thing  
- [DB] Couple more Korthia updates & a use for Soul Cinders?!  
- [Logic] Retail: Revised how certain learnable Things are skipped during Fill to cover more situations where this behavior is desirable  
- [DB] Refactored 'Primal Invocation Extract' and related Glimmer structure to actually represent how it works in game  
- [Parser] Fixed an issue with the name() shortcut when using implicit groups within it  
- [Parser] Added an 'itemDropHQT' shortcut for making an HQT group based on the HQT triggered when an Item drops  
- Fix some reported errors  
- Sort many HQTs  
- [Logic] Retail: Fixed another potential data alignment issue for recipeID's over 1M  
    [Logic] Retail: No longer fills 'purchases' under collected Toys when they are not the Root of the Fill operation (i.e. no longer see that you need some Currency to buy a Toy you already have because the Toy is needed for something else you don't have yet)  
- [Logic] Retail: Tracked down a niche issue where Items crafted via RecipeIDs over 1M would show the wrong Contains content only in Tooltips  
- Adjust Honor Achievement timelines  
- [Parser] Fixed an issue where the NonRepeatField logic was ignoring the parent's field value when removing the single consistent value across all child groups (e.g. this resolves many 'awp' situations where it resolved to the parent's value in game when the child groups had a different value when parsed)  
- Regenerating missing files  
- Classic: Fixed an issue with the Account Management window.  
- Sort Recipes  
- Harvest: 11.1.5.60179  
- Harvest: 11.1.5.60067  
- Harvest: 11.1.5.60008  
- Harvest: 11.1.5.59919  
- Harvest: 11.1.0.60228  
- Harvest: 11.1.0.60189  
- Harvest: 11.1.0.60037  
- Harvest: 11.1.0.59888  
- Harvest: 4.4.2.60192  
- Harvest: 4.4.2.60142  
- Harvest: 4.4.2.59962  
- Harvest: 3.4.4.60190  
- Harvest: 3.4.4.60063  
- Harvest: 3.4.4.60003  
- Harvest: 3.4.4.59887  
- Harvest: 3.4.4.59853  
- Harvest: 3.4.4.59817  
- Harvest: 1.15.7.60191  
- Harvest: 1.15.7.60141  
- Harvest: 1.15.7.60013  
- Harvest: 1.15.7.60000  
- Harvest: 1.15.7.59856  
- [Parser] Fixed Living Branch itemID to mark uncollectible  
- Updated Object Harvester to look for mx and tw languages on WoWHead.  
- [Timeline] Add build number for 1.15.7.  
- Add new LoU renown quest, reduce sourcing of market research/CHETT cards, fix some reported errors  
- [DB] Moved Stygian Lockbox to actual Location where it's pickpocketed  
- [Logic] Some indentation reduction in quest handling  
- [Logic] Retail: Fixed text about item failing to load from persisting when the Item does actually load  
- Grrrr - Parse after new objects plus contrib stuffs  
- [DB] Getting some unsorted Cata necks and fingers sorted  
- Fix some reported errors  
- [Logic] Bumped CanRetry to 3 sec (from 2 sec) & added a testing method to allow adjusting the value for any needed user testing  
    [Logic] Retail: Items no longer default their link to the default item name when failing to return item info after the CanRetry duration. Also, we no longer block CanRetry on Items once they fail to populate valid Server data (this way they should re-try themselves later if viewed again in a list)  
- Update 11.1.5 Timelines  
- Oh yeah there are tournament banners available, go sign up before it's too late  
- [DB] q:65622 is also an HQT not linked to Criteria  
- [DB] q:65005 seems to truly be an HQT, not linked to Criteria  
- Fix some reported errors  
- [Cata/Retail] Properly mark Jezebel Bican's location as HFP, instead of Dalaran (#1955)  
    Properly mark Jezebel Bican's location as HFP, instead of Dalaran  
- [Parser] Retail: Adjusted hierarchical handling for awp/rwp fields (recommend updating Classic configs in the same manner)  
- Added COMMON\_QUALITY\_TRANSMOGS to the parser config files.  
- Classic: Fixed a bug with the dynamic recipe lists where they seemingly ignored important filtering requirements.  
- [Parser] AchievementDB for TWW no longer provides unique data (over WagoDB files) for parse and will now be ignored  
    [Parser] NonRepeatField hierarchical logic no longer removes parent field values which differ from child field values  
    [DB] Updated WagoDB files (no apparent changes)  
- [DB] Adjusted 'Kirtonos the Herald' timeline bubbledown for accuracy  
- [DB] 'Camp Winterhoof' and 'Help for Camp Winterhoof' are mutually exclusive outside of Party Sync  
- Fixed a couple of BOP crafted blacksmithing items not having a requirement for blacksmithing on them.  
- Fixed a couple of BOP crafted leatherworking items not having a requirement for leatherworking on them.  
- [DB] Fixed contract Account wide quests & 'Undermined Delves' is not AW  
- Kalimdor/Feralas: Refactor code to eliminate duplicate keys  
    - Added/Updated some descriptions and coordinates  
- [Misc.] Sort locale order.  
- [TOC] Add esMX localization.  
- [Locale] Separate esMX from es to mx.  
- Update es.lua (#1954)  
- Classic: Updated a number of windows to preload their data container.  
- Renamed the "Sync" window to "Account Management".  
