# AD Indicator Pooling & Profile Switch Aura Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split AD indicator Apply functions into Configure (once) + Update (per event) to fix combat click-through and improve performance, plus fix profile switching not initializing Direct API aura mode.

**Architecture:** Each indicator type (icon, square, bar) gets a ConfigureX function for static properties and an UpdateX function for dynamic aura data. A global version counter (`DF.adConfigVersion`) tracks config changes; indicators only reconfigure when their stored version is stale. Position stays in Update to support layout group dynamic offsets. Profile switch fix adds `EnableDirectAuraMode`/`DisableDirectAuraMode` call to `FullProfileRefresh`.

**Tech Stack:** Lua (WoW addon), WoW API (SecureGroupHeaderTemplate, C_UnitAuras)

---

### Task 1: Profile Switch Aura Fix (Core.lua)

**Files:**
- Modify: `Core.lua:4846-4994` (FullProfileRefresh, between RebuildDirectFilterStrings and UpdateAllAuras)

This is a standalone bugfix independent of the pooling refactor.

- [ ] **Step 1: Add aura source mode reinitialization to FullProfileRefresh**

In `Core.lua`, find the `RebuildDirectFilterStrings` call at ~line 4846-4848. Immediately after it, add the aura mode switch:

```lua
    -- Rebuild aura filter strings from the new profile's settings
    if DF.RebuildDirectFilterStrings then
        DF:RebuildDirectFilterStrings()
    end

    -- Re-initialize aura source mode for the new profile
    -- Without this, switching to a profile using Direct API shows no auras
    -- because the cache (DF.BlizzardAuraCache) is never populated
    if DF.EnableDirectAuraMode then
        local partyMode = DF.db.party and DF.db.party.auraSourceMode
        local raidMode = DF.db.raid and DF.db.raid.auraSourceMode
        local needsDirect = (partyMode == "DIRECT") or (raidMode == "DIRECT")
        if needsDirect then
            DF:EnableDirectAuraMode()
        elseif DF.DisableDirectAuraMode then
            DF:DisableDirectAuraMode()
        end
    end
```

- [ ] **Step 2: Test in-game**

1. Create two profiles: one using Blizzard aura mode, one using Direct API
2. Switch from Blizzard profile to Direct API profile
3. Verify auras appear immediately without needing to toggle modes manually
4. Switch back to Blizzard profile and verify auras still work
5. Test while in a party/raid with actual auras visible

- [ ] **Step 3: Commit**

```bash
git add Core.lua
git commit -m "Fix profile switch not initializing Direct API aura mode

FullProfileRefresh now calls EnableDirectAuraMode/DisableDirectAuraMode
based on the new profile's auraSourceMode setting. Previously the Direct
API cache was never populated when switching profiles, causing no auras
to appear until the user manually toggled the mode."
```

---

### Task 2: Add Config Version Counter (Engine.lua)

**Files:**
- Modify: `AuraDesigner/Engine.lua:921` (ForceRefreshAllFrames)

- [ ] **Step 1: Add version bump to ForceRefreshAllFrames**

At the top of `ForceRefreshAllFrames()` (line 921), add the version increment:

```lua
function Engine:ForceRefreshAllFrames()
    -- Bump config version so all indicators reconfigure on next UpdateFrame
    DF.adConfigVersion = (DF.adConfigVersion or 0) + 1

    local function TryUpdate(frame)
```

- [ ] **Step 2: Add version bump to FullProfileRefresh in Core.lua**

In `Core.lua`, in the same area where we added the aura mode fix (Task 1), add:

```lua
    -- Bump AD config version so indicators reconfigure with new profile settings
    DF.adConfigVersion = (DF.adConfigVersion or 0) + 1
```

Place this right before the `-- === REFRESH AURAS ===` comment at ~line 4992.

- [ ] **Step 3: Initialize the counter**

At the top of `Engine.lua`, near the module initialization (before any function definitions), add:

```lua
DF.adConfigVersion = 0
```

- [ ] **Step 4: Commit**

```bash
git add AuraDesigner/Engine.lua Core.lua
git commit -m "Add AD config version counter for configure-once pattern

DF.adConfigVersion is incremented in ForceRefreshAllFrames (GUI changes)
and FullProfileRefresh (profile switches). Indicators will use this to
skip redundant static property re-application on UNIT_AURA events."
```

---

### Task 3: Split ApplyIcon into ConfigureIcon + UpdateIcon

**Files:**
- Modify: `AuraDesigner/Indicators.lua:1303-1805` (GetOrCreateADIcon, ApplyIcon)

This is the largest task. The existing `ApplyIcon` (lines 1323-1805) gets split into two functions.

- [ ] **Step 1: Create ConfigureIcon function**

Add this new function right after `GetOrCreateADIcon` (after line 1321). This contains all the static, config-driven properties extracted from ApplyIcon:

