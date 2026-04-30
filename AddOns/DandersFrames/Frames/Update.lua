local addonName, DF = ...

-- ============================================================
-- FRAMES UPDATE MODULE
-- Contains frame update and layout functions
-- ============================================================

-- Local caching of frequently used globals and WoW API for performance.
-- Audit finding #3 (2026-04-06): UpdateHealthFast and UpdatePower are
-- called once per unit per UNIT_HEALTH / UNIT_POWER event, and each
-- call hits 3-5 of these unit API functions. In a 25-player raid at
-- typical combat event rates that's thousands of global hash lookups
-- per second that compile to nothing with these locals in scope.
-- Matching pattern: Frames/Bars.lua:8-19 already uses this pattern
-- for its own unit API calls.
local pairs, ipairs, type, tonumber, tostring = pairs, ipairs, type, tonumber, tostring
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local format = string.format
local issecretvalue = issecretvalue
local InCombatLockdown = InCombatLockdown
-- Unit health / power / state APIs (hot path in UpdateHealthFast + UpdatePower)
local UnitExists = UnitExists
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthMissing = UnitHealthMissing
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

-- Growth direction helper (file-scope, no closure allocation)
local function GetGrowthOffset(direction, iconSize, pad)
    if direction == "LEFT" then
        return -(iconSize + pad), 0
    elseif direction == "RIGHT" then
        return iconSize + pad, 0
    elseif direction == "UP" then
        return 0, iconSize + pad
    elseif direction == "DOWN" then
        return 0, -(iconSize + pad)
    end
    return 0, 0
end

-- Shared default tables (avoid per-call allocation)
local DEFAULT_EXPIRING_BORDER_COLOR = {r = 1, g = 0.5, b = 0, a = 1}
local DEFAULT_EXPIRING_TINT_COLOR = {r = 1, g = 0.3, b = 0.3, a = 0.3}

