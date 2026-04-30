local env = select(2, ...)
local GenericEnum = env.modules:Import("packages\\generic-enum")
local Sound = env.modules:Import("packages\\sound")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonRange = env.modules:New("packages\\uic-common\\range")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    UIStepperArrowLeft              = UICCommonPreload.ATLAS{ left = 92/512, right = 117/512, top = 415/512, bottom = 440/512 },
    UIStepperArrowLeft_Highlighted  = UICCommonPreload.ATLAS{ left = 115/512, right = 140/512, top = 415/512, bottom = 440/512 },
    UIStepperArrowLeft_Pushed       = UICCommonPreload.ATLAS{ left = 138/512, right = 163/512, top = 415/512, bottom = 440/512 },
    UIStepperArrowLeft_Disabled     = UICCommonPreload.ATLAS{ left = 161/512, right = 186/512, top = 415/512, bottom = 440/512 },
    UIStepperArrowRight             = UICCommonPreload.ATLAS{ left = 90/512, right = 115/512, top = 446/512, bottom = 471/512 },
    UIStepperArrowRight_Highlighted = UICCommonPreload.ATLAS{ left = 113/512, right = 138/512, top = 446/512, bottom = 471/512 },
    UIStepperArrowRight_Pushed      = UICCommonPreload.ATLAS{ left = 136/512, right = 161/512, top = 446/512, bottom = 471/512 },
    UIStepperArrowRight_Disabled    = UICCommonPreload.ATLAS{ left = 159/512, right = 184/512, top = 446/512, bottom = 471/512 },

    UIRangeTrack                    = UICCommonPreload.ATLAS{ inset = { 15, 15, 13, 13 }, scale = 1, left = 90/512, right = 144/512, top = 474/512, bottom = 499/512 },
    UIRangeThumb                    = UICCommonPreload.ATLAS{ left = 92/512, right = 128/512, top = 376/512, bottom = 412/512 },
    UIRangeThumb_Highlighted        = UICCommonPreload.ATLAS{ left = 128/512, right = 164/512, top = 376/512, bottom = 412/512 },
    UIRangeThumb_Pushed             = UICCommonPreload.ATLAS{ left = 164/512, right = 200/512, top = 376/512, bottom = 412/512 },
    UIRangeThumb_Disabled           = UICCommonPreload.ATLAS{ left = 200/512, right = 236/512, top = 376/512, bottom = 412/512 }
}

do -- Stepper
    local StepperButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function StepperButtonMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local isEnabled = self:IsEnabled()

        if not isEnabled then
            if self.isIncrease then
                self:background(UIDEF.UIStepperArrowRight_Disabled)
            else
                self:background(UIDEF.UIStepperArrowLeft_Disabled)
            end
        elseif buttonState == "PUSHED" then
            if self.isIncrease then
                self:background(UIDEF.UIStepperArrowRight_Pushed)
            else
                self:background(UIDEF.UIStepperArrowLeft_Pushed)
            end
        elseif buttonState == "HIGHLIGHTED" then
            if self.isIncrease then
                self:background(UIDEF.UIStepperArrowRight_Highlighted)
            else
                self:background(UIDEF.UIStepperArrowLeft_Highlighted)
            end
        else
            if self.isIncrease then
                self:background(UIDEF.UIStepperArrowRight)
            else
                self:background(UIDEF.UIStepperArrowLeft)
            end
        end
    end

    function StepperButtonMixin:HandleOnClick()
        local min, max = self.parent.Range:GetMinMaxValues()
        local step = self.parent.Range:GetValueStep()
        local value = self.parent.Range:GetValue()

        if self.isIncrease then
            self.parent.Range:SetValue(math.min(value + step, max))
        else
            self.parent.Range:SetValue(math.max(value - step, min))
        end
    end

    function StepperButtonMixin:OnLoad(isIncrease, parent)
        self:InitButton()
        self.isIncrease = isIncrease
        self.parent = parent

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.HandleOnClick)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function StepperButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.SCROLLBAR_STEP)
    end

    UICCommonRange.StepperButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name)
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        Mixin(frame, StepperButtonMixin)

        return frame
    end)
end

