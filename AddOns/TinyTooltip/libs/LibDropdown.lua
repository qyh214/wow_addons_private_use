
---------------------------------
-- 簡易下拉菜單 Author: M
---------------------------------

local MAJOR, MINOR = "LibDropdown.7000", 2
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local DROPDOWNFRAME_MIN_WIDTH  = 130
local DROPDOWNFRAME_MAX_HEIGHT = 298

local DropDownFrame = CreateFrame("Frame", nil, UIParent, "InsetFrameTemplate3")
DropDownFrame.Bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
DropDownFrame.Bg:SetPoint("TOPLEFT", DropDownFrame.BorderTopLeft, "BOTTOMRIGHT", -6, 5)
DropDownFrame.Bg:SetPoint("BOTTOMRIGHT", DropDownFrame.BorderBottomRight, "TOPLEFT", 5, -5)
DropDownFrame:SetFrameStrata("DIALOG")
DropDownFrame:SetClampedToScreen(true)
DropDownFrame:SetToplevel(true)
DropDownFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, DropDownFrame, "UIPanelScrollFrameTemplate")
DropDownFrame.ScrollFrame:SetPoint("TOPLEFT", DropDownFrame, "TOPLEFT", 0, -6)
DropDownFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", DropDownFrame, "BOTTOMRIGHT", -2, 4)
DropDownFrame.ScrollFrame.ScrollBar:Hide()
DropDownFrame.ScrollFrame.ScrollBar:ClearAllPoints()
DropDownFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", DropDownFrame.ScrollFrame, "TOPRIGHT", -16, -15)
DropDownFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", DropDownFrame.ScrollFrame, "BOTTOMRIGHT", -16, 15)
DropDownFrame.ListFrame = CreateFrame("Frame", nil, DropDownFrame.ScrollFrame)
DropDownFrame.ListFrame:SetPoint("TOPLEFT")
DropDownFrame.ScrollFrame:SetScrollChild(DropDownFrame.ListFrame)
DropDownFrame.ScrollFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
    self.ScrollBar:SetShown(floor(yrange) ~= 0)
end)

function DropDownFrame:HideButtons()
    local index = 1
    while (self.ListFrame["button"..index]) do
        self.ListFrame["button"..index]:Hide()
        index = index + 1
    end
end

function DropDownFrame:GetSelectedInfo(value)
    local index = 1
    local info
    while (self.ListFrame["button"..index]) do
        if (self.ListFrame["button"..index]:IsShown()) then
            info = self.ListFrame["button"..index].info
            if (info.value == value) then
                return info
            end
        end
        index = index + 1
    end
end

function DropDownFrame:AddButton(info)
    local index = 1
    local button
    while (self.ListFrame["button"..index]) do
        if (not self.ListFrame["button"..index]:IsShown()) then
            button = self.ListFrame["button"..index]
            break
        end
        index = index + 1
    end
    if (not button) then
        button = CreateFrame("Button", nil, self.ListFrame)
        button:SetPoint("LEFT")
        button:SetPoint("RIGHT")
        button:SetHeight(16)
        button:SetHighlightTexture("Interface\\Buttons\\UI-ListBox-Highlight", "ADD")
        button.check = button:CreateTexture(nil, "ARTWORK")
        button.check:SetSize(16, 16)
        button.check:SetPoint("LEFT", 6, 0)
        button.check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
        button.check:SetTexCoord(0, 0.5, 0.5, 1)
        button.uncheck = button:CreateTexture(nil, "ARTWORK")
        button.uncheck:SetSize(16, 16)
        button.uncheck:SetPoint("LEFT", 6, 0)
        button.uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
        button.uncheck:SetTexCoord(0.5, 1, 0.5, 1)
        button.texture = button:CreateTexture(nil, "BORDER")
        button.texture:SetPoint("TOPLEFT", 22, 0)
        button.texture:SetPoint("BOTTOMRIGHT", -18, 0)
        button.text = button:CreateFontString(nil, "BORDER")
        button.text:SetFont(GameFontHighlightSmall:GetFont(), 14, "THINOUTLINE")
        button.text.font, button.text.size, button.text.flag = button.text:GetFont()
        button.text:SetPoint("LEFT", 24, 0)
        button.info = {}
        button:SetScript("OnClick", function(self)
            self:GetParent():GetParent():GetParent():Hide()
            if (self.info.func) then
                self.info.func(self.info, self.info.arg1, self.info.arg2)
            end
        end)
        self.ListFrame["button"..index] = button
    end
    button:Show()
    button.check:SetShown(info.checked)
    button.uncheck:SetShown(not info.checked)
    button.texture:SetTexture(info.texture)
    button.text:SetText(info.text or info.value)
    button.text:SetFont(info.font or button.text.font, button.text.size, button.text.flag)
    button.info.text = info.text
    button.info.value = info.value
    button.info.checked = info.checked
    button.info.func = info.func
    button.info.texture = info.texture
    button.info.font = info.font
    button.info.arg1 = info.arg1
    button.info.arg2 = info.arg2
    local width = info.staticWidth and info.staticWidth or button.text:GetWidth()+32
    button:SetWidth(width)
    button:SetPoint("TOPLEFT", 2, -18*index+18)
    self.ListFrame:SetHeight(18*index)
    self.ListFrame:SetWidth(max(DROPDOWNFRAME_MIN_WIDTH, self.ListFrame:GetWidth(), width+20))
    self:SetWidth(self.ListFrame:GetWidth())
