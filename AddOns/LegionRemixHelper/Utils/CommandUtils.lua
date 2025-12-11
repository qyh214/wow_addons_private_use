---@class AddonPrivate
local Private = select(2, ...)

---@class CommandUtils
local commandUtils = {
    ---@type table<any, string>
    L = nil,
    ---@type LegionRH
    addon = nil,
}
Private.CommandUtils = commandUtils

local const = Private.constants

function commandUtils:Init()
    self.L = Private.L

    local subCommands = {
        default = self.OnCollectionsCommand,

        [self.L["CommandUtils.CollectionsCommand"]] = self.OnCollectionsCommand,
        [self.L["CommandUtils.CollectionsCommandShort"]] = self.OnCollectionsCommand,

        [self.L["CommandUtils.SettingsCommand"]] = self.OnSettingsCommand,
        [self.L["CommandUtils.SettingsCommandShort"]] = self.OnSettingsCommand,
    }

    Private.Addon:RegisterCommand({
        "LRH",
        "LegionRH",
    }, function (addon, args)
        if args and #args > 0 then
            local cmd = args[1]
            if subCommands[cmd] then
                subCommands[cmd](self)
                return
            end
        elseif args == nil or #args == 0 then
            subCommands["default"](self)
            return
        end
        self:OnUnknownCommand(addon)
    end)
end

function commandUtils:OnUnknownCommand(addon)
    addon:Print(self.L["CommandUtils.UnknownCommand"])
end

function commandUtils:OnSettingsCommand()
    Settings.OpenToCategory(Private.SettingsUtils:GetCategory():GetID() or 0)
end

function commandUtils:OnCollectionsCommand()
    SetCollectionsJournalShown(true, const.COLLECTIONS_TAB.TAB_ID)
end
