---@diagnostic disable

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable
local L = _G.PreydatorL or setmetatable({}, { __index = function(_, k) return k end })

local SettingsModule = {}
Preydator:RegisterModule("Settings", SettingsModule)

local api = Preydator.API
local constants = Preydator.Constants

local Settings = _G.Settings
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local InCombatLockdown = _G.InCombatLockdown
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton
local ColorPickerFrame = _G.ColorPickerFrame
local OpacitySliderFrame = _G.OpacitySliderFrame
local C_CurrencyInfo = _G.C_CurrencyInfo

local function ApplyDropdownListScale(level, dropDownFrame)
    if not dropDownFrame or not dropDownFrame.GetEffectiveScale then
        return
    end

    local listFrame = _G["DropDownList" .. tostring(level or 1)]
    if not listFrame or not listFrame.SetScale then
        return
    end

    local uiScale = (UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()) or 1
    if uiScale <= 0 then
        uiScale = 1
    end

    local desiredScale = dropDownFrame:GetEffectiveScale() / uiScale
    listFrame:SetScale(desiredScale)
end

local function ApplyDropdownListLimit(maxScrollItems)
    if type(maxScrollItems) ~= "number" or maxScrollItems <= 0 then
        return
    end

    local listFrame = _G.DropDownList1
    if not listFrame then
        return
    end

    listFrame.maxScrollItems = math.floor(maxScrollItems)
end

local function BindDropdownScale(dropdown, maxScrollItems)
    if not dropdown or dropdown.PreydatorScaleHookBound then
        return
    end

    local button = dropdown.Button
    if not button then
        return
    end

    dropdown.PreydatorScaleHookBound = true
    button:HookScript("OnClick", function()
        local timer = _G.C_Timer
        if timer and type(timer.After) == "function" then
            timer.After(0, function()
                ApplyDropdownListLimit(maxScrollItems)
                ApplyDropdownListScale(1, dropdown)
            end)
            return
        end

        ApplyDropdownListLimit(maxScrollItems)
        ApplyDropdownListScale(1, dropdown)
    end)
end

local COLUMN_LEFT_X = 5
local COLUMN_RIGHT_X = 221
local COLUMN_FAR_RIGHT_X = COLUMN_RIGHT_X + (COLUMN_RIGHT_X - COLUMN_LEFT_X)
local CONTROL_WIDTH = 250
local TAB_WIDTH = 101
local PANEL_WIDTH = 760
local PANEL_HEIGHT = 620

local DEFAULT_SLIDER_WIDTH = 170
local DEFAULT_SLIDER_SCALE = 1
local DEFAULT_SLIDER_VALUEBOX_WIDTH = 56
local DEFAULT_SLIDER_VALUEBOX_HEIGHT = 20

local pendingOpenOptionsAfterCombat = false

local TEXTURE_OPTIONS = {
    default = { text = L["Default"] },
    flat = { text = L["Flat"] },
    raid = { text = L["Raid HP Fill"] },
    classic = { text = L["Classic Skill Bar"] },
}

local FONT_OPTIONS = {
    frizqt = { text = L["Friz Quadrata"] },
    arialn = { text = L["Arial Narrow"] },
    skurri = { text = L["Skurri"] },
    morpheus = { text = L["Morpheus"] },
}

local CHANNEL_OPTIONS = {
    Master = { text = L["Master"] },
    SFX = { text = L["SFX"] },
    Dialog = { text = L["Dialog"] },
    Ambience = { text = L["Ambience"] },
    Music = { text = L["Music"] },
}

local BAR_ACCESSIBILITY_OPTIONS = {
    default = { text = L["Default"] },
    deuteranopia = { text = L["Deuteranopia"] },
    protanopia = { text = L["Protanopia"] },
}

local BAR_ACCESSIBILITY_PRESETS = {
    deuteranopia = {
        fillColor = { 0.90, 0.60, 0.10, 1.00 },
        borderColor = { 0.90, 0.60, 0.10, 1.00 },
        titleColor = { 1.00, 0.74, 0.00, 1.00 },
        percentColor = { 1.00, 1.00, 1.00, 1.00 },
        tickColor = { 0.65, 0.68, 0.84, 1.00 },
        bgColor = { 0.06, 0.07, 0.14, 0.88 },
        borderColorLinked = false,
    },
    protanopia = {
        fillColor = { 0.00, 0.72, 0.82, 1.00 },
        borderColor = { 0.00, 0.72, 0.82, 1.00 },
        titleColor = { 0.00, 0.88, 1.00, 1.00 },
        percentColor = { 1.00, 1.00, 1.00, 1.00 },
        tickColor = { 0.50, 0.74, 0.80, 1.00 },
        bgColor = { 0.03, 0.10, 0.13, 0.88 },
        borderColorLinked = false,
    },
}

-- Ordered theme options including built-in presets + any user-saved custom themes
local function GetAllThemeOptions()
    local db = api.GetSettings()
    local opts = {
        { key = "brown",        text = L["Brown"] },
        { key = "light",        text = L["Light"] },
        { key = "dark",         text = L["Dark"] },
        { key = "deuteranopia", text = L["Deuteranopia"] },
        { key = "protanopia",   text = L["Protanopia"] },
    }
    if db and type(db.customThemeOrder) == "table" then
        for _, name in ipairs(db.customThemeOrder) do
            if db.customThemes and db.customThemes[name] then
                opts[#opts + 1] = { key = name, text = name }
            end
        end
    end
    return opts
end

-- Built-in preset colors mirrored here for the custom theme editor's "Load from Preset" feature
local THEME_EDITOR_PRESETS = {
    brown        = { section={0.08,0.06,0.03,0.92}, row={0.14,0.11,0.06,0.92}, rowAlt={0.10,0.08,0.05,0.92}, border={0.78,0.62,0.20,0.95}, header={0.21,0.15,0.06,1.00}, title={1.00,0.82,0.00,1.00}, text={1.00,1.00,1.00,1.00}, muted={0.74,0.70,0.60,1.00}, season={0.60,0.80,1.00,1.00}, fontKey="frizqt" },
    light        = { section={0.87,0.84,0.79,0.94}, row={0.95,0.93,0.90,0.95}, rowAlt={0.90,0.87,0.83,0.95}, border={0.27,0.24,0.19,1.00}, header={0.78,0.72,0.64,0.96}, title={0.12,0.10,0.08,1.00}, text={0.10,0.09,0.07,1.00}, muted={0.28,0.25,0.21,1.00}, season={0.13,0.34,0.67,1.00}, fontKey="frizqt" },
    dark         = { section={0.07,0.07,0.09,0.92}, row={0.14,0.14,0.16,0.92}, rowAlt={0.11,0.11,0.13,0.92}, border={0.30,0.30,0.35,0.90}, header={0.18,0.18,0.22,1.00}, title={1.00,0.82,0.00,1.00}, text={1.00,1.00,1.00,1.00}, muted={0.65,0.65,0.70,1.00}, season={0.60,0.80,1.00,1.00}, fontKey="frizqt" },
    deuteranopia = { section={0.06,0.07,0.14,0.92}, row={0.10,0.12,0.22,0.92}, rowAlt={0.08,0.09,0.17,0.92}, border={0.90,0.60,0.10,0.95}, header={0.14,0.16,0.30,1.00}, title={1.00,0.74,0.00,1.00}, text={1.00,1.00,1.00,1.00}, muted={0.65,0.68,0.84,1.00}, season={0.35,0.65,1.00,1.00}, fontKey="frizqt" },
    protanopia   = { section={0.03,0.10,0.13,0.92}, row={0.06,0.16,0.20,0.92}, rowAlt={0.04,0.12,0.16,0.92}, border={0.00,0.72,0.82,0.95}, header={0.08,0.20,0.26,1.00}, title={0.00,0.88,1.00,1.00}, text={1.00,1.00,1.00,1.00}, muted={0.50,0.74,0.80,1.00}, season={1.00,0.86,0.00,1.00}, fontKey="frizqt" },
}

local THEME_COLOR_KEYS = { "section", "row", "rowAlt", "border", "header", "title", "text", "muted", "season" }

local HUNT_PANEL_SIDE_OPTIONS = {
    left = { text = L["Left"] },
    right = { text = L["Right"] },
}

local HUNT_GROUP_OPTIONS = {
    none = { text = L["None"] },
    difficulty = { text = L["Difficulty"] },
    zone = { text = L["Zone"] },
}

local HUNT_SORT_OPTIONS = {
    difficulty = { text = L["Difficulty"] },
    zone = { text = L["Zone"] },
    title = { text = L["Title"] },
}

local HUNT_SORT_DIR_OPTIONS = {
    asc = { text = L["Ascending"] },
    desc = { text = L["Descending"] },
}

local HUNT_ALIGN_OPTIONS = {
    { key = "top", text = L["Top"] },
    { key = "middle", text = L["Middle"] },
    { key = "bottom", text = L["Bottom"] },
}

local ACHIEVEMENT_SIGNAL_STYLE_OPTIONS = {
    icon_only = { text = L["Icon Only"] },
    icon_count = { text = L["Icon + Count"] },
    count_only = { text = L["Text Only"] },
}

local HUNT_REWARD_STYLE_OPTIONS = {
    icon_text  = { text = L["Icon + Text"] },
    icon_count = { text = L["Icon + Count"] },
    text_only  = { text = L["Text Only"] },
    icon_only  = { text = L["Icon Only"] },
}

local PERCENT_DISPLAY_OPTIONS = {
    [constants.PERCENT_DISPLAY_INSIDE] = { text = L["In Bar"] },
    [constants.PERCENT_DISPLAY_ABOVE_BAR] = { text = L["Above Bar"] },
    [constants.PERCENT_DISPLAY_ABOVE_TICKS] = { text = L["Above Ticks"] },
    [constants.PERCENT_DISPLAY_UNDER_TICKS] = { text = L["Under Ticks"] },
    [constants.PERCENT_DISPLAY_BELOW_BAR] = { text = L["Below Bar"] },
    [constants.PERCENT_DISPLAY_OFF] = { text = L["Off"] },
}

local VERTICAL_PERCENT_DISPLAY_OPTIONS = {
    [constants.PERCENT_DISPLAY_OFF]       = { text = L["Off"] },
    [constants.PERCENT_DISPLAY_ABOVE_BAR] = { text = L["Above"] },
    [constants.PERCENT_DISPLAY_INSIDE]    = { text = L["Inside"] },
    [constants.PERCENT_DISPLAY_BELOW_BAR] = { text = L["Below"] },
}

local LAYER_MODE_OPTIONS = {
    [constants.LAYER_MODE_ABOVE] = { text = L["Above Fill"] },
    [constants.LAYER_MODE_BELOW] = { text = L["Below Fill"] },
}

local PROGRESS_SEGMENT_OPTIONS = {
    [constants.PROGRESS_SEGMENTS_QUARTERS] = { text = L["Quarters (25/50/75/100)"] },
    [constants.PROGRESS_SEGMENTS_THIRDS] = { text = L["Thirds (33/66/100)"] },
}

local LABEL_MODE_OPTIONS = {
    [constants.LABEL_MODE_CENTER]       = { text = L["Centered"] },
    [constants.LABEL_MODE_LEFT]         = { text = L["Left (Prefix only)"] },
    [constants.LABEL_MODE_LEFT_COMBINED] = { text = L["Left (Prefix + Suffix)"] },
    [constants.LABEL_MODE_LEFT_SUFFIX]  = { text = L["Left (Suffix only)"] },
    [constants.LABEL_MODE_RIGHT]        = { text = L["Right (Suffix only)"] },
    [constants.LABEL_MODE_RIGHT_COMBINED] = { text = L["Right (Prefix + Suffix)"] },
    [constants.LABEL_MODE_RIGHT_PREFIX] = { text = L["Right (Prefix only)"] },
    [constants.LABEL_MODE_SEPARATE]     = { text = L["Separate (Prefix + Suffix)"] },
    [constants.LABEL_MODE_NONE]         = { text = L["No Text"] },
}

local LABEL_ROW_OPTIONS = {
    [constants.LABEL_ROW_ABOVE] = { text = L["Above Bar"] },
    [constants.LABEL_ROW_BELOW] = { text = L["Below Bar"] },
}

local ORIENTATION_OPTIONS = {
    [constants.ORIENTATION_HORIZONTAL] = { text = L["Horizontal"] },
    [constants.ORIENTATION_VERTICAL] = { text = L["Vertical"] },
}

local VERTICAL_FILL_DIRECTION_OPTIONS = {
    [constants.FILL_DIRECTION_UP] = { text = L["Fill Up"] },
    [constants.FILL_DIRECTION_DOWN] = { text = L["Fill Down"] },
}

local VERTICAL_SIDE_OPTIONS = {
    left = { text = L["Left"] },
    right = { text = L["Right"] },
}

local VERTICAL_PERCENT_SIDE_OPTIONS = {
    left   = { text = L["Left"] },
    center = { text = L["Center"] },
    right  = { text = L["Right"] },
}

local VERTICAL_TEXT_ALIGN_OPTIONS = {
    top = { text = L["Top Align"] },
    middle = { text = L["Middle Align"] },
    bottom = { text = L["Bottom Align"] },
    top_prefix_only = { text = L["Top Prefix Only"] },
    top_suffix_only = { text = L["Top Suffix Only"] },
    bottom_prefix_only = { text = L["Bottom Prefix Only"] },
    bottom_suffix_only = { text = L["Bottom Suffix Only"] },
    separate = { text = L["Separate Prefix/Suffix"] },
}

local function Clamp(value, minValue, maxValue)
    if api and type(api.Clamp) == "function" then
        return api.Clamp(value, minValue, maxValue)
    end
    return math.max(minValue, math.min(maxValue, value))
end

local function NormalizeSliderValue(value, minValue, maxValue, step)
    if api and type(api.NormalizeSliderValue) == "function" then
        return api.NormalizeSliderValue(value, minValue, maxValue, step)
    end

    local numeric = tonumber(value)
    if not numeric then
        return nil
    end

    numeric = Clamp(numeric, minValue, maxValue)
    if step and step > 0 then
        numeric = math.floor((numeric / step) + 0.5) * step
    end
    return Clamp(numeric, minValue, maxValue)
end

local function OpenColorPicker(initial, allowAlpha, callback)
    if not ColorPickerFrame then
        return
    end

    local start = {
        initial[1] or 1,
        initial[2] or 1,
        initial[3] or 1,
        initial[4] or 1,
    }

    local function applyFromPicker()
        local r, g, b
        if ColorPickerFrame.GetColorRGB then
            r, g, b = ColorPickerFrame:GetColorRGB()
        elseif ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker and ColorPickerFrame.Content.ColorPicker.GetColorRGB then
            r, g, b = ColorPickerFrame.Content.ColorPicker:GetColorRGB()
        else
            r, g, b = start[1], start[2], start[3]
        end

        local a = start[4]
        if allowAlpha then
            if ColorPickerFrame.GetColorAlpha then
                a = ColorPickerFrame:GetColorAlpha()
            elseif OpacitySliderFrame and OpacitySliderFrame.GetValue then
                a = 1 - OpacitySliderFrame:GetValue()
            end
        end

        callback({ r, g, b, a })
    end

    local function cancelColor(previousValues)
        local pr = start[1]
        local pg = start[2]
        local pb = start[3]
        local pa = start[4]

        if type(previousValues) == "table" then
            pr = previousValues.r or previousValues[1] or pr
            pg = previousValues.g or previousValues[2] or pg
            pb = previousValues.b or previousValues[3] or pb
            pa = previousValues.a or previousValues[4] or pa
        end

        callback({ pr, pg, pb, pa })
    end

    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = start[1],
            g = start[2],
            b = start[3],
            opacity = allowAlpha and start[4] or 0,
            hasOpacity = allowAlpha and true or false,
            swatchFunc = applyFromPicker,
            opacityFunc = applyFromPicker,
            cancelFunc = cancelColor,
            func = applyFromPicker,
        })
        return
    end

    ColorPickerFrame.hasOpacity = allowAlpha and true or false
    ColorPickerFrame.opacity = allowAlpha and (1 - start[4]) or 0
    ColorPickerFrame.previousValues = { start[1], start[2], start[3], start[4] }
    ColorPickerFrame.func = applyFromPicker
    ColorPickerFrame.swatchFunc = applyFromPicker
    ColorPickerFrame.opacityFunc = applyFromPicker
    ColorPickerFrame.cancelFunc = cancelColor

    if ColorPickerFrame.SetColorRGB then
        ColorPickerFrame:SetColorRGB(start[1], start[2], start[3])
    end

    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

local function CreateSectionTitle(parent, x, y, text)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    title:SetText(text)
    return title
end

local function CreateCheckbox(parent, x, y, label, getter, setter)
    return api.CreateCheckboxControl(parent, x, y, label, getter, setter, {
        withSetEnabled = true,
    })
end

local function CreateSlider(parent, x, y, label, minValue, maxValue, step, getter, setter, formatValue)
    return api.CreateSliderControl(parent, x, y, label, minValue, maxValue, step, getter, setter, formatValue, {
        containerWidth = CONTROL_WIDTH + 28,
        containerHeight = 56,
        sliderWidth = DEFAULT_SLIDER_WIDTH,
        sliderScale = DEFAULT_SLIDER_SCALE,
        valueBoxWidth = DEFAULT_SLIDER_VALUEBOX_WIDTH,
        valueBoxHeight = DEFAULT_SLIDER_VALUEBOX_HEIGHT,
        valueBoxOffsetX = 12,
        withSetEnabled = true,
    })
end

local SOUND_PICKER_VISIBLE_ROWS = 15
local SOUND_PICKER_ROW_HEIGHT = 22

