# Deadly Boss Mods Core

## [8.2.29](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.2.29) (2019-11-22)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.2.28...8.2.29)

- Some mythic testing tweaks and bump version  
- Fix error  
- Miner timer tweaks  
- KR Update (#90)  
    * KR Update  
- Fix missing =  
- Also add some preliminary mind phase detection to Nzoth (currently it'd only work ok for player, for rest of phase it'd fail to build accurate table do to combat log phasing issues that hopefully blizzard addresses)  
- N'zoth update from the limited amount of test logs from the buggy mess that was called testing last week :D  
- Added some debug to ashvane to try and figure out how/why Core is breaking on cleaning up old timers when :Stop() is called  
- Azshara Update to new CLEU events  
     - Improved timers for all events that didn't used to be in combat log (but are now). Nether Portal and All 4 add timers particularly  
     - This update also finally enables add warnings on normal and LFR difficulty for Devoted, Myrmidon, and Indomitable adds. ALL add warnings will be 2-3 seconds faster (before the CLEU events, they were only detectable on heroic/mythic via a slightly slower event)  
- Fixed heart of frost timer, which probably changed a long time ago when they adjusted fight to make killing elemental more disirable than ignoring it, but no one reported it/cared.  
- Wrathion and Vexiona mythic updates  
- Mythic Maut update  
- Fixed energy infoframe to always show percent, not obnoxious numbers, during encounter.  
    Auto Logger Feature Update  
    - Re-worked auto logger to support either recording only bosses, or the entire zone via a new checkbox in options.  
    - Tweaked defaults a bit so that the default is to record entire zone, but only current content raids (ie trivial content excluded)  
- KR Update (#88)  
    * KR Update  
- Fix bad soundkit IDs for some sounds. Closes #87  
