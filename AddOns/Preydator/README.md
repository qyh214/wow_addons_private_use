# Preydator

Preydator is a focused Prey Hunt companion addon for World of Warcraft, featuring Predator-inspired audio cues, a customizable hunt progress bar, and stage-based tracking built from Blizzard quest/widget APIs.

Current release: `v2.2.10`

Runtime safety note: In restricted instance content (`party`, `raid`, `scenario`, `delve`, `arena`, `pvp`), Preydator is intended to fail closed and keep runtime behavior inactive.

## What Preydator tracks

- Active prey quest and stage transitions in real time
- Out-of-zone state and fallback labels
- Stage-based progress display using Blizzard's exposed stage model
- Locale-aware hunt/achievement label normalization for non-English clients (prefix and difficulty marker parsing)
- Hunt Table achievement signal matching with strict mode boundaries and compact punctuation/title normalization handling
- Hunt Table mode memory stores only confirmed quest difficulty detections and reuses questID mappings to reduce locale/parsing drift

Important: Blizzard does not expose a true percent completion for Prey Hunts. Preydator uses stage transitions and fallback stage percentages.

- `Quarters`: `25 / 50 / 75 / 100`
- `Thirds`: `33 / 66 / 100` (default for new installs)

## Stage flow

1. **Scent in the Wind**
2. **Blood in the Shadows**
3. **Echoes of the Kill**
4. **Feast of the Fang**

## UI and layout features (2.0.3)

- New module runtime controls for Bar, Sounds, Currency, Hunt Table, and Warband
- Module-aware settings locking with reload detection when module state changes
- CPU optimizations for zone caching and reduced unnecessary update routes
- New installs start with the bar unlocked for quick placement; lock it in Options when finished
- 4K display support with corrected dropdown scaling and UI-scale normalization
- Account-wide prey unlock tracking for Nightmare difficulty
- Bar position persistence across reloads with resilient backup coordinate sync
- New Currency Tracker window for approved Prey currencies
- New Warband currency table with sortable columns and realm grouping
- Hunt Table tracker with grouping/sorting, reward icons, collapsible headers, and direct accept/open actions
- Warband `Prey Track (Alts)` with `N/H/Ni` available/completed modes and weekly-aware tracking snapshots
- Hunt Table achievement signals resolve from explicit questID criteria mappings only (no title/name fallback matching)
- Hunt Table achievement signals on higher-tier rows can cumulatively include unmet lower-tier mapped achievements for the same prey target while remaining questID/criteria anchored
- Session delta tracking for approved Prey currencies
- Theme support in currency windows: `Light`, `Brown`, `Dark`
- One-time What's New splash for currency launch (with Show Again in Advanced tab)
- Currencies tab now includes direct controls for tracker/warband visibility, tracked currency selection, random hunt cost context, and panel layout sliders

- Modular tabbed settings panel: `General`, `Display`, `Text`, `Audio`, `Advanced`
- Compact Edit Mode quick-settings window
- Edit Mode click-to-open behavior on the Preydator element
- Outside-click dismiss behavior while Edit Mode quick-settings is open
- Lock/unlock positioning and persistent center-relative coordinates
- Display controls: width, height, scale, font size
- Vertical bar mode controls: orientation, fill direction, vertical scale, dedicated width/height, text side/alignment, and vertical percent controls

## Display customization

- Texture presets
- Color controls:
	- Fill color
	- Background color
	- Title color
	- Percent color
	- Tick mark color
	- Border color (optional linked-to-fill behavior)
- Percent display modes:
	- In Bar
	- Above Bar
	- Above Ticks
	- Under Ticks
	- Below Bar
	- Off
- Text Display mode for stage names: `Above Bar` or `Below Bar`
- Tick mark labels can be used as the percent display in vertical mode (`Show Percentage at Tick Marks`)
- `Display Spark Line` toggle (default: off)
- Fill and tick rendering inset so visuals stay inside the border at all scales

## Text and label system

- Full stage label editing for all 4 stages
- Prefix + suffix label system
- Dedicated `Out of Zone Prefix` and `Ambush Prefix`
- Ambush/Bloody suffix fields support exact variable markers (`preyTargetName`, `bloodyCommandSourceName`) or literal custom text
- Label modes:
	- Centered
	- Left (Prefix only)
	- Left (Suffix only)
	- Right (Suffix only)
	- Right (Prefix only)
	- Separate (Prefix + Suffix)
	- No Text

## Audio features

