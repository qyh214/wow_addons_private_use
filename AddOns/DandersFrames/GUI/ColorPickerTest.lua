-- DandersFrames Custom Color Picker Test
-- /dfcolortest to open

local addonName, DF = ...
local GUI = DF.GUI
local testFrame = nil

-- Theme colors (matching addon)
local C_BG = {r = 0.1, g = 0.1, b = 0.1}
local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
local C_ACCENT = {r = 0.45, g = 0.45, b = 0.95}
local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
local C_TEXT_DIM = {r = 0.5, g = 0.5, b = 0.5}

-- Class colors
local CLASS_COLORS = {
    {name = "Warrior", r = 0.78, g = 0.61, b = 0.43},
    {name = "Paladin", r = 0.96, g = 0.55, b = 0.73},
    {name = "Hunter", r = 0.67, g = 0.83, b = 0.45},
    {name = "Rogue", r = 1.00, g = 0.96, b = 0.41},
    {name = "Priest", r = 1.00, g = 1.00, b = 1.00},
    {name = "Death Knight", r = 0.77, g = 0.12, b = 0.23},
    {name = "Shaman", r = 0.00, g = 0.44, b = 0.87},
    {name = "Mage", r = 0.41, g = 0.80, b = 0.94},
    {name = "Warlock", r = 0.58, g = 0.51, b = 0.79},
    {name = "Monk", r = 0.00, g = 1.00, b = 0.59},
    {name = "Druid", r = 1.00, g = 0.49, b = 0.04},
    {name = "Demon Hunter", r = 0.64, g = 0.19, b = 0.79},
    {name = "Evoker", r = 0.20, g = 0.58, b = 0.50},
}

-- Saved preferences (would be in SavedVariables)
local savedColors = {}  -- Will be loaded from DB
local recentColors = {}
local preferSquarePicker = true  -- User preference: true = square, false = circle
local savedPosition = nil  -- Saved position (x, y) - persists until reload
local MAX_RECENT = 27  -- 3 rows of 9
local MAX_SAVED = 27   -- 3 rows of 9

-- Swatch layout constants
local SWATCH_SIZE = 30
local SWATCH_GAP = 2
local SWATCHES_PER_ROW = 9

-- Initialize saved colors from database
local function LoadSavedColors()
    if DandersFramesDB_v2 and DandersFramesDB_v2.colorPickerSaved then
        savedColors = DandersFramesDB_v2.colorPickerSaved
    end
    if DandersFramesDB_v2 and DandersFramesDB_v2.colorPickerRecent then
        recentColors = DandersFramesDB_v2.colorPickerRecent
    end
    if DandersFramesDB_v2 and DandersFramesDB_v2.colorPickerSquare ~= nil then
        preferSquarePicker = DandersFramesDB_v2.colorPickerSquare
    end
end

-- Save colors to database
local function SaveColorsToDb()
    if not DandersFramesDB_v2 then
        DandersFramesDB_v2 = {}
    end
    DandersFramesDB_v2.colorPickerSaved = savedColors
    DandersFramesDB_v2.colorPickerRecent = recentColors
    DandersFramesDB_v2.colorPickerSquare = preferSquarePicker
end

-- Load on addon load
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "DandersFrames" then
        LoadSavedColors()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Helper to create a unique color key
local function ColorKey(r, g, b, a)
    return string.format("%.2f,%.2f,%.2f,%.2f", r, g, b, a or 1)
end

-- ============================================================
-- HSV <-> RGB Conversion
-- ============================================================

local function HSVtoRGB(h, s, v)
    if s == 0 then return v, v, v end
    h = h / 60
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    i = i % 6
    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    else return v, p, q end
end

local function RGBtoHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    if max ~= 0 then s = d / max end
    if max ~= min then
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h * 60
    end
    return h, s, v
end

local function RGBtoHex(r, g, b, a)
    if a then
        return string.format("#%02X%02X%02X%02X", 
            math.floor(r * 255 + 0.5),
            math.floor(g * 255 + 0.5),
            math.floor(b * 255 + 0.5),
            math.floor(a * 255 + 0.5))
    else
        return string.format("#%02X%02X%02X", 
            math.floor(r * 255 + 0.5),
            math.floor(g * 255 + 0.5),
            math.floor(b * 255 + 0.5))
    end
end

local function HexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex == 8 then  -- RRGGBBAA
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        local a = tonumber(hex:sub(7, 8), 16) / 255
        return r or 1, g or 1, b or 1, a or 1
    elseif #hex == 6 then  -- RRGGBB
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        return r or 1, g or 1, b or 1, nil
    end
    return 1, 1, 1, nil
end

-- ============================================================
-- Color Picker Frame
-- ============================================================

