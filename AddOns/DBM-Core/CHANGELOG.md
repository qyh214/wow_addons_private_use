# Deadly Boss Mods Core

## [9.0.15](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.15) (2020-12-28)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.14...9.0.15) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Prep tag  
- Extended P2 heroic timers for sire slightly  
    Fixed a ton of bad timers on normal sire, which aren't even remotely the same as heroic  
- Reset countdown options to off for crystalize and eruption. On generals, no countdowns are good do to spell queuing  
- Danse Macabre is no longer using an air horn by default  
- Fix and re-enable countdown for ember blast  
- Missed something  
- Just remove the ember blast countdown for now.  
- Also fix object  
- Glyph of Destruction counter (#458)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Make all incompatible addons use infinite loop notice  
- Enabled the bfa mod available alerts  
    Performed some slight refactoring onf auto logging to resolve some issues with logs not starting for M+ do to fact that when player enters dungeon, it's still a Mythic-0. DBM will now run log check function on all loading screen changes, if difficulty index becomes 8 in any of them (ie the keystone ui reload occurs  
- This probably actually uses more cpu, but a hell of a lot better to look at. Probably should have QartemisT review. It tests fine  
- Prevent kael mod from engaging if he gets stuck on boss health frames after victory  
- Fixed a bug that's been there a LONG time that showed a random "nil" message when showing range frame in n instance  
- Fix  
- Fix ember blast countdown on mythic, apparently tooltips lie  
- Bump alpha  
