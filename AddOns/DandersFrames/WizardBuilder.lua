local addonName, DF = ...

-- ============================================================
-- WIZARD BUILDER
-- Visual tool for creating, editing, and sharing setup wizards.
-- Stores wizard configs in DandersFramesDB_v2.wizardConfigs.
-- ============================================================

local pairs, ipairs, tinsert, tremove, wipe = pairs, ipairs, tinsert, tremove, wipe
local format = string.format
local type = type
local time = time
local L = DF.L

local WB = {}
DF.WizardBuilder = WB

-- ============================================================
-- DB KEY CACHE
-- Flattened list of all setting keys for the searchable dropdown
-- ============================================================

local dbKeyCache = nil

local function BuildDBKeyCache()
    if dbKeyCache then return dbKeyCache end
    dbKeyCache = {}

    -- Get export categories if available for grouping
    local catLookup = {}
    if DF.GetSettingCategory then
        -- Build from known keys
    end

    -- Party keys
    if DF.PartyDefaults then
        for key, val in pairs(DF.PartyDefaults) do
            local cat = ""
            if DF.GetSettingCategory then
                cat = DF:GetSettingCategory(key) or "other"
            end
            tinsert(dbKeyCache, {
                value = "party." .. key,
                text = "party." .. key,
                category = format(L["Party: %s"], cat),
            })
        end
    end

    -- Raid keys
    if DF.RaidDefaults then
        for key, val in pairs(DF.RaidDefaults) do
            local cat = ""
            if DF.GetSettingCategory then
                cat = DF:GetSettingCategory(key) or "other"
            end
            tinsert(dbKeyCache, {
                value = "raid." .. key,
                text = "raid." .. key,
                category = format(L["Raid: %s"], cat),
            })
        end
    end

    -- Sort by category then key
    table.sort(dbKeyCache, function(a, b)
        if a.category == b.category then
            return a.text < b.text
        end
        return a.category < b.category
    end)

    return dbKeyCache
end

local function GetDBKeyOptions()
    return BuildDBKeyCache()
end

-- ============================================================
-- WIZARD CONFIG HELPERS
-- ============================================================

local function GetWizardConfigs()
    return DandersFramesDB_v2 and DandersFramesDB_v2.wizardConfigs or {}
end

local function SaveWizardConfig(name, config)
    if not DandersFramesDB_v2 then return end
    if not DandersFramesDB_v2.wizardConfigs then DandersFramesDB_v2.wizardConfigs = {} end
    DandersFramesDB_v2.wizardConfigs[name] = config
end

local function DeleteWizardConfig(name)
    if DandersFramesDB_v2 and DandersFramesDB_v2.wizardConfigs then
        DandersFramesDB_v2.wizardConfigs[name] = nil
    end
end

local function GetWizardNames()
    local names = {}
    local configs = GetWizardConfigs()
    for name in pairs(configs) do
        tinsert(names, { label = name, name = name })
    end
    table.sort(names, function(a, b) return a.name < b.name end)
    return names
end

local function CreateNewWizard(name)
    local config = {
        name = name,
        author = UnitName("player") or "Unknown",
        description = "",
        version = 1,
        created = time(),
        modified = time(),
        title = name,
        width = 440,
        steps = {
            {
                id = "step1",
                question = L["First question"],
                description = "",
                type = "single",
                options = {
                    { label = L["Option A"], value = "a" },
                    { label = L["Option B"], value = "b" },
                },
                next = "summary",
            },
            {
                id = "summary",
                type = "summary",
            },
        },
        settingsMap = {},
    }
    SaveWizardConfig(name, config)
    return config
end

-- ============================================================
-- IMPORT / EXPORT
-- Uses same LibSerialize + LibDeflate pattern as profiles
-- Format prefix: !DFW1!
-- ============================================================

local LibSerialize = LibStub("LibSerialize", true)
local LibDeflate = LibStub("LibDeflate", true)

function WB:ExportWizard(name)
    local configs = GetWizardConfigs()
    local config = configs[name]
    if not config then return nil, "Wizard not found" end
    if not LibSerialize or not LibDeflate then return nil, "Missing libraries" end

    local serialized = LibSerialize:Serialize(config)
    if not serialized then return nil, "Serialization failed" end

    local compressed = LibDeflate:CompressDeflate(serialized)
    if not compressed then return nil, "Compression failed" end

    local encoded = LibDeflate:EncodeForPrint(compressed)
    if not encoded then return nil, "Encoding failed" end

    return "!DFW1!" .. encoded
end

function WB:ImportWizard(str)
    if not str or str == "" then return nil, "Empty string" end
    if not LibSerialize or not LibDeflate then return nil, "Missing libraries" end

    local prefix = str:sub(1, 6)
    if prefix ~= "!DFW1!" then return nil, "Invalid format (expected !DFW1! prefix)" end

    local encoded = str:sub(7)
    local compressed = LibDeflate:DecodeForPrint(encoded)
    if not compressed then return nil, "Decode failed" end

    local serialized = LibDeflate:DecompressDeflate(compressed)
    if not serialized then return nil, "Decompress failed" end

    local success, data = LibSerialize:Deserialize(serialized)
    if not success or not data then return nil, "Deserialize failed" end

    -- Validate basic structure
    if not data.name or not data.steps or type(data.steps) ~= "table" then
        return nil, "Invalid wizard structure"
    end

    return data
end

-- ============================================================
-- PREVIEW: Build a ShowPopupWizard config from stored data
-- ============================================================

-- Expose as both local and module function for Options.lua access
local function BuildWizardConfig(config)
    if not config then return nil end

    -- Deep copy steps to avoid modifying the stored config
    local steps = DF:DeepCopy(config.steps)

    -- For user-built wizards, branching is handled by EvaluateBranches in Popup.lua
    -- which reads step.branches directly. No function conversion needed.

    return {
        title = config.title or config.name or L["Wizard"],
        width = config.width or 440,
        steps = steps,
        settingsMap = config.settingsMap,
        onComplete = function(answers)
            -- settingsMap is applied automatically by CompleteWizard() in Popup.lua
            DF:Debug("Wizard '" .. (config.name or "?") .. "' completed")
        end,
    }
end

-- ============================================================
-- STATE: Track which wizard and step are being edited
-- ============================================================

local editingWizardName = nil
local editingStepIndex = nil

-- ============================================================
-- BUILDER POPUP
-- A popup-style editor that looks like the wizard output but
-- with editable fields. Each "page" edits one wizard step.
-- ============================================================

local BuilderFrame = nil
local builderConfig = nil       -- The wizard config being edited
local builderWizardName = nil   -- Name key in SavedVariables
local builderStepIndex = 1      -- Which step is currently shown
local builderOnSave = nil       -- Callback when wizard is saved

-- Theme colors (matching Popup.lua)
local BC = {
    background = {r = 0.08, g = 0.08, b = 0.08, a = 0.97},
    panel      = {r = 0.12, g = 0.12, b = 0.12, a = 1},
    element    = {r = 0.18, g = 0.18, b = 0.18, a = 1},
    border     = {r = 0.25, g = 0.25, b = 0.25, a = 1},
    accent     = {r = 0.45, g = 0.45, b = 0.95, a = 1},
    hover      = {r = 0.22, g = 0.22, b = 0.22, a = 1},
    text       = {r = 0.9,  g = 0.9,  b = 0.9,  a = 1},
    textDim    = {r = 0.6,  g = 0.6,  b = 0.6,  a = 1},
    green      = {r = 0.2,  g = 0.9,  b = 0.2},
    red        = {r = 0.9,  g = 0.25, b = 0.25},
    orange     = {r = 0.85, g = 0.55, b = 0.1},
}

local BUILDER_WIDTH = 500
local BUILDER_PADDING = 20

local function ApplyBuilderBackdrop(frame, bgColor, borderColor, edgeSize)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = edgeSize or 1,
    })
    frame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 1)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
end

-- Create an edit box with dark theme styling
local function CreateBuilderEditBox(parent, width, height, multiLine)
    -- Use a container frame with backdrop, edit box inside it
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(width, height)
    ApplyBuilderBackdrop(container, BC.element, BC.border, 1)

    local edit = CreateFrame("EditBox", nil, container)
    edit:SetPoint("TOPLEFT", 8, -4)
    edit:SetPoint("BOTTOMRIGHT", -8, 4)
    edit:SetAutoFocus(false)
    edit:SetFontObject(DFFontHighlightSmall)
    edit:SetTextColor(BC.text.r, BC.text.g, BC.text.b)
    if multiLine then
        edit:SetMultiLine(true)
        edit:SetMaxLetters(500)
    end
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Forward common methods to the container for positioning
    container.SetText = function(_, text) edit:SetText(text or "") end
    container.GetText = function(_) return edit:GetText() end
    container.SetScript = function(_, event, handler)
        if event == "OnEnterPressed" or event == "OnEscapePressed" or event == "OnTextChanged" then
            edit:SetScript(event, handler)
        end
    end
    container.ClearFocus = function(_) edit:ClearFocus() end
    container.editBox = edit

    return container
end

-- Create a themed button
local function CreateBuilderButton(parent, text, width, height, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    ApplyBuilderBackdrop(btn, BC.element, BC.border, 1)

    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(text)
    btn.Text:SetTextColor(BC.text.r, BC.text.g, BC.text.b)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(BC.hover.r, BC.hover.g, BC.hover.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        ApplyBuilderBackdrop(self, BC.element, BC.border, 1)
    end)
    btn:SetScript("OnClick", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if onClick then onClick() end
    end)
    return btn
end

-- Create a small icon button (delete, settings, branch)
local function CreateSmallButton(parent, text, size, onClick, color)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(size, size)
    local bgColor = color or BC.element
    ApplyBuilderBackdrop(btn, bgColor, BC.border, 1)

    btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(text)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(BC.hover.r, BC.hover.g, BC.hover.b, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        ApplyBuilderBackdrop(self, bgColor, BC.border, 1)
    end)
    btn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if onClick then onClick() end
    end)
    return btn
end

