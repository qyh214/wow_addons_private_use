local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast
local L = DF.L
local format = string.format

-- HOOKS INTO DANDERSFRAMES
-- ============================================================

-- Hook frame creation to auto-register new frames
local originalCreateUnitFrame = DF.CreateUnitFrame
if originalCreateUnitFrame then
    DF.CreateUnitFrame = function(self, ...)
        local frame = originalCreateUnitFrame(self, ...)
        if frame and CC.db and CC.db.enabled then
            CC:RegisterFrame(frame)
        end
        return frame
    end
end

-- ============================================================
-- INITIALIZATION HOOK
-- ============================================================

-- ============================================================

-- NEW CLICK CASTING UI (Spell Grid with instant binding)
-- ============================================================

-- Shared tables for UI elements (accessible from other files)
CC.spellCells = CC.spellCells or {}
CC.bindingRows = CC.bindingRows or {}
local spellCells = CC.spellCells
local bindingRows = CC.bindingRows
local clickCastUIFrame = nil

-- Constants for Active Bindings section (shared with BindingEditor.lua)
CC.BINDING_ROW_HEIGHT = 48  -- Taller for two-line display with wrapping
CC.LEFT_PANEL_WIDTH = 300   -- Width of expanded bindings panel
CC.LEFT_PANEL_COLLAPSED_WIDTH = 85  -- Width when collapsed (wider for scrollbar)

local BINDING_ROW_HEIGHT = CC.BINDING_ROW_HEIGHT
local LEFT_PANEL_WIDTH = CC.LEFT_PANEL_WIDTH
local LEFT_PANEL_COLLAPSED_WIDTH = CC.LEFT_PANEL_COLLAPSED_WIDTH

-- Local alias for helper functions (defined in Bindings.lua)
local function GetSpellDisplayInfo(a, b) 
    if CC.GetSpellDisplayInfo then 
        return CC.GetSpellDisplayInfo(a, b) 
    else
        -- Fallback if function not available
        local name = b or (a and C_Spell.GetSpellName and C_Spell.GetSpellName(a)) or "Unknown"
        local icon = a and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(a) or 134400
        return name, icon, a
    end
end

-- Helper function to convert fallback settings to human-readable text
local function GetFallbackDisplayText(fallback)
    if not fallback then return nil end
    
    local parts = {}
    if fallback.mouseover then table.insert(parts, "Mouseover") end
    if fallback.target then table.insert(parts, "Target") end
    if fallback.selfCast then table.insert(parts, "Self") end
    
    if #parts == 0 then return nil end
    return table.concat(parts, " then ")
end

-- Export to CC namespace for use in other UI files
CC.GetFallbackDisplayText = GetFallbackDisplayText

