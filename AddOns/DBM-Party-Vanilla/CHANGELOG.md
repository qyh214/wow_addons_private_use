# DBM - Dungeons, Delves, & Events

## [r247](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r247) (2026-04-29)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r246...r247) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Correct wrong KR name (#600)  
- always use fallback, even in debugmode  
- Fixes  
- Switch Lumbering fixation to full special warning object  
- forgot to add hardcode object  
- revisions to apis  
- enable pit of saron hardcodes in all difficulties  
-  - Lura's Discordant beam will now use a full special warning personal alert instead of private aura, enabling text alert, custom text, and UI flash when you're targetted  
     - Muro'jin's Carrion Swoop will now announce target name  
     - Derelict Duo's Heaving Yank will now use full special warning personal alert instead of private aura, enabling text alert, custom text, and UI flash when you're targetted  
     - VIryx's Cast down will now announce target name  
     - Garfrosts Orebreaker will now use full special warning personal alert instead of private aura, enabling text alert, custom text, and UI flash when you're targetted  
- remove 12.0.1 toc, take 2 (CN and KR updated now)  
- Update all dungeon hardcodes to check if user actually has DBM bars enabled and use timeline fallbacks immediately if they don't, so they still get audio countdowns and custom colors on timeline api.  
- Cleanup debug prints on zuraal by ignoring 2 placeholder timers and canceling other abilities when their timers get updated due to spell queuing.  
