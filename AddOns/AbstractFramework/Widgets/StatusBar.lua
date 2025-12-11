---@class AbstractFramework
local AF = _G.AbstractFramework
local CreateColor = CreateColor

---------------------------------------------------------------------
-- status bar countdown
---------------------------------------------------------------------
---@param bar table
---@param totalTime number
---@param timeRemaining number|nil if nil then countdown will be used
---@param onFinish? fun(self:AF_BlizzardStatusBar|AF_SimpleStatusBar)
function AF.StartStatusBarCountdown(bar, totalTime, timeRemaining, onFinish)
    bar._countdownTime = timeRemaining or totalTime

    bar:SetMinMaxValues(0, totalTime)
    bar:SetValue(bar._countdownTime)

    bar:SetScript("OnUpdate", function(self, elapsed)
        self._countdownTime = self._countdownTime - elapsed
        if self._countdownTime <= 0 then
            self:SetValue(0)
            self:SetScript("OnUpdate", nil)
            if onFinish then onFinish(self) end
        else
            self:SetValue(self._countdownTime)
        end
    end)
end

function AF.StopStatusBarCountdown(bar)
    bar:SetScript("OnUpdate", nil)
end

---------------------------------------------------------------------
-- blizzard
---------------------------------------------------------------------
---@class AF_BlizzardStatusBar:AF_SmoothStatusBar,Frame
local AF_BlizzardStatusBarMixin = {}

function AF_BlizzardStatusBarMixin:SetBarValue(v)
    AF.SetStatusBarValue(self, v)
end

function AF_BlizzardStatusBarMixin:SetMinMaxValues(minValue, maxValue)
    self:_SetMinMaxValues(minValue, maxValue)
    self.minValue = minValue
    self.maxValue = maxValue
end

function AF_BlizzardStatusBarMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    if self.progressText then
        AF.RePoint(self.progressText)
    end
end

---@param minValue number|nil default is 0
---@param maxValue number|nil default is 100
---@param width number|nil
---@param height number|nil
---@param color string|nil default is addon accent color
---@param borderColor string|nil default is border color
---@param progressTextType string|nil "percentage" or "current_value" or "current_max".
---@return AF_BlizzardStatusBar bar
function AF.CreateBlizzardStatusBar(parent, minValue, maxValue, width, height, color, borderColor, progressTextType)
    color = color or AF.GetAddonAccentColorName()
    borderColor = borderColor or "border"

    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    AF.ApplyDefaultBackdropWithColors(bar, AF.GetColorTable(color, 0.9, 0.1), borderColor)
    AF.SetSize(bar, width, height)

    minValue = minValue or 0
    maxValue = maxValue or 100

    bar._SetMinMaxValues = bar.SetMinMaxValues

    Mixin(bar, AF_BaseWidgetMixin)
    Mixin(bar, AF_SmoothStatusBarMixin) -- SetSmoothedValue/ResetSmoothedValue/SetMinMaxSmoothedValue
    Mixin(bar, AF_BlizzardStatusBarMixin)

    bar:SetStatusBarTexture(AF.GetPlainTexture())
    bar:SetStatusBarColor(AF.GetColorRGB(color, 0.7))
    bar:GetStatusBarTexture():SetDrawLayer("BORDER", -7)

    bar.tex = AF.CreateGradientTexture(bar, "HORIZONTAL", "none", AF.GetColorTable(color, 0.2), nil, "BORDER", -6)
    bar.tex:SetBlendMode("ADD")
    bar.tex:SetPoint("TOPLEFT", bar:GetStatusBarTexture())
    bar.tex:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture())

    if progressTextType then
        bar.progressText = AF.CreateFontString(bar)
        AF.SetPoint(bar.progressText, "CENTER")
        if progressTextType == "percentage" then
            bar:SetScript("OnValueChanged", function()
                bar.progressText:SetFormattedText("%d%%", (bar:GetValue()-bar.minValue)/bar.maxValue*100)
            end)
        elseif progressTextType == "current_value" then
            bar:SetScript("OnValueChanged", function()
                bar.progressText:SetFormattedText("%d", bar:GetValue())
            end)
        elseif progressTextType == "current_max" then
            bar:SetScript("OnValueChanged", function()
                bar.progressText:SetFormattedText("%d/%d", bar:GetValue(), bar.maxValue)
            end)
        end
    end

    bar:SetMinMaxValues(minValue, maxValue)
    bar:SetValue(minValue)

    AF.AddToPixelUpdater_OnShow(bar)

    return bar
