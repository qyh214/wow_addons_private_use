local addonName, DF = ...

-- ============================================================
-- DISPEL OVERLAY SYSTEM
-- Shows colored border/glow when unit has dispellable debuff
-- 
-- APPROACH: Per-element curves with custom colors and alphas.
-- - Each element (border, gradient, icon) has its own curve
-- - Curves use user-customizable colors per dispel type
-- - Alpha is baked into the curve based on element settings
-- - None (0) has alpha=0 = invisible
-- - Dispellable types have element's alpha = visible
-- ============================================================

-- Local caching of frequently used globals for performance
local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local CreateColorFromBytes = CreateColorFromBytes
local issecretvalue = issecretvalue

-- Edge gradient textures: each edge is solid at the outer edge and fades inward
-- Uses pre-baked gradient texture files + SetVertexColor (handles secret/tainted values)
-- instead of WHITE8x8 + SetGradient + CreateColor (which errors on secret values)
local EDGE_GRADIENT_TEXTURES = {
    TOP = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V",        -- Solid top, fades down
    BOTTOM = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V_Rev", -- Solid bottom, fades up
    LEFT = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H",       -- Solid left, fades right
    RIGHT = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H_Rev",  -- Solid right, fades left
}

-- ============================================================
-- DISPEL TYPE ENUM VALUES (WoW 12.0+)
-- From wago.tools/db2/SpellDispelType
-- ============================================================

local Enum_DispelType = {
    None = 0,
    Magic = 1,
    Curse = 2,
    Disease = 3,
    Poison = 4,
    Enrage = 9,
    Bleed = 11,
}

-- All known dispel type enum values
local ALL_DISPEL_ENUMS = {0, 1, 2, 3, 4, 9, 11}

-- ============================================================
-- CURVE CACHES (per element type)
-- ============================================================

local borderCurve = nil
local gradientCurve = nil
local nameTextCurve = nil
local iconCurves = {}  -- Per-type curves for icons

-- Invalidate all curves when settings change
function DF:InvalidateDispelColorCurve()
    borderCurve = nil
    gradientCurve = nil
    nameTextCurve = nil
    iconCurves = {}
    -- Also invalidate debuff border curve
    DF.debuffBorderCurve = nil
end

-- ============================================================
-- HELPER: Get dispel colors from db
-- ============================================================

local function GetDispelColors(db)
    return {
        [1] = db.dispelMagicColor or {r = 0.2, g = 0.6, b = 1.0},    -- Magic
        [2] = db.dispelCurseColor or {r = 0.6, g = 0.0, b = 1.0},    -- Curse
        [3] = db.dispelDiseaseColor or {r = 0.6, g = 0.4, b = 0.0},  -- Disease
        [4] = db.dispelPoisonColor or {r = 0.0, g = 0.6, b = 0.0},   -- Poison
        [9] = db.dispelBleedColor or {r = 1.0, g = 0.0, b = 0.0},    -- Enrage
        [11] = db.dispelBleedColor or {r = 1.0, g = 0.0, b = 0.0},   -- Bleed
    }
end

-- ============================================================
-- BUILD ELEMENT CURVE
-- Creates a curve with custom colors and element-specific alpha
-- ============================================================

local function BuildElementCurve(alpha, db)
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then
        return nil
    end
    
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    
    -- None = always invisible
    curve:AddPoint(0, CreateColor(0, 0, 0, 0))
    
    -- Get custom colors from db
    local colors = GetDispelColors(db)
    
    -- Add each dispel type with custom color and element's alpha
    for _, enumVal in ipairs(ALL_DISPEL_ENUMS) do
        if enumVal ~= 0 then  -- Skip None
            local c = colors[enumVal]
            if c then
                curve:AddPoint(enumVal, CreateColor(c.r, c.g, c.b, alpha))
            end
        end
    end
    
    return curve
end

-- ============================================================
-- GET BORDER CURVE
-- Uses border alpha from settings
-- ============================================================

local function GetBorderCurve(db)
    if borderCurve then
        return borderCurve
    end
    
    local alpha = db.dispelBorderAlpha or 0.8
    borderCurve = BuildElementCurve(alpha, db)
    return borderCurve
end

-- ============================================================
-- GET GRADIENT CURVE
-- Uses gradient alpha from settings, multiplied by intensity
-- ============================================================

local function GetGradientCurve(db)
    if gradientCurve then
        return gradientCurve
    end
    
    local alpha = db.dispelGradientAlpha or 0.3
    local intensity = db.dispelGradientIntensity or 1.0
    -- Multiply alpha by intensity (for ADD blending, higher alpha = brighter glow)
    -- Cap at 1.0 for the curve, but we'll boost further via vertex color if needed
    local effectiveAlpha = math.min(alpha * intensity, 1.0)
    gradientCurve = BuildElementCurve(effectiveAlpha, db)
    return gradientCurve
end

-- ============================================================
-- GET NAME TEXT CURVE
-- Full alpha (1.0) — just used to resolve dispel type to color
-- ============================================================

local function GetNameTextCurve(db)
    if nameTextCurve then
        return nameTextCurve
    end
    nameTextCurve = BuildElementCurve(1.0, db)
    return nameTextCurve
end

-- ============================================================
-- PER-TYPE ICON CURVES
-- Each curve has ALL dispel types as points
-- Only the target type has alpha=1, all others have alpha=0
-- This way the returned color's alpha controls visibility
-- ============================================================

local function GetIconCurve(targetEnum, db)
    local cacheKey = targetEnum
    if iconCurves[cacheKey] then
        return iconCurves[cacheKey]
    end
    
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then
        return nil
    end
    
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    
    local iconAlpha = db.dispelIconAlpha or 1.0
    
    -- Add ALL enum values as points
    -- Only target gets alpha from settings, all others get alpha=0
    -- Use white color - atlas icons have their own built-in colors
    for _, enumVal in ipairs(ALL_DISPEL_ENUMS) do
        if enumVal == targetEnum then
            curve:AddPoint(enumVal, CreateColor(1, 1, 1, iconAlpha))
        else
            curve:AddPoint(enumVal, CreateColor(1, 1, 1, 0))  -- Invisible
        end
    end
    
    iconCurves[cacheKey] = curve
    return curve
end

-- Pre-create icon curves for each dispel type
local function GetMagicIconCurve(db)
    return GetIconCurve(Enum_DispelType.Magic, db)
end

local function GetCurseIconCurve(db)
    return GetIconCurve(Enum_DispelType.Curse, db)
end

local function GetDiseaseIconCurve(db)
    return GetIconCurve(Enum_DispelType.Disease, db)
end

local function GetPoisonIconCurve(db)
    return GetIconCurve(Enum_DispelType.Poison, db)
end

local function GetEnrageIconCurve(db)
    return GetIconCurve(Enum_DispelType.Enrage, db)
end

-- Special curve for bleed icon - responds to both Bleed (11) and Enrage (9)
-- Uses white color since atlas has its own built-in color
local function GetBleedIconCurve(db)
    local cacheKey = "bleed_custom"
    if iconCurves[cacheKey] then
        return iconCurves[cacheKey]
    end
    
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then
        return nil
    end
    
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    
    local iconAlpha = db.dispelIconAlpha or 1.0
    
    -- Add ALL enum values as points
    -- Bleed (11) and Enrage (9) get white with full alpha
    -- All others get alpha=0 (invisible)
    for _, enumVal in ipairs(ALL_DISPEL_ENUMS) do
        if enumVal == Enum_DispelType.Bleed or enumVal == Enum_DispelType.Enrage then
            curve:AddPoint(enumVal, CreateColor(1, 1, 1, iconAlpha))
        else
            curve:AddPoint(enumVal, CreateColor(1, 1, 1, 0))  -- Invisible
        end
    end
    
    iconCurves[cacheKey] = curve
    return curve
end

-- ============================================================
-- FALLBACK COLORS (for test mode and out-of-combat)
-- Uses custom colors from db
-- ============================================================

local function GetTestDispelColor(dispelType, db)
    local colors = {
        Magic = db.dispelMagicColor or {r = 0.2, g = 0.6, b = 1.0},
        Curse = db.dispelCurseColor or {r = 0.6, g = 0.0, b = 1.0},
        Disease = db.dispelDiseaseColor or {r = 0.6, g = 0.4, b = 0.0},
        Poison = db.dispelPoisonColor or {r = 0.0, g = 0.6, b = 0.0},
        Enrage = db.dispelBleedColor or {r = 1.0, g = 0.0, b = 0.0},
        Bleed = db.dispelBleedColor or {r = 1.0, g = 0.0, b = 0.0},
    }
    local color = colors[dispelType]
    if color then
        return color.r, color.g, color.b
    end
    return 0.5, 0.5, 1.0
end

-- ============================================================
-- OVERLAY CREATION - Using StatusBar for secret color support
-- Blizzard-managed textures (from StatusBar) CAN handle secret colors
-- Addon-created textures CANNOT handle secret colors
-- ============================================================

