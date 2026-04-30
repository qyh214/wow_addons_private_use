local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local Waypoint_Preload = env.modules:Import("@\\Waypoint\\Preload")
local Waypoint_Templates = env.modules:Import("@\\Waypoint\\Templates")
local PinpointArrow, ContextIcon = Waypoint_Templates.PinpointArrow, Waypoint_Templates.ContextIcon

WUIFrame = Frame("WUIFrame"):_Render()

do -- Waypoint
    local WAYPOINT_SIZE = 46
    local FOOTER_WIDTH = 100
    local FOOTER_HEIGHT = 38
    local FOOTER_TEXT_WIDTH = 100

    local name = "WUIWaypointFrame"
    local id = "WUIWaypointFrame"

    local frame = Frame(name, {
            Frame(name .. ".Container", {
                Frame(name .. ".AnimationFrame", {
                    ContextIcon(name .. ".ContextIcon")
                        :id("ContextIcon", id)
                        :point(UIKit.Enum.Point.Center)
                        :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                        :frameLevel(5)
                        :backgroundBlendMode(UIKit.Enum.BlendMode.Add),

                    Frame(name .. ".Beam", {
                        Frame(name .. ".Beam.Mask")
                            :id("Beam.Mask", id)
                            :point(UIKit.Enum.Point.Center, UIKit.Enum.Point.Bottom)
                            :size(100, 100)
                            :maskBackground(Waypoint_Preload.UIDEF.UIWaypointBeamMask)
                            :frameLevel(2),

                        Frame(name .. ".Beam.Background")
                            :id("Beam.Background", id)
                            :size(UIKit.UI.FILL)
                            :frameLevel(1)
                            :background(Waypoint_Preload.UIDEF.UIWaypointBeam)
                            :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                            :mask(UIKit.NewGroupCaptureString("Beam.Mask", id)),

                        Frame(name .. ".Beam.FX.Mask")
                            :id("Beam.FX.Mask", id)
                            :point(UIKit.Enum.Point.Bottom)
                            :size(UIKit.Define.Percentage{ value = 100 }, 250)
                            :maskBackground(Waypoint_Preload.UIDEF.UIWaypointBeamMask)
                            :frameLevel(2),

                        Frame(name .. ".Beam.FX")
                            :id("Beam.FX", id)
                            :size(UIKit.UI.FILL)
                            :frameLevel(2)
                            :backgroundBlendMode(UIKit.Enum.BlendMode.Add)
                            :background(Waypoint_Preload.UIDEF.UIWaypointBeamFX)
                            :mask(UIKit.NewGroupCaptureString("Beam.FX.Mask", id))
                    })
                        :id("Beam", id)
                        :point(UIKit.Enum.Point.Bottom, UIKit.Enum.Point.Center)
                        :y(-25)
                        :size(50, 500)
                        :frameLevel(2),

                    LayoutVertical(name .. ".Footer", {
                        Text(name .. ".Footer.InfoText")
                            :id("Footer.InfoText", id)
                            :fontObject(UIFont.WUIFooterFont)
                            :textAlignment("CENTER", "MIDDLE")
                            :size(FOOTER_TEXT_WIDTH, UIKit.UI.FIT),

                        Text(name .. ".Footer.DistanceText")
                            :id("Footer.DistanceText", id)
                            :fontObject(UIFont.WUIFooterFont)
                            :textAlignment("CENTER", "MIDDLE")
                            :size(FOOTER_TEXT_WIDTH, UIKit.UI.FIT),

                        Text(name .. ".Footer.ArrivalTimeText")
                            :id("Footer.ArrivalTimeText", id)
                            :point(UIKit.Enum.Point.Center)
                            :fontObject(UIFont.WUIFooterFont)
                            :textAlignment("CENTER", "MIDDLE")
                            :size(FOOTER_TEXT_WIDTH, UIKit.UI.FIT)
                    })
                        :id("Footer", id)
                        :anchor(UIKit.NewGroupCaptureString("ContextIcon", id))
                        :point(UIKit.Enum.Point.Top, UIKit.Enum.Point.Bottom)
                        :y(0)
                        :size(FOOTER_WIDTH, FOOTER_HEIGHT)
                        :layoutSpacing(3)
                        :frameLevel(4)
                        :ignoreParentScale(true)
                        :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
                })
                    :id("AnimationFrame", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
            })
                :id("Container", id)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
        })
        :parent(WUIFrame)
        :frameStrata(UIKit.Enum.FrameStrata.Background, 1)
        :size(WAYPOINT_SIZE, WAYPOINT_SIZE)
        :_Render()

    frame.Container = UIKit.GetElementById("Container", id)
    frame.AnimationFrame = UIKit.GetElementById("AnimationFrame", id)
    frame.ContextIcon = UIKit.GetElementById("ContextIcon", id)
    frame.Beam = UIKit.GetElementById("Beam", id)
    frame.Beam.Background = UIKit.GetElementById("Beam.Background", id)
    frame.Beam.BackgroundTexture = frame.Beam.Background:GetTextureFrame()
    frame.Beam.Mask = UIKit.GetElementById("Beam.Mask", id)
    frame.Beam.FX = UIKit.GetElementById("Beam.FX", id)
    frame.Beam.FXMask = UIKit.GetElementById("Beam.FX.Mask", id)
    frame.Beam.FXTexture = frame.Beam.FX:GetTextureFrame()
    frame.Footer = UIKit.GetElementById("Footer", id)
    frame.Footer.InfoText = UIKit.GetElementById("Footer.InfoText", id)
    frame.Footer.DistanceText = UIKit.GetElementById("Footer.DistanceText", id)
    frame.Footer.ArrivalTimeText = UIKit.GetElementById("Footer.ArrivalTimeText", id)
    WUIWaypointFrame = frame
end

do -- Pinpoint
    local CONTEXT_SIZE = 58
    local FOREGROUND_SIZE = UIKit.Define.Fit{ delta = 23 }
    local FOREGROUND_CONTENT = UIKit.Define.Fit{}
    local FOREGROUND_CONTENT_MAXWIDTH = 325

    local name = "WUIPinpointFrame"
    local id = "WUIPinpointFrame"

    local frame = Frame(name, {
            Frame(name .. ".Container", {
                Frame(name .. ".AnimationFrame", {
                    Frame(name .. ".Background", {
                        ContextIcon(name .. ".Background.ContextIcon")
                            :id("Background.ContextIcon", id)
                            :size(CONTEXT_SIZE, CONTEXT_SIZE)
                            :point(UIKit.Enum.Point.Center)
                            :frameLevel(3),

                        PinpointArrow("Background.Arrow")
                            :id("Background.Arrow", id)
                            :anchor(UIKit.NewGroupCaptureString("Background.ContextIcon", id))
                            :point(UIKit.Enum.Point.Top, UIKit.Enum.Point.Bottom)
                            :size(UIKit.UI.FIT, UIKit.UI.FIT)
                            :y(10)
                            :frameLevel(2)
                    })
                        :id("Background", id)
                        :frameLevel(1)
                        :point(UIKit.Enum.Point.Center)
                        :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                        :_excludeFromCalculations(),

                    Frame(name .. ".Foreground", {
                        Frame(name .. ".Foreground.Background")
                            :id("Foreground.Background", id)
                            :background(Waypoint_Preload.UIDEF.UIPinpoint)
                            :size(UIKit.UI.FILL)
                            :frameLevel(6)
                            :_excludeFromCalculations(),

                        Text(name .. ".Foreground.Content")
                            :id("Foreground.Content", id)
                            :point(UIKit.Enum.Point.Center)
                            :textAlignment("LEFT", "MIDDLE")
                            :fontObject(UIFont.UIFontObjectNormal10)
                            :size(FOREGROUND_CONTENT, FOREGROUND_CONTENT)
                            :maxWidth(FOREGROUND_CONTENT_MAXWIDTH)
                            :textVerticalSpacing(3)
                            :frameLevel(8)
                            :_updateMode(UIKit.Enum.UpdateMode.All)
                    })
                        :id("Foreground", id)
                        :point(UIKit.Enum.Point.Center)
                        :size(UIKit.Define.Fit{ delta = 23 }, FOREGROUND_SIZE)
                        :frameLevel(5)
                })
                    :id("AnimationFrame", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.FIT, UIKit.UI.FIT)
            })
                :id("Container", id)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.UI.FIT, UIKit.UI.FIT)
        })
        :parent(WUIFrame)
        :frameStrata(UIKit.Enum.FrameStrata.Background, 1)
        :size(UIKit.UI.FIT, UIKit.UI.FIT)
        :_Render()

    frame.Container = UIKit.GetElementById("Container", id)
    frame.AnimationFrame = UIKit.GetElementById("AnimationFrame", id)
    frame.Background = UIKit.GetElementById("Background", id)
    frame.Background.ContextIcon = UIKit.GetElementById("Background.ContextIcon", id)
    frame.Background.Arrow = UIKit.GetElementById("Background.Arrow", id)
    frame.Foreground = UIKit.GetElementById("Foreground", id)
    frame.Foreground.Background = UIKit.GetElementById("Foreground.Background", id)
    frame.Foreground.BackgroundTexture = frame.Foreground.Background:GetTextureFrame()
    frame.Foreground.Content = UIKit.GetElementById("Foreground.Content", id)
    WUIPinpointFrame = frame
