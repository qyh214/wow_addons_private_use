local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast
local L = DF.L
local format = string.format

-- Local aliases for shared constants (defined in Constants.lua)
local PROFILE_TEMPLATE = CC.PROFILE_TEMPLATE

-- Local aliases for helper functions (defined in Profiles.lua)
local GetPlayerClass = function() return CC.GetPlayerClass() end

-- Local alias for helper functions (defined in UI/ProfilesPanel.lua)
local function ShowPopupOnTop(name) return CC.ShowPopupOnTop and CC.ShowPopupOnTop(name) or StaticPopup_Show(name) end

-- IMPORT POPUP DIALOG
-- ============================================================

local ImportPopupFrame = nil
local pendingImportData = nil
local pendingImportCallback = nil

-- Theme colors matching GUI/GUI.lua
local POPUP_COLORS = {
    background = {r = 0.08, g = 0.08, b = 0.08, a = 0.97},
    panel = {r = 0.12, g = 0.12, b = 0.12, a = 1},
    element = {r = 0.18, g = 0.18, b = 0.18, a = 1},
    border = {r = 0.25, g = 0.25, b = 0.25, a = 1},
    accent = {r = 0.45, g = 0.45, b = 0.95, a = 1},
    hover = {r = 0.22, g = 0.22, b = 0.22, a = 1},
    text = {r = 0.9, g = 0.9, b = 0.9, a = 1},
    textDim = {r = 0.6, g = 0.6, b = 0.6, a = 1},
    green = {r = 0.2, g = 0.9, b = 0.2},
    orange = {r = 1.0, g = 0.6, b = 0.1},
    red = {r = 0.9, g = 0.25, b = 0.25},
}

local function CreateStyledButton(parent, text, width, height)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 120, height or 28)
    
    if not btn.SetBackdrop then Mixin(btn, BackdropTemplateMixin) end
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(POPUP_COLORS.element.r, POPUP_COLORS.element.g, POPUP_COLORS.element.b, 1)
    btn:SetBackdropBorderColor(POPUP_COLORS.border.r, POPUP_COLORS.border.g, POPUP_COLORS.border.b, 1)
    
    local label = btn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(POPUP_COLORS.text.r, POPUP_COLORS.text.g, POPUP_COLORS.text.b)
    btn.label = label
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(POPUP_COLORS.hover.r, POPUP_COLORS.hover.g, POPUP_COLORS.hover.b, 1)
        self:SetBackdropBorderColor(POPUP_COLORS.accent.r, POPUP_COLORS.accent.g, POPUP_COLORS.accent.b, 1)
    end)
    
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(POPUP_COLORS.element.r, POPUP_COLORS.element.g, POPUP_COLORS.element.b, 1)
        self:SetBackdropBorderColor(POPUP_COLORS.border.r, POPUP_COLORS.border.g, POPUP_COLORS.border.b, 1)
    end)
    
    return btn
end

local function CreateImportPopup()
    if ImportPopupFrame then return ImportPopupFrame end
    
    local frame = CreateFrame("Frame", "DFClickCastingImportPopup", UIParent, "BackdropTemplate")
    frame:SetSize(520, 460)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(100)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    frame:SetBackdropColor(POPUP_COLORS.background.r, POPUP_COLORS.background.g, POPUP_COLORS.background.b, POPUP_COLORS.background.a)
    frame:SetBackdropBorderColor(POPUP_COLORS.border.r, POPUP_COLORS.border.g, POPUP_COLORS.border.b, 1)
    frame:Hide()
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 2, -2)
    titleBar:SetPoint("TOPRIGHT", -2, -2)
    titleBar:SetHeight(32)
    if not titleBar.SetBackdrop then Mixin(titleBar, BackdropTemplateMixin) end
    titleBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    titleBar:SetBackdropColor(POPUP_COLORS.panel.r, POPUP_COLORS.panel.g, POPUP_COLORS.panel.b, 1)
    
    local title = titleBar:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("CENTER")
    title:SetText(L["Import Click Casting Profile"])
    title:SetTextColor(POPUP_COLORS.text.r, POPUP_COLORS.text.g, POPUP_COLORS.text.b)
    frame.title = title
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -6, 0)
    closeBtn:SetNormalFontObject("DFFontNormal")
    
    local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
    closeTex:SetAllPoints()
    closeTex:SetColorTexture(0.8, 0.2, 0.2, 0.8)
    closeBtn.tex = closeTex
    
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(1, 1, 1)
    
    closeBtn:SetScript("OnEnter", function(self) self.tex:SetColorTexture(1, 0.3, 0.3, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self.tex:SetColorTexture(0.8, 0.2, 0.2, 0.8) end)
    closeBtn:SetScript("OnClick", function()
        if pendingImportCallback then
            pendingImportCallback("cancel")
        end
        frame:Hide()
    end)
    
    -- Warning text panel
    local warningPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    warningPanel:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -10)
    warningPanel:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -10, -10)
    warningPanel:SetHeight(45)
    if not warningPanel.SetBackdrop then Mixin(warningPanel, BackdropTemplateMixin) end
    warningPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    warningPanel:SetBackdropColor(0.3, 0.2, 0.1, 0.5)
    warningPanel:SetBackdropBorderColor(0.6, 0.4, 0.1, 0.8)
    
    local warningIcon = warningPanel:CreateTexture(nil, "OVERLAY")
    warningIcon:SetPoint("LEFT", 12, 0)
    warningIcon:SetSize(20, 20)
    warningIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\warning")
    warningIcon:SetVertexColor(1, 0.8, 0.3)
    
    local warning = warningPanel:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    warning:SetPoint("LEFT", warningIcon, "RIGHT", 8, 0)
    warning:SetPoint("RIGHT", -12, 0)
    warning:SetJustifyH("LEFT")
    warning:SetTextColor(1, 0.8, 0.3)
    frame.warning = warning
    
    -- Content area
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", warningPanel, "BOTTOMLEFT", 0, -10)
    contentArea:SetPoint("TOPRIGHT", warningPanel, "BOTTOMRIGHT", 0, -10)
    contentArea:SetHeight(200)
    
    -- Valid bindings section
    local validPanel = CreateFrame("Frame", nil, contentArea, "BackdropTemplate")
    validPanel:SetPoint("TOPLEFT", 0, 0)
    validPanel:SetSize(240, 200)
    if not validPanel.SetBackdrop then Mixin(validPanel, BackdropTemplateMixin) end
    validPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    validPanel:SetBackdropColor(POPUP_COLORS.panel.r, POPUP_COLORS.panel.g, POPUP_COLORS.panel.b, 1)
    validPanel:SetBackdropBorderColor(POPUP_COLORS.green.r * 0.5, POPUP_COLORS.green.g * 0.5, POPUP_COLORS.green.b * 0.5, 1)
    
    local validIcon = validPanel:CreateTexture(nil, "OVERLAY")
    validIcon:SetPoint("TOPLEFT", 10, -8)
    validIcon:SetSize(14, 14)
    validIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
    validIcon:SetVertexColor(POPUP_COLORS.green.r, POPUP_COLORS.green.g, POPUP_COLORS.green.b)
    
    local validLabel = validPanel:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    validLabel:SetPoint("LEFT", validIcon, "RIGHT", 4, 0)
    validLabel:SetText(L["Compatible Bindings"])
    validLabel:SetTextColor(POPUP_COLORS.green.r, POPUP_COLORS.green.g, POPUP_COLORS.green.b)
    
    local validScroll = CreateFrame("ScrollFrame", nil, validPanel, "ScrollFrameTemplate")
    validScroll:SetPoint("TOPLEFT", 8, -28)
    validScroll:SetPoint("BOTTOMRIGHT", -28, 8)
    DF.GUI.StyleScrollBar(validScroll)

    local validList = CreateFrame("Frame", nil, validScroll)
    validList:SetSize(200, 170)
    validScroll:SetScrollChild(validList)
    frame.validList = validList
    frame.validScroll = validScroll
    
    -- Invalid bindings section
    local invalidPanel = CreateFrame("Frame", nil, contentArea, "BackdropTemplate")
    invalidPanel:SetPoint("TOPRIGHT", 0, 0)
    invalidPanel:SetSize(240, 200)
    if not invalidPanel.SetBackdrop then Mixin(invalidPanel, BackdropTemplateMixin) end
    invalidPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    invalidPanel:SetBackdropColor(POPUP_COLORS.panel.r, POPUP_COLORS.panel.g, POPUP_COLORS.panel.b, 1)
    invalidPanel:SetBackdropBorderColor(POPUP_COLORS.red.r * 0.5, POPUP_COLORS.red.g * 0.5, POPUP_COLORS.red.b * 0.5, 1)
    
    local invalidIcon = invalidPanel:CreateTexture(nil, "OVERLAY")
    invalidIcon:SetPoint("TOPLEFT", 10, -8)
    invalidIcon:SetSize(14, 14)
    invalidIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    invalidIcon:SetVertexColor(POPUP_COLORS.red.r, POPUP_COLORS.red.g, POPUP_COLORS.red.b)
    
    local invalidLabel = invalidPanel:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    invalidLabel:SetPoint("LEFT", invalidIcon, "RIGHT", 4, 0)
    invalidLabel:SetText(L["Incompatible Bindings"])
    invalidLabel:SetTextColor(POPUP_COLORS.red.r, POPUP_COLORS.red.g, POPUP_COLORS.red.b)
    
    local invalidScroll = CreateFrame("ScrollFrame", nil, invalidPanel, "ScrollFrameTemplate")
    invalidScroll:SetPoint("TOPLEFT", 8, -28)
    invalidScroll:SetPoint("BOTTOMRIGHT", -28, 8)
    DF.GUI.StyleScrollBar(invalidScroll)

    local invalidList = CreateFrame("Frame", nil, invalidScroll)
    invalidList:SetSize(200, 170)
    invalidScroll:SetScrollChild(invalidList)
    frame.invalidList = invalidList
    frame.invalidScroll = invalidScroll
    
    -- Legend
    local legend = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    legend:SetPoint("TOPLEFT", contentArea, "BOTTOMLEFT", 0, -8)
    legend:SetWidth(500)
    legend:SetJustifyH("LEFT")
    legend:SetTextColor(POPUP_COLORS.textDim.r, POPUP_COLORS.textDim.g, POPUP_COLORS.textDim.b)
    frame.legend = legend
    
    -- Summary panel
    local summaryPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    summaryPanel:SetPoint("TOPLEFT", legend, "BOTTOMLEFT", 0, -8)
    summaryPanel:SetPoint("TOPRIGHT", contentArea, "BOTTOMRIGHT", 0, -8)
    summaryPanel:SetHeight(50)
    if not summaryPanel.SetBackdrop then Mixin(summaryPanel, BackdropTemplateMixin) end
    summaryPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    summaryPanel:SetBackdropColor(POPUP_COLORS.element.r, POPUP_COLORS.element.g, POPUP_COLORS.element.b, 0.5)
    summaryPanel:SetBackdropBorderColor(POPUP_COLORS.border.r, POPUP_COLORS.border.g, POPUP_COLORS.border.b, 1)
    
    local summary = summaryPanel:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    summary:SetPoint("CENTER")
    summary:SetWidth(480)
    summary:SetJustifyH("CENTER")
    summary:SetTextColor(POPUP_COLORS.text.r, POPUP_COLORS.text.g, POPUP_COLORS.text.b)
    frame.summary = summary
    
    -- Buttons - positioned relative to bottom of frame with proper spacing
    local btnWidth = 150
    local btnSpacing = 12
    local totalWidth = (btnWidth * 3) + (btnSpacing * 2)
    local startX = -totalWidth / 2 + btnWidth / 2
    
    -- Import All button
    local importAllBtn = CreateStyledButton(frame, L["Import All"], btnWidth, 30)
    importAllBtn:SetPoint("BOTTOM", frame, "BOTTOM", startX, 18)
    importAllBtn:SetScript("OnClick", function()
        if pendingImportCallback then
            pendingImportCallback("all")
        end
        frame:Hide()
    end)
    frame.importAllBtn = importAllBtn
    
    -- Import Compatible button
    local importCompatibleBtn = CreateStyledButton(frame, L["Compatible Only"], btnWidth, 30)
    importCompatibleBtn:SetPoint("BOTTOM", frame, "BOTTOM", startX + btnWidth + btnSpacing, 18)
    importCompatibleBtn:SetScript("OnClick", function()
        if pendingImportCallback then
            pendingImportCallback("compatible")
        end
        frame:Hide()
    end)
    frame.importCompatibleBtn = importCompatibleBtn
    
    -- Cancel button
    local cancelBtn = CreateStyledButton(frame, L["Cancel"], btnWidth, 30)
    cancelBtn:SetPoint("BOTTOM", frame, "BOTTOM", startX + (btnWidth + btnSpacing) * 2, 18)
    cancelBtn:SetScript("OnClick", function()
        if pendingImportCallback then
            pendingImportCallback("cancel")
        end
        frame:Hide()
    end)
    frame.cancelBtn = cancelBtn
    
    ImportPopupFrame = frame
    return frame
