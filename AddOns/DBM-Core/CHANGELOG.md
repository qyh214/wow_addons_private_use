# Deadly Boss Mods Core

## [9.0.2](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.2) (2020-10-20)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.1...9.0.2) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new release  
- Finish the unfinished stuff in Sanguine Dsepths  
- Update version check  
- Missed one replaccement  
- Reworked Council of Blood mod with changes from latest build. A lot of abilities removed and added, therefor status of this mod has been changed from done back to bet since it needs to be retested  
    Fixed a missed nameplate line usage on ghuun (was harmless but injected extra args and table for no reason)  
- Code cleanup and security improvements on TimerTracker handling to prevent abuse (accidental or intentional) that would cause BG or M+ timer objects started by blizzard to break. Now, if an M+ or PvP timer already exists, pull timers from DBM will no longer start TimerTracker countdown objects.  
     - In addition, another update was made to fix a niche condition for M+ where players like to do a 10 second pull timer first before activating keystone, and then after loading screen Obviously blizzard starts their own M+ timer. Blizzard added a conditional to TimerTracker code on their end that says "if a timer is already running, don't start another one". This was causing M+ blizzard timer not to activate correctly if even a fraction of a second was left on DBMs pull timer when keystone was activated. Now, any time a loading screen is triggered, DBM will wipe out TimerTracker objects that have countdown type to ensure that when blizzard runs their type 2 timer (M+), "already running" abort conditionn would be false.  
- Es update  
- Fixed regression to RU translations that caused them to completely erase english tables instead of doing table replacements. This was causing lua errors or missing auto translations on warnings/timers that weren't yet translated into Russian  
- We can fix PvP timers, right? :P (#369)  
    All timers are handled via PvPGeneral mod.  
    Any which aren't (e.g. silvershard mines), use math rather than events to calculate their time, so don't need a resync.  
- Fix #367 (#368)  
- Forgot to bump version for next alpha cycle  
- Some short term changes to TimerTracker handling in PT to reducce chance of taint as well as change to type 3 so texture overwriting no longer required. This will likely be changed up again in future to possibly migrate to blizzards countdown timer once it is able to accomidate some needs  
