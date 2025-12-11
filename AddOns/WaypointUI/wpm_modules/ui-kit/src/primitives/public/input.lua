local env                    = select(2, ...)
local MixinUtil              = env.WPM:Import("wpm_modules/mixin-util")

local Mixin                  = MixinUtil.Mixin

local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_Input = env.WPM:New("wpm_modules/ui-kit/primitives/input")


-- Shared
--------------------------------

local dummy = CreateFrame("EditBox"); dummy:Hide()
local Method_SetFont = getmetatable(dummy).__index.SetFont


-- Input
--------------------------------

local InputMixin = {}
do
    -- Init
    --------------------------------

    function InputMixin:Init()
        self.__isMultiLine = false
        self.__textPlaceholder = nil
        self.__caretWidth = nil
        self.__caretOffsetX = nil
    end


    -- Accessor
    --------------------------------

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


    -- Layout
    --------------------------------

    function InputMixin:FitContent()
        local _, fitY = self:GetFitContent()

        if not fitY then return end
        if not self.__isMultiLine then
            local textHeight = select(2, self.__Text:GetFont())
            self:SetHeight(textHeight)
        end
    end


    -- Caret
    --------------------------------

    function InputMixin:SetCaretWidth(width)
        if not width then return end
        self.__caretWidth = width
    end

    function InputMixin:SetCaretOffsetX(offset)
        if not offset then return end
        self.__caretOffsetX = offset
    end


    -- Font
    --------------------------------

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


    -- Placeholder
    --------------------------------

    local function updatePlaceholder(self)
        self.__Placeholder:SetFont(self:GetFont())
        self.__Placeholder:SetJustifyH(self:GetJustifyH())
        self.__Placeholder:SetJustifyV(self:GetJustifyV())
        self.__Placeholder:SetShadowOffset(self:GetShadowOffset())
        self.__Placeholder:SetShadowColor(self:GetShadowColor())
    end

    function InputMixin:ShowPlaceholder()
        updatePlaceholder(self)
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
end

local function setupCustomCaret(self)
    self.__caretWidth = 2.5

    -- Hide default caret
    self.__Caret:HookScript("OnShow", function()
        self.__Caret:Hide()
    end)

    local caretAnchor = UIKit_Primitives_Frame.New("Frame", "$parent.CaretAnchor", self)
    caretAnchor:SetSize(self.__caretWidth, 12)
    caretAnchor:Hide()

    return caretAnchor
end

local function updateCaretPosition(self, x, y, w, h)
    local caretAnchor = self.__CaretAnchor
    if not caretAnchor then return end

    local height = (h and h > 0) and h or 12
    if caretAnchor:GetWidth() ~= self.__caretWidth or caretAnchor:GetHeight() ~= height then
        caretAnchor:SetSize(self.__caretWidth or 1, height)
    end

    caretAnchor:ClearAllPoints()
    caretAnchor:SetPoint(self:IsMultiLine() and "TOPLEFT" or "LEFT", self, (x or 0) + (self.__caretOffsetX or 0), (y or 0))

    if self:HasFocus() then
        caretAnchor:Show()
    end
end

local function handleTextChanged(self, userInput)
    if self.__textPlaceholder then
        if not self:HasText() then
            self:ShowPlaceholder()
        else
            self:HidePlaceholder()
        end
    end

    self:FitContent()

    self:TriggerEvent("OnSizeChanged")
    self:TriggerEvent("OnTextChanged", self:GetText(), userInput)
end

local function handleFocusGained(self)
    self.__CaretAnchor:Show()
    self:TriggerEvent("OnFocusGained")
end

local function handleFocusLost(self)
    self.__CaretAnchor:Hide()
    self:TriggerEvent("OnFocusLost")
end

local function handleEscapePressed(self)
    self:TriggerEvent("OnEscapePressed")
    self:ClearFocus()
end

local function handleSetMultiLine(self, multiLine)
    self.__isMultiLine = multiLine
end

local function handleShow(self)
    if self.isVisible == false then
        self.isVisible = true
        self:GetParent():SetCursorPosition(0)
    end
end

local function handleHide(self)
    self.isVisible = false
end


function UIKit_Primitives_Input.New(name, parent)
    name = name or "undefined"


    local frame = UIKit_Primitives_Frame.New("EditBox", name, parent)
    Mixin(frame, InputMixin)
    frame:Init()
    frame:SetFontObject("GameFontNormal")
    frame:SetAutoFocus(false)


    -- Placeholder
    --------------------------------

    local placeholder = frame:CreateFontString(name .. ".Placeholder", "OVERLAY", "GameFontNormal")
    placeholder:SetAllPoints(frame)
    placeholder:Hide()


    -- References
    --------------------------------

    frame.__Text        = select(1, frame:GetRegions())
    frame.__Placeholder = placeholder
    frame.__Caret       = select(2, frame:GetRegions())
    frame.__CaretAnchor = setupCustomCaret(frame)

    frame:AddAlias("INPUT_TEXT", frame.__Text)
    frame:AddAlias("INPUT_PLACEHOLDER", frame.__Placeholder)
    frame:AddAlias("INPUT_CARET", frame.__CaretAnchor)


    -- Events
    --------------------------------

    frame:HookScript("OnTextChanged", handleTextChanged)
    frame:HookScript("OnCursorChanged", updateCaretPosition)
    frame:HookScript("OnEditFocusGained", handleFocusGained)
    frame:HookScript("OnEditFocusLost", handleFocusLost)
    frame:HookScript("OnEscapePressed", handleEscapePressed)
    frame.__Text:HookScript("OnShow", handleShow)
    frame.__Text:HookScript("OnHide", handleHide)
    hooksecurefunc(frame, "SetMultiLine", handleSetMultiLine)



    _G[name .. ".Placeholder"] = nil
    return frame
end
