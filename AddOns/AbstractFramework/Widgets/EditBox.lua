---@class AbstractFramework
local AF = _G.AbstractFramework

local strmatch, strsub, strgsub, strfind, strlower = string.match, string.sub, string.gsub, string.find, string.lower

---------------------------------------------------------------------
-- edit box
---------------------------------------------------------------------
---@class AF_EditBox:EditBox,AF_BaseWidgetMixin
local AF_EditBoxMixin = {}

---@param func? fun(value: any) function to call when confirm button is clicked
---@param text string|nil if nil then use a tick icon
---@param position "RIGHT_INSIDE"|"RIGHT_OUTSIDE"|"BOTTOM"|"BOTTOMLEFT"|"BOTTOMRIGHT"|"NONE"|nil default "RIGHT_INSIDE".
---@param width number|nil default is 30, but use editbox width if position is "BOTTOM".
---@param height number|nil default is 20.
---@return AF_Button confirmBtn
function AF_EditBoxMixin:SetConfirmButton(func, text, position, width, height)
    self.confirmBtn = self.confirmBtn or AF.CreateButton(self, text, self.accentColor, width or 30, height or 20)
    self.confirmBtn:Hide()
    AF.SetFrameLevel(self.confirmBtn, 5)

    if text then
        self.confirmBtn:SetText(text)
    else
        self.confirmBtn:SetTexture(AF.GetIcon("Tick"), {16, 16}, {"CENTER", 0, 0})
    end

    AF.ClearPoints(self.confirmBtn)
    position = position and strupper(position) or "RIGHT_INSIDE"
    if position == "BOTTOM" then
        AF.SetPoint(self.confirmBtn, "TOPLEFT", self, "BOTTOMLEFT", 0, 1)
        AF.SetPoint(self.confirmBtn, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 1)
    elseif position == "BOTTOMLEFT" then
        AF.SetPoint(self.confirmBtn, "TOPLEFT", self, "BOTTOMLEFT", 0, 1)
    elseif position == "BOTTOMRIGHT" then
        AF.SetPoint(self.confirmBtn, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 1)
    elseif position == "RIGHT_OUTSIDE" then
        AF.SetPoint(self.confirmBtn, "TOPLEFT", self, "TOPRIGHT", -1, 0)
    elseif position == "RIGHT_INSIDE" then
        AF.SetPoint(self.confirmBtn, "TOPRIGHT")
    else
        -- NONE, do nothing
    end

    self.confirmBtn:SetScript("OnHide", function()
        self.confirmBtn:Hide()
    end)

    self.confirmBtn:SetScript("OnClick", function()
        local value = self:GetValue()

        if func then func(value) end

        self.value = value -- update value
        self.confirmBtn:Hide()
        self:ClearFocus()
    end)

    return self.confirmBtn
end

---@param func fun(self: AF_EditBox)
function AF_EditBoxMixin:SetOnEditFocusGained(func)
    self.onEditFocusGained = func
end

---@param func fun(self: AF_EditBox)
function AF_EditBoxMixin:SetOnEditFocusLost(func)
    self.onEditFocusLost = func
end

---@param func fun(value: any, self: AF_EditBox)
function AF_EditBoxMixin:SetOnEnterPressed(func)
    self.onEnterPressed = func
end

---@param func fun(self: AF_EditBox)
function AF_EditBoxMixin:SetOnEscapePressed(func)
    self.onEscapePressed = func
end

---@param func fun(value: any, userChanged: boolean, self: AF_EditBox)
function AF_EditBoxMixin:SetOnTextChanged(func)
    self.onTextChanged = func
end

function AF_EditBoxMixin:Clear()
    self:SetText("")
end

function AF_EditBoxMixin:GetBytes()
    local value = self:GetValue()
    if type(value) ~= "string" then value = tostring(value) end
    return #value
end