-- Pool of option row frames for reuse
local optionRowPool = {}

local function GetOptionRow()
    local row = tremove(optionRowPool)
    if row then
        row:Show()
        return row
    end
    return nil  -- Caller will create new
end

local function ReleaseOptionRow(row)
    row:Hide()
    row:ClearAllPoints()
    row:SetParent(UIParent)
    tinsert(optionRowPool, row)
end

-- Active option rows in current render
local activeOptionRows = {}

local function SaveCurrentConfig()
    if builderWizardName and builderConfig then
        builderConfig.modified = time()
        SaveWizardConfig(builderWizardName, builderConfig)
    end
end

-- ============================================================
-- BUILDER FRAME CONSTRUCTION
-- ============================================================

local function CreateBuilderFrame()
    if BuilderFrame then return BuilderFrame end

    local f = CreateFrame("Frame", "DFBuilderFrame", UIParent, "BackdropTemplate")
    f:SetSize(BUILDER_WIDTH, 500)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(200)
    ApplyBuilderBackdrop(f, BC.background, BC.border, 2)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:Hide()

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 2, -2)
    titleBar:SetPoint("TOPRIGHT", -2, -2)
    titleBar:SetHeight(32)
    ApplyBuilderBackdrop(titleBar, BC.panel, BC.border, 1)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    f.TitleBar = titleBar

    -- Accent stripe
    local accent = f:CreateTexture(nil, "OVERLAY")
    accent:SetPoint("TOPLEFT", 0, 0)
    accent:SetPoint("TOPRIGHT", 0, 0)
    accent:SetHeight(2)
    accent:SetColorTexture(BC.accent.r, BC.accent.g, BC.accent.b, 1)

    -- Title text
    f.TitleText = titleBar:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    f.TitleText:SetPoint("CENTER")
    f.TitleText:SetText(L["Wizard Builder"])
    f.TitleText:SetTextColor(BC.text.r, BC.text.g, BC.text.b)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -6, 0)
    closeBtn.bg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBtn.bg:SetAllPoints()
    closeBtn.bg:SetColorTexture(BC.red.r, BC.red.g, BC.red.b, 0.8)
    closeBtn.text = closeBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    closeBtn.text:SetPoint("CENTER", 0, 1)
    closeBtn.text:SetText("x")
    closeBtn:SetScript("OnClick", function()
        SaveCurrentConfig()
        f:Hide()
    end)
    closeBtn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 0.3, 0.3, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(BC.red.r, BC.red.g, BC.red.b, 0.8)
    end)

    -- Content area (plain frame, no scroll — frame resizes to fit)
    local contentArea = CreateFrame("Frame", nil, f)
    contentArea:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    contentArea:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    -- Bottom will be set dynamically when we know content height
    contentArea:SetHeight(400)
    f.Content = contentArea

    -- Button bar
    local buttonBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    buttonBar:SetPoint("BOTTOMLEFT", 2, 2)
    buttonBar:SetPoint("BOTTOMRIGHT", -2, 2)
    buttonBar:SetHeight(44)
    ApplyBuilderBackdrop(buttonBar, BC.panel, BC.border, 1)
    f.ButtonBar = buttonBar

    -- Back button
    f.BackBtn = CreateBuilderButton(buttonBar, L["Back"], 90, 30, function()
        if builderStepIndex > 1 then
            builderStepIndex = builderStepIndex - 1
            RenderBuilderStep()
        end
    end)
    f.BackBtn:SetPoint("LEFT", 10, 0)

    -- Add Step button (center)
    f.AddStepBtn = CreateBuilderButton(buttonBar, L["+ Add Step"], 100, 30, function()
        if not builderConfig then return end
        -- Insert new step after current (before summary if exists)
        local insertPos = builderStepIndex + 1
        -- Don't insert after summary
        if builderConfig.steps[builderStepIndex] and builderConfig.steps[builderStepIndex].type == "summary" then
            insertPos = builderStepIndex
        end
        local newId = "step" .. (#builderConfig.steps + 1)
        tinsert(builderConfig.steps, insertPos, {
            id = newId,
            question = "",
            description = "",
            type = "single",
            options = {
                { label = L["Option A"], value = "a" },
                { label = L["Option B"], value = "b" },
            },
        })
        SaveCurrentConfig()
        builderStepIndex = insertPos
        RenderBuilderStep()
    end)
    f.AddStepBtn:SetPoint("CENTER", 0, 0)

    -- Next/Save button
    f.NextBtn = CreateBuilderButton(buttonBar, L["Next"], 90, 30, function()
        if not builderConfig then return end
        if builderStepIndex < #builderConfig.steps then
            builderStepIndex = builderStepIndex + 1
            RenderBuilderStep()
        else
            -- Last step: save and close
            SaveCurrentConfig()
            f:Hide()
            if builderOnSave then builderOnSave(builderWizardName) end
        end
    end)
    f.NextBtn:SetPoint("RIGHT", -10, 0)

    -- Progress dots container
    f.DotsContainer = CreateFrame("Frame", nil, f)
    f.DotsContainer:SetHeight(12)
    f.DotsContainer:SetPoint("BOTTOM", buttonBar, "TOP", 0, 4)
    f.Dots = {}

    -- Add to special frames for Escape key
    tinsert(UISpecialFrames, "DFBuilderFrame")

    BuilderFrame = f
    return f
end

-- ============================================================
-- RENDER A BUILDER STEP
-- Shows editable fields for one step of the wizard
-- ============================================================

local function UpdateBuilderDots()
    if not BuilderFrame or not builderConfig then return end
    local numSteps = #builderConfig.steps
    local dots = BuilderFrame.Dots
    local dotSize = 8
    local dotSpacing = 6
    local totalWidth = numSteps * dotSize + (numSteps - 1) * dotSpacing

    BuilderFrame.DotsContainer:SetWidth(totalWidth)

    for i = 1, max(numSteps, #dots) do
        if i <= numSteps then
            if not dots[i] then
                dots[i] = BuilderFrame.DotsContainer:CreateTexture(nil, "OVERLAY")
                dots[i]:SetSize(dotSize, dotSize)
            end
            dots[i]:ClearAllPoints()
            dots[i]:SetPoint("LEFT", (i - 1) * (dotSize + dotSpacing), 0)
            if i == builderStepIndex then
                dots[i]:SetColorTexture(BC.accent.r, BC.accent.g, BC.accent.b, 1)
            else
                dots[i]:SetColorTexture(BC.border.r, BC.border.g, BC.border.b, 1)
            end
            dots[i]:Show()
        elseif dots[i] then
            dots[i]:Hide()
        end
    end
end

local function UpdateBuilderNavButtons()
    if not BuilderFrame or not builderConfig then return end

    -- Back
    if builderStepIndex > 1 then
        BuilderFrame.BackBtn:Show()
    else
        BuilderFrame.BackBtn:Hide()
    end

    -- Next/Save
    if builderStepIndex >= #builderConfig.steps then
        BuilderFrame.NextBtn.Text:SetText(L["Save & Close"])
    else
        BuilderFrame.NextBtn.Text:SetText(L["Next"])
    end
end

-- Forward declaration
-- RenderBuilderStep defined below after helpers

local function ClearBuilderContent()
    -- Release option rows
    for _, row in ipairs(activeOptionRows) do
        ReleaseOptionRow(row)
    end
    wipe(activeOptionRows)

    -- Destroy the inner content container and recreate it
    -- This ensures ALL children AND font strings are removed
    if BuilderFrame and BuilderFrame.ContentInner then
        BuilderFrame.ContentInner:Hide()
        BuilderFrame.ContentInner:SetParent(nil)
    end

    if BuilderFrame and BuilderFrame.Content then
        local inner = CreateFrame("Frame", nil, BuilderFrame.Content)
        inner:SetAllPoints()
        BuilderFrame.ContentInner = inner
    end
end

-- Create an option row for the builder
local function CreateOptionRowFrame(parent, optIndex, step, onUpdate)
    local row = GetOptionRow()
    if not row then
        row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        row:SetHeight(32)
        ApplyBuilderBackdrop(row, {r = 0.14, g = 0.14, b = 0.14, a = 1}, BC.border, 1)

        -- Label edit box
        row.LabelEdit = CreateFrame("EditBox", nil, row, "BackdropTemplate")
        row.LabelEdit:SetHeight(24)
        row.LabelEdit:SetPoint("LEFT", 8, 0)
        row.LabelEdit:SetAutoFocus(false)
        row.LabelEdit:SetFontObject(DFFontHighlightSmall)
        row.LabelEdit:SetTextInsets(6, 6, 0, 0)
        ApplyBuilderBackdrop(row.LabelEdit, BC.element, BC.border, 1)
        row.LabelEdit:SetTextColor(BC.text.r, BC.text.g, BC.text.b)
        row.LabelEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

        -- Delete button (rightmost)
        row.DeleteBtn = CreateSmallButton(row, "x", 24, nil, BC.element)
        row.DeleteBtn:SetPoint("RIGHT", -4, 0)
        row.DeleteBtn.Text:SetTextColor(BC.red.r, BC.red.g, BC.red.b)

        -- Branch button (wider to show step IDs)
        row.BranchBtn = CreateSmallButton(row, "->", 24, nil, BC.element)
        row.BranchBtn:SetSize(70, 24)
        row.BranchBtn:SetPoint("RIGHT", row.DeleteBtn, "LEFT", -2, 0)
        row.BranchBtn.Text:SetTextColor(BC.accent.r, BC.accent.g, BC.accent.b)
        row.BranchBtn.Text:SetFontObject(DFFontHighlightSmall)

        -- Settings gear button
        row.GearBtn = CreateSmallButton(row, "S", 24, nil, BC.element)
        row.GearBtn:SetPoint("RIGHT", row.BranchBtn, "LEFT", -2, 0)
        row.GearBtn.Text:SetTextColor(BC.orange.r, BC.orange.g, BC.orange.b)
    end

    row:SetParent(parent)
    row.LabelEdit:ClearAllPoints()
    row.LabelEdit:SetPoint("LEFT", 8, 0)
    row.LabelEdit:SetPoint("RIGHT", row.GearBtn, "LEFT", -8, 0)

    -- Configure for this option
    local opt = step.options[optIndex]
    row.LabelEdit:SetText(opt and opt.label or "")
    row.LabelEdit:SetScript("OnTextChanged", function(self)
        if step.options[optIndex] then
            step.options[optIndex].label = self:GetText()
            step.options[optIndex].value = self:GetText():gsub("%s+", "_"):lower()
            SaveCurrentConfig()
        end
    end)
    row.LabelEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    -- Gear: open settings picker for this option
    row.GearBtn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if not step.options[optIndex] then return end
        local optValue = step.options[optIndex].value
        -- Hide builder, enter picker mode
        BuilderFrame:Hide()
        DF:EnterSettingsPickerMode(function(tabName, dbKey, controlType)
            local currentValue = DF:GetDBKeyByPath(DF.GUI.SelectedMode .. "." .. dbKey)
            local mode = DF.GUI.SelectedMode or "party"
            local fullKey = mode .. "." .. dbKey

            -- Helper to store a setting value and return to builder
            local function LinkSettingValue(setValue)
                if not builderConfig.settingsMap then builderConfig.settingsMap = {} end
                if not builderConfig.settingsMap[step.id] then builderConfig.settingsMap[step.id] = {} end
                if not builderConfig.settingsMap[step.id][optValue] then builderConfig.settingsMap[step.id][optValue] = {} end
                builderConfig.settingsMap[step.id][optValue][fullKey] = setValue
                SaveCurrentConfig()
                BuilderFrame:Show()
                RenderBuilderStep()
            end

            -- Helper to store as highlight
            local function LinkSettingHighlight()
                if not step.highlightSettings then step.highlightSettings = {} end
                local found = false
                for _, k in ipairs(step.highlightSettings) do
                    if k == dbKey then found = true break end
                end
                if not found then
                    tinsert(step.highlightSettings, dbKey)
                end
                step.openTab = tabName
                SaveCurrentConfig()
                BuilderFrame:Show()
                RenderBuilderStep()
            end

            -- Build action buttons based on control type
            if controlType == "checkbox" then
                -- Checkbox: offer true/false choice
                DF:ShowPopupWizard({
                    title = format(L["Link: %s"], dbKey),
                    width = 400,
                    steps = {
                        {
                            id = "action",
                            question = format(L["What should '%s' do with this setting?"], (opt and opt.label or L["this option"])),
                            description = format(L["%s (currently %s)"], dbKey, tostring(currentValue)),
                            type = "single",
                            options = {
                                { label = L["Enable (set to true)"], value = "set_true" },
                                { label = L["Disable (set to false)"], value = "set_false" },
                                { label = L["Highlight for user to configure"], value = "highlight" },
                            },
                        },
                    },
                    onComplete = function(answers)
                        local action = answers.action
                        if action == "set_true" then
                            LinkSettingValue(true)
                        elseif action == "set_false" then
                            LinkSettingValue(false)
                        elseif action == "highlight" then
                            LinkSettingHighlight()
                        else
                            BuilderFrame:Show()
                        end
                    end,
                    onCancel = function()
                        BuilderFrame:Show()
                    end,
                })
            elseif controlType == "slider" then
                -- Slider: show current value and let user type a number
                DF:ShowPopupAlert({
                    title = format(L["Link: %s"], dbKey),
                    message = format(L["Setting: %s\nCurrent value: %s\n\nEnter the value to set, or highlight for the user."],
                        dbKey, tostring(currentValue)),
                    buttons = {
                        {
                            label = format(L["Use Current (%s)"], tostring(currentValue)),
                            onClick = function()
                                LinkSettingValue(currentValue)
                            end,
                        },
                        {
                            label = L["Highlight for User"],
                            onClick = function()
                                LinkSettingHighlight()
                            end,
                        },
                        {
                            label = L["Cancel"],
                            onClick = function()
                                BuilderFrame:Show()
                            end,
                        },
                    },
                })
            else
                -- Dropdown/color/other: offer highlight or use current value
                DF:ShowPopupAlert({
                    title = format(L["Link: %s"], dbKey),
                    message = format(L["Setting: %s\nCurrent value: %s\n\nWhat should happen when '%s' is selected?"],
                        dbKey, tostring(currentValue), opt and opt.label or L["this option"]),
                    buttons = {
                        {
                            label = L["Use Current Value"],
                            onClick = function()
                                LinkSettingValue(currentValue)
                            end,
                        },
                        {
                            label = L["Highlight for User"],
                            onClick = function()
                                LinkSettingHighlight()
                            end,
                        },
                        {
                            label = L["Cancel"],
                            onClick = function()
                                BuilderFrame:Show()
                            end,
                        },
                    },
                })
            end  -- if controlType
        end)  -- EnterSettingsPickerMode callback
    end)  -- GearBtn OnClick

    -- Branch: cycle through available steps
    row.BranchBtn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if not step.options[optIndex] or not builderConfig then return end
        -- Build list of step IDs to cycle through
        local stepIds = {}
        for _, s in ipairs(builderConfig.steps) do
            if s.id ~= step.id then
                tinsert(stepIds, s.id)
            end
        end
        tinsert(stepIds, "")  -- Empty = no branch (follow default next)

        -- Find current branch for this option
        if not step.branches then step.branches = {} end
        local currentGoto = ""
        for _, b in ipairs(step.branches) do
            if b.condition and b.condition.equals == step.options[optIndex].value then
                currentGoto = b["goto"] or ""
                break
            end
        end

        -- Cycle to next
        local nextIdx = 1
        for i, id in ipairs(stepIds) do
            if id == currentGoto then
                nextIdx = (i % #stepIds) + 1
                break
            end
        end
        local newGoto = stepIds[nextIdx]

        -- Update or create branch
        local found = false
        for _, b in ipairs(step.branches) do
            if b.condition and b.condition.equals == step.options[optIndex].value then
                if newGoto == "" then
                    -- Remove branch
                    for j, bb in ipairs(step.branches) do
                        if bb == b then tremove(step.branches, j) break end
                    end
                else
                    b["goto"] = newGoto
                end
                found = true
                break
            end
        end
        if not found and newGoto ~= "" then
            tinsert(step.branches, {
                condition = { equals = step.options[optIndex].value },
                ["goto"] = newGoto,
            })
        end
        SaveCurrentConfig()
        -- Re-render to show updated branch display
        RenderBuilderStep()
    end)

    -- Update branch display
    local branchTarget = ""
    if step.branches then
        for _, b in ipairs(step.branches) do
            if b.condition and b.condition.equals == (opt and opt.value) then
                branchTarget = b["goto"] or ""
                break
            end
        end
    end
    if branchTarget ~= "" then
        row.BranchBtn.Text:SetText("> " .. branchTarget)
    else
        row.BranchBtn.Text:SetText(L["no branch"])
    end

    -- Delete
    row.DeleteBtn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if #step.options > 1 then
            tremove(step.options, optIndex)
            SaveCurrentConfig()
            RenderBuilderStep()
        end
    end)

    -- Tooltip for gear showing linked settings
    row.GearBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(BC.hover.r, BC.hover.g, BC.hover.b, 1)
        local linked = {}
        local sm = builderConfig.settingsMap
        if sm and sm[step.id] and opt and sm[step.id][opt.value] then
            for k, v in pairs(sm[step.id][opt.value]) do
                tinsert(linked, k .. " = " .. tostring(v))
            end
        end
        if #linked > 0 then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Linked Settings"], 1, 1, 1)
            for _, line in ipairs(linked) do
                GameTooltip:AddLine(line, BC.orange.r, BC.orange.g, BC.orange.b)
            end
            GameTooltip:Show()
        end
    end)
    row.GearBtn:SetScript("OnLeave", function(self)
        ApplyBuilderBackdrop(self, BC.element, BC.border, 1)
        GameTooltip:Hide()
    end)

    -- Tooltip for branch
    row.BranchBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(BC.hover.r, BC.hover.g, BC.hover.b, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Branch"], 1, 1, 1)
        if branchTarget ~= "" then
            GameTooltip:AddLine(format(L["Goes to: %s"], branchTarget), BC.accent.r, BC.accent.g, BC.accent.b)
        else
            GameTooltip:AddLine(L["Click to set branch target"], BC.textDim.r, BC.textDim.g, BC.textDim.b)
        end
        GameTooltip:AddLine(L["Click to cycle through steps"], BC.textDim.r, BC.textDim.g, BC.textDim.b)
        GameTooltip:Show()
    end)
    row.BranchBtn:SetScript("OnLeave", function(self)
        ApplyBuilderBackdrop(self, BC.element, BC.border, 1)
        GameTooltip:Hide()
    end)

    row:Show()
    tinsert(activeOptionRows, row)
    return row
