local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER - INDICATORS
-- Visual rendering for all 8 indicator types. Creates, shows,
-- hides, and updates indicator elements on unit frames.
--
-- Uses a Begin/Apply/End pattern per frame update:
--   BeginFrame(frame)  -- reset per-frame state
--   Apply(frame, ...)  -- called per active indicator
--   EndFrame(frame)    -- revert anything not applied
--
-- Key design decisions:
--   - Border: Own overlay frame (like highlight system), not
--     modifying the existing frame.border
--   - Icons: Created via DF:CreateAuraIcon() for full expiring
--     indicator, duration text, and stack support
--   - Placed indicators: One per aura name at its configured
--     anchor point — no growth/pushing between auras
-- ============================================================

local pairs, ipairs, type = pairs, ipairs, type
local format = string.format
local GetTime = GetTime
local max, min = math.max, math.min
local issecretvalue = issecretvalue or function() return false end
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID
local IsAuraFilteredOut = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID

-- Check if an interpolated color result differs from the original color.
-- result.r/g/b may be secret (tainted) values from EvaluateRemainingDuration/Percent;
-- arithmetic on secret values throws. If tainted, the engine IS interpolating → expiring.
local function IsColorExpiring(result, oc)
    if issecretvalue(result.r) then return true end
    return (math.abs(result.r - oc.r) > 0.01 or math.abs(result.g - oc.g) > 0.01 or math.abs(result.b - oc.b) > 0.01)
end

DF.AuraDesigner = DF.AuraDesigner or {}

local Indicators = {}
DF.AuraDesigner.Indicators = Indicators

-- Strata ordering for safe strata assignment (never lower an indicator below its parent frame)
local STRATA_ORDER = {
    BACKGROUND = 1, LOW = 2, MEDIUM = 3, HIGH = 4,
    DIALOG = 5, FULLSCREEN = 6, FULLSCREEN_DIALOG = 7, TOOLTIP = 8,
}

local function SafeSetFrameStrata(widget, frame, targetStrata)
    local parentStrata = frame:GetFrameStrata()
    local parentOrder = STRATA_ORDER[parentStrata] or 3
    local targetOrder = STRATA_ORDER[targetStrata] or 3
    -- Don't lower below the parent (prevents vanishing in preview panels)
    if targetOrder < parentOrder then
        widget:SetFrameStrata(parentStrata)
    else
        widget:SetFrameStrata(targetStrata)
    end
end

-- ============================================================
-- SAFE HELPERS (match the pattern in Features/Auras.lua)
-- ============================================================

local function SafeSetTexture(icon, texture)
    if icon and icon.texture and texture then
        icon.texture:SetTexture(texture)
        return true
    end
end

-- Secret-safe cooldown setter using Duration objects.
-- Real unit: C_UnitAuras.GetAuraDuration → SetCooldownFromDurationObject
-- Preview:  C_DurationUtil.CreateDuration → SetCooldownFromDurationObject
-- Fallback: SetCooldownFromExpirationTime
local function SafeSetCooldown(cooldown, auraData, unit)
    if not cooldown then return end

    -- Path 1: Real unit — get Duration object from the API (handles secrets)
    if unit and auraData.auraInstanceID
       and C_UnitAuras and C_UnitAuras.GetAuraDuration
       and cooldown.SetCooldownFromDurationObject then
        local durationObj = C_UnitAuras.GetAuraDuration(unit, auraData.auraInstanceID)
        if durationObj then
            cooldown:SetCooldownFromDurationObject(durationObj)
            return
        end
    end

    -- Path 2: Preview (no real unit) — build a synthetic Duration object
    local dur = auraData.duration
    local exp = auraData.expirationTime
    if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
        if C_DurationUtil and C_DurationUtil.CreateDuration and cooldown.SetCooldownFromDurationObject then
            local durationObj = C_DurationUtil.CreateDuration()
            durationObj:SetTimeFromStart(exp - dur, dur)
            cooldown:SetCooldownFromDurationObject(durationObj)
            return
        end
        -- Final fallback
        if cooldown.SetCooldownFromExpirationTime then
            cooldown:SetCooldownFromExpirationTime(exp, dur)
        elseif cooldown.SetCooldown then
            cooldown:SetCooldown(exp - dur, dur)
        end
    end
end

-- Secret-safe check for whether an aura has a timer.
-- Uses C_UnitAuras.DoesAuraHaveExpirationTime when available (handles secrets).
-- Falls back to direct comparison when values are non-secret (e.g., preview).
local function HasAuraDuration(auraData, unit)
    -- When a real unit is present, the Duration object pipeline
    -- (SetCooldownFromDurationObject / SetTimerDuration) handles everything
    -- including permanent auras. Return true so we enter those code paths;
    -- the APIs are secret-safe and handle zero-duration correctly.
    -- We avoid DoesAuraHaveExpirationTime because it returns a secret boolean
    -- that can't be used in conditionals.
    if unit and auraData.auraInstanceID then
        return true
    end
    -- Fallback for preview (non-secret mock data)
    local dur = auraData.duration
    local exp = auraData.expirationTime
    if dur and exp then
        if issecretvalue(dur) or issecretvalue(exp) then
            return true
        end
        return dur > 0 and exp > 0
    end
    return false
end

-- ============================================================
-- BORDER OFFSET COMPENSATION
-- Adjusts indicator position so borders don't hang off the frame
-- edge when anchored at a boundary (e.g. TOPLEFT offset 0,0).
-- ============================================================

local function AdjustOffsetForBorder(anchor, offsetX, offsetY, borderSize, borderEnabled)
    if not borderEnabled or not borderSize or borderSize <= 0 then
        return offsetX, offsetY
    end
    local a = anchor or "CENTER"
    if a:find("LEFT") then
        offsetX = offsetX + borderSize
    elseif a:find("RIGHT") then
        offsetX = offsetX - borderSize
    end
    if a:find("TOP") then
        offsetY = offsetY - borderSize
    elseif a:find("BOTTOM") then
        offsetY = offsetY + borderSize
    end
    return offsetX, offsetY
end

-- ============================================================
-- SHARED EXPIRING TICKER
-- Processes all registered indicators with expiring settings
-- at ~3 FPS. Same dual-path approach as bar's OnUpdate:
--   API path:     Build a Step color curve per element, evaluate
--                 via durationObj:EvaluateRemainingPercent → apply
--   Preview path: Manual pct calculation, compare to threshold
-- ============================================================

local expiringRegistry = {}
local pendingHideWhenNotExpiring = false  -- Set by Apply before dispatch, read by RegisterExpiring
local pendingUseShowHide = false          -- When true, ticker uses Show/Hide instead of SetAlpha
local pendingHiddenAlpha = nil            -- Alpha to use when "not expiring" (nil = 0 for borders, savedAlpha for framealpha)

local function RegisterExpiring(element, entryData)
    -- Propagate Show When Missing visibility flag
    if pendingHideWhenNotExpiring then
        entryData.hideWhenNotExpiring = true
        entryData.visibleAlpha = entryData.originalAlpha or 1
        entryData.useShowHide = pendingUseShowHide or false
        entryData.hiddenAlpha = pendingHiddenAlpha  -- nil = use 0, number = use that alpha
    end
    expiringRegistry[element] = entryData

    -- Evaluate immediately so the Apply function ends with the correct
    -- color.  Without this the Apply sets the *original* color, then the
    -- ticker (3 FPS) overrides it later → visible flicker.
    -- Same approach as bar's "Set initial bar color" block in ConfigureBar.
    local applied = false
    if entryData.colorCurve and entryData.unit and entryData.auraInstanceID
       and C_UnitAuras and C_UnitAuras.GetAuraDuration then
        local durationObj = C_UnitAuras.GetAuraDuration(entryData.unit, entryData.auraInstanceID)
        if durationObj then
            local result
            if entryData.thresholdMode == "SECONDS" and durationObj.EvaluateRemainingDuration then
                result = durationObj:EvaluateRemainingDuration(entryData.colorCurve)
            elseif durationObj.EvaluateRemainingPercent then
                result = durationObj:EvaluateRemainingPercent(entryData.colorCurve)
            end
            if result and entryData.applyResult then
                entryData.applyResult(element, result, entryData)
                applied = true
            end
        end
    end
    if not applied then
        local dur = entryData.duration
        local exp = entryData.expirationTime
        if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
            local remaining = max(0, exp - GetTime())
            local isExpiring
            if entryData.thresholdMode == "SECONDS" then
                isExpiring = remaining <= (entryData.threshold or 10)
            else
                local pct = remaining / dur
                isExpiring = pct <= ((entryData.threshold or 30) / 100)
            end
            if entryData.applyManual then
                entryData.applyManual(element, isExpiring, entryData)
            end
        elseif entryData.applyManual then
            -- duration=0 means permanent or synthetic (missing) aura — not expiring
            entryData.applyManual(element, false, entryData)
        end
    end
end

local function UnregisterExpiring(element)
    if element then
        expiringRegistry[element] = nil
    end
end

-- Build a Step color curve encoding two states:
--   Below threshold → expiring color
--   At/above threshold → original color
-- Same pattern as bar's dfAD_colorCurve for expiring-only mode.
-- thresholdMode: nil/"PERCENT" = percentage (0-100), "SECONDS" = seconds (1-60)
local function BuildExpiringColorCurve(threshold, expiringColor, originalColor, thresholdMode)
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then return nil end
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    local ecR = expiringColor.r or 1
    local ecG = expiringColor.g or 0.2
    local ecB = expiringColor.b or 0.2
    local ocR = originalColor.r or 1
    local ocG = originalColor.g or 1
    local ocB = originalColor.b or 1
    curve:AddPoint(0, CreateColor(ecR, ecG, ecB, 1))
    if thresholdMode == "SECONDS" then
        -- Curve points in seconds for EvaluateRemainingDuration
        curve:AddPoint(threshold, CreateColor(ocR, ocG, ocB, 1))
        curve:AddPoint(600, CreateColor(ocR, ocG, ocB, 1))  -- 10min cap
    else
        -- Curve points as decimal percentage for EvaluateRemainingPercent
        curve:AddPoint(threshold / 100, CreateColor(ocR, ocG, ocB, 1))
        curve:AddPoint(1, CreateColor(ocR, ocG, ocB, 1))
    end
    return curve
end

-- Build a Step color curve for hiding duration text above a seconds threshold.
-- Returns alpha=1 (visible) when remaining <= threshold, alpha=0 (hidden) above.
-- Only uses EvaluateRemainingDuration (always seconds-based).
-- Create (or return cached) pulse AnimationGroup on a frame.
-- Matches the buff tab's expiring border pulse: 1→0.3→1, 0.5s each, IN_OUT, REPEAT.
local function GetOrCreatePulseAnim(frame)
    if not frame.dfAD_pulse then
        frame.dfAD_pulse = frame:CreateAnimationGroup()
        frame.dfAD_pulse:SetLooping("REPEAT")
        local fadeOut = frame.dfAD_pulse:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.3)
        fadeOut:SetDuration(0.5)
        fadeOut:SetOrder(1)
        fadeOut:SetSmoothing("IN_OUT")
        local fadeIn = frame.dfAD_pulse:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.3)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.5)
        fadeIn:SetOrder(2)
        fadeIn:SetSmoothing("IN_OUT")
    end
    return frame.dfAD_pulse
end

-- Play or stop a pulse animation based on expiring state.
local function UpdatePulseState(el, isExpiring)
    if el.dfAD_expiringPulsate and el.dfAD_pulse then
        if isExpiring and not el.dfAD_pulse:IsPlaying() then
            el.dfAD_pulse:Play()
        elseif not isExpiring and el.dfAD_pulse:IsPlaying() then
            el.dfAD_pulse:Stop()
            el:SetAlpha(1)
        end
    end
end

-- Create or return a whole-frame alpha pulse animation (pulses entire icon/square).
local function GetOrCreateWholeAlphaPulse(frame)
    if not frame.dfAD_wholeAlphaPulse then
        frame.dfAD_wholeAlphaPulse = frame:CreateAnimationGroup()
        frame.dfAD_wholeAlphaPulse:SetLooping("REPEAT")
        local fadeOut = frame.dfAD_wholeAlphaPulse:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.3)
        fadeOut:SetDuration(0.5)
        fadeOut:SetOrder(1)
        fadeOut:SetSmoothing("IN_OUT")
        local fadeIn = frame.dfAD_wholeAlphaPulse:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.3)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.5)
        fadeIn:SetOrder(2)
        fadeIn:SetSmoothing("IN_OUT")
    end
    return frame.dfAD_wholeAlphaPulse
end

-- Create or return a bounce (translation) animation.
-- For squares, a wrapper frame is used to avoid CooldownFrameTemplate rendering glitches
-- when Translation is applied directly to a frame with a Cooldown child.
-- The wrapper is created and managed in the square expiring setup section.
local function GetOrCreateBounceAnim(frame)
    if not frame.dfAD_bounceAnim then
        frame.dfAD_bounceAnim = frame:CreateAnimationGroup()
        frame.dfAD_bounceAnim:SetLooping("REPEAT")
        local up = frame.dfAD_bounceAnim:CreateAnimation("Translation")
        up:SetOffset(0, 4)
        up:SetDuration(0.25)
        up:SetOrder(1)
        up:SetSmoothing("OUT")
        local down = frame.dfAD_bounceAnim:CreateAnimation("Translation")
        down:SetOffset(0, -4)
        down:SetDuration(0.25)
        down:SetOrder(2)
        down:SetSmoothing("IN")
    end
    return frame.dfAD_bounceAnim
end

-- Play or stop whole-alpha pulse based on expiring state.
local function UpdateWholeAlphaPulseState(el, isExpiring)
    if el.dfAD_expiringWholeAlphaPulse and el.dfAD_wholeAlphaPulse then
        if isExpiring and not el.dfAD_wholeAlphaPulse:IsPlaying() then
            el.dfAD_wholeAlphaPulse:Play()
        elseif not isExpiring and el.dfAD_wholeAlphaPulse:IsPlaying() then
            el.dfAD_wholeAlphaPulse:Stop()
            el:SetAlpha(1)
        end
    end
end

-- Play or stop bounce animation based on expiring state.
local function UpdateBounceState(el, isExpiring)
    if el.dfAD_expiringBounce and el.dfAD_bounceAnim then
        if isExpiring and not el.dfAD_bounceAnim:IsPlaying() then
            el.dfAD_bounceAnim:Play()
        elseif not isExpiring and el.dfAD_bounceAnim:IsPlaying() then
            el.dfAD_bounceAnim:Stop()
        end
    end
end

local function BuildDurationHideCurve(threshold)
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then return nil end
    DF.durationHideCurves = DF.durationHideCurves or {}
    local cacheKey = threshold
    if not DF.durationHideCurves[cacheKey] then
        local curve = C_CurveUtil.CreateColorCurve()
        curve:SetType(Enum.LuaCurveType.Step)
        curve:AddPoint(0, CreateColor(1, 1, 1, 1))          -- visible
        curve:AddPoint(threshold, CreateColor(1, 1, 1, 0))  -- hidden
        curve:AddPoint(600, CreateColor(1, 1, 1, 0))        -- cap
        DF.durationHideCurves[cacheKey] = curve
    end
    return DF.durationHideCurves[cacheKey]
end

-- Scan for the native cooldown FontString that Blizzard creates lazily.
-- Returns true if it was newly found this call (caller should apply deferred styling).
local function EnsureNativeCooldownText(indicator, cooldownFrame)
    if indicator.nativeCooldownText then return false end
    if not cooldownFrame then return false end
    local regions = { cooldownFrame:GetRegions() }
    for _, region in pairs(regions) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            indicator.nativeCooldownText = region
            indicator.nativeTextReparented = false
            return true
        end
    end
    return false