end

local function GetBindingDisplayText(binding)
    -- Display names for mouse buttons
    local MOUSE_BUTTON_NAMES = {
        LeftButton = "Left Click",
        RightButton = "Right Click",
        MiddleButton = "Middle Click",
        Button4 = "Mouse 4",
        Button5 = "Mouse 5",
        Button6 = "Mouse 6",
        Button7 = "Mouse 7",
        Button8 = "Mouse 8",
    }
    
    -- Display names for scroll
    local SCROLL_NAMES = {
        SCROLLUP = "Scroll Up",
        SCROLLDOWN = "Scroll Down",
    }
    
    -- Determine the key/button display text based on binding type
    local keyCombo = "?"
    local bindType = binding.bindType or "mouse"
    
    if bindType == "mouse" and binding.button then
        keyCombo = MOUSE_BUTTON_NAMES[binding.button] or binding.button
    elseif bindType == "scroll" and binding.key then
        keyCombo = SCROLL_NAMES[binding.key] or binding.key
    elseif bindType == "key" and binding.key then
        keyCombo = binding.key
    elseif binding.button then
        -- Fallback for old format without bindType
        keyCombo = MOUSE_BUTTON_NAMES[binding.button] or binding.button
    elseif binding.key then
        keyCombo = binding.key
    end
    
    -- Add modifiers (handle both table and string formats)
    if binding.modifiers then
        local mods = {}
        if type(binding.modifiers) == "table" then
            -- Table format: {shift = true, ctrl = false, ...}
            if binding.modifiers.shift then table.insert(mods, "Shift") end
            if binding.modifiers.ctrl then table.insert(mods, "Ctrl") end
            if binding.modifiers.alt then table.insert(mods, "Alt") end
            if binding.modifiers.meta then table.insert(mods, "Cmd") end
        elseif type(binding.modifiers) == "string" and binding.modifiers ~= "" then
            -- String format: "shift-ctrl-alt-meta-"
            local modStr = binding.modifiers:lower()
            if modStr:find("shift") then table.insert(mods, "Shift") end
            if modStr:find("ctrl") then table.insert(mods, "Ctrl") end
            if modStr:find("alt") then table.insert(mods, "Alt") end
            if modStr:find("meta") then table.insert(mods, "Cmd") end
        end
        if #mods > 0 then
            keyCombo = table.concat(mods, "+") .. "+" .. keyCombo
        end
    end
    
    local actionText = ""
    if binding.actionType == "spell" then
        actionText = binding.spellName or "Unknown Spell"
    elseif binding.actionType == "macro" then
        actionText = "Macro: " .. (binding.macroName or "Custom")
    elseif binding.actionType == "target" then
        actionText = "Target"
    elseif binding.actionType == "focus" then
        actionText = "Focus"
    elseif binding.actionType == "follow" then
        actionText = "Follow"
    elseif binding.actionType == "assist" then
        actionText = "Assist"
    elseif binding.actionType == "menu" then
        actionText = "Menu"
    else
        actionText = binding.actionType or "Unknown"
    end
    
    return keyCombo .. " = " .. actionText
end

