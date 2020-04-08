# <DBM> Outlands

## [r671](https://github.com/DeadlyBossMods/DBM-BCVanilla/tree/r671) (2020-03-29)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-BCVanilla/compare/r670...r671)

- Fix to last  
- Sync some classic updates back to BWL for retail  
- Small Fix for Last  
- Classic TBC Prep 1: Karazhan  
     - Updated any remaining variables that weren't syncable by timer recovery so that all variables used by these mods are supported by timer recovery.  
     - Updated all target warnings that don't have special warnings to be exempt from target warning filter feature in DBM-Core to ensure no warnings go missing.  
     - Updated some mods that were still creating args table for all combat log events instead of just the ones for spellIds we care about (cpu saving)  
     - Updated Icon and rangecheck options to the modern objects so that they use auto localized text as well as honor the global disable options from DBM-Core  
     - Added Special warnings for interrupts to Moros encounter for both heal spells now that modern objects support good filtering of when no to show these warnings.  
     - Updated a few option defaults to defaults that make more sense for some of the spells in these encounters.  
     - Updated bosses that have multiple phases to now support showing phase in wipe messages and status whispers  
     - Fixed bug with auto marking of elementals on shade of aran to actually mark the 4 adds with 4 different icons instead of trying to mark all 4 adds with star. FIxing this bug also fixed inefficiency in object as well since it was trying to scan for 16 adds for 20 seconds instead of 4 adds for only a couple seconds.  
- Sync some more fixes from classic I forgot to push  
