local env                     = select(2, ...)
local SlashCommand            = env.WPM:Import("wpm_modules/slash-command")
local Support                 = env.WPM:Import("@/Support")
local Support_WorldQuestsList = env.WPM:New("@/Support/WorldQuestsList")


-- Helpers
--------------------------------

local function removeWQLSlashCmd()
    SlashCommand.RemoveSlashCommand("WQLSlashWay")
end


-- Setup
--------------------------------

local function OnAddonLoad()
    C_Timer.After(10, function()
        removeWQLSlashCmd()
    end)
end
Support.Add("WorldQuestsList", OnAddonLoad)
