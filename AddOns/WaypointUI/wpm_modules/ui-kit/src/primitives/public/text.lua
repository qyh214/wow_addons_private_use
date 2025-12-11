local env                    = select(2, ...)
local MixinUtil              = env.WPM:Import("wpm_modules/mixin-util")
local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Define           = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Enum             = env.WPM:Import("wpm_modules/ui-kit/enum")
local UIKit_UI_Scanner       = env.WPM:Await("wpm_modules/ui-kit/ui/scanner")

local Mixin                  = MixinUtil.Mixin

local UIKit_Primitives_Text  = env.WPM:New("wpm_modules/ui-kit/primitives/text")


-- Shared
--------------------------------

local dummy = CreateFrame("Frame"):CreateFontString(); dummy:Hide()
local Method_SetText = getmetatable(dummy).__index.SetText
local Method_SetFormattedText = getmetatable(dummy).__index.SetFormattedText

local TEXT_PORT_METHODS = {
    "CalculateScreenAreaFromCharacterSpan", "CanNonSpaceWrap", "CanWordWrap",
    "FindCharacterIndexAtCoordinate", "GetFieldSize", "GetFont", "GetFontObject",
    "GetIndentedWordWrap", "GetJustifyH", "GetJustifyV", "GetLineHeight",
    "GetMaxLines", "GetNumLines", "GetRotation", "GetShadowColor",
    "GetShadowOffset", "GetSpacing", "GetStringHeight", "GetStringWidth",
    "GetText", "GetTextColor", "GetTextScale", "GetUnboundedStringWidth",
    "GetWrappedWidth", "IsTruncated", "SetAlphaGradient", "SetFixedColor",
    "SetIndentedWordWrap", "SetJustifyH", "SetJustifyV", "SetMaxLines",
    "SetNonSpaceWrap", "SetRotation", "SetShadowColor", "SetShadowOffset",
    "SetSpacing", "SetTextColor", "SetTextHeight", "SetTextScale", "SetWordWrap"
}


-- Text
--------------------------------

local TextMixin = {}
do
    -- Port Methods
    --------------------------------

    for i = 1, #TEXT_PORT_METHODS do
        local method = TEXT_PORT_METHODS[i]
        TextMixin[method] = function(self, ...)
            return self.__Text[method](self.__Text, ...)
        end
    end


    -- Init
    --------------------------------

    function TextMixin:Init()
        self.__fontObject = GameFontNormal
        self.__fontPath = GameFontNormal:GetFont()
        self.__fontSize = 12
        self.__fontFlags = ""
    end


    -- Fit Content
    --------------------------------

    function TextMixin:FitContent()
        local fitWidth, fitHeight = self:GetFitContent()
        local widthProp = self.uk_prop_width
        local heightProp = self.uk_prop_height

        local widthDelta = (widthProp == UIKit_Define.Fit and widthProp.delta) or 0
        local heightDelta = (heightProp == UIKit_Define.Fit and heightProp.delta) or 0

        local text = self.__Text

        local frameWidth = self:GetWidth()
        if fitWidth then
            text:SetWidth(math.max(0, self:GetMaxWidth() or math.huge))
            frameWidth = self:ResolveFitSize("width", text:GetWrappedWidth(), widthProp)
            self:SetWidth(frameWidth)
        end
        text:SetWidth(math.max(0, frameWidth - widthDelta))

        local frameHeight = self:GetHeight()
        if fitHeight then
            text:SetHeight(math.max(0, self:GetMaxHeight() or math.huge))
            frameHeight = self:ResolveFitSize("height", text:GetStringHeight(), heightProp)
            self:SetHeight(frameHeight)
        end
        text:SetHeight(math.max(0, frameHeight - heightDelta))
    end


    -- Set
    --------------------------------

    function TextMixin:SetText(...)
        Method_SetText(self.__Text, ...)
        self:FitContent()

        self:TriggerEvent("OnTextChanged", ...)

        -- If in UserUpdate mode, explicitly trigger layout update
        if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
            UIKit_UI_Scanner.ScanFrame(self)
        end
    end

    function TextMixin:SetFormattedText(...)
        Method_SetFormattedText(self.__Text, ...)
        self:FitContent()

        self:TriggerEvent("OnFormattedTextChanged", ...)

        -- If in UserUpdate mode, explicitly trigger layout update
        if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
            UIKit_UI_Scanner.ScanFrame(self)
        end
    end


    -- Font
    --------------------------------

    function TextMixin:SetFont(path)
        if not path then return end

        self.__fontPath = path
        self:UpdateFont()
    end

    function TextMixin:SetFontSize(size)
        if not size then return end

        self.__fontSize = size
        self:UpdateFont()
    end

    function TextMixin:SetFontFlags(flags)
        if not flags then return end

        self.__fontFlags = flags
        self:UpdateFont()
    end

    function TextMixin:SetFontObject(fontObject)
        self.__fontObject = fontObject
        self:UpdateFont()
    end


    -- Internal
    --------------------------------

    function TextMixin:UpdateFont()
        if self.__fontObject then
            self.__Text:SetFontObject(self.__fontObject)
        else
            self.__Text:SetFont(self.__fontPath, self.__fontSize, self.__fontFlags)
        end
    end
end


function UIKit_Primitives_Text.New(name, parent)
    name = name or "undefined"


    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    local fontString = frame:CreateFontString(name .. "FontStringObject", "OVERLAY", "GameFontNormal")
    fontString:SetAllPoints(frame)

    Mixin(frame, TextMixin)
    frame:Init()


    -- References
    --------------------------------

    frame.__Text = fontString


    -- Defaults
    --------------------------------

    fontString:SetWordWrap(true)
    fontString:SetTextColor(1, 1, 1, 1)


    -- Events
    --------------------------------

    frame:RegisterEvent("UI_SCALE_CHANGED")
    frame:SetScript("OnEvent", frame.UpdateFont)


    _G[name .. "FontStringObject"] = nil
    return frame
end