function CC:CreateClickCastUI(parent)
    if clickCastUIFrame then return end
    clickCastUIFrame = parent
    CC.clickCastUIFrame = parent
    
    local themeColor = {r = 0.2, g = 0.8, b = 0.4}
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08}
    local C_PANEL = {r = 0.12, g = 0.12, b = 0.12}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    local C_TEXT = {r = 0.9, g = 0.9, b = 0.9}
    local C_TEXT_DIM = {r = 0.6, g = 0.6, b = 0.6}
    local C_COMBAT = {r = 1.0, g = 0.3, b = 0.3}
    local C_NOCOMBAT = {r = 0.3, g = 1.0, b = 0.3}
    
    -- Store colors for later use
    CC.UI_COLORS = {
        theme = themeColor,
        background = C_BACKGROUND,
        panel = C_PANEL,
        element = C_ELEMENT,
        border = C_BORDER,
        text = C_TEXT,
        textDim = C_TEXT_DIM,
        combat = C_COMBAT,
        nocombat = C_NOCOMBAT,
    }
    
    -- =========================================================================
    -- HEADER: Two rows for better organization
    -- =========================================================================
    local header = CreateFrame("Frame", nil, parent)
    header:SetPoint("TOPLEFT", 10, -8)
    header:SetPoint("TOPRIGHT", -10, -8)
    header:SetHeight(48)  -- Two rows
    CC.header = header
    
    -- === ROW 1: Title + Enable + Profile Dropdown ===
    local row1 = CreateFrame("Frame", nil, header)
    row1:SetPoint("TOPLEFT", 0, 0)
    row1:SetPoint("TOPRIGHT", 0, 0)
    row1:SetHeight(22)
    
    -- Title
    local title = row1:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("LEFT", 0, 0)
    title:SetText(L["Click-Casting"])
    title:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    
    -- Enable checkbox (next to title)
    local enableCb = CreateFrame("CheckButton", nil, row1, "BackdropTemplate")
    enableCb:SetPoint("LEFT", title, "RIGHT", 15, 0)
    enableCb:SetSize(14, 14)
    enableCb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    enableCb:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    enableCb:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local enableCheck = enableCb:CreateTexture(nil, "OVERLAY")
    enableCheck:SetTexture("Interface\\Buttons\\WHITE8x8")
    enableCheck:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
    enableCheck:SetPoint("CENTER")
    enableCheck:SetSize(8, 8)
    enableCb:SetCheckedTexture(enableCheck)
    
    local enableLabel = row1:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    enableLabel:SetPoint("LEFT", enableCb, "RIGHT", 3, 0)
    enableLabel:SetText(L["Enabled"])
    enableLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    enableCb:SetScript("OnClick", function(self)
        local wantEnabled = self:GetChecked()
        
        if wantEnabled then
            -- Check for conflicting addons
            local conflicts = {}
            if C_AddOns and C_AddOns.IsAddOnLoaded then
                if C_AddOns.IsAddOnLoaded("Clique") then
                    table.insert(conflicts, "Clique")
                end
                if C_AddOns.IsAddOnLoaded("Clicked") then
                    table.insert(conflicts, "Clicked")
                end
            elseif IsAddOnLoaded then
                if IsAddOnLoaded("Clique") then
                    table.insert(conflicts, "Clique")
                end
                if IsAddOnLoaded("Clicked") then
                    table.insert(conflicts, "Clicked")
                end
            end
            
            if #conflicts > 0 then
                -- Show conflict popup
                CC:ShowClickCastConflictPopup(conflicts, self)
                return
            end
            
            -- No addon conflicts - show Blizzard warning
            CC:ShowBlizzardClickCastWarning(self, function()
                -- Proceed with enabling
                CC.db.enabled = true
                CC:SetEnabled(true)
            end)
            return
        end
        
        -- Disabling - proceed normally
        CC.db.enabled = false
        CC:SetEnabled(false)
    end)
    
    -- Profile settings cogwheel (far right of row 1)
    local profileCogwheel = CreateFrame("Button", nil, row1, "BackdropTemplate")
    profileCogwheel:SetPoint("RIGHT", 0, 0)
    profileCogwheel:SetSize(18, 18)
    profileCogwheel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    profileCogwheel:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    profileCogwheel:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local cogwheelIcon = profileCogwheel:CreateTexture(nil, "OVERLAY")
    cogwheelIcon:SetPoint("CENTER", 0, 0)
    cogwheelIcon:SetSize(14, 14)
    cogwheelIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\settings")
    cogwheelIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    profileCogwheel:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        cogwheelIcon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["Profile Settings"], 1, 1, 1)
        GameTooltip:AddLine(L["Open the Profiles tab to manage profiles"], 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    profileCogwheel:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        cogwheelIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        GameTooltip:Hide()
    end)
    profileCogwheel:SetScript("OnClick", function()
        if CC.SetActiveTab then
            CC.SetActiveTab("profiles")
        end
    end)
    
    -- Profile dropdown (to the left of cogwheel)
    local profileDropdown = CreateFrame("Frame", nil, row1, "BackdropTemplate")
    profileDropdown:SetPoint("RIGHT", profileCogwheel, "LEFT", -4, 0)
    profileDropdown:SetSize(140, 18)
    profileDropdown:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    profileDropdown:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    profileDropdown:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
    
    local profileDropText = profileDropdown:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    profileDropText:SetPoint("LEFT", 6, 0)
    profileDropText:SetPoint("RIGHT", -16, 0)
    profileDropText:SetJustifyH("LEFT")
    profileDropText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    profileDropText:SetWordWrap(false)
    
    local profileDropArrow = profileDropdown:CreateTexture(nil, "OVERLAY")
    profileDropArrow:SetPoint("RIGHT", -4, 0)
    profileDropArrow:SetSize(12, 12)
    profileDropArrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    profileDropArrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local profileLabel = row1:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    profileLabel:SetPoint("RIGHT", profileDropdown, "LEFT", -4, 0)
    profileLabel:SetText(L["Profile:"])
    profileLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local profileMenu = CreateFrame("Frame", nil, profileDropdown, "BackdropTemplate")
    profileMenu:SetPoint("TOPRIGHT", profileDropdown, "BOTTOMRIGHT", 0, -2)
    profileMenu:SetWidth(180)
    profileMenu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    profileMenu:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
    profileMenu:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    profileMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    profileMenu:SetFrameLevel(200)
    profileMenu:Hide()
    
    -- Helper to truncate text
    local function TruncateText(text, maxLen)
        if not text then return "" end
        if #text <= maxLen then return text end
        return string.sub(text, 1, maxLen - 2) .. ".."
    end
    
    local function UpdateProfileDropdown()
        local activeProfile = CC:GetActiveProfileName()
        profileDropText:SetText(TruncateText(activeProfile, 20))
    end
    
    local function ShowProfileMenu()
        for _, child in ipairs({profileMenu:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
        
        local profiles = CC:GetProfileList()
        local activeProfile = CC:GetActiveProfileName()
        local yOff = -4
        
        for _, profileName in ipairs(profiles) do
            local item = CreateFrame("Button", nil, profileMenu)
            item:SetPoint("TOPLEFT", 4, yOff)
            item:SetPoint("RIGHT", -4, 0)
            item:SetHeight(18)
            
            local itemText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            itemText:SetPoint("LEFT", 4, 0)
            itemText:SetText(profileName)
            
            if profileName == activeProfile then
                itemText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            else
                itemText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end
            
            item:SetScript("OnEnter", function()
                itemText:SetTextColor(1, 1, 1)
            end)
            item:SetScript("OnLeave", function()
                if profileName == activeProfile then
                    itemText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
                else
                    itemText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                end
            end)
            item:SetScript("OnClick", function()
                if not InCombatLockdown() and profileName ~= activeProfile then
                    if CC:SetActiveProfile(profileName) then
                        CC:ApplyBindings()
                        CC:RefreshClickCastingUI()
                        UpdateProfileDropdown()
                    end
                elseif InCombatLockdown() then
                    print("|cffff9900DandersFrames:|r Cannot switch profiles during combat")
                end
                profileMenu:Hide()
            end)
            
            yOff = yOff - 18
        end
        
        profileMenu:SetHeight(-yOff + 4)
        profileMenu:Show()
    end
    
    profileDropdown:SetScript("OnMouseDown", function()
        if profileMenu:IsShown() then
            profileMenu:Hide()
        else
            ShowProfileMenu()
        end
    end)
    
    profileDropdown:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    end)
    profileDropdown:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
    end)
    
    profileMenu:SetScript("OnLeave", function(self)
        C_Timer.After(0.1, function()
            if not profileDropdown:IsMouseOver() and not profileMenu:IsMouseOver() then
                profileMenu:Hide()
            end
        end)
    end)
    
    CC.profileDropdown = profileDropdown
    CC.profileDropText = profileDropText
    CC.UpdateProfileDropdown = UpdateProfileDropdown
    
    -- === ROW 2: Options (Cast on DOWN, Quick Bind, Smart Res, Search) ===
    local row2 = CreateFrame("Frame", nil, header)
    row2:SetPoint("TOPLEFT", 0, -24)
    row2:SetPoint("TOPRIGHT", 0, -24)
    row2:SetHeight(22)
    
    -- Cast on down checkbox
    local downCb = CreateFrame("CheckButton", nil, row2, "BackdropTemplate")
    downCb:SetPoint("LEFT", 0, 0)
    downCb:SetSize(14, 14)
    downCb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    downCb:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    downCb:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local downCheck = downCb:CreateTexture(nil, "OVERLAY")
    downCheck:SetTexture("Interface\\Buttons\\WHITE8x8")
    downCheck:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
    downCheck:SetPoint("CENTER")
    downCheck:SetSize(8, 8)
    downCb:SetCheckedTexture(downCheck)
    
    local downLabel = row2:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    downLabel:SetPoint("LEFT", downCb, "RIGHT", 3, 0)
    downLabel:SetText(L["Cast on DOWN"])
    downLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    downCb:SetScript("OnClick", function(self)
        CC.db.options.castOnDown = self:GetChecked()
        CC:ApplyBindings()
    end)
    
    -- Quick Bind toggle
    local quickBindCb = CreateFrame("CheckButton", nil, row2, "BackdropTemplate")
    quickBindCb:SetPoint("LEFT", downLabel, "RIGHT", 15, 0)
    quickBindCb:SetSize(14, 14)
    quickBindCb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    quickBindCb:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    quickBindCb:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local quickBindCheck = quickBindCb:CreateTexture(nil, "OVERLAY")
    quickBindCheck:SetTexture("Interface\\Buttons\\WHITE8x8")
    quickBindCheck:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
    quickBindCheck:SetPoint("CENTER")
    quickBindCheck:SetSize(8, 8)
    quickBindCb:SetCheckedTexture(quickBindCheck)
    
    local quickBindLabel = row2:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    quickBindLabel:SetPoint("LEFT", quickBindCb, "RIGHT", 3, 0)
    quickBindLabel:SetText(L["Quick Bind"])
    quickBindLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    quickBindCb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["Quick Bind Mode"], 1, 1, 1)
        GameTooltip:AddLine(L["When enabled: Click spell, press key to bind instantly."], 0.7, 0.7, 0.7)
        GameTooltip:AddLine(L["When disabled: Click spell to open Binding Editor."], 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    quickBindCb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    quickBindCb:SetScript("OnClick", function(self)
        CC.db.options.quickBindEnabled = self:GetChecked()
    end)

    -- Smart Resurrection dropdown
    local smartResLabel = row2:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    smartResLabel:SetPoint("LEFT", quickBindLabel, "RIGHT", 15, 0)
    smartResLabel:SetText(L["Smart Res:"])
    smartResLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    local smartResDropdown = CreateFrame("Frame", nil, row2, "BackdropTemplate")
    smartResDropdown:SetPoint("LEFT", smartResLabel, "RIGHT", 4, 0)
    smartResDropdown:SetSize(110, 16)
    smartResDropdown:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    smartResDropdown:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    smartResDropdown:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local smartResText = smartResDropdown:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    smartResText:SetPoint("LEFT", 6, 0)
    smartResText:SetPoint("RIGHT", -14, 0)
    smartResText:SetJustifyH("LEFT")
    smartResText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    smartResText:SetWordWrap(false)
    
    local smartResArrow = smartResDropdown:CreateTexture(nil, "OVERLAY")
    smartResArrow:SetPoint("RIGHT", -4, 0)
    smartResArrow:SetSize(12, 12)
    smartResArrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    smartResArrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local smartResOptions = {
        { value = "disabled", text = L["Disabled"] },
        { value = "normal", text = L["Res + Mass"] },
        { value = "normal+combat", text = L["Res + Mass + Combat"] },
    }
    
    local function UpdateSmartResText()
        local current = CC.profile and CC.profile.options and CC.profile.options.smartResurrection or "disabled"
        for _, opt in ipairs(smartResOptions) do
            if opt.value == current then
                smartResText:SetText(opt.text)
                return
            end
        end
        smartResText:SetText(L["Disabled"])
    end
    
    local smartResMenu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    smartResMenu:SetSize(130, #smartResOptions * 20 + 4)
    smartResMenu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    smartResMenu:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
    smartResMenu:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    smartResMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    smartResMenu:SetFrameLevel(100)
    smartResMenu:SetClampedToScreen(true)
    smartResMenu:Hide()
    
    for i, opt in ipairs(smartResOptions) do
        local optBtn = CreateFrame("Button", nil, smartResMenu)
        optBtn:SetPoint("TOPLEFT", 2, -2 - (i-1) * 20)
        optBtn:SetSize(126, 20)
        
        local optText = optBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        optText:SetPoint("LEFT", 4, 0)
        optText:SetText(opt.text)
        optText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        
        optBtn:SetScript("OnEnter", function()
            optText:SetTextColor(1, 1, 1)
        end)
        optBtn:SetScript("OnLeave", function()
            optText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        end)
        optBtn:SetScript("OnClick", function()
            if CC.profile and CC.profile.options then
                CC.profile.options.smartResurrection = opt.value
            end
            UpdateSmartResText()
            smartResMenu:Hide()
            CC:ApplyBindings()
        end)
    end
    
    smartResDropdown:SetScript("OnMouseDown", function()
        if smartResMenu:IsShown() then
            smartResMenu:Hide()
            if smartResMenu.closeFrame then
                smartResMenu.closeFrame:Hide()
            end
        else
            UpdateSmartResText()
            -- Position menu below the dropdown
            smartResMenu:ClearAllPoints()
            smartResMenu:SetPoint("TOPLEFT", smartResDropdown, "BOTTOMLEFT", 0, -2)
            smartResMenu:Show()
            smartResMenu:Raise()
            
            -- Close on any click outside
            if not smartResMenu.closeFrame then
                smartResMenu.closeFrame = CreateFrame("Button", nil, UIParent)
                smartResMenu.closeFrame:SetFrameStrata("FULLSCREEN")
                smartResMenu.closeFrame:SetScript("OnClick", function()
                    smartResMenu:Hide()
                    smartResMenu.closeFrame:Hide()
                end)
            end
            smartResMenu.closeFrame:SetAllPoints(UIParent)
            smartResMenu.closeFrame:Show()
        end
    end)
    
    smartResMenu:SetScript("OnHide", function()
        if smartResMenu.closeFrame then
            smartResMenu.closeFrame:Hide()
        end
    end)
    
    smartResDropdown:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["Smart Resurrection"], 1, 1, 1)
        GameTooltip:AddLine("When using any spell binding on a dead target,", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("cast a resurrection spell instead.", 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Disabled"] .. ":", themeColor.r, themeColor.g, themeColor.b)
        GameTooltip:AddLine(L["Bindings only cast their assigned spell"], 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Res + Mass"] .. ":", themeColor.r, themeColor.g, themeColor.b)
        GameTooltip:AddLine(L["Dead + Out of combat: Cast Mass Res or normal Res"], 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Res + Mass + Combat"] .. ":", themeColor.r, themeColor.g, themeColor.b)
        GameTooltip:AddLine(L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"], 0.7, 0.7, 0.7)
        GameTooltip:AddLine(L["Dead + Out of combat: Cast Mass Res or normal Res"], 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    smartResDropdown:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        GameTooltip:Hide()
    end)
    
    smartResMenu:SetScript("OnLeave", function()
        C_Timer.After(0.1, function()
            if not smartResDropdown:IsMouseOver() and not smartResMenu:IsMouseOver() then
                smartResMenu:Hide()
            end
        end)
    end)
    
    CC.smartResDropdown = smartResDropdown
    CC.smartResMenu = smartResMenu
    CC.UpdateSmartResText = UpdateSmartResText
    
    -- Search box (right side of row 2)
    local searchBox = CreateFrame("EditBox", nil, row2, "BackdropTemplate")
    searchBox:SetPoint("RIGHT", 0, 0)
    searchBox:SetSize(120, 16)
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    searchBox:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    searchBox:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    DF.GUI:SetSettingsFont(searchBox, 10, "")
    searchBox:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    searchBox:SetTextInsets(18, 6, 0, 0)
    searchBox:SetAutoFocus(false)
    
    local searchIcon = searchBox:CreateTexture(nil, "OVERLAY")
    searchIcon:SetPoint("LEFT", 4, 0)
    searchIcon:SetSize(10, 10)
    searchIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\search")
    searchIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    searchPlaceholder:SetPoint("LEFT", 18, 0)
    searchPlaceholder:SetText(L["Search..."])
    searchPlaceholder:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    searchBox:SetScript("OnEditFocusGained", function() searchPlaceholder:Hide() end)
    searchBox:SetScript("OnEditFocusLost", function() 
        if searchBox:GetText() == "" then searchPlaceholder:Show() end 
    end)
    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text == "" then searchPlaceholder:Show() else searchPlaceholder:Hide() end
        CC:RefreshSpellGrid()
    end)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    CC.searchBox = searchBox
    CC.enableCb = enableCb
    CC.downCb = downCb
    CC.quickBindCb = quickBindCb
    
    -- =========================================================================
    -- MAIN CONTENT: Side-by-side layout
    -- =========================================================================
    local mainContent = CreateFrame("Frame", nil, parent)
    mainContent:SetPoint("TOPLEFT", 10, -60)
    mainContent:SetPoint("BOTTOMRIGHT", -10, 10)
    CC.mainContent = mainContent
    
    -- =========================================================================
    -- LEFT PANEL: Active Bindings (collapsible)
    -- =========================================================================
    local leftPanel = CreateFrame("Frame", nil, mainContent, "BackdropTemplate")
    leftPanel:SetPoint("TOPLEFT", 0, 0)
    leftPanel:SetPoint("BOTTOMLEFT", 0, 0)
    leftPanel:SetWidth(LEFT_PANEL_WIDTH)
    leftPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    leftPanel:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.95)
    leftPanel:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.8)
    CC.leftPanel = leftPanel
    CC.bindingsSection = leftPanel  -- Alias for compatibility
    
    -- Panel header
    local bindingsHeader = CreateFrame("Frame", nil, leftPanel)
    bindingsHeader:SetPoint("TOPLEFT", 0, 0)
    bindingsHeader:SetPoint("TOPRIGHT", 0, 0)
    bindingsHeader:SetHeight(28)
    
    -- Collapse/Expand button (left side of header)
    local collapseBtn = CreateFrame("Button", nil, bindingsHeader, "BackdropTemplate")
    collapseBtn:SetPoint("LEFT", 4, 0)
    collapseBtn:SetSize(20, 20)
    collapseBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    collapseBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    collapseBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local collapseIcon = collapseBtn:CreateTexture(nil, "OVERLAY")
    collapseIcon:SetPoint("CENTER")
    collapseIcon:SetSize(12, 12)
    collapseIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
    collapseIcon:SetTexCoord(1, 0, 0, 1)  -- Flip horizontally to point left (expanded state)
    collapseIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    collapseBtn.icon = collapseIcon
    
    collapseBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
        self.icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
    end)
    collapseBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        self.icon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    end)
    
    CC.collapseBtn = collapseBtn
    CC.collapseIcon = collapseIcon
    CC.leftPanelCollapsed = false
    
    -- Title
    local bindingsTitle = bindingsHeader:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    bindingsTitle:SetPoint("LEFT", collapseBtn, "RIGHT", 6, 0)
    bindingsTitle:SetText(L["Active Bindings"])
    bindingsTitle:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    CC.bindingsTitle = bindingsTitle
    
    -- Hint text
    local bindingsHint = bindingsHeader:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    bindingsHint:SetPoint("LEFT", bindingsTitle, "RIGHT", 6, 0)
    bindingsHint:SetText(L["— click to edit"])
    bindingsHint:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    CC.bindingsHint = bindingsHint
    
    -- Clear All button
    local clearAllBtn = CreateFrame("Button", nil, bindingsHeader, "BackdropTemplate")
    clearAllBtn:SetPoint("RIGHT", -6, 0)
    clearAllBtn:SetSize(65, 18)
    clearAllBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    clearAllBtn:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
    clearAllBtn:SetBackdropBorderColor(0.5, 0.2, 0.2, 0.8)
    
    local clearAllIcon = clearAllBtn:CreateTexture(nil, "OVERLAY")
    clearAllIcon:SetPoint("LEFT", 6, 0)
    clearAllIcon:SetSize(10, 10)
    clearAllIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\delete")
    clearAllIcon:SetVertexColor(0.9, 0.6, 0.6)
    local clearAllText = clearAllBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    clearAllText:SetPoint("LEFT", clearAllIcon, "RIGHT", 3, 0)
    clearAllText:SetText(L["Clear"])
    clearAllText:SetTextColor(0.9, 0.6, 0.6)
    
    clearAllBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.4, 0.15, 0.15, 1)
        self:SetBackdropBorderColor(0.7, 0.3, 0.3, 1)
        clearAllText:SetTextColor(1, 0.7, 0.7)
        clearAllIcon:SetVertexColor(1, 0.7, 0.7)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["Clear All Bindings"], 1, 0.3, 0.3)
        GameTooltip:AddLine(L["Remove all bindings from the current profile."], 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    clearAllBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
        self:SetBackdropBorderColor(0.5, 0.2, 0.2, 0.8)
        clearAllText:SetTextColor(0.9, 0.6, 0.6)
        clearAllIcon:SetVertexColor(0.9, 0.6, 0.6)
        GameTooltip:Hide()
    end)
    clearAllBtn:SetScript("OnClick", function()
        CC:ShowClearAllConfirmation()
    end)
    CC.clearAllBtn = clearAllBtn
    
    -- Bindings scroll frame (full height)
    local bindingsScroll = CreateFrame("ScrollFrame", nil, leftPanel, "ScrollFrameTemplate")
    bindingsScroll:SetPoint("TOPLEFT", 5, -30)
    bindingsScroll:SetPoint("BOTTOMRIGHT", -25, 5)
    
    DF.GUI.StyleScrollBar(bindingsScroll)

    local bindingsContent = CreateFrame("Frame", nil, bindingsScroll)
    bindingsContent:SetWidth(LEFT_PANEL_WIDTH - 35)
    bindingsContent:SetHeight(1)
    bindingsScroll:SetScrollChild(bindingsContent)
    
    CC.bindingsScroll = bindingsScroll
    CC.bindingsContent = bindingsContent
    
    -- Mouse wheel scrolling for bindings
    bindingsScroll:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = self:GetVerticalScrollRange()
        if maxScroll <= 0 then return end
        local currentScroll = self:GetVerticalScroll()
        local scrollStep = BINDING_ROW_HEIGHT
        local newScroll = currentScroll - (delta * scrollStep)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        self:SetVerticalScroll(newScroll)
    end)
    
    leftPanel:EnableMouseWheel(true)
    leftPanel:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = bindingsScroll:GetVerticalScrollRange()
        if maxScroll <= 0 then return end
        local currentScroll = bindingsScroll:GetVerticalScroll()
        local scrollStep = BINDING_ROW_HEIGHT
        local newScroll = currentScroll - (delta * scrollStep)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        bindingsScroll:SetVerticalScroll(newScroll)
    end)
    
    -- Collapse/Expand functionality
    local function ToggleLeftPanel()
        CC.leftPanelCollapsed = not CC.leftPanelCollapsed
        
        if CC.leftPanelCollapsed then
            -- Collapse
            leftPanel:SetWidth(LEFT_PANEL_COLLAPSED_WIDTH)
            collapseIcon:SetTexCoord(0, 1, 0, 1)  -- Point right (expand direction)
            bindingsTitle:Hide()
            bindingsHint:Hide()
            clearAllBtn:Hide()
            bindingsContent:SetWidth(LEFT_PANEL_COLLAPSED_WIDTH - 20)  -- Narrower for icons only
            -- Adjust scroll frame to use less padding when collapsed
            bindingsScroll:SetPoint("TOPLEFT", 3, -30)
            bindingsScroll:SetPoint("BOTTOMRIGHT", -18, 5)
            -- Update binding rows to collapsed mode
            CC:RefreshActiveBindings()
        else
            -- Expand
            leftPanel:SetWidth(LEFT_PANEL_WIDTH)
            collapseIcon:SetTexCoord(1, 0, 0, 1)  -- Point left (collapse direction)
            bindingsTitle:Show()
            bindingsHint:Show()
            clearAllBtn:Show()
            bindingsContent:SetWidth(LEFT_PANEL_WIDTH - 35)
            -- Restore scroll frame padding
            bindingsScroll:SetPoint("TOPLEFT", 5, -30)
            bindingsScroll:SetPoint("BOTTOMRIGHT", -25, 5)
            -- Update binding rows to expanded mode
            CC:RefreshActiveBindings()
        end
    end
    
    collapseBtn:SetScript("OnClick", ToggleLeftPanel)
    CC.ToggleLeftPanel = ToggleLeftPanel
    
    -- Store expand button references for compatibility
    CC.bindingsExpanded = true  -- Now means "not collapsed"
    CC.expandBtn = collapseBtn
    CC.expandIcon = collapseIcon
    
    -- =========================================================================
    -- RIGHT PANEL: Selection Section (Tabs + Spell Grid)
    -- =========================================================================
    local rightPanel = CreateFrame("Frame", nil, mainContent)
    rightPanel:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", 5, 0)
    rightPanel:SetPoint("BOTTOMRIGHT", 0, 0)
    CC.rightPanel = rightPanel
    CC.selectionSection = rightPanel  -- Alias for compatibility
    local selectionSection = rightPanel  -- Local alias for use below
    
    -- Selection header - TWO ROWS: tabs row + filter row
    local selectionHeader = CreateFrame("Frame", nil, rightPanel, "BackdropTemplate")
    selectionHeader:SetPoint("TOPLEFT", 0, 0)
    selectionHeader:SetPoint("TOPRIGHT", 0, 0)
    selectionHeader:SetHeight(60)  -- Two rows: 28 + 28 + spacing
    selectionHeader:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    selectionHeader:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
    selectionHeader:SetFrameLevel(rightPanel:GetFrameLevel() + 1)
    CC.selectionHeader = selectionHeader
    
    -- ROW 1: Tabs
    local tabsRow = CreateFrame("Frame", nil, selectionHeader)
    tabsRow:SetPoint("TOPLEFT", 0, 0)
    tabsRow:SetPoint("TOPRIGHT", 0, 0)
    tabsRow:SetHeight(28)
    
    -- ROW 2: Filters and view controls
    local filterRow = CreateFrame("Frame", nil, selectionHeader)
    filterRow:SetPoint("TOPLEFT", 0, -30)
    filterRow:SetPoint("TOPRIGHT", 0, -30)
    filterRow:SetHeight(26)
    CC.filterRow = filterRow
    
    -- Helper to create a tab button
    local function CreateTabButton(parent, text, width)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(width, 24)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        btn.text = btnText
        
        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(C_ELEMENT.r + 0.05, C_ELEMENT.g + 0.05, C_ELEMENT.b + 0.05, 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self.isActive then
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            end
        end)
        
        function btn:SetActive(active)
            self.isActive = active
            if active then
                self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
                self.text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            else
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
                self.text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            end
        end
        
        return btn
    end
    
    -- Helper to create a dropdown button
    local function CreateDropdown(parent, defaultText, width, options, onSelect)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(width, 22)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btnText:SetPoint("LEFT", 6, 0)
        btnText:SetPoint("RIGHT", -16, 0)
        btnText:SetJustifyH("LEFT")
        btnText:SetText(defaultText)
        btnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        btn.text = btnText
        
        local arrow = btn:CreateTexture(nil, "OVERLAY")
        arrow:SetPoint("RIGHT", -4, 0)
        arrow:SetSize(12, 12)
        arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
        arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C_ELEMENT.r + 0.05, C_ELEMENT.g + 0.05, C_ELEMENT.b + 0.05, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        end)
        
        -- Create dropdown menu (parented to UIParent for proper z-ordering)
        local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        menu:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        menu:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
        menu:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetFrameLevel(100)
        menu:SetWidth(width)
        menu:SetClampedToScreen(true)
        menu:Hide()
        btn.menu = menu
        
        local menuHeight = 4
        for i, opt in ipairs(options) do
            local item = CreateFrame("Button", nil, menu)
            item:SetHeight(20)
            item:SetPoint("TOPLEFT", 2, -(2 + (i-1) * 20))
            item:SetPoint("TOPRIGHT", -2, -(2 + (i-1) * 20))
            
            local itemText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            itemText:SetPoint("LEFT", 4, 0)
            itemText:SetText(opt.label)
            itemText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            
            item:SetScript("OnEnter", function(self)
                itemText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            end)
            item:SetScript("OnLeave", function(self)
                itemText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end)
            item:SetScript("OnClick", function()
                btnText:SetText(opt.label)
                menu:Hide()
                if onSelect then onSelect(opt.key) end
            end)
            
            menuHeight = menuHeight + 20
        end
        menu:SetHeight(menuHeight)
        
        btn:SetScript("OnClick", function()
            if menu:IsShown() then
                menu:Hide()
                if menu.closeFrame then
                    menu.closeFrame:Hide()
                end
            else
                -- Position menu below the button
                menu:ClearAllPoints()
                menu:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
                menu:Show()
                menu:Raise()
                
                -- Close on any click outside
                if not menu.closeFrame then
                    menu.closeFrame = CreateFrame("Button", nil, UIParent)
                    menu.closeFrame:SetFrameStrata("FULLSCREEN")
                    menu.closeFrame:SetScript("OnClick", function()
                        menu:Hide()
                        menu.closeFrame:Hide()
                    end)
                end
                menu.closeFrame:SetAllPoints(UIParent)
                menu.closeFrame:Show()
            end
        end)
        
        -- Close menu when it hides
        menu:SetScript("OnHide", function()
            if menu.closeFrame then
                menu.closeFrame:Hide()
            end
        end)
        
        btn.SetValue = function(self, key)
            for _, opt in ipairs(options) do
                if opt.key == key then
                    btnText:SetText(opt.label)
                    break
                end
            end
        end
        
        return btn
    end
    
    -- Helper to create view toggle buttons
    local function CreateViewButton(parent, tooltip)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(22, 22)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        btn.iconLines = {}
        
        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(C_ELEMENT.r + 0.08, C_ELEMENT.g + 0.08, C_ELEMENT.b + 0.08, 1)
            end
            if tooltip then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(tooltip, 1, 1, 1)
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self.isActive then
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            end
            GameTooltip:Hide()
        end)
        
        function btn:SetActive(active)
            self.isActive = active
            if active then
                self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
                for _, line in ipairs(self.iconLines) do
                    line:SetColorTexture(themeColor.r, themeColor.g, themeColor.b, 1)
                end
                if self.azText then self.azText:SetTextColor(themeColor.r, themeColor.g, themeColor.b) end
            else
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
                for _, line in ipairs(self.iconLines) do
                    line:SetColorTexture(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
                end
                if self.azText then self.azText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b) end
            end
        end
        
        return btn
    end
    
    -- Create tabs (in tabs row)
    local spellsTab = CreateTabButton(tabsRow, L["Spells"], 55)
    spellsTab:SetPoint("LEFT", 4, 0)
    spellsTab:SetActive(true)
    CC.spellsTab = spellsTab
    
    local macrosTab = CreateTabButton(tabsRow, L["Macros"], 55)
    macrosTab:SetPoint("LEFT", spellsTab, "RIGHT", 2, 0)
    macrosTab:SetActive(false)
    CC.macrosTab = macrosTab
    
    local itemsTab = CreateTabButton(tabsRow, L["Items"], 50)
    itemsTab:SetPoint("LEFT", macrosTab, "RIGHT", 2, 0)
    itemsTab:SetActive(false)
    CC.itemsTab = itemsTab
    
    local profilesTab = CreateTabButton(tabsRow, L["Profiles"], 60)
    profilesTab:SetPoint("LEFT", itemsTab, "RIGHT", 2, 0)
    profilesTab:SetActive(false)
    CC.profilesTab = profilesTab
    
    CC.activeTab = "spells"
    CC.selectedMacroSource = "all"
    
    -- Macro-specific controls (in filter row, anchored from LEFT to avoid overlap)
    -- Macro source dropdown (leftmost)
    local macroSourceDropdown = CreateDropdown(filterRow, L["All"], 65, {
        {key = "all", label = L["All"]},
        {key = "custom", label = L["Custom"]},
        {key = "global_import", label = L["General"]},
        {key = "char_import", label = L["Character"]},
    }, function(key)
        CC.selectedMacroSource = key
        CC:RefreshSpellGrid()
    end)
    macroSourceDropdown:SetPoint("LEFT", 4, 0)
    macroSourceDropdown:Hide()
    CC.macroSourceDropdown = macroSourceDropdown
    
    -- New Macro button (green, prominent)
    local newMacroBtn = CreateFrame("Button", nil, filterRow, "BackdropTemplate")
    newMacroBtn:SetSize(55, 20)
    newMacroBtn:SetPoint("LEFT", macroSourceDropdown, "RIGHT", 8, 0)
    newMacroBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    newMacroBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
    newMacroBtn:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
    local newMacroIcon = newMacroBtn:CreateTexture(nil, "OVERLAY")
    newMacroIcon:SetPoint("LEFT", 6, 0)
    newMacroIcon:SetSize(12, 12)
    newMacroIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\add")
    newMacroIcon:SetVertexColor(1, 1, 1)
    local newMacroBtnText = newMacroBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    newMacroBtnText:SetPoint("LEFT", newMacroIcon, "RIGHT", 3, 0)
    newMacroBtnText:SetText(L["New"])
    newMacroBtnText:SetTextColor(1, 1, 1)
    newMacroBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(themeColor.r * 0.5, themeColor.g * 0.5, themeColor.b * 0.5, 1)
    end)
    newMacroBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
    end)
    newMacroBtn:SetScript("OnClick", function()
        CC:ShowMacroEditorDialog()
    end)
    newMacroBtn:Hide()
    CC.newMacroBtn = newMacroBtn
    
    -- Import button
    local importMacroBtn = CreateFrame("Button", nil, filterRow, "BackdropTemplate")
    importMacroBtn:SetSize(60, 20)
    importMacroBtn:SetPoint("LEFT", newMacroBtn, "RIGHT", 4, 0)
    importMacroBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    importMacroBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    importMacroBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local importMacroIcon = importMacroBtn:CreateTexture(nil, "OVERLAY")
    importMacroIcon:SetPoint("LEFT", 6, 0)
    importMacroIcon:SetSize(12, 12)
    importMacroIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\download")
    importMacroIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    local importMacroBtnText = importMacroBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    importMacroBtnText:SetPoint("LEFT", importMacroIcon, "RIGHT", 3, 0)
    importMacroBtnText:SetText(L["Import"])
    importMacroBtnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    importMacroBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    end)
    importMacroBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    end)
    importMacroBtn:SetScript("OnClick", function()
        CC:ShowImportMacroDialog()
    end)
    importMacroBtn:Hide()
    CC.importMacroBtn = importMacroBtn
    
    -- Quick Macro button
    local quickMacroBtn = CreateFrame("Button", nil, filterRow, "BackdropTemplate")
    quickMacroBtn:SetSize(62, 20)
    quickMacroBtn:SetPoint("LEFT", importMacroBtn, "RIGHT", 4, 0)
    quickMacroBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    quickMacroBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    quickMacroBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local quickMacroIcon = quickMacroBtn:CreateTexture(nil, "OVERLAY")
    quickMacroIcon:SetPoint("LEFT", 6, 0)
    quickMacroIcon:SetSize(12, 12)
    quickMacroIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\edit")
    quickMacroIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    local quickMacroBtnText = quickMacroBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    quickMacroBtnText:SetPoint("LEFT", quickMacroIcon, "RIGHT", 3, 0)
    quickMacroBtnText:SetText(L["Quick Macro"])
    quickMacroBtnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    quickMacroBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["Quick Macro"], 1, 1, 1)
        GameTooltip:AddLine("Create a simple macro without opening the full editor.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    quickMacroBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        GameTooltip:Hide()
    end)
    quickMacroBtn:SetScript("OnClick", function()
        CC:ShowQuickMacroDialog()
    end)
    quickMacroBtn:Hide()
    CC.quickMacroBtn = quickMacroBtn
    
    -- Macro hint (after buttons)
    local macroHint = filterRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    macroHint:SetPoint("LEFT", quickMacroBtn, "RIGHT", 12, 0)
    macroHint:SetText(L["Click macro to bind"])
    macroHint:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    macroHint:Hide()
    CC.macroHint = macroHint
    
    -- Remove macroSourceLabel since dropdown is self-explanatory
    local macroSourceLabel = filterRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    macroSourceLabel:SetPoint("LEFT", 0, 0)  -- Hidden, not used
    macroSourceLabel:SetText("")
    macroSourceLabel:Hide()
    CC.macroSourceLabel = macroSourceLabel
    
    -- =============================================
    -- SPELLS TAB CONTROLS (in filter row, anchor left of view buttons)
    -- =============================================
    -- "Click spell to bind" hint
    local bindHint = filterRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    -- Anchored dynamically after view buttons are created
    bindHint:SetText(L["Click spell to bind"])
    bindHint:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Show dropdown
    local showDropdown = CreateDropdown(filterRow, L["All"], 70, {
        {key = "all", label = L["All"]},
        {key = "helpful", label = "Helpful"},
        {key = "harmful", label = "Harmful"},
    }, function(key)
        CC.selectedSpellType = key
        CC:RefreshSpellGrid()
    end)
    CC.showDropdown = showDropdown
    CC.selectedSpellType = "all"
    
    local showLabel = filterRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    showLabel:SetText(L["Show:"])
    showLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- =============================================
    -- ITEMS TAB CONTROLS
    -- =============================================
    local itemsHint = filterRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    itemsHint:SetText(L["Click item slot to bind"])
    itemsHint:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    itemsHint:Hide()
    CC.itemsHint = itemsHint
    
    -- Tab switching function (defined after all controls exist)
    local function SetActiveTab(tabName)
        CC.activeTab = tabName
        spellsTab:SetActive(tabName == "spells")
        macrosTab:SetActive(tabName == "macros")
        itemsTab:SetActive(tabName == "items")
        profilesTab:SetActive(tabName == "profiles")
        
        -- Toggle spell controls
        local showSpellControls = (tabName == "spells")
        showLabel:SetShown(showSpellControls)
        showDropdown:SetShown(showSpellControls)
        bindHint:SetShown(showSpellControls)
        
        -- Toggle macro controls
        local showMacroControls = (tabName == "macros")
        macroSourceLabel:SetShown(showMacroControls)
        macroSourceDropdown:SetShown(showMacroControls)
        newMacroBtn:SetShown(showMacroControls)
        importMacroBtn:SetShown(showMacroControls)
        quickMacroBtn:SetShown(showMacroControls)
        macroHint:SetShown(showMacroControls)
        
        -- Toggle items controls
        local showItemsControls = (tabName == "items")
        itemsHint:SetShown(showItemsControls)
        
        -- Toggle profiles panel
        local showProfiles = (tabName == "profiles")
        if CC.profilesPanel then
            CC.profilesPanel:SetShown(showProfiles)
        end
        if CC.spellGrid then
            CC.spellGrid:SetShown(not showProfiles)
        end
        
        if not showProfiles then
            CC:RefreshSpellGrid()
        else
            CC:RefreshProfilesPanel()
        end
    end
    
    spellsTab:SetScript("OnClick", function() SetActiveTab("spells") end)
    macrosTab:SetScript("OnClick", function() SetActiveTab("macros") end)
    itemsTab:SetScript("OnClick", function() SetActiveTab("items") end)
    profilesTab:SetScript("OnClick", function() SetActiveTab("profiles") end)
    
    -- Store reference for external access (e.g., from profile settings cogwheel)
    CC.SetActiveTab = SetActiveTab
    
    -- View buttons (in filter row, far right side)
    local alphabeticalSortBtn = CreateViewButton(filterRow, L["A-Z"])
    alphabeticalSortBtn:SetPoint("RIGHT", -4, 0)
    local az = alphabeticalSortBtn:CreateFontString(nil, "ARTWORK", "DFFontNormalSmall")
    az:SetPoint("CENTER", 0, 0)
    az:SetText("AZ")
    az:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
    alphabeticalSortBtn.azText = az
    
    local sectionedSortBtn = CreateViewButton(filterRow, L["Categories"])
    sectionedSortBtn:SetPoint("RIGHT", alphabeticalSortBtn, "LEFT", -2, 0)
    local h1 = sectionedSortBtn:CreateTexture(nil, "ARTWORK")
    h1:SetSize(4, 2)
    h1:SetPoint("TOPLEFT", sectionedSortBtn, "CENTER", -6, 4)
    h1:SetColorTexture(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
    table.insert(sectionedSortBtn.iconLines, h1)
    local l1 = sectionedSortBtn:CreateTexture(nil, "ARTWORK")
    l1:SetSize(10, 2)
    l1:SetPoint("CENTER", 1, 0)
    l1:SetColorTexture(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
    table.insert(sectionedSortBtn.iconLines, l1)
    local h2 = sectionedSortBtn:CreateTexture(nil, "ARTWORK")
    h2:SetSize(4, 2)
    h2:SetPoint("TOPLEFT", sectionedSortBtn, "CENTER", -6, -4)
    h2:SetColorTexture(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
    table.insert(sectionedSortBtn.iconLines, h2)
    
    local gridViewBtn = CreateViewButton(filterRow, L["Grid"])
    gridViewBtn:SetPoint("RIGHT", sectionedSortBtn, "LEFT", -8, 0)
    local positions = {{-4, 3}, {4, 3}, {-4, -5}, {4, -5}}
    for _, pos in ipairs(positions) do
        local square = gridViewBtn:CreateTexture(nil, "ARTWORK")
        square:SetSize(5, 5)
        square:SetPoint("CENTER", pos[1], pos[2])
        square:SetColorTexture(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
        table.insert(gridViewBtn.iconLines, square)
    end
    
    local listViewBtn = CreateViewButton(filterRow, L["List"])
    listViewBtn:SetPoint("RIGHT", gridViewBtn, "LEFT", -2, 0)
    for i = 0, 2 do
        local line = listViewBtn:CreateTexture(nil, "ARTWORK")
        line:SetSize(12, 2)
        line:SetPoint("CENTER", 0, 3 - i * 4)
        line:SetColorTexture(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
        table.insert(listViewBtn.iconLines, line)
    end
    
    -- Layout/Sort toggle functions
    local function SetActiveLayout(layout)
        listViewBtn:SetActive(layout == "list")
        gridViewBtn:SetActive(layout == "grid")
    end
    
    local function SetActiveSort(sort)
        sectionedSortBtn:SetActive(sort == "sectioned")
        alphabeticalSortBtn:SetActive(sort == "alphabetical")
    end
    
    listViewBtn:SetScript("OnClick", function()
        CC.viewLayout = "list"
        CC.db.options.viewLayout = "list"
        SetActiveLayout("list")
        CC:RefreshSpellGrid()
    end)
    
    gridViewBtn:SetScript("OnClick", function()
        CC.viewLayout = "grid"
        CC.db.options.viewLayout = "grid"
        SetActiveLayout("grid")
        CC:RefreshSpellGrid()
    end)
    
    sectionedSortBtn:SetScript("OnClick", function()
        CC.viewSort = "sectioned"
        CC.db.options.viewSort = "sectioned"
        SetActiveSort("sectioned")
        CC:RefreshSpellGrid()
    end)
    
    alphabeticalSortBtn:SetScript("OnClick", function()
        CC.viewSort = "alphabetical"
        CC.db.options.viewSort = "alphabetical"
        SetActiveSort("alphabetical")
        CC:RefreshSpellGrid()
    end)
    
    CC.gridViewBtn = gridViewBtn
    CC.listViewBtn = listViewBtn
    CC.sectionedSortBtn = sectionedSortBtn
    CC.alphabeticalSortBtn = alphabeticalSortBtn
    CC.SetActiveLayout = SetActiveLayout
    CC.SetActiveSort = SetActiveSort
    
    -- Now anchor the tab-specific controls relative to view buttons
    bindHint:SetPoint("RIGHT", listViewBtn, "LEFT", -15, 0)
    showDropdown:SetPoint("RIGHT", bindHint, "LEFT", -8, 0)
    showLabel:SetPoint("RIGHT", showDropdown, "LEFT", -4, 0)
    itemsHint:SetPoint("RIGHT", listViewBtn, "LEFT", -15, 0)
    
    -- Macro controls are already positioned from LEFT inline above
    
    -- Load saved preferences
    CC.viewLayout = CC.db.options.viewLayout or "grid"
    CC.viewSort = CC.db.options.viewSort or "sectioned"
    
    -- =========================================================================
    -- SPELL GRID CONTAINER
    -- =========================================================================
    local gridContainer = CreateFrame("Frame", nil, selectionSection, "BackdropTemplate")
    gridContainer:SetPoint("TOPLEFT", selectionHeader, "BOTTOMLEFT", 0, -2)
    gridContainer:SetPoint("BOTTOMRIGHT", 0, 0)
    gridContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    gridContainer:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.5)
    gridContainer:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    CC.gridContainer = gridContainer
    
    -- Scroll frame for spell grid
    local scrollFrame = CreateFrame("ScrollFrame", nil, gridContainer, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)
    
    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetWidth(scrollFrame:GetWidth() - 10)
    scrollContent:SetHeight(1)
    scrollFrame:SetScrollChild(scrollContent)
    DF.GUI.StyleScrollBar(scrollFrame)

    CC.scrollContent = scrollContent
    CC.scrollFrame = scrollFrame

    -- Mouse wheel scrolling with smaller step
    -- Override the template's default scroll behavior
    local SCROLL_STEP = 30 -- Smaller step for smoother feel
    
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = self:GetVerticalScrollRange()
        if maxScroll <= 0 then return end
        
        local currentScroll = self:GetVerticalScroll()
        local newScroll = currentScroll - (delta * SCROLL_STEP)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        self:SetVerticalScroll(newScroll)
    end)
    
    -- Also handle on container for when cursor is outside scroll frame
    gridContainer:EnableMouseWheel(true)
    gridContainer:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = scrollFrame:GetVerticalScrollRange()
        if maxScroll <= 0 then return end
        
        local currentScroll = scrollFrame:GetVerticalScroll()
        local newScroll = currentScroll - (delta * SCROLL_STEP)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        scrollFrame:SetVerticalScroll(newScroll)
    end)
    
    -- Handle resize
    local resizeTimer = nil
    gridContainer:SetScript("OnSizeChanged", function(self, width, height)
        if resizeTimer then resizeTimer:Cancel() end
        resizeTimer = C_Timer.NewTimer(0.05, function()
            resizeTimer = nil
            if scrollFrame and scrollContent then
                scrollContent:SetWidth(scrollFrame:GetWidth() - 10)
            end
            if CC.RefreshSpellGrid then
                CC:RefreshSpellGrid(true)
            end
        end)
    end)
    
    -- =========================================================================
    -- PROFILES PANEL (hidden by default, shown when Profiles tab is active)
    -- =========================================================================
    local profilesPanel = CreateFrame("Frame", nil, selectionSection, "BackdropTemplate")
    profilesPanel:SetPoint("TOPLEFT", selectionHeader, "BOTTOMLEFT", 0, -2)
    profilesPanel:SetPoint("BOTTOMRIGHT", 0, 0)
    profilesPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    profilesPanel:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.5)
    profilesPanel:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    profilesPanel:Hide()
    CC.profilesPanel = profilesPanel
    
    -- Store reference for spellGrid (so we can show/hide it)
    CC.spellGrid = gridContainer
    
    -- Create the keybind capture popup
    CC:CreateKeybindPopup()
    
    -- Create the profiles panel content
    CC:CreateProfilesPanelContent()
end

-- =========================================================================

-- REFRESH ACTIVE BINDINGS LIST
-- =========================================================================
function CC:RefreshActiveBindings()
    if not self.bindingsContent then return end
    
    -- Clear existing rows
    for _, row in ipairs(bindingRows) do
        row:Hide()
        row:SetParent(nil)
    end
    wipe(bindingRows)
    
    -- Get all bindings
    local bindings = self.db.bindings or {}
    
    -- Count enabled bindings (default to enabled if not specified)
    local enabledCount = 0
    for _, binding in ipairs(bindings) do
        if binding.enabled ~= false then  -- Default to enabled
            enabledCount = enabledCount + 1
        end
    end
    
    -- Update title with count (only shown when expanded)
    if self.bindingsTitle then
        self.bindingsTitle:SetText(format(L["Active Bindings (%d)"], enabledCount))
    end
    
    -- Determine content width based on collapsed state
    local isCollapsed = self.leftPanelCollapsed
    local contentWidth
    if isCollapsed then
        contentWidth = LEFT_PANEL_COLLAPSED_WIDTH - 20  -- Narrower for icons only
    else
        contentWidth = LEFT_PANEL_WIDTH - 35
    end
    self.bindingsContent:SetWidth(contentWidth)
    
    -- Create rows for each binding
    local yOffset = 0
    local rowHeight = isCollapsed and 60 or BINDING_ROW_HEIGHT  -- Taller rows when collapsed for icon + text
    
    for i, binding in ipairs(bindings) do
        if binding.enabled ~= false then  -- Default to enabled
            if isCollapsed then
                -- Create collapsed binding row (icon + keybind vertically)
                local row = self:CreateCollapsedBindingRow(self.bindingsContent, binding, i)
                row:SetPoint("TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", 0, -yOffset)
                table.insert(bindingRows, row)
                yOffset = yOffset + rowHeight
            else
                -- Create full binding row
                local row = self:CreateBindingRow(self.bindingsContent, binding, i)
                row:SetPoint("TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", 0, -yOffset)
                table.insert(bindingRows, row)
                yOffset = yOffset + BINDING_ROW_HEIGHT
            end
        end
    end
    
    -- Update content height
    self.bindingsContent:SetHeight(math.max(yOffset, 1))
end

-- Create a collapsed binding row (icon + keybind stacked vertically)
function CC:CreateCollapsedBindingRow(parent, binding, index)
    local C = self.UI_COLORS
    local themeColor = C.theme
    
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(58)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    row:SetBackdropColor(C.element.r, C.element.g, C.element.b, 0.8)
    row:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
    
    -- Icon (centered, larger)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("TOP", 0, -3)
    
    -- Set icon based on action type (same logic as full row)
    if binding.actionType == "target" then
        icon:SetTexture("Interface\\CURSOR\\Crosshairs")
    elseif binding.actionType == "menu" then
        icon:SetTexture("Interface\\Buttons\\UI-GuildButton-OfficerNote-Up")
    elseif binding.actionType == "focus" then
        icon:SetTexture("Interface\\Icons\\Ability_Hunter_MasterMarksman")
    elseif binding.actionType == "assist" then
        icon:SetTexture("Interface\\Icons\\Ability_Hunter_SniperShot")
    elseif binding.actionType == CC.ACTION_TYPES.ITEM then
        if binding.itemType == "slot" and binding.itemSlot then
            local itemInfo = CC:GetSlotItemInfo(binding.itemSlot)
            if itemInfo and itemInfo.icon then
                icon:SetTexture(itemInfo.icon)
            else
                for _, slotData in ipairs(CC.EQUIPMENT_SLOTS) do
                    if slotData.slot == binding.itemSlot then
                        icon:SetTexture(slotData.icon)
                        break
                    end
                end
            end
        elseif binding.itemId then
            local itemInfo = CC:GetItemInfoById(binding.itemId)
            if itemInfo and itemInfo.icon then
                icon:SetTexture(itemInfo.icon)
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
    elseif binding.actionType == "macro" and binding.macroId then
        local macro = CC:GetMacroById(binding.macroId)
        if macro then
            local autoIcon = CC:GetIconFromMacroBody(macro.body)
            if autoIcon then
                icon:SetTexture(autoIcon)
            elseif macro.icon and type(macro.icon) == "number" and macro.icon > 0 then
                icon:SetTexture(macro.icon)
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
    elseif binding.spellId or binding.spellName then
        local _, displayIcon = GetSpellDisplayInfo(binding.spellId, binding.spellName)
        icon:SetTexture(displayIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
    else
        icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Keybind text (below icon, centered)
    local bindText = ""
    if binding.bindType == "mouse" then
        local modDisplay = ""
        if binding.modifiers and binding.modifiers ~= "" then
            local mods = binding.modifiers:lower()
            if mods:find("shift") then modDisplay = modDisplay .. "S+" end
            if mods:find("ctrl") then modDisplay = modDisplay .. "C+" end
            if mods:find("alt") then modDisplay = modDisplay .. "A+" end
            if mods:find("meta") then modDisplay = modDisplay .. "⌘+" end
        end
        local buttonName = CC.BUTTON_DISPLAY_NAMES[binding.button] or binding.button
        bindText = modDisplay .. buttonName
    elseif binding.bindType == "key" then
        local modDisplay = ""
        if binding.modifiers and binding.modifiers ~= "" then
            local mods = binding.modifiers:lower()
            if mods:find("shift") then modDisplay = modDisplay .. "S+" end
            if mods:find("ctrl") then modDisplay = modDisplay .. "C+" end
            if mods:find("alt") then modDisplay = modDisplay .. "A+" end
            if mods:find("meta") then modDisplay = modDisplay .. "⌘+" end
        end
        local keyName = CC.KEY_DISPLAY_NAMES[binding.key] or binding.key
        bindText = modDisplay .. keyName
    elseif binding.bindType == "scroll" then
        local modDisplay = ""
        if binding.modifiers and binding.modifiers ~= "" then
            local mods = binding.modifiers:lower()
            if mods:find("shift") then modDisplay = modDisplay .. "S+" end
            if mods:find("ctrl") then modDisplay = modDisplay .. "C+" end
            if mods:find("alt") then modDisplay = modDisplay .. "A+" end
            if mods:find("meta") then modDisplay = modDisplay .. "⌘+" end
        end
        local scrollName = CC.SCROLL_DISPLAY_NAMES[binding.key] or binding.key
        bindText = modDisplay .. scrollName
    end
    
    local keybind = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    keybind:SetPoint("BOTTOM", 0, 3)
    keybind:SetJustifyH("CENTER")
    keybind:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    keybind:SetText(bindText)
    keybind:SetWidth(LEFT_PANEL_COLLAPSED_WIDTH - 16)
    keybind:SetWordWrap(false)
    
    row.binding = binding
    row.bindingIndex = index
    
    -- Hover effect
    local displayName = CC:GetActionDisplayString(binding)
    row:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C.element.r + 0.08, C.element.g + 0.08, C.element.b + 0.08, 1)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(displayName, 1, 1, 1)
        GameTooltip:AddLine(bindText, themeColor.r, themeColor.g, themeColor.b)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Click to edit"], 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C.element.r, C.element.g, C.element.b, 0.8)
        self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
        GameTooltip:Hide()
    end)
    
    -- Click to edit
    row:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local bindingIcon = nil
            local actionType = binding.actionType or CC.ACTION_TYPES.SPELL
            
            if binding.spellId or binding.spellName then
                local _, displayIcon = GetSpellDisplayInfo(binding.spellId, binding.spellName)
                bindingIcon = displayIcon
            end
            
            local displayName, displayIcon, displaySpellId = GetSpellDisplayInfo(binding.spellId, binding.spellName)
            local spellInfo = {
                name = displayName or binding.spellName or binding.macroName or binding.actionType,
                spellId = binding.spellId,
                spellName = binding.spellName,
                icon = displayIcon or bindingIcon,
                isMacro = actionType == CC.ACTION_TYPES.MACRO,
                macroId = binding.macroId,
                actionType = actionType,
                displaySpellId = displaySpellId,
            }
            CC:ShowEditBindingPanel(spellInfo, binding, self.bindingIndex)
        end
    end)
    
    return row
