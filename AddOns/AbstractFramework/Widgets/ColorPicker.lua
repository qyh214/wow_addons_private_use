---@class AbstractFramework
local AF = _G.AbstractFramework

----------------------------------------------------------------
-- color picker widget
----------------------------------------------------------------
---@class AF_ColorPicker:Button
local AF_ColorPickerMixin = {}

function AF_ColorPickerMixin:EnableAlpha(enabled)
    AF.HideColorPicker()
    self.alphaEnabled = enabled
end

---@param ... number|table r, g, b, a or {r, g, b, a}
function AF_ColorPickerMixin:SetColor(...)
    if select("#", ...) == 1 then
        local t = ...
        self.color[1] = t[1]
        self.color[2] = t[2]
        self.color[3] = t[3]
        self.color[4] = t[4]
        self:SetBackdropColor(AF.UnpackColor(t))
    else
        local r, g, b, a = ...
        self.color[1] = r
        self.color[2] = g
        self.color[3] = b
        self.color[4] = a
        self:SetBackdropColor(r, g, b, a)
    end
end

function AF_ColorPickerMixin:GetColorTable()
    return self.color
end

function AF_ColorPickerMixin:GetColorRGB()
    return AF.UnpackColor(self.color)
end

---@param parent Frame
---@param label string
---@param alphaEnabled boolean
---@param onChange function
---@param onConfirm function
---@return AF_ColorPicker cp
function AF.CreateColorPicker(parent, label, alphaEnabled, onChange, onConfirm)
    local cp = CreateFrame("Button", nil, parent, "BackdropTemplate")
    AF.SetSize(cp, 14, 14)
    AF.ApplyDefaultBackdrop(cp)
    cp:SetBackdropBorderColor(0, 0, 0, 1)

    cp.label = AF.CreateFontString(cp, label)
    AF.SetPoint(cp.label, "LEFT", cp, "RIGHT", 5, 0)
    cp:SetHitRectInsets(0, -cp.label:GetStringWidth()-5, 0, 0)

    cp.accentColor = AF.GetAddonAccentColorName()

    cp:SetScript("OnEnter", function()
        cp:SetBackdropBorderColor(AF.GetColorRGB(cp.accentColor, nil, 0.5))
        cp.label:SetColor(cp.accentColor)
    end)

    cp:SetScript("OnLeave", function()
        cp:SetBackdropBorderColor(AF.GetColorRGB("black"))
        cp.label:SetColor("white")
    end)

    -- cp.mask = AF.CreateTexture(cp, nil, {0.15, 0.15, 0.15, 0.75})
    -- AF.SetPoint(cp.mask, "TOPLEFT", 1, -1)
    -- AF.SetPoint(cp.mask, "BOTTOMRIGHT", -1, 1)
    -- cp.mask:Hide()

    Mixin(cp, AF_ColorPickerMixin)

    cp.alphaEnabled = alphaEnabled
    cp.onChange = onChange
    cp.onConfirm = onConfirm

    cp.color = {1, 1, 1, 1}

    cp:SetScript("OnClick", function()
        -- reset temp
        cp._r = cp.color[1]
        cp._g = cp.color[2]
        cp._b = cp.color[3]
        cp._a = cp.color[4]

        AF.ShowColorPicker(cp, function(r, g, b, a)
            cp:SetBackdropColor(r, g, b, a)
            if cp._r ~= r or cp._g ~= g or cp._b ~= b or cp._a ~= a then
                cp._r = r
                cp._g = g
                cp._b = b
                cp._a = a
                if cp.onChange then
                    cp.onChange(r, g, b, a)
                end
            end
        end, function(r, g, b, a)
            if cp.color[1] ~= r or cp.color[2] ~= g or cp.color[3] ~= b or cp.color[4] ~= a then
                cp.color[1] = r
                cp.color[2] = g
                cp.color[3] = b
                cp.color[4] = a
                if cp.onConfirm then
                    cp.onConfirm(r, g, b, a)
                end
            end
        end, cp.alphaEnabled, unpack(cp.color))
    end)

    cp.color = {1, 1, 1, 1}

    cp:SetScript("OnEnable", function()
        cp.label:SetTextColor(AF.GetColorRGB("white"))
        cp:SetBackdropColor(AF.UnpackColor(cp.color))
        -- cp.mask:Hide()
    end)

    cp:SetScript("OnDisable", function()
        cp.label:SetTextColor(AF.GetColorRGB("disabled"))
        cp:SetBackdropColor(AF.ConvertToGrayscale(AF.UnpackColor(cp.color)))
        -- cp.mask:Show()
    end)

    AF.AddToPixelUpdater(cp)

    return cp