function DF:ApplyFrameLayout(frame)
    if not frame then return end
    
    -- Skip SetSize operations on secure header children during combat
    -- These frames are protected and cannot be resized in combat
    local isSecureChild = frame.dfIsHeaderChild
    local skipResize = isSecureChild and InCombatLockdown()
    
    local db = DF:GetFrameDB(frame)

    -- Frame size (with pixel-perfect support)
    -- Skip during combat for secure frames
    if not skipResize then
        local frameWidth = db.frameWidth or 120
        local frameHeight = db.frameHeight or 50
        DF:SetPixelPerfectSize(frame, frameWidth, frameHeight, db)
    end
    
    -- NOTE: We no longer skip layout during slider drag
    -- Throttling is now handled by ThrottledUpdateAll() instead
    
    -- ========================================
    -- HEALTH BAR
    -- ========================================
    local healthBar = frame.healthBar
    if healthBar then
        -- Texture
        local healthTex = db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar"
        healthBar:SetStatusBarTexture(healthTex)
        
        -- Orientation
        local orientation = db.healthOrientation or "HORIZONTAL"
        if orientation == "HORIZONTAL" then
            healthBar:SetOrientation("HORIZONTAL")
            healthBar:SetReverseFill(false)
            healthBar:SetRotatesTexture(false)
        elseif orientation == "HORIZONTAL_INV" then
            healthBar:SetOrientation("HORIZONTAL")
            healthBar:SetReverseFill(true)
            healthBar:SetRotatesTexture(false)
        elseif orientation == "VERTICAL" then
            healthBar:SetOrientation("VERTICAL")
            healthBar:SetReverseFill(false)
            healthBar:SetRotatesTexture(true)
        elseif orientation == "VERTICAL_INV" then
            healthBar:SetOrientation("VERTICAL")
            healthBar:SetReverseFill(true)
            healthBar:SetRotatesTexture(true)
        end
        
        -- Also apply to missing health bar (opposite fill direction)
        if frame.missingHealthBar then
            if orientation == "HORIZONTAL" then
                frame.missingHealthBar:SetOrientation("HORIZONTAL")
                frame.missingHealthBar:SetReverseFill(true)  -- Opposite of health bar
                frame.missingHealthBar:SetRotatesTexture(false)
            elseif orientation == "HORIZONTAL_INV" then
                frame.missingHealthBar:SetOrientation("HORIZONTAL")
                frame.missingHealthBar:SetReverseFill(false)  -- Opposite of health bar
                frame.missingHealthBar:SetRotatesTexture(false)
            elseif orientation == "VERTICAL" then
                frame.missingHealthBar:SetOrientation("VERTICAL")
                frame.missingHealthBar:SetReverseFill(true)  -- Opposite of health bar
                frame.missingHealthBar:SetRotatesTexture(true)
            elseif orientation == "VERTICAL_INV" then
                frame.missingHealthBar:SetOrientation("VERTICAL")
                frame.missingHealthBar:SetReverseFill(false)  -- Opposite of health bar
                frame.missingHealthBar:SetRotatesTexture(true)
            end
        end
    end
    
    -- ========================================
    -- RESOURCE/POWER BAR LAYOUT
    -- Delegated to ApplyResourceBarLayout which handles show/hide,
    -- role filtering, layout, background, border, and frame level
    -- ========================================
    DF:ApplyResourceBarLayout(frame)
    
    -- ========================================
    -- ABSORB BAR LAYOUT
    -- ========================================
    local absorbBar = frame.dfAbsorbBar
    if absorbBar then
        local absorbMode = db.absorbBarMode or "OVERLAY"
        local absorbTex = db.absorbBarTexture or "Interface\\Buttons\\WHITE8x8"
        local absorbColor = db.absorbBarColor or {r = 0, g = 0.835, b = 1, a = 0.7}
        
        absorbBar:SetStatusBarTexture(absorbTex)
        absorbBar:SetStatusBarColor(absorbColor.r, absorbColor.g, absorbColor.b, absorbColor.a)
        
        if absorbMode == "FLOATING" then
            -- Floating mode positioning
            absorbBar:ClearAllPoints()
            local anchor = db.absorbBarAnchor or "BOTTOM"
            absorbBar:SetPoint(anchor, frame, anchor, db.absorbBarX or 0, db.absorbBarY or 0)
            
            -- Apply pixel-perfect sizing
            local absorbWidth = db.absorbBarWidth or 50
            local absorbHeight = db.absorbBarHeight or 6
            if db.pixelPerfect then
                absorbWidth = DF:PixelPerfect(absorbWidth)
                absorbHeight = DF:PixelPerfect(absorbHeight)
            end
            absorbBar:SetSize(absorbWidth, absorbHeight)
            
            local orient = db.absorbBarOrientation or "HORIZONTAL"
            absorbBar:SetOrientation(orient)
            absorbBar:SetReverseFill(db.absorbBarReverse or false)
            
            if absorbBar.bg then
                local bgC = db.absorbBarBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
                absorbBar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
            end
        end
    end
    
    -- ========================================
    -- HEAL ABSORB BAR LAYOUT
    -- ========================================
    local healAbsorbBar = frame.dfHealAbsorbBar
    if healAbsorbBar then
        local healAbsorbMode = db.healAbsorbBarMode or "OVERLAY"
        local healAbsorbTex = db.healAbsorbBarTexture or "Interface\\Buttons\\WHITE8x8"
        local healAbsorbColor = db.healAbsorbBarColor or {r = 0.4, g = 0.1, b = 0.1, a = 0.7}
        
        healAbsorbBar:SetStatusBarTexture(healAbsorbTex)
        healAbsorbBar:SetStatusBarColor(healAbsorbColor.r, healAbsorbColor.g, healAbsorbColor.b, healAbsorbColor.a)
        
        if healAbsorbMode == "FLOATING" then
            -- Floating mode positioning
            healAbsorbBar:ClearAllPoints()
            local anchor = db.healAbsorbBarAnchor or "BOTTOM"
            healAbsorbBar:SetPoint(anchor, frame, anchor, db.healAbsorbBarX or 0, db.healAbsorbBarY or -10)
            
            -- Apply pixel-perfect sizing
            local healAbsorbWidth = db.healAbsorbBarWidth or 50
            local healAbsorbHeight = db.healAbsorbBarHeight or 6
            if db.pixelPerfect then
                healAbsorbWidth = DF:PixelPerfect(healAbsorbWidth)
                healAbsorbHeight = DF:PixelPerfect(healAbsorbHeight)
            end
            healAbsorbBar:SetSize(healAbsorbWidth, healAbsorbHeight)
            
            local orient = db.healAbsorbBarOrientation or "HORIZONTAL"
            healAbsorbBar:SetOrientation(orient)
            healAbsorbBar:SetReverseFill(db.healAbsorbBarReverse or false)
            
            if healAbsorbBar.bg then
                local bgC = db.healAbsorbBarBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
                healAbsorbBar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
            end
        end
    end
    
    -- ========================================
    -- BORDER
    -- ========================================
    if frame.border then
        local showBorder = db.showFrameBorder ~= false
        local borderSize = db.borderSize or 1
        local borderColor = db.borderColor or {r = 0, g = 0, b = 0, a = 1}
        
        -- Apply pixel-perfect sizing to border 
        if db.pixelPerfect then
            borderSize = DF:PixelPerfect(borderSize)
        end
        
        if showBorder and frame.border.top then
            frame.border.top:SetHeight(borderSize)
            frame.border.top:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.top:Show()
            
            frame.border.bottom:SetHeight(borderSize)
            frame.border.bottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.bottom:Show()
            
            frame.border.left:SetWidth(borderSize)
            frame.border.left:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.left:Show()
            
            frame.border.right:SetWidth(borderSize)
            frame.border.right:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.right:Show()
        elseif frame.border.top then
            frame.border.top:Hide()
            frame.border.bottom:Hide()
            frame.border.left:Hide()
            frame.border.right:Hide()
        end
    end
    
    -- ========================================
    -- NAME TEXT
    -- ========================================
    if frame.nameText then
        local nameFont = db.nameFont or "Fonts\\FRIZQT__.TTF"
        local nameFontSize = db.nameFontSize or 11
        local nameOutline = db.nameTextOutline or "OUTLINE"
        if nameOutline == "NONE" then nameOutline = "" end
        
        DF:SafeSetFont(frame.nameText, nameFont, nameFontSize, nameOutline)
        
        local nameAnchor = db.nameTextAnchor or "TOP"
        frame.nameText:ClearAllPoints()
        frame.nameText:SetPoint(nameAnchor, frame, nameAnchor, db.nameTextX or 0, db.nameTextY or -2)
        
        -- Defer color AND alpha to the appearance system so OOR fading is respected.
        -- Previously this hardcoded alpha=1.0 which overrode range fading on roster changes.
        if DF.UpdateNameTextAppearance then
            DF:UpdateNameTextAppearance(frame)
        elseif not db.nameTextUseClassColor then
            local nameColor = db.nameTextColor or {r = 1, g = 1, b = 1, a = 1}
            frame.nameText:SetTextColor(nameColor.r, nameColor.g, nameColor.b, nameColor.a or 1)
        end
    end
    
    -- ========================================
    -- HEALTH TEXT
    -- ========================================
    if frame.healthText then
        local healthFont = db.healthFont or "Fonts\\FRIZQT__.TTF"
        local healthFontSize = db.healthFontSize or 10
        local healthOutline = db.healthTextOutline or "OUTLINE"
        if healthOutline == "NONE" then healthOutline = "" end
        
        DF:SafeSetFont(frame.healthText, healthFont, healthFontSize, healthOutline)
        
        local healthAnchor = db.healthTextAnchor or "CENTER"
        frame.healthText:ClearAllPoints()
        frame.healthText:SetPoint(healthAnchor, frame, healthAnchor, db.healthTextX or 0, db.healthTextY or 0)
        
        if DF.UpdateHealthTextAppearance then
            DF:UpdateHealthTextAppearance(frame)
        elseif not db.healthTextUseClassColor then
            local healthTextColor = db.healthTextColor or {r = 1, g = 1, b = 1, a = 1}
            frame.healthText:SetTextColor(healthTextColor.r, healthTextColor.g, healthTextColor.b, healthTextColor.a or 1)
        end
    end
    
    -- ========================================
    -- STATUS TEXT
    -- ========================================
    if frame.statusText then
        local statusFont = db.statusTextFont or "Fonts\\FRIZQT__.TTF"
        local statusFontSize = db.statusTextFontSize or 10
        local statusOutline = db.statusTextOutline or "OUTLINE"
        if statusOutline == "NONE" then statusOutline = "" end
        
        DF:SafeSetFont(frame.statusText, statusFont, statusFontSize, statusOutline)
        
        local statusAnchor = db.statusTextAnchor or "CENTER"
        frame.statusText:ClearAllPoints()
        frame.statusText:SetPoint(statusAnchor, frame, statusAnchor, db.statusTextX or 0, db.statusTextY or 0)
        
        if DF.UpdateStatusTextAppearance then
            DF:UpdateStatusTextAppearance(frame)
        else
            local statusColor = db.statusTextColor or {r = 1, g = 1, b = 1, a = 1}
            frame.statusText:SetTextColor(statusColor.r, statusColor.g, statusColor.b, statusColor.a or 1)
        end
    end
    
    -- ========================================
    -- ROLE ICON
    -- ========================================
    if frame.roleIcon then
        local showRole = db.showRoleIcon ~= false
        local roleScale = db.roleIconScale or 1.0
        local roleAnchor = db.roleIconAnchor or "TOPLEFT"
        local roleX = db.roleIconX or 2
        local roleY = db.roleIconY or -2
        
        local roleSize = 18 * roleScale
        if db.pixelPerfect then
            roleSize = DF:PixelPerfect(roleSize)
        end
        frame.roleIcon:SetSize(roleSize, roleSize)
        frame.roleIcon:ClearAllPoints()
        frame.roleIcon:SetPoint(roleAnchor, frame, roleAnchor, roleX, roleY)
    end
    
    -- ========================================
    -- RAID TARGET ICON
    -- ========================================
    if frame.raidTargetIcon then
        local raidTargetScale = db.raidTargetIconScale or 1.0
        local raidTargetAnchor = db.raidTargetIconAnchor or "TOP"
        local raidTargetX = db.raidTargetIconX or 0
        local raidTargetY = db.raidTargetIconY or 2
        
        local raidTargetSize = 16 * raidTargetScale
        if db.pixelPerfect then
            raidTargetSize = DF:PixelPerfect(raidTargetSize)
        end
        frame.raidTargetIcon:SetSize(raidTargetSize, raidTargetSize)
        frame.raidTargetIcon:ClearAllPoints()
        frame.raidTargetIcon:SetPoint(raidTargetAnchor, frame, raidTargetAnchor, raidTargetX, raidTargetY)
    end
    
    -- ========================================
    -- LEADER ICON
    -- ========================================
    -- Positioning handled by UpdateLeaderIcon in Bars.lua to avoid duplication
    if frame.leaderIcon then
        local leaderSize = 12
        if db.pixelPerfect then
            leaderSize = DF:PixelPerfect(leaderSize)
        end
        frame.leaderIcon:SetSize(leaderSize, leaderSize)
        -- Call UpdateLeaderIcon for positioning (respects user settings)
        if DF.UpdateLeaderIcon then
            DF:UpdateLeaderIcon(frame)
        end
    end
    
    -- ========================================
    -- READY CHECK ICON
    -- ========================================
    if frame.readyCheckIcon then
        local readyCheckSize = 16
        if db.pixelPerfect then
            readyCheckSize = DF:PixelPerfect(readyCheckSize)
        end
        frame.readyCheckIcon:SetSize(readyCheckSize, readyCheckSize)
    end
    
    -- ========================================
    -- CENTER STATUS ICON
    -- ========================================
    if frame.centerStatusIcon then
        local centerStatusSize = 16
        if db.pixelPerfect then
            centerStatusSize = DF:PixelPerfect(centerStatusSize)
        end
        frame.centerStatusIcon:SetSize(centerStatusSize, centerStatusSize)
    end
    
    -- ========================================
    -- RESTED INDICATOR
    -- ========================================
    if frame.restedIndicator then
        local restedSize = db.restedIndicatorSize or 20
        -- Use new corner-hanging defaults; ignore old values that were for inside-frame positioning
        local restedX = db.restedIndicatorOffsetX
        local restedY = db.restedIndicatorOffsetY
        -- If using old default values (around -2), switch to new defaults
        if not restedX or restedX > -10 then restedX = -18 end
        if not restedY or restedY > -10 then restedY = -14 end
        
        if db.pixelPerfect then
            restedSize = DF:PixelPerfect(restedSize)
        end
        -- Width is 1.2x height for the ZZZ layout
        frame.restedIndicator:SetSize(restedSize * 1.2, restedSize * 0.9)
        frame.restedIndicator:ClearAllPoints()
        frame.restedIndicator:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", restedX, restedY)
    end
    
    -- ========================================
    -- MISSING BUFF ICON
    -- ========================================
    if frame.missingBuffFrame then
        local missingBuffSize = db.missingBuffIconSize or 24
        if db.pixelPerfect then
            missingBuffSize = DF:PixelPerfect(missingBuffSize)
        end
        frame.missingBuffFrame:SetSize(missingBuffSize, missingBuffSize)
    end
    
    -- ========================================
    -- BACKGROUND COLOR & TEXTURE
    -- ========================================
    if frame.background then
        local bgTexture = db.backgroundTexture or "Solid"
        
        -- Apply texture only (color is handled by ElementAppearance)
        if bgTexture == "Solid" or bgTexture == "" then
            -- Solid color mode - just mark texture type, color set by ElementAppearance
            frame.dfCurrentBgTexture = "Solid"
        else
            -- Textured background - only call SetTexture if texture path changed
            if frame.dfCurrentBgTexture ~= bgTexture then
                frame.background:SetTexture(bgTexture)
                frame.background:SetHorizTile(false)
                frame.background:SetVertTile(false)
                frame.dfCurrentBgTexture = bgTexture
                frame.dfCurrentBgKey = nil  -- Clear key when switching to textured
            end
            
            -- Ensure SetAlpha is 1.0 for textured backgrounds (alpha controlled via vertex color)
            frame.background:SetAlpha(1.0)
        end
        
        -- Delegate color to ElementAppearance for centralized handling
        DF:UpdateBackgroundAppearance(frame)
        
        --[[ TODO CLEANUP: Old background color code - now handled by ElementAppearance
        local bgMode = db.backgroundColorMode or "CUSTOM"
        
        -- For BLACK/BLIZZARD mode, treat as CUSTOM with black color
        -- This ensures identical code path to avoid any flickering differences
        local effectiveBgMode = bgMode
        local effectiveBgColor
        if bgMode == "BLIZZARD" or bgMode == "BLACK" then
            effectiveBgMode = "CUSTOM"
            effectiveBgColor = {r = 0, g = 0, b = 0, a = 0.8}
        end
        
        -- Apply texture (use Solid as fallback for ColorTexture behavior)
        if bgTexture == "Solid" or bgTexture == "" then
            -- Solid color mode - update cache and use key tracking to prevent flickering
            frame.dfCurrentBgTexture = "Solid"
            if effectiveBgMode == "CUSTOM" then
                local c = effectiveBgColor or db.backgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                local key = string.format("CUSTOM:%.2f:%.2f:%.2f:%.2f", c.r, c.g, c.b, c.a or 0.8)
                if frame.dfCurrentBgKey ~= key then
                    frame.background:SetColorTexture(c.r, c.g, c.b, c.a or 0.8)
                    frame.dfCurrentBgKey = key
                end
            elseif effectiveBgMode == "CLASS" then
                local unit = frame.unit
                local classColor = {r = 0, g = 0, b = 0}
                if unit and UnitExists(unit) then
                    local _, class = UnitClass(unit)
                    classColor = DF:GetClassColor(class)
                end
                local bgAlpha = db.backgroundClassAlpha or 0.3
                local key = string.format("CLASS:%.2f:%.2f:%.2f:%.2f", classColor.r, classColor.g, classColor.b, bgAlpha)
                if frame.dfCurrentBgKey ~= key then
                    frame.background:SetColorTexture(classColor.r, classColor.g, classColor.b, bgAlpha)
                    frame.dfCurrentBgKey = key
                end
            end
        else
            -- Textured background - only call SetTexture if texture path changed
            if frame.dfCurrentBgTexture ~= bgTexture then
                frame.background:SetTexture(bgTexture)
                frame.background:SetHorizTile(false)
                frame.background:SetVertTile(false)
                frame.dfCurrentBgTexture = bgTexture
                frame.dfCurrentBgKey = nil  -- Clear key when switching to textured
            end
            
            -- Ensure SetAlpha is 1.0 for textured backgrounds (alpha controlled via vertex color)
            frame.background:SetAlpha(1.0)
            
            -- Always update vertex color (includes alpha)
            if effectiveBgMode == "CUSTOM" then
                local c = effectiveBgColor or db.backgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                frame.background:SetVertexColor(c.r, c.g, c.b, c.a or 0.8)
            elseif effectiveBgMode == "CLASS" then
                local unit = frame.unit
                local classColor = {r = 0, g = 0, b = 0}
                if unit and UnitExists(unit) then
                    local _, class = UnitClass(unit)
                    classColor = DF:GetClassColor(class)
                end
                local bgAlpha = db.backgroundClassAlpha or 0.3
                frame.background:SetVertexColor(classColor.r, classColor.g, classColor.b, bgAlpha)
            end
        end
        --]]
    end
    
    -- Apply aura layout
    DF:ApplyAuraLayout(frame, "BUFF")
    DF:ApplyAuraLayout(frame, "DEBUFF")
