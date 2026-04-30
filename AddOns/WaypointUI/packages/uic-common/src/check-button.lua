local env = select(2, ...)
local Sound = env.modules:Import("packages\\sound")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonCheckButton = env.modules:New("packages\\uic-common\\check-button")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    UICheckButton                    = UICCommonPreload.ATLAS{ left = 4/512, right = 51/512, top = 192/512, bottom = 239/512 },
    UICheckButton_Disabled           = UICCommonPreload.ATLAS{ left = 98/512, right = 145/512, top = 192/512, bottom = 239/512 },
    UICheckButtonChecked             = UICCommonPreload.ATLAS{ left = 51/512, right = 98/512, top = 192/512, bottom = 239/512 },
    UICheckButtonChecked_Disabled    = UICCommonPreload.ATLAS{ left = 145/512, right = 192/512, top = 192/512, bottom = 239/512 }
}

do --Check Button
    local CheckButtonMixin = CreateFromMixins(UICSharedMixin.CheckButtonMixin)

    function CheckButtonMixin:OnLoad()
        self:InitCheckButton()

        self:RegisterMouseEvents()
        self:HookCheck(self.UpdateCheck)
        self:HookMouseUp(self.Toggle)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)

        self:UpdateAnimation()
        self:UpdateCheck()
    end

    function CheckButtonMixin:UpdateAnimation()
        local isChecked = self:GetChecked()
        local isEnabled = self:IsEnabled()

        if isChecked then
            if not isEnabled then
                self:background(UIDEF.UICheckButtonChecked_Disabled)
            else
                self:background(UIDEF.UICheckButtonChecked)
            end
        else
            if not isEnabled then
                self:background(UIDEF.UICheckButton_Disabled)
            else
                self:background(UIDEF.UICheckButton)
            end
        end
    end

    function CheckButtonMixin:UpdateCheck()
        self:UpdateAnimation()
    end

    function CheckButtonMixin:PlayInteractSound()
        local isChecked = self:GetChecked()
        if isChecked then
            Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        else
            Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        end
    end

    UICCommonCheckButton.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name)
            :background(UIDEF.UICheckButton)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        Mixin(frame, CheckButtonMixin)
        frame:OnLoad()

        return frame
    end)
end