end

local Extensions = {

    ListFunc = function(self) end,

    SetData = function(self, data)
        self.dropdata = data
    end,

    SetLabel = function(self, text)
        self.Label:SetText(text)
    end,
    
    SetText = function(self, text)
        self.Text:SetText(text)
    end,

    GetSelectedValue = function(self)
        return self.selectedValue
    end,

    SetSelectedValue = function(self, value, text)
        self.selectedValue = value
        if (not text) then
            local info = DropDownFrame:GetSelectedInfo(value)
            text = info and info.text
        end
        self:SetText(text or VIDEO_QUALITY_LABEL6 or value)
        if (self.selectedFunc) then
            self.selectedFunc(self, value, text)
        end
    end,

    SetListFunc = function(self, func)
        self.ListFunc = func
    end,
    
    ToggleDropDownFrame = function(self)
        if (DropDownFrame.parent == self and DropDownFrame:IsShown()) then
            return DropDownFrame:Hide()
        end
        DropDownFrame.parent = self
        DropDownFrame:HideButtons()
        DropDownFrame.ListFrame:SetWidth(DROPDOWNFRAME_MIN_WIDTH)
        DropDownFrame:SetHeight(min(DROPDOWNFRAME_MAX_HEIGHT, #self.dropdata*18+10))
        self:ListFunc()
        DropDownFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 18, 4)
        DropDownFrame:Show()
    end,
}

lib.Initialize = function(frame, initFunction, displayMode)
    for k, v in pairs(Extensions) do frame[k] = v end
    if (not frame.dropdata) then frame.dropdata = {} end
    frame.Button:SetScript("OnClick", function() frame:ToggleDropDownFrame() end)
    frame:SetScript("OnHide", nil)
    if (initFunction) then
        frame:SetListFunc(initFunction)
        DropDownFrame:HideButtons()
        frame:ListFunc()
    end
    if (displayMode == "MENU") then
        local name = frame:GetName()
        _G[name.."Left"]:Hide()
        _G[name.."Middle"]:Hide()
        _G[name.."Right"]:Hide()
        _G[name.."ButtonNormalTexture"]:SetTexture("")
        _G[name.."ButtonDisabledTexture"]:SetTexture("")
        _G[name.."ButtonPushedTexture"]:SetTexture("")
        _G[name.."ButtonHighlightTexture"]:SetTexture("")
        local button = _G[name.."Button"]
        button:ClearAllPoints()
        button:SetPoint("LEFT", name.."Text", "LEFT", -9, 0)
        button:SetPoint("RIGHT", name.."Text", "RIGHT", 6, 0)
	end
end

lib.SetText = function(frame, text)
    frame:SetText(text)
end

lib.CreateInfo = function()
    return UIDropDownMenu_CreateInfo()
end

lib.AddButton = function(info)
    DropDownFrame:AddButton(info)
end

lib.GetSelectedValue = function(frame)
    return frame:GetSelectedValue()
end

lib.SetSelectedValue = function(frame, value, text)
    frame:SetSelectedValue(value, text)
end

lib.ToggleDropDownMenu = function(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
    if (anchorName == "cursor") then
        local cursorX, cursorY = GetCursorPosition()
        xOffset = cursorX + (xOffset or 0)
        yOffset = cursorY + (yOffset or 0)
        --@todo
    elseif (anchorName) then
        Extensions.ToggleDropDownFrame(anchorName)
    end
end
