local env = select(2, ...)
local SlashCommand = env.modules:Import("packages\\slash-command")
local SupportedAddons = env.modules:Import("@\\SupportedAddons")

local function OnAddonLoad()
    C_Timer.After(10, function()
        SlashCommand.RemoveSlashCommand("WQLSlashWay")
    end)
end

SupportedAddons.Add("WorldQuestsList", OnAddonLoad)
