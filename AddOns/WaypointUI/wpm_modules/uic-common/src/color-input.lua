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

local UICCommonColorInput                                                                                                                            = env.WPM:New("wpm_modules/uic-common/color-input")


-- Shared
--------------------------------

local PATH        = Path.Root .. "/wpm_modules/uic-common/resources/"
local ATLAS       = UIKit.Define.Texture_Atlas{ path = PATH .. "color-input.png", inset = 37, scale = .5 }
local TEXTURE_NIL = UIKit.Define.Texture_NineSlice{ path = nil, inset = 1, scale = 1 }

Utils_Texture.PreloadAsset(PATH .. "color-input.png")


-- Base
--------------------------------

local CONTENT_SIZE                = UIKit.Define.Percentage{ value = 100 }

local BACKGROUND_FRAME            = ATLAS{ left = 0 / 384, right = 128 / 384, top = 0 / 128, bottom = 64 / 128 }
local BACKGROUND_FRAME_DISABLED   = ATLAS{ left = 256 / 384, right = 384 / 384, top = 0 / 128, bottom = 64 / 128 }
local BACKGROUND_FILL             = ATLAS{ left = 0 / 384, right = 128 / 384, top = 64 / 128, bottom = 128 / 128 }
local BACKGROUND_FILL_PUSHED      = ATLAS{ left = 128 / 384, right = 256 / 384, top = 64 / 128, bottom = 128 / 128 }
local BACKGROUND_FILL_DISABLED    = ATLAS{ left = 256 / 384, right = 384 / 384, top = 64 / 128, bottom = 128 / 128 }


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
    local enabled = self:IsEnabled()

    self:background(enabled and BACKGROUND_FRAME or BACKGROUND_FRAME_DISABLED)
    if not enabled then
        self.Fill:background(BACKGROUND_FILL_DISABLED)
        return
    end

    if buttonState == "NORMAL" or buttonState == "HIGHLIGHTED" then
        self.Fill:background(BACKGROUND_FILL)
    elseif buttonState == "PUSHED" then
        self.Fill:background(BACKGROUND_FILL_PUSHED)
    end
end

function ColorInputMixin:PlayInteractSound()
    Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end


UICCommonColorInput.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Fill", {
                unpack(children)
            })
                :id("Fill", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
                :background(TEXTURE_NIL)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :background(BACKGROUND_FRAME)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Texture = frame:GetBackground()
    frame.Fill = UIKit.GetElementById("Fill", id)
    frame.FillTexture = frame.Fill:GetBackground()

    Mixin(frame, ColorInputMixin)
    frame:OnLoad(true)

    return frame
end)
