local env                     = select(2, ...)
local L                       = env.L
local Config                  = env.Config

local IsSuperTrackingAnything = C_SuperTrack.IsSuperTrackingAnything
local SetCVar                 = SetCVar
local GetCVar                 = GetCVar

local CallbackRegistry        = env.WPM:Import("wpm_modules/callback-registry")
local SavedVariables          = env.WPM:Import("wpm_modules/saved-variables")
local MapPin                  = env.WPM:Import("@/MapPin")


-- Helpers
--------------------------------

local cachedSFXVolume = nil
local cachedGuidePin = nil

local function showGuidePin()
    if not cachedGuidePin then return end
    cachedGuidePin:SetAlpha(1)
end

local function hideGuidePin()
    if not cachedGuidePin then return end
    cachedGuidePin:SetAlpha(0)
end

local function placeUserNavigationAtGuidePin()
    if not cachedGuidePin then return end
    MapPin.NewUserNavigation(cachedGuidePin.name, C_Map.GetBestMapForUnit("player"), cachedGuidePin.normalizedX * 100, cachedGuidePin.normalizedY * 100, "GuidePin")
    hideGuidePin()
end

local function muteSFXChannel()
    SetCVar("Sound_SFXVolume", 0)
end

local function unmuteSFXChannel()
    SetCVar("Sound_SFXVolume", cachedSFXVolume or 1)
end

local function locateGuidePin()
    -- Refresh pins by opening and immediately closing WorldMapFrame
    local isWorldMapVisible = WorldMapFrame:IsVisible()
    cachedSFXVolume = GetCVar("Sound_SFXVolume")

    if not isWorldMapVisible then
        muteSFXChannel()

        WorldMapFrame:Show()
        WorldMapFrame:Hide()

        C_Timer.After(.5, unmuteSFXChannel)
    end

    -- Locate GossipPinTemplate aka Guide pin
    for pin in WorldMapFrame:EnumeratePinsByTemplate("GossipPinTemplate") do
        cachedGuidePin = pin
        return pin
    end

    return nil
end


-- Shared
--------------------------------

local function handleAccept()
    placeUserNavigationAtGuidePin()
end

local function handleCancel()
    showGuidePin()
end

local REPLACE_PROMPT_INFO = {
    text         = L["Guide Pin Assistant - ReplacePrompt"],
    options      = {
        {
            text     = L["Guide Pin Assistant - ReplacePrompt - Yes"],
            callback = handleAccept
        },
        {
            text     = L["Guide Pin Assistant - ReplacePrompt - No"],
            callback = handleCancel
        }
    },
    hideOnEscape = true,
    timeout      = 10
}


-- Events
--------------------------------

local Events = CreateFrame("Frame")
Events:RegisterEvent("DYNAMIC_GOSSIP_POI_UPDATED")
Events:SetScript("OnEvent", function(self, event)
    if not locateGuidePin() then return end
    if not cachedGuidePin then return end

    if not IsSuperTrackingAnything() then
        placeUserNavigationAtGuidePin()
    else
        WUISharedPrompt:Open(REPLACE_PROMPT_INFO, cachedGuidePin.name)
    end
end)


-- Settings
--------------------------------

local function updateToMatchSetting()
    local Setting_GuidePinAssistantEnabled = Config.DBGlobal:GetVariable("GuidePinAssistantEnabled")
    if Setting_GuidePinAssistantEnabled then
        Events:RegisterEvent("DYNAMIC_GOSSIP_POI_UPDATED")
    else
        Events:UnregisterEvent("DYNAMIC_GOSSIP_POI_UPDATED")
    end
end

SavedVariables.OnChange("WaypointDB_Global", "GuidePinAssistantEnabled", updateToMatchSetting)
CallbackRegistry:Add("Preload.DatabaseReady", updateToMatchSetting)
