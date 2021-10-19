# <DBM> Dragon Soul

## [r214](https://github.com/DeadlyBossMods/DBM-Cataclysm/tree/r214) (2021-10-11)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Cataclysm/compare/r213...r214) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Cataclysm/releases)

- updated scanformobs  
- prune a redundancy  
- Update Blackhorn.lua (#11)  
- Actually register the event for combat timer  
- *Blackhorn Update  
     - Fixed bug where  combat detection stopped working (ship no longer fires IEEU on RP start). This means the combat start timer now has to trigger off localized text though which means it's no longer available in all langauges.  
     - Also fixed a bug where blade rush timer stopped working because at some point (likely in a performance optimisation pass) an invalid unit ID was added (boss1) to UNIT event, which the adds would never have. In fixin this, also added protection against timer showing for people in group but outside the raid  
     - also pruned unneeded localisations  
- some cleanups and fixes, because ugly  
