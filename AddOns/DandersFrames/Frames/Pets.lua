local addonName, DF = ...

-- ============================================================
-- PET FRAMES MODULE
-- Handles creation, positioning, and updates for pet frames
-- ============================================================

-- Storage for pet frames
DF.petFrames = DF.petFrames or {}
DF.partyPetFrames = DF.partyPetFrames or {}
DF.raidPetFrames = DF.raidPetFrames or {}

-- Storage for test mode pet frames (non-secure, independent of live frames)
DF.testPetFrames = DF.testPetFrames or {}       -- [0]=player pet, [1-4]=party pets
DF.testRaidPetFrames = DF.testRaidPetFrames or {} -- [1-40]=raid pets

-- ============================================================
-- PET FRAME CREATION
-- ============================================================

function DF:CreatePetFrame(unit, ownerFrame, isRaid)
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local parent = ownerFrame or (isRaid and DF.raidContainer or DF.container)
    
    -- Generate frame name based on unit
    local frameName = "DandersFrames_Pet_" .. unit:gsub("pet", "Pet")
    
    local frame = CreateFrame("Button", frameName, parent, "SecureUnitButtonTemplate,SecureHandlerEnterLeaveTemplate")
    frame:SetSize(db.petFrameWidth or 80, db.petFrameHeight or 20)
    frame.unit = unit
    frame.ownerFrame = ownerFrame
    frame.isPetFrame = true
    frame.isRaidFrame = isRaid
    frame.dfIsDandersFrame = true  -- Mark as DandersFrames frame for click casting module
    
    -- Register unit attribute
    frame:SetAttribute("unit", unit)
    -- Note: type1/type2 are set by click-casting module (or RestoreBlizzardDefaults when disabled)
    
    -- Background
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Health bar
    frame.healthBar = CreateFrame("StatusBar", nil, frame)
    frame.healthBar:SetAllPoints()
    frame.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.healthBar:SetMinMaxValues(0, 100)
    frame.healthBar:SetValue(100)
    frame.healthBar:SetStatusBarColor(0, 0.8, 0)
    
    -- Health bar background (for deficit)
    frame.healthBar.bg = frame.healthBar:CreateTexture(nil, "BACKGROUND")
    frame.healthBar.bg:SetAllPoints()
    frame.healthBar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    
    -- Border
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", 1, -1)
    frame.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)
    
    -- Name text — do NOT use SetFont() directly; use SetFontObject so that
    -- later SafeSetFont calls with font families can properly override
    frame.nameText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.nameText:SetFontObject(GameFontNormal)
    frame.nameText:SetPoint("CENTER", 0, 0)
    frame.nameText:SetTextColor(1, 1, 1)
    frame.nameText:SetText("")

    -- Health text (optional, can be toggled) — same pattern: no direct SetFont()
    frame.healthText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.healthText:SetFontObject(GameFontNormal)
    frame.healthText:SetPoint("RIGHT", -2, 0)
    frame.healthText:SetTextColor(1, 1, 1)
    frame.healthText:SetText("")
    frame.healthText:Hide()
    
    -- Store owner unit for death checking
    local ownerUnit = unit:gsub("pet", "")
    if ownerUnit == "" then ownerUnit = "player" end
    frame.ownerUnit = ownerUnit
    
    -- Register events for this pet frame
    frame:SetScript("OnEvent", function(self, event, ...)
        DF:OnPetFrameEvent(self, event, ...)
    end)
    
    -- PERFORMANCE FIX 2025-01-20: Use RegisterUnitEvent for C++ level filtering
    -- Pet frames need to listen to both the pet unit AND the owner unit:
    -- - Pet unit: for health, name updates
    -- - Owner unit: for death detection (hide pet when owner dies) and UNIT_PET
    frame:RegisterUnitEvent("UNIT_HEALTH", unit, ownerUnit)  -- Need both pet and owner
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)          -- Pet only
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)        -- Pet only
    frame:RegisterUnitEvent("UNIT_FLAGS", unit, ownerUnit)   -- Need both (death detection)
    frame:RegisterUnitEvent("UNIT_PET", ownerUnit)           -- Fires on owner when pet changes
    
    --[[ OLD CODE - Remove after testing (was causing event flooding in cities)
    frame:RegisterEvent("UNIT_HEALTH")
    frame:RegisterEvent("UNIT_MAXHEALTH")
    frame:RegisterEvent("UNIT_NAME_UPDATE")
    frame:RegisterEvent("UNIT_FLAGS")  -- For detecting death
    frame:RegisterEvent("UNIT_PET")    -- For detecting pet summon/dismiss
    --]]
    
    -- Mouse interaction - use HookScript to not interfere with other handlers
    frame:HookScript("OnEnter", function(self)
        if db.tooltipFrameEnabled then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end
    end)
    
    frame:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Ping support
    DF:RegisterFrameForPing(frame)
    
    -- Register with external click-casting addons (Clique, Clicked, etc.)
    DF:RegisterFrameWithClickCast(frame)
    
    -- Initial hide - will be shown when pet exists
    frame:Hide()
    
    return frame
end

-- ============================================================
-- TEST PET FRAME CREATION
-- Non-secure Button frames for test mode preview
-- ============================================================

function DF:CreateTestPetFrame(unit, ownerTestFrame, isRaid)
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local parent = ownerTestFrame or (isRaid and DF.testRaidContainer or DF.testPartyContainer)

    -- Generate frame name
    local frameName = "DandersFrames_TestPet_" .. unit:gsub("pet", "Pet")

    -- Create as regular Button (NOT SecureUnitButtonTemplate)
    -- This allows show/hide at any time without combat lockdown
    local frame = CreateFrame("Button", frameName, parent)
    frame:SetSize(db.petFrameWidth or 80, db.petFrameHeight or 20)
    frame.unit = unit
    frame.ownerFrame = ownerTestFrame
    frame.isPetFrame = true
    frame.isRaidFrame = isRaid
    frame.dfIsTestFrame = true
    frame.dfIsDandersFrame = true

    -- Store owner unit for consistency with live pet frames
    local ownerUnit = unit:gsub("pet", "")
    if ownerUnit == "" then ownerUnit = "player" end
    frame.ownerUnit = ownerUnit

    -- Background
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    -- Health bar
    frame.healthBar = CreateFrame("StatusBar", nil, frame)
    frame.healthBar:SetAllPoints()
    frame.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.healthBar:SetMinMaxValues(0, 100)
    frame.healthBar:SetValue(100)
    frame.healthBar:SetStatusBarColor(0, 0.8, 0)

    -- Health bar background (for deficit)
    frame.healthBar.bg = frame.healthBar:CreateTexture(nil, "BACKGROUND")
    frame.healthBar.bg:SetAllPoints()
    frame.healthBar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

    -- Border
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", 1, -1)
    frame.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    -- Name text — do NOT use SetFont() directly; use SafeSetFont or SetFontObject
    -- so that later SafeSetFont calls with font families can properly override
    frame.nameText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.nameText:SetFontObject(GameFontNormal)
    frame.nameText:SetPoint("CENTER", 0, 0)
    frame.nameText:SetTextColor(1, 1, 1)
    frame.nameText:SetText("")

    -- Health text (optional, can be toggled) — same pattern: no direct SetFont()
    frame.healthText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.healthText:SetFontObject(GameFontNormal)
    frame.healthText:SetPoint("RIGHT", -2, 0)
    frame.healthText:SetTextColor(1, 1, 1)
    frame.healthText:SetText("")
    frame.healthText:Hide()

    -- No events registered - test frames use fake data
    -- No click-casting registration - test frames aren't for real unit targeting

    -- Initial hide
    frame:Hide()

    return frame