local function CreateDispelOverlay(frame)
    if frame.dfDispelOverlay then
        return frame.dfDispelOverlay
    end
    
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    -- Frame level hierarchy (low to high):
    -- Base frame elements (health bar, absorbs, etc.) - frame level +0 to +5
    -- Dispel gradient - parented to healthBar, level healthBar+2
    -- Dispel overlay - frame level +6
    -- Dispel borders - frame level +7
    -- Frame border - frame level +10
    -- Content overlay (text) - frame level +25
    -- Dispel icon - parented to contentOverlay, level +26
    -- Auras - frame level +50
    overlay:SetFrameLevel(frame:GetFrameLevel() + 6)
    
    -- Create StatusBars for borders - their textures CAN handle secret colors
    -- Top border
    overlay.borderTop = CreateFrame("StatusBar", nil, overlay)
    overlay.borderTop:SetFrameLevel(overlay:GetFrameLevel() + 1)  -- Just above gradient
    overlay.borderTop:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderTop:SetMinMaxValues(0, 1)
    overlay.borderTop:SetValue(1)
    overlay.borderTop:GetStatusBarTexture():SetBlendMode("BLEND")  -- Opaque, not additive
    
    -- Bottom border
    overlay.borderBottom = CreateFrame("StatusBar", nil, overlay)
    overlay.borderBottom:SetFrameLevel(overlay:GetFrameLevel() + 1)
    overlay.borderBottom:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderBottom:SetMinMaxValues(0, 1)
    overlay.borderBottom:SetValue(1)
    overlay.borderBottom:GetStatusBarTexture():SetBlendMode("BLEND")  -- Opaque, not additive
    
    -- Left border
    overlay.borderLeft = CreateFrame("StatusBar", nil, overlay)
    overlay.borderLeft:SetFrameLevel(overlay:GetFrameLevel() + 1)
    overlay.borderLeft:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderLeft:SetMinMaxValues(0, 1)
    overlay.borderLeft:SetValue(1)
    overlay.borderLeft:GetStatusBarTexture():SetBlendMode("BLEND")  -- Opaque, not additive
    
    -- Right border
    overlay.borderRight = CreateFrame("StatusBar", nil, overlay)
    overlay.borderRight:SetFrameLevel(overlay:GetFrameLevel() + 1)
    overlay.borderRight:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderRight:SetMinMaxValues(0, 1)
    overlay.borderRight:SetValue(1)
    overlay.borderRight:GetStatusBarTexture():SetBlendMode("BLEND")  -- Opaque, not additive
    
    -- Dark background behind gradient (helps gradient show on light class colors)
    -- Parent to healthBar to ensure proper layering
    local gradientParent = frame.healthBar or overlay
    overlay.gradientDarken = gradientParent:CreateTexture(nil, "ARTWORK", nil, 1)
    overlay.gradientDarken:SetColorTexture(0, 0, 0, 0.5)
    overlay.gradientDarken:Hide()
    
    -- Gradient - use a StatusBar with gradient texture
    -- The texture has built-in alpha gradient, so we just tint it with color
    -- Parent to healthBar to ensure proper layering above health bar content
    overlay.gradient = CreateFrame("StatusBar", nil, gradientParent)
    overlay.gradient:SetFrameLevel(gradientParent:GetFrameLevel() + 2)  -- Above health bar content
    overlay.gradient:SetMinMaxValues(0, 1)
    overlay.gradient:SetValue(1)
    
    -- Use Blizzard's gradient texture - this fades from solid to transparent
    -- "Interface\\BUTTONS\\WHITE8x8" is solid, we need a gradient
    -- Options: Create custom texture OR use existing WoW gradients
    overlay.gradient:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.gradient:GetStatusBarTexture():SetBlendMode("ADD")
    
    -- Store reference to set gradient texture later based on style
    overlay.gradientStyle = "FULL"
    
    -- EDGE style gradients (4 edges that fade inward using gradient textures)
    overlay.gradientTop = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientTop:SetTexture(EDGE_GRADIENT_TEXTURES.TOP)
    overlay.gradientTop:Hide()
    
    overlay.gradientBottom = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientBottom:SetTexture(EDGE_GRADIENT_TEXTURES.BOTTOM)
    overlay.gradientBottom:Hide()
    
    overlay.gradientLeft = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientLeft:SetTexture(EDGE_GRADIENT_TEXTURES.LEFT)
    overlay.gradientLeft:Hide()
    
    overlay.gradientRight = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientRight:SetTexture(EDGE_GRADIENT_TEXTURES.RIGHT)
    overlay.gradientRight:Hide()
    
    -- ============================================================
    -- DISPEL TYPE ICONS
    -- Each icon uses a separate curve where only its type has alpha=1
    -- The curve's alpha controls visibility - we never "know" the type
    -- ============================================================
    
    -- Get the contentOverlay for proper layering (it's at frame level +25)
    local iconParent = frame.contentOverlay or frame
    local iconLevel = iconParent:GetFrameLevel() + 1  -- Just above contentOverlay base
    
    -- Helper to create icon StatusBar with atlas
    local function CreateIconStatusBar(atlasName)
        local icon = CreateFrame("StatusBar", nil, iconParent)
        icon:SetFrameLevel(iconLevel)
        icon:SetMinMaxValues(0, 1)
        icon:SetValue(1)
        icon:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
        icon:GetStatusBarTexture():SetAtlas(atlasName)
        icon:Hide()
        return icon
    end
    
    -- Helper to create simple icon frame with texture (for bleed/enrage)
    local function CreateIconTexture(atlasName)
        local icon = CreateFrame("Frame", nil, iconParent)
        icon:SetFrameLevel(iconLevel)
        icon.texture = icon:CreateTexture(nil, "OVERLAY")
        icon.texture:SetAllPoints()
        icon.texture:SetAtlas(atlasName)
        icon:Hide()
        -- Add methods to match StatusBar API
        icon.GetStatusBarTexture = function(self) return self.texture end
        return icon
    end
    
    -- Create icons for each dispel type
    -- Note: Bleed uses simple texture frame for reliability
    overlay.icons = {
        magic = CreateIconStatusBar("RaidFrame-Icon-DebuffMagic"),
        curse = CreateIconStatusBar("RaidFrame-Icon-DebuffCurse"),
        disease = CreateIconStatusBar("RaidFrame-Icon-DebuffDisease"),
        poison = CreateIconStatusBar("RaidFrame-Icon-DebuffPoison"),
        bleed = CreateIconTexture("RaidFrame-Icon-DebuffBleed"),  -- Bleed atlas
    }
    
    -- Pulse animation
    overlay.pulseAnim = overlay:CreateAnimationGroup()
    overlay.pulseAnim:SetLooping("REPEAT")
    
    local fadeOut = overlay.pulseAnim:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.3)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(1)
    fadeOut:SetSmoothing("IN_OUT")
    
    local fadeIn = overlay.pulseAnim:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.3)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(2)
    fadeIn:SetSmoothing("IN_OUT")
    
    overlay:Hide()
    frame.dfDispelOverlay = overlay
    
    return overlay
end

-- ============================================================
-- OVERLAY LAYOUT
-- ============================================================

-- ============================================================
-- LAYOUT CHANGE DETECTION
-- ApplyOverlayLayout used to run on every ShowOverlayWithSecretColor
-- call (~100x/sec in a raid), re-applying dozens of SetPoint/SetSize
-- calls even when nothing had changed. The layout only actually
-- changes when the user adjusts dispel options or the parent frame
-- is resized — rare events. Compare the 15 relevant settings + parent
-- dimensions against values cached on the overlay; if all match,
-- skip the layout pass entirely.
-- ============================================================
local function LayoutStateChanged(overlay, db)
    local gradientParent = overlay.gradient and overlay.gradient:GetParent()
    local parentH = gradientParent and gradientParent:GetHeight() or 40
    local parentW = gradientParent and gradientParent:GetWidth() or 80
    return overlay.dfL_borderSize              ~= db.dispelBorderSize
        or overlay.dfL_borderInset             ~= db.dispelBorderInset
        or overlay.dfL_pixelPerfect            ~= db.pixelPerfect
        or overlay.dfL_iconSize                ~= db.dispelIconSize
        or overlay.dfL_iconAlpha               ~= db.dispelIconAlpha
        or overlay.dfL_iconPosition            ~= db.dispelIconPosition
        or overlay.dfL_iconOffsetX             ~= db.dispelIconOffsetX
        or overlay.dfL_iconOffsetY             ~= db.dispelIconOffsetY
        or overlay.dfL_showIcon                ~= db.dispelShowIcon
        or overlay.dfL_gradientStyle           ~= db.dispelGradientStyle
        or overlay.dfL_gradientSize            ~= db.dispelGradientSize
        or overlay.dfL_gradientOnCurrentHealth ~= db.dispelGradientOnCurrentHealth
        or overlay.dfL_healthOrientation       ~= db.healthOrientation
        or overlay.dfL_parentH                 ~= parentH
        or overlay.dfL_parentW                 ~= parentW
end

local function CacheLayoutState(overlay, db)
    local gradientParent = overlay.gradient and overlay.gradient:GetParent()
    overlay.dfL_borderSize              = db.dispelBorderSize
    overlay.dfL_borderInset             = db.dispelBorderInset
    overlay.dfL_pixelPerfect            = db.pixelPerfect
    overlay.dfL_iconSize                = db.dispelIconSize
    overlay.dfL_iconAlpha               = db.dispelIconAlpha
    overlay.dfL_iconPosition            = db.dispelIconPosition
    overlay.dfL_iconOffsetX             = db.dispelIconOffsetX
    overlay.dfL_iconOffsetY             = db.dispelIconOffsetY
    overlay.dfL_showIcon                = db.dispelShowIcon
    overlay.dfL_gradientStyle           = db.dispelGradientStyle
    overlay.dfL_gradientSize            = db.dispelGradientSize
    overlay.dfL_gradientOnCurrentHealth = db.dispelGradientOnCurrentHealth
    overlay.dfL_healthOrientation       = db.healthOrientation
    overlay.dfL_parentH                 = gradientParent and gradientParent:GetHeight() or 40
    overlay.dfL_parentW                 = gradientParent and gradientParent:GetWidth() or 80
end

