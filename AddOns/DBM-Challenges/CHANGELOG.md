# <DBM> Challenges

## [r148](https://github.com/DeadlyBossMods/DBM-Challenges/tree/r148) (2022-04-09)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Challenges/compare/r147...r148) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Challenges/releases)

- micro optimize. This will keep event handler from running in unneeded zones  
- update luacheck  
- This fixes healer mod  
- tweak last. kills should still have some recombat protection, wipes also raised to 3 seconds to allow some time for bosses to fall off boss health frame  
- Set recombat time to 1 on all mage tower mods,, so they don't fail to re-engage if you jump back in immediately after a wipe.  
    Fix healer engage code, it will work once core is fixed, gave it some debug since it's ideal mod for testing core for now  
