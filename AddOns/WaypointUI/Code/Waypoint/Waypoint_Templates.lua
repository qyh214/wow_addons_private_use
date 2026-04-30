local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local Waypoint_Preload = env.modules:Import("@\\Waypoint\\Preload")
local Waypoint_Templates = env.modules:New("@\\Waypoint\\Templates")

local Mixin = Mixin

do -- Pinpoint Arrow
    local ARROW_SIZE = 15

    local PinpointArrowMixin = {}

    function PinpointArrowMixin:Play()
        self.AnimGroup:Play(self, "NORMAL")
    end

    function PinpointArrowMixin:Stop()
        self.AnimGroup:Stop(self)
    end

    function PinpointArrowMixin:SetTint(color)
        self.Arrow1TextureBackground:SetColor(color)
        self.Arrow2TextureBackground:SetColor(color)
        self.Arrow3TextureBackground:SetColor(color)
    end

    PinpointArrowMixin.AnimGroup = UIAnim.New()
    do
        local Arrow1Intro = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.5):loopDelayEnd(1.25):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(0):to(1)
        local Arrow1Translate = UIAnim.Animate():property(UIAnim.Enum.Property.PosY):duration(1.75):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(7.5):to(-7.5)
        local Arrow1Outro = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.5):loopDelayStart(1.25):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(1):to(0)
        local Arrow2Intro = UIAnim.Animate():wait(0.25):property(UIAnim.Enum.Property.Alpha):duration(0.5):loopDelayEnd(1.25):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(0):to(1)
        local Arrow2Translate = UIAnim.Animate():wait(0.25):property(UIAnim.Enum.Property.PosY):duration(1.75):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(7.5):to(-7.5)
        local Arrow2Outro = UIAnim.Animate():wait(0.25):property(UIAnim.Enum.Property.Alpha):duration(0.5):loopDelayStart(1.25):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(1):to(0)
        local Arrow3Intro = UIAnim.Animate():wait(0.5):property(UIAnim.Enum.Property.Alpha):duration(0.5):loopDelayEnd(1.25):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(0):to(1)
        local Arrow3Translate = UIAnim.Animate():wait(0.5):property(UIAnim.Enum.Property.PosY):duration(1.75):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(7.5):to(-7.5)
        local Arrow3Outro = UIAnim.Animate():wait(0.5):property(UIAnim.Enum.Property.Alpha):duration(0.5):loopDelayStart(1.25):loop(UIAnim.Enum.Looping.Reset):easing(UIAnim.Enum.Easing.Linear):from(1):to(0)
        PinpointArrowMixin.AnimGroup:State("NORMAL", function(frame)
            frame.Arrow1Texture:SetAlpha(0)
            frame.Arrow2Texture:SetAlpha(0)
            frame.Arrow3Texture:SetAlpha(0)

            Arrow1Intro:Play(frame.Arrow1Texture)
            Arrow1Translate:Play(frame.Arrow1Texture)
            Arrow1Outro:Play(frame.Arrow1Texture)

            Arrow2Intro:Play(frame.Arrow2Texture)
            Arrow2Translate:Play(frame.Arrow2Texture)
            Arrow2Outro:Play(frame.Arrow2Texture)

            Arrow3Intro:Play(frame.Arrow3Texture)
            Arrow3Translate:Play(frame.Arrow3Texture)
            Arrow3Outro:Play(frame.Arrow3Texture)
        end)
    end

    Waypoint_Templates.PinpointArrow = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                LayoutVertical(name .. "LayoutVertical", {
                    Frame(name .. "Arrow1", {
                        Frame(name .. "Arrow1Texture")
                            :id("Arrow1Texture", id)
                            :background(Waypoint_Preload.UIDEF.UIPinpointArrow)
                            :point(UIKit.Enum.Point.Center)
                            :size(ARROW_SIZE, ARROW_SIZE)
                            :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                            :frameLevel(1)
                    })
                        :id("Arrow1", id)
                        :size(ARROW_SIZE, ARROW_SIZE)
                        :frameLevel(1),

                    Frame(name .. "Arrow2", {
                        Frame(name .. "Arrow2Texture")
                            :id("Arrow2Texture", id)
                            :background(Waypoint_Preload.UIDEF.UIPinpointArrow)
                            :point(UIKit.Enum.Point.Center)
                            :size(ARROW_SIZE, ARROW_SIZE)
                            :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                            :frameLevel(1)
                    })
                        :id("Arrow2", id)
                        :size(ARROW_SIZE, ARROW_SIZE)
                        :frameLevel(1),

                    Frame(name .. "Arrow3", {
                        Frame(name .. "Arrow3Texture")
                            :id("Arrow3Texture", id)
                            :background(Waypoint_Preload.UIDEF.UIPinpointArrow)
                            :point(UIKit.Enum.Point.Center)
                            :size(ARROW_SIZE, ARROW_SIZE)
                            :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                            :frameLevel(1)
                    })
                        :id("Arrow3", id)
                        :size(ARROW_SIZE, ARROW_SIZE)
                        :frameLevel(1)
                })
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.FIT, UIKit.UI.FIT)
                    :layoutSpacing(-5)
            })

        frame.Arrow1 = UIKit.GetElementById("Arrow1", id)
        frame.Arrow2 = UIKit.GetElementById("Arrow2", id)
        frame.Arrow3 = UIKit.GetElementById("Arrow3", id)
        frame.Arrow1Texture = UIKit.GetElementById("Arrow1Texture", id)
        frame.Arrow2Texture = UIKit.GetElementById("Arrow2Texture", id)
        frame.Arrow3Texture = UIKit.GetElementById("Arrow3Texture", id)
        frame.Arrow1TextureBackground = frame.Arrow1Texture:GetTextureFrame()
        frame.Arrow2TextureBackground = frame.Arrow2Texture:GetTextureFrame()
        frame.Arrow3TextureBackground = frame.Arrow3Texture:GetTextureFrame()

        Mixin(frame, PinpointArrowMixin)
        return frame
    end)
end

do -- Context Icon
    local FOREGROUND_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 14 }
    local CONTENT_SIZE = UIKit.Define.Percentage{ value = 28 }

    local ContextIconMixin = {}

    function ContextIconMixin:OnLoad()
        self.tintColor = nil
    end

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
        self.ImageTexture:SetColor(GenericEnum.ColorRGB01.WHITE_FONT_COLOR)
    end

    function ContextIconMixin:SetData(ContextIconTexture)
        if ContextIconTexture.type == "ATLAS" then
            self:SetAtlas(ContextIconTexture.path)
        else
            self:SetIcon(ContextIconTexture.path)
        end
    end

    Waypoint_Templates.ContextIcon = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. "Background")
                    :id("BackgroundTexture", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(FOREGROUND_SIZE, FOREGROUND_SIZE)
                    :background(Waypoint_Preload.UIDEF.ContextIcon)
                    :frameLevel(2),
                Frame(name .. "Image")
                    :id("Image", id)
                    :point(UIKit.Enum.Point.Center)
                    :background(UIKit.UI.TEXTURE_NIL)
                    :frameLevel(3)
                    :size(CONTENT_SIZE, CONTENT_SIZE)
            })

        frame.BackgroundTexture = UIKit.GetElementById("BackgroundTexture", id):GetTextureFrame()
        frame.ImageTexture = UIKit.GetElementById("Image", id):GetTextureFrame()

        Mixin(frame, ContextIconMixin)
        frame:OnLoad()
        
        return frame
    end)
end
