local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local Sound = env.modules:Import("packages\\sound")
local UIFont = env.modules:Import("packages\\ui-font")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local UICCommon = env.modules:Import("packages\\uic-common")
local Settings_Enum = env.modules:Import("@\\Settings\\Enum")
local Settings_Preload = env.modules:Import("@\\Settings\\Preload")
local Settings_Widgets = env.modules:New("@\\Settings\\Settings_Widgets")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

do -- Tab
    local CONTENT_Y = -22
    local CONTENT_WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 17 + 5 }
    local CONTENT_HEIGHT = UIKit.UI.P_FILL
    local CONTENT_SCROLL_WIDTH = UIKit.UI.P_FILL
    local CONTENT_SCROLL_HEIGHT = UIKit.Define.Fit{ delta = 240 }
    local LAYOUT_SPACING = 10
    local LAYOUT_WIDTH = UIKit.UI.P_FILL
    local LAYOUT_HEIGHT = UIKit.Define.Fit{ delta = 32 }
    local SCROLLBAR_WIDTH = 10
    local SCROLLBAR_HEIGHT = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 35 }

    local TabMixin = {}

    function TabMixin:PlayIntro()
        self.AnimGroup:Play(self, "Intro")
    end

    TabMixin.AnimGroup = UIAnim.New()
    do
        local Intro = UIAnim.Animate():wait(0.1):property(UIAnim.Enum.Property.Alpha):duration(0.2):from(0):to(1)
        TabMixin.AnimGroup:State("Intro", function(frame)
            frame:SetAlpha(0)
            Intro:Play(frame)
        end)
    end

    Settings_Widgets.Tab = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                ScrollContainer(name .. ".Content", {
                    LayoutVertical(name .. ".Layout", {
                        unpack(children)
                    })
                        :id("Layout", id)
                        :point(UIKit.Enum.Point.Top)
                        :y(CONTENT_Y)
                        :size(LAYOUT_WIDTH, LAYOUT_HEIGHT)
                        :layoutDirection(UIKit.Enum.Direction.Vertical)
                        :layoutSpacing(LAYOUT_SPACING)
                        :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
                })
                    :id("Content", id)
                    :point(UIKit.Enum.Point.Left)
                    :size(CONTENT_WIDTH, CONTENT_HEIGHT)
                    :scrollContainerContentWidth(CONTENT_SCROLL_WIDTH)
                    :scrollContainerContentHeight(CONTENT_SCROLL_HEIGHT)
                    :layoutDirection(UIKit.Enum.Direction.Vertical)
                    :scrollInterpolation(10),

                UICCommon.ScrollBar(name .. ".ScrollBar")
                    :id("ScrollBar", id)
                    :point(UIKit.Enum.Point.Right)
                    :size(SCROLLBAR_WIDTH, SCROLLBAR_HEIGHT)
                    :linkedScrollContainer(UIKit.NewGroupCaptureString("Content", id))
            })
            :point(UIKit.Enum.Point.Center)
            :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
            :_renderBreakpoint()

        frame.Content = UIKit.GetElementById("Content", id)
        frame.ScrollBar = UIKit.GetElementById("ScrollBar", id)
        frame.Layout = UIKit.GetElementById("Layout", id)

        Mixin(frame, TabMixin)

        return frame
    end)
end

