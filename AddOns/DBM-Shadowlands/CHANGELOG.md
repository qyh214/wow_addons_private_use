# <DBM> World Bosses (Shadowlands)

## [9.1.20](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.1.20) (2021-11-02)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.1.19...9.1.20) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- prepare new core releases  
- Bump toc files  
- Updated Halkias sinlight timer based on feedback and log checking  
- Fixed a bug where the scheduler woud not have correct zone Id do to flawed logic that only updated it if a mod registered a function BEFORE changing zones (which realistically almost never happens, since mods register custom schedulers mid fight) Should fix https://github.com/DeadlyBossMods/DBM-TBC-Classic/issues/78  
- Auto expand infoframe to 10 on the nine instead of trackig 8 targets only if user manually does it.  
    Fixed bug where yells would still happen over 8 targets.  
- Finally fix a bug where stats and wipe/kill message would be wrong difficulty on classic bosses that have poor wipe detection (no valid encounter\_end event or releasing before it fires)  
- Fix numpty  
- Added support for classic seasons to Unified Core  
- This makes me a little less nervous  
- Bump alphas  
