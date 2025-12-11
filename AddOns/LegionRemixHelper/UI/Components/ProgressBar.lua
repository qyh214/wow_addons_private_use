---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class ProgressBarComponentObject: ProgressBarComponentMixin

local BAR_HEIGHT_SCALE = 18 / 15
local BAR_WIDTH_SCALE = 29 / 15
local BORDER_HEIGHT_SCALE = 31 / 15
local BORDER_WIDTH_SCALE = 35 / 15

local function onEnter(self)
    local obj = self.obj
    local tooltipText = obj:GetTooltipTextGetter() and obj:GetTooltipTextGetter()()
    if not tooltipText then
        tooltipText = obj:GetTooltipText()
        if not tooltipText then return end
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltipText, 1, .8, 0, 1, true)
    GameTooltip:Show()
end

local function onLeave(self)
    GameTooltip:Hide()
end

---@class ProgressBarComponentOptions
---@field frameStrata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field tooltipText string|nil?
---@field tooltipTextGetter (fun():tooltipText:string|nil) | nil
---@field barTexture string|nil?
---@field barColor ColorMixin?
---@field minValue number?
---@field maxValue number?
---@field value number?
---@field labelText string?
---@field backgroundLeftAtlas string|nil?
---@field backgroundCenterAtlas string|nil?
---@field backgroundRightAtlas string|nil?
---@field borderLeftAtlas string|nil?
---@field borderCenterAtlas string|nil?
---@field borderRightAtlas string|nil?
---@field backgroundLeftTexture string|nil?
---@field backgroundCenterTexture string|nil?
---@field backgroundRightTexture string|nil?
---@field borderLeftTexture string|nil?
---@field borderCenterTexture string|nil?
---@field borderRightTexture string|nil?
local defaultOptions = {
    frameStrata = "HIGH",
    width = 215,
    height = 15,
    anchors = {
        { "CENTER" }
    },
    tooltipText = nil,
    tooltipTextGetter = nil,
    barTexture = "Interface/TargetingFrame/UI-StatusBar",
    barColor = CreateColor(1, 1, 0, 1),
    minValue = 0,
    maxValue = 100,
    value = 50,
    labelText = "Progress",
    backgroundLeftAtlas = "widgetstatusbar-bgleft",
    backgroundCenterAtlas = "widgetstatusbar-bgcenter",
    backgroundRightAtlas = "widgetstatusbar-bgright",
    borderLeftAtlas = "widgetstatusbar-borderleft",
    borderCenterAtlas = "widgetstatusbar-bordercenter",
    borderRightAtlas = "widgetstatusbar-borderright",
    backgroundLeftTexture = nil,
    backgroundCenterTexture = nil,
    backgroundRightTexture = nil,
    borderLeftTexture = nil,
    borderCenterTexture = nil,
    borderRightTexture = nil,
}

---@class ProgressBarComponent
---@field defaultOptions ProgressBarComponentOptions
local progressBarComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.ProgressBar = progressBarComponent

local componentsBase = Private.Components.Base

---@class ProgressBarComponentMixin
---@field frame Frame|table
---@field bar StatusBar
---@field backgroundLeft Texture
---@field backgroundCenter Texture
---@field backgroundRight Texture
---@field borderLeft Texture
---@field borderCenter Texture
---@field borderRight Texture
---@field label FontString
---@field tooltipText string|nil
---@field tooltipTextGetter fun():tooltipText:string|nil
local progressBarComponentMixin = {
    frame = nil,
    bar = nil,
    backgroundLeft = nil,
    backgroundCenter = nil,
    backgroundRight = nil,
    borderLeft = nil,
    borderCenter = nil,
    borderRight = nil,
    label = nil,
    tooltipText = nil,
    tooltipTextGetter = nil,
}

---@return string|nil
function progressBarComponentMixin:GetTooltipText()
    return self.tooltipText
end

---@param tooltipText string|nil
function progressBarComponentMixin:SetTooltipText(tooltipText)
    self.tooltipText = tooltipText
end

---@return fun():tooltipText:string|nil tooltipTextGetter
function progressBarComponentMixin:GetTooltipTextGetter()
    return self.tooltipTextGetter
end

---@param getter fun():tooltipText:string|nil
function progressBarComponentMixin:SetTooltipTextGetter(getter)
    self.tooltipTextGetter = getter
end

---@return string
function progressBarComponentMixin:GetLabelText()
    return self.label:GetText()
end

---@param labelText string|nil
function progressBarComponentMixin:SetLabelText(labelText)
    self.label:SetText(labelText or "")
end

---@return number minValue, number maxValue
function progressBarComponentMixin:GetMinMaxValues()
    return self.bar:GetMinMaxValues()
end

---@param min number|nil
---@param max number|nil
function progressBarComponentMixin:SetMinMaxValues(min, max)
    self.bar:SetMinMaxValues(min or 0, max or 100)
