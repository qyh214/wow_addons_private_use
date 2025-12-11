# AllTheThings

## [4.8.4](https://github.com/ATTWoWAddon/AllTheThings/tree/4.8.4) (2025-12-10)
[Full Changelog](https://github.com/ATTWoWAddon/AllTheThings/compare/4.8.3...4.8.4) [Previous Releases](https://github.com/ATTWoWAddon/AllTheThings/releases)

- Moved few NYI decor items back to Unsorted. They will be obtainable maybe with 12.0.0, will see.  
- Finished all housing quests and added coords to them.  
- Bump build to 11.2.7.64797  
- Update RU locale for quest warning string  
- MISTS: There's only one version of Mogu Runes of Fate in MOP Classic.  
- MISTS: Added Stolen Shado-Pan Insignia to the Warbringers.  
- MISTS: Moved the Mogu Runes of Fate quest to Vale and adjusted timelines and stuff.  
- MISTS: Updated the tooltip for the new Work Orders quest object to show the quests that actually give reputation.  
- Added many coords for the 'Decor Treasure Hunt' quests.  
- MISTS: Now targeting 5.5.3. Marked Listen to the Drunk Fish as deleted with 5.5.3.  
- [DB] Couple Decor Treasure coords  
    [DB] Adjusted Decor in Garrison Trading Post  
- [Logic] Fixed the OnlySortingRightClick function eating Left clicks in some cases  
    [Logic] Retail: Added 'CreatePopoutForSearch' to create a popout from a 'search' string  
    [Logic] Retail: CostItem and CostCurrency groups (in Cost and Total Cost groups) now create proper popouts when right-clicked  
- [Debug] Added decorID to DebugDB export  
- [DB] Some quest and Decor updates  
- [Logic] In addition to Breadcrumbs, all Things with 'lockCriteria' now also warn when accepting a Quest which can lock them from being collected  
- [Logic] Retail: Alt-Click tracking now works for Quests  
- Addressed some parser warnings that came from the Uldir InstanceHelper rework  
- Decor Hunt: Two more coordinates  
    - and some misc updates  
- Added Darkshore decor items.  
- Sorted few more decor items.  
- Added 2 more decors from Garrison assault quests.  
- Legion Remix: 'Out of Time' and 'Until Our Next Hello'  
    - Blank Doomsayer's Pamphlet  
    - Move 'Invasion' achievements  
- material cleanup mop  
- some more work in zg sod  
- Bump build to 11.2.7.64772  
- Legion Remix: Cache from the Infinite's Armory  
    - Placeholders for final event quests  
- updated tbc and naz trainers to follow the same layout as the other professions in other expansions  
- [Locale] Decor Lumber: Update localization  
- some decor error reports  
- Decor items have no First Craft bonus.  
- Uldir InstanceHelper review feedback  
- [Logic] Added Total Reagents calculation! [WIP]  
    * This will include a row in ATT popouts that calculates the total Reagents required for all Crafting output Items within the popout  
    * [Initial implementation, there are many more things to add/fix concerning this]  
- [Logic] Added a 'OnlySortingRightClick' OnClick function to only allow a sorting right click  
    [Logic] Retail: Cost and Total Cost can now be user-sorted (default sort is by the total required)  
- [Logic] Retail: Fixed Recipes in Sources popout not being visible based on Filtering  
- Added Lumber objects into MobileDB.  
    Fixed weird overlap of classic/cata lumber.  
- Added Lumber object names.  
- Added all objects and maps for Lumber locations.  
- [Logic] Retail: Popouts of Items which are Crafting Outputs will now include their Recipes under 'Source(s)'  
- [DB] Added Classic Lumber objects stub  
- [Logic] Retail: Fixed logic where a Thing could show itself under 'Source(s)' due to having an npcID linked  
- [Parser] Fixed a logic issue where harvested object names would not be included in the current parse  
- [Logic] Retail: Fixed NPCs shown in 'Source(s)' of a popout sometimes not including known ATT information  
- [Logic] Retail: Fixed an issue where Total Cost in a popout could include Costs of already-learned Recipes/Things if they were visible in the List  
- [Logic] Fixed a logic issue with 'Maps' information type when in a Location that actually has no MapID (Player Housing)  
- [Logic] o\_repeated groups now work properly with 'maps' fields  
- [DB] Update Sourcing example for 'Olemba Lumber'  
- [DB] Fixed SL TW symlinks [items are base versions so don't need modItemID selects]  
    [DB] Couple Decor Treasure Hunt coords  
    [Contrib] Some ignored objects  
    [Misc] Formatting in Symlink file  
- [DB] TBC Crafted Items: Olemba Lumber coords and maps  
- [DB] Couple DH campaign quests adjusted  
- Legion/Antoran Wastes: Unify the data for 'Squadron Commander Vishax' rare and add a QS! under Zone Drops  
    - Added a few QIs here and there  
    Housing Decor Hunt: Two more coordinates  
- 2 typo fixes (#2229)  
    * Typo in naxxramas  
    * Fixed Spires of Ascension TW  
- One more Uldir fix.  
- Removed duplicated 'Pattern: Embroidered Deep Sea Bag' in Uldir (it's LFR+).  
- Refactor Uldir with InstanceHelper  
- marked some things daily. maybe only during remix, but included if statements for that  
- Fix a few reported errors  
- Added Wandering Isle set for Pandaren Heritage.  
- Added HQT for 'Mastery of Timeways' buff.  
- window: only ClearAllPoints if a valid Point is saved (#2149)  
    * window: only ClearAllPoints if a valid Point is saved  
- [DB] 10.1.5 Nazzramas: Description about Frozen Rune locations  
- Decor Treasure Hunt: Two more coordinates  
    - Remove descriptions as nobody else is adding them :(  
- [Debug] Remove debug print from Instance cache  
- [Logic] Retail: Decor no longer hooks ATT information while editing your House (e.g. you can see the Placement Cost again) (fixes #2227)  
- Add special Mechagon quest box  
- [Logic] Simplified some ignoreSourceLookup fields  
- [Logic] Retail: Removed some tooltip search fallback logic since I can no longer find the proper counter-examples for why it needed to exist and it's messing up some tooltips :weary:  
- [Logic] Retail: Major improvement to some tooltip lag by skipping Filling when viewing tooltips on ATT rows which have no link or no tooltip info from the link  
- [Logic] Retail: Simplified the check for adding Contains data to a group  
- Fix a few reported errors  
