# [3.0.6](https://github.com/WeakAuras/WeakAuras2/tree/3.0.6) (2020-11-09)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/3.0.5...3.0.6)

## Highlights

 Mostly bug fixes but we now also let you set icons via conditions 

## Commits

InfusOnWoW (36):

- Fix MoverSizer lua errors if the mover has no position
- Don't hide the Options window on import
- Fix Custom Variables Validation to ignore additionalProgress
- Introduce "elapsedTime" as a conditionType
- Fix TexturePicker drop down
- Options: Show a arrow pointing to offscreen auras
- BT2 Multi: Guard against a empty string for count check
- Fix anchoring of MoverSizer to Groups
- Add missing conversion code for IconSource
- Fix Importing from chat if Options were never opened
- Tweak Custom Variables validation
- Add missing file
- Add a Lock Positions button in the toolbar
- Improve Item Bonus Id checks
- Fix BarModels breaking if hidden at 0 width
- In the Item Bonus ID actually list legendaries for the current spec
- Add a "None" choice to Covenants
- Validate Custom Variables
- Simplify AddCodeOption api
- Don't send overlay glow event if weakauras is paused
- Fix Group's selfPoint
- Use the right states for dynamic conditions
- Use browse icon in more places
- Allow selectiong Icon Source/Icon via Conditions
- Fix adding new aura without a time condition not unscheduling old check
- Fix removing a condition check not calling modify
- Fix wrong argument in call to ClearAndUpdateOptions in AuraBar.lua
- Don't error on trying to import a update
- Fix models not showing up in some cases
- Resize the WeakAuras window if it's bigger than the screen
- Make WA_Utf8Sub resilent against trying to format numbers
- Fix errors in opening TextEditor for Custom Checks
- Fix importing icon auras before the Options were opened
- Add the Error Frame as a destination for messages
- Templates: Fix Slice and Dice
- Fix parent for custom anchoring

Stanzilla (3):

- Update README.md
- Formatting and cleanup
- Change Discord server link

mrbuds (1):

- Classic: add support for MAINTANK and MAINASSIST filter (#2636)

