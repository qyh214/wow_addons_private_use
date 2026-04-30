# Aura Designer Indicator Pooling & Profile Switch Aura Fix

**Date:** 2026-03-27
**Status:** Draft
**Scope:** AuraDesigner/Indicators.lua, AuraDesigner/Engine.lua, Core.lua

## Problem Statement

Two bugs exist in the current aura system:

1. **Aura Designer icons block click-casting in combat.** AD indicator Apply functions (ApplyIcon, ApplySquare, ApplyBar) re-apply all frame properties on every UNIT_AURA event, including `SetFrameStrata()` and `SetFrameLevel()` which reset mouse propagation state. The propagation re-set is guarded by `InCombatLockdown()`, so during combat propagation is cleared but never restored. Regular buff icons don't have this problem because they're configured once at creation and the update path only touches texture/cooldown data.

2. **Switching profiles to Direct API aura mode shows no auras.** `FullProfileRefresh()` in Core.lua doesn't call `SetAuraSourceMode()` or `EnableDirectAuraMode()`, so the Direct API cache (`DF.BlizzardAuraCache`) is never populated for the new profile. Toggling Blizzard/Direct mode manually works because `SetAuraSourceMode()` calls `EnableDirectAuraMode()` which calls `DirectScanAllUnits()`.

## Design: Configure-Once Split

### Architecture

Split each indicator's Apply function into two phases:

- **Configure** — Sets all static, config-driven properties. Runs once when the indicator is first seen, and again only when AD settings change.
- **Update** — Sets only dynamic, aura-data-driven properties. Runs on every UNIT_AURA event.

### Version Stamp

A global config version counter tracks when AD settings change:

```
DF.adConfigVersion = 0
```

Each indicator frame stores its last-configured version:

```
icon.dfAD_configVersion = DF.adConfigVersion
```

The version is bumped in:
- `ForceRefreshAllFrames()` (settings change from GUI)
- `FullProfileRefresh()` (profile switch/import/reset)

The version is stored on the **indicator frame object** (e.g., `icon.dfAD_configVersion`), not on the indicator data table. This way a hidden/reused frame knows whether it was configured with stale settings when it next becomes active.

### Engine Dispatch (Engine.lua)

Current:
```
Engine:UpdateFrame(frame)
  -> Build activeIndicators[]
  -> BeginFrame(frame)
  -> Loop: Apply(frame, typeKey, config, auraData, defaults, key, priority)
  -> EndFrame(frame)
```

New:
```
Engine:UpdateFrame(frame)
  -> Build activeIndicators[]
  -> BeginFrame(frame)
  -> Loop:
       if indicator.dfAD_configVersion ~= DF.adConfigVersion then
           Configure(frame, typeKey, config, defaults, key, priority)
       end
       Update(frame, typeKey, config, auraData, defaults, key, priority)
  -> EndFrame(frame)
```

`Configure()` dispatches to `ConfigureIcon`/`ConfigureSquare`/`ConfigureBar`.
`Update()` dispatches to `UpdateIcon`/`UpdateSquare`/`UpdateBar`.

## Icons: Configure vs Update

### ConfigureIcon (static, config-driven)

- `SetSize`, `SetScale`, `SetAlpha` (dfBaseAlpha)
- `SetFrameLevel`, `SetFrameStrata` / `SafeSetFrameStrata`
- Border show/hide, thickness, inset
- Texture inset + texcoord setup
- Stack font, size, outline, anchor, color
- Duration font, size, outline, anchor, color-by-time flag
- Duration hide wrapper creation + reparenting of native cooldown text
- `hideIcon` mode (text-only: hide texture/border/swipe)
- Mouse propagation: `SetPropagateMouseMotion(true)`, `SetPropagateMouseClicks(true)`, `SetMouseClickEnabled(false)`
- Expiring animation frame creation (pulse frame, bounce anim, whole-alpha pulse)
- Store `dfAD_configVersion`

### UpdateIcon (dynamic, aura-data-driven)

- Position (`ClearAllPoints` + `SetPoint`) — in Update because layout groups compute dynamic offsets per-event
- Texture (`SafeSetTexture` from `auraData.icon` or `C_Spell.GetSpellTexture`)
- Desaturation (`SetDesaturated` for missing aura mode)
- Cooldown (`SafeSetCooldown`, show/hide swipe)
- Stack count text (via `C_UnitAuras.GetAuraApplicationDisplayCount`)
- Duration text visibility + initial color evaluation
- Duration hide-above alpha evaluation + ticker registration
- Expiring ticker registration (`RegisterExpiring` with auraInstanceID/duration/expirationTime)
- Expiring pulse/bounce/whole-alpha state evaluation
- `icon:Show()`

## Squares: Configure vs Update

### ConfigureSquare (static)

