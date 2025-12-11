local env                                                                                                                                          = select(2, ...)
local MixinUtil                                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                                         = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                                        = env.WPM:Import("wpm_modules/sound")
local UIFont                                                                                                                                       = env.WPM:Import("wpm_modules/ui-font")
local UIKit                                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")
local UICSharedMixin                                                                                                                               = env.WPM:Import("wpm_modules/uic-sharedmixin")
local GenericEnum                                                                                                                                  = env.WPM:Import("wpm_modules/generic-enum")
local Utils_Texture                                                                                                                                = env.WPM:Import("wpm_modules/utils/texture")

local Mixin                                                                                                                                        = MixinUtil.Mixin
local CreateFromMixins                                                                                                                             = MixinUtil.CreateFromMixins

local UICCommonButton                                                                                                                              = env.WPM:New("wpm_modules/uic-common/button")


-- Shared
--------------------------------

local PATH        = Path.Root .. "/wpm_modules/uic-common/resources/"
local FILL        = UIKit.Define.Fill{}
local ATLAS       = UIKit.Define.Texture_Atlas{ path = PATH .. "button.png", inset = 37, scale = .5 }
local TEXTURE_NIL = UIKit.Define.Texture_NineSlice{ path = nil, inset = 1, scale = 1 }


Utils_Texture.PreloadAsset(PATH .. "button.png")


-- Base
--------------------------------

local CONTENT_SIZE                            = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 19 }
local CONTENT_SIZE_SQUARE                     = UIKit.Define.Percentage{ value = 100 }

local BASE_BACKGROUND_RED                     = ATLAS{ left = 0 / 512, top = 0 / 320, right = 128 / 512, bottom = 64 / 320 }
local BASE_BACKGROUND_RED_HIGHLIGHTED         = ATLAS{ left = 128 / 512, top = 0 / 320, right = 256 / 512, bottom = 64 / 320 }
local BASE_BACKGROUND_RED_PUSHED              = ATLAS{ left = 256 / 512, top = 0 / 320, right = 384 / 512, bottom = 64 / 320 }
local BASE_BACKGROUND_RED_DISABLED            = ATLAS{ left = 384 / 512, top = 0 / 320, right = 512 / 512, bottom = 64 / 320 }
local BASE_BACKGROUND_RED_SQUARE              = ATLAS{ left = 0 / 512, top = 128 / 320, right = 64 / 512, bottom = 192 / 320 }
local BASE_BACKGROUND_RED_SQUARE_HIGHLIGHED   = ATLAS{ left = 64 / 512, top = 128 / 320, right = 128 / 512, bottom = 192 / 320 }
local BASE_BACKGROUND_RED_SQUARE_PUSHED       = ATLAS{ left = 128 / 512, top = 128 / 320, right = 192 / 512, bottom = 192 / 320 }
local BASE_BACKGROUND_RED_SQUARE_DISABLED     = ATLAS{ left = 192 / 512, top = 128 / 320, right = 256 / 512, bottom = 192 / 320 }

local BASE_BACKGROUND_GREY                    = ATLAS{ left = 0 / 512, top = 64 / 320, right = 128 / 512, bottom = 128 / 320 }
local BASE_BACKGROUND_GREY_HIGHLIGHTED        = ATLAS{ left = 128 / 512, top = 64 / 320, right = 256 / 512, bottom = 128 / 320 }
local BASE_BACKGROUND_GREY_PUSHED             = ATLAS{ left = 256 / 512, top = 64 / 320, right = 384 / 512, bottom = 128 / 320 }
local BASE_BACKGROUND_GREY_DISABLED           = ATLAS{ left = 384 / 512, top = 64 / 320, right = 512 / 512, bottom = 128 / 320 }
local BASE_BACKGROUND_GREY_SQUARE             = ATLAS{ left = 0 / 512, top = 192 / 320, right = 64 / 512, bottom = 256 / 320 }
local BASE_BACKGROUND_GREY_SQUARE_HIGHLIGHTED = ATLAS{ left = 64 / 512, top = 192 / 320, right = 128 / 512, bottom = 256 / 320 }
local BASE_BACKGROUND_GREY_SQUARE_PUSHED      = ATLAS{ left = 128 / 512, top = 192 / 320, right = 192 / 512, bottom = 256 / 320 }
local BASE_BACKGROUND_GREY_SQUARE_DISABLED    = ATLAS{ left = 192 / 512, top = 192 / 320, right = 256 / 512, bottom = 256 / 320 }