do -- Tab Button
    local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = -7 }
    local TEXT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 23 }
    local TEXT_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local TEXT_COLOR_SELECTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local TEXT_ALPHA = 0.5
    local TEXT_ALPHA_HIGHLIGHTED = 1
    local TEXT_ALPHA_PUSHED = 0.75
    local TEXT_ALPHA_SELECTED = 1
    local TEXT_Y = 0
    local TEXT_Y_PUSHED = -1
    local WIDTH = UIKit.Define.Percentage{ value = 100 }
    local HEIGHT = 35

    local TabButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function TabButtonMixin:OnLoad()
        self:InitButton()

        self.isSelected = false

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function TabButtonMixin:SetText(text)
        self.Text:SetText(text)
    end

    function TabButtonMixin:SetSelected(selected)
        self.isSelected = selected
        self:UpdateAnimation()
    end

    function TabButtonMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()

        self.Text:ClearAllPoints()

        if self.isSelected then
            if buttonState == "PUSHED" then
                self.Background:background(Settings_Preload.UIDEF.UITabButtonSelected_Pushed)
                self.Text:SetPoint("CENTER", self, 0, TEXT_Y_PUSHED)
            elseif buttonState == "HIGHLIGHTED" then
                self.Background:background(Settings_Preload.UIDEF.UITabButtonSelected_Highlighted)
                self.Text:SetPoint("CENTER", self, 0, TEXT_Y)
            else
                self.Background:background(Settings_Preload.UIDEF.UITabButtonSelected)
                self.Text:SetPoint("CENTER", self, 0, TEXT_Y)
            end

            self.Text:textColor(TEXT_COLOR_SELECTED)
            self.Text:SetAlpha(TEXT_ALPHA_SELECTED)
        else
            if buttonState == "PUSHED" then
                self.Background:background(Settings_Preload.UIDEF.UITabButton_Pushed)
                self.Text:textColor(TEXT_COLOR)
                self.Text:SetAlpha(TEXT_ALPHA_PUSHED)
                self.Text:SetPoint("CENTER", self, 0, TEXT_Y_PUSHED)
            elseif buttonState == "HIGHLIGHTED" then
                self.Background:background(Settings_Preload.UIDEF.UITabButton_Highlighted)
                self.Text:textColor(TEXT_COLOR)
                self.Text:SetAlpha(TEXT_ALPHA_HIGHLIGHTED)
                self.Text:SetPoint("CENTER", self, 0, TEXT_Y)
            else
                self.Background:background(Settings_Preload.UIDEF.UITabButton)
                self.Text:textColor(TEXT_COLOR)
                self.Text:SetAlpha(TEXT_ALPHA)
                self.Text:SetPoint("CENTER", self, 0, TEXT_Y)
            end
        end
    end

    function TabButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    Settings_Widgets.TabButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Background")
                    :id("Background", id)
                    :size(BACKGROUND_SIZE)
                    :background(UIKit.UI.TEXTURE_NIL)
                    :frameLevel(1)
                    :_excludeFromCalculations(),

                Text(name .. ".Text")
                    :id("Text", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(TEXT_SIZE, TEXT_SIZE)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :textAlignment("LEFT", "MIDDLE")
                    :frameLevel(2)
                    :_updateMode(UIKit.Enum.UpdateMode.UserUpdate)
            })
            :size(WIDTH, HEIGHT)

        frame.Background = UIKit.GetElementById("Background", id)
        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, TabButtonMixin)
        frame:OnLoad()

        return frame
    end)
end

