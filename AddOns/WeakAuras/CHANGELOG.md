# [2.17.5](https://github.com/WeakAuras/WeakAuras2/tree/2.17.5) (2020-05-04)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/2.17.4...2.17.5)

## Highlights

 - Mostly bug fixes with a few smaller features sprinkled on top 

## Commits

InfusOnWoW (19):

- Fix Alternate Power staying around after leaving vision
- Unit Characteristics: Add UnitClassification
- Text: Add shadow options
- Text: Remove old workaround for SetText
- Fix the order in SubRegionOptions
- Fix UnitIsUnit check for Unit Characteristics
- Fix specific unit for unit type triggers
- Conditions External Glow: Fix frame chooser
- Fix tracking of buffs on bosses
- Fix some events being handled even while WeakAuras is paused
- Add new feature strings to various places
- Set FrameLevel again after setting frame strata
- Load: Add support for multi zone names
- Fix spell name and spell id conditions for Cast Trigger
- Add Attack Power to the Character Stats
- Custom Trigger: Add fake events for UNIT:unit
- Add Dead/Ghost and Disconnected filter to various triggers
- BT2: Add a hostility check for nameplates
- Enable the ignoreSelf option for nameplates

Stanzilla (1):

- Add a way to overwrite default font and font size (#2169)

asaka-wa (2):

- Fix anchor (#2175)
- Update wiki links to new Custom Code Blocks page (#2162)

mrbuds (5):

- templates: add Show on Ready Also add condition isNotUsableBlue for basic Show on cooldown & Show on Ready partially fixes #797
- refactor anchor & glow to unitframe monitoring (#2165)
- fix default options not loaded for WeakAuras addon fixes #2177 (#2179)
- DG anchored to Unit Frames: fix #2051 - anchor to hidden frame when can't find a unitframe - handle new LibGetFrame Callback: FRAME_UNIT_REMOVED
- disable trigger "Crowd Controlled" for classic fixes #2145

nullKomplex (2):

- Profiling Improvements
- Fix inconsequential typo.

