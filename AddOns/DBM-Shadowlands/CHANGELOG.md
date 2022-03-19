# <DBM> World Bosses (Shadowlands)

## [9.2.7](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.2.7) (2022-03-15)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.2.6...9.2.7) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- prep new tag for retail  
- Hal Update  
     - Finish hal mythic timers for intermission 2  
    Jailer Update  
     - Fixed bug where torment would throw lua errors when starting timers  
     - Refixed p3 torment timer support to use the p3 ID that I missed (since it wasn't translated on WCL)  
     - Fixed Chains of oppression to be correct warning type in addition to removing useless target warning since it targets everyone.  
- Fixed some bad object spellids that caused some warnings and timers to display completely wrong spell on guardian and lords of dread  
- Fixed a bug where Ascensionscall timer was using same spellId as humbling strikes, causing it to actually overwrite it, this likely caused settings to be completely ignored but also it actually caused both timers to be busted this entire time...crazy how no one noticed til today :o  
- Disable other NoSortAnnounce for now, since current code doesn't favor that actually lookin good, fortunately very few would be disabling group by spells  
- Re-enable second relciaim timer, which has now been confirmed as an accurate guess.  
    Improved crushing prism announce to now give target names, since targer warning was originally from when mechanic targetted half the raid, now it targets 3 people.  
- Added additional race condition checks to avoid lua errors when users disconnect/reconnect mid fight.  
- missed an old entry  
- cache initial difficulty values from core itself until timer recovery has completed. this should be right most of time.  
- Add jailer P3 heroic timers and fixed a bug where torment timer was missing in P3 (because torment cast success only appears in combat log in p1 and 2 only, in p3 it's missing?)  
- missed a decimator timer  
- Fix some errors  
- Some tweaks to omythic halondrus, such as better option defaults, and better initial timers and intermission 1 timers  
    Bug fix to jailer that caused phase 3 detection not to work at all  
    Phase 1 and 2 heroic timers also added to jailer since they radically differ from normal mode. P3 is pending data.  
- Lihuvim update  
     - Fixed bug where mythic berserk on was wrong  
     - Added the alignment shift timer too, which I thought was already there, my bad.  
     - Added whether an alert is a grip or a push to cosmic shift alert on mythic, including new voice pack support for it.  
- Update commonlocal.ru.lua (#83) Add one phrase. Small cleaning.  
- Update koKR (#84)  
- Apply several short text phrases to timers yells and alerts  
- Add count variant of tank combo  
- swear i copy/pasted that  
- set new alpha revision  
