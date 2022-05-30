# <DBM> World Bosses (Shadowlands)

## [9.2.18](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.2.18) (2022-05-17)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.2.17...9.2.18) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- prep new retail and tbc tags  
- remove aggregation on wicked star, all difficulties now only get 1 at a time so it's no longer required  
- update luacheck  
- Switch night hunter to Melee > ranged / raid roster index icon sorting priority. This will now prioritize melee over ranged, and if multiple melee prioritize raid roster raid index. ranged will also be sorted by raid roster index too.  
- Improve notes  
- Add support for more auto icon localized texts. Renames too so yes every old module is also being updated here in a second.  
- Logic fixes to last and fixes to arg differences on SetAlphaIcon compat  
- Cleaned up new icon code and added more functions. DBM now has an auto object that can set icons using following sorted methods: 1. Setting icons on targets prioriizing melee over ranged, and if multiple melee then prioritizing sorting multiple melee alphabetical 2. Setting icons on targets prioriizing melee over ranged, and if multiple melee then prioritizing sorting multiple melee by raid roster numeric index. 3. Setting icons on targets prioritizing ranged over melee, then if multiple ranged then prioritizing sorting multiple ranged alphabetical 4. Setting icons on targets prioritizing ranged over melee, then if multiple ranged then prioritizing sorting multiple ranged by raid roster index. 5. Simply not caring about ranged or melee and just setting icons sorting them alphabetically 6. Simply not caring about ranged or melee and just setting icons by raid roster index. technically 5 and 6 aren't new features. they've been supported for years but code was cleaned up and streamlined so all 6 of above functions use a single prototype  
- Refine comment and code to show intent, but it's still not done.  
- tweak  
- Update localization.ru.lua (#760)  
    A more correct translation.  
- Bump alphas  
