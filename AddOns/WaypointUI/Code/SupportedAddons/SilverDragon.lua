local env = select(2, ...)
local Config = env.Config
local Path = env.modules:Import("packages\\path")
local MapPin = env.modules:Import("@\\MapPin")
local SupportedAddons = env.modules:Import("@\\SupportedAddons")
local SupportedAddons_TomTom = env.modules:Import("@\\SupportedAddons\\TomTom")
local SupportedAddons_SilverDragon = env.modules:New("@\\SupportedAddons\\SilverDragon")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("SilverDragonSupportEnabled") == true end

local tostring = tostring

local SessionWaypointInfo = { id = nil, name = nil, mapID = nil, x = nil, y = nil }

function IsBuiltInWaypointEnabled()
    local SilverDragon = LibStub("AceAddon-3.0"):GetAddon("SilverDragon", true)
    if SilverDragon then
        local TomTom = SilverDragon:GetModule("TomTom", true)
        if TomTom and TomTom.db and TomTom.db.profile then
            return TomTom.db.profile.blizzard == true
        end
    end
    return false
end

local function NormalizeCoordinate(coord)
    coord = tonumber(coord)
    if not coord or coord < 0 then return nil end
    if coord <= 1 then
        return coord * 100
    end
    while coord > 100 do
        coord = coord / 100
    end
    return coord
end

local function GetWaypointName(sourceID)
    if type(sourceID) == "string" and sourceID ~= "" then
        return sourceID
    end

    local SilverDragon = _G.SilverDragon
    if type(sourceID) == "number" and SilverDragon and type(SilverDragon.GetMobLabel) == "function" then
        local label = SilverDragon:GetMobLabel(sourceID)
        if label and label ~= "" then
            return label
        end
    end

    return tostring(sourceID or "SilverDragon")
end

local function CaptureWaypointInfo(sourceID, mapID, x, y)
    local normalizedMapID = tonumber(mapID)
    local normalizedX = NormalizeCoordinate(x)
    local normalizedY = NormalizeCoordinate(y)
    if not normalizedMapID or not normalizedX or not normalizedY then return false end

    SessionWaypointInfo.id = sourceID
    SessionWaypointInfo.name = GetWaypointName(sourceID)
    SessionWaypointInfo.mapID = normalizedMapID
    SessionWaypointInfo.x = normalizedX
    SessionWaypointInfo.y = normalizedY
    return true
end

function SupportedAddons_SilverDragon.PlaceWaypointAtSession()
    if not SessionWaypointInfo.mapID or not SessionWaypointInfo.x or not SessionWaypointInfo.y then return end
    SupportedAddons_TomTom.IgnoreWaypoint(SessionWaypointInfo.mapID, SessionWaypointInfo.x, SessionWaypointInfo.y)
    MapPin.NewUserNavigation(SessionWaypointInfo.name, SessionWaypointInfo.mapID, SessionWaypointInfo.x, SessionWaypointInfo.y, "SilverDragon_Waypoint", Path.Root .. "\\Art\\Icons\\VignetteElite", nil, nil, nil, true)
end

local function OnPointTo(_, sourceID, mapID, x, y)
    if not IsModuleEnabled() or not IsBuiltInWaypointEnabled() then return end
    if not CaptureWaypointInfo(sourceID, mapID, x, y) then return end
    SupportedAddons_SilverDragon.PlaceWaypointAtSession()
end

local function OnHide(_, sourceID)
    if not MapPin.IsUserNavigationFlagged("SilverDragon_Waypoint") then return end
    if tostring(SessionWaypointInfo.id) ~= tostring(sourceID) then return end
    MapPin.ClearUserNavigation()
end

local function OnAddonLoad()
    local SilverDragon = _G.SilverDragon
    if not SilverDragon or type(SilverDragon.GetModule) ~= "function" then return end

    local WaypointModule = SilverDragon:GetModule("TomTom", true)
    if not WaypointModule then return end

    hooksecurefunc(WaypointModule, "PointTo", OnPointTo)
    hooksecurefunc(WaypointModule, "Hide", OnHide)

    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDONS_UNLOADING")
    f:SetScript("OnEvent", function()
        if MapPin.IsUserNavigationFlagged("SilverDragon_Waypoint") then
            MapPin.ClearUserNavigation()
        end
    end)
end

SupportedAddons.Add("SilverDragon", OnAddonLoad)
