local addonName, DF = ...

-- ============================================================
-- POPUP SYSTEM
-- Generic reusable popup framework for wizards and alerts.
-- Usage:
--   DF:ShowPopupWizard(config)  -- multi-step wizard with branching
--   DF:ShowPopupAlert(config)   -- simple message + buttons
-- See CLAUDE.md for full API reference.
-- ============================================================

local pairs, ipairs, type, tinsert, tremove, wipe = pairs, ipairs, type, table.insert, table.remove, table.wipe
local format = string.format
local L = DF.L
local floor, max, min = math.floor, math.max, math.min
local CreateFrame = CreateFrame
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local UIParent = UIParent
local BackdropTemplateMixin = BackdropTemplateMixin
local Mixin = Mixin

-- ============================================================
-- THEME COLORS (matching GUI/GUI.lua)
-- ============================================================

local C = {
    background = {r = 0.08, g = 0.08, b = 0.08, a = 0.97},
    panel      = {r = 0.12, g = 0.12, b = 0.12, a = 1},
    element    = {r = 0.18, g = 0.18, b = 0.18, a = 1},
    border     = {r = 0.25, g = 0.25, b = 0.25, a = 1},
    accent     = {r = 0.45, g = 0.45, b = 0.95, a = 1},
    hover      = {r = 0.22, g = 0.22, b = 0.22, a = 1},
    selected   = {r = 0.28, g = 0.28, b = 0.45, a = 1},
    text       = {r = 0.9,  g = 0.9,  b = 0.9,  a = 1},
    textDim    = {r = 0.6,  g = 0.6,  b = 0.6,  a = 1},
    green      = {r = 0.2,  g = 0.9,  b = 0.2},
    red        = {r = 0.9,  g = 0.25, b = 0.25},
}

-- ============================================================
-- BACKDROP HELPERS
-- ============================================================

local function ApplyBackdrop(frame, bgColor, borderColor, edgeSize)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = edgeSize or 1,
    })
    frame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 1)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
end

-- ============================================================
-- STYLED BUTTON HELPER
-- ============================================================

local function CreatePopupButton(parent, text, width, height)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 120, height or 28)
    ApplyBackdrop(btn, C.element, C.border)

    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    -- Anchor to both left and right edges (with a small inset) so SetWordWrap
    -- can flow long labels onto multiple lines within the button.
    btn.Text:SetPoint("LEFT", 6, 0)
    btn.Text:SetPoint("RIGHT", -6, 0)
    btn.Text:SetJustifyH("CENTER")
    btn.Text:SetJustifyV("MIDDLE")
    btn.Text:SetWordWrap(true)
    btn.Text:SetText(text)
    btn.Text:SetTextColor(C.text.r, C.text.g, C.text.b)

    btn:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(C.hover.r, C.hover.g, C.hover.b, 1)
            self:SetBackdropBorderColor(C.accent.r, C.accent.g, C.accent.b, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
            self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 1)
        end
    end)
    btn:SetScript("OnClick", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if self.onClick then self.onClick(self) end
    end)

    return btn
end

-- ============================================================
-- OPTION BUTTON HELPER (for wizard steps)
-- ============================================================

local function CreateOptionButton(parent, index)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetHeight(36)
    ApplyBackdrop(btn, C.element, C.border)

    -- Icon (optional, hidden by default)
    local icon = btn:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("LEFT", 10, 0)
    icon:SetSize(20, 20)
    icon:Hide()
    btn.Icon = icon

    -- Checkbox square (for multi-select, hidden by default)
    local check = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    check:SetSize(14, 14)
    check:SetPoint("LEFT", 10, 0)
    ApplyBackdrop(check, C.element, C.border)
    check:Hide()
    btn.CheckBox = check

    local checkMark = check:CreateTexture(nil, "OVERLAY")
    checkMark:SetPoint("CENTER")
    checkMark:SetSize(8, 8)
    checkMark:SetColorTexture(C.accent.r, C.accent.g, C.accent.b, 1)
    checkMark:Hide()
    btn.CheckMark = checkMark

    -- Label
    local label = btn:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    label:SetPoint("LEFT", 12, 0)
    label:SetPoint("RIGHT", -12, 0)
    label:SetJustifyH("LEFT")
    label:SetTextColor(C.text.r, C.text.g, C.text.b)
    btn.Label = label

    -- Hover effects
    btn:SetScript("OnEnter", function(self)
        if not self.isSelected then
            self:SetBackdropColor(C.hover.r, C.hover.g, C.hover.b, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.isSelected then
            self:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
        end
    end)

    btn.index = index
    return btn
end

local function SetOptionSelected(btn, selected)
    btn.isSelected = selected
    if selected then
        btn:SetBackdropColor(C.selected.r, C.selected.g, C.selected.b, 1)
        btn:SetBackdropBorderColor(C.accent.r, C.accent.g, C.accent.b, 1)
        if btn.CheckMark then btn.CheckMark:Show() end
    else
        btn:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
        btn:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 1)
        if btn.CheckMark then btn.CheckMark:Hide() end
    end
end

-- ============================================================
-- IMAGE CARD HELPER (for imageselect steps)
-- ============================================================

local MAX_IMAGE_CARDS = 4
local IMAGE_CARD_SIZE = 120
local IMAGE_CARD_SPACING = 10

local function CreateImageCard(parent, index)
    local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
    card:SetSize(IMAGE_CARD_SIZE, IMAGE_CARD_SIZE + 28)
    ApplyBackdrop(card, C.element, C.border)

    -- Image texture
    local img = card:CreateTexture(nil, "ARTWORK")
    img:SetPoint("TOPLEFT", 4, -4)
    img:SetPoint("TOPRIGHT", -4, -4)
    img:SetHeight(IMAGE_CARD_SIZE - 8)
    img:SetTexCoord(0, 1, 0, 1)
    card.Image = img

    -- Label below the image
    local label = card:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    label:SetPoint("BOTTOMLEFT", 4, 6)
    label:SetPoint("BOTTOMRIGHT", -4, 6)
    label:SetJustifyH("CENTER")
    label:SetTextColor(C.text.r, C.text.g, C.text.b)
    label:SetWordWrap(true)
    card.Label = label

    -- Selected check overlay (top-right corner)
    local checkBg = card:CreateTexture(nil, "OVERLAY", nil, 1)
    checkBg:SetPoint("TOPRIGHT", -2, -2)
    checkBg:SetSize(20, 20)
    checkBg:SetColorTexture(C.accent.r, C.accent.g, C.accent.b, 0.9)
    checkBg:Hide()
    card.CheckBg = checkBg

    local checkTex = card:CreateTexture(nil, "OVERLAY", nil, 2)
    checkTex:SetPoint("CENTER", checkBg, "CENTER")
    checkTex:SetSize(12, 12)
    checkTex:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\check")
    checkTex:SetVertexColor(1, 1, 1)
    checkTex:Hide()
    card.CheckTex = checkTex

    -- Hover effects
    card:SetScript("OnEnter", function(self)
        if not self.isSelected then
            self:SetBackdropColor(C.hover.r, C.hover.g, C.hover.b, 1)
            self:SetBackdropBorderColor(C.accent.r, C.accent.g, C.accent.b, 0.5)
        end
    end)
    card:SetScript("OnLeave", function(self)
        if not self.isSelected then
            self:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
            self:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 1)
        end
    end)

    card.index = index
    return card
end

local function SetImageCardSelected(card, selected)
    card.isSelected = selected
    if selected then
        card:SetBackdropColor(C.selected.r, C.selected.g, C.selected.b, 1)
        card:SetBackdropBorderColor(C.accent.r, C.accent.g, C.accent.b, 1)
        card.CheckBg:Show()
        card.CheckTex:Show()
    else
        card:SetBackdropColor(C.element.r, C.element.g, C.element.b, 1)
        card:SetBackdropBorderColor(C.border.r, C.border.g, C.border.b, 1)
        card.CheckBg:Hide()
        card.CheckTex:Hide()
    end
end

-- ============================================================
-- FRAME CONSTRUCTION (lazy, called once)
-- ============================================================

local PopupFrame = nil
local MAX_OPTIONS = 6
local FRAME_WIDTH = 440
local CONTENT_PADDING = 20
local OPTION_SPACING = 4

-- Wizard state
local wizardConfig = nil
local wizardAnswers = {}
local wizardHistory = {}
local wizardCurrentStepId = nil
local wizardStepLookup = {}
local wizardOptionButtons = {}
local wizardImageCards = {}
local wizardAutoAdvanceTimer = nil

-- Wizard stack (for sub-wizards)
local wizardStack = {}
local wizardTestModeActive = false

-- Settings highlight state
local highlightPool = {}
local activeHighlights = {}

-- Alert state
local alertConfig = nil
local alertButtons = {}

-- Mode tracking
local popupMode = nil  -- "wizard" or "alert"

local function CancelAutoAdvance()
    if wizardAutoAdvanceTimer then
        wizardAutoAdvanceTimer:Cancel()
        wizardAutoAdvanceTimer = nil
    end
end

-- ============================================================
-- WIZARD STACK (sub-wizard support)
-- ============================================================

