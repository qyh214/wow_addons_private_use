local addonName, DF = ...
local GUI = {}
DF.GUI = GUI
local L = DF.L

-- =========================================================================
-- MODERN UI CONSTANTS & STYLING (Matching Original v2.3.8)
-- =========================================================================

local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08, a = 0.95}  -- Dark charcoal
local C_PANEL      = {r = 0.12, g = 0.12, b = 0.12, a = 1}     -- Slightly lighter
local C_ELEMENT    = {r = 0.18, g = 0.18, b = 0.18, a = 1}     -- Element backgrounds
local C_BORDER     = {r = 0.25, g = 0.25, b = 0.25, a = 1}     -- Subtle borders
local C_ACCENT     = {r = 0.45, g = 0.45, b = 0.95, a = 1}       -- Party Purple-Blue
local C_RAID       = {r = 1.0, g = 0.5, b = 0.2, a = 1}        -- Raid Orange
local C_HOVER      = {r = 0.22, g = 0.22, b = 0.22, a = 1}
local C_TEXT       = {r = 0.9, g = 0.9, b = 0.9, a = 1}
local C_TEXT_DIM   = {r = 0.6, g = 0.6, b = 0.6, a = 1}

DF.SectionRegistry = DF.SectionRegistry or {}

-- Track selected mode
GUI.SelectedMode = "party"

-- Registry of tabs that should show a "New" badge until opened.
-- Add tab IDs here for new features; the badge auto-hides once viewed.
GUI.NewTabs = {
    ["indicators_targetedlist"] = true,
    ["general_pinnedframes"] = true,
    ["auras_dispel"] = true,
}

-- Registry of section headers (inside a tab) that should show a "New" badge
-- until the user visits the tab and then navigates away. Keyed by
-- "<tabName>.<sectionId>" so entries are unambiguous across tabs.
-- The badge is created by GUI:AddSectionNewBadge and cleared by SelectTab
-- when the user leaves the owning tab (persisted via seenSections).
GUI.NewSections = {
    ["general_pinnedframes.frameType"] = true,
    ["auras_dispel.overlaySource"] = true,
}

-- Live-tracked badges pending a "seen" mark, keyed by tabName → { key = badge }.
-- Populated by AddSectionNewBadge, drained by SelectTab on tab leave.
GUI.pendingSectionBadges = {}

-- Add a gold "New" badge to the right of a section header's text. Returns the
-- badge FontString, or nil if the section isn't registered in NewSections or
-- has already been marked seen. The badge clears (and is persisted as seen)
-- the next time the user navigates away from `tabName`.
function GUI:AddSectionNewBadge(widget, tabName, sectionId)
    -- Anchor to whichever label FontString the widget exposes:
    --   * CreateHeader containers use `.text`
    --   * CreateDropdown containers use `.label`
    local anchor = widget and (widget.text or widget.label)
    if not anchor or not tabName or not sectionId then return end
    local key = tabName .. "." .. sectionId
    if not GUI.NewSections[key] then return end

    local seen = DandersFramesDB_v2 and DandersFramesDB_v2.seenSections
                 and DandersFramesDB_v2.seenSections[key]
    if seen then return end

    local badge = widget:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    badge:SetPoint("LEFT", anchor, "RIGHT", 6, 0)
    badge:SetText(L["New"])
    badge:SetTextColor(1, 0.82, 0)

    GUI.pendingSectionBadges[tabName] = GUI.pendingSectionBadges[tabName] or {}
    GUI.pendingSectionBadges[tabName][key] = badge
    return badge
end

-- Pages that remain fully accessible regardless of whether party or raid
-- mode is disabled via General settings. All other mode-specific tabs
-- are greyed out and non-interactive when viewing a disabled mode.
-- Auto Layouts is intentionally NOT whitelisted: it edits per-profile
-- settings that would have no effect if all frames are disabled.
GUI.AlwaysAccessiblePages = {
    ["general_settings"]             = true,  -- the toggles themselves
    ["profiles_manage"]              = true,
    ["profiles_importexport"]        = true,
    ["debug_console"]                = true,
    ["indicators_targetedlist"]      = true,
    ["indicators_personal_targeted"] = true,
}

-- Returns true if the given tab should be disabled for the currently
-- selected mode (i.e. the tab is mode-specific and that mode is off).
function GUI:IsTabDisabledForCurrentMode(tabName)
    if not tabName then return false end
    if GUI.AlwaysAccessiblePages[tabName] then return false end
    if GUI.SelectedMode == "party" and DF.db and DF.db.partyEnabled == false then return true end
    if GUI.SelectedMode == "raid"  and DF.db and DF.db.raidEnabled  == false then return true end
    return false
end

-- Walk all registered tabs and update their .disabled flag + visuals
-- based on the current mode and enable flags. Call after mode switches.
function GUI:UpdateTabAvailability()
    if not GUI.Tabs then return end
    for name, btn in pairs(GUI.Tabs) do
        local disabled = GUI:IsTabDisabledForCurrentMode(name)
        btn.disabled = disabled
        if btn.Text then
            if disabled then
                btn.Text:SetTextColor(0.45, 0.45, 0.45)
            else
                btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end
        end
        if disabled and not btn.isActive then
            btn:SetBackdropColor(0, 0, 0, 0)
        end
    end
end

-- Track currently open dropdown menu (only one can be open at a time)
local currentOpenDropdown = nil

-- Close any currently open dropdown
local function CloseOpenDropdown()
    if currentOpenDropdown and currentOpenDropdown:IsShown() then
        currentOpenDropdown:Hide()
    end
    currentOpenDropdown = nil
end

-- Set the currently open dropdown
local function SetOpenDropdown(menuFrame)
    CloseOpenDropdown()
    currentOpenDropdown = menuFrame
end

-- Helper to get current theme color
local function GetThemeColor()
    if GUI.SelectedMode == "raid" then return C_RAID else return C_ACCENT end
end
GUI.GetThemeColor = GetThemeColor

-- Helper to create element backdrop (for dropdowns, sliders, inputs)
local function CreateElementBackdrop(frame)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, C_ELEMENT.a)
    frame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
end

-- Helper to create panel backdrop (for main panels)
local function CreatePanelBackdrop(frame)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, C_BACKGROUND.a)
    frame:SetBackdropBorderColor(0, 0, 0, 1)
end
GUI.CreatePanelBackdrop = CreatePanelBackdrop

-- Style a ScrollFrameTemplate scrollbar to use the pill-shaped thumb
-- All scroll frames must use ScrollFrameTemplate (not UIPanelScrollFrameTemplate)
local function StyleScrollBar(scrollFrame)
    local sb = scrollFrame.ScrollBar
    if not sb then return end

    -- Hide track background and track end caps
    if sb.Background then sb.Background:Hide() end
    if sb.Track then
        if sb.Track.Begin then sb.Track.Begin:Hide() end
        if sb.Track.End then sb.Track.End:Hide() end
        if sb.Track.Middle then sb.Track.Middle:Hide() end
    end

    -- Style the pill-shaped thumb — hide default textures, overlay with themed color
    if sb.Thumb then
        if sb.Thumb.Begin then sb.Thumb.Begin:Hide() end
        if sb.Thumb.End then sb.Thumb.End:Hide() end
        if sb.Thumb.Middle then sb.Thumb.Middle:Hide() end
        if not sb.Thumb.customBg then
            local thumb = sb.Thumb:CreateTexture(nil, "ARTWORK")
            thumb:SetAllPoints()
            thumb:SetColorTexture(0.4, 0.4, 0.4, 0.8)
            sb.Thumb.customBg = thumb
        end
    end

    -- Hide navigation buttons
    if sb.Back then sb.Back:Hide() sb.Back:SetSize(1, 1) end
    if sb.Forward then sb.Forward:Hide() sb.Forward:SetSize(1, 1) end

    -- Slim width
    sb:SetWidth(10)
end
GUI.StyleScrollBar = StyleScrollBar

-- =========================================================================
-- WIDGET FACTORY
-- =========================================================================

function GUI:CreateHeader(parent, text)
    -- Use a frame container so we can position text at bottom (padding above)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 25)
    container:Show()
    
    local h = container:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    h:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 2)
    h:SetText(text)
    local c = GetThemeColor()
    h:SetTextColor(c.r, c.g, c.b)
    h:SetJustifyH("LEFT")
    h.UpdateTheme = function() local nc = GetThemeColor() h:SetTextColor(nc.r, nc.g, nc.b) end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, h)
    
    -- Store text reference
    container.text = h
    
    -- Forward IsShown to ensure layout works
    container.GetText = function() return h:GetText() end
    
    -- SEARCH: Track current section
    if DF.Search then
        DF.Search:SetCurrentSection(text)
    end
    
    return container
end

-- Collapsible section for grouping related settings.
-- Collapsed state is persisted in DandersFramesDB_v2.collapsedGroups keyed by
-- `text` (shared store with CreateSettingsGroup's collapsible header), so the
-- user's fold preference survives reloads.
function GUI:CreateCollapsibleSection(parent, text, defaultExpanded, width)
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    section:SetSize(width or 500, 28)  -- Header height
    -- Resolve initial expanded state: SavedVariables override the default.
    local savedStates = GUI:GetCollapsedGroups()
    if text and savedStates[text] ~= nil then
        section.expanded = not savedStates[text]
    else
        section.expanded = defaultExpanded ~= false
    end
    section.sectionTitleText = text
    section.sectionChildren = {}
    section.paddingAfter = 8  -- Padding space after header before first child
    
    -- Header bar with background
    if not section.SetBackdrop then Mixin(section, BackdropTemplateMixin) end
    section:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    section:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.8)
    section:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    -- Click area
    local clickArea = CreateFrame("Button", nil, section)
    clickArea:SetAllPoints()
    clickArea:EnableMouse(true)
    
    -- Expand/collapse arrow icon
    section.arrow = section:CreateTexture(nil, "OVERLAY")
    section.arrow:SetPoint("LEFT", 8, 0)
    section.arrow:SetSize(12, 12)
    if section.expanded then
        section.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    else
        section.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
    end
    section.arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Section title
    section.title = section:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    section.title:SetPoint("LEFT", 26, 0)
    section.title:SetText(text)
    local c = GetThemeColor()
    section.title:SetTextColor(c.r, c.g, c.b)
    section.title.UpdateTheme = function()
        local nc = GetThemeColor()
        section.title:SetTextColor(nc.r, nc.g, nc.b)
    end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, section.title)

    -- Optional inline tag — small yellow text placed after the title to
    -- stand out as a status summary (e.g. "[Normal Dispels]"). Call
    -- section:SetTag(text) at any time; pass nil or empty string to clear.
    section.tag = section:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    section.tag:SetPoint("LEFT", section.title, "RIGHT", 8, 0)
    section.tag:SetTextColor(1, 0.82, 0, 1)  -- WoW standard gold/yellow
    section.tag:SetText("")
    section.SetTag = function(self, text)
        if text and text ~= "" then
            self.tag:SetText(text)
            self.tag:Show()
        else
            self.tag:SetText("")
            self.tag:Hide()
        end
    end

    -- SEARCH: Track current section
    if DF.Search then
        DF.Search:SetCurrentSection(text)
    end
    
    -- Toggle function
    section.Toggle = function(self)
        self.expanded = not self.expanded
        if self.expanded then
            self.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
        else
            self.arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
        end
        -- Persist collapsed state to SavedVariables (only store true, remove when expanded)
        if self.sectionTitleText then
            local saved = GUI:GetCollapsedGroups()
            saved[self.sectionTitleText] = (not self.expanded) or nil
        end

        -- Trigger layout refresh (RefreshStates handles show/hide based on expanded state)
        if parent.RefreshStates then
            parent:RefreshStates()
        end
    end
    
    -- Register child widgets to this section
    section.RegisterChild = function(self, widget)
        table.insert(self.sectionChildren, widget)
        widget.parentSection = self
        
        -- Use a marker to check section state during RefreshStates
        widget.collapsibleSection = self
    end
    
    -- Hover effects
    clickArea:SetScript("OnEnter", function()
        section:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 0.8)
    end)
    clickArea:SetScript("OnLeave", function()
        section:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.8)
    end)
    clickArea:SetScript("OnClick", function()
        section:Toggle()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    return section
end

-- =========================================================================
-- SETTINGS GROUP - Visible container that groups related settings together
-- Ensures settings never get split across columns
-- =========================================================================
-- Collapsed state persistence (stored in SavedVariables, survives logout)
-- Lazily initialized from DandersFramesDB_v2.collapsedGroups on first access
function GUI:GetCollapsedGroups()
    if not DandersFramesDB_v2 then return {} end
    if not DandersFramesDB_v2.collapsedGroups then
        DandersFramesDB_v2.collapsedGroups = {}
    end
    return DandersFramesDB_v2.collapsedGroups
end

function GUI:CreateSettingsGroup(parent, width, opts)
    -- opts can be a boolean (legacy: collapsible) or a table { collapsible, showSummary }
    if type(opts) == "boolean" then opts = { collapsible = opts } end
    opts = opts or {}

    local group = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    group:SetSize(width or 280, 10)  -- Height will be calculated dynamically
    group.groupChildren = {}
    group.isSettingsGroup = true
    group.collapsible = opts.collapsible or false
    group.showSummary = opts.showSummary or false
    group.collapsed = false

    -- Visual styling - subtle background and border
    local padding = 10
    local margin = 10  -- Space between groups
    group.padding = padding
    group.margin = margin

    if not group.SetBackdrop then Mixin(group, BackdropTemplateMixin) end
    group:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    group:SetBackdropColor(1, 1, 1, 0.03)  -- Very subtle white background (3% opacity)
    group:SetBackdropBorderColor(1, 1, 1, 0.08)  -- Subtle white border (8% opacity)

    -- Bottom collapse bar (only for collapsible groups, shown when expanded)
    if group.collapsible then
        local collapseBar = CreateFrame("Button", nil, group)
        collapseBar:SetHeight(14)
        collapseBar:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT", 1, 1)
        collapseBar:SetPoint("BOTTOMRIGHT", group, "BOTTOMRIGHT", -1, 1)

        local barBg = collapseBar:CreateTexture(nil, "BACKGROUND")
        barBg:SetAllPoints()
        barBg:SetColorTexture(1, 1, 1, 0.03)

        local barIcon = collapseBar:CreateTexture(nil, "OVERLAY")
        barIcon:SetSize(8, 8)
        barIcon:SetPoint("CENTER", 0, 0)
        local mediaPath = "Interface\\AddOns\\DandersFrames\\Media\\Icons\\"
        barIcon:SetTexture(mediaPath .. "chevron_right")
        barIcon:SetVertexColor(1, 1, 1, 0.3)

        collapseBar:SetScript("OnEnter", function()
            barBg:SetColorTexture(1, 1, 1, 0.06)
            barIcon:SetVertexColor(1, 1, 1, 0.6)
        end)
        collapseBar:SetScript("OnLeave", function()
            barBg:SetColorTexture(1, 1, 1, 0.03)
            barIcon:SetVertexColor(1, 1, 1, 0.3)
        end)
        collapseBar:SetScript("OnClick", function()
            group.collapsed = true
            local headerText = group.headerWidget and group.headerWidget.text and group.headerWidget.text:GetText()
            if headerText then
                local saved = GUI:GetCollapsedGroups()
                saved[headerText] = true
            end
            if group.collapseArrow then
                group.collapseArrow:SetTexture(mediaPath .. "chevron_right")
            end
            if DF.AuraDesigner_RefreshPage then
                DF:AuraDesigner_RefreshPage()
            end
        end)

        collapseBar:Hide()
        group.collapseBar = collapseBar
    end

    -- Add a widget to this group
    group.AddWidget = function(self, widget, height)
        widget:SetParent(self)
        table.insert(self.groupChildren, {
            widget = widget,
            height = height or 55,
        })
        -- Mark widget as belonging to this group
        widget.settingsGroup = self

        -- If collapsible and this is the first widget (header), set up collapse toggle
        if self.collapsible and #self.groupChildren == 1 and widget.text then
            self.headerWidget = widget

            -- Resolve collapsed state: default to expanded unless saved state says collapsed
            local headerText = widget.text:GetText()
            local savedStates = GUI:GetCollapsedGroups()
            if headerText and savedStates[headerText] then
                self.collapsed = true
            else
                self.collapsed = false
            end

            -- Shift header text right to make room for the arrow icon
            widget.text:ClearAllPoints()
            widget.text:SetPoint("BOTTOMLEFT", widget, "BOTTOMLEFT", 14, 2)

            -- Add toggle arrow icon (texture from Media folder)
            local arrow = widget:CreateTexture(nil, "OVERLAY")
            arrow:SetSize(10, 10)
            arrow:SetPoint("RIGHT", widget.text, "LEFT", -2, 0)
            local mediaPath = "Interface\\AddOns\\DandersFrames\\Media\\Icons\\"
            arrow:SetTexture(self.collapsed and (mediaPath .. "chevron_right") or (mediaPath .. "expand_more"))
            local c = GetThemeColor()
            arrow:SetVertexColor(c.r, c.g, c.b)
            self.collapseArrow = arrow

            -- Theme listener for arrow color
            arrow.UpdateTheme = function()
                local nc = GetThemeColor()
                arrow:SetVertexColor(nc.r, nc.g, nc.b)
            end
            if not parent.ThemeListeners then parent.ThemeListeners = {} end
            table.insert(parent.ThemeListeners, arrow)

            -- Make the header clickable
            widget:EnableMouse(true)
            widget:SetScript("OnMouseDown", function()
                self.collapsed = not self.collapsed
                -- Persist collapsed state to SavedVariables
                if headerText then
                    local saved = GUI:GetCollapsedGroups()
                    saved[headerText] = self.collapsed or nil  -- only store true, remove when expanded
                end
                arrow:SetTexture(self.collapsed and (mediaPath .. "chevron_right") or (mediaPath .. "expand_more"))
                -- Refresh the page to recalculate layout
                if DF.AuraDesigner_RefreshPage then
                    DF:AuraDesigner_RefreshPage()
                end
            end)

            -- Highlight arrow on hover to indicate clickable
            widget:SetScript("OnEnter", function()
                arrow:SetVertexColor(1, 1, 1)
            end)
            widget:SetScript("OnLeave", function()
                local nc = GetThemeColor()
                arrow:SetVertexColor(nc.r, nc.g, nc.b)
            end)
        end

        return widget
    end

    -- Calculate total height based on visible children and layout them
    group.LayoutChildren = function(self)
        local y = -self.padding  -- Start with top padding
        local visibleCount = 0
        local innerWidth = self:GetWidth() - (self.padding * 2)  -- Width for child widgets

        for i, entry in ipairs(self.groupChildren) do
            local widget = entry.widget
            local height = entry.height

            -- If collapsed, only show the header (first widget)
            if self.collapsed and i > 1 then
                widget:Hide()
            else
                -- Check if widget should be visible
                local shouldShow = true
                if widget.hideOn then
                    local db = DF.db[GUI.SelectedMode]
                    if db and widget.hideOn(db) then
                        shouldShow = false
                    end
                end

                if shouldShow then
                    widget:ClearAllPoints()
                    widget:SetPoint("TOPLEFT", self, "TOPLEFT", self.padding, y)
                    -- Set width to fit within group padding
                    widget:SetWidth(innerWidth)
                    widget:Show()
                    y = y - height
                    visibleCount = visibleCount + 1
                else
                    widget:Hide()
                end
            end
        end

        -- Show/hide collapsed summary and bottom collapse bar
        if self.collapsible then
            if self.collapsed then
                if self.showSummary then
                    -- Build summary fontstring lazily on first use
                    if not self.collapseSummary then
                        self.collapseSummary = self:CreateFontString(nil, "OVERLAY")
                        DF:SafeSetFont(self.collapseSummary, nil, 9, "")
                        self.collapseSummary:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b, 0.5)
                        self.collapseSummary:SetJustifyH("LEFT")
                        self.collapseSummary:SetWordWrap(true)
                    end

                    -- Collect labels from child widgets (skip header at index 1)
                    local labels = {}
                    for i = 2, #self.groupChildren do
                        local w = self.groupChildren[i].widget
                        -- Scan the widget's regions for a FontString with text
                        for _, region in ipairs({w:GetRegions()}) do
                            if region.GetText and region:GetText() and region:GetText() ~= "" then
                                labels[#labels + 1] = region:GetText()
                                break
                            end
                        end
                    end

                    local summaryText = table.concat(labels, "  \194\183  ")  -- separated by  ·
                    self.collapseSummary:SetText(summaryText)
                    self.collapseSummary:ClearAllPoints()
                    self.collapseSummary:SetPoint("TOPLEFT", self, "TOPLEFT", self.padding, y)
                    self.collapseSummary:SetWidth(innerWidth)
                    self.collapseSummary:Show()
                    -- Measure actual wrapped height
                    local summaryHeight = self.collapseSummary:GetStringHeight() or 12
                    y = y - summaryHeight - 2
                else
                    if self.collapseSummary then self.collapseSummary:Hide() end
                end

                if self.collapseBar then self.collapseBar:Hide() end
            else
                if self.collapseSummary then self.collapseSummary:Hide() end
                if self.collapseBar then
                    self.collapseBar:Show()
                    y = y - self.collapseBar:GetHeight()
                end
            end
        end

        -- Update group height (add padding at bottom)
        local totalHeight = math.abs(y) + self.padding
        if totalHeight < 1 then totalHeight = 1 end
        self:SetHeight(totalHeight)
        -- Add margin to calculated height for spacing between groups
        self.calculatedHeight = totalHeight + self.margin

        return self.calculatedHeight
    end

    -- Process disableOn for children
    group.RefreshChildStates = function(self)
        local db = DF.db[GUI.SelectedMode]
        if not db then return end

        for _, entry in ipairs(self.groupChildren) do
            local widget = entry.widget
            if widget.disableOn then
                local shouldDisable = widget.disableOn(db)
                if widget.SetEnabled then
                    widget:SetEnabled(not shouldDisable)
                end
            end
            if widget.refreshContent and widget:IsShown() then
                widget:refreshContent(db)
            end
        end
    end

    return group
end

function GUI:CreateLabel(parent, text, width, color)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width or 380, 40)
    
    local lbl = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, -5)
    lbl:SetWidth(width or 380)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(text)
    
    if color then
        lbl:SetTextColor(color.r, color.g, color.b, color.a or 1)
    else
        lbl:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
    end
    
    frame.SetText = function(self, newText) lbl:SetText(newText) end
    return frame
end

-- Themed info callout: neutral dark box with a theme-color border and a label
-- composed of a bold title prefix + body text. Used for settings explanations
-- that benefit from visual prominence without the red "warning" styling.
-- SetContent(title, body) updates both parts; SetText(text) remains available
-- for plain single-string use.
function GUI:CreateInfoCallout(parent, width, height)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(width or 560, height or 60)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })

    local applyTheme = function()
        local c = GetThemeColor()
        -- Neutral element background with the theme colour only on the border
        -- and (via SetContent below) on the bolded title prefix. Keeps the box
        -- from looking like a big coloured panel.
        frame:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0.75)
        frame:SetBackdropBorderColor(c.r, c.g, c.b, 0.7)
    end
    applyTheme()

    local lbl = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 10, -10)
    lbl:SetPoint("BOTTOMRIGHT", -10, 10)
    lbl:SetJustifyH("LEFT")
    lbl:SetJustifyV("TOP")
    lbl:SetWordWrap(true)
    lbl:SetNonSpaceWrap(true)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    local currentTitle, currentBody = nil, ""
    local function render()
        if currentTitle and currentTitle ~= "" then
            local c = GetThemeColor()
            local hex = string.format("ff%02x%02x%02x",
                math.floor(c.r * 255), math.floor(c.g * 255), math.floor(c.b * 255))
            lbl:SetText("|c" .. hex .. currentTitle .. ":|r " .. (currentBody or ""))
        else
            lbl:SetText(currentBody or "")
        end
    end

    frame.SetContent = function(self, title, body)
        currentTitle, currentBody = title, body
        render()
    end
    frame.SetText = function(self, text)
        currentTitle, currentBody = nil, text
        render()
    end

    frame.UpdateTheme = function()
        applyTheme()
        render()
    end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, frame)

    return frame
end

-- Segmented button group: a row of mutually-exclusive buttons, one selected at
-- a time. Each option shows a primary label and an optional subtitle on a
-- second line. Selected button gets a themed border + tinted fill; unselected
-- buttons use the standard element backdrop.
--
--   options: ordered array of { value=, label=, subtitle= }
--   dbTable/dbKey: reads/writes the selected value
--   callback: called after a selection change
--   totalWidth: total container width (buttons divide it evenly with small gaps)
function GUI:CreateSegmentedButtonGroup(parent, options, dbTable, dbKey, callback, totalWidth)
    local container = CreateFrame("Frame", nil, parent)
    totalWidth = totalWidth or 560
    local btnHeight = 38  -- compact modern height: label + subtitle fit snugly
    local gap = 4
    local minBtnWidth = 110  -- below this, buttons wrap to next row
    container:SetSize(totalWidth, btnHeight)

    local n = #options

    local buttons = {}
    container.buttons = buttons

    -- Reposition buttons to fill the container's current width. Wraps to
    -- additional rows when per-button width would drop below minBtnWidth.
    -- Called on creation and on OnSizeChanged so buttons reflow when the
    -- page stretches or shrinks the container.
    local function Relayout()
        -- Re-entry guard: OnSizeChanged can fire again when we SetHeight
        -- below, and we might also be called during a deferred RefreshStates.
        -- Without this guard the widget rebuild chain loops infinitely and
        -- drops the framerate to single digits.
        if container._relayouting then return end
        container._relayouting = true

        local w = container:GetWidth() or totalWidth
        if w <= 0 then w = totalWidth end

        local perRow = math.max(1, math.min(n, math.floor((w + gap) / (minBtnWidth + gap))))
        local rows = math.ceil(n / perRow)
        local bw = math.floor((w - gap * (perRow - 1)) / perRow)

        for i, btn in ipairs(buttons) do
            local rowIdx = math.ceil(i / perRow) - 1
            local colIdx = (i - 1) % perRow
            btn:SetWidth(bw)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", colIdx * (bw + gap), -(rowIdx * (btnHeight + gap)))
        end

        local newHeight = rows * btnHeight + (rows - 1) * gap
        if math.abs((container:GetHeight() or 0) - newHeight) > 0.5 then
            container:SetHeight(newHeight)
        end

        -- If the row count changed the required layout space, bump
        -- layoutHeight so the page reserves the right amount on the next
        -- layout pass, and defer a layout-only refresh (NOT page:Refresh()
        -- which would rebuild all widgets and re-enter this path forever).
        local desiredLayoutH = newHeight + 4
        if container.layoutHeight ~= desiredLayoutH then
            container.layoutHeight = desiredLayoutH
            if not container._relayoutPending then
                container._relayoutPending = true
                C_Timer.After(0, function()
                    container._relayoutPending = false
                    if parent and parent.RefreshStates then
                        parent:RefreshStates()
                    end
                end)
            end
        end

        container._relayouting = false
    end
    container:SetScript("OnSizeChanged", function() Relayout() end)

    local function Refresh()
        local currentVal = dbTable and dbTable[dbKey]
        local theme = GetThemeColor()
        for _, btn in ipairs(buttons) do
            local selected = (btn.value == currentVal)
            btn.selected = selected
            if selected then
                -- Border-only selection: same backdrop as unselected, themed
                -- border, themed label. Subtle but unambiguous.
                btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                btn:SetBackdropBorderColor(theme.r, theme.g, theme.b, 1)
                if btn.Label then btn.Label:SetTextColor(theme.r, theme.g, theme.b, 1) end
                if btn.Subtitle then btn.Subtitle:SetTextColor(theme.r * 0.85, theme.g * 0.85, theme.b * 0.95, 1) end
            else
                btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.6)
                if btn.Label then btn.Label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b, 1) end
                if btn.Subtitle then btn.Subtitle:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1) end
            end
        end
    end
    container.Refresh = Refresh
    -- refreshContent hook used by the page layout so external changes to the
    -- db value (e.g. profile switches) re-sync the selected button.
    container.refreshContent = function(self) Refresh() end

    for i, opt in ipairs(options) do
        local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
        btn:SetHeight(btnHeight)
        -- Width and position set by Relayout() below (called at end of setup
        -- and on every OnSizeChanged).
        CreateElementBackdrop(btn)

        btn.value = opt.value

        btn.Label = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btn.Label:SetPoint("TOP", 0, -5)
        btn.Label:SetText(opt.label or "")

        if opt.subtitle and opt.subtitle ~= "" then
            btn.Subtitle = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            btn.Subtitle:SetPoint("BOTTOM", 0, 5)
            btn.Subtitle:SetText(opt.subtitle)
            -- Nudge subtitle down by ~1 pt for a clearer visual hierarchy.
            local fPath, fSize, fFlags = btn.Subtitle:GetFont()
            if fPath and fSize and fSize > 9 then
                btn.Subtitle:SetFont(fPath, fSize - 1, fFlags or "")
            end
        end

        btn:SetScript("OnEnter", function(self)
            if not self.selected then
                self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            Refresh()
        end)
        btn:SetScript("OnClick", function(self)
            if dbTable[dbKey] == self.value then return end
            dbTable[dbKey] = self.value
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            Refresh()
            if callback then callback() end
        end)

        buttons[i] = btn
    end

    Relayout()
    Refresh()

    container.UpdateTheme = function() Refresh() end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, container)

    return container
end

function GUI:CreateWarningBox(parent, text, width, height)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(width or 280, height or 70)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.4, 0.1, 0.1, 0.7)  -- Dark red background
    frame:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)  -- Red border
    
    local lbl = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 8, -8)
    lbl:SetPoint("BOTTOMRIGHT", -8, 8)
    lbl:SetJustifyH("LEFT")
    lbl:SetJustifyV("TOP")
    lbl:SetWordWrap(true)
    lbl:SetNonSpaceWrap(true)
    lbl:SetText(text)
    lbl:SetTextColor(1, 0.8, 0.8, 1)  -- Light red/pink text
    
    frame.SetText = function(self, newText) lbl:SetText(newText) end
    return frame
end

