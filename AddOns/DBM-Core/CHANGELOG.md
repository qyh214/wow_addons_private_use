# Deadly Boss Mods Core

## [8.3.26](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.3.26) (2020-06-12)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.3.25...8.3.26)

- Properly Fixed infoframe optiondefault code  
    Prep new release  
- Re-add the commented 431 check, which is still good to run sometimes (just not all the time, at least not yet)  
- Some more pixel adjustments in Special Announcements  
- Fixed a text overlap in announcements  
- Fixed bug with "Dont Play Special Warning Sound" option  
- Add altimor now that he's in journal. He only had a dungeon enocunter ID last couple builds.  
- Removed some bad comments  
- Fix Paws being stupid  
- Another comment note  
    Changed text for heroic 10 and 25 to actually say 10 and 25 instead of just "heroic".  
- Fix typo in wod fix. Now all stats modules accurate again.  
- Merge in UI fixes diff  
- Added proper support for Firelands stats format  
    Improved support for WoD Dungeon stats support showing correct challenge text  
- Just some slight notes improvement (no code changes), although some of them not even I could figure out/remember  
- Fix incorrect self  
- Fixed GUI heighlight bug on scroll  
    Fixed stats area being too small on some raid foramts  
- Updates (#255)  
    * Fixed bug.  
- Fix regression that caused guild combat syncs to throw lua errors.  
- Updates (#254)  
    * Small fixes  
- Push fix to prevent realmstrip code running on units that aren't player units  
- Updates (#253)  
    Cleanup  
- Fix these 3 that were mis-changed, DBM-Core should have no more local issues  
- Push more fixes (and maybe breakage?)  
- Fix first batch is missed globals  
- Further tighten luacheck and added a missed DBM global  
    Changed one warning on ra-den to be clearer  
- Update localization.cn.lua (#252)  
- Fix "AlwaysShowSpeedKillTimer" option name (#250)  
- Fixed typo  
- Update KR (#249)  
    * Update KR  
- Fix another missed spot  
- Fixed a bug with infoframe adding a second * on off realmers and adding a single one on players from same realm  
- Updated GUI: zhTW (#248)  
- Sync CN update to retail  
- Add tab translations now, ahead of feature work, to allow more time for localization  
- Update localization.cn.lua (#246)  
- Update localization.cn.lua (#247)  
- Remove unused Locales from my changes.  
    Fixed a gross ineffiicency in one of my core edits too.  
- Re-arrangements and renames. Sorry for breaking ReloadUI updates with this, but consistency had to be applied for easier code maintenance  
- Fix headers  
- DBM-Core & GUI Updates  
      - Re-arranged core options a bit more, moving all options related to privacy into their own "Privacy" options tab and moved 3 of the chat frame message alerts from extra features, into Chatframe Messages where it made more sense for them to belong.  
      - Added a new privacy option, ported from classic but slightly modified to better align with retail, to disable the sending of world boss engaged/defeated sync messages.  
      - Moved some local variables that didn't belong at file level.  
      - Ported SendWorldSync over from classic, to cleanup combat functions a little and unify the two cores a bit.  
      - Fixed a bug that caused the guild sync privacy option to never actually work because the disable sync, and sending sync were both sent in same frame update so not enough time was ever allowed to actually let the RL disablethis feature. Now there is a 1.5 second delay to allow this functionality to work correctly.  
- Tweak wording of that option  
- Some GUI Tweaks  
      - Renamed "warning" objects to announce object, since not all announcements are warnings. Also removed "raid" from terminology because not all announcements are in raids (5 mans dungeons, pvp, solo play also have dbm modules so this classification was grossly inaccurate)  
      - Renamed "Bar Setup" to "Timers" to be more clear that those are timer options, since "bar" is a less accurate broad classification that can mean different things (timer bars, nameplate bars, health bars, etc).  
      - Renamed "General Messages" to "Chatframe Messages" to better reflect that options in that area toggle what message are or aren't shown in chat frame. Also moved this option area lower down list since it's has closer relationship to global disables and filters, it makes sense to be right next to it.  
      - On that note, one option was moved from global disables and filters to chatframe messages, because it was a better fit for that option. That option is the one that enables/disables showing reminder messages.  
- Made infoframe on Xanesh more practical. It will now hide when it's not needed instead of show bank a good 50% of the fight.  
- Update KR (#245)  
    * KR Update  
- Prep new alpha version before merging in PRs  