end

----------------------------------------------------------------
-- color picker frame
----------------------------------------------------------------
local colorPickerFrame
local currentPane, originalPane, saturationBrightnessPane, hueSlider, alphaSlider, picker
local rEB, gEB, bEB, aEB, h_EB, s_EB, b_EB, hexEB
local confirmBtn, cancelBtn

local Callback

local oR, oG, oB, oA
local H, S, B, A

-------------------------------------------------
-- update functions
-------------------------------------------------
local function UpdateColor_RGBA(r, g, b, a)
    -- update currentPane & originalPane
    currentPane:SetColor(r, g, b, a)

    r, g, b = Round(r * 255), Round(g * 255), Round(b * 255)

    -- update editboxes
    rEB:SetText(r)
    gEB:SetText(g)
    bEB:SetText(b)
    aEB:SetText(Round(a * 100))
    hexEB:SetText(AF.ConvertRGB256ToHEX(r, g, b))
end

local function UpdateColor_HSBA(h, s, b, a, updateWidgetColor, updatePickerAndSlider)
    h_EB:SetText(Round(h))
    s_EB:SetText(Round(s * 100))
    b_EB:SetText(Round(b * 100))

    if updateWidgetColor then
        local _r, _g, _b = AF.ConvertHSBToRGB(h, 1, 1)
        saturationBrightnessPane.tex:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(_r, _g, _b, 1))

        _r, _g, _b = AF.ConvertHSBToRGB(h, s, b)
        alphaSlider.tex2:SetGradient("VERTICAL", CreateColor(_r, _g, _b, 0), CreateColor(_r, _g, _b, 1))
    end

    if updatePickerAndSlider then
        picker:SetPoint("CENTER", saturationBrightnessPane, "BOTTOMLEFT", Round(s*saturationBrightnessPane:GetWidth()), Round(b*saturationBrightnessPane:GetHeight()))
        hueSlider:SetValue(h)
        alphaSlider:SetValue(1-a)
    end
end

local function UpdateAll(use, v1, v2, v3, a, updateWidgetColor, updatePickerAndSlider)
    if use == "rgb" then
        v1 = tonumber(format("%.3f", v1))
        v2 = tonumber(format("%.3f", v2))
        v3 = tonumber(format("%.3f", v3))
        UpdateColor_RGBA(v1, v2, v3, a)
        local h, s, b = AF.ConvertRGBToHSB(v1, v2, v3)
        UpdateColor_HSBA(h, s, b, a, updateWidgetColor, updatePickerAndSlider)
        Callback(v1, v2, v3, a)
    elseif use == "hsb" then
        UpdateColor_HSBA(v1, v2, v3, a, updateWidgetColor, updatePickerAndSlider)
        local r, g, b = AF.ConvertHSBToRGB(v1, v2, v3)
        UpdateColor_RGBA(r, g, b, a)
        Callback(r, g, b, a)
    end
end

-------------------------------------------------
-- create color pane
-------------------------------------------------
local function CreateColorPane()
    local pane = AF.CreateBorderedFrame(colorPickerFrame, nil, 102, 27)

    pane.solid = AF.CreateTexture(pane)
    AF.SetPoint(pane.solid, "TOPLEFT", 1, -1)
    AF.SetPoint(pane.solid, "BOTTOMRIGHT", pane, "BOTTOMLEFT", 50, 1)

    pane.alpha = AF.CreateTexture(pane)
    AF.SetPoint(pane.alpha, "TOPLEFT", pane.solid, "TOPRIGHT")
    AF.SetPoint(pane.alpha, "BOTTOMRIGHT", -1, 1)

    function pane:SetColor(r, g, b, a)
        pane.solid:SetColorTexture(r, g, b)
        pane.alpha:SetColorTexture(r, g, b, a)
    end

    return pane
end

