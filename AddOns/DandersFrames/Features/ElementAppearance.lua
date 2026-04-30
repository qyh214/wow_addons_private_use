local addonName, DF = ...

-- ============================================================
-- ELEMENT APPEARANCE SYSTEM
-- Centralized color AND alpha management for all frame elements
-- Each element has a single function that determines its full appearance
-- based on all relevant factors (OOR, dead, aggro, settings, etc.)
--
-- This replaces the separate color/alpha functions to prevent flickering
-- and conflicts from multiple functions trying to set appearance.
--
-- Priority Order for determining appearance:
-- 1. Aggro Override (health bar only)
-- 2. Dead/Offline State
-- 3. Health Threshold Fading (above configurable health threshold)
-- 4. Out of Range (OOR) - element-specific or frame-level
-- 5. Normal Settings
--
-- Integration Points:
-- - Range timer (Range.lua) calls UpdateRangeAppearance every 0.2s
--   (which skips per-element updates in standard OOR mode for performance)
-- - ApplyDeadFade/ResetDeadFade (Colors.lua) delegate here
-- - UpdateUnitFrame (Update.lua) calls for unit changes
-- - Settings hooks call for live updates
-- ============================================================

-- Local caching for performance
local pairs, ipairs = pairs, ipairs
local UnitInRange = UnitInRange
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local CreateColor = CreateColor
local issecretvalue = issecretvalue  -- nil pre-Midnight, function in Midnight+

-- ============================================================
-- PERFORMANCE FIX: Reusable ColorMixin objects
-- SetVertexColorFromBoolean needs ColorMixin objects, but creating
-- them every call (5x/sec per frame) causes massive memory allocation.
-- We reuse the same objects and just update their values.
-- ============================================================
local reusableInRangeColor = CreateColor(1, 1, 1, 1)
local reusableOutOfRangeColor = CreateColor(1, 1, 1, 1)

-- ============================================================
-- PERFORMANCE FIX: Default color tables
-- These are used as fallbacks when db values are nil
-- Avoids creating new tables on every call (called 5x/sec per frame)
-- ============================================================
local DEFAULT_COLOR_GRAY = {r = 0.5, g = 0.5, b = 0.5}
local DEFAULT_COLOR_HEALTH = {r = 0.2, g = 0.8, b = 0.2}
local DEFAULT_COLOR_DEAD_BG = {r = 0.3, g = 0, b = 0}
local DEFAULT_COLOR_BACKGROUND = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
local DEFAULT_COLOR_WHITE = {r = 1, g = 1, b = 1}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Check if frame is a DandersFrames frame (process all our frames)
local function IsDandersFrame(frame)
    return frame and frame.dfIsDandersFrame
end

-- Get the appropriate database for this frame
local function GetDB(frame)
    return DF:GetFrameDB(frame)
end

-- Get current range status for a unit
-- Returns a boolean (may be secret from UnitInRange fallback)
-- Downstream callers must use SetAlphaFromBoolean for secret-safe alpha.
local function GetInRange(frame)
    -- Use cached value from Range.lua if available
    -- May be a secret boolean from UnitInRange (classes without friendly spells)
    local inRange = frame.dfInRange
    if issecretvalue and issecretvalue(inRange) then
        return inRange  -- Secret boolean, pass through for SetAlphaFromBoolean
    end
    if inRange ~= nil then
        return inRange
    end
    
    -- Fallback for frames not yet updated by range timer
    local unit = frame.unit
    if not unit then return true end
    
    if not UnitExists(unit) then
        return true
    elseif UnitIsUnit(unit, "player") then
        return true  -- Player is always in range
    end
    
    -- Default to in-range if no cached value yet
    return true
end

-- Apply OOR alpha to any UI element (Frame, Texture, or FontString)
-- inRange may be a secret boolean from UnitInRange fallback (DK/DH/Hunter/Warrior).
-- SetAlphaFromBoolean handles secret booleans natively (Midnight+ API).
local function ApplyOORAlpha(element, inRange, inAlpha, oorAlpha)
    if not element then return end
    if element.SetAlphaFromBoolean then
        element:SetAlphaFromBoolean(inRange, inAlpha, oorAlpha)
    else
        element:SetAlpha(inRange and inAlpha or oorAlpha)
    end
end

-- Check if unit is dead or offline
local function IsDeadOrOffline(frame)
    local unit = frame.unit
    if not unit or not UnitExists(unit) then return false end
    return UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)
end

-- Check if unit is specifically offline (not just dead)
local function IsOffline(frame)
    local unit = frame.unit
    if not unit or not UnitExists(unit) then return false end
    return not UnitIsConnected(unit)
end

-- Check if health threshold fade is enabled
local function IsHealthFadeEnabled(db)
    return db and db.healthFadeEnabled
end

-- Get class color for a unit
local function GetClassColor(frame)
    local unit = frame.unit
    if not unit or not UnitExists(unit) then
        return DEFAULT_COLOR_GRAY
    end
    local _, class = UnitClass(unit)
    return DF:GetClassColor(class)
end

