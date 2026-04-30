# Changelog

## 2.2.10 - 2026-04-23

### Fixed
- Fixed an over-aggressive prey-zone fallback regression from 2.2.10 where unresolved quest-zone data could mark legitimate in-zone hunts as explicitly out-of-zone, causing Stage 1-3 bar updates to stop and the bar to disappear mid-hunt.
- Tightened the `Only show in prey zone` widget-visible fallback so it only acts as an in-zone signal when Preydator has actual prey-zone map evidence, preventing wrong-zone false positives like Silvermoon City without hard-marking unresolved live hunts out of zone.
- Fixed world-map mouseover taint path (`Blizzard_SharedXML/LayoutFrame.lua:491`, secret-number compare) by removing direct numeric coercion on raw map-ID payloads in prey-zone canonicalization and using fail-closed token parsing before map-ID comparisons.
- Hardened minimap/flying prey-zone refresh paths against secret-value taint by sanitizing `GetBestMapForUnit` and quest-zone map payloads in-scope before any helper-call boundaries, preventing protected map values from propagating into later layout comparisons during tooltip updates.
- Fixed `/pd inspect bs` usability when BugSack/error-handler dispatch fails. The command now prints the inspect lines to chat as a fallback instead of only reporting the dispatch failure.
- Fixed `/pd inspect` reporting `shouldShowBar=false / onlyShowInPreyZone-block` while the bar was physically visible. The diagnostic `onlyShowInPreyZone` branch now mirrors the actual `BarRuntime` logic including the `preyWidgetVisible` fallback, so the inspect output truthfully reflects what the bar is doing.

## 2.2.9 - 2026-04-19

### Fixed
- Fixed sound-selection persistence during load/update normalization so addon-local custom selections are retained when stored with legacy filename/full-path/case variants.
- Fixed a sound migration bug where the saved Bloody Command sound was not included in the allowed custom sound set, causing custom Bloody Command selections to reset to a fallback sound on load.
- Retired the legacy 2.2.0 audio-defaults prompt so updates can no longer accidentally replace a player's saved sound choices.
- Silenced Luacheck's false-positive `main function has more than 200 local variables` warning for the monolithic core runtime file so style checks stop flagging the file for its chunk size alone.
- Fixed Ambush/Bloody Command text fallback so alerts no longer render blank when legacy empty prefix values are carried forward; legacy text settings now migrate to `AMBUSH: ` + `preyTargetName` and `Bloody Command: ` + `bloodyCommandSourceName` defaults.
- Fixed alert text behavior when both prefix and suffix are empty so Ambush/Bloody Command alerts keep the Stage label instead of showing no text.
- Fixed Ambush trigger misses for non-name chat lines by adding a fallback phrase detector (including trap callouts) in active prey context, matching ActionSounds-style behavior while preserving prey-name matching priority.
- Added Ambush chat gate diagnostics to debug log (`/pd debug show`) so accepted/ignored chat lines include event/sender/match-route details.
- Fixed suffix variable-marker rendering so when `preyTargetName` or `bloodyCommandSourceName` is selected but no runtime name is available yet, the marker text remains visible instead of collapsing to prefix-only text.
- Fixed Ambush variable-name resolution in fallback chat routes by passing sender through the trigger and using it as dynamic name fallback when `preyTargetName` is selected but quest-title parsing has not populated yet.
- Fixed delayed Currency Tracker gain/loss updates by restoring immediate refresh on loot/currency chat signals and subscribing the currency module event frame to direct currency/update events (`CURRENCY_DISPLAY_UPDATE`, `CHAT_MSG_CURRENCY`, `QUEST_TURNED_IN`, `BAG_UPDATE_DELAYED`) while keeping deferred follow-up sweeps for late server updates.
- Changed Hunt Table achievement matching to strict QuestID criteria only. Title/name/difficulty fallback matching is now disabled so achievements only signal when an explicit questID criteria mapping exists.
- Removed name-based achievement fallback cache population in HuntScanner so only questID criteria mappings are built for signals.
- Fixed strict questID achievement stacking for mode tiers by evaluating lower mode achievements (I/II) with the same quest criteriaID hint as Mode III, so rows can correctly show combined pending counts (for example `x2` when both II and III are still incomplete).
- Extended strict questID cumulative stacking to non-I/II/III per-quest achievements by resolving same-target lower-tier questIDs through criteria-index alignment, so higher-tier hunt rows also include unmet mapped achievements from lower tiers.

### Added
- Added ordered sound catalogs so audio selectors now list `None` first, then custom addon-local sounds, bundled Preydator defaults, and finally extra registered sounds discovered from LibSharedMedia.
- Added validation support for non-Preydator registered sound paths so selecting an external catalog sound is preserved by settings normalization instead of being reset on load.
- Added a dedicated searchable sound picker popup (15 visible rows with scrollbar) for all sound-selection controls (Stage 1-4, Ambush, Bloody Command, Echo of Predation).
- External LibSharedMedia sound entries are labeled with a source prefix (`LSM: Sound Name`). Preydator bundled sounds and custom user files are unlabelled.

## 2.2.8 - 2026-04-18

### Fixed
- Fixed stage progression skipping Stage 2 during objective-inference fallback when widget progress state was unresolved. The first-objective-complete path now maps to `progressState=1` (Stage 2) instead of `progressState=2` (Stage 3), restoring correct stage flow.

## 2.2.7 - 2026-04-18

### Added
- Added static prey quest data module with deterministic questID mappings for difficulty and criteria IDs (`Modules/PreyQuestData.lua`) and TOC registration before HuntScanner.
- Added explicit tracked per-quest achievement mapping table for non-meta prey achievements using IDs curated in `issues/achievements.md`.
- Added achievement route diagnostics counters (`id`, `fallback`, `miss`) to HuntScanner and surfaced them in `/pd inspect`, `/pd hinspect`, and `/pd ainspect` outputs.
- Added Ambush debug instrumentation when sound playback is skipped by cooldown, so `/pd debuglog` explicitly reports the remaining cooldown instead of failing silently.

### Changed
- HuntScanner achievement signal cache now prioritizes static questID-driven ID matching for known prey quests, including mode I/II/III checks by difficulty, before legacy text fallback routes.

### Fixed
- Fixed locale-sensitive prey achievement signal drift by moving primary matching to ID-based quest criteria checks for mapped prey quests.
- Fixed bar not resetting to Stage 1 after player death on Hard/Nightmare hunts before Stage 4. The widget cache's anti-regression guard was blocking the post-death objective rollback; `PLAYER_ALIVE` now clears the cache so the bar re-evaluates from live quest state. Stage 4 is exempt (death after reaching Stage 4 no longer causes an objective reset).
- Fixed Shift+RightClick minimap Options opening in combat triggering `[ADDON_ACTION_BLOCKED]` on Blizzard's protected `OpenSettingsPanel()` call by deferring the panel-open request until `PLAYER_REGEN_ENABLED`.
- Fixed Currency Tracker opening tainting Blizzard money/currency UI with a secret-number payload by sanitizing `C_CurrencyInfo.GetCurrencyInfo()` quantity and icon values before any addon-side arithmetic or UI binding.
- Fixed `Only show in prey zone` permanent bar blocking when `preyZoneMapID` is unresolved but the Blizzard prey widget is currently visible; bar visibility now accepts the same widget-driven in-zone signal already used by stage-4 handling.
- Added Eversong Woods (`2395`) to known prey map canonicalization so prey-zone fallback certification resolves active Eversong hunts correctly (including quest `91245`).
- Fixed noisy-event out-of-zone gating so ambush chat processing is only suppressed when the player is explicitly out of prey zone (`inPreyZone=false`), not when zone state is temporarily unknown (`inPreyZone=nil`) during active hunts.

## 2.2.6 - 2026-04-14

