local env                                                                                                                          = select(2, ...)
local MixinUtil                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                         = env.WPM:Import("wpm_modules/path")
local GenericEnum                                                                                                                  = env.WPM:Import("wpm_modules/generic-enum")
local UIKit                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, LayoutVertical, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.LayoutVertical, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")

local Mixin                                                                                                                        = MixinUtil.Mixin

local Waypoint_Templates                                                                                                           = env.WPM:New("@/Waypoint/Templates")


-- Shared
--------------------------------

local PATH        = Path.Root .. "/Art/Waypoint/"
local ATLAS       = UIKit.Define.Texture_Atlas{ path = PATH .. "WaypointUITextureAtlas.png" }
local FIT         = UIKit.Define.Fit{}

local TEXTURE_NIL = UIKit.Define.Texture{ path = nil }


-- Pinpoint Arrow
--------------------------------

local PA_ARROW_BACKGROUND = ATLAS{ left = 512 / 1792, right = 768 / 1792, top = 0 / 2560, bottom = 256 / 2560 }
local PA_ARROW_SIZE       = UIKit.Define.Num{ value = 15 }


local PAAnimation = UIAnim.New()
local PAAnimation_Arrow1Intro = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :duration(.5)
    :loopDelayEnd(1.25)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(0)
    :to(1)
local PAAnimation_Arrow1Translate = UIAnim.Animate()
    :property(UIAnim.Enum.Property.PosY)
    :duration(1.75)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(7.5)
    :to(-7.5)
local PAAnimation_Arrow1Outro = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :duration(.5)
    :loopDelayStart(1.25)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(1)
    :to(0)
local PAAnimation_Arrow2Intro = UIAnim.Animate()
    :wait(.25)

    :property(UIAnim.Enum.Property.Alpha)
    :duration(.5)
    :loopDelayEnd(1.25)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(0)
    :to(1)
local PAAnimation_Arrow2Translate = UIAnim.Animate()
    :wait(.25)

    :property(UIAnim.Enum.Property.PosY)
    :duration(1.75)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(7.5)
    :to(-7.5)
local PAAnimation_Arrow2Outro = UIAnim.Animate()
    :wait(.25)

    :property(UIAnim.Enum.Property.Alpha)
    :duration(.5)
    :loopDelayStart(1.25)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(1)
    :to(0)
local PAAnimation_Arrow3Intro = UIAnim.Animate()
    :wait(.5)

    :property(UIAnim.Enum.Property.Alpha)
    :duration(.5)
    :loopDelayEnd(1.25)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(0)
    :to(1)
local PAAnimation_Arrow3Translate = UIAnim.Animate()
    :wait(.5)

    :property(UIAnim.Enum.Property.PosY)
    :duration(1.75)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(7.5)
    :to(-7.5)
local PAAnimation_Arrow3Outro = UIAnim.Animate()
    :wait(.5)

    :property(UIAnim.Enum.Property.Alpha)
    :duration(.5)
    :loopDelayStart(1.25)
    :loop(UIAnim.Enum.Looping.Reset)
    :easing(UIAnim.Enum.Easing.Linear)
    :from(1)
    :to(0)

PAAnimation:State("NORMAL", function(frame)
    frame.Arrow1Texture:SetAlpha(0)
    frame.Arrow2Texture:SetAlpha(0)
    frame.Arrow3Texture:SetAlpha(0)

    PAAnimation_Arrow1Intro:Play(frame.Arrow1Texture)
    PAAnimation_Arrow1Translate:Play(frame.Arrow1Texture)
    PAAnimation_Arrow1Outro:Play(frame.Arrow1Texture)

    PAAnimation_Arrow2Intro:Play(frame.Arrow2Texture)
    PAAnimation_Arrow2Translate:Play(frame.Arrow2Texture)
    PAAnimation_Arrow2Outro:Play(frame.Arrow2Texture)

    PAAnimation_Arrow3Intro:Play(frame.Arrow3Texture)
    PAAnimation_Arrow3Translate:Play(frame.Arrow3Texture)
    PAAnimation_Arrow3Outro:Play(frame.Arrow3Texture)
end)


local PinpointArrowMixin = {}

function PinpointArrowMixin:Play()
    PAAnimation:Play(self, "NORMAL")
end

function PinpointArrowMixin:Stop()
    PAAnimation:Stop(self)
end

function PinpointArrowMixin:SetTint(color)
    self.Arrow1TextureBackground:SetColor(color)
    self.Arrow2TextureBackground:SetColor(color)
    self.Arrow3TextureBackground:SetColor(color)
end


