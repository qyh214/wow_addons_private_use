local addonName, DF = ...

-- ============================================================
-- FRAMES CORE MODULE
-- Contains shared containers, helpers, and utilities
-- ============================================================

-- ============================================================
-- FRAME CONTAINERS
-- ============================================================

-- NOTE: Party/raid frames are now created by SecureGroupHeaderTemplate in Headers.lua
-- These legacy tables are kept empty for backwards compatibility
-- Access frames via DF:IteratePartyFrames() and DF:IterateRaidFrames() instead
-- Legacy frame references for backward compatibility
-- In the old (pre-header) system, these were populated directly:
--   DF.playerFrame = CreatePartyFrame("player")
--   DF.partyFrames[i] = CreatePartyFrame("party"..i)
--   DF.raidFrames[i] = CreateRaidFrame("raid"..i)
-- Now frames are managed by SecureGroupHeaderTemplate, so these use
-- proxy tables that dynamically resolve via the header-based getters.
-- This preserves the API for external addons using AllowAddOnTableAccess.
DF.playerFrame = nil  -- Updated by Headers.lua OnAttributeChanged when unit=="player"
DF.partyFrames = setmetatable({}, {
    __index = function(_, k)
        if type(k) == "number" and DF.GetPartyFrame then
            return DF:GetPartyFrame(k)
        end
    end
})
DF.raidFrames = setmetatable({}, {
    __index = function(_, k)
        if type(k) == "number" and DF.GetRaidFrame then
            return DF:GetRaidFrame(k)
        end
    end
})

DF.container = nil
DF.moverFrame = nil
DF.testMode = false

-- Raid frame containers
DF.raidContainer = nil
DF.raidMoverFrame = nil

-- Color curve cache for gradient mode
DF.CurveCache = {}

-- ============================================================
-- SECRET VALUE HANDLING (WoW 12.0+ / Midnight Beta)
-- ============================================================
-- In WoW 12.0+, certain Unit APIs may return "secret values" that cannot
-- be used in arithmetic operations. The proper handling is:
--
-- 1. HEALTH BARS: Use GetSafeHealthPercent() helper which tries CurveConstants
--    first, then falls back to old boolean API
-- 2. POWER BARS: Check type(value) ~= "number" to detect secrets, then either
--    hide the bar or pass values directly to StatusBar APIs
-- 3. ABSORB BARS: UnitHealthMax is safe, but UnitGetTotalAbsorbs/HealAbsorbs
--    may be secret - pass directly to StatusBar:SetValue() without comparison
-- 4. HEALTH TEXT: Use SetFormattedText which handles secret values internally
-- 5. COLORS: Use UnitHealthPercent(unit, true, curve) to get colors directly
-- ============================================================

-- Helper to get health percent safely with proper scale (0-100)
-- Uses CurveConstants.ScaleTo100 which returns 0-100 directly
local function GetSafeHealthPercent(unit)
    -- Use ScaleTo100 curve - returns 0-100 directly
    return UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
end

-- Export for use in other files
DF.GetSafeHealthPercent = GetSafeHealthPercent