end

-- ============================================================
-- TEST PET FRAME INITIALIZATION
-- ============================================================

function DF:InitializeTestPetFrames()
    -- Create test pet frames for each test party frame
    for i = 0, 4 do
        if not DF.testPetFrames[i] and DF.testPartyFrames[i] then
            local unit = i == 0 and "pet" or ("partypet" .. i)
            DF.testPetFrames[i] = DF:CreateTestPetFrame(unit, DF.testPartyFrames[i], false)
        end
    end
end

function DF:InitializeTestRaidPetFrames()
    -- Create test pet frames for each test raid frame
    for i = 1, 40 do
        if not DF.testRaidPetFrames[i] and DF.testRaidFrames[i] then
            DF.testRaidPetFrames[i] = DF:CreateTestPetFrame("raidpet" .. i, DF.testRaidFrames[i], true)
        end
    end
end

-- ============================================================
-- TEST PET FRAME CLEANUP
-- ============================================================

function DF:HideAllTestPetFrames()
    for i = 0, 4 do
        if DF.testPetFrames[i] then DF.testPetFrames[i]:Hide() end
    end
    -- Also hide pet group container if it exists
    if DF.petGroupContainer then DF.petGroupContainer:Hide() end
end

function DF:HideAllTestRaidPetFrames()
    for i = 1, 40 do
        if DF.testRaidPetFrames[i] then DF.testRaidPetFrames[i]:Hide() end
    end
    if DF.raidPetGroupContainer then DF.raidPetGroupContainer:Hide() end
end

-- ============================================================
-- PET FRAME EVENTS
-- ============================================================

function DF:OnPetFrameEvent(frame, event, unit, ...)
    -- Handle UNIT_PET event (fires on owner unit when pet changes)
    if event == "UNIT_PET" then
        if unit == frame.ownerUnit then
            -- Owner's pet changed - update visibility
            if UnitExists(frame.unit) and not UnitIsDeadOrGhost(frame.ownerUnit) then
                DF:SetPetFrameVisible(frame, true)
                DF:UpdatePetHealth(frame)
                DF:UpdatePetName(frame)
            else
                DF:SetPetFrameVisible(frame, false)
            end
        end
        return
    end
    
    -- Check for owner unit events (for death detection)
    if unit == frame.ownerUnit then
        if event == "UNIT_HEALTH" or event == "UNIT_FLAGS" then
            -- Check if owner died - hide pet frame
            if UnitIsDeadOrGhost(frame.ownerUnit) then
                DF:SetPetFrameVisible(frame, false)
            else
                -- Owner alive, check if pet exists
                if UnitExists(frame.unit) then
                    DF:SetPetFrameVisible(frame, true)
                    DF:UpdatePetHealth(frame)
                end
            end
        end
        return
    end
    
    -- Handle pet unit events
    if unit ~= frame.unit then return end
    
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        DF:UpdatePetHealth(frame)
    elseif event == "UNIT_NAME_UPDATE" then
        DF:UpdatePetName(frame)
    elseif event == "UNIT_FLAGS" then
        -- Pet may have been dismissed or died
        if not UnitExists(frame.unit) then
            DF:SetPetFrameVisible(frame, false)
        end
    end
end

-- ============================================================
-- PET FRAME UPDATES
-- ============================================================