-------------------------------------------------
-- create color slider
-------------------------------------------------
local function CreateColorSliderHolder(onValueChanged)
    local holder = CreateFrame("Frame", nil, colorPickerFrame, "BackdropTemplate")
    AF.SetSize(holder, 20, 132)
    AF.ApplyDefaultBackdropWithColors(holder)

    local slider = CreateFrame("Slider", nil, holder)
    holder.slider = slider
    AF.SetOnePixelInside(slider, holder)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("VERTICAL")

    slider:SetScript("OnValueChanged", onValueChanged)

    slider.thumb1 = slider:CreateTexture(nil, "ARTWORK")
    AF.SetSize(slider.thumb1, 20, 1)
    slider:SetThumbTexture(slider.thumb1)

    slider.thumb2 = slider:CreateTexture(nil, "ARTWORK")
    slider.thumb2:SetTexture(AF.GetIcon("ArrowLeft2"))
    AF.SetSize(slider.thumb2, 16, 16)
    AF.SetPoint(slider.thumb2, "LEFT", slider.thumb1, "RIGHT", -5, 0)

    function holder:UpdatePixels()
        AF.ReSize(holder)
        AF.RePoint(holder)
        AF.ReBorder(holder)
        AF.RePoint(slider)
        AF.ReSize(slider.thumb1)
        AF.ReSize(slider.thumb2)
        AF.RePoint(slider.thumb2)
    end

    return holder
end

-------------------------------------------------
-- create color editbox
-------------------------------------------------
local function CreateEB(label, width, height, isNumeric, group)
    local eb = AF.CreateEditBox(colorPickerFrame, nil, width, height, isNumeric and "number" or "trim")
    eb.label2 = AF.CreateFontString(eb, label)
    AF.SetPoint(eb.label2, "BOTTOMLEFT", eb, "TOPLEFT", 0, 2)

    eb:SetScript("OnEditFocusGained", function()
        eb:HighlightText()
        eb.oldText = eb:GetText()
    end)

    eb:SetScript("OnEditFocusLost", function()
        eb:HighlightText(0, 0)
        if strtrim(eb:GetText()) == "" then
            eb:SetText(eb.oldText)
        end
    end)

    eb:SetScript("OnEnterPressed", function()
        if isNumeric then
            if group == "rgb" then
                if rEB:GetNumber() > 255 then
                    rEB:SetText(255)
                end
                if gEB:GetNumber() > 255 then
                    gEB:SetText(255)
                end
                if bEB:GetNumber() > 255 then
                    bEB:SetText(255)
                end

                local r, g, b = AF.ConvertToRGB(rEB:GetNumber(), gEB:GetNumber(), bEB:GetNumber())
                H, S, B = AF.ConvertRGBToHSB(r, g, b)
                UpdateAll("rgb", r, g, b, A, true, true)

            elseif group == "hsb" then
                if h_EB:GetNumber() > 360 then
                    h_EB:SetText(360)
                end
                if s_EB:GetNumber() > 100 then
                    s_EB:SetText(100)
                end
                if b_EB:GetNumber() > 100 then
                    b_EB:SetText(100)
                end

                H, S, B = h_EB:GetNumber(), s_EB:GetNumber()/100, b_EB:GetNumber()/100
                UpdateAll("hsb", H, S, B, A, true, true)

            else -- alphaSlider
                if aEB:GetNumber() > 100 then
                    aEB:SetText(100)
                end
                A = aEB:GetNumber()/100

                alphaSlider:SetValue(1-A)
                UpdateAll("hsb", H, S, B, A)
            end

        else -- hex
            local text = strtrim(hexEB:GetText())
            -- print(text, hexEB.oldText)
            if strlen(text) ~= 6 or not strmatch(text, "^[0-9a-fA-F]+$") then
                hexEB:SetText(hexEB.oldText)
            end

            local r, g, b = AF.ConvertToRGB(AF.ConvertHEXToRGB256(hexEB:GetText()))
            H, S, B = AF.ConvertRGBToHSB(r, g, b)
            UpdateAll("rgb", r, g, b, A, true, true)
        end

        eb:ClearFocus()
    end)

    return eb
end