-- Helper to set health bar value safely
-- Uses CurveConstants.ScaleTo100 for the bar value, then delegates
-- threshold fading to HealthFade.lua's curve-based system.
local function SetHealthBarValue(bar, unit, frame)
    if not bar then return end

    -- Get health percent (0-100) via CurveConstants.ScaleTo100
    local pct = GetSafeHealthPercent(unit)

    -- Set bar range and value
    bar:SetMinMaxValues(0, 100)

    -- Get the appropriate db for this frame
    local db
    if frame and frame.isRaidFrame then
        db = DF.GetRaidDB and DF:GetRaidDB()
    else
        db = DF.GetDB and DF:GetDB()
    end
    local smoothEnabled = db and db.smoothBars

    if smoothEnabled and Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut then
        bar:SetValue(pct, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        bar:SetValue(pct)
    end

    -- Health threshold fading (curve-based, no Lua-side secret comparison)
    if frame then
        if DF.UpdateHealthFade then
            DF:UpdateHealthFade(frame)
        end
    end
end

-- Export for use in other files
DF.SetHealthBarValue = SetHealthBarValue

-- Helper to set missing health bar value safely
-- Uses UnitHealthMissing API which is safe with secret values
-- IMPORTANT: We pass values directly to StatusBar APIs without arithmetic
local function SetMissingHealthBarValue(bar, unit, frame)
    if not bar then return end
    
    -- Get the appropriate db for this frame
    local db
    if frame and frame.isRaidFrame then
        db = DF.GetRaidDB and DF:GetRaidDB()
    else
        db = DF.GetDB and DF:GetDB()
    end
    
    local backgroundMode = db and db.backgroundMode or "BACKGROUND"
    
    -- Only show if mode includes missing health
    if backgroundMode == "BACKGROUND" then
        bar:Hide()
        return
    end
    
    -- Use UnitHealthMissing API - safe with secret values
    -- Second param true means use predicted/displayable value
    -- CRITICAL: Do NOT do arithmetic on these values - pass directly to StatusBar
    local missingHealth = UnitHealthMissing(unit, true)
    local maxHealth = UnitHealthMax(unit)
    
    -- Set bar range using maxHealth, value using missingHealth
    -- StatusBar handles the math internally (safe with secret values)
    bar:SetMinMaxValues(0, maxHealth)
    
    local smoothEnabled = db and db.smoothBars
    if smoothEnabled and Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut then
        bar:SetValue(missingHealth, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        bar:SetValue(missingHealth)
    end
    
    -- Update texture before color (SetStatusBarTexture resets vertex color)
    local texture = db and db.missingHealthTexture
    if not texture or texture == "" then
        texture = db and db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar"
    end
    bar:SetStatusBarTexture(texture)
    
    -- Update color based on color mode
    local colorMode = db and db.missingHealthColorMode or "CUSTOM"
    local r, g, b, a
    
    -- Check for dead/offline state with custom dead color enabled
    local isDeadOrOffline = unit and UnitExists(unit) and (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit))
    local useDeadColor = isDeadOrOffline and db.fadeDeadFrames and db.fadeDeadUseCustomColor
    
    if useDeadColor then
        -- Use custom dead color (same as background uses)
        local c = db.fadeDeadBackgroundColor or {r = 0.3, g = 0, b = 0}
        r, g, b = c.r, c.g, c.b
        a = db.fadeDeadBackground or 0.4
    elseif colorMode == "PERCENT" and unit and UnitExists(unit) then
        -- Use health gradient curve
        local applied = false
        local curve = DF:GetCurveForUnit(unit, db, "missingHealthColor", DF.MissingHealthCurveCache)
        if curve and UnitHealthPercent then
            local color = UnitHealthPercent(unit, true, curve)
            local tex = bar:GetStatusBarTexture()
            if color and tex then
                tex:SetVertexColor(color:GetRGB())
                tex:SetAlpha(db.missingHealthGradientAlpha or 0.8)
                applied = true
            end
        end
        if not applied then
            r, g, b = 0.5, 0, 0
            a = db.missingHealthGradientAlpha or 0.8
        end
    elseif colorMode == "CLASS" and unit and UnitExists(unit) then
        -- Use class color
        local _, class = UnitClass(unit)
        local classColor = DF:GetClassColor(class)
        if classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
        else
            r, g, b = 0.5, 0, 0  -- Fallback dark red
        end
        a = db and db.missingHealthClassAlpha or 0.8
    else
        -- Use custom color
        local missingColor = db and db.missingHealthColor or {r = 0.5, g = 0, b = 0, a = 0.8}
        r, g, b, a = missingColor.r, missingColor.g, missingColor.b, missingColor.a or 0.8
    end
    if r then
        bar:SetStatusBarColor(r, g, b, a)
    end
    
    bar:Show()
end

-- Export for use in other files
DF.SetMissingHealthBarValue = SetMissingHealthBarValue

-- ============================================================
-- PIXEL-PERFECT SCALING
-- ============================================================

-- Cached pixel scale value (updated on UI scale changes)
local cachedPixelScale = nil

-- Calculate the pixel-perfect scale factor
-- This ensures 1 unit in WoW coordinates equals exactly 1 screen pixel
function DF:UpdatePixelScale()
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    local uiScale = UIParent:GetEffectiveScale()
    -- WoW's reference resolution is 768 pixels high
    local pixelScale = 768 / physicalHeight
    cachedPixelScale = pixelScale / uiScale
end

-- Get the cached pixel scale (calculates if not yet cached)
function DF:GetPixelScale()
    if not cachedPixelScale then
        self:UpdatePixelScale()
    end
    return cachedPixelScale
end

-- Snap a value to the nearest pixel boundary
-- Returns the adjusted value that will render pixel-perfectly
function DF:PixelPerfect(value)
    local scale = self:GetPixelScale()
    return math.floor(value / scale + 0.5) * scale
end

-- Snap a value to the nearest pixel boundary, but ensure minimum 1 pixel for thickness values
function DF:PixelPerfectThickness(value)
    local scale = self:GetPixelScale()
    local result = math.floor(value / scale + 0.5) * scale
    -- Ensure minimum 1 pixel thickness
    if result < scale then
        result = scale
    end
    return result
end

-- Snap a value UP to the next pixel boundary (ceiling)
function DF:PixelPerfectCeil(value)
    local scale = self:GetPixelScale()
    return math.ceil(value / scale) * scale
end

-- Adjust a size to ensure borders fit evenly on all sides
-- Takes a desired size and border thickness, returns adjusted size
-- Ensures the inner content area (size - 2*border) is a whole pixel count
-- and the overall size accommodates the border cleanly
function DF:PixelPerfectSizeForBorder(size, borderThickness)
    local scale = self:GetPixelScale()
    
    -- Snap border to nearest pixel (minimum 1 pixel if > 0)
    local borderPixels = math.floor(borderThickness / scale + 0.5)
    if borderThickness > 0 and borderPixels < 1 then
        borderPixels = 1
    end
    local ppBorder = borderPixels * scale
    
    -- Snap size to nearest pixel
    local sizePixels = math.floor(size / scale + 0.5)
    
    -- Calculate content area (what's left after borders on both sides)
    local contentPixels = sizePixels - (2 * borderPixels)
    
    -- If content would be less than 1 pixel, increase size
    if contentPixels < 1 then
        contentPixels = 1
        sizePixels = contentPixels + (2 * borderPixels)
    end
    
    return sizePixels * scale, ppBorder
end

-- Adjust size and scale together to ensure pixel-perfect rendering with borders
-- The key insight: SetScale scales EVERYTHING including border thickness
-- So a 1px border at scale 1.15 becomes 1.15px which won't render cleanly
-- Solution: Calculate final size, set that directly, and use scale=1.0
-- Returns: finalSize (to use with SetSize), scale (always 1.0), adjustedBorder
function DF:PixelPerfectSizeAndScaleForBorder(size, iconScale, borderThickness)
    local pixelScale = self:GetPixelScale()
    
    -- Calculate the desired final rendered size (what the user expects to see)
    local desiredFinalSize = size * iconScale
    
    -- Snap border to nearest pixel (minimum 1 pixel if > 0)
    local borderPixels = math.floor(borderThickness / pixelScale + 0.5)
    if borderThickness > 0 and borderPixels < 1 then
        borderPixels = 1
    end
    local ppBorder = borderPixels * pixelScale
    
    -- Snap the final size to nearest pixel
    local finalSizePixels = math.floor(desiredFinalSize / pixelScale + 0.5)
    
    -- Calculate content area (what's left after borders on both sides)
    local contentPixels = finalSizePixels - (2 * borderPixels)
    
    -- If content would be less than 1 pixel, increase size
    if contentPixels < 1 then
        contentPixels = 1
        finalSizePixels = contentPixels + (2 * borderPixels)
    end
    
    local ppFinalSize = finalSizePixels * pixelScale
    
    -- Return: the pixel-perfect final size, scale=1.0 (no scaling), and border
    -- By using scale=1.0, the border stays at exactly the specified pixel width
    return ppFinalSize, 1.0, ppBorder
end

-- Pixel-perfect SetSize helper
-- Only applies pixel snapping if pixelPerfect is enabled in the given db
-- Skips SetSize for secure header children during combat
function DF:SetPixelPerfectSize(frame, width, height, db)
    -- Skip for secure header children during combat (protected frame restriction)
    if frame.dfIsHeaderChild and InCombatLockdown() then
        return
    end
    
    if db and db.pixelPerfect then
        frame:SetSize(self:PixelPerfect(width), self:PixelPerfect(height))
    else
        frame:SetSize(width, height)
    end
end

-- Pixel-perfect SetWidth helper
-- Skips SetWidth for secure header children during combat
function DF:SetPixelPerfectWidth(frame, width, db)
    -- Skip for secure header children during combat (protected frame restriction)
    if frame.dfIsHeaderChild and InCombatLockdown() then
        return
    end
    
    if db and db.pixelPerfect then
        frame:SetWidth(self:PixelPerfect(width))
    else
        frame:SetWidth(width)
    end
end

-- Pixel-perfect SetHeight helper
-- Skips SetHeight for secure header children during combat
function DF:SetPixelPerfectHeight(frame, height, db)
    -- Skip for secure header children during combat (protected frame restriction)
    if frame.dfIsHeaderChild and InCombatLockdown() then
        return
    end
    
    if db and db.pixelPerfect then
        frame:SetHeight(self:PixelPerfect(height))
    else
        frame:SetHeight(height)
    end
end

-- Register for UI scale change events to update pixel scale
local pixelScaleFrame = CreateFrame("Frame")
pixelScaleFrame:RegisterEvent("UI_SCALE_CHANGED")
pixelScaleFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
pixelScaleFrame:SetScript("OnEvent", function()
    DF:UpdatePixelScale()
    -- Refresh all frames to apply new pixel scale
    if DF.initialized then
        if DF.UpdateAllFrames then
            DF:UpdateAllFrames()
        end
        if DF.UpdateRaidLayout then
            DF:UpdateRaidLayout()
        end
    end
end)

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- External lookup table for raid frame status
-- WoW 12.0's SecureGroupHeader_Update (C code) clears custom Lua fields on child
-- frames during template processing. This table lives OUTSIDE the frame object,
-- so the secure template can't touch it.
DF.raidFrameRegistry = DF.raidFrameRegistry or setmetatable({}, {__mode = "k"})

-- Register a frame as a raid frame (call from InitializeHeaderChild and FlatRaidFrames)
function DF:RegisterRaidFrame(frame)
    if frame then
        self.raidFrameRegistry[frame] = true
        frame.isRaidFrame = true  -- Also set the field (fast path if it sticks)
    end
end

-- Check if a frame is a raid frame (checks external registry first, then field)
function DF:IsRaidFrame(frame)
    if not frame then return false end
    return frame.isRaidFrame or self.raidFrameRegistry[frame] or false
end

-- Helper to get correct DB based on frame type
function DF:GetFrameDB(frame)
    if frame and DF:IsRaidFrame(frame) then
        return DF:GetRaidDB()
    else
        return DF:GetDB()
    end
end

-- Note: FormatNumber should only be used with known-accessible values
-- For secret values from Unit APIs, use SetFormattedText with %s directly
function DF:FormatNumber(num)
    if not num then return "0" end
    
    -- Use Blizzard's abbreviation if available (handles large numbers)
    if AbbreviateNumbers then
        return AbbreviateNumbers(num)
    elseif AbbreviateLargeNumbers then
        return AbbreviateLargeNumbers(num)
    end
    
    return tostring(num)
end

-- Abbreviate large numbers (for health text, etc.)
function DF:AbbreviateNumber(num)
    if not num then return "0" end
    
    if num >= 1000000000 then
        return string.format("%.1fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

-- Get duration text color based on remaining percentage (for test mode)
-- Returns r, g, b values matching the color curve used for live frames
-- 0% = red, 30% = orange, 50% = yellow, 100% = green
function DF:GetDurationColorByPercent(percent)
    if not percent then return 1, 1, 1 end
    
    -- Clamp to 0-1 range
    percent = math.max(0, math.min(1, percent))
    
    if percent < 0.3 then
        -- Red to Orange (0% to 30%)
        local t = percent / 0.3
        return 1, 0.5 * t, 0
    elseif percent < 0.5 then
        -- Orange to Yellow (30% to 50%)
        local t = (percent - 0.3) / 0.2
        return 1, 0.5 + 0.5 * t, 0
    else
        -- Yellow to Green (50% to 100%)
        local t = (percent - 0.5) / 0.5
        return 1 - t, 1, 0
    end
end

-- Check if frame is valid for updates
function DF:IsValidFrame(frame)
    return frame and frame.healthBar and true or false
end

-- ============================================================
-- EXTERNAL ADDON API
-- Provides methods for other addons (like RG_Aliases) to hook
-- ============================================================

-- Get unit name - can be overridden by other addons (like RG_Aliases)
-- This is the primary hook point for nickname addons
function DF:GetUnitName(unit)
    return UnitName(unit) or unit
end

-- Iterator for all compact unit frames (player, party, raid)
-- Accepts a callback function OR returns an iterator if no callback provided
-- Usage with callback: DF:IterateCompactFrames(function(frame) ... end)
-- Usage as iterator: for frame in DF:IterateCompactFrames() do ... end
function DF:IterateCompactFrames(callback)
    local frames = {}

    -- Arena first (IsInRaid()=true in arena, so must check before raid)
    if DF.IsInArena and DF:IsInArena() then
        if DF.IterateArenaFrames then
            DF:IterateArenaFrames(function(frame)
                if frame then
                    table.insert(frames, frame)
                end
            end)
        end
    else
        -- Add party frames (includes player via headers)
        if DF.IteratePartyFrames then
            DF:IteratePartyFrames(function(frame)
                if frame then
                    table.insert(frames, frame)
                end
            end)
        end

        -- Add raid frames
        if DF.IterateRaidFrames then
            DF:IterateRaidFrames(function(frame)
                if frame then
                    table.insert(frames, frame)
                end
            end)
        end
    end
    
    -- If callback provided, call it for each frame (RG_Aliases style)
    if callback and type(callback) == "function" then
        for _, frame in ipairs(frames) do
            callback(frame)
        end
        return
    end
    
    -- Otherwise return an iterator
    local i = 0
    return function()
        i = i + 1
        return frames[i]
    end
end

-- Get all visible frames as a table (alternative to iterator)
function DF:GetAllFrames()
    local frames = {}

    -- Arena first (IsInRaid()=true in arena, so must check before raid)
    if DF.IsInArena and DF:IsInArena() then
        if DF.IterateArenaFrames then
            DF:IterateArenaFrames(function(frame)
                if frame and frame:IsShown() then
                    table.insert(frames, frame)
                end
            end)
        end
        return frames
    end

    -- Add party frames (includes player via headers)
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            if frame and frame:IsShown() then
                table.insert(frames, frame)
            end
        end)
    end

    -- Add raid frames
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            if frame and frame:IsShown() then
                table.insert(frames, frame)
            end
        end)
    end

    return frames
end

-- Get frame for a specific unit
function DF:GetFrameForUnit(unit)
    if not unit then return nil end

    local foundFrame = nil

    -- Arena first (IsInRaid()=true in arena, so must check before raid)
    if DF.IsInArena and DF:IsInArena() then
        if DF.IterateArenaFrames then
            DF:IterateArenaFrames(function(frame)
                if frame and frame.unit == unit then
                    foundFrame = frame
                    return true  -- Stop iteration
                end
            end)
        end
        return foundFrame
    end

    -- Check party frames (includes player)
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            if frame and frame.unit == unit then
                foundFrame = frame
                return true  -- Stop iteration
            end
        end)
        if foundFrame then return foundFrame end
    end

    -- Check raid frames
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            if frame and frame.unit == unit then
                foundFrame = frame
                return true  -- Stop iteration
            end
        end)
    end

    return foundFrame
