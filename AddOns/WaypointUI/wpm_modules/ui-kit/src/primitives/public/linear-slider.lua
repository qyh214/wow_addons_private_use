local env                           = select(2, ...)
local MixinUtil                     = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                         = MixinUtil.Mixin

local UIKit_Primitives_Frame        = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_LinearSlider = env.WPM:New("wpm_modules/ui-kit/primitives/linear-slider")


-- Shared
--------------------------------

local dummy = CreateFrame("Slider"); dummy:Hide()
local Method_Enable = getmetatable(dummy).__index.Enable
local Method_Disable = getmetatable(dummy).__index.Disable
local Method_SetEnabled = getmetatable(dummy).__index.SetEnabled


-- Linear Slider
--------------------------------

local LinearSliderMixin = {}
do
    -- Accessor
    --------------------------------

    function LinearSliderMixin:GetThumb()
        return self.__Thumb
    end

    function LinearSliderMixin:GetThumbAnchor()
        return self.__ThumbAnchor
    end


    -- Set
    --------------------------------

    function LinearSliderMixin:SetThumbSize(width, height)
        self.__ThumbAnchor:SetSize(width, height)
    end


    -- Thumb
    --------------------------------

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


    -- Override
    --------------------------------

    function LinearSliderMixin:EnableSlider()
        Method_Enable(self)
    end

    function LinearSliderMixin:DisableSlider()
        Method_Disable(self)
    end

    function LinearSliderMixin:SetEnabledSlider(enabled)
        Method_SetEnabled(self, enabled)
    end
end


function UIKit_Primitives_LinearSlider.New(name, parent)
    name = name or "undefined"


    local linearSlider = UIKit_Primitives_Frame.New("Slider", name, parent)
    Mixin(linearSlider, LinearSliderMixin)
    linearSlider:SetObeyStepOnDrag(true)


    -- Thumb Anchor
    --------------------------------

    local thumbAnchor = linearSlider:CreateTexture(name .. ".ThumbAnchor")
    linearSlider:SetThumbTexture(thumbAnchor)


    -- Thumb
    --------------------------------

    local thumb = UIKit_Primitives_Frame.New("Frame", name .. ".Thumb", linearSlider)
    thumb:SetPoint("TOPLEFT", thumbAnchor)
    thumb:SetPoint("BOTTOMRIGHT", thumbAnchor)


    -- Initialize
    --------------------------------

    linearSlider:AddAlias("LINEAR_SLIDER_THUMB", thumb)
    linearSlider:AddAlias("LINEAR_SLIDER_TRACK", linearSlider)

    linearSlider.__ThumbAnchor = thumbAnchor
    linearSlider.__Thumb = thumb


    -- Events
    --------------------------------

    linearSlider:HookScript("OnValueChanged", function(_, ...) linearSlider:TriggerEvent("OnValueChanged", ...) end)
    linearSlider:HookScript("OnMinMaxChanged", function(_, ...) linearSlider:TriggerEvent("OnMinMaxChanged", ...) end)

    linearSlider:HookScript("OnMouseDown", function(_, button) linearSlider:OnTrackMouseDown(button) end)
    linearSlider:HookScript("OnMouseUp", function(_, button) linearSlider:OnTrackMouseUp(button) end)
    thumb:HookScript("OnMouseDown", function(_, button) linearSlider:OnThumbMouseDown(button) end)
    thumb:HookScript("OnMouseUp", function(_, button) linearSlider:OnThumbMouseUp(button) end)


    _G[name .. ".ThumbAnchor"] = nil
    return linearSlider
end