local function CreateColorPickerTest(hasAlpha)
    if testFrame then
        testFrame.hasAlpha = hasAlpha
        testFrame:UpdateAlphaVisibility()
        if testFrame.RefreshSavedSwatches then
            testFrame.RefreshSavedSwatches()
        end
        testFrame:Show()
        return
    end
    
    hasAlpha = hasAlpha ~= false  -- Default to true for testing
    
    -- Current color state
    local currentHue = 0
    local currentSat = 1
    local currentVal = 1
    local currentAlpha = 1
    local activeTab = "saved"
    local useSquarePicker = preferSquarePicker
    local isUpdatingInputs = false  -- Prevent recursive updates
    
    -- Main frame
    testFrame = CreateFrame("Frame", "DFColorPickerTest", UIParent, "BackdropTemplate")
    testFrame:SetSize(320, 450)
    testFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    testFrame:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, 1)
    testFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    testFrame:SetMovable(true)
    testFrame:EnableMouse(true)
    testFrame:SetFrameStrata("FULLSCREEN_DIALOG")  -- High strata but below TOOLTIP so GameTooltip shows above
    testFrame:SetFrameLevel(500)
    testFrame:SetToplevel(true)
    testFrame.hasAlpha = hasAlpha
    
    -- Position using saved location, or center on GUI/screen if first open
    local function UpdatePosition()
        testFrame:ClearAllPoints()
        if savedPosition then
            -- Use saved position from previous open
            testFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", savedPosition.x, savedPosition.y)
        else
            -- First open this session - center on screen
            testFrame:SetPoint("CENTER")
        end
    end
    
    -- Save current position
    local function SavePosition()
        local left = testFrame:GetLeft()
        local bottom = testFrame:GetBottom()
        local width = testFrame:GetWidth()
        local height = testFrame:GetHeight()
        if left and bottom and width and height then
            savedPosition = {
                x = left + width / 2,
                y = bottom + height / 2
            }
        end
    end
    
    testFrame.UpdatePosition = UpdatePosition
    testFrame.SavePosition = SavePosition
    UpdatePosition()
    
    -- Make Escape key close the picker (and treat as cancel)
    tinsert(UISpecialFrames, "DFColorPickerTest")
    
    -- Track if we're closing via apply (vs cancel/escape)
    testFrame.appliedColor = false
    
    -- OnHide handler - treat as cancel if not applied
    testFrame:SetScript("OnHide", function(self)
        if not self.appliedColor then
            -- Closing via Escape or other means - treat as cancel
            if self.onCancelCallback then
                self.onCancelCallback()
            end
        end
        self.appliedColor = false
        self.skipOnChange = false
        self:ClearCallbacks()
    end)
    
    -- Header
    local header = CreateFrame("Frame", nil, testFrame)
    header:SetHeight(28)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() testFrame:StartMoving() end)
    header:SetScript("OnDragStop", function() 
        testFrame:StopMovingOrSizing()
        SavePosition()
    end)
    
    local title = header:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("LEFT", 10, 0)
    title:SetText("DandersFrames Color Picker")
    title:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
    
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -4, 0)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER")
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(0.6, 0.6, 0.6)
    closeBtn.icon = closeIcon
    closeBtn:SetScript("OnClick", function() 
        -- OnHide will treat this as cancel
        testFrame:Hide() 
    end)
    closeBtn:SetScript("OnEnter", function(self) self.icon:SetVertexColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function(self) self.icon:SetVertexColor(0.6, 0.6, 0.6) end)
    
    -- Pill toggle for Square/Circle mode
    local pillContainer = CreateFrame("Frame", nil, header, "BackdropTemplate")
    pillContainer:SetSize(110, 18)
    pillContainer:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    pillContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    pillContainer:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    pillContainer:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local squareBtn = CreateFrame("Button", nil, pillContainer, "BackdropTemplate")
    squareBtn:SetSize(54, 16)
    squareBtn:SetPoint("LEFT", 1, 0)
    squareBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    
    local squareBtnText = squareBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    squareBtnText:SetPoint("CENTER")
    squareBtnText:SetText("Square")
    
    local circleBtn = CreateFrame("Button", nil, pillContainer, "BackdropTemplate")
    circleBtn:SetSize(54, 16)
    circleBtn:SetPoint("RIGHT", -1, 0)
    circleBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    
    local circleBtnText = circleBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    circleBtnText:SetPoint("CENTER")
    circleBtnText:SetText("Circle")
    
    -- Content area
    local content = CreateFrame("Frame", nil, testFrame)
    content:SetPoint("TOPLEFT", 10, -38)
    content:SetPoint("BOTTOMRIGHT", -10, 45)
    
    local squareSize = 160
    local hueBarWidth = 20
    local alphaBarWidth = 20
    
    -- ============================================================
    -- Square Picker Container
    -- ============================================================
    
    local squareContainer = CreateFrame("Frame", nil, content)
    squareContainer:SetSize(290, 170)
    squareContainer:SetPoint("TOPLEFT", 0, 0)
    
    -- Color Square (Saturation/Value)
    local squareFrame = CreateFrame("Frame", nil, squareContainer, "BackdropTemplate")
    squareFrame:SetSize(squareSize, squareSize)
    squareFrame:SetPoint("TOPLEFT", 0, 0)
    squareFrame:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    squareFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local hueLayer = squareFrame:CreateTexture(nil, "BACKGROUND")
    hueLayer:SetAllPoints()
    hueLayer:SetColorTexture(1, 1, 1, 1)
    
    local blackLayer = squareFrame:CreateTexture(nil, "ARTWORK")
    blackLayer:SetAllPoints()
    blackLayer:SetColorTexture(1, 1, 1, 1)
    blackLayer:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 0))
    
    local picker = squareFrame:CreateTexture(nil, "OVERLAY")
    picker:SetSize(14, 14)
    picker:SetTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
    picker:SetTexCoord(0, 0.15625, 0, 0.625)
    
    -- Hue Bar
    local hueBar = CreateFrame("Frame", nil, squareContainer, "BackdropTemplate")
    hueBar:SetSize(hueBarWidth, squareSize)
    hueBar:SetPoint("LEFT", squareFrame, "RIGHT", 8, 0)
    hueBar:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    hueBar:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local hueColors = {{1,0,0}, {1,1,0}, {0,1,0}, {0,1,1}, {0,0,1}, {1,0,1}, {1,0,0}}
    local numSegments = 6
    local segmentHeight = squareSize / numSegments
    for i = 1, numSegments do
        local segment = hueBar:CreateTexture(nil, "BACKGROUND")
        segment:SetSize(hueBarWidth, segmentHeight)
        segment:SetPoint("TOPLEFT", 0, -((i-1) * segmentHeight))
        segment:SetColorTexture(1, 1, 1, 1)
        local c1, c2 = hueColors[i], hueColors[i + 1]
        segment:SetGradient("VERTICAL", CreateColor(c2[1], c2[2], c2[3], 1), CreateColor(c1[1], c1[2], c1[3], 1))
    end
    
    local hueIndicator = hueBar:CreateTexture(nil, "OVERLAY", nil, 2)
    hueIndicator:SetSize(hueBarWidth + 4, 6)
    hueIndicator:SetColorTexture(1, 1, 1, 1)
    
    local hueIndicatorBorder = hueBar:CreateTexture(nil, "OVERLAY", nil, 1)
    hueIndicatorBorder:SetSize(hueBarWidth + 6, 8)
    hueIndicatorBorder:SetColorTexture(0, 0, 0, 1)
    
    -- Alpha Bar
    local alphaBar = CreateFrame("Frame", nil, squareContainer, "BackdropTemplate")
    alphaBar:SetSize(alphaBarWidth, squareSize)
    alphaBar:SetPoint("LEFT", hueBar, "RIGHT", 8, 0)
    alphaBar:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    alphaBar:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    -- Checkerboard background for alpha (inset by 1 to match gradient)
    local checkerSize = 8
    local checkerWidth = alphaBarWidth - 2
    local checkerHeight = squareSize - 2
    for row = 0, math.ceil(checkerHeight / checkerSize) - 1 do
        for col = 0, math.ceil(checkerWidth / checkerSize) - 1 do
            local checker = alphaBar:CreateTexture(nil, "BACKGROUND")
            local w = math.min(checkerSize, checkerWidth - col * checkerSize)
            local h = math.min(checkerSize, checkerHeight - row * checkerSize)
            checker:SetSize(w, h)
            checker:SetPoint("TOPLEFT", 1 + col * checkerSize, -1 - row * checkerSize)
            local isLight = (row + col) % 2 == 0
            checker:SetColorTexture(isLight and 0.4 or 0.2, isLight and 0.4 or 0.2, isLight and 0.4 or 0.2, 1)
        end
    end
    
    local alphaGradient = alphaBar:CreateTexture(nil, "ARTWORK")
    alphaGradient:SetPoint("TOPLEFT", 1, -1)
    alphaGradient:SetPoint("BOTTOMRIGHT", -1, 1)
    alphaGradient:SetColorTexture(1, 1, 1, 1)
    
    local alphaIndicator = alphaBar:CreateTexture(nil, "OVERLAY", nil, 2)
    alphaIndicator:SetSize(alphaBarWidth + 4, 6)
    alphaIndicator:SetColorTexture(1, 1, 1, 1)
    
    local alphaIndicatorBorder = alphaBar:CreateTexture(nil, "OVERLAY", nil, 1)
    alphaIndicatorBorder:SetSize(alphaBarWidth + 6, 8)
    alphaIndicatorBorder:SetColorTexture(0, 0, 0, 1)
    
    -- ============================================================
    -- Circle Picker Container (Custom implementation for full edge access)
    -- ============================================================
    
    local circleContainer = CreateFrame("Frame", nil, content)
    circleContainer:SetSize(290, 170)
    circleContainer:SetPoint("TOPLEFT", 0, 0)
    circleContainer:Hide()
    
    -- Custom wheel frame (not using ColorSelect for better control)
    local wheelFrame = CreateFrame("Frame", nil, circleContainer)
    wheelFrame:SetSize(squareSize, squareSize)
    wheelFrame:SetPoint("TOPLEFT", 0, 0)
    
    local wheelTexture = wheelFrame:CreateTexture(nil, "ARTWORK")
    wheelTexture:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\DF_ColorWheel")
    wheelTexture:SetAllPoints()
    wheelTexture:SetTexelSnappingBias(0)
    wheelTexture:SetSnapToPixelGrid(false)
    
    -- Wheel thumb indicator
    -- Create wheel selector using custom ring texture
    local wheelThumbSize = 16
    local wheelThumb = CreateFrame("Frame", nil, wheelFrame)
    wheelThumb:SetSize(wheelThumbSize, wheelThumbSize)
    wheelThumb:SetFrameLevel(wheelFrame:GetFrameLevel() + 5)
    
    -- Ring texture
    local thumbRing = wheelThumb:CreateTexture(nil, "OVERLAY", nil, 2)
    thumbRing:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\DF_Ring")
    thumbRing:SetAllPoints()
    
    -- Custom Value bar for circle picker (no checkerboard - just gradient)
    local circleValueBar = CreateFrame("Frame", nil, circleContainer, "BackdropTemplate")
    circleValueBar:SetSize(hueBarWidth, squareSize)
    circleValueBar:SetPoint("TOPLEFT", squareSize + 8, 0)
    circleValueBar:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    circleValueBar:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local circleValueGradient = circleValueBar:CreateTexture(nil, "BACKGROUND")
    circleValueGradient:SetPoint("TOPLEFT", 1, -1)
    circleValueGradient:SetPoint("BOTTOMRIGHT", -1, 1)
    circleValueGradient:SetColorTexture(1, 1, 1, 1)
    
    local circleValueIndicator = circleValueBar:CreateTexture(nil, "OVERLAY", nil, 2)
    circleValueIndicator:SetSize(hueBarWidth + 4, 6)
    circleValueIndicator:SetColorTexture(1, 1, 1, 1)
    
    local circleValueIndicatorBorder = circleValueBar:CreateTexture(nil, "OVERLAY", nil, 1)
    circleValueIndicatorBorder:SetSize(hueBarWidth + 6, 8)
    circleValueIndicatorBorder:SetColorTexture(0, 0, 0, 1)
    
    -- Alpha bar for circle picker
    local circleAlphaBar = CreateFrame("Frame", nil, circleContainer, "BackdropTemplate")
    circleAlphaBar:SetSize(alphaBarWidth, squareSize)
    circleAlphaBar:SetPoint("LEFT", circleValueBar, "RIGHT", 8, 0)
    circleAlphaBar:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    circleAlphaBar:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    -- Checkerboard for circle alpha (inset by 1 to match gradient)
    for row = 0, math.ceil(checkerHeight / checkerSize) - 1 do
        for col = 0, math.ceil(checkerWidth / checkerSize) - 1 do
            local checker = circleAlphaBar:CreateTexture(nil, "BACKGROUND")
            local w = math.min(checkerSize, checkerWidth - col * checkerSize)
            local h = math.min(checkerSize, checkerHeight - row * checkerSize)
            checker:SetSize(w, h)
            checker:SetPoint("TOPLEFT", 1 + col * checkerSize, -1 - row * checkerSize)
            local isLight = (row + col) % 2 == 0
            checker:SetColorTexture(isLight and 0.4 or 0.2, isLight and 0.4 or 0.2, isLight and 0.4 or 0.2, 1)
        end
    end
    
    local circleAlphaGradient = circleAlphaBar:CreateTexture(nil, "ARTWORK")
    circleAlphaGradient:SetPoint("TOPLEFT", 1, -1)
    circleAlphaGradient:SetPoint("BOTTOMRIGHT", -1, 1)
    circleAlphaGradient:SetColorTexture(1, 1, 1, 1)
    
    local circleAlphaIndicator = circleAlphaBar:CreateTexture(nil, "OVERLAY", nil, 2)
    circleAlphaIndicator:SetSize(alphaBarWidth + 4, 6)
    circleAlphaIndicator:SetColorTexture(1, 1, 1, 1)
    
    local circleAlphaIndicatorBorder = circleAlphaBar:CreateTexture(nil, "OVERLAY", nil, 1)
    circleAlphaIndicatorBorder:SetSize(alphaBarWidth + 6, 8)
    circleAlphaIndicatorBorder:SetColorTexture(0, 0, 0, 1)
    
    -- ============================================================
    -- Preview Swatch
    -- ============================================================
    
    local previewFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    previewFrame:SetSize(55, 55)
    previewFrame:SetPoint("TOPLEFT", squareContainer, "TOPRIGHT", -50, 0)
    previewFrame:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    previewFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    -- Checkerboard behind preview for alpha (inset by 1 for border)
    local previewInner = 53  -- 55 - 2 for border
    for row = 0, math.ceil(previewInner / 8) - 1 do
        for col = 0, math.ceil(previewInner / 8) - 1 do
            local checker = previewFrame:CreateTexture(nil, "BACKGROUND")
            local w = math.min(8, previewInner - col * 8)
            local h = math.min(8, previewInner - row * 8)
            checker:SetSize(w, h)
            checker:SetPoint("TOPLEFT", 1 + col * 8, -1 - row * 8)
            local isLight = (row + col) % 2 == 0
            checker:SetColorTexture(isLight and 0.4 or 0.2, isLight and 0.4 or 0.2, isLight and 0.4 or 0.2, 1)
        end
    end
    
    local previewTexture = previewFrame:CreateTexture(nil, "ARTWORK")
    previewTexture:SetPoint("TOPLEFT", 1, -1)
    previewTexture:SetPoint("BOTTOMRIGHT", -1, 1)
    
    -- ============================================================
    -- RGBA Editable Inputs
    -- ============================================================
    
    local inputFrame = CreateFrame("Frame", nil, content)
    inputFrame:SetSize(290, 24)
    inputFrame:SetPoint("TOPLEFT", squareContainer, "BOTTOMLEFT", 0, -8)
    
    local function CreateRGBAInput(parent, label, color, xOffset, width)
        local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        container:SetSize(width, 22)
        container:SetPoint("LEFT", xOffset, 0)
        container:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
        container:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        
        local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        lbl:SetPoint("LEFT", 4, 0)
        lbl:SetText(label)
        lbl:SetTextColor(color.r, color.g, color.b)
        
        local editBox = CreateFrame("EditBox", nil, container)
        editBox:SetSize(width - 22, 18)
        editBox:SetPoint("LEFT", lbl, "RIGHT", 2, 0)
        editBox:SetFontObject("DFFontNormalSmall")
        editBox:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        editBox:SetAutoFocus(false)
        editBox:SetNumeric(true)
        editBox:SetMaxLetters(3)
        editBox:SetJustifyH("LEFT")
        
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        
        return editBox
    end
    
    local rInput = CreateRGBAInput(inputFrame, "R", {r=1, g=0.4, b=0.4}, 0, 60)
    local gInput = CreateRGBAInput(inputFrame, "G", {r=0.4, g=1, b=0.4}, 64, 60)
    local bInput = CreateRGBAInput(inputFrame, "B", {r=0.4, g=0.6, b=1}, 128, 60)
    local aInput = CreateRGBAInput(inputFrame, "A%", {r=0.8, g=0.8, b=0.8}, 192, 60)
    aInput:GetParent().alphaInput = true
    
    -- Hex input
    local hexFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    hexFrame:SetSize(118, 22)  -- Wider to accommodate copy button
    hexFrame:SetPoint("TOPLEFT", inputFrame, "BOTTOMLEFT", 0, -4)
    hexFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    hexFrame:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    
    local hexLabel = hexFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    hexLabel:SetPoint("LEFT", 4, 0)
    hexLabel:SetText("Hex")
    hexLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local hexInput = CreateFrame("EditBox", nil, hexFrame)
    hexInput:SetSize(70, 18)
    hexInput:SetPoint("LEFT", hexLabel, "RIGHT", 4, 0)
    hexInput:SetFontObject("DFFontNormalSmall")
    hexInput:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    hexInput:SetAutoFocus(false)
    hexInput:SetMaxLetters(9)  -- #RRGGBBAA
    hexInput:SetJustifyH("LEFT")
    hexInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    -- Copy button
    local copyBtn = CreateFrame("Button", nil, hexFrame, "BackdropTemplate")
    copyBtn:SetSize(18, 18)
    copyBtn:SetPoint("LEFT", hexInput, "RIGHT", 2, 0)
    copyBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    copyBtn:SetBackdropColor(C_ELEMENT.r * 0.8, C_ELEMENT.g * 0.8, C_ELEMENT.b * 0.8, 1)
    copyBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local copyIcon = copyBtn:CreateTexture(nil, "OVERLAY")
    copyIcon:SetPoint("CENTER", 0, 0)
    copyIcon:SetSize(12, 12)
    copyIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\content_copy")
    copyIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Create a copy popup that appears within the color picker
    local copyPopup = CreateFrame("Frame", nil, testFrame, "BackdropTemplate")
    copyPopup:SetSize(180, 70)
    copyPopup:SetPoint("CENTER", testFrame, "CENTER", 0, 0)
    copyPopup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    copyPopup:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, 1)
    copyPopup:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
    copyPopup:SetFrameLevel(testFrame:GetFrameLevel() + 10)
    copyPopup:Hide()
    
    local copyPopupLabel = copyPopup:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    copyPopupLabel:SetPoint("TOP", 0, -8)
    copyPopupLabel:SetText("Press Ctrl+C to copy:")
    copyPopupLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    local copyPopupEdit = CreateFrame("EditBox", nil, copyPopup, "BackdropTemplate")
    copyPopupEdit:SetSize(160, 22)
    copyPopupEdit:SetPoint("TOP", copyPopupLabel, "BOTTOM", 0, -6)
    copyPopupEdit:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    copyPopupEdit:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    copyPopupEdit:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    copyPopupEdit:SetFontObject("DFFontNormalSmall")
    copyPopupEdit:SetTextColor(1, 1, 1)
    copyPopupEdit:SetAutoFocus(false)
    copyPopupEdit:SetJustifyH("CENTER")
    copyPopupEdit:SetScript("OnEscapePressed", function() copyPopup:Hide() end)
    copyPopupEdit:SetScript("OnEnterPressed", function() copyPopup:Hide() end)
    
    local copyPopupClose = CreateFrame("Button", nil, copyPopup, "BackdropTemplate")
    copyPopupClose:SetSize(50, 18)
    copyPopupClose:SetPoint("BOTTOM", 0, 6)
    copyPopupClose:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    copyPopupClose:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    copyPopupClose:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local copyPopupCloseText = copyPopupClose:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    copyPopupCloseText:SetPoint("CENTER")
    copyPopupCloseText:SetText("Close")
    copyPopupCloseText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    copyPopupClose:SetScript("OnClick", function() copyPopup:Hide() end)
    copyPopupClose:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1) end)
    copyPopupClose:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1) end)
    
    copyBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
        copyIcon:SetVertexColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Copy hex to clipboard")
        GameTooltip:Show()
    end)
    copyBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        copyIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        GameTooltip:Hide()
    end)
    copyBtn:SetScript("OnClick", function()
        local hex = hexInput:GetText()
        if hex and hex ~= "" then
            copyPopupEdit:SetText(hex)
            copyPopup:Show()
            copyPopupEdit:SetFocus()
            copyPopupEdit:HighlightText()
        end
    end)
    
    -- ============================================================
    -- Update Functions
    -- ============================================================
    
    local function UpdateHueGradient()
        local r, g, b = HSVtoRGB(currentHue, 1, 1)
        hueLayer:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(r, g, b, 1))
    end
    
    local function UpdateAlphaGradient()
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        alphaGradient:SetGradient("VERTICAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 1))
        circleAlphaGradient:SetGradient("VERTICAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 1))
    end
    
    local function UpdatePickerPosition()
        local x = currentSat * squareSize
        local y = currentVal * squareSize
        picker:ClearAllPoints()
        picker:SetPoint("CENTER", squareFrame, "BOTTOMLEFT", x, y)
    end
    
    local function UpdateHueIndicator()
        local y = (currentHue / 360) * squareSize
        hueIndicator:ClearAllPoints()
        hueIndicator:SetPoint("CENTER", hueBar, "TOP", 0, -y)
        hueIndicatorBorder:ClearAllPoints()
        hueIndicatorBorder:SetPoint("CENTER", hueIndicator)
    end
    
    local function UpdateAlphaIndicator()
        local y = (1 - currentAlpha) * squareSize
        alphaIndicator:ClearAllPoints()
        alphaIndicator:SetPoint("CENTER", alphaBar, "TOP", 0, -y)
        alphaIndicatorBorder:ClearAllPoints()
        alphaIndicatorBorder:SetPoint("CENTER", alphaIndicator)
        
        circleAlphaIndicator:ClearAllPoints()
        circleAlphaIndicator:SetPoint("CENTER", circleAlphaBar, "TOP", 0, -y)
        circleAlphaIndicatorBorder:ClearAllPoints()
        circleAlphaIndicatorBorder:SetPoint("CENTER", circleAlphaIndicator)
    end
    
    local function UpdateCircleValueGradient()
        -- Create gradient from current hue/sat color to black
        local r, g, b = HSVtoRGB(currentHue, currentSat, 1)
        circleValueGradient:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(r, g, b, 1))
    end
    
    local function UpdateCircleValueIndicator()
        local y = (1 - currentVal) * squareSize
        circleValueIndicator:ClearAllPoints()
        circleValueIndicator:SetPoint("CENTER", circleValueBar, "TOP", 0, -y)
        circleValueIndicatorBorder:ClearAllPoints()
        circleValueIndicatorBorder:SetPoint("CENTER", circleValueIndicator)
    end
    
    local function UpdateWheelThumbPosition()
        -- Convert hue/sat to x,y position on wheel
        local radius = squareSize / 2
        local angle = (currentHue / 360) * 2 * math.pi - math.pi  -- -pi to pi
        local dist = currentSat * radius
        local x = radius + math.cos(angle) * dist
        local y = radius + math.sin(angle) * dist  -- Matches texture: y - center convention
        wheelThumb:ClearAllPoints()
        wheelThumb:SetPoint("CENTER", wheelFrame, "TOPLEFT", x, -y)
    end
    
    local function UpdateInputs()
        if isUpdatingInputs then return end
        isUpdatingInputs = true
        
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        rInput:SetText(math.floor(r * 255 + 0.5))
        gInput:SetText(math.floor(g * 255 + 0.5))
        bInput:SetText(math.floor(b * 255 + 0.5))
        aInput:SetText(math.floor(currentAlpha * 100 + 0.5))
        
        if testFrame.hasAlpha then
            hexInput:SetText(RGBtoHex(r, g, b, currentAlpha))
        else
            hexInput:SetText(RGBtoHex(r, g, b))
        end
        
        isUpdatingInputs = false
    end
    
    local function UpdateAllColors()
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        previewTexture:SetColorTexture(r, g, b, currentAlpha)
        
        UpdateHueGradient()
        UpdateAlphaGradient()
        UpdatePickerPosition()
        UpdateHueIndicator()
        UpdateAlphaIndicator()
        UpdateCircleValueGradient()
        UpdateCircleValueIndicator()
        UpdateWheelThumbPosition()
        UpdateInputs()
        
        -- Call live preview callback if set (but not during initialization)
        if testFrame.onChangeCallback and not testFrame.skipOnChange then
            testFrame.onChangeCallback({
                r = r,
                g = g,
                b = b,
                a = testFrame.hasAlpha and currentAlpha or 1
            })
        end
    end
    
    -- Initialize gradient
    UpdateHueGradient()
    
    -- ============================================================
    -- Input Handlers
    -- ============================================================
    
    local function OnRGBAInputChanged()
        if isUpdatingInputs then return end
        
        local r = (tonumber(rInput:GetText()) or 0) / 255
        local g = (tonumber(gInput:GetText()) or 0) / 255
        local b = (tonumber(bInput:GetText()) or 0) / 255
        local a = (tonumber(aInput:GetText()) or 100) / 100
        
        r = math.max(0, math.min(1, r))
        g = math.max(0, math.min(1, g))
        b = math.max(0, math.min(1, b))
        a = math.max(0, math.min(1, a))
        
        currentHue, currentSat, currentVal = RGBtoHSV(r, g, b)
        currentAlpha = a
        UpdateAllColors()
    end
    
    rInput:SetScript("OnEnterPressed", function(self) OnRGBAInputChanged(); self:ClearFocus() end)
    gInput:SetScript("OnEnterPressed", function(self) OnRGBAInputChanged(); self:ClearFocus() end)
    bInput:SetScript("OnEnterPressed", function(self) OnRGBAInputChanged(); self:ClearFocus() end)
    aInput:SetScript("OnEnterPressed", function(self) OnRGBAInputChanged(); self:ClearFocus() end)
    
    -- Live update as user types
    rInput:SetScript("OnTextChanged", function(self, userInput) if userInput then OnRGBAInputChanged() end end)
    gInput:SetScript("OnTextChanged", function(self, userInput) if userInput then OnRGBAInputChanged() end end)
    bInput:SetScript("OnTextChanged", function(self, userInput) if userInput then OnRGBAInputChanged() end end)
    aInput:SetScript("OnTextChanged", function(self, userInput) if userInput then OnRGBAInputChanged() end end)
    
    hexInput:SetScript("OnEnterPressed", function(self)
        if isUpdatingInputs then return end
        local hex = self:GetText()
        local r, g, b, a = HexToRGB(hex)
        currentHue, currentSat, currentVal = RGBtoHSV(r, g, b)
        if a and testFrame.hasAlpha then
            currentAlpha = a
        end
        UpdateAllColors()
        self:ClearFocus()
    end)
    
    -- Live update hex as user types
    hexInput:SetScript("OnTextChanged", function(self, userInput)
        if not userInput or isUpdatingInputs then return end
        local hex = self:GetText()
        -- Only update if it looks like a valid hex (starts with # and has enough chars)
        if hex:match("^#%x%x%x%x%x%x") then
            local r, g, b, a = HexToRGB(hex)
            if r and g and b then
                currentHue, currentSat, currentVal = RGBtoHSV(r, g, b)
                if a and testFrame.hasAlpha then
                    currentAlpha = a
                end
                UpdateAllColors()
            end
        end
    end)
    
    -- ============================================================
    -- Mouse Handlers
    -- ============================================================
    
    local isDraggingSquare, isDraggingHue, isDraggingAlpha, isDraggingCircleValue = false, false, false, false
    
    squareFrame:EnableMouse(true)
    squareFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDraggingSquare = true
            local scale = self:GetEffectiveScale()
            local cursorX, cursorY = GetCursorPosition()
            cursorX, cursorY = cursorX / scale, cursorY / scale
            currentSat = math.max(0, math.min(1, (cursorX - self:GetLeft()) / squareSize))
            currentVal = math.max(0, math.min(1, (cursorY - self:GetBottom()) / squareSize))
            UpdateAllColors()
        end
    end)
    squareFrame:SetScript("OnMouseUp", function() isDraggingSquare = false end)
    squareFrame:SetScript("OnUpdate", function(self)
        if isDraggingSquare then
            local scale = self:GetEffectiveScale()
            local cursorX, cursorY = GetCursorPosition()
            cursorX, cursorY = cursorX / scale, cursorY / scale
            currentSat = math.max(0, math.min(1, (cursorX - self:GetLeft()) / squareSize))
            currentVal = math.max(0, math.min(1, (cursorY - self:GetBottom()) / squareSize))
            UpdateAllColors()
        end
    end)
    
    hueBar:EnableMouse(true)
    hueBar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDraggingHue = true
            local scale = self:GetEffectiveScale()
            local _, cursorY = GetCursorPosition()
            cursorY = cursorY / scale
            currentHue = math.max(0, math.min(360, ((self:GetTop() - cursorY) / squareSize) * 360))
            UpdateAllColors()
        end
    end)
    hueBar:SetScript("OnMouseUp", function() isDraggingHue = false end)
    hueBar:SetScript("OnUpdate", function(self)
        if isDraggingHue then
            local scale = self:GetEffectiveScale()
            local _, cursorY = GetCursorPosition()
            cursorY = cursorY / scale
            currentHue = math.max(0, math.min(360, ((self:GetTop() - cursorY) / squareSize) * 360))
            UpdateAllColors()
        end
    end)
    
    -- Alpha bar handlers (for both square and circle mode)
    local function SetupAlphaBarHandlers(bar)
        bar:EnableMouse(true)
        bar:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                isDraggingAlpha = true
                local scale = self:GetEffectiveScale()
                local _, cursorY = GetCursorPosition()
                cursorY = cursorY / scale
                currentAlpha = math.max(0, math.min(1, 1 - ((self:GetTop() - cursorY) / squareSize)))
                UpdateAllColors()
            end
        end)
        bar:SetScript("OnMouseUp", function() isDraggingAlpha = false end)
        bar:SetScript("OnUpdate", function(self)
            if isDraggingAlpha then
                local scale = self:GetEffectiveScale()
                local _, cursorY = GetCursorPosition()
                cursorY = cursorY / scale
                currentAlpha = math.max(0, math.min(1, 1 - ((self:GetTop() - cursorY) / squareSize)))
                UpdateAllColors()
            end
        end)
    end
    
    SetupAlphaBarHandlers(alphaBar)
    SetupAlphaBarHandlers(circleAlphaBar)
    
    -- Circle value bar handlers
    circleValueBar:EnableMouse(true)
    circleValueBar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDraggingCircleValue = true
            local scale = self:GetEffectiveScale()
            local _, cursorY = GetCursorPosition()
            cursorY = cursorY / scale
            currentVal = math.max(0, math.min(1, 1 - ((self:GetTop() - cursorY) / squareSize)))
            UpdateAllColors()
        end
    end)
    circleValueBar:SetScript("OnMouseUp", function() isDraggingCircleValue = false end)
    circleValueBar:SetScript("OnUpdate", function(self)
        if isDraggingCircleValue then
            local scale = self:GetEffectiveScale()
            local _, cursorY = GetCursorPosition()
            cursorY = cursorY / scale
            currentVal = math.max(0, math.min(1, 1 - ((self:GetTop() - cursorY) / squareSize)))
            UpdateAllColors()
        end
    end)
    
    -- Custom wheel handler (updates hue and saturation)
    local isDraggingWheel = false
    local wheelRadius = squareSize / 2
    
    local function UpdateWheelFromCursor(frame)
        local scale = frame:GetEffectiveScale()
        local cursorX, cursorY = GetCursorPosition()
        cursorX, cursorY = cursorX / scale, cursorY / scale
        
        local centerX = frame:GetLeft() + wheelRadius
        local centerY = frame:GetTop() - wheelRadius
        
        local dx = cursorX - centerX
        local dy = centerY - cursorY  -- Inverted: WoW Y is up, texture Y is down
        local dist = math.sqrt(dx*dx + dy*dy)
        
        -- Clamp to wheel radius
        if dist > wheelRadius then
            dx = dx * wheelRadius / dist
            dy = dy * wheelRadius / dist
            dist = wheelRadius
        end
        
        -- Calculate hue from angle
        local angle = math.atan2(dy, dx)
        currentHue = ((angle + math.pi) / (2 * math.pi)) * 360
        
        -- Calculate saturation from distance
        currentSat = dist / wheelRadius
        
        UpdateAllColors()
    end
    
    wheelFrame:EnableMouse(true)
    wheelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDraggingWheel = true
            UpdateWheelFromCursor(self)
        end
    end)
    wheelFrame:SetScript("OnMouseUp", function() isDraggingWheel = false end)
    wheelFrame:SetScript("OnUpdate", function(self)
        if isDraggingWheel then
            UpdateWheelFromCursor(self)
        end
    end)
    
    -- ============================================================
    -- Mode Toggle
    -- ============================================================
    
    local function UpdatePickerMode()
        if useSquarePicker then
            squareContainer:Show()
            circleContainer:Hide()
            -- Highlight square button
            squareBtn:SetBackdropColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
            squareBtnText:SetTextColor(1, 1, 1)
            circleBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0)
            circleBtnText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        else
            squareContainer:Hide()
            circleContainer:Show()
            -- Highlight circle button
            circleBtn:SetBackdropColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
            circleBtnText:SetTextColor(1, 1, 1)
            squareBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0)
            squareBtnText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            -- Update wheel thumb position
            UpdateWheelThumbPosition()
        end
    end
    
    squareBtn:SetScript("OnClick", function()
        if not useSquarePicker then
            useSquarePicker = true
            preferSquarePicker = true
            SaveColorsToDb()
            UpdatePickerMode()
            UpdateAllColors()
        end
    end)
    
    circleBtn:SetScript("OnClick", function()
        if useSquarePicker then
            useSquarePicker = false
            preferSquarePicker = false
            SaveColorsToDb()
            UpdatePickerMode()
            UpdateAllColors()
        end
    end)
    
    -- Hover effects
    squareBtn:SetScript("OnEnter", function(self)
        if not useSquarePicker then
            self:SetBackdropColor(C_ELEMENT.r + 0.1, C_ELEMENT.g + 0.1, C_ELEMENT.b + 0.1, 1)
        end
    end)
    squareBtn:SetScript("OnLeave", function(self)
        if not useSquarePicker then
            self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0)
        end
    end)
    circleBtn:SetScript("OnEnter", function(self)
        if useSquarePicker then
            self:SetBackdropColor(C_ELEMENT.r + 0.1, C_ELEMENT.g + 0.1, C_ELEMENT.b + 0.1, 1)
        end
    end)
    circleBtn:SetScript("OnLeave", function(self)
        if useSquarePicker then
            self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0)
        end
    end)
    
    -- ============================================================
    -- Alpha Visibility
    -- ============================================================
    
    function testFrame:UpdateAlphaVisibility()
        local showAlpha = self.hasAlpha
        alphaBar:SetShown(showAlpha)
        circleAlphaBar:SetShown(showAlpha)
        aInput:GetParent():SetShown(showAlpha)
        
        -- Adjust preview position based on alpha visibility
        if showAlpha then
            previewFrame:SetPoint("TOPLEFT", squareContainer, "TOPRIGHT", -50, 0)
        else
            previewFrame:SetPoint("TOPLEFT", squareContainer, "TOPRIGHT", -78, 0)
        end
    end
    
    -- ============================================================
    -- Tabs
    -- ============================================================
    
    local tabFrame = CreateFrame("Frame", nil, content)
    tabFrame:SetSize(300, 22)
    tabFrame:SetPoint("TOPLEFT", hexFrame, "BOTTOMLEFT", 0, -8)
    
    local tabButtons = {}
    local tabContent = CreateFrame("Frame", nil, content)
    tabContent:SetSize(300, 96)  -- 3 rows of 30px swatches + 2px gaps
    tabContent:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT", 0, -4)
    
    local function CreateTab(name, label, xOffset)
        local btn = CreateFrame("Button", nil, tabFrame)
        btn:SetSize(55, 20)
        btn:SetPoint("LEFT", xOffset, 0)
        
        local text = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        text:SetPoint("CENTER")
        text:SetText(label)
        btn.text = text
        
        local underline = btn:CreateTexture(nil, "OVERLAY")
        underline:SetHeight(2)
        underline:SetPoint("BOTTOMLEFT", 0, 0)
        underline:SetPoint("BOTTOMRIGHT", 0, 0)
        underline:SetColorTexture(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
        underline:Hide()
        btn.underline = underline
        
        btn.name = name
        tabButtons[name] = btn
        return btn
    end
    
    CreateTab("saved", "Saved", 0)
    CreateTab("recent", "Recent", 60)
    CreateTab("class", "Class", 120)
    
    -- Save button in tab row (right-aligned)
    local saveBtn = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
    saveBtn:SetSize(50, 18)
    saveBtn:SetPoint("RIGHT", 0, 0)
    saveBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    saveBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    saveBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local saveBtnText = saveBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    saveBtnText:SetPoint("CENTER")
    saveBtnText:SetText("Save")
    saveBtnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    saveBtn:SetScript("OnEnter", function(self) 
        self:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1) 
    end)
    saveBtn:SetScript("OnLeave", function(self) 
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1) 
    end)
    
    local classContent = CreateFrame("Frame", nil, tabContent)
    classContent:SetAllPoints()
    classContent:Hide()
    
    local savedContent = CreateFrame("Frame", nil, tabContent)
    savedContent:SetAllPoints()
    
    local recentContent = CreateFrame("Frame", nil, tabContent)
    recentContent:SetAllPoints()
    recentContent:Hide()
    
    -- Helper to show tooltip above the color picker
    local function ShowTooltip(owner, anchor)
        GameTooltip:SetOwner(owner, anchor or "ANCHOR_RIGHT")
    end
    
    local function HideTooltip()
        GameTooltip:Hide()
    end
    
    -- Helper to finalize tooltip display
    local function FinalizeTooltip()
        GameTooltip:Show()
        -- GameTooltip is TOOLTIP strata, which is above our FULLSCREEN_DIALOG strata
    end
    
    local function SelectColor(r, g, b)
        currentHue, currentSat, currentVal = RGBtoHSV(r, g, b)
        UpdateAllColors()
    end
    
    local function CreateColorSwatch(parent, index, r, g, b, tooltip)
        local row = math.floor((index - 1) / SWATCHES_PER_ROW)
        local col = (index - 1) % SWATCHES_PER_ROW
        
        local swatch = CreateFrame("Button", nil, parent, "BackdropTemplate")
        swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
        swatch:SetPoint("TOPLEFT", col * (SWATCH_SIZE + SWATCH_GAP), -row * (SWATCH_SIZE + SWATCH_GAP))
        swatch:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        swatch:SetBackdropColor(r, g, b, 1)
        swatch:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        
        swatch:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(1, 1, 1, 1)
            if tooltip then
                ShowTooltip(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltip)
                FinalizeTooltip()
            end
        end)
        swatch:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
            HideTooltip()
        end)
        swatch:SetScript("OnClick", function() SelectColor(r, g, b) end)
        
        return swatch
    end
    
    for i, class in ipairs(CLASS_COLORS) do
        CreateColorSwatch(classContent, i, class.r, class.g, class.b, class.name)
    end
    
    -- ============================================================
    -- Saved Colors Tab
    -- ============================================================
    
    local savedSwatches = {}
    local savedEmptyText = savedContent:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    savedEmptyText:SetPoint("CENTER", 0, 0)
    savedEmptyText:SetText("No saved colors yet\nClick 'Save' to add current color")
    savedEmptyText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    savedEmptyText:SetJustifyH("CENTER")
    
    local function RefreshSavedSwatches()
        -- Clear existing swatches
        for _, swatch in ipairs(savedSwatches) do
            swatch:Hide()
            swatch:SetParent(nil)
        end
        wipe(savedSwatches)
        
        -- Show/hide empty text
        savedEmptyText:SetShown(#savedColors == 0)
        
        -- Create swatches for saved colors
        for i, color in ipairs(savedColors) do
            local row = math.floor((i - 1) / SWATCHES_PER_ROW)
            local col = (i - 1) % SWATCHES_PER_ROW
            
            local swatch = CreateFrame("Button", nil, savedContent, "BackdropTemplate")
            swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
            swatch:SetPoint("TOPLEFT", col * (SWATCH_SIZE + SWATCH_GAP), -row * (SWATCH_SIZE + SWATCH_GAP))
            swatch:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            swatch:SetBackdropColor(color.r, color.g, color.b, 1)
            swatch:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
            swatch.colorIndex = i
            
            swatch:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(1, 1, 1, 1)
                ShowTooltip(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Left-click to select")
                GameTooltip:AddLine("Right-click to delete", 0.7, 0.7, 0.7)
                FinalizeTooltip()
            end)
            swatch:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
                HideTooltip()
            end)
            swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            swatch:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    SelectColor(color.r, color.g, color.b)
                    -- Only apply alpha if picker has alpha, otherwise force to 1
                    if testFrame.hasAlpha and color.a then
                        currentAlpha = color.a
                    else
                        currentAlpha = 1
                    end
                    UpdateAllColors()
                elseif button == "RightButton" then
                    -- Get hex code before removing
                    local deletedColor = savedColors[self.colorIndex]
                    local hexCode = RGBtoHex(deletedColor.r, deletedColor.g, deletedColor.b, deletedColor.a)
                    
                    table.remove(savedColors, self.colorIndex)
                    SaveColorsToDb()
                    RefreshSavedSwatches()
                    
                    -- Print confirmation with hex code
                    print("|cff7373f2DandersFrames:|r Color deleted: |cffffffff" .. hexCode .. "|r")
                end
            end)
            
            table.insert(savedSwatches, swatch)
        end
    end
    
    -- Store on frame for reuse when reopening
    testFrame.RefreshSavedSwatches = RefreshSavedSwatches
    
    saveBtn:SetScript("OnClick", function()
        if #savedColors >= MAX_SAVED then
            print("|cff7373f2DandersFrames:|r Maximum saved colors reached (" .. MAX_SAVED .. ")")
            return
        end
        
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        local a = testFrame.hasAlpha and currentAlpha or nil
        local key = ColorKey(r, g, b, a or 1)
        
        -- Check if color already exists (compare without alpha for RGB-only pickers)
        for _, color in ipairs(savedColors) do
            if ColorKey(color.r, color.g, color.b, color.a or 1) == key then
                print("|cff7373f2DandersFrames:|r Color already saved")
                return
            end
        end
        
        table.insert(savedColors, 1, {r = r, g = g, b = b, a = a})
        SaveColorsToDb()
        RefreshSavedSwatches()
        
        -- Switch to saved tab
        testFrame.SetActiveTab("saved")
        
        -- Print confirmation with hex code
        local hexCode = RGBtoHex(r, g, b, a)
        print("|cff7373f2DandersFrames:|r Color saved: |cffffffff" .. hexCode .. "|r")
    end)
    
    -- ============================================================
    -- Recent Colors Tab  
    -- ============================================================
    
    local recentSwatches = {}
    local recentEmptyText = recentContent:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    recentEmptyText:SetPoint("CENTER", 0, 0)
    recentEmptyText:SetText("No recent colors yet\nColors appear here when you apply them")
    recentEmptyText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    recentEmptyText:SetJustifyH("CENTER")
    
    local function RefreshRecentSwatches()
        -- Clear existing swatches
        for _, swatch in ipairs(recentSwatches) do
            swatch:Hide()
            swatch:SetParent(nil)
        end
        wipe(recentSwatches)
        
        -- Show/hide empty text
        recentEmptyText:SetShown(#recentColors == 0)
        
        -- Create swatches for recent colors
        for i, color in ipairs(recentColors) do
            local row = math.floor((i - 1) / SWATCHES_PER_ROW)
            local col = (i - 1) % SWATCHES_PER_ROW
            
            local swatch = CreateFrame("Button", nil, recentContent, "BackdropTemplate")
            swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
            swatch:SetPoint("TOPLEFT", col * (SWATCH_SIZE + SWATCH_GAP), -row * (SWATCH_SIZE + SWATCH_GAP))
            swatch:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            swatch:SetBackdropColor(color.r, color.g, color.b, 1)
            swatch:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
            swatch.colorData = color
            
            swatch:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(1, 1, 1, 1)
                ShowTooltip(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine("Left-click to select")
                GameTooltip:AddLine("Right-click to save", 0.7, 0.7, 0.7)
                FinalizeTooltip()
            end)
            swatch:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
                HideTooltip()
            end)
            swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            swatch:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    SelectColor(color.r, color.g, color.b)
                    -- Only apply alpha if picker has alpha, otherwise force to 1
                    if testFrame.hasAlpha and color.a then
                        currentAlpha = color.a
                    else
                        currentAlpha = 1
                    end
                    UpdateAllColors()
                elseif button == "RightButton" then
                    -- Save to saved colors
                    if #savedColors >= MAX_SAVED then
                        print("|cff7373f2DandersFrames:|r Maximum saved colors reached (" .. MAX_SAVED .. ")")
                        return
                    end
                    
                    -- Only save alpha if picker has alpha
                    local a = testFrame.hasAlpha and color.a or nil
                    local key = ColorKey(color.r, color.g, color.b, a or 1)
                    for _, saved in ipairs(savedColors) do
                        if ColorKey(saved.r, saved.g, saved.b, saved.a or 1) == key then
                            print("|cff7373f2DandersFrames:|r Color already saved")
                            return
                        end
                    end
                    
                    table.insert(savedColors, 1, {r = color.r, g = color.g, b = color.b, a = a})
                    SaveColorsToDb()
                    RefreshSavedSwatches()
                    
                    -- Switch to saved tab
                    testFrame.SetActiveTab("saved")
                    
                    -- Print confirmation with hex code
                    local hexCode = RGBtoHex(color.r, color.g, color.b, a)
                    print("|cff7373f2DandersFrames:|r Color saved: |cffffffff" .. hexCode .. "|r")
                end
            end)
            
            table.insert(recentSwatches, swatch)
        end
    end
    
    -- Function to add color to recent (called on Apply and on open)
    local function AddToRecent(r, g, b, a)
        local key = ColorKey(r, g, b, a)
        
        -- Remove if already exists (will re-add at front)
        for i, color in ipairs(recentColors) do
            if ColorKey(color.r, color.g, color.b, color.a) == key then
                table.remove(recentColors, i)
                break
            end
        end
        
        -- Add to front
        table.insert(recentColors, 1, {r = r, g = g, b = b, a = a})
        
        -- Trim to max (auto-delete oldest)
        while #recentColors > MAX_RECENT do
            table.remove(recentColors)
        end
        
        -- Save to DB
        SaveColorsToDb()
        
        RefreshRecentSwatches()
    end
    
    -- Store on testFrame for external access
    testFrame.AddToRecent = AddToRecent
    
    local function UpdateTabs()
        for name, btn in pairs(tabButtons) do
            if name == activeTab then
                btn.text:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
                btn.underline:Show()
            else
                btn.text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
                btn.underline:Hide()
            end
        end
        classContent:SetShown(activeTab == "class")
        savedContent:SetShown(activeTab == "saved")
        recentContent:SetShown(activeTab == "recent")
    end
    
    -- Store on testFrame for access from earlier-defined handlers
    testFrame.UpdateTabs = UpdateTabs
    testFrame.SetActiveTab = function(tab)
        activeTab = tab
        UpdateTabs()
    end
    
    for name, btn in pairs(tabButtons) do
        btn:SetScript("OnClick", function()
            activeTab = name
            UpdateTabs()
        end)
    end
    
    -- ============================================================
    -- Footer
    -- ============================================================
    
    local footer = CreateFrame("Frame", nil, testFrame, "BackdropTemplate")
    footer:SetHeight(40)
    footer:SetPoint("BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", 0, 0)
    footer:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    footer:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    
    -- Apply button on the left (matches Blizzard's color picker layout)
    local applyBtn = CreateFrame("Button", nil, footer, "BackdropTemplate")
    applyBtn:SetSize(80, 26)
    applyBtn:SetPoint("RIGHT", footer, "CENTER", -5, 0)
    applyBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    applyBtn:SetBackdropColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
    applyBtn:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
    local applyText = applyBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    applyText:SetPoint("CENTER")
    applyText:SetText("Okay")
    applyText:SetTextColor(1, 1, 1)
    applyBtn:SetScript("OnClick", function()
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        
        -- Add to recent colors
        AddToRecent(r, g, b, testFrame.hasAlpha and currentAlpha or nil)
        
        if testFrame.hasAlpha then
            print(string.format("|cff7373f2DandersFrames:|r Selected color: R=%.2f G=%.2f B=%.2f A=%.2f (%s)", r, g, b, currentAlpha, RGBtoHex(r, g, b, currentAlpha)))
        else
            print(string.format("|cff7373f2DandersFrames:|r Selected color: R=%.2f G=%.2f B=%.2f (%s)", r, g, b, RGBtoHex(r, g, b)))
        end
        testFrame:Hide()
    end)
    applyBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(C_ACCENT.r * 1.2, C_ACCENT.g * 1.2, C_ACCENT.b * 1.2, 1) end)
    applyBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1) end)
    
    -- Cancel button on the right (matches Blizzard's color picker layout)
    local cancelBtn = CreateFrame("Button", nil, footer, "BackdropTemplate")
    cancelBtn:SetSize(80, 26)
    cancelBtn:SetPoint("LEFT", footer, "CENTER", 5, 0)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, 1)
    cancelBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    cancelText:SetPoint("CENTER")
    cancelText:SetText("Cancel")
    cancelText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    cancelBtn:SetScript("OnClick", function() testFrame:Hide() end)
    cancelBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0.8, 0.4, 0.4, 1) end)
    cancelBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1) end)
    
    -- ============================================================
    -- API Methods
    -- ============================================================
    
    -- Set color from RGBA (0-1 range)
    function testFrame:SetColor(r, g, b, a)
        local h, s, v = RGBtoHSV(r, g, b)
        currentHue = h
        currentSat = s
        currentVal = v
        currentAlpha = a or 1
        UpdateAllColors()
    end
    
    -- Get current color as RGBA (0-1 range)
    function testFrame:GetColor()
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        return r, g, b, currentAlpha
    end
    
    -- Set callbacks
    function testFrame:SetCallbacks(onAccept, onCancel, onChange)
        self.onAcceptCallback = onAccept
        self.onCancelCallback = onCancel
        self.onChangeCallback = onChange
    end
    
    -- Clear callbacks
    function testFrame:ClearCallbacks()
        self.onAcceptCallback = nil
        self.onCancelCallback = nil
        self.onChangeCallback = nil
    end
    
    -- Update Apply button to use callback
    applyBtn:SetScript("OnClick", function()
        local r, g, b = HSVtoRGB(currentHue, currentSat, currentVal)
        
        -- Add to recent colors
        AddToRecent(r, g, b, testFrame.hasAlpha and currentAlpha or nil)
        
        -- Mark as applied so OnHide doesn't treat it as cancel
        testFrame.appliedColor = true
        
        -- Call callback if set
        if testFrame.onAcceptCallback then
            testFrame.onAcceptCallback({
                r = r,
                g = g, 
                b = b,
                a = testFrame.hasAlpha and currentAlpha or 1
            })
        end
        
        testFrame:ClearCallbacks()
        testFrame:Hide()
    end)
    
    -- Update Cancel button to use callback
    cancelBtn:SetScript("OnClick", function()
        -- OnHide will call onCancelCallback
        testFrame:Hide()
    end)
    
    -- ============================================================
    -- Initialize
    -- ============================================================
    
    currentHue = 25
    currentSat = 0.8
    currentVal = 0.9
    currentAlpha = 1
    
    UpdatePickerMode()
    UpdateTabs()
    RefreshSavedSwatches()
    RefreshRecentSwatches()
    testFrame:UpdateAlphaVisibility()
    UpdateAllColors()
    
    testFrame:Show()
