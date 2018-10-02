# Lib: ResInfo-1.0

## [25](https://github.com/phanx-wow/LibResInfo/tree/25) (2016-11-18) [](#top)
[Full Changelog](https://github.com/phanx-wow/LibResInfo/compare/24...25)

-   Fix error in RESURRECT_REQUEST in raids  
    Resolves #13  
-   Merge pull request #12 from p3lim-wow/fix-11  
    Add the expiration time to hasPending on combat res spells  
-   Add the expiration time to hasPending on combat res spells  
    Fixes #11  
-   Cleanup  
    - Updated URLs to use HTTPS instead of HTTP  
    - Fixed some indentation  
    - Moved libraries into a Libs subdirectory  
-   Merge pull request #7 from p3lim-wow/fix-debugprints  
    Remove redundant debug print  
-   Merge pull request #9 from p3lim-wow/fix-player-res-status  
    Fix status for ghosted player  
-   Clean up inconsistent quote styles  
-   Merge pull request #6 from p3lim-wow/fix-combatres  
    Track combat resurrections by the debuff it leaves on the target  
-   Merge pull request #8 from p3lim-wow/fix-pending-onused  
    Clear pending or reincarnation in scenarios where the alive logic fails  
-   Fix status for ghosted player  
-   Clear pending or reincarnation in scenarios where the alive logic fails  
    This can happen when hasPending/hasReincarnation still has record of the player but  
    isDead has no record.  
-   Only allow the resurrecting logic to execute if the unit does not have reincarnation  
    The resurrecting spell is also present (but hidden) on reincarnation, so if the unit can  
    reincarnate, ResPending callback will fire twice, once for reincarnation and once for  
    resurrecting, which means UnitHasIncomingRes will return nil on the second callback.  
-   Remove redundant debug print  
-   Track combat resurrections by the debuff it leaves on the target  
-   Fix inconsistent quoting style  
-   Merge pull request #5 from p3lim-wow/fix-reincarnation  
    Add support for Reincarnation  
-   Align the variable assignment block again  
-   Add support for reincarnation  
-   Add items: Brazier of Awakening, Failure Detection Pylon  
-   Fix typo  
-   Add X-Category to TOC  
