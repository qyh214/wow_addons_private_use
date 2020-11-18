# Deadly Boss Mods Core

## [9.0.4](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.4) (2020-11-17)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.3...9.0.4) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Quick fix on one timer object type  
- bump tocs  
    Added last world boss drycode for shadowlands  
- Update README.md  
- Nuke bfa mods from orbid, they are split into new stand alone  
    update brawlers and world events to shadowlands catagory  
- Set mod ban  
- Added drycodes for Nurgash and Oranomonos  
- Brain fart, can't use chat bubbles on world bosses. So charged anima blast will be even more fun :D  
- Sludgefist update  
     - Fixed bug that cauased 2nd stomp timer to be wrong.  
     - Added code to stop hateful gaze timer/countdown if boss instantly gains full energy from failed chain stomp  
     - Fixed missing chain slam timer  
     - Minor timer updates  
     - Updated timers to stay on screen when they get delayed by spell queue or more importantly hateful gaze/stun impact.  
- Update duration of Stone Shell from last nights hotfixes  
- added DBM-GarrisionInvasions to the blocked mod list, it was also merged into another mod  
- Add DBM-Argus to banned mods  
- Just change world bosses to a new naming convention that'll avoid the naming conflict issues going forward. Plus it'll add clarity to mods anyways. Downside, requires translations now for mods that used to be auto translated.  
- Revert "prefer localized (displayName) over Name (usually modId) when verifying if a frame already exists. Display name should never be nil because if one isn't passed then it's just going to return the value of Name anyways so basically now it's displayName -- > Name check order instead of just Name. This will obviously still error if there are ever two things with competing localized names. In other words this still probably doesn't fix the Kr issue with "Shadowlands""  
- prefer localized (displayName) over Name (usually modId) when verifying if a frame already exists. Display name should never be nil because if one isn't passed then it's just going to return the value of Name anyways so basically now it's displayName -- > Name check order instead of just Name. This will obviously still error if there are ever two things with competing localized names. In other words this still probably doesn't fix the Kr issue with "Shadowlands"  
- When blizzard changes section Ids for sake of changing them (no changes to text, or anything, just swappedd to another ID because....reasons  
- Update zhTW (#381)  
- Small council timer fix  
- tweak Emeriss timer  
- Significant updates to council post mythic testing. if heroic and normal aren't retested than it's possible those mods will not be perfect on launch, but mythic should be in fairly good shape, at least for most common boss orders. Literally no one in testing left Freida or Nik for last, so their 3 abilities are not corrected yet.  
- Fixed trivial check to make content trivial if player is 10 levels higher than content tuning, not 10 levels under it. :D  
- Missed a table  
- Simplify chain link code on sludgefist  
    Fixed chain links pairs 9 and 10 not having valid say bubbles  
    Fixed a regression that caused options with invalid spellIds to error out and fail instead of reporting out and allowing mod to continue to load  
- Fix a few changed/invalid spellId calls  
- Fixed bug causing crystalize timer not to start  
- Bug tweak last to avoid spam. if debug mode is off, cap logging level to 1 and 2, 3 should only be logged explictely if user enables it  
- Always fire debug callback even if it's not enabled, produce better transcriptor logs without needing users to actually turn debug on.  
- Miner timer adustments  
- Ensure that the option GUI never gets trivial filtered  
- Added new feature to automatically download all special anounce sounds on global level to regular announce sounds for content that is trivial for your level (on by default). Closes #379  
- comma  
- Update how istrivial works with a table that took annoying long to make. this table will applied to more features soon™  
- Update localization.tw.lua (#378)  
- Work around a new bug in GUI that didn't used to be there, but is there now. mod names can't be same as frame names or they refuse to load.  
- Minor adjustments to Ysondre  
- KR Update (#375)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update DBM-Party-Shadowlands.toc (#377)  
    Correct title errors.  
- Update DBM-Shadowlands.toc (#376)  
    Add zh-TW Title.  
- Bump alpha for new test cycle  