function GUI:CreateButton(parent, text, width, height, func)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 120, height or 22)
    CreateElementBackdrop(btn)
    
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(text)
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    btn:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if self:IsEnabled() then
            if self.isTab and self.isActive then
                self:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
            else
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            end
        end
    end)
    btn:SetScript("OnClick", function(self)
        if func then func(self) end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    return btn
end

-- Creates a button with an icon and text
-- iconName is the name of the icon file (without path/extension)
-- iconSize is optional (defaults to 16)
function GUI:CreateIconButton(parent, iconName, text, width, height, func, iconSize)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 120, height or 22)
    CreateElementBackdrop(btn)
    
    local iSize = iconSize or 16
    local icon = btn:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("LEFT", 8, 0)
    icon:SetSize(iSize, iSize)
    icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\" .. iconName)
    icon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    btn.Icon = icon
    
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    btn.Text:SetText(text)
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    btn:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        end
    end)
    btn:SetScript("OnClick", function(self)
        if func then func(self) end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    return btn
end

-- Creates a \"See Also:\" section with clickable links to related pages
-- links = { {pageId = \"display_tooltips\", label = \"Tooltips\"}, ... }
function GUI:CreateSeeAlso(parent, links)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetHeight(32)
    container:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    container:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    local label = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    label:SetPoint("TOPLEFT", 8, -10)
    label:SetText(L["See Also:"])
    label:SetTextColor(0.7, 0.7, 0.7)
    
    local linkButtons = {}
    local separators = {}
    
    for i, linkData in ipairs(links) do
        local link = CreateFrame("Button", nil, container)
        link:SetHeight(16)
        
        local linkText = link:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        linkText:SetPoint("TOPLEFT", 0, -1)
        linkText:SetText(linkData.label)
        local c = GetThemeColor()
        linkText:SetTextColor(c.r, c.g, c.b)
        link.text = linkText
        link.textWidth = linkText:GetStringWidth() + 4
        link:SetWidth(link.textWidth)
        
        link:SetScript("OnEnter", function(self)
            linkText:SetTextColor(1, 1, 1)
        end)
        link:SetScript("OnLeave", function(self)
            linkText:SetTextColor(c.r, c.g, c.b)
        end)
        link:SetScript("OnClick", function()
            if GUI.SelectTab then
                GUI.SelectTab(linkData.pageId)
            end
        end)
        
        table.insert(linkButtons, link)
        
        -- Create separator (hidden by default, shown as needed)
        if i < #links then
            local sep = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            sep:SetText("•")
            sep:SetTextColor(0.5, 0.5, 0.5)
            table.insert(separators, sep)
        end
    end
    
    -- Layout function that handles wrapping
    local function LayoutLinks()
        local containerWidth = container:GetWidth()
        if containerWidth < 50 then return end  -- Not sized yet
        
        local labelWidth = label:GetStringWidth() + 16
        local firstLinkX = labelWidth  -- Where first link starts
        local xOffset = labelWidth
        local yOffset = -9
        local lineHeight = 18
        local maxX = containerWidth - 10
        local rowCount = 1
        
        -- First pass: determine which links are on which row
        local linkRows = {}
        local tempX = labelWidth
        local currentRow = 1
        
        for i, link in ipairs(linkButtons) do
            local linkWidth = link.textWidth
            local sepWidth = (i < #linkButtons) and 14 or 0
            
            -- Check if we need to wrap
            if tempX + linkWidth > maxX and tempX > labelWidth then
                currentRow = currentRow + 1
                tempX = firstLinkX
            end
            
            linkRows[i] = currentRow
            tempX = tempX + linkWidth + sepWidth
        end
        
        rowCount = currentRow
        
        -- Second pass: position elements
        xOffset = labelWidth
        local lastRowForLink = 1
        
        for i, link in ipairs(linkButtons) do
            local linkWidth = link.textWidth
            
            -- Check if we need to wrap to new line
            if linkRows[i] > lastRowForLink then
                xOffset = firstLinkX
                yOffset = yOffset - lineHeight
                lastRowForLink = linkRows[i]
            end
            
            link:ClearAllPoints()
            link:SetPoint("TOPLEFT", container, "TOPLEFT", xOffset, yOffset)
            
            xOffset = xOffset + linkWidth + 2
            
            -- Position separator only if next link is on same row
            if separators[i] then
                if linkRows[i + 1] == linkRows[i] then
                    separators[i]:ClearAllPoints()
                    separators[i]:SetPoint("TOPLEFT", container, "TOPLEFT", xOffset, yOffset - 1)
                    separators[i]:Show()
                    xOffset = xOffset + 12
                else
                    separators[i]:Hide()
                end
            end
        end
        
        -- Adjust container height based on rows
        local newHeight = 10 + (rowCount * lineHeight)
        container:SetHeight(newHeight)
        container.layoutHeight = newHeight + 5
    end
    
    container:SetScript("OnSizeChanged", LayoutLinks)
    
    -- Initial layout after a frame (to let width be set)
    C_Timer.After(0, LayoutLinks)
    
    return container
end

-- =========================================================================
-- OVERRIDE INDICATORS FOR AUTO PROFILES
-- =========================================================================
-- Helper function to add override indicators (star, reset button, global value text)
-- to widget containers when editing an auto profile

-- Debug flag - when true, shows all reset buttons regardless of override state
local overrideDebugMode = false

-- Track all widgets with override indicators for refresh
local overrideWidgets = {}

-- Function to check if debug mode is active (exposed for other files)
local function IsOverrideDebugMode()
    return overrideDebugMode
end
GUI.IsOverrideDebugMode = IsOverrideDebugMode

-- Function to refresh all override indicators
local function RefreshAllOverrideIndicators()
    for _, widget in ipairs(overrideWidgets) do
        if widget and widget.UpdateOverrideIndicators then
            widget:UpdateOverrideIndicators()
        end
    end
    -- Also refresh position override indicator
    if GUI.UpdatePositionOverrideIndicator then
        GUI.UpdatePositionOverrideIndicator()
    end
    -- Refresh tab override stars (auto-profiles)
    if DF.AutoProfilesUI and DF.AutoProfilesUI.RefreshTabOverrideStars then
        DF.AutoProfilesUI:RefreshTabOverrideStars()
    end
end
GUI.RefreshAllOverrideIndicators = RefreshAllOverrideIndicators

-- Allow other files to register widgets with override indicators
function GUI.RegisterOverrideWidget(widget)
    table.insert(overrideWidgets, widget)
end

-- Slash command to toggle debug mode
SLASH_DFOVERRIDEDEBUG1 = "/dfoverridedebug"
SlashCmdList["DFOVERRIDEDEBUG"] = function()
    overrideDebugMode = not overrideDebugMode
    print("|cff00ff00DandersFrames:|r Override debug mode " .. (overrideDebugMode and "ENABLED" or "DISABLED"))
    -- Refresh all override indicators
    RefreshAllOverrideIndicators()
    -- Also update position panel if open
    if DF.positionPanel and DF.positionPanel.UpdatePositionOverride then
        DF.positionPanel.UpdatePositionOverride()
    end
end

local function AddOverrideIndicators(container, lbl, dbKey, onReset, verticalOffset, optionsMap, dbTable)
    -- Skip for proxy tables (e.g. Aura Designer) that don't support per-key override tracking
    if dbTable and rawget(dbTable, "_skipOverrideIndicators") then return end
    verticalOffset = verticalOffset or 0
    container.overrideOptionsMap = optionsMap
    
    -- Reset button (shown when overridden) - positioned at top right
    local resetBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
    resetBtn:SetSize(18, 18)
    resetBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, verticalOffset)
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
    
    resetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.8, 0.2, 1)
        resetIcon:SetVertexColor(1, 0.8, 0.2)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Reset to Global"])
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        resetIcon:SetVertexColor(0.6, 0.6, 0.6)
        GameTooltip:Hide()
    end)
    resetBtn:SetScript("OnClick", function()
        if onReset then
            onReset()
        end
    end)
    container.overrideResetBtn = resetBtn
    
    -- Override icon (shown when overridden) - positioned LEFT of reset button, yellow/gold color
    local starBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
    starBtn:SetSize(18, 18)
    starBtn:SetPoint("RIGHT", resetBtn, "LEFT", -2, 0)
    starBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    starBtn:SetBackdropColor(0, 0, 0, 0)
    starBtn:SetBackdropBorderColor(0, 0, 0, 0)
    starBtn:Hide()
    local starIcon = starBtn:CreateTexture(nil, "OVERLAY")
    starIcon:SetSize(12, 12)
    starIcon:SetPoint("CENTER")
    starIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
    starIcon:SetVertexColor(1, 0.8, 0.2)
    starBtn:SetScript("OnEnter", function(s)
        if s.tooltipText then
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(s.tooltipText)
            if s.tooltipSubText then
                GameTooltip:AddLine(s.tooltipSubText, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end
    end)
    starBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    container.overrideStar = starBtn
    
    -- Global value text (shown when in edit mode) - positioned inline after label
    local globalText = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    globalText:SetPoint("LEFT", lbl, "RIGHT", 4, 0)
    globalText:SetTextColor(0.4, 0.4, 0.4)
    globalText:Hide()
    container.overrideGlobalText = globalText
    
    -- Checkmark icon for matching global value
    local checkIcon = container:CreateTexture(nil, "OVERLAY")
    checkIcon:SetSize(8, 8)
    checkIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
    checkIcon:SetVertexColor(0.3, 0.7, 0.3)
    checkIcon:Hide()
    container.overrideCheckIcon = checkIcon
    
    -- Store dbKey for reference
    container.overrideDbKey = dbKey
    
    -- Function to update override indicators
    container.UpdateOverrideIndicators = function(self, currentValue)
        -- Debug mode shows all buttons
        if overrideDebugMode then
            self.overrideStar:Show()
            self.overrideResetBtn:Show()
            self.overrideGlobalText:SetText("(debug)")
            self.overrideGlobalText:SetTextColor(1, 0.8, 0.2)  -- Yellow for visibility
            self.overrideGlobalText:Show()
            self.overrideCheckIcon:Hide()
            return
        end
        
        -- Only show when in raid mode
        local GUI = DF.GUI
        if not GUI or GUI.SelectedMode ~= "raid" then
            self.overrideStar:Hide()
            self.overrideResetBtn:Hide()
            self.overrideGlobalText:Hide()
            self.overrideCheckIcon:Hide()
            return
        end

        local AutoProfilesUI = DF.AutoProfilesUI
        local isEditing = AutoProfilesUI and AutoProfilesUI:IsEditing()
        local isRuntimeOverridden = AutoProfilesUI and AutoProfilesUI:IsOverriddenByRuntime(dbKey)

        -- Hide everything if not editing AND not runtime-overridden
        if not isEditing and not isRuntimeOverridden then
            self.overrideStar:Hide()
            self.overrideResetBtn:Hide()
            self.overrideGlobalText:Hide()
            self.overrideCheckIcon:Hide()
            return
        end

        -- Runtime override mode: show star + global value, but no reset button
        if isRuntimeOverridden and not isEditing then
            self.overrideStar.tooltipText = L["Overridden by Auto Layout"]
            self.overrideStar.tooltipSubText = L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."]
            self.overrideStar:Show()
            self.overrideResetBtn:Hide()  -- Can't reset runtime overrides from controls
            self.overrideCheckIcon:Hide()

            local globalValue = AutoProfilesUI:GetRuntimeGlobalValue(dbKey)

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
                if globalValue.r then
                    globalDisplay = L["Color"]
                else
                    globalDisplay = "..."
                end
            elseif type(globalValue) == "string" and self.overrideOptionsMap and self.overrideOptionsMap[globalValue] then
                local mapped = self.overrideOptionsMap[globalValue]
                if type(mapped) == "table" then
                    globalDisplay = mapped.text or mapped.label or globalValue
                else
                    globalDisplay = tostring(mapped)
                end
            else
                globalDisplay = tostring(globalValue or L["None"])
            end

            self.overrideGlobalText:SetText("(Global: " .. globalDisplay .. ")")
            self.overrideGlobalText:ClearAllPoints()
            self.overrideGlobalText:SetPoint("LEFT", lbl, "RIGHT", 4, 0)
            self.overrideGlobalText:SetTextColor(0.5, 0.5, 0.5)
            self.overrideGlobalText:Show()
            return
        end

        -- Editing mode: existing behavior
        -- Check if setting is overridden
        local isOverridden = AutoProfilesUI:IsSettingOverridden(dbKey)
        local globalValue = AutoProfilesUI:GetGlobalValue(dbKey)

        -- Show/hide star and reset button
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
            -- Color table
            if globalValue.r then
                globalDisplay = "Color"
            else
                globalDisplay = "..."
            end
        elseif type(globalValue) == "string" and self.overrideOptionsMap and self.overrideOptionsMap[globalValue] then
            local mapped = self.overrideOptionsMap[globalValue]
            if type(mapped) == "table" then
                globalDisplay = mapped.text or mapped.label or globalValue
            else
                globalDisplay = tostring(mapped)
            end
        else
            globalDisplay = tostring(globalValue or L["None"])
        end

        -- Show global value inline with label
        self.overrideGlobalText:SetText("(Global: " .. globalDisplay .. ")")
        self.overrideGlobalText:ClearAllPoints()
        self.overrideGlobalText:SetPoint("LEFT", lbl, "RIGHT", 4, 0)

        if isOverridden then
            self.overrideGlobalText:SetTextColor(0.5, 0.5, 0.5)
            self.overrideCheckIcon:Hide()
        else
            self.overrideGlobalText:SetTextColor(0.3, 0.6, 0.3)
            -- Position check icon after text
            self.overrideCheckIcon:ClearAllPoints()
            self.overrideCheckIcon:SetPoint("LEFT", self.overrideGlobalText, "RIGHT", 2, 0)
            self.overrideCheckIcon:Show()
        end
        self.overrideGlobalText:Show()
    end
    
    -- Register this widget for refresh tracking
    table.insert(overrideWidgets, container)
    
    return container
end

-- Override indicators for order list controls (drag lists)
-- These don't have traditional labels, so we use a compact star + reset + "Modified" badge
local function AddOrderListOverrideIndicators(container, dbKey, onReset)
    -- Reset button (shown when overridden) - positioned at top right
    local resetBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
    resetBtn:SetSize(18, 18)
    resetBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 14)
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
    
    resetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.8, 0.2, 1)
        resetIcon:SetVertexColor(1, 0.8, 0.2)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Reset to Global Order"])
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        resetIcon:SetVertexColor(0.6, 0.6, 0.6)
        GameTooltip:Hide()
    end)
    resetBtn:SetScript("OnClick", function()
        if onReset then onReset() end
    end)
    container.overrideResetBtn = resetBtn
    
    -- Star icon to the left of reset button (Button for tooltip support)
    local starBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
    starBtn:SetSize(18, 18)
    starBtn:SetPoint("RIGHT", resetBtn, "LEFT", -2, 0)
    starBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    starBtn:SetBackdropColor(0, 0, 0, 0)
    starBtn:SetBackdropBorderColor(0, 0, 0, 0)
    starBtn:Hide()
    local starIcon = starBtn:CreateTexture(nil, "OVERLAY")
    starIcon:SetSize(12, 12)
    starIcon:SetPoint("CENTER")
    starIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
    starIcon:SetVertexColor(1, 0.8, 0.2)
    starBtn:SetScript("OnEnter", function(s)
        if s.tooltipText then
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            GameTooltip:SetText(s.tooltipText)
            if s.tooltipSubText then
                GameTooltip:AddLine(s.tooltipSubText, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end
    end)
    starBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    container.overrideStar = starBtn
    
    -- "Modified" text to the left of star
    local modifiedText = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    modifiedText:SetPoint("RIGHT", starIcon, "LEFT", -2, 0)
    modifiedText:SetText(L["Modified"])
    modifiedText:SetTextColor(1, 0.8, 0.2, 0.8)
    modifiedText:Hide()
    container.overrideModifiedText = modifiedText
    
    -- Store dbKey for reference
    container.overrideDbKey = dbKey
    
    -- Update function
    container.UpdateOverrideIndicators = function(self, currentValue)
        -- Debug mode
        if overrideDebugMode then
            self.overrideStar:Show()
            self.overrideResetBtn:Show()
            self.overrideModifiedText:SetText("Modified (debug)")
            self.overrideModifiedText:Show()
            return
        end
        
        -- Only show when in raid mode and editing
        local GUI = DF.GUI
        if not GUI or GUI.SelectedMode ~= "raid" then
            self.overrideStar:Hide()
            self.overrideResetBtn:Hide()
            self.overrideModifiedText:Hide()
            return
        end
        
        local AutoProfilesUI = DF.AutoProfilesUI
        if not AutoProfilesUI or not AutoProfilesUI:IsEditing() then
            self.overrideStar:Hide()
            self.overrideResetBtn:Hide()
            self.overrideModifiedText:Hide()
            return
        end
        
        local isOverridden = AutoProfilesUI:IsSettingOverridden(dbKey)
        
        if isOverridden then
            self.overrideStar.tooltipText = L["Overridden in this layout"]
            self.overrideStar.tooltipSubText = L["This setting differs from the global profile value. Click the reset button to revert."]
            self.overrideStar:Show()
            self.overrideResetBtn:Show()
            self.overrideModifiedText:Show()
        else
            self.overrideStar:Hide()
            self.overrideResetBtn:Hide()
            self.overrideModifiedText:Hide()
        end
    end

    -- Register for refresh tracking
    table.insert(overrideWidgets, container)
end

function GUI:CreateCheckbox(parent, label, dbTable, dbKey, callback, customGet, customSet, overrideKey)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(220, 24)
    
    local cb = CreateFrame("CheckButton", nil, container, "BackdropTemplate")
    cb:SetSize(18, 18)
    cb:SetPoint("LEFT", 0, 0)
    CreateElementBackdrop(cb)
    
    -- Checkmark
    cb.Check = cb:CreateTexture(nil, "OVERLAY")
    cb.Check:SetTexture("Interface\\Buttons\\WHITE8x8")
    local c = GetThemeColor()
    cb.Check:SetVertexColor(c.r, c.g, c.b)
    cb.Check:SetPoint("CENTER")
    cb.Check:SetSize(10, 10)
    cb:SetCheckedTexture(cb.Check)
    
    -- Label
    local txt = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    txt:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    txt:SetText(label)
    txt:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Determine the key to use for override indicators
    local effectiveOverrideKey = overrideKey or dbKey
    
    -- Add override indicators if we have a key (either dbKey or overrideKey)
    if effectiveOverrideKey and type(effectiveOverrideKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(effectiveOverrideKey)
                -- Refresh to global value
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(effectiveOverrideKey)
                cb:SetChecked(globalVal)
                if dbTable and dbKey then
                    dbTable[dbKey] = globalVal
                elseif customSet then
                    customSet(globalVal)
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
                if callback then callback() end
            end
        end
        AddOverrideIndicators(container, txt, effectiveOverrideKey, onReset, nil, nil, dbTable)
    end
    
    local function UpdateState()
        local val = false
        if customGet then val = customGet() elseif dbTable and dbKey then val = dbTable[dbKey] end
        cb:SetChecked(val)
        -- Update override indicators
        if container.UpdateOverrideIndicators then
            container:UpdateOverrideIndicators(val)
        end
    end
    
    cb.UpdateTheme = function()
        local nc = GetThemeColor()
        cb.Check:SetVertexColor(nc.r, nc.g, nc.b)
    end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, cb)
    
    container:SetScript("OnShow", UpdateState)
    cb:SetScript("OnClick", function(self)
        local val = self:GetChecked()
        if DF.debugEnabled then
            print("|cffff00ffDF DEBUG:|r Checkbox OnClick")
            print("  dbKey:", dbKey)
            print("  overrideKey:", overrideKey)
            print("  new value:", val)
        end

        -- Runtime override protection: redirect to baseline, skip refresh
        if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
           and DF.AutoProfilesUI:HandleRuntimeWrite(effectiveOverrideKey, val) then
            if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(val) end
            return
        end

        if customSet then customSet(val) elseif dbTable and dbKey then dbTable[dbKey] = val end

        -- If editing a profile, also set the override (use effectiveOverrideKey)
        if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and effectiveOverrideKey then
            DF.AutoProfilesUI:SetProfileSetting(effectiveOverrideKey, val)
        end
        
        -- Update override indicators
        if container.UpdateOverrideIndicators then
            container:UpdateOverrideIndicators(val)
        end
        
        if callback then 
            if DF.debugEnabled then print("  -> calling callback") end
            callback() 
        end
        if parent.RefreshStates then 
            if DF.debugEnabled then print("  -> calling RefreshStates") end
            parent:RefreshStates() 
        end
        if DF.debugEnabled then print("  -> calling DF:UpdateAll()") end
        DF:UpdateAll()
    end)
    
    container.SetEnabled = function(self, enabled)
        cb:SetEnabled(enabled)
        if enabled then
            txt:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        else
            txt:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
    end

    -- Tooltip support: show container.tooltip on hover
    container:EnableMouse(true)
    container:SetScript("OnEnter", function(self)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(self.tooltip, 1, 0.82, 0, true)
            GameTooltip:Show()
        end
    end)
    container:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdateState()
    
    -- SEARCH: Register this setting
    if DF.Search then
        local hasCustomGetSet = (customGet ~= nil or customSet ~= nil)
        if dbKey and type(dbKey) == "string" then
            container.searchEntry = DF.Search:RegisterCheckbox(label, dbKey, nil, false)
        elseif hasCustomGetSet then
            container.searchEntry = DF.Search:RegisterCheckbox(label, nil, nil, true)
        end
    end
    
    return container
end

-- ============================================================
-- TOGGLE SWITCH
-- A two-state toggle for mutually exclusive options. Two labels
-- flank a pill-shaped track with a sliding thumb. The active
-- label is bright, the inactive label is dimmed.
--
-- API: GUI:CreateToggleSwitch(parent, labelA, labelB, dbTable,
--        dbKey, valueA, valueB, callback)
--   labelA / labelB : display text for each state
--   valueA / valueB : the db values those states map to
-- ============================================================
function GUI:CreateToggleSwitch(parent, labelA, labelB, dbTable, dbKey, valueA, valueB, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 24)

    -- Left label
    local txtA = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    txtA:SetPoint("LEFT", 0, 0)
    txtA:SetText(labelA)

    -- Track (pill shape, fixed width)
    local trackWidth, trackHeight = 36, 18
    local track = CreateFrame("Frame", nil, container, "BackdropTemplate")
    track:SetSize(trackWidth, trackHeight)
    track:SetPoint("LEFT", txtA, "RIGHT", 8, 0)

    -- Right label (anchored to track)
    local txtB = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    txtB:SetPoint("LEFT", track, "RIGHT", 8, 0)
    txtB:SetText(labelB)
    track:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    track:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    track:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)

    -- Thumb
    local thumbSize = trackHeight - 4
    local thumb = track:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(thumbSize, thumbSize)
    thumb:SetTexture("Interface\\Buttons\\WHITE8x8")

    -- Fill highlight spanning the full track interior
    local fill = track:CreateTexture(nil, "ARTWORK")
    fill:SetTexture("Interface\\Buttons\\WHITE8x8")
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMRIGHT", -2, 2)

    -- Override indicator support
    local effectiveOverrideKey = dbKey
    if effectiveOverrideKey and type(effectiveOverrideKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(effectiveOverrideKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(effectiveOverrideKey)
                if dbTable and dbKey then
                    dbTable[dbKey] = globalVal
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
                if callback then callback() end
            end
        end
        AddOverrideIndicators(container, txtB, effectiveOverrideKey, onReset, nil, nil, dbTable)
    end

    -- Visual refresh
    local function UpdateVisuals()
        local val
        if dbTable and dbKey then val = dbTable[dbKey] end
        local isB = (val == valueB)

        local tc = GetThemeColor()
        thumb:ClearAllPoints()
        if isB then
            thumb:SetPoint("RIGHT", track, "RIGHT", -2, 0)
        else
            thumb:SetPoint("LEFT", track, "LEFT", 2, 0)
        end

        thumb:SetVertexColor(tc.r, tc.g, tc.b, 1)
        fill:SetVertexColor(tc.r, tc.g, tc.b, 0.25)

        -- Label colors
        if isB then
            txtA:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            txtB:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        else
            txtA:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            txtB:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end

        if container.UpdateOverrideIndicators then
            container:UpdateOverrideIndicators(val)
        end
    end

    -- Click handler (shared by track and both labels)
    local function Toggle()
        local current = dbTable and dbKey and dbTable[dbKey]
        local newVal = (current == valueB) and valueA or valueB

        -- Runtime override protection
        if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
           and DF.AutoProfilesUI:HandleRuntimeWrite(effectiveOverrideKey, newVal) then
            if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(newVal) end
            return
        end

        if dbTable and dbKey then dbTable[dbKey] = newVal end

        -- Profile editing
        if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and effectiveOverrideKey then
            DF.AutoProfilesUI:SetProfileSetting(effectiveOverrideKey, newVal)
        end

        UpdateVisuals()

        if callback then callback() end
        if parent.RefreshStates then parent:RefreshStates() end
        DF:UpdateAll()
    end

    track:EnableMouse(true)
    track:SetScript("OnMouseUp", function() Toggle() end)
    txtA:SetParent(container)
    txtB:SetParent(container)
    -- Make labels clickable via the container
    container:EnableMouse(true)
    container:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then Toggle() end
    end)

    -- Theme support
    track.UpdateTheme = function()
        UpdateVisuals()
    end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, track)

    container:SetScript("OnShow", UpdateVisuals)

    -- Tooltip support
    container:SetScript("OnEnter", function(self)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText(labelA .. " / " .. labelB, 1, 1, 1)
            GameTooltip:AddLine(self.tooltip, 1, 0.82, 0, true)
            GameTooltip:Show()
        end
        -- Hover highlight on track
        track:SetBackdropBorderColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 1)
    end)
    container:SetScript("OnLeave", function()
        GameTooltip:Hide()
        track:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    end)

    -- Enable/disable
    container.SetEnabled = function(self, enabled)
        track:EnableMouse(enabled)
        self:EnableMouse(enabled)
        if enabled then
            UpdateVisuals()
        else
            txtA:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            txtB:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            thumb:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.5)
            fill:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.1)
        end
    end

    -- Search registration
    if DF.Search and dbKey and type(dbKey) == "string" then
        container.searchEntry = DF.Search:RegisterCheckbox(labelA .. " / " .. labelB, dbKey, nil, false)
    end

    UpdateVisuals()
    return container
end

-- ============================================================
-- DEBUG CATEGORY ROW
-- A wide row with checkbox + bold category name + description.
-- The whole row is clickable, hover shows a background highlight,
-- and the description is also surfaced as a tooltip on hover so it
-- remains accessible even if it gets visually truncated.
--
-- Used by the Debug > Categories sub-tab. The categoryKey writes
-- directly to DandersFramesDB_v2.debug.filters.
-- ============================================================
function GUI:CreateDebugCategoryRow(parent, categoryKey, description, width)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width or 520, 28)
    row:EnableMouse(true)

    -- Hover background
    row.hoverBg = row:CreateTexture(nil, "BACKGROUND")
    row.hoverBg:SetAllPoints()
    row.hoverBg:SetColorTexture(1, 1, 1, 0.05)
    row.hoverBg:Hide()

    -- Checkbox
    local cb = CreateFrame("CheckButton", nil, row, "BackdropTemplate")
    cb:SetSize(16, 16)
    cb:SetPoint("LEFT", 4, 0)
    CreateElementBackdrop(cb)
    cb.Check = cb:CreateTexture(nil, "OVERLAY")
    cb.Check:SetTexture("Interface\\Buttons\\WHITE8x8")
    local c = GetThemeColor()
    cb.Check:SetVertexColor(c.r, c.g, c.b)
    cb.Check:SetPoint("CENTER")
    cb.Check:SetSize(9, 9)
    cb:SetCheckedTexture(cb.Check)
    cb:EnableMouse(false)  -- forward clicks to the row

    -- Theme listener so the checkmark colour stays in sync
    cb.UpdateTheme = function()
        local nc = GetThemeColor()
        cb.Check:SetVertexColor(nc.r, nc.g, nc.b)
    end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, cb)

    -- Category name (bold, full opacity)
    local nameTxt = row:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    nameTxt:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    nameTxt:SetWidth(86)
    nameTxt:SetJustifyH("LEFT")
    nameTxt:SetText(categoryKey)
    nameTxt:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    -- Description (dim, fills remaining space, wraps if too long)
    if description and description ~= "" then
        local descTxt = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        descTxt:SetPoint("LEFT", nameTxt, "RIGHT", 12, 0)
        descTxt:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        descTxt:SetJustifyH("LEFT")
        descTxt:SetText(description)
        descTxt:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        row.descTxt = descTxt
    end

    -- State helpers — read/write filters[categoryKey]
    -- Absent or true = logged, explicit false = not logged
    row.RefreshState = function()
        local filters = DandersFramesDB_v2 and DandersFramesDB_v2.debug and DandersFramesDB_v2.debug.filters
        local checked = (not filters) or filters[categoryKey] ~= false
        cb:SetChecked(checked)
    end

    local function ToggleState()
        local filters = DandersFramesDB_v2 and DandersFramesDB_v2.debug and DandersFramesDB_v2.debug.filters
        if not filters then return end
        -- Toggle: false -> true, anything else -> false
        if filters[categoryKey] == false then
            filters[categoryKey] = true
        else
            filters[categoryKey] = false
        end
        row.RefreshState()
        if DF.DebugConsole then DF.DebugConsole:RefreshDisplay() end
    end

    row:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then ToggleState() end
    end)

    row:SetScript("OnEnter", function(self)
        self.hoverBg:Show()
        if description and description ~= "" then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(categoryKey, 1, 1, 1)
            GameTooltip:AddLine(description, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(self)
        self.hoverBg:Hide()
        GameTooltip:Hide()
    end)

    row:SetScript("OnShow", row.RefreshState)
    row.RefreshState()

    return row
end

function GUI:CreateInput(parent, label, width)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width or 180, 44)
    
    local lbl = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    local editbox = CreateFrame("EditBox", nil, frame)
    editbox:SetPoint("TOPLEFT", 0, -15)
    editbox:SetPoint("TOPRIGHT", 0, -15)
    editbox:SetHeight(24)
    if not editbox.SetBackdrop then Mixin(editbox, BackdropTemplateMixin) end
    editbox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    editbox:SetBackdropColor(0, 0, 0, 0.5)
    editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    editbox:SetFontObject(DFFontHighlightSmall)
    editbox:SetTextInsets(5, 5, 0, 0)
    editbox:SetAutoFocus(false)
    editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editbox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    
    frame.EditBox = editbox
    return frame
end