local CONTENT_Y                               = 0
local CONTENT_Y_HIGHLIGHTED                   = 0
local CONTENT_Y_PRESSED                       = -1
local CONTENT_ALPHA_ENABLED                   = 1
local CONTENT_ALPHA_DISABLED                  = .5


local ButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

function ButtonMixin:OnLoad(isRed, is1x)
    self:InitButton()
    self.isRed = isRed
    self.is1x = is1x

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookEnableChange(self.UpdateAnimation)
    self:HookMouseUp(self.PlayInteractSound)
    self:UpdateAnimation()
end

function ButtonMixin:UpdateAnimation()
    local enabled = self:IsEnabled()
    local buttonState = self:GetButtonState()

    if not enabled then
        local texture =
            self.is1x and (self.isRed and BASE_BACKGROUND_RED_SQUARE_DISABLED or BASE_BACKGROUND_GREY_SQUARE_DISABLED) or
            (self.isRed and BASE_BACKGROUND_RED_DISABLED or BASE_BACKGROUND_GREY_DISABLED)

        self.Texture:background(texture)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
    elseif buttonState == "NORMAL" then
        local texture =
            self.is1x and (self.isRed and BASE_BACKGROUND_RED_SQUARE or BASE_BACKGROUND_GREY_SQUARE) or
            (self.isRed and BASE_BACKGROUND_RED or BASE_BACKGROUND_GREY)

        self.Texture:background(texture)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
    elseif buttonState == "HIGHLIGHTED" then
        local texture =
            self.is1x and (self.isRed and BASE_BACKGROUND_RED_SQUARE_HIGHLIGHED or BASE_BACKGROUND_GREY_SQUARE_HIGHLIGHTED) or
            (self.isRed and BASE_BACKGROUND_RED_HIGHLIGHTED or BASE_BACKGROUND_GREY_HIGHLIGHTED)

        self.Texture:background(texture)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_HIGHLIGHTED, CONTENT_Y_HIGHLIGHTED)
    elseif buttonState == "PUSHED" then
        local texture =
            self.is1x and (self.isRed and BASE_BACKGROUND_RED_SQUARE_PUSHED or BASE_BACKGROUND_GREY_SQUARE_PUSHED) or
            (self.isRed and BASE_BACKGROUND_RED_PUSHED or BASE_BACKGROUND_GREY_PUSHED)

        self.Texture:background(texture)
        self.Content:ClearAllPoints()
        self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_PRESSED, CONTENT_Y_PRESSED)
    end

    self.Content:SetAlpha(enabled and CONTENT_ALPHA_ENABLED or CONTENT_ALPHA_DISABLED)
end

function ButtonMixin:PlayInteractSound()
    Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end


UICCommonButton.RedBase = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :background(TEXTURE_NIL)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Texture = frame:GetBackground()
    frame.Content = UIKit.GetElementById("Content", id)

    Mixin(frame, ButtonMixin)
    frame:OnLoad(true)

    return frame
end)

UICCommonButton.GreyBase = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE, CONTENT_SIZE)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :background(TEXTURE_NIL)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Texture = frame:GetBackground()
    frame.Content = UIKit.GetElementById("Content", id)

    Mixin(frame, ButtonMixin)
    frame:OnLoad(false)

    return frame
end)

UICCommonButton.RedBaseSquare = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE_SQUARE, CONTENT_SIZE_SQUARE)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :background(TEXTURE_NIL)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Texture = frame:GetBackground()
    frame.Content = UIKit.GetElementById("Content", id)

    Mixin(frame, ButtonMixin)
    frame:OnLoad(true, true)

    return frame
end)

UICCommonButton.GreyBaseSquare = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(CONTENT_SIZE_SQUARE, CONTENT_SIZE_SQUARE)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :background(TEXTURE_NIL)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Texture = frame:GetBackground()
    frame.Content = UIKit.GetElementById("Content", id)

    Mixin(frame, ButtonMixin)
    frame:OnLoad(false, true)

    return frame
end)


-- Text
--------------------------------

