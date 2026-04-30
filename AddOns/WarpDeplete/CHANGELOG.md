# WarpDeplete

## [v5.1.0](https://github.com/happenslol/WarpDeplete/tree/v5.1.0) (2026-04-22)
[Full Changelog](https://github.com/happenslol/WarpDeplete/commits/v5.1.0) [Previous Releases](https://github.com/happenslol/WarpDeplete/releases)

- chore: Bump version  
- feat: Show forces count in tooltips for midnight (#149)  
    Adds back the forces count as a fixed string in mob tooltips. Custom formatting is removed for now, since it would involve wrangling with secret values which is very error-prone.  
- chore: Bump version  
- fix: Add missing fonts and textures  
- chore: Bump version  
- fix: Check for secret values in UNIT\_DIED event (#141)  
- chore: Bump version  
- fix: Update addon for Midnight pre-patch (#138)  
    * Added support for Midnight pre-patch  
    * UNIT\_DIED is now its own event instead of a subevent of CLEU  
    * C\_ChallengeMode.GetCompletionInfo has been removed, using C\_ChallengeMode.GetChallengeCompletionInfo instead  
- fix: Use category id to open addon settings (#136)  
- chore: Update interface version russian description  (#134)  
- chore: Bump version  
- feat: Add checks for midnight expansion (#133)  
- chore: Add interface version for midnight (#132)  
- chore: update gitignore (#131)  
- chore: Update all locales (#129)  
- chore: Update embeds.xml (#130)  
- fix: Fix shared media dependency url (#128)  
- fix: Fix external dependency links again (#127)  
- fix: Fix external dependency references (#125)  
- chore: Remove vendored dependencies and switch to automatic packaging (#124)  