-- CreateEditBox: Text input with db binding (for settings like custom text)
function GUI:CreateEditBox(parent, label, dbTable, dbKey, callback, width)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width or 180, 44)
    
    local lbl = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Add override indicators if dbKey is provided
    if dbKey and type(dbKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if dbTable and dbKey then
                    dbTable[dbKey] = globalVal
                end
                if frame.EditBox then
                    frame.EditBox:SetText(globalVal or "")
                end
                if frame.UpdateOverrideIndicators then
                    frame:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
                if callback then callback() end
            end
        end
        AddOverrideIndicators(frame, lbl, dbKey, onReset, 6, nil, dbTable)
    end
    
    local editbox = CreateFrame("EditBox", nil, frame)
    editbox:SetPoint("TOPLEFT", 0, -15)
    editbox:SetPoint("TOPRIGHT", 0, -15)
    editbox:SetHeight(24)
    if not editbox.SetBackdrop then Mixin(editbox, BackdropTemplateMixin) end
    editbox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    editbox:SetBackdropColor(0, 0, 0, 0.5)
    editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    editbox:SetFontObject(DFFontHighlightSmall)
    editbox:SetTextInsets(5, 5, 0, 0)
    editbox:SetAutoFocus(false)
    
    -- Set initial value from db
    if dbTable and dbKey then
        editbox:SetText(dbTable[dbKey] or "")
    end
    
    -- Save on enter or focus lost
    local function SaveValue()
        if dbTable and dbKey then
            local val = editbox:GetText()
            -- Runtime override protection
            if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
               and DF.AutoProfilesUI:HandleRuntimeWrite(dbKey, val) then
                if frame.UpdateOverrideIndicators then frame:UpdateOverrideIndicators(val) end
                return
            end
            dbTable[dbKey] = val
            -- Track override when editing a profile
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                DF.AutoProfilesUI:SetProfileSetting(dbKey, val)
            end
            if frame.UpdateOverrideIndicators then
                frame:UpdateOverrideIndicators(val)
            end
            if callback then callback() end
        end
    end
    
    editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editbox:SetScript("OnEnterPressed", function(self)
        SaveValue()
        self:ClearFocus()
    end)
    editbox:SetScript("OnEditFocusLost", SaveValue)
    
    -- Refresh override indicators on show
    frame:SetScript("OnShow", function()
        if dbTable and dbKey then
            editbox:SetText(dbTable[dbKey] or "")
        end
        if frame.UpdateOverrideIndicators then
            frame:UpdateOverrideIndicators(dbTable and dbTable[dbKey])
        end
    end)
    
    frame.EditBox = editbox
    return frame
end

function GUI:CreateSlider(parent, label, minVal, maxVal, step, dbTable, dbKey, callback, lightweightUpdate, usePreviewMode)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 50)
    
    -- Label
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Add override indicators if dbKey is provided (for auto profiles)
    -- Use vertical offset of 6 to align with label row (sliders have input box below)
    if dbKey and type(dbKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                -- Refresh to global value
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                dbTable[dbKey] = globalVal
                -- Update slider display
                if container.slider then
                    container.slider:SetValue(globalVal)
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
            end
        end
        AddOverrideIndicators(container, lbl, dbKey, onReset, 6, nil, dbTable)
    end

    -- Background track
    local track = CreateFrame("Frame", nil, container, "BackdropTemplate")
    track:SetPoint("TOPLEFT", 0, -18)
    track:SetSize(180, 8)
    CreateElementBackdrop(track)
    
    -- Fill track (colored portion)
    local fill = track:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", 1, 0)
    fill:SetHeight(6)
    local c = GetThemeColor()
    fill:SetColorTexture(c.r, c.g, c.b, 0.8)
    
    -- Slider
    local slider = CreateFrame("Slider", nil, container)
    slider:SetPoint("TOPLEFT", 0, -18)
    slider:SetSize(180, 8)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetHitRectInsets(-4, -4, -8, -8)
    container.slider = slider  -- Store reference for reset
    
    -- Track whether this slider is actively being dragged
    local isDragging = false
    
    -- Store preview mode flag for this slider
    local sliderUsePreviewMode = usePreviewMode or false
    
    -- Thumb
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 16)
    thumb:SetColorTexture(c.r, c.g, c.b, 1)
    slider:SetThumbTexture(thumb)
    
    -- Value input
    local input = CreateFrame("EditBox", nil, container, "BackdropTemplate")
    input:SetPoint("LEFT", track, "RIGHT", 8, 0)
    input:SetSize(50, 20)
    CreateElementBackdrop(input)
    input:SetFontObject(DFFontHighlightSmall)
    input:SetJustifyH("CENTER")
    input:SetAutoFocus(false)
    input:SetTextInsets(2, 2, 0, 0)
    
    local function UpdateFill()
        local val = slider:GetValue()
        local pct = (val - minVal) / (maxVal - minVal)
        fill:SetWidth(math.max(1, pct * 178))
    end
    
    container.SetEnabled = function(self, enabled)
        slider:SetEnabled(enabled)
        input:EnableMouse(enabled)
        local tc = GetThemeColor()
        if enabled then
            lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            thumb:SetColorTexture(tc.r, tc.g, tc.b, 1)
            fill:SetColorTexture(tc.r, tc.g, tc.b, 0.8)
        else
            lbl:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            thumb:SetColorTexture(0.4, 0.4, 0.4, 1)
            fill:SetColorTexture(0.4, 0.4, 0.4, 0.5)
        end
    end
    
    container.UpdateTheme = function()
        local nc = GetThemeColor()
        if slider:IsEnabled() then
            thumb:SetColorTexture(nc.r, nc.g, nc.b, 1)
            fill:SetColorTexture(nc.r, nc.g, nc.b, 0.8)
        end
    end
    if not parent.ThemeListeners then parent.ThemeListeners = {} end
    table.insert(parent.ThemeListeners, container)
    
    local suppressCallback = false
    
    -- Smart format: show whole numbers as integers, decimals with minimum precision needed
    local function FormatValue(val)
        if val == math.floor(val) then
            return string.format("%d", val)
        elseif val * 10 == math.floor(val * 10) then
            return string.format("%.1f", val)
        else
            return string.format("%.2f", val)
        end
    end
    
    local function UpdateValue(val)
        val = val or minVal
        suppressCallback = true
        slider:SetValue(val)
        suppressCallback = false
        input:SetText(FormatValue(val))
        UpdateFill()
        -- Update override indicators
        if container.UpdateOverrideIndicators then
            container:UpdateOverrideIndicators(val)
        end
    end
    
    -- Track drag start - pass the lightweight update function, name for debug, and preview mode
    slider:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            isDragging = true
            local funcName = lightweightUpdate and (dbKey .. " lightweight") or nil
            DF:OnSliderDragStart(lightweightUpdate, funcName, sliderUsePreviewMode)
        end
    end)
    
    -- Track drag end - do full update when slider is released
    slider:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and isDragging then
            isDragging = false
            DF:OnSliderDragStop()
            -- Update override indicators after drag ends
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(slider:GetValue())
            end
        end
    end)
    
    slider:SetScript("OnShow", function()
        if dbTable then UpdateValue(dbTable[dbKey]) end
    end)
    
    slider:SetScript("OnValueChanged", function(self, value)
        if suppressCallback then return end
        if not dbTable then return end
        if step >= 1 then
            value = math.floor(value + 0.5)
        else
            value = math.floor(value / step + 0.5) * step
        end

        -- Runtime override protection: redirect to baseline, skip refresh
        if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
           and DF.AutoProfilesUI:HandleRuntimeWrite(dbKey, value) then
            if not input:HasFocus() then input:SetText(FormatValue(value)) end
            UpdateFill()
            if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(value) end
            return
        end

        dbTable[dbKey] = value

        -- If editing a profile, also set the override
        if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
            DF.AutoProfilesUI:SetProfileSetting(dbKey, value)
        end
        
        if not input:HasFocus() then
            input:SetText(FormatValue(value))
        end
        UpdateFill()
        -- Use targeted update system - lightweight during drag, full on release
        DF:ThrottledUpdateAll()
        -- Skip callback during drag - it will run via UpdateAll on release
        if callback and not DF.sliderDragging then
            callback()
        end
    end)
    
    input:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            val = math.max(minVal, math.min(maxVal, val))

            -- Runtime override protection: redirect to baseline, skip refresh
            if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
               and DF.AutoProfilesUI:HandleRuntimeWrite(dbKey, val) then
                self:SetText(FormatValue(val))
                suppressCallback = true
                slider:SetValue(val)
                suppressCallback = false
                UpdateFill()
                if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(val) end
                self:ClearFocus()
                return
            end

            dbTable[dbKey] = val
            suppressCallback = true
            slider:SetValue(val)
            suppressCallback = false

            -- Update input text to show actual value entered
            self:SetText(FormatValue(val))
            UpdateFill()

            -- If editing a profile, also set the override
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                DF.AutoProfilesUI:SetProfileSetting(dbKey, val)
            end

            -- Update override indicators
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(val)
            end

            -- FIX 2025-01-20: Call callback OR lightweightUpdate (some sliders have nil callback)
            if callback then
                callback()
            elseif lightweightUpdate then
                lightweightUpdate()
            end

            -- Guaranteed full update (SetValue may not fire OnValueChanged if value didn't change)
            DF:UpdateAll()
        else
            UpdateValue(dbTable[dbKey])
        end
        self:ClearFocus()
    end)
    
    input:SetScript("OnEscapePressed", function(self)
        UpdateValue(dbTable[dbKey])
        self:ClearFocus()
    end)
    
    if dbTable then UpdateValue(dbTable[dbKey]) end
    
    -- SEARCH: Register this setting with slider metadata
    if DF.Search and dbKey and type(dbKey) == "string" then
        container.searchEntry = DF.Search:RegisterSlider(label, dbKey, minVal, maxVal, step, nil)
    end
    
    -- Expose label for dynamic updates
    container.label = lbl
    
    return container
end

function GUI:CreateColorPicker(parent, label, dbTable, dbKey, hasAlpha, callback, lightweightCallback, useLightweight)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 28)
    
    -- Button - use relative anchoring so it resizes with container
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetPoint("TOPLEFT", 0, 0)
    btn:SetPoint("TOPRIGHT", 0, 0)
    btn:SetHeight(24)
    CreateElementBackdrop(btn)
    
    -- Label
    local txt = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    txt:SetPoint("LEFT", 8, 0)
    txt:SetText(label)
    txt:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Color swatch
    local swatch = btn:CreateTexture(nil, "OVERLAY")
    swatch:SetSize(40, 16)
    swatch:SetPoint("RIGHT", -6, 0)
    
    -- Add override indicators if dbKey is provided (for auto profiles)
    if dbKey and type(dbKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                -- Refresh to global value
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if globalVal then
                    dbTable[dbKey].r = globalVal.r
                    dbTable[dbKey].g = globalVal.g
                    dbTable[dbKey].b = globalVal.b
                    dbTable[dbKey].a = globalVal.a or 1
                end
                if container.UpdateSwatch then
                    container:UpdateSwatch()
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(dbTable[dbKey])
                end
                DF:UpdateAll()
            end
        end
        AddOverrideIndicators(container, txt, dbKey, onReset, nil, nil, dbTable)
    end
    
    local function UpdateSwatch()
        if dbTable and dbKey and dbTable[dbKey] then
            local c = dbTable[dbKey]
            swatch:SetColorTexture(c.r, c.g, c.b, c.a or 1)
            -- Update override indicators
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(c)
            end
        end
    end
    container.UpdateSwatch = UpdateSwatch  -- Expose for reset
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)
    
    btn:SetScript("OnClick", function()
        if not dbTable then return end
        local c = dbTable[dbKey]
        if not c then 
            c = {r = 1, g = 1, b = 1, a = 1}
            dbTable[dbKey] = c
        end
        
        -- Store original values for cancel
        local originalColor = {r = c.r, g = c.g, b = c.b, a = c.a or 1}
        
        local info = {
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = 1
                if hasAlpha and ColorPickerFrame.GetColorAlpha then
                    a = ColorPickerFrame:GetColorAlpha() or 1
                end
                dbTable[dbKey].r = r
                dbTable[dbKey].g = g
                dbTable[dbKey].b = b
                dbTable[dbKey].a = a
                
                -- If editing a profile, also set the override
                if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                    DF.AutoProfilesUI:SetProfileSetting(dbKey, {r = r, g = g, b = b, a = a})
                end
                
                UpdateSwatch()
                -- Use lightweight callback during dragging if available
                if useLightweight and lightweightCallback then
                    lightweightCallback()
                else
                    DF:ThrottledUpdateAll()
                    if callback then callback() end
                end
            end,
            hasOpacity = hasAlpha,
            opacityFunc = hasAlpha and function()
                if ColorPickerFrame.GetColorAlpha then
                    local a = ColorPickerFrame:GetColorAlpha()
                    if a then
                        dbTable[dbKey].a = a
                        UpdateSwatch()
                        -- Use lightweight callback during dragging if available
                        if useLightweight and lightweightCallback then
                            lightweightCallback()
                        else
                            DF:ThrottledUpdateAll()
                            if callback then callback() end
                        end
                    end
                end
            end or nil,
            cancelFunc = function(restore)
                -- Restore original color on cancel
                dbTable[dbKey].r = originalColor.r
                dbTable[dbKey].g = originalColor.g
                dbTable[dbKey].b = originalColor.b
                dbTable[dbKey].a = originalColor.a
                UpdateSwatch()
                DF:UpdateAll()
                if callback then callback() end
            end,
            r = c.r or 1, 
            g = c.g or 1, 
            b = c.b or 1, 
            opacity = hasAlpha and (c.a or 1) or nil,
        }
        
        -- Hook the OK button to run full update when confirmed
        if useLightweight and lightweightCallback then
            -- We need to run full update when picker is closed via OK
            local oldSetup = ColorPickerFrame.SetupColorPickerAndShow
            local function OnPickerClosed()
                DF:UpdateAll()
                if callback then callback() end
            end
            -- Use a frame to detect when color picker closes
            if not container.colorPickerWatcher then
                container.colorPickerWatcher = CreateFrame("Frame")
            end
            container.colorPickerWatcher:SetScript("OnUpdate", function(self)
                if not ColorPickerFrame:IsShown() then
                    self:SetScript("OnUpdate", nil)
                    -- Only run if color changed (not cancelled)
                    local cur = dbTable[dbKey]
                    if cur.r ~= originalColor.r or cur.g ~= originalColor.g or 
                       cur.b ~= originalColor.b or cur.a ~= originalColor.a then
                        DF:UpdateAll()
                        if callback then callback() end
                    end
                end
            end)
        end
        
        -- Mark this as a DandersFrames color picker call
        GUI:MarkColorPickerCall()
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    
    container.SetEnabled = function(self, enabled)
        btn:SetEnabled(enabled)
        if enabled then
            txt:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            swatch:SetDesaturated(false)
        else
            txt:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            swatch:SetDesaturated(true)
        end
    end
    
    btn:SetScript("OnShow", UpdateSwatch)
    UpdateSwatch()
    
    -- SEARCH: Register this setting
    if DF.Search and dbKey and type(dbKey) == "string" then
        container.searchEntry = DF.Search:RegisterColorPicker(label, dbKey, hasAlpha, nil)
    end
    
    return container
end

function GUI:CreateDropdown(parent, label, options, dbTable, dbKey, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 50)

    -- Label
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    -- Expose label so helpers like AddSectionNewBadge can anchor a badge to it.
    container.label = lbl
    
    -- Add override indicators if dbKey is provided (for auto profiles)
    if dbKey and type(dbKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                -- Refresh to global value
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                dbTable[dbKey] = globalVal
                if container.UpdateText then
                    container:UpdateText()
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
            end
        end
        AddOverrideIndicators(container, lbl, dbKey, onReset, 6, options, dbTable)
    end

    -- Button - use relative anchoring so it resizes with container
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetPoint("TOPLEFT", 0, -16)
    btn:SetPoint("TOPRIGHT", 0, -16)
    btn:SetHeight(24)
    CreateElementBackdrop(btn)
    
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -20, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Arrow indicator
    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local function UpdateText()
        if dbTable and dbKey then
            local val = dbTable[dbKey]
            local displayVal = options[val]
            -- Handle table format: {value = X, text = "text"} or {text = "text"}
            if type(displayVal) == "table" then
                displayVal = displayVal.text or displayVal.label or tostring(val)
            end
            btn.Text:SetText(displayVal or tostring(val) or L["Select..."])
            -- Update override indicators
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(val)
            end
        end
    end
    container.UpdateText = UpdateText  -- Expose for reset
    
    -- Menu frame
    local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    menuFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetClampedToScreen(true)
    CreateElementBackdrop(menuFrame)
    menuFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.98)
    menuFrame:Hide()
    
    -- Clear tracking when hidden
    menuFrame:SetScript("OnHide", function()
        if currentOpenDropdown == menuFrame then
            currentOpenDropdown = nil
        end
    end)
    
    local menuButtons = {}
    local menuHeight = 0
    local sortedOptions = {}
    
    -- Check for custom order array
    if options._order then
        -- Use specified order
        for _, k in ipairs(options._order) do
            if options[k] then
                table.insert(sortedOptions, {key = k, value = options[k]})
            end
        end
    else
        -- Default: sort alphabetically by display value
        for k, v in pairs(options) do
            -- Handle both formats: KEY = "text" or KEY = {value = X, text = "text"}
            local displayValue = type(v) == "table" and (v.text or v.label or tostring(k)) or v
            table.insert(sortedOptions, {key = k, value = displayValue})
        end
        table.sort(sortedOptions, function(a, b)
            local aVal = type(a.value) == "string" and a.value or tostring(a.key)
            local bVal = type(b.value) == "string" and b.value or tostring(b.key)
            return aVal < bVal
        end)
    end
    
    for i, opt in ipairs(sortedOptions) do
        local menuBtn = CreateFrame("Button", nil, menuFrame)
        menuBtn:SetPoint("TOPLEFT", 2, -2 - (i - 1) * 22)
        menuBtn:SetPoint("TOPRIGHT", -2, -2 - (i - 1) * 22)
        menuBtn:SetHeight(22)
        
        menuBtn.Text = menuBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        menuBtn.Text:SetPoint("LEFT", 8, 0)
        menuBtn.Text:SetText(opt.value)
        menuBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        
        menuBtn.Highlight = menuBtn:CreateTexture(nil, "HIGHLIGHT")
        menuBtn.Highlight:SetAllPoints()
        local c = GetThemeColor()
        menuBtn.Highlight:SetColorTexture(c.r, c.g, c.b, 0.3)
        
        menuBtn:SetScript("OnClick", function()
            -- Runtime override protection: redirect to baseline, skip refresh
            if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
               and DF.AutoProfilesUI:HandleRuntimeWrite(dbKey, opt.key) then
                UpdateText()
                menuFrame:Hide()
                if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(opt.key) end
                return
            end

            dbTable[dbKey] = opt.key

            -- If editing a profile, also set the override
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                DF.AutoProfilesUI:SetProfileSetting(dbKey, opt.key)
            end

            UpdateText()
            menuFrame:Hide()
            DF:UpdateAll()
            if callback then callback() end
            if parent.RefreshStates then parent:RefreshStates() end
        end)
        
        table.insert(menuButtons, menuBtn)
        menuHeight = menuHeight + 22
    end
    
    -- Menu frame width matches button width
    menuFrame:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)
    menuFrame:SetHeight(menuHeight + 4)
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)
    
    btn:SetScript("OnClick", function(self)
        if menuFrame:IsShown() then
            menuFrame:Hide()
            currentOpenDropdown = nil
        else
            -- Close any other open dropdown first
            CloseOpenDropdown()
            for i, menuBtn in ipairs(menuButtons) do
                local opt = sortedOptions[i]
                if dbTable[dbKey] == opt.key then
                    menuBtn.Text:SetTextColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b)
                else
                    menuBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                end
            end
            menuFrame:Show()
            currentOpenDropdown = menuFrame
        end
    end)
    
    btn:SetScript("OnShow", UpdateText)
    UpdateText()
    
    container.SetEnabled = function(self, enabled)
        btn:SetEnabled(enabled)
        if enabled then
            lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        else
            lbl:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            btn.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
    end
    
    -- SEARCH: Register this setting
    if DF.Search and dbKey and type(dbKey) == "string" then
        container.searchEntry = DF.Search:RegisterDropdown(label, dbKey, options, nil)
    end
    
    return container
end

-- ============================================================
-- GROWTH DIRECTION CONTROL
-- Three linked dropdowns (Orientation, Wrap, Direction) that
-- compose into a single growth value like "LEFT_UP"
-- ============================================================

-- Decompose "LEFT_UP" into {orientation, wrap, direction}
local function DecomposeGrowth(growth)
    local primary, secondary = strsplit("_", growth or "LEFT_UP")
    if not secondary then
        -- Malformed value (no underscore) — fall back to LEFT_UP
        return "HORIZONTAL", "UP", "LEFT"
    end
    if primary == "CENTER" then
        if secondary == "UP" or secondary == "DOWN" then
            return "HORIZONTAL", secondary, "CENTER"
        else
            return "VERTICAL", secondary, "CENTER"
        end
    elseif primary == "LEFT" or primary == "RIGHT" then
        return "HORIZONTAL", secondary, primary
    else
        return "VERTICAL", secondary, primary
    end
end

-- Compose {orientation, wrap, direction} back into "LEFT_UP"
local function ComposeGrowth(orientation, wrap, direction)
    -- Safety: if wrap is nil, pick a sensible default for the orientation
    if not wrap then
        wrap = (orientation == "HORIZONTAL") and "UP" or "LEFT"
    end
    if direction == "CENTER" then
        return "CENTER_" .. wrap
    else
        return direction .. "_" .. (wrap or "UP")
    end
end

-- Map values when switching orientation so the selection stays sensible
local ORIENTATION_MAP = {
    UP = "LEFT", DOWN = "RIGHT", LEFT = "UP", RIGHT = "DOWN",
}

function GUI:CreateGrowthControl(parent, db, dbKey, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 155)

    -- Read current decomposed state
    local curOrientation, curWrap, curDirection = DecomposeGrowth(db[dbKey] or "LEFT_UP")

    -- Option tables per orientation
    local ORIENT_OPTIONS = {
        HORIZONTAL = "Horizontal",
        VERTICAL = "Vertical",
        _order = {"HORIZONTAL", "VERTICAL"},
    }
    local WRAP_OPTIONS = {
        HORIZONTAL = { UP = "Up", DOWN = "Down", _order = {"UP", "DOWN"} },
        VERTICAL = { LEFT = "Left", RIGHT = "Right", _order = {"LEFT", "RIGHT"} },
    }
    local DIR_OPTIONS = {
        HORIZONTAL = { LEFT = "Left", CENTER = "Center", RIGHT = "Right", _order = {"LEFT", "CENTER", "RIGHT"} },
        VERTICAL = { UP = "Up", CENTER = "Center", DOWN = "Down", _order = {"UP", "CENTER", "DOWN"} },
    }

    -- Shared write-back: recompose and save
    local function WriteBack()
        db[dbKey] = ComposeGrowth(curOrientation, curWrap, curDirection)
        DF:UpdateAll()
        if callback then callback() end
        if parent.RefreshStates then parent:RefreshStates() end
    end

    -- Sub-dropdown builder (simplified version of CreateDropdown, no override indicators)
    local function BuildMiniDropdown(yOffset, label, options, getValue, setValue)
        local frame = CreateFrame("Frame", nil, container)
        frame:SetPoint("TOPLEFT", 0, yOffset)
        frame:SetPoint("TOPRIGHT", 0, yOffset)
        frame:SetHeight(50)

        local lbl = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        lbl:SetPoint("TOPLEFT", 0, 0)
        lbl:SetText(label)
        lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

        local btn = CreateFrame("Button", nil, frame, "BackdropTemplate")
        btn:SetPoint("TOPLEFT", 0, -16)
        btn:SetPoint("TOPRIGHT", 0, -16)
        btn:SetHeight(24)
        CreateElementBackdrop(btn)

        btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btn.Text:SetPoint("LEFT", 8, 0)
        btn.Text:SetPoint("RIGHT", -20, 0)
        btn.Text:SetJustifyH("LEFT")
        btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

        local arrow = btn:CreateTexture(nil, "OVERLAY")
        arrow:SetPoint("RIGHT", -8, 0)
        arrow:SetSize(12, 12)
        arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
        arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

        local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        menuFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
        menuFrame:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)
        menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        menuFrame:SetClampedToScreen(true)
        CreateElementBackdrop(menuFrame)
        menuFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.98)
        menuFrame:Hide()

        menuFrame:SetScript("OnHide", function()
            if currentOpenDropdown == menuFrame then
                currentOpenDropdown = nil
            end
        end)

        local menuButtons = {}

        -- Rebuild populates menu items from current options
        frame.Rebuild = function(self, newOptions)
            for _, mb in ipairs(menuButtons) do mb:Hide() end
            wipe(menuButtons)

            local sorted = {}
            if newOptions._order then
                for _, k in ipairs(newOptions._order) do
                    if newOptions[k] then
                        sorted[#sorted + 1] = { key = k, value = newOptions[k] }
                    end
                end
            else
                for k, v in pairs(newOptions) do
                    if k ~= "_order" then
                        sorted[#sorted + 1] = { key = k, value = v }
                    end
                end
                table.sort(sorted, function(a, b) return a.value < b.value end)
            end

            local menuHeight = 0
            for i, opt in ipairs(sorted) do
                local menuBtn = CreateFrame("Button", nil, menuFrame)
                menuBtn:SetPoint("TOPLEFT", 2, -2 - (i - 1) * 22)
                menuBtn:SetPoint("TOPRIGHT", -2, -2 - (i - 1) * 22)
                menuBtn:SetHeight(22)

                menuBtn.Text = menuBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                menuBtn.Text:SetPoint("LEFT", 8, 0)
                menuBtn.Text:SetText(opt.value)
                menuBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

                menuBtn.Highlight = menuBtn:CreateTexture(nil, "HIGHLIGHT")
                menuBtn.Highlight:SetAllPoints()
                local c = GetThemeColor()
                menuBtn.Highlight:SetColorTexture(c.r, c.g, c.b, 0.3)

                menuBtn:SetScript("OnClick", function()
                    setValue(opt.key)
                    WriteBack()
                    btn.Text:SetText(opt.value)
                    menuFrame:Hide()
                end)

                menuButtons[#menuButtons + 1] = menuBtn
                menuHeight = menuHeight + 22
            end
            menuFrame:SetHeight(menuHeight + 4)

            -- Update displayed text
            local curVal = getValue()
            btn.Text:SetText(newOptions[curVal] or tostring(curVal) or L["Select..."])
        end

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        end)

        btn:SetScript("OnClick", function(self)
            if menuFrame:IsShown() then
                menuFrame:Hide()
                currentOpenDropdown = nil
            else
                CloseOpenDropdown()
                -- Highlight current selection
                local curVal = getValue()
                local curDisplay = options[curVal]
                for _, mb in ipairs(menuButtons) do
                    if mb.Text:GetText() == curDisplay then
                        mb.Text:SetTextColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b)
                    else
                        mb.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                    end
                end
                menuFrame:Show()
                currentOpenDropdown = menuFrame
            end
        end)

        -- Expose btn for external enable/disable
        frame.btn = btn
        frame:Rebuild(options)
        return frame
    end

    -- Build the three dropdowns (forward-declare wrap/dir so orientation callback can reference them)
    local wrapDD, dirDD
    local orientDD = BuildMiniDropdown(0, "Orientation", ORIENT_OPTIONS,
        function() return curOrientation end,
        function(val)
            if val ~= curOrientation then
                -- Map wrap and direction to the new orientation
                curWrap = ORIENTATION_MAP[curWrap] or curWrap
                curDirection = (curDirection == "CENTER") and "CENTER" or (ORIENTATION_MAP[curDirection] or curDirection)
                curOrientation = val
                -- Rebuild dependent dropdowns with new options
                wrapDD:Rebuild(WRAP_OPTIONS[curOrientation])
                dirDD:Rebuild(DIR_OPTIONS[curOrientation])
            end
        end
    )

    wrapDD = BuildMiniDropdown(-50, "Wrap", WRAP_OPTIONS[curOrientation],
        function() return curWrap end,
        function(val) curWrap = val end
    )

    dirDD = BuildMiniDropdown(-100, "Direction", DIR_OPTIONS[curOrientation],
        function() return curDirection end,
        function(val) curDirection = val end
    )

    -- SetEnabled support for disableOn (disable the actual clickable buttons)
    container.SetEnabled = function(self, enabled)
        local alpha = enabled and 1.0 or 0.4
        self:SetAlpha(alpha)
        orientDD.btn:SetEnabled(enabled)
        wrapDD.btn:SetEnabled(enabled)
        dirDD.btn:SetEnabled(enabled)
    end

    -- Refresh from db (e.g., after profile switch)
    container.refreshContent = function(self)
        curOrientation, curWrap, curDirection = DecomposeGrowth(db[dbKey] or "LEFT_UP")
        orientDD:Rebuild(ORIENT_OPTIONS)
        wrapDD:Rebuild(WRAP_OPTIONS[curOrientation])
        dirDD:Rebuild(DIR_OPTIONS[curOrientation])
    end

    return container
end

-- ============================================================
-- TEXTURE DROPDOWN WITH PREVIEW
-- ============================================================

function GUI:CreateTextureDropdown(parent, label, dbTable, dbKey, callback, customOptions)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 50)

    -- Label
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    -- Add override indicators if dbKey is provided
    if dbKey and type(dbKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if dbTable and dbKey then
                    dbTable[dbKey] = globalVal
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
                if callback then callback() end
            end
        end
        AddOverrideIndicators(container, lbl, dbKey, onReset, 6, nil, dbTable)
    end
    
    -- Button - use relative anchoring so it resizes with container
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetPoint("TOPLEFT", 0, -16)
    btn:SetPoint("TOPRIGHT", 0, -16)
    btn:SetHeight(24)
    CreateElementBackdrop(btn)
    
    -- Texture preview on button
    btn.Preview = btn:CreateTexture(nil, "ARTWORK")
    btn.Preview:SetPoint("LEFT", 4, 0)
    btn.Preview:SetSize(80, 16)
    
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 90, 0)
    btn.Text:SetPoint("RIGHT", -20, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Arrow indicator
    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local function UpdateText()
        if dbTable and dbKey then
            local val = dbTable[dbKey]
            local displayName
            if customOptions then
                -- Use custom options lookup
                displayName = customOptions[val]
            else
                -- Use robust SharedMedia lookup
                displayName = DF:GetTextureNameFromPath(val)
            end
            btn.Text:SetText(displayName or L["Select..."])
            -- Handle "Solid" special case (not a valid texture path)
            if val == "Solid" then
                btn.Preview:SetColorTexture(0.3, 0.3, 0.3, 1)
            else
                btn.Preview:SetTexture(val)
                btn.Preview:SetVertexColor(0.3, 0.7, 0.3)  -- Green tint for preview
            end
        end
    end
    
    -- Menu frame with scroll
    local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    menuFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetClampedToScreen(true)
    CreateElementBackdrop(menuFrame)
    menuFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.98)
    menuFrame:Hide()
    
    -- Search box at top of menu
    local SEARCH_HEIGHT = 26
    local searchBox = CreateFrame("EditBox", nil, menuFrame, "BackdropTemplate")
    searchBox:SetPoint("TOPLEFT", 4, -4)
    searchBox:SetPoint("TOPRIGHT", -4, -4)
    searchBox:SetHeight(22)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(DFFontHighlightSmall)
    searchBox:SetTextInsets(24, 8, 0, 0)
    CreateElementBackdrop(searchBox)
    searchBox:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Search icon
    local searchIcon = searchBox:CreateTexture(nil, "OVERLAY")
    searchIcon:SetPoint("LEFT", 6, 0)
    searchIcon:SetSize(12, 12)
    searchIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\search")
    searchIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Placeholder text
    local placeholder = searchBox:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    placeholder:SetPoint("LEFT", 24, 0)
    placeholder:SetText(L["Search textures..."])
    placeholder:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.6)
    
    searchBox:SetScript("OnEditFocusGained", function() placeholder:Hide() end)
    searchBox:SetScript("OnEditFocusLost", function() 
        if searchBox:GetText() == "" then placeholder:Show() end
    end)
    
    -- Clear tracking when hidden
    menuFrame:SetScript("OnHide", function()
        if currentOpenDropdown == menuFrame then
            currentOpenDropdown = nil
        end
        searchBox:SetText("")
        searchBox:ClearFocus()
        placeholder:Show()
    end)
    
    -- Scroll frame - positioned below search box
    local scrollFrame = CreateFrame("ScrollFrame", nil, menuFrame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 2, -(SEARCH_HEIGHT + 4))
    scrollFrame:SetPoint("BOTTOMRIGHT", -20, 2)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(234)  -- Match button width for texture dropdown
    scrollFrame:SetScrollChild(scrollChild)
    
    StyleScrollBar(scrollFrame)

    local menuButtons = {}
    local ITEM_HEIGHT = 28
    local MAX_VISIBLE = 8
    
    -- Function to rebuild menu with current textures
    local function RebuildMenu(filterText)
        -- Clear old buttons
        for _, menuBtn in ipairs(menuButtons) do
            menuBtn:Hide()
            menuBtn:SetParent(nil)
        end
        wipe(menuButtons)
        
        -- Get fresh texture list (use custom options if provided)
        local options = customOptions or DF:GetTextureList()
        local sortedOptions = {}
        
        -- Apply filter if provided
        filterText = filterText and filterText:lower() or ""
        
        for k, v in pairs(options) do
            if filterText == "" or v:lower():find(filterText, 1, true) then
                table.insert(sortedOptions, {key = k, value = v})
            end
        end
        table.sort(sortedOptions, function(a, b) return a.value < b.value end)
        
        -- Resize menu and scroll child
        local menuHeight = math.min(#sortedOptions, MAX_VISIBLE) * ITEM_HEIGHT + SEARCH_HEIGHT + 8
        menuFrame:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)
        menuFrame:SetHeight(menuHeight)
        scrollChild:SetHeight(#sortedOptions * ITEM_HEIGHT)
        
        -- Hide scrollbar if not needed
        if scrollBar then
            if #sortedOptions <= MAX_VISIBLE then
                scrollBar:Hide()
            else
                scrollBar:Show()
            end
        end
        
        -- Create new buttons
        for i, opt in ipairs(sortedOptions) do
            local menuBtn = CreateFrame("Button", nil, scrollChild)
            menuBtn:SetSize(234, ITEM_HEIGHT)
            menuBtn:SetPoint("TOPLEFT", 0, -(i - 1) * ITEM_HEIGHT)
            
            -- Texture preview
            menuBtn.Preview = menuBtn:CreateTexture(nil, "ARTWORK")
            menuBtn.Preview:SetPoint("LEFT", 4, 0)
            menuBtn.Preview:SetSize(80, 18)
            -- Handle "Solid" special case
            if opt.key == "Solid" then
                menuBtn.Preview:SetColorTexture(0.3, 0.3, 0.3, 1)
            else
                menuBtn.Preview:SetTexture(opt.key)
                menuBtn.Preview:SetVertexColor(0.3, 0.7, 0.3)  -- Green tint for preview
            end
            
            menuBtn.Text = menuBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            menuBtn.Text:SetPoint("LEFT", 90, 0)
            menuBtn.Text:SetText(opt.value)
            
            -- Highlight selected item
            if dbTable[dbKey] == opt.key then
                menuBtn.Text:SetTextColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b)
            else
                menuBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end
            
            menuBtn.Highlight = menuBtn:CreateTexture(nil, "HIGHLIGHT")
            menuBtn.Highlight:SetAllPoints()
            local c = GetThemeColor()
            menuBtn.Highlight:SetColorTexture(c.r, c.g, c.b, 0.3)
            
            menuBtn:SetScript("OnClick", function()
                -- Runtime override protection
                if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
                   and DF.AutoProfilesUI:HandleRuntimeWrite(dbKey, opt.key) then
                    UpdateText()
                    menuFrame:Hide()
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(opt.key) end
                    return
                end
                dbTable[dbKey] = opt.key
                -- Track override when editing a profile
                if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                    DF.AutoProfilesUI:SetProfileSetting(dbKey, opt.key)
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(opt.key)
                end
                UpdateText()
                menuFrame:Hide()
                DF:UpdateAll()
                if callback then callback() end
            end)

            table.insert(menuButtons, menuBtn)
        end
    end
    
    -- Search box text changed handler
    searchBox:SetScript("OnTextChanged", function(self)
        RebuildMenu(self:GetText())
    end)
    
    -- Allow escape to close
    searchBox:SetScript("OnEscapePressed", function()
        menuFrame:Hide()
    end)
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)
    
    btn:SetScript("OnClick", function(self)
        if menuFrame:IsShown() then
            menuFrame:Hide()
            currentOpenDropdown = nil
        else
            -- Close any other open dropdown first
            CloseOpenDropdown()
            -- Rebuild menu with current SharedMedia textures
            RebuildMenu()
            menuFrame:Show()
            currentOpenDropdown = menuFrame
            -- Focus search box
            searchBox:SetFocus()
        end
    end)
    
    btn:SetScript("OnShow", UpdateText)
    UpdateText()
    
    -- Refresh override indicators on show
    container:SetScript("OnShow", function()
        UpdateText()
        if container.UpdateOverrideIndicators then
            container:UpdateOverrideIndicators(dbTable and dbTable[dbKey])
        end
    end)
    
    container.SetEnabled = function(self, enabled)
        btn:SetEnabled(enabled)
        if enabled then
            lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        else
            lbl:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            btn.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
    end
    
    -- SEARCH: Register this setting (use current texture list)
    if DF.Search and dbKey and type(dbKey) == "string" then
        local currentOptions = customOptions or DF:GetTextureList()
        container.searchEntry = DF.Search:RegisterDropdown(label, dbKey, currentOptions, nil)
    end
    
    return container