local VARIANT_RED_TEXT_COLOR              = UIKit.Define.Color_RGBA{ r = GenericEnum.ColorRGB.Yellow.r * 255, g = GenericEnum.ColorRGB.Yellow.g * 255, b = GenericEnum.ColorRGB.Yellow.b * 255, a = 1 }
local VARIANT_RED_TEXT_COLOR_HIGHLIGHTED  = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
local VARIANT_GRAY_TEXT_COLOR             = UIKit.Define.Color_RGBA{ r = 216, g = 216, b = 216, a = 1 }
local VARIANT_GRAY_TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }


local ButtonTextMixin = {}

function ButtonTextMixin:ButtonText_OnLoad()
    self:HookButtonStateChange(self.ButtonText_UpdateAnimation)
end

function ButtonTextMixin:ButtonText_UpdateAnimation()
    local isRed = self.isRed
    local enabled = self:IsEnabled()
    local buttonState = self:GetButtonState()

    if not enabled then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR or VARIANT_GRAY_TEXT_COLOR)
    elseif buttonState == "NORMAL" then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR or VARIANT_GRAY_TEXT_COLOR)
    elseif buttonState == "HIGHLIGHTED" then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR_HIGHLIGHTED or VARIANT_GRAY_TEXT_COLOR_HIGHLIGHTED)
    elseif buttonState == "PUSHED" then
        self.Text:textColor(isRed and VARIANT_RED_TEXT_COLOR_HIGHLIGHTED or VARIANT_GRAY_TEXT_COLOR_HIGHLIGHTED)
    end

end

function ButtonTextMixin:SetText(text)
    self.Text:SetText(text)
end

function ButtonTextMixin:GetText()
    return self.Text:GetText()
end


UICCommonButton.RedWithText = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICCommonButton.RedBase(name, {
            Text(name .. ".Text")
                :id("Text", id)
                :fontObject(UIFont.UIFontObjectNormal12)
                :textColor(VARIANT_RED_TEXT_COLOR)
                :size(FILL)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

            unpack(children)
        })
        :id("Button", id)

    frame.Text = UIKit.GetElementById("Text", id)

    Mixin(frame, ButtonTextMixin)
    frame:ButtonText_OnLoad()

    return frame
end)

UICCommonButton.GreyWithText = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICCommonButton.GreyBase(name, {
            Text(name .. ".Text")
                :id("Text", id)
                :fontObject(UIFont.UIFontObjectNormal12)
                :size(FILL)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

            unpack(children)
        })

    frame.Text = UIKit.GetElementById("Text", id)

    Mixin(frame, ButtonTextMixin)
    frame:ButtonText_OnLoad()

    return frame
end)


-- Close
--------------------------------

local C_TEXTURE = ATLAS{ left = 64 / 512, top = 256 / 320, right = 128 / 512, bottom = 320 / 320 }
local C_SIZE = UIKit.Define.Percentage{ value = 62 }


UICCommonButton.RedClose = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICCommonButton.RedBaseSquare(name, {
            Frame(name .. ".Close")
                :id("Close", id)
                :point(UIKit.Enum.Point.Center)
                :background(C_TEXTURE)
                :size(C_SIZE, C_SIZE)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

            unpack(children)
        })

    frame.Close = UIKit.GetElementById("Close", id)
    frame.CloseTexture = frame.Close:GetBackground()

    return frame
end)


-- Selection Menu
--------------------------------

local SM_ARROW_TEXTURE = ATLAS{ left = 0 / 512, top = 256 / 320, right = 64 / 512, bottom = 320 / 320 }
local SM_ARROW_SIZE    = UIKit.Define.Num{ value = 12 }


local ButtonSelectionMenuMixin = CreateFromMixins(UICSharedMixin.SelectionMenuRemote)

function ButtonSelectionMenuMixin:OnLoad()
    self:InitSelectionMenuRemote()
end


UICCommonButton.SelectionMenu = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICCommonButton.GreyWithText(name, {
            Frame(name .. ".Arrow")
                :id("Arrow", id)
                :point(UIKit.Enum.Point.Right)
                :background(SM_ARROW_TEXTURE)
                :size(SM_ARROW_SIZE, SM_ARROW_SIZE)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

            unpack(children)
        })

    frame.Text:textAlignment("LEFT", "MIDDLE")
    frame.Arrow = UIKit.GetElementById("Arrow", id)

    Mixin(frame, ButtonSelectionMenuMixin)
    frame:OnLoad()

    return frame
end)