local function ShallowCopyTable(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            -- One level deep copy for answer tables (multi-select values)
            local inner = {}
            for ik, iv in pairs(v) do inner[ik] = iv end
            copy[k] = inner
        else
            copy[k] = v
        end
    end
    return copy
end

local function CopyArray(t)
    local copy = {}
    for i, v in ipairs(t) do copy[i] = v end
    return copy
end

local function PushWizardState()
    local snapshot = {
        config = wizardConfig,
        answers = ShallowCopyTable(wizardAnswers),
        history = CopyArray(wizardHistory),
        currentStepId = wizardCurrentStepId,
        stepLookup = ShallowCopyTable(wizardStepLookup),
    }
    tinsert(wizardStack, snapshot)
end

-- Forward declaration (defined after RenderWizardStep etc.)
local PopWizardState

-- ============================================================
-- SETTINGS HIGHLIGHT SYSTEM
-- Highlights specific controls in the settings GUI with a
-- pulsing orange background that fades out after a few seconds.
-- ============================================================

local HIGHLIGHT_COLOR = {r = 1.0, g = 0.5, b = 0.1}  -- orange
local HIGHLIGHT_PULSES = 4      -- number of pulse cycles
local HIGHLIGHT_PULSE_DUR = 0.4 -- seconds per half-cycle

local function CreateHighlightOverlay()
    local overlay = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    ApplyBackdrop(overlay, HIGHLIGHT_COLOR, HIGHLIGHT_COLOR, 2)
    overlay:SetBackdropColor(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, 0.15)
    overlay:SetBackdropBorderColor(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, 0.8)

    -- Pulse animation: flash a few times then fade out
    local ag = overlay:CreateAnimationGroup()

    -- Pulse cycles (bright -> dim -> bright ...)
    for i = 1, HIGHLIGHT_PULSES do
        local fadeUp = ag:CreateAnimation("Alpha")
        fadeUp:SetFromAlpha(0.3)
        fadeUp:SetToAlpha(1)
        fadeUp:SetDuration(HIGHLIGHT_PULSE_DUR)
        fadeUp:SetOrder(i * 2 - 1)

        local fadeDown = ag:CreateAnimation("Alpha")
        fadeDown:SetFromAlpha(1)
        fadeDown:SetToAlpha(0.3)
        fadeDown:SetDuration(HIGHLIGHT_PULSE_DUR)
        fadeDown:SetOrder(i * 2)
    end

    -- Final fade out to invisible
    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.3)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.6)
    fadeOut:SetOrder(HIGHLIGHT_PULSES * 2 + 1)

    ag:SetScript("OnFinished", function()
        overlay:SetAlpha(0)
    end)

    overlay.pulseAnim = ag
    overlay:Hide()
    return overlay
end

local function GetHighlightOverlay()
    local overlay = tremove(highlightPool)
    if not overlay then
        overlay = CreateHighlightOverlay()
    end
    return overlay
end

function DF:ClearSettingHighlights()
    for _, overlay in ipairs(activeHighlights) do
        overlay.pulseAnim:Stop()
        overlay:SetAlpha(1)
        overlay:ClearAllPoints()
        overlay:SetParent(UIParent)
        overlay:Hide()
        tinsert(highlightPool, overlay)
    end
    wipe(activeHighlights)
end

function DF:HighlightSettings(tabName, dbKeys)
    DF:ClearSettingHighlights()

    if not tabName or not dbKeys or #dbKeys == 0 then return end
    if not DF.GUI or not DF.GUI.Pages then return end

    local page = DF.GUI.Pages[tabName]
    if not page or not page.children then
        DF:DebugWarn("HighlightSettings: page not found or has no children: " .. tostring(tabName))
        return
    end

    -- Build lookup set for fast matching
    local keySet = {}
    for _, key in ipairs(dbKeys) do
        keySet[key] = true
    end

    local firstWidget = nil
    local matchCount = 0

    -- Helper to apply highlight to a single widget
    local function ApplyHighlight(widget)
        matchCount = matchCount + 1
        local overlay = GetHighlightOverlay()
        overlay:SetParent(widget)
        overlay:SetFrameLevel(widget:GetFrameLevel() + 10)
        overlay:ClearAllPoints()
        overlay:SetPoint("TOPLEFT", widget, "TOPLEFT", -3, 3)
        overlay:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", 3, -3)
        overlay:SetAlpha(1)
        overlay:Show()
        overlay.pulseAnim:Play()
        tinsert(activeHighlights, overlay)

        if not firstWidget then
            firstWidget = widget
        end
    end

    -- Check a widget for matching dbKey
    local function CheckWidget(widget)
        local dbKey = widget.searchEntry and widget.searchEntry.dbKey
        if dbKey and keySet[dbKey] then
            ApplyHighlight(widget)
        end
    end

    -- Search page children and recurse into settings groups
    for _, widget in ipairs(page.children) do
        CheckWidget(widget)
        -- If this is a settings group, also check its children
        if widget.isSettingsGroup and widget.groupChildren then
            for _, entry in ipairs(widget.groupChildren) do
                if entry.widget then
                    CheckWidget(entry.widget)
                end
            end
        end
    end

    DF:Debug("HighlightSettings: matched " .. matchCount .. "/" .. #dbKeys .. " controls on tab " .. tabName)

    -- Scroll to first highlighted widget
    if firstWidget and page.SetVerticalScroll then
        local widgetTop = firstWidget:GetTop()
        local pageTop = page:GetTop()
        if widgetTop and pageTop then
            local offset = pageTop - widgetTop - 20
            if offset > 0 then
                local maxScroll = page.child:GetHeight() - page:GetHeight()
                page:SetVerticalScroll(min(offset, max(0, maxScroll)))
            end
        end
    end
end

-- ============================================================
-- SETTINGS PICKER MODE
-- Lets the wizard builder capture a setting from the real GUI
-- ============================================================

local pickerOverlays = {}
local pickerBanner = nil

local PICKER_COLOR = {r = 0.85, g = 0.55, b = 0.1}  -- Orange highlight for picker targets

local function CreatePickerOverlay(widget, tabName, dbKey, controlType, callback)
    local overlay = CreateFrame("Button", nil, widget)
    overlay:SetAllPoints()
    overlay:SetFrameLevel(widget:GetFrameLevel() + 20)
    overlay:EnableMouse(true)

    -- Semi-transparent orange on hover
    overlay.bg = overlay:CreateTexture(nil, "BACKGROUND")
    overlay.bg:SetAllPoints()
    overlay.bg:SetColorTexture(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0)

    overlay.border = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    overlay.border:SetPoint("TOPLEFT", -2, 2)
    overlay.border:SetPoint("BOTTOMRIGHT", 2, -2)
    if not overlay.border.SetBackdrop then Mixin(overlay.border, BackdropTemplateMixin) end
    overlay.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    overlay.border:SetBackdropBorderColor(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0)

    overlay:SetScript("OnEnter", function()
        overlay.bg:SetColorTexture(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0.15)
        overlay.border:SetBackdropBorderColor(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0.8)
        GameTooltip:SetOwner(overlay, "ANCHOR_CURSOR")
        GameTooltip:SetText(L["Click to select this setting"], 1, 1, 1)
        GameTooltip:AddLine(dbKey, PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b)
        GameTooltip:Show()
    end)
    overlay:SetScript("OnLeave", function()
        overlay.bg:SetColorTexture(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0)
        overlay.border:SetBackdropBorderColor(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0)
        GameTooltip:Hide()
    end)
    overlay:SetScript("OnClick", function()
        GameTooltip:Hide()
        callback(tabName, dbKey, controlType)
    end)

    overlay:Show()
    tinsert(pickerOverlays, overlay)
end

local function CreatePickerBanner()
    if pickerBanner then return pickerBanner end

    local banner = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    banner:SetHeight(36)
    banner:SetFrameStrata("DIALOG")
    banner:SetFrameLevel(300)
    if not banner.SetBackdrop then Mixin(banner, BackdropTemplateMixin) end
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(PICKER_COLOR.r, PICKER_COLOR.g, PICKER_COLOR.b, 0.9)
    banner:SetBackdropBorderColor(PICKER_COLOR.r * 0.7, PICKER_COLOR.g * 0.7, PICKER_COLOR.b * 0.7, 1)

    banner.text = banner:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    banner.text:SetPoint("LEFT", 16, 0)
    banner.text:SetText(L["Click a setting to link it to your wizard"])
    banner.text:SetTextColor(0, 0, 0)

    local cancelBtn = CreateFrame("Button", nil, banner, "BackdropTemplate")
    cancelBtn:SetSize(80, 24)
    cancelBtn:SetPoint("RIGHT", -8, 0)
    if not cancelBtn.SetBackdrop then Mixin(cancelBtn, BackdropTemplateMixin) end
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    cancelBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    cancelBtn.text = cancelBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    cancelBtn.text:SetPoint("CENTER")
    cancelBtn.text:SetText(L["Cancel"])
    cancelBtn:SetScript("OnClick", function()
        DF:CancelSettingsPickerMode()
    end)
    cancelBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 1)
    end)
    cancelBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 1)
    end)

    banner:Hide()
    pickerBanner = banner
    return banner
end

-- Clear all picker overlays and banner
function DF:ClearSettingsPicker()
    for _, overlay in ipairs(pickerOverlays) do
        overlay:Hide()
        overlay:SetParent(UIParent)
        overlay:ClearAllPoints()
    end
    wipe(pickerOverlays)

    if pickerBanner then
        pickerBanner:Hide()
    end
    DF.settingsPickerMode = false
    DF.settingsPickerCallback = nil
