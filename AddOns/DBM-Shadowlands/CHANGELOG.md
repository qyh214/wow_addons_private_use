# <DBM> World Bosses (Shadowlands)

## [9.2.10](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.2.10) (2022-03-30)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.2.9...9.2.10) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- Tag all the things  
- Re-add 2 used icons.  
- Update koKR (Retail) (#747)  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Cleanup some unused files; - Move spark.blp to DBM-StatusBarTimers - Remove LOA sound, as it exists in classic/bcc now - Remove default.blp from DBM-Core, as it's a duplicate of DBM-StatusBarTimers (and all references point there) - Removed unused arrow textures - Remove ? unused textures (CryptFiendBurrow, CryptFiendUnBurrow) - Remove redundant PvP textures (GuardTower, OrcTower)  
- Check warlock has an imp for Singe Magic dispell  
- adjust fog timer for non mythic lords of dread  
- Update localization.cn.lua (#746)  
- Update zhTW (#745)  
- Update localization.ru.lua (#744)  
    Added missing phrases. Translation of some phrases.  
- Update commonlocal.ru.lua (#93)  
- NewTimer object that isn't auto localized also needs a way to inject group spellid  
- Groupspells doesn't work that way, so has to be done like this  
- Add another failsafe for mid fight dcs  
- Add alerts I forgot  
- Failsafes  
- fix stupid  
- Jailer Update:  
     - Refactor phase change code to use blizzards official phase change markers, helps cleanup code a bit too.  
     - Added Tyranny Warning and timer that's approx. since event isn't in combat log it basically caculated based on hit debuffs and using scheduling to kinda pre warn the 3 second cast based on this  
     - Added short text to describe descolation better.  
     - Added heal and dispel timers based on echo''s kill for Blood and Death sentence mechanics, credits to Justwait  
     - Fixed one missing Normal mode timer for for relentless domination  
     - Added phase change timers  
     - Announce initial death sentence target  
- Push locals ahead of next jailer update, to give loalizers max time to get ready for it  
- functions work better when they're actually defined as a function  
- Jailer Update:  
     - tweak icon usage one last time to be compatible with final BW module  
     - Improved handling of mythic chains of anquish 3 by coding for fact that boss sometimes skips sometimes casts. DBM will now assume it's coming but if it doesn't, auto start timer for 4th one  
     - Improved Death Sentence handling to not warn player every time it changes to a diff version of debuff. Now it only warns on 30 second application. It also more efficiently only schedules yell countdown when 6 second version of debuff applied instead of scheduling it for entire 30.  
- Jailer Update  
     - Forced sacrifice wasn't used  
     - Added mythic timers for all stages (including hidden one)  
     - Cleaned up some unused  
     - Fixed a bug where timers beyond a stages max length would show.  
- Slight improve tank warnings on Lihuvim  
- Jailer Update:  
     - Fixed a bug where decimator count didn't reset on P3, causing timer to not work (and counts to be wrong for casts)  
     - Added UI line for phase 4 (mythic only) abilities to separate cleaner  
     - Added Rune of damnation to P4 table to avoid nil errors (timer data still pending)  
     - Reset two more counts on P4 start for P1 and P3 abilities that carry over.  
- Update koKR (#92) Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Soazmi update  
- Jailer Update  
     - Push mythic jailer drycodes for Stage 4 (most timers for stages 1-3 are still currently being widthheld for now and will be added when race concludes)  
     - Re-add short name text using a different method to some abilities  
- Add counts to tear timer and trap timer on xymox  
- Also error out if no function passes so author knows they are using it incorrectly.  
- Do not allow all callbacks to be unregistered by any mod that forgets to pass a valid function, that's just bad. now it should just error out if a function isn't passed and leave it at that. This resolves issues with one mod breaking other mods, Ref https://github.com/BigWigsMods/Transcriptor/pull/30 Also added more CL  
- that's what I get for copy and paste out of github's bad editor. it actually converted some of tabs to spaces but left some tabs? wtf github. make your editor less shit  
- Update localization.ru.lua (#91)  
- fix multiple tank checks across 5 mods  
- Fix https://github.com/DeadlyBossMods/DBM-TBC-Classic/issues/111  
- This is hacky, but it won't throw errors setting a custom name.  
- merge compatible changes back in  
- Revert "Untested jailer shortname code using the untested short name core code. Shouldn't be any issues at all."  
- This should revert it to last stable point  
- fuck it, i'm going to bed  
- make luachec happy  
- Fix two mods using invalid spellids  
- Untested jailer shortname code using the untested short name core code. Shouldn't be any issues at all.  
    Also improved the jailer bombs to reuse the already existing "jump in pit" voice pack sound from maiden of vigilence because might as well :)  
- fix error in last, forgot to comment two lines  
- Fix bad copy paste  
- Fixed a bug where split resolution timer had wrong spellid  
    Fixed defile warning to just be an aoe count warning since target scan doesn't actually work. Removed misleading yells and personal warnings  
- decimator was mis flagged as a tank warning, it's not. removed some bad warnings, reclassified it and fixed voice sound for it so it is more clear what ability is  
- not sure why this check is here, so remove it  
- Improve logic here too  
- Fix up Luacheck  
- Fix weirdness with Rygelon  
    Add -delay to combat start timers  
    Remove redundant IsMythic call inside an ELSE statement for IsMythic  
- Add berserk timer to Xymox normal/heroic  
- Tweak pause/resume code for fear and clouds to factor in min time before boss can cast again after a phase transition. This will ensure the most pristine level of accuracy  
- bump alpha  
