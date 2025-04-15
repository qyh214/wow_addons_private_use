---@class AbstractFramework
local AF = _G.AbstractFramework

-- NOTE: up to two decimal places value

---------------------------------------------------------------------
-- slider
---------------------------------------------------------------------
---@class AF_Slider:Slider
local AF_SliderMixin = {}

function AF_SliderMixin:GetValue()
    local value = self.value
    return value
end

function AF_SliderMixin:SetValue(value)
    value = AF.RoundToNearestMultiple(value, self.step)
    self.value = value
    self:_SetValue(value)
    self.eb:SetText(value * (self.isPercentage and 100 or 1))
end

function AF_SliderMixin:SetMinMaxValues(minV, maxV)
    assert(minV < maxV, "minV must be less than maxV")
    self:_SetMinMaxValues(minV, maxV)
    self.low = minV
    self.high = maxV
    self.lowText:SetText(minV * (self.isPercentage and 100 or 1) .. self.unit)
    self.highText:SetText(maxV * (self.isPercentage and 100 or 1) .. self.unit)
end

function AF_SliderMixin:SetLabel(text)
    self.label:SetText(text)
end

function AF_SliderMixin:SetLowHighTextShown(show)
    if show then
        self.lowText:Show()
        self.highText:Show()
    else
        self.lowText:Hide()
        self.highText:Hide()
    end
end

function AF_SliderMixin:SetEditBoxShown(show)
    if show then
        self.eb:Show()
    else
        self.eb:Hide()
    end
end

-- OnEnterPressed / dragging
---@param func function
function AF_SliderMixin:SetOnValueChanged(func)
    self.onValueChanged = func
end

-- OnEnterPressed / OnMouseUp
---@param func function
function AF_SliderMixin:SetAfterValueChanged(func)
    self.afterValueChanged = func
end

---@private
function AF_SliderMixin:OnEnter()
    self.thumb:SetColor("accent")
    self.highlight:Show()
    self.valueBeforeClick = self.value
end

---@private
function AF_SliderMixin:OnLeave()
    self.thumb:SetColor(AF.GetColorTable("accent", 0.7))
    self.highlight:Hide()
end

---@private
function AF_SliderMixin:OnDisable()
    self.label:SetColor("disabled")
    self.eb:SetEnabled(false)
    self.thumb:SetColor(AF.GetColorTable("disabled", 0.7))
    self.thumbBG:SetColor(AF.GetColorTable("black", 0.7))
    self.thumbBG2:SetColor(AF.GetColorTable("disabled", 0.25))
    self.lowText:SetColor("disabled")
    self.highText:SetColor("disabled")
    self.percentSign:SetColor("disabled")
    self:SetScript("OnEnter", nil)
    self:SetScript("OnLeave", nil)
    self:SetBackdropBorderColor(AF.GetColorRGB("black", 0.7))
end

---@private
function AF_SliderMixin:OnEnable()
    self.label:SetColor("white")
    self.eb:SetEnabled(true)
    self.thumb:SetColor(AF.GetColorTable("accent", 0.7))
    self.thumbBG:SetColor(AF.GetColorTable("black", 1))
    self.thumbBG2:SetColor(AF.GetColorTable("accent", 0.25))
    self.lowText:SetColor("gray")
    self.highText:SetColor("gray")
    self.percentSign:SetColor("gray")
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
    self:SetBackdropBorderColor(AF.GetColorRGB("black", 1))
end

