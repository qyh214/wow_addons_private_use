local env = select(2, ...)
local SavedVariables_Enum = env.modules:Import("packages\\saved-variables\\enum")
local SavedVariables_Handler = env.modules:Import("packages\\saved-variables\\handler")
local SavedVariables = env.modules:New("packages\\saved-variables")

SavedVariables.Enum = SavedVariables_Enum
SavedVariables.RegisterDatabase = SavedVariables_Handler.RegisterDatabase
SavedVariables.RemoveDatabase = SavedVariables_Handler.RemoveDatabase
SavedVariables.GetDatabase = SavedVariables_Handler.GetDatabase
SavedVariables.OnChange = SavedVariables_Handler.OnChange