end

-- Apply deferred duration text styling when the native cooldown FontString
-- is discovered after Configure (because Blizzard creates it lazily on
-- first SetCooldown).  Mirrors the reparent+style+position block in Configure.
local function ApplyDeferredDurationStyling(indicator)
    local text = indicator.nativeCooldownText
    if not text then return end
    if not indicator.showDuration and indicator.showDuration ~= nil then
        text:Hide()
        return
    end
    -- Create duration hide wrapper if needed
    if not indicator.durationHideWrapper and indicator.textOverlay then
        indicator.durationHideWrapper = CreateFrame("Frame", nil, indicator.textOverlay)
        indicator.durationHideWrapper:SetAllPoints(indicator.textOverlay)
        indicator.durationHideWrapper:SetFrameLevel(indicator.textOverlay:GetFrameLevel())
        indicator.durationHideWrapper:EnableMouse(false)
    end
    -- Reparent into wrapper
    if not indicator.nativeTextReparented and indicator.durationHideWrapper then
        text:SetParent(indicator.durationHideWrapper)
        indicator.nativeTextReparented = true
    end
    -- Style
    local font = indicator.dfAD_durationFont or "Fonts\\FRIZQT__.TTF"
    local scale = indicator.dfAD_durationScale or 1.0
    local outline = indicator.dfAD_durationOutline or "OUTLINE"
    if outline == "NONE" then outline = "" end
    local size = 10 * scale
    DF:SafeSetFont(text, font, size, outline)
    -- Position
    local anchor = indicator.durationAnchor or indicator.dfAD_durationAnchor or "CENTER"
    local dx = indicator.durationX or indicator.dfAD_durationX or 0
    local dy = indicator.durationY or indicator.dfAD_durationY or 0
    text:ClearAllPoints()
    text:SetPoint(anchor, indicator, anchor, dx, dy)
    text:Show()
end

local expiringFrame = CreateFrame("Frame")
local expiringElapsed = 0
expiringFrame:Show()  -- CRITICAL: OnUpdate only fires on visible frames