end

-- ============================================================
-- FONT DROPDOWN WITH PREVIEW
-- ============================================================

function GUI:CreateFontDropdown(parent, label, dbTable, dbKey, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 50)

    -- Label
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    -- Add override indicators if dbKey is provided
    if dbKey and type(dbKey) == "string" then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if dbTable and dbKey then
                    dbTable[dbKey] = globalVal
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(globalVal)
                end
                DF:UpdateAll()
                if callback then callback() end
            end
        end
        AddOverrideIndicators(container, lbl, dbKey, onReset, 6, nil, dbTable)
    end
    
    -- Button - use relative anchoring so it resizes with container
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetPoint("TOPLEFT", 0, -16)
    btn:SetPoint("TOPRIGHT", 0, -16)
    btn:SetHeight(24)
    CreateElementBackdrop(btn)
    
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -20, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Arrow indicator
    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local function UpdateText()
        if dbTable and dbKey then
            local val = dbTable[dbKey]
            -- Get font display name (handles both names and legacy paths)
            local displayName = DF:GetFontNameFromPath(val)
            btn.Text:SetText(displayName or L["Select..."])
            -- Try to set the button text to the selected font for preview
            local fontPath = DF:GetFontPath(val)
            if fontPath then
                local success = pcall(function()
                    btn.Text:SetFont(fontPath, 12, "")
                end)
                if not success then
                    btn.Text:SetFontObject(DFFontHighlightSmall)
                end
            end
        end
    end
    
    -- Menu frame with scroll
    local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    menuFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetClampedToScreen(true)
    CreateElementBackdrop(menuFrame)
    menuFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.98)
    menuFrame:Hide()
    
    -- Search box at top of menu
    local SEARCH_HEIGHT = 26
    local searchBox = CreateFrame("EditBox", nil, menuFrame, "BackdropTemplate")
    searchBox:SetPoint("TOPLEFT", 4, -4)
    searchBox:SetPoint("TOPRIGHT", -4, -4)
    searchBox:SetHeight(22)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(DFFontHighlightSmall)
    searchBox:SetTextInsets(24, 8, 0, 0)
    CreateElementBackdrop(searchBox)
    searchBox:SetBackdropColor(0.1, 0.1, 0.1, 1)
    
    -- Search icon
    local searchIcon = searchBox:CreateTexture(nil, "OVERLAY")
    searchIcon:SetPoint("LEFT", 6, 0)
    searchIcon:SetSize(12, 12)
    searchIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\search")
    searchIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Placeholder text
    local placeholder = searchBox:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    placeholder:SetPoint("LEFT", 24, 0)
    placeholder:SetText(L["Search fonts..."])
    placeholder:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.6)
    
    searchBox:SetScript("OnEditFocusGained", function() placeholder:Hide() end)
    searchBox:SetScript("OnEditFocusLost", function() 
        if searchBox:GetText() == "" then placeholder:Show() end
    end)
    
    -- Clear tracking when hidden
    menuFrame:SetScript("OnHide", function()
        if currentOpenDropdown == menuFrame then
            currentOpenDropdown = nil
        end
        searchBox:SetText("")
        searchBox:ClearFocus()
        placeholder:Show()
    end)
    
    -- Scroll frame - positioned below search box
    local scrollFrame = CreateFrame("ScrollFrame", nil, menuFrame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 2, -(SEARCH_HEIGHT + 4))
    scrollFrame:SetPoint("BOTTOMRIGHT", -20, 2)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(234)  -- Match button width for font dropdown
    scrollFrame:SetScrollChild(scrollChild)
    
    StyleScrollBar(scrollFrame)

    local menuButtons = {}
    local ITEM_HEIGHT = 24
    local MAX_VISIBLE = 10

    -- Function to rebuild menu with current fonts
    local function RebuildMenu(filterText)
        -- Clear old buttons
        for _, menuBtn in ipairs(menuButtons) do
            menuBtn:Hide()
            menuBtn:SetParent(nil)
        end
        wipe(menuButtons)
        
        -- Get fresh font list
        local options = DF:GetFontList()
        local sortedOptions = {}
        
        -- Apply filter if provided
        filterText = filterText and filterText:lower() or ""
        
        for k, v in pairs(options) do
            if filterText == "" or v:lower():find(filterText, 1, true) then
                table.insert(sortedOptions, {key = k, value = v})
            end
        end
        table.sort(sortedOptions, function(a, b) return a.value < b.value end)
        
        -- Resize menu and scroll child
        local menuHeight = math.min(#sortedOptions, MAX_VISIBLE) * ITEM_HEIGHT + SEARCH_HEIGHT + 8
        menuFrame:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)
        menuFrame:SetHeight(menuHeight)
        scrollChild:SetHeight(#sortedOptions * ITEM_HEIGHT)
        
        -- Hide scrollbar if not needed
        if scrollBar then
            if #sortedOptions <= MAX_VISIBLE then
                scrollBar:Hide()
            else
                scrollBar:Show()
            end
        end
        
        -- Create new buttons
        for i, opt in ipairs(sortedOptions) do
            local menuBtn = CreateFrame("Button", nil, scrollChild)
            menuBtn:SetSize(234, ITEM_HEIGHT)
            menuBtn:SetPoint("TOPLEFT", 0, -(i - 1) * ITEM_HEIGHT)
            
            menuBtn.Text = menuBtn:CreateFontString(nil, "OVERLAY")
            menuBtn.Text:SetPoint("LEFT", 8, 0)
            menuBtn.Text:SetPoint("RIGHT", -8, 0)
            menuBtn.Text:SetJustifyH("LEFT")
            
            -- Set default font first, then try to use the actual font for preview
            menuBtn.Text:SetFontObject(DFFontHighlightSmall)
            
            -- Try to preview in the actual font
            local LSM = DF.GetLSM and DF.GetLSM()
            if LSM then
                local fontPath = LSM:Fetch("font", opt.key)
                if fontPath then
                    pcall(function()
                        menuBtn.Text:SetFont(fontPath, 12, "")
                    end)
                end
            end
            
            menuBtn.Text:SetText(opt.value)
            
            -- Highlight selected item (compare with stored font name)
            local currentValue = dbTable[dbKey]
            local currentName = DF:GetFontNameFromPath(currentValue)
            if currentName == opt.key or currentValue == opt.key then
                menuBtn.Text:SetTextColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b)
            else
                menuBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end
            
            menuBtn.Highlight = menuBtn:CreateTexture(nil, "HIGHLIGHT")
            menuBtn.Highlight:SetAllPoints()
            local c = GetThemeColor()
            menuBtn.Highlight:SetColorTexture(c.r, c.g, c.b, 0.3)
            
            menuBtn:SetScript("OnClick", function()
                -- Runtime override protection
                if GUI.SelectedMode == "raid" and DF.AutoProfilesUI
                   and DF.AutoProfilesUI:HandleRuntimeWrite(dbKey, opt.key) then
                    UpdateText()
                    menuFrame:Hide()
                    if container.UpdateOverrideIndicators then container:UpdateOverrideIndicators(opt.key) end
                    return
                end
                -- Store font NAME in database (not path)
                dbTable[dbKey] = opt.key
                -- Track override when editing a profile
                if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                    DF.AutoProfilesUI:SetProfileSetting(dbKey, opt.key)
                end
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(opt.key)
                end
                UpdateText()
                menuFrame:Hide()
                DF:UpdateAll()
                if callback then callback() end
            end)
            
            table.insert(menuButtons, menuBtn)
        end
    end
    
    -- Search box text changed handler
    searchBox:SetScript("OnTextChanged", function(self)
        RebuildMenu(self:GetText())
    end)
    
    -- Allow escape to close
    searchBox:SetScript("OnEscapePressed", function()
        menuFrame:Hide()
    end)
    
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)
    
    btn:SetScript("OnClick", function(self)
        if menuFrame:IsShown() then
            menuFrame:Hide()
            currentOpenDropdown = nil
        else
            -- Close any other open dropdown first
            CloseOpenDropdown()
            -- Rebuild menu with current SharedMedia fonts
            RebuildMenu()
            menuFrame:Show()
            currentOpenDropdown = menuFrame
            -- Focus search box
            searchBox:SetFocus()
        end
    end)
    
    btn:SetScript("OnShow", UpdateText)
    UpdateText()
    
    -- Refresh override indicators on show
    container:SetScript("OnShow", function()
        UpdateText()
        if container.UpdateOverrideIndicators then
            container:UpdateOverrideIndicators(dbTable and dbTable[dbKey])
        end
    end)
    
    container.SetEnabled = function(self, enabled)
        btn:SetEnabled(enabled)
        if enabled then
            lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        else
            lbl:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            btn.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
    end
    
    -- SEARCH: Register this setting (use current font list)
    if DF.Search and dbKey and type(dbKey) == "string" then
        container.searchEntry = DF.Search:RegisterDropdown(label, dbKey, DF:GetFontList(), nil)
    end
    
    return container
end

-- ============================================================
-- SOUND DROPDOWN (Searchable, scrollable — mirrors font dropdown)
-- ============================================================

function GUI:CreateSoundDropdown(parent, label, dbTable, dbKey, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 50)

    -- Label
    local lbl = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    -- Button
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetPoint("TOPLEFT", 0, -16)
    btn:SetPoint("TOPRIGHT", 0, -16)
    btn:SetHeight(24)
    CreateElementBackdrop(btn)

    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -20, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    -- Arrow indicator
    local arrow = btn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
    arrow:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

    local function UpdateText()
        if dbTable and dbKey then
            local val = dbTable[dbKey]
            btn.Text:SetText(val or L["Select..."])
        end
    end

    -- Menu frame with scroll
    local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    menuFrame:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetClampedToScreen(true)
    CreateElementBackdrop(menuFrame)
    menuFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.98)
    menuFrame:Hide()

    -- Search box at top of menu
    local SEARCH_HEIGHT = 26
    local searchBox = CreateFrame("EditBox", nil, menuFrame, "BackdropTemplate")
    searchBox:SetPoint("TOPLEFT", 4, -4)
    searchBox:SetPoint("TOPRIGHT", -4, -4)
    searchBox:SetHeight(22)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(DFFontHighlightSmall)
    searchBox:SetTextInsets(24, 8, 0, 0)
    CreateElementBackdrop(searchBox)
    searchBox:SetBackdropColor(0.1, 0.1, 0.1, 1)

    -- Search icon
    local searchIcon = searchBox:CreateTexture(nil, "OVERLAY")
    searchIcon:SetPoint("LEFT", 6, 0)
    searchIcon:SetSize(12, 12)
    searchIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\search")
    searchIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

    -- Placeholder text
    local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    searchPlaceholder:SetPoint("LEFT", 24, 0)
    searchPlaceholder:SetText(L["Search sounds..."])
    searchPlaceholder:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.6)

    searchBox:SetScript("OnEditFocusGained", function() searchPlaceholder:Hide() end)
    searchBox:SetScript("OnEditFocusLost", function()
        if searchBox:GetText() == "" then searchPlaceholder:Show() end
    end)

    menuFrame:SetScript("OnHide", function()
        if currentOpenDropdown == menuFrame then
            currentOpenDropdown = nil
        end
        searchBox:SetText("")
        searchBox:ClearFocus()
        searchPlaceholder:Show()
    end)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, menuFrame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 2, -(SEARCH_HEIGHT + 4))
    scrollFrame:SetPoint("BOTTOMRIGHT", -20, 2)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(234)
    scrollFrame:SetScrollChild(scrollChild)

    StyleScrollBar(scrollFrame)

    local menuButtons = {}
    local ITEM_HEIGHT = 22
    local MAX_VISIBLE = 10

    local function RebuildMenu(filterText)
        for _, menuBtn in ipairs(menuButtons) do
            menuBtn:Hide()
            menuBtn:SetParent(nil)
        end
        wipe(menuButtons)

        local options = DF:GetSoundList()
        local sortedOptions = {}

        filterText = filterText and filterText:lower() or ""

        for k, v in pairs(options) do
            if filterText == "" or v:lower():find(filterText, 1, true) then
                table.insert(sortedOptions, {key = k, value = v})
            end
        end
        table.sort(sortedOptions, function(a, b) return a.value < b.value end)

        local menuHeight = math.min(#sortedOptions, MAX_VISIBLE) * ITEM_HEIGHT + SEARCH_HEIGHT + 8
        menuFrame:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)
        menuFrame:SetHeight(menuHeight)
        scrollChild:SetHeight(#sortedOptions * ITEM_HEIGHT)

        if scrollBar then
            if #sortedOptions <= MAX_VISIBLE then
                scrollBar:Hide()
            else
                scrollBar:Show()
            end
        end

        for i, opt in ipairs(sortedOptions) do
            local menuBtn = CreateFrame("Button", nil, scrollChild)
            menuBtn:SetSize(234, ITEM_HEIGHT)
            menuBtn:SetPoint("TOPLEFT", 0, -(i - 1) * ITEM_HEIGHT)

            menuBtn.Text = menuBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            menuBtn.Text:SetPoint("LEFT", 8, 0)
            menuBtn.Text:SetPoint("RIGHT", -8, 0)
            menuBtn.Text:SetJustifyH("LEFT")
            menuBtn.Text:SetText(opt.value)

            -- Highlight selected item
            local currentValue = dbTable[dbKey]
            if currentValue == opt.key then
                menuBtn.Text:SetTextColor(GetThemeColor().r, GetThemeColor().g, GetThemeColor().b)
            else
                menuBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end

            menuBtn.Highlight = menuBtn:CreateTexture(nil, "HIGHLIGHT")
            menuBtn.Highlight:SetAllPoints()
            local c = GetThemeColor()
            menuBtn.Highlight:SetColorTexture(c.r, c.g, c.b, 0.3)

            menuBtn:SetScript("OnClick", function()
                dbTable[dbKey] = opt.key
                UpdateText()
                menuFrame:Hide()
                DF:UpdateAll()
                if callback then callback() end
            end)

            table.insert(menuButtons, menuBtn)
        end
    end

    searchBox:SetScript("OnTextChanged", function(self)
        RebuildMenu(self:GetText())
    end)

    searchBox:SetScript("OnEscapePressed", function()
        menuFrame:Hide()
    end)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)

    btn:SetScript("OnClick", function(self)
        if menuFrame:IsShown() then
            menuFrame:Hide()
            currentOpenDropdown = nil
        else
            CloseOpenDropdown()
            RebuildMenu()
            menuFrame:Show()
            currentOpenDropdown = menuFrame
            searchBox:SetFocus()
        end
    end)

    btn:SetScript("OnShow", UpdateText)
    UpdateText()

    return container
end

-- ============================================================
-- ROLE ORDER LIST (Drag-Drop)
-- ============================================================

function GUI:CreateRoleOrderList(parent, dbTable, dbKey, callback, separateMeleeRangedKey)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(220, 130)
    
    -- Role display info with colors
    local ROLE_INFO = {
        TANK = { name = L["Tank"], color = {0.53, 0.77, 0.84}, coords = {0, 19/64, 22/64, 41/64} },
        HEALER = { name = L["Healer"], color = {0.25, 0.78, 0.25}, coords = {20/64, 39/64, 1/64, 20/64} },
        MELEE = { name = L["Melee DPS"], color = {0.82, 0.65, 0.47}, coords = {20/64, 39/64, 22/64, 41/64} },
        RANGED = { name = L["Ranged DPS"], color = {1.0, 0.49, 0.04}, coords = {20/64, 39/64, 22/64, 41/64} },
        DAMAGER = { name = L["DPS"], color = {0.82, 0.65, 0.47}, coords = {20/64, 39/64, 22/64, 41/64} },
    }
    
    local roleItems = {}
    local ITEM_HEIGHT = 30
    local draggingItem = nil
    local dragOffsetY = 0
    
    -- Check if we should show separate melee/ranged
    local function IsSeparateMeleeRanged()
        if separateMeleeRangedKey and dbTable then
            return dbTable[separateMeleeRangedKey]
        end
        return true
    end
    
    -- Get the roles to display
    local function GetDisplayRoles()
        if IsSeparateMeleeRanged() then
            return { "TANK", "HEALER", "MELEE", "RANGED" }
        else
            return { "TANK", "HEALER", "DAMAGER" }
        end
    end
    
    -- Get current order from db or use default
    local function GetCurrentOrder()
        local displayRoles = GetDisplayRoles()
        if dbTable and dbKey and dbTable[dbKey] then
            local order = {}
            for _, role in ipairs(dbTable[dbKey]) do
                for _, displayRole in ipairs(displayRoles) do
                    if role == displayRole or 
                       (displayRole == "DAMAGER" and (role == "MELEE" or role == "RANGED" or role == "DAMAGER")) then
                        local found = false
                        for _, existing in ipairs(order) do
                            if existing == displayRole then found = true break end
                        end
                        if not found then
                            table.insert(order, displayRole)
                        end
                        break
                    end
                end
            end
            for _, displayRole in ipairs(displayRoles) do
                local found = false
                for _, existing in ipairs(order) do
                    if existing == displayRole then found = true break end
                end
                if not found then
                    table.insert(order, displayRole)
                end
            end
            return order
        end
        return displayRoles
    end
    
    -- Save order to db
    local function SaveOrder(newOrder)
        if dbTable and dbKey then
            local saveOrder = {}
            for _, role in ipairs(newOrder) do
                if role == "DAMAGER" then
                    table.insert(saveOrder, "MELEE")
                    table.insert(saveOrder, "RANGED")
                else
                    table.insert(saveOrder, role)
                end
            end
            dbTable[dbKey] = saveOrder
            -- Track override when editing a profile
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                local copy = {}
                for i, v in ipairs(saveOrder) do copy[i] = v end
                DF.AutoProfilesUI:SetProfileSetting(dbKey, copy)
            end
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(saveOrder)
            end
            if callback then callback() end
        end
    end
    
    -- Get index from Y position
    local function GetIndexFromY(y)
        local containerTop = container:GetTop()
        if not containerTop then return 1 end
        local relativeY = containerTop - y
        local index = math.floor(relativeY / ITEM_HEIGHT) + 1
        local order = GetCurrentOrder()
        return math.max(1, math.min(index, #order))
    end
    
    -- Update visual positions
    local function UpdateItemPositions()
        local order = GetCurrentOrder()
        local numRoles = #order
        
        container:SetHeight(numRoles * ITEM_HEIGHT + 5)
        
        for _, item in pairs(roleItems) do
            item:Hide()
        end
        
        for i, role in ipairs(order) do
            local item = roleItems[role]
            if item then
                item:Show()
                item.posIndex = i
                item.numText:SetText(i .. ".")
                if item ~= draggingItem then
                    item:ClearAllPoints()
                    item:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i - 1) * ITEM_HEIGHT))
                    item:SetWidth(container:GetWidth() > 0 and container:GetWidth() or 220)
                end
            end
        end
    end
    
    -- Create grip texture (3 horizontal lines)
    local function CreateGripTexture(parentFrame)
        local grip = CreateFrame("Frame", nil, parentFrame)
        grip:SetSize(12, 16)
        
        for i = 1, 3 do
            local line = grip:CreateTexture(nil, "ARTWORK")
            line:SetSize(10, 2)
            line:SetPoint("TOP", grip, "TOP", 0, -3 - (i - 1) * 5)
            line:SetColorTexture(0.5, 0.5, 0.5, 1)
            grip["line" .. i] = line
        end
        
        grip.SetGripColor = function(self, r, g, b)
            for i = 1, 3 do
                self["line" .. i]:SetColorTexture(r, g, b, 1)
            end
        end
        
        return grip
    end
    
    -- Create a single role item
    local function CreateRoleItem(role)
        local info = ROLE_INFO[role]
        if not info then return nil end
        
        local item = CreateFrame("Frame", nil, container, "BackdropTemplate")
        item:SetHeight(ITEM_HEIGHT - 2)
        item:EnableMouse(true)
        item:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        item:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
        item:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        
        -- Grip texture
        local grip = CreateGripTexture(item)
        grip:SetPoint("LEFT", 6, 0)
        item.grip = grip
        
        -- Priority number
        local numText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
        numText:SetPoint("LEFT", grip, "RIGHT", 6, 0)
        numText:SetWidth(18)
        numText:SetJustifyH("LEFT")
        item.numText = numText
        
        -- Role icon
        local icon = item:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", numText, "RIGHT", 2, 0)
        icon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        icon:SetTexCoord(unpack(info.coords))
        item.icon = icon
        
        -- Role name with color
        local text = item:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        text:SetText(info.name)
        text:SetTextColor(info.color[1], info.color[2], info.color[3])
        item.text = text
        
        item.role = role
        item.posIndex = 1
        
        -- Mouse handlers for dragging
        item:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                draggingItem = self
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local itemTop = self:GetTop()
                dragOffsetY = itemTop - cursorY
                
                self:SetBackdropColor(0.28, 0.28, 0.55, 0.9)
                self:SetBackdropBorderColor(0.45, 0.45, 0.95, 1)
                self:SetFrameLevel(container:GetFrameLevel() + 10)
                self.grip:SetGripColor(1, 1, 1)
            end
        end)
        
        item:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and draggingItem == self then
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local dropIndex = GetIndexFromY(cursorY)
                
                local order = GetCurrentOrder()
                local currentIdx = self.posIndex
                
                if currentIdx ~= dropIndex then
                    local draggedRole = self.role
                    table.remove(order, currentIdx)
                    table.insert(order, dropIndex, draggedRole)
                    SaveOrder(order)
                end
                
                self:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self:SetFrameLevel(container:GetFrameLevel() + 1)
                self.grip:SetGripColor(0.5, 0.5, 0.5)
                
                draggingItem = nil
                UpdateItemPositions()
            end
        end)
        
        item:SetScript("OnUpdate", function(self)
            if draggingItem ~= self then return end
            
            local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local containerTop = container:GetTop()
            local containerBottom = container:GetBottom()
            
            if not containerTop or not containerBottom then return end
            
            local targetY = cursorY + dragOffsetY
            local offsetFromTop = containerTop - targetY
            
            local maxOffset = (containerTop - containerBottom) - ITEM_HEIGHT + 5
            offsetFromTop = math.max(0, math.min(offsetFromTop, maxOffset))
            
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -offsetFromTop)
            self:SetWidth(container:GetWidth())
            
            -- Update other items based on where this would drop
            local dropIndex = GetIndexFromY(cursorY)
            local order = GetCurrentOrder()
            
            local tempOrder = {}
            for i, r in ipairs(order) do
                if roleItems[r] ~= self then
                    table.insert(tempOrder, r)
                end
            end
            table.insert(tempOrder, dropIndex, self.role)
            
            for i, r in ipairs(tempOrder) do
                local otherItem = roleItems[r]
                if otherItem and otherItem ~= self then
                    otherItem:ClearAllPoints()
                    otherItem:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i - 1) * ITEM_HEIGHT))
                    otherItem:SetWidth(container:GetWidth())
                    otherItem.numText:SetText(i .. ".")
                end
            end
        end)
        
        -- Hover effects
        item:SetScript("OnEnter", function(self)
            if not draggingItem then
                self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
                self.grip:SetGripColor(0.8, 0.8, 0.8)
            end
        end)
        
        item:SetScript("OnLeave", function(self)
            if draggingItem ~= self then
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self.grip:SetGripColor(0.5, 0.5, 0.5)
            end
        end)
        
        return item
    end
    
    -- Create all role items
    for _, role in ipairs({"TANK", "HEALER", "MELEE", "RANGED", "DAMAGER"}) do
        roleItems[role] = CreateRoleItem(role)
    end
    
    -- Initial layout
    UpdateItemPositions()
    
    -- Refresh function
    container.Refresh = function()
        UpdateItemPositions()
    end
    
    -- Override indicators for profile editing
    if dbKey and type(dbKey) == "string" and not (dbTable and rawget(dbTable, "_skipOverrideIndicators")) then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if dbTable and type(globalVal) == "table" then
                    local copy = {}
                    for i, v in ipairs(globalVal) do copy[i] = v end
                    dbTable[dbKey] = copy
                end
                UpdateItemPositions()
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(dbTable[dbKey])
                end
                if callback then callback() end
            end
        end
        AddOrderListOverrideIndicators(container, dbKey, onReset)

        container:SetScript("OnShow", function()
            UpdateItemPositions()
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(dbTable and dbTable[dbKey])
            end
        end)
    end

    return container
end

-- ============================================================
-- CLASS ORDER LIST (Drag-Drop) - For class sorting within roles
-- ============================================================

function GUI:CreateClassOrderList(parent, dbTable, dbKey, callback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(220, 340)  -- Taller to fit all 13 classes
    
    -- Class display info with colors (using Blizzard class colors)
    local CLASS_INFO = {
        DEATHKNIGHT = { name = L["Death Knight"], color = {0.77, 0.12, 0.23} },
        DEMONHUNTER = { name = L["Demon Hunter"], color = {0.64, 0.19, 0.79} },
        DRUID = { name = L["Druid"], color = {1.0, 0.49, 0.04} },
        EVOKER = { name = L["Evoker"], color = {0.20, 0.58, 0.50} },
        HUNTER = { name = L["Hunter"], color = {0.67, 0.83, 0.45} },
        MAGE = { name = L["Mage"], color = {0.25, 0.78, 0.92} },
        MONK = { name = L["Monk"], color = {0.0, 1.0, 0.59} },
        PALADIN = { name = L["Paladin"], color = {0.96, 0.55, 0.73} },
        PRIEST = { name = L["Priest"], color = {1.0, 1.0, 1.0} },
        ROGUE = { name = L["Rogue"], color = {1.0, 0.96, 0.41} },
        SHAMAN = { name = L["Shaman"], color = {0.0, 0.44, 0.87} },
        WARLOCK = { name = L["Warlock"], color = {0.53, 0.53, 0.93} },
        WARRIOR = { name = L["Warrior"], color = {0.78, 0.61, 0.43} },
    }
    
    local ALL_CLASSES = {
        "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER",
        "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE",
        "SHAMAN", "WARLOCK", "WARRIOR"
    }
    
    local classItems = {}
    local ITEM_HEIGHT = 24  -- Slightly smaller to fit all classes
    local draggingItem = nil
    local dragOffsetY = 0
    
    -- Get current order from db or use default
    local function GetCurrentOrder()
        if dbTable and dbKey and dbTable[dbKey] then
            -- Ensure all classes are present
            local order = {}
            local seen = {}
            for _, class in ipairs(dbTable[dbKey]) do
                if CLASS_INFO[class] and not seen[class] then
                    table.insert(order, class)
                    seen[class] = true
                end
            end
            -- Add any missing classes
            for _, class in ipairs(ALL_CLASSES) do
                if not seen[class] then
                    table.insert(order, class)
                end
            end
            return order
        end
        return ALL_CLASSES
    end
    
    -- Save order to db
    local function SaveOrder(newOrder)
        if dbTable and dbKey then
            dbTable[dbKey] = newOrder
            -- Track override when editing a profile
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                local copy = {}
                for i, v in ipairs(newOrder) do copy[i] = v end
                DF.AutoProfilesUI:SetProfileSetting(dbKey, copy)
            end
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(newOrder)
            end
            if callback then callback() end
        end
    end
    
    -- Get index from Y position
    local function GetIndexFromY(y)
        local containerTop = container:GetTop()
        if not containerTop then return 1 end
        local relativeY = containerTop - y
        local index = math.floor(relativeY / ITEM_HEIGHT) + 1
        local order = GetCurrentOrder()
        return math.max(1, math.min(index, #order))
    end
    
    -- Update visual positions
    local function UpdateItemPositions()
        local order = GetCurrentOrder()
        local numClasses = #order
        
        container:SetHeight(numClasses * ITEM_HEIGHT + 5)
        
        for _, item in pairs(classItems) do
            item:Hide()
        end
        
        for i, class in ipairs(order) do
            local item = classItems[class]
            if item then
                item:Show()
                item.posIndex = i
                item.numText:SetText(i .. ".")
                if item ~= draggingItem then
                    item:ClearAllPoints()
                    item:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i - 1) * ITEM_HEIGHT))
                    item:SetWidth(container:GetWidth() > 0 and container:GetWidth() or 220)
                end
            end
        end
    end
    
    -- Create grip texture (3 horizontal lines)
    local function CreateGripTexture(parentFrame)
        local grip = CreateFrame("Frame", nil, parentFrame)
        grip:SetSize(10, 12)
        
        for i = 1, 3 do
            local line = grip:CreateTexture(nil, "ARTWORK")
            line:SetSize(8, 1)
            line:SetPoint("TOP", grip, "TOP", 0, -2 - (i - 1) * 4)
            line:SetColorTexture(0.5, 0.5, 0.5, 1)
            grip["line" .. i] = line
        end
        
        grip.SetGripColor = function(self, r, g, b)
            for i = 1, 3 do
                self["line" .. i]:SetColorTexture(r, g, b, 1)
            end
        end
        
        return grip
    end
    
    -- Create a single class item
    local function CreateClassItem(class)
        local info = CLASS_INFO[class]
        if not info then return nil end
        
        local item = CreateFrame("Frame", nil, container, "BackdropTemplate")
        item:SetHeight(ITEM_HEIGHT - 2)
        item:EnableMouse(true)
        item:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        item:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
        item:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        
        -- Grip texture
        local grip = CreateGripTexture(item)
        grip:SetPoint("LEFT", 4, 0)
        item.grip = grip
        
        -- Priority number
        local numText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        numText:SetPoint("LEFT", grip, "RIGHT", 4, 0)
        numText:SetWidth(20)
        numText:SetJustifyH("LEFT")
        item.numText = numText
        
        -- Class color bar
        local colorBar = item:CreateTexture(nil, "ARTWORK")
        colorBar:SetSize(3, ITEM_HEIGHT - 6)
        colorBar:SetPoint("LEFT", numText, "RIGHT", 2, 0)
        colorBar:SetColorTexture(info.color[1], info.color[2], info.color[3], 1)
        item.colorBar = colorBar
        
        -- Class name with color
        local text = item:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        text:SetPoint("LEFT", colorBar, "RIGHT", 6, 0)
        text:SetText(info.name)
        text:SetTextColor(info.color[1], info.color[2], info.color[3])
        item.text = text
        
        item.class = class
        item.posIndex = 1
        
        -- Mouse handlers for dragging
        item:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                draggingItem = self
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local itemTop = self:GetTop()
                dragOffsetY = itemTop - cursorY
                
                self:SetBackdropColor(0.28, 0.28, 0.55, 0.9)
                self:SetBackdropBorderColor(0.45, 0.45, 0.95, 1)
                self:SetFrameLevel(container:GetFrameLevel() + 10)
                self.grip:SetGripColor(1, 1, 1)
            end
        end)
        
        item:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and draggingItem == self then
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local dropIndex = GetIndexFromY(cursorY)
                
                local order = GetCurrentOrder()
                local currentIdx = self.posIndex
                
                if currentIdx ~= dropIndex then
                    local draggedClass = self.class
                    table.remove(order, currentIdx)
                    table.insert(order, dropIndex, draggedClass)
                    SaveOrder(order)
                end
                
                self:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self:SetFrameLevel(container:GetFrameLevel() + 1)
                self.grip:SetGripColor(0.5, 0.5, 0.5)
                
                draggingItem = nil
                UpdateItemPositions()
            end
        end)
        
        item:SetScript("OnUpdate", function(self)
            if draggingItem ~= self then return end
            
            local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local containerTop = container:GetTop()
            local containerBottom = container:GetBottom()
            
            if not containerTop or not containerBottom then return end
            
            local targetY = cursorY + dragOffsetY
            local offsetFromTop = containerTop - targetY
            
            local maxOffset = (containerTop - containerBottom) - ITEM_HEIGHT + 5
            offsetFromTop = math.max(0, math.min(offsetFromTop, maxOffset))
            
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -offsetFromTop)
            self:SetWidth(container:GetWidth())
            
            -- Update other items based on where this would drop
            local dropIndex = GetIndexFromY(cursorY)
            local order = GetCurrentOrder()
            
            local tempOrder = {}
            for i, c in ipairs(order) do
                if classItems[c] ~= self then
                    table.insert(tempOrder, c)
                end
            end
            table.insert(tempOrder, dropIndex, self.class)
            
            for i, c in ipairs(tempOrder) do
                local otherItem = classItems[c]
                if otherItem and otherItem ~= self then
                    otherItem:ClearAllPoints()
                    otherItem:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i - 1) * ITEM_HEIGHT))
                    otherItem:SetWidth(container:GetWidth())
                    otherItem.numText:SetText(i .. ".")
                end
            end
        end)
        
        -- Hover effects
        item:SetScript("OnEnter", function(self)
            if not draggingItem then
                self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
                self.grip:SetGripColor(0.8, 0.8, 0.8)
            end
        end)
        
        item:SetScript("OnLeave", function(self)
            if draggingItem ~= self then
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self.grip:SetGripColor(0.5, 0.5, 0.5)
            end
        end)
        
        return item
    end
    
    -- Create all class items
    for _, class in ipairs(ALL_CLASSES) do
        classItems[class] = CreateClassItem(class)
    end
    
    -- Initial layout
    UpdateItemPositions()
    
    -- Refresh function
    container.Refresh = function()
        UpdateItemPositions()
    end
    
    -- Override indicators for profile editing
    if dbKey and type(dbKey) == "string" and not (dbTable and rawget(dbTable, "_skipOverrideIndicators")) then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if dbTable and type(globalVal) == "table" then
                    local copy = {}
                    for i, v in ipairs(globalVal) do copy[i] = v end
                    dbTable[dbKey] = copy
                end
                UpdateItemPositions()
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(dbTable[dbKey])
                end
                if callback then callback() end
            end
        end
        AddOrderListOverrideIndicators(container, dbKey, onReset)

        container:SetScript("OnShow", function()
            UpdateItemPositions()
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(dbTable and dbTable[dbKey])
            end
        end)
    end

    return container