---@param mode string|nil "multiline"|"number"|"decimal"|"trim".
function AF_EditBoxMixin:SetMode(mode)
    self:SetMultiLine(false)
    self:SetNumeric(false)

    if not mode then
        self.mode = nil
        self.GetValue = function(self)
            return self:GetText()
        end
        return
    end

    mode = strlower(mode)
    self.mode = mode


    if mode == "multiline" then
        self:SetMultiLine(true)
        self.GetValue = function(self)
            return self:GetText()
        end
    elseif mode == "number" then
        self:SetNumeric(true)
        self.GetValue = function(self)
            return tonumber(self:GetText()) -- or 0
        end
    elseif mode == "decimal" then
        self.GetValue = function(self)
            local text = strgsub(self:GetText(), "[^%d%.%-]", "")

            local neg, rest = strmatch(text, "^(-?)(.*)")
            rest = strgsub(rest, "%-", "")
            text = neg .. rest

            local firstDecimal = strfind(text, "%.")
            if firstDecimal then
                text = strsub(text, 1, firstDecimal) ..
                    strgsub(strsub(text, firstDecimal + 1), "%.", "")
            end
            return tonumber(text) -- or 0
        end
    elseif mode == "trim" then
        self.GetValue = function(self)
            return strtrim(self:GetText())
        end
    end
end

function AF_EditBoxMixin:GetValue()
    return self:GetText()
end

function AF_EditBoxMixin:SetNotUserChangable(notUserChangable)
    self.notUserChangable = notUserChangable
end

---@param color string|table
function AF_EditBoxMixin:SetBorderColor(color)
    if type(color) == "string" then
        color = AF.GetColorTable(color)
    elseif type(color) ~= "table" then
        color = AF.GetColorTable("border")
    end

    if self:IsEnabled() then
        self:SetBackdropBorderColor(AF.UnpackColor(color))
    else
        self._borderColor = color
    end
end

---@param label string
function AF_EditBoxMixin:SetLabel(label)
    self.label:SetText(label or "")
end

--- an outside label (title), just like dropdowns
---@param label string
function AF_EditBoxMixin:SetLabelAlt(label)
    if not self.labelAlt then
        self.labelAlt = AF.CreateFontString(self)
        AF.SetPoint(self.labelAlt, "BOTTOMLEFT", self, "TOPLEFT", 2, 2)
        self:HookOnEnable(function()
            self.labelAlt:SetColor("white")
        end)
        self:HookOnDisable(function()
            self.labelAlt:SetColor("disabled")
        end)
    end
    self.labelAlt:SetText(label or "")
end

local function AF_EditBox_OnEditFocusGained(self)
    if self.onEditFocusGained then self.onEditFocusGained(self) end
    self:HighlightText()
end

local function AF_EditBox_OnEditFocusLost(self)
    if self.onEditFocusLost then self.onEditFocusLost(self) end
    self:HighlightText(0, 0)
end

local function AF_EditBox_OnEscapePressed(self)
    if self.onEscapePressed then self.onEscapePressed(self) end
    self:ClearFocus()
end

local function AF_EditBox_OnEnterPressed(self)
    if self.onEnterPressed then self.onEnterPressed(self:GetValue(), self) end
    self:ClearFocus()
end

local function AF_EditBox_OnDisable(self)
    self:SetTextColor(AF.GetColorRGB("disabled"))
    self:SetBackdropBorderColor(AF.GetColorRGB("border", 0.7))
end

local function AF_EditBox_OnEnable(self)
    self:SetTextColor(1, 1, 1, 1)
    if self._borderColor then
        self:SetBackdropBorderColor(AF.UnpackColor(self._borderColor))
    else
        self:SetBackdropBorderColor(0, 0, 0, 1)
    end
end

local function AF_EditBox_OnEnter(self)
    if not self:IsEnabled() then return end
    if self.highlight then self.highlight:Show() end
end

local function AF_EditBox_OnLeave(self)
    if not self:IsEnabled() then return end
    if self.highlight then self.highlight:Hide() end
end

local function AF_EditBox_OnTextChanged(self, userChanged)
    -- NOTE: this is weird
    -- OnTextChanged seems to be invoked immediately after this script is set & OnShow (if is hidden before)
    --! be careful when using on a dialog

    if self:GetText() == "" then
        self.label:Show()
    else
        self.label:Hide()
    end

    local value = self:GetValue()

    if self.onTextChanged then
        self.onTextChanged(value, userChanged, self)
    end

    if userChanged then
        if self.notUserChangable then
            self:SetText(self.value or "") -- restore
            self:SetCursorPosition(0)
            return
        end

        if self.confirmBtn then
            if self.value ~= value and (self.mode ~= "number" or value) then
                self.confirmBtn:Show()
            else
                self.confirmBtn:Hide()
            end
        end
    else
        self.value = value -- update value
    end