end

-- ============================================================
-- PUBLIC API: GUI:OpenColorPicker
-- ============================================================

-- Open color picker with initial color, alpha support, and callbacks
-- @param initialColor: table with r, g, b, a (0-1 range)
-- @param hasAlpha: boolean - show alpha slider
-- @param onAccept: function(newColor) - called with {r, g, b, a} on accept
-- @param onCancel: function() - called on cancel
function GUI:OpenColorPicker(initialColor, hasAlpha, onAccept, onCancel, onChange)
    -- Ensure the picker is created
    CreateColorPickerTest(hasAlpha)
    
    -- If picker is already visible, hide it first without triggering cancel callback
    -- This prevents state leakage when quickly switching between color pickers
    if testFrame:IsShown() then
        testFrame.appliedColor = true  -- Prevent OnHide from calling old cancel callback
        testFrame:Hide()
    end
    
    -- Clear any previous callbacks to prevent state leakage
    testFrame:ClearCallbacks()
    testFrame.appliedColor = false
    testFrame.skipOnChange = false
    
    -- Set new callbacks
    testFrame:SetCallbacks(onAccept, onCancel, onChange)
    
    -- Set initial color (skip onChange callback during initialization)
    if initialColor then
        testFrame.skipOnChange = true
        testFrame:SetColor(
            initialColor.r or 1,
            initialColor.g or 1,
            initialColor.b or 1,
            initialColor.a or 1
        )
        testFrame.skipOnChange = false
        
        -- Add initial color to recent colors
        if testFrame.AddToRecent then
            testFrame.AddToRecent(
                initialColor.r or 1,
                initialColor.g or 1,
                initialColor.b or 1,
                hasAlpha and (initialColor.a or 1) or nil
            )
        end
    end
    
    -- Set alpha mode
    testFrame.hasAlpha = hasAlpha
    testFrame:UpdateAlphaVisibility()
    
    -- Update position relative to GUI
    if testFrame.UpdatePosition then
        testFrame.UpdatePosition()
    end
    
    -- Show
    testFrame:Show()