-- ============================================================
-- HEALTH BAR APPEARANCE
-- Handles: color mode, dead/offline, aggro, OOR alpha
-- We apply color via the texture's SetVertexColor to avoid secret value issues
-- ============================================================

function DF:UpdateHealthBarAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.healthBar then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    -- Skip during test mode (test mode handles its own appearance)
    if DF.testMode or DF.raidTestMode then return end

    local unit = frame.unit
    local deadOrOffline = IsDeadOrOffline(frame)
    local offline = IsOffline(frame)
    local inRange = GetInRange(frame)
    local aggroActive = frame.dfAggroActive and frame.dfAggroColor

    -- Get the texture - this is what we apply colors to
    local tex = frame.healthBar:GetStatusBarTexture()
    if not tex then return end

    -- ========================================
    -- DETERMINE ALPHA
    -- ========================================
    local colorMode = db.healthColorMode or "CLASS"
    local alpha
    if colorMode == "CUSTOM" then
        local c = db.healthColor
        alpha = (c and c.a) or 1.0
    else
        alpha = db.classColorAlpha or 1.0
    end

    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadHealthBar or 1
    end

    -- ========================================
    -- APPLY COLOR
    -- Skip when Aura Designer health bar color indicator is active.
    -- AD owns the bar color while its indicator is applied; normal
    -- color updates (UNIT_HEALTH, form shifts, etc.) must not
    -- overwrite it.  Alpha is still applied below so OOR/dead fade
    -- continues to work.
    -- ========================================
    local adHealthBarActive = frame.dfAD and frame.dfAD.healthbar

    if adHealthBarActive then
        -- AD owns the color — don't touch it
    elseif aggroActive then
        -- Priority 1: Aggro override
        local c = frame.dfAggroColor
        tex:SetVertexColor(c.r, c.g, c.b)
    elseif deadOrOffline then
        -- Priority 2: Dead/Offline gray
        if offline then
            tex:SetVertexColor(0.5, 0.5, 0.5)
        else
            tex:SetVertexColor(0.3, 0.3, 0.3)
        end
    else
        -- Priority 3: Normal color based on mode
        if colorMode == "PERCENT" then
            -- PERCENT mode: Use UnitHealthPercent with curve - returns ColorMixin
            local curve = DF:GetCurveForUnit(unit, db)
            if curve and unit and UnitHealthPercent then
                local color = UnitHealthPercent(unit, true, curve)
                if color then
                    tex:SetVertexColor(color:GetRGB())
                else
                    -- Fallback to class color
                    local classColor = GetClassColor(frame)
                    tex:SetVertexColor(classColor.r, classColor.g, classColor.b)
                end
            else
                -- Fallback to class color
                local classColor = GetClassColor(frame)
                tex:SetVertexColor(classColor.r, classColor.g, classColor.b)
            end
        elseif colorMode == "CLASS" then
            local classColor = GetClassColor(frame)
            tex:SetVertexColor(classColor.r, classColor.g, classColor.b)
        elseif colorMode == "CUSTOM" then
            local c = db.healthColor or DEFAULT_COLOR_HEALTH
            tex:SetVertexColor(c.r, c.g, c.b)
        else
            -- Default fallback
            tex:SetVertexColor(0, 0.8, 0)
        end
    end

    -- ========================================
    -- APPLY ALPHA
    -- ========================================
    if db.oorEnabled then
        -- Element-specific OOR mode
        local oorAlpha = db.oorHealthBarAlpha or 0.2
        ApplyOORAlpha(tex, inRange, alpha, oorAlpha)
    else
        -- Frame-level OOR mode - just apply alpha
        tex:SetAlpha(alpha)
    end
end

-- ============================================================
-- MISSING HEALTH BAR APPEARANCE
-- Handles: dead/offline custom color override
-- ============================================================

function DF:UpdateMissingHealthBarAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.missingHealthBar then return end

    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end

    local unit = frame.unit
    if not unit then return end

    -- OOR alpha for element-specific mode
    local db = GetDB(frame)
    if db and db.oorEnabled then
        local inRange = GetInRange(frame)
        local oorAlpha = db.oorMissingHealthAlpha or 0.2
        ApplyOORAlpha(frame.missingHealthBar, inRange, 1.0, oorAlpha)
    end

    -- SetMissingHealthBarValue handles the dead color override internally
    DF.SetMissingHealthBarValue(frame.missingHealthBar, unit, frame)
end

-- ============================================================
-- BACKGROUND APPEARANCE
-- Handles: color mode, textured vs solid, dead/offline, OOR alpha
-- ============================================================

