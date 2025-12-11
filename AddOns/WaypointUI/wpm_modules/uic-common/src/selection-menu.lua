local env                                                                                                                                          = select(2, ...)
local GenericEnum                                                                                                                                  = env.WPM:Import("wpm_modules/generic-enum")
local MixinUtil                                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                                         = env.WPM:Import("wpm_modules/path")
local UIFont                                                                                                                                       = env.WPM:Import("wpm_modules/ui-font")
local UIKit                                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")
local UICSharedMixin                                                                                                                               = env.WPM:Import("wpm_modules/uic-sharedmixin")
local Utils_Texture                                                                                                                                = env.WPM:Import("wpm_modules/utils/texture")

local Mixin                                                                                                                                        = MixinUtil.Mixin
local CreateFromMixins                                                                                                                             = MixinUtil.CreateFromMixins

local UICCommonSelectionMenu                                                                                                                       = env.WPM:New("wpm_modules/uic-common/selection-menu")


-- Shared
--------------------------------

local PATH        = Path.Root .. "/wpm_modules/uic-common/resources/"
local ATLAS       = UIKit.Define.Texture_Atlas{ path = PATH .. "selection-menu.png" }
local TEXTURE_NIL = UIKit.Define.Texture{ path = nil }

Utils_Texture.PreloadAsset(PATH .. "selection-menu.png")


-- Row
--------------------------------

local ROW_BACKGROUND                   = ATLAS{ inset = 32, scale = .175, left = 256 / 320, right = 320 / 320, top = 0 / 192, bottom = 64 / 192 }
local ROW_BACKGROUND_COLOR             = UIKit.Define.Color_RGBA{ r = 125, g = 125, b = 125, a = 0 }
local ROW_BACKGROUND_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 125, g = 125, b = 125, a = .25 }
local ROW_BACKGROUND_COLOR_PUSHED      = UIKit.Define.Color_RGBA{ r = 125, g = 125, b = 125, a = .175 }
local ROW_WIDTH                        = UIKit.Define.Percentage{ value = 100 }
local ROW_HEIGHT                       = UIKit.Define.Num{ value = 28 }
local TEXT_SIZE                        = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 12.5 }
local TEXT_COLOR                       = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .75 }
local TEXT_COLOR_HIGHLIGHTED           = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
local TEXT_COLOR_SELECTED              = UIKit.Define.Color_RGBA{ r = GenericEnum.ColorRGB.Yellow.r * 255, g = GenericEnum.ColorRGB.Yellow.g * 255, b = GenericEnum.ColorRGB.Yellow.b * 255, a = 1 }
local TEXT_Y_PUSHED                    = -1
local TEXT_Y                           = 0


local RowMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

function RowMixin:OnLoad()
    self:InitButton()

    self.isSelected = false
    self.__parentRef = nil
    self.__index = nil

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookMouseUp(self.OnClick)
end

function RowMixin:OnClick()
    if not self.__parentRef then return end

    self.__parentRef:SetSelectedIndex(self.__index)
    self:UpdateAnimation()
end

function RowMixin:OnElementUpdate(parent, index, value)
    self.__parentRef = parent
    self.__index = index
    self:UpdateAnimation()

    self.Text:SetText(value)

    if self.__parentRef.customElementUpdateHandler then
        self.__parentRef.customElementUpdateHandler(self, index, value)
    end
end

function RowMixin:IsSelected()
    return self.isSelected
end

function RowMixin:UpdateSelected()
    if not self.__parentRef then return end
    self.isSelected = (self.__index == self.__parentRef.selectedIndex)
end

function RowMixin:UpdateAnimation()
    if not self.__parentRef then return end

    self:UpdateSelected()

    local isSelected = self:IsSelected()
    local buttonState = self:GetButtonState()

    if isSelected then
        if buttonState == "PUSHED" then
            self:backgroundColor(ROW_BACKGROUND_COLOR_PUSHED)
            self.Text:textColor(TEXT_COLOR_SELECTED)
        elseif buttonState == "HIGHLIGHTED" then
            self:backgroundColor(ROW_BACKGROUND_COLOR_HIGHLIGHTED)
            self.Text:textColor(TEXT_COLOR_SELECTED)
        else
            self:backgroundColor(ROW_BACKGROUND_COLOR)
            self.Text:textColor(TEXT_COLOR_SELECTED)
        end
    else
        if buttonState == "PUSHED" then
            self:backgroundColor(ROW_BACKGROUND_COLOR_PUSHED)
            self.Text:textColor(TEXT_COLOR_HIGHLIGHTED)
        elseif buttonState == "HIGHLIGHTED" then
            self:backgroundColor(ROW_BACKGROUND_COLOR_HIGHLIGHTED)
            self.Text:textColor(TEXT_COLOR_HIGHLIGHTED)
        else
            self:backgroundColor(ROW_BACKGROUND_COLOR)
            self.Text:textColor(TEXT_COLOR)
        end
    end

    self.Text:ClearAllPoints()
    self.Text:SetPoint("CENTER", self, 0, buttonState == "PUSHED" and TEXT_Y_PUSHED or TEXT_Y)