---@param parent Frame
---@param text string
---@param width number
---@param low number
---@param high number
---@param step number
---@param isPercentage boolean
---@param showLowHighText boolean
---@return AF_Slider slider
function AF.CreateSlider(parent, text, width, low, high, step, isPercentage, showLowHighText)
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    AF.ApplyDefaultBackdropWithColors(slider, "widget")

    slider.isPercentage = isPercentage
    slider.step = step or 1

    slider:SetValueStep(step or 1)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("HORIZONTAL")
    AF.SetSize(slider, width, 10)

    -- label --------------------------------------------------------
    local label = AF.CreateFontString(slider, text)
    slider.label = label
    AF.SetPoint(label, "BOTTOM", slider, "TOP", 0, 2)
    -----------------------------------------------------------------

    -- low ----------------------------------------------------------
    local lowText = AF.CreateFontString(slider, nil, "gray")
    slider.lowText = lowText
    AF.SetPoint(lowText, "TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
    -----------------------------------------------------------------

    -- high ---------------------------------------------------------
    local highText = AF.CreateFontString(slider, nil, "gray")
    slider.highText = highText
    AF.SetPoint(highText, "TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
    -----------------------------------------------------------------

    if not showLowHighText then
        lowText:Hide()
        highText:Hide()
    end

    -- thumb --------------------------------------------------------
    local thumbBG = AF.CreateTexture(slider, nil, AF.GetColorTable("black"), "BACKGROUND", 3)
    slider.thumbBG = thumbBG
    AF.SetSize(thumbBG, 10, 10)
    slider:SetThumbTexture(thumbBG)

    local thumbBG2 =  AF.CreateTexture(slider, nil, AF.GetColorTable("accent", 0.25), "BACKGROUND", 2)
    slider.thumbBG2 = thumbBG2
    AF.SetPoint(thumbBG2, "TOPLEFT", 1, -1)
    AF.SetPoint(thumbBG2, "BOTTOMRIGHT", thumbBG, "BOTTOMLEFT")

    local thumb = AF.CreateTexture(slider, nil, AF.GetColorTable("accent", 0.7), "OVERLAY", 7)
    slider.thumb = thumb
    AF.SetPoint(thumb, "TOPLEFT", thumbBG, 1, -1)
    AF.SetPoint(thumb, "BOTTOMRIGHT", thumbBG, -1, 1)
    -----------------------------------------------------------------

    -- editbox ------------------------------------------------------
    local eb = AF.CreateEditBox(slider, nil, 50, 14)
    slider.eb = eb
    AF.SetPoint(eb, "TOPLEFT", slider, "BOTTOMLEFT", math.ceil(width / 2 - 24), -1)
    eb:SetJustifyH("CENTER")
    eb:SetMode("decimal")

    eb:SetScript("OnEnterPressed", function()
        eb:ClearFocus()
        local value = eb:GetValue()

        if value then
            value = value / (isPercentage and 100 or 1)
            value = AF.RoundToNearestMultiple(value, step)
            value = AF.Clamp(value, slider.low, slider.high)

            if slider.value ~= value then
                if slider.onValueChanged then slider.onValueChanged(value) end
                if slider.afterValueChanged then slider.afterValueChanged(value) end
            end

            slider.value = value
            slider:_SetValue(value) -- update thumb position
            eb:SetText(value * (isPercentage and 100 or 1))
        else
            eb:SetText(slider.value * (isPercentage and 100 or 1))
        end
    end)

    eb:SetScript("OnShow", function(self)
        if slider.value then self:SetText(slider.value * (isPercentage and 100 or 1)) end
    end)
    -----------------------------------------------------------------

    -- percentage ---------------------------------------------------
    local unit = isPercentage and "%" or ""
    slider.unit = unit

    local percentSign = AF.CreateFontString(eb, "%", "gray")
    slider.percentSign = percentSign
    AF.SetPoint(percentSign, "LEFT", eb, "RIGHT", 2, 0)
    if isPercentage then
        percentSign:Show()
    else
        percentSign:Hide()
    end
    -----------------------------------------------------------------

    -- highlight ----------------------------------------------------
    local highlight = AF.CreateTexture(slider, nil, AF.GetColorTable("accent", 0.05), "BACKGROUND", 1)
    slider.highlight = highlight
    AF.SetPoint(highlight, "TOPLEFT", 1, -1)
    AF.SetPoint(highlight, "BOTTOMRIGHT", -1, 1)
    highlight:Hide()
    -----------------------------------------------------------------

    slider._GetValue = slider.GetValue
    slider._SetValue = slider.SetValue
    slider._SetMinMaxValues = slider.SetMinMaxValues

    Mixin(slider, AF_SliderMixin)
    slider:SetMinMaxValues(low, high)

    -- OnEnter ------------------------------------------------------
    slider:SetScript("OnEnter", slider.OnEnter)
    slider:SetScript("OnLeave", slider.OnLeave)
    -----------------------------------------------------------------

    -- OnValueChanged -----------------------------------------------
    slider:SetScript("OnValueChanged", function(self, value, userChanged)
        value = AF.RoundToNearestMultiple(value, step)
        if slider.value == value then return end

        if userChanged then -- IsDraggingThumb()
            slider.value = value
            eb:SetText(value * (isPercentage and 100 or 1))
            if slider.onValueChanged then
                slider.onValueChanged(value)
            end
        end
    end)
    -----------------------------------------------------------------

    -- OnMouseUp ----------------------------------------------------
    slider:SetScript("OnMouseUp", function(self, button, isMouseOver)
        if not slider:IsEnabled() then return end

        -- slider.value here == newValue, OnMouseUp called after OnValueChanged
        if self.valueBeforeClick ~= slider.value and slider.afterValueChanged then
            self.valueBeforeClick = slider.value
            slider.afterValueChanged(slider.value)
        end
    end)
    -----------------------------------------------------------------

    -- REVIEW: OnMouseWheel
    --[[
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(self, delta)
        if not IsShiftKeyDown() then return end

        -- NOTE: OnValueChanged may not be called: value == low
        slider.value = slider.value and slider.value or low

        local value
        if delta == 1 then -- scroll up
            value = slider.value + step
            value = value > high and high or value
        elseif delta == -1 then -- scroll down
            value = slider.value - step
            value = value < low and low or value
        end

        if value ~= slider.value then
            slider:SetValue(value)
            if slider.onValueChanged then slider.onValueChanged(value) end
            if slider.afterValueChanged then slider.afterValueChanged(value) end
        end
    end)
    ]]

    slider:SetScript("OnEnable", slider.OnEnable)
    slider:SetScript("OnDisable", slider.OnDisable)

    slider:SetValue(low)
    AF.AddToPixelUpdater(slider)

    return slider
end

---------------------------------------------------------------------
-- vertical slider
---------------------------------------------------------------------
---@class AF_VerticalSlider:AF_Slider
local AF_VerticalSliderMixin = {}

function AF_VerticalSliderMixin:SetValue(value)
    value = AF.RoundToNearestMultiple(self.high - value + self.low, self.step)
    self.value = value
    self:_SetValue(value)
    self.eb:SetText(value * (self.isPercentage and 100 or 1))
end

-- updates the width of the label and adjusts it dynamically to prevent truncation
---@param wordWrapWidth? number the initial width, defaults to 50
function AF_VerticalSliderMixin:UpdateWordWrap(wordWrapWidth)
    self.label._wordWrapWidth = wordWrapWidth
    self.label:SetWordWrap(true)
    local current = wordWrapWidth or 50
    self:SetScript("OnUpdate", function()
        self.label:SetWidth(current)
        if self.label:IsTruncated() then
            current = current + 5
        else
            self:SetScript("OnUpdate", nil)
        end
    end)
end

local function VerticalSlider_UpdatePixels(self)
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    self:UpdateWordWrap(self.label._wordWrapWidth)
end

---@param parent Frame
---@param text string
---@param height number
---@param low number
---@param high number
---@param step number
---@param isPercentage boolean
---@param showLowHighText boolean
---@return AF_VerticalSlider slider
function AF.CreateVerticalSlider(parent, text, height, low, high, step, isPercentage, showLowHighText)
    local slider = AF.CreateSlider(parent, text, 10, low, high, step, isPercentage, showLowHighText)
    AF.ApplyDefaultBackdropWithColors(slider, "widget")

    slider:SetOrientation("VERTICAL")
    AF.SetHeight(slider, height)

    slider.eb:Hide()
    slider.percentSign:Hide()

    slider.low = low
    slider.high = high
    slider.isPercentage = isPercentage
    slider.step = step

    -- label --------------------------------------------------------
    AF.ClearPoints(slider.label)
    AF.SetPoint(slider.label, "TOP", slider, "BOTTOM", 0, -2)
    -----------------------------------------------------------------

    -- low ----------------------------------------------------------
    AF.ClearPoints(slider.lowText)
    AF.SetPoint(slider.lowText, "TOPLEFT", slider, "TOPRIGHT", 2, 0)
    AF.CreateFadeInOutAnimation(slider.lowText)
    -----------------------------------------------------------------

    -- high ---------------------------------------------------------
    AF.ClearPoints(slider.highText)
    AF.SetPoint(slider.highText, "BOTTOMLEFT", slider, "BOTTOMRIGHT", 2, 0)
    AF.CreateFadeInOutAnimation(slider.highText)
    -----------------------------------------------------------------

    -- thumb --------------------------------------------------------
    AF.ClearPoints(slider.thumbBG2)
    AF.SetPoint(slider.thumbBG2, "TOPLEFT", slider.thumbBG, "BOTTOMLEFT")
    AF.SetPoint(slider.thumbBG2, "BOTTOMRIGHT", -1, 1)

    local thumbText = AF.CreateFontString(slider, nil, "accent")
    AF.SetPoint(thumbText, "RIGHT", slider.thumbBG, "LEFT", -2, 0)
    thumbText:Hide()
    AF.CreateFadeInOutAnimation(thumbText)
    -----------------------------------------------------------------

    Mixin(slider, AF_VerticalSliderMixin)

    -- OnValueChanged -----------------------------------------------
    slider:SetScript("OnValueChanged", function(self, value, userChanged)
        value = AF.RoundToNearestMultiple(self.high - value + self.low, step)
        if slider.value == value then return end

        if userChanged then -- IsDraggingThumb()
            slider.value = value
            if slider.onValueChanged then
                slider.onValueChanged(value)
            end
        end

        if slider:IsDraggingThumb() then
            thumbText:SetText(slider.value .. slider.unit)
        end
    end)
    -----------------------------------------------------------------

    -- OnMouseUp/OnMouseDown ----------------------------------------
    slider:HookScript("OnMouseUp", function(self, button, isMouseOver)
        if not slider:IsEnabled() then return end

        thumbText.fadeOut:Play()
        if showLowHighText then
            slider.lowText.fadeOut:Play()
            slider.highText.fadeOut:Play()
        end
    end)

    slider:SetScript("OnMouseDown", function(self, button, isMouseOver)
        if not slider:IsEnabled() then return end

        thumbText:SetText(slider:GetValue() .. slider.unit)
        thumbText.fadeIn:Play()
        if showLowHighText then
            slider.lowText.fadeIn:Play()
            slider.highText.fadeIn:Play()
        end
    end)
    -----------------------------------------------------------------

    AF.AddToPixelUpdater(slider, VerticalSlider_UpdatePixels)

    return slider
end