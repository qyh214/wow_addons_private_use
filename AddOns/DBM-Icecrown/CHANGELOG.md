# <DBM> Icecrown Citadel

## [r294](https://github.com/DeadlyBossMods/DBM-WotLK/tree/r294) (2020-06-11)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-WotLK/compare/r293...r294)

- Fix algalon, he's disabled in timewalker difficulty so he shouldn't have TW stats  
- Update LuaCheck to find broken stuff  
- Sync editorconfig from DeadlyBossMods  
- Ulduar Update:  
      - Changed all icon and range options to newer object types, so they don't require manual localizing and honor the global disable options.  
      - Updated some target warnings that shouldn't be filtered to use the no filter object.  
      - Fixed some bugs where some icons wouldn't get removed at all (or not as fast as it should be)  
      - Fixed two cases where it was possible icon option would attempt to set icons that can't be set (if people clump up and get too many debuffs)  
      - Fixed a bug where Voice pack warning filter wasn't applied correctly and would instead cause a lua error for Brain link special warning on Yogg  
