local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_LinearSlider = env.modules:New("packages\\ui-kit\\primitives\\linear-slider")

local Mixin = Mixin

local dummy = CreateFrame("Slider"); dummy:Hide()
local Method_Enable = getmetatable(dummy).__index.Enable
local Method_Disable = getmetatable(dummy).__index.Disable
local Method_SetEnabled = getmetatable(dummy).__index.SetEnabled

local LinearSliderMixin = {}

function LinearSliderMixin:GetThumb()
    return self.__Thumb
end

function LinearSliderMixin:GetThumbAnchor()
    return self.__ThumbAnchor
end

function LinearSliderMixin:SetThumbSize(width, height)
    self.__ThumbAnchor:SetSize(width, height)
end

function LinearSliderMixin:OnTrackMouseDown(button)
    self:TriggerEvent("OnTrackMouseDown", button)
end

function LinearSliderMixin:OnTrackMouseUp(button)
    self:TriggerEvent("OnTrackMouseUp", button)
end

function LinearSliderMixin:OnThumbMouseDown(button)
    self:TriggerEvent("OnThumbMouseDown", button)
end

function LinearSliderMixin:OnThumbMouseUp(button)
    self:TriggerEvent("OnThumbMouseUp", button)
end

function LinearSliderMixin:EnableSlider()
    Method_Enable(self)
end

function LinearSliderMixin:DisableSlider()
    Method_Disable(self)
end

function LinearSliderMixin:SetEnabledSlider(enabled)
    Method_SetEnabled(self, enabled)
end

function UIKit_Primitives_LinearSlider.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Slider", name, parent)
    Mixin(frame, LinearSliderMixin)
    frame:SetObeyStepOnDrag(true)

    local thumbAnchor = frame:CreateTexture(name .. ".ThumbAnchor")
    frame:SetThumbTexture(thumbAnchor)

    local thumb = UIKit_Primitives_Frame.New("Frame", name .. ".Thumb", frame)
    thumb:SetPoint("TOPLEFT", thumbAnchor)
    thumb:SetPoint("BOTTOMRIGHT", thumbAnchor)

    frame:AddAlias("LINEAR_SLIDER_THUMB", thumb)
    frame:AddAlias("LINEAR_SLIDER_TRACK", frame)

    frame.__ThumbAnchor = thumbAnchor
    frame.__Thumb = thumb

    frame:HookScript("OnValueChanged", function(_, ...) frame:TriggerEvent("OnValueChanged", ...) end)
    frame:HookScript("OnMinMaxChanged", function(_, ...) frame:TriggerEvent("OnMinMaxChanged", ...) end)
    frame:HookScript("OnMouseDown", function(_, button) frame:OnTrackMouseDown(button) end)
    frame:HookScript("OnMouseUp", function(_, button) frame:OnTrackMouseUp(button) end)
    thumb:HookScript("OnMouseDown", function(_, button) frame:OnThumbMouseDown(button) end)
    thumb:HookScript("OnMouseUp", function(_, button) frame:OnThumbMouseUp(button) end)

    _G[name .. ".ThumbAnchor"] = nil
    return frame
end
