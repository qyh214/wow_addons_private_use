# [5.5.5](https://github.com/WeakAuras/WeakAuras2/tree/5.5.5) (2023-06-18)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/5.5.4...5.5.5)

## Highlights

 - Updates to the BW/DBM triggers
- Bug fixes
- Talent load checks now use talent instead of spell id 

## Commits

InfusOnWoW (14):

- Rework Talent load to check via talent id instead of spell id
- Remove talents that don't exist
- Rewrite Two Column Drop Down
- Make Two ColumnDropDown work with table values
- Fix lua error if GetSpecialization returns nil
- Prevent an empty PlaySound from stopping sounds
- Model: Fix setting of unit models in Wotlk
- Animation Options: Fix rotate amount being invisible
- DBM Stage Trigger: Fix if loaded after SetStage has already fired
- BW Timer: Fixes lua error if remaining is a string
- Fix TexturePicker Search box
- BT2: Fix unloading auras prevents the next schedule of a recheck
- In ActivateEnvironment for tsu variables, don't create the region
- Tweak Ignore Update PR

Logan Tracy (1):

- Added Unleash Life template for Restoration Shaman

Stanzilla (2):

- Update Wrath TOC for 3.4.2
- Spelling fixes

mrbuds (5):

- Fix "BigWigs Timer" trigger remaining time option
- BigWigs Stage trigger: set stage back to 0 after encounter end
- Init BigWigs stage value when registering BigWigs_SetStage
- BigWigs triggers: rename "Spell Id" field to "Key"
- Fix printed nil on updating aura