expiringFrame:SetScript("OnUpdate", function(_, elapsed)
    expiringElapsed = expiringElapsed + elapsed
    if expiringElapsed < 0.33 then return end  -- ~3 FPS
    expiringElapsed = 0

    for element, entry in pairs(expiringRegistry) do
        if not element:IsShown() then
            expiringRegistry[element] = nil
        else
            local applied = false

            -- API path: evaluate color curve (same as bar's OnUpdate)
            if entry.colorCurve and entry.unit and entry.auraInstanceID
               and C_UnitAuras and C_UnitAuras.GetAuraDuration then
                local durationObj = C_UnitAuras.GetAuraDuration(entry.unit, entry.auraInstanceID)
                if durationObj then
                    local result
                    if entry.thresholdMode == "SECONDS" and durationObj.EvaluateRemainingDuration then
                        result = durationObj:EvaluateRemainingDuration(entry.colorCurve)
                    elseif durationObj.EvaluateRemainingPercent then
                        result = durationObj:EvaluateRemainingPercent(entry.colorCurve)
                    end
                    if result and entry.applyResult then
                        entry.applyResult(element, result, entry)
                        applied = true
                    end
                end
            end

            -- Preview fallback: manual comparison (same as bar's preview path)
            if not applied then
                local dur = entry.duration
                local exp = entry.expirationTime
                if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
                    local remaining = max(0, exp - GetTime())
                    local isExpiring
                    if entry.thresholdMode == "SECONDS" then
                        isExpiring = remaining <= (entry.threshold or 10)
                    else
                        local pct = remaining / dur
                        isExpiring = pct <= ((entry.threshold or 30) / 100)
                    end
                    if entry.applyManual then
                        entry.applyManual(element, isExpiring, entry)
                    end
                elseif entry.applyManual then
                    -- duration=0 means permanent or synthetic (missing) aura — not expiring
                    entry.applyManual(element, false, entry)
                end
            end

            -- Show When Missing: toggle visibility based on expiring state.
            -- Icons/squares use Hide()/Show() so OOR alpha restore won't undo us.
            -- Borders use SetAlpha() since they're not in the OOR icon/square loop.
            if entry.hideWhenNotExpiring then
                local dur = entry.duration
                local exp = entry.expirationTime
                local isExp = false
                if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
                    local rem = max(0, exp - GetTime())
                    if entry.thresholdMode == "SECONDS" then
                        isExp = rem <= (entry.threshold or 10)
                    else
                        isExp = (rem / dur) <= ((entry.threshold or 30) / 100)
                    end
                end
                if entry.useShowHide then
                    if isExp then
                        element:Show()
                        element:SetAlpha(entry.visibleAlpha or 1)
                    else
                        element:Hide()
                    end
                else
                    local notExpAlpha = entry.hiddenAlpha or 0
                    element:SetAlpha(isExp and (entry.visibleAlpha or 1) or notExpAlpha)
                end
            end
        end
    end
end)

-- ============================================================
-- PER-FRAME STATE
-- Tracks which frame-level indicators were applied this frame
-- so EndFrame can revert unclaimed ones.
-- ============================================================

local function EnsureFrameState(frame)
    if not frame.dfAD then
        frame.dfAD = {
            -- Frame-level claim flags (reset each BeginFrame)
            border = false,
            healthbar = false,
            nametext = false,
            healthtext = false,
            framealpha = false,
            -- Placed indicator tracking: { [auraName] = true } for active this frame
            activeIcons = {},
            activeSquares = {},
            activeBars = {},
            -- Custom border tracking: { [auraName] = true } for active this frame
            activeCustomBorders = {},
            -- Saved defaults for reverting (tintOverlay cached separately)
            savedNameColor = nil,
            savedHealthTextColor = nil,
            savedAlpha = nil,
        }
    end
    return frame.dfAD
end

-- ============================================================
-- BEGIN FRAME
-- Reset per-frame state before Apply calls
-- ============================================================

function Indicators:BeginFrame(frame)
    local state = EnsureFrameState(frame)
    state.border = false
    state.healthbar = false
    state.nametext = false
    state.healthtext = false
    state.framealpha = false
    table.wipe(state.activeIcons)
    table.wipe(state.activeSquares)
    table.wipe(state.activeBars)
    table.wipe(state.activeCustomBorders)
end

-- ============================================================
-- CONFIGURE DISPATCH
-- Routes to type-specific Configure functions for pooled indicator types.
-- Called only when dfAD_configVersion is stale.
-- ============================================================
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

-- ============================================================
-- APPLY -- DISPATCH TO TYPE HANDLERS
-- ============================================================

function Indicators:Apply(frame, typeKey, config, auraData, defaults, auraName, priority)
    -- Show When Missing + aura is present: hide unless expiring
    local hideUntilExpiring = config.showWhenMissing and auraData and not auraData.isMissingAura
    if hideUntilExpiring and not config.expiringEnabled then
        -- No expiring configured; nothing to show when aura is present
        return
    end

    -- Validate aura still exists and matches expectations before rendering.
    -- Mirrors the defensive bar post-validation pattern (commit 7b141a8).
    local unit = frame.unit
    local auraID = auraData and auraData.auraInstanceID
    if auraID then
        -- Secret auraInstanceID = stale cache hit from a different aura
        if issecretvalue(auraID) then return end

        -- Verify the aura still exists on this unit
        if unit and GetAuraDataByAuraInstanceID then
            local live = GetAuraDataByAuraInstanceID(unit, auraID)
            if not live then return end
        end

        -- Verify the aura belongs to the player (not another player's buff)
        -- Skip for selfOnly auras (e.g. Symbiotic Relationship) where the
        -- source is another unit but the buff legitimately appears on the player
        if unit and IsAuraFilteredOut and not auraData.selfOnly then
            if IsAuraFilteredOut(unit, auraID, "HELPFUL|PLAYER") then return end
        end
    end

    -- Set module flags so RegisterExpiring (called inside Apply*) picks them up
    pendingHideWhenNotExpiring = hideUntilExpiring or false
    -- Icons and squares use Show/Hide to avoid OOR alpha restore undoing the hide
    pendingUseShowHide = (typeKey == "icon" or typeKey == "square") and hideUntilExpiring or false
    -- Frame alpha reverts to saved alpha instead of 0 when "not expiring"
    if typeKey == "framealpha" and hideUntilExpiring then
        local state = frame.dfAD
        pendingHiddenAlpha = state and state.savedAlpha or 1.0
    else
        pendingHiddenAlpha = nil
    end

    if typeKey == "border" then
        self:ApplyBorder(frame, config, auraData, auraName)
    elseif typeKey == "healthbar" then
        self:ApplyHealthBar(frame, config, auraData)
    elseif typeKey == "nametext" then
        self:ApplyNameText(frame, config, auraData)
    elseif typeKey == "healthtext" then
        self:ApplyHealthText(frame, config, auraData)
    elseif typeKey == "framealpha" then
        self:ApplyFrameAlpha(frame, config, auraData)
    elseif typeKey == "icon" then
        self:UpdateIcon(frame, config, auraData, defaults, auraName, priority)
    elseif typeKey == "square" then
        self:UpdateSquare(frame, config, auraData, defaults, auraName, priority)
    elseif typeKey == "bar" then
        self:UpdateBar(frame, config, auraData, defaults, auraName, priority)
    end

    pendingHideWhenNotExpiring = false  -- Reset
    pendingUseShowHide = false
    pendingHiddenAlpha = nil

    -- After rendering, hide the indicator if we're in "present but hide until expiring" mode.
    -- The expiring ticker (3 FPS) will toggle visibility when the threshold is met.
    -- Use Hide() for icons/squares so OOR alpha restore (UpdateAuraDesignerAppearance)
    -- won't undo our visibility override. Borders keep SetAlpha since they're not in
    -- the OOR icon/square loop.
    if hideUntilExpiring then
        if typeKey == "icon" then
            local icon = frame.dfAD_icons and frame.dfAD_icons[auraName]
            if icon then icon:Hide() end
        elseif typeKey == "square" then
            local sq = frame.dfAD_squares and frame.dfAD_squares[auraName]
            if sq then sq:Hide() end
        elseif typeKey == "border" then
            local ch = frame.dfAD_border
            if config.borderMode == "custom" and frame.dfAD_customBorders then
                ch = frame.dfAD_customBorders[auraName]
            end
            if ch then ch:SetAlpha(0) end
        elseif typeKey == "framealpha" then
            -- Revert to normal alpha — don't make the frame transparent
            local state = frame.dfAD
            local savedAlpha = state and state.savedAlpha or 1.0
            frame:SetAlpha(savedAlpha)
        end
    end
end

-- ============================================================
-- APPLY (TEST MODE)
-- Skips aura validation — mock data has no real auraInstanceID
-- ============================================================

function Indicators:ApplyTest(frame, typeKey, config, auraData, defaults, auraName, priority)
    if typeKey == "border" then
        self:ApplyBorder(frame, config, auraData, auraName)
    elseif typeKey == "healthbar" then
        self:ApplyHealthBar(frame, config, auraData)
    elseif typeKey == "nametext" then
        self:ApplyNameText(frame, config, auraData)
    elseif typeKey == "healthtext" then
        self:ApplyHealthText(frame, config, auraData)
    elseif typeKey == "framealpha" then
        self:ApplyFrameAlpha(frame, config, auraData)
    elseif typeKey == "icon" then
        self:ConfigureIcon(frame, config, defaults, auraName, priority)
        self:UpdateIcon(frame, config, auraData, defaults, auraName, priority)
    elseif typeKey == "square" then
        self:ConfigureSquare(frame, config, defaults, auraName, priority)
        self:UpdateSquare(frame, config, auraData, defaults, auraName, priority)
    elseif typeKey == "bar" then
        self:ConfigureBar(frame, config, defaults, auraName, priority)
        self:UpdateBar(frame, config, auraData, defaults, auraName, priority)
    end
end

-- ============================================================
-- END FRAME
-- Revert anything not claimed during this frame's Apply calls
-- ============================================================

function Indicators:EndFrame(frame)
    local state = frame.dfAD
    if not state then return end

    -- Revert shared border
    if not state.border then
        self:RevertBorder(frame)
    end

    -- Hide custom borders not active this frame
    if frame.dfAD_customBorders then
        for key, ch in pairs(frame.dfAD_customBorders) do
            if not state.activeCustomBorders[key] then
                UnregisterExpiring(ch)
                DF.ApplyHighlightStyle(ch, "NONE", 2, 0, 1, 1, 1, 1)
                ch.dfAD_style = nil
                ch.dfAD_auraID = nil
            end
        end
    end

    -- Revert health bar color
    if not state.healthbar then
        self:RevertHealthBar(frame)
    end

    -- Revert name text color
    if not state.nametext then
        self:RevertNameText(frame)
    end

    -- Revert health text color
    if not state.healthtext then
        self:RevertHealthText(frame)
    end

    -- Revert frame alpha
    if not state.framealpha then
        self:RevertFrameAlpha(frame)
    end

    -- Hide placed indicators not active this frame
    self:HideUnusedIcons(frame, state.activeIcons)
    self:HideUnusedSquares(frame, state.activeSquares)
    self:HideUnusedBars(frame, state.activeBars)

    -- Re-apply OOR alpha after AD has set config alphas on all indicators
    if DF.UpdateAuraDesignerAppearance then
        DF:UpdateAuraDesignerAppearance(frame)
    end
end

-- ============================================================
-- HIDE ALL -- Clear everything (used when AD disabled or no unit)
-- ============================================================

function Indicators:HideAll(frame)
    self:RevertBorder(frame)
    self:RevertCustomBorders(frame)
    self:RevertHealthBar(frame)
    self:RevertNameText(frame)
    self:RevertHealthText(frame)
    self:RevertFrameAlpha(frame)
    self:HideUnusedIcons(frame, {})
    self:HideUnusedSquares(frame, {})
    self:HideUnusedBars(frame, {})
end

-- ============================================================
-- FRAME-LEVEL INDICATORS
-- These modify existing frame elements. Only the highest
-- priority aura claiming a type wins (first Apply call claims).
-- ============================================================

-- ============================================================
-- BORDER (own overlay frame, like the highlight system)
-- Creates a separate frame parented to UIParent with 4 edge
-- textures. Does NOT modify the existing frame.border.
-- ============================================================

-- Map old border style names to highlight-compatible uppercase keys
local BORDER_STYLE_MIGRATION = { Solid = "SOLID", Glow = "GLOW", Pulse = "SOLID" }

local function GetOrCreateADBorder(frame)
    if frame.dfAD_border then
        -- Update points (frame may have moved)
        frame.dfAD_border:ClearAllPoints()
        frame.dfAD_border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.dfAD_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        return frame.dfAD_border
    end

    -- Create overlay frame parented to UIParent (avoids clipping)
    -- Uses same structure as the highlight system so we can reuse
    -- DF.ApplyHighlightStyle for all 6 border modes.
    local ch = CreateFrame("Frame", nil, UIParent)
    ch:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    ch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    ch:SetFrameStrata(frame:GetFrameStrata())
    ch:SetFrameLevel(frame:GetFrameLevel() + 8)  -- Below aggro(+9) highlight
    ch:Hide()

    -- 4 edge textures (named to match highlight system)
    ch.topLine = ch:CreateTexture(nil, "OVERLAY")
    ch.bottomLine = ch:CreateTexture(nil, "OVERLAY")
    ch.leftLine = ch:CreateTexture(nil, "OVERLAY")
    ch.rightLine = ch:CreateTexture(nil, "OVERLAY")

    -- Hook owner OnHide to hide border
    frame:HookScript("OnHide", function()
        if frame.dfAD_border then
            frame.dfAD_border:Hide()
        end
    end)

    frame.dfAD_border = ch
    return ch
end

local function GetOrCreateCustomBorder(frame, key)
    if not frame.dfAD_customBorders then
        frame.dfAD_customBorders = {}
    end
    local pool = frame.dfAD_customBorders
    if pool[key] then
        pool[key]:ClearAllPoints()
        pool[key]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        pool[key]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        return pool[key]
    end

    local ch = CreateFrame("Frame", nil, UIParent)
    ch:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    ch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    ch:SetFrameStrata(frame:GetFrameStrata())
    ch:SetFrameLevel(frame:GetFrameLevel() + 7)  -- Below shared border(+8)
    ch:Hide()

    ch.topLine = ch:CreateTexture(nil, "OVERLAY")
    ch.bottomLine = ch:CreateTexture(nil, "OVERLAY")
    ch.leftLine = ch:CreateTexture(nil, "OVERLAY")
    ch.rightLine = ch:CreateTexture(nil, "OVERLAY")

    frame:HookScript("OnHide", function()
        if pool[key] then
            pool[key]:Hide()
        end
    end)

    pool[key] = ch
    return ch
end

-- Shared logic for applying border style, change detection, and expiring
-- registration to a border overlay frame. Used by both shared and custom borders.
local function ApplyBorderToOverlay(ch, frame, config, auraData)
    local color = config.color
    if not color then return end

    local r, g, b = color[1] or color.r or 1, color[2] or color.g or 1, color[3] or color.b or 1
    local alpha = color[4] or color.a or 1
    local thickness = config.thickness or 2
    local inset = config.inset or 0

    local style = BORDER_STYLE_MIGRATION[config.style] or config.style or "SOLID"

    local auraID = auraData and auraData.auraInstanceID
    local expiringPulsate = config.expiringPulsate or false
    if ch:IsShown()
        and ch.dfAD_style == style
        and ch.dfAD_r == r and ch.dfAD_g == g and ch.dfAD_b == b and ch.dfAD_a == alpha
        and ch.dfAD_thickness == thickness and ch.dfAD_inset == inset
        and ch.dfAD_auraID == auraID
        and ch.dfAD_expiringPulsate == expiringPulsate then
        return
    end

    DF.ApplyHighlightStyle(ch, style, thickness, inset, r, g, b, alpha)

    ch.dfAD_style = style
    ch.dfAD_r, ch.dfAD_g, ch.dfAD_b, ch.dfAD_a = r, g, b, alpha
    ch.dfAD_thickness = thickness
    ch.dfAD_inset = inset
    ch.dfAD_auraID = auraID

    local expiringEnabled = config.expiringEnabled
    if expiringEnabled == nil then expiringEnabled = false end

    -- Lazy-create pulse animation group (reused across aura changes)
    if expiringPulsate then GetOrCreatePulseAnim(ch) end
    ch.dfAD_expiringPulsate = expiringPulsate

    if expiringEnabled then
        local ec = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
        local oc = {r = r, g = g, b = b}
        RegisterExpiring(ch, {
            unit = frame.unit,
            auraInstanceID = auraID,
            threshold = config.expiringThreshold or 30,
            duration = auraData and auraData.duration,
            expirationTime = auraData and auraData.expirationTime,
            colorCurve = BuildExpiringColorCurve(config.expiringThreshold or 30, ec, oc, config.expiringThresholdMode),
            thresholdMode = config.expiringThresholdMode,
            color = ec, originalColor = oc,
            originalAlpha = alpha, expiringAlpha = config.expiringAlpha or 1.0, style = style, thickness = thickness, inset = inset,
            -- Border expiring callbacks: only the color and alpha change
            -- as the aura approaches expiration. The style/thickness/inset
            -- were fixed when ApplyHighlightStyle was originally called in
            -- the parent function, so every tick here is a pure recolor.
            -- Use UpdateHighlightStyleColor to skip the full tear-down
            -- (especially important for ANIMATED where tearing down hides
            -- 80 dashes, removes from the animator, and re-initializes
            -- everything 3 times per second).
            applyResult = function(el, result, entry)
                local oc2 = entry.originalColor
                local isExp = IsColorExpiring(result, oc2)
                local a = isExp and entry.expiringAlpha or entry.originalAlpha
                DF.UpdateHighlightStyleColor(el, entry.style, result.r, result.g, result.b, a)
                UpdatePulseState(el, isExp)
            end,
            applyManual = function(el, isExp, entry)
                if isExp then
                    local c = entry.color
                    DF.UpdateHighlightStyleColor(el, entry.style, c.r or 1, c.g or 0.2, c.b or 0.2, entry.expiringAlpha)
                else
                    local c = entry.originalColor
                    DF.UpdateHighlightStyleColor(el, entry.style, c.r, c.g, c.b, entry.originalAlpha)
                end
                UpdatePulseState(el, isExp)
            end,
        })
    else
        UnregisterExpiring(ch)
        -- Stop pulsation when expiring is disabled
        if ch.dfAD_pulse and ch.dfAD_pulse:IsPlaying() then
            ch.dfAD_pulse:Stop()
            ch:SetAlpha(1)
        end
    end
end

function Indicators:ApplyBorder(frame, config, auraData, auraName)
    local state = EnsureFrameState(frame)

    if config.borderMode == "custom" and auraName then
        -- Custom border: independent overlay, bypasses shared claim system
        local ch = GetOrCreateCustomBorder(frame, auraName)
        state.activeCustomBorders[auraName] = true
        ApplyBorderToOverlay(ch, frame, config, auraData)
        return
    end

    -- Shared border (default): priority-based, first claim wins
    if state.border then return end
    state.border = true
    local ch = GetOrCreateADBorder(frame)
    ApplyBorderToOverlay(ch, frame, config, auraData)
end

function Indicators:RevertBorder(frame)
    if frame and frame.dfAD_border then
        UnregisterExpiring(frame.dfAD_border)
        -- Use NONE mode to properly clean up all styles (animated, glow, corners, etc.)
        DF.ApplyHighlightStyle(frame.dfAD_border, "NONE", 2, 0, 1, 1, 1, 1)
        -- Clear cached state so next ApplyBorder won't skip via change detection
        frame.dfAD_border.dfAD_style = nil
        frame.dfAD_border.dfAD_auraID = nil
    end
end

function Indicators:RevertCustomBorders(frame)
    if frame and frame.dfAD_customBorders then
        for _, ch in pairs(frame.dfAD_customBorders) do
            UnregisterExpiring(ch)
            DF.ApplyHighlightStyle(ch, "NONE", 2, 0, 1, 1, 1, 1)
            ch.dfAD_style = nil
            ch.dfAD_auraID = nil
        end
    end
end

-- ============================================================
-- HEALTH BAR COLOR
-- Tint mode uses a colored overlay texture instead of arithmetic
-- blending — health bar colors may be secret (tainted) values
-- that cannot be used in Lua math. The blend slider controls
-- the overlay alpha, so the bar color shows through naturally.
-- ============================================================

local function GetOrCreateTintOverlay(frame)
    local state = frame.dfAD
    if state and state.tintOverlay then return state.tintOverlay end

    local healthBar = frame.healthBar
    if not healthBar then return nil end

    -- StatusBar so the fill tracks current health (same pattern as dispel gradient
    -- and buff indicator overlays). Parented to healthBar for proper layering.
    local overlay = CreateFrame("StatusBar", nil, healthBar)
    overlay:SetAllPoints(healthBar)
    overlay:SetFrameLevel(healthBar:GetFrameLevel() + 1)
    local tex = healthBar:GetStatusBarTexture()
    overlay:SetStatusBarTexture(tex and tex:GetTexture() or "Interface\\Buttons\\WHITE8x8")
    overlay:SetMinMaxValues(0, 1)
    overlay:SetValue(1)
    overlay:Hide()

    if state then
        state.tintOverlay = overlay
    end
    return overlay
end

function Indicators:ApplyHealthBar(frame, config, auraData)
    local state = EnsureFrameState(frame)
    if state.healthbar then return end
    state.healthbar = true

    local healthBar = frame.healthBar
    if not healthBar then return end

    local color = config.color
    if not color then return end

    local r, g, b = color[1] or color.r or 1, color[2] or color.g or 1, color[3] or color.b or 1
    local mode = string.lower(config.mode or "replace")
    -- Both modes use the overlay — replace forces full opacity, tint uses blend slider
    local blend = (mode == "replace") and 1 or (config.blend or 0.5)

    local overlay = GetOrCreateTintOverlay(frame)
    if overlay then
        overlay:SetStatusBarColor(r, g, b, blend)
        overlay:Show()
        -- Sync fill with current health
        if DF.UpdateADTintHealth then
            DF:UpdateADTintHealth(frame)
        end
    end

    -- ========================================
    -- EXPIRING: register overlay with ticker
    -- ========================================
    local expiringEnabled = config.expiringEnabled
    if expiringEnabled == nil then expiringEnabled = false end

    local expiringPulsate = config.expiringPulsate or false
    if expiringPulsate then GetOrCreatePulseAnim(overlay) end
    overlay.dfAD_expiringPulsate = expiringPulsate

    if expiringEnabled then
        local ec = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
        local oc = {r = r, g = g, b = b}
        RegisterExpiring(overlay, {
            unit = frame.unit,
            auraInstanceID = auraData and auraData.auraInstanceID,
            threshold = config.expiringThreshold or 30,
            duration = auraData and auraData.duration,
            expirationTime = auraData and auraData.expirationTime,
            blend = blend,
            colorCurve = BuildExpiringColorCurve(config.expiringThreshold or 30, ec, oc, config.expiringThresholdMode),
            thresholdMode = config.expiringThresholdMode,
            color = ec, originalColor = oc,
            applyResult = function(el, result, entry)
                el:SetStatusBarColor(result.r, result.g, result.b, entry.blend)
                local oc2 = entry.originalColor
                local isExp = IsColorExpiring(result, oc2)
                UpdatePulseState(el, isExp)
            end,
            applyManual = function(el, isExp, entry)
                local c = isExp and entry.color or entry.originalColor
                el:SetStatusBarColor(c.r or 1, c.g or 1, c.b or 1, entry.blend)
                UpdatePulseState(el, isExp)
            end,
        })
    elseif overlay then
        UnregisterExpiring(overlay)
        if overlay.dfAD_pulse and overlay.dfAD_pulse:IsPlaying() then
            overlay.dfAD_pulse:Stop()
            overlay:SetAlpha(1)
        end
    end
end

function Indicators:RevertHealthBar(frame)
    local state = frame and frame.dfAD
    if not state then return end

    -- Hide overlay and unregister its expiring ticker
    if state.tintOverlay then
        UnregisterExpiring(state.tintOverlay)
        if state.tintOverlay.dfAD_pulse and state.tintOverlay.dfAD_pulse:IsPlaying() then
            state.tintOverlay.dfAD_pulse:Stop()
            state.tintOverlay:SetAlpha(1)
        end
        state.tintOverlay:Hide()
    end

    -- Refresh health bar color so the bar shows the correct color
    -- (class color, custom color, etc.) after the overlay is removed.
    -- This also handles the login edge case where the bar may not
    -- have been fully colored before the overlay was first applied.
    if DF.UpdateHealthBarAppearance then
        DF:UpdateHealthBarAppearance(frame)
    end
end

-- Update tint overlay fill to match current health.
-- Called from UpdateUnitFrame and UpdateHealthFast (same pattern as
-- DF:UpdateDispelGradientHealth and DF:UpdateMyBuffGradientHealth).
function DF:UpdateADTintHealth(frame)
    if not frame or not frame.dfAD then return end

    local overlay = frame.dfAD.tintOverlay
    if not overlay or not overlay:IsShown() then return end

    local unit = frame.unit
    if not unit or not UnitExists(unit) then return end

    local db = DF:GetFrameDB(frame)

    -- Match health bar orientation and fill direction
    local orient = db and db.healthOrientation or "HORIZONTAL"
    if orient == "HORIZONTAL" then
        overlay:SetOrientation("HORIZONTAL")
        overlay:SetReverseFill(false)
    elseif orient == "HORIZONTAL_INV" then
        overlay:SetOrientation("HORIZONTAL")
        overlay:SetReverseFill(true)
    elseif orient == "VERTICAL" then
        overlay:SetOrientation("VERTICAL")
        overlay:SetReverseFill(false)
    elseif orient == "VERTICAL_INV" then
        overlay:SetOrientation("VERTICAL")
        overlay:SetReverseFill(true)
    end

    -- StatusBar API handles secret values internally
    local maxHealth = UnitHealthMax(unit)
    local currentHealth = UnitHealth(unit, true)

    overlay:SetMinMaxValues(0, maxHealth)

    local smoothEnabled = db and db.smoothBars
    if smoothEnabled and Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut then
        overlay:SetValue(currentHealth, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        overlay:SetValue(currentHealth)
    end
end

-- ============================================================
-- NAME TEXT COLOR
-- ============================================================

function Indicators:ApplyNameText(frame, config, auraData)
    local state = EnsureFrameState(frame)
    if state.nametext then return end
    state.nametext = true

    local nameText = frame.nameText
    if not nameText then return end

    -- Save original color on first use
    if not state.savedNameColor then
        local r, g, b, a = nameText:GetTextColor()
        state.savedNameColor = { r = r, g = g, b = b, a = a }
    end

    local color = config.color
    if color then
        local r, g, b = color[1] or color.r or 1, color[2] or color.g or 1, color[3] or color.b or 1
        nameText:SetTextColor(r, g, b, 1)

        -- ========================================
        -- EXPIRING: register with shared ticker
        -- ========================================
        local expiringEnabled = config.expiringEnabled
        if expiringEnabled == nil then expiringEnabled = false end
        if expiringEnabled then
            local ec = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
            local oc = {r = r, g = g, b = b}
            RegisterExpiring(nameText, {
                unit = frame.unit,
                auraInstanceID = auraData and auraData.auraInstanceID,
                threshold = config.expiringThreshold or 30,
                duration = auraData and auraData.duration,
                expirationTime = auraData and auraData.expirationTime,
                colorCurve = BuildExpiringColorCurve(config.expiringThreshold or 30, ec, oc, config.expiringThresholdMode),
            thresholdMode = config.expiringThresholdMode,
                color = ec, originalColor = oc,
                applyResult = function(el, result, entry)
                    el:SetTextColor(result.r, result.g, result.b, result.a or 1)
                end,
                applyManual = function(el, isExp, entry)
                    if isExp then
                        local c = entry.color
                        el:SetTextColor(c.r or 1, c.g or 0.2, c.b or 0.2, 1)
                    else
                        local c = entry.originalColor
                        el:SetTextColor(c.r, c.g, c.b, 1)
                    end
                end,
            })
        else
            UnregisterExpiring(nameText)
        end
    end
end

function Indicators:RevertNameText(frame)
    local state = frame and frame.dfAD
    if not state or not state.savedNameColor then return end

    local nameText = frame.nameText
    if not nameText then return end

    UnregisterExpiring(nameText)
    local c = state.savedNameColor
    nameText:SetTextColor(c.r, c.g, c.b, c.a)
    state.savedNameColor = nil  -- Re-capture next time
end

-- ============================================================
-- HEALTH TEXT COLOR
-- ============================================================

function Indicators:ApplyHealthText(frame, config, auraData)
    local state = EnsureFrameState(frame)
    if state.healthtext then return end
    state.healthtext = true

    local healthText = frame.healthText
    if not healthText then return end

    -- Save original color on first use
    if not state.savedHealthTextColor then
        local r, g, b, a = healthText:GetTextColor()
        state.savedHealthTextColor = { r = r, g = g, b = b, a = a }
    end

    local color = config.color
    if color then
        local r, g, b = color[1] or color.r or 1, color[2] or color.g or 1, color[3] or color.b or 1
        healthText:SetTextColor(r, g, b, 1)

        -- ========================================
        -- EXPIRING: register with shared ticker
        -- ========================================
        local expiringEnabled = config.expiringEnabled
        if expiringEnabled == nil then expiringEnabled = false end
        if expiringEnabled then
            local ec = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
            local oc = {r = r, g = g, b = b}
            RegisterExpiring(healthText, {
                unit = frame.unit,
                auraInstanceID = auraData and auraData.auraInstanceID,
                threshold = config.expiringThreshold or 30,
                duration = auraData and auraData.duration,
                expirationTime = auraData and auraData.expirationTime,
                colorCurve = BuildExpiringColorCurve(config.expiringThreshold or 30, ec, oc, config.expiringThresholdMode),
            thresholdMode = config.expiringThresholdMode,
                color = ec, originalColor = oc,
                applyResult = function(el, result, entry)
                    el:SetTextColor(result.r, result.g, result.b, result.a or 1)
                end,
                applyManual = function(el, isExp, entry)
                    if isExp then
                        local c = entry.color
                        el:SetTextColor(c.r or 1, c.g or 0.2, c.b or 0.2, 1)
                    else
                        local c = entry.originalColor
                        el:SetTextColor(c.r, c.g, c.b, 1)
                    end
                end,
            })
        else
            UnregisterExpiring(healthText)
        end
    end
end

function Indicators:RevertHealthText(frame)
    local state = frame and frame.dfAD
    if not state or not state.savedHealthTextColor then return end

    local healthText = frame.healthText
    if not healthText then return end

    UnregisterExpiring(healthText)
    local c = state.savedHealthTextColor
    healthText:SetTextColor(c.r, c.g, c.b, c.a)
    state.savedHealthTextColor = nil
end

-- ============================================================
-- FRAME ALPHA
-- ============================================================

function Indicators:ApplyFrameAlpha(frame, config, auraData)
    local state = EnsureFrameState(frame)
    if state.framealpha then return end
    state.framealpha = true

    -- Save original alpha on first use
    if not state.savedAlpha then
        state.savedAlpha = frame:GetAlpha()
    end

    local alpha = config.alpha
    if alpha then
        frame:SetAlpha(alpha)
    end

    -- ========================================
    -- EXPIRING: register with shared ticker
    -- ========================================
    local expiringEnabled = config.expiringEnabled
    if expiringEnabled == nil then expiringEnabled = false end
    if expiringEnabled then
        local expiringAlpha = config.expiringAlpha or 1.0
        local originalAlpha = alpha or (state.savedAlpha or 1.0)
        -- Encode alpha values in the R channel of a color curve
        local ec = {r = expiringAlpha, g = 0, b = 0}
        local oc = {r = originalAlpha, g = 0, b = 0}
        RegisterExpiring(frame, {
            unit = frame.unit,
            auraInstanceID = auraData and auraData.auraInstanceID,
            threshold = config.expiringThreshold or 30,
            duration = auraData and auraData.duration,
            expirationTime = auraData and auraData.expirationTime,
            colorCurve = BuildExpiringColorCurve(config.expiringThreshold or 30, ec, oc, config.expiringThresholdMode),
            thresholdMode = config.expiringThresholdMode,
            expiringAlpha = expiringAlpha,
            originalAlpha = originalAlpha,
            applyResult = function(el, result, entry)
                -- Alpha encoded in R channel of the curve
                el:SetAlpha(result.r)
            end,
            applyManual = function(el, isExp, entry)
                if isExp then
                    el:SetAlpha(entry.expiringAlpha)
                else
                    el:SetAlpha(entry.originalAlpha)
                end
            end,
        })
    else
        UnregisterExpiring(frame)
    end
end

function Indicators:RevertFrameAlpha(frame)
    local state = frame and frame.dfAD
    if not state or not state.savedAlpha then return end

    UnregisterExpiring(frame)
    frame:SetAlpha(state.savedAlpha)
    state.savedAlpha = nil
end

-- ============================================================
-- PLACED INDICATORS -- ICON
-- One icon per aura at its configured anchor point.
-- Uses DF:CreateAuraIcon() for full expiring indicator,
-- duration text, stack count, and cooldown swipe support.
-- ============================================================

-- Get or create the icon map for a frame: { [auraName] = icon }
local function GetIconMap(frame)
    if not frame.dfAD_icons then
        frame.dfAD_icons = {}
    end
    return frame.dfAD_icons
end

local function GetOrCreateADIcon(frame, auraName)
    local map = GetIconMap(frame)
    if map[auraName] then return map[auraName] end

    -- Use the same icon creation as the rest of the addon
    local icon = DF:CreateAuraIcon(frame, 0, "BUFF")
    icon.dfAD_auraName = auraName

    -- Store default settings for the aura timer system
    icon.showDuration = true
    icon.durationColorByTime = true
    icon.durationAnchor = "CENTER"
    icon.durationX = 0
    icon.durationY = 0
    icon.stackMinimum = 2

    map[auraName] = icon
    return icon
end

-- ============================================================
-- ConfigureIcon: static config-driven properties (called once per config change)
-- Sets size, strata, border, fonts, propagation — anything that
-- does NOT depend on per-event aura data.
-- ============================================================
function Indicators:ConfigureIcon(frame, config, defaults, auraName, priority)
    local icon = GetOrCreateADIcon(frame, auraName)

    -- Size (clamp to 8 minimum; old configs may have sizes below the current slider floor)
    local size = math.max(8, config.size or (defaults and defaults.iconSize) or 24)
    local scale = config.scale or (defaults and defaults.iconScale) or 1.0
    icon:SetSize(size, size)
    icon:SetScale(scale)

    -- Alpha
    local iconAlpha = config.alpha or 1.0
    icon.dfBaseAlpha = iconAlpha
    icon:SetAlpha(iconAlpha)

    -- Frame level: base from frame (not contentOverlay) + per-indicator level + small priority tiebreaker
    local level = config.frameLevel or (defaults and defaults.indicatorFrameLevel) or 2
    local baseLevel = frame:GetFrameLevel()
    local priorityBoost = math.floor((20 - (priority or 5)) / 4)  -- 0-5 range for tiebreaking
    icon:SetFrameLevel(math.max(0, baseLevel + level + priorityBoost))

    -- Frame strata: per-indicator override, falls back to global default
    local strata = config.frameStrata or (defaults and defaults.indicatorFrameStrata) or "HIGH"
    if strata ~= "INHERIT" then
        SafeSetFrameStrata(icon, frame, strata)
    else
        icon:SetFrameStrata(frame:GetFrameStrata())
    end

    -- Hide Icon (text-only mode) flag — stored for UpdateIcon to read
    local hideIcon = config.hideIcon; if hideIcon == nil then hideIcon = defaults and defaults.hideIcon end
    icon.dfAD_hideIcon = hideIcon

    -- ========================================
    -- BORDER (the black background behind the icon texture)
    -- ========================================
    local borderEnabled = config.borderEnabled
    if borderEnabled == nil then borderEnabled = true end
    local borderThickness = config.borderThickness or 1
    local borderInset = config.borderInset or 1

    if icon.border then
        if borderEnabled and not hideIcon then
            icon.border:ClearAllPoints()
            PixelUtil.SetPoint(icon.border, "TOPLEFT", icon, "TOPLEFT", -borderInset, borderInset)
            PixelUtil.SetPoint(icon.border, "BOTTOMRIGHT", icon, "BOTTOMRIGHT", borderInset, -borderInset)
            icon.border:SetColorTexture(0, 0, 0, 0.8)
            icon.border:Show()
        else
            icon.border:Hide()
        end
    end

    -- Adjust texture inset to sit inside border
    if icon.texture and not hideIcon then
        icon.texture:ClearAllPoints()
        local texInset = borderEnabled and borderThickness or 0
        icon.texture:SetPoint("TOPLEFT", texInset, -texInset)
        icon.texture:SetPoint("BOTTOMRIGHT", -texInset, texInset)
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    -- ========================================
    -- STACK COUNT — font/style configuration
    -- ========================================
    local showStacks = config.showStacks
    if showStacks == nil then showStacks = true end
    local stackMin = config.stackMinimum or 2
    icon.stackMinimum = stackMin
    icon.dfAD_showStacks = showStacks

    -- Stack font/style (instance → global defaults → hardcoded)
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

    -- ========================================
    -- DURATION TEXT — font/style/flags configuration
    -- ========================================
    local showDuration = config.showDuration
    if showDuration == nil then showDuration = true end
    local durationFont = config.durationFont or (defaults and defaults.durationFont) or "Fonts\\FRIZQT__.TTF"
    local durationScale = config.durationScale or (defaults and defaults.durationScale) or 1.0
    local durationOutline = config.durationOutline or (defaults and defaults.durationOutline) or "OUTLINE"
    if durationOutline == "NONE" then durationOutline = "" end
    local durationAnchor = config.durationAnchor or (defaults and defaults.durationAnchor) or "CENTER"
    local durationX = config.durationX; if durationX == nil then durationX = defaults and defaults.durationX end; if durationX == nil then durationX = 0 end
    local durationY = config.durationY; if durationY == nil then durationY = defaults and defaults.durationY end; if durationY == nil then durationY = 0 end
    local durationColorByTime = config.durationColorByTime
    if durationColorByTime == nil then
        durationColorByTime = (defaults and defaults.durationColorByTime)
        if durationColorByTime == nil then durationColorByTime = true end
    end

    local durationHideAboveEnabled = config.durationHideAboveEnabled
    if durationHideAboveEnabled == nil then durationHideAboveEnabled = (defaults and defaults.durationHideAboveEnabled) or false end
    local durationHideAboveThreshold = config.durationHideAboveThreshold or (defaults and defaults.durationHideAboveThreshold) or 10

    -- Store duration config on icon for UpdateIcon to read
    icon.showDuration = showDuration
    icon.durationColorByTime = durationColorByTime
    icon.durationAnchor = durationAnchor
    icon.durationX = durationX
    icon.durationY = durationY
    icon.durationHideAboveEnabled = durationHideAboveEnabled
    icon.durationHideAboveThreshold = durationHideAboveThreshold
    icon.dfAD_durationFont = durationFont
    icon.dfAD_durationScale = durationScale
    icon.dfAD_durationOutline = durationOutline
    icon.cooldown:SetHideCountdownNumbers(not showDuration)

    -- Find native cooldown text if not yet cached (same scan as the shared timer)
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

    -- Create duration hide wrapper + reparent native text + style + position
    if icon.nativeCooldownText then
        if showDuration then
            -- Reparent to a wrapper frame so we can control visibility via the
            -- wrapper's alpha.  Blizzard's CooldownFrame resets both SetTextColor
            -- alpha AND SetAlpha on its own FontString every frame, so the only
            -- reliable way to hide the text is a parent-level alpha override.
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
            icon.nativeCooldownText:Show()
        else
            icon.nativeCooldownText:Hide()
        end
    end

    -- ========================================
    -- EXPIRING — animation frame creation + config flags
    -- ========================================
    local expiringEnabled = config.expiringEnabled
    if expiringEnabled == nil then expiringEnabled = false end
    local expiringPulsate = config.expiringPulsate or false

    -- Lazy-create a wrapper frame for the border texture so we can animate its alpha
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
        if icon.adBorderPulseFrame.dfAD_pulse and icon.adBorderPulseFrame.dfAD_pulse:IsPlaying() then
            icon.adBorderPulseFrame.dfAD_pulse:Stop()
            icon.adBorderPulseFrame:SetAlpha(1)
        end
    end

    -- Whole-alpha pulse: animates the entire icon frame's alpha
    local expiringWholeAlphaPulse = config.expiringWholeAlphaPulse or false
    if expiringWholeAlphaPulse then GetOrCreateWholeAlphaPulse(icon) end
    icon.dfAD_expiringWholeAlphaPulse = expiringWholeAlphaPulse
    if not expiringWholeAlphaPulse and icon.dfAD_wholeAlphaPulse and icon.dfAD_wholeAlphaPulse:IsPlaying() then
        icon.dfAD_wholeAlphaPulse:Stop()
        icon:SetAlpha(1)
    end

    -- Bounce: animates the icon frame position up and down
    local expiringBounce = config.expiringBounce or false
    if expiringBounce then GetOrCreateBounceAnim(icon) end
    icon.dfAD_expiringBounce = expiringBounce
    if not expiringBounce and icon.dfAD_bounceAnim and icon.dfAD_bounceAnim:IsPlaying() then
        icon.dfAD_bounceAnim:Stop()
    end

    -- Store expiring config flags for UpdateIcon to read
    icon.dfAD_expiringEnabled = expiringEnabled
    icon.dfAD_expiringColor = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
    icon.dfAD_expiringThreshold = config.expiringThreshold or 30
    icon.dfAD_expiringThresholdMode = config.expiringThresholdMode
    icon.dfAD_expiringPulsate = expiringPulsate

    -- Missing-mode config
    icon.dfAD_missingDesaturate = config.missingDesaturate

    -- Mouse handling: propagate motion/clicks to parent for tooltips and click-casting
    -- Guarded because SetPropagateMouseMotion/Clicks are protected in combat.
    -- Pre-warm ensures this runs outside combat for all configured indicators.
    if not InCombatLockdown() then
        if icon.SetPropagateMouseMotion then
            icon:SetPropagateMouseMotion(true)
        end
        if icon.SetPropagateMouseClicks then
            icon:SetPropagateMouseClicks(true)
        end
        if icon.SetMouseClickEnabled then
            icon:SetMouseClickEnabled(false)
        end
    end

    -- Stamp config version so we know when to re-configure
    icon.dfAD_configVersion = DF.adConfigVersion or 0
end

-- ============================================================
-- UpdateIcon: dynamic aura-data-driven properties (called every UNIT_AURA)
-- Sets texture, cooldown, stacks, duration text, expiring registration,
-- and position (position is dynamic because layout groups compute offsets
-- per-event based on which group members are active).
-- ============================================================
function Indicators:UpdateIcon(frame, config, auraData, defaults, auraName, priority)
    local state = EnsureFrameState(frame)
    state.activeIcons[auraName] = true

    local icon = GetOrCreateADIcon(frame, auraName)

    -- Store aura data for tooltip lookups (parent-driven via ShowDFAuraTooltip)
    if auraData then
        if not icon.auraData then
            icon.auraData = { auraInstanceID = nil }
        end
        icon.auraData.auraInstanceID = auraData.auraInstanceID
    end

    -- Position — each aura has its own anchor, no growth
    -- Position is dynamic because layout groups compute offsets per-event
    local anchor = config.anchor or "TOPLEFT"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or 0
    -- Compensate for border overhang at frame edges
    local borderEnabledForPos = config.borderEnabled
    if borderEnabledForPos == nil then borderEnabledForPos = true end
    offsetX, offsetY = AdjustOffsetForBorder(anchor, offsetX, offsetY, config.borderInset or 1, borderEnabledForPos)
    icon:ClearAllPoints()
    icon:SetPoint(anchor, frame, anchor, offsetX, offsetY)

    -- Read stored config flags from ConfigureIcon
    local hideIcon = icon.dfAD_hideIcon

    -- Texture
    if not hideIcon then
        if auraData.icon then
            SafeSetTexture(icon, auraData.icon)
        elseif auraData.spellId and not issecretvalue(auraData.spellId) and C_Spell and C_Spell.GetSpellTexture then
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

    -- Cooldown — uses Duration object pipeline (secret-safe)
    local hideSwipe = config.hideSwipe; if hideSwipe == nil then hideSwipe = defaults and defaults.hideSwipe end
    local hasDuration = HasAuraDuration(auraData, frame.unit)
    if hasDuration then
        SafeSetCooldown(icon.cooldown, auraData, frame.unit)
        -- Retry lazy FontString scan — SetCooldown forces Blizzard to create it
        if EnsureNativeCooldownText(icon, icon.cooldown) then
            ApplyDeferredDurationStyling(icon)
        end
        icon.cooldown:SetDrawSwipe(not hideSwipe and not hideIcon)
        icon.cooldown:Show()
    else
        icon.cooldown:SetDrawSwipe(false)
        icon.cooldown:Hide()
        -- Clear stale countdown text (may persist if reparented to durationHideWrapper)
        if icon.nativeCooldownText then
            icon.nativeCooldownText:SetText("")
            icon.nativeCooldownText:Hide()
        end
    end

    -- ========================================
    -- STACK COUNT — dynamic display
    -- ========================================
    if icon.count then
        icon.count:SetText("")
        icon.count:Hide()
        if icon.dfAD_showStacks then
            local unit = frame.unit
            local auraInstanceID = auraData.auraInstanceID
            local stackMin = icon.stackMinimum
            if unit and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
                -- Blizzard API: returns pre-formatted display text, handles secrets
                local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, stackMin, 99)
                if stackText then
                    icon.count:SetText(stackText)
                    icon.count:Show()
                end
            elseif auraData.stacks then
                -- Fallback for preview (no unit/auraInstanceID)
                if not issecretvalue(auraData.stacks) and auraData.stacks >= stackMin then
                    icon.count:SetText(auraData.stacks)
                    icon.count:Show()
                end
            end
        end
    end

    -- ========================================
    -- DURATION TEXT — dynamic visibility + color
    -- ========================================
    local showDuration = icon.showDuration
    local durationColorByTime = icon.durationColorByTime
    local durationHideAboveEnabled = icon.durationHideAboveEnabled
    local durationHideAboveThreshold = icon.durationHideAboveThreshold

    if icon.nativeCooldownText then
        if showDuration then
            icon.nativeCooldownText:Show()

            -- Compute hide-above alpha (initial evaluation)
            local hideAlpha = 1
            if durationHideAboveEnabled and hasDuration then
                local usedHideAPI = false
                if frame.unit and auraData.auraInstanceID
                   and C_UnitAuras and C_UnitAuras.GetAuraDuration then
                    local dObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
                    if dObj and dObj.EvaluateRemainingDuration then
                        local hideCurve = BuildDurationHideCurve(durationHideAboveThreshold)
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
                        hideAlpha = remaining > durationHideAboveThreshold and 0 or 1
                    end
                end
            end

            -- Apply hide-above alpha on the wrapper frame (immune to Blizzard resets)
            if icon.durationHideWrapper then
                icon.durationHideWrapper:SetAlpha(hideAlpha)
            end

            -- Color by remaining time (green → yellow → orange → red)
            if durationColorByTime and hasDuration then
                local usedAPI = false
                -- API path: works with secret values (in combat)
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
                -- Manual fallback for preview (non-secret values)
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

            -- Register wrapper for ongoing hide-above alpha updates via the shared ticker
            -- Temporarily suppress hideWhenNotExpiring so the wrapper doesn't get it
            -- (wrapper has its own threshold logic, not the expiring threshold)
            local savedHWNE = pendingHideWhenNotExpiring
            pendingHideWhenNotExpiring = false
            if durationHideAboveEnabled and hasDuration and icon.durationHideWrapper then
                local hideCurve = BuildDurationHideCurve(durationHideAboveThreshold)
                if hideCurve then
                    RegisterExpiring(icon.durationHideWrapper, {
                        unit = frame.unit,
                        auraInstanceID = auraData and auraData.auraInstanceID,
                        threshold = durationHideAboveThreshold,
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
            pendingHideWhenNotExpiring = savedHWNE  -- Restore for main registration
        else
            icon.nativeCooldownText:Hide()
        end
    end

    -- ========================================
    -- EXPIRING — register with shared ticker (uses stored config flags)
    -- ========================================
    local expiringEnabled = icon.dfAD_expiringEnabled
    local expiringPulsate = icon.dfAD_expiringPulsate
    local expiringWholeAlphaPulse = icon.dfAD_expiringWholeAlphaPulse
    local expiringBounce = icon.dfAD_expiringBounce

    -- Register if ANY expiring feature is active (color, pulsate, alpha pulse, bounce)
    local anyExpiringFeature = expiringEnabled or expiringPulsate or expiringWholeAlphaPulse or expiringBounce
    if anyExpiringFeature then
        local ec = icon.dfAD_expiringColor
        local oc = {r = 0, g = 0, b = 0}  -- icon border default = black
        local applyColor = expiringEnabled
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
                -- applyResult only fires when colorCurve is set (i.e. applyColor = true)
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
            icon:SetAlpha(1)
        end
        if icon.dfAD_bounceAnim and icon.dfAD_bounceAnim:IsPlaying() then
            icon.dfAD_bounceAnim:Stop()
        end
    end

    icon:Show()
end

function Indicators:HideUnusedIcons(frame, activeMap)
    local map = frame and frame.dfAD_icons
    if not map then return end
    for auraName, icon in pairs(map) do
        if not activeMap[auraName] then
            UnregisterExpiring(icon)
            icon:Hide()
            -- Clear stale aura data (matches bar cleanup pattern)
            if icon.auraData then
                icon.auraData.auraInstanceID = nil
            end
            if icon.cooldown then
                icon.cooldown:Hide()
            end
            if icon.count then
                icon.count:SetText("")
            end
        end
    end
end

-- ============================================================
-- PLACED INDICATORS -- SQUARE
-- One colored square per aura at its configured anchor point.
-- ============================================================

local function GetSquareMap(frame)
    if not frame.dfAD_squares then
        frame.dfAD_squares = {}
    end
    return frame.dfAD_squares
end

local function CreateADSquare(frame, auraName)
    local sq = CreateFrame("Frame", nil, frame.contentOverlay or frame)
    sq:SetSize(8, 8)
    sq:SetFrameLevel((frame.contentOverlay or frame):GetFrameLevel() + 10)
    sq.dfAD_auraName = auraName

    sq.border = sq:CreateTexture(nil, "BACKGROUND")
    sq.border:SetAllPoints()
    sq.border:SetColorTexture(0, 0, 0, 1)

    sq.texture = sq:CreateTexture(nil, "ARTWORK")
    sq.texture:SetPoint("TOPLEFT", 1, -1)
    sq.texture:SetPoint("BOTTOMRIGHT", -1, 1)

    -- Cooldown (swipe effect) — same setup as DF:CreateAuraIcon
    sq.cooldown = CreateFrame("Cooldown", nil, sq, "CooldownFrameTemplate")
    sq.cooldown:SetAllPoints(sq.texture)
    sq.cooldown:SetDrawEdge(false)
    sq.cooldown:SetDrawSwipe(true)
    sq.cooldown:SetReverse(true)
    sq.cooldown:SetHideCountdownNumbers(false)

    -- Text overlay above the cooldown swipe for stacks + duration
    sq.textOverlay = CreateFrame("Frame", nil, sq)
    sq.textOverlay:SetAllPoints(sq)
    sq.textOverlay:SetFrameLevel(sq.cooldown:GetFrameLevel() + 5)
    sq.textOverlay:EnableMouse(false)

    -- Stack count (on textOverlay so it draws above swipe)
    sq.count = sq.textOverlay:CreateFontString(nil, "OVERLAY")
    sq.count:SetFontObject(GameFontNormal)
    sq.count:SetPoint("CENTER", 0, 0)
    sq.count:SetTextColor(1, 1, 1)

    sq:Hide()
    return sq
end

local function GetOrCreateADSquare(frame, auraName)
    local map = GetSquareMap(frame)
    if map[auraName] then return map[auraName] end
    local sq = CreateADSquare(frame, auraName)
    map[auraName] = sq
    return sq
end

-- ============================================================
-- ConfigureSquare: static config applied once per config change
-- Sets size, scale, alpha, frame level/strata, border, color,
-- stack/duration font & style, expiring animation setup, and
-- mouse propagation.  Mirrors the ConfigureIcon pattern.
-- ============================================================
function Indicators:ConfigureSquare(frame, config, defaults, auraName, priority)
    local sq = GetOrCreateADSquare(frame, auraName)

    -- Size & scale (fall back to global defaults, same as icon)
    local size = config.size or (defaults and defaults.iconSize) or 24
    local scale = config.scale or (defaults and defaults.iconScale) or 1.0
    sq:SetSize(size, size)
    sq:SetScale(scale)

    -- Alpha
    local sqAlpha = config.alpha or 1.0
    sq.dfBaseAlpha = sqAlpha
    sq:SetAlpha(sqAlpha)

    -- Frame level: base from frame (not contentOverlay) + per-indicator level + small priority tiebreaker
    local level = config.frameLevel or (defaults and defaults.indicatorFrameLevel) or 2
    local baseLevel = frame:GetFrameLevel()
    local priorityBoost = math.floor((20 - (priority or 5)) / 4)  -- 0-5 range for tiebreaking
    sq:SetFrameLevel(math.max(0, baseLevel + level + priorityBoost))

    -- Frame strata: per-indicator override, falls back to global default
    local strata = config.frameStrata or (defaults and defaults.indicatorFrameStrata) or "HIGH"
    if strata ~= "INHERIT" then
        SafeSetFrameStrata(sq, frame, strata)
    else
        sq:SetFrameStrata(frame:GetFrameStrata())
    end

    -- Hide Icon (text-only mode) — stored for UpdateSquare to read
    local hideIcon = config.hideIcon; if hideIcon == nil then hideIcon = defaults and defaults.hideIcon end
    sq.dfAD_hideIcon = hideIcon

    -- ========================================
    -- BORDER
    -- ========================================
    local showBorder = config.showBorder
    if showBorder == nil then showBorder = true end
    local borderThickness = config.borderThickness or 1
    local borderInset = config.borderInset or 1

    if showBorder and not hideIcon then
        sq.border:ClearAllPoints()
        PixelUtil.SetPoint(sq.border, "TOPLEFT", sq, "TOPLEFT", -borderInset, borderInset)
        PixelUtil.SetPoint(sq.border, "BOTTOMRIGHT", sq, "BOTTOMRIGHT", borderInset, -borderInset)
        sq.border:SetColorTexture(0, 0, 0, 1)
        sq.border:Show()
    else
        sq.border:Hide()
    end

    -- Adjust texture inset to sit inside border
    if not hideIcon then
        sq.texture:ClearAllPoints()
        local texInset = showBorder and borderThickness or 0
        sq.texture:SetPoint("TOPLEFT", texInset, -texInset)
        sq.texture:SetPoint("BOTTOMRIGHT", -texInset, texInset)
    end

    -- Color (static config)
    local color = config.color
    if not hideIcon then
        if color then
            sq.texture:SetColorTexture(color[1] or color.r or 1, color[2] or color.g or 1, color[3] or color.b or 1, 1)
        else
            sq.texture:SetColorTexture(1, 1, 1, 1)
        end
        sq.texture:Show()
    else
        sq.texture:Hide()
    end

    -- ========================================
    -- STACK COUNT — font/style configuration
    -- ========================================
    local showStacks = config.showStacks
    if showStacks == nil then showStacks = true end
    local stackMin = config.stackMinimum or 2
    sq.stackMinimum = stackMin
    sq.dfAD_showStacks = showStacks

    local stackFont = config.stackFont or (defaults and defaults.stackFont) or "Fonts\\FRIZQT__.TTF"
    local stackScale = config.stackScale or (defaults and defaults.stackScale) or 1.0
    local stackOutline = config.stackOutline or (defaults and defaults.stackOutline) or "OUTLINE"
    if stackOutline == "NONE" then stackOutline = "" end
    local stackAnchor = config.stackAnchor or (defaults and defaults.stackAnchor) or "BOTTOMRIGHT"
    local stackX = config.stackX; if stackX == nil then stackX = defaults and defaults.stackX end; if stackX == nil then stackX = 0 end
    local stackY = config.stackY; if stackY == nil then stackY = defaults and defaults.stackY end; if stackY == nil then stackY = 0 end

    if sq.count then
        local stackSize = 10 * stackScale
        DF:SafeSetFont(sq.count, stackFont, stackSize, stackOutline)
        sq.count:ClearAllPoints()
        sq.count:SetPoint(stackAnchor, sq, stackAnchor, stackX, stackY)
        local stackColor = config.stackColor or (defaults and defaults.stackColor)
        if stackColor then
            sq.count:SetTextColor(stackColor.r or 1, stackColor.g or 1, stackColor.b or 1, stackColor.a or 1)
        else
            sq.count:SetTextColor(1, 1, 1, 1)
        end
    end

    -- ========================================
    -- DURATION TEXT — font/style/flags configuration
    -- ========================================
    local showDuration = config.showDuration
    if showDuration == nil then showDuration = true end
    local durationFont = config.durationFont or (defaults and defaults.durationFont) or "Fonts\\FRIZQT__.TTF"
    local durationScale = config.durationScale or (defaults and defaults.durationScale) or 1.0
    local durationOutline = config.durationOutline or (defaults and defaults.durationOutline) or "OUTLINE"
    if durationOutline == "NONE" then durationOutline = "" end
    local durationAnchor = config.durationAnchor or (defaults and defaults.durationAnchor) or "CENTER"
    local durationX = config.durationX; if durationX == nil then durationX = defaults and defaults.durationX end; if durationX == nil then durationX = 0 end
    local durationY = config.durationY; if durationY == nil then durationY = defaults and defaults.durationY end; if durationY == nil then durationY = 0 end
    local durationColorByTime = config.durationColorByTime
    if durationColorByTime == nil then
        durationColorByTime = (defaults and defaults.durationColorByTime)
        if durationColorByTime == nil then durationColorByTime = true end
    end

    local durationHideAboveEnabled = config.durationHideAboveEnabled
    if durationHideAboveEnabled == nil then durationHideAboveEnabled = (defaults and defaults.durationHideAboveEnabled) or false end
    local durationHideAboveThreshold = config.durationHideAboveThreshold or (defaults and defaults.durationHideAboveThreshold) or 10

    -- Store duration config on square for UpdateSquare to read
    sq.showDuration = showDuration
    sq.durationColorByTime = durationColorByTime
    sq.durationAnchor = durationAnchor
    sq.durationX = durationX
    sq.durationY = durationY
    sq.durationHideAboveEnabled = durationHideAboveEnabled
    sq.durationHideAboveThreshold = durationHideAboveThreshold
    sq.dfAD_durationFont = durationFont
    sq.dfAD_durationScale = durationScale
    sq.dfAD_durationOutline = durationOutline

    if sq.cooldown then
        sq.cooldown:SetHideCountdownNumbers(not showDuration)
    end

    -- Find native cooldown text if not yet cached (same region scan as icons)
    if not sq.nativeCooldownText and sq.cooldown then
        local regions = { sq.cooldown:GetRegions() }
        for _, region in pairs(regions) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                sq.nativeCooldownText = region
                sq.nativeTextReparented = false
                break
            end
        end
    end

    -- Create duration hide wrapper + reparent native text + style + position
    if sq.nativeCooldownText then
        if showDuration then
            if not sq.durationHideWrapper and sq.textOverlay then
                sq.durationHideWrapper = CreateFrame("Frame", nil, sq.textOverlay)
                sq.durationHideWrapper:SetAllPoints(sq.textOverlay)
                sq.durationHideWrapper:SetFrameLevel(sq.textOverlay:GetFrameLevel())
                sq.durationHideWrapper:EnableMouse(false)
            end
            if not sq.nativeTextReparented and sq.durationHideWrapper then
                sq.nativeCooldownText:SetParent(sq.durationHideWrapper)
                sq.nativeTextReparented = true
            end
            -- Style
            local durationSize = 10 * durationScale
            DF:SafeSetFont(sq.nativeCooldownText, durationFont, durationSize, durationOutline)
            -- Position
            sq.nativeCooldownText:ClearAllPoints()
            sq.nativeCooldownText:SetPoint(durationAnchor, sq, durationAnchor, durationX, durationY)
            sq.nativeCooldownText:Show()
        else
            sq.nativeCooldownText:Hide()
        end
    end

    -- ========================================
    -- EXPIRING — animation frame creation + config flags
    -- ========================================
    local expiringEnabled = config.expiringEnabled
    if expiringEnabled == nil then expiringEnabled = false end
    local expiringPulsate = config.expiringPulsate or false

    -- Lazy-create a wrapper frame for the fill texture so we can animate its alpha
    if expiringPulsate and sq.texture then
        if not sq.adFillPulseFrame then
            sq.adFillPulseFrame = CreateFrame("Frame", nil, sq)
            sq.adFillPulseFrame:SetAllPoints(sq)
            sq.adFillPulseFrame:SetFrameLevel(sq:GetFrameLevel())
            sq.adFillPulseFrame:EnableMouse(false)
        end
        if not sq.adFillReparented then
            sq.texture:SetParent(sq.adFillPulseFrame)
            sq.adFillReparented = true
        end
        GetOrCreatePulseAnim(sq.adFillPulseFrame)
        sq.adFillPulseFrame.dfAD_expiringPulsate = true
    elseif sq.adFillPulseFrame then
        sq.adFillPulseFrame.dfAD_expiringPulsate = false
        if sq.adFillPulseFrame.dfAD_pulse and sq.adFillPulseFrame.dfAD_pulse:IsPlaying() then
            sq.adFillPulseFrame.dfAD_pulse:Stop()
            sq.adFillPulseFrame:SetAlpha(1)
        end
    end

    -- Whole-alpha pulse: animates the entire square frame's alpha
    local expiringWholeAlphaPulse = config.expiringWholeAlphaPulse or false
    if expiringWholeAlphaPulse then GetOrCreateWholeAlphaPulse(sq) end
    sq.dfAD_expiringWholeAlphaPulse = expiringWholeAlphaPulse
    if not expiringWholeAlphaPulse and sq.dfAD_wholeAlphaPulse and sq.dfAD_wholeAlphaPulse:IsPlaying() then
        sq.dfAD_wholeAlphaPulse:Stop()
        sq:SetAlpha(1)
    end

    -- Bounce: Translation animation directly on the square
    local expiringBounce = config.expiringBounce or false
    if expiringBounce then GetOrCreateBounceAnim(sq) end
    sq.dfAD_expiringBounce = expiringBounce
    if not expiringBounce and sq.dfAD_bounceAnim and sq.dfAD_bounceAnim:IsPlaying() then
        sq.dfAD_bounceAnim:Stop()
    end

    -- Store expiring config flags for UpdateSquare to read
    sq.dfAD_expiringEnabled = expiringEnabled
    sq.dfAD_expiringColor = config.expiringColor or {r = 1, g = 0.2, b = 0.2}
    sq.dfAD_expiringThreshold = config.expiringThreshold or 30
    sq.dfAD_expiringThresholdMode = config.expiringThresholdMode
    sq.dfAD_expiringPulsate = expiringPulsate

    -- Missing-mode config
    sq.dfAD_missingDesaturate = config.missingDesaturate

    -- Mouse handling: propagate motion/clicks to parent for tooltips and click-casting
    -- Mouse handling: guarded because SetPropagateMouseMotion/Clicks are protected in combat
    if not InCombatLockdown() then
        if sq.SetPropagateMouseMotion then
            sq:SetPropagateMouseMotion(true)
        end
        if sq.SetPropagateMouseClicks then
            sq:SetPropagateMouseClicks(true)
        end
        if sq.SetMouseClickEnabled then
            sq:SetMouseClickEnabled(false)
        end
    end

    -- Stamp config version so we know when to re-configure
    sq.dfAD_configVersion = DF.adConfigVersion or 0
end

-- ============================================================
-- UpdateSquare: dynamic aura-data-driven properties (called every UNIT_AURA)
-- Sets position, cooldown, desaturation, stacks, duration text,
-- expiring registration, and shows the square.  Mirrors UpdateIcon.
-- ============================================================
function Indicators:UpdateSquare(frame, config, auraData, defaults, auraName, priority)
    local state = EnsureFrameState(frame)
    state.activeSquares[auraName] = true

    local sq = GetOrCreateADSquare(frame, auraName)

    -- Store aura data for tooltip lookups (parent-driven via ShowDFAuraTooltip)
    if auraData then
        if not sq.auraData then
            sq.auraData = { auraInstanceID = nil }
        end
        sq.auraData.auraInstanceID = auraData.auraInstanceID
    end

    -- Position — each aura has its own anchor, no growth
    -- Position is dynamic because layout groups compute offsets per-event
    local anchor = config.anchor or "TOPLEFT"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or 0
    -- Compensate for border overhang at frame edges
    local showBorderForPos = config.showBorder
    if showBorderForPos == nil then showBorderForPos = true end
    offsetX, offsetY = AdjustOffsetForBorder(anchor, offsetX, offsetY, config.borderInset or 1, showBorderForPos)
    sq:ClearAllPoints()
    sq:SetPoint(anchor, frame, anchor, offsetX, offsetY)

    -- Read stored config flags from ConfigureSquare
    local hideIcon = sq.dfAD_hideIcon

    -- Desaturation for Show When Missing mode
    if sq.texture then
        local desaturate = sq.dfAD_missingDesaturate and auraData.isMissingAura
        sq.texture:SetDesaturated(desaturate and true or false)
    end

    -- ========================================
    -- COOLDOWN SWIPE (Duration object pipeline)
    -- ========================================
    local hideSwipe = config.hideSwipe; if hideSwipe == nil then hideSwipe = defaults and defaults.hideSwipe end
    local hasDuration = HasAuraDuration(auraData, frame.unit)
    if sq.cooldown then
        if hasDuration then
            SafeSetCooldown(sq.cooldown, auraData, frame.unit)
            -- Retry lazy FontString scan — SetCooldown forces Blizzard to create it
            if EnsureNativeCooldownText(sq, sq.cooldown) then
                ApplyDeferredDurationStyling(sq)
            end
            sq.cooldown:SetDrawSwipe(not hideSwipe and not hideIcon)
            sq.cooldown:Show()
        else
            sq.cooldown:SetDrawSwipe(false)
            sq.cooldown:Hide()
        end
    end

    -- ========================================
    -- STACK COUNT — dynamic display
    -- ========================================
    if sq.count then
        sq.count:SetText("")
        sq.count:Hide()
        if sq.dfAD_showStacks then
            local unit = frame.unit
            local auraInstanceID = auraData.auraInstanceID
            local stackMin = sq.stackMinimum
            if unit and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
                local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, stackMin, 99)
                if stackText then
                    sq.count:SetText(stackText)
                    sq.count:Show()
                end
            elseif auraData.stacks then
                if not issecretvalue(auraData.stacks) and auraData.stacks >= stackMin then
                    sq.count:SetText(auraData.stacks)
                    sq.count:Show()
                end
            end
        end
    end

    -- ========================================
    -- DURATION TEXT — dynamic visibility + color
    -- ========================================
    local showDuration = sq.showDuration
    local durationColorByTime = sq.durationColorByTime
    local durationHideAboveEnabled = sq.durationHideAboveEnabled
    local durationHideAboveThreshold = sq.durationHideAboveThreshold

    if sq.nativeCooldownText then
        if showDuration then
            sq.nativeCooldownText:Show()

            -- Compute hide-above alpha (initial evaluation)
            local hideAlpha = 1
            if durationHideAboveEnabled and hasDuration then
                local usedHideAPI = false
                if frame.unit and auraData.auraInstanceID
                   and C_UnitAuras and C_UnitAuras.GetAuraDuration then
                    local dObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
                    if dObj and dObj.EvaluateRemainingDuration then
                        local hideCurve = BuildDurationHideCurve(durationHideAboveThreshold)
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
                        hideAlpha = remaining > durationHideAboveThreshold and 0 or 1
                    end
                end
            end

            -- Apply hide-above alpha on the wrapper frame (immune to Blizzard resets)
            if sq.durationHideWrapper then
                sq.durationHideWrapper:SetAlpha(hideAlpha)
            end

            -- Color by remaining time (green → yellow → orange → red)
            if durationColorByTime and hasDuration then
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
                            sq.nativeCooldownText:SetTextColor(result.r, result.g, result.b, 1)
                        end
                        usedAPI = true
                    end
                end
                if not usedAPI then
                    local exp = auraData.expirationTime
                    local dur = auraData.duration
                    if exp and dur and not issecretvalue(exp) and not issecretvalue(dur) and dur > 0 then
                        local remaining = max(0, exp - GetTime())
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
                        sq.nativeCooldownText:SetTextColor(r, g, b, 1)
                    end
                end
            else
                local durationColor = config.durationColor or (defaults and defaults.durationColor)
                if durationColor then
                    sq.nativeCooldownText:SetTextColor(durationColor.r or 1, durationColor.g or 1, durationColor.b or 1, 1)
                else
                    sq.nativeCooldownText:SetTextColor(1, 1, 1, 1)
                end
            end

            -- Register wrapper for ongoing hide-above alpha updates via the shared ticker
            -- Temporarily suppress hideWhenNotExpiring so the wrapper doesn't get it
            local savedHWNE2 = pendingHideWhenNotExpiring
            pendingHideWhenNotExpiring = false
            if durationHideAboveEnabled and hasDuration and sq.durationHideWrapper then
                local hideCurve = BuildDurationHideCurve(durationHideAboveThreshold)
                if hideCurve then
                    RegisterExpiring(sq.durationHideWrapper, {
                        unit = frame.unit,
                        auraInstanceID = auraData and auraData.auraInstanceID,
                        threshold = durationHideAboveThreshold,
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
                if sq.durationHideWrapper then
                    UnregisterExpiring(sq.durationHideWrapper)
                    sq.durationHideWrapper:SetAlpha(1)
                end
            end
            pendingHideWhenNotExpiring = savedHWNE2  -- Restore for main registration
        else
            sq.nativeCooldownText:Hide()
        end
    end

    -- ========================================
    -- EXPIRING — register with shared ticker (uses stored config flags)
    -- ========================================
    local expiringEnabled = sq.dfAD_expiringEnabled
    local expiringPulsate = sq.dfAD_expiringPulsate
    local expiringWholeAlphaPulse = sq.dfAD_expiringWholeAlphaPulse
    local expiringBounce = sq.dfAD_expiringBounce

    -- Register if ANY expiring feature is active (color, pulsate, alpha pulse, bounce)
    local anyExpiringFeature = expiringEnabled or expiringPulsate or expiringWholeAlphaPulse or expiringBounce
    if anyExpiringFeature then
        local ec = sq.dfAD_expiringColor
        local color = config.color
        local oc = {r = color and (color[1] or color.r) or 1, g = color and (color[2] or color.g) or 1, b = color and (color[3] or color.b) or 1}
        local applyColor = expiringEnabled
        RegisterExpiring(sq, {
            unit = frame.unit,
            auraInstanceID = auraData and auraData.auraInstanceID,
            threshold = sq.dfAD_expiringThreshold,
            duration = auraData and auraData.duration,
            expirationTime = auraData and auraData.expirationTime,
            colorCurve = applyColor and BuildExpiringColorCurve(sq.dfAD_expiringThreshold, ec, oc, sq.dfAD_expiringThresholdMode) or nil,
            thresholdMode = sq.dfAD_expiringThresholdMode,
            color = ec, originalColor = oc,
            applyResult = function(el, result, entry)
                -- applyResult only fires when colorCurve is set (i.e. applyColor = true)
                if el.texture then
                    el.texture:SetColorTexture(result.r, result.g, result.b, result.a or 1)
                end
                local oc2 = entry.originalColor
                local isExp = IsColorExpiring(result, oc2)
                if el.adFillPulseFrame then
                    UpdatePulseState(el.adFillPulseFrame, isExp)
                end
                UpdateWholeAlphaPulseState(el, isExp)
                UpdateBounceState(el, isExp)
            end,
            applyManual = function(el, isExp, entry)
                if applyColor and el.texture then
                    if isExp then
                        local c = entry.color
                        el.texture:SetColorTexture(c.r or 1, c.g or 0.2, c.b or 0.2, 1)
                    else
                        local c = entry.originalColor
                        el.texture:SetColorTexture(c.r or 1, c.g or 1, c.b or 1, 1)
                    end
                end
                if el.adFillPulseFrame then
                    UpdatePulseState(el.adFillPulseFrame, isExp)
                end
                UpdateWholeAlphaPulseState(el, isExp)
                UpdateBounceState(el, isExp)
            end,
        })
    else
        UnregisterExpiring(sq)
        if sq.adFillPulseFrame and sq.adFillPulseFrame.dfAD_pulse and sq.adFillPulseFrame.dfAD_pulse:IsPlaying() then
            sq.adFillPulseFrame.dfAD_pulse:Stop()
            sq.adFillPulseFrame:SetAlpha(1)
        end
        if sq.dfAD_wholeAlphaPulse and sq.dfAD_wholeAlphaPulse:IsPlaying() then
            sq.dfAD_wholeAlphaPulse:Stop()
            sq:SetAlpha(1)
        end
        if sq.dfAD_bounceAnim and sq.dfAD_bounceAnim:IsPlaying() then
            sq.dfAD_bounceAnim:Stop()
        end
    end

    sq:Show()
end

function Indicators:HideUnusedSquares(frame, activeMap)
    local map = frame and frame.dfAD_squares
    if not map then return end
    for auraName, sq in pairs(map) do
        if not activeMap[auraName] then
            UnregisterExpiring(sq)
            sq:Hide()
            -- Clear stale cooldown (matches bar cleanup pattern)
            if sq.cooldown then
                sq.cooldown:Hide()
            end
            if sq.count then
                sq.count:SetText("")
            end
        end
    end
end

-- ============================================================
-- PLACED INDICATORS -- BAR
-- One progress bar per aura at its configured anchor point.
-- ============================================================

local function GetBarMap(frame)
    if not frame.dfAD_bars then
        frame.dfAD_bars = {}
    end
    return frame.dfAD_bars
end

local DEFAULT_BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

-- Cached color curves for bar color-by-time (same approach as Auras.lua expiring system)
-- Bar color curves are now pre-built per-bar in ConfigureBar (stored as bar.dfAD_colorCurve)

local function CreateADBar(frame, auraName)
    local bar = CreateFrame("StatusBar", nil, frame.contentOverlay or frame)
    bar:SetSize(60, 6)
    bar:SetStatusBarTexture(DEFAULT_BAR_TEXTURE)
    bar:SetMinMaxValues(0, 1)
    bar:SetFrameLevel((frame.contentOverlay or frame):GetFrameLevel() + 10)
    bar.dfAD_auraName = auraName

    -- Background texture
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetTexture(DEFAULT_BAR_TEXTURE)
    bar.bg:SetVertexColor(0.15, 0.15, 0.15, 0.8)

    -- Border frame
    bar.borderFrame = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    bar.borderFrame:SetPoint("TOPLEFT", -1, 1)
    bar.borderFrame:SetPoint("BOTTOMRIGHT", 1, -1)
    if bar.borderFrame.SetBackdrop then
        bar.borderFrame:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        bar.borderFrame:SetBackdropBorderColor(0, 0, 0, 1)
    end

    -- Text overlay (above everything for duration text)
    bar.textOverlay = CreateFrame("Frame", nil, bar)
    bar.textOverlay:SetAllPoints(bar)
    bar.textOverlay:SetFrameLevel(bar:GetFrameLevel() + 5)
    bar.textOverlay:EnableMouse(false)

    -- Duration text (manual, for preview)
    bar.duration = bar.textOverlay:CreateFontString(nil, "OVERLAY")
    DF:SafeSetFont(bar.duration, nil, 10, "OUTLINE")
    bar.duration:SetPoint("CENTER", 0, 0)
    bar.duration:SetTextColor(1, 1, 1)

    -- Cooldown frame for native countdown text in combat (secret-safe)
    -- Invisible swipe — we only use its built-in countdown FontString
    bar.durationCooldown = CreateFrame("Cooldown", nil, bar.textOverlay, "CooldownFrameTemplate")
    bar.durationCooldown:SetAllPoints(bar)
    bar.durationCooldown:SetDrawSwipe(false)
    bar.durationCooldown:SetDrawEdge(false)
    bar.durationCooldown:SetDrawBling(false)
    bar.durationCooldown:SetHideCountdownNumbers(false)
    bar.durationCooldown:Hide()

    -- OnUpdate: handles bar color + preview-only value/text
    -- Real unit bars use SetTimerDuration for fill (no manual arithmetic needed).
    -- Preview bars use manual OnUpdate for fill and text.
    bar.dfAD_duration = 0
    bar.dfAD_expirationTime = 0
    bar.dfAD_colorElapsed = 0
    bar.dfAD_usedTimerDuration = false
    bar.dfAD_expiryCheckElapsed = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        -- Expiration guard: if the aura is gone, hide the bar (#406)
        -- Throttled to ~1 FPS to avoid per-frame API calls
        self.dfAD_expiryCheckElapsed = (self.dfAD_expiryCheckElapsed or 0) + elapsed
        if self.dfAD_expiryCheckElapsed >= 1.0 then
            self.dfAD_expiryCheckElapsed = 0
            local unit = self.dfAD_unit
            local auraID = self.dfAD_auraInstanceID
            if unit and auraID then
                if not C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID) then
                    self:SetValue(0)
                    self:Hide()
                    return
                end
            end
        end

        self.dfAD_colorElapsed = (self.dfAD_colorElapsed or 0) + elapsed

        -- ============================================
        -- PREVIEW: Manual bar value + text (~30 fps)
        -- Only runs when SetTimerDuration is NOT driving the bar
        -- ============================================
        if not self.dfAD_usedTimerDuration then
            local dur = self.dfAD_duration
            local exp = self.dfAD_expirationTime
            if dur and exp and dur > 0 and exp > 0 then
                local remaining = max(0, exp - GetTime())
                local pct = min(1, remaining / dur)
                self:SetValue(pct)

                -- Duration text
                if self.duration and self.duration:IsShown() then
                    if remaining >= 60 then
                        self.duration:SetText(format("%dm", remaining / 60))
                    else
                        self.duration:SetText(format("%.1f", remaining))
                    end
                    if self.dfAD_durationColorByTime then
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
                        self.duration:SetTextColor(r, g, b, 1)
                    end
                end
            end
        end

        -- ============================================
        -- BAR COLOR (API-driven when available, manual fallback)
        -- Throttled to ~1 FPS for performance
        -- ============================================
        if self.dfAD_colorElapsed < 1.0 then return end
        self.dfAD_colorElapsed = 0

        -- API path: evaluate pre-built color curve (no secret comparisons)
        -- The curve is built in ConfigureBar and encodes gradient + expiring logic
        if self.dfAD_colorCurve then
            local unit = self.dfAD_unit
            local auraInstanceID = self.dfAD_auraInstanceID
            if unit and auraInstanceID
               and C_UnitAuras and C_UnitAuras.GetAuraDuration then
                local durationObj = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
                if durationObj then
                    local result
                    if self.dfAD_colorCurveUsesSeconds and durationObj.EvaluateRemainingDuration then
                        result = durationObj:EvaluateRemainingDuration(self.dfAD_colorCurve)
                    elseif durationObj.EvaluateRemainingPercent then
                        result = durationObj:EvaluateRemainingPercent(self.dfAD_colorCurve)
                    end
                    if result and result.r then
                        self:SetStatusBarColor(result.r, result.g, result.b)
                        return
                    end
                end
            end
        end

        -- Manual color fallback for preview
        if not self.dfAD_usedTimerDuration then
            local dur = self.dfAD_duration
            local exp = self.dfAD_expirationTime
            if dur and exp and dur > 0 and exp > 0 then
                local pct = min(1, max(0, exp - GetTime()) / dur)
                local barR = self.dfAD_fillR or 1
                local barG = self.dfAD_fillG or 1
                local barB = self.dfAD_fillB or 1
                if self.dfAD_barColorByTime then
                    if pct < 0.3 then
                        local t = pct / 0.3
                        barR, barG, barB = 1, 0.5 * t, 0
                    elseif pct < 0.5 then
                        local t = (pct - 0.3) / 0.2
                        barR, barG, barB = 1, 0.5 + 0.5 * t, 0
                    else
                        local t = (pct - 0.5) / 0.5
                        barR, barG, barB = 1 - t, 1, 0
                    end
                end
                if self.dfAD_expiringEnabled and self.dfAD_expiringThreshold then
                    local isExp
                    if self.dfAD_expiringThresholdMode == "SECONDS" then
                        local remaining = max(0, exp - GetTime())
                        isExp = remaining <= self.dfAD_expiringThreshold
                    else
                        isExp = pct <= (self.dfAD_expiringThreshold / 100)
                    end
                    if isExp then
                        local ec = self.dfAD_expiringColor
                        if ec then
                            barR = ec.r or 1
                            barG = ec.g or 0.2
                            barB = ec.b or 0.2
                        end
                    end
                end
                self:SetStatusBarColor(barR, barG, barB, 1)
            end
        end
    end)

    bar:Hide()
    return bar
end

local function GetOrCreateADBar(frame, auraName)
    local map = GetBarMap(frame)
    if map[auraName] then return map[auraName] end
    local bar = CreateADBar(frame, auraName)
    map[auraName] = bar
    return bar
end

-- ============================================================
-- ConfigureBar: static config applied once per config change
-- Sets size, orientation, texture, colors, color curve, border,
-- frame level/strata, duration font & style, expiring config
-- flags, and mouse propagation.  Mirrors ConfigureIcon/ConfigureSquare.
-- ============================================================
function Indicators:ConfigureBar(frame, config, defaults, auraName, priority)
    local bar = GetOrCreateADBar(frame, auraName)

    -- ========================================
    -- SIZE & ORIENTATION
    -- ========================================
    local matchW = config.matchFrameWidth
    local matchH = config.matchFrameHeight
    if matchW == nil then matchW = true end   -- default: match frame width
    if matchH == nil then matchH = false end  -- default: don't match height
    local width = config.width or 60
    local height = config.height or 6
    if matchW then width = frame:GetWidth() end
    if matchH then height = frame:GetHeight() end
    bar:SetSize(width, height)

    local barAlpha = config.alpha or 1.0
    bar.dfBaseAlpha = barAlpha
    bar:SetAlpha(barAlpha)

    local orientation = config.orientation or "HORIZONTAL"
    bar:SetOrientation(orientation)

    -- Fill direction
    local reverseFill = config.reverseFill
    if reverseFill ~= nil and bar.SetReverseFill then
        bar:SetReverseFill(reverseFill)
    end

    -- ========================================
    -- TEXTURE
    -- ========================================
    local texture = config.texture or DEFAULT_BAR_TEXTURE
    bar:SetStatusBarTexture(texture)
    if bar.bg then
        bar.bg:SetTexture(texture)
    end

    -- ========================================
    -- COLORS (stored for OnUpdate to read)
    -- ========================================
    local fillColor = config.fillColor
    local fillR = fillColor and (fillColor[1] or fillColor.r) or 1
    local fillG = fillColor and (fillColor[2] or fillColor.g) or 1
    local fillB = fillColor and (fillColor[3] or fillColor.b) or 1

    local bgColor = config.bgColor
    if bgColor and bar.bg then
        bar.bg:SetVertexColor(bgColor[1] or bgColor.r or 0, bgColor[2] or bgColor.g or 0, bgColor[3] or bgColor.b or 0, bgColor[4] or bgColor.a or 0.5)
    end

    -- Bar color by time (stored for OnUpdate to read)
    local barColorByTime = config.barColorByTime
    if barColorByTime == nil then barColorByTime = false end
    bar.dfAD_barColorByTime = barColorByTime

    -- Expiring color (stored for OnUpdate to read)
    local expiringEnabled = config.expiringEnabled
    if expiringEnabled == nil then expiringEnabled = false end
    bar.dfAD_expiringEnabled = expiringEnabled
    bar.dfAD_expiringThreshold = config.expiringThreshold or 30
    bar.dfAD_expiringThresholdMode = config.expiringThresholdMode
    bar.dfAD_expiringColor = config.expiringColor or { r = 1, g = 0.2, b = 0.2 }

    -- Store base fill color for OnUpdate fallback
    bar.dfAD_fillR = fillR
    bar.dfAD_fillG = fillG
    bar.dfAD_fillB = fillB

    -- Hide Icon flag (bars don't have icons but stored for consistency)
    local hideIcon = config.hideIcon; if hideIcon == nil then hideIcon = defaults and defaults.hideIcon end
    bar.dfAD_hideIcon = hideIcon

    -- ========================================
    -- COLOR CURVE (pre-built for OnUpdate)
    -- Single curve handles gradient + expiring without secret comparisons.
    -- OnUpdate evaluates: durationObj:EvaluateRemainingPercent/Duration(curve) → SetStatusBarColor
    -- ========================================
    local useSeconds = config.expiringThresholdMode == "SECONDS"
    local needsColorCurve = barColorByTime or expiringEnabled
    if needsColorCurve and C_CurveUtil and C_CurveUtil.CreateColorCurve then
        local curve = C_CurveUtil.CreateColorCurve()
        local expiringColor = config.expiringColor or { r = 1, g = 0.2, b = 0.2 }
        local expiringThresholdRaw = config.expiringThreshold or 30
        -- For curve building, convert to the appropriate scale
        local expiringThreshold = useSeconds and expiringThresholdRaw or (expiringThresholdRaw / 100)

        if expiringEnabled and barColorByTime then
            -- Composite: when using seconds mode with gradient, fall back to
            -- percentage curve (gradient is inherently percentage-based).
            -- The manual fallback path handles seconds expiring separately.
            local pctThreshold = useSeconds and 0.3 or expiringThreshold
            curve:SetType(Enum.LuaCurveType.Linear)
            local ecR = expiringColor.r or 1
            local ecG = expiringColor.g or 0.2
            local ecB = expiringColor.b or 0.2
            -- Expiring zone (flat color up to threshold)
            curve:AddPoint(0, CreateColor(ecR, ecG, ecB, 1))
            if pctThreshold > 0.002 then
                curve:AddPoint(pctThreshold - 0.001, CreateColor(ecR, ecG, ecB, 1))
            end
            -- Compute gradient color at threshold for smooth transition
            local gR, gG, gB
            if pctThreshold < 0.3 then
                local t = pctThreshold / 0.3
                gR, gG, gB = 1, 0.5 * t, 0
            elseif pctThreshold < 0.5 then
                local t = (pctThreshold - 0.3) / 0.2
                gR, gG, gB = 1, 0.5 + 0.5 * t, 0
            else
                local t = (pctThreshold - 0.5) / 0.5
                gR, gG, gB = 1 - t, 1, 0
            end
            curve:AddPoint(pctThreshold, CreateColor(gR, gG, gB, 1))
            -- Add gradient key points above threshold
            if pctThreshold < 0.3 then
                curve:AddPoint(0.3, CreateColor(1, 0.5, 0, 1))
            end
            if pctThreshold < 0.5 then
                curve:AddPoint(0.5, CreateColor(1, 1, 0, 1))
            end
            curve:AddPoint(1, CreateColor(0, 1, 0, 1))
            -- Composite always uses percent evaluation (gradient needs it)
            bar.dfAD_colorCurveUsesSeconds = false

        elseif expiringEnabled then
            -- Expiring only: step from expiring color to fill color
            curve:SetType(Enum.LuaCurveType.Step)
            local ecR = expiringColor.r or 1
            local ecG = expiringColor.g or 0.2
            local ecB = expiringColor.b or 0.2
            curve:AddPoint(0, CreateColor(ecR, ecG, ecB, 1))
            if useSeconds then
                curve:AddPoint(expiringThreshold, CreateColor(fillR, fillG, fillB, 1))
                curve:AddPoint(600, CreateColor(fillR, fillG, fillB, 1))  -- 10min cap
            else
                curve:AddPoint(expiringThreshold, CreateColor(fillR, fillG, fillB, 1))
                curve:AddPoint(1, CreateColor(fillR, fillG, fillB, 1))
            end
            bar.dfAD_colorCurveUsesSeconds = useSeconds

        elseif barColorByTime then
            -- Gradient only: red → orange → yellow → green (always percent)
            curve:SetType(Enum.LuaCurveType.Linear)
            curve:AddPoint(0, CreateColor(1, 0, 0, 1))
            curve:AddPoint(0.3, CreateColor(1, 0.5, 0, 1))
            curve:AddPoint(0.5, CreateColor(1, 1, 0, 1))
            curve:AddPoint(1, CreateColor(0, 1, 0, 1))
            bar.dfAD_colorCurveUsesSeconds = false
        end

        bar.dfAD_colorCurve = curve
    else
        bar.dfAD_colorCurve = nil
    end

    -- ========================================
    -- BORDER
    -- ========================================
    local showBorder = config.showBorder
    if showBorder == nil then showBorder = true end
    local borderThickness = config.borderThickness or 1

    if bar.borderFrame then
        if showBorder then
            bar.borderFrame:ClearAllPoints()
            bar.borderFrame:SetPoint("TOPLEFT", -borderThickness, borderThickness)
            bar.borderFrame:SetPoint("BOTTOMRIGHT", borderThickness, -borderThickness)
            if bar.borderFrame.SetBackdrop then
                bar.borderFrame:SetBackdrop({
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = borderThickness,
                })
                local borderColor = config.borderColor
                if borderColor then
                    bar.borderFrame:SetBackdropBorderColor(borderColor[1] or borderColor.r or 0, borderColor[2] or borderColor.g or 0, borderColor[3] or borderColor.b or 0, borderColor[4] or borderColor.a or 1)
                else
                    bar.borderFrame:SetBackdropBorderColor(0, 0, 0, 1)
                end
            end
            bar.borderFrame:Show()
        else
            bar.borderFrame:Hide()
        end
    end

    -- Frame level: base from frame (not contentOverlay) + per-indicator level + small priority tiebreaker
    local level = config.frameLevel or (defaults and defaults.indicatorFrameLevel) or 2
    local baseLevel = frame:GetFrameLevel()
    local priorityBoost = math.floor((20 - (priority or 5)) / 4)  -- 0-5 range for tiebreaking
    bar:SetFrameLevel(math.max(0, baseLevel + level + priorityBoost))

    -- Frame strata: per-indicator override, falls back to global default
    local strata = config.frameStrata or (defaults and defaults.indicatorFrameStrata) or "HIGH"
    if strata ~= "INHERIT" then
        SafeSetFrameStrata(bar, frame, strata)
    else
        bar:SetFrameStrata(frame:GetFrameStrata())
    end

    -- ========================================
    -- DURATION TEXT — font/style/flags configuration
    -- ========================================
    local showDuration = config.showDuration
    if showDuration == nil then showDuration = false end
    local durationFont = config.durationFont or (defaults and defaults.durationFont) or "Fonts\\FRIZQT__.TTF"
    local durationScale = config.durationScale or (defaults and defaults.durationScale) or 1.0
    local durationOutline = config.durationOutline or (defaults and defaults.durationOutline) or "OUTLINE"
    if durationOutline == "NONE" then durationOutline = "" end
    local durationAnchor = config.durationAnchor or (defaults and defaults.durationAnchor) or "CENTER"
    local durationX = config.durationX; if durationX == nil then durationX = defaults and defaults.durationX end; if durationX == nil then durationX = 0 end
    local durationY = config.durationY; if durationY == nil then durationY = defaults and defaults.durationY end; if durationY == nil then durationY = 0 end
    local durationColorByTime = config.durationColorByTime
    if durationColorByTime == nil then
        durationColorByTime = (defaults and defaults.durationColorByTime)
        if durationColorByTime == nil then durationColorByTime = true end
    end

    local durationHideAboveEnabled = config.durationHideAboveEnabled
    if durationHideAboveEnabled == nil then durationHideAboveEnabled = (defaults and defaults.durationHideAboveEnabled) or false end
    local durationHideAboveThreshold = config.durationHideAboveThreshold or (defaults and defaults.durationHideAboveThreshold) or 10

    -- Store duration config on bar for UpdateBar and OnUpdate to read
    bar.dfAD_showDuration = showDuration
    bar.dfAD_durationColorByTime = durationColorByTime
    bar.dfAD_durationAnchor = durationAnchor
    bar.dfAD_durationX = durationX
    bar.dfAD_durationY = durationY
    bar.dfAD_durationHideAboveEnabled = durationHideAboveEnabled
    bar.dfAD_durationHideAboveThreshold = durationHideAboveThreshold
    bar.dfAD_durationFont = durationFont
    bar.dfAD_durationScale = durationScale
    bar.dfAD_durationOutline = durationOutline

    -- Find native cooldown text if not yet cached
    if not bar.nativeCooldownText and bar.durationCooldown then
        local regions = { bar.durationCooldown:GetRegions() }
        for _, region in pairs(regions) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                bar.nativeCooldownText = region
                bar.nativeTextReparented = false
                break
            end
        end
    end

    -- Create duration hide wrapper + reparent native text + style + position
    if bar.nativeCooldownText then
        if showDuration then
            if not bar.durationHideWrapper and bar.textOverlay then
                bar.durationHideWrapper = CreateFrame("Frame", nil, bar.textOverlay)
                bar.durationHideWrapper:SetAllPoints(bar.textOverlay)
                bar.durationHideWrapper:SetFrameLevel(bar.textOverlay:GetFrameLevel())
                bar.durationHideWrapper:EnableMouse(false)
            end
            if not bar.nativeTextReparented and bar.durationHideWrapper then
                bar.nativeCooldownText:SetParent(bar.durationHideWrapper)
                bar.nativeTextReparented = true
            end
            local durationSize = 10 * durationScale
            DF:SafeSetFont(bar.nativeCooldownText, durationFont, durationSize, durationOutline)
            bar.nativeCooldownText:ClearAllPoints()
            bar.nativeCooldownText:SetPoint(durationAnchor, bar, durationAnchor, durationX, durationY)
            bar.nativeCooldownText:Show()
        else
            bar.nativeCooldownText:Hide()
        end
    end

    -- Style manual duration FontString (preview path)
    if bar.duration then
        local durationSize = 10 * durationScale
        DF:SafeSetFont(bar.duration, durationFont, durationSize, durationOutline)
        bar.duration:ClearAllPoints()
        bar.duration:SetPoint(durationAnchor, bar, durationAnchor, durationX, durationY)
    end

    -- ========================================
    -- EXPIRING — animation setup + config flags
    -- ========================================
    -- Whole-alpha pulse: animates the entire bar frame's alpha
    local expiringWholeAlphaPulse = config.expiringWholeAlphaPulse or false
    if expiringWholeAlphaPulse then GetOrCreateWholeAlphaPulse(bar) end
    bar.dfAD_expiringWholeAlphaPulse = expiringWholeAlphaPulse
    if not expiringWholeAlphaPulse and bar.dfAD_wholeAlphaPulse and bar.dfAD_wholeAlphaPulse:IsPlaying() then
        bar.dfAD_wholeAlphaPulse:Stop()
        bar:SetAlpha(1)
    end

    -- Bounce: Translation animation directly on the bar
    local expiringBounce = config.expiringBounce or false
    if expiringBounce then GetOrCreateBounceAnim(bar) end
    bar.dfAD_expiringBounce = expiringBounce
    if not expiringBounce and bar.dfAD_bounceAnim and bar.dfAD_bounceAnim:IsPlaying() then
        bar.dfAD_bounceAnim:Stop()
    end

    -- Mouse handling: propagate motion/clicks to parent for tooltips and click-casting
    -- Mouse handling: guarded because SetPropagateMouseMotion/Clicks are protected in combat
    if not InCombatLockdown() then
        if bar.SetPropagateMouseMotion then
            bar:SetPropagateMouseMotion(true)
        end
        if bar.SetPropagateMouseClicks then
            bar:SetPropagateMouseClicks(true)
        end
        if bar.SetMouseClickEnabled then
            bar:SetMouseClickEnabled(false)
        end
    end

    -- Stamp config version so we know when to re-configure
    bar.dfAD_configVersion = DF.adConfigVersion or 0
end

-- ============================================================
-- UpdateBar: dynamic aura-data-driven properties (called every UNIT_AURA)
-- Sets position, fill, initial color, duration text + cooldown,
-- hide-above alpha, and shows the bar.  Mirrors UpdateIcon/UpdateSquare.
-- ============================================================
function Indicators:UpdateBar(frame, config, auraData, defaults, auraName, priority)
    local state = EnsureFrameState(frame)
    state.activeBars[auraName] = true

    local bar = GetOrCreateADBar(frame, auraName)

    -- Store unit + auraInstanceID for API-based color evaluation in OnUpdate
    bar.dfAD_unit = frame.unit
    bar.dfAD_auraInstanceID = auraData.auraInstanceID

    -- ========================================
    -- POSITION (dynamic because layout groups compute offsets per-event)
    -- ========================================
    local anchor = config.anchor or "BOTTOM"
    local offsetX = config.offsetX or 0
    local offsetY = config.offsetY or 0
    -- Compensate for border overhang at frame edges
    local showBorderForPos = config.showBorder
    if showBorderForPos == nil then showBorderForPos = true end
    offsetX, offsetY = AdjustOffsetForBorder(anchor, offsetX, offsetY, config.borderThickness or 1, showBorderForPos)
    bar:ClearAllPoints()
    bar:SetPoint(anchor, frame, anchor, offsetX, offsetY)

    -- ========================================
    -- COUNTDOWN DATA (drives bar fill)
    -- Real unit: SetTimerDuration handles fill natively (secret-safe)
    -- Preview:   Manual SetValue in OnUpdate
    -- ========================================
    local hasDuration = HasAuraDuration(auraData, frame.unit)
    local usedTimerDuration = false

    if hasDuration then
        -- Path 1: Real unit — SetTimerDuration with Duration object
        if frame.unit and auraData.auraInstanceID
           and C_UnitAuras and C_UnitAuras.GetAuraDuration
           and bar.SetTimerDuration then
            local durationObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
            if durationObj then
                bar:SetTimerDuration(durationObj, Enum.StatusBarInterpolation.Immediate, Enum.StatusBarTimerDirection.RemainingTime)
                usedTimerDuration = true
            end
        end

        -- Path 2: Preview fallback — manual SetValue
        if not usedTimerDuration then
            local dur = auraData.duration
            local exp = auraData.expirationTime
            bar.dfAD_duration = dur
            bar.dfAD_expirationTime = exp
            if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
                local remaining = exp - GetTime()
                local pct = max(0, min(1, remaining / dur))
                bar:SetValue(pct)
            else
                bar:SetValue(1)
            end
        end
    else
        bar.dfAD_duration = 0
        bar.dfAD_expirationTime = 0
        bar:SetValue(1)  -- Permanent aura = full bar
    end

    bar.dfAD_usedTimerDuration = usedTimerDuration

    -- ========================================
    -- INITIAL BAR COLOR
    -- When a color curve exists, evaluate it immediately to avoid flicker
    -- (UpdateBar runs on every aura update; without this, the fill color
    -- would flash briefly until the throttled OnUpdate re-evaluates the curve)
    -- ========================================
    local fillR = bar.dfAD_fillR or 1
    local fillG = bar.dfAD_fillG or 1
    local fillB = bar.dfAD_fillB or 1

    if bar.dfAD_colorCurve and frame.unit and auraData.auraInstanceID
       and C_UnitAuras and C_UnitAuras.GetAuraDuration then
        local durationObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
        if durationObj then
            local result
            if bar.dfAD_colorCurveUsesSeconds and durationObj.EvaluateRemainingDuration then
                result = durationObj:EvaluateRemainingDuration(bar.dfAD_colorCurve)
            elseif durationObj.EvaluateRemainingPercent then
                result = durationObj:EvaluateRemainingPercent(bar.dfAD_colorCurve)
            end
            if result and result.r then
                bar:SetStatusBarColor(result.r, result.g, result.b)
            else
                bar:SetStatusBarColor(fillR, fillG, fillB, 1)
            end
        else
            bar:SetStatusBarColor(fillR, fillG, fillB, 1)
        end
    else
        bar:SetStatusBarColor(fillR, fillG, fillB, 1)
    end

    -- ========================================
    -- DURATION TEXT
    -- ========================================
    local showDuration = bar.dfAD_showDuration
    local durationColorByTime = bar.dfAD_durationColorByTime
    local durationHideAboveEnabled = bar.dfAD_durationHideAboveEnabled
    local durationHideAboveThreshold = bar.dfAD_durationHideAboveThreshold
    local durationAnchor = bar.dfAD_durationAnchor or "CENTER"
    local durationX = bar.dfAD_durationX or 0
    local durationY = bar.dfAD_durationY or 0

    if showDuration and hasDuration then
        local durationSize = 10 * (bar.dfAD_durationScale or 1.0)
        local durationFont = bar.dfAD_durationFont or "Fonts\\FRIZQT__.TTF"

        -- Compute hide-above alpha (initial evaluation)
        local hideAlpha = 1
        if durationHideAboveEnabled then
            local usedHideAPI = false
            if frame.unit and auraData.auraInstanceID
               and C_UnitAuras and C_UnitAuras.GetAuraDuration then
                local dObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
                if dObj and dObj.EvaluateRemainingDuration then
                    local hideCurve = BuildDurationHideCurve(durationHideAboveThreshold)
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
                    hideAlpha = remaining > durationHideAboveThreshold and 0 or 1
                end
            end
        end

        if usedTimerDuration and bar.durationCooldown then
            -- COMBAT PATH: Use native cooldown countdown text (secret-safe)
            -- The cooldown frame handles formatting and updating automatically
            bar.duration:Hide()

            -- Set the cooldown with the same Duration object
            local durationObj = C_UnitAuras.GetAuraDuration(frame.unit, auraData.auraInstanceID)
            if durationObj then
                bar.durationCooldown:SetCooldownFromDurationObject(durationObj)
                bar.durationCooldown:Show()
                -- Retry lazy FontString scan — SetCooldownFromDurationObject forces creation
                if EnsureNativeCooldownText(bar, bar.durationCooldown) then
                    ApplyDeferredDurationStyling(bar)
                end
            end

            -- Style and position the native countdown text
            if bar.nativeCooldownText then
                -- Apply hide-above alpha on the wrapper frame (immune to Blizzard resets)
                if bar.durationHideWrapper then
                    bar.durationHideWrapper:SetAlpha(hideAlpha)
                end

                if not durationColorByTime then
                    bar.nativeCooldownText:SetTextColor(1, 1, 1, 1)
                elseif durationObj and durationObj.EvaluateRemainingPercent then
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
                        bar.nativeCooldownText:SetTextColor(result.r, result.g, result.b, 1)
                    end
                end

                -- Register wrapper for ongoing hide-above alpha updates
                -- Temporarily suppress hideWhenNotExpiring so the wrapper doesn't get it
                local savedHWNE = pendingHideWhenNotExpiring
                pendingHideWhenNotExpiring = false
                if durationHideAboveEnabled and bar.durationHideWrapper then
                    local hideCurve = BuildDurationHideCurve(durationHideAboveThreshold)
                    if hideCurve then
                        RegisterExpiring(bar.durationHideWrapper, {
                            unit = frame.unit,
                            auraInstanceID = auraData and auraData.auraInstanceID,
                            threshold = durationHideAboveThreshold,
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
                    if bar.durationHideWrapper then
                        UnregisterExpiring(bar.durationHideWrapper)
                        bar.durationHideWrapper:SetAlpha(1)
                    end
                end
                pendingHideWhenNotExpiring = savedHWNE  -- Restore for main registration
            end

        elseif bar.duration then
            -- PREVIEW PATH: Manual FontString (non-secret values)
            if bar.durationCooldown then
                bar.durationCooldown:Hide()
            end
            if bar.nativeCooldownText then
                bar.nativeCooldownText:Hide()
            end
            if bar.durationHideWrapper then
                UnregisterExpiring(bar.durationHideWrapper)
                bar.durationHideWrapper:SetAlpha(1)
            end

            local dur = auraData.duration
            local exp = auraData.expirationTime
            if dur and exp and not issecretvalue(dur) and not issecretvalue(exp) and dur > 0 then
                local remaining = max(0, exp - GetTime())
                if remaining >= 60 then
                    bar.duration:SetText(format("%dm", remaining / 60))
                else
                    bar.duration:SetText(format("%.1f", remaining))
                end
            else
                bar.duration:SetText("")
            end

            bar.duration:SetAlpha(hideAlpha)
            bar.duration:SetTextColor(1, 1, 1, 1)
            bar.duration:Show()
        end
    else
        if bar.duration then bar.duration:Hide() end
        if bar.durationCooldown then bar.durationCooldown:Hide() end
        if bar.nativeCooldownText then
            bar.nativeCooldownText:Hide()
        end
        if bar.durationHideWrapper then
            UnregisterExpiring(bar.durationHideWrapper)
            bar.durationHideWrapper:SetAlpha(1)
        end
    end

    bar:Show()
end

function Indicators:HideUnusedBars(frame, activeMap)
    local map = frame and frame.dfAD_bars
    if not map then return end
    for auraName, bar in pairs(map) do
        if not activeMap[auraName] then
            bar:Hide()
            -- Clear stale metadata so OnUpdate doesn't run with expired
            -- auraInstanceIDs causing stuck/corrupted bar state (#406)
            bar:SetValue(0)
            bar.dfAD_auraInstanceID = nil
            bar.dfAD_unit = nil
            bar.dfAD_duration = 0
            bar.dfAD_expirationTime = 0
            bar.dfAD_colorCurve = nil
            bar.dfAD_usedTimerDuration = false
            if bar.durationCooldown then
                bar.durationCooldown:Hide()
            end
        end
    end
end
