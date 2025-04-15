---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- function
---------------------------------------------------------------------
do
    local f = CreateFrame("Frame")
    AF.FrameSetSize = f.SetSize
    AF.FrameSetHeight = f.SetHeight
    AF.FrameSetWidth = f.SetWidth
    AF.FrameGetSize = f.GetSize
    AF.FrameGetHeight = f.GetHeight
    AF.FrameGetWidth = f.GetWidth
    AF.FrameSetPoint = f.SetPoint
    AF.FrameSetFrameLevel = f.SetFrameLevel
    AF.FrameShow = f.Show
    AF.FrameHide = f.Hide

    local c = CreateFrame("Cooldown")
    AF.FrameSetCooldown = c.SetCooldown
    AF.FrameSetCooldownDuration = c.SetCooldownDuration
end

---------------------------------------------------------------------
-- AF_BaseWidgetMixin
---------------------------------------------------------------------
---@class AF_BaseWidgetMixin
AF_BaseWidgetMixin = {}

function AF_BaseWidgetMixin:SetOnShow(func)
    self:SetScript("OnShow", func)
end

function AF_BaseWidgetMixin:HookOnShow(func)
    self:HookScript("OnShow", func)
end

function AF_BaseWidgetMixin:GetOnShow()
    return function()
        self:GetScript("OnShow")(self)
    end
end

function AF_BaseWidgetMixin:SetOnHide(func)
    self:SetScript("OnHide", func)
end

function AF_BaseWidgetMixin:HookOnHide(func)
    self:HookScript("OnHide", func)
end

function AF_BaseWidgetMixin:GetOnHide()
    return function()
        self:GetScript("OnHide")(self)
    end
end

function AF_BaseWidgetMixin:SetOnEnter(func)
    self:SetScript("OnEnter", func)
end

function AF_BaseWidgetMixin:HookOnEnter(func)
    self:HookScript("OnEnter", func)
end

function AF_BaseWidgetMixin:GetOnEnter()
    return function()
        self:GetScript("OnEnter")(self)
    end
end

function AF_BaseWidgetMixin:SetOnLeave(func)
    self:SetScript("OnLeave", func)
end

function AF_BaseWidgetMixin:HookOnLeave(func)
    self:HookScript("OnLeave", func)
end

function AF_BaseWidgetMixin:GetOnLeave()
    return function()
        self:GetScript("OnLeave")(self)
    end
end

function AF_BaseWidgetMixin:SetOnMouseDown(func)
    self:SetScript("OnMouseDown", func)
end

function AF_BaseWidgetMixin:HookOnMouseDown(func)
    self:HookScript("OnMouseDown", func)
end

function AF_BaseWidgetMixin:GetOnMouseDown()
    return function()
        self:GetScript("OnMouseDown")(self)
    end
end

function AF_BaseWidgetMixin:SetOnMouseUp(func)
    self:SetScript("OnMouseUp", func)
end

function AF_BaseWidgetMixin:HookOnMouseUp(func)
    self:HookScript("OnMouseUp", func)
end

function AF_BaseWidgetMixin:GetOnMouseUp()
    return function()
        self:GetScript("OnMouseUp")(self)
    end
end

function AF_BaseWidgetMixin:SetOnMouseWheel(func)
    self:SetScript("OnMouseWheel", func)
end

function AF_BaseWidgetMixin:HookOnMouseWheel(func)
    self:HookScript("OnMouseWheel", func)
end

function AF_BaseWidgetMixin:GetOnMouseWheel()
    return function()
        self:GetScript("OnMouseWheel")(self)
    end
end

function AF_BaseWidgetMixin:SetOnLoad(func)
    self:SetScript("OnLoad", func)
end

function AF_BaseWidgetMixin:HookOnLoad(func)
    self:HookScript("OnLoad", func)
end

function AF_BaseWidgetMixin:GetOnLoad()
    return function()
        self:GetScript("OnLoad")(self)
    end
end

function AF_BaseWidgetMixin:SetOnEnable(func)
    if self:HasScript("OnEnable") then
        self:SetScript("OnEnable", func)
    end
end

function AF_BaseWidgetMixin:HookOnEnable(func)
    if self:HasScript("OnEnable") then
        self:HookScript("OnEnable", func)
    end
end

function AF_BaseWidgetMixin:GetOnEnable()
    if self:HasScript("OnEnable") then
        return function()
            self:GetScript("OnEnable")(self)
        end
    end
end

function AF_BaseWidgetMixin:SetOnDisable(func)
    if self:HasScript("OnDisable") then
        self:SetScript("OnDisable", func)
    end
end

function AF_BaseWidgetMixin:HookOnDisable(func)
    if self:HasScript("OnDisable") then
        self:HookScript("OnDisable", func)
    end
end

