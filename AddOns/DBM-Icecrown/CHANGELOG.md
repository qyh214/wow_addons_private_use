# <DBM> Icecrown Citadel

## [r295](https://github.com/DeadlyBossMods/DBM-WotLK/tree/r295) (2020-08-06)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-WotLK/compare/r294...r295) [Previous Releases](https://github.com/DeadlyBossMods/DBM-WotLK/releases)

- Show everyone on yogg infoframe now that column support should make it more view friendly  
- Disable LE and NUM\_LE in all luachecks  
- Purge all unnesseary SetZone calls  
- Apply onlyHighest to valithria  
- Update luacheck  
- Sync GTFO change from classic  
- Yuck, this original mod used spaces instead of tabs. I'm not gonna fix entire mod, just part travis is bitching about  
- Changed grip warning to no longer use a table or scheduling, it's now only 1 target at all times per June 30th hotfixes. old code was left in though (commented out) because it will be used again probably 3-4 years from now when classic WoTLK is a thing.  
    While at it, also fixed crunch armor to be a stack warning and not a filtered target warning and made it more useful as well with tweaked option defaults  
- Update Thaddius.lua  