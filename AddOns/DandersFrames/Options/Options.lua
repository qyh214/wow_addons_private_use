local addonName, DF = ...
local format = string.format

-- ============================================================
-- GUI PAGE SETUP - Collapsible Category System
-- ============================================================

function DF:SetupGUIPages(GUI, CreateCategory, CreateSubTab, BuildPage)
    local L = DF.L
    
    -- Helper function to create a themed "Copy to Raid/Party" button for a section
    local function CreateCopyButton(parent, prefixes, sectionName, pageId)
        -- Register section in the sync registry
        if pageId then
            DF.SectionRegistry[pageId] = prefixes
        end

        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(115, 26)
        
        -- Apply element backdrop style
        if not btn.SetBackdrop then Mixin(btn, BackdropTemplateMixin) end
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        
        -- Icon
        btn.Icon = btn:CreateTexture(nil, "OVERLAY")
        btn.Icon:SetPoint("LEFT", 8, 0)
        btn.Icon:SetSize(14, 14)
        btn.Icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\content_copy")
        
        -- Text
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btn.Text:SetPoint("LEFT", btn.Icon, "RIGHT", 4, 0)
        
        -- Sync toggle button
        local linkBtn
        if pageId then
            linkBtn = CreateFrame("Button", nil, btn, "BackdropTemplate")
            linkBtn:SetSize(120, 26)
            linkBtn:SetPoint("RIGHT", btn, "LEFT", -4, 0)

            if not linkBtn.SetBackdrop then Mixin(linkBtn, BackdropTemplateMixin) end
            linkBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })

            linkBtn.Icon = linkBtn:CreateTexture(nil, "OVERLAY")
            linkBtn.Icon:SetPoint("LEFT", 8, 0)
            linkBtn.Icon:SetSize(14, 14)
            linkBtn.Icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\refresh")

            linkBtn.Text = linkBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            linkBtn.Text:SetPoint("LEFT", linkBtn.Icon, "RIGHT", 4, 0)
        end

        -- Update appearance based on current mode
        local function UpdateAppearance()
            local mode = GUI.SelectedMode or "party"
            local themeColor = GUI.GetThemeColor()
            
            if mode == "party" then
                btn.Text:SetText(L["Copy to Raid"])
            else
                btn.Text:SetText(L["Copy to Party"])
            end
            
            -- Normal state colors
            btn:SetBackdropColor(0.18, 0.18, 0.18, 1)
            btn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)
            btn.Text:SetTextColor(0.6, 0.6, 0.6)
            btn.Icon:SetVertexColor(0.6, 0.6, 0.6)

            -- Update sync button appearance
            if linkBtn then
                local dest = mode == "party" and L["Raid"] or L["Party"]
                local isLinked = DF.db and DF.db.linkedSections and DF.db.linkedSections[pageId]
                if isLinked then
                    linkBtn.Text:SetText(format(L["Synced with %s"], dest))
                    linkBtn:SetBackdropColor(themeColor.r * 0.2, themeColor.g * 0.2, themeColor.b * 0.2, 1)
                    linkBtn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
                    linkBtn.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
                    linkBtn.Icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
                else
                    linkBtn.Text:SetText(format(L["Sync with %s"], dest))
                    linkBtn:SetBackdropColor(0.18, 0.18, 0.18, 1)
                    linkBtn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)
                    linkBtn.Text:SetTextColor(0.6, 0.6, 0.6)
                    linkBtn.Icon:SetVertexColor(0.6, 0.6, 0.6)
                end
            end
        end
        
        -- Store for refresh
        btn.UpdateModeText = UpdateAppearance
        btn.rightAlign = true  -- Flag for layout system
        
        -- Hover effects
        btn:SetScript("OnEnter", function(self)
            local themeColor = GUI.GetThemeColor()
            self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            self.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            self.Icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
            
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local mode = GUI.SelectedMode or "party"
            local src = mode == "party" and L["Party"] or L["Raid"]
            local dest = mode == "party" and L["Raid"] or L["Party"]
            GameTooltip:SetText(format(L["Copy %s Settings"], sectionName))
            GameTooltip:AddLine(format(L["Copies these settings from %s to %s."], src, dest), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        
        btn:SetScript("OnLeave", function(self)
            UpdateAppearance()
            GameTooltip:Hide()
        end)
        
        btn:SetScript("OnClick", function()
            local mode = GUI.SelectedMode or "party"
            local dest = mode == "party" and L["Raid"] or L["Party"]
            -- Show confirmation
            StaticPopupDialogs["DANDERSFRAMES_COPY_SECTION"] = {
                text = format(L["Copy %s settings to %s?"], sectionName, dest),
                button1 = L["Copy"],
                button2 = L["Cancel"],
                OnAccept = function()
                    DF:CopySectionSettings(prefixes, mode)
                    if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("DANDERSFRAMES_COPY_SECTION")
        end)

        -- Sync button event handlers
        if linkBtn then
            linkBtn:SetScript("OnEnter", function(self)
                local themeColor = GUI.GetThemeColor()
                local isLinked = DF.db and DF.db.linkedSections and DF.db.linkedSections[pageId]
                self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
                self.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
                self.Icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)

                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if isLinked then
                    GameTooltip:SetText(format(L["Synced: %s"], sectionName))
                    GameTooltip:AddLine(format(L["Party & Raid %s settings are synced.\nClick to stop syncing."], sectionName), 1, 1, 1, true)
                else
                    GameTooltip:SetText(format(L["Sync: %s"], sectionName))
                    GameTooltip:AddLine(format(L["Click to sync Party & Raid %s settings.\nChanges in one mode will automatically apply to the other."], sectionName), 1, 1, 1, true)
                end
                GameTooltip:Show()
            end)

            linkBtn:SetScript("OnLeave", function()
                UpdateAppearance()
                GameTooltip:Hide()
            end)

            linkBtn:SetScript("OnClick", function()
                if not DF.db then return end
                if not DF.db.linkedSections then DF.db.linkedSections = {} end

                if DF.db.linkedSections[pageId] then
                    DF.db.linkedSections[pageId] = nil
                    UpdateAppearance()
                else
                    local mode = GUI.SelectedMode or "party"
                    local dest = mode == "party" and L["Raid"] or L["Party"]
                    StaticPopupDialogs["DANDERSFRAMES_LINK_SECTION"] = {
                        text = format(L["Sync %s settings?\n\nThis will copy current %s settings to %s and keep them in sync."], sectionName, sectionName, dest),
                        button1 = L["Sync"],
                        button2 = L["Cancel"],
                        OnAccept = function()
                            DF.db.linkedSections[pageId] = true
                            DF:CopySectionSettings(prefixes, mode)
                            if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                    }
                    StaticPopup_Show("DANDERSFRAMES_LINK_SECTION")
                end
            end)
        end
        
        -- Initial update
        UpdateAppearance()
        
        -- Register for theme updates
        if not parent.ThemeListeners then parent.ThemeListeners = {} end
        table.insert(parent.ThemeListeners, {UpdateTheme = UpdateAppearance})
        
        return btn
    end

    -- Expose for use by sub-pages (e.g. Aura Designer)
    GUI.CreateCopyButton = CreateCopyButton

    -- Define category order (updated structure)
    GUI.CategoryOrder = {"general", "clickcast", "display", "bars", "text", "auras", "indicators", "profiles", "debug"}
    
    -- ========================================
    -- CATEGORY: General
    -- ========================================
    CreateCategory("general", L["General"])
    
    -- ========================================
    -- CATEGORY: Display (new top-level category)
    -- ========================================
    CreateCategory("display", L["Display"])
    
    -- Display > Visibility
    local pageVisibility = CreateSubTab("display", "display_visibility", L["Visibility"])
    BuildPage(pageVisibility, function(self, db, Add, AddSpace, AddSyncPoint)
        
        -- ===== FRAME DISPLAY GROUP (Column 1) =====
        local frameDisplayGroup = GUI:CreateSettingsGroup(self.child, 280)
        frameDisplayGroup:AddWidget(GUI:CreateHeader(self.child, L["Frame Display"]), 40)
        
        local soloMode = frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Solo Mode"], db, "soloMode", function()
            DF:UpdateAllFrames()
            DF:UpdateDefaultPlayerFrame()
        end), 30)
        soloMode.hideOn = function() return GUI.SelectedMode == "raid" end
        
        frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Minimap Button"], db, "showMinimapButton", function()
            DF:UpdateMinimapButton()
        end), 30)
        
        local restedIndicator = frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Rested Indicator"], db, "restedIndicator", function()
            DF:UpdateRestedIndicator()
        end), 30)
        restedIndicator.hideOn = function() return GUI.SelectedMode == "raid" end
        restedIndicator.disableOn = function(d) return not d.soloMode end
        restedIndicator.tooltip = L["Show rested indicators when in a rested area (inn, city)."]
        
        local restedIcon = frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["    Show ZZZ Icon"], db, "restedIndicatorIcon", function()
            DF:UpdateRestedIndicator()
        end), 30)
        restedIcon.hideOn = function() return GUI.SelectedMode == "raid" end
        restedIcon.disableOn = function(d) return not d.soloMode or not d.restedIndicator end
        restedIcon.tooltip = L["Show the animated ZZZ icon on the player frame."]
        
        local restedGlow = frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["    Show Frame Glow"], db, "restedIndicatorGlow", function()
            DF:UpdateRestedIndicator()
        end), 30)
        restedGlow.hideOn = function() return GUI.SelectedMode == "raid" end
        restedGlow.disableOn = function(d) return not d.soloMode or not d.restedIndicator end
        restedGlow.tooltip = L["Show a pulsing yellow glow around the frame."]
        
        local soloNote = frameDisplayGroup:AddWidget(GUI:CreateLabel(self.child, L["Solo Mode: Show your player frame when not in a group."], 250), 30)
        soloNote.hideOn = function() return GUI.SelectedMode == "raid" end
        
        local hidePlayer = frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Self from Party Frames"], db, "hidePlayerFrame", function()
            -- Update the secure header's showPlayer attribute
            if not InCombatLockdown() and DF.partyHeader then
                DF.partyHeader:SetAttribute("showPlayer", not db.hidePlayerFrame)
            end
            -- Reapply header settings to reposition frames
            if DF.ApplyHeaderSettings then
                DF:ApplyHeaderSettings()
            end
            DF:UpdateAllFrames()
        end), 30)
        hidePlayer.hideOn = function() return GUI.SelectedMode == "raid" end
        hidePlayer.tooltip = L["Removes your player frame from the DandersFrames party display."]

        local hideDefaultPlayer = frameDisplayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Blizzard Player Frame"], db, "hideDefaultPlayerFrame", function()
            DF:UpdateDefaultPlayerFrame()
        end), 30)
        hideDefaultPlayer.tooltip = L["Hides the default Blizzard player portrait and health bar."]

        Add(frameDisplayGroup, nil, 1)
    end)
    
    -- Display > Tooltips (moved from General)
    local pageTooltips = CreateSubTab("display", "display_tooltips", L["Tooltips"])
    BuildPage(pageTooltips, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top right (positioned automatically via rightAlign)
        Add(CreateCopyButton(self.child, {"tooltip"}, L["Tooltips"], "display_tooltips"), 25, 2)
        
        -- Anchor position values (shared)
        local anchorPositionValues = {
            TOPLEFT = L["Top Left"],
            TOP = L["Top"],
            TOPRIGHT = L["Top Right"],
            LEFT = L["Left"],
            CENTER = L["Center"],
            RIGHT = L["Right"],
            BOTTOMLEFT = L["Bottom Left"],
            BOTTOM = L["Bottom"],
            BOTTOMRIGHT = L["Bottom Right"],
        }
        
        -- ===== ROW 1: Frame Tooltips + Buff Tooltips =====
        
        -- Frame Tooltips (Column 1)
        local frameTooltipGroup = GUI:CreateSettingsGroup(self.child, 280)
        frameTooltipGroup:AddWidget(GUI:CreateHeader(self.child, L["Frame Tooltips"]), 40)
        frameTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Frame Tooltips"], db, "tooltipFrameEnabled", nil), 30)
        frameTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Disable in Combat"], db, "tooltipFrameDisableInCombat", function() end), 30)
        
        local frameAnchorValues = {
            DEFAULT = L["Game Default"],
            CURSOR = L["Cursor"],
            FRAME = L["Unit Frame"],
        }
        frameTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor To"], frameAnchorValues, db, "tooltipFrameAnchor", function() GUI:RefreshCurrentPage() end), 55)
        
        local frameAnchorPos = frameTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Position"], anchorPositionValues, db, "tooltipFrameAnchorPos", function() end), 55)
        frameAnchorPos.disableOn = function(d) return d.tooltipFrameAnchor == "DEFAULT" end
        
        local frameOffsetX = frameTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -100, 100, 1, db, "tooltipFrameX", function() end), 55)
        frameOffsetX.disableOn = function(d) return d.tooltipFrameAnchor ~= "FRAME" end
        
        local frameOffsetY = frameTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -100, 100, 1, db, "tooltipFrameY", function() end), 55)
        frameOffsetY.disableOn = function(d) return d.tooltipFrameAnchor ~= "FRAME" end
        
        Add(frameTooltipGroup, nil, 1)
        
        -- Buff Tooltips (Column 2)
        local buffTooltipGroup = GUI:CreateSettingsGroup(self.child, 280)
        buffTooltipGroup:AddWidget(GUI:CreateHeader(self.child, L["Buff Tooltips"]), 40)
        buffTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Buff Tooltips"], db, "tooltipBuffEnabled", nil), 30)
        buffTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Disable in Combat"], db, "tooltipBuffDisableInCombat", function() end), 30)
        
        local buffAnchorValues = {
            DEFAULT = L["Game Default"],
            CURSOR = L["Cursor"],
            FRAME = L["Buff Icon"],
        }
        buffTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor To"], buffAnchorValues, db, "tooltipBuffAnchor", function() GUI:RefreshCurrentPage() end), 55)
        
        local buffAnchorPos = buffTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Position"], anchorPositionValues, db, "tooltipBuffAnchorPos", function() end), 55)
        buffAnchorPos.disableOn = function(d) return d.tooltipBuffAnchor == "DEFAULT" end
        
        local buffOffsetX = buffTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "tooltipBuffX", function() end), 55)
        buffOffsetX.disableOn = function(d) return d.tooltipBuffAnchor ~= "FRAME" end
        
        local buffOffsetY = buffTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "tooltipBuffY", function() end), 55)
        buffOffsetY.disableOn = function(d) return d.tooltipBuffAnchor ~= "FRAME" end
        
        Add(buffTooltipGroup, nil, 2)
        
        -- Sync point: align row 2 to start at the same level
        AddSyncPoint()
        
        -- ===== ROW 2: Debuff Tooltips + Defensive Icon Tooltips =====
        
        -- Debuff Tooltips (Column 1)
        local debuffTooltipGroup = GUI:CreateSettingsGroup(self.child, 280)
        debuffTooltipGroup:AddWidget(GUI:CreateHeader(self.child, L["Debuff Tooltips"]), 40)
        debuffTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Debuff Tooltips"], db, "tooltipDebuffEnabled", nil), 30)
        debuffTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Disable in Combat"], db, "tooltipDebuffDisableInCombat", function() end), 30)
        
        local debuffAnchorValues = {
            DEFAULT = L["Game Default"],
            CURSOR = L["Cursor"],
            FRAME = L["Debuff Icon"],
        }
        debuffTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor To"], debuffAnchorValues, db, "tooltipDebuffAnchor", function() GUI:RefreshCurrentPage() end), 55)
        
        local debuffAnchorPos = debuffTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Position"], anchorPositionValues, db, "tooltipDebuffAnchorPos", function() end), 55)
        debuffAnchorPos.disableOn = function(d) return d.tooltipDebuffAnchor == "DEFAULT" end
        
        local debuffOffsetX = debuffTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "tooltipDebuffX", function() end), 55)
        debuffOffsetX.disableOn = function(d) return d.tooltipDebuffAnchor ~= "FRAME" end
        
        local debuffOffsetY = debuffTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "tooltipDebuffY", function() end), 55)
        debuffOffsetY.disableOn = function(d) return d.tooltipDebuffAnchor ~= "FRAME" end
        
        Add(debuffTooltipGroup, nil, 1)
        
        -- Defensive Icon Tooltips (Column 2)
        local defTooltipGroup = GUI:CreateSettingsGroup(self.child, 280)
        defTooltipGroup:AddWidget(GUI:CreateHeader(self.child, L["Defensive Icon Tooltips"]), 40)
        defTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Defensive Icon Tooltips"], db, "tooltipDefensiveEnabled", nil), 30)
        defTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Disable in Combat"], db, "tooltipDefensiveDisableInCombat", function() end), 30)
        
        local defAnchorValues = {
            DEFAULT = L["Game Default"],
            CURSOR = L["Cursor"],
            FRAME = L["Defensive Icon"],
        }
        defTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor To"], defAnchorValues, db, "tooltipDefensiveAnchor", function() GUI:RefreshCurrentPage() end), 55)
        
        local defAnchorPos = defTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Position"], anchorPositionValues, db, "tooltipDefensiveAnchorPos", function() end), 55)
        defAnchorPos.disableOn = function(d) return d.tooltipDefensiveAnchor == "DEFAULT" end
        
        local defOffsetX = defTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -100, 100, 1, db, "tooltipDefensiveX", function() end), 55)
        defOffsetX.disableOn = function(d) return d.tooltipDefensiveAnchor ~= "FRAME" end
        
        local defOffsetY = defTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -100, 100, 1, db, "tooltipDefensiveY", function() end), 55)
        defOffsetY.disableOn = function(d) return d.tooltipDefensiveAnchor ~= "FRAME" end
        
        Add(defTooltipGroup, nil, 2)

        -- Resurrection Icon Tooltips (Column 3)
        local resTooltipGroup = GUI:CreateSettingsGroup(self.child, 280)
        resTooltipGroup:AddWidget(GUI:CreateHeader(self.child, L["Resurrection Icon Tooltips"]), 40)
        resTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Resurrection Icon Tooltips"], db, "tooltipResurrectionEnabled", nil), 30)
        Add(resTooltipGroup, nil, 2)

        -- Sync point: align row 3
        AddSyncPoint()

        -- ===== ROW 3: Binding Tooltips =====

        -- Binding Tooltips (Column 1)
        local bindTooltipGroup = GUI:CreateSettingsGroup(self.child, 280)
        bindTooltipGroup:AddWidget(GUI:CreateHeader(self.child, L["Binding Tooltips"]), 40)
        bindTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Binding Tooltips"], db, "tooltipBindingEnabled", nil), 30)
        bindTooltipGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Disable in Combat"], db, "tooltipBindingDisableInCombat", function() end), 30)

        local bindAnchorValues = {
            DEFAULT = L["Game Default"],
            CURSOR = L["Cursor"],
            FRAME = L["Unit Frame"],
        }
        bindTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor To"], bindAnchorValues, db, "tooltipBindingAnchor", function() GUI:RefreshCurrentPage() end), 55)

        local bindAnchorPos = bindTooltipGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Position"], anchorPositionValues, db, "tooltipBindingAnchorPos", function() end), 55)
        bindAnchorPos.disableOn = function(d) return d.tooltipBindingAnchor == "DEFAULT" end

        local bindOffsetX = bindTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -100, 100, 1, db, "tooltipBindingX", function() end), 55)
        bindOffsetX.disableOn = function(d) return d.tooltipBindingAnchor ~= "FRAME" end

        local bindOffsetY = bindTooltipGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -100, 100, 1, db, "tooltipBindingY", function() end), 55)
        bindOffsetY.disableOn = function(d) return d.tooltipBindingAnchor ~= "FRAME" end

        Add(bindTooltipGroup, nil, 1)

        -- Sync point before See Also
        AddSyncPoint()
        AddSpace(20, "both")

        -- See Also links
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_buffs", label = L["Buffs"]},
            {pageId = "auras_debuffs", label = L["Debuffs"]},
            {pageId = "auras_bossdebuffs", label = L["Boss Debuffs"]},
            {pageId = "auras_defensiveicon", label = L["Defensive Icon"]},
        }), 30, "both")
    end)
    
    -- Display > Fading (moved from Indicators > Out of Range + Dead/Offline fading)
    local pageFading = CreateSubTab("display", "display_fading", L["Fading"])
    BuildPage(pageFading, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top right
        Add(CreateCopyButton(self.child, {"rangeFade", "oor", "dead", "offline", "healthFade", "hf"}, L["Fading"], "display_fading"), 25, 2)
        
        -- Sync point: ensures both columns start below the copy button
        AddSpace(10, "both")
        
        -- Helper to check if element options should be hidden
        local function HideOOROptions(d)
            return not d.oorEnabled
        end
        
        -- Helper to check if frame-level alpha should be hidden (when element-specific is enabled)
        local function HideFrameLevelAlpha(d)
            return d.oorEnabled
        end
        
        -- ===== OUT OF RANGE GROUP (Column 1) =====
        local oorGroup = GUI:CreateSettingsGroup(self.child, 280)
        oorGroup:AddWidget(GUI:CreateHeader(self.child, L["Out of Range"]), 40)
        
        -- Build dropdown options dynamically
        local function GetRangeSpellDropdownOptions()
            local options = {}
            if DF.GetRangeSpellOptions then
                local spellOptions = DF:GetRangeSpellOptions()
                for _, opt in ipairs(spellOptions) do
                    options[opt.value] = opt.label
                end
            else
                options[0] = L["Auto (Spec Default)"]
            end
            return options
        end
        
        -- Ensure db value is not nil (default to 0 = Auto)
        if db.rangeCheckSpellID == nil then
            db.rangeCheckSpellID = 0
        end
        
        -- Helper to refresh info label
        local function RefreshRangeInfoLabel()
            if self.rangeSpellInfoLabel and self.rangeSpellInfoLabel.SetText and DF.GetCurrentRangeSpellInfo then
                local info = DF:GetCurrentRangeSpellInfo()
                self.rangeSpellInfoLabel:SetText("|cFFAAAAAA" .. "Active: " .. (info.spellName or "None") .. " (" .. (info.range or "?") .. ")|r")
            end
        end
        
        -- Set value callback - called AFTER dropdown has already set db.rangeCheckSpellID
        local function SetRangeSpellValue()
            local value = db.rangeCheckSpellID or 0
            if DF.SetRangeCheckSpell then
                DF:SetRangeCheckSpell(value)
            end
            RefreshRangeInfoLabel()
            if self.rangeSpellInput and self.rangeSpellInput.EditBox then
                self.rangeSpellInput.EditBox:SetText("")
            end
        end
        
        -- Range Check Spell row
        local rangeSpellDropdown = oorGroup:AddWidget(GUI:CreateDropdown(self.child, L["Range Check Spell"], GetRangeSpellDropdownOptions(), db, "rangeCheckSpellID", SetRangeSpellValue), 55)
        rangeSpellDropdown.tooltip = L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."]
        
        -- Custom Spell ID Input
        local customSpellInput = oorGroup:AddWidget(GUI:CreateInput(self.child, L["Custom Spell ID"], 120), 55)
        customSpellInput.tooltip = L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."]
        self.rangeSpellInput = customSpellInput
        
        -- Set initial value if it's a custom spell not in dropdown
        if db.rangeCheckSpellID and db.rangeCheckSpellID > 0 then
            local isInDropdown = false
            if DF.GetRangeSpellOptions then
                for _, opt in ipairs(DF:GetRangeSpellOptions()) do
                    if opt.value == db.rangeCheckSpellID then
                        isInDropdown = true
                        break
                    end
                end
            end
            if not isInDropdown then
                customSpellInput.EditBox:SetText(tostring(db.rangeCheckSpellID))
            end
        end
        
        customSpellInput.EditBox:SetNumeric(true)
        customSpellInput.EditBox:SetMaxLetters(8)
        
        local function ApplyCustomSpellID()
            local text = customSpellInput.EditBox:GetText()
            local spellID = tonumber(text)
            
            if not text or text == "" then
                return
            end
            
            if spellID and spellID > 0 then
                local spellName = C_Spell.GetSpellName(spellID)
                if spellName then
                    db.rangeCheckSpellID = spellID
                    if DF.SetRangeCheckSpell then
                        DF:SetRangeCheckSpell(spellID)
                    end
                    RefreshRangeInfoLabel()
                    print("|cFF00FF00[DFRange]|r Custom spell set: " .. spellName .. " (ID: " .. spellID .. ")")
                else
                    print("|cFFFF0000[DFRange]|r Invalid spell ID: " .. spellID)
                    customSpellInput.EditBox:SetText("")
                end
            end
        end
        
        customSpellInput.EditBox:SetScript("OnEnterPressed", function(self)
            ApplyCustomSpellID()
            self:ClearFocus()
        end)
        customSpellInput.EditBox:SetScript("OnEditFocusLost", function(self)
            ApplyCustomSpellID()
        end)
        
        -- Info label showing current active spell
        local rangeInfoText = L["Loading..."]
        if DF.GetCurrentRangeSpellInfo then
            local rangeInfo = DF:GetCurrentRangeSpellInfo()
            rangeInfoText = (rangeInfo.spellName or "None") .. " (" .. (rangeInfo.range or "?") .. ")"
        end
        local infoLabel = oorGroup:AddWidget(GUI:CreateLabel(self.child, "|cFFAAAAAA" .. "Active: " .. rangeInfoText .. "|r", 250), 25)
        self.rangeSpellInfoLabel = infoLabel

        -- Range update interval
        if db.rangeUpdateInterval == nil then
            db.rangeUpdateInterval = 0.5
        end
        local intervalSlider = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Range Check Interval"], 0.1, 1.0, 0.05, db, "rangeUpdateInterval", nil, function()
            if DF.SetRangeUpdateInterval then
                DF:SetRangeUpdateInterval(db.rangeUpdateInterval)
            end
        end, true), 55)
        intervalSlider.tooltip = L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"]

        -- Frame-level alpha (shown when element-specific is disabled)
        local frameLevelAlpha = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Alpha (Out of Range)"], 0.1, 1.0, 0.05, db, "rangeFadeAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        frameLevelAlpha.hideOn = HideFrameLevelAlpha
        
        -- Element-specific toggle
        oorGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Element-Specific Alpha"], db, "oorEnabled", function()
            self:RefreshStates()
        end), 30)
        
        -- Element-specific sliders (shown when enabled)
        local oorHealth = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Health Bar Alpha"], 0.0, 1.0, 0.05, db, "oorHealthBarAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorHealth.hideOn = HideOOROptions
        
        local oorMissingHealth = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Missing Health Alpha"], 0.0, 1.0, 0.05, db, "oorMissingHealthAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorMissingHealth.hideOn = HideOOROptions

        local oorBg = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Background Alpha"], 0.0, 1.0, 0.05, db, "oorBackgroundAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorBg.hideOn = HideOOROptions
        
        local oorName = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Name Text Alpha"], 0.0, 1.0, 0.05, db, "oorNameTextAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorName.hideOn = HideOOROptions
        
        local oorHealthText = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Health Text Alpha"], 0.0, 1.0, 0.05, db, "oorHealthTextAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorHealthText.hideOn = HideOOROptions
        
        local oorAuras = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Auras Alpha"], 0.0, 1.0, 0.05, db, "oorAurasAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorAuras.hideOn = HideOOROptions
        
        local oorIcons = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Icons Alpha"], 0.0, 1.0, 0.05, db, "oorIconsAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorIcons.hideOn = HideOOROptions
        
        local oorDispel = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Dispel Overlay Alpha"], 0.0, 1.0, 0.05, db, "oorDispelOverlayAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorDispel.hideOn = HideOOROptions
        
        -- My Buff Indicator OOR slider removed — feature deprecated

        local oorPower = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Power Bar Alpha"], 0.0, 1.0, 0.05, db, "oorPowerBarAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorPower.hideOn = HideOOROptions
        
        local oorMissingBuff = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Missing Buff Alpha"], 0.0, 1.0, 0.05, db, "oorMissingBuffAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorMissingBuff.hideOn = HideOOROptions
        
        local oorDefensive = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Defensive Icon Alpha"], 0.0, 1.0, 0.05, db, "oorDefensiveIconAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorDefensive.hideOn = HideOOROptions
        
        local oorTargetedSpell = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Targeted Spell Alpha"], 0.0, 1.0, 0.05, db, "oorTargetedSpellAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorTargetedSpell.hideOn = HideOOROptions

        local oorAuraDesigner = oorGroup:AddWidget(GUI:CreateSlider(self.child, L["Aura Designer Alpha"], 0.0, 1.0, 0.05, db, "oorAuraDesignerAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        oorAuraDesigner.hideOn = HideOOROptions

        Add(oorGroup, nil, 1)
        
        -- ===== DEAD/OFFLINE FADING GROUP (Column 2) =====
        local deadGroup = GUI:CreateSettingsGroup(self.child, 280)
        deadGroup:AddWidget(GUI:CreateHeader(self.child, L["Dead/Offline Fading"]), 40)
        
        deadGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Dead Fade"], db, "fadeDeadFrames", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
            DF:RefreshAllVisibleFrames()
        end), 30)
        
        local function HideDeadOptions(d)
            return not d.fadeDeadFrames
        end
        
        local deadBgAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Background Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadBackground", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadBgAlpha.hideOn = HideDeadOptions
        
        local deadHealthAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Health Bar Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadHealthBar", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadHealthAlpha.hideOn = HideDeadOptions
        
        local deadNameAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Name Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadName", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadNameAlpha.hideOn = HideDeadOptions
        
        local deadPowerAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Power Bar Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadPowerBar", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadPowerAlpha.hideOn = HideDeadOptions
        
        local deadIconsAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Icons Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadIcons", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadIconsAlpha.hideOn = HideDeadOptions
        
        local deadAurasAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Auras Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadAuras", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadAurasAlpha.hideOn = HideDeadOptions
        
        local deadTextAlpha = deadGroup:AddWidget(GUI:CreateSlider(self.child, L["Status Text Alpha"], 0.0, 1.0, 0.05, db, "fadeDeadStatusText", function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        deadTextAlpha.hideOn = HideDeadOptions
        
        local deadCustomBg = deadGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Custom Dead Background"], db, "fadeDeadUseCustomColor", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
            DF:RefreshAllVisibleFrames()
        end), 30)
        deadCustomBg.hideOn = HideDeadOptions
        
        local function HideDeadBgColor(d)
            return not d.fadeDeadFrames or not d.fadeDeadUseCustomColor
        end
        
        local deadBgColor = deadGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Dead Background Color"], db, "fadeDeadBackgroundColor", false, function() DF:RefreshAllVisibleFrames() end, function() DF:RefreshAllVisibleFrames() end, true), 35)
        deadBgColor.hideOn = HideDeadBgColor
        
        Add(deadGroup, nil, 2)
        
        -- ===== HEALTH THRESHOLD FADING (above health threshold) =====
        AddSpace(20, "both")
        local hfGroup = GUI:CreateSettingsGroup(self.child, 560)
        hfGroup:AddWidget(GUI:CreateHeader(self.child, L["Health Threshold Fading"]), 40)
        hfGroup.tooltip = L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."]

        hfGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Health Threshold Fade"], db, "healthFadeEnabled", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
            DF:RefreshAllVisibleFrames()
        end), 30)

        local function HideHFOptions(d)
            return not d.healthFadeEnabled
        end

        local hfThreshold = hfGroup:AddWidget(GUI:CreateSlider(self.child, L["Health Threshold (%)"], 50, 100, 1, db, "healthFadeThreshold", function()
            DF:UpdateAllFrames()
            DF:RefreshAllVisibleFrames()
        end), 55)
        hfThreshold.hideOn = HideHFOptions
        hfThreshold.tooltip = L["Units at or above this health percent are faded."]

        local hfCancelDispel = hfGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Cancel Fade on Dispellable Debuff"], db, "hfCancelOnDispel", function()
            DF:UpdateAllFrames()
            DF:RefreshAllVisibleFrames()
        end), 30)
        hfCancelDispel.hideOn = HideHFOptions

        -- Health fade sliders need UpdateAllFrameAppearances to force an immediate visual refresh.
        -- Unlike OOR/dead fade which refresh on range/state changes, health fade alpha values
        -- are only re-read during appearance updates, not triggered by FullFrameRefresh alone.
        local function RefreshHealthFade()
            if DF.InvalidateHealthFadeCurve then DF:InvalidateHealthFadeCurve() end
            DF:RefreshAllVisibleFrames()
            if DF.UpdateAllFrameAppearances then DF:UpdateAllFrameAppearances() end
        end

        local hfFrameAlpha = hfGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Alpha (Above Threshold)"], 0.1, 1.0, 0.05, db, "healthFadeAlpha", nil, RefreshHealthFade, true), 55)
        hfFrameAlpha.hideOn = HideHFOptions
        hfFrameAlpha.tooltip = L["Frame opacity when health is above the threshold."]

        Add(hfGroup, nil, "both")
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "display_visibility", label = L["Visibility"]},
            {pageId = "text_status", label = L["Status Text"]},
        }), 30, "both")
    end)
    
    -- Display > Pet Frames
    local pagePets = CreateSubTab("display", "display_pets", L["Pet Frames"])
    BuildPage(pagePets, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top right
        Add(CreateCopyButton(self.child, {"pet"}, L["Pet Frames"], "display_pets"), 25, 2)
        
        -- Check modes for conditional content
        local isGroupedMode = db.petGroupMode == "GROUPED"
        local isRaidMode = GUI.SelectedMode == "raid"
        
        -- ===== GENERAL GROUP (full width) =====
        local generalGroup = GUI:CreateSettingsGroup(self.child, 560)
        generalGroup:AddWidget(GUI:CreateHeader(self.child, L["Pet Frame Settings"]), 40)
        generalGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Pet Frames"], db, "petEnabled", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end), 30)
        generalGroup:AddWidget(GUI:CreateLabel(self.child, L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."], 530), 30)
        Add(generalGroup, nil, "both")
        
        -- ===== LAYOUT MODE GROUP (full width) =====
        local layoutGroup = GUI:CreateSettingsGroup(self.child, 560)
        layoutGroup:AddWidget(GUI:CreateHeader(self.child, L["Layout Mode"]), 40)
        
        local groupModeValues = {
            ATTACHED = L["Attached to Owner"],
            GROUPED = L["Separate Pet Group"],
        }
        layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Layout Mode"], groupModeValues, db, "petGroupMode", function()
            if DF.UpdateAllPetFrames then DF:UpdateAllPetFrames(true) end
            if DF.UpdateAllRaidPetFrames then DF:UpdateAllRaidPetFrames(true) end
            GUI:RefreshCurrentPage()
        end), 55)
        
        if not isGroupedMode then
            layoutGroup:AddWidget(GUI:CreateLabel(self.child, L["Pet frames are positioned relative to their owner's frame."], 530), 25)
        else
            layoutGroup:AddWidget(GUI:CreateLabel(self.child, L["Pet frames are grouped together in a separate container."], 530), 25)
        end
        Add(layoutGroup, nil, "both")
        
        -- ===== COLUMN 1 GROUPS =====
        
        -- GROUPED MODE: Group Settings (col1)
        if isGroupedMode then
            local groupedSettingsGroup = GUI:CreateSettingsGroup(self.child, 280)
            groupedSettingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Group Settings"]), 40)
            
            local groupAnchorValues = {
                BOTTOM = isRaidMode and L["Below Raid"] or L["Below Party"],
                TOP = isRaidMode and L["Above Raid"] or L["Above Party"],
                LEFT = isRaidMode and L["Left of Raid"] or L["Left of Party"],
                RIGHT = isRaidMode and L["Right of Raid"] or L["Right of Party"],
            }
            local updateFunc = isRaidMode 
                and function() if DF.UpdateRaidPetGroupLayout then DF:UpdateRaidPetGroupLayout() end end
                or function() if DF.UpdatePetGroupLayout then DF:UpdatePetGroupLayout() end end
            
            groupedSettingsGroup:AddWidget(GUI:CreateDropdown(self.child, L["Group Position"], groupAnchorValues, db, "petGroupAnchor", updateFunc), 55)
            
            local growthValues = { HORIZONTAL= L["Horizontal"], VERTICAL= L["Vertical"] }
            groupedSettingsGroup:AddWidget(GUI:CreateDropdown(self.child, L["Growth Direction"], growthValues, db, "petGroupGrowth", updateFunc), 55)
            groupedSettingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Pet Spacing"], 0, 20, 1, db, "petGroupSpacing", updateFunc, updateFunc, true), 55)
            groupedSettingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Group X Offset"], -100, 100, 1, db, "petGroupOffsetX", updateFunc, updateFunc, true), 55)
            groupedSettingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Group Y Offset"], -100, 100, 1, db, "petGroupOffsetY", updateFunc, updateFunc, true), 55)
            
            if isRaidMode then
                groupedSettingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Group Label"], db, "petGroupShowLabel", function()
                    if DF.UpdateRaidPetGroupLayout then DF:UpdateRaidPetGroupLayout() end
                end), 30)
            end
            
            Add(groupedSettingsGroup, nil, 1)
        end
        
        -- SIZE GROUP (col1)
        local sizeGroup = GUI:CreateSettingsGroup(self.child, 280)
        sizeGroup:AddWidget(GUI:CreateHeader(self.child, L["Size"]), 40)
        
        if not isGroupedMode then
            sizeGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Match Owner Width"], db, "petMatchOwnerWidth", function()
                if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
                GUI:RefreshCurrentPage()
            end), 30)
            sizeGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Match Owner Height"], db, "petMatchOwnerHeight", function()
                if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
                GUI:RefreshCurrentPage()
            end), 30)
        end
        
        local widthSlider = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Width"], 40, 150, 1, db, "petFrameWidth", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        if not isGroupedMode then
            widthSlider.disableOn = function(d) return d.petMatchOwnerWidth end
        end
        
        local heightSlider = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Height"], 10, 40, 1, db, "petFrameHeight", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        if not isGroupedMode then
            heightSlider.disableOn = function(d) return d.petMatchOwnerHeight end
        end
        
        Add(sizeGroup, nil, 1)
        
        -- HEALTH BAR GROUP (col1)
        local healthBarGroup = GUI:CreateSettingsGroup(self.child, 280)
        healthBarGroup:AddWidget(GUI:CreateHeader(self.child, L["Health Bar"]), 40)
        
        local healthColorValues = {
            GREEN = L["Always Green"],
            CLASS = L["Owner's Class Color"],
            HEALTH = L["By Health %"],
            CUSTOM = L["Custom Color"],
        }
        healthBarGroup:AddWidget(GUI:CreateDropdown(self.child, L["Health Bar Color"], healthColorValues, db, "petHealthColorMode", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
            GUI:RefreshCurrentPage()
        end), 55)
        
        local customHealthColor = healthBarGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Custom Health Color"], db, "petHealthColor", false, function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 35)
        customHealthColor.hideOn = function(d) return d.petHealthColorMode ~= "CUSTOM" end
        
        healthBarGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Health Percentage"], db, "petShowHealthText", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end), 30)
        Add(healthBarGroup, nil, 1)
        
        -- NAME TEXT GROUP (col1)
        local outlineValues = {
            [""]= L["None"],
            OUTLINE = L["Outline"],
            THICKOUTLINE = L["Thick Outline"],
            SHADOW = L["Shadow"],
            MONOCHROME = L["Monochrome"],
        }
        local textAnchorValues = {
            TOPLEFT= L["Top Left"], TOP= L["Top"], TOPRIGHT= L["Top Right"],
            LEFT= L["Left"], CENTER= L["Center"], RIGHT= L["Right"],
            BOTTOMLEFT= L["Bottom Left"], BOTTOM= L["Bottom"], BOTTOMRIGHT= L["Bottom Right"],
        }
        
        local nameTextGroup = GUI:CreateSettingsGroup(self.child, 280)
        nameTextGroup:AddWidget(GUI:CreateHeader(self.child, L["Name Text"]), 40)
        nameTextGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "petNameFont", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        nameTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 16, 1, db, "petNameFontSize", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        nameTextGroup:AddWidget(GUI:CreateDropdown(self.child, L["Font Outline"], outlineValues, db, "petNameFontOutline", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        nameTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Name Length"], 4, 20, 1, db, "petNameMaxLength", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end), 55)
        nameTextGroup:AddWidget(GUI:CreateDropdown(self.child, L["Name Anchor"], textAnchorValues, db, "petNameAnchor", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        nameTextGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Name Color"], db, "petNameColor", false, function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 35)
        nameTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Name X Offset"], -30, 30, 1, db, "petNameX", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        nameTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Name Y Offset"], -15, 15, 1, db, "petNameY", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        Add(nameTextGroup, nil, 1)
        
        -- ===== COLUMN 2 GROUPS =====
        
        -- POSITION GROUP (col2, Attached mode only)
        if not isGroupedMode then
            local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
            positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
            
            local anchorValues = {
                BOTTOM = L["Below Owner"],
                TOP = L["Above Owner"],
                LEFT = L["Left of Owner"],
                RIGHT = L["Right of Owner"],
            }
            positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Position"], anchorValues, db, "petAnchor", function()
                if DF.UpdateAllPetFramePositions then DF:UpdateAllPetFramePositions() end
            end), 55)
            positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "petOffsetX", function()
                if DF.UpdateAllPetFramePositions then DF:UpdateAllPetFramePositions() end
            end, function() if DF.UpdateAllPetFramePositions then DF:UpdateAllPetFramePositions() end end, true), 55)
            positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "petOffsetY", function()
                if DF.UpdateAllPetFramePositions then DF:UpdateAllPetFramePositions() end
            end, function() if DF.UpdateAllPetFramePositions then DF:UpdateAllPetFramePositions() end end, true), 55)
            
            Add(positionGroup, nil, 2)
        end
        
        -- APPEARANCE GROUP (col2)
        local appearanceGroup = GUI:CreateSettingsGroup(self.child, 280)
        appearanceGroup:AddWidget(GUI:CreateHeader(self.child, L["Appearance"]), 40)
        appearanceGroup:AddWidget(GUI:CreateTextureDropdown(self.child, L["Health Bar Texture"], db, "petTexture", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        appearanceGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "petShowBorder", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 30)
        appearanceGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "petBorderColor", true, function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 35)
        appearanceGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Background Color"], db, "petBackgroundColor", true, function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 35)
        Add(appearanceGroup, nil, 2)
        
        -- HEALTH TEXT GROUP (col2)
        local healthTextGroup = GUI:CreateSettingsGroup(self.child, 280)
        healthTextGroup:AddWidget(GUI:CreateHeader(self.child, L["Health Text"]), 40)
        healthTextGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "petHealthFont", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        healthTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 14, 1, db, "petHealthFontSize", function()
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        healthTextGroup:AddWidget(GUI:CreateDropdown(self.child, L["Font Outline"], outlineValues, db, "petHealthFontOutline", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        healthTextGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Health Text Color"], db, "petHealthTextColor", false, function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 35)
        healthTextGroup:AddWidget(GUI:CreateDropdown(self.child, L["Health Text Anchor"], textAnchorValues, db, "petHealthAnchor", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end), 55)
        healthTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Health X Offset"], -30, 30, 1, db, "petHealthX", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        healthTextGroup:AddWidget(GUI:CreateSlider(self.child, L["Health Y Offset"], -15, 15, 1, db, "petHealthY", function()
            if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end
        end, function() if DF.LightweightUpdatePetFrames then DF:LightweightUpdatePetFrames() end end, true), 55)
        Add(healthTextGroup, nil, 2)
    end)
    
    -- General > Settings (mode enable/disable, Blizzard frame toggles, profile-wide settings)
    local pageGeneral = CreateSubTab("general", "general_settings", L["Settings"])
    BuildPage(pageGeneral, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Helpers: read from party-mode storage (canonical), write to BOTH
        -- party and raid mode dbs so the value stays consistent regardless
        -- of which mode is currently selected. The Blizzard frames are
        -- global UI elements so the toggle conceptually has no mode.
        local function makeBlizGet(key)
            return function() return DF.db.party and DF.db.party[key] end
        end
        local function makeBlizSet(key, cb)
            return function(val)
                if DF.db.party then DF.db.party[key] = val end
                if DF.db.raid  then DF.db.raid[key]  = val end
                if cb then cb() end
            end
        end

        -- Contextual reload popup shown when toggling DF Party/Raid frames.
        -- Offers an optional third button that ALSO flips the matching
        -- Blizzard hide flag, so "enabling" DF party also disables Blizzard
        -- party (typical intent) and "disabling" DF party also enables
        -- Blizzard party (so the user isn't left with no frames).
        local function PromptReloadAfterModeToggle(mode)
            if not DF:EnableFlagsDifferFromLoaded() then return end
            if not DF.ShowPopupAlert then return end

            -- NB: don't use `cond and a or b` here — the `a` result can be
            -- false (when DF frames are disabled), which makes the `or`
            -- fall through to the wrong mode's value.
            local enabled
            if mode == "party" then
                enabled = DF.db.partyEnabled ~= false
            else
                enabled = DF.db.raidEnabled ~= false
            end
            local blizKey = (mode == "party") and "hideBlizzardPartyFrames" or "hideBlizzardRaidFrames"
            local blizCurrentlyHidden = DF.db.party and DF.db.party[blizKey]

            local buttons = {}
            if enabled and not blizCurrentlyHidden then
                -- Enabling DF frames while Blizzard frames are still visible
                -- → offer to disable the Blizzard equivalent on the same reload
                buttons[#buttons + 1] = {
                    label = (mode == "party") and L["Reload & Disable Blizzard Party"] or L["Reload & Disable Blizzard Raid"],
                    onClick = function()
                        if DF.db.party then DF.db.party[blizKey] = true end
                        if DF.db.raid  then DF.db.raid[blizKey]  = true end
                        ReloadUI()
                    end,
                }
            elseif (not enabled) and blizCurrentlyHidden then
                -- Disabling DF frames while Blizzard frames are hidden
                -- → offer to re-enable the Blizzard equivalent
                buttons[#buttons + 1] = {
                    label = (mode == "party") and L["Reload & Enable Blizzard Party"] or L["Reload & Enable Blizzard Raid"],
                    onClick = function()
                        if DF.db.party then DF.db.party[blizKey] = false end
                        if DF.db.raid  then DF.db.raid[blizKey]  = false end
                        ReloadUI()
                    end,
                }
            end
            buttons[#buttons + 1] = { label = L["Just Reload"], onClick = function() ReloadUI() end }
            buttons[#buttons + 1] = { label = L["Reload Later"] }

            DF:ShowPopupAlert({
                title = L["Reload Required"],
                message = L["Enabling or disabling a frame mode requires a UI reload to take effect.\n\nReload now?"],
                width = 560,
                buttonWidth = 170,
                buttonHeight = 44,
                buttons = buttons,
            })
        end

        -- ===== INFO BANNER (global settings notice) =====
        do
            local banner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
            banner:SetSize(560, 40)
            if not banner.SetBackdrop then Mixin(banner, BackdropTemplateMixin) end
            banner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            banner:SetBackdropColor(0.15, 0.18, 0.28, 1)
            local tc = GUI.GetThemeColor and GUI.GetThemeColor() or {r = 0.45, g = 0.45, b = 0.95}
            banner:SetBackdropBorderColor(tc.r, tc.g, tc.b, 0.5)

            local icon = banner:CreateTexture(nil, "OVERLAY")
            icon:SetPoint("LEFT", 10, 0)
            icon:SetSize(16, 16)
            icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\info")

            local txt = banner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            txt:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            txt:SetPoint("RIGHT", banner, "RIGHT", -10, 0)
            txt:SetJustifyH("LEFT")
            txt:SetWordWrap(true)
            txt:SetText(L["Settings on this page apply globally — changes persist across both the Party and Raid sections."])
            txt:SetTextColor(0.85, 0.85, 0.85)

            Add(banner, 44, "both")
        end

        -- ===== FRAME MODES GROUP (Column 1, Top) =====
        local modesGroup = GUI:CreateSettingsGroup(self.child, 280)
        modesGroup:AddWidget(GUI:CreateHeader(self.child, L["Frame Modes"]), 40)
        modesGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Party Frames"], DF.db, "partyEnabled", function() PromptReloadAfterModeToggle("party") end), 30)
        modesGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Raid Frames"], DF.db, "raidEnabled", function() PromptReloadAfterModeToggle("raid") end), 30)
        modesGroup:AddWidget(GUI:CreateLabel(self.child,
            L["Completely enable or disable the Party or Raid frame system. Disabled modes are never created, consuming zero performance in the background. Requires a UI reload to apply."],
            260), 80)
        Add(modesGroup, nil, 1)

        -- ===== BLIZZARD FRAMES GROUP (Column 1, Bottom) =====
        -- Storage stays per-mode (party + raid both updated via setter sync)
        -- so AutoProfiles and ExportCategories continue to work unchanged.
        local blizzardGroup = GUI:CreateSettingsGroup(self.child, 280)
        blizzardGroup:AddWidget(GUI:CreateHeader(self.child, L["Blizzard Frames"]), 40)

        local disablePartyCheck = blizzardGroup:AddWidget(GUI:CreateCheckbox(
            self.child, L["Disable Blizzard Party Frames"],
            DF.db.party, "hideBlizzardPartyFrames",
            function() DF:UpdateBlizzardFrameVisibility() end,
            makeBlizGet("hideBlizzardPartyFrames"),
            makeBlizSet("hideBlizzardPartyFrames", function() DF:UpdateBlizzardFrameVisibility() end)
        ), 30)
        disablePartyCheck.tooltip = L["Hides and unregisters all events on the default Blizzard party frames so they consume no performance."]

        local disableRaidCheck = blizzardGroup:AddWidget(GUI:CreateCheckbox(
            self.child, L["Disable Blizzard Raid Frames"],
            DF.db.party, "hideBlizzardRaidFrames",
            function() DF:UpdateBlizzardFrameVisibility() end,
            makeBlizGet("hideBlizzardRaidFrames"),
            makeBlizSet("hideBlizzardRaidFrames", function() DF:UpdateBlizzardFrameVisibility() end)
        ), 30)
        disableRaidCheck.tooltip = L["Hides and unregisters all events on the default Blizzard raid frames so they consume no performance."]

        -- Visual divider + small caption to separate the related sub-option
        -- (Show Side Menu only applies once a Blizzard frame is disabled)
        local divider = CreateFrame("Frame", nil, self.child)
        divider:SetSize(260, 1)
        local dividerTex = divider:CreateTexture(nil, "OVERLAY")
        dividerTex:SetColorTexture(1, 1, 1, 0.08)
        dividerTex:SetPoint("LEFT", 0, 0)
        dividerTex:SetPoint("RIGHT", 0, 0)
        dividerTex:SetHeight(1)
        blizzardGroup:AddWidget(divider, 14)

        local sideMenuCheck = blizzardGroup:AddWidget(GUI:CreateCheckbox(
            self.child, L["Show Party/Raid Side Menu"],
            DF.db.party, "showBlizzardSideMenu",
            function() DF:UpdateBlizzardFrameVisibility() end,
            makeBlizGet("showBlizzardSideMenu"),
            makeBlizSet("showBlizzardSideMenu", function() DF:UpdateBlizzardFrameVisibility() end)
        ), 30)
        sideMenuCheck.disableOn = function()
            local p = DF.db.party
            return not (p and (p.hideBlizzardPartyFrames or p.hideBlizzardRaidFrames))
        end
        sideMenuCheck.tooltip = L["Shows the ping wheel & party management menu when Blizzard frames are disabled."]

        Add(blizzardGroup, nil, 1)

        -- ===== SETTINGS PANEL APPEARANCE GROUP (Column 2, Top) =====
        -- Controls the look of this settings panel itself — does NOT affect
        -- in-game frame text (use Health Text / Name Text pages for those).
        local outlineValues = {
            [""]          = L["None"],
            OUTLINE       = L["Outline"],
            THICKOUTLINE  = L["Thick Outline"],
            MONOCHROME    = L["Monochrome"],
        }
        local appearanceGroup = GUI:CreateSettingsGroup(self.child, 280)
        appearanceGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings Panel Appearance"]), 40)
        appearanceGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Settings Font"], DF.db, "settingsFont", function()
            if GUI.RefreshSettingsFont then GUI:RefreshSettingsFont() end
        end), 55)
        appearanceGroup:AddWidget(GUI:CreateDropdown(self.child, L["Settings Font Outline"], outlineValues, DF.db, "settingsFontOutline", function()
            if GUI.RefreshSettingsFont then GUI:RefreshSettingsFont() end
        end), 55)
        appearanceGroup:AddWidget(GUI:CreateLabel(self.child,
            L["Font used for this settings panel. Does not affect in-game frame text — use the Health Text, Name Text, and Status Text pages for those."],
            260), 60)
        Add(appearanceGroup, nil, 2)

        -- ===== LANGUAGE GROUP (Column 2, Bottom) =====
        local languageValues = {
            AUTO  = L["Auto (use client language)"],
            enUS  = "English",
            deDE  = "Deutsch",
            esES  = "Español (ES)",
            esMX  = "Español (MX)",
            frFR  = "Français",
            itIT  = "Italiano",
            koKR  = "한국어",
            ptBR  = "Português (BR)",
            ruRU  = "Русский",
            zhCN  = "中文 (简体)",
            zhTW  = "中文 (繁體)",
        }
        local languageGroup = GUI:CreateSettingsGroup(self.child, 280)
        languageGroup:AddWidget(GUI:CreateHeader(self.child, L["Language"]), 40)
        -- Language override lives on the per-character SavedVariable so
        -- locale files can read it at file-load time (before DF.db exists).
        languageGroup:AddWidget(GUI:CreateDropdown(self.child, L["Addon Language"], languageValues, DandersFramesCharDB, "languageOverride", function()
            if DF.ShowPopupAlert then
                DF:ShowPopupAlert({
                    title = L["Reload Required"],
                    message = L["Changing the addon language requires a UI reload to take effect.\n\nReload now?"],
                    buttons = {
                        { label = L["Reload Now"], onClick = function() ReloadUI() end },
                        { label = L["Later"] },
                    },
                })
            end
        end), 55)
        languageGroup:AddWidget(GUI:CreateLabel(self.child,
            L["Override the addon's display language. Auto follows your WoW client language. Translations are community-contributed and may be incomplete."],
            260), 60)
        Add(languageGroup, nil, 2)

        -- ===== NOTIFICATIONS GROUP (Column 2, Bottom) =====
        local notificationsGroup = GUI:CreateSettingsGroup(self.child, 280)
        notificationsGroup:AddWidget(GUI:CreateHeader(self.child, L["Notifications"]), 40)
        notificationsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Notify me when a newer version is available"],
            DF:GetGlobalDB(), "notifyOutdated", function()
                -- Setting applies immediately; no extra callback needed.
            end), 30)
        Add(notificationsGroup, nil, 2)
    end)

    -- General > Frame
    local pageFrame = CreateSubTab("general", "general_frame", L["Frame"])
    BuildPage(pageFrame, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"frame", "background", "missingHealth", "border", "anchor"}, L["Frame"], "general_frame"), 25, 2)
        
        -- Migration: Ensure new flat raid settings have defaults
        if db.raidFlatGrowthAnchor == nil then db.raidFlatGrowthAnchor = "START" end
        if db.raidFlatFrameAnchor == nil then db.raidFlatFrameAnchor = "START" end
        if db.raidFlatColumnAnchor == nil then db.raidFlatColumnAnchor = "START" end
        
        -- Function to update the correct frames based on mode
        local function UpdateFrames()
            if DF.headersInitialized then
                DF:ApplyHeaderSettings()
            end
            if GUI.SelectedMode == "raid" then
                DF:UpdateRaidLayout()
                if DF.SecureSort and DF.SecureSort.raidFramesRegistered then
                    DF.SecureSort:PushRaidLayoutConfig()
                    DF.SecureSort:PushRaidGroupLayoutConfig()
                    DF.SecureSort:TriggerSecureRaidSort()
                end
                -- Update test mode frames if active
                if DF.raidTestMode then DF:UpdateRaidTestFrames() end
            else
                DF:UpdateAllFrames()
            end
        end
        
        -- Store references to sliders so we can update their labels
        local groupsPerRowSlider, rowColSpacingSlider, playersPerRowSlider
        
        -- Function to update dynamic labels based on growth direction
        local function UpdateDynamicLabels()
            if groupsPerRowSlider and groupsPerRowSlider.label then
                groupsPerRowSlider.label:SetText(db.growDirection == "VERTICAL" and L["Groups Per Column"] or L["Groups Per Row"])
            end
            if rowColSpacingSlider and rowColSpacingSlider.label then
                rowColSpacingSlider.label:SetText(db.growDirection == "VERTICAL" and L["Column Spacing"] or L["Row Spacing"])
            end
            if playersPerRowSlider and playersPerRowSlider.label then
                playersPerRowSlider.label:SetText(db.growDirection == "VERTICAL" and L["Players Per Column"] or L["Players Per Row"])
            end
        end
        
        -- Custom callback for growth direction
        local function OnGrowthDirectionChanged()
            UpdateDynamicLabels()
            UpdateFrames()
            if GUI.SelectedMode == "raid" and not db.raidUseGroups and not InCombatLockdown() then
                C_Timer.After(0, function()
                    if not InCombatLockdown() then
                        if DF.headersInitialized then DF:ApplyHeaderSettings() end
                        if DF.UpdateRaidLayout then DF:UpdateRaidLayout() end
                    end
                end)
            end
            -- Defer label repositioning so headers have settled into new direction first
            C_Timer.After(0, function()
                if DF.UpdateRaidGroupLabels then
                    DF:UpdateRaidGroupLabels()
                end
            end)
        end
        
        -- ===== FRAME SIZE GROUP (Column 1) =====
        local sizeGroup = GUI:CreateSettingsGroup(self.child, 280)
        sizeGroup:AddWidget(GUI:CreateHeader(self.child, L["Frame Size"]), 40)
        sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Width"], 60, 300, 1, db, "frameWidth", UpdateFrames, function() DF:LightweightUpdateFrameSize() end, true), 55)
        sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Height"], 20, 300, 1, db, "frameHeight", UpdateFrames, function() DF:LightweightUpdateFrameSize() end, true), 55)
        sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Padding"], 0, 10, 1, db, "framePadding", UpdateFrames, function() DF:LightweightUpdateFrameSize() end, true), 55)
        sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Scale"], 0.5, 2.0, 0.05, db, "frameScale", function() DF:UpdateContainerPosition() DF:UpdateRaidContainerPosition() UpdateFrames() end, function() DF:LightweightUpdateFrameScale() end, true), 55)
        local frameSpacingSlider = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Spacing"], -5, 50, 1, db, "frameSpacing", UpdateFrames, function() DF:LightweightUpdateFrameSpacing() end, true), 55)
        frameSpacingSlider.hideOn = function() return GUI.SelectedMode == "raid" and not db.raidUseGroups end
        Add(sizeGroup, nil, 1)
        
        -- ===== APPEARANCE GROUP (Column 2) =====
        local appearanceGroup = GUI:CreateSettingsGroup(self.child, 280)
        appearanceGroup:AddWidget(GUI:CreateHeader(self.child, L["Appearance"]), 40)
        appearanceGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Frame Border"], db, "showFrameBorder", UpdateFrames), 30)
        local borderColorPicker = appearanceGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "borderColor", true, UpdateFrames, function() DF:LightweightUpdateBorderColor() end, true), 35)
        borderColorPicker.hideOn = function(d) return not d.showFrameBorder end
        appearanceGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Pixel-Perfect Scaling"], db, "pixelPerfect", UpdateFrames), 30)
        appearanceGroup:AddWidget(GUI:CreateLabel(self.child, L["Snaps sizes and borders to exact pixels for crisp rendering."], 250), 30)
        Add(appearanceGroup, nil, 2)

        -- ===== LAYOUT DIRECTION GROUP (Column 1) =====
        local layoutGroup = GUI:CreateSettingsGroup(self.child, 280)
        layoutGroup:AddWidget(GUI:CreateHeader(self.child, L["Layout Direction"]), 40)
        
        -- Party dropdown
        local partyGrowOptions = { HORIZONTAL= L["Rows"], VERTICAL= L["Columns"] }
        local partyArrangeDropdown = layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Arrange In"], partyGrowOptions, db, "growDirection", OnGrowthDirectionChanged), 55)
        partyArrangeDropdown.hideOn = function() return GUI.SelectedMode == "raid" end
        
        -- Raid GROUP dropdown (groups mode)
        local raidGrowOptions = { HORIZONTAL= L["Columns"], VERTICAL= L["Rows"] }
        local raidArrangeDropdown = layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Arrange Groups In"], raidGrowOptions, db, "growDirection", OnGrowthDirectionChanged), 55)
        raidArrangeDropdown.hideOn = function() return GUI.SelectedMode ~= "raid" or not db.raidUseGroups end
        
        -- Raid FLAT dropdown
        local flatGrowOptions = { HORIZONTAL= L["Rows"], VERTICAL= L["Columns"] }
        local flatArrangeDropdown = layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Arrange Players In"], flatGrowOptions, db, "growDirection", OnGrowthDirectionChanged), 55)
        flatArrangeDropdown.hideOn = function() return GUI.SelectedMode ~= "raid" or db.raidUseGroups end
        
        -- Growth anchor (party only)
        local anchorOptions = { START= L["Start"], CENTER= L["Center"], END= L["End"] }
        local anchorDropdown = layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Frames Grow From"], anchorOptions, db, "growthAnchor", UpdateFrames), 55)
        anchorDropdown.hideOn = function() return GUI.SelectedMode == "raid" end
        
        local helpText = layoutGroup:AddWidget(GUI:CreateLabel(self.child, L["Start = Left/Top, End = Right/Bottom depending on direction."], 250), 30)
        helpText.hideOn = function() return GUI.SelectedMode == "raid" end
        
        Add(layoutGroup, nil, 1)
        
        -- ===== RAID LAYOUT MODE GROUP (Column 2, raid only) =====
        local raidModeGroup = GUI:CreateSettingsGroup(self.child, 280)
        raidModeGroup:AddWidget(GUI:CreateHeader(self.child, L["Raid Layout Mode"]), 40)
        raidModeGroup.hideOn = function() return GUI.SelectedMode ~= "raid" end
        
        local useGroupsCheck = raidModeGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Group-Based Layout"], db, "raidUseGroups", function()
            UpdateFrames()
            if DF.SecureSort then
                DF.SecureSort:PushRaidGroupLayoutConfig()
                DF.SecureSort:TriggerSecureRaidSort()
            end
            if not db.raidUseGroups and not InCombatLockdown() then
                if DF.UpdateRaidGroupLabels then DF:UpdateRaidGroupLabels() end
                C_Timer.After(0, function()
                    if not InCombatLockdown() then
                        if DF.FlatRaidFrames then
                            if not DF.FlatRaidFrames.initialized then DF.FlatRaidFrames:Initialize() end
                            if DF.FlatRaidFrames.initialized then DF.FlatRaidFrames:SetEnabled(true) end
                        end
                        if DF.headersInitialized then DF:ApplyHeaderSettings() end
                        if DF.UpdateRaidLayout then DF:UpdateRaidLayout() end
                    end
                end)
            else
                if DF.FlatRaidFrames and DF.FlatRaidFrames.initialized then
                    DF.FlatRaidFrames:SetEnabled(false)
                end
            end
            if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
        end), 30)
        
        raidModeGroup:AddWidget(GUI:CreateLabel(self.child, L["Enabled: Players organized by raid groups (1-8).\nDisabled: All players in one flat grid."], 250), 45)
        Add(raidModeGroup, nil, 2)
        
        -- ===== GROUP LAYOUT SETTINGS (Column 1, raid+groups only) =====
        local groupLayoutGroup = GUI:CreateSettingsGroup(self.child, 280)
        groupLayoutGroup:AddWidget(GUI:CreateHeader(self.child, L["Group Layout Settings"]), 40)
        groupLayoutGroup.hideOn = function() return GUI.SelectedMode ~= "raid" or not db.raidUseGroups end
        
        groupLayoutGroup:AddWidget(GUI:CreateLabel(self.child, L["Horizontal: Players stack vertically, groups grow left-to-right."], 250), 25)
        
        groupLayoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Group Spacing"], -5, 100, 1, db, "raidGroupSpacing", UpdateFrames, function() DF:LightweightUpdateRaidLayout() end, true), 55)
        
        local rowColLabel = db.growDirection == "VERTICAL" and L["Column Spacing"] or L["Row Spacing"]
        rowColSpacingSlider = groupLayoutGroup:AddWidget(GUI:CreateSlider(self.child, rowColLabel, -5, 100, 1, db, "raidRowColSpacing", UpdateFrames, function() DF:LightweightUpdateRaidLayout() end, true), 55)
        
        local groupsLabel = db.growDirection == "VERTICAL" and L["Groups Per Column"] or L["Groups Per Row"]
        groupsPerRowSlider = groupLayoutGroup:AddWidget(GUI:CreateSlider(self.child, groupsLabel, 1, 8, 1, db, "raidGroupsPerRow", UpdateFrames, function() DF:LightweightUpdateRaidLayout() end, true), 55)
        
        groupLayoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Groups Grow From"], anchorOptions, db, "raidGroupAnchor", UpdateFrames), 55)

        local rowGrowLabel = db.growDirection == "VERTICAL" and L["Columns Grow From"] or L["Rows Grow From"]
        local rowGrowOptions = db.growDirection == "VERTICAL" and { START= L["Left"], END= L["Right"] } or { START= L["Top"], END= L["Bottom"] }
        groupLayoutGroup:AddWidget(GUI:CreateDropdown(self.child, rowGrowLabel, rowGrowOptions, db, "raidGroupRowGrowth", UpdateFrames), 55)

        local playerAnchorOptions = { START= L["Start"], END= L["End"] }
        groupLayoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Players Grow From"], playerAnchorOptions, db, "raidPlayerAnchor", UpdateFrames), 55)
        
        Add(groupLayoutGroup, nil, 1)
        
        -- ===== GROUP VISIBILITY (Column 1, raid only) =====
        local groupVisGroup = GUI:CreateSettingsGroup(self.child, 280)
        groupVisGroup:AddWidget(GUI:CreateHeader(self.child, L["Group Visibility"]), 40)
        groupVisGroup.hideOn = function() return GUI.SelectedMode ~= "raid" end
        
        groupVisGroup:AddWidget(GUI:CreateLabel(self.child, L["Choose which groups to display."], 250), 25)
        
        -- Initialize raidGroupVisible if it doesn't exist
        if not db.raidGroupVisible then
            db.raidGroupVisible = {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true}
        end
        
        for i = 1, 8 do
            local groupIndex = i
            local overrideKey = "raidGroupVisible_" .. i
            groupVisGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Group"] .. " " .. i, nil, nil, 
                function()
                    -- Update test mode frames if active
                    if DF.raidTestMode then DF:UpdateRaidTestFrames() end
                    if db.raidUseGroups then
                        -- Separated mode
                        DF:UpdateRaidHeaderVisibility(); DF:PositionRaidHeaders()
                    else
                        -- Flat mode - rebuild groupFilter and nameList
                        if DF.FlatRaidFrames then
                            DF.FlatRaidFrames:UpdateContainerSize()
                            DF.FlatRaidFrames:UpdateSorting()
                        end
                    end
                end,
                function() return db.raidGroupVisible[groupIndex] ~= false end,
                function(val) db.raidGroupVisible[groupIndex] = val end,
                overrideKey
            ), 25)
        end
        
        Add(groupVisGroup, nil, 1)
        
        -- ===== GROUP DISPLAY ORDER (Column 2, raid+groups only) =====
        local groupOrderGroup = GUI:CreateSettingsGroup(self.child, 280)
        groupOrderGroup:AddWidget(GUI:CreateHeader(self.child, L["Group Display Order"]), 40)
        groupOrderGroup.hideOn = function() return GUI.SelectedMode ~= "raid" or not db.raidUseGroups end
        
        groupOrderGroup:AddWidget(GUI:CreateLabel(self.child, L["Drag to reorder groups. Top = first."], 250), 25)
        
        local playerGroupFirstCheck = groupOrderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["My Group First"], db, "raidPlayerGroupFirst", function()
            if DF.UpdatePlayerGroupTracking then DF:UpdatePlayerGroupTracking() end
            if DF.UpdateRaidGroupOrderAttributes then DF:UpdateRaidGroupOrderAttributes() end
            DF:TriggerRaidPosition()
        end), 25)
        playerGroupFirstCheck.tooltip = L["When enabled, the group you are in will always be displayed first."]
        
        -- Initialize raidGroupDisplayOrder if it doesn't exist
        if not db.raidGroupDisplayOrder then
            db.raidGroupDisplayOrder = {1, 2, 3, 4, 5, 6, 7, 8}
        end
        
        local groupOrderWidget = GUI:CreateGroupOrderList(self.child, db, "raidGroupDisplayOrder", function()
            if DF.UpdateRaidGroupOrderAttributes then DF:UpdateRaidGroupOrderAttributes() end
            DF:TriggerRaidPosition()
            -- Update test mode frames if active
            if DF.raidTestMode then DF:UpdateRaidTestFrames() end
        end)
        groupOrderGroup:AddWidget(groupOrderWidget, 230)
        
        Add(groupOrderGroup, nil, 2)
        
        -- ===== FLAT GRID SETTINGS (Column 1, raid+flat only) =====
        local flatGridGroup = GUI:CreateSettingsGroup(self.child, 280)
        flatGridGroup:AddWidget(GUI:CreateHeader(self.child, L["Flat Grid Settings"]), 40)
        flatGridGroup.hideOn = function() return GUI.SelectedMode ~= "raid" or db.raidUseGroups end
        
        flatGridGroup:AddWidget(GUI:CreateLabel(self.child, L["All players in a unified grid. Sorting applies raid-wide."], 250), 25)
        
        local function UpdateFlatLayoutFull()
            if InCombatLockdown() then return end
            if DF.headersInitialized then DF:ApplyHeaderSettings() end
            if GUI.SelectedMode == "raid" then DF:UpdateRaidLayout() end
        end
        
        local playersPerLabel = db.growDirection == "VERTICAL" and L["Players Per Column"] or L["Players Per Row"]
        playersPerRowSlider = flatGridGroup:AddWidget(GUI:CreateSlider(self.child, playersPerLabel, 1, 40, 1, db, "raidPlayersPerRow", UpdateFlatLayoutFull, UpdateFlatLayoutFull, true), 55)
        
        local growthAnchorOptions = { START= L["Start"], CENTER= L["Center"], END= L["End"] }
        flatGridGroup:AddWidget(GUI:CreateDropdown(self.child, L["Frames Grow From"], growthAnchorOptions, db, "raidFlatGrowthAnchor", UpdateFrames), 55)
        
        local columnAnchorOptions = { START= L["Start (Left/Top)"], END= L["End (Right/Bottom)"] }
        flatGridGroup:AddWidget(GUI:CreateDropdown(self.child, L["Columns Grow From"], columnAnchorOptions, db, "raidFlatColumnAnchor", UpdateFrames), 55)
        
        flatGridGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Reverse Order"], db, "raidFlatFrameAnchor", UpdateFrames, 
            function() return db.raidFlatFrameAnchor == "END" end,
            function(val) db.raidFlatFrameAnchor = val and "END" or "START" end
        ), 30)
        
        flatGridGroup:AddWidget(GUI:CreateSlider(self.child, L["Horizontal Spacing"], -5, 100, 1, db, "raidFlatHorizontalSpacing", UpdateFrames, function() DF:LightweightUpdateFrameSize() end, true), 55)
        flatGridGroup:AddWidget(GUI:CreateSlider(self.child, L["Vertical Spacing"], -5, 100, 1, db, "raidFlatVerticalSpacing", UpdateFrames, function() DF:LightweightUpdateFrameSize() end, true), 55)
        
        Add(flatGridGroup, nil, 1)
        
        -- Update labels on show
        if groupsPerRowSlider and groupsPerRowSlider.label then
            groupsPerRowSlider:HookScript("OnShow", UpdateDynamicLabels)
        end
        if rowColSpacingSlider and rowColSpacingSlider.label then
            rowColSpacingSlider:HookScript("OnShow", UpdateDynamicLabels)
        end
        if playersPerRowSlider and playersPerRowSlider.label then
            playersPerRowSlider:HookScript("OnShow", UpdateDynamicLabels)
        end

        -- ===== PERMANENT MOVER GROUP (Column 2) =====
        local permMoverGroup = GUI:CreateSettingsGroup(self.child, 280)
        permMoverGroup:AddWidget(GUI:CreateHeader(self.child, L["Permanent Mover"]), 40)

        permMoverGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Permanent Mover"], db, "permanentMover", function()
            DF:UpdatePermanentMoverVisibility()
        end), 30)

        local moverAnchorValues = {
            TOPLEFT= L["Top Left"], TOP= L["Top"], TOPRIGHT= L["Top Right"],
            LEFT= L["Left"], RIGHT= L["Right"],
            BOTTOMLEFT= L["Bottom Left"], BOTTOM= L["Bottom"], BOTTOMRIGHT= L["Bottom Right"],
        }
        local permMoverAnchor = permMoverGroup:AddWidget(
            GUI:CreateDropdown(self.child, L["Handle Position"], moverAnchorValues, db, "permanentMoverAnchor", function()
                DF:UpdatePermanentMoverAnchor(GUI.SelectedMode)
            end), 55)
        permMoverAnchor.disableOn = function(d) return not d.permanentMover end

        local attachValues = { CONTAINER= L["Container"], FIRST= L["First Unit"], LAST= L["Last Unit"] }
        local permAttach = permMoverGroup:AddWidget(
            GUI:CreateDropdown(self.child, L["Attach To"], attachValues, db, "permanentMoverAttachTo", function()
                DF:UpdatePermanentMoverAnchor(GUI.SelectedMode)
            end), 55)
        permAttach.disableOn = function(d) return not d.permanentMover end
        permAttach.tooltip = L["Attach the handle to the container, the first visible unit, or the last visible unit."]

        local function PermMoverAnchorUpdate() DF:UpdatePermanentMoverAnchor(GUI.SelectedMode) end
        local function PermMoverSizeUpdate() DF:UpdatePermanentMoverSize(GUI.SelectedMode) end

        local permOffsetX = permMoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -500, 500, 1, db, "permanentMoverOffsetX", PermMoverAnchorUpdate, PermMoverAnchorUpdate), 55)
        permOffsetX.disableOn = function(d) return not d.permanentMover end

        local permOffsetY = permMoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -500, 500, 1, db, "permanentMoverOffsetY", PermMoverAnchorUpdate, PermMoverAnchorUpdate), 55)
        permOffsetY.disableOn = function(d) return not d.permanentMover end

        local permWidth = permMoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Handle Width"], 5, 500, 1, db, "permanentMoverWidth", PermMoverSizeUpdate, PermMoverSizeUpdate), 55)
        permWidth.disableOn = function(d) return not d.permanentMover end

        local permHeight = permMoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Handle Height"], 5, 500, 1, db, "permanentMoverHeight", PermMoverSizeUpdate, PermMoverSizeUpdate), 55)
        permHeight.disableOn = function(d) return not d.permanentMover end

        local permHover = permMoverGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show on Hover Only"], db, "permanentMoverShowOnHover", function()
            DF:UpdatePermanentMoverVisibility()
        end), 30)
        permHover.disableOn = function(d) return not d.permanentMover end
        permHover.tooltip = L["Handle is invisible until you hover over it. Fades in and out smoothly."]

        local permCombat = permMoverGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "permanentMoverHideInCombat", function()
            DF:UpdatePermanentMoverCombatState()
        end), 30)
        permCombat.disableOn = function(d) return not d.permanentMover end
        permCombat.tooltip = L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."]

        local permColor = permMoverGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Handle Color"], db, "permanentMoverColor", false, function()
            DF:UpdatePermanentMoverColor(GUI.SelectedMode)
        end), 35)
        permColor.disableOn = function(d) return not d.permanentMover end

        local permCombatColor = permMoverGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Combat Color"], db, "permanentMoverCombatColor", false, nil), 35)
        permCombatColor.disableOn = function(d) return not d.permanentMover end
        permCombatColor.tooltip = L["Color shown when in combat to indicate the handle is locked."]

        -- Quick action dropdowns
        local actionValues = {}
        for id, data in pairs(DF.PERM_MOVER_ACTIONS) do
            actionValues[id] = data.label
        end

        local permActionLeft = permMoverGroup:AddWidget(GUI:CreateDropdown(self.child, L["Left Click"], actionValues, db, "permanentMoverActionLeft"), 55)
        permActionLeft.disableOn = function(d) return not d.permanentMover end

        local permActionRight = permMoverGroup:AddWidget(GUI:CreateDropdown(self.child, L["Right Click"], actionValues, db, "permanentMoverActionRight"), 55)
        permActionRight.disableOn = function(d) return not d.permanentMover end

        local permActionShiftLeft = permMoverGroup:AddWidget(GUI:CreateDropdown(self.child, L["Shift+Left Click"], actionValues, db, "permanentMoverActionShiftLeft"), 55)
        permActionShiftLeft.disableOn = function(d) return not d.permanentMover end

        local permActionShiftRight = permMoverGroup:AddWidget(GUI:CreateDropdown(self.child, L["Shift+Right Click"], actionValues, db, "permanentMoverActionShiftRight"), 55)
        permActionShiftRight.disableOn = function(d) return not d.permanentMover end

        local permPullTimer = permMoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Pull Timer Duration"], 3, 30, 1, db, "permanentMoverPullTimerDuration"), 55)
        permPullTimer.disableOn = function(d) return not d.permanentMover end
        permPullTimer.tooltip = L["Duration in seconds for the Pull Timer quick action."]

        Add(permMoverGroup, nil, 2)

        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "general_sorting", label = L["Sorting"]},
            {pageId = "bars_health", label = L["Health Bar"]},
            {pageId = "text_name", label = L["Name Text"]},
        }), 30, "both")
    end)
    
    -- General > Global Fonts
    local pageGlobalFonts = CreateSubTab("general", "general_fonts", L["Global Fonts"])
    BuildPage(pageGlobalFonts, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Initialize temp storage for selections (persists during session)
        if not DF.GlobalFontTemp then
            DF.GlobalFontTemp = {
                font = db.nameFont or "Fonts\\FRIZQT__.TTF",
                outline = db.nameTextOutline or "OUTLINE",
            }
        end
        
        -- ===== FONT SELECTION GROUP (Column 1) =====
        local fontSelectGroup = GUI:CreateSettingsGroup(self.child, 280)
        fontSelectGroup:AddWidget(GUI:CreateHeader(self.child, L["Global Font Settings"]), 40)
        fontSelectGroup:AddWidget(GUI:CreateLabel(self.child, L["Set a font and outline style, then click Apply to update ALL text elements."], 250), 40)
        
        fontSelectGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], DF.GlobalFontTemp, "font", function() end), 55)
        
        local outlineOptions = {
            NONE = L["None"],
            OUTLINE = L["Outline"],
            THICKOUTLINE = L["Thick Outline"],
            SHADOW = L["Shadow"],
        }
        fontSelectGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, DF.GlobalFontTemp, "outline", function() end), 55)
        
        -- Themed Apply button
        local applyBtn = CreateFrame("Button", nil, self.child, "BackdropTemplate")
        applyBtn:SetSize(120, 28)
        applyBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        applyBtn:SetBackdropColor(0.18, 0.18, 0.18, 1)
        applyBtn:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        
        applyBtn.text = applyBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        applyBtn.text:SetPoint("CENTER", 0, 0)
        applyBtn.text:SetText(L["Apply to All"])
        applyBtn.text:SetTextColor(0.9, 0.9, 0.9, 1)
        
        applyBtn:SetScript("OnEnter", function(s)
            s:SetBackdropColor(0.45, 0.45, 0.95, 0.3)
            s:SetBackdropBorderColor(0.45, 0.45, 0.95, 1)
            s.text:SetTextColor(1, 1, 1, 1)
        end)
        applyBtn:SetScript("OnLeave", function(s)
            s:SetBackdropColor(0.18, 0.18, 0.18, 1)
            s:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
            s.text:SetTextColor(0.9, 0.9, 0.9, 1)
        end)
        applyBtn:SetScript("OnMouseDown", function(s) s:SetBackdropColor(0.45, 0.45, 0.95, 0.5) end)
        applyBtn:SetScript("OnMouseUp", function(s) s:SetBackdropColor(0.45, 0.45, 0.95, 0.3) end)
        applyBtn:SetScript("OnClick", function()
            local font = DF.GlobalFontTemp.font
            local outline = DF.GlobalFontTemp.outline
            
            -- Clear font family cache so new fonts are created
            if DF.ClearFontCache then DF:ClearFontCache() end
            
            -- Apply to all font settings
            db.nameFont = font; db.nameTextOutline = outline
            db.healthFont = font; db.healthTextOutline = outline
            db.statusTextFont = font; db.statusTextOutline = outline
            db.buffStackFont = font; db.buffStackOutline = outline
            db.buffDurationFont = font; db.buffDurationOutline = outline
            db.debuffStackFont = font; db.debuffStackOutline = outline
            db.debuffDurationFont = font; db.debuffDurationOutline = outline
            db.petNameFont = font; db.petNameFontOutline = outline
            db.petHealthFont = font; db.petHealthFontOutline = outline
            db.targetedSpellDurationFont = font; db.targetedSpellDurationOutline = outline
            db.personalTargetedSpellDurationFont = font; db.personalTargetedSpellDurationOutline = outline
            db.targetedListFont = font; db.targetedListFontOutline = outline
            db.defensiveIconDurationFont = font; db.defensiveIconDurationOutline = outline
            db.statusIconFont = font; db.statusIconFontOutline = outline
            if db.groupLabelFont ~= nil then
                db.groupLabelFont = font; db.groupLabelOutline = outline
            end
            -- Aura Designer global defaults + clear per-instance overrides
            if db.auraDesigner then
                if db.auraDesigner.defaults then
                    local adDefaults = db.auraDesigner.defaults
                    adDefaults.durationFont = font; adDefaults.durationOutline = outline
                    adDefaults.stackFont = font; adDefaults.stackOutline = outline
                end
                -- Clear per-instance font overrides so all indicators inherit global
                if db.auraDesigner.auras then
                    for _, auraCfg in pairs(db.auraDesigner.auras) do
                        if auraCfg.indicators then
                            for _, inst in ipairs(auraCfg.indicators) do
                                inst.durationFont = nil; inst.durationOutline = nil
                                inst.stackFont = nil; inst.stackOutline = nil
                            end
                        end
                    end
                end
            end

            DF:UpdateAllFrames()
            if GUI.SelectedMode == "raid" and DF.UpdateRaidLayout then DF:UpdateRaidLayout() end
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
            if DF.UpdateAllTargetedSpellLayouts then DF:UpdateAllTargetedSpellLayouts() end
            if (DF.testMode or DF.raidTestMode) and DF.UpdateAllTestTargetedSpell then DF:UpdateAllTestTargetedSpell() end
            if DF.UpdateTestPersonalTargetedSpells then DF:UpdateTestPersonalTargetedSpells() end
            if DF.UpdateTargetedListLayout then DF:UpdateTargetedListLayout() end
            if DF.UpdateAllFramesStatusIcons then DF:UpdateAllFramesStatusIcons() end
            
            -- Refresh test frames to apply new fonts
            if DF.RefreshTestFrames then DF:RefreshTestFrames() end

            -- Force Aura Designer to re-apply indicators with new fonts
            if DF.AuraDesigner and DF.AuraDesigner.Engine and DF.AuraDesigner.Engine.ForceRefreshAllFrames then
                DF.AuraDesigner.Engine:ForceRefreshAllFrames()
            end
            -- Also refresh the AD options preview if visible
            if DF.AuraDesigner_RefreshPage then DF:AuraDesigner_RefreshPage() end

            print("|cff00ff00DandersFrames:|r Applied global font settings to all text elements.")
        end)
        fontSelectGroup:AddWidget(applyBtn, 35)
        
        Add(fontSelectGroup, nil, 1)
        
        -- ===== SHADOW SETTINGS GROUP (Column 1) =====
        local shadowGroup = GUI:CreateSettingsGroup(self.child, 280)
        shadowGroup:AddWidget(GUI:CreateHeader(self.child, L["Shadow Settings"]), 40)
        shadowGroup:AddWidget(GUI:CreateLabel(self.child, L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."], 250), 40)
        
        local function UpdateShadowSettings()
            -- Full update on release
            if DF.ClearFontCache then DF:ClearFontCache() end
            DF:UpdateAllFrames()
            if GUI.SelectedMode == "raid" and DF.UpdateRaidLayout then DF:UpdateRaidLayout() end
            if DF.ApplyPetSettings then DF:ApplyPetSettings() end
        end
        
        local function LightweightShadowUpdate()
            if DF.LightweightUpdateFontShadows then DF:LightweightUpdateFontShadows() end
        end
        
        shadowGroup:AddWidget(GUI:CreateSlider(self.child, L["Shadow X Offset"], -10, 10, 0.5, db, "fontShadowOffsetX", UpdateShadowSettings, LightweightShadowUpdate), 50)
        shadowGroup:AddWidget(GUI:CreateSlider(self.child, L["Shadow Y Offset"], -10, 10, 0.5, db, "fontShadowOffsetY", UpdateShadowSettings, LightweightShadowUpdate), 50)
        shadowGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Shadow Color"], db, "fontShadowColor", true, UpdateShadowSettings, LightweightShadowUpdate, true), 40)
        
        Add(shadowGroup, nil, 1)
        
        -- ===== AFFECTED ELEMENTS GROUP (Column 2) =====
        local infoGroup = GUI:CreateSettingsGroup(self.child, 280)
        infoGroup:AddWidget(GUI:CreateHeader(self.child, L["Affected Elements"]), 40)
        infoGroup:AddWidget(GUI:CreateLabel(self.child, L["• Name Text\n• Health Text\n• Status Text (Dead/Offline)\n• Buff Stack & Duration\n• Debuff Stack & Duration\n• Pet Frame Text\n• Targeted Spell Duration\n• Defensive Icon Duration\n• Status Icon Text (Res, Summon, etc.)\n• Group Labels (Raid)"], 250), 175)
        infoGroup:AddWidget(GUI:CreateLabel(self.child, L["Note: Font sizes are not changed. Adjust sizes in each element's page."], 250), 40)
        Add(infoGroup, nil, 2)
    end)
    
    -- General > Group Labels (Raid only, group-based layout only)
    local pageGroupLabels = CreateSubTab("general", "general_labels", L["Group Labels"])
    BuildPage(pageGroupLabels, function(self, db, Add, AddSpace, AddSyncPoint)
        local function HideGroupLabelOptions(d)
            return GUI.SelectedMode ~= "raid" or not d.raidUseGroups or not d.groupLabelEnabled
        end
        
        local function UpdateLabels()
            if DF.UpdateRaidGroupLabels then DF:UpdateRaidGroupLabels() end
        end
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Raid Group Labels"]), 40)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["Display labels above or beside each raid group."], 250), 25)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Group Labels"], db, "groupLabelEnabled", UpdateLabels), 30)
        settingsGroup.hideOn = function() return GUI.SelectedMode ~= "raid" or not db.raidUseGroups end
        Add(settingsGroup, nil, 1)
        
        -- ===== TEXT FORMAT GROUP (Column 1) =====
        local formatGroup = GUI:CreateSettingsGroup(self.child, 280)
        formatGroup:AddWidget(GUI:CreateHeader(self.child, L["Text Format"]), 40)
        
        local formatOptions = {
            ["GROUP_NUM"] = L["Group 1"],
            ["SHORT"] = L["G1"],
            ["NUM_ONLY"] = L["1"],
            ["ROMAN"] = L["I, II, III..."],
        }
        formatGroup:AddWidget(GUI:CreateDropdown(self.child, L["Label Format"], formatOptions, db, "groupLabelFormat", UpdateLabels), 55)
        formatGroup.hideOn = HideGroupLabelOptions
        Add(formatGroup, nil, 1)
        
        -- ===== FONT GROUP (Column 1) =====
        local fontGroup = GUI:CreateSettingsGroup(self.child, 280)
        fontGroup:AddWidget(GUI:CreateHeader(self.child, L["Font Settings"]), 40)
        fontGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "groupLabelFont", UpdateLabels), 55)
        fontGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 8, 24, 1, db, "groupLabelFontSize", UpdateLabels, function() DF:LightweightUpdateGroupLabels() end, true), 55)
        
        local outlineOptions = {
            ["NONE"] = L["None"],
            ["OUTLINE"] = L["Outline"],
            ["THICKOUTLINE"] = L["Thick Outline"],
            ["SHADOW"] = L["Shadow"],
        }
        fontGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "groupLabelOutline", UpdateLabels), 55)
        fontGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Label Color"], db, "groupLabelColor", true, UpdateLabels, function() DF:LightweightUpdateGroupLabelColor() end, true), 35)
        fontGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Shadow"], db, "groupLabelShadow", UpdateLabels), 30)
        fontGroup.hideOn = HideGroupLabelOptions
        Add(fontGroup, nil, 1)
        
        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        
        local positionOptions = {
            ["START"] = L["Start of Group"],
            ["CENTER"] = L["Center of Group"],
            ["END"] = L["End of Group"],
        }
        positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Label Position"], positionOptions, db, "groupLabelPosition", UpdateLabels), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -100, 100, 1, db, "groupLabelOffsetX", UpdateLabels, function() DF:LightweightUpdateGroupLabels() end, true), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -100, 100, 1, db, "groupLabelOffsetY", UpdateLabels, function() DF:LightweightUpdateGroupLabels() end, true), 55)
        positionGroup:AddWidget(GUI:CreateLabel(self.child, L["Start: Above/left of groups.\nCenter: Middle of the group.\nEnd: Below/right of groups."], 250), 50)
        positionGroup.hideOn = HideGroupLabelOptions
        Add(positionGroup, nil, 2)
        
        -- Party mode message
        local partyMsg = Add(GUI:CreateLabel(self.child, L["Group labels are only available for raid frames.\n\nSwitch to Raid mode using the toggle at the top\nof the settings panel to configure group labels."], 400), 80, "both")
        partyMsg.hideOn = function() return GUI.SelectedMode == "raid" end
        
        -- Flat mode message
        local flatMsg = Add(GUI:CreateLabel(self.child, L["Group labels are not available in Flat Grid layout.\n\nEnable 'Use Group-Based Layout' in Frame settings\nto use group labels."], 400), 80, "both")
        flatMsg.hideOn = function() return GUI.SelectedMode ~= "raid" or db.raidUseGroups end
    end)
    
    -- General > Pinned Frames
    local pagePinnedFrames = CreateSubTab("general", "general_pinnedframes", L["Pinned Frames"])
    BuildPage(pagePinnedFrames, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Constants
        local HIGHLIGHT_MAX_SETS = 2
        
        -- Initialize pinnedFrames in db if needed
        if not db.pinnedFrames then
            db.pinnedFrames = {
                sets = {
                    [1] = {
                        enabled = false, name = "Pinned 1", players = {},
                        growDirection = "HORIZONTAL", unitsPerRow = 5,
                        horizontalSpacing = 2, verticalSpacing = 2, scale = 1.0,
                        position = { point = "CENTER", x = 0, y = 200 },
                        locked = false, showLabel = false,
                        autoAddTanks = false, autoAddHealers = false, autoAddDPS = false,
                        keepOfflinePlayers = true,
                    },
                    [2] = {
                        enabled = false, name = "Pinned 2", players = {},
                        growDirection = "HORIZONTAL", unitsPerRow = 5,
                        horizontalSpacing = 2, verticalSpacing = 2, scale = 1.0,
                        position = { point = "CENTER", x = 0, y = -200 },
                        locked = false, showLabel = false,
                        autoAddTanks = false, autoAddHealers = false, autoAddDPS = false,
                        keepOfflinePlayers = true,
                    },
                },
            }
        end
        
        -- Migration: add new options to existing sets
        for i = 1, 2 do
            local set = db.pinnedFrames.sets[i]
            if set then
                if set.autoAddTanks == nil then set.autoAddTanks = false end
                if set.autoAddHealers == nil then set.autoAddHealers = false end
                if set.autoAddDPS == nil then set.autoAddDPS = false end
                if set.keepOfflinePlayers == nil then set.keepOfflinePlayers = true end
                if set.columnAnchor == nil then set.columnAnchor = "START" end
                if set.frameAnchor == nil then set.frameAnchor = "START" end
                if set.locked == nil then set.locked = false end
                if set.showLabel == nil then set.showLabel = false end
                if set.players == nil then set.players = {} end
                if set.manualPlayers == nil then set.manualPlayers = {} end
                if set.frameType == nil then set.frameType = "player" end
                if set.testCount == nil then set.testCount = 3 end
            end
        end
        
        -- Current active tab (persist across page refreshes so switching tabs
        -- between sets with different frameTypes — which calls RefreshCurrentPage —
        -- doesn't snap back to tab 1)
        pagePinnedFrames.persistedTab = pagePinnedFrames.persistedTab or 1
        local activeHighlightTab = pagePinnedFrames.persistedTab
        local tabButtons = {}
        local controlsToRefresh = {}
        
        local function GetCurrentSet()
            return db.pinnedFrames.sets[activeHighlightTab]
        end

        local function IsCurrentBossMode()
            local s = GetCurrentSet()
            return s and s.frameType == "friendlyBoss"
        end

        local function RefreshControls()
            for _, ctrl in ipairs(controlsToRefresh) do
                if ctrl.Refresh then ctrl:Refresh() end
            end
        end
        
        local function RefreshTabs()
            local themeColor = GUI.GetThemeColor()
            for i, tab in ipairs(tabButtons) do
                local set = db.pinnedFrames.sets[i]
                local isActive = (i == activeHighlightTab)
                if isActive then
                    tab:SetBackdropColor(0.18, 0.18, 0.18, 1)
                    tab:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
                    tab.text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
                else
                    tab:SetBackdropColor(0.1, 0.1, 0.1, 1)
                    tab:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
                    tab.text:SetTextColor(0.5, 0.5, 0.5)
                end
                local displayName = set.name
                if displayName == L["Highlight"] .. " " .. i or displayName == "" then displayName = L["Highlight"] .. " " .. i end
                tab.text:SetText(displayName)
            end
        end
        
        -- ===== HEADER GROUP (full width) =====
        local headerGroup = GUI:CreateSettingsGroup(self.child, 560)
        headerGroup:AddWidget(GUI:CreateHeader(self.child, L["Pinned Frames"]), 40)
        headerGroup:AddWidget(GUI:CreateLabel(self.child, L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."], 530), 40)
        Add(headerGroup, nil, "both")
        
        -- Tab container
        local tabContainer = CreateFrame("Frame", nil, self.child)
        tabContainer:SetSize(460, 32)
        Add(tabContainer, 32, "both")
        
        for i = 1, HIGHLIGHT_MAX_SETS do
            local tab = CreateFrame("Button", nil, tabContainer, "BackdropTemplate")
            tab:SetSize(120, 28)
            tab:SetPoint("LEFT", tabContainer, "LEFT", (i - 1) * 124, 0)
            tab:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            tab.text = tab:CreateFontString(nil, "OVERLAY", "DFFontNormal")
            tab.text:SetPoint("CENTER")
            tab.text:SetText(L["Highlight"] .. " " .. i)
            tab:SetScript("OnClick", function()
                local oldSet = GetCurrentSet()
                local oldType = oldSet and oldSet.frameType
                activeHighlightTab = i
                pagePinnedFrames.persistedTab = i
                local newSet = GetCurrentSet()
                local newType = newSet and newSet.frameType
                RefreshTabs()
                if oldType ~= newType and GUI.RefreshCurrentPage then
                    -- Frame type differs between tabs — rebuild page to show/hide boss vs player controls
                    GUI.RefreshCurrentPage()
                else
                    RefreshControls()
                    if GUI.RefreshAllOverrideIndicators then GUI.RefreshAllOverrideIndicators() end
                end
            end)
            tab:SetScript("OnEnter", function(s) if activeHighlightTab ~= i then s:SetBackdropBorderColor(0.4, 0.4, 0.4, 1); s.text:SetTextColor(0.7, 0.7, 0.7) end end)
            tab:SetScript("OnLeave", function() RefreshTabs() end)
            tabButtons[i] = tab
        end
        RefreshTabs()
        
        AddSpace(10, "both")
        
        -- Helper to get the pinned override key for the current active tab
        local function GetPinnedKey(dbKey)
            return "pinned." .. activeHighlightTab .. "." .. dbKey
        end
        
        -- Add override indicators (star, reset, global text) to a pinned frame control
        local function AddPinnedOverrideIndicators(container, lbl, dbKey, onReset)
            local AutoProfilesUI = DF.AutoProfilesUI
            if not AutoProfilesUI then return end
            
            -- Reset button
            local resetBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
            resetBtn:SetSize(18, 18)
            resetBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
            resetBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            resetBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            resetBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            resetBtn:Hide()
            
            local resetIcon = resetBtn:CreateTexture(nil, "OVERLAY")
            resetIcon:SetPoint("CENTER")
            resetIcon:SetSize(12, 12)
            resetIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\refresh")
            resetIcon:SetVertexColor(0.6, 0.6, 0.6)
            
            resetBtn:SetScript("OnEnter", function(s)
                s:SetBackdropBorderColor(1, 0.8, 0.2, 1)
                resetIcon:SetVertexColor(1, 0.8, 0.2)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Reset to Global"])
                GameTooltip:Show()
            end)
            resetBtn:SetScript("OnLeave", function(s)
                s:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                resetIcon:SetVertexColor(0.6, 0.6, 0.6)
                GameTooltip:Hide()
            end)
            resetBtn:SetScript("OnClick", function()
                if onReset then onReset() end
            end)
            container.overrideResetBtn = resetBtn
            
            -- Star icon (Button with invisible backdrop for reliable mouse events)
            local starFrame = CreateFrame("Button", nil, container, "BackdropTemplate")
            starFrame:SetSize(18, 18)
            starFrame:SetPoint("RIGHT", resetBtn, "LEFT", -2, 0)
            starFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            starFrame:SetBackdropColor(0, 0, 0, 0)
            starFrame:SetBackdropBorderColor(0, 0, 0, 0)
            starFrame:Hide()
            local starIcon = starFrame:CreateTexture(nil, "OVERLAY")
            starIcon:SetSize(12, 12)
            starIcon:SetPoint("CENTER")
            starIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
            starIcon:SetVertexColor(1, 0.8, 0.2)
            starFrame:SetScript("OnEnter", function(s)
                if s.tooltipText then
                    GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                    GameTooltip:SetText(s.tooltipText)
                    if s.tooltipSubText then
                        GameTooltip:AddLine(s.tooltipSubText, 1, 1, 1, true)
                    end
                    GameTooltip:Show()
                end
            end)
            starFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            container.overrideStar = starFrame
            
            -- Global value text
            local globalText = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            globalText:SetPoint("LEFT", lbl, "RIGHT", 4, 0)
            globalText:SetTextColor(0.4, 0.4, 0.4)
            globalText:Hide()
            container.overrideGlobalText = globalText
            
            -- Checkmark icon
            local checkIcon = container:CreateTexture(nil, "OVERLAY")
            checkIcon:SetSize(8, 8)
            checkIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
            checkIcon:SetVertexColor(0.3, 0.7, 0.3)
            checkIcon:Hide()
            container.overrideCheckIcon = checkIcon
            
            container.UpdateOverrideIndicators = function(self)
                -- Debug mode
                if GUI.IsOverrideDebugMode and GUI.IsOverrideDebugMode() then
                    self.overrideStar:Show()
                    self.overrideResetBtn:Show()
                    self.overrideGlobalText:SetText("(debug)")
                    self.overrideGlobalText:SetTextColor(1, 0.8, 0.2)
                    self.overrideGlobalText:Show()
                    self.overrideCheckIcon:Hide()
                    return
                end
                
                -- Only show in raid mode while editing
                if not GUI or GUI.SelectedMode ~= "raid" then
                    self.overrideStar:Hide(); self.overrideResetBtn:Hide()
                    self.overrideGlobalText:Hide(); self.overrideCheckIcon:Hide()
                    return
                end
                
                local isEditing = AutoProfilesUI and AutoProfilesUI:IsEditing()
                local pinnedKey = GetPinnedKey(dbKey)
                local isRuntimeOverridden = AutoProfilesUI and AutoProfilesUI:IsOverriddenByRuntime(pinnedKey)

                -- Hide everything if not editing AND not runtime-overridden
                if not isEditing and not isRuntimeOverridden then
                    self.overrideStar:Hide(); self.overrideResetBtn:Hide()
                    self.overrideGlobalText:Hide(); self.overrideCheckIcon:Hide()
                    return
                end

                -- Runtime override mode: show star + global value, no reset button
                if isRuntimeOverridden and not isEditing then
                    self.overrideStar.tooltipText = L["Overridden by Auto Layout"]
                    self.overrideStar.tooltipSubText = L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."]
                    self.overrideStar:Show()
                    self.overrideResetBtn:Hide()
                    self.overrideCheckIcon:Hide()

                    local globalValue = AutoProfilesUI:GetRuntimeGlobalValue(pinnedKey)
                    local globalDisplay
                    if type(globalValue) == "boolean" then
                        globalDisplay = globalValue and L["Yes"] or L["No"]
                    elseif type(globalValue) == "number" then
                        if globalValue == math.floor(globalValue) then
                            globalDisplay = tostring(globalValue)
                        else
                            globalDisplay = string.format("%.2f", globalValue)
                        end
                    elseif type(globalValue) == "table" then
                        globalDisplay = "..."
                    else
                        globalDisplay = tostring(globalValue or "None")
                    end

                    self.overrideGlobalText:SetText("Global: " .. globalDisplay)
                    self.overrideGlobalText:SetTextColor(0.5, 0.5, 0.5)
                    self.overrideGlobalText:Show()
                    return
                end

                -- Editing mode: existing behavior
                local isOverridden = AutoProfilesUI:IsSettingOverridden(pinnedKey)
                local globalValue = AutoProfilesUI:GetGlobalValue(pinnedKey)

                if isOverridden then
                    self.overrideStar.tooltipText = L["Overridden in this layout"]
                    self.overrideStar.tooltipSubText = L["This setting differs from the global profile value. Click the reset button to revert."]
                    self.overrideStar:Show()
                    self.overrideResetBtn:Show()
                else
                    self.overrideStar:Hide()
                    self.overrideResetBtn:Hide()
                end

                -- Format global value for display
                local globalDisplay
                if type(globalValue) == "boolean" then
                    globalDisplay = globalValue and L["Yes"] or L["No"]
                elseif type(globalValue) == "number" then
                    if globalValue == math.floor(globalValue) then
                        globalDisplay = tostring(globalValue)
                    else
                        globalDisplay = string.format("%.2f", globalValue)
                    end
                elseif type(globalValue) == "table" then
                    globalDisplay = "..."
                else
                    globalDisplay = tostring(globalValue or "None")
                end

                -- Show global text with check/star positioning
                if isOverridden then
                    self.overrideGlobalText:SetText("Global: " .. globalDisplay)
                    self.overrideGlobalText:SetTextColor(0.4, 0.4, 0.4)
                    self.overrideGlobalText:Show()
                    self.overrideCheckIcon:Hide()
                else
                    self.overrideGlobalText:SetText("Global: " .. globalDisplay)
                    self.overrideGlobalText:SetTextColor(0.3, 0.7, 0.3)
                    self.overrideGlobalText:Show()
                    self.overrideCheckIcon:SetPoint("RIGHT", self.overrideGlobalText, "LEFT", -2, 0)
                    self.overrideCheckIcon:Show()
                end
            end
            
            -- Register for global refresh
            if GUI.RegisterOverrideWidget then
                GUI.RegisterOverrideWidget(container)
            end
        end
        
        -- Helper function to create refreshable checkbox
        local function CreateRefreshableCheckbox(parent, label, dbKey, callback)
            local container = CreateFrame("Frame", nil, parent)
            container:SetSize(250, 24)
            local cb = CreateFrame("CheckButton", nil, container, "BackdropTemplate")
            cb:SetSize(18, 18)
            cb:SetPoint("LEFT", 0, 0)
            cb:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            cb:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            cb:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
            cb.Check = cb:CreateTexture(nil, "OVERLAY")
            cb.Check:SetTexture("Interface\\Buttons\\WHITE8x8")
            local tc = GUI.GetThemeColor()
            cb.Check:SetVertexColor(tc.r, tc.g, tc.b)
            cb.Check:SetPoint("CENTER")
            cb.Check:SetSize(10, 10)
            cb:SetCheckedTexture(cb.Check)
            local txt = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            txt:SetPoint("LEFT", cb, "RIGHT", 8, 0)
            txt:SetText(label)
            txt:SetTextColor(0.8, 0.8, 0.8)
            cb:SetScript("OnClick", function(s)
                local val = s:GetChecked()
                -- Runtime override protection
                if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
                   and DF.AutoProfilesUI:HandleRuntimeWrite(GetPinnedKey(dbKey), val) then
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
                    return
                end
                GetCurrentSet()[dbKey] = val
                if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                    DF.AutoProfilesUI:SetProfileSetting(GetPinnedKey(dbKey), val)
                end
                if callback then callback(GetCurrentSet()) end
                DF:UpdateAll()
                if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
            end)
            container.Refresh = function()
                cb:SetChecked(GetCurrentSet()[dbKey])
                if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
            end
            
            -- Override indicators with reset
            AddPinnedOverrideIndicators(container, txt, dbKey, function()
                local AutoProfilesUI = DF.AutoProfilesUI
                if AutoProfilesUI then
                    AutoProfilesUI:ResetProfileSetting(GetPinnedKey(dbKey))
                    cb:SetChecked(GetCurrentSet()[dbKey])
                    if callback then callback(GetCurrentSet()) end
                    DF:UpdateAll()
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
                end
            end)
            
            container.Refresh()
            table.insert(controlsToRefresh, container)
            return container
        end
        
        -- Helper function to create refreshable slider
        local function CreateRefreshableSlider(parent, label, minVal, maxVal, step, dbKey, callback)
            local container = CreateFrame("Frame", nil, parent)
            container:SetSize(250, 50)
            local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            lbl:SetPoint("TOPLEFT", 0, 0)
            lbl:SetText(label)
            lbl:SetTextColor(0.8, 0.8, 0.8)
            local track = CreateFrame("Frame", nil, container, "BackdropTemplate")
            track:SetPoint("TOPLEFT", 0, -18)
            track:SetSize(170, 8)
            track:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            track:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            track:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
            local fill = track:CreateTexture(nil, "ARTWORK")
            fill:SetPoint("LEFT", 1, 0)
            fill:SetHeight(6)
            local tc = GUI.GetThemeColor()
            fill:SetColorTexture(tc.r, tc.g, tc.b, 0.8)
            local slider = CreateFrame("Slider", nil, container)
            slider:SetPoint("TOPLEFT", 0, -18)
            slider:SetSize(170, 8)
            slider:SetOrientation("HORIZONTAL")
            slider:SetMinMaxValues(minVal, maxVal)
            slider:SetValueStep(step)
            slider:SetObeyStepOnDrag(true)
            slider:SetHitRectInsets(-4, -4, -8, -8)
            local thumb = slider:CreateTexture(nil, "OVERLAY")
            thumb:SetSize(12, 16)
            thumb:SetColorTexture(tc.r, tc.g, tc.b, 1)
            slider:SetThumbTexture(thumb)
            local input = CreateFrame("EditBox", nil, container, "BackdropTemplate")
            input:SetPoint("LEFT", track, "RIGHT", 8, 0)
            input:SetSize(50, 20)
            input:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            input:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            input:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
            input:SetFontObject(DFFontHighlightSmall)
            input:SetJustifyH("CENTER")
            input:SetAutoFocus(false)
            input:SetTextInsets(2, 2, 0, 0)
            local function UpdateFill() local pct = (slider:GetValue() - minVal) / (maxVal - minVal); fill:SetWidth(math.max(1, pct * 168)) end
            local function UpdateValue(val) slider:SetValue(val); input:SetText(step < 1 and string.format("%.1f", val) or string.format("%d", val)); UpdateFill() end
            slider:SetScript("OnValueChanged", function(_, value)
                -- Runtime override protection
                if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
                   and DF.AutoProfilesUI:HandleRuntimeWrite(GetPinnedKey(dbKey), value) then
                    input:SetText(step < 1 and string.format("%.1f", value) or string.format("%d", value))
                    UpdateFill()
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
                    return
                end
                GetCurrentSet()[dbKey] = value
                input:SetText(step < 1 and string.format("%.1f", value) or string.format("%d", value))
                UpdateFill()
                if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                    DF.AutoProfilesUI:SetProfileSetting(GetPinnedKey(dbKey), value)
                end
                if callback then callback() end
                if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
            end)
            input:SetScript("OnEnterPressed", function(s)
                local val = tonumber(s:GetText())
                if val then
                    val = math.max(minVal, math.min(maxVal, val))
                    -- Runtime override protection
                    if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
                       and DF.AutoProfilesUI:HandleRuntimeWrite(GetPinnedKey(dbKey), val) then
                        s:SetText(step < 1 and string.format("%.1f", val) or string.format("%d", val))
                        slider:SetValue(val)
                        UpdateFill()
                        if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
                        s:ClearFocus()
                        return
                    end
                    GetCurrentSet()[dbKey] = val
                    slider:SetValue(val)
                    s:SetText(step < 1 and string.format("%.1f", val) or string.format("%d", val))
                    UpdateFill()
                    if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                        DF.AutoProfilesUI:SetProfileSetting(GetPinnedKey(dbKey), val)
                    end
                    if callback then callback() end
                    DF:UpdateAll()
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
                end
                s:ClearFocus()
            end)
            input:SetScript("OnEscapePressed", function(s) s:ClearFocus(); UpdateValue(GetCurrentSet()[dbKey]) end)
            container.Refresh = function()
                UpdateValue(GetCurrentSet()[dbKey] or minVal)
                if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
            end
            
            -- Override indicators with reset
            AddPinnedOverrideIndicators(container, lbl, dbKey, function()
                local AutoProfilesUI = DF.AutoProfilesUI
                if AutoProfilesUI then
                    AutoProfilesUI:ResetProfileSetting(GetPinnedKey(dbKey))
                    UpdateValue(GetCurrentSet()[dbKey] or minVal)
                    if callback then callback() end
                    DF:UpdateAll()
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators() end
                end
            end)
            
            container.Refresh()
            table.insert(controlsToRefresh, container)
            return container
        end
        
        -- Helper function to create refreshable dropdown
        local function CreateRefreshableDropdown(parent, label, options, dbKey, callback)
            local wrapper = CreateFrame("Frame", nil, parent)
            wrapper:SetSize(250, 50)
            local lbl = wrapper:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            lbl:SetPoint("TOPLEFT", 0, 0)
            lbl:SetText(label)
            lbl:SetTextColor(0.8, 0.8, 0.8)
            local btn = CreateFrame("Button", nil, wrapper, "BackdropTemplate")
            btn:SetPoint("TOPLEFT", 0, -16)
            btn:SetSize(220, 24)
            btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            btn:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            btn.Text:SetPoint("LEFT", 8, 0)
            btn.Text:SetPoint("RIGHT", -20, 0)
            btn.Text:SetJustifyH("LEFT")
            btn.Text:SetTextColor(0.8, 0.8, 0.8)
            local arrow = btn:CreateTexture(nil, "OVERLAY")
            arrow:SetPoint("RIGHT", -8, 0)
            arrow:SetSize(12, 12)
            arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
            arrow:SetVertexColor(0.5, 0.5, 0.5)
            local function UpdateText() btn.Text:SetText(options[GetCurrentSet()[dbKey]] or "Select...") end
            local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
            menuFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
            menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            menuFrame:SetClampedToScreen(true)
            menuFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            menuFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.98)
            menuFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            menuFrame:Hide()
            local menuHeight = 0
            local sortedOptions = {}
            for k, v in pairs(options) do table.insert(sortedOptions, {key = k, value = v}) end
            table.sort(sortedOptions, function(a, b) return tostring(a.value) < tostring(b.value) end)
            for idx, opt in ipairs(sortedOptions) do
                local menuBtn = CreateFrame("Button", nil, menuFrame)
                menuBtn:SetPoint("TOPLEFT", 2, -2 - (idx - 1) * 22)
                menuBtn:SetPoint("TOPRIGHT", -2, -2 - (idx - 1) * 22)
                menuBtn:SetHeight(22)
                menuBtn.Text = menuBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                menuBtn.Text:SetPoint("LEFT", 8, 0)
                menuBtn.Text:SetText(opt.value)
                menuBtn.Text:SetTextColor(0.8, 0.8, 0.8)
                menuBtn.Highlight = menuBtn:CreateTexture(nil, "HIGHLIGHT")
                menuBtn.Highlight:SetAllPoints()
                local tc = GUI.GetThemeColor()
                menuBtn.Highlight:SetColorTexture(tc.r, tc.g, tc.b, 0.3)
                menuBtn:SetScript("OnClick", function()
                    -- Runtime override protection
                    if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
                       and DF.AutoProfilesUI:HandleRuntimeWrite(GetPinnedKey(dbKey), opt.key) then
                        UpdateText()
                        menuFrame:Hide()
                        if wrapper.UpdateOverrideIndicators then wrapper:UpdateOverrideIndicators() end
                        return
                    end
                    GetCurrentSet()[dbKey] = opt.key
                    UpdateText()
                    menuFrame:Hide()
                    if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                        DF.AutoProfilesUI:SetProfileSetting(GetPinnedKey(dbKey), opt.key)
                    end
                    if callback then callback() end
                    if wrapper.UpdateOverrideIndicators then wrapper:UpdateOverrideIndicators() end
                end)
                menuHeight = menuHeight + 22
            end
            menuFrame:SetSize(220, menuHeight + 4)
            btn:SetScript("OnClick", function() if menuFrame:IsShown() then menuFrame:Hide() else menuFrame:Show() end end)
            btn:SetScript("OnEnter", function(s) s:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) end)
            btn:SetScript("OnLeave", function(s) s:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) end)
            wrapper.Refresh = function()
                UpdateText()
                if wrapper.UpdateOverrideIndicators then wrapper:UpdateOverrideIndicators() end
            end
            
            -- Override indicators with reset
            AddPinnedOverrideIndicators(wrapper, lbl, dbKey, function()
                local AutoProfilesUI = DF.AutoProfilesUI
                if AutoProfilesUI then
                    AutoProfilesUI:ResetProfileSetting(GetPinnedKey(dbKey))
                    UpdateText()
                    if callback then callback() end
                    if wrapper.UpdateOverrideIndicators then wrapper:UpdateOverrideIndicators() end
                end
            end)
            
            UpdateText()
            table.insert(controlsToRefresh, wrapper)
            return wrapper
        end
        
        -- Helper function to update layout
        local function UpdateHighlightLayout()
            if DF.PinnedFrames then
                DF.PinnedFrames:ApplyLayoutSettings(activeHighlightTab)
                DF.PinnedFrames:ResizeContainer(activeHighlightTab)
                -- If a preview container is active for the edited mode, keep it in sync
                DF.PinnedFrames:UpdatePreviewSet(activeHighlightTab)
            end
        end
        
        -- Forward declaration for roster widget and unit selection header
        local rosterWidget
        local unitSelHeader
        
        -- Helper: sync players array to override system after auto-populate
        local function SyncPlayersOverride()
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                local players = GetCurrentSet().players
                local copy = {}
                for i, v in ipairs(players) do copy[i] = v end
                DF.AutoProfilesUI:SetProfileSetting(GetPinnedKey("players"), copy)
                if unitSelHeader and unitSelHeader.UpdateOverrideIndicators then
                    unitSelHeader:UpdateOverrideIndicators()
                end
            end
        end
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        
        -- SetEnabled / SetLocked / SetShowLabel internally use GetSetDB → IsInRaid(),
        -- so calling them while editing the inactive mode would mutate the active
        -- mode's state. Only call them when the selected mode matches the live mode;
        -- otherwise the DB write from the checkbox itself is enough and the preview
        -- reflects the change.
        local function IsEditingActiveMode()
            local actualMode = IsInRaid() and "raid" or "party"
            return GUI.SelectedMode == actualMode
        end

        -- Refresh Test Mode frames if active — enable/lock toggles affect
        -- mover visibility and whether test frames should render at all.
        local function RefreshTestModeIfActive()
            if DF.PinnedFrames.IsTestModeActive and DF.PinnedFrames:IsTestModeActive() then
                DF.PinnedFrames:ExitTestMode()
                DF.PinnedFrames:EnterTestMode()
            end
        end

        settingsGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Enable"], "enabled", function()
            if not DF.PinnedFrames then return end
            if IsEditingActiveMode() then
                DF.PinnedFrames:SetEnabled(activeHighlightTab, GetCurrentSet().enabled)
            end
            DF.PinnedFrames:UpdatePreviewSet(activeHighlightTab)
            RefreshTestModeIfActive()
        end), 28)
        settingsGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Lock Position"], "locked", function()
            if not DF.PinnedFrames then return end
            if IsEditingActiveMode() then
                DF.PinnedFrames:SetLocked(activeHighlightTab, GetCurrentSet().locked)
            end
            DF.PinnedFrames:UpdatePreviewSet(activeHighlightTab)
            RefreshTestModeIfActive()
        end), 28)
        settingsGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Show Label"], "showLabel", function()
            if not DF.PinnedFrames then return end
            if IsEditingActiveMode() then
                DF.PinnedFrames:SetShowLabel(activeHighlightTab, GetCurrentSet().showLabel)
            end
            DF.PinnedFrames:UpdatePreviewSet(activeHighlightTab)
            RefreshTestModeIfActive()
        end), 28)

        -- Reset Position button
        local resetPosBtn = CreateFrame("Button", nil, self.child, "BackdropTemplate")
        resetPosBtn:SetSize(130, 22)
        resetPosBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        resetPosBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        resetPosBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        local resetPosText = resetPosBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        resetPosText:SetPoint("CENTER")
        resetPosText:SetText(L["Reset Position"])
        resetPosBtn:SetScript("OnClick", function()
            local set = GetCurrentSet()
            if not set or not DF.PinnedFrames then return end

            -- Reset position in the edited (selected) mode's DB
            set.position = { point = "CENTER", x = 0, y = 0 }

            -- Apply to the real container only if editing the actual mode
            local actualMode = IsInRaid() and "raid" or "party"
            if GUI.SelectedMode == actualMode then
                local container = DF.PinnedFrames.containers[activeHighlightTab]
                if container then
                    container:ClearAllPoints()
                    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                    DF.PinnedFrames:ApplyLayoutSettings(activeHighlightTab)
                end
            end

            -- Keep the preview in sync if one is active for the edited mode
            DF.PinnedFrames:UpdatePreviewSet(activeHighlightTab)
        end)
        resetPosBtn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.25, 0.25, 0.25, 0.9)
        end)
        resetPosBtn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        end)
        settingsGroup:AddWidget(resetPosBtn, 28)

        -- Label name input
        local nameInputContainer = CreateFrame("Frame", nil, self.child)
        nameInputContainer:SetSize(250, 44)
        local nameLabel = nameInputContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        nameLabel:SetPoint("TOPLEFT", 0, 0)
        nameLabel:SetText(L["Label Name"])
        nameLabel:SetTextColor(0.8, 0.8, 0.8)
        local nameInput = CreateFrame("EditBox", nil, nameInputContainer, "BackdropTemplate")
        nameInput:SetPoint("TOPLEFT", 0, -15)
        nameInput:SetSize(220, 24)
        nameInput:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        nameInput:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        nameInput:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        nameInput:SetFontObject(DFFontHighlight)
        nameInput:SetTextInsets(8, 8, 0, 0)
        nameInput:SetAutoFocus(false)
        nameInput:SetMaxLetters(30)
        nameInput:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
        nameInput:SetScript("OnEnterPressed", function(s) s:ClearFocus() end)
        nameInput:SetScript("OnEditFocusLost", function(s)
            GetCurrentSet().name = s:GetText()
            RefreshTabs()
            if DF.PinnedFrames then
                DF.PinnedFrames:UpdateLabel(activeHighlightTab)
                -- Refresh preview label text too if a preview is active
                DF.PinnedFrames:UpdatePreviewSet(activeHighlightTab)
            end
        end)
        nameInputContainer.Refresh = function() nameInput:SetText(GetCurrentSet().name or "") end
        table.insert(controlsToRefresh, nameInputContainer)
        settingsGroup:AddWidget(nameInputContainer, 48)
        
        Add(settingsGroup, nil, 1)
        
        -- ===== FRAME TYPE GROUP (full width) =====
        local frameTypeGroup = GUI:CreateSettingsGroup(self.child, 560)
        local frameTypeHeader = GUI:CreateHeader(self.child, L["Frame Type"])
        -- Gold "New" badge next to the header (the Friendly Boss NPCs option was
        -- introduced in 4.3.2). Clears when the user navigates away from the
        -- Pinned Frames tab and stays cleared across sessions.
        GUI:AddSectionNewBadge(frameTypeHeader, "general_pinnedframes", "frameType")
        frameTypeGroup:AddWidget(frameTypeHeader, 40)

        local frameTypeOptions = {
            player = L["Player Frames"],
            friendlyBoss = L["Friendly Boss NPCs"],
        }

        local function OnFrameTypeChanged()
            if not DF.PinnedFrames then return end
            if InCombatLockdown() then return end
            DF.PinnedFrames:Reinitialize()
            if GUI.RefreshCurrentPage then GUI.RefreshCurrentPage() end
        end

        frameTypeGroup:AddWidget(
            CreateRefreshableDropdown(self.child, L["Frame Type"], frameTypeOptions, "frameType", OnFrameTypeChanged),
            55
        )

        -- Test Count slider: how many test frames show when Test Mode is
        -- active. Boss mode: 1–8 (hard WoW limit). Player mode: 1–10
        -- (covers typical pinned set sizes; range kept modest since pinned
        -- sets rarely need more than that for layout verification).
        local function OnTestCountChanged()
            if not DF.PinnedFrames then return end
            if DF.PinnedFrames.IsTestModeActive and DF.PinnedFrames:IsTestModeActive() then
                DF.PinnedFrames:ExitTestMode()
                DF.PinnedFrames:EnterTestMode()
            end
        end
        local testMax = IsCurrentBossMode() and 8 or 10
        frameTypeGroup:AddWidget(
            CreateRefreshableSlider(self.child, L["Test Count"], 1, testMax, 1, "testCount", OnTestCountChanged),
            55
        )

        Add(frameTypeGroup, nil, "both")
        AddSpace(10, "both")

        -- ===== LAYOUT GROUP (Column 2) =====
        local layoutGroup = GUI:CreateSettingsGroup(self.child, 280)
        layoutGroup:AddWidget(GUI:CreateHeader(self.child, L["Layout"]), 40)
        
        local directionOptions = { HORIZONTAL= L["Horizontal"], VERTICAL= L["Vertical"] }
        layoutGroup:AddWidget(CreateRefreshableDropdown(self.child, L["Direction"], directionOptions, "growDirection", UpdateHighlightLayout), 55)
        
        local frameAnchorOptions = { START= L["Start (Left/Top)"], CENTER= L["Center"], END= L["End (Right/Bottom)"] }
        layoutGroup:AddWidget(CreateRefreshableDropdown(self.child, L["Frame Growth"], frameAnchorOptions, "frameAnchor", UpdateHighlightLayout), 55)

        local columnAnchorOptions = { START= L["Start (Left/Top)"], CENTER= L["Center"], END= L["End (Right/Bottom)"] }
        layoutGroup:AddWidget(CreateRefreshableDropdown(self.child, L["Column Growth"], columnAnchorOptions, "columnAnchor", UpdateHighlightLayout), 55)
        
        layoutGroup:AddWidget(CreateRefreshableSlider(self.child, L["Units Per Row"], 1, 10, 1, "unitsPerRow", UpdateHighlightLayout), 55)
        layoutGroup:AddWidget(CreateRefreshableSlider(self.child, L["Scale"], 0.5, 2.0, 0.1, "scale", UpdateHighlightLayout), 55)
        
        Add(layoutGroup, nil, 2)
        
        -- ===== SPACING GROUP (Column 1) =====
        local spacingGroup = GUI:CreateSettingsGroup(self.child, 280)
        spacingGroup:AddWidget(GUI:CreateHeader(self.child, L["Spacing"]), 40)
        spacingGroup:AddWidget(CreateRefreshableSlider(self.child, L["Horizontal Spacing"], -5, 50, 1, "horizontalSpacing", UpdateHighlightLayout), 55)
        spacingGroup:AddWidget(CreateRefreshableSlider(self.child, L["Vertical Spacing"], -5, 50, 1, "verticalSpacing", UpdateHighlightLayout), 55)
        Add(spacingGroup, nil, 1)
        
        if not IsCurrentBossMode() then
        -- ===== AUTO-POPULATE GROUP (Column 2) =====
        local autoPopGroup = GUI:CreateSettingsGroup(self.child, 280)
        autoPopGroup:AddWidget(GUI:CreateHeader(self.child, L["Auto-Populate"]), 40)
        autoPopGroup:AddWidget(GUI:CreateLabel(self.child, L["Automatically add players by role when they join your group."], 250), 30)

        autoPopGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Auto-add Tanks"], "autoAddTanks", function()
            if GetCurrentSet().autoAddTanks and DF.PinnedFrames then
                DF.PinnedFrames:AutoPopulateSet(GetCurrentSet())
                DF.PinnedFrames:UpdateHeaderNameList(activeHighlightTab)
                if rosterWidget then rosterWidget:Refresh() end
                SyncPlayersOverride()
            end
        end), 28)
        autoPopGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Auto-add Healers"], "autoAddHealers", function()
            if GetCurrentSet().autoAddHealers and DF.PinnedFrames then
                DF.PinnedFrames:AutoPopulateSet(GetCurrentSet())
                DF.PinnedFrames:UpdateHeaderNameList(activeHighlightTab)
                if rosterWidget then rosterWidget:Refresh() end
                SyncPlayersOverride()
            end
        end), 28)
        autoPopGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Auto-add DPS"], "autoAddDPS", function()
            if GetCurrentSet().autoAddDPS and DF.PinnedFrames then
                DF.PinnedFrames:AutoPopulateSet(GetCurrentSet())
                DF.PinnedFrames:UpdateHeaderNameList(activeHighlightTab)
                if rosterWidget then rosterWidget:Refresh() end
                SyncPlayersOverride()
            end
        end), 28)
        autoPopGroup:AddWidget(CreateRefreshableCheckbox(self.child, L["Keep when offline/left"], "keepOfflinePlayers", function() end), 28)

        Add(autoPopGroup, nil, 2)
        end -- not IsCurrentBossMode
        
        if not IsCurrentBossMode() then
        -- ===== UNIT SELECTION (full width) =====
        AddSpace(10, "both")

        -- Unit Selection header with override indicator
        unitSelHeader = CreateFrame("Frame", nil, self.child)
        unitSelHeader:SetSize(500, 40)
        local unitSelTitle = unitSelHeader:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        unitSelTitle:SetPoint("LEFT", 0, 0)
        unitSelTitle:SetText(L["Unit Selection"])
        unitSelTitle:SetTextColor(1, 1, 1)

        -- Override indicator for players list (header-level)
        AddPinnedOverrideIndicators(unitSelHeader, unitSelTitle, "players", function()
            local AutoProfilesUI = DF.AutoProfilesUI
            if AutoProfilesUI then
                AutoProfilesUI:ResetProfileSetting(GetPinnedKey("players"))
                if rosterWidget and rosterWidget.Refresh then rosterWidget:Refresh() end
                if DF.PinnedFrames then DF.PinnedFrames:UpdateHeaderNameList(activeHighlightTab) end
                if unitSelHeader.UpdateOverrideIndicators then unitSelHeader:UpdateOverrideIndicators() end
            end
        end)
        unitSelHeader.Refresh = function(self)
            if self.UpdateOverrideIndicators then self:UpdateOverrideIndicators() end
        end

        Add(unitSelHeader, 40, "both")

        rosterWidget = GUI:CreateHighlightRosterWidget(
            self.child,
            function() return GetCurrentSet().players end,
            function(players)
                local set = GetCurrentSet()
                set.players = players
                -- Sync manualPlayers: every player currently in the list via GUI is manual.
                -- Rebuild the lookup to match exactly what's in the list now.
                if not set.manualPlayers then set.manualPlayers = {} end
                local newManual = {}
                for _, name in ipairs(players) do
                    -- Preserve existing manual entries, add any new ones
                    newManual[name] = true
                end
                set.manualPlayers = newManual
                if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                    -- Deep copy the players array for the override
                    local copy = {}
                    for i, v in ipairs(players) do copy[i] = v end
                    DF.AutoProfilesUI:SetProfileSetting(GetPinnedKey("players"), copy)
                    if unitSelHeader.UpdateOverrideIndicators then unitSelHeader:UpdateOverrideIndicators() end
                end
            end,
            function()
                if DF.PinnedFrames then DF.PinnedFrames:UpdateHeaderNameList(activeHighlightTab) end
            end
        )

        local originalRefresh = rosterWidget.Refresh
        rosterWidget.Refresh = function(s)
            if originalRefresh then originalRefresh(s) end
            if unitSelHeader.UpdateOverrideIndicators then unitSelHeader:UpdateOverrideIndicators() end
        end
        table.insert(controlsToRefresh, rosterWidget)
        table.insert(controlsToRefresh, unitSelHeader)
        Add(rosterWidget, 340, "both")
        end -- not IsCurrentBossMode

        RefreshControls()

        -- Show preview containers if editing a non-active mode
        -- (e.g. raid settings while actually in a party): lets the user
        -- position/scale the pinned frames for that mode without being in it.
        if DF.PinnedFrames then
            DF.PinnedFrames:ShowPreview(GUI.SelectedMode)
        end
    end)

    pagePinnedFrames:SetScript("OnHide", function()
        if DF.PinnedFrames then
            DF.PinnedFrames:HidePreview()
        end
    end)

    -- General > Sorting
    local pageSorting = CreateSubTab("general", "general_sorting", L["Sorting"])
    BuildPage(pageSorting, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"sort", "selfPosition", "rolePriority", "classPriority"}, L["Sorting"], "general_sorting"), 25, 2)
        
        -- Helper function to trigger sort for current mode
        local function TriggerSortForCurrentMode()
            if DF.testMode or DF.raidTestMode then
                if DF.RefreshTestFramesWithLayout then DF:RefreshTestFramesWithLayout() end
                return
            end
            if DF.headersInitialized then DF:ApplyHeaderSettings() end
            -- Arena: ApplyHeaderSettings handles orientation but not sorting.
            -- Call ApplyArenaHeaderSorting directly for settings changes from the GUI.
            if DF.IsInArena and DF:IsInArena() then
                if not InCombatLockdown() and DF.ApplyArenaHeaderSorting then
                    DF:ApplyArenaHeaderSorting()
                end
            elseif GUI.SelectedMode == "raid" then
                if DF.SecureSort then
                    DF.SecureSort:PushRaidSortSettings()
                    DF.SecureSort:TriggerSecureRaidSort()
                end
            else
                if DF.Sort then DF.Sort:TriggerResort() end
            end
        end
        
        local function HideSortOptions(d)
            if d.useFrameSort and FrameSortApi then return true end
            return not d.sortEnabled
        end
        
        -- Store reference to role widget so we can refresh it
        local roleOrderWidget = nil
        
        -- ===== COMBAT STATUS BANNER (full width) =====
        local combatBanner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        combatBanner:SetSize(560, 45)
        combatBanner:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        
        local combatBannerIcon = combatBanner:CreateTexture(nil, "OVERLAY")
        combatBannerIcon:SetSize(20, 20)
        combatBannerIcon:SetPoint("LEFT", 12, 0)
        
        local combatBannerText = combatBanner:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        combatBannerText:SetPoint("LEFT", combatBannerIcon, "RIGHT", 8, 0)
        combatBannerText:SetPoint("RIGHT", -12, 0)
        combatBannerText:SetJustifyH("LEFT")
        combatBannerText:SetWordWrap(true)
        
        local function UpdateCombatBanner()
            if not db.sortEnabled then
                combatBanner:Hide()
                return
            end
            
            combatBanner:Show()
            
            local selfPos = db.sortSelfPosition or "SORTED"
            local hasAdvancedOptions = db.sortSeparateMeleeRanged or db.sortByClass or db.sortAlphabetical
            
            if hasAdvancedOptions then
                -- All groups limited
                combatBanner:SetBackdropColor(0.6, 0.3, 0.1, 0.9)
                combatBanner:SetBackdropBorderColor(0.8, 0.4, 0.1, 1)
                combatBannerIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\warning")
                combatBannerIcon:SetVertexColor(1, 0.6, 0.2)
                combatBannerText:SetText(L["Combat Limitation: All groups will not update with new players that join mid-combat."])
                combatBannerText:SetTextColor(1, 0.85, 0.7)
            elseif selfPos == "FIRST" or selfPos == "LAST" then
                -- Player's group limited
                combatBanner:SetBackdropColor(0.5, 0.45, 0.1, 0.9)
                combatBanner:SetBackdropBorderColor(0.7, 0.6, 0.1, 1)
                combatBannerIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\info")
                combatBannerIcon:SetVertexColor(1, 0.9, 0.3)
                combatBannerText:SetText(L["Combat Limitation: Your group will not update with new players that join mid-combat."])
                combatBannerText:SetTextColor(1, 0.95, 0.7)
            else
                -- Fully combat safe
                combatBanner:SetBackdropColor(0.1, 0.4, 0.2, 0.9)
                combatBanner:SetBackdropBorderColor(0.2, 0.6, 0.3, 1)
                combatBannerIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
                combatBannerIcon:SetVertexColor(0.3, 1, 0.5)
                combatBannerText:SetText(L["Fully Combat Safe: Frames will update normally during combat."])
                combatBannerText:SetTextColor(0.7, 1, 0.8)
            end
        end
        
        combatBanner.hideOn = HideSortOptions
        combatBanner.UpdateBanner = UpdateCombatBanner
        Add(combatBanner, 50, "both")
        
        -- Initial update
        UpdateCombatBanner()
        
        -- ===== SORTING OPTIONS GROUP (Column 1) =====
        local sortOptionsGroup = GUI:CreateSettingsGroup(self.child, 280)
        sortOptionsGroup:AddWidget(GUI:CreateHeader(self.child, L["Unit Frame Sorting"]), 40)
        sortOptionsGroup:AddWidget(GUI:CreateLabel(self.child, L["Sort party members by role, class, and name.\n\nSort order: Self Position > Role > Class > Name"], 250), 60)
        
        local raidSortNote = sortOptionsGroup:AddWidget(GUI:CreateLabel(self.child, L["Raid: Group layout sorts within each group.\nFlat grid layout sorts all players together."], 250), 35)
        raidSortNote.hideOn = function() return GUI.SelectedMode ~= "raid" end

        sortOptionsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Custom Sorting"], db, "sortEnabled", function()
            TriggerSortForCurrentMode()
            UpdateCombatBanner()
        end), 30)
        
        local sortMeleeRanged = sortOptionsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Separate Melee & Ranged DPS"], db, "sortSeparateMeleeRanged", function()
            TriggerSortForCurrentMode()
            if roleOrderWidget and roleOrderWidget.Refresh then roleOrderWidget.Refresh() end
            UpdateCombatBanner()
        end), 30)
        sortMeleeRanged.hideOn = HideSortOptions
        
        local sortByClass = sortOptionsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Sort by Class (within role)"], db, "sortByClass", function()
            TriggerSortForCurrentMode()
            self:RefreshStates()
            UpdateCombatBanner()
        end), 30)
        sortByClass.hideOn = HideSortOptions
        
        local sortAlphaValues = {
            [false] = L["Off"],
            ["AZ"] = L["A to Z"],
            ["ZA"] = L["Z to A"],
            _order = {false, "AZ", "ZA"},
        }
        local sortAlpha = sortOptionsGroup:AddWidget(GUI:CreateDropdown(self.child, L["Alphabetical (within class/role)"], sortAlphaValues, db, "sortAlphabetical", function()
            TriggerSortForCurrentMode()
            UpdateCombatBanner()
        end), 55)
        sortAlpha.hideOn = HideSortOptions
        
        Add(sortOptionsGroup, nil, 1)

        -- ===== FRAMESORT INTEGRATION GROUP (Column 1) =====
        if FrameSortApi then
            local frameSortGroup = GUI:CreateSettingsGroup(self.child, 280)
            frameSortGroup:AddWidget(GUI:CreateHeader(self.child, L["FrameSort Integration"]), 40)
            frameSortGroup:AddWidget(GUI:CreateLabel(self.child, format(L["FrameSort addon detected. Enable to let FrameSort control frame ordering.\n\n%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues."], "|cFFFF8800", "|r"), 250), 70)
            frameSortGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use FrameSort Addon"], db, "useFrameSort", function()
                -- Set both modes simultaneously
                local partyDB = DF:GetDB("party")
                local raidDB = DF:GetDB("raid")
                if partyDB then partyDB.useFrameSort = db.useFrameSort end
                if raidDB then raidDB.useFrameSort = db.useFrameSort end
                -- Notify the FrameSort module
                if DF.FrameSort and DF.FrameSort.OnSettingChanged then
                    DF.FrameSort:OnSettingChanged()
                end
                -- Trigger a re-sort so the change takes effect immediately
                TriggerSortForCurrentMode()
                -- Refresh options visibility
                self:RefreshStates()
            end), 30)
            Add(frameSortGroup, nil, 1)
        end

        -- ===== SELF POSITION GROUP (Column 1) =====
        local selfPosGroup = GUI:CreateSettingsGroup(self.child, 280)
        selfPosGroup:AddWidget(GUI:CreateHeader(self.child, L["Self Position"]), 40)
        
        local selfPosValues = {
            ["FIRST"] = L["Always First"],
            ["LAST"] = L["Always Last"],
            ["SORTED"] = L["Sorted with Group"],
            ["NORMAL"] = L["Sorted with Group"],
            _order = {"FIRST", "LAST", "SORTED"},
        }
        selfPosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Position"], selfPosValues, db, "sortSelfPosition", function()
            TriggerSortForCurrentMode()
            UpdateCombatBanner()
        end), 55)
        selfPosGroup.hideOn = HideSortOptions
        Add(selfPosGroup, nil, 1)
        
        -- ===== ROLE PRIORITY GROUP (Column 2) =====
        local rolePriorityGroup = GUI:CreateSettingsGroup(self.child, 280)
        rolePriorityGroup:AddWidget(GUI:CreateHeader(self.child, L["Role Priority"]), 40)
        rolePriorityGroup:AddWidget(GUI:CreateLabel(self.child, L["Drag to reorder. Top = first."], 250), 25)
        
        roleOrderWidget = GUI:CreateRoleOrderList(self.child, db, "sortRoleOrder", function()
            TriggerSortForCurrentMode()
        end, "sortSeparateMeleeRanged")
        rolePriorityGroup:AddWidget(roleOrderWidget, 135)
        rolePriorityGroup.hideOn = HideSortOptions
        Add(rolePriorityGroup, nil, 2)
        
        -- ===== CLASS PRIORITY GROUP (Column 2) =====
        local classPriorityGroup = GUI:CreateSettingsGroup(self.child, 280)
        classPriorityGroup:AddWidget(GUI:CreateHeader(self.child, L["Class Priority"]), 40)
        classPriorityGroup:AddWidget(GUI:CreateLabel(self.child, L["Drag to reorder. Top = first."], 250), 25)
        
        local classOrderWidget = GUI:CreateClassOrderList(self.child, db, "sortClassOrder", function()
            TriggerSortForCurrentMode()
        end)
        classPriorityGroup:AddWidget(classOrderWidget, 320)
        classPriorityGroup.hideOn = function(d) return not d.sortEnabled or not d.sortByClass end
        Add(classPriorityGroup, nil, 2)
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "general_frame", label = L["Frame"]},
            {pageId = "general_labels", label = L["Group Labels"]},
        }), 30, "both")
    end)
    
    -- General > Integrations
    local pageIntegrations = CreateSubTab("general", "general_integrations", L["Integrations"])
    BuildPage(pageIntegrations, function(self, db, Add, AddSpace, AddSyncPoint)
        -- ===== COLOR PICKER GROUP (Column 1) =====
        local colorPickerGroup = GUI:CreateSettingsGroup(self.child, 280)
        colorPickerGroup:AddWidget(GUI:CreateHeader(self.child, L["Color Picker"]), 40)
        
        colorPickerGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use DF Color Picker"], db, "colorPickerOverride", function()
            if db.colorPickerOverride or db.colorPickerGlobalOverride then
                local success = GUI:InstallColorPickerHook()
                if success then print("|cff00ff00DandersFrames:|r Color picker override enabled")
                elseif GUI:IsColorPickerHookInstalled() then print("|cff00ff00DandersFrames:|r Color picker override already active") end
            else
                GUI:UninstallColorPickerHook()
                print("|cffff9900DandersFrames:|r Color picker override disabled")
            end
        end), 30)
        colorPickerGroup:AddWidget(GUI:CreateLabel(self.child, L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."], 250), 40)
        
        colorPickerGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use DF Color Picker for All Addons"], db, "colorPickerGlobalOverride", function()
            if db.colorPickerOverride or db.colorPickerGlobalOverride then
                local success = GUI:InstallColorPickerHook()
                if success then print("|cff00ff00DandersFrames:|r Custom color picker enabled for all addons")
                elseif GUI:IsColorPickerHookInstalled() then print("|cff00ff00DandersFrames:|r Color picker hook already active") end
            else
                GUI:UninstallColorPickerHook()
                print("|cffff9900DandersFrames:|r Color picker hook disabled")
            end
        end), 30)
        colorPickerGroup:AddWidget(GUI:CreateLabel(self.child, L["Show the DF color picker when any addon opens a color picker."], 250), 30)
        
        Add(colorPickerGroup, nil, 1)
        
        -- ===== MASQUE GROUP (Column 2) =====
        local masqueGroup = GUI:CreateSettingsGroup(self.child, 280)
        masqueGroup:AddWidget(GUI:CreateHeader(self.child, L["Masque Integration"]), 40)
        
        if DF.Masque then
            masqueGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Let Masque Control Aura Borders"], db, "masqueBorderControl", function()
                if DF.ApplyLayout then DF:ApplyLayout() end
                if DF.UpdateAllFrames then DF:UpdateAllFrames() end
                print("|cff00ff00DandersFrames:|r Masque border control " .. (db.masqueBorderControl and L["enabled"] or L["disabled"]) .. ". A /reload may be needed.")
            end), 30)
            masqueGroup:AddWidget(GUI:CreateLabel(self.child, L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."], 250), 45)
        else
            masqueGroup:AddWidget(GUI:CreateLabel(self.child, L["Masque addon is not installed.\n\nMasque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable."], 250), 75)
        end
        
        Add(masqueGroup, nil, 2)
        
        -- ===== CLICK-THROUGH GROUP (Column 1) =====
        local clickThroughGroup = GUI:CreateSettingsGroup(self.child, 280)
        clickThroughGroup:AddWidget(GUI:CreateHeader(self.child, L["Click-Through Icons"]), 40)
        clickThroughGroup:AddWidget(GUI:CreateLabel(self.child, L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."], 250), 45)
        
        local buffDisableMouse = clickThroughGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Buff Icons Click-Through"], db, "buffDisableMouse", function()
            if DF.UpdateAuraClickThrough then DF:UpdateAuraClickThrough() end
        end), 30)
        buffDisableMouse.disableOn = function(d) return not d.showBuffs end
        
        local debuffDisableMouse = clickThroughGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Debuff Icons Click-Through"], db, "debuffDisableMouse", function()
            if DF.UpdateAuraClickThrough then DF:UpdateAuraClickThrough() end
        end), 30)
        debuffDisableMouse.disableOn = function(d) return not d.showDebuffs end
        
        local defensiveDisableMouse = clickThroughGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Defensive Icon Click-Through"], db, "defensiveIconDisableMouse", function()
            if DF.UpdateAuraClickThrough then DF:UpdateAuraClickThrough() end
        end), 30)
        defensiveDisableMouse.disableOn = function(d) return not d.defensiveIconEnabled end
        
        local tsDisableMouse = clickThroughGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Targeted Spell Click-Through"], db, "targetedSpellDisableMouse", function()
            if DF.UpdateAuraClickThrough then DF:UpdateAuraClickThrough() end
        end), 30)
        tsDisableMouse.disableOn = function(d) return not d.targetedSpellEnabled end
        
        clickThroughGroup:AddWidget(GUI:CreateLabel(self.child, L["⚠ Note: Click-through icons will not show tooltips."], 250), 25)
        
        Add(clickThroughGroup, nil, 1)
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_buffs", label = L["Buffs"]},
            {pageId = "auras_debuffs", label = L["Debuffs"]},
            {pageId = "auras_defensiveicon", label = L["Defensive Icon"]},
            {pageId = "indicators_targetedspells", label = L["Targeted Spells"]},
        }), 30, "both")
    end)
    
    -- Display > Class Colors
    local pageClassColors = CreateSubTab("display", "display_classcolors", L["Class Colors"])
    BuildPage(pageClassColors, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Class colors are shared across party/raid, stored at profile level
        local classColorsDB = DF.db.classColors
        if not classColorsDB then
            DF.db.classColors = {}
            classColorsDB = DF.db.classColors
        end
        
        -- Ordered list of all classes with display names
        local CLASS_LIST = {
            { token = "WARRIOR",      name = L["Warrior"] },
            { token = "PALADIN",      name = L["Paladin"] },
            { token = "HUNTER",       name = L["Hunter"] },
            { token = "ROGUE",        name = L["Rogue"] },
            { token = "PRIEST",       name = L["Priest"] },
            { token = "DEATHKNIGHT",  name = L["Death Knight"] },
            { token = "SHAMAN",       name = L["Shaman"] },
            { token = "MAGE",         name = L["Mage"] },
            { token = "WARLOCK",      name = L["Warlock"] },
            { token = "MONK",         name = L["Monk"] },
            { token = "DRUID",        name = L["Druid"] },
            { token = "DEMONHUNTER",  name = L["Demon Hunter"] },
            { token = "EVOKER",       name = L["Evoker"] },
        }
        
        -- ===== Column 1 =====
        local col1 = GUI:CreateSettingsGroup(self.child, 280)
        col1:AddWidget(GUI:CreateHeader(self.child, L["Class Colors"]), 40)
        col1:AddWidget(GUI:CreateLabel(self.child, L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."], 260), 50)
        
        -- Reset All button
        local resetAllBtn = CreateFrame("Button", nil, self.child, "BackdropTemplate")
        resetAllBtn:SetSize(260, 24)
        resetAllBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        resetAllBtn:SetBackdropColor(0.15, 0.15, 0.15, 1)
        resetAllBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        local resetAllText = resetAllBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        resetAllText:SetPoint("CENTER")
        resetAllText:SetText(L["Reset All to Default"])
        resetAllBtn:SetScript("OnClick", function()
            -- Reset all to Blizzard defaults
            for _, info in ipairs(CLASS_LIST) do
                local default = RAID_CLASS_COLORS[info.token]
                if default then
                    classColorsDB[info.token] = { r = default.r, g = default.g, b = default.b, a = 1 }
                end
            end
            DF:RefreshAllVisibleFrames()
            -- Refresh the options page to update swatches
            if pageClassColors and pageClassColors.Refresh then
                pageClassColors:Refresh()
            end
        end)
        resetAllBtn:SetScript("OnEnter", function(s) s:SetBackdropColor(0.25, 0.25, 0.25, 1) end)
        resetAllBtn:SetScript("OnLeave", function(s) s:SetBackdropColor(0.15, 0.15, 0.15, 1) end)
        col1:AddWidget(resetAllBtn, 30)
        
        -- First half of classes in column 1
        for i = 1, 7 do
            local info = CLASS_LIST[i]
            local token = info.token
            -- Initialize from Blizzard defaults if not customized
            if not classColorsDB[token] then
                local default = RAID_CLASS_COLORS[token]
                if default then
                    classColorsDB[token] = { r = default.r, g = default.g, b = default.b, a = 1 }
                end
            end
            col1:AddWidget(GUI:CreateColorPicker(self.child, info.name, classColorsDB, token, false, function()
                DF:RefreshAllVisibleFrames()
            end, function()
                DF:RefreshAllVisibleFrames()
            end, true), 30)
        end
        
        Add(col1, nil, 1)
        
        -- ===== Column 2 =====
        local col2 = GUI:CreateSettingsGroup(self.child, 280)
        col2:AddWidget(GUI:CreateHeader(self.child, " "), 40)
        col2:AddWidget(GUI:CreateLabel(self.child, L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."], 260), 50)
        
        -- Spacer to match Reset button height in column 1
        local spacer = CreateFrame("Frame", nil, self.child)
        spacer:SetSize(260, 24)
        col2:AddWidget(spacer, 30)
        
        -- Second half of classes in column 2
        for i = 8, #CLASS_LIST do
            local info = CLASS_LIST[i]
            local token = info.token
            if not classColorsDB[token] then
                local default = RAID_CLASS_COLORS[token]
                if default then
                    classColorsDB[token] = { r = default.r, g = default.g, b = default.b, a = 1 }
                end
            end
            col2:AddWidget(GUI:CreateColorPicker(self.child, info.name, classColorsDB, token, false, function()
                DF:RefreshAllVisibleFrames()
            end, function()
                DF:RefreshAllVisibleFrames()
            end, true), 30)
        end
        
        Add(col2, nil, 2)
    end)
    
    -- ========================================
    -- CATEGORY: Bars
    -- ========================================
    CreateCategory("bars", L["Bars"])
    
    -- Bars > Health Bar
    local pageHealthBar = CreateSubTab("bars", "bars_health", L["Health Bar"])
    BuildPage(pageHealthBar, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"healthColor", "healthOrientation", "healthTexture", "classColor", "smoothBars", "background", "missingHealth"}, L["Health Bar"], "bars_health"), 25, 2)
        
        local currentSection = nil
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then currentSection:RegisterChild(widget) end
            return widget
        end
        
        -- ===== HEALTH BAR SECTION =====
        local healthBarSection = Add(GUI:CreateCollapsibleSection(self.child, L["Health Bar"], true), 36, "both")
        currentSection = healthBarSection
        
        -- ===== COLOR GROUP (Column 1) =====
        local colorGroup = GUI:CreateSettingsGroup(self.child, 280)
        colorGroup:AddWidget(GUI:CreateHeader(self.child, L["Color"]), 40)
        
        local colorModes = { CLASS= L["Class Color"], CUSTOM= L["Custom Color"], PERCENT= L["Health Gradient"] }
        colorGroup:AddWidget(GUI:CreateDropdown(self.child, L["Color Mode"], colorModes, db, "healthColorMode", function()
            self:RefreshStates()
            DF:UpdateColorCurve()
            -- Refresh health colors on all frames (same as alpha slider)
            DF:RefreshAllVisibleFrames()
        end), 55)
        
        local classAlpha = colorGroup:AddWidget(GUI:CreateSlider(self.child, L["Health Bar Alpha"], 0, 1, 0.05, db, "classColorAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        classAlpha.hideOn = function(d) return d.healthColorMode ~= "CLASS" and d.healthColorMode ~= "PERCENT" end
        
        local customColor = colorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Custom Health Color"], db, "healthColor", true, nil, function() DF:LightweightUpdateHealthColor() end, true), 35)
        customColor.hideOn = function(d) return d.healthColorMode ~= "CUSTOM" end
        
        AddToSection(colorGroup, nil, 1)
        
        -- ===== TEXTURE GROUP (Column 2) =====
        local textureGroup = GUI:CreateSettingsGroup(self.child, 280)
        textureGroup:AddWidget(GUI:CreateHeader(self.child, L["Texture"]), 40)
        textureGroup:AddWidget(GUI:CreateTextureDropdown(self.child, L["Texture"], db, "healthTexture"), 55)
        
        local orientOptions = {
            HORIZONTAL= L["Left to Right"], HORIZONTAL_INV= L["Right to Left"],
            VERTICAL= L["Bottom to Top"], VERTICAL_INV= L["Top to Bottom"],
        }
        textureGroup:AddWidget(GUI:CreateDropdown(self.child, L["Fill Direction"], orientOptions, db, "healthOrientation", function() DF:UpdateAllFrames() end), 55)
        textureGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Smooth Bar Animation"], db, "smoothBars", function() DF:UpdateAllFrames() end), 30)
        
        AddToSection(textureGroup, nil, 2)
        
        -- ===== GRADIENT PREVIEW (full width, conditional) =====
        local gradHeader = AddToSection(GUI:CreateHeader(self.child, L["Gradient"]), 40, "both")
        gradHeader.hideOn = function(d) return d.healthColorMode ~= "PERCENT" end
        
        local gradBar = AddToSection(GUI:CreateGradientBar(self.child, 550, 24, db), 35, "both")
        gradBar.hideOn = function(d) return d.healthColorMode ~= "PERCENT" end
        
        -- ===== HIGH HEALTH GROUP (Column 1, conditional) =====
        local highGroup = GUI:CreateSettingsGroup(self.child, 280)
        highGroup:AddWidget(GUI:CreateHeader(self.child, L["High Health (100%)"]), 40)
        highGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "healthColorHigh", false, function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, true), 35)
        highGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "healthColorHighUseClass", function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end), 30)
        highGroup:AddWidget(GUI:CreateSlider(self.child, L["Weight"], 1, 5, 1, db, "healthColorHighWeight", function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, true), 55)
        highGroup.hideOn = function(d) return d.healthColorMode ~= "PERCENT" end
        AddToSection(highGroup, nil, 1)
        
        -- ===== MEDIUM HEALTH GROUP (Column 2, conditional) =====
        local medGroup = GUI:CreateSettingsGroup(self.child, 280)
        medGroup:AddWidget(GUI:CreateHeader(self.child, L["Medium Health (50%)"]), 40)
        medGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "healthColorMedium", false, function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, true), 35)
        medGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "healthColorMediumUseClass", function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end), 30)
        medGroup:AddWidget(GUI:CreateSlider(self.child, L["Weight"], 1, 5, 1, db, "healthColorMediumWeight", function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, true), 55)
        medGroup.hideOn = function(d) return d.healthColorMode ~= "PERCENT" end
        AddToSection(medGroup, nil, 2)
        
        -- ===== LOW HEALTH GROUP (Column 1, conditional) =====
        local lowGroup = GUI:CreateSettingsGroup(self.child, 280)
        lowGroup:AddWidget(GUI:CreateHeader(self.child, L["Low Health (0%)"]), 40)
        lowGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "healthColorLow", false, function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, true), 35)
        lowGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "healthColorLowUseClass", function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end), 30)
        lowGroup:AddWidget(GUI:CreateSlider(self.child, L["Weight"], 1, 5, 1, db, "healthColorLowWeight", function() if gradBar.UpdatePreview then gradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if gradBar.UpdatePreview then gradBar.UpdatePreview() end end, true), 55)
        lowGroup.hideOn = function(d) return d.healthColorMode ~= "PERCENT" end
        AddToSection(lowGroup, nil, 1)
        
        -- ===== BACKGROUND GROUP (Column 1) =====
        local bgGroup = GUI:CreateSettingsGroup(self.child, 280)
        bgGroup:AddWidget(GUI:CreateHeader(self.child, L["Background"]), 40)
        
        local bgModes = { CUSTOM= L["Custom Color"], CLASS= L["Class Color"] }
        bgGroup:AddWidget(GUI:CreateDropdown(self.child, L["Background Mode"], bgModes, db, "backgroundColorMode", function()
            self:RefreshStates()
            DF:LightweightUpdateBackgroundColor()
        end), 55)
        
        local bgTextureOptions = DF:GetTextureList(true)
        bgGroup:AddWidget(GUI:CreateTextureDropdown(self.child, L["Background Texture"], db, "backgroundTexture", function()
            DF:LightweightUpdateBackgroundColor()
        end, bgTextureOptions), 55)
        
        local bgColor = bgGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Background Color"], db, "backgroundColor", true, nil, function() DF:LightweightUpdateBackgroundColor() end, true), 35)
        bgColor.hideOn = function(d) return d.backgroundColorMode ~= "CUSTOM" end
        
        local bgClassAlpha = bgGroup:AddWidget(GUI:CreateSlider(self.child, L["Background Alpha"], 0, 1, 0.05, db, "backgroundClassAlpha", nil, function() DF:LightweightUpdateBackgroundColor() end, true), 55)
        bgClassAlpha.hideOn = function(d) return d.backgroundColorMode ~= "CLASS" end
        
        AddToSection(bgGroup, nil, 1)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== MISSING HEALTH SECTION =====
        local missingSection = Add(GUI:CreateCollapsibleSection(self.child, L["Missing Health"], true), 36, "both")
        currentSection = missingSection
        
        -- ===== MISSING HEALTH GROUP (Column 1) =====
        local missingGroup = GUI:CreateSettingsGroup(self.child, 280)
        missingGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        
        local bgFillModes = { BACKGROUND= L["Background Only"], MISSING_HEALTH= L["Missing Health Only"], BOTH= L["Both"] }
        local bgFillMode = missingGroup:AddWidget(GUI:CreateDropdown(self.child, L["Background Fill"], bgFillModes, db, "backgroundMode", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 55)
        bgFillMode.tooltip = L["Background Only: Normal solid background\nMissing Health Only: Shows colored bar where health is missing\nBoth: Shows both"]
        
        local missingHealthTextureOptions = DF:GetTextureList(false)
        local missingHealthTexture = missingGroup:AddWidget(GUI:CreateTextureDropdown(self.child, L["Missing Health Texture"], db, "missingHealthTexture", function()
            DF:UpdateAllFrames()
        end, missingHealthTextureOptions), 55)
        missingHealthTexture.hideOn = function(d) return d.backgroundMode == "BACKGROUND" end
        
        local missingHealthColorModes = { CUSTOM= L["Custom Color"], CLASS= L["Class Color"], PERCENT= L["Health Gradient"] }
        local missingHealthColorMode = missingGroup:AddWidget(GUI:CreateDropdown(self.child, L["Color Mode"], missingHealthColorModes, db, "missingHealthColorMode", function()
            self:RefreshStates()
            DF:UpdateColorCurve()
            DF:UpdateAllFrames()
        end), 55)
        missingHealthColorMode.hideOn = function(d) return d.backgroundMode == "BACKGROUND" end
        
        local missingHealthColor = missingGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Missing Health Color"], db, "missingHealthColor", true, nil, function() DF:UpdateAllFrames() end, true), 35)
        missingHealthColor.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "CUSTOM" end
        
        local missingHealthClassAlpha = missingGroup:AddWidget(GUI:CreateSlider(self.child, L["Class Color Alpha"], 0, 1, 0.05, db, "missingHealthClassAlpha", nil, function() DF:UpdateAllFrames() end, true), 55)
        missingHealthClassAlpha.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "CLASS" end
        
        local missingHealthGradientAlpha = missingGroup:AddWidget(GUI:CreateSlider(self.child, L["Gradient Color Alpha"], 0, 1, 0.05, db, "missingHealthGradientAlpha", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        missingHealthGradientAlpha.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "PERCENT" end

        AddToSection(missingGroup, nil, 1)

        -- ===== MISSING HEALTH GRADIENT PREVIEW (full width, conditional) =====
        local mhGradHeader = AddToSection(GUI:CreateHeader(self.child, L["Gradient"]), 40, "both")
        mhGradHeader.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "PERCENT" end

        local mhGradBar = AddToSection(GUI:CreateGradientBar(self.child, 550, 24, db, "missingHealthColor"), 35, "both")
        mhGradBar.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "PERCENT" end

        -- ===== MISSING HEALTH HIGH GROUP (Column 1, conditional) =====
        local mhHighGroup = GUI:CreateSettingsGroup(self.child, 280)
        mhHighGroup:AddWidget(GUI:CreateHeader(self.child, L["High Health (100%)"]), 40)
        mhHighGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "missingHealthColorHigh", false, function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, true), 35)
        mhHighGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "missingHealthColorHighUseClass", function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end), 30)
        mhHighGroup:AddWidget(GUI:CreateSlider(self.child, L["Weight"], 1, 5, 1, db, "missingHealthColorHighWeight", function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, true), 55)
        mhHighGroup.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "PERCENT" end
        AddToSection(mhHighGroup, nil, 1)

        -- ===== MISSING HEALTH MEDIUM GROUP (Column 2, conditional) =====
        local mhMedGroup = GUI:CreateSettingsGroup(self.child, 280)
        mhMedGroup:AddWidget(GUI:CreateHeader(self.child, L["Medium Health (50%)"]), 40)
        mhMedGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "missingHealthColorMedium", false, function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, true), 35)
        mhMedGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "missingHealthColorMediumUseClass", function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end), 30)
        mhMedGroup:AddWidget(GUI:CreateSlider(self.child, L["Weight"], 1, 5, 1, db, "missingHealthColorMediumWeight", function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, true), 55)
        mhMedGroup.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "PERCENT" end
        AddToSection(mhMedGroup, nil, 2)

        -- ===== MISSING HEALTH LOW GROUP (Column 1, conditional) =====
        local mhLowGroup = GUI:CreateSettingsGroup(self.child, 280)
        mhLowGroup:AddWidget(GUI:CreateHeader(self.child, L["Low Health (0%)"]), 40)
        mhLowGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "missingHealthColorLow", false, function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, true), 35)
        mhLowGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "missingHealthColorLowUseClass", function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end), 30)
        mhLowGroup:AddWidget(GUI:CreateSlider(self.child, L["Weight"], 1, 5, 1, db, "missingHealthColorLowWeight", function() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() end, function() DF:UpdateColorCurve() DF:RefreshAllVisibleFrames() if mhGradBar.UpdatePreview then mhGradBar.UpdatePreview() end end, true), 55)
        mhLowGroup.hideOn = function(d) return d.backgroundMode == "BACKGROUND" or d.missingHealthColorMode ~= "PERCENT" end
        AddToSection(mhLowGroup, nil, 1)
        
        currentSection = nil
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "general_frame", label = L["Frame"]},
            {pageId = "text_health", label = L["Health Text"]},
            {pageId = "bars_absorbs", label = L["Absorbs"]},
        }), 30, "both")
    end)
    
    -- Bars > Resource Bar
    local pageResource = CreateSubTab("bars", "bars_resource", L["Resource Bar"])
    BuildPage(pageResource, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"resourceBar"}, L["Resource Bar"], "bars_resource"), 25, 2)
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Resource Bar Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Resource Bar"], db, "resourceBarEnabled", function() 
            DF:UpdateAllPowerEventRegistration()
            DF:UpdateAllFrames() 
        end), 30)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Healers"], db, "resourceBarShowHealer", function() DF:UpdateAllFrames() end), 30)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Tanks"], db, "resourceBarShowTank", function() DF:UpdateAllFrames() end), 30)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["DPS"], db, "resourceBarShowDPS", function() DF:UpdateAllFrames() end), 30)
        local showInSolo = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show in Solo Mode"], db, "resourceBarShowInSoloMode", function() DF:UpdateAllFrames() end), 30)
        showInSolo.hideOn = function() return GUI.SelectedMode == "raid" end
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Smooth Bar Animation"], db, "resourceBarSmooth", function() DF:UpdateAllFrames() end), 30)
        Add(settingsGroup, nil, 1)

        -- ===== CLASS FILTER GROUP (Column 1) =====
        local classFilterGroup = GUI:CreateSettingsGroup(self.child, 280)
        classFilterGroup:AddWidget(GUI:CreateHeader(self.child, L["Class Filter"]), 40)

        local RB_CLASS_LIST = {
            { token = "WARRIOR",      name = L["Warrior"] },
            { token = "PALADIN",      name = L["Paladin"] },
            { token = "HUNTER",       name = L["Hunter"] },
            { token = "ROGUE",        name = L["Rogue"] },
            { token = "PRIEST",       name = L["Priest"] },
            { token = "DEATHKNIGHT",  name = L["Death Knight"] },
            { token = "SHAMAN",       name = L["Shaman"] },
            { token = "MAGE",         name = L["Mage"] },
            { token = "WARLOCK",      name = L["Warlock"] },
            { token = "MONK",         name = L["Monk"] },
            { token = "DRUID",        name = L["Druid"] },
            { token = "DEMONHUNTER",  name = L["Demon Hunter"] },
            { token = "EVOKER",       name = L["Evoker"] },
        }

        if not db.resourceBarClassFilter then
            db.resourceBarClassFilter = {}
            for _, info in ipairs(RB_CLASS_LIST) do
                db.resourceBarClassFilter[info.token] = true
            end
        end

        for _, info in ipairs(RB_CLASS_LIST) do
            classFilterGroup:AddWidget(
                GUI:CreateCheckbox(self.child, info.name, db.resourceBarClassFilter, info.token, function()
                    DF:UpdateAllFrames()
                end), 25
            )
        end
        Add(classFilterGroup, nil, 1)

        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        
        local anchorOptions = {
            TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"], CENTER= L["Center"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor Point"], anchorOptions, db, "resourceBarAnchor", function() DF:UpdateAllFrames() end), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "resourceBarX", nil, function() DF:LightweightUpdatePowerBarPosition() end, true), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "resourceBarY", nil, function() DF:LightweightUpdatePowerBarPosition() end, true), 55)
        Add(positionGroup, nil, 2)
        
        -- ===== ORIENTATION GROUP (Column 1) =====
        local orientGroup = GUI:CreateSettingsGroup(self.child, 280)
        orientGroup:AddWidget(GUI:CreateHeader(self.child, L["Orientation"]), 40)
        local orientOptions = { HORIZONTAL= L["Horizontal"], VERTICAL= L["Vertical"] }
        orientGroup:AddWidget(GUI:CreateDropdown(self.child, L["Orientation"], orientOptions, db, "resourceBarOrientation", function() DF:UpdateAllFrames() end), 55)
        orientGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Reverse Fill Direction"], db, "resourceBarReverseFill", function() DF:UpdateAllFrames() end), 30)
        Add(orientGroup, nil, 1)
        
        -- ===== BACKGROUND GROUP (Column 2) =====
        local bgGroup = GUI:CreateSettingsGroup(self.child, 280)
        bgGroup:AddWidget(GUI:CreateHeader(self.child, L["Background"]), 40)
        bgGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Background"], db, "resourceBarBackgroundEnabled", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 30)
        local bgColor = bgGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Background Color"], db, "resourceBarBackgroundColor", true, nil, function() DF:LightweightUpdateResourceBarBackgroundColor() end, true), 35)
        bgColor.disableOn = function(d) return not d.resourceBarBackgroundEnabled end
        Add(bgGroup, nil, 2)
        
        -- ===== BORDER GROUP (Column 1) =====
        local borderGroup = GUI:CreateSettingsGroup(self.child, 280)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "resourceBarBorderEnabled", function()
            self:RefreshStates()
            DF:LightweightUpdateResourceBarBorder()
        end), 30)
        local borderColor = borderGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "resourceBarBorderColor", true, nil, function() DF:LightweightUpdateResourceBarBorderColor() end, true), 35)
        borderColor.disableOn = function(d) return not d.resourceBarBorderEnabled end
        Add(borderGroup, nil, 1)
        
        -- ===== FRAME LEVEL GROUP (Column 2) =====
        local frameLevelGroup = GUI:CreateSettingsGroup(self.child, 280)
        frameLevelGroup:AddWidget(GUI:CreateHeader(self.child, L["Frame Level"]), 40)
        frameLevelGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Level Offset"], 0, 20, 1, db, "resourceBarFrameLevel", nil, function() DF:LightweightUpdateResourceBarFrameLevel() end, true), 55)
        frameLevelGroup:AddWidget(GUI:CreateLabel(self.child, L["Higher values render the bar above other elements. Frame border is at level 10."], 250), 50)
        Add(frameLevelGroup, nil, 2)
        
        -- ===== SIZE GROUP (Column 1) =====
        local sizeGroup = GUI:CreateSettingsGroup(self.child, 280)
        sizeGroup:AddWidget(GUI:CreateHeader(self.child, L["Size"]), 40)
        sizeGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Match Health Bar Width/Height"], db, "resourceBarMatchWidth", function() DF:UpdateAllFrames() end), 30)
        local widthSlider = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Width / Length"], 10, 200, 1, db, "resourceBarWidth", nil, function() DF:LightweightUpdatePowerBarSize() end, true), 55)
        widthSlider.disableOn = function(d) return d.resourceBarMatchWidth end
        sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Height / Thickness"], 1, 20, 1, db, "resourceBarHeight", nil, function() DF:LightweightUpdatePowerBarSize() end, true), 55)
        Add(sizeGroup, nil, 1)
        
        -- ===== RESOURCE COLORS GROUP (Column 2) =====
        local colorGroup = GUI:CreateSettingsGroup(self.child, 280)
        colorGroup:AddWidget(GUI:CreateHeader(self.child, L["Resource Colors"]), 40)
        colorGroup:AddWidget(GUI:CreateLabel(self.child, L["Customize resource bar colors per power type. Shared across party and raid frames."], 260), 40)
        colorGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "resourceBarClassColor", function() DF:RefreshAllVisibleFrames() end), 30)
        
        local powerColorsDB = DF.db.powerColors
        if not powerColorsDB then
            DF.db.powerColors = {}
            powerColorsDB = DF.db.powerColors
        end
        
        local POWER_LIST = {
            { token = "MANA",         name = L["Mana"] },
            { token = "RAGE",         name = L["Rage"] },
            { token = "FOCUS",        name = L["Focus"] },
            { token = "ENERGY",       name = L["Energy"] },
            { token = "RUNIC_POWER",  name = L["Runic Power"] },
            { token = "INSANITY",     name = L["Insanity"] },
            { token = "FURY",         name = L["Fury"] },
            { token = "LUNAR_POWER",  name = L["Lunar Power"] },
        }
        
        for _, info in ipairs(POWER_LIST) do
            local token = info.token
            if not powerColorsDB[token] then
                local default = PowerBarColor[token]
                if default then
                    powerColorsDB[token] = { r = default.r, g = default.g, b = default.b, a = 1 }
                end
            end
            colorGroup:AddWidget(GUI:CreateColorPicker(self.child, info.name, powerColorsDB, token, false, function()
                DF:RefreshAllVisibleFrames()
            end, function()
                DF:RefreshAllVisibleFrames()
            end, true), 30)
        end
        
        -- Reset button
        local resetPowerBtn = CreateFrame("Button", nil, self.child, "BackdropTemplate")
        resetPowerBtn:SetSize(260, 24)
        resetPowerBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        resetPowerBtn:SetBackdropColor(0.15, 0.15, 0.15, 1)
        resetPowerBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        local resetPowerText = resetPowerBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        resetPowerText:SetPoint("CENTER")
        resetPowerText:SetText(L["Reset All to Default"])
        resetPowerBtn:SetScript("OnClick", function()
            for _, info in ipairs(POWER_LIST) do
                local default = PowerBarColor[info.token]
                if default then
                    powerColorsDB[info.token] = { r = default.r, g = default.g, b = default.b, a = 1 }
                end
            end
            DF:RefreshAllVisibleFrames()
            if pageResource and pageResource.Refresh then
                pageResource:Refresh()
            end
        end)
        resetPowerBtn:SetScript("OnEnter", function(s) s:SetBackdropColor(0.25, 0.25, 0.25, 1) end)
        resetPowerBtn:SetScript("OnLeave", function(s) s:SetBackdropColor(0.15, 0.15, 0.15, 1) end)
        colorGroup:AddWidget(resetPowerBtn, 30)
        
        Add(colorGroup, nil, 2)
    end)
    
    -- Bars > Class Power (Holy Power, Chi, Combo Points, etc. - player frame only)
    local pageClassPower = CreateSubTab("bars", "bars_classpower", L["Class Power"])
    BuildPage(pageClassPower, function(self, db, Add, AddSpace, AddSyncPoint)
        Add(CreateCopyButton(self.child, {"classPower"}, L["Class Power"]), 25, 2)
        Add(GUI:CreateHeader(self.child, L["Class Power Pips"]), 40, "both")
        Add(GUI:CreateLabel(self.child, L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."], 560), 50, "both")
        AddSpace(10, "both")
        
        Add(GUI:CreateCheckbox(self.child, L["Enable Class Power Pips"], db, "classPowerEnabled", function()
            self:RefreshStates()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end), 25, 1)
        
        local function HideClassPower(d)
            return not d.classPowerEnabled
        end
        
        AddSpace(10, 1)
        Add(GUI:CreateHeader(self.child, L["Size"]), 40, 1)
        
        local cpHeight = Add(GUI:CreateSlider(self.child, L["Pip Height"], 1, 12, 1, db, "classPowerHeight", nil, function() if DF.RefreshClassPower then DF.RefreshClassPower() end end, true), 55, 1)
        cpHeight.hideOn = HideClassPower
        
        local cpGap = Add(GUI:CreateSlider(self.child, L["Gap Between Pips"], 0, 5, 1, db, "classPowerGap", nil, function() if DF.RefreshClassPower then DF.RefreshClassPower() end end, true), 55, 1)
        cpGap.hideOn = HideClassPower
        
        local cpIgnoreFade = Add(GUI:CreateCheckbox(self.child, L["Ignore Full Health Fade"], db, "classPowerIgnoreFade", function()
            if DF.UpdateClassPowerAlpha then DF.UpdateClassPowerAlpha() end
        end), 25, 1)
        cpIgnoreFade.hideOn = HideClassPower

        AddSpace(10, 1)
        Add(GUI:CreateHeader(self.child, L["Colors"]), 40, 1)

        local cpUseCustomColor = Add(GUI:CreateCheckbox(self.child, L["Use Custom Pip Color"], db, "classPowerUseCustomColor", function()
            self:RefreshStates()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end), 25, 1)
        cpUseCustomColor.hideOn = HideClassPower
        cpUseCustomColor.tooltip = L["When enabled, all pips use a single custom color instead of the class-specific default."]

        local cpColor = Add(GUI:CreateColorPicker(self.child, L["Pip Color"], db, "classPowerColor", false, function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end, function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end, true), 35, 1)
        cpColor.hideOn = HideClassPower
        cpColor.disableOn = function(d) return not d.classPowerUseCustomColor end

        local cpBgColor = Add(GUI:CreateColorPicker(self.child, L["Background Color"], db, "classPowerBgColor", true, function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end, function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end, true), 35, 1)
        cpBgColor.hideOn = HideClassPower
        cpBgColor.tooltip = L["Color and opacity of the empty/inactive pips."]

        Add(GUI:CreateHeader(self.child, L["Position"]), 40, 2)
        local anchorOptions = {
            INSIDE_BOTTOM = L["Inside (Bottom)"],
            INSIDE_TOP = L["Inside (Top)"],
            BOTTOM = L["Below Health Bar"],
            TOP = L["Above Health Bar"],
            LEFT = L["Left of Health Bar"],
            RIGHT = L["Right of Health Bar"],
        }
        local cpAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "classPowerAnchor", function() if DF.RefreshClassPower then DF.RefreshClassPower() end end), 55, 2)
        cpAnchor.hideOn = HideClassPower
        cpAnchor.tooltip = L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."]

        local cpX = Add(GUI:CreateSlider(self.child, L["Offset X"], -30, 30, 1, db, "classPowerX", nil, function() if DF.RefreshClassPower then DF.RefreshClassPower() end end, true), 55, 2)
        cpX.hideOn = HideClassPower

        local cpY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -20, 20, 1, db, "classPowerY", nil, function() if DF.RefreshClassPower then DF.RefreshClassPower() end end, true), 55, 2)
        cpY.hideOn = HideClassPower

        AddSpace(10, 2)
        Add(GUI:CreateHeader(self.child, L["Show for Roles"]), 40, 2)

        local cpShowTank = Add(GUI:CreateCheckbox(self.child, L["Tank"], db, "classPowerShowTank", function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end), 25, 2)
        cpShowTank.hideOn = HideClassPower

        local cpShowHealer = Add(GUI:CreateCheckbox(self.child, L["Healer"], db, "classPowerShowHealer", function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end), 25, 2)
        cpShowHealer.hideOn = HideClassPower

        local cpShowDamager = Add(GUI:CreateCheckbox(self.child, L["Damage"], db, "classPowerShowDamager", function()
            if DF.RefreshClassPower then DF.RefreshClassPower() end
        end), 25, 2)
        cpShowDamager.hideOn = HideClassPower
    end)
    
    -- Bars > Absorbs (combined Absorb Shield + Heal Absorb with collapsible sections)
    local pageAbsorb = CreateSubTab("bars", "bars_absorb", L["Absorbs"])
    BuildPage(pageAbsorb, function(self, db, Add, AddSpace)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"absorbBar", "healAbsorb"}, L["Absorbs"], "bars_absorb"), 25, 2)
        
        local currentSection = nil
        
        -- Helper to add widgets to current section
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then
                currentSection:RegisterChild(widget)
            end
            return widget
        end
        
        -- ===== ABSORB SHIELD SECTION =====
        local absorbSection = Add(GUI:CreateCollapsibleSection(self.child, L["Absorb Shield"], true), 36, "both")
        currentSection = absorbSection
        
        local modeOptions = {
            OVERLAY = L["Overlay (on health bar)"],
            ATTACHED = L["Attached to Health"],
            ATTACHED_OVERFLOW = L["Attached + Overflow"],
            FLOATING = L["Floating Bar"],
        }
        AddToSection(GUI:CreateDropdown(self.child, L["Display Mode"], modeOptions, db, "absorbBarMode", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 55, 1)
        
        local textureOptions = DF:GetTextureList()
        -- Add stripe textures if not already present
        local stripeTextures = {
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft"]= "DF Stripes Soft",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft_Wide"]= "DF Stripes Soft Wide",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes"]= "DF Stripes",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Sparse"]= "DF Stripes Sparse",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Medium"]= "DF Stripes Medium",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense"]= "DF Stripes Dense",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Very_Dense"]= "DF Stripes Very Dense",
        }
        for path, name in pairs(stripeTextures) do
            if not textureOptions[path] then
                textureOptions[path] = name
            end
        end
        AddToSection(GUI:CreateTextureDropdown(self.child, L["Texture"], db, "absorbBarTexture", function() DF:UpdateAllFrames() end, textureOptions), 55, 1)
        
        AddToSection(GUI:CreateColorPicker(self.child, L["Bar Color"], db, "absorbBarColor", true, nil, function() DF:LightweightUpdateAbsorbBarColor() end, true), 35, 1)
        
        local blendOptions = { BLEND= L["Normal (BLEND)"], ADD= L["Additive (ADD)"] }
        AddToSection(GUI:CreateDropdown(self.child, L["Blend Mode"], blendOptions, db, "absorbBarBlendMode", function() DF:UpdateAllFrames() end), 55, 1)
        
        local overlayRev = AddToSection(GUI:CreateCheckbox(self.child, L["Reverse Overlay Fill"], db, "absorbBarOverlayReverse", function() DF:UpdateAllFrames() end), 25, 1)
        overlayRev.hideOn = function(d) return d.absorbBarMode ~= "OVERLAY" and d.absorbBarMode ~= "ATTACHED_OVERFLOW" end
        
        local absorbClampOptions = {
            [0] = L["None (no clamping)"],
            [1] = L["Missing Health"],
            [2] = L["Max Health"],
        }
        local absorbClampDropdown = AddToSection(GUI:CreateDropdown(self.child, L["Clamp Mode"], absorbClampOptions, db, "absorbBarAttachedClampMode", function() DF:UpdateAllFrames() end), 55, 1)
        absorbClampDropdown.hideOn = function(d) return d.absorbBarMode ~= "ATTACHED" and d.absorbBarMode ~= "ATTACHED_OVERFLOW" end
        
        local absorbShowOvershield = AddToSection(GUI:CreateCheckbox(self.child, L["Show Overshield Glow"], db, "absorbBarShowOvershield", function() DF:UpdateAllFrames() end), 25, 1)
        absorbShowOvershield.hideOn = function(d) return d.absorbBarMode ~= "ATTACHED" end
        absorbShowOvershield.tooltip = L["Shows a glow at max health when absorb exceeds the clamp limit."]
        
        local absorbOvershieldStyleOptions = {
            SPARK = L["Spark"],
            LINE = L["Line"],
            GRADIENT = L["Gradient"],
            GLOW = L["Glow"],
        }
        local absorbOvershieldStyle = AddToSection(GUI:CreateDropdown(self.child, L["Glow Style"], absorbOvershieldStyleOptions, db, "absorbBarOvershieldStyle", function() DF:UpdateAllFrames() end), 55, 1)
        absorbOvershieldStyle.hideOn = function(d) return d.absorbBarMode ~= "ATTACHED" or not d.absorbBarShowOvershield end
        
        local absorbOvershieldColor = AddToSection(GUI:CreateColorPicker(self.child, L["Glow Color"], db, "absorbBarOvershieldColor", false, nil, function() DF:UpdateAllFrames() end), 35, 1)
        absorbOvershieldColor.hideOn = function(d) return d.absorbBarMode ~= "ATTACHED" or not d.absorbBarShowOvershield end
        
        local absorbOvershieldAlpha = AddToSection(GUI:CreateSlider(self.child, L["Glow Alpha"], 0.1, 1, 0.05, db, "absorbBarOvershieldAlpha", nil, function() DF:UpdateAllFrames() end, true), 55, 1)
        absorbOvershieldAlpha.hideOn = function(d) return d.absorbBarMode ~= "ATTACHED" or not d.absorbBarShowOvershield end
        
        local absorbOvershieldReverse = AddToSection(GUI:CreateCheckbox(self.child, L["Reverse Position"], db, "absorbBarOvershieldReverse", function() DF:UpdateAllFrames() end), 25, 1)
        absorbOvershieldReverse.hideOn = function(d) return d.absorbBarMode ~= "ATTACHED" or not d.absorbBarShowOvershield end
        absorbOvershieldReverse.tooltip = L["Moves the glow to the opposite side (no HP side instead of max HP side)."]
        
        -- Floating mode settings (column 2)
        local floatingHeader = AddToSection(GUI:CreateHeader(self.child, L["Floating Bar Position"]), 45, 2)
        floatingHeader.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local orientOptions = { HORIZONTAL= L["Horizontal"], VERTICAL= L["Vertical"] }
        local orientDropdown = AddToSection(GUI:CreateDropdown(self.child, L["Orientation"], orientOptions, db, "absorbBarOrientation", function() DF:UpdateAllFrames() end), 55, 1)
        orientDropdown.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local revFill = AddToSection(GUI:CreateCheckbox(self.child, L["Reverse Fill"], db, "absorbBarReverse", function() DF:UpdateAllFrames() end), 25, 2)
        revFill.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local widthSlider = AddToSection(GUI:CreateSlider(self.child, L["Width"], 10, 200, 1, db, "absorbBarWidth", nil, function() DF:LightweightUpdateAbsorbBar() end, true), 55, 1)
        widthSlider.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local heightSlider = AddToSection(GUI:CreateSlider(self.child, L["Height"], 1, 30, 1, db, "absorbBarHeight", nil, function() DF:LightweightUpdateAbsorbBar() end, true), 55, 1)
        heightSlider.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local anchorOptions = {
            TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"], CENTER= L["Center"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        local anchorDropdown = AddToSection(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "absorbBarAnchor", function() DF:UpdateAllFrames() end), 55, 1)
        anchorDropdown.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local xSlider = AddToSection(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "absorbBarX", nil, function() DF:LightweightUpdateAbsorbBar() end, true), 55, 1)
        xSlider.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local ySlider = AddToSection(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "absorbBarY", nil, function() DF:LightweightUpdateAbsorbBar() end, true), 55, 1)
        ySlider.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local bgColorPicker = AddToSection(GUI:CreateColorPicker(self.child, L["Background Color"], db, "absorbBarBackgroundColor", true, nil, function() DF:LightweightUpdateAbsorbBarColor() end, true), 35, 2)
        bgColorPicker.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local strataOptions = {
            BACKGROUND = L["Background"],
            LOW = L["Low"],
            MEDIUM = L["Medium"],
            HIGH = L["High"],
            DIALOG = L["Dialog"],
        }
        local strataDropdown = AddToSection(GUI:CreateDropdown(self.child, L["Frame Strata"], strataOptions, db, "absorbBarStrata", function() DF:UpdateAllFrames() end), 55, 1)
        strataDropdown.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        local levelSlider = AddToSection(GUI:CreateSlider(self.child, L["Frame Level"], 1, 100, 1, db, "absorbBarFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("absorb") end, true), 55, 1)
        levelSlider.hideOn = function(d) return d.absorbBarMode ~= "FLOATING" end
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== HEAL ABSORB SECTION =====
        local healAbsorbSection = Add(GUI:CreateCollapsibleSection(self.child, L["Heal Absorb"], true), 36, "both")
        currentSection = healAbsorbSection
        
        AddToSection(GUI:CreateLabel(self.child, L["Shows effects that reduce incoming healing (like Necrotic stacks)."], 260), 25, 1)
        
        local healModeOptions = {
            OVERLAY = L["Overlay (on health bar)"],
            ATTACHED = L["Attached to Health"],
            FLOATING = L["Floating Bar"],
        }
        AddToSection(GUI:CreateDropdown(self.child, L["Display Mode"], healModeOptions, db, "healAbsorbBarMode", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 55, 1)
        
        local healTextureOptions = DF:GetTextureList()
        -- Add stripe textures if not already present
        local healStripeTextures = {
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft"]= "DF Stripes Soft",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Soft_Wide"]= "DF Stripes Soft Wide",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes"]= "DF Stripes",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Sparse"]= "DF Stripes Sparse",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Medium"]= "DF Stripes Medium",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Dense"]= "DF Stripes Dense",
            ["Interface\\AddOns\\DandersFrames\\Media\\DF_Stripes_Very_Dense"]= "DF Stripes Very Dense",
        }
        for path, name in pairs(healStripeTextures) do
            if not healTextureOptions[path] then
                healTextureOptions[path] = name
            end
        end
        AddToSection(GUI:CreateTextureDropdown(self.child, L["Texture"], db, "healAbsorbBarTexture", function() DF:UpdateAllFrames() end, healTextureOptions), 55, 1)
        
        AddToSection(GUI:CreateColorPicker(self.child, L["Bar Color"], db, "healAbsorbBarColor", true, nil, function() DF:LightweightUpdateHealAbsorbBarColor() end, true), 35, 1)
        
        local healBlendOptions = { BLEND= L["Normal (BLEND)"], ADD= L["Additive (ADD)"] }
        AddToSection(GUI:CreateDropdown(self.child, L["Blend Mode"], healBlendOptions, db, "healAbsorbBarBlendMode", function() DF:UpdateAllFrames() end), 55, 1)
        
        local healOverlayRev = AddToSection(GUI:CreateCheckbox(self.child, L["Reverse Overlay Fill"], db, "healAbsorbBarOverlayReverse", function() DF:UpdateAllFrames() end), 25, 1)
        healOverlayRev.hideOn = function(d) return d.healAbsorbBarMode ~= "OVERLAY" end
        
        -- Heal Absorb Floating mode settings (column 2)
        local healFloatingHeader = AddToSection(GUI:CreateHeader(self.child, L["Floating Bar Position"]), 45, 2)
        healFloatingHeader.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healOrientDropdown = AddToSection(GUI:CreateDropdown(self.child, L["Orientation"], orientOptions, db, "healAbsorbBarOrientation", function() DF:UpdateAllFrames() end), 55, 1)
        healOrientDropdown.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healRevFill = AddToSection(GUI:CreateCheckbox(self.child, L["Reverse Fill"], db, "healAbsorbBarReverse", function() DF:UpdateAllFrames() end), 25, 2)
        healRevFill.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healWidthSlider = AddToSection(GUI:CreateSlider(self.child, L["Width"], 10, 200, 1, db, "healAbsorbBarWidth", nil, function() DF:LightweightUpdateHealAbsorbBar() end, true), 55, 1)
        healWidthSlider.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healHeightSlider = AddToSection(GUI:CreateSlider(self.child, L["Height"], 1, 30, 1, db, "healAbsorbBarHeight", nil, function() DF:LightweightUpdateHealAbsorbBar() end, true), 55, 1)
        healHeightSlider.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healAnchorDropdown = AddToSection(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "healAbsorbBarAnchor", function() DF:UpdateAllFrames() end), 55, 1)
        healAnchorDropdown.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healXSlider = AddToSection(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "healAbsorbBarX", nil, function() DF:LightweightUpdateHealAbsorbBar() end, true), 55, 1)
        healXSlider.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healYSlider = AddToSection(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "healAbsorbBarY", nil, function() DF:LightweightUpdateHealAbsorbBar() end, true), 55, 1)
        healYSlider.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        local healBgColorPicker = AddToSection(GUI:CreateColorPicker(self.child, L["Background Color"], db, "healAbsorbBarBackgroundColor", true, nil, function() DF:LightweightUpdateHealAbsorbBarColor() end, true), 35, 2)
        healBgColorPicker.hideOn = function(d) return d.healAbsorbBarMode ~= "FLOATING" end
        
        currentSection = nil
    end)
    
    -- Bars > Heal Prediction
    local pageHealPrediction = CreateSubTab("bars", "bars_healpred", L["Heal Prediction"])
    BuildPage(pageHealPrediction, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"healPrediction"}, L["Heal Prediction"], "bars_healpred"), 25, 2)
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Heal Prediction"]), 40)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Heal Prediction"], db, "healPredictionEnabled", function() 
            self:RefreshStates()
            DF:UpdateAllFrames() 
        end), 30)
        
        local modeOptions = { OVERLAY= L["Attached to Health"], FLOATING= L["Floating Bar"] }
        local modeDropdown = settingsGroup:AddWidget(GUI:CreateDropdown(self.child, L["Display Mode"], modeOptions, db, "healPredictionMode", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 55)
        modeDropdown.disableOn = function(d) return not d.healPredictionEnabled end
        
        local textureOptions = DF:GetTextureList()
        local texDropdown = settingsGroup:AddWidget(GUI:CreateTextureDropdown(self.child, L["Texture"], db, "healPredictionTexture", function() DF:UpdateAllFrames() end, textureOptions), 55)
        texDropdown.disableOn = function(d) return not d.healPredictionEnabled end
        
        local blendOptions = { BLEND= L["Normal (BLEND)"], ADD= L["Additive (ADD)"] }
        local blendDropdown = settingsGroup:AddWidget(GUI:CreateDropdown(self.child, L["Blend Mode"], blendOptions, db, "healPredictionBlendMode", function() DF:UpdateAllFrames() end), 55)
        blendDropdown.disableOn = function(d) return not d.healPredictionEnabled end
        
        Add(settingsGroup, nil, 1)
        
        -- ===== APPEARANCE GROUP (Column 2) =====
        local appearanceGroup = GUI:CreateSettingsGroup(self.child, 280)
        appearanceGroup:AddWidget(GUI:CreateHeader(self.child, L["Appearance"]), 40)
        
        local overhealCheckbox = appearanceGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Overheal"], db, "healPredictionShowOverheal", function() DF:UpdateAllFrames() end), 30)
        overhealCheckbox.disableOn = function(d) return not d.healPredictionEnabled end
        overhealCheckbox.tooltip = L["When enabled, shows incoming heals even if they would overheal."]
        
        local myColor = appearanceGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Heal Prediction Color"], db, "healPredictionMyColor", true, nil, function() DF:UpdateAllFrames() end, true), 35)
        myColor.disableOn = function(d) return not d.healPredictionEnabled end
        
        Add(appearanceGroup, nil, 2)
        
        -- ===== FLOATING POSITION GROUP (Column 1, conditional) =====
        local floatingGroup = GUI:CreateSettingsGroup(self.child, 280)
        floatingGroup:AddWidget(GUI:CreateHeader(self.child, L["Floating Bar Position"]), 40)
        
        local orientOptions = { HORIZONTAL= L["Horizontal"], VERTICAL= L["Vertical"] }
        local orientDropdown = floatingGroup:AddWidget(GUI:CreateDropdown(self.child, L["Orientation"], orientOptions, db, "healPredictionOrientation", function() DF:UpdateAllFrames() end), 55)
        orientDropdown.disableOn = function(d) return not d.healPredictionEnabled end
        
        local revFill = floatingGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Reverse Fill"], db, "healPredictionReverse", function() DF:UpdateAllFrames() end), 30)
        revFill.disableOn = function(d) return not d.healPredictionEnabled end
        
        local widthSlider = floatingGroup:AddWidget(GUI:CreateSlider(self.child, L["Width"], 10, 200, 1, db, "healPredictionWidth", nil, function() DF:UpdateAllFrames() end, true), 55)
        widthSlider.disableOn = function(d) return not d.healPredictionEnabled end
        
        local heightSlider = floatingGroup:AddWidget(GUI:CreateSlider(self.child, L["Height"], 1, 30, 1, db, "healPredictionHeight", nil, function() DF:UpdateAllFrames() end, true), 55)
        heightSlider.disableOn = function(d) return not d.healPredictionEnabled end
        
        floatingGroup.hideOn = function(d) return d.healPredictionMode ~= "FLOATING" end
        Add(floatingGroup, nil, 1)
        
        -- ===== FLOATING ANCHOR GROUP (Column 2, conditional) =====
        local anchorGroup = GUI:CreateSettingsGroup(self.child, 280)
        anchorGroup:AddWidget(GUI:CreateHeader(self.child, L["Floating Bar Anchor"]), 40)
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        local anchorDropdown = anchorGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "healPredictionAnchor", function() DF:UpdateAllFrames() end), 55)
        anchorDropdown.disableOn = function(d) return not d.healPredictionEnabled end
        
        local xSlider = anchorGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "healPredictionX", nil, function() DF:UpdateAllFrames() end, true), 55)
        xSlider.disableOn = function(d) return not d.healPredictionEnabled end
        
        local ySlider = anchorGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "healPredictionY", nil, function() DF:UpdateAllFrames() end, true), 55)
        ySlider.disableOn = function(d) return not d.healPredictionEnabled end
        
        local bgColorPicker = anchorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Background Color"], db, "healPredictionBackgroundColor", true, nil, function() DF:UpdateAllFrames() end, true), 35)
        bgColorPicker.disableOn = function(d) return not d.healPredictionEnabled end
        
        anchorGroup.hideOn = function(d) return d.healPredictionMode ~= "FLOATING" end
        Add(anchorGroup, nil, 2)
    end)
    
    -- ========================================
    -- CATEGORY: Text
    -- ========================================
    CreateCategory("text", L["Text"])
    
    -- Text > Health Text
    local pageHealthText = CreateSubTab("text", "text_health", L["Health Text"])
    BuildPage(pageHealthText, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"healthText", "healthFont"}, L["Health Text"], "text_health"), 25, 2)
        
        -- ===== FORMAT GROUP (Column 1) =====
        local formatGroup = GUI:CreateSettingsGroup(self.child, 280)
        formatGroup:AddWidget(GUI:CreateHeader(self.child, L["Health Text"]), 40)
        
        local formatOptions = {
            PERCENT= L["Percentage"], CURRENT= L["Current Health"], CURRENTMAX= L["Current / Max"],
            DEFICIT= L["Health Deficit"], NONE= L["Hidden"],
            _order = {"PERCENT", "CURRENT", "CURRENTMAX", "DEFICIT", "NONE"},
        }
        formatGroup:AddWidget(GUI:CreateDropdown(self.child, L["Health Format"], formatOptions, db, "healthTextFormat", function() DF:RefreshAllVisibleFrames() end), 55)
        formatGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Abbreviate (K/M)"], db, "healthTextAbbreviate", function() DF:RefreshAllVisibleFrames() end), 30)
        formatGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide % Symbol"], db, "healthTextHidePercent", function() DF:RefreshAllVisibleFrames() end), 30)
        Add(formatGroup, nil, 1)
        
        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "healthTextAnchor", function() DF:UpdateAllFrames() end), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "healthTextX", nil, function() DF:LightweightUpdateTextPosition("health") end, true), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "healthTextY", nil, function() DF:LightweightUpdateTextPosition("health") end, true), 55)
        Add(positionGroup, nil, 2)
        
        -- ===== FONT GROUP (Column 1) =====
        local fontGroup = GUI:CreateSettingsGroup(self.child, 280)
        fontGroup:AddWidget(GUI:CreateHeader(self.child, L["Font"]), 40)
        fontGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "healthFont", function() DF:UpdateAllFrames() end), 55)
        fontGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "healthFontSize", nil, function() DF:LightweightUpdateFontSize("health") end, true), 55)
        
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }
        fontGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "healthTextOutline", function() DF:LightweightUpdateFontSize("health") end), 55)
        fontGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "healthTextUseClassColor", function()
            self:RefreshStates()
            DF:RefreshAllVisibleFrames()
        end), 30)
        local healthColor = fontGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Text Color"], db, "healthTextColor", true, nil, function() DF:LightweightUpdateTextColor("health") end, true), 35)
        healthColor.disableOn = function(d) return d.healthTextUseClassColor end
        Add(fontGroup, nil, 1)
    end)
    
    -- Text > Status Text (Dead/Offline)
    local pageStatusText = CreateSubTab("text", "text_status", L["Status Text"])
    BuildPage(pageStatusText, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"statusText"}, L["Status Text"], "text_status"), 25, 2)
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Status Text (Dead/Offline)"]), 40)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Status Text"], db, "statusTextEnabled", function() 
            -- Force full refresh of all frames to update status text visibility
            if DF.testMode or DF.raidTestMode then
                -- In test mode, refresh test frames
                if DF.RefreshTestFrames then DF:RefreshTestFrames() end
                if DF.UpdateRaidTestFrames then DF:UpdateRaidTestFrames() end
            else
                -- Live mode - update live frames
                if DF.IterateAllFrames then
                    DF:IterateAllFrames(function(frame)
                        if frame and frame.unit and UnitExists(frame.unit) then
                            DF:UpdateUnitFrame(frame)
                        end
                    end)
                end
            end
        end), 30)
        Add(settingsGroup, nil, 1)
        
        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "statusTextAnchor", function() DF:UpdateAllFrames() end), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "statusTextX", nil, function() DF:LightweightUpdateTextPosition("status") end, true), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "statusTextY", nil, function() DF:LightweightUpdateTextPosition("status") end, true), 55)
        Add(positionGroup, nil, 2)
        
        -- ===== FONT GROUP (Column 1) =====
        local fontGroup = GUI:CreateSettingsGroup(self.child, 280)
        fontGroup:AddWidget(GUI:CreateHeader(self.child, L["Font"]), 40)
        fontGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "statusTextFont", function() DF:UpdateAllFrames() end), 55)
        fontGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "statusTextFontSize", nil, function() DF:LightweightUpdateFontSize("status") end, true), 55)
        
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }
        fontGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "statusTextOutline", function() DF:LightweightUpdateFontSize("status") end), 55)
        fontGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Text Color"], db, "statusTextColor", true, nil, function() DF:LightweightUpdateTextColor("status") end, true), 35)
        Add(fontGroup, nil, 1)
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "display_fading", label = L["Dead/Offline Fading"]},
        }), 30, "both")
    end)
    
    -- Text > Name Text
    local pageNameText = CreateSubTab("text", "text_name", L["Name Text"])
    BuildPage(pageNameText, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"name"}, L["Name Text"], "text_name"), 25, 2)
        
        -- ===== FONT GROUP (Column 1) =====
        local fontGroup = GUI:CreateSettingsGroup(self.child, 280)
        fontGroup:AddWidget(GUI:CreateHeader(self.child, L["Name Text"]), 40)
        fontGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "nameFont", nil), 55)
        fontGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "nameFontSize", nil, function() DF:LightweightUpdateFontSize("name") end, true), 55)
        
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }
        fontGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "nameTextOutline", function() DF:LightweightUpdateFontSize("name") end), 55)
        Add(fontGroup, nil, 1)
        
        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "nameTextAnchor", nil), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "nameTextX", nil, function() DF:LightweightUpdateTextPosition("name") end, true), 55)
        positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "nameTextY", nil, function() DF:LightweightUpdateTextPosition("name") end, true), 55)
        Add(positionGroup, nil, 2)
        
        -- ===== COLOR GROUP (Column 1) =====
        local colorGroup = GUI:CreateSettingsGroup(self.child, 280)
        colorGroup:AddWidget(GUI:CreateHeader(self.child, L["Color"]), 40)
        colorGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Class Color"], db, "nameTextUseClassColor", function()
            self:RefreshStates()
            DF:RefreshAllVisibleFrames()
        end), 30)
        local nameColor = colorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Name Color"], db, "nameTextColor", true, nil, function() DF:LightweightUpdateTextColor("name") end, true), 35)
        nameColor.disableOn = function(d) return d.nameTextUseClassColor end
        Add(colorGroup, nil, 1)
        
        -- ===== TRUNCATION GROUP (Column 2) =====
        local truncGroup = GUI:CreateSettingsGroup(self.child, 280)
        truncGroup:AddWidget(GUI:CreateHeader(self.child, L["Truncation"]), 40)
        truncGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Length (0=off)"], 0, 20, 1, db, "nameTextLength", function()
            self:RefreshStates()
            DF:RefreshAllVisibleFrames()
        end, function() DF:RefreshAllVisibleFrames() end, true), 55)
        
        local truncOptions = { ELLIPSIS= L["Ellipsis (...)"], CUT= L["Cut"] }
        local truncDropdown = truncGroup:AddWidget(GUI:CreateDropdown(self.child, L["Truncate Mode"], truncOptions, db, "nameTextTruncateMode", function() DF:RefreshAllVisibleFrames() end), 55)
        truncDropdown.disableOn = function(d) return (d.nameTextLength or 0) == 0 end
        Add(truncGroup, nil, 2)
    end)
    
    -- ========================================
    -- CATEGORY: Auras
    -- ========================================
    CreateCategory("auras", L["Auras"])

    -- Auras > Aura Filters (master switch for Blizzard vs Direct API mode)
    local pageAuraFilters = CreateSubTab("auras", "auras_filters", L["Aura Filters"])
    BuildPage(pageAuraFilters, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Setup wizard banner (hidden when Blizzard's aura pipeline is gone
        -- on 12.0.5+: the wizard walks users through choosing between Blizzard
        -- and Direct sources, which is meaningless when only Direct exists).
        if not DF.BlizzardAuraSourceUnavailable then
            local banner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
            banner:SetSize(520, 44)
            if not banner.SetBackdrop then Mixin(banner, BackdropTemplateMixin) end
            banner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            banner:SetBackdropColor(0.15, 0.18, 0.28, 1)
            local themeColor = GUI.GetThemeColor()
            banner:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)

            local bannerIcon = banner:CreateTexture(nil, "OVERLAY")
            bannerIcon:SetPoint("LEFT", 12, 0)
            bannerIcon:SetSize(20, 20)
            bannerIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\help")

            local bannerText = banner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            bannerText:SetPoint("LEFT", bannerIcon, "RIGHT", 8, 0)
            bannerText:SetPoint("RIGHT", banner, "RIGHT", -110, 0)
            bannerText:SetText(L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."])
            bannerText:SetTextColor(0.85, 0.85, 0.85)
            bannerText:SetJustifyH("LEFT")

            local bannerBtn = GUI:CreateButton(banner, L["Run Setup Wizard"], 105, 28, function()
                if DF.WizardBuilder then
                    local builtins = DF.WizardBuilder:GetBuiltinWizards()
                    for _, entry in ipairs(builtins) do
                        if entry.name == "Aura Filter Setup" and entry.build then
                            local config = entry.build()
                            if config then DF:ShowPopupWizard(config) end
                            break
                        end
                    end
                end
            end)
            bannerBtn:SetPoint("RIGHT", -8, 0)

            Add(banner, 50, "both")
            AddSpace(4, "both")
        end

        -- Copy button at top
        Add(CreateCopyButton(self.child, {"auraSourceMode", "directBuff", "directDebuff"}, L["Aura Filters"], "auras_filters"), 25, 2)

        -- ===== INFO BANNER =====
        -- Explains that Aura Filters only affect buff/debuff bars, with inline
        -- links to related pages so users can find the independent systems.
        do
            local infoBanner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
            infoBanner:SetSize(560, 56)
            if not infoBanner.SetBackdrop then Mixin(infoBanner, BackdropTemplateMixin) end
            infoBanner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            infoBanner:SetBackdropColor(0.15, 0.18, 0.28, 1)
            local tc = GUI.GetThemeColor()
            infoBanner:SetBackdropBorderColor(tc.r, tc.g, tc.b, 0.5)

            local infoIcon = infoBanner:CreateTexture(nil, "OVERLAY")
            infoIcon:SetPoint("TOPLEFT", 12, -10)
            infoIcon:SetSize(18, 18)
            infoIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\info")

            -- Helper to create an inline clickable link
            local function CreateInlineLink(parent, text, pageId)
                local btn = CreateFrame("Button", nil, parent)
                local fs = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                fs:SetAllPoints()
                fs:SetText(text)
                local c = GUI.GetThemeColor()
                fs:SetTextColor(c.r, c.g, c.b)
                btn:SetScript("OnEnter", function() fs:SetTextColor(1, 1, 1) end)
                btn:SetScript("OnLeave", function()
                    local c2 = GUI.GetThemeColor()
                    fs:SetTextColor(c2.r, c2.g, c2.b)
                end)
                btn:SetScript("OnClick", function()
                    if GUI.SelectTab then GUI.SelectTab(pageId) end
                end)
                btn:SetSize(fs:GetStringWidth() + 2, 14)
                return btn
            end

            -- Line 1: "Aura Filters only affect the [Buff Bar] and [Debuff Bar]."
            local t1 = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t1:SetPoint("TOPLEFT", infoIcon, "TOPRIGHT", 8, 2)
            t1:SetText(L["Aura Filters only affect the"])
            t1:SetTextColor(0.85, 0.85, 0.85)

            local linkBuff = CreateInlineLink(infoBanner, L["Buff Bar"], "auras_buffs")
            linkBuff:SetPoint("LEFT", t1, "RIGHT", 3, 0)

            local t2 = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t2:SetPoint("LEFT", linkBuff, "RIGHT", 3, 0)
            t2:SetText(L["and"])
            t2:SetTextColor(0.85, 0.85, 0.85)

            local linkDebuff = CreateInlineLink(infoBanner, L["Debuff Bar"], "auras_debuffs")
            linkDebuff:SetPoint("LEFT", t2, "RIGHT", 3, 0)

            local t2b = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t2b:SetPoint("LEFT", linkDebuff, "RIGHT", 0, 0)
            t2b:SetText(".")
            t2b:SetTextColor(0.85, 0.85, 0.85)

            -- Line 2: "Auras displayed in the [Dispel Overlay], [Defensive Icon], and [Aura Designer] are independent."
            local t3 = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t3:SetPoint("TOPLEFT", t1, "BOTTOMLEFT", 0, -4)
            t3:SetText(L["Auras displayed in the"])
            t3:SetTextColor(0.85, 0.85, 0.85)

            local linkDispel = CreateInlineLink(infoBanner, L["Dispel Overlay"], "auras_dispel")
            linkDispel:SetPoint("LEFT", t3, "RIGHT", 3, 0)

            local t4 = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t4:SetPoint("LEFT", linkDispel, "RIGHT", 0, 0)
            t4:SetText(",")
            t4:SetTextColor(0.85, 0.85, 0.85)

            local linkDef = CreateInlineLink(infoBanner, L["Defensive Icon"], "auras_defensiveicon")
            linkDef:SetPoint("LEFT", t4, "RIGHT", 3, 0)

            local t5 = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t5:SetPoint("LEFT", linkDef, "RIGHT", 0, 0)
            t5:SetText(",")
            t5:SetTextColor(0.85, 0.85, 0.85)

            local linkAD = CreateInlineLink(infoBanner, L["Aura Designer"], "auras_auradesigner")
            linkAD:SetPoint("LEFT", t5, "RIGHT", 3, 0)

            local t5b = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t5b:SetPoint("LEFT", linkAD, "RIGHT", 0, 0)
            t5b:SetText(", " .. L["and"])
            t5b:SetTextColor(0.85, 0.85, 0.85)

            local linkBoss = CreateInlineLink(infoBanner, L["Boss Debuffs"], "auras_bossdebuffs")
            linkBoss:SetPoint("LEFT", t5b, "RIGHT", 3, 0)

            local t6 = infoBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            t6:SetPoint("LEFT", linkBoss, "RIGHT", 3, 0)
            t6:SetText(L["are independent of Aura Filters."])
            t6:SetTextColor(0.85, 0.85, 0.85)

            Add(infoBanner, 62, "both")
            AddSpace(4, "both")
        end

        -- hideOn helper: only show Direct mode options when Direct is selected
        local function HideDirectOptions(d)
            return d.auraSourceMode ~= "DIRECT"
        end

        -- Callback that rebuilds filter strings and rescans
        local function DirectFilterChanged()
            if DF.RebuildDirectFilterStrings then
                DF:RebuildDirectFilterStrings()
            end
            if DF.DirectScanAllUnits then
                DF:DirectScanAllUnits()
            end
        end

        -- ===== MODE SELECTION (Column 1) =====
        local modeGroup = GUI:CreateSettingsGroup(self.child, 280)
        modeGroup:AddWidget(GUI:CreateHeader(self.child, L["Aura Data Source"]), 40)

        local modeOptions = {
            BLIZZARD = L["Blizzard (Default)"],
            DIRECT = L["Direct API"],
        }
        local modeDropdown = modeGroup:AddWidget(GUI:CreateDropdown(self.child, L["Source Mode"], modeOptions, db, "auraSourceMode", function()
            if DF.SetAuraSourceMode then
                DF:SetAuraSourceMode(db.auraSourceMode)
            end
            self:RefreshStates()
        end), 55)
        -- Disable the dropdown when Blizzard's aura pipeline has been removed
        -- (12.0.5+). The forced-DIRECT migration in Features/Auras.lua ensures
        -- the value is correct; this just prevents the user from trying to
        -- switch back to a source that no longer exists.
        modeDropdown.disableOn = function() return DF.BlizzardAuraSourceUnavailable end

        -- Warning note shown when the Blizzard source has been force-disabled.
        -- Uses hideOn (not disableOn) since it's informational text.
        local apiBlockedNote = modeGroup:AddWidget(GUI:CreateLabel(self.child,
            "|cffffcc00WoW 12.0.5 removed addon access to Blizzard's party-frame aura data. The Blizzard source is no longer available; DandersFrames has switched to Direct API automatically.|r", 250), 60)
        apiBlockedNote.hideOn = function() return not DF.BlizzardAuraSourceUnavailable end

        Add(modeGroup, nil, 1)

        -- ===== BUFF FILTERS (Column 2, Direct mode only) =====
        local function HideBuffSubFilters(d)
            return d.auraSourceMode ~= "DIRECT" or d.directBuffShowAll
        end

        local buffGroup = GUI:CreateSettingsGroup(self.child, 280)
        buffGroup.hideOn = HideDirectOptions
        local buffHeader = buffGroup:AddWidget(GUI:CreateHeader(self.child, L["Buff Filters"]), 40)
        buffHeader.hideOn = HideDirectOptions

        local bfAll = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["All Buffs"], db, "directBuffShowAll", function()
            DirectFilterChanged()
            self:RefreshStates()
        end), 30)
        bfAll.hideOn = HideDirectOptions
        bfAll.tooltip = L["Show every buff with no filtering."]

        local bfOnlyMine = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Only My Buffs"], db, "directBuffOnlyMine", function()
            DirectFilterChanged()
            self:RefreshStates()
        end), 30)
        bfOnlyMine.hideOn = HideDirectOptions
        bfOnlyMine.tooltip = L["Only show buffs that you cast. Applies to all buff filters."]

        local buffSubInfo = buffGroup:AddWidget(GUI:CreateLabel(self.child, "|cff888888Enabled filters are combined \226\128\148 buffs matching any selected filter will be shown.|r", 250), 35)
        buffSubInfo.hideOn = HideBuffSubFilters

        local bfRaid = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Raid Buffs"], db, "directBuffFilterRaid", DirectFilterChanged), 30)
        bfRaid.hideOn = HideBuffSubFilters
        bfRaid.tooltip = L["Buffs flagged by Blizzard to show up on raid frames."]

        local bfRaidIC = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Raid In Combat"], db, "directBuffFilterRaidInCombat", DirectFilterChanged), 30)
        bfRaidIC.hideOn = HideBuffSubFilters
        bfRaidIC.tooltip = L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."]

        local bfCancel = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Cancelable"], db, "directBuffFilterCancelable", DirectFilterChanged), 30)
        bfCancel.hideOn = HideBuffSubFilters
        bfCancel.tooltip = L["Buffs that can be right-click cancelled."]

        local bfNotCancel = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Not Cancelable"], db, "directBuffFilterNotCancelable", DirectFilterChanged), 30)
        bfNotCancel.hideOn = HideBuffSubFilters
        bfNotCancel.tooltip = L["Buffs that cannot be cancelled by the player."]

        local bfImportant = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Important Spells"], db, "directBuffFilterImportant", DirectFilterChanged), 30)
        bfImportant.hideOn = HideBuffSubFilters
        bfImportant.tooltip = L["Spells flagged as important by Blizzard."]

        local bfBigDef = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Big Defensives"], db, "directBuffFilterBigDefensive", DirectFilterChanged), 30)
        bfBigDef.hideOn = HideBuffSubFilters
        bfBigDef.tooltip = L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."]

        local bfExtDef = buffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["External Defensives"], db, "directBuffFilterExternalDefensive", DirectFilterChanged), 30)
        bfExtDef.hideOn = HideBuffSubFilters
        bfExtDef.tooltip = L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."]

        local buffSortOptions = {
            DEFAULT = L["Default (Slot Order)"],
            TIME = L["Time Remaining"],
            NAME = L["Alphabetical"],
        }
        local bfSort = buffGroup:AddWidget(GUI:CreateDropdown(self.child, L["Sort Order"], buffSortOptions, db, "directBuffSortOrder", DirectFilterChanged), 55)
        bfSort.hideOn = HideDirectOptions
        Add(buffGroup, nil, 2)

        -- ===== DEBUFF FILTERS (Column 1, Direct mode only) =====
        local function HideDebuffSubFilters(d)
            return d.auraSourceMode ~= "DIRECT" or d.directDebuffShowAll
        end

        local debuffGroup = GUI:CreateSettingsGroup(self.child, 280)
        debuffGroup.hideOn = HideDirectOptions
        local debuffHeader = debuffGroup:AddWidget(GUI:CreateHeader(self.child, L["Debuff Filters"]), 40)
        debuffHeader.hideOn = HideDirectOptions

        local dfAll = debuffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["All Debuffs"], db, "directDebuffShowAll", function()
            DirectFilterChanged()
            self:RefreshStates()
        end), 30)
        dfAll.hideOn = HideDirectOptions
        dfAll.tooltip = L["Show every debuff with no filtering."]

        -- ===== WARNING BANNER: All Debuffs disabled =====
        local debuffWarningBanner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        debuffWarningBanner:SetSize(560, 45)
        debuffWarningBanner:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        debuffWarningBanner:SetBackdropColor(0.5, 0.45, 0.1, 0.9)
        debuffWarningBanner:SetBackdropBorderColor(0.7, 0.6, 0.1, 1)

        local debuffWarningIcon = debuffWarningBanner:CreateTexture(nil, "OVERLAY")
        debuffWarningIcon:SetSize(20, 20)
        debuffWarningIcon:SetPoint("LEFT", 12, 0)
        debuffWarningIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\warning")
        debuffWarningIcon:SetVertexColor(1, 0.9, 0.3)

        local debuffWarningText = debuffWarningBanner:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        debuffWarningText:SetPoint("LEFT", debuffWarningIcon, "RIGHT", 8, 0)
        debuffWarningText:SetPoint("RIGHT", -12, 0)
        debuffWarningText:SetJustifyH("LEFT")
        debuffWarningText:SetWordWrap(true)
        debuffWarningText:SetText(L["Recommended: enable 'All Debuffs' to see all relevant debuffs, especially for healers."])
        debuffWarningText:SetTextColor(1, 0.95, 0.7)

        debuffWarningBanner.hideOn = function(d)
            return d.auraSourceMode ~= "DIRECT" or d.directDebuffShowAll
        end
        debuffGroup:AddWidget(debuffWarningBanner, 50)

        local debuffSubInfo = debuffGroup:AddWidget(GUI:CreateLabel(self.child, "|cff888888Enabled filters are combined \226\128\148 debuffs matching any selected filter will be shown.|r", 250), 35)
        debuffSubInfo.hideOn = HideDebuffSubFilters

        local dfRaid = debuffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Raid Debuffs"], db, "directDebuffFilterRaid", DirectFilterChanged), 30)
        dfRaid.hideOn = HideDebuffSubFilters
        dfRaid.tooltip = L["Debuffs relevant in a raid context."]

        local dfRaidIC = debuffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Raid In Combat"], db, "directDebuffFilterRaidInCombat", DirectFilterChanged), 30)
        dfRaidIC.hideOn = HideDebuffSubFilters
        dfRaidIC.tooltip = L["Debuffs relevant during combat in a raid context."]

        local dfCC = debuffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Crowd Control"], db, "directDebuffFilterCrowdControl", DirectFilterChanged), 30)
        dfCC.hideOn = HideDebuffSubFilters
        dfCC.tooltip = L["CC effects like stuns, roots, and incapacitates."]

        local dfImportant = debuffGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Important Spells"], db, "directDebuffFilterImportant", DirectFilterChanged), 30)
        dfImportant.hideOn = HideDebuffSubFilters
        dfImportant.tooltip = L["Spells flagged as important by Blizzard."]

        local dfDispelToggle = debuffGroup:AddWidget(GUI:CreateToggleSwitch(self.child, L["Dispellable By Me"], L["All Dispellable"], db, "directDebuffDispellableMode", "PLAYER", "ALL", DirectFilterChanged), 30)
        dfDispelToggle.hideOn = HideDebuffSubFilters
        dfDispelToggle.tooltip = L["Dispellable By Me: only debuffs you can dispel. All Dispellable: any debuff that can be dispelled."]

        local debuffSortOptions = {
            DEFAULT = L["Default (Slot Order)"],
            TIME = L["Time Remaining"],
            NAME = L["Alphabetical"],
        }
        local dfSort = debuffGroup:AddWidget(GUI:CreateDropdown(self.child, L["Sort Order"], debuffSortOptions, db, "directDebuffSortOrder", DirectFilterChanged), 55)
        dfSort.hideOn = HideDirectOptions
        Add(debuffGroup, nil, 1)

        -- ===== AURA BLACKLIST (Column 2, under Buff Filters) =====
        -- Pointer section directing users to the dedicated Aura Blacklist tab.
        -- Aura Filters (this tab) controls what types of auras are shown;
        -- the Aura Blacklist tab is where specific spells are excluded.
        do
            local blacklistGroup = GUI:CreateSettingsGroup(self.child, 280)
            blacklistGroup:AddWidget(GUI:CreateHeader(self.child, L["Aura Blacklist"]), 40)
            blacklistGroup:AddWidget(GUI:CreateLabel(self.child,
                L["To blacklist specific auras, see the Aura Blacklist tab."], 250), 40)

            -- Clickable link button styled like the inline links in the info banner above.
            local linkBtn = CreateFrame("Button", nil, self.child)
            linkBtn:SetSize(250, 18)
            local linkFs = linkBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            linkFs:SetPoint("LEFT", 0, 0)
            linkFs:SetText(L["Open Aura Blacklist"])
            local blTc = GUI.GetThemeColor()
            linkFs:SetTextColor(blTc.r, blTc.g, blTc.b)
            linkBtn:SetScript("OnEnter", function() linkFs:SetTextColor(1, 1, 1) end)
            linkBtn:SetScript("OnLeave", function()
                local c = GUI.GetThemeColor()
                linkFs:SetTextColor(c.r, c.g, c.b)
            end)
            linkBtn:SetScript("OnClick", function()
                if GUI.SelectTab then GUI.SelectTab("auras_blacklist") end
            end)
            blacklistGroup:AddWidget(linkBtn, 24)

            Add(blacklistGroup, nil, 2)
        end

        -- ===== SEE ALSO =====
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_buffs", label = L["Buff Icons"]},
            {pageId = "auras_debuffs", label = L["Debuff Icons"]},
            {pageId = "auras_blacklist", label = L["Aura Blacklist"]},
            {pageId = "auras_auradesigner", label = L["Aura Designer"]},
        }), 30, "both")
    end)

    -- Auras > Aura Designer
    local pageAuraDesigner = CreateSubTab("auras", "auras_auradesigner", L["Aura Designer"])
    BuildPage(pageAuraDesigner, function(self, db, Add, AddSpace, AddSyncPoint)
        if DF.BuildAuraDesignerPage then
            DF.BuildAuraDesignerPage(GUI, self, db)
        end
    end)

    -- Auras > Aura Blacklist
    local pageAuraBlacklist = CreateSubTab("auras", "auras_blacklist", L["Aura Blacklist"])
    BuildPage(pageAuraBlacklist, function(self, db, Add, AddSpace, AddSyncPoint)
        if DF.BuildAuraBlacklistPage then
            DF.BuildAuraBlacklistPage(GUI, self, db)
        end
    end)

    -- Auras > Buffs (combined Layout + Appearance with collapsible sections)
    local pageBuffs = CreateSubTab("auras", "auras_buffs", L["Buffs"])
    BuildPage(pageBuffs, function(self, db, Add, AddSpace, AddSyncPoint)
        -- ========================================
        -- AD COEXISTENCE INFO BANNER
        -- Shows when Aura Designer is active (with or without buffs).
        -- ========================================
        local adBanner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        adBanner:SetHeight(28)
        adBanner:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        adBanner:SetBackdropColor(0.14, 0.14, 0.14, 1)
        adBanner:SetBackdropBorderColor(0.30, 0.30, 0.30, 0.5)

        local adBannerText = adBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        adBannerText:SetPoint("LEFT", 10, 0)
        adBannerText:SetTextColor(0.6, 0.6, 0.6)

        local adBannerLinkBtn = CreateFrame("Button", nil, adBanner)
        adBannerLinkBtn:SetSize(120, 18)
        adBannerLinkBtn:SetPoint("LEFT", adBannerText, "RIGHT", 8, 0)
        local adBannerLinkText = adBannerLinkBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        adBannerLinkText:SetAllPoints()
        adBannerLinkText:SetText(L["Open Aura Designer"])
        local tc = GUI.GetThemeColor()
        adBannerLinkText:SetTextColor(tc.r, tc.g, tc.b)
        adBannerLinkBtn:SetScript("OnEnter", function() adBannerLinkText:SetTextColor(1, 1, 1) end)
        adBannerLinkBtn:SetScript("OnLeave", function()
            local c = GUI.GetThemeColor()
            adBannerLinkText:SetTextColor(c.r, c.g, c.b)
        end)
        adBannerLinkBtn:SetScript("OnClick", function()
            if GUI.SelectTab then GUI.SelectTab("auras_auradesigner") end
        end)

        -- Second link: "Enable Buffs" (only shown when showBuffs is false)
        local enableBuffsBtn = CreateFrame("Button", nil, adBanner)
        enableBuffsBtn:SetSize(85, 18)
        enableBuffsBtn:SetPoint("LEFT", adBannerText, "RIGHT", 8, 0)
        local enableBuffsText = enableBuffsBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        enableBuffsText:SetAllPoints()
        enableBuffsText:SetText(L["Enable Buffs"])
        enableBuffsText:SetTextColor(tc.r, tc.g, tc.b)
        enableBuffsBtn:SetScript("OnEnter", function() enableBuffsText:SetTextColor(1, 1, 1) end)
        enableBuffsBtn:SetScript("OnLeave", function()
            local c = GUI.GetThemeColor()
            enableBuffsText:SetTextColor(c.r, c.g, c.b)
        end)
        enableBuffsBtn:SetScript("OnClick", function()
            db.showBuffs = true
            self:RefreshStates()
            DF:InvalidateAuraLayout()
            DF:UpdateAllFrames()
        end)

        -- Refresh banner content based on current state
        adBanner.refreshContent = function(_, d)
            local adEnabled = d.auraDesigner and d.auraDesigner.enabled
            if adEnabled and d.showBuffs then
                adBannerText:SetText(L["Aura Designer is active alongside Buffs."])
                enableBuffsBtn:Hide()
                adBannerLinkBtn:ClearAllPoints()
                adBannerLinkBtn:SetPoint("LEFT", adBannerText, "RIGHT", 8, 0)
                adBannerLinkBtn:Show()
            elseif adEnabled and not d.showBuffs then
                adBannerText:SetText(L["Buffs are disabled. Aura Designer is managing your auras."])
                enableBuffsBtn:ClearAllPoints()
                enableBuffsBtn:SetPoint("LEFT", adBannerText, "RIGHT", 8, 0)
                enableBuffsBtn:Show()
                adBannerLinkBtn:ClearAllPoints()
                adBannerLinkBtn:SetPoint("LEFT", enableBuffsBtn, "RIGHT", 8, 0)
                adBannerLinkBtn:Show()
            end
        end

        adBanner.hideOn = function(d)
            return not (d.auraDesigner and d.auraDesigner.enabled)
        end

        Add(adBanner, 32, "both")

        -- Copy button at top right
        Add(CreateCopyButton(self.child, {"buff"}, L["Buffs"], "auras_buffs"), 25, 2)

        -- ===== DEDUPLICATION =====
        AddSpace(10, "both")
        local dedupGroup = GUI:CreateSettingsGroup(self.child, 280)
        dedupGroup:AddWidget(GUI:CreateHeader(self.child, L["Deduplication"]), 40)
        dedupGroup:AddWidget(GUI:CreateLabel(self.child, L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."], 250), 45)
        dedupGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide duplicate buffs"], db, "buffDeduplicateDefensives", function()
            DF:UpdateAllAuras()
        end), 30)
        Add(dedupGroup, nil, 1)

        AddSpace(10, "both")

        local currentSection = nil
        
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then currentSection:RegisterChild(widget) end
            return widget
        end
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }

        -- ===== LAYOUT SECTION =====
        local layoutSection = Add(GUI:CreateCollapsibleSection(self.child, L["Layout"], true), 36, "both")
        currentSection = layoutSection

        -- Settings Group (col1)
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 260)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        local showBuffsCb = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Buffs"], db, "showBuffs", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 30)
        -- Re-sync checked state when value changes externally (e.g. AD banner click)
        showBuffsCb.refreshContent = function(self)
            local onShow = self:GetScript("OnShow")
            if onShow then onShow(self) end
        end
        local buffMax = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Buffs"], 0, 8, 1, db, "buffMax", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        buffMax.disableOn = function(d) return not d.showBuffs end
        local buffSize = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 10, 40, 1, db, "buffSize", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffSize.disableOn = function(d) return not d.showBuffs end
        local buffScale = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "buffScale", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffScale.disableOn = function(d) return not d.showBuffs end
        local buffAlpha = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.0, 1.0, 0.05, db, "buffAlpha", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffAlpha.disableOn = function(d) return not d.showBuffs end
        AddToSection(settingsGroup, nil, 1)
        
        -- Position Group (col2)
        local positionGroup = GUI:CreateSettingsGroup(self.child, 260)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        local buffAnchor = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "buffAnchor", nil), 55)
        buffAnchor.disableOn = function(d) return not d.showBuffs end
        local buffGrowth = positionGroup:AddWidget(GUI:CreateGrowthControl(self.child, db, "buffGrowth", nil), 155)
        buffGrowth.disableOn = function(d) return not d.showBuffs end
        local buffOffsetX = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "buffOffsetX", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffOffsetX.disableOn = function(d) return not d.showBuffs end
        local buffOffsetY = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "buffOffsetY", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffOffsetY.disableOn = function(d) return not d.showBuffs end
        AddToSection(positionGroup, nil, 2)
        
        -- Grid Layout Group (col1)
        local gridGroup = GUI:CreateSettingsGroup(self.child, 260)
        gridGroup:AddWidget(GUI:CreateHeader(self.child, L["Grid Layout"]), 40)
        local buffWrap = gridGroup:AddWidget(GUI:CreateSlider(self.child, L["Icons Per Row"], 1, 8, 1, db, "buffWrap", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffWrap.disableOn = function(d) return not d.showBuffs end
        local buffPaddingX = gridGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing X"], -5, 10, 1, db, "buffPaddingX", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffPaddingX.disableOn = function(d) return not d.showBuffs end
        local buffPaddingY = gridGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing Y"], -5, 10, 1, db, "buffPaddingY", nil, function() DF:LightweightUpdateAuraPosition("buff") end, true), 55)
        buffPaddingY.disableOn = function(d) return not d.showBuffs end
        AddToSection(gridGroup, nil, 1)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== APPEARANCE SECTION =====
        local appearanceSection = Add(GUI:CreateCollapsibleSection(self.child, L["Appearance"], true), 36, "both")
        currentSection = appearanceSection
        
        local function MasqueControlsBorders(d)
            return DF.Masque and d.masqueBorderControl
        end
        
        -- Border Group (col1)
        local borderGroup = GUI:CreateSettingsGroup(self.child, 260)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        local buffMasqueNote = borderGroup:AddWidget(GUI:CreateLabel(self.child, "|cffff9900Borders controlled by Masque.|r See Integrations.", 230), 30)
        buffMasqueNote.hideOn = function(d) return not MasqueControlsBorders(d) end
        local buffBorderEnabled = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "buffBorderEnabled", nil), 30)
        buffBorderEnabled.disableOn = function(d) return not d.showBuffs or MasqueControlsBorders(d) end
        buffBorderEnabled.hideOn = function(d) return MasqueControlsBorders(d) end
        local buffBorderThickness = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Thickness"], 1, 5, 1, db, "buffBorderThickness", nil, function() DF:LightweightUpdateAuraBorder("buff") end, true), 55)
        buffBorderThickness.disableOn = function(d) return not d.showBuffs or not d.buffBorderEnabled or MasqueControlsBorders(d) end
        buffBorderThickness.hideOn = function(d) return MasqueControlsBorders(d) end
        local buffBorderInset = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Inset"], -3, 3, 1, db, "buffBorderInset", nil, function() DF:LightweightUpdateAuraBorder("buff") end, true), 55)
        buffBorderInset.disableOn = function(d) return not d.showBuffs or not d.buffBorderEnabled or MasqueControlsBorders(d) end
        buffBorderInset.hideOn = function(d) return MasqueControlsBorders(d) end
        borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Cooldown Swipe"], db, "buffHideSwipe", nil), 30)
        AddToSection(borderGroup, nil, 1)
        
        -- Stack Count Group (col1)
        local stackCountGroup = GUI:CreateSettingsGroup(self.child, 260)
        stackCountGroup:AddWidget(GUI:CreateHeader(self.child, L["Stack Count"]), 40)
        stackCountGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "buffStackFont", function() DF:LightweightUpdateAuraStackText("buff") end), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "buffStackScale", nil, function() DF:LightweightUpdateAuraStackText("buff") end, true), 55)
        stackCountGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "buffStackOutline", function() DF:LightweightUpdateAuraStackText("buff") end), 55)
        stackCountGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "buffStackAnchor", function() DF:LightweightUpdateAuraStackText("buff") end), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "buffStackX", nil, function() DF:LightweightUpdateAuraStackText("buff") end, true), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "buffStackY", nil, function() DF:LightweightUpdateAuraStackText("buff") end, true), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Min Stacks to Show"], 1, 10, 1, db, "buffStackMinimum", nil), 55)
        AddToSection(stackCountGroup, nil, 1)
        
        -- Duration Text Group (col2)
        local durationGroup = GUI:CreateSettingsGroup(self.child, 260)
        durationGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration Text"]), 40)
        local durShow = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration"], db, "buffShowDuration", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 30)
        local durFont = durationGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "buffDurationFont", nil), 55)
        durFont.disableOn = function(d) return not d.buffShowDuration end
        local durScale = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "buffDurationScale", nil, function() DF:LightweightUpdateAuraDurationText("buff") end, true), 55)
        durScale.disableOn = function(d) return not d.buffShowDuration end
        local durOutline = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "buffDurationOutline", function() DF:LightweightUpdateAuraDurationText("buff") end), 55)
        durOutline.disableOn = function(d) return not d.buffShowDuration end
        local durAnchor = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "buffDurationAnchor", function() DF:LightweightUpdateAuraDurationText("buff") end), 55)
        durAnchor.disableOn = function(d) return not d.buffShowDuration end
        local durX = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "buffDurationX", nil, function() DF:LightweightUpdateAuraDurationText("buff") end, true), 55)
        durX.disableOn = function(d) return not d.buffShowDuration end
        local durY = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "buffDurationY", nil, function() DF:LightweightUpdateAuraDurationText("buff") end, true), 55)
        durY.disableOn = function(d) return not d.buffShowDuration end
        local durColor = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Color by Time Remaining"], db, "buffDurationColorByTime", function() DF:RefreshDurationColorSettings() end), 30)
        durColor.disableOn = function(d) return not d.buffShowDuration end
        local durHideAbove = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Above Threshold"], db, "buffDurationHideAboveEnabled", function() DF:RefreshDurationColorSettings() end), 30)
        durHideAbove.disableOn = function(d) return not d.buffShowDuration end
        local durHideAboveSlider = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Hide Above (seconds)"], 1, 60, 1, db, "buffDurationHideAboveThreshold", nil, function() DF:RefreshDurationColorSettings() end), 55)
        durHideAboveSlider.disableOn = function(d) return not d.buffShowDuration or not d.buffDurationHideAboveEnabled end
        AddToSection(durationGroup, nil, 2)

        -- Expiring Indicator Group (col2)
        local expiringGroup = GUI:CreateSettingsGroup(self.child, 260)
        expiringGroup:AddWidget(GUI:CreateHeader(self.child, L["Expiring Indicator"]), 40)
        expiringGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Expiring Indicators"], db, "buffExpiringEnabled", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 30)
        local function HideExpiring(d) return not d.buffExpiringEnabled end
        local isSeconds = db.buffExpiringThresholdMode == "SECONDS"
        local thresholdLabel = isSeconds and L["Expiring Threshold (seconds)"] or L["Expiring Threshold (%)"]
        local thresholdMin = isSeconds and 1 or 5
        local thresholdMax = isSeconds and 60 or 95
        local thresholdStep = isSeconds and 1 or 5
        local thresholdSlider = expiringGroup:AddWidget(GUI:CreateSlider(self.child, thresholdLabel, thresholdMin, thresholdMax, thresholdStep, db, "buffExpiringThreshold", nil), 55)
        thresholdSlider.disableOn = HideExpiring
        local modeBtn = expiringGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Seconds Instead of Percent"], nil, nil,
            nil,
            function() return db.buffExpiringThresholdMode == "SECONDS" end,
            function(val)
                if val then
                    db.buffExpiringThresholdMode = "SECONDS"
                    db.buffExpiringThreshold = 10
                else
                    db.buffExpiringThresholdMode = "PERCENT"
                    db.buffExpiringThreshold = 30
                end
                DF:UpdateAllFrames()
                self:Refresh()
            end,
            "buffExpiringThresholdMode"), 30)
        modeBtn.disableOn = HideExpiring
        local borderEnabled = expiringGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Expiring Border"], db, "buffExpiringBorderEnabled", function()
            self:RefreshStates()
            DF:UpdateAllFrames() 
        end), 30)
        borderEnabled.disableOn = HideExpiring
        local borderColorByTime = expiringGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Color by Time Remaining"], db, "buffExpiringBorderColorByTime", function() 
            self:RefreshStates()
            DF:UpdateAllFrames() 
        end), 30)
        borderColorByTime.disableOn = function(d) return not d.buffExpiringEnabled or not d.buffExpiringBorderEnabled end
        local borderColor = expiringGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "buffExpiringBorderColor", true, nil, function() DF:LightweightUpdateExpiringBorderColor() end, true), 35)
        borderColor.disableOn = function(d) return not d.buffExpiringEnabled or not d.buffExpiringBorderEnabled or d.buffExpiringBorderColorByTime end
        borderColor.hideOn = function(d) return d.buffExpiringBorderColorByTime end
        local borderPulsate = expiringGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Pulsate Border"], db, "buffExpiringBorderPulsate", nil), 30)
        borderPulsate.disableOn = function(d) return not d.buffExpiringEnabled or not d.buffExpiringBorderEnabled end
        local borderThickness = expiringGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Thickness"], 1, 5, 1, db, "buffExpiringBorderThickness", nil, function() DF:LightweightUpdateAuraBorder("buff") end, true), 55)
        borderThickness.disableOn = function(d) return not d.buffExpiringEnabled or not d.buffExpiringBorderEnabled end
        local borderInset = expiringGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Inset"], -3, 3, 1, db, "buffExpiringBorderInset", nil, function() DF:LightweightUpdateAuraBorder("buff") end, true), 55)
        borderInset.disableOn = function(d) return not d.buffExpiringEnabled or not d.buffExpiringBorderEnabled end
        local tintEnabled = expiringGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Expiring Tint"], db, "buffExpiringTintEnabled", nil), 30)
        tintEnabled.disableOn = HideExpiring
        local tintColor = expiringGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Tint Color"], db, "buffExpiringTintColor", true, nil, function() DF:LightweightUpdateExpiringTintColor() end, true), 35)
        tintColor.disableOn = function(d) return not d.buffExpiringEnabled or not d.buffExpiringTintEnabled end
        AddToSection(expiringGroup, nil, 2)

        currentSection = nil

        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "display_tooltips", label = L["Buff Tooltips"]},
            {pageId = "general_integrations", label = L["Integrations"]},
            {pageId = "auras_missingbuffs", label = L["Missing Buffs"]},
            {pageId = "auras_defensiveicon", label = L["Defensive Icon"]},
        }), 30, "both")
    end)

    -- Auras > My Buff Indicators — DEPRECATED: tab removed from UI, feature force-disabled on load.
    -- Code kept intact in Features/MyBuffIndicators.lua for potential future re-enablement.

    -- Auras > Debuffs (combined Layout + Appearance with collapsible sections)
    local pageDebuffs = CreateSubTab("auras", "auras_debuffs", L["Debuffs"])
    BuildPage(pageDebuffs, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"debuff"}, L["Debuffs"], "auras_debuffs"), 25, 2)
        
        AddSpace(10, "both")
        
        local currentSection = nil
        
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then currentSection:RegisterChild(widget) end
            return widget
        end
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }

        -- ===== LAYOUT SECTION =====
        local layoutSection = Add(GUI:CreateCollapsibleSection(self.child, L["Layout"], true), 36, "both")
        currentSection = layoutSection

        -- Settings Group (col1)
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 260)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Debuffs"], db, "showDebuffs", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 30)
        local dispelHighlight = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Highlight Dispellable"], db, "dispellableHighlight", nil), 30)
        dispelHighlight.disableOn = function(d) return not d.showDebuffs end
        local debuffMax = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Debuffs"], 0, 8, 1, db, "debuffMax", nil, function() DF:RefreshAllVisibleFrames() end, true), 55)
        debuffMax.disableOn = function(d) return not d.showDebuffs end
        local debuffSize = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 10, 40, 1, db, "debuffSize", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffSize.disableOn = function(d) return not d.showDebuffs end
        local debuffScale = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "debuffScale", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffScale.disableOn = function(d) return not d.showDebuffs end
        local debuffAlpha = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.0, 1.0, 0.05, db, "debuffAlpha", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffAlpha.disableOn = function(d) return not d.showDebuffs end
        AddToSection(settingsGroup, nil, 1)
        
        -- Position Group (col2)
        local positionGroup = GUI:CreateSettingsGroup(self.child, 260)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        local debuffAnchor = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "debuffAnchor", nil), 55)
        debuffAnchor.disableOn = function(d) return not d.showDebuffs end
        local debuffGrowth = positionGroup:AddWidget(GUI:CreateGrowthControl(self.child, db, "debuffGrowth", nil), 155)
        debuffGrowth.disableOn = function(d) return not d.showDebuffs end
        local debuffOffsetX = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "debuffOffsetX", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffOffsetX.disableOn = function(d) return not d.showDebuffs end
        local debuffOffsetY = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "debuffOffsetY", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffOffsetY.disableOn = function(d) return not d.showDebuffs end
        AddToSection(positionGroup, nil, 2)
        
        -- Grid Layout Group (col1)
        local gridGroup = GUI:CreateSettingsGroup(self.child, 260)
        gridGroup:AddWidget(GUI:CreateHeader(self.child, L["Grid Layout"]), 40)
        local debuffWrap = gridGroup:AddWidget(GUI:CreateSlider(self.child, L["Icons Per Row"], 1, 8, 1, db, "debuffWrap", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffWrap.disableOn = function(d) return not d.showDebuffs end
        local debuffPaddingX = gridGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing X"], -5, 10, 1, db, "debuffPaddingX", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffPaddingX.disableOn = function(d) return not d.showDebuffs end
        local debuffPaddingY = gridGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing Y"], -5, 10, 1, db, "debuffPaddingY", nil, function() DF:LightweightUpdateAuraPosition("debuff") end, true), 55)
        debuffPaddingY.disableOn = function(d) return not d.showDebuffs end
        AddToSection(gridGroup, nil, 1)
        
        -- Blizzard Settings Group (col2)
        local blizzGroup = GUI:CreateSettingsGroup(self.child, 260)
        blizzGroup:AddWidget(GUI:CreateHeader(self.child, L["Blizzard Frame Settings"]), 40)
        blizzGroup:AddWidget(GUI:CreateLabel(self.child, L["Controls Blizzard's debuff filtering (affects our display too)."], 230), 35)
        local partyDb = DF.db.party
        blizzGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Only Dispellable Debuffs"], partyDb, "_blizzOnlyDispellable", function()
            local newValue = partyDb._blizzOnlyDispellable
            SetCVar("raidFramesDisplayOnlyDispellableDebuffs", newValue and 1 or 0)
        end), 30)
        AddToSection(blizzGroup, nil, 2)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== APPEARANCE SECTION =====
        local appearanceSection = Add(GUI:CreateCollapsibleSection(self.child, L["Appearance"], true), 36, "both")
        currentSection = appearanceSection
        
        local function MasqueControlsBorders(d)
            return DF.Masque and d.masqueBorderControl
        end
        
        local function InvalidateAndUpdate()
            DF.debuffBorderCurve = nil
            DF:UpdateAllFrames()
        end
        
        -- Border Group (col1)
        local borderGroup = GUI:CreateSettingsGroup(self.child, 260)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        local debuffMasqueNote = borderGroup:AddWidget(GUI:CreateLabel(self.child, "|cffff9900Borders controlled by Masque.|r See Integrations.", 230), 30)
        debuffMasqueNote.hideOn = function(d) return not MasqueControlsBorders(d) end
        local debuffBorderEnabled = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "debuffBorderEnabled", InvalidateAndUpdate), 30)
        debuffBorderEnabled.disableOn = function(d) return not d.showDebuffs or MasqueControlsBorders(d) end
        debuffBorderEnabled.hideOn = function(d) return MasqueControlsBorders(d) end
        local debuffBorderThickness = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Thickness"], 1, 5, 1, db, "debuffBorderThickness", nil, function() DF:LightweightUpdateAuraBorder("debuff") end, true), 55)
        debuffBorderThickness.disableOn = function(d) return not d.showDebuffs or not d.debuffBorderEnabled or MasqueControlsBorders(d) end
        debuffBorderThickness.hideOn = function(d) return MasqueControlsBorders(d) end
        local debuffBorderInset = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Inset"], -3, 3, 1, db, "debuffBorderInset", nil, function() DF:LightweightUpdateAuraBorder("debuff") end, true), 55)
        debuffBorderInset.disableOn = function(d) return not d.showDebuffs or not d.debuffBorderEnabled or MasqueControlsBorders(d) end
        debuffBorderInset.hideOn = function(d) return MasqueControlsBorders(d) end
        local colorByType = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Color by Dispel Type"], db, "debuffBorderColorByType", InvalidateAndUpdate), 30)
        colorByType.disableOn = function(d) return not d.debuffBorderEnabled or MasqueControlsBorders(d) end
        colorByType.hideOn = function(d) return MasqueControlsBorders(d) end
        borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Cooldown Swipe"], db, "debuffHideSwipe", nil), 30)
        AddToSection(borderGroup, nil, 1)
        
        -- Dispel Colors Group (col2)
        local colorsGroup = GUI:CreateSettingsGroup(self.child, 260)
        colorsGroup:AddWidget(GUI:CreateHeader(self.child, L["Dispel Type Colors"]), 40)
        local magicColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Magic"], db, "debuffBorderColorMagic", false, InvalidateAndUpdate, function() DF:LightweightUpdateDebuffBorderColors() end, true), 30)
        magicColor.disableOn = function(d) return not d.debuffBorderEnabled or not d.debuffBorderColorByType or MasqueControlsBorders(d) end
        local curseColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Curse"], db, "debuffBorderColorCurse", false, InvalidateAndUpdate, function() DF:LightweightUpdateDebuffBorderColors() end, true), 30)
        curseColor.disableOn = function(d) return not d.debuffBorderEnabled or not d.debuffBorderColorByType or MasqueControlsBorders(d) end
        local diseaseColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Disease"], db, "debuffBorderColorDisease", false, InvalidateAndUpdate, function() DF:LightweightUpdateDebuffBorderColors() end, true), 30)
        diseaseColor.disableOn = function(d) return not d.debuffBorderEnabled or not d.debuffBorderColorByType or MasqueControlsBorders(d) end
        local poisonColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Poison"], db, "debuffBorderColorPoison", false, InvalidateAndUpdate, function() DF:LightweightUpdateDebuffBorderColors() end, true), 30)
        poisonColor.disableOn = function(d) return not d.debuffBorderEnabled or not d.debuffBorderColorByType or MasqueControlsBorders(d) end
        local bleedColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Bleed / Enrage"], db, "debuffBorderColorBleed", false, InvalidateAndUpdate, function() DF:LightweightUpdateDebuffBorderColors() end, true), 30)
        bleedColor.disableOn = function(d) return not d.debuffBorderEnabled or not d.debuffBorderColorByType or MasqueControlsBorders(d) end
        local noneColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["None / Physical"], db, "debuffBorderColorNone", false, InvalidateAndUpdate, function() DF:LightweightUpdateDebuffBorderColors() end, true), 30)
        noneColor.disableOn = function(d) return not d.debuffBorderEnabled or not d.debuffBorderColorByType or MasqueControlsBorders(d) end
        colorsGroup.hideOn = function(d) return MasqueControlsBorders(d) end
        AddToSection(colorsGroup, nil, 2)
        
        -- Stack Count Group (col1)
        local stackCountGroup = GUI:CreateSettingsGroup(self.child, 260)
        stackCountGroup:AddWidget(GUI:CreateHeader(self.child, L["Stack Count"]), 40)
        stackCountGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "debuffStackFont", function() DF:LightweightUpdateAuraStackText("debuff") end), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "debuffStackScale", nil, function() DF:LightweightUpdateAuraStackText("debuff") end, true), 55)
        stackCountGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "debuffStackOutline", function() DF:LightweightUpdateAuraStackText("debuff") end), 55)
        stackCountGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "debuffStackAnchor", function() DF:LightweightUpdateAuraStackText("debuff") end), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "debuffStackX", nil, function() DF:LightweightUpdateAuraStackText("debuff") end, true), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "debuffStackY", nil, function() DF:LightweightUpdateAuraStackText("debuff") end, true), 55)
        stackCountGroup:AddWidget(GUI:CreateSlider(self.child, L["Min Stacks to Show"], 1, 10, 1, db, "debuffStackMinimum", nil), 55)
        AddToSection(stackCountGroup, nil, 1)
        
        -- Duration Text Group (col2)
        local durationGroup = GUI:CreateSettingsGroup(self.child, 260)
        durationGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration Text"]), 40)
        local durShow = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration"], db, "debuffShowDuration", function()
            self:RefreshStates()
            DF:UpdateAllFrames()
        end), 30)
        local durFont = durationGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "debuffDurationFont", nil), 55)
        durFont.disableOn = function(d) return not d.debuffShowDuration end
        local durScale = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "debuffDurationScale", nil, function() DF:LightweightUpdateAuraDurationText("debuff") end, true), 55)
        durScale.disableOn = function(d) return not d.debuffShowDuration end
        local durOutline = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "debuffDurationOutline", function() DF:LightweightUpdateAuraDurationText("debuff") end), 55)
        durOutline.disableOn = function(d) return not d.debuffShowDuration end
        local durAnchor = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "debuffDurationAnchor", function() DF:LightweightUpdateAuraDurationText("debuff") end), 55)
        durAnchor.disableOn = function(d) return not d.debuffShowDuration end
        local durX = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "debuffDurationX", nil, function() DF:LightweightUpdateAuraDurationText("debuff") end, true), 55)
        durX.disableOn = function(d) return not d.debuffShowDuration end
        local durY = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "debuffDurationY", nil, function() DF:LightweightUpdateAuraDurationText("debuff") end, true), 55)
        durY.disableOn = function(d) return not d.debuffShowDuration end
        local durColor = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Color by Time Remaining"], db, "debuffDurationColorByTime", function() DF:RefreshDurationColorSettings() end), 30)
        durColor.disableOn = function(d) return not d.debuffShowDuration end
        local durHideAbove = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Above Threshold"], db, "debuffDurationHideAboveEnabled", function() DF:RefreshDurationColorSettings() end), 30)
        durHideAbove.disableOn = function(d) return not d.debuffShowDuration end
        local durHideAboveSlider = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Hide Above (seconds)"], 1, 60, 1, db, "debuffDurationHideAboveThreshold", nil, function() DF:RefreshDurationColorSettings() end), 55)
        durHideAboveSlider.disableOn = function(d) return not d.debuffShowDuration or not d.debuffDurationHideAboveEnabled end
        AddToSection(durationGroup, nil, 2)

        currentSection = nil

        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "display_tooltips", label = L["Debuff Tooltips"]},
            {pageId = "general_integrations", label = L["Integrations"]},
            {pageId = "auras_dispel", label = L["Dispel Overlay"]},
            {pageId = "auras_bossdebuffs", label = L["Boss Debuffs"]},
        }), 30, "both")
    end)
    
    -- Auras > Boss Debuffs (Private Auras)
    local pageBossDebuffs = CreateSubTab("auras", "auras_bossdebuffs", L["Boss Debuffs"])
    BuildPage(pageBossDebuffs, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"bossDebuff"}, L["Boss Debuffs"], "auras_bossdebuffs"), 25, 2)

        -- ===== INFO BANNER =====
        do
            local bdBanner = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
            bdBanner:SetSize(560, 38)
            if not bdBanner.SetBackdrop then Mixin(bdBanner, BackdropTemplateMixin) end
            bdBanner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            bdBanner:SetBackdropColor(0.15, 0.18, 0.28, 1)
            local tc = GUI.GetThemeColor()
            bdBanner:SetBackdropBorderColor(tc.r, tc.g, tc.b, 0.5)

            local bdIcon = bdBanner:CreateTexture(nil, "OVERLAY")
            bdIcon:SetPoint("LEFT", 12, 0)
            bdIcon:SetSize(18, 18)
            bdIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\info")

            local bdText = bdBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            bdText:SetPoint("LEFT", bdIcon, "RIGHT", 8, 0)
            bdText:SetText(L["Boss Debuffs only trigger"])
            bdText:SetTextColor(0.85, 0.85, 0.85)

            local bdLink = CreateFrame("Button", nil, bdBanner)
            local bdLinkText = bdLink:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            bdLinkText:SetAllPoints()
            bdLinkText:SetText(L["Dispel Overlays"])
            bdLinkText:SetTextColor(tc.r, tc.g, tc.b)
            bdLink:SetSize(bdLinkText:GetStringWidth() + 2, 14)
            bdLink:SetPoint("LEFT", bdText, "RIGHT", 3, 0)
            bdLink:SetScript("OnEnter", function() bdLinkText:SetTextColor(1, 1, 1) end)
            bdLink:SetScript("OnLeave", function()
                local c = GUI.GetThemeColor()
                bdLinkText:SetTextColor(c.r, c.g, c.b)
            end)
            bdLink:SetScript("OnClick", function()
                if GUI.SelectTab then GUI.SelectTab("auras_dispel") end
            end)

            local bdSuffix = bdBanner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            bdSuffix:SetPoint("LEFT", bdLink, "RIGHT", 3, 0)
            bdSuffix:SetText(L["in Hybrid or Blizzard mode."])
            bdSuffix:SetTextColor(0.85, 0.85, 0.85)

            Add(bdBanner, 44, "both")
        end

        AddSpace(10, "both")
        
        local anchorOptions = {
            ["TOPLEFT"]= L["Top Left"], ["TOP"]= L["Top"], ["TOPRIGHT"]= L["Top Right"],
            ["LEFT"]= L["Left"], ["CENTER"]= L["Center"], ["RIGHT"]= L["Right"],
            ["BOTTOMLEFT"]= L["Bottom Left"], ["BOTTOM"]= L["Bottom"], ["BOTTOMRIGHT"]= L["Bottom Right"],
        }
        
        local function HideBossDebuffOptions(d)
            return not d.bossDebuffsEnabled
        end
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."], 250), 35)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Boss Debuffs"], db, "bossDebuffsEnabled", function()
            self:RefreshStates()
            if DF.UpdateAllPrivateAuraVisibility then DF:UpdateAllPrivateAuraVisibility() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 30)
        local maxCount = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Icons"], 1, 4, 1, db, "bossDebuffsMax", nil, function()
            if DF.RefreshAllPrivateAuraAnchors then DF:RefreshAllPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        maxCount.hideOn = HideBossDebuffOptions
        local showCountdown = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Cooldown Swipe"], db, "bossDebuffsShowCountdown", function()
            self:RefreshStates()
            if DF.RefreshAllPrivateAuraAnchors then DF:RefreshAllPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 30)
        showCountdown.hideOn = HideBossDebuffOptions
        local showNumbers = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration Numbers"], db, "bossDebuffsShowNumbers", function()
            self:RefreshStates()
            if DF.RefreshAllPrivateAuraAnchors then DF:RefreshAllPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 30)
        showNumbers.hideOn = function(d) return not d.bossDebuffsEnabled end
        local hideTooltip = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Tooltip on Mouseover"], db, "bossDebuffsHideTooltip", function()
            if DF.RefreshAllPrivateAuraAnchors then DF:RefreshAllPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 30)
        hideTooltip.hideOn = HideBossDebuffOptions
        local textScale = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Text Scale"], 0.5, 3.0, 0.05, db, "bossDebuffsTextScale", nil, function()
            if DF.RefreshAllPrivateAuraAnchors then DF:RefreshAllPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        textScale.hideOn = HideBossDebuffOptions
        Add(settingsGroup, nil, 1)

        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        local anchor = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "bossDebuffsAnchor", function()
            if DF.UpdateAllPrivateAuraPositions then DF:UpdateAllPrivateAuraPositions() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 55)
        anchor.hideOn = HideBossDebuffOptions
        local growthOptions4 = { RIGHT= L["Right"], LEFT= L["Left"], DOWN= L["Down"], UP= L["Up"] }
        local growth = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Growth Direction"], growthOptions4, db, "bossDebuffsGrowth", function()
            if DF.UpdateAllPrivateAuraPositions then DF:UpdateAllPrivateAuraPositions() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 55)
        growth.hideOn = HideBossDebuffOptions
        local offsetX = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "bossDebuffsOffsetX", nil, function()
            if DF.UpdateAllPrivateAuraPositions then DF:UpdateAllPrivateAuraPositions() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        offsetX.hideOn = HideBossDebuffOptions
        local offsetY = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "bossDebuffsOffsetY", nil, function()
            if DF.UpdateAllPrivateAuraPositions then DF:UpdateAllPrivateAuraPositions() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        offsetY.hideOn = HideBossDebuffOptions
        Add(positionGroup, nil, 2)
        
        -- ===== SIZE GROUP (Column 1) =====
        local sizeGroup = GUI:CreateSettingsGroup(self.child, 280)
        sizeGroup:AddWidget(GUI:CreateHeader(self.child, L["Size & Spacing"]), 40)
        local iconSize = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 10, 60, 1, db, "bossDebuffsIconSize", nil, function()
            if DF.PreviewPrivateAuraAnchors then DF:PreviewPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
            self:RefreshStates()
        end, true), 55)
        iconSize.hideOn = HideBossDebuffOptions

        -- Stack text warning note + "Show me" button container
        local stackNoteContainer = CreateFrame("Frame", nil, self.child)
        stackNoteContainer:SetSize(250, 55)
        local stackNoteLabel = stackNoteContainer:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        stackNoteLabel:SetPoint("TOPLEFT", stackNoteContainer, "TOPLEFT", 0, 0)
        stackNoteLabel:SetWidth(250)
        stackNoteLabel:SetJustifyH("LEFT")
        stackNoteLabel:SetText("|cFFFF4444Note:|r Icons smaller than 30 may hide stack text behind duration text. At small sizes, consider disabling duration numbers.")
        local showMeBtn = CreateFrame("Button", nil, stackNoteContainer, "BackdropTemplate")
        showMeBtn:SetSize(55, 18)
        showMeBtn:SetPoint("TOPLEFT", stackNoteLabel, "BOTTOMLEFT", 0, -4)
        if not showMeBtn.SetBackdrop then Mixin(showMeBtn, BackdropTemplateMixin) end
        showMeBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        showMeBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        showMeBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        local showMeText = showMeBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        showMeText:SetPoint("CENTER")
        showMeText:SetText("|cFFFFFF00Show me|r")
        showMeBtn:SetScript("OnClick", function()
            DF:HighlightSettings("auras_bossdebuffs", { "bossDebuffsShowNumbers" })
        end)
        showMeBtn:SetScript("OnEnter", function(s) s:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) end)
        showMeBtn:SetScript("OnLeave", function(s) s:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) end)
        local stackNote = sizeGroup:AddWidget(stackNoteContainer, 65)
        stackNote.hideOn = function(d)
            return not d.bossDebuffsEnabled or (d.bossDebuffsIconSize or 20) >= 30
        end
        local borderScale = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Scale"], 0, 2.0, 0.1, db, "bossDebuffsBorderScale", nil, function()
            if DF.PreviewPrivateAuraAnchors then DF:PreviewPrivateAuraAnchors() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        borderScale.hideOn = HideBossDebuffOptions
        local spacing = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing"], 0, 20, 1, db, "bossDebuffsSpacing", nil, function()
            if DF.UpdateAllPrivateAuraPositions then DF:UpdateAllPrivateAuraPositions() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        spacing.hideOn = HideBossDebuffOptions
        local frameLevel = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "bossDebuffsFrameLevel", nil, function()
            if DF.UpdateAllPrivateAuraFrameLevel then DF:UpdateAllPrivateAuraFrameLevel() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end, true), 55)
        frameLevel.hideOn = HideBossDebuffOptions

        local bossDebuffStrataOptions = {
            BACKGROUND = L["Background"],
            LOW = L["Low"],
            MEDIUM = L["Medium"],
            HIGH = L["High"],
            DIALOG = L["Dialog"],
            _order = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG" },
        }
        local bossDebuffStrata = sizeGroup:AddWidget(GUI:CreateDropdown(self.child, L["Frame Strata"], bossDebuffStrataOptions, db, "bossDebuffsStrata", function()
            if DF.UpdateAllPrivateAuraStrata then DF:UpdateAllPrivateAuraStrata() end
            if DF.UpdateAllTestBossDebuffs then DF:UpdateAllTestBossDebuffs() end
        end), 55)
        bossDebuffStrata.hideOn = HideBossDebuffOptions
        local bossDebuffStrataNote = sizeGroup:AddWidget(GUI:CreateLabel(self.child, "|cFF888888" .. L["Raise to HIGH if boss debuff icons render behind the frame on small icon sizes."] .. "|r", 260), 30)
        bossDebuffStrataNote.hideOn = HideBossDebuffOptions

        sizeGroup.hideOn = HideBossDebuffOptions
        Add(sizeGroup, nil, 1)

        -- Private Aura Dispel Overlay settings moved to the Dispel Overlay tab
        -- under the "Blizzard" source. The container's enable state and options
        -- are now driven by dispelOverlaySource and the unified dispel-type
        -- dropdown. This subsection is intentionally left empty.

        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_debuffs", label = L["Debuffs"]},
            {pageId = "auras_dispel", label = L["Dispel Overlay"]},
        }), 30, "both")
    end)
    
    -- Auras > Missing Buffs
    local pageMissingBuffs = CreateSubTab("auras", "auras_missingbuffs", L["Missing Buffs"])
    BuildPage(pageMissingBuffs, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"missingBuff"}, L["Missing Buffs"], "auras_missingbuffs"), 25, 2)
        
        AddSpace(10, "both")
        
        local function HideMissingBuffOptions(d)
            return not d.missingBuffIconEnabled
        end
        
        local function HideManualBuffOptions(d)
            return not d.missingBuffIconEnabled or d.missingBuffClassDetection
        end
        
        local anchorOptions = {
            ["TOPLEFT"]= L["Top Left"], ["TOP"]= L["Top"], ["TOPRIGHT"]= L["Top Right"],
            ["LEFT"]= L["Left"], ["CENTER"]= L["Center"], ["RIGHT"]= L["Right"],
            ["BOTTOMLEFT"]= L["Bottom Left"], ["BOTTOM"]= L["Bottom"], ["BOTTOMRIGHT"]= L["Bottom Right"],
        }
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["Shows icon when party members are missing raid buffs."], 250), 30)
        settingsGroup:AddWidget(GUI:CreateWarningBox(self.child, "|cffff6666NOTE:|r Does NOT work in Mythic+ keystones. In combat, results may be slightly delayed.", 250, 55), 60)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Missing Buff Icon"], db, "missingBuffIconEnabled", function()
            self:RefreshStates()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        local classDetect = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Auto-detect (your class's buff)"], db, "missingBuffClassDetection", function()
            self:RefreshStates()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        classDetect.hideOn = HideMissingBuffOptions
        local hideBar = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide raid buffs from buff bar"], db, "missingBuffHideFromBar", function()
            DF:UpdateAllAuras()
        end), 30)
        hideBar.hideOn = HideMissingBuffOptions
        local chkDebug = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Debug Mode (print to chat)"], db, "missingBuffIconDebug", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkDebug.hideOn = HideMissingBuffOptions
        Add(settingsGroup, nil, 1)
        
        -- ===== BUFFS TO CHECK GROUP (Column 2) =====
        local buffsGroup = GUI:CreateSettingsGroup(self.child, 280)
        buffsGroup:AddWidget(GUI:CreateHeader(self.child, L["Buffs to Check (Manual Mode)"]), 40)
        buffsGroup:AddWidget(GUI:CreateLabel(self.child, L["When auto-detect is OFF, select which raid buffs to monitor manually."], 250), 35)
        local chkInt = buffsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Arcane Intellect (Mage)"], db, "missingBuffCheckIntellect", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkInt.hideOn = HideManualBuffOptions
        local chkStam = buffsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Power Word: Fortitude (Priest)"], db, "missingBuffCheckStamina", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkStam.hideOn = HideManualBuffOptions
        local chkAP = buffsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Battle Shout (Warrior)"], db, "missingBuffCheckAttackPower", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkAP.hideOn = HideManualBuffOptions
        local chkVers = buffsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Mark of the Wild (Druid)"], db, "missingBuffCheckVersatility", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkVers.hideOn = HideManualBuffOptions
        local chkSky = buffsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Skyfury (Shaman)"], db, "missingBuffCheckSkyfury", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkSky.hideOn = HideManualBuffOptions
        local chkBronze = buffsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Blessing of the Bronze (Evoker)"], db, "missingBuffCheckBronze", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        chkBronze.hideOn = HideManualBuffOptions
        buffsGroup.hideOn = HideMissingBuffOptions
        Add(buffsGroup, nil, 2)
        
        -- ===== APPEARANCE GROUP (Column 1) =====
        local appearanceGroup = GUI:CreateSettingsGroup(self.child, 280)
        appearanceGroup:AddWidget(GUI:CreateHeader(self.child, L["Appearance"]), 40)
        local mbSize = appearanceGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 12, 48, 1, db, "missingBuffIconSize", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateMissingBuff() end, true), 55)
        mbSize.hideOn = HideMissingBuffOptions
        local mbScale = appearanceGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 3.0, 0.1, db, "missingBuffIconScale", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateMissingBuff() end, true), 55)
        mbScale.hideOn = HideMissingBuffOptions
        local mbLevel = appearanceGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "missingBuffIconFrameLevel", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateFrameLevel("missingBuff") end, true), 55)
        mbLevel.hideOn = HideMissingBuffOptions
        appearanceGroup.hideOn = HideMissingBuffOptions
        Add(appearanceGroup, nil, 1)
        
        -- ===== POSITION GROUP (Column 2) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        local mbAnchor = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "missingBuffIconAnchor", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 55)
        mbAnchor.hideOn = HideMissingBuffOptions
        local mbX = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -150, 150, 1, db, "missingBuffIconX", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateMissingBuff() end, true), 55)
        mbX.hideOn = HideMissingBuffOptions
        local mbY = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -150, 150, 1, db, "missingBuffIconY", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateMissingBuff() end, true), 55)
        mbY.hideOn = HideMissingBuffOptions
        positionGroup.hideOn = HideMissingBuffOptions
        Add(positionGroup, nil, 2)
        
        -- ===== BORDER GROUP (Column 1) =====
        local borderGroup = GUI:CreateSettingsGroup(self.child, 280)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        local mbShowBorder = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "missingBuffIconShowBorder", function()
            self:RefreshStates()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end), 30)
        mbShowBorder.hideOn = HideMissingBuffOptions
        local function HideMissingBuffBorderOptions(d)
            return not d.missingBuffIconEnabled or not d.missingBuffIconShowBorder
        end
        local mbBorder = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Size"], 1, 6, 1, db, "missingBuffIconBorderSize", function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateMissingBuff() end, true), 55)
        mbBorder.hideOn = HideMissingBuffBorderOptions
        local mbColor = borderGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "missingBuffIconBorderColor", true, function()
            if DF.UpdateAllMissingBuffIcons then DF:UpdateAllMissingBuffIcons() end
        end, function() DF:LightweightUpdateMissingBuffBorderColor() end, true), 35)
        mbColor.hideOn = HideMissingBuffBorderOptions
        borderGroup.hideOn = HideMissingBuffOptions
        Add(borderGroup, nil, 1)
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_buffs", label = L["Buffs"]},
        }), 30, "both")
    end)
    
    -- Auras > Defensive Icon
    local pageDefensiveIcon = CreateSubTab("auras", "auras_defensiveicon", L["Defensive Icon"])
    BuildPage(pageDefensiveIcon, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"defensiveIcon"}, L["Defensive Icon"], "auras_defensiveicon"), 25, 2)
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        
        local function HideDefensiveIconOptions(d)
            return not d.defensiveIconEnabled
        end
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."], 250), 45)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Defensive Icon"], db, "defensiveIconEnabled", function()
            self:RefreshStates()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 30)
        
        local hideSwipe = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Cooldown Swipe"], db, "defensiveIconHideSwipe", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 30)
        hideSwipe.hideOn = HideDefensiveIconOptions
        Add(settingsGroup, nil, 1)
        
        -- ===== APPEARANCE GROUP (Column 2) =====
        local appearanceGroup = GUI:CreateSettingsGroup(self.child, 280)
        appearanceGroup:AddWidget(GUI:CreateHeader(self.child, L["Appearance"]), 40)
        
        local diIconSize = appearanceGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 12, 48, 1, db, "defensiveIconSize", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diIconSize.hideOn = HideDefensiveIconOptions
        
        local diScale = appearanceGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 4.0, 0.1, db, "defensiveIconScale", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diScale.hideOn = HideDefensiveIconOptions
        
        local diLevel = appearanceGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "defensiveIconFrameLevel", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateFrameLevel("defensive") end, true), 55)
        diLevel.hideOn = HideDefensiveIconOptions
        
        local levelNote = appearanceGroup:AddWidget(GUI:CreateLabel(self.child, L["0=Auto, Higher=On top of more elements"], 230), 25)
        levelNote.hideOn = HideDefensiveIconOptions
        Add(appearanceGroup, nil, 2)
        
        -- ===== POSITION GROUP (Column 1) =====
        local positionGroup = GUI:CreateSettingsGroup(self.child, 280)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        
        local diAnchor = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "defensiveIconAnchor", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 55)
        diAnchor.hideOn = HideDefensiveIconOptions
        
        local diX = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -100, 100, 1, db, "defensiveIconX", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diX.hideOn = HideDefensiveIconOptions
        
        local diY = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -100, 100, 1, db, "defensiveIconY", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diY.hideOn = HideDefensiveIconOptions
        Add(positionGroup, nil, 1)
        
        -- ===== BORDER GROUP (Column 2) =====
        local borderGroup = GUI:CreateSettingsGroup(self.child, 280)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        
        local diShowBorder = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "defensiveIconShowBorder", function()
            self:RefreshStates()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 30)
        diShowBorder.hideOn = HideDefensiveIconOptions
        
        local function HideDefensiveBorderOptions(d)
            return not d.defensiveIconEnabled or not d.defensiveIconShowBorder
        end
        
        local diBorder = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Size"], 0, 8, 1, db, "defensiveIconBorderSize", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diBorder.hideOn = HideDefensiveBorderOptions
        
        local diColor = borderGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "defensiveIconBorderColor", true, function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIconColors() end, true), 35)
        diColor.hideOn = HideDefensiveBorderOptions
        Add(borderGroup, nil, 2)
        
        -- ===== DURATION GROUP (Column 1) =====
        local durationGroup = GUI:CreateSettingsGroup(self.child, 280)
        durationGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration Text"]), 40)
        
        local showDur = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration Text"], db, "defensiveIconShowDuration", function()
            self:RefreshStates()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 30)
        showDur.hideOn = HideDefensiveIconOptions
        
        local function HideDefensiveDurationOptions(d)
            return not d.defensiveIconEnabled or not d.defensiveIconShowDuration
        end
        
        local diDurFont = durationGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Duration Font"], db, "defensiveIconDurationFont", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 55)
        diDurFont.hideOn = HideDefensiveDurationOptions
        
        local diDurScale = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Duration Scale"], 0.5, 2.0, 0.05, db, "defensiveIconDurationScale", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diDurScale.hideOn = HideDefensiveDurationOptions
        
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }
        local diDurOutline = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Duration Outline"], outlineOptions, db, "defensiveIconDurationOutline", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 55)
        diDurOutline.hideOn = HideDefensiveDurationOptions
        
        durationGroup.hideOn = HideDefensiveIconOptions
        Add(durationGroup, nil, 1)
        
        -- ===== DURATION POSITION GROUP (Column 2) =====
        local durPosGroup = GUI:CreateSettingsGroup(self.child, 280)
        durPosGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration Position"]), 40)
        
        local diDurX = durPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Duration Offset X"], -20, 20, 1, db, "defensiveIconDurationX", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diDurX.hideOn = HideDefensiveDurationOptions
        
        local diDurY = durPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Duration Offset Y"], -20, 20, 1, db, "defensiveIconDurationY", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        diDurY.hideOn = HideDefensiveDurationOptions
        
        local diDurColor = durPosGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Duration Color"], db, "defensiveIconDurationColor", false, function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIconColors() end, true), 35)
        diDurColor.hideOn = HideDefensiveDurationOptions
        diDurColor.disableOn = function(d) return d.defensiveIconDurationColorByTime end
        
        local diDurColorByTime = durPosGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Color by Time Remaining"], db, "defensiveIconDurationColorByTime", function()
            self:RefreshStates()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 30)
        diDurColorByTime.hideOn = HideDefensiveDurationOptions
        
        durPosGroup.hideOn = HideDefensiveIconOptions
        Add(durPosGroup, nil, 2)

        -- ===== LAYOUT GROUP - DIRECT MODE (Column 1) =====
        local layoutGroup = GUI:CreateSettingsGroup(self.child, 280)
        layoutGroup:AddWidget(GUI:CreateHeader(self.child, L["Layout (Direct Mode)"]), 40)
        layoutGroup:AddWidget(GUI:CreateLabel(self.child, L["Controls how multiple defensive icons are arranged when using Direct aura mode."], 250), 45)

        local defGrowth = layoutGroup:AddWidget(GUI:CreateGrowthControl(self.child, db, "defensiveBarGrowth", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end), 155)
        defGrowth.hideOn = HideDefensiveIconOptions

        local defMax = layoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Icons"], 1, 5, 1, db, "defensiveBarMax", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, nil, true), 55)
        defMax.hideOn = HideDefensiveIconOptions

        local defWrap = layoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Icons Per Row"], 1, 5, 1, db, "defensiveBarWrap", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, nil, true), 55)
        defWrap.hideOn = HideDefensiveIconOptions

        local defSpacing = layoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Spacing"], -10, 10, 1, db, "defensiveBarSpacing", function()
            if DF.UpdateAllDefensiveBars then DF:UpdateAllDefensiveBars() end
        end, function() DF:LightweightUpdateDefensiveIcons() end, true), 55)
        defSpacing.hideOn = HideDefensiveIconOptions

        layoutGroup.hideOn = HideDefensiveIconOptions
        Add(layoutGroup, nil, 1)

        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_buffs", label = L["Buffs"]},
            {pageId = "auras_debuffs", label = L["Debuffs"]},
            {pageId = "auras_filters", label = L["Aura Filters"]},
            {pageId = "general_integrations", label = L["Integrations"]},
        }), 30, "both")
    end)
    
    -- ========================================
    -- CATEGORY: Indicators
    -- ========================================
    CreateCategory("indicators", L["Indicators"])
    
    -- Indicators > Targeted Spells (moved from Auras)
    local pageTargetedSpells = CreateSubTab("indicators", "indicators_targetedspells", L["Targeted Spells"])
    BuildPage(pageTargetedSpells, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"targetedSpell"}, L["Targeted Spells"], "indicators_targetedspells"), 25, 2)
        
        AddSpace(10, "both")
        
        local currentSection = nil
        
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then currentSection:RegisterChild(widget) end
            return widget
        end
        
        local anchorOptions = {
            CENTER= L["Center"], TOP= L["Top"], BOTTOM= L["Bottom"], LEFT= L["Left"], RIGHT= L["Right"],
            TOPLEFT= L["Top Left"], TOPRIGHT= L["Top Right"], BOTTOMLEFT= L["Bottom Left"], BOTTOMRIGHT= L["Bottom Right"],
        }
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }
        local growthOptions = { UP= L["Up"], DOWN= L["Down"], LEFT= L["Left"], RIGHT= L["Right"], CENTER_H= L["Center (Horizontal)"], CENTER_V= L["Center (Vertical)"] }
        
        local function HideTargetedSpellOptions(d) return not d.targetedSpellEnabled end
        local function HideTargetedDurationOptions(d) return not d.targetedSpellEnabled or not d.targetedSpellShowDuration end
        local function HideBorderOptions(d) return not d.targetedSpellEnabled or not d.targetedSpellShowBorder end
        
        local function TargetedSpellLightweightUpdate()
            if (DF.testMode or DF.raidTestMode) and DF.UpdateAllTestTargetedSpell then DF:UpdateAllTestTargetedSpell() end
        end
        
        local function FullUpdate()
            if DF.UpdateAllTargetedSpellLayouts then DF:UpdateAllTargetedSpellLayouts() end
            TargetedSpellLightweightUpdate()
        end
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["Shows an icon when an enemy is casting a spell targeting a party/raid member."], 250), 35)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Targeted Spells"], db, "targetedSpellEnabled", function()
            self:RefreshStates()
            if DF.ToggleTargetedSpells then DF:ToggleTargetedSpells(db.targetedSpellEnabled) end
        end), 30)
        local tsImportantOnly = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Important Spells Only"], db, "targetedSpellImportantOnly", function()
            self:RefreshStates()
            FullUpdate()
        end), 30)
        tsImportantOnly.disableOn = HideTargetedSpellOptions
        local tsNameplateOffscreen = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Offscreen Nameplates"], db, "targetedSpellNameplateOffscreen", function()
            if DF.SetNameplateOffscreen then DF:SetNameplateOffscreen(db.targetedSpellNameplateOffscreen) end
            FullUpdate()
        end), 30)
        tsNameplateOffscreen.disableOn = HideTargetedSpellOptions
        Add(settingsGroup, nil, 1)
        
        -- ===== CONTENT TYPES GROUP (Column 2) =====
        local contentGroup = GUI:CreateSettingsGroup(self.child, 280)
        contentGroup:AddWidget(GUI:CreateHeader(self.child, L["Content Types"]), 40)
        contentGroup:AddWidget(GUI:CreateLabel(self.child, L["Show in content types:"], 250), 25)
        local tsOpenWorld = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Open World"], db, "targetedSpellInOpenWorld", nil), 25)
        tsOpenWorld.disableOn = HideTargetedSpellOptions
        local tsDungeons = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Dungeons"], db, "targetedSpellInDungeons", nil), 25)
        tsDungeons.disableOn = HideTargetedSpellOptions
        tsDungeons.hideOn = function() return GUI.SelectedMode == "raid" end
        local tsArena = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Arena"], db, "targetedSpellInArena", nil), 25)
        tsArena.disableOn = HideTargetedSpellOptions
        tsArena.hideOn = function() return GUI.SelectedMode == "raid" end
        local tsRaids = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Raids"], db, "targetedSpellInRaids", nil), 25)
        tsRaids.disableOn = HideTargetedSpellOptions
        tsRaids.hideOn = function() return GUI.SelectedMode ~= "raid" end
        local tsBattlegrounds = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Battlegrounds"], db, "targetedSpellInBattlegrounds", nil), 25)
        tsBattlegrounds.disableOn = HideTargetedSpellOptions
        tsBattlegrounds.hideOn = function() return GUI.SelectedMode ~= "raid" end
        contentGroup.hideOn = HideTargetedSpellOptions
        Add(contentGroup, nil, 2)
        
        -- Cast History button
        local historyBtn = GUI:CreateButton(self.child, L["Open Cast History"], 140, 24, function()
            if DF.ShowCastHistoryUI then DF:ShowCastHistoryUI() end
        end)
        Add(historyBtn, 30, 1)
        
        AddSpace(10, "both")
        
        -- ===== LAYOUT SECTION =====
        local layoutSection = Add(GUI:CreateCollapsibleSection(self.child, L["Layout"], true), 36, "both")
        currentSection = layoutSection
        
        -- Position Group (col1)
        local positionGroup = GUI:CreateSettingsGroup(self.child, 260)
        positionGroup:AddWidget(GUI:CreateHeader(self.child, L["Position"]), 40)
        local tsAnchor = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "targetedSpellAnchor", FullUpdate), 55)
        tsAnchor.disableOn = HideTargetedSpellOptions
        local tsX = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -100, 100, 1, db, "targetedSpellX", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsX.disableOn = HideTargetedSpellOptions
        local tsY = positionGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -100, 100, 1, db, "targetedSpellY", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsY.disableOn = HideTargetedSpellOptions
        local tsGrowth = positionGroup:AddWidget(GUI:CreateDropdown(self.child, L["Growth Direction"], growthOptions, db, "targetedSpellGrowth", FullUpdate), 55)
        tsGrowth.disableOn = HideTargetedSpellOptions
        AddToSection(positionGroup, nil, 1)
        
        -- Size Group (col2)
        local sizeGroup = GUI:CreateSettingsGroup(self.child, 260)
        sizeGroup:AddWidget(GUI:CreateHeader(self.child, L["Size"]), 40)
        local tsIconSize = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 12, 48, 1, db, "targetedSpellSize", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsIconSize.disableOn = HideTargetedSpellOptions
        local tsScale = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 4.0, 0.1, db, "targetedSpellScale", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsScale.disableOn = HideTargetedSpellOptions
        local tsSpacing = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing"], 0, 10, 1, db, "targetedSpellSpacing", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsSpacing.disableOn = HideTargetedSpellOptions
        local tsMaxIcons = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Icons"], 1, 10, 1, db, "targetedSpellMaxIcons", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsMaxIcons.disableOn = HideTargetedSpellOptions
        local tsLevel = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "targetedSpellFrameLevel", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsLevel.disableOn = HideTargetedSpellOptions
        AddToSection(sizeGroup, nil, 2)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== APPEARANCE SECTION =====
        local appearanceSection = Add(GUI:CreateCollapsibleSection(self.child, L["Appearance"], true), 36, "both")
        currentSection = appearanceSection
        
        -- Border Group (col1)
        local borderGroup = GUI:CreateSettingsGroup(self.child, 260)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        local tsAlpha = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.0, 1.0, 0.05, db, "targetedSpellAlpha", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsAlpha.disableOn = HideTargetedSpellOptions
        local hideSwipe = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Cooldown Swipe"], db, "targetedSpellHideSwipe", FullUpdate), 30)
        hideSwipe.disableOn = HideTargetedSpellOptions
        local tsShowBorder = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "targetedSpellShowBorder", function()
            self:RefreshStates()
            FullUpdate()
        end), 30)
        tsShowBorder.disableOn = HideTargetedSpellOptions
        local tsBorderSize = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Size"], 0, 8, 1, db, "targetedSpellBorderSize", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsBorderSize.disableOn = HideBorderOptions
        local tsColor = borderGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "targetedSpellBorderColor", false, FullUpdate), 35)
        tsColor.disableOn = HideBorderOptions
        AddToSection(borderGroup, nil, 1)
        
        -- Duration Group (col2)
        local durationGroup = GUI:CreateSettingsGroup(self.child, 260)
        durationGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration Text"]), 40)
        local showDur = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration Text"], db, "targetedSpellShowDuration", function()
            self:RefreshStates()
            FullUpdate()
        end), 30)
        showDur.disableOn = HideTargetedSpellOptions
        local tsDurFont = durationGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "targetedSpellDurationFont", FullUpdate), 55)
        tsDurFont.disableOn = HideTargetedDurationOptions
        local tsDurScale = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "targetedSpellDurationScale", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsDurScale.disableOn = HideTargetedDurationOptions
        local tsDurOutline = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "targetedSpellDurationOutline", FullUpdate), 55)
        tsDurOutline.disableOn = HideTargetedDurationOptions
        local tsDurX = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -20, 20, 1, db, "targetedSpellDurationX", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsDurX.disableOn = HideTargetedDurationOptions
        local tsDurY = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -20, 20, 1, db, "targetedSpellDurationY", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsDurY.disableOn = HideTargetedDurationOptions
        local tsDurColor = durationGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "targetedSpellDurationColor", false, FullUpdate), 35)
        tsDurColor.disableOn = HideTargetedDurationOptions
        AddToSection(durationGroup, nil, 2)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== IMPORTANT SPELLS SECTION =====
        local importantSection = Add(GUI:CreateCollapsibleSection(self.child, L["Important Spells"], true), 36, "both")
        currentSection = importantSection
        
        local function HideHighlightOptions(d) return not d.targetedSpellEnabled or not d.targetedSpellHighlightImportant end
        local highlightStyleOptions = { glow = L["Glow"], marchingAnts = L["Marching Ants"], solidBorder = L["Solid Border"], pulse = L["Pulse"], none = L["None"] }
        
        local highlightGroup = GUI:CreateSettingsGroup(self.child, 260)
        highlightGroup:AddWidget(GUI:CreateHeader(self.child, L["Highlight Settings"]), 40)
        local tsHighlightImportant = highlightGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Highlight Important Spells"], db, "targetedSpellHighlightImportant", function()
            self:RefreshStates()
            FullUpdate()
        end), 30)
        tsHighlightImportant.disableOn = HideTargetedSpellOptions
        local tsHighlightStyle = highlightGroup:AddWidget(GUI:CreateDropdown(self.child, L["Highlight Style"], highlightStyleOptions, db, "targetedSpellHighlightStyle", FullUpdate), 55)
        tsHighlightStyle.disableOn = HideHighlightOptions
        local tsHighlightColor = highlightGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Highlight Color"], db, "targetedSpellHighlightColor", false, FullUpdate), 35)
        tsHighlightColor.disableOn = HideHighlightOptions
        local tsHighlightSize = highlightGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Thickness"], 1, 8, 1, db, "targetedSpellHighlightSize", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsHighlightSize.disableOn = HideHighlightOptions
        local tsHighlightInset = highlightGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Inset"], -4, 8, 1, db, "targetedSpellHighlightInset", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsHighlightInset.disableOn = HideHighlightOptions
        AddToSection(highlightGroup, nil, 1)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== INTERRUPTED VISUAL SECTION =====
        local interruptedSection = Add(GUI:CreateCollapsibleSection(self.child, L["Interrupted Visual"], true), 36, "both")
        currentSection = interruptedSection
        
        local function HideInterruptedOptions(d) return not d.targetedSpellEnabled or not d.targetedSpellShowInterrupted end
        local function HideXOptions(d) return not d.targetedSpellEnabled or not d.targetedSpellShowInterrupted or not d.targetedSpellInterruptedShowX end
        
        local interruptGroup = GUI:CreateSettingsGroup(self.child, 260)
        interruptGroup:AddWidget(GUI:CreateHeader(self.child, L["Interrupt Settings"]), 40)
        local tsShowInterrupted = interruptGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Interrupted Visual"], db, "targetedSpellShowInterrupted", function()
            self:RefreshStates()
            FullUpdate()
        end), 30)
        tsShowInterrupted.disableOn = HideTargetedSpellOptions
        local tsInterruptedDuration = interruptGroup:AddWidget(GUI:CreateSlider(self.child, L["Duration"], 0.1, 2.0, 0.1, db, "targetedSpellInterruptedDuration", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsInterruptedDuration.disableOn = HideInterruptedOptions
        local tsInterruptedTintColor = interruptGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Tint Color"], db, "targetedSpellInterruptedTintColor", false, FullUpdate), 35)
        tsInterruptedTintColor.disableOn = HideInterruptedOptions
        local tsInterruptedTintAlpha = interruptGroup:AddWidget(GUI:CreateSlider(self.child, L["Tint Opacity"], 0, 1, 0.1, db, "targetedSpellInterruptedTintAlpha", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsInterruptedTintAlpha.disableOn = HideInterruptedOptions
        AddToSection(interruptGroup, nil, 1)
        
        local xMarkGroup = GUI:CreateSettingsGroup(self.child, 260)
        xMarkGroup:AddWidget(GUI:CreateHeader(self.child, L["X Mark"]), 40)
        local tsInterruptedShowX = xMarkGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show X Mark"], db, "targetedSpellInterruptedShowX", function()
            self:RefreshStates()
            FullUpdate()
        end), 30)
        tsInterruptedShowX.disableOn = HideInterruptedOptions
        local tsInterruptedXColor = xMarkGroup:AddWidget(GUI:CreateColorPicker(self.child, L["X Color"], db, "targetedSpellInterruptedXColor", false, FullUpdate), 35)
        tsInterruptedXColor.disableOn = HideXOptions
        local tsInterruptedXSize = xMarkGroup:AddWidget(GUI:CreateSlider(self.child, L["X Size"], 8, 32, 1, db, "targetedSpellInterruptedXSize", FullUpdate, TargetedSpellLightweightUpdate, true), 55)
        tsInterruptedXSize.disableOn = HideXOptions
        xMarkGroup.hideOn = HideInterruptedOptions
        AddToSection(xMarkGroup, nil, 2)
        
        currentSection = nil
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_buffs", label = L["Buffs"]},
            {pageId = "auras_debuffs", label = L["Debuffs"]},
            {pageId = "general_integrations", label = L["Integrations"]},
            {pageId = "indicators_personal_targeted", label = L["Personal Targeted Spells"]},
        }), 30, "both")

        -- ============================================================
        -- API COMPATIBILITY OVERLAY (Group-frame Targeted Spells)
        --
        -- Group-frame Targeted Spells relies on UnitIsUnit comparing a
        -- nameplateXtarget against a party/raid token. Blizzard's
        -- 2026-04-07 hotfix made that combination return nil, with no
        -- in-addon workaround (the new PlayerIsSpellTarget API only
        -- answers for the player). DF.GroupTargetedSpellsAPIBlocked is
        -- set permanently at addon load in Features/TargetedSpells.lua,
        -- so this overlay is always visible on this page.
        --
        -- The overlay is parented to the page (not self.child) so it
        -- survives Refresh() rebuilds and floats above the scroll
        -- content.
        -- ============================================================
        if not self.apiBlockedOverlay then
            -- Parent to the page (ScrollFrame). The GUI window is in DIALOG
            -- strata; widgets inside it inherit DIALOG. We bump the overlay
            -- to FULLSCREEN_DIALOG and crank the frame level so it draws
            -- above everything in the page including the scroll child.
            local overlay = CreateFrame("Frame", nil, self, "BackdropTemplate")
            overlay:SetFrameStrata("FULLSCREEN_DIALOG")
            overlay:SetFrameLevel(500)
            overlay:SetAllPoints(self)
            overlay:EnableMouse(true) -- block clicks to underlying controls
            overlay:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
            overlay:SetBackdropColor(0, 0, 0, 0.85)

            local title = overlay:CreateFontString(nil, "OVERLAY", "DFFontNormalHuge")
            title:SetPoint("CENTER", 0, 80)
            title:SetText(L["Disabled — WoW API Change"])
            title:SetTextColor(1, 0.82, 0)

            local body = overlay:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
            body:SetPoint("TOP", title, "BOTTOM", 0, -20)
            body:SetWidth(520)
            body:SetJustifyH("CENTER")
            body:SetText(L["A WoW API change prevents addons from detecting which party or raid member an enemy is targeting. Group-frame Targeted Spells can no longer function and has been disabled.\n\nThe Personal Targeted Spells display still works and will warn you about casts targeting you."])

            local gotoBtn = GUI:CreateButton(overlay, L["Open Personal Targeted Spells"], 260, 30, function()
                if GUI.SelectTab then GUI.SelectTab("indicators_personal_targeted") end
            end)
            gotoBtn:SetParent(overlay)
            gotoBtn:SetFrameStrata("FULLSCREEN_DIALOG")
            gotoBtn:SetFrameLevel(501)
            gotoBtn:SetPoint("TOP", body, "BOTTOM", 0, -25)

            self.apiBlockedOverlay = overlay
            overlay:Hide()
        end

        if DF.GroupTargetedSpellsAPIBlocked then
            self.apiBlockedOverlay:Show()
        else
            self.apiBlockedOverlay:Hide()
        end
    end)

    -- Stub kept for ABI compatibility — the overlay is now always visible
    -- so this is a no-op, but other code paths still call it.
    GUI.RefreshTargetedSpellsOverlay = function()
        local page = GUI.Pages and GUI.Pages["indicators_targetedspells"]
        if page and page.apiBlockedOverlay then
            if DF.GroupTargetedSpellsAPIBlocked then
                page.apiBlockedOverlay:Show()
            else
                page.apiBlockedOverlay:Hide()
            end
        end
    end

    -- ============================================================
    -- Indicators > Targeted List
    -- ============================================================
    -- Stacked cast-bar display showing enemy casts targeting party
    -- members. Replaces the group-frame Targeted Spells icons that
    -- Blizzard's 2026-04-07 UnitIsUnit hotfix permanently broke.
    -- Party-only feature; raid mode shows a redirect message.
    local pageTargetedList = CreateSubTab("indicators", "indicators_targetedlist", L["Targeted List"])
    BuildPage(pageTargetedList, function(self, db, Add, AddSpace, AddSyncPoint)
            -- Party-only feature: show message and return if in raid mode
            if GUI.SelectedMode == "raid" then
                Add(GUI:CreateHeader(self.child, L["Targeted List"]), 40, "both")
                Add(GUI:CreateLabel(self.child,
                    L["Targeted List is a Party-only feature. Switch to Party mode to configure."],
                    500, {r = 0.6, g = 0.6, b = 0.6}), 60, "both")
                return
            end

            -- Copy button at top
            Add(CreateCopyButton(self.child, {"targetedList"}, L["Targeted List"], "indicators_targetedlist"), 25, 2)

            AddSpace(6, "both")

            local currentSection = nil

            local function AddToSection(widget, height, col)
                Add(widget, height, col)
                if currentSection then currentSection:RegisterChild(widget) end
                return widget
            end

            local growthOptions = { UP = L["Up"], DOWN = L["Down"] }
            local outlineOptions = { NONE = L["None"], OUTLINE = L["Outline"], THICKOUTLINE = L["Thick Outline"], SHADOW = L["Shadow"] }
            local iconPosOptions = { LEFT = L["Left"], RIGHT = L["Right"] }
            local stylePresetOptions = {
                DEFAULT = L["Default"],
                COMPACT = L["Compact"],
                DETAILED = L["Detailed"],
                MINIMAL = L["Minimal"],
            }


            local function HideTLOptions(d) return not d.targetedListEnabled end
            local function HideIconOptions(d) return not d.targetedListEnabled or not d.targetedListShowIcon end
            local function HideBorderOptions(d) return not d.targetedListEnabled or not d.targetedListShowBorder end
            local function HideTargetNameOptions(d) return not d.targetedListEnabled or not d.targetedListShowTargetName end

            local function TargetedListUpdate()
                if DF.UpdateTargetedListLayout then DF:UpdateTargetedListLayout() end
            end

            -- ===== SETTINGS GROUP (Column 1) =====
            local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
            settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
            settingsGroup:AddWidget(GUI:CreateLabel(self.child,
                L["Shows an icon when an enemy is casting a spell targeting a party/raid member."], 250), 35)
            settingsGroup:AddWidget(GUI:CreateLabel(self.child,
                "|cff888888" .. L["To reposition: Unlock frames (/df unlock) and drag the mover."] .. "|r", 250), 30)
            settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable"], db, "targetedListEnabled", function()
                self:RefreshStates()
                if DF.ToggleTargetedList then DF:ToggleTargetedList(db.targetedListEnabled) end
            end), 30)
            local tlImportantOnly = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Important Spells Only"], db, "targetedListImportantOnly", TargetedListUpdate), 30)
            tlImportantOnly.disableOn = HideTLOptions
            local tlHideOwn = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Casts Targeting You"], db, "targetedListHideOwnCasts", TargetedListUpdate), 30)
            tlHideOwn.disableOn = HideTLOptions
            local tlShowUntargeted = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Untargeted Casts"], db, "targetedListShowUntargeted", TargetedListUpdate), 30)
            tlShowUntargeted.disableOn = HideTLOptions
            local tlHideOOC = settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Hide Out-of-Combat Casts"], db, "targetedListHideOutOfCombat", TargetedListUpdate), 30)
            tlHideOOC.disableOn = HideTLOptions
            tlHideOOC.tooltip = L["Only show casts from enemies that are in combat. Filters out idle mobs casting nearby."]
            local tlMaxBars = settingsGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Bars"], 1, 20, 1, db, "targetedListMaxBars", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlMaxBars.disableOn = HideTLOptions
            Add(settingsGroup, nil, 1)

            AddSpace(10, "both")

            -- ===== LAYOUT SECTION =====
            local layoutSection = Add(GUI:CreateCollapsibleSection(self.child, L["Layout"], true), 36, "both")
            currentSection = layoutSection

            local layoutGroup = GUI:CreateSettingsGroup(self.child, 260)
            layoutGroup:AddWidget(GUI:CreateHeader(self.child, L["Size & Spacing"]), 40)
            local tlW = layoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Bar Width"], 120, 600, 1, db, "targetedListWidth", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlW.disableOn = HideTLOptions
            local tlH = layoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Bar Height"], 14, 48, 1, db, "targetedListHeight", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlH.disableOn = HideTLOptions
            local tlSpace = layoutGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing"], 0, 10, 1, db, "targetedListSpacing", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlSpace.disableOn = HideTLOptions
            local tlGrowth = layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Growth Direction"], growthOptions, db, "targetedListGrowth", TargetedListUpdate), 55)
            tlGrowth.disableOn = HideTLOptions
            local sortOptions = { NEWEST = L["Newest First"], OLDEST = L["Oldest First"], STATIC = L["Static (No Reorder)"] }
            local tlSort = layoutGroup:AddWidget(GUI:CreateDropdown(self.child, L["Sort Order"], sortOptions, db, "targetedListSortOrder", TargetedListUpdate), 55)
            tlSort.disableOn = HideTLOptions
            AddToSection(layoutGroup, nil, 1)

            local presetGroup = GUI:CreateSettingsGroup(self.child, 260)
            presetGroup:AddWidget(GUI:CreateHeader(self.child, L["Bar Style"]), 40)
            -- Picking a preset writes a bundle of settings to db
            -- (bar dimensions, show/hide toggles, font size, etc.)
            -- via DF:ApplyTargetedListPreset. After the bundle is
            -- applied the individual settings remain editable —
            -- the preset is a one-shot "start from this configuration"
            -- action, not a continuous override.
            local tlPreset = presetGroup:AddWidget(GUI:CreateDropdown(self.child, L["Bar Style"], stylePresetOptions, db, "targetedListStylePreset", function()
                if DF.ApplyTargetedListPreset then
                    DF:ApplyTargetedListPreset(db.targetedListStylePreset)
                end
                -- Also refresh GUI widgets so users see the preset's
                -- values reflected in the other sliders/checkboxes.
                if GUI and GUI.RefreshCurrentPage then
                    GUI:RefreshCurrentPage()
                end
                TargetedListUpdate()
            end), 55)
            tlPreset.disableOn = HideTLOptions
            local tlTexture = presetGroup:AddWidget(GUI:CreateTextureDropdown(self.child, L["Texture"], db, "targetedListTexture", TargetedListUpdate), 55)
            tlTexture.disableOn = HideTLOptions
            local tlBgAlpha = presetGroup:AddWidget(GUI:CreateSlider(self.child, L["Background Alpha"], 0, 1, 0.05, db, "targetedListBackgroundAlpha", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlBgAlpha.disableOn = HideTLOptions
            local tlShowBorder = presetGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "targetedListShowBorder", function()
                self:RefreshStates()
                TargetedListUpdate()
            end), 30)
            tlShowBorder.disableOn = HideTLOptions
            local tlBorderColor = presetGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "targetedListBorderColor", true, TargetedListUpdate, function() if DF.LightweightUpdateTargetedListBorderColor then DF:LightweightUpdateTargetedListBorderColor() end end, true), 35)
            tlBorderColor.disableOn = HideBorderOptions
            AddToSection(presetGroup, nil, 2)

            currentSection = nil
            AddSpace(10, "both")

            -- ===== APPEARANCE SECTION =====
            local appearanceSection = Add(GUI:CreateCollapsibleSection(self.child, L["Appearance"], true), 36, "both")
            currentSection = appearanceSection

            local colorGroup = GUI:CreateSettingsGroup(self.child, 260)
            colorGroup:AddWidget(GUI:CreateHeader(self.child, L["Bar Color"]), 40)
            local tlInterColor = colorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Interruptible Color"], db, "targetedListInterruptibleColor", true, TargetedListUpdate, function() if DF.LightweightUpdateTargetedListBarColor then DF:LightweightUpdateTargetedListBarColor() end end, true), 35)
            tlInterColor.disableOn = HideTLOptions
            local tlUninterColor = colorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Uninterruptible Color"], db, "targetedListUninterruptibleColor", true, TargetedListUpdate, function() if DF.LightweightUpdateTargetedListBarColor then DF:LightweightUpdateTargetedListBarColor() end end, true), 35)
            tlUninterColor.disableOn = HideTLOptions
            local tlSelfTargetEnabled = colorGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Self-Target Color"], db, "targetedListSelfTargetColorEnabled", function()
                self:RefreshStates()
                TargetedListUpdate()
            end), 30)
            tlSelfTargetEnabled.disableOn = HideTLOptions
            tlSelfTargetEnabled.tooltip = L["Highlight the bar when the enemy is casting at you."]
            local function HideSelfTargetOptions(d) return not d.targetedListEnabled or not d.targetedListSelfTargetColorEnabled end
            local tlSelfTargetColor = colorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Self-Target Color"], db, "targetedListSelfTargetColor", true, TargetedListUpdate, nil, true), 35)
            tlSelfTargetColor.disableOn = HideSelfTargetOptions
            local tlHighlight = colorGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Highlight Important Spells"], db, "targetedListHighlightImportant", function()
                self:RefreshStates()
                TargetedListUpdate()
            end), 30)
            tlHighlight.disableOn = HideTLOptions
            local function HideHighlightOptions(d) return not d.targetedListEnabled or not d.targetedListHighlightImportant end
            local tlHighlightColor = colorGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Highlight Color"], db, "targetedListHighlightColor", false, TargetedListUpdate, function() if DF.LightweightUpdateTargetedListHighlightColor then DF:LightweightUpdateTargetedListHighlightColor() end end, true), 35)
            tlHighlightColor.disableOn = HideHighlightOptions
            local tlResetColors = colorGroup:AddWidget(GUI:CreateButton(self.child, L["Reset Colors to Default"], 200, 24, function()
                db.targetedListInterruptibleColor = {r = 1, g = 0.494, b = 0.137, a = 1}
                db.targetedListUninterruptibleColor = {r = 0.8, g = 0.302, b = 0.302, a = 1}
                db.targetedListSelfTargetColor = {r = 0.02, g = 0.776, b = 0.4, a = 0.2}
                db.targetedListHighlightColor = {r = 1, g = 0.8, b = 0}
                db.targetedListBorderColor = {r = 0.18, g = 0.18, b = 0.18, a = 1}
                -- Refresh color swatches
                if tlInterColor.UpdateSwatch then tlInterColor:UpdateSwatch() end
                if tlUninterColor.UpdateSwatch then tlUninterColor:UpdateSwatch() end
                if tlSelfTargetColor.UpdateSwatch then tlSelfTargetColor:UpdateSwatch() end
                if tlHighlightColor.UpdateSwatch then tlHighlightColor:UpdateSwatch() end
                TargetedListUpdate()
                self:RefreshStates()
            end), 30)
            tlResetColors.disableOn = HideTLOptions
            AddToSection(colorGroup, nil, 1)

            local iconGroup = GUI:CreateSettingsGroup(self.child, 260)
            iconGroup:AddWidget(GUI:CreateHeader(self.child, L["Icon"]), 40)
            local tlShowIcon = iconGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Icon"], db, "targetedListShowIcon", function()
                self:RefreshStates()
                TargetedListUpdate()
            end), 30)
            tlShowIcon.disableOn = HideTLOptions
            local tlIconPos = iconGroup:AddWidget(GUI:CreateDropdown(self.child, L["Icon Position"], iconPosOptions, db, "targetedListIconPosition", TargetedListUpdate), 55)
            tlIconPos.disableOn = HideIconOptions
            local tlZoom = iconGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Zoom Icon"], db, "targetedListZoomIcon", TargetedListUpdate), 30)
            tlZoom.disableOn = HideIconOptions
            AddToSection(iconGroup, nil, 2)

            currentSection = nil
            AddSpace(10, "both")

            -- ===== TEXT SECTION =====
            local textSection = Add(GUI:CreateCollapsibleSection(self.child, L["Text"], true), 36, "both")
            currentSection = textSection

            local textToggleGroup = GUI:CreateSettingsGroup(self.child, 260)
            textToggleGroup:AddWidget(GUI:CreateHeader(self.child, L["Show"]), 40)
            local tlShowSpellName = textToggleGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Spell Name"], db, "targetedListShowSpellName", TargetedListUpdate), 30)
            tlShowSpellName.disableOn = HideTLOptions
            local tlShowTargetName = textToggleGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Target Name"], db, "targetedListShowTargetName", function()
                self:RefreshStates()
                TargetedListUpdate()
            end), 30)
            tlShowTargetName.disableOn = HideTLOptions
            local tlShowDuration = textToggleGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration"], db, "targetedListShowDuration", TargetedListUpdate), 30)
            tlShowDuration.disableOn = HideTLOptions
            local tlClassColor = textToggleGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Target Name Class Color"], db, "targetedListTargetNameClassColor", TargetedListUpdate), 30)
            tlClassColor.disableOn = HideTargetNameOptions
            local tlArrow = textToggleGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Arrow Prefix"], db, "targetedListShowArrowPrefix", TargetedListUpdate), 30)
            tlArrow.disableOn = HideTargetNameOptions
            local tlArrowSuffix = textToggleGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Arrow Suffix"], db, "targetedListShowArrowSuffix", TargetedListUpdate), 30)
            tlArrowSuffix.disableOn = HideTargetNameOptions
            AddToSection(textToggleGroup, nil, 1)

            local fontGroup = GUI:CreateSettingsGroup(self.child, 260)
            fontGroup:AddWidget(GUI:CreateHeader(self.child, L["Font"]), 40)
            local tlFont = fontGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "targetedListFont", TargetedListUpdate), 55)
            tlFont.disableOn = HideTLOptions
            local tlFontSize = fontGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 8, 24, 1, db, "targetedListFontSize", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlFontSize.disableOn = HideTLOptions
            local tlFontOutline = fontGroup:AddWidget(GUI:CreateDropdown(self.child, L["Font Outline"], outlineOptions, db, "targetedListFontOutline", TargetedListUpdate), 55)
            tlFontOutline.disableOn = HideTLOptions
            AddToSection(fontGroup, nil, 2)

            currentSection = nil
            AddSpace(10, "both")

            -- ===== TEXT POSITION SECTION =====
            -- Per-element anchor + X/Y offset. Each text element
            -- (spell name, target name, duration) can be independently
            -- anchored to LEFT / CENTER / RIGHT within the bar's
            -- progress region with a pixel offset applied on top.
            local textPosSection = Add(GUI:CreateCollapsibleSection(self.child, L["Text Position"], true), 36, "both")
            currentSection = textPosSection

            local textAnchorOptions = { LEFT = L["Left"], CENTER = L["Center"], RIGHT = L["Right"] }
            local textAlignOptions = { LEFT = L["Left"], CENTER = L["Center"], RIGHT = L["Right"] }

            local spellNamePosGroup = GUI:CreateSettingsGroup(self.child, 260)
            spellNamePosGroup:AddWidget(GUI:CreateHeader(self.child, L["Spell Name"]), 40)
            local tlSNFontSize = spellNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "targetedListSpellNameFontSize", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlSNFontSize.disableOn = HideTLOptions
            local tlSNWidth = spellNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Text Width"], 0, 400, 1, db, "targetedListSpellNameWidth", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlSNWidth.disableOn = HideTLOptions
            local tlSNAnchor = spellNamePosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], textAnchorOptions, db, "targetedListSpellNameAnchor", TargetedListUpdate), 55)
            tlSNAnchor.disableOn = HideTLOptions
            local tlSNAlign = spellNamePosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Alignment"], textAlignOptions, db, "targetedListSpellNameAlign", TargetedListUpdate), 55)
            tlSNAlign.disableOn = HideTLOptions
            local tlSNX = spellNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -500, 500, 1, db, "targetedListSpellNameX", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlSNX.disableOn = HideTLOptions
            local tlSNY = spellNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -500, 500, 1, db, "targetedListSpellNameY", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlSNY.disableOn = HideTLOptions
            AddToSection(spellNamePosGroup, nil, 1)

            local targetNamePosGroup = GUI:CreateSettingsGroup(self.child, 260)
            targetNamePosGroup:AddWidget(GUI:CreateHeader(self.child, L["Target Name"]), 40)
            local tlTNFontSize = targetNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "targetedListTargetNameFontSize", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlTNFontSize.disableOn = HideTargetNameOptions
            local tlTNWidth = targetNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Text Width"], 0, 400, 1, db, "targetedListTargetNameWidth", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlTNWidth.disableOn = HideTargetNameOptions
            local tlTNAnchor = targetNamePosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], textAnchorOptions, db, "targetedListTargetNameAnchor", TargetedListUpdate), 55)
            tlTNAnchor.disableOn = HideTargetNameOptions
            local tlTNAlign = targetNamePosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Alignment"], textAlignOptions, db, "targetedListTargetNameAlign", TargetedListUpdate), 55)
            tlTNAlign.disableOn = HideTargetNameOptions
            local tlTNX = targetNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -500, 500, 1, db, "targetedListTargetNameX", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlTNX.disableOn = HideTargetNameOptions
            local tlTNY = targetNamePosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -500, 500, 1, db, "targetedListTargetNameY", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlTNY.disableOn = HideTargetNameOptions
            AddToSection(targetNamePosGroup, nil, 2)

            local function HideDurationPosOptions(d) return not d.targetedListEnabled or not d.targetedListShowDuration end
            local durationPosGroup = GUI:CreateSettingsGroup(self.child, 260)
            durationPosGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration"]), 40)
            local tlDurFontSize = durationPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "targetedListDurationFontSize", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlDurFontSize.disableOn = HideDurationPosOptions
            local tlDurAnchor = durationPosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], textAnchorOptions, db, "targetedListDurationAnchor", TargetedListUpdate), 55)
            tlDurAnchor.disableOn = HideDurationPosOptions
            local tlDurAlign = durationPosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Alignment"], textAlignOptions, db, "targetedListDurationAlign", TargetedListUpdate), 55)
            tlDurAlign.disableOn = HideDurationPosOptions
            local tlDurX = durationPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -500, 500, 1, db, "targetedListDurationX", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlDurX.disableOn = HideDurationPosOptions
            local tlDurY = durationPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -500, 500, 1, db, "targetedListDurationY", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlDurY.disableOn = HideDurationPosOptions
            AddToSection(durationPosGroup, nil, 1)

            local interruptPosGroup = GUI:CreateSettingsGroup(self.child, 260)
            interruptPosGroup:AddWidget(GUI:CreateHeader(self.child, L["Interrupt Text"]), 40)
            local tlIntFontSize = interruptPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Font Size"], 6, 24, 1, db, "targetedListInterruptTextFontSize", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlIntFontSize.disableOn = HideTLOptions
            local tlIntWidth = interruptPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Text Width"], 0, 400, 1, db, "targetedListInterruptTextWidth", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlIntWidth.disableOn = HideTLOptions
            local tlIntAnchor = interruptPosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Anchor"], textAnchorOptions, db, "targetedListInterruptTextAnchor", TargetedListUpdate), 55)
            tlIntAnchor.disableOn = HideTLOptions
            local tlIntAlign = interruptPosGroup:AddWidget(GUI:CreateDropdown(self.child, L["Alignment"], textAlignOptions, db, "targetedListInterruptTextAlign", TargetedListUpdate), 55)
            tlIntAlign.disableOn = HideTLOptions
            local tlIntX = interruptPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -500, 500, 1, db, "targetedListInterruptTextX", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlIntX.disableOn = HideTLOptions
            local tlIntY = interruptPosGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -500, 500, 1, db, "targetedListInterruptTextY", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlIntY.disableOn = HideTLOptions
            AddToSection(interruptPosGroup, nil, 2)

            currentSection = nil
            AddSpace(10, "both")

            -- ===== BEHAVIOR SECTION =====
            local behaviorSection = Add(GUI:CreateCollapsibleSection(self.child, L["Behavior"], true), 36, "both")
            currentSection = behaviorSection

            local timingGroup = GUI:CreateSettingsGroup(self.child, 260)
            timingGroup:AddWidget(GUI:CreateHeader(self.child, L["Timing"]), 40)
            local tlFadeOut = timingGroup:AddWidget(GUI:CreateSlider(self.child, L["Fade Out Duration"], 0, 1, 0.05, db, "targetedListFadeOutDuration", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlFadeOut.disableOn = HideTLOptions
            local tlFlashDur = timingGroup:AddWidget(GUI:CreateSlider(self.child, L["Interrupted Flash Duration"], 0, 2, 0.1, db, "targetedListInterruptedFlashDuration", TargetedListUpdate, TargetedListUpdate, true), 55)
            tlFlashDur.disableOn = HideTLOptions
            AddToSection(timingGroup, nil, 1)

            currentSection = nil

            -- See Also links
            AddSpace(20, "both")
            Add(GUI:CreateSeeAlso(self.child, {
                {pageId = "indicators_targetedspells", label = L["Targeted Spells"]},
                {pageId = "indicators_personal_targeted", label = L["Personal Targeted"]},
            }), 30, "both")
        end)

    -- Indicators > Personal Targeted Spells (center of screen display for player)
    local pagePersonalTargeted = CreateSubTab("indicators", "indicators_personal_targeted", L["Personal Targeted"])
    BuildPage(pagePersonalTargeted, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"personalTargeted"}, L["Personal Targeted"], "indicators_personal_targeted"), 25, 2)
        
        AddSpace(10, "both")
        
        local currentSection = nil
        
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then currentSection:RegisterChild(widget) end
            return widget
        end
        
        local growthOptions = { UP= L["Up"], DOWN= L["Down"], LEFT= L["Left"], RIGHT= L["Right"], CENTER_H= L["Center (Horizontal)"], CENTER_V= L["Center (Vertical)"] }
        local outlineOptions = { NONE= L["None"], OUTLINE= L["Outline"], THICKOUTLINE= L["Thick Outline"], SHADOW= L["Shadow"] }
        
        local function HidePersonalOptions(d) return not d.personalTargetedSpellEnabled end
        local function HidePersonalDurationOptions(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellShowDuration end
        local function HideBorderOptions(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellShowBorder end
        
        local function PersonalTargetedUpdate()
            if DF.UpdatePersonalTargetedSpellsPosition then DF:UpdatePersonalTargetedSpellsPosition() end
            if DF.UpdateTestPersonalTargetedSpells then DF:UpdateTestPersonalTargetedSpells() end
        end
        
        -- ===== SETTINGS GROUP (Column 1) =====
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["Shows incoming targeted spells on YOU in the center of your screen."], 250), 30)
        settingsGroup:AddWidget(GUI:CreateLabel(self.child, L["To reposition: Unlock frames (/df unlock) and drag the mover."], 250), 30)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Personal Targeted Spells"], db, "personalTargetedSpellEnabled", function()
            self:RefreshStates()
            if DF.TogglePersonalTargetedSpells then DF:TogglePersonalTargetedSpells(db.personalTargetedSpellEnabled) end
        end), 30)
        settingsGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Important Spells Only"], db, "personalTargetedSpellImportantOnly", PersonalTargetedUpdate), 30)
        Add(settingsGroup, nil, 1)
        
        -- ===== CONTENT TYPES GROUP (Column 2) =====
        local contentGroup = GUI:CreateSettingsGroup(self.child, 280)
        contentGroup:AddWidget(GUI:CreateHeader(self.child, L["Content Types"]), 40)
        contentGroup:AddWidget(GUI:CreateLabel(self.child, L["Show in content types:"], 250), 25)
        local ptsOpenWorld = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Open World"], db, "personalTargetedSpellInOpenWorld", nil), 25)
        ptsOpenWorld.disableOn = HidePersonalOptions
        ptsOpenWorld.hideOn = function() return GUI.SelectedMode == "raid" end
        local ptsDungeons = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Dungeons"], db, "personalTargetedSpellInDungeons", nil), 25)
        ptsDungeons.disableOn = HidePersonalOptions
        ptsDungeons.hideOn = function() return GUI.SelectedMode == "raid" end
        local ptsRaids = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Raids"], db, "personalTargetedSpellInRaids", nil), 25)
        ptsRaids.disableOn = HidePersonalOptions
        ptsRaids.hideOn = function() return GUI.SelectedMode == "raid" end
        local ptsArena = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Arena"], db, "personalTargetedSpellInArena", nil), 25)
        ptsArena.disableOn = HidePersonalOptions
        ptsArena.hideOn = function() return GUI.SelectedMode == "raid" end
        local ptsBattlegrounds = contentGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Battlegrounds"], db, "personalTargetedSpellInBattlegrounds", nil), 25)
        ptsBattlegrounds.disableOn = HidePersonalOptions
        ptsBattlegrounds.hideOn = function() return GUI.SelectedMode == "raid" end
        contentGroup:AddWidget(GUI:CreateLabel(self.child, L["Content type filters configured in Party tab."], 250), 25)
        contentGroup.hideOn = HidePersonalOptions
        Add(contentGroup, nil, 2)
        
        AddSpace(10, "both")
        
        -- ===== LAYOUT SECTION =====
        local layoutSection = Add(GUI:CreateCollapsibleSection(self.child, L["Layout"], true), 36, "both")
        currentSection = layoutSection
        
        -- Size Group (col1)
        local sizeGroup = GUI:CreateSettingsGroup(self.child, 260)
        sizeGroup:AddWidget(GUI:CreateHeader(self.child, L["Size"]), 40)
        local ptsSize = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 20, 80, 1, db, "personalTargetedSpellSize", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsSize.disableOn = HidePersonalOptions
        local ptsScale = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.05, db, "personalTargetedSpellScale", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsScale.disableOn = HidePersonalOptions
        local ptsSpacing = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Spacing"], 0, 20, 1, db, "personalTargetedSpellSpacing", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsSpacing.disableOn = HidePersonalOptions
        local ptsMaxIcons = sizeGroup:AddWidget(GUI:CreateSlider(self.child, L["Max Icons"], 1, 10, 1, db, "personalTargetedSpellMaxIcons", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsMaxIcons.disableOn = HidePersonalOptions
        AddToSection(sizeGroup, nil, 1)
        
        -- Growth Group (col2)
        local growthGroup = GUI:CreateSettingsGroup(self.child, 260)
        growthGroup:AddWidget(GUI:CreateHeader(self.child, L["Growth"]), 40)
        local ptsGrowth = growthGroup:AddWidget(GUI:CreateDropdown(self.child, L["Growth Direction"], growthOptions, db, "personalTargetedSpellGrowth", PersonalTargetedUpdate), 55)
        ptsGrowth.disableOn = HidePersonalOptions
        AddToSection(growthGroup, nil, 2)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== APPEARANCE SECTION =====
        local appearanceSection = Add(GUI:CreateCollapsibleSection(self.child, L["Appearance"], true), 36, "both")
        currentSection = appearanceSection
        
        -- Border Group (col1)
        local borderGroup = GUI:CreateSettingsGroup(self.child, 260)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        local ptsAlpha = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.0, 1.0, 0.05, db, "personalTargetedSpellAlpha", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsAlpha.disableOn = HidePersonalOptions
        local ptsSwipe = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Cooldown Swipe"], db, "personalTargetedSpellShowSwipe", PersonalTargetedUpdate), 30)
        ptsSwipe.disableOn = HidePersonalOptions
        local ptsBorder = borderGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "personalTargetedSpellShowBorder", function()
            self:RefreshStates()
            PersonalTargetedUpdate()
        end), 30)
        ptsBorder.disableOn = HidePersonalOptions
        local ptsBorderSize = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Size"], 1, 5, 1, db, "personalTargetedSpellBorderSize", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsBorderSize.disableOn = HideBorderOptions
        local ptsBorderColor = borderGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Border Color"], db, "personalTargetedSpellBorderColor", false, PersonalTargetedUpdate), 35)
        ptsBorderColor.disableOn = HideBorderOptions
        AddToSection(borderGroup, nil, 1)
        
        -- Duration Group (col2)
        local durationGroup = GUI:CreateSettingsGroup(self.child, 260)
        durationGroup:AddWidget(GUI:CreateHeader(self.child, L["Duration Text"]), 40)
        local ptsDuration = durationGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Duration Text"], db, "personalTargetedSpellShowDuration", function()
            self:RefreshStates()
            PersonalTargetedUpdate()
        end), 30)
        ptsDuration.disableOn = HidePersonalOptions
        local ptsDurFont = durationGroup:AddWidget(GUI:CreateFontDropdown(self.child, L["Font"], db, "personalTargetedSpellDurationFont", PersonalTargetedUpdate), 55)
        ptsDurFont.disableOn = HidePersonalDurationOptions
        local ptsDurScale = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.0, 0.1, db, "personalTargetedSpellDurationScale", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsDurScale.disableOn = HidePersonalDurationOptions
        local ptsDurOutline = durationGroup:AddWidget(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "personalTargetedSpellDurationOutline", PersonalTargetedUpdate), 55)
        ptsDurOutline.disableOn = HidePersonalDurationOptions
        local ptsDurX = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset X"], -20, 20, 1, db, "personalTargetedSpellDurationX", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsDurX.disableOn = HidePersonalDurationOptions
        local ptsDurY = durationGroup:AddWidget(GUI:CreateSlider(self.child, L["Offset Y"], -20, 20, 1, db, "personalTargetedSpellDurationY", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsDurY.disableOn = HidePersonalDurationOptions
        local ptsDurColor = durationGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "personalTargetedSpellDurationColor", false, PersonalTargetedUpdate), 35)
        ptsDurColor.disableOn = HidePersonalDurationOptions
        AddToSection(durationGroup, nil, 2)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== IMPORTANT SPELLS SECTION =====
        local highlightSection = Add(GUI:CreateCollapsibleSection(self.child, L["Important Spells"], true), 36, "both")
        currentSection = highlightSection
        
        local personalHighlightStyleOptions = { glow = L["Glow"], marchingAnts = L["Marching Ants"], solidBorder = L["Solid Border"], pulse = L["Pulse"], none = L["None"] }
        
        local highlightGroup = GUI:CreateSettingsGroup(self.child, 260)
        highlightGroup:AddWidget(GUI:CreateHeader(self.child, L["Highlight Settings"]), 40)
        local ptsHighlight = highlightGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Highlight Important Spells"], db, "personalTargetedSpellHighlightImportant", PersonalTargetedUpdate), 30)
        ptsHighlight.disableOn = HidePersonalOptions
        local ptsHighlightStyle = highlightGroup:AddWidget(GUI:CreateDropdown(self.child, L["Highlight Style"], personalHighlightStyleOptions, db, "personalTargetedSpellHighlightStyle", PersonalTargetedUpdate), 55)
        ptsHighlightStyle.disableOn = function(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellHighlightImportant end
        local ptsHighlightColor = highlightGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Highlight Color"], db, "personalTargetedSpellHighlightColor", false, PersonalTargetedUpdate), 35)
        ptsHighlightColor.disableOn = function(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellHighlightImportant end
        local ptsHighlightSize = highlightGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Thickness"], 1, 6, 1, db, "personalTargetedSpellHighlightSize", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsHighlightSize.disableOn = function(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellHighlightImportant end
        local ptsHighlightInset = highlightGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Inset"], -4, 8, 1, db, "personalTargetedSpellHighlightInset", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsHighlightInset.disableOn = function(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellHighlightImportant end
        AddToSection(highlightGroup, nil, 1)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ===== INTERRUPTED VISUAL SECTION =====
        local interruptSection = Add(GUI:CreateCollapsibleSection(self.child, L["Interrupted Visual"], true), 36, "both")
        currentSection = interruptSection
        
        local function HideInterruptOptions(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellShowInterrupted end
        local function HideInterruptXOptions(d) return not d.personalTargetedSpellEnabled or not d.personalTargetedSpellShowInterrupted or not d.personalTargetedSpellInterruptedShowX end
        
        local interruptGroup = GUI:CreateSettingsGroup(self.child, 260)
        interruptGroup:AddWidget(GUI:CreateHeader(self.child, L["Interrupt Settings"]), 40)
        local ptsInterrupted = interruptGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Interrupted Visual"], db, "personalTargetedSpellShowInterrupted", function()
            self:RefreshStates()
            PersonalTargetedUpdate()
        end), 30)
        ptsInterrupted.disableOn = HidePersonalOptions
        local ptsInterruptDur = interruptGroup:AddWidget(GUI:CreateSlider(self.child, L["Duration"], 0.1, 2.0, 0.1, db, "personalTargetedSpellInterruptedDuration", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsInterruptDur.disableOn = HideInterruptOptions
        local ptsInterruptTint = interruptGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Tint Color"], db, "personalTargetedSpellInterruptedTintColor", false, PersonalTargetedUpdate), 35)
        ptsInterruptTint.disableOn = HideInterruptOptions
        local ptsInterruptTintAlpha = interruptGroup:AddWidget(GUI:CreateSlider(self.child, L["Tint Opacity"], 0, 1, 0.1, db, "personalTargetedSpellInterruptedTintAlpha", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsInterruptTintAlpha.disableOn = HideInterruptOptions
        AddToSection(interruptGroup, nil, 1)
        
        local xMarkGroup = GUI:CreateSettingsGroup(self.child, 260)
        xMarkGroup:AddWidget(GUI:CreateHeader(self.child, L["X Mark"]), 40)
        local ptsShowX = xMarkGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show X Mark"], db, "personalTargetedSpellInterruptedShowX", function()
            self:RefreshStates()
            PersonalTargetedUpdate()
        end), 30)
        ptsShowX.disableOn = HideInterruptOptions
        local ptsXColor = xMarkGroup:AddWidget(GUI:CreateColorPicker(self.child, L["X Color"], db, "personalTargetedSpellInterruptedXColor", false, PersonalTargetedUpdate), 35)
        ptsXColor.disableOn = HideInterruptXOptions
        local ptsXSize = xMarkGroup:AddWidget(GUI:CreateSlider(self.child, L["X Size"], 8, 40, 1, db, "personalTargetedSpellInterruptedXSize", PersonalTargetedUpdate, PersonalTargetedUpdate, true), 55)
        ptsXSize.disableOn = HideInterruptXOptions
        xMarkGroup.hideOn = HideInterruptOptions
        AddToSection(xMarkGroup, nil, 2)
        
        currentSection = nil
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "indicators_targetedspells", label = L["Targeted Spells (on frames)"]},
        }), 30, "both")
    end)
    
    -- Indicators > Icons (All icons with collapsible sections)
    local pageIcons = CreateSubTab("indicators", "indicators_icons", L["Icons"])
    BuildPage(pageIcons, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"roleIcon", "leaderIcon", "raidTargetIcon", "readyCheckIcon", "summonIcon", "resurrectionIcon", "phasedIcon", "afkIcon", "vehicleIcon", "raidRoleIcon", "statusIconFont", "statusIconFontSize", "statusIconFontOutline"}, L["Icons"], "indicators_icons"), 25, 2)
        
        local anchorOptions = {
            CENTER = L["Center"],
            TOP = L["Top"],
            BOTTOM = L["Bottom"],
            LEFT = L["Left"],
            RIGHT = L["Right"],
            TOPLEFT = L["Top Left"],
            TOPRIGHT = L["Top Right"],
            BOTTOMLEFT = L["Bottom Left"],
            BOTTOMRIGHT = L["Bottom Right"],
        }
        
        local roleStyleOptions = {
            BLIZZARD = L["Blizzard"],
            CUSTOM = "DF Icons",
            EXTERNAL = L["External"],
        }
        
        local outlineOptions = {
            [""]= L["None"],
            ["OUTLINE"] = L["Outline"],
            ["THICKOUTLINE"] = L["Thick Outline"],
            ["SHADOW"] = L["Shadow"],
        }
        
        -- ============================================
        -- STATUS ICON TEXT SETTINGS (Collapsible, at top)
        -- ============================================
        local textSection = Add(GUI:CreateCollapsibleSection(self.child, L["Status Icon Text Settings"], false, 250), 28, 1)
        
        local textLabel = Add(GUI:CreateLabel(self.child, L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"], 240), 30, 1)
        textSection:RegisterChild(textLabel)
        
        local textFont = Add(GUI:CreateFontDropdown(self.child, L["Font"], db, "statusIconFont", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 55, 1)
        textSection:RegisterChild(textFont)
        
        local textSize = Add(GUI:CreateSlider(self.child, L["Font Size"], 8, 24, 1, db, "statusIconFontSize", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 55, 1)
        textSection:RegisterChild(textSize)
        
        local textOutline = Add(GUI:CreateDropdown(self.child, L["Outline"], outlineOptions, db, "statusIconFontOutline", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 55, 1)
        textSection:RegisterChild(textOutline)
        
        local shadowNote = Add(GUI:CreateLabel(self.child, L["Shadow settings are controlled in General > Global Fonts."], 240), 30, 1)
        textSection:RegisterChild(shadowNote)
        shadowNote.hideOn = function(d) return d.statusIconFontOutline ~= "SHADOW" end
        
        -- Text Colors header
        local colorsLabel = Add(GUI:CreateLabel(self.child, L["Text Colors:"], 240), 25, 1)
        textSection:RegisterChild(colorsLabel)
        
        local summonColor = Add(GUI:CreateColorPicker(self.child, L["Summon"], db, "summonIconTextColor", false, nil, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 30, 1)
        textSection:RegisterChild(summonColor)
        
        local resColor = Add(GUI:CreateColorPicker(self.child, L["Resurrection"], db, "resurrectionIconTextColor", false, nil, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 30, 1)
        textSection:RegisterChild(resColor)
        
        local afkColor = Add(GUI:CreateColorPicker(self.child, L["AFK"], db, "afkIconTextColor", false, nil, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 30, 1)
        textSection:RegisterChild(afkColor)
        
        local phasedColor = Add(GUI:CreateColorPicker(self.child, L["Phased"], db, "phasedIconTextColor", false, nil, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 30, 1)
        textSection:RegisterChild(phasedColor)
        
        local vehicleColor = Add(GUI:CreateColorPicker(self.child, L["Vehicle"], db, "vehicleIconTextColor", false, nil, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 30, 1)
        textSection:RegisterChild(vehicleColor)
        
        local raidRoleColor = Add(GUI:CreateColorPicker(self.child, L["Raid Role (MT/MA)"], db, "raidRoleIconTextColor", false, nil, function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end, true), 30, 1)
        textSection:RegisterChild(raidRoleColor)
        
        -- ============================================
        -- ROLE ICON (Collapsible)
        -- ============================================
        local roleSection = Add(GUI:CreateCollapsibleSection(self.child, L["Role Icon"], false, 250), 28, 1)

        local roleStyle = Add(GUI:CreateDropdown(self.child, L["Icon Style"], roleStyleOptions, db, "roleIconStyle", function() DF:UpdateAllRoleIcons() end), 55, 1)
        roleSection:RegisterChild(roleStyle)

        local roleExtTank = Add(GUI:CreateEditBox(self.child, "Tank Icon Path", db, "roleIconExternalTank", function() DF:UpdateAllRoleIcons() end), 55, 1)
        roleSection:RegisterChild(roleExtTank)
        roleExtTank.hideOn = function(d) return d.roleIconStyle ~= "EXTERNAL" end

        local roleExtHealer = Add(GUI:CreateEditBox(self.child, "Healer Icon Path", db, "roleIconExternalHealer", function() DF:UpdateAllRoleIcons() end), 55, 1)
        roleSection:RegisterChild(roleExtHealer)
        roleExtHealer.hideOn = function(d) return d.roleIconStyle ~= "EXTERNAL" end

        local roleExtDPS = Add(GUI:CreateEditBox(self.child, "DPS Icon Path", db, "roleIconExternalDPS", function() DF:UpdateAllRoleIcons() end), 55, 1)
        roleSection:RegisterChild(roleExtDPS)
        roleExtDPS.hideOn = function(d) return d.roleIconStyle ~= "EXTERNAL" end

        local roleExtNote = Add(GUI:CreateLabel(self.child, L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."], 250), 40, 1)
        roleSection:RegisterChild(roleExtNote)
        roleExtNote.hideOn = function(d) return d.roleIconStyle ~= "EXTERNAL" end

        local roleOnlyInCombat = Add(GUI:CreateCheckbox(self.child, L["Show All Roles Out of Combat"], db, "roleIconOnlyInCombat", function() DF:UpdateAllRoleIcons() end), 30, 1)
        roleSection:RegisterChild(roleOnlyInCombat)

        local roleOnlyInCombatDesc = Add(GUI:CreateLabel(self.child, L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."], 250), 40, 1)
        roleSection:RegisterChild(roleOnlyInCombatDesc)

        local roleShowTank = Add(GUI:CreateCheckbox(self.child, L["Show Tank"], db, "roleIconShowTank", nil), 30, 1)
        roleSection:RegisterChild(roleShowTank)
        
        local roleShowHealer = Add(GUI:CreateCheckbox(self.child, L["Show Healer"], db, "roleIconShowHealer", nil), 30, 1)
        roleSection:RegisterChild(roleShowHealer)
        
        local roleShowDPS = Add(GUI:CreateCheckbox(self.child, L["Show DPS"], db, "roleIconShowDPS", nil), 30, 1)
        roleSection:RegisterChild(roleShowDPS)
        
        local roleScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "roleIconScale", nil, function() DF:LightweightUpdateIconPosition("role") end, true), 55, 1)
        roleSection:RegisterChild(roleScale)
        
        local roleAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "roleIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("role") end, true), 55, 1)
        roleSection:RegisterChild(roleAlpha)
        
        local roleAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "roleIconAnchor", function() DF:LightweightUpdateIconPosition("role") end), 55, 1)
        roleSection:RegisterChild(roleAnchor)
        
        local roleX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "roleIconX", nil, function() DF:LightweightUpdateIconPosition("role") end, true), 55, 1)
        roleSection:RegisterChild(roleX)
        
        local roleY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "roleIconY", nil, function() DF:LightweightUpdateIconPosition("role") end, true), 55, 1)
        roleSection:RegisterChild(roleY)
        
        local roleLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "roleIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("role") end, true), 55, 1)
        roleSection:RegisterChild(roleLevel)
        
        -- ============================================
        -- LEADER ICON (Collapsible)
        -- ============================================
        local leaderSection = Add(GUI:CreateCollapsibleSection(self.child, L["Leader Icon"], false, 250), 28, 1)
        
        local leaderEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Leader Icon"], db, "leaderIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        leaderSection:RegisterChild(leaderEnabled)
        
        local leaderScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "leaderIconScale", nil, function() DF:LightweightUpdateIconPosition("leader") end, true), 55, 1)
        leaderSection:RegisterChild(leaderScale)
        
        local leaderAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "leaderIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("leader") end, true), 55, 1)
        leaderSection:RegisterChild(leaderAlpha)
        
        local leaderHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "leaderIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        leaderSection:RegisterChild(leaderHide)
        
        local leaderAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "leaderIconAnchor", function() DF:LightweightUpdateIconPosition("leader") end), 55, 1)
        leaderSection:RegisterChild(leaderAnchor)
        
        local leaderX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "leaderIconX", nil, function() DF:LightweightUpdateIconPosition("leader") end, true), 55, 1)
        leaderSection:RegisterChild(leaderX)
        
        local leaderY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "leaderIconY", nil, function() DF:LightweightUpdateIconPosition("leader") end, true), 55, 1)
        leaderSection:RegisterChild(leaderY)
        
        local leaderLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "leaderIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("leader") end, true), 55, 1)
        leaderSection:RegisterChild(leaderLevel)
        
        -- ============================================
        -- RAID TARGET ICON (Collapsible)
        -- ============================================
        local raidTargetSection = Add(GUI:CreateCollapsibleSection(self.child, L["Raid Target Icon"], false, 250), 28, 1)
        
        local rtEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Raid Target Icon"], db, "raidTargetIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        raidTargetSection:RegisterChild(rtEnabled)
        
        local rtScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "raidTargetIconScale", nil, function() DF:LightweightUpdateIconPosition("raidTarget") end, true), 55, 1)
        raidTargetSection:RegisterChild(rtScale)
        
        local rtAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "raidTargetIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("raidTarget") end, true), 55, 1)
        raidTargetSection:RegisterChild(rtAlpha)
        
        local rtHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "raidTargetIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        raidTargetSection:RegisterChild(rtHide)
        
        local rtAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "raidTargetIconAnchor", function() DF:LightweightUpdateIconPosition("raidTarget") end), 55, 1)
        raidTargetSection:RegisterChild(rtAnchor)
        
        local rtX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "raidTargetIconX", nil, function() DF:LightweightUpdateIconPosition("raidTarget") end, true), 55, 1)
        raidTargetSection:RegisterChild(rtX)
        
        local rtY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "raidTargetIconY", nil, function() DF:LightweightUpdateIconPosition("raidTarget") end, true), 55, 1)
        raidTargetSection:RegisterChild(rtY)
        
        local rtLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "raidTargetIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("raidTarget") end, true), 55, 1)
        raidTargetSection:RegisterChild(rtLevel)
        
        -- ============================================
        -- READY CHECK ICON (Collapsible)
        -- ============================================
        local readySection = Add(GUI:CreateCollapsibleSection(self.child, L["Ready Check Icon"], false, 250), 28, 1)
        
        local rcEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Ready Check Icon"], db, "readyCheckIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        readySection:RegisterChild(rcEnabled)
        
        local rcScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "readyCheckIconScale", nil, function() DF:LightweightUpdateIconPosition("readyCheck") end, true), 55, 1)
        readySection:RegisterChild(rcScale)
        
        local rcAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "readyCheckIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("readyCheck") end, true), 55, 1)
        readySection:RegisterChild(rcAlpha)
        
        local rcHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "readyCheckIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        readySection:RegisterChild(rcHide)
        
        local rcAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "readyCheckIconAnchor", function() DF:LightweightUpdateIconPosition("readyCheck") end), 55, 1)
        readySection:RegisterChild(rcAnchor)
        
        local rcX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "readyCheckIconX", nil, function() DF:LightweightUpdateIconPosition("readyCheck") end, true), 55, 1)
        readySection:RegisterChild(rcX)
        
        local rcY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "readyCheckIconY", nil, function() DF:LightweightUpdateIconPosition("readyCheck") end, true), 55, 1)
        readySection:RegisterChild(rcY)
        
        local rcPersist = Add(GUI:CreateSlider(self.child, L["Persist (sec)"], 0, 15, 1, db, "readyCheckIconPersist"), 55, 1)
        readySection:RegisterChild(rcPersist)
        
        local rcLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "readyCheckIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("readyCheck") end, true), 55, 1)
        readySection:RegisterChild(rcLevel)
        
        -- ============================================
        -- SUMMON ICON (Collapsible)
        -- ============================================
        local summonSection = Add(GUI:CreateCollapsibleSection(self.child, L["Summon Icon"], false, 250), 28, 1)
        
        local sumEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Summon Icon"], db, "summonIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        summonSection:RegisterChild(sumEnabled)
        
        local sumShowText = Add(GUI:CreateCheckbox(self.child, L["Show as Text"], db, "summonIconShowText", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 30, 1)
        summonSection:RegisterChild(sumShowText)
        
        local sumTextPending = Add(GUI:CreateEditBox(self.child, "Pending Text", db, "summonIconTextPending", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        summonSection:RegisterChild(sumTextPending)
        
        local sumTextAccepted = Add(GUI:CreateEditBox(self.child, "Accepted Text", db, "summonIconTextAccepted", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        summonSection:RegisterChild(sumTextAccepted)
        
        local sumTextDeclined = Add(GUI:CreateEditBox(self.child, "Declined Text", db, "summonIconTextDeclined", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        summonSection:RegisterChild(sumTextDeclined)
        
        local sumScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "summonIconScale", nil, function() DF:LightweightUpdateIconPosition("summon") end, true), 55, 1)
        summonSection:RegisterChild(sumScale)
        
        local sumAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "summonIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("summon") end, true), 55, 1)
        summonSection:RegisterChild(sumAlpha)
        
        local sumHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "summonIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        summonSection:RegisterChild(sumHide)
        
        local sumAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "summonIconAnchor", function() DF:LightweightUpdateIconPosition("summon") end), 55, 1)
        summonSection:RegisterChild(sumAnchor)
        
        local sumX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "summonIconX", nil, function() DF:LightweightUpdateIconPosition("summon") end, true), 55, 1)
        summonSection:RegisterChild(sumX)
        
        local sumY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "summonIconY", nil, function() DF:LightweightUpdateIconPosition("summon") end, true), 55, 1)
        summonSection:RegisterChild(sumY)
        
        local sumLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "summonIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("summon") end, true), 55, 1)
        summonSection:RegisterChild(sumLevel)
        
        -- ============================================
        -- RESURRECTION ICON (Collapsible)
        -- ============================================
        local resSection = Add(GUI:CreateCollapsibleSection(self.child, L["Resurrection Icon"], false, 250), 28, 1)
        
        local resEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Resurrection Icon"], db, "resurrectionIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        resSection:RegisterChild(resEnabled)
        
        local resShowText = Add(GUI:CreateCheckbox(self.child, L["Show as Text"], db, "resurrectionIconShowText", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 30, 1)
        resSection:RegisterChild(resShowText)
        
        local resTextCasting = Add(GUI:CreateEditBox(self.child, "Casting Text", db, "resurrectionIconTextCasting", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        resSection:RegisterChild(resTextCasting)
        
        local resTextPending = Add(GUI:CreateEditBox(self.child, "Pending Text", db, "resurrectionIconTextPending", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        resSection:RegisterChild(resTextPending)
        
        local resScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "resurrectionIconScale", nil, function() DF:LightweightUpdateIconPosition("resurrection") end, true), 55, 1)
        resSection:RegisterChild(resScale)
        
        local resAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "resurrectionIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("resurrection") end, true), 55, 1)
        resSection:RegisterChild(resAlpha)
        
        local resAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "resurrectionIconAnchor", function() DF:LightweightUpdateIconPosition("resurrection") end), 55, 1)
        resSection:RegisterChild(resAnchor)
        
        local resX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "resurrectionIconX", nil, function() DF:LightweightUpdateIconPosition("resurrection") end, true), 55, 1)
        resSection:RegisterChild(resX)
        
        local resY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "resurrectionIconY", nil, function() DF:LightweightUpdateIconPosition("resurrection") end, true), 55, 1)
        resSection:RegisterChild(resY)
        
        local resLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "resurrectionIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("resurrection") end, true), 55, 1)
        resSection:RegisterChild(resLevel)
        
        -- ============================================
        -- PHASED ICON (Collapsible)
        -- ============================================
        local phasedSection = Add(GUI:CreateCollapsibleSection(self.child, L["Phased Icon"], false, 250), 28, 1)
        
        local phEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Phased Icon"], db, "phasedIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        phasedSection:RegisterChild(phEnabled)
        
        local phShowText = Add(GUI:CreateCheckbox(self.child, L["Show as Text"], db, "phasedIconShowText", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 30, 1)
        phasedSection:RegisterChild(phShowText)
        
        local phText = Add(GUI:CreateEditBox(self.child, "Status Text", db, "phasedIconText", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        phasedSection:RegisterChild(phText)
        
        local phLFG = Add(GUI:CreateCheckbox(self.child, L["Show LFG Eye for Cross-Instance"], db, "phasedIconShowLFGEye", function() DF:UpdateAllFrames() end), 30, 1)
        phasedSection:RegisterChild(phLFG)
        
        local phScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "phasedIconScale", nil, function() DF:LightweightUpdateIconPosition("phased") end, true), 55, 1)
        phasedSection:RegisterChild(phScale)
        
        local phAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "phasedIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("phased") end, true), 55, 1)
        phasedSection:RegisterChild(phAlpha)
        
        local phHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "phasedIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        phasedSection:RegisterChild(phHide)
        
        local phAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "phasedIconAnchor", function() DF:LightweightUpdateIconPosition("phased") end), 55, 1)
        phasedSection:RegisterChild(phAnchor)
        
        local phX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "phasedIconX", nil, function() DF:LightweightUpdateIconPosition("phased") end, true), 55, 1)
        phasedSection:RegisterChild(phX)
        
        local phY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "phasedIconY", nil, function() DF:LightweightUpdateIconPosition("phased") end, true), 55, 1)
        phasedSection:RegisterChild(phY)
        
        local phLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "phasedIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("phased") end, true), 55, 1)
        phasedSection:RegisterChild(phLevel)
        
        -- ============================================
        -- AFK ICON (Collapsible)
        -- ============================================
        local afkSection = Add(GUI:CreateCollapsibleSection(self.child, L["AFK Icon"], false, 250), 28, 1)
        
        local afkEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable AFK Icon"], db, "afkIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        afkSection:RegisterChild(afkEnabled)
        
        local afkShowText = Add(GUI:CreateCheckbox(self.child, L["Show as Text"], db, "afkIconShowText", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 30, 1)
        afkSection:RegisterChild(afkShowText)
        
        local afkText = Add(GUI:CreateEditBox(self.child, "Status Text", db, "afkIconText", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        afkSection:RegisterChild(afkText)
        
        local afkTimer = Add(GUI:CreateCheckbox(self.child, L["Show Timer"], db, "afkIconShowTimer", function() DF:UpdateAllFramesStatusIcons() end), 30, 1)
        afkSection:RegisterChild(afkTimer)
        
        local afkScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "afkIconScale", nil, function() DF:LightweightUpdateIconPosition("afk") end, true), 55, 1)
        afkSection:RegisterChild(afkScale)
        
        local afkAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "afkIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("afk") end, true), 55, 1)
        afkSection:RegisterChild(afkAlpha)
        
        local afkHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "afkIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        afkSection:RegisterChild(afkHide)
        
        local afkAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "afkIconAnchor", function() DF:LightweightUpdateIconPosition("afk") end), 55, 1)
        afkSection:RegisterChild(afkAnchor)
        
        local afkX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "afkIconX", nil, function() DF:LightweightUpdateIconPosition("afk") end, true), 55, 1)
        afkSection:RegisterChild(afkX)
        
        local afkY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "afkIconY", nil, function() DF:LightweightUpdateIconPosition("afk") end, true), 55, 1)
        afkSection:RegisterChild(afkY)
        
        local afkLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "afkIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("afk") end, true), 55, 1)
        afkSection:RegisterChild(afkLevel)
        
        -- ============================================
        -- VEHICLE ICON (Collapsible)
        -- ============================================
        local vehSection = Add(GUI:CreateCollapsibleSection(self.child, L["Vehicle Icon"], false, 250), 28, 1)
        
        local vehEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Vehicle Icon"], db, "vehicleIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        vehSection:RegisterChild(vehEnabled)
        
        local vehShowText = Add(GUI:CreateCheckbox(self.child, L["Show as Text"], db, "vehicleIconShowText", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 30, 1)
        vehSection:RegisterChild(vehShowText)
        
        local vehText = Add(GUI:CreateEditBox(self.child, "Status Text", db, "vehicleIconText", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        vehSection:RegisterChild(vehText)
        
        local vehScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "vehicleIconScale", nil, function() DF:LightweightUpdateIconPosition("vehicle") end, true), 55, 1)
        vehSection:RegisterChild(vehScale)
        
        local vehAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "vehicleIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("vehicle") end, true), 55, 1)
        vehSection:RegisterChild(vehAlpha)
        
        local vehHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "vehicleIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        vehSection:RegisterChild(vehHide)
        
        local vehAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "vehicleIconAnchor", function() DF:LightweightUpdateIconPosition("vehicle") end), 55, 1)
        vehSection:RegisterChild(vehAnchor)
        
        local vehX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "vehicleIconX", nil, function() DF:LightweightUpdateIconPosition("vehicle") end, true), 55, 1)
        vehSection:RegisterChild(vehX)
        
        local vehY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "vehicleIconY", nil, function() DF:LightweightUpdateIconPosition("vehicle") end, true), 55, 1)
        vehSection:RegisterChild(vehY)
        
        local vehLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "vehicleIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("vehicle") end, true), 55, 1)
        vehSection:RegisterChild(vehLevel)
        
        -- ============================================
        -- RAID ROLE ICON (Collapsible)
        -- ============================================
        local rrSection = Add(GUI:CreateCollapsibleSection(self.child, L["Raid Role Icon (MT/MA)"], false, 250), 28, 1)
        
        local rrEnabled = Add(GUI:CreateCheckbox(self.child, L["Enable Raid Role Icon"], db, "raidRoleIconEnabled", function() DF:UpdateAllFrames() end), 30, 1)
        rrSection:RegisterChild(rrEnabled)
        
        local rrShowTank = Add(GUI:CreateCheckbox(self.child, L["Show Main Tank"], db, "raidRoleIconShowTank", function() DF:UpdateAllFrames() end), 30, 1)
        rrSection:RegisterChild(rrShowTank)
        
        local rrShowAssist = Add(GUI:CreateCheckbox(self.child, L["Show Main Assist"], db, "raidRoleIconShowAssist", function() DF:UpdateAllFrames() end), 30, 1)
        rrSection:RegisterChild(rrShowAssist)
        
        local rrShowText = Add(GUI:CreateCheckbox(self.child, L["Show as Text"], db, "raidRoleIconShowText", function() DF:UpdateAllFramesStatusIcons(); DF:RefreshTestFrames() end), 30, 1)
        rrSection:RegisterChild(rrShowText)
        
        local rrTextTank = Add(GUI:CreateEditBox(self.child, "Tank Text", db, "raidRoleIconTextTank", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        rrSection:RegisterChild(rrTextTank)
        
        local rrTextAssist = Add(GUI:CreateEditBox(self.child, "Assist Text", db, "raidRoleIconTextAssist", function() DF:UpdateAllFramesStatusIcons() end, 120), 55, 1)
        rrSection:RegisterChild(rrTextAssist)
        
        local rrScale = Add(GUI:CreateSlider(self.child, L["Scale"], 0.5, 2.5, 0.1, db, "raidRoleIconScale", nil, function() DF:LightweightUpdateIconPosition("raidRole") end, true), 55, 1)
        rrSection:RegisterChild(rrScale)
        
        local rrAlpha = Add(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "raidRoleIconAlpha", nil, function() DF:LightweightUpdateIconAlpha("raidRole") end, true), 55, 1)
        rrSection:RegisterChild(rrAlpha)
        
        local rrHide = Add(GUI:CreateCheckbox(self.child, L["Hide in Combat"], db, "raidRoleIconHideInCombat", function() DF:UpdateAllFrames() end), 30, 1)
        rrSection:RegisterChild(rrHide)
        
        local rrAnchor = Add(GUI:CreateDropdown(self.child, L["Anchor"], anchorOptions, db, "raidRoleIconAnchor", function() DF:LightweightUpdateIconPosition("raidRole") end), 55, 1)
        rrSection:RegisterChild(rrAnchor)
        
        local rrX = Add(GUI:CreateSlider(self.child, L["Offset X"], -50, 50, 1, db, "raidRoleIconX", nil, function() DF:LightweightUpdateIconPosition("raidRole") end, true), 55, 1)
        rrSection:RegisterChild(rrX)
        
        local rrY = Add(GUI:CreateSlider(self.child, L["Offset Y"], -50, 50, 1, db, "raidRoleIconY", nil, function() DF:LightweightUpdateIconPosition("raidRole") end, true), 55, 1)
        rrSection:RegisterChild(rrY)
        
        local rrLevel = Add(GUI:CreateSlider(self.child, L["Frame Level"], 0, 100, 1, db, "raidRoleIconFrameLevel", nil, function() DF:LightweightUpdateFrameLevel("raidRole") end, true), 55, 1)
        rrSection:RegisterChild(rrLevel)
    end)
    
    -- Indicators > Highlights
    local pageHighlights = CreateSubTab("indicators", "indicators_highlights", L["Highlights"])
    BuildPage(pageHighlights, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"selectionHighlight", "hoverHighlight", "aggroHighlight", "aggro"}, L["Highlights"], "indicators_highlights"), 25, 2)
        
        AddSpace(10, "both")
        
        local currentSection = nil
        
        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then currentSection:RegisterChild(widget) end
            return widget
        end
        
        local highlightModes = {
            ["NONE"] = L["Hidden"],
            ["SOLID"] = L["Solid Border"],
            ["ANIMATED"] = L["Animated Border"],
            ["DASHED"] = L["Dashed Border"],
            ["GLOW"] = L["Glow"],
            ["CORNERS"] = L["Corners Only"],
        }
        
        -- ========================================
        -- SELECTION HIGHLIGHT SECTION
        -- ========================================
        local selectionSection = Add(GUI:CreateCollapsibleSection(self.child, L["Selection Highlight"], true), 36, "both")
        currentSection = selectionSection
        
        local function HideSelectionOptions(d) return d.selectionHighlightMode == "NONE" end
        
        local selGroup = GUI:CreateSettingsGroup(self.child, 260)
        selGroup:AddWidget(GUI:CreateHeader(self.child, L["Selection Settings"]), 40)
        selGroup:AddWidget(GUI:CreateDropdown(self.child, L["Mode"], highlightModes, db, "selectionHighlightMode", function()
            self:RefreshStates()
        end), 55)
        local selThick = selGroup:AddWidget(GUI:CreateSlider(self.child, L["Thickness"], 1, 10, 1, db, "selectionHighlightThickness", nil, function() DF:LightweightUpdateHighlight("selection") end, true), 55)
        selThick.hideOn = HideSelectionOptions
        local selInset = selGroup:AddWidget(GUI:CreateSlider(self.child, L["Inset"], -10, 10, 1, db, "selectionHighlightInset", nil, function() DF:LightweightUpdateHighlight("selection") end, true), 55)
        selInset.hideOn = HideSelectionOptions
        local selAlpha = selGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "selectionHighlightAlpha", nil, function() DF:LightweightUpdateHighlight("selection") end, true), 55)
        selAlpha.hideOn = HideSelectionOptions
        local selCol = selGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "selectionHighlightColor", false, nil, function() DF:LightweightUpdateSelectionHighlightColor() end, true), 35)
        selCol.hideOn = HideSelectionOptions
        AddToSection(selGroup, nil, 1)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ========================================
        -- HOVER HIGHLIGHT SECTION
        -- ========================================
        local hoverSection = Add(GUI:CreateCollapsibleSection(self.child, L["Hover Highlight"], true), 36, "both")
        currentSection = hoverSection
        
        local function HideHoverOptions(d) return d.hoverHighlightMode == "NONE" end
        
        local hoverGroup = GUI:CreateSettingsGroup(self.child, 260)
        hoverGroup:AddWidget(GUI:CreateHeader(self.child, L["Hover Settings"]), 40)
        hoverGroup:AddWidget(GUI:CreateDropdown(self.child, L["Mode"], highlightModes, db, "hoverHighlightMode", function()
            self:RefreshStates()
        end), 55)
        local hoverThick = hoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Thickness"], 1, 10, 1, db, "hoverHighlightThickness", nil, function() DF:LightweightUpdateHighlight("hover") end, true), 55)
        hoverThick.hideOn = HideHoverOptions
        local hoverInset = hoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Inset"], -10, 10, 1, db, "hoverHighlightInset", nil, function() DF:LightweightUpdateHighlight("hover") end, true), 55)
        hoverInset.hideOn = HideHoverOptions
        local hoverAlpha = hoverGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "hoverHighlightAlpha", nil, function() DF:LightweightUpdateHighlight("hover") end, true), 55)
        hoverAlpha.hideOn = HideHoverOptions
        local hoverCol = hoverGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Color"], db, "hoverHighlightColor", false, nil, function() DF:LightweightUpdateHighlight("hover") end, true), 35)
        hoverCol.hideOn = HideHoverOptions
        AddToSection(hoverGroup, nil, 1)
        
        currentSection = nil
        AddSpace(10, "both")
        
        -- ========================================
        -- AGGRO HIGHLIGHT SECTION
        -- ========================================
        local aggroSection = Add(GUI:CreateCollapsibleSection(self.child, L["Aggro Highlight"], true), 36, "both")
        currentSection = aggroSection
        
        local function HideAggroOptions(d) return d.aggroHighlightMode == "NONE" or d.aggroHighlightMode == "HEALTH_COLOR" end
        local function HideAggroModeNone(d) return d.aggroHighlightMode == "NONE" end
        local function HideCustomColorOptions(d) return d.aggroHighlightMode == "NONE" or not d.aggroUseCustomColors end
        local function HideNonTankingColors(d) return d.aggroHighlightMode == "NONE" or not d.aggroUseCustomColors or d.aggroOnlyTanking end
        
        local aggroModes = {
            ["NONE"] = L["Hidden"],
            ["HEALTH_COLOR"] = L["Health Bar Color"],
            ["SOLID"] = L["Solid Border"],
            ["ANIMATED"] = L["Animated Border"],
            ["DASHED"] = L["Dashed Border"],
            ["GLOW"] = L["Glow"],
            ["CORNERS"] = L["Corners Only"],
        }
        
        -- Aggro Settings Group (col1)
        local aggroGroup = GUI:CreateSettingsGroup(self.child, 260)
        aggroGroup:AddWidget(GUI:CreateHeader(self.child, L["Aggro Settings"]), 40)
        aggroGroup:AddWidget(GUI:CreateDropdown(self.child, L["Mode"], aggroModes, db, "aggroHighlightMode", function()
            self:RefreshStates()
            if DF.UpdateAllHighlights then DF:UpdateAllHighlights() end
        end), 55)
        local aggroOnlyTanking = aggroGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Only Show When Tanking"], db, "aggroOnlyTanking", function()
            self:RefreshStates()
            if DF.UpdateAllHighlights then DF:UpdateAllHighlights() end
        end), 28)
        aggroOnlyTanking.hideOn = HideAggroModeNone
        local aggroThick = aggroGroup:AddWidget(GUI:CreateSlider(self.child, L["Thickness"], 1, 10, 1, db, "aggroHighlightThickness", nil, function() DF:LightweightUpdateHighlight("aggro") end, true), 55)
        aggroThick.hideOn = HideAggroOptions
        local aggroInset = aggroGroup:AddWidget(GUI:CreateSlider(self.child, L["Inset"], -10, 10, 1, db, "aggroHighlightInset", nil, function() DF:LightweightUpdateHighlight("aggro") end, true), 55)
        aggroInset.hideOn = HideAggroOptions
        local aggroAlpha = aggroGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "aggroHighlightAlpha", nil, function() DF:LightweightUpdateHighlight("aggro") end, true), 55)
        aggroAlpha.hideOn = HideAggroOptions
        AddToSection(aggroGroup, nil, 1)
        
        -- Threat Colors Group (col2)
        local threatGroup = GUI:CreateSettingsGroup(self.child, 260)
        threatGroup:AddWidget(GUI:CreateHeader(self.child, L["Threat Colors"]), 40)
        local useCustomColors = threatGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Use Custom Colors"], db, "aggroUseCustomColors", function()
            self:RefreshStates()
            if DF.UpdateAllHighlights then DF:UpdateAllHighlights() end
        end), 28)
        useCustomColors.hideOn = HideAggroModeNone
        local colorHighThreat = threatGroup:AddWidget(GUI:CreateColorPicker(self.child, L["High Threat (Yellow)"], db, "aggroColorHighThreat", false, nil, function()
            DF:LightweightUpdateHighlight("aggro")
        end, true), 30)
        colorHighThreat.hideOn = HideNonTankingColors
        local colorHighestThreat = threatGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Highest Threat (Orange)"], db, "aggroColorHighestThreat", false, nil, function()
            DF:LightweightUpdateHighlight("aggro")
        end, true), 30)
        colorHighestThreat.hideOn = HideNonTankingColors
        local colorTanking = threatGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Tanking (Red)"], db, "aggroColorTanking", false, nil, function()
            DF:LightweightUpdateHighlight("aggro")
        end, true), 30)
        colorTanking.hideOn = HideCustomColorOptions
        threatGroup:AddWidget(GUI:CreateLabel(self.child, L["Yellow=high, Orange=highest, Red=tanking."], 230), 25)
        threatGroup.hideOn = HideAggroModeNone
        AddToSection(threatGroup, nil, 2)
        
        currentSection = nil
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_dispel", label = L["Dispel Overlay"]},
        }), 30, "both")
    end)
    
    -- Auras > Dispel Overlay (moved from Indicators)
    local pageDispel = CreateSubTab("auras", "auras_dispel", L["Dispel Overlay"])
    BuildPage(pageDispel, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Copy button at top
        Add(CreateCopyButton(self.child, {"dispel"}, L["Dispel Overlay"], "auras_dispel"), 25, 2)

        AddSpace(10, "both")

        local function HideIfSourceOff(d)
            return d.dispelOverlaySource == "off"
        end
        local function HideIfNotDF(d)
            local s = d.dispelOverlaySource
            return s ~= "dandersframes" and s ~= "both"
        end
        local function HideIfNotBlizzard(d)
            local s = d.dispelOverlaySource
            return s ~= "blizzard" and s ~= "both"
        end
        -- Kept for back-compat inside this function — alias for HideIfNotDF.
        local HideDispelOptions = HideIfNotDF

        local function InvalidateCurves()
            if DF.InvalidateDispelColorCurve then DF:InvalidateDispelColorCurve() end
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end

        -- Called when the overlay source changes: refresh DF's overlay and
        -- rebuild the Blizzard container anchor per the new source value.
        local function OnSourceChanged()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
            if DF.PreviewPrivateAuraAnchors then
                DF:PreviewPrivateAuraAnchors()
            elseif DF.UpdateContainerOverlaySettings and DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    DF:UpdateContainerOverlaySettings(f)
                end)
            end
        end
        local function OnDispelTypeChanged()
            InvalidateCurves()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
            if DF.UpdateContainerOverlaySettings and DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    DF:UpdateContainerOverlaySettings(f)
                end)
            end
        end

        -- ===== OVERLAY SOURCE (full-width, always visible) =====
        -- Segmented button group + themed callout that explains the selected
        -- mode. Shared "Show Overlay For" dropdown sits below in a narrow
        -- column-1 group.
        local sourceHeader = GUI:CreateHeader(self.child, L["Overlay Source"])
        Add(sourceHeader, 36, "both")
        GUI:AddSectionNewBadge(sourceHeader, "auras_dispel", "overlaySource")

        -- Four options in the user's preferred display order.
        local sourceOptions = {
            { value = "both",          label = L["Hybrid"],   subtitle = L["Recommended"] },
            { value = "dandersframes", label = "DandersFrames", subtitle = L["No Boss Debuffs"] },
            { value = "blizzard",      label = L["Blizzard"], subtitle = L["Limited Options"] },
            { value = "off",           label = L["Off"],      subtitle = "" },
        }

        local calloutBox  -- forward declaration so the button callback can update it
        local function UpdateCalloutForSource()
            local s = db.dispelOverlaySource or "both"
            if s == "both" then
                calloutBox:SetContent(L["Hybrid Mode"], L["DandersFrames overlay shows for normal dispellable debuffs. Blizzard overlay activates only when a boss debuff (private aura) is present — private auras are invisible to addons, so only Blizzard can show them."])
            elseif s == "dandersframes" then
                calloutBox:SetContent(L["DandersFrames Mode"], L["DandersFrames overlay handles all normal dispellable debuffs with full customisation. Boss debuffs (private auras) are not covered."])
            elseif s == "blizzard" then
                calloutBox:SetContent(L["Blizzard Mode"], L["Blizzard's native overlay covers both normal debuffs and boss debuffs (private auras), with limited customisation options."])
            else
                calloutBox:SetContent(L["Off Mode"], L["No dispel overlay is displayed."])
            end
        end

        local sourceButtons = GUI:CreateSegmentedButtonGroup(self.child, sourceOptions, db, "dispelOverlaySource", function()
            OnSourceChanged()
            UpdateCalloutForSource()
            self:RefreshStates()
            GUI:RefreshCurrentPage()
        end, 560)
        Add(sourceButtons, 42, "both")

        calloutBox = GUI:CreateInfoCallout(self.child, 560, 60)
        UpdateCalloutForSource()
        Add(calloutBox, 66, "both")

        -- Narrow settings group for the shared "Show Overlay For" dropdown.
        AddSpace(8, "both")
        local settingsGroup = GUI:CreateSettingsGroup(self.child, 280)
        settingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Settings"]), 40)
        local dispelIndicatorOptions = { [1]= L["Dispellable By Me"], [2]= L["All Dispellable"] }
        local dispelIndicatorDropdown = settingsGroup:AddWidget(GUI:CreateDropdown(self.child, L["Show Overlay For"], dispelIndicatorOptions, db, "dispelOverlayDispelType", function()
            OnDispelTypeChanged()
        end), 55)
        dispelIndicatorDropdown.hideOn = HideIfSourceOff
        settingsGroup.hideOn = HideIfSourceOff
        Add(settingsGroup, nil, 1)

        -- ===== DANDERSFRAMES COLLAPSIBLE SECTION =====
        -- Wraps all DandersFrames-overlay SettingsGroups below. Header hides
        -- entirely when source doesn't include DandersFrames; groups hide
        -- via their own hideOn + the section's collapsed state.
        AddSyncPoint()
        AddSpace(10, "both")
        local dfSection = GUI:CreateCollapsibleSection(self.child, L["DandersFrames Overlay"], true, 560)
        dfSection.hideOn = HideIfNotDF
        -- Tag: DandersFrames only ever handles normal dispellable debuffs,
        -- never private auras, so the tag is static.
        dfSection:SetTag("[" .. L["Normal Dispels"] .. "]")
        Add(dfSection, 36, "both")

        -- Display group (quick toggles) — Column 1
        local displayGroup = GUI:CreateSettingsGroup(self.child, 280)
        displayGroup:AddWidget(GUI:CreateHeader(self.child, L["Display"]), 40)
        local showBorder = displayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Border"], db, "dispelShowBorder", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        showBorder.hideOn = HideDispelOptions
        local showGradient = displayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Gradient"], db, "dispelShowGradient", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        showGradient.hideOn = HideDispelOptions
        local animate = displayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Pulse Animation"], db, "dispelAnimate", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        animate.hideOn = HideDispelOptions
        local nameTextCheck = displayGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Color Name Text"], db, "dispelNameText", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        nameTextCheck.hideOn = HideDispelOptions
        displayGroup.hideOn = HideDispelOptions
        dfSection:RegisterChild(displayGroup)
        Add(displayGroup, nil, 1)

        -- ===== ICON GROUP (Column 2) =====
        local iconGroup = GUI:CreateSettingsGroup(self.child, 280)
        iconGroup:AddWidget(GUI:CreateHeader(self.child, L["Dispel Type Icon"]), 40)
        local showIcon = iconGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show Dispel Icon"], db, "dispelShowIcon", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        showIcon.hideOn = HideDispelOptions
        local HideIconOptions = function(d) return HideIfNotDF(d) or d.dispelShowIcon == false end
        local iconSize = iconGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Size"], 10, 40, 1, db, "dispelIconSize", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        iconSize.hideOn = HideIconOptions
        local iconAlpha = iconGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Opacity"], 0.1, 1.0, 0.1, db, "dispelIconAlpha", function()
            InvalidateCurves()
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        iconAlpha.hideOn = HideIconOptions
        local iconPositions = {
            ["CENTER"]= L["Center"], ["TOP"]= L["Top"], ["BOTTOM"]= L["Bottom"],
            ["LEFT"]= L["Left"], ["RIGHT"]= L["Right"],
            ["TOPLEFT"]= L["Top Left"], ["TOPRIGHT"]= L["Top Right"],
            ["BOTTOMLEFT"]= L["Bottom Left"], ["BOTTOMRIGHT"]= L["Bottom Right"],
        }
        local iconPos = iconGroup:AddWidget(GUI:CreateDropdown(self.child, L["Icon Position"], iconPositions, db, "dispelIconPosition", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 55)
        iconPos.hideOn = HideIconOptions
        local iconOffsetX = iconGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Offset X"], -50, 50, 1, db, "dispelIconOffsetX", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        iconOffsetX.hideOn = HideIconOptions
        local iconOffsetY = iconGroup:AddWidget(GUI:CreateSlider(self.child, L["Icon Offset Y"], -50, 50, 1, db, "dispelIconOffsetY", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        iconOffsetY.hideOn = HideIconOptions
        iconGroup.hideOn = HideDispelOptions
        dfSection:RegisterChild(iconGroup)
        Add(iconGroup, nil, 2)

        -- ===== BORDER GROUP (Column 1) =====
        local borderGroup = GUI:CreateSettingsGroup(self.child, 280)
        borderGroup:AddWidget(GUI:CreateHeader(self.child, L["Border"]), 40)
        local borderSize = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Thickness"], 1, 6, 1, db, "dispelBorderSize", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        borderSize.hideOn = HideDispelOptions
        local borderInset = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Inset"], -4, 4, 1, db, "dispelBorderInset", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        borderInset.hideOn = HideDispelOptions
        local borderAlpha = borderGroup:AddWidget(GUI:CreateSlider(self.child, L["Border Opacity"], 0.1, 1.0, 0.1, db, "dispelBorderAlpha", function()
            InvalidateCurves()
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        borderAlpha.hideOn = HideDispelOptions
        borderGroup.hideOn = HideDispelOptions
        dfSection:RegisterChild(borderGroup)
        Add(borderGroup, nil, 1)

        -- ===== COLORS GROUP (Column 2) =====
        local colorsGroup = GUI:CreateSettingsGroup(self.child, 280)
        colorsGroup:AddWidget(GUI:CreateHeader(self.child, L["Custom Dispel Colors"]), 40)
        local magicColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Magic"], db, "dispelMagicColor", false, InvalidateCurves, function() DF:LightweightUpdateDispelColors() end, true), 30)
        magicColor.hideOn = HideDispelOptions
        local curseColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Curse"], db, "dispelCurseColor", false, InvalidateCurves, function() DF:LightweightUpdateDispelColors() end, true), 30)
        curseColor.hideOn = HideDispelOptions
        local diseaseColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Disease"], db, "dispelDiseaseColor", false, InvalidateCurves, function() DF:LightweightUpdateDispelColors() end, true), 30)
        diseaseColor.hideOn = HideDispelOptions
        local poisonColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Poison"], db, "dispelPoisonColor", false, InvalidateCurves, function() DF:LightweightUpdateDispelColors() end, true), 30)
        poisonColor.hideOn = HideDispelOptions
        local bleedColor = colorsGroup:AddWidget(GUI:CreateColorPicker(self.child, L["Bleed / Enrage"], db, "dispelBleedColor", false, InvalidateCurves, function() DF:LightweightUpdateDispelColors() end, true), 30)
        bleedColor.hideOn = HideDispelOptions
        local resetColors = colorsGroup:AddWidget(GUI:CreateButton(self.child, L["Reset to Defaults"], 130, 22, function()
            db.dispelMagicColor = {r = 0.2, g = 0.6, b = 1.0}
            db.dispelCurseColor = {r = 0.6, g = 0.0, b = 1.0}
            db.dispelDiseaseColor = {r = 0.6, g = 0.4, b = 0.0}
            db.dispelPoisonColor = {r = 0.0, g = 0.6, b = 0.0}
            db.dispelBleedColor = {r = 1.0, g = 0.0, b = 0.0}
            InvalidateCurves()
            self:Refresh()
        end), 30)
        resetColors.hideOn = HideDispelOptions
        colorsGroup.hideOn = HideDispelOptions
        dfSection:RegisterChild(colorsGroup)
        Add(colorsGroup, nil, 2)

        -- ===== GRADIENT GROUP (Column 1) =====
        local gradientGroup = GUI:CreateSettingsGroup(self.child, 280)
        gradientGroup:AddWidget(GUI:CreateHeader(self.child, L["Gradient"]), 40)
        local gradientStyles = {
            ["FULL"]= L["Full Frame"], ["TOP"]= L["Top Edge"], ["BOTTOM"]= L["Bottom Edge"],
            ["LEFT"]= L["Left Edge"], ["RIGHT"]= L["Right Edge"], ["EDGE"]= L["Edge Glow (All Sides)"],
        }
        local gradStyle = gradientGroup:AddWidget(GUI:CreateDropdown(self.child, L["Gradient Position"], gradientStyles, db, "dispelGradientStyle", function()
            self:RefreshStates()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 55)
        gradStyle.hideOn = HideDispelOptions
        local onHealthCheck = gradientGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Show On Current Health Only"], db, "dispelGradientOnCurrentHealth", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        onHealthCheck.hideOn = function(d) return HideIfNotDF(d) or d.dispelGradientStyle ~= "FULL" end
        local gradSize = gradientGroup:AddWidget(GUI:CreateSlider(self.child, L["Gradient Size"], 0.1, 1.0, 0.1, db, "dispelGradientSize", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        gradSize.hideOn = HideDispelOptions
        local gradAlpha = gradientGroup:AddWidget(GUI:CreateSlider(self.child, L["Gradient Opacity"], 0.1, 1.0, 0.1, db, "dispelGradientAlpha", function()
            InvalidateCurves()
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        gradAlpha.hideOn = HideDispelOptions
        local gradIntensity = gradientGroup:AddWidget(GUI:CreateSlider(self.child, L["Gradient Intensity"], 0.5, 3.0, 0.1, db, "dispelGradientIntensity", function()
            InvalidateCurves()
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        gradIntensity.hideOn = HideDispelOptions
        local blendModes = { ["ADD"]= L["Glow (ADD)"], ["BLEND"]= L["Solid (BLEND)"] }
        local blendDropdown = gradientGroup:AddWidget(GUI:CreateDropdown(self.child, L["Blend Mode"], blendModes, db, "dispelGradientBlendMode", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 55)
        blendDropdown.hideOn = HideDispelOptions
        gradientGroup.hideOn = HideDispelOptions
        dfSection:RegisterChild(gradientGroup)
        Add(gradientGroup, nil, 1)

        -- ===== DARKEN GROUP (Column 2) =====
        local darkenGroup = GUI:CreateSettingsGroup(self.child, 280)
        darkenGroup:AddWidget(GUI:CreateHeader(self.child, L["Darken Effect"]), 40)
        local darkenCheck = darkenGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Darken Behind Gradient"], db, "dispelGradientDarkenEnabled", function()
            self:RefreshStates()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end), 30)
        darkenCheck.hideOn = HideDispelOptions
        local darkenAlpha = darkenGroup:AddWidget(GUI:CreateSlider(self.child, L["Darken Amount"], 0.1, 1.0, 0.05, db, "dispelGradientDarkenAlpha", function()
            if DF.UpdateAllDispelOverlays then DF:UpdateAllDispelOverlays() end
        end, function() DF:LightweightUpdateDispelOverlay() end, true), 55)
        darkenAlpha.hideOn = function(d) return HideIfNotDF(d) or not d.dispelGradientDarkenEnabled end
        darkenGroup.hideOn = HideDispelOptions
        dfSection:RegisterChild(darkenGroup)
        Add(darkenGroup, nil, 2)

        -- ===== BLIZZARD OVERLAY COLLAPSIBLE SECTION =====
        -- Only relevant for sources "blizzard" and "both". Header hides
        -- entirely when source excludes Blizzard.
        AddSyncPoint()
        AddSpace(15, "both")
        local blizSection = GUI:CreateCollapsibleSection(self.child, L["Blizzard Overlay"], true, 560)
        blizSection.hideOn = HideIfNotBlizzard
        -- Tag reflects what the Blizzard overlay actually handles under
        -- the current source mode:
        --   Hybrid   → only private auras (DandersFrames handles normals)
        --   Blizzard → both (Blizzard runs alone for every dispellable)
        local function UpdateBlizSectionTag()
            local s = db.dispelOverlaySource or "both"
            local privateTag = "[" .. L["Private Aura Dispels"] .. "]"
            local normalTag  = "[" .. L["Normal Dispels"] .. "]"
            if s == "both" then
                blizSection:SetTag(privateTag)
            elseif s == "blizzard" then
                blizSection:SetTag(normalTag .. " " .. privateTag)
            else
                blizSection:SetTag(nil)
            end
        end
        UpdateBlizSectionTag()
        blizSection.refreshContent = function(self) UpdateBlizSectionTag() end
        Add(blizSection, 36, "both")

        local blizGroup = GUI:CreateSettingsGroup(self.child, 280)
        blizGroup:AddWidget(GUI:CreateLabel(self.child, "|cFFFF4444Note:|r " .. L["This overlay is rendered by Blizzard and has limited customisation. It is separate from the DandersFrames overlay above."], 260), 60)

        local gradientDirOptions = {
            [0] = L["Top Edge"],
            [1] = L["Bottom Edge"],
            [2] = L["Left Edge"],
        }
        local blizGradientDir = blizGroup:AddWidget(GUI:CreateDropdown(self.child, L["Gradient Direction"], gradientDirOptions, db, "bossDebuffsContainerOverlayGradientDir", function()
            if DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    if DF.UpdateContainerOverlaySettings then DF:UpdateContainerOverlaySettings(f) end
                end)
            end
        end), 55)
        blizGradientDir.hideOn = HideIfNotBlizzard
        local gradientNote = blizGroup:AddWidget(GUI:CreateLabel(self.child, "|cFF888888" .. L["Right Edge is not available in the Blizzard API."] .. "|r", 260), 20)
        gradientNote.hideOn = HideIfNotBlizzard

        local blizAlpha = blizGroup:AddWidget(GUI:CreateSlider(self.child, L["Alpha"], 0.1, 1.0, 0.05, db, "bossDebuffsContainerOverlayAlpha", function()
            if DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    if DF.UpdateContainerOverlaySettings then DF:UpdateContainerOverlaySettings(f) end
                end)
            end
        end), 40)
        blizAlpha.hideOn = HideIfNotBlizzard

        local strataOptions = {
            BACKGROUND = L["Background"],
            LOW = L["Low"],
            MEDIUM = L["Medium"],
            HIGH = L["High"],
            DIALOG = L["Dialog"],
            _order = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG" },
        }
        local blizStrata = blizGroup:AddWidget(GUI:CreateDropdown(self.child, L["Frame Strata"], strataOptions, db, "bossDebuffsContainerOverlayStrata", function()
            if DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    if DF.UpdateContainerOverlaySettings then DF:UpdateContainerOverlaySettings(f) end
                end)
            end
        end), 55)
        blizStrata.hideOn = HideIfNotBlizzard

        local blizFrameLevel = blizGroup:AddWidget(GUI:CreateSlider(self.child, L["Frame Level"], 0, 50, 1, db, "bossDebuffsContainerOverlayFrameLevel", function()
            if DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    if DF.UpdateContainerOverlaySettings then DF:UpdateContainerOverlaySettings(f) end
                end)
            end
        end), 40)
        blizFrameLevel.hideOn = HideIfNotBlizzard

        local frameLevelNote = blizGroup:AddWidget(GUI:CreateLabel(self.child, "|cFF888888" .. L["Raise strata or frame level if the overlay is hidden by frame text on short/wide frames."] .. "|r", 260), 30)
        frameLevelNote.hideOn = HideIfNotBlizzard

        local blizSizeAdjust = blizGroup:AddWidget(GUI:CreateSlider(self.child, L["Inset"], -10, 10, 1, db, "bossDebuffsContainerOverlaySizeAdjust", function()
            if DF.IterateAllFrames then
                DF:IterateAllFrames(function(f)
                    if DF.UpdateContainerOverlaySettings then DF:UpdateContainerOverlaySettings(f) end
                end)
            end
        end), 40)
        blizSizeAdjust.hideOn = HideIfNotBlizzard

        local editModeBtn = blizGroup:AddWidget(GUI:CreateButton(self.child, L["Open Edit Mode"], 140, 24, function()
            -- Use :Show() directly instead of ShowUIPanel — DF's GUIFrame is
            -- in UISpecialFrames, and ShowUIPanel's fullscreen-panel transition
            -- closes special frames as part of its slot management. :Show()
            -- bypasses the slot system; edit mode's OnShow still fires.
            if EditModeManagerFrame then
                EditModeManagerFrame:Show()
            end
        end), 30)
        editModeBtn.hideOn = HideIfNotBlizzard
        local editModeNote = blizGroup:AddWidget(GUI:CreateLabel(self.child, "|cFF888888" .. L["Open edit mode to preview the Blizzard dispel overlay."] .. "|r", 260), 25)
        editModeNote.hideOn = HideIfNotBlizzard

        blizGroup.hideOn = HideIfNotBlizzard
        blizSection:RegisterChild(blizGroup)
        Add(blizGroup, nil, 1)

        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "auras_debuffs", label = L["Debuffs"]},
            {pageId = "indicators_highlights", label = L["Highlights"]},
        }), 30, "both")
    end)
    
    -- ========================================
    -- CATEGORY: Profiles
    -- ========================================
    CreateCategory("profiles", L["Profiles"])
    
    -- ========================================
    -- Profiles > Auto Layouts (Raid only)
    -- ========================================
    local pageAutoProfiles = CreateSubTab("profiles", "profiles_auto", L["Auto Layouts"])
    BuildPage(pageAutoProfiles, function(self, db, Add, AddSpace)
        if DF.AutoProfilesUI and DF.AutoProfilesUI.BuildPage then
            DF.AutoProfilesUI:BuildPage(GUI, self, db, Add, AddSpace)
        else
            Add(GUI:CreateHeader(self.child, L["Auto Layouts"]), 40, "both")
            Add(GUI:CreateLabel(self.child, L["Auto Layouts module not loaded."], 400), 30, "both")
        end
    end)
    
    -- Profiles > Manage
    local pageManage = CreateSubTab("profiles", "profiles_manage", L["Manage"])
    BuildPage(pageManage, function(self, db, Add, AddSpace, AddSyncPoint)
        local currentProfile = DF:GetCurrentProfile()
        local profiles = DF:GetProfiles()
        
        -- Helper to add to current section (for collapsible sections this pattern won't apply, but we use groups)
        local currentSection = nil
        local function AddToSection(widget, col, colNum)
            widget.layoutCol = colNum or col
            table.insert(self.children, widget)
        end
        
        -- ============================================
        -- COLUMN 1: Profile List & Creation
        -- ============================================
        
        -- Current Profile Info Group
        local currentGroup = GUI:CreateSettingsGroup(self.child, 260)
        currentGroup:AddWidget(GUI:CreateHeader(self.child, L["Current Profile"]), 40)
        currentGroup:AddWidget(GUI:CreateLabel(self.child, "|cff00ff00" .. currentProfile .. "|r", 240), 25)
        AddToSection(currentGroup, nil, 1)
        
        -- Available Profiles Group
        local listGroup = GUI:CreateSettingsGroup(self.child, 260)
        listGroup:AddWidget(GUI:CreateHeader(self.child, L["Available Profiles"]), 40)
        
        -- Create a container frame for profile list with fixed width and max height
        local maxListHeight = 180
        local contentHeight = #profiles * 28 + 10
        local listHeight = math.min(contentHeight, maxListHeight)
        local listContainer = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        listContainer:SetSize(240, listHeight)
        listContainer:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        listContainer:SetBackdropColor(0, 0, 0, 0.3)
        listContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        listGroup:AddWidget(listContainer, listHeight + 5)
        
        -- Create scroll frame for the profile list
        local profileScroll = CreateFrame("ScrollFrame", nil, listContainer, "ScrollFrameTemplate")
        profileScroll:SetPoint("TOPLEFT", 2, -2)
        profileScroll:SetPoint("BOTTOMRIGHT", -22, 2)
        
        GUI.StyleScrollBar(profileScroll)
        if contentHeight <= maxListHeight and profileScroll.ScrollBar then
            profileScroll.ScrollBar:Hide()
            profileScroll:SetPoint("BOTTOMRIGHT", -4, 2)
        end
        
        -- Create scroll child to hold profile buttons
        local profileScrollChild = CreateFrame("Frame", nil, profileScroll)
        profileScrollChild:SetSize(210, contentHeight)
        profileScroll:SetScrollChild(profileScrollChild)
        
        -- Profile buttons inside scroll child
        local py = -3
        for i, p in ipairs(profiles) do
            local btn = CreateFrame("Button", nil, profileScrollChild, "BackdropTemplate")
            btn:SetSize(206, 24)
            btn:SetPoint("TOPLEFT", 2, py)
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
            btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            
            local text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            text:SetPoint("CENTER")
            text:SetText(p)
            
            if p == currentProfile then
                local c = GUI.GetThemeColor()
                btn:SetBackdropColor(c.r * 0.3, c.g * 0.3, c.b * 0.3, 1)
                btn:SetBackdropBorderColor(c.r, c.g, c.b, 1)
            end
            
            btn:SetScript("OnEnter", function(self)
                self:SetBackdropColor(0.25, 0.25, 0.25, 1)
            end)
            btn:SetScript("OnLeave", function(self)
                if p == currentProfile then
                    local c = GUI.GetThemeColor()
                    self:SetBackdropColor(c.r * 0.3, c.g * 0.3, c.b * 0.3, 1)
                else
                    self:SetBackdropColor(0.15, 0.15, 0.15, 1)
                end
            end)
            btn:SetScript("OnClick", function() 
                DF:SetProfile(p) 
                if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
            end)
            py = py - 28
        end
        
        AddToSection(listGroup, nil, 1)
        
        -- Create New Profile Group
        local createGroup = GUI:CreateSettingsGroup(self.child, 260)
        createGroup:AddWidget(GUI:CreateHeader(self.child, L["Create New Profile"]), 40)
        
        local input = GUI:CreateInput(self.child, L["Profile Name"], 240)
        createGroup:AddWidget(input, 50)
        
        -- Button row for create actions
        local btnRow = CreateFrame("Frame", nil, self.child)
        btnRow:SetSize(240, 28)
        
        local createBtn = GUI:CreateButton(self.child, L["Create Empty"], 115, 24, function()
            local text = input.EditBox:GetText()
            if not text or text == "" then
                print("|cffff6666DandersFrames:|r Please enter a profile name.")
                return
            end
            DF:SetProfile(text) 
            input.EditBox:SetText("")
            if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
        end)
        createBtn:SetParent(btnRow)
        createBtn:SetPoint("LEFT", 0, 0)
        
        local dupeBtn = GUI:CreateButton(self.child, L["Duplicate Current"], 115, 24, function()
            local text = input.EditBox:GetText()
            if not text or text == "" then
                print("|cffff6666DandersFrames:|r Please enter a name for the duplicated profile.")
                return
            end
            if DF:DuplicateProfile(text) then
                input.EditBox:SetText("")
                if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
            end
        end)
        dupeBtn:SetParent(btnRow)
        dupeBtn:SetPoint("LEFT", createBtn, "RIGHT", 10, 0)
        
        createGroup:AddWidget(btnRow, 32)
        AddToSection(createGroup, nil, 1)
        
        -- ============================================
        -- COLUMN 2: Actions & Settings
        -- ============================================
        
        -- Profile Actions Group
        local actionsGroup = GUI:CreateSettingsGroup(self.child, 260)
        actionsGroup:AddWidget(GUI:CreateHeader(self.child, L["Profile Actions"]), 40)
        
        -- Register delete confirmation popup
        if not StaticPopupDialogs["DANDERSFRAMES_DELETE_PROFILE_CONFIRM"] then
            StaticPopupDialogs["DANDERSFRAMES_DELETE_PROFILE_CONFIRM"] = {
                text = L["Delete profile '%s'?\n\nThis cannot be undone."],
                button1 = L["Delete"],
                button2 = L["Cancel"],
                OnAccept = function(self, data)
                    DF:SetProfile("Default")
                    DF:DeleteProfile(data)
                    if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
        end
        
        actionsGroup:AddWidget(GUI:CreateIconButton(self.child, "delete", L["Delete Current Profile"], 240, 26, function()
            local p = DF:GetCurrentProfile()
            if p == "Default" then 
                print("|cffff6666DandersFrames:|r Cannot delete Default profile.") 
            else
                local dialog = StaticPopup_Show("DANDERSFRAMES_DELETE_PROFILE_CONFIRM", p)
                if dialog then
                    dialog.data = p
                end
            end
        end), 32)
        
        -- Register reset confirmation popup
        if not StaticPopupDialogs["DANDERSFRAMES_RESET_PROFILE_CONFIRM"] then
            StaticPopupDialogs["DANDERSFRAMES_RESET_PROFILE_CONFIRM"] = {
                text = L["Reset current profile to defaults?\nThis will reset BOTH Party and Raid settings."],
                button1 = L["Yes"],
                button2 = L["No"],
                OnAccept = function()
                    DF:ResetProfile("party")
                    DF:ResetProfile("raid")
                    if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
        end
        
        actionsGroup:AddWidget(GUI:CreateIconButton(self.child, "refresh", L["Reset Profile to Defaults"], 240, 26, function()
            StaticPopup_Show("DANDERSFRAMES_RESET_PROFILE_CONFIRM")
        end), 32)
        
        AddToSection(actionsGroup, nil, 2)
        
        -- Copy Settings Group
        local copyGroup = GUI:CreateSettingsGroup(self.child, 260)
        copyGroup:AddWidget(GUI:CreateHeader(self.child, L["Copy Settings"]), 40)
        copyGroup:AddWidget(GUI:CreateLabel(self.child, L["Copy all settings between Party and Raid modes."], 240), 25)
        
        -- Register copy confirmation popups
        if not StaticPopupDialogs["DANDERSFRAMES_COPY_PARTY_TO_RAID"] then
            StaticPopupDialogs["DANDERSFRAMES_COPY_PARTY_TO_RAID"] = {
                text = "Copy Party settings to Raid?\n\nThis will overwrite all Raid settings with your current Party settings.",
                button1 = L["Copy"],
                button2 = L["Cancel"],
                OnAccept = function()
                    DF:CopyProfile("party", "raid")
                    if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
        end
        
        if not StaticPopupDialogs["DANDERSFRAMES_COPY_RAID_TO_PARTY"] then
            StaticPopupDialogs["DANDERSFRAMES_COPY_RAID_TO_PARTY"] = {
                text = "Copy Raid settings to Party?\n\nThis will overwrite all Party settings with your current Raid settings.",
                button1 = L["Copy"],
                button2 = L["Cancel"],
                OnAccept = function()
                    DF:CopyProfile("raid", "party")
                    if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
        end
        
        copyGroup:AddWidget(GUI:CreateIconButton(self.child, "chevron_right", L["Party to Raid"], 240, 26, function()
            StaticPopup_Show("DANDERSFRAMES_COPY_PARTY_TO_RAID")
        end), 32)
        
        copyGroup:AddWidget(GUI:CreateIconButton(self.child, "chevron_right", L["Raid to Party"], 240, 26, function()
            StaticPopup_Show("DANDERSFRAMES_COPY_RAID_TO_PARTY")
        end), 32)
        
        AddToSection(copyGroup, nil, 2)
        
        -- Auto-Switch by Spec Group
        local specGroup = GUI:CreateSettingsGroup(self.child, 260)
        specGroup:AddWidget(GUI:CreateHeader(self.child, L["Auto-Switch by Spec"]), 40)
        
        -- Initialize per-character data if needed
        if not DandersFramesCharDB then 
            DandersFramesCharDB = { enableSpecSwitch = false, specProfiles = {} } 
        end
        
        specGroup:AddWidget(GUI:CreateCheckbox(self.child, L["Enable Spec Auto-Switch"], DandersFramesCharDB, "enableSpecSwitch"), 30)
        
        local numSpecs = GetNumSpecializations and GetNumSpecializations() or 0
        if numSpecs > 0 then
            -- Build profile list for dropdown
            local pList = { [""]= L["None"] }
            for _, p in ipairs(profiles) do 
                pList[p] = p 
            end
            
            if not DandersFramesCharDB.specProfiles then 
                DandersFramesCharDB.specProfiles = {} 
            end
            
            for i = 1, numSpecs do
                local id, name, _, icon = GetSpecializationInfo(i)
                if name then
                    specGroup:AddWidget(GUI:CreateDropdown(self.child, name, pList, DandersFramesCharDB.specProfiles, i), 55)
                end
            end
        else
            specGroup:AddWidget(GUI:CreateLabel(self.child, L["Specialization data not available."], 240), 25)
        end
        
        AddToSection(specGroup, nil, 2)
        
        -- See Also links
        AddSpace(20, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "profiles_importexport", label = L["Import/Export"]},
        }), 30, "both")
    end)
    
    -- Profiles > Import/Export
    local pageImportExport = CreateSubTab("profiles", "profiles_importexport", L["Import/Export"])
    BuildPage(pageImportExport, function(self, db, Add, AddSpace, AddSyncPoint)
        -- Store references
        self.exportCheckboxes = {}
        self.importCheckboxes = {}
        self.exportFrameTypes = {party = true, raid = true}
        self.importFrameTypes = {party = true, raid = true}
        
        local categoryOrder = {"position", "layout", "bars", "auras", "text", "icons", "other", "pinnedFrames", "auraDesigner", "autoLayout"}
        
        -- Helper to add to section
        local function AddToSection(widget, col, colNum)
            widget.layoutCol = colNum or col
            table.insert(self.children, widget)
        end
        
        -- Helper to create themed small checkbox
        local function CreateSmallCheckbox(parent, label, initialChecked)
            local container = CreateFrame("Frame", nil, parent)
            container:SetSize(100, 18)
            
            local cb = CreateFrame("CheckButton", nil, container, "BackdropTemplate")
            cb:SetSize(14, 14)
            cb:SetPoint("LEFT", 0, 0)
            cb:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            cb:SetBackdropColor(0.18, 0.18, 0.18, 1)
            cb:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
            
            cb.Check = cb:CreateTexture(nil, "OVERLAY")
            cb.Check:SetTexture("Interface\\Buttons\\WHITE8x8")
            local tc = GUI.GetThemeColor()
            cb.Check:SetVertexColor(tc.r, tc.g, tc.b)
            cb.Check:SetPoint("CENTER")
            cb.Check:SetSize(8, 8)
            cb:SetCheckedTexture(cb.Check)
            
            local txt = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            txt:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            txt:SetText(label)
            txt:SetTextColor(0.85, 0.85, 0.85)
            cb.label = txt
            
            cb:SetChecked(initialChecked or false)
            
            container.UpdateTheme = function()
                local c = GUI.GetThemeColor()
                cb.Check:SetVertexColor(c.r, c.g, c.b)
            end
            if not parent.ThemeListeners then parent.ThemeListeners = {} end
            table.insert(parent.ThemeListeners, container)
            
            container.checkbox = cb
            container.SetChecked = function(self, val) cb:SetChecked(val) end
            container.GetChecked = function(self) return cb:GetChecked() end
            container.Enable = function(self) cb:Enable(); container:SetAlpha(1) end
            container.Disable = function(self) cb:Disable(); container:SetAlpha(0.35) end
            
            return container
        end
        
        -- Helper to create small themed button
        local function CreateSmallButton(parent, text, width)
            local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
            btn:SetSize(width, 20)
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
            btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
            
            btn.text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(text)
            btn.text:SetTextColor(0.8, 0.8, 0.8)
            
            btn:SetScript("OnEnter", function(s) s:SetBackdropColor(0.25, 0.25, 0.25, 1) end)
            btn:SetScript("OnLeave", function(s) s:SetBackdropColor(0.15, 0.15, 0.15, 1) end)
            
            return btn
        end
        
        -- ========================================
        -- COLUMN 1: EXPORT
        -- ========================================
        
        -- Export Settings Group
        local exportSettingsGroup = GUI:CreateSettingsGroup(self.child, 260)
        exportSettingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Export Settings"]), 40)
        
        -- Profile name input
        local nameInput = GUI:CreateInput(self.child, L["Profile Name"], 240)
        local currentProfileName = (DF.db and DF.db.keys and DF.db.keys.profile) or "My Profile"
        nameInput.EditBox:SetText(currentProfileName)
        self.exportNameEdit = nameInput.EditBox
        exportSettingsGroup:AddWidget(nameInput, 50)
        
        -- Preset buttons row
        local presetRow = CreateFrame("Frame", nil, self.child)
        presetRow:SetSize(240, 24)
        
        local presets = {
            {name = "All", x = 0, cats = {"position", "layout", "bars", "auras", "text", "icons", "other"}},
            {name = "Look", x = 60, cats = {"bars", "auras", "text", "icons", "other"}},
            {name = "Layout", x = 120, cats = {"position", "layout"}},
            {name = "None", x = 180, cats = {}},
        }
        
        for _, p in ipairs(presets) do
            local btn = CreateSmallButton(presetRow, p.name, 56)
            btn:SetPoint("LEFT", p.x, 0)
            btn:SetScript("OnClick", function()
                local sel = {}
                for _, c in ipairs(p.cats) do sel[c] = true end
                for cat, cb in pairs(self.exportCheckboxes) do cb:SetChecked(sel[cat] or false) end
            end)
        end
        exportSettingsGroup:AddWidget(presetRow, 28)
        
        -- Frame types row
        local ftRow = CreateFrame("Frame", nil, self.child)
        ftRow:SetSize(240, 20)
        
        local partyExp = CreateSmallCheckbox(ftRow, "Party", true)
        partyExp:SetPoint("LEFT", 0, 0)
        partyExp.checkbox:SetScript("OnClick", function(s) self.exportFrameTypes.party = s:GetChecked() end)
        
        local raidExp = CreateSmallCheckbox(ftRow, "Raid", true)
        raidExp:SetPoint("LEFT", 80, 0)
        raidExp.checkbox:SetScript("OnClick", function(s) self.exportFrameTypes.raid = s:GetChecked() end)
        exportSettingsGroup:AddWidget(ftRow, 24)
        
        -- Categories
        for _, cat in ipairs(categoryOrder) do
            local info = DF.ExportCategoryInfo[cat]
            local catRow = CreateFrame("Frame", nil, self.child)
            catRow:SetSize(240, 18)
            
            local cb = CreateSmallCheckbox(catRow, info.name, true)
            cb:SetPoint("LEFT", 0, 0)
            self.exportCheckboxes[cat] = cb
            exportSettingsGroup:AddWidget(catRow, 20)
        end
        
        AddToSection(exportSettingsGroup, nil, 1)
        
        -- Export Actions Group
        local exportActionsGroup = GUI:CreateSettingsGroup(self.child, 260)
        exportActionsGroup:AddWidget(GUI:CreateHeader(self.child, L["Export"]), 40)
        
        -- Export button
        exportActionsGroup:AddWidget(GUI:CreateIconButton(self.child, "upload", L["Generate Export String"], 240, 26, function()
            local selectedCats = {}
            local allSelected = true
            for _, cat in ipairs(categoryOrder) do
                if self.exportCheckboxes[cat]:GetChecked() then
                    table.insert(selectedCats, cat)
                else
                    allSelected = false
                end
            end
            if allSelected then selectedCats = nil end
            
            local profileName = self.exportNameEdit:GetText()
            if profileName == "" then profileName = nil end
            
            local str = DF:ExportProfile(selectedCats, self.exportFrameTypes, profileName)
            if str and self.exportEditBox then
                self.exportEditBox:SetText(str)
                self.exportEditBox:HighlightText()
                self.exportEditBox:SetFocus()
                print("|cff00ff00DandersFrames:|r Export generated.")
            elseif not str then
                print("|cffff0000DandersFrames:|r Export failed - no string returned")
            end
        end), 32)
        
        -- Export text area
        local exportScrollContainer = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        exportScrollContainer:SetSize(240, 100)
        exportScrollContainer:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        exportScrollContainer:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
        exportScrollContainer:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        
        local exportScroll = CreateFrame("ScrollFrame", nil, exportScrollContainer, "ScrollFrameTemplate")
        exportScroll:SetPoint("TOPLEFT", 4, -4)
        exportScroll:SetPoint("BOTTOMRIGHT", -22, 4)
        GUI.StyleScrollBar(exportScroll)
        
        local exportEditBox = CreateFrame("EditBox", nil, exportScroll)
        exportEditBox:SetMultiLine(true)
        exportEditBox:SetFontObject(DFFontHighlightSmall)
        exportEditBox:SetWidth(210)
        exportEditBox:SetHeight(90)
        exportEditBox:SetAutoFocus(false)
        exportEditBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
        exportScroll:SetScrollChild(exportEditBox)
        self.exportEditBox = exportEditBox
        
        exportScrollContainer:EnableMouse(true)
        exportScrollContainer:SetScript("OnMouseDown", function() exportEditBox:SetFocus() end)
        exportScroll:EnableMouse(true)
        exportScroll:SetScript("OnMouseDown", function() exportEditBox:SetFocus() end)
        
        exportActionsGroup:AddWidget(exportScrollContainer, 105)
        
        -- Select All button
        exportActionsGroup:AddWidget(GUI:CreateButton(self.child, L["Select All Text"], 240, 24, function()
            if self.exportEditBox then 
                self.exportEditBox:HighlightText()
                self.exportEditBox:SetFocus()
            end
        end), 28)
        
        AddToSection(exportActionsGroup, nil, 1)
        
        -- ========================================
        -- COLUMN 2: IMPORT
        -- ========================================
        
        -- Import String Group
        local importStringGroup = GUI:CreateSettingsGroup(self.child, 260)
        importStringGroup:AddWidget(GUI:CreateHeader(self.child, L["Import String"]), 40)
        
        -- Import text area
        local importScrollContainer = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        importScrollContainer:SetSize(240, 80)
        importScrollContainer:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        importScrollContainer:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
        importScrollContainer:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        
        local importScroll = CreateFrame("ScrollFrame", nil, importScrollContainer, "ScrollFrameTemplate")
        importScroll:SetPoint("TOPLEFT", 4, -4)
        importScroll:SetPoint("BOTTOMRIGHT", -22, 4)
        GUI.StyleScrollBar(importScroll)
        
        local importEditBox = CreateFrame("EditBox", nil, importScroll)
        importEditBox:SetMultiLine(true)
        importEditBox:SetFontObject(DFFontHighlightSmall)
        importEditBox:SetWidth(210)
        importEditBox:SetHeight(70)
        importEditBox:SetAutoFocus(false)
        importEditBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
        importScroll:SetScrollChild(importEditBox)
        self.importEditBox = importEditBox
        
        importScrollContainer:EnableMouse(true)
        importScrollContainer:SetScript("OnMouseDown", function() importEditBox:SetFocus() end)
        importScroll:EnableMouse(true)
        importScroll:SetScript("OnMouseDown", function() importEditBox:SetFocus() end)
        
        importStringGroup:AddWidget(importScrollContainer, 85)
        
        -- Parse button
        importStringGroup:AddWidget(GUI:CreateButton(self.child, L["Parse String"], 240, 26, function()
            if not self.importEditBox then return end
            local str = self.importEditBox:GetText()
            if not str or str == "" then
                print("|cffff6666DandersFrames:|r Paste a string first.")
                return
            end
            
            local importData, errMsg = DF:ValidateImportString(str)
            if not importData then
                print("|cffff0000DandersFrames:|r " .. errMsg)
                if self.importInfoLabel then self.importInfoLabel:SetText("|cffff6666Error: " .. errMsg .. "|r") end
                return
            end
            
            self.parsedImportData = importData
            local info = DF:GetImportInfo(importData)
            
            if self.importInfoLabel then
                self.importInfoLabel:SetText(string.format("|cff00ff00OK|r v%s %s%s",
                    tostring(info.version),
                    info.hasParty and "[Party]" or "",
                    info.hasRaid and "[Raid]" or ""))
            end
            
            if self.importNameEdit and info.profileName then
                self.importNameEdit:SetText(info.profileName)
            end
            
            if self.createNewProfileCheck then
                self.createNewProfileCheck:Enable()
                self.createNewProfileCheck:SetChecked(true)
            end
            
            local availableCats = {}
            for _, cat in ipairs(info.detectedCategories) do availableCats[cat] = true end
            
            for cat, cb in pairs(self.importCheckboxes) do
                if availableCats[cat] then cb:Enable(); cb:SetChecked(true)
                else cb:Disable(); cb:SetChecked(false) end
            end
            
            if self.importPartyCheck then
                if info.hasParty then self.importPartyCheck:Enable() else self.importPartyCheck:Disable() end
                self.importPartyCheck:SetChecked(info.hasParty)
            end
            if self.importRaidCheck then
                if info.hasRaid then self.importRaidCheck:Enable() else self.importRaidCheck:Disable() end
                self.importRaidCheck:SetChecked(info.hasRaid)
            end
            
            print("|cff00ff00DandersFrames:|r Parsed. Select options and Import.")
        end), 30)
        
        -- Info label
        local infoLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        infoLabel:SetWidth(240)
        infoLabel:SetJustifyH("LEFT")
        infoLabel:SetText("|cff888888Paste string above, then Parse|r")
        self.importInfoLabel = infoLabel
        
        local infoContainer = CreateFrame("Frame", nil, self.child)
        infoContainer:SetSize(240, 18)
        infoLabel:SetParent(infoContainer)
        infoLabel:SetPoint("LEFT", 0, 0)
        importStringGroup:AddWidget(infoContainer, 22)
        
        AddToSection(importStringGroup, nil, 2)
        
        -- Import Settings Group
        local importSettingsGroup = GUI:CreateSettingsGroup(self.child, 260)
        importSettingsGroup:AddWidget(GUI:CreateHeader(self.child, L["Import Settings"]), 40)
        
        -- Profile name input for import
        local impNameInput = GUI:CreateInput(self.child, L["Profile Name"], 240)
        impNameInput.EditBox:SetText(L["Imported Profile"])
        self.importNameEdit = impNameInput.EditBox
        importSettingsGroup:AddWidget(impNameInput, 50)
        
        -- Create new profile checkbox
        local createNewRow = CreateFrame("Frame", nil, self.child)
        createNewRow:SetSize(240, 20)
        
        local createNewCheck = CreateSmallCheckbox(createNewRow, "Create New Profile", true)
        createNewCheck:SetPoint("LEFT", 0, 0)
        createNewCheck:Disable()
        self.createNewProfileCheck = createNewCheck
        importSettingsGroup:AddWidget(createNewRow, 24)
        
        -- Frame types row
        local ftRowImp = CreateFrame("Frame", nil, self.child)
        ftRowImp:SetSize(240, 20)
        
        local partyImp = CreateSmallCheckbox(ftRowImp, "Party", false)
        partyImp:SetPoint("LEFT", 0, 0)
        partyImp:Disable()
        partyImp.checkbox:SetScript("OnClick", function(s) self.importFrameTypes.party = s:GetChecked() end)
        self.importPartyCheck = partyImp
        
        local raidImp = CreateSmallCheckbox(ftRowImp, "Raid", false)
        raidImp:SetPoint("LEFT", 80, 0)
        raidImp:Disable()
        raidImp.checkbox:SetScript("OnClick", function(s) self.importFrameTypes.raid = s:GetChecked() end)
        self.importRaidCheck = raidImp
        importSettingsGroup:AddWidget(ftRowImp, 24)
        
        -- Categories
        for _, cat in ipairs(categoryOrder) do
            local info = DF.ExportCategoryInfo[cat]
            local catRow = CreateFrame("Frame", nil, self.child)
            catRow:SetSize(240, 18)
            
            local cb = CreateSmallCheckbox(catRow, info.name, false)
            cb:SetPoint("LEFT", 0, 0)
            cb:Disable()
            self.importCheckboxes[cat] = cb
            importSettingsGroup:AddWidget(catRow, 20)
        end
        
        AddToSection(importSettingsGroup, nil, 2)
        
        -- Import Actions Group
        local importActionsGroup = GUI:CreateSettingsGroup(self.child, 260)
        importActionsGroup:AddWidget(GUI:CreateHeader(self.child, L["Import"]), 40)
        
        -- Import button
        importActionsGroup:AddWidget(GUI:CreateIconButton(self.child, "download", L["Import Selected"], 240, 26, function()
            if not self.parsedImportData then
                print("|cffff6666DandersFrames:|r Parse a string first.")
                return
            end
            
            local selectedCats = {}
            for _, cat in ipairs(categoryOrder) do
                if self.importCheckboxes[cat]:GetChecked() then
                    table.insert(selectedCats, cat)
                end
            end
            
            if #selectedCats == 0 then
                print("|cffff6666DandersFrames:|r Select at least one category.")
                return
            end
            
            local selectedFrameTypes = {
                party = self.importPartyCheck:GetChecked(),
                raid = self.importRaidCheck:GetChecked(),
            }
            
            if not selectedFrameTypes.party and not selectedFrameTypes.raid then
                print("|cffff6666DandersFrames:|r Select Party or Raid.")
                return
            end
            
            local createNew = self.createNewProfileCheck and self.createNewProfileCheck:GetChecked()
            local profileName = self.importNameEdit and self.importNameEdit:GetText()
            if profileName == "" then profileName = nil end
            
            local confirmText
            if createNew then
                confirmText = "Create new profile '" .. (profileName or "Imported Profile") .. "'?\n\nThis will copy your current settings, then apply the selected import categories on top."
            else
                local currentProfile = DF:GetCurrentProfile() or "Default"
                confirmText = "Import settings into current profile?\n\n|cffff6666WARNING: This will permanently overwrite settings in your '" .. currentProfile .. "' profile.|r\n\nTip: Check 'Create New Profile' to import without affecting your current settings."
            end
            
            StaticPopupDialogs["DANDERSFRAMES_IMPORT_CONFIRM"] = {
                text = confirmText,
                button1 = L["Import"],
                button2 = L["Cancel"],
                OnAccept = function(dialog)
                    local data = dialog.data
                    if data and data.importData then
                        DF:ApplyImportedProfile(data.importData, data.selectedCats, data.selectedFrameTypes, data.profileName, data.createNew)
                        if GUI.RefreshCurrentPage then GUI:RefreshCurrentPage() end
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            
            local dialog = StaticPopup_Show("DANDERSFRAMES_IMPORT_CONFIRM")
            if dialog then
                dialog.data = {
                    importData = self.parsedImportData,
                    selectedCats = selectedCats,
                    selectedFrameTypes = selectedFrameTypes,
                    profileName = profileName,
                    createNew = createNew,
                }
            end
        end), 32)
        
        -- Clear button
        importActionsGroup:AddWidget(GUI:CreateIconButton(self.child, "close", L["Clear"], 240, 24, function()
            if self.importEditBox then self.importEditBox:SetText("") end
            if self.importInfoLabel then self.importInfoLabel:SetText("|cff888888Paste string above, then Parse|r") end
            if self.importNameEdit then self.importNameEdit:SetText(L["Imported Profile"]) end
            if self.createNewProfileCheck then self.createNewProfileCheck:Disable(); self.createNewProfileCheck:SetChecked(true) end
            for _, cb in pairs(self.importCheckboxes) do cb:SetChecked(false); cb:Disable() end
            if self.importPartyCheck then self.importPartyCheck:Disable(); self.importPartyCheck:SetChecked(false) end
            if self.importRaidCheck then self.importRaidCheck:Disable(); self.importRaidCheck:SetChecked(false) end
            self.parsedImportData = nil
        end), 28)
        
        AddToSection(importActionsGroup, nil, 2)
        
        -- See Also
        AddSpace(15, "both")
        Add(GUI:CreateSeeAlso(self.child, {
            {pageId = "profiles_manage", label = L["Manage Profiles"]},
        }), 30, "both")
    end)

    -- ========================================
    -- CATEGORY: Wizards
    -- ========================================
    -- Wizards category hidden for now (builder still in development)
    -- CreateCategory("wizards", "Wizards")

    -- Wizards > Setup Wizards (launcher/manager page) — disabled while category is hidden
    if false then
    local pageWizards = CreateSubTab("wizards", "wizards_main", L["Setup Wizards"])
    BuildPage(pageWizards, function(self, db, Add, AddSpace, AddSyncPoint)
        -- ============ BUILT-IN WIZARDS ============
        Add(GUI:CreateHeader(self.child, L["Built-in Wizards"]), 40, "both")

        -- Built-in wizard registry
        local builtins = DF.WizardBuilder and DF.WizardBuilder.GetBuiltinWizards and DF.WizardBuilder:GetBuiltinWizards() or {}

        if #builtins == 0 then
            Add(GUI:CreateLabel(self.child, L["No built-in wizards available yet. Check back after updates!"], 460), 24, "both")
        else
            for _, entry in ipairs(builtins) do
                local row = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
                row:SetSize(460, 50)
                if not row.SetBackdrop then Mixin(row, BackdropTemplateMixin) end
                row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
                row:SetBackdropColor(0.14, 0.14, 0.14, 1)
                row:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)

                local nameText = row:CreateFontString(nil, "OVERLAY", "DFFontNormal")
                nameText:SetPoint("TOPLEFT", 12, -8)
                nameText:SetText(entry.name)
                nameText:SetTextColor(0.9, 0.9, 0.9)

                local descText = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                descText:SetPoint("TOPLEFT", 12, -24)
                descText:SetPoint("RIGHT", row, "RIGHT", -90, 0)
                descText:SetText(entry.description or "")
                descText:SetTextColor(0.6, 0.6, 0.6)
                descText:SetJustifyH("LEFT")

                local runBtn = GUI:CreateButton(row, L["Run"], 70, 28, function()
                    if entry.build then
                        local config = entry.build()
                        if config then DF:ShowPopupWizard(config) end
                    end
                end)
                runBtn:SetPoint("RIGHT", -8, 0)

                Add(row, 54, "both")
            end
        end

        AddSpace(16, "both")

        -- ============ MY WIZARDS ============
        Add(GUI:CreateHeader(self.child, L["My Wizards"]), 40, "both")

        local configs = DandersFramesDB_v2 and DandersFramesDB_v2.wizardConfigs or {}
        local sortedNames = {}
        for name in pairs(configs) do
            tinsert(sortedNames, name)
        end
        table.sort(sortedNames)

        if #sortedNames == 0 then
            Add(GUI:CreateLabel(self.child, L["No custom wizards yet. Click 'New Wizard' to create one!"], 460), 24, "both")
        else
            for _, name in ipairs(sortedNames) do
                local config = configs[name]
                local row = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
                row:SetSize(460, 50)
                if not row.SetBackdrop then Mixin(row, BackdropTemplateMixin) end
                row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
                row:SetBackdropColor(0.14, 0.14, 0.14, 1)
                row:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)

                local nameText = row:CreateFontString(nil, "OVERLAY", "DFFontNormal")
                nameText:SetPoint("TOPLEFT", 12, -8)
                nameText:SetText(config.title or name)
                nameText:SetTextColor(0.9, 0.9, 0.9)

                local descText = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                descText:SetPoint("TOPLEFT", 12, -24)
                descText:SetPoint("RIGHT", row, "RIGHT", -240, 0)
                descText:SetText(config.description or "")
                descText:SetTextColor(0.6, 0.6, 0.6)
                descText:SetJustifyH("LEFT")

                local btnX = -8

                -- Delete button
                local delBtn = GUI:CreateButton(row, L["Del"], 40, 24, function()
                    if DandersFramesDB_v2 and DandersFramesDB_v2.wizardConfigs then
                        DandersFramesDB_v2.wizardConfigs[name] = nil
                    end
                    pageWizards:Refresh()
                    if pageWizards.RefreshStates then pageWizards:RefreshStates() end
                end)
                delBtn:SetPoint("RIGHT", btnX, 0)
                btnX = btnX - 44

                -- Export button
                local exportBtn = GUI:CreateButton(row, L["Export"], 50, 24, function()
                    if DF.WizardBuilder then
                        local str, err = DF.WizardBuilder:ExportWizard(name)
                        if str then
                            -- Copy to clipboard via editbox
                            DF:ShowPopupAlert({
                                title = "Export Wizard",
                                message = "Wizard exported! Press Ctrl+C to copy the string below.",
                                width = 500,
                            })
                        else
                            print("|cffff0000DandersFrames:|r Export failed: " .. (err or "unknown"))
                        end
                    end
                end)
                exportBtn:SetPoint("RIGHT", delBtn, "LEFT", -4, 0)
                btnX = btnX - 54

                -- Edit button (opens builder popup)
                local editBtn = GUI:CreateButton(row, L["Edit"], 40, 24, function()
                    if DF.ShowWizardBuilder then
                        DF:ShowWizardBuilder(name, function()
                            pageWizards:Refresh()
                            if pageWizards.RefreshStates then pageWizards:RefreshStates() end
                        end)
                    end
                end)
                editBtn:SetPoint("RIGHT", exportBtn, "LEFT", -4, 0)
                btnX = btnX - 44

                -- Run button
                local runBtn = GUI:CreateButton(row, L["Run"], 40, 24, function()
                    if DF.WizardBuilder then
                        local wizConfig = DF.WizardBuilder.BuildWizardConfig and DF.WizardBuilder.BuildWizardConfig(config)
                        if not wizConfig then
                            -- Fallback: build manually
                            wizConfig = {
                                title = config.title or config.name or "Wizard",
                                width = config.width or 440,
                                steps = DF:DeepCopy(config.steps),
                                settingsMap = config.settingsMap,
                                onComplete = function() DF:Debug("Wizard complete") end,
                            }
                        end
                        DF:ShowPopupWizard(wizConfig)
                    end
                end)
                runBtn:SetPoint("RIGHT", editBtn, "LEFT", -4, 0)

                Add(row, 54, "both")
            end
        end

        AddSpace(12, "both")

        -- Action buttons row
        local btnRow = CreateFrame("Frame", nil, self.child)
        btnRow:SetSize(460, 30)

        -- New Wizard button
        local newBtn = GUI:CreateButton(btnRow, L["+ New Wizard"], 120, 28, function()
            -- Generate unique name
            local baseName = "New Wizard"
            local wizName = baseName
            local counter = 1
            local existingConfigs = DandersFramesDB_v2 and DandersFramesDB_v2.wizardConfigs or {}
            while existingConfigs[wizName] do
                counter = counter + 1
                wizName = baseName .. " " .. counter
            end
            if DF.ShowWizardBuilder then
                DF:ShowWizardBuilder(wizName, function()
                    pageWizards:Refresh()
                    if pageWizards.RefreshStates then pageWizards:RefreshStates() end
                end)
            end
        end)
        newBtn:SetPoint("LEFT", 0, 0)

        -- Import button
        local importBtn = GUI:CreateButton(btnRow, L["Import"], 80, 28, function()
            DF:ShowPopupAlert({
                title = "Import Wizard",
                message = "Paste a wizard export string in chat with:\n/df importwizard <string>",
            })
        end)
        importBtn:SetPoint("LEFT", newBtn, "RIGHT", 8, 0)

        Add(btnRow, 34, "both")
    end)
    end  -- if false (wizards tab hidden)

    -- ========================================
    -- CATEGORY: Debug
    -- ========================================
    CreateCategory("debug", L["Debug"])

    -- Single page containing four collapsible sections in workflow order:
    -- Settings -> Categories -> Live Log -> Script Runner.
    -- All sections are collapsible and start expanded.
    local pageDebugConsole = CreateSubTab("debug", "debug_console", L["Console"])
    BuildPage(pageDebugConsole, function(self, db, Add, AddSpace, AddSyncPoint)

        -- Proxy for dropdown/slider keys (they don't support customGet/customSet)
        local debugProxy = setmetatable({}, {
            __index = function(_, k)
                return DandersFramesDB_v2 and DandersFramesDB_v2.debug and DandersFramesDB_v2.debug[k]
            end,
            __newindex = function(_, k, v)
                if DandersFramesDB_v2 and DandersFramesDB_v2.debug then
                    DandersFramesDB_v2.debug[k] = v
                end
            end,
        })

        -- Tracks the currently-open collapsible section so AddToSection() can
        -- automatically register subsequent widgets as its children.
        local currentSection = nil

        local function AddToSection(widget, height, col)
            Add(widget, height, col)
            if currentSection then
                currentSection:RegisterChild(widget)
            end
            return widget
        end

        -- ============================================================
        -- 1) SETTINGS SECTION
        -- ============================================================
        local settingsSection = Add(GUI:CreateCollapsibleSection(self.child, L["Settings"], true), 36, "both")
        currentSection = settingsSection

        AddToSection(GUI:CreateCheckbox(self.child, L["Enable Debug Logging"], nil, nil, function()
            if DF.DebugConsole then DF.DebugConsole:RefreshDisplay() end
        end, function()
            return DandersFramesDB_v2 and DandersFramesDB_v2.debug and DandersFramesDB_v2.debug.enabled or false
        end, function(val)
            if DF.DebugConsole then
                DF.DebugConsole:SetEnabled(val)
            elseif DandersFramesDB_v2 and DandersFramesDB_v2.debug then
                DandersFramesDB_v2.debug.enabled = val
            end
        end), 28, "both")

        AddToSection(GUI:CreateCheckbox(self.child, L["Echo to Chat"], nil, nil, nil, function()
            return DandersFramesDB_v2 and DandersFramesDB_v2.debug and DandersFramesDB_v2.debug.chatEcho or false
        end, function(val)
            if DandersFramesDB_v2 and DandersFramesDB_v2.debug then
                DandersFramesDB_v2.debug.chatEcho = val
            end
        end), 28, "both")

        local logLevelOptions = {
            ["INFO"]  = L["Info (All)"],
            ["WARN"]  = L["Warnings + Errors"],
            ["ERROR"] = L["Errors Only"],
        }
        AddToSection(GUI:CreateDropdown(self.child, L["Minimum Log Level"], logLevelOptions, debugProxy, "logLevel", function()
            if DF.DebugConsole then DF.DebugConsole:RefreshDisplay() end
        end), 55, 1)

        AddToSection(GUI:CreateSlider(self.child, L["Max Log Entries"], 100, 10000, 100, debugProxy, "maxLines", function()
            if DF.DebugConsole then
                DF.DebugConsole:PruneLog()
                DF.DebugConsole:RefreshDisplay()
            end
        end), 55, 2)

        AddSyncPoint()

        -- ============================================================
        -- 2) LOGGED CATEGORIES SECTION
        -- ============================================================
        local categoriesSection = Add(GUI:CreateCollapsibleSection(self.child, L["Logged Categories"], true), 36, "both")
        currentSection = categoriesSection

        AddToSection(GUI:CreateLabel(self.child, "|cff888888" .. L["Unchecked categories are not logged at all. Disable noisy categories before reproducing a bug to keep the buffer focused."] .. "|r", 540), 36, "both")

        -- All / None buttons row
        local filterBtnRow = CreateFrame("Frame", nil, self.child)
        filterBtnRow:SetSize(540, 24)

        local function CollectAllCategories()
            local set = {}
            if DF.DebugConsole then
                for _, g in ipairs(DF.DebugConsole:GetCategoryGroups()) do
                    for _, cat in ipairs(g.categories) do
                        set[cat.key] = true
                    end
                end
                for cat in pairs(DF.DebugConsole:GetKnownCategories()) do
                    set[cat] = true
                end
            end
            return set
        end

        -- Track all created rows so All/None can refresh their visual state
        self.filterRows = {}
        local function RefreshAllRows()
            for _, row in pairs(self.filterRows) do
                if row.RefreshState then row:RefreshState() end
            end
            if DF.DebugConsole then DF.DebugConsole:RefreshDisplay() end
        end

        local btnAll = GUI:CreateButton(filterBtnRow, L["All"], 60, 22, function()
            if DandersFramesDB_v2 and DandersFramesDB_v2.debug then
                local filters = DandersFramesDB_v2.debug.filters
                for cat in pairs(CollectAllCategories()) do
                    filters[cat] = true
                end
            end
            RefreshAllRows()
        end)
        btnAll:SetPoint("LEFT", 0, 0)

        local btnNone = GUI:CreateButton(filterBtnRow, L["None"], 60, 22, function()
            if DandersFramesDB_v2 and DandersFramesDB_v2.debug then
                local filters = DandersFramesDB_v2.debug.filters
                for cat in pairs(CollectAllCategories()) do
                    filters[cat] = false
                end
            end
            RefreshAllRows()
        end)
        btnNone:SetPoint("LEFT", btnAll, "RIGHT", 6, 0)

        AddToSection(filterBtnRow, 28, "both")

        if DF.DebugConsole then
            local groups = DF.DebugConsole:GetCategoryGroups()
            for _, group in ipairs(groups) do
                local groupLabel = L[group.name] or group.name
                AddToSection(GUI:CreateLabel(self.child, "|cffeda55f" .. groupLabel .. "|r", 540), 22, "both")
                for _, cat in ipairs(group.categories) do
                    local row = GUI:CreateDebugCategoryRow(self.child, cat.key, cat.desc, 540)
                    self.filterRows[cat.key] = row
                    AddToSection(row, 28, "both")
                end
            end

            -- Append auto-discovered categories that aren't in the registry
            local registered = DF.DebugConsole:GetRegisteredCategorySet()
            local known = DF.DebugConsole:GetKnownCategories()
            local extras = {}
            for cat in pairs(known) do
                if not registered[cat] then
                    tinsert(extras, cat)
                end
            end
            if #extras > 0 then
                table.sort(extras)
                AddToSection(GUI:CreateLabel(self.child, "|cffeda55f" .. L["Discovered"] .. "|r", 540), 22, "both")
                for _, cat in ipairs(extras) do
                    local row = GUI:CreateDebugCategoryRow(self.child, cat, nil, 540)
                    self.filterRows[cat] = row
                    AddToSection(row, 28, "both")
                end
            end
        end

        AddSyncPoint()

        -- ============================================================
        -- 3) LIVE LOG SECTION
        -- ============================================================
        local logSection = Add(GUI:CreateCollapsibleSection(self.child, L["Live Log"], true), 36, "both")
        currentSection = logSection

        -- Entry count label
        local entryCountLabel = GUI:CreateLabel(self.child, "", 540)
        local function UpdateEntryCount()
            local count = DF.DebugConsole and DF.DebugConsole:GetLogEntryCount() or 0
            entryCountLabel:SetText("|cff888888" .. format(L["Log entries: %d"], count) .. "|r")
        end
        UpdateEntryCount()
        AddToSection(entryCountLabel, 20, "both")

        -- Action buttons row (Refresh / Clear Log / Copy to Clipboard)
        local actionRow = CreateFrame("Frame", nil, self.child)
        actionRow:SetSize(540, 28)

        local refreshBtn = GUI:CreateButton(actionRow, L["Refresh"], 100, 24, function()
            if DF.DebugConsole then
                DF.DebugConsole:RefreshDisplay()
                UpdateEntryCount()
            end
        end)
        refreshBtn:SetPoint("LEFT", 0, 0)

        local clearBtn = GUI:CreateButton(actionRow, L["Clear Log"], 100, 24, function()
            if DF.DebugConsole then
                DF.DebugConsole:ClearLog()
                UpdateEntryCount()
            end
        end)
        clearBtn:SetPoint("LEFT", refreshBtn, "RIGHT", 6, 0)

        local copyBtn = GUI:CreateButton(actionRow, L["Copy to Clipboard"], 140, 24, function()
            if not DF.DebugConsole then return end
            local text = DF.DebugConsole:GetExportText()

            local popup = CreateFrame("Frame", "DFDebugExportPopup", UIParent, "BackdropTemplate")
            popup:SetSize(500, 350)
            popup:SetPoint("CENTER")
            popup:SetFrameStrata("DIALOG")
            popup:SetFrameLevel(200)
            if not popup.SetBackdrop then Mixin(popup, BackdropTemplateMixin) end
            popup:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
            popup:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            popup:EnableMouse(true)
            popup:SetMovable(true)
            popup:RegisterForDrag("LeftButton")
            popup:SetScript("OnDragStart", popup.StartMoving)
            popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

            local title = popup:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
            title:SetPoint("TOP", 0, -10)
            title:SetText(L["Debug Log Export (Filtered)"])
            title:SetTextColor(0.9, 0.9, 0.9)

            local instructions = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            instructions:SetPoint("TOP", title, "BOTTOM", 0, -4)
            instructions:SetText(L["Press Ctrl+A to select all, then Ctrl+C to copy"])
            instructions:SetTextColor(0.6, 0.6, 0.6)

            local scrollContainer = CreateFrame("Frame", nil, popup, "BackdropTemplate")
            scrollContainer:SetPoint("TOPLEFT", 12, -45)
            scrollContainer:SetPoint("BOTTOMRIGHT", -12, 40)
            scrollContainer:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            scrollContainer:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
            scrollContainer:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

            local scroll = CreateFrame("ScrollFrame", nil, scrollContainer, "ScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", 4, -4)
            scroll:SetPoint("BOTTOMRIGHT", -22, 4)
            GUI.StyleScrollBar(scroll)

            local editBox = CreateFrame("EditBox", nil, scroll)
            editBox:SetMultiLine(true)
            editBox:SetFontObject(DFFontHighlightSmall)
            editBox:SetWidth(440)
            editBox:SetAutoFocus(true)
            editBox:SetScript("OnEscapePressed", function() popup:Hide() end)
            scroll:SetScrollChild(editBox)

            editBox:SetText(text)
            editBox:HighlightText()

            local closeBtn = GUI:CreateButton(popup, L["Close"], 80, 24, function() popup:Hide() end)
            closeBtn:SetPoint("BOTTOM", 0, 10)

            popup:SetScript("OnHide", function(s)
                s:SetParent(nil)
                s:ClearAllPoints()
            end)
        end)
        copyBtn:SetPoint("LEFT", clearBtn, "RIGHT", 6, 0)

        AddToSection(actionRow, 32, "both")

        -- Full-width log viewer
        local logScrollContainer = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        logScrollContainer:SetSize(540, 480)
        logScrollContainer:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        logScrollContainer:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
        logScrollContainer:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

        local logScroll = CreateFrame("ScrollFrame", nil, logScrollContainer, "ScrollFrameTemplate")
        logScroll:SetPoint("TOPLEFT", 4, -4)
        logScroll:SetPoint("BOTTOMRIGHT", -22, 4)
        GUI.StyleScrollBar(logScroll)

        local logEditBox = CreateFrame("EditBox", nil, logScroll)
        logEditBox:SetMultiLine(true)
        logEditBox:SetFontObject(DFFontHighlightSmall)
        logEditBox:SetWidth(510)
        logEditBox:SetHeight(470)
        logEditBox:SetAutoFocus(false)
        logEditBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
        logEditBox:SetScript("OnTextChanged", function(s, userInput)
            if userInput and DF.DebugConsole then
                DF.DebugConsole:RefreshDisplay()
            end
        end)
        logScroll:SetScrollChild(logEditBox)

        logScrollContainer:EnableMouse(true)
        logScrollContainer:SetScript("OnMouseDown", function() logEditBox:SetFocus() end)
        logScroll:EnableMouse(true)
        logScroll:SetScript("OnMouseDown", function() logEditBox:SetFocus() end)

        AddToSection(logScrollContainer, 485, "both")

        -- Register live EditBox with DebugConsole
        if DF.DebugConsole then
            DF.DebugConsole:SetLiveEditBox(logEditBox)
            DF.DebugConsole:RefreshDisplay()
            UpdateEntryCount()
        end

        -- Unregister on page hide
        self:SetScript("OnHide", function()
            if DF.DebugConsole then
                DF.DebugConsole:SetLiveEditBox(nil)
            end
        end)

        AddSyncPoint()

        -- ============================================================
        -- 4) SCRIPT RUNNER SECTION (developer-only utility, unrelated)
        -- ============================================================
        local scriptSection = Add(GUI:CreateCollapsibleSection(self.child, L["Script Runner"], true), 36, "both")
        currentSection = scriptSection

        local scriptScrollContainer = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
        scriptScrollContainer:SetSize(540, 120)
        scriptScrollContainer:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        scriptScrollContainer:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
        scriptScrollContainer:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

        local scriptScroll = CreateFrame("ScrollFrame", nil, scriptScrollContainer, "ScrollFrameTemplate")
        scriptScroll:SetPoint("TOPLEFT", 4, -4)
        scriptScroll:SetPoint("BOTTOMRIGHT", -22, 4)
        GUI.StyleScrollBar(scriptScroll)

        local scriptEditBox = CreateFrame("EditBox", nil, scriptScroll)
        scriptEditBox:SetMultiLine(true)
        scriptEditBox:SetFontObject(DFFontHighlightSmall)
        scriptEditBox:SetWidth(510)
        scriptEditBox:SetHeight(112)
        scriptEditBox:SetAutoFocus(false)
        scriptEditBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
        scriptEditBox:SetScript("OnTextChanged", function(s, userInput)
            if userInput and DandersFramesDB_v2 and DandersFramesDB_v2.debug then
                DandersFramesDB_v2.debug.lastScript = s:GetText()
            end
        end)
        scriptScroll:SetScrollChild(scriptEditBox)

        if DandersFramesDB_v2 and DandersFramesDB_v2.debug and DandersFramesDB_v2.debug.lastScript then
            scriptEditBox:SetText(DandersFramesDB_v2.debug.lastScript)
        end

        scriptScrollContainer:EnableMouse(true)
        scriptScrollContainer:SetScript("OnMouseDown", function() scriptEditBox:SetFocus() end)
        scriptScroll:EnableMouse(true)
        scriptScroll:SetScript("OnMouseDown", function() scriptEditBox:SetFocus() end)

        AddToSection(scriptScrollContainer, 125, "both")

        local scriptStatusLabel = GUI:CreateLabel(self.child, "", 540)
        AddToSection(scriptStatusLabel, 20, "both")

        AddToSection(GUI:CreateButton(self.child, L["Run Script"], 540, 26, function()
            local code = scriptEditBox:GetText()
            if not code or code == "" then
                scriptStatusLabel:SetText("|cff666666No script to run.|r")
                return
            end
            local fn, err = loadstring(code)
            if not fn then
                scriptStatusLabel:SetText("|cffff6666Error: " .. tostring(err) .. "|r")
                DF:DebugError("SCRIPT", "Compile error: %s", tostring(err))
                return
            end
            local ok, result = pcall(fn)
            if ok then
                if result ~= nil then
                    scriptStatusLabel:SetText("|cff88ccffResult: " .. tostring(result) .. "|r")
                else
                    scriptStatusLabel:SetText("|cff88ff88Script executed successfully.|r")
                end
            else
                scriptStatusLabel:SetText("|cffff6666Runtime: " .. tostring(result) .. "|r")
                DF:DebugError("SCRIPT", "Runtime error: %s", tostring(result))
            end
        end), 32, "both")

        currentSection = nil
    end)

end