end

-- ============================================================
-- ROLE ICON TEXTURE HELPER
-- Centralizes texture resolution for all role icon styles
-- ============================================================
local ROLE_ICON_TEXTURES = {
    TANK = "Interface\\AddOns\\DandersFrames\\Media\\DF_Tank",
    HEALER = "Interface\\AddOns\\DandersFrames\\Media\\DF_Healer",
    DAMAGER = "Interface\\AddOns\\DandersFrames\\Media\\DF_DPS",
}

local BLIZZARD_ROLE_COORDS = {
    TANK = {0, 0.296875, 0.296875, 0.65},
    HEALER = {0.296875, 0.59375, 0, 0.296875},
    DAMAGER = {0.296875, 0.59375, 0.296875, 0.65},
}

function DF:GetRoleIconTexture(db, role)
    local style = db.roleIconStyle or "BLIZZARD"

    if style == "EXTERNAL" then
        local path
        if role == "TANK" then path = db.roleIconExternalTank
        elseif role == "HEALER" then path = db.roleIconExternalHealer
        elseif role == "DAMAGER" then path = db.roleIconExternalDPS
        end
        -- Fall back to DF Icons if path is empty
        if path and path ~= "" then
            -- Strip everything before "Interface" (e.g. full filesystem paths)
            path = path:gsub("^.*[/\\]([Ii]nterface)", "%1")
            -- Strip file extensions (.tga, .blp, .png) — WoW expects paths without them
            path = path:gsub("%.[tT][gG][aA]$", "")
            path = path:gsub("%.[bB][lL][pP]$", "")
            path = path:gsub("%.[pP][nN][gG]$", "")
            return path, 0, 1, 0, 1
        end
        style = "CUSTOM"
    end

    if style == "CUSTOM" then
        return ROLE_ICON_TEXTURES[role], 0, 1, 0, 1
    else
        -- BLIZZARD
        local c = BLIZZARD_ROLE_COORDS[role]
        return "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", c[1], c[2], c[3], c[4]
    end
end
