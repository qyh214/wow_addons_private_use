local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local UICCommon = env.modules:Import("packages\\uic-common")
local Settings_Preload = env.modules:Import("@\\Settings\\Preload")

do -- Setting
    local name = Settings_Preload.FRAME_NAME
    local id = Settings_Preload.FRAME_NAME

    local frame = Frame(name .. ".Frame", {
        Frame(name .. ".Sidebar", {
            Frame(name .. ".Sidebar.Divider")
                :id("Sidebar.Divider", id)
                :point(UIKit.Enum.Point.Right)
                :size(2, UIKit.Define.Percentage{ value = 100 })
                :background(Settings_Preload.UIDEF.Divider)
                :backgroundColor(UIKit.Define.Color_RGBA{ r = 142.5, g = 142.5, b = 142.5, a = 0.2375 }),

            Frame(name .. ".Sidebar.Content", {
                LayoutVertical(name .. ".Sidebar.Tab")
                    :id("Sidebar.Tab", id)
                    :point(UIKit.Enum.Point.Top)
                    :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Percentage{ value = 100, operator = "-", delta = 75 })
                    :layoutSpacing(3),

                LayoutVertical(name .. ".Sidebar.Footer")
                    :id("Sidebar.Footer", id)
                    :point(UIKit.Enum.Point.Bottom)
                    :size(UIKit.Define.Percentage{ value = 100 }, 75)
                    :layoutAlignmentV(UIKit.Enum.Direction.Trailing)
                    :layoutSpacing(3)
            })
                :id("Sidebar.Content", id)
                :size(UIKit.Define.Fill{ delta = 45 })
        })
            :id("Sidebar", id)
            :point(UIKit.Enum.Point.Left)
            :size(212, UIKit.Define.Percentage{ value = 100 }),

        Frame(name .. ".Content", {
            Frame(name .. ".Content.Container")
                :id("Content.Container", id)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = 35 }, UIKit.Define.Percentage{ value = 100 })
        })
            :id("Content", id)
            :point(UIKit.Enum.Point.Right)
            :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = 212 }, UIKit.Define.Percentage{ value = 100 })
    })

    frame.Sidebar = UIKit.GetElementById("Sidebar", id)
    frame.Sidebar.Content = UIKit.GetElementById("Sidebar.Content", id)
    frame.Sidebar.Image = UIKit.GetElementById("Sidebar.Image", id)
    frame.Sidebar.Tab = UIKit.GetElementById("Sidebar.Tab", id)
    frame.Sidebar.Footer = UIKit.GetElementById("Sidebar.Footer", id)
    frame.Content = UIKit.GetElementById("Content", id)
    frame.Content.Container = UIKit.GetElementById("Content.Container", id)
    _G[name] = frame
end

do -- Prompt
    local name = Settings_Preload.FRAME_NAME
    local id = Settings_Preload.FRAME_NAME

    local frame = UICCommon.Prompt(name .. ".Prompt")
        :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog, 100)
        :parent(UIParent)
        :anchor(StaticPopup1)
        :point(UIKit.Enum.Point.Center)
        :_Render()

    frame:Hide()
    _G[Settings_Preload.FRAME_NAME].Prompt = frame
end

do -- Selection Menu
    local name = Settings_Preload.FRAME_NAME
    local id = Settings_Preload.FRAME_NAME

    local frame = UICCommon.SelectionMenu(name .. ".SelectionMenu")
        :parent(_G[Settings_Preload.FRAME_NAME])
        :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog)
        :size(175, UIKit.Define.Fit{})
        :_Render()

    frame:Hide()
    _G[Settings_Preload.FRAME_NAME].SelectionMenu = frame
end