end

---@return number value
function progressBarComponentMixin:GetValue()
    return self.bar:GetValue()
end

---@param value number
function progressBarComponentMixin:SetValue(value)
    self.bar:SetValue(value or 0)
end

---@return string|nil leftTexture
---@return string|nil centerTexture
---@return string|nil rightTexture
function progressBarComponentMixin:GetBackgroundTextures()
    return self.backgroundLeft:GetTexture(), self.backgroundCenter:GetTexture(), self.backgroundRight:GetTexture()
end

---@param leftTexture string|nil
---@param centerTexture string|nil
---@param rightTexture string|nil
function progressBarComponentMixin:SetBackgroundTextures(leftTexture, centerTexture, rightTexture)
    if leftTexture then
        self.backgroundLeft:SetTexture(leftTexture)
    end
    if centerTexture then
        self.backgroundCenter:SetTexture(centerTexture)
    end
    if rightTexture then
        self.backgroundRight:SetTexture(rightTexture)
    end
end

---@return string|nil leftTexture
---@return string|nil centerTexture
---@return string|nil rightTexture
function progressBarComponentMixin:GetBorderTextures()
    return self.borderLeft:GetTexture(), self.borderCenter:GetTexture(), self.borderRight:GetTexture()
end

---@param leftTexture string|nil
---@param centerTexture string|nil
---@param rightTexture string|nil
function progressBarComponentMixin:SetBorderTextures(leftTexture, centerTexture, rightTexture)
    if leftTexture then
        self.borderLeft:SetTexture(leftTexture)
    end
    if centerTexture then
        self.borderCenter:SetTexture(centerTexture)
    end
    if rightTexture then
        self.borderRight:SetTexture(rightTexture)
    end
end

---@return string|nil leftAtlas
---@return string|nil centerAtlas
---@return string|nil rightAtlas
function progressBarComponentMixin:GetBackgroundAtlas()
    return self.backgroundLeft:GetAtlas(), self.backgroundCenter:GetAtlas(), self.backgroundRight:GetAtlas()
end

---@param leftAtlas string|nil
---@param centerAtlas string|nil
---@param rightAtlas string|nil
function progressBarComponentMixin:SetBackgroundAtlas(leftAtlas, centerAtlas, rightAtlas)
    if leftAtlas then
        self.backgroundLeft:SetAtlas(leftAtlas)
    end
    if centerAtlas then
        self.backgroundCenter:SetAtlas(centerAtlas)
    end
    if rightAtlas then
        self.backgroundRight:SetAtlas(rightAtlas)
    end
end

---@return string|nil leftAtlas
---@return string|nil centerAtlas
---@return string|nil rightAtlas
function progressBarComponentMixin:GetBorderAtlas()
    return self.borderLeft:GetAtlas(), self.borderCenter:GetAtlas(), self.borderRight:GetAtlas()
end

---@param leftAtlas string|nil
---@param centerAtlas string|nil
---@param rightAtlas string|nil
function progressBarComponentMixin:SetBorderAtlas(leftAtlas, centerAtlas, rightAtlas)
    if leftAtlas then
        self.borderLeft:SetAtlas(leftAtlas)
    end
    if centerAtlas then
        self.borderCenter:SetAtlas(centerAtlas)
    end
    if rightAtlas then
        self.borderRight:SetAtlas(rightAtlas)
    end
end

---@return string|nil barTexture
function progressBarComponentMixin:GetBarTexture()
    return self.bar:GetStatusBarTexture():GetTexture()
end

---@param texture string|nil
function progressBarComponentMixin:SetBarTexture(texture)
    if texture then
        self.bar:SetStatusBarTexture(texture)
    end
end

---@return number red, number green, number blue, number alpha
function progressBarComponentMixin:GetBarColor()
    return self.bar:GetStatusBarColor()
end

---@param red number|nil
---@param green number|nil
---@param blue number|nil
---@param alpha number|nil
function progressBarComponentMixin:SetBarColor(red, green, blue, alpha)
    self.bar:SetStatusBarColor(red or 1, green or 1, blue or 0, alpha or 1)
end

---@param height number|nil
function progressBarComponentMixin:SetTextureSizes(height)
    height = height or self.frame:GetHeight()
    local bgHeight = height * BAR_HEIGHT_SCALE
    local bgWidth = height * BAR_WIDTH_SCALE
    local borHeight = height * BORDER_HEIGHT_SCALE
    local borWidth = height * BORDER_WIDTH_SCALE

    self.backgroundLeft:SetSize(bgWidth, bgHeight)
    self.backgroundCenter:SetHeight(bgHeight)
    self.backgroundRight:SetSize(bgWidth, bgHeight)
    self.borderLeft:SetSize(borWidth, borHeight)
    self.borderCenter:SetHeight(borHeight)
    self.borderRight:SetSize(borWidth, borHeight)