end

-- Raid Group Order List (drag-and-drop)
function GUI:CreateGroupOrderList(parent, dbTable, dbKey, callback, playerGroupFirstKey)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(180, 250)
    
    -- Group colors for visual distinction
    local GROUP_COLORS = {
        [1] = {0.95, 0.40, 0.40},  -- Red
        [2] = {0.40, 0.95, 0.40},  -- Green
        [3] = {0.40, 0.60, 0.95},  -- Blue
        [4] = {0.95, 0.95, 0.40},  -- Yellow
        [5] = {0.95, 0.40, 0.95},  -- Magenta
        [6] = {0.40, 0.95, 0.95},  -- Cyan
        [7] = {0.95, 0.70, 0.40},  -- Orange
        [8] = {0.70, 0.40, 0.95},  -- Purple
    }
    
    local groupItems = {}
    local ITEM_HEIGHT = 28
    local draggingItem = nil
    local dragOffsetY = 0
    
    -- Get current order from db or use default
    local function GetCurrentOrder()
        if dbTable and dbKey and dbTable[dbKey] then
            -- Validate and return existing order
            local order = {}
            local seen = {}
            for _, groupNum in ipairs(dbTable[dbKey]) do
                if groupNum >= 1 and groupNum <= 8 and not seen[groupNum] then
                    table.insert(order, groupNum)
                    seen[groupNum] = true
                end
            end
            -- Add any missing groups
            for i = 1, 8 do
                if not seen[i] then
                    table.insert(order, i)
                end
            end
            return order
        end
        return {1, 2, 3, 4, 5, 6, 7, 8}
    end
    
    -- Save order to db
    local function SaveOrder(newOrder)
        if dbTable and dbKey then
            dbTable[dbKey] = newOrder
            -- Track override when editing a profile
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() and dbKey then
                local copy = {}
                for i, v in ipairs(newOrder) do copy[i] = v end
                DF.AutoProfilesUI:SetProfileSetting(dbKey, copy)
            end
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(newOrder)
            end
            if callback then callback() end
        end
    end
    
    -- Get index from Y position
    local function GetIndexFromY(y)
        local containerTop = container:GetTop()
        if not containerTop then return 1 end
        local relativeY = containerTop - y
        local index = math.floor(relativeY / ITEM_HEIGHT) + 1
        return math.max(1, math.min(index, 8))
    end
    
    -- Update visual positions
    local function UpdateItemPositions()
        local order = GetCurrentOrder()
        
        for _, item in pairs(groupItems) do
            item:Hide()
        end
        
        for displayPos, groupNum in ipairs(order) do
            local item = groupItems[groupNum]
            if item then
                item:Show()
                item.displayPos = displayPos
                item.numText:SetText(displayPos .. ".")
                if item ~= draggingItem then
                    item:ClearAllPoints()
                    item:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((displayPos - 1) * ITEM_HEIGHT))
                    item:SetWidth(container:GetWidth() > 0 and container:GetWidth() or 180)
                end
            end
        end
    end
    
    -- Create grip texture (3 horizontal lines)
    local function CreateGripTexture(parentFrame)
        local grip = CreateFrame("Frame", nil, parentFrame)
        grip:SetSize(12, 14)
        
        for i = 1, 3 do
            local line = grip:CreateTexture(nil, "ARTWORK")
            line:SetSize(10, 2)
            line:SetPoint("TOP", grip, "TOP", 0, -2 - (i - 1) * 4)
            line:SetColorTexture(0.5, 0.5, 0.5, 1)
            grip["line" .. i] = line
        end
        
        grip.SetGripColor = function(self, r, g, b)
            for i = 1, 3 do
                self["line" .. i]:SetColorTexture(r, g, b, 1)
            end
        end
        
        return grip
    end
    
    -- Create a single group item
    local function CreateGroupItem(groupNum)
        local color = GROUP_COLORS[groupNum]
        
        local item = CreateFrame("Frame", nil, container, "BackdropTemplate")
        item:SetHeight(ITEM_HEIGHT - 2)
        item:EnableMouse(true)
        item:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        item:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
        item:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        
        -- Grip texture
        local grip = CreateGripTexture(item)
        grip:SetPoint("LEFT", 6, 0)
        item.grip = grip
        
        -- Display position number
        local numText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
        numText:SetPoint("LEFT", grip, "RIGHT", 6, 0)
        numText:SetWidth(18)
        numText:SetJustifyH("LEFT")
        item.numText = numText
        
        -- Color swatch
        local swatch = item:CreateTexture(nil, "ARTWORK")
        swatch:SetSize(14, 14)
        swatch:SetPoint("LEFT", numText, "RIGHT", 4, 0)
        swatch:SetColorTexture(color[1], color[2], color[3], 1)
        item.swatch = swatch
        
        -- Group name
        local text = item:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        text:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
        text:SetText("Group " .. groupNum)
        text:SetTextColor(color[1], color[2], color[3])
        item.text = text
        
        item.groupNum = groupNum
        item.displayPos = groupNum
        
        -- Mouse handlers for dragging
        item:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                draggingItem = self
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local itemTop = self:GetTop()
                dragOffsetY = itemTop - cursorY
                
                self:SetBackdropColor(0.28, 0.28, 0.55, 0.9)
                self:SetBackdropBorderColor(0.45, 0.45, 0.95, 1)
                self:SetFrameLevel(container:GetFrameLevel() + 10)
                self.grip:SetGripColor(1, 1, 1)
            end
        end)
        
        item:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and draggingItem == self then
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local newIndex = GetIndexFromY(cursorY)
                
                -- Reorder
                local currentOrder = GetCurrentOrder()
                local oldIndex = self.displayPos
                
                if newIndex ~= oldIndex then
                    table.remove(currentOrder, oldIndex)
                    table.insert(currentOrder, newIndex, self.groupNum)
                    SaveOrder(currentOrder)
                end
                
                draggingItem = nil
                self:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self:SetFrameLevel(container:GetFrameLevel() + 1)
                self.grip:SetGripColor(0.5, 0.5, 0.5)
                
                UpdateItemPositions()
            end
        end)
        
        item:SetScript("OnUpdate", function(self)
            if draggingItem ~= self then return end
            
            local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local containerTop = container:GetTop()
            local containerBottom = container:GetBottom()
            
            if not containerTop or not containerBottom then return end
            
            local targetY = cursorY + dragOffsetY
            local offsetFromTop = containerTop - targetY
            
            local maxOffset = (containerTop - containerBottom) - ITEM_HEIGHT + 5
            offsetFromTop = math.max(0, math.min(offsetFromTop, maxOffset))
            
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -offsetFromTop)
            self:SetWidth(container:GetWidth())
            
            -- Update other items based on where this would drop
            local dropIndex = GetIndexFromY(cursorY)
            local order = GetCurrentOrder()
            
            -- Build temp order: remove self, insert at drop position
            local tempOrder = {}
            for i, g in ipairs(order) do
                if groupItems[g] ~= self then
                    table.insert(tempOrder, g)
                end
            end
            table.insert(tempOrder, dropIndex, self.groupNum)
            
            -- Position all other items according to temp order
            for i, g in ipairs(tempOrder) do
                local otherItem = groupItems[g]
                if otherItem and otherItem ~= self then
                    otherItem:ClearAllPoints()
                    otherItem:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i - 1) * ITEM_HEIGHT))
                    otherItem:SetWidth(container:GetWidth())
                    otherItem.numText:SetText(i .. ".")
                end
            end
        end)
        
        item:SetScript("OnEnter", function(self)
            if draggingItem ~= self then
                self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
                self.grip:SetGripColor(0.8, 0.8, 0.8)
            end
        end)
        
        item:SetScript("OnLeave", function(self)
            if draggingItem ~= self then
                self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                self.grip:SetGripColor(0.5, 0.5, 0.5)
            end
        end)
        
        return item
    end
    
    -- Create all group items
    for i = 1, 8 do
        groupItems[i] = CreateGroupItem(i)
    end
    
    -- Initial layout
    UpdateItemPositions()
    
    -- Refresh function
    container.Refresh = function()
        UpdateItemPositions()
    end
    
    -- Override indicators for profile editing
    if dbKey and type(dbKey) == "string" and not (dbTable and rawget(dbTable, "_skipOverrideIndicators")) then
        local function onReset()
            if DF.AutoProfilesUI then
                DF.AutoProfilesUI:ResetProfileSetting(dbKey)
                local globalVal = DF.AutoProfilesUI:GetGlobalValue(dbKey)
                if dbTable and type(globalVal) == "table" then
                    local copy = {}
                    for i, v in ipairs(globalVal) do copy[i] = v end
                    dbTable[dbKey] = copy
                end
                UpdateItemPositions()
                if container.UpdateOverrideIndicators then
                    container:UpdateOverrideIndicators(dbTable[dbKey])
                end
                if callback then callback() end
            end
        end
        AddOrderListOverrideIndicators(container, dbKey, onReset)

        container:SetScript("OnShow", function()
            UpdateItemPositions()
            if container.UpdateOverrideIndicators then
                container:UpdateOverrideIndicators(dbTable and dbTable[dbKey])
            end
        end)
    end

    return container
end

-- ============================================================
-- HIGHLIGHT FRAMES ROSTER WIDGET
-- ============================================================
-- Dual-column widget for selecting players to highlight
-- Left: Current group roster
-- Right: Selected players (draggable for reorder)

