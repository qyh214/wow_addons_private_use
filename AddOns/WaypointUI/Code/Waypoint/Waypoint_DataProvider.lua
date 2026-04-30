local env = select(2, ...)
local Config = env.Config
local Path = env.modules:Import("packages\\path")
local MapPin = env.modules:Import("@\\MapPin")
local SharedUtil = env.modules:Import("@\\SharedUtil")
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local Waypoint_ContextIcon = env.modules:Import("@\\Waypoint\\ContextIcon")
local Waypoint_Define = env.modules:Import("@\\Waypoint\\Define")
local Waypoint_Enum = env.modules:Import("@\\Waypoint\\Enum")
local Waypoint_Cache = env.modules:Import("@\\Waypoint\\Cache")
local Waypoint_DataProvider = env.modules:New("@\\Waypoint\\DataProvider")

local CreateFrame = CreateFrame
local GetNavigationFrame = C_Navigation.GetFrame
local GetDistance = C_Navigation.GetDistance
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification
local IsComplete = C_QuestLog.IsComplete
local IsInsideQuestBlob = C_Minimap.IsInsideQuestBlob
local GetNeighborhoodMapData = C_HousingNeighborhood.GetNeighborhoodMapData

local CachedNextWaypointInfo = {}
local EL = CreateFrame("Frame")
EL:RegisterEvent("SUPER_TRACKING_PATH_UPDATED")
EL:RegisterEvent("PLAYER_LOGIN")
EL:SetScript("OnEvent", function()
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        local x, y, waypointDescription = C_SuperTrack.GetNextWaypointForMap(mapID)
        CachedNextWaypointInfo.x, CachedNextWaypointInfo.y, CachedNextWaypointInfo.waypointDescription = x, y, waypointDescription
    else
        CachedNextWaypointInfo.x, CachedNextWaypointInfo.y, CachedNextWaypointInfo.waypointDescription = nil, nil, nil
    end
end)

