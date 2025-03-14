# AllTheThings

## [4.3.4](https://github.com/ATTWoWAddon/AllTheThings/tree/4.3.4) (2025-03-09)
[Full Changelog](https://github.com/ATTWoWAddon/AllTheThings/compare/4.3.3...4.3.4) [Previous Releases](https://github.com/ATTWoWAddon/AllTheThings/releases)

- Fix a few more errors, add C.H.E.T.T. description  
- Fix some reported errors, update Undermine raid content  
- [Locale] Update zhCN: Undermine (#1926)  
- WotLK ores and elementals  
- Update Undermine campaign quests, fix some reported errors  
- Retail Errors  
- EK/Burning Steppes: Refactor code to eliminate duplicate keys (#1921)  
- EK/Arathi Highlands: Refactor code to eliminate duplicate keys (#1920)  
- EK/Wetlands: Refactor code to eliminate duplicate keys (#1919)  
    - "Incendicite Ore" (item 3340) has been made obsolete as of Cata. New one does not require a Profession to be acquired;  
    - "Black Whelp Scale" (item 7286) was relevant pre-Cata as it is part of (at least) 2 Classic Leatherworking Patterns;  
    - "Guardsman Belt" (item 3429) was added to vendors at 10.1.7;  
    - Remove a note on C"ursed Eye of Paleth" (item 2944) as it is permanently unlocked;  
    - Add proper Timelines on "Razormaw Hatchling" (item 48124) as it was a drop from a creature at one point;  
    - Move "Razormaw Matriarch's Nest" (object 202083) to Treasures.  
- EK/Redridge Mountains: Refactor code to eliminate duplicate keys (#1911)  
    - Kimberly Hiett only sold Arrows before the release of Cataclysm.  
    - Morganth (pre-cata) and Grand Magus Doane (post-Cata) share npcID  
- EK/Wetlands: Partially revert bef0bc89fae3a0a77d6a38138448b320ddae30c1  
    This, along with various other Zone Drops will be fixed with PR #1919  
- Update Vignette.lua  
    Ignore Undermine Renown Quartermaster  
- Removed expansion from AWP window dynamic headers since the empty groups are purged anyways.  
- Update some Undermine drops  
- Added Undermine quest rewards.  
- [Logic] Retail: Dynamic categories within a patch header for /att awp will now clean out empty groups  
- Aligned and documented vendor availability of the dragonriding cup rewards  
- new ssn new seasonal toys  
- Fix typo preventing parse  
- New year, new copyright.  
- [DB] Missing coord for Delegation  
- added anyclassic to classic boost  
- Retail: Delve ring sorted, weekly for alts fix, trading post questID and Blizzard decide to fix crests  
- Update some Undermine things, fix a Wetlands item drop  
- [Logic] app.GetNameFromProviders now uses proper WOWAPI wrapper for GetItemInfo  
- [DB] Ancient Suffering & The Darkmist Legacy are not really breadcrumbs, but they do get locked if Verinias the Twisted becomes flagged completed  
- [Logic] Retail: Revised implementation of dynamic groups within /att awp [exp] individual patches to load when viewed  
- [Logic] Fixed an issue with app:BuildTargettedSearchResponse where a search against a set of prior search results would fail to return any resulting data  
- [Logic] Assignments to DelayLoadedObjects are now captured into a default holder table prior to the object being created  
- [Logic] Retail: Fixed a logic bug where app:BuildTargettedSearchResponse against a specific 'groups' would allow doing a full cached-based search instead if no 'criteria' was also provided  
- [Logic] Retail: Safeguard a potential Cost reference Lua error for some users on login  
- Simplified expansion values in dynamic categories in AWP window code.  
- Added dynamic groups for /att awp commands.  
- Fix Rituals of the New Moon, fix some errors  
- added darkfuse chompactor mountitemID  
- Add Gallywix normal ID  
- [DB] Removed 'sourceIgnored' fields from where they shouldn't be  
- [DB] Retail: Removed the duplicated listing of Heirlooms within Character > Heirlooms [Use the dynamic category to see all Heirlooms in one group :thumbsup:]  
- [Logic] Fixed Heirlooms with an Appearance to ignore their FilterID as expected when collectible as an Heirloom  
- I always find a typo when reviewing own commits.  
- More sorting for 11.1.0.  
- Removed duplicated toy in ToyDB.  
- Sorted a lot of TWW stuff, mainly cleaning Missing files.  
    Changed few delve timelines back to 11.1.0.  
- Added some hidden currencies that I had stashed for months and forgot about it lol.  
- Fixed wrong comma for some new Undermine toys.  
    Fixed delve timelines and added them for Level HQTs.  
- Fix some reported errors  
- TBC: My head is getting cloudy  
- Update Mount/Pet/ToyDB for 11.1.5.59571  
- Sort some new dungeon drops, add Brann 60-80 HQTs  
- Fixed the abbreviation for Cataclysm to prevent it from shortening "Cataclysmic" to "Cataic", etc.  
- Classic: The Auction House Module now sorts elements by their price within the list.  
- Fix some reported errors, clean up delve loot  
- [Logic] Very minor caching logic cleanup/improvements  
- [Logic] Retail: More Cost fixes!  
    * Fixed Costs from always being considered a Cost when leading directly to other Costs which themselves were for a filtered-Purchase and not showing  
    * Improved some Cost logic that only needs to run when settings are changed  
    * Consolidated some collectible checking logic  
- [DB] Cleaned up Speaker Gulan to properly use providers  
- [Misc] Removed some indentation from NPC filling  
- Zipthrottle: Short and fix.  
- Update some objects and confirm some raid HQTs  
- [DB] Removed Synthebrew Goggles from being providers of quests that they themselves are provider for  
    [DB] Organized Sparklematic stuff in Gnomergan & timeline fixes for removed stuff & adjustments from personal testing  
- Zapthrottle: The superiour solution  
- TBC: Zapthrottle Mote Extractor  
- Add Renzik's Lockbox, sym scrap box rewards to job streaks  
- Cata: Adjusted the Protocol Twilight drops.  
- Setup Hard Ways at the Gallagio  
- [Parser] Fixed a logic issue where timelines without an explicit 'added' change which are currently-available would include the 'awp' value of a future re-adding patch rather than the 'rwp' of the future removal patch  
    [Parser] Fixed a logic issue where some Spells would be used for providers instead of their respective Item  
- [Parser] error() now performs an Error log instead of destroying the Lua context in an actual error throw (this allows us to actually know where the error came from)  
    [Parser] Classic: Files parsed via the #IMPORT commands which encounter error() or print() will now properly include the sub-file where it occurred  
- cata classic rbg wpns fixed  
- Add Darkfuse Solutions  
- [Parser] Classic: Fixed an issue with pre-wrath encounters sometimes not converting as expected when not containing a 'groups' field  
- [CI] Add 'auto' arg to the parser args.  
    the arg, auto, means that when an error that cannot be resolved is encountered, the program will exit without waiting for user input.  
- Fix some reported errors, clean up delve HQTs  
- [CI] Call the parser directly instead of using bat.  
- [Parser] No longer returns early or in an error state if 'IGNORE\_ERRORS' is included in PreProcessorTags config (this is dangerous and all errors should be fixed!)  
- Classic: The Removed With Patch Loot window can now be configured to exclude non-collectibles and also set an arbitrary RWP maximum to use for its filter.  
- [CI] Split the classic parser flow.  
- Changed few more timelines to season start, although now it does not even matter, but let's stay correct :)  
- Some HAT from latest build  
- [Parser] Various cleanup and updates  
    * Consolidated handling of parser run arguments  
    * Consolidated handling of 'wait for user' functionality (likely to be removed entirely in future)  
    * Providing an 'auto' argument to the Parser will cause it to no longer trigger any 'wait for user' functionality  
    * Moved a bit more logic to PostProcessing  
    * Split Criteria which relate to Spells & utilize spell providers where possible, relegating to associated item provider where possible as well  
- [Test] Added a script timeout test function  
- [Logic] Real-time exploration check now updates visible groups properly when collected  
- [Logic] Retail: Missing map dialogs should now include additonal zone names if available  
- Fix more reported errors  
- [DB] S.C.R.A.P. content is now linked to the Vignette which pops in the zone as applicable  
- [DB] Fixed encounter ID of The Gobfather  
- [Harvest] Added harvested quests up to 91000 since Blizz apparently went crazy with IDs  
- [Logic] Quests which have no server quest name now perform an additional check in case they have a name based on other delay-loaded information and allow a few retries to load that name before printing the quest completion in chat  
- Setup Homecoming chapter (why bother with story mode if it's not open week 1)  
- [DB] Removed 11.0 upgrade bonuses & added 11.1 upgrade bonuses  
- Update some Undermine things post season launch  
- [Locale] Update zhTW: Cartels of Undermine.  
- [Locale] Update zhCN: Season of Discovery.  
- [Locale] Update zhCN/zhTW: Waylaid Supplies  