function DF:UpdateBackgroundAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.background then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end
    
    -- Skip if actively adjusting background color in options (prevents flicker)
    if DF.isAdjustingBackgroundColor then return end
    
    -- Handle backgroundMode visibility
    local backgroundMode = db.backgroundMode or "BACKGROUND"
    if backgroundMode == "MISSING_HEALTH" then
        -- Only missing health bar visible, hide solid background
        frame.background:SetAlpha(0)
        return
    end
    -- For "BACKGROUND" or "BOTH", continue with normal background rendering
    
    local unit = frame.unit
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    -- Check if using textured background
    local bgTexture = db.backgroundTexture or "Solid"
    local isTexturedBg = bgTexture ~= "Solid" and bgTexture ~= ""
    
    -- ========================================
    -- DETERMINE COLOR
    -- ========================================
    local r, g, b = 0.1, 0.1, 0.1  -- Default dark
    local baseAlpha = 0.8
    
    local bgMode = db.backgroundColorMode or "CUSTOM"
    
    -- Check for dead custom color override (COLOR only, alpha handled separately)
    local useDeadColor = deadOrOffline and db.fadeDeadFrames and db.fadeDeadUseCustomColor
    
    if useDeadColor then
        -- Use custom dead COLOR (alpha is handled in next section)
        local c = db.fadeDeadBackgroundColor or DEFAULT_COLOR_DEAD_BG
        r, g, b = c.r, c.g, c.b
        baseAlpha = 0.8
    elseif bgMode == "CLASS" and unit and UnitExists(unit) then
        local classColor = GetClassColor(frame)
        r, g, b = classColor.r, classColor.g, classColor.b
        baseAlpha = db.backgroundClassAlpha or 0.3
    elseif bgMode == "CUSTOM" then
        local c = db.backgroundColor or DEFAULT_COLOR_BACKGROUND
        r, g, b = c.r, c.g, c.b
        baseAlpha = c.a or 0.8
    else
        -- Fallback - use default background color (BLIZZARD/BLACK migrated to CUSTOM in v3.2.x)
        local c = db.backgroundColor or DEFAULT_COLOR_BACKGROUND
        r, g, b = c.r, c.g, c.b
        baseAlpha = c.a or 0.8
    end
    
    -- ========================================
    -- DETERMINE ALPHA
    -- ========================================
    local finalAlpha = baseAlpha
    
    if deadOrOffline and db.fadeDeadFrames then
        finalAlpha = db.fadeDeadBackground or 1
    end
    
    -- ========================================
    -- APPLY APPEARANCE
    -- ========================================
    if db.oorEnabled then
        -- Element-specific OOR mode
        local oorBgAlpha = db.oorBackgroundAlpha or 0.1
        
        if isTexturedBg then
            -- Textured background: use SetVertexColor for color+alpha
            frame.background:SetAlpha(1.0)  -- Keep frame alpha at 1
            if frame.background.SetVertexColorFromBoolean then
                -- PERF: Reuse color objects instead of creating new ones
                reusableInRangeColor:SetRGBA(r, g, b, finalAlpha)
                reusableOutOfRangeColor:SetRGBA(r, g, b, oorBgAlpha)
                frame.background:SetVertexColorFromBoolean(inRange, reusableInRangeColor, reusableOutOfRangeColor)
            else
                local effectiveAlpha = inRange and finalAlpha or oorBgAlpha
                frame.background:SetVertexColor(r, g, b, effectiveAlpha)
            end
        else
            -- Solid background: use SetColorTexture + ApplyOORAlpha
            frame.background:SetColorTexture(r, g, b, 1.0)
            ApplyOORAlpha(frame.background, inRange, finalAlpha, oorBgAlpha)
        end
    else
        -- Frame-level OOR mode
        if isTexturedBg then
            frame.background:SetAlpha(1.0)
            frame.background:SetVertexColor(r, g, b, finalAlpha)
        else
            frame.background:SetColorTexture(r, g, b, 1.0)
            frame.background:SetAlpha(finalAlpha)
        end
    end
end

-- ============================================================
-- NAME TEXT APPEARANCE
-- Handles: color (class or custom), dead/offline, OOR alpha
-- ============================================================

function DF:UpdateNameTextAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.nameText then return end

    -- Skip test frames - they handle their own appearance in TestMode.lua
    if frame.dfIsTestFrame then return end

    local db = GetDB(frame)
    if not db then return end

    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)

    -- ========================================
    -- DETERMINE COLOR
    -- ========================================
    local r, g, b = 1, 1, 1  -- Default white
    local baseAlpha = 1.0     -- From color picker

    if db.nameTextUseClassColor then
        -- Class color always applies, even when dead/offline
        local classColor = GetClassColor(frame)
        r, g, b = classColor.r, classColor.g, classColor.b
    elseif deadOrOffline then
        -- Gray for dead/offline (only when not using class color)
        r, g, b = 0.5, 0.5, 0.5
    else
        local c = db.nameTextColor or DEFAULT_COLOR_WHITE
        r, g, b = c.r, c.g, c.b
        baseAlpha = c.a or 1.0
    end

    -- ========================================
    -- DETERMINE ALPHA
    -- All alpha goes through SetAlpha/SetAlphaFromBoolean,
    -- never through SetTextColor's alpha channel.
    -- ========================================
    local alpha = baseAlpha

    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadName or 1.0
    end

    -- ========================================
    -- APPLY APPEARANCE
    -- Color always uses alpha=1.0; opacity is controlled
    -- solely via SetAlpha so it works with SetAlphaFromBoolean.
    -- ========================================
    frame.nameText:SetTextColor(r, g, b, 1.0)

    if db.oorEnabled then
        local oorAlpha = db.oorNameTextAlpha or 1
        ApplyOORAlpha(frame.nameText, inRange, alpha, oorAlpha)
    else
        frame.nameText:SetAlpha(alpha)
    end