end

-- Enter picker mode: opens the settings GUI and overlays all controls
-- callback(tabName, dbKey, controlType) is called when a setting is clicked
function DF:EnterSettingsPickerMode(callback, startTab)
    DF:ClearSettingsPicker()

    DF.settingsPickerMode = true
    DF.settingsPickerCallback = callback

    -- Show settings GUI
    if DF.GUIFrame then
        DF.GUIFrame:Show()
    elseif DF.ToggleGUI then
        DF:ToggleGUI()
    end

    -- Navigate to start tab if specified
    if startTab and DF.GUI and DF.GUI.Tabs and DF.GUI.Tabs[startTab] then
        DF.GUI.Tabs[startTab]:Click()
    end

    -- Show picker banner anchored to the settings GUI
    local banner = CreatePickerBanner()
    if DF.GUIFrame then
        banner:ClearAllPoints()
        banner:SetPoint("BOTTOMLEFT", DF.GUIFrame, "TOPLEFT", 0, 2)
        banner:SetPoint("BOTTOMRIGHT", DF.GUIFrame, "TOPRIGHT", 0, 2)
    end
    banner:Show()

    -- Apply picker overlays to the current page
    DF:ApplyPickerOverlaysToCurrentPage()
end

-- Apply picker overlays to whichever settings page is currently visible
function DF:ApplyPickerOverlaysToCurrentPage()
    if not DF.settingsPickerMode then return end

    -- Clear old overlays
    for _, overlay in ipairs(pickerOverlays) do
        overlay:Hide()
        overlay:SetParent(UIParent)
        overlay:ClearAllPoints()
    end
    wipe(pickerOverlays)

    if not DF.GUI or not DF.GUI.Pages then return end

    -- Find the currently visible page
    local currentTabName = nil
    local currentPage = nil
    for tabName, page in pairs(DF.GUI.Pages) do
        if page:IsShown() then
            currentTabName = tabName
            currentPage = page
            break
        end
    end

    if not currentPage or not currentPage.children then return end

    local function OverlayWidget(widget)
        local entry = widget.searchEntry
        if not entry or not entry.dbKey then return end

        local controlType = entry.widgetType or "unknown"

        CreatePickerOverlay(widget, currentTabName, entry.dbKey, controlType, function(tab, key, ctype)
            local cb = DF.settingsPickerCallback
            DF:ClearSettingsPicker()
            if DF.GUIFrame then DF.GUIFrame:Hide() end
            if cb then cb(tab, key, ctype) end
        end)
    end

    -- Walk page children and settings groups
    for _, widget in ipairs(currentPage.children) do
        OverlayWidget(widget)
        if widget.isSettingsGroup and widget.groupChildren then
            for _, entry in ipairs(widget.groupChildren) do
                if entry.widget then
                    OverlayWidget(entry.widget)
                end
            end
        end
    end
end

-- Cancel picker mode (called by banner cancel button or escape)
function DF:CancelSettingsPickerMode()
    DF:ClearSettingsPicker()
    if DF.GUIFrame then DF.GUIFrame:Hide() end
    -- Re-show builder popup if it was hidden
    if PopupFrame and not PopupFrame:IsShown() and popupMode == "builder" then
        PopupFrame:Show()
    end
end

-- ============================================================
-- TEST MODE & GUI INTEGRATION HELPERS
-- ============================================================

-- Flash-pulse a frame container to draw attention to it
-- Matches the same timing as the settings highlight (4 pulses + fade out)
local containerFlash = nil

local function FlashContainer(container)
    if not container or not container:IsVisible() then return end

    -- Create or reuse a flash overlay
    if not containerFlash then
        containerFlash = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        ApplyBackdrop(containerFlash, HIGHLIGHT_COLOR, HIGHLIGHT_COLOR, 2)
        containerFlash:SetBackdropColor(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, 0.15)
        containerFlash:SetBackdropBorderColor(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, 0.8)
        containerFlash:SetFrameStrata("HIGH")

        local ag = containerFlash:CreateAnimationGroup()

        -- Same pulse cycle as settings highlights: 4 pulses at 0.4s each half
        for i = 1, HIGHLIGHT_PULSES do
            local fadeUp = ag:CreateAnimation("Alpha")
            fadeUp:SetFromAlpha(0.3)
            fadeUp:SetToAlpha(1)
            fadeUp:SetDuration(HIGHLIGHT_PULSE_DUR)
            fadeUp:SetOrder(i * 2 - 1)

            local fadeDown = ag:CreateAnimation("Alpha")
            fadeDown:SetFromAlpha(1)
            fadeDown:SetToAlpha(0.3)
            fadeDown:SetDuration(HIGHLIGHT_PULSE_DUR)
            fadeDown:SetOrder(i * 2)
        end

        -- Final fade out
        local fadeOut = ag:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.3)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.6)
        fadeOut:SetOrder(HIGHLIGHT_PULSES * 2 + 1)

        ag:SetScript("OnFinished", function()
            containerFlash:Hide()
        end)
        containerFlash.flashAnim = ag
        containerFlash:Hide()
    end

    containerFlash:SetParent(container)
    containerFlash:SetFrameLevel(container:GetFrameLevel() + 5)
    containerFlash:ClearAllPoints()
    containerFlash:SetPoint("TOPLEFT", container, "TOPLEFT", -4, 4)
    containerFlash:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 4, -4)
    containerFlash:SetAlpha(0)
    containerFlash:Show()
    containerFlash.flashAnim:Play()
end

-- Track whether the wizard opened the GUI (so we can close it when leaving GUI steps)
local wizardOpenedGUI = false

local function CleanupTestMode()
    if wizardTestModeActive then
        if DF.HideTestFrames then DF:HideTestFrames(true) end
        if DF.HideRaidTestFrames then DF:HideRaidTestFrames() end
        wizardTestModeActive = false
    end
end

local function CleanupGUI()
    if wizardOpenedGUI then
        if DF.GUIFrame and DF.GUIFrame:IsShown() then
            DF.GUIFrame:Hide()
        end
        wizardOpenedGUI = false
    end
end

local function ProcessStepIntegration(step)
    -- Clear previous highlights
    DF:ClearSettingHighlights()

    -- Close GUI if previous step had it open but this one doesn't
    if not step.openTab then
        CleanupGUI()
    end

    -- Test mode: clean up if this step doesn't use it (handles back navigation)
    if not step.testMode and not step.testModeOff then
        CleanupTestMode()
    elseif step.testModeOff then
        CleanupTestMode()
    end
    if step.testMode == "party" then
        if DF.ShowTestFrames then DF:ShowTestFrames(true) end
        wizardTestModeActive = true
        -- Flash the test party container to draw attention
        C_Timer.After(0.3, function()
            if DF.testPartyContainer then FlashContainer(DF.testPartyContainer) end
        end)
    elseif step.testMode == "raid" then
        if DF.ShowRaidTestFrames then DF:ShowRaidTestFrames() end
        wizardTestModeActive = true
        C_Timer.After(0.3, function()
            if DF.testRaidContainer then FlashContainer(DF.testRaidContainer) end
        end)
    end

    -- GUI tab navigation (use Click() to trigger full page rebuild)
    if step.openTab then
        if not DF.GUIFrame or not DF.GUIFrame:IsShown() then
            if DF.ToggleGUI then DF:ToggleGUI() end
            wizardOpenedGUI = true
        end
        if DF.GUI and DF.GUI.Tabs and DF.GUI.Tabs[step.openTab] then
            DF.GUI.Tabs[step.openTab]:Click()
        end
    end

    -- Settings highlighting (delayed to let tab render and page rebuild)
    if step.highlightSettings then
        local tabName = step.openTab
        local keys = step.highlightSettings
        C_Timer.After(0.3, function()
            DF:HighlightSettings(tabName, keys)
        end)
    end

    -- Sub-wizard launch
    if step.launchWizard then
        DF:ShowSubWizard(step.launchWizard)
        return true  -- signal: skip rendering this step
    end

    return false
end

local function GetStepById(id)
    return wizardStepLookup[id]
end

-- Evaluate conditional branches on a step
-- Returns the goto step ID if a branch condition matches, or nil
local function EvaluateBranches(step, answers)
    if not step.branches or not answers then return nil end
    for _, branch in ipairs(step.branches) do
        local cond = branch.condition
        if cond then
            -- Use cond.step to check a specific step's answer, or default to current step
            local answer = cond.step and answers[cond.step] or answers[step.id]
            -- equals: single-select answer matches exactly
            if cond.equals and answer == cond.equals then
                return branch["goto"]
            end
            -- contains: single-select answer is one of the listed values
            if cond.contains and type(cond.contains) == "table" then
                for _, v in ipairs(cond.contains) do
                    if answer == v then return branch["goto"] end
                end
            end
            -- includes: multi-select answer includes this value
            if cond.includes and type(answer) == "table" then
                for _, v in ipairs(answer) do
                    if v == cond.includes then return branch["goto"] end
                end
            end
        end
    end
    return nil
end

