# Deadly Boss Mods Core

## [8.3.9](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.3.9) (2020-02-01)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.3.8...8.3.9)

- Prep new Tag  
- Release the ilgynoth mod  
- KR Update (#130)  
    * KR Update  
- Updated the Black Scar taunt stack amount (#129)  
    Taunting at 2 stacks is not enough time for a tank to drop his/her stacks.  
- Make sure the locals don't prevent retail DBM from notifying classic users they installed wrong mod  
- Actually handle SendSync code better for mods by improved SetRevision code  
- Core will now more robustly handle if revision is sent as a number instead of expected string  
- Core will now send DBM.Revision revision instead of 0,  when a mod is missing it's own revision (such as when using github checkout)  
    Tweaked Ra-den respawn  
- Re-enabled fading anguish fades yell by default, but initial apply stuff off by default on Nzoth  
    Shortened yell text and removed unneeded count from it for shred Psyche on Skitra  
- Just enable harvester timer collection on all clients, regardless of spawn count or debug mode. This will get actual data the fastest  
- Another fix  
- Fixed tank check on Shadhar again because i'm bad at > vs >=  
- Fixed a bug that caused basher tentacle spawn timer not to work on Nzoth  
- Fixed a bug where Twilight Decimator timer didn't stop on phase 3 push for non mythic Vexiona  
- Cleanup shadhar code a little  
- Changed DBM GUI frame size from 800 x 510 to 800 x 600, extending height of frame a bit.  
- Open up CheckNearby function access to 3rd party mods  
- Show count in void eruption timer  
- Shorten SAY countdown text on muttering.  
- Tweaks to option defaults for ra-den add switch warnings and tweaks to raden respawn time  
- Tweaks to improve Drestagath antispam for multiple tentacles dying at once  
- Tone down descolation hand holding a litte. telling entire raid to help soak is incorrect advice. the help soak warning is now off by default and you can enable it if you're one of people who's job is to do this. Otherwise, a general target warning will be shown in it's place to rest of raid.  
- Fixed logic in breath update. because I was using :Update method instead of starting a new timer, I was forgetting a step, where I needed timer progress value not timer remaining one.  
    Also floor values to 10th deciminal for good measure so it doesn't start anything obnoxious like a 17.326262362 timer. Hopefully no further issues from this. If this still doesn't work I'll scrap fancy update method and just use fresh timers which will definitely work, but I want to try this last test of live updating an existing timer instead of replacing with new one.  
- Pre warn when Hentai's energy is high and agony is 1-2 tentacle deaths away  
    Added Hentai's mythic berserk.  
- Sometimes, it's not clear that some warnings only apply to heroic, or mythic. So now, special warnings that are only going to appear on heroic or mythic difficulty will show heroic or mythic difficulty dungeon journal icon next to special warning option in GUI (if supported by the mod. This was already done for Nyalotha mods).  
- Re-added the 3 dodge special warnings, but made them off by default. mythic raiders might want extra spam for the adds dying triggering these things, but it should be opt in. It's actually not that spammy either so my reaction to remove them entirely might have been premature kneejerk  
- Fix infoframe option text for Hentai boss  
- Added likely ra-den respawn time  
    Added cast count to charged bonds, gorge essence, and corrupted existence timers  
- Insanity bomb yell off by default to reduce spam. it sitll does countdown yell which makes sense, but initial apply not needed  
- Updated most encounters to use spell substitutions for shorter timer names where possible. Remember, this can always be disabled in timer options so timers always display original spell names.  
    Changed Ra-den to use earlier P2 trigger and improved initial P2 timers  
- Add carapaces new berserk  