```lua
-- ============================================================
-- CONFIGURE ICON (static, config-driven)
-- Called once when first seen and when AD settings change (adConfigVersion bump).
-- Sets size, position, strata, border, fonts, propagation, animation setup.
-- ============================================================
function Indicators:ConfigureIcon(frame, config, defaults, auraName, priority)
    local icon = GetOrCreateADIcon(frame, auraName)

    -- Size
    local size = config.size or (defaults and defaults.iconSize) or 24
    local scale = config.scale or (defaults and defaults.iconScale) or 1.0
    icon:SetSize(size, size)
    icon:SetScale(scale)

    -- Alpha
    local iconAlpha = config.alpha or 1.0
    icon.dfBaseAlpha = iconAlpha
    icon:SetAlpha(iconAlpha)

    -- Frame level: base from frame + per-indicator level + small priority tiebreaker
    local level = config.frameLevel or (defaults and defaults.indicatorFrameLevel) or 2
    local baseLevel = frame:GetFrameLevel()
    local priorityBoost = math.floor((20 - (priority or 5)) / 4)
    icon:SetFrameLevel(math.max(0, baseLevel + level + priorityBoost))

    -- Frame strata
    local strata = config.frameStrata or (defaults and defaults.indicatorFrameStrata) or "INHERIT"
    if strata ~= "INHERIT" then
        SafeSetFrameStrata(icon, frame, strata)
    else
        icon:SetFrameStrata(frame:GetFrameStrata())
    end

    -- Hide Icon (text-only mode)
    local hideIcon = config.hideIcon; if hideIcon == nil then hideIcon = defaults and defaults.hideIcon end

    -- Border
    local borderEnabled = config.borderEnabled
    if borderEnabled == nil then borderEnabled = true end
    local borderThickness = config.borderThickness or 1
    local borderInset = config.borderInset or 1

    if icon.border then
        if borderEnabled and not hideIcon then
            icon.border:ClearAllPoints()
            icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -borderInset, borderInset)
            icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", borderInset, -borderInset)
            icon.border:SetColorTexture(0, 0, 0, 0.8)
            icon.border:Show()
        else
            icon.border:Hide()
        end
    end

    -- Texture inset
    if icon.texture and not hideIcon then
        icon.texture:ClearAllPoints()
        local texInset = borderEnabled and borderThickness or 0
        icon.texture:SetPoint("TOPLEFT", texInset, -texInset)
        icon.texture:SetPoint("BOTTOMRIGHT", -texInset, texInset)
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    -- Stack font/style
    local stackFont = config.stackFont or (defaults and defaults.stackFont) or "Fonts\\FRIZQT__.TTF"
    local stackScale = config.stackScale or (defaults and defaults.stackScale) or 1.0
    local stackOutline = config.stackOutline or (defaults and defaults.stackOutline) or "OUTLINE"
    if stackOutline == "NONE" then stackOutline = "" end
    local stackAnchor = config.stackAnchor or (defaults and defaults.stackAnchor) or "BOTTOMRIGHT"
    local stackX = config.stackX; if stackX == nil then stackX = defaults and defaults.stackX end; if stackX == nil then stackX = 0 end
    local stackY = config.stackY; if stackY == nil then stackY = defaults and defaults.stackY end; if stackY == nil then stackY = 0 end

    if icon.count then
        local stackSize = 10 * stackScale
        DF:SafeSetFont(icon.count, stackFont, stackSize, stackOutline)
        icon.count:ClearAllPoints()
        icon.count:SetPoint(stackAnchor, icon, stackAnchor, stackX, stackY)
        local stackColor = config.stackColor or (defaults and defaults.stackColor)
        if stackColor then
            icon.count:SetTextColor(stackColor.r or 1, stackColor.g or 1, stackColor.b or 1, stackColor.a or 1)
        else
            icon.count:SetTextColor(1, 1, 1, 1)
        end
    end

    -- Duration font/style settings (stored on icon for UpdateIcon to use)
    local durationFont = config.durationFont or (defaults and defaults.durationFont) or "Fonts\\FRIZQT__.TTF"
    local durationScale = config.durationScale or (defaults and defaults.durationScale) or 1.0
    local durationOutline = config.durationOutline or (defaults and defaults.durationOutline) or "OUTLINE"
    if durationOutline == "NONE" then durationOutline = "" end
    local durationAnchor = config.durationAnchor or (defaults and defaults.durationAnchor) or "CENTER"
    local durationX = config.durationX; if durationX == nil then durationX = defaults and defaults.durationX end; if durationX == nil then durationX = 0 end
    local durationY = config.durationY; if durationY == nil then durationY = defaults and defaults.durationY end; if durationY == nil then durationY = 0 end

    -- Store config values on icon so UpdateIcon can use them without re-reading config
    icon.dfAD_durationFont = durationFont
    icon.dfAD_durationScale = durationScale
    icon.dfAD_durationOutline = durationOutline
    icon.dfAD_durationAnchor = durationAnchor
    icon.dfAD_durationX = durationX
    icon.dfAD_durationY = durationY
    icon.dfAD_hideIcon = hideIcon

    -- Duration color-by-time flag
    local durationColorByTime = config.durationColorByTime
    if durationColorByTime == nil then
        durationColorByTime = (defaults and defaults.durationColorByTime)
        if durationColorByTime == nil then durationColorByTime = true end
    end
    icon.dfAD_durationColorByTime = durationColorByTime

    -- Duration hide-above settings
    local durationHideAboveEnabled = config.durationHideAboveEnabled
    if durationHideAboveEnabled == nil then durationHideAboveEnabled = (defaults and defaults.durationHideAboveEnabled) or false end
    local durationHideAboveThreshold = config.durationHideAboveThreshold or (defaults and defaults.durationHideAboveThreshold) or 10
    icon.durationHideAboveEnabled = durationHideAboveEnabled
    icon.durationHideAboveThreshold = durationHideAboveThreshold

    -- Duration show flag
    local showDuration = config.showDuration
    if showDuration == nil then showDuration = true end
    icon.showDuration = showDuration
    icon.durationColorByTime = durationColorByTime
    icon.durationAnchor = durationAnchor
    icon.durationX = durationX
    icon.durationY = durationY

    -- Stacks show flag + minimum
    local showStacks = config.showStacks
    if showStacks == nil then showStacks = true end
    icon.dfAD_showStacks = showStacks
    local stackMin = config.stackMinimum or 2
    icon.stackMinimum = stackMin

    -- Duration hide wrapper creation + native text reparenting
    if not icon.nativeCooldownText and icon.cooldown then
        local regions = { icon.cooldown:GetRegions() }
        for _, region in pairs(regions) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                icon.nativeCooldownText = region
                icon.nativeTextReparented = false
                break
            end
        end
    end

    if icon.nativeCooldownText and showDuration then
        if not icon.durationHideWrapper and icon.textOverlay then
            icon.durationHideWrapper = CreateFrame("Frame", nil, icon.textOverlay)
            icon.durationHideWrapper:SetAllPoints(icon.textOverlay)
            icon.durationHideWrapper:SetFrameLevel(icon.textOverlay:GetFrameLevel())
            icon.durationHideWrapper:EnableMouse(false)
        end
        if not icon.nativeTextReparented and icon.durationHideWrapper then
            icon.nativeCooldownText:SetParent(icon.durationHideWrapper)
            icon.nativeTextReparented = true
        end
        -- Style
        local durationSize = 10 * durationScale
        DF:SafeSetFont(icon.nativeCooldownText, durationFont, durationSize, durationOutline)
        -- Position
        icon.nativeCooldownText:ClearAllPoints()
        icon.nativeCooldownText:SetPoint(durationAnchor, icon, durationAnchor, durationX, durationY)
    end

    icon.cooldown:SetHideCountdownNumbers(not showDuration)

    -- Expiring animation frame creation (lazy-create only, state set in UpdateIcon)
    local expiringPulsate = config.expiringPulsate or false
    if expiringPulsate and icon.border then
        if not icon.adBorderPulseFrame then
            icon.adBorderPulseFrame = CreateFrame("Frame", nil, icon)
            icon.adBorderPulseFrame:SetAllPoints(icon)
            icon.adBorderPulseFrame:SetFrameLevel(icon:GetFrameLevel())
            icon.adBorderPulseFrame:EnableMouse(false)
        end
        if not icon.adBorderReparented then
            icon.border:SetParent(icon.adBorderPulseFrame)
            icon.adBorderReparented = true
        end
        GetOrCreatePulseAnim(icon.adBorderPulseFrame)
        icon.adBorderPulseFrame.dfAD_expiringPulsate = true
    elseif icon.adBorderPulseFrame then
        icon.adBorderPulseFrame.dfAD_expiringPulsate = false
    end

    local expiringWholeAlphaPulse = config.expiringWholeAlphaPulse or false
    if expiringWholeAlphaPulse then GetOrCreateWholeAlphaPulse(icon) end
    icon.dfAD_expiringWholeAlphaPulse = expiringWholeAlphaPulse

    local expiringBounce = config.expiringBounce or false
    if expiringBounce then GetOrCreateBounceAnim(icon) end
    icon.dfAD_expiringBounce = expiringBounce

    -- Store expiring config for UpdateIcon
    icon.dfAD_expiringEnabled = config.expiringEnabled
    if icon.dfAD_expiringEnabled == nil then icon.dfAD_expiringEnabled = false end
    icon.dfAD_expiringColor = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
    icon.dfAD_expiringThreshold = config.expiringThreshold or 30
    icon.dfAD_expiringThresholdMode = config.expiringThresholdMode
    icon.dfAD_expiringPulsate = expiringPulsate

    -- Store missing-mode config
    icon.dfAD_missingDesaturate = config.missingDesaturate

    -- Mouse propagation — set once, never touched again
    -- These are protected in combat, but since Configure only runs outside combat
    -- (or at first creation which is also outside combat), this is safe.
    if icon.SetPropagateMouseMotion then
        icon:SetPropagateMouseMotion(true)
    end
    if icon.SetPropagateMouseClicks then
        icon:SetPropagateMouseClicks(true)
    end
    if icon.SetMouseClickEnabled then
        icon:SetMouseClickEnabled(false)
    end

    -- Mark as configured at current version
    icon.dfAD_configVersion = DF.adConfigVersion or 0
end
```

