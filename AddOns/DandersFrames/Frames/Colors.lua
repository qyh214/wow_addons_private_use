local addonName, DF = ...

-- ============================================================
-- FRAMES COLORS MODULE
-- Contains health color system, gradients, and dead fade
-- ============================================================

-- Apply out of range effect to test frame
-- Style the status text element based on settings
function DF:StyleStatusText(frame)
    if not frame or not frame.statusText then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    -- Apply font
    local font = db.statusTextFont or "Fonts\\FRIZQT__.TTF"
    local fontSize = db.statusTextFontSize or 10
    local outline = db.statusTextOutline or "OUTLINE"
    if outline == "NONE" then outline = "" end
    
    DF:SafeSetFont(frame.statusText, font, fontSize, outline)
    
    -- Apply position
    frame.statusText:ClearAllPoints()
    local anchor = db.statusTextAnchor or "CENTER"
    frame.statusText:SetPoint(anchor, frame, anchor, db.statusTextX or 0, db.statusTextY or 0)
    
    -- Apply color
    local color = db.statusTextColor or {r = 1, g = 1, b = 1}
    frame.statusText:SetTextColor(color.r, color.g, color.b, 1)
    
    -- Ensure it's on top
    frame.statusText:SetDrawLayer("OVERLAY", 7)
end

-- Apply dead/offline fade to frame elements
-- statusType: "Dead" or "Offline" - used for dead-specific styling
function DF:ApplyDeadFade(frame, statusType, forceApply)
    if not frame then return end
    
    -- Skip test frames - they handle their own dead fade in TestMode.lua
    if frame.dfIsTestFrame then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    if not db.fadeDeadFrames then return end
    
    -- Mark the frame as having dead fade applied
    frame.dfDeadFadeApplied = true
    
    -- Delegate to ElementAppearance for centralized handling
    -- This ensures consistent appearance across all code paths
    if DF.UpdateAllElementAppearances then
        DF:UpdateAllElementAppearances(frame)
        return
    end
    
end

-- Reset dead fade (restore normal alpha)
function DF:ResetDeadFade(frame)
    if not frame then return end
    if not frame.dfDeadFadeApplied then return end
    
    -- Clear the flag FIRST so ElementAppearance knows we're not in dead state
    frame.dfDeadFadeApplied = false
    
    -- Delegate to ElementAppearance for centralized handling
    -- This ensures consistent appearance across all code paths
    if DF.UpdateAllElementAppearances then
        DF:UpdateAllElementAppearances(frame)
        return
    end
end
-- ============================================================
-- SMOOTH BAR HELPER
-- ============================================================
-- Uses the new 12.0.5 StatusBar:SetValue interpolation when smoothBars is enabled

local function SetBarValue(bar, value, frame)
    if not bar or not bar.SetValue then return end
    
    -- Get the appropriate db for this frame
    local db
    if frame and frame.isRaidFrame then
        db = DF.GetRaidDB and DF:GetRaidDB()
    else
        db = DF.GetDB and DF:GetDB()
    end
    local smoothEnabled = db and db.smoothBars
    
    if smoothEnabled and Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut then
        bar:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        bar:SetValue(value)
    end
end

-- Export for use in other files
DF.SetBarValue = SetBarValue

-- ============================================================
-- HEALTH COLOR SYSTEM
-- ============================================================

function DF:UpdateColorCurve()
    DF.CurveCache = {}
    DF.MissingHealthCurveCache = {}
end