-------------------------------------------------
-- color grids
-------------------------------------------------
local function CreateColorGrid(color)
    local grid = AF.CreateButton(colorPickerFrame, nil, nil, 14, 14)

    if type(color) == "table" then
        AF.SetTooltips(grid, "ANCHOR_TOPLEFT", 0, 2, "|c"..AF.GetColorHex(color[1])..color[2])
        color = color[1]
    end

    local r, g, b, a = AF.GetColorRGB(color, 1)
    grid:SetBackdropBorderColor(AF.GetColorRGB("black"))
    grid:SetBackdropColor(r, g, b, a)

    grid:SetScript("OnClick", function()
        H, S, B = AF.ConvertRGBToHSB(r, g, b)
        A = a
        UpdateAll("rgb", r, g, b, a, true, true)
    end)

    return grid
end

local localizedClass = LocalizedClassList()

local preset1 = {
    {"DEATHKNIGHT", localizedClass["DEATHKNIGHT"]},
    {"DEMONHUNTER", localizedClass["DEMONHUNTER"]},
    {"DRUID", localizedClass["DRUID"]},
    {"EVOKER", localizedClass["EVOKER"]},
    {"HUNTER", localizedClass["HUNTER"]},
    {"MAGE", localizedClass["MAGE"]},
    {"MONK", localizedClass["MONK"]},
    {"PALADIN", localizedClass["PALADIN"]},
    {"PRIEST", localizedClass["PRIEST"]},
    {"ROGUE", localizedClass["ROGUE"]},
    {"SHAMAN", localizedClass["SHAMAN"]},
    {"WARLOCK", localizedClass["WARLOCK"]},
    {"WARRIOR", localizedClass["WARRIOR"]},
}

local preset2 = {
    {"Poor", ITEM_QUALITY0_DESC},
    {"Common", ITEM_QUALITY1_DESC},
    {"Uncommon", ITEM_QUALITY2_DESC},
    {"Rare", ITEM_QUALITY3_DESC},
    {"Epic", ITEM_QUALITY4_DESC},
    {"Legendary", ITEM_QUALITY5_DESC},
    {"Artifact", ITEM_QUALITY6_DESC},
    {"Heirloom", ITEM_QUALITY7_DESC},
    {"WoWToken", ITEM_QUALITY8_DESC},
}

local preset3 = {
    "red", "yellow", "green", "cyan", "blue", "purple",
    "pink", "chartreuse",
    "blazing_tangerine", "vivid_raspberry"
}