- [ ] **Step 2: Create UpdateIcon function**

Add this right after ConfigureIcon. This contains only dynamic, aura-data-driven properties:

```lua
-- ============================================================
-- UPDATE ICON (dynamic, aura-data-driven)
-- Called on every UNIT_AURA. Sets texture, cooldown, stacks, position,
-- expiring state. Assumes ConfigureIcon has already set static properties.
-- ============================================================
function Indicators:UpdateIcon(frame, config, auraData, defaults, auraName, priority)
    local state = EnsureFrameState(frame)
    state.activeIcons[auraName] = true

    local icon = GetOrCreateADIcon(frame, auraName)

    -- Store aura data for tooltip lookups
    if auraData then
        if not icon.auraData then
            icon.auraData = { auraInstanceID = nil }
        end
        icon.auraData.auraInstanceID = auraData.auraInstanceID
    end

    -- Position — must be in Update because layout groups compute dynamic offsets
    local anchor = config.anchor or "TOPLEFT"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or 0
    local borderEnabledForPos = config.borderEnabled
    if borderEnabledForPos == nil then borderEnabledForPos = true end
    offsetX, offsetY = AdjustOffsetForBorder(anchor, offsetX, offsetY, config.borderInset or 1, borderEnabledForPos)
    icon:ClearAllPoints()
    icon:SetPoint(anchor, frame, anchor, offsetX, offsetY)

    -- Texture
    local hideIcon = icon.dfAD_hideIcon
    if not hideIcon then
        if auraData.icon then
            SafeSetTexture(icon, auraData.icon)
        elseif auraData.spellId and C_Spell and C_Spell.GetSpellTexture then
            SafeSetTexture(icon, C_Spell.GetSpellTexture(auraData.spellId))
        end
        if icon.texture then icon.texture:Show() end
    else
        if icon.texture then icon.texture:Hide() end
    end

    -- Desaturation for Show When Missing mode
    if icon.texture then
        local desaturate = icon.dfAD_missingDesaturate and auraData.isMissingAura
        icon.texture:SetDesaturated(desaturate and true or false)
    end

    -- Cooldown
    local hideSwipe = config.hideSwipe; if hideSwipe == nil then hideSwipe = defaults and defaults.hideSwipe end
    local hasDuration = HasAuraDuration(auraData, frame.unit)
    if hasDuration then
        SafeSetCooldown(icon.cooldown, auraData, frame.unit)
        icon.cooldown:SetDrawSwipe(not hideSwipe and not hideIcon)
        icon.cooldown:Show()
    else
        icon.cooldown:SetDrawSwipe(false)
        icon.cooldown:Hide()
        if icon.nativeCooldownText then
            icon.nativeCooldownText:SetText("")
            icon.nativeCooldownText:Hide()
        end
    end

    -- Stack count
    if icon.count then
        icon.count:SetText("")
        icon.count:Hide()
        if icon.dfAD_showStacks then
            local unit = frame.unit
            local auraInstanceID = auraData.auraInstanceID
            if unit and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
                local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, icon.stackMinimum, 99)
                if stackText then
                    icon.count:SetText(stackText)
                    icon.count:Show()
                end
            elseif auraData.stacks then
                if not issecretvalue(auraData.stacks) and auraData.stacks >= icon.stackMinimum then
                    icon.count:SetText(auraData.stacks)
                    icon.count:Show()
                end
            end
        end
    end

    -- Duration text
    if icon.nativeCooldownText then
        if icon.showDuration then
            icon.nativeCooldownText:Show()

            -- Hide-above alpha evaluation
            local hideAlpha = 1
            if icon.durationHideAboveEnabled and hasDuration then
                local usedHideAPI = false
                if frame.unit and auraData.auraInstanceID
                   and C_UnitAuras and C_UnitAuras.GetAuraDuration then
                    local dObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
                    if dObj and dObj.EvaluateRemainingDuration then
                        local hideCurve = BuildDurationHideCurve(icon.durationHideAboveThreshold)
                        if hideCurve then
                            local hideResult = dObj:EvaluateRemainingDuration(hideCurve)
                            if hideResult then
                                hideAlpha = hideResult.a or (hideResult.GetAlpha and hideResult:GetAlpha()) or 1
                            end
                            usedHideAPI = true
                        end
                    end
                end
                if not usedHideAPI then
                    local exp = auraData.expirationTime
                    local dur = auraData.duration
                    if exp and dur and not issecretvalue(exp) and not issecretvalue(dur) and dur > 0 then
                        local remaining = max(0, exp - GetTime())
                        hideAlpha = remaining > icon.durationHideAboveThreshold and 0 or 1
                    end
                end
            end
            if icon.durationHideWrapper then
                icon.durationHideWrapper:SetAlpha(hideAlpha)
            end

            -- Color by remaining time
            if icon.dfAD_durationColorByTime and hasDuration then
                local usedAPI = false
                if frame.unit and auraData.auraInstanceID
                   and C_UnitAuras and C_UnitAuras.GetAuraDuration
                   and C_CurveUtil and C_CurveUtil.CreateColorCurve then
                    local durationObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
                    if durationObj and durationObj.EvaluateRemainingPercent then
                        if not DF.durationColorCurve then
                            DF.durationColorCurve = C_CurveUtil.CreateColorCurve()
                            DF.durationColorCurve:SetType(Enum.LuaCurveType.Linear)
                            DF.durationColorCurve:AddPoint(0, CreateColor(1, 0, 0, 1))
                            DF.durationColorCurve:AddPoint(0.3, CreateColor(1, 0.5, 0, 1))
                            DF.durationColorCurve:AddPoint(0.5, CreateColor(1, 1, 0, 1))
                            DF.durationColorCurve:AddPoint(1, CreateColor(0, 1, 0, 1))
                        end
                        local result = durationObj:EvaluateRemainingPercent(DF.durationColorCurve)
                        if result and result.r then
                            icon.nativeCooldownText:SetTextColor(result.r, result.g, result.b, 1)
                        end
                        usedAPI = true
                    end
                end
                if not usedAPI then
                    local exp = auraData.expirationTime
                    local dur = auraData.duration
                    if exp and dur and not issecretvalue(exp) and not issecretvalue(dur) and dur > 0 then
                        local remaining = exp - GetTime()
                        local pct = max(0, min(1, remaining / dur))
                        local r, g, b
                        if pct < 0.3 then
                            local t = pct / 0.3
                            r, g, b = 1, 0.5 * t, 0
                        elseif pct < 0.5 then
                            local t = (pct - 0.3) / 0.2
                            r, g, b = 1, 0.5 + 0.5 * t, 0
                        else
                            local t = (pct - 0.5) / 0.5
                            r, g, b = 1 - t, 1, 0
                        end
                        icon.nativeCooldownText:SetTextColor(r, g, b, 1)
                    end
                end
            else
                local durationColor = config.durationColor or (defaults and defaults.durationColor)
                if durationColor then
                    icon.nativeCooldownText:SetTextColor(durationColor.r or 1, durationColor.g or 1, durationColor.b or 1, 1)
                else
                    icon.nativeCooldownText:SetTextColor(1, 1, 1, 1)
                end
            end

            -- Duration hide-above ticker registration
            local savedHWNE = pendingHideWhenNotExpiring
            pendingHideWhenNotExpiring = false
            if icon.durationHideAboveEnabled and hasDuration and icon.durationHideWrapper then
                local hideCurve = BuildDurationHideCurve(icon.durationHideAboveThreshold)
                if hideCurve then
                    RegisterExpiring(icon.durationHideWrapper, {
                        unit = frame.unit,
                        auraInstanceID = auraData and auraData.auraInstanceID,
                        threshold = icon.durationHideAboveThreshold,
                        thresholdMode = "SECONDS",
                        duration = auraData and auraData.duration,
                        expirationTime = auraData and auraData.expirationTime,
                        colorCurve = hideCurve,
                        applyResult = function(el, result)
                            local a = result.a or (result.GetAlpha and result:GetAlpha()) or 1
                            el:SetAlpha(a)
                        end,
                        applyManual = function(el, isExp)
                            el:SetAlpha(isExp and 1 or 0)
                        end,
                    })
                end
            else
                if icon.durationHideWrapper then
                    UnregisterExpiring(icon.durationHideWrapper)
                    icon.durationHideWrapper:SetAlpha(1)
                end
            end
            pendingHideWhenNotExpiring = savedHWNE
        else
            icon.nativeCooldownText:Hide()
        end
    end

    -- Expiring ticker registration
    local anyExpiringFeature = icon.dfAD_expiringEnabled or icon.dfAD_expiringPulsate or icon.dfAD_expiringWholeAlphaPulse or icon.dfAD_expiringBounce
    if anyExpiringFeature then
        local ec = icon.dfAD_expiringColor
        local oc = {r = 0, g = 0, b = 0}
        local applyColor = icon.dfAD_expiringEnabled
        RegisterExpiring(icon, {
            unit = frame.unit,
            auraInstanceID = auraData and auraData.auraInstanceID,
            threshold = icon.dfAD_expiringThreshold,
            duration = auraData and auraData.duration,
            expirationTime = auraData and auraData.expirationTime,
            colorCurve = applyColor and BuildExpiringColorCurve(icon.dfAD_expiringThreshold, ec, oc, icon.dfAD_expiringThresholdMode) or nil,
            thresholdMode = icon.dfAD_expiringThresholdMode,
            color = ec, originalColor = oc,
            applyResult = function(el, result, entry)
                if el.border then
                    el.border:SetColorTexture(result.r, result.g, result.b, result.a or 1)
                end
                local oc2 = entry.originalColor
                local isExp = IsColorExpiring(result, oc2)
                if el.adBorderPulseFrame then
                    UpdatePulseState(el.adBorderPulseFrame, isExp)
                end
                UpdateWholeAlphaPulseState(el, isExp)
                UpdateBounceState(el, isExp)
            end,
            applyManual = function(el, isExp, entry)
                if applyColor and el.border then
                    if isExp then
                        local c = entry.color
                        el.border:SetColorTexture(c.r or 1, c.g or 0.2, c.b or 0.2, 1)
                    else
                        el.border:SetColorTexture(0, 0, 0, 0.8)
                    end
                end
                if el.adBorderPulseFrame then
                    UpdatePulseState(el.adBorderPulseFrame, isExp)
                end
                UpdateWholeAlphaPulseState(el, isExp)
                UpdateBounceState(el, isExp)
            end,
        })
    else
        UnregisterExpiring(icon)
        if icon.adBorderPulseFrame and icon.adBorderPulseFrame.dfAD_pulse and icon.adBorderPulseFrame.dfAD_pulse:IsPlaying() then
            icon.adBorderPulseFrame.dfAD_pulse:Stop()
            icon.adBorderPulseFrame:SetAlpha(1)
        end
        if icon.dfAD_wholeAlphaPulse and icon.dfAD_wholeAlphaPulse:IsPlaying() then
            icon.dfAD_wholeAlphaPulse:Stop()
            icon:SetAlpha(icon.dfBaseAlpha or 1)
        end
        if icon.dfAD_bounceAnim and icon.dfAD_bounceAnim:IsPlaying() then
            icon.dfAD_bounceAnim:Stop()
        end
    end

    icon:Show()
end
```