-- Get a color curve for gradient mode
-- prefix: db key prefix ("healthColor" or "missingHealthColor")
-- cache: cache table to use (DF.CurveCache or DF.MissingHealthCurveCache)
function DF:GetCurveForUnit(unit, db, prefix, cache)
    if not unit then return nil end
    prefix = prefix or "healthColor"
    cache = cache or DF.CurveCache
    
    local useClass = db[prefix .. "LowUseClass"] or db[prefix .. "MediumUseClass"] or db[prefix .. "HighUseClass"]
    local class = "DEFAULT"
    
    if useClass then
        _, class = UnitClass(unit)
        if not class then class = "DEFAULT" end
    end
    
    if cache[class] then return cache[class] end
    
    if not C_CurveUtil or not C_CurveUtil.CreateColorCurve then return nil end
    
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    
    local function GetStageColor(stage)
        if db[prefix .. stage .. "UseClass"] and class ~= "DEFAULT" then
            local c = DF:GetClassColor(class)
            if c then return c.r, c.g, c.b, 1.0 end
            return 0.5, 0.5, 0.5, 1.0
        else
            local c = db[prefix .. stage]
            return c.r, c.g, c.b, c.a or 1
        end
    end
    
    local lowW = math.max(1, math.floor(db[prefix .. "LowWeight"] or 1))
    local medW = math.max(1, math.floor(db[prefix .. "MediumWeight"] or 1))
    local highW = math.max(1, math.floor(db[prefix .. "HighWeight"] or 1))
    
    local lr, lg, lb, la = GetStageColor("Low")
    local mr, mg, mb, ma = GetStageColor("Medium")
    local hr, hg, hb, ha = GetStageColor("High")
    
    local lCol = CreateColor(lr, lg, lb, la)
    local mCol = CreateColor(mr, mg, mb, ma)
    local hCol = CreateColor(hr, hg, hb, ha)
    
    local colorPoints = {}
    for i = 1, lowW do table.insert(colorPoints, lCol) end
    for i = 1, medW do table.insert(colorPoints, mCol) end
    for i = 1, highW do table.insert(colorPoints, hCol) end
    
    if #colorPoints < 2 then colorPoints = {lCol, hCol} end
    
    local numPoints = #colorPoints
    for i, col in ipairs(colorPoints) do
        local position = (i - 1) / (numPoints - 1)
        curve:AddPoint(position, col)
    end
    
    cache[class] = curve
    return curve
end

-- Get gradient color for a health percentage using actual db settings
-- This replicates the curve logic for test mode where we don't have a real unit
-- prefix: db key prefix ("healthColor" or "missingHealthColor")
function DF:GetHealthGradientColor(percent, db, testClass, prefix)
    prefix = prefix or "healthColor"
    
    local lowW = math.max(1, math.floor(db[prefix .. "LowWeight"] or 1))
    local medW = math.max(1, math.floor(db[prefix .. "MediumWeight"] or 1))
    local highW = math.max(1, math.floor(db[prefix .. "HighWeight"] or 1))
    
    local function GetStageColor(stage)
        if db[prefix .. stage .. "UseClass"] and testClass then
            local c = DF:GetClassColor(testClass)
            if c then return {r = c.r, g = c.g, b = c.b} end
        end
        return db[prefix .. stage] or {r = 0.5, g = 0.5, b = 0.5}
    end
    
    local lowColor = GetStageColor("Low")
    local midColor = GetStageColor("Medium")
    local highColor = GetStageColor("High")
    
    -- Build weighted color points array (same logic as GetCurveForUnit)
    local colorPoints = {}
    for i = 1, lowW do table.insert(colorPoints, lowColor) end
    for i = 1, medW do table.insert(colorPoints, midColor) end
    for i = 1, highW do table.insert(colorPoints, highColor) end
    
    if #colorPoints < 2 then 
        colorPoints = {lowColor, highColor} 
    end
    
    -- Find which segment of the curve we're in and interpolate
    local numPoints = #colorPoints
    local scaledPos = percent * (numPoints - 1)
    local lowerIdx = math.floor(scaledPos) + 1
    local upperIdx = math.min(lowerIdx + 1, numPoints)
    local t = scaledPos - (lowerIdx - 1)  -- Fractional position within segment
    
    local c1 = colorPoints[lowerIdx]
    local c2 = colorPoints[upperIdx]
    
    -- Linear interpolation between the two points
    local r = c1.r + (c2.r - c1.r) * t
    local g = c1.g + (c2.g - c1.g) * t
    local b = c1.b + (c2.b - c1.b) * t
    
    return {r = r, g = g, b = b}