end

-- ============================================================
-- HEALTH TEXT APPEARANCE
-- ============================================================

function DF:UpdateHealthTextAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.healthText then return end

    local db = GetDB(frame)
    if not db then return end

    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end

    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)

    -- ========================================
    -- DETERMINE COLOR
    -- ========================================
    local r, g, b = 1, 1, 1  -- Default white
    local baseAlpha = 1.0     -- From color picker

    if db.healthTextUseClassColor then
        local classColor = GetClassColor(frame)
        r, g, b = classColor.r, classColor.g, classColor.b
    else
        local c = db.healthTextColor or DEFAULT_COLOR_WHITE
        r, g, b = c.r, c.g, c.b
        baseAlpha = c.a or 1.0
    end

    -- ========================================
    -- DETERMINE ALPHA
    -- All alpha goes through SetAlpha/SetAlphaFromBoolean.
    -- ========================================
    local alpha = baseAlpha

    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadHealthBar or 1  -- Health text follows health bar alpha
    end

    -- ========================================
    -- APPLY APPEARANCE
    -- Color always uses alpha=1.0; opacity is controlled
    -- solely via SetAlpha so it works with SetAlphaFromBoolean.
    -- ========================================
    frame.healthText:SetTextColor(r, g, b, 1.0)

    if db.oorEnabled then
        local oorAlpha = db.oorHealthTextAlpha or 0.25
        ApplyOORAlpha(frame.healthText, inRange, alpha, oorAlpha)
    else
        frame.healthText:SetAlpha(alpha)
    end
end

-- ============================================================
-- STATUS TEXT APPEARANCE
-- ============================================================

function DF:UpdateStatusTextAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.statusText then return end

    local db = GetDB(frame)
    if not db then return end

    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end

    local deadOrOffline = IsDeadOrOffline(frame)

    -- Status text color (usually white)
    local c = db.statusTextColor or DEFAULT_COLOR_WHITE
    local r, g, b = c.r, c.g, c.b
    local baseAlpha = c.a or 1.0

    local alpha = baseAlpha
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadStatusText or 1.0
    end

    -- Color always uses alpha=1.0; opacity via SetAlpha
    frame.statusText:SetTextColor(r, g, b, 1.0)
    frame.statusText:SetAlpha(alpha)
end

-- ============================================================
-- POWER BAR APPEARANCE
-- ============================================================

function DF:UpdatePowerBarAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.dfPowerBar then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    -- Power bar color is typically set by UpdateUnitFrame based on power type
    -- Here we just handle alpha
    
    local alpha = 1.0
    
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadPowerBar or 0
    end
    
    if db.oorEnabled then
        local oorAlpha = db.oorPowerBarAlpha or 0.2
        ApplyOORAlpha(frame.dfPowerBar, inRange, alpha, oorAlpha)
    else
        frame.dfPowerBar:SetAlpha(alpha)
    end
end

-- ============================================================
-- BUFF ICONS APPEARANCE
-- ============================================================

function DF:UpdateBuffIconsAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.buffIcons then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadAuras or 1.0
    end

    if db.oorEnabled then
        local oorAlpha = db.oorAurasAlpha or 0.2

        for _, icon in ipairs(frame.buffIcons) do
            if icon then
                ApplyOORAlpha(icon, inRange, alpha, oorAlpha)
            end
        end
    else
        for _, icon in ipairs(frame.buffIcons) do
            if icon then
                icon:SetAlpha(alpha)
            end
        end
    end
end

-- ============================================================
-- DEBUFF ICONS APPEARANCE
-- ============================================================

function DF:UpdateDebuffIconsAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.debuffIcons then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    -- Skip during test mode
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadAuras or 1.0
    end

    if db.oorEnabled then
        local oorAlpha = db.oorAurasAlpha or 0.2

        for _, icon in ipairs(frame.debuffIcons) do
            if icon then
                ApplyOORAlpha(icon, inRange, alpha, oorAlpha)
            end
        end
    else
        for _, icon in ipairs(frame.debuffIcons) do
            if icon then
                icon:SetAlpha(alpha)
            end
        end
    end
end

-- ============================================================
-- ICON APPEARANCE (Role, Leader, Raid Target, Ready Check, Center Status)
-- These icons don't change color, just alpha
-- ============================================================

function DF:UpdateRoleIconAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.roleIcon then return end

    local db = GetDB(frame)
    if not db then return end

    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = db.roleIconAlpha or 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = (db.fadeDeadIcons or 1.0) * (db.roleIconAlpha or 1.0)
    end

    if db.oorEnabled then
        local oorAlpha = db.oorIconsAlpha or 0.5
        ApplyOORAlpha(frame.roleIcon, inRange, alpha, oorAlpha)
    else
        frame.roleIcon:SetAlpha(alpha)
    end
end