do -- Range
    local THUMB_SIZE = 16
    local STEPPER_SIZE = 16
    local WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 28 }
    local HEIGHT = UIKit.Define.Percentage{ value = 100 }
    local TRACK_SIZE = UIKit.Define.Fill{ delta = 6 }

    local RangeSliderMixin = CreateFromMixins(UICSharedMixin.RangeMixin)

    local function OnEnableChange(self, isEnabled)
        self.parent.ForwardButton:SetEnabled(isEnabled)
        self.parent.BackwardButton:SetEnabled(isEnabled)

        self:UpdateAnimation()
    end

    function RangeSliderMixin:OnLoad(parent)
        self:InitRange()
        self.parent = parent

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(OnEnableChange)
        self:HookMouseDown(self.PlayInteractSound)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function RangeSliderMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local isEnabled = self:IsEnabled()

        if not isEnabled then
            self.parent.RangeThumb:background(UIDEF.UIRangeThumb_Disabled)
        elseif buttonState == "PUSHED" then
            self.parent.RangeThumb:background(UIDEF.UIRangeThumb_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self.parent.RangeThumb:background(UIDEF.UIRangeThumb_Highlighted)
        else
            self.parent.RangeThumb:background(UIDEF.UIRangeThumb)
        end
    end

    function RangeSliderMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    local RangeMixin = {}

    function RangeMixin:GetRange()
        return self.Range
    end

    UICCommonRange.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                LinearSlider(name .. ".Range", {
                    Frame(name .. ".RangeThumb")
                        :id("RangeThumb", id)
                        :frameLevel(2)
                        :as("LINEAR_SLIDER_THUMB")
                        :size(UIKit.UI.FILL)
                        :background(UIDEF.UIRangeThumb)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                    Frame(name .. ".RangeTrack")
                        :id("RangeTrack", id)
                        :frameLevel(1)
                        :as("LINEAR_SLIDER_TRACK")
                        :size(TRACK_SIZE)
                        :background(UIDEF.UIRangeTrack)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                })
                    :id("Range", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(WIDTH, HEIGHT)
                    :linearSliderThumbPropagateMouse(true)
                    :linearSliderThumbSize(THUMB_SIZE, THUMB_SIZE)
                    :linearSliderOrientation(UIKit.Enum.Orientation.Horizontal)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonRange.StepperButton(name .. ".ForwardButton")
                    :id("ForwardButton", id)
                    :point(UIKit.Enum.Point.Right)
                    :size(STEPPER_SIZE, STEPPER_SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonRange.StepperButton(name .. ".BackwardButton")
                    :id("BackwardButton", id)
                    :point(UIKit.Enum.Point.Left)
                    :size(STEPPER_SIZE, STEPPER_SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })

        frame.Range = UIKit.GetElementById("Range", id)
        frame.RangeThumb = UIKit.GetElementById("RangeThumb", id)
        frame.RangeTrack = UIKit.GetElementById("RangeTrack", id)
        frame.ForwardButton = UIKit.GetElementById("ForwardButton", id)
        frame.BackwardButton = UIKit.GetElementById("BackwardButton", id)

        Mixin(frame.Range, RangeSliderMixin)
        Mixin(frame, RangeMixin)
        frame.Range:OnLoad(frame)
        frame.ForwardButton:OnLoad(true, frame)
        frame.BackwardButton:OnLoad(false, frame)

        return frame
    end)
end

do -- Range with Text
    local TEXT_COLOR = GenericEnum.UIColorRGB.NORMAL_FONT_COLOR
    local TEXT_WIDTH = UIKit.Define.Percentage{ value = 34, operator = "-", delta = 5 }
    local RANGE_WIDTH = UIKit.Define.Percentage{ value = 66 }

    local RangeWithTextMixin = {}

    function RangeWithTextMixin:GetRange()
        return self.Range:GetRange()
    end

    function RangeWithTextMixin:SetText(text)
        self.Text:SetText(text)
    end

    function RangeWithTextMixin:GetText()
        return self.Text:GetText()
    end

    UICCommonRange.NewWithText = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :point(UIKit.Enum.Point.Left)
                    :size(TEXT_WIDTH, UIKit.UI.P_FILL)
                    :fontObject(UIFont.UIFontObjectNormal11)
                    :textAlignment("RIGHT", "MIDDLE")
                    :textColor(TEXT_COLOR)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonRange.New(name .. ".Range")
                    :id("Range", id)
                    :point(UIKit.Enum.Point.Right)
                    :size(RANGE_WIDTH, UIKit.UI.P_FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Text = UIKit.GetElementById("Text", id)
        frame.Range = UIKit.GetElementById("Range", id)

        Mixin(frame, RangeWithTextMixin)

        return frame
    end)
end
