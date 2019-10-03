# <DBM> Outlands

## [r668](https://github.com/DeadlyBossMods/DBM-BCVanilla/tree/r668) (2019-09-24)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-BCVanilla/compare/r667...r668)

- TOC Bump  
- Damage Shield special warning for Majordomo now off by default. A new general warning that's on for everyone by default takes it's place. If special warning is re-enabled, general warning will auto hide. Reason being, melee generally don't stop attacking for it and 2, casters like to know that it was melee shield in a general announce and they are safe for another 30 seconds.  
- Fix same impossible lua error here as well  
    in Addition, retail now has better submerge detection using a retail only method. No longer relies on yells. Too bad that can't be used on classic :\  
- Tweaked Immolate warning to now be off by default on Garr, it still felt spammy enough to be an opt in warning, not opt out. Spam shouldn't be something that's ever defaulted  
    Added ignite mana timer to Baron Geddon  
    Added Inferno timer to Baron Geddon  
    Fixed bug with countdown yell for bomb on Baron Geddon  
    Made Bomb timer more robust on baron Geddon, in event actual debuff is resisted by target.  
    Fixed curse timer on Gehennas with live classic data.  
    Removed Doom Cast timer from Lucifron. he spends half the fight casting doom,it doesn't really need a cast timer showing that.  
    Added timers for first casts of doom and curse to Lucifron  
    Added optional (off by default) Conflagration target warning to Magmadar  
    Re-enabled Panic timer on Magmadar now that I've seen an agreeable amount of live classic timer data to confirm it.  
    Disabled all Deaden Magic warnings/timers on Shazzrah by default. That stuff can be spammy and spam should be opt in, not opt out.  
    Added Counterspell cooldown timer to Shazzrah  
    Fixed Gate timer on shazzrah being too slow.  
    Fixed initial curse timer on Shazzrah being too slow  
- Fix stray )  
- Added teleport and shield cooldown timers to Majordomo  
    Added remaining sons warning to ragnoaros (for sons 3 2 and 1)  
    Added missing Wrath of rag timer for first wrath cast after sons phase has ended.  
    Fixed ragnaros mod so that if you are sitting outside, you won't accept syncs that submerge phase has begun.  
- Fix same MC bugs that were fixed in DBM-Classic  
- Merge pull request #1 from Mini-Dragon/master  
    zhCN update  
- zhCN update  
- Include project version in toc  
- adjust packager call  
- move to the BigWigs community packager  