function DF:UpdateLeaderIconAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.leaderIcon then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = db.leaderIconAlpha or 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = (db.fadeDeadIcons or 1.0) * (db.leaderIconAlpha or 1.0)
    end

    if db.oorEnabled then
        local oorAlpha = db.oorIconsAlpha or 0.5
        ApplyOORAlpha(frame.leaderIcon, inRange, alpha, oorAlpha)
    else
        frame.leaderIcon:SetAlpha(alpha)
    end
end

function DF:UpdateRaidTargetIconAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.raidTargetIcon then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = db.raidTargetIconAlpha or 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = (db.fadeDeadIcons or 1.0) * (db.raidTargetIconAlpha or 1.0)
    end

    if db.oorEnabled then
        local oorAlpha = db.oorIconsAlpha or 0.5
        ApplyOORAlpha(frame.raidTargetIcon, inRange, alpha, oorAlpha)
    else
        frame.raidTargetIcon:SetAlpha(alpha)
    end
end

function DF:UpdateReadyCheckIconAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.readyCheckIcon then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = db.readyCheckIconAlpha or 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = (db.fadeDeadIcons or 1.0) * (db.readyCheckIconAlpha or 1.0)
    end

    if db.oorEnabled then
        local oorAlpha = db.oorIconsAlpha or 0.5
        ApplyOORAlpha(frame.readyCheckIcon, inRange, alpha, oorAlpha)
    else
        frame.readyCheckIcon:SetAlpha(alpha)
    end
end

function DF:UpdateCenterStatusIconAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.centerStatusIcon then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    
    local alpha = 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadIcons or 1.0
    end

    if db.oorEnabled then
        local oorAlpha = db.oorIconsAlpha or 0.5
        ApplyOORAlpha(frame.centerStatusIcon, inRange, alpha, oorAlpha)
    else
        frame.centerStatusIcon:SetAlpha(alpha)
    end
end

-- ============================================================
-- DISPEL OVERLAY APPEARANCE
-- ============================================================

function DF:UpdateDispelOverlayAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.dfDispelOverlay then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)
    local overlay = frame.dfDispelOverlay
    local alpha = 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadBackground or 1
    end
    
    if db.oorEnabled then
        local oorAlpha = db.oorDispelOverlayAlpha or 0.2
        ApplyOORAlpha(overlay.gradient, inRange, alpha, oorAlpha)
        ApplyOORAlpha(overlay.borderTop, inRange, alpha, oorAlpha)
        ApplyOORAlpha(overlay.borderBottom, inRange, alpha, oorAlpha)
        ApplyOORAlpha(overlay.borderLeft, inRange, alpha, oorAlpha)
        ApplyOORAlpha(overlay.borderRight, inRange, alpha, oorAlpha)
        if overlay.icons then
            for _, icon in pairs(overlay.icons) do
                ApplyOORAlpha(icon, inRange, alpha, oorAlpha)
            end
        end
        if DF.ApplyDispelOverlayAppearance then
            DF:ApplyDispelOverlayAppearance(frame)
        end
    else
        if overlay.gradient then overlay.gradient:SetAlpha(alpha) end
        if overlay.borderTop then overlay.borderTop:SetAlpha(alpha) end
        if overlay.borderBottom then overlay.borderBottom:SetAlpha(alpha) end
        if overlay.borderLeft then overlay.borderLeft:SetAlpha(alpha) end
        if overlay.borderRight then overlay.borderRight:SetAlpha(alpha) end
        if overlay.icons then
            for _, icon in pairs(overlay.icons) do
                icon:SetAlpha(alpha)
            end
        end
    end
end

-- ============================================================
-- MY BUFF INDICATOR APPEARANCE
-- ============================================================

function DF:UpdateMyBuffIndicatorAppearance(frame)
    if DF.ApplyMyBuffIndicatorAppearance then
        DF:ApplyMyBuffIndicatorAppearance(frame)
    end
    local db = GetDB(frame)
    if not db then return end
    if DF.testMode or DF.raidTestMode then return end
    if not frame.dfMyBuffOverlay or not frame.dfMyBuffOverlay:IsShown() then return end
end

-- ============================================================
-- MISSING BUFF ICON APPEARANCE
-- ============================================================

function DF:UpdateMissingBuffAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.missingBuffFrame then return end
    
    -- PERF: Skip if missing buff frame isn't visible
    if not frame.missingBuffFrame:IsShown() then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local deadOrOffline = IsDeadOrOffline(frame)
    local inRange = GetInRange(frame)

    local alpha = 1.0
    if deadOrOffline and db.fadeDeadFrames then
        alpha = db.fadeDeadIcons or 1.0
    end

    if db.oorEnabled then
        local oorAlpha = db.oorMissingBuffAlpha or 0.5
        ApplyOORAlpha(frame.missingBuffIcon, inRange, alpha, oorAlpha)
        ApplyOORAlpha(frame.missingBuffBorderLeft, inRange, alpha, oorAlpha)
        ApplyOORAlpha(frame.missingBuffBorderRight, inRange, alpha, oorAlpha)
        ApplyOORAlpha(frame.missingBuffBorderTop, inRange, alpha, oorAlpha)
        ApplyOORAlpha(frame.missingBuffBorderBottom, inRange, alpha, oorAlpha)
    else
        frame.missingBuffIcon:SetAlpha(alpha)
        if frame.missingBuffBorderLeft then frame.missingBuffBorderLeft:SetAlpha(alpha) end
        if frame.missingBuffBorderRight then frame.missingBuffBorderRight:SetAlpha(alpha) end
        if frame.missingBuffBorderTop then frame.missingBuffBorderTop:SetAlpha(alpha) end
        if frame.missingBuffBorderBottom then frame.missingBuffBorderBottom:SetAlpha(alpha) end
    end
