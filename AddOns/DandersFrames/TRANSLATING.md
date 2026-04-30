# Translating DandersFrames

Thank you for helping make DandersFrames accessible to players around the world! This guide explains how to contribute translations and provides context for strings that might be ambiguous.

## How to Translate

All translations are managed through the **CurseForge Localization Portal**:

1. Go to [DandersFrames on CurseForge](https://www.curseforge.com/wow/addons/danders-frames/localization)
2. Sign in with your CurseForge account
3. Select your language from the dropdown
4. You'll see a list of English phrases — type your translation next to each one
5. Click Save when done

That's it! Your translations will be included in the next addon build automatically. You don't need to know how to code, use Git, or submit pull requests.

## Supported Languages

| Code | Language |
|------|----------|
| deDE | German (Deutsch) |
| esES | Spanish - EU (Espanol) |
| esMX | Spanish - Latin America |
| frFR | French (Francais) |
| itIT | Italian (Italiano) |
| koKR | Korean |
| ptBR | Portuguese - Brazil (Portugues) |
| ruRU | Russian |
| zhCN | Chinese - Simplified |
| zhTW | Chinese - Traditional |

## Translation Guidelines

### General Rules

- **Keep translations concise** — GUI labels must fit in buttons, tabs, and checkboxes. If the English is short, keep the translation short.
- **Don't translate placeholders** — `%s`, `%d`, and `%1$s` are replaced with values at runtime. Keep them in your translation in the same order.
- **Don't translate color codes** — strings like `|cff00ff00` and `|r` are WoW color formatting. Leave them as-is.
- **Don't translate brand names** — "DandersFrames", "Masque", "ElvUI", "WeakAuras", "FrameSort" should stay in English.
- **WoW terms** — use the official localized term from your WoW client where possible (e.g., the official translation for "Healer", "Tank", "DPS", class names, spell names).
- **Be consistent** — if you translate "Enable" as "Activer" in one place, use "Activer" everywhere.

### Placeholders

Some strings contain placeholders that get replaced with dynamic values:

| Placeholder | Meaning | Example |
|-------------|---------|---------|
| `%s` | A text value (name, label, etc.) | `"Created profile: %s"` becomes `"Created profile: MyProfile"` |
| `%d` | A number | `"%d players"` becomes `"25 players"` |
| `%1$s`, `%2$s` | Ordered text values | Used when word order differs between languages |

**Important:** Keep all placeholders in your translation. The addon will crash if a placeholder is missing.

### Capitalization

English strings use Title Case for headers and labels (`"Health Bar Settings"`). Follow the capitalization conventions of your language — many languages don't use title case for settings labels.

---

## Phrase Context Guide

Many English phrases are short and could mean different things in different contexts. This section explains where each ambiguous phrase appears and what it means, so you can choose the correct translation.

### Single-Word Labels (Most Common)

These appear as GUI control labels, column headers, or dropdown options:

| Phrase | Context | Notes |
|--------|---------|-------|
| `"Alpha"` | Slider label | Means opacity/transparency (0 = invisible, 1 = fully visible). Not the Greek letter. |
| `"Anchor"` | Dropdown label | The attachment point of a UI element (where it's pinned to). |
| `"Application"` | Dropdown option | How an effect is applied visually (e.g., border application mode). |
| `"Bars"` | Settings category | The health/power/absorb bar section. |
| `"Blend Mode"` | Dropdown label | How a texture layer blends with layers below it (ADD, BLEND, etc.). |
| `"Border"` | Section header / checkbox | The decorative edge around a frame element. |
| `"Cast"` | As in "Cast Spell" | The act of casting a spell, not a fishing cast. |
| `"Center"` | Anchor position | The middle point of a frame. |
| `"Clamp"` | As in "Clamp to Screen" | Prevent the frame from being dragged off-screen. |
| `"Class"` | As in WoW class | Warrior, Mage, Priest, etc. — not a school class. |
| `"Clear"` | Button label | Remove/delete all items from a list. |
| `"Clip"` | As in "Clip Border" | Visually cut off/trim the border at the frame edge. |
| `"Color"` | Label or button | Opens a color picker or refers to a color setting. |
| `"Console"` | Debug Console | A text output panel for debugging — not a game console. |
| `"Container"` | Frame container | The parent frame that holds party/raid unit frames. |
| `"Copy"` | Button label | Duplicate settings from one mode to another. |
| `"Current"` | As in "Current Health" | The present value, not an electrical current. |
| `"Custom"` | Dropdown option | User-defined, as opposed to a preset/default. |
| `"Cut"` | Dropdown option | A text truncation mode — cuts text off at a length. |
| `"Dead"` | Unit status | The unit has died in-game. |
| `"Deficit"` | Health text format | Shows missing health (how much health is gone). |
| `"Del"` | Button label | Short for "Delete". |
| `"Direct"` | As in "Direct API" | Reading aura data directly from WoW's API. |
| `"Display"` | Settings category | Visual display settings. |
| `"Down"` | Growth direction | Frames grow downward. |
| `"Duration"` | Aura duration | How long a buff/debuff lasts. |
| `"Edge"` | Border style | The outer edge of a frame. |
| `"Edit"` | Button label | Open for modification. |
| `"Ellipsis (...)"` | Truncation option | Text cut off with "..." at the end. |
| `"End"` | Anchor position | The trailing edge (right in LTR languages, left in RTL). |
| `"Export"` | Button label | Save settings as a shareable string. |
| `"Fade"` | Visual effect | Gradually reduce opacity (become transparent). |
| `"Fill"` | Bar fill direction | Which direction the health bar fills from. |
| `"Finish"` | Button in wizard | Complete the wizard/setup process. |
| `"Flat"` | Raid layout mode | All players in one grid (not separated by groups). |
| `"Frame"` | UI frame | A single unit frame showing one player. |
| `"General"` | Settings category | General/miscellaneous settings. |
| `"Global"` | As in "Global Keybind" | Applies everywhere, not just in this addon. |
| `"Grid"` | Layout style | Icons/frames arranged in a grid pattern. |
| `"Group"` | Raid group | A WoW raid group (1-8), not a generic group. |
| `"Handle"` | Drag handle | The UI element you click to drag/move the frame container. |
| `"Health"` | Health points | A unit's hit points / life total. |
| `"Highlight"` | Visual overlay | A colored glow or border shown on hover/selection/aggro. |
| `"Hook"` | Attachment method | How the pet frame connects to its owner frame. |
| `"Horizontal"` | Direction | Left-to-right layout. |
| `"Icon"` | Small image | A buff/debuff icon, role icon, or status icon. |
| `"Import"` | Button label | Load settings from a shared string. |
| `"Indicators"` | Settings category | Visual indicators (highlights, icons, spell tracking). |
| `"Inset"` | Border inset | How far the border is pushed inward from the edge. |
| `"Label"` | Group label | Text label above raid groups ("Group 1", etc.). |
| `"Layout"` | Frame layout | How frames are arranged (size, spacing, growth). |
| `"Left"` | Anchor position | Left side of a frame. |
| `"List"` | Layout style | Icons arranged in a single row/column. |
| `"Lock"` | Button label | Prevent the frame from being moved/resized. |
| `"Match"` | As in "Match Current" | Use the same settings as the current mode. |
| `"Missing"` | As in "Missing Buff" | A buff that should be present but isn't. |
| `"Mode"` | Settings mode | Party mode vs Raid mode, or a display mode. |
| `"Mover"` | Drag handle | The overlay frame used to reposition unit frames. |
| `"Name"` | Player name | The character's name displayed on the frame. |
| `"None"` | Dropdown option | No selection / disabled. |
| `"Offset X"` / `"Offset Y"` | Slider label | Horizontal / vertical pixel offset for positioning. |
| `"Orientation"` | Bar direction | Whether a bar fills horizontally or vertically. |
| `"Outline"` | Font outline | A border drawn around text characters for readability. |
| `"Overflow"` | Layout behavior | What happens when icons exceed available space. |
| `"Overlay"` | Visual layer | A texture/color drawn on top of the health bar. |
| `"Pips"` | Class power dots | Small indicators for class resources (Holy Power, Chi, etc.). |
| `"Position"` | Settings section | X/Y offset and anchor point settings. |
| `"Power"` | Resource bar | Mana, Energy, Rage, etc. |
| `"Priority"` | Sort/display priority | Which items appear first. |
| `"Profile"` | Settings profile | A saved set of addon settings. |
| `"Pull Timer"` | Raid tool | A countdown before pulling a boss. |
| `"Range"` | Distance check | Whether a unit is in spell range. |
| `"Reverse"` | Bar fill option | Fill the bar in the opposite direction. |
| `"Right"` | Anchor position | Right side of a frame. |
| `"Role"` | Group role | Tank, Healer, or DPS. |
| `"Rows"` | Layout setting | Horizontal rows of frames. |
| `"Scale"` | Size multiplier | How much to enlarge/shrink an element. |
| `"Select..."` | Dropdown placeholder | Prompt to choose an option. |
| `"Shadow"` | Font outline style | A drop shadow behind text. |
| `"Size"` | Dimension | Width and/or height in pixels. |
| `"Smooth"` | Bar animation | Animated bar transitions instead of instant jumps. |
| `"Solo"` | As in "Solo Mode" | When the player is alone (not in a group). |
| `"Sort"` | Sorting | Arrange units in a specific order. |
| `"Source"` | Data source | Where aura data comes from. |
| `"Spacing"` | Gap between frames | Pixel gap between adjacent frames. |
| `"Spec"` | Specialization | A WoW class specialization (e.g., Holy Paladin). |
| `"Stacks"` | Buff/debuff stacks | The number of times a buff/debuff has accumulated. |
| `"Start"` | Anchor position | The leading edge (left in LTR languages). |
| `"Status"` | Unit status | Dead, Offline, AFK, etc. |
| `"Strata"` | Frame strata | WoW UI layer ordering (LOW, MEDIUM, HIGH). |
| `"Sync"` | Settings sync | Keep Party and Raid settings linked. |
| `"Target"` | Target unit | The player's current target. |
| `"Text"` | Settings category | Text display settings (name, health, status). |
| `"Texture"` | Visual texture | The bar texture/pattern used for health bars. |
| `"Threshold"` | A trigger value | The point at which an effect activates (e.g., health %). |
| `"Tooltip"` | Hover popup | Information shown when hovering over a frame. |
| `"Top"` | Anchor position | Top of a frame. |
| `"Truncate"` | Text shortening | Cut long text to fit available space. |
| `"Unlock"` | Button label | Allow the frame to be moved/resized. |
| `"Up"` | Growth direction | Frames grow upward. |
| `"Vehicle"` | WoW vehicle | When a player enters a vehicle (mount with abilities). |
| `"Vertical"` | Direction | Top-to-bottom layout. |
| `"Width"` | Dimension | Horizontal size in pixels. |
| `"Wizard"` | Setup wizard | A step-by-step guided setup process. |

### Format Strings

These contain `%s` or `%d` placeholders. The values shown below are examples of what gets inserted:

| Phrase | What `%s`/`%d` becomes | Where it appears |
|--------|------------------------|------------------|
| `"Created profile: %s"` | Profile name | Chat message after creating a profile |
| `"Deleted profile: %s"` | Profile name | Chat message after deleting a profile |
| `"Switched to profile: %s"` | Profile name | Chat message after switching profiles |
| `"%d players"` | Number | Raid group size display |
| `"%d - %d players"` | Min, Max | Layout range display |
| `"Copied %d settings from %s to %s."` | Count, Source mode, Destination mode | Chat message after copy |
| `"Debug logging %s"` | "enabled" or "disabled" | Chat message toggling debug |
| `"Arena mode %sENABLED%s"` | Color code start, Color code end | Chat message toggling arena mode |
| `"Copy %s Settings"` | Section name | Tooltip on copy button |
| `"v%s loaded. Type %s/df%s for settings"` | Version, color start, color end | Addon loaded message |
| `"Auto-profile \"%s\" activated (%s, %d players)"` | Profile name, content type, count | Chat message |

### Phrases That Look Similar But Mean Different Things

| Phrase | Where | Meaning |
|--------|-------|---------|
| `"Enable"` | Checkbox label | Turn a feature on |
| `"Enabled"` | Status indicator | Currently turned on |
| `"enabled"` | Dynamic text | Lowercase, inserted into "Debug logging %s" |
| `"Disabled"` | Status / dropdown | Currently turned off |
| `"disabled"` | Dynamic text | Lowercase, inserted into "Debug logging %s" |
| `"Lock"` | Button label | Lock frames in place |
| `"Locked"` | Status text | Frames are currently locked |
| `"Unlock"` | Button label | Unlock frames for moving |
| `"Party"` | Mode toggle / category | 5-player party mode |
| `"PARTY"` | Tab button label | The Party tab button (all caps in English) |
| `"Raid"` | Mode toggle / category | Raid mode (up to 40 players) |
| `"RAID"` | Tab button label | The Raid tab button (all caps in English) |

### WoW-Specific Terms

Use your WoW client's official translations for these:

- **Class names:** Death Knight, Demon Hunter, Druid, Evoker, Hunter, Mage, Monk, Paladin, Priest, Rogue, Shaman, Warlock, Warrior
- **Roles:** Tank, Healer, DPS (Damage), DAMAGER
- **Resources:** Mana, Energy, Rage, Focus, Runic Power, Insanity, Maelstrom, Fury, Pain, Lunar Power, Astral Power, Combo Points, Chi, Holy Power, Soul Shards, Arcane Charges, Essence
- **Debuff types:** Magic, Curse, Disease, Poison, Bleed
- **Buffs:** Arcane Intellect, Battle Shout, Mark of the Wild, Power Word: Fortitude, Blessing of the Bronze, Skyfury, Hunter's Mark
- **Status:** Dead, Ghost, Offline, AFK, Disconnected

### Strings You Can Skip

Some English strings don't need translation because they are technical terms understood universally:

- `"DPS"` — universally understood gaming term
- `"AFK"` — universally understood
- `"HoT"` / `"DoT"` — Heal/Damage over Time (standard MMO terms)
- `"UI"` — User Interface
- `"ADD"` / `"BLEND"` / `"DISABLE"` — WoW blend mode constants (technical)

## Questions?

If you're unsure about the context of a specific phrase, you can:
1. Open DandersFrames in-game (`/df`) and search for the English text to see where it appears
2. Ask in the [DandersFrames Discord](https://discord.gg/dandersframes)

Thank you for contributing to DandersFrames localization!