end

-- ============================================================
-- BLIZZARD COLOR PICKER OVERRIDE SYSTEM
-- Hidden Blizzard + Visible Custom UI Approach
-- 
-- How it works:
-- 1. Let Blizzard's picker open normally (callbacks are set up internally)
-- 2. Hide Blizzard's picker visually
-- 3. Show our beautiful custom picker
-- 4. Sync color changes to hidden Blizzard picker (triggers callbacks automatically)
-- 5. OK/Cancel click Blizzard's buttons (proper callback execution)
-- ============================================================

local originalOpenColorPicker = nil
local originalSetupColorPickerAndShow = nil
local blizzardPickerHidden = false

-- Hide Blizzard's color picker visually while keeping it functional
local function HideBlizzardPicker()
    if not ColorPickerFrame then return end
    
    -- Prevent auto-close when clicking outside
    ColorPickerFrame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    
    -- Scale down to tiny size (minimizes any flicker before hide takes effect)
    ColorPickerFrame:SetScale(0.001)
    
    -- Hide visually but keep functional
    ColorPickerFrame:SetAlpha(0)
    ColorPickerFrame:EnableMouse(false)
    
    -- Move it way off screen so it doesn't interfere
    ColorPickerFrame:ClearAllPoints()
    ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 10000, 10000)
    
    blizzardPickerHidden = true