end

-- Full UI refresh - call this when talents or profiles change
function CC:RefreshClickCastingUI()
    -- Refresh spell grid (includes bindings list)
    if self.scrollContent then
        self:RefreshSpellGrid()
    end
    
    -- Refresh profiles panel if visible
    if self.activeTab == "profiles" and self.profilesPanel then
        self:RefreshProfilesPanel()
    end
    
    -- Update profile dropdown
    if self.UpdateProfileDropdown then
        self.UpdateProfileDropdown()
    end
    
    -- Update smart res dropdown
    if self.UpdateSmartResText then
        self.UpdateSmartResText()
    end
end

-- Keybind capture popup
function CC:CreateKeybindPopup()
    if self.keybindPopup then return end
    
    local themeColor = {r = 0.2, g = 0.8, b = 0.4}
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08}
    local C_ELEMENT = {r = 0.18, g = 0.18, b = 0.18}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25}
    
    -- Global capture frame (invisible, captures input anywhere on screen)
    local captureFrame = CreateFrame("Frame", "DFKeybindCapture", UIParent)
    captureFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    captureFrame:SetAllPoints(UIParent)
    captureFrame:EnableKeyboard(true)
    captureFrame:EnableMouse(true)
    captureFrame:EnableMouseWheel(true)
    captureFrame:Hide()
    
    -- Helper to check if a key is a valid bindable key
    local function IsBindableKey(key)
        -- Modifier keys shouldn't be captured as the main key
        if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" or key == "LMETA" or key == "RMETA" then
            return false
        end
        -- Accept any other key that WoW reports - this supports international keyboards
        -- Keys like ^ on German keyboards, ñ on Spanish, etc.
        return key and key ~= ""
    end
    
    -- Keyboard capture on global frame
    captureFrame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            CC:HideKeybindPopup()
            return
        end
        
        if IsBindableKey(key) then
            CC:ProcessKeybind("key", key)
        end
    end)
    
    -- Mouse capture moved after popup creation to allow cancel button check
    
    -- Scroll wheel capture on global frame
    captureFrame:SetScript("OnMouseWheel", function(self, delta)
        local scrollKey = delta > 0 and "SCROLLUP" or "SCROLLDOWN"
        CC:ProcessKeybind("scroll", scrollKey)
    end)
    
    self.keybindCaptureFrame = captureFrame
    
    -- Visual popup (displays info, positioned on our UI)
    local popup = CreateFrame("Frame", "DFKeybindPopup", UIParent, "BackdropTemplate")
    local popupHeight = (IsMacClient and IsMacClient()) and 155 or 140
    popup:SetSize(280, popupHeight)
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(captureFrame:GetFrameLevel() + 10)
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    popup:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0.98)
    popup:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    popup:Hide()
    
    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    popup.title = title
    
    -- Spell name
    local spellName = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    spellName:SetPoint("TOP", title, "BOTTOM", 0, -8)
    spellName:SetTextColor(1, 1, 1)
    popup.spellName = spellName
    
    -- Instructions
    local instructions = popup:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    instructions:SetPoint("TOP", spellName, "BOTTOM", 0, -12)
    instructions:SetText(L["Press any key, mouse button, or scroll wheel\n(with modifiers if desired)"])
    instructions:SetTextColor(0.7, 0.7, 0.7)
    instructions:SetJustifyH("CENTER")
    
    -- Mac warning (only visible on Mac)
    local isMac = IsMacClient and IsMacClient()
    local macWarning = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    macWarning:SetPoint("TOP", instructions, "BOTTOM", 0, -4)
    macWarning:SetText("|cffff9900" .. L["Note: Cmd + Left Click unavailable on Mac"] .. "|r")
    macWarning:SetTextColor(0.9, 0.6, 0.2)
    if isMac then
        macWarning:Show()
    else
        macWarning:Hide()
    end
    popup.macWarning = macWarning
    
    -- Modifier display
    local modDisplay = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    modDisplay:SetPoint("TOP", instructions, "BOTTOM", 0, isMac and -18 or -8)
    modDisplay:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    popup.modDisplay = modDisplay
    
    -- Cancel button - create as separate frame at highest strata to avoid capture frame blocking
    local cancelBtn = CreateFrame("Button", "DFKeybindCancelBtn", UIParent, "BackdropTemplate")
    cancelBtn:SetSize(80, 24)
    cancelBtn:SetFrameStrata("TOOLTIP")  -- Highest strata, above FULLSCREEN_DIALOG
    cancelBtn:SetFrameLevel(9999)  -- Very high frame level
    cancelBtn:EnableMouse(true)  -- Ensure mouse is enabled
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    cancelBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    cancelBtn:Hide()
    
    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    cancelText:SetPoint("CENTER")
    cancelText:SetText(L["Cancel"])
    cancelText:SetTextColor(0.9, 0.9, 0.9)
    
    cancelBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    end)
    cancelBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    end)
    cancelBtn:SetScript("OnClick", function(self)
        CC:HideKeybindPopup()
    end)
    
    -- Store reference and link to popup
    popup.cancelBtn = cancelBtn
    CC.keybindCancelBtn = cancelBtn
    
    -- Update the capture frame mouse handler - check if over cancel button first
    captureFrame:SetScript("OnMouseDown", function(self, button)
        -- Check if left-clicking on the cancel button using bounds check
        if button == "LeftButton" and cancelBtn and cancelBtn:IsShown() then
            local x, y = GetCursorPosition()
            local scale = cancelBtn:GetEffectiveScale()
            x, y = x / scale, y / scale
            local left, bottom, width, height = cancelBtn:GetRect()
            if left and x >= left and x <= (left + width) and y >= bottom and y <= (bottom + height) then
                CC:HideKeybindPopup()
                return
            end
        end
        
        -- Accept standard buttons and Button4-Button31 for gaming mice
        if button == "LeftButton" or button == "RightButton" or button == "MiddleButton" or button:match("^Button%d+$") then
            CC:ProcessKeybind("mouse", button)
        end
    end)
    
    -- Update modifier display on update
    popup:SetScript("OnUpdate", function(self)
        local mods = ""
        if IsShiftKeyDown() then mods = mods .. "Shift + " end
        if IsControlKeyDown() then mods = mods .. "Ctrl + " end
        if IsAltKeyDown() then mods = mods .. "Alt + " end
        if IsMetaKeyDown() then mods = mods .. "Cmd + " end
        if mods == "" then
            self.modDisplay:SetText("")
        else
            self.modDisplay:SetText(mods .. "...")
        end
    end)
    
    self.keybindPopup = popup
