local env                                                                                                                          = select(2, ...)
local Path                                                                                                                         = env.WPM:Import("wpm_modules/path")
local UIFont                                                                                                                       = env.WPM:Import("wpm_modules/ui-font")
local MixinUtil                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local UIKit                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, LayoutVertical, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.LayoutVertical, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")
local Waypoint_Templates                                                                                                           = env.WPM:Import("@/Waypoint/Templates")
local PinpointArrow, ContextIcon                                                                                                   = Waypoint_Templates.PinpointArrow, Waypoint_Templates.ContextIcon

local Mixin                                                                                                                        = MixinUtil.Mixin


-- Shared
--------------------------------

local PATH   = Path.Root .. "/Art/Waypoint/"
local ATLAS  = UIKit.Define.Texture_Atlas{ path = PATH .. "WaypointUITextureAtlas.png" }

local P_FILL = UIKit.Define.Percentage{ value = 100 }
local FILL   = UIKit.Define.Fill{}
local FIT    = UIKit.Define.Fit{}


-- Parent
--------------------------------

WUIFrame = Frame("WUIFrame", {

    })
    :id("WUIFrame")
    :_Render()


-- Waypoint
--------------------------------

do
    local BEAM_BACKGROUND         = ATLAS{ left = 768 / 1792, right = 1280 / 1792, top = 0 / 2560, bottom = 2560 / 2560 }
    local BEAM_BACKGROUND_MASK    = UIKit.Define.Texture{ path = PATH .. "WaypointBeamMask.png" }
    local BEAM_FX_BACKGROUND      = ATLAS{ left = 1280 / 1792, right = 1792 / 1792, top = 0 / 2560, bottom = 2560 / 2560 }
    local BEAM_FX_BACKGROUND_MASK = UIKit.Define.Texture{ path = PATH .. "WaypointBeamFXMask.png" }
    local WAVE_BACKGROUND         = ATLAS{ left = 512 / 1792, right = 768 / 1792, top = 256 / 2560, bottom = 512 / 2560 }
    local WAYPOINT_SIZE           = UIKit.Define.Num{ value = 45 }
    local WAVE_SIZE               = UIKit.Define.Num{ value = 75 }
    local FOOTER_WIDTH            = UIKit.Define.Num{ value = 100 }
    local FOOTER_HEIGHT           = UIKit.Define.Num{ value = 37.5 }
    local FOOTER_TEXT_WIDTH       = UIKit.Define.Num{ value = 100 }
    local FOOTER_TEXT_HEIGHT      = UIKit.Define.Num{ value = 11 }


    Frame("WUIWaypointFrame", {
        Frame("WUIWaypointFrame.Container", {
            ContextIcon("WUIWaypointFrame_ContextIcon")
                :id("WUIWaypointFrame.ContextIcon")
                :point(UIKit.Enum.Point.Center)
                :size(P_FILL, P_FILL)
                :frameLevel(5)
                :backgroundBlendMode(UIKit.Enum.BlendMode.Add),

            Frame("WUIWaypointFrame.Wave")
                :id("WUIWaypointFrame.Wave")
                :point(UIKit.Enum.Point.Center)
                :size(WAVE_SIZE, WAVE_SIZE)
                :frameLevel(3)
                :background(WAVE_BACKGROUND),

            Frame("WUIWaypointFrame.Beam", {
                Frame("WUIWaypointFrame.Beam.Mask")
                    :id("WUIWaypointFrame.Beam.Mask")
                    :point(UIKit.Enum.Point.Center, UIKit.Enum.Point.Bottom)
                    :size(UIKit.Define.Num{ value = 100 }, UIKit.Define.Num{ value = 100 })
                    :maskBackground(BEAM_BACKGROUND_MASK)
                    :frameLevel(2),

                Frame("WUIWaypointFrame.Beam.Background")
                    :id("WUIWaypointFrame.Beam.Background")
                    :size(FILL)
                    :frameLevel(1)
                    :background(BEAM_BACKGROUND)
                    :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                    :mask("WUIWaypointFrame.Beam.Mask"),

                Frame("WUIWaypointFrame.Beam.FX.Mask")
                    :id("WUIWaypointFrame.Beam.FX.Mask")
                    :point(UIKit.Enum.Point.Bottom)
                    :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Num{ value = 250 })
                    :maskBackground(BEAM_FX_BACKGROUND_MASK)
                    :frameLevel(2),

                Frame("WUIWaypointFrame.Beam.FX")
                    :id("WUIWaypointFrame.Beam.FX")
                    :size(FILL)
                    :frameLevel(2)
                    :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                    :background(BEAM_FX_BACKGROUND)
                    :mask("WUIWaypointFrame.Beam.FX.Mask")

            })
                :id("WUIWaypointFrame.Beam")
                :point(UIKit.Enum.Point.Bottom, UIKit.Enum.Point.Center)
                :y(UIKit.Define.Num{ value = -25 })
                :size(UIKit.Define.Num{ value = 50 }, UIKit.Define.Num{ value = 500 })
                :frameLevel(2),

            LayoutVertical("WUIWaypointFrame.Footer", {
                Text("WUIWaypointFrame.Footer.InfoText")
                    :id("WUIWaypointFrame.Footer.InfoText")
                    :fontObject(UIFont.UIFontObjectNormal8)
                    :textAlignment("CENTER", "MIDDLE")
                    :size(FOOTER_TEXT_WIDTH, FOOTER_TEXT_HEIGHT),

                Text("WUIWaypointFrame.Footer.DistanceText")
                    :id("WUIWaypointFrame.Footer.DistanceText")
                    :fontObject(UIFont.UIFontObjectNormal8)
                    :textAlignment("CENTER", "MIDDLE")
                    :size(FOOTER_TEXT_WIDTH, FOOTER_TEXT_HEIGHT)
                    :alpha(.5),

                Text("WUIWaypointFrame.Footer.ArrivalTimeText")
                    :id("WUIWaypointFrame.Footer.ArrivalTimeText")
                    :point(UIKit.Enum.Point.Center)
                    :fontObject(UIFont.UIFontObjectNormal8)
                    :textAlignment("CENTER", "MIDDLE")
                    :size(FOOTER_TEXT_WIDTH, FOOTER_TEXT_HEIGHT)
                    :alpha(.5)

            })
                :id("WUIWaypointFrame.Footer")
                :anchor("WUIWaypointFrame.ContextIcon")
                :point(UIKit.Enum.Point.Top, UIKit.Enum.Point.Bottom)
                :y(UIKit.Define.Num{ value = 0 })
                :size(FOOTER_WIDTH, FOOTER_HEIGHT)
                :layoutSpacing(UIKit.Define.Num{ value = 0 })
                :frameLevel(4)
                :ignoreParentScale(true)
                :alpha(.5)
                :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
        })
            :id("WUIWaypointFrame.Container")
            :point(UIKit.Enum.Point.Center)
            :size(P_FILL, P_FILL)

    })
        :id("WUIWaypointFrame")
        :parent("WUIFrame")
        :frameStrata(UIKit.Enum.FrameStrata.Background, 1)
        :size(WAYPOINT_SIZE, WAYPOINT_SIZE)

        :_Render()

    WUIWaypointFrame                        = UIKit.GetElementById("WUIWaypointFrame")
    WUIWaypointFrame.Container              = UIKit.GetElementById("WUIWaypointFrame.Container")
    WUIWaypointFrame.ContextIcon            = UIKit.GetElementById("WUIWaypointFrame.ContextIcon")
    WUIWaypointFrame.Wave                   = UIKit.GetElementById("WUIWaypointFrame.Wave")
    WUIWaypointFrame.WaveTexture            = WUIWaypointFrame.Wave:GetBackground()
    WUIWaypointFrame.Beam                   = UIKit.GetElementById("WUIWaypointFrame.Beam")
    WUIWaypointFrame.Beam.Background        = UIKit.GetElementById("WUIWaypointFrame.Beam.Background")
    WUIWaypointFrame.Beam.BackgroundTexture = WUIWaypointFrame.Beam.Background:GetBackground()
    WUIWaypointFrame.Beam.Mask              = UIKit.GetElementById("WUIWaypointFrame.Beam.Mask")
    WUIWaypointFrame.Beam.FX                = UIKit.GetElementById("WUIWaypointFrame.Beam.FX")
    WUIWaypointFrame.Beam.FXMask            = UIKit.GetElementById("WUIWaypointFrame.Beam.FX.Mask")
    WUIWaypointFrame.Beam.FXTexture         = WUIWaypointFrame.Beam.FX:GetBackground()
    WUIWaypointFrame.Footer                 = UIKit.GetElementById("WUIWaypointFrame.Footer")
    WUIWaypointFrame.Footer.InfoText        = UIKit.GetElementById("WUIWaypointFrame.Footer.InfoText")
    WUIWaypointFrame.Footer.DistanceText    = UIKit.GetElementById("WUIWaypointFrame.Footer.DistanceText")
    WUIWaypointFrame.Footer.ArrivalTimeText = UIKit.GetElementById("WUIWaypointFrame.Footer.ArrivalTimeText")


    local WaypointAnimation = UIAnim.New()
    do
        local function applyDefaultState(frame)
            frame:SetAlpha(1)
            frame.ContextIcon:SetScale(1)
            frame.Beam.Mask:SetScale(50)
            frame.Wave:Play()
            frame.Beam.FXMask:Play()
        end

        -- Instant
        --------------------------------

        WaypointAnimation:State("INSTANT", function(frame)
            applyDefaultState(frame)
        end)

        -- Fade In
        --------------------------------

        local FadeIn = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.175)
            :to(1)

        WaypointAnimation:State("FADE_IN", function(frame)
            FadeIn:Play(frame)
            applyDefaultState(frame)
        end)

        -- Fade Out
        --------------------------------

        local FadeOut = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.175)
            :to(0)

        WaypointAnimation:State("FADE_OUT", function(frame)
            FadeOut:Play(frame)
            frame.Wave:Stop()
        end)

        -- Intro
        --------------------------------

        local IntroFade = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(1)
            :from(0)
            :to(1)
        local IntroContextIconScale = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Scale)
            :easing(UIAnim.Enum.Easing.ExpoIn)
            :duration(.5)
            :from(2.25)
            :to(1)
        local IntroBeamMaskScale = UIAnim.Animate()
            :wait(.175)
            :property(UIAnim.Enum.Property.Scale)
            :easing(UIAnim.Enum.Easing.ExpoIn)
            :duration(.5)
            :from(1)
            :to(50)

        WaypointAnimation:State("INTRO", function(frame)
            frame.Beam.Mask:SetScale(1)

            IntroFade:Play(frame)
            IntroContextIconScale:Play(frame.ContextIcon)
            IntroBeamMaskScale:Play(frame.Beam.Mask)

            frame.Wave:Play()
            frame.Beam.FXMask:Play()
        end)

        -- Outro
        --------------------------------

        local OutroFade = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.25)
            :to(0)
        local OutroBeamMaskScale = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Scale)
            :easing(UIAnim.Enum.Easing.ExpoIn)
            :duration(.5)
            :to(1)

        WaypointAnimation:State("OUTRO", function(frame)
            OutroFade:Play(frame)
            OutroBeamMaskScale:Play(frame.Beam.Mask)

            frame.Wave:Stop()
            frame.Beam.FXMask:Stop()
        end)
    end

    local WaypointAnimation_Hover = UIAnim.New()
    do
        local Enabled = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.QuartInOut)
            :duration(.375)
            :to(.25)
        local Disabled = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.QuartInOut)
            :duration(.375)
            :to(1)

        WaypointAnimation_Hover:State("ENABLED", function(frame)
            Enabled:Play(frame.Container)
        end)

        WaypointAnimation_Hover:State("DISABLED", function(frame)
            Disabled:Play(frame.Container)
        end)
    end

    do -- Wave
        local WaveAnimation = UIAnim.New()
        local Intro = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.75)
            :loop(UIAnim.Enum.Looping.Reset)
            :loopDelayEnd(.75)
            :from(0)
            :to(1)
        local Scale = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Scale)
            :easing(UIAnim.Enum.Easing.CubicInOut)
            :duration(1.5)
            :loop(UIAnim.Enum.Looping.Reset)
            :from(.1)
            :to(1.25)
        local Outro = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.75)
            :loop(UIAnim.Enum.Looping.Reset)
            :loopDelayStart(.75)
            :from(1)
            :to(0)

        WaveAnimation:State("NORMAL", function(frame)
            Intro:Play(frame)
            Scale:Play(frame)
            Outro:Play(frame)
        end)

        local WaveMixin = {}

        function WaveMixin:Play()
            WaveAnimation:Play(self, "NORMAL")
        end

        function WaveMixin:Stop()
            WaveAnimation:Stop(self)
        end

        Mixin(WUIWaypointFrame.Wave, WaveMixin)
    end

    do -- Beam FX Mask
        local BeamFXMaskAnimation = UIAnim.New()
        local Translate = UIAnim.Animate()
            :property(UIAnim.Enum.Property.PosY)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(5)
            :loop(UIAnim.Enum.Looping.Reset)
            :from(-250)
            :to(500)

        BeamFXMaskAnimation:State("NORMAL", function(frame)
            Translate:Play(frame)
        end)

        local BeamFXMaskMixin = {}

        function BeamFXMaskMixin:Play()
            BeamFXMaskAnimation:Play(self, "NORMAL")
        end

        function BeamFXMaskMixin:Stop()
            BeamFXMaskAnimation:Stop(self)
        end

        Mixin(WUIWaypointFrame.Beam.FXMask, BeamFXMaskMixin)
    end


    local WaypointMixin = {}
    WaypointMixin.Animation = WaypointAnimation
    WaypointMixin.Animation_Hover = WaypointAnimation_Hover

    function WaypointMixin:Appearance_SetIcon(UIContextIconTexture)
        self.ContextIcon:SetInfo(UIContextIconTexture)
    end

    function WaypointMixin:Appearance_SetIconOpacity(opacity)
        self.ContextIcon:SetOpacity(opacity)
    end

    function WaypointMixin:Appearance_SetRecolor(shouldRecolor)
        if shouldRecolor then
            self.ContextIcon:Recolor()
        else
            self.ContextIcon:Decolor()
        end
    end

    function WaypointMixin:Appearance_SetTint(color)
        self.ContextIcon:SetTint(color)
        self.WaveTexture:SetColor(color)
        self.Beam.BackgroundTexture:SetColor(color)
        self.Footer.InfoText:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
        self.Footer.DistanceText:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
        self.Footer.ArrivalTimeText:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
    end

    function WaypointMixin:Appearance_SetBeam(enable, opacity)
        self.Beam:SetShown(enable)
        if enable then self.Beam.Background:SetAlpha(opacity) end
    end

    function WaypointMixin:Appearance_SetText(alpha, scale)
        self.Footer.InfoText:SetAlpha(alpha)
        self.Footer.InfoText:SetScale(scale)
        self.Footer.DistanceText:SetAlpha(alpha)
        self.Footer.DistanceText:SetScale(scale)
        self.Footer.ArrivalTimeText:SetAlpha(alpha)
        self.Footer.ArrivalTimeText:SetScale(scale)
    end

    Mixin(WUIWaypointFrame, WaypointMixin)