local function BuildDropdownOptionList(optionSource)
    local optionList = {}
    if type(optionSource) == "table" and #optionSource > 0 then
        for _, entry in ipairs(optionSource) do
            if type(entry) == "table" and entry.key ~= nil then
                optionList[#optionList + 1] = { key = entry.key, entry = entry }
            end
        end
    else
        for key, entry in pairs(optionSource or {}) do
            optionList[#optionList + 1] = { key = key, entry = entry }
        end

        table.sort(optionList, function(left, right)
            return tostring(left.entry and left.entry.text or "") < tostring(right.entry and right.entry.text or "")
        end)
    end

    return optionList
end

local function EnsureSoundPickerFrame()
    local soundPickerFrame = _G.PreydatorSoundPickerFrame
    if soundPickerFrame then
        return soundPickerFrame
    end

    local frame = CreateFrame("Frame", "PreydatorSoundPickerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(520, 500)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    if frame.TitleText then
        frame.TitleText:SetText(L["Sound Picker"] or "Sound Picker")
    end

    if type(_G.UISpecialFrames) == "table" then
        _G.UISpecialFrames[#_G.UISpecialFrames + 1] = "PreydatorSoundPickerFrame"
    end

    local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -34)
    searchLabel:SetText(L["Search"] or "Search")

    local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    searchBox:SetAutoFocus(false)
    searchBox:SetSize(330, 22)
    searchBox:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -6)
    searchBox:SetTextInsets(6, 6, 0, 0)
    frame.searchBox = searchBox

    local listContainer = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    listContainer:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -4, -8)
    listContainer:SetSize(488, 380)
    listContainer:EnableMouseWheel(true)
    frame.listContainer = listContainer

    local scrollProxy = CreateFrame("ScrollFrame", nil, frame)
    scrollProxy:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, 0)
    scrollProxy:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", 0, 0)

    local scrollSlider = CreateFrame("Slider", nil, scrollProxy, "OptionsSliderTemplate")
    scrollSlider:SetOrientation("VERTICAL")
    scrollSlider:SetPoint("TOPLEFT", listContainer, "TOPRIGHT", -18, -18)
    scrollSlider:SetPoint("BOTTOMLEFT", listContainer, "BOTTOMRIGHT", -18, 18)
    scrollSlider:SetWidth(16)
    scrollSlider:SetMinMaxValues(0, 0)
    scrollSlider:SetValueStep(1)
    scrollSlider:SetObeyStepOnDrag(true)
    scrollSlider:SetValue(0)
    if scrollSlider.Low then scrollSlider.Low:Hide() end
    if scrollSlider.High then scrollSlider.High:Hide() end
    if scrollSlider.Text then scrollSlider.Text:Hide() end
    frame.scrollSlider = scrollSlider

    local clearButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearButton:SetSize(70, 22)
    clearButton:SetPoint("LEFT", searchBox, "RIGHT", 8, 0)
    clearButton:SetText(L["Clear"] or "Clear")
    clearButton:SetScript("OnClick", function()
        searchBox:SetText("")
    end)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 12)
    closeButton:SetText(L["Close"] or "Close")
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("LEFT", closeButton, "RIGHT", -340, 0)
    statusText:SetJustifyH("LEFT")
    frame.statusText = statusText

    frame.optionRows = {}
    frame.filteredOptions = {}
    frame.currentOffset = 0
    frame.context = nil

    local function RefreshRows()
        local total = #frame.filteredOptions
        local maxOffset = math.max(0, total - SOUND_PICKER_VISIBLE_ROWS)
        frame.currentOffset = math.max(0, math.min(frame.currentOffset or 0, maxOffset))

        scrollSlider:SetMinMaxValues(0, maxOffset)
        scrollSlider:SetValue(frame.currentOffset)
        scrollSlider:SetShown(maxOffset > 0)

        local selectedKey = nil
        if frame.context and type(frame.context.getter) == "function" then
            selectedKey = frame.context.getter()
        end

        for rowIndex = 1, SOUND_PICKER_VISIBLE_ROWS do
            local optionIndex = frame.currentOffset + rowIndex
            local option = frame.filteredOptions[optionIndex]
            local row = frame.optionRows[rowIndex]
            if not row then
                break
            end

            if option then
                row.option = option
                row.text:SetText(tostring(option.entry and option.entry.text or ""))
                row:Show()
                if selectedKey ~= nil and selectedKey == option.key then
                    row.text:SetTextColor(1.00, 0.82, 0.00)
                else
                    row.text:SetTextColor(1.00, 1.00, 1.00)
                end
            else
                row.option = nil
                row:Hide()
            end
        end

        if total > 0 then
            statusText:SetText(string.format("%d %s", total, (L["sounds"] or "sounds")))
        else
            statusText:SetText(L["No matching sounds"] or "No matching sounds")
        end
    end

    local function ApplyFilter()
        local query = string.lower((searchBox:GetText() or ""):match("^%s*(.-)%s*$") or "")
        frame.filteredOptions = {}

        local source = frame.context and frame.context.optionList or {}
        for _, option in ipairs(source) do
            local text = tostring(option.entry and option.entry.text or "")
            if query == "" or string.find(string.lower(text), query, 1, true) then
                frame.filteredOptions[#frame.filteredOptions + 1] = option
            end
        end

        frame.currentOffset = 0
        RefreshRows()
    end

    frame.ApplyFilter = ApplyFilter
    frame.RefreshRows = RefreshRows

    scrollSlider:SetScript("OnValueChanged", function(_, value)
        frame.currentOffset = math.floor((value or 0) + 0.5)
        RefreshRows()
    end)

    listContainer:SetScript("OnMouseWheel", function(_, delta)
        local minValue, maxValue = scrollSlider:GetMinMaxValues()
        if (maxValue or 0) <= (minValue or 0) then
            return
        end

        local currentValue = scrollSlider:GetValue() or 0
        local nextValue = Clamp(currentValue - delta, minValue or 0, maxValue or 0)
        scrollSlider:SetValue(nextValue)
    end)

    searchBox:SetScript("OnTextChanged", function()
        ApplyFilter()
    end)
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    for rowIndex = 1, SOUND_PICKER_VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, listContainer)
        row:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 10, -(12 + (rowIndex - 1) * SOUND_PICKER_ROW_HEIGHT))
        row:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", -22, -(12 + (rowIndex - 1) * SOUND_PICKER_ROW_HEIGHT))
        row:SetHeight(SOUND_PICKER_ROW_HEIGHT)

        local rowHighlight = row:CreateTexture(nil, "HIGHLIGHT")
        rowHighlight:SetAllPoints(true)
        rowHighlight:SetColorTexture(1, 1, 1, 0.08)

        local normalBg = row:CreateTexture(nil, "BACKGROUND")
        normalBg:SetAllPoints(true)
        normalBg:SetColorTexture(0, 0, 0, 0.18)

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", row, "LEFT", 6, 0)
        text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        text:SetJustifyH("LEFT")
        row.text = text

        row:SetScript("OnClick", function(self)
            if not self.option or not frame.context then
                return
            end

            if type(frame.context.setter) == "function" then
                frame.context.setter(self.option.key)
            end
            if type(frame.context.refresh) == "function" then
                frame.context.refresh()
            end

            frame:Hide()
        end)

        frame.optionRows[rowIndex] = row
    end

    _G.PreydatorSoundPickerFrame = frame
    return frame
end

local function OpenSoundPicker(context)
    if type(context) ~= "table" then
        return
    end

    local frame = EnsureSoundPickerFrame()
    local titleText = context.pickerTitle or context.label or (L["Sound Picker"] or "Sound Picker")
    if frame.TitleText then
        frame.TitleText:SetText(titleText)
    end

    frame.context = {
        optionList = BuildDropdownOptionList((type(context.getOptions) == "function" and context.getOptions()) or {}),
        getter = context.getter,
        setter = context.setter,
        refresh = context.refresh,
    }

    frame.searchBox:SetText("")
    frame.currentOffset = 0
    frame:Show()
    frame:Raise()
    frame.searchBox:SetFocus()
    frame:ApplyFilter()
end

local function CreateDropdown(parent, x, y, label, width, options, getter, setter, maxScrollItems)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    title:SetText(label)

    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -16, -4)

    local dropdownConfig = nil
    local scrollLimit = maxScrollItems
    if type(maxScrollItems) == "table" then
        dropdownConfig = maxScrollItems
        scrollLimit = maxScrollItems.maxScrollItems
    end

    BindDropdownScale(dropdown, scrollLimit)

    local function GetOptions()
        if type(options) == "function" then
            return options() or {}
        end
        return options or {}
    end

    local function RefreshText()
        local selected = getter()
        local optionSource = GetOptions()
        local entry = optionSource[selected]
        if not entry and type(optionSource) == "table" and #optionSource > 0 then
            for _, item in ipairs(optionSource) do
                if item and item.key == selected then
                    entry = item
                    break
                end
            end
        end
        UIDropDownMenu_SetText(dropdown, entry and entry.text or "Select")
    end

    UIDropDownMenu_SetWidth(dropdown, width)
    if type(scrollLimit) == "number" and scrollLimit > 0 then
        dropdown.maxItems = math.floor(scrollLimit)
    end

    UIDropDownMenu_Initialize(dropdown, function()
        ApplyDropdownListLimit(scrollLimit)

        local optionList = BuildDropdownOptionList(GetOptions())

        for _, item in ipairs(optionList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.entry.text
            info.func = function()
                setter(item.key)
                RefreshText()
            end
            info.checked = getter() == item.key
            UIDropDownMenu_AddButton(info)
        end
    end)

    if dropdownConfig and dropdownConfig.useSearchPicker and dropdown.Button and dropdown.Button.SetScript then
        dropdown.Button:SetScript("OnClick", function(self)
            if self.IsEnabled and not self:IsEnabled() then
                return
            end

            OpenSoundPicker({
                label = label,
                pickerTitle = dropdownConfig.pickerTitle,
                getOptions = GetOptions,
                getter = getter,
                setter = setter,
                refresh = RefreshText,
            })
        end)
    end

    dropdown.PreydatorRefresh = RefreshText
    function dropdown:PreydatorSetEnabled(enabled)
        local isEnabled = enabled and true or false
        self:SetAlpha(isEnabled and 1 or 0.45)
        local toggleDropdown = isEnabled and _G.UIDropDownMenu_EnableDropDown or _G.UIDropDownMenu_DisableDropDown
        if toggleDropdown then
            toggleDropdown(self)
        end
        if self.EnableMouse then
            self:EnableMouse(isEnabled)
        end
    end
    RefreshText()
    return dropdown
end

local function CreateSoundPickerSelector(parent, x, y, label, width, getOptions, getter, setter)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    title:SetText(label)

    local TRIGGER_W = 28
    local DISPLAY_W = width - TRIGGER_W - 4

    local displayBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    displayBox:SetSize(DISPLAY_W, 20)
    displayBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    displayBox:SetAutoFocus(false)
    displayBox:SetText("")
    displayBox:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)

    local triggerBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    triggerBtn:SetSize(TRIGGER_W, 22)
    triggerBtn:SetPoint("LEFT", displayBox, "RIGHT", 4, -1)
    triggerBtn:SetText("...")

    local function ResolveOptions()
        if type(getOptions) == "function" then
            return getOptions() or {}
        end
        return getOptions or {}
    end

    local function RefreshText()
        local selected = getter and getter() or nil
        local optionSource = ResolveOptions()
        local optionList = BuildDropdownOptionList(optionSource)
        local selectedText = nil

        for _, option in ipairs(optionList) do
            if option and option.key == selected then
                selectedText = tostring(option.entry and option.entry.text or "")
                break
            end
        end

        displayBox:SetText(selectedText and selectedText ~= "" and selectedText or "(none)")
    end

    local function DoOpen()
        OpenSoundPicker({
            label = label,
            pickerTitle = L["Sound Selection"] or "Sound Selection",
            getOptions = ResolveOptions,
            getter = getter,
            setter = setter,
            refresh = RefreshText,
        })
    end

    displayBox:SetScript("OnMouseDown", DoOpen)
    triggerBtn:SetScript("OnClick", DoOpen)

    displayBox.PreydatorRefresh = RefreshText
    function displayBox:PreydatorSetEnabled(enabled)
        local isEnabled = enabled and true or false
        self:SetAlpha(isEnabled and 1 or 0.45)
        triggerBtn:SetAlpha(isEnabled and 1 or 0.45)
        triggerBtn:SetEnabled(isEnabled)
        triggerBtn:EnableMouse(isEnabled)
        self:EnableMouse(isEnabled)
    end

    RefreshText()
    return displayBox
end

local function CreateTextInput(parent, x, y, label, width, getter, setter)
    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    labelText:SetText(label)

    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetSize(width, 20)
    edit:SetAutoFocus(false)
    edit:SetTextInsets(6, 6, 0, 0)
    edit:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -6)
    edit:SetText(getter() or "")
    edit:SetScript("OnEnterPressed", function(self)
        setter(self:GetText())
        self:SetText(getter() or "")
        self:ClearFocus()
    end)
    edit:SetScript("OnEditFocusLost", function(self)
        setter(self:GetText())
        self:SetText(getter() or "")
    end)

    function edit:PreydatorRefresh()
        self:SetText(getter() or "")
    end

    function edit:PreydatorSetEnabled(enabled)
        local isEnabled = enabled and true or false
        self:SetAlpha(isEnabled and 1 or 0.45)
        self:SetEnabled(isEnabled)
        if self.EnableMouse then
            self:EnableMouse(isEnabled)
        end
    end

    return edit
end

local function CreateColorButton(parent, x, y, label, getter, setter, allowAlpha)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(170, 22)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText(label)

    local swatch = button:CreateTexture(nil, "OVERLAY")
    swatch:SetSize(18, 18)
    swatch:SetPoint("LEFT", button, "RIGHT", 8, 0)

    local function RefreshSwatch()
        local color = getter()
        swatch:SetColorTexture(color[1], color[2], color[3], (allowAlpha and color[4]) or 1)
    end

    button:SetScript("OnClick", function(self)
        if self.IsEnabled and not self:IsEnabled() then
            return
        end
        OpenColorPicker(getter(), allowAlpha, function(color)
            setter({ color[1], color[2], color[3], color[4] })
            RefreshSwatch()
        end)
    end)

    button.PreydatorRefresh = RefreshSwatch

    function button:PreydatorSetEnabled(enabled)
        local isEnabled = enabled and true or false
        self:SetAlpha(isEnabled and 1 or 0.45)
        self:SetEnabled(isEnabled)
        if self.EnableMouse then
            self:EnableMouse(isEnabled)
        end
        swatch:SetAlpha(isEnabled and 1 or 0.55)
    end

    RefreshSwatch()
    return button
end

local function CreateActionButton(parent, x, y, width, text, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText(text)
    button:SetScript("OnClick", onClick)

    function button:PreydatorSetEnabled(enabled)
        local isEnabled = enabled and true or false
        self:SetAlpha(isEnabled and 1 or 0.45)
        self:SetEnabled(isEnabled)
        if self.EnableMouse then
            self:EnableMouse(isEnabled)
        end
    end

    return button
end

local function CreateLeftNavTabs(parent, labels, onSelect)
    local navPanel = CreateFrame("Frame", nil, parent)
    navPanel:SetSize(140, 482)
    navPanel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -108)
    
    local navBackground = navPanel:CreateTexture(nil, "BACKGROUND")
    navBackground:SetAllPoints()
    navBackground:SetColorTexture(0.12, 0.12, 0.12, 1)
    
    local tabs = {}
    local buttonHeight = 32
    local buttonSpacing = 2
    
    for index, label in ipairs(labels) do
        local tab = CreateFrame("Button", nil, navPanel)
        tab:SetSize(130, buttonHeight)
        tab:SetPoint("TOPLEFT", navPanel, "TOPLEFT", 5, -((index - 1) * (buttonHeight + buttonSpacing)) - 5)
        
        local background = tab:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.18, 0.18, 0.18, 0.9)
        tab.PreydatorBackground = background
        
        local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("CENTER")
        text:SetText(label)
        text:SetJustifyH("CENTER")
        tab.PreydatorText = text
        
        local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.45, 0.45, 0.45, 0.4)
        
        tab:SetScript("OnClick", function()
            onSelect(index)
        end)
        
        tabs[index] = tab
    end
    
    return tabs, navPanel
end

local function RegisterRefresher(owner, control)
    owner.refreshers[#owner.refreshers + 1] = control
    return control
end

local function IsModuleEnabled(moduleKey)
    local customizationV2 = Preydator:GetModule("CustomizationStateV2")
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        return customizationV2:IsModuleEnabled(moduleKey) == true
    end
    return true
end

local function RefreshHuntTrackerPanel()
    local huntScanner = Preydator:GetModule("HuntScanner")
    if huntScanner and type(huntScanner.ApplySettings) == "function" then
        huntScanner:ApplySettings()
    end
end

local function RefreshCurrencyTrackerPanel()
    local tracker = Preydator:GetModule("CurrencyTracker")
    if tracker and type(tracker.RefreshCurrencyPage) == "function" then
        tracker:RefreshCurrencyPage()
    end
end

local function BuildModulesPage(owner, parent)
    local customizationV2 = Preydator:GetModule("CustomizationStateV2")

    local MODULE_LEFT_X = 5
    local MODULE_RIGHT_X = 258
    local MODULE_BUTTON_X = 252
    local MODULE_TOP_Y = -42
    local MODULE_ROW_STEP = 84
    local MODULE_DESC_OFFSET_X = 30
    local MODULE_DESC_OFFSET_Y = 28
    local MODULE_DESC_WIDTH = 200
    local MODULE_CHECKBOX_LIFT = 8

    local function RequestReloadUI()
        if _G.C_UI and type(_G.C_UI.Reload) == "function" then
            _G.C_UI.Reload()
            return
        end
        if type(_G.ReloadUI) == "function" then
            _G.ReloadUI()
        end
    end

    CreateSectionTitle(parent, MODULE_LEFT_X, -10, L["Module Status"])
    
    local moduleList = {
        { key = "bar", label = L["Bar Module"], desc = L["Controls the main prey progress bar display and behavior."] },
        { key = "sounds", label = L["Sounds Module"], desc = L["Controls stage sounds and ambush audio settings."] },
        { key = "currency", label = L["Currency Module"], desc = L["Controls the currency tracker panel and currency displays."] },
        { key = "hunt", label = L["Hunt Table Module"], desc = L["Controls hunt table data, sorting, and panel features."] },
        { key = "warband", label = L["Warband Module"], desc = L["Controls the warband currency panel and roster view."] },
    }

    local initialModuleState = {}
    for _, module in ipairs(moduleList) do
        if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
            initialModuleState[module.key] = customizationV2:IsModuleEnabled(module.key) and true or false
        else
            initialModuleState[module.key] = true
        end
    end

    local reloadButton = CreateActionButton(parent, MODULE_BUTTON_X, -8, 170, L["Reload"], function()
        RequestReloadUI()
    end)

    local function SetReloadButtonActive(isActive)
        if isActive then
            reloadButton:Enable()
            reloadButton:SetAlpha(1)
        else
            reloadButton:Disable()
            reloadButton:SetAlpha(0.5)
        end
    end

    local function RefreshReloadButtonVisibility()
        local hasChanges = false
        for _, module in ipairs(moduleList) do
            local current = true
            if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
                current = customizationV2:IsModuleEnabled(module.key) and true or false
            end

            if current ~= initialModuleState[module.key] then
                hasChanges = true
                break
            end
        end

        SetReloadButtonActive(hasChanges)
    end

    for index, module in ipairs(moduleList) do
        local inRightColumn = index > 3
        local rowIndex = (index - 1) % 3
        local x = inRightColumn and MODULE_RIGHT_X or MODULE_LEFT_X
        local yBase = MODULE_TOP_Y - (rowIndex * MODULE_ROW_STEP)
        local yCheck = yBase + MODULE_CHECKBOX_LIFT

        local moduleCheck = RegisterRefresher(owner, CreateCheckbox(parent, x, yCheck, module.label, function()
            if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
                return customizationV2:IsModuleEnabled(module.key)
            end
            return true
        end, function(value)
            if customizationV2 and type(customizationV2.Set) == "function" then
                customizationV2:Set("customizationV2.moduleEnabled." .. module.key, value and true or false)
            end
            RefreshReloadButtonVisibility()
        end))
        moduleCheck:SetScale(1)

        local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", x + MODULE_DESC_OFFSET_X, yBase - MODULE_DESC_OFFSET_Y)
        desc:SetWidth(MODULE_DESC_WIDTH)
        desc:SetJustifyH("LEFT")
        desc:SetWordWrap(true)
        desc:SetText(module.desc or "")
    end

    RefreshReloadButtonVisibility()

    local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -332)
    note:SetWidth(500)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(L["Module changes require a reload to fully apply. Hunt Table also controls achievement tracking behavior."])
    do
        local fontPath, fontSize, fontFlags = note:GetFont()
        if fontPath and fontSize then
            note:SetFont(fontPath, fontSize * 1.25, fontFlags)
        end
    end
    note:SetTextColor(1.0, 0.88, 0.45)
end

