# <DBM> Dragon Soul

## [r201](https://github.com/DeadlyBossMods/DBM-Cataclysm/tree/r201) (2019-08-21)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Cataclysm/compare/r200...r201)

- Completed voice pack support for firelands  
    Fixed a few timers not yet assigned color types or inline icons  
    Fixed a few spam situations with redundant warnings.  
    Eliminated custom target scanner code from Shannox, and use Cores built in target scanner (which ironically, is based off the shannox target scanner :D )  
    Changed some icon usages to fit more in line with current standards (using lower index, and keeping hands off upper index if it can be helped, so marks like x and skull can be used for actually marking kil prio)  
- Add bethtilac's berserk timer, thanks to improper scaling for large TW raids causing fight to be undoable for 30 players. :D  
- Improve trash interrupt warning for firelands  
    Added voice pack support to all trash warnings in firelands  
    Resorted mod function orders to conform to consistency. Boss mod order should be primary events (triggers, phase changes spawns etc) which are tied to success and start events, followed by secondary events (debuffs, personal warnings etc). this is more logical than alphabetical event order old mods used.  
    Added parsing expressions to all firelands mods so it can speed up log crawling when public logs of TW become available.  
- First pass on firelands for code cleanup, code prep for timewalking, and object upgrading to eliminate unneeded local  
    More to do, but little at a time.  
- Include project version in toc  
- adjust packager call  
- move to the BigWigs community packager  