end

-- ============================================================
-- UNIFIED FRAME UPDATE
-- ============================================================

function DF:UpdateUnitFrame(frame, source)
    if DF.RosterDebugCount then 
        DF:RosterDebugCount("UpdateUnitFrame")
        if source then
            DF:RosterDebugCount("UpdateUnitFrame:" .. source)
        end
    end
    if not frame or not frame.unit then return end
    
    -- Skip if in test mode (test mode has its own update)
    local isRaid = DF:IsRaidFrame(frame)
    if isRaid and DF.raidTestMode then return end
    if not isRaid and DF.testMode then return end
    
    local unit = frame.unit
    if not UnitExists(unit) then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- ========================================
    -- OFFLINE CHECK
    -- ========================================
    local isConnected = UnitIsConnected(unit)
    if not isConnected then
        -- Show offline state
        if frame.healthBar then
            -- FIX: Use SetMinMaxValues(0, 100) + SetValue(100) to match UpdateHealthFast.
            -- Previously used SetValue(1) without setting min/max, which could show as
            -- 1% health if the bar range was 0-100 from a prior SetHealthBarValue call.
            frame.healthBar:SetMinMaxValues(0, 100)
            frame.healthBar:SetValue(100)
            -- TODO CLEANUP: Color now handled by ElementAppearance via ApplyDeadFade
            -- frame.healthBar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        end
        if frame.nameText then
            local name = DF:GetUnitName(unit) or unit
            -- Truncate name if needed (UTF-8 aware)
            local nameLength = db.nameTextLength or 0
            if nameLength > 0 and DF:UTF8Len(name) > nameLength then
                if db.nameTextTruncateMode == "ELLIPSIS" then
                    name = DF:UTF8Sub(name, 1, nameLength) .. "..."
                else
                    name = DF:UTF8Sub(name, 1, nameLength)
                end
            end
            frame.nameText:SetText(name)
            -- TODO CLEANUP: Color now handled by ElementAppearance via ApplyDeadFade
            -- frame.nameText:SetTextColor(0.5, 0.5, 0.5, 1)
        end
        if frame.statusText then
            if db.statusTextEnabled ~= false then
                frame.statusText:SetText("Offline")
                frame.statusText:Show()
            else
                frame.statusText:Hide()
            end
        end
        if frame.healthText then
            frame.healthText:Hide()
        end
        if frame.dfPowerBar then
            frame.dfPowerBar:Hide()
        end
        if frame.dfAbsorbBar then
            frame.dfAbsorbBar:Hide()
        end
        if frame.dfHealAbsorbBar then
            frame.dfHealAbsorbBar:Hide()
        end
        -- Apply dead fade for offline units
        DF:ApplyDeadFade(frame, "Offline")
        frame.dfLastKnownConnected = false
        return
    end

    -- ========================================
    -- DEAD/GHOST CHECK
    -- ========================================
    local isDead = UnitIsDead(unit)
    local isGhost = UnitIsGhost(unit)
    
    if isDead or isGhost then
        if frame.healthBar then
            frame.healthBar:SetMinMaxValues(0, 100)
            frame.healthBar:SetValue(0)
            -- TODO CLEANUP: Color now handled by ElementAppearance via ApplyDeadFade
            -- frame.healthBar:SetStatusBarColor(0.3, 0.3, 0.3, 1)
        end
        if frame.nameText then
            local name = DF:GetUnitName(unit) or unit
            -- Truncate name if needed (UTF-8 aware)
            local nameLength = db.nameTextLength or 0
            if nameLength > 0 and DF:UTF8Len(name) > nameLength then
                if db.nameTextTruncateMode == "ELLIPSIS" then
                    name = DF:UTF8Sub(name, 1, nameLength) .. "..."
                else
                    name = DF:UTF8Sub(name, 1, nameLength)
                end
            end
            frame.nameText:SetText(name)
            -- TODO CLEANUP: Color now handled by ElementAppearance via ApplyDeadFade
            -- frame.nameText:SetTextColor(0.5, 0.5, 0.5, 1)
        end
        if frame.statusText then
            if db.statusTextEnabled ~= false then
                frame.statusText:SetText(isGhost and "Ghost" or "Dead")
                frame.statusText:Show()
            else
                frame.statusText:Hide()
            end
        end
        if frame.healthText then
            frame.healthText:Hide()
        end
        if frame.dfPowerBar then
            frame.dfPowerBar:Hide()
        end
        if frame.dfAbsorbBar then
            frame.dfAbsorbBar:Hide()
        end
        if frame.dfHealAbsorbBar then
            frame.dfHealAbsorbBar:Hide()
        end
        
        -- Still update leader and raid target icons (role icons handled separately)
        DF:UpdateLeaderIcon(frame)
        DF:UpdateRaidTargetIcon(frame)
        -- Apply dead fade for dead/ghost units
        DF:ApplyDeadFade(frame, "Dead")
        return
    end
    
    -- Unit is alive and connected - reset dead fade if it was applied
    DF:ResetDeadFade(frame)
    frame.dfLastKnownConnected = true

    -- Clear status text for alive units
    if frame.statusText then
        frame.statusText:SetText("")
        frame.statusText:Hide()
    end

    -- ========================================
    -- HEALTH
    -- ========================================
    if frame.healthBar then
        -- Use helper function that handles CurveConstants fallback
        DF.SetHealthBarValue(frame.healthBar, unit, frame)
        
        -- Delegate color to ElementAppearance for centralized handling
        -- This prevents conflicts between multiple code paths trying to set color
        DF:UpdateHealthBarAppearance(frame)
        
        --[[ TODO CLEANUP: Old color code - now handled by ElementAppearance
        -- Skip color setting if aggro color override is active
        if not (frame.dfAggroActive and frame.dfAggroColor) then
            -- Health color based on mode
            local colorMode = db.healthColorMode or "CLASS"
            local _, class = UnitClass(unit)
            local classColor = DF:GetClassColor(class)
            local alpha = db.classColorAlpha or 1.0
            
            if colorMode == "CLASS" then
                frame.healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, alpha)
            elseif colorMode == "PERCENT" then
                -- Use UnitHealthPercent with a curve as 3rd arg - returns color directly
                local curve = DF:GetCurveForUnit(unit, db)
                if curve and UnitHealthPercent then
                    local color = UnitHealthPercent(unit, true, curve)
                    if color then
                        local tex = frame.healthBar:GetStatusBarTexture()
                        if tex then
                            tex:SetVertexColor(color:GetRGB())
                            tex:SetAlpha(alpha)
                        end
                    else
                        frame.healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, alpha)
                    end
                else
                    frame.healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, alpha)
                end
            elseif colorMode == "CUSTOM" then
                local c = db.healthColor or {r = 0.2, g = 0.8, b = 0.2, a = 1}
                frame.healthBar:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
            end
        end
        --]]
    end
    
    -- ========================================
    -- MISSING HEALTH BAR
    -- ========================================
    if frame.missingHealthBar then
        DF.SetMissingHealthBarValue(frame.missingHealthBar, unit, frame)
    end
    
    -- ========================================
    -- BACKGROUND COLOR & TEXTURE
    -- ========================================
    -- Delegate to ElementAppearance for centralized handling
    -- This prevents conflicts between Update.lua, Colors.lua, and Range.lua
    DF:UpdateBackgroundAppearance(frame)
    
    --[[ TODO CLEANUP: Old background color code - now handled by ElementAppearance
    if frame.background then
        local bgMode = db.backgroundColorMode or "CUSTOM"
        local bgTexture = db.backgroundTexture or "Solid"
        
        -- For BLACK/BLIZZARD mode, treat as CUSTOM with black color
        -- This ensures identical code path to avoid any flickering differences
        local effectiveBgMode = bgMode
        local effectiveBgColor
        if bgMode == "BLIZZARD" or bgMode == "BLACK" then
            effectiveBgMode = "CUSTOM"
            effectiveBgColor = {r = 0, g = 0, b = 0, a = 0.8}
        end
        
        -- Apply texture (use Solid as fallback for ColorTexture behavior)
        if bgTexture == "Solid" or bgTexture == "" then
            -- Solid color mode - only update if texture type changed
            if frame.dfCurrentBgTexture ~= "Solid" then
                frame.dfCurrentBgTexture = "Solid"
            end
            -- Use key tracking to prevent flickering from repeated SetColorTexture calls
            if effectiveBgMode == "CUSTOM" then
                local c = effectiveBgColor or db.backgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                local key = string.format("CUSTOM:%.2f:%.2f:%.2f:%.2f", c.r, c.g, c.b, c.a or 0.8)
                if frame.dfCurrentBgKey ~= key then
                    frame.background:SetColorTexture(c.r, c.g, c.b, c.a or 0.8)
                    frame.dfCurrentBgKey = key
                end
            elseif effectiveBgMode == "CLASS" then
                local _, class = UnitClass(unit)
                local classColor = DF:GetClassColor(class)
                local bgAlpha = db.backgroundClassAlpha or 0.3
                local key = string.format("CLASS:%.2f:%.2f:%.2f:%.2f", classColor.r, classColor.g, classColor.b, bgAlpha)
                if frame.dfCurrentBgKey ~= key then
                    frame.background:SetColorTexture(classColor.r, classColor.g, classColor.b, bgAlpha)
                    frame.dfCurrentBgKey = key
                end
            end
        else
            -- Textured background - only call SetTexture if texture path changed
            -- This prevents flickering on every health update
            if frame.dfCurrentBgTexture ~= bgTexture then
                frame.background:SetTexture(bgTexture)
                frame.background:SetHorizTile(false)
                frame.background:SetVertTile(false)
                frame.dfCurrentBgTexture = bgTexture
                frame.dfCurrentBgKey = nil  -- Clear key when switching to textured
                -- Reset SetAlpha to 1.0 when texture changes so only vertex color controls alpha
                frame.background:SetAlpha(1.0)
            end
            
            -- Always update vertex color (this doesn't cause flicker)
            -- Alpha is controlled entirely through vertex color for textured backgrounds
            if effectiveBgMode == "CUSTOM" then
                local c = effectiveBgColor or db.backgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                frame.background:SetVertexColor(c.r, c.g, c.b, c.a or 0.8)
            elseif effectiveBgMode == "CLASS" then
                local _, class = UnitClass(unit)
                local classColor = DF:GetClassColor(class)
                local bgAlpha = db.backgroundClassAlpha or 0.3
                frame.background:SetVertexColor(classColor.r, classColor.g, classColor.b, bgAlpha)
            end
        end
    end
    --]]
    
    -- ========================================
    -- NAME
    -- ========================================
    DF:UpdateName(frame)
    
    -- ========================================
    -- HEALTH TEXT
    -- ========================================
    if frame.healthText then
        local format = db.healthTextFormat or "PERCENT"
        if format == "NONE" then
            frame.healthText:Hide()
        else
            if format == "PERCENT" then
                local pct = DF.GetSafeHealthPercent(unit)
                local pctFmt = db.healthTextHidePercent and "%.0f" or "%.0f%%"
                frame.healthText:SetFormattedText(pctFmt, pct)
            elseif format == "CURRENT" then
                local curr = UnitHealth(unit, true)
                if curr then
                    if db.healthTextAbbreviate and AbbreviateNumbers then
                        frame.healthText:SetText(AbbreviateNumbers(curr))
                    else
                        frame.healthText:SetFormattedText("%s", curr)
                    end
                end
            elseif format == "DEFICIT" then
                local deficit = UnitHealthMissing(unit, true)
                if deficit then
                    if C_StringUtil and C_StringUtil.TruncateWhenZero and C_StringUtil.WrapString then
                        frame.healthText:SetText(C_StringUtil.WrapString(C_StringUtil.TruncateWhenZero(deficit), "-"))
                        if db.healthTextAbbreviate and AbbreviateNumbers and frame.healthText:GetText() then
                            frame.healthText:SetFormattedText("-%s", AbbreviateNumbers(deficit))
                        end
                    elseif db.healthTextAbbreviate and AbbreviateNumbers then
                        frame.healthText:SetFormattedText("-%s", AbbreviateNumbers(deficit))
                    else
                        frame.healthText:SetFormattedText("-%s", deficit)
                    end
                end
            elseif format == "CURRENTMAX" then
                local curr = UnitHealth(unit, true)
                local max = UnitHealthMax(unit, true)
                if curr and max then
                    if db.healthTextAbbreviate and AbbreviateNumbers then
                        frame.healthText:SetFormattedText("%s/%s", AbbreviateNumbers(curr), AbbreviateNumbers(max))
                    else
                        frame.healthText:SetFormattedText("%s/%s", curr, max)
                    end
                end
            end
            frame.healthText:Show()
        end
    end
    
    -- ========================================
    -- POWER BAR
    -- ========================================
    local showPower = DF:ShouldShowResourceBar(unit, db)

    -- Health bar positioning (resource bar is floating, doesn't affect health bar size)
    if frame.healthBar then
        local padding = db.framePadding or 0
        frame.healthBar:ClearAllPoints()
        frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
        frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -padding, padding)
    end
    
    if frame.dfPowerBar then
        if showPower then
            local power = UnitPower(unit)
            local maxPower = UnitPowerMax(unit)

            -- Secret value guard: UnitPowerMax/UnitPower return secret values for arena opponents
            -- SetMinMaxValues cannot handle secret values, so hide the bar when they appear
            if type(power) ~= "number" or type(maxPower) ~= "number" then
                frame.dfPowerBar:Hide()
            else
                frame.dfPowerBar:SetMinMaxValues(0, maxPower)
                frame.dfPowerBar:SetValue(power)

                local _, classToken = UnitClass(unit)
                local classColor = db.resourceBarClassColor and classToken and DF:GetClassColor(classToken)
                if classColor then
                    frame.dfPowerBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
                else
                    local powerType, powerToken = UnitPowerType(unit)
                    local powerColor = DF:GetPowerColor(powerToken, powerType)
                    frame.dfPowerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b, 1)
                end
                frame.dfPowerBar:Show()
                -- Let the appearance system handle alpha (OOR, dead, element-specific)
                if DF.UpdatePowerBarAppearance then
                    DF:UpdatePowerBarAppearance(frame)
                end
            end
        else
            frame.dfPowerBar:Hide()
        end
    end
    
    -- ========================================
    -- ABSORB BAR
    -- ========================================
    DF:UpdateAbsorb(frame)
    
    -- ========================================
    -- HEAL ABSORB BAR
    -- ========================================
    DF:UpdateHealAbsorb(frame)
    
    -- ========================================
    -- HEAL PREDICTION BAR
    -- ========================================
    DF:UpdateHealPrediction(frame)
    
    -- ========================================
    -- ICONS (Leader and Raid Target only - Role icons updated separately)
    -- ========================================
    -- Note: Role icons are NOT updated here - they are updated only on:
    -- GROUP_ROSTER_UPDATE, PLAYER_REGEN_ENABLED/DISABLED, and settings changes
    -- This prevents role icons from flickering when UnitGroupRolesAssigned
    -- temporarily returns "NONE" during other events
    DF:UpdateLeaderIcon(frame)
    DF:UpdateRaidTargetIcon(frame)
    
    -- ========================================
    -- DISPEL GRADIENT HEALTH UPDATE
    -- ========================================
    -- Update dispel gradient if it's tracking current health
    if DF.UpdateDispelGradientHealth then
        DF:UpdateDispelGradientHealth(frame)
    end
    
    -- Update my buff gradient if it's tracking current health
    if DF.UpdateMyBuffGradientHealth then
        DF:UpdateMyBuffGradientHealth(frame)
    end

    -- Update AD tint overlay if it's tracking current health
    if DF.UpdateADTintHealth then
        DF:UpdateADTintHealth(frame)
    end

    -- ========================================
    -- RANGE CHECK
    -- ========================================
    -- Range checking is handled by Features/Range.lua using SetAlphaFromBoolean
    -- which properly handles "secret" values from UnitInRange() in raid contexts.
    -- See DF:UpdateRange() for the implementation.
