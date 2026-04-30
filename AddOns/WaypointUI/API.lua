--[[
    WaypointUI API Documentation

    `WaypointUIAPI.Navigation`
        `ClearDestination()`                                                                        -- Clears any active navigation (user waypoint or supertracked content)
        `ClearUserNavigation()`                                                                     -- Clears the current user-placed waypoint marker
        `GetUserNavigation()`                                                                       -- Returns the current waypoint session info (name, mapID, x, y, flags, iconTexture, r, g, b, requestRecolor) or nil
        `NewUserNavigation(name, mapID, x, y, flags?, iconTexture?, r?, g?, b?, requestRecolor?)`   -- Creates and tracks a new user waypoint at the specified coordinates
        `IsUserNavigationTracked()`                                                                 -- Returns true if a user waypoint is currently being tracked

    `WaypointUIAPI.OpenSettingsUI()`
]]

local env = select(2, ...)
WaypointUIAPI = WaypointUIAPI or {}

do -- @\\MapPin
    local MapPin = env.modules:Await("@\\MapPin")
    WaypointUIAPI.Navigation = {
        ClearDestination        = MapPin.ClearDestination,
        ClearUserNavigation     = MapPin.ClearUserNavigation,
        GetUserNavigation       = MapPin.GetUserNavigation,
        NewUserNavigation       = MapPin.NewUserNavigation,
        IsUserNavigationTracked = MapPin.IsUserNavigationTracked
    }
end

do -- @\\Settings
    local Setting = env.modules:Await("@\\Settings")
    WaypointUIAPI_OpenSettingsUI = Setting.OpenSettingsUI
    WaypointUIAPI.OpenSettingsUI = Setting.OpenSettingsUI
end
