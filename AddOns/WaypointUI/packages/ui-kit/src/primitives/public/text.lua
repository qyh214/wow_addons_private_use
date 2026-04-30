local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_UI_Scanner = env.modules:Await("packages\\ui-kit\\ui\\scanner")
local UIKit_Primitives_Text = env.modules:New("packages\\ui-kit\\primitives\\text")

local Mixin = Mixin
local math_max = math.max
local math_huge = math.huge
local UIKit_Define_Fit = UIKit_Define.Fit


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

local TextMixin = {}

for i = 1, #TEXT_PORT_METHODS do
    local method = TEXT_PORT_METHODS[i]
    TextMixin[method] = function(self, ...)
        return self.__Text[method](self.__Text, ...)
    end
end

function TextMixin:Init()
    self.__fontObject = GameFontNormal
    self.__fontPath = GameFontNormal:GetFont()
    self.__fontSize = 12
    self.__fontFlags = ""
end

function TextMixin:FitContent()
    local fitWidth, fitHeight = self:GetFitContent()
    local widthProp = self.uk_prop_width
    local heightProp = self.uk_prop_height

    local widthDelta = (widthProp == UIKit_Define_Fit and widthProp.delta) or 0
    local heightDelta = (heightProp == UIKit_Define_Fit and heightProp.delta) or 0

    local text = self.__Text

    local frameWidth = self:GetWidth()
    if fitWidth then
        text:SetWidth(math_max(0, self:GetMaxWidth() or math_huge))
        frameWidth = self:ResolveFitSize("width", text:GetWrappedWidth(), widthProp)
        self:SetWidth(frameWidth)
    end
    text:SetWidth(math_max(0, frameWidth - widthDelta))

    local frameHeight = self:GetHeight()
    if fitHeight then
        text:SetHeight(math_max(0, self:GetMaxHeight() or math_huge))
        frameHeight = self:ResolveFitSize("height", text:GetStringHeight(), heightProp)
        self:SetHeight(frameHeight)
    end
    text:SetHeight(math_max(0, frameHeight - heightDelta))
end

function TextMixin:SetText(...)
    Method_SetText(self.__Text, ...)
    self:FitContent()
    self:TriggerEvent("OnTextChanged", ...)

    if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
        UIKit_UI_Scanner.ScanFrame(self)
    end
end

function TextMixin:SetFormattedText(...)
    Method_SetFormattedText(self.__Text, ...)
    self:FitContent()
    self:TriggerEvent("OnFormattedTextChanged", ...)

    if self.uk_flag_updateMode == UIKit_Enum.UpdateMode.UserUpdate then
        UIKit_UI_Scanner.ScanFrame(self)
    end
end

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

function TextMixin:UpdateFont()
    if self.__fontObject then
        self.__Text:SetFontObject(self.__fontObject)
    else
        self.__Text:SetFont(self.__fontPath, self.__fontSize, self.__fontFlags)
    end
end

function UIKit_Primitives_Text.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    local fontString = frame:CreateFontString(name .. "FontStringObject", "OVERLAY", "GameFontNormal")
    fontString:SetAllPoints(frame)

    Mixin(frame, TextMixin)
    frame:Init()

    frame.__Text = fontString

    fontString:SetWordWrap(true)
    fontString:SetTextColor(1, 1, 1, 1)

    frame:RegisterEvent("UI_SCALE_CHANGED")
    frame:SetScript("OnEvent", frame.UpdateFont)

    _G[name .. "FontStringObject"] = nil
    return frame
end
