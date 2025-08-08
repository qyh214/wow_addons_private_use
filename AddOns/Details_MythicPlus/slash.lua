
--functions to handle the slash commands
---@type details
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil

--localization
local L = detailsFramework.Language.GetLanguageTable(addonName)

addon.commands = {
    [""] = {L["COMMAND_OPEN_OPTIONS"], function ()
        print(string.format(L["COMMAND_OPEN_OPTIONS_PRINT"], "/sb help"))
        addon.ShowMythicPlusOptionsWindow()
    end},
    help = {L["COMMAND_HELP"], function ()
        print(L["COMMAND_HELP_PRINT"])
        local sb = WrapTextInColorCode("/sb ", "0000ccff")
        for name, command in pairs(addon.commands) do
            print(sb .. (name and WrapTextInColorCode(name .. " ", "001eff00") or "") .. command[1])
        end
    end},
    version = {L["COMMAND_SHOW_VERSION"], function ()
        Details.ShowCopyValueFrame(addon.GetFullVersionString())
    end},
    open = {L["COMMAND_OPEN_SCOREBOARD"], function ()
        addon.OpenScoreboardFrame()
    end},
    logs = {L["COMMAND_OPEN_LOGS"], function ()
        addon.ShowLogs()
    end},
}

SLASH_SCORE1, SLASH_SCORE2, SLASH_SCORE3 = "/scoreboard", "/score", "/sb"
function SlashCmdList.SCORE(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = string.lower(command)

    if (addon.commands[command]) then
        addon.commands[command][2](rest)
    end
end