do -- Widgets
    local ACTION_SIZE_NUM = 25
    local ACTION_SIZE_75 = math.ceil(ACTION_SIZE_NUM * 0.75)
    local ACTION_SIZE_100 = math.ceil(ACTION_SIZE_NUM)
    local ACTION_SIZE_125 = math.ceil(ACTION_SIZE_NUM * 1.25)
    local ACTION_SIZE_500 = math.ceil(ACTION_SIZE_NUM * 5)
    local ACTION_SIZE_750 = math.ceil(ACTION_SIZE_NUM * 7.5)
    local ACTION_SIZE_1000 = math.ceil(ACTION_SIZE_NUM * 10)

    do -- Title
        local MAX_WIDTH = 255
        local VERTICAL_SPACING = 11
        local ICON_MASK = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Primitives\\Gradient-TB" }
        local ICON_SIZE = 138
        local WIDTH = UIKit.Define.Percentage{ value = 100 }
        local HEIGHT = 225

        local TitleMixin = {}

        function TitleMixin:SetData(icon, title, description)
            self.IconTexture:SetTexture(icon)
            self.Title:SetText(title)
            self.Description:SetText(description)
        end

        Settings_Widgets.Title = UIKit.Template(function(id, name, children, ...)
            local frame =
                Frame(name, {
                    Frame(name .. ".Container", {
                        Frame(name .. ".Icon")
                            :id("Icon", id)
                            :point(UIKit.Enum.Point.Center)
                            :size(ICON_SIZE, ICON_SIZE)
                            :alpha(0.0975)
                            :background(UIKit.UI.TEXTURE_NIL)
                            :mask(ICON_MASK)
                            :backgroundBlendMode(UIKit.Enum.BlendMode.Add),

                        LayoutVertical(name .. ".Container.LayoutHorizontal.LayoutVertical", {
                            Text(name .. ".Title")
                                :id("Title", id)
                                :fontObject(UIFont.UIFontObjectNormal18)
                                :textAlignment("CENTER", "MIDDLE")
                                :size(UIKit.UI.FIT, UIKit.UI.FIT)
                                :maxWidth(MAX_WIDTH)
                                :_updateMode(UIKit.Enum.UpdateMode.All),

                            Text(name .. ".Description")
                                :id("Description", id)
                                :fontObject(UIFont.UIFontObjectNormal12)
                                :textAlignment("CENTER", "MIDDLE")
                                :size(UIKit.UI.FIT, UIKit.UI.FIT)
                                :maxWidth(MAX_WIDTH)
                                :alpha(0.75)
                                :_updateMode(UIKit.Enum.UpdateMode.All)
                        })
                            :point(UIKit.Enum.Point.Center)
                            :size(UIKit.UI.FIT, UIKit.UI.FIT)
                            :layoutSpacing(VERTICAL_SPACING)
                            :layoutAlignmentH(UIKit.Enum.Direction.Justified)

                    })
                        :point(UIKit.Enum.Point.Center)
                        :size(UIKit.UI.FIT, UIKit.UI.FIT)

                })
                :size(WIDTH, HEIGHT)

            frame.Icon = UIKit.GetElementById("Icon", id)
            frame.IconTexture = frame.Icon:GetTextureFrame()
            frame.Title = UIKit.GetElementById("Title", id)
            frame.Description = UIKit.GetElementById("Description", id)

            Mixin(frame, TitleMixin)

            return frame
        end)
    end

    do -- Container
        local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = -7 }
        local WIDTH = UIKit.Define.Percentage{ value = 100 }
        local HEIGHT = UIKit.Define.Fit{ delta = 25 }
        local CONTENT_WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 25 }
        local CONTENT_HEIGHT = UIKit.Define.Fit{}
        local CONTENT_SPACING = 10
        local CONTAINER_WIDTH = UIKit.Define.Percentage{ value = 100 }
        local CONTAINER_HEIGHT = UIKit.Define.Fit{ delta = 39 }
        local TEXT_CONTAINER_WIDTH = UIKit.Define.Percentage{ value = 100 }
        local TEXT_CONTAINER_HEIGHT = 32
        local TEXT_WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 30 }
        local TEXT_HEIGHT = UIKit.Define.Percentage{ value = 100 }
        local TEXT_X = 15
        local TEXT_Y = 0
        local MAIN_WIDTH = WIDTH
        local MAIN_HEIGHT = HEIGHT
        local MAIN_OFFSET_Y = -32

        local ContainerMixin = {}

        function ContainerMixin:SetSubcontainer(isSubcontainer)
            if isSubcontainer then
                self.Background:background(Settings_Preload.UIDEF.UICSubcontainer)
            else
                self.Background:background(Settings_Preload.UIDEF.UICContainer)
            end
        end

        function ContainerMixin:SetTransparent(isTransparent)
            if isTransparent then
                self.Background:SetAlpha(0)
            else
                self.Background:SetAlpha(1)
            end
        end

        Settings_Widgets.Container = UIKit.Template(function(id, name, children, ...)
            local frame =
                Frame(name, {
                    Frame(name .. ".Background")
                        :id("Background", id)
                        :size(BACKGROUND_SIZE)
                        :background(UIKit.UI.TEXTURE_NIL)
                        :_excludeFromCalculations(),

                    LayoutVertical(name .. ".Content", {
                        unpack(children)
                    })
                        :id("Content", id)
                        :point(UIKit.Enum.Point.Center)
                        :size(CONTENT_WIDTH, CONTENT_HEIGHT)
                        :layoutSpacing(CONTENT_SPACING)
                        :layoutDirection(UIKit.Enum.Direction.Vertical)
                        :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
                })
                :size(WIDTH, HEIGHT)

            frame.Background = UIKit.GetElementById("Background", id)
            frame.Content = UIKit.GetElementById("Content", id)

            Mixin(frame, ContainerMixin)

            return frame
        end)

        Settings_Widgets.ContainerWithTitle = UIKit.Template(function(id, name, children, ...)
            local frame =
                Frame(name, {
                    Frame(name .. ".Title", {
                        Text()
                            :id("Title", id)
                            :point(UIKit.Enum.Point.Left)
                            :fontObject(UIFont.UIFontObjectNormal14)
                            :textAlignment("LEFT", "MIDDLE")
                            :textColor(GenericEnum.UIColorRGB.NORMAL_FONT_COLOR)
                            :size(TEXT_WIDTH, TEXT_HEIGHT)
                            :x(TEXT_X)
                            :y(TEXT_Y)
                            :_excludeFromCalculations()
                    })
                        :point(UIKit.Enum.Point.Top)
                        :size(TEXT_CONTAINER_WIDTH, TEXT_CONTAINER_HEIGHT)
                        :_excludeFromCalculations(),

                    Frame(name .. ".Main", {
                        Frame(name .. ".Background")
                            :id("Background", id)
                            :size(BACKGROUND_SIZE)
                            :background(UIKit.UI.TEXTURE_NIL)
                            :_excludeFromCalculations(),

                        LayoutVertical(name .. ".Content", {
                            unpack(children)
                        })
                            :id("Content", id)
                            :point(UIKit.Enum.Point.Center)
                            :size(CONTENT_WIDTH, CONTENT_HEIGHT)
                            :layoutSpacing(CONTENT_SPACING)
                            :layoutDirection(UIKit.Enum.Direction.Vertical)
                            :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
                    })
                        :id("Main", id)
                        :point(UIKit.Enum.Point.Top)
                        :y(MAIN_OFFSET_Y)
                        :size(MAIN_WIDTH, MAIN_HEIGHT)
                })
                :size(CONTAINER_WIDTH, CONTAINER_HEIGHT)

            frame.Title = UIKit.GetElementById("Title", id)
            frame.Background = UIKit.GetElementById("Background", id)
            frame.Content = UIKit.GetElementById("Content", id)

            Mixin(frame, ContainerMixin)

            return frame
        end)
    end

    do -- Element Base
        local MARGIN = 20
        local MIN_HEIGHT = 17
        local INDENT = 15
        local INFO_TEXT_MAX_WIDTH = UIKit.Define.Percentage{ value = 100 }
        local SPACING = 5
        local IMAGE_SIZE_2x_WIDTH = 300
        local IMAGE_SIZE_2x_HEIGHT = 150
        local IMAGE_SIZE_1x_WIDTH = 150
        local IMAGE_SIZE_1x_HEIGHT = 150
        local WIDTH = UIKit.Define.Percentage{ value = 100 }
        local HEIGHT = UIKit.Define.Fit{}
        local CONTENT_HEIGHT = UIKit.Define.Fit{ delta = MARGIN }
        local INFO_X = math.ceil(MARGIN / 2)
        local INFO_WIDTH = UIKit.Define.Percentage{ value = 55, operator = "-", delta = MARGIN }
        local INFO_HEIGHT = UIKit.Define.Fit{}
        local INFO_IMAGE_HEIGHT = UIKit.Define.Fit{ delta = math.ceil(MARGIN / 2) }
        local ACTION_X = -2
        local ACTION_WIDTH = UIKit.Define.Percentage{ value = 45, operator = "-", delta = MARGIN }
        local ACTION_HEIGHT = UIKit.Define.Percentage{ value = 100 }
        local BACKGROUND_SIZE = UIKit.Define.Fill{ delta = -10 }
        local INDENT_MAP = {}
        for i = 0, 5 do
            INDENT_MAP[i] = {
                x     = INDENT * i,
                width = UIKit.Define.Percentage{ value = 100, operator = "-", delta = INDENT * i }
            }
        end

        local ElementBaseMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

        function ElementBaseMixin:OnLoad()
            self:InitButton()

            self.isTransparent = false

            self.HitRect:onEnter(function() self:OnEnter() end)
            self.HitRect:onLeave(function() self:OnLeave() end)
            self:HookButtonStateChange(self.UpdateAnimation)
            self:UpdateAnimation()
            self:SetIndent(0)
        end

        function ElementBaseMixin:UpdateAnimation()
            local buttonState = self:GetButtonState()
            self.Background:SetShown(not self.isTransparent and buttonState ~= "NORMAL")
        end

        function ElementBaseMixin:SetData(title, description, imagePath, imageSize)
            self.Title:SetShown(title ~= nil)
            if title then self.Title:SetText(title) end

            self.Description:SetShown(description ~= nil)
            if description then self.Description:SetText(description) end

            self.Image:SetShown(imageSize and imagePath)
            if imageSize and imagePath then self:SetImage(imageSize, imagePath) end
        end

        function ElementBaseMixin:SetImage(imageSize, imagePath)
            if imageSize == Settings_Enum.ImageType.Large then
                self.Image.Background:SetSize(IMAGE_SIZE_2x_WIDTH, IMAGE_SIZE_2x_HEIGHT)
                self.Image:SetWidth(IMAGE_SIZE_2x_WIDTH)
            else
                self.Image.Background:SetSize(IMAGE_SIZE_1x_WIDTH, IMAGE_SIZE_1x_HEIGHT)
                self.Image:SetHeight(IMAGE_SIZE_2x_HEIGHT)
            end
            self.Image.BackgroundTexture:SetTexture(imagePath)
        end

        function ElementBaseMixin:SetTransparent(isTransparent)
            self.isTransparent = isTransparent
            self:UpdateAnimation()
        end

        function ElementBaseMixin:SetIndent(indent)
            self.Content:x(INDENT_MAP[indent].x)
            self.Content:width(INDENT_MAP[indent].width)
        end

        Settings_Widgets.ElementBase = UIKit.Template(function(id, name, children, ...)
            local frame =
                Frame(name, {
                    HitRect(name .. ".HitRect")
                        :id("HitRect", id)
                        :size(UIKit.UI.FILL)
                        :frameLevel(1000)
                        :_excludeFromCalculations(),

                    Frame(name .. ".Background")
                        :id("Background", id)
                        :size(BACKGROUND_SIZE)
                        :background(Settings_Preload.UIDEF.UIWidget)
                        :_excludeFromCalculations(),

                    Frame(name .. ".Content", {
                        LayoutVertical(name .. ".Info", {
                            Text(name .. ".Title")
                                :id("Title", id)
                                :fontObject(UIFont.UIFontObjectNormal12)
                                :textAlignment("LEFT", "MIDDLE")
                                :size(UIKit.UI.FIT, UIKit.UI.FIT)
                                :maxWidth(INFO_TEXT_MAX_WIDTH)
                                :_updateMode(UIKit.Enum.UpdateMode.All),

                            Text(name .. ".Description")
                                :id("Description", id)
                                :fontObject(UIFont.UIFontObjectNormal11)
                                :textAlignment("LEFT", "MIDDLE")
                                :size(UIKit.UI.FIT, UIKit.UI.FIT)
                                :maxWidth(INFO_TEXT_MAX_WIDTH)
                                :alpha(0.5)
                                :_updateMode(UIKit.Enum.UpdateMode.All),

                            Frame(name .. ".Image", {
                                Frame(name .. ".Image.Background")
                                    :id("Image.Background", id)
                                    :point(UIKit.Enum.Point.Bottom)
                                    :background(UIKit.UI.TEXTURE_NIL)
                            })
                                :id("Image", id)
                                :height(INFO_IMAGE_HEIGHT)
                        })
                            :id("Info", id)
                            :point(UIKit.Enum.Point.Left)
                            :x(INFO_X)
                            :size(INFO_WIDTH, INFO_HEIGHT)
                            :minHeight(MIN_HEIGHT)
                            :layoutAlignmentH(UIKit.Enum.Direction.Leading)
                            :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                            :layoutSpacing(SPACING),

                        Frame(name .. ".Action", {
                            unpack(children)
                        })
                            :id("Action", id)
                            :point(UIKit.Enum.Point.Right)
                            :x(ACTION_X)
                            :size(ACTION_WIDTH, ACTION_HEIGHT)
                            :_excludeFromCalculations()
                    })
                        :id("Content", id)
                        :point(UIKit.Enum.Point.Left)
                        :height(CONTENT_HEIGHT)
                })
                :size(WIDTH, HEIGHT)

            frame.HitRect = UIKit.GetElementById("HitRect", id)
            frame.Content = UIKit.GetElementById("Content", id)
            frame.Background = UIKit.GetElementById("Background", id)
            frame.Title = UIKit.GetElementById("Title", id)
            frame.Description = UIKit.GetElementById("Description", id)
            frame.Image = UIKit.GetElementById("Image", id)
            frame.Image.Background = UIKit.GetElementById("Image.Background", id)
            frame.Image.BackgroundTexture = frame.Image.Background:GetTextureFrame()
            frame.Info = UIKit.GetElementById("Info", id)
            frame.Action = UIKit.GetElementById("Action", id)

            Mixin(frame, ElementBaseMixin)
            frame:OnLoad()

            return frame
        end)
    end

    do -- Element (Text)
        Settings_Widgets.ElementText = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name)

            return frame
        end)
    end

    do -- Element (Check Button)
        local ElementCheckButtonMixin = {}

        function ElementCheckButtonMixin:GetCheckButton()
            return self.CheckButton
        end

        Settings_Widgets.ElementCheckButton = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name, {
                    UICCommon.CheckButton(name .. ".CheckButton")
                        :id("CheckButton", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(ACTION_SIZE_100, ACTION_SIZE_100)
                })

            frame.CheckButton = UIKit.GetElementById("CheckButton", id)

            Mixin(frame, ElementCheckButtonMixin)

            return frame
        end)
    end

    do -- Element (Button)
        local ElementButtonMixin = {}

        function ElementButtonMixin:GetButton()
            return self.Button
        end

        Settings_Widgets.ElementButton = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name, {
                    UICCommon.RedTextButton(name .. ".Button")
                        :id("Button", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(ACTION_SIZE_750, ACTION_SIZE_125)
                })

            frame.Button = UIKit.GetElementById("Button", id)

            Mixin(frame, ElementButtonMixin)

            return frame
        end)
    end

    do -- Element (Range)
        local ElementRangeMixin = {}

        function ElementRangeMixin:GetRange()
            return self.Range:GetRange()
        end

        Settings_Widgets.ElementRange = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name, {
                    UICCommon.RangeWithText(name .. ".Range")
                        :id("Range", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(ACTION_SIZE_750, ACTION_SIZE_75)
                })

            frame.Range = UIKit.GetElementById("Range", id)

            Mixin(frame, ElementRangeMixin)

            return frame
        end)
    end

    do -- Element (Option Button)
        local ElementSelectionMenuMixin = {}

        function ElementSelectionMenuMixin:GetSelectionMenuButton()
            return self.SelectionMenuButton
        end

        Settings_Widgets.ElementSelectionMenu = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name, {
                    UICCommon.SelectionMenuButton(name .. ".SelectionMenuButton")
                        :id("SelectionMenuButton", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(ACTION_SIZE_500, ACTION_SIZE_125)
                })

            frame.SelectionMenuButton = UIKit.GetElementById("SelectionMenuButton", id)

            Mixin(frame, ElementSelectionMenuMixin)

            return frame
        end)
    end

    do -- Element (Color Input)
        local ElementColorInputMixin = {}

        function ElementColorInputMixin:GetColorInput()
            return self.ColorInput
        end

        Settings_Widgets.ElementColorInput = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name, {
                    UICCommon.ColorInput(name .. ".ColorInput")
                        :id("ColorInput", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(ACTION_SIZE_750, ACTION_SIZE_125)
                })

            frame.ColorInput = UIKit.GetElementById("ColorInput", id)

            Mixin(frame, ElementColorInputMixin)

            return frame
        end)
    end

    do -- Element (Input)
        local ElementInputMixin = {}

        function ElementInputMixin:GetInput()
            return self.Input:GetInput()
        end

        Settings_Widgets.ElementInput = UIKit.Template(function(id, name, children, ...)
            local frame =
                Settings_Widgets.ElementBase(name, {
                    UICCommon.Input(name .. ".Input")
                        :id("Input", id)
                        :point(UIKit.Enum.Point.Right)
                        :size(ACTION_SIZE_750, ACTION_SIZE_125)
                })

            frame.Input = UIKit.GetElementById("Input", id)
            frame.Input.Input:fontSize(14)

            Mixin(frame, ElementInputMixin)

            return frame
        end)
    end
end
