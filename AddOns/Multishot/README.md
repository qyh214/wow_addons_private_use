# Multishot
Multishot is a WoW addon which could automatically take screenshots under various customizable conditions. 

Use command `/multishot` in game to open the configuration panel.

## Supported Game Version
Only guaranteed to work in **Retail WoW**.

Notes: I don't play any Classic versions of WoW and I don't have any interest or intention to make this addon work in those versions.

## Credits
This addon is a continuation of [Multishot](https://www.curseforge.com/wow/addons/multishot) and was created when the original project lacked maintenance around year 2014. Thanks to the original authors and contributors for all the work they put into the original addon.

## Bugs & Suggestions
I've been posting updates on the Chinese forum NGA since Nov 2014. You can provide feedback on this [NGA page](https://bbs.nga.cn/read.php?tid=7534350) if you want.

Also, feel free to open up an [issue](https://github.com/Nukme/Multishot/issues) here on Github.

## Major updates and fixes
- Add option to auto-screenshot after finishing a Mythic+ dungeon.
- Add option to auto-screenshot after obtaining a Legendary item.
- Remove the functionality to auto-screenshot after killing a rare mob.
- Re-write the logic to auto-screenshot after killing a boss. Instead of examing the NPC_IDs upon unit deaths, the addon now takes in-game event `ENCOUNTER_END return 1` as the mark of the end of a boss fight.
- Record boss kills using ENCOUNTER_IDs instead of NPC_IDs.
- Lua error fixes along the game expansions.
