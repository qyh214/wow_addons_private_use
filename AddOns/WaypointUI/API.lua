--[[
    WaypointUI API Documentation

    `WaypointUIAPI.Navigation`
        `ClearUserNavigation()`                    -- Clear current /way marker
        `GetUserNavigation()`                      -- Returns the current /way SessionInfo if available
        `NewUserNavigation(name, mapID, x, y)`     -- Sets a new /way marker
        `IsUserNavigation()`                       -- Returns true if a /way marker is set

    `WaypointUIAPI.OpenSettingUI()`
]]

local env = select(2, ...)


WaypointUIAPI = WaypointUIAPI or {}

do -- @/MapPin
    local MapPin = env.WPM:Await("@/MapPin")

    WaypointUIAPI.Navigation = {
        ClearDestination    = MapPin.ClearDestination,
        ClearUserNavigation = MapPin.ClearUserNavigation,
        SetUserNavigation   = MapPin.SetUserNavigation,
        GetUserNavigation   = MapPin.GetUserNavigation,
        NewUserNavigation   = MapPin.NewUserNavigation,
        IsUserNavigation    = MapPin.IsUserNavigation
    }
end

do -- @/Setting
    local Setting_Logic = env.WPM:Await("@/Setting/Logic")

    WaypointUIAPI_OpenSettingUI = Setting_Logic.OpenSettingUI
end