function AF_BaseWidgetMixin:GetOnDisable()
    if self:HasScript("OnDisable") then
        return function()
            self:GetScript("OnDisable")(self)
        end
    end
end

function AF_BaseWidgetMixin:SetOnUpdate(func)
    if self:HasScript("OnUpdate") then
        self:SetScript("OnUpdate", func)
    end
end

function AF_BaseWidgetMixin:HookOnUpdate(func)
    if self:HasScript("OnUpdate") then
        self:HookScript("OnUpdate", func)
    end
end

function AF_BaseWidgetMixin:GetOnUpdate()
    if self:HasScript("OnUpdate") then
        return function()
            self:GetScript("OnUpdate")(self)
        end
    end
end

function AF_BaseWidgetMixin:SetOnSizeChanged(func)
    if self:HasScript("OnSizeChanged") then
        self:SetScript("OnSizeChanged", func)
    end
end

function AF_BaseWidgetMixin:HookOnSizeChanged(func)
    if self:HasScript("OnSizeChanged") then
        self:HookScript("OnSizeChanged", func)
    end
end

function AF_BaseWidgetMixin:GetOnSizeChanged()
    if self:HasScript("OnSizeChanged") then
        return function()
            self:GetScript("OnSizeChanged")(self)
        end
    end
end

function AF_BaseWidgetMixin:SyncEnableDisableWith(frame)
    if not frame then return end
    frame:HookOnEnable(function()
        AF.SetEnabled(true, self)
    end)
    frame:HookOnDisable(function()
        AF.SetEnabled(false, self)
    end)
end

function AF_BaseWidgetMixin:Toggle()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

---------------------------------------------------------------------
-- enable / disable
---------------------------------------------------------------------
function AF.SetEnabled(isEnabled, ...)
    if isEnabled == nil then isEnabled = false end

    for _, w in pairs({...}) do
        if w:IsObjectType("FontString") then
            if isEnabled then
                w:SetTextColor(AF.GetColorRGB("white"))
            else
                w:SetTextColor(AF.GetColorRGB("disabled"))
            end
        elseif w:IsObjectType("Texture") then
            if isEnabled then
                w:SetDesaturated(false)
            else
                w:SetDesaturated(true)
            end
        elseif w.SetEnabled then
            w:SetEnabled(isEnabled)
        elseif isEnabled then
            w:Show()
        else
            w:Hide()
        end
    end
end

function AF.Enable(...)
    AF.SetEnabled(true, ...)
end

function AF.Disable(...)
    AF.SetEnabled(false, ...)
end

---------------------------------------------------------------------
-- frame level relative to parent
---------------------------------------------------------------------
function AF.SetFrameLevel(frame, level, relativeTo)
    if relativeTo then
        frame:SetFrameLevel(AF.Clamp(relativeTo:GetFrameLevel() + level, 0, 10000))
    else
        frame:SetFrameLevel(AF.Clamp(frame:GetParent():GetFrameLevel() + level, 0, 10000))
    end
end

---------------------------------------------------------------------
-- backdrops
---------------------------------------------------------------------
function AF.ApplyDefaultBackdrop(frame, borderSize)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    local n = borderSize or 1
    AF.SetBackdrop(frame, {bgFile = AF.GetPlainTexture(), edgeFile = AF.GetPlainTexture(), edgeSize = n, insets = {left = n, right = n, top = n, bottom = n}})
end

function AF.ApplyDefaultBackdrop_NoBackground(frame, borderSize)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    AF.SetBackdrop(frame, {edgeFile = AF.GetPlainTexture(), edgeSize = borderSize or 1})
end

function AF.ApplyDefaultBackdrop_NoBorder(frame)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    AF.SetBackdrop(frame, {bgFile = AF.GetPlainTexture()})
end

function AF.ApplyDefaultBackdropColors(frame)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    frame:SetBackdropColor(AF.GetColorRGB("background"))
    frame:SetBackdropBorderColor(AF.GetColorRGB("border"))
end

---@param frame Frame
---@param color string|table color name defined in Color.lua or color table
---@param borderColor string|table color name defined in Color.lua or color table
function AF.ApplyDefaultBackdropWithColors(frame, color, borderColor)
    color = color or "background"
    borderColor = borderColor or "border"

    AF.ApplyDefaultBackdrop(frame)
    if type(color) == "string" then
        frame:SetBackdropColor(AF.GetColorRGB(color))
    else
        frame:SetBackdropColor(unpack(color))
    end
    if type(borderColor) == "string" then
        frame:SetBackdropBorderColor(AF.GetColorRGB(borderColor))
    else
        frame:SetBackdropBorderColor(unpack(borderColor))
    end
end

---------------------------------------------------------------------
-- drag
---------------------------------------------------------------------
function AF.SetDraggable(frame, notUserPlaced)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetMouseClickEnabled(true)
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
        if notUserPlaced then self:SetUserPlaced(false) end
    end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end