local function ApplyOverlayLayout(overlay, db, frame)
    if not overlay then return end

    -- Fast path: skip the entire layout pass if nothing that affects
    -- it has changed since last call. Typical in-combat outcome.
    if not LayoutStateChanged(overlay, db) then return end

    local borderSize = db.dispelBorderSize or 2
    local borderInset = db.dispelBorderInset or 0

    -- Apply pixel-perfect adjustments
    if db.pixelPerfect then
        borderSize = DF:PixelPerfect(borderSize)
        borderInset = DF:PixelPerfect(borderInset)
    end
    
    overlay.borderLeft:ClearAllPoints()
    overlay.borderLeft:SetPoint("TOPLEFT", overlay, "TOPLEFT", -borderInset, borderInset)
    overlay.borderLeft:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", -borderInset, -borderInset)
    overlay.borderLeft:SetWidth(borderSize)
    
    overlay.borderRight:ClearAllPoints()
    overlay.borderRight:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", borderInset, borderInset)
    overlay.borderRight:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", borderInset, -borderInset)
    overlay.borderRight:SetWidth(borderSize)
    
    overlay.borderTop:ClearAllPoints()
    overlay.borderTop:SetPoint("TOPLEFT", overlay, "TOPLEFT", -borderInset + borderSize, borderInset)
    overlay.borderTop:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", borderInset - borderSize, borderInset)
    overlay.borderTop:SetHeight(borderSize)
    
    overlay.borderBottom:ClearAllPoints()
    overlay.borderBottom:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", -borderInset + borderSize, -borderInset)
    overlay.borderBottom:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", borderInset - borderSize, -borderInset)
    overlay.borderBottom:SetHeight(borderSize)
    
    -- Icon positioning
    local iconSize = db.dispelIconSize or 20
    local iconAlpha = db.dispelIconAlpha or 1.0
    local iconPosition = db.dispelIconPosition or "CENTER"
    local iconOffsetX = db.dispelIconOffsetX or 0
    local iconOffsetY = db.dispelIconOffsetY or 0
    local showIcon = db.dispelShowIcon ~= false
    
    -- Apply pixel-perfect to icon size
    if db.pixelPerfect then
        iconSize = DF:PixelPerfect(iconSize)
    end
    
    if overlay.icons and showIcon then
        -- Position anchor points
        local anchorPoint = iconPosition
        local relativePoint = iconPosition
        
        for _, icon in pairs(overlay.icons) do
            icon:ClearAllPoints()
            icon:SetPoint(anchorPoint, overlay, relativePoint, iconOffsetX, iconOffsetY)
            icon:SetSize(iconSize, iconSize)
            icon:SetAlpha(iconAlpha)
        end
    end
    
    -- Gradient positioning (gradient is parented to healthBar)
    local gradientStyle = db.dispelGradientStyle or "FULL"
    local gradientSize = db.dispelGradientSize or 0.3
    local gradientParent = overlay.gradient:GetParent()
    local parentHeight = gradientParent and gradientParent:GetHeight() or 40
    local parentWidth = gradientParent and gradientParent:GetWidth() or 80
    
    overlay.gradient:ClearAllPoints()
    if overlay.gradientDarken then
        overlay.gradientDarken:ClearAllPoints()
    end
    
    -- Clear edge gradients
    if overlay.gradientTop then overlay.gradientTop:ClearAllPoints() end
    if overlay.gradientBottom then overlay.gradientBottom:ClearAllPoints() end
    if overlay.gradientLeft then overlay.gradientLeft:ClearAllPoints() end
    if overlay.gradientRight then overlay.gradientRight:ClearAllPoints() end
    
    -- Reset health tracking - only FULL style with onCurrentHealth will set this true
    overlay.gradientTracksHealth = false
    
    if gradientStyle == "EDGE" then
        -- EDGE style - gradients from each edge fading inward
        local edgeSize = parentHeight * gradientSize
        local edgeWidth = parentWidth * gradientSize
        
        if overlay.gradientTop then
            overlay.gradientTop:SetPoint("TOPLEFT", gradientParent, "TOPLEFT", 0, 0)
            overlay.gradientTop:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT", 0, 0)
            overlay.gradientTop:SetHeight(edgeSize)
        end
        
        if overlay.gradientBottom then
            overlay.gradientBottom:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT", 0, 0)
            overlay.gradientBottom:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT", 0, 0)
            overlay.gradientBottom:SetHeight(edgeSize)
        end
        
        if overlay.gradientLeft then
            overlay.gradientLeft:SetPoint("TOPLEFT", gradientParent, "TOPLEFT", 0, 0)
            overlay.gradientLeft:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT", 0, 0)
            overlay.gradientLeft:SetWidth(edgeWidth)
        end
        
        if overlay.gradientRight then
            overlay.gradientRight:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT", 0, 0)
            overlay.gradientRight:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT", 0, 0)
            overlay.gradientRight:SetWidth(edgeWidth)
        end
        
        -- Hide darken and main gradient for EDGE style
        if overlay.gradientDarken then
            overlay.gradientDarken:Hide()
        end
    elseif gradientStyle == "TOP" then
        overlay.gradient:SetPoint("TOPLEFT", gradientParent, "TOPLEFT")
        overlay.gradient:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT")
        overlay.gradient:SetHeight(parentHeight * gradientSize)
        if overlay.gradientDarken then
            overlay.gradientDarken:SetPoint("TOPLEFT", gradientParent, "TOPLEFT")
            overlay.gradientDarken:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT")
            overlay.gradientDarken:SetHeight(parentHeight * gradientSize)
        end
    elseif gradientStyle == "BOTTOM" then
        overlay.gradient:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT")
        overlay.gradient:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT")
        overlay.gradient:SetHeight(parentHeight * gradientSize)
        if overlay.gradientDarken then
            overlay.gradientDarken:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT")
            overlay.gradientDarken:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT")
            overlay.gradientDarken:SetHeight(parentHeight * gradientSize)
        end
    elseif gradientStyle == "LEFT" then
        overlay.gradient:SetPoint("TOPLEFT", gradientParent, "TOPLEFT")
        overlay.gradient:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT")
        overlay.gradient:SetWidth(parentWidth * gradientSize)
        if overlay.gradientDarken then
            overlay.gradientDarken:SetPoint("TOPLEFT", gradientParent, "TOPLEFT")
            overlay.gradientDarken:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT")
            overlay.gradientDarken:SetWidth(parentWidth * gradientSize)
        end
    elseif gradientStyle == "RIGHT" then
        overlay.gradient:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT")
        overlay.gradient:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT")
        overlay.gradient:SetWidth(parentWidth * gradientSize)
        if overlay.gradientDarken then
            overlay.gradientDarken:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT")
            overlay.gradientDarken:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT")
            overlay.gradientDarken:SetWidth(parentWidth * gradientSize)
        end
    else
        -- FULL style - can optionally track current health
        local onCurrentHealth = gradientStyle == "FULL" and db.dispelGradientOnCurrentHealth ~= false
        
        if onCurrentHealth and frame and frame.healthBar then
            -- Position gradient to match health bar
            overlay.gradient:SetAllPoints(gradientParent)
            if overlay.gradientDarken then
                overlay.gradientDarken:SetAllPoints(gradientParent)
            end
            
            -- Match health bar orientation and fill direction
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            if healthOrient == "HORIZONTAL" then
                overlay.gradient:SetOrientation("HORIZONTAL")
                overlay.gradient:SetReverseFill(false)
            elseif healthOrient == "HORIZONTAL_INV" then
                overlay.gradient:SetOrientation("HORIZONTAL")
                overlay.gradient:SetReverseFill(true)
            elseif healthOrient == "VERTICAL" then
                overlay.gradient:SetOrientation("VERTICAL")
                overlay.gradient:SetReverseFill(false)
            elseif healthOrient == "VERTICAL_INV" then
                overlay.gradient:SetOrientation("VERTICAL")
                overlay.gradient:SetReverseFill(true)
            end
            
            -- Mark this gradient as tracking health
            overlay.gradientTracksHealth = true
        else
            -- Standard full frame overlay
            overlay.gradient:SetAllPoints(gradientParent)
            if overlay.gradientDarken then
                overlay.gradientDarken:SetAllPoints(gradientParent)
            end
            
            -- Reset to standard status bar mode (full value)
            overlay.gradient:SetOrientation("HORIZONTAL")
            overlay.gradient:SetReverseFill(false)
            overlay.gradient:SetMinMaxValues(0, 1)
            overlay.gradient:SetValue(1)
            overlay.gradientTracksHealth = false
        end
    end

    -- Cache the current layout settings so subsequent calls can
    -- short-circuit via LayoutStateChanged.
    CacheLayoutState(overlay, db)
end

-- ============================================================
-- UPDATE DISPEL GRADIENT HEALTH VALUE
-- Called when health changes to update the gradient overlay
-- ============================================================

