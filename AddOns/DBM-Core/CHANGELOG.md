# DBM - Core

## [12.0.44](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.44) (2026-04-29)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.43...12.0.44) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep tag  
- add missing kr strings (#2038)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Align localizations (#2039)  
- another fix  
- improve debug  
    fix a bug  
- fix two world boss mods not loading (surprised I didn't notice sooner, guess that shows just how insignificant they are)  
- fix over engineered noise and lua error caused by over engineered noise  
- Make fallback states be used even in debug mode  
- more combat oriented debug removed from printing.  
- fix more in combat debug print spam when in debugmode 3  
- Fix a regression that caused kills to also be flagged as wipes in DBM core guild syncs  
- improve readability  
- IgnoreBlizzAPI should no longer be ignored if in debugmode 3  
- double number of lines  
- another small minor tweak  
- missed some spammy events  
- disable several spammy debug evens at level 3 level  
    tweak a few other debug events to be more verbose or enable logging.  
- improve debug  
- level up debug log and give it control over whether or not it's basic timeline debuglog or verbose with additional details  
- combine upheaval warnings  
    Add stage markers  
- tweak default timings and add optionto alter them  
- Simplification  
- debug readability improvement  
- Tweak objects and update gloom and convergence warnings to make smart use of ENCOUNTER\_WARNING  
- Push new objects to simplify using ENCOUNTER\_WARNING ti dispatch both personal warnings and target warnings.  
    Upgrade dread breath special warning to now include target name, and eliminate redundant non special target warning.  
- extend debug logging  
- bump alpha  