local function GetNextStepId(step, answer)
    -- Check conditional branches first (uses full answers table)
    local branchResult = EvaluateBranches(step, wizardAnswers)
    if branchResult then return branchResult end

    -- Fall back to standard next (function or string)
    if step.next == nil then return nil end
    if type(step.next) == "function" then
        return step.next(answer)
    elseif type(step.next) == "string" then
        return step.next
    end
    return nil
end

-- Helper: apply settingsMap (if present) then call onComplete
local function CompleteWizard()
    if wizardConfig.settingsMap then
        DF:ApplyWizardSettingsMap(wizardConfig.settingsMap, wizardAnswers)
    end
    if wizardConfig.onComplete then
        wizardConfig.onComplete(wizardAnswers)
    end
    -- Refresh the settings GUI if it's open so changes are visible
    if DF.GUI and DF.GUI.RefreshCurrentPage then
        DF.GUI.RefreshCurrentPage()
    end
end

-- Forward declarations
local RenderWizardStep, RenderSummary, UpdateNavButtons, UpdateProgressDots

local function CreatePopupFrame()
    if PopupFrame then return PopupFrame end

    local f = CreateFrame("Frame", "DFPopupFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_WIDTH, 300)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(250)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:Hide()
    ApplyBackdrop(f, C.background, {r = 0, g = 0, b = 0, a = 1}, 2)

    -- ============================================================
    -- TITLE BAR
    -- ============================================================

    local titleBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 2, -2)
    titleBar:SetPoint("TOPRIGHT", -2, -2)
    titleBar:SetHeight(32)
    if not titleBar.SetBackdrop then Mixin(titleBar, BackdropTemplateMixin) end
    titleBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    titleBar:SetBackdropColor(C.panel.r, C.panel.g, C.panel.b, 1)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    titleBar:EnableMouse(true)
    f.TitleBar = titleBar

    -- Accent stripe at very top
    local stripe = f:CreateTexture(nil, "OVERLAY")
    stripe:SetPoint("TOPLEFT", 2, -2)
    stripe:SetPoint("TOPRIGHT", -2, -2)
    stripe:SetHeight(2)
    stripe:SetColorTexture(C.accent.r, C.accent.g, C.accent.b, 1)
    f.AccentStripe = stripe

    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    titleText:SetPoint("CENTER")
    titleText:SetTextColor(C.text.r, C.text.g, C.text.b)
    f.TitleText = titleText

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -6, 0)

    local closeBg = closeBtn:CreateTexture(nil, "ARTWORK")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(0.8, 0.2, 0.2, 0.8)
    closeBtn.bg = closeBg

    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER")
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(1, 1, 1)

    closeBtn:SetScript("OnEnter", function(self) self.bg:SetColorTexture(1, 0.3, 0.3, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.8, 0.2, 0.2, 0.8) end)
    closeBtn:SetScript("OnClick", function()
        CancelAutoAdvance()
        DF:ClearSettingHighlights()
        local wasSubWizard = #wizardStack > 0
        if popupMode == "wizard" and wizardConfig and wizardConfig.onCancel then
            wizardConfig.onCancel()
        end
        -- If onCancel popped a sub-wizard (parent is now showing), don't hide
        if not wasSubWizard then
            CleanupTestMode()
            CleanupGUI()
            f:Hide()
        end
    end)

    -- ============================================================
    -- CONTENT AREA
    -- ============================================================

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", CONTENT_PADDING, -CONTENT_PADDING)
    content:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -CONTENT_PADDING, -CONTENT_PADDING)
    -- Bottom anchor added after buttonBar is created (see below)
    f.Content = content

    -- Question text (wizard mode)
    local questionText = content:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    questionText:SetPoint("TOPLEFT")
    questionText:SetPoint("TOPRIGHT")
    questionText:SetJustifyH("LEFT")
    questionText:SetTextColor(C.text.r, C.text.g, C.text.b)
    f.QuestionText = questionText

    -- Description text (wizard mode, optional)
    local descText = content:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    descText:SetPoint("TOPLEFT", questionText, "BOTTOMLEFT", 0, -6)
    descText:SetPoint("TOPRIGHT", questionText, "BOTTOMRIGHT", 0, -6)
    descText:SetJustifyH("LEFT")
    descText:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)
    f.DescText = descText

    -- Message text (alert mode)
    local messageText = content:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    messageText:SetPoint("TOPLEFT")
    messageText:SetPoint("TOPRIGHT")
    messageText:SetJustifyH("LEFT")
    messageText:SetSpacing(3)
    messageText:SetTextColor(C.text.r, C.text.g, C.text.b)
    f.MessageText = messageText

    -- Alert icon (alert mode, optional)
    local alertIcon = content:CreateTexture(nil, "OVERLAY")
    alertIcon:SetSize(32, 32)
    alertIcon:SetPoint("TOPLEFT")
    alertIcon:Hide()
    f.AlertIcon = alertIcon

    -- Option buttons container (height set dynamically in RenderWizardStep)
    local optionsContainer = CreateFrame("Frame", nil, content)
    optionsContainer:SetPoint("TOPLEFT", descText, "BOTTOMLEFT", 0, -12)
    optionsContainer:SetPoint("TOPRIGHT", descText, "BOTTOMRIGHT", 0, -12)
    optionsContainer:SetHeight(MAX_OPTIONS * (36 + OPTION_SPACING))
    f.OptionsContainer = optionsContainer

    -- Pre-create option buttons
    for i = 1, MAX_OPTIONS do
        local btn = CreateOptionButton(optionsContainer, i)
        btn:SetPoint("TOPLEFT", 0, -((i - 1) * (36 + OPTION_SPACING)))
        btn:SetPoint("TOPRIGHT", 0, -((i - 1) * (36 + OPTION_SPACING)))
        btn:Hide()
        wizardOptionButtons[i] = btn
    end

    -- Image cards container (for imageselect steps)
    local imageContainer = CreateFrame("Frame", nil, content)
    imageContainer:SetPoint("TOPLEFT", descText, "BOTTOMLEFT", 0, -12)
    imageContainer:SetPoint("TOPRIGHT", descText, "BOTTOMRIGHT", 0, -12)
    imageContainer:SetHeight(IMAGE_CARD_SIZE + 28)
    imageContainer:Hide()
    f.ImageContainer = imageContainer

    -- Pre-create image cards (positioned dynamically in RenderWizardStep)
    for i = 1, MAX_IMAGE_CARDS do
        local card = CreateImageCard(imageContainer, i)
        card:Hide()
        wizardImageCards[i] = card
    end

    -- Summary scroll frame (for summary step) — uses ScrollFrameTemplate with themed scrollbar
    local summaryScroll = CreateFrame("ScrollFrame", "DFPopupSummaryScroll", content, "ScrollFrameTemplate")
    summaryScroll:SetPoint("TOPLEFT", questionText, "BOTTOMLEFT", 0, -16)
    summaryScroll:SetPoint("TOPRIGHT", questionText, "BOTTOMRIGHT", -14, -16)
    summaryScroll:SetHeight(200)
    summaryScroll:Hide()
    f.SummaryScroll = summaryScroll

    DF.GUI.StyleScrollBar(summaryScroll)
    -- Custom positioning for popup scrollbar
    if summaryScroll.ScrollBar then
        summaryScroll.ScrollBar:ClearAllPoints()
        summaryScroll.ScrollBar:SetPoint("TOPRIGHT", summaryScroll, "TOPRIGHT", 12, 0)
        summaryScroll.ScrollBar:SetPoint("BOTTOMRIGHT", summaryScroll, "BOTTOMRIGHT", 12, 0)
    end

    local summaryChild = CreateFrame("Frame", nil, summaryScroll)
    summaryChild:SetSize(FRAME_WIDTH - CONTENT_PADDING * 2 - 30, 1)
    summaryScroll:SetScrollChild(summaryChild)
    f.SummaryChild = summaryChild

    -- ============================================================
    -- PROGRESS DOTS (wizard mode)
    -- ============================================================

    local dotsContainer = CreateFrame("Frame", nil, f)
    dotsContainer:SetHeight(12)
    dotsContainer:SetPoint("BOTTOM", f, "BOTTOM", 0, 44)
    f.DotsContainer = dotsContainer
    f.dots = {}

    -- ============================================================
    -- BUTTON BAR (bottom)
    -- ============================================================

    local buttonBar = CreateFrame("Frame", nil, f)
    buttonBar:SetPoint("BOTTOMLEFT", 2, 2)
    buttonBar:SetPoint("BOTTOMRIGHT", -2, 2)
    buttonBar:SetHeight(36)
    if not buttonBar.SetBackdrop then Mixin(buttonBar, BackdropTemplateMixin) end
    buttonBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    buttonBar:SetBackdropColor(C.panel.r, C.panel.g, C.panel.b, 1)
    f.ButtonBar = buttonBar

    -- Now anchor content bottom to button bar top (content needs height to render children)
    content:SetPoint("BOTTOMLEFT", buttonBar, "TOPLEFT", CONTENT_PADDING, CONTENT_PADDING)
    content:SetPoint("BOTTOMRIGHT", buttonBar, "TOPRIGHT", -CONTENT_PADDING, CONTENT_PADDING)

    -- Back button (wizard)
    local backBtn = CreatePopupButton(buttonBar, L["Back"], 80, 26)
    backBtn:SetPoint("LEFT", 8, 0)
    backBtn:Hide()
    f.BackButton = backBtn

    -- Next/Apply button (wizard)
    local nextBtn = CreatePopupButton(buttonBar, L["Next"], 80, 26)
    nextBtn:SetPoint("RIGHT", -8, 0)
    nextBtn:Hide()
    f.NextButton = nextBtn

    -- Alert buttons (dynamically created)
    f.alertButtonFrames = {}

    -- ============================================================
    -- ESCAPE KEY HANDLING
    -- ============================================================

    -- Add to special frames table so Escape closes it
    tinsert(UISpecialFrames, "DFPopupFrame")

    PopupFrame = f
    return f