local DataProviderUtil = {}
do
    local CLAMP_THRESHOLD = 0.125

    function DataProviderUtil.GetCompletionText(questID)
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if not questLogIndex then return nil end
        return GetQuestLogCompletionText(questLogIndex)
    end

    function DataProviderUtil.GetObjectiveInfo(objectives)
        if not objectives then return nil end
        local obj = Waypoint_Define.ObjectiveInfo{ objectives = objectives }
        obj.isMultiObjective = #objectives > 1
        return obj
    end

    function DataProviderUtil.GetTrackingType()
        local questID = Waypoint_Cache.Get("questID")
        if questID then
            if not IsComplete(questID) then
                return Waypoint_Enum.TrackingType.IncompleteQuest
            end
            local classification = GetQuestClassification(questID)
            if classification == Enum.QuestClassification.Recurring or classification == Enum.QuestClassification.Meta or classification == Enum.QuestClassification.Calling then
                return Waypoint_Enum.TrackingType.CompleteRepeatableQuest
            elseif classification == Enum.QuestClassification.Important then
                return Waypoint_Enum.TrackingType.CompleteImportantQuest
            end
            return Waypoint_Enum.TrackingType.CompleteQuest
        end
        if Waypoint_Cache.Get("pinType") == Enum.SuperTrackingType.Corpse then
            return Waypoint_Enum.TrackingType.Corpse
        end
        return Waypoint_Enum.TrackingType.Other
    end

    function DataProviderUtil.GetRedirectInfo()
        if CachedNextWaypointInfo.x then
            local x, y, text = CachedNextWaypointInfo.x, CachedNextWaypointInfo.y, CachedNextWaypointInfo.waypointDescription
            return Waypoint_Define.RedirectInfo{ valid = text ~= nil, x = x, y = y, text = text }
        end
        return Waypoint_Define.RedirectInfo{ valid = false }
    end

    function DataProviderUtil.GetState()
        local thresholdPinpoint = Config.DBGlobal:GetVariable("DistanceThresholdPinpoint")
        local thresholdHidden = Config.DBGlobal:GetVariable("DistanceThresholdHidden")
        local allowInQuestArea = Config.DBGlobal:GetVariable("PinpointAllowInQuestArea")

        local questID = Waypoint_Cache.Get("questID")
        local distance = Waypoint_Cache.Get("distance") or 9999
        local isValid = Waypoint_Cache.Get("valid")
        local isInAreaPOI = questID and IsInsideQuestBlob(questID)
        local isQuestDefault = questID and Waypoint_Cache.Get("icon") == "3308452"

        local state
        if (isInAreaPOI and not allowInQuestArea) or distance <= thresholdHidden or not isValid then
            state = (isInAreaPOI or distance <= thresholdHidden) and Waypoint_Enum.State.InvalidRange or Waypoint_Enum.State.Invalid
        elseif distance < thresholdPinpoint then
            state = isQuestDefault and Waypoint_Enum.State.QuestProximity or Waypoint_Enum.State.Proximity
        else
            state = isQuestDefault and Waypoint_Enum.State.QuestArea or Waypoint_Enum.State.Area
        end

        return state, state ~= Waypoint_Cache.Get("state")
    end

    function DataProviderUtil.IsClamped()
        local navFrame = Waypoint_Cache.navFrame
        if not navFrame then return end
        local clamped = SharedUtil:GetFrameDistanceFromScreenEdge(navFrame) < CLAMP_THRESHOLD
        return clamped, Waypoint_Cache.Get("clamped") ~= clamped
    end

    do -- Context Icon
        local HOUSING_ATLAS_MAP = {
            [Enum.HousingPlotOwnerType.None]     = "housing-map-plot-unoccupied",
            [Enum.HousingPlotOwnerType.Self]     = "housing-map-plot-player-house",
            [Enum.HousingPlotOwnerType.Friend]   = "housing-map-plot-occupied-friend",
            [Enum.HousingPlotOwnerType.Stranger] = "housing-map-plot-occupied"
        }

        local function GetSuperTrackedHousingPlotInfo()
            local pinType, plotDataID = C_SuperTrack.GetSuperTrackedMapPin()
            if pinType ~= Enum.SuperTrackingMapPinType.HousingPlot or not plotDataID then return nil end

            local mapData = GetNeighborhoodMapData()
            for _, plotInfo in ipairs(mapData) do
                if plotInfo.plotDataID == plotDataID then
                    return HOUSING_ATLAS_MAP[plotInfo.ownerType]
                end
            end

            return nil
        end


        local PATH_CONTEXT_ICON = Path.Root .. "\\Art\\Icons\\"
        local RedirectContextIcon = Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "Redirect", requestRecolor = true }

        function Waypoint_DataProvider.GetContextIconTextureForQuest(questID)
            local texturePath = Waypoint_ContextIcon.GetContextIcon(questID)
            return texturePath and Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = texturePath } or nil
        end

        function Waypoint_DataProvider.GetContextIconTextureForOtherPinType()
            local pinType = Waypoint_Cache.Get("pinType")
            if not pinType then return nil end

            local poiType = Waypoint_Cache.Get("poiType")
            local poiInfo = Waypoint_Cache.Get("poiInfo")
            local isVignette = Waypoint_Cache.Get("vignetteID") ~= nil
            local isUserNavigationTracked = MapPin.IsUserNavigationTracked()
            local userNavigation = MapPin.GetUserNavigation()

            if pinType == Enum.SuperTrackingType.Corpse then
                return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = "poi-torghast" }
            elseif isUserNavigationTracked and userNavigation and userNavigation.iconTexture then
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = userNavigation.iconTexture, requestRecolor = userNavigation.requestRecolor }
            elseif poiType == Enum.SuperTrackingMapPinType.TaxiNode then
                return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = "Crosshair_Taxi_128" }
            elseif poiInfo and poiInfo.atlasName then
                return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = poiInfo.atlasName }
            elseif isUserNavigationTracked then
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "Navigation", requestRecolor = true }
            elseif pinType == Enum.SuperTrackingType.UserWaypoint then
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "MapPin", requestRecolor = true }
            elseif poiType == Enum.SuperTrackingMapPinType.DigSite then
                return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = "ArchBlob" }
            elseif poiType == Enum.SuperTrackingMapPinType.QuestOffer then
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "AvailableQuest" }
            elseif isVignette then
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "VignetteElite", requestRecolor = true }
            elseif poiType == Enum.SuperTrackingMapPinType.HousingPlot then
                local atlas = GetSuperTrackedHousingPlotInfo()
                if atlas then
                    return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = atlas }
                end
            end
            return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "MapPin", requestRecolor = true }
        end

        function Waypoint_DataProvider.GetContextIconTextureForRedirect()
            return RedirectContextIcon
        end
    end
end

do -- Nav frame
    local function GetNavFrame()
        local navFrame = GetNavigationFrame()
        if navFrame then
            Waypoint_Cache.navFrame = navFrame
            CallbackRegistry.Trigger("Waypoint_DataProvider.NavFrameObtained", navFrame)
        end
    end

    GetNavFrame()

    local f = CreateFrame("Frame")
    f:RegisterEvent("NAVIGATION_FRAME_CREATED")
    f:RegisterEvent("NAVIGATION_FRAME_DESTROYED")
    f:SetScript("OnEvent", function(self, event)
        if event == "NAVIGATION_FRAME_CREATED" then
            GetNavFrame()
        elseif event == "NAVIGATION_FRAME_DESTROYED" then
            Waypoint_Cache.navFrame = nil
        end
    end)
