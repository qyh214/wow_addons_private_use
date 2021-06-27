# Deadly Boss Mods Core

## [9.0.30](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.30) (2021-06-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.29...9.0.30) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Prep new release  
- Changed how phasing is done to improve callbacks for weak auras/3rd party mods after a requesst and some discussion with other authors. This basically means DBM now has a phase change callback that's much cleaner to use than trying to hook DBM\_Announce objects looking for stage change messages, since not all mods that use phasing actually announce phase changes this way.  
- Update koKR (#595)  
- Add some prints  
- Some spell renames and stuff from latest journal update, so i'm not confused later  
    Also added optional (off by default) stack counter for tarragrue debuffs  
- Sync fix (#594)  
- Adjustment to fatescribe based on journal updates  
- Delete license.txt (#591)  
- Sync delta code changes. (#590)  
- Fix the fix to the fix  
- Fix last  
- Add 15 seconds per hotfix  
- Add a link to BCC issues in issue templates. (#588)  
- Update Rohkalo from mythic testing, still WIP do to incomplete logs as well as blizzard breaking combat log  
    Updated Kel Thuzad from mythic testing. Also WIP and incomplete because blizzard designed fight is a crappy way that makes doing accurate timers very miserable.  
    Fixed a couple bugs on Raznal but didn't update it for mythic yet. ALSO a crappy fight to work on because blizzard hates the combat log and only 1 of literally 9 abilities is even in it.  
    Updated Sylvanas from heroic testing. Incomplete since literally no one saw phase 3 except for like two guild that got there because of a bugged phase 2, but still wiped a minute into it.  
- Few general cleanup in DBT (#587)  
    - Remove deprecated functions, these should have stopped being used for a LONG while  
    - Remove bar.owner usage, and reference DBT directly (memory saving as we're not defining another reference object)  
    - Define a default of numBars instead of using or checks everywhere.  
- Add zhCN for SOD (#586)  
- Sync DBT tweaks (#585)  
- Potential fix for bars not updating on enlarge? (#584)  
- Update koKR (#583)  
- prep alpha cycle  