- [ ] **Step 3: Remove the old ApplyIcon function**

Delete the entire `ApplyIcon` function (lines 1323-1805). It is fully replaced by ConfigureIcon + UpdateIcon.

- [ ] **Step 4: Test in-game**

1. Open `/df` settings and go to Aura Designer
2. Configure an icon indicator on an aura
3. Enter test mode (`/df test`) and verify the icon appears with correct size, position, border, stacks, duration
4. Change a setting (e.g., icon size) in the AD GUI and verify it updates immediately
5. Enter combat with auras active — verify icons are click-through (clicks reach the unit frame for casting)
6. Verify new auras appearing mid-combat render correctly

- [ ] **Step 5: Commit**

```bash
git add AuraDesigner/Indicators.lua
git commit -m "Split ApplyIcon into ConfigureIcon + UpdateIcon

Static properties (size, strata, border, fonts, propagation) are set once
in ConfigureIcon. Dynamic properties (texture, cooldown, stacks, expiring)
are set per UNIT_AURA in UpdateIcon. Fixes AD icons blocking click-casting
in combat since propagation is now set once and never reset."
```

---

### Task 4: Split ApplySquare into ConfigureSquare + UpdateSquare

**Files:**
- Modify: `AuraDesigner/Indicators.lua:1886-2318` (ApplySquare area, line numbers will have shifted from Task 3)

