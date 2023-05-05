# <DBM> Dungeons (Dragonflight)

## [r76](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r76) (2023-05-02)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r75...r76) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- bump tocs  
- fixed a missed rename  
- Another underrot pass with some stuff I missed in last pass that wowhead article brought to attention. a few things were wrong in WH articile too (like timers) but the added spells were definitely useful. :D  
- better late than never, but add timers to flame dance and tectonic Slam to ruby life pools trash, to help pre season 2 testing of nameplate timers, plus these are two pretty important timer abilities that shouldn't have been omitted in first place.  
- Add timers and minor fixes to Underrot trash  
- another fix  
- fix missing ,  
- Work in progress tweaks/additions to underrot, timers will be done soon but being dragged into m+ so pushing this part for now  
- Tweaks  
- Lightning lash can no longer be interrupted, so now warnings will say to get grounding field  
    Also added alerts for overload grounding field as well, and itll be emphasized if you're actually in it.  
    Added timers for both of the above  
- Several bugfixes and timer tweaks to freehold, Uldaman, Neltharius, and VP  
- Add eng/herb buff gossipID  
- reclassify painful motivation timer type for same reason warning is off by default. this is more of a tank role/decision to make and not just something to be callusly interrupted.  
    Also fixed stats for vortex Pinnacle to now show Mythic+ difficulty  
- fix missing ID  
- Fix duplicate object  
- Supercharge freehold with few new alerts and a crap ton of timers  
- Update koKR (#117)  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Fix missing spellId  
- Supercharge Legacy of Tyr trash module with many new alerts and a buttload ton of timers  
- fix missing ,  
- VP boss updates for 10.1  
- Update localization.ru.lua (#116)  
- Update zhTW (#115)  
- Fix missing closing statement  
- Supercharge Neltharius mod with many new warnings and timers  
- fix typo/error  
- Add timers to all supported abilities that had consistent timings to Halls of infusion  
- add several more warnings to Halls of infusion. will do notable timers tomorrow  
- Move all dungeon phase calls to self:GetStage() api  
- Add lethal current to VP trash mod  
    Added many missing abilities to Brackenhide Hollow trash mod  
    Added first pass on timers to Brackenhide Hollow trash mod as well  
- Fix table  
- Upgrade all trash timers for unique mobs to still send GUID so callbacks can grab GUID and assign ability timers to specific 3rd party nameplates  
    Also finally added some missing SMBG stuff (better late than never, instance was so easy it didn't need a trash mod, but when working on timer updates i figured might as well finish populationg SMBG)  
- fix typo  
- Minor drycode for harlan sweete changes  
- Add RP timer for Magmatusk activation  
- modernize quills call with clearer instructions that are now available  
- Add IconTexture  
- Fix object name between merge  
- Merge original wise mari with new one, since BOTH are actually still avaialble on classic (timewalking uses original version of fight, not rework). this hybrid mod will support both automatically  
- Code a silly work around to an impossible problem  
