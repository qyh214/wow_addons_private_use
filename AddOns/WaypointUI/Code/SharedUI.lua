local env = select(2, ...)

local UIKit = env.WPM:Import("wpm_modules/ui-kit")
local Frame, Grid, LayoutVertical, HStack, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView , List = UIKit.UI.Frame, UIKit.UI.Grid, UIKit.UI.LayoutVertical, UIKit.UI.HStack, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UICCommon = env.WPM:Import("wpm_modules/uic-common")


-- Prompt
--------------------------------

UICCommon.Prompt("WUISharedPrompt")
    :id("WUISharedPrompt")
    :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog)
    :parent(UIParent)
    :anchor(StaticPopup1)
    :point(UIKit.Enum.Point.Center)
    :_Render()

WUISharedPrompt = UIKit.GetElementById("WUISharedPrompt")
WUISharedPrompt:Hide()
