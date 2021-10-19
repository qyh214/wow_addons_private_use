# <DBM> World Bosses (Shadowlands)

## [9.1.18](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.1.18) (2021-10-12)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.1.17...9.1.18) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- Prepare for new release  
- Fixed non mythic timers for hammer and scythe on painsmith, they were nerfed at some point and wasn't reported til now. Axe remains unchanged.  
- Don't register IEEU in classic flavors  
- Cleanup. it passed every test i threw at it though.  
- More fixes  
- Push bugfixes thus far  
- Send the object rather than the frame, woopsie  
- Fix event handling in modules  
- what I have so far  
- Fix misnamed variable in Module.lua  
- Fixed a bug where icon debug always said icon setting failed for invalid units.  
    Fixed a bug where debug invalidly reported non updated varaibles  
    Added additional debu to diagnose why scanformobs isn't working yet  
- sync up casin  
- ScanforMobs arg cleanup  
- cannon timer now off by default since a buff timer confuses people  
- Fixes  
- Update koKR (#14)  
- Migrate icon functions into module  
- Basic module system prepped for work  
- Fix numpty  
- Made guessing game icon marking off by default, by user request  
- cleanup  
- reaper icon setting, take 215215  
- Acount for arena unit ids  
- Lets attempt icon validation that just continues loop if SetRaidTarget fails....it's too bad SetRaidTarget doesn't havea  2nd arg for success for when api is broken.  
- And do this cleanup too.  
- Allow faster world boss mod loading by supporting nameplate added event  
- update luacheck  
- incriment alpha version  