end


-- Pinpoint
--------------------------------

do
    local CONTEXT_SIZE                = UIKit.Define.Num{ value = 57 }
    local FOREGROUND_BACKGROUND       = ATLAS{ inset = 75, scale = .125, left = 0 / 1792, right = 512 / 1792, top = 0 / 2560, bottom = 256 / 2560 }
    local FOREGROUND_SIZE             = UIKit.Define.Fit{ delta = 23 }
    local FOREGROUND_CONTENT          = UIKit.Define.Fit{}
    local FOREGROUND_CONTENT_MAXWIDTH = UIKit.Define.Num{ value = 325 }


    Frame("WUIPinpointFrame", {
        Frame("WUIPinpointFrame.Container", {
            Frame("WUIPinpointFrame.Background", {
                ContextIcon("WUIPinpointFrame.Background.ContextIcon")
                    :id("WUIPinpointFrame.Background.ContextIcon")
                    :size(CONTEXT_SIZE, CONTEXT_SIZE)
                    :point(UIKit.Enum.Point.Center)
                    :frameLevel(3),

                PinpointArrow("WUIPinpointFrame.Background.Arrow")
                    :id("WUIPinpointFrame.Background.Arrow")
                    :anchor("WUIPinpointFrame.Background.ContextIcon")
                    :point(UIKit.Enum.Point.Top, UIKit.Enum.Point.Bottom)
                    :size(FIT, FIT)
                    :y(UIKit.Define.Num{ value = 10 })
                    :frameLevel(2)
            })
                :id("WUIPinpointFrame.Background")
                :frameLevel(1)
                :point(UIKit.Enum.Point.Center)
                :size(P_FILL, P_FILL)
                :_excludeFromCalculations(),

            Frame("WUIPinpointFrame.Foreground", {
                Frame("WUIPinpointFrame.Foreground.Background")
                    :id("WUIPinpointFrame.Foreground.Background")
                    :background(FOREGROUND_BACKGROUND)
                    :size(FILL)
                    :frameLevel(6)
                    :_excludeFromCalculations(),

                Text("WUIPinpointFrame.Foreground.Content")
                    :id("WUIPinpointFrame.Foreground.Content")
                    :point(UIKit.Enum.Point.Center)
                    :textAlignment("LEFT", "MIDDLE")
                    :fontObject(UIFont.UIFontObjectNormal10)
                    :size(FOREGROUND_CONTENT, FOREGROUND_CONTENT)
                    :maxWidth(FOREGROUND_CONTENT_MAXWIDTH)
                    :textVerticalSpacing(3)
                    :frameLevel(8)
                    :_updateMode(UIKit.Enum.UpdateMode.All)
            })
                :id("WUIPinpointFrame.Foreground")
                :point(UIKit.Enum.Point.Center)
                :size(FOREGROUND_SIZE, FOREGROUND_SIZE)
                :frameLevel(5)
        })
            :id("WUIPinpointFrame.Container")
            :point(UIKit.Enum.Point.Center)
            :size(FIT, FIT)
    })
        :id("WUIPinpointFrame")
        :parent("WUIFrame")
        :frameStrata(UIKit.Enum.FrameStrata.Background, 1)
        :size(FIT, FIT)
        :_Render()


    WUIPinpointFrame = UIKit.GetElementById("WUIPinpointFrame")
    WUIPinpointFrame.Container = UIKit.GetElementById("WUIPinpointFrame.Container")
    WUIPinpointFrame.Background = UIKit.GetElementById("WUIPinpointFrame.Background")
    WUIPinpointFrame.Background.ContextIcon = UIKit.GetElementById("WUIPinpointFrame.Background.ContextIcon")
    WUIPinpointFrame.Background.Arrow = UIKit.GetElementById("WUIPinpointFrame.Background.Arrow")
    WUIPinpointFrame.Foreground = UIKit.GetElementById("WUIPinpointFrame.Foreground")
    WUIPinpointFrame.Foreground.Background = UIKit.GetElementById("WUIPinpointFrame.Foreground.Background")
    WUIPinpointFrame.Foreground.BackgroundTexture = WUIPinpointFrame.Foreground.Background:GetBackground()
    WUIPinpointFrame.Foreground.Content = UIKit.GetElementById("WUIPinpointFrame.Foreground.Content")


    local PinpointAnimation = UIAnim.New()
    do
        local function applyDefaultState(frame)
            frame.Container:SetAlpha(1)
            frame.Background.Arrow:Play()
        end

        -- Instant
        --------------------------------

        PinpointAnimation:State("INSTANT", function(frame)
            frame:SetAlpha(1)
            applyDefaultState(frame)
        end)

        -- Fade In
        --------------------------------

        local FadeIn = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.175)
            :from(0)
            :to(1)

        PinpointAnimation:State("FADE_IN", function(frame)
            FadeIn:Play(frame)
            applyDefaultState(frame)
        end)

        -- Fade Out
        --------------------------------

        local FadeOut = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.175)
            :to(0)

        PinpointAnimation:State("FADE_OUT", function(frame)
            FadeOut:Play(frame)
            frame.Background.Arrow:Stop()
        end)

        -- Intro
        --------------------------------

        local Intro = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.5)
            :to(1)

        local IntroTranslate = UIAnim.Animate()
            :property(UIAnim.Enum.Property.PosY)
            :easing(UIAnim.Enum.Easing.ExpoInOut)
            :duration(1)
            :from(-57.5)
            :to(0)

        PinpointAnimation:State("INTRO", function(frame)
            Intro:Play(frame)
            IntroTranslate:Play(frame.Container)
            frame.Background.Arrow:Play()
        end)

        -- Outro
        --------------------------------

        local OUTRO_ALPHA = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.25)
            :to(0)

        local OUTRO_POS_Y = UIAnim.Animate()
            :property(UIAnim.Enum.Property.PosY)
            :easing(UIAnim.Enum.Easing.ExpoInOut)
            :duration(.25)
            :to(-12.5)

        PinpointAnimation:State("OUTRO", function(frame)
            OUTRO_ALPHA:Play(frame)
            OUTRO_POS_Y:Play(frame.Container)
            frame.Background.Arrow:Stop()
        end)
    end

    local PinpointAnimation_Hover = UIAnim.New()
    do
        local Enabled = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.QuartInOut)
            :duration(.375)
            :to(.25)

        local Disabled = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.QuartInOut)
            :duration(.375)
            :to(1)

        PinpointAnimation_Hover:State("ENABLED", function(frame)
            Enabled:Play(frame.Container)
        end)

        PinpointAnimation_Hover:State("DISABLED", function(frame)
            Disabled:Play(frame.Container)
        end)
    end


    local PinpointMixin = {}
    PinpointMixin.Animation = PinpointAnimation
    PinpointMixin.Animation_Hover = PinpointAnimation_Hover

    function PinpointMixin:Appearance_SetIcon(UIContextIconTexture)
        self.Background.ContextIcon:SetInfo(UIContextIconTexture)
    end

    function PinpointMixin:Appearance_SetIconOpacity(opacity)
        self.Background.ContextIcon:SetAlpha(opacity)
    end

    function PinpointMixin:Appearance_SetRecolor(shouldRecolor)
        if shouldRecolor then
            self.Background.ContextIcon:Recolor()
        else
            self.Background.ContextIcon:Decolor()
        end
    end

    function PinpointMixin:Appearance_SetTint(color)
        self.Background.ContextIcon:SetTint(color)
        self.Background.Arrow:SetTint(color)
        self.Foreground.BackgroundTexture:SetColor(color)
        self.Foreground.Content:SetTextColor(color.r, color.g, color.b, color.a or 1)
    end

    Mixin(WUIPinpointFrame, PinpointMixin)