### Fixed
- Fixed `Only show in prey zone` permanentlyblocking the bar when `preyZoneMapID` is nil but the Blizzard prey widget is visible: bar visibility now treats an active prey widget as an authoritative in-zone signal (same pattern already used for stage-4 zone detection), so bars show correctly without requiring HuntScanner or zone-API resolution.
- Added Eversong Woods (map 2395) to the known prey map table so zone-certification fallbacks can correctly resolve Eversong-based hunts (e.g. Consul Nebulor questID 91245).
- Added a cooldown-skip debug log entry when the ambush sound is blocked by the 80-second cooldown, so blocked sounds are visible in `/pd debuglog` instead of silently dropping.
- Added a self-contained bar-side prey-zone fallback that no longer depends on HuntScanner map cache data: when Blizzard zone APIs are unresolved, active hunts can now bootstrap zone certification from known prey maps using widget setup/bound-quest signals plus tracked-widget presence (including hidden default-icon cases) with quest-log `isOnMap` guardrails, so mid-hunt updates do not require re-picking the quest to restore `Only show in prey zone` visibility.
- Fixed live prey progression updates stalling without reload by hardening widget-cache refresh behavior and objective fallback gating, so stage transitions continue to advance during active hunts.
- Fixed login/bootstrap race cases where active prey state could initialize late and leave runtime polling/event flow idle until a manual refresh/reload.
- Added queued login bootstrap refresh passes after `PLAYER_LOGIN`/`PLAYER_ENTERING_WORLD` so delayed quest/widget readiness does not require manual reload to initialize bar state.
- Fixed stale stage/progress carryover on prey quest re-accept (including same questID) by resetting widget/progress cache on `QUEST_ACCEPTED` before runtime reconciliation.
- Fixed stage regressions from stale/partial widget data by preserving stronger known progress and preventing in-hunt progressState rollbacks.
- Fixed reload bootstrap/state carryover issues so fresh hunts no longer jump to an incorrect stage and same-quest stale snapshots do not override live context.
- Fixed prey-zone gating edge cases so non-prey areas do not falsely latch in-zone, while valid prey-widget signals still assert in-zone state for active hunts.
- Fixed quest lifecycle cleanup so turn-in/abandon boundaries clear zone/progress state consistently and prevent stale bar persistence.
- Fixed wrong-zone bar visibility false positives under `Only show in prey zone` by removing unresolved zone-certification fallbacks that inferred in-zone from the current player map or fresh prey-widget activity (for example latching Silvermoon/Voidstorm hunts to Zul'Aman or Harandar).
- Fixed accepted hunts with unresolved Blizzard zone APIs staying zone-unknown after Hunt Table pickup by promoting the current live Hunt Table zone inference into a transient runtime map ID, so the active hunt resolves the correct zone without persisting a permanent quest-to-zone binding.
- Fixed prey-specific ambush reliability by improving prey-name extraction and matching logic while keeping triggers anchored to the active prey target.
- Fixed Hunt Table achievement indicators not showing for some hunts when achievement criteria quest IDs did not match offer quest IDs or criteria metadata arrived incomplete; signals now include robust title/difficulty fallback matching.
- Fixed Hunt Table mode mismatches where pin-description parsing could assign the wrong Normal/Hard/Nightmare key for live rows; difficulty now prefers authoritative quest-title metadata before fallback parsing.
- Tightened Hunt Table pin difficulty parsing to accept only unambiguous mode markers (including parenthesized suffixes), preventing mixed description text from being misclassified to the wrong difficulty.
- Updated Hunt Table difficulty memory to prefer confirmed questID mappings first and only persist newly parsed values when difficulty detection is unambiguous, preventing guessed defaults from polluting cross-region quest difficulty cache.
- Fixed strict achievement name matching misses caused by punctuation/spacing variants (for example `Jan'alai` vs `Janali`) by adding compact-key lookup while preserving difficulty boundaries.
- Fixed a Hunt Table regression where cross-difficulty inference could incorrectly match Normal/Hard rows against Nightmare achievements; matching is strict by mode and no longer infers a different difficulty bucket.
- Fixed additional title drift cases where Blizzard hunt rows and achievement criteria differ only by a leading article (`The ...`), by trying article variants during strict title-key resolution.
- Added a scoped alias for `The Talon of Jan'alai` -> `The Talon of Janali` in hunt-achievement title resolution to handle Blizzard transliteration drift while keeping strict difficulty boundaries.

### Added
- Added objective-inference diagnostics to `/pd qinspect` (`objectiveInference`) and hardened inspect/qinspect BugSack dispatch to fail closed.

### Changed
- Canonicalized prey-map fallback equivalence for Zul'Aman (`2537 -> 2437`) in legacy/runtime-safe zone resolution paths.

## 2.2.5 - 2026-04-12

### Fixed
- Fixed a default prey-icon suppression regression where the Blizzard prey icon could remain visible during active hunt progression (including stage 3) while `Disable Default Prey Icon` was enabled. Suppression now attempts immediately even during combat-lockdown windows and keeps post-combat reapply as a fail-closed fallback if a frame remains shown.
- Fixed incorrect-zone prey bar visibility when Blizzard returned `GetInfo(...).isOnMap=true` but no reliable prey-zone map ID. Preydator no longer treats broad quest-log map membership as proof that the player is inside the prey zone, preventing false positives like Eversong Woods showing a Zul'Aman hunt bar under `Only show in prey zone`.
- Fixed a zone-entry regression where the Preydator bar could stay hidden in the correct prey zone until deeper movement triggered a later widget setup/suppression pass. When Blizzard has not yet provided a reliable quest-zone map, a currently shown prey widget is now treated as authoritative in-zone confirmation for the bar and icon-suppression paths.
- Fixed stage-1 audio not firing reliably after reload when zone state entered through widget-setup timing paths instead of an explicit stage transition. Entering the prey zone now triggers one current-stage sound pass when no prior stage sound was played for that stage.
- Fixed a reload case where the bar could remain hidden in-zone with `Only show in prey zone` until leaving/re-entering. Any prey-widget setup now refreshes setup-freshness timing even when payload fields are sparse, allowing zone confirmation to resolve without requiring a later zone transition event.

## 2.2.4 - 2026-04-11

### Fixed
- Fixed a post-completion stale stage-4 latch where polling could disable at kill-carry expiry before a final state reconcile, leaving the bar visible with no live prey quest and preventing expected Hunt Table completion refresh behavior.
- Hardened `/pd qinspect bs` BugSack dispatch by guarding error-handler send calls with an outer protected wrapper so handler faults fail closed to chat output instead of surfacing a command-time Lua error.
- Fixed stale widget carryover on new quest acceptance that could immediately force stage 4 / 100% and fire completion sound logic; quest handoff now clears widget timing state and ignores unbound widget payloads unless backed by a fresh Setup signal.
- Fixed in-zone stage instability where unbound prey-widget payloads could be dropped after setup freshness elapsed, causing stage/progress to bounce or reset; widget updates are now bound to the active tracked prey quest at setup time and cleared on quest handoff.
- Restored bar visibility for active prey quests when Blizzard quest-zone APIs return nil by adding a HuntScanner-backed quest->zone map fallback in prey-zone resolution, preventing `inPreyZone=nil`/`onlyShowInPreyZone` false blocks.
- Fixed remaining stage fallback-to-zero/one cases by binding widget quest context immediately on quest handoff, so unbound widget payloads remain associated with the current active prey quest instead of expiring into nil stage data.

## 2.2.3 - 2026-04-11

### Changed
- Removed the unused `/preydator` slash entrypoint and kept `/pd` as the sole command entrypoint.
- Removed unused core slash aliases: `/pd open`, `/pd mem`, and `/pd memory`.
- Narrowed inspect command aliases to `/pd inspect` and `/pd inspect bs`; removed unused `bug`, `bugsack`, `both`, and concatenated inspect aliases.
- Renamed quest inspect command family from `inspectquest` to `qinspect`, with support for `/pd qinspect [questID] [bs]`.
- Renamed hunt debug command family from `huntdebug` to `hinspect`, with support for `/pd hinspect [bs]` and `/pd hinspectcopy [bs]`.
- Updated zhCN/koKR localized slash-help text to reference the current `hinspect` and expanded inspect command surface.

### Fixed
- Hardened HuntScanner achievement matching so quest-ID criteria remain authoritative and name-based fallback is used only when a quest criteria entry has no usable quest asset ID.
- Improved HuntScanner name matching normalization for non-English clients by stripping localized prefix labels (colon-form), preserving non-ASCII text during normalization, and detecting localized difficulty markers via locale tokens.
- Re-enabled HuntScanner reward-cache warming in live Hunt Table context so hunt rewards populate again when the Hunt Table is open (`interactionType=3`, mission frame + map tab visible).
- Clarified runtime safety policy: in restricted instance content (party, raid, scenario, delve, arena, pvp), Preydator runtime behavior is intended to fail closed and remain inactive.
- Fixed Echo nameplate GUID parsing taint by removing direct empty-string comparisons on secret GUID payloads and parsing NPC ID from raw GUID values through taint-safe coercion only.
- Hardened restricted-instance runtime gating with scenario fallbacks and an early EventRuntime fail-closed return so Preydator runtime handlers do not execute in instance content.
- Fixed an over-broad scenario fallback in core restricted-instance detection that could hide the prey bar outside instances; scenario fallback now requires valid stage metadata before fail-closing runtime behavior.
- Fixed prey-zone transition cache gaps that could leave `preyZoneMapID` unresolved (`nil`) during active hunts, incorrectly blocking bar visibility under `Only show in prey zone`; active progress/widget signals now latch a safe canonical zone map fallback.
- Reduced default prey-icon hide flicker by using event-driven suppression reapplication (mixin/setup transitions and combat-safe deferred retries) instead of periodic polling.

### Added
- Added `localization-audit.ps1` sanitizer workflow for issues datasets to normalize `Korian` -> `Korean` labels and skip `[DNT] [PH]` placeholder rows during import prep.

## 2.2.2 - 2026-04-10

### Fixed
- Hardened Echo of Predation nameplate GUID parsing to avoid direct comparisons on raw `UnitGUID` values in protected contexts, preventing secret-string compare faults in `NAME_PLATE_UNIT_ADDED` handling.
- Added a reusable taint-safe GUID-to-NPC parser helper and routed both Echo nameplate handling and HuntScanner target-NPC parsing through it.
- Hardened Echo NPC-ID coercion to use the shared fail-closed numeric conversion path instead of direct `tonumber(...)`.

## 2.2.1 - 2026-04-10

### Changed
- Added an idle-off runtime mode for core prey tracking events. With no active prey quest, Preydator now unregisters prey runtime event listeners and keeps only bootstrap/quest-accept detection active until a live prey quest exists.
- Reduced CurrencyTracker idle event subscriptions to loot-only refresh on its dedicated event frame.

### Fixed
- Fixed an Echo of Predation nameplate taint path in restricted instances introduced in 2.2.0. Nameplate Echo processing is now blocked unless prey runtime is active and context-valid.
- Hardened debug slash handlers (`/pd huntdebug`, `/pd inspect`) to fail closed in restricted instances instead of running broad snapshot/inspect reads. These paths were exposed by the expanded slash-command surface added in 2.2.0.

## 2.2.0 - 2026-04-10

### Added
- Hunt Tracker achievement matching remains difficulty-strict for prey criteria so Normal/Hard/Nightmare requirements do not cross-credit between modes.

- Increased Audio test-button widths to fit longer labels cleanly.
- Updated Bloody Command gating to stages 1, 2, and 3 only (Nightmare difficulty required).
- Updated release packaging script to use an explicit runtime include list (`Preydator.toc`, `Preydator.lua`, `Core`, `Modules`, `Locales`, `media`, `sounds`) so commit-only/docs/dev files are not shipped in release zips.
- Bumped addon version to `2.2.0` in both `Preydator.toc` and `build-release.ps1` default version.
- Added `Music` as a valid Audio sound channel option and normalized/validated it across playback/runtime paths.
- Moved `Silence Arator` control into the primary Audio checkbox area (above `Custom Files / Tests`) and removed the extra section title.
- Moved `Enhance Sounds` to the right column under the Audio hint text and aligned it to the `Echo of Predation Sound` row.
- Increased Ambush sound cooldown from `45s` to `80s`.
- Simplified stage-4 bar click behavior to only set the active prey quest as super-tracked.
- Removed stage-4 bar click dependence on `Disable Default Prey Icon`; quest super-track click now works whether the default icon is shown or hidden.
- Updated new-install/default sound mapping to: stage1 `predator-ambush.ogg`, stage2 `predator-snarl-01.ogg`, stage3 `predator-torment.ogg`, stage4 `predator-kill.ogg`, ambush `well-we-ve-prepared-a-trap-for-this-predator.ogg`, bloody command `predator-kills-its-prey-to-survive.ogg`, echo `echo-of-predation.ogg`.
- Updated Advanced `Show What's New` to re-show the 2.2.0 audio-defaults prompt for repeat close/apply testing.
- Hardened localized difficulty detection to be case-insensitive across clients while preserving canonical internal keys.
- Added explicit ruRU difficulty initials override (`О/В/К`) for Warband prey header display.

### Fixed
- Removed stage-4 map-open and waypoint fallback behavior (`OpenQuestMap`/`ToggleWorldMap`/user waypoint placement) from bar-click handling to reduce taint-risky map/widget interaction paths.
- Cleared prey-zone/active-quest cache state explicitly on prey quest lifecycle boundaries (`QUEST_TURNED_IN`, `QUEST_REMOVED`/abandon) so each new prey quest resolves a fresh zone map target and avoids stale-zone carryover.
- Fixed 2.2.0 audio-defaults prompt runtime error on reload caused by early-scope frame cache writes resolving `state` as nil.
- Fixed 2.2.0 `New Defaults` click runtime error caused by direct `NormalizeAmbushSettings` call resolving to nil in early method scope.

## 2.1.17 - 2026-04-08

### Fixed
- Fixed `Blizzard_UIWidgetTemplateTextWithState.lua:35` tooltip widget taint cascade (`attempt to perform arithmetic on local 'textHeight' (a secret number value tainted by 'Preydator')`). Root cause: multiple widget and frame introspection paths executed during event processing were reading Blizzard frame properties (via `ResolvePreyFieldsFromFrame`, `CaptureLivePreyHuntFrames`, mixin hook via `hooksecurefunc`), which returned values tainted by the widget system. These tainted reads occurred in addon execution contexts that cascaded into simultaneous tooltip widget processing, corrupting unrelated widgets like TextWithState. Fixed by disabling ALL widget/frame introspection paths and obtaining prey state exclusively from pure quest APIs and tracked state. Prey icon suppression and frame suppression hooks are now disabled; prey progression is tracked entirely from `QUEST_ACCEPTED`, `QUEST_COMPLETE`, and quest data events without frame reads.
- Fixed `Blizzard_SharedXML/SharedTooltipTemplates.lua:213` world-map tooltip taint (`attempt to compare local 'frameWidth' (a secret number value tainted by 'Preydator')`). Root cause: the `EnsureWidgetSuppressionHook` OnShow script was calling `ApplyWidgetFrameSuppression` inside a pcall, establishing a taint context that propagated to downstream Blizzard layout code. Fixed by disabling frame suppression in the OnShow hook entirely; suppression now happens exclusively through the state/settings update handlers outside the widget event context, preventing taint spillover into tooltip/layout rendering.
- Fixed stage-4 "find location" map-open flow to avoid protected world-map pin mutation during combat lockdown (`Button:SetPassThroughButtons` action blocked path).
- Removed forced `QuestMapFrame_OpenToQuestDetails(...)` call from the stage-4 helper and rely on quest super-track / waypoint behavior instead.
- Fixed `Blizzard_UIWidgetTemplateTextWithState.lua:35` world-map tooltip taint (`attempt to perform arithmetic on local 'textHeight' (a secret number value tainted by 'Preydator')`). Root cause: the `UIWidgetTemplatePreyHuntProgressMixin.Setup` hook was reading `widgetInfo.shownState` and `widgetInfo.progressState` directly while in a tainted execution context, storing the raw secret-number values in `preyWidgetInfoCache`. Those tainted values later propagated into bar display arithmetic and corrupted Blizzard's tooltip widget layout. Fixed by sanitizing both values via string-roundtrip coercion (`tostring` → `tonumber`) inside the hook, producing a clean plain integer before storage and breaking the taint chain.
- Fixed additional world-map tooltip taint path (`Blizzard_SharedXML/LayoutFrame.lua:491` secret-number compare) by enforcing the same numeric sanitization barrier on prey-widget frame fallback reads and on all widget-derived progress values before writing to addon state/cache (`newProgressState`, `newProgressPercent`, objective percent).
- Added a broader taint-hardening pass for numeric extraction/parsing in prey progress/objective percent math and HuntScanner map fallback/debug-event capture, while preserving all existing addon behavior and user-facing features.

### Localization
- Updated `esES` (Spanish - EU) localization strings for Preydator prey labels and difficulty terms.
- Added/confirmed contributor credit in the Spanish locale file. Thank you `jaestevan` for the translation help.

### Notes
- Confirmed `AreaPoiUtil.lua:SetPadding` taint can be reproduced with Preydator disabled; issue does not originate from this addon.

## 2.1.16 - 2026-04-04

### Fixed
- Hardened HuntScanner restricted-instance gating for scenario edge cases by treating explicit scenario API state as restricted even when `IsInInstance()` returns transient/nonstandard values.
- Added safe HuntScanner snapshot-error context logging (`instance` / `scenario` state summary) so any remaining restricted-content snapshot failures can be diagnosed from user reports without exposing protected payloads.
- Fixed prey icon suppression intermittently showing during hunt progression in combat by attempting immediate suppression on prey-widget `OnShow` and only deferring to post-combat retry when the frame remains visible.

## 2.1.15 - 2026-04-03

### Fixed
- Fixed prey icon suppression regression in 2.1.14 where the "Disable Default Prey Icon" option stopped working. Icon suppression hook is now properly applied when the option is enabled.

## 2.1.14 - 2026-04-02

### Fixed
- Added canonical map-ID equivalence for the new prey-zone sub-map mismatch case so player map `2444` is treated as zone map `2405` in prey-zone checks (`2405` -> `2405`, `2444` -> `2405`).
- Hardened stage-4 prey map-open flow against protected quest/map payloads by sanitizing active quest IDs before map/super-track API calls.
- Hardened map/value coercion paths to avoid direct numeric conversion on protected payload values by switching to fail-closed token parsing in `SafeToNumber(...)`.
- Fixed protected-call map taint (`Button:SetPassThroughButtons`) by removing Preydator runtime mouse/drag mutations on Blizzard-owned prey widget frames.
- Fixed remaining world-map delve tooltip taint path (`AreaPoiUtil.lua:SetPadding` secret-value restriction) by disabling runtime suppression/click hook mutations on Blizzard prey widget frames and keeping Preydator in read-only prey-widget state capture mode.

## 2.1.13 - 2026-04-01

### Fixed
- Fixed delve combat chat spam (`Preydator HuntScanner: snapshot error: attempt to perform string conversion on a secret string value`) caused by stale `huntInteractionActive` state still allowing non-login HuntScanner event paths to queue snapshot work in restricted instances.
- Added a blanket non-login restricted-instance early return in HuntScanner event handling, so `ACHIEVEMENT_EARNED`, `CRITERIA_UPDATE`, `QUEST_DATA_LOAD_RESULT`, and other events cannot trigger snapshot passes while inside delve/instance content.
- Hardened HuntScanner reward snapshot and formatting paths to avoid raw `tostring(...)`/`tonumber(...)` coercion on protected reward payload strings/numbers, reducing taint propagation into Blizzard widget tooltip/layout code (`Blizzard_UIWidgetTemplateTextWithState.lua`, `MoneyFrame.lua`, `LayoutFrame.lua`).
- Added an emergency taint guard that disables HuntScanner reward-cache warming via `AdventureMapQuestChoiceDialog` reward widget introspection. This prevents Preydator from touching protected reward-frame payloads that can spill secret-number taint into Blizzard world-map tooltip reward rendering (`GameTooltip.lua`, `MoneyFrame.lua`, `SharedTooltipTemplates.lua`).

### Cleanup
- Removed the stale legacy inspect-version constant from `Preydator.lua` (`INSPECT_VERSION`), which no longer had any live read paths after inspect routing moved to `Modules/DebugInspect.lua`.
- Removed the unused `Preydator.API.OpenLegacyOptionsPanel` compatibility shim from `Preydator.lua`.
- Fixed Hunt Tracker appearing when speaking to Astalor Bloodsworn (or other Hunt Table NPCs) outside of an active Hunt Table session. `IsHuntTableContext` now requires the Hunt Table mission frame to be visible before treating a matching NPC ID alone as a valid context signal; the explicit gossip-spell check (which covers opening the Table from its gossip menu) is still evaluated first and remains ungated.

## 2.1.11 - 2026-03-31

### Fixed
- Fixed HuntScanner snapshot errors in scenarios. The restricted-instance event gate previously had a selective event-name list, leaving `ACHIEVEMENT_EARNED`, `CRITERIA_UPDATE`, and `QUEST_DATA_LOAD_RESULT` able to fall through and trigger snapshot passes when `huntInteractionActive` was stale-true from a prior Hunt Table session. The gate is now a blanket early-return for all events (except `PLAYER_LOGIN`) when inside any restricted instance type.
- Hardened stage-4 prey waypoint fallback against protected world-map payloads. Preydator no longer reads `C_QuestLog.GetNextWaypoint()` and related quest-map coordinate fields through raw `tonumber(...)`/direct numeric comparisons, reducing another remaining path that could spill taint into Blizzard map tooltip/layout code such as `AreaPoiUtil.lua`.

## 2.1.10 - 2026-03-30

### Fixed
- Fixed world-map mouseover taint (`Blizzard_UIWidgetTemplateBase.lua:1638`, secret-number arithmetic tainted by Preydator) by fail-closing HuntScanner dialog reward snapshot parsing on item payload identity fields. Reward extraction now reads only display-safe text/texture fields and no longer reads `itemID`/`itemLink`/numeric quantity payload values from Blizzard reward widget tables.
- Fixed Hunt Table reward icon regression introduced by the taint hardening pass. Icon rendering now restores safe direct display-icon extraction (texture/atlas fields) while still avoiding taint-prone `itemID`/`itemLink` reward identity reads.
- Tightened HuntScanner noisy event gating to strict Hunt Table/preview context only. `UPDATE_UI_WIDGET`/`UPDATE_ALL_UI_WIDGETS`/`QUEST_LOG_UPDATE` subscriptions and processing no longer wake on active-prey world-quest state alone.
- Fixed legacy/invalid Hunt Table reward-style settings being treated as text-only. Reward style now normalizes to valid keys on load and icon-mode cache warm-up repopulates stale no-icon reward entries.
- Fixed Hunt Table icon backfill repeatedly walking many quests in the same difficulty. Cache replacement now prefers icon-bearing reward lists at equal score and propagates difficulty rewards across same-difficulty quests in one warm-up pass.
- Fixed HuntScanner snapshot runtime error (`attempt to call global 'RewardListHasIconTags'`) caused by helper declaration order during reward-cache replacement checks.
- Added prey-zone map alias fallback for Harandar sub-map mismatch cases (`2576` treated as `2413`) in the same canonical map-ID equivalence path used for prior Zul'Aman-style mismatches.
- Simplified bar-side zone matching to a lightweight generic path: compare canonical player map ID with canonical quest-zone map ID from `C_TaskQuest.GetQuestZoneID`, while preserving the prior Zul'Aman deterministic fallback (`2536` -> `2437`) and explicit override safety when task-zone lookup is unavailable.
- Restored the proven 2.1.9 prey stage resolution path after today's inferred-stage fallback experiments regressed live progression. Stage now follows the same live widget-driven behavior as 2.1.9 instead of attempting tooltip/objective stage inference.
- Improved prey-zone entry responsiveness by reducing false-zone retry refresh cadence (`2.0s` -> `0.5s`) so zone transitions are recognized faster while keeping true-state revalidation conservative.

## 2.1.9 - 2026-03-29

### Fixed
- Hardened prey widget mixin handling to read only safe game-state fields from `Setup(widgetInfo)` (`progressState`, `shownState`, `tooltip`) while never reading taint-prone widget identity/geometry fields, preserving stage progression without reintroducing secret-number taint paths.
- Hardened all noisy widget hook/event fanout paths to drop `UPDATE_UI_WIDGET` payload args before module dispatch/debug capture, preventing secret-value payload propagation through addon hook callbacks.
- Fixed remaining taint propagation path where `UPDATE_UI_WIDGET` secret-number payload args were passed across the main `OnEvent` → core runtime function call boundary before being nil'd. Passing a secret value as a function argument spreads taint into the callee's execution context regardless of whether it is used, which could corrupt unrelated Blizzard layout operations (e.g. `AreaPoiUtil.lua:65 SetPadding`). Args are now nil'd in the main handler before any function call.
- Removed dead `GetCandidateWidgetSetIDs` function and its `C_UIWidgetManager.GetPowerBarWidgetSetID` call and `rawSetID > 0` secret-number comparison, which were unreachable but could have introduced taint if ever triggered. Removed associated `C_UIWidgetManager` local and `candidateWidgetSetIDs` UI state field.
- Fixed prey-stage progression regression introduced during taint hardening by restoring controlled `widgetInfo` capture in the prey mixin hook; stage now advances correctly from live widget state while remaining fail-closed on taint-prone fields.
- Fixed stale `inPreyZone=true` state persisting across zone transitions/hearth moves by adding periodic true-state revalidation in prey-zone refresh logic (not just stale-false retries), preventing out-of-zone stage-1 fallback bars from showing when `Only show in prey zone` is enabled.
- Updated fallback stage-gate progression to match intended semantics: Thirds now uses `0/33/66/100` (stage 1 is zone gate), while Quarters remains `25/50/75/100`.
- Hardened bar visibility to strict no-instance behavior by treating `pvp` and `arena` instance types as restricted alongside party/raid/scenario/delve, so the bar cannot show in any instance regardless of `Only show in prey zone`.
- Fixed prey-zone false negatives in known sub-map mismatch cases by adding a deterministic map-alias fallback in zone resolution (`2536` treated as prey-zone map `2437` for affected prey quest context), removing icon/signal-driven zone fallback so bar visibility is based on stable map data rather than default prey-icon visibility.

### Cleanup
- Removed dormant prey widget-ID tracking/state paths (`TrackKnownPreyWidgetFrames`, `lastPreyWidgetID`, `lastPreyWidgetSetID`, and related debug output) so suppression now relies only on live prey-mixin frame capture, reducing stale code surface and future taint reintroduction risk.

## 2.1.8 - 2026-03-28

### Fixed
- Fixed non-final prey stages being able to display an over-reported 100% bar when live widget/objective percent payloads reached 100 before Blizzard advanced the prey widget to final stage. Non-final display percent is now capped to the selected segment ceiling for the resolved stage, so Thirds and Quarters cannot report completion early.
- Fixed Thirds stage fallback progression mismatch so documented and rendered fallback stages now align to `33/66/100` behavior instead of leaving stage 1 at `0%` when live percent data is unavailable.
- Hardened HuntScanner to a strict no-instance rule, including disabling options/theme preview and refresh paths while in restricted content where prey hunts and Hunt Table interactions cannot occur.
- Fixed restricted-instance Blizzard widget taint in delve/combat paths by fail-closing the prey-widget mixin hook before reading widget payload fields while in restricted content, preventing secret-value taint propagation into Blizzard widget layout arithmetic.

## 2.1.7 - 2026-03-27

### Fixed
- Fixed Hunt Tracker showing a Nightmare hunt in the wrong zone (2 hunts in one zone, 0 in the other). Root cause: hunt quest zone resolution APIs (`C_TaskQuest.GetQuestZoneID` and `C_Map.GetMapInfoAtPosition`) return nil for adventure map quest-offer pins, forcing fallback to hardcoded coordinate buckets in `InferZoneFromCoords`. The original thresholds were imprecise: `x > 0.70` and `y > 0.55` caused southern Eversong Woods pins (ny=0.678) to be misclassified as Zul'Aman. Fixed by calibrating thresholds to all 12 hunt locations: Harandar (x > 0.78), Voidstorm (x > 0.50 && y < 0.30), Eversong Woods (x < 0.35), Zul'Aman (else). Zone is now resolved correctly for all hunt quests across all four zones.
- Fixed `Blizzard_MoneyFrame` secret-number taint on world-quest reward tooltips by removing HuntScanner reads of taint-prone numeric reward payload fields during reward parsing/caching, and failing closed on those paths.
- Fixed intermittent HuntScanner `snapshot error` chat reports in restricted-content transitions (including delves) by replacing remaining raw `tonumber(...)` conversions in live snapshot/event paths with `SafeToNumber(...)` fail-closed coercion.
- Fixed hunt-table warm-up repeatedly inspecting the same representative quests when icon-upgrade fallback returned empty by preserving existing cached rewards instead of clearing them, preventing repeated 4-quest refresh spam.
- Fixed reward icon/count regressions from over-hardened extraction by restoring safe itemID/itemLink and quantity field parsing in dialog reward snapshots (still fail-closed via protected coercion/calls).
- Restricted reward inspection/review to strict Hunt Table mission context only (active interaction type 3 + mission map tab shown), preventing reward probing outside the table.
- Fixed quests getting stuck on `No tracked rewards` despite `cachedRewards` being populated by treating empty per-quest reward cache entries as pending data, re-allowing warm-up and difficulty-cache backfill for those rows.
- Fixed Hunt Table `Icon+Count` reward style failing to show counts for cached entries formatted as `Name xN` by extending count parsing to support both leading-amount and trailing-amount patterns.
- Fixed `bad argument #1 to 'SetWidth' (Secret values are only allowed during untainted execution)` errors triggered during World Quests by removing all `C_UIWidgetManager.GetAllWidgetsBySetID` widget-type/ID field reads from prey widget scanning. Reading `widgetType`/`widgetID` from `GetAllWidgetsBySetID` results propagates secret-number taint even inside `pcall`, corrupting Blizzard's subsequent layout processing for unrelated widgets (e.g. TextWithState "Runestone State:"). Prey widget state is now read from a snapshot captured by the existing `UIWidgetTemplatePreyHuntProgressMixin.Setup` hook, which copies only non-secret fields (progressState, tooltip, shownState, questID, percent fields) and never touches secret-number widget identity fields.

### Cleanup
- Streamlined Hunt Table reward rendering by consolidating duplicated preview/live reward-style formatting into one shared formatter, reducing code surface while preserving behavior.
- Further streamlined HuntScanner reward cache flow by deduplicating reward-score and empty-cache checks into shared helpers, reducing repeated logic across warm-up and render paths.
- Continued HuntScanner cleanup by extracting shared reward-style/icon helpers and removing repeated inline checks in reward summary formatting paths.
- Finalized this cleanup pass by centralizing reward-style settings lookup in one helper shared by preview and live reward-summary paths.

## 2.1.6 - 2026-03-26

### Release
- Updated addon metadata version to `2.1.6` in TOC and release tooling defaults.

## 2.1.5 - 2026-03-26

### Release
- Updated addon metadata version to `2.1.5` in TOC and release tooling defaults.

## 2.1.4 - 2026-03-26

### Fixed
- Hardened prey-icon suppression to operate on tracked prey widget mixin frames directly, removing the broad cross-container global frame probing path.
- Hardened prey-widget scanning so default prey icon visibility logic only queries prey-relevant widget sets (cached prey set + PowerBar) and no longer falls back to non-prey widget containers, preventing tooltip/widget-set taint spillover into Blizzard layout processing.
- Tightened default prey icon suppression behavior so when `Disable Default Prey Icon` is enabled, the Blizzard prey encounter visual (including the stage-4 glow layer) is consistently suppressed.
- Hardened prey icon suppression against residual icon/glow animation playback by stopping prey-frame animation groups and hiding prey icon/glow visual regions at suppression time.
- Reworked settings dropdown high-DPI scaling to bind per-Preydator dropdown open handling instead of a global `ToggleDropDownMenu` hook.

### Release
- Updated addon metadata version to `2.1.4` in TOC and release tooling defaults.

### Cleanup
- Removed dead helper functions `TryGetWidgetFrameByID`, `SetFrameIconVisible`, `ApplySuppressionToParentChain`, and `FindGlobalFramesForWidgetID` from `Preydator.lua`. These became unreachable after the container-probing path was removed in this version's hardening pass.
- Removed unused `UI.targetedWidgetGlobalFrameCache` field from the UI state table; no live code paths reference it after the global-frame scan helpers were deleted.

## 2.1.3 - 2026-03-25

### Fixed
- HuntScanner reward inspection is now strictly gated to active Hunt Table mission context only (mission frame shown and hunt interaction active), preventing open-world quest reward probing.
- Added explicit `koKR` localization assignments for all currently code-referenced localization keys to eliminate missing-key fallback to English.

### Release
- Updated addon metadata version to `2.1.3` in TOC and release tooling defaults.

### Changed
- Unified achievement badge color across all themes to use Protanopia's gold/orange tone for consistent visual distinction and better colorblind accessibility.
- Changed Hunt Tracker Accept button text to use the standard gold on normal themes while keeping the alternate color treatment on color-blind themes.
- Changed Warband character column sizing to measure cached character names dynamically so long names no longer truncate with ellipses.
- Added Hunt Table difficulty color pickers in Panels settings so Normal, Hard, and Nightmare badge colors can be changed directly from the options UI.
- Added an Achievement Badge color picker in Achievements settings so signal icon/text color can be customized without changing theme presets.
- Fixed Achievements settings description wrapping so long text stays inside the panel bounds.

## 2.1.1 - 2026-03-24

### Changed
- Bloody Command alert routing is now chat-only. Removed legacy aura-path event handling (`UNIT_AURA`) and related stale routing branches from core event fanout.
- Updated release behavior notes for Bloody Command to reflect Astalor chat-line trigger flow instead of player-aura trigger flow.
- Added an Advanced settings toggle for verbose Bloody Command diagnostics (`Verbose Bloody Command Debug`) so gate-detail logs can be enabled only when needed.
- Added `Category-koKR` metadata to the addon TOC so Korean clients get localized category labeling in addon lists.

### Fixed
- Fixed Blizzard widget taint propagation by removing Preydator-owned state writes on Blizzard widget frames. Suppression/click-hook state now uses addon-owned weak-key tables, preventing protected layout comparisons from seeing tainted frame tables.
- Hardened sound playback against invalid or legacy saved sound-channel values. Sound channel values are now normalized to canonical keys and playback can fall back to safe channels when needed.
- Added sound-channel self-heal on successful playback so recovered channel values are persisted back into settings.
- Added defensive sound-settings normalization for `soundsEnabled`, `soundChannel`, and `soundEnhance` so stale or malformed persisted values no longer block playback paths.
- Reduced Bloody Command debug noise during normal debug sessions by keeping one concise trigger line and gating verbose gate/skip traces behind `debugBloodyCommand`.
- Preserved fail-open safety for unknown widget payload shapes so client-specific event argument differences do not regress prey updates.
- Fixed Hunt Tracker achievement cache rebuild crash caused by helper-order resolution in Lua (`IsAchievementCompletedCached` resolving as nil during first rebuild pass).
- Fixed Hunt Tracker achievement matching for criteria that do not expose a quest `assetID`, including `Prey: Chasing Death (Nightmare)`.
- Fixed grouped Hunt Tracker weeks being capped to 12 visible rows; the row pool now accommodates grouped headers plus all weekly hunts.
- Fixed stale warband prey-availability counts after weekly/server reset by keying fallback reset detection off Blizzard's server weekly reset timer and clearing HuntScanner availability caches during reconciliation before snapshots are refreshed.

### Added
- Added full `koKR` localization coverage from community contribution (issue #12), including settings tabs/sections, sound controls, hints, module labels, and tooltip strings.
- Added hunt-integrated achievement guidance in Hunt Tracker rows. Prey hunts now show an achievement signal badge when they advance tracked incomplete achievements, with optional `xN` count and mouseover names.
- Added Achievements tab options to control hunt-row achievement display (`Show Achievement Signals`, `Achievement Signal Style`, and `Show Achievement Names On Mouseover`).
- Added the Hunt Table display-style selector for achievement signals so the hunt list can be set to icon-only, text-only, or both from the Hunt Table tab.
- Added persistent earned-achievement caching for Hunt Tracker guidance. Once a tracked achievement is earned, it is stored in SavedVariables and skipped on future rebuilds because it cannot be earned twice.
- Added `Clear Achievement Cache` to the Defaults/Advanced maintenance section so achievement guidance cache can be reset without wiping all settings.

### Performance
- Added early `UPDATE_UI_WIDGET` relevance filtering in core event runtime so non-prey widget payloads short-circuit before noisy module fanout and prey-state refresh work.
- Added tracked prey widget ID state to improve relevance checks across differing widget update payload formats.
- Narrowed widget set ID scanning in `GetCandidateWidgetSetIDs` to query `GetPowerBarWidgetSetID` first (the known home of the prey hunt widget) and only fall back to the other three set IDs if the PowerBar set yields nothing. This reduces the number of protected secret-number values touched per widget scan cycle.
- Restored lean Hunt Tracker noisy-event gating so an active prey quest no longer keeps `QUEST_LOG_UPDATE` and widget listeners alive while the Hunt Table panel is closed.

### Cleanup
- Removed stale Bloody Command aura helpers/state from `Core/Alerts.lua` (`BLOODY_COMMAND_SPELL_IDS`, aura scan helpers/state) after chat-trigger validation.
- Removed stale `UNIT_AURA` prey-signal references/comments from `Core/EventRuntime.lua` and main event registration in `Preydator.lua`.
- Finalized EventRuntime stale-signal cleanup notes/comments for chat-owned alert routing.
- Added `UIWidgetTemplatePreyHuntProgressMixin.Setup` mixin hook (via `hooksecurefunc`) as the primary prey-icon suppression path. The hook fires after Blizzard's `AnimIn`/`ResetAnimState`/show sequence completes, targeting only the exact mixin type and eliminating the need to scan and manipulate arbitrary container frame globals for suppression.
- Added `Blizzard_UIWidgets` sub-addon readiness guard: `ADDON_LOADED` now watches for `Blizzard_UIWidgets` and triggers the mixin suppression hook and first icon-visibility pass only after widget APIs are confirmed present.

## 2.1.0 - 2026-03-23

### Changed
- Began core-architecture split by introducing a new `Core/` folder and moving shared runtime alert event handling there.
- Consolidated Ambush and Bloody Command event routing into one shared core alert file (`Core/Alerts.lua`) so both alert paths are maintained together.
- Added a dedicated bar runtime module (`Core/BarRuntime.lua`) and routed bar apply/update flows through it so bar display logic stays grouped in one maintenance location.
- Hardened core alert routing to honor module runtime state, so Ambush/Bloody processing now short-circuits when Bar/Sounds paths are disabled.
- Started settings-migration extraction by introducing `Core/SettingsRuntime.lua` and delegating normalization/migration paths from `Preydator.lua` with fallback-safe wrappers.
- Continued core extraction by introducing `Core/SoundsRuntime.lua` and delegating sound-option building, sound-path resolution, and playback helpers from `Preydator.lua` with fallback-safe wrappers.
- Continued core extraction by introducing `Core/PreyContextRuntime.lua` and delegating prey-zone status refresh, active-prey quest cache helpers, and quest-listen burst arming from `Preydator.lua` with fallback-safe wrappers.
- Continued monolith split by introducing `Modules/SlashCommands.lua` and delegating slash-command routing from `Preydator.lua` with fallback-safe wrappers.
- Reduced top-level local pressure in `Preydator.lua` by consolidating multiple runtime-module getter helpers into one generic `GetRuntimeModule()` path.
- Continued core extraction by introducing `Core/EventRuntime.lua` and delegating top-level event dispatch from `Preydator.lua` via a thin runtime bridge.
- Continued sound-runtime extraction by moving sound filename/path helper operations (`Normalize/Add/Remove`, addon path build/extract, and sound-key resolution) into `Core/SoundsRuntime.lua` and routing `Preydator.lua` through module wrappers.
- Continued prey-context extraction by moving prey-zone map lookup and player-map hierarchy checks into `Core/PreyContextRuntime.lua`, removing two more top-level helper locals from `Preydator.lua`.
- Continued local-pressure reduction by introducing `Core/DebugRuntime.lua` and moving memory/debug formatting helpers out of `Preydator.lua`.
- Continued local-pressure reduction by collapsing the disabled legacy inspect path in `Preydator.lua` to a compatibility stub and removing its dead helper locals.
- Continued local-pressure reduction by moving vertical-label formatting helpers into `Core/BarRuntime.lua` and removing three more top-level helper locals from `Preydator.lua`.
- Continued local-pressure reduction by moving ambush chat-matching helpers into `Core/Alerts.lua` and removing three more top-level helper locals from `Preydator.lua`.
- Continued local-pressure reduction by deleting the bar-point backup wrapper locals from `Preydator.lua` and calling `Core/SettingsRuntime.lua` directly at the remaining backup/restore sites.
- Continued local-pressure reduction by deleting five sound-management wrapper locals from `Preydator.lua` and routing the remaining UI/API sound option paths directly through `Core/SoundsRuntime.lua`.
- Continued local-pressure reduction by deleting the remaining top-level stage-sound resolver wrapper from `Preydator.lua` and routing all stage-sound resolution through `Preydator.API.ResolveStageSoundPath`.
- Continued local-pressure reduction by deleting the now-unreferenced legacy `PrintInspectState` compatibility stub from `Preydator.lua`.
- Continued local-pressure reduction by inlining prey-widget enum fallback lookups at call sites and removing two more tiny helper locals from `Preydator.lua`.
- Continued local-pressure reduction by inlining four BarRuntime context-only utility helpers (`stage fallback`, `tick percents`, `percent text layer`, `tick layer`) and removing their corresponding top-level locals from `Preydator.lua`.
- Continued local-pressure reduction by removing the top-level `IsEditModePreviewActive` helper and inlining its tiny frame-shown check at direct call sites and in BarRuntime context wiring.
- Continued local-pressure reduction by inlining default stage-sound path mapping at remaining use sites and removing the top-level `GetDefaultStageSoundPath` helper from `Preydator.lua`.
- Continued local-pressure reduction by inlining percent normalization/clamp logic at use sites and removing two more tiny top-level helpers from `Preydator.lua`.
- Continued local-pressure reduction by removing two unused Bloody Command helper leftovers (`BLOODY_COMMAND_SOURCE_NPC_IDS` and `ParseNPCIDFromGUID`) from `Core/Alerts.lua`.

### Added
- Added shared runtime-state API helper for core modules so Bar/Sounds module gating is derived from one source.
- Added dedicated Bloody Command alert options in the active Sounds page with separate sound/visual toggles and an independent sound picker/test button. Detection watches Astalor Bloodsworn Bloody Command aura applications on the player and reuses the transient bar alert path without changing prey-stage mappings.

### Fixed
- Fixed `ADDON_ACTION_FORBIDDEN` on `Frame:RegisterEvent()` by registering core events once at startup instead of re-registering inside runtime initialization.
- Hardened legacy `forceShowBar` migration by explicitly writing `false` on load, so users with stale persisted `true` values are guaranteed to recover without manual SavedVariables edits.
- Fixed old persisted debug `forceShowBar` state keeping the prey bar visible everywhere with `Only show in prey zone` enabled and no active prey quest. Force-show is now session-only and stale saved values are cleared on load.
- Restored the `Progress Segments` (`Thirds` / `Quarters`) dropdown to the active `Bar` settings tab.
- Restricted Bloody Command alert firing to Nightmare prey difficulty and stage > 1 (stage 4 remains valid), matching intended behavior against non-qualifying prey contexts.

## 2.0.8 - 2026-03-22

### Fixed
- Fixed non-Latin glyph rendering on `ruRU`/`koKR`/`zhCN`/`zhTW` by forcing locale-safe font fallback (`STANDARD_TEXT_FONT`) for bar labels, Currency/Warband windows, and Hunt panel text when selected decorative fonts lack required character support.

## 2.0.7 - 2026-03-22

### Fixed
- Restored addon version metadata in debug inspect module headers. `/pd inspect` and `/pd inspectquest` now include `addon=x.y.z` in their first line again.
- Fixed Warband panel realm-row overlap when collapsing realms with long names (including spaces/hyphens) by forcing single-line row-cell text in the table layout.
- Removed `Subtotal` text from grouped realm rows in Warband and rebalanced table column sizing to prioritize the realm-name column so more full realm names stay visible.
- Hardened default prey-icon widget suppression against Blizzard tooltip/widget taint by narrowing suppression scope to direct prey widget frames and safeguarding widget-set ID reads.
- Hardened core world-map value handling to fail closed on protected/tainted API payloads (map IDs, map info, quest-map positions, and waypoint creation), preventing unsafe values from propagating into Blizzard map/widget paths.
- Extended fail-closed map/world-quest guards into `DebugInspect` and `HuntScanner` (protected `GetBestMapForUnit`, `GetMapInfo`, `GetQuestZoneID`, and `GetMapInfoAtPosition` reads) so secret-number payloads are safely ignored instead of cascading into Blizzard widget/layout code.
- Finalized a defensive quest-inspect pass by guarding remaining quest-log detail reads (`IsOnQuest`, `IsQuestFlaggedCompleted`, `GetInfo`, `GetQuestTagInfo`, `GetQuestObjectives`) with protected calls to prevent secret values from tripping inspect/report formatting.

## 2.0.6 - 2026-03-21

### Fixed
- Fixed Hunt Table module disable wiring so HuntScanner now honors module state at runtime. When the Hunt module is disabled, HuntScanner now hard-stops noisy event subscriptions, snapshot queueing, refresh/cache passes, and panel rendering instead of continuing to process hunt events through the separate scanner event frame.
- Fixed Bar/Sounds independence in active polling gates. Core polling now remains available for sound-driven prey stage updates when Sounds is enabled, even if Bar is disabled; polling is forced off only when both Bar and sound runtime are disabled.

## 2.0.5 - 2026-03-21

### Performance
- Ported core prey polling to V2-style stage gating: `OnUpdate` is now enabled only while hot prey context exists (quest bootstrap, kill-carry window, ambush alert window, quest-listen burst, edit-mode preview, force-show, or active in-zone prey tracking) and is detached when idle.
- Reduced idle event overhead by making noisy prey-context checks lazy in `Preydator.lua` so non-widget events do not perform unnecessary quest-cache/time probes.
- Reduced Hunt Table event overhead by memoizing per-event hunt-context evaluation in `HuntScanner` so expensive context checks are only computed when a branch needs them.

### Fixed
- Fixed Warband totals row changing when collapsing a realm group. Grand totals now always sum from the filtered character source rows (all shown characters) rather than from post-collapse display rows, so collapse/expand only affects visibility and not totals.
- Fixed Lock/Unlock Bar behavior so toggling lock state from settings immediately refreshes bar interaction state (mouse/drag) without waiting for a later display update.
- Fixed Profiles tab actions by wiring a full profile runtime API (switch/create/delete/reset/copy) to live settings state.

### Changed
- Moved profile management out of `Preydator.lua` monolith into dedicated module `Modules/ProfileManager.lua`, and wired profile loading at addon startup through the new profile system.
- Simplified Profiles page settings logic to rely on module-backed profile APIs directly (removed legacy unavailable-API fallback scaffolding).

## 2.0.4 - 2026-03-20

### Fixed
- Fixed `attempt to compare a secret number value (tainted by 'Preydator')` crash in `LayoutFrame.lua` triggered when hovering AreaPOI tooltips on the world map while a prey quest was active. Root cause: `C_UIWidgetManager.GetAllWidgetsBySetID()` was called with secret-number set IDs returned by `GetTopCenterWidgetSetID()`, `GetObjectiveTrackerWidgetSetID()`, etc., tainting the returned widget table fields (`widgetType`, `widgetID`). Those tainted values then propagated into Blizzard's `DefaultWidgetLayout` comparison in `LayoutFrame.lua`. Fixed by wrapping all three `GetAllWidgetsBySetID` call sites and `widget.widgetType`/`widget.widgetID` field reads in `pcall`, and coercing `widgetID` through `tonumber()` before passing it back to any Blizzard API.
- Fixed locale difficulty detection in Hunt Table parsing so non-English clients no longer collapse hunts into Normal. `ParseDifficulty` now checks localized difficulty strings (`L["Normal"]`, `L["Hard"]`, `L["Nightmare"]`) in addition to English substrings while still returning canonical internal keys (`normal`/`hard`/`nightmare`) for stable sorting and caching. Added locale entries across non-enUS files (with AI-translation notes for native-speaker verification) and confirmed deDE mappings (`Schwer`, `Alptraum`). (Credit: gz2k2)

## 2.0.3 - 2026-03-20

### Changed
- `/pd inspect` output now includes the addon version number (`addon=x.y.z`) alongside the inspect schema version, making it immediately clear from a screenshot whether a player is on the latest release.
- Sound dropdowns now include a `None` option for each stage and Ambush so players can mute specific alerts directly from settings without disabling all sounds. (Credit: SirNorek)

### Fixed
- Dropdown popup menus now scale correctly on 4K / high-DPI monitors. `UIDropDownMenuTemplate` popup lists (`DropDownList1`) are parented to UIParent and do not automatically inherit the effective scale of the Settings panel; on 4K where UI scale is low (≈0.64), popups appeared too small and misaligned. Fixed by hooking `ToggleDropDownMenu` to normalize dropdown list scale to the effective scale ratio of the opening frame on every open event. (Credit: npi6666)
- HuntScanner reward probing now avoids raw arithmetic/coercion on protected Blizzard quest reward values, preventing `MoneyFrame_Update` secret-number taint when hovering world-map quest rewards.
- Core/Currency/Debug inspect paths now use protected numeric/string coercion for Blizzard API payload fields to reduce secret-value taint spillover outside HuntScanner-specific reward probes.
- Fixed a core dropdown localization regression (`attempt to index global 'L'`) by routing the `None` sound option label through `_G.PreydatorL` in `Preydator.lua`.
- Hardened bar position persistence so backup coordinates are only synced on explicit position changes (drag/save/reset), preventing generic apply/refresh paths from rewriting cached coordinates and causing post-reset/reload jumps.
- Backup restore now only repairs missing/invalid bar point data and no longer overwrites valid saved coordinates during load.
- Bar position clamping during login/world-enter no longer modifies saved coordinates; clamp is applied only to the live frame placement, preventing login-time screen metrics from reducing valid saved Y coordinates (e.g., 472 → 362). Position reapplies on `PLAYER_ENTERING_WORLD` to settle final UI dimensions.
- Panels tab spacing was increased in Currency/Warband sections to remove tight stacking/overlap, including a targeted +8px downward offset for `Show Quest Reward Icons`.

## 2.0.2 - 2026-03-20

### Fixed
- Bar drag position now persists reliably across reloads. Added resilient backup sync for saved bar coordinates and load-time restoration so position no longer snaps back to default `y=472` after moving.
- Corrected bar position restore order on load so backup coordinates are restored before normalization and not overwritten during startup.
- **Critical:** Bar visibility broken for non-enUS clients due to localization-dependent difficulty keys in hunted rewards and counts caching.
  - Root cause: `ParseDifficulty` was returning localized strings (`L["Normal"]`, `L["Hard"]`, `L["Nightmare"]`) which were then used as dictionary keys in persisted `difficultyRewardCache`, `questDifficultyByID`, and snapshot `mapDifficultyCounts`.
  - When players switched client locales or used addon with different locale clients, cached data keys became invalid because localization strings differ by language (enUS `"Normal"` vs deDE varies, etc.).
  - Solution: Changed `ParseDifficulty` to return canonical non-localized names (`"normal"`, `"hard"`, `"nightmare"`) for all internal data structures;  added `GetDifficultyDisplayName()` for UI display purposes; implemented `MigrateDifficultyKeysFromLocalizedToCanonical()` to convert existing persisted data on load.
  - Data flow now: WoW API → `ParseDifficulty` (canonical) → stored/cached (canonical) → migrated on load (canonical old → canonical new) → `GetDifficultyDisplayName` for UI display (localized labels).
- HuntScanner no longer queues or processes hunt-table snapshot work while the player is inside restricted instance content (`party`, `raid`, `scenario`, `delve`, `pvp`, `arena`).
- Ambush chat scanning now requires a fresh live prey quest match and refreshes zone state before evaluating prey-zone ambush logic, preventing stale prey state from firing inside delves or after prey context has ended.
- Hunt Table difficulty sorting now uses canonical difficulty rank instead of alphabetic string order, so ordering is consistently `N/H/Ni` (least to most) rather than locale/text-dependent variants.
- Currency and Warband windows now use stronger opacity and explicit frame layering so overlap does not visually blend the two panels into one block.

### Changed
- Ambush sound alerts now use a 45-second cooldown between plays to prevent rapid repeat firing from clustered ambush chat events.
- Stage-4 click navigation now prefers super-tracking the active prey quest (default-icon style behavior) and only falls back to user map waypoint pinning when quest super-track APIs are unavailable.
- Bar defaults updated: default position now uses `x=0` and `y=472`, and the bar is locked by default again.
- Hunt Table group headers now order difficulty groups hardest-first (`Nightmare > Hard > Normal`) when grouped by difficulty.
- Edit Mode window now anchors to the right side of Blizzard HUD Edit Mode with the same offset values.

### Fixed
- Warband Prey Track (`N/H/Ni`) now uses account-shared availability propagation with level gating, so updates captured on one character are reflected across all characters.
- Weekly reset fallback now reinitializes prey availability correctly by level: `78-89 => 4/-/-`, `90+ => 4/4/-` (or `4/4/4` once Nightmare has been permanently unlocked on the account).
- Added permanent saved unlock behavior for Nightmare in currency DB fallback logic; once unlocked, post-reset level-90 snapshots keep Nightmare availability enabled.

### Changed
- Corrected the fallback Warband prey model so live availability remains per-character, while only Nightmare unlock is shared account-wide.

## 2.0.1 - 2026-03-20

### Changed
- Module inspect output now includes instance/map diagnostics (`inInstance`, `instanceType`, `playerMapType`) and prey-zone cache diagnostics (`preyZoneMapID`, `preyZoneName`, `zoneCacheDirty`) for easier screenshot-based troubleshooting.
- Module inspect output removed the center-dot diagnostic row to keep reports focused on live visibility/state issues.
- Shared slider helpers were centralized in `Preydator.API` (`Clamp`, `RoundToStep`, `NormalizeSliderValue`) and consumed by `Settings` and `EditMode` to reduce helper drift.

### Fixed
- `Only show in prey zone` visibility now correctly hides the bar whenever `inPreyZone == false`, including fallback paths where a prey zone map ID is unavailable.
- Delve/instance bar gating was hardened with a restricted-instance check plus dungeon map-type fallback, preventing bar visibility in restricted instance content while preserving Edit Mode preview.
- Zone transition recovery was improved to prevent stale out-of-zone state after Delve exit:
  - registered `PLAYER_ENTERING_WORLD` for zone cache invalidation,
  - added periodic retry refresh while `inPreyZone == false`,
  - forced hierarchy rebuild on stale retry checks.
- HuntScanner snapshot/caching paths were hardened against protected Blizzard values by switching quest-ID numeric coercion to safe conversion helpers.

### Cleanup
- Removed unused `CurrencyTracker` local `OpenColorPicker` helper.
- Removed stale `HuntScanner` compatibility branch referencing `ZoneGateV2` (non-present module path in this repo).

## 2.0.0 - 2026-03-19

- Added module-aware settings gating across top-strip controls, Sounds page, Panels page sections, Currency matrix controls, and Theme controls.
- Added quest-focused inspect diagnostics (`/pd inspectquest`, `/pd inspectquestbug`, `/pd inspectquestboth`) with BugSack-compatible payload output.
### Changed
- Updated one-time splash/version gate to `2.0.0` and refreshed release messaging.
### Fixed
- Bar module gating now correctly preserves disabled state (removed false-to-true coercion paths) and enforces disabled behavior at runtime.
- Sounds module disable now blocks stage/ambush playback at core sound entry path (`TryPlaySound`).
- Currency and Warband module disable now force-close windows, prevent reopen toggles, and stop live refresh/update paths when disabled.
- Zone detection fallback for prey quests now uses quest log `isOnMap` when task-zone map IDs are unavailable.

### Performance
- Reduced unnecessary prey zone recomputation by caching zone status and refreshing only on relevant zone/quest transitions.
- Kept module-disabled refresh routes short-circuited to avoid avoidable UI and currency update work.

## 1.7.4 - 2026-03-19

### Changed
- New installs now default to an unlocked Preydator bar (`locked = false`) for easier first-time positioning.
- Added inspect shorthand support: `/pd inspect bs` now routes inspect output to BugSack mode.

### Fixed
- Fixed multiple runtime regressions from stale bar/options references after internal UI state refactor (`barFrame`/`barFill`/options category references), resolving repeated nil-index errors in live updates and settings refresh flows.
- Fixed Advanced settings reset actions to target live anchor settings:
  - `Reset Bar Position` now resets `point` anchor/x/y.
  - `Reset Tracker Positions` now resets tracker point tables and hunt panel side/anchor settings.

### Performance
- Reduced idle CPU churn by tightening prey update/event gates:
  - Removed redundant CurrencyTracker quest-log polling path and kept currency refresh event-driven.
  - Suppressed noisy widget/module fanout when there is no prey context.
  - Added strict ambush scan gating to active prey + in-zone + pre-stage-4 only.
  - Added out-of-zone fast-path handling to skip expensive widget/objective scans while a prey quest is active but player is outside prey zone.
  - Added one-attempt stage sound guard to prevent repeated failed stage-4 sound retry loops after reload.

## 1.7.3 - 2026-03-15

### Fixed
- Fixed a CurrencyTracker Lua scoping regression where `ToggleWarbandWindow()` could call `EnsureWarbandWindow` before its local function declaration was in scope, causing `attempt to call global 'EnsureWarbandWindow' (a nil value)` when opening Warband from settings.
- Fixed HuntScanner callback spam outside real Hunt Table usage by tightening context detection, cancelling queued follow-up passes when the panel closes, and ignoring passive widget/quest churn unless Hunt Table context, mission frame, or explicit preview is active.
- Fixed HuntScanner reward-cache invalidation flow by moving prey-completion cache clearing to an explicit hook from `Preydator.lua`, so accepted prey quests no longer rely on broad background scan churn to clear stale hunt rewards.
- Hardened HuntDebug snapshot/report formatting against protected Blizzard strings so debug payload generation no longer trips secret-string conversion failures in restricted contexts.

## 1.7.2 - 2026-03-15

### Changed
- Removed dead gossip-path code from HuntScanner: `GatherGossipQuests`, `IsLikelyPreyTitle`, all legacy gossip/quest-greeting API locals, and the gossip-based fallback rows in `BuildQuestRows`. Hunt data is sourced exclusively from adventure map pins; gossip scanning was a holdover from earlier implementation attempts and called taint-prone secure APIs on every scan pass.
- `IsHuntTableContext` now only checks target NPC ID, interaction type 3, and the Hunt Table controller spell ID option — no gossip quest title scanning.
- Removed `QUEST_ACCEPTED` event registration from HuntScanner (unused after pin-based system).

## 1.7.1 - 2026-03-15

### Fixed
- HuntScanner no longer fires gossip/quest scan passes inside battlegrounds, arenas, dungeons, raids, or delves, eliminating repeated "snapshot error: attempt to perform string conversion on a secret string value" spam caused by Blizzard taint in restricted instances.

## 1.7.0 - 2026-03-15

### Added
- Added an alt-aware prey progress chart in Currency settings (`Prey Track (Alts)`) showing character, zone, and rank snapshot data.
- Added prey snapshot persistence per character to SavedVariables so alt progress remains visible between sessions and reloads.
- Added a Hunt Table companion panel that appears during hunt-table interactions and lists available prey quests with reward summaries while preserving Blizzard's default quest/model panel.
- Added General-tab controls for Hunt Table tracking and side placement (`Left` / `Right`).
- Added dedicated `Hunt Table` and `Warband` settings tabs to begin separating hunt and warband controls from broad general settings.
- Added troubleshooting slash command `/pd huntdebug` to print captured hunt-table payload details (available quests, active quests, options, NPC/spell context).
- Expanded Hunt Table diagnostics to capture modern interaction-manager and quest-detail API paths, plus recent event traces, to support non-gossip hunt-table flows.
- Hunt Table capture now supports observed alternate NPC context (`246231`) and performs short delayed re-scan passes after interaction events to catch fast-populated quest payloads before UI close.

### Changed
- Mapped the new alt prey progress tracking work into the roadmap Epic 3 direction (weekly/prey progress visibility).
- Hunt Table tracker now uses Blizzard Adventure Map quest pins as the primary hunt source and warms per-quest reward data asynchronously from the quest-choice dialog, with retry-safe timeouts for empty payloads.
- Hunt reward warming now samples one representative quest per difficulty (plus active quests) to reduce visible quest-choice dialog flicker during cache warm-up.
- Hunt reward lines now include reward icons and normalize numeric experience rewards to include `XP` text.
- `/pd huntdebug bs` now uses BugGrabber APIs directly when available and no longer routes through error-handler paths that attach large local-variable dumps.
- Improved `/pd huntdebug bs` compatibility by trying multiple BugGrabber/BugSack call styles and auto-opening BugSack when a payload is delivered.
- Hunt panel quest rows are now clickable and open the corresponding Blizzard quest dialog on the adventure map.
- Hunt reward cache now persists in SavedVariables, refreshes on the first login of each day by invalidating stale entries, and reuses shared difficulty rewards when quests return after abandon.
- Completing prey stage 4 now invalidates cached rewards for that difficulty so the next Hunt Table visit refills updated rewards.
- Hunt Table actions are blocked while a prey quest is active, and row-level `Accept` now uses a hidden non-zoom dialog flow to avoid leaving the adventure map stuck on a zone zoom.
- Reward hydration now waits for fuller quest-choice reward widget population before committing cache, preventing premature XP-only snapshots; reward icon extraction also supports additional widget field variants.
- Advanced Debug now includes a `Refresh Hunt Cache` action, and Hunt settings includes direct cache/table refresh controls wired to `HuntScanner` refresh APIs.
- Hunt reward extraction now falls back to item-based fields (`itemID` / `itemLink`) for name/icon/count resolution, improving capture of chest/cache rewards that omit direct reward text fields.
- Currency settings have been decoupled from Warband controls: Warband toggles/grouping/layout controls no longer live on the Currencies page.
- Warband now has a dedicated option to show/hide `Prey Track (Alts)` directly inside the Warband window instead of the Currencies tab.
- Hunt Table warm-up now samples one representative quest per difficulty again, and Hunt settings now include grouping/sorting controls (`Group Hunts By`, `Sort Hunts By`) for zone/difficulty/title organization.
- Fixed HuntScanner reward API errors by passing the required `isChoice` argument to `C_QuestLog.GetQuestRewardCurrencyInfo`, eliminating repeated snapshot error spam.
- Clicking an already-open Hunt Table quest row now closes the quest details and attempts to reset zoom, improving map navigation UX.
- Hunt panel now supports settings for width, height, scale, font size, and side-anchor vertical alignment (`Top`, `Middle`, `Bottom`).
- Hunt grouped headers (zone/difficulty) are now collapsible directly from the Hunt panel.
- Warband tab now uses an open/close button flow, removes the link shortcut to Currencies, and includes tracked-currency toggles.
- Warband prey rows now show an `N/H/Ni` column with mode toggle (`available` or `completed`) and keep rank visible in a dedicated column.
- Hunt Table preview can now be shown directly from Options, with independent Hunt theme selection and cleaner grouped row titles that no longer append difficulty/zone suffixes.
- Hunt grouping now buckets by group first and sorts within each group, preventing duplicate zone/difficulty headers when sort order changes.
- Warband runtime now honors its own tracked-currency list and theme settings, and grouped character rows fill the `N/H/Ni` column instead of adding separate prey rows.
- Hunt availability counts now preserve cached values at login and update automatically on first Hunt Table interaction, removing the need to manually click the table before Warband difficulty tracking refreshes.
- Hunt Table defaults for new installs are now `Match Currency Theme = On`, `Group Hunts By = Difficulty`, and `Sort Hunts By = Zone`.
- Removed the Hunt Table bottom debug helper text from the live panel for a cleaner in-game presentation.
- Updated one-time splash content and release metadata for `1.7.0` (TOC, build script default version, and What's New version gate).

### Fixed
- Prevented prey availability snapshots from being overwritten with nil scanner values during early login refresh timing, so cached N/H/Ni values remain visible until live hunt data arrives.
- Kept localization bootstrap/fallback flow release-safe for ship builds while updating the splash body/title copy used in `1.7.0`.

## 1.6.5 - 2026-03-14

### Fixed
- Restored semantic localization fallback text assignments so settings hints and currency splash body no longer display raw keys (`HINT_PANEL_SUBTITLE`, `HINT_VERTICAL_PERCENT_OFFSET`, `HINT_VERTICAL_LOCK`, `HINT_AUDIO_SLIDER`, `HINT_ADVANCED_NOTES`, `WHATS_NEW_BODY`).
- Reworked fallback minimap button behavior for clients without icon managers:
  - corrected full-circle drag math using quadrant-safe angle handling;
  - restored proper icon asset source (`media/Preydator_64.png` from project asset copy);
  - stabilized Blizzard-style circular button presentation.

## 1.6.4 - 2026-03-14

### Fixed
- Removed `local L` alias from `Preydator.lua` main chunk to stay under Lua's hard 200-local-variable limit. Locale lookups now reference `_G.PreydatorL` directly inline. This also resolves the cascading `RegisterModule` nil errors in `Settings.lua`, `EditMode.lua`, and `CurrencyTracker.lua` that occurred because `Preydator.lua` was aborting before `_G.Preydator` was created.

## 1.6.3 - 2026-03-14

### Added
- Localization infrastructure: `Locales/Locales.lua` creates the `PreydatorL` global with a metatable fallback so untranslated keys safely return the key itself.
- `Locales/enUS.lua` — full translator reference guide documenting every key, format-string pattern, and semantic hint key.
- Stub locale files for deDE, frFR, esES, esMX, ptBR, itIT, ruRU, koKR, zhCN, zhTW — ready for community translation.

### Changed
- All UI strings in `Preydator.lua`, `Settings.lua`, `CurrencyTracker.lua`, and `EditMode.lua` routed through `L["key"]` lookup.
- TOC updated to version 1.6.3; all 12 locale files load before `Preydator.lua`.

### Fixed
- Ambush detection double-trigger: removed English `"ambush"` string check from `IsAmbushSystemMessage`; detection now relies solely on prey name matching, eliminating the duplicate sound that fired from both `CHAT_MSG_SYSTEM` and `CHAT_MSG_MONSTER_SAY`.

## 1.6.0 - 2026-03-14

### Added
- New Currency Tracker system for approved Prey currencies (`3392`, `3316`, `3383`, `3341`, `3343`).
- New Warband currency window with sortable columns and optional realm grouping/subtotals.
- New currency-focused options page controls for tracked IDs, random hunt cost context, gain/spend delta colors, and layout controls.
- New one-time "What's New" splash for the currency feature rollout.
- New Advanced-tab action button: `Show What's New`.

### Changed
- Currency and Warband windows now default to OFF for fresh installs.
- Currency theme naming cleaned up (`Light` instead of `Light (Tan)`).
- Currency options panel streamlined to keep core controls in one place, including a local theme selector.
- Release metadata updated for `1.6.0`.

### Fixed
- Light theme readability improved for text/title contrast.
- Currency window now expands and contracts correctly with tracked-row count.
- Warband table columns remain inside window bounds and auto-fit tracked currency columns.
- Warband sizing now grows and contracts with content demand without forcing manual slider correction.

## 1.5.5 - 2026-03-13

### Added
- Expanded vertical bar setup in Display settings with dedicated controls for orientation, fill direction, vertical scale, text side/alignment, and vertical percent behavior.
- Added vertical tick-percent workflow so percent labels can be shown at tick marks and replace the single vertical percent text when enabled.

### Changed
- Repurposed Display tab control from `Tick Mark Layer` to `Text Display` (`Above Bar` / `Below Bar`) for prefix/suffix stage name placement.
- `Vertical Percent Side` is now focused on tick-mark behavior (`Vertical Percent Tick Mark`) and no longer drives single percent placement logic.
- `Above Ticks` percent mode now renders tick-mark percentages above the bar instead of showing one top-aligned percent value.
- Tick mark rendering now stays above fill by default for consistent readability.

### Fixed
- Corrected a Lua syntax regression in display settings normalization caused by an incomplete conditional branch (`Missed symbol 'then'`).

## 1.5.1 - 2026-03-13

### Added
- New label modes for combined output on one side: `Left (Prefix + Suffix)` and `Right (Prefix + Suffix)`.
- New percent display modes: `Above Bar` and `Above Ticks`.
- New text layout control: `Prefix/Suffix Row` with `Above Bar` or `Below Bar` placement.
- New orientation controls in Display settings: `Bar Orientation` (`Horizontal` or `Vertical`) and `Vertical Fill Direction` (`Fill Up` or `Fill Down`).

### Changed
- Text tab right column is now aligned with left-column prefix/suffix sections for a more symmetrical layout.
- Vertical orientation now supports vertical prefix/suffix rendering while percent text remains horizontal.

### Notes
- Vertical mode is implemented as a practical beta-style option due Blizzard UI constraints around true font rotation; labels are rendered in stacked vertical text.

## 1.5.0 - 2026-03-13

### Added
- New settings checkbox: **Show in Edit Mode preview** so the Preydator bar remains visible while Blizzard Edit Mode is open.
- New setting: **Tick Mark Layer** with `Above Fill` or `Below Fill` modes.
- Expanded **Percent Display** modes with explicit in-bar layering: `In Bar (Above Fill)` and `In Bar (Below Fill)`.
- New modular **tabbed settings UI** that replaces the old single long-form options layout.
- New compact **Edit Mode quick settings** window for common layout controls while Blizzard Edit Mode is open.
- Sliders now include a live value field that can also be typed into directly.
- **Label Mode** dropdown with centered, left-only, right-only, separate prefix/suffix, and no-text layouts.
- Prefix and suffix label support for all four stages, plus dedicated out-of-zone and ambush prefix fields.
- **Border Color** picker with optional link-to-fill behavior.
- **Tick Mark Color** picker in Display settings.
- Static spark line at the right edge of the fill bar for clearer fill-end visibility.

### Changed
- Layering behavior for in-bar percent text is now driven directly by the selected percent display mode.
- Options layout now stays within a strict two-column structure across tabs instead of expanding into an overlong stacked panel.
- Default bar size updated to match the preferred in-game look: **Width 160, Height 29, Scale 0.9**. Existing installs keep their saved values.
- Default **Progress Segments** changed from Quarters to **Thirds**. Existing installs keep their saved value.
- Fill bar and tick marks are inset inside the border so scaling, texture changes, and color changes do not bleed outside the frame.

### Compatibility
- Existing installs keep current saved values; new settings defaults are only applied when a key is missing in `PreydatorDB`.

### Note for users reporting "bar shows 25% at stage start"
This is expected behavior. Blizzard only exposes a stage number (1–4), not a true percent. Stage 1 = entered prey zone = 25% (or 33% in Thirds mode) is the first meaningful progress state the addon can report. Stage 4 = prey visible on map = 100%.

## 1.1.2 - 2026-03-06

### Changed
- Release polish pass for stage-4 prey encounter behavior and map-open fallback interactions.
- Core slash help now only lists user-facing commands.
- Encounter suppression gating tightened to active prey hunt flow only (`active quest` + `in zone` + `stage > 1`).

### Fixed
- Stage-4 bar click fallback no longer depends on waypoint availability; map opening proceeds even when quest coordinates are unavailable.
- Prevented duplicate map toggles from mouse down/up double execution in stage-4 fallback mode.
- Hardened widget suppression paths against restricted/forbidden table access and animation-group API misuse.

### Dev / Internal
- Debug inspect slash handling moved out of core command flow and delegated to optional modules.
- Added optional debug module: `Modules/DebugInspect.lua` (not loaded by default in `Preydator.toc`).

## 1.1.1 - 2026-03-06

### Added
- New settings checkbox: **Disable Default Prey Icon**.
- Stage 4 quick-navigation: click the default prey encounter icon to open the world map and set a waypoint for the active prey quest.
- Stage 4 fallback when icon is hidden: click the locked Preydator bar to open the world map and set prey quest waypoint.

### Fixed
- Resolved startup/runtime Lua error from calling `NormalizeSoundSettings` before local function initialization.
- Resolved a second ordering regression where `GetSoundPathForKey` could be called before local function initialization.
- Added explicit forward declarations for both helpers to prevent nil global-call failures during early settings normalization paths.
- Hardened ambush chat detection against tainted/secret chat strings to avoid `attempt to compare local 'message'` runtime errors.
- Disabled ambush chat scanning while in `party`, `raid`, `scenario`, or `delve` instances where Blizzard restricts actionable chat payloads.
- Disabled ambush chat scanning when no active prey quest is tracked.
- Improved default prey icon toggle behavior by scanning prey widget frame regions so icon hide/show applies more reliably across widget containers.
- Default prey encounter suppression now only applies during active prey hunt stages (in-zone or while progress data is active).

## 1.1.0 - 2026-03-05

### Added
- Ambush alert system updates: configurable ambush sound/visual toggles and custom ambush text override support.
- In-settings **Custom Sound Files** tools to add and remove entries without slash commands.
- Flexible custom sound input handling: accepts names without spaces, optional `.ogg`, and optional full addon sound path prefix.

### Changed
- Ambush sound default is now `predator-kill.ogg`.
- Sound failure warning text now points to the current custom file workflow.
- Debug logging now defaults to **off** at startup.

### Fixed
- Removal logic now handles legacy malformed custom sound entries more reliably (without enabling space-containing names).

## 1.0.2 - 2026-03-04

### Changed
- `Only show in prey zone` behavior now works as: unchecked = bar visible, checked = hide unless active prey is in-zone.
- Progress tick marks now show only `25`, `50`, and `75` (removed `0`).

## 1.0.1 - 2026-03-04

### Added
- New settings option: **Only show in prey zone** to hide the bar while you are outside the active prey zone.

### Changed
- Replaced **Show when no active prey** with **Only show in prey zone** for clearer visibility behavior.
- README now clarifies out-of-zone visibility behavior and the new zone-gated display option.

### Fixed
- `/preydator options` and `/pd options` now open the settings category using a valid numeric category ID in modern Settings API flows.
- Resolved Lua error: `bad argument #1 to 'OpenSettingsPanel'` caused by passing a string category name to `Settings.OpenToCategory`.

## 1.0.0 - 2026-03-03

### Added
- Full settings panel for bar visuals, fonts, colors, labels, and sound behavior.
- Stage sound test buttons directly in settings.
- `/pd inspect` diagnostics for live quest/widget/bar state.
- Full reset-to-defaults support from settings.

### Changed
- Stage model finalized to 4 hunt stages:
  1. Scent in the Wind
  2. Blood in the Shadows
  3. Echoes of the Kill
  4. Feast of the Fang
- Final stage display is locked to 100% for consistent end-stage feedback.
- Bar scaling behavior updated to resize around a stable center anchor.
- README refreshed for release usage and customization guidance.

### Fixed
- Color picker callback/session handling issues across multiple swatches.
- Reset workflow now refreshes controls and values correctly in the settings UI.
- Bar position persistence/lock behavior regressions during iterative tuning.

### Removed
- Redundant slash sound test commands (replaced by settings test buttons).
- Redundant slash reset command (replaced by settings reset controls).
- Nameplate texture preset from texture options.
