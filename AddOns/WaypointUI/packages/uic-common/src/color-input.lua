local env = select(2, ...)
local Sound = env.modules:Import("packages\\sound")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonColorInput = env.modules:New("packages\\uic-common\\color-input")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    UIColorInput              = UICCommonPreload.ATLAS{ inset = 10, scale = 0.7, left = 7/512, right = 100/512, top = 242/512, bottom = 283/512 },
    UIColorInput_Disabled     = UICCommonPreload.ATLAS{ inset = 10, scale = 0.7, left = 106/512, right = 199/512, top = 242/512, bottom = 283/512 },
    UIColorInputFill          = UICCommonPreload.ATLAS{ left = 202/512, right = 292/512, top = 243/512, bottom = 282/512 },
    UIColorInputFill_Pushed   = UICCommonPreload.ATLAS{ left = 292/512, right = 382/512, top = 243/512, bottom = 282/512 },
    UIColorInputFill_Disabled = UICCommonPreload.ATLAS{ left = 382/512, right = 472/512, top = 243/512, bottom = 282/512 }
}

do --Color Input
    local ColorInputMixin = CreateFromMixins(UICSharedMixin.ColorInputMixin)

    function ColorInputMixin:OnLoad()
        self:InitColorInput()

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookColorChange(self.OnColorChange)
        self:HookMouseUp(self.OnClick)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ColorInputMixin:OnColorChange(color)
        self.FillTexture:SetColor(color)
    end

    function ColorInputMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local isEnabled = self:IsEnabled()

        self:background(isEnabled and UIDEF.UIColorInput or UIDEF.UIColorInput_Disabled)
        if not isEnabled then
            self.Fill:background(UIDEF.UIColorInputFill_Disabled)
            return
        end

        if buttonState == "NORMAL" or buttonState == "HIGHLIGHTED" then
            self.Fill:background(UIDEF.UIColorInputFill)
        elseif buttonState == "PUSHED" then
            self.Fill:background(UIDEF.UIColorInputFill_Pushed)
        end
    end

    function ColorInputMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    UICCommonColorInput.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Fill", {
                    unpack(children)
                })
                    :id("Fill", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                    :background(UIKit.UI.TEXTURE_NIL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIDEF.UIColorInput)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Fill = UIKit.GetElementById("Fill", id)
        frame.FillTexture = frame.Fill:GetTextureFrame()

        Mixin(frame, ColorInputMixin)
        frame:OnLoad(true)

        return frame
    end)
end