end

-- Restore Blizzard's color picker to normal state
local function RestoreBlizzardPicker()
    if not ColorPickerFrame then return end
    
    -- Re-register the close event
    ColorPickerFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    
    -- Restore scale
    ColorPickerFrame:SetScale(1)
    
    -- Restore visibility
    ColorPickerFrame:SetAlpha(1)
    ColorPickerFrame:EnableMouse(true)
    
    -- Restore position (Blizzard will handle this on next open)
    ColorPickerFrame:ClearAllPoints()
    ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    blizzardPickerHidden = false
end

-- Sync color to Blizzard's hidden picker (this triggers addon callbacks automatically!)
local function SyncColorToBlizzard(r, g, b, a)
    if not ColorPickerFrame:IsShown() then return end
    
    local debugEnabled = DandersFrames and DandersFrames.db and DandersFrames.db.party and DandersFrames.db.party.colorPickerDebug
    
    if debugEnabled then
        print("|cffff9900[ColorPicker Debug] Syncing to Blizzard:|r", r, g, b, a)
    end
    
    -- Set color via the internal ColorPicker widget
    -- This triggers Blizzard's OnColorSelect which fires all addon callbacks naturally
    if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker then
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
        if ColorPickerFrame.hasOpacity and a and ColorPickerFrame.Content.ColorPicker.SetColorAlpha then
            ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a)
        end
    end
    
    -- Also set directly on ColorPickerFrame for addons that read from there
    if ColorPickerFrame.SetColorRGB then
        ColorPickerFrame:SetColorRGB(r, g, b)
    end
    if ColorPickerFrame.hasOpacity and a and ColorPickerFrame.SetColorAlpha then
        ColorPickerFrame:SetColorAlpha(a)
    end