local function PopulateImportPopup(validBindings, invalidBindings, sourceClass, profileName)
    local frame = CreateImportPopup()
    
    -- Clear existing items
    for _, child in pairs({frame.validList:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, child in pairs({frame.invalidList:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Set warning text
    local currentClass = GetPlayerClass()
    if sourceClass and sourceClass ~= currentClass then
        frame.warning:SetText(format(L["This profile was created for %s%s%s.\nSome bindings may not be compatible with %s%s%s."], "|cffffffff", sourceClass, "|r", "|cffffffff", currentClass, "|r"))
    else
        frame.warning:SetText(L["Some bindings use spells that are not available\nto your current class or specialization."])
    end
    
    -- Helper to create a colored dot texture
    local function CreateDot(parent, r, g, b)
        local dot = parent:CreateTexture(nil, "ARTWORK")
        dot:SetSize(8, 8)
        dot:SetColorTexture(r, g, b, 1)
        return dot
    end
    
    -- Populate valid bindings list
    local yOffset = 0
    local lineHeight = 18
    
    for _, entry in ipairs(validBindings) do
        local row = CreateFrame("Frame", nil, frame.validList)
        row:SetPoint("TOPLEFT", 0, -yOffset)
        row:SetSize(200, lineHeight)
        
        local dot = CreateDot(row, 
            entry.status == "valid_spec" and POPUP_COLORS.green.r or POPUP_COLORS.orange.r,
            entry.status == "valid_spec" and POPUP_COLORS.green.g or POPUP_COLORS.orange.g,
            entry.status == "valid_spec" and POPUP_COLORS.green.b or POPUP_COLORS.orange.b
        )
        dot:SetPoint("LEFT", 2, 0)
        
        local text = row:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        text:SetPoint("LEFT", dot, "RIGHT", 6, 0)
        text:SetWidth(180)
        text:SetJustifyH("LEFT")
        text:SetText(entry.display)
        
        if entry.status == "valid_spec" then
            text:SetTextColor(0.8, 0.9, 0.8)
        else
            text:SetTextColor(0.9, 0.85, 0.7)
        end
        
        yOffset = yOffset + lineHeight
    end
    frame.validList:SetHeight(math.max(170, yOffset + 10))
    
    -- Populate invalid bindings list
    yOffset = 0
    for _, entry in ipairs(invalidBindings) do
        local row = CreateFrame("Frame", nil, frame.invalidList)
        row:SetPoint("TOPLEFT", 0, -yOffset)
        row:SetSize(200, lineHeight)
        
        local dot = CreateDot(row, POPUP_COLORS.red.r, POPUP_COLORS.red.g, POPUP_COLORS.red.b)
        dot:SetPoint("LEFT", 2, 0)
        
        local text = row:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        text:SetPoint("LEFT", dot, "RIGHT", 6, 0)
        text:SetWidth(180)
        text:SetJustifyH("LEFT")
        text:SetText(entry.display)
        text:SetTextColor(0.9, 0.7, 0.7)
        
        yOffset = yOffset + lineHeight
    end
    frame.invalidList:SetHeight(math.max(170, yOffset + 10))
    
    -- Update legend with inline colored squares using textures
    frame.legend:SetText("|cff33ee33[A]|r Available   |cffffaa00[S]|r Different Spec   |cffee3333[X]|r Not Available")
    
    -- Update summary
    local validCount = #validBindings
    local invalidCount = #invalidBindings
    local totalCount = validCount + invalidCount
    
    frame.summary:SetText(format(
        L["Profile: %s%s%s\n%s%d compatible%s   %s%d incompatible%s   %s%d total%s"],
        "|cffffffff", profileName or "Imported", "|r",
        "|cff33ee33", validCount, "|r",
        "|cffee3333", invalidCount, "|r",
        "|cff888888", totalCount, "|r"
    ))

    -- Update button text
    if invalidCount == 0 then
        frame.importAllBtn.label:SetText(L["Import All"])
        frame.importCompatibleBtn:SetAlpha(0.5)
        frame.importCompatibleBtn:Disable()
    else
        frame.importAllBtn.label:SetText(format(L["Import All (%d)"], totalCount))
        frame.importCompatibleBtn.label:SetText(format(L["Compatible (%d)"], validCount))
        frame.importCompatibleBtn:SetAlpha(1)
        frame.importCompatibleBtn:Enable()
    end
    
    return frame
end

-- Import profile from string
function CC:ImportProfile(importString, newProfileName)
    if not importString or importString == "" then
        return false, "Empty import string"
    end
    
    local data
    
    -- Check for new format (!DFC1!)
    if string.sub(importString, 1, 6) == "!DFC1!" then
        local payload = string.sub(importString, 7)
        data = self:DeserializeString(payload)
    -- Legacy format (DF01:)
    elseif string.sub(importString, 1, 5) == "DF01:" then
        local payload = string.sub(importString, 6)
        data = self:DeserializeStringLegacy(payload)
    else
        return false, "Invalid format (expected !DFC1! or DF01: header)"
    end
    
    if not data then
        return false, "Failed to decode import data"
    end
    
    -- Validate
    if not data.profile then
        return false, "Invalid profile data"
    end
    
    -- Analyze bindings for compatibility
    local sourceClass = data.class
    local currentClass = GetPlayerClass()
    local validBindings = {}
    local invalidBindings = {}
    
    if data.profile.bindings then
        for _, binding in ipairs(data.profile.bindings) do
            local status = "valid_spec"
            
            -- Check spell bindings for class compatibility
            if binding.actionType == "spell" and binding.spellName then
                status = self:GetSpellValidityStatus(binding.spellName)
            end
            
            local entry = {
                binding = binding,
                status = status,
                display = GetBindingDisplayText(binding)
            }
            
            if status == "invalid" then
                table.insert(invalidBindings, entry)
            else
                table.insert(validBindings, entry)
            end
        end
    end
    
    -- If there are invalid bindings, show popup
    if #invalidBindings > 0 then
        local frame = PopulateImportPopup(validBindings, invalidBindings, sourceClass, data.profileName)
        
        -- Store data for callback
        pendingImportData = {
            data = data,
            validBindings = validBindings,
            invalidBindings = invalidBindings,
            newProfileName = newProfileName,
        }
        
        -- Set callback
        pendingImportCallback = function(choice)
            if choice == "cancel" then
                print("|cffff9900DandersFrames:|r Import cancelled")
                pendingImportData = nil
                return
            end
            
            local importData = pendingImportData
            if not importData then return end
            
            -- Build bindings list based on choice
            local bindingsToImport = {}
            
            if choice == "all" then
                -- Import all bindings
                for _, entry in ipairs(importData.validBindings) do
                    table.insert(bindingsToImport, entry.binding)
                end
                for _, entry in ipairs(importData.invalidBindings) do
                    table.insert(bindingsToImport, entry.binding)
                end
            else
                -- Import only compatible bindings
                for _, entry in ipairs(importData.validBindings) do
                    table.insert(bindingsToImport, entry.binding)
                end
            end
            
            -- Perform the import
            CC:DoImportProfile(importData.data, bindingsToImport, importData.newProfileName, choice == "all")
            pendingImportData = nil
        end
        
        frame:Show()
        return true, "Showing import dialog"
    end
    
    -- No invalid bindings, import directly
    local allBindings = {}
    for _, entry in ipairs(validBindings) do
        table.insert(allBindings, entry.binding)
    end
    
    return self:DoImportProfile(data, allBindings, newProfileName, false)
end

-- Actually perform the import (called after popup choice or directly if no conflicts)
function CC:DoImportProfile(data, bindings, newProfileName, importedInvalid)
    -- Use provided name or generate one
    local profileName = newProfileName or data.profileName or "Imported"
    local classData = self:GetClassData()
    
    -- Ensure unique name
    local baseName = profileName
    local counter = 1
    while classData.profiles[profileName] do
        counter = counter + 1
        profileName = baseName .. " " .. counter
    end
    
    -- Create the profile with the selected bindings
    local profile = CopyTable(data.profile)
    profile.bindings = bindings
    
    -- Import the profile
    classData.profiles[profileName] = profile
    
    -- Ensure all required fields exist
    if not classData.profiles[profileName].bindings then
        classData.profiles[profileName].bindings = {}
    end
    if not classData.profiles[profileName].customMacros then
        classData.profiles[profileName].customMacros = {}
    end
    if not classData.profiles[profileName].options then
        classData.profiles[profileName].options = CopyTable(PROFILE_TEMPLATE.options)
    end
    
    -- Print result
    local bindingCount = #bindings
    print("|cff33cc33DandersFrames:|r Imported profile: " .. profileName .. " (" .. bindingCount .. " bindings)")
    if importedInvalid then
        print("|cffff9900DandersFrames:|r Note: Some imported spells may not work with your current class/spec")
    end
    
    -- Refresh the UI to show the new profile
    if self.UpdateProfileDropdown then
        self.UpdateProfileDropdown()
    end
    if self.RefreshClickCastingUI then
        self:RefreshClickCastingUI()
    end
    
    return true, profileName
end

-- ============================================================

-- CLICK-CASTING CONFLICT POPUP
-- =========================================================================
function CC:ShowClickCastConflictPopup(conflicts, enableCheckbox)
    -- Check if user has chosen to ignore conflict warnings
    if self.db and self.db.ignoreConflictWarning then
        -- Skip conflict popup, proceed to Blizzard warning / enable
        CC:ShowBlizzardClickCastWarning(enableCheckbox, function()
            CC.db.enabled = true
            CC:SetEnabled(true)
        end)
        return
    end
    
    local C = self.UI_COLORS
    -- Fallback colors if UI_COLORS not yet initialized
    local themeColor = C and C.theme or { r = 0.2, g = 0.8, b = 0.2 }
    local borderColor = C and C.border or { r = 0.3, g = 0.3, b = 0.3 }
    
    -- Close any existing conflict popup
    if self.conflictPopup then
        self.conflictPopup:Hide()
    end
    
    local conflictList = table.concat(conflicts, " and ")
    
    -- Create popup frame
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(400, 280)  -- Taller to fit all buttons
    popup:SetPoint("CENTER")
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
    popup:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(200)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
    self.conflictPopup = popup
    
    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText(L["Click-Casting Addon Conflict"])
    title:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    popup.title = title
    
    -- Message
    local msg = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    msg:SetPoint("TOP", title, "BOTTOM", 0, -15)
    msg:SetPoint("LEFT", 20, 0)
    msg:SetPoint("RIGHT", -20, 0)
    msg:SetJustifyH("CENTER")
    msg:SetText(format(L["%s detected.\n\nWhich click-casting addon would you like to use?"], conflictList))
    msg:SetTextColor(1, 1, 1)
    popup.msg = msg
    
    -- Warning
    local warning = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    warning:SetPoint("TOP", msg, "BOTTOM", 0, -10)
    warning:SetPoint("LEFT", 20, 0)
    warning:SetPoint("RIGHT", -20, 0)
    warning:SetJustifyH("CENTER")
    warning:SetText(L["Selecting an option will disable the other addon(s)\nand reload your UI."])
    warning:SetTextColor(0.7, 0.7, 0.7)
    popup.warning = warning
    
    -- Helper function to create buttons
    local function CreateChoiceButton(parent, text, yOffset, isPrimary)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(180, 30)
        btn:SetPoint("TOP", warning, "BOTTOM", 0, yOffset)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        
        if isPrimary then
            btn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            btn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        else
            btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
            btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(1, 1, 1)
        btn.label = btnText
        
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            if isPrimary then
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            else
                self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            end
        end)
        
        return btn
    end
    
    -- DandersFrames button (primary)
    local dfBtn = CreateChoiceButton(popup, L["Use DandersFrames"], -20, true)
    dfBtn:SetScript("OnClick", function()
        -- Disable conflicting addons
        for _, addonName in ipairs(conflicts) do
            if C_AddOns and C_AddOns.DisableAddOn then
                C_AddOns.DisableAddOn(addonName)
            elseif DisableAddOn then
                DisableAddOn(addonName)
            end
        end
        
        -- Enable DandersFrames click casting
        CC.db.enabled = true
        if CC.profile and CC.profile.options then
            CC.profile.options.enabled = true
        end
        
        popup:Hide()
        
        -- Reload UI
        ReloadUI()
    end)
    popup.dfBtn = dfBtn
    
    -- Conflicting addon button
    local otherBtn = CreateChoiceButton(popup, format(L["Use %s"], conflicts[1]), -55, false)
    otherBtn:SetScript("OnClick", function()
        -- Disable DandersFrames click casting
        CC.db.enabled = false
        if CC.profile and CC.profile.options then
            CC.profile.options.enabled = false
        end
        
        -- Uncheck the enable checkbox
        if enableCheckbox then
            enableCheckbox:SetChecked(false)
        end
        
        popup:Hide()
        
        -- Reload UI to ensure clean state
        ReloadUI()
    end)
    popup.otherBtn = otherBtn
    
    -- Cancel button
    local cancelBtn = CreateChoiceButton(popup, L["Cancel"], -90, false)
    cancelBtn:SetSize(100, 26)
    cancelBtn:SetScript("OnClick", function()
        -- Revert checkbox state
        if enableCheckbox then
            enableCheckbox:SetChecked(false)
        end
        popup:Hide()
    end)
    popup.cancelBtn = cancelBtn
    
    -- Ignore button (next to Cancel) - both centered as a group
    local ignoreBtn = CreateChoiceButton(popup, L["Ignore"], -90, false)
    ignoreBtn:SetSize(100, 26)
    ignoreBtn:SetBackdropColor(0.3, 0.2, 0.1, 1)
    ignoreBtn:SetBackdropBorderColor(0.6, 0.4, 0.1, 1)
    
    -- Center both buttons as a group (100 + 10 + 100 = 210 total width)
    cancelBtn:ClearAllPoints()
    cancelBtn:SetPoint("TOP", warning, "BOTTOM", -55, -90)  -- Half of 100 + half of 10 gap
    ignoreBtn:ClearAllPoints()
    ignoreBtn:SetPoint("TOP", warning, "BOTTOM", 55, -90)   -- Half of 100 + half of 10 gap
    
    -- Track if we're in confirmation state
    local confirmationState = false
    
    ignoreBtn:SetScript("OnClick", function()
        if not confirmationState then
            -- Switch to confirmation state
            confirmationState = true
            
            -- Update popup to show warning
            title:SetText(L["Are you sure?"])
            title:SetTextColor(1, 0.6, 0.2)
            
            msg:SetText(format(L["Having multiple click-casting addons enabled\nmay cause conflicts and unexpected behavior.\n\n%sUse at your own risk!%s"], "|cffff6600", "|r"))
            
            warning:SetText(L["This warning will not appear again after confirming."])
            warning:SetTextColor(1, 0.8, 0.3)
            
            -- Hide the main buttons
            dfBtn:Hide()
            otherBtn:Hide()
            
            -- Update buttons
            cancelBtn.label:SetText(L["Go Back"])
            ignoreBtn.label:SetText(L["Confirm"])
            ignoreBtn:SetBackdropColor(0.5, 0.2, 0.1, 1)
            ignoreBtn:SetBackdropBorderColor(0.8, 0.3, 0.1, 1)
        else
            -- Confirmed - save setting and proceed to enable
            CC.db.ignoreConflictWarning = true
            print("|cff33cc33DandersFrames:|r Conflict warning disabled. Both addons will remain enabled.")
            print("|cffff9900DandersFrames:|r You can re-enable this warning by typing: /df resetconflict")
            popup:Hide()
            -- Proceed to Blizzard warning / enable
            CC:ShowBlizzardClickCastWarning(enableCheckbox, function()
                CC.db.enabled = true
                CC:SetEnabled(true)
            end)
        end
    end)
    
    cancelBtn:SetScript("OnClick", function()
        if confirmationState then
            -- Go back to normal state
            confirmationState = false
            
            title:SetText(L["Click-Casting Addon Conflict"])
            title:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            
            msg:SetText(format(L["%s detected.\n\nWhich click-casting addon would you like to use?"], conflictList))
            
            warning:SetText(L["Selecting an option will disable the other addon(s)\nand reload your UI."])
            warning:SetTextColor(0.7, 0.7, 0.7)
            
            dfBtn:Show()
            otherBtn:Show()
            
            cancelBtn.label:SetText(L["Cancel"])
            ignoreBtn.label:SetText(L["Ignore"])
            ignoreBtn:SetBackdropColor(0.3, 0.2, 0.1, 1)
            ignoreBtn:SetBackdropBorderColor(0.6, 0.4, 0.1, 1)
        else
            -- Normal cancel
            if enableCheckbox then
                enableCheckbox:SetChecked(false)
            end
            popup:Hide()
        end
    end)
    popup.ignoreBtn = ignoreBtn
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER")
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(0.7, 0.7, 0.7)
    closeBtn:SetScript("OnEnter", function() closeIcon:SetVertexColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeIcon:SetVertexColor(0.7, 0.7, 0.7) end)
    closeBtn:SetScript("OnClick", function()
        if enableCheckbox then
            enableCheckbox:SetChecked(false)
        end
        popup:Hide()
    end)
    
    popup:Show()
end

-- =========================================================================

-- BLIZZARD CLICK-CASTING WARNING DIALOG
-- =========================================================================

function CC:ShowBlizzardClickCastWarning(enableCheckbox, onConfirm)
    -- Check if user has chosen to ignore this warning
    if self.db and self.db.ignoreBlizzardWarning then
        -- Proceed directly
        if onConfirm then onConfirm() end
        return
    end
    
    local C = self.UI_COLORS
    local themeColor = C and C.theme or { r = 0.2, g = 0.8, b = 0.2 }
    
    -- Close any existing warning popup
    if self.blizzardWarningPopup then
        self.blizzardWarningPopup:Hide()
    end
    
    -- Create popup frame
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(420, 200)
    popup:SetPoint("CENTER")
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
    popup:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(200)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
    self.blizzardWarningPopup = popup
    
    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText(L["Blizzard Click-Casting"])
    title:SetTextColor(1, 0.8, 0.2)  -- Yellow/orange warning color
    
    -- Message
    local msg = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    msg:SetPoint("TOP", title, "BOTTOM", 0, -15)
    msg:SetPoint("LEFT", 25, 0)
    msg:SetPoint("RIGHT", -25, 0)
    msg:SetJustifyH("CENTER")
    msg:SetText(L["Blizzard's built-in click-casting may conflict with\nDandersFrames click-casting settings.\n\nWe recommend clearing Blizzard's bindings from\nframes where you use DandersFrames bindings."])
    msg:SetTextColor(0.9, 0.9, 0.9)
    
    -- Helper function to create buttons
    local function CreateButton(parent, text, isPrimary)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(160, 30)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        
        if isPrimary then
            btn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            btn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        else
            btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
            btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(1, 1, 1)
        btn.label = btnText
        
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            if isPrimary then
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            else
                self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            end
        end)
        
        return btn
    end
    
    -- "Clear Blizzard Bindings" button (primary)
    local clearBtn = CreateButton(popup, L["Clear Blizzard Bindings"], true)
    clearBtn:SetPoint("BOTTOMLEFT", 25, 20)
    clearBtn:SetScript("OnClick", function()
        -- Reset Blizzard's click-casting profile to default (removes all custom bindings)
        if C_ClickBindings and C_ClickBindings.ResetCurrentProfile then
            C_ClickBindings.ResetCurrentProfile()
            print("|cff33cc33DandersFrames:|r Blizzard click-casting profile reset to default.")
        end
        
        -- Remember to clear on future enables
        CC.db.clearBlizzardOnEnable = true
        
        -- Also clear from our registered frames
        CC:RefreshBlizzardClickCastClearing()
        
        popup:Hide()
        
        -- Proceed with enabling
        if onConfirm then onConfirm() end
    end)
    
    -- "Ignore" button
    local ignoreBtn = CreateButton(popup, L["Ignore"], false)
    ignoreBtn:SetPoint("BOTTOMRIGHT", -25, 20)
    ignoreBtn:SetScript("OnClick", function()
        -- Just proceed without clearing
        popup:Hide()
        
        if onConfirm then onConfirm() end
    end)
    
    -- "Don't show again" checkbox (small, bottom center)
    local dontShowCb = CreateFrame("CheckButton", nil, popup, "BackdropTemplate")
    dontShowCb:SetSize(14, 14)
    dontShowCb:SetPoint("BOTTOM", 0, 55)
    dontShowCb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    dontShowCb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    dontShowCb:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    local check = dontShowCb:CreateTexture(nil, "OVERLAY")
    check:SetSize(16, 16)
    check:SetPoint("CENTER", 0, 0)
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetVertexColor(themeColor.r, themeColor.g, themeColor.b, 1)
    check:Hide()
    dontShowCb.check = check
    
    dontShowCb:SetScript("OnClick", function(self)
        if self.check:IsShown() then
            self.check:Hide()
            CC.db.ignoreBlizzardWarning = false
        else
            self.check:Show()
            CC.db.ignoreBlizzardWarning = true
        end
    end)
    
    local dontShowLabel = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    dontShowLabel:SetPoint("LEFT", dontShowCb, "RIGHT", 5, 0)
    dontShowLabel:SetText(L["Don't show this warning again"])
    dontShowLabel:SetTextColor(0.6, 0.6, 0.6)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER")
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(0.7, 0.7, 0.7)
    closeBtn:SetScript("OnEnter", function() closeIcon:SetVertexColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeIcon:SetVertexColor(0.7, 0.7, 0.7) end)
    closeBtn:SetScript("OnClick", function()
        -- Revert checkbox state
        if enableCheckbox then
            enableCheckbox:SetChecked(false)
        end
        popup:Hide()
    end)
    
    popup:Show()
end

-- =========================================================================

-- MACRO EDITOR DIALOG
-- ============================================================

local macroEditorDialog = nil

function CC:ShowMacroEditorDialog(existingMacro)
    -- Close all other macro dialogs first
    self:CloseAllMacroDialogs()
    
    local themeColor = DF.GUI and DF.GUI.GetThemeColor and DF.GUI.GetThemeColor() or {r = 0.2, g = 0.8, b = 0.4}
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08}
    local C_PANEL = {r = 0.12, g = 0.12, b = 0.12}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
    local C_TEXT_DIM = {r = 0.6, g = 0.6, b = 0.6}
    
    local isEditing = existingMacro ~= nil
    local isImported = existingMacro and (existingMacro.source == "global_import" or existingMacro.source == "char_import")
    
    -- Create dialog
    macroEditorDialog = CreateFrame("Frame", "DFMacroEditorDialog", UIParent, "BackdropTemplate")
    local thisDialog = macroEditorDialog  -- Local capture for closures
    macroEditorDialog:SetSize(400, 380)
    macroEditorDialog:SetPoint("CENTER", 0, 50)
    macroEditorDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    macroEditorDialog:SetFrameLevel(100)
    macroEditorDialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    macroEditorDialog:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.98)
    macroEditorDialog:SetBackdropBorderColor(0, 0, 0, 1)
    macroEditorDialog:EnableMouse(true)
    macroEditorDialog:SetMovable(true)
    macroEditorDialog:RegisterForDrag("LeftButton")
    macroEditorDialog:SetScript("OnDragStart", macroEditorDialog.StartMoving)
    macroEditorDialog:SetScript("OnDragStop", macroEditorDialog.StopMovingOrSizing)
    
    -- Title
    local title = macroEditorDialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    if isEditing then
        if isImported then
            title:SetText(L["View Imported Macro"])
        else
            title:SetText(L["Edit Macro"])
        end
    else
        title:SetText(L["Create Custom Macro"])
    end
    title:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetSize(20, 20)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    closeBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    closeBtn:SetScript("OnClick", function() thisDialog:Hide() end)
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.8, 0.2, 0.2, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Icon button
    local selectedIcon = existingMacro and existingMacro.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    local userSelectedIcon = existingMacro and existingMacro.icon and true or false -- Track if user manually picked
    
    local iconBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
    iconBtn:SetSize(48, 48)
    iconBtn:SetPoint("TOPLEFT", 12, -40)
    iconBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    iconBtn:SetBackdropColor(0, 0, 0, 0.5)
    iconBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local iconTexture = iconBtn:CreateTexture(nil, "ARTWORK")
    iconTexture:SetSize(44, 44)
    iconTexture:SetPoint("CENTER")
    iconTexture:SetTexture(selectedIcon)
    iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Function to auto-update icon from body text
    local function TryAutoUpdateIcon(bodyText)
        if userSelectedIcon then return end -- Don't override user selection
        local autoIcon = CC:GetIconFromMacroBody(bodyText)
        if autoIcon then
            selectedIcon = autoIcon
            iconTexture:SetTexture(autoIcon)
        end
    end
    
    iconBtn:SetScript("OnClick", function()
        if not isImported then
            CC:ShowIconPickerDialog(function(iconId)
                selectedIcon = iconId
                userSelectedIcon = true -- Mark as user-selected
                iconTexture:SetTexture(iconId)
            end)
        end
    end)
    iconBtn:SetScript("OnEnter", function(self)
        if not isImported then
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        end
    end)
    iconBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    end)
    
    -- Store function for use by body input
    macroEditorDialog.TryAutoUpdateIcon = TryAutoUpdateIcon
    
    -- Name label
    local nameLabel = macroEditorDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    nameLabel:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 10, -2)
    nameLabel:SetText(L["Name:"])
    nameLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Name input
    local nameInput = CreateFrame("EditBox", nil, macroEditorDialog, "BackdropTemplate")
    nameInput:SetSize(310, 24)
    nameInput:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -4)
    nameInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    nameInput:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    nameInput:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    DF.GUI:SetSettingsFont(nameInput, 11, "")
    nameInput:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    nameInput:SetTextInsets(6, 6, 0, 0)
    nameInput:SetAutoFocus(false)
    nameInput:SetText(existingMacro and existingMacro.name or "")
    nameInput:SetEnabled(not isImported)
    if isImported then
        nameInput:SetBackdropColor(C_ELEMENT.r - 0.05, C_ELEMENT.g - 0.05, C_ELEMENT.b - 0.05, 1)
    end
    
    -- Body label
    local bodyLabel = macroEditorDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    bodyLabel:SetPoint("TOPLEFT", 12, -105)
    bodyLabel:SetText(L["Macro Text:"])
    bodyLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Character count
    local charCount = macroEditorDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    charCount:SetPoint("TOPRIGHT", -12, -105)
    charCount:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Body scroll frame
    local bodyScroll = CreateFrame("ScrollFrame", nil, macroEditorDialog, "ScrollFrameTemplate")
    bodyScroll:SetSize(370, 160)
    bodyScroll:SetPoint("TOPLEFT", bodyLabel, "BOTTOMLEFT", 0, -4)
    DF.GUI.StyleScrollBar(bodyScroll)

    local bodyBg = CreateFrame("Frame", nil, bodyScroll, "BackdropTemplate")
    bodyBg:SetAllPoints(bodyScroll)
    bodyBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    bodyBg:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    bodyBg:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    bodyBg:SetFrameLevel(bodyScroll:GetFrameLevel() - 1)
    
    -- Body edit box
    local bodyInput = CreateFrame("EditBox", nil, bodyScroll)
    bodyInput:SetSize(360, 160)
    DF.GUI:SetSettingsFont(bodyInput, 11, "")
    bodyInput:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    bodyInput:SetMultiLine(true)
    bodyInput:SetAutoFocus(false)
    bodyInput:SetTextInsets(6, 6, 6, 6)
    bodyInput:SetText(existingMacro and existingMacro.body or "#showtooltip\n")
    bodyInput:SetEnabled(not isImported)
    bodyScroll:SetScrollChild(bodyInput)
    
    local function UpdateCharCount()
        local text = bodyInput:GetText() or ""
        local len = #text
        local color = len > 255 and "|cffff4444" or (len > 230 and "|cffffaa00" or "|cff88ff88")
        charCount:SetText(color .. len .. "/255|r")
        
        -- Also try to auto-update icon based on body text
        if macroEditorDialog.TryAutoUpdateIcon then
            macroEditorDialog.TryAutoUpdateIcon(text)
        end
    end
    UpdateCharCount()
    bodyInput:SetScript("OnTextChanged", UpdateCharCount)
    
    -- Buttons at bottom
    local buttonY = -340
    
    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
    cancelBtn:SetSize(80, 28)
    cancelBtn:SetPoint("BOTTOMLEFT", 12, 12)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    cancelBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    cancelBtn:SetScript("OnClick", function() thisDialog:Hide() end)
    cancelBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(C_ELEMENT.r + 0.1, C_ELEMENT.g + 0.1, C_ELEMENT.b + 0.1, 1) end)
    cancelBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Delete button (for editing)
    if isEditing and not isImported then
        local deleteBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
        deleteBtn:SetSize(80, 28)
        deleteBtn:SetPoint("LEFT", cancelBtn, "RIGHT", 8, 0)
        deleteBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        deleteBtn:SetBackdropColor(0.4, 0.1, 0.1, 1)
        deleteBtn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
        local deleteText = deleteBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        deleteText:SetPoint("CENTER")
        deleteText:SetText(L["Delete"])
        deleteText:SetTextColor(1, 0.5, 0.5)
        deleteBtn:SetScript("OnClick", function()
            StaticPopupDialogs["DF_CONFIRM_DELETE_MACRO"] = {
                text = format(L["Delete macro '%s'?\nAny bindings using this macro will be removed."], existingMacro.name),
                button1 = L["Delete"],
                button2 = L["Cancel"],
                OnAccept = function()
                    CC:DeleteMacro(existingMacro.id)
                    CC:RefreshSpellGrid()
                    thisDialog:Hide()
                    -- Macro deleted
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            ShowPopupOnTop("DF_CONFIRM_DELETE_MACRO")
        end)
        deleteBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.6, 0.15, 0.15, 1) end)
        deleteBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.4, 0.1, 0.1, 1) end)
    end
    
    -- Import-specific buttons
    if isImported then
        -- Delete button for imported macros (positioned next to cancel)
        local deleteBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
        deleteBtn:SetSize(80, 28)
        deleteBtn:SetPoint("LEFT", cancelBtn, "RIGHT", 8, 0)
        deleteBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        deleteBtn:SetBackdropColor(0.4, 0.1, 0.1, 1)
        deleteBtn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
        local deleteText = deleteBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        deleteText:SetPoint("CENTER")
        deleteText:SetText(L["Delete"])
        deleteText:SetTextColor(1, 0.5, 0.5)
        deleteBtn:SetScript("OnClick", function()
            StaticPopupDialogs["DF_CONFIRM_DELETE_IMPORTED_MACRO"] = {
                text = format(L["Delete imported macro '%s'?\nAny bindings using this macro will be removed.\n\n(The original WoW macro will not be affected)"], existingMacro.name),
                button1 = L["Delete"],
                button2 = L["Cancel"],
                OnAccept = function()
                    CC:DeleteMacro(existingMacro.id)
                    CC:RefreshSpellGrid()
                    thisDialog:Hide()
                    -- Macro deleted
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            ShowPopupOnTop("DF_CONFIRM_DELETE_IMPORTED_MACRO")
        end)
        deleteBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.6, 0.15, 0.15, 1) end)
        deleteBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.4, 0.1, 0.1, 1) end)
        
        -- Sync button
        local syncBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
        syncBtn:SetSize(100, 28)
        syncBtn:SetPoint("BOTTOMRIGHT", -100, 12)
        syncBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        syncBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        syncBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        local syncText = syncBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        syncText:SetPoint("CENTER")
        syncText:SetText(L["Sync from WoW"])
        syncText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        syncBtn:SetScript("OnClick", function()
            local success, msg = CC:SyncImportedMacro(existingMacro.id)
            if success then
                print("|cff00ff00DandersFrames:|r " .. msg)
                thisDialog:Hide()
                CC:ShowMacroEditorDialog(CC:GetMacroById(existingMacro.id))
            else
                print("|cffff4444DandersFrames:|r " .. msg)
            end
        end)
        
        -- Convert to Custom button
        local convertBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
        convertBtn:SetSize(80, 28)
        convertBtn:SetPoint("BOTTOMRIGHT", -12, 12)
        convertBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        convertBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
        convertBtn:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
        local convertText = convertBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        convertText:SetPoint("CENTER")
        convertText:SetText(L["Edit Copy"])
        convertText:SetTextColor(1, 1, 1)
        convertBtn:SetScript("OnClick", function()
            CC:ConvertToCustomMacro(existingMacro.id)
            -- Converted
            thisDialog:Hide()
            CC:ShowMacroEditorDialog(CC:GetMacroById(existingMacro.id))
            CC:RefreshSpellGrid()
        end)
    else
        -- Save button
        local saveBtn = CreateFrame("Button", nil, macroEditorDialog, "BackdropTemplate")
        saveBtn:SetSize(80, 28)
        saveBtn:SetPoint("BOTTOMRIGHT", -12, 12)
        saveBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        saveBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
        saveBtn:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
        local saveText = saveBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        saveText:SetPoint("CENTER")
        saveText:SetText(L["Save"])
        saveText:SetTextColor(1, 1, 1)
        saveBtn:SetScript("OnClick", function()
            local name = nameInput:GetText():trim()
            local body = bodyInput:GetText()
            
            if name == "" then
                print("|cffff4444DandersFrames:|r Please enter a macro name")
                return
            end
            if body == "" then
                print("|cffff4444DandersFrames:|r Please enter macro text")
                return
            end
            if #body > 255 then
                print("|cffff4444DandersFrames:|r Macro text exceeds 255 characters")
                return
            end
            
            local macroData = {
                id = existingMacro and existingMacro.id or nil,
                name = name,
                icon = selectedIcon,
                body = body,
                source = "custom",
            }
            
            CC:SaveMacro(macroData)
            CC:ApplyBindings()
            CC:RefreshSpellGrid()
            thisDialog:Hide()
            -- Macro saved
        end)
        saveBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(themeColor.r * 0.5, themeColor.g * 0.5, themeColor.b * 0.5, 1) end)
        saveBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1) end)
    end
    
    macroEditorDialog:Show()
