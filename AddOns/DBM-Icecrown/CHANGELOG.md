# <DBM> Icecrown Citadel

## [r312](https://github.com/DeadlyBossMods/DBM-WotLK/tree/r312) (2023-03-21)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-WotLK/compare/r311...r312) [Previous Releases](https://github.com/DeadlyBossMods/DBM-WotLK/releases)

- Bump toc files  
- Emphasize switch on emalon for dps roles by default with new special announce option  
- Add alert for hard mode  
- Update localization.ru.lua (#29)  
    Brain portal: 3 sec -> 10 sec  
- phase2 boss yell. (#31)  
    * Update localization.cn.lua  
    This is boss yell for phase2 in Simplified Chinese.  
    * Update localization.cn.lua  
    This is boss yell for phase2 in Simplified Chinese.  
- Add malady yell for those that process bubbles better than alerts  
- make brain portal soon a 10 second prewarn  
- fixed bug where animus timer didn't stop when saronite vapor dies  
- few other tweaks to Coliseum  
- Anub'Arak Update  
      - Fixed bug where penetrating cold announce options would only work if raid leader was one setting icons. Now, it'll work regardless of who sets icon (but still only be announced by raid leader)  
      - Penetrating Cold will also now announce affected targets (on by default forhealers)  
      - API will now track phases for things such as weak auras or just wipe/status messages  
      - Pursuit icon will now be removed more reliably	789d1c  
- Anub'Arak Update  
     - Fixed bug where penetrating cold announce options would only work if raid leader was one setting icons. Now, it'll work regardless of who sets icon (but still only be announced by raid leader)  
     - Penetrating Cold will also now announce affected targets (on by default forhealers)  
     - API will now track phases for things such as weak auras or just wipe/status messages  
     - Pursuit icon will now be removed more reliably  
- disable the frost bomb timer on mimiron, it's not time based, it's flame cluster based (it fires when flames hit a threshold)  
    Adjusted initial shock blast timer of P4 timer as well with a new lower time seen in fresh log  
- move ICC target scans to use GUID instead of CID, since it's a faster code path. CID really shouldn't be used anymore.  
- No longer require boss to be targetted for overload, and use modern api instead to warn if within 23 yards of caster (range is 20 but 23 is closest available to retail and classic)  
- fixed configuration glitch for yogg icon options all using same spellId  
- Tweak option defaults for plasma blast to include healers  
- try to fix persuit special alert not working  