end

-- Click Blizzard's OK button (handles all callback execution properly)
local function ClickBlizzardOK()
    if ColorPickerFrame and ColorPickerFrame.Footer and ColorPickerFrame.Footer.OkayButton then
        -- Mark as not hidden first (prevents cleanup hook from running)
        blizzardPickerHidden = false
        
        -- Keep scale tiny during click to prevent flicker
        -- Restore other properties so callbacks work
        ColorPickerFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
        ColorPickerFrame:SetAlpha(1)
        ColorPickerFrame:EnableMouse(true)
        -- Scale stays tiny!
        
        -- Click OK - Blizzard will hide the frame
        ColorPickerFrame.Footer.OkayButton:Click()
        
        -- Now restore scale for next time (frame is hidden now)
        ColorPickerFrame:SetScale(1)
        ColorPickerFrame:ClearAllPoints()
        ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

-- Click Blizzard's OK button with color sync (for external addon use)
local function ClickBlizzardOKWithColor(r, g, b, a)
    local debugEnabled = DandersFrames and DandersFrames.db and DandersFrames.db.party and DandersFrames.db.party.colorPickerDebug
    
    if debugEnabled then
        print("|cffff9900[ColorPicker Debug] ClickBlizzardOKWithColor called:|r", r, g, b, a)
    end
    
    if ColorPickerFrame and ColorPickerFrame.Footer and ColorPickerFrame.Footer.OkayButton then
        -- Mark as not hidden first (prevents cleanup hook from running)
        blizzardPickerHidden = false
        
        -- Restore properties so syncing works
        ColorPickerFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
        ColorPickerFrame:SetAlpha(1)
        ColorPickerFrame:EnableMouse(true)
        
        -- Sync final color directly before clicking OK
        if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker then
            ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
            if debugEnabled then
                print("  Set Content.ColorPicker RGB:", r, g, b)
            end
            if ColorPickerFrame.hasOpacity and a and ColorPickerFrame.Content.ColorPicker.SetColorAlpha then
                ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a)
                if debugEnabled then
                    print("  Set Content.ColorPicker Alpha:", a)
                end
            end
        end
        if ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:SetColorRGB(r, g, b)
            if debugEnabled then
                print("  Set ColorPickerFrame RGB:", r, g, b)
            end
        end
        if ColorPickerFrame.hasOpacity and a and ColorPickerFrame.SetColorAlpha then
            ColorPickerFrame:SetColorAlpha(a)
            if debugEnabled then
                print("  Set ColorPickerFrame Alpha:", a)
            end
        end
        
        -- Debug: verify what values will be read
        if debugEnabled then
            if ColorPickerFrame.GetColorRGB then
                local rr, gg, bb = ColorPickerFrame:GetColorRGB()
                print("  Verify GetColorRGB:", rr, gg, bb)
            end
            if ColorPickerFrame.GetColorAlpha then
                local aa = ColorPickerFrame:GetColorAlpha()
                print("  Verify GetColorAlpha:", aa)
            end
        end
        
        -- Click OK - Blizzard will hide the frame and call swatchFunc
        if debugEnabled then
            print("  Clicking OK button...")
        end
        ColorPickerFrame.Footer.OkayButton:Click()
        
        -- Now restore scale for next time (frame is hidden now)
        ColorPickerFrame:SetScale(1)
        ColorPickerFrame:ClearAllPoints()
        ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        
        if debugEnabled then
            print("  Done!")
        end
    else
        if debugEnabled then
            print("|cffff0000[ColorPicker Debug] ERROR: ColorPickerFrame or OkayButton not found!|r")
        end
    end
