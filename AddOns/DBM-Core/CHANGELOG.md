# Deadly Boss Mods Core

## [8.2.16](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.2.16) (2019-09-04)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.2.15...8.2.16)

- Prep release  
- scale broker icon to low rez  
- range tweaks  
- Sync  
- Revert "Layout fixes"  
- Revert "Removed Minimap icon"  
- Revert "Missed this"  
- Layout fixes  
- Missed this  
- Removed Minimap icon  
- Couple minor fixes to Ulmath  
- Fix countdown migration function also migrationg users who actually turn countdown off on purpose, back to on default.  
    Instead of doing this, now when existing timers have new defaults added for countdown object, OptionName/OptionVersion should be added to timer object instead. Closes #61  
- Dropdown changes, Fixes #43 (#60)  
    * Commit #1 for Dropdown changes  
    Moving this over into another xml  
    * Commit #2 for dropdowns  
    Updated DropDown xml  
    * And lastly, the Lua  
    Yeet.  
- Fix UI-MinusButton  
- Dungeon renames  
- Fix for RegsiterShortTermEvents (#58)  
    * Fix for RegsiterShortTermEvents  
    Allow us to register events multiple times.  
    * Hmm. This should prevents multiple cases for RegisterEvents.  
- Remove hard embeds and fetch live externals instead  
- Add another user request  
- announce as well  
- Add punctured darkness buff active timer  
- zhCN and zhTW index update for toc file (#57)  
