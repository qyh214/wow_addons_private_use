# [3.4.2](https://github.com/WeakAuras/WeakAuras2/tree/3.4.2) (2021-05-27)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/3.4.1...3.4.2)

## Highlights

 - More work on nested groups.
- Make more WeakAuras functions private.
- BCC fixes and model updates. 

## Commits

InfusOnWoW (13):

- Prepare another small part of WeakAurasOptions for nested
- Prepare TriggerTemplates for nested
- Make Private accessible for Templates
- Prepare TriggerOptions for nested
- Prepare another part of ActionOptions for nested
- Prepare GetOverlayInfo for nested
- Prepare SortDisplayButtons for nested
- Prepare automatic frame level setting for nested
- Slightly Simplify ProgressTexture Options code
- Cast Trigger: Deprecate the old Spell Name check
- Move Swing Timer remaining time check to the right place
- Improve scam checks
- Fix regression on dragging auras

Stanzilla (3):

- Move SortDisplayButtons to private namespace (#3116)
- Update WeakAurasModelPaths from wow.tools
- Update WeakAurasModelPaths from wow.tools

emptyrivers (1):

- privatise DisplayToString

mrbuds (3):

- swing timer: do not reset swing on SPELL_EXTRA_ATTACKS
- Swing Timer trigger, fix remaining time check fixes #3106
- fix CorrectSpellName for linked spells on TBC

