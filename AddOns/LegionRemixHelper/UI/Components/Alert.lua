---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class AlertComponentObject: AlertComponentMixin

---@class AlertComponentOptions
---@field frame_strata FrameStrata?
---@field anchors table?
---@field onClick fun(self: AlertComponentObject, button: string, down: boolean)?
---@field onShow fun(self: AlertComponentObject)?
---@field onHide fun(self: AlertComponentObject)?
---@field title string?
---@field description string?
---@field icon string|number?
local defaultOptions = {
    frame_strata = "TOOLTIP",
    anchors = {
        { "CENTER" }
    },
    onClick = nil,
    onShow = nil,
    onHide = nil,
    title = "Alert Title",
    description = "Alert Description",
    icon = 236293,
}

---@class AlertComponent
---@field defaultOptions AlertComponentOptions
local alertComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.Alert = alertComponent

local componentsBase = Private.Components.Base

---@class AlertComponentMixin
local alertComponentMixin = {
    ---@type FontString
    title = nil,
    ---@type FontString
    desc = nil,
    ---@type Texture
    icon = nil,
    ---@type Frame|table
    frame = nil,
    ---@type nil|fun(self: AlertComponentObject, button: string, down: boolean)
    onClick = nil,
    ---@type nil|fun(self: AlertComponentObject)
    onShow = nil,
    ---@type nil|fun(self: AlertComponentObject)
    onHide = nil,
    ---@type number|nil
    shownTime = nil,
}

---@return string title
function alertComponentMixin:GetTitle()
    return self.title:GetText()
end

---@param title string|nil
function alertComponentMixin:SetTitle(title)
    self.title:SetText(title or "")
end

---@return string description
function alertComponentMixin:GetDescription()
    return self.desc:GetText()
end

---@param description string|nil
function alertComponentMixin:SetDescription(description)
    self.desc:SetText(description or "")
end

---@return string|number|nil iconPath
function alertComponentMixin:GetIcon()
    return self.icon:GetTexture()
end

---@param iconPath string|number|nil
function alertComponentMixin:SetIcon(iconPath)
    self.icon:SetTexture(iconPath)
end

---@return fun(self: AlertComponentObject, button: string, down: boolean)|nil onClick
function alertComponentMixin:GetOnClick()
    return self.onClick
end

---@param onClick fun(self: AlertComponentObject, button: string, down: boolean)|nil
function alertComponentMixin:SetOnClick(onClick)
    self.onClick = onClick
end

---@return fun(self: AlertComponentObject)|nil onShow
function alertComponentMixin:GetOnShow()
    return self.onShow
end

---@param onShow fun(self: AlertComponentObject)|nil
function alertComponentMixin:SetOnShow(onShow)
    self.onShow = onShow
end

---@return fun(self: AlertComponentObject)|nil onHide
function alertComponentMixin:GetOnHide()
    return self.onHide
end

---@param onHide fun(self: AlertComponentObject)|nil
function alertComponentMixin:SetOnHide(onHide)
    self.onHide = onHide
end

---@return number|nil shownTime
function alertComponentMixin:GetShownTime()
    return self.shownTime
end

---@param shownTime number|nil
function alertComponentMixin:SetShownTime(shownTime)
    self.shownTime = shownTime
end

---@param parent Frame?
---@param options AlertComponentOptions
---@return AlertComponentObject sampleFrame
function alertComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    options = componentsBase:MixTables(defaultOptions, options or {})
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata(options.frame_strata)
    frame:SetSize(311, 78)

    for _, anchor in ipairs(options.anchors) do
        frame:SetPoint(unpack(anchor))
    end

    local animInGroup = frame:CreateAnimationGroup()
    local animIn = animInGroup:CreateAnimation("Alpha")
    animIn:SetFromAlpha(1)
    animIn:SetToAlpha(0)
    animIn:SetDuration(0)
    animIn:SetOrder(1)
    local animIn2 = animInGroup:CreateAnimation("Alpha")
    animIn2:SetFromAlpha(0)
    animIn2:SetToAlpha(1)
    animIn2:SetDuration(.2)
    animIn2:SetOrder(2)

    local animOutGroup = frame:CreateAnimationGroup()
    local animOut = animOutGroup:CreateAnimation("Alpha")
    animOut:SetDuration(1.5)
    animOut:SetFromAlpha(1)
    animOut:SetToAlpha(0)
    animOut:SetStartDelay(4.05)
    animOut:SetOrder(1)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAtlas("legioninvasion-Toast-Frame", true)
    background:SetPoint("LEFT")

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Ability_Warlock_DemonicPower")
    icon:SetSize(48, 48)
    icon:SetPoint("LEFT", 15, 0)

    local title = frame:CreateFontString(nil, nil, "GameFontWhiteTiny")
    title:SetPoint("TOP", 28, -22)
    title:SetTextColor(.973, .937, .580)
    title:SetSize(200, 12)

    local desc = frame:CreateFontString(nil, nil, "GameFontHighlight")
    desc:SetPoint("CENTER", frame, "TOP", 28, -46)
    desc:SetSize(200, 0)

    frame:SetScript("OnMouseDown", function(scriptFrame, button, down)
        if button == "RightButton" then
            animInGroup:Stop()
            animOutGroup:Stop()
            scriptFrame:Hide()
            return
        end

        local obj = scriptFrame.obj
        if obj and obj.onClick then
            obj:onClick(button, down)
        end
    end)
    animOut:SetScript("OnFinished", function(scriptFrame)
        scriptFrame:GetRegionParent():Hide()
    end)
    frame:SetScript("OnShow", function()
        animInGroup:Play()
        animOutGroup:Play()

        local obj = frame.obj
        if obj then
            obj:SetShownTime(GetTime())
            if obj.onShow then
                obj:onShow()
            end
        end
    end)
    frame:SetScript("OnEnter", function()
        animOutGroup:Stop()
    end)
    frame:SetScript("OnLeave", function()
        animOut:SetStartDelay(1)
        animOutGroup:Play()
    end)
    frame:SetScript("OnHide", function()
        local obj = frame.obj
        if obj and obj.onHide then
            obj:onHide()
        end
    end)

    return self:CreateObject(frame, icon, title, desc, options)
end

---@param frame table|Frame
---@param icon Texture
---@param title FontString
---@param desc FontString
---@param options AlertComponentOptions
---@return AlertComponentObject
function alertComponent:CreateObject(frame, icon, title, desc, options)
    local obj = {}
    obj.frame = frame
    obj.icon = icon
    obj.title = title
    obj.desc = desc

    setmetatable(obj, { __index = alertComponentMixin })
    ---@cast obj AlertComponentObject

    frame.obj = obj

    obj:SetOnClick(options.onClick)
    obj:SetOnShow(options.onShow)
    obj:SetOnHide(options.onHide)
    obj:SetTitle(options.title)
    obj:SetDescription(options.description)
    obj:SetIcon(options.icon)

    return obj
end
