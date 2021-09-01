# [3.7.0](https://github.com/WeakAuras/WeakAuras2/tree/3.7.0) (2021-08-23)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/3.6.1...3.7.0)

## Highlights

 - Added a few new sounds
- Added raid role and raid mark to bufftrigger2
- Classic fixes
- Texture support for aurabar overlays
- and more! 

## Commits

InfusOnWoW (10):

- Model Fix small option issues
- BT2: Add optional "Raid Mark"
- Add optional role + roleIcon to BT2 state
- Fix animation playing for models
- Sounds: Add Double Whoosh
- Sounds: Add a Oh No sound
- Sounds: Add Generic Errror Beep
- Sounds: Add a better Squeaky Toy Sound
- Sounds: Add Tada Fanfare
- Fix Enchant Trigger for Chinese locale

Stanzilla (5):

- Update WeakAurasModelPaths from wow.tools
- Update WeakAurasModelPaths from wow.tools
- Update WeakAurasModelPaths from wow.tools
- Update WeakAurasModelPaths from wow.tools
- Update WeakAurasModelPaths from wow.tools

Vardex (1):

- Change the transmission version for nested exports

mrbuds (13):

- Add deficit to health and power triggers fixes #3273
- bufftrigger2: trigger number was missing for some text replacement's tooltip
- Enable raidMark for classic & bcc for bufftrigger2 trigger And fix typo in tooltip
- Add texture support to aurabar overlays
- GetHitChance : fix potential nil error
- Character Stats trigger: add hitrating and hitpercent on bcc, and update on PLAYER_DAMAGE_DONE_MODS event criticalchance wasn't update when changing stance on warrior
- Character Stats trigger: fix criticalpercent fixes #3256 on classic & bcc it didn't use GetSpellCritChance on retail it returned min GetSpellCritChance value instead of max
- set region's alpha setter and getter only for regions with a default alpha property fixes #3257
- set region.regionType in region's create function this give visibility of regionType in regionPrototype.create
- bcc: add "zone id" load condition api is back for builds 2.5.1 and 2.5.2
- Swingtimer (#3255)
- bcc: update encounter ids tooltip reflect changes made by blizzard with build 2.5.1.38453
- Add pets support for BT2, Health, Cast and Power trigger

nullKomplex (1):

- Fix Weapon Enchant Trigger name state value.