Follow the exact same pattern as Task 3 but for squares. Use the current `ApplySquare` code as reference. The key differences from icons:

**ConfigureSquare should include:**
- Size, scale, alpha
- Frame level, frame strata
- Border show/hide, thickness
- Texture color from `config.color` (this is static config, not aura data)
- Stack font settings
- Duration font settings + hide wrapper
- `hideIcon` mode
- Mouse propagation: `SetPropagateMouseMotion(true)`, `SetPropagateMouseClicks(true)`, `SetMouseClickEnabled(false)` — NOTE: squares currently have NO propagation at all, this is a new addition
- Expiring animation frame creation
- Store relevant config flags on the square frame (same pattern as icon)
- Store `dfAD_configVersion`

**UpdateSquare should include:**
- `state.activeSquares[auraName] = true`
- Position (ClearAllPoints + SetPoint, for layout groups)
- Cooldown (SafeSetCooldown)
- Stack count text
- Desaturation for missing aura
- Duration text + color evaluation + hide-above
- Expiring ticker registration + state evaluation
- `sq:Show()`

- [ ] **Step 1: Create ConfigureSquare function**

Extract static properties from ApplySquare into a new `ConfigureSquare` function. Follow the same structure as ConfigureIcon. Add mouse propagation calls (currently missing from squares entirely).

