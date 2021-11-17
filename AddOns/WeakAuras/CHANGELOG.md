# [3.7.3](https://github.com/WeakAuras/WeakAuras2/tree/3.7.3) (2021-11-02)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/3.7.2...3.7.3)

## Highlights

 TOC Update for Retail and a few new features/additions

Remove ExternalAddons API as it was broken and unused

More preparation for Nested Groups 

## Commits

Casey Raethke (1):

- Add UNIT_RESISTANCES to Character Stats trigger

InfusOnWoW (22):

- Remove accidental debug print
- Ensure that on drag start we select the dragged aura
- Document that DuplicateAura does not copy children
- Remove unused parameter from internal function
- Simplify filterAnimPresets
- Simplify code around deletion of dynamic groups
- Remove reference to dead regionType "timer"
- PickDisplay: Adjust for nested groups
- Recursively add parents, grandparents, etc
- Prepare group for nested
- Skip sub groups in shift multi selection
- Add Spirit to Character Stats
- Use .data.id instead of GetTitle()
- ExternalAddons: Remove it
- BCC: Fix combo points not updating on target change
- AuraBar: Fix SetInverse not inversing overlays
- Fix reseting of x/y offset on auras being moved into a dynamic group
- Swing Timer: Note that the trigger is not correct in BCC
- Fix conditions not being unapplied correctly in collapse
- Add support for Charged Combo Points with Kyrian Legendary
- Text Replacements: Add Custom Variables with descriptions
- Try to preserve names on importing

Lynn (1):

- TTS: Save value.message_voice as number instead of string

Stanzilla (1):

- Update TOC for Retail Patch 9.1.5

mrbuds (2):

- enable TTS on classic_era and fix error for tbc
- swing timer: fix spell that reset swing not starting swing timer by waiting a frame after the spell so "isAttacking" has correct state