end

-- Hide the keybind popup and capture frame
function CC:HideKeybindPopup()
    if self.keybindPopup then
        self.keybindPopup:Hide()
    end
    if self.keybindCaptureFrame then
        self.keybindCaptureFrame:Hide()
    end
    if self.keybindCancelBtn then
        self.keybindCancelBtn:Hide()
    end
    self.pendingSpellData = nil
end

-- Show the keybind popup for a spell or action
function CC:ShowKeybindPopup(spellData)
    if not self.keybindPopup then return end
    
    self.pendingSpellData = spellData
    
    if spellData.isItem then
        -- Item binding
        self.keybindPopup.title:SetText(L["Bind Item"])
        self.keybindPopup.spellName:SetText(spellData.name or "Unknown Item")
    elseif spellData.actionType and not spellData.spellName then
        -- Special action (Target, Menu)
        self.keybindPopup.title:SetText(L["Bind Action"])
        self.keybindPopup.spellName:SetText(spellData.name or spellData.actionType)
    else
        -- Regular spell - show current override name for display
        self.keybindPopup.title:SetText(L["Bind Spell"])
        local displayName = GetSpellDisplayInfo(spellData.spellId, spellData.spellName or spellData.name)
        self.keybindPopup.spellName:SetText(displayName or spellData.spellName or spellData.name or "Unknown")
    end
    
    -- Position centered on our click casting UI frame
    self.keybindPopup:ClearAllPoints()
    if self.clickCastUIFrame then
        self.keybindPopup:SetPoint("CENTER", self.clickCastUIFrame, "CENTER", 0, 0)
    else
        self.keybindPopup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    -- Show both capture frame and popup
    self.keybindCaptureFrame:Show()
    self.keybindPopup:Show()
    self.keybindPopup:Raise()
    
    -- Position and show cancel button (separate frame at TOOLTIP strata)
    if self.keybindCancelBtn then
        self.keybindCancelBtn:ClearAllPoints()
        self.keybindCancelBtn:SetPoint("BOTTOM", self.keybindPopup, "BOTTOM", 0, 10)
        self.keybindCancelBtn:Show()
        self.keybindCancelBtn:Raise()
    end
end

-- ============================================================