end

-- ============================================================
-- FAST HEALTH UPDATE (Hot path for UNIT_HEALTH / UNIT_MAXHEALTH)
--
-- Lean update that only touches combat-critical health elements.
-- Called on every UNIT_HEALTH event (highest frequency combat event).
--
-- Includes: health bar, health text, absorbs, heal prediction,
--           missing health bar, dispel gradient, dead/offline guards.
-- Excludes: name text, background, power bar, icons, health bar
--           positioning (handled by full UpdateUnitFrame on unit
--           swap / settings changes / roster events / UNIT_CONNECTION).
-- ============================================================

function DF:UpdateHealthFast(frame)
    if not frame or not frame.unit then return end

    -- Skip test frames entirely — their health comes from UpdateTestFrame
    -- which reads fake data from DF:GetTestUnitData. Includes boss-mode pinned
    -- frames that Test Mode temporarily marks with dfIsTestFrame.
    if frame.dfIsTestFrame then return end

    -- Skip if in test mode (blanket skip for real live frames)
    local isRaidHF = DF:IsRaidFrame(frame)
    if isRaidHF and DF.raidTestMode then return end
    if not isRaidHF and DF.testMode then return end

    local unit = frame.unit
    if not UnitExists(unit) then return end

    local db = DF:GetFrameDB(frame)

    -- ========================================
    -- OFFLINE CHECK
    -- ========================================
    local isConnected = UnitIsConnected(unit)
    if not isConnected then
        if frame.healthBar then
            frame.healthBar:SetMinMaxValues(0, 100)
            frame.healthBar:SetValue(100)
        end
        if frame.statusText then
            if db.statusTextEnabled ~= false then
                frame.statusText:SetText("Offline")
                frame.statusText:Show()
            else
                frame.statusText:Hide()
            end
        end
        if frame.healthText then
            frame.healthText:Hide()
        end
        if frame.dfPowerBar then
            frame.dfPowerBar:Hide()
        end
        if frame.dfAbsorbBar then
            frame.dfAbsorbBar:Hide()
        end
        if frame.dfHealAbsorbBar then
            frame.dfHealAbsorbBar:Hide()
        end
        DF:ApplyDeadFade(frame, "Offline")
        frame.dfLastKnownConnected = false
        return
    end

    -- ========================================
    -- DEAD/GHOST CHECK
    -- ========================================
    local isDead = UnitIsDead(unit)
    local isGhost = UnitIsGhost(unit)

    if isDead or isGhost then
        if frame.healthBar then
            frame.healthBar:SetMinMaxValues(0, 100)
            frame.healthBar:SetValue(0)
        end
        if frame.statusText then
            if db.statusTextEnabled ~= false then
                frame.statusText:SetText(isGhost and "Ghost" or "Dead")
                frame.statusText:Show()
            else
                frame.statusText:Hide()
            end
        end
        if frame.healthText then
            frame.healthText:Hide()
        end
        if frame.dfPowerBar then
            frame.dfPowerBar:Hide()
        end
        if frame.dfAbsorbBar then
            frame.dfAbsorbBar:Hide()
        end
        if frame.dfHealAbsorbBar then
            frame.dfHealAbsorbBar:Hide()
        end
        DF:ApplyDeadFade(frame, "Dead")
        return
    end

    -- Unit is alive and connected - reset dead fade if it was applied
    DF:ResetDeadFade(frame)
    frame.dfLastKnownConnected = true

    -- Clear resurrection icon if unit was pending a res and is now alive
    if DF.HasPendingResurrection and DF:HasPendingResurrection(unit) then
        DF:UpdateResurrectionIcon(frame)
        -- Refresh auras so transient "Resurrected" buff icon clears
        if DF.UpdateAuras_Enhanced then DF:UpdateAuras_Enhanced(frame) end
    end

    -- Clear status text for alive units
    if frame.statusText then
        frame.statusText:SetText("")
        frame.statusText:Hide()
    end

    -- ========================================
    -- HEALTH BAR
    -- ========================================
    if frame.healthBar then
        DF.SetHealthBarValue(frame.healthBar, unit, frame)
        DF:UpdateHealthBarAppearance(frame)
    end

    -- ========================================
    -- MISSING HEALTH BAR
    -- ========================================
    if frame.missingHealthBar then
        DF.SetMissingHealthBarValue(frame.missingHealthBar, unit, frame)
    end

    -- ========================================
    -- HEALTH TEXT
    -- ========================================
    if frame.healthText then
        local fmt = db.healthTextFormat or "PERCENT"
        if fmt == "NONE" then
            frame.healthText:Hide()
        else
            if fmt == "PERCENT" then
                local pct = DF.GetSafeHealthPercent(unit)
                local pctFmt = db.healthTextHidePercent and "%.0f" or "%.0f%%"
                frame.healthText:SetFormattedText(pctFmt, pct)
            elseif fmt == "CURRENT" then
                local curr = UnitHealth(unit, true)
                if curr then
                    if db.healthTextAbbreviate and AbbreviateNumbers then
                        frame.healthText:SetText(AbbreviateNumbers(curr))
                    else
                        frame.healthText:SetFormattedText("%s", curr)
                    end
                end
            elseif fmt == "DEFICIT" then
                local deficit = UnitHealthMissing(unit, true)
                if deficit then
                    if C_StringUtil and C_StringUtil.TruncateWhenZero and C_StringUtil.WrapString then
                        frame.healthText:SetText(C_StringUtil.WrapString(C_StringUtil.TruncateWhenZero(deficit), "-"))
                        if db.healthTextAbbreviate and AbbreviateNumbers and frame.healthText:GetText() then
                            frame.healthText:SetFormattedText("-%s", AbbreviateNumbers(deficit))
                        end
                    elseif db.healthTextAbbreviate and AbbreviateNumbers then
                        frame.healthText:SetFormattedText("-%s", AbbreviateNumbers(deficit))
                    else
                        frame.healthText:SetFormattedText("-%s", deficit)
                    end
                end
            elseif fmt == "CURRENTMAX" then
                local curr = UnitHealth(unit, true)
                local maxHp = UnitHealthMax(unit, true)
                if curr and maxHp then
                    if db.healthTextAbbreviate and AbbreviateNumbers then
                        frame.healthText:SetFormattedText("%s/%s", AbbreviateNumbers(curr), AbbreviateNumbers(maxHp))
                    else
                        frame.healthText:SetFormattedText("%s/%s", curr, maxHp)
                    end
                end
            end
            frame.healthText:Show()
        end
    end

    -- ========================================
    -- ABSORB / HEAL ABSORB / HEAL PREDICTION
    -- ========================================
    -- These have their own dedicated events (UNIT_ABSORB_AMOUNT_CHANGED,
    -- UNIT_HEAL_ABSORB_AMOUNT_CHANGED, UNIT_HEAL_PREDICTION) that handle
    -- value changes. In ATTACHED/OVERLAY mode, bars anchor to the health fill
    -- texture edge, so position auto-updates when health changes.
    --
    -- EXCEPTION: ATTACHED mode with clamp (absorbBarAttachedClampMode > 0)
    -- clamps the displayed absorb to missing health, so health changes affect
    -- the clamped value even when absorb amount is unchanged.
    local absorbMode = db.absorbBarMode or "OVERLAY"
    if (absorbMode == "ATTACHED" or absorbMode == "ATTACHED_OVERFLOW") and (db.absorbBarAttachedClampMode or 1) > 0 then
        DF:UpdateAbsorb(frame)
    end

    -- ========================================
    -- DISPEL GRADIENT HEALTH
    -- ========================================
    if DF.UpdateDispelGradientHealth then
        DF:UpdateDispelGradientHealth(frame)
    end
    
    -- Update my buff gradient if it's tracking current health
    if DF.UpdateMyBuffGradientHealth then
        DF:UpdateMyBuffGradientHealth(frame)
    end

    -- Update AD tint overlay if it's tracking current health
    if DF.UpdateADTintHealth then
        DF:UpdateADTintHealth(frame)
    end
