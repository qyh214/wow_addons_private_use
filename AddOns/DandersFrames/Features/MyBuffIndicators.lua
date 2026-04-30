local addonName, DF = ...

-- ============================================================
-- MY BUFF INDICATORS (DEPRECATED)
-- Shows visual indicator when player has any buff on unit
--
-- This feature is currently hidden from the UI and force-disabled
-- for all users as of v4.0.12. The code is kept intact in case
-- the feature needs to be re-enabled in a future version.
-- The GUI tab, test mode checkbox, auto-profile category, and
-- out-of-range slider have all been removed from the UI.
-- ============================================================

local pairs = pairs
local CreateFrame = CreateFrame
local issecretvalue = issecretvalue

-- ============================================================
-- OVERLAY CREATION
-- ============================================================

local function CreateMyBuffOverlay(frame)
    if frame.dfMyBuffOverlay then
        return frame.dfMyBuffOverlay
    end
    
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    -- Frame level: above health bar content but below auras
    overlay:SetFrameLevel(frame:GetFrameLevel() + 6)
    
    -- Create border bars using StatusBar
    overlay.borderTop = CreateFrame("StatusBar", nil, overlay)
    overlay.borderTop:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderTop:SetMinMaxValues(0, 1)
    overlay.borderTop:SetValue(1)
    overlay.borderTop:GetStatusBarTexture():SetBlendMode("BLEND")
    
    overlay.borderBottom = CreateFrame("StatusBar", nil, overlay)
    overlay.borderBottom:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderBottom:SetMinMaxValues(0, 1)
    overlay.borderBottom:SetValue(1)
    overlay.borderBottom:GetStatusBarTexture():SetBlendMode("BLEND")
    
    overlay.borderLeft = CreateFrame("StatusBar", nil, overlay)
    overlay.borderLeft:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderLeft:SetMinMaxValues(0, 1)
    overlay.borderLeft:SetValue(1)
    overlay.borderLeft:GetStatusBarTexture():SetBlendMode("BLEND")
    
    overlay.borderRight = CreateFrame("StatusBar", nil, overlay)
    overlay.borderRight:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.borderRight:SetMinMaxValues(0, 1)
    overlay.borderRight:SetValue(1)
    overlay.borderRight:GetStatusBarTexture():SetBlendMode("BLEND")
    
    -- Pulse animation
    local pulseGroup = overlay:CreateAnimationGroup()
    pulseGroup:SetLooping("REPEAT")
    
    local fadeOut = pulseGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.4)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(1)
    
    local fadeIn = pulseGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.4)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(2)
    
    overlay.pulseAnim = pulseGroup
    
    -- Create gradient as StatusBar (so it can track health value like a health bar)
    -- Parent to healthBar if available for proper layering
    local gradientParent = frame.healthBar or overlay
    overlay.gradientStatusBar = CreateFrame("StatusBar", nil, gradientParent)
    overlay.gradientStatusBar:SetFrameLevel(gradientParent:GetFrameLevel() + 2)
    overlay.gradientStatusBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    overlay.gradientStatusBar:SetMinMaxValues(0, 1)
    overlay.gradientStatusBar:SetValue(1)
    overlay.gradientStatusBar:Hide()
    
    -- Store gradient parent reference for layout
    overlay.gradientParent = gradientParent
    
    -- EDGE style gradients (4 edges that fade inward) - these remain as textures
    overlay.gradientTop = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientTop:SetTexture("Interface\\Buttons\\WHITE8x8")
    overlay.gradientTop:Hide()
    
    overlay.gradientBottom = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientBottom:SetTexture("Interface\\Buttons\\WHITE8x8")
    overlay.gradientBottom:Hide()
    
    overlay.gradientLeft = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientLeft:SetTexture("Interface\\Buttons\\WHITE8x8")
    overlay.gradientLeft:Hide()
    
    overlay.gradientRight = gradientParent:CreateTexture(nil, "ARTWORK", nil, 2)
    overlay.gradientRight:SetTexture("Interface\\Buttons\\WHITE8x8")
    overlay.gradientRight:Hide()
    
    frame.dfMyBuffOverlay = overlay
    return overlay
end

-- ============================================================
-- LAYOUT
-- ============================================================