end

-- Click Blizzard's Cancel button (handles all callback execution properly)
local function ClickBlizzardCancel()
    if ColorPickerFrame and ColorPickerFrame.Footer and ColorPickerFrame.Footer.CancelButton then
        -- Mark as not hidden first (prevents cleanup hook from running)
        blizzardPickerHidden = false
        
        -- Keep scale tiny during click to prevent flicker
        -- Restore other properties so callbacks work
        ColorPickerFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
        ColorPickerFrame:SetAlpha(1)
        ColorPickerFrame:EnableMouse(true)
        -- Scale stays tiny!
        
        -- Click Cancel - Blizzard will hide the frame
        ColorPickerFrame.Footer.CancelButton:Click()
        
        -- Now restore scale for next time (frame is hidden now)
        ColorPickerFrame:SetScale(1)
        ColorPickerFrame:ClearAllPoints()
        ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

-- Open our color picker alongside hidden Blizzard picker
local function OpenDFColorPickerWithBlizzard(info, useBlizzardAsBackend)
    local debugEnabled = DandersFrames and DandersFrames.db and DandersFrames.db.party and DandersFrames.db.party.colorPickerDebug
    
    if debugEnabled then
        print("|cffff9900[ColorPicker Debug] Opening with Blizzard backend:|r", useBlizzardAsBackend)
        print("  r:", info.r, "g:", info.g, "b:", info.b)
        print("  hasOpacity:", info.hasOpacity)
        print("  opacity:", info.opacity)
    end
    
    -- Get initial color
    local r, g, b = info.r or 1, info.g or 1, info.b or 1
    local a = info.opacity or info.a or 1
    local hasAlpha = info.hasOpacity
    
    if useBlizzardAsBackend then
        -- Using hidden Blizzard picker as backend
        -- Blizzard's picker is already open, just hide it visually
        C_Timer.After(0.01, function()
            HideBlizzardPicker()
        end)
        
        -- Open our picker with callbacks that interact with Blizzard's hidden picker
        GUI:OpenColorPicker(
            { r = r, g = g, b = b, a = a },
            hasAlpha,
            -- On Accept: sync color and click Blizzard's OK button
            function(newColor)
                -- Sync and click OK in one operation to ensure color is correct
                ClickBlizzardOKWithColor(newColor.r, newColor.g, newColor.b, newColor.a)
            end,
            -- On Cancel: click Blizzard's Cancel button
            function()
                ClickBlizzardCancel()
            end,
            -- On Change: sync to Blizzard (triggers live preview callbacks)
            function(newColor)
                SyncColorToBlizzard(newColor.r, newColor.g, newColor.b, newColor.a)
            end
        )
    else
        -- Direct mode (DandersFrames internal, no Blizzard backend needed)
        -- Store callbacks for manual handling
        local callbacks = {
            swatchFunc = info.swatchFunc,
            cancelFunc = info.cancelFunc,
            opacityFunc = info.opacityFunc,
            hasOpacity = hasAlpha,
            originalR = r,
            originalG = g,
            originalB = b,
            originalA = a,
        }
        
        -- Set up previousValues for Blizzard UI compatibility
        ColorPickerFrame.previousValues = { r = r, g = g, b = b, a = a }
        
        local function ApplyColor(newColor)
            -- Set values on ColorPickerFrame for addons that read from there
            if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker then
                ColorPickerFrame.Content.ColorPicker:SetColorRGB(newColor.r, newColor.g, newColor.b)
                if callbacks.hasOpacity and ColorPickerFrame.Content.ColorPicker.SetColorAlpha then
                    ColorPickerFrame.Content.ColorPicker:SetColorAlpha(newColor.a)
                end
            end
            if ColorPickerFrame.SetColorRGB then
                ColorPickerFrame:SetColorRGB(newColor.r, newColor.g, newColor.b)
            end
            if callbacks.hasOpacity and ColorPickerFrame.SetColorAlpha then
                ColorPickerFrame:SetColorAlpha(newColor.a)
            end
            
            -- Call callbacks
            if callbacks.swatchFunc then pcall(callbacks.swatchFunc) end
            if callbacks.opacityFunc and callbacks.hasOpacity then pcall(callbacks.opacityFunc) end
        end
        
        GUI:OpenColorPicker(
            { r = r, g = g, b = b, a = a },
            hasAlpha,
            -- On Accept
            function(newColor)
                ApplyColor(newColor)
            end,
            -- On Cancel
            function()
                -- Restore original
                if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker then
                    ColorPickerFrame.Content.ColorPicker:SetColorRGB(callbacks.originalR, callbacks.originalG, callbacks.originalB)
                    if callbacks.hasOpacity and ColorPickerFrame.Content.ColorPicker.SetColorAlpha then
                        ColorPickerFrame.Content.ColorPicker:SetColorAlpha(callbacks.originalA)
                    end
                end
                ColorPickerFrame.previousValues = { r = callbacks.originalR, g = callbacks.originalG, b = callbacks.originalB, a = callbacks.originalA }
                if callbacks.swatchFunc then pcall(callbacks.swatchFunc) end
                if callbacks.opacityFunc and callbacks.hasOpacity then pcall(callbacks.opacityFunc) end
                if callbacks.cancelFunc then pcall(callbacks.cancelFunc) end
            end,
            -- On Change
            function(newColor)
                ApplyColor(newColor)
            end
        )
    end
end

-- Flag to mark when DandersFrames is opening a color picker
local dfColorPickerFlag = false

-- Call this before opening color picker from DandersFrames
function GUI:MarkColorPickerCall()
    dfColorPickerFlag = true
    -- Auto-clear after a short delay in case something goes wrong
    C_Timer.After(0.1, function() dfColorPickerFlag = false end)
end

-- Check if the current call is from DandersFrames
local function IsFromDandersFrames()
    local result = dfColorPickerFlag
    dfColorPickerFlag = false  -- Clear immediately after checking
    return result
end

-- Hooked SetupColorPickerAndShow function (Midnight API)
local function HookedSetupColorPickerAndShow(self, info)
    -- Safety check
    if not originalSetupColorPickerAndShow then
        return
    end
    
    -- Use global DandersFrames reference for db access
    local dfGlobal = DandersFrames
    local db = dfGlobal and dfGlobal.db and dfGlobal.db.party
    if not db then
        return originalSetupColorPickerAndShow(self, info)
    end
    
    -- Default settings if not set
    if db.colorPickerOverride == nil then
        db.colorPickerOverride = true
    end
    if db.colorPickerGlobalOverride == nil then
        db.colorPickerGlobalOverride = false
    end
    
    local isFromDF = IsFromDandersFrames()
    
    -- Hide our picker if it's showing (to prevent overlap)
    if testFrame and testFrame:IsShown() then
        testFrame.appliedColor = true
        testFrame:Hide()
    end
    
    if isFromDF and db.colorPickerOverride then
        -- DandersFrames internal call: use our picker directly (no Blizzard backend)
        OpenDFColorPickerWithBlizzard(info, false)
    elseif db.colorPickerGlobalOverride then
        -- Global override: let Blizzard open, then hide it and show ours
        -- Pre-scale to tiny size BEFORE Blizzard opens (minimizes flicker)
        if ColorPickerFrame then
            ColorPickerFrame:SetScale(0.001)
        end
        -- Let Blizzard set up (it opens but is tiny)
        originalSetupColorPickerAndShow(self, info)
        -- Now open our picker with Blizzard as hidden backend
        OpenDFColorPickerWithBlizzard(info, true)
    else
        -- No override: just use Blizzard normally
        originalSetupColorPickerAndShow(self, info)
    end