-- Helper to set pet frame visibility (uses SetAlpha to work in combat)
-- Note: When showing, we don't set alpha to 1 because range fading may need a different alpha
function DF:SetPetFrameVisible(frame, visible)
    if not frame then return end

    if visible then
        -- Mark as visible - range system will set appropriate alpha
        frame.dfPetHidden = false
        -- Set to 1 so range system can take over (don't compare current alpha - it may be secret)
        frame:SetAlpha(1)
        -- Also try to show if not in combat (for proper click targeting)
        if not InCombatLockdown() then
            frame:Show()
        else
            DF:Debug("PET", "SetPetFrameVisible: %s wants SHOW but InCombatLockdown - using alpha only", frame.unit or "?")
        end
    else
        -- Mark as hidden and set alpha to 0
        frame.dfPetHidden = true
        frame:SetAlpha(0)
        -- Also try to hide if not in combat
        if not InCombatLockdown() then
            frame:Hide()
        end
    end
end

function DF:UpdatePetHealth(frame)
    if not frame or not frame.unit then return end
    
    local unit = frame.unit
    local db = DF:GetFrameDB(frame)
    
    -- Check if pet exists
    if not UnitExists(unit) then 
        DF:SetPetFrameVisible(frame, false)
        return 
    end
    
    -- Check if owner is dead - hide pet frame if so
    local ownerUnit = unit:gsub("pet", "")
    if ownerUnit == "" then ownerUnit = "player" end
    if UnitIsDeadOrGhost(ownerUnit) then
        DF:SetPetFrameVisible(frame, false)
        return
    end
    
    -- Pet exists and owner is alive - show frame
    DF:SetPetFrameVisible(frame, true)
    
    -- Use the safe SetHealthBarValue function which handles secrets properly
    DF.SetHealthBarValue(frame.healthBar, unit, frame)
    
    -- Update health text if shown
    -- Pass secret value directly to SetFormattedText - it handles secrets internally
    if db.petShowHealthText and frame.healthText then
        local success = pcall(function()
            local pct = DF.GetSafeHealthPercent(unit)
            frame.healthText:SetFormattedText("%.0f%%", pct)
        end)
        if not success then
            frame.healthText:SetText("")
        end
        frame.healthText:Show()
    elseif frame.healthText then
        frame.healthText:Hide()
    end
    
    -- Color health bar based on settings
    if db.petHealthColorMode == "CLASS" then
        -- Try to get pet owner's class color
        local _, class = UnitClass(ownerUnit)
        if class then
            local color = DF:GetClassColor(class)
            if color then
                frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
                return
            end
        end
    elseif db.petHealthColorMode == "HEALTH" then
        -- Use gradient curve to get color based on health percentage
        -- UnitHealthPercent with a color curve returns the color directly
        local curve = DF:GetPetHealthGradientCurve()
        if curve then
            local success = pcall(function()
                local color = UnitHealthPercent(unit, true, curve)
                if color and color.GetRGB then
                    local tex = frame.healthBar:GetStatusBarTexture()
                    if tex then
                        tex:SetVertexColor(color:GetRGB())
                    end
                end
            end)
            if success then
                return
            end
        end
        -- Fallback if curve not available or failed - just use green
        frame.healthBar:SetStatusBarColor(0, 0.8, 0)
        return
    elseif db.petHealthColorMode == "CUSTOM" then
        local c = db.petHealthColor or {r = 0, g = 0.8, b = 0}
        frame.healthBar:SetStatusBarColor(c.r, c.g, c.b)
        return
    end
    
    -- Default green
    frame.healthBar:SetStatusBarColor(0, 0.8, 0)
end

-- Get or create a health gradient curve for pet frames
function DF:GetPetHealthGradientCurve()
    if not DF.petHealthCurve then
        -- Create a simple red-yellow-green gradient curve using C_CurveUtil
        if C_CurveUtil and C_CurveUtil.CreateColorCurve then
            local curve = C_CurveUtil.CreateColorCurve()
            curve:SetType(Enum.LuaCurveType.Linear)
            
            -- Add color points: red at 0%, yellow at 50%, green at 100%
            local red = CreateColor(1, 0, 0, 1)
            local yellow = CreateColor(1, 0.8, 0, 1)
            local green = CreateColor(0, 0.8, 0, 1)
            
            curve:AddPoint(0, red)
            curve:AddPoint(0.5, yellow)
            curve:AddPoint(1, green)
            
            DF.petHealthCurve = curve
        end
    end
    return DF.petHealthCurve
end

-- Apply visual styling to pet frame
function DF:ApplyPetFrameStyle(frame)
    if not frame then return end
    if InCombatLockdown() then return end

    local db = DF:GetFrameDB(frame)

    -- Calculate size - optionally match owner's dimensions (only in ATTACHED mode)
    local width = db.petFrameWidth or 80
    local height = db.petFrameHeight or 20
    
    -- Match Owner Width/Height only applies in ATTACHED mode, not GROUPED mode
    local isGroupedMode = db.petGroupMode == "GROUPED"
    
    if not isGroupedMode and frame.ownerFrame then
        if db.petMatchOwnerWidth then
            width = frame.ownerFrame:GetWidth()
        end
        if db.petMatchOwnerHeight then
            height = frame.ownerFrame:GetHeight()
        end
    end
    
    frame:SetSize(width, height)
    
    -- Update health bar texture - use path directly (dropdown saves paths)
    local texture = db.petTexture or "Interface\\TargetingFrame\\UI-StatusBar"
    frame.healthBar:SetStatusBarTexture(texture)
    frame.healthBar.bg:SetTexture(texture)
    
    -- Background color
    local bgColor = db.petBackgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
    frame.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 0.8)
    
    -- Health bar background color
    local healthBgColor = db.petHealthBgColor or {r = 0.2, g = 0.2, b = 0.2, a = 0.8}
    frame.healthBar.bg:SetVertexColor(healthBgColor.r, healthBgColor.g, healthBgColor.b, healthBgColor.a or 0.8)
    
    -- Border
    if db.petShowBorder then
        local borderColor = db.petBorderColor or {r = 0, g = 0, b = 0, a = 1}
        frame.border:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
        frame.border:Show()
    else
        frame.border:Hide()
    end
    
    -- Name text styling - use SafeSetFont like main frames
    local nameFont = db.petNameFont or "Fonts\\FRIZQT__.TTF"
    local nameFontSize = db.petNameFontSize or 9
    local nameFontOutline = db.petNameFontOutline or "OUTLINE"
    DF:SafeSetFont(frame.nameText, nameFont, nameFontSize, nameFontOutline)

    -- Name text position
    frame.nameText:ClearAllPoints()
    local nameAnchor = db.petNameAnchor or "CENTER"
    local nameX = db.petNameX or 0
    local nameY = db.petNameY or 0
    frame.nameText:SetPoint(nameAnchor, frame.healthBar, nameAnchor, nameX, nameY)
    
    -- Name text color
    local nameColor = db.petNameColor or {r = 1, g = 1, b = 1}
    frame.nameText:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
    
    -- Health text styling
    if frame.healthText then
        local healthFont = db.petHealthFont or "Fonts\\ARIALN.TTF"
        local healthFontSize = db.petHealthFontSize or 8
        local healthFontOutline = db.petHealthFontOutline or "OUTLINE"
        DF:SafeSetFont(frame.healthText, healthFont, healthFontSize, healthFontOutline)
        
        -- Health text position
        frame.healthText:ClearAllPoints()
        local healthAnchor = db.petHealthAnchor or "RIGHT"
        local healthX = db.petHealthX or -2
        local healthY = db.petHealthY or 0
        frame.healthText:SetPoint(healthAnchor, frame.healthBar, healthAnchor, healthX, healthY)
        
        -- Health text color
        local healthColor = db.petHealthTextColor or {r = 1, g = 1, b = 1}
        frame.healthText:SetTextColor(healthColor.r, healthColor.g, healthColor.b)
    end
end

function DF:UpdatePetName(frame)
    if not frame or not frame.unit then return end
    if not UnitExists(frame.unit) then return end
    
    local name = GetUnitName(frame.unit, true)
    if name then
        -- Truncate long names
        local db = DF:GetFrameDB(frame)
        local maxLen = db.petNameMaxLength or 12
        if #name > maxLen then
            name = name:sub(1, maxLen) .. "..."
        end
        frame.nameText:SetText(name)
    end
end

function DF:UpdatePetFrame(frame)
    if not frame then return end

    local db = DF:GetFrameDB(frame)

    -- Check if owner is dead - hide pet frame if so
    local ownerUnit = frame.unit:gsub("pet", "")
    if ownerUnit == "" then ownerUnit = "player" end

    -- Test mode handling
    local isInTestMode = (frame.isRaidFrame and DF.raidTestMode) or (not frame.isRaidFrame and DF.testMode)

    if isInTestMode then
        -- Check if pets should be shown in test mode
        if db.testShowPets == false then
            DF:Debug("PET", "UpdatePetFrame: %s HIDDEN (testShowPets=false)", frame.unit)
            DF:SetPetFrameVisible(frame, false)
            return
        end
        -- In test mode, show pet frames with fake data
        DF:ApplyPetFrameStyle(frame)
        DF:UpdatePetFrameTestMode(frame)
        DF:SetPetFrameVisible(frame, true)
        return
    end

    -- Update visibility and data
    local unitExists = UnitExists(frame.unit)
    local ownerDead = UnitIsDeadOrGhost(ownerUnit)
    if unitExists and not ownerDead then
        -- Apply visual styling
        DF:ApplyPetFrameStyle(frame)
        -- Update health and name
        DF:UpdatePetHealth(frame)
        DF:UpdatePetName(frame)
        DF:SetPetFrameVisible(frame, true)
        DF:Debug("PET", "UpdatePetFrame: %s VISIBLE (unitExists=%s ownerDead=%s)", frame.unit, tostring(unitExists), tostring(ownerDead))
    else
        DF:SetPetFrameVisible(frame, false)
        DF:Debug("PET", "UpdatePetFrame: %s HIDDEN (unitExists=%s ownerDead=%s)", frame.unit, tostring(unitExists), tostring(ownerDead))
    end