end

-- ============================================================

-- ICON PICKER DIALOG
-- ============================================================

local iconPickerDialog = nil

function CC:ShowIconPickerDialog(onSelect)
    if iconPickerDialog then
        iconPickerDialog:Hide()
    end
    
    local themeColor = DF.GUI and DF.GUI.GetThemeColor and DF.GUI.GetThemeColor() or {r = 0.2, g = 0.8, b = 0.4}
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
    local C_TEXT_DIM = {r = 0.6, g = 0.6, b = 0.6}
    
    iconPickerDialog = CreateFrame("Frame", "DFIconPickerDialog", UIParent, "BackdropTemplate")
    iconPickerDialog:SetSize(320, 280)
    iconPickerDialog:SetPoint("CENTER", 0, 50)
    iconPickerDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    iconPickerDialog:SetFrameLevel(110)
    iconPickerDialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    iconPickerDialog:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.98)
    iconPickerDialog:SetBackdropBorderColor(0, 0, 0, 1)
    iconPickerDialog:EnableMouse(true)
    iconPickerDialog:SetMovable(true)
    iconPickerDialog:RegisterForDrag("LeftButton")
    iconPickerDialog:SetScript("OnDragStart", iconPickerDialog.StartMoving)
    iconPickerDialog:SetScript("OnDragStop", iconPickerDialog.StopMovingOrSizing)
    
    -- Title
    local title = iconPickerDialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(L["Choose Icon"])
    title:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, iconPickerDialog, "BackdropTemplate")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetSize(20, 20)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    closeBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    closeBtn:SetScript("OnClick", function() iconPickerDialog:Hide() end)
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.8, 0.2, 0.2, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Icon grid
    local iconSize = 32
    local padding = 4
    local cols = 8
    local startY = -40
    
    for i, iconId in ipairs(CC.COMMON_MACRO_ICONS) do
        local row = math.floor((i - 1) / cols)
        local col = (i - 1) % cols
        
        local iconBtn = CreateFrame("Button", nil, iconPickerDialog, "BackdropTemplate")
        iconBtn:SetSize(iconSize, iconSize)
        iconBtn:SetPoint("TOPLEFT", 12 + col * (iconSize + padding), startY - row * (iconSize + padding))
        iconBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        iconBtn:SetBackdropColor(0, 0, 0, 0.3)
        iconBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        
        local tex = iconBtn:CreateTexture(nil, "ARTWORK")
        tex:SetSize(iconSize - 4, iconSize - 4)
        tex:SetPoint("CENTER")
        tex:SetTexture(iconId)
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        
        iconBtn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        end)
        iconBtn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        end)
        iconBtn:SetScript("OnClick", function()
            if onSelect then onSelect(iconId) end
            iconPickerDialog:Hide()
        end)
    end
    
    -- Manual ID input
    local idLabel = iconPickerDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    idLabel:SetPoint("BOTTOMLEFT", 12, 50)
    idLabel:SetText(L["Or enter Icon ID:"])
    idLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local idInput = CreateFrame("EditBox", nil, iconPickerDialog, "BackdropTemplate")
    idInput:SetSize(100, 24)
    idInput:SetPoint("LEFT", idLabel, "RIGHT", 8, 0)
    idInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    idInput:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    idInput:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    DF.GUI:SetSettingsFont(idInput, 11, "")
    idInput:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    idInput:SetTextInsets(6, 6, 0, 0)
    idInput:SetAutoFocus(false)
    idInput:SetNumeric(true)
    
    local useIdBtn = CreateFrame("Button", nil, iconPickerDialog, "BackdropTemplate")
    useIdBtn:SetSize(50, 24)
    useIdBtn:SetPoint("LEFT", idInput, "RIGHT", 4, 0)
    useIdBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    useIdBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    useIdBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local useIdText = useIdBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    useIdText:SetPoint("CENTER")
    useIdText:SetText(L["Use"])
    useIdText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    useIdBtn:SetScript("OnClick", function()
        local id = tonumber(idInput:GetText())
        if id then
            if onSelect then onSelect(id) end
            iconPickerDialog:Hide()
        end
    end)
    
    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, iconPickerDialog, "BackdropTemplate")
    cancelBtn:SetSize(80, 28)
    cancelBtn:SetPoint("BOTTOMRIGHT", -12, 12)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    cancelBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    cancelBtn:SetScript("OnClick", function() iconPickerDialog:Hide() end)
    
    iconPickerDialog:Show()