end

local function AF_EditBox_OnHide(self)
    self:SetText(self.value or "") -- restore
end

---@param parent Frame
---@param label? string
---@param width? number
---@param height? number
---@param mode? "multiline"|"number"|"trim"|nil
---@param font? string|Font
---@return AF_EditBox
function AF.CreateEditBox(parent, label, width, height, mode, font)
    local eb = CreateFrame("EditBox", nil, parent, "BackdropTemplate")

    eb.accentColor = AF.GetAddonAccentColorName()

    AF.ApplyDefaultBackdropWithColors(eb, "widget")
    AF.SetWidth(eb, width or 40)
    AF.SetHeight(eb, height or 20)

    eb.label = AF.CreateFontString(eb, label, nil, font)
    eb.label:SetPoint("LEFT", 4, 0)
    eb.label:SetPoint("RIGHT", -4, 0)
    eb.label:SetJustifyH("LEFT")
    eb.label:SetWordWrap(false)
    eb.label:SetTextColor(AF.GetColorRGB("disabled"))

    Mixin(eb, AF_EditBoxMixin)
    Mixin(eb, AF_BaseWidgetMixin)

    eb:SetMode(mode)
    eb:SetFontObject(font or "AF_FONT_NORMAL")
    eb:SetMaxLetters(0)
    eb:SetJustifyH("LEFT")
    eb:SetJustifyV("MIDDLE")
    eb:SetTextInsets(4, 4, 0, 0)
    eb:SetAutoFocus(false)

    eb.highlight = AF.CreateTexture(eb, nil, AF.GetColorTable(eb.accentColor, 0.07))
    AF.SetPoint(eb.highlight, "TOPLEFT", 1, -1)
    AF.SetPoint(eb.highlight, "BOTTOMRIGHT", -1, 1)
    eb.highlight:Hide()

    eb.value = "" -- init value

    eb:SetScript("OnTextChanged", AF_EditBox_OnTextChanged)
    eb:SetScript("OnEditFocusGained", AF_EditBox_OnEditFocusGained)
    eb:SetScript("OnEditFocusLost", AF_EditBox_OnEditFocusLost)
    eb:SetScript("OnEscapePressed", AF_EditBox_OnEscapePressed)
    eb:SetScript("OnEnterPressed", AF_EditBox_OnEnterPressed)
    eb:SetScript("OnDisable", AF_EditBox_OnDisable)
    eb:SetScript("OnEnable", AF_EditBox_OnEnable)
    eb:SetScript("OnEnter", AF_EditBox_OnEnter)
    eb:SetScript("OnLeave", AF_EditBox_OnLeave)
    eb:SetScript("OnHide", AF_EditBox_OnHide)

    AF.AddToPixelUpdater_OnShow(eb)

    return eb
end

---------------------------------------------------------------------
-- scroll edit box
---------------------------------------------------------------------
---@class AF_ScrollEditBox:AF_ScrollFrame
local AF_ScrollEditBoxMixin = {}

function AF_ScrollEditBoxMixin:SetText(text)
    self:ResetScroll()
    self.eb:SetText(text)
    self.eb:SetCursorPosition(0)
end

function AF_ScrollEditBoxMixin:GetText()
    return self.eb:GetText()
end

function AF_ScrollEditBoxMixin:GetValue()
    return self.eb:GetValue()
end

function AF_ScrollEditBoxMixin:Clear()
    self:ResetScroll()
    self.eb:Clear()
    self.eb:SetCursorPosition(0)
end

---@param position number
function AF_ScrollEditBoxMixin:SetCursorPosition(position)
    self.eb:SetCursorPosition(position)
end

function AF_ScrollEditBoxMixin:IsEnabled()
    return self._isEnabled
end

