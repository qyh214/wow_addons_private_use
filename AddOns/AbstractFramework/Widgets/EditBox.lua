---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- edit box
---------------------------------------------------------------------
---@class AF_EditBox:EditBox,AF_BaseWidgetMixin
local AF_EditBoxMixin = {}

---@param func function?
---@param text string?
---@param position string? "RIGHT_INSIDE"|"RIGHT_OUTSIDE"|"BOTTOM"|"BOTTOMLEFT"|"BOTTOMRIGHT"|nil, default "RIGHT_INSIDE".
---@param width number? default is 30, but use editbox width if position is "BOTTOM".
---@param height number? default is 20.
function AF_EditBoxMixin:SetConfirmButton(func, text, position, width, height)
    self.confirmBtn = self.confirmBtn or AF.CreateButton(self, text, "accent", width or 30, height or 20)
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
    else
        AF.SetPoint(self.confirmBtn, "TOPRIGHT")
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
end

function AF_EditBoxMixin:SetOnEditFocusGained(func)
    self.onEditFocusGained = func
end

function AF_EditBoxMixin:SetOnEditFocusLost(func)
    self.onEditFocusLost = func
end

function AF_EditBoxMixin:SetOnEnterPressed(func)
    self.onEnterPressed = func
end

function AF_EditBoxMixin:SetOnEscapePressed(func)
    self.onEscapePressed = func
end

---@param func fun(value: any, userChanged: boolean)
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
            local text = string.gsub(self:GetText(), "[^%d%.]", "")

            local firstDecimal = string.find(text, "%.")
            if firstDecimal then
                text = string.sub(text, 1, firstDecimal) ..
                    string.gsub(string.sub(text, firstDecimal + 1), "%.", "")
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

