# Deadly Boss Mods Core

## [9.0.19](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.19) (2021-01-27)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.18...9.0.19) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- final mythic review of generals complete, it looks solid now. Prepping new release  
- removed infoframe from non mythic hundering destroyer  
    Removed invalid timer on Doctor Ickus  
    Possiby fixed timer on stradama? if not, at least made it more likely to kick out debug  
- Fixed some minoir timer bugs on altimor and fixed some major timer bugs on lady inerva (at some point blizz removed generic container events and added new specific ones, and of course didn't communicate it so mod could be updated when this happened. No idea how long this mod was broken)  
- Preliminary generals fixes  
- stupid shift key  
- Generals mod now stops all timers on phase change. Doesn't start new ones either since those aren't known yet. Some templating done to try and get fixes out quicker tomorrow.  
- Fix last  
- Fixed a regression where ResetAnimations would apply bars to the huge anchor even if it was disabled  
- Several miner timer adjustments in dungeons  
- VERY aggressive retesting was done on bar updating under all animation conditions and this seemed to cure problem. Previoux fix was right, it needs to run as it was before todays earlier modification. that modification made it worse. What was missing is bar sorting itself running during "move" event, when the move event was aborted by a timer update/restart  
- Add another test condition  
- only run the hacky fix I added to DBT on :Update calls. in start calls it might cause problems since Start already calls ApplyStyle and append, which can cause bar to be double appended (thus resulting in an error that it's trying to append bar to itself)  
-  - Cleaned up unused stuff on shriekwing  
     - Fixed chain link starting on LFR difficulty sludgefist  
     - Updated some LFR difficulty sludgefist timers. he gains energy a little slower there  
     - Fixed LFR timer update functions on generals to not keep starting an invalid eruption timer. LFR doesn't have eruption  
     - Added the correct LEAP timer to LFR instead and appropriate update functions now tied to it as well, improving the updating of other spells  
     - Also added warnings/SAY bubbles for LFR version of leap as well.  
     - Again fixed countdown defaults on crystalize and eruption. This was meant to be off by default, and I thought i fixed that then reset defaults, instead I reset defaults and ended up re-enabling them for everyone in last fix attempt. Sorry about that. THIS attempt should make countdowns OFF by default. Countdowns on this figh are counter intuitive.  
     - While at it, fixed a bug where the brief period of time one boss is dead and other isn't at end of fight, the timer update functions could still respawn timers for dead boss. This will no longer happen  
- Updatet the automatic special warning downgrading to also remove screen flash on downgraded special warnings  
- Bump alpha  
