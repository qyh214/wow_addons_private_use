# True Stat Values

## [1.5.4](https://github.com/MSchiavi/TrueStatValues/tree/1.5.4) (2026-04-25)
[Full Changelog](https://github.com/MSchiavi/TrueStatValues/commits/1.5.4) [Previous Releases](https://github.com/MSchiavi/TrueStatValues/releases)

- Add automated release workflow (#35)  
    Releases are now built and published via BigWigsMods/packager when a tag is  
    pushed. Output goes to GitHub Releases and CurseForge (project 437378). The  
    .toc Version is now @project-version@ so the packager substitutes the tag at  
    build time, removing the need for a manual version bump.  
    Co-authored-by: Claude Opus 4.7 (1M context) <noreply@anthropic.com>  
- Use issecretvalue checks to prevent secret-value taint errors (#34)  
- up version (#33)  
- Only recalculate rating out of combat (#32)  
- Fix  (#29)  
    * Update Tooltips.lua  
    * Update Tooltips.lua  
    * Update Tooltips.lua  
    * Update Tooltips.lua  
- Fix SECRET frame strata error in tooltip progress bar (#31)  
    * fix: guard against SECRET frame strata in tooltip progress bar  
    GameTooltip:GetFrameStrata() can return "SECRET" which is not a valid  
    argument for SetFrameStrata(). Fall back to "TOOLTIP" strata instead.  
    Fixes #30  
    * fix: hardcode TOOLTIP strata to avoid taint error  
    GetFrameStrata() on GameTooltip returns a tainted value that cannot  
    be compared, causing "attempt to compare local 'strata' (a secret  
    string value tainted by TrueStatValues)" errors. Since the bar is  
    always on a tooltip, just hardcode the strata.  
    Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>  
    ---------  
    Co-authored-by: Claude Opus 4.6 (1M context) <noreply@anthropic.com>  
- Fix frame width error (#28)  
    * implement custom bar for stats  
    * bump version  
- fixed in what seems like 95% of cases ? (#25)  
- enhancement for "Stat by X" in item descriptions (#24)  
- added is secret check to value (#21)  
- Updade for Midnight (#19)  
- Update TrueStatValues.toc  
    .5 and .7  
- 11.2  
- update toc (#18)  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- update game version (#17)  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- voodoo mastery in black list (#16)  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- 11.1 interface (#13)  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- update (#10)  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- update version (#9)  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- Mastery rating bug (#8)  
    * handle mastery rating from other addons.  
    * mastery fix  
    * comment  
    * version bump  
    ---------  
    Co-authored-by: MSchiavi <mmschaivi45@gmail.com>  
- Merge pull request #6 from MSchiavi/leech\_vers\_bug  
    Black list for abiltiies that have secondaries in the name  
- version  
- black list for abiltiies that have secondaries in the name  
- Merge pull request #5 from nanjuekaien1/patch-2  
    Update TrueStatValues.toc  
- Update TrueStatValues.toc  
- Merge pull request #4 from nanjuekaien1/patch-1  
    Update TrueStatValues.toc  
- Update TrueStatValues.toc  
- version number  
- typo  
- updated author  
- Merge pull request #3 from Hinalover/patch-1  
    Correct Stats to use Pre-diminishing Returns  
- Correct Stats to use Pre-diminishing Returns  
- update .toc  
- Merge pull request #1 from MSchiavi/tww  
    Secondary Conversions for TWW  
- Merge branch 'main' of https://github.com/MSchiavi/TrueStatValues into tww  
- updated code owners  
- Merge pull request #2 from Xorban/master  
    11.0.2  
- Merge branch 'tww' of https://github.com/MSchiavi/TrueStatValues into tww  
- code owners file  
- Update TrueStatValues.lua  
    Co-authored-by: Serghei Iakovlev <egrep@protonmail.ch>  
- Update TrueStatValues.lua  
    Co-authored-by: Serghei Iakovlev <egrep@protonmail.ch>  
- added terts  
- Merge branch 'xorban-11-02' into tww  
- update packages  
- Folder removed and Toottips updated  
- Final fix  
- Merge branch 'main' of https://github.com/MSchiavi/TrueStatValues  
- Fix  
- tww conversions  
- Merge remote-tracking branch 'origin/helpingout'  
- fixes - in evoker mastery name.  
- remove commas before tonumber conversion  
- if statement to check nil's  
- removed this print statement  
- updated table values  
- updated events to callbacks  
- updated conversion values  
- init 1.0  