local function ApplyOverlayLayout(overlay, db, frame)
    if not overlay or not frame then return end
    
    local borderSize = db.myBuffIndicatorBorderSize or 2
    local inset = db.myBuffIndicatorBorderInset or 0
    local width, height = frame:GetWidth(), frame:GetHeight()
    
    if width <= 0 or height <= 0 then return end
    
    -- Top border
    overlay.borderTop:ClearAllPoints()
    overlay.borderTop:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -inset)
    overlay.borderTop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -inset, -inset)
    overlay.borderTop:SetHeight(borderSize)
    
    -- Bottom border
    overlay.borderBottom:ClearAllPoints()
    overlay.borderBottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", inset, inset)
    overlay.borderBottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, inset)
    overlay.borderBottom:SetHeight(borderSize)
    
    -- Left border
    overlay.borderLeft:ClearAllPoints()
    overlay.borderLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -inset - borderSize)
    overlay.borderLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", inset, inset + borderSize)
    overlay.borderLeft:SetWidth(borderSize)
    
    -- Right border
    overlay.borderRight:ClearAllPoints()
    overlay.borderRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -inset, -inset - borderSize)
    overlay.borderRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, inset + borderSize)
    overlay.borderRight:SetWidth(borderSize)
    
    -- Gradient layout
    local gradientSize = db.myBuffIndicatorGradientSize or 0.3
    local gradientStyle = db.myBuffIndicatorGradientStyle or "FULL"
    local gradientParent = overlay.gradientParent or frame
    local parentWidth = gradientParent:GetWidth()
    local parentHeight = gradientParent:GetHeight()
    
    overlay.gradientStatusBar:ClearAllPoints()
    overlay.gradientTop:ClearAllPoints()
    overlay.gradientBottom:ClearAllPoints()
    overlay.gradientLeft:ClearAllPoints()
    overlay.gradientRight:ClearAllPoints()
    
    if gradientStyle == "FULL" then
        local onCurrentHealth = db.myBuffIndicatorGradientOnCurrentHealth
        
        if onCurrentHealth and frame.healthBar then
            -- Position gradient to match health bar
            overlay.gradientStatusBar:SetAllPoints(gradientParent)
            
            -- Match health bar orientation and fill direction
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            if healthOrient == "HORIZONTAL" then
                overlay.gradientStatusBar:SetOrientation("HORIZONTAL")
                overlay.gradientStatusBar:SetReverseFill(false)
            elseif healthOrient == "HORIZONTAL_INV" then
                overlay.gradientStatusBar:SetOrientation("HORIZONTAL")
                overlay.gradientStatusBar:SetReverseFill(true)
            elseif healthOrient == "VERTICAL" then
                overlay.gradientStatusBar:SetOrientation("VERTICAL")
                overlay.gradientStatusBar:SetReverseFill(false)
            elseif healthOrient == "VERTICAL_INV" then
                overlay.gradientStatusBar:SetOrientation("VERTICAL")
                overlay.gradientStatusBar:SetReverseFill(true)
            end
            
            -- Mark this gradient as tracking health
            overlay.gradientTracksHealth = true
        else
            -- Standard full frame overlay
            overlay.gradientStatusBar:SetAllPoints(gradientParent)
            overlay.gradientStatusBar:SetOrientation("HORIZONTAL")
            overlay.gradientStatusBar:SetReverseFill(false)
            overlay.gradientStatusBar:SetMinMaxValues(0, 1)
            overlay.gradientStatusBar:SetValue(1)
            overlay.gradientTracksHealth = false
        end
    elseif gradientStyle == "TOP" then
        overlay.gradientStatusBar:SetPoint("TOPLEFT", gradientParent, "TOPLEFT", 0, 0)
        overlay.gradientStatusBar:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT", 0, 0)
        overlay.gradientStatusBar:SetHeight(parentHeight * gradientSize)
        overlay.gradientStatusBar:SetMinMaxValues(0, 1)
        overlay.gradientStatusBar:SetValue(1)
        overlay.gradientTracksHealth = false
    elseif gradientStyle == "BOTTOM" then
        overlay.gradientStatusBar:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT", 0, 0)
        overlay.gradientStatusBar:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT", 0, 0)
        overlay.gradientStatusBar:SetHeight(parentHeight * gradientSize)
        overlay.gradientStatusBar:SetMinMaxValues(0, 1)
        overlay.gradientStatusBar:SetValue(1)
        overlay.gradientTracksHealth = false
    elseif gradientStyle == "LEFT" then
        overlay.gradientStatusBar:SetPoint("TOPLEFT", gradientParent, "TOPLEFT", 0, 0)
        overlay.gradientStatusBar:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT", 0, 0)
        overlay.gradientStatusBar:SetWidth(parentWidth * gradientSize)
        overlay.gradientStatusBar:SetMinMaxValues(0, 1)
        overlay.gradientStatusBar:SetValue(1)
        overlay.gradientTracksHealth = false
    elseif gradientStyle == "RIGHT" then
        overlay.gradientStatusBar:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT", 0, 0)
        overlay.gradientStatusBar:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT", 0, 0)
        overlay.gradientStatusBar:SetWidth(parentWidth * gradientSize)
        overlay.gradientStatusBar:SetMinMaxValues(0, 1)
        overlay.gradientStatusBar:SetValue(1)
        overlay.gradientTracksHealth = false
    elseif gradientStyle == "EDGE" then
        -- EDGE style - gradients from each edge
        local edgeSize = parentHeight * gradientSize
        local edgeWidth = parentWidth * gradientSize
        
        overlay.gradientTop:SetPoint("TOPLEFT", gradientParent, "TOPLEFT", 0, 0)
        overlay.gradientTop:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT", 0, 0)
        overlay.gradientTop:SetHeight(edgeSize)
        
        overlay.gradientBottom:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT", 0, 0)
        overlay.gradientBottom:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT", 0, 0)
        overlay.gradientBottom:SetHeight(edgeSize)
        
        overlay.gradientLeft:SetPoint("TOPLEFT", gradientParent, "TOPLEFT", 0, 0)
        overlay.gradientLeft:SetPoint("BOTTOMLEFT", gradientParent, "BOTTOMLEFT", 0, 0)
        overlay.gradientLeft:SetWidth(edgeWidth)
        
        overlay.gradientRight:SetPoint("TOPRIGHT", gradientParent, "TOPRIGHT", 0, 0)
        overlay.gradientRight:SetPoint("BOTTOMRIGHT", gradientParent, "BOTTOMRIGHT", 0, 0)
        overlay.gradientRight:SetWidth(edgeWidth)
        
        overlay.gradientTracksHealth = false
    end
