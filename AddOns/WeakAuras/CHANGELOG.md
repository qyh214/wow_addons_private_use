# [5.3.5](https://github.com/WeakAuras/WeakAuras2/tree/5.3.5) (2023-01-18)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/5.3.4...5.3.5)

## Highlights

 - Bug fixes 

## Commits

InfusOnWoW (20):

- SubText: Move SubRegion:SetVisible to the end
- Revert "Revert "Fix some regressions with text updates""
- Revert "Fix a regression with text updates"
- Remove old debug output
- Fix some regressions with text updates
- Weapon Enchant: Fix enchant trigger not parsing name correctly
- Make C_Timer callbacks use the better error reporting
- Fix typo in enUs.lua
- Revert "Don't give WeakAurasDisplayButtons global names"
- Texture: Add Rotate property for conditions
- Talents: Rework checking for active talents
- PlaySound on the master channel
- Improve TimerTick/Frame system
- Templates: Make Convoke the Spirits use the Exact Spell option
- Templates: Brewmaster Add Purified Chi buff
- Don't give WeakAurasDisplayButtons global names
- Temporary Enchant Tooltip parsing: Require a unit after time
- Options: Fix sounds being played from all auras on multi-selection set
- Fix pet being included in Smart Group with "Include Pets" in a raid
- SpinBox: Fix not being able to enter unchanged values

Stanzilla (6):

- Fix a regression with text updates
- Revert "Fix some regressions with text updates"
- Update Wrath TOC for Patch 3.4.1
- remove stray semicolons
- Remove very old Masque workaround that should no longer be needed
- Mark `checkDoublePercent` as optional in `ContainsPlaceHolders`

emptyrivers (6):

- be more careful about removing subscribers (#4239)
- unsubscribe text updates when text is not visible
- add media custom option
- adopt BAG_UPDATE_DELAYED
- ignore small deltas on numbers
- only run sort/grow when interesting state changes happen (#4205)

mrbuds (8):

- Models: fix SetTransform API for wotlk ptr
- Item triggers: restore disabled triggers for WOTLK PTR
- Cast trigger: safeguard nil error on WeakAuras.UnitChannelInfo
- Cast Trigger: fix channel not interrupting
- Classic: remove "Instance Type" load option, fix Spec Role & Raid Role
- add "Not Spell Known" load option
- Power trigger: add Max Power filter
- Health trigger: add Max Health filter