end

-- Update pet frame with test mode fake data
function DF:UpdatePetFrameTestMode(frame)
    if not frame then return end
    
    -- Set fake name
    local petNames = {"Wolf", "Cat", "Bear", "Imp", "Voidwalker", "Felguard", "Water Elemental", "Ghoul", "Treant", "Earth Elemental"}
    local index = 1
    if frame.unit:match("partypet(%d+)") then
        index = tonumber(frame.unit:match("partypet(%d+)")) or 1
    elseif frame.unit:match("raidpet(%d+)") then
        index = tonumber(frame.unit:match("raidpet(%d+)")) or 1
    end
    local name = petNames[((index - 1) % #petNames) + 1]
    frame.nameText:SetText(name)
    
    -- Set fake health (random between 60-100%)
    local healthPercent = 0.6 + (math.random() * 0.4)
    frame.healthBar:SetMinMaxValues(0, 1)
    frame.healthBar:SetValue(healthPercent)
    
    -- Set health bar color (green)
    frame.healthBar:SetStatusBarColor(0.2, 0.8, 0.2)
    
    -- Update health text if shown
    if frame.healthText then
        local db = DF:GetFrameDB(frame)
        if db.petShowHealth then
            local maxHealth = 50000
            local currentHealth = math.floor(maxHealth * healthPercent)
            frame.healthText:SetText(string.format("%d%%", math.floor(healthPercent * 100)))
            frame.healthText:Show()
        else
            frame.healthText:Hide()
        end
    end
end

-- Lightweight update for live slider preview (no full rebuild)
function DF:LightweightUpdatePetFrames()
    -- Test mode: update test pet frames
    if DF.testMode then
        for i = 0, 4 do
            if DF.testPetFrames[i] then
                DF:ApplyPetFrameStyle(DF.testPetFrames[i])
                DF:PositionPetFrame(DF.testPetFrames[i])
            end
        end
    else
        -- Live mode: update real pet frames
        if DF.petFrames.player then
            DF:ApplyPetFrameStyle(DF.petFrames.player)
            DF:PositionPetFrame(DF.petFrames.player)
        end
        for i = 1, 4 do
            if DF.partyPetFrames[i] then
                DF:ApplyPetFrameStyle(DF.partyPetFrames[i])
                DF:PositionPetFrame(DF.partyPetFrames[i])
            end
        end
    end

    -- Raid test mode: update test raid pet frames
    if DF.raidTestMode then
        for i = 1, 40 do
            if DF.testRaidPetFrames[i] then
                DF:ApplyPetFrameStyle(DF.testRaidPetFrames[i])
                DF:PositionPetFrame(DF.testRaidPetFrames[i])
            end
        end
    else
        -- Live mode: update real raid pet frames
        for i = 1, 40 do
            if DF.raidPetFrames[i] then
                DF:ApplyPetFrameStyle(DF.raidPetFrames[i])
                DF:PositionPetFrame(DF.raidPetFrames[i])
            end
        end
    end
end

-- ============================================================
-- PET FRAME POSITIONING
-- ============================================================

function DF:PositionPetFrame(frame)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if we're using grouped mode
    if db.petGroupMode == "GROUPED" then
        -- In grouped mode, positioning is handled by UpdatePetGroupLayout
        return
    end
    
    -- ATTACHED mode - position relative to owner
    if not frame.ownerFrame then return end
    
    local anchor = db.petAnchor or "BOTTOM"
    local offsetX = db.petOffsetX or 0
    local offsetY = db.petOffsetY or -2
    
    frame:ClearAllPoints()
    frame:SetParent(frame.ownerFrame:GetParent())
    
    if anchor == "BOTTOM" then
        frame:SetPoint("TOP", frame.ownerFrame, "BOTTOM", offsetX, offsetY)
    elseif anchor == "TOP" then
        frame:SetPoint("BOTTOM", frame.ownerFrame, "TOP", offsetX, -offsetY)
    elseif anchor == "LEFT" then
        frame:SetPoint("RIGHT", frame.ownerFrame, "LEFT", offsetX, offsetY)
    elseif anchor == "RIGHT" then
        frame:SetPoint("LEFT", frame.ownerFrame, "RIGHT", -offsetX, offsetY)
    end
end

-- ============================================================
-- PET GROUP CONTAINER (Party Mode)
-- ============================================================

function DF:CreatePetGroupContainer()
    if DF.petGroupContainer then return DF.petGroupContainer end
    
    local container = CreateFrame("Frame", "DandersFrames_PetGroupContainer", UIParent)
    container:SetSize(200, 50)
    container:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    container:Hide()
    
    DF.petGroupContainer = container
    return container
end

function DF:UpdatePetGroupLayout()
    local db = DF:GetDB()
    local isTestMode = DF.testMode

    -- Only use group layout if in GROUPED mode and pets are enabled/shown
    local petsEnabled = isTestMode and (db.petEnabled and db.testShowPets ~= false) or (not isTestMode and db.petEnabled)
    if db.petGroupMode ~= "GROUPED" or not petsEnabled then
        if DF.petGroupContainer then
            DF.petGroupContainer:Hide()
        end
        return
    end

    -- Create container if needed
    if not DF.petGroupContainer then
        DF:CreatePetGroupContainer()
    end

    local container = DF.petGroupContainer

    -- In live mode, need a party container reference
    if not isTestMode and not DF.container then return end

    -- Collect visible pet frames
    local petFrames = {}
    local testFrameCount = db.testFrameCount or 5

    if isTestMode then
        -- Test mode: use test pet frames
        if testFrameCount >= 1 and DF.testPetFrames[0] then
            table.insert(petFrames, DF.testPetFrames[0])
        end
        for i = 1, 4 do
            if (i + 1) <= testFrameCount and DF.testPetFrames[i] then
                table.insert(petFrames, DF.testPetFrames[i])
            end
        end
    else
        -- Normal mode - check which pets actually exist
        if DF.petFrames.player and UnitExists("pet") then
            table.insert(petFrames, DF.petFrames.player)
        end
        for i = 1, 4 do
            if DF.partyPetFrames[i] and UnitExists("partypet" .. i) then
                table.insert(petFrames, DF.partyPetFrames[i])
            end
        end
    end

    if #petFrames == 0 then
        container:Hide()
        return
    end

    -- Get settings
    local growth = db.petGroupGrowth or "HORIZONTAL"
    local spacing = db.petGroupSpacing or 2
    local anchor = db.petGroupAnchor or "BOTTOM"
    local offsetX = db.petGroupOffsetX or 0
    local offsetY = db.petGroupOffsetY or -5

    -- Calculate container size using pet frame dimensions
    local petWidth = db.petFrameWidth or 80
    local petHeight = db.petFrameHeight or 18

    local containerWidth, containerHeight

    if growth == "HORIZONTAL" then
        containerWidth = (#petFrames * petWidth) + ((#petFrames - 1) * spacing)
        containerHeight = petHeight
    else
        containerWidth = petWidth
        containerHeight = (#petFrames * petHeight) + ((#petFrames - 1) * spacing)
    end

    container:SetSize(containerWidth, containerHeight)

    -- Calculate the actual center of visible party frames
    local visibleFrames = {}

    if isTestMode then
        -- Test mode: iterate test party frames directly
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame and frame:IsShown() and (i < testFrameCount) then
                table.insert(visibleFrames, frame)
            end
        end
    elseif DF.IteratePartyFrames then
        -- Live mode: use the iterator
        DF:IteratePartyFrames(function(frame)
            if frame and frame:IsShown() then
                table.insert(visibleFrames, frame)
            end
        end)
    end
    
    -- Position container relative to party frames
    container:ClearAllPoints()
    
    if #visibleFrames > 0 then
        local partyGrowth = db.growDirection or "HORIZONTAL"
        
        -- Find the actual bounds of all visible party frames using GetRect
        -- This handles frame sorting correctly - find actual leftmost/rightmost frames
        local minX, maxX, minY, maxY
        local leftmostFrame, rightmostFrame, topmostFrame, bottommostFrame
        
        for _, frame in ipairs(visibleFrames) do
            local left, bottom, width, height = frame:GetRect()
            if left and bottom and width and height then
                local right = left + width
                local top = bottom + height
                
                if not minX or left < minX then 
                    minX = left 
                    leftmostFrame = frame
                end
                if not maxX or right > maxX then 
                    maxX = right 
                    rightmostFrame = frame
                end
                if not minY or bottom < minY then 
                    minY = bottom 
                    bottommostFrame = frame
                end
                if not maxY or top > maxY then 
                    maxY = top 
                    topmostFrame = frame
                end
            end
        end
        
        if minX and maxX and minY and maxY and leftmostFrame then
            local totalPartyWidth = maxX - minX
            local totalPartyHeight = maxY - minY
            
            -- Calculate centering offset
            local centerOffsetX = (totalPartyWidth - containerWidth) / 2
            local centerOffsetY = (totalPartyHeight - containerHeight) / 2
            
            -- Position based on anchor - use the appropriate edge frame
            if anchor == "BOTTOM" then
                if partyGrowth == "HORIZONTAL" then
                    container:SetPoint("TOPLEFT", leftmostFrame, "BOTTOMLEFT", centerOffsetX + offsetX, offsetY)
                else
                    container:SetPoint("TOP", bottommostFrame, "BOTTOM", offsetX, offsetY)
                end
            elseif anchor == "TOP" then
                if partyGrowth == "HORIZONTAL" then
                    container:SetPoint("BOTTOMLEFT", leftmostFrame, "TOPLEFT", centerOffsetX + offsetX, -offsetY)
                else
                    container:SetPoint("BOTTOM", topmostFrame, "TOP", offsetX, -offsetY)
                end
            elseif anchor == "LEFT" then
                if partyGrowth == "HORIZONTAL" then
                    container:SetPoint("RIGHT", leftmostFrame, "LEFT", offsetX, offsetY)
                else
                    container:SetPoint("TOPRIGHT", topmostFrame, "TOPLEFT", offsetX, -centerOffsetY + offsetY)
                end
            elseif anchor == "RIGHT" then
                if partyGrowth == "HORIZONTAL" then
                    container:SetPoint("LEFT", rightmostFrame, "RIGHT", -offsetX, offsetY)
                else
                    container:SetPoint("TOPLEFT", bottommostFrame, "TOPRIGHT", -offsetX, -centerOffsetY + offsetY)
                end
            end
            
            container:Show()
            
            -- Position pet frames within container
            for i, frame in ipairs(petFrames) do
                frame:ClearAllPoints()
                frame:SetParent(container)
                
                if i == 1 then
                    if growth == "HORIZONTAL" then
                        frame:SetPoint("LEFT", container, "LEFT", 0, 0)
                    else
                        frame:SetPoint("TOP", container, "TOP", 0, 0)
                    end
                else
                    local prevFrame = petFrames[i - 1]
                    if growth == "HORIZONTAL" then
                        frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
                    else
                        frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
                    end
                end
            end
            return
        end
    end
    
    -- Fallback: use party container directly
    if anchor == "BOTTOM" then
        container:SetPoint("TOP", partyContainer, "BOTTOM", offsetX, offsetY)
    elseif anchor == "TOP" then
        container:SetPoint("BOTTOM", partyContainer, "TOP", offsetX, -offsetY)
    elseif anchor == "LEFT" then
        container:SetPoint("RIGHT", partyContainer, "LEFT", offsetX, offsetY)
    elseif anchor == "RIGHT" then
        container:SetPoint("LEFT", partyContainer, "RIGHT", -offsetX, offsetY)
    end
    
    -- Position pet frames within container (fallback path)
    for i, frame in ipairs(petFrames) do
        frame:ClearAllPoints()
        frame:SetParent(container)
        
        if i == 1 then
            if growth == "HORIZONTAL" then
                frame:SetPoint("LEFT", container, "LEFT", 0, 0)
            else
                frame:SetPoint("TOP", container, "TOP", 0, 0)
            end
        else
            local prevFrame = petFrames[i - 1]
            if growth == "HORIZONTAL" then
                frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
            else
                frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
            end
        end
    end
    
    container:Show()
end

-- ============================================================
-- RAID PET GROUP
-- ============================================================

function DF:CreateRaidPetGroupContainer()
    if DF.raidPetGroupContainer then return DF.raidPetGroupContainer end
    
    local container = CreateFrame("Frame", "DandersFrames_RaidPetGroupContainer", DF.raidContainer or UIParent)
    container:SetSize(200, 100)
    container:Hide()
    
    -- Create group label
    container.label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    container.label:SetPoint("BOTTOM", container, "TOP", 0, 2)
    container.label:SetText("Pets")
    
    DF.raidPetGroupContainer = container
    return container
end

function DF:UpdateRaidPetGroupLayout()
    local db = DF:GetRaidDB()
    local isTestMode = DF.raidTestMode

    -- Only use group layout if in GROUPED mode and pets are enabled/shown
    local petsEnabled = isTestMode and (db.petEnabled and db.testShowPets ~= false) or (not isTestMode and db.petEnabled)
    if db.petGroupMode ~= "GROUPED" or not petsEnabled then
        if DF.raidPetGroupContainer then
            DF.raidPetGroupContainer:Hide()
        end
        return
    end

    -- Create container if needed
    if not DF.raidPetGroupContainer then
        DF:CreateRaidPetGroupContainer()
    end

    local container = DF.raidPetGroupContainer

    -- In live mode, need a raid container reference
    if not isTestMode and not DF.raidContainer then return end
    local raidContainer = isTestMode and DF.testRaidContainer or DF.raidContainer

    -- Collect visible pet frames (cap at 10 for test mode)
    local petFrames = {}
    local maxPets = 10

    if isTestMode then
        -- Test mode: use test raid pet frames
        local testFrameCount = math.min(db.raidTestFrameCount or 10, maxPets)
        for i = 1, testFrameCount do
            if DF.testRaidPetFrames[i] then
                table.insert(petFrames, DF.testRaidPetFrames[i])
            end
        end
    else
        for i = 1, 40 do
            if DF.raidPetFrames[i] and UnitExists("raidpet" .. i) then
                table.insert(petFrames, DF.raidPetFrames[i])
            end
        end
    end

    if #petFrames == 0 then
        container:Hide()
        return
    end

    -- Get pet group settings
    local petFrameWidth = db.petFrameWidth or 72
    local petFrameHeight = db.petFrameHeight or 18
    local petSpacing = db.petGroupSpacing or 2
    local petGrowth = db.petGroupGrowth or "VERTICAL"
    local petAnchor = db.petGroupAnchor or "RIGHT"
    local offsetX = db.petGroupOffsetX or 5
    local offsetY = db.petGroupOffsetY or 0

    -- Size container based on pet frame dimensions and growth direction
    local containerWidth, containerHeight
    if petGrowth == "HORIZONTAL" then
        containerWidth = (#petFrames * petFrameWidth) + ((#petFrames - 1) * petSpacing)
        containerHeight = petFrameHeight
    else
        containerWidth = petFrameWidth
        containerHeight = (#petFrames * petFrameHeight) + ((#petFrames - 1) * petSpacing)
    end
    container:SetSize(containerWidth, containerHeight)

    -- Find actual bounds and edge frames of visible raid frames
    local minX, maxX, minY, maxY
    local leftmostFrame, rightmostFrame, topmostFrame, bottommostFrame

    -- Helper to process frame bounds
    local function processFrameBounds(frame)
        if frame and frame:IsShown() then
            local left, bottom, width, height = frame:GetRect()
            if left and bottom and width and height then
                local right = left + width
                local top = bottom + height

                if not minX or left < minX then
                    minX = left
                    leftmostFrame = frame
                end
                if not maxX or right > maxX then
                    maxX = right
                    rightmostFrame = frame
                end
                if not minY or bottom < minY then
                    minY = bottom
                    bottommostFrame = frame
                end
                if not maxY or top > maxY then
                    maxY = top
                    topmostFrame = frame
                end
            end
        end
    end

    if isTestMode then
        -- Test mode: iterate test raid frames directly
        local testFrameCount = db.raidTestFrameCount or 10
        for i = 1, testFrameCount do
            processFrameBounds(DF.testRaidFrames[i])
        end
    elseif DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            processFrameBounds(frame)
        end)
    end
    
    -- Position container relative to raid frames by anchoring to edge frames
    container:ClearAllPoints()
    container:SetParent(raidContainer)
    
    if minX and maxX and minY and maxY and leftmostFrame and rightmostFrame and topmostFrame and bottommostFrame then
        local raidWidth = maxX - minX
        local raidHeight = maxY - minY
        
        -- Calculate centering offsets
        local centerOffsetX = (raidWidth - containerWidth) / 2
        local centerOffsetY = (raidHeight - containerHeight) / 2
        
        if petAnchor == "RIGHT" then
            -- Right of raid frames, vertically centered
            -- Anchor to rightmostFrame, but need to offset Y since rightmostFrame might not be at top
            local rmLeft, rmBottom, rmWidth, rmHeight = rightmostFrame:GetRect()
            local rmTop = rmBottom + rmHeight
            local yAdjust = maxY - rmTop  -- How far down from the raid's top is this frame's top
            container:SetPoint("TOPLEFT", rightmostFrame, "TOPRIGHT", offsetX, yAdjust - centerOffsetY + offsetY)
            
        elseif petAnchor == "LEFT" then
            -- Left of raid frames, vertically centered
            -- Anchor to leftmostFrame, but need to offset Y since leftmostFrame might not be at top
            local lmLeft, lmBottom, lmWidth, lmHeight = leftmostFrame:GetRect()
            local lmTop = lmBottom + lmHeight
            local yAdjust = maxY - lmTop  -- How far down from the raid's top is this frame's top
            container:SetPoint("TOPRIGHT", leftmostFrame, "TOPLEFT", -offsetX, yAdjust - centerOffsetY + offsetY)
            
        elseif petAnchor == "BOTTOM" then
            -- Below raid frames, horizontally centered
            -- Anchor to bottommostFrame, but need to offset X since bottommostFrame might not be at left
            local bmLeft = select(1, bottommostFrame:GetRect())
            local xAdjust = bmLeft - minX  -- How far right from the raid's left is this frame
            container:SetPoint("TOPLEFT", bottommostFrame, "BOTTOMLEFT", -xAdjust + centerOffsetX + offsetX, -offsetY)
            
        elseif petAnchor == "TOP" then
            -- Above raid frames, horizontally centered
            -- Anchor to topmostFrame, but need to offset X since topmostFrame might not be at left
            local tmLeft = select(1, topmostFrame:GetRect())
            local xAdjust = tmLeft - minX  -- How far right from the raid's left is this frame
            container:SetPoint("BOTTOMLEFT", topmostFrame, "TOPLEFT", -xAdjust + centerOffsetX + offsetX, offsetY)
        end
    else
        -- Fallback: anchor to raid container directly
        container:SetPoint("TOPLEFT", raidContainer, "TOPRIGHT", offsetX, offsetY)
    end
    
    -- Update label
    if db.petGroupShowLabel ~= false then
        container.label:SetText(db.petGroupLabel or "Pets")
        container.label:Show()
        
        -- Apply group label styling from raid settings
        local labelFont = db.groupLabelFont or "Fonts\\FRIZQT__.TTF"
        local labelSize = db.groupLabelFontSize or 12
        local labelOutline = db.groupLabelOutline or "OUTLINE"
        DF:SafeSetFont(container.label, labelFont, labelSize, labelOutline)
        
        local labelColor = db.groupLabelColor or {r = 1, g = 1, b = 1}
        container.label:SetTextColor(labelColor.r, labelColor.g, labelColor.b)
    else
        container.label:Hide()
    end
    
    -- Position pet frames within container
    for i, frame in ipairs(petFrames) do
        frame:ClearAllPoints()
        frame:SetParent(container)
        
        if i == 1 then
            if petGrowth == "HORIZONTAL" then
                frame:SetPoint("LEFT", container, "LEFT", 0, 0)
            else
                frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
            end
        else
            local prevFrame = petFrames[i - 1]
            if petGrowth == "HORIZONTAL" then
                frame:SetPoint("LEFT", prevFrame, "RIGHT", petSpacing, 0)
            else
                frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -petSpacing)
            end
        end
    end
    
    container:Show()
end

-- ============================================================
-- PET FRAME INITIALIZATION
-- ============================================================

function DF:InitializePetFrames()
    local db = DF:GetDB()

    DF:Debug("PET", "InitializePetFrames called. petEnabled=%s petFramesInitialized=%s", tostring(db.petEnabled), tostring(DF.petFramesInitialized))

    -- Don't create if pets are disabled
    if not db.petEnabled then
        DF:Debug("PET", "InitializePetFrames: SKIPPED - pets disabled")
        return
    end

    -- Create player pet frame
    local playerFrame = DF:GetPlayerFrame()
    if not DF.petFrames.player and playerFrame then
        DF.petFrames.player = DF:CreatePetFrame("pet", playerFrame, false)
        DF:Debug("PET", "InitializePetFrames: created player pet frame")
    end
    DF:Debug("PET", "InitializePetFrames: playerFrame=%s petFrames.player=%s", tostring(playerFrame ~= nil), tostring(DF.petFrames.player ~= nil))

    -- Create party pet frames
    local partyCount = 0
    for i = 1, 4 do
        local partyFrame = DF:GetPartyFrame(i)
        if not DF.partyPetFrames[i] and partyFrame then
            DF.partyPetFrames[i] = DF:CreatePetFrame("partypet" .. i, partyFrame, false)
            partyCount = partyCount + 1
        end
    end
    DF:Debug("PET", "InitializePetFrames: created %d new party pet frames", partyCount)

    -- Only mark as initialized if at least one frame was actually created
    -- This allows retry when headers become available (e.g., joining a group)
    if DF.petFrames.player or next(DF.partyPetFrames) then
        DF.petFramesInitialized = true
        DF:Debug("PET", "InitializePetFrames: marked as initialized, positioning frames")
        -- Position all pet frames
        DF:UpdateAllPetFramePositions()
    else
        DF:Debug("PET", "InitializePetFrames: NO frames created - will retry later")
    end
end

function DF:InitializeRaidPetFrames()
    local db = DF:GetRaidDB()
    
    -- Don't create if pets are disabled for raid
    if not db.petEnabled then return end
    
    -- Create raid pet frames via iterator
    local frameIdx = 0
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            frameIdx = frameIdx + 1
            if not DF.raidPetFrames[frameIdx] and frame then
                DF.raidPetFrames[frameIdx] = DF:CreatePetFrame("raidpet" .. frameIdx, frame, true)
            end
        end)
    end
end

-- ============================================================
-- UPDATE ALL PET FRAMES
-- ============================================================

local lastPetUpdateTime = 0

function DF:UpdateAllPetFrames(force)
    -- Throttle: skip if already ran this frame (multiple callers during startup/updates)
    local now = GetTime()
    if not force and now == lastPetUpdateTime then return end
    lastPetUpdateTime = now

    local db = DF:GetDB()

    DF:Debug("PET", "UpdateAllPetFrames called. testMode=%s raidTestMode=%s petEnabled=%s testShowPets=%s",
        tostring(DF.testMode), tostring(DF.raidTestMode), tostring(db.petEnabled), tostring(db.testShowPets))

    -- Hide party pet group container if in raid test mode
    if DF.raidTestMode then
        DF:Debug("PET", "UpdateAllPetFrames: hiding party pets (raid test mode active)")
        if DF.petFrames.player then DF.petFrames.player:Hide() end
        for i = 1, 4 do
            if DF.partyPetFrames[i] then DF.partyPetFrames[i]:Hide() end
        end
        DF:HideAllTestPetFrames()
        return
    end

    -- In test mode, show pets if enabled AND testShowPets is on; outside test mode, check petEnabled
    local shouldShowPets
    if DF.testMode then
        shouldShowPets = db.petEnabled and (db.testShowPets ~= false)
    else
        shouldShowPets = db.petEnabled
    end

    DF:Debug("PET", "UpdateAllPetFrames: shouldShowPets=%s", tostring(shouldShowPets))

    if not shouldShowPets then
        -- Hide all pet frames if disabled
        if DF.testMode then
            DF:HideAllTestPetFrames()
        else
            if DF.petFrames.player then DF.petFrames.player:Hide() end
            for i = 1, 4 do
                if DF.partyPetFrames[i] then DF.partyPetFrames[i]:Hide() end
            end
            if DF.petGroupContainer then DF.petGroupContainer:Hide() end
        end
        return
    end

    -- Test mode: use test pet frames
    if DF.testMode then
        -- Initialize test pet frames if needed
        DF:InitializeTestPetFrames()

        local testFrameCount = db.testFrameCount or 5

        -- Update test pet frames
        for i = 0, 4 do
            if DF.testPetFrames[i] then
                if i < testFrameCount then
                    DF:UpdatePetFrame(DF.testPetFrames[i])
                    DF:PositionPetFrame(DF.testPetFrames[i])
                else
                    DF.testPetFrames[i]:Hide()
                end
            end
        end

        -- Update group layout if in grouped mode
        if db.petGroupMode == "GROUPED" then
            DF:UpdatePetGroupLayout()
        end
        return
    end

    -- Live mode: use real pet frames
    -- Initialize if needed
    DF:Debug("PET", "UpdateAllPetFrames: LIVE MODE - calling InitializePetFrames")
    DF:InitializePetFrames()

    DF:Debug("PET", "UpdateAllPetFrames: LIVE MODE - playerPet=%s partyPets=%d",
        tostring(DF.petFrames.player ~= nil),
        (DF.partyPetFrames[1] and 1 or 0) + (DF.partyPetFrames[2] and 1 or 0) + (DF.partyPetFrames[3] and 1 or 0) + (DF.partyPetFrames[4] and 1 or 0))

    -- Update player pet
    if DF.petFrames.player then
        DF:UpdatePetFrame(DF.petFrames.player)
        DF:PositionPetFrame(DF.petFrames.player)
    end

    -- Update party pets
    for i = 1, 4 do
        if DF.partyPetFrames[i] then
            DF:UpdatePetFrame(DF.partyPetFrames[i])
            DF:PositionPetFrame(DF.partyPetFrames[i])
        end
    end

    -- Update group layout if in grouped mode
    if db.petGroupMode == "GROUPED" then
        DF:UpdatePetGroupLayout()
    end
end

local lastRaidPetUpdateTime = 0

function DF:UpdateAllRaidPetFrames(force)
    -- Throttle: skip if already ran this frame (multiple callers during startup/updates)
    local now = GetTime()
    if not force and now == lastRaidPetUpdateTime then return end
    lastRaidPetUpdateTime = now

    local db = DF:GetRaidDB()

    -- Hide raid pet frames if in party test mode (not raid test mode)
    if DF.testMode and not DF.raidTestMode then
        for i = 1, 40 do
            if DF.raidPetFrames[i] then DF.raidPetFrames[i]:Hide() end
        end
        DF:HideAllTestRaidPetFrames()
        return
    end

    -- In test mode, show pets if enabled AND testShowPets is on; outside test mode, check petEnabled
    local shouldShowPets
    if DF.raidTestMode then
        shouldShowPets = db.petEnabled and (db.testShowPets ~= false)
    else
        shouldShowPets = db.petEnabled
    end

    if not shouldShowPets then
        if DF.raidTestMode then
            DF:HideAllTestRaidPetFrames()
        else
            for i = 1, 40 do
                if DF.raidPetFrames[i] then DF.raidPetFrames[i]:Hide() end
            end
            if DF.raidPetGroupContainer then DF.raidPetGroupContainer:Hide() end
        end
        return
    end

    -- Raid test mode: use test pet frames
    if DF.raidTestMode then
        DF:InitializeTestRaidPetFrames()

        local testFrameCount = db.raidTestFrameCount or 10

        for i = 1, 40 do
            if DF.testRaidPetFrames[i] then
                if i <= testFrameCount then
                    DF:UpdatePetFrame(DF.testRaidPetFrames[i])
                    DF:PositionPetFrame(DF.testRaidPetFrames[i])
                else
                    DF.testRaidPetFrames[i]:Hide()
                end
            end
        end

        if db.petGroupMode == "GROUPED" then
            DF:UpdateRaidPetGroupLayout()
        end
        return
    end

    -- Live mode: use real raid pet frames
    -- Initialize if needed (deferred creation)
    local frameIdx = 0
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            frameIdx = frameIdx + 1
            if frame and not DF.raidPetFrames[frameIdx] then
                DF.raidPetFrames[frameIdx] = DF:CreatePetFrame("raidpet" .. frameIdx, frame, true)
            end
        end)
    end

    -- Update all raid pets
    for i = 1, 40 do
        if DF.raidPetFrames[i] then
            DF:UpdatePetFrame(DF.raidPetFrames[i])
            DF:PositionPetFrame(DF.raidPetFrames[i])
        end
    end

    -- Update group layout if in grouped mode
    if db.petGroupMode == "GROUPED" then
        DF:UpdateRaidPetGroupLayout()
    end
end

function DF:UpdateAllPetFramePositions()
    -- Update party pet positions
    if DF.petFrames.player then
        DF:PositionPetFrame(DF.petFrames.player)
    end
    
    for i = 1, 4 do
        if DF.partyPetFrames[i] then
            DF:PositionPetFrame(DF.partyPetFrames[i])
        end
    end
    
    -- Update raid pet positions
    for i = 1, 40 do
        if DF.raidPetFrames[i] then
            DF:PositionPetFrame(DF.raidPetFrames[i])
        end
    end
end

-- ============================================================
-- PET EVENT HANDLING
-- ============================================================

function DF:OnPetChanged(unit)
    -- Determine which pet frame to update based on unit
    if unit == "player" or unit == "pet" then
        if DF.petFrames.player then
            DF:UpdatePetFrame(DF.petFrames.player)
        end
    elseif unit:match("^party%d$") then
        local index = tonumber(unit:match("party(%d)"))
        if index and DF.partyPetFrames[index] then
            DF:UpdatePetFrame(DF.partyPetFrames[index])
        end
    elseif unit:match("^partypet%d$") then
        local index = tonumber(unit:match("partypet(%d)"))
        if index and DF.partyPetFrames[index] then
            DF:UpdatePetFrame(DF.partyPetFrames[index])
        end
    elseif unit:match("^raid%d+$") then
        local index = tonumber(unit:match("raid(%d+)"))
        if index and DF.raidPetFrames[index] then
            DF:UpdatePetFrame(DF.raidPetFrames[index])
        end
    elseif unit:match("^raidpet%d+$") then
        local index = tonumber(unit:match("raidpet(%d+)"))
        if index and DF.raidPetFrames[index] then
            DF:UpdatePetFrame(DF.raidPetFrames[index])
        end
    end
end

-- Register for UNIT_PET event in main addon
-- This will be called from the main event handler
function DF:HandleUnitPetEvent(unit)
    local db = DF:GetDB()

    DF:Debug("PET", "HandleUnitPetEvent: unit=%s petEnabled=%s petFramesInitialized=%s", tostring(unit), tostring(db.petEnabled), tostring(DF.petFramesInitialized))

    -- Lazy-load pet frames on first pet event (if pets are enabled)
    -- InitializePetFrames sets the flag internally only when frames are created
    if db.petEnabled and not DF.petFramesInitialized then
        DF:Debug("PET", "HandleUnitPetEvent: lazy-loading pet frames")
        DF:InitializePetFrames()
    end

    DF:OnPetChanged(unit)
end

-- ============================================================
-- APPLY PET SETTINGS (called when settings change)
-- ============================================================

function DF:ApplyPetSettings()
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()

    DF:Debug("PET", "ApplyPetSettings called. testMode=%s raidTestMode=%s petEnabled=%s raidPetEnabled=%s",
        tostring(DF.testMode), tostring(DF.raidTestMode), tostring(db.petEnabled), tostring(raidDb.petEnabled))

    -- Update party/solo pet frames
    local partyPetsEnabled = DF.testMode and (db.petEnabled and db.testShowPets ~= false) or (not DF.testMode and db.petEnabled)
    if partyPetsEnabled then
        if DF.testMode then
            DF:InitializeTestPetFrames()
        else
            DF:InitializePetFrames()
        end
        DF:UpdateAllPetFrames(true)  -- force: explicit settings change
    else
        -- Hide all party pet frames (both live and test)
        if DF.petFrames.player then DF.petFrames.player:Hide() end
        for i = 1, 4 do
            if DF.partyPetFrames[i] then DF.partyPetFrames[i]:Hide() end
        end
        DF:HideAllTestPetFrames()
    end

    -- Update raid pet frames
    local raidPetsEnabled = DF.raidTestMode and (raidDb.petEnabled and raidDb.testShowPets ~= false) or (not DF.raidTestMode and raidDb.petEnabled)
    if raidPetsEnabled then
        if DF.raidTestMode then
            DF:InitializeTestRaidPetFrames()
        end
        DF:UpdateAllRaidPetFrames(true)  -- force: explicit settings change
    else
        for i = 1, 40 do
            if DF.raidPetFrames[i] then DF.raidPetFrames[i]:Hide() end
        end
        DF:HideAllTestRaidPetFrames()
    end
end