local function BuildGlobalTopStrip(owner, parent)
    local db = api.GetSettings()
    
    local stripFrame = CreateFrame("Frame", nil, parent)
    stripFrame:SetSize(PANEL_WIDTH - 116, 36)
    stripFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -56)
    
    local stripBackground = stripFrame:CreateTexture(nil, "BACKGROUND")
    stripBackground:SetAllPoints()
    stripBackground:SetColorTexture(0.15, 0.15, 0.15, 0.8)
    
    local stripBorder = stripFrame:CreateTexture(nil, "BORDER")
    stripBorder:SetAllPoints()
    stripBorder:SetColorTexture(0.3, 0.3, 0.3, 0.3)
    stripBorder:SetHeight(1)
    stripBorder:SetVertexColor(0.3, 0.3, 0.3)
    
    local controls = {}
    local spacing = 5
    local currentX = 8
    local checkboxSpacing = 120
    
    -- Lock Frame checkbox
    local lockCheck = CreateCheckbox(stripFrame, currentX - 5, -7, L["Lock Frame"], function() return db.locked end, function(value)
        db.locked = value
        api.RequestBarRefresh()
    end)
    lockCheck:SetSize(24, 24)
    controls[#controls + 1] = lockCheck
    currentX = currentX + checkboxSpacing
    
    -- Hide Prey Icon checkbox
    local hideIconCheck = CreateCheckbox(stripFrame, currentX - 15, -7, L["Hide Prey Icon"], function() return db.disableDefaultPreyIcon == true end, function(value)
        db.disableDefaultPreyIcon = value
        api.ApplyDefaultPreyIconVisibility()
        api.UpdateBarDisplay()
    end)
    hideIconCheck:SetSize(24, 24)
    controls[#controls + 1] = hideIconCheck
    currentX = currentX + checkboxSpacing
    
    -- Show Only In Zone checkbox
    local zoneCheck = CreateCheckbox(stripFrame, currentX - 15, -7, L["Show Only In Zone"], function() return db.onlyShowInPreyZone end, function(value)
        db.onlyShowInPreyZone = value
        api.UpdateBarDisplay()
    end)
    zoneCheck:SetSize(24, 24)
    controls[#controls + 1] = zoneCheck
    currentX = currentX + checkboxSpacing

    -- Enable Sounds checkbox
    local soundCheck = CreateCheckbox(stripFrame, currentX + 5, -7, L["Enable Sounds"], function()
        return db.soundsEnabled ~= false
    end, function(value)
        db.soundsEnabled = value and true or false
        api.NormalizeSoundSettings()
    end)
    soundCheck:SetSize(24, 24)
    controls[#controls + 1] = soundCheck
    currentX = currentX + checkboxSpacing

    -- Disable Minimap Button checkbox
    local minimapCheck = CreateCheckbox(stripFrame, currentX, -7, L["Disable Minimap Button"], function()
        return db.currencyMinimap and db.currencyMinimap.hide == true
    end, function(value)
        db.currencyMinimap = db.currencyMinimap or {}
        db.currencyMinimap.hide = value and true or false
        db.currencyMinimapButton = not (value and true or false)
        if type(_G.Preydator) == "table" and type(_G.Preydator.UpdateLauncherButtonVisibility) == "function" then
            _G.Preydator.UpdateLauncherButtonVisibility()
        end
        RefreshCurrencyTrackerPanel()
    end)
    minimapCheck:SetSize(24, 24)
    controls[#controls + 1] = minimapCheck

    controls[#controls + 1] = {
        PreydatorRefresh = function()
            local barEnabled = IsModuleEnabled("bar")
            local soundsEnabled = IsModuleEnabled("sounds")
            if lockCheck and lockCheck.PreydatorSetEnabled then
                lockCheck:PreydatorSetEnabled(barEnabled)
            end
            if zoneCheck and zoneCheck.PreydatorSetEnabled then
                zoneCheck:PreydatorSetEnabled(barEnabled)
            end
            if soundCheck and soundCheck.PreydatorSetEnabled then
                soundCheck:PreydatorSetEnabled(soundsEnabled)
            end
        end,
    }
    
    return stripFrame, controls
end

local function BuildHuntPage(owner, parent)
    local db = api.GetSettings()
    local huntControls = {}
    local currencyControls = {}
    local warbandControls = {}

    local function TrackHuntControl(control)
        huntControls[#huntControls + 1] = control
        return RegisterRefresher(owner, control)
    end

    local function TrackCurrencyControl(control)
        currencyControls[#currencyControls + 1] = control
        return RegisterRefresher(owner, control)
    end

    local function TrackWarbandControl(control)
        warbandControls[#warbandControls + 1] = control
        return RegisterRefresher(owner, control)
    end

    local function ToggleHuntPreview()
        db.huntScannerPreviewInOptions = not (db.huntScannerPreviewInOptions == true)
        local huntScanner = Preydator:GetModule("HuntScanner")
        if huntScanner and type(huntScanner.SetPreviewEnabled) == "function" then
            huntScanner:SetPreviewEnabled(db.huntScannerPreviewInOptions == true)
        end
        owner:RefreshControls()
    end

    local function ToggleCurrencyPanel()
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.ToggleCurrencyWindow) == "function" then
            tracker:ToggleCurrencyWindow()
        else
            db.currencyWindowEnabled = not (db.currencyWindowEnabled == true)
            RefreshCurrencyTrackerPanel()
        end
        owner:RefreshControls()
    end

    local function ToggleWarbandPanel()
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.ToggleWarbandWindow) == "function" then
            tracker:ToggleWarbandWindow()
        else
            db.currencyWarbandWindowEnabled = not (db.currencyWarbandWindowEnabled == true)
            RefreshCurrencyTrackerPanel()
        end
        owner:RefreshControls()
    end

    local function GetKnownWarbandCharacters()
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.GetKnownWarbandCharacters) == "function" then
            return tracker:GetKnownWarbandCharacters() or {}
        end
        return {}
    end

    local function IsWarbandCharacterShown(charKey)
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.IsWarbandCharacterShown) == "function" then
            return tracker:IsWarbandCharacterShown(charKey)
        end
        return true
    end

    local function SetWarbandCharacterShown(charKey, shown)
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.SetWarbandCharacterShown) == "function" then
            tracker:SetWarbandCharacterShown(charKey, shown)
        else
            db.currencyWarbandCharacterVisibility = db.currencyWarbandCharacterVisibility or {}
            db.currencyWarbandCharacterVisibility[charKey] = shown and true or false
            RefreshCurrencyTrackerPanel()
        end
        owner:RefreshControls()
    end

    local function PurgeHiddenWarbandCharacters()
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.PurgeHiddenWarbandCharacters) == "function" then
            tracker:PurgeHiddenWarbandCharacters()
        end
        RefreshCurrencyTrackerPanel()
        owner:RefreshControls()
    end

    local function SetAllWarbandCharactersShown(shown)
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.SetAllWarbandCharactersShown) == "function" then
            tracker:SetAllWarbandCharactersShown(shown)
        else
            db.currencyWarbandCharacterVisibility = db.currencyWarbandCharacterVisibility or {}
            for _, entry in ipairs(GetKnownWarbandCharacters()) do
                db.currencyWarbandCharacterVisibility[entry.charKey] = shown and true or false
            end
            RefreshCurrencyTrackerPanel()
        end
        owner:RefreshControls()
    end

    local knownCharacters = GetKnownWarbandCharacters()
    local contentHeight = math.max(1594, 1274 + (math.ceil(#knownCharacters / 2) * 28))

    local contentViewport = CreateFrame("ScrollFrame", nil, parent)
    contentViewport:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    contentViewport:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 0)
    contentViewport:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, contentViewport)
    content:SetPoint("TOPLEFT", contentViewport, "TOPLEFT", 0, 0)
    content:SetSize(PANEL_WIDTH - 160, contentHeight)
    contentViewport:SetScrollChild(content)

    local panelScrollSlider = CreateFrame("Slider", nil, contentViewport, "OptionsSliderTemplate")
    panelScrollSlider:SetOrientation("VERTICAL")
    panelScrollSlider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
    panelScrollSlider:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 26)
    panelScrollSlider:SetWidth(16)
    panelScrollSlider:SetMinMaxValues(0, 100)
    panelScrollSlider:SetValueStep(1)
    panelScrollSlider:SetObeyStepOnDrag(true)
    panelScrollSlider:SetValue(0)
    if panelScrollSlider.Low then panelScrollSlider.Low:Hide() end
    if panelScrollSlider.High then panelScrollSlider.High:Hide() end
    if panelScrollSlider.Text then panelScrollSlider.Text:Hide() end

    local function UpdatePanelScrollBounds()
        contentViewport:UpdateScrollChildRect()
        local currentValue = panelScrollSlider:GetValue() or 0
        local scrollRange = contentViewport:GetVerticalScrollRange() or 0
        if scrollRange < 0 then scrollRange = 0 end
        panelScrollSlider:SetMinMaxValues(0, scrollRange)
        local clamped = Clamp(currentValue, 0, scrollRange)
        panelScrollSlider:SetValue(clamped)
        contentViewport:SetVerticalScroll(clamped)
        if scrollRange <= 0 then
            panelScrollSlider:SetEnabled(false)
            panelScrollSlider:SetAlpha(0.35)
        else
            panelScrollSlider:SetEnabled(true)
            panelScrollSlider:SetAlpha(1)
        end
    end

    panelScrollSlider:SetScript("OnValueChanged", function(self, value)
        local _, maxValue = self:GetMinMaxValues()
        contentViewport:SetVerticalScroll(Clamp(value or 0, 0, maxValue or 0))
    end)
    contentViewport:SetScript("OnMouseWheel", function(_, delta)
        local minValue, maxValue = panelScrollSlider:GetMinMaxValues()
        panelScrollSlider:SetValue(Clamp((panelScrollSlider:GetValue() or 0) - (delta * 24), minValue or 0, maxValue or 0))
    end)
    if parent.HookScript then
        parent:HookScript("OnShow", UpdatePanelScrollBounds)
        parent:HookScript("OnSizeChanged", UpdatePanelScrollBounds)
    end
    if content.HookScript then
        content:HookScript("OnSizeChanged", UpdatePanelScrollBounds)
    end

    -- Hunt Table section
    CreateSectionTitle(content, COLUMN_LEFT_X, -10, L["Hunt Table Panel"])
    TrackHuntControl(CreateCheckbox(content, COLUMN_LEFT_X, -38, L["Enable Hunt Table Tracker"], function()
        return db.huntScannerEnabled ~= false
    end, function(value)
        db.huntScannerEnabled = value and true or false
        RefreshHuntTrackerPanel()
    end))

    TrackHuntControl(CreateDropdown(content, COLUMN_LEFT_X, -80, L["Hunt Panel Side"], 170, HUNT_PANEL_SIDE_OPTIONS, function()
        return db.huntScannerSide or "right"
    end, function(key)
        db.huntScannerSide = (key == "left") and "left" or "right"
        RefreshHuntTrackerPanel()
    end))
    TrackHuntControl(CreateDropdown(content, COLUMN_LEFT_X, -132, L["Group Hunts By"], 170, HUNT_GROUP_OPTIONS, function()
        return db.huntScannerGroupBy or "difficulty"
    end, function(key)
        db.huntScannerGroupBy = key
        RefreshHuntTrackerPanel()
    end))
    TrackHuntControl(CreateDropdown(content, COLUMN_LEFT_X, -184, L["Sort Hunts By"], 170, HUNT_SORT_OPTIONS, function()
        return db.huntScannerSortBy or "zone"
    end, function(key)
        db.huntScannerSortBy = key
        RefreshHuntTrackerPanel()
    end))
    TrackHuntControl(CreateDropdown(content, COLUMN_LEFT_X, -236, L["Sort Direction"], 170, HUNT_SORT_DIR_OPTIONS, function()
        return db.huntScannerSortDir or "asc"
    end, function(key)
        db.huntScannerSortDir = (key == "desc") and "desc" or "asc"
        RefreshHuntTrackerPanel()
    end))
    TrackHuntControl(CreateDropdown(content, COLUMN_LEFT_X, -288, L["Anchor Align"], 170, HUNT_ALIGN_OPTIONS, function()
        return db.huntScannerAnchorAlign or "top"
    end, function(key)
        db.huntScannerAnchorAlign = (key == "middle" or key == "bottom") and key or "top"
        RefreshHuntTrackerPanel()
    end))
    TrackHuntControl(CreateDropdown(content, COLUMN_LEFT_X, -340, L["Reward Display Style"], 170, HUNT_REWARD_STYLE_OPTIONS, function()
        return db.huntScannerRewardStyle or "icon_text"
    end, function(value)
        db.huntScannerRewardStyle = value
        RefreshHuntTrackerPanel()
    end))

    local note = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_RIGHT_X, -10)
    note:SetWidth(260)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(L["Use Hunt Table controls here to manage sorting, grouping, panel size, and reward cache behavior."])

    local previewButton = CreateActionButton(content, COLUMN_RIGHT_X, -38, 180, L["Show Preview Pane"], function()
        ToggleHuntPreview()
    end)
    TrackHuntControl(previewButton)
    previewButton.PreydatorRefresh = function(self)
        self:SetText((db.huntScannerPreviewInOptions == true) and L["Hide Preview Pane"] or L["Show Preview Pane"])
    end

    TrackHuntControl(CreateSlider(content, COLUMN_RIGHT_X, -80, L["Hunt Panel Width"], 280, 620, 1, function()
        return db.huntScannerWidth or 336
    end, function(value)
        db.huntScannerWidth = math.floor(value + 0.5)
        RefreshHuntTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackHuntControl(CreateSlider(content, COLUMN_RIGHT_X, -132, L["Hunt Panel Height"], 320, 900, 1, function()
        return db.huntScannerHeight or 460
    end, function(value)
        db.huntScannerHeight = math.floor(value + 0.5)
        RefreshHuntTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    TrackHuntControl(CreateSlider(content, COLUMN_RIGHT_X, -184, L["Hunt Panel Scale"], 0.70, 1.60, 0.05, function()
        return db.huntScannerScale or 1.00
    end, function(value)
        db.huntScannerScale = value
        RefreshHuntTrackerPanel()
    end, function(value)
        return string.format("%.2f", value)
    end))
    TrackHuntControl(CreateSlider(content, COLUMN_RIGHT_X, -236, L["Hunt Panel Font Size"], 10, 24, 1, function()
        return db.huntScannerFontSize or 12
    end, function(value)
        db.huntScannerFontSize = math.floor(value + 0.5)
        RefreshHuntTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackHuntControl(CreateColorButton(content, COLUMN_RIGHT_X, -288, L["Normal Difficulty"], function()
        local colors = db.huntScannerDifficultyColors or {}
        return colors.normal or { 0.42, 1.00, 0.56, 1.00 }
    end, function(color)
        db.huntScannerDifficultyColors = db.huntScannerDifficultyColors or {}
        db.huntScannerDifficultyColors.normal = { color[1], color[2], color[3], color[4] or 1 }
        RefreshHuntTrackerPanel()
    end, false))
    TrackHuntControl(CreateColorButton(content, COLUMN_RIGHT_X, -320, L["Hard Difficulty"], function()
        local colors = db.huntScannerDifficultyColors or {}
        return colors.hard or { 1.00, 0.67, 0.24, 1.00 }
    end, function(color)
        db.huntScannerDifficultyColors = db.huntScannerDifficultyColors or {}
        db.huntScannerDifficultyColors.hard = { color[1], color[2], color[3], color[4] or 1 }
        RefreshHuntTrackerPanel()
    end, false))
    TrackHuntControl(CreateColorButton(content, COLUMN_RIGHT_X, -352, L["Nightmare Difficulty"], function()
        local colors = db.huntScannerDifficultyColors or {}
        return colors.nightmare or { 1.00, 0.35, 0.35, 1.00 }
    end, function(color)
        db.huntScannerDifficultyColors = db.huntScannerDifficultyColors or {}
        db.huntScannerDifficultyColors.nightmare = { color[1], color[2], color[3], color[4] or 1 }
        RefreshHuntTrackerPanel()
    end, false))
    -- Currency section
    CreateSectionTitle(content, COLUMN_LEFT_X, -392, L["Currency Panel"])
    local currencyToggleButton = CreateActionButton(content, COLUMN_RIGHT_X, -392, 180, L["Open Currency"], function()
        ToggleCurrencyPanel()
    end)
    TrackCurrencyControl(currencyToggleButton)
    currencyToggleButton.PreydatorRefresh = function(self)
        self:SetText((db.currencyWindowEnabled == true) and L["Close Currency"] or L["Open Currency"])
    end
    TrackCurrencyControl(CreateCheckbox(content, COLUMN_LEFT_X, -428, L["Show Random Hunts Available"], function()
        return db.currencyShowAffordableHunts == true
    end, function(value)
        db.currencyShowAffordableHunts = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    TrackCurrencyControl(CreateCheckbox(content, COLUMN_LEFT_X, -458, L["Hide Currency in Instance"], function()
        return db.currencyWindowHideInInstance == true
    end, function(value)
        db.currencyWindowHideInInstance = value and true or false
        RefreshCurrencyTrackerPanel()
    end))

    TrackCurrencyControl(CreateColorButton(content, COLUMN_LEFT_X, -498, L["Gain Color"], function()
        return db.currencyDeltaGainColor or { 0.15, 0.9, 0.35, 1 }
    end, function(color)
        db.currencyDeltaGainColor = { color[1], color[2], color[3], color[4] }
        RefreshCurrencyTrackerPanel()
    end, true))
    TrackCurrencyControl(CreateColorButton(content, COLUMN_LEFT_X, -542, L["Spend Color"], function()
        return db.currencyDeltaLossColor or { 0.95, 0.25, 0.2, 1 }
    end, function(color)
        db.currencyDeltaLossColor = { color[1], color[2], color[3], color[4] }
        RefreshCurrencyTrackerPanel()
    end, true))

    local previewTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewTitle:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_LEFT_X, -588)
    previewTitle:SetText(L["Delta Preview"])

    local function ResolveCurrencyThemeSurface(key, colorKey)
        local source = THEME_EDITOR_PRESETS[key]
        if not source and type(db.customThemes) == "table" then
            source = db.customThemes[key]
        end
        if not source then
            source = THEME_EDITOR_PRESETS.brown
        end
        local fallback = THEME_EDITOR_PRESETS.brown[colorKey]
        local color = source[colorKey] or fallback or { 1, 1, 1, 1 }
        return { color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1 }
    end

    local function CreateDeltaPreviewBox(x, y)
        local box = CreateFrame("Frame", nil, content, "BackdropTemplate")
        box:SetSize(42, 62)
        box:SetPoint("TOPLEFT", content, "TOPLEFT", x, y)
        box:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        box:SetBackdropBorderColor(0, 0, 0, 0.85)

        local gainText = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gainText:SetPoint("TOP", box, "TOP", 0, -14)
        gainText:SetText("+123")

        local lossText = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lossText:SetPoint("TOP", box, "TOP", 0, -40)
        lossText:SetText("-45")

        return { frame = box, gainText = gainText, lossText = lossText }
    end

    local previewBoxes = {
        CreateDeltaPreviewBox(COLUMN_LEFT_X, -610),
        CreateDeltaPreviewBox(COLUMN_LEFT_X + 46, -610),
        CreateDeltaPreviewBox(COLUMN_LEFT_X + 92, -610),
    }

    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            local gain = db.currencyDeltaGainColor or { 0.15, 0.9, 0.35, 1 }
            local loss = db.currencyDeltaLossColor or { 0.95, 0.25, 0.2, 1 }
            local key = db.currencyTheme or "brown"
            local surfaces = {
                ResolveCurrencyThemeSurface(key, "section"),
                ResolveCurrencyThemeSurface(key, "row"),
                ResolveCurrencyThemeSurface(key, "rowAlt"),
            }
            for i, box in ipairs(previewBoxes) do
                local surface = surfaces[i] or surfaces[2]
                box.frame:SetBackdropColor(surface[1], surface[2], surface[3], surface[4] or 0.92)
                box.gainText:SetTextColor(gain[1], gain[2], gain[3], gain[4] or 1)
                box.lossText:SetTextColor(loss[1], loss[2], loss[3], loss[4] or 1)
            end
        end,
    })

    TrackCurrencyControl(CreateSlider(content, COLUMN_RIGHT_X, -440, L["Currency Width"], 240, 520, 4, function()
        return db.currencyWindowWidth or 336
    end, function(value)
        db.currencyWindowWidth = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackCurrencyControl(CreateSlider(content, COLUMN_RIGHT_X, -494, L["Currency Height"], 64, 700, 4, function()
        return db.currencyWindowHeight or 280
    end, function(value)
        db.currencyWindowHeight = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackCurrencyControl(CreateSlider(content, COLUMN_RIGHT_X, -548, L["Currency Font Size"], 10, 24, 1, function()
        return db.currencyWindowFontSize or 12
    end, function(value)
        db.currencyWindowFontSize = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackCurrencyControl(CreateSlider(content, COLUMN_RIGHT_X, -602, L["Currency Scale"], 0.70, 1.40, 0.05, function()
        return db.currencyWindowScale or 1.00
    end, function(value)
        db.currencyWindowScale = value
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return string.format("%.2f", value)
    end))

    -- Warband section
    CreateSectionTitle(content, COLUMN_LEFT_X, -730, L["Warband Panel"])
    local warbandToggleButton = CreateActionButton(content, COLUMN_RIGHT_X, -730, 180, L["Open Warband"], function()
        ToggleWarbandPanel()
    end)
    TrackWarbandControl(warbandToggleButton)
    warbandToggleButton.PreydatorRefresh = function(self)
        self:SetText((db.currencyWarbandWindowEnabled == true) and L["Close Warband"] or L["Open Warband"])
    end
    TrackWarbandControl(CreateCheckbox(content, COLUMN_LEFT_X, -790, L["Show Realm"], function()
        return db.currencyShowRealmInWarband == true
    end, function(value)
        db.currencyShowRealmInWarband = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    TrackWarbandControl(CreateCheckbox(content, COLUMN_LEFT_X, -818, L["Track Alts Weekly"], function()
        return db.currencyWarbandShowPreyTrack ~= false
    end, function(value)
        db.currencyWarbandShowPreyTrack = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    TrackWarbandControl(CreateCheckbox(content, COLUMN_LEFT_X, -846, L["Show Prey Weekly Completed"], function()
        return db.currencyWarbandPreyMode == "completed"
    end, function(value)
        db.currencyWarbandPreyMode = value and "completed" or "available"
        RefreshCurrencyTrackerPanel()
    end))
    TrackWarbandControl(CreateCheckbox(content, COLUMN_LEFT_X, -874, L["Hide Low Level Alts (78)"], function()
        return db.currencyWarbandHideLowLevel == true
    end, function(value)
        db.currencyWarbandHideLowLevel = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    TrackWarbandControl(CreateCheckbox(content, COLUMN_LEFT_X, -902, L["Use Icons for Warband Currencies"], function()
        return db.currencyWarbandUseIcons == true
    end, function(value)
        db.currencyWarbandUseIcons = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    TrackWarbandControl(CreateCheckbox(content, COLUMN_LEFT_X, -930, L["Hide Warband in Instance"], function()
        return db.currencyWarbandWindowHideInInstance == true
    end, function(value)
        db.currencyWarbandWindowHideInInstance = value and true or false
        RefreshCurrencyTrackerPanel()
    end))

    TrackWarbandControl(CreateSlider(content, COLUMN_RIGHT_X, -760, L["Warband Width"], 150, 900, 1, function()
        return db.currencyWarbandWidth or 420
    end, function(value)
        db.currencyWarbandWidth = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackWarbandControl(CreateSlider(content, COLUMN_RIGHT_X, -812, L["Warband Height"], 80, 600, 1, function()
        return db.currencyWarbandHeight or 250
    end, function(value)
        db.currencyWarbandHeight = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackWarbandControl(CreateSlider(content, COLUMN_RIGHT_X, -864, L["Warband Font Size"], 10, 24, 1, function()
        return db.currencyWarbandFontSize or 12
    end, function(value)
        db.currencyWarbandFontSize = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    TrackWarbandControl(CreateSlider(content, COLUMN_RIGHT_X, -916, L["Warband Scale"], 0.70, 1.40, 0.05, function()
        return db.currencyWarbandScale or 1.0
    end, function(value)
        db.currencyWarbandScale = value
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return string.format("%.2f", value)
    end))

    CreateSectionTitle(content, COLUMN_LEFT_X, -1016, L["Characters in Tracker"])
    TrackWarbandControl(CreateActionButton(content, COLUMN_LEFT_X, -1048, 180, L["Select All Characters"], function()
        SetAllWarbandCharactersShown(true)
    end))
    TrackWarbandControl(CreateActionButton(content, COLUMN_RIGHT_X, -1048, 200, L["Remove Unchecked Characters"], function()
        PurgeHiddenWarbandCharacters()
    end))
    for index, entry in ipairs(knownCharacters) do
        local level = tonumber(entry.level)
        local levelSuffix = level and string.format(" (L%d)", level) or ""
        local label = entry.charKey .. levelSuffix
        local rowIndex = math.floor((index - 1) / 2)
        local columnX = ((index - 1) % 2 == 0) and COLUMN_LEFT_X or COLUMN_RIGHT_X
        TrackWarbandControl(CreateCheckbox(content, columnX, -1082 - (rowIndex * 28), label, function()
            return IsWarbandCharacterShown(entry.charKey)
        end, function(value)
            SetWarbandCharacterShown(entry.charKey, value and true or false)
        end))
    end
    if #knownCharacters == 0 then
        local emptyNote = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        emptyNote:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_LEFT_X, -1082)
        emptyNote:SetWidth(300)
        emptyNote:SetJustifyH("LEFT")
        emptyNote:SetWordWrap(true)
        emptyNote:SetText(L["No cached characters yet. Log into alts to populate this list."])
    end

    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            local huntEnabled = IsModuleEnabled("hunt")
            local currencyEnabled = IsModuleEnabled("currency")
            local warbandEnabled = IsModuleEnabled("warband")

            for _, control in ipairs(huntControls) do
                if control and type(control.PreydatorSetEnabled) == "function" then
                    control:PreydatorSetEnabled(huntEnabled)
                end
            end
            for _, control in ipairs(currencyControls) do
                if control and type(control.PreydatorSetEnabled) == "function" then
                    control:PreydatorSetEnabled(currencyEnabled)
                end
            end
            for _, control in ipairs(warbandControls) do
                if control and type(control.PreydatorSetEnabled) == "function" then
                    control:PreydatorSetEnabled(warbandEnabled)
                end
            end

            UpdatePanelScrollBounds()
        end,
    })
    UpdatePanelScrollBounds()
end

local function BuildWarbandPage(owner, parent)
    local db = api.GetSettings()
    local trackedIDs = { 3392, 3316, 3383, 3341, 3343, 3345, 3310 }

    CreateSectionTitle(parent, COLUMN_LEFT_X, -10, L["Warband Window"])
    local warbandToggleButton = CreateActionButton(parent, COLUMN_LEFT_X, -38, 180, L["Open Warband"], function()
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.ToggleWarbandWindow) == "function" then
            tracker:ToggleWarbandWindow()
        else
            db.currencyWarbandWindowEnabled = not (db.currencyWarbandWindowEnabled == true)
            RefreshCurrencyTrackerPanel()
        end
        owner:RefreshControls()
    end)
    RegisterRefresher(owner, warbandToggleButton)
    warbandToggleButton.PreydatorRefresh = function(self)
        self:SetText((db.currencyWarbandWindowEnabled == true) and L["Close Warband"] or L["Open Warband"])
    end

    RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_LEFT_X, -68, L["Show Realm in Warband"], function()
        return db.currencyShowRealmInWarband == true
    end, function(value)
        db.currencyShowRealmInWarband = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    RegisterRefresher(owner, CreateSlider(parent, COLUMN_LEFT_X, -96, L["Warband Width"], 150, 900, 1, function()
        return db.currencyWarbandWidth or 420
    end, function(value)
        db.currencyWarbandWidth = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    RegisterRefresher(owner, CreateSlider(parent, COLUMN_LEFT_X, -148, L["Warband Height"], 80, 600, 1, function()
        return db.currencyWarbandHeight or 250
    end, function(value)
        db.currencyWarbandHeight = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    RegisterRefresher(owner, CreateSlider(parent, COLUMN_LEFT_X, -200, L["Warband Font Size"], 10, 24, 1, function()
        return db.currencyWarbandFontSize or 12
    end, function(value)
        db.currencyWarbandFontSize = math.floor(value + 0.5)
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    RegisterRefresher(owner, CreateSlider(parent, COLUMN_LEFT_X, -252, L["Warband Scale"], 0.7, 1.4, 0.05, function()
        return db.currencyWarbandScale or 1.0
    end, function(value)
        db.currencyWarbandScale = value
        RefreshCurrencyTrackerPanel()
    end, function(value)
        return string.format("%.2f", value)
    end))

    CreateSectionTitle(parent, COLUMN_RIGHT_X, -10, L["Tracked in Warband"])
    RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_RIGHT_X, -38, L["Show Prey Track (Alts) in Warband"], function()
        return db.currencyWarbandShowPreyTrack ~= false
    end, function(value)
        db.currencyWarbandShowPreyTrack = value and true or false
        RefreshCurrencyTrackerPanel()
    end))
    RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_RIGHT_X, -66, L["Prey Track Shows Completed"], function()
        return db.currencyWarbandPreyMode == "completed"
    end, function(value)
        db.currencyWarbandPreyMode = value and "completed" or "available"
        RefreshCurrencyTrackerPanel()
    end))
    for index, currencyID in ipairs(trackedIDs) do
        local currencyInfoAPI = _G.C_CurrencyInfo
        local info = currencyInfoAPI and currencyInfoAPI.GetCurrencyInfo and currencyInfoAPI.GetCurrencyInfo(currencyID)
        local label = (info and info.name) or ("Currency " .. tostring(currencyID))
        RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_RIGHT_X, -104 - ((index - 1) * 28), label, function()
            db.currencyWarbandTrackedIDs = db.currencyWarbandTrackedIDs or {}
            return db.currencyWarbandTrackedIDs[currencyID] ~= false
        end, function(value)
            db.currencyWarbandTrackedIDs = db.currencyWarbandTrackedIDs or {}
            db.currencyWarbandTrackedIDs[currencyID] = value and true or false
            RefreshCurrencyTrackerPanel()
        end))
    end
end

local function BuildBarPage(owner, parent)
    local db = api.GetSettings()
    local defaults = api.GetDefaults()
    local BAR_RIGHT_X = COLUMN_RIGHT_X + 10
    local customizationV2 = Preydator:GetModule("CustomizationStateV2")

    if type(db.barAccessibilityTheme) ~= "string" then
        db.barAccessibilityTheme = "default"
    end

    -- Track all bar controls so we can disable/grey them when the bar module is disabled
    local barControls = {}
    
    local function TrackBarControl(control)
        barControls[#barControls + 1] = control
        return RegisterRefresher(owner, control)
    end

    local function CloneColor(source, fallback)
        local color = type(source) == "table" and source or fallback
        return {
            (color and color[1]) or 1,
            (color and color[2]) or 1,
            (color and color[3]) or 1,
            (color and color[4]) or 1,
        }
    end

    local function ApplyBarAccessibilityTheme(key)
        local preset = BAR_ACCESSIBILITY_PRESETS[key]
        if not preset then
            db.fillColor = CloneColor(defaults.fillColor, db.fillColor)
            db.borderColor = CloneColor(defaults.borderColor, db.borderColor or db.fillColor)
            db.titleColor = CloneColor(defaults.titleColor, db.titleColor)
            db.percentColor = CloneColor(defaults.percentColor, db.percentColor)
            db.tickColor = CloneColor(defaults.tickColor, db.tickColor)
            db.bgColor = CloneColor(defaults.bgColor, db.bgColor)
            db.borderColorLinked = defaults.borderColorLinked ~= false
            db.barAccessibilityTheme = "default"
        else
            db.fillColor = CloneColor(preset.fillColor, db.fillColor)
            db.borderColor = CloneColor(preset.borderColor, db.borderColor or db.fillColor)
            db.titleColor = CloneColor(preset.titleColor, db.titleColor)
            db.percentColor = CloneColor(preset.percentColor, db.percentColor)
            db.tickColor = CloneColor(preset.tickColor, db.tickColor)
            db.bgColor = CloneColor(preset.bgColor, db.bgColor)
            db.borderColorLinked = preset.borderColorLinked == true
            db.barAccessibilityTheme = key
        end

        api.NormalizeColorSettings()
        api.ApplyBarSettings()
        api.RequestBarRefresh()
    end

    local contentViewport = CreateFrame("ScrollFrame", nil, parent)
    contentViewport:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    contentViewport:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 0)
    contentViewport:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, contentViewport)
    content:SetPoint("TOPLEFT", contentViewport, "TOPLEFT", 0, 0)
    content:SetSize(PANEL_WIDTH - 160, 960)
    contentViewport:SetScrollChild(content)

    local contentScrollSlider = CreateFrame("Slider", nil, contentViewport, "OptionsSliderTemplate")
    contentScrollSlider:SetOrientation("VERTICAL")
    contentScrollSlider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
    contentScrollSlider:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 26)
    contentScrollSlider:SetWidth(16)
    contentScrollSlider:SetMinMaxValues(0, 100)
    contentScrollSlider:SetValueStep(1)
    contentScrollSlider:SetObeyStepOnDrag(true)
    contentScrollSlider:SetValue(0)
    if contentScrollSlider.Low then contentScrollSlider.Low:Hide() end
    if contentScrollSlider.High then contentScrollSlider.High:Hide() end
    if contentScrollSlider.Text then contentScrollSlider.Text:Hide() end

    local function UpdateBarScrollBounds()
        contentViewport:UpdateScrollChildRect()
        local minValue, maxValue = contentScrollSlider:GetMinMaxValues()
        local currentValue = contentScrollSlider:GetValue() or 0
        local scrollRange = contentViewport:GetVerticalScrollRange() or 0
        if scrollRange < 0 then
            scrollRange = 0
        end

        contentScrollSlider:SetMinMaxValues(0, scrollRange)
        local clamped = Clamp(currentValue, 0, scrollRange)
        contentScrollSlider:SetValue(clamped)
        contentViewport:SetVerticalScroll(clamped)

        if scrollRange <= 0 then
            contentScrollSlider:SetEnabled(false)
            contentScrollSlider:SetAlpha(0.35)
        else
            contentScrollSlider:SetEnabled(true)
            contentScrollSlider:SetAlpha(1)
        end
    end

    contentScrollSlider:SetScript("OnValueChanged", function(self, value)
        local _, maxValue = self:GetMinMaxValues()
        local clamped = Clamp(value or 0, 0, maxValue or 0)
        contentViewport:SetVerticalScroll(clamped)
    end)

    contentViewport:SetScript("OnMouseWheel", function(_, delta)
        local minValue, maxValue = contentScrollSlider:GetMinMaxValues()
        local currentValue = contentScrollSlider:GetValue() or 0
        local step = 24
        local nextValue = Clamp(currentValue - (delta * step), minValue or 0, maxValue or 0)
        contentScrollSlider:SetValue(nextValue)
    end)

    if parent.HookScript then
        parent:HookScript("OnShow", UpdateBarScrollBounds)
        parent:HookScript("OnSizeChanged", UpdateBarScrollBounds)
    end
    if contentViewport.HookScript then
        contentViewport:HookScript("OnSizeChanged", UpdateBarScrollBounds)
    end
    if content.HookScript then
        content:HookScript("OnSizeChanged", UpdateBarScrollBounds)
    end

    local function IsHorizontalMode()
        return (db.orientation or constants.ORIENTATION_HORIZONTAL) ~= constants.ORIENTATION_VERTICAL
    end

    CreateSectionTitle(content, COLUMN_LEFT_X, -10, L["Bar"])
    local orientationDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -40, L["Bar Orientation"], 170, ORIENTATION_OPTIONS, function()
        return db.orientation
    end, function(key)
        db.orientation = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
        owner:RefreshControls()
        UpdateBarScrollBounds()
    end))
    TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -96, L["Texture"], 170, TEXTURE_OPTIONS, function()
        return db.textureKey
    end, function(key)
        db.textureKey = key
        api.ApplyBarSettings()
    end))
    TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -152, L["Title Font"], 170, FONT_OPTIONS, function()
        return db.titleFontKey
    end, function(key)
        db.titleFontKey = key
        api.ApplyBarSettings()
    end))
    TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -208, L["Percent Font"], 170, FONT_OPTIONS, function()
        return db.percentFontKey
    end, function(key)
        db.percentFontKey = key
        api.ApplyBarSettings()
    end))

    CreateSectionTitle(content, BAR_RIGHT_X, -10, L["Dimensions"])
    local horizontalScaleSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -40, L["Scale"], 0.5, 2, 0.05, function()
        return db.scale
    end, function(value)
        db.scale = value
        api.RequestBarRefresh()
    end, function(value)
        return string.format("%.2f", value)
    end))
    local verticalScaleSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -40, L["Scale"], 0.5, 2, 0.05, function()
        return db.verticalScale or 0.9
    end, function(value)
        db.verticalScale = value
        api.RequestBarRefresh()
    end, function(value)
        return string.format("%.2f", value)
    end))

    local horizontalWidthSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -92, L["Width"], 100, 350, 1, function()
        return db.horizontalWidth or db.width
    end, function(value)
        db.horizontalWidth = math.floor(value + 0.5)
        if IsHorizontalMode() then
            db.width = db.horizontalWidth
        end
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    local verticalWidthSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -92, L["Width"], 10, 60, 1, function()
        return db.verticalWidth or db.width
    end, function(value)
        db.verticalWidth = math.floor(value + 0.5)
        if not IsHorizontalMode() then
            db.width = db.verticalWidth
        end
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    local horizontalHeightSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -144, L["Height"], 10, 60, 1, function()
        return db.horizontalHeight or db.height
    end, function(value)
        db.horizontalHeight = math.floor(value + 0.5)
        if IsHorizontalMode() then
            db.height = db.horizontalHeight
        end
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    local verticalHeightSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -144, L["Height"], 100, 350, 1, function()
        return db.verticalHeight or db.height
    end, function(value)
        db.verticalHeight = math.floor(value + 0.5)
        if not IsHorizontalMode() then
            db.height = db.verticalHeight
        end
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    local fontSizeSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -196, L["Font Size"], 8, 24, 1, function()
        return db.fontSize
    end, function(value)
        db.fontSize = math.floor(value + 0.5)
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    CreateSectionTitle(content, COLUMN_LEFT_X, -264, L["Horizontal Dimensions"])
    local textDisplayDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -294, L["Text Display"], 170, LABEL_ROW_OPTIONS, function()
        return db.labelRowPosition
    end, function(key)
        if not IsHorizontalMode() then
            return
        end
        db.labelRowPosition = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local horizontalTextAlignmentDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -350, L["Horizontal Text Alignment"], 170, LABEL_MODE_OPTIONS, function()
        return db.stageLabelMode
    end, function(key)
        if not IsHorizontalMode() then
            return
        end
        db.stageLabelMode = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local progressSegmentsDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -406, L["Progress Segments"], 170, PROGRESS_SEGMENT_OPTIONS, function()
        return db.progressSegments
    end, function(key)
        db.progressSegments = key
        api.NormalizeProgressSettings()
        api.RequestBarRefresh()
    end))

    CreateSectionTitle(content, BAR_RIGHT_X, -264, L["Percent Display"])
    local percentDisplayDropdown = TrackBarControl(CreateDropdown(content, BAR_RIGHT_X, -294, L["Percent Display"], 170, PERCENT_DISPLAY_OPTIONS, function()
        return db.percentDisplay
    end, function(key)
        if not IsHorizontalMode() then
            return
        end
        db.percentDisplay = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local horizontalTextPlacementDropdown = TrackBarControl(CreateDropdown(content, BAR_RIGHT_X, -350, L["Horizontal Text Placement"], 170, LABEL_ROW_OPTIONS, function()
        return db.labelRowPosition
    end, function(key)
        if not IsHorizontalMode() then
            return
        end
        db.labelRowPosition = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    CreateSectionTitle(content, COLUMN_LEFT_X, -430, L["Visual Style"])
    TrackBarControl(CreateDropdown(content, BAR_RIGHT_X, -408, L["Accessibility"], 170, BAR_ACCESSIBILITY_OPTIONS, function()
        return db.barAccessibilityTheme or "default"
    end, function(key)
        ApplyBarAccessibilityTheme(key)
        owner:RefreshControls()
    end))
    TrackBarControl(CreateColorButton(content, COLUMN_LEFT_X, -460, L["Fill Color"], function()
        return db.fillColor
    end, function(color)
        db.fillColor = color
        db.barAccessibilityTheme = "default"
        api.ApplyBarSettings()
    end, true))
    TrackBarControl(CreateColorButton(content, BAR_RIGHT_X, -460, L["Border Color"], function()
        if db.borderColorLinked == false and db.borderColor then
            return db.borderColor
        end
        return db.fillColor
    end, function(color)
        db.borderColor = color
        db.borderColorLinked = false
        db.barAccessibilityTheme = "default"
        api.NormalizeColorSettings()
        api.ApplyBarSettings()
    end, true))
    TrackBarControl(CreateColorButton(content, COLUMN_LEFT_X, -494, L["Stage Title Color"], function()
        return db.titleColor
    end, function(color)
        db.titleColor = color
        db.barAccessibilityTheme = "default"
        api.RequestBarRefresh()
    end, true))
    TrackBarControl(CreateColorButton(content, BAR_RIGHT_X, -494, L["Percent Color"], function()
        return db.percentColor
    end, function(color)
        db.percentColor = color
        db.barAccessibilityTheme = "default"
        api.RequestBarRefresh()
    end, true))
    TrackBarControl(CreateColorButton(content, COLUMN_LEFT_X, -528, L["Tick Mark Color"], function()
        return db.tickColor
    end, function(color)
        db.tickColor = color
        db.barAccessibilityTheme = "default"
        api.RequestBarRefresh()
    end, true))
    TrackBarControl(CreateColorButton(content, BAR_RIGHT_X, -528, L["Background Color"], function()
        return db.bgColor
    end, function(color)
        db.bgColor = color
        db.barAccessibilityTheme = "default"
        api.ApplyBarSettings()
    end, true))

    local sparkCheck = TrackBarControl(CreateCheckbox(content, COLUMN_LEFT_X, -564, L["Display Spark Line"], function()
        return db.showSparkLine == true
    end, function(value)
        db.showSparkLine = value and true or false
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))
    local borderLinkCheck = TrackBarControl(CreateCheckbox(content, BAR_RIGHT_X, -564, L["Link border color to fill"], function()
        return db.borderColorLinked ~= false
    end, function(value)
        db.borderColorLinked = value and true or false
        db.barAccessibilityTheme = "default"
        api.NormalizeColorSettings()
        api.ApplyBarSettings()
    end))

    CreateSectionTitle(content, COLUMN_LEFT_X, -620, L["Vertical Dimensions"])
    local verticalFillDirectionDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -650, L["Vertical Fill Direction"], 170, VERTICAL_FILL_DIRECTION_OPTIONS, function()
        return db.verticalFillDirection
    end, function(key)
        db.verticalFillDirection = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))
    local verticalTextSideDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -706, L["Vertical Text Side"], 170, VERTICAL_SIDE_OPTIONS, function()
        return db.verticalTextSide
    end, function(key)
        db.verticalTextSide = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))
    local verticalTextAlignDropdown = TrackBarControl(CreateDropdown(content, COLUMN_LEFT_X, -762, L["Vertical Text Alignment"], 170, VERTICAL_TEXT_ALIGN_OPTIONS, function()
        return db.verticalTextAlign
    end, function(key)
        db.verticalTextAlign = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))
    local verticalTickPercentCheck = TrackBarControl(CreateCheckbox(content, COLUMN_LEFT_X, -818, L["Show Percentage at Tick Marks"], function()
        return db.showVerticalTickPercent == true
    end, function(value)
        db.showVerticalTickPercent = value and true or false
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local verticalNote = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    verticalNote:SetPoint("TOPLEFT", content, "TOPLEFT", BAR_RIGHT_X, -620)
    verticalNote:SetWidth(260)
    verticalNote:SetJustifyH("LEFT")
    verticalNote:SetWordWrap(true)
    verticalNote:SetText(L["HINT_VERTICAL_PERCENT_OFFSET"])

    local textOffsetSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -650, L["Vertical Text Offset"], 2, 60, 1, function()
        return db.verticalTextOffset or 10
    end, function(value)
        db.verticalTextOffset = math.floor(value + 0.5)
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    local percentOffsetSlider = TrackBarControl(CreateSlider(content, BAR_RIGHT_X, -706, L["Vertical Percent Offset"], 2, 60, 1, function()
        return db.verticalPercentOffset or 10
    end, function(value)
        db.verticalPercentOffset = math.floor(value + 0.5)
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))
    local verticalPercentSideDropdown = TrackBarControl(CreateDropdown(content, BAR_RIGHT_X, -806, L["Vertical Percent Tick Mark"], 170, VERTICAL_PERCENT_SIDE_OPTIONS, function()
        return db.verticalPercentSide
    end, function(key)
        db.verticalPercentSide = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))
    local verticalPercentDisplayDropdown = TrackBarControl(CreateDropdown(content, BAR_RIGHT_X, -862, L["Vertical Percent Display"], 170, VERTICAL_PERCENT_DISPLAY_OPTIONS, function()
        return db.verticalPercentDisplay
    end, function(key)
        db.verticalPercentDisplay = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local function ApplyBarModeState()
        local isHorizontal = IsHorizontalMode()
        local barEnabled = true
        if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
            barEnabled = customizationV2:IsModuleEnabled("bar") == true
        end

        horizontalScaleSlider:SetShown(isHorizontal)
        horizontalWidthSlider:SetShown(isHorizontal)
        horizontalHeightSlider:SetShown(isHorizontal)

        verticalScaleSlider:SetShown(not isHorizontal)
        verticalWidthSlider:SetShown(not isHorizontal)
        verticalHeightSlider:SetShown(not isHorizontal)

        if textDisplayDropdown.PreydatorSetEnabled then
            textDisplayDropdown:PreydatorSetEnabled(barEnabled and isHorizontal)
        end
        if horizontalTextAlignmentDropdown.PreydatorSetEnabled then
            horizontalTextAlignmentDropdown:PreydatorSetEnabled(barEnabled and isHorizontal)
        end
        if horizontalTextPlacementDropdown.PreydatorSetEnabled then
            horizontalTextPlacementDropdown:PreydatorSetEnabled(barEnabled and isHorizontal)
        end
        if percentDisplayDropdown.PreydatorSetEnabled then
            percentDisplayDropdown:PreydatorSetEnabled(barEnabled and isHorizontal)
        end
        if progressSegmentsDropdown.PreydatorSetEnabled then
            progressSegmentsDropdown:PreydatorSetEnabled(barEnabled)
        end
        if sparkCheck.PreydatorSetEnabled then
            sparkCheck:PreydatorSetEnabled(barEnabled and isHorizontal)
        end

        if verticalFillDirectionDropdown.PreydatorSetEnabled then
            verticalFillDirectionDropdown:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if verticalTextSideDropdown.PreydatorSetEnabled then
            verticalTextSideDropdown:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if verticalTextAlignDropdown.PreydatorSetEnabled then
            verticalTextAlignDropdown:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if verticalTickPercentCheck.PreydatorSetEnabled then
            verticalTickPercentCheck:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if textOffsetSlider.PreydatorSetEnabled then
            textOffsetSlider:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if percentOffsetSlider.PreydatorSetEnabled then
            percentOffsetSlider:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if verticalPercentSideDropdown.PreydatorSetEnabled then
            verticalPercentSideDropdown:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end
        if verticalPercentDisplayDropdown.PreydatorSetEnabled then
            verticalPercentDisplayDropdown:PreydatorSetEnabled(barEnabled and (not isHorizontal))
        end

        verticalNote:SetAlpha((barEnabled and (not isHorizontal)) and 1 or 0.45)

        for _, control in ipairs(barControls) do
            if control and type(control.PreydatorSetEnabled) == "function" then
                control:PreydatorSetEnabled(barEnabled)
            end
        end
    end

    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            ApplyBarModeState()
            UpdateBarScrollBounds()
        end,
    })

    ApplyBarModeState()
    UpdateBarScrollBounds()
end

local function BuildVerticalPage(owner, parent)
    local db = api.GetSettings()

    local function IsVerticalMode()
        return (db.orientation or constants.ORIENTATION_HORIZONTAL) == constants.ORIENTATION_VERTICAL
    end

    CreateSectionTitle(parent, COLUMN_LEFT_X, -10, L["Vertical Mode"])
    RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -40, L["Bar Orientation"], 170, ORIENTATION_OPTIONS, function()
        return db.orientation
    end, function(key)
        db.orientation = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
        owner:RefreshControls()
    end))

    RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -96, L["Vertical Fill Direction"], 170, VERTICAL_FILL_DIRECTION_OPTIONS, function()
        return db.verticalFillDirection
    end, function(key)
        db.verticalFillDirection = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -152, L["Vertical Text Side"], 170, VERTICAL_SIDE_OPTIONS, function()
        return db.verticalTextSide
    end, function(key)
        db.verticalTextSide = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -208, L["Vertical Text Alignment"], 190, VERTICAL_TEXT_ALIGN_OPTIONS, function()
        return db.verticalTextAlign
    end, function(key)
        db.verticalTextAlign = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local verticalPercentDisplayDropdown = RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -264, L["Vertical Percent Display"], 190, VERTICAL_PERCENT_DISPLAY_OPTIONS, function()
        return db.verticalPercentDisplay
    end, function(key)
        db.verticalPercentDisplay = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local verticalPercentSideDropdown = RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -320, L["Vertical Percent Tick Mark"], 170, VERTICAL_PERCENT_SIDE_OPTIONS, function()
        return db.verticalPercentSide
    end, function(key)
        db.verticalPercentSide = key
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local verticalTickPercentCheck = RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_LEFT_X, -364, L["Show Percentage at Tick Marks"], function()
        return db.showVerticalTickPercent == true
    end, function(value)
        db.showVerticalTickPercent = value and true or false
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end))

    local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", parent, "TOPLEFT", COLUMN_RIGHT_X, -36)
    note:SetWidth(260)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(L["HINT_VERTICAL_PERCENT_OFFSET"])

    CreateSectionTitle(parent, COLUMN_RIGHT_X, -10, L["Vertical Dimensions"])
    local verticalScaleSlider = RegisterRefresher(owner, CreateSlider(parent, COLUMN_RIGHT_X, -64, L["Scale"], 0.5, 2, 0.05, function()
        return db.verticalScale or 0.9
    end, function(value)
        db.verticalScale = value
        api.RequestBarRefresh()
    end, function(value)
        return string.format("%.2f", value)
    end))

    local verticalWidthSlider = RegisterRefresher(owner, CreateSlider(parent, COLUMN_RIGHT_X, -116, L["Width"], 10, 60, 1, function()
        return db.verticalWidth or db.width
    end, function(value)
        db.verticalWidth = math.floor(value + 0.5)
        if IsVerticalMode() then
            db.width = db.verticalWidth
        end
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    local verticalHeightSlider = RegisterRefresher(owner, CreateSlider(parent, COLUMN_RIGHT_X, -168, L["Height"], 100, 350, 1, function()
        return db.verticalHeight or db.height
    end, function(value)
        db.verticalHeight = math.floor(value + 0.5)
        if IsVerticalMode() then
            db.height = db.verticalHeight
        end
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    local textOffsetSlider = RegisterRefresher(owner, CreateSlider(parent, COLUMN_RIGHT_X, -224, L["Vertical Text Offset"], 2, 60, 1, function()
        return db.verticalTextOffset or 10
    end, function(value)
        db.verticalTextOffset = math.floor(value + 0.5)
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    local percentOffsetSlider = RegisterRefresher(owner, CreateSlider(parent, COLUMN_RIGHT_X, -280, L["Vertical Percent Offset"], 2, 60, 1, function()
        return db.verticalPercentOffset or 10
    end, function(value)
        db.verticalPercentOffset = math.floor(value + 0.5)
        api.NormalizeDisplaySettings()
        api.RequestBarRefresh()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    local function ApplyVerticalControlState()
        local enabled = IsVerticalMode()
        local percentMode = db.verticalPercentDisplay or constants.PERCENT_DISPLAY_INSIDE
        local percentNotOff = percentMode ~= constants.PERCENT_DISPLAY_OFF
        local textSide = db.verticalTextSide or "right"
        local tickMarkSide = db.verticalPercentSide or "center"
        local percentOffsetApplies = enabled and (
            textSide == "left"
            or textSide == "right"
            or tickMarkSide == "left"
            or tickMarkSide == "right"
        )

        if verticalPercentSideDropdown and verticalPercentSideDropdown.PreydatorSetEnabled then
            verticalPercentSideDropdown:PreydatorSetEnabled(enabled and percentNotOff)
        end
        if verticalTickPercentCheck and verticalTickPercentCheck.PreydatorSetEnabled then
            verticalTickPercentCheck:PreydatorSetEnabled(enabled and percentNotOff)
        end
        if textOffsetSlider.PreydatorSetEnabled then
            textOffsetSlider:PreydatorSetEnabled(enabled)
        end
        if percentOffsetSlider.PreydatorSetEnabled then
            percentOffsetSlider:PreydatorSetEnabled(percentOffsetApplies)
        end
        if verticalWidthSlider.PreydatorSetEnabled then
            verticalWidthSlider:PreydatorSetEnabled(enabled)
        end
        if verticalHeightSlider.PreydatorSetEnabled then
            verticalHeightSlider:PreydatorSetEnabled(enabled)
        end
        if verticalScaleSlider.PreydatorSetEnabled then
            verticalScaleSlider:PreydatorSetEnabled(enabled)
        end
    end

    local textOffsetBaseRefresh = textOffsetSlider.PreydatorRefresh
    textOffsetSlider.PreydatorRefresh = function(self)
        textOffsetBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local verticalPercentDisplayBaseRefresh = verticalPercentDisplayDropdown.PreydatorRefresh
    verticalPercentDisplayDropdown.PreydatorRefresh = function(self)
        verticalPercentDisplayBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local verticalPercentSideBaseRefresh = verticalPercentSideDropdown.PreydatorRefresh
    verticalPercentSideDropdown.PreydatorRefresh = function(self)
        verticalPercentSideBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local verticalTickPercentBaseRefresh = verticalTickPercentCheck.PreydatorRefresh
    verticalTickPercentCheck.PreydatorRefresh = function(self)
        verticalTickPercentBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local percentOffsetBaseRefresh = percentOffsetSlider.PreydatorRefresh
    percentOffsetSlider.PreydatorRefresh = function(self)
        percentOffsetBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local verticalWidthBaseRefresh = verticalWidthSlider.PreydatorRefresh
    verticalWidthSlider.PreydatorRefresh = function(self)
        verticalWidthBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local verticalScaleBaseRefresh = verticalScaleSlider.PreydatorRefresh
    verticalScaleSlider.PreydatorRefresh = function(self)
        verticalScaleBaseRefresh(self)
        ApplyVerticalControlState()
    end

    local verticalHeightBaseRefresh = verticalHeightSlider.PreydatorRefresh
    verticalHeightSlider.PreydatorRefresh = function(self)
        verticalHeightBaseRefresh(self)
        ApplyVerticalControlState()
    end
end

local function BuildTextPage(owner, parent)
    local db = api.GetSettings()
    local defaults = api.GetDefaults()
    local TEXT_RIGHT_X = COLUMN_RIGHT_X + 15

    CreateSectionTitle(parent, COLUMN_LEFT_X, -10, L["Prefix Labels"])
    for stageIndex = 1, constants.MAX_STAGE do
        local offset = -40 - ((stageIndex - 1) * 46)
        RegisterRefresher(owner, CreateTextInput(parent, COLUMN_LEFT_X, offset, string.format(L["Stage %d"], stageIndex), 220, function()
            if not db.stageSuffixLabels then db.stageSuffixLabels = {} end
            return db.stageSuffixLabels[stageIndex] or ""
        end, function(value)
            if not db.stageSuffixLabels then db.stageSuffixLabels = {} end
            db.stageSuffixLabels[stageIndex] = value
            api.NormalizeDisplaySettings()
            api.UpdateBarDisplay()
        end))
    end

    RegisterRefresher(owner, CreateTextInput(parent, COLUMN_LEFT_X, -234, L["Out of Zone Prefix"], 220, function()
        return db.outOfZonePrefix or ""
    end, function(value)
        db.outOfZonePrefix = value
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
    end))
    RegisterRefresher(owner, CreateTextInput(parent, COLUMN_LEFT_X, -280, L["Ambush Prefix"], 220, function()
        return db.ambushPrefix or "AMBUSH: "
    end, function(value)
        db.ambushPrefix = tostring(value or "AMBUSH: ")
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
    end))
    RegisterRefresher(owner, CreateTextInput(parent, COLUMN_LEFT_X, -326, L["Bloody Command Prefix"], 220, function()
        return db.bloodyCommandPrefix or "Bloody Command: "
    end, function(value)
        db.bloodyCommandPrefix = tostring(value or "Bloody Command: ")
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
    end))

    CreateSectionTitle(parent, TEXT_RIGHT_X, -10, L["Suffix Labels"])
    for stageIndex = 1, constants.MAX_STAGE do
        local offset = -40 - ((stageIndex - 1) * 46)
        RegisterRefresher(owner, CreateTextInput(parent, TEXT_RIGHT_X, offset, string.format(L["Stage %d"], stageIndex), 220, function()
            return db.stageLabels[stageIndex] or ""
        end, function(value)
            db.stageLabels[stageIndex] = value
            api.NormalizeLabelSettings()
            api.UpdateBarDisplay()
        end))
    end

    RegisterRefresher(owner, CreateTextInput(parent, TEXT_RIGHT_X, -234, L["Out of Zone Label"], 220, function()
        return db.outOfZoneLabel
    end, function(value)
        db.outOfZoneLabel = value
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
    end))
    RegisterRefresher(owner, CreateTextInput(parent, TEXT_RIGHT_X, -280, L["Ambush Suffix"], 220, function()
        return db.ambushSuffix or "preyTargetName"
    end, function(value)
        db.ambushSuffix = tostring(value or "preyTargetName")
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
    end))
    RegisterRefresher(owner, CreateTextInput(parent, TEXT_RIGHT_X, -326, L["Bloody Command Suffix"], 220, function()
        return db.bloodyCommandSuffix or "bloodyCommandSourceName"
    end, function(value)
        db.bloodyCommandSuffix = tostring(value or "bloodyCommandSourceName")
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
    end))
    CreateActionButton(parent, TEXT_RIGHT_X, -372, 180, L["Restore Default Names"], function()
        for stageIndex = 1, constants.MAX_STAGE do
            db.stageLabels[stageIndex] = defaults.stageLabels[stageIndex] or ""
        end
        db.outOfZoneLabel = constants.DEFAULT_OUT_OF_ZONE_LABEL
        db.ambushPrefix = "AMBUSH: "
        db.ambushSuffix = "preyTargetName"
        db.bloodyCommandPrefix = "Bloody Command: "
        db.bloodyCommandSuffix = "bloodyCommandSourceName"
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
        owner:RefreshControls()
    end)

end

local function BuildSoundsPage(owner, parent)
    local db = api.GetSettings()
    local soundsControls = {}

    local function TrackSoundsControl(control)
        soundsControls[#soundsControls + 1] = control
        return RegisterRefresher(owner, control)
    end

    local contentViewport = CreateFrame("ScrollFrame", nil, parent)
    contentViewport:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    contentViewport:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 0)
    contentViewport:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, contentViewport)
    content:SetPoint("TOPLEFT", contentViewport, "TOPLEFT", 0, 0)
    content:SetSize(PANEL_WIDTH - 160, 620)
    contentViewport:SetScrollChild(content)

    local contentScrollSlider = CreateFrame("Slider", nil, contentViewport, "OptionsSliderTemplate")
    contentScrollSlider:SetOrientation("VERTICAL")
    contentScrollSlider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
    contentScrollSlider:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 26)
    contentScrollSlider:SetWidth(16)
    contentScrollSlider:SetMinMaxValues(0, 100)
    contentScrollSlider:SetValueStep(1)
    contentScrollSlider:SetObeyStepOnDrag(true)
    contentScrollSlider:SetValue(0)
    if contentScrollSlider.Low then contentScrollSlider.Low:Hide() end
    if contentScrollSlider.High then contentScrollSlider.High:Hide() end
    if contentScrollSlider.Text then contentScrollSlider.Text:Hide() end

    local function UpdateSoundsScrollBounds()
        contentViewport:UpdateScrollChildRect()
        local currentValue = contentScrollSlider:GetValue() or 0
        local scrollRange = contentViewport:GetVerticalScrollRange() or 0
        if scrollRange < 0 then
            scrollRange = 0
        end

        contentScrollSlider:SetMinMaxValues(0, scrollRange)
        local clamped = Clamp(currentValue, 0, scrollRange)
        contentScrollSlider:SetValue(clamped)
        contentViewport:SetVerticalScroll(clamped)

        if scrollRange <= 0 then
            contentScrollSlider:SetEnabled(false)
            contentScrollSlider:SetAlpha(0.35)
        else
            contentScrollSlider:SetEnabled(true)
            contentScrollSlider:SetAlpha(1)
        end
    end

    contentScrollSlider:SetScript("OnValueChanged", function(self, value)
        local _, maxValue = self:GetMinMaxValues()
        local clamped = Clamp(value or 0, 0, maxValue or 0)
        contentViewport:SetVerticalScroll(clamped)
    end)

    contentViewport:SetScript("OnMouseWheel", function(_, delta)
        local minValue, maxValue = contentScrollSlider:GetMinMaxValues()
        local currentValue = contentScrollSlider:GetValue() or 0
        local step = 24
        local nextValue = Clamp(currentValue - (delta * step), minValue or 0, maxValue or 0)
        contentScrollSlider:SetValue(nextValue)
    end)

    if parent.HookScript then
        parent:HookScript("OnShow", UpdateSoundsScrollBounds)
        parent:HookScript("OnSizeChanged", UpdateSoundsScrollBounds)
    end
    if content.HookScript then
        content:HookScript("OnSizeChanged", UpdateSoundsScrollBounds)
    end

    TrackSoundsControl(CreateCheckbox(content, COLUMN_LEFT_X, -10, L["Ambush sound alert"], function()
        return db.ambushSoundEnabled ~= false
    end, function(value)
        db.ambushSoundEnabled = value and true or false
        api.NormalizeAmbushSettings()
    end))
    TrackSoundsControl(CreateCheckbox(content, COLUMN_RIGHT_X, -10, L["Ambush visual alert"], function()
        return db.ambushVisualEnabled ~= false
    end, function(value)
        db.ambushVisualEnabled = value and true or false
        api.NormalizeAmbushSettings()
    end))
    TrackSoundsControl(CreateCheckbox(content, COLUMN_LEFT_X, -38, L["Bloody Command sound alert"], function()
        return db.bloodyCommandSoundEnabled ~= false
    end, function(value)
        db.bloodyCommandSoundEnabled = value and true or false
        api.NormalizeAmbushSettings()
    end))
    TrackSoundsControl(CreateCheckbox(content, COLUMN_RIGHT_X, -38, L["Bloody Command visual alert"], function()
        return db.bloodyCommandVisualEnabled ~= false
    end, function(value)
        db.bloodyCommandVisualEnabled = value and true or false
        api.NormalizeAmbushSettings()
    end))
    TrackSoundsControl(CreateCheckbox(content, COLUMN_RIGHT_X, -66, L["Silence Arator (Astalor Bloodsworn)"], function()
        return db.silenceArator == true
    end, function(value)
        db.silenceArator = value and true or false
        api.ApplyAratorSilencing()
    end))

    TrackSoundsControl(CreateDropdown(content, COLUMN_LEFT_X, -82, L["Sound Channel"], 170, function()
        return CHANNEL_OPTIONS
    end, function()
        return db.soundChannel
    end, function(key)
        db.soundChannel = key
        api.NormalizeSoundSettings()
    end))

    CreateSectionTitle(content, COLUMN_LEFT_X, -130, L["Sound Selection"])

    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -160, string.format(L["Stage %d Sound"], 1), 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.stageSounds[1]
    end, function(key)
        db.stageSounds[1] = key
        api.NormalizeSoundSettings()
    end))
    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -214, string.format(L["Stage %d Sound"], 2), 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.stageSounds[2]
    end, function(key)
        db.stageSounds[2] = key
        api.NormalizeSoundSettings()
    end))
    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -268, string.format(L["Stage %d Sound"], 3), 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.stageSounds[3]
    end, function(key)
        db.stageSounds[3] = key
        api.NormalizeSoundSettings()
    end))
    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -322, string.format(L["Stage %d Sound"], 4), 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.stageSounds[4]
    end, function(key)
        db.stageSounds[4] = key
        api.NormalizeSoundSettings()
    end))

    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -376, L["Ambush Sound"], 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.ambushSoundPath
    end, function(key)
        db.ambushSoundPath = key
        api.NormalizeAmbushSettings()
    end))
    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -430, L["Bloody Command Sound"], 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.bloodyCommandSoundPath
    end, function(key)
        db.bloodyCommandSoundPath = key
        api.NormalizeAmbushSettings()
    end))
    TrackSoundsControl(CreateSoundPickerSelector(content, COLUMN_LEFT_X, -484, L["Echo of Predation Sound"], 170, function()
        return api.BuildSoundDropdownOptions()
    end, function()
        return db.echoOfPredationSoundPath
    end, function(key)
        db.echoOfPredationSoundPath = key
        api.NormalizeAmbushSettings()
    end))
    CreateSectionTitle(content, COLUMN_RIGHT_X, -102, L["Custom Files / Tests"])
    local combinedAudioHintText = tostring(L["HINT_AUDIO_SLIDER"] or "")
    local sliderHintText, customInputHintText = combinedAudioHintText:match("^([^\r\n]+)[\r\n]+(.+)$")
    if not sliderHintText or sliderHintText == "" then
        sliderHintText = combinedAudioHintText
    end

    local customHintStart = sliderHintText:find("Custom sound input", 1, true)
    if customHintStart then
        local extracted = sliderHintText:sub(customHintStart)
        sliderHintText = (sliderHintText:sub(1, customHintStart - 1):match("^%s*(.-)%s*$") or "")
        if not customInputHintText or customInputHintText == "" then
            customInputHintText = extracted
        end
    end

    if sliderHintText == "" then
        sliderHintText = "Slider values can be dragged or typed directly."
    end

    if not customInputHintText or customInputHintText == "" then
        customInputHintText = "Custom sound input accepts bare names, .ogg, or full addon paths."
    end

    local customSoundInput = CreateTextInput(content, COLUMN_RIGHT_X, -132, L["Custom Sound File"], 220, function()
        return ""
    end, function()
    end)
    TrackSoundsControl(customSoundInput)
    customSoundInput:SetScript("OnEditFocusLost", nil)
    customSoundInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    customSoundInput:SetText("")

    local customInputHint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    customInputHint:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_RIGHT_X, -186)
    customInputHint:SetWidth(250)
    customInputHint:SetJustifyH("LEFT")
    customInputHint:SetWordWrap(true)
    customInputHint:SetText(customInputHintText)

    local addFileButton = CreateActionButton(content, COLUMN_RIGHT_X, -224, 105, L["Add File"], function()
        local ok, message = api.AddSoundFileName(customSoundInput:GetText())
        if ok then
            customSoundInput:SetText("")
            owner:RefreshControls()
            print(string.format(L["Preydator: Added sound file '%s'."], tostring(message)))
        else
            print("Preydator: " .. tostring(message))
        end
    end)
    TrackSoundsControl(addFileButton)

    local removeFileButton = CreateActionButton(content, COLUMN_RIGHT_X + 115, -224, 105, L["Remove File"], function()
        local ok, message = api.RemoveSoundFileName(customSoundInput:GetText())
        if ok then
            customSoundInput:SetText("")
            owner:RefreshControls()
            print(string.format(L["Preydator: Removed sound file '%s'."], tostring(message)))
        else
            print("Preydator: " .. tostring(message))
        end
    end)
    TrackSoundsControl(removeFileButton)

    local TEST_SOUND_BUTTON_WIDTH = 190

    local testStage1Button = CreateActionButton(content, COLUMN_RIGHT_X, -268, TEST_SOUND_BUTTON_WIDTH, string.format(L["Test Stage %d"], 1), function()
        local path = api.ResolveStageSoundPath(1)
        if not path then
            print(string.format(L["Preydator: No stage %d sound configured."], 1))
            return
        end
        if not api.PlayTestSound(path) then
            print(string.format(L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"], 1, tostring(path)))
        end
    end)
    TrackSoundsControl(testStage1Button)

    local testStage2Button = CreateActionButton(content, COLUMN_RIGHT_X, -298, TEST_SOUND_BUTTON_WIDTH, string.format(L["Test Stage %d"], 2), function()
        local path = api.ResolveStageSoundPath(2)
        if not path then
            print(string.format(L["Preydator: No stage %d sound configured."], 2))
            return
        end
        if not api.PlayTestSound(path) then
            print(string.format(L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"], 2, tostring(path)))
        end
    end)
    TrackSoundsControl(testStage2Button)

    local testStage3Button = CreateActionButton(content, COLUMN_RIGHT_X, -328, TEST_SOUND_BUTTON_WIDTH, string.format(L["Test Stage %d"], 3), function()
        local path = api.ResolveStageSoundPath(3)
        if not path then
            print(string.format(L["Preydator: No stage %d sound configured."], 3))
            return
        end
        if not api.PlayTestSound(path) then
            print(string.format(L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"], 3, tostring(path)))
        end
    end)
    TrackSoundsControl(testStage3Button)

    local testStage4Button = CreateActionButton(content, COLUMN_RIGHT_X, -358, TEST_SOUND_BUTTON_WIDTH, string.format(L["Test Stage %d"], 4), function()
        local path = api.ResolveStageSoundPath(4)
        if not path then
            print(string.format(L["Preydator: No stage %d sound configured."], 4))
            return
        end
        if not api.PlayTestSound(path) then
            print(string.format(L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"], 4, tostring(path)))
        end
    end)
    TrackSoundsControl(testStage4Button)

    local testAmbushButton = CreateActionButton(content, COLUMN_RIGHT_X, -388, TEST_SOUND_BUTTON_WIDTH, L["Test Ambush"], function()
        local path = api.ResolveAmbushSoundPath()
        if not path then
            print("Preydator: No ambush sound configured.")
            return
        end
        if not api.PlayTestSound(path) then
            print("Preydator: Ambush sound file failed to play. Ensure this file exists as .ogg: " .. tostring(path))
        end
    end)
    TrackSoundsControl(testAmbushButton)
    local testBloodyCommandButton = CreateActionButton(content, COLUMN_RIGHT_X, -418, TEST_SOUND_BUTTON_WIDTH, L["Test Bloody Command"], function()
        local path = api.ResolveBloodyCommandSoundPath()
        if not path then
            print("Preydator: No Bloody Command sound configured.")
            return
        end
        if not api.PlayTestSound(path) then
            print("Preydator: Bloody Command sound file failed to play. Ensure this file exists as .ogg: " .. tostring(path))
        end
    end)
    TrackSoundsControl(testBloodyCommandButton)
    local testEchoOfPredationButton = CreateActionButton(content, COLUMN_RIGHT_X, -448, TEST_SOUND_BUTTON_WIDTH, L["Test Echo of Predation"], function()
        local path = api.ResolveEchoOfPredationSoundPath()
        if not path then
            print("Preydator: No Echo of Predation sound configured.")
            return
        end
        if not api.PlayTestSound(path) then
            print("Preydator: Echo of Predation sound file failed to play. Ensure this file exists as .ogg: " .. tostring(path))
        end
    end)
    TrackSoundsControl(testEchoOfPredationButton)
    local note = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_RIGHT_X, -488)
    note:SetWidth(250)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(sliderHintText)

    TrackSoundsControl(CreateSlider(content, COLUMN_RIGHT_X, -530, L["Enhance Sounds"], 0, 100, 5, function() return db.soundEnhance or 0 end, function(value)
        db.soundEnhance = math.floor(value + 0.5)
    end, function(value) return tostring(math.floor(value + 0.5)) end))

    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            local soundsEnabled = IsModuleEnabled("sounds")
            for _, control in ipairs(soundsControls) do
                if control and type(control.PreydatorSetEnabled) == "function" then
                    control:PreydatorSetEnabled(soundsEnabled)
                end
            end
            customInputHint:SetAlpha(soundsEnabled and 1 or 0.45)
            note:SetAlpha(soundsEnabled and 1 or 0.45)
            UpdateSoundsScrollBounds()
        end,
    })

    UpdateSoundsScrollBounds()
end

local function BuildThemePage(owner, parent)
    local db = api.GetSettings()
    local huntScanner = Preydator:GetModule("HuntScanner")

    local function ApplyThemeEditorPreviewRefresh()
        RefreshCurrencyTrackerPanel()
        RefreshHuntTrackerPanel()
        if huntScanner and type(huntScanner.SetThemePreviewEnabled) == "function" then
            huntScanner:SetThemePreviewEnabled(db.themeEditorPreviewInOptions == true)
        end
    end

    -- Ensure custom theme storage
    if type(db.customThemes) ~= "table" then db.customThemes = {} end
    if type(db.customThemeOrder) ~= "table" then db.customThemeOrder = {} end
    if type(db.themeEditorName) ~= "string" then db.themeEditorName = "" end
    if type(db.themeEditorFontKey) ~= "string" or not FONT_OPTIONS[db.themeEditorFontKey] then
        db.themeEditorFontKey = "frizqt"
    end
    if db.themeEditorPreviewInOptions == nil then
        db.themeEditorPreviewInOptions = false
    end
    if db.themeUseClassColors == nil then
        db.themeUseClassColors = true
    end
    if type(db.themeEditorColors) ~= "table" then
        db.themeEditorColors = {}
        for _, k in ipairs(THEME_COLOR_KEYS) do
            local v = THEME_EDITOR_PRESETS.brown[k]
            db.themeEditorColors[k] = { v[1], v[2], v[3], v[4] }
        end
    end
    for _, k in ipairs(THEME_COLOR_KEYS) do
        if type(db.themeEditorColors[k]) ~= "table" then
            local v = THEME_EDITOR_PRESETS.brown[k]
            db.themeEditorColors[k] = { v[1], v[2], v[3], v[4] }
        end
    end

    -- Scroll frame infrastructure (same pattern as BuildBarPage)
    local contentViewport = CreateFrame("ScrollFrame", nil, parent)
    contentViewport:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    contentViewport:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 0)
    contentViewport:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, contentViewport)
    content:SetPoint("TOPLEFT", contentViewport, "TOPLEFT", 0, 0)
    content:SetSize(PANEL_WIDTH - 160, 780)
    contentViewport:SetScrollChild(content)

    local themeScrollSlider = CreateFrame("Slider", nil, contentViewport, "OptionsSliderTemplate")
    themeScrollSlider:SetOrientation("VERTICAL")
    themeScrollSlider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -24)
    themeScrollSlider:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 26)
    themeScrollSlider:SetWidth(16)
    themeScrollSlider:SetMinMaxValues(0, 100)
    themeScrollSlider:SetValueStep(1)
    themeScrollSlider:SetObeyStepOnDrag(true)
    themeScrollSlider:SetValue(0)
    if themeScrollSlider.Low then themeScrollSlider.Low:Hide() end
    if themeScrollSlider.High then themeScrollSlider.High:Hide() end
    if themeScrollSlider.Text then themeScrollSlider.Text:Hide() end

    local function UpdateThemeScrollBounds()
        contentViewport:UpdateScrollChildRect()
        local currentValue = themeScrollSlider:GetValue() or 0
        local scrollRange = contentViewport:GetVerticalScrollRange() or 0
        if scrollRange < 0 then scrollRange = 0 end
        themeScrollSlider:SetMinMaxValues(0, scrollRange)
        local clamped = Clamp(currentValue, 0, scrollRange)
        themeScrollSlider:SetValue(clamped)
        contentViewport:SetVerticalScroll(clamped)
        if scrollRange <= 0 then
            themeScrollSlider:SetEnabled(false)
            themeScrollSlider:SetAlpha(0.35)
        else
            themeScrollSlider:SetEnabled(true)
            themeScrollSlider:SetAlpha(1)
        end
    end

    themeScrollSlider:SetScript("OnValueChanged", function(self, value)
        local _, maxValue = self:GetMinMaxValues()
        contentViewport:SetVerticalScroll(Clamp(value or 0, 0, maxValue or 0))
    end)
    contentViewport:SetScript("OnMouseWheel", function(_, delta)
        local minValue, maxValue = themeScrollSlider:GetMinMaxValues()
        themeScrollSlider:SetValue(Clamp((themeScrollSlider:GetValue() or 0) - (delta * 24), minValue or 0, maxValue or 0))
    end)
    if parent.HookScript then
        parent:HookScript("OnShow", UpdateThemeScrollBounds)
        parent:HookScript("OnSizeChanged", UpdateThemeScrollBounds)
    end
    if content.HookScript then
        content:HookScript("OnSizeChanged", UpdateThemeScrollBounds)
    end

    local THEME_RIGHT_X = 250

    -- ===== Section 1: Global Theme (left) | Per-Module Themes (right) =====
    CreateSectionTitle(content, COLUMN_LEFT_X, -10, L["Global Theme"])

    local globalThemeCheck = RegisterRefresher(owner, CreateCheckbox(content, COLUMN_LEFT_X, -38, L["Enable Global Theme"], function()
        return db.themeEnabled == true
    end, function(value)
        db.themeEnabled = value and true or false
        if value then
            local theme = db.globalTheme or "brown"
            db.currencyTheme = theme
            db.huntScannerTheme = theme
            db.currencyWarbandTheme = theme
            RefreshCurrencyTrackerPanel()
            RefreshHuntTrackerPanel()
        end
        owner:RefreshControls()
    end))

    local globalThemeDropdown = RegisterRefresher(owner, CreateDropdown(content, COLUMN_LEFT_X, -80, L["Global Panel Theme"], 170, GetAllThemeOptions, function()
        return db.globalTheme or "brown"
    end, function(key)
        db.globalTheme = key
        if db.themeEnabled then
            db.currencyTheme = key
            db.huntScannerTheme = key
            db.currencyWarbandTheme = key
            RefreshCurrencyTrackerPanel()
            RefreshHuntTrackerPanel()
        end
    end))

    local globalNote = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    globalNote:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_LEFT_X, -148)
    globalNote:SetWidth(210)
    globalNote:SetJustifyH("LEFT")
    globalNote:SetWordWrap(true)
    globalNote:SetText(L["When enabled, all panels use the global theme. Disable to set themes per-module below."])

    CreateSectionTitle(content, THEME_RIGHT_X, -10, L["Per-Module Themes"])

    local currencyThemeDropdown = RegisterRefresher(owner, CreateDropdown(content, THEME_RIGHT_X, -40, L["Currency Panel Theme"], 170, GetAllThemeOptions, function()
        return db.currencyTheme or "brown"
    end, function(key)
        db.currencyTheme = key
        RefreshCurrencyTrackerPanel()
    end))

    local huntThemeDropdown = RegisterRefresher(owner, CreateDropdown(content, THEME_RIGHT_X, -96, L["Hunt Table Theme"], 170, GetAllThemeOptions, function()
        return db.huntScannerTheme or "brown"
    end, function(key)
        db.huntScannerTheme = key
        RefreshHuntTrackerPanel()
    end))

    local warbandThemeDropdown = RegisterRefresher(owner, CreateDropdown(content, THEME_RIGHT_X, -152, L["Warband Theme"], 170, GetAllThemeOptions, function()
        return db.currencyWarbandTheme or "brown"
    end, function(key)
        db.currencyWarbandTheme = key
        RefreshCurrencyTrackerPanel()
    end))

    local perModuleNote = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    perModuleNote:SetPoint("TOPLEFT", content, "TOPLEFT", COLUMN_LEFT_X, -218)
    perModuleNote:SetWidth(220)
    perModuleNote:SetJustifyH("LEFT")
    perModuleNote:SetWordWrap(true)
    perModuleNote:SetText(L["Per-module themes are ignored while Global Theme is enabled."])

    local achievementThemeDropdown = RegisterRefresher(owner, CreateDropdown(content, THEME_RIGHT_X, -218, L["Achievements Theme"], 170, GetAllThemeOptions, function()
        return db.achievementTheme or "brown"
    end, function(key)
        db.achievementTheme = key
    end))
    if achievementThemeDropdown.PreydatorSetEnabled then
        achievementThemeDropdown:PreydatorSetEnabled(false)
    end

    RegisterRefresher(owner, CreateCheckbox(content, COLUMN_LEFT_X, -252, L["Class color Names"], function()
        return db.themeUseClassColors ~= false
    end, function(value)
        db.themeUseClassColors = value and true or false
        RefreshCurrencyTrackerPanel()
    end))

    RegisterRefresher(owner, CreateDropdown(content, COLUMN_LEFT_X, -286, L["Theme Font"], 170, FONT_OPTIONS, function()
        return db.themeEditorFontKey or "frizqt"
    end, function(key)
        db.themeEditorFontKey = key
        ApplyThemeEditorPreviewRefresh()
    end))

    local themePreviewButton = CreateActionButton(content, THEME_RIGHT_X, -286, 170, L["Theme Preview Pane"], function()
        db.themeEditorPreviewInOptions = not (db.themeEditorPreviewInOptions == true)
        ApplyThemeEditorPreviewRefresh()
        owner:RefreshControls()
    end)
    local themePreviewState = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    themePreviewState:SetPoint("TOPLEFT", content, "TOPLEFT", THEME_RIGHT_X + 178, -290)
    themePreviewState:SetWidth(110)
    themePreviewState:SetJustifyH("LEFT")
    themePreviewState:SetText("")
    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            themePreviewState:SetText((db.themeEditorPreviewInOptions == true) and L["On"] or L["Off"])
            themePreviewState:SetTextColor((db.themeEditorPreviewInOptions == true) and 0.45 or 0.75, (db.themeEditorPreviewInOptions == true) and 0.85 or 0.75, 0.45, 1)
            if db.themeEditorPreviewInOptions == true then
                ApplyThemeEditorPreviewRefresh()
            end
        end,
    })

    local baseGlobalRefresh = globalThemeCheck.PreydatorRefresh
    globalThemeCheck.PreydatorRefresh = function(self)
        if baseGlobalRefresh then baseGlobalRefresh(self) end

        local currencyEnabled = IsModuleEnabled("currency")
        local huntEnabled = IsModuleEnabled("hunt")
        local warbandEnabled = IsModuleEnabled("warband")
        local anyThemeModuleEnabled = currencyEnabled or huntEnabled or warbandEnabled
        local isGlobal = db.themeEnabled == true

        if globalThemeCheck.PreydatorSetEnabled then
            globalThemeCheck:PreydatorSetEnabled(anyThemeModuleEnabled)
        end

        if globalThemeDropdown.PreydatorSetEnabled then
            globalThemeDropdown:PreydatorSetEnabled(anyThemeModuleEnabled and isGlobal)
        end

        if currencyThemeDropdown.PreydatorSetEnabled then
            currencyThemeDropdown:PreydatorSetEnabled(currencyEnabled and (not isGlobal))
        end

        if huntThemeDropdown.PreydatorSetEnabled then
            huntThemeDropdown:PreydatorSetEnabled(huntEnabled and (not isGlobal))
        end

        if warbandThemeDropdown.PreydatorSetEnabled then
            warbandThemeDropdown:PreydatorSetEnabled(warbandEnabled and (not isGlobal))
        end

        if achievementThemeDropdown.PreydatorSetEnabled then achievementThemeDropdown:PreydatorSetEnabled(false) end
        if not anyThemeModuleEnabled then
            globalNote:SetAlpha(0.45)
            perModuleNote:SetAlpha(0.45)
        else
            globalNote:SetAlpha(1)
            perModuleNote:SetAlpha(isGlobal and 1 or 0.45)
        end
    end
    globalThemeCheck:PreydatorRefresh()

    -- ===== Section 2: Custom Theme Editor =====
    local TCOL1, TCOL2 = COLUMN_LEFT_X, THEME_RIGHT_X

    CreateSectionTitle(content, TCOL1, -340, L["Custom Theme Editor"])

    -- Load from Preset row
    CreateDropdown(content, TCOL1, -372, L["Load from Preset"], 150, GetAllThemeOptions, function()
        return db.themeEditorLoadKey or "brown"
    end, function(key)
        db.themeEditorLoadKey = key
        local source = THEME_EDITOR_PRESETS[key]
        if not source and db.customThemes then source = db.customThemes[key] end
        if source then
            for _, elem in ipairs(THEME_COLOR_KEYS) do
                local color = source[elem]
                if type(color) == "table" then
                    db.themeEditorColors[elem] = { color[1], color[2], color[3], color[4] }
                end
            end
            db.themeEditorFontKey = source.fontKey or db.themeEditorFontKey or "frizqt"
            ApplyThemeEditorPreviewRefresh()
            owner:RefreshControls()
        end
    end)

    CreateTextInput(content, 285, -372, L["Theme Name"], 170, function()
        return db.themeEditorName or ""
    end, function(value)
        db.themeEditorName = type(value) == "string" and value:match("^%s*(.-)%s*$") or ""
    end)

    -- 3×3 color picker grid
    local colorDefs = {
        { key = "section", label = L["Section BG"],   col = TCOL1, row = 1 },
        { key = "row",     label = L["Row BG"],       col = TCOL2, row = 1 },
        { key = "rowAlt",  label = L["Row Alt BG"],   col = TCOL1, row = 2 },
        { key = "border",  label = L["Border"],       col = TCOL2, row = 2 },
        { key = "header",  label = L["Header BG"],    col = TCOL1, row = 3 },
        { key = "title",   label = L["Title Color"],  col = TCOL2, row = 3 },
        { key = "text",    label = L["Text Color"],   col = TCOL1, row = 4 },
        { key = "muted",   label = L["Muted Color"],  col = TCOL2, row = 4 },
        { key = "season",  label = L["Season Color"], col = TCOL1, row = 5 },
    }
    for _, def in ipairs(colorDefs) do
        local yPos = -430 - (def.row - 1) * 34
        RegisterRefresher(owner, CreateColorButton(content, def.col, yPos, def.label, function()
            local c = db.themeEditorColors and db.themeEditorColors[def.key]
            return c or { 1, 1, 1, 1 }
        end, function(color)
            db.themeEditorColors = db.themeEditorColors or {}
            db.themeEditorColors[def.key] = { color[1], color[2], color[3], color[4] }
            ApplyThemeEditorPreviewRefresh()
        end, true))
    end

    -- Save Theme button
    CreateActionButton(content, TCOL1, -598, 120, L["Save Theme"], function()
        local name = db.themeEditorName:match("^%s*(.-)%s*$") or ""
        if #name == 0 then
            print("Preydator: " .. L["Please enter a theme name before saving."])
            return
        end
        local required = { "section", "row", "rowAlt", "border", "header", "title", "text", "muted", "season" }
        local ec = db.themeEditorColors or {}
        for _, k in ipairs(required) do
            if type(ec[k]) ~= "table" then
                print("Preydator: " .. L["Theme is missing color elements. Load a preset first."])
                return
            end
        end
        db.customThemes = db.customThemes or {}
        db.customThemeOrder = db.customThemeOrder or {}
        local isNew = not db.customThemes[name]
        db.customThemes[name] = {}
        for _, k in ipairs(required) do
            local c = ec[k]
            db.customThemes[name][k] = { c[1], c[2], c[3], c[4] }
        end
        db.customThemes[name].fontKey = db.themeEditorFontKey or "frizqt"
        if isNew then
            db.customThemeOrder[#db.customThemeOrder + 1] = name
        end
        db.themeEditorPreviewInOptions = false
        ApplyThemeEditorPreviewRefresh()
        owner:RefreshControls()
        print(string.format("Preydator: " .. L["Theme '%s' saved."], name))
    end)

    local saveNote = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    saveNote:SetPoint("TOPLEFT", content, "TOPLEFT", TCOL1 + 130, -602)
    saveNote:SetWidth(250)
    saveNote:SetJustifyH("LEFT")
    saveNote:SetWordWrap(false)
    saveNote:SetText(L["Saved themes appear in all theme dropdowns."])

    -- Delete Saved Theme row
    local function GetDeleteOptions()
        local opts = {}
        if type(db.customThemeOrder) == "table" then
            for _, name in ipairs(db.customThemeOrder) do
                if db.customThemes and db.customThemes[name] then
                    opts[#opts + 1] = { key = name, text = name }
                end
            end
        end
        if #opts == 0 then
            opts[#opts + 1] = { key = "__none__", text = L["(no saved themes)"] }
        end
        return opts
    end

    RegisterRefresher(owner, CreateDropdown(content, TCOL1, -632, L["Delete Saved Theme"], 170, GetDeleteOptions, function()
        return db.themeEditorDeleteKey or (type(db.customThemeOrder) == "table" and db.customThemeOrder[1]) or "__none__"
    end, function(key)
        db.themeEditorDeleteKey = key
    end))

    CreateActionButton(content, TCOL1 + 207, -660, 80, L["Delete"], function()
        local name = db.themeEditorDeleteKey
        if not name or name == "__none__" then return end
        if not db.customThemes or not db.customThemes[name] then return end
        db.customThemes[name] = nil
        for i, n in ipairs(db.customThemeOrder) do
            if n == name then table.remove(db.customThemeOrder, i); break end
        end

        local function ReassignTheme(settingKey)
            if db[settingKey] == name then
                db[settingKey] = "brown"
                return true
            end
            return false
        end

        local changed = false
        changed = ReassignTheme("globalTheme") or changed
        changed = ReassignTheme("currencyTheme") or changed
        changed = ReassignTheme("huntScannerTheme") or changed
        changed = ReassignTheme("currencyWarbandTheme") or changed
        changed = ReassignTheme("achievementTheme") or changed

        if db.themeEnabled == true and db.globalTheme == "brown" then
            db.currencyTheme = "brown"
            db.huntScannerTheme = "brown"
            db.currencyWarbandTheme = "brown"
            changed = true
        end

        if db.themeEditorLoadKey == name then
            db.themeEditorLoadKey = "brown"
        end
        db.themeEditorDeleteKey = nil
        if changed then
            RefreshCurrencyTrackerPanel()
            RefreshHuntTrackerPanel()
        end
        owner:RefreshControls()
        print(string.format("Preydator: " .. L["Theme '%s' deleted."], name))
    end)

    RegisterRefresher(owner, { PreydatorRefresh = function() UpdateThemeScrollBounds() end })
    UpdateThemeScrollBounds()
end

local function BuildAchievementsPage(owner, parent)
    local db = api.GetSettings()

    local function ConfigureCheckboxLabel(control, width)
        if not (control and control.Text and control.Text.SetWidth) then
            return
        end

        control.Text:SetWidth(width)
        control.Text:SetJustifyH("LEFT")
        if control.Text.SetWordWrap then
            control.Text:SetWordWrap(true)
        end
    end

    local function ToggleAchievementPreview()
        local huntScanner = Preydator:GetModule("HuntScanner")
        local enabled = not (db.huntScannerPreviewInOptions == true)
        if huntScanner and type(huntScanner.SetPreviewEnabled) == "function" then
            huntScanner:SetPreviewEnabled(enabled)
        else
            db.huntScannerPreviewInOptions = enabled
            RefreshHuntTrackerPanel()
        end
        owner:RefreshControls()
    end

    CreateSectionTitle(parent, COLUMN_LEFT_X, -10, L["Achievements"])
    local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -42)
    note:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -42)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(L["Hunt Tracker drives achievement indicators and tooltips in the hunt list. Use preview to test icon style, icon size, and tooltip names with sample achievement data."])

    local previewButton = RegisterRefresher(owner, CreateActionButton(parent, COLUMN_LEFT_X + 24, -304, 180, L["Show Preview Pane"], function()
        ToggleAchievementPreview()
    end))
    previewButton.PreydatorRefresh = function(self)
        self:SetText((db.huntScannerPreviewInOptions == true) and L["Hide Preview Pane"] or L["Show Preview Pane"])
    end

    local signalCheck = RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_LEFT_X, -106, L["Show Achievement Signals In Hunt Tracker"], function()
        return db.huntScannerAchievementSignals ~= false
    end, function(value)
        db.huntScannerAchievementSignals = value and true or false
        RefreshHuntTrackerPanel()
    end))
    ConfigureCheckboxLabel(signalCheck, 320)

    local tooltipCheck = RegisterRefresher(owner, CreateCheckbox(parent, COLUMN_LEFT_X, -142, L["Show Achievement Names On Mouseover"], function()
        return db.huntScannerAchievementTooltip ~= false
    end, function(value)
        db.huntScannerAchievementTooltip = value and true or false
        RefreshHuntTrackerPanel()
    end))
    ConfigureCheckboxLabel(tooltipCheck, 320)

    local styleDropdown = RegisterRefresher(owner, CreateDropdown(parent, COLUMN_LEFT_X, -184, L["Achievement Signal Style"], 170, ACHIEVEMENT_SIGNAL_STYLE_OPTIONS, function()
        return db.huntScannerAchievementSignalStyle or "icon_count"
    end, function(value)
        db.huntScannerAchievementSignalStyle = value
        RefreshHuntTrackerPanel()
    end))

    local badgeColorButton = RegisterRefresher(owner, CreateColorButton(parent, COLUMN_LEFT_X, -244, L["Achievement Badge Color"], function()
        return db.huntScannerAchievementBadgeColor or { 1.00, 0.86, 0.00, 1.00 }
    end, function(color)
        db.huntScannerAchievementBadgeColor = { color[1], color[2], color[3], color[4] or 1 }
        RefreshHuntTrackerPanel()
    end, true))

    local iconSizeSlider = RegisterRefresher(owner, CreateSlider(parent, COLUMN_LEFT_X, -286, L["Achievement Icon Size"], 12, 32, 1, function()
        return tonumber(db.huntScannerAchievementIconSize) or 18
    end, function(value)
        db.huntScannerAchievementIconSize = math.floor(value + 0.5)
        RefreshHuntTrackerPanel()
    end, function(value)
        return tostring(math.floor(value + 0.5))
    end))

    previewButton:SetPoint("TOPLEFT", parent, "TOPLEFT", COLUMN_LEFT_X + 24, -340)

    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            local enabled = db.huntScannerAchievementSignals ~= false
            if tooltipCheck and tooltipCheck.PreydatorSetEnabled then
                tooltipCheck:PreydatorSetEnabled(enabled)
            end
            if styleDropdown and styleDropdown.PreydatorSetEnabled then
                styleDropdown:PreydatorSetEnabled(enabled)
            end
            if badgeColorButton and badgeColorButton.PreydatorSetEnabled then
                badgeColorButton:PreydatorSetEnabled(enabled)
            end
            if iconSizeSlider and iconSizeSlider.PreydatorSetEnabled then
                iconSizeSlider:PreydatorSetEnabled(enabled and (db.huntScannerAchievementSignalStyle ~= "count_only"))
            end
            if signalCheck and signalCheck.PreydatorSetEnabled then
                signalCheck:PreydatorSetEnabled(IsModuleEnabled("hunt"))
            end
            if previewButton and previewButton.PreydatorSetEnabled then
                previewButton:PreydatorSetEnabled(IsModuleEnabled("hunt"))
            end
        end,
    })