- Size, scale, alpha
- Frame level, frame strata
- Border show/hide, thickness
- Texture color (from `config.color`)
- Stack font, size, outline, anchor, color
- Duration font, size, outline, anchor, color-by-time flag
- Duration hide wrapper creation + reparenting
- `hideIcon` mode
- Mouse propagation: `SetPropagateMouseMotion(true)`, `SetPropagateMouseClicks(true)`, `SetMouseClickEnabled(false)`
- Expiring animation setup
- Store `dfAD_configVersion`

### UpdateSquare (dynamic)

- Position (`ClearAllPoints` + `SetPoint`) — dynamic for layout groups
- Cooldown (`SafeSetCooldown`)
- Stack count text
- Desaturation for missing aura
- Duration text visibility + color evaluation
- Duration hide-above alpha + ticker registration
- Expiring ticker registration + state evaluation
- `sq:Show()`

## Bars: Configure vs Update

### ConfigureBar (static)

- Size, orientation (`SetOrientation`), fill direction (`SetReverseFill`)
- StatusBar texture (`SetStatusBarTexture`), background color
- Border frame + backdrop
- Frame level, frame strata
- Color curve building (`C_CurveUtil.CreateColorCurve`) + storing on bar (`dfAD_colorCurve`)
- Color flags: `dfAD_barColorByTime`, `dfAD_fillR/G/B`, `dfAD_expiringEnabled`, `dfAD_expiringThreshold`
- Duration font, size, outline, anchor
- OnUpdate script assignment
- Mouse propagation: `SetMouseClickEnabled(false)`, `SetPropagateMouseClicks(true)`, `SetPropagateMouseMotion(true)`
- Store `dfAD_configVersion`

### UpdateBar (dynamic)

- Position (`ClearAllPoints` + `SetPoint`) — dynamic for layout groups
- `dfAD_auraInstanceID`, `dfAD_unit` assignment
- Fill via `SetTimerDuration` (secret-safe) or `SetValue` (preview fallback)
- Initial color curve evaluation + `SetStatusBarColor`
- Duration text + cooldown setup
- Duration hide-above alpha + ticker registration
- Expiring state evaluation
- `bar:Show()`

## Profile Switch Aura Fix (Core.lua)

### Location

In `FullProfileRefresh()`, after the existing `RebuildDirectFilterStrings()` call (~line 4846) but before `UpdateAllAuras()` (~line 4992).

### Implementation

```lua
-- Re-initialize aura source mode for the new profile
local partyMode = DF.db.party and DF.db.party.auraSourceMode
local raidMode = DF.db.raid and DF.db.raid.auraSourceMode
local needsDirect = (partyMode == "DIRECT") or (raidMode == "DIRECT")

if needsDirect then
    DF:EnableDirectAuraMode()   -- Sets directModeActive, rebuilds filters, scans all units
else
    DF:DisableDirectAuraMode()  -- Clears directModeActive, unregisters events
end
```

This mirrors the startup initialization path (Auras.lua:2342-2348) and the manual toggle path in `SetAuraSourceMode()`. It ensures the Direct API cache is populated or cleared to match the new profile before `UpdateAllAuras()` tries to render.

### Config version bump

`FullProfileRefresh()` should also bump `DF.adConfigVersion` so that all AD indicators reconfigure on the next `UpdateFrame()` call, picking up the new profile's AD settings.

## Files Modified

| File | Change |
|------|--------|
| `AuraDesigner/Indicators.lua` | Split ApplyIcon into ConfigureIcon + UpdateIcon. Split ApplySquare into ConfigureSquare + UpdateSquare. Split ApplyBar into ConfigureBar + UpdateBar. Add Configure/Update dispatch functions. Add mouse propagation to ConfigureSquare (currently missing entirely). Expand mouse propagation in ConfigureBar (currently only has SetMouseClickEnabled). |
| `AuraDesigner/Engine.lua` | Update dispatch loop to check configVersion and call Configure vs Update. Bump adConfigVersion in ForceRefreshAllFrames(). |
| `Core.lua` | Add EnableDirectAuraMode/DisableDirectAuraMode call in FullProfileRefresh(). Bump adConfigVersion in FullProfileRefresh(). |

## Performance Impact

The main hot path (UNIT_AURA during combat) will skip all static property calls. Rough estimate of work avoided per indicator per event:

- Icons: ~15 skipped calls (SetSize, SetScale, SetAlpha, ClearAllPoints, SetPoint, SetFrameLevel, SetFrameStrata, border setup, texture inset, font setup x2, propagation x3)
- Squares: ~12 skipped calls (similar minus some icon-specific work)
- Bars: ~18 skipped calls (orientation, texture, backdrop, color curve building, etc.)

In a raid with 20 frames each showing 3-4 AD indicators, this is 60-80 indicators x 15 skipped calls = 900-1200 fewer API calls per UNIT_AURA event.