end

-- ============================================================
-- LEGACY FRAME CREATION (for backwards compatibility)
-- These now just call the unified CreateUnitFrame
-- ============================================================

-- ============================================================
-- DEDICATED POWER BAR UPDATE
-- ============================================================
-- Separate function for power bar updates, can be called independently
-- This is useful for combat reload when UnitExists may return false initially

function DF:UpdatePower(frame)
    if not frame or not frame.unit then return end
    if not frame.dfPowerBar then return end
    
    local unit = frame.unit
    local db = DF:GetFrameDB(frame)
    
    -- Check if power bar should be shown (uses centralized role filter)
    local showPower = DF:ShouldShowResourceBar(unit, db)

    if not showPower then
        frame.dfPowerBar:Hide()
        return
    end
    
    -- Only update if unit exists
    if not UnitExists(unit) then return end
    
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)

    -- Secret value guard: UnitPowerMax/UnitPower return secret values for arena opponents
    -- SetMinMaxValues cannot handle secret values, so hide the bar when they appear
    if type(power) ~= "number" or type(maxPower) ~= "number" then
        frame.dfPowerBar:Hide()
        return
    end

    frame.dfPowerBar:SetMinMaxValues(0, maxPower)
    frame.dfPowerBar:SetValue(power)

    -- Update color
    local _, classToken = UnitClass(unit)
    local classColor = db.resourceBarClassColor and classToken and DF:GetClassColor(classToken)
    if classColor then
        frame.dfPowerBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
    else
        local powerType, powerToken = UnitPowerType(unit)
        local powerColor = DF:GetPowerColor(powerToken, powerType)
        frame.dfPowerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b, 1)
    end
    frame.dfPowerBar:Show()
end

-- UPDATE FUNCTIONS
-- ============================================================

function DF:UpdateFrame(frame)
    if not DF.initialized then return end
    if not frame or not frame.unit then return end
    
    -- For party frames, use the unified update
    if not frame.isRaidFrame then
        DF:UpdateUnitFrame(frame)
        -- Also call aura update and other party-specific updates
        DF:UpdateAuras(frame)
        DF:UpdateReadyCheckIcon(frame)
        DF:UpdateCenterStatusIcon(frame)
        -- Explicit power bar update (in case UpdateUnitFrame early-exited)
        if DF.UpdatePower then
            DF:UpdatePower(frame)
        end
    end