end

local function BuildProfilesPage(owner, parent)
    local PROFILE_LEFT_X = COLUMN_LEFT_X
    local PROFILE_RIGHT_X = 258
    local PROFILE_NOTE_WIDTH = 236
    local PROFILE_DROPDOWN_WIDTH = 170
    local PROFILE_BUTTON_WIDTH = 170

    local function GetActiveProfileNameSafe()
        return api.GetActiveProfileName() or "Default"
    end

    local function GetAllProfileNamesSafe()
        local names = api.GetAllProfileNames()
        if type(names) == "table" and #names > 0 then
            return names
        end
        return { "Default" }
    end

    local function CreateProfileNote(x, y, width, text)
        local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        note:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        note:SetWidth(width)
        note:SetJustifyH("LEFT")
        note:SetWordWrap(true)
        note:SetText(text)
        return note
    end

    local function TrimProfileName(value)
        value = tostring(value or "")
        return (value:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function BuildAlternateProfileOptions()
        local active = GetActiveProfileNameSafe()
        local options = {}
        for _, name in ipairs(GetAllProfileNamesSafe()) do
            if name ~= active then
                options[#options + 1] = { key = name, text = name }
            end
        end
        return options
    end

    local function ResolveAlternateProfile(currentValue)
        local options = BuildAlternateProfileOptions()
        for _, option in ipairs(options) do
            if option.key == currentValue then
                return currentValue
            end
        end
        return options[1] and options[1].key or nil
    end

    parent.PreydatorCopyFromProfile = ResolveAlternateProfile(parent.PreydatorCopyFromProfile)
    parent.PreydatorDeleteProfile = ResolveAlternateProfile(parent.PreydatorDeleteProfile)

    CreateSectionTitle(parent, PROFILE_LEFT_X, -10, L["Profiles"])
    CreateProfileNote(PROFILE_LEFT_X, -42, 500, L["Change active profile, create a new one, copy settings between profiles, reset the current profile, or delete an unused profile."])

    CreateSectionTitle(parent, PROFILE_LEFT_X, -96, L["Active Profile"])
    CreateProfileNote(PROFILE_LEFT_X, -126, PROFILE_NOTE_WIDTH, L["Switch profiles to load a different saved setup immediately."])

    local activeProfileStatus = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    activeProfileStatus:SetPoint("TOPLEFT", parent, "TOPLEFT", PROFILE_LEFT_X, -154)
    activeProfileStatus:SetJustifyH("LEFT")
    activeProfileStatus:SetText("")
    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            activeProfileStatus:SetText(string.format("%s %s", L["Current Profile:"], tostring(GetActiveProfileNameSafe())))
        end,
    })

    RegisterRefresher(owner, CreateDropdown(parent, PROFILE_LEFT_X, -178, L["Current Profile"], PROFILE_DROPDOWN_WIDTH,
        function()
            local options = {}
            for _, name in ipairs(GetAllProfileNamesSafe()) do
                options[#options + 1] = { key = name, text = name }
            end
            return options
        end,
        function()
            return GetActiveProfileNameSafe()
        end,
        function(key)
            if key ~= GetActiveProfileNameSafe() then
                api.SwitchToProfile(key)
                parent.PreydatorCopyFromProfile = ResolveAlternateProfile(parent.PreydatorCopyFromProfile)
                parent.PreydatorDeleteProfile = ResolveAlternateProfile(parent.PreydatorDeleteProfile)
                owner:RefreshControls()
            end
        end
    ))

    CreateSectionTitle(parent, PROFILE_RIGHT_X, -96, L["Manage Profiles"])
    CreateProfileNote(PROFILE_RIGHT_X, -126, PROFILE_NOTE_WIDTH, L["Reset the active profile or delete another unused profile."])

    CreateActionButton(parent, PROFILE_RIGHT_X, -170, PROFILE_BUTTON_WIDTH, L["Reset to Defaults"], function()
        api.ResetCurrentProfile()
        owner:RefreshControls()
    end)

    local deleteDropdown = RegisterRefresher(owner, CreateDropdown(parent, PROFILE_RIGHT_X, -212, L["Delete Profile"], PROFILE_DROPDOWN_WIDTH,
        function()
            return BuildAlternateProfileOptions()
        end,
        function()
            parent.PreydatorDeleteProfile = ResolveAlternateProfile(parent.PreydatorDeleteProfile)
            return parent.PreydatorDeleteProfile
        end,
        function(key)
            parent.PreydatorDeleteProfile = key
        end
    ))

    local deleteButton = CreateActionButton(parent, PROFILE_RIGHT_X, -263, PROFILE_BUTTON_WIDTH, L["Delete Profile"], function()
        local profileName = ResolveAlternateProfile(parent.PreydatorDeleteProfile)
        if not profileName then
            print("Preydator: " .. L["No removable profile is available."])
            return
        end
        local ok, err = api.DeleteProfile(profileName)
        if not ok then
            print("Preydator: " .. tostring(err))
            return
        end
        parent.PreydatorCopyFromProfile = ResolveAlternateProfile(parent.PreydatorCopyFromProfile)
        parent.PreydatorDeleteProfile = ResolveAlternateProfile(parent.PreydatorDeleteProfile)
        owner:RefreshControls()
    end)

    CreateSectionTitle(parent, PROFILE_LEFT_X, -232, L["New Profile"])
    CreateProfileNote(PROFILE_LEFT_X, -262, PROFILE_NOTE_WIDTH, L["Enter a name and optionally copy your current settings into the new profile."])

    local newNameLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    newNameLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", PROFILE_LEFT_X, -298)
    newNameLabel:SetText(L["Profile Name:"])

    local newNameEdit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    newNameEdit:SetSize(190, 20)
    newNameEdit:SetAutoFocus(false)
    newNameEdit:SetTextInsets(6, 6, 0, 0)
    newNameEdit:SetPoint("TOPLEFT", newNameLabel, "BOTTOMLEFT", 0, -6)
    newNameEdit:SetText("")
    newNameEdit:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    newNameEdit.copyCurrentEnabled = false
    RegisterRefresher(owner, CreateCheckbox(parent, PROFILE_LEFT_X, -344, L["Copy current settings"], function()
        return newNameEdit.copyCurrentEnabled == true
    end, function(value)
        newNameEdit.copyCurrentEnabled = value and true or false
    end))

    CreateActionButton(parent, PROFILE_LEFT_X, -372, PROFILE_BUTTON_WIDTH, L["Create Profile"], function()
        local name = TrimProfileName(newNameEdit:GetText())
        if name == "" then
            print("Preydator: " .. L["Please enter a profile name."])
            return
        end
        local copyFrom = newNameEdit.copyCurrentEnabled and GetActiveProfileNameSafe() or nil
        local ok, err = api.CreateProfile(name, copyFrom)
        if not ok then
            print("Preydator: " .. tostring(err))
            return
        end
        newNameEdit:SetText("")
        newNameEdit.copyCurrentEnabled = false
        parent.PreydatorCopyFromProfile = name
        parent.PreydatorDeleteProfile = name
        owner:RefreshControls()
    end)

    CreateSectionTitle(parent, PROFILE_RIGHT_X, -310, L["Copy From"])
    CreateProfileNote(PROFILE_RIGHT_X, -340, PROFILE_NOTE_WIDTH, L["Copy another profile into the current one."])

    local copyDropdown = RegisterRefresher(owner, CreateDropdown(parent, PROFILE_RIGHT_X, -374, L["Source Profile"], PROFILE_DROPDOWN_WIDTH,
        function()
            return BuildAlternateProfileOptions()
        end,
        function()
            parent.PreydatorCopyFromProfile = ResolveAlternateProfile(parent.PreydatorCopyFromProfile)
            return parent.PreydatorCopyFromProfile
        end,
        function(key)
            parent.PreydatorCopyFromProfile = key
        end
    ))

    local copyButton = CreateActionButton(parent, PROFILE_RIGHT_X, -432, PROFILE_BUTTON_WIDTH, L["Copy Into Current"], function()
        local sourceName = ResolveAlternateProfile(parent.PreydatorCopyFromProfile)
        if not sourceName then
            print("Preydator: " .. L["Select a source profile first."])
            return
        end
        api.CopyProfileFrom(sourceName)
        owner:RefreshControls()
    end)

    RegisterRefresher(owner, {
        PreydatorRefresh = function()
            local hasAlternateProfile = ResolveAlternateProfile(parent.PreydatorCopyFromProfile) ~= nil
            if copyButton and copyButton.SetEnabled then
                copyButton:SetEnabled(hasAlternateProfile)
            end
            if copyButton then
                copyButton:SetAlpha(hasAlternateProfile and 1 or 0.4)
            end
            if copyDropdown and copyDropdown.PreydatorSetEnabled then
                copyDropdown:PreydatorSetEnabled(hasAlternateProfile)
            end

            local hasRemovableProfile = ResolveAlternateProfile(parent.PreydatorDeleteProfile) ~= nil
            if deleteButton and deleteButton.SetEnabled then
                deleteButton:SetEnabled(hasRemovableProfile)
            end
            if deleteButton then
                deleteButton:SetAlpha(hasRemovableProfile and 1 or 0.4)
            end
            if deleteDropdown and deleteDropdown.PreydatorSetEnabled then
                deleteDropdown:PreydatorSetEnabled(hasRemovableProfile)
            end
        end,
    })

end

local function BuildAdvancedPage(owner, parent)
    local db = api.GetSettings()
    local defaults = api.GetDefaults()

    local ADV_LEFT_X = COLUMN_LEFT_X
    local ADV_RIGHT_X = 258
    local ADV_TEXT_WIDTH = 236
    local ADV_BUTTON_WIDTH = 170

    local function CreateAdvancedNote(x, y, text)
        local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        note:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        note:SetWidth(ADV_TEXT_WIDTH)
        note:SetJustifyH("LEFT")
        note:SetWordWrap(true)
        note:SetText(text)
        return note
    end

    -- Left column: position + maintenance
    CreateSectionTitle(parent, ADV_LEFT_X, -10, L["Position Reset"])
    CreateAdvancedNote(ADV_LEFT_X, -40, L["Reset frame anchors if windows are off-screen or misplaced."])

    CreateActionButton(parent, ADV_LEFT_X, -78, ADV_BUTTON_WIDTH, L["Reset Bar Position"], function()
        db.point = {
            anchor = defaults.point.anchor,
            relativePoint = defaults.point.relativePoint,
            x = defaults.point.x,
            y = defaults.point.y,
        }
        api.ApplyBarSettings()
        owner:RefreshControls()
    end)

    CreateActionButton(parent, ADV_LEFT_X, -110, ADV_BUTTON_WIDTH, L["Reset Tracker Positions"], function()
        db.currencyWindowPoint = {
            anchor = defaults.currencyWindowPoint.anchor,
            relativePoint = defaults.currencyWindowPoint.relativePoint,
            x = defaults.currencyWindowPoint.x,
            y = defaults.currencyWindowPoint.y,
        }
        db.currencyWarbandWindowPoint = {
            anchor = defaults.currencyWarbandWindowPoint.anchor,
            relativePoint = defaults.currencyWarbandWindowPoint.relativePoint,
            x = defaults.currencyWarbandWindowPoint.x,
            y = defaults.currencyWarbandWindowPoint.y,
        }
        db.huntScannerSide = defaults.huntScannerSide
        db.huntScannerAnchorAlign = defaults.huntScannerAnchorAlign
        RefreshCurrencyTrackerPanel()
        RefreshHuntTrackerPanel()
        owner:RefreshControls()
    end)

    CreateSectionTitle(parent, ADV_LEFT_X, -166, L["Maintenance"])
    CreateAdvancedNote(ADV_LEFT_X, -196, L["Utility actions for release notes and hunt scanner cache maintenance."])

    CreateActionButton(parent, ADV_LEFT_X, -234, ADV_BUTTON_WIDTH, L["Show What's New"], function()
        db.currencyWhatsNewSeenVersion = nil
        db.soundDefaultsPromptSeenVersion = nil

        if type(Preydator.ShowSoundDefaultsPromptIfNeeded) == "function" then
            Preydator:ShowSoundDefaultsPromptIfNeeded()
        end

        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.ShowCurrencyWhatsNew) == "function" then
            tracker:ShowCurrencyWhatsNew(true)
        end
    end)

    CreateActionButton(parent, ADV_LEFT_X, -266, ADV_BUTTON_WIDTH, L["Refresh Hunt Cache"], function()
        local huntScanner = Preydator:GetModule("HuntScanner")
        if huntScanner and type(huntScanner.RefreshRewardCache) == "function" then
            huntScanner:RefreshRewardCache()
            print("Preydator: Hunt reward cache refresh queued.")
        end
    end)

    CreateActionButton(parent, ADV_LEFT_X, -298, ADV_BUTTON_WIDTH, L["Refresh Hunt Table Now"], function()
        local huntScanner = Preydator:GetModule("HuntScanner")
        if huntScanner and type(huntScanner.RefreshNow) == "function" then
            huntScanner:RefreshNow()
        end
    end)

    CreateActionButton(parent, ADV_LEFT_X, -330, ADV_BUTTON_WIDTH, L["Clear Achievement Cache"], function()
        local huntScanner = Preydator:GetModule("HuntScanner")
        if huntScanner and type(huntScanner.ClearAchievementCache) == "function" then
            huntScanner:ClearAchievementCache()
            print("Preydator: Cleared hunt achievement cache.")
        end
    end)

    CreateSectionTitle(parent, ADV_LEFT_X, -384, L["Notes"])
    CreateAdvancedNote(ADV_LEFT_X, -414, L["HINT_ADVANCED_NOTES"])

    -- Right column: restore + debug
    CreateSectionTitle(parent, ADV_RIGHT_X, -10, L["Restore / Reset"])
    CreateAdvancedNote(ADV_RIGHT_X, -40, L["Restore text and audio defaults, or fully reset all profile settings."])

    CreateActionButton(parent, ADV_RIGHT_X, -78, ADV_BUTTON_WIDTH, L["Restore Default Names"], function()
        for stageIndex = 1, (constants.MAX_STAGE - 1) do
            db.stageLabels[stageIndex] = defaults.stageLabels[stageIndex] or ""
        end
        db.outOfZoneLabel = constants.DEFAULT_OUT_OF_ZONE_LABEL
        db.ambushPrefix = "AMBUSH: "
        db.ambushSuffix = "preyTargetName"
        db.bloodyCommandPrefix = "Bloody Command: "
        db.bloodyCommandSuffix = "bloodyCommandSourceName"
        api.NormalizeLabelSettings()
        api.UpdateBarDisplay()
        owner:RefreshControls()
    end)

    CreateActionButton(parent, ADV_RIGHT_X, -110, ADV_BUTTON_WIDTH, L["Restore Default Sounds"], function()
        db.soundsEnabled = defaults.soundsEnabled
        db.soundChannel = defaults.soundChannel
        db.soundEnhance = defaults.soundEnhance
        db.ambushSoundEnabled = defaults.ambushSoundEnabled
        db.ambushVisualEnabled = defaults.ambushVisualEnabled
        db.ambushSoundPath = defaults.ambushSoundPath
        db.bloodyCommandSoundEnabled = defaults.bloodyCommandSoundEnabled
        db.bloodyCommandVisualEnabled = defaults.bloodyCommandVisualEnabled
        db.bloodyCommandSoundPath = defaults.bloodyCommandSoundPath
        db.echoOfPredationSoundPath = defaults.echoOfPredationSoundPath
        db.silenceArator = defaults.silenceArator
        api.ApplyAratorSilencing()
        db.soundFileNames = {}
        for _, fileName in ipairs(constants.DEFAULT_SOUND_FILENAMES) do
            db.soundFileNames[#db.soundFileNames + 1] = fileName
        end
        for stageIndex = 1, constants.MAX_STAGE do
            db.stageSounds[stageIndex] = defaults.stageSounds[stageIndex]
        end
        api.NormalizeSoundSettings()
        api.NormalizeAmbushSettings()
        owner:RefreshControls()
    end)

    CreateActionButton(parent, ADV_RIGHT_X, -142, ADV_BUTTON_WIDTH, L["Reset All Defaults"], function()
        api.ResetAllSettings()
        owner:RefreshControls()
    end)

    CreateSectionTitle(parent, ADV_RIGHT_X, -198, L["Debug"])
    CreateAdvancedNote(ADV_RIGHT_X, -228, L["Developer logging toggles for diagnostics and currency event traces."])

    RegisterRefresher(owner, CreateCheckbox(parent, ADV_RIGHT_X, -262, L["Enable Debug"], function()
        return db.debugSounds == true
    end, function(value)
        db.debugSounds = value and true or false
        _G.PreydatorDebugDB.enabled = db.debugSounds and true or false
    end))

    RegisterRefresher(owner, CreateCheckbox(parent, ADV_RIGHT_X, -290, L["Currency Debug Events"], function()
        return db.currencyDebugEvents == true
    end, function(value)
        db.currencyDebugEvents = value and true or false
    end))

    RegisterRefresher(owner, CreateCheckbox(parent, ADV_RIGHT_X, -318, L["Verbose Bloody Command Debug"], function()
        return db.debugBloodyCommand == true
    end, function(value)
        db.debugBloodyCommand = value and true or false
    end))
end

function SettingsModule:RefreshControls()
    for _, control in ipairs(self.refreshers or {}) do
        local refresh = control and control.PreydatorRefresh
        if type(refresh) == "function" then
            refresh(control)
        end
    end
end

function SettingsModule:BuildTabbedOptions(parent, topOffset, bottomOffset)
    local tabLabels = { L["Modules"], L["Bar"], L["Stage Text"], L["Sounds"], L["Theme"], L["Panels"], L["Currency"], L["Achievements"], L["Profiles"], L["Default Settings"] }

    -- Build top global control strip
    local stripFrame, stripControls = BuildGlobalTopStrip(self, parent)
    for _, control in ipairs(stripControls or {}) do
        RegisterRefresher(self, control)
    end
    
    local tabs, navPanel = CreateLeftNavTabs(parent, tabLabels, function(index)
        for tabIndex, frame in ipairs(self.tabFrames) do
            frame:SetShown(tabIndex == index)
            if tabIndex == index then
                self.tabs[tabIndex].PreydatorBackground:SetColorTexture(0.28, 0.28, 0.28, 1)
                self.tabs[tabIndex].PreydatorText:SetTextColor(1, 1, 1)
            else
                self.tabs[tabIndex].PreydatorBackground:SetColorTexture(0.18, 0.18, 0.18, 0.9)
                self.tabs[tabIndex].PreydatorText:SetTextColor(0.8, 0.8, 0.8)
            end
        end

        if tabLabels[index] == L["Currency"] then
            RefreshCurrencyTrackerPanel()
        elseif tabLabels[index] == L["Panels"] then
            RefreshCurrencyTrackerPanel()
            RefreshHuntTrackerPanel()
        end
    end)

    self.tabs = tabs
    self.tabFrames = self.tabFrames or {}
    self.refreshers = self.refreshers or {}

    local function BuildCurrenciesPage(owner, frame)
        local tracker = Preydator:GetModule("CurrencyTracker")
        if tracker and type(tracker.BuildCurrencyPage) == "function" then
            tracker:BuildCurrencyPage(owner, frame)
        end
    end

    local pageBuilders = {
        BuildModulesPage,
        BuildBarPage,
        BuildTextPage,
        BuildSoundsPage,
        BuildThemePage,
        BuildHuntPage,
        BuildCurrenciesPage,
        BuildAchievementsPage,
        BuildProfilesPage,
        BuildAdvancedPage,
    }

    for index, builder in ipairs(pageBuilders) do
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetPoint("TOPLEFT", navPanel, "TOPRIGHT", 8, 0)
        frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, bottomOffset or 8)
        frame:SetShown(index == 1)
        self.tabFrames[index] = frame
        builder(self, frame)
    end

    tabs[1]:Click()