function AF_ScrollEditBoxMixin:SetEnabled(enabled)
    self._isEnabled = enabled
    self.eb:SetEnabled(enabled)
    self:EnableMouseWheel(enabled)
    self.scrollThumb:EnableMouse(enabled)
    if enabled then
        self.scrollThumb:SetBackdropColor(AF.GetColorRGB(self.accentColor))
        self.scrollThumb:SetBackdropBorderColor(AF.GetColorRGB("black"))
        self.scrollBar:SetBackdropBorderColor(AF.GetColorRGB("black"))
        self.scrollFrame:SetBackdropBorderColor(AF.GetColorRGB("black"))
    else
        self.scrollThumb:SetBackdropColor(AF.GetColorRGB("disabled", 0.7))
        self.scrollThumb:SetBackdropBorderColor(AF.GetColorRGB("black", 0.7))
        self.scrollBar:SetBackdropBorderColor(AF.GetColorRGB("black", 0.7))
        self.scrollFrame:SetBackdropBorderColor(AF.GetColorRGB("black", 0.7))
    end
end

function AF_ScrollEditBoxMixin:SetOnEditFocusGained(func)
    self.eb:SetOnEditFocusGained(func)
end

function AF_ScrollEditBoxMixin:SetOnEditFocusLost(func)
    self.eb:SetOnEditFocusLost(func)
end

function AF_ScrollEditBoxMixin:SetOnEnterPressed(func)
    self.eb:SetOnEnterPressed(func)
end

function AF_ScrollEditBoxMixin:SetOnEscapePressed(func)
    self.eb:SetOnEscapePressed(func)
end

---@param func fun(value: string, userChanged: boolean)
function AF_ScrollEditBoxMixin:SetOnTextChanged(func)
    self.eb:SetOnTextChanged(func)
end

---@param func fun(value: any)
---@param text string|nil if nil then use a tick icon
---@param position "BOTTOM"|"BOTTOMLEFT"|"BOTTOMRIGHT"|"NONE"|nil default "BOTTOMLEFT".
---@param width number|nil default is 30, but use editbox width if position is "BOTTOM".
---@param height number|nil default is 20.
---@return AF_Button confirmBtn
function AF_ScrollEditBoxMixin:SetConfirmButton(func, text, position, width, height)
    local confirmBtn = self.eb:SetConfirmButton(func, text, nil, width, height)

    confirmBtn:SetParent(self.scrollFrame)
    AF.SetFrameLevel(confirmBtn, 5, self.scrollFrame)

    AF.ClearPoints(confirmBtn)
    position = position and strupper(position) or "BOTTOMLEFT"
    if position == "BOTTOM" then
        AF.SetPoint(confirmBtn, "TOPLEFT", self.scrollFrame, "BOTTOMLEFT", 0, 1)
        AF.SetPoint(confirmBtn, "TOPRIGHT", self.scrollFrame, "BOTTOMRIGHT", 0, 1)
    elseif position == "BOTTOMLEFT" then
        AF.SetPoint(confirmBtn, "TOPLEFT", self.scrollFrame, "BOTTOMLEFT", 0, 1)
    elseif position == "BOTTOMRIGHT" then
        AF.SetPoint(confirmBtn, "TOPRIGHT", self.scrollFrame, "BOTTOMRIGHT", 0, 1)
    else
        -- NONE, do nothing
    end

    return confirmBtn
end

function AF_ScrollEditBoxMixin:SetMaxLetters(maxLetters)
    self.eb:SetMaxLetters(maxLetters)
end

function AF_ScrollEditBoxMixin:SetMaxBytes(maxBytes)
    self.eb:SetMaxBytes(maxBytes)
end

function AF_ScrollEditBoxMixin:GetBytes()
    return self.eb:GetBytes()
end

function AF_ScrollEditBoxMixin:Clear()
    self.eb:SetText("")
end

function AF_ScrollEditBoxMixin:SetNotUserChangable(notUserChangable)
    self.eb:SetNotUserChangable(notUserChangable)
end

function AF_ScrollEditBoxMixin:SetFocus()
    self.eb:SetFocus()
end

function AF_ScrollEditBoxMixin:ClearFocus()
    self.eb:ClearFocus()
end

function AF_ScrollEditBoxMixin:HasFocus()
    return self.eb:HasFocus()
end

function AF_ScrollEditBoxMixin:SetAutoFocus(autoFocus)
    self.eb:SetAutoFocus(autoFocus)
end