end

-- ============================================================
-- PROGRESS DOTS
-- ============================================================

UpdateProgressDots = function()
    if popupMode ~= "wizard" or not wizardConfig then return end

    local f = PopupFrame
    -- Count total visited + remaining steps (estimate)
    local totalSteps = #wizardHistory + 1  -- history + current
    local currentStep = #wizardHistory + 1

    -- Check if current step is summary
    local step = GetStepById(wizardCurrentStepId)
    if step and step.type == "summary" then
        -- Keep total as-is, current is last
    end

    -- Clear old dots
    for _, dot in ipairs(f.dots) do
        dot:Hide()
    end

    local dotSize = 8
    local dotSpacing = 6
    local totalWidth = totalSteps * dotSize + (totalSteps - 1) * dotSpacing
    f.DotsContainer:SetWidth(totalWidth)
    f.DotsContainer:SetPoint("BOTTOM", f, "BOTTOM", 0, 44)

    for i = 1, totalSteps do
        local dot = f.dots[i]
        if not dot then
            dot = f.DotsContainer:CreateTexture(nil, "OVERLAY")
            dot:SetSize(dotSize, dotSize)
            f.dots[i] = dot
        end

        local xOff = (i - 1) * (dotSize + dotSpacing) - totalWidth / 2 + dotSize / 2
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", f.DotsContainer, "CENTER", xOff, 0)

        if i == currentStep then
            dot:SetColorTexture(C.accent.r, C.accent.g, C.accent.b, 1)
        else
            dot:SetColorTexture(C.border.r, C.border.g, C.border.b, 1)
        end
        dot:Show()
    end

    f.DotsContainer:Show()
end

-- ============================================================
-- RENDER WIZARD STEP
-- ============================================================

