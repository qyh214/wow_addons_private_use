local env                                                                                                                                          = select(2, ...)
local GenericEnum                                                                                                                                  = env.WPM:Import("wpm_modules/generic-enum")
local MixinUtil                                                                                                                                    = env.WPM:Import("wpm_modules/mixin-util")
local CallbackRegistry                                                                                                                             = env.WPM:Import("wpm_modules/callback-registry")
local Path                                                                                                                                         = env.WPM:Import("wpm_modules/path")
local Sound                                                                                                                                        = env.WPM:Import("wpm_modules/sound")
local UIFont                                                                                                                                       = env.WPM:Import("wpm_modules/ui-font")
local UIKit                                                                                                                                        = env.WPM:Import("wpm_modules/ui-kit")
local Frame, LayoutGrid, LayoutVertical, LayoutHorizontal, ScrollView, ScrollBar, Text, Input, LinearSlider, InteractiveRect, LazyScrollView, List = UIKit.UI.Frame, UIKit.UI.LayoutGrid, UIKit.UI.LayoutVertical, UIKit.UI.LayoutHorizontal, UIKit.UI.ScrollView, UIKit.UI.ScrollBar, UIKit.UI.Text, UIKit.UI.Input, UIKit.UI.LinearSlider, UIKit.UI.InteractiveRect, UIKit.UI.LazyScrollView, UIKit.UI.List
local UIAnim                                                                                                                                       = env.WPM:Import("wpm_modules/ui-anim")
local UICSharedMixin                                                                                                                               = env.WPM:Import("wpm_modules/uic-sharedmixin")
local Utils_Texture                                                                                                                                = env.WPM:Import("wpm_modules/utils/texture")
local WoWClient                                                                                                                                    = env.WPM:Import("wpm_modules/wow-client")

local Mixin                                                                                                                                        = MixinUtil.Mixin
local CreateFromMixins                                                                                                                             = MixinUtil.CreateFromMixins

local UICCommonButton                                                                                                                                = env.WPM:Import("wpm_modules/uic-common/button")
local UICCommonPrompt                                                                                                                                = env.WPM:New("wpm_modules/uic-common/prompt")


-- Shared
--------------------------------

local PATH  = Path.Root .. "/wpm_modules/uic-common/resources/"
local ATLAS = UIKit.Define.Texture_Atlas{ path = PATH .. "panel.png" }

Utils_Texture.PreloadAsset(PATH .. "panel.png")


-- Prompt Button
--------------------------------

local BTN_WIDTH  = UIKit.Define.Num{ value = 125 }
local BTN_HEIGHT = UIKit.Define.Num{ value = 25 }


UICCommonPrompt.Button = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        UICCommonButton.RedWithText(name)
        :size(BTN_WIDTH, BTN_HEIGHT)

    return frame
end)


-- Prompt
--------------------------------

local PROMPT_BACKGROUND       = ATLAS{ inset = 64, scale = .425, left = 256 / 512, top = 256 / 512, right = 384 / 512, bottom = 384 / 512 }
local PROMPT_BACKGROUND_COLOR = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = .875 }
local PROMPT_WIDTH            = UIKit.Define.Fit{ delta = 46 }
local PROMPT_HEIGHT           = UIKit.Define.Fit{ delta = 46 }
local PROMPT_CONTENT_SPACING  = UIKit.Define.Num{ value = 9 }
local PROMPT_CONTENT_SIZE     = UIKit.Define.Fit{}
local PROMPT_TEXT_SIZE        = UIKit.Define.Fit{}
local PROMPT_TEXT_MAX_WIDTH   = UIKit.Define.Num{ value = 325 }
local PROMPT_BUTTON_SPACING   = UIKit.Define.Num{ value = 5 }
local PROMPT_BUTTON_SIZE      = UIKit.Define.Fit{}


local PromptAnimation = UIAnim.New()

local IntroAlpha = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :duration(.325)
    :from(0)
    :to(1)

local IntroTranslate = UIAnim.Animate()
    :property(UIAnim.Enum.Property.PosY)
    :easing(UIAnim.Enum.Easing.ElasticOut)
    :duration(1.25)
    :from(-15)
    :to(0)

local OutroAlpha = UIAnim.Animate()
    :property(UIAnim.Enum.Property.Alpha)
    :duration(.325)
    :to(0)

local OutroTranslate = UIAnim.Animate()
    :property(UIAnim.Enum.Property.PosY)
    :easing(UIAnim.Enum.Easing.QuintInOut)
    :duration(.375)
    :to(-15)