end

UICCommonSelectionMenu.Row = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Text(name .. ".Text", {

            })
                :id("Text", id)
                :point(UIKit.Enum.Point.Center)
                :size(TEXT_SIZE, TEXT_SIZE)
                :fontObject(UIFont.UIFontObjectNormal14)
                :textColor(TEXT_COLOR)
                :textAlignment("LEFT", "MIDDLE")
        })
        :background(ROW_BACKGROUND)
        :backgroundColor(ROW_BACKGROUND_COLOR)
        :size(ROW_WIDTH, ROW_HEIGHT)


    frame.Text = UIKit.GetElementById("Text", id)
    Mixin(frame, RowMixin)
    frame:OnLoad()

    return frame
end)


-- Content Arrow
--------------------------------

local ARROW_BACKGROUND             = ATLAS{ inset = 0, scale = 1, left = 128 / 320, right = 192 / 320, top = 128 / 192, bottom = 192 / 192 }
local ARROW_BACKGROUND_HIGHLIGHTED = ATLAS{ inset = 0, scale = 1, left = 192 / 320, right = 256 / 320, top = 128 / 192, bottom = 192 / 192 }
local ARROW_BACKGROUND_PUSHED      = ATLAS{ inset = 0, scale = 1, left = 256 / 320, right = 320 / 320, top = 128 / 192, bottom = 192 / 192 }
local ARROW_SIZE                   = UIKit.Define.Num{ value = 11 }

local OVERLAY_BACKGROUND_UP        = ATLAS{ inset = 32, scale = 1, left = 0 / 320, right = 64 / 320, top = 128 / 192, bottom = 192 / 192 }
local OVERLAY_BACKGROUND_DOWN      = ATLAS{ inset = 32, scale = 1, left = 64 / 320, right = 128 / 320, top = 128 / 192, bottom = 192 / 192 }
local OVERLAY_WIDTH                = UIKit.Define.Percentage{ value = 100 }
local OVERLAY_HEIGHT               = UIKit.Define.Num{ value = 35 }


local ContentArrowAnimation = UIAnim.New()

local ContentArrowIntroAlpha = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :easing(UIAnim.Enum.Easing.Linear)
    :duration(.125)
    :from(0)
    :to(1)

local ContentArrowOutroAlpha = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :easing(UIAnim.Enum.Easing.Linear)
    :duration(.125)
    :to(0)

ContentArrowAnimation:State("INTRO", function(frame)
    ContentArrowIntroAlpha:Play(frame)
end)

ContentArrowAnimation:State("OUTRO", function(frame)
    ContentArrowOutroAlpha:Play(frame)
end)


local ContentArrowMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

function ContentArrowMixin:UpdateAnimation()
    local buttonState = self:GetButtonState()

    if buttonState == "PUSHED" then
        self:background(ARROW_BACKGROUND_PUSHED)
    elseif buttonState == "HIGHLIGHTED" then
        self:background(ARROW_BACKGROUND_HIGHLIGHTED)
    else
        self:background(ARROW_BACKGROUND)
    end
end

function ContentArrowMixin:OnClick()
    if not self.scrollView then return end

    if self.isUp then
        self.scrollView:ScrollToTop()
    else
        self.scrollView:ScrollToBottom()
    end
end

function ContentArrowMixin:OnLoad(parent, scrollView, isUp)
    self:InitButton()

    self.parent = parent
    self.scrollView = scrollView
    self.isUp = isUp

    self:RegisterMouseEvents()
    self:HookButtonStateChange(self.UpdateAnimation)
    self:HookMouseUp(self.OnClick)
    self:UpdateAnimation()

    if isUp then
        self.parent:background(OVERLAY_BACKGROUND_UP)
        self:point(UIKit.Enum.Point.Top)
    else
        self.parent:background(OVERLAY_BACKGROUND_DOWN)
        self:point(UIKit.Enum.Point.Bottom)
        self:backgroundRotation(math.pi)
    end