RenderWizardStep = function()
    local f = PopupFrame
    local step = GetStepById(wizardCurrentStepId)
    if not step then
        DF:DebugError("Popup: step not found: " .. tostring(wizardCurrentStepId))
        return
    end

    -- Process step-level integration (test mode, GUI, highlights, sub-wizard)
    local launched = ProcessStepIntegration(step)
    if launched then return end  -- sub-wizard was launched, skip rendering

    -- Handle summary step
    if step.type == "summary" then
        RenderSummary()
        return
    end

    -- Hide alert elements
    f.MessageText:Hide()
    f.AlertIcon:Hide()
    f.SummaryScroll:Hide()
    f.SummaryChild:Hide()

    -- Show wizard elements
    f.QuestionText:Show()
    f.QuestionText:SetText(step.question or "")

    if step.description and step.description ~= "" then
        f.DescText:Show()
        f.DescText:SetText(step.description)
    else
        f.DescText:Hide()
        f.DescText:SetText("")
    end

    local anchor = f.DescText:IsShown() and f.DescText or f.QuestionText
    local existingAnswer = wizardAnswers[step.id]
    local numOptions = step.options and #step.options or 0
    local isImageSelect = (step.type == "imageselect")

    if isImageSelect then
        -- ============================================================
        -- IMAGE SELECT MODE
        -- ============================================================

        -- Hide regular options, show image container
        f.OptionsContainer:Hide()
        for i = 1, MAX_OPTIONS do wizardOptionButtons[i]:Hide() end

        f.ImageContainer:ClearAllPoints()
        f.ImageContainer:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
        f.ImageContainer:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -12)

        -- Calculate card size based on available width and number of options
        local frameWidth = PopupFrame:GetWidth() or FRAME_WIDTH
        local availWidth = frameWidth - CONTENT_PADDING * 2
        local numCards = min(numOptions, MAX_IMAGE_CARDS)
        local cardWidth = floor((availWidth - (numCards - 1) * IMAGE_CARD_SPACING) / numCards)
        cardWidth = min(cardWidth, IMAGE_CARD_SIZE + 40)  -- cap max size
        -- Allow steps to specify an image aspect ratio (width/height, e.g. 1.8 for wide images)
        local imageAspect = step.imageAspect
        local cardImageHeight = imageAspect and floor((cardWidth - 8) / imageAspect) or (cardWidth - 8)
        local cardHeight = cardImageHeight + 8 + 24
        f.ImageContainer:SetHeight(cardHeight)
        f.ImageContainer:Show()

        -- Calculate centering offset
        local totalCardsWidth = numCards * cardWidth + (numCards - 1) * IMAGE_CARD_SPACING
        local startX = floor((availWidth - totalCardsWidth) / 2)

        for i = 1, MAX_IMAGE_CARDS do
            local card = wizardImageCards[i]
            if i <= numCards then
                local opt = step.options[i]
                card:SetSize(cardWidth, cardHeight)
                card.Image:SetHeight(cardImageHeight)

                -- Set image
                if opt.image then
                    card.Image:SetTexture(opt.image)
                    card.Image:Show()
                elseif opt.icon then
                    card.Image:SetTexture(opt.icon)
                    card.Image:Show()
                else
                    card.Image:Hide()
                end

                -- Set texcoord if provided
                if opt.texCoord then
                    card.Image:SetTexCoord(unpack(opt.texCoord))
                else
                    card.Image:SetTexCoord(0, 1, 0, 1)
                end

                card.Label:SetText(opt.label or "")
                card.optionValue = opt.value
                card.stepId = step.id

                -- Check if previously selected
                local isSelected = existingAnswer and (existingAnswer == opt.value)
                SetImageCardSelected(card, isSelected)

                -- Click handler (always single-select for images)
                card:SetScript("OnClick", function(self)
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                    for j = 1, numCards do
                        SetImageCardSelected(wizardImageCards[j], j == self.index)
                    end
                    wizardAnswers[step.id] = self.optionValue

                    -- Auto-advance after short delay
                    CancelAutoAdvance()
                    wizardAutoAdvanceTimer = C_Timer.NewTimer(0.2, function()
                        wizardAutoAdvanceTimer = nil
                        local nextId = GetNextStepId(step, wizardAnswers[step.id])
                        if nextId == nil and step.next == nil then
                            for idx, s in ipairs(wizardConfig.steps) do
                                if s.id == step.id and wizardConfig.steps[idx + 1] then
                                    nextId = wizardConfig.steps[idx + 1].id
                                    break
                                end
                            end
                        end
                        if nextId then
                            tinsert(wizardHistory, wizardCurrentStepId)
                            wizardCurrentStepId = nextId
                            RenderWizardStep()
                            UpdateNavButtons()
                            UpdateProgressDots()
                        else
                            -- No next step: finish the wizard
                            local wasTopLevel = (#wizardStack == 0)
                            CompleteWizard()
                            -- Only hide if this was a top-level wizard (not a sub-wizard returning to parent)
                            if wasTopLevel then
                                PopupFrame:Hide()
                            end
                        end
                    end)
                end)

                -- Position
                card:ClearAllPoints()
                local xPos = startX + (i - 1) * (cardWidth + IMAGE_CARD_SPACING)
                card:SetPoint("TOPLEFT", f.ImageContainer, "TOPLEFT", xPos, 0)
                card:Show()
            else
                card:Hide()
            end
        end

        -- Resize frame
        local questionHeight = f.QuestionText:GetStringHeight() or 18
        local descHeight = f.DescText:IsShown() and (f.DescText:GetStringHeight() + 6) or 0
        local contentHeight = questionHeight + descHeight + 12 + cardHeight
        local totalHeight = 34 + CONTENT_PADDING + contentHeight + CONTENT_PADDING + 20 + 38
        totalHeight = max(totalHeight, 250)
        totalHeight = min(totalHeight, 650)
        f:SetHeight(totalHeight)

    else
        -- ============================================================
        -- REGULAR OPTIONS MODE (single / multi)
        -- ============================================================

        -- Hide image cards, show options
        f.ImageContainer:Hide()
        for i = 1, MAX_IMAGE_CARDS do wizardImageCards[i]:Hide() end

        f.OptionsContainer:ClearAllPoints()
        f.OptionsContainer:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
        f.OptionsContainer:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -12)
        f.OptionsContainer:Show()

        local isMulti = (step.type == "multi")

        for i = 1, MAX_OPTIONS do
            local btn = wizardOptionButtons[i]
            if i <= numOptions then
                local opt = step.options[i]
                btn:Show()

                -- Configure icon
                if opt.icon then
                    btn.Icon:SetTexture(opt.icon)
                    btn.Icon:Show()
                    btn.CheckBox:Hide()
                    btn.Label:ClearAllPoints()
                    btn.Label:SetPoint("LEFT", btn.Icon, "RIGHT", 8, 0)
                    btn.Label:SetPoint("RIGHT", -12, 0)
                elseif isMulti then
                    btn.Icon:Hide()
                    btn.CheckBox:Show()
                    btn.Label:ClearAllPoints()
                    btn.Label:SetPoint("LEFT", btn.CheckBox, "RIGHT", 8, 0)
                    btn.Label:SetPoint("RIGHT", -12, 0)
                else
                    btn.Icon:Hide()
                    btn.CheckBox:Hide()
                    btn.Label:ClearAllPoints()
                    btn.Label:SetPoint("LEFT", 12, 0)
                    btn.Label:SetPoint("RIGHT", -12, 0)
                end

                btn.Label:SetText(opt.label or "")
                btn.optionValue = opt.value
                btn.stepId = step.id
                btn.isMultiSelect = isMulti

                -- Check if previously selected
                local isSelected = false
                if existingAnswer then
                    if isMulti then
                        for _, v in ipairs(existingAnswer) do
                            if v == opt.value then isSelected = true; break end
                        end
                    else
                        isSelected = (existingAnswer == opt.value)
                    end
                end
                SetOptionSelected(btn, isSelected)

                -- Click handler
                btn:SetScript("OnClick", function(self)
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

                    if self.isMultiSelect then
                        self.isSelected = not self.isSelected
                        SetOptionSelected(self, self.isSelected)

                        local selected = {}
                        for j = 1, numOptions do
                            if wizardOptionButtons[j].isSelected then
                                tinsert(selected, wizardOptionButtons[j].optionValue)
                            end
                        end
                        wizardAnswers[step.id] = selected
                    else
                        for j = 1, numOptions do
                            SetOptionSelected(wizardOptionButtons[j], j == self.index)
                        end
                        wizardAnswers[step.id] = self.optionValue

                        CancelAutoAdvance()
                        wizardAutoAdvanceTimer = C_Timer.NewTimer(0.15, function()
                            wizardAutoAdvanceTimer = nil
                            local nextId = GetNextStepId(step, wizardAnswers[step.id])
                            if nextId == nil and step.next == nil then
                                for idx, s in ipairs(wizardConfig.steps) do
                                    if s.id == step.id and wizardConfig.steps[idx + 1] then
                                        nextId = wizardConfig.steps[idx + 1].id
                                        break
                                    end
                                end
                            end
                            if nextId then
                                tinsert(wizardHistory, wizardCurrentStepId)
                                wizardCurrentStepId = nextId
                                RenderWizardStep()
                                UpdateNavButtons()
                                UpdateProgressDots()
                            else
                                -- No next step: finish the wizard
                                local wasTopLevel = (#wizardStack == 0)
                                CompleteWizard()
                                if wasTopLevel then
                                    PopupFrame:Hide()
                                end
                            end
                        end)
                    end
                end)

                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", f.OptionsContainer, "TOPLEFT", 0, -((i - 1) * (36 + OPTION_SPACING)))
                btn:SetPoint("TOPRIGHT", f.OptionsContainer, "TOPRIGHT", 0, -((i - 1) * (36 + OPTION_SPACING)))
            else
                btn:Hide()
            end
        end

        -- Resize frame
        local optionsHeight = numOptions * (36 + OPTION_SPACING) - OPTION_SPACING
        local questionHeight = f.QuestionText:GetStringHeight() or 18
        local descHeight = f.DescText:IsShown() and (f.DescText:GetStringHeight() + 6) or 0
        local contentHeight = questionHeight + descHeight + 12 + optionsHeight
        local totalHeight = 34 + CONTENT_PADDING + contentHeight + CONTENT_PADDING + 20 + 38
        totalHeight = max(totalHeight, 200)
        totalHeight = min(totalHeight, 600)
        f:SetHeight(totalHeight)

        f.OptionsContainer:SetHeight(optionsHeight)
    end

    UpdateNavButtons()
    UpdateProgressDots()
end

-- ============================================================
-- RENDER SUMMARY
-- ============================================================

RenderSummary = function()
    local f = PopupFrame

    -- Hide wizard option elements
    f.DescText:Hide()
    f.OptionsContainer:Hide()
    f.ImageContainer:Hide()
    f.AlertIcon:Hide()
    f.MessageText:Hide()
    for i = 1, MAX_OPTIONS do
        wizardOptionButtons[i]:Hide()
    end
    for i = 1, MAX_IMAGE_CARDS do
        wizardImageCards[i]:Hide()
    end

    -- Show summary header
    f.QuestionText:Show()
    f.QuestionText:SetText(L["Here's what we'll set up:"])

    -- Build summary content
    f.SummaryScroll:Show()
    f.SummaryChild:Show()

    -- Clear previous summary rows
    if f.summaryRows then
        for _, row in ipairs(f.summaryRows) do
            row:Hide()
        end
    end
    f.summaryRows = f.summaryRows or {}

    local ROW_HEIGHT = 40
    local ROW_SPACING = 6
    local yOffset = 0
    local rowIndex = 0

    -- Walk through history to show only visited steps (in order)
    local visitedIds = {}
    for _, id in ipairs(wizardHistory) do
        tinsert(visitedIds, id)
    end

    local childWidth = f.SummaryChild:GetWidth() or (FRAME_WIDTH - CONTENT_PADDING * 2 - 14)

    for _, stepId in ipairs(visitedIds) do
        local step = GetStepById(stepId)
        if step and step.type ~= "summary" and not step.launchWizard then
            rowIndex = rowIndex + 1

            local row = f.summaryRows[rowIndex]
            if not row then
                row = CreateFrame("Frame", nil, f.SummaryChild, "BackdropTemplate")
                ApplyBackdrop(row, C.panel, C.border)
                f.summaryRows[rowIndex] = row

                -- Label at top of row (question text)
                row.Label = row:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                row.Label:SetPoint("TOPLEFT", 12, -8)
                row.Label:SetPoint("TOPRIGHT", -12, -8)
                row.Label:SetJustifyH("LEFT")
                row.Label:SetTextColor(C.textDim.r, C.textDim.g, C.textDim.b)

                -- Value below label (answer text)
                row.Value = row:CreateFontString(nil, "OVERLAY", "DFFontNormal")
                row.Value:SetPoint("TOPLEFT", row.Label, "BOTTOMLEFT", 0, -2)
                row.Value:SetPoint("TOPRIGHT", row.Label, "BOTTOMRIGHT", 0, -2)
                row.Value:SetJustifyH("LEFT")
                row.Value:SetTextColor(C.text.r, C.text.g, C.text.b)
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", f.SummaryChild, "TOPLEFT", 0, yOffset)
            row:SetPoint("TOPRIGHT", f.SummaryChild, "TOPRIGHT", 0, yOffset)

            -- Full question as label (no truncation needed since it wraps)
            row.Label:SetText(step.question or step.id)

            -- Format answer
            local answer = wizardAnswers[step.id]
            local answerText = ""
            if type(answer) == "table" then
                local labels = {}
                for _, val in ipairs(answer) do
                    for _, opt in ipairs(step.options or {}) do
                        if opt.value == val then
                            tinsert(labels, opt.label)
                            break
                        end
                    end
                end
                answerText = table.concat(labels, ", ")
            elseif answer then
                for _, opt in ipairs(step.options or {}) do
                    if opt.value == answer then
                        answerText = opt.label
                        break
                    end
                end
                if answerText == "" then answerText = tostring(answer) end
            else
                answerText = L["(skipped)"]
            end
            row.Value:SetText(answerText)

            -- Calculate row height based on text content
            -- Explicitly set word-wrap width so GetStringHeight accounts for wrapping
            local rowWidth = (f.SummaryChild:GetWidth() or (FRAME_WIDTH - CONTENT_PADDING * 2 - 30)) - 24  -- 12px padding each side
            row.Label:SetWidth(rowWidth)
            row.Value:SetWidth(rowWidth)
            local labelHeight = row.Label:GetStringHeight() or 12
            local valueHeight = row.Value:GetStringHeight() or 14
            local rowHeight = max(ROW_HEIGHT, 8 + labelHeight + 2 + valueHeight + 8)
            row:SetHeight(rowHeight)

            row:Show()
            yOffset = yOffset - (rowHeight + ROW_SPACING)
        end
    end

    -- Size the summary child and scroll area
    local totalContentHeight = max(1, -yOffset - ROW_SPACING)
    f.SummaryChild:SetHeight(totalContentHeight)

    -- Scroll height: fit content up to a max, then scroll
    local maxScrollHeight = 240
    local scrollHeight = min(totalContentHeight, maxScrollHeight)
    f.SummaryScroll:SetHeight(scrollHeight)

    -- Resize frame to fit
    local questionHeight = f.QuestionText:GetStringHeight() or 18
    local contentHeight = questionHeight + 16 + scrollHeight
    local totalHeight = 34 + CONTENT_PADDING + contentHeight + CONTENT_PADDING + 20 + 38
    totalHeight = max(totalHeight, 220)
    totalHeight = min(totalHeight, 650)
    f:SetHeight(totalHeight)

    f.SummaryScroll:ClearAllPoints()
    f.SummaryScroll:SetPoint("TOPLEFT", f.QuestionText, "BOTTOMLEFT", 0, -12)
    f.SummaryScroll:SetPoint("TOPRIGHT", f.QuestionText, "BOTTOMRIGHT", -20, -12)

    UpdateNavButtons()
    UpdateProgressDots()
end

-- ============================================================
-- NAVIGATION BUTTONS
-- ============================================================

UpdateNavButtons = function()
    local f = PopupFrame

    if popupMode == "wizard" then
        -- Hide alert buttons
        for _, btn in ipairs(f.alertButtonFrames) do
            btn:Hide()
        end

        -- Back button: show if we have history
        if #wizardHistory > 0 then
            f.BackButton:Show()
            f.BackButton.onClick = function()
                CancelAutoAdvance()
                -- Pop history and go back
                wizardCurrentStepId = tremove(wizardHistory)
                RenderWizardStep()
            end
        else
            f.BackButton:Hide()
        end

        -- Next/Apply button
        local step = GetStepById(wizardCurrentStepId)
        if step then
            if step.type == "summary" then
                f.NextButton:Show()
                f.NextButton.Text:SetText(L["Apply"])
                f.NextButton.onClick = function()
                    CancelAutoAdvance()
                    CompleteWizard()
                    f:Hide()
                end
            elseif step.type == "multi" then
                -- Multi-select needs a Next button (no auto-advance)
                f.NextButton:Show()

                local nextId = GetNextStepId(step, wizardAnswers[step.id])
                if nextId == nil and step.next == nil then
                    for idx, s in ipairs(wizardConfig.steps) do
                        if s.id == step.id and wizardConfig.steps[idx + 1] then
                            nextId = wizardConfig.steps[idx + 1].id
                            break
                        end
                    end
                end

                if nextId then
                    f.NextButton.Text:SetText(L["Next"])
                else
                    f.NextButton.Text:SetText(L["Finish"])
                end

                f.NextButton.onClick = function()
                    CancelAutoAdvance()
                    local answer = wizardAnswers[step.id]
                    local nId = GetNextStepId(step, answer)
                    if nId == nil and step.next == nil then
                        for idx, s in ipairs(wizardConfig.steps) do
                            if s.id == step.id and wizardConfig.steps[idx + 1] then
                                nId = wizardConfig.steps[idx + 1].id
                                break
                            end
                        end
                    end

                    if nId then
                        tinsert(wizardHistory, wizardCurrentStepId)
                        wizardCurrentStepId = nId
                        RenderWizardStep()
                    else
                        -- No next step, treat as finish
                        local wasTopLevel = (#wizardStack == 0)
                        CompleteWizard()
                        if wasTopLevel then
                            f:Hide()
                        end
                    end
                end
            else
                -- Single select: auto-advance handles it, but show Next for keyboard users
                f.NextButton:Show()
                f.NextButton.Text:SetText(L["Next"])
                f.NextButton.onClick = function()
                    CancelAutoAdvance()
                    local answer = wizardAnswers[step.id]
                    if not answer then return end  -- must select something

                    local nextId = GetNextStepId(step, answer)
                    if nextId == nil and step.next == nil then
                        for idx, s in ipairs(wizardConfig.steps) do
                            if s.id == step.id and wizardConfig.steps[idx + 1] then
                                nextId = wizardConfig.steps[idx + 1].id
                                break
                            end
                        end
                    end

                    if nextId then
                        tinsert(wizardHistory, wizardCurrentStepId)
                        wizardCurrentStepId = nextId
                        RenderWizardStep()
                    end
                end
            end
        end
    elseif popupMode == "alert" then
        -- Hide wizard nav
        f.BackButton:Hide()
        f.NextButton:Hide()
        f.DotsContainer:Hide()
    end
end

-- ============================================================
-- CONFIGURE FOR WIZARD
-- ============================================================

local function ConfigureForWizard(config)
    local f = CreatePopupFrame()

    -- Reset state
    CancelAutoAdvance()
    DF:ClearSettingHighlights()
    -- Only cleanup test mode/GUI if this is a top-level wizard (not a sub-wizard push)
    if #wizardStack == 0 then
        CleanupTestMode()
        CleanupGUI()
    end
    wipe(wizardAnswers)
    wipe(wizardHistory)
    wipe(wizardStepLookup)
    popupMode = "wizard"
    wizardConfig = config

    -- Build step lookup
    for _, step in ipairs(config.steps) do
        wizardStepLookup[step.id] = step
    end

    -- Set title (prefix with addon name so users know the source)
    local displayTitle = config.title or "Setup"
    if not config.noPrefix then
        displayTitle = "DandersFrames: " .. displayTitle
    end
    f.TitleText:SetText(displayTitle)

    -- Set frame width
    local width = config.width or FRAME_WIDTH
    f:SetWidth(width)

    -- Show wizard elements, hide alert elements
    f.QuestionText:Show()
    f.MessageText:Hide()
    f.AlertIcon:Hide()
    for _, btn in ipairs(f.alertButtonFrames) do
        btn:Hide()
    end

    -- Start at first step
    wizardCurrentStepId = config.steps[1].id
    RenderWizardStep()

    f:ClearAllPoints()
    f:SetPoint("CENTER")
    f:Show()
end

-- ============================================================
-- CONFIGURE FOR ALERT
-- ============================================================

local function ConfigureForAlert(config)
    local f = CreatePopupFrame()

    -- Reset state
    CancelAutoAdvance()
    DF:ClearSettingHighlights()
    CleanupTestMode()
    CleanupGUI()
    wipe(wizardStack)
    popupMode = "alert"
    alertConfig = config

    -- Set title
    f.TitleText:SetText(config.title or L["Notice"])

    -- Set frame width
    local width = config.width or FRAME_WIDTH
    f:SetWidth(width)

    -- Hide wizard elements
    f.QuestionText:Hide()
    f.DescText:Hide()
    f.OptionsContainer:Hide()
    f.ImageContainer:Hide()
    f.SummaryScroll:Hide()
    f.SummaryChild:Hide()
    f.DotsContainer:Hide()
    f.BackButton:Hide()
    f.NextButton:Hide()
    for i = 1, MAX_OPTIONS do
        wizardOptionButtons[i]:Hide()
    end
    for i = 1, MAX_IMAGE_CARDS do
        wizardImageCards[i]:Hide()
    end

    -- Alert icon (optional)
    f.MessageText:ClearAllPoints()
    if config.icon then
        f.AlertIcon:SetTexture(config.icon)
        f.AlertIcon:Show()
        f.MessageText:SetPoint("TOPLEFT", f.AlertIcon, "TOPRIGHT", 10, 0)
        f.MessageText:SetPoint("TOPRIGHT", f.Content, "TOPRIGHT")
    else
        f.AlertIcon:Hide()
        f.MessageText:SetPoint("TOPLEFT", f.Content, "TOPLEFT")
        f.MessageText:SetPoint("TOPRIGHT", f.Content, "TOPRIGHT")
    end

    -- Set message
    f.MessageText:SetText(config.message or "")
    f.MessageText:Show()

    -- Create/reuse alert buttons
    local buttons = config.buttons or {}
    local numButtons = #buttons
    local btnWidth = config.buttonWidth or 100
    local btnHeight = config.buttonHeight or 26
    local btnSpacing = 8
    local totalBtnWidth = numButtons * btnWidth + (numButtons - 1) * btnSpacing
    local startX = -totalBtnWidth / 2 + btnWidth / 2

    -- Resize the ButtonBar to fit taller buttons (default bar is 36px)
    local desiredBarHeight = math.max(36, btnHeight + 10)
    f.ButtonBar:SetHeight(desiredBarHeight)

    -- Hide old alert buttons
    for _, btn in ipairs(f.alertButtonFrames) do
        btn:Hide()
    end

    for i, btnConfig in ipairs(buttons) do
        local btn = f.alertButtonFrames[i]
        if not btn then
            btn = CreatePopupButton(f.ButtonBar, "", btnWidth, btnHeight)
            f.alertButtonFrames[i] = btn
        end

        btn.Text:SetText(btnConfig.label or L["OK"])
        btn:SetSize(btnWidth, btnHeight)
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", f.ButtonBar, "CENTER", startX + (i - 1) * (btnWidth + btnSpacing), 0)
        btn.onClick = function()
            if btnConfig.onClick then
                btnConfig.onClick()
            end
            f:Hide()
        end
        btn:Show()
    end

    -- If no buttons provided, add a default OK button
    if numButtons == 0 then
        local btn = f.alertButtonFrames[1]
        if not btn then
            btn = CreatePopupButton(f.ButtonBar, L["OK"], btnWidth, 26)
            f.alertButtonFrames[1] = btn
        end
        btn.Text:SetText(L["OK"])
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", f.ButtonBar, "CENTER", 0, 0)
        btn.onClick = function() f:Hide() end
        btn:Show()
    end

    -- Resize frame
    local messageHeight = f.MessageText:GetStringHeight() or 18
    local iconHeight = config.icon and 32 or 0
    local contentHeight = max(messageHeight, iconHeight)
    -- Account for dynamically-sized ButtonBar (36 default, more when buttons are taller)
    local barHeight = (f.ButtonBar and f.ButtonBar:GetHeight()) or 36
    local totalHeight = 34 + CONTENT_PADDING + contentHeight + CONTENT_PADDING + (barHeight + 2)
    totalHeight = max(totalHeight, 140)
    totalHeight = min(totalHeight, 500)
    f:SetHeight(totalHeight)

    f:ClearAllPoints()
    f:SetPoint("CENTER")
    f:Show()
end

-- ============================================================
-- WIZARD STACK: PopWizardState (needs RenderWizardStep etc. defined above)
-- ============================================================

PopWizardState = function()
    local snapshot = tremove(wizardStack)
    if not snapshot then return end

    wizardConfig = snapshot.config
    wizardAnswers = snapshot.answers
    wizardHistory = snapshot.history
    wizardCurrentStepId = snapshot.currentStepId
    wizardStepLookup = snapshot.stepLookup
    popupMode = "wizard"

    -- Auto-advance past launchWizard steps to avoid re-launching the sub-wizard
    local step = wizardStepLookup[wizardCurrentStepId]
    if step and step.launchWizard then
        local nextId = GetNextStepId(step, nil)
        if nextId == nil and step.next == nil then
            -- Fall through to next step in array
            for idx, s in ipairs(wizardConfig.steps) do
                if s.id == step.id and wizardConfig.steps[idx + 1] then
                    nextId = wizardConfig.steps[idx + 1].id
                    break
                end
            end
        end
        if nextId then
            tinsert(wizardHistory, wizardCurrentStepId)
            wizardCurrentStepId = nextId
        end
    end

    -- Re-render the parent wizard's current step
    if PopupFrame then
        local restoreTitle = wizardConfig.title or "Setup"
        if not wizardConfig.noPrefix then
            restoreTitle = "DandersFrames: " .. restoreTitle
        end
        PopupFrame.TitleText:SetText(restoreTitle)
        local width = wizardConfig.width or FRAME_WIDTH
        PopupFrame:SetWidth(width)
    end
    RenderWizardStep()
    UpdateNavButtons()
    UpdateProgressDots()
end

-- ============================================================
-- PUBLIC API
-- ============================================================

function DF:ShowPopupWizard(config)
    if not config or not config.steps or #config.steps == 0 then
        DF:DebugError("ShowPopupWizard: config must include at least one step")
        return
    end
    ConfigureForWizard(config)
end

function DF:ShowPopupAlert(config)
    if not config then
        DF:DebugError("ShowPopupAlert: config is required")
        return
    end
    ConfigureForAlert(config)
end

-- Launch a sub-wizard from within a running wizard.
-- When the sub-wizard completes, answers are merged and the parent wizard resumes.
-- config.id is required for answer namespacing.
function DF:ShowSubWizard(config)
    if not config or not config.steps or #config.steps == 0 then
        DF:DebugError("ShowSubWizard: config must include at least one step")
        return
    end
    if not config.id then
        DF:DebugError("ShowSubWizard: config.id is required")
        return
    end
    if popupMode ~= "wizard" then
        DF:DebugWarn("ShowSubWizard: no active wizard to return to, launching as top-level")
        DF:ShowPopupWizard(config)
        return
    end

    -- Save current wizard state
    PushWizardState()

    -- Wrap onComplete to merge answers and restore parent
    local originalOnComplete = config.onComplete
    local subId = config.id
    local mergeFlat = config.mergeAnswers

    config.onComplete = function(subAnswers)
        -- Call the sub-wizard's own onComplete first (if any)
        if originalOnComplete then
            originalOnComplete(subAnswers)
        end

        -- Peek at parent answers (top of stack) to merge into
        local parent = wizardStack[#wizardStack]
        if parent then
            if mergeFlat then
                -- Flat merge: sub-wizard keys go directly into parent answers
                for k, v in pairs(subAnswers) do
                    parent.answers[k] = v
                end
            else
                -- Namespaced: store under "sub:id"
                parent.answers["sub:" .. subId] = subAnswers
            end
        end

        -- Restore parent wizard
        PopWizardState()
    end

    -- Wrap onCancel to just restore parent (no merge)
    local originalOnCancel = config.onCancel
    config.onCancel = function()
        if originalOnCancel then
            originalOnCancel()
        end
        PopWizardState()
    end

    -- Launch the sub-wizard
    ConfigureForWizard(config)
end

-- Close the popup programmatically
function DF:HidePopup()
    CancelAutoAdvance()
    DF:ClearSettingHighlights()
    CleanupTestMode()
    CleanupGUI()
    wipe(wizardStack)
    if PopupFrame then
        PopupFrame:Hide()
    end
end

-- Check if popup is currently showing
function DF:IsPopupShown()
    return PopupFrame and PopupFrame:IsShown()
end

-- Check if we're inside a sub-wizard
function DF:IsSubWizardActive()
    return #wizardStack > 0
end

-- ============================================================
-- TEST COMMANDS (temporary, for validation)
-- ============================================================

function DF:TestPopupWizard()
    DF:ShowPopupWizard({
        title = "Test Wizard",
        steps = {
            {
                id = "color",
                question = "Pick your favourite colour",
                description = "This is a single-select step. Clicking an option auto-advances.",
                type = "single",
                options = {
                    { label = "Red",    value = "red" },
                    { label = "Blue",   value = "blue" },
                    { label = "Green",  value = "green" },
                },
                next = function(answer)
                    if answer == "blue" then return "blueshade" end
                    return "layout"
                end,
            },
            {
                id = "blueshade",
                question = "Which shade of blue?",
                type = "single",
                options = {
                    { label = "Sky Blue",   value = "sky" },
                    { label = "Navy",       value = "navy" },
                    { label = "Teal",       value = "teal" },
                },
                next = "layout",
            },
            {
                id = "layout",
                question = "Which frame layout do you prefer?",
                description = "Click an image to select it.",
                type = "imageselect",
                options = {
                    { label = "Compact",  value = "compact",  image = "Interface\\Icons\\INV_Misc_GroupNeedMore" },
                    { label = "Standard", value = "standard", image = "Interface\\Icons\\INV_Misc_GroupLooking" },
                    { label = "Wide",     value = "wide",     image = "Interface\\Icons\\Achievement_BG_grab_cap_quickly" },
                },
                next = "preview",
            },
            {
                -- Test: opens settings GUI and highlights frame size controls
                id = "preview",
                question = "Adjust the frame size to your liking",
                description = "The Frame Width and Frame Height sliders are highlighted in your settings panel. Adjust them, then click Next.",
                type = "single",
                options = {
                    { label = "Looks good, continue", value = "ok" },
                },
                openTab = "general_frame",
                highlightSettings = { "frameWidth", "frameHeight" },
                testMode = "party",
                next = "subwizard_launch",
            },
            {
                -- Test: launches a sub-wizard
                id = "subwizard_launch",
                question = "",
                type = "single",
                options = {},
                testModeOff = true,
                launchWizard = {
                    id = "bonus",
                    title = "Bonus Sub-Wizard",
                    mergeAnswers = true,
                    steps = {
                        {
                            id = "bonus_q",
                            question = "This is a sub-wizard! Pick a bonus option:",
                            description = "When you complete or cancel this, you'll return to the parent wizard.",
                            type = "single",
                            options = {
                                { label = "Extra Sparkle",   value = "sparkle" },
                                { label = "More Cowbell",    value = "cowbell" },
                                { label = "Nothing Thanks",  value = "none" },
                            },
                            next = nil,
                        },
                    },
                    onComplete = function(answers)
                        DF:Debug("Sub-wizard complete: bonus_q = " .. tostring(answers.bonus_q))
                    end,
                },
            },
            {
                id = "features",
                question = "Which features do you want?",
                description = "This is a multi-select step. Select as many as you like, then click Next.",
                type = "multi",
                options = {
                    { label = "Aura Tracking",     value = "auras" },
                    { label = "Health Fade",        value = "healthfade" },
                    { label = "Range Check",        value = "range" },
                    { label = "Dispel Highlight",   value = "dispel" },
                },
                next = "size",
            },
            {
                id = "size",
                question = "What frame size feels right?",
                type = "single",
                options = {
                    { label = "Small (for large raids)",    value = "small" },
                    { label = "Medium (balanced)",          value = "medium" },
                    { label = "Large (healer focus)",       value = "large" },
                },
                next = "extras",
            },
            {
                id = "extras",
                question = "Any extra options?",
                description = "Pick as many as you like.",
                type = "multi",
                options = {
                    { label = "Show power bars",            value = "power" },
                    { label = "Class-coloured health",      value = "classcolor" },
                    { label = "Show role icons",            value = "roleicons" },
                    { label = "Incoming heal prediction",   value = "healpred" },
                },
                next = "summary",
            },
            {
                id = "summary",
                type = "summary",
            },
        },
        onComplete = function(answers)
            DF:Debug("Test wizard complete! Answers:")
            for k, v in pairs(answers) do
                if type(v) == "table" then
                    DF:Debug("  " .. k .. " = " .. table.concat(v, ", "))
                else
                    DF:Debug("  " .. k .. " = " .. tostring(v))
                end
            end
        end,
        onCancel = function()
            DF:Debug("Test wizard cancelled")
        end,
    })
end

function DF:TestPopupAlert()
    DF:ShowPopupAlert({
        title = "Test Alert",
        message = "This is a test alert message.\nIt supports multiple lines and will resize to fit the content.\n\nClick a button below to dismiss.",
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        buttons = {
            { label = "Action", onClick = function() DF:Debug("Test alert: Action clicked") end },
            { label = "Dismiss", onClick = nil },
        },
    })
end