function DF:UpdateDispelGradientHealth(frame)
    if not frame or not frame.dfDispelOverlay then return end
    
    local overlay = frame.dfDispelOverlay
    if not overlay.gradient or not overlay.gradientTracksHealth then return end
    if not overlay:IsShown() then return end
    
    local unit = frame.unit
    if not unit or not UnitExists(unit) then return end
    
    -- Get the appropriate db for this frame to check smoothBars setting
    local db
    if frame.isRaidFrame then
        db = DF.GetRaidDB and DF:GetRaidDB()
    else
        db = DF.GetDB and DF:GetDB()
    end
    local smoothEnabled = db and db.smoothBars
    
    -- StatusBar API handles secret values internally via SetMinMaxValues/SetValue
    -- No need to compare values - just pass them directly
    local maxHealth = UnitHealthMax(unit)
    local currentHealth = UnitHealth(unit, true)
    
    overlay.gradient:SetMinMaxValues(0, maxHealth)
    
    -- Use same smooth interpolation as health bar when enabled
    if smoothEnabled and Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut then
        overlay.gradient:SetValue(currentHealth, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        overlay.gradient:SetValue(currentHealth)
    end
end

-- ============================================================
-- APPLY DISPEL OVERLAY APPEARANCE
-- Called by ElementAppearance when range changes
-- Handles EDGE gradients which need SetVertexColor re-applied with OOR alpha
-- ============================================================

function DF:ApplyDispelOverlayAppearance(frame)
    if not frame or not frame.dfDispelOverlay then return end
    
    local overlay = frame.dfDispelOverlay
    if not overlay:IsShown() then return end
    
    local db = DF:GetFrameDB(frame)
    if not db then return end
    
    local gradientStyle = db.dispelGradientStyle or "FULL"
    
    -- Only need special handling for EDGE style
    -- Non-EDGE styles use SetAlphaFromBoolean which is handled by ElementAppearance
    if gradientStyle ~= "EDGE" then return end
    if not db.dispelShowGradient then return end
    
    -- Get OOR settings (dfInRange may be secret from UnitInRange fallback)
    local inRange = frame.dfInRange
    if not (issecretvalue and issecretvalue(inRange)) and inRange == nil then inRange = true end
    local oorAlpha = db.oorDispelOverlayAlpha or 0.2
    
    -- Get current dispel color from stored type
    local dispelType = overlay.currentDispelType
    if not dispelType then return end
    
    local dispelColors = {
        Magic = {0.2, 0.6, 1.0},
        Curse = {0.6, 0.0, 1.0},
        Disease = {0.6, 0.4, 0.0},
        Poison = {0.0, 0.6, 0.0},
        Bleed = {0.8, 0.0, 0.0},
    }
    
    local colors = dispelColors[dispelType]
    if not colors then return end
    
    local r, g, b = colors[1], colors[2], colors[3]
    local gradientAlpha = db.dispelGradientAlpha or 0.5
    local intensity = db.dispelGradientIntensity or 1.0
    local blendMode = db.dispelGradientBlendMode or "ADD"
    
    -- Apply intensity to colors
    local ri, gi, bi = r * intensity, g * intensity, b * intensity
    
    -- Calculate final alpha with OOR
    local finalAlpha = gradientAlpha
    if db.oorEnabled and not inRange then
        finalAlpha = gradientAlpha * oorAlpha
    end
    
    -- Re-apply EDGE gradients with OOR alpha
    if overlay.gradientTop then
        overlay.gradientTop:SetTexture(EDGE_GRADIENT_TEXTURES.TOP)
        overlay.gradientTop:SetVertexColor(ri, gi, bi, finalAlpha)
        overlay.gradientTop:SetBlendMode(blendMode)
    end
    
    if overlay.gradientBottom then
        overlay.gradientBottom:SetTexture(EDGE_GRADIENT_TEXTURES.BOTTOM)
        overlay.gradientBottom:SetVertexColor(ri, gi, bi, finalAlpha)
        overlay.gradientBottom:SetBlendMode(blendMode)
    end
    
    if overlay.gradientLeft then
        overlay.gradientLeft:SetTexture(EDGE_GRADIENT_TEXTURES.LEFT)
        overlay.gradientLeft:SetVertexColor(ri, gi, bi, finalAlpha)
        overlay.gradientLeft:SetBlendMode(blendMode)
    end
    
    if overlay.gradientRight then
        overlay.gradientRight:SetTexture(EDGE_GRADIENT_TEXTURES.RIGHT)
        overlay.gradientRight:SetVertexColor(ri, gi, bi, finalAlpha)
        overlay.gradientRight:SetBlendMode(blendMode)
    end
end

-- ============================================================
-- SHOW OVERLAY WITH SECRET COLOR
-- StatusBar textures CAN handle secret colors via GetRGB()
-- The color's alpha from the curve determines visibility
-- ============================================================

-- Gradient texture paths (relative to addon folder)
local GRADIENT_TEXTURES = {
    LEFT = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H",      -- Fades left to right (solid left)
    RIGHT = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H_Rev",  -- Fades right to left (solid right)
    TOP = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V",        -- Fades top to bottom (solid top)
    BOTTOM = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V_Rev", -- Fades bottom to top (solid bottom)
    FULL = "Interface\\Buttons\\WHITE8x8",                          -- Solid fill
}

-- ============================================================
-- DISPEL NAME TEXT COLORING
-- Colors the unit name text with dispel type color
-- ============================================================

local function ApplyDispelNameText(frame, r, g, b)
    local nameText = frame.nameText
    if not nameText then return end
    if not frame.dfDispelNameTextOrigColor then
        local cr, cg, cb, ca = nameText:GetTextColor()
        frame.dfDispelNameTextOrigColor = { r = cr, g = cg, b = cb, a = ca }
    end
    nameText:SetTextColor(r, g, b, 1)
    frame.dfDispelNameTextActive = true
end

local function RevertDispelNameText(frame)
    if not frame or not frame.dfDispelNameTextActive then return end
    local nameText = frame.nameText
    if not nameText then return end
    -- If AD nametext is active, restore to AD's color
    local adState = frame.dfAD
    if adState and adState.nametext and adState.savedNameColor then
        local c = adState.savedNameColor
        nameText:SetTextColor(c.r, c.g, c.b, c.a or 1)
    elseif frame.dfDispelNameTextOrigColor then
        local c = frame.dfDispelNameTextOrigColor
        nameText:SetTextColor(c.r, c.g, c.b, c.a or 1)
    end
    frame.dfDispelNameTextOrigColor = nil
    frame.dfDispelNameTextActive = false
end

local function ShowOverlayWithSecretColor(overlay, db, unit, auraInstanceID, frame)
    if not overlay or not unit or not auraInstanceID then return end
    
    local showBorder = db.dispelShowBorder ~= false
    local showGradient = db.dispelShowGradient ~= false
    local showIcon = db.dispelShowIcon ~= false
    
    -- Get OOR alpha settings for dispel overlay (dfInRange may be secret from UnitInRange)
    local inRange = frame and frame.dfInRange
    -- If dfInRange is nil (not set yet), assume in range. Secret values pass through.
    if not (issecretvalue and issecretvalue(inRange)) and inRange == nil then inRange = true end
    local oorDispelAlpha = db.oorDispelOverlayAlpha or 0.55
    
    ApplyOverlayLayout(overlay, db, frame)
    
    -- Apply per-element curves - each has custom colors and baked-in alpha
    -- Border uses border curve with border alpha
    if showBorder then
        local borderCurve = GetBorderCurve(db)
        if borderCurve then
            local borderColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, borderCurve)
            if borderColor then
                local tex = overlay.borderTop:GetStatusBarTexture()
                tex:SetVertexColor(borderColor:GetRGBA())
                overlay.borderTop:Show()
                if overlay.borderTop.SetAlphaFromBoolean then
                    overlay.borderTop:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                end
                
                tex = overlay.borderBottom:GetStatusBarTexture()
                tex:SetVertexColor(borderColor:GetRGBA())
                overlay.borderBottom:Show()
                if overlay.borderBottom.SetAlphaFromBoolean then
                    overlay.borderBottom:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                end
                
                tex = overlay.borderLeft:GetStatusBarTexture()
                tex:SetVertexColor(borderColor:GetRGBA())
                overlay.borderLeft:Show()
                if overlay.borderLeft.SetAlphaFromBoolean then
                    overlay.borderLeft:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                end
                
                tex = overlay.borderRight:GetStatusBarTexture()
                tex:SetVertexColor(borderColor:GetRGBA())
                overlay.borderRight:Show()
                if overlay.borderRight.SetAlphaFromBoolean then
                    overlay.borderRight:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                end
            end
        end
    else
        overlay.borderTop:Hide()
        overlay.borderBottom:Hide()
        overlay.borderLeft:Hide()
        overlay.borderRight:Hide()
    end
    
    -- Gradient uses gradient curve with gradient alpha baked in
    if showGradient then
        local gradientCurve = GetGradientCurve(db)
        if gradientCurve then
            local gradientColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, gradientCurve)
            if gradientColor then
                local gradientStyle = db.dispelGradientStyle or "FULL"
                local blendMode = db.dispelGradientBlendMode or "ADD"
                local darkenEnabled = db.dispelGradientDarkenEnabled
                local darkenAlpha = db.dispelGradientDarkenAlpha or 0.5
                
                if gradientStyle == "EDGE" then
                    -- EDGE style - 4 edge gradients using gradient texture files
                    -- Use texture files + SetVertexColor instead of SetGradient + CreateColor
                    -- SetVertexColor handles secret/tainted color values natively
                    
                    -- Hide main gradient and darken for EDGE style
                    overlay.gradient:Hide()
                    if overlay.gradientDarken then
                        overlay.gradientDarken:Hide()
                    end
                    
                    -- Calculate OOR alpha multiplier for edge textures
                    local oorAlpha = 1
                    if db.oorEnabled and not inRange then
                        oorAlpha = oorDispelAlpha
                    end
                    
                    -- Show edge gradients with gradient texture files
                    if overlay.gradientTop then
                        overlay.gradientTop:SetTexture(EDGE_GRADIENT_TEXTURES.TOP)
                        overlay.gradientTop:SetVertexColor(gradientColor:GetRGBA())
                        overlay.gradientTop:SetBlendMode(blendMode)
                        overlay.gradientTop:SetAlpha(oorAlpha)
                        overlay.gradientTop:Show()
                    end
                    
                    if overlay.gradientBottom then
                        overlay.gradientBottom:SetTexture(EDGE_GRADIENT_TEXTURES.BOTTOM)
                        overlay.gradientBottom:SetVertexColor(gradientColor:GetRGBA())
                        overlay.gradientBottom:SetBlendMode(blendMode)
                        overlay.gradientBottom:SetAlpha(oorAlpha)
                        overlay.gradientBottom:Show()
                    end
                    
                    if overlay.gradientLeft then
                        overlay.gradientLeft:SetTexture(EDGE_GRADIENT_TEXTURES.LEFT)
                        overlay.gradientLeft:SetVertexColor(gradientColor:GetRGBA())
                        overlay.gradientLeft:SetBlendMode(blendMode)
                        overlay.gradientLeft:SetAlpha(oorAlpha)
                        overlay.gradientLeft:Show()
                    end
                    
                    if overlay.gradientRight then
                        overlay.gradientRight:SetTexture(EDGE_GRADIENT_TEXTURES.RIGHT)
                        overlay.gradientRight:SetVertexColor(gradientColor:GetRGBA())
                        overlay.gradientRight:SetBlendMode(blendMode)
                        overlay.gradientRight:SetAlpha(oorAlpha)
                        overlay.gradientRight:Show()
                    end
                else
                    -- Non-EDGE styles - use main gradient
                    -- Hide edge gradients
                    if overlay.gradientTop then overlay.gradientTop:Hide() end
                    if overlay.gradientBottom then overlay.gradientBottom:Hide() end
                    if overlay.gradientLeft then overlay.gradientLeft:Hide() end
                    if overlay.gradientRight then overlay.gradientRight:Hide() end
                    
                    -- Show/hide darken background
                    if overlay.gradientDarken then
                        if darkenEnabled then
                            overlay.gradientDarken:SetColorTexture(0, 0, 0, darkenAlpha)
                            overlay.gradientDarken:Show()
                        else
                            overlay.gradientDarken:Hide()
                        end
                    end
                    
                    -- Set the appropriate gradient texture
                    local texturePath = GRADIENT_TEXTURES[gradientStyle] or GRADIENT_TEXTURES.FULL
                    overlay.gradient:SetStatusBarTexture(texturePath)
                    
                    -- Apply the color with baked-in alpha from curve
                    local tex = overlay.gradient:GetStatusBarTexture()
                    tex:SetVertexColor(gradientColor:GetRGBA())
                    tex:SetBlendMode(blendMode)
                    -- Apply OOR alpha via SetAlphaFromBoolean
                    if overlay.gradient.SetAlphaFromBoolean then
                        overlay.gradient:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                    else
                        overlay.gradient:SetAlpha(1)
                    end
                    
                    overlay.gradient:Show()
                end
            end
        end
    else
        overlay.gradient:Hide()
        if overlay.gradientDarken then
            overlay.gradientDarken:Hide()
        end
        -- Hide edge gradients
        if overlay.gradientTop then overlay.gradientTop:Hide() end
        if overlay.gradientBottom then overlay.gradientBottom:Hide() end
        if overlay.gradientLeft then overlay.gradientLeft:Hide() end
        if overlay.gradientRight then overlay.gradientRight:Hide() end
    end
    
    -- Apply per-type curves to icons
    -- Each icon has its own curve where only its type has alpha > 0
    -- The alpha controls visibility (alpha=0 = invisible)
    if showIcon and overlay.icons then
        -- Magic icon
        local magicCurve = GetMagicIconCurve(db)
        if magicCurve then
            local iconColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, magicCurve)
            if iconColor then
                local tex = overlay.icons.magic:GetStatusBarTexture()
                tex:SetVertexColor(iconColor:GetRGBA())
                overlay.icons.magic:Show()
                if overlay.icons.magic.SetAlphaFromBoolean then
                    overlay.icons.magic:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                else
                    overlay.icons.magic:SetAlpha(1)
                end
            end
        end
        
        -- Curse icon
        local curseCurve = GetCurseIconCurve(db)
        if curseCurve then
            local iconColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, curseCurve)
            if iconColor then
                local tex = overlay.icons.curse:GetStatusBarTexture()
                tex:SetVertexColor(iconColor:GetRGBA())
                overlay.icons.curse:Show()
                if overlay.icons.curse.SetAlphaFromBoolean then
                    overlay.icons.curse:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                else
                    overlay.icons.curse:SetAlpha(1)
                end
            end
        end
        
        -- Disease icon
        local diseaseCurve = GetDiseaseIconCurve(db)
        if diseaseCurve then
            local iconColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, diseaseCurve)
            if iconColor then
                local tex = overlay.icons.disease:GetStatusBarTexture()
                tex:SetVertexColor(iconColor:GetRGBA())
                overlay.icons.disease:Show()
                if overlay.icons.disease.SetAlphaFromBoolean then
                    overlay.icons.disease:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                else
                    overlay.icons.disease:SetAlpha(1)
                end
            end
        end
        
        -- Poison icon
        local poisonCurve = GetPoisonIconCurve(db)
        if poisonCurve then
            local iconColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, poisonCurve)
            if iconColor then
                local tex = overlay.icons.poison:GetStatusBarTexture()
                tex:SetVertexColor(iconColor:GetRGBA())
                overlay.icons.poison:Show()
                if overlay.icons.poison.SetAlphaFromBoolean then
                    overlay.icons.poison:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                else
                    overlay.icons.poison:SetAlpha(1)
                end
            end
        end
        
        -- Bleed/Enrage icon - uses our custom curve with bleed color baked in
        local bleedCurve = GetBleedIconCurve(db)
        if bleedCurve then
            local iconColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, bleedCurve)
            if iconColor then
                local tex = overlay.icons.bleed:GetStatusBarTexture()
                tex:SetVertexColor(iconColor:GetRGBA())
                overlay.icons.bleed:Show()
                if overlay.icons.bleed.SetAlphaFromBoolean then
                    overlay.icons.bleed:SetAlphaFromBoolean(inRange, 1.0, oorDispelAlpha)
                else
                    overlay.icons.bleed:SetAlpha(1)
                end
            end
        end
    elseif overlay.icons then
        -- Hide all icons if disabled
        for _, icon in pairs(overlay.icons) do
            icon:Hide()
        end
    end
    
    -- Animation
    if db.dispelAnimate and overlay.pulseAnim then
        if not overlay.pulseAnim:IsPlaying() then
            overlay.pulseAnim:Play()
        end
    else
        if overlay.pulseAnim and overlay.pulseAnim:IsPlaying() then
            overlay.pulseAnim:Stop()
        end
        overlay:SetAlpha(1)
    end
    
    overlay:Show()
    
    -- Update gradient health value if tracking current health
    if overlay.gradientTracksHealth then
        DF:UpdateDispelGradientHealth(frame)
    end

    -- Name text coloring — resolve dispel type to color via curve
    if db.dispelNameText and frame then
        local ntCurve = GetNameTextCurve(db)
        if ntCurve then
            local ntColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceID, ntCurve)
            if ntColor then
                local cr, cg, cb = ntColor:GetRGB()
                ApplyDispelNameText(frame, cr, cg, cb)
            end
        end
    end
end

-- ============================================================
-- SHOW OVERLAY WITH RGB (for test mode)
-- ============================================================

