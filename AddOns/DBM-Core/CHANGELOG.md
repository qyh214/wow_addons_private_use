# Deadly Boss Mods Core

## [9.0.18](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.18) (2021-01-19)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.17...9.0.18) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Prep new tag  
- further throttle duplicate events on altimor  
- LuaCheck cleanup (#484)  
    * LuaCheck cleanup  
- Remove unessesary check, we know target mapID so it doesn't need to be checked  
- Optimize some infoframes (#483)  
- Don't show players outside zone on hungering destroyer infoframe  
- Several aranomonos timer fixes  
- Fix #479 (#480)  
- Added optional off by default special warning to interrupt dreadbolt volley. This warning does NOT use the filter function at all meaning it always fires regardless of target or spell cooldown, which is why it's off by default.  
- Fixed bug where souls pikes was extended twice and subtracted twice, and prideful was never extended beyond dance at all  
- I'm gonna leave this debug code around for a while, but at least fix the duplicate entries  
- Stray copy/paste  
- Several countdown fixes related to live bar updates  
     - Fixed a bug where default countdowns would start even when users had countdown completely disabled for that timer option,  after a bar fade or time remaining was live updated.  
     - Fixed a bug where bar updates would swap to default voice even when a custom voice was used.  
     - Fixed a bug where a countdown would not be canceled during a bar update for a bar a user set a countown on manually but had no default countdown option defined.  
     - Fixed a bug where a new countdown would needlessly be scheduled after a bar update, when remaining time on the new bar is less than 3.  
- prep further debug  
- Prepare timer test conditions for debugging addition or subtraction timer methods  
- If test mode is started over before it's finished, abort previous timers/countdowns to avoid false debug and duplicate countdowns  
    Possibly fix the real issue behind #476. Although this requires more testing tomorrow  
- Tidied up sire timer options a little.  
    Grouped up timer options on shriekwing for earsplitting shriek so they aren't in two diff spots  
- Adjust the dims of the special warning and coundown dropdowns so "None" is never runcated, improving readability of them quite a bit  
- Improve Halkias timers. Closes #473  
- Improve tank stuff on darkvein based on feedback.  
     - warped desires stack warning is on by default now.  
     - warped desires stack warning will no longer wrongfully say to taunt if you still have stacks yourself  
     - warped desires stack warning will no longer go off if stacks came from adds (this is a bad timing and can cause cleaves)  
     - hidden desires taunt warning that was on by default is now off by default, that's a niche thing that requires knowing precise timing to do it safely so it shouldn't be something DBM defaults.  
- Fixed glyph CD, which was correct on in notes but not in timer for some reason.  
- The whole bug is because difficulty doesn't actually return as mythic plus (8) for nearly 6 seconds after the challenge mode event has already fired.  
- Fix  
- Try fixing CM logging a different way  
- Attempt to fix up Beryllia's tmers some  
- Update koKR (#472)  
    Co-authored-by: QartemisT <QartemisT@gmail.com>  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Manastorms: P2 Aerial Rocket Chicken is party-wide damage that's not … (#474)  
- Also another tweak to remove unnessesary rescheduling instantly after rescheduling if both combat logging and transcriptor logging used at same time  
- Slightly better  
- Fix core to always log if PT is used, period and update checkforActualPull to support M+ in this behavior as well  
- Couple timer tweaks  
- Fix overwhelm not showing which name (#471)  
- Fixed voicepack bug where deathgate warning had no voice assigned  
- Update zhCN (#469)  
- Update zhTW (#468)  
- Bump alpha  