end

function DF:UpdateHealth(frame)
    if not frame or not frame.unit then return end
    
    local unit = frame.unit
    
    -- Only process player and party units
    if unit ~= "player" and not unit:match("^party%d$") then
        return
    end
    
    local db = DF:GetDB()
    
    -- Check for status conditions (Dead, Offline, AFK)
    local isDead = UnitIsDeadOrGhost(unit)
    local isOffline = not UnitIsConnected(unit)
    
    if isDead or isOffline then
        -- Determine status type for dead-specific styling
        local statusType = isOffline and "Offline" or "Dead"
        
        -- Show status text if enabled
        if db.statusTextEnabled and frame.statusText then
            DF:StyleStatusText(frame)
            if isOffline then
                frame.statusText:SetText("Offline")
            elseif isDead then
                frame.statusText:SetText("Dead")
            end
            frame.statusText:Show()
            frame.healthText:Hide()
        end
        
        -- Update health bar for dead/offline unit using helper
        DF.SetHealthBarValue(frame.healthBar, unit, frame)
        DF:ApplyHealthColors(frame)
        
        -- Update missing health bar for dead/offline unit
        if frame.missingHealthBar then
            DF.SetMissingHealthBarValue(frame.missingHealthBar, unit, frame)
        end
        
        -- Apply dead fade with status type
        DF:ApplyDeadFade(frame, statusType)
        return
    end
    
    -- Unit is alive - reset dead fade if it was applied
    DF:ResetDeadFade(frame)
    
    -- Hide status text, show health text
    if frame.statusText then
        frame.statusText:SetText("")
        frame.statusText:Hide()
    end
    frame.healthText:Show()
    
    -- Update health bar using helper
    DF.SetHealthBarValue(frame.healthBar, unit, frame)
    
    -- Update missing health bar
    if frame.missingHealthBar then
        DF.SetMissingHealthBarValue(frame.missingHealthBar, unit, frame)
    end
    
    -- Update health text
    local format = db.healthTextFormat or "PERCENT"
    
    if format == "NONE" then
        frame.healthText:SetText("")
    else
        -- Helper for abbreviation - uses Blizzard APIs which handle secret values
        local function FormatValue(val)
            if not val then return val end
            if db.healthTextAbbreviate then
                if AbbreviateNumbers then
                    return AbbreviateNumbers(val)
                elseif AbbreviateLargeNumbers then
                    return AbbreviateLargeNumbers(val)
                end
            end
            return val
        end
        
        -- Health text formatting
        if format == "PERCENT" then
            local p = DF.GetSafeHealthPercent(unit)
            local pctFmt = db.healthTextHidePercent and "%.0f" or "%.0f%%"
            frame.healthText:SetFormattedText(pctFmt, p)
        elseif format == "DEFICIT" then
            local miss = UnitHealthMissing(unit, true)
            
            if miss then
                if C_StringUtil and C_StringUtil.TruncateWhenZero and C_StringUtil.WrapString then
                    frame.healthText:SetText(C_StringUtil.WrapString(C_StringUtil.TruncateWhenZero(miss), "-"))
                    if db.healthTextAbbreviate and frame.healthText:GetText() then
                        frame.healthText:SetFormattedText("-%s", FormatValue(miss))
                    end
                elseif db.healthTextAbbreviate then
                    frame.healthText:SetFormattedText("-%s", FormatValue(miss))
                else
                    frame.healthText:SetFormattedText("-%s", miss)
                end
            end
        elseif format == "CURRENT" then
            local curr = UnitHealth(unit, true)
            if curr then
                frame.healthText:SetFormattedText("%s", FormatValue(curr))
            end
        elseif format == "CURRENTMAX" then
            local curr = UnitHealth(unit, true)
            local max = UnitHealthMax(unit, true)
            if curr and max then
                frame.healthText:SetFormattedText("%s / %s", FormatValue(curr), FormatValue(max))
            end
        end
    end
    
    -- Update dispel gradient if it's tracking health
    if DF.UpdateDispelGradientHealth then
        DF:UpdateDispelGradientHealth(frame)
    end
    
    -- Update my buff gradient if it's tracking current health
    if DF.UpdateMyBuffGradientHealth then
        DF:UpdateMyBuffGradientHealth(frame)
    end

    -- Update AD tint overlay if it's tracking current health
    if DF.UpdateADTintHealth then
        DF:UpdateADTintHealth(frame)
    end

    -- Apply colors
    DF:ApplyHealthColors(frame)
end

-- ============================================================
-- Apply all visual styles to a frame (called when settings change)
-- Apply all visual styles to a frame (DEPRECATED - use ApplyFrameLayout instead)
function DF:ApplyFrameStyle(frame)
    if not frame then return end
    -- Use unified layout function
    DF:ApplyFrameLayout(frame)
end

