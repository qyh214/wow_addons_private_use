local addonName, DF = ...
DF.BUILD_DATE = "2026-04-30T14:03:46Z"
DF.RELEASE_CHANNEL = "release"
DF.CHANGELOG_TEXT = [===[
# DandersFrames Changelog

## [4.3.6] - 2026-04-30

### Improvements

* (Click Casting) Improved mouseover detection on hovered unit frames after a Blizzard API fix.
* (Click Casting) The conflict popup for Clique and Clicked now also appears when switching to a click-cast profile that turns click casting on.
* (Boss Debuffs) Updated the info banner to clarify that boss debuffs trigger dispel overlays in Hybrid or Blizzard mode.
* (Boss Debuffs) Added an Inset slider for the Blizzard dispel overlay so the gradient can extend past or shrink inside the frame edges.
* (Boss Debuffs) Replaced separate Icon Width and Icon Height sliders with a single Icon Size slider. Existing settings carry over to the larger of your two old values.
* (Boss Debuffs) Added an Open Edit Mode button to the Blizzard Overlay settings so you can preview the Blizzard dispel overlay live.

### Bug Fixes

* (Pet Frames) Fix Lua error spam during boss pulls when a pet is in the group.
* (Status Icons) Fix Lua error spam when the Status Icon font outline is set to "None".
* (Update Notification) Fix "You aren't in a party." and "You aren't in a raid." chat spam in LFG dungeons, LFR, scenarios, and battlegrounds.
* (Boss Debuffs) Fix icons sometimes staying invisible after a transient registration hiccup until you fully reload.
* (Boss Debuffs) Fix icons not rendering at certain size combinations.
* (Boss Debuffs) Skip private aura registration on pet frames — pets can't receive boss debuffs.
* (Click Casting) Fix target click-cast bindings on DandersFrames hitting the /target name range limit.
* (Boss Debuffs) Surface Blizzard private aura API errors instead of silently swallowing them.
* (Boss Debuffs) Fix icons sometimes rendering behind the unit frame after a re-register, even with frame level raised.
* (Aura Designer) Reduce GUI lag when opening Aura Designer with many configured effects.
* (Dispel Overlay) Fix dispel type icons not fading when a unit goes out of range with element-specific alpha enabled.

## [4.3.5] - 2026-04-26

### Improvements

* (Dispel Overlay) Added a Frame Strata dropdown and Frame Level slider to the Blizzard overlay settings. Raise them if the overlay gets hidden behind frame text on short/wide frames.
* (Boss Debuffs) Added a Frame Strata dropdown next to Frame Level. Default is now HIGH so private aura icons always render above frame text and borders, including for users with small icon sizes. Lower it via the dropdown if you preferred the old behaviour.

### Bug Fixes

* (Tooltips) Fix aura tooltips being overwritten by the unit tooltip when hovering buffs and debuffs

## [4.3.4] - 2026-04-24

### Changes

* (Dispel Overlay) DandersFrames-only mode users have been switched to Hybrid mode for this update — Hybrid covers boss debuffs that DandersFrames mode missed. You can switch back under Settings > Dispel Overlay > Overlay Source if you prefer.

### Bug Fixes

* (Buff Bar) Fix buff icons sometimes getting stuck on the bar until reload after a unit went out of range and back
* (Aura Designer) Fix tracked auras occasionally not being deduped from the buff bar after a unit returns from out of range
* (Private Aura Dispel Overlay) Overlay now stays on the correct player when roster or sort changes move players between slots, including mid-combat
* (Range) Fix Lua error spam from range checks during timewalking dungeons
* (Update Notification) Fix remaining "You aren't in a party." chat spam in delves and follower dungeons
* (Boss Debuffs) Fix boss debuff icons occasionally rendering behind the unit frame on some group members
* (Tooltips) Fix buff/debuff tooltip flickering with the unit tooltip when hovering an aura icon after entering the frame body

## [4.3.3] - 2026-04-21

### New Features

* **Pinned Frames in Test Mode** — Test Mode now fills your enabled pinned sets with fake units so you can design the layout without being in a group. Boss sets show friendly-NPC test units (Fiery Treant, Charred Bramble, etc.); player-mode sets show party/raid test units. A new **Test Count** slider in the Pinned Frames settings chooses how many frames appear (1–8 boss, 1–10 player). Test frames are non-secure mock frames that look identical to live frames — your real pinned setup isn't touched. Raid test mode only shows raid-profile sets, party test mode only shows party-profile sets, and the other mode's frames are never affected.
* **Dispel Overlay redesign** — Private Aura Dispel Overlay settings have moved to the Dispel Overlay tab under a new **Overlay Source** dropdown with four modes:
    * **Hybrid** — DandersFrames for normal dispels, Blizzard for boss debuffs (recommended)
    * **DandersFrames** — full customisation, does not cover boss debuffs
    * **Blizzard** — covers both normal debuffs and boss debuffs, limited customisation
    * **Off** — disabled
    
    In Hybrid mode the two overlays no longer double up; DandersFrames handles normal dispels while Blizzard picks up boss debuffs only. "Show Overlay For" (Dispellable By Me / All Dispellable) is now a single unified setting shared by both overlays.

### Improvements

* (Friendly Boss NPC Frames) Frames no longer collapse upward when a boss dies — surviving frames hold their position, and new bosses fill the next free slot. Slot assignments reset when combat ends
* (Private Aura Dispel Overlay) Overlay no longer covers the frame border, text, and icons
* (Private Aura Dispel Overlay) Added an Alpha slider to dim the overlay
* (Dispel Overlay) Section headers now show tags indicating which dispel types each section covers under the current Overlay Source mode
* (Dispel Overlay) Reduced CPU overhead in Blizzard and Off modes during combat

### Changes

* (Private Aura Dispel Overlay) Removed the "Show Dispel Icons" toggle — the top-right icons cannot be hidden separately from the overlay, so the option had no effect

### Bug Fixes

* (Aura Designer) Fix constant tooltip Lua error spam during raid encounters with secret auras
* (Range) Fix error spam when range fading is active
* (Update Notification) Fix "You aren't in a party." chat spam in NPC follower dungeons and delves
* (Friendly Boss NPC Frames) Aura Designer indicators now apply correctly when a boss slot swaps to a new NPC mid-encounter
* (Friendly Boss NPC Frames) Out-of-range fading now works on boss frames
* (Friendly Boss NPC Frames) Fix health, power, name, absorb, heal prediction, and aura updates not applying reliably
* (Friendly Boss NPC Frames) Fix Aura Designer indicators from a previous boss lingering on a slot after it's assigned to a new NPC
* (Friendly Boss NPC Frames) Reduce race conditions where a boss frame intermittently fails to appear on spawn
* (Friendly Boss NPC Frames) Fix health and Aura Designer indicators not updating when a boss slot silently swaps to a different NPC mid-encounter
* (Pinned Frames) Fix stale background, border, and label from the real pinned container showing behind test frames when Test Mode matches the current group mode
* (Pinned Frames) The set label now appears above test frames in all cases, including cross-mode previews (e.g. raid test mode while in a party)
* (Targeted List) Cast bar now snaps to full yellow on interrupt instead of continuing to fill

## [4.3.2] - 2026-04-21

### New Features

* **Friendly Boss NPC Frames** — Pinned frame sets now have a Frame Type setting. Switch a set to "Friendly Boss NPCs" to display healable friendly boss units (boss1–boss8) instead of group members. Useful for encounters where friendly adds need healing. All layout, positioning, click-casting, buffs, debuffs, Aura Designer indicators, and out-of-range fading work the same as player-mode pinned sets. Visible frames compact to the set's anchor so there are no empty slots when only some boss units are friendly — even as bosses appear and die during combat.
* **Update notification** — if another DandersFrames user in your group or guild is running a newer stable version, you'll see a one-time chat message on login. Can be disabled in General > Settings > Notifications.

### Improvements

* **Pinned Frames** — movers are now color-coded per mode (orange for raid, purple-blue for party) so it's obvious which mode's position you're editing
* **Pinned Frames** — opening a pinned-frames page for the inactive mode (e.g. Raid settings while you're solo or in a party) now shows a preview container for that mode's frames so you can reposition them without joining a group
* (Aura Filters) Added an Aura Blacklist pointer section with a link to the dedicated Aura Blacklist tab, making it easier to find spell-specific exclusions from the filters page

### Bug Fixes

* Fix DPS jumping order mid-dungeon when "Separate Melee & Ranged DPS" is enabled
* (Click-Casting) Fix "In Combat Only" and "Out of Combat Only" conditions being ignored for Target Unit and Open Menu bindings
* (Aura Designer) Fix beacon indicators being invisible if saved at an icon size smaller than the slider minimum
* (Aura Designer) Fix indicators inside Layout Groups not being draggable
* (Aura Designer) Spec-specific spells (e.g. Earthshield) now appear correctly after switching specs without needing a reload
* (Auto Profiles) Fix brief flicker to party settings when exiting the auto-profile editor before the raid override re-applies
* (Status Text) Fix "Offline" / "AFK" text lingering on a frame after the player comes back online
* (Status Text) Add "DND" status text display (previously only AFK was shown)
* (Frames) Fix the Resurrected buff icon staying on a player's frame after they've come back to life
* (Frames) Fix the summon-pending icon staying on your frame after leaving the group
* (Auras) Raid frame aura icon borders are now pixel-perfect (were slightly blurry when raid frame scale differed from UIParent)
* (Boss Debuffs) Fix boss debuff icons overlapping instead of spacing correctly when tooltips are hidden and growth direction is left/up
* (Defensives) Fix defensive cooldown icons swapping slot positions / flickering when multiple cooldowns are active
* (Defensives) Fix the second defensive cooldown icon not fading when the player is out of range or out of phase
* (Pinned Frames) Dragging the mover while viewing the inactive mode's settings no longer silently saves the new position to the active mode's profile
* (Pinned Frames) The Enable, Lock Position, and Show Label checkboxes no longer mutate the active mode's container when toggled from the inactive mode's settings
* (Pinned Frames) Fix the second pinned-frames tab being unselectable when the two sets had different Frame Types — the tab now sticks across the page rebuild
* (Pinned Frames) Boss-mode preview container now uses a single-frame placeholder (matching live behaviour when no boss is visible) instead of a four-frame-wide box
* (Aura Designer) Sound alerts now pick up live edits without toggling the alert off and on
* (Test Mode) Correct Monkbrew test unit from Mistweaver (healer) to Brewmaster (tank)
* (Frames) Fix "No secure position handler!" red error spamming chat on login/reload when raid frames are disabled

### 12.0.5 Compatibility

* **Private Aura Dispel Overlay** — on 12.0.5+, a new Blizzard-rendered dispel overlay for private auras replaces the old frame border overlay. Controlled from Boss Debuffs settings with options for dispel filter, gradient direction, and dispel type icons.
* Fix private aura anchors for 12.0.5 API changes

### API

* **OnFramesSorted callback** — External addons can subscribe to `DandersFrames.RegisterCallback(self, "OnFramesSorted", ...)` to be notified whenever party, raid, or arena frames are reshuffled. Fires once per sortType per tick (coalesced) in both combat and non-combat — covers settings changes, roster updates, role swaps, spec detection, and Blizzard's internal ASSIGNEDROLE re-sorts. Callback receives `(event, sortType)` where sortType is `"party"`, `"raid"`, or `"arena"`. Safe to call `DandersFrames_GetFrameForUnit(unit)` from inside the handler.

## [4.3.1] - 2026-04-15

### New Features

* **Disable Party or Raid frames** — new toggles in General > Settings let you fully disable either frame system. Disabled frames never load, so they use no resources. Requires a reload; the popup can also toggle Blizzard's frames on or off for you in the same reload.
* **Custom font for the settings panel** — pick a font and outline in General > Settings > Appearance. Applies instantly, no reload.
* **Addon language override** — run the addon in a different language than your WoW client (per-character). Defaults to auto-detect.

### Improvements

* Reorganised General > Settings into Frame Modes, Blizzard Frames, Appearance, and Language sections
* Blizzard frame toggles renamed from "Hide" to "Disable" (they fully disable, not just hide) and now appear in both Party and Raid views
* "Hide Blizzard Player Frame" moved to Display > Visibility
* Fixed Cyrillic, Korean, and Chinese characters showing as squares in various places

### Bug Fixes

* (Aura Designer) Holy Paladin: Holy Bulwark now triggers the same indicator as Sacred Weapon. A warning icon on the spell explains why the two can't be tracked separately.

## [4.3.0] - 2026-04-10

### Improvements

* (Auras) Force-disable Blizzard aura data source ahead of its removal in 12.0.5 — all users now use Direct API mode immediately
* (Auras) Prevent Blizzard aura source from persisting via profile imports — removed from export categories, forced to Direct on import and every login
* (Aura Filters) Add info banner clarifying that Aura Filters only affect Buff Bar and Debuff Bar, with clickable links to related pages
* (Aura Filters) Remove outdated Defensives and Dispel Detection info section
* (Aura Filters) Dispellable filter now uses a toggle switch (Dispellable By Me / All Dispellable) instead of two separate checkboxes
* (Aura Filters) Warning banner when "All Debuffs" is disabled, recommending healers keep it enabled
* (Aura Blacklist) Add notice explaining the blacklist is a curated Blizzard list
* (Aura Blacklist) Add warning icon next to Symbiotic Relationship noting caster-only blacklist limitation
* (Aura Blacklist) Increased warning and notice banner icon sizes for better visibility
* (Boss Debuffs) Add info banner noting Boss Debuffs cannot trigger Dispel Overlays

### New Features

* **Toggle Switch GUI element** — new reusable UI control for mutually exclusive A/B settings, with themed visuals and label highlighting
* **"New" tab badges** — gold "New" text appears on tabs and their parent category for new features, auto-hides once the tab is opened
* **Targeted List** — a new stacked cast-bar display that shows enemy casts targeting party members. Replaces the group-frame Targeted Spells icons that were broken by Blizzard's recent UnitIsUnit hotfix. Party-mode only, with draggable mover, test mode, four style presets, and full appearance controls including font, colors, icon, border, textures, arrow prefix/suffix, self-target color overlay, hide out-of-combat filter, cast-to-channel transitions, interrupted flash, and per-text-element positioning

### Bug Fixes

* (Tooltips) Add tooltip refresh ticker so third-party tooltip addons (e.g. RaiderIO) can respond to modifier key state changes while hovering unit frames
* (Tooltips) Add clean unit token resolver for tooltip SetUnit calls to work around Midnight 12.0 taint propagation from secure frame attributes
* (Absorb Bars) Fix absorb bars showing as floating bars when Attached or Attached+Overflow display mode is selected
* (Aura Designer) Fix indicators sometimes showing wrong settings (wrong font size, icon size, bar colors) — Configure now runs mid-combat so indicators always get correct static settings immediately
* (Aura Designer) Fix duration text using default Blizzard font/size when the cooldown FontString hasn't been created yet at configure time
* (Personal Targeted Spells) Removed the white center-line overlays from the mover frame
* (Targeted Spells) Added `UNIT_SPELLCAST_FAILED_QUIET` to the registered event list — some cancelled casts previously left dangling personal-display icons

## [4.2.9] - 2026-04-10

### Improvements

* (GUI) Modernised all scroll bars across the addon to use the new slim pill-style thumb instead of the default Blizzard scroll bars

### Bug Fixes

* (Dispel Overlay) Fix "All Dispellable" mode not showing the dispel overlay when using the Blizzard aura data source

## [4.2.8] - 2026-04-08

### New Features

* (Profiler) Major rework of the function profiler with new tabs for per-event CPU cost and per-frame OnUpdate handlers
* (Profiler) New columns for peak calls per frame and per-call memory allocation
* (Profiler) Right-click "Print to Chat" now emits a Top 5 summary
* (Profiler) Function coverage expanded from ~30 to ~140 tracked methods

### Performance

* **Major raid performance pass** — total addon CPU down about **62%** and memory churn down about **93%** in a 20-player boss fight. Expect smoother frames during heavy AoE, big pulls, and dispel-heavy fights, especially on older hardware
* (Buff & Debuff Tracking) Rebuilt the core aura system so it does the work once instead of repeating the same scan 6–7 times per update. Around 99% of aura events now use the fast cached path in raid
* (Dispel Highlights) The colored outline around dispellable debuffs is now near-free — its CPU cost dropped by about 95%
* (Absorb Shields) Shield overlays update about twice as fast and no longer create throwaway data on every update
* (Animated Highlights) Marching-ants borders redraw at 30 FPS instead of 60 with no visible difference, cutting their CPU cost to about a third
* (Aura Designer) Custom indicators reuse a pool of entries instead of creating new ones every frame — noticeably lighter at raid scale
* (Aura Designer) Expiring border color animation no longer tears down and rebuilds the entire border on every tick
* (Frame Updates) Small efficiency win across every frame refresh from caching commonly used WoW APIs

### Bug Fixes

* (Profiler) Fix taint errors from the profiler incorrectly wrapping Blizzard's secure compact raid frame handlers. The profiler now only instruments DandersFrames-owned frames

### Technical Notes

For the curious — measured in a 5m 38s raid boss fight (493,901 calls profiled):

* **Total addon CPU:** ~114 ms/sec → ~43 ms/sec (**−62%**)
* **Memory churn (top sources):** ~12 MB/sec → < 1 MB/sec (**−93%**)
* **Aura cache hit rate:** 99.6% (36,204 of 36,360 events skip the full scan)
* **Dispel overlay CPU share:** 16.4% → 0.8% (**−95%**)
* **Absorb update per call:** ~111 µs / ~80 B → 38.4 µs / 0 B (**−65% CPU, zero allocation**)
* **Aura tracking:** Now uses the `UNIT_AURA updateInfo` payload with a shared `DF.AuraCache` keyed by aura instance ID. Both Aura Designer and Dispel overlay read from the same cache instead of re-querying `C_UnitAuras`
* **Aura Designer indicator entries** are pooled (max 64 reused), and instance keys are cached in a two-level lookup table
* **Dispel overlay** caches its layout state and short-circuits `ApplyOverlayLayout` when nothing relevant changed — same pattern was then applied to absorb shields
* **Update.lua** caches `UnitHealth`, `UnitPower`, `InCombatLockdown` and 9 other Unit\* APIs as file-scope locals to skip global lookups in the hot path

## [4.2.7] - 2026-04-07

### New Features

* (Auras) Added `Player Dispellable` and `All Dispellable` debuff filters to Direct API mode

### Improvements

* (Locales) Locale warnings now silent by default

### Performance

* (Auras) Reduced wasted aura processing in raid combat
* (Range) Reduced wasted range update events in busy zones

### Bug Fixes

* (Auras) Fix "Compound unit tokens are not allowed" error spam in raid and arena
* (Internal) Removed two non-unit events from per-frame filter list

## [4.2.6] - 2026-04-07

### Bug Fixes

* (Aura Designer) Fix error spam from secret aura tracking
* (Locales) Fix locale errors showing to users
* (Defensive Icon) Fix defensive auras showing in both the buff bar and the defensive icon at the same time

## [4.2.5] - 2026-04-07

### Improvements

* (Debug Console) Redesigned page with collapsible sections and a wider log viewer
* (Defensive Icon) Now shows multiple big defensives at once and works consistently across both aura source modes

### WoW API Changes

* (Targeted Spells) Group-frame targeted spell icons disabled — a recent WoW change prevents addons from knowing which party member an enemy is targeting. Personal Targeted Spells still works, and a replacement display is in development
* (Auras) Auto-switch to Direct API mode if the upcoming WoW 12.0.5 patch removes the Blizzard aura source. A popup will explain the change if it triggers
* (Aura Designer) Temporarily disabled Symbiotic Relationship target tracking due to a WoW API issue. Restoration Druids will lose this indicator until it can be reworked

### Bug Fixes

* (Dispel Overlay) Fix "All Dispellable" mode not firing when the dispellable debuff was filtered out of the icon display
* (Debug Console) Fix log viewer crashing when certain protected values were logged
* (Auras) Fix a load-time error when Direct API mode was enabled

### Diagnostics

* (Raid Frames) Added logging to help track down the "raid frames jump on roster change" bug. If affected, open `/df console`, enable the **RAIDPOS**, **LAYOUT**, **ROSTER**, and **FRAMESORT** categories, reproduce, then send the log with your bug report.

## [4.2.4] - 2026-04-05

### Bug Fixes

* (Dispel Overlay) Fix health bars appearing darkened/black when a unit had any non-dispellable debuff in "All Dispellable" mode with the gradient darken option enabled

## [4.2.3] - 2026-04-05

### Bug Fixes

* (Localization) Add missing "Pull Timer" locale string causing errors on load

## [4.2.2] - 2026-04-05

### Improvements

* (Auras) Increase all buff, debuff, boss debuff, and missing buff offset slider ranges from ±20–100 to ±150 for consistency with Aura Designer

### Bug Fixes

* (Click Casting) Fix click casting not working on pinned frames
* (Dispel Overlay) Fix "All Dispellable" mode only showing debuffs the player can personally dispel — now correctly highlights any dispellable debuff (Magic, Curse, Disease, Poison) regardless of class
* (Dispel Overlay) Fix swapped dropdown labels for "All Dispellable" and "Dispellable By Me" options

## [4.2.1] - 2026-04-04

### Bug Fixes

* (Localization) Fix Spanish locale file containing a CurseForge API error instead of translation data

## [4.2.0] - 2026-04-04

### New Features

* (Resource Bar) Add "Use Class Color" option for resource bars — colors power bars by class instead of power type (thanks **sKullsen**)
* (Localization) Add full localization infrastructure using AceLocale-3.0 and CurseForge translation system — community translators can now contribute translations via the CurseForge web UI without touching code
* (Localization) Add locale stubs for 11 languages: English, German, Spanish (EU/LATAM), French, Italian, Korean, Portuguese (BR), Russian, Chinese (Simplified/Traditional)

### Improvements

* (Frames) Add tooltip to resurrection icon showing cast status (green = incoming, yellow = pending accept)
* (Frames) Status icons (summon, AFK, phased, resurrection) now stay fully visible when unit is out of range or dead

### Bug Fixes

* (Raid Frames) Fix groups overlapping after auto-profile switch when layout direction and spacing are unchanged between profiles
* (Raid Frames) Fix CENTER-aligned groups landing in wrong positions when the first person joins a previously empty group
* (Fonts) Fix client crash (ACCESS_VIOLATION) when SetFontObject receives an uninitialized font family during early login
* (Auto Layouts) Fix frames using wrong positions or settings when switching between grouped and flat raid layouts
* (Auto Layouts) Fix double frame refresh when switching between auto-profiles
* (Auto Layouts) Fix race condition between auto-profile evaluation and roster update processing
* (Auto Layouts) Fix flat raid fast path not reapplying layout settings when spacing or anchors change
* (Auto Layouts) Fix grouped headers staying empty after switching from flat to grouped mode on instance entry
* (Auto Layouts) Fix raid container drifting to wrong position after group sorting due to CENTER anchor resize
* (Auto Layouts) Fix profile switch reading stale overlay settings during refresh
* (Auto Layouts) Fix flat raid container not resizing immediately after layout settings change
* (Auto Layouts) Add defensive refresh after auto-profile deactivation to prevent partially-configured frame state
* (Health Text) Fix Abbreviate (K/M) not working in Deficit mode outside of Test Mode (thanks **andybergon**)
* (Settings) Fix Health Bar section sync accidentally overwriting Health Text settings due to overly broad prefix matching
* (Resource Bar) Remove stale type guards that could prevent the resource bar from displaying power values
* (Missing Buffs) Fix missing buff indicators not fading when a unit is dead or offline
* (Aura Designer) Fix icon border appearing asymmetric at certain sizes by snapping to pixel boundaries
* (Aura Designer) Fix right panel sizing breaking when switching between Party and Raid mode on narrow windows
* (Aura Designer) Fix sound alert preview failing when "None" is selected or LSM returns a non-path value
* (Test Mode) Fix heal prediction animations showing inconsistent direction after importing a profile
* (Position Panel) Fix "Hide Drag Overlay" preference resetting every time the mover is unlocked

## [4.1.11] - 2026-04-01

### Bug Fixes

* (Click-Casting) Fix right-click menu not working on Blizzard frames when a right-click spell binding is set to DandersFrames only

## [4.1.10] - 2026-03-31

### New Features

* (API) Add layout config endpoints — `DandersFrames_GetPartyConfig()` and `DandersFrames_GetRaidConfig()` return frame dimensions, scale, spacing, and layout settings for external addon integration
* (Boss Debuffs) Add Text Scale slider for timer and stack count text
* (Aura Designer) Add expire sound alert — plays a sound when the longest active buff duration drops below a configurable threshold
* (Aura Designer) Add collapsible settings groups — indicator settings sections can be collapsed/expanded by clicking the header, with state persisted across sessions
* (Aura Designer) Add bottom collapse bar to expanded indicator cards and settings groups for quick access

### Improvements

* (Aura Designer) Add warning messages when Preview Sound has no sound file selected or the file fails to play

### Bug Fixes

* (Frames) Fix IteratePinnedFrames error on roster update caused by function used before declaration
* (Frames) Fix frames staying stuck as offline after a player reconnects
* (Grouped Raids) Fix groups briefly overlapping when someone joins the raid
* (Boss Debuffs) Fix overlay border showing tooltips when it shouldn't
* (Aura Designer) Fix Adapter nil error on login when spec is set to auto
* (Click-Casting) Fix deleted click bindings being silently restored
* (Frames) Fix ADDON_ACTION_BLOCKED error when entering combat while dragging raid frames
* (Frames) Fix role icon alpha setting not applying in test mode
* (Aura Designer) Fix indicator borders rendering below the unit frame border
* (Frames) Fix resource bar not showing in delves due to unassigned role
* (Grouped Raids) Fix raid frame anchor shifting position when changing specs
* (Frames) Fix summon icon staying visible after a player leaves the group
* (Boss Debuffs) Fix hide tooltip setting hiding boss debuff icons in test mode
* (Blizzard Frames) Fix side menu flickering when set to hidden

## [4.1.9] - 2026-03-27

### New Features

* (Boss Debuffs) **Frame Border Overlay** — shows a border around the entire unit frame when boss debuffs are active, with auto-fit sizing and adjustable settings
* (Boss Debuffs) **Overlay Setup Wizard** — guided setup with image previews when enabling the overlay for the first time, including a warning about visual quirks
* (Boss Debuffs) **Hide Tooltip** option — prevents the tooltip from appearing when hovering over boss debuff icons
* (Boss Debuffs) **Test Mode Overlay Preview** — preview the overlay border in test mode without needing to be in combat

### Changes

* (Boss Debuffs) Simplified private aura system — cleaner single-anchor approach, removed unused settings
* (Boss Debuffs) Overlay icon ratio slider now goes up to 15 to support very wide frames

### Bug Fixes

* (Auras) Fix auras not showing after switching profiles with different data source settings
* (Aura Designer) Fix indicator icons blocking click-casting in combat
* (Grouped Raids) Fix groups growing from the wrong direction after changing settings
* (Grouped Raids) Fix group display order resetting when changing raid settings
* (Grouped Raids) Fix group labels misaligning after switching layout direction
* (Flat Raids) Fix hidden groups sometimes showing frames when sorting is active
* (Flat Raids) Fix a group disappearing after roster changes during combat

### Performance

* (Aura Designer) Reduced per-event work — static properties are now set once on config change instead of every aura event

## [4.1.8] - 2026-03-26

### New Features

* (Auras) Add Aura Filter Setup Wizard — guided setup to help configure aura data source and filter options. Runs automatically on first login after update, or manually via the Aura Filters settings tab

## [4.1.7] - 2026-03-25

### Bug Fixes

* (Auras) Fix Blizzard data source showing no debuffs — Blizzard moved aura data from frame arrays to container objects in the latest update, updated reader to use new Iterate API
* (Auras) Fix dispel overlay not working in Blizzard data source — use Direct API dispel filter (IsAuraFilteredOutByInstanceID) for secret-safe dispel detection since old dispelDebuffFrames no longer populated

### Changes

* (Auras) Switch default aura data source to Direct API for all new and existing profiles — provides full control over buff/debuff filtering. Users can switch back to Blizzard mode in settings if preferred
* (Auras) Update default Direct API filters: show all debuffs, sort buffs and debuffs by time remaining

## [4.1.6] - 2026-03-25

### Bug Fixes

* (Growth) Fix nil wrap error when growth direction value has no underscore separator
* (Growth) Add safety fallback for nil wrap in growth direction composer

## [4.1.5] - 2026-03-24

### Bug Fixes

* (Grouped Raids) Fix hidden groups sometimes showing frames when players join or are moved into them — hidden group headers are now fully neutralized (attributes cleared) so they can never claim or display units
* (Boss Debuffs) Fix private auras showing on wrong players after sorting or roster changes — restore reanchor system with combat lockdown guards so anchors rebind to the correct unit token
* (Targeted Spells) Stagger icon pool creation for raid frames to prevent script-ran-too-long errors when 40 frames initialise simultaneously
* (Auras) Use SetCooldownFromDurationObject for secret-safe aura cooldowns
* (Auras) Add issecretvalue local cache to Icons.lua and DebugAuras.lua

## [4.1.4] - 2026-03-23

### New Features

* **Frame Scale** — new slider in Layout settings to scale party and raid frames (0.5x–2.0x). Movers, snap-to-grid, and drag all work correctly at any scale. Scale is per-profile and applies to containers, movers, and test frames.
* (Pinned Frames) **Auto-Update by Role** — when auto-add role filters are active (tanks, healers, DPS), players whose role no longer matches are automatically removed. Manually added players and offline players are never auto-removed.

### Bug Fixes

* (Grouped Raids) Fix empty groups overlapping populated groups — empty groups were being positioned at their natural grid slot instead of being skipped, causing overlap when groups compact
* (Grouped Raids) Fix groups sometimes overlapping on roster change — position handler now re-fires on every roster update to stay in sync with WoW's internal child re-sorting
* (Flat Raids) Fix raid anchor moving when respeccing or dying — grouped-mode positioning was resizing the shared container when flat mode was active
* (Flat Raids) Fix frames overlapping with grouped headers when auto layout switches from grouped to flat mode
* (Pinned Frames) Fix frames drifting towards bottom-left when changing scale
* (Pinned Frames) Fix drag speed mismatch at non-1.0 scale — frames now track the cursor 1:1 at any scale

## [4.1.3] - 2026-03-17

### New Features

* (Aura Designer) **Show When Missing** — per-indicator toggle that inverts visibility: shows the indicator when the aura is absent, hides when present. Supports all indicator types except bars. Icons support a "Desaturate When Missing" sub-option.
* (Aura Designer) **Show When Missing + Expiring** — when both are enabled, the indicator stays hidden while the buff is active, appears during the expiring window, then shows with normal appearance once the buff drops off
* (Auras) **Growth Direction Control** — replaced the single growth dropdown with a three-part control (Orientation, Wrap, Direction) for clearer configuration
* (Aura Designer) **Sound Alerts** — per-indicator sound alerts that play when an aura appears, expires, or is missing. Supports all LibSharedMedia sounds, adjustable volume, loop/one-shot modes, and a global "Mute All Sound Alerts" toggle in the Aura Designer banner. Includes a searchable sound dropdown picker.
* (Sorting) **[Experimental] FrameSort Addon Integration** — added support for the FrameSort addon. When enabled in General > Sorting, FrameSort controls frame ordering for party, raid (flat and grouped), and arena frames. Requires the FrameSort addon to be installed separately.

### Bug Fixes

* (Raid Frames) **Major fix** for raid frames jumping/shifting position when players join, leave, or when loading into LFR/BGs — completely reworked the reposition pipeline to batch all updates into a single authoritative reposition, with a settling debounce for instance loading
* (Flat Raid Frames) Fixed flat raid frames flickering between party and raid settings during group transitions
* (Flat Raid Frames) Fixed flat raid frame positioning breaking after layout or roster changes
* (Position) Fixed mover handles for both party and raid staying visible after switching group type
* (Auto Layouts) Fixed several issues with switching between flat and grouped layouts — duplicate frames, hidden groups reappearing after combat, and layout not updating after mid-fight settings changes
* (Aura Designer) Fixed grouped layout preview not rendering correctly after the growth direction overhaul — indicators were stacking on top of each other instead of spreading out
* (Aura Designer) Fixed custom border indicators not showing on the frame preview
* (Aura Designer) Fixed indicators appearing on disabled pinned frames
* (Aura Designer) Fixed several Show When Missing visual issues — out-of-range alpha, transparent frames, stale duration text, pulsate animation not stopping, and indicators not appearing in test mode
* (Sound Alerts) Fixed sound engine not finding raid frames when using flat layout
* (Sound Alerts) Sound-only auras now correctly tracked for buff bar dedup
* (Sorting) Fixed secret string taint in cross-realm name caching

### Improvements

* (Debug Console) Added comprehensive debug logging across roster updates, header visibility, flat raid operations, frame positioning, and frame layout — helps diagnose frame issues in the field

## [4.1.2] - 2026-03-16

### New Features

* (Health Text) **Hide % Symbol** — new checkbox to remove the percent sign from health percentage text
* (Pinned Frames) **Growth direction anchoring** — Frame Growth and Column Growth now support Start, Center, and End options, controlling which edge stays fixed as frames are added (e.g. "Start" grows rightward/downward, "End" grows leftward/upward)
* (Pinned Frames) **Reset Position button** — resets a pinned frame set to the center of the screen if it gets lost off-screen

> **Note:** Pinned frame positions may have shifted slightly due to the new anchoring system. Use the Reset Position button or reposition frames if needed.

### Bug Fixes

* (Auras) Fixed buff/debuff borders staying visible even when disabled — operator precedence bug caused the buff border check to fire regardless of aura type
* (Aura Designer) Fixed stack count text bleeding onto adjacent icons when auras reorder in a layout group
* (Defensive Icons) Fixed 2nd+ defensive bar icons always showing tooltip and ignoring tooltip settings, anchor position, and click-through configuration
* (Resource Bar) Fixed resource bar being 2px too wide when "Match Width" is enabled and a frame border is active
* (Status Icons) Fixed leader icon not hiding in combat when "Hide in Combat" is enabled
* (Pinned Frames) Fixed error when OnDragStop fires without a matching OnDragStart on pinned frame movers

## [4.1.1] - 2026-03-15

### Bug Fixes

* (Position) Lowered permanent mover frame strata from HIGH to MEDIUM so it no longer covers other UI elements
* (Defensive Icons) Fixed double-scaled positioning offsets causing defensive icons to stack vertically instead of horizontally
* (Defensive Icons) Reduced raid frame defensive icon defaults (size 20, scale 1.0, max 3) to fit narrower raid frames
* (Pinned Frames) Fixed aura designer indicators (borders, defensives, dispels) leaking onto disabled pinned frame sets
* (Aura Designer) Fixed border indicator pandemic state using the regular border alpha instead of the configured expiring alpha
* (Aura Designer) Declassified Beacon of Virtue as non-secret — spell ID 200025 is on Blizzard's whitelist and readable via standard API

## [4.1.0] - 2026-03-14

### New Features

* (Position) **Permanent Mover handle** — a small always-visible drag handle on frames for repositioning without unlocking, with customizable position, size, offset, colors, show-on-hover with fade animation, hide-in-combat option, and red combat indicator
* (Position) **Permanent Mover quick actions** — left-click, right-click, shift+left-click, and shift+right-click can be bound to 13 preset actions including open settings, quick switch profile/click-cast profile, cycle profiles, toggle test mode, unlock frames, toggle solo mode, ready check, pull timer, reset position, and reload UI
* (Position) **Permanent Mover attach to unit** — handle can be attached to the container, first visible unit, or last visible unit so it follows the group size
* (Position) **Hide drag overlay** checkbox in the unlock panel to hide the blue drag area while keeping frames draggable
* (Dispel Overlay) **Color Name Text** — optional checkbox to color the unit's name text with the dispel type color when a dispellable debuff is present
* (Aura Designer) **Expiring pulsate for icon, square, and health bar indicators** — borders and fills can now pulse when an aura is about to expire
* (Aura Designer) **Expiring whole alpha pulse** — entire icon/square pulses its alpha when expiring
* (Aura Designer) **Expiring bounce animation** — icon/square bounces up and down when expiring
* (Aura Designer) **Hide duration text above threshold** — duration text can be hidden when the remaining time is above a configurable seconds threshold (icon, square, and bar types)
* (Aura Designer) **Expiring threshold in seconds** — expiring indicators can now trigger based on remaining seconds as well as remaining percentage
* (Aura Designer) **Trigger operator (ANY / ALL)** — indicators with multiple trigger spells can now require all triggers to be active (AND mode) or just one (OR mode, default)
* (Aura Designer) **Duration priority (Highest / Lowest)** — expiring indicators on multi-trigger spells can track the highest or lowest remaining duration buff
* (Aura Designer) **Custom border mode** — border indicators can now use an independent overlay per aura, so multiple border indicators can be visible at the same time
* (Aura Designer) **Settings grouped in containers** — all indicator settings panels and global defaults are now organized with bordered section containers
* (Aura Designer) **Earthliving Weapon** added as a trackable Restoration Shaman aura
* (Aura Designer) **Sense Power** added as a trackable Augmentation Evoker secret aura
* (Aura Designer) **Ebon Might self-buff tracking** — Augmentation Evoker's caster self-buff (395296) is now tracked on the player via fingerprint disambiguation, with correct tooltip and buff bar dedup
* (Aura Designer) **Symbiotic Relationship linked aura system** — Restoration Druid's caster buff is detected on the player and mirrored as an indicator onto the target's frame, with OOC target resolution, tooltip-based fallback, recast detection, and buff bar dedup
* (Aura Designer) **Ancestral Vigor** added as a trackable Restoration Shaman aura
* (Aura Blacklist) **Expanded blacklist coverage** — added Rogue poisons, Shaman weapon imbuements, Blessing of the Bronze (all class variants), Paladin rites, Mage Icicles, Hunter Tip of the Spear, and Shaman Reincarnation
* (Debug) **Script Runner** — multiline Lua script input in the debug console with persistent text across sessions

### Bug Fixes

* (Position) Fixed nudge buttons causing the blue drag area to vanish
* (Auras) **Fixed taint errors from secret value comparisons** — duration hide, expiring indicators, and color curves now correctly pipe secret values through secret-aware APIs only

## [4.0.16] - 2026-03-11

### Bug Fixes

* (Click Casting) **Fixed binding tooltip vanishing when pressing modifier keys** — modifier format mismatch caused all bindings to be filtered out
* (Pet Frames) Fixed taint error from secret boolean in pet range checking
* (Fading) **Fixed name and health text alpha resetting to 1.0** on zone change, combat res, vehicle exit, and test mode exit
* (Aura Designer) **Fixed secret auras not appearing immediately on cast in combat** — inline fingerprint matching eliminates race condition between detection and rendering
* (Aura Designer) Fixed Verdant Embrace tooltip incorrectly showing Upheaval

### New Features

* (Aura Designer) **Secret aura tracking** — tracks auras that WoW hides behind secret spell IDs using signature-based fingerprinting (credit to Harrek for the technique and aura data from Advanced Raid Frames)
* (Aura Blacklist) **Combat / out-of-combat controls** — per-spell checkboxes to blacklist auras only in combat, only out of combat, or both
* (Aura Blacklist) Redesigned blacklist UI as a single unified spell list with inline toggle and checkboxes

### New Trackable Auras (Aura Designer)

* **Preservation Evoker:** Time Dilation, Rewind, Verdant Embrace
* **Restoration Druid:** Ironbark
* **Discipline Priest:** Pain Suppression, Power Infusion
* **Holy Priest:** Guardian Spirit, Power Infusion
* **Mistweaver Monk:** Life Cocoon, Strength of the Black Ox
* **Restoration Shaman:** Hydrobubble
* **Holy Paladin:** Blessing of Protection, Holy Armaments, Blessing of Sacrifice, Blessing of Freedom, Dawnlight, Beacon of Virtue

### Improvements

* (Aura Designer) Spell cards now show WoW spell tooltips on hover
* (Aura Designer) Secret auras shown in a distinct section with visual styling to differentiate from regular auras
* (Aura Designer) Added "unsupported spec" message when viewing a non-healer spec
* (Aura Designer) **Class color border** on preview frame window showing the current spec's class
* (Aura Designer) **Class-colored spec dropdown** — each spec name colored by class for clarity
* (Aura Designer) **Customise button** on layout group members — jumps directly to that aura's effects settings
* (Aura Designer) Fixed page scrolling — only the right settings panel scrolls now, preview stays in view
* (Auras) Added **Raid In Combat** debuff filter option — matches the existing buff filter for better debuff coverage
* (Click Casting) Renamed "Mouseover" fallback to "Global" for clarity
* (Click Casting) "Does not work with action bar binds" warning now highlighted in red

## [4.0.15] - 2026-03-10

### Bug Fixes

* (Fading) **Fixed combat stutter when leaving combat**
* (Fading) **Fixed false out-of-range on units that were actually in range**
* (Fading) **Fixed everyone always showing as in-range** — re-added polling timer as a safety net alongside event-driven updates
* (Fading) **Fixed player frame being affected by out-of-range fading**
* (Aura Designer) **Fixed indicators ignoring their configured alpha**
* (Pet Frames) Fixed taint error when pet frame style changes during combat
* (Aura Blacklist) Fixed Harrier's Exhaustion not being filterable
* (Click Casting) Fixed binding tooltip showing wrong modifier
* (Aura Designer) Fixed health text showing in indicator preview when disabled

### New Features

* (Fading) **Hybrid range checking** — range now uses both instant events and a configurable polling timer for maximum reliability
* (Fading) **Missing health bar out-of-range alpha** — new element-specific alpha slider for the missing health (damage) portion of the health bar

## [4.0.14] - 2026-03-08

### Bug Fixes

* (Fading) **Fixed power/resource bar not fading when out of range**
* (Fading) **Fixed name text and health text not fading when out of range or dead/offline** in element-specific alpha mode
* (Fading) **Fixed debuff borders staying visible when faded**
* (Fading) Fixed defensive icons not fading when using Direct API mode with multiple defensives
* (Fading) Fixed name text flickering or staying at full alpha after switching specs
* (Fading) Fixed range checking not updating after changing talents
* (Missing Buff) Fixed missing buff indicator incorrectly showing on NPC followers in follower dungeons
* (API) Fixed external API functions not returning arena frames — `GetFrameForUnit()`, `GetAllFrames()`, and `IterateFrames()` now work correctly inside arenas
* (Side Menu) Improved hiding of Blizzard's raid/party side menu when disabled in settings
* (Raid Frames) **Fixed hidden groups reappearing on roster changes**
* (Raid Frames) **Fixed frames snapping to random positions on roster changes**
* (Raid Frames) **Fixed group order resetting on roster changes**
* (PvP) **Fixed health bars showing 100% in Battlegrounds**
* (PvP) Fixed self-healing cooldown not resetting on zone transitions
* (Test Mode) Fixed group visibility setting not applying in raid test mode
* (Test Mode) Fixed custom group display order not applying in raid test mode
* (Test Mode) Fixed "Columns Grow From" and "Reverse Order" dropdowns not updating flat raid test frames
* (Test Mode) Fixed layout settings not refreshing test frames when changed

### New Features

* (Range) **Range check fallback** — added a fallback for classes without friendly range check spells so out-of-range fading now works for all classes
* (Aura Designer) **Strata and frame level controls** — indicators can now be placed on different frame strata with a configurable default frame level
* (Test Mode) **Aura Designer support in test mode** — Aura Designer indicators now render on test frames
* (Aura Designer) **Out of range alpha** — new element-specific alpha slider for Aura Designer indicators (icons, squares, bars)

### Improvements

* (Test Mode) Redesigned test mode panel with collapsible sections, active count badges, and settings page quick-links

## [4.0.13] - 2026-03-08

### Bug Fixes

* (Click Casting) **Fixed keyboard click-cast bindings randomly stopping mid-hover** — keyboard-bound spells would sometimes stop working until the mouse left and re-entered the frame
* (Click Casting) Fixed spell transform procs (e.g. Flash of Light → Benediction) causing "Spell not Learned" errors
* (Click Casting) Fixed left-click casting randomly failing on some party/raid frames
* (Aura Blacklist) Fixed class dropdown overlapping text and not updating when selecting a different class
* (Auto Layouts) Fixed Aura Designer changes not saving when editing an auto layout a second time
* (Aura Designer) Fixed override indicators incorrectly appearing on internal proxy settings
* (Aura Designer) Fixed crash caused by corrupted saved data
* (Aura Designer) Fixed crash when swapping to a profile without Aura Designer settings

### Improvements

* (Missing Buff Icon) **Missing buff icons now work in combat** — previously they would disappear when entering combat
* (Missing Buff Icon) Added support for talent variant spell IDs (Mark of the Wild, Arcane Intellect)
* (Missing Buff Icon) Improved Blessing of the Bronze detection to cover all Evoker variants
* (Debug Console) Export now respects current severity and category filters
* (Aura Designer) Increased all X/Y offset slider ranges to -150 to 150
* (Aura Designer) Grouped layout spacing slider now allows negative values for overlapping indicators
* (Aura Designer) Added "Reset to Global" button when editing auto layout overrides
* (Aura Designer) Editing banner no longer overlaps page controls

## [4.0.12] - 2026-03-06

### New Features

* **Multi-trigger frame effects** (Aura Designer) — a single frame effect (border, health bar color, etc.) can now trigger on any of multiple auras (e.g. show a border if Rejuvenation OR Regrowth OR Lifebloom is active)
* **Layout groups** (Aura Designer) — group placed indicators at a shared anchor with automatic flow positioning; when an aura is inactive, grouped indicators collapse without gaps
* **Spec-scoped aura configs** (Aura Designer) — configurations are now saved per-spec, so shared buffs like Prayer of Mending can have different indicator setups on each spec
* **Preview click-to-select** (Aura Designer) — left-click any indicator on the frame preview to jump to its settings; right-click to remove it
* **Duration and Stack text color** (Aura Designer) — new color pickers with alpha for duration text and stack text on icon and square indicators, available as both global defaults and per-indicator overrides
* **Hide Icon (Text Only)** (Aura Designer) — new checkbox on icon and square indicators that hides the icon visual while keeping duration and stack text visible
* **Cancel Targeting option** (Click Casting) — new per-binding checkbox in advanced settings that adds /stopspelltarget to the macro, preventing the blue targeting hand on certain spells. Disabled by default so spells like Rescue work correctly

### Bug Fixes

* (Frames) Fixed buff/debuff/defensive tooltips not showing when hovering aura icons
* (Frames) Fixed defensive bar icons not receiving hover events for tooltips
* (Frames) Fixed aura icons created during combat permanently losing tooltip hover after combat ends
* (Click Casting) Fixed smart resurrection not working on non-English WoW clients
* (Click Casting) Fixed click-casting "Spell not Learned" errors after talent changes
* (Click Casting) Fixed all click-casting bindings failing on non-English WoW clients

## [4.0.11] - 2026-03-03

### Bug Fixes

* Fixed target/focus/aggro highlights not showing on arena frames
* Fixed Aura Designer stack count font and outline settings not applying
* Fixed buff/debuff tooltips permanently breaking after combat until reload
* Fixed empty Buff Filters, Debuff Filters, and Defensives group containers showing when using Blizzard (default) aura mode
* Fixed Aura Designer health bar color overlay not restoring the correct color when the tracked buff expires
* Fixed Aura Designer health bar color overlay not matching the health bar texture
* Fixed Aura Designer health bar color not restoring correctly on login when a buff is already active
* Fixed party frames showing empty when loading into a follower dungeon
* Fixed Beacon of Virtue not available in the Aura Designer — it can now be configured with its own independent indicators
* Fixed Aura Designer spell icons changing when talent choice nodes replace a spell (e.g. Beacon of Light showing Beacon of Virtue's icon)

### Improvements

* Improved click-casting debug logging to help diagnose intermittent binding failures
* Added horizontal scrollbars to Aura Designer trackable auras and active effects strips

## [4.0.10] - 2026-03-02

### Bug Fixes

* Fixed addon managers (Wago, CurseForge) constantly prompting for updates due to stale version in TOC file — version is now updated as part of every release
* Fixed Aura Designer tracking buffs from other players instead of only your own casts

### New Features

* **Auto layout Copy To** — duplicate an auto layout (with all overrides) to any content type section, including same-section copying for different size ranges
* **Only My Buffs filter** — new toggle in Direct API buff filters that restricts all buff filters to player-cast buffs only (enabled by default); removes the now-redundant My Buffs sub-filter

## [4.0.9] - 2026-03-02

### Bug Fixes

* Fixed imported and duplicated profiles resetting to Default on reload/relog due to per-character SavedVariable not being synced

### New Features

* **Direct API buff filters** — added Not Cancelable, Big Defensives, and External Defensives as toggleable filter options
* **Additive filter logic** — enabled filters now use OR logic so selecting multiple categories shows the union (e.g. Raid In Combat + Big Defensives shows both) instead of requiring auras to match all selected filters
* **Defensive icon scanning** — defensive icon now detects both Big Defensives and External Defensives (e.g. Pain Suppression, Blessing of Sacrifice)
* **Filter tooltips** — hover any filter checkbox to see a description of what that category includes
* **Defensive bar spacing** — icon spacing slider now supports negative values for overlapping icons
* **Updated filter defaults** — buff filters default to Raid In Combat + Big Defensives + External Defensives; debuff filters default to Raid Debuffs + Crowd Control + Important Spells (migrated for existing users)

## [4.0.8] - 2026-03-01

### New: Aura Designer

Visual indicator system for tracking buffs, debuffs, and auras on your frames.
* **8 indicator types** — 3 placed indicators (Icon, Square, Bar) that occupy anchor points on the frame, plus 5 frame effects (Border, Health Bar Color, Name Text Color, Health Text Color, Frame Alpha) that affect the entire frame
* **Drag-to-place** — drag auras from the spell list onto any of 9 anchor points (corners, edges, center) with X/Y offset adjustment
* **Icon indicators** — spell icon with cooldown swipe, duration text, and stack count display
* **Square indicators** — colored square with cooldown swipe, duration text, and stack count
* **Bar indicators** — progress bar showing remaining duration with horizontal/vertical orientation, match-frame-width option, fill color, background color, and bar-color-by-time gradient
* **Border frame effect** — 5 styles: Solid, Animated, Dashed, Glow, and Corners Only with configurable thickness and color
* **Health Bar Color frame effect** — Replace or Tint mode with adjustable blend strength
* **Name/Health Text Color frame effects** — override unit name or health text color when an aura is active
* **Frame Alpha frame effect** — adjust entire frame transparency based on aura presence
* **Expiring system** — all 8 indicator types support an expiring color that activates below a configurable remaining-duration threshold, fully combat-safe
* **Priority stacking** — configurable priority per aura (1-20); frame effects only show the highest-priority active aura, placed indicators coexist on separate anchors
* **Buff coexistence** — standard buff icons can display alongside Aura Designer indicators, with a popup to choose when enabling AD
* **Global defaults** — configure default icon size, scale, duration/stack font, font scale, and outline style; new indicators inherit these automatically with per-indicator overrides available
* **Live preview** — indicators render on the frame preview in the options panel with adjustable zoom (0.75×–2.5×)
* **Per-spec aura lists** — curated aura lists for 8 healer and augmentation specs, auto-refreshes when switching specs

### New: Auto Layouts (Raid Only)

Automatically switches your raid frame layout based on content type and raid size. Does not apply to party, solo, or arena.
* **Three content categories** — Instanced/PvP (raids, dungeons, battlegrounds), Mythic (fixed 20-player), and Open World (world bosses, outdoor groups)
* **Per-size-range profiles** — create multiple layouts per content type, each covering a custom player range (e.g., 1-10, 11-20, 21-40). Mythic is a single fixed layout for 20 players
* **Automatic switching** — monitors group roster, zone changes, and instance type; applies the matching layout on-the-fly when content or raid size changes
* **Override-only storage** — each layout stores only the settings that differ from your global profile; everything else is inherited automatically
* **Full settings coverage** — overrides can include frame size, growth direction, groups per row, group visibility, bar colors, text settings, aura filters, icon toggles, pinned frame configuration, and more
* **Live editing** — click "Edit Settings" to enter editing mode with live frame preview; every change is tracked as an override with visual indicators showing which settings are modified vs global
* **Override indicators** — green checkmark for global values, orange star with reset button for modified values, per-tab override counts
* **Non-destructive** — your global profile is never modified; exiting editing mode restores your base settings cleanly
* **Crash recovery** — if editing is interrupted, the next login detects and restores your base settings
* **Status display** — shows current content type, instance name, raid size, active layout, and override count
* **Export/import support** — auto layout configurations included in profile exports

### New: Aura System Improvements

* **Direct Aura mode** — optional mode that gives full control over which buffs and debuffs appear using filter categories (Player, Raid, Big Defensive, etc.). Configure in Auras > Aura Filters
* **All Buffs / All Debuffs toggles** — master toggles to quickly show all buffs or all debuffs without configuring individual filters
* **Important Spells filter** — checkbox to show Blizzard's curated list of important buffs and debuffs
* **Buff deduplication** — buffs already displayed by the Defensive Bar or Aura Designer are automatically hidden from the buff bar. Enabled by default, toggle in Buffs tab
* **Multi-defensive icons** — Defensive Bar now shows all active big defensives simultaneously (up to configured max), not just one
* **Defensive bar compound growth** — growth direction now supports two-axis layouts (e.g., RIGHT_DOWN, LEFT_UP) with configurable wrap count
* Max buff and debuff icon count increased from 5 to 8

### New Features

* Health fade system — fades frames above a configurable health threshold, with option to cancel fade when a dispellable debuff is active (contributed by X-Steeve)
* Class power pips — Holy Power, Chi, Combo Points, etc. displayed on the player frame as colored pips with configurable size, position, anchor, color, vertical layout, and role filter options (contributed by X-Steeve)
* "Sync with Raid/Party" toggle per settings page (contributed by Enf0)
* Per-class resource bar filter toggles
* Click-cast binding tooltip on unit frame hover — shows active bindings with usability status (contributed by riyuk)
* Health gradient color mode for missing health bar (contributed by Enf0)
* Click-cast binding tooltip moved to main Tooltip settings with full anchor and position controls
* Debug Console — in-game debug log viewer (`/df debug` to toggle, `/df console` to view)

### Bug Fixes

* Fix click-casting "script ran too long" error when many frames are registered (ElvUI, etc.)
* Fix health fade errors caused by Blizzard's protected health values
* Fix health fade not working correctly on pet frames, in test mode, and during health animation
* Fix profiles not persisting per character — each character now remembers their own active profile
* Fix pet frames vanishing after reload
* Fix pet frame font crash on non-English clients
* Fix party frame container not repositioning when dragging width or height sliders
* Fix resource bar border, color, and width issues after login/reload/resize
* Fix heal absorb bar showing smaller than actual absorb amount
* Fix absorb bar not fading when unit is out of range
* Fix name text truncation not applied to offline players
* Fix summon icon permanently stuck on frames after M+ start or group leave
* Fix icon alpha settings (role, leader, raid target, ready check) reverting to 100% after releasing slider
* Fix click-casting not working when clicking on aura/defensive icons
* Fix click-casting "Spell not learned" when queuing as different spec
* Fix DF click-casting not working until reload when first enabled
* Fix Clique compatibility — prevent duplicate registration, defer writes, commit all header children
* Fix aura click-through not updating safely on login
* Fix leader icon not updating on first leader change (contributed by riyuk)
* Fix Lua errors during Blizzard frame registration (contributed by riyuk)
* Fix missing raid groups when reloading UI during combat
* Fix duration text showing on permanent buffs
* Fix defensive icons showing stale data after entering/exiting vehicles
* Fix unit name getting stuck to the vehicle name after exiting a vehicle
* Fix follower dungeon only showing 2-3 party members until /reload
* Fix click-casting reload popup appearing on every login when the Clicked conflict warning is set to Ignore
* Fix dispel overlay sometimes treating all debuffs as dispellable
* Fix non-defensive buffs appearing in the Defensive Bar when units are out of range
* Fix raid mover frame (orange anchor) not resizing when frame settings change
* Fix group labels anchoring to the wrong player when sorting is enabled

## [4.0.6] - 2026-02-15

### Bug Fixes

* `/df resetgui` command now works — was referencing wrong frame variable, also shows the GUI after resetting
* Settings UI can now be dragged from the bottom banner in addition to the title bar
* Fix party frame mover (blue rectangle) showing wrong size after switching between profiles with different orientations or frame dimensions
* Fix Wago UI pack imports overwriting previous profiles — importing multiple profiles sequentially no longer corrupts the first imported profile
* Fix error when duplicating a profile

## [4.0.5] - 2026-02-14

### Bug Fixes

* Raid frames misaligned / anchoring broken
* Groups per row setting not working in live raids
* Arena/BG frames showing wrong layout after reload
* Arena health bars not updating after reload
* Leader change causes frames to disappear or misalign
* Menu bind ignores out-of-combat setting
* Boss aura font size defaulting to 200% instead of 100%
* Click casting profiles don't switch on spec change
* Clique not working on pet frames
* Absorb overlay doesn't fade when out of range
* Heal absorb and heal prediction bars don't fade when out of range
* Defensive icon flashes at wrong opacity when appearing
* Name text stays full opacity on out-of-range players
* Health text and status text stay full opacity on out-of-range players
* Name alpha resets after exiting test mode
* Glowy hand cursor after failed click cast spells
* Macro editing window gets stuck open when reopened
* Flat raid unlock mover sized incorrectly
* Fonts broken on non-English client languages

### New Features

* Click casting spec default profile option
* Group visibility options now available in flat raid mode
* Slider edit boxes accept precise decimal values for fine-tuned positioning and scaling
]===]
