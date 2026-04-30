local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonInput = env.modules:New("packages\\uic-common\\input")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    UIInput          = UICCommonPreload.ATLAS{ inset = 10, scale = 0.7, left = 7 / 512, right = 100 / 512, top = 242 / 512, bottom = 283 / 512 },
    UIInput_Disabled = UICCommonPreload.ATLAS{ inset = 10, scale = 0.7, left = 106 / 512, right = 199 / 512, top = 242 / 512, bottom = 283 / 512 },
    UIInputCaret     = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Primitives\\Box" }
}

do --Input
    local TEXT_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local CARET_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local PLACEHOLDER_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 0.5 }
    local HIGHLIGHT_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 0.375 }
    local INPUT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 17.5 }
    local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = 0 }

    local InputMixin = CreateFromMixins(UICSharedMixin.InputMixin)

    function InputMixin:GetInput()
        return self.Input
    end

    function InputMixin:OnLoad()
        self:InitInput()

        self:RegisterMouseEventsWithComponents(self.HitRect, self.Input)
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookFocusChange(self.UpdateAnimation)
        self:UpdateAnimation()
    end

    function InputMixin:UpdateAnimation()
        local focused = self:IsFocused()
        local isEnabled = self:IsEnabled()

        if not isEnabled then
            self.Background:background(UIDEF.UIInput_Disabled)
        elseif focused then
            self.Background:background(UIDEF.UIInput_Highlighted)

            if not self.AnimGroup:IsPlaying(self.Caret, "NORMAL") then
                self.AnimGroup:Play(self.Caret, "NORMAL")
            end
        else
            local buttonState = self:GetButtonState()
            if buttonState == "HIGHLIGHTED" then
                self.Background:background(UIDEF.UIInput_Highlighted)
            else
                self.Background:background(UIDEF.UIInput)
            end
        end
    end

    function InputMixin:SetMultiline(value)
        self.Input:inputMultiLine(value)
    end

    function InputMixin:SetPlaceholder(value)
        self.Input:placeholder(value)
    end

    InputMixin.AnimGroup = UIAnim.New()
    do
        local Blink = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.1):from(0):to(1):loop(UIAnim.Enum.Looping.Yoyo):loopDelayEnd(0.5)
        InputMixin.AnimGroup:State("NORMAL", function(frame)
            Blink:Play(frame)
        end)
    end

    UICCommonInput.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                HitRect(name .. ".HitRect")
                    :id("HitRect", id)
                    :frameLevel(5)
                    :size(UIKit.UI.FILL)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Background")
                    :id("Background", id)
                    :frameLevel(1)
                    :size(BACKGROUND_SIZE)
                    :background(UIDEF.UIInput)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Input(name .. ".Input", {
                    Frame(name .. ".Caret")
                        :id("Caret", id)
                        :as("INPUT_CARET")
                        :frameLevel(3)
                        :size(UIKit.UI.FILL)
                        :background(UIDEF.UIInputCaret)
                        :backgroundColor(CARET_COLOR)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                })
                    :id("Input", id)
                    :frameLevel(2)
                    :point(UIKit.Enum.Point.Center)
                    :size(INPUT_SIZE, UIKit.UI.FIT)
                    :fontObject(UIFont.UIFontObjectNormal10)
                    :textColor(TEXT_COLOR)
                    :inputPlaceholderFont(UIFont.UIFontNormal)
                    :inputPlaceholderFontSize(11)
                    :inputPlaceholderTextColor(PLACEHOLDER_COLOR)
                    :inputMultiLine(false)
                    :inputHighlightColor(HIGHLIGHT_COLOR)
                    :inputCaretWidth(2)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :enableMouse(true)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.HitRect = UIKit.GetElementById("HitRect", id)
        frame.Background = UIKit.GetElementById("Background", id)
        frame.Input = UIKit.GetElementById("Input", id)
        frame.Caret = UIKit.GetElementById("Caret", id)

        Mixin(frame, InputMixin)
        frame:OnLoad()

        return frame
    end)
end
