local env            = select(2, ...)
local L              = env.L
local Config         = env.Config

local LazyTimer      = env.WPM:Import("wpm_modules/lazy-timer")
local MapPin         = env.WPM:Import("@/MapPin")
local Support        = env.WPM:Import("@/Support")
local Support_TomTom = env.WPM:New("@/Support/TomTom")


-- Shared
--------------------------------

local lastClickTime         = nil
local lastSetCrazyArrowTime = nil
local lastQuestInfo         = { time = nil, questID = nil }
local TomTomWaypointInfo    = { name = nil, mapID = nil, x = nil, y = nil }

local function handleAccept()
    Support_TomTom.PlaceWaypointAtSession()
end

local REPLACE_PROMPT_INFO = {
    text         = L["TomTom - ReplacePrompt"],
    options      = {
        {
            text     = L["TomTom - ReplacePrompt - Yes"],
            callback = handleAccept
        },
        {
            text     = L["TomTom - ReplacePrompt - No"],
            callback = nil
        }
    },
    hideOnEscape = true,
    timeout      = 10
}


-- Helpers
--------------------------------

local function isGlobalEnabled()
    return Config.DBGlobal:GetVariable("TomTomSupportEnabled") == true
end

function Support_TomTom.PlaceWaypointAtSession()
    MapPin.NewUserNavigation(TomTomWaypointInfo.name, TomTomWaypointInfo.mapID, TomTomWaypointInfo.x, TomTomWaypointInfo.y, "TomTom_Waypoint")
    Support_TomTom.UpdateSuperTrackPinVisibility()
end

function Support_TomTom.IsUserSetCrazyArrow()
    if lastSetCrazyArrowTime == lastClickTime then
        return true
    end
    return false
end

function Support_TomTom.IsQuestConflictWithTomTomWaypoint()
    if lastSetCrazyArrowTime == lastQuestInfo.time then
        return true
    end
    return false
end

function Support_TomTom.UpdateSuperTrackPinVisibility()
    if MapPin.IsUserNavigation() and MapPin.IsUserNavigationFlagged("TomTom_Waypoint") then
        MapPin.ToggleSuperTrackedPinDisplay(false)
    else
        MapPin.ToggleSuperTrackedPinDisplay(true)
    end
end

local HandleCrazyArrowTimer = LazyTimer.New()
HandleCrazyArrowTimer:SetAction(function()
    if Support_TomTom.IsQuestConflictWithTomTomWaypoint() then
        return
    end

    -- skip prompt if we're already tracking another TomTom waypoint or auto replace is enabled
    if Config.DBGlobal:GetVariable("TomTomAutoReplaceWaypoint") == true or (not C_SuperTrack.IsSuperTrackingAnything() or (MapPin.IsUserNavigationFlagged("TomTom_Waypoint"))) then
        Support_TomTom.PlaceWaypointAtSession()
        return
    elseif Support_TomTom.IsUserSetCrazyArrow() then -- only show prompt when specifically tracking TomTom waypoint `Set as waypoint arrow`
        WUISharedPrompt:Open(REPLACE_PROMPT_INFO, TomTomWaypointInfo.name)
    end
end)

local function OnSetCrazyArrow(_, uid, _, title)
    if not isGlobalEnabled() then return end

    lastSetCrazyArrowTime = GetTime()

    TomTomWaypointInfo.name = title
    TomTomWaypointInfo.mapID = uid[1]
    TomTomWaypointInfo.x = uid[2] * 100
    TomTomWaypointInfo.y = uid[3] * 100

    HandleCrazyArrowTimer:Start(0.016)
end

local function OnClearCrazyArrow()
    if not isGlobalEnabled() then return end

    if MapPin.IsUserNavigationFlagged("TomTom_Waypoint") then
        MapPin.ClearUserNavigation()
    end
end


-- Setup
--------------------------------

local function OnAddonLoad()
    local Events = CreateFrame("Frame")
    Events:RegisterEvent("USER_WAYPOINT_UPDATED")
    Events:RegisterEvent("SUPER_TRACKING_CHANGED")
    Events:RegisterEvent("GLOBAL_MOUSE_UP")
    Events:SetScript("OnEvent", function(self, event, ...)
        if event == "USER_WAYPOINT_UPDATED" then
            Support_TomTom.UpdateSuperTrackPinVisibility()
        end

        if event == "SUPER_TRACKING_CHANGED" then
            local questID = C_SuperTrack.GetSuperTrackedQuestID()
            if questID then
                lastQuestInfo.time = GetTime()
                lastQuestInfo.questID = questID
            end
        end

        if event == "GLOBAL_MOUSE_UP" then
            lastClickTime = GetTime()
        end
    end)

    hooksecurefunc(TomTom, "SetCrazyArrow", OnSetCrazyArrow)
    TomTomCrazyArrow:HookScript("OnHide", OnClearCrazyArrow)

    local UnloadEvent = CreateFrame("Frame")
    UnloadEvent:RegisterEvent("ADDONS_UNLOADING")
    UnloadEvent:SetScript("OnEvent", function()
        if MapPin.IsUserNavigationFlagged("TomTom_Waypoint") then
            MapPin.ClearUserNavigation()
        end
    end)
end
Support.Add("TomTom", OnAddonLoad)