end

-- Apply health bar colors based on settings
function DF:ApplyHealthColors(frame)
    if not frame or not frame.healthBar then return end

    -- Skip if Aura Designer health bar color indicator is active
    local adState = frame.dfAD
    if adState and adState.healthbar then return end

    local unit = frame.unit
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    local mode = db.healthColorMode
    local classColorAlpha = db.classColorAlpha or 1.0
    
    -- Check if dead fade is currently applied to this frame
    -- Only use the flag - don't re-check dead status here
    local deadFadeActive = frame.dfDeadFadeApplied
    
    -- Check if aggro color override is active
    if frame.dfAggroActive and frame.dfAggroColor then
        local c = frame.dfAggroColor
        frame.healthBar:SetStatusBarColor(c.r, c.g, c.b)
        -- Also set vertex color to override gradient mode
        local tex = frame.healthBar:GetStatusBarTexture()
        if tex then
            tex:SetVertexColor(c.r, c.g, c.b)
            if not deadFadeActive then
                tex:SetAlpha(classColorAlpha)
            end
        end
        return  -- Skip normal color logic
    end
    
    if mode == "PERCENT" then
        -- Gradient mode - use color curve
        local curve = DF:GetCurveForUnit(unit, db)
        if curve and unit and UnitHealthPercent then
            local color = UnitHealthPercent(unit, true, curve)
            local tex = frame.healthBar:GetStatusBarTexture()
            if color and tex then
                tex:SetVertexColor(color:GetRGB())
                -- Don't override alpha if dead fade is applied
                if not deadFadeActive then
                    tex:SetAlpha(classColorAlpha)
                end
            end
        end
    elseif mode == "CLASS" then
        -- Class color mode - use RGB only, alpha controlled separately
        local r, g, b = 0, 1, 0
        if unit then
            local _, class = UnitClass(unit)
            local classColor = class and DF:GetClassColor(class)
            if classColor then
                r, g, b = classColor.r, classColor.g, classColor.b
            end
        end
        frame.healthBar:SetStatusBarColor(r, g, b)
        -- Apply alpha separately so range/dead fade can control it
        if not deadFadeActive then
            local tex = frame.healthBar:GetStatusBarTexture()
            if tex then tex:SetAlpha(classColorAlpha) end
        end
    else
        -- Custom color mode - use RGBA
        local c = db.healthColor
        frame.healthBar:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
    end
    
    -- Skip background color if dead fade with custom color is active
    if deadFadeActive and db.fadeDeadUseCustomColor then
        -- Dead fade custom color takes priority, don't override
        return
    end
    
    -- Also skip if dead fade is active (preserve the alpha)
    if deadFadeActive then
        return
    end
    
    -- Background color is handled by ElementAppearance.lua (UpdateBackgroundAppearance)
    -- which is called from UpdateUnitFrame. No need to duplicate it here.
end

-- Apply bar orientation
function DF:ApplyBarOrientation(frame)
    if not frame or not frame.healthBar then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    local mode = db.healthOrientation or "HORIZONTAL"
    
    local orient, reverse
    if mode == "HORIZONTAL" then
        orient, reverse = "HORIZONTAL", false
    elseif mode == "HORIZONTAL_INV" then
        orient, reverse = "HORIZONTAL", true
    elseif mode == "VERTICAL" then
        orient, reverse = "VERTICAL", false
    elseif mode == "VERTICAL_INV" then
        orient, reverse = "VERTICAL", true
    end
    
    frame.healthBar:SetOrientation(orient)
    frame.healthBar:SetReverseFill(reverse)
    
    -- Apply orientation to missing health bar (opposite fill direction)
    -- Missing health fills from the "end" where health is depleted
    if frame.missingHealthBar then
        frame.missingHealthBar:SetOrientation(orient)
        frame.missingHealthBar:SetReverseFill(not reverse)  -- Opposite of health bar
    end
end