end

function SettingsModule:EnsureOptionsPanel()
    if self.optionsPanel then
        return self.optionsPanel, self.optionsCategoryID
    end

    local panel = CreateFrame("Frame", "PreydatorOptionsPanel_Modular")
    panel.name = "Preydator"

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 0, -16)
    title:SetText("Preydator")

    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetWidth(PANEL_WIDTH - 16)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetWordWrap(true)
    subtitle:SetText(L["HINT_PANEL_SUBTITLE"])

    panel:SetScript("OnShow", function()
        self:RefreshControls()
        local huntScanner = Preydator:GetModule("HuntScanner")
        if huntScanner and type(huntScanner.HandleOptionsPanelVisibility) == "function" then
            huntScanner:HandleOptionsPanelVisibility(true)
        end
    end)

    panel:SetScript("OnHide", function()
        local huntScanner = Preydator:GetModule("HuntScanner")
        if huntScanner and type(huntScanner.HandleOptionsPanelVisibility) == "function" then
            huntScanner:HandleOptionsPanelVisibility(false)
        end
    end)

    self.refreshers = {}
    self.tabFrames = {}
    self:BuildTabbedOptions(panel, -108, 8)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, "Preydator", "Preydator")
        Settings.RegisterAddOnCategory(category)
        if type(category) == "table" then
            self.optionsCategoryID = category.ID or (category.GetID and category:GetID())
            panel.categoryID = self.optionsCategoryID
        end
    elseif _G.InterfaceOptions_AddCategory then
        _G.InterfaceOptions_AddCategory(panel)
    end

    self.optionsPanel = panel
    return self.optionsPanel, self.optionsCategoryID
end

function SettingsModule:OpenOptionsPanel()
    if InCombatLockdown and InCombatLockdown() == true then
        pendingOpenOptionsAfterCombat = true
        return false
    end

    pendingOpenOptionsAfterCombat = false
    local panel, categoryID = self:EnsureOptionsPanel()
    if Settings and Settings.OpenToCategory and type(categoryID) == "number" then
        Settings.OpenToCategory(categoryID)
        return true
    end

    if _G.InterfaceOptionsFrame_OpenToCategory then
        _G.InterfaceOptionsFrame_OpenToCategory("Preydator")
        return true
    end

    return false
end

function SettingsModule:OnPlayerRegenEnabled()
    if pendingOpenOptionsAfterCombat ~= true then
        return
    end

    self:OpenOptionsPanel()
end

function SettingsModule:BuildAdvancedContainer(parent, topOffset, bottomOffset)
    self.refreshers = self.refreshers or {}
    self.tabFrames = self.tabFrames or {}
    self:BuildTabbedOptions(parent, topOffset, bottomOffset)
end