end

---@return number width, number height
function progressBarComponentMixin:GetSize()
    return self.frame:GetSize()
end

---@param width number
---@param height number
function progressBarComponentMixin:SetSize(width, height)
    self.frame:SetSize(width, height)
    self:SetTextureSizes(height)
end

---@param parent Frame?
---@param options ProgressBarComponentOptions
---@return ProgressBarComponentObject sampleFrame
function progressBarComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frameStrata then
        options.frameStrata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata(options.frameStrata)
    frame:SetSize(options.width, options.height)

    for _, anchor in ipairs(options.anchors) do
        frame:SetPoint(unpack(anchor))
    end

    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetAllPoints()

    local backgroundLeft = bar:CreateTexture(nil, "BACKGROUND")
    backgroundLeft:SetPoint("LEFT", -2, 0)

    local backgroundRight = bar:CreateTexture(nil, "BACKGROUND")
    backgroundRight:SetPoint("RIGHT", 2, 0)

    local backgroundCenter = bar:CreateTexture(nil, "BACKGROUND")
    backgroundCenter:SetPoint("TOPLEFT", backgroundLeft, "TOPRIGHT")
    backgroundCenter:SetPoint("BOTTOMRIGHT", backgroundRight, "BOTTOMLEFT")

    local borderLeft = bar:CreateTexture(nil, "OVERLAY")
    borderLeft:SetPoint("LEFT", -8, 0)

    local borderRight = bar:CreateTexture(nil, "OVERLAY")
    borderRight:SetPoint("RIGHT", 8, 0)

    local borderCenter = bar:CreateTexture(nil, "OVERLAY")
    borderCenter:SetPoint("LEFT", borderLeft, "RIGHT")
    borderCenter:SetPoint("RIGHT", borderRight, "LEFT")

    local label = bar:CreateFontString(nil, nil, "GameFontHighlightMedium")
    label:SetPoint("CENTER")
    label:SetJustifyH("LEFT")

    frame:SetScript("OnEnter", onEnter)
    frame:SetScript("OnLeave", onLeave)

    return self:CreateObject(
        frame,
        bar,
        backgroundLeft,
        backgroundCenter,
        backgroundRight,
        borderLeft,
        borderCenter,
        borderRight,
        label,
        options
    )
end

---@param frame Frame|table
---@param bar StatusBar
---@param backgroundLeft Texture
---@param backgroundCenter Texture
---@param backgroundRight Texture
---@param borderLeft Texture
---@param borderCenter Texture
---@param borderRight Texture
---@param label FontString
---@param options ProgressBarComponentOptions
---@return ProgressBarComponentObject
function progressBarComponent:CreateObject(frame, bar, backgroundLeft, backgroundCenter, backgroundRight, borderLeft,
                                           borderCenter, borderRight, label, options)
    local obj = {}
    setmetatable(obj, { __index = progressBarComponentMixin })
    ---@cast obj ProgressBarComponentObject
    frame.obj = obj

    obj.frame = frame
    obj.bar = bar
    obj.backgroundLeft = backgroundLeft
    obj.backgroundCenter = backgroundCenter
    obj.backgroundRight = backgroundRight
    obj.borderLeft = borderLeft
    obj.borderCenter = borderCenter
    obj.borderRight = borderRight
    obj.label = label

    frame.obj = obj

    obj:SetTooltipText(options.tooltipText)
    obj:SetTooltipTextGetter(options.tooltipTextGetter)
    obj:SetBarTexture(options.barTexture)
    obj:SetBarColor(options.barColor:GetRGBA())
    obj:SetMinMaxValues(options.minValue, options.maxValue)
    obj:SetValue(options.value)
    obj:SetLabelText(options.labelText)


    if options.backgroundLeftAtlas or options.backgroundCenterAtlas or options.backgroundRightAtlas then
        obj:SetBackgroundAtlas(options.backgroundLeftAtlas, options.backgroundCenterAtlas, options.backgroundRightAtlas)
    end
    if options.borderLeftAtlas or options.borderCenterAtlas or options.borderRightAtlas then
        obj:SetBorderAtlas(options.borderLeftAtlas, options.borderCenterAtlas, options.borderRightAtlas)
    end
    if options.backgroundLeftTexture or options.backgroundCenterTexture or options.backgroundRightTexture then
        obj:SetBackgroundTextures(options.backgroundLeftTexture, options.backgroundCenterTexture,
            options.backgroundRightTexture)
    end
    if options.borderLeftTexture or options.borderCenterTexture or options.borderRightTexture then
        obj:SetBorderTextures(options.borderLeftTexture, options.borderCenterTexture, options.borderRightTexture)
    end

    obj:SetTextureSizes(options.height)

    return obj
end