end

function RenderBuilderStep()
    if not BuilderFrame or not builderConfig then return end

    ClearBuilderContent()

    local step = builderConfig.steps[builderStepIndex]
    if not step then return end

    local parent = BuilderFrame.ContentInner or BuilderFrame.Content
    local y = -BUILDER_PADDING
    local contentWidth = BUILDER_WIDTH - 40

    -- Step counter + delete button
    local counterFrame = CreateFrame("Frame", nil, parent)
    counterFrame:SetSize(contentWidth, 24)
    counterFrame:SetPoint("TOPLEFT", BUILDER_PADDING, y)

    local counterText = counterFrame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    counterText:SetPoint("LEFT")
    counterText:SetText(format(L["Step %d of %d"], builderStepIndex, #builderConfig.steps))
    counterText:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)

    -- Delete step button (only if more than 1 step)
    if #builderConfig.steps > 1 then
        local delStep = CreateBuilderButton(counterFrame, L["Delete Step"], 80, 20, function()
            tremove(builderConfig.steps, builderStepIndex)
            if builderStepIndex > #builderConfig.steps then
                builderStepIndex = #builderConfig.steps
            end
            SaveCurrentConfig()
            RenderBuilderStep()
        end)
        delStep:SetPoint("RIGHT")
        delStep.Text:SetTextColor(BC.red.r, BC.red.g, BC.red.b)
    end

    y = y - 32

    -- Wizard Name (editable, shown on first step only)
    if builderStepIndex == 1 then
        local nameLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        nameLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        nameLabel:SetText(L["Wizard Name:"])
        nameLabel:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)
        y = y - 18

        local nameEdit = CreateBuilderEditBox(parent, contentWidth, 28)
        nameEdit:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        nameEdit:SetText(builderConfig.title or builderConfig.name or "")
        nameEdit:SetScript("OnTextChanged", function(self)
            local newTitle = self:GetText()
            if newTitle and newTitle ~= "" then
                builderConfig.title = newTitle
                BuilderFrame.TitleText:SetText(L["Building: "] .. newTitle)
                SaveCurrentConfig()
            end
        end)
        nameEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        y = y - 36
    end

    -- Summary step is special — no editable content
    if step.type == "summary" then
        local summaryLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
        summaryLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        summaryLabel:SetText(L["Summary Step"])
        summaryLabel:SetTextColor(BC.text.r, BC.text.g, BC.text.b)
        y = y - 30

        local desc = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        desc:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        desc:SetPoint("RIGHT", parent, "RIGHT", -BUILDER_PADDING, 0)
        desc:SetText(L["This step automatically shows a review of all the user's answers. It's always the last step."])
        desc:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)
        desc:SetJustifyH("LEFT")
        desc:SetWordWrap(true)
        y = y - (desc:GetStringHeight() or 30) - 20

        local contentHeight = math.abs(y) + 20
        BuilderFrame.Content:SetHeight(contentHeight)
        local frameHeight = contentHeight + 32 + 44 + 24
        frameHeight = min(max(frameHeight, 300), 650)
        BuilderFrame:SetHeight(frameHeight)
        BuilderFrame.Content:ClearAllPoints()
        BuilderFrame.Content:SetPoint("TOPLEFT", BuilderFrame.TitleBar, "BOTTOMLEFT", 0, 0)
        BuilderFrame.Content:SetPoint("BOTTOMRIGHT", BuilderFrame.ButtonBar, "TOPRIGHT", 0, 16)
        UpdateBuilderDots()
        UpdateBuilderNavButtons()
        return
    end

    -- Step Type (simple label + cycle button)
    local typeLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    typeLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    typeLabel:SetText(L["Type:"])
    typeLabel:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)

    local typeNames = { single = L["Single Select"], multi = L["Multi Select"] }
    local typeBtn = CreateBuilderButton(parent, typeNames[step.type] or L["Single Select"], 120, 22, function()
        if step.type == "single" then
            step.type = "multi"
        else
            step.type = "single"
        end
        SaveCurrentConfig()
        RenderBuilderStep()
    end)
    typeBtn:SetPoint("LEFT", typeLabel, "RIGHT", 8, 0)
    y = y - 30

    -- Question
    local qLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    qLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    qLabel:SetText(L["Question:"])
    qLabel:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)
    y = y - 18

    local qEdit = CreateBuilderEditBox(parent, contentWidth, 28)
    qEdit:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    qEdit:SetText(step.question or "")
    qEdit:SetScript("OnTextChanged", function(self)
        step.question = self:GetText()
        SaveCurrentConfig()
    end)
    qEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    y = y - 36

    -- Description
    local dLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    dLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    dLabel:SetText(L["Description (optional)"])
    dLabel:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)
    y = y - 18

    local dEdit = CreateBuilderEditBox(parent, contentWidth, 56, true)
    dEdit:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    dEdit:SetText(step.description or "")
    dEdit:SetScript("OnTextChanged", function(self)
        step.description = self:GetText()
        SaveCurrentConfig()
    end)
    y = y - 64

    -- Options header
    local optLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    optLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    optLabel:SetText(L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"])
    optLabel:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)
    y = y - 20

    -- Option rows
    if not step.options then step.options = {} end
    for i, opt in ipairs(step.options) do
        local row = CreateOptionRowFrame(parent, i, step, function()
            SaveCurrentConfig()
            RenderBuilderStep()
        end)
        row:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        row:SetPoint("RIGHT", parent, "RIGHT", -BUILDER_PADDING, 0)
        y = y - 36
    end

    -- Add Option button
    local addOptBtn = CreateBuilderButton(parent, L["+ Add Option"], 120, 26, function()
        local newLabel = "Option " .. string.char(64 + #step.options + 1)  -- A, B, C...
        tinsert(step.options, { label = newLabel, value = newLabel:gsub("%s+", "_"):lower() })
        SaveCurrentConfig()
        RenderBuilderStep()
    end)
    addOptBtn:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    y = y - 36

    -- Integration section (collapsible)
    local intLabel = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    intLabel:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    intLabel:SetText(L["Integration (advanced):"])
    intLabel:SetTextColor(BC.textDim.r, BC.textDim.g, BC.textDim.b)
    y = y - 20

    -- Test mode toggle
    local testModes = { "", "party", "raid" }
    local testModeNames = { [""] = L["None"], party = L["Party"], raid = L["Raid"] }
    local testBtn = CreateBuilderButton(parent, format(L["Test Mode: %s"], testModeNames[step.testMode or ""]), 160, 22, function()
        local current = step.testMode or ""
        local nextIdx = 1
        for i, m in ipairs(testModes) do
            if m == current then nextIdx = (i % #testModes) + 1 break end
        end
        step.testMode = testModes[nextIdx] ~= "" and testModes[nextIdx] or nil
        SaveCurrentConfig()
        RenderBuilderStep()
    end)
    testBtn:SetPoint("TOPLEFT", BUILDER_PADDING, y)
    y = y - 28

    -- Open Tab info
    if step.openTab then
        local tabInfo = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        tabInfo:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        tabInfo:SetText(format(L["Opens tab: %s"], step.openTab))
        tabInfo:SetTextColor(BC.orange.r, BC.orange.g, BC.orange.b)
        y = y - 18
    end

    -- Highlight Settings info
    if step.highlightSettings and #step.highlightSettings > 0 then
        local hlInfo = parent:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        hlInfo:SetPoint("TOPLEFT", BUILDER_PADDING, y)
        hlInfo:SetText(format(L["Highlights: %s"], table.concat(step.highlightSettings, ", ")))
        hlInfo:SetTextColor(BC.orange.r, BC.orange.g, BC.orange.b)
        y = y - 18
    end

    y = y - 20

    -- Resize content area and frame to fit
    local contentHeight = math.abs(y) + 20
    BuilderFrame.Content:SetHeight(contentHeight)

    local frameHeight = contentHeight + 32 + 44 + 24  -- titlebar + buttonbar + dots
    frameHeight = min(max(frameHeight, 300), 650)
    BuilderFrame:SetHeight(frameHeight)

    -- Update content bottom anchor relative to button bar
    BuilderFrame.Content:ClearAllPoints()
    BuilderFrame.Content:SetPoint("TOPLEFT", BuilderFrame.TitleBar, "BOTTOMLEFT", 0, 0)
    BuilderFrame.Content:SetPoint("BOTTOMRIGHT", BuilderFrame.ButtonBar, "TOPRIGHT", 0, 16)

    UpdateBuilderDots()
    UpdateBuilderNavButtons()
end

-- ============================================================
-- PUBLIC API: Show the builder popup
-- ============================================================

function WB:ShowBuilder(wizardName, onSave)
    local configs = GetWizardConfigs()
    local config = configs[wizardName]
    if not config then
        config = CreateNewWizard(wizardName)
    end

    -- Ensure summary step exists at end
    local hasSummary = false
    for _, s in ipairs(config.steps) do
        if s.type == "summary" then hasSummary = true break end
    end
    if not hasSummary then
        tinsert(config.steps, { id = "summary", type = "summary" })
        SaveWizardConfig(wizardName, config)
    end

    builderConfig = config
    builderWizardName = wizardName
    builderStepIndex = 1
    builderOnSave = onSave

    local f = CreateBuilderFrame()
    f.TitleText:SetText(L["Building: "] .. (config.title or wizardName))
    f:Show()
    RenderBuilderStep()
end

-- Expose for use in Options.lua
function DF:ShowWizardBuilder(wizardName, onSave)
    WB:ShowBuilder(wizardName, onSave)
end

-- ============================================================
-- PAGE: MY WIZARDS (List + Management)
-- ============================================================

function WB:BuildListPage(GUI, page, db, Add, AddSpace, AddSyncPoint)
    local self = page

    -- Header
    Add(GUI:CreateHeader(self.child, L["Setup Wizards"]), 40, "both")
    Add(GUI:CreateLabel(self.child, L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."], 520), 40, "both")
    AddSpace(10, "both")

    -- === LEFT COLUMN: Wizard List ===
    local listLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    listLabel:SetText(L["My Wizards"])
    local listLabelFrame = CreateFrame("Frame", nil, self.child)
    listLabelFrame:SetSize(260, 20)
    listLabelFrame.text = listLabel
    listLabel:SetParent(listLabelFrame)
    listLabel:SetPoint("BOTTOMLEFT", 0, 0)
    Add(listLabelFrame, 20, 1)

    local isBuilding = false
    local wizardList = GUI:CreateSelectableList(self.child, 240, 200, function(item, index)
        if item and not isBuilding then
            editingWizardName = item.name
            page:Refresh()
        end
    end)
    Add(wizardList, 205, 1)

    -- Buttons row below list
    local btnRow = CreateFrame("Frame", nil, self.child)
    btnRow:SetSize(240, 26)

    local newBtn = GUI:CreateButton(btnRow, L["+ New"], 80, 24, function()
        -- Generate unique name
        local configs = GetWizardConfigs()
        local baseName = "New Wizard"
        local name = baseName
        local i = 2
        while configs[name] do
            name = baseName .. " " .. i
            i = i + 1
        end
        CreateNewWizard(name)
        editingWizardName = name
        page:Refresh()
    end)
    newBtn:SetPoint("TOPLEFT", 0, 0)

    local deleteBtn = GUI:CreateButton(btnRow, L["Delete"], 80, 24, function()
        if editingWizardName then
            DeleteWizardConfig(editingWizardName)
            editingWizardName = nil
            page:Refresh()
        end
    end)
    deleteBtn:SetPoint("LEFT", newBtn, "RIGHT", 4, 0)

    local importBtn = GUI:CreateButton(btnRow, L["Import"], 70, 24, function()
        -- Show import popup
        DF:ShowPopupAlert({
            title = L["Import Wizard"],
            message = L["Paste the wizard export string below:"],
            buttons = {
                {
                    label = L["Import"],
                    onClick = function()
                        -- Import handled via the editbox in a future iteration
                        -- For now, use a simple approach
                    end,
                },
                { label = L["Cancel"] },
            },
        })
    end)
    importBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 4, 0)

    Add(btnRow, 28, 1)

    -- === RIGHT COLUMN: Wizard Details ===
    local configs = GetWizardConfigs()
    local config = editingWizardName and configs[editingWizardName] or nil

    if config then
        local detailLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        detailLabel:SetText(L["Wizard Details"])
        local detailLabelFrame = CreateFrame("Frame", nil, self.child)
        detailLabelFrame:SetSize(260, 20)
        detailLabel:SetParent(detailLabelFrame)
        detailLabel:SetPoint("BOTTOMLEFT", 0, 0)
        Add(detailLabelFrame, 20, 2)

        local detailGroup = GUI:CreateSettingsGroup(self.child, 250)

        -- Name
        local nameFrame = CreateFrame("Frame", nil, detailGroup)
        nameFrame:SetSize(230, 44)
        local nameLabel = nameFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        nameLabel:SetPoint("TOPLEFT", 0, 0)
        nameLabel:SetText(L["Name"])
        nameLabel:SetTextColor(0.6, 0.6, 0.6)
        local nameEdit = CreateFrame("EditBox", nil, nameFrame, "BackdropTemplate")
        nameEdit:SetSize(230, 24)
        nameEdit:SetPoint("TOPLEFT", 0, -16)
        nameEdit:SetAutoFocus(false)
        nameEdit:SetFontObject(DFFontHighlightSmall)
        nameEdit:SetTextInsets(6, 6, 0, 0)
        if not nameEdit.SetBackdrop then Mixin(nameEdit, BackdropTemplateMixin) end
        nameEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        nameEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
        nameEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
        nameEdit:SetText(config.name or "")
        nameEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            local newName = self:GetText()
            if newName ~= "" and newName ~= editingWizardName then
                local oldName = editingWizardName
                config.name = newName
                config.title = newName
                config.modified = time()
                DeleteWizardConfig(oldName)
                SaveWizardConfig(newName, config)
                editingWizardName = newName
                page:Refresh()
            end
        end)
        nameEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        detailGroup:AddWidget(nameFrame, 48)

        -- Description
        local descFrame = CreateFrame("Frame", nil, detailGroup)
        descFrame:SetSize(230, 44)
        local descLabel = descFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        descLabel:SetPoint("TOPLEFT", 0, 0)
        descLabel:SetText(L["Description"])
        descLabel:SetTextColor(0.6, 0.6, 0.6)
        local descEdit = CreateFrame("EditBox", nil, descFrame, "BackdropTemplate")
        descEdit:SetSize(230, 24)
        descEdit:SetPoint("TOPLEFT", 0, -16)
        descEdit:SetAutoFocus(false)
        descEdit:SetFontObject(DFFontHighlightSmall)
        descEdit:SetTextInsets(6, 6, 0, 0)
        if not descEdit.SetBackdrop then Mixin(descEdit, BackdropTemplateMixin) end
        descEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        descEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
        descEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
        descEdit:SetText(config.description or "")
        descEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            config.description = self:GetText()
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
        end)
        descEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        detailGroup:AddWidget(descFrame, 48)

        Add(detailGroup, nil, 2)
        AddSpace(8, 2)

        -- Action buttons
        local editBtn = GUI:CreateIconButton(self.child, "edit", L["Edit Steps"], 160, 26, function()
            editingStepIndex = 1
            -- Navigate to editor tab
            if GUI.Tabs and GUI.Tabs["wizards_editor"] then
                GUI.Tabs["wizards_editor"]:Click()
            end
        end, 14)
        Add(editBtn, 30, 2)

        local previewBtn = GUI:CreateIconButton(self.child, "visibility", L["Preview"], 160, 26, function()
            local wizConfig = BuildWizardConfig(config)
            if wizConfig then
                DF:ShowPopupWizard(wizConfig)
            end
        end, 14)
        Add(previewBtn, 30, 2)

        local dupBtn = GUI:CreateIconButton(self.child, "content_copy", L["Duplicate"], 160, 26, function()
            local newName = config.name .. " (Copy)"
            local i = 2
            local allConfigs = GetWizardConfigs()
            while allConfigs[newName] do
                newName = config.name .. " (Copy " .. i .. ")"
                i = i + 1
            end
            local copy = DF:DeepCopy(config)
            copy.name = newName
            copy.title = newName
            copy.created = time()
            copy.modified = time()
            SaveWizardConfig(newName, copy)
            editingWizardName = newName
            page:Refresh()
        end, 14)
        Add(dupBtn, 30, 2)

        AddSpace(8, 2)

        -- Export button
        local exportBtn = GUI:CreateIconButton(self.child, "upload", L["Export"], 160, 26, function()
            local str, err = WB:ExportWizard(editingWizardName)
            if str then
                DF:ShowPopupAlert({
                    title = L["Export Wizard"],
                    message = L["Copy the string below to share this wizard:"] .. "\n\n" .. str:sub(1, 60) .. "...",
                    buttons = {
                        { label = L["OK"] },
                    },
                })
            else
                DF:DebugWarn("Export failed: " .. (err or "unknown"))
            end
        end, 14)
        Add(exportBtn, 30, 2)

    else
        -- No wizard selected
        local placeholder = self.child:CreateFontString(nil, "OVERLAY", "DFFontDisable")
        placeholder:SetText(L["Select or create a wizard"])
        local placeholderFrame = CreateFrame("Frame", nil, self.child)
        placeholderFrame:SetSize(260, 30)
        placeholder:SetParent(placeholderFrame)
        placeholder:SetPoint("CENTER")
        Add(placeholderFrame, 30, 2)
    end

    -- Populate the wizard list (guard against re-entrant refresh)
    local names = GetWizardNames()
    isBuilding = true
    wizardList:SetItems(names)
    if editingWizardName then
        for i, item in ipairs(names) do
            if item.name == editingWizardName then
                wizardList:SetSelected(i)
                break
            end
        end
    end
    isBuilding = false
end

-- ============================================================
-- PAGE: STEP EDITOR
-- ============================================================

function WB:BuildEditorPage(GUI, page, db, Add, AddSpace, AddSyncPoint)
    local self = page
    local configs = GetWizardConfigs()
    local config = editingWizardName and configs[editingWizardName] or nil

    if not config then
        Add(GUI:CreateHeader(self.child, L["Step Editor"]), 40, "both")
        Add(GUI:CreateLabel(self.child, L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."], 500), 30, "both")
        return
    end

    -- Header with wizard name
    Add(GUI:CreateHeader(self.child, format(L["Editing: %s"], (config.name or "?"))), 40, "both")

    -- Back button
    local backBtn = GUI:CreateIconButton(self.child, "chevron_right", L["Back to List"], 140, 24, function()
        if GUI.Tabs and GUI.Tabs["wizards_list"] then
            GUI.Tabs["wizards_list"]:Click()
        end
    end, 14)
    Add(backBtn, 28, "both")
    AddSpace(6, "both")

    -- === LEFT: Step List ===
    local stepListLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    stepListLabel:SetText(L["Steps"])
    local stepListLabelFrame = CreateFrame("Frame", nil, self.child)
    stepListLabelFrame:SetSize(170, 20)
    stepListLabel:SetParent(stepListLabelFrame)
    stepListLabel:SetPoint("BOTTOMLEFT", 0, 0)
    Add(stepListLabelFrame, 20, 1)

    local stepItems = {}
    for i, step in ipairs(config.steps) do
        tinsert(stepItems, { label = step.id or ("step" .. i), index = i })
    end

    local isEditorBuilding = false
    local stepList = GUI:CreateSelectableList(self.child, 170, 300, function(item, index)
        if item and not isEditorBuilding then
            editingStepIndex = item.index
            page:Refresh()
        end
    end)
    isEditorBuilding = true
    stepList:SetItems(stepItems)
    Add(stepList, 305, 1)

    -- Step management buttons
    local stepBtnRow = CreateFrame("Frame", nil, self.child)
    stepBtnRow:SetSize(170, 26)

    local addStepBtn = GUI:CreateButton(stepBtnRow, L["+ Add"], 50, 22, function()
        local newId = "step" .. (#config.steps + 1)
        -- Insert before summary if one exists
        local insertPos = #config.steps + 1
        for i, s in ipairs(config.steps) do
            if s.type == "summary" then
                insertPos = i
                break
            end
        end
        tinsert(config.steps, insertPos, {
            id = newId,
            question = L["New question"],
            description = "",
            type = "single",
            options = {
                { label = L["Option A"], value = "a" },
                { label = L["Option B"], value = "b" },
            },
        })
        config.modified = time()
        SaveWizardConfig(editingWizardName, config)
        editingStepIndex = insertPos
        page:Refresh()
    end)
    addStepBtn:SetPoint("TOPLEFT", 0, 0)

    local delStepBtn = GUI:CreateButton(stepBtnRow, L["Del"], 40, 22, function()
        if editingStepIndex and config.steps[editingStepIndex] then
            tremove(config.steps, editingStepIndex)
            if editingStepIndex > #config.steps then
                editingStepIndex = #config.steps > 0 and #config.steps or nil
            end
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
            page:Refresh()
        end
    end)
    delStepBtn:SetPoint("LEFT", addStepBtn, "RIGHT", 2, 0)

    local upBtn = GUI:CreateButton(stepBtnRow, "^", 28, 22, function()
        if editingStepIndex and editingStepIndex > 1 then
            local s = config.steps
            s[editingStepIndex], s[editingStepIndex - 1] = s[editingStepIndex - 1], s[editingStepIndex]
            editingStepIndex = editingStepIndex - 1
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
            page:Refresh()
        end
    end)
    upBtn:SetPoint("LEFT", delStepBtn, "RIGHT", 2, 0)

    local downBtn = GUI:CreateButton(stepBtnRow, "v", 28, 22, function()
        if editingStepIndex and editingStepIndex < #config.steps then
            local s = config.steps
            s[editingStepIndex], s[editingStepIndex + 1] = s[editingStepIndex + 1], s[editingStepIndex]
            editingStepIndex = editingStepIndex + 1
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
            page:Refresh()
        end
    end)
    downBtn:SetPoint("LEFT", upBtn, "RIGHT", 2, 0)

    Add(stepBtnRow, 28, 1)

    -- Set selection in step list
    if editingStepIndex then
        for i, item in ipairs(stepItems) do
            if item.index == editingStepIndex then
                stepList:SetSelected(i)
                break
            end
        end
    end
    isEditorBuilding = false

    -- === RIGHT: Step Properties ===
    local step = editingStepIndex and config.steps[editingStepIndex] or nil
    if not step then
        local noStepLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontDisable")
        noStepLabel:SetText(L["Select a step to edit"])
        local noStepFrame = CreateFrame("Frame", nil, self.child)
        noStepFrame:SetSize(340, 30)
        noStepLabel:SetParent(noStepFrame)
        noStepLabel:SetPoint("CENTER")
        Add(noStepFrame, 30, 2)
        return
    end

    -- Step Properties Group
    local propsGroup = GUI:CreateSettingsGroup(self.child, 340)

    -- Step ID
    local idFrame = CreateFrame("Frame", nil, propsGroup)
    idFrame:SetSize(320, 44)
    local idLabel = idFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    idLabel:SetPoint("TOPLEFT", 0, 0)
    idLabel:SetText(L["Step ID"])
    idLabel:SetTextColor(0.6, 0.6, 0.6)
    local idEdit = CreateFrame("EditBox", nil, idFrame, "BackdropTemplate")
    idEdit:SetSize(320, 24)
    idEdit:SetPoint("TOPLEFT", 0, -16)
    idEdit:SetAutoFocus(false)
    idEdit:SetFontObject(DFFontHighlightSmall)
    idEdit:SetTextInsets(6, 6, 0, 0)
    if not idEdit.SetBackdrop then Mixin(idEdit, BackdropTemplateMixin) end
    idEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    idEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
    idEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
    idEdit:SetText(step.id or "")
    idEdit:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local newId = self:GetText():gsub("%s+", "_"):lower()
        if newId ~= "" then
            -- Update references in other steps
            local oldId = step.id
            for _, s in ipairs(config.steps) do
                if s.next == oldId then s.next = newId end
                if s.branches then
                    for _, b in ipairs(s.branches) do
                        if b["goto"] == oldId then b["goto"] = newId end
                        if b.condition and b.condition.step == oldId then b.condition.step = newId end
                    end
                end
            end
            step.id = newId
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
            page:Refresh()
        end
    end)
    idEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    propsGroup:AddWidget(idFrame, 48)

    -- Question (not for summary type)
    if step.type ~= "summary" then
        local qFrame = CreateFrame("Frame", nil, propsGroup)
        qFrame:SetSize(320, 44)
        local qLabel = qFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        qLabel:SetPoint("TOPLEFT", 0, 0)
        qLabel:SetText(L["Question"])
        qLabel:SetTextColor(0.6, 0.6, 0.6)
        local qEdit = CreateFrame("EditBox", nil, qFrame, "BackdropTemplate")
        qEdit:SetSize(320, 24)
        qEdit:SetPoint("TOPLEFT", 0, -16)
        qEdit:SetAutoFocus(false)
        qEdit:SetFontObject(DFFontHighlightSmall)
        qEdit:SetTextInsets(6, 6, 0, 0)
        if not qEdit.SetBackdrop then Mixin(qEdit, BackdropTemplateMixin) end
        qEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        qEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
        qEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
        qEdit:SetText(step.question or "")
        qEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            step.question = self:GetText()
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
        end)
        qEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        propsGroup:AddWidget(qFrame, 48)

        -- Description
        local dFrame = CreateFrame("Frame", nil, propsGroup)
        dFrame:SetSize(320, 44)
        local dLabel = dFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        dLabel:SetPoint("TOPLEFT", 0, 0)
        dLabel:SetText(L["Description (optional)"])
        dLabel:SetTextColor(0.6, 0.6, 0.6)
        local dEdit = CreateFrame("EditBox", nil, dFrame, "BackdropTemplate")
        dEdit:SetSize(320, 24)
        dEdit:SetPoint("TOPLEFT", 0, -16)
        dEdit:SetAutoFocus(false)
        dEdit:SetFontObject(DFFontHighlightSmall)
        dEdit:SetTextInsets(6, 6, 0, 0)
        if not dEdit.SetBackdrop then Mixin(dEdit, BackdropTemplateMixin) end
        dEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        dEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
        dEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
        dEdit:SetText(step.description or "")
        dEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            step.description = self:GetText()
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
        end)
        dEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        propsGroup:AddWidget(dFrame, 48)
    end

    -- Step Type dropdown
    local typeOptions = {
        single = L["Single Select"],
        multi = L["Multi Select"],
        summary = L["Summary"],
    }
    local typeOrder = { "single", "multi", "summary" }

    local typeFrame = CreateFrame("Frame", nil, propsGroup)
    typeFrame:SetSize(320, 50)
    local typeLabel = typeFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    typeLabel:SetPoint("TOPLEFT", 0, 0)
    typeLabel:SetText(L["Type"])
    typeLabel:SetTextColor(0.6, 0.6, 0.6)

    local typeBtn = CreateFrame("Button", nil, typeFrame, "BackdropTemplate")
    typeBtn:SetSize(200, 24)
    typeBtn:SetPoint("TOPLEFT", 0, -16)
    if not typeBtn.SetBackdrop then Mixin(typeBtn, BackdropTemplateMixin) end
    typeBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    typeBtn:SetBackdropColor(0.18, 0.18, 0.18, 1)
    typeBtn:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
    typeBtn.Text = typeBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    typeBtn.Text:SetPoint("LEFT", 6, 0)
    typeBtn.Text:SetText(typeOptions[step.type] or step.type or "single")

    local typeMenu = CreateFrame("Frame", nil, typeBtn, "BackdropTemplate")
    typeMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    typeMenu:SetFrameLevel(300)
    typeMenu:SetWidth(200)
    if not typeMenu.SetBackdrop then Mixin(typeMenu, BackdropTemplateMixin) end
    typeMenu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    typeMenu:SetBackdropColor(0.12, 0.12, 0.12, 1)
    typeMenu:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    typeMenu:SetPoint("TOP", typeBtn, "BOTTOM", 0, -1)
    typeMenu:Hide()
    typeMenu:EnableMouse(true)

    local y = 0
    for _, key in ipairs(typeOrder) do
        local optBtn = CreateFrame("Button", nil, typeMenu, "BackdropTemplate")
        optBtn:SetHeight(22)
        optBtn:SetPoint("TOPLEFT", 2, -y)
        optBtn:SetPoint("TOPRIGHT", -2, -y)
        optBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
        optBtn:SetBackdropColor(0, 0, 0, 0)
        local optLabel = optBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        optLabel:SetPoint("LEFT", 6, 0)
        optLabel:SetText(typeOptions[key])
        optBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.22, 0.22, 0.22, 1) end)
        optBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0, 0, 0, 0) end)
        optBtn:SetScript("OnClick", function()
            step.type = key
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
            typeMenu:Hide()
            page:Refresh()
        end)
        y = y + 22
    end
    typeMenu:SetHeight(y + 4)

    typeBtn:SetScript("OnClick", function()
        if typeMenu:IsShown() then typeMenu:Hide() else typeMenu:Show() end
    end)
    typeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.22, 0.22, 0.22, 1) end)
    typeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.18, 0.18, 0.18, 1) end)

    propsGroup:AddWidget(typeFrame, 50)
    Add(propsGroup, nil, 2)
    AddSpace(8, 2)

    -- === INTEGRATION SECTION ===
    if step.type ~= "summary" then
        local intGroup = GUI:CreateSettingsGroup(self.child, 340)

        -- Integration header
        local intHeader = intGroup:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        intHeader:SetText(L["Integration"])
        local intHeaderFrame = CreateFrame("Frame", nil, intGroup)
        intHeaderFrame:SetSize(320, 18)
        intHeader:SetParent(intHeaderFrame)
        intHeader:SetPoint("BOTTOMLEFT", 0, 0)
        intGroup:AddWidget(intHeaderFrame, 18)

        -- Test Mode dropdown
        local testModeOpts = { [""] = L["Off"], party = L["Party"], raid = L["Raid"] }
        local testModeFrame = CreateFrame("Frame", nil, intGroup)
        testModeFrame:SetSize(320, 50)
        local tmLabel = testModeFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        tmLabel:SetPoint("TOPLEFT", 0, 0)
        tmLabel:SetText(L["Test Mode"])
        tmLabel:SetTextColor(0.6, 0.6, 0.6)

        local tmBtn = CreateFrame("Button", nil, testModeFrame, "BackdropTemplate")
        tmBtn:SetSize(150, 24)
        tmBtn:SetPoint("TOPLEFT", 0, -16)
        if not tmBtn.SetBackdrop then Mixin(tmBtn, BackdropTemplateMixin) end
        tmBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        tmBtn:SetBackdropColor(0.18, 0.18, 0.18, 1)
        tmBtn:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
        tmBtn.Text = tmBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        tmBtn.Text:SetPoint("LEFT", 6, 0)
        tmBtn.Text:SetText(testModeOpts[step.testMode or ""] or L["Off"])

        local tmMenu = CreateFrame("Frame", nil, tmBtn, "BackdropTemplate")
        tmMenu:SetFrameStrata("FULLSCREEN_DIALOG")
        tmMenu:SetFrameLevel(300)
        tmMenu:SetWidth(150)
        if not tmMenu.SetBackdrop then Mixin(tmMenu, BackdropTemplateMixin) end
        tmMenu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        tmMenu:SetBackdropColor(0.12, 0.12, 0.12, 1)
        tmMenu:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        tmMenu:SetPoint("TOP", tmBtn, "BOTTOM", 0, -1)
        tmMenu:Hide()
        tmMenu:EnableMouse(true)

        local tmY = 0
        for _, pair in ipairs({ {"", L["Off"]}, {"party", L["Party"]}, {"raid", L["Raid"]} }) do
            local tmOptBtn = CreateFrame("Button", nil, tmMenu, "BackdropTemplate")
            tmOptBtn:SetHeight(22)
            tmOptBtn:SetPoint("TOPLEFT", 2, -tmY)
            tmOptBtn:SetPoint("TOPRIGHT", -2, -tmY)
            tmOptBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
            tmOptBtn:SetBackdropColor(0, 0, 0, 0)
            local tmOptLabel = tmOptBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            tmOptLabel:SetPoint("LEFT", 6, 0)
            tmOptLabel:SetText(pair[2])
            tmOptBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.22, 0.22, 0.22, 1) end)
            tmOptBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0, 0, 0, 0) end)
            tmOptBtn:SetScript("OnClick", function()
                step.testMode = pair[1] ~= "" and pair[1] or nil
                config.modified = time()
                SaveWizardConfig(editingWizardName, config)
                tmMenu:Hide()
                tmBtn.Text:SetText(pair[2])
            end)
            tmY = tmY + 22
        end
        tmMenu:SetHeight(tmY + 4)
        tmBtn:SetScript("OnClick", function() if tmMenu:IsShown() then tmMenu:Hide() else tmMenu:Show() end end)
        tmBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.22, 0.22, 0.22, 1) end)
        tmBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.18, 0.18, 0.18, 1) end)

        intGroup:AddWidget(testModeFrame, 50)

        -- Open Tab
        local openTabFrame = CreateFrame("Frame", nil, intGroup)
        openTabFrame:SetSize(320, 44)
        local otLabel = openTabFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        otLabel:SetPoint("TOPLEFT", 0, 0)
        otLabel:SetText(L["Open Settings Tab"])
        otLabel:SetTextColor(0.6, 0.6, 0.6)
        local otEdit = CreateFrame("EditBox", nil, openTabFrame, "BackdropTemplate")
        otEdit:SetSize(320, 24)
        otEdit:SetPoint("TOPLEFT", 0, -16)
        otEdit:SetAutoFocus(false)
        otEdit:SetFontObject(DFFontHighlightSmall)
        otEdit:SetTextInsets(6, 6, 0, 0)
        if not otEdit.SetBackdrop then Mixin(otEdit, BackdropTemplateMixin) end
        otEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        otEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
        otEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
        otEdit:SetText(step.openTab or "")
        otEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            local val = self:GetText()
            step.openTab = val ~= "" and val or nil
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
        end)
        otEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        intGroup:AddWidget(openTabFrame, 48)

        -- Highlight Settings
        local hsFrame = CreateFrame("Frame", nil, intGroup)
        hsFrame:SetSize(320, 44)
        local hsLabel = hsFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        hsLabel:SetPoint("TOPLEFT", 0, 0)
        hsLabel:SetText(L["Highlight Settings (comma-separated dbKeys)"])
        hsLabel:SetTextColor(0.6, 0.6, 0.6)
        local hsEdit = CreateFrame("EditBox", nil, hsFrame, "BackdropTemplate")
        hsEdit:SetSize(320, 24)
        hsEdit:SetPoint("TOPLEFT", 0, -16)
        hsEdit:SetAutoFocus(false)
        hsEdit:SetFontObject(DFFontHighlightSmall)
        hsEdit:SetTextInsets(6, 6, 0, 0)
        if not hsEdit.SetBackdrop then Mixin(hsEdit, BackdropTemplateMixin) end
        hsEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        hsEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
        hsEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)

        -- Convert table to comma string for editing
        local hsStr = ""
        if step.highlightSettings and type(step.highlightSettings) == "table" then
            hsStr = table.concat(step.highlightSettings, ", ")
        end
        hsEdit:SetText(hsStr)
        hsEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            local val = self:GetText()
            if val == "" then
                step.highlightSettings = nil
            else
                step.highlightSettings = {}
                for key in val:gmatch("[^,]+") do
                    key = key:match("^%s*(.-)%s*$")  -- trim
                    if key ~= "" then
                        tinsert(step.highlightSettings, key)
                    end
                end
            end
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
        end)
        hsEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        intGroup:AddWidget(hsFrame, 48)

        Add(intGroup, nil, 2)
        AddSpace(8, 2)
    end

    -- === OPTIONS SECTION ===
    if step.type == "single" or step.type == "multi" then
        local optGroup = GUI:CreateSettingsGroup(self.child, 340)

        local optHeader = optGroup:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        optHeader:SetText(L["Options"])
        local optHeaderFrame = CreateFrame("Frame", nil, optGroup)
        optHeaderFrame:SetSize(320, 18)
        optHeader:SetParent(optHeaderFrame)
        optHeader:SetPoint("BOTTOMLEFT", 0, 0)
        optGroup:AddWidget(optHeaderFrame, 18)

        step.options = step.options or {}

        for i, opt in ipairs(step.options) do
            local optRow = CreateFrame("Frame", nil, optGroup)
            optRow:SetSize(320, 50)

            -- Label
            local olLabel = optRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            olLabel:SetPoint("TOPLEFT", 0, 0)
            olLabel:SetText(L["Label:"])
            olLabel:SetTextColor(0.6, 0.6, 0.6)
            local olEdit = CreateFrame("EditBox", nil, optRow, "BackdropTemplate")
            olEdit:SetSize(130, 22)
            olEdit:SetPoint("LEFT", olLabel, "RIGHT", 4, 0)
            olEdit:SetAutoFocus(false)
            olEdit:SetFontObject(DFFontHighlightSmall)
            olEdit:SetTextInsets(4, 4, 0, 0)
            if not olEdit.SetBackdrop then Mixin(olEdit, BackdropTemplateMixin) end
            olEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            olEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
            olEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
            olEdit:SetText(opt.label or "")
            olEdit:SetScript("OnEnterPressed", function(self)
                self:ClearFocus()
                opt.label = self:GetText()
                config.modified = time()
                SaveWizardConfig(editingWizardName, config)
            end)
            olEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            -- Value
            local ovLabel = optRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            ovLabel:SetPoint("TOPLEFT", 0, -24)
            ovLabel:SetText(L["Value:"])
            ovLabel:SetTextColor(0.6, 0.6, 0.6)
            local ovEdit = CreateFrame("EditBox", nil, optRow, "BackdropTemplate")
            ovEdit:SetSize(130, 22)
            ovEdit:SetPoint("LEFT", ovLabel, "RIGHT", 4, -0)
            ovEdit:SetAutoFocus(false)
            ovEdit:SetFontObject(DFFontHighlightSmall)
            ovEdit:SetTextInsets(4, 4, 0, 0)
            if not ovEdit.SetBackdrop then Mixin(ovEdit, BackdropTemplateMixin) end
            ovEdit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
            ovEdit:SetBackdropColor(0.18, 0.18, 0.18, 1)
            ovEdit:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.5)
            ovEdit:SetText(opt.value or "")
            ovEdit:SetScript("OnEnterPressed", function(self)
                self:ClearFocus()
                opt.value = self:GetText()
                config.modified = time()
                SaveWizardConfig(editingWizardName, config)
            end)
            ovEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            -- Delete option button
            local delOptBtn = GUI:CreateButton(optRow, "X", 22, 22, function()
                tremove(step.options, i)
                config.modified = time()
                SaveWizardConfig(editingWizardName, config)
                page:Refresh()
            end)
            delOptBtn:SetPoint("TOPRIGHT", 0, 0)

            optGroup:AddWidget(optRow, 52)
        end

        -- Add Option button
        local addOptBtnFrame = CreateFrame("Frame", nil, optGroup)
        addOptBtnFrame:SetSize(320, 26)
        local addOptBtn = GUI:CreateButton(addOptBtnFrame, L["+ Add Option"], 120, 22, function()
            tinsert(step.options, { label = L["New Option"], value = "new" .. (#step.options + 1) })
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
            page:Refresh()
        end)
        addOptBtn:SetPoint("TOPLEFT", 0, 0)
        optGroup:AddWidget(addOptBtnFrame, 26)

        Add(optGroup, nil, 2)
        AddSpace(8, 2)
    end

    -- === BRANCHING RULES SECTION ===
    if step.type ~= "summary" then
        local branchLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        branchLabel:SetText(L["Branching Rules"])
        local branchLabelFrame = CreateFrame("Frame", nil, self.child)
        branchLabelFrame:SetSize(340, 18)
        branchLabel:SetParent(branchLabelFrame)
        branchLabel:SetPoint("BOTTOMLEFT", 0, 0)
        Add(branchLabelFrame, 22, 2)

        -- Build step options for dropdowns
        local stepOpts = {}
        for _, s in ipairs(config.steps) do
            tinsert(stepOpts, { value = s.id, text = s.id })
        end

        local branchEditor = GUI:CreateBranchEditor(self.child, 340, function(newBranches, newFallback)
            step.branches = #newBranches > 0 and newBranches or nil
            step.next = newFallback
            config.modified = time()
            SaveWizardConfig(editingWizardName, config)
        end)
        branchEditor:SetStepOptions(stepOpts)
        branchEditor:SetData(step.branches or {}, step.next)
        Add(branchEditor, branchEditor:GetHeight() + 10, 2)
        AddSpace(8, 2)
    end

    -- === SETTINGS MAP SECTION ===
    if step.type == "single" or step.type == "multi" then
        local smLabel = self.child:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        smLabel:SetText(L["Settings to Apply"])
        local smLabelFrame = CreateFrame("Frame", nil, self.child)
        smLabelFrame:SetSize(340, 18)
        smLabel:SetParent(smLabelFrame)
        smLabel:SetPoint("BOTTOMLEFT", 0, 0)
        Add(smLabelFrame, 22, 2)

        config.settingsMap = config.settingsMap or {}
        config.settingsMap[step.id] = config.settingsMap[step.id] or {}

        for _, opt in ipairs(step.options or {}) do
            -- Sub-header for this option value
            local subHeaderFrame = CreateFrame("Frame", nil, self.child)
            subHeaderFrame:SetSize(340, 20)
            local subHeader = subHeaderFrame:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            subHeader:SetPoint("BOTTOMLEFT", 0, 0)
            subHeader:SetText(format(L["When \"%s\" selected:"], (opt.label or opt.value or "?")))
            subHeader:SetTextColor(0.7, 0.7, 0.7)
            Add(subHeaderFrame, 22, 2)

            local optValue = opt.value
            local existingData = config.settingsMap[step.id] and config.settingsMap[step.id][optValue] or {}

            local kvEditor = GUI:CreateKeyValueEditor(self.child, 340, GetDBKeyOptions, function(newData)
                if not config.settingsMap[step.id] then config.settingsMap[step.id] = {} end
                config.settingsMap[step.id][optValue] = newData
                config.modified = time()
                SaveWizardConfig(editingWizardName, config)
            end)
            kvEditor:SetData(existingData)
            Add(kvEditor, kvEditor:GetHeight() + 10, 2)
        end
    end
end

-- ============================================================
-- MODULE EXPORTS
-- ============================================================

-- Expose BuildWizardConfig for Options.lua
WB.BuildWizardConfig = BuildWizardConfig

-- Built-in wizard registry
-- Each entry: { name, description, build = function() return wizard config end }
local builtinWizards = {}

function WB:RegisterBuiltinWizard(entry)
    tinsert(builtinWizards, entry)
end

function WB:GetBuiltinWizards()
    return builtinWizards
end

-- ============================================================
-- BUILT-IN WIZARD: Aura Filter Setup
-- ============================================================

WB:RegisterBuiltinWizard({
    name = "Aura Filter Setup",
    description = L["Guided setup for configuring which buffs and debuffs appear on your frames."],
    build = function()
        -- All the Direct API filter keys to highlight when user wants to configure themselves
        local directFilterKeys = {
            "directBuffShowAll", "directBuffOnlyMine",
            "directBuffFilterRaid", "directBuffFilterRaidInCombat",
            "directBuffFilterCancelable", "directBuffFilterNotCancelable",
            "directBuffFilterImportant", "directBuffFilterBigDefensive",
            "directBuffFilterExternalDefensive", "directBuffSortOrder",
            "directDebuffShowAll", "directDebuffFilterRaid",
            "directDebuffFilterRaidInCombat", "directDebuffFilterCrowdControl",
            "directDebuffFilterImportant",
            "directDebuffDispellableMode",
            "directDebuffSortOrder",
        }

        return {
            title = L["Aura Filter Setup"],
            width = 480,
            steps = {
                {
                    id = "welcome",
                    question = L["Would you like to set up your aura filters?"],
                    description = L["• Having trouble seeing certain buffs or debuffs?\n• This wizard helps you pick the right aura settings"],
                    type = "single",
                    options = {
                        { label = L["Yes, set it up"], value = "yes" },
                        { label = L["No thanks"], value = "no" },
                    },
                    branches = {
                        { condition = { equals = "no" }, ["goto"] = "cancel" },
                    },
                    next = "source",
                },
                {
                    id = "source",
                    question = L["Which aura data source would you like to use?"],
                    type = "single",
                    options = {
                        {
                            label = L["Blizzard"],
                            value = "blizzard",
                        },
                        {
                            label = L["Direct API"],
                            value = "direct",
                        },
                    },
                    description = L["Blizzard:\n• Mirrors the buffs/debuffs from default Blizzard frames\n• Requires Blizzard raid settings to be configured correctly\n• Slightly more performance heavy in large groups\n\nDirect API:\n• Gives you control over what shows on your frames\n• Some filters may miss certain buffs/debuffs\n• Others might show unwanted ones\n• Can be fine-tuned for best results"],
                    branches = {
                        { condition = { equals = "blizzard" }, ["goto"] = "summary" },
                    },
                    next = "direct_config",
                },
                {
                    id = "direct_config",
                    question = L["How would you like to configure the filters?"],
                    description = L["• Recommended defaults work well for most players\n• Manual lets you fine-tune every filter option"],
                    type = "single",
                    options = {
                        { label = L["Use recommended defaults"], value = "defaults" },
                        { label = L["Let me configure it myself"], value = "manual" },
                    },
                    next = "summary",
                },
                {
                    id = "cancel",
                    type = "summary",
                },
                {
                    id = "summary",
                    type = "summary",
                },
            },
            settingsMap = {
                source = {
                    blizzard = {
                        ["party.auraSourceMode"] = "BLIZZARD",
                        ["raid.auraSourceMode"] = "BLIZZARD",
                    },
                    direct = {
                        ["party.auraSourceMode"] = "DIRECT",
                        ["raid.auraSourceMode"] = "DIRECT",
                    },
                },
                direct_config = {
                    defaults = {
                        ["party.auraSourceMode"] = "DIRECT",
                        ["raid.auraSourceMode"] = "DIRECT",
                        -- Buff defaults
                        ["party.directBuffShowAll"] = false,
                        ["party.directBuffOnlyMine"] = true,
                        ["party.directBuffFilterRaid"] = true,
                        ["party.directBuffFilterRaidInCombat"] = true,
                        ["party.directBuffFilterCancelable"] = false,
                        ["party.directBuffFilterNotCancelable"] = false,
                        ["party.directBuffFilterImportant"] = true,
                        ["party.directBuffFilterBigDefensive"] = true,
                        ["party.directBuffFilterExternalDefensive"] = true,
                        ["party.directBuffSortOrder"] = "TIME",
                        -- Debuff defaults
                        ["party.directDebuffShowAll"] = true,
                        ["party.directDebuffFilterRaid"] = true,
                        ["party.directDebuffFilterRaidInCombat"] = true,
                        ["party.directDebuffFilterCrowdControl"] = true,
                        ["party.directDebuffFilterImportant"] = true,
                        ["party.directDebuffDispellableMode"] = "PLAYER",
                        ["party.directDebuffSortOrder"] = "TIME",
                        -- Same for raid
                        ["raid.directBuffShowAll"] = false,
                        ["raid.directBuffOnlyMine"] = true,
                        ["raid.directBuffFilterRaid"] = true,
                        ["raid.directBuffFilterRaidInCombat"] = true,
                        ["raid.directBuffFilterCancelable"] = false,
                        ["raid.directBuffFilterNotCancelable"] = false,
                        ["raid.directBuffFilterImportant"] = true,
                        ["raid.directBuffFilterBigDefensive"] = true,
                        ["raid.directBuffFilterExternalDefensive"] = true,
                        ["raid.directBuffSortOrder"] = "TIME",
                        ["raid.directDebuffShowAll"] = true,
                        ["raid.directDebuffFilterRaid"] = true,
                        ["raid.directDebuffFilterRaidInCombat"] = true,
                        ["raid.directDebuffFilterCrowdControl"] = true,
                        ["raid.directDebuffFilterImportant"] = true,
                        ["raid.directDebuffDispellableMode"] = "PLAYER",
                        ["raid.directDebuffSortOrder"] = "TIME",
                    },
                    manual = {
                        ["party.auraSourceMode"] = "DIRECT",
                        ["raid.auraSourceMode"] = "DIRECT",
                    },
                },
            },
            onComplete = function(answers)
                -- If user chose manual config, open the aura filters tab and highlight settings
                if answers.direct_config == "manual" then
                    C_Timer.After(0.2, function()
                        -- Open GUI if not already open (don't toggle closed)
                        local guiAlreadyOpen = DF.GUIFrame and DF.GUIFrame:IsShown()
                        if not guiAlreadyOpen then
                            if DF.ToggleGUI then DF:ToggleGUI() end
                        end
                        C_Timer.After(0.3, function()
                            -- Switch to aura filters tab
                            if DF.GUI and DF.GUI.Tabs and DF.GUI.Tabs["auras_filters"] then
                                DF.GUI.Tabs["auras_filters"]:Click()
                            end
                            -- Refresh the page so settings reflect changes
                            if DF.GUI and DF.GUI.RefreshCurrentPage then
                                DF.GUI.RefreshCurrentPage()
                            end
                            C_Timer.After(0.3, function()
                                DF:HighlightSettings("auras_filters", directFilterKeys)
                            end)
                        end)
                    end)
                end
                -- Rebuild aura filters after settings change
                if DF.RebuildDirectFilterStrings then
                    DF:RebuildDirectFilterStrings()
                end
                if DF.SetAuraSourceMode then
                    local mode = DF.db and DF.db.party and DF.db.party.auraSourceMode
                    if mode then DF:SetAuraSourceMode(mode) end
                end
                DF:Debug("Aura Filter Setup wizard completed")
            end,
            onCancel = function()
                DF:Debug("Aura Filter Setup wizard cancelled")
            end,
        }
    end,
})

-- Import wizard via slash command
function WB:HandleImportCommand(str)
    local data, err = self:ImportWizard(str)
    if not data then
        print("|cffff0000DandersFrames:|r Import failed: " .. (err or "unknown"))
        return
    end
    local name = data.name or "Imported Wizard"
    -- Avoid overwriting existing
    local configs = GetWizardConfigs()
    if configs[name] then
        local counter = 1
        while configs[name .. " " .. counter] do counter = counter + 1 end
        name = name .. " " .. counter
        data.name = name
    end
    SaveWizardConfig(name, data)
    print("|cff00ff00DandersFrames:|r Imported wizard '" .. name .. "' successfully!")
end
