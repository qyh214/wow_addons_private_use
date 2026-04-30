local env = select(2, ...)
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommonPreload = env.modules:Import("packages\\uic-common\\preload")
local UICCommonSelectionMenu = env.modules:New("packages\\uic-common\\selection-menu")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

local UIDEF = {
    UIRow               = UICCommonPreload.ATLAS{ inset = 4, scale = 1, left = 401 / 512, right = 433 / 512, top = 102 / 512, bottom = 118 / 512 },
    UIMenu              = UICCommonPreload.ATLAS{ inset = { 35, 35, 22, 51 }, scale = 0.9, left = 192 / 512, right = 319 / 512, top = 98 / 512, bottom = 192 / 512 },
    UIArrow             = UICCommonPreload.ATLAS{ left = 319 / 512, right = 345 / 512, top = 137 / 512, bottom = 163 / 512 },
    UIArrow_Highlighted = UICCommonPreload.ATLAS{ left = 349 / 512, right = 375 / 512, top = 137 / 512, bottom = 163 / 512 },
    UIArrow_Pushed      = UICCommonPreload.ATLAS{ left = 380 / 512, right = 406 / 512, top = 137 / 512, bottom = 163 / 512 },
    UIEdgeFade_Top      = UICCommonPreload.ATLAS{ inset = 0, left = 321 / 512, right = 353 / 512, top = 102 / 512, bottom = 134 / 512 },
    UIEdgeFade_Bottom   = UICCommonPreload.ATLAS{ inset = 0, left = 361 / 512, right = 393 / 512, top = 102 / 512, bottom = 134 / 512 }
}

do -- Row
    local WIDTH = UIKit.Define.Percentage{ value = 100 }
    local HEIGHT = 28
    local BACKGROUND_COLOR = UIKit.Define.Color_RGBA{ r = 125, g = 125, b = 125, a = 0 }
    local BACKGROUND_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 125, g = 125, b = 125, a = 0.25 }
    local BACKGROUND_COLOR_PUSHED = UIKit.Define.Color_RGBA{ r = 125, g = 125, b = 125, a = 0.175 }
    local TEXT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 12.5 }
    local TEXT_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 0.75 }
    local TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local TEXT_COLOR_SELECTED = GenericEnum.UIColorRGB.NORMAL_FONT_COLOR
    local TEXT_Y_PUSHED = -1
    local TEXT_Y = 0

    local RowMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function RowMixin:OnLoad()
        self:InitButton()

        self.isSelected = false
        self.__parentRef = nil
        self.__index = nil

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.Row_OnClick)
    end

    function RowMixin:Row_OnClick()
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
                self:backgroundColor(BACKGROUND_COLOR_PUSHED)
                self.Text:textColor(TEXT_COLOR_SELECTED)
            elseif buttonState == "HIGHLIGHTED" then
                self:backgroundColor(BACKGROUND_COLOR_HIGHLIGHTED)
                self.Text:textColor(TEXT_COLOR_SELECTED)
            else
                self:backgroundColor(BACKGROUND_COLOR)
                self.Text:textColor(TEXT_COLOR_SELECTED)
            end
        else
            if buttonState == "PUSHED" then
                self:backgroundColor(BACKGROUND_COLOR_PUSHED)
                self.Text:textColor(TEXT_COLOR_HIGHLIGHTED)
            elseif buttonState == "HIGHLIGHTED" then
                self:backgroundColor(BACKGROUND_COLOR_HIGHLIGHTED)
                self.Text:textColor(TEXT_COLOR_HIGHLIGHTED)
            else
                self:backgroundColor(BACKGROUND_COLOR)
                self.Text:textColor(TEXT_COLOR)
            end
        end

        self.Text:ClearAllPoints()
        self.Text:SetPoint("CENTER", self, 0, buttonState == "PUSHED" and TEXT_Y_PUSHED or TEXT_Y)
    end

    UICCommonSelectionMenu.Row = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(TEXT_SIZE, TEXT_SIZE)
                    :fontObject(UIFont.UIFontObjectNormal14)
                    :textColor(TEXT_COLOR)
                    :textAlignment("LEFT", "MIDDLE")
            })
            :background(UIDEF.UIRow)
            :backgroundColor(BACKGROUND_COLOR)
            :size(WIDTH, HEIGHT)

        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, RowMixin)
        frame:OnLoad()

        return frame
    end)