-- Apply layout settings to buff or debuff icons
function DF:ApplyAuraLayout(frame, auraType)
    if not frame then return end
    -- When AD is enabled: skip buff layout only if showBuffs is off (AD replaces them).
    -- When showBuffs is on, standard buffs coexist with AD and need layout applied.
    -- Debuff layout always runs.
    if auraType == "BUFF" and DF.IsAuraDesignerEnabled and DF:IsAuraDesignerEnabled(frame) then
        local frameDB = DF:GetFrameDB(frame)
        if not (frameDB and frameDB.showBuffs) then return end
    end

    local db = DF:GetFrameDB(frame)
    local icons, prefix
    
    if auraType == "BUFF" then
        icons = frame.buffIcons
        prefix = "buff"
    else
        icons = frame.debuffIcons
        prefix = "debuff"
    end
    
    if not icons then return end
    
    -- Get settings with prefix
    local size = db[prefix .. "Size"] or 18
    local scale = db[prefix .. "Scale"] or 1.0
    local alpha = db[prefix .. "Alpha"] or 1.0
    local anchor = db[prefix .. "Anchor"] or (auraType == "BUFF" and "BOTTOMRIGHT" or "BOTTOMLEFT")
    local growth = db[prefix .. "Growth"] or (auraType == "BUFF" and "LEFT_UP" or "RIGHT_UP")
    local wrap = db[prefix .. "Wrap"] or 3
    local maxIcons = db[prefix .. "Max"] or 4
    local offsetX = db[prefix .. "OffsetX"] or 0
    local offsetY = db[prefix .. "OffsetY"] or 0
    local paddingX = db[prefix .. "PaddingX"] or 2
    local paddingY = db[prefix .. "PaddingY"] or 2
    
    -- Get border thickness for this aura type (needed for pixel-perfect size calculation)
    local borderThickness = db[prefix .. "BorderThickness"] or 1
    
    -- Apply pixel-perfect sizing to aura size and scale together, adjusting for border
    if db.pixelPerfect then
        size, scale, borderThickness = DF:PixelPerfectSizeAndScaleForBorder(size, scale, borderThickness)
    end
    
    -- Stack text settings
    local stackScale = db[prefix .. "StackScale"] or 1.0
    local stackFont = db[prefix .. "StackFont"] or "Fonts\\FRIZQT__.TTF"
    local stackAnchor = db[prefix .. "StackAnchor"] or "BOTTOMRIGHT"
    local stackX = db[prefix .. "StackX"] or 0
    local stackY = db[prefix .. "StackY"] or 0
    local stackOutline = db[prefix .. "StackOutline"] or "OUTLINE"
    if stackOutline == "NONE" then stackOutline = "" end
    local stackMinimum = db[prefix .. "StackMinimum"] or 2
    
    -- Duration text settings (renamed from countdown)
    local showDuration = db[prefix .. "ShowDuration"] or false
    local durationScale = db[prefix .. "DurationScale"] or 1.0
    local durationFont = db[prefix .. "DurationFont"] or "Fonts\\FRIZQT__.TTF"
    local durationOutline = db[prefix .. "DurationOutline"] or "OUTLINE"
    if durationOutline == "NONE" then durationOutline = "" end
    local durationAnchor = db[prefix .. "DurationAnchor"] or "CENTER"
    local durationX = db[prefix .. "DurationX"] or 0
    local durationY = db[prefix .. "DurationY"] or 0
    local durationColorByTime = db[prefix .. "DurationColorByTime"] or false
    local durationHideAboveEnabled = db[prefix .. "DurationHideAboveEnabled"] or false
    local durationHideAboveThreshold = db[prefix .. "DurationHideAboveThreshold"] or 10
    local hideSwipe = db[prefix .. "HideSwipe"] or false
    
    -- Expiring indicator settings (buffs only)
    local expiringEnabled = false
    local expiringThreshold = 30
    local expiringThresholdMode = "PERCENT"
    local expiringBorderEnabled = false
    local expiringBorderColor = DEFAULT_EXPIRING_BORDER_COLOR
    local expiringBorderColorByTime = false
    local expiringBorderPulsate = false
    local expiringBorderThickness = 2
    local expiringBorderInset = -1
    local expiringTintEnabled = false
    local expiringTintColor = DEFAULT_EXPIRING_TINT_COLOR
    
    if auraType == "BUFF" then
        expiringEnabled = db.buffExpiringEnabled or false
        expiringThreshold = db.buffExpiringThreshold or 30
        expiringThresholdMode = db.buffExpiringThresholdMode or "PERCENT"
        expiringBorderEnabled = db.buffExpiringBorderEnabled or false
        expiringBorderColor = db.buffExpiringBorderColor or DEFAULT_EXPIRING_BORDER_COLOR
        expiringBorderColorByTime = db.buffExpiringBorderColorByTime or false
        expiringBorderPulsate = db.buffExpiringBorderPulsate or false
        expiringBorderThickness = db.buffExpiringBorderThickness or 2
        expiringBorderInset = db.buffExpiringBorderInset or -1
        expiringTintEnabled = db.buffExpiringTintEnabled or false
        expiringTintColor = db.buffExpiringTintColor or DEFAULT_EXPIRING_TINT_COLOR
    end
    -- Note: Debuffs don't use expiring indicators - their borders are used for debuff types
    
    -- Apply pixel-perfect sizing to expiring border thickness 
    if db.pixelPerfect and auraType == "BUFF" then
        expiringBorderThickness = DF:PixelPerfect(expiringBorderThickness)
    end
    
    -- Debuff border settings (use pre-calculated borderThickness if this is debuff type)
    local debuffBorderThickness = auraType == "DEBUFF" and borderThickness or (db.debuffBorderThickness or 1)
    local debuffBorderInset = db.debuffBorderInset or 1
    
    -- Buff border settings (use pre-calculated borderThickness if this is buff type)
    local buffBorderThickness = auraType == "BUFF" and borderThickness or (db.buffBorderThickness or 1)
    local buffBorderInset = db.buffBorderInset or 1
    
    -- Apply pixel-perfect sizing to the other type's border thickness (the current type was already done)
    if db.pixelPerfect then
        if auraType == "BUFF" then
            debuffBorderThickness = DF:PixelPerfect(debuffBorderThickness)
        else
            buffBorderThickness = DF:PixelPerfect(buffBorderThickness)
        end
    end
    
    -- Parse growth direction (PRIMARY_SECONDARY)
    local primary, secondary = strsplit("_", growth)
    primary = primary or "LEFT"
    secondary = secondary or "UP"
    
    -- Calculate growth offsets using scaled size (final rendered size)
    local scaledSize = size * scale
    
    local primaryX, primaryY = GetGrowthOffset(primary, scaledSize, paddingX)
    local secondaryX, secondaryY = GetGrowthOffset(secondary, scaledSize, paddingY)
    
    -- Get range state for this frame (may be secret boolean from UnitInRange fallback)
    local inRange = frame.dfInRange
    if not (issecretvalue and issecretvalue(inRange)) and inRange == nil then inRange = true end
    local oorAurasAlpha = db.oorAurasAlpha or 0.55
    local oorEnabled = db.oorEnabled
    
    -- Apply to each icon
    for i, icon in ipairs(icons) do
        -- ALWAYS set fonts on all icons to prevent "Font not set" errors
        -- even if the icon will be hidden
        if icon.count then
            local stackSize = 10 * stackScale
            DF:SafeSetFont(icon.count, stackFont, stackSize, stackOutline)
            icon.count:ClearAllPoints()
            icon.count:SetPoint(stackAnchor, icon, stackAnchor, stackX, stackY)
        end
        
        -- Store settings on icon for use in update function
        icon.stackMinimum = stackMinimum
        icon.showDuration = showDuration
        icon.durationColorByTime = durationColorByTime
        icon.durationHideAboveEnabled = durationHideAboveEnabled
        icon.durationHideAboveThreshold = durationHideAboveThreshold
        icon.durationAnchor = durationAnchor
        icon.durationX = durationX
        icon.durationY = durationY
        icon.expiringEnabled = expiringEnabled
        icon.expiringThreshold = expiringThreshold
        icon.expiringThresholdMode = expiringThresholdMode
        icon.expiringBorderEnabled = expiringBorderEnabled
        icon.expiringBorderColor = expiringBorderColor
        icon.expiringBorderColorByTime = expiringBorderColorByTime
        icon.expiringBorderPulsate = expiringBorderPulsate
        icon.expiringBorderThickness = expiringBorderThickness
        icon.expiringBorderInset = expiringBorderInset
        icon.expiringTintEnabled = expiringTintEnabled
        icon.expiringTintColor = expiringTintColor
        
        -- Duration text settings - native cooldown text stays as child of cooldown frame
        -- Cooldown Show/Hide controls both swipe and text visibility for permanent vs timed buffs
        if icon.nativeCooldownText then
            local durationSize = 10 * durationScale
            DF:SafeSetFont(icon.nativeCooldownText, durationFont, durationSize, durationOutline)
            -- Update position with current offsets
            icon.nativeCooldownText:ClearAllPoints()
            icon.nativeCooldownText:SetPoint(durationAnchor, icon, durationAnchor, durationX, durationY)
        end

        -- Tell Blizzard to show/hide countdown numbers based on user setting
        if icon.cooldown and icon.cooldown.SetHideCountdownNumbers then
            icon.cooldown:SetHideCountdownNumbers(not icon.showDuration)
        end
        
        if i > maxIcons then
            icon:Hide()
        else
            -- Calculate position (0-indexed)
            local idx = i - 1
            local row = math.floor(idx / wrap)
            local col = idx % wrap
            
            local x = offsetX + (col * primaryX) + (row * secondaryX)
            local y = offsetY + (col * primaryY) + (row * secondaryY)
            
            -- Size and position
            icon:SetSize(size, size)
            icon:SetScale(scale)
            
            -- Apply alpha with range consideration using SetAlphaFromBoolean
            if oorEnabled and icon.SetAlphaFromBoolean then
                icon:SetAlphaFromBoolean(inRange, alpha, oorAurasAlpha)
            else
                icon:SetAlpha(alpha)
            end
            
            icon:ClearAllPoints()
            icon:SetPoint(anchor, frame, anchor, x, y)
            
            -- Use SetMouseClickEnabled(false) to allow tooltips while passing clicks through
            -- This is Cell's approach for click-casting compatibility with tooltips
            if not InCombatLockdown() then
                if icon.SetMouseClickEnabled then
                    icon:SetMouseClickEnabled(false)
                end
            end
            
            -- Check if Masque is available and if user wants Masque to control borders
            local masqueGroup = auraType == "BUFF" and DF.MasqueGroup_Buffs or DF.MasqueGroup_Debuffs
            local masqueBorderControl = db.masqueBorderControl
            
            -- Register with Masque if enabled and not already registered
            -- We do this here (after sizing) to ensure the icon has proper dimensions
            if DF.Masque and masqueBorderControl and masqueGroup and not icon.masqueRegistered then
                -- Create FloatingBG for Masque's Backdrop feature if not exists
                if not icon.FloatingBG then
                    icon.FloatingBG = icon:CreateTexture(nil, "BACKGROUND", nil, -1)
                    icon.FloatingBG:SetAllPoints()
                    icon.FloatingBG:SetColorTexture(0, 0, 0, 0)
                end
                
                local buttonData = {
                    Icon = icon.texture,
                    Cooldown = icon.cooldown,
                    Count = icon.count,
                    Normal = icon.Normal,
                    Border = icon.masqueBorder,
                    FloatingBG = icon.FloatingBG,
                }
                
                local buttonType = (auraType == "DEBUFF") and "Debuff" or "Aura"
                masqueGroup:AddButton(icon, buttonData, buttonType)
                icon.masqueRegistered = true
            end
            
            -- Check if Masque is actively skinning
            local masqueActive = masqueGroup and masqueGroup.IsDisabled and not masqueGroup:IsDisabled()
            
            -- Handle border visibility based on Masque settings
            if icon.border then
                if masqueActive and masqueBorderControl then
                    -- Masque controls borders - hide our border, show Masque border
                    icon.border:Hide()
                    if icon.masqueBorder then
                        icon.masqueBorder:Show()
                    end
                else
                    -- We control borders - show our border, hide Masque border
                    icon.border:Show()
                    if icon.masqueBorder then
                        icon.masqueBorder:Hide()
                    end
                    -- Also hide FloatingBG (Masque backdrop) when we control borders
                    if icon.FloatingBG then
                        icon.FloatingBG:Hide()
                    end
                end
            end
            
            -- Texture and layer reset (skip if Masque is actively skinning and controlling borders)
            if not (masqueActive and masqueBorderControl) then
                -- Get border thickness for icon texture inset calculation
                local borderThickness = auraType == "DEBUFF" and debuffBorderThickness or buffBorderThickness
                -- Ensure at least 1 pixel inset for visibility
                local textureInset = math.max(1, borderThickness)
                
                -- Reset icon texture position and layer - inset matches border thickness
                icon.texture:ClearAllPoints()
                icon.texture:SetPoint("TOPLEFT", textureInset, -textureInset)
                icon.texture:SetPoint("BOTTOMRIGHT", -textureInset, textureInset)
                -- Reset draw layer to ARTWORK - Masque moves it to BACKGROUND which causes dimming
                icon.texture:SetDrawLayer("ARTWORK", 0)
                -- Ensure full opacity and no vertex color tinting
                icon.texture:SetVertexColor(1, 1, 1, 1)
                
                -- Reset Normal texture if it exists (Masque might have modified it)
                if icon.Normal then
                    icon.Normal:SetDrawLayer("BORDER", 0)
                    icon.Normal:SetAlpha(0)  -- Keep it invisible
                end
            end
            
            -- Apply border thickness and inset (only if we control borders)
            if icon.border and not (masqueActive and masqueBorderControl) then
                local borderThickness = auraType == "DEBUFF" and debuffBorderThickness or buffBorderThickness
                local borderInset = auraType == "DEBUFF" and debuffBorderInset or buffBorderInset
                icon.border:ClearAllPoints()
                icon.border:SetPoint("TOPLEFT", -borderThickness + borderInset, borderThickness - borderInset)
                icon.border:SetPoint("BOTTOMRIGHT", borderThickness - borderInset, -borderThickness + borderInset)
            end
            
            -- Expiring tint overlay
            if icon.expiringTint then
                icon.expiringTint:SetColorTexture(expiringTintColor.r, expiringTintColor.g, expiringTintColor.b, expiringTintColor.a)
            end
            
            -- Expiring border (4 edge textures) - apply thickness and inset
            if icon.expiringBorderTop then
                local thickness = expiringBorderThickness
                local inset = expiringBorderInset
                
                -- Only set static color if NOT in colorByTime mode (OnUpdate handles color in that mode)
                if not expiringBorderColorByTime then
                    icon.expiringBorderTop:SetVertexColor(expiringBorderColor.r, expiringBorderColor.g, expiringBorderColor.b, expiringBorderColor.a or 1)
                    icon.expiringBorderBottom:SetVertexColor(expiringBorderColor.r, expiringBorderColor.g, expiringBorderColor.b, expiringBorderColor.a or 1)
                    icon.expiringBorderLeft:SetVertexColor(expiringBorderColor.r, expiringBorderColor.g, expiringBorderColor.b, expiringBorderColor.a or 1)
                    icon.expiringBorderRight:SetVertexColor(expiringBorderColor.r, expiringBorderColor.g, expiringBorderColor.b, expiringBorderColor.a or 1)
                end
                
                -- Set thickness
                icon.expiringBorderTop:SetHeight(thickness)
                icon.expiringBorderBottom:SetHeight(thickness)
                icon.expiringBorderLeft:SetWidth(thickness)
                icon.expiringBorderRight:SetWidth(thickness)
                
                -- Position with inset (negative inset = outset)
                icon.expiringBorderLeft:ClearAllPoints()
                icon.expiringBorderLeft:SetPoint("TOPLEFT", icon, "TOPLEFT", inset, -inset)
                icon.expiringBorderLeft:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", inset, inset)
                
                icon.expiringBorderRight:ClearAllPoints()
                icon.expiringBorderRight:SetPoint("TOPRIGHT", icon, "TOPRIGHT", -inset, -inset)
                icon.expiringBorderRight:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -inset, inset)
                
                icon.expiringBorderTop:ClearAllPoints()
                icon.expiringBorderTop:SetPoint("TOPLEFT", icon.expiringBorderLeft, "TOPRIGHT", 0, 0)
                icon.expiringBorderTop:SetPoint("TOPRIGHT", icon.expiringBorderRight, "TOPLEFT", 0, 0)
                
                icon.expiringBorderBottom:ClearAllPoints()
                icon.expiringBorderBottom:SetPoint("BOTTOMLEFT", icon.expiringBorderLeft, "BOTTOMRIGHT", 0, 0)
                icon.expiringBorderBottom:SetPoint("BOTTOMRIGHT", icon.expiringBorderRight, "BOTTOMLEFT", 0, 0)
            end
            
            -- Cooldown swipe settings
            if icon.cooldown then
                icon.cooldown:SetDrawSwipe(not hideSwipe)
                -- Enable native countdown numbers when duration is enabled
                icon.cooldown:SetHideCountdownNumbers(not showDuration)
            end
        end
    end
    
    -- Stamp this frame with the current layout version so UpdateAuras can skip
    -- redundant layout passes until settings change again
    frame.dfAuraLayoutVersion = DF.auraLayoutVersion or 0
