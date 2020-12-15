# Deadly Boss Mods Core

## [9.0.9](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.9) (2020-12-15)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.8...9.0.9) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Fixed feeding time before tagging  
- Fix obvious error and bump version  
- Fixed a TON of bugs with artificer Xymox that caused a lot of timers not to work correctly at all. Also updated some timers that changed since beta.  
    Added bird auto icon marking to Kael and fixed it so mod will announce them rezzing now. Also removed the non working nameplate aura for birds recharging, since they have no nameplates when recharging  
- Test a fix for variable dance durations on the timer correction code  
- Activate the type 0 spawn timers after all. blizz IS using them. Mod will now start initial timers for kael, but then overwrite them with type 1 timers if darithos dies and overwrites the 0 timers.  
    Bumped HF versions of 2 other updates from earlier  
- Castle Update  
     - Applied short name text to timers and warning across entire zone where the short name made most sense  
     - Shortened yell tet for Sinseeker on Altimor  
     - Fixed icon option on Hungering Destroyer for Volatile Ejection to NEVER touch icons set by Miasma. Now, if a miasma target gets ejection, the icon will not be changed  
     - Further shortened Miasma chat bubble (if turned on, it's still off by default)  
     - Fixed a bug on Inerva where the interrupt warnings were missing the cast count.  
- Added Coalescing timer to Muehzala, which was missing somehow.  
- Update zhTW (#422)  
    * Update zhTW  
    * Fix issue.  
    Co-authored-by: QartemisT <63267788+QartemisT@users.noreply.github.com>  
- Update localization.cn.lua (#423)  
- Change rip soul to a target warning so it can provide context/target name  
- Fix typo  
- Add last remaining feature requested  
- Apparently I straight up forgot to finish Executor Tarvold mod. I literally had a warning started that wasn't hooked up to anything. Anyways, fixed it so now Castigate should have better warnings.  
- Kael Update  
     - Some minor timer updates  
     - Upgraded Blazing Surge from a regular warning to special warning  
     - Enabled Concussive smash timer (may need testing)  
     - Added optional Feiry strike special warning (off by default). In addition, also added a general announce for it that's on by default for melee (although if you turn special warning on the general one is surpressed of course)  
    Hungering Destroyer Update  
     - Added optional off by default pre warning for volatile injection that announces beginning of cast. Some players wanted to know when to early spread evev though you don't know who victims are until cast finishes.  
- Fixed a bug where the icon option for setting icon on dutiful might throw a lua error instead  
    Fixed ravenous feast timer on generals, it's much shorter now.  
    Fixed spell name for Chain slam general target warning.  
    Added edge of annihilation cast timer to artificer and changed glyph of destruction target timer to on by default for everyone.  
- Fixed pkgmeta  
- Misc Castle Updates  
     - Added target timer for tank explotion to artificer for healers and tanks by default  
     - Fixed a bug where tank debuff yell countdown didn't aborb if player died before it finished as well  
     - Added optional soak special warning for bottled anima (off by default). can be turned on for a more prominant warning and customizing sound.  
     - Added icon marking for dutiful spawn on council of blood  
     - Drycoded more suspected (and confirmed) mythic mechanics into Sire mod  
- Shorten all position yells on Sire to just be "SpellName <number>"  
- Fixed a bug where Cadre was using an AI timer instead of the better hard coded timer it already has  
    Added a general count announce for drain essence that's on for healers by default  
- Made melee check slightly more robust. It'll at least pick up balance druids temporarily shifted into bear/cat form, but only if lunar power > 0  
- Made boss health checking more robust against nil errors if cached health value isn't set correctly or doesn't exist yet.  
- Bump HF and sync revisions on last  
- Hungering Destroyer  
     - Fixed issue where miasma marker might try to set star on multiple melee  
     - Also fixed issue where star would get assigned to no body (and instead an icon that option isn't supposed to use, gets used instead) because there are no melee selected by miasma  
- Fix  
- Actually fix the original issue (#415)  
- prep next dev cycle this time, forgot to with last one and every alpha was flagged as a release version, oops.  
