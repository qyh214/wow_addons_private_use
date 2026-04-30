# AllTheThings

## [5.1.3](https://github.com/ATTWoWAddon/AllTheThings/tree/5.1.3) (2026-04-30)
[Full Changelog](https://github.com/ATTWoWAddon/AllTheThings/compare/5.1.2...5.1.3) [Previous Releases](https://github.com/ATTWoWAddon/AllTheThings/releases)

- parse  
- [Logic] GetIconFromProviders now handles Spell providers  
    [Logic] Achievement Criteria now attempt to use a valid provider icon if they have providers assigned before defaulting to their Achievement's icon  
- may trading post  
- [Logic] Fixed app.report not printing properly if the first argument is nil  
    [Logic] Fixed Callback methods not properly running with all arguments if the first argument is nil  
    [Logic] Fixed TableKeyDiff considering matching false values as differences  
    [Logic] Added TablesIdentical and CountTable helper methods  
    [Performance] Various micro-optimizations in heavily-used functionality  
    Co-authored-by: Copilot <copilot@github.com>  
- [Debug] Added performance capture for Visibility-assignment functions  
- [Logic] Fixed an oversight where users using 'Loot Mode' could have marginally-degraded Update performance after many force-refreshes (until force-refreshing an equivalent amount of times with 'Loot Mode' NOT enabled)  
    Co-authored-by: Copilot <copilot@github.com>  
- Bumped build files to 12.0.5.67235  
- [Logic] Use 'IsQuestAvailable' when determining if quests have cost collectibles to properly account for all situations  
- Repeatable quests that are "saved" no longer filter out their cost collectibles. (Junkboxes Needed in Classic Era)  
- [Contrib] Leniency on coord accuracy for Objects sourced under Quests is now 3 (was 2)  
    [Contrib] Coord accuracy by default for Objects is now 1 (was 2)  
    [Contrib] Add an 'in-game' check for Objects (e.g. if an Object is in-game or available but ATT has it marked as removed)  
    [Contrib] Frostwall map precision bumped to 2.5  
- Added the Nap Mat, the new Children's Week reward  
- [DB] Voidbreaker Throggar HQT in Mythic  
- [DB] Fix qg for An Unrelenting March  
- Update Quests.lua  
    NYI quest.. but shows completed when completing the other quests  
- [Logic] Fixed bubbleDown on Timelost Saddle  
- Weekly Quest and parsed  
- [Logic] Fixed an issue where some Quest names would fail to retrieve themselves if the questID was passed as a string  
- [Logic] Fixed another secret value issue in RetrievingData  
- [Locale] Update esES/MX: Object ID. (#2404)  
    - Since "item" and "object" mean the same thing in Spanish, "object id" needs a clearer specification of its use for better reporting. Now object use "Environment Object" in es-es and es-mx  
- [Pet Battles] Add missing Flawless Dragonkin Battle-Stone (#2401)  
- Children's Week: Update Prismatic Bauble timeline (was available for Pride Month once in the past)  
- Midnight Keystone Myth: Achievement, currency, and mounts  
- Ritual Sites: Fix blunders of copy/pasting  
- Added one more Void Assault pet from Eversong Woods.  
- Ritual Sites: More pets!  
- Surely the last change to Void Assaults.  
- More Void Assaults symlinks and fixes.  
- Corrected all rewards from 'Light of the Party' item.  
- Applied new icons.  
- Added Blizz Icons for some Midnight xpac features   
    Prey, Abundance, Ritual Sites & Void Assaults  
- [DB] Added many more account-wide quests  
- [Logic] ATT dialog with Editbox now respects 'Enter' and 'Esc' presses in an expected manner  
    Co-authored-by: Copilot <copilot@github.com>  
- [DB] Gouging Pick is actually learnable  
- [Logic] Fixed a Lua error from secrets being checked for 'Retrieving' status (fixes #2405)  
- Account sync serialization (#2393)  
    * [Logic] Various Account-sync serialization testing to try to reduce sync times  
    * [Logic] Added sequence shortening for trie compression  
    * [Logic] Added 0-based RLE compression to bit-array serialization to slightly reduce transferred length a bit more on average (e.g. 511 chunks -> 201 chunks for Main char)  
    * [Logic] Fixed an error when bit-array serializing a table which has non-numeric keys  
    [Logic] Added (de)serializers for num-num table fields (AzeriteEssenceRanks)  
    [Logic] Ignore some other possible keys which may be present in user data cache  
    [Logic] Made the serializer/deserializer calls safe from errors with a message print when they fail so it can be sent to Devs for analysis  
    * [Debug]  Comment debugging functions  
    * ...  
- [Logic] Use constant locales for ATT popup dialogs  
    [Logic] Added a 'cancel' button for the ALL\_THE\_THINGS\_EDITBOX popup  
    [Logic] Fixed timeout of popup potentially lingering between popups  
- Brawler's Guild: Correct criteria ID for Unguloxx (#2406)  