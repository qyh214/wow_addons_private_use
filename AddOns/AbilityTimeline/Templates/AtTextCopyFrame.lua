local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtTextCopyFrame"
local Version = 1
local variables = {
    height = 100,
    width = 10,
    editBoxOffset = {
        x = 5,
        y = 0,
    }
}

---@param self AtTextCopyFrame
local function OnAcquire(self)
    self.Content.frame:Show()
    self.EditBox.frame:Show()
    self.Hint:Show()
    self.CloseButton:Show()
end

---@param self AtTextCopyFrame
local function OnRelease(self)
    self.EditBox:SetText('')
    self.EditBox.editbox:SetScript("OnKeyUp", nil)
    self.Content.frame:Hide()
    self.EditBox.frame:Hide()
    self.Hint:Hide()
    self.CloseButton:Hide()
end

local activeText = ""
local function RegisterKeyBinds(widget)
    widget.EditBox.editbox:SetScript("OnKeyUp", function(self, key)
        if IsControlKeyDown() then
            -- handle copy or cut
            if key == "C" or key == "X" then
                if widget and widget.frame then
                    widget.frame.CloseButton:Click()
                    widget.EditBox.editbox:SetScript("OnKeyUp", nil)
                end
            end
        end
    end)
    widget.EditBox.editbox:SetScript("OnTextChanged", function(self)
        self:SetText(activeText)
        self:SetFocus()
        self:HighlightText()
    end)
end

local function SetValues(self, text)
    self.EditBox:SetText(text)
    RegisterKeyBinds(self)
    -- Delay focus and highlight to ensure it works after frame is shown
    C_Timer.After(0.05, function()
        if self.EditBox and self.EditBox.editbox then
            self.EditBox.editbox:SetFocus()
            self.EditBox.editbox:HighlightText()
        end
    end)
    activeText = text
end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)

    local frame = CreateFrame("Frame", Type .. count, UIParent, 'PortraitFrameTemplateNoCloseButton')

    frame:SetPortraitTextureRaw("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\portrait.tga")
    frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
    frame:SetTitle(private.getLocalisation("CopyText"))
    frame:SetHeight(variables.height)

    frame.Content = AceGUI:Create("SimpleGroup")
    frame.Content:SetParent(frame)
    frame.Content:SetPoint("TOPLEFT", frame, "TOPLEFT", variables.editBoxOffset.x, -variables.editBoxOffset.y - 30)
    frame.Content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -variables.editBoxOffset.x,
    variables.editBoxOffset.y + 30)
    frame.Content:SetLayout("Fill")
    frame.EditBox = AceGUI:Create("EditBox")
    frame.EditBox:SetLabel('')
    frame.EditBox:DisableButton(true)
    private.Debug(frame.EditBox, "editbox")
    frame.Content:AddChild(frame.EditBox)

    frame.Hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.Hint:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    frame.Hint:SetText(private.getLocalisation("TextCopyHint"))

    frame.CloseButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    frame:Show()

    ---@class AtTextCopyFrame : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        frame = frame,
        type = Type,
        count = count,
        SetValues = SetValues,
        Content = frame.Content,
        EditBox = frame.EditBox,
        Hint = frame.Hint,
        CloseButton = frame.CloseButton,
        RegisterKeyBinds = RegisterKeyBinds,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
