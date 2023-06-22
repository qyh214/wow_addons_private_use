# <DBM> World Bosses (Dragonflight)

## [10.1.12](https://github.com/DeadlyBossMods/DBM-Retail/tree/10.1.12) (2023-06-06)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/10.1.11...10.1.12) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- Prep new tags for all flavors to start the new week with soundkit to file data Id migration and better private auras code for retail players  
- extra unschedules for good measure  
- Revert "tweaks to afflicted timer"  
- tweaks to afflicted timer  
- tweak last to account for niche cases (like player clicking off the timer)  
- Further enhance testing of afflicted and incorp timers for users in debug mode til proper testing can be done on it. the rest seems sound for now to do general release  
- Massively improve afflicted alert and timer  
     - Alert now uses new voice like "help spirit" for voice packs  
     - timer now pauses when leaving combat and resumes when entering combat. In addition, timer will loop in combat if a set of ghosts is skipped (ie the 60 second timer insteadof 30)  
- Further refine Magmorax code  
- Improve swap code for Magmorax to swap every 1 as long as debuff is expiring before next cast  
- Work around niche case doubel soak can cause problem from it's intended behavior  
- timer option too  
- disable trash timer for now, something is wrong with it and needs more investigating  
    tweak a basrikron timer too  
- Fix at least one case that'd cause private aura sound not to play  
- Update localization.ru.lua (#227)  
- Update localization.cn.lua (#904)  
- honor voice pack global disables by sound ID in the private aura object  
- Cleanup some minor warnings on namings  
- change option text since sound now configurable  
- fix alignment.  
- fix lua errors but not actual alignment issues  
- add some default sound Ids  
- Completely switch over to file data Id from soundkit. There may be bugs.  
- A little post tier cleanup  
- Improve taunt tech on rashok to not show two taunt warnings at same time if two conditions are met within 1 second of one another (ie spell aura applied event and spell cast start event 0.01ms apart). both conditional checks still run, but if both pass "this is a taunt" only one of them will be shown.  
- Just some tuesday reset Aberrus updates  
     - Fixed bug causing infused stacks to not alert on Experiments  
     - Increased aggregation window for rays of anguish to 1.1 seconds to try to get all targets bundled together  
     - Added knockback voice pack alert to Opressing Howl on Scale commander  
     - Changed tank voice pack sound on Echo of Nelth from "defensive" to "knockback" alert  
     - Refixed P3 timers again for echo, which seem to have reverted whatever they did last week. Plus they tweaked some other timers to reduce spell queues slightly.  
     - Added Dark binding personal alerts and chat bubbles to Trash mod  
     - Added Brutal Cauterization interrupt warning to trash mod  
     - Added Brutal cauterization CD timer (with plater nameplate aura support) to trash mod.  
- Fix bug causing afflicted timer to get stuck due to args in wrong order in timer object  
- bump alpha  