end

-- ============================================================

-- IMPORT MACRO DIALOG
-- ============================================================

local importMacroDialog = nil

function CC:ShowImportMacroDialog()
    -- Close all other macro dialogs first
    self:CloseAllMacroDialogs()
    
    local themeColor = DF.GUI and DF.GUI.GetThemeColor and DF.GUI.GetThemeColor() or {r = 0.2, g = 0.8, b = 0.4}
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
    local C_TEXT_DIM = {r = 0.6, g = 0.6, b = 0.6}
    
    importMacroDialog = CreateFrame("Frame", "DFImportMacroDialog", UIParent, "BackdropTemplate")
    local thisDialog = importMacroDialog  -- Local capture for closures
    importMacroDialog:SetSize(400, 400)
    importMacroDialog:SetPoint("CENTER", 0, 50)
    importMacroDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    importMacroDialog:SetFrameLevel(100)
    importMacroDialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    importMacroDialog:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.98)
    importMacroDialog:SetBackdropBorderColor(0, 0, 0, 1)
    importMacroDialog:EnableMouse(true)
    importMacroDialog:SetMovable(true)
    importMacroDialog:RegisterForDrag("LeftButton")
    importMacroDialog:SetScript("OnDragStart", importMacroDialog.StartMoving)
    importMacroDialog:SetScript("OnDragStop", importMacroDialog.StopMovingOrSizing)
    
    -- Title
    local title = importMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(L["Import WoW Macros"])
    title:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, importMacroDialog, "BackdropTemplate")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetSize(20, 20)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    closeBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    closeBtn:SetScript("OnClick", function() thisDialog:Hide() end)
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.8, 0.2, 0.2, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Tab buttons
    local selectedTab = "general"
    local selectedMacros = {}
    local macroRows = {}
    
    local function CreateImportTab(text, tabKey, anchor, anchorTo)
        local btn = CreateFrame("Button", nil, importMacroDialog, "BackdropTemplate")
        btn:SetSize(80, 24)
        if anchorTo then
            btn:SetPoint("LEFT", anchorTo, "RIGHT", 4, 0)
        else
            btn:SetPoint("TOPLEFT", 12, -35)
        end
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        
        function btn:SetActive(active)
            if active then
                self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
            else
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
            end
        end
        
        return btn
    end
    
    local globalTab = CreateImportTab("General", "general")
    local charTab = CreateImportTab("Character", "character", nil, globalTab)
    
    -- Scroll frame for macro list
    local scrollContainer = CreateFrame("Frame", nil, importMacroDialog, "BackdropTemplate")
    scrollContainer:SetPoint("TOPLEFT", 12, -65)
    scrollContainer:SetPoint("BOTTOMRIGHT", -12, 50)
    scrollContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    scrollContainer:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0.5)
    scrollContainer:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local scrollFrame = CreateFrame("ScrollFrame", nil, scrollContainer, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -24, 4)
    DF.GUI.StyleScrollBar(scrollFrame)

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetWidth(scrollFrame:GetWidth())
    scrollContent:SetHeight(1)
    scrollFrame:SetScrollChild(scrollContent)
    
    -- Selected count
    local selectedCount = importMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    selectedCount:SetPoint("BOTTOMLEFT", 12, 18)
    selectedCount:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local function UpdateSelectedCount()
        local count = 0
        for _ in pairs(selectedMacros) do count = count + 1 end
        selectedCount:SetText(format(L["Selected: %d"], count))
    end
    
    local function RefreshMacroList()
        -- Clear existing rows
        for _, row in ipairs(macroRows) do
            row:Hide()
            row:SetParent(nil)
        end
        wipe(macroRows)
        wipe(selectedMacros)
        
        local macros
        if selectedTab == "general" then
            macros = CC:GetWoWGlobalMacros()
        else
            macros = CC:GetWoWCharacterMacros()
        end
        
        local yOffset = 0
        for i, macro in ipairs(macros) do
            local row = CreateFrame("Button", nil, scrollContent, "BackdropTemplate")
            row:SetSize(scrollContent:GetWidth() - 8, 28)
            row:SetPoint("TOPLEFT", 4, -yOffset)
            row:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
            })
            row:SetBackdropColor(0, 0, 0, 0)
            
            -- Checkbox
            local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
            cb:SetSize(20, 20)
            cb:SetPoint("LEFT", 2, 0)
            cb:SetScript("OnClick", function(self)
                if self:GetChecked() then
                    selectedMacros[macro.wowIndex] = macro
                else
                    selectedMacros[macro.wowIndex] = nil
                end
                UpdateSelectedCount()
            end)
            
            -- Icon
            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(22, 22)
            icon:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            -- Try auto-detect icon from macro body first
            local autoIcon = CC:GetIconFromMacroBody(macro.body)
            if autoIcon then
                icon:SetTexture(autoIcon)
            elseif macro.icon and type(macro.icon) == "number" and macro.icon > 0 then
                icon:SetTexture(macro.icon)
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            
            -- Name
            local name = row:CreateFontString(nil, "OVERLAY", "DFFontNormal")
            name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            name:SetText(macro.name)
            name:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            
            row:SetScript("OnEnter", function(self)
                self:SetBackdropColor(1, 1, 1, 0.05)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(macro.name, 1, 1, 1)
                local bodyPreview = macro.body or ""
                if #bodyPreview > 150 then bodyPreview = bodyPreview:sub(1, 150) .. "..." end
                GameTooltip:AddLine(bodyPreview, 0.7, 0.7, 0.7, true)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                self:SetBackdropColor(0, 0, 0, 0)
                GameTooltip:Hide()
            end)
            row:SetScript("OnClick", function()
                cb:Click()
            end)
            
            table.insert(macroRows, row)
            yOffset = yOffset + 30
        end
        
        scrollContent:SetHeight(math.max(100, yOffset))
        UpdateSelectedCount()
    end
    
    globalTab:SetScript("OnClick", function()
        selectedTab = "general"
        globalTab:SetActive(true)
        charTab:SetActive(false)
        RefreshMacroList()
    end)
    
    charTab:SetScript("OnClick", function()
        selectedTab = "character"
        globalTab:SetActive(false)
        charTab:SetActive(true)
        RefreshMacroList()
    end)
    
    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, importMacroDialog, "BackdropTemplate")
    cancelBtn:SetSize(80, 28)
    cancelBtn:SetPoint("BOTTOMLEFT", 12, 12)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    cancelBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    cancelBtn:SetScript("OnClick", function() thisDialog:Hide() end)
    
    -- Import All button
    local importAllBtn = CreateFrame("Button", nil, importMacroDialog, "BackdropTemplate")
    importAllBtn:SetSize(80, 28)
    importAllBtn:SetPoint("LEFT", cancelBtn, "RIGHT", 6, 0)
    importAllBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    importAllBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    importAllBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local importAllText = importAllBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    importAllText:SetPoint("CENTER")
    importAllText:SetText(L["Import All"])
    importAllText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    importAllBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    end)
    importAllBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    end)
    importAllBtn:SetScript("OnClick", function()
        -- Import all macros from both general and character
        local globalMacros = CC:GetWoWGlobalMacros()
        local charMacros = CC:GetWoWCharacterMacros()
        local imported = 0
        local updated = 0
        
        for _, macro in ipairs(globalMacros) do
            local result, status = CC:ImportWoWMacro(macro)
            if status == "imported" then
                imported = imported + 1
            elseif status == "updated" then
                updated = updated + 1
            end
        end
        
        for _, macro in ipairs(charMacros) do
            local result, status = CC:ImportWoWMacro(macro)
            if status == "imported" then
                imported = imported + 1
            elseif status == "updated" then
                updated = updated + 1
            end
        end
        
        local msg = ""
        if imported > 0 then msg = msg .. "Imported " .. imported .. " macro(s). " end
        if updated > 0 then msg = msg .. "Updated " .. updated .. " macro(s)." end
        if msg ~= "" then
            print("|cff00ff00DandersFrames:|r " .. msg)
        else
            print("|cff00ff00DandersFrames:|r All macros already imported.")
        end
        
        thisDialog:Hide()
        CC:RefreshSpellGrid()
    end)
    
    -- Import button
    local importBtn = CreateFrame("Button", nil, importMacroDialog, "BackdropTemplate")
    importBtn:SetSize(80, 28)
    importBtn:SetPoint("BOTTOMRIGHT", -12, 12)
    importBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    importBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
    importBtn:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
    local importText = importBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    importText:SetPoint("CENTER")
    importText:SetText(L["Import"])
    importText:SetTextColor(1, 1, 1)
    importBtn:SetScript("OnClick", function()
        local imported = 0
        local updated = 0
        for _, macro in pairs(selectedMacros) do
            local result, status = CC:ImportWoWMacro(macro)
            if status == "imported" then
                imported = imported + 1
            elseif status == "updated" then
                updated = updated + 1
            end
        end
        
        local msg = ""
        if imported > 0 then msg = msg .. "Imported " .. imported .. " macro(s). " end
        if updated > 0 then msg = msg .. "Updated " .. updated .. " macro(s)." end
        if msg ~= "" then
            print("|cff00ff00DandersFrames:|r " .. msg)
        end
        
        thisDialog:Hide()
        CC:RefreshSpellGrid()
    end)
    
    -- Initialize
    globalTab:SetActive(true)
    RefreshMacroList()
    
    importMacroDialog:Show()