end

function ContentArrowMixin:Load()
    self.parent:Show()

    ContentArrowAnimation:Play(self.parent, "INTRO")
end

function ContentArrowMixin:Unload()
    ContentArrowAnimation:Play(self.parent, "OUTRO", function()
        self.parent:Hide()
    end)
end

function ContentArrowMixin:isOpen()
    return self.parent:IsShown()
end

UICCommonSelectionMenu.ContentArrow = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Arrow")
                :id("Arrow", id)
                :size(ARROW_SIZE, ARROW_SIZE)
                :background(TEXTURE_NIL)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :background(TEXTURE_NIL)
        :size(OVERLAY_WIDTH, OVERLAY_HEIGHT)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Arrow = UIKit.GetElementById("Arrow", id)

    Mixin(frame.Arrow, ContentArrowMixin)
    return frame
end)


-- Selection Menu
--------------------------------

local MENU_BACKGROUND            = ATLAS{ inset = { 82, 82, 58, 58 }, scale = .7, left = 0 / 320, right = 256 / 320, top = 0 / 192, bottom = 128 / 192 }
local MENU_BACKGROUND_SIZE       = UIKit.Define.Fill{ left = -55, right = -55, top = -40, bottom = -40 }
local MENU_LIST_WIDTH            = UIKit.Define.Percentage{ value = 100 }
local MENU_LIST_HEIGHT           = UIKit.Define.Fit{}
local MENU_CONTENT_WIDTH         = UIKit.Define.Percentage{ value = 100 }
local MENU_CONTENT_HEIGHT        = UIKit.Define.Fit{ delta = 7 }
local MENU_CONTENT_SCROLL_WIDTH  = UIKit.Define.Percentage{ value = 100 }
local MENU_CONTENT_SCROLL_HEIGHT = UIKit.Define.Fit{}


local SelectionMenuAnimation = UIAnim.New()

local IntroAlpha = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :easing(UIAnim.Enum.Easing.ExpoOut)
    :duration(.5)
    :from(0)
    :to(1)

local IntroTranslate = UIAnim.Animate()
    :property(UIAnim.Enum.Property.PosY)
    :easing(UIAnim.Enum.Easing.ExpoOut)
    :duration(.5)
    :from(7.5)
    :to(0)

local OutroAlpha = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :easing(UIAnim.Enum.Easing.ExpoOut)
    :duration(.5)
    :to(0)

local OutroTranslate = UIAnim.Animate()
    :property(UIAnim.Enum.Property.PosY)
    :easing(UIAnim.Enum.Easing.ExpoOut)
    :duration(.5)
    :to(7.5)

SelectionMenuAnimation:State("INTRO", function(frame)
    IntroAlpha:Play(frame.Content)
    IntroTranslate:Play(frame.Content)
end)

SelectionMenuAnimation:State("OUTRO", function(frame)
    OutroAlpha:Play(frame.Content)
    OutroTranslate:Play(frame.Content)
end)


local SelectionMenuMixin = {}

local function handleGlobalMouseClick(self, button)
    if not self:IsShown() then return end -- Not already hidden as the event triggers while this frame is hidden?
    if self:IsMouseOver() then return end -- Not mouse over context menu
    if self.root and self.root:IsMouseOver() then return end -- Not mouse over root frame

    self:Close()
end

function SelectionMenuMixin:OnLoad()
    self.isOpen                     = false
    self.root                       = nil -- Prevent closing from clicking on the root frame such as a button
    self.selectedIndex              = 0
    self.customElementUpdateHandler = nil
    self.onValueChangeHook          = nil

    -- List
    self.List:SetOnElementUpdate(function(...) self:HandleElementUpdate(...) end)

    -- Content arrow indicator
    self.List:HookEvent("OnContentAboveChanged", function(_, hasContentAbove)
        if hasContentAbove then
            self.ArrowUp.Arrow:Load()
        else
            self.ArrowUp.Arrow:Unload()
        end
    end)

    self.List:HookEvent("OnContentBelowChanged", function(_, hasContentBelow)
        if hasContentBelow then
            self.ArrowDown.Arrow:Load()
        else
            self.ArrowDown.Arrow:Unload()
        end
    end)

    self.ArrowUp:Hide()
    self.ArrowDown:Hide()

    -- Hide on click elsewhere
    self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    self:SetScript("OnEvent", handleGlobalMouseClick)
end

