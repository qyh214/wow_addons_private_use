local env                                                                                                                                          = select(2, ...)
local Path                                                                                                                                         = env.WPM:Import("wpm_modules/path")
local UIKit                                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")

local UICCommon                                                                                                                                      = env.WPM:Import("wpm_modules/uic-common")
local Setting_Shared                                                                                                                               = env.WPM:Import("@/Setting/Shared")


-- Shared
--------------------------------

local FRAME_NAME = Setting_Shared.FRAME_NAME


-- Frame
--------------------------------

local TEXTURE_DIVIDER = UIKit.Define.Texture{ path = Path.Root .. "/Art/Shape/Square.png" }


Frame(FRAME_NAME .. ".Frame", {
    Frame(FRAME_NAME .. ".Sidebar", {
        Frame(FRAME_NAME .. ".Sidebar.Divider")
            :id(FRAME_NAME .. ".Sidebar.Divider")
            :point(UIKit.Enum.Point.Right)
            :size(UIKit.Define.Num{ value = 2 }, UIKit.Define.Percentage{ value = 100 })
            :background(TEXTURE_DIVIDER)
            :backgroundColor(UIKit.Define.Color_RGBA{ r = 142.5, g = 142.5, b = 142.5, a = .2375 }),

        Frame(FRAME_NAME .. ".Sidebar.Content", {
            LayoutVertical(FRAME_NAME .. ".Sidebar.Tab")
                :id(FRAME_NAME .. ".Sidebar.Tab")
                :point(UIKit.Enum.Point.Top)
                :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Percentage{ value = 100, operator = "-", delta = 75 })
                :layoutSpacing(UIKit.Define.Num{ value = 3 }),

            LayoutVertical(FRAME_NAME .. ".Sidebar.Footer")
                :id(FRAME_NAME .. ".Sidebar.Footer")
                :point(UIKit.Enum.Point.Bottom)
                :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Num{ value = 75 })
                :layoutAlignmentV(UIKit.Enum.Direction.Trailing)
                :layoutSpacing(UIKit.Define.Num{ value = 3 })
        })
            :id(FRAME_NAME .. ".Sidebar.Content")
            :size(UIKit.Define.Fill{ delta = 45 })
    })
        :id(FRAME_NAME .. ".Sidebar")
        :point(UIKit.Enum.Point.Left)
        :size(UIKit.Define.Num{ value = 212 }, UIKit.Define.Percentage{ value = 100 }),

    Frame(FRAME_NAME .. ".Content", {
        Frame(FRAME_NAME .. ".Content.Container")
            :id(FRAME_NAME .. ".Content.Container")
            :point(UIKit.Enum.Point.Center)
            :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = 35 }, UIKit.Define.Percentage{ value = 100 })
    })
        :id(FRAME_NAME .. ".Content")
        :point(UIKit.Enum.Point.Right)
        :size(UIKit.Define.Percentage{ value = 100, operator = "-", delta = 212 }, UIKit.Define.Percentage{ value = 100 })
})
    :id(FRAME_NAME)

_G[FRAME_NAME] = UIKit.GetElementById(FRAME_NAME)
_G[FRAME_NAME].Sidebar = UIKit.GetElementById(FRAME_NAME .. ".Sidebar")
_G[FRAME_NAME].Sidebar.Content = UIKit.GetElementById(FRAME_NAME .. ".Sidebar.Content")
_G[FRAME_NAME].Sidebar.Image = UIKit.GetElementById(FRAME_NAME .. ".Sidebar.Image")
_G[FRAME_NAME].Sidebar.Tab = UIKit.GetElementById(FRAME_NAME .. ".Sidebar.Tab")
_G[FRAME_NAME].Sidebar.Footer = UIKit.GetElementById(FRAME_NAME .. ".Sidebar.Footer")
_G[FRAME_NAME].Content = UIKit.GetElementById(FRAME_NAME .. ".Content")
_G[FRAME_NAME].Content.Container = UIKit.GetElementById(FRAME_NAME .. ".Content.Container")


-- Prompt
--------------------------------

UICCommon.Prompt(FRAME_NAME .. ".Prompt")
    :id(FRAME_NAME .. ".Prompt")
    :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog, 100)
    :parent(UIParent)
    :anchor(StaticPopup1)
    :point(UIKit.Enum.Point.Center)
    :_Render()

_G[FRAME_NAME].Prompt = UIKit.GetElementById(FRAME_NAME .. ".Prompt")
_G[FRAME_NAME].Prompt:Hide()


-- Selection Menu
--------------------------------

_G[FRAME_NAME].SelectionMenu = UICCommon.SelectionMenu(FRAME_NAME .. ".SelectionMenu")
    :parent(_G[FRAME_NAME])
    :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog)
    :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Fit{})
    :_Render()