end

-- ============================================================

-- QUICK MACRO BUILDER DIALOG
-- ============================================================

local quickMacroDialog = nil

function CC:ShowQuickMacroDialog()
    -- Close all other macro dialogs first
    self:CloseAllMacroDialogs()
    
    local themeColor = DF.GUI and DF.GUI.GetThemeColor and DF.GUI.GetThemeColor() or {r = 0.2, g = 0.8, b = 0.4}
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
    local C_TEXT_DIM = {r = 0.6, g = 0.6, b = 0.6}
    
    quickMacroDialog = CreateFrame("Frame", "DFQuickMacroDialog", UIParent, "BackdropTemplate")
    local thisDialog = quickMacroDialog  -- Local capture for closures
    quickMacroDialog:SetSize(420, 400)
    quickMacroDialog:SetPoint("CENTER", 0, 50)
    quickMacroDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    quickMacroDialog:SetFrameLevel(100)
    quickMacroDialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    quickMacroDialog:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.98)
    quickMacroDialog:SetBackdropBorderColor(0, 0, 0, 1)
    quickMacroDialog:EnableMouse(true)
    quickMacroDialog:SetMovable(true)
    quickMacroDialog:RegisterForDrag("LeftButton")
    quickMacroDialog:SetScript("OnDragStart", quickMacroDialog.StartMoving)
    quickMacroDialog:SetScript("OnDragStop", quickMacroDialog.StopMovingOrSizing)
    
    -- Title
    local title = quickMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(L["Quick Macro Builder"])
    title:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, quickMacroDialog, "BackdropTemplate")
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    closeBtn:SetSize(20, 20)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    closeBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    closeBtn:SetScript("OnClick", function() thisDialog:Hide() end)
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.8, 0.2, 0.2, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- State
    local selectedSpell = nil
    local selectedPattern = "mouseover_target_self"
    local showTooltip = true
    local stopCasting = false
    
    -- Spell search
    local spellLabel = quickMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    spellLabel:SetPoint("TOPLEFT", 12, -40)
    spellLabel:SetText(L["Spell:"])
    spellLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local spellInput = CreateFrame("EditBox", nil, quickMacroDialog, "BackdropTemplate")
    spellInput:SetSize(300, 24)
    spellInput:SetPoint("TOPLEFT", spellLabel, "BOTTOMLEFT", 0, -4)
    spellInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    spellInput:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    spellInput:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    DF.GUI:SetSettingsFont(spellInput, 11, "")
    spellInput:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    spellInput:SetTextInsets(6, 6, 0, 0)
    spellInput:SetAutoFocus(false)
    
    -- Spell icon display
    local spellIcon = quickMacroDialog:CreateTexture(nil, "ARTWORK")
    spellIcon:SetSize(24, 24)
    spellIcon:SetPoint("LEFT", spellInput, "RIGHT", 8, 0)
    spellIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Pattern selection
    local patternLabel = quickMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    patternLabel:SetPoint("TOPLEFT", 12, -95)
    patternLabel:SetText(L["Pattern:"])
    patternLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local patterns = {
        {key = "mouseover_target_self", label = "Mouseover → Target → Self (Helpful)"},
        {key = "mouseover_target", label = "Mouseover → Target (Helpful)"},
        {key = "mouseover_only", label = "Mouseover Only (Helpful)"},
        {key = "harm_mouseover_target", label = "Mouseover → Target (Harmful)"},
        {key = "focus_mouseover_target", label = "Focus → Mouseover → Target"},
    }
    
    local patternButtons = {}
    local yOffset = -115
    
    local function UpdatePreview()
        if not selectedSpell then return end
        local macroText = CC:BuildQuickMacro(selectedSpell, selectedPattern, {
            showTooltip = showTooltip,
            stopCasting = stopCasting,
        })
        if quickMacroDialog.previewText then
            quickMacroDialog.previewText:SetText(macroText)
        end
    end
    
    for i, pattern in ipairs(patterns) do
        local btn = CreateFrame("Button", nil, quickMacroDialog, "BackdropTemplate")
        btn:SetSize(390, 22)
        btn:SetPoint("TOPLEFT", 12, yOffset)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
        })
        btn:SetBackdropColor(0, 0, 0, 0)
        
        local radio = btn:CreateTexture(nil, "ARTWORK")
        radio:SetSize(14, 14)
        radio:SetPoint("LEFT", 4, 0)
        radio:SetTexture("Interface\\Buttons\\UI-RadioButton")
        radio:SetTexCoord(0, 0.25, 0, 1)
        btn.radio = radio
        
        local label = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        label:SetPoint("LEFT", radio, "RIGHT", 6, 0)
        label:SetText(pattern.label)
        label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        
        function btn:SetSelected(selected)
            if selected then
                self.radio:SetTexCoord(0.25, 0.5, 0, 1)
            else
                self.radio:SetTexCoord(0, 0.25, 0, 1)
            end
        end
        
        btn:SetScript("OnClick", function()
            selectedPattern = pattern.key
            for _, b in ipairs(patternButtons) do
                b:SetSelected(false)
            end
            btn:SetSelected(true)
            UpdatePreview()
        end)
        
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(1, 1, 1, 0.05)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0)
        end)
        
        if pattern.key == selectedPattern then
            btn:SetSelected(true)
        end
        
        table.insert(patternButtons, btn)
        yOffset = yOffset - 24
    end
    
    -- Options
    yOffset = yOffset - 10
    
    local tooltipCb = CreateFrame("CheckButton", nil, quickMacroDialog, "UICheckButtonTemplate")
    tooltipCb:SetSize(20, 20)
    tooltipCb:SetPoint("TOPLEFT", 12, yOffset)
    tooltipCb:SetChecked(true)
    tooltipCb:SetScript("OnClick", function(self)
        showTooltip = self:GetChecked()
        UpdatePreview()
    end)
    local tooltipLabel = quickMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    tooltipLabel:SetPoint("LEFT", tooltipCb, "RIGHT", 4, 0)
    tooltipLabel:SetText(L["Add #showtooltip"])
    tooltipLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    local stopCb = CreateFrame("CheckButton", nil, quickMacroDialog, "UICheckButtonTemplate")
    stopCb:SetSize(20, 20)
    stopCb:SetPoint("LEFT", tooltipLabel, "RIGHT", 20, 0)
    stopCb:SetChecked(false)
    stopCb:SetScript("OnClick", function(self)
        stopCasting = self:GetChecked()
        UpdatePreview()
    end)
    local stopLabel = quickMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    stopLabel:SetPoint("LEFT", stopCb, "RIGHT", 4, 0)
    stopLabel:SetText(L["Add /stopcasting"])
    stopLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Preview
    yOffset = yOffset - 35
    local previewLabel = quickMacroDialog:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    previewLabel:SetPoint("TOPLEFT", 12, yOffset)
    previewLabel:SetText(L["Preview:"])
    previewLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local previewBg = CreateFrame("Frame", nil, quickMacroDialog, "BackdropTemplate")
    previewBg:SetSize(390, 60)
    previewBg:SetPoint("TOPLEFT", previewLabel, "BOTTOMLEFT", 0, -4)
    previewBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    previewBg:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    previewBg:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    
    local previewText = previewBg:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    previewText:SetPoint("TOPLEFT", 8, -8)
    previewText:SetPoint("BOTTOMRIGHT", -8, 8)
    previewText:SetJustifyH("LEFT")
    previewText:SetJustifyV("TOP")
    previewText:SetTextColor(0.7, 0.7, 0.7)
    previewText:SetText(L["Enter a spell name above..."])
    quickMacroDialog.previewText = previewText
    
    -- Spell input handling
    spellInput:SetScript("OnTextChanged", function(self)
        local text = self:GetText():trim()
        if text == "" then
            selectedSpell = nil
            spellIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            previewText:SetText(L["Enter a spell name above..."])
            return
        end
        
        -- Try to find exact spell
        local spellInfo = C_Spell.GetSpellInfo(text)
        if spellInfo then
            selectedSpell = spellInfo.name
            spellIcon:SetTexture(spellInfo.iconID or "Interface\\Icons\\INV_Misc_QuestionMark")
            UpdatePreview()
        else
            selectedSpell = text -- Use raw text
            spellIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            UpdatePreview()
        end
    end)
    
    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, quickMacroDialog, "BackdropTemplate")
    cancelBtn:SetSize(80, 28)
    cancelBtn:SetPoint("BOTTOMLEFT", 12, 12)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    cancelBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    cancelBtn:SetScript("OnClick", function() thisDialog:Hide() end)
    
    -- Create Macro button
    local createBtn = CreateFrame("Button", nil, quickMacroDialog, "BackdropTemplate")
    createBtn:SetSize(100, 28)
    createBtn:SetPoint("BOTTOMRIGHT", -12, 12)
    createBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    createBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
    createBtn:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
    local createText = createBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    createText:SetPoint("CENTER")
    createText:SetText(L["Create Macro"])
    createText:SetTextColor(1, 1, 1)
    createBtn:SetScript("OnClick", function()
        if not selectedSpell then
            print("|cffff4444DandersFrames:|r Please enter a spell name")
            return
        end
        
        local macroText = CC:BuildQuickMacro(selectedSpell, selectedPattern, {
            showTooltip = showTooltip,
            stopCasting = stopCasting,
        })
        
        -- Try to get spell icon
        local iconId = "Interface\\Icons\\INV_Misc_QuestionMark"
        local spellInfo = C_Spell.GetSpellInfo(selectedSpell)
        if spellInfo and spellInfo.iconID then
            iconId = spellInfo.iconID
        end
        
        local macroData = {
            name = selectedSpell .. " (Macro)",
            icon = iconId,
            body = macroText,
            source = "custom",
        }
        
        CC:SaveMacro(macroData)
        CC:RefreshSpellGrid()
        thisDialog:Hide()
        -- Macro created
    end)
    createBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(themeColor.r * 0.5, themeColor.g * 0.5, themeColor.b * 0.5, 1) end)
    createBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1) end)
    
    quickMacroDialog:Show()
