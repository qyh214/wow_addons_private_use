local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_Input = env.modules:New("packages\\ui-kit\\primitives\\input")

local Mixin = Mixin
local CreateFrame = CreateFrame
local getmetatable = getmetatable
local select = select
local assert = assert
local hooksecurefunc = hooksecurefunc


local dummy = CreateFrame("EditBox"); dummy:Hide()
local Method_SetFont = getmetatable(dummy).__index.SetFont

local InputMixin = {}

local function UpdatePlaceholder(inputFrame)
    local placeholder = inputFrame.__Placeholder
    placeholder:SetFont(inputFrame:GetFont())
    placeholder:SetJustifyH(inputFrame:GetJustifyH())
    placeholder:SetJustifyV(inputFrame:GetJustifyV())
    placeholder:SetShadowOffset(inputFrame:GetShadowOffset())
    placeholder:SetShadowColor(inputFrame:GetShadowColor())
end

local function HideDefaultCaret(caret)
    caret:Hide()
end

function InputMixin:OnLoad()
    self.__isMultiLine = false
    self.__textPlaceholder = nil
    self.__caretWidth = nil
    self.__caretOffsetX = nil
end

function InputMixin:GetTextObject()
    return self.__Text
end

function InputMixin:GetPlaceholderObject()
    return self.__Placeholder
end

function InputMixin:GetCaret()
    return self.__Caret
end

function InputMixin:GetCaretAnchor()
    return self.__CaretAnchor
end

function InputMixin:FitContent()
    local _, fitY = self:GetFitContent()
    if not fitY then return end

    if not self.__isMultiLine then
        local textHeight = select(2, self.__Text:GetFont())
        self:SetHeight(textHeight)
    end
end

function InputMixin:SetCaretWidth(width)
    if not width then return end
    self.__caretWidth = width
end

function InputMixin:SetCaretOffsetX(offset)
    if not offset then return end
    self.__caretOffsetX = offset
end

function InputMixin:SetFont(path)
    if not path then return end
    local _, size, flags = self:GetFont()
    Method_SetFont(self, path, size, flags)
end

function InputMixin:SetFontSize(size)
    if not size then return end
    local path, _, flags = self:GetFont()
    Method_SetFont(self, path, size, flags)
end

function InputMixin:SetFontFlags(flags)
    if not flags then return end
    local path, size = self:GetFont()
    Method_SetFont(self, path, size, flags)
end

function InputMixin:ShowPlaceholder()
    UpdatePlaceholder(self)
    self.__Placeholder:Show()
end

function InputMixin:HidePlaceholder()
    self.__Placeholder:Hide()
end

function InputMixin:SetPlaceholder(text)
    assert(text, "Invalid variable `text`")
    self.__Placeholder:SetText(text)
    self.__textPlaceholder = text
end

function InputMixin:SetPlaceholderFont(path)
    if not path then return end
    local _, size, flags = self.__Placeholder:GetFont()
    self.__Placeholder:SetFont(path, size, flags)
end

function InputMixin:SetPlaceholderFontSize(size)
    if not size then return end
    local path, _, flags = self.__Placeholder:GetFont()
    self.__Placeholder:SetFont(path, size, flags)
end

function InputMixin:SetPlaceholderFontFlags(flags)
    if not flags then return end
    local path, size = self.__Placeholder:GetFont()
    self.__Placeholder:SetFont(path, size, flags)
end

function InputMixin:ClearText()
    self:SetText("")
end

local function OnCursorChanged(inputFrame, x, y, w, h)
    local caretAnchor = inputFrame.__CaretAnchor
    if not caretAnchor then return end

    local caretWidth = inputFrame.__caretWidth or 1
    local height = (h and h > 0) and h or 12

    if caretAnchor:GetWidth() ~= caretWidth or caretAnchor:GetHeight() ~= height then
        caretAnchor:SetSize(caretWidth, height)
    end

    caretAnchor:ClearAllPoints()
    caretAnchor:SetPoint(
        inputFrame:IsMultiLine() and "TOPLEFT" or "LEFT",
        inputFrame,
        (x or 0) + (inputFrame.__caretOffsetX or 0),
        y or 0
    )

    if inputFrame:HasFocus() then
        caretAnchor:Show()
    end
end

local function OnTextChanged(inputFrame, userInput)
    if inputFrame.__textPlaceholder then
        if inputFrame:HasText() then
            inputFrame:HidePlaceholder()
        else
            inputFrame:ShowPlaceholder()
        end
    end

    inputFrame:FitContent()
    inputFrame:TriggerEvent("OnSizeChanged")
    inputFrame:TriggerEvent("OnTextChanged", inputFrame:GetText(), userInput)
end

local function OnFocusGained(inputFrame)
    inputFrame.__CaretAnchor:Show()
    inputFrame:TriggerEvent("OnFocusGained")
end

local function OnFocusLost(inputFrame)
    inputFrame.__CaretAnchor:Hide()
    inputFrame:TriggerEvent("OnFocusLost")
end

local function OnEscapePressed(inputFrame)
    inputFrame:TriggerEvent("OnEscapePressed")
    inputFrame:ClearFocus()
end

local function OnSetMultiLine(inputFrame, multiLine)
    inputFrame.__isMultiLine = multiLine
end

local function OnTextRegionShow(textRegion)
    if textRegion.uk_isVisible == false then
        textRegion.uk_isVisible = true
        textRegion:GetParent():SetCursorPosition(0)
    end
end

local function OnTextRegionHide(textRegion)
    textRegion.uk_isVisible = false
end

function UIKit_Primitives_Input.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("EditBox", name, parent)
    Mixin(frame, InputMixin)
    frame:OnLoad()
    frame:SetFontObject("GameFontNormal")
    frame:SetAutoFocus(false)

    local placeholder = frame:CreateFontString(name .. ".Placeholder", "OVERLAY", "GameFontNormal")
    placeholder:SetAllPoints(frame)
    placeholder:Hide()

    frame.__Text = select(1, frame:GetRegions())
    frame.__Placeholder = placeholder
    frame.__Caret = select(2, frame:GetRegions())

    frame.__caretWidth = 2.5
    frame.__Caret:HookScript("OnShow", HideDefaultCaret)

    local caretAnchor = UIKit_Primitives_Frame.New("Frame", "$parent.CaretAnchor", frame)
    caretAnchor:SetSize(frame.__caretWidth, 12)
    caretAnchor:Hide()
    frame.__CaretAnchor = caretAnchor

    frame:AddAlias("INPUT_TEXT", frame.__Text)
    frame:AddAlias("INPUT_PLACEHOLDER", placeholder)
    frame:AddAlias("INPUT_CARET", caretAnchor)

    frame:HookScript("OnTextChanged", OnTextChanged)
    frame:HookScript("OnCursorChanged", OnCursorChanged)
    frame:HookScript("OnEditFocusGained", OnFocusGained)
    frame:HookScript("OnEditFocusLost", OnFocusLost)
    frame:HookScript("OnEscapePressed", OnEscapePressed)
    frame.__Text:HookScript("OnShow", OnTextRegionShow)
    frame.__Text:HookScript("OnHide", OnTextRegionHide)
    hooksecurefunc(frame, "SetMultiLine", OnSetMultiLine)

    _G[name .. ".Placeholder"] = nil
    return frame
end