end

function Waypoint_DataProvider.CacheSuperTrackingInfo()
    local valid = C_SuperTrack.IsSuperTrackingAnything()
    local pinType = C_SuperTrack.GetHighestPrioritySuperTrackingType()
    local icon = tostring(SuperTrackedFrame.Icon:GetTexture())
    local trackableType, trackableID = C_SuperTrack.GetSuperTrackedContent()
    local poiType, poiID = C_SuperTrack.GetSuperTrackedMapPin()
    local poiInfo = poiID and C_AreaPoiInfo.GetAreaPOIInfo(nil, poiID)
    local pinName, pinDescription = C_SuperTrack.GetSuperTrackedItemName()
    local redirectInfo = DataProviderUtil.GetRedirectInfo()
    local redirectContextIcon = Waypoint_DataProvider.GetContextIconTextureForRedirect()
    local vignetteID = C_SuperTrack.GetSuperTrackedVignette()

    if MapPin.IsUserNavigationTracked() or MapPin.IsUserNavigationFlagged("RareScanner_Waypoint") or MapPin.IsUserNavigationFlagged("SilverDragon_Waypoint") then
        local info = MapPin.GetUserNavigation()
        pinName = info.name
        pinDescription = string.format("X: %0.1f, Y: %0.1f", info.x * 100, info.y * 100)
    end

    Waypoint_Cache.Set("valid", valid)
    Waypoint_Cache.Set("pinType", pinType)
    Waypoint_Cache.Set("icon", icon)
    Waypoint_Cache.Set("trackableType", trackableType)
    Waypoint_Cache.Set("trackableID", trackableID)
    Waypoint_Cache.Set("poiType", poiType)
    Waypoint_Cache.Set("poiID", poiID)
    Waypoint_Cache.Set("poiInfo", poiInfo)
    Waypoint_Cache.Set("pinName", pinName)
    Waypoint_Cache.Set("pinDescription", pinDescription)
    Waypoint_Cache.Set("redirectInfo", redirectInfo)
    Waypoint_Cache.Set("redirectContextIcon", redirectContextIcon)
    Waypoint_Cache.Set("pinContextIcon", Waypoint_DataProvider.GetContextIconTextureForOtherPinType())
    Waypoint_Cache.Set("vignetteID", vignetteID)

    CallbackRegistry.Trigger("Waypoint_DataProvider.CacheSuperTrackingInfo")
end

function Waypoint_DataProvider.CacheQuestInfo()
    local questID = C_SuperTrack.GetSuperTrackedQuestID()
    local questClassification = questID and GetQuestClassification(questID)
    local questComplete = questID and IsComplete(questID)
    local questIsWorldQuest = questID and C_QuestLog.IsWorldQuest(questID)
    local questObjectiveInfo = questID and DataProviderUtil.GetObjectiveInfo(C_QuestLog.GetQuestObjectives(questID))
    local questName = questID and C_QuestLog.GetTitleForQuestID(questID)
    local questContextIcon = questID and Waypoint_DataProvider.GetContextIconTextureForQuest(questID)
    local questCompletionText = questID and DataProviderUtil.GetCompletionText(questID)

    Waypoint_Cache.Set("questID", questID)
    Waypoint_Cache.Set("questClassification", questClassification)
    Waypoint_Cache.Set("questComplete", questComplete)
    Waypoint_Cache.Set("questIsWorldQuest", questIsWorldQuest)
    Waypoint_Cache.Set("questObjectiveInfo", questObjectiveInfo)
    Waypoint_Cache.Set("questContextIcon", questContextIcon)
    Waypoint_Cache.Set("questName", questName)
    Waypoint_Cache.Set("questCompletionText", questCompletionText)

    CallbackRegistry.Trigger("Waypoint_DataProvider.CacheQuestInfo")
end

function Waypoint_DataProvider.CacheTrackingType()
    Waypoint_Cache.Set("trackingType", DataProviderUtil.GetTrackingType())
end

function Waypoint_DataProvider.CacheState()
    local state, stateChanged = DataProviderUtil.GetState()
    Waypoint_Cache.Set("state", state)
    if stateChanged then CallbackRegistry.Trigger("Waypoint_DataProvider.StateChanged") end
    CallbackRegistry.Trigger("Waypoint_DataProvider.CacheState")
end

function Waypoint_DataProvider.CacheRealtime()
    local clamped, clampChanged = DataProviderUtil.IsClamped()
    Waypoint_Cache.Set("distance", GetDistance())
    Waypoint_Cache.Set("clamped", clamped)
    if clampChanged then CallbackRegistry.Trigger("Waypoint_DataProvider.ClampChanged") end
    CallbackRegistry.Trigger("Waypoint_DataProvider.CacheRealtime")
end