-------------------------------------------------
-- CreateColorPickerFrame
-------------------------------------------------
local function CreateColorPickerFrame()
    colorPickerFrame = AF.CreateHeaderedFrame(UIParent, "AFColorPicker", _G.COLOR_PICKER, 269, 297, "DIALOG")
    colorPickerFrame.header.closeBtn:Hide()
    -- AF.ApplyDefaultBackdropWithColors(colorPickerFrame, nil, "accent")
    -- AF.ApplyDefaultBackdropWithColors(colorPickerFrame.header, "header", "accent")
    AF.SetPoint(colorPickerFrame, "CENTER")

    ---------------------------------------------
    -- color pane
    ---------------------------------------------
    currentPane = CreateColorPane()
    AF.SetPoint(currentPane, "TOPLEFT", 7, -7)

    originalPane = CreateColorPane()
    AF.SetPoint(originalPane, "TOPLEFT", currentPane, "TOPRIGHT", 7, 0)

    ---------------------------------------------
    -- saturation, brightness
    ---------------------------------------------
    local saturationBrightnessPaneBG = AF.CreateBorderedFrame(colorPickerFrame, nil, 132, 132)
    AF.SetPoint(saturationBrightnessPaneBG, "TOPLEFT", currentPane, "BOTTOMLEFT", 0, -7)

    saturationBrightnessPane = CreateFrame("Frame", nil, saturationBrightnessPaneBG)
    AF.SetOnePixelInside(saturationBrightnessPane, saturationBrightnessPaneBG)
    saturationBrightnessPane.tex = saturationBrightnessPane:CreateTexture(nil, "ARTWORK", nil, 0)
    saturationBrightnessPane.tex:SetAllPoints(saturationBrightnessPane)
    saturationBrightnessPane.tex:SetTexture(AF.GetPlainTexture())

    -- add brightness
    local brightness = AF.CreateGradientTexture(saturationBrightnessPane, "VERTICAL", AF.GetColorTable("black", 1), AF.GetColorTable("black", 0), nil, nil, 1)
    brightness:SetAllPoints(saturationBrightnessPane)

    ---------------------------------------------
    -- hue slider
    ---------------------------------------------
    local hueSliderHolder = CreateColorSliderHolder(function(self, value, userChanged)
        if not userChanged then return end
        H = value

        if self.prev == H then return end
        self.prev = H

        -- update
        UpdateAll("hsb", H, S, B, A, true)
    end)
    AF.SetPoint(hueSliderHolder, "TOPLEFT", saturationBrightnessPaneBG, "TOPRIGHT", 15, 0)

    hueSlider = hueSliderHolder.slider

    hueSlider:SetValueStep(1)
    hueSlider:SetMinMaxValues(0, 360)

    -- fill color
    local colors = {"red", "yellow", "green", "cyan", "blue", "purple", "red"}
    local sectionSize = hueSlider:GetHeight() / 6
    for i = 1, 6 do
        hueSlider[i] = AF.CreateGradientTexture(hueSlider, "VERTICAL", colors[i+1], colors[i])

        -- width
        hueSlider[i]:SetHeight(sectionSize)

        -- point
        if i == 1 then
            hueSlider[i]:SetPoint("TOPLEFT")
        else
            hueSlider[i]:SetPoint("TOPLEFT", hueSlider[i-1], "BOTTOMLEFT")
        end
        hueSlider[i]:SetPoint("RIGHT")
    end

    ---------------------------------------------
    -- alpha slider
    ---------------------------------------------
    local alphaSliderHolder = CreateColorSliderHolder(function(self, value, userChanged)
        if not userChanged then return end
        A = tonumber(format("%.3f", 1 - value))

        if self.prev == A then return end
        self.prev = A

        -- update
        UpdateAll("hsb", H, S, B, A)
    end)
    AF.SetPoint(alphaSliderHolder, "TOPLEFT", hueSliderHolder, "TOPRIGHT", 15, 0)

    alphaSlider = alphaSliderHolder.slider

    alphaSlider:SetValueStep(0.001)
    alphaSlider:SetMinMaxValues(0, 1)

    alphaSlider.tex1 = alphaSlider:CreateTexture(nil, "ARTWORK", nil, 0)
    alphaSlider.tex1:SetTexture(AF.GetIcon("ColorPicker"))
    alphaSlider.tex1:SetHorizTile(true)
    alphaSlider.tex1:SetVertTile(true)
    alphaSlider.tex1:SetAllPoints(alphaSlider)

    alphaSlider.tex2 = alphaSlider:CreateTexture(nil, "ARTWORK", nil, 1)
    alphaSlider.tex2:SetTexture(AF.GetPlainTexture())
    alphaSlider.tex2:SetAllPoints(alphaSlider)

    alphaSlider:SetScript("OnEnable", function()
        alphaSlider:SetAlpha(1)
        alphaSlider.thumb2:SetVertexColor(AF.GetColorRGB("white"))
    end)
    alphaSlider:SetScript("OnDisable", function()
        alphaSlider:SetAlpha(0.25)
        alphaSlider.thumb2:SetVertexColor(AF.GetColorRGB("disabled"))
    end)

    ---------------------------------------------
    -- picker
    ---------------------------------------------
    picker = CreateFrame("Frame", nil, saturationBrightnessPane)
    AF.SetSize(picker, 16, 16)
    picker:SetPoint("CENTER", saturationBrightnessPane, "BOTTOMLEFT")

    picker.tex = picker:CreateTexture(nil, "ARTWORK")
    picker.tex:SetAllPoints()
    picker.tex:SetTexture(AF.GetIcon("ColorPickerRing"))
    -- AF.SetSize(picker.tex1, 10, 10)
    -- picker.tex1:SetTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
    -- picker.tex1:SetTexCoord(0, 0.15625, 0, 0.625)

    picker:EnableMouse(true)
    picker:SetMovable(true)

    function picker:StartMoving(x, y, mouseX, mouseY)
        local scale = picker:GetEffectiveScale()

        local lastX, lastY
        self:SetScript("OnUpdate", function(self)
            local newMouseX, newMouseY = GetCursorPosition()
            if newMouseX == lastX and newMouseY == lastY then return end
            lastX, lastY = newMouseX, newMouseY

            local newX = x + (newMouseX - mouseX) / scale
            local newY = y + (newMouseY - mouseY) / scale

            if newX < 0 then -- left
                newX = 0
            elseif newX > saturationBrightnessPane:GetWidth() then -- right
                newX = saturationBrightnessPane:GetWidth()
            end

            if newY < 0 then -- top
                newY = 0
            elseif newY > saturationBrightnessPane:GetHeight() then
                newY = saturationBrightnessPane:GetHeight()
            end

            picker:SetPoint("CENTER", saturationBrightnessPane, "BOTTOMLEFT", newX, newY)

            -- update HSV
            S = newX / saturationBrightnessPane:GetWidth()
            B = newY / saturationBrightnessPane:GetHeight()

            -- update
            UpdateAll("hsb", H, S, B, A, true)
        end)
    end

    picker:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end

        local x, y = select(4, picker:GetPoint(1))
        local mouseX, mouseY = GetCursorPosition()

        picker:StartMoving(x, y, mouseX, mouseY)
    end)

    picker:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- click & drag
    saturationBrightnessPane:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end

        local sbX, sbY = saturationBrightnessPane:GetLeft(), saturationBrightnessPane:GetBottom()
        local mouseX, mouseY = GetCursorPosition()

        local scale = picker:GetEffectiveScale()
        mouseX, mouseY = mouseX/scale, mouseY/scale

        -- start dragging
        local x, y = select(4, picker:GetPoint(1))
        picker:StartMoving(mouseX/scale-sbX, mouseY/scale-sbY, mouseX, mouseY)
    end)

    saturationBrightnessPane:SetScript("OnMouseUp", function(self, button)
        picker:SetScript("OnUpdate", nil)
    end)

    ---------------------------------------------
    -- editboxes
    ---------------------------------------------
    -- red
    rEB = CreateEB("R", 40, 20, true, "rgb")
    AF.SetPoint(rEB, "TOPLEFT", saturationBrightnessPaneBG, "BOTTOMLEFT", 0, -25)

    -- green
    gEB = CreateEB("G", 40, 20, true, "rgb")
    AF.SetPoint(gEB, "TOPLEFT", rEB, "TOPRIGHT", 7, 0)

    -- blue
    bEB = CreateEB("B", 40, 20, true, "rgb")
    AF.SetPoint(bEB, "TOPLEFT", gEB, "TOPRIGHT", 7, 0)

    -- alphaSlider
    aEB = CreateEB("A", 69, 20, true)
    AF.SetPoint(aEB, "TOPLEFT", bEB, "TOPRIGHT", 7, 0)

    -- hue
    h_EB = CreateEB("H", 40, 20, true, "hsb")
    AF.SetPoint(h_EB, "TOPLEFT", rEB, "BOTTOMLEFT", 0, -25)

    -- saturation
    s_EB = CreateEB("S", 40, 20, true, "hsb")
    AF.SetPoint(s_EB, "TOPLEFT", h_EB, "TOPRIGHT", 7, 0)

    -- brightness
    b_EB = CreateEB("B", 40, 20, true, "hsb")
    AF.SetPoint(b_EB, "TOPLEFT", s_EB, "TOPRIGHT", 7, 0)

    -- hex
    hexEB = CreateEB("Hex", 69, 20, false, "rgb")
    AF.SetPoint(hexEB, "TOPLEFT", b_EB, "TOPRIGHT", 7, 0)

    ---------------------------------------------
    -- buttons
    ---------------------------------------------
    confirmBtn = AF.CreateButton(colorPickerFrame, _G.OKAY, "green", 102, 20)
    AF.SetPoint(confirmBtn, "TOPLEFT", h_EB, "BOTTOMLEFT", 0, -7)

    cancelBtn = AF.CreateButton(colorPickerFrame, _G.CANCEL, "red", 102, 20)
    AF.SetPoint(cancelBtn, "TOPLEFT", confirmBtn, "TOPRIGHT", 7, 0)

    ---------------------------------------------
    -- color grids
    ---------------------------------------------
    local sep = AF.CreateSeparator(colorPickerFrame, 269, 1, AF.GetColorTable("disabled", 0.25), true)
    AF.SetPoint(sep, "TOPLEFT", originalPane, "TOPRIGHT", 7, -7)

    local grids = {}

    for i = 1, #preset1 do
        grids[i] = CreateColorGrid(preset1[i])
        if i == 1 then
            AF.SetPoint(grids[i], "TOPLEFT", originalPane, "TOPRIGHT", 14, -1)
        elseif (i-1) % 2 == 0 then
            AF.SetPoint(grids[i], "TOPLEFT", grids[i-2], "BOTTOMLEFT", 0, -2)
        else
            AF.SetPoint(grids[i], "TOPLEFT", grids[i-1], "TOPRIGHT", 2, 0)
        end
    end

    local offset = #preset1
    for i = 1, #preset2 do
        local index = i+offset
        grids[index] = CreateColorGrid(preset2[i])

        if i == 1 then
            AF.SetPoint(grids[index], "TOPLEFT", grids[offset], "BOTTOMLEFT", 0, -7)
        elseif (i-1) % 2 == 0 then
            AF.SetPoint(grids[index], "TOPLEFT", grids[index-2], "BOTTOMLEFT", 0, -2)
        else
            AF.SetPoint(grids[index], "TOPLEFT", grids[index-1], "TOPRIGHT", 2, 0)
        end
    end

    offset = #preset1 + #preset2
    for i = 1, #preset3 do
        local index = i+offset
        grids[index] = CreateColorGrid(preset3[i])

        if i == 1 then
            AF.SetPoint(grids[index], "TOPLEFT", grids[offset], "BOTTOMLEFT", 0, -7)
        elseif (i-1) % 2 == 0 then
            AF.SetPoint(grids[index], "TOPLEFT", grids[index-2], "BOTTOMLEFT", 0, -2)
        else
            AF.SetPoint(grids[index], "TOPLEFT", grids[index-1], "TOPRIGHT", 2, 0)
        end
    end

    ---------------------------------------------
    -- update pixels
    ---------------------------------------------
    colorPickerFrame._UpdatePixels = colorPickerFrame.UpdatePixels
    function colorPickerFrame:UpdatePixels()
        colorPickerFrame:_UpdatePixels()

        -- AF.ReSize(saturationBrightnessPaneBG)
        -- AF.RePoint(saturationBrightnessPaneBG)

        AF.RePoint(saturationBrightnessPane)

        -- brightness slider
        hueSliderHolder:UpdatePixels()
        alphaSliderHolder:UpdatePixels()

        -- update each color section
        for i = 1, 6 do
            hueSlider[i]:SetHeight(hueSlider:GetHeight() / 6)
        end

        -- picker
        AF.ReSize(picker)
    end

    AF.AddToPixelUpdater(colorPickerFrame)