local function ShowOverlayWithRGB(overlay, r, g, b, db, dispelType, oorAlphaMultiplier, frame, testData)
    if not overlay then return end
    
    -- Store dispel type for lightweight color updates
    overlay.currentDispelType = dispelType
    
    -- Default OOR multiplier to 1.0 (no change)
    oorAlphaMultiplier = oorAlphaMultiplier or 1.0
    
    local borderAlpha = (db.dispelBorderAlpha or 0.8) * oorAlphaMultiplier
    local gradientAlpha = (db.dispelGradientAlpha or 0.5) * oorAlphaMultiplier
    local showBorder = db.dispelShowBorder ~= false
    local showGradient = db.dispelShowGradient ~= false
    local showIcon = db.dispelShowIcon ~= false
    
    ApplyOverlayLayout(overlay, db, frame)
    
    if showBorder then
        -- StatusBars use GetStatusBarTexture():SetVertexColor()
        local tex = overlay.borderTop:GetStatusBarTexture()
        tex:SetVertexColor(r, g, b, borderAlpha)
        overlay.borderTop:Show()
        
        tex = overlay.borderBottom:GetStatusBarTexture()
        tex:SetVertexColor(r, g, b, borderAlpha)
        overlay.borderBottom:Show()
        
        tex = overlay.borderLeft:GetStatusBarTexture()
        tex:SetVertexColor(r, g, b, borderAlpha)
        overlay.borderLeft:Show()
        
        tex = overlay.borderRight:GetStatusBarTexture()
        tex:SetVertexColor(r, g, b, borderAlpha)
        overlay.borderRight:Show()
    else
        overlay.borderTop:Hide()
        overlay.borderBottom:Hide()
        overlay.borderLeft:Hide()
        overlay.borderRight:Hide()
    end
    
    if showGradient then
        local gradientStyle = db.dispelGradientStyle or "FULL"
        local intensity = db.dispelGradientIntensity or 1.0
        local blendMode = db.dispelGradientBlendMode or "ADD"
        local darkenEnabled = db.dispelGradientDarkenEnabled
        local darkenAlpha = db.dispelGradientDarkenAlpha or 0.5
        
        if gradientStyle == "EDGE" then
            -- EDGE style - 4 edge gradients using gradient texture files
            -- Hide main gradient and darken for EDGE style
            overlay.gradient:Hide()
            if overlay.gradientDarken then
                overlay.gradientDarken:Hide()
            end
            
            -- Apply intensity to colors
            local ri, gi, bi = r * intensity, g * intensity, b * intensity
            
            -- Show edge gradients with gradient textures + SetVertexColor
            if overlay.gradientTop then
                overlay.gradientTop:SetTexture(EDGE_GRADIENT_TEXTURES.TOP)
                overlay.gradientTop:SetVertexColor(ri, gi, bi, gradientAlpha)
                overlay.gradientTop:SetBlendMode(blendMode)
                overlay.gradientTop:Show()
            end
            
            if overlay.gradientBottom then
                overlay.gradientBottom:SetTexture(EDGE_GRADIENT_TEXTURES.BOTTOM)
                overlay.gradientBottom:SetVertexColor(ri, gi, bi, gradientAlpha)
                overlay.gradientBottom:SetBlendMode(blendMode)
                overlay.gradientBottom:Show()
            end
            
            if overlay.gradientLeft then
                overlay.gradientLeft:SetTexture(EDGE_GRADIENT_TEXTURES.LEFT)
                overlay.gradientLeft:SetVertexColor(ri, gi, bi, gradientAlpha)
                overlay.gradientLeft:SetBlendMode(blendMode)
                overlay.gradientLeft:Show()
            end
            
            if overlay.gradientRight then
                overlay.gradientRight:SetTexture(EDGE_GRADIENT_TEXTURES.RIGHT)
                overlay.gradientRight:SetVertexColor(ri, gi, bi, gradientAlpha)
                overlay.gradientRight:SetBlendMode(blendMode)
                overlay.gradientRight:Show()
            end
        else
            -- Non-EDGE styles - use main gradient
            -- Hide edge gradients
            if overlay.gradientTop then overlay.gradientTop:Hide() end
            if overlay.gradientBottom then overlay.gradientBottom:Hide() end
            if overlay.gradientLeft then overlay.gradientLeft:Hide() end
            if overlay.gradientRight then overlay.gradientRight:Hide() end
            
            -- Show/hide darken background
            if overlay.gradientDarken then
                if darkenEnabled then
                    overlay.gradientDarken:SetColorTexture(0, 0, 0, darkenAlpha * oorAlphaMultiplier)
                    overlay.gradientDarken:Show()
                else
                    overlay.gradientDarken:Hide()
                end
            end
            
            -- Set the appropriate gradient texture
            local texturePath = GRADIENT_TEXTURES[gradientStyle] or GRADIENT_TEXTURES.FULL
            overlay.gradient:SetStatusBarTexture(texturePath)
            
            local tex = overlay.gradient:GetStatusBarTexture()
            -- Apply intensity by multiplying RGB values (makes gradient brighter/dimmer)
            tex:SetVertexColor(r * intensity, g * intensity, b * intensity, gradientAlpha)
            tex:SetBlendMode(blendMode)
            overlay.gradient:Show()
        end
    else
        overlay.gradient:Hide()
        if overlay.gradientDarken then
            overlay.gradientDarken:Hide()
        end
        -- Hide edge gradients
        if overlay.gradientTop then overlay.gradientTop:Hide() end
        if overlay.gradientBottom then overlay.gradientBottom:Hide() end
        if overlay.gradientLeft then overlay.gradientLeft:Hide() end
        if overlay.gradientRight then overlay.gradientRight:Hide() end
    end
    
    -- Show icon for test mode based on dispelType
    if showIcon and overlay.icons and dispelType then
        local iconAlpha = (db.dispelIconAlpha or 1.0) * oorAlphaMultiplier
        
        -- Hide all icons first
        for _, icon in pairs(overlay.icons) do
            icon:Hide()
        end
        
        -- Show the matching icon
        local iconKey = string.lower(dispelType)
        if iconKey == "enrage" then iconKey = "bleed" end  -- Enrage uses bleed icon
        
        if overlay.icons[iconKey] then
            local tex = overlay.icons[iconKey]:GetStatusBarTexture()
            -- Tint bleed icon with red (since it uses disease atlas)
            if iconKey == "bleed" then
                tex:SetVertexColor(r, g, b, 1)  -- Use the passed color (bleed color)
            else
                tex:SetVertexColor(1, 1, 1, 1)  -- White for standard icons
            end
            overlay.icons[iconKey]:SetAlpha(iconAlpha)
            overlay.icons[iconKey]:Show()
        end
    elseif overlay.icons then
        for _, icon in pairs(overlay.icons) do
            icon:Hide()
        end
    end
    
    if db.dispelAnimate and overlay.pulseAnim then
        if not overlay.pulseAnim:IsPlaying() then
            overlay.pulseAnim:Play()
        end
    else
        if overlay.pulseAnim and overlay.pulseAnim:IsPlaying() then
            overlay.pulseAnim:Stop()
        end
        overlay:SetAlpha(1)
    end
    
    overlay:Show()
    
    -- Update gradient health value if tracking current health (test mode)
    if overlay.gradientTracksHealth and frame then
        -- For test mode, use the testData's health percent
        local testHealth = (testData and testData.healthPercent) or 0.75
        overlay.gradient:SetMinMaxValues(0, 1)
        overlay.gradient:SetValue(testHealth)
    end

    -- Name text coloring — uses the explicit RGB passed to this function
    if db.dispelNameText and frame then
        ApplyDispelNameText(frame, r, g, b)
    end
end

-- ============================================================
-- HIDE OVERLAY
-- ============================================================

local function HideOverlay(overlay)
    if not overlay then return end
    
    -- Stop animation first
    if overlay.pulseAnim and overlay.pulseAnim:IsPlaying() then
        overlay.pulseAnim:Stop()
    end
    
    -- Reset alpha
    overlay:SetAlpha(1)
    
    -- Hide all border textures
    overlay.borderTop:Hide()
    overlay.borderBottom:Hide()
    overlay.borderLeft:Hide()
    overlay.borderRight:Hide()
    
    -- Hide gradient and its darken background
    overlay.gradient:Hide()
    if overlay.gradientDarken then
        overlay.gradientDarken:Hide()
    end
    
    -- Hide edge gradients
    if overlay.gradientTop then overlay.gradientTop:Hide() end
    if overlay.gradientBottom then overlay.gradientBottom:Hide() end
    if overlay.gradientLeft then overlay.gradientLeft:Hide() end
    if overlay.gradientRight then overlay.gradientRight:Hide() end
    
    -- Hide all icons
    if overlay.icons then
        for _, icon in pairs(overlay.icons) do
            icon:Hide()
        end
    end
    
    -- Hide the overlay frame itself
    overlay:Hide()
end

-- ============================================================
-- MAIN UPDATE FUNCTION
-- Simple approach: One curve with all types, None has alpha=0
-- Just apply the color - alpha handles visibility
-- ============================================================

-- Hide the dispel overlay and clear the last-rendered-aura cache so
-- the next valid UpdateDispelOverlay call re-renders the overlay.
-- Used by every early-return path inside UpdateDispelOverlay — without
-- clearing dfLastDispelAuraID here, the last-rendered-aura skip below
-- would incorrectly early-return after the user re-enabled the overlay.
local function HideDispelAndInvalidate(frame)
    if frame.dfDispelOverlay then
        HideOverlay(frame.dfDispelOverlay)
    end
    RevertDispelNameText(frame)
    frame.dfLastDispelAuraID = nil
    -- DF's overlay just went hidden — let the Blizzard container wrapper
    -- show so private-aura dispels still get an overlay.
    if DF.UpdateContainerOverlayVisibility then
        DF:UpdateContainerOverlayVisibility(frame)
    end
end

