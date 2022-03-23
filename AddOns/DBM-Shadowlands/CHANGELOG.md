# <DBM> World Bosses (Shadowlands)

## [9.2.8](https://github.com/DeadlyBossMods/DBM-Retail/tree/9.2.8) (2022-03-22)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Retail/compare/9.2.7...9.2.8) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Retail/releases)

- prep new retail and tbc tags  
- bump BCC toc Raise boss unit ID scan to boss 10, per hotfix last week, now allows up to 10 and all return valid unit events  
- Fixed a bug where second protoform cascade timer in intial boss phase rotation was wrong in normal (and LFR, which uses same timers)  
- Pantheon LFR update  
- Update Dausegne for LFR  
- Small tweak to rygelon  
- Tazavesh Trash update  
     - Fixed bug where one trash announce announced a warning twice instead of playing a voice  
     - Also fixed a bug where trash warnings would show for trash you aren't in combat with. It'll now all strictly be filtered through combat validation. Caveat of this is, sometimes warnings won't show when you are in combat with mobs, if caster is not targetted at time of cast, the down side of combat affiliation validation :\  
- Changed icon usage again on anduin slightly to match other mods.  
    Tweaked jailer icons to account for mythic having 5 bombs  
- Update koKR (#90)  
- Fixed a bug that caused deafoning crash on xav not to work  
- Fixed a bug that caused hopelessness timer to never be right in phase 3 anduin do to wrong code ath being commented out. But also depreciated that code path anyways and eliminated P3 timer tables since in all difficulties P3 timers are static.  
    Also finished the mythic phase length timers. Timers for fight should now be complete on any difficulty of any fight length  
- Berserk timer is 6 mins 30 seconds in mythic - Rygelon  
- Remove debugging code.  
- Disable beserk timer for LFR, as there are 10 minute+ pulls without cast  
- Beserk is 7 minutes only in lfr/normal  
- Fix another case of sourceGUID  
- Fix another case of sourceGUID  
- Fix another case of sourceGUID  
- Fix another case of sourceGUID  
- Fix typo on sourceGUID  
- Update Skolex.lua  
- Beserk time changed to 7 minutes  
    Ref log: https://www.warcraftlogs.com/reports/6F2DPm1GHMRzQ7Xc#fight=4&type=casts&hostility=1&source=23&ability=364622  
- fixed bug with soul reaper taunt not working.  
    MAYBE fix a bug with soul reaper defensivve warning both tanks if the primary tank isn't securely tanking. Although in that situation it'll now just not warn either tank if it can't securely detect a status 3 tank.  
- revise tanking check with a new option to only request status 3 check  
- couple more mythic ygelon timer tweaks from vods, i'm not gonna go too much into vod timings when there isn't much urgency to support fight yet  
- Update localization.cn.lua (#89)  
- don't show dark zeal taunt warning if still phased in kingsmourn  
- further improvements to tank swap warnings based on feedback.  
- also change spell description in optinos ot use the new spellids tooltip, not old one  
- another tank debuff tweak, hal taunt swap will now ignroe if you have debuff and always authorize taunt warning to swap beam back and forth.  
- Fixed a bug that caused tank warning not to fire on Vigilant guardian for boss swapping.  
    Fixed a bug that caused interrupt warning to show before you're supposed to interrupt on lords of dread. it should now correctly wait until incomplete form drops before telling you to interrupt casts.  
    Fixed a bug where icon setting for manifeste shadows on lords of dread was a bit slow. it should be faster now.  
- cleanup anduin mod, outside of tweaks to one intermission, mythic is same as heroic so the entire table can be reduced  
- Improve dausegne barrage so count is always visible, in all warning types  
- add a you pos count object.  
- just eyeballing, might not be right, but it looks like bang is 5 seconds slower on mythic  
- update lords of dread mythic berserk  
- tweak one more default  
- change icon defaults and usages on jailer to be compatible with the now (finally) released BW jailer mod  
- adjust carrion throttle some, because it was overly strict and filtering first targets too  
- timer weaks to guardian to reset two timers on expose core, per todays hotfixes  
- Fix Lua error  
- Update commonlocal.cn.lua (#88)  
- Update localization.tw.lua (#87)  
- Update commonlocal.tw.lua (#86)  
- Only warn initial carrion targets for non targets. (personal always). This is a good middle ground of knowing initial targets but avoiding spam from it bouncing all about from handling it poorly  
- Tweak last, that kind of aggregation won't work, ultimately no way to avoid spam without gimping warning too much. it only spams if things going wrong, so just don't go wrong! ('ll i'll come up with cleaner solution later)  
- Fix a few observed bugs with lords of dread  
- Update alpha revision  
