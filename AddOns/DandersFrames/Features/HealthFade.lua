local addonName, DF = ...

-- ============================================================
-- HEALTH THRESHOLD FADE SYSTEM (Curve-Based)
-- Fades frames when a unit's health is above a configurable threshold.
-- Uses C_CurveUtil.CreateColorCurve() to encode the fade alpha in the
-- curve's alpha channel, then passes UnitHealthPercent(unit, true, curve)
-- to get a ColorMixin whose GetRGBA() alpha is the resolved fade value.
-- The result goes straight to frame:SetAlpha() — NO Lua-side comparison
-- ever touches the secret number.
-- Frame-level fade only — element-specific removed for performance.
-- ============================================================

-- Upvalue frequently used globals
local UnitExists = UnitExists
local UnitHealthPercent = UnitHealthPercent
local CreateColor = CreateColor
local wipe = wipe
local issecretvalue = issecretvalue

-- ============================================================
-- CURVE CACHE
-- Curves keyed by (threshold, belowAlpha, aboveAlpha).
-- Typically only 1-2 unique curves at any time.
-- ============================================================

local healthFadeCurveCache = {}

local function BuildHealthFadeCurve(threshold, belowAlpha, aboveAlpha)
    local key = threshold .. "_" .. belowAlpha .. "_" .. aboveAlpha
    if healthFadeCurveCache[key] then return healthFadeCurveCache[key] end

    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)

    local pos = threshold / 100  -- 0-1 range
    local belowColor = CreateColor(1, 1, 1, belowAlpha)
    local aboveColor = CreateColor(1, 1, 1, aboveAlpha)

    -- Step function at threshold boundary
    curve:AddPoint(0, belowColor)
    if pos > 0.001 then curve:AddPoint(pos - 0.001, belowColor) end
    if pos < 0.999 then curve:AddPoint(pos + 0.001, aboveColor) end
    curve:AddPoint(1, aboveColor)

    healthFadeCurveCache[key] = curve
    return curve
end

-- Invalidate curve cache when options change (called from Options.lua)
function DF:InvalidateHealthFadeCurve()
    wipe(healthFadeCurveCache)
end

-- ============================================================
-- APPLY HEALTH FADE ALPHA
-- Builds a curve encoding the fade, evaluates it via UnitHealthPercent,
-- and applies the result directly to frame:SetAlpha().
-- Returns true if health fade alpha was applied.
-- NO secret number comparisons — the curve result goes straight to SetAlpha.
-- ============================================================

function DF:ApplyHealthFadeAlpha(frame)
    if not frame or not frame.unit then return false end

    local db = DF:GetFrameDB(frame)
    if not db or not db.healthFadeEnabled then return false end

    -- Skip in test mode (test mode handles its own fade)
    if DF.testMode or DF.raidTestMode then return false end

    -- Dispel cancel: if dispel overlay is showing, cancel fade
    -- (IsShown is a non-tainted boolean)
    if db.hfCancelOnDispel then
        if frame.dfDispelOverlay and frame.dfDispelOverlay:IsShown() then
            return false
        end
    end

    -- Determine below-threshold alpha based on range state
    -- frame.dfInRange may be a secret boolean from UnitInRange fallback
    local belowAlpha = 1.0
    if not db.oorEnabled then
        local inRange = frame.dfInRange
        if not (issecretvalue and issecretvalue(inRange)) and inRange == false then
            belowAlpha = db.rangeFadeAlpha or 0.4
        end
        -- Secret values: can't compare, leave belowAlpha at 1 (OOR handled by frame-level SetAlphaFromBoolean)
    end

    local aboveAlpha = db.healthFadeAlpha or 0.5
    local threshold = db.healthFadeThreshold or 100

    -- Build curve and resolve via WoW engine (no secret number comparison)
    local curve = BuildHealthFadeCurve(threshold, belowAlpha, aboveAlpha)
    local color = UnitHealthPercent(frame.unit, true, curve)
    if not color then return false end

    -- Extract alpha and apply directly — never compare, never store
    local _, _, _, alpha = color:GetRGBA()
    if not alpha then return false end

    frame:SetAlpha(alpha)
    return true
end

-- ============================================================
-- UPDATE HEALTH FADE STATE FOR A FRAME
-- Called from SetHealthBarValue on every health update.
-- ============================================================

function DF:UpdateHealthFade(frame)
    if not frame or not frame.unit then return end

    if frame.isPetFrame then
        DF:UpdatePetHealthFade(frame)
        return
    end

    if DF.PerfTest and not DF.PerfTest.enableHealthFade then return end
    if DF.testMode or DF.raidTestMode then return end

    local db = DF:GetFrameDB(frame)
    if not db or not db.healthFadeEnabled then
        if frame.dfHealthFadeActive then
            frame.dfHealthFadeActive = false
            if DF.UpdateAllElementAppearances then
                DF:UpdateAllElementAppearances(frame)
            end
        end
        return
    end

    local applied = DF:ApplyHealthFadeAlpha(frame)
    local wasActive = frame.dfHealthFadeActive

    frame.dfHealthFadeActive = applied

    -- On transition off (dispel cancel etc), restore normal appearance
    if wasActive and not applied then
        if DF.UpdateAllElementAppearances then
            DF:UpdateAllElementAppearances(frame)
        end
    end
end

-- ============================================================
-- UPDATE HEALTH FADE FOR PET FRAMES
-- Same curve approach — only set frame:SetAlpha (cascades to children).
-- Do NOT also set healthBar:SetAlpha or the alpha double-stacks.
-- ============================================================

function DF:UpdatePetHealthFade(frame)
    if not frame or not frame.unit then return end
    if not UnitExists(frame.unit) then return end

    local db = DF:GetFrameDB(frame)
    if not db or not db.healthFadeEnabled then
        frame.dfHealthFadeActive = false
        frame:SetAlpha(1.0)
        return
    end

    local threshold = db.healthFadeThreshold or 100
    local aboveAlpha = db.healthFadeAlpha or 0.5

    local curve = BuildHealthFadeCurve(threshold, 1.0, aboveAlpha)
    local color = UnitHealthPercent(frame.unit, true, curve)
    if not color then return end

    local _, _, _, alpha = color:GetRGBA()
    if not alpha then return end

    frame:SetAlpha(alpha)
end

-- ============================================================
-- HELPER: Check if a frame is currently health-faded
-- ============================================================

function DF:IsHealthFaded(frame)
    if not frame then return false end
    return frame.dfHealthFadeActive == true
end