Waypoint_Templates.PinpointArrow = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            LayoutVertical(name .. "LayoutVertical", {
                Frame(name .. "Arrow1", {
                    Frame(name .. "Arrow1Texture", {

                    })
                        :id("Arrow1Texture", id)
                        :background(PA_ARROW_BACKGROUND)
                        :point(UIKit.Enum.Point.Center)
                        :size(PA_ARROW_SIZE, PA_ARROW_SIZE)
                        :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                        :frameLevel(1)

                })
                    :id("Arrow1", id)
                    :size(PA_ARROW_SIZE, PA_ARROW_SIZE)
                    :frameLevel(1),

                Frame(name .. "Arrow2", {
                    Frame(name .. "Arrow2Texture", {

                    })
                        :id("Arrow2Texture", id)
                        :background(PA_ARROW_BACKGROUND)
                        :point(UIKit.Enum.Point.Center)
                        :size(PA_ARROW_SIZE, PA_ARROW_SIZE)
                        :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                        :frameLevel(1)

                })
                    :id("Arrow2", id)
                    :size(PA_ARROW_SIZE, PA_ARROW_SIZE)
                    :frameLevel(1),

                Frame(name .. "Arrow3", {
                    Frame(name .. "Arrow3Texture", {

                    })
                        :id("Arrow3Texture", id)
                        :background(PA_ARROW_BACKGROUND)
                        :point(UIKit.Enum.Point.Center)
                        :size(PA_ARROW_SIZE, PA_ARROW_SIZE)
                        :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                        :frameLevel(1)

                })
                    :id("Arrow3", id)
                    :size(PA_ARROW_SIZE, PA_ARROW_SIZE)
                    :frameLevel(1)
            })
                :point(UIKit.Enum.Point.Center)
                :size(FIT, FIT)
                :layoutSpacing(UIKit.Define.Num{ value = -5 })
        })

    frame.Arrow1 = UIKit.GetElementById("Arrow1", id)
    frame.Arrow2 = UIKit.GetElementById("Arrow2", id)
    frame.Arrow3 = UIKit.GetElementById("Arrow3", id)

    frame.Arrow1Texture = UIKit.GetElementById("Arrow1Texture", id)
    frame.Arrow2Texture = UIKit.GetElementById("Arrow2Texture", id)
    frame.Arrow3Texture = UIKit.GetElementById("Arrow3Texture", id)
    frame.Arrow1TextureBackground = frame.Arrow1Texture:GetBackground()
    frame.Arrow2TextureBackground = frame.Arrow2Texture:GetBackground()
    frame.Arrow3TextureBackground = frame.Arrow3Texture:GetBackground()

    Mixin(frame, PinpointArrowMixin)
    return frame
end)


-- Context Icon
--------------------------------

local CI_FOREGROUND_TEXTURE = ATLAS{ left = 0 / 1792, right = 256 / 1792, top = 256 / 2560, bottom = 512 / 2560 }
local CI_BACKGROUND_SIZE    = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 12.5 }
local CI_CONTENT_SIZE       = UIKit.Define.Percentage{ value = 32.5 }


local ContextIconMixin     = {}
ContextIconMixin.tintColor = nil

function ContextIconMixin:SetIcon(texture)
    self.ImageTexture:SetTexture(texture)
end

function ContextIconMixin:SetAtlas(atlas)
    self.ImageTexture:SetAtlas(atlas)
end

function ContextIconMixin:SetOpacity(opacity)
    self.Content:SetAlpha(opacity)
end

function ContextIconMixin:SetTint(color)
    self.tintColor = color
    self.BackgroundTexture:SetColor(color)
end

function ContextIconMixin:Recolor()
    self.ImageTexture:SetDesaturated(true)
    self.ImageTexture:SetColor(self.tintColor)
end

function ContextIconMixin:Decolor()
    self.ImageTexture:SetDesaturated(false)
    self.ImageTexture:SetColor(GenericEnum.ColorRGB.White)
end

function ContextIconMixin:SetInfo(ContextIconTexture)
    if ContextIconTexture.type == "ATLAS" then
        self:SetAtlas(ContextIconTexture.path)
    else
        self:SetIcon(ContextIconTexture.path)
    end
end


Waypoint_Templates.ContextIcon = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. "Background", {

            })
                :id("BackgroundTexture", id)
                :point(UIKit.Enum.Point.Center)
                :size(CI_BACKGROUND_SIZE, CI_BACKGROUND_SIZE)
                :background(CI_FOREGROUND_TEXTURE)
                :frameLevel(2),

            Frame(name .. "Image")
                :id("Image", id)
                :point(UIKit.Enum.Point.Center)
                :background(TEXTURE_NIL)
                :frameLevel(3)
                :size(CI_CONTENT_SIZE, CI_CONTENT_SIZE)
        })

    frame.BackgroundTexture = UIKit.GetElementById("BackgroundTexture", id):GetBackground()
    frame.ImageTexture = UIKit.GetElementById("Image", id):GetBackground()

    Mixin(frame, ContextIconMixin)
    return frame
end)
