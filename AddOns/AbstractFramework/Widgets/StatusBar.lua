---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- blizzard
---------------------------------------------------------------------
---@class AF_BlizzardStatusBar:AF_SmoothStatusBar
local AF_BlizzardStatusBarMixin = {}

function AF_BlizzardStatusBarMixin:SetBarValue(v)
    AF.SetStatusBarValue(self, v)
end

function AF_BlizzardStatusBarMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    if self.progressText then
        AF.RePoint(self.progressText)
    end
end

---@param color string color name defined in Color.lua
---@param borderColor string color name defined in Color.lua
---@param progressTextType string? "percentage" or "current_value" or "current_max".
---@return AF_BlizzardStatusBar bar
function AF.CreateBlizzardStatusBar(parent, minValue, maxValue, width, height, color, borderColor, progressTextType)
    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    AF.ApplyDefaultBackdropWithColors(bar, AF.GetColorTable(color, 0.9, 0.1), borderColor)
    AF.SetSize(bar, width, height)

    minValue = minValue or 1
    maxValue = maxValue or 1

    bar._SetMinMaxValues = bar.SetMinMaxValues

    hooksecurefunc(bar, "SetMinMaxValues", function(self, l, h)
        self.minValue = l
        self.maxValue = h
    end)

    Mixin(bar, SmoothStatusBarMixin) -- SetSmoothedValue/ResetSmoothedValue/SetMinMaxSmoothedValue
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

    AF.AddToPixelUpdater(bar)

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

---@class AF_SimpleStatusBar:Frame
local AF_SimpleStatusBarMixin = {}
-- appearance
function AF_SimpleStatusBarMixin:SetTexture(texture, lossTexture)
    self.fg:SetTexture(texture)
    self.loss:SetTexture(lossTexture or texture)
end

function AF_SimpleStatusBarMixin:SetColor(r, g, b, a)
    self.fg:SetVertexColor(r, g, b, a)
end

function AF_SimpleStatusBarMixin:SetGradientColor(...)
    if select("#", ...) == 2 then
        local startColor, endColor = ...
        self.fg:SetGradient("HORIZONTAL", CreateColor(AF.UnpackColor(startColor)), CreateColor(AF.UnpackColor(endColor)))
    else
        local r1, g1, b1, a1, r2, g2, b2, a2 = ...
        self.fg:SetGradient("HORIZONTAL", CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
    end
end

function AF_SimpleStatusBarMixin:SetLossColor(r, g, b, a)
    self.loss:SetVertexColor(r, g, b, a)
end

function AF_SimpleStatusBarMixin:SetGradientLossColor(...)
    if select("#", ...) == 2 then
        local startColor, endColor = ...
        self.loss:SetGradient("HORIZONTAL", CreateColor(AF.UnpackColor(startColor)), CreateColor(AF.UnpackColor(endColor)))
    else
        local r1, g1, b1, a1, r2, g2, b2, a2 = ...
        self.loss:SetGradient("HORIZONTAL", CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
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

-- desaturate
function AF_SimpleStatusBarMixin:Desaturate(enabled)
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
    Mixin(bar, AF.SmoothStatusBarMixin)
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

    -- desaturate
    local mod = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    bar.mod = mod
    mod:SetAllPoints(fg.mask)
    mod:SetColorTexture(0.6, 0.6, 0.6)
    mod:SetBlendMode("MOD")
    mod:Hide()

    -- setup default texture points
    bar:SnapTextureToEdge(noBackdrop)

    -- pixel perfect
    AF.AddToPixelUpdater(bar, bar.DefaultUpdatePixels)

    return bar
end