---@param parent Frame
---@param label string
---@param width number
---@param height number
---@param mode string? "multiline"|"number"|"trim"|nil
---@param font? string|Font
---@return AF_EditBox
function AF.CreateEditBox(parent, label, width, height, mode, font)
    local eb = CreateFrame("EditBox", nil, parent, "BackdropTemplate")

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

    eb:SetScript("OnEditFocusGained", function()
        if eb.onEditFocusGained then eb.onEditFocusGained() end
        eb:HighlightText()
    end)

    eb:SetScript("OnEditFocusLost", function()
        if eb.onEditFocusLost then eb.onEditFocusLost() end
        eb:HighlightText(0, 0)
    end)

    eb:SetScript("OnEscapePressed", function()
        if eb.onEscapePressed then eb.onEscapePressed() end
        eb:ClearFocus()
    end)

    eb:SetScript("OnEnterPressed", function()
        if eb.onEnterPressed then eb.onEnterPressed(eb:GetText()) end
        eb:ClearFocus()
    end)

    eb:SetScript("OnDisable", function()
        eb:SetTextColor(AF.GetColorRGB("disabled"))
        eb:SetBackdropBorderColor(0, 0, 0, 0.7)
    end)

    eb:SetScript("OnEnable", function()
        eb:SetTextColor(1, 1, 1, 1)
        eb:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    eb.highlight = AF.CreateTexture(eb, nil, AF.GetColorTable("accent", 0.07))
    AF.SetPoint(eb.highlight, "TOPLEFT", 1, -1)
    AF.SetPoint(eb.highlight, "BOTTOMRIGHT", -1, 1)
    eb.highlight:Hide()

    eb:SetScript("OnEnter", function()
        if not eb:IsEnabled() then return end
        eb.highlight:Show()
    end)

    eb:SetScript("OnLeave", function()
        if not eb:IsEnabled() then return end
        eb.highlight:Hide()
    end)

    eb.value = "" -- init value

    eb:SetScript("OnTextChanged", function(self, userChanged)
        if eb:GetText() == "" then
            eb.label:Show()
        else
            eb.label:Hide()
        end

        local value = eb:GetValue()

        if eb.onTextChanged then
            eb.onTextChanged(value, userChanged)
        end

        if userChanged then
            if eb.notUserChangable then
                eb:SetText(eb.value or "") -- restore
                return
            end

            if eb.confirmBtn then
                if eb.value ~= value then
                    eb.confirmBtn:Show()
                else
                    eb.confirmBtn:Hide()
                end
            end
        else
            eb.value = value -- update value
        end
    end)

    eb:SetScript("OnHide", function()
        eb:SetText(eb.value or "") -- restore
    end)

    AF.AddToPixelUpdater(eb)

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

function AF_ScrollEditBoxMixin:IsEnabled()
    return self._isEnabled
end

function AF_ScrollEditBoxMixin:SetEnabled(enabled)
    self._isEnabled = enabled
    self.eb:SetEnabled(enabled)
    self:EnableMouseWheel(enabled)
    self.scrollThumb:EnableMouse(enabled)
    if enabled then
        self.scrollThumb:SetBackdropColor(AF.GetColorRGB("accent"))
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

function AF_ScrollEditBoxMixin:SetOnTextChanged(func)
    self.eb:SetOnTextChanged(func)
end

---@param func function?
---@param text string?
---@param position string? "RIGHT_INSIDE"|"RIGHT_OUTSIDE"|"BOTTOM"|"BOTTOMLEFT"|"BOTTOMRIGHT"|nil, default "BOTTOMLEFT".
---@param width number? default is 30, but use editbox width if position is "BOTTOM".
---@param height number? default is 20.
function AF_ScrollEditBoxMixin:SetConfirmButton(func, text, position, width, height)
    self.eb:SetConfirmButton(func, text, nil, width, height)

    local confirmBtn = self.eb.confirmBtn
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
    elseif position == "RIGHT_OUTSIDE" then
        AF.SetPoint(confirmBtn, "TOPLEFT", self.scrollFrame, "TOPRIGHT", -1, 0)
    else
        AF.SetPoint(confirmBtn, "TOPRIGHT", self.scrollFrame)
    end
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

---@return AF_ScrollEditBox frame
function AF.CreateScrollEditBox(parent, name, label, width, height, scrollStep)
    scrollStep = scrollStep or 1

    local frame = AF.CreateScrollFrame(parent, name, width, height, "none", "none")
    AF.ApplyDefaultBackdropWithColors(frame.scrollFrame, "widget")
    AF.ApplyDefaultBackdropWithColors(frame.scrollBar)

    -- highlight
    local highlight = AF.CreateTexture(frame.scrollFrame, nil, AF.GetColorTable("accent", 0.07))
    AF.SetPoint(highlight, "TOPLEFT", 1, -1)
    AF.SetPoint(highlight, "BOTTOMRIGHT", -1, 1)
    highlight:Hide()

    frame.scrollFrame:SetScript("OnEnter", function()
        if not frame:IsEnabled() then return end
        highlight:Show()
    end)

    frame.scrollFrame:SetScript("OnLeave", function()
        if not frame:IsEnabled() then return end
        highlight:Hide()
    end)

    -- edit box
    local eb = AF.CreateEditBox(frame.scrollContent, label, 10, 20, "multiline")
    frame.eb = eb
    eb.UpdatePixels = function() end
    eb:ClearBackdrop()
    eb:SetPoint("TOPLEFT")
    eb:SetPoint("RIGHT")
    eb:SetTextInsets(4, 4, 4, 4)
    eb:SetSpacing(2)
    eb:SetScript("OnEnter", frame.scrollFrame:GetScript("OnEnter"))
    eb:SetScript("OnLeave", frame.scrollFrame:GetScript("OnLeave"))

    eb:SetScript("OnEnterPressed", function(self) self:Insert("\n") end)

    -- https://warcraft.wiki.gg/wiki/UIHANDLER_OnCursorChanged
    eb:SetScript("OnCursorChanged", function(self, x, y, arg, lineHeight)
        if not frame:IsEnabled() then return end

        frame:SetScrollStep((lineHeight + eb:GetSpacing()) * scrollStep)

        local vs = frame.scrollFrame:GetVerticalScroll()
        local h  = frame.scrollFrame:GetHeight()

        local cursorHeight = lineHeight + abs(y) + 8 + eb:GetSpacing()

        if vs + y > 0 then -- cursor above current view
            frame.scrollFrame:SetVerticalScroll(-y)
        elseif cursorHeight > h + vs then
            frame.scrollFrame:SetVerticalScroll(cursorHeight-h)
        end

        if frame.scrollFrame:GetVerticalScroll() > frame.scrollFrame:GetVerticalScrollRange() then frame:ScrollToBottom() end
    end)

    eb:HookScript("OnTextChanged", function()
        -- NOTE: should not use SetContentHeight
        frame.scrollContent:SetHeight(eb:GetHeight())
    end)

    frame.scrollFrame:SetScript("OnMouseDown", function()
        eb:SetFocus(true)
    end)

    frame._isEnabled = true
    Mixin(frame, AF_ScrollEditBoxMixin)
    Mixin(frame, AF_BaseWidgetMixin)

    return frame
end