end

do -- Content Arrow
    local ARROW_SIZE = 11
    local EDGE_FADE_WIDTH = UIKit.Define.Percentage{ value = 100 }
    local EDGE_FADE_HEIGHT = 35

    local ContentArrowMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function ContentArrowMixin:OnLoad(parent, scrollContainer, isTop)
        self:InitButton()

        self.parent = parent
        self.scrollContainer = scrollContainer
        self.isTop = isTop

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.ContextArrow_OnClick)
        self:UpdateAnimation()

        if isTop then
            self.parent:background(UIDEF.UIEdgeFade_Top)
            self:point(UIKit.Enum.Point.Top)
        else
            self.parent:background(UIDEF.UIEdgeFade_Bottom)
            self:point(UIKit.Enum.Point.Bottom)
            self:backgroundRotation(math.pi)
        end
    end

    function ContentArrowMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        if buttonState == "PUSHED" then
            self:background(UIDEF.UIArrow_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self:background(UIDEF.UIArrow_Highlighted)
        else
            self:background(UIDEF.UIArrow)
        end
    end

    function ContentArrowMixin:ContextArrow_OnClick()
        if not self.scrollContainer then return end

        if self.isTop then
            self.scrollContainer:ScrollToTop()
        else
            self.scrollContainer:ScrollToBottom()
        end
    end

    function ContentArrowMixin:Reveal()
        self.parent:Show()
        self.AnimGroup:Play(self.parent, "INTRO")
    end

    function ContentArrowMixin:Conceal()
        self.AnimGroup:Play(self.parent, "OUTRO", function()
            self.parent:Hide()
        end)
    end

    function ContentArrowMixin:IsRevealed()
        return self.parent:IsShown()
    end

    ContentArrowMixin.AnimGroup = UIAnim.New()
    do
        local IntroAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.125):from(0):to(1)
        local OutroAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.125):to(0)
        ContentArrowMixin.AnimGroup:State("INTRO", function(frame)
            IntroAlpha:Play(frame)
        end)
        ContentArrowMixin.AnimGroup:State("OUTRO", function(frame)
            OutroAlpha:Play(frame)
        end)
    end

    UICCommonSelectionMenu.ContentArrow = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Arrow")
                    :id("Arrow", id)
                    :size(ARROW_SIZE, ARROW_SIZE)
                    :background(UIKit.UI.TEXTURE_NIL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIKit.UI.TEXTURE_NIL)
            :size(EDGE_FADE_WIDTH, EDGE_FADE_HEIGHT)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Arrow = UIKit.GetElementById("Arrow", id)

        Mixin(frame.Arrow, ContentArrowMixin)

        return frame
    end)
end