function DF:UpdateDispelOverlay(frame)
    if not frame then return end

    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableDispel then
        HideDispelAndInvalidate(frame)
        return
    end

    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)

    -- Check if in test mode first (allows preview even when dispel overlay is disabled)
    local isRaidFrame = frame.isRaidFrame
    local inRelevantTestMode = (isRaidFrame and DF.raidTestMode) or (not isRaidFrame and DF.testMode)

    -- Decide whether DF's own overlay path should run. In test mode we
    -- honour testShowDispelGlow; otherwise DF runs only for sources
    -- "dandersframes" and "both" (Hybrid).
    local shouldRun
    if inRelevantTestMode then
        shouldRun = db and db.testShowDispelGlow
    else
        local src = db and db.dispelOverlaySource
        shouldRun = db and (src == "dandersframes" or src == "both")
    end

    if not shouldRun then
        -- Only run the cleanup path when there's DF overlay state that actually
        -- needs clearing. On a fresh frame in Blizzard / Off mode, every flag
        -- below is falsy and we skip HideDispelAndInvalidate entirely (which
        -- also skips a redundant UpdateContainerOverlayVisibility call). This
        -- matters in combat where UpdateDispelOverlay fires many times per
        -- second per frame via TriggerAuraUpdateForUnit.
        local hasState = (frame.dfDispelOverlay and frame.dfDispelOverlay:IsShown())
                       or frame.dfDispelNameTextActive
                       or (frame.dfLastDispelAuraID ~= nil)
        if hasState then
            HideDispelAndInvalidate(frame)
        end
        return
    end

    local unit = frame.unit

    -- Handle test mode - only show dispels on the correct frame type
    if inRelevantTestMode then
        local testIndex = frame.index
        if testIndex == nil then
            if frame.unit == "player" then
                testIndex = 0
            elseif frame.unit then
                testIndex = tonumber(frame.unit:match("%d+")) or 0
            else
                testIndex = 0
            end
        end

        local testData = DF.GetTestUnitData and DF:GetTestUnitData(testIndex, frame.isRaidFrame)

        if testData and testData.dispelType then
            local overlay = CreateDispelOverlay(frame)
            local r, g, b = GetTestDispelColor(testData.dispelType, db)

            -- Calculate OOR alpha multiplier for test mode
            local oorMultiplier = 1.0
            if db.testShowOutOfRange and testData.outOfRange and not testData.status then
                local oorDispelAlpha = db.oorDispelOverlayAlpha or 0.55
                oorMultiplier = oorDispelAlpha
            end

            ShowOverlayWithRGB(overlay, r, g, b, db, testData.dispelType, oorMultiplier, frame, testData)
            -- Test mode doesn't use the last-rendered-aura skip — it has
            -- its own lifecycle and can re-render every tick cheaply.
            frame.dfLastDispelAuraID = nil
            if DF.UpdateContainerOverlayVisibility then
                DF:UpdateContainerOverlayVisibility(frame)
            end
        else
            HideDispelAndInvalidate(frame)
        end
        return
    end

    -- If we're in a test mode but this frame type doesn't match, hide any overlay and skip
    if (DF.raidTestMode and not isRaidFrame) or (DF.testMode and isRaidFrame) then
        HideDispelAndInvalidate(frame)
        return
    end

    -- Real unit detection
    if not unit or not UnitExists(unit) then
        if DF.debugDispel then
            print("|cffff0000DF Dispel:|r Hide - unit doesn't exist: " .. tostring(unit))
        end
        HideDispelAndInvalidate(frame)
        return
    end

    -- Check API availability
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex or not C_UnitAuras.GetAuraDispelTypeColor then
        if DF.debugDispel then
            print("|cffff0000DF Dispel:|r Hide - API not available")
        end
        HideDispelAndInvalidate(frame)
        return
    end
    
    -- Debug mode
    local debugMode = DF.debugDispel
    
    -- PERFORMANCE OPTIMIZATION: Use BlizzardAuraCache instead of scanning all 40 slots.
    local foundDispellable = false
    local lastDispellableID = nil
    local lastDispelType = nil

    -- Check if bleed/enrage overlay is enabled (user wants to see them)
    local bleedColor = db.dispelBleedColor
    local showBleeds = bleedColor and (bleedColor.r > 0 or bleedColor.g > 0 or bleedColor.b > 0)

    -- Determine dispel type:
    -- dispelOverlayDispelType (Blizzard convention): 1 = Dispellable By Me, 2 = All Dispellable
    local dispelType = db.dispelOverlayDispelType or 2

    local cache = DF.BlizzardAuraCache and DF.BlizzardAuraCache[unit]

    if dispelType == 1 then
        -- "Dispellable By Me": use playerDispellable cache (RAID_PLAYER_DISPELLABLE filtered)
        if cache and cache.playerDispellable then
            local auraInstanceID = next(cache.playerDispellable)
            if auraInstanceID then
                foundDispellable = true
                lastDispellableID = auraInstanceID
                if debugMode then
                    print("|cff00ff00DF Dispel:|r Found player-dispellable in cache: " .. tostring(auraInstanceID))
                end
            end
        end
    else
        -- "All Dispellable": prefer cache.allDispellable (populated by Direct mode's
        -- ClassifyAura via ScanUnitFull/ApplyAuraDelta, independently of the user's
        -- debuff filters, so the overlay fires even when the debuff is filtered out
        -- of icon display). Falls back to iterating cache.debuffsByID (which has
        -- full auraData) for Blizzard-mode units where allDispellable may be empty.
        if cache and cache.allDispellable and next(cache.allDispellable) then
            local auraInstanceID = next(cache.allDispellable)
            foundDispellable = true
            lastDispellableID = auraInstanceID
            if debugMode then
                print("|cff00ff00DF Dispel:|r Found all-dispellable (unfiltered): " .. tostring(auraInstanceID))
            end
        elseif cache and cache.debuffsByID then
            -- Read dispelName directly from cached aura data — no API call, no
            -- allocation. Fix A's ScanUnitFull/ApplyAuraDelta populate
            -- cache.debuffsByID with the full auraData tables we need. Nil
            -- checks on secret values are safe (verified) — they don't taint
            -- or compare.
            for id, aura in pairs(cache.debuffsByID) do
                if aura.dispelName ~= nil then
                    foundDispellable = true
                    lastDispellableID = id
                    if debugMode then
                        print("|cff00ff00DF Dispel:|r Found all-dispellable: " .. tostring(id))
                    end
                    break
                end
            end
        end
    end

    -- Scan for bleeds/enrages if enabled AND no regular dispellable found.
    -- Bleeds (dispelType 11) and enrages (dispelType 9) aren't captured by
    -- the dispellable filters above because they aren't dispellable in the
    -- standard sense.
    --
    -- Fix A optimization: read from cache.debuffsByID (populated by
    -- ScanUnitFull/ApplyAuraDelta) instead of calling GetAuraDataByIndex
    -- in a 1..40 loop. The cache already has the full auraData tables,
    -- so this is a pure read path — zero allocations vs the old slow
    -- path's ~10-20 fresh aura data tables per call.
    if showBleeds and not foundDispellable and cache and cache.debuffsByID then
        for id, aura in pairs(cache.debuffsByID) do
            local dispelType = aura.dispelType
            if dispelType == 11 or dispelType == 9 then
                foundDispellable = true
                lastDispellableID = id
                lastDispelType = dispelType
                if debugMode then
                    local typeName = dispelType == 11 and "BLEED" or "ENRAGE"
                    print("|cff00ff00DF Dispel:|r " .. (aura.name or "?") .. " - " .. typeName)
                end
                break  -- Found one, stop scanning
            end
        end
    end

    -- Fast path: if the dispellable aura hasn't changed since the last
    -- render, skip the entire render/hide path. In raid combat a
    -- dispellable debuff typically lasts several seconds — without this
    -- skip, UpdateDispelOverlay redraws the same overlay 20+ times for
    -- the same aura, calling GetAuraDispelTypeColor 8 times per redraw
    -- (each returning a fresh ColorMixin allocation) and re-running
    -- ApplyOverlayLayout (dozens of wasted SetPoint/SetSize calls).
    --
    -- The skip is safe because:
    --   * Same auraInstanceID implies same dispelType implies same colors
    --     (colors are derived deterministically from dispelType via curves).
    --   * Range state changes are handled by DF:ApplyDispelOverlayAppearance
    --     (called from ElementAppearance when range changes) — not by
    --     UpdateDispelOverlay — so we don't need to re-apply OOR alpha here.
    --   * lastDispelType comparison isn't needed because bleeds/enrages
    --     use the RGB path below which is driven purely by lastDispelType,
    --     and lastDispelType never changes for a given auraInstanceID.
    --   * Aura refreshes (updatedAuraInstanceIDs) keep the same
    --     auraInstanceID — dispel colors don't depend on duration/stacks.
    local newID = foundDispellable and lastDispellableID or nil
    if newID == frame.dfLastDispelAuraID then
        return  -- no change since last render; overlay is already correct
    end
    frame.dfLastDispelAuraID = newID

    if foundDispellable and lastDispellableID then
        -- Create overlay only when we need to show it
        local overlay = CreateDispelOverlay(frame)
        -- For bleeds (11) and enrages (9), use RGB fallback since they're not standard dispellable types
        if lastDispelType == 11 or lastDispelType == 9 then
            local typeName = lastDispelType == 11 and "Bleed" or "Enrage"
            local r, g, b = GetTestDispelColor(typeName, db)
            -- OOR alpha is handled by Range.lua via SetAlphaFromBoolean on each element
            -- Don't try to compare dfInRange as it may be a secret/tainted value
            ShowOverlayWithRGB(overlay, r, g, b, db, typeName, 1.0, frame)
        else
            -- Show overlay with per-element curves (custom colors and alphas baked in)
            ShowOverlayWithSecretColor(overlay, db, unit, lastDispellableID, frame)
        end
    else
        -- No dispellable debuffs found - hide overlay if it exists
        if frame.dfDispelOverlay then
            HideOverlay(frame.dfDispelOverlay)
        end
        RevertDispelNameText(frame)
        if debugMode then
            print("|cffff0000DF Dispel:|r No dispellable debuffs found")
        end
    end

    -- Gate the Blizzard native dispel overlay: show it only when DF's own
    -- overlay is hidden, so private auras still get an overlay without
    -- doubling up for normal dispellable debuffs.
    if DF.UpdateContainerOverlayVisibility then
        DF:UpdateContainerOverlayVisibility(frame)
    end
end

-- ============================================================
-- UPDATE ALL OVERLAYS
-- ============================================================

function DF:UpdateAllDispelOverlays()
    DF:IterateAllFrames(function(frame)
        if frame then
            DF:UpdateDispelOverlay(frame)
        end
    end)
end

-- Force clear all dispel overlays
function DF:ClearAllDispelOverlays()
    local function ClearFrame(frame)
        if frame then
            if frame.dfDispelOverlay then
                HideOverlay(frame.dfDispelOverlay)
            end
            RevertDispelNameText(frame)
            if DF.UpdateContainerOverlayVisibility then
                DF:UpdateContainerOverlayVisibility(frame)
            end
        end
    end

    DF:IterateAllFrames(function(frame)
        ClearFrame(frame)
    end)
end

-- ============================================================
-- FRAME LOOKUP
-- ============================================================

local function FindFrameByUnit(unit)
    if not unit then return nil end
    
    -- Fast path: use unitFrameMap
    if DF.unitFrameMap and DF.unitFrameMap[unit] then
        return DF.unitFrameMap[unit]
    end
    
    local foundFrame = nil
    
    DF:IterateAllFrames(function(frame)
        if frame and frame.unit == unit then
            foundFrame = frame
            return true  -- Stop iteration
        end
    end)
    
    return foundFrame
end

-- ============================================================
-- EVENT HANDLING
-- ============================================================

local eventFrame = CreateFrame("Frame")
-- PERFORMANCE FIX 2025-01-20: UNIT_AURA is now handled by the frame's own event handler
-- in Create.lua, which calls UpdateDispelOverlay directly. This avoids this frame
-- receiving ALL UNIT_AURA events in the game world just to filter them down.
-- eventFrame:RegisterEvent("UNIT_AURA")  -- REMOVED - handled by frame events now
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0.5, function()
            DF:UpdateAllDispelOverlays()
        end)
    end
end)

-- ============================================================
-- DEBUG COMMAND
-- ============================================================