end

do -- Navigator
    local NAVIGATOR_SIZE = 46
    local ARROW_SIZE = 58

    local name = "WUINavigatorFrame"
    local id = "WUINavigatorFrame"

    local frame = Frame(name, {
            Frame(name .. ".Container", {
                Frame(name .. ".AnimationFrame", {
                    ContextIcon(name .. ".ContextIcon")
                        :id("ContextIcon", id)
                        :frameLevel(2)
                        :point(UIKit.Enum.Point.Center)
                        :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL),

                    Frame(name .. ".Arrow")
                        :id("Arrow", id)
                        :point(UIKit.Enum.Point.Center)
                        :frameLevel(3)
                        :size(ARROW_SIZE, ARROW_SIZE)
                        :background(Waypoint_Preload.UIDEF.UINavigatorArrow)
                })
                    :id("AnimationFrame", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
            })
                :id("Container", id)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)

        })
        :parent(WUIFrame)
        :frameStrata(UIKit.Enum.FrameStrata.Background, 1)
        :size(NAVIGATOR_SIZE, NAVIGATOR_SIZE)
        :clampedToScreen(true)
        :_Render()

    frame.Container = UIKit.GetElementById("Container", id)
    frame.AnimationFrame = UIKit.GetElementById("AnimationFrame", id)
    frame.ContextIcon = UIKit.GetElementById("ContextIcon", id)
    frame.Arrow = UIKit.GetElementById("Arrow", id)
    frame.ArrowTexture = frame.Arrow:GetTextureFrame()
    WUINavigatorFrame = frame
end
