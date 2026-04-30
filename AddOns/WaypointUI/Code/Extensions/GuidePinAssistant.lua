local env = select(2, ...)
local L = env.L
local Config = env.Config
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local MapPin = env.modules:Import("@\\MapPin")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("GuidePinAssistantEnabled") == true end

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local IsSuperTrackingAnything = C_SuperTrack.IsSuperTrackingAnything
local GetPoiForUiMapID = C_GossipInfo and (C_GossipInfo.GetPoiForUiMapID or C_GossipInfo.GetGossipPoiForUiMapID)
local GetPoiInfo = C_GossipInfo and (C_GossipInfo.GetPoiInfo or C_GossipInfo.GetGossipPoiInfo)

local cachedGuidePin = nil

local function GetNormalizedCoordinates(poiInfo)
    if not poiInfo then return nil, nil end

    if poiInfo.position and poiInfo.position.x and poiInfo.position.y then
        return poiInfo.position.x, poiInfo.position.y
    end

    if poiInfo.normalizedPosition and poiInfo.normalizedPosition.x and poiInfo.normalizedPosition.y then
        return poiInfo.normalizedPosition.x, poiInfo.normalizedPosition.y
    end

    return poiInfo.normalizedX or poiInfo.x, poiInfo.normalizedY or poiInfo.y
end

local function PlaceUserNavigationAtGuidePin()
    if not cachedGuidePin then return end
    local mapID = cachedGuidePin.mapID or GetBestMapForUnit("player")
    if not mapID then return end

    MapPin.NewUserNavigation(cachedGuidePin.name, mapID, cachedGuidePin.normalizedX * 100, cachedGuidePin.normalizedY * 100, "GuidePin")
end

local function LocateGuidePin()
    if not GetPoiForUiMapID or not GetPoiInfo then return nil end

    local mapID = GetBestMapForUnit("player")
    if not mapID then return nil end

    local gossipPoiID = GetPoiForUiMapID(mapID)
    if not gossipPoiID then return nil end

    local poiInfo = GetPoiInfo(mapID, gossipPoiID)
    if not poiInfo then return nil end

    local normalizedX, normalizedY = GetNormalizedCoordinates(poiInfo)
    if not normalizedX or not normalizedY then return nil end

    cachedGuidePin = {
        name = poiInfo.name or "Guide Pin",
        mapID = mapID,
        normalizedX = normalizedX,
        normalizedY = normalizedY
    }

    return cachedGuidePin
end

local REPLACE_PROMPT_INFO = {
    text         = L["GUIDE_PIN_ASSISTANT_REPLACEPROMPT"],
    options      = {
        {
            text     = L["REPLACE"],
            callback = PlaceUserNavigationAtGuidePin
        },
        {
            text     = L["CANCEL"],
        }
    },
    hideOnEscape = true,
    timeout      = 10
}

local f = CreateFrame("Frame")
f:RegisterEvent("DYNAMIC_GOSSIP_POI_UPDATED")
f:SetScript("OnEvent", function(self, event)
    if not LocateGuidePin() then return end
    if not cachedGuidePin then return end

    if not IsSuperTrackingAnything() or MapPin.IsUserNavigationFlagged("GuidePin") then
        PlaceUserNavigationAtGuidePin()
    else
        WUISharedPrompt:Open(REPLACE_PROMPT_INFO, cachedGuidePin.name)
    end
end)

do -- Settings
    local function UpdateToMatchSetting()
        if IsModuleEnabled() then
            f:RegisterEvent("DYNAMIC_GOSSIP_POI_UPDATED")
        else
            f:UnregisterEvent("DYNAMIC_GOSSIP_POI_UPDATED")
        end
    end

    SavedVariables.OnChange("WaypointDB_Global", "GuidePinAssistantEnabled", UpdateToMatchSetting)
    CallbackRegistry.Add("Preload.DatabaseReady", UpdateToMatchSetting)
end
