local env = select(2, ...)
local Sound = env.modules:Import("packages\\sound")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonScrollBar = env.modules:New("packages\\uic-common\\scroll-bar")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    UIScrollBarTrack             = UICCommonPreload.ATLAS{ inset = 6, scale = 0.3, left = 78/512, right = 90/512, top = 378/512, bottom = 499/512 },
    UIScrollBarThumb             = UICCommonPreload.ATLAS{ inset = 12, left = 4 / 512, right = 28 / 512, top = 376 / 512, bottom = 501 / 512 },
    UIScrollBarThumb_Highlighted = UICCommonPreload.ATLAS{ inset = 12, left = 28 / 512, right = 52 / 512, top = 376 / 512, bottom = 501 / 512 },
    UIScrollBarThumb_Pushed      = UICCommonPreload.ATLAS{ inset = 12, left = 52 / 512, right = 76 / 512, top = 376 / 512, bottom = 501 / 512 }
}

do --Scroll Bar
    local ScrollBarMixin = CreateFromMixins(UICSharedMixin.ScrollBarMixin)

    function ScrollBarMixin:OnLoad()
        self:InitScrollBar()

        self.HitRect:AddOnEnter(function() self:OnEnter() end)
        self.HitRect:AddOnLeave(function() self:OnLeave() end)
        self.HitRect:AddOnMouseDown(function() self:OnMouseDown() end)
        self.HitRect:AddOnMouseUp(function() self:OnMouseUp() end)

        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ScrollBarMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()

        if buttonState == "PUSHED" then
            self.Thumb:background(UIDEF.UIScrollBarThumb_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self.Thumb:background(UIDEF.UIScrollBarThumb_Highlighted)
        else
            self.Thumb:background(UIDEF.UIScrollBarThumb)
        end
    end

    function ScrollBarMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end

    UICCommonScrollBar.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            ScrollBar(name, {
                HitRect(name .. ".HitRect")
                    :id("HitRect", id)
                    :frameLevel(3)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Thumb")
                    :id("Thumb", id)
                    :frameLevel(2)
                    :as("LINEAR_SLIDER_THUMB")
                    :size(UIKit.UI.FILL)
                    :background(UIDEF.UIScrollBarThumb)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Track")
                    :id("Track", id)
                    :frameLevel(1)
                    :as("LINEAR_SLIDER_TRACK")
                    :point(UIKit.Enum.Point.Center)
                    :size(6, UIKit.UI.P_FILL)
                    :background(UIDEF.UIScrollBarTrack)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })

        frame.HitRect = UIKit.GetElementById("HitRect", id)
        frame.Thumb = UIKit.GetElementById("Thumb", id)
        frame.Track = UIKit.GetElementById("Track", id)

        Mixin(frame, ScrollBarMixin)
        frame:OnLoad()

        return frame
    end)
end
