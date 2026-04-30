local env = select(2, ...)
local Sound = env.modules:Import("packages\\sound")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonButton = env.modules:New("packages\\uic-common\\button")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    Close                           = UICCommonPreload.ATLAS{ left = 319 / 512, right = 345 / 512, top = 185 / 512, bottom = 211 / 512 },
    SelectionMenu                   = UICCommonPreload.ATLAS{ left = 344 / 512, right = 370 / 512, top = 186 / 512, bottom = 212 / 512 },

    UIRedButton                     = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 7 / 512, right = 100 / 512, top = 54 / 512, bottom = 95 / 512 },
    UIRedButton_Highlighted         = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 106 / 512, right = 199 / 512, top = 54 / 512, bottom = 95 / 512 },
    UIRedButton_Pushed              = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 205 / 512, right = 298 / 512, top = 54 / 512, bottom = 95 / 512 },
    UIRedButton_Disabled            = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 304 / 512, right = 397 / 512, top = 54 / 512, bottom = 95 / 512 },
    UIRedButtonCompact              = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 7 / 512, right = 48 / 512, top = 148 / 512, bottom = 189 / 512 },
    UIRedButtonCompact_Highlighted  = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 54 / 512, right = 95 / 512, top = 148 / 512, bottom = 189 / 512 },
    UIRedButtonCompact_Pushed       = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 101 / 512, right = 142 / 512, top = 148 / 512, bottom = 189 / 512 },
    UIRedButtonCompact_Disabled     = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 148 / 512, right = 189 / 512, top = 148 / 512, bottom = 189 / 512 },

    UIGrayButton                    = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 7 / 512, right = 100 / 512, top = 7 / 512, bottom = 48 / 512 },
    UIGrayButton_Highlighted        = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 106 / 512, right = 199 / 512, top = 7 / 512, bottom = 48 / 512 },
    UIGrayButton_Pushed             = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 205 / 512, right = 298 / 512, top = 7 / 512, bottom = 48 / 512 },
    UIGrayButton_Disabled           = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 304 / 512, right = 397 / 512, top = 7 / 512, bottom = 48 / 512 },
    UIGrayButtonCompact             = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 7 / 512, right = 48 / 512, top = 101 / 512, bottom = 142 / 512 },
    UIGrayButtonCompact_Highlighted = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 54 / 512, right = 95 / 512, top = 101 / 512, bottom = 142 / 512 },
    UIGrayButtonCompact_Pushed      = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 101 / 512, right = 142 / 512, top = 101 / 512, bottom = 142 / 512 },
    UIGrayButtonCompact_Disabled    = UICCommonPreload.ATLAS{ inset = 14, scale = 0.7, left = 148 / 512, right = 189 / 512, top = 101 / 512, bottom = 142 / 512 }
}

do --Button
    local CONTENT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 19 }
    local CONTENT_SIZE_SQUARE = UIKit.Define.Percentage{ value = 100 }
    local CONTENT_Y = 0
    local CONTENT_Y_HIGHLIGHTED = 0
    local CONTENT_Y_PRESSED = -1
    local CONTENT_ALPHA_ENABLED = 1
    local CONTENT_ALPHA_DISABLED = 0.5

    local ButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function ButtonMixin:OnLoad(isRed, isCompact)
        self:InitButton()
        self.isRed = isRed
        self.isCompact = isCompact

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ButtonMixin:UpdateAnimation()
        local isEnabled = self:IsEnabled()
        local buttonState = self:GetButtonState()

        if not isEnabled then
            local texture =
                self.isCompact and (self.isRed and UIDEF.UIRedButtonCompact_Disabled or UIDEF.UIGrayButtonCompact_Disabled) or
                (self.isRed and UIDEF.UIRedButton_Disabled or UIDEF.UIGrayButton_Disabled)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
        elseif buttonState == "NORMAL" then
            local texture =
                self.isCompact and (self.isRed and UIDEF.UIRedButtonCompact or UIDEF.UIGrayButtonCompact) or
                (self.isRed and UIDEF.UIRedButton or UIDEF.UIGrayButton)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
        elseif buttonState == "HIGHLIGHTED" then
            local texture =
                self.isCompact and (self.isRed and UIDEF.UIRedButtonCompact_Highlighted or UIDEF.UIGrayButtonCompact_Highlighted) or
                (self.isRed and UIDEF.UIRedButton_Highlighted or UIDEF.UIGrayButton_Highlighted)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_HIGHLIGHTED, CONTENT_Y_HIGHLIGHTED)
        elseif buttonState == "PUSHED" then
            local texture =
                self.isCompact and (self.isRed and UIDEF.UIRedButtonCompact_Pushed or UIDEF.UIGrayButtonCompact_Pushed) or
                (self.isRed and UIDEF.UIRedButton_Pushed or UIDEF.UIGrayButton_Pushed)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_PRESSED, CONTENT_Y_PRESSED)
        end

        self.Content:SetAlpha(isEnabled and CONTENT_ALPHA_ENABLED or CONTENT_ALPHA_DISABLED)
    end

    function ButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    UICCommonButton.RedButton = UIKit.Template(function(id, name, children, ...)
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
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(true)

        return frame
    end)

    UICCommonButton.GrayButton = UIKit.Template(function(id, name, children, ...)
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
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(false)

        return frame
    end)

    UICCommonButton.RedCompactButton = UIKit.Template(function(id, name, children, ...)
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
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(true, true)

        return frame
    end)

    UICCommonButton.GrayCompactButton = UIKit.Template(function(id, name, children, ...)
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
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(false, true)

        return frame
    end)