- [ ] **Step 2: Create UpdateSquare function**

Extract dynamic properties from ApplySquare into a new `UpdateSquare` function.

- [ ] **Step 3: Remove the old ApplySquare function**

Delete the entire `ApplySquare` function.

- [ ] **Step 4: Test in-game**

Same test steps as Task 3 but for square indicators. Pay special attention to:
- Square color rendering correctly
- Click-through working in combat (this is new for squares)
- Expiring color changes on squares

- [ ] **Step 5: Commit**

```bash
git add AuraDesigner/Indicators.lua
git commit -m "Split ApplySquare into ConfigureSquare + UpdateSquare

Same configure-once pattern as icons. Also adds missing mouse propagation
to squares — they previously had no click-through at all."
```

---

### Task 5: Split ApplyBar into ConfigureBar + UpdateBar

**Files:**
- Modify: `AuraDesigner/Indicators.lua:2552-3033` (ApplyBar area, line numbers will have shifted)

Follow the same pattern for bars. Key differences from icons/squares:

**ConfigureBar should include:**
- Size, orientation (`SetOrientation`), fill direction (`SetReverseFill`)
- StatusBar texture (`SetStatusBarTexture`), background color
- Border frame + backdrop
- Frame level, frame strata
- Color curve building (`C_CurveUtil.CreateColorCurve`) + storing on bar
- Color flags: `dfAD_barColorByTime`, `dfAD_fillR/G/B`, `dfAD_expiringEnabled`, `dfAD_expiringThreshold`
- Duration font settings
- OnUpdate script assignment
- Mouse propagation: expand existing `SetMouseClickEnabled(false)` to also include `SetPropagateMouseClicks(true)` and `SetPropagateMouseMotion(true)`
- Store `dfAD_configVersion`

