# DandersFrames - Claude Code Project Guide

## Overview

DandersFrames is a custom party and raid frame addon for World of Warcraft (Retail/Midnight 12.0). It replaces the default Blizzard party/raid frames with highly configurable alternatives. The addon includes a full GUI settings panel, profile system, click-casting system, test mode, aura filtering, and an external API for Wago UI Pack integration.

**Author:** Danders
**Current Version:** 4.0.6
**Language:** Lua + XML (WoW addon)
**Slash Commands:** `/df` (settings), `/rl` (reload UI), `/dfarena` (test arena mode)

## Important Workflow Rules

- **Always present a plan before implementing major features or changes.** Outline which files will be modified, what will be added, and how it will work. Wait for approval before writing any code.
- **For small bug fixes or minor tweaks, just go ahead** — no plan needed.
- **Never modify files in the `Libs/` folder.** These are third-party libraries.
- **Always update the TOC file** (`DandersFrames.toc`) when adding or removing Lua/XML files. Load order matters — see `.claude/docs/project-structure.md`.
- **Test mode exists** — when suggesting testing, remind that `/df test` or the test mode toggle can be used to simulate party/raid frames without being in a group.
- **No AI attribution in commits.** Never add `Co-Authored-By` lines, Claude references, or any AI-related mentions in commit messages or code comments.
- **`CHANGELOG.md` is the single source of truth for changelogs.** Always add new changelog entries to `CHANGELOG.md` — never edit `Changelog.lua` directly. CI generates `Changelog.lua` from `CHANGELOG.md` at build time via `generate_changelog.sh`. To update the local in-game changelog for testing, run `bash generate_changelog.sh` then restore side effects with `git checkout -- CHANGELOG.md DandersFrames.toc` (the script modifies these as a side effect). The `/bump-version` skill should add entries to `CHANGELOG.md`.
- **Changelog style: short, sweet, non-technical.** Entries are read by end users in-game. Keep them brief and describe WHAT changed, not HOW.
    - **Default length:** one sentence, ideally under ~20 words. Phrase as the user-visible outcome (what they'll notice).
    - **Never include:** file names, line numbers, function names, API names, event names, secure-template internals, attribute strings, code snippets, commit-message-style explanations of the implementation, or references to how other addons solve the same problem. Don't mention other addons (ElvUI, Grid2, Blizzard internal templates, etc.) unless the user specifically asks.
    - **Allowed to be longer and more detailed:**
        - **New features** — describe what users can do with the feature and where to find the setting. Two to four sentences is fine.
        - **Developer-facing changes (DF API)** — external integrations (e.g. `RegisterCallback` events, public API functions other addons depend on) need enough detail for developers to update their code. This is essentially the only case where technical detail belongs.
    - **Examples:**
        - ❌ "Fix `attempt to perform boolean test on field 'dfInRange' (a secret boolean value, while execution tainted by 'DandersFrames')` error spam from Range.lua:550."
        - ✓ "(Range) Fix error spam when range fading is active in combat."
        - ❌ "Boss frames now register their own unit events directly (`UNIT_HEALTH`, `UNIT_POWER_UPDATE`, `UNIT_AURA`, …). This follows the same pattern ElvUI uses for its boss frames."
        - ✓ "(Friendly Boss NPC Frames) Fix health, power, name, and absorb updates not applying reliably."
- **Open bug awareness.** `_Reference/open-bugs.json` is a local cache of all currently triaged confirmed bugs (regenerated daily after the triage agent, or on demand via `/refresh-bugs`). When implementing fixes or features, you may optionally invoke `/check-bugs` to see if your changes touch files listed in open bug reports — useful for catching "this incidentally fixes bug X" moments or spotting bugs close to what you're working on. The release skills (`/release-alpha`, `/release-beta` manual path, `/release-stable`) run `/check-bugs` automatically before tagging so nothing ships without considering whether open bugs are now resolved.

## File Paths

### Repository (source of truth)
```
C:\Users\luked\Documents\DandersFrames\Repo\DandersFrames
```

### WoW AddOns Folders (symlinked to repo)
```
Live:  C:\Games\Blizzard\World of Warcraft\_retail_\Interface\AddOns\DandersFrames
PTR:   C:\Games\Blizzard\World of Warcraft\_ptr_\Interface\AddOns\DandersFrames
Beta:  C:\Games\Blizzard\World of Warcraft\_beta_\Interface\AddOns\DandersFrames
```
All three are symlinked to the repo folder — changes in the repo are immediately available in all WoW installations.

### Reference Folder
```
_Reference/
```
This folder exists in the repo root but is **git-ignored**. Use it to drop in documents, bug reports, other addon source code, API documentation, or any material that Claude should read to help solve issues. For example:
- Paste another addon's source code to compare approaches or debug compatibility issues
- Drop in Blizzard API documentation or forum posts about specific problems
- Add bug report text files for Claude to work through

### Tools

- **`_Reference/tools/decode_profile.py`** — decodes a DandersFrames profile export string (`!DFP1!...`) to JSON outside WoW. Reimplements `LibDeflate:DecodeForPrint` + raw deflate + `LibSerialize:Deserialize` in Python so user-submitted profile strings (from bug reports, Discord, etc.) can be inspected without loading them in-game. Usage: `PYTHONIOENCODING=utf-8 python _Reference/tools/decode_profile.py path/to/profile.txt > profile.json`. Note: integers and floats in LibSerialize are big-endian, not little-endian.

## Coding Conventions (Quick Reference)

Every Lua file starts with:
```lua
local addonName, DF = ...
```

Cache frequently used globals at file scope:
```lua
local pairs, ipairs, type = pairs, ipairs, type
local format = string.format
```

Section headers:
```lua
-- ============================================================
-- SECTION NAME IN CAPS
-- Brief description of what this section does
-- ============================================================
```

Use `DF:Debug()` / `DF:DebugWarn()` / `DF:DebugError()` — **never raw `print()`**. See `.claude/docs/debug-console.md` for full API reference.

### Global name vs. `DF` local alias

**Inside addon Lua files:** use `DF` (the local addon table from `local addonName, DF = ...`).

**From chat / `/dump` / `/run` / macros / external callers:** use the full global `DandersFrames` (registered via `_G[addonName] = DF` in Core.lua). `DF` is a file-local, not a global — `/dump DF.foo` always errors with "attempt to index global 'DF' (a nil value)".

When giving users in-game verification commands, always write `DandersFrames.X` not `DF.X`:
```
/dump DandersFrames.VersionCheck:RunComparatorTests()   -- works
/dump DF.VersionCheck:RunComparatorTests()              -- fails (DF is nil globally)
```

## Essential Patterns

### Settings Access
```lua
local db = DF:GetFrameDB(frame)  -- Returns party or raid settings based on frame type
local db = DF:GetDB("party")     -- Direct mode access
local db = DF:GetDB("raid")      -- or DF:GetRaidDB()
```
`DF.db` always points to the current profile: `DandersFramesDB_v2.profiles[currentProfile]`
Settings within a profile are split by mode: `DF.db.party.settingName` and `DF.db.raid.settingName`

### Combat Lockdown
Always check before modifying secure frame attributes, size, visibility, or header configuration:
```lua
if InCombatLockdown() then return end
```

### Adding New Settings
1. Add the default value to `DF.PartyDefaults` and/or `DF.RaidDefaults` in `Config.lua`
2. The migration system in `Core.lua` automatically applies missing defaults to existing profiles
3. Add the GUI control in `Options/Options.lua` — **use `L["Label"]` for all user-facing strings** (see Localization below)
4. Add `L["Label"] = true` to `Locales/enUS.lua` in the `--@do-not-package@` block (alphabetically)
5. Access via `DF:GetDB(mode).settingName` or `DF:GetFrameDB(frame).settingName`

## Localization

The addon uses **AceLocale-3.0** with **CurseForge's translation system**. Community translators contribute translations via the CurseForge web UI — no code changes needed from them. The BigWigs Packager auto-uploads English source strings on every build (via the `-S` flag) and pulls translations for all other locales.

### How It Works
- `Locales/enUS.lua` contains all English source strings as `L["String"] = true`
- Translation files (`Locales/deDE.lua`, `zhCN.lua`, etc.) contain `@localization@` keywords
- At build time, the BigWigs Packager:
  1. Uploads English source strings to CurseForge (via `-S` flag)
  2. Pulls translations from CurseForge for each locale and replaces `@localization@` tags
- In development (running from source), the `--@do-not-package@` block in `enUS.lua` provides English fallbacks
- The CurseForge localization portal is on the **old** authors site: `authors-old.curseforge.com`

### Accessing L
```lua
local L = DF.L  -- Available in any file that loads after Core.lua
```
For files that load BEFORE Core.lua (Config.lua, Profile.lua), use `local L = DF.L` inside functions (not at file scope), since `DF.L` is only available at runtime.

### Rules for ALL User-Facing Strings
- **Every string users see** must be wrapped in `L["..."]` — GUI labels, print messages, tooltips, button text
- **Never localize:** setting keys, db keys, page IDs, texture paths, debug messages, anchor values, internal identifiers, addon brand names (DandersFrames, FrameSort, Masque, ElvUI)
- **Never localize:** debug/developer output — slash command diagnostics (`/df debug*`), "module not loaded" errors, profiler messages, sort cache messages. These target the developer, not users
- **Addon brand names** stay as raw strings: `"DandersFrames"`, `"DF Icons"`, `"DF Stripes"` etc. Feature names within the addon (like "Aura Designer") CAN be translated
- **Dropdown options:** localize DISPLAY TEXT (`L["Center"]`), NOT the VALUE key (`"CENTER"`)
- **Dynamic text:** use `format(L["Created profile: %s"], name)` — put `%s`/`%d` placeholders in the locale key
- **Color codes** stay outside L — use `format()` with `%s` placeholders:
  ```lua
  -- CORRECT:
  format(L["Arena mode %sENABLED%s for testing"], "|cff00ff00", "|r")

  -- WRONG:
  L["Arena mode |cff00ff00ENABLED|r for testing"]
  ```
- **Never store L["..."] as a db value** — dropdowns must store raw keys (`"START"`, `"END"`, `"CENTER"`), not localized display text. If a user switches language, stored localized values become stale

### Reuse Existing Strings
Before adding a new locale string, **search `enUS.lua` for an existing string that says the same thing**. Duplicate/near-duplicate strings waste translator effort and bloat the phrase count. Common pitfalls:
- **Naming consistency:** always use `"Offset X"` / `"Offset Y"` (not `"X Offset"`). Check the existing pattern before adding
- **Casing consistency:** `"Combat Only"` not `"Combat only"`, `"Font Settings"` not `"Font settings"`
- **Avoid rewording:** if `L["Show Stacks"]` exists, don't add `L["Show Stack Count"]` — reuse the existing one
- **Confirmation buttons:** reuse `L["Yes"]`, `L["No"]`, `L["Cancel"]`, `L["Confirm"]` etc. — don't create variants like `L["Yes, let's do it"]` unless the context truly demands unique wording
- **Setting labels:** if a slider/checkbox label already exists (e.g., `L["Width"]`, `L["Alpha"]`, `L["Offset X"]`), reuse it rather than creating `L["Frame Width"]` or `L["Bar Alpha"]` — the section header provides context

### When Adding New Settings or UI Elements
1. **Search `enUS.lua` first** for an existing string that fits
2. If no match, use `L["Label"]` in the GUI control call
3. Add `L["Your Label"] = true` to `Locales/enUS.lua` in the `--@do-not-package@` block, alphabetically sorted
4. The `-S` flag on the packager auto-uploads new strings to CurseForge on the next build — no manual import needed

### Example
```lua
-- In Options.lua:
GUI:CreateCheckbox(self.child, L["Show Power Bar"], db, "showPowerBar", callback)
GUI:CreateSlider(self.child, L["Width"], 40, 400, 1, db, "frameWidth", callback)
local options = { CENTER = L["Center"], TOP = L["Top"] }
GUI:CreateDropdown(self.child, L["Anchor"], options, db, "anchor", callback)

-- Color codes with format():
local msg = format(L["v%s loaded. Type %s/df%s for settings"], DF.VERSION, "|cffeda55f", "|r")

-- In Locales/enUS.lua (inside --@do-not-package@ block):
L["Anchor"] = true
L["Center"] = true
L["Show Power Bar"] = true
L["Top"] = true
L["Width"] = true
```

### Supported Languages
enUS (source), deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW

## WoW API Notes

- This addon targets **Retail WoW (Midnight 12.0)**, Interface version 120000/120001
- Uses `SecureGroupHeaderTemplate` and `SecureUnitButtonTemplate` for party/raid frames
- Uses `C_AddOns.GetAddOnMetadata` (modern API, with fallback to old `GetAddOnMetadata`)
- Optional integration with **Masque** (button skinning) and **LibSharedMedia** (fonts/textures)

## Module Documentation

Detailed reference docs are in `.claude/docs/`. Read the relevant module when working on that subsystem.

| Topic | File | When to Read |
|-------|------|-------------|
| Project Structure | `.claude/docs/project-structure.md` | Understanding the file tree or TOC load order |
| Coding Conventions | `.claude/docs/coding-conventions.md` | Writing new code, naming things, module organization |
| Debug Console | `.claude/docs/debug-console.md` | Adding debug logging, working with the debug system |
| Settings & Profiles | `.claude/docs/settings-and-profiles.md` | Touching settings, profiles, SavedVariables, or import/export |
| Frame System | `.claude/docs/frame-system.md` | Working with unit frames, headers, or frame updates |
| Secret Values | `.claude/docs/secret-values.md` | Any code that reads unit health, power, or absorbs |
| Performance | `.claude/docs/performance.md` | Optimizing hot paths, table allocation, or event handling |
| CI/CD & Releases | `.claude/docs/ci-cd.md` | Building, tagging, releasing, or modifying CI workflows |
| Build: Alpha | `.claude/docs/build-alpha.md` | Pushing an alpha build to CurseForge |
| Build: Beta | `.claude/docs/build-beta.md` | Understanding automatic betas or triggering manually |
| Build: Stable | `.claude/docs/build-stable.md` | Pushing a stable release to all users |
| Localization | `CLAUDE.md` (Localization section) | Adding or modifying any user-facing string |
| Adding Settings | `.claude/docs/adding-settings.md` | Adding new settings to Config, GUI, and exports |
| Adding Modules | `.claude/docs/adding-modules.md` | Creating new Lua files and updating the TOC |
| PR Workflow | `.claude/docs/pr-workflow.md` | Merging community PRs, leaving review comments, changelog attribution |
| Popup System | `.claude/docs/popup-system.md` | Showing wizard or alert popups to the user |
| Wizard Builder | `WizardBuilder.lua` | Popup-based wizard builder with settings picker, import/export, and built-in registry |

## Skills (Slash Commands)

| Skill | Description |
|-------|-------------|
| `/skills` | List all available skills with short descriptions |
| `/pre-flight` | Check repo readiness (clean tree, main branch, remote sync) |
| `/changelog` | Display latest changelog section and confirm with user |
| `/changelog-discord` | Preview the exact Discord message(s) that will be posted on release |
| `/release-alpha` | Full alpha release pipeline (pre-flight → changelog → tag → push) |
| `/release-beta` | Beta build info and manual trigger options |
| `/release-stable` | Full stable release pipeline with extra verification |
| `/review-prs` | Review open PRs — fetch diffs, check conventions, identify risks, and prioritize with recommendations |
| `/add-setting` | Scaffold a new setting (Config defaults + GUI snippet + export category) |
| `/add-module` | Create a new Lua file with boilerplate + add to TOC |
| `/plan-feature` | Plan and scaffold a complete new feature |
| `/bump-version` | Add a new version section to CHANGELOG.md |
| `/debug` | Scan bug reports in `_Reference/bugs/`, triage by severity, and propose fix plans |
| `/fix-bug` | Fix a triaged bug from the Discord API, implement the fix, and push status back to the bot |
| `/update-discord` | Mark fixed bugs on the Discord bot API after implementing fixes |
| `/refresh-bugs` | Manually regenerate the local open bugs cache (`_Reference/open-bugs.json`) |
| `/check-bugs` | Cross-reference recent changes against open bugs and prompt per-bug to mark any as fixed |
| `/run-triage` | Manually trigger the daily triage agent |
| `/triage-schedule` | View or change the daily triage schedule |
| `/triage-logs` | Check latest triage agent logs and daily report |