function AF_ScrollEditBoxMixin:IsAutoFocus()
    return self.eb:IsAutoFocus()
end

function AF_ScrollEditBoxMixin:SetTextColor(...)
    self.eb:SetTextColor(...)
end

---@param start? number
---@param stop? number
function AF_ScrollEditBoxMixin:HighlightText(start, stop)
    self.eb:HighlightText(start, stop)
end

---@param label string
function AF_ScrollEditBoxMixin:SetLabel(label)
    self.eb:SetLabel(label)
end

---@param label string
function AF_ScrollEditBoxMixin:SetLabelAlt(label)
    self.eb.SetLabelAlt(self, label)
end

--! NOTE: this may cause strange cursor and text misalignment issues
function AF_ScrollEditBoxMixin:SetSpacing(spacing)
    self.eb:SetSpacing(spacing)
end

local function AF_ScrollEditBox_ScrollFrame_OnEnter(scrollFrame)
    if not scrollFrame:GetParent():IsEnabled() then return end
    scrollFrame.highlight:Show()
end

local function AF_ScrollEditBox_ScrollFrame_OnLeave(scrollFrame)
    if not scrollFrame:GetParent():IsEnabled() then return end
    scrollFrame.highlight:Hide()
end

local function AF_ScrollEditBox_ScrollFrame_OnMouseDown(scrollFrame)
    scrollFrame:GetParent().eb:SetFocus(true)
end

local function AF_ScrollEditBox_OnEnter(eb)
    AF_ScrollEditBox_ScrollFrame_OnEnter(eb:GetParent():GetParent())
end

local function AF_ScrollEditBox_OnLeave(eb)
    AF_ScrollEditBox_ScrollFrame_OnLeave(eb:GetParent():GetParent())
end

local function AF_ScrollEditBox_OnEnterPressed(eb)
    eb:Insert("\n")
end

local function AF_ScrollEditBox_OnCursorChanged(eb, x, y, arg, lineHeight)
    -- https://warcraft.wiki.gg/wiki/UIHANDLER_OnCursorChanged
    local frame = eb:GetParent():GetParent():GetParent()
    if not frame:IsEnabled() then return end

    lineHeight = lineHeight + eb:GetSpacing()
    frame:SetScrollStep(lineHeight)

    local vs = frame.scrollFrame:GetVerticalScroll()
    local h  = frame.scrollFrame:GetHeight()

    if vs + y > 0 then
        -- cursor above current view
        frame.scrollFrame:SetVerticalScroll(-y)
    elseif vs + y - lineHeight + h < 0 then
        -- cursor below current view
        -- insets + cursorHeight
        local offset = AF.ConvertPixelsForRegion(4, eb) * 2 + lineHeight - y - h
        if offset > frame.scrollFrame:GetVerticalScrollRange() then
            frame:ScrollToBottom()
        else
            frame.scrollFrame:SetVerticalScroll(offset)
        end
    end
end

local function AF_ScrollEditBox_OnTextChanged(eb)
    local frame = eb:GetParent():GetParent():GetParent()
    frame:SetContentHeight(eb:GetHeight(), true, true)
    if frame.scrollFrame:GetVerticalScroll() > frame.scrollFrame:GetVerticalScrollRange() then
        frame:ScrollToBottom()
    end
end

