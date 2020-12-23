# Deadly Boss Mods Core

## [9.0.12](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.12) (2020-12-22)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.11...9.0.12) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Fix incorrect voice with one that's slightly less incorrect  
- Sync some bug fixes into mainline sire, but with mythic specific code stripped out  
    Prep new release for new raid week  
- Unfuck phase 2 timers  
- Fix a big fuckup  
- Fixed a bug that caused wicked blade icons never to reset and timer not to show on normal difficulty generals  
- Add berserk timers to generals  
- Generals Update:  
     - Updated timers per Dec 18th hotfixes to some of them  
     - Changed default icon options and icon usages to be more compatible with heart rend+add marking strategy, OR target mechanics+ add marking strat. Whichever you choose.  
     - Fixed an issue where the mythic adds timer could start if adds popped out at same time as shield going up, causing you to have an invalid initial adds timer for a phase that doesn't have skirmishers  
     - Fixed initial mythic timers, which differ from non mythic  
     - Fixed a bug where wicked blade timer incorrectly reset between phases. it never resets, ever, for entirety of fight, same as crystalize.  
     - Fixed a bug that caused the Heart Rend target announce to never show  
     - Changed heart rend timer to sync up to cast START instead of cast success  
     - Changed most timers and warnings to have count in them  
     - Updated Wicked Slaughter timer, which is shorter on live vs beta  
     - Added new optional special warning (off by default) to run to crystalize target when it goes out, if you have bleeds on you that need clearing.  
     - Added new optional special warning for when heart rend is being CAST (also off by default)  
     - Added optional off by default warning to auto assign mythic eruption soaks to the players that spawned them. Don't enable if your strat is to assign custom assignments  
     - Added a new Spell queue detection feature that automatically adjusts all boss timers during fight whenever ability casts cause other ability casts to get delayed. This will actively and fluidlly keep timers up to date even in the worst of spell queue situations.  
- Update localization.cn.lua (#449)  
    * Update localization.cn.lua  
    * Update localization.cn.lua  
- Update zhTW (#446)  
- Update GUI zhTW (#447)  
- Update koKR (#444)  
- Make boss preview 300x300 (#443)  
    This makes mobs actually RENDER properly, without cutting their heads off.  
- Tell GUI to ignoreCustom (#442)  
    * Tell GUI to ignoreCustom  
    * And here too  
- Also changed Drain fluids to be off by default based on feedback.  
- Now that Altimor isn't broken, fix P4 sinseeker timer on mythic  
    Also removed bad taunt warning in spires of ascension.. that mechanic doesn't seem to exist anymore  
- Added two special warnings for both add switches on Council of Blood  
    Added likely respawn time to sludgefist.  
- Actually show the count in the gaze and slam warnings  
- Updated zhTW (#441)  
- Proper syntax for failures. (#431)  
- Mod profile import/export (#440)  
- Fix two stupid  
- Fixed a bug wehre chain link warning never actually gave you partner name when it was supposed to  
    Disabled sinseeker timer for phase 4 mythic since it doesn't get cast in P4?  
    Made lady inerva personal warning for shared suffering 1 second faster  
- Support for CustomSounds (the hacky way of installing sounds) (#439)  
- Fix regression issue properly (#437)  
- Tweaked altimor sinseeker timers now that some longer lasting pulls exist on WCL  
    More aggressivevly restore sounds on login if option to disable them exists. Wouldn't want blizzard to delete that setting from the game too  
- Update zhTW (#436)  
- Blizzard apparently killed off ability to hide quest tooltips in 9.0, so disabled from DBM as well.  
- Fix typo  
- Fixed a serious regression that causes core to spam lua errors when playing sounds.  
    Fixed a bug on sludgefist where the seismic timer would keep on keeping on when it ran out of sequenced timers. now it'll cleanup when it reaches end of timer table.. still need to fix actual missing timers.  
- bump alpha revision  
