local env                                                                                                                                          = select(2, ...)
local MixinUtil                                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                                         = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                                        = env.WPM:Import("wpm_modules/sound")
local UIKit                                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")
local UICSharedMixin                                                                                                                               = env.WPM:Import("wpm_modules/uic-sharedmixin")
local Utils_Texture                                                                                                                                = env.WPM:Import("wpm_modules/utils/texture")

local Mixin                                                                                                                                        = MixinUtil.Mixin
local CreateFromMixins                                                                                                                             = MixinUtil.CreateFromMixins

local UICCommonCheckButton                                                                                                                           = env.WPM:New("wpm_modules/uic-common/check-button")


-- Shared
--------------------------------

local PATH                           = Path.Root .. "/wpm_modules/uic-common/resources/"
local ATLAS                          = UIKit.Define.Texture_Atlas{ path = PATH .. "check-button.png", inset = 75, scale = 1 }

Utils_Texture.PreloadAsset(PATH .. "check-button.png")


-- Base
--------------------------------

local BACKGROUND                     = ATLAS{ left = 0 / 192, top = 0 / 128, right = 64 / 192, bottom = 64 / 128 }
local BACKGROUND_HIGHLIGHTED         = ATLAS{ left = 64 / 192, top = 0 / 128, right = 128 / 192, bottom = 64 / 128 }
local BACKGROUND_DISABLED            = ATLAS{ left = 128 / 192, top = 0 / 128, right = 192 / 192, bottom = 64 / 128 }
local BACKGROUND_CHECKED             = ATLAS{ left = 0 / 192, top = 64 / 128, right = 64 / 192, bottom = 128 / 128 }
local BACKGROUND_CHECKED_HIGHLIGHTED = ATLAS{ left = 64 / 192, top = 64 / 128, right = 128 / 192, bottom = 128 / 128 }
local BACKGROUND_CHECKED_DISABLED    = ATLAS{ left = 128 / 192, top = 64 / 128, right = 192 / 192, bottom = 128 / 128 }


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
    local chedked = self:GetChecked()
    local highlighted = self:IsHighlighted()
    local enabled = self:IsEnabled()

    if chedked then
        if not enabled then
            self:background(BACKGROUND_CHECKED_DISABLED)
        elseif highlighted then
            self:background(BACKGROUND_CHECKED_HIGHLIGHTED)
        else
            self:background(BACKGROUND_CHECKED)
        end
    else
        if not enabled then
            self:background(BACKGROUND_DISABLED)
        elseif highlighted then
            self:background(BACKGROUND_HIGHLIGHTED)
        else
            self:background(BACKGROUND)
        end
    end
end

function CheckButtonMixin:UpdateCheck()
    self:UpdateAnimation()
end

function CheckButtonMixin:PlayInteractSound()
    local checked = self:GetChecked()
    if checked then
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    else
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end
end


UICCommonCheckButton.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name)
        :background(BACKGROUND)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    Mixin(frame, CheckButtonMixin)
    frame:OnLoad()

    return frame
end)
