# <DBM> World Bosses (Dragonflight)

## [10.0.20](https://github.com/DeadlyBossMods/DBM-Retail/tree/10.0.20) (2023-01-17)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/10.0.19...10.0.20) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- prep new retail tag  
- Raszageth Update  
     - Fixed a bug where initial timers where showing LFR/Normal timers on all difficulties. Mythic and Heroic timers on engage will now show correctly.  
     - Fixed a bug where an extra storm surge timer would start in P2 for a 4th stormsurge that wasn't possible to happen.  
     - Added additional P3 timers for normal and LFR difficulty  
     - Updated Lightning Devastation timers for normal and LFR difficulty  
     - Enabled phase duration timer for phase 2 , it should be accurate for most part in non mythic difficulties.  
- Timer updates for LFR Broodkeeper  
- bump alphas  
- prep new tags for wrath classic and classic era, retail's new tag on hold until LFR wing 3 can be logged at (LFR raszageth was never tested,, so it's gonna need updates first)  
- Fixed a few unregistered events that caused following things not to work  
     - Empowered storm was broken do to invalid spellid on Strunraan  
     - Rending bite timer/alert never worked on Broodkeeper  
     - Add auto marking never worked on Dathea  
     - Flame Smite alert never worked on Kurog  
     - Scattered Charge alert never worked on Raszageth  
     - Lighting strike alert/timer never worked on Raszageth  
     - Wrapped in Webs alert didn't work on LFR/Normal Sennarth  
     - Reflections alert didn't work on aniversery Azuregos world boss  
- Brawlers guild: no idea what was going on here or what this will break, but it'll fix another thing. these mods were made so long ago  
- Fix last  
- code cleanup  
- Fix bug where no clear yell was showing if you got negative charge with the new antispam code  
- Fixed a bug that causd empowered great staff warning/say to never work in p2 broodkeeper. How do bugs this obvious take months to get reported. Either everyone using DBM is only 6/8 or they just don't care when it's broken. :\  
- Comment cleanup  
- Even more anti spam against player clearing thundering  
- Fix German localization for roleplay timer text (#177)  
- Fix lightning crash on Kurog, which was apparently redesigned at some point to not have a 4 second pre targetting debuff and never knew because no one reported it hasn't worked in weeks.  
- Fix cast time in blowback alert  
- Update localization.cn.lua (#175)  
- Update commonlocal.cn.lua (#176)  
- Fix some minor debug errors with deleted journal entries  
- Update koKR (#174)  
- Fix sundering crash again, update timers for Basrikron  
- bump alpha  