end

---------------------------------------------------------------------
-- simple
---------------------------------------------------------------------
local ClampedPercentageBetween = AF.ClampedPercentageBetween
local ApproxEqual = AF.ApproxEqual

local function UpdateValue(self)
    self.progress = ClampedPercentageBetween(self.value, self.min, self.max)

    if ApproxEqual(self.progress, 0.0) then
        self.fg.mask:SetWidth(0.00001)
        self.fg:Hide()
    elseif ApproxEqual(self.progress, 1.0) then
        self.fg.mask:SetWidth(self:GetBarWidth())
        self.fg:Show()
    else
        self.fg.mask:SetWidth(self.progress * self:GetBarWidth())
        self.fg:Show()
    end
end

---@class AF_SimpleStatusBar:AF_SmoothStatusBar,Frame
local AF_SimpleStatusBarMixin = {}

---@param texture string
---@param lossTexture string|nil if nil then use texture
---@param wrapModeHorizontal string|nil
---@param wrapModeVertical string|nil
---@param filterMode string|nil
function AF_SimpleStatusBarMixin:SetTexture(texture, lossTexture, wrapModeHorizontal, wrapModeVertical, filterMode)
    self.fg:SetTexture(texture, wrapModeHorizontal, wrapModeVertical, filterMode)
    self.loss:SetTexture(lossTexture or texture, wrapModeHorizontal, wrapModeVertical, filterMode)
end

function AF_SimpleStatusBarMixin:SetColor(r, g, b, a)
    self.fg:SetVertexColor(r, g, b, a)
end

