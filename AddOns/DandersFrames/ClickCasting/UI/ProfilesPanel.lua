local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast
local L = DF.L
local format = string.format

-- Local aliases for helper functions (defined in Constants.lua and Profiles.lua)
local IsDefaultProfile = function(name) return CC.IsDefaultProfile(name) end

-- PROFILES PANEL UI
-- =========================================================================

function CC:CreateProfilesPanelContent()
    local panel = self.profilesPanel
    if not panel then return end
    
    local C = self.UI_COLORS
    local themeColor = C.theme
    
    -- Two-column layout
    local leftCol = CreateFrame("Frame", nil, panel)
    leftCol:SetPoint("TOPLEFT", 10, -10)
    leftCol:SetPoint("BOTTOMLEFT", 10, 10)
    leftCol:SetWidth(200)  -- Narrower for more right space
    
    local rightCol = CreateFrame("Frame", nil, panel)
    rightCol:SetPoint("TOPLEFT", leftCol, "TOPRIGHT", 10, 0)
    rightCol:SetPoint("BOTTOMRIGHT", -10, 10)
    
    -- ===== LEFT COLUMN: Profile List =====
    local profilesLabel = leftCol:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    profilesLabel:SetPoint("TOPLEFT", 0, 0)
    profilesLabel:SetText(L["YOUR PROFILES"])
    profilesLabel:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)
    
    local profileList = CreateFrame("Frame", nil, leftCol, "BackdropTemplate")
    profileList:SetPoint("TOPLEFT", profilesLabel, "BOTTOMLEFT", 0, -4)
    profileList:SetPoint("RIGHT", 0, 0)
    profileList:SetHeight(180)
    profileList:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    profileList:SetBackdropColor(0.06, 0.06, 0.06, 1)
    profileList:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
    CC.profileListFrame = profileList
    
    -- Profile list scroll frame
    local profileScroll = CreateFrame("ScrollFrame", nil, profileList, "ScrollFrameTemplate")
    profileScroll:SetPoint("TOPLEFT", 2, -2)
    profileScroll:SetPoint("BOTTOMRIGHT", -22, 2)
    DF.GUI.StyleScrollBar(profileScroll)

    local profileContent = CreateFrame("Frame", nil, profileScroll)
    profileContent:SetWidth(profileScroll:GetWidth())
    profileContent:SetHeight(1)
    profileScroll:SetScrollChild(profileContent)
    CC.profileListContent = profileContent
    
    -- Profile buttons
    local btnRow = CreateFrame("Frame", nil, leftCol)
    btnRow:SetPoint("TOPLEFT", profileList, "BOTTOMLEFT", 0, -8)
    btnRow:SetPoint("RIGHT", 0, 0)
    btnRow:SetHeight(22)
    
    local function CreateSmallButton(parent, text, width)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(width, 22)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
        btn:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(C.text.r, C.text.g, C.text.b)
        btn.text = btnText
        
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
        end)
        
        return btn
    end
    
    -- Row 1: New and Copy buttons
    local newBtn = CreateSmallButton(btnRow, L["New"], 10)  -- Width will be set by anchors
    newBtn:SetPoint("LEFT", 0, 0)
    newBtn:SetPoint("RIGHT", btnRow, "CENTER", -2, 0)
    newBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
    -- Add icon
    local newIcon = newBtn:CreateTexture(nil, "OVERLAY")
    newIcon:SetPoint("LEFT", 8, 0)
    newIcon:SetSize(12, 12)
    newIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\add")
    newIcon:SetVertexColor(C.text.r, C.text.g, C.text.b)
    newBtn.text:ClearAllPoints()
    newBtn.text:SetPoint("LEFT", newIcon, "RIGHT", 4, 0)
    newBtn:SetScript("OnClick", function()
        CC:ShowNewProfileDialog()
    end)
    
    local copyBtn = CreateSmallButton(btnRow, L["Copy"], 10)
    copyBtn:SetPoint("LEFT", btnRow, "CENTER", 2, 0)
    copyBtn:SetPoint("RIGHT", 0, 0)
    -- Add icon
    local copyIcon = copyBtn:CreateTexture(nil, "OVERLAY")
    copyIcon:SetPoint("LEFT", 8, 0)
    copyIcon:SetSize(12, 12)
    copyIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\content_copy")
    copyIcon:SetVertexColor(C.text.r, C.text.g, C.text.b)
    copyBtn.text:ClearAllPoints()
    copyBtn.text:SetPoint("LEFT", copyIcon, "RIGHT", 4, 0)
    copyBtn:SetScript("OnClick", function()
        if CC.selectedProfileName then
            CC:ShowCopyProfileDialog(CC.selectedProfileName)
        end
    end)
    CC.profileCopyBtn = copyBtn
    
    -- Row 2: Rename and Delete buttons
    local btnRow2 = CreateFrame("Frame", nil, leftCol)
    btnRow2:SetPoint("TOPLEFT", btnRow, "BOTTOMLEFT", 0, -3)
    btnRow2:SetPoint("RIGHT", btnRow, "RIGHT", 0, 0)
    btnRow2:SetHeight(22)
    
    local renameBtn = CreateSmallButton(btnRow2, L["Rename"], 10)
    renameBtn:SetPoint("LEFT", 0, 0)
    renameBtn:SetPoint("RIGHT", btnRow2, "CENTER", -2, 0)
    -- Add icon
    local renameIcon = renameBtn:CreateTexture(nil, "OVERLAY")
    renameIcon:SetPoint("LEFT", 8, 0)
    renameIcon:SetSize(12, 12)
    renameIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\edit")
    renameIcon:SetVertexColor(C.text.r, C.text.g, C.text.b)
    renameBtn.text:ClearAllPoints()
    renameBtn.text:SetPoint("LEFT", renameIcon, "RIGHT", 4, 0)
    renameBtn:SetScript("OnClick", function()
        if CC.selectedProfileName then
            CC:ShowRenameProfileDialog(CC.selectedProfileName)
        end
    end)
    CC.profileRenameBtn = renameBtn
    
    local deleteBtn = CreateSmallButton(btnRow2, L["Delete"], 10)
    deleteBtn:SetPoint("LEFT", btnRow2, "CENTER", 2, 0)
    deleteBtn:SetPoint("RIGHT", 0, 0)
    -- Add icon
    local deleteIcon = deleteBtn:CreateTexture(nil, "OVERLAY")
    deleteIcon:SetPoint("LEFT", 8, 0)
    deleteIcon:SetSize(12, 12)
    deleteIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\delete")
    deleteIcon:SetVertexColor(1, 0.5, 0.5)
    deleteBtn.text:ClearAllPoints()
    deleteBtn.text:SetPoint("LEFT", deleteIcon, "RIGHT", 4, 0)
    deleteBtn:SetBackdropBorderColor(0.8, 0.2, 0.2, 0.5)
    deleteBtn.text:SetTextColor(1, 0.5, 0.5)
    deleteBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.3, 0.3, 1)
    end)
    deleteBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.8, 0.2, 0.2, 0.5)
    end)
    deleteBtn:SetScript("OnClick", function()
        if CC.selectedProfileName and not IsDefaultProfile(CC.selectedProfileName) then
            CC:ShowDeleteProfileDialog(CC.selectedProfileName)
        end
    end)
    CC.profileDeleteBtn = deleteBtn
    
    -- Import/Export section
    local ioLabel = leftCol:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    ioLabel:SetPoint("TOPLEFT", btnRow2, "BOTTOMLEFT", 0, -12)
    ioLabel:SetText(L["Import/Export"])
    ioLabel:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)
    
    local ioRow = CreateFrame("Frame", nil, leftCol)
    ioRow:SetPoint("TOPLEFT", ioLabel, "BOTTOMLEFT", 0, -4)
    ioRow:SetPoint("RIGHT", 0, 0)
    ioRow:SetHeight(22)
    
    local exportBtn = CreateSmallButton(ioRow, L["Export"], 10)
    exportBtn:SetPoint("LEFT", 0, 0)
    exportBtn:SetPoint("RIGHT", ioRow, "CENTER", -2, 0)
    exportBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
    -- Add icon
    local exportIcon = exportBtn:CreateTexture(nil, "OVERLAY")
    exportIcon:SetPoint("LEFT", 8, 0)
    exportIcon:SetSize(12, 12)
    exportIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\upload")
    exportIcon:SetVertexColor(C.text.r, C.text.g, C.text.b)
    exportBtn.text:ClearAllPoints()
    exportBtn.text:SetPoint("LEFT", exportIcon, "RIGHT", 4, 0)
    exportBtn:SetScript("OnClick", function()
        CC:ShowExportDialog()
    end)
    
    local importBtn = CreateSmallButton(ioRow, L["Import"], 10)
    importBtn:SetPoint("LEFT", ioRow, "CENTER", 2, 0)
    importBtn:SetPoint("RIGHT", 0, 0)
    -- Add icon
    local importIcon = importBtn:CreateTexture(nil, "OVERLAY")
    importIcon:SetPoint("LEFT", 8, 0)
    importIcon:SetSize(12, 12)
    importIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\download")
    importIcon:SetVertexColor(C.text.r, C.text.g, C.text.b)
    importBtn.text:ClearAllPoints()
    importBtn.text:SetPoint("LEFT", importIcon, "RIGHT", 4, 0)
    importBtn:SetScript("OnClick", function()
        CC:ShowImportDialog()
    end)
    
    -- Auto-create profiles checkbox
    local autoCreateCb = CreateFrame("CheckButton", nil, leftCol, "BackdropTemplate")
    autoCreateCb:SetPoint("TOPLEFT", ioRow, "BOTTOMLEFT", 0, -12)
    autoCreateCb:SetSize(14, 14)
    autoCreateCb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    autoCreateCb:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
    autoCreateCb:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
    
    local autoCreateCheck = autoCreateCb:CreateTexture(nil, "OVERLAY")
    autoCreateCheck:SetPoint("CENTER")
    autoCreateCheck:SetSize(10, 10)
    autoCreateCheck:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    autoCreateCheck:SetDesaturated(true)
    autoCreateCheck:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
    autoCreateCb.check = autoCreateCheck
    
    local autoCreateLabel = leftCol:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    autoCreateLabel:SetPoint("LEFT", autoCreateCb, "RIGHT", 5, 0)
    autoCreateLabel:SetText(L["Auto-create profiles for loadouts"])
    autoCreateLabel:SetTextColor(C.text.r, C.text.g, C.text.b)
    
    -- Initialize checkbox state
    local autoCreate = CC.db and CC.db.global and CC.db.global.autoCreateProfiles
    if autoCreate == nil then autoCreate = true end
    autoCreateCb:SetChecked(autoCreate)
    autoCreateCheck:SetShown(autoCreate)
    
    autoCreateCb:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        self.check:SetShown(checked)
        if CC.db and CC.db.global then
            CC.db.global.autoCreateProfiles = checked
        end
        if checked then
            print("|cff33cc33DandersFrames:|r Auto-create profiles enabled.")
        else
            print("|cffff9900DandersFrames:|r Auto-create profiles disabled. Profiles will not be created for new loadouts.")
        end
        -- Refresh to update the status text
        CC:RefreshProfilesPanel()
    end)
    
    autoCreateCb:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Auto-Create Profiles"], 1, 1, 1)
        GameTooltip:AddLine(L["When enabled, a new profile will be automatically"], 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("created when you switch to a talent loadout that", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("doesn't have a profile assigned.", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine(" ", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Disable this if you want to use the same profile", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("for all your loadouts.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    autoCreateCb:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
        GameTooltip:Hide()
    end)
    
    CC.autoCreateCb = autoCreateCb
    
    -- Disable while mounted checkbox
    local mountCb = CreateFrame("Button", nil, leftCol, "BackdropTemplate")
    mountCb:SetSize(16, 16)
    mountCb:SetPoint("TOPLEFT", autoCreateCb, "BOTTOMLEFT", 0, -8)
    mountCb:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    mountCb:SetBackdropColor(0.1, 0.1, 0.1, 1)
    mountCb:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
    
    local mountCheck = mountCb:CreateTexture(nil, "OVERLAY")
    mountCheck:SetSize(10, 10)
    mountCheck:SetPoint("CENTER")
    mountCheck:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    mountCheck:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
    mountCb.check = mountCheck
    
    local mountLabel = leftCol:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    mountLabel:SetPoint("LEFT", mountCb, "RIGHT", 6, 0)
    mountLabel:SetText(L["Disable while mounted/flying"])
    mountLabel:SetTextColor(C.text.r, C.text.g, C.text.b)
    
    -- Define methods first
    mountCb.SetChecked = function(self, checked)
        self.isChecked = checked
        self.check:SetShown(checked)
    end
    mountCb.GetChecked = function(self)
        return self.isChecked
    end
    
    -- Initialize checkbox state
    local disableMounted = CC.db and CC.db.global and CC.db.global.disableWhileMounted
    if disableMounted == nil then disableMounted = false end
    mountCb:SetChecked(disableMounted)
    
    mountCb:SetScript("OnClick", function(self)
        local checked = not self:GetChecked()
        self:SetChecked(checked)
        if CC.db and CC.db.global then
            CC.db.global.disableWhileMounted = checked
        end
        if checked then
            print("|cff33cc33DandersFrames:|r Click-casting will be disabled while mounted/flying.")
        else
            print("|cffff9900DandersFrames:|r Click-casting will stay active while mounted/flying.")
        end
        -- Rebuild bindings with new macro conditions (if not in combat)
        if not InCombatLockdown() then
            CC:ApplyBindings()
        else
            CC.needsBindingRefresh = true
        end
    end)
    
    mountCb:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Disable While Mounted"], 1, 1, 1)
        GameTooltip:AddLine(L["When enabled, click-casting bindings will be"], 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("temporarily disabled while you are mounted", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("or in druid flight form.", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine(" ", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("This allows normal clicking on unit frames", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("to select targets while traveling.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    mountCb:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
        GameTooltip:Hide()
    end)
    
    CC.mountCb = mountCb
    
    -- ===== RIGHT COLUMN: Loadout Assignments =====
    local loadoutLabel = rightCol:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    loadoutLabel:SetPoint("TOPLEFT", 0, 0)
    loadoutLabel:SetText(L["LOADOUT ASSIGNMENTS"])
    loadoutLabel:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)
    
    local loadoutContainer = CreateFrame("Frame", nil, rightCol, "BackdropTemplate")
    loadoutContainer:SetPoint("TOPLEFT", loadoutLabel, "BOTTOMLEFT", 0, -4)
    loadoutContainer:SetPoint("RIGHT", 0, 0)
    loadoutContainer:SetPoint("BOTTOM", 0, 0)
    loadoutContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    loadoutContainer:SetBackdropColor(0.06, 0.06, 0.06, 1)
    loadoutContainer:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
    
    -- Loadout scroll frame
    local loadoutScroll = CreateFrame("ScrollFrame", nil, loadoutContainer, "ScrollFrameTemplate")
    loadoutScroll:SetPoint("TOPLEFT", 2, -2)
    loadoutScroll:SetPoint("BOTTOMRIGHT", -22, 2)
    DF.GUI.StyleScrollBar(loadoutScroll)

    local loadoutContent = CreateFrame("Frame", nil, loadoutScroll)
    loadoutContent:SetHeight(1)
    loadoutScroll:SetScrollChild(loadoutContent)
    CC.loadoutContent = loadoutContent
    CC.loadoutScroll = loadoutScroll
    
    -- Update content width on size change
    loadoutContainer:SetScript("OnSizeChanged", function()
        loadoutContent:SetWidth(math.max(loadoutScroll:GetWidth() - 10, 100))
    end)
    
    -- Auto-link indicator at bottom
    local autoLinkInfo = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    autoLinkInfo:SetPoint("BOTTOMLEFT", 10, 10)
    autoLinkInfo:SetPoint("RIGHT", panel, "RIGHT", -220, 0) -- Limit width so it doesn't overlap right column
    autoLinkInfo:SetJustifyH("LEFT")
    autoLinkInfo:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)
    CC.autoLinkInfo = autoLinkInfo
end

function CC:RefreshProfilesPanel()
    if not self.profilesPanel or not self.profilesPanel:IsShown() then return end
    
    local C = self.UI_COLORS
    local themeColor = C.theme
    
    -- Clear existing profile items
    if self.profileListContent then
        for _, child in ipairs({self.profileListContent:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
    end
    
    -- Update auto-create checkbox state
    if self.autoCreateCb then
        local autoCreate = self.db and self.db.global and self.db.global.autoCreateProfiles
        if autoCreate == nil then autoCreate = true end
        self.autoCreateCb:SetChecked(autoCreate)
        if self.autoCreateCb.check then
            self.autoCreateCb.check:SetShown(autoCreate)
        end
    end
    
    -- Update mount checkbox state
    if self.mountCb then
        local disableMounted = self.db and self.db.global and self.db.global.disableWhileMounted
        if disableMounted == nil then disableMounted = false end
        self.mountCb:SetChecked(disableMounted)
        if self.mountCb.check then
            self.mountCb.check:SetShown(disableMounted)
        end
    end
    
    -- Get profiles
    local profiles = self:GetProfileList()
    local activeProfile = self:GetActiveProfileName()
    local yOffset = 0
    
    -- Create profile items
    for _, profileName in ipairs(profiles) do
        local item = CreateFrame("Button", nil, self.profileListContent, "BackdropTemplate")
        item:SetPoint("TOPLEFT", 0, -yOffset)
        item:SetPoint("RIGHT", 0, 0)
        item:SetHeight(28)
        item:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
        })
        
        local isActive = (profileName == activeProfile)
        local isSelected = (profileName == self.selectedProfileName)
        
        if isSelected then
            item:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
        elseif isActive then
            item:SetBackdropColor(0.15, 0.25, 0.15, 1)
        else
            item:SetBackdropColor(0.1, 0.1, 0.1, 1)
        end
        
        -- Active indicator
        if isActive then
            local dot = item:CreateTexture(nil, "OVERLAY")
            dot:SetSize(8, 8)
            dot:SetPoint("LEFT", 6, 0)
            dot:SetTexture("Interface\\Buttons\\WHITE8x8")
            dot:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
        end
        
        -- Binding count (create first so nameText can anchor to it)
        local classData = self:GetClassData()
        local profile = classData.profiles[profileName]
        local bindCount = profile and profile.bindings and #profile.bindings or 0
        
        local countText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        countText:SetPoint("RIGHT", -6, 0)
        countText:SetText(format(L["%d binds"], bindCount))
        countText:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)
        
        local nameText = item:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        nameText:SetPoint("LEFT", isActive and 18 or 6, 0)
        nameText:SetPoint("RIGHT", countText, "LEFT", -8, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetWordWrap(false)
        nameText:SetText(profileName)
        nameText:SetTextColor(C.text.r, C.text.g, C.text.b)
        
        -- Store full name for tooltip
        item.fullProfileName = profileName
        
        item:SetScript("OnClick", function()
            self.selectedProfileName = profileName
            -- Switch to the profile on single click (if not in combat and not already active)
            if profileName ~= activeProfile and not InCombatLockdown() then
                if self:SetActiveProfile(profileName) then
                    self:ApplyBindings()
                    self:RefreshClickCastingUI()  -- Refresh entire UI including bindings list
                end
            elseif InCombatLockdown() then
                print("|cffff9900DandersFrames:|r Cannot switch profiles during combat")
            else
                -- Already active, just refresh to update selection highlight
                self:RefreshProfilesPanel()
            end
        end)
        
        item:SetScript("OnDoubleClick", function()
            -- Double-click does the same as single-click
        end)
        
        item:SetScript("OnEnter", function(self)
            if not isSelected then
                self:SetBackdropColor(0.15, 0.15, 0.15, 1)
            end
            -- Show tooltip with full profile name
            if self.fullProfileName and #self.fullProfileName > 20 then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.fullProfileName, 1, 1, 1)
                GameTooltip:Show()
            end
        end)
        
        item:SetScript("OnLeave", function(self)
            if not isSelected then
                if isActive then
                    self:SetBackdropColor(0.15, 0.25, 0.15, 1)
                else
                    self:SetBackdropColor(0.1, 0.1, 0.1, 1)
                end
            end
            GameTooltip:Hide()
        end)
        
        yOffset = yOffset + 30
    end
    
    self.profileListContent:SetHeight(math.max(yOffset, 1))
    
    -- Update button states
    local canModify = self.selectedProfileName and not IsDefaultProfile(self.selectedProfileName)
    if self.profileDeleteBtn then
        self.profileDeleteBtn:SetEnabled(canModify)
        self.profileDeleteBtn:SetAlpha(canModify and 1 or 0.5)
    end
    if self.profileRenameBtn then
        self.profileRenameBtn:SetEnabled(canModify)
        self.profileRenameBtn:SetAlpha(canModify and 1 or 0.5)
    end
    
    -- Refresh loadout assignments
    self:RefreshLoadoutAssignments()
    
    -- Update auto-link info
    if self.autoLinkInfo then
        local specIndex = GetSpecialization() or 1
        local loadoutID = 0
        if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
            loadoutID = C_ClassTalents.GetActiveConfigID() or 0
        end
        local assignedProfile, isSpecific = self:GetProfileForLoadout(specIndex, loadoutID)
        
        -- Check auto-create setting
        local autoCreate = self.db and self.db.global and self.db.global.autoCreateProfiles
        if autoCreate == nil then autoCreate = true end
        
        if isSpecific and assignedProfile and assignedProfile == activeProfile then
            self.autoLinkInfo:SetText("|cff33cc33" .. L["[Linked]"] .. "|r " .. L["Profile matched to loadout"])
        elseif isSpecific and assignedProfile then
            self.autoLinkInfo:SetText("|cffff9900" .. L["[Override]"] .. "|r " .. format(L["Loadout expects: %s"], assignedProfile))
        elseif not isSpecific and loadoutID > 0 then
            if autoCreate then
                self.autoLinkInfo:SetText("|cff888888" .. L["[Unassigned]"] .. "|r " .. L["Will auto-create on switch"])
            else
                self.autoLinkInfo:SetText("|cff888888" .. L["[Unassigned]"] .. "|r " .. L["Auto-create disabled"])
            end
        else
            self.autoLinkInfo:SetText("|cff888888" .. L["[Unassigned]"] .. "|r " .. L["No loadout detected"])
        end
    end
end

function CC:RefreshLoadoutAssignments()
    if not self.loadoutContent then return end
    
    local C = self.UI_COLORS
    local themeColor = C.theme
    
    -- Update content width
    if self.loadoutScroll then
        local scrollWidth = self.loadoutScroll:GetWidth()
        if scrollWidth and scrollWidth > 0 then
            self.loadoutContent:SetWidth(scrollWidth - 10)
        else
            self.loadoutContent:SetWidth(200)  -- Fallback width
        end
    end
    
    -- Clear existing
    for _, child in ipairs({self.loadoutContent:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local yOffset = 0
    local profiles = self:GetProfileList()
    local numSpecs = self:GetNumSpecs()
    
    for specIndex = 1, numSpecs do
        local _, specName, _, specIcon = GetSpecializationInfo(specIndex)
        if specName then
            -- Spec header
            local specHeader = CreateFrame("Frame", nil, self.loadoutContent, "BackdropTemplate")
            specHeader:SetPoint("TOPLEFT", 0, -yOffset)
            specHeader:SetPoint("RIGHT", 0, 0)
            specHeader:SetHeight(24)
            specHeader:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
            specHeader:SetBackdropColor(0.12, 0.12, 0.12, 1)
            
            local icon = specHeader:CreateTexture(nil, "ARTWORK")
            icon:SetSize(18, 18)
            icon:SetPoint("LEFT", 4, 0)
            icon:SetTexture(specIcon)
            
            local specText = specHeader:CreateFontString(nil, "OVERLAY", "DFFontNormal")
            specText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
            specText:SetText(specName)
            specText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            
            yOffset = yOffset + 26
            
            -- Get loadouts for this spec
            local loadouts = self:GetSpecLoadouts(specIndex)
            
            -- Always show spec default row (fallback when no specific loadout matches)
            local row = self:CreateLoadoutRow(self.loadoutContent, specIndex, 0, L["Spec Default"], profiles, yOffset)
            yOffset = yOffset + 24
            
            -- Show individual loadout rows if any exist
            for _, loadout in ipairs(loadouts) do
                local row = self:CreateLoadoutRow(self.loadoutContent, specIndex, loadout.configID, loadout.name, profiles, yOffset)
                yOffset = yOffset + 24
            end
            
            yOffset = yOffset + 4  -- Spacing between specs
        end
    end
    
    self.loadoutContent:SetHeight(math.max(yOffset, 1))
end

function CC:CreateLoadoutRow(parent, specIndex, configID, loadoutName, profiles, yOffset)
    local C = self.UI_COLORS
    local themeColor = C.theme
    
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", 12, -yOffset)  -- Reduced indent
    row:SetPoint("RIGHT", -4, 0)
    row:SetHeight(22)
    
    -- Profile dropdown button (create first so nameText can anchor to it)
    -- Use noFallback=true to only show specifically assigned profiles
    local assignedProfile = self:GetProfileForLoadout(specIndex, configID, true)
    
    local dropBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
    dropBtn:SetPoint("RIGHT", 0, 0)
    dropBtn:SetSize(115, 18)  -- Reduced width to give more space for loadout name
    dropBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    
    if assignedProfile then
        dropBtn:SetBackdropColor(themeColor.r * 0.2, themeColor.g * 0.2, themeColor.b * 0.2, 1)
        dropBtn:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
    else
        dropBtn:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
        dropBtn:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
    end
    
    -- Truncate text helper
    local function TruncText(text, maxLen)
        if not text or #text <= maxLen then return text or "" end
        return string.sub(text, 1, maxLen - 2) .. ".."
    end
    
    local dropText = dropBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    dropText:SetPoint("LEFT", 4, 0)
    dropText:SetPoint("RIGHT", -14, 0)
    dropText:SetJustifyH("LEFT")
    dropText:SetWordWrap(false)
    local displayText = assignedProfile and TruncText(assignedProfile, 14) or L["Not Set"]
    dropText:SetText(displayText)
    dropText:SetTextColor(assignedProfile and themeColor.r or C.textDim.r, assignedProfile and themeColor.g or C.textDim.g, assignedProfile and themeColor.b or C.textDim.b)
    
    -- Dropdown arrow
    local arrow = dropBtn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -4, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    arrow:SetVertexColor(C.textDim.r, C.textDim.g, C.textDim.b)
    
    -- Name text (constrained to not overlap button)
    local nameText = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    nameText:SetPoint("LEFT", 0, 0)
    nameText:SetPoint("RIGHT", dropBtn, "LEFT", -4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    -- Truncate loadout name if needed
    local displayName = loadoutName
    if #loadoutName > 12 then
        displayName = string.sub(loadoutName, 1, 10) .. ".."
    end
    nameText:SetText(displayName)
    nameText:SetTextColor(C.text.r, C.text.g, C.text.b)
    
    dropBtn:SetScript("OnClick", function(self)
        -- Close any existing dropdown
        if CC.loadoutDropdownMenu and CC.loadoutDropdownMenu:IsShown() then
            CC.loadoutDropdownMenu:Hide()
            if CC.loadoutDropdownMenu.forButton == self then
                return  -- Toggle off
            end
        end
        
        -- Create dropdown menu
        local menu = CC.loadoutDropdownMenu
        if not menu then
            menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            menu:SetFrameStrata("FULLSCREEN_DIALOG")
            menu:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            menu:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
            menu:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 1)
            menu:SetClampedToScreen(true)
            menu.items = {}
            CC.loadoutDropdownMenu = menu
            
            -- Close when clicking elsewhere
            menu:SetScript("OnShow", function()
                menu:SetPropagateKeyboardInput(true)
            end)
        end
        
        -- Clear existing items
        for _, item in ipairs(menu.items) do
            item:Hide()
        end
        wipe(menu.items)
        
        -- Build menu items
        local menuItems = {}
        -- Only show "Clear Assignment" if there's currently an assignment
        if assignedProfile then
            table.insert(menuItems, { text = "|cff888888Clear Assignment|r", value = nil, isClear = true })
        end
        for _, profileName in ipairs(profiles) do
            table.insert(menuItems, { text = profileName, value = profileName })
        end
        
        local itemHeight = 20
        local maxWidth = 140
        
        for i, itemData in ipairs(menuItems) do
            local item = CreateFrame("Button", nil, menu, "BackdropTemplate")
            item:SetHeight(itemHeight)
            item:SetPoint("TOPLEFT", 2, -2 - (i-1) * itemHeight)
            item:SetPoint("RIGHT", -2, 0)
            
            local itemText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            itemText:SetPoint("LEFT", 6, 0)
            itemText:SetPoint("RIGHT", -6, 0)
            itemText:SetJustifyH("LEFT")
            itemText:SetText(itemData.text)
            
            local isSelected = (itemData.value == assignedProfile) or (itemData.value == nil and assignedProfile == nil)
            if isSelected then
                itemText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            else
                itemText:SetTextColor(C.text.r, C.text.g, C.text.b)
            end
            
            item:SetScript("OnEnter", function(self)
                self:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
                self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            end)
            item:SetScript("OnLeave", function(self)
                self:SetBackdrop(nil)
            end)
            item:SetScript("OnClick", function()
                CC:AssignProfileToLoadout(specIndex, configID, itemData.value)
                CC:RefreshLoadoutAssignments()
                menu:Hide()
            end)
            
            table.insert(menu.items, item)
        end
        
        -- Size and position the menu
        menu:SetSize(maxWidth, #menuItems * itemHeight + 4)
        menu:ClearAllPoints()
        menu:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -2)
        menu.forButton = self
        menu:Show()
        menu:Raise()
        
        -- Close on any click outside
        local closeFrame = CreateFrame("Button", nil, UIParent)
        closeFrame:SetAllPoints(UIParent)
        closeFrame:SetFrameStrata("FULLSCREEN")
        closeFrame:SetScript("OnClick", function()
            menu:Hide()
            closeFrame:Hide()
        end)
        closeFrame:Show()
        menu.closeFrame = closeFrame
        menu:SetScript("OnHide", function()
            if menu.closeFrame then
                menu.closeFrame:Hide()
            end
        end)
    end)
    
    dropBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
        if assignedProfile then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(format(L["Profile: %s"], assignedProfile), 1, 1, 1)
            GameTooltip:AddLine(L["Click to change assignment"], 0.7, 0.7, 0.7)
            GameTooltip:Show()
        else
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            if configID == 0 then
                GameTooltip:SetText(L["No default profile set"], 1, 1, 1)
                GameTooltip:AddLine("Click to assign a profile that activates", 0.7, 0.7, 0.7)
                GameTooltip:AddLine("when switching to this spec", 0.7, 0.7, 0.7)
            else
                GameTooltip:SetText(L["Using spec default"], 1, 1, 1)
                GameTooltip:AddLine("Click to assign a specific profile", 0.7, 0.7, 0.7)
            end
            GameTooltip:Show()
        end
    end)
    dropBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        if assignedProfile then
            self:SetBackdropBorderColor(themeColor.r * 0.6, themeColor.g * 0.6, themeColor.b * 0.6, 1)
        else
            self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 0.5)
        end
    end)
    
    return row
end

-- =========================================================================

-- PROFILE DIALOGS
-- =========================================================================

-- Helper to show StaticPopup and raise it above our UI
local function ShowPopupOnTop(popupName)
    local dialog = StaticPopup_Show(popupName)
    if dialog then
        dialog:SetFrameStrata("FULLSCREEN_DIALOG")
        dialog:Raise()
    end
    return dialog
end

-- Export to CC namespace for use in other UI files
CC.ShowPopupOnTop = ShowPopupOnTop

function CC:ShowNewProfileDialog()
    StaticPopupDialogs["DFCC_NEW_PROFILE"] = {
        text = L["Enter new profile name:"],
        button1 = L["Create"],
        button2 = L["Cancel"],
        hasEditBox = true,
        editBoxWidth = 200,
        OnAccept = function(self)
            local name = self.EditBox:GetText()
            if name and name ~= "" then
                if CC:CreateProfile(name, CC:GetActiveProfileName()) then
                    CC:RefreshProfilesPanel()
                end
            end
        end,
        OnShow = function(self)
            self.EditBox:SetText("")
            self.EditBox:SetFocus()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_NEW_PROFILE")
end

function CC:ShowCopyProfileDialog(sourceName)
    StaticPopupDialogs["DFCC_COPY_PROFILE"] = {
        text = format(L["Enter name for copy of '%s':"], sourceName),
        button1 = L["Copy"],
        button2 = L["Cancel"],
        hasEditBox = true,
        editBoxWidth = 200,
        OnAccept = function(self)
            local name = self.EditBox:GetText()
            if name and name ~= "" then
                if CC:CreateProfile(name, sourceName) then
                    CC:RefreshProfilesPanel()
                end
            end
        end,
        OnShow = function(self)
            self.EditBox:SetText(sourceName .. " Copy")
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_COPY_PROFILE")
end

function CC:ShowRenameProfileDialog(oldName)
    StaticPopupDialogs["DFCC_RENAME_PROFILE"] = {
        text = format(L["Enter new name for '%s':"], oldName),
        button1 = L["Rename"],
        button2 = L["Cancel"],
        hasEditBox = true,
        editBoxWidth = 200,
        OnAccept = function(self)
            local name = self.EditBox:GetText()
            if name and name ~= "" and name ~= oldName then
                if CC:RenameProfile(oldName, name) then
                    CC.selectedProfileName = name
                    CC:RefreshProfilesPanel()
                end
            end
        end,
        OnShow = function(self)
            self.EditBox:SetText(oldName)
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_RENAME_PROFILE")
end

function CC:ShowDeleteProfileDialog(profileName)
    StaticPopupDialogs["DFCC_DELETE_PROFILE"] = {
        text = format(L["Delete profile '%s'?\n\nThis cannot be undone."], profileName),
        button1 = L["Delete"],
        button2 = L["Cancel"],
        OnAccept = function()
            if CC:DeleteProfile(profileName) then
                CC.selectedProfileName = nil
                CC:RefreshProfilesPanel()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_DELETE_PROFILE")
end

function CC:ShowClearAllConfirmation()
    local bindingCount = self.profile and self.profile.bindings and #self.profile.bindings or 0
    local profileName = self.currentProfileName or "Default"
    
    if bindingCount == 0 then
        print("|cffff9900DandersFrames:|r No bindings to clear.")
        return
    end
    
    StaticPopupDialogs["DFCC_CLEAR_ALL_BINDINGS"] = {
        text = format(L["Reset all bindings to defaults?\n\nThis will set:\n• Left Click = Target Unit\n• Right Click = Open Menu\n\n%sThis cannot be undone.%s"], "|cffff6666", "|r"),
        button1 = L["Reset to Defaults"],
        button2 = L["Cancel"],
        OnAccept = function()
            CC:ResetBindingsToDefaults()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_CLEAR_ALL_BINDINGS")
end

-- Reset bindings to Blizzard-style defaults (Target + Menu)
-- Same as what Blizzard uses when you reset click-casting
function CC:ResetBindingsToDefaults()
    if not self.profile then return end
    
    local count = #self.profile.bindings
    
    -- Clear all bindings
    wipe(self.profile.bindings)
    
    -- Add default bindings (same as Blizzard defaults)
    -- Left Click = Target Unit
    table.insert(self.profile.bindings, {
        enabled = true,
        bindType = "mouse",
        button = "LeftButton",
        modifiers = "",
        actionType = "target",
        combat = "always",
        frames = { dandersFrames = true, otherFrames = true },
        fallback = { mouseover = false, target = false, selfCast = false },
    })
    
    -- Right Click = Open Menu
    table.insert(self.profile.bindings, {
        enabled = true,
        bindType = "mouse",
        button = "RightButton",
        modifiers = "",
        actionType = "menu",
        combat = "always",
        frames = { dandersFrames = true, otherFrames = true },
        fallback = { mouseover = false, target = false, selfCast = false },
    })
    
    -- Rebuild secure bindings
    self:BuildKeyboardBindingSnippets()
    
    -- Re-apply to all frames
    if not InCombatLockdown() then
        self:ApplyBindings()
    end
    
    -- Refresh the UI
    self:RefreshClickCastingUI()
    
    print("|cff33cc33DandersFrames:|r Reset bindings to defaults (Target + Menu). " .. count .. " custom binding(s) removed.")
end

-- Legacy function for compatibility
function CC:ClearAllBindings()
    self:ResetBindingsToDefaults()
end

function CC:ShowExportDialog()
    local exportString = self:ExportProfile()
    
    if not exportString or exportString == "" then
        -- Error message already printed by ExportProfile
        StaticPopupDialogs["DFCC_EXPORT_ERROR"] = {
            text = L["Export failed. Please try again or check for errors."],
            button1 = L["OK"],
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        ShowPopupOnTop("DFCC_EXPORT_ERROR")
        return
    end
    
    StaticPopupDialogs["DFCC_EXPORT_PROFILE"] = {
        text = L["Copy this string to share your profile:"],
        button1 = L["Done"],
        hasEditBox = true,
        editBoxWidth = 350,
        OnShow = function(self)
            self.EditBox:SetText(exportString)
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_EXPORT_PROFILE")
end

function CC:ShowImportDialog()
    StaticPopupDialogs["DFCC_IMPORT_PROFILE"] = {
        text = L["Paste a profile string to import:"],
        button1 = L["Import"],
        button2 = L["Cancel"],
        hasEditBox = true,
        editBoxWidth = 350,
        OnAccept = function(self)
            local importString = self.EditBox:GetText()
            if importString and importString ~= "" then
                local success, result = CC:ImportProfile(importString)
                if success then
                    print("|cff33cc33DandersFrames:|r Profile imported: " .. result)
                    CC:RefreshProfilesPanel()
                else
                    print("|cffff0000DandersFrames:|r Import failed: " .. (result or "unknown error"))
                end
            end
        end,
        OnShow = function(self)
            self.EditBox:SetText("")
            self.EditBox:SetFocus()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    ShowPopupOnTop("DFCC_IMPORT_PROFILE")
end

-- =========================================================================
