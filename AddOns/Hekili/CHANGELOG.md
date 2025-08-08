# Hekili

## [v11.2.0-1.0.0e](https://github.com/Hekili/hekili/tree/v11.2.0-1.0.0e) (2025-08-07)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.2.0-1.0.0d...v11.2.0-1.0.0e) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Merge pull request #5042 from syrifgit/sub-rogue-rupture  
    Sub Rogue - Account for not talenting Flagellation  
- Merge pull request #5041 from syrifgit/11-2-housekeeping  
    Housekeeping  
- Sub Rogue - Account for not talenting Flagellation  
    APL gets weird because when not talented, flagellation cooldown returns 0.  
    I worked around a lot of this last season, but this case was never noticed because literally every sub build used flag. Now that there's a no-flag build, it has popped up.  
    Fixes https://github.com/Hekili/hekili/issues/5035  
- Housekeeping  
    `raid&boss` will be undone the next time any of these are exported to pack strings  
- Merge pull request #5037 from syrifgit/elemental-apl  
    Elemental APL  
- review notes  
- Merge pull request #5034 from syrifgit/11-2-sin-tweak  
    Sin Rogue - Rupture Fix  
- Merge pull request #5039 from syrifgit/marksmanship-apl  
    Marksmanship apl + dark ranger tidy up  
- Frost DK Set Bonus  
- Merge pull request #5032 from syrifgit/frostbane  
    Death knight Fixes  
- variable math, breath CD  
- Update HunterBeastMastery.lua  
- Marksmanship APL + tidy up  
    ## APL Sync: https://github.com/simulationcraft/simc/commit/0fb177014fc85f5688c383f812d22ae0c1aa2ecf + https://github.com/simulationcraft/simc/commit/fd7df65a34caa11d0a3b194482cadbf9ae24e458  
    ## BM APL  
    Fix trinket lines  
    ## Dark Ranger  
    Fix black arrow in flight mechanics, this successfully stops multishot from flickering while it's in flight due to tricks/beast cleave being applied on impact.  
- Elemental APL  
    Updated APL: https://github.com/simulationcraft/simc/commit/6d828cebb86355a4148a0cf11d9c8f4b293b350e  
- Sin Rogue - Rupture Fix  
    My custom APL tweak fell apart on the new APL when facing less than 5 targets (the cap for the stacking rupture talent).  
    This is the custom edit that forces more rupture on the same target for users who do not enable target swaps, to spread via carnage talent and not grief their damage.  
    Fixes https://github.com/Hekili/hekili/issues/5030  
- spellID  
- Fix totem alias  
- Update DeathKnightUnholy.lua  
- Update DeathKnightFrost.lua  
- oops  
- SimC Syntax  
- Unholy had some spellID changes  
- fix Frost Strike being unknown while frostbane is up  
    Might need to examine spell overrides more broadly, maybe?  
    Fixes https://github.com/Hekili/hekili/issues/5031  
