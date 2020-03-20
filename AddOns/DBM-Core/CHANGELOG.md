# Deadly Boss Mods Core

## [8.3.18](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.3.18) (2020-03-17)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.3.17...8.3.18)

- Bump version and prepare tag  
- Complete the normal mode growth tentacles to complete different timers for all 4 difficulties. Removed debug for them.  
- Update LFR Berserk  
- Fixed guild combat messaging system throwing lua errors on niche bosses that exist in a raid but not in journal. This error only happened when Boss was in a raid, not in the journal, is current content (or rather current content relative to players level, IE doing algalon herald of titans run).  
- Added LFR timer for Growth Covered tentacle and disabled timer for Gaze of Madness (doesn't seem to happen in LFR?)  
- Pruned Enlarge bar percent option, it's simply not really compatible with the "Simple" bar behavior plus it contradicts the enlarge bar time option, which is all DBM really needs.  
    Combined the general bar options and limited bar options back together since there are no longer limitaitons on said bar options.  
- Simple bar behavior option should now work with all bar animation/movement options.  
- Updated LFR trashing tentacles in stage 3 Carapace from videos.  
    Also updated normal thrashing tentacles through mathmatical calculations based on heroic and lfr timers.  
