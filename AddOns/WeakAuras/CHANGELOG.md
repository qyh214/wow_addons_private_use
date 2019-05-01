# [2.12.0](https://github.com/WeakAuras/WeakAuras2/tree/2.12.0) (2019-04-26)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/2.11.6...2.12.0)

## Highlights

 - Aura Snapping: A new feature to help you move around and anchor your auras on your screen. Read more about it in this [blog post](https://www.patreon.com/posts/positioning-now-25513912).
- Dynamic Groups Rewrite: Dynamic Groups have been rewritten from the ground up for better performance and new features. Read more about it in this [blog post](https://www.patreon.com/posts/dynamic-groups-26311053).
- You can now duplicate whole groups!
- Buff tracking now allows you to select multiple debuff classes!
- The usual round of bug fixes and improvements! 

## Commits

InfusOnWoW (23):

- Fix tooltip frame not having a parent and thus eating mouse events (#1287)
- BuffTrigger2: Add code to recheck auras on PLAYER_ENTERING_WORLD (#1280)
- fix error on data.progressPrecision = -0 (#1277)
- Fix stupid errors
- BuffTrigger2: Fix GUID
- Wrap Anchoring in pcall and show a somewhat descriptive error message
- Removing the "Hide: Custom" option from most triggers
- BuffTrigger2: Fix UpdateMatchData not detecting changes in debuffClass
- Revert "Make cooldown tracking work like in 2.11.3"
- Add a bit of profiling around custom text update via "trigger update"
- Add more magic to TwoColumnSelectionBox
- Add PLAYER_ENTERING_WORLD to isMounted check
- Remove duplicated functions introduced in fa75abcc
- Don't use magic "/" in displayname, instead use a array
- Fix UnitIsUnit check to check both units
- Make Spell Charges use GetSpellCount in more cases
- Make cooldown tracking work like in 2.11.3
- Optimize Unit Change events for units that have no events
- Reset the smooth progress value just before showing a progress bar
- Fix models not showing up
- Add a Selection ComboBox that can show a two depth hierarchy
- Fix showing/enabling of various precions/custom text options
- Icon: Make "Show Cooldown Text" toggle work with OmniCC

Nightwarden24 (5):

- Refactor class and race types; drop the "LibBabble-Race-3.0" library
- Fix PR #1237
- Refactor class and race types; drop the "LibBabble-Race-3.0" library
- Use global (Blizzard) strings instead of localized for some types
- Register the "Fira Mono Medium" font for RU

Stanzilla (8):

- sort .luacheckrc entries a-z
- move remaining inline luacheck globals to the rc file
- add discord notifications for when builds fail
- remove debug print
- improve changelog generating script
- stricter luacheck on the CI
- fix botched revert
- Revert Refactor class and race types; drop the "LibBabble-Race-3.0" library

emptyrivers (18):

- add new feature indicator
- remove unnecessary AnchorFrame call. (#1300)
- Custom Grow & Sort (#1272)
- collect errors from login thread (#1286)
- regenerate option name and key if necessary (#1281)
- add new feature indicator
- tweak thumbnail code AGAIN
- remove duplicated fields in table constructors
- Add Dynamic Group grid layout
- set dynamic group selfPoint again (#1231)
- move data.expanded to our collapsed data paradigm
- Add arc length option
- add limit option
- don't reset option name and option key
- set option max to the *max*, not the min
- guard against nil (#1220)
- Optimize and rewrite dynamic groups
- Add PCRE2 to vscode settings

mrbuds (23):

- fix Cast trigger with inverse = true not showing correctly after loggin
- Template: fix victory rush
- Template: add buff = true for Arcane Power
- Crucible of Storms encounter ids (#1289)
- Fix tooltip frame not having a parent for AuraBar (#1288)
- check icon visibility for tooltip (fix #1283) (#1284)
- fix auras with strata=TOOLTIP highjacking cursor's clicks (#1270)
- BuffTrigger2: multiselect for buffclass (#1266)
- don't require a reloadui for updating uiscale
- Clear region scripts on hiding options and disable mouse (#1264)
- Add alignment snapping for auras and groups (#1254)
- BT2: add matchCountPerUnit text and condition
- BT2: add debuffClass condition
- BigWigs trigger: fix error when checking remainingTime
- change position of movers when they get out of screen
- add buttons for moving auras by 1 pixel (#1250)
- template: fix icefury load condition
- sanitize more input
- use C_Texture.GetAtlasInfo instead of GetAtlasInfo GetAtlasInfo will be removed next expansion
- sanitize more input #1244
- Update bug_report.md
- optimize and fix parenting issue on WeakAuras.DuplicateAura
- Allow duplicate on groups (#1226)