function GUI:CreateHighlightRosterWidget(parent, getPlayersFunc, setPlayersFunc, onChangeCallback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(460, 340)
    
    local ITEM_HEIGHT = 26
    local COL_WIDTH = 224  -- Wider columns
    local COL_GAP = 12     -- Smaller gap between columns
    
    -- State
    local rosterItems = {}
    local highlightItems = {}
    local currentRoster = {}
    local draggingItem = nil
    local dragOffsetY = 0
    
    -- Custom role icons
    local ROLE_ICONS = {
        TANK = "Interface\\AddOns\\DandersFrames\\Media\\DF_Tank",
        HEALER = "Interface\\AddOns\\DandersFrames\\Media\\DF_Healer",
        DAMAGER = "Interface\\AddOns\\DandersFrames\\Media\\DF_DPS",
    }
    local ROLE_COLORS = {
        TANK = {0.35, 0.56, 0.82},
        HEALER = {0.29, 0.62, 0.29},
        DAMAGER = {0.70, 0.35, 0.35},
    }
    
    -- Icon paths
    local ICON_ARROW = "Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right"
    local ICON_CHECK = "Interface\\AddOns\\DandersFrames\\Media\\Icons\\check"
    local ICON_CLOSE = "Interface\\AddOns\\DandersFrames\\Media\\Icons\\close"
    
    -- ========== LEFT COLUMN: Group Roster ==========
    local leftHeader = container:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    leftHeader:SetPoint("TOPLEFT", 0, 0)
    leftHeader:SetText(L["Group Roster"])
    leftHeader:SetTextColor(0.7, 0.7, 0.7)
    
    local leftCount = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    leftCount:SetPoint("LEFT", leftHeader, "RIGHT", 8, 0)
    leftCount:SetTextColor(0.5, 0.5, 0.5)
    
    local leftBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    leftBg:SetPoint("TOPLEFT", 0, -18)
    leftBg:SetSize(COL_WIDTH, 240)
    leftBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    leftBg:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    leftBg:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    
    local leftScroll = CreateFrame("ScrollFrame", nil, leftBg, "ScrollFrameTemplate")
    leftScroll:SetPoint("TOPLEFT", 4, -4)
    leftScroll:SetPoint("BOTTOMRIGHT", -24, 4)
    
    local leftContent = CreateFrame("Frame", nil, leftScroll)
    leftContent:SetSize(COL_WIDTH - 28, 1)
    leftScroll:SetScrollChild(leftContent)
    StyleScrollBar(leftScroll)

    -- ========== RIGHT COLUMN: Highlighted Units ==========
    local rightHeader = container:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    rightHeader:SetPoint("TOPLEFT", leftBg, "TOPRIGHT", COL_GAP, 18)
    rightHeader:SetText(L["Highlighted Units"])
    rightHeader:SetTextColor(0.7, 0.7, 0.7)
    
    local rightCount = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    rightCount:SetPoint("LEFT", rightHeader, "RIGHT", 8, 0)
    rightCount:SetTextColor(0.5, 0.5, 0.5)
    
    local rightBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    rightBg:SetPoint("TOPLEFT", leftBg, "TOPRIGHT", COL_GAP, 0)
    rightBg:SetSize(COL_WIDTH, 240)
    rightBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    rightBg:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    rightBg:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    
    local rightScroll = CreateFrame("ScrollFrame", nil, rightBg, "ScrollFrameTemplate")
    rightScroll:SetPoint("TOPLEFT", 4, -4)
    rightScroll:SetPoint("BOTTOMRIGHT", -24, 4)
    
    local rightContent = CreateFrame("Frame", nil, rightScroll)
    rightContent:SetSize(COL_WIDTH - 28, 1)
    rightScroll:SetScrollChild(rightContent)
    StyleScrollBar(rightScroll)

    -- ========== HELPER FUNCTIONS ==========
    
    -- Get current group roster
    local function GetGroupRoster()
        local roster = {}
        local numMembers = GetNumGroupMembers()
        if numMembers == 0 then
            -- Solo - just show player
            local name = UnitName("player")
            local realm = GetRealmName()
            local _, class = UnitClass("player")
            table.insert(roster, {
                name = name,
                fullName = name .. "-" .. realm,
                class = class or "WARRIOR",
                role = "DAMAGER",
                group = 1,
            })
            return roster
        end
        
        local isRaid = IsInRaid()
        
        for i = 1, numMembers do
            local unit = isRaid and ("raid" .. i) or (i == 1 and "player" or "party" .. (i - 1))
            local name, realm = UnitName(unit)
            
            if name then
                realm = realm or GetRealmName()
                local fullName = name .. "-" .. realm
                local _, class = UnitClass(unit)
                local role = UnitGroupRolesAssigned(unit)
                if role == "NONE" then role = "DAMAGER" end
                local group = 1
                if isRaid then
                    local raidIndex = UnitInRaid(unit)
                    if raidIndex then
                        local _, _, subgroup = GetRaidRosterInfo(raidIndex + 1)
                        group = subgroup or 1
                    end
                end
                
                table.insert(roster, {
                    name = name,
                    fullName = fullName,
                    class = class or "WARRIOR",
                    role = role or "DAMAGER",
                    group = group,
                })
            end
        end
        
        -- Sort by group, then role, then name
        table.sort(roster, function(a, b)
            if a.group ~= b.group then return a.group < b.group end
            local roleOrder = { TANK = 1, HEALER = 2, DAMAGER = 3 }
            local aRole = roleOrder[a.role] or 3
            local bRole = roleOrder[b.role] or 3
            if aRole ~= bRole then return aRole < bRole end
            return a.name < b.name
        end)
        
        return roster
    end
    
    -- Check if player is in highlighted list
    local function IsPlayerHighlighted(fullName)
        local players = getPlayersFunc()
        for _, p in ipairs(players) do
            if p == fullName then return true end
        end
        return false
    end
    
    -- Check if player is in current group
    local function IsPlayerInGroup(fullName)
        for _, p in ipairs(currentRoster) do
            if p.fullName == fullName or p.name == fullName then
                return true, p
            end
        end
        return false, nil
    end
    
    -- Add player to highlight list
    local function AddPlayer(fullName)
        local players = getPlayersFunc()
        if not IsPlayerHighlighted(fullName) then
            table.insert(players, fullName)
            setPlayersFunc(players)
            if onChangeCallback then onChangeCallback() end
        end
    end
    
    -- Remove player from highlight list
    local function RemovePlayer(fullName)
        local players = getPlayersFunc()
        for i, p in ipairs(players) do
            if p == fullName then
                table.remove(players, i)
                setPlayersFunc(players)
                if onChangeCallback then onChangeCallback() end
                break
            end
        end
    end
    
    -- Create grip texture
    local function CreateGripTexture(parentFrame)
        local grip = CreateFrame("Frame", nil, parentFrame)
        grip:SetSize(12, 14)
        
        for i = 1, 3 do
            local line = grip:CreateTexture(nil, "ARTWORK")
            line:SetSize(10, 2)
            line:SetPoint("TOP", grip, "TOP", 0, -2 - (i - 1) * 4)
            line:SetColorTexture(0.5, 0.5, 0.5, 1)
            grip["line" .. i] = line
        end
        
        grip.SetGripColor = function(self, r, g, b)
            for i = 1, 3 do
                self["line" .. i]:SetColorTexture(r, g, b, 1)
            end
        end
        
        return grip
    end
    
    -- Create role icon using custom textures
    local function CreateRoleIcon(parentFrame, role)
        local icon = parentFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(14, 14)
        icon:SetTexture(ROLE_ICONS[role] or ROLE_ICONS.DAMAGER)
        return icon
    end
    
    -- ========== ROSTER ITEM (Left Column) ==========
    local function CreateRosterItem(playerData, index)
        local item = CreateFrame("Frame", nil, leftContent, "BackdropTemplate")
        item:SetHeight(ITEM_HEIGHT - 2)
        item:SetPoint("TOPLEFT", 0, -((index - 1) * ITEM_HEIGHT))
        item:SetPoint("TOPRIGHT", 0, -((index - 1) * ITEM_HEIGHT))
        item:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
        })
        item:SetBackdropColor(0, 0, 0, 0)
        
        item.playerData = playerData
        
        -- Role icon
        local roleIcon = CreateRoleIcon(item, playerData.role)
        roleIcon:SetPoint("LEFT", 4, 0)
        item.roleIcon = roleIcon
        
        -- Name (class colored)
        local nameText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        nameText:SetPoint("LEFT", roleIcon, "RIGHT", 6, 0)
        nameText:SetPoint("RIGHT", -70, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetText(playerData.name)
        local classColor = DF:GetClassColor(playerData.class)
        if classColor then
            nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
        else
            nameText:SetTextColor(0.8, 0.8, 0.8)
        end
        item.nameText = nameText
        
        -- Group number
        local groupText = item:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        groupText:SetPoint("RIGHT", -34, 0)
        groupText:SetText("G" .. playerData.group)
        groupText:SetTextColor(0.4, 0.4, 0.4)
        item.groupText = groupText
        
        -- Add button
        local addBtn = CreateFrame("Button", nil, item, "BackdropTemplate")
        addBtn:SetSize(26, 20)
        addBtn:SetPoint("RIGHT", -4, 0)
        addBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        
        local themeColor = GetThemeColor()
        
        -- Icon for button
        addBtn.icon = addBtn:CreateTexture(nil, "OVERLAY")
        addBtn.icon:SetSize(12, 12)
        addBtn.icon:SetPoint("CENTER", 0, 0)
        
        local function UpdateAddButton()
            local isHighlighted = IsPlayerHighlighted(playerData.fullName)
            if isHighlighted then
                addBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                addBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
                addBtn.icon:SetTexture(ICON_CHECK)
                addBtn.icon:SetVertexColor(0.4, 0.4, 0.4)
                item:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
                nameText:SetAlpha(0.5)
                groupText:SetAlpha(0.5)
                roleIcon:SetAlpha(0.5)
            else
                addBtn:SetBackdropColor(themeColor.r * 0.2, themeColor.g * 0.2, themeColor.b * 0.2, 0.8)
                addBtn:SetBackdropBorderColor(themeColor.r * 0.5, themeColor.g * 0.5, themeColor.b * 0.5, 0.8)
                addBtn.icon:SetTexture(ICON_ARROW)
                addBtn.icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
                item:SetBackdropColor(0, 0, 0, 0)
                nameText:SetAlpha(1)
                groupText:SetAlpha(1)
                roleIcon:SetAlpha(1)
            end
        end
        
        addBtn:SetScript("OnClick", function()
            if not IsPlayerHighlighted(playerData.fullName) then
                AddPlayer(playerData.fullName)
                container:Refresh()
            end
        end)
        
        addBtn:SetScript("OnEnter", function(self)
            if not IsPlayerHighlighted(playerData.fullName) then
                self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            end
        end)
        
        addBtn:SetScript("OnLeave", function(self)
            UpdateAddButton()
        end)
        
        item.addBtn = addBtn
        item.UpdateAddButton = UpdateAddButton
        UpdateAddButton()
        
        return item
    end
    
    -- ========== HIGHLIGHT ITEM (Right Column - Draggable) ==========
    local function CreateHighlightItem(fullName, index, totalCount)
        local item = CreateFrame("Frame", nil, rightContent, "BackdropTemplate")
        item:SetHeight(ITEM_HEIGHT - 2)
        item:SetPoint("TOPLEFT", 0, -((index - 1) * ITEM_HEIGHT))
        item:SetPoint("TOPRIGHT", 0, -((index - 1) * ITEM_HEIGHT))
        item:EnableMouse(true)
        item:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        item:SetBackdropColor(0.12, 0.12, 0.12, 0.9)
        item:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        
        item.fullName = fullName
        item.index = index
        
        -- Check if player is in current group
        local inGroup, playerData = IsPlayerInGroup(fullName)
        
        -- Grip handle
        local grip = CreateGripTexture(item)
        grip:SetPoint("LEFT", 4, 0)
        item.grip = grip
        
        -- Position number
        local themeColor = GetThemeColor()
        local numText = item:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        numText:SetPoint("LEFT", grip, "RIGHT", 6, 0)
        numText:SetWidth(20)
        numText:SetJustifyH("LEFT")
        numText:SetText(index .. ".")
        numText:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
        item.numText = numText
        
        -- Role icon
        local role = playerData and playerData.role or "DAMAGER"
        local roleIcon = CreateRoleIcon(item, role)
        roleIcon:SetPoint("LEFT", numText, "RIGHT", 4, 0)
        item.roleIcon = roleIcon
        
        -- Name
        local displayName = fullName:match("([^%-]+)") or fullName  -- Get name before realm
        local nameText = item:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        nameText:SetPoint("LEFT", roleIcon, "RIGHT", 6, 0)
        nameText:SetPoint("RIGHT", -34, 0)
        nameText:SetJustifyH("LEFT")
        
        if playerData then
            nameText:SetText(playerData.name)
            local classColor = DF:GetClassColor(playerData.class)
            if classColor then
                nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
            end
        else
            -- Player not in group
            nameText:SetText(displayName .. " " .. L["(offline)"])
            nameText:SetTextColor(0.5, 0.5, 0.5)
            item:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
            grip:SetGripColor(0.35, 0.35, 0.35)
            roleIcon:SetAlpha(0.5)
        end
        item.nameText = nameText
        
        -- Remove button
        local removeBtn = CreateFrame("Button", nil, item, "BackdropTemplate")
        removeBtn:SetSize(26, 20)
        removeBtn:SetPoint("RIGHT", -4, 0)
        removeBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        removeBtn:SetBackdropColor(0.5, 0.15, 0.15, 0.5)
        removeBtn:SetBackdropBorderColor(0.6, 0.25, 0.25, 0.8)
        
        -- X icon for remove button
        removeBtn.icon = removeBtn:CreateTexture(nil, "OVERLAY")
        removeBtn.icon:SetSize(12, 12)
        removeBtn.icon:SetPoint("CENTER", 0, 0)
        removeBtn.icon:SetTexture(ICON_CLOSE)
        removeBtn.icon:SetVertexColor(0.8, 0.3, 0.3)
        
        removeBtn:SetScript("OnClick", function()
            RemovePlayer(fullName)
            container:Refresh()
        end)
        
        removeBtn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.6, 0.2, 0.2, 0.8)
            self:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
        end)
        
        removeBtn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.5, 0.15, 0.15, 0.5)
            self:SetBackdropBorderColor(0.6, 0.25, 0.25, 0.8)
        end)
        
        item.removeBtn = removeBtn
        
        -- ========== DRAG HANDLERS ==========
        item:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                draggingItem = self
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local itemTop = self:GetTop()
                dragOffsetY = itemTop - cursorY
                
                self:SetBackdropColor(0.25, 0.25, 0.4, 0.95)
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
                self:SetFrameLevel(rightContent:GetFrameLevel() + 10)
                self.grip:SetGripColor(1, 1, 1)
            end
        end)
        
        item:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and draggingItem == self then
                local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
                local contentTop = rightContent:GetTop()
                if contentTop then
                    local relativeY = contentTop - cursorY
                    local newIndex = math.floor(relativeY / ITEM_HEIGHT) + 1
                    newIndex = math.max(1, math.min(newIndex, totalCount))
                    
                    local oldIndex = self.index
                    if newIndex ~= oldIndex then
                        -- Reorder the players array
                        local players = getPlayersFunc()
                        local removed = table.remove(players, oldIndex)
                        table.insert(players, newIndex, removed)
                        setPlayersFunc(players)
                        if onChangeCallback then onChangeCallback() end
                    end
                end
                
                draggingItem = nil
                container:Refresh()
            end
        end)
        
        item:SetScript("OnUpdate", function(self)
            if draggingItem ~= self then return end
            
            local cursorY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local contentTop = rightContent:GetTop()
            local contentBottom = rightContent:GetBottom()
            
            if not contentTop or not contentBottom then return end
            
            local targetY = cursorY + dragOffsetY
            local offsetFromTop = contentTop - targetY
            
            local maxOffset = math.max(0, (totalCount - 1) * ITEM_HEIGHT)
            offsetFromTop = math.max(0, math.min(offsetFromTop, maxOffset))
            
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", rightContent, "TOPLEFT", 0, -offsetFromTop)
            self:SetPoint("TOPRIGHT", rightContent, "TOPRIGHT", 0, -offsetFromTop)
            
            -- Update visual positions of other items
            local dropIndex = math.floor(offsetFromTop / ITEM_HEIGHT) + 1
            dropIndex = math.max(1, math.min(dropIndex, totalCount))
            
            for _, otherItem in ipairs(highlightItems) do
                if otherItem ~= self then
                    local visualIndex = otherItem.index
                    if self.index < dropIndex then
                        -- Dragging down
                        if otherItem.index > self.index and otherItem.index <= dropIndex then
                            visualIndex = otherItem.index - 1
                        end
                    else
                        -- Dragging up
                        if otherItem.index < self.index and otherItem.index >= dropIndex then
                            visualIndex = otherItem.index + 1
                        end
                    end
                    otherItem:ClearAllPoints()
                    otherItem:SetPoint("TOPLEFT", rightContent, "TOPLEFT", 0, -((visualIndex - 1) * ITEM_HEIGHT))
                    otherItem:SetPoint("TOPRIGHT", rightContent, "TOPRIGHT", 0, -((visualIndex - 1) * ITEM_HEIGHT))
                    otherItem.numText:SetText(visualIndex .. ".")
                end
            end
        end)
        
        -- Hover effects
        item:SetScript("OnEnter", function(self)
            if draggingItem ~= self then
                self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
                self.grip:SetGripColor(0.8, 0.8, 0.8)
            end
        end)
        
        item:SetScript("OnLeave", function(self)
            if draggingItem ~= self then
                self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
                if inGroup then
                    self.grip:SetGripColor(0.5, 0.5, 0.5)
                else
                    self.grip:SetGripColor(0.35, 0.35, 0.35)
                end
            end
        end)
        
        return item
    end
    
    -- ========== QUICK ADD BUTTONS ==========
    local buttonRow = CreateFrame("Frame", nil, container)
    buttonRow:SetSize(460, 28)
    buttonRow:SetPoint("TOPLEFT", leftBg, "BOTTOMLEFT", 0, -8)
    
    local function CreateQuickAddButton(text, role, color, xOffset)
        local btn = CreateFrame("Button", nil, buttonRow, "BackdropTemplate")
        btn:SetSize(68, 24)
        btn:SetPoint("LEFT", xOffset, 0)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(color[1] * 0.15, color[2] * 0.15, color[3] * 0.15, 0.9)
        btn:SetBackdropBorderColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5, 0.8)
        
        btn.text = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        btn.text:SetPoint("CENTER")
        btn.text:SetText(text)
        btn.text:SetTextColor(color[1], color[2], color[3])
        
        btn:SetScript("OnClick", function()
            local players = getPlayersFunc()
            for _, player in ipairs(currentRoster) do
                if role == "ALL" or player.role == role then
                    if not IsPlayerHighlighted(player.fullName) then
                        table.insert(players, player.fullName)
                    end
                end
            end
            setPlayersFunc(players)
            if onChangeCallback then onChangeCallback() end
            container:Refresh()
        end)
        
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(color[1] * 0.25, color[2] * 0.25, color[3] * 0.25, 1)
            self:SetBackdropBorderColor(color[1], color[2], color[3], 1)
        end)
        
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(color[1] * 0.15, color[2] * 0.15, color[3] * 0.15, 0.9)
            self:SetBackdropBorderColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5, 0.8)
        end)
        
        return btn
    end
    
    local tankBtn = CreateQuickAddButton("+ Tanks", "TANK", ROLE_COLORS.TANK, 0)
    local healerBtn = CreateQuickAddButton("+ Healers", "HEALER", ROLE_COLORS.HEALER, 72)
    local dpsBtn = CreateQuickAddButton("+ DPS", "DAMAGER", ROLE_COLORS.DAMAGER, 144)
    local allBtn = CreateQuickAddButton("+ All", "ALL", {0.6, 0.6, 0.6}, 216)
    
    -- Clear All button (right side)
    local clearBtn = CreateFrame("Button", nil, buttonRow, "BackdropTemplate")
    clearBtn:SetSize(68, 24)
    clearBtn:SetPoint("RIGHT", 0, 0)
    clearBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    clearBtn:SetBackdropColor(0.5, 0.15, 0.15, 0.5)
    clearBtn:SetBackdropBorderColor(0.6, 0.25, 0.25, 0.8)
    
    clearBtn.text = clearBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    clearBtn.text:SetPoint("CENTER")
    clearBtn.text:SetText(L["Clear All"])
    clearBtn.text:SetTextColor(0.8, 0.35, 0.35)
    
    clearBtn:SetScript("OnClick", function()
        setPlayersFunc({})
        if onChangeCallback then onChangeCallback() end
        container:Refresh()
    end)
    
    clearBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.6, 0.2, 0.2, 0.8)
        self:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
    end)
    
    clearBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.5, 0.15, 0.15, 0.5)
        self:SetBackdropBorderColor(0.6, 0.25, 0.25, 0.8)
    end)
    
    -- Remove Offline button (next to Clear All)
    local removeOfflineBtn = CreateFrame("Button", nil, buttonRow, "BackdropTemplate")
    removeOfflineBtn:SetSize(90, 24)
    removeOfflineBtn:SetPoint("RIGHT", clearBtn, "LEFT", -6, 0)
    removeOfflineBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    removeOfflineBtn:SetBackdropColor(0.4, 0.3, 0.15, 0.5)
    removeOfflineBtn:SetBackdropBorderColor(0.5, 0.4, 0.2, 0.8)
    
    removeOfflineBtn.text = removeOfflineBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    removeOfflineBtn.text:SetPoint("CENTER")
    removeOfflineBtn.text:SetText(L["Remove Offline"])
    removeOfflineBtn.text:SetTextColor(0.7, 0.55, 0.3)
    
    removeOfflineBtn:SetScript("OnClick", function()
        local players = getPlayersFunc()
        local newPlayers = {}
        
        -- Keep only players that are in the current roster
        for _, fullName in ipairs(players) do
            local inGroup = false
            for _, p in ipairs(currentRoster) do
                if p.fullName == fullName or p.name == fullName then
                    inGroup = true
                    break
                end
            end
            if inGroup then
                table.insert(newPlayers, fullName)
            end
        end
        
        setPlayersFunc(newPlayers)
        if onChangeCallback then onChangeCallback() end
        container:Refresh()
    end)
    
    removeOfflineBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.5, 0.4, 0.2, 0.8)
        self:SetBackdropBorderColor(0.7, 0.55, 0.3, 1)
    end)
    
    removeOfflineBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.4, 0.3, 0.15, 0.5)
        self:SetBackdropBorderColor(0.5, 0.4, 0.2, 0.8)
    end)
    
    -- ========== MANUAL PLAYER ENTRY ==========
    local themeColor = GetThemeColor()
    local manualHeader = container:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    manualHeader:SetPoint("TOPLEFT", buttonRow, "BOTTOMLEFT", 0, -12)
    manualHeader:SetText(L["Add Offline Player"])
    manualHeader:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    
    local manualHelp = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    manualHelp:SetPoint("TOPLEFT", manualHeader, "BOTTOMLEFT", 0, -2)
    manualHelp:SetText(L["Pre-configure players before they join the group"])
    manualHelp:SetTextColor(0.45, 0.45, 0.45)
    
    local manualInput = CreateFrame("EditBox", nil, container, "BackdropTemplate")
    manualInput:SetPoint("TOPLEFT", manualHelp, "BOTTOMLEFT", 0, -6)
    manualInput:SetSize(380, 24)
    manualInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    manualInput:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    manualInput:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    manualInput:SetFontObject(DFFontHighlight)
    manualInput:SetTextInsets(8, 8, 0, 0)
    manualInput:SetAutoFocus(false)
    manualInput:SetMaxLetters(50)
    
    manualInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    
    manualInput:SetScript("OnEnterPressed", function(self)
        local text = self:GetText():trim()
        if text ~= "" then
            -- Add realm if not present
            if not text:find("-") then
                text = text .. "-" .. GetRealmName()
            end
            AddPlayer(text)
            self:SetText("")
            container:Refresh()
        end
        self:ClearFocus()
    end)
    
    local addManualBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
    addManualBtn:SetPoint("LEFT", manualInput, "RIGHT", 6, 0)
    addManualBtn:SetSize(54, 24)
    addManualBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    addManualBtn:SetBackdropColor(themeColor.r * 0.2, themeColor.g * 0.2, themeColor.b * 0.2, 0.9)
    addManualBtn:SetBackdropBorderColor(themeColor.r * 0.5, themeColor.g * 0.5, themeColor.b * 0.5, 0.8)
    
    addManualBtn.text = addManualBtn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    addManualBtn.text:SetPoint("CENTER")
    addManualBtn.text:SetText(L["Add"])
    addManualBtn.text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
    
    addManualBtn:SetScript("OnClick", function()
        local text = manualInput:GetText():trim()
        if text ~= "" then
            if not text:find("-") then
                text = text .. "-" .. GetRealmName()
            end
            AddPlayer(text)
            manualInput:SetText("")
            container:Refresh()
        end
    end)
    
    addManualBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
        self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
    end)
    
    addManualBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(themeColor.r * 0.2, themeColor.g * 0.2, themeColor.b * 0.2, 0.9)
        self:SetBackdropBorderColor(themeColor.r * 0.5, themeColor.g * 0.5, themeColor.b * 0.5, 0.8)
    end)
    
    -- ========== REFRESH FUNCTION ==========
    function container:Refresh()
        -- Get current roster
        currentRoster = GetGroupRoster()
        local players = getPlayersFunc()
        
        -- Clear existing items
        for _, item in ipairs(rosterItems) do
            item:Hide()
            item:SetParent(nil)
        end
        wipe(rosterItems)
        
        for _, item in ipairs(highlightItems) do
            item:Hide()
            item:SetParent(nil)
        end
        wipe(highlightItems)
        
        -- Update counts
        leftCount:SetText("(" .. #currentRoster .. ")")
        rightCount:SetText("(" .. #players .. ")")
        
        -- Build left column (roster)
        for i, playerData in ipairs(currentRoster) do
            local item = CreateRosterItem(playerData, i)
            table.insert(rosterItems, item)
        end
        leftContent:SetHeight(math.max(1, #currentRoster * ITEM_HEIGHT))
        
        -- Build right column (highlighted)
        for i, fullName in ipairs(players) do
            local item = CreateHighlightItem(fullName, i, #players)
            table.insert(highlightItems, item)
        end
        rightContent:SetHeight(math.max(1, #players * ITEM_HEIGHT))
        
        -- Show hint if empty
        if #players == 0 then
            if not container.emptyHint then
                container.emptyHint = rightContent:CreateFontString(nil, "OVERLAY", "DFFontNormal")
                container.emptyHint:SetPoint("CENTER", rightBg, "CENTER", 0, 0)
                container.emptyHint:SetText(L["Add players from the roster\nor use quick add buttons"])
                container.emptyHint:SetTextColor(0.35, 0.35, 0.35)
                container.emptyHint:SetJustifyH("CENTER")
            end
            container.emptyHint:Show()
        elseif container.emptyHint then
            container.emptyHint:Hide()
        end
    end
    
    -- Register for roster updates
    container:RegisterEvent("GROUP_ROSTER_UPDATE")
    container:RegisterEvent("PLAYER_ENTERING_WORLD")
    container:SetScript("OnEvent", function(self, event)
        self:Refresh()
    end)
    
    -- Initial refresh
    container:Refresh()
    
    return container
end

-- Gradient Preview Bar
function GUI:CreateGradientBar(parent, width, height, db, prefix)
    prefix = prefix or "healthColor"
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(width or 360, height or 24)
    CreateElementBackdrop(f)
    
    local lbl = f:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmallOutline")
    lbl:SetPoint("LEFT", f, "LEFT", 8, 0)
    lbl:SetText("0%")
    lbl:SetTextColor(1, 1, 1, 1)
    
    local lbl2 = f:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmallOutline")
    lbl2:SetPoint("RIGHT", f, "RIGHT", -8, 0)
    lbl2:SetText("100%")
    lbl2:SetTextColor(1, 1, 1, 1)
    
    f.TexPool = {}
    
    f.UpdatePreview = function()
        if not db then return end
        
        for _, tex in ipairs(f.TexPool) do tex:Hide() end
        
        local _, pClass = UnitClass("player")
        local classCol = DF:GetClassColor(pClass)
        
        local function GetC(stage)
            if db[prefix .. stage .. "UseClass"] then
                return CreateColor(classCol.r, classCol.g, classCol.b, 1)
            end
            local c = db[prefix .. stage]
            if not c or not c.r then return CreateColor(1, 1, 1, 1) end
            return CreateColor(c.r, c.g, c.b, 1)
        end
        
        local lCol = GetC("Low")
        local mCol = GetC("Medium")
        local hCol = GetC("High")
        
        local lowW = math.max(1, math.floor(db[prefix .. "LowWeight"] or 1))
        local medW = math.max(1, math.floor(db[prefix .. "MediumWeight"] or 1))
        local highW = math.max(1, math.floor(db[prefix .. "HighWeight"] or 1))
        
        local points = {}
        for i = 1, lowW do table.insert(points, lCol) end
        for i = 1, medW do table.insert(points, mCol) end
        for i = 1, highW do table.insert(points, hCol) end
        
        if #points < 2 then points = {lCol, hCol} end
        
        local numSegments = #points - 1
        local segWidth = (f:GetWidth() - 4) / numSegments
        
        for i = 1, numSegments do
            local tex = f.TexPool[i]
            if not tex then
                tex = f:CreateTexture(nil, "ARTWORK")
                table.insert(f.TexPool, tex)
            end
            
            tex:Show()
            tex:ClearAllPoints()
            tex:SetPoint("LEFT", f, "LEFT", 2 + (i - 1) * segWidth, 0)
            tex:SetSize(segWidth, f:GetHeight() - 4)
            
            local c1 = points[i]
            local c2 = points[i + 1]
            
            tex:SetColorTexture(1, 1, 1, 1)
            tex:SetGradient("HORIZONTAL", c1, c2)
        end
    end
    
    f:SetScript("OnShow", f.UpdatePreview)
    f.UpdatePreview()
    return f
end

-- =========================================================================
-- SELECTABLE LIST WIDGET
-- Scrollable list of selectable items with hover highlight and accent
-- selection bar. Used by the Wizard Builder for wizard/step lists.
-- =========================================================================

function GUI:CreateSelectableList(parent, width, height, onSelect)
    local ROW_HEIGHT = 28
    local MAX_VISIBLE = math.floor(height / ROW_HEIGHT)

    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(width, height)
    CreateElementBackdrop(container)

    -- Scroll frame
    local scroll = CreateFrame("ScrollFrame", nil, container, "ScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", -20, 2)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(width - 24)
    scroll:SetScrollChild(child)

    StyleScrollBar(scroll)

    -- State
    local items = {}
    local selectedIndex = nil
    local rowPool = {}

    local function GetRow(index)
        if rowPool[index] then return rowPool[index] end

        local row = CreateFrame("Button", nil, child, "BackdropTemplate")
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))
        row:SetPoint("TOPRIGHT", 0, -((index - 1) * ROW_HEIGHT))

        row:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
        })
        row:SetBackdropColor(0, 0, 0, 0)

        -- Accent bar on left (hidden by default)
        row.accent = row:CreateTexture(nil, "OVERLAY")
        row.accent:SetPoint("TOPLEFT", 0, 0)
        row.accent:SetPoint("BOTTOMLEFT", 0, 0)
        row.accent:SetWidth(3)
        row.accent:Hide()

        row.label = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        row.label:SetPoint("LEFT", 8, 0)
        row.label:SetPoint("RIGHT", -4, 0)
        row.label:SetJustifyH("LEFT")
        row.label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

        row:SetScript("OnEnter", function(self)
            if selectedIndex ~= self.index then
                self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
            end
        end)
        row:SetScript("OnLeave", function(self)
            if selectedIndex ~= self.index then
                self:SetBackdropColor(0, 0, 0, 0)
            end
        end)
        row:SetScript("OnClick", function(self)
            container:SetSelected(self.index)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end)

        rowPool[index] = row
        return row
    end

    local function Refresh()
        local themeColor = GetThemeColor()
        child:SetHeight(math.max(1, #items * ROW_HEIGHT))

        for i = 1, math.max(#items, #rowPool) do
            local row = GetRow(i)
            if i <= #items then
                row.index = i
                row.label:SetText(items[i].label or items[i].name or tostring(items[i]))
                row:Show()

                if i == selectedIndex then
                    row:SetBackdropColor(C_ELEMENT.r + 0.05, C_ELEMENT.g + 0.05, C_ELEMENT.b + 0.05, 1)
                    row.accent:SetColorTexture(themeColor.r, themeColor.g, themeColor.b, 1)
                    row.accent:Show()
                    row.label:SetTextColor(1, 1, 1)
                else
                    row:SetBackdropColor(0, 0, 0, 0)
                    row.accent:Hide()
                    row.label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                end
            else
                row:Hide()
            end
        end
    end

    function container:SetItems(newItems)
        items = newItems or {}
        if selectedIndex and selectedIndex > #items then
            selectedIndex = #items > 0 and #items or nil
        end
        Refresh()
    end

    function container:GetItems()
        return items
    end

    function container:SetSelected(index)
        if index and (index < 1 or index > #items) then index = nil end
        local oldIndex = selectedIndex
        selectedIndex = index
        Refresh()
        if oldIndex ~= index and onSelect then
            onSelect(index and items[index] or nil, index)
        end
    end

    function container:GetSelected()
        return selectedIndex
    end

    function container:GetSelectedItem()
        return selectedIndex and items[selectedIndex] or nil
    end

    function container:RefreshDisplay()
        Refresh()
    end

    return container
end

-- =========================================================================
-- SEARCHABLE DROPDOWN WIDGET
-- Dropdown with a search/filter box. Used for the DB key picker (800+ keys)
-- and any large option set. Groups items by category headers.
-- =========================================================================

function GUI:CreateSearchableDropdown(parent, label, width, onSelect)
    local MENU_WIDTH = width or 260
    local ROW_HEIGHT = 22
    local MAX_VISIBLE = 12
    local SEARCH_HEIGHT = 26

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(MENU_WIDTH, 50)

    -- Label
    if label then
        container.label = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        container.label:SetPoint("TOPLEFT", 0, 0)
        container.label:SetText(label)
        container.label:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    end

    -- Button
    local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
    btn:SetSize(MENU_WIDTH, 24)
    btn:SetPoint("TOPLEFT", 0, -20)
    CreateElementBackdrop(btn)

    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 6, 0)
    btn.Text:SetPoint("RIGHT", -20, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    btn.Text:SetText(L["Select..."])

    btn.Arrow = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Arrow:SetPoint("RIGHT", -6, 0)
    btn.Arrow:SetText("v")
    btn.Arrow:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

    -- Menu frame
    local menuFrame = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetFrameLevel(300)
    menuFrame:SetWidth(MENU_WIDTH)
    menuFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    menuFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
    menuFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
    menuFrame:SetPoint("TOP", btn, "BOTTOM", 0, -2)
    menuFrame:Hide()
    menuFrame:EnableMouse(true)

    -- Search box
    local searchBox = CreateFrame("EditBox", nil, menuFrame, "BackdropTemplate")
    searchBox:SetSize(MENU_WIDTH - 12, SEARCH_HEIGHT)
    searchBox:SetPoint("TOP", 0, -6)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(DFFontHighlightSmall)
    searchBox:SetTextInsets(6, 6, 0, 0)
    CreateElementBackdrop(searchBox)

    searchBox.placeholder = searchBox:CreateFontString(nil, "OVERLAY", "DFFontDisableSmall")
    searchBox.placeholder:SetPoint("LEFT", 6, 0)
    searchBox.placeholder:SetText(L["Search..."])
    searchBox.placeholder:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.6)

    -- Scroll frame for menu items
    local menuScroll = CreateFrame("ScrollFrame", nil, menuFrame, "ScrollFrameTemplate")
    menuScroll:SetPoint("TOPLEFT", 4, -(SEARCH_HEIGHT + 12))
    menuScroll:SetPoint("BOTTOMRIGHT", -20, 4)

    local menuChild = CreateFrame("Frame", nil, menuScroll)
    menuChild:SetWidth(MENU_WIDTH - 28)
    menuScroll:SetScrollChild(menuChild)

    StyleScrollBar(menuScroll)

    -- State
    local allOptions = {}  -- { { value = "x", text = "X", category = "Cat" }, ... }
    local menuButtons = {}
    local selectedValue = nil

    local function RebuildMenu(filterText)
        filterText = filterText and filterText:lower() or ""

        -- Filter options
        local filtered = {}
        for _, opt in ipairs(allOptions) do
            if filterText == "" or (opt.text and opt.text:lower():find(filterText, 1, true)) or
               (opt.value and tostring(opt.value):lower():find(filterText, 1, true)) then
                tinsert(filtered, opt)
            end
        end

        -- Group by category
        local categories = {}
        local catOrder = {}
        for _, opt in ipairs(filtered) do
            local cat = opt.category or ""
            if not categories[cat] then
                categories[cat] = {}
                tinsert(catOrder, cat)
            end
            tinsert(categories[cat], opt)
        end

        -- Build rows
        local yOffset = 0
        local rowIndex = 0
        local themeColor = GetThemeColor()

        -- Hide existing
        for _, b in ipairs(menuButtons) do b:Hide() end

        for _, cat in ipairs(catOrder) do
            -- Category header (if not empty string)
            if cat ~= "" then
                rowIndex = rowIndex + 1
                local header = menuButtons[rowIndex]
                if not header then
                    header = CreateFrame("Frame", nil, menuChild)
                    header:SetHeight(18)
                    menuButtons[rowIndex] = header
                    header.label = header:CreateFontString(nil, "OVERLAY", "DFFontDisableSmall")
                    header.label:SetPoint("LEFT", 4, 0)
                    header.label:SetJustifyH("LEFT")
                    header.isHeader = true
                end
                header:SetPoint("TOPLEFT", 0, -yOffset)
                header:SetPoint("TOPRIGHT", 0, -yOffset)
                header.label:SetText(cat:upper())
                header.label:SetTextColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
                header:Show()
                yOffset = yOffset + 18
            end

            -- Options in this category
            for _, opt in ipairs(categories[cat]) do
                rowIndex = rowIndex + 1
                local row = menuButtons[rowIndex]
                if not row then
                    row = CreateFrame("Button", nil, menuChild, "BackdropTemplate")
                    row:SetHeight(ROW_HEIGHT)
                    row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
                    row:SetBackdropColor(0, 0, 0, 0)
                    menuButtons[rowIndex] = row
                    row.label = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                    row.label:SetPoint("LEFT", 8, 0)
                    row.label:SetPoint("RIGHT", -4, 0)
                    row.label:SetJustifyH("LEFT")

                    row:SetScript("OnEnter", function(self)
                        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
                    end)
                    row:SetScript("OnLeave", function(self)
                        if self.optValue == selectedValue then
                            self:SetBackdropColor(themeColor.r, themeColor.g, themeColor.b, 0.15)
                        else
                            self:SetBackdropColor(0, 0, 0, 0)
                        end
                    end)
                    row:SetScript("OnClick", function(self)
                        selectedValue = self.optValue
                        btn.Text:SetText(self.optText or tostring(self.optValue))
                        menuFrame:Hide()
                        CloseOpenDropdown()
                        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                        if onSelect then onSelect(self.optValue, self.optText) end
                    end)
                end
                row:SetPoint("TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", 0, -yOffset)
                row.optValue = opt.value
                row.optText = opt.text
                row.label:SetText(opt.text or tostring(opt.value))

                if opt.value == selectedValue then
                    row:SetBackdropColor(themeColor.r, themeColor.g, themeColor.b, 0.15)
                    row.label:SetTextColor(1, 1, 1)
                else
                    row:SetBackdropColor(0, 0, 0, 0)
                    row.label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                end
                row:Show()
                yOffset = yOffset + ROW_HEIGHT
            end
        end

        menuChild:SetHeight(math.max(1, yOffset))
        local visibleHeight = math.min(yOffset, MAX_VISIBLE * ROW_HEIGHT)
        menuFrame:SetHeight(visibleHeight + SEARCH_HEIGHT + 20)
    end

    -- Search box handlers
    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        searchBox.placeholder:SetShown(text == "")
        RebuildMenu(text)
    end)
    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        menuFrame:Hide()
        CloseOpenDropdown()
    end)

    -- Button toggle
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)
    btn:SetScript("OnClick", function()
        if menuFrame:IsShown() then
            menuFrame:Hide()
            CloseOpenDropdown()
        else
            CloseOpenDropdown()
            searchBox:SetText("")
            RebuildMenu("")
            menuFrame:Show()
            SetOpenDropdown(menuFrame)
            searchBox:SetFocus()
        end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)

    -- Public API
    function container:SetOptions(opts)
        allOptions = opts or {}
        RebuildMenu("")
    end

    function container:SetValue(value)
        selectedValue = value
        -- Find display text
        for _, opt in ipairs(allOptions) do
            if opt.value == value then
                btn.Text:SetText(opt.text or tostring(value))
                return
            end
        end
        btn.Text:SetText(value and tostring(value) or L["Select..."])
    end

    function container:GetValue()
        return selectedValue
    end

    function container:SetEnabled(enabled)
        btn:SetEnabled(enabled)
        if enabled then
            btn:SetAlpha(1)
        else
            btn:SetAlpha(0.5)
            menuFrame:Hide()
        end
    end

    return container
end

-- =========================================================================
-- KEY-VALUE EDITOR WIDGET
-- Editable list of key=value rows for the wizard builder settings map.
-- Each row: [Searchable Key Dropdown] = [Value Input] [X Delete]
-- =========================================================================

function GUI:CreateKeyValueEditor(parent, width, keyOptionsFunc, onChanged)
    local ROW_HEIGHT = 50
    local KEY_WIDTH = math.floor(width * 0.55)
    local VAL_WIDTH = math.floor(width * 0.30)
    local DEL_WIDTH = 22

    local container = CreateFrame("Frame", nil, parent)
    container:SetWidth(width)

    local rows = {}
    local data = {}  -- { { key = "party.x", value = 123 }, ... }

    local function NotifyChanged()
        local result = {}
        for _, entry in ipairs(data) do
            if entry.key and entry.key ~= "" then
                result[entry.key] = entry.value
            end
        end
        if onChanged then onChanged(result) end
    end

    local function InferValueType(key)
        -- Determine input type from defaults
        if not key then return "string" end
        local mode, dbKey = key:match("^(%w+)%.(.+)$")
        if not mode or not dbKey then return "string" end
        local defaults = (mode == "party") and DF.PartyDefaults or
                         (mode == "raid") and DF.RaidDefaults or nil
        if not defaults then return "string" end
        local defaultVal = defaults[dbKey]
        if defaultVal == nil then return "string" end
        local t = type(defaultVal)
        if t == "boolean" then return "boolean" end
        if t == "number" then return "number" end
        if t == "table" and defaultVal.r and defaultVal.g and defaultVal.b then return "color" end
        return "string"
    end

    local function BuildRow(index)
        local row = rows[index]
        if not row then
            row = CreateFrame("Frame", nil, container)
            row:SetHeight(ROW_HEIGHT)
            rows[index] = row

            -- Key dropdown
            row.keyDropdown = GUI:CreateSearchableDropdown(row, nil, KEY_WIDTH - 4, function(value, text)
                data[index].key = value
                -- Update value input type
                local vtype = InferValueType(value)
                row:UpdateValueInput(vtype, data[index].value)
                NotifyChanged()
            end)
            row.keyDropdown:SetPoint("TOPLEFT", 0, 0)

            -- Value input (edit box by default, swapped for checkbox if boolean)
            row.valueFrame = CreateFrame("Frame", nil, row)
            row.valueFrame:SetSize(VAL_WIDTH, 24)
            row.valueFrame:SetPoint("TOPLEFT", KEY_WIDTH, -20)

            row.valueEdit = CreateFrame("EditBox", nil, row.valueFrame, "BackdropTemplate")
            row.valueEdit:SetSize(VAL_WIDTH, 24)
            row.valueEdit:SetPoint("TOPLEFT")
            row.valueEdit:SetAutoFocus(false)
            row.valueEdit:SetFontObject(DFFontHighlightSmall)
            row.valueEdit:SetTextInsets(6, 6, 0, 0)
            CreateElementBackdrop(row.valueEdit)
            row.valueEdit:SetScript("OnEnterPressed", function(self)
                self:ClearFocus()
                local vtype = InferValueType(data[index].key)
                if vtype == "number" then
                    data[index].value = tonumber(self:GetText()) or 0
                else
                    data[index].value = self:GetText()
                end
                NotifyChanged()
            end)
            row.valueEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            row.valueCheck = CreateFrame("CheckButton", nil, row.valueFrame)
            row.valueCheck:SetSize(20, 20)
            row.valueCheck:SetPoint("TOPLEFT", 2, -2)
            row.valueCheck:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
            row.valueCheck:GetNormalTexture():SetVertexColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            local checkTex = row.valueCheck:CreateTexture(nil, "OVERLAY")
            checkTex:SetSize(14, 14)
            checkTex:SetPoint("CENTER")
            checkTex:SetTexture("Interface\\Buttons\\WHITE8x8")
            row.valueCheck.checkTex = checkTex
            row.valueCheck:SetScript("OnClick", function(self)
                data[index].value = self:GetChecked()
                local tc = GetThemeColor()
                self.checkTex:SetVertexColor(tc.r, tc.g, tc.b, data[index].value and 1 or 0)
                NotifyChanged()
            end)
            row.valueCheck:Hide()

            row.valueBoolLabel = row.valueFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            row.valueBoolLabel:SetPoint("LEFT", row.valueCheck, "RIGHT", 4, 0)
            row.valueBoolLabel:SetText(L["Enabled"])
            row.valueBoolLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            row.valueBoolLabel:Hide()

            -- Delete button
            row.deleteBtn = GUI:CreateButton(row, "X", DEL_WIDTH, 24, function()
                tremove(data, index)
                container:Refresh()
                NotifyChanged()
            end)
            row.deleteBtn:SetPoint("TOPLEFT", KEY_WIDTH + VAL_WIDTH + 4, -20)

            function row:UpdateValueInput(vtype, val)
                if vtype == "boolean" then
                    row.valueEdit:Hide()
                    row.valueCheck:Show()
                    row.valueBoolLabel:Show()
                    row.valueCheck:SetChecked(val == true)
                    local tc = GetThemeColor()
                    row.valueCheck.checkTex:SetVertexColor(tc.r, tc.g, tc.b, val and 1 or 0)
                else
                    row.valueCheck:Hide()
                    row.valueBoolLabel:Hide()
                    row.valueEdit:Show()
                    row.valueEdit:SetText(val ~= nil and tostring(val) or "")
                end
            end
        end
        return row
    end

    -- Add button
    local addBtn = GUI:CreateButton(container, "+ Add Setting", 120, 22, function()
        tinsert(data, { key = "", value = "" })
        container:Refresh()
    end)

    function container:Refresh()
        local keyOpts = keyOptionsFunc and keyOptionsFunc() or {}
        local yOffset = 0

        for i = 1, math.max(#data, #rows) do
            if i <= #data then
                local row = BuildRow(i)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", 0, -yOffset)
                row.keyDropdown:SetOptions(keyOpts)
                row.keyDropdown:SetValue(data[i].key)

                local vtype = InferValueType(data[i].key)
                row:UpdateValueInput(vtype, data[i].value)
                row:Show()
                yOffset = yOffset + ROW_HEIGHT + 4
            elseif rows[i] then
                rows[i]:Hide()
            end
        end

        addBtn:ClearAllPoints()
        addBtn:SetPoint("TOPLEFT", 0, -yOffset)
        container:SetHeight(yOffset + 30)
    end

    function container:SetData(newData)
        -- newData = { ["party.key"] = value, ... }
        data = {}
        if newData then
            for k, v in pairs(newData) do
                tinsert(data, { key = k, value = v })
            end
        end
        container:Refresh()
    end

    function container:GetData()
        local result = {}
        for _, entry in ipairs(data) do
            if entry.key and entry.key ~= "" then
                result[entry.key] = entry.value
            end
        end
        return result
    end

    container:Refresh()
    return container
end

-- =========================================================================
-- BRANCH EDITOR WIDGET
-- Visual editor for conditional wizard branching rules.
-- Each row: IF [step] [operator] [value] → [goto step] [X]
-- Plus: ELSE → [fallback step]
-- =========================================================================

function GUI:CreateBranchEditor(parent, width, onChanged)
    local ROW_HEIGHT = 30
    local container = CreateFrame("Frame", nil, parent)
    container:SetWidth(width)

    local branches = {}  -- { { condition = { step = "", equals = "" }, goto = "" }, ... }
    local fallbackNext = nil
    local stepOptions = {}  -- populated externally
    local rows = {}

    local function NotifyChanged()
        if onChanged then onChanged(branches, fallbackNext) end
    end

    local function MakeStepDropdown(parentFrame, w, onChange)
        local dd = CreateFrame("Button", nil, parentFrame, "BackdropTemplate")
        dd:SetSize(w, 22)
        CreateElementBackdrop(dd)

        dd.Text = dd:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        dd.Text:SetPoint("LEFT", 4, 0)
        dd.Text:SetPoint("RIGHT", -14, 0)
        dd.Text:SetJustifyH("LEFT")
        dd.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        dd.Text:SetText(L["(none)"])

        dd.Arrow = dd:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        dd.Arrow:SetPoint("RIGHT", -4, 0)
        dd.Arrow:SetText("v")
        dd.Arrow:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

        dd.value = nil

        -- Simple menu
        local menu = CreateFrame("Frame", nil, dd, "BackdropTemplate")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetFrameLevel(310)
        menu:SetWidth(w)
        menu:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        menu:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
        menu:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        menu:SetPoint("TOP", dd, "BOTTOM", 0, -1)
        menu:Hide()
        menu:EnableMouse(true)

        local menuBtns = {}

        local function RebuildMenu()
            for _, b in ipairs(menuBtns) do b:Hide() end
            local y = 0
            for i, opt in ipairs(stepOptions) do
                local b = menuBtns[i]
                if not b then
                    b = CreateFrame("Button", nil, menu, "BackdropTemplate")
                    b:SetHeight(22)
                    b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
                    b:SetBackdropColor(0, 0, 0, 0)
                    menuBtns[i] = b
                    b.label = b:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                    b.label:SetPoint("LEFT", 6, 0)
                    b.label:SetJustifyH("LEFT")
                    b:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
                    b:SetScript("OnLeave", function(self) self:SetBackdropColor(0, 0, 0, 0) end)
                    b:SetScript("OnClick", function(self)
                        dd.value = self.optValue
                        dd.Text:SetText(self.optValue or L["(none)"])
                        menu:Hide()
                        CloseOpenDropdown()
                        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                        if onChange then onChange(self.optValue) end
                    end)
                end
                b:SetPoint("TOPLEFT", 2, -y)
                b:SetPoint("TOPRIGHT", -2, -y)
                b.optValue = opt.value or opt
                b.label:SetText(opt.text or opt.value or tostring(opt))
                b.label:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                b:Show()
                y = y + 22
            end
            menu:SetHeight(math.max(22, y + 4))
        end

        dd:SetScript("OnClick", function()
            if menu:IsShown() then
                menu:Hide()
                CloseOpenDropdown()
            else
                CloseOpenDropdown()
                RebuildMenu()
                menu:Show()
                SetOpenDropdown(menu)
            end
        end)
        dd:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
        dd:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)

        function dd:SetValue(v)
            dd.value = v
            dd.Text:SetText(v or L["(none)"])
        end

        return dd
    end

    local function BuildRow(index)
        local row = rows[index]
        if not row then
            row = CreateFrame("Frame", nil, container)
            row:SetHeight(ROW_HEIGHT)
            rows[index] = row

            -- "IF" label
            row.ifLabel = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            row.ifLabel:SetPoint("LEFT", 0, 0)
            row.ifLabel:SetText("IF")
            row.ifLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

            -- Step dropdown (which step's answer to check)
            row.stepDD = MakeStepDropdown(row, 90, function(val)
                branches[index].condition.step = val
                NotifyChanged()
            end)
            row.stepDD:SetPoint("LEFT", row.ifLabel, "RIGHT", 4, 0)

            -- Operator label ("=")
            row.opLabel = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            row.opLabel:SetPoint("LEFT", row.stepDD, "RIGHT", 4, 0)
            row.opLabel:SetText("=")
            row.opLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

            -- Value edit
            row.valueEdit = CreateFrame("EditBox", nil, row, "BackdropTemplate")
            row.valueEdit:SetSize(70, 22)
            row.valueEdit:SetPoint("LEFT", row.opLabel, "RIGHT", 4, 0)
            row.valueEdit:SetAutoFocus(false)
            row.valueEdit:SetFontObject(DFFontHighlightSmall)
            row.valueEdit:SetTextInsets(4, 4, 0, 0)
            CreateElementBackdrop(row.valueEdit)
            row.valueEdit:SetScript("OnEnterPressed", function(self)
                self:ClearFocus()
                branches[index].condition.equals = self:GetText()
                NotifyChanged()
            end)
            row.valueEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            -- Arrow label
            row.arrowLabel = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            row.arrowLabel:SetPoint("LEFT", row.valueEdit, "RIGHT", 4, 0)
            row.arrowLabel:SetText("->")
            row.arrowLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

            -- Goto step dropdown
            row.gotoDD = MakeStepDropdown(row, 80, function(val)
                branches[index]["goto"] = val
                NotifyChanged()
            end)
            row.gotoDD:SetPoint("LEFT", row.arrowLabel, "RIGHT", 4, 0)

            -- Delete button
            row.deleteBtn = GUI:CreateButton(row, "X", 22, 22, function()
                tremove(branches, index)
                container:Refresh()
                NotifyChanged()
            end)
            row.deleteBtn:SetPoint("LEFT", row.gotoDD, "RIGHT", 4, 0)
        end
        return row
    end

    -- Fallback row
    local fallbackRow = CreateFrame("Frame", nil, container)
    fallbackRow:SetHeight(ROW_HEIGHT)

    local elseLabel = fallbackRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    elseLabel:SetPoint("LEFT", 0, 0)
    elseLabel:SetText("ELSE ->")
    elseLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)

    local fallbackDD = MakeStepDropdown(fallbackRow, 100, function(val)
        fallbackNext = val
        NotifyChanged()
    end)
    fallbackDD:SetPoint("LEFT", elseLabel, "RIGHT", 4, 0)

    -- Add button
    local addBtn = GUI:CreateButton(container, "+ Add Rule", 100, 22, function()
        tinsert(branches, { condition = { step = "", equals = "" }, ["goto"] = "" })
        container:Refresh()
        NotifyChanged()
    end)

    function container:SetStepOptions(opts)
        stepOptions = opts or {}
    end

    function container:Refresh()
        local yOffset = 0

        for i = 1, math.max(#branches, #rows) do
            if i <= #branches then
                local row = BuildRow(i)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -yOffset)
                row:SetPoint("TOPRIGHT", 0, -yOffset)

                local b = branches[i]
                row.stepDD:SetValue(b.condition and b.condition.step or "")
                row.valueEdit:SetText(b.condition and b.condition.equals or "")
                row.gotoDD:SetValue(b["goto"] or "")
                row:Show()
                yOffset = yOffset + ROW_HEIGHT + 2
            elseif rows[i] then
                rows[i]:Hide()
            end
        end

        -- Fallback row
        fallbackRow:ClearAllPoints()
        fallbackRow:SetPoint("TOPLEFT", 0, -yOffset)
        fallbackRow:SetPoint("TOPRIGHT", 0, -yOffset)
        fallbackDD:SetValue(fallbackNext)
        yOffset = yOffset + ROW_HEIGHT + 4

        -- Add button
        addBtn:ClearAllPoints()
        addBtn:SetPoint("TOPLEFT", 0, -yOffset)
        yOffset = yOffset + 28

        container:SetHeight(yOffset)
    end

    function container:SetData(branchesData, fallback)
        branches = branchesData or {}
        fallbackNext = fallback
        container:Refresh()
    end

    function container:GetData()
        return branches, fallbackNext
    end

    container:Refresh()
    return container
end

-- =========================================================================
-- MAIN GUI CREATION
-- =========================================================================

function DF:ToggleGUI()
    if DF.GUIFrame and DF.GUIFrame:IsShown() then
        DF.GUIFrame:Hide()
    else
        if not DF.GUIFrame then
            DF:CreateGUI()
        end
        
        -- Auto-detect mode based on current group status
        -- ARENA FIX: Arena returns IsInRaid()=true but uses party-style layout/settings.
        -- Check for arena first so the settings UI shows party settings, not raid.
        if DF.IsInArena and DF:IsInArena() then
            GUI.SelectedMode = "party"
        elseif IsInRaid() then
            GUI.SelectedMode = "raid"
        else
            GUI.SelectedMode = "party"
        end
        
        -- Update theme colors to match selected mode
        if GUI.UpdateThemeColors then
            GUI.UpdateThemeColors()
        end
        
        -- Show correct content for the selected mode
        if GUI.ShowNormalContent then
            GUI:ShowNormalContent()
        end
        
        -- Refresh editing UI state (re-enables tabs that were disabled when closed during editing)
        local AutoProfilesUI = DF.AutoProfilesUI
        if AutoProfilesUI and AutoProfilesUI.RefreshEditingUI then
            AutoProfilesUI:RefreshEditingUI()
        end

        -- Refresh override stars (shows if a runtime profile is active)
        if AutoProfilesUI and AutoProfilesUI.RefreshTabOverrideStars then
            AutoProfilesUI:RefreshTabOverrideStars()
        end
        
        DF.GUIFrame:Show()
        GUI:RefreshCurrentPage()

        -- Auto-show changelog on first open after update
        if DandersFramesDB_v2 and DandersFramesDB_v2.lastSeenVersion ~= DF.VERSION then
            DandersFramesDB_v2.lastSeenVersion = DF.VERSION
            if GUI.changelogOverlay and GUI.changelogContent and GUI.changelogScroll then
                GUI.changelogContent:SetWidth(GUI.changelogScroll:GetWidth())
                GUI.changelogContent:SetText(GUI.FormatChangelog(DF.CHANGELOG_TEXT))
                GUI.changelogContent:SetCursorPosition(0)
                GUI.changelogOverlay:Show()
            end
        end
    end
end

function DF:CreateGUI()
    if DF.GUIFrame then return end
    
    -- Default and saved sizes
    local defaultWidth, defaultHeight = 760, 520
    local minWidth, minHeight = 520, 400
    local maxWidth, maxHeight = 1200, 900
    
    -- Load saved position and size (stored in party db since it's always available)
    local guiDb = DF.db and DF.db.party or {}
    local savedScale = guiDb.guiScale or 1.0
    local savedWidth = guiDb.guiWidth or defaultWidth
    local savedHeight = guiDb.guiHeight or defaultHeight
    
    -- Main frame (matching old addon approach - no BackdropTemplate in CreateFrame)
    local frame = CreateFrame("Frame", "DandersFramesGUI", UIParent)
    frame:SetSize(savedWidth, savedHeight)
    -- Restore saved position, or default to center
    if guiDb.guiPoint and guiDb.guiX then
        frame:SetPoint(guiDb.guiPoint, UIParent, guiDb.guiRelPoint or "CENTER", guiDb.guiX, guiDb.guiY)
    else
        frame:SetPoint("CENTER")
    end
    frame:SetFrameStrata("DIALOG")  -- Match old addon
    frame:SetToplevel(true)         -- Match old addon
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    frame:EnableMouse(true)
    frame:SetScale(savedScale)
    -- Note: Dragging is handled by titleBar, not main frame
    CreatePanelBackdrop(frame)
    frame:Hide()
    DF.GUIFrame = frame
    
    -- Allow closing with Escape key
    tinsert(UISpecialFrames, "DandersFramesGUI")
    
    -- Exit profile editing when GUI is closed
    frame:SetScript("OnHide", function()
        local AutoProfilesUI = DF.AutoProfilesUI
        if AutoProfilesUI and AutoProfilesUI:IsEditing() then
            AutoProfilesUI:ExitEditing(true)  -- Skip UI updates since GUI is closing
        end
    end)
    
    -- Title bar (handles dragging like old addon)
    -- Uses FULLSCREEN_DIALOG strata so it stays above dropdown menus and popups,
    -- allowing the window to be dragged even when settings panels are open.
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetHeight(30)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", -30, 0)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        -- Save position so it persists across sessions
        local point, _, relPoint, x, y = frame:GetPoint()
        if DF.db and DF.db.party then
            DF.db.party.guiPoint = point
            DF.db.party.guiRelPoint = relPoint
            DF.db.party.guiX = x
            DF.db.party.guiY = y
        end
    end)
    titleBar:SetFrameStrata("FULLSCREEN_DIALOG")
    titleBar:SetFrameLevel(200)
    
    local title = titleBar:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("LEFT", 12, 0)
    local versionStr = DF.VERSION or "Unknown"
    local channelTags = { alpha = " |cffff8800alpha|r", beta = " |cffff8800beta|r" }
    local channelTag = channelTags[DF.RELEASE_CHANNEL] or ""
    title:SetText("DandersFrames " .. versionStr .. channelTag)
    local c = GetThemeColor()
    title:SetTextColor(c.r, c.g, c.b)
    title.UpdateTheme = function()
        local nc = GetThemeColor()
        title:SetTextColor(nc.r, nc.g, nc.b)
    end
    
    -- Close button with icon
    local closeBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -8, -5)
    closeBtn:SetFrameStrata("FULLSCREEN_DIALOG")
    closeBtn:SetFrameLevel(210)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    closeBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER")
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.3, 0.3, 1)
        closeIcon:SetVertexColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        closeIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Info button (changelog)
    local infoBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
    infoBtn:SetSize(20, 20)
    infoBtn:SetPoint("TOPRIGHT", -32, -5)
    infoBtn:SetFrameStrata("FULLSCREEN_DIALOG")
    infoBtn:SetFrameLevel(210)
    infoBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    infoBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    infoBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local infoIcon = infoBtn:CreateTexture(nil, "OVERLAY")
    infoIcon:SetPoint("CENTER")
    infoIcon:SetSize(16, 16)
    infoIcon:SetAtlas("QuestNormal")
    infoIcon:SetDesaturated(true)
    infoIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    infoBtn:SetScript("OnEnter", function(self)
        local tc = GetThemeColor()
        self:SetBackdropBorderColor(tc.r, tc.g, tc.b, 1)
        infoIcon:SetVertexColor(tc.r, tc.g, tc.b)
    end)
    infoBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        infoIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    end)

    -- Changelog overlay (covers full content area below title bar)
    local changelogOverlay = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    changelogOverlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -30)
    changelogOverlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    changelogOverlay:SetFrameStrata("FULLSCREEN_DIALOG")
    changelogOverlay:SetFrameLevel(300)
    CreatePanelBackdrop(changelogOverlay)
    changelogOverlay:Hide()
    GUI.changelogOverlay = changelogOverlay

    -- Header bar within the overlay
    local changelogHeader = CreateFrame("Frame", nil, changelogOverlay)
    changelogHeader:SetPoint("TOPLEFT", 8, -8)
    changelogHeader:SetPoint("TOPRIGHT", -8, -8)
    changelogHeader:SetHeight(24)

    local changelogTitle = changelogHeader:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    changelogTitle:SetPoint("LEFT", 4, 0)
    changelogTitle:SetText("Changelog — " .. versionStr)
    changelogTitle:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    local backBtn = CreateFrame("Button", nil, changelogHeader, "BackdropTemplate")
    backBtn:SetSize(60, 22)
    backBtn:SetPoint("RIGHT", 0, 0)
    CreateElementBackdrop(backBtn)
    local backText = backBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    backText:SetPoint("CENTER")
    backText:SetText(L["Back"])
    backText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    backBtn:SetScript("OnEnter", function(self)
        local tc = GetThemeColor()
        self:SetBackdropBorderColor(tc.r, tc.g, tc.b, 1)
    end)
    backBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    end)
    backBtn:SetScript("OnClick", function() changelogOverlay:Hide() end)

    -- Convert markdown changelog to WoW color-coded plain text
    local function FormatChangelog(text)
        if not text or text == "" then return L["No changelog available."] end
        local tc = GetThemeColor()
        local themeHex = format("%02x%02x%02x", tc.r * 255, tc.g * 255, tc.b * 255)
        local dimHex = format("%02x%02x%02x", C_TEXT_DIM.r * 255, C_TEXT_DIM.g * 255, C_TEXT_DIM.b * 255)
        local textHex = format("%02x%02x%02x", C_TEXT.r * 255, C_TEXT.g * 255, C_TEXT.b * 255)

        local lines = {}
        for line in text:gmatch("[^\n]*") do
            if line:match("^# ") then
                -- Main title — skip (already shown in header bar)
            elseif line:match("^## ") then
                -- Version header
                local content = line:gsub("^##%s*", "")
                lines[#lines + 1] = format("|cff%s%s|r", themeHex, content)
            elseif line:match("^### ") then
                -- Section header
                local content = line:gsub("^###%s*", "")
                lines[#lines + 1] = format("\n|cff%s%s|r", textHex, content)
            elseif line:match("^%*%s") or line:match("^%-%s") then
                -- Bullet point
                local content = line:gsub("^[%*%-]%s*", "")
                lines[#lines + 1] = format("  |cff%s\226\128\162|r  |cff%s%s|r", themeHex, dimHex, content)
            elseif line:match("^%s*$") then
                lines[#lines + 1] = ""
            else
                lines[#lines + 1] = format("|cff%s%s|r", dimHex, line)
            end
        end

        return table.concat(lines, "\n")
    end

    local changelogScroll = CreateFrame("ScrollFrame", nil, changelogOverlay, "ScrollFrameTemplate")
    changelogScroll:SetPoint("TOPLEFT", 8, -38)
    changelogScroll:SetPoint("BOTTOMRIGHT", -26, 8)

    local changelogContent = CreateFrame("EditBox", nil, changelogScroll)
    changelogContent:SetMultiLine(true)
    changelogContent:SetAutoFocus(false)
    changelogContent:SetFontObject(DFFontHighlightSmall)
    changelogContent:SetWidth(changelogScroll:GetWidth() or 500)
    changelogContent:SetText(FormatChangelog(DF.CHANGELOG_TEXT))
    changelogContent:SetCursorPosition(0)
    changelogContent:EnableMouse(true)
    changelogContent:EnableKeyboard(false)
    changelogContent:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    changelogContent:SetScript("OnEditFocusGained", function(self) self:HighlightText(0, 0) end)
    changelogScroll:SetScrollChild(changelogContent)
    StyleScrollBar(changelogScroll)
    GUI.FormatChangelog = FormatChangelog
    GUI.changelogContent = changelogContent
    GUI.changelogScroll = changelogScroll

    infoBtn:SetScript("OnClick", function()
        if changelogOverlay:IsShown() then
            changelogOverlay:Hide()
        else
            changelogContent:SetWidth(changelogScroll:GetWidth())
            changelogContent:SetText(FormatChangelog(DF.CHANGELOG_TEXT))
            changelogContent:SetCursorPosition(0)
            changelogOverlay:Show()
        end
    end)

    -- =========================================================================
    -- RESIZE HANDLE (bottom-right corner)
    -- =========================================================================
    local resizeHandle = CreateFrame("Button", nil, frame)
    resizeHandle:SetSize(16, 16)
    resizeHandle:SetPoint("BOTTOMRIGHT", -2, 2)
    resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeHandle:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing()
        -- Save new size
        DF.db.party.guiWidth = frame:GetWidth()
        DF.db.party.guiHeight = frame:GetHeight()
        -- Update content layout
        if GUI.SelectedMode == "clicks" then
            -- Refresh click casting UI on resize (skip scroll reset)
            if DF.ClickCast and DF.ClickCast.RefreshSpellGrid then
                DF.ClickCast:RefreshSpellGrid(true)
            end
        elseif GUI.RefreshCurrentPage then
            GUI:RefreshCurrentPage()
        end
    end)
    
    -- Party/Raid mode toggle buttons
    local btnParty = CreateFrame("Button", nil, frame, "BackdropTemplate")
    btnParty:SetPoint("TOPLEFT", 12, -32)
    btnParty:SetSize(70, 24)
    CreateElementBackdrop(btnParty)
    btnParty.Text = btnParty:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnParty.Text:SetPoint("CENTER")
    btnParty.Text:SetText(L["PARTY"])
    GUI.PartyButton = btnParty  -- Store for external access
    
    local btnRaid = CreateFrame("Button", nil, frame, "BackdropTemplate")
    btnRaid:SetPoint("LEFT", btnParty, "RIGHT", 4, 0)
    btnRaid:SetSize(70, 24)
    CreateElementBackdrop(btnRaid)
    btnRaid.Text = btnRaid:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnRaid.Text:SetPoint("CENTER")
    btnRaid.Text:SetText(L["RAID"])
    GUI.RaidButton = btnRaid  -- Store for external access
    
    -- Click Casting tab button
    local btnClicks = CreateFrame("Button", nil, frame, "BackdropTemplate")
    btnClicks:SetPoint("LEFT", btnRaid, "RIGHT", 4, 0)
    btnClicks:SetSize(70, 24)
    CreateElementBackdrop(btnClicks)
    btnClicks.Text = btnClicks:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnClicks.Text:SetPoint("CENTER")
    btnClicks.Text:SetText(L["BINDS"])
    GUI.ClicksButton = btnClicks
    
    -- =========================================================================
    -- TEST MODE BUTTON (next to CLICKS tab)
    -- =========================================================================
    local btnTest = CreateFrame("Button", nil, frame, "BackdropTemplate")
    btnTest:SetPoint("LEFT", btnClicks, "RIGHT", 12, 0)
    btnTest:SetSize(75, 24)
    CreateElementBackdrop(btnTest)
    btnTest.Icon = btnTest:CreateTexture(nil, "OVERLAY")
    btnTest.Icon:SetPoint("LEFT", 6, 0)
    btnTest.Icon:SetSize(14, 14)
    btnTest.Icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\visibility")
    btnTest.Icon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    btnTest.Text = btnTest:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnTest.Text:SetPoint("LEFT", btnTest.Icon, "RIGHT", 4, 0)
    btnTest.Text:SetText(L["Test"])
    btnTest.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    GUI.TestButton = btnTest
    
    -- =========================================================================
    -- LOCK/UNLOCK BUTTON (next to Test button)
    -- =========================================================================
    local btnLock = CreateFrame("Button", nil, frame, "BackdropTemplate")
    btnLock:SetPoint("LEFT", btnTest, "RIGHT", 4, 0)
    btnLock:SetSize(80, 24)
    CreateElementBackdrop(btnLock)
    btnLock.Icon = btnLock:CreateTexture(nil, "OVERLAY")
    btnLock.Icon:SetPoint("LEFT", 6, 0)
    btnLock.Icon:SetSize(14, 14)
    btnLock.Icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\lock")
    btnLock.Icon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    btnLock.Text = btnLock:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btnLock.Text:SetPoint("LEFT", btnLock.Icon, "RIGHT", 4, 0)
    btnLock.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    GUI.LockButton = btnLock
    
    -- Position override star (shown next to lock button when position is overridden)
    local positionOverrideStar = frame:CreateTexture(nil, "OVERLAY")
    positionOverrideStar:SetSize(14, 14)
    positionOverrideStar:SetPoint("LEFT", btnLock, "RIGHT", 4, 0)
    positionOverrideStar:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
    positionOverrideStar:SetVertexColor(1, 0.8, 0.2)  -- Yellow/gold
    positionOverrideStar:Hide()
    GUI.PositionOverrideStar = positionOverrideStar
    
    -- Function to update position override indicator
    local function UpdatePositionOverrideIndicator()
        -- Debug mode shows indicator
        if overrideDebugMode then
            positionOverrideStar:Show()
            return
        end
        
        if GUI.SelectedMode ~= "raid" then
            positionOverrideStar:Hide()
            return
        end
        
        local AutoProfilesUI = DF.AutoProfilesUI
        if not AutoProfilesUI or not AutoProfilesUI:IsEditing() then
            positionOverrideStar:Hide()
            return
        end
        
        -- Check if position is overridden (either X or Y)
        local xOverridden = AutoProfilesUI:IsSettingOverridden("raidAnchorX")
        local yOverridden = AutoProfilesUI:IsSettingOverridden("raidAnchorY")
        
        if xOverridden or yOverridden then
            positionOverrideStar:Show()
        else
            positionOverrideStar:Hide()
        end
    end
    GUI.UpdatePositionOverrideIndicator = UpdatePositionOverrideIndicator
    
    -- Forward declaration (defined after UpdateThemeColors)
    local UpdateTestButtonState
    
    local function UpdateLockButtonState()
        local db = DF.db[GUI.SelectedMode]
        -- Raid mode uses raidLocked, party mode uses locked
        local isLocked = db and (GUI.SelectedMode == "raid" and db.raidLocked or db.locked)
        local themeColor = GetThemeColor()
        
        btnLock.Text:SetText(isLocked and L["Unlock"] or L["Lock"])
        btnLock.Icon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\" .. (isLocked and "lock" or "lock_open"))
        
        if not isLocked then
            -- Unlocked - highlight the button
            btnLock:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            btnLock:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            btnLock.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            btnLock.Icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
        else
            -- Locked - normal state
            btnLock:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            btnLock:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)
            btnLock.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            btnLock.Icon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
        
        -- Update position override indicator
        UpdatePositionOverrideIndicator()
    end
    GUI.UpdateLockButtonState = UpdateLockButtonState
    
    btnLock:SetScript("OnClick", function()
        local db = DF.db[GUI.SelectedMode]
        if not db then return end
        
        -- Check current lock state using the correct key per mode
        local isLocked = GUI.SelectedMode == "raid" and db.raidLocked or db.locked
        
        if GUI.SelectedMode == "raid" then
            if isLocked then
                DF:UnlockRaidFrames()
            else
                DF:LockRaidFrames()
            end
        else
            if isLocked then
                DF:UnlockFrames()
            else
                DF:LockFrames()
            end
        end
        
        -- Lock/Unlock functions now call UpdateLockButtonState themselves,
        -- but call it here too as a safety net
        UpdateLockButtonState()
        UpdateTestButtonState()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    
    -- =========================================================================
    -- UI SCALE SLIDER (top right, always visible with larger min frame size)
    -- =========================================================================
    local scaleContainer = CreateFrame("Frame", nil, frame)
    scaleContainer:SetSize(155, 24)
    scaleContainer:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -32)
    
    local scaleLabel = scaleContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    scaleLabel:SetPoint("LEFT", 0, 0)
    scaleLabel:SetText(L["UI Scale:"])
    scaleLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local scaleSlider = CreateFrame("Slider", nil, scaleContainer, "BackdropTemplate")
    scaleSlider:SetPoint("LEFT", scaleLabel, "RIGHT", 6, 0)
    scaleSlider:SetSize(65, 14)
    scaleSlider:SetOrientation("HORIZONTAL")
    scaleSlider:SetMinMaxValues(0.6, 1.4)
    scaleSlider:SetValueStep(0.05)
    scaleSlider:SetObeyStepOnDrag(true)
    scaleSlider:SetValue(savedScale)
    CreateElementBackdrop(scaleSlider)
    
    -- Thumb texture
    local thumb = scaleSlider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 14)
    thumb:SetColorTexture(0.5, 0.5, 0.5, 1)
    scaleSlider:SetThumbTexture(thumb)
    
    local scaleValue = scaleContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    scaleValue:SetPoint("LEFT", scaleSlider, "RIGHT", 4, 0)
    scaleValue:SetText(string.format("%.0f%%", savedScale * 100))
    scaleValue:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Only update text while dragging (not main frame scale - that causes cursor drift)
    -- But DO update popup panels live
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 20 + 0.5) / 20  -- Round to 0.05
        scaleValue:SetText(string.format("%.0f%%", value * 100))
        -- Update popup panels live (they don't cause cursor drift)
        if DF.positionPanel then
            DF.positionPanel:SetScale(value)
        end
        if DF.TestPanel then
            DF.TestPanel:SetScale(value)
        end
    end)
    
    -- Apply scale only on mouse release to avoid cursor drift issues
    scaleSlider:SetScript("OnMouseUp", function(self)
        local value = math.floor(self:GetValue() * 20 + 0.5) / 20
        frame:SetScale(value)
        if DF.db and DF.db.party then
            DF.db.party.guiScale = value
        end
        -- Also update popup panels
        if DF.positionPanel then
            DF.positionPanel:SetScale(value)
        end
        if DF.TestPanel then
            DF.TestPanel:SetScale(value)
        end
    end)
    
    GUI.ScaleSlider = scaleSlider
    GUI.ScaleContainer = scaleContainer
    -- =========================================================================
    -- END TOP BAR CONTROLS
    -- =========================================================================
    
    local function UpdateThemeColors()
        local pc = C_ACCENT
        local rc = C_RAID
        local cc = {r = 0.2, g = 0.8, b = 0.4} -- Click casting green
        
        -- Reset all mode buttons first
        btnParty:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btnParty:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        btnParty.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        btnRaid:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btnRaid:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        btnRaid.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        btnClicks:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btnClicks:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        btnClicks.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        
        -- Highlight the selected mode
        if GUI.SelectedMode == "party" then
            btnParty:SetBackdropColor(pc.r, pc.g, pc.b, 1)
            btnParty:SetBackdropBorderColor(pc.r, pc.g, pc.b, 1)
            btnParty.Text:SetTextColor(1, 1, 1)
        elseif GUI.SelectedMode == "raid" then
            btnRaid:SetBackdropColor(rc.r, rc.g, rc.b, 1)
            btnRaid:SetBackdropBorderColor(rc.r, rc.g, rc.b, 1)
            btnRaid.Text:SetTextColor(1, 1, 1)
        elseif GUI.SelectedMode == "clicks" then
            btnClicks:SetBackdropColor(cc.r, cc.g, cc.b, 1)
            btnClicks:SetBackdropBorderColor(cc.r, cc.g, cc.b, 1)
            btnClicks.Text:SetTextColor(1, 1, 1)
        end
        
        -- Update Test button colors based on whether test panel is open
        local testActive = DF.TestPanel and DF.TestPanel:IsShown()
        local themeColor = GUI.SelectedMode == "party" and pc or (GUI.SelectedMode == "raid" and rc or cc)
        
        if testActive then
            btnTest:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            btnTest:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            btnTest.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            btnTest.Icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
        else
            btnTest:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            btnTest:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)
            btnTest.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            btnTest.Icon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
        
        -- Show/hide Test and Lock buttons based on mode
        if GUI.SelectedMode == "clicks" then
            btnTest:Hide()
            btnLock:Hide()
        else
            btnTest:Show()
            btnLock:Show()
        end
        
        title.UpdateTheme()
        
        -- Update active tab
        local nc = GetThemeColor()
        for name, btn in pairs(GUI.Tabs) do
            if btn.isActive and not btn.disabled then
                btn.accent:SetColorTexture(nc.r, nc.g, nc.b, 1)
                btn.Text:SetTextColor(nc.r, nc.g, nc.b)
                btn.Text:SetAlpha(1)
            elseif btn.disabled then
                btn.Text:SetTextColor(0.4, 0.4, 0.4)
                btn.Text:SetAlpha(1)
                if btn.accent then btn.accent:Hide() end
            end
        end
        
        -- Update theme listeners
        if GUI.CurrentPageName and GUI.Pages[GUI.CurrentPageName] then
            local page = GUI.Pages[GUI.CurrentPageName]
            if page.child and page.child.ThemeListeners then
                for _, widget in ipairs(page.child.ThemeListeners) do
                    if widget.UpdateTheme then widget:UpdateTheme() end
                end
            end
        end
        
        -- Update test panel if open (but don't trigger circular updates)
        if DF.TestPanel and DF.TestPanel:IsShown() then
            DF.TestPanel:UpdateStateNoCallback()
        end
        
        -- Update lock button state
        UpdateLockButtonState()
    end
    GUI.UpdateThemeColors = UpdateThemeColors
    
    -- Function to update test button state (called externally)
    UpdateTestButtonState = function()
        -- Highlight based on whether the test panel popup is visible
        local pc = C_ACCENT
        local rc = C_RAID
        local cc = {r = 0.2, g = 0.8, b = 0.4}
        local testActive = DF.TestPanel and DF.TestPanel:IsShown()
        local themeColor = GUI.SelectedMode == "party" and pc or (GUI.SelectedMode == "raid" and rc or cc)
        
        if testActive then
            btnTest:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            btnTest:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            btnTest.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            btnTest.Icon:SetVertexColor(themeColor.r, themeColor.g, themeColor.b)
        else
            btnTest:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            btnTest:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)
            btnTest.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            btnTest.Icon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        end
    end
    GUI.UpdateTestButtonState = UpdateTestButtonState
    
    -- Test button scripts
    btnTest:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btnTest:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            -- Quick toggle test mode
            DF:ToggleTestMode()
            UpdateThemeColors()
        else
            -- Open/close test panel
            DF:ToggleTestPanel()
            UpdateTestButtonState()
        end
    end)
    
    btnTest:SetScript("OnEnter", function(self)
        local testActive = DF.TestPanel and DF.TestPanel:IsShown()
        if not testActive then
            local themeColor = GUI.SelectedMode == "party" and C_ACCENT or C_RAID
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
        end
    end)
    btnTest:SetScript("OnLeave", function(self)
        local testActive = DF.TestPanel and DF.TestPanel:IsShown()
        if not testActive then
            local themeColor = GUI.SelectedMode == "party" and C_ACCENT or C_RAID
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.5)
        end
    end)
    
    btnParty:SetScript("OnClick", function()
        DF:SyncLinkedSections()

        -- Before switching tabs, clean up current mode's test mode and unlock state
        if GUI.SelectedMode == "raid" then
            -- Lock raid frames if unlocked
            local raidDb = DF:GetRaidDB()
            if not raidDb.raidLocked then
                raidDb.raidLocked = true
                if DF.raidContainer then
                    DF.raidContainer:EnableMouse(false)
                    DF.raidContainer:SetMovable(false)
                end
                if DF.LockRaidFrames then DF:LockRaidFrames() end
            end
            -- Disable raid test mode if active
            if DF.raidTestMode then
                DF:HideRaidTestFrames(true)  -- silent
            end
        end
        
        GUI.SelectedMode = "party"
        if DF.Search then
            DF.Search:InvalidateRegistry()
            DF.Search:RefreshIfActive()
        end
        UpdateThemeColors()
        GUI:ShowNormalContent()
        GUI:UpdateTabAvailability()
        GUI:RefreshCurrentPage()
    end)
    btnRaid:SetScript("OnClick", function()
        DF:SyncLinkedSections()

        -- Before switching tabs, clean up current mode's test mode and unlock state
        if GUI.SelectedMode == "party" then
            -- Lock party frames if unlocked
            local partyDb = DF:GetDB()
            if not partyDb.locked then
                partyDb.locked = true
                if DF.partyContainer then
                    DF.partyContainer:EnableMouse(false)
                    DF.partyContainer:SetMovable(false)
                end
                if DF.LockFrames then DF:LockFrames() end
            end
            -- Disable party test mode if active
            if DF.testMode then
                DF:HideTestFrames(true)  -- silent
            end
        end
        
        GUI.SelectedMode = "raid"
        if DF.Search then
            DF.Search:InvalidateRegistry()
            DF.Search:RefreshIfActive()
        end
        UpdateThemeColors()
        GUI:ShowNormalContent()
        GUI:UpdateTabAvailability()
        GUI:RefreshCurrentPage()
    end)
    
    -- Click Casting tab click handler
    btnClicks:SetScript("OnClick", function()
        -- Clean up any test/unlock state from previous mode
        if GUI.SelectedMode == "party" then
            local partyDb = DF:GetDB()
            if partyDb and not partyDb.locked then
                partyDb.locked = true
                if DF.LockFrames then DF:LockFrames() end
            end
            if DF.testMode then DF:HideTestFrames(true) end
        elseif GUI.SelectedMode == "raid" then
            local raidDb = DF:GetRaidDB()
            if raidDb and not raidDb.raidLocked then
                raidDb.raidLocked = true
                if DF.LockRaidFrames then DF:LockRaidFrames() end
            end
            if DF.raidTestMode then DF:HideRaidTestFrames(true) end
        end
        
        GUI.SelectedMode = "clicks"
        if DF.Search then 
            DF.Search:HideResults()
        end
        UpdateThemeColors()
        GUI:ShowClickCastingContent()
    end)
    
    -- Tab container (left side) - with scrolling
    local tabFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    tabFrame:SetPoint("TOPLEFT", 12, -64)
    tabFrame:SetPoint("BOTTOMLEFT", 12, 36)
    tabFrame:SetWidth(155)
    CreateElementBackdrop(tabFrame)
    tabFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.5)
    
    -- =========================================================================
    -- SEARCH BAR
    -- =========================================================================
    local searchBar = nil
    local tabScrollStartY = -4
    if DF.Search then
        searchBar = DF.Search:CreateSearchBar(tabFrame)
        searchBar:SetPoint("TOPLEFT", 4, -4)
        searchBar:SetPoint("TOPRIGHT", -14, -4)
        tabScrollStartY = -36
    end
    
    local tabScroll = CreateFrame("ScrollFrame", nil, tabFrame, "ScrollFrameTemplate")
    tabScroll:SetPoint("TOPLEFT", 4, tabScrollStartY)
    tabScroll:SetPoint("BOTTOMRIGHT", -14, 4)
    
    StyleScrollBar(tabScroll)
    -- Custom positioning for tab scrollbar
    if tabScroll.ScrollBar then
        tabScroll.ScrollBar:ClearAllPoints()
        tabScroll.ScrollBar:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -4, tabScrollStartY)
        tabScroll.ScrollBar:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -4, 4)
    end
    
    local tabContainer = CreateFrame("Frame", nil, tabScroll)
    tabContainer:SetWidth(130)
    tabContainer:SetHeight(600) -- Will be updated dynamically
    tabScroll:SetScrollChild(tabContainer)
    GUI.tabContainer = tabContainer
    GUI.tabScroll = tabScroll
    
    -- Content area (right side) - no BackdropTemplate in CreateFrame
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", tabFrame, "TOPRIGHT", 8, 0)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 36)
    CreateElementBackdrop(content)
    content:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.3)
    GUI.contentFrame = content
    GUI.tabFrame = tabFrame
    
    -- =========================================================================
    -- CLICK CASTING PANEL (full width, replaces normal content when active)
    -- =========================================================================
    local clickCastPanel = CreateFrame("Frame", nil, frame)
    clickCastPanel:SetPoint("TOPLEFT", 12, -64)
    clickCastPanel:SetPoint("BOTTOMRIGHT", -12, 36)
    CreateElementBackdrop(clickCastPanel)
    clickCastPanel:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.3)
    clickCastPanel:Hide()
    GUI.clickCastPanel = clickCastPanel
    
    -- =========================================================================
    -- FOOTER BAR (Discord & Donation links + bottom drag handle)
    -- =========================================================================

    -- Bottom drag bar (mirrors titleBar for dragging from the bottom)
    local bottomBar = CreateFrame("Frame", nil, frame)
    bottomBar:SetHeight(30)
    bottomBar:SetPoint("BOTTOMLEFT", 0, 0)
    bottomBar:SetPoint("BOTTOMRIGHT", -16, 0)  -- Leave space for resize handle
    bottomBar:EnableMouse(true)
    bottomBar:RegisterForDrag("LeftButton")
    bottomBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    bottomBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local point, _, relPoint, x, y = frame:GetPoint()
        if DF.db and DF.db.party then
            DF.db.party.guiPoint = point
            DF.db.party.guiRelPoint = relPoint
            DF.db.party.guiX = x
            DF.db.party.guiY = y
        end
    end)

    local footer = CreateFrame("Frame", nil, bottomBar)
    footer:SetPoint("BOTTOMLEFT", 12, 8)
    footer:SetPoint("BOTTOMRIGHT", -12, 8)
    footer:SetHeight(22)
    
    -- URL copy popup helper
    local function ShowURLPopup(url, label)
        local popup = GUI.urlPopup
        if not popup then
            popup = CreateFrame("Frame", "DFURLPopup", UIParent, "BackdropTemplate")
            popup:SetSize(380, 80)
            popup:SetPoint("CENTER")
            popup:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            popup:SetBackdropColor(0.1, 0.1, 0.1, 0.98)
            popup:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
            popup:SetFrameStrata("FULLSCREEN_DIALOG")
            popup:SetFrameLevel(250)
            popup:EnableMouse(true)
            
            local popupTitle = popup:CreateFontString(nil, "OVERLAY", "DFFontNormal")
            popupTitle:SetPoint("TOP", 0, -10)
            popupTitle:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            popup.title = popupTitle
            
            local editBox = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
            editBox:SetPoint("TOPLEFT", 12, -30)
            editBox:SetPoint("TOPRIGHT", -12, -30)
            editBox:SetHeight(22)
            editBox:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            editBox:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            editBox:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
            editBox:SetFontObject(DFFontHighlightSmall)
            editBox:SetAutoFocus(true)
            editBox:SetScript("OnEscapePressed", function() popup:Hide() end)
            editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
            popup.editBox = editBox
            
            local hint = popup:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            hint:SetPoint("BOTTOM", 0, 8)
            hint:SetText(L["Press Ctrl+C to copy, then Escape to close"])
            hint:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
            
            GUI.urlPopup = popup
        end
        
        popup.title:SetText(label)
        popup.editBox:SetText(url)
        popup:Show()
        popup.editBox:SetFocus()
        popup.editBox:HighlightText()
    end
    GUI.ShowURLPopup = ShowURLPopup

    -- Create a footer link button
    local function CreateFooterLink(parent, text, color, url, popupLabel)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetHeight(22)
        
        local label = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        label:SetPoint("CENTER")
        label:SetText(text)
        label:SetTextColor(color.r, color.g, color.b)
        btn:SetWidth(label:GetStringWidth() + 10)
        btn.label = label
        
        btn:SetScript("OnEnter", function()
            label:SetTextColor(1, 1, 1)
        end)
        btn:SetScript("OnLeave", function()
            label:SetTextColor(color.r, color.g, color.b)
        end)
        btn:SetScript("OnClick", function()
            ShowURLPopup(url, popupLabel)
        end)
        
        return btn
    end
    
    -- Discord link
    local discordColor = { r = 0.45, g = 0.53, b = 0.85 }
    local discordBtn = CreateFooterLink(footer, "Need support? Join our Discord", discordColor, 
        "https://discord.gg/SDWtduCqnT", "Join the DandersFrames Discord")
    discordBtn:SetPoint("LEFT", footer, "LEFT", 2, 0)
    
    -- Separator
    local sep = footer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    sep:SetPoint("LEFT", discordBtn, "RIGHT", 8, 0)
    sep:SetText("|")
    sep:SetTextColor(C_BORDER.r, C_BORDER.g, C_BORDER.b)
    
    -- PayPal link
    local paypalColor = { r = 0.35, g = 0.65, b = 0.45 }
    local donateBtn = CreateFooterLink(footer, "Support with PayPal", paypalColor,
        "https://paypal.me/dandersframesaddon", "Support DandersFrames Development")
    donateBtn:SetPoint("LEFT", sep, "RIGHT", 8, 0)

    -- Separator 2
    local sep2 = footer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    sep2:SetPoint("LEFT", donateBtn, "RIGHT", 8, 0)
    sep2:SetText("|")
    sep2:SetTextColor(C_BORDER.r, C_BORDER.g, C_BORDER.b)

    -- Patreon link
    local patreonColor = { r = 0.90, g = 0.35, b = 0.30 }
    local patreonBtn = CreateFooterLink(footer, "Support with Patreon", patreonColor,
        "https://www.patreon.com/DandersFrames", "Support DandersFrames on Patreon")
    patreonBtn:SetPoint("LEFT", sep2, "RIGHT", 8, 0)

    -- Version on the right
    local versionText = footer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    versionText:SetPoint("RIGHT", footer, "RIGHT", -2, 0)
    versionText:SetText(versionStr .. channelTag)
    versionText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.5)
    
    -- Create the click casting UI content
    if DF.ClickCast then
        DF.ClickCast:CreateClickCastUI(clickCastPanel)
    end
    
    -- Store min width references for tab switching
    local normalMinWidth = minWidth  -- 520
    local clicksMinWidth = 760  -- Clicks tab needs more space
    
    -- Function to show normal Party/Raid content
    function GUI:ShowNormalContent()
        if clickCastPanel then clickCastPanel:Hide() end
        if tabFrame then tabFrame:Show() end
        if content then content:Show() end

        -- Restore normal minimum width
        frame:SetResizeBounds(normalMinWidth, minHeight, maxWidth, maxHeight)

        -- Update tab availability for current mode (greys out tabs for disabled modes)
        GUI:UpdateTabAvailability()
    end
    
    -- Function to show Click Casting content
    function GUI:ShowClickCastingContent()
        if tabFrame then tabFrame:Hide() end
        if content then content:Hide() end
        
        -- Set larger minimum width for clicks tab
        frame:SetResizeBounds(clicksMinWidth, minHeight, maxWidth, maxHeight)
        
        -- If current width is less than clicks min, expand it
        local currentWidth = frame:GetWidth()
        if currentWidth < clicksMinWidth then
            frame:SetWidth(clicksMinWidth)
        end
        
        if clickCastPanel then 
            clickCastPanel:Show()
            -- Refresh the spell grid
            if DF.ClickCast and DF.ClickCast.RefreshSpellGrid then
                DF.ClickCast:RefreshSpellGrid()
            end
        end
    end
    
    -- =========================================================================
    -- SEARCH RESULTS PANEL (inside content area)
    -- =========================================================================
    if DF.Search then
        DF.Search:CreateResultsPanel(content)
    end
    
    GUI.Tabs = {}
    GUI.Pages = {}
    
    local function SelectTab(name)
        -- Hide search results when navigating to a tab
        if DF.Search then
            DF.Search:HideResults()
        end

        -- Clear any "New" section-header badges on the tab we're leaving.
        -- The user has had their chance to see the badges; mark them seen
        -- persistently so they don't reappear on the next visit.
        local leavingTab = GUI.CurrentPageName
        if leavingTab and leavingTab ~= name and GUI.pendingSectionBadges[leavingTab] then
            for key, badge in pairs(GUI.pendingSectionBadges[leavingTab]) do
                if badge and badge.Hide then badge:Hide() end
                if DandersFramesDB_v2 then
                    DandersFramesDB_v2.seenSections = DandersFramesDB_v2.seenSections or {}
                    DandersFramesDB_v2.seenSections[key] = true
                end
            end
            GUI.pendingSectionBadges[leavingTab] = nil
        end

        for k, page in pairs(GUI.Pages) do page:Hide() end
        for k, btn in pairs(GUI.Tabs) do
            if btn.accent then btn.accent:Hide() end
            -- Check if tab is disabled (e.g., during Auto Profile editing)
            if btn.disabled then
                btn.Text:SetTextColor(0.4, 0.4, 0.4)
                btn.Text:SetAlpha(1)
            else
                btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                btn.Text:SetAlpha(1)
            end
            btn.isActive = false
            btn:SetBackdropColor(0, 0, 0, 0)  -- Reset background when deselected
        end
        
        -- Auto-expand parent category so the selected tab is visible
        local tab = GUI.Tabs[name]
        if tab and tab.categoryName then
            local cat = GUI.Categories[tab.categoryName]
            if cat and not cat.expanded then
                cat.expanded = true
                cat.arrow:SetText("-")
                -- Persist state
                if DF.db and DF.db.party then
                    if not DF.db.party.guiExpandedCategories then
                        DF.db.party.guiExpandedCategories = {}
                    end
                    DF.db.party.guiExpandedCategories[cat.name] = true
                end
                GUI:UpdateTabLayout()
            end
        end
        
        if GUI.Pages[name] then
            -- Set current tab for Search registration
            if DF.Search then
                local page = GUI.Pages[name]
                DF.Search:SetCurrentTab(page.tabName, page.tabLabel)
                DF.Search.CurrentSection = nil
            end
            
            GUI.Pages[name]:Show()
            GUI.Pages[name]:Refresh()
            if GUI.Pages[name].RefreshStates then GUI.Pages[name]:RefreshStates() end
            -- Reapply picker overlays if in picker mode
            if DF.settingsPickerMode and DF.ApplyPickerOverlaysToCurrentPage then
                C_Timer.After(0.05, function() DF:ApplyPickerOverlaysToCurrentPage() end)
            end
        end
        local nc = GetThemeColor()
        if GUI.Tabs[name] then
            if GUI.Tabs[name].accent then
                GUI.Tabs[name].accent:Show()
                GUI.Tabs[name].accent:SetColorTexture(nc.r, nc.g, nc.b, 1)
            end
            GUI.Tabs[name].Text:SetTextColor(nc.r, nc.g, nc.b)
            GUI.Tabs[name].isActive = true
            -- Mark "New" badge as seen
            if GUI.Tabs[name].newBadge and GUI.Tabs[name].newBadge:IsShown() then
                GUI.Tabs[name].newBadge:Hide()
                if DandersFramesDB_v2 then
                    DandersFramesDB_v2.seenTabs = DandersFramesDB_v2.seenTabs or {}
                    DandersFramesDB_v2.seenTabs[name] = true
                end
                -- Hide parent category badge if no remaining children have new badges
                local catName = GUI.Tabs[name].categoryName
                local cat = catName and GUI.Categories[catName]
                if cat and cat.newBadge and cat.newBadge:IsShown() then
                    local anyNew = false
                    for _, child in ipairs(cat.children) do
                        if child.newBadge and child.newBadge:IsShown() then
                            anyNew = true
                            break
                        end
                    end
                    if not anyNew then cat.newBadge:Hide() end
                end
            end
        end
        GUI.CurrentPageName = name
        UpdateThemeColors()
    end
    GUI.SelectTab = SelectTab
    
    GUI.RefreshCurrentPage = function()
        -- Don't refresh regular pages when in clicks mode (they use DF.db which doesn't have "clicks")
        if GUI.SelectedMode == "clicks" then
            return
        end
        if GUI.CurrentPageName and GUI.Pages[GUI.CurrentPageName] then
            GUI.Pages[GUI.CurrentPageName]:Refresh()
            if GUI.Pages[GUI.CurrentPageName].RefreshStates then
                GUI.Pages[GUI.CurrentPageName]:RefreshStates()
            end
            UpdateThemeColors()
        end
        -- Refresh override indicators
        RefreshAllOverrideIndicators()
    end
    
    -- Category system
    GUI.Categories = {}
    local categoryY = -8
    
    local function CreateCategory(name, label)
        local cat = CreateFrame("Button", nil, tabContainer, "BackdropTemplate")
        cat:SetPoint("TOPLEFT", 4, categoryY)
        cat:SetPoint("TOPRIGHT", -4, categoryY)
        cat:SetHeight(28)
        cat:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
        cat:SetBackdropColor(0, 0, 0, 0)
        cat.name = name
        cat.children = {}
        
        -- Restore saved state (default collapsed)
        local savedStates = DF.db and DF.db.party and DF.db.party.guiExpandedCategories
        cat.expanded = savedStates and savedStates[name] or false
        
        -- Expand/collapse indicator (simple minus/plus)
        cat.arrow = cat:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        cat.arrow:SetPoint("LEFT", 6, 0)
        cat.arrow:SetText(cat.expanded and "-" or "+")
        cat.arrow:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        
        cat.Text = cat:CreateFontString(nil, "OVERLAY", "DFFontNormal")
        cat.Text:SetPoint("LEFT", 20, 0)
        cat.Text:SetText(label)
        cat.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

        -- "New" badge for categories — shown when any child tab has a new badge
        local catNewBadge = cat:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        catNewBadge:SetPoint("RIGHT", cat, "RIGHT", -8, 0)
        catNewBadge:SetText(L["New"])
        catNewBadge:SetTextColor(1, 0.82, 0)
        catNewBadge:Hide()
        cat.newBadge = catNewBadge

        cat:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 0.3)
        end)
        cat:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0)
        end)
        cat:SetScript("OnClick", function(self)
            self.expanded = not self.expanded
            self.arrow:SetText(self.expanded and "-" or "+")
            -- Persist state
            if DF.db and DF.db.party then
                if not DF.db.party.guiExpandedCategories then
                    DF.db.party.guiExpandedCategories = {}
                end
                DF.db.party.guiExpandedCategories[self.name] = self.expanded or nil
            end
            GUI:UpdateTabLayout()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end)
        
        GUI.Categories[name] = cat
        -- Only add to CategoryOrder if not already in the explicit list (Options.lua sets it)
        local found = false
        for _, v in ipairs(GUI.CategoryOrder) do
            if v == name then found = true break end
        end
        if not found then
            tinsert(GUI.CategoryOrder, name)
        end
        categoryY = categoryY - 30
        return cat
    end
    
    local function CreateSubTab(categoryName, name, label)
        local cat = GUI.Categories[categoryName]
        if not cat then return end
        
        local btn = CreateFrame("Button", nil, tabContainer, "BackdropTemplate")
        btn:SetHeight(26)
        btn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
        btn:SetBackdropColor(0, 0, 0, 0)
        btn.isTab = true
        btn.tabName = name
        btn.categoryName = categoryName
        
        -- Left accent bar
        btn.accent = btn:CreateTexture(nil, "OVERLAY")
        btn.accent:SetPoint("TOPLEFT", 0, 0)
        btn.accent:SetPoint("BOTTOMLEFT", 0, 0)
        btn.accent:SetWidth(3)
        btn.accent:Hide()
        
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btn.Text:SetPoint("LEFT", 24, 0)
        btn.Text:SetText(label)
        btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

        -- "New" badge — shown for tabs in GUI.NewTabs until the user opens them
        local newBadge = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        newBadge:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
        newBadge:SetText(L["New"])
        newBadge:SetTextColor(1, 0.82, 0)
        newBadge:Hide()
        btn.newBadge = newBadge
        if GUI.NewTabs[name]
           and not (DandersFramesDB_v2 and DandersFramesDB_v2.seenTabs
                    and DandersFramesDB_v2.seenTabs[name]) then
            newBadge:Show()
            -- Also show "New" on the parent category
            if cat and cat.newBadge then
                cat.newBadge:Show()
            end
        end

        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 0.5)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self.isActive then
                self:SetBackdropColor(0, 0, 0, 0)
            end
        end)
        btn:SetScript("OnClick", function(self)
            if self.disabled then return end
            SelectTab(name)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end)
        
        -- Create the page
        local page = CreateFrame("ScrollFrame", nil, content, "ScrollFrameTemplate")
        page:SetPoint("TOPLEFT", 8, -8)
        page:SetPoint("BOTTOMRIGHT", -8, 8)
        
        StyleScrollBar(page)

        local child = CreateFrame("Frame", nil, page)
        child:SetSize(content:GetWidth() - 30, 1)
        page:SetScrollChild(child)
        page.child = child
        page.tabName = name
        page.tabLabel = label
        page:Hide()
        page.Refresh = function() end
        
        GUI.Tabs[name] = btn
        GUI.Pages[name] = page
        table.insert(cat.children, btn)
        
        return page
    end
    
    -- Update tab positions based on expanded/collapsed state
    function GUI:UpdateTabLayout()
        local y = -8
        
        for _, catName in ipairs(GUI.CategoryOrder) do
            local cat = GUI.Categories[catName]
            if cat then
                cat:ClearAllPoints()
                cat:SetPoint("TOPLEFT", 0, y)
                cat:SetPoint("TOPRIGHT", 0, y)
                y = y - 30
                
                if cat.expanded then
                    for _, btn in ipairs(cat.children) do
                        btn:Show()
                        btn:ClearAllPoints()
                        btn:SetPoint("TOPLEFT", 0, y)
                        btn:SetPoint("TOPRIGHT", 0, y)
                        y = y - 28
                    end
                else
                    for _, btn in ipairs(cat.children) do
                        btn:Hide()
                    end
                end
            end
        end
        
        -- Update scroll child height
        local totalHeight = math.abs(y) + 20
        GUI.tabContainer:SetHeight(totalHeight)
    end
    
    -- Store category order
    GUI.CategoryOrder = {}
    
    local function CreateTab(name, label)
        -- Legacy single tab support - create as category with one item
        local page = CreateSubTab("tools", name, label)
        return page
    end
    
    local function BuildPage(page, builderFunc)
        page.Refresh = function(self)
            local db = DF.db[GUI.SelectedMode]
            -- Guard against nil db (e.g., when "clicks" mode is selected)
            if not db then return end

            if self.children then
                for _, child in ipairs(self.children) do child:Hide() end
            end
            self.children = {}
            self.child.ThemeListeners = {}
            -- Propagate RefreshStates to child so widgets can call it
            self.child.RefreshStates = function() self:RefreshStates() end
            local parent = self.child

            local function Add(widget, height, col)
                table.insert(self.children, widget)
                widget:SetParent(parent)
                widget.layoutHeight = height or 55
                widget.layoutCol = col or 1
                return widget
            end

            -- Disabled-mode handling: when the current mode is off in General
            -- settings, replace the page content with a single banner instead
            -- of rendering any controls. Whitelisted pages (General, Profiles,
            -- Debug, Targeted List, Personal Targeted) always render normally.
            if GUI:IsTabDisabledForCurrentMode(self.tabName) then
                local banner = CreateFrame("Frame", nil, parent, "BackdropTemplate")
                banner:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8x8",
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                })
                banner:SetBackdropColor(0.4, 0.2, 0.05, 0.5)
                banner:SetBackdropBorderColor(1, 0.82, 0, 0.7)
                local msg = banner:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                msg:SetPoint("LEFT", 14, 0)
                msg:SetPoint("RIGHT", -14, 0)
                msg:SetJustifyH("LEFT")
                msg:SetWordWrap(true)
                msg:SetText(GUI.SelectedMode == "raid"
                    and (L["Raid frames are currently disabled. Changes here will apply after re-enabling Raid in the General tab and reloading."])
                    or  (L["Party frames are currently disabled. Changes here will apply after re-enabling Party in the General tab and reloading."]))
                table.insert(self.children, banner)
                banner:SetParent(parent)
                banner.layoutHeight = 60
                banner.layoutCol = "both"
                self:RefreshStates()
                return  -- skip builderFunc entirely
            end
            
            local function AddSpace(h, col)
                local spacer = CreateFrame("Frame", nil, parent)
                spacer:SetSize(1, h)
                spacer.layoutHeight = h
                spacer.layoutCol = col or "both"
                table.insert(self.children, spacer)
            end
            
            -- Sync point: forces both columns to align to the same Y position
            local function AddSyncPoint()
                local sync = CreateFrame("Frame", nil, parent)
                sync:SetSize(1, 1)
                sync.isSyncPoint = true
                sync.layoutHeight = 0
                sync.layoutCol = "both"
                table.insert(self.children, sync)
            end
            
            builderFunc(self, db, Add, AddSpace, AddSyncPoint)
            self:RefreshStates()
        end
        
        page.RefreshStates = function(self)
            if not self.children then return end
            local db = DF.db[GUI.SelectedMode]
            if not db then return end
            
            -- First pass: handle SettingsGroups - layout their children and calculate heights
            for _, widget in ipairs(self.children) do
                if widget.isSettingsGroup then
                    -- Layout children within the group (handles hideOn internally)
                    widget:LayoutChildren()
                    -- Process disableOn for group children
                    widget:RefreshChildStates()
                end
            end
            
            -- Second pass: handle regular widgets and group visibility
            for _, widget in ipairs(self.children) do
                -- Skip SettingsGroup children - they're handled by their parent group
                if widget.settingsGroup then
                    -- Already handled by group's LayoutChildren
                elseif widget.isSettingsGroup then
                    -- For groups, check collapsible section state AND group-level hideOn
                    local shouldHide = false
                    
                    -- Check if parent collapsible section is collapsed
                    if widget.collapsibleSection and not widget.collapsibleSection.expanded then
                        shouldHide = true
                    end
                    
                    -- Check group's own hideOn
                    if not shouldHide and widget.hideOn then
                        shouldHide = widget.hideOn(db)
                    end
                    
                    if shouldHide then
                        widget:Hide()
                    else
                        widget:Show()
                    end
                else
                    -- Regular widget processing
                    if widget.disableOn then
                        local shouldDisable = widget.disableOn(db)
                        if widget.SetEnabled then
                            widget:SetEnabled(not shouldDisable)
                        end
                    end
                    
                    -- Check if widget should be hidden
                    local shouldHide = false
                    
                    -- First check if parent collapsible section is collapsed
                    if widget.collapsibleSection and not widget.collapsibleSection.expanded then
                        shouldHide = true
                    end
                    
                    -- Then check widget's own hideOn
                    if not shouldHide and widget.hideOn then
                        shouldHide = widget.hideOn(db)
                    end
                    
                    if shouldHide then
                        widget:Hide()
                    else
                        widget:Show()
                        -- Call refreshContent hook for dynamic content updates
                        if widget.refreshContent then
                            widget:refreshContent(db)
                        end
                    end
                end
            end
            
            -- Determine column layout based on content area width
            local contentWidth = GUI.contentFrame and GUI.contentFrame:GetWidth() or 540
            local minColumnWidth = 270  -- Minimum width for each column
            local usesTwoColumns = contentWidth >= (minColumnWidth * 2 + 20)
            
            -- Account for scrollbar and padding when calculating usable width
            local usableWidth = contentWidth - 40  -- Extra padding for scrollbar
            
            -- Check if editing banner is active (adds 50px at top)
            local bannerOffset = 0
            if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                bannerOffset = 50
            end
            
            -- Layout - adjust column positions based on available width
            local x1, maxY = 5, 0
            local col2X = usesTwoColumns and math.floor(contentWidth / 2) or x1
            local y1, y2 = -5 - bannerOffset, -5 - bannerOffset
            
            -- First, position any right-aligned elements (like Copy buttons) at absolute top-right
            for _, widget in ipairs(self.children) do
                if widget.rightAlign and widget:IsShown() then
                    widget:ClearAllPoints()
                    widget:SetPoint("TOPRIGHT", self.child, "TOPRIGHT", -10, -5 - bannerOffset)
                end
            end
            
            -- Reserve space below right-aligned elements
            local hasRightAligned = false
            for _, widget in ipairs(self.children) do
                if widget.rightAlign then
                    hasRightAligned = true
                    break
                end
            end
            if hasRightAligned then
                -- Add padding below the copy button (button height ~26 + 14 padding)
                y1 = y1 - 40
                y2 = y2 - 40
            end
            
            for _, widget in ipairs(self.children) do
                -- Skip widgets that belong to a SettingsGroup (they're positioned by the group)
                if widget.settingsGroup then
                    -- Do nothing - parent group handles positioning
                elseif widget.rightAlign then
                    -- Already positioned above, skip
                elseif widget.isSyncPoint then
                    -- Sync point: align both columns to the lowest Y position
                    local syncY = math.min(y1, y2)
                    y1 = syncY
                    y2 = syncY
                elseif widget:IsShown() then
                    -- For SettingsGroups, use calculated height
                    local h = widget.layoutHeight or 0
                    if widget.isSettingsGroup and widget.calculatedHeight then
                        h = widget.calculatedHeight
                    end
                    
                    widget:ClearAllPoints()
                    
                    -- Set height for frame-based widgets (like header containers)
                    if widget.text and widget.SetHeight and h > 0 then
                        widget:SetHeight(h)
                    end
                    
                    -- Apply indent offset if specified (for child/sub-options)
                    -- Supports: true (20px), or a number for multiple levels (e.g. 2 = 40px)
                    local indentOffset = 0
                    if widget.indent then
                        if type(widget.indent) == "number" then
                            indentOffset = widget.indent * 20
                        else
                            indentOffset = 20
                        end
                    end
                    
                    if widget.layoutCol == "both" then
                        local startY = math.min(y1, y2)
                        widget:SetPoint("TOPLEFT", x1 + indentOffset, startY)
                        -- Set width to span both columns (with scrollbar padding)
                        widget:SetWidth(usableWidth - indentOffset)
                        y1 = startY - h
                        y2 = startY - h
                    elseif widget.layoutCol == 2 and usesTwoColumns then
                        widget:SetPoint("TOPLEFT", col2X + indentOffset, y2)
                        -- Reduce width for indented widgets to maintain alignment
                        if indentOffset > 0 and widget.SetWidth then
                            local defaultColWidth = math.floor((usableWidth - 20) / 2)
                            widget:SetWidth(defaultColWidth - indentOffset)
                        end
                        y2 = y2 - h
                    else
                        -- Column 1, or column 2 when in single-column mode
                        widget:SetPoint("TOPLEFT", x1 + indentOffset, y1)
                        -- Reduce width for indented widgets to maintain alignment
                        if indentOffset > 0 and widget.SetWidth then
                            local defaultColWidth = math.floor((usableWidth - 20) / 2)
                            widget:SetWidth(defaultColWidth - indentOffset)
                        end
                        y1 = y1 - h
                    end
                    
                    local currentBottom = math.min(y1, y2)
                    if math.abs(currentBottom) > maxY then maxY = math.abs(currentBottom) end
                end
            end
            self.child:SetHeight(maxY + 40 + bannerOffset)
            
            -- Update scroll child width to match content area
            if self.child and GUI.contentFrame then
                self.child:SetWidth(GUI.contentFrame:GetWidth() - 30)
            end
        end
    end
    
    -- Load pages from Options file
    if DF.SetupGUIPages then
        DF:SetupGUIPages(GUI, CreateCategory, CreateSubTab, BuildPage)
    end
    
    -- Setup Auto Profiles editing banner
    if DF.AutoProfilesUI and DF.AutoProfilesUI.SetupEditingBanner then
        DF.AutoProfilesUI:SetupEditingBanner()
    end
    
    -- Apply Aura Designer tab disabled state before first SelectTab
    if DF.ApplyAuraDesignerTabState then
        DF:ApplyAuraDesignerTabState()
    end

    -- Update tab layout after all tabs created
    GUI:UpdateTabLayout()

    UpdateThemeColors()

    -- Apply tab availability for current mode (greys out disabled-mode tabs)
    GUI:UpdateTabAvailability()

    -- Select first subtab
    if GUI.CategoryOrder[1] then
        local firstCat = GUI.Categories[GUI.CategoryOrder[1]]
        if firstCat and firstCat.children[1] then
            SelectTab(firstCat.children[1].tabName)
        end
    end
end