end


-- Navigator
--------------------------------

do
    local NAVIGATOR_SIZE   = UIKit.Define.Num{ value = 45 }
    local ARROW_BACKGROUND = ATLAS{ left = 0 / 1792, right = 256 / 1792, top = 512 / 2560, bottom = 768 / 2560 }
    local ARROW_SIZE       = UIKit.Define.Num{ value = 57 }


    Frame("WUINavigatorFrame", {
        Frame("WUINavigatorFrame.Container", {
            ContextIcon("WUINavigatorFrame.ContextIcon")
                :id("WUINavigatorFrame.ContextIcon")
                :frameLevel(2)
                :point(UIKit.Enum.Point.Center)
                :size(P_FILL, P_FILL),

            Frame("WUINavigatorFrame.Arrow")
                :id("WUINavigatorFrame.Arrow")
                :point(UIKit.Enum.Point.Center)
                :frameLevel(3)
                :size(ARROW_SIZE, ARROW_SIZE)
                :background(ARROW_BACKGROUND)

        })
            :id("WUINavigatorFrame.Container")
            :point(UIKit.Enum.Point.Center)
            :size(P_FILL, P_FILL)

    })
        :id("WUINavigatorFrame")
        :parent("WUIFrame")
        :frameStrata(UIKit.Enum.FrameStrata.Background, 1)
        :size(NAVIGATOR_SIZE, NAVIGATOR_SIZE)
        :clampedToScreen(true)

        :_Render()

    WUINavigatorFrame = UIKit.GetElementById("WUINavigatorFrame")
    WUINavigatorFrame.Container = UIKit.GetElementById("WUINavigatorFrame.Container")
    WUINavigatorFrame.ContextIcon = UIKit.GetElementById("WUINavigatorFrame.ContextIcon")
    WUINavigatorFrame.Arrow = UIKit.GetElementById("WUINavigatorFrame.Arrow")
    WUINavigatorFrame.ArrowTexture = UIKit.GetElementById("WUINavigatorFrame.Arrow"):GetBackground()


    local NavigatorAnimation = UIAnim.New()
    do
        -- Instant
        --------------------------------

        NavigatorAnimation:State("INSTANT", function(frame)
            frame:SetAlpha(1)
        end)

        -- Fade In
        --------------------------------

        local FadeIn = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.175)
            :to(1)

        NavigatorAnimation:State("FADE_IN", function(frame)
            FadeIn:Play(frame)
        end)

        --------------------------------

        local FadeOut = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.Linear)
            :duration(.175)
            :to(0)

        NavigatorAnimation:State("FADE_OUT", function(frame)
            FadeOut:Play(frame)
        end)
    end

    local NavigatorAnimation_Hover = UIAnim.New()
    do
        local Enabled = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.QuartInOut)
            :duration(.375)
            :to(.25)

        local Disabled = UIAnim.Animate()
            :property(UIAnim.Enum.Property.Alpha)
            :easing(UIAnim.Enum.Easing.QuartInOut)
            :duration(.375)
            :to(1)

        NavigatorAnimation_Hover:State("ENABLED", function(frame)
            Enabled:Play(frame.Container)
        end)

        NavigatorAnimation_Hover:State("DISABLED", function(frame)
            Disabled:Play(frame.Container)
        end)
    end


    local NavigatorMixin = {}
    NavigatorMixin.Animation = NavigatorAnimation
    NavigatorMixin.Animation_Hover = NavigatorAnimation_Hover

    function NavigatorMixin:Appearance_SetIcon(UIContextIconTexture)
        self.ContextIcon:SetInfo(UIContextIconTexture)
    end

    function NavigatorMixin:Appearance_SetIconOpacity(opacity)
        self.ContextIcon:SetAlpha(opacity)
    end

    function NavigatorMixin:Appearance_SetRecolor(shouldRecolor)
        if shouldRecolor then
            self.ContextIcon:Recolor()
        else
            self.ContextIcon:Decolor()
        end
    end

    function NavigatorMixin:Appearance_SetTint(color)
        self.ContextIcon:SetTint(color)
        self.ArrowTexture:SetColor(color)
    end

    Mixin(WUINavigatorFrame, NavigatorMixin)
end