end

-- ============================================================
-- GRADIENT TEXTURES
-- ============================================================

local GRADIENT_TEXTURES = {
    LEFT = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H",      -- Fades left to right (solid left)
    RIGHT = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_H_Rev",  -- Fades right to left (solid right)
    TOP = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V",        -- Fades top to bottom (solid top)
    BOTTOM = "Interface\\AddOns\\DandersFrames\\Media\\DF_Gradient_V_Rev", -- Fades bottom to top (solid bottom)
    FULL = "Interface\\Buttons\\WHITE8x8",                                 -- Solid fill
}

-- ============================================================
-- SHOW / HIDE
-- ============================================================

local function HideAllGradients(overlay)
    if overlay.gradientStatusBar then overlay.gradientStatusBar:Hide() end
    if overlay.gradientTop then overlay.gradientTop:Hide() end
    if overlay.gradientBottom then overlay.gradientBottom:Hide() end
    if overlay.gradientLeft then overlay.gradientLeft:Hide() end
    if overlay.gradientRight then overlay.gradientRight:Hide() end
end

local function ShowOverlay(overlay, db, frame)
    if not overlay then return end
    
    ApplyOverlayLayout(overlay, db, frame)
    
    local color = db.myBuffIndicatorColor or {r = 0, g = 1, b = 0}
    local r, g, b = color.r, color.g, color.b
    
    -- Get OOR settings
    local inRange = true
    local oorAlpha = db.oorMyBuffIndicatorAlpha or 0.2
    if db.oorEnabled and frame and not DF.testMode and not DF.raidTestMode then
        inRange = frame.dfInRange
        if not (issecretvalue and issecretvalue(inRange)) and inRange == nil then inRange = true end
    end
    
    -- Show/hide borders and apply OOR
    if db.myBuffIndicatorShowBorder ~= false then
        local borderAlpha = db.myBuffIndicatorBorderAlpha or 0.8
        
        overlay.borderTop:GetStatusBarTexture():SetVertexColor(r, g, b, borderAlpha)
        overlay.borderTop:Show()
        if db.oorEnabled and overlay.borderTop.SetAlphaFromBoolean then
            overlay.borderTop:SetAlphaFromBoolean(inRange, 1.0, oorAlpha)
        end
        
        overlay.borderBottom:GetStatusBarTexture():SetVertexColor(r, g, b, borderAlpha)
        overlay.borderBottom:Show()
        if db.oorEnabled and overlay.borderBottom.SetAlphaFromBoolean then
            overlay.borderBottom:SetAlphaFromBoolean(inRange, 1.0, oorAlpha)
        end
        
        overlay.borderLeft:GetStatusBarTexture():SetVertexColor(r, g, b, borderAlpha)
        overlay.borderLeft:Show()
        if db.oorEnabled and overlay.borderLeft.SetAlphaFromBoolean then
            overlay.borderLeft:SetAlphaFromBoolean(inRange, 1.0, oorAlpha)
        end
        
        overlay.borderRight:GetStatusBarTexture():SetVertexColor(r, g, b, borderAlpha)
        overlay.borderRight:Show()
        if db.oorEnabled and overlay.borderRight.SetAlphaFromBoolean then
            overlay.borderRight:SetAlphaFromBoolean(inRange, 1.0, oorAlpha)
        end
    else
        overlay.borderTop:Hide()
        overlay.borderBottom:Hide()
        overlay.borderLeft:Hide()
        overlay.borderRight:Hide()
    end
    
    -- Show/hide gradients and apply OOR
    if db.myBuffIndicatorShowGradient then
        local gradientAlpha = db.myBuffIndicatorGradientAlpha or 0.3
        local gradientStyle = db.myBuffIndicatorGradientStyle or "FULL"
        
        -- Hide all first
        HideAllGradients(overlay)
        
        if gradientStyle == "EDGE" then
            -- EDGE style - gradients from each edge fading inward
            -- Calculate final alpha including OOR
            local finalAlpha = gradientAlpha
            if db.oorEnabled and not inRange then
                finalAlpha = gradientAlpha * oorAlpha
            end
            
            overlay.gradientTop:SetGradient("VERTICAL",
                CreateColor(r, g, b, 0),           -- Bottom (inner): transparent
                CreateColor(r, g, b, finalAlpha)   -- Top (outer): colored
            )
            overlay.gradientTop:Show()
            
            overlay.gradientBottom:SetGradient("VERTICAL",
                CreateColor(r, g, b, finalAlpha),  -- Bottom (outer): colored
                CreateColor(r, g, b, 0)            -- Top (inner): transparent
            )
            overlay.gradientBottom:Show()
            
            overlay.gradientLeft:SetGradient("HORIZONTAL",
                CreateColor(r, g, b, finalAlpha),  -- Left (outer): colored
                CreateColor(r, g, b, 0)            -- Right (inner): transparent
            )
            overlay.gradientLeft:Show()
            
            overlay.gradientRight:SetGradient("HORIZONTAL",
                CreateColor(r, g, b, 0),           -- Left (inner): transparent
                CreateColor(r, g, b, finalAlpha)   -- Right (outer): colored
            )
            overlay.gradientRight:Show()
        else
            -- Non-EDGE styles use the StatusBar with gradient texture files
            local texturePath = GRADIENT_TEXTURES[gradientStyle] or GRADIENT_TEXTURES.FULL
            overlay.gradientStatusBar:SetStatusBarTexture(texturePath)
            
            local tex = overlay.gradientStatusBar:GetStatusBarTexture()
            tex:SetVertexColor(r, g, b, gradientAlpha)
            
            overlay.gradientStatusBar:Show()
            
            -- Apply OOR via SetAlphaFromBoolean
            if db.oorEnabled and overlay.gradientStatusBar.SetAlphaFromBoolean then
                overlay.gradientStatusBar:SetAlphaFromBoolean(inRange, 1.0, oorAlpha)
            end
            
            -- Update health value if tracking (only for FULL style)
            if overlay.gradientTracksHealth and frame and frame.unit then
                DF:UpdateMyBuffGradientHealth(frame)
            end
        end
    else
        -- Hide all gradients
        HideAllGradients(overlay)
    end
    
    -- Animation
    if db.myBuffIndicatorAnimate and overlay.pulseAnim then
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
end