PromptAnimation:State("INTRO", function(frame)
    IntroAlpha:Play(frame)
    IntroTranslate:Play(frame)
end)

PromptAnimation:State("OUTRO", function(frame)
    OutroAlpha:Play(frame)
    OutroTranslate:Play(frame)
end)


local PromptMixin = {}

function PromptMixin:OnLoad()
    self.hideOnEscape = false

    CallbackRegistry:Add("WoWClient.OnEscapePressed", function()
        if self.hideOnEscape and self:IsShown() then
            WoWClient.BlockKeyEvent()
            self:OnEscape()
        end
    end)
end

function PromptMixin:ShowPrompt()
    self:Show()
    PromptAnimation:Play(self, "INTRO")
end

function PromptMixin:HidePrompt()
    if PromptAnimation:IsPlaying(self, "OUTRO") then return end
    if self.timeoutTimer then self.timeoutTimer:Cancel() end

    PromptAnimation:Play(self, "OUTRO").onFinish(function()
        self:Hide()
    end)
end

function PromptMixin:OnEscape()
    self:HidePrompt()
end

function PromptMixin:OnTimeout()
    self:HidePrompt()
end

function PromptMixin:SetTimeout(seconds)
    if self.timeoutTimer then self.timeoutTimer:Cancel() end

    self.timeoutTimer = C_Timer.NewTimer(seconds, function()
        self:OnTimeout()
    end)
end

function PromptMixin:Open(info, ...)
    --[[
        Expected table:
            text (string),
            options = {
                {
                    text (string),
                    callback (function)
                }
            },
            hideOnEscape? (boolean),
            timeout? (number)
    ]]

    assert(info, "Invalid variable `info`")
    assert(info.text and info.options, "Invalid variable `info`: Missing required fields")

    self.hideOnEscape = info.hideOnEscape or false
    if info.timeout then self:SetTimeout(info.timeout) end

    local textToDisplay = ""
    if ... then
        textToDisplay = string.format(info.text, ...)
    else
        textToDisplay = info.text
    end
    self.Content.Text:SetText(textToDisplay)
    self.Content.ButtonContainer.List:SetData(info.options)

    self:_Render()
    self:ShowPrompt()
end

local function handleElementClick(self)
    if self.value.callback then
        self.value.callback()
    end

    self:GetFrameParent().__parentRef:HidePrompt()
end

local function handleElementUpdate(element, index, value)
    element.index = index
    element.value = value

    element:HookMouseUp(handleElementClick, true)
    element:SetText(value.text)
end


UICCommonPrompt.New = UIKit.Prefab(function(id, name, children, ...)
    local frame =
        Frame(name, {
            LayoutVertical(name .. ".Content", {
                Text(name .. ".Content.Text")
                    :id("Content.Text", id)
                    :size(PROMPT_TEXT_SIZE, PROMPT_TEXT_SIZE)
                    :maxWidth(PROMPT_TEXT_MAX_WIDTH)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                LayoutHorizontal(name .. ".Content.ButtonContainer", {
                    List()
                        :id("Content.ButtonContainer.List", id)
                        :poolPrefab(UICCommonPrompt.Button)
                        :poolOnElementUpdate(handleElementUpdate)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                })
                    :id("Content.ButtonContainer", id)
                    :size(PROMPT_BUTTON_SIZE, PROMPT_BUTTON_SIZE)
                    :layoutSpacing(PROMPT_BUTTON_SPACING)
                    :layoutAlignmentH(UIKit.Enum.Direction.Justified)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
                :id("Content", id)
                :point(UIKit.Enum.Point.Center)
                :size(PROMPT_CONTENT_SIZE, PROMPT_CONTENT_SIZE)
                :layoutSpacing(PROMPT_CONTENT_SPACING)
                :layoutAlignmentH(UIKit.Enum.Direction.Justified)
                :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
        })
        :size(PROMPT_WIDTH, PROMPT_HEIGHT)
        :background(PROMPT_BACKGROUND)
        :backgroundColor(PROMPT_BACKGROUND_COLOR)
        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

    frame.Content = UIKit.GetElementById("Content", id)
    frame.Content.Text = UIKit.GetElementById("Content.Text", id)
    frame.Content.ButtonContainer = UIKit.GetElementById("Content.ButtonContainer", id)
    frame.Content.ButtonContainer.List = UIKit.GetElementById("Content.ButtonContainer.List", id)


    Mixin(frame, PromptMixin)
    frame:OnLoad()
    frame.Content.ButtonContainer.__parentRef = frame

    return frame
end)