end


-- Debug slash command for global bindings
SLASH_DFCCGLOBAL1 = "/dfccglobal"
SlashCmdList["DFCCGLOBAL"] = function(msg)
    if msg == "debug" then
        CC.db.options.debugBindings = not CC.db.options.debugBindings
        print("|cff33cc66DandersFrames:|r Debug mode " .. (CC.db.options.debugBindings and "ENABLED" or "DISABLED"))
    elseif msg == "apply" then
        -- Reapplied
        CC:ApplyBindings()
    elseif msg == "mouseover" then
        -- Check what WoW sees as mouseover
        local mo = UnitExists("mouseover")
        local moName = mo and UnitName("mouseover") or "nil"
        local moGuid = mo and UnitGUID("mouseover") or "nil"
        -- GetMouseFoci returns a table in modern WoW
        local frames = GetMouseFoci and GetMouseFoci() or {}
        local frame = frames[1]
        local frameName = frame and frame:GetName() or "nil"
        print("|cff33cc66Mouseover check:|r")
        print("  UnitExists('mouseover'): " .. tostring(mo))
        print("  UnitName('mouseover'): " .. moName)
        print("  UnitGUID('mouseover'): " .. tostring(moGuid))
        print("  GetMouseFoci()[1]: " .. frameName)
    elseif msg == "testclick" then
        -- Manually click the first global binding button
        if DFGlobalBinding1 then
            print("|cff33cc66Testing /click DFGlobalBinding1|r")
            local mo = UnitExists("mouseover") and UnitName("mouseover") or "nil"
            print("  mouseover before click: " .. mo)
            -- This won't actually click due to secure restrictions, but shows the info
        end
    elseif msg == "list" then
        print("|cff33cc66DandersFrames:|r Bindings by scope:")
        local counts = {unitframes = 0, blizzard = 0, onhover = 0, targetcast = 0}
        for i, binding in ipairs(CC.db.bindings) do
            if binding.enabled ~= false then
                local scope = binding.scope or "blizzard"
                counts[scope] = (counts[scope] or 0) + 1
            end
        end
        print("  Unit Frames Only: " .. counts.unitframes)
        print("  Unit Frames + Blizzard: " .. counts.blizzard)
        print("  On Hover (@mouseover): " .. counts.onhover)
        print("  Target Cast: " .. counts.targetcast)
        print("|cff33cc66Active global keybinds:|r " .. (CC.globalBindingCount or 0))
        
        -- Count registered frames
        local frameCount = 0
        if CC.registeredFrames then
            for frame in pairs(CC.registeredFrames) do
                frameCount = frameCount + 1
            end
        end
        print("|cff33cc66Total registered frames:|r " .. frameCount)
    elseif msg == "inspect" then
        -- Inspect what frame is under the mouse
        local frames = GetMouseFoci and GetMouseFoci() or {}
        local frame = frames[1]
        if frame then
            print("|cff33cc66Frame under mouse:|r")
            print("  Name: " .. (frame:GetName() or "nil"))
            print("  Type: " .. frame:GetObjectType())
            print("  Parent: " .. (frame:GetParent() and frame:GetParent():GetName() or "nil"))
            local unitAttr = frame.GetAttribute and frame:GetAttribute("unit") or "nil"
            print("  Unit attr: " .. (unitAttr or "nil"))
            print("  .unit field: " .. (frame.unit or "nil"))
            print("  Registered: " .. ((CC.registeredFrames and CC.registeredFrames[frame]) and "yes" or "no"))
            print("  dfClickCastRegistered: " .. (frame.dfClickCastRegistered and "yes" or "no"))
            print("  dfIsNameplate: " .. tostring(frame.dfIsNameplate or false))
            print("  dfKeyboardHandlersSetup: " .. tostring(frame.dfKeyboardHandlersSetup or false))
            
            -- Check if it's a Button
            local isButton = frame:IsObjectType("Button")
            print("  Is Button: " .. tostring(isButton))
            
            -- Check for RegisterForClicks
            if frame.GetRegisteredClicks then
                local clicks = frame:GetRegisteredClicks()
                print("  RegisteredClicks: " .. (clicks or "none"))
            end
            
            -- Check parent chain for nameplates
            local parent = frame:GetParent()
            local depth = 0
            local isNameplateChild = false
            while parent and depth < 5 do
                local pName = parent:GetName() or "unnamed"
                print("  Parent " .. depth .. ": " .. pName)
                if pName:match("NamePlate") then
                    print("    ^ This is a nameplate!")
                    isNameplateChild = true
                end
                parent = parent:GetParent()
                depth = depth + 1
            end
            
            -- If it's a nameplate child, check if the nameplate itself is registered
            if isNameplateChild then
                print("  Checking nameplate registrations...")
                for unitToken, regFrame in pairs(CC.registeredNameplates or {}) do
                    print("    " .. unitToken .. " -> " .. (regFrame:GetName() or "unnamed"))
                end
            end
        else
            print("|cffff6666No frame under mouse|r")
        end
    elseif msg == "nameplates" then
        -- Show all registered nameplates
        print("|cff33cc66DandersFrames:|r Registered Nameplates:")
        local count = 0
        for unitToken, frame in pairs(CC.registeredNameplates or {}) do
            count = count + 1
            local name = UnitName(unitToken) or "Unknown"
            local frameName = frame:GetName() or "unnamed"
            local registered = (CC.registeredFrames and CC.registeredFrames[frame]) and "yes" or "no"
            print("  " .. unitToken .. " (" .. name .. ") -> " .. frameName .. " [registered: " .. registered .. "]")
        end
        if count == 0 then
            print("  (none)")
        end
        print("Total: " .. count)
        
        -- Also show all visible nameplates according to WoW
        local allPlates = C_NamePlate.GetNamePlates()
        print("|cff33cc66WoW visible nameplates:|r " .. #allPlates)
        for i, plate in ipairs(allPlates) do
            local unitToken = plate.namePlateUnitToken
            local name = unitToken and UnitName(unitToken) or "Unknown"
            local isRegistered = CC.registeredNameplates[unitToken] and "yes" or "no"
            print("  " .. (unitToken or "?") .. " (" .. name .. ") registered: " .. isRegistered)
        end
    elseif msg == "bindings" then
        -- Show all active bindings on the current hovered frame
        local frames = GetMouseFoci and GetMouseFoci() or {}
        local frame = frames[1]
        if frame then
            local frameName = frame:GetName() or "unnamed"
            print("|cff33cc66Bindings for " .. frameName .. ":|r")
            
            -- Check if registered
            if not CC.registeredFrames or not CC.registeredFrames[frame] then
                print("  Frame is NOT registered for click-casting!")
                print("  Trying to find registered parent...")
                local parent = frame:GetParent()
                local depth = 0
                while parent and depth < 5 do
                    if CC.registeredFrames and CC.registeredFrames[parent] then
                        print("  Found registered parent: " .. (parent:GetName() or "unnamed"))
                        frame = parent
                        break
                    end
                    parent = parent:GetParent()
                    depth = depth + 1
                end
            end
            
            -- Show what bindings SHOULD be on this frame
            local scopesApplicable = {}
            if frame.dfClickCastRegistered then
                scopesApplicable.unitframes = true
                scopesApplicable.blizzard = frame.dfIsBlizzardFrame
            end
            
            print("  Applicable scopes:")
            for scope, active in pairs(scopesApplicable) do
                print("    " .. scope .. ": " .. tostring(active))
            end
            
            -- List enabled bindings
            print("  Enabled bindings:")
            for i, binding in ipairs(CC.db.bindings) do
                if binding.enabled ~= false then
                    local scope = binding.scope or "blizzard"
                    local bindType = binding.bindType or "mouse"
                    local spellName = binding.spellName or binding.macroName or binding.actionType or "?"
                    local keyText = CC:GetBindingKeyText(binding)
                    print("    [" .. scope .. "] " .. keyText .. " -> " .. spellName)
                end
            end
            
            -- Show frame attributes
            print("  Frame attributes:")
            for i = 1, 5 do
                local typeAttr = frame:GetAttribute("type" .. i)
                local spellAttr = frame:GetAttribute("spell" .. i)
                local macroAttr = frame:GetAttribute("macrotext" .. i)
                if typeAttr or spellAttr or macroAttr then
                    print("    type" .. i .. "=" .. tostring(typeAttr) .. " spell" .. i .. "=" .. tostring(spellAttr))
                end
            end
        else
            print("|cffff6666No frame under mouse|r")
        end
    elseif msg == "register" then
        -- Try to register the frame under mouse
        local frames = GetMouseFoci and GetMouseFoci() or {}
        local frame = frames[1]
        if frame then
            local frameName = frame:GetName() or "unnamed"
            print("|cff33cc66Trying to register " .. frameName .. "...|r")
            
            if InCombatLockdown() then
                print("  Cannot register during combat!")
            else
                CC:RegisterFrame(frame)
                print("  Registration attempted. Check /dfccglobal inspect to verify.")
            end
        else
            print("|cffff6666No frame under mouse|r")
        end
    elseif msg == "onhover" then
        -- Show onhover button status
        print("|cff33cc66On Hover Button Status:|r")
        if CC.hovercastButton then
            print("  Button exists: yes")
            print("  Button name: " .. (CC.hovercastButton:GetName() or "nil"))
            print("  Button shown: " .. tostring(CC.hovercastButton:IsShown()))
            
            -- Show some attributes
            local attrs = {"type1", "spell1", "unit1", "typeshiftf", "spellshiftf", "unitshiftf"}
            print("  Sample attributes:")
            for _, attr in ipairs(attrs) do
                local val = CC.hovercastButton:GetAttribute(attr)
                if val then
                    print("    " .. attr .. " = " .. tostring(val))
                end
            end
            
            -- Show the setup script
            if CC.hovercastButton.clearScript then
                print("  Clear script exists: yes")
            else
                print("  Clear script exists: no")
            end
            
            -- List onhover/targetcast bindings
            print("  On Hover / Target Cast bindings configured:")
            local count = 0
            for i, binding in ipairs(CC.db.bindings) do
                if binding.enabled ~= false then
                    local scope = binding.scope or "blizzard"
                    if scope == "onhover" or scope == "targetcast" then
                        count = count + 1
                        local keyText = CC:GetBindingKeyText(binding)
                        local spellName = binding.spellName or binding.macroName or binding.actionType or "?"
                        print("    " .. keyText .. " -> " .. spellName .. " [" .. scope .. "]")
                    end
                end
            end
            if count == 0 then
                print("    (none configured)")
            end
        else
            print("  Button exists: NO - this is the problem!")
            print("  Try: /dfccglobal apply")
        end
    elseif msg == "smartres" then
        -- Debug smart resurrection settings
        print("|cff33cc66Smart Resurrection Debug:|r")
        local mode = CC.profile and CC.profile.options and CC.profile.options.smartResurrection or "disabled"
        print("  Current mode: " .. mode)
        
        local resSpells = CC:GetPlayerResurrectionSpells()
        if resSpells then
            print("  Available spells:")
            print("    Normal: " .. (resSpells.normal or "none"))
            print("    Mass: " .. (resSpells.mass or "none"))
            print("    Combat: " .. (resSpells.combat or "none"))
        else
            print("  No resurrection spells available for your class")
        end
        
        -- Show what a sample macro would look like
        local sampleParts = CC:GetSmartResurrectionParts("Regrowth", "friendly")
        if sampleParts then
            print("  Sample macro parts for Regrowth (friendly):")
            for _, part in ipairs(sampleParts) do
                print("    " .. part)
            end
        else
            print("  Smart res would NOT be added to spells (mode disabled or no spells)")
        end
    else
        print("|cff33cc66/dfccglobal commands:|r")
        print("  debug - Toggle debug output")
        print("  apply - Reapply all bindings")
        print("  list - Show binding counts and status")
        print("  inspect - Inspect frame under mouse cursor")
        print("  mouseover - Check what WoW sees as mouseover unit")
        print("  nameplates - Show all registered nameplates")
        print("  bindings - Show bindings for frame under cursor")
        print("  register - Try to register frame under cursor")
        print("  onhover - Show on hover button status")
        print("  smartres - Debug smart resurrection")
    end
end