end

-- ============================================================
-- ABSORB BAR APPEARANCE
-- ============================================================

function DF:UpdateAbsorbBarAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.dfAbsorbBar then return end
    
    -- PERF: Skip if absorb bar isn't visible
    if not frame.dfAbsorbBar:IsShown() then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local inRange = GetInRange(frame)
    
    if db.oorEnabled then
        local oorAlpha = db.oorAbsorbBarAlpha or 0.5
        ApplyOORAlpha(frame.dfAbsorbBar, inRange, 1.0, oorAlpha)
    end
end

-- ============================================================
-- HEAL ABSORB BAR APPEARANCE
-- ============================================================

function DF:UpdateHealAbsorbBarAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.dfHealAbsorbBar then return end
    
    if not frame.dfHealAbsorbBar:IsShown() then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local inRange = GetInRange(frame)
    
    if db.oorEnabled then
        local oorAlpha = db.oorAbsorbBarAlpha or 0.5
        ApplyOORAlpha(frame.dfHealAbsorbBar, inRange, 1.0, oorAlpha)
    end
end

-- ============================================================
-- HEAL PREDICTION BAR APPEARANCE
-- ============================================================

function DF:UpdateHealPredictionBarAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.dfHealPredictionBar then return end
    
    if not frame.dfHealPredictionBar:IsShown() then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local inRange = GetInRange(frame)
    
    if db.oorEnabled then
        local oorAlpha = db.oorAbsorbBarAlpha or 0.5
        ApplyOORAlpha(frame.dfHealPredictionBar, inRange, 1.0, oorAlpha)
    end
end

-- ============================================================
-- DEFENSIVE ICON APPEARANCE
-- ============================================================

function DF:UpdateDefensiveIconAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.defensiveIcon then return end
    
    -- PERF: Skip if defensive icon isn't visible
    if not frame.defensiveIcon:IsShown() then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local inRange = GetInRange(frame)
    local icon = frame.defensiveIcon
    
    local alpha = 1.0

    if db.oorEnabled then
        local oorAlpha = db.oorDefensiveIconAlpha or 0.5
        ApplyOORAlpha(icon.texture, inRange, alpha, oorAlpha)
        ApplyOORAlpha(icon.borderLeft, inRange, alpha, oorAlpha)
        ApplyOORAlpha(icon.borderRight, inRange, alpha, oorAlpha)
        ApplyOORAlpha(icon.borderTop, inRange, alpha, oorAlpha)
        ApplyOORAlpha(icon.borderBottom, inRange, alpha, oorAlpha)
        ApplyOORAlpha(icon.cooldown, inRange, alpha, oorAlpha)
        ApplyOORAlpha(icon.count, inRange, alpha, oorAlpha)

        -- Additional defensive bar icons also need OOR alpha applied
        if frame.defensiveBarIcons then
            for _, extraIcon in pairs(frame.defensiveBarIcons) do
                ApplyOORAlpha(extraIcon.texture, inRange, alpha, oorAlpha)
                ApplyOORAlpha(extraIcon.borderLeft, inRange, alpha, oorAlpha)
                ApplyOORAlpha(extraIcon.borderRight, inRange, alpha, oorAlpha)
                ApplyOORAlpha(extraIcon.borderTop, inRange, alpha, oorAlpha)
                ApplyOORAlpha(extraIcon.borderBottom, inRange, alpha, oorAlpha)
                ApplyOORAlpha(extraIcon.cooldown, inRange, alpha, oorAlpha)
                ApplyOORAlpha(extraIcon.count, inRange, alpha, oorAlpha)
            end
        end
    else
        if icon.texture then icon.texture:SetAlpha(alpha) end
        if icon.borderLeft then icon.borderLeft:SetAlpha(alpha) end
        if icon.borderRight then icon.borderRight:SetAlpha(alpha) end
        if icon.borderTop then icon.borderTop:SetAlpha(alpha) end
        if icon.borderBottom then icon.borderBottom:SetAlpha(alpha) end
        if icon.cooldown then icon.cooldown:SetAlpha(alpha) end
        if icon.count then icon.count:SetAlpha(alpha) end

        -- Additional defensive bar icons also need alpha applied
        if frame.defensiveBarIcons then
            for _, extraIcon in pairs(frame.defensiveBarIcons) do
                if extraIcon.texture then extraIcon.texture:SetAlpha(alpha) end
                if extraIcon.borderLeft then extraIcon.borderLeft:SetAlpha(alpha) end
                if extraIcon.borderRight then extraIcon.borderRight:SetAlpha(alpha) end
                if extraIcon.borderTop then extraIcon.borderTop:SetAlpha(alpha) end
                if extraIcon.borderBottom then extraIcon.borderBottom:SetAlpha(alpha) end
                if extraIcon.cooldown then extraIcon.cooldown:SetAlpha(alpha) end
                if extraIcon.count then extraIcon.count:SetAlpha(alpha) end
            end
        end
    end