---@param parent Frame
---@param name string
---@param label? string
---@param width? number
---@param height? number
---@return AF_ScrollEditBox frame
function AF.CreateScrollEditBox(parent, name, label, width, height)
    local frame = AF.CreateScrollFrame(parent, name, width, height, "none", "none")
    AF.ApplyDefaultBackdropWithColors(frame.scrollFrame, "widget")
    AF.ApplyDefaultBackdropWithColors(frame.scrollBar)

    frame.accentColor = AF.GetAddonAccentColorName()

    -- highlight
    local highlight = AF.CreateTexture(frame.scrollFrame, nil, AF.GetColorTable(frame.accentColor, 0.07))
    frame.scrollFrame.highlight = highlight
    AF.SetPoint(highlight, "TOPLEFT", 1, -1)
    AF.SetPoint(highlight, "BOTTOMRIGHT", -1, 1)
    highlight:Hide()

    frame.scrollFrame:SetScript("OnEnter", AF_ScrollEditBox_ScrollFrame_OnEnter)
    frame.scrollFrame:SetScript("OnLeave", AF_ScrollEditBox_ScrollFrame_OnLeave)

    -- edit box
    local eb = AF.CreateEditBox(frame.scrollContent, label, 10, 20, "multiline")
    frame.eb = eb
    eb.UpdatePixels = function() end
    eb:ClearBackdrop()
    eb:SetPoint("TOPLEFT")
    eb:SetPoint("RIGHT")
    eb:SetTextInsets(4, 4, 4, 4)
    -- eb:SetSpacing(2)
    eb:SetScript("OnEnter", AF_ScrollEditBox_OnEnter)
    eb:SetScript("OnLeave", AF_ScrollEditBox_OnLeave)
    eb:SetScript("OnEnterPressed", AF_ScrollEditBox_OnEnterPressed)
    eb:SetScript("OnCursorChanged", AF_ScrollEditBox_OnCursorChanged)
    eb:HookScript("OnTextChanged", AF_ScrollEditBox_OnTextChanged)
    frame.scrollFrame:SetScript("OnMouseDown", AF_ScrollEditBox_ScrollFrame_OnMouseDown)

    frame._isEnabled = true
    Mixin(frame, AF_ScrollEditBoxMixin)
    Mixin(frame, AF_BaseWidgetMixin)

    return frame
end

---------------------------------------------------------------------
-- transient edit box
---------------------------------------------------------------------
local editBoxPool

local function EditBox_OnEscapePressed(self)
    if self.onEscapePressed then
        self.onEscapePressed(self)
    end
    self:Hide()
end

local function EditBox_OnEnterPressed(self)
    if self.onEnterPressed then
        self.onEnterPressed(self:GetValue(), self)
    end
    self:Hide()
end

local function EditBox_OnShow(self)
    self:SetFocus()
    AF.SetFrameLevel(self, 20)
end

local function EditBox_OnHide(self)
    self:Hide()
    self:Clear()
    AF.ClearPoints(self)

    -- reset
    self.onEditFocusGained = nil
    self.onEditFocusLost = nil
    self.onEnterPressed = nil
    self.onEscapePressed = nil

    self:SetBorderColor("border")
    self:SetBackdropColor(AF.GetColorRGB("widget"))

    editBoxPool:Release(self)
end

local function EditBox_OnSetScript()
    error("EditBox:SetScript is not allowed, use SetOnEnter/EscapePressed instead.")
end

local function EditBox_OnHookScript()
    error("EditBox:HookScript is not allowed, use SetOnEnter/EscapePressed instead.")
end

editBoxPool = AF.CreateObjectPool(function()
    local eb = AF.CreateEditBox(AF.UIParent)
    eb:Hide()
    eb:SetOnShow(EditBox_OnShow)
    eb:SetOnHide(EditBox_OnHide)
    eb:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
    eb:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
    hooksecurefunc(eb, "SetScript", EditBox_OnSetScript)
    hooksecurefunc(eb, "HookScript", EditBox_OnHookScript)
    return eb
end, function(_, eb)
    -- reset
    eb:SetOnEscapePressed(nil)
    eb:SetOnEnterPressed(nil)
    eb:SetOnEditFocusGained(nil)
    eb:SetOnEditFocusLost(nil)
    eb:SetOnTextChanged(nil)
    eb:SetText("")
end)

-- this is a transient edit box, it will be created on demand and released when not needed.
-- please DO NOT use this for dialogs or other persistent edit boxes,
-- and DO NOT modify its script handlers besides "SetOnEnter/EscapePressed", "SetOnEditFocusGained/Lost", "SetOnTextChanged".
---@param parent Frame
---@param label? string
---@param width? number
---@param height? number
---@param mode? string "multiline"|"number"|"trim"|nil
---@param font? string|Font
---@return AF_EditBox
function AF.GetEditBox(parent, label, width, height, mode, font)
    local eb = editBoxPool:Acquire()

    eb:SetParent(parent)
    eb:SetLabel(label)
    AF.SetSize(eb, width, height)
    eb:SetMode(mode)
    eb:SetFontObject(font or "AF_FONT_NORMAL")
    eb:Show()

    return eb
end