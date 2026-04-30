local env = select(2, ...)
local L = env.L
local Config = env.Config
local MapPin = env.modules:Import("@\\MapPin")
local SupportedAddons = env.modules:Import("@\\SupportedAddons")
local SupportedAddons_DugisGuideViewerZ = env.modules:New("@\\SupportedAddons\\DugisGuideViewerZ")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("DugisSupportEnabled") == true end

local DugisWaypointInfo = { name = nil, mapID = nil, x = nil, y = nil }


local function HandleAccept()
    SupportedAddons_DugisGuideViewerZ.PlaceWaypointAtSession()
end

local REPLACE_PROMPT_INFO = {
    text         = L["DUGISGUIDEVIEWERZ_REPLACEPROMPT"],
    options      = {
        {
            text     = L["REPLACE"],
            callback = HandleAccept
        },
        {
            text     = L["CANCEL"],
            callback = nil
        }
    },
    hideOnEscape = true,
    timeout      = 10
}


function SupportedAddons_DugisGuideViewerZ.PlaceWaypointAtSession()
    MapPin.NewUserNavigation(DugisWaypointInfo.name, DugisWaypointInfo.mapID, DugisWaypointInfo.x, DugisWaypointInfo.y, "Dugis_Waypoint")
end

local function OnWaypointsChanged()
    if not IsModuleEnabled() then return end

    local activePoint = DugisArrowGlobal and DugisArrowGlobal.GetActivePoint and DugisArrowGlobal:GetActivePoint()
    if not activePoint or not activePoint.m then
        if MapPin.IsUserNavigationFlagged("Dugis_Waypoint") then
            MapPin.ClearUserNavigation()
        end
        return
    end

    local wp = activePoint.waypoint
    DugisWaypointInfo.name = (wp and wp.desc) or "Dugi Waypoint"
    DugisWaypointInfo.mapID = activePoint.m
    DugisWaypointInfo.x = activePoint.x * 100
    DugisWaypointInfo.y = activePoint.y * 100

    if Config.DBGlobal:GetVariable("DugisAutoReplaceWaypoint") == true or not C_SuperTrack.IsSuperTrackingAnything() or MapPin.IsUserNavigationFlagged("Dugis_Waypoint") then
        SupportedAddons_DugisGuideViewerZ.PlaceWaypointAtSession()
    else
        WUISharedPrompt:Open(REPLACE_PROMPT_INFO, DugisWaypointInfo.name)
    end
end

local function OnAddonLoad()
    local scanner = nil
    scanner = C_Timer.NewTicker(0.1, function()
        if DugisArrowGlobal and DugisArrowGlobal.WaypointsChanged and type(DugisArrowGlobal.WaypointsChanged) == "function" then
            hooksecurefunc(DugisArrowGlobal, "WaypointsChanged", OnWaypointsChanged)
            scanner:Cancel()
            scanner = nil
        end
    end)

    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDONS_UNLOADING")
    f:SetScript("OnEvent", function()
        if MapPin.IsUserNavigationFlagged("Dugis_Waypoint") then
            MapPin.ClearUserNavigation()
        end
    end)
end

SupportedAddons.Add("DugisGuideViewerZ", OnAddonLoad)
