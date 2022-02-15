# <DBM> World Bosses (Shadowlands)

## [9.1.28](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.1.28) (2022-02-08)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.1.27...9.1.28) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- Prep new tags  
- Bump Classic TOC version to 1.14.2  
- Fixed Auto expand defaults for retail Tweaked Panel prototype to reduce unnessesary calls to getspellinfo by using the already existing check in main gui file Also added a check that if blank or no description, insert a text saying there isn't one so it isn't just an empty box  
- ContinueOnSpellLoad fails horribly if the spellid used is not actually a valid one (might be cause if loading a PTR mod on retail or blizzard deletes/changes a spellId. Fixed by adding validation and if not valid it'll revert to just setting text as text  
- more grouping tweaks/fixes  
- Update commonlocal.ru.lua (#76)  
- Because of alpha users, this needs to be forced, or it'll look bad in classic and tbc  
- Removed "newoptions" flags  
- ATUALLY push update, apparently it was dumb and pushed an update without changes  
- Complete Rygelon's phasing code  
- Fix bad removal  
- I forget every boss that I used wrong template for this zone that had random variables in shitty places.  
- More rygelon work, but this mod is just going to have to stay half done until live. the journal for it has conflicting information to spell data that leads me to believe either journal is wrong on some points, or spell data is and it's impossible to know which is wrong. Hopefully blizzard gives it more clarity before launch, otherwise it's just going to stay a half assed mod until week 2 of raid when everyone sees it for first time.  
- Dropdown bgFile renders super weird in classic era  
- Fix  
- initial pass on new options layouts for Sepulcher  
    Also a half done Rygelon mod (will finish second half tomorrow)  
- Fix some cases of text not being centered.  
- improve fatescribe option readabiity by splitting by stage  
- Make forced misc lines insert into misc area only. if misc is defined, it's probably meant to go there and not into groupings. Fixes visibility of all the drop downs.  
- Add the crappy dropdown bug work around to mods that are missing it.  
- Update localization.ru.lua (#75) Minor typos.  
- Fix typo  
- Update localization.ru.lua (#74)  
- Also missed this in the first pass  
- That was missing because it was useless, actually fix specWarnParasiticInfester by deleting it instead  
- Update koKR (#73) Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update koKR (Retail) (#730)  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Full pass on dungeons and updated 20 mods to fix douplicate groups, or reorganized by phase or caster and added headers  
- set stats type for dungeons and world bosses and go from there. will begin review now  
- Update zhTW (#72)  
- Update localization.cn.lua (#71)  
- made eye of jailer better looking  
- Enable the audio expand option as well, another easy add. :D  
- Fixed bug where not all ice and earth bridge spells were grouped on sylvanas  
- Add option to toggle whether updated mods use the new guid layout or old one. Added option to choose whether or not icon options are included in new layout when it is enabled  
- Fix some options being positioned a little weirdly.  
- make movie skipping off by default for good until such a time CINEMATIC\_START get an Id system.  
- Remove one useless infoframe  
    turn another off by default  
- Fix another error  
- apparently luacheck is just dumb and can't report an error accurately  
- Updated Halondrus and Lihuvim encounter mods to latest changes  
- Fixed stats page looking a little quirky, due to textarea changes  
- Fix CI  
- fix some altimor ordering  
- updated two bools  
- Fix grouping being a little quirky when setting custom groups  
- it's late, no idea why i commented that  
- mis named that  
- Finished review on castle and sanctum and got all groupings setup and fixed some mismatching spellids or spellids that lacked descriptions with ones that didn't  
- Make grouping title a little more visible (tiny hint larger, and different color)  
- Fix weird error when clicking NEAR the toggle button  
- Fixed critical bug in new ui code that caused most warnings and timers to fail and spam errors instead  
- begin work on spell grouping and mod re-sorting  
- Fix something that got merged badly  
- Gui (#67) - Make new objects an OrderedTable, so they appear in the order they were coded in - Add a variable for \"newOptions\" at an addon level (So old mods don't parse over and break badly) - Replace GroupOptions with GroupSpells, and do automatic detection - Improve rendering in GUI for new options, and fix some other quirky bugs - Improve CreateLine positioning code  
- Update localization.ru.lua (#727)  
    Accurate translation.  
- Update localization.ru.lua (#69) Missing phrases and their translation.  
- Update localization.ru.lua (#728)  
    Added SetOptionLocalization. Minor fixes.  
- Update zhTW (#68)  
- bump alpha revisions  
