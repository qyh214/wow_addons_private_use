local env = select(2, ...)
local WoWClient_Events = env.modules:Import("packages\\wow-client\\events")
local WoWClient_Versioning = env.modules:Import("packages\\wow-client\\versioning")
local WoWClient_Keybind = env.modules:Import("packages\\wow-client\\keybind")
local WoWClient = env.modules:New("packages\\wow-client")

WoWClient.IS_RETAIL = WoWClient_Versioning.IS_RETAIL
WoWClient.IS_CLASSIC_PROGRESSION = WoWClient_Versioning.IS_CLASSIC_PROGRESSION
WoWClient.IS_CLASSIC_ERA = WoWClient_Versioning.IS_CLASSIC_ERA
WoWClient.IS_CLASSIC_ALL = WoWClient_Versioning.IS_CLASSIC_ALL

WoWClient.BlockKeyEvent = WoWClient_Keybind.BlockKeyEvent
WoWClient.IsKeyBinding = WoWClient_Keybind.IsKeyBinding
WoWClient.IsKeyBindingSet = WoWClient_Keybind.IsKeyBindingSet

WoWClient.IsPlayerTurning = WoWClient_Events.IsPlayerTurning
WoWClient.IsPlayerLooking = WoWClient_Events.IsPlayerLooking
