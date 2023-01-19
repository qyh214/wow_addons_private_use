# <DBM> Dungeons (Dragonflight)

## [r59](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r59) (2023-01-17)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r58...r59) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Fixed several legacy dungeon mods that also had bad or missing spellids  
     - Fixed Tharbek GTFO warning not firing in UBRS  
     - Fixed bug that caused lava burst and suppression field interrupt warnings not to work right in. Bloodmaul Slag Mines  
     - Fixed a bug that caused GTFO on Magmolatus not to work in bloodmaul Slag Mines  
     - Fixed bug that caused dispel warning for Immolate not to work correctly on Terongor in Auchindoun  
     - Fixed bug that caused curtan of flame timer never to work on Azzakel in Auchindoun  
     - Fixed a bug where Channeling alerts and timers didn't work on Selin in Magisters terrace  
     - Fixed a bug where gravity lapse timers and alerts didn't work on Kael in Magisters Terrace  
     - Fixed a bug where Duelist blade chat bubble didn't show on freehold trash  
     - Fixed bug where darkshot dodge alert in kings rest trash didn't work  
     - Possibly fixed a bug where Wail of Mourning aoe incoming alert didn't work on kings rest trash  
     - Fixed a bug where wreck alert and timer didn't work on HK8 in mechagon  
     - Fixed a bug where sonic pulse shockwave dodge didn't work on mechagon trash (now I know why people were dying to it more often than other avoids in SL S4)  
     - Fixed a bug where Ferocity dispel warning didn't work on Siege of Boralus trash  
     - Fixed a bug where interrupt warning for jolt didn't work correctly on adderal and ass pix in temple of sethraliss  
     - Fixed a bug where repentance alert didn't work on High Prophet in Lost city of Tolvir  
     - Fixed a bug where Spores alert and timer didn't work on Agronox in Catheddral of Eternal Night  
     - Fixed a bug where burning hatred alerts didn't work on Dargrul in Neltharions Lair  
     - Fixed bug that caused Coalesced void not to work on Zuraal in Seat of Triumvirate  
     - Fixed a bug where fixate nameplate icon was never properly claered on Hakkar in De Other Side  
     - Fixed a bug where Tears of the Forrest timer/alert didn't work on Ingra Maloch in Mists of Tirna Scithe  
     - Fixed a bug where overgrowth alerts didn't work in Mists of Tirna Scithe trash  
     - Fixed a bug that caused Bulwark of Maldraxxus alert not to work in Plaguefall trash  
     - Fixed a bug that caused Curse of Suppression not to work in sanguine depths  
     - Fixed a bug that caused Titantic Insight target timer not to cancel if removed early on Hylbrande in Tazavesh  
     - Fixed bug that caused alert that collapsing energy has ended not to show on Soleah in Tazvesh  
     - Fixed a bug that caused junk mail interrupt warning not to show on tazavesh trash  
     - Fixed a bug that caused Chronolight Enhancer cast warning not to show on tazavesh trash  
     - Fixed a bug that caused Inpound Contraband alert saying it has ended not to show on Zophex the sentinel in tazavesh  
     - Fixed a bug that caused ghostly charge timer not to show on Mordretha in theater of pain  
     - Fixed a bug that caused Echo of Battle timer not to show on Mordretha in theater of pain  
     - Fixed a bug that cause deaths grasp target announce not to show on Mordretha in theater of pain  
     - Fixed a bug that caused tenderize stack announce not to work in Necrotic wake trash  
     - Fixed a bug that caused sever flesh alert and timer not to work on Surgeon Stitchflesh in Necrotic Wake  
     - Fixed some vanilla dungeon stuff in a few bosses I got lazy to type out at this point since those mods are really really basic anyways  
- Fixed several bugs related to unregistered or incorrectly registered spellids affecting many current content dungeons  
     - Fixed bug on Vexamus that caused arcane fissure timer not to start after first in Algethar Academy  
     - Fixed a bug on Khajin the Unyeilding that caused Frost shock dispel warning not to work  
     - Fixed a bug on The scorcchig Forge in. Neltharus that caused Aegis countdown yell not to cancel if was removed early  
     - Fixed a bug with ruby life pools trash that caused living bomb countdown yell not to cancel if removed early  
     - Fixed a major bug on Granyth in Nokhud that caused phase change code to never work, resulting in MANY broken timer resets  
     - Fixed a bug on Sentinel Talondras in Uldaman that caused earthen shards target alert not to work  
     - Fixed a bug on courts of stars trash that caused interrupt warning for Disintegration Beam not to work  
     - Fixed a bug on Fenryr in Halls of valor that caused range check not to auto hide after leap has ended  
     - Fixed a bug on Odyn in halls of valor that caused spear announce never to show  
     - Fixed a bug on Nhallish in Shadowmoon Buriel grounds that caused void devastation alert and timer never to work  
- comment and code cleanup  
- at gesyer timers and fix geyser announcementss  
- Update localization.cn.lua (#94)  
- Don't auto close spy helper dialogs. People just don't want to use infoframe, or the chat spam, they have to read clue for themselves so by default now everyone is stuck doing that unless they opt in to auto closing/hiding.  
- Fix bug causing breath warnings and timers not to work on hymdall  
- Fixed a bug where spy helper infoframe still showed up on LW comms when disabled.  
- Enable gutshot hyena timer  
- Update koKR (#93)  
    Co-authored-by: Artemis <QartemisT@gmail.com>  