function DF:DebugDispel(unit)
    unit = unit or "player"
    print("|cff00ff00DandersFrames:|r Dispel Debug for " .. unit)
    
    local db = DF:GetDB()
    print("  dispelOverlaySource: " .. tostring(db and db.dispelOverlaySource))
    print("  dispelOverlayDispelType: " .. tostring(db and db.dispelOverlayDispelType))
    
    -- Get debuffs sorted by expiration
    local sortRule = Enum.UnitAuraSortRule and Enum.UnitAuraSortRule.Expiration or 3
    local auras = C_UnitAuras.GetUnitAuras(unit, "HARMFUL", nil, sortRule)
    
    if not auras or #auras == 0 then
        print("  No debuffs found")
        return
    end
    
    print("  Found " .. #auras .. " debuffs (sorted by expiration)")
    
    -- Show debuffs with dispelName
    print("  |cffffcc00Debuffs:|r")
    local lastDispellable = nil
    for i, aura in ipairs(auras) do
        if i > 10 then break end
        local auraName = aura.name or "?"
        local dispelName = aura.dispelName
        
        if dispelName ~= nil then
            print(string.format("    [%d] %s - |cff00ff00%s|r", i, auraName, dispelName))
            lastDispellable = aura
        else
            print(string.format("    [%d] %s - |cffff0000nil (not dispellable)|r", i, auraName))
        end
    end
    
    if lastDispellable then
        print("  |cff00ff00Last dispellable:|r " .. (lastDispellable.name or "?") .. " (" .. lastDispellable.dispelName .. ")")
    else
        print("  |cffff0000No dispellable debuffs|r")
    end
    
    print("  |cffffcc00Frame/Overlay Status:|r")
    local frame = FindFrameByUnit(unit)
    if frame then
        print("    Frame found: YES")
        print("    Frame shown: " .. tostring(frame:IsShown()))
        if frame.dfDispelOverlay then
            local overlay = frame.dfDispelOverlay
            print("    Overlay exists: YES")
            print("    Overlay shown: " .. (overlay:IsShown() and "|cff00ff00YES|r" or "|cffff0000NO|r"))
            print("    Overlay alpha: " .. string.format("%.2f", overlay:GetAlpha()))
            if overlay.borderTop then
                print("    BorderTop shown: " .. tostring(overlay.borderTop:IsShown()))
            end
            if overlay.icons then
                local iconsShown = {}
                for name, icon in pairs(overlay.icons) do
                    if icon:IsShown() then
                        table.insert(iconsShown, name)
                    end
                end
                print("    Icons shown: " .. (#iconsShown > 0 and table.concat(iconsShown, ", ") or "none"))
            end
        else
            print("    Overlay exists: NO")
        end
    else
        print("    Frame found: NO")
    end
    
    -- Force update
    print("  |cffffcc00Forcing update...|r")
    if frame then
        DF:UpdateDispelOverlay(frame)
        C_Timer.After(0.1, function()
            if frame.dfDispelOverlay then
                print("  After update - Overlay shown: " .. tostring(frame.dfDispelOverlay:IsShown()))
            end
        end)
    end
end

SLASH_DFDISPEL1 = "/dfdispel"
SlashCmdList["DFDISPEL"] = function(msg)
    if msg == "debug" then
        DF.debugDispel = not DF.debugDispel
        print("|cff00ff00DandersFrames:|r Dispel debug " .. (DF.debugDispel and "|cff00ff00ENABLED|r" or "|cffff0000DISABLED|r"))
    elseif msg == "test" then
        -- Test dispelName field
        print("|cff00ff00DandersFrames:|r Testing dispelName field...")
        
        -- Test against first BUFF (should have nil dispelName)
        local buff = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
        if buff then
            print("  Buff: " .. (buff.name or "?"))
            print("  dispelName: " .. (buff.dispelName and ("|cff00ff00" .. buff.dispelName .. "|r") or "|cffff0000nil|r"))
        else
            print("  No buff found")
        end
        
        -- Test against first DEBUFF
        local debuff = C_UnitAuras.GetAuraDataByIndex("player", 1, "HARMFUL")
        if debuff then
            print("  Debuff: " .. (debuff.name or "?"))
            print("  dispelName: " .. (debuff.dispelName and ("|cff00ff00" .. debuff.dispelName .. "|r") or "|cffff0000nil|r"))
        else
            print("  No debuff found")
        end
    elseif msg == "cvar" then
        -- Test/discover dispel-related CVars
        print("|cff00ff00DandersFrames:|r Checking dispel-related CVars...")
        
        -- Known CVars to check
        local cvarsToCheck = {
            "raidFramesDisplayOnlyDispellableDebuffs",
            "showDispelDebuffs",
            "showCastableBuffs",
            "raidFramesDisplayDebuffs",
            "raidFramesDisplayDispellableDebuffs",
            "raidOptionDisplayOnlyDispellableDebuffs",
            "raidFramesDispelMode",
        }
        
        for _, cvarName in ipairs(cvarsToCheck) do
            local value = GetCVar(cvarName)
            if value then
                print(string.format("  %s = |cff00ff00%s|r", cvarName, tostring(value)))
            else
                print(string.format("  %s = |cffff0000not found|r", cvarName))
            end
        end
        
        -- Try to find the dropdown setting via Settings API
        print("")
        print("|cffffcc00Checking Settings API...|r")
        if Settings and Settings.GetValue then
            -- Try various possible setting names
            local settingsToCheck = {
                "PROXY_RAID_FRAMES_DISPLAY_ONLY_DISPELLABLE_DEBUFFS",
                "raidFramesDisplayOnlyDispellableDebuffs", 
                "dispelDebuffDisplayMode",
                "raidFramesDispelDebuffDisplayMode",
                "displayDispellableDebuffs",
            }
            for _, settingName in ipairs(settingsToCheck) do
                local ok, value = pcall(function() return Settings.GetValue(settingName) end)
                if ok and value ~= nil then
                    print(string.format("  Settings.%s = |cff00ff00%s|r", settingName, tostring(value)))
                end
            end
        end
        
        -- Check C_CVar for all cvars containing "dispel" or "debuff"
        print("")
        print("|cffffcc00Searching all CVars for 'dispel'...|r")
        if C_CVar and C_CVar.GetCVarInfo then
            -- Can't enumerate all CVars, but we can try specific ones
            local moreToCheck = {
                "raidFramesDisplayDispelDebuffs",
                "partyFramesDisplayOnlyDispellableDebuffs",
                "displayOnlyDispellableDebuffs",
                "dispelDebuffIndicatorMode",
                "raidOptionDispelDebuffIndicator",
            }
            for _, cvarName in ipairs(moreToCheck) do
                local value = GetCVar(cvarName)
                if value then
                    print(string.format("  %s = |cff00ff00%s|r", cvarName, tostring(value)))
                end
            end
        end
        
        -- Check EditMode settings if available
        print("")
        print("|cffffcc00Checking EditMode/CompactUnitFrame settings...|r")
        if EditModeManagerFrame then
            print("  EditModeManagerFrame exists")
        end
        
        -- Try to find the setting on CompactRaidFrameContainer
        if CompactRaidFrameContainer then
            print("  CompactRaidFrameContainer exists")
            if CompactRaidFrameContainer.displayOnlyDispellableDebuffs ~= nil then
                print("    .displayOnlyDispellableDebuffs = " .. tostring(CompactRaidFrameContainer.displayOnlyDispellableDebuffs))
            end
            if CompactRaidFrameContainer.dispelDebuffDisplayMode ~= nil then
                print("    .dispelDebuffDisplayMode = " .. tostring(CompactRaidFrameContainer.dispelDebuffDisplayMode))
            end
        end
        
        -- Check DefaultCompactUnitFrameSetupOptions
        if DefaultCompactUnitFrameSetupOptions then
            print("  DefaultCompactUnitFrameSetupOptions exists")
            for k, v in pairs(DefaultCompactUnitFrameSetupOptions) do
                if type(k) == "string" and (k:lower():find("dispel") or k:lower():find("debuff")) then
                    print(string.format("    .%s = %s", k, tostring(v)))
                end
            end
        end
        
        -- Check the raid profile settings
        if GetRaidProfileOption then
            print("")
            print("|cffffcc00Checking Raid Profile options...|r")
            local profile = GetActiveRaidProfile and GetActiveRaidProfile() or nil
            if profile then
                print("  Active profile: " .. tostring(profile))
                local optionsToCheck = {
                    "displayOnlyDispellableDebuffs",
                    "dispelDebuffDisplayMode",
                    "displayDebuffs",
                }
                for _, opt in ipairs(optionsToCheck) do
                    local ok, value = pcall(function() return GetRaidProfileOption(profile, opt) end)
                    if ok and value ~= nil then
                        print(string.format("    %s = |cff00ff00%s|r", opt, tostring(value)))
                    end
                end
            end
        end
        
    elseif msg == "cvar1" then
        -- Set to show only dispellable debuffs
        print("|cff00ff00DandersFrames:|r Setting raidFramesDisplayOnlyDispellableDebuffs = 1")
        SetCVar("raidFramesDisplayOnlyDispellableDebuffs", 1)
        
    elseif msg == "cvar0" then
        -- Set to show all debuffs
        print("|cff00ff00DandersFrames:|r Setting raidFramesDisplayOnlyDispellableDebuffs = 0")
        SetCVar("raidFramesDisplayOnlyDispellableDebuffs", 0)
        
    elseif msg == "indicator" then
        -- Check and show the raidFramesDispelIndicatorType setting
        print("|cff00ff00DandersFrames:|r Checking raidFramesDispelIndicatorType...")
        
        local indicatorType = nil
        
        -- Find a Blizzard compact unit frame to check
        local blizzFrame = nil
        for i = 1, 4 do
            local frame = _G["CompactPartyFrameMember" .. i]
            if frame and frame.optionTable then
                blizzFrame = frame
                break
            end
        end
        if not blizzFrame then
            for i = 1, 40 do
                local frame = _G["CompactRaidFrame" .. i]
                if frame and frame.optionTable then
                    blizzFrame = frame
                    break
                end
            end
        end
        
        if blizzFrame and blizzFrame.optionTable then
            indicatorType = blizzFrame.optionTable.raidFramesDispelIndicatorType
            print("  Current value: " .. tostring(indicatorType))
            if indicatorType == 0 then
                print("  Mode: |cffff0000DISABLED|r")
            elseif indicatorType == 1 then
                print("  Mode: |cff00ff00DISPELLABLE BY ME|r (optimal for PLAYER_DISPELLABLE)")
            elseif indicatorType == 2 then
                print("  Mode: |cffffaa00SHOW ALL|r")
            end
        else
            print("  |cffff0000Could not find Blizzard frame to check|r")
        end
        
    elseif msg == "setindicator" then
        -- This command has been disabled as modifying optionTable causes errors
        print("|cff00ff00DandersFrames:|r setindicator command disabled.")
        print("  Modifying frame.optionTable causes protected value errors in combat.")
        print("  Use the 'Show Overlay For' dropdown in DandersFrames settings instead.")
        print("  Our addon handles filtering internally based on that setting.")
        
    elseif msg == "dump" then
        -- Dump ALL properties from key objects
        print("|cff00ff00DandersFrames:|r Comprehensive dump...")
        
        -- Dump DefaultCompactUnitFrameSetupOptions
        print("")
        print("|cffffcc00DefaultCompactUnitFrameSetupOptions:|r")
        if DefaultCompactUnitFrameSetupOptions then
            for k, v in pairs(DefaultCompactUnitFrameSetupOptions) do
                print(string.format("  %s = %s (%s)", tostring(k), tostring(v), type(v)))
            end
        else
            print("  nil")
        end
        
        -- Dump DefaultCompactMiniFrameSetUpOptions
        print("")
        print("|cffffcc00DefaultCompactMiniFrameSetUpOptions:|r")
        if DefaultCompactMiniFrameSetUpOptions then
            for k, v in pairs(DefaultCompactMiniFrameSetUpOptions) do
                print(string.format("  %s = %s (%s)", tostring(k), tostring(v), type(v)))
            end
        else
            print("  nil")
        end
        
    elseif msg == "dump2" then
        -- Dump CompactRaidFrameManager settings
        print("|cff00ff00DandersFrames:|r Dumping CompactRaidFrameManager...")
        
        if CompactRaidFrameManager then
            print("  CompactRaidFrameManager exists")
            -- Check for setting-related properties
            for k, v in pairs(CompactRaidFrameManager) do
                if type(k) == "string" and type(v) ~= "function" and type(v) ~= "table" then
                    print(string.format("    %s = %s", k, tostring(v)))
                end
            end
            
            -- Check container
            if CompactRaidFrameManager.container then
                print("")
                print("  |cffffcc00.container properties:|r")
                for k, v in pairs(CompactRaidFrameManager.container) do
                    if type(k) == "string" and type(v) ~= "function" and type(v) ~= "table" then
                        print(string.format("    %s = %s", k, tostring(v)))
                    end
                end
            end
        else
            print("  nil")
        end
        
        -- Check CompactUnitFrameProfiles
        print("")
        print("|cffffcc00CompactUnitFrameProfiles:|r")
        if CompactUnitFrameProfiles then
            print("  exists")
            if CompactUnitFrameProfiles.selectedProfile then
                print("  selectedProfile = " .. tostring(CompactUnitFrameProfiles.selectedProfile))
            end
        else
            print("  nil")
        end
        
    elseif msg == "dump3" then
        -- Try to find the setting by checking a Blizzard compact frame directly
        print("|cff00ff00DandersFrames:|r Checking Blizzard frame options...")
        
        -- Find a Blizzard compact unit frame
        local blizzFrame = nil
        if CompactRaidFrameContainer then
            -- Try to get first raid frame
            for i = 1, 40 do
                local frameName = "CompactRaidFrame" .. i
                local frame = _G[frameName]
                if frame then
                    blizzFrame = frame
                    break
                end
            end
        end
        
        if not blizzFrame then
            -- Try party frames
            for i = 1, 4 do
                local frameName = "CompactPartyFrameMember" .. i
                local frame = _G[frameName]
                if frame then
                    blizzFrame = frame
                    break
                end
            end
        end
        
        if blizzFrame then
            print("  Found frame: " .. blizzFrame:GetName())
            
            -- Check optionTable
            if blizzFrame.optionTable then
                print("")
                print("  |cffffcc00.optionTable:|r")
                for k, v in pairs(blizzFrame.optionTable) do
                    if type(v) ~= "function" and type(v) ~= "table" then
                        local vStr = tostring(v)
                        if k:lower():find("dispel") or k:lower():find("debuff") then
                            print(string.format("    |cff00ff00%s = %s|r", k, vStr))
                        else
                            print(string.format("    %s = %s", k, vStr))
                        end
                    end
                end
            end
        else
            print("  No Blizzard compact frame found")
        end
        
    elseif msg == "dump4" then
        -- Deep search for dispel indicator setting source
        print("|cff00ff00DandersFrames:|r Searching for dispel indicator setting...")
        
        -- Check all GetCVarInfo for dispel-related CVars
        print("")
        print("|cffffcc00Searching CVars:|r")
        local cvarNames = {
            "raidFramesDispelIndicatorType",
            "raidFramesDisplayDispelDebuffs", 
            "showDispelDebuffs",
            "raidFramesDispelMode",
            "compactUnitFrameDispelIndicator",
        }
        for _, name in ipairs(cvarNames) do
            local val = GetCVar(name)
            if val then
                print("  " .. name .. " = " .. tostring(val))
            end
        end
        
        -- Check Settings API for dispel-related settings
        print("")
        print("|cffffcc00Checking Settings API:|r")
        if Settings then
            -- Try to find dispel-related settings
            local settingNames = {
                "raidFramesDispelIndicatorType",
                "PROXY_RAID_FRAMES_DISPEL_INDICATOR_TYPE",
                "RaidFramesDispelIndicator",
            }
            for _, name in ipairs(settingNames) do
                local ok, val = pcall(function() return Settings.GetValue(name) end)
                if ok and val ~= nil then
                    print("  Settings." .. name .. " = " .. tostring(val))
                end
            end
            
            -- Try to enumerate settings categories
            if Settings.GetAllCategories then
                local categories = Settings.GetAllCategories()
                if categories then
                    print("  Found " .. #categories .. " settings categories")
                end
            end
        else
            print("  Settings API not available")
        end
        
        -- Check DefaultCompactUnitFrameSetupOptions
        print("")
        print("|cffffcc00DefaultCompactUnitFrameSetupOptions:|r")
        if DefaultCompactUnitFrameSetupOptions then
            for k, v in pairs(DefaultCompactUnitFrameSetupOptions) do
                if type(k) == "string" and k:lower():find("dispel") then
                    print("  " .. k .. " = " .. tostring(v))
                end
            end
        end
        
        -- Check EditModeManagerFrame
        print("")
        print("|cffffcc00EditModeManagerFrame:|r")
        if EditModeManagerFrame then
            print("  exists")
            if EditModeManagerFrame.GetAccountSettingValue then
                local ok, val = pcall(function() 
                    return EditModeManagerFrame:GetAccountSettingValue(Enum.EditModeAccountSetting.ShowDispelDebuffs)
                end)
                if ok then
                    print("  ShowDispelDebuffs = " .. tostring(val))
                end
            end
        end
        
        -- Check if there's a function that provides the optionTable
        print("")
        print("|cffffcc00Checking option providers:|r")
        if DefaultCompactUnitFrameOptions then
            print("  DefaultCompactUnitFrameOptions exists")
            if type(DefaultCompactUnitFrameOptions) == "table" then
                for k, v in pairs(DefaultCompactUnitFrameOptions) do
                    if type(k) == "string" and k:lower():find("dispel") then
                        print("    " .. k .. " = " .. tostring(v))
                    end
                end
            end
        end
        
        if CompactUnitFrameProfilesGetAutoActivationState then
            print("  CompactUnitFrameProfilesGetAutoActivationState exists")
        end
        
        -- Check EditModeSettingDisplayInfoManager for dispel settings
        if EditModeSettingDisplayInfoManager then
            print("  EditModeSettingDisplayInfoManager exists")
        end

    elseif msg == "profile" then
        -- Dump all raid profile options
        print("|cff00ff00DandersFrames:|r Dumping Raid Profile options...")
        
        if GetActiveRaidProfile and GetRaidProfileOption then
            local profile = GetActiveRaidProfile()
            print("  Active profile: " .. tostring(profile))
            
            -- Try to get all options by checking known option names
            local knownOptions = {
                "keepGroupsTogether", "displayHealPrediction", "displayAggroHighlight",
                "displayBorder", "displayMainTankAndAssist", "displayPowerBar",
                "useClassColors", "displayPets", "sortBy", "healthText",
                "horizontalGroups", "displayNonBossDebuffs", "displayOnlyDispellableDebuffs",
                "frameWidth", "frameHeight", "autoActivate2Players", "autoActivate3Players",
                "autoActivate5Players", "autoActivate10Players", "autoActivate15Players",
                "autoActivate25Players", "autoActivate40Players", "locked",
            }
            
            for _, opt in ipairs(knownOptions) do
                local ok, value = pcall(function() return GetRaidProfileOption(profile, opt) end)
                if ok and value ~= nil then
                    print(string.format("    %s = %s", opt, tostring(value)))
                end
            end
            
            -- Also try dispel-specific ones
            print("")
            print("  |cffffcc00Dispel-related:|r")
            local dispelOptions = {
                "displayOnlyDispellableDebuffs",
                "dispelDebuffDisplayMode",
                "displayDispellableDebuffs",
                "dispelMode",
                "debuffDisplayMode",
            }
            for _, opt in ipairs(dispelOptions) do
                local ok, value = pcall(function() return GetRaidProfileOption(profile, opt) end)
                if ok and value ~= nil then
                    print(string.format("    %s = |cff00ff00%s|r", opt, tostring(value)))
                end
            end
        else
            print("  |cffff0000GetActiveRaidProfile or GetRaidProfileOption not available|r")
        end
        
    else
        DF:DebugDispel(msg ~= "" and msg or "player")
    end
end

-- ============================================================
-- PRIVATE AURA DISPEL SLOT TEST
-- Compares BlizzardAuraCache vs GetAuraSlots to detect private
-- dispellable auras that the cache can't see
-- ============================================================

SLASH_DFSLOTTEST1 = "/dfslottest"
SlashCmdList["DFSLOTTEST"] = function(msg)
    print("|cff00ff00DandersFrames:|r Private Aura Dispel Slot Test")
    print("")
    
    -- Check API availability
    if not C_UnitAuras or not C_UnitAuras.GetAuraSlots then
        print("  |cffff0000C_UnitAuras.GetAuraSlots not available!|r")
        return
    end
    
    -- Build unit list from current group
    local units = {}
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            table.insert(units, "raid" .. i)
        end
    elseif IsInGroup() then
        table.insert(units, "player")
        for i = 1, GetNumGroupMembers() - 1 do
            table.insert(units, "party" .. i)
        end
    else
        table.insert(units, "player")
    end
    
    print(string.format("  Scanning %d unit(s)...", #units))
    print(string.format("  %-12s  %-12s  %-12s  %s", "Unit", "Cache", "Slots", "Result"))
    print("  " .. string.rep("-", 60))
    
    local cacheHits, slotHits, mismatches = 0, 0, 0
    
    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            -- Check 1: Existing BlizzardAuraCache
            local cacheFound = false
            local cache = DF.BlizzardAuraCache and DF.BlizzardAuraCache[unit]
            if cache and cache.playerDispellable then
                local id = next(cache.playerDispellable)
                if id then cacheFound = true end
            end
            
            -- Check 2: GetAuraSlots with RAID_PLAYER_DISPELLABLE filter
            local slotsFound = false
            local ok, result = pcall(function()
                return C_UnitAuras.GetAuraSlots(unit, "HARMFUL|RAID_PLAYER_DISPELLABLE", 1)
            end)
            if ok and result then
                -- GetAuraSlots returns multiple values, not a table
                -- First return is count, then slot indices
                if type(result) == "number" and result > 0 then
                    slotsFound = true
                elseif type(result) == "table" and result[1] then
                    slotsFound = true
                end
            end
            
            -- Also try the multi-return form in case it doesn't return a table
            if not slotsFound then
                local ok2, count, slot1 = pcall(C_UnitAuras.GetAuraSlots, unit, "HARMFUL|RAID_PLAYER_DISPELLABLE", 1)
                if ok2 then
                    if type(count) == "number" and count > 0 then
                        slotsFound = true
                    elseif slot1 then
                        slotsFound = true
                    end
                end
            end
            
            -- Format result
            local cacheStr = cacheFound and "|cff00ff00YES|r" or "|cffff0000NO|r "
            local slotsStr = slotsFound and "|cff00ff00YES|r" or "|cffff0000NO|r "
            
            local result = ""
            if cacheFound then cacheHits = cacheHits + 1 end
            if slotsFound then slotHits = slotHits + 1 end
            
            if cacheFound and slotsFound then
                result = "|cff00ff00normal debuff|r"
            elseif not cacheFound and slotsFound then
                result = "|cffff00ffPRIVATE AURA!|r"
                mismatches = mismatches + 1
            elseif cacheFound and not slotsFound then
                result = "|cffffcc00cache only (stale?)|r"
                mismatches = mismatches + 1
            else
                result = "|cff888888clean|r"
            end
            
            local name = UnitName(unit) or unit
            print(string.format("  %-12s  %-12s  %-12s  %s", name, cacheStr, slotsStr, result))
        end
    end
    
    print("")
    print(string.format("  Summary: Cache=%d  Slots=%d  Private=%d", cacheHits, slotHits, mismatches))
    
    if mismatches > 0 then
        print("  |cffff00ff>> Private dispellable auras detected! GetAuraSlots works! <<|r")
    end
end
