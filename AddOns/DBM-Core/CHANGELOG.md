# Deadly Boss Mods Core

## [8.3.20](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.3.20) (2020-04-19)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.3.19...8.3.20)

- Prep new retail core as well  
- Fixed a bug on mechagon trash where dispel warning for suffocating smog lacked target name  
    Added 2 more dungeon drycodes to Theater of Pain  
- Updated Boss Names for Devos Shreikwing, and Alee  
    Added mod drycode for "A Front of Challengers" dungeon boss  
    Fixed bug on Kin'Tara drycode  
- KR Update (#174)  
    * KR Update  
- Revert an unneeded change, NORMAL\_FONT\_COLOR isn't going anywhere, it was just moved from Constants to SharedConstants  
- Revert UNIT\_HEALTH change on carapace for now, since it relies on accuracy and UNIT\_HEALTH doesn't have that on live, not til 9.0  
    Couple more dungeon drycodes  
    Some improved debug on all target scanner drycodes  
- Fix a bug that caused brutal smash special warning (when enabled) not to work. Closes #173  
- Couple more Dungeon boss drycodes  
- KR Update (#171)  
    * KR Update  
- Begin prep work on Castle Nathria  
- Slight drycode tweak to stichflesh based on what i saw on streams. Cant confirm spellID though without trancsriptor log though.  
- I lied, 2 more dungeon bosses drycoded and ready. 11 others with updated creature Ids as wowhead's data improves  
- Push just a couple more dungeon boss updates then take rest of night off, hit it harder tomorrow.  
- Fix bug with assignment of shadowlands party mods that caused them to appear in wrong mod cat.  
    Added drycodes to first two bosses of Plaguefall dungeon.  
- Preliminary drycoded warnings/timers/features for Halls of Atonement. This one will need a revisit when updated build ships that fills in some of the blanks on these fights.  
- Update Luacheck  
- Fix error in last  
- Push a few more Core and GUI fixes for Shadowlands  
- Fix bug with deleted line and removed some completely useless debug code and instead add better debug code to help find that kind of bug faster going forward  
- Update pkgmeta so shadowlands dungeon mods are included in packager  
- Update luacheck to accept EXPANSION\_NAME8 so it doesn't build fail for it :D  
- Missed DBM-GUI in last  
- Shadowlands Update 1  
     - *Worked around a crash bug in alpha client that causes it to crash when PlaySoundFile api is used. This is temporarily disabled in DBM (which will cause a lot of features to just not work like audio countdowns and custom sounds, but better that then frequent crashes. This work around will be removed when blizzard fixes the bug. They've been made aware and in fact have already fixed it internally, we just have to wait til next alpha build).  
     - Updated DBM-Core to support Shadowlands mod category  
     - Added full drycoded support for The Necrotic Wake dungeon preliminary warnings, AI Timers, and other features  
     - Added basic support for EVERY other 5 man dungeon boss in Shadow lands with basic support for combat detection and stats (Warnings will be populated over coming days/weeks)  
- Fix last  
- Updated difficulty mapping for shadowlands  
- Change UNIT\_HEALTH\_FREQUENT to UNIT\_HEALTH  
- Fix megadrill as well on mechagon trash  
- Fixed incorrect warning being caused by process waste cast on mechagon trash  
- Update heroic timer data for Nzoth thought harvesters  
- Fix one more replacement  
- Also fix the api glitch too, so apparently it won't work at all this year :\  
- Fixed some name replacements i missed, which sadly won't show for most til next year  
- Changed touch of corruptor timer to expire on SPELL\_CAST\_START instead of SPELL\_CAST\_SUCCESS on Ilgynoth. Some would prefer to know when cast starts vs when debuffs happen.  
- Tweak an option default  
    Updated BW version check since I haven't been remembering to do that lately  