end

-------------------------------------------------
-- show
-------------------------------------------------
function AF.ShowColorPicker(owner, callback, onConfirm, hasAlpha, r, g, b, a)
    if not colorPickerFrame then
        CreateColorPickerFrame()
    end

    colorPickerFrame:SetParent(owner)
    colorPickerFrame:SetFrameStrata("DIALOG")
    colorPickerFrame:SetToplevel(true)

    -- accent color system
    -- colorPickerFrame:SetTitleBackgroundColor(AF.GetColorTable(owner.accentColor, 0.025))
    -- colorPickerFrame:SetTitleColor(owner.accentColor)

    -- clear previous
    hueSlider.prev = nil
    alphaSlider.prev = nil

    -- already shown, restore previous
    if colorPickerFrame:IsShown() then
        if Callback then
            Callback(oR, oG, oB, oA)
        end
    end

    -- backup for restore
    oR, oG, oB, oA = r or 1, g or 1, b or 1, a or 1

    -- data & callback
    H, S, B = AF.ConvertRGBToHSB(oR, oG, oB)
    A = oA
    Callback = callback

    confirmBtn:SetScript("OnClick", function()
        Callback = nil
        colorPickerFrame:Hide()
        local r, g, b = AF.ConvertHSBToRGB(H, S, B)
        onConfirm(r, g, b, A)
    end)

    cancelBtn:SetScript("OnClick", function()
        Callback = nil
        colorPickerFrame:Hide()
        callback(oR, oG, oB, oA)
    end)

    -- update originalPane
    originalPane:SetColor(oR, oG, oB, oA)

    -- update all
    UpdateAll("rgb", oR, oG, oB, oA, true, true)
    AF.SetEnabled(hasAlpha, alphaSlider, aEB, aEB.label2)

    colorPickerFrame:Show()
end

function AF.HideColorPicker()
    if colorPickerFrame then
        colorPickerFrame:Hide()
    end
end