local env                     = select(2, ...)
local UICCommonButton         = env.WPM:Import("wpm_modules/uic-common/button")
local UICCommonCheckButton    = env.WPM:Import("wpm_modules/uic-common/check-button")
local UICCommonRange          = env.WPM:Import("wpm_modules/uic-common/range")
local UICCommonScrollBar      = env.WPM:Import("wpm_modules/uic-common/scroll-bar")
local UICCommonInput          = env.WPM:Import("wpm_modules/uic-common/input")
local UICCommonSelectionMenu  = env.WPM:Import("wpm_modules/uic-common/selection-menu")
local UICCommonColorInput     = env.WPM:Import("wpm_modules/uic-common/color-input")
local UICCommonPrompt         = env.WPM:Import("wpm_modules/uic-common/prompt")
local UICCommon               = env.WPM:New("wpm_modules/uic-common")

UICCommon.ButtonRed           = UICCommonButton.RedBase
UICCommon.ButtonGrey          = UICCommonButton.GreyBase
UICCommon.ButtonRedSquare     = UICCommonButton.RedBaseSquare
UICCommon.ButtonGreySquare    = UICCommonButton.GreyBaseSquare
UICCommon.ButtonRedWithText   = UICCommonButton.RedWithText
UICCommon.ButtonGreyWithText  = UICCommonButton.GreyWithText
UICCommon.ButtonRedClose      = UICCommonButton.RedClose
UICCommon.ButtonSelectionMenu = UICCommonButton.SelectionMenu
UICCommon.CheckButton         = UICCommonCheckButton.New
UICCommon.ScrollBar           = UICCommonScrollBar.New
UICCommon.Input               = UICCommonInput.New
UICCommon.Range               = UICCommonRange.New
UICCommon.RangeWithText       = UICCommonRange.NewWithText
UICCommon.SelectionMenu       = UICCommonSelectionMenu.New
UICCommon.ColorInput          = UICCommonColorInput.New
UICCommon.Prompt              = UICCommonPrompt.New

-- Demo
--------------------------------

--[[
    local UIKit = env.WPM:Import("wpm_modules/ui-kit")
    local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List

    LayoutVertical{
        -- Red Button with Text
        UICCommon.ButtonRedWithText()
            :id("RedWithText")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 }),

        -- Grey Button with Text
        UICCommon.ButtonGreyWithText()
            :id("GreyWithText")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 }),

        -- Red Close Button
        UICCommon.ButtonRedClose()
            :id("RedClose")
            :size(UIKit.Define.Num{ value = 32 }, UIKit.Define.Num{ value = 32 }),

        -- Selection Menu Button
        UICCommon.ButtonSelectionMenu()
            :id("SelectionMenuButton")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 }),

        -- CheckButton
        UICCommon.CheckButton()
            :id("CheckButton")
            :size(UIKit.Define.Num{ value = 22 }, UIKit.Define.Num{ value = 22 }),

        -- Input
        UICCommon.Input()
            :id("Input")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Fit{ delta = 17 }),

        -- Range
        UICCommon.Range()
            :id("Range")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 15 }),

        -- Range With Text
        UICCommon.RangeWithText()
            :id("RangeWithText")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 15 }),

        -- Color Input
        UICCommon.ColorInput()
            :id("ColorInput")
            :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Num{ value = 32 })
    }
        :point(UIKit.Enum.Point.Center)
        :parent(UIParent)
        :size(UIKit.Define.Percentage{ value = 50 }, UIKit.Define.Percentage{ value = 50 })
        :layoutDirection(UIKit.Enum.Direction.Vertical)
        :layoutSpacing(UIKit.Define.Num{ value = 5 })
        :_Render()


    ScrollView{
        Frame{

        }
            :point(UIKit.Enum.Point.Top)
            :size(UIKit.Define.Percentage{ value = 100 }, UIKit.Define.Num{ value = 100 })
    }
        :id("ScrollView")
        :point(UIKit.Enum.Point.Center)
        :size(UIKit.Define.Num{ value = 375 }, UIKit.Define.Num{ value = 250 })
        :scrollDirection(UIKit.Enum.Direction.Vertical)
        :scrollViewContentWidth(UIKit.Define.Percentage{ value = 100 })
        :scrollViewContentHeight(UIKit.Define.Num{ value = 575 })
        :scrollInterpolation(5)
        :_Render()

    UICCommon.ScrollBar()
        :id("ScrollBar")
        :scrollBarTarget("ScrollView")
        :point(UIKit.Enum.Point.Right)
        :size(UIKit.Define.Num{ value = 7 }, UIKit.Define.Num{ value = 575 })
        :scrollDirection(UIKit.Enum.Direction.Vertical)
        :_Render()



    -- Set Values
    --------------------------------

    E_RedWithText = UIKit.GetElementById("RedWithText")
    E_RedWithText:SetText("Button")

    E_GreyWithText = UIKit.GetElementById("GreyWithText")
    E_GreyWithText:SetText("Button")

    E_RedClose = UIKit.GetElementById("RedClose")

    E_Input = UIKit.GetElementById("Input")

    E_CheckButton = UIKit.GetElementById("CheckButton")
    E_CheckButton:SetChecked(true)

    E_Range = UIKit.GetElementById("Range")
    E_Range:GetRange():SetMinMaxValues(0, 1)
    E_Range:GetRange():SetValue(.5)

    E_RangeWithText = UIKit.GetElementById("RangeWithText")
    E_RangeWithText:GetRange():SetMinMaxValues(0, 1)
    E_RangeWithText:GetRange():SetValue(.5)
    E_RangeWithText:SetText("Range")

    E_ColorInput = UIKit.GetElementById("ColorInput")

    E_ScrollView = UIKit.GetElementById("ScrollView")

    E_ScrollBar = UIKit.GetElementById("ScrollBar")




    -- Create a selection menu
    --      Try: E_SelectionMenu:Open(initialIndex, data, onValueChange, onElementUpdateHandler, point, relativeTo, relativePoint, x, y)
    --------------------------------

    E_SelectionMenu = UICCommon.SelectionMenu()
        :parent(UIParent)
        :frameStrata(UIKit.Enum.FrameStrata.FullscreenDialog)
        :size(UIKit.Define.Num{ value = 175 }, UIKit.Define.Fit{ delta = 7 })
        :_Render()



    -- Dropdown Button to open menu
    --------------------------------

    local value = 1

    E_SelectionMenu_Data = {}
    for i = 1, 500 do
        table.insert(E_SelectionMenu_Data, "entry" .. i)
    end

    E_SelectionMenuButton = UIKit.GetElementById("SelectionMenuButton")
    E_SelectionMenuButton:SetSelectionMenu(E_SelectionMenu)
    E_SelectionMenuButton:HookValueChanged(function(_, val) value = val; print(value) end)
    E_SelectionMenuButton:SetData(E_SelectionMenu_Data)



    -- Create a prompt
    --------------------------------

    E_Prompt = UICCommon.Prompt()
        :parent(UIParent)
        :point(UIKit.Enum.Point.Center)
        :_Render()

    local E_Prompt_Data = {
        text    = "PH",
        options = {
            {
                text     = "Accept",
                callback = function()
                    print("Accept")
                end
            },
            {
                text     = "Decline",
                callback = function()
                    print("Decline")
                end
            }
        }
    }

    E_Prompt:SetData(E_Prompt_Data)
--]]
