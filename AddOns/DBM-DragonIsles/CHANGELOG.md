# <DBM> World Bosses (Dragonflight)

## [10.0.23](https://github.com/DeadlyBossMods/DBM-Retail/tree/10.0.23) (2023-02-02)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/10.0.22...10.0.23) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- Fix a regression (from when icons were changed to match other mods) that caused broodkeeper to never mark more than one mage  
- prep tags  
- Allow core to seemlessly switch to gossip index if gossipID missing  
- Bump mod HF revision  
- actually also scrap this warning entirely, it's also too spammy  
- address even more massive amount of spam on broodkeeper  
- also distance filter scope two of adds abilities to further reduce spam if adds are far away and not your problem  
- massively increase alert aggregation due to excessive alert spam on broodkeeper (that agian wasn't reported)  
- remove unused warnings/options  
- Update koKR (#179)  
- Update localization.ru.lua (#178)  
- disable manual calls to collectgarbage due to a 10.0.5 bug where manually calling garbage collect actually causes natural GC to cease working and instead leak memory like mad. It'll result in a briefly high memory usage report after loading mods, but it'll eventually clear out from non broken automatic GC, it's not urgent to purge it right away and was purely for cosmetic/reporting reasons anyways that we did this.  
- more tweaks to resolve more potential for mod conflicts/squelching that was unwanted  
- also cleanup unused this season  
- This is a bug at least, fixed a bug where thundering count didn't reset on new thundering, if a trash warning from another mod recently used same antispam ID.  
- more safety for good measure  
- debug  
- Scrap lightning crash icon options since it never worked anyways, and change yells to use non icons  
- Announce mark cast with count when each set goes out  
- Very tiny tweaks to add timers  
- bump alphas  