end

do --Button (Text)
    local RED_TEXT_COLOR = GenericEnum.UIColorRGB.NORMAL_FONT_COLOR
    local RED_TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local GRAY_TEXT_COLOR = UIKit.Define.Color_RGBA{ r = 216, g = 216, b = 216, a = 1 }
    local GRAY_TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }

    local TextButtonMixin = {}

    function TextButtonMixin:TextButton_OnLoad()
        self:HookButtonStateChange(self.TextButton_UpdateAnimation)
    end

    function TextButtonMixin:TextButton_UpdateAnimation()
        local isRed = self.isRed
        local isEnabled = self:IsEnabled()
        local buttonState = self:GetButtonState()

        if not isEnabled then
            self.Text:textColor(GRAY_TEXT_COLOR)
        elseif buttonState == "NORMAL" then
            self.Text:textColor(isRed and RED_TEXT_COLOR or GRAY_TEXT_COLOR)
        elseif buttonState == "HIGHLIGHTED" then
            self.Text:textColor(isRed and RED_TEXT_COLOR_HIGHLIGHTED or GRAY_TEXT_COLOR_HIGHLIGHTED)
        elseif buttonState == "PUSHED" then
            self.Text:textColor(isRed and RED_TEXT_COLOR_HIGHLIGHTED or GRAY_TEXT_COLOR_HIGHLIGHTED)
        end
    end

    function TextButtonMixin:SetText(text)
        self.Text:SetText(text)
    end

    function TextButtonMixin:GetText()
        return self.Text:GetText()
    end

    UICCommonButton.RedTextButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.RedButton(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :textColor(RED_TEXT_COLOR)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })
            :id("Button", id)

        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, TextButtonMixin)
        frame:TextButton_OnLoad()

        return frame
    end)

    UICCommonButton.GrayTextButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.GrayButton(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })

        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, TextButtonMixin)
        frame:TextButton_OnLoad()

        return frame
    end)
end

do --Button (Close)
    local SIZE = UIKit.Define.Percentage{ value = 62 }

    UICCommonButton.RedCloseButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.RedCompactButton(name, {
                Frame(name .. ".Close")
                    :id("Close", id)
                    :point(UIKit.Enum.Point.Center)
                    :background(UIDEF.Close)
                    :size(SIZE, SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })

        frame.Close = UIKit.GetElementById("Close", id)
        frame.CloseTexture = frame.Close:GetTextureFrame()

        return frame
    end)
end

do --Button (Selection Menu)
    local SelectionMenuButtonMixin = CreateFromMixins(UICSharedMixin.SelectionMenuRemoteMixin)

    function SelectionMenuButtonMixin:OnLoad()
        self:InitSelectionMenuRemoteMixin()
    end

    UICCommonButton.SelectionMenuButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.GrayTextButton(name, {
                Frame(name .. ".Arrow")
                    :id("Arrow", id)
                    :point(UIKit.Enum.Point.Right)
                    :background(UIDEF.SelectionMenu)
                    :size(12, 12)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })

        frame.Text:textAlignment("LEFT", "MIDDLE")
        frame.Arrow = UIKit.GetElementById("Arrow", id)

        Mixin(frame, SelectionMenuButtonMixin)
        frame:OnLoad()

        return frame
    end)
end
