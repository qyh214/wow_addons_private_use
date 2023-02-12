# <DBM> Icecrown Citadel

## [r311](https://github.com/DeadlyBossMods/DBM-WotLK/tree/r311) (2023-01-24)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-WotLK/compare/r310...r311) [Previous Releases](https://github.com/DeadlyBossMods/DBM-WotLK/releases)

- bump tocs  
- Fix a bug where overwhelming power timer would not cancel if tank dies early on iron council hard mode  
- tweaks to lunatic gaze timers to not start when not in p3, since it's also used to hacky detect portals.  
    Also reset Shadow beacon icons every time so it's always same marks used each add set.  
- Maybe fix collapsing star timer not working in classic?  
- Update koKR (Wrath) (#27)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- give retail the combat start timer too  
- add algalon combat timer to classic  
- I hate working on these old mods that don't follow conventions  
- add pre nerf yogg mind control spell alert  
- additional council tweaks  
- Fist pass on adjusting classic timers to using yells on mimiron  
- Retail timer tweak for yogg  
    Also changed cast timer bar color for deafening crash and lunatic gaze to be different from CD timer so it's an easier distinction which is which  
- Pass new "allow guid wipe" arg to target scanner on yogg. This will fix shadow beacon target marking (with a core update as well)  
- Fixed bug on ignis where flame jets had wrong spell name  
- Iron Council Update  
     - Overload now has a CD in P1 and P2 (p3 it's disabled cause it stops being reliable while boss does tentrils)  
     - Rune of death now has an initial timer after first boss dies  
     - Rune of shields now has initial timer after first boss dies  
     - Tentrils now has an initial timer after 2nd boss dies  
- Don't start portal timers if it's already p3, in case a lunatic gaze slips through after shadow barrier is removed  
- run custom actions on wrath repo  
- Add rest of classic encounter IDs that differ from retail  
- tweak the default of last  
- Set countdown on by default of mark on vezax  
- Filter mark target from crash scan, so when they happen at same time it doesn't announce crash is on mark target immediately and instead tries to find actual crash target  
- change this back to run out  
- Fix bug where mimironn P2 initial timers were wrong cause math is hard.  
    enabled the guessed p4 mimi timers so I can at least see on streams if right or not  
- Fix bug where tank mechanic on algalon had wrong spell name on retail and classic  
    Fixed a bug where collapsing star timer had green icon instead of a star icon on classic  
    Fixed a bug were initial timers on first pull on classic were way off.  
    Removed debug prints, cause the work around formost part should be fine now outside of reloading UI after first pull. can't do much about that.  
- Fix 25 man enrage warning on Gluth, Closes https://github.com/DeadlyBossMods/DBM-WoTLKC/issues/8  
- Fix hard mode/saronite timers for classic wrath Closes https://github.com/DeadlyBossMods/DBM-WoTLKC/issues/13  
- change audio for mark of faceless since "run out" is often taken literally and players are running to BFE when they just need to make sure they aren't within x yards of another player. New audio will say "spread"  
- fix ignis voice pack lua errors  
- Correct work around for doing 10 and 25 in same session  
- Ulduar Update  
     - Fixed a bug where flame Leviathan pursuit detection didn't work do to obsolete api checks when building GUID table.  
     - Fixed bug where wipe/kill detection on classic could be slow due to classic not using same encounter Ids as retail (why they keep changing these is beyond me.).  
     - Changed algalon combat timers again to try and work with the inconsistencies of encounter start on first pull vs not first pull on classic  
- Add note on algalon engage  
- Update localization.ru.lua (#26)  
- Shorten timer text on hodir so it's actually readable  
- Throttle system overload  
- trust encounter events in classic, at least until I can confirm they are bad like retail or not. hopefully they aren't.  
- Revert "Add Thaddius polarity support in RangeFrame (#25)"  
- bump toc for wrath classic  
- Fixed bug on mimiron where napalm shell icons didn't clear on mimiron  
    Fixed a bug where lightning charge achievement fail check didn't work on thorim  
- Cleanup code so it's more tidy and efficient (on my end) at expense of making it less efficient on blizzards end (will use more comms). This is a tradeoff I'm ok with since it was in their power to avoid it entirely.  
- Add late sync protection on phase 3 start to yogg. That way don't rely on built in antispam of sync function failing if someone sends one > 8 seconds later due to massive lag.  
- add algalon print too, and fix mimiron one to only fire in classic.  
- Re-enable p2 yell on angalon  
- fix some renames  
- whitespace because github  
- Fix algalon stats so classic algalon stats aren't overwritten by retail override and will once again show 10 and 25 man kills/wipes  
    Regressed mimiron back to 2009 code that depends on localization when running on classic but also modernized CHAT\_MSG\_LOOT to be more modern on retail and classic.  
- Add Thaddius polarity support in RangeFrame (#25)  
    Co-authored-by: lantisnt <lantisnt@gmail.com>  
- Updated razorscale and thorim timers from updated PTR change log for classic wrath.  
- Push unstaged stuff  
- Fixed a bug that caused brain portal timers not to show after first brain portals.  
    Also updated timers for Classic wrath pre nerf (which has brain rooms far less often)  
    Closes https://github.com/DeadlyBossMods/DBM-Retail/issues/833  
- Fix error in last  
- Improve Shadow beacon to  
    Allow icons to still work even if the person setting icons is mind controlled  
    Allow nameplate auras for big visible auras on the popular nameplate mods  
- micro optimize shadow crash to use GUID based scan, which is the more efficient path to CID based scan. no functional change in it really  
- Improve shadow crash alert to not filter non special alert of target.  
    Improved nearby checks to use modern code on shadowcrash and mark of the faceless one  
    increased range of mark of faceless one to warn if someone has it within 13 yards, up from 10 (can't do 15 cause next range available with limited api is 18)  
- quick fix rune of death cd timer, initial timer still missing (and might stay that way for now)  
- Fixed lua error on freya elders.  
    Changed warning text on hodir to say keep moving instead of "move away"  
    Changed icons used by hodir to 1 and 2 instead of 7 and 8, confirming to more modern mob icon usage  
- Initial pass of adjustments for wrath classic Ulduar  
- Fix timer update call on saph  
- Fix lua error that's been there for about 10 years, because not a single user reported it until now. Closes https://github.com/DeadlyBossMods/DBM-WoTLKC/issues/10  
- Nerf the efficency of ulduar modules to scan all unitIds and not just boss unit Ids in ulduar, then sync them to entire raid to make sure all users get it even if they aren't targetting bosses. #nochanges am I right? even with this, it's likely there will be situations algalon, kologarn, mimiron, and razorscale have missing alerts/timers.  
