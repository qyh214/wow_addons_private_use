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

local UICCommonScrollBar                                                                                                                             = env.WPM:New("wpm_modules/uic-common/scroll-bar")


-- Shared
--------------------------------

local PATH                         = Path.Root .. "/wpm_modules/uic-common/resources/"
local FILL                         = UIKit.Define.Fill{}
local ATLAS                        = UIKit.Define.Texture_Atlas{ path = PATH .. "scroll-bar.png" }
local BACKGROUND                   = ATLAS{ inset = 32, scale = 1, left = 0 / 320, right = 64 / 320, top = 0 / 128, bottom = 128 / 128 }
local BACKGROUND_THUMB             = ATLAS{ inset = 32, scale = 1, left = 64 / 320, right = 128 / 320, top = 0 / 128, bottom = 64 / 128 }
local BACKGROUND_THUMB_HIGHLIGHTED = ATLAS{ inset = 32, scale = 1, left = 128 / 320, right = 192 / 320, top = 0 / 128, bottom = 64 / 128 }
local BACKGROUND_THUMB_PUSHED      = ATLAS{ inset = 32, scale = 1, left = 192 / 320, right = 256 / 320, top = 0 / 128, bottom = 64 / 128 }
local BACKGROUND_THUMB_DISABLED    = ATLAS{ inset = 32, scale = 1, left = 256 / 320, right = 320 / 320, top = 0 / 128, bottom = 64 / 128 }

Utils_Texture.PreloadAsset(PATH .. "scroll-bar.png")


-- Scroll Bar
--------------------------------

local ScrollBarMixin = CreateFromMixins(UICSharedMixin.ScrollBarMixin)

function ScrollBarMixin:OnLoad()
    self:InitScrollBar()

    self.Hitbox:AddOnEnter(function() self:OnEnter() end)
    self.Hitbox:AddOnLeave(function() self:OnLeave() end)
    self.Hitbox:AddOnMouseDown(function() self:OnMouseDown() end)
    self.Hitbox:AddOnMouseUp(function() self:OnMouseUp() end)

    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookEnableChange(self.UpdateAnimation)
    self:HookMouseUp(self.PlayInteractSound)
    self:UpdateAnimation()
end

function ScrollBarMixin:UpdateAnimation()
    local buttonState = self:GetButtonState()
    local enabled = self:IsEnabled()

    if not enabled then
        self.Thumb:background(BACKGROUND_THUMB_DISABLED)
    elseif buttonState == "PUSHED" then
        self.Thumb:background(BACKGROUND_THUMB_PUSHED)
    elseif buttonState == "HIGHLIGHTED" then
        self.Thumb:background(BACKGROUND_THUMB_HIGHLIGHTED)
    else
        self.Thumb:background(BACKGROUND_THUMB)
    end
end

function ScrollBarMixin:PlayInteractSound()
    Sound.PlaySound("UI", SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end


UICCommonScrollBar.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        ScrollBar(name, {
            InteractiveRect(name .. ".Hitbox")
                :id("Hitbox", id)
                :frameLevel(3)
                :size(FILL)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

            Frame(name .. ".Thumb")
                :id("Thumb", id)
                :frameLevel(2)
                :under("LINEAR_SLIDER_THUMB")
                :size(FILL)
                :background(BACKGROUND_THUMB)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

            Frame(name .. ".Track")
                :id("Track", id)
                :frameLevel(1)
                :under("LINEAR_SLIDER_TRACK")
                :size(FILL)
                :background(BACKGROUND)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })

    frame.Hitbox = UIKit.GetElementById("Hitbox", id)
    frame.Thumb = UIKit.GetElementById("Thumb", id)
    frame.Track = UIKit.GetElementById("Track", id)

    Mixin(frame, ScrollBarMixin)
    frame:OnLoad()

    return frame
end)
