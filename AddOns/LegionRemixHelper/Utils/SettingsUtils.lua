---@class AddonPrivate
local Private = select(2, ...)

---@alias SettingsUtilsTypes
---|"BOOLEAN"
---| "NUMBER"
---| "STRING"

---@class SettingsDropdownOption
---@field key string
---@field text string

---@class SettingsUtils
---@field addon LegionRH
---@field category any
local settingsUtils = {
    addon = nil,
    category = nil,
}
Private.SettingsUtils = settingsUtils

local const = Private.constants
local typeConst = const.SETTINGS.TYPES

---@param funcType "GETTER" | "SETTER" | "GETTERSETTER"
---@param setting string
---@param default any
---@return function|nil, function|nil
function settingsUtils:GetDBFunc(funcType, setting, default)
    if funcType == "GETTER" then
        return function()
            return self.addon:GetDatabaseValue(setting, true) or default
        end
    elseif funcType == "SETTER" then
        return function(newValue)
            self.addon:SetDatabaseValue(setting, newValue)
        end
    elseif funcType == "GETTERSETTER" then
        return self:GetDBFunc("GETTER", setting, default), self:GetDBFunc("SETTER", setting)
    end
end

function settingsUtils:Init()
    local addon = Private.Addon
    self.addon = addon

    local category = Settings.RegisterVerticalLayoutCategory(addon.DisplayName)
    Settings.RegisterAddOnCategory(category)
    self.category = category
end

---@param category any
---@param lookup string
---@param varType SettingsUtilsTypes
---@param title string
---@param tooltip string?
---@param default any
---@param getter fun(): any
---@param setter fun(newValue: any)
---@return table initializer, table options
function settingsUtils:CreateCheckbox(category, lookup, varType, title, tooltip, default, getter, setter)
    local setting = Settings.RegisterProxySetting(category, lookup,
        typeConst[varType], title, default, getter, setter)
    return Settings.CreateCheckbox(category, setting, tooltip)
end

---@param category any
---@param lookup string
---@param varType SettingsUtilsTypes
---@param title string
---@param tooltip string?
---@param default any
---@param minValue number
---@param maxValue number
---@param step number
---@param getter fun(): any
---@param setter fun(newValue: any)
---@return table initializer, table options
function settingsUtils:CreateSlider(category, lookup, varType, title, tooltip, default, minValue, maxValue, step, getter,
                                    setter)
    local setting = Settings.RegisterProxySetting(category, lookup,
        typeConst[varType], title, default, getter, setter)
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    local initializer = Settings.CreateSlider(category, setting, options, tooltip)

    return initializer, options
end

---@param category any
---@param lookup string
---@param varType SettingsUtilsTypes
---@param title string
---@param tooltip string?
---@param default any
---@param options SettingsDropdownOption[]
---@param getter fun(): any
---@param setter fun(newValue: any)
---@return table initializer
function settingsUtils:CreateDropdown(category, lookup, varType, title, tooltip, default, options, getter, setter)
    local setting = Settings.RegisterProxySetting(category, lookup,
        typeConst[varType], title, default, getter, setter)

    local function getOptions()
        local container = Settings.CreateControlTextContainer()
        for _, option in ipairs(options) do
            container:Add(option.key, option.text)
        end
        return container:GetData()
    end
    return Settings.CreateDropdown(category, setting, getOptions, tooltip)
end

---@param category any
---@param initializer any
---@return table layout
function settingsUtils:AddToCategoryLayout(category, initializer)
    local layout = SettingsPanel:GetLayout(category)
    layout:AddInitializer(initializer)
    return layout
end

---@param category any
---@param title string
---@param text string
---@param onClick fun()
---@param tooltip string?
---@param addToSearch boolean?
---@return table initializer
function settingsUtils:CreateButton(category, title, text, onClick, tooltip, addToSearch)
    local initializer = CreateSettingsButtonInitializer(title, text, onClick, tooltip, addToSearch)
    self:AddToCategoryLayout(category, initializer)
    return initializer
end

---@param category any
---@param title string
---@param tooltip string?
---@param searchTags string[]?
---@return table initializer
function settingsUtils:CreateHeader(category, title, tooltip, searchTags)
    local initializer = CreateSettingsListSectionHeaderInitializer(title, tooltip)
    initializer:AddSearchTags(unpack(searchTags or {}))
    self:AddToCategoryLayout(category, initializer)
    return initializer
end

---@return table category
function settingsUtils:GetCategory()
    return self.category
end

---@param category table
---@param template string?
---@param data table?
---@param height number?
---@param identifier string?
---@param onInit fun(frame: Frame, data: table?)
---@param onDefaulted fun()?
---@param searchTags string[]?
---@return table initializer
function settingsUtils:CreatePanel(category, template, data, height, identifier, onInit, onDefaulted, searchTags)
    local initializer = Settings.CreatePanelInitializer(template or "BackdropTemplate", data or {})
    identifier = identifier or "default"

    function initializer:GetExtent()
        return self.height
    end

    function initializer:SetHeight(newHeight)
        self.height = newHeight
    end

    function initializer:InitFrame(frame)
        if self.onInit then
            self.onInit(frame, self.data)
        end
    end

    function initializer:SetOnInit(callback)
        self.onInit = callback
    end

    function initializer:TriggerOnDefaulted()
        if self.onDefaulted then
            self.onDefaulted()
        end
    end

    function initializer:SetOnDefaulted(callback)
        self.onDefaulted = callback
    end

    EventRegistry:RegisterCallback("Settings.Defaulted", function()
        initializer:TriggerOnDefaulted()
    end)
    EventRegistry:RegisterCallback("Settings.CategoryDefaulted", function(_, defaultedCategory)
        if defaultedCategory:GetID() == category:GetID() then
            initializer:TriggerOnDefaulted()
        end
    end)

    initializer:SetHeight(height or 200)
    initializer:SetOnInit(function(frame, panelData)
        if not frame.panelFrames then
            frame.panelFrames = {}
        end
        for _, f in pairs(frame.panelFrames) do
            f:Hide()
        end
        local panel = frame.panelFrames[identifier]
        if not panel then
            panel = CreateFrame("Frame", nil, frame, template or "BackdropTemplate")
            panel:SetAllPoints()
            frame.panelFrames[identifier] = panel
        end
        onInit(panel, panelData)
        panel:Show()
    end)
    initializer:SetOnDefaulted(onDefaulted)
    initializer:AddSearchTags(unpack(searchTags or {}))

    self:AddToCategoryLayout(category, initializer)

    return initializer
end