end

-- Legacy hooked OpenColorPicker function (pre-Midnight)
local function HookedOpenColorPicker(info)
    if not originalOpenColorPicker then
        return
    end
    
    -- Use global DandersFrames reference for db access
    local dfGlobal = DandersFrames
    local db = dfGlobal and dfGlobal.db and dfGlobal.db.party
    if not db then
        return originalOpenColorPicker(info)
    end
    
    -- Default settings if not set
    if db.colorPickerOverride == nil then
        db.colorPickerOverride = true
    end
    if db.colorPickerGlobalOverride == nil then
        db.colorPickerGlobalOverride = false
    end
    
    local isFromDF = IsFromDandersFrames()
    
    -- Hide our picker if it's showing (to prevent overlap)
    if testFrame and testFrame:IsShown() then
        testFrame.appliedColor = true
        testFrame:Hide()
    end
    
    if isFromDF and db.colorPickerOverride then
        -- DandersFrames internal call: use our picker directly (no Blizzard backend)
        OpenDFColorPickerWithBlizzard(info, false)
    elseif db.colorPickerGlobalOverride then
        -- Global override: let Blizzard open, then hide it and show ours
        -- Pre-scale to tiny size BEFORE Blizzard opens (minimizes flicker)
        if ColorPickerFrame then
            ColorPickerFrame:SetScale(0.001)
        end
        -- Let Blizzard set up (it opens but is tiny)
        originalOpenColorPicker(info)
        -- Now open our picker with Blizzard as hidden backend
        OpenDFColorPickerWithBlizzard(info, true)
    else
        -- No override: just use Blizzard normally
        originalOpenColorPicker(info)
    end
end

-- Install/uninstall hooks
function GUI:InstallColorPickerHook()
    local installed = false
    
    -- Try Midnight API first (SetupColorPickerAndShow)
    if ColorPickerFrame and type(ColorPickerFrame.SetupColorPickerAndShow) == "function" then
        if ColorPickerFrame.SetupColorPickerAndShow ~= HookedSetupColorPickerAndShow then
            originalSetupColorPickerAndShow = ColorPickerFrame.SetupColorPickerAndShow
            ColorPickerFrame.SetupColorPickerAndShow = HookedSetupColorPickerAndShow
            installed = true
        end
    end
    
    -- Also try legacy API (OpenColorPicker) for compatibility
    if type(OpenColorPicker) == "function" then
        if OpenColorPicker ~= HookedOpenColorPicker then
            originalOpenColorPicker = OpenColorPicker
            OpenColorPicker = HookedOpenColorPicker
            installed = true
        end
    end
    
    return installed
end

function GUI:UninstallColorPickerHook()
    -- Restore Midnight API
    if ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow == HookedSetupColorPickerAndShow and originalSetupColorPickerAndShow then
        ColorPickerFrame.SetupColorPickerAndShow = originalSetupColorPickerAndShow
        originalSetupColorPickerAndShow = nil
    end
    
    -- Restore legacy API
    if OpenColorPicker == HookedOpenColorPicker and originalOpenColorPicker then
        OpenColorPicker = originalOpenColorPicker
        originalOpenColorPicker = nil
    end
end

-- Check if hook is installed
function GUI:IsColorPickerHookInstalled()
    local midnightHooked = ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow == HookedSetupColorPickerAndShow
    local legacyHooked = type(OpenColorPicker) == "function" and OpenColorPicker == HookedOpenColorPicker
    return midnightHooked or legacyHooked
end

-- Auto-install hook after addon is fully loaded
local hookInitFrame = CreateFrame("Frame")
hookInitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
hookInitFrame:SetScript("OnEvent", function(self, event)
    -- Always install the hook - the hook itself checks settings when invoked
    -- Use a timer to ensure ColorPickerFrame is fully initialized
    C_Timer.After(1, function()
        GUI:InstallColorPickerHook()
    end)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Slash commands
SLASH_DFCOLORTEST1 = "/dfcolortest"
SlashCmdList["DFCOLORTEST"] = function()
    CreateColorPickerTest(true)  -- With alpha
end

SLASH_DFCOLORTESTNOALPHA1 = "/dfcolortestna"
SlashCmdList["DFCOLORTESTNOALPHA"] = function()
    CreateColorPickerTest(false)  -- Without alpha
end

-- Debug command to check hook status
SLASH_DFCOLORHOOK1 = "/dfcolorhook"
SlashCmdList["DFCOLORHOOK"] = function(arg)
    if arg == "on" then
        local success = GUI:InstallColorPickerHook()
        if success then
            print("|cff00ff00DandersFrames:|r Color picker hook installed")
        else
            print("|cffff0000DandersFrames:|r Failed to install hook (already hooked or API not available)")
        end
    elseif arg == "off" then
        GUI:UninstallColorPickerHook()
        print("|cffff0000DandersFrames:|r Color picker hook removed")
    elseif arg == "debug" then
        -- Toggle debug mode
        local dfGlobal = DandersFrames
        local db = dfGlobal and dfGlobal.db and dfGlobal.db.party
        if db then
            db.colorPickerDebug = not db.colorPickerDebug
            print("|cff7373f2DandersFrames:|r Color picker debug " .. (db.colorPickerDebug and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
            print("Open a color picker to see debug output")
        else
            print("|cffff0000DandersFrames:|r DB not available")
        end
    elseif arg == "api" then
        -- Show API info
        print("|cff7373f2Checking API functions:|r")
        print("  OpenColorPicker:", type(OpenColorPicker))
        print("  ColorPickerFrame:", type(ColorPickerFrame))
        if ColorPickerFrame then
            print("  ColorPickerFrame.SetupColorPickerAndShow:", type(ColorPickerFrame.SetupColorPickerAndShow))
            print("  ColorPickerFrame.Show:", type(ColorPickerFrame.Show))
            print("  ColorPickerFrame.SetColorRGB:", type(ColorPickerFrame.SetColorRGB))
            print("  ColorPickerFrame.GetColorRGB:", type(ColorPickerFrame.GetColorRGB))
            print("  ColorPickerFrame.SetColorAlpha:", type(ColorPickerFrame.SetColorAlpha))
            print("  ColorPickerFrame.GetColorAlpha:", type(ColorPickerFrame.GetColorAlpha))
            if ColorPickerFrame.Content then
                print("  ColorPickerFrame.Content:", type(ColorPickerFrame.Content))
                if ColorPickerFrame.Content.ColorPicker then
                    print("  ColorPickerFrame.Content.ColorPicker:", type(ColorPickerFrame.Content.ColorPicker))
                    print("  ColorPickerFrame.Content.ColorPicker.SetColorRGB:", type(ColorPickerFrame.Content.ColorPicker.SetColorRGB))
                    print("  ColorPickerFrame.Content.ColorPicker.GetColorRGB:", type(ColorPickerFrame.Content.ColorPicker.GetColorRGB))
                    print("  ColorPickerFrame.Content.ColorPicker.SetColorAlpha:", type(ColorPickerFrame.Content.ColorPicker.SetColorAlpha))
                    print("  ColorPickerFrame.Content.ColorPicker.GetColorAlpha:", type(ColorPickerFrame.Content.ColorPicker.GetColorAlpha))
                end
            end
        end
    else
        local isInstalled = GUI:IsColorPickerHookInstalled()
        local dfGlobal = DandersFrames
        local db = dfGlobal and dfGlobal.db and dfGlobal.db.party
        print("|cff7373f2DandersFrames Color Picker Hook Status:|r")
        print("  Hook installed: " .. (isInstalled and "|cff00ff00Yes|r" or "|cffff0000No|r"))
        print("  Midnight API (SetupColorPickerAndShow): " .. (ColorPickerFrame and type(ColorPickerFrame.SetupColorPickerAndShow) or "N/A"))
        print("  Legacy API (OpenColorPicker): " .. type(OpenColorPicker))
        print("  originalSetupColorPickerAndShow: " .. (originalSetupColorPickerAndShow and "|cff00ff00captured|r" or "|cffff0000nil|r"))
        print("  originalOpenColorPicker: " .. (originalOpenColorPicker and "|cff00ff00captured|r" or "|cffff0000nil|r"))
        print("  DB available: " .. (db and "|cff00ff00Yes|r" or "|cffff0000No|r"))
        if db then
            print("  colorPickerOverride: " .. (db.colorPickerOverride and "|cff00ff00true|r" or "|cffff0000false|r"))
            print("  colorPickerGlobalOverride: " .. (db.colorPickerGlobalOverride and "|cff00ff00true|r" or "|cffff0000false|r"))
            print("  colorPickerDebug: " .. (db.colorPickerDebug and "|cff00ff00true|r" or "|cffff0000false|r"))
        end
        print("Use |cffeda55f/dfcolorhook on|r or |cffeda55f/dfcolorhook off|r to toggle")
        print("Use |cffeda55f/dfcolorhook debug|r to toggle debug output")
        print("Use |cffeda55f/dfcolorhook api|r to show API info")
    end
end

-- ============================================================
-- BLIZZARD PICKER STATE RESTORATION
-- Ensure Blizzard's picker is restored when our picker closes
-- ============================================================

-- Hook our picker's OnHide to restore Blizzard if needed
local function SetupPickerCleanup()
    if testFrame then
        testFrame:HookScript("OnHide", function()
            if blizzardPickerHidden then
                -- Try to use ClickBlizzardCancel for proper scale handling
                if ColorPickerFrame and ColorPickerFrame.Footer and ColorPickerFrame.Footer.CancelButton and ColorPickerFrame:IsShown() then
                    ClickBlizzardCancel()
                else
                    -- Fallback: just restore state directly
                    if ColorPickerFrame then
                        ColorPickerFrame:SetScale(1)
                        ColorPickerFrame:SetAlpha(1)
                        ColorPickerFrame:EnableMouse(true)
                        ColorPickerFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
                        ColorPickerFrame:ClearAllPoints()
                        ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                    end
                    blizzardPickerHidden = false
                end
            end
        end)
    end
end

-- Initialize cleanup hook after picker is created
local cleanupInitialized = false
hooksecurefunc(GUI, "OpenColorPicker", function()
    if not cleanupInitialized and testFrame then
        SetupPickerCleanup()
        cleanupInitialized = true
    end
end)
