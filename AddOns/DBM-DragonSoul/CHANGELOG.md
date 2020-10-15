# <DBM> Dragon Soul

## [r210](https://github.com/DeadlyBossMods/DBM-Cataclysm/tree/r210) (2020-10-13)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Cataclysm/compare/r209...r210) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Cataclysm/releases)

- Bump TOCS  
- Fixed a bug  luacheck didn't find  
- Fix last  
- Drycode automatic timer updates off boss energy to bethtilac as well as allow partial spiderling string matching  
- Fixes  
- Ragnaros Update:  
     - Hopefully fixed a bug with phase detection (and thus a lot of timers and such) would break if Splitting bow was triggered on pull, but the event fired before ENCOUNTER\_START.  
     - Fixed initial phase 4 heroic timers, which changed when blizzard revamped zone for timewalking apparently  
     - Fixed bug where engulfing flames timers would show on heroic, when heroic should only use the world in flames timer.  
     - Fixed seeds to finally use spellID and not inefficiently request spell name on all boss unit events for spell name matching.  
     - Fixed a bug where the engulfing flames special warning would not show for melee if the position warning filter was enabled for engulfing flames  
- Adjust first cataclysm timer on Alysrazor  
- Bandaid bethtilac for now.  
- Fixes to ragnaros, Rhyolith, and benthilac  
- Fixed phase change timers to cancel previous phase change timers so they don't throw debug code from rapid kills  
- Fixed hatch eggs timer firing twice  
- Merge pull request #4 from DeadlyBossMods/stats  
    MinExpansion  
- MinExpansion  
- Merge pull request #3 from DeadlyBossMods/stats  
    stats  
- stats  
- Possibly fix premature combat end on ragnaros, or this doesn't change anything at all, hard to say without knowing cause.  