function SelectionMenuMixin:HandleElementUpdate(element, index, value)
    element:OnElementUpdate(self, index, value)
end

function SelectionMenuMixin:SetData(data)
    self.List:SetData(data)
    self:_Render()
end

function SelectionMenuMixin:SetSelectedIndex(index)
    self.selectedIndex = index
    self.List:UpdateAllVisibleElements()

    if self.onValueChangeHook then
        self.onValueChangeHook(self.root or self, self.selectedIndex)
    end
end

function SelectionMenuMixin:GetSelectedIndex()
    return self.selectedIndex
end

function SelectionMenuMixin:GetData()
    return self.List:GetData()
end

function SelectionMenuMixin:GetRoot()
    return self.root
end

function SelectionMenuMixin:Open(initialIndex, data, onValueChange, customElementUpdateHandler, point, relativeTo, relativePoint, x, y, root)
    assert(initialIndex, "Invalid variable `initialIndex`")
    assert(data, "Invalid variable `data`")
    assert(point, "Invalid variable `point`")
    assert(relativeTo, "Invalid variable `relativeTo`")
    assert(relativePoint, "Invalid variable `relativePoint`")
    assert(x, "Invalid variable `x`")
    assert(y, "Invalid variable `y`")

    self.customElementUpdateHandler = customElementUpdateHandler or self.customElementUpdateHandler
    self.onValueChangeHook = onValueChange or self.onValueChangeHook
    self.root = root

    -- Positioning
    self:ClearAllPoints()
    self:SetPoint(point, relativeTo, relativePoint, x, y)

    -- Data
    self:SetData(data)
    self:SetSelectedIndex(initialIndex)

    -- Initialize
    self:Show()
    C_Timer.After(0, function() self.List:ScrollToIndex(initialIndex) end)
    SelectionMenuAnimation:Play(self, "INTRO")

    -- Flag as loaded
    self.isOpen = true
end

function SelectionMenuMixin:Close()
    if SelectionMenuAnimation:IsPlaying(self, "OUTRO") then return end

    SelectionMenuAnimation:Play(self, "OUTRO").onFinish(function()
        self:Hide()
    end)

    self.isOpen = false
end

function SelectionMenuMixin:IsOpen()
    return self.isOpen
end


UICCommonSelectionMenu.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Content", {
                Frame(name .. ".Background")
                    :id("Background", id)
                    :frameLevel(2)
                    :size(MENU_BACKGROUND_SIZE)
                    :background(MENU_BACKGROUND)
                    :alpha(.925)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                LazyScrollView(name .. ".List")
                    :id("List", id)
                    :frameLevel(3)
                    :point(UIKit.Enum.Point.Center)
                    :size(MENU_LIST_WIDTH, MENU_LIST_HEIGHT)
                    :maxHeight(UIKit.Define.Num{ value = 275 })
                    :scrollViewContentWidth(MENU_CONTENT_SCROLL_WIDTH)
                    :scrollViewContentHeight(MENU_CONTENT_SCROLL_HEIGHT)
                    :scrollInterpolation(10)
                    :scrollDirection(UIKit.Enum.Direction.Vertical)
                    :poolPrefab(UICCommonSelectionMenu.Row)
                    :lazyScrollViewElementHeight(28)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonSelectionMenu.ContentArrow(name .. ".ArrowUp")
                    :id("ArrowUp", id)
                    :frameLevel(5)
                    :point(UIKit.Enum.Point.Top)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonSelectionMenu.ContentArrow(name .. ".ArrowDown")
                    :id("ArrowDown", id)
                    :frameLevel(5)
                    :point(UIKit.Enum.Point.Bottom)
                    :_excludeFromCalculations()
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(MENU_CONTENT_WIDTH, MENU_CONTENT_HEIGHT)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Content = UIKit.GetElementById("Content", id)
    frame.Background = UIKit.GetElementById("Background", id)
    frame.BackgroundTexture = frame.Background:GetBackground()
    frame.List = UIKit.GetElementById("List", id)
    frame.ArrowUp = UIKit.GetElementById("ArrowUp", id)
    frame.ArrowDown = UIKit.GetElementById("ArrowDown", id)

    frame.List.__parentRef = frame

    Mixin(frame, SelectionMenuMixin)
    frame:OnLoad()
    frame.ArrowUp.Arrow:OnLoad(frame.ArrowUp, frame.List, true)
    frame.ArrowDown.Arrow:OnLoad(frame.ArrowDown, frame.List, false)

    return frame
end)