**UpdateBar should include:**
- `state.activeBars[auraName] = true`
- Position (ClearAllPoints + SetPoint)
- `dfAD_auraInstanceID`, `dfAD_unit` assignment
- Fill via `SetTimerDuration` or `SetValue`
- Initial color curve evaluation + `SetStatusBarColor`
- Duration text + cooldown setup
- Duration hide-above alpha + ticker registration
- `bar:Show()`

- [ ] **Step 1: Create ConfigureBar function**

Extract static properties from ApplyBar. Add full mouse propagation.

- [ ] **Step 2: Create UpdateBar function**

Extract dynamic properties from ApplyBar.

- [ ] **Step 3: Remove the old ApplyBar function**

Delete the entire `ApplyBar` function.

- [ ] **Step 4: Test in-game**

Same test steps as Task 3 but for bar indicators. Pay special attention to:
- Bar fill animation (SetTimerDuration path)
- Bar color-by-time curves
- OnUpdate color/text updates still working
- Click-through in combat (expanded from partial)

- [ ] **Step 5: Commit**

```bash
git add AuraDesigner/Indicators.lua
git commit -m "Split ApplyBar into ConfigureBar + UpdateBar

Same configure-once pattern as icons/squares. Expands mouse propagation
from partial (SetMouseClickEnabled only) to full click-through."
```

---

### Task 6: Update Dispatch in Indicators:Apply and Engine

**Files:**
- Modify: `AuraDesigner/Indicators.lua:515-573` (Apply dispatch function)
- Modify: `AuraDesigner/Engine.lua:625-666` (UpdateFrame dispatch loop)

- [ ] **Step 1: Add Configure dispatch to Indicators**

Add a new `Indicators:Configure` method right before the existing `Indicators:Apply` (at ~line 515):

```lua
function Indicators:Configure(frame, typeKey, config, defaults, auraName, priority)
    if typeKey == "icon" then
        self:ConfigureIcon(frame, config, defaults, auraName, priority)
    elseif typeKey == "square" then
        self:ConfigureSquare(frame, config, defaults, auraName, priority)
    elseif typeKey == "bar" then
        self:ConfigureBar(frame, config, defaults, auraName, priority)
    end
    -- border, healthbar, nametext, healthtext, framealpha don't need configure-once
    -- (they modify the unit frame itself, not pooled indicator frames)
end
```

- [ ] **Step 2: Update Indicators:Apply to use UpdateIcon/UpdateSquare/UpdateBar**

