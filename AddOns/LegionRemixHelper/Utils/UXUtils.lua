---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants

---@class UXUtils
local uxUtils = {
    ---@type table<any, string>
    L = nil,
}
Private.UXUtils = uxUtils

function uxUtils:Init()
    self.L = Private.L
    Private.UXUI:Init()
end

function uxUtils:GetOnDefaulted()
    return function()
        -- We don't have anything to reset yet
    end
end

function uxUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["UXUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["UXUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreatePanel(settingsCategory, nil, nil, 75, "UXSettingsPanel", Private.UXUI:GetSettingsPanelInitializer(),
        self:GetOnDefaulted(), { settingsPrefix })
end