do -- Selection Menu
    local BACKGROUND_SIZE = UIKit.Define.Fill{ left = -33, right = -33, top = -20, bottom = -45 }
    local LIST_WIDTH = UIKit.Define.Percentage{ value = 100 }
    local LIST_HEIGHT = UIKit.Define.Fit{}
    local CONTENT_WIDTH = UIKit.Define.Percentage{ value = 100 }
    local CONTENT_HEIGHT = UIKit.Define.Fit{ delta = 7 }
    local CONTENT_SCROLL_WIDTH = UIKit.Define.Percentage{ value = 100 }
    local CONTENT_SCROLL_HEIGHT = UIKit.Define.Fit{}

    local SelectionMenuMixin = {}

    local function UpdateArrowVisibility(arrow, shouldReveal)
        if shouldReveal then
            arrow:Reveal()
        else
            arrow:Conceal()
        end
    end

    local function OnGlobalMouseClick(self, button)
        if not self:IsShown() then return end
        if self:IsMouseOver() then return end
        if self.root and self.root:IsMouseOver() then return end

        self:Close()
    end

    function SelectionMenuMixin:OnLoad()
        self.isOpen = false
        self.root = nil
        self.selectedIndex = 0
        self.customElementUpdateHandler = nil
        self.onValueChangeHook = nil

        self.List:SetOnElementUpdate(function(...) self:HandleElementUpdate(...) end)
        self.List:HookEvent("OnContentAboveChanged", function(_, hasContentAbove)
            UpdateArrowVisibility(self.ArrowUp.Arrow, hasContentAbove)
        end)
        self.List:HookEvent("OnContentBelowChanged", function(_, hasContentBelow)
            UpdateArrowVisibility(self.ArrowDown.Arrow, hasContentBelow)
        end)

        self.ArrowUp:Hide()
        self.ArrowDown:Hide()

        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
        self:SetScript("OnEvent", OnGlobalMouseClick)
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

        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, x, y)

        self:SetData(data)
        self:SetSelectedIndex(initialIndex)

        self:Show()
        C_Timer.After(0, function() self.List:ScrollToIndex(initialIndex) end)
        self.AnimGroup:Play(self, "INTRO")

        self.isOpen = true
    end

    function SelectionMenuMixin:Close()
        if self.AnimGroup:IsPlaying(self, "OUTRO") then return end
        self.AnimGroup:Play(self, "OUTRO"):onFinish(function()
            self:Hide()
        end)
        self.isOpen = false
    end

    function SelectionMenuMixin:IsOpen()
        return self.isOpen
    end

    SelectionMenuMixin.AnimGroup = UIAnim.New()
    do
        local IntroAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.ExpoOut):duration(0.5):from(0):to(1)
        local IntroTranslate = UIAnim.Animate():property(UIAnim.Enum.Property.PosY):easing(UIAnim.Enum.Easing.ExpoOut):duration(0.5):from(7):to(0)
        SelectionMenuMixin.AnimGroup:State("INTRO", function(frame)
            frame.Content:SetAlpha(0)
            IntroAlpha:Play(frame.Content)
            IntroTranslate:Play(frame.Content)
        end)

        local OutroAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.ExpoOut):duration(0.5):to(0)
        local OutroTranslate = UIAnim.Animate():property(UIAnim.Enum.Property.PosY):easing(UIAnim.Enum.Easing.ExpoOut):duration(0.5):to(7)
        SelectionMenuMixin.AnimGroup:State("OUTRO", function(frame)
            OutroAlpha:Play(frame.Content)
            OutroTranslate:Play(frame.Content)
        end)
    end

    UICCommonSelectionMenu.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Content", {
                    Frame(name .. ".Background")
                        :id("Background", id)
                        :frameLevel(2)
                        :size(BACKGROUND_SIZE)
                        :background(UIDEF.UIMenu)
                        :alpha(0.925)
                        :_excludeFromCalculations()
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                    LazyScrollContainer(name .. ".List")
                        :id("List", id)
                        :frameLevel(3)
                        :point(UIKit.Enum.Point.Center)
                        :size(LIST_WIDTH, LIST_HEIGHT)
                        :maxHeight(275)
                        :scrollContainerContentWidth(CONTENT_SCROLL_WIDTH)
                        :scrollContainerContentHeight(CONTENT_SCROLL_HEIGHT)
                        :scrollInterpolation(10)
                        :scrollDirection(UIKit.Enum.Direction.Vertical)
                        :poolTemplate(UICCommonSelectionMenu.Row)
                        :lazyScrollContainerElementHeight(28)
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
                    :size(CONTENT_WIDTH, CONTENT_HEIGHT)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Content = UIKit.GetElementById("Content", id)
        frame.Background = UIKit.GetElementById("Background", id)
        frame.BackgroundTexture = frame.Background:GetTextureFrame()
        frame.List = UIKit.GetElementById("List", id)
        frame.ArrowUp = UIKit.GetElementById("ArrowUp", id)
        frame.ArrowDown = UIKit.GetElementById("ArrowDown", id)

        Mixin(frame, SelectionMenuMixin)
        frame:OnLoad()
        frame.ArrowUp.Arrow:OnLoad(frame.ArrowUp, frame.List, true)
        frame.ArrowDown.Arrow:OnLoad(frame.ArrowDown, frame.List, false)

        frame.List.__parentRef = frame

        return frame
    end)
end
