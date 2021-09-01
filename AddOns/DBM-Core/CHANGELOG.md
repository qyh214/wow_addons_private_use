# Deadly Boss Mods Core

## [9.1.12](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.1.12) (2021-08-31)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.1.11...9.1.12) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prevent duplicate timer entries through additional validation check  
    Don't call unnessesary stop calls during timer updates on generals and nerzhul. The cleanup is already handled in the :Update method so performing it twice is just wasted cpu and redundant debug  
    Minor timer adjustments  
- silence yell above 8 players  
- Don't need to clear icon multiple times. just once. another micro performance improvement to fragments icon code  
- Fixed bug where grimm portent yell on fatescribe was non sensicle  
    Cleaned up the nines fragments code and maybe fix a bug with fragment yells/icons if more than 3 exist at same time on heroic or more than 4 exist at same time on mythic plus small performance change (calculating uid multiple times is silly, it doesn't change  
- Update koKR (#655)  
- Fix count issue (#654)  
    Some idiot forgot to use pairs to iter items  
- Don't debug report wipe on boss mods that don't have proper combat.  
- suspend news update until there it is needed again one day.  
- Fixed invalid variable name in darkness timer  
- Add additional protection while at it in remote chancec event is added to other mobs (probably won't be, they have spawn events already )  
- unrelated note, soul shard marking was broken on KT because it was using wrong GUID, fix that at least.  
- Fixed nerzhul incrementing phase twice on phase change, resulting in timers to go off the rails bonkers  
- LFR adjustments to castle based on debug feedback.  
- two minor timer corrections  
- More P1 LFR data  
- Fixed bug that caused arrow countdown yell not to actually use the right option/prototype. How something was broken for MONTHS before a single user reported it is beyond me. Why don't people report bugs :\ Special thanks to the person who came forward now.  
- bump alpha revision  
