local env                                 = select(2, ...)
local Config                              = env.Config

local SetSuperTrackedUserWaypoint         = C_SuperTrack.SetSuperTrackedUserWaypoint
local IsSuperTrackingAnything             = C_SuperTrack.IsSuperTrackingAnything
local ClearAllSuperTracked                = C_SuperTrack.ClearAllSuperTracked
local GetHighestPrioritySuperTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType
local CanSetUserWaypointOnMap             = C_Map.CanSetUserWaypointOnMap
local SetUserWaypoint                     = C_Map.SetUserWaypoint
local ClearUserWaypoint                   = C_Map.ClearUserWaypoint
local HasUserWaypoint                     = C_Map.HasUserWaypoint
local CreateFrame                         = CreateFrame
local hooksecurefunc                      = hooksecurefunc
local tostring                            = tostring

local Sound                               = env.WPM:Import("wpm_modules/sound")
local CallbackRegistry                    = env.WPM:Import("wpm_modules/callback-registry")
local LazyTimer                           = env.WPM:Import("wpm_modules/lazy-timer")
local MapPin                              = env.WPM:New("@/MapPin")


-- Shared
--------------------------------

local session = {
    name  = nil,
    mapID = nil,
    x     = nil,
    y     = nil,
    flags = nil
}


-- Helper
--------------------------------

local function getUserWaypointPosition()
    local userWaypoint = C_Map.GetUserWaypoint()
    if not userWaypoint then return nil end

    return {
        mapID = userWaypoint.uiMapID,
        pos   = userWaypoint.position
    }
end


-- Audio
--------------------------------

local function playUserNavigationAudio()
    local Setting_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.NewUserNavigation

    if Setting_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation")
        end
    end

    Sound.PlaySound("Main", soundID)
end


-- User Navigation (/way)
--------------------------------

function MapPin.ClearUserNavigation()
    if MapPin.IsUserNavigation() then ClearUserWaypoint() end
    MapPin.SetUserNavigation()
end

function MapPin.ClearDestination()
    if MapPin.IsUserNavigation() then
        MapPin.ClearUserNavigation()
    end

    if IsSuperTrackingAnything() then
        ClearAllSuperTracked()
    end
end

function MapPin.SetUserNavigation(name, mapID, x, y, flags)
    session = {
        name  = name,
        mapID = mapID,
        x     = x,
        y     = y,
        flags = flags
    }

    Config.DBLocal:SetVariable("slashWayCache", session)
end

function MapPin.GetUserNavigation()
    local savedWay = Config.DBLocal:GetVariable("slashWayCache")

    if not savedWay then
        session = {
            name  = nil,
            mapID = nil,
            x     = nil,
            y     = nil,
            flags = nil
        }

        Config.DBLocal:SetVariable("slashWayCache", session)
    else
        session = savedWay
    end

    return session
end

function MapPin.NewUserNavigation(name, mapID, x, y, flags)
    if not mapID or not x or not y then return end
    if not CanSetUserWaypointOnMap(mapID) then return end

    local pos = CreateVector2D(x / 100, y / 100)
    local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)

    MapPin.SetUserNavigation(name, mapID, pos.x, pos.y, flags)
    SetUserWaypoint(mapPoint)
    SetSuperTrackedUserWaypoint(true)

    CallbackRegistry:Trigger("MapPin.NewUserNavigation")

    playUserNavigationAudio()
end

function MapPin.IsUserNavigation()
    if not HasUserWaypoint() then return false end

    local pinTracked                = GetHighestPrioritySuperTrackingType() == Enum.SuperTrackingType.UserWaypoint
    local userWaypoint              = getUserWaypointPosition()
    local currentUserNavigationInfo = MapPin.GetUserNavigation()

    if not userWaypoint or not currentUserNavigationInfo or not currentUserNavigationInfo.mapID or not currentUserNavigationInfo.x or not currentUserNavigationInfo.y then return false end

    local mapIDMatch = tostring(userWaypoint.mapID) == tostring(currentUserNavigationInfo.mapID)
    local xMatch     = string.format("%.1f", userWaypoint.pos.x * 100) == string.format("%.1f", currentUserNavigationInfo.x * 100)
    local yMatch     = string.format("%.1f", userWaypoint.pos.y * 100) == string.format("%.1f", currentUserNavigationInfo.y * 100)

    return (pinTracked and mapIDMatch and xMatch and yMatch)
end

function MapPin.IsUserNavigationFlagged(flag)
    local currentUserNavigationInfo = MapPin.GetUserNavigation()
    if MapPin.IsUserNavigation() and currentUserNavigationInfo and currentUserNavigationInfo.flags == flag then
        return true
    end
    return false
end


-- Super Track
--------------------------------

function MapPin.ToggleSuperTrackedPinDisplay(shown)
    for pin in WorldMapFrame:EnumeratePinsByTemplate("WaypointLocationPinTemplate") do
        pin:SetAlpha(shown and 1 or 0)
        pin:EnableMouse(shown)
    end
end


-- Additional Features
--------------------------------

do -- Clear super track when user waypoint is cleared with `C_Map.ClearUserWaypoint`
    local EL = CreateFrame("Frame")
    EL:RegisterEvent("USER_WAYPOINT_UPDATED")
    EL:SetScript("OnEvent", function(self, event, ...)
        if not C_Map.HasUserWaypoint() then
            C_SuperTrack.ClearAllSuperTracked()
        end
    end)
end


-- Setup
--------------------------------

local function OnAddonLoad()
    MapPin.GetUserNavigation()
    CallbackRegistry:Trigger("MapPin.Ready")
end

CallbackRegistry:Add("Preload.AddonReady", OnAddonLoad)
