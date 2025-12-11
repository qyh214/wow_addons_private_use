local env                    = select(2, ...)
local SavedVariables_Enum    = env.WPM:Import("wpm_modules/saved-variables/enum")
local SavedVariables_Handler = env.WPM:Import("wpm_modules/saved-variables/handler")
local SavedVariables         = env.WPM:New("wpm_modules/saved-variables")


-- Accessors
--------------------------------

SavedVariables.Enum = SavedVariables_Enum


-- API
--------------------------------

SavedVariables.RegisterDatabase = SavedVariables_Handler.RegisterDatabase
SavedVariables.RemoveDatabase   = SavedVariables_Handler.RemoveDatabase
SavedVariables.GetDatabase      = SavedVariables_Handler.GetDatabase
SavedVariables.OnChange         = SavedVariables_Handler.OnChange