- Stage 1-4 sound selection
- Ambush sound selection
- Echo of Predation sound selection (Nightmare prey encounter)
- Sound channel selection
- Sound enhancement control
- Stage sound test buttons (1-4), Ambush test, Bloody Command test, and Echo of Predation test button
- Custom sound file add/remove in settings UI
- Protected default sound files cannot be removed
- Sound selection uses a dedicated searchable picker popup (15 visible rows with scrollbar) for Stage 1-4, Ambush, Bloody Command, and Echo of Predation
- Sound list order is stable: `None`, custom addon-local sounds, bundled Preydator defaults, then extra registered sounds from LibSharedMedia when available
- Ambush alert trigger supports prey-name matching plus fallback ambush phrase matching (including trap callouts) while an active prey hunt context is valid
- Bloody Command alert trigger: Nightmare prey only, stages 1-3
- Existing custom/addon-local sound selections are preserved across updates, including migrated addon-local path casing/format variants
- The legacy 2.2.0 audio migration prompt is retired so updates cannot accidentally replace saved sound choices

Bundled default files:

- `predator-alert.ogg`
- `predator-ambush.ogg`
- `predator-snarl-01.ogg`
- `predator-torment.ogg`
- `predator-kill.ogg`
- `well-we-ve-prepared-a-trap-for-this-predator.ogg`
- `predator-kills-its-prey-to-survive.ogg`
- `echo-of-predation.ogg`

2.2.0 default mapping:

- Stage 1: `predator-ambush.ogg`
- Stage 2: `predator-snarl-01.ogg`
- Stage 3: `predator-torment.ogg`
- Stage 4: `predator-kill.ogg`
- Ambush trigger: `well-we-ve-prepared-a-trap-for-this-predator.ogg`
- Bloody Command trigger: `predator-kills-its-prey-to-survive.ogg`
- Echo of Predation: `echo-of-predation.ogg`

## Visibility and icon behavior

- `Only show in prey zone`
- `Show in Edit Mode preview`
- `Disable Default Prey Icon`
- Bar-side zone resolution includes a self-contained fallback that can certify the current prey map from a fresh tracked prey-widget setup signal when Blizzard zone APIs are unresolved (independent of Hunt Scanner cache).

## Diagnostics and debug

- `/pd inspect` live diagnostic output
- `/pd qinspect` quest-focused diagnostic output
- `/pd hinspect` hunt snapshot diagnostic output
- Debug system defaults to off
- Advanced tab `Enable Debug` toggle
- Slash debug controls remain available:
	- `/pd debug on`
	- `/pd debug off`
	- `/pd debug show`
	- `/pd debug clear`

## Roadmap progress snapshot

- Epic 1: Approved Currency Ledger (MVP) - Completed and expanded through `v1.7.0`
- Epic 2: Hunt Source Scanner - Planned
- Epic 3: Weekly Hunt Cap Tracker - Planned
- Epic 4: Prey Achievement Gap Highlighter - Planned
- Epic 5: Reward Intelligence and Cost Context - In progress

## Slash commands

- Entry point:
	- `/pd`

- UI / bar controls:
	- `/pd options` - open the Preydator options panel.
	- `/pd show` - force the progress bar visible.
	- `/pd hide` - return the progress bar to automatic visibility.
	- `/pd toggle` - toggle forced visibility on/off.

- Debug log controls:
	- `/pd debug on` - enable debug logging.
	- `/pd debug off` - disable debug logging.
	- `/pd debug show` - print the latest debug log lines.
	- `/pd debug clear` - clear stored debug log lines.

- Inspect diagnostics:
	- `/pd inspect` - print live addon diagnostics to chat.
	- `/pd inspect bs` - send live addon diagnostics to BugSack.

- Quest inspect diagnostics:
	- `/pd qinspect` - inspect the active prey quest.
	- `/pd qinspect <questID>` - inspect a specific quest ID.
	- `/pd qinspect bs` - send active prey quest diagnostics to BugSack.
	- `/pd qinspect <questID> bs` - send specific quest diagnostics to BugSack.

- Hunt snapshot diagnostics:
	- `/pd hinspect` - print the current hunt snapshot to chat.
	- `/pd hinspect bs` - send the current hunt snapshot to BugSack.
	- `/pd hinspectcopy` - print the last captured hunt payload.
	- `/pd hinspectcopy bs` - send the last captured hunt payload to BugSack.

Removed legacy aliases: `/preydator`, `/pd open`, `/pd mem`, `/pd memory`, `inspectquest*`, and `huntdebug*`.

## Optional custom audio

Place your own `.ogg` files in:

```text
Interface/AddOns/Preydator/sounds/
```

Then add/select them in settings and run `/reload` if needed.

Accepted input formats in the custom file field:

- bare name (example: `my-alert`)
- explicit `.ogg` filename (example: `my-alert.ogg`)
- full path starting with `Interface\AddOns\Preydator\sounds\`

## Issues and feedback

Please report bugs, feature requests, or visual/audio issues at:

**[https://github.com/RagingAltoholic/Preydator/issues](https://github.com/RagingAltoholic/Preydator/issues)**