In the existing `Indicators:Apply` function, change the icon/square/bar dispatch lines:

```lua
    elseif typeKey == "icon" then
        self:UpdateIcon(frame, config, auraData, defaults, auraName, priority)
    elseif typeKey == "square" then
        self:UpdateSquare(frame, config, auraData, defaults, auraName, priority)
    elseif typeKey == "bar" then
        self:UpdateBar(frame, config, auraData, defaults, auraName, priority)
    end
```

- [ ] **Step 3: Add config version check to Engine dispatch loop**

In `Engine.lua`, modify the dispatch loop (lines 625-666). Before the `Indicators:Apply` call, add the version check. The indicator frame needs to be looked up to check its version:

```lua
    for _, ind in ipairs(activeIndicators) do
        local key = ind.placed and ind.instanceKey or ind.auraName
        local config = ind.config

        -- Layout group offset wrapping (existing code, unchanged)
        if ind.placed and ind.instanceKey then
            local entry = groupLookup[ind.instanceKey]
            if entry then
                -- ... existing metatable wrapper code ...
            end
        end

        -- Configure-once: only reconfigure when AD settings have changed
        if ind.typeKey == "icon" or ind.typeKey == "square" or ind.typeKey == "bar" then
            local indicatorFrame = nil
            if ind.typeKey == "icon" then
                indicatorFrame = frame.dfAD_icons and frame.dfAD_icons[key]
            elseif ind.typeKey == "square" then
                indicatorFrame = frame.dfAD_squares and frame.dfAD_squares[key]
            elseif ind.typeKey == "bar" then
                indicatorFrame = frame.dfAD_bars and frame.dfAD_bars[key]
            end
            -- Configure if frame doesn't exist yet (first time) or version is stale
            if not indicatorFrame or indicatorFrame.dfAD_configVersion ~= (DF.adConfigVersion or 0) then
                Indicators:Configure(frame, ind.typeKey, config, adDB.defaults, key, ind.priority)
            end
        end

        Indicators:Apply(frame, ind.typeKey, config, ind.auraData, adDB.defaults, key, ind.priority)
    end
```

- [ ] **Step 4: Test the full system in-game**

1. `/df test` — verify all indicator types render correctly
2. Change AD settings in GUI — verify they update immediately
3. Switch profiles — verify indicators reconfigure
4. Enter combat — verify click-through works for all indicator types (icons, squares, bars)
5. Verify auras appearing/disappearing mid-combat work correctly
6. Verify layout groups still position correctly with dynamic member changes

- [ ] **Step 5: Commit**

```bash
git add AuraDesigner/Indicators.lua AuraDesigner/Engine.lua
git commit -m "Wire up configure-once dispatch in Engine and Indicators

Engine checks adConfigVersion before each indicator and calls Configure
only when stale. Apply now dispatches to UpdateIcon/Square/Bar for the
lightweight per-event path. Non-pooled indicator types (border, healthbar,
nametext, healthtext, framealpha) are unchanged."
```

---

### Task 7: Final Cleanup and Verification

**Files:**
- Modify: `AuraDesigner/Indicators.lua` (remove dead code if any)
- Modify: `Core.lua` (verify fixIconMouse still works for regular auras)

- [ ] **Step 1: Verify fixIconMouse in Core.lua is unaffected**

Read the `fixIconMouse` function in Core.lua (~line 4540). Confirm it still only iterates `buffIcons`, `debuffIcons`, `defensiveBarIcons` — it should NOT be extended to AD indicators since AD indicators now have propagation set permanently via ConfigureIcon/Square/Bar.

- [ ] **Step 2: Remove the InCombatLockdown guard from GetOrCreateADIcon path**

In `Frames/Create.lua`, the `CreateAuraIcon` function (line 2511) has an `InCombatLockdown()` guard that sets `DF.auraIconsNeedMouseFix = true` as a fallback. Since AD icons now get propagation from ConfigureIcon (which runs outside combat), this fallback is harmless but no longer needed for AD icons. Leave it as-is since regular buff icons still use it.

- [ ] **Step 3: Full integration test**

Complete test checklist:
1. Fresh login — AD indicators appear and are click-through
2. Profile switch from Blizzard to Direct API — auras appear immediately
3. Profile switch from Direct API to Blizzard — auras appear immediately
4. AD icons in combat — click-through, no blocking
5. AD squares in combat — click-through (new behavior)
6. AD bars in combat — click-through (improved from partial)
7. Change AD settings mid-session — indicators update immediately
8. Layout groups — position dynamically with aura changes
9. Expiring animations — pulse, bounce, alpha all work
10. Duration text — color-by-time, hide-above-threshold work
11. Missing aura mode — desaturation works

- [ ] **Step 4: Commit any cleanup**

```bash
git add -A
git commit -m "Final cleanup for AD indicator pooling refactor"
```