---@param orientation Orientation|nil
---@param ... number|table (r1, g1, b1, a1, r2, g2, b2, a2) or {startColorTable, endColorTable}
function AF_SimpleStatusBarMixin:SetGradientColor(orientation, ...)
    if select("#", ...) == 2 then
        local startColor, endColor = ...
        self.fg:SetGradient(orientation or "HORIZONTAL", CreateColor(AF.UnpackColor(startColor)), CreateColor(AF.UnpackColor(endColor)))
    else
        local r1, g1, b1, a1, r2, g2, b2, a2 = ...
        self.fg:SetGradient(orientation or "HORIZONTAL", CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
    end
end

function AF_SimpleStatusBarMixin:SetLossColor(r, g, b, a)
    self.loss:SetVertexColor(r, g, b, a)
end

----@param orientation Orientation|nil
---@param ... number|table (r1, g1, b1, a1, r2, g2, b2, a2) or {startColorTable, endColorTable}
function AF_SimpleStatusBarMixin:SetGradientLossColor(orientation, ...)
    if select("#", ...) == 2 then
        local startColor, endColor = ...
        self.loss:SetGradient(orientation or "HORIZONTAL", CreateColor(AF.UnpackColor(startColor)), CreateColor(AF.UnpackColor(endColor)))
    else
        local r1, g1, b1, a1, r2, g2, b2, a2 = ...
        self.loss:SetGradient(orientation or "HORIZONTAL", CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
    end
end

function AF_SimpleStatusBarMixin:SetBackgroundColor(r, g, b, a)
    self:SetBackdropColor(r, g, b, a)
end

function AF_SimpleStatusBarMixin:SetBorderColor(r, g, b, a)
    self:SetBackdropBorderColor(r, g, b, a)
end

function AF_SimpleStatusBarMixin:SnapTextureToEdge(noInset)
    self.noInset = noInset
    AF.ClearPoints(self.fg)
    AF.ClearPoints(self.loss)
    if noInset then
        AF.SetPoint(self.bg, "TOPLEFT")
        AF.SetPoint(self.bg, "BOTTOMRIGHT")
        AF.SetPoint(self.fg, "TOPLEFT")
        AF.SetPoint(self.fg, "BOTTOMRIGHT")
        AF.SetPoint(self.fg.mask, "TOPLEFT")
        AF.SetPoint(self.fg.mask, "BOTTOMLEFT")
        AF.SetPoint(self.loss, "TOPLEFT")
        AF.SetPoint(self.loss, "BOTTOMRIGHT")
        AF.SetPoint(self.loss.mask, "TOPRIGHT")
        AF.SetPoint(self.loss.mask, "BOTTOMRIGHT")
    else
        AF.SetPoint(self.bg, "TOPLEFT", 1, -1)
        AF.SetPoint(self.bg, "BOTTOMRIGHT", -1, 1)
        AF.SetPoint(self.fg, "TOPLEFT", 1, -1)
        AF.SetPoint(self.fg, "BOTTOMRIGHT", -1, 1)
        AF.SetPoint(self.fg.mask, "TOPLEFT", 1, -1)
        AF.SetPoint(self.fg.mask, "BOTTOMLEFT", 1, 1)
        AF.SetPoint(self.loss, "TOPLEFT", 1, -1)
        AF.SetPoint(self.loss, "BOTTOMRIGHT", -1, 1)
        AF.SetPoint(self.loss.mask, "TOPRIGHT", -1, -1)
        AF.SetPoint(self.loss.mask, "BOTTOMRIGHT", -1, 1)
    end
    AF.SetPoint(self.loss.mask, "TOPLEFT", self.fg.mask, "TOPRIGHT")
    AF.SetPoint(self.loss.mask, "BOTTOMLEFT", self.fg.mask, "BOTTOMRIGHT")
end

-- smooth
function AF_SimpleStatusBarMixin:SetSmoothing(smoothing)
    self:ResetSmoothedValue()
    if smoothing then
        self.SetBarValue = self.SetSmoothedValue
        self.SetBarMinMaxValues = self.SetMinMaxSmoothedValue
    else
        self.SetBarValue = self.SetValue
        self.SetBarMinMaxValues = self.SetMinMaxValues
    end
end

-- get
function AF_SimpleStatusBarMixin:GetMinMaxValues()
    return self.min, self.max
end

function AF_SimpleStatusBarMixin:GetValue()
    return self.value
end

function AF_SimpleStatusBarMixin:GetRemainingValue()
    return self.max - self.value
end

function AF_SimpleStatusBarMixin:GetBarSize()
    return self.bg:GetSize()
end

function AF_SimpleStatusBarMixin:GetBarWidth()
    return self.bg:GetWidth()
end

function AF_SimpleStatusBarMixin:GetBarHeight()
    return self.bg:GetHeight()
end

-- set
function AF_SimpleStatusBarMixin:SetMinMaxValues(min, max)
    self.min = min
    self.max = max
    UpdateValue(self)
end

function AF_SimpleStatusBarMixin:SetValue(value)
    self.value = value
    UpdateValue(self)
end

-- dim
function AF_SimpleStatusBarMixin:Dim(enabled)
    self.mod:SetShown(enabled)
end

-- pixel perfect
function AF_SimpleStatusBarMixin:DefaultUpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.fg)
    AF.RePoint(self.fg.mask)
    AF.RePoint(self.loss)
    AF.RePoint(self.loss.mask)
end

---@return AF_SimpleStatusBar bar
function AF.CreateSimpleStatusBar(parent, name, noBackdrop)
    local bar = CreateFrame("Frame", name, parent)
    Mixin(bar, AF_BaseWidgetMixin)
    Mixin(bar, AF_SimpleStatusBarMixin)

    if noBackdrop then
        bar.SetBackgroundColor = nil
        bar.SetBorderColor = nil
    else
        AF.ApplyDefaultBackdrop(bar)
    end

    -- default value
    bar.min = 0
    bar.max = 0
    bar.value = 0

    -- smooth
    Mixin(bar, AF_SmoothStatusBarMixin)
    bar:SetSmoothing(false)

    -- foreground texture
    local fg = bar:CreateTexture(nil, "BORDER", nil, -1)
    bar.fg = fg
    fg.mask = bar:CreateMaskTexture()
    fg.mask:SetTexture(AF.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    fg:AddMaskTexture(fg.mask)

    -- already done in PixelUtil
    -- fg:SetTexelSnappingBias(0)
    -- fg:SetSnapToPixelGrid(false)

    -- loss texture
    local loss = bar:CreateTexture(nil, "BORDER", nil, -1)
    bar.loss = loss
    loss.mask = bar:CreateMaskTexture()
    loss.mask:SetTexture(AF.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
    loss:AddMaskTexture(loss.mask)

    -- bg texture NOTE: currently only for GetBarSize/Width/Height
    local bg = bar:CreateTexture(nil, "BORDER", nil, -2)
    bar.bg = bg

    -- dim
    local mod = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    bar.mod = mod
    mod:SetAllPoints(fg.mask)
    mod:SetColorTexture(0.6, 0.6, 0.6)
    mod:SetBlendMode("MOD")
    mod:Hide()

    -- setup default texture points
    bar:SnapTextureToEdge(noBackdrop)

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(bar, bar.DefaultUpdatePixels)

    return bar
end