end

-- ============================================================
-- TARGETED SPELL CONTAINER APPEARANCE
-- ============================================================

function DF:UpdateTargetedSpellAppearance(frame)
    if not IsDandersFrame(frame) then return end
    if not frame.targetedSpellContainer then return end
    
    -- PERF: Skip if container isn't visible
    if not frame.targetedSpellContainer:IsShown() then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    local inRange = GetInRange(frame)
    
    local alpha = 1.0

    if db.oorEnabled then
        local oorAlpha = db.oorTargetedSpellAlpha or 0.5
        ApplyOORAlpha(frame.targetedSpellContainer, inRange, alpha, oorAlpha)
    else
        frame.targetedSpellContainer:SetAlpha(alpha)
    end
end

-- ============================================================
-- AURA DESIGNER INDICATORS APPEARANCE
-- Handles OOR alpha for placed AD indicators (icons, squares, bars)
-- ============================================================

function DF:UpdateAuraDesignerAppearance(frame)
    if not IsDandersFrame(frame) then return end

    local db = GetDB(frame)
    if not db then return end

    if DF.testMode or DF.raidTestMode then return end

    local inRange = GetInRange(frame)

    if db.oorEnabled then
        local oorAlpha = db.oorAuraDesignerAlpha or 0.2

        -- Icons
        if frame.dfAD_icons then
            for _, icon in pairs(frame.dfAD_icons) do
                if icon and icon:IsShown() then
                    ApplyOORAlpha(icon, inRange, icon.dfBaseAlpha or 1.0, oorAlpha)
                end
            end
        end
        -- Squares
        if frame.dfAD_squares then
            for _, sq in pairs(frame.dfAD_squares) do
                if sq and sq:IsShown() then
                    ApplyOORAlpha(sq, inRange, sq.dfBaseAlpha or 1.0, oorAlpha)
                end
            end
        end
        -- Bars
        if frame.dfAD_bars then
            for _, bar in pairs(frame.dfAD_bars) do
                if bar and bar:IsShown() then
                    ApplyOORAlpha(bar, inRange, bar.dfBaseAlpha or 1.0, oorAlpha)
                end
            end
        end
    else
        -- Frame-level mode: restore each indicator's base alpha
        if frame.dfAD_icons then
            for _, icon in pairs(frame.dfAD_icons) do
                if icon then icon:SetAlpha(icon.dfBaseAlpha or 1.0) end
            end
        end
        if frame.dfAD_squares then
            for _, sq in pairs(frame.dfAD_squares) do
                if sq then sq:SetAlpha(sq.dfBaseAlpha or 1.0) end
            end
        end
        if frame.dfAD_bars then
            for _, bar in pairs(frame.dfAD_bars) do
                if bar then bar:SetAlpha(bar.dfBaseAlpha or 1.0) end
            end
        end
    end
end

-- ============================================================
-- FRAME-LEVEL APPEARANCE (for non-oorEnabled mode)
-- ============================================================

function DF:UpdateFrameAppearance(frame)
    if not IsDandersFrame(frame) then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if DF.testMode or DF.raidTestMode then return end
    
    if db.oorEnabled then
        ApplyOORAlpha(frame, true, 1.0, 1.0)
    else
        local inRange = GetInRange(frame)
        -- Frame-level: health fade via curve (re-evaluate for range changes)
        if IsHealthFadeEnabled(db) and frame.dfHealthFadeActive and DF.ApplyHealthFadeAlpha and DF:ApplyHealthFadeAlpha(frame) then
            -- Curve applied alpha directly, includes OOR state
        else
            local outOfRangeAlpha = db.rangeFadeAlpha or 0.4
            ApplyOORAlpha(frame, inRange, 1.0, outOfRangeAlpha)
        end
    end
end

-- ============================================================
-- RANGE-ONLY APPEARANCE UPDATE (Performance optimization)
-- Called by Range.lua instead of UpdateAllElementAppearances.
-- In standard OOR mode (oorEnabled=false), only the parent frame's
-- alpha needs updating — WoW's frame hierarchy cascades it to all
-- children automatically. This reduces 18 function calls to 1.
-- In element-specific OOR mode (oorEnabled=true), each element has
-- its own alpha, so we fall through to the full update path.
-- ============================================================

function DF:UpdateRangeAppearance(frame)
    if not IsDandersFrame(frame) then return end
    
    local db = GetDB(frame)
    if not db then return end
    
    if db.oorEnabled then
        -- Element-specific OOR mode: each element has its own alpha
        -- Must update all elements individually
        DF:UpdateAllElementAppearances(frame)
    else
        -- Standard mode: single SetAlpha on the parent frame cascades to all children.
        -- Element alphas (dead state, base alpha, etc.) are already set by other
        -- update paths (death events, settings changes, full refreshes).
        -- We only need to update the frame-level OOR alpha here.
        DF:UpdateFrameAppearance(frame)
    end
end

-- ============================================================
-- UPDATE ALL ELEMENT APPEARANCES
-- Master function to update all elements at once
-- ============================================================

function DF:UpdateAllElementAppearances(frame)
    if not IsDandersFrame(frame) then return end
    
    -- Update frame-level appearance first
    DF:UpdateFrameAppearance(frame)
    
    -- Update each element
    DF:UpdateHealthBarAppearance(frame)
    DF:UpdateMissingHealthBarAppearance(frame)
    DF:UpdateBackgroundAppearance(frame)
    DF:UpdateNameTextAppearance(frame)
    DF:UpdateHealthTextAppearance(frame)
    DF:UpdateStatusTextAppearance(frame)
    DF:UpdatePowerBarAppearance(frame)
    DF:UpdateBuffIconsAppearance(frame)
    DF:UpdateDebuffIconsAppearance(frame)
    DF:UpdateRoleIconAppearance(frame)
    DF:UpdateLeaderIconAppearance(frame)
    DF:UpdateRaidTargetIconAppearance(frame)
    DF:UpdateReadyCheckIconAppearance(frame)
    DF:UpdateCenterStatusIconAppearance(frame)
    DF:UpdateDispelOverlayAppearance(frame)
    DF:UpdateMyBuffIndicatorAppearance(frame)
    DF:UpdateMissingBuffAppearance(frame)
    DF:UpdateAbsorbBarAppearance(frame)
    DF:UpdateHealAbsorbBarAppearance(frame)
    DF:UpdateHealPredictionBarAppearance(frame)
    DF:UpdateDefensiveIconAppearance(frame)
    DF:UpdateTargetedSpellAppearance(frame)
    DF:UpdateAuraDesignerAppearance(frame)
    -- Class power pips (player frame only): reparent/alpha for health fade (party or raid player frame)
    if DF.UpdateClassPowerAlpha and (frame == DF.playerFrame or (frame.unit and frame.isRaidFrame and UnitIsUnit(frame.unit, "player"))) then
        DF.UpdateClassPowerAlpha()
    end
end

-- ============================================================
-- HELPER: Update all DandersFrames frames
-- ============================================================

function DF:UpdateAllFrameAppearances()
    local function updateFrame(frame)
        if frame and frame.dfIsDandersFrame then
            DF:UpdateAllElementAppearances(frame)
        end
    end
    
    -- All frames (party/raid/arena) via iterator
    if DF.IterateAllFrames then
        DF:IterateAllFrames(updateFrame)
    end
    
    -- Pinned frames
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header then
                for i = 1, 40 do
                    local child = header:GetAttribute("child" .. i)
                    if child then
                        updateFrame(child)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- BACKWARD COMPATIBILITY
-- These functions redirect to the new appearance functions
-- for code that still calls the old alpha-only functions
-- ============================================================

-- Redirect old alpha functions to new appearance functions
DF.UpdateAllElementAlphas = DF.UpdateAllElementAppearances
DF.UpdateAllSecureFrameAlphas = DF.UpdateAllFrameAppearances

-- Individual redirects (in case any code calls these directly)
DF.UpdateHealthBarAlpha = DF.UpdateHealthBarAppearance
DF.UpdateBackgroundAlpha = DF.UpdateBackgroundAppearance
DF.UpdateNameTextAlpha = DF.UpdateNameTextAppearance
DF.UpdateHealthTextAlpha = DF.UpdateHealthTextAppearance
DF.UpdateStatusTextAlpha = DF.UpdateStatusTextAppearance
DF.UpdatePowerBarAlpha = DF.UpdatePowerBarAppearance
DF.UpdateBuffIconsAlpha = DF.UpdateBuffIconsAppearance
DF.UpdateDebuffIconsAlpha = DF.UpdateDebuffIconsAppearance
DF.UpdateRoleIconAlpha = DF.UpdateRoleIconAppearance
DF.UpdateLeaderIconAlpha = DF.UpdateLeaderIconAppearance
DF.UpdateRaidTargetIconAlpha = DF.UpdateRaidTargetIconAppearance
DF.UpdateReadyCheckIconAlpha = DF.UpdateReadyCheckIconAppearance
DF.UpdateCenterStatusIconAlpha = DF.UpdateCenterStatusIconAppearance
DF.UpdateDispelOverlayAlpha = DF.UpdateDispelOverlayAppearance
DF.UpdateMissingBuffAlpha = DF.UpdateMissingBuffAppearance
DF.UpdateDefensiveIconAlpha = DF.UpdateDefensiveIconAppearance
DF.UpdateTargetedSpellAlpha = DF.UpdateTargetedSpellAppearance
DF.UpdateFrameAlpha = DF.UpdateFrameAppearance
