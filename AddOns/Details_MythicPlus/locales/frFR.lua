do
    --translate here: https://legacy.curseforge.com/wow/addons/details-damage-meter-mythic/localization
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "frFR")
    local L = languageTable

------------------------------------------------------------
--[[Translation missing --]]
L["ADDON_MENU_ADDONS_TITLE"] = "Mythic+ Scoreboard"
--[[Translation missing --]]
L["ADDON_MENU_ADDONS_TOOLTIP_LEFT_CLICK"] = "left click"
--[[Translation missing --]]
L["ADDON_MENU_ADDONS_TOOLTIP_OPEN_OPTIONS"] = "open options"
--[[Translation missing --]]
L["ADDON_MENU_ADDONS_TOOLTIP_OPEN_SCOREBOARD"] = "open scoreboard"
--[[Translation missing --]]
L["ADDON_MENU_ADDONS_TOOLTIP_RIGHT_CLICK"] = "right click"
--[[Translation missing --]]
L["COMMAND_CLEAR_RUN_HISTORY"] = "Clear recent runs history"
--[[Translation missing --]]
L["COMMAND_CLEAR_RUN_HISTORY_DONE"] = "Cleared the history of %s run(s)"
--[[Translation missing --]]
L["COMMAND_HELP"] = "Shows this list of commands"
--[[Translation missing --]]
L["COMMAND_HELP_PRINT"] = "available commands"
--[[Translation missing --]]
L["COMMAND_OPEN_LOGS"] = "Show recent logs"
--[[Translation missing --]]
L["COMMAND_OPEN_OPTIONS"] = "Open the options"
--[[Translation missing --]]
L["COMMAND_OPEN_OPTIONS_PRINT"] = "Opening Details! Mythic+ scoreboard options, for more information use %s"
--[[Translation missing --]]
L["COMMAND_OPEN_SCOREBOARD"] = "Open the scoreboard"
--[[Translation missing --]]
L["COMMAND_SHOW_VERSION"] = "Show the version in a popup"
--[[Translation missing --]]
L["OPTIONS_AUTO_OPEN_CHOICE_LOOT_CLOSED"] = "When done looting"
--[[Translation missing --]]
L["OPTIONS_AUTO_OPEN_CHOICE_OVERALL_READY"] = "When the run ends"
--[[Translation missing --]]
L["OPTIONS_AUTO_OPEN_DESC"] = "Do you want to automatically open the scoreboard when done looting the chest, or when the run itself finishes?"
--[[Translation missing --]]
L["OPTIONS_AUTO_OPEN_LABEL"] = "Automatically open scoreboard"
--[[Translation missing --]]
L["OPTIONS_DEBUG"] = "Debug"
--[[Translation missing --]]
L["OPTIONS_DEBUG_STORE_DEBUG_INFO_DESC"] = "Enabling this option will save more information when reloading for debugging purposes. It is recommended to keep this option off unless you are actually debugging"
--[[Translation missing --]]
L["OPTIONS_DEBUG_STORE_DEBUG_INFO_LABEL"] = "Save debug info"
--[[Translation missing --]]
L["OPTIONS_DEBUG_STORE_DEV_MODE_DESC"] = "Enables specific information and features used when developing this addon."
--[[Translation missing --]]
L["OPTIONS_DEBUG_STORE_DEV_MODE_LABEL"] = "Developer Mode"
--[[Translation missing --]]
L["OPTIONS_GENERAL_OPTIONS"] = "General Options"
--[[Translation missing --]]
L["OPTIONS_HISTORY_RUNS_TO_KEEP_AVERAGE_PER_RUN"] = "Average per run"
--[[Translation missing --]]
L["OPTIONS_HISTORY_RUNS_TO_KEEP_DESC"] = "The amount of runs to save. Existing history larger than this amount will be removed upon next reload or login."
--[[Translation missing --]]
L["OPTIONS_HISTORY_RUNS_TO_KEEP_LABEL"] = "Runs to keep"
--[[Translation missing --]]
L["OPTIONS_HISTORY_RUNS_TO_KEEP_SAVED_RUNS"] = "Saved runs"
--[[Translation missing --]]
L["OPTIONS_HISTORY_RUNS_TO_KEEP_TOTAL_STORAGE"] = "Total storage"
--[[Translation missing --]]
L["OPTIONS_OPEN_DELAY_DESC"] = "The amount of seconds after which the scoreboard will appear according to the setting above"
--[[Translation missing --]]
L["OPTIONS_OPEN_DELAY_LABEL"] = "Scoreboard open delay"
--[[Translation missing --]]
L["OPTIONS_SAVING"] = "Saving"
--[[Translation missing --]]
L["OPTIONS_SCOREBOARD_SCALE_DESC"] = "Increase or decrease the scale of the scoreboard"
--[[Translation missing --]]
L["OPTIONS_SCOREBOARD_SCALE_LABEL"] = "Scoreboard scale"
--[[Translation missing --]]
L["OPTIONS_SECTION_TIMELINE"] = "Timeline"
--[[Translation missing --]]
L["OPTIONS_SECTION_VISIBLE_COLUMNS"] = "Visible columns"
--[[Translation missing --]]
L["OPTIONS_SHOW_CC_CAST_TOOLTIP_PERCENTAGE_DESC"] = "The tooltip will also show the percentage of each crowd control cast"
--[[Translation missing --]]
L["OPTIONS_SHOW_CC_CAST_TOOLTIP_PERCENTAGE_LABEL"] = "Show % for CC casts"
--[[Translation missing --]]
L["OPTIONS_SHOW_INTERRUPT_TOOLTIP_PERCENTAGE_DESC"] = "The tooltip will also show the percentage of each section"
--[[Translation missing --]]
L["OPTIONS_SHOW_INTERRUPT_TOOLTIP_PERCENTAGE_LABEL"] = "Show % for interrupts"
--[[Translation missing --]]
L["OPTIONS_SHOW_MINIMAP_ICON_DESC"] = "The minimap icon lets you quickly open your scoreboard whenever you want"
--[[Translation missing --]]
L["OPTIONS_SHOW_MINIMAP_ICON_LABEL"] = "Show minimap icon"
--[[Translation missing --]]
L["OPTIONS_SHOW_REMAINING_TIME_DESC"] = "When a key is timed, an extra section will be added showing the time still remaining"
--[[Translation missing --]]
L["OPTIONS_SHOW_REMAINING_TIME_LABEL"] = "Show remaining time"
--[[Translation missing --]]
L["OPTIONS_SHOW_TIME_SECTIONS_DESC"] = "Shows time labels for sections on the timeline as a guide"
--[[Translation missing --]]
L["OPTIONS_SHOW_TIME_SECTIONS_LABEL"] = "Show time labels for sections"
--[[Translation missing --]]
L["OPTIONS_SHOW_TOOLTIP_SUMMARY_DESC"] = "When hovering over a column in the scoreboard it will show a summary of the breakdown"
--[[Translation missing --]]
L["OPTIONS_SHOW_TOOLTIP_SUMMARY_LABEL"] = "Summary in tooltip"
--[[Translation missing --]]
L["OPTIONS_TOOLTIPS"] = "Tooltips"
--[[Translation missing --]]
L["OPTIONS_TRANSLIT_DESC"] = "Translit Cyrillic characters to the latin alphabet"
--[[Translation missing --]]
L["OPTIONS_TRANSLIT_LABEL"] = "Translit"
--[[Translation missing --]]
L["OPTIONS_WINDOW_TITLE"] = "Details! Mythic+ Options"
--[[Translation missing --]]
L["SCOREBOARD_NO_SCORE_AVAILABLE"] = "There is currently no score on the board"
--[[Translation missing --]]
L["SCOREBOARD_NOT_IN_COMBAT_LABEL"] = "Not in combat"
--[[Translation missing --]]
L["SCOREBOARD_RELOADED_TOOLTIP"] = "This run's data is incomplete, and possibly incorrect because of a reload or relog mid-run"
--[[Translation missing --]]
L["SCOREBOARD_RELOADED_WARNING"] = "Incomplete Data"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_CC_CASTS"] = "CC Casts"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_DAMAGE_TAKEN"] = "Damage Taken"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_DEATHS"] = "Deaths"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_DISPELS"] = "Dispels"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_DPS"] = "DPS"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_HPS"] = "HPS"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_INTERRUPTS"] = "Interrupts"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_KEYSTONE"] = "Keystone"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_LOOT"] = "Loot"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_PLAYER_NAME"] = "Player Name"
--[[Translation missing --]]
L["SCOREBOARD_TITLE_SCORE"] = "M+ Score"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_CC_CAST_HEADER"] = "Amount"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_DAMAGE_DONE_HEADER"] = "Highest"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_DAMAGE_TAKEN_HEADER"] = "Highest"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_HEALING_DONE_HEADER"] = "Highest"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_INTERRUPT_MISSED_LABEL"] = "Missed"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_INTERRUPT_OVERLAP_LABEL"] = "Overlap"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_INTERRUPT_SUCCESS_LABEL"] = "Success"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_INTERRUPTS_HEADER"] = "Amount"
--[[Translation missing --]]
L["SCOREBOARD_TOOLTIP_OPEN_BREAKDOWN"] = "Click to open breakdown"
--[[Translation missing --]]
L["SCOREBOARD_UNKNOWN_DUNGEON_LABEL"] = "Unknown Dungeon"

end