# Deadly Boss Mods Core

## [8.3.21](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.3.21) (2020-05-02)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.3.20...8.3.21)

- Ok, now prep a retail release, should fix the WowI problem too  
- Revert "Prep new classic tag"  
- Prep new classic tag  
- Only set close player text when it's actually shown, to avoid nil errors and also to not waste cpu  
- Updated Shreikwing mod with two new abilities added in build 34199  
- Renamed Dredger Giant to Sludgefist  
    Added Stoneborne Generals and The Council of Blood now that they have journal entries.  
- When wrong version of DBM is installed, don't just display message once at login. display message every 15 seconds, indefinitely, until incorrect version of DBM is uninstalled.  
- missed a couple  
- Fixed a bug that caused radar not to display first decimal place when more than 1 person was in range  
    Changed measurement indicator from d back to y in english and m in all other languages. TODO, check region instead. if region US then y else m, regardless of language.  
- Updated Lord Chamberlain from logs, removing infoframe for stacking debuff they appear to have deleted, added very preliminary timers (pull too short) and fixed a missing spellId  
- KR Update (#178)  
    * KR Update  
- Updated first 3 bosses of Halls of Atonement from logs. few events/spellIds fixed. some timers added, others disabled do to insufficient data to substanciate they even have timers.  
- The rest of Sanguine Depths drycoded  
- Drycoded first two bosses of Sanguine Depths dungeon  
    Drycoded Shriekwing (first boss) of Castle Nathria raid  
- Added Mordretha drycode to Theater of Pain  
- DBM Timer Update  
     - Improved the DBM-GUI bar setup UI with better organizing of options  
     - Improved labeling each dummy bar with an appropriate bar label for each instead of all of them saying "dummy"  
     - Added a large bar example right next to small bar example in the part of timer GUI for configuring appearance options, so you can more visibly see how appearance options affect the two bar types.  
     - Added a user requested new option to change Start/End color to apply those colors to small/large bar types instead of being used as an animated color fade. This will allow users to setup bars in more ways (such as making small bars red and large bars blue if they wish)  
- Sync boss names/order to current journal build  
- Kul'tharok Drycode added to Theater of Pain  