-- Public function for appearance updates (called by ElementAppearance.lua)
-- This just re-calls ShowOverlay which handles everything
function DF:ApplyMyBuffIndicatorAppearance(frame)
    if not frame or not frame.dfMyBuffOverlay then return end
    if not frame.dfMyBuffOverlay:IsShown() then return end
    
    local db = DF:GetFrameDB(frame)
    if not db then return end
    
    -- Re-apply the overlay to update OOR state
    ShowOverlay(frame.dfMyBuffOverlay, db, frame)
end

local function HideOverlay(overlay)
    if not overlay then return end
    
    -- Stop animation
    if overlay.pulseAnim and overlay.pulseAnim:IsPlaying() then
        overlay.pulseAnim:Stop()
    end
    overlay:SetAlpha(1)
    
    -- Hide borders
    overlay.borderTop:Hide()
    overlay.borderBottom:Hide()
    overlay.borderLeft:Hide()
    overlay.borderRight:Hide()
    
    -- Hide gradients
    HideAllGradients(overlay)
    
    overlay:Hide()
end

-- ============================================================
-- GRADIENT HEALTH UPDATE
-- ============================================================

function DF:UpdateMyBuffGradientHealth(frame)
    if not frame or not frame.dfMyBuffOverlay then return end
    
    local overlay = frame.dfMyBuffOverlay
    if not overlay.gradientTracksHealth then return end
    if not overlay.gradientStatusBar then return end
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
    
    overlay.gradientStatusBar:SetMinMaxValues(0, maxHealth)
    
    -- Use same smooth interpolation as health bar when enabled
    if smoothEnabled and Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut then
        overlay.gradientStatusBar:SetValue(currentHealth, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        overlay.gradientStatusBar:SetValue(currentHealth)
    end
end

-- ============================================================
-- MAIN UPDATE FUNCTION
-- ============================================================

function DF:UpdateMyBuffIndicator(frame)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if in test mode first (allows preview even when feature is disabled)
    local isRaidFrame = frame.isRaidFrame
    local inRelevantTestMode = (isRaidFrame and DF.raidTestMode) or (not isRaidFrame and DF.testMode)
    
    -- In test mode, check testShowMyBuffIndicator; otherwise check myBuffIndicatorEnabled
    if inRelevantTestMode then
        if not db or not db.testShowMyBuffIndicator then
            if frame.dfMyBuffOverlay then
                HideOverlay(frame.dfMyBuffOverlay)
            end
            return
        end
    else
        if not db or not db.myBuffIndicatorEnabled then
            if frame.dfMyBuffOverlay then
                HideOverlay(frame.dfMyBuffOverlay)
            end
            return
        end
        -- Aura Designer replaces My Buff Indicators — hide when AD is active
        if db.auraDesigner and db.auraDesigner.enabled then
            if frame.dfMyBuffOverlay then
                HideOverlay(frame.dfMyBuffOverlay)
            end
            return
        end
    end
    
    local unit = frame.unit
    
    -- Handle test mode
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
        
        if testData and testData.hasMyBuff then
            local overlay = CreateMyBuffOverlay(frame)
            ShowOverlay(overlay, db, frame)
            
            -- Update gradient health for test mode (only for FULL style with health tracking enabled)
            local gradientStyle = db.myBuffIndicatorGradientStyle or "FULL"
            local onCurrentHealth = db.myBuffIndicatorGradientOnCurrentHealth
            
            if gradientStyle == "FULL" and onCurrentHealth and testData.healthPercent then
                overlay.gradientStatusBar:SetMinMaxValues(0, 1)
                overlay.gradientStatusBar:SetValue(testData.healthPercent)
            end
        else
            if frame.dfMyBuffOverlay then
                HideOverlay(frame.dfMyBuffOverlay)
            end
        end
        return
    end
    
    -- If we're in a test mode but this frame type doesn't match, hide any overlay and skip
    if (DF.raidTestMode and not isRaidFrame) or (DF.testMode and isRaidFrame) then
        if frame.dfMyBuffOverlay then
            HideOverlay(frame.dfMyBuffOverlay)
        end
        return
    end
    
    -- Real unit detection
    if not unit or not UnitExists(unit) then
        if frame.dfMyBuffOverlay then
            HideOverlay(frame.dfMyBuffOverlay)
        end
        return
    end
    
    -- Check cache for player buffs
    local hasMyBuff = DF.UnitHasMyBuff and DF.UnitHasMyBuff(unit)
    
    if hasMyBuff then
        local overlay = CreateMyBuffOverlay(frame)
        ShowOverlay(overlay, db, frame)
    else
        if frame.dfMyBuffOverlay then
            HideOverlay(frame.dfMyBuffOverlay)
        end
    end
end

-- ============================================================
-- UPDATE ALL FRAMES
-- ============================================================

function DF:UpdateAllMyBuffIndicators()
    -- Handle test mode frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames and DF.testPartyFrames[i]
            if frame then DF:UpdateMyBuffIndicator(frame) end
        end
        return
    end
    
    if DF.raidTestMode then
        for i = 1, 40 do
            local frame = DF.testRaidFrames and DF.testRaidFrames[i]
            if frame then DF:UpdateMyBuffIndicator(frame) end
        end
        return
    end
    
    -- Regular frames
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            if frame then DF:UpdateMyBuffIndicator(frame) end
        end)
    end
    
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            if frame then DF:UpdateMyBuffIndicator(frame) end
        end)
    end
end

-- ============================================================
-- CLEAR ALL OVERLAYS
-- ============================================================

function DF:ClearAllMyBuffIndicators()
    local function ClearFrame(frame)
        if frame and frame.dfMyBuffOverlay then
            HideOverlay(frame.dfMyBuffOverlay)
        end
    end
    
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(ClearFrame)
    end
    
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(ClearFrame)
    end
end