end

-- Refresh duration text color settings on existing icons (for live updates when checkbox changes)
function DF:RefreshDurationColorSettings()
    local function UpdateFrameIcons(frame)
        if not frame then return end
        local db = DF:GetFrameDB(frame)
        
        -- Update buff icons
        if frame.buffIcons then
            local colorByTime = db.buffDurationColorByTime or false
            local hideAboveEnabled = db.buffDurationHideAboveEnabled or false
            local hideAboveThreshold = db.buffDurationHideAboveThreshold or 10
            for _, icon in ipairs(frame.buffIcons) do
                icon.durationColorByTime = colorByTime
                icon.durationHideAboveEnabled = hideAboveEnabled
                icon.durationHideAboveThreshold = hideAboveThreshold
                -- If turning off color, reset to default color
                if not colorByTime and icon.nativeCooldownText then
                    local durationColor = db.buffDurationColor or {r=1, g=1, b=1}
                    icon.nativeCooldownText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
                end
                -- If turning off hide, reset wrapper alpha to 1
                if not hideAboveEnabled and icon.durationHideWrapper then
                    icon.durationHideWrapper:SetAlpha(1)
                end
            end
        end

        -- Update debuff icons
        if frame.debuffIcons then
            local colorByTime = db.debuffDurationColorByTime or false
            local hideAboveEnabled = db.debuffDurationHideAboveEnabled or false
            local hideAboveThreshold = db.debuffDurationHideAboveThreshold or 10
            for _, icon in ipairs(frame.debuffIcons) do
                icon.durationColorByTime = colorByTime
                icon.durationHideAboveEnabled = hideAboveEnabled
                icon.durationHideAboveThreshold = hideAboveThreshold
                -- If turning off color, reset to default color
                if not colorByTime and icon.nativeCooldownText then
                    local durationColor = db.debuffDurationColor or {r=1, g=1, b=1}
                    icon.nativeCooldownText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
                end
                -- If turning off hide, reset wrapper alpha to 1
                if not hideAboveEnabled and icon.durationHideWrapper then
                    icon.durationHideWrapper:SetAlpha(1)
                end
            end
        end
    end
    
    -- Party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(UpdateFrameIcons)
    end
    
    -- Raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(UpdateFrameIcons)
    end
end

-- ============================================================
-- REFRESH ALL FONTS
-- ============================================================
-- Lightweight function to re-apply fonts to all frames
-- Called at PLAYER_LOGIN to ensure fonts are properly initialized
-- (during combat reload, fonts may not be fully available at ADDON_LOADED)

local function RefreshFrameFonts(frame, db)
    if not frame then return end
    
    -- Name text
    if frame.nameText then
        local nameFont = db.nameFont or "Fonts\\FRIZQT__.TTF"
        local nameFontSize = db.nameFontSize or 11
        local nameOutline = db.nameTextOutline or "OUTLINE"
        if nameOutline == "NONE" then nameOutline = "" end
        DF:SafeSetFont(frame.nameText, nameFont, nameFontSize, nameOutline)
    end
    
    -- Health text
    if frame.healthText then
        local healthFont = db.healthFont or "Fonts\\FRIZQT__.TTF"
        local healthFontSize = db.healthFontSize or 10
        local healthOutline = db.healthTextOutline or "OUTLINE"
        if healthOutline == "NONE" then healthOutline = "" end
        DF:SafeSetFont(frame.healthText, healthFont, healthFontSize, healthOutline)
    end
    
    -- Status text
    if frame.statusText then
        local statusFont = db.statusTextFont or "Fonts\\FRIZQT__.TTF"
        local statusFontSize = db.statusTextFontSize or 10
        local statusOutline = db.statusTextOutline or "OUTLINE"
        if statusOutline == "NONE" then statusOutline = "" end
        DF:SafeSetFont(frame.statusText, statusFont, statusFontSize, statusOutline)
    end
end

function DF:RefreshAllFonts()
    local partyDb = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Refresh party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            RefreshFrameFonts(frame, partyDb)
        end)
    end
    
    -- Refresh raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            RefreshFrameFonts(frame, raidDb)
        end)
    end
    
    -- Refresh pet frames (use pet-specific font keys, not main frame keys)
    local function RefreshPetFonts(frame, db)
        if not frame then return end
        if frame.nameText then
            local nameFont = db.petNameFont or "Fonts\\FRIZQT__.TTF"
            local nameFontSize = db.petNameFontSize or 9
            local nameFontOutline = db.petNameFontOutline or "OUTLINE"
            if nameFontOutline == "NONE" then nameFontOutline = "" end
            DF:SafeSetFont(frame.nameText, nameFont, nameFontSize, nameFontOutline)
        end
        if frame.healthText then
            local healthFont = db.petHealthFont or "Fonts\\ARIALN.TTF"
            local healthFontSize = db.petHealthFontSize or 8
            local healthFontOutline = db.petHealthFontOutline or "OUTLINE"
            if healthFontOutline == "NONE" then healthFontOutline = "" end
            DF:SafeSetFont(frame.healthText, healthFont, healthFontSize, healthFontOutline)
        end
    end

    -- Refresh live pet frames
    if DF.petFrames and DF.petFrames.player then
        RefreshPetFonts(DF.petFrames.player, partyDb)
    end

    if DF.partyPetFrames then
        for _, frame in pairs(DF.partyPetFrames) do
            RefreshPetFonts(frame, partyDb)
        end
    end

    if DF.raidPetFrames then
        for _, frame in pairs(DF.raidPetFrames) do
            RefreshPetFonts(frame, raidDb)
        end
    end

    -- Refresh test pet frames (these exist when in test mode)
    if DF.testMode and DF.testPetFrames then
        for i = 0, 4 do
            RefreshPetFonts(DF.testPetFrames[i], partyDb)
        end
    end

    if DF.raidTestMode and DF.testRaidPetFrames then
        for i = 1, 40 do
            RefreshPetFonts(DF.testRaidPetFrames[i], raidDb)
        end
    end

    -- Also refresh test party/raid frames for main frame fonts
    if DF.testMode and DF.testPartyFrames then
        for i = 0, 4 do
            if DF.testPartyFrames[i] then
                RefreshFrameFonts(DF.testPartyFrames[i], partyDb)
            end
        end
    end

    if DF.raidTestMode and DF.testRaidFrames then
        for i = 1, 40 do
            if DF.testRaidFrames[i] then
                RefreshFrameFonts(DF.testRaidFrames[i], raidDb)
            end
        end
    end
end