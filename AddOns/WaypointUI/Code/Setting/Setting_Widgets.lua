local env                                                                                                                                          = select(2, ...)
local MixinUtil                                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local Path                                                                                                                                         = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                                        = env.WPM:Import("wpm_modules/sound")
local UIFont                                                                                                                                       = env.WPM:Import("wpm_modules/ui-font")
local GenericEnum                                                                                                                                  = env.WPM:Import("wpm_modules/generic-enum")
local UIKit                                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")

local Mixin                                                                                                                                        = MixinUtil.Mixin
local CreateFromMixins                                                                                                                             = MixinUtil.CreateFromMixins

local UICSharedMixin                                                                                                                               = env.WPM:Import("wpm_modules/uic-sharedmixin")
local UICCommon                                                                                                                                      = env.WPM:Import("wpm_modules/uic-common")
local Setting_Enum                                                                                                                                 = env.WPM:Import("@/Setting/Enum")
local Setting_Widgets                                                                                                                              = env.WPM:New("@/Setting/Setting_Widgets")

-- Shared
--------------------------------

local PATH              = Path.Root .. "/Art/Setting/"

local TEXTURE_NIL       = UIKit.Define.Texture{ path = nil }
local FILL              = UIKit.Define.Fill{}
local P_FILL            = UIKit.Define.Percentage{ value = 100 }
local TEXT_COLOR_YELLOW = UIKit.Define.Color_RGBA{ r = GenericEnum.ColorRGB.Yellow.r * 255, g = GenericEnum.ColorRGB.Yellow.g * 255, b = GenericEnum.ColorRGB.Yellow.b * 255, a = 1 }





-- Tab
--------------------------------

local TAB_CONTENT_Y             = UIKit.Define.Num{ value = -22 }
local TAB_CONTENT_WIDTH         = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 17 + 5 }
local TAB_CONTENT_HEIGHT        = P_FILL
local TAB_CONTENT_SCROLL_WIDTH  = P_FILL
local TAB_CONTENT_SCROLL_HEIGHT = UIKit.Define.Fit{ delta = 240 }
local TAB_LAYOUT_SPACING        = UIKit.Define.Num{ value = 10 }
local TAB_LAYOUT_WIDTH          = P_FILL
local TAB_LAYOUT_HEIGHT         = UIKit.Define.Fit{ delta = 32 }
local TAB_SCROLLBAR_WIDTH       = UIKit.Define.Num{ value = 10 }
local TAB_SCROLLBAR_HEIGHT      = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 35 }


local TabAnimation = UIAnim.New()
local TabAnimation_Intro = UIAnim.Animate()
    :wait(.1)

    :property(UIAnim.Enum.Property.Alpha)
    :duration(.25)
    :from(0)
    :to(1)

TabAnimation:State("Intro", function(frame)
    frame:SetAlpha(0)
    TabAnimation_Intro:Play(frame)
end)


local TabMixin = {}

function TabMixin:PlayIntro()
    TabAnimation:Play(self, "Intro")
end



Setting_Widgets.Tab = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            ScrollView(name .. ".Content", {
                LayoutVertical(name .. ".Layout", {
                    unpack(children)
                })
                    :id("Layout", id)
                    :point(UIKit.Enum.Point.Top)
                    :y(TAB_CONTENT_Y)
                    :size(TAB_LAYOUT_WIDTH, TAB_LAYOUT_HEIGHT)
                    :layoutDirection(UIKit.Enum.Direction.Vertical)
                    :layoutSpacing(TAB_LAYOUT_SPACING)
                    :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Left)
                :size(TAB_CONTENT_WIDTH, TAB_CONTENT_HEIGHT)
                :scrollViewContentWidth(TAB_CONTENT_SCROLL_WIDTH)
                :scrollViewContentHeight(TAB_CONTENT_SCROLL_HEIGHT)
                :layoutDirection(UIKit.Enum.Direction.Vertical)
                :scrollInterpolation(10),

            UICCommon.ScrollBar(name .. ".ScrollBar", {

            })
                :id("ScrollBar", id)
                :point(UIKit.Enum.Point.Right)
                :size(TAB_SCROLLBAR_WIDTH, TAB_SCROLLBAR_HEIGHT)
                :scrollBarTarget("Content", id)

        })
        :point(UIKit.Enum.Point.Center)
        :size(P_FILL, P_FILL)
        :_renderBreakpoint()

    frame.Content = UIKit.GetElementById("Content", id)
    frame.ScrollBar = UIKit.GetElementById("ScrollBar", id)
    frame.Layout = UIKit.GetElementById("Layout", id)

    Mixin(frame, TabMixin)

    return frame
end)





-- Tab Button
--------------------------------

local TB_ATLAS                           = UIKit.Define.Texture_Atlas{ path = PATH .. "TabButton.png", inset = 128 }
local TB_BACKGROUND                      = TB_ATLAS{ left = 0 / 768, top = 0 / 512, right = 256 / 768, bottom = 256 / 512, scale = .575 }
local TB_BACKGROUND_HIGHLIGHTED          = TB_ATLAS{ left = 256 / 768, top = 0 / 512, right = 512 / 768, bottom = 256 / 512, scale = .575 }
local TB_BACKGROUND_PUSHED               = TB_ATLAS{ left = 512 / 768, top = 0 / 512, right = 768 / 768, bottom = 256 / 512, scale = .575 }
local TB_BACKGROUND_SELECTED             = TB_ATLAS{ left = 0 / 768, top = 256 / 512, right = 256 / 768, bottom = 512 / 512, scale = .575 }
local TB_BACKGROUND_SELECTED_HIGHLIGHTED = TB_ATLAS{ left = 256 / 768, top = 256 / 512, right = 512 / 768, bottom = 512 / 512, scale = .575 }
local TB_BACKGROUND_SELECTED_PUSHED      = TB_ATLAS{ left = 512 / 768, top = 256 / 512, right = 768 / 768, bottom = 512 / 512, scale = .575 }
local TB_BACKGROUND_SIZE                 = UIKit.Define.Fill{ delta = -7 }
local TB_TEXT_SIZE                       = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 23 }
local TB_TEXT_COLOR                      = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
local TB_TEXT_COLOR_SELECTED             = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
local TB_TEXT_ALPHA                      = .5
local TB_TEXT_ALPHA_HIGHLIGHTED          = 1
local TB_TEXT_ALPHA_PUSHED               = .75
local TB_TEXT_ALPHA_SELECTED             = 1
local TB_TEXT_Y                          = 0
local TB_TEXT_Y_PUSHED                   = -1
local TB_WIDTH                           = UIKit.Define.Percentage{ value = 100 }
local TB_HEIGHT                          = UIKit.Define.Num{ value = 35 }


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
            self.Background:background(TB_BACKGROUND_SELECTED_PUSHED)
            self.Text:SetPoint("CENTER", self, 0, TB_TEXT_Y_PUSHED)
        elseif buttonState == "HIGHLIGHTED" then
            self.Background:background(TB_BACKGROUND_SELECTED_HIGHLIGHTED)
            self.Text:SetPoint("CENTER", self, 0, TB_TEXT_Y)
        else
            self.Background:background(TB_BACKGROUND_SELECTED)
            self.Text:SetPoint("CENTER", self, 0, TB_TEXT_Y)
        end

        self.Text:textColor(TB_TEXT_COLOR_SELECTED)
        self.Text:SetAlpha(TB_TEXT_ALPHA_SELECTED)
    else
        if buttonState == "PUSHED" then
            self.Background:background(TB_BACKGROUND_PUSHED)
            self.Text:textColor(TB_TEXT_COLOR)
            self.Text:SetAlpha(TB_TEXT_ALPHA_PUSHED)
            self.Text:SetPoint("CENTER", self, 0, TB_TEXT_Y_PUSHED)
        elseif buttonState == "HIGHLIGHTED" then
            self.Background:background(TB_BACKGROUND_HIGHLIGHTED)
            self.Text:textColor(TB_TEXT_COLOR)
            self.Text:SetAlpha(TB_TEXT_ALPHA_HIGHLIGHTED)
            self.Text:SetPoint("CENTER", self, 0, TB_TEXT_Y)
        else
            self.Background:background(TB_BACKGROUND)
            self.Text:textColor(TB_TEXT_COLOR)
            self.Text:SetAlpha(TB_TEXT_ALPHA)
            self.Text:SetPoint("CENTER", self, 0, TB_TEXT_Y)
        end
    end
end

function TabButtonMixin:PlayInteractSound()
    Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end


Setting_Widgets.TabButton = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Background")
                :id("Background", id)
                :size(TB_BACKGROUND_SIZE)
                :background(TEXTURE_NIL)
                :frameLevel(1)

                :_excludeFromCalculations(),

            Text(name .. ".Text")
                :id("Text", id)
                :point(UIKit.Enum.Point.Center)
                :size(TB_TEXT_SIZE, TB_TEXT_SIZE)
                :fontObject(UIFont.UIFontObjectNormal12)
                :textAlignment("LEFT", "MIDDLE")
                :frameLevel(2)
                :_updateMode(UIKit.Enum.UpdateMode.UserUpdate)
        })
        :size(TB_WIDTH, TB_HEIGHT)


    frame.Background = UIKit.GetElementById("Background", id)
    frame.Text = UIKit.GetElementById("Text", id)

    Mixin(frame, TabButtonMixin)
    frame:OnLoad()

    return frame
end)





-- Widget — Title
--------------------------------

local FIT                    = UIKit.Define.Fit{}
local TITLE_MAX_WIDTH        = UIKit.Define.Num{ value = 255 }
local TITLE_VERTICAL_SPACING = UIKit.Define.Num{ value = 11 }
local TITLE_IMAGE_MASK       = UIKit.Define.Texture{ path = Path.Root .. "/Art/Shape/GradientUp.png" }
local TITLE_IMAGE_SIZE       = UIKit.Define.Num{ value = 138 }
local TITLE_WIDTH            = UIKit.Define.Percentage{ value = 100 }
local TITLE_HEIGHT           = UIKit.Define.Num{ value = 225 }


local TitleMixin = {}

function TitleMixin:SetInfo(image, title, description)
    self.SplashTexture:SetTexture(image)
    self.Title:SetText(title)
    self.Description:SetText(description)
end

Setting_Widgets.Title = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Container", {
                Frame(name .. ".Splash")
                    :id("Splash", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(TITLE_IMAGE_SIZE, TITLE_IMAGE_SIZE)
                    :alpha(.0975)
                    :background(TEXTURE_NIL)
                    :mask(TITLE_IMAGE_MASK)
                    :backgroundBlendMode(UIKit.Enum.BlendMode.Add),

                LayoutVertical(name .. ".Container.LayoutHorizontal.LayoutVertical", {
                    Text(name .. ".Title")
                        :id("Title", id)
                        :fontObject(UIFont.UIFontObjectNormal18)
                        :textAlignment("CENTER", "MIDDLE")
                        :size(FIT, FIT)
                        :maxWidth(TITLE_MAX_WIDTH)
                        :_updateMode(UIKit.Enum.UpdateMode.All),

                    Text(name .. ".Description")
                        :id("Description", id)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textAlignment("CENTER", "MIDDLE")
                        :size(FIT, FIT)
                        :maxWidth(TITLE_MAX_WIDTH)
                        :alpha(.75)
                        :_updateMode(UIKit.Enum.UpdateMode.All)
                })
                    :point(UIKit.Enum.Point.Center)
                    :size(FIT, FIT)
                    :layoutSpacing(TITLE_VERTICAL_SPACING)
                    :layoutAlignmentH(UIKit.Enum.Direction.Justified)

            })
                :point(UIKit.Enum.Point.Center)
                :size(FIT, FIT)

        })
        :size(TITLE_WIDTH, TITLE_HEIGHT)


    frame.Splash = UIKit.GetElementById("Splash", id)
    frame.SplashTexture = frame.Splash:GetBackground()
    frame.Title = UIKit.GetElementById("Title", id)
    frame.Description = UIKit.GetElementById("Description", id)

    Mixin(frame, TitleMixin)

    return frame
end)





-- Widget — Container
--------------------------------

local C_ATLAS           = UIKit.Define.Texture_Atlas{ path = PATH .. "WidgetContainer.png", inset = 70, sliceMode = Enum.UITextureSliceMode.Stretched }
local C_BACKGROUND      = C_ATLAS{ left = 0 / 512, right = 256 / 512, top = 0 / 512, bottom = 256 / 512, scale = .25 }
local C_BACKGROUND_SUB  = C_ATLAS{ left = 256 / 512, right = 512 / 512, top = 0 / 512, bottom = 256 / 512, scale = .25 }
local C_BACKGROUND_SIZE = UIKit.Define.Fill{ delta = -7 }
local C_WIDTH           = UIKit.Define.Percentage{ value = 100 }
local C_HEIGHT          = UIKit.Define.Fit{ delta = 25 }
local C_CONTENT_WIDTH   = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 25 }
local C_CONTENT_HEIGHT  = UIKit.Define.Fit{}
local C_CONTENT_SPACING = UIKit.Define.Num{ value = 10 }


local ContainerMixin = {}

function ContainerMixin:SetSubcontainer(isSubcontainer)
    if isSubcontainer then
        self.Background:background(C_BACKGROUND_SUB)
    else
        self.Background:background(C_BACKGROUND)
    end
end

function ContainerMixin:SetTransparent(isTransparent)
    if isTransparent then
        self.Background:SetAlpha(0)
    else
        self.Background:SetAlpha(1)
    end
end


Setting_Widgets.Container = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Background")
                :id("Background", id)
                :size(C_BACKGROUND_SIZE)
                :background(TEXTURE_NIL)
                :_excludeFromCalculations(),

            LayoutVertical(name .. ".Content", {
                unpack(children)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(C_CONTENT_WIDTH, C_CONTENT_HEIGHT)
                :layoutSpacing(C_CONTENT_SPACING)
                :layoutDirection(UIKit.Enum.Direction.Vertical)
                :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
        })
        :size(C_WIDTH, C_HEIGHT)


    frame.Background = UIKit.GetElementById("Background", id)
    frame.Content = UIKit.GetElementById("Content", id)

    Mixin(frame, ContainerMixin)

    return frame
end)


local C_TITLE_WIDTH                 = UIKit.Define.Percentage{ value = 100 }
local C_TITLE_HEIGHT                = UIKit.Define.Fit{ delta = 39 }
local C_TITLE_TEXT_CONTAINER_WIDTH  = UIKit.Define.Percentage{ value = 100 }
local C_TITLE_TEXT_CONTAINER_HEIGHT = UIKit.Define.Num{ value = 32 }
local C_TITLE_TEXT_WIDTH            = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 30 }
local C_TITLE_TEXT_HEIGHT           = UIKit.Define.Percentage{ value = 100 }
local C_TITLE_TEXT_X                = UIKit.Define.Num{ value = 15 }
local C_TITLE_TEXT_Y                = UIKit.Define.Num{ value = 0 }
local C_MAIN_WIDTH                  = C_WIDTH
local C_MAIN_HEIGHT                 = C_HEIGHT
local C_MAIN_OFFSET_Y               = UIKit.Define.Num{ value = -32 }


Setting_Widgets.ContainerWithTitle = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            Frame(name .. ".Title", {
                Text()
                    :id("Title", id)
                    :point(UIKit.Enum.Point.Left)
                    :fontObject(UIFont.UIFontObjectNormal14)
                    :textAlignment("LEFT", "MIDDLE")
                    :textColor(TEXT_COLOR_YELLOW)
                    :size(C_TITLE_TEXT_WIDTH, C_TITLE_TEXT_HEIGHT)
                    :x(C_TITLE_TEXT_X)
                    :y(C_TITLE_TEXT_Y)
                    :_excludeFromCalculations()

            })
                :point(UIKit.Enum.Point.Top)
                :size(C_TITLE_TEXT_CONTAINER_WIDTH, C_TITLE_TEXT_CONTAINER_HEIGHT)
                :_excludeFromCalculations(),

            Frame(name .. ".Main", {
                Frame(name .. ".Background")
                    :id("Background", id)
                    :size(C_BACKGROUND_SIZE)
                    :background(TEXTURE_NIL)
                    :_excludeFromCalculations(),

                LayoutVertical(name .. ".Content", {
                    unpack(children)
                })
                    :id("Content", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(C_CONTENT_WIDTH, C_CONTENT_HEIGHT)
                    :layoutSpacing(C_CONTENT_SPACING)
                    :layoutDirection(UIKit.Enum.Direction.Vertical)
                    :_updateMode(UIKit.Enum.UpdateMode.ChildrenVisibilityChanged)
            })
                :id("Main", id)
                :point(UIKit.Enum.Point.Top)
                :y(C_MAIN_OFFSET_Y)
                :size(C_MAIN_WIDTH, C_MAIN_HEIGHT)

        })
        :size(C_TITLE_WIDTH, C_TITLE_HEIGHT)


    frame.Title = UIKit.GetElementById("Title", id)
    frame.Background = UIKit.GetElementById("Background", id)
    frame.Content = UIKit.GetElementById("Content", id)

    Mixin(frame, ContainerMixin)

    return frame
end)





-- Widget — Shared
--------------------------------

local E_ACTION_SIZE_NUM  = 25
local E_ACTION_SIZE_75   = UIKit.Define.Num{ value = math.ceil(E_ACTION_SIZE_NUM * .75) }
local E_ACTION_SIZE_100  = UIKit.Define.Num{ value = math.ceil(E_ACTION_SIZE_NUM) }
local E_ACTION_SIZE_125  = UIKit.Define.Num{ value = math.ceil(E_ACTION_SIZE_NUM * 1.25) }
local E_ACTION_SIZE_500  = UIKit.Define.Num{ value = math.ceil(E_ACTION_SIZE_NUM * 5) }
local E_ACTION_SIZE_750  = UIKit.Define.Num{ value = math.ceil(E_ACTION_SIZE_NUM * 7.5) }
local E_ACTION_SIZE_1000 = UIKit.Define.Num{ value = math.ceil(E_ACTION_SIZE_NUM * 10) }





-- Widget — Element Base
--------------------------------

local E_BACKGROUND           = UIKit.Define.Texture_NineSlice{ path = PATH .. "WidgetBackground.png", inset = 70, scale = .125, sliceMode = Enum.UITextureSliceMode.Stretched }

local E_MARGIN               = 20
local E_MIN_HEIGHT           = UIKit.Define.Num{ value = 17 }
local E_INDENT               = 15
local E_INFO_TEXT_MAX_WIDTH  = UIKit.Define.Percentage{ value = 100 }
local E_SPACING              = UIKit.Define.Num{ value = 5 }
local E_IMAGE_SIZE_2x_WIDTH  = 200
local E_IMAGE_SIZE_2x_HEIGHT = 100
local E_IMAGE_SIZE_1x_WIDTH  = 100
local E_IMAGE_SIZE_1x_HEIGHT = 100

local E_WIDTH                = UIKit.Define.Percentage{ value = 100 }
local E_HEIGHT               = UIKit.Define.Fit{}
local E_CONTENT_HEIGHT       = UIKit.Define.Fit{ delta = E_MARGIN }
local E_INFO_OFFSET_X        = UIKit.Define.Num{ value = math.ceil(E_MARGIN / 2) }
local E_INFO_WIDTH           = UIKit.Define.Percentage{ value = 55, operator = "-", delta = E_MARGIN }
local E_INFO_HEIGHT          = UIKit.Define.Fit{}
local E_ACTION_OFFSET_X      = UIKit.Define.Num{ value = -math.ceil(E_MARGIN / 2 - 3) }
local E_ACTION_WIDTH         = UIKit.Define.Percentage{ value = 45, operator = "-", delta = E_MARGIN }
local E_ACTION_HEIGHT        = UIKit.Define.Percentage{ value = 100 }
local E_BACKGROUND_SIZE      = UIKit.Define.Fill{ delta = -10 }

local INDENT_MAP             = {}
for i = 0, 5 do
    INDENT_MAP[i] = {
        ["x"]     = UIKit.Define.Num{ value = E_INDENT * i },
        ["width"] = UIKit.Define.Percentage{ value = 100, operator = "-", delta = E_INDENT * i }
    }
end


local ElementBaseMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

function ElementBaseMixin:OnLoad()
    self:InitButton()

    self.isTransparent = false

    self.Hitbox:onEnter(function() self:OnEnter() end)
    self.Hitbox:onLeave(function() self:OnLeave() end)
    self:HookButtonStateChange(self.UpdateAnimation)
    self:UpdateAnimation()
end

function ElementBaseMixin:UpdateAnimation()
    local buttonState = self:GetButtonState()
    self.Background:SetShown(not self.isTransparent and buttonState ~= "NORMAL")
end

function ElementBaseMixin:SetInfo(title, description, imageSize, imagePath)
    -- Title
    self.Title:SetShown(title ~= nil)
    if title then self.Title:SetText(title) end

    -- Description
    self.Description:SetShown(description ~= nil)
    if description then self.Description:SetText(description) end

    -- Image
    self.Image:SetShown(imageSize and imagePath)
    if imageSize and imagePath then self:SetImage(imageSize, imagePath) end
end

function ElementBaseMixin:SetImage(imageSize, imagePath)
    if imageSize == Setting_Enum.ImageType.Large then
        self.Image:SetSize(E_IMAGE_SIZE_2x_WIDTH, E_IMAGE_SIZE_2x_HEIGHT)
    else
        self.Image:SetSize(E_IMAGE_SIZE_1x_WIDTH, E_IMAGE_SIZE_1x_HEIGHT)
    end

    self.ImageTexture:SetTexture(imagePath)
end

function ElementBaseMixin:SetTransparent(isTransparent)
    self.isTransparent = isTransparent
    self:UpdateAnimation()
end

function ElementBaseMixin:SetIndent(indent)
    self.Content:x(INDENT_MAP[indent].x)
    self.Content:width(INDENT_MAP[indent].width)
end


Setting_Widgets.ElementBase = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            InteractiveRect(name .. ".Hitbox")
                :id("Hitbox", id)
                :size(FILL)
                :frameLevel(1000)
                :_excludeFromCalculations(),

            Frame(name .. ".Background")
                :id("Background", id)
                :size(E_BACKGROUND_SIZE)
                :background(E_BACKGROUND)
                :_excludeFromCalculations(),

            Frame(name .. ".Content", {
                LayoutVertical(name .. ".Info", {
                    Text(name .. ".Title")
                        :id("Title", id)
                        :fontObject(UIFont.UIFontObjectNormal12)
                        :textAlignment("LEFT", "MIDDLE")
                        :size(FIT, FIT)
                        :maxWidth(E_INFO_TEXT_MAX_WIDTH)
                        :_updateMode(UIKit.Enum.UpdateMode.All),

                    Frame(name .. ".Image")
                        :id("Image", id)
                        :background(TEXTURE_NIL),

                    Text(name .. ".Description")
                        :id("Description", id)
                        :fontObject(UIFont.UIFontObjectNormal10)
                        :textAlignment("LEFT", "MIDDLE")
                        :size(FIT, FIT)
                        :maxWidth(E_INFO_TEXT_MAX_WIDTH)
                        :alpha(.5)
                        :_updateMode(UIKit.Enum.UpdateMode.All)
                })
                    :id("Info", id)
                    :point(UIKit.Enum.Point.Left)
                    :x(E_INFO_OFFSET_X)
                    :size(E_INFO_WIDTH, E_INFO_HEIGHT)
                    :minHeight(E_MIN_HEIGHT)
                    :layoutAlignmentH(UIKit.Enum.Direction.Leading)
                    :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                    :layoutSpacing(E_SPACING),

                Frame(name .. ".Action", {
                    unpack(children)
                })
                    :id("Action", id)
                    :point(UIKit.Enum.Point.Right)
                    :x(E_ACTION_OFFSET_X)
                    :size(E_ACTION_WIDTH, E_ACTION_HEIGHT)

                    :_excludeFromCalculations()
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Left)
                :height(E_CONTENT_HEIGHT)

        })
        :size(E_WIDTH, E_HEIGHT)


    frame.Hitbox = UIKit.GetElementById("Hitbox", id)
    frame.Content = UIKit.GetElementById("Content", id)
    frame.Background = UIKit.GetElementById("Background", id)
    frame.Title = UIKit.GetElementById("Title", id)
    frame.Image = UIKit.GetElementById("Image", id)
    frame.ImageTexture = frame.Image:GetBackground()
    frame.Description = UIKit.GetElementById("Description", id)
    frame.Info = UIKit.GetElementById("Info", id)
    frame.Action = UIKit.GetElementById("Action", id)

    Mixin(frame, ElementBaseMixin)
    frame:OnLoad()
    frame:SetIndent(0)

    return frame
end)





-- Widget — Element / Text
--------------------------------

Setting_Widgets.ElementText = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name)

    return frame
end)





-- Widget — Element / CheckButton
--------------------------------

local ElementCheckButtonMixin = {}

function ElementCheckButtonMixin:GetCheckButton()
    return self.CheckButton
end

Setting_Widgets.ElementCheckButton = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name, {
            UICCommon.CheckButton(name .. ".CheckButton")
                :id("CheckButton", id)
                :point(UIKit.Enum.Point.Right)
                :size(E_ACTION_SIZE_100, E_ACTION_SIZE_100)

        })


    frame.CheckButton = UIKit.GetElementById("CheckButton", id)

    Mixin(frame, ElementCheckButtonMixin)

    return frame
end)





-- Widget — Element / Button
--------------------------------

local ElementButtonMixin = {}

function ElementButtonMixin:GetButton()
    return self.Button
end

Setting_Widgets.ElementButton = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name, {
            UICCommon.ButtonRedWithText(name .. ".Button")
                :id("Button", id)
                :point(UIKit.Enum.Point.Right)
                :size(E_ACTION_SIZE_750, E_ACTION_SIZE_125)

        })


    frame.Button = UIKit.GetElementById("Button", id)

    Mixin(frame, ElementButtonMixin)

    return frame
end)






-- Widget — Element / Range
--------------------------------

local ElementRangeMixin = {}

function ElementRangeMixin:GetRange()
    return self.Range:GetRange()
end

Setting_Widgets.ElementRange = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name, {
            UICCommon.RangeWithText(name .. ".Range")
                :id("Range", id)
                :point(UIKit.Enum.Point.Right)
                :size(E_ACTION_SIZE_750, E_ACTION_SIZE_75)

        })


    frame.Range = UIKit.GetElementById("Range", id)

    Mixin(frame, ElementRangeMixin)

    return frame
end)






-- Widget — Element / Option Button
--------------------------------

local ElementSelectionMenuMixin = {}

function ElementSelectionMenuMixin:GetButtonSelectionMenu()
    return self.ButtonSelectionMenu
end

Setting_Widgets.ElementSelectionMenu = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name, {
            UICCommon.ButtonSelectionMenu(name .. ".ButtonSelectionMenu")
                :id("ButtonSelectionMenu", id)
                :point(UIKit.Enum.Point.Right)
                :size(E_ACTION_SIZE_500, E_ACTION_SIZE_125)

        })


    frame.ButtonSelectionMenu = UIKit.GetElementById("ButtonSelectionMenu", id)

    Mixin(frame, ElementSelectionMenuMixin)

    return frame
end)





-- Widget — Element / Color Input
--------------------------------

local ElementColorInputMixin = {}

function ElementColorInputMixin:GetColorInput()
    return self.ColorInput
end

Setting_Widgets.ElementColorInput = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name, {
            UICCommon.ColorInput(name .. ".ColorInput")
                :id("ColorInput", id)
                :point(UIKit.Enum.Point.Right)
                :size(E_ACTION_SIZE_750, E_ACTION_SIZE_125)

        })


    frame.ColorInput = UIKit.GetElementById("ColorInput", id)

    Mixin(frame, ElementColorInputMixin)

    return frame
end)





-- Widget — Element / Input
--------------------------------

local ElementInputMixin = {}

function ElementInputMixin:GetInput()
    return self.Input:GetInput()
end

Setting_Widgets.ElementInput = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Setting_Widgets.ElementBase(name, {
            UICCommon.Input(name .. ".Input")
                :id("Input", id)
                :point(UIKit.Enum.Point.Right)
                :size(E_ACTION_SIZE_750, E_ACTION_SIZE_125)

        })


    frame.Input = UIKit.GetElementById("Input", id)
    frame.Input.Input:fontSize(14)

    Mixin(frame, ElementInputMixin)

    return frame
end)
