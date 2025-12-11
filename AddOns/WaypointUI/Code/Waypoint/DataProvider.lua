local env                    = select(2, ...)
local Config                 = env.Config

local GetBestMapForUnit      = C_Map.GetBestMapForUnit
local GetNavigationFrame     = C_Navigation.GetFrame
local GetDistance            = C_Navigation.GetDistance
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification
local IsComplete             = C_QuestLog.IsComplete
local IsInsideQuestBlob      = C_Minimap.IsInsideQuestBlob

local Path                   = env.WPM:Import("wpm_modules/path")
local MapPin                 = env.WPM:Import("@/MapPin")
local LocalUtil              = env.WPM:Import("@/LocalUtil")
local CallbackRegistry       = env.WPM:Import("wpm_modules/callback-registry")
local Waypoint_ContextIcon   = env.WPM:Import("@/Waypoint/ContextIcon")
local Waypoint_Define        = env.WPM:Import("@/Waypoint/Define")
local Waypoint_Enum          = env.WPM:Import("@/Waypoint/Enum")
local Waypoint_Cache         = env.WPM:Import("@/Waypoint/Cache")
local Waypoint_DataProvider  = env.WPM:New("@/Waypoint/DataProvider")


-- Helpers
--------------------------------

local CLAMP_THRESHOLD = .125

local function getCompletionText(questID)
    if not C_QuestLog.GetLogIndexForQuestID(questID) then return nil end
    C_QuestLog.SetSelectedQuest(questID)
    return GetQuestLogCompletionText()
end

local function getObjectiveInfo(objectives)
    if not objectives then return nil end
    local obj = Waypoint_Define.ObjectiveInfo{ objectives = objectives }
    obj.isMultiObjective = #objectives > 1
    return obj
end

local function getTrackingType()
    local questID = Waypoint_Cache.Get("questID")
    if questID then
        if not IsComplete(questID) then
            return Waypoint_Enum.TrackingType.QuestIncomplete
        end
        local classification = GetQuestClassification(questID)
        if classification == Enum.QuestClassification.Recurring then
            return Waypoint_Enum.TrackingType.QuestCompleteRecurring
        elseif classification == Enum.QuestClassification.Important then
            return Waypoint_Enum.TrackingType.QuestCompleteImportant
        end
        return Waypoint_Enum.TrackingType.QuestComplete
    end
    if Waypoint_Cache.Get("pinType") == Enum.SuperTrackingType.Corpse then
        return Waypoint_Enum.TrackingType.Corpse
    end
    return Waypoint_Enum.TrackingType.Other
end

local function getRedirectInfo()
    local mapID = GetBestMapForUnit("player")
    if mapID then
        local x, y, text = C_SuperTrack.GetNextWaypointForMap(mapID)
        return Waypoint_Define.RedirectInfo{ valid = text ~= nil, x = x, y = y, text = text }
    end
    return Waypoint_Define.RedirectInfo{ valid = false }
end

local function getState()
    local thresholdPinpoint = Config.DBGlobal:GetVariable("DistanceThresholdPinpoint")
    local thresholdHidden   = Config.DBGlobal:GetVariable("DistanceThresholdHidden")
    local allowInQuestArea  = Config.DBGlobal:GetVariable("PinpointAllowInQuestArea")

    local questID           = Waypoint_Cache.Get("questID")
    local distance          = Waypoint_Cache.Get("distance") or 9999
    local isValid           = Waypoint_Cache.Get("valid")
    local isInAreaPOI       = questID and IsInsideQuestBlob(questID)
    local isQuestDefault    = questID and Waypoint_Cache.Get("icon") == "3308452"

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

local function isClamped()
    local navFrame = Waypoint_Cache.navFrame
    if not navFrame then return end
    local clamped = LocalUtil:GetFrameDistanceFromScreenEdge(navFrame) < CLAMP_THRESHOLD
    return clamped, Waypoint_Cache.Get("clamped") ~= clamped
end

do -- Context Icon
    local PATH_CONTEXT_ICON = Path.Root .. "/Art/Icon/"
    local RedirectContextIcon = Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "Redirect.png", requestRecolor = true }

    function Waypoint_DataProvider:GetContextIconTextureForQuest(questID)
        local texturePath = Waypoint_ContextIcon:GetContextIcon(questID)
        return texturePath and Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = texturePath } or nil
    end

    function Waypoint_DataProvider:GetContextIconTextureForOtherPinType()
        local pinType = Waypoint_Cache.Get("pinType")
        if not pinType then return nil end

        local poiType = Waypoint_Cache.Get("poiType")
        local poiInfo = Waypoint_Cache.Get("poiInfo")

        if pinType == Enum.SuperTrackingType.Corpse then
            return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = "poi-torghast" }
        elseif poiType == Enum.SuperTrackingMapPinType.TaxiNode then
            return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = "Crosshair_Taxi_128" }
        elseif poiInfo and poiInfo.atlasName then
            return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = poiInfo.atlasName }
        elseif MapPin.IsUserNavigation() then
            if MapPin.IsUserNavigationFlagged("TomTom_Waypoint") then
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "TomTomArrow.png", requestRecolor = true }
            else
                return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "Navigation.png", requestRecolor = true }
            end
        elseif pinType == Enum.SuperTrackingType.UserWaypoint then
            return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "MapPin.png", requestRecolor = true }
        elseif poiType == Enum.SuperTrackingMapPinType.DigSite then
            return Waypoint_Define.ContextIconTexture{ type = "ATLAS", path = "ArchBlob" }
        elseif poiType == Enum.SuperTrackingMapPinType.QuestOffer then
            return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "QuestAvailable.png" }
        end
        return Waypoint_Define.ContextIconTexture{ type = "TEXTURE", path = PATH_CONTEXT_ICON .. "MapPin.png", requestRecolor = true }
    end

    function Waypoint_DataProvider:GetContextIconTextureForRedirect()
        return RedirectContextIcon
    end
end


-- Cache
--------------------------------

do -- Nav frame
    local function getNavFrame()
        local navFrame = GetNavigationFrame()
        if navFrame then
            Waypoint_Cache.navFrame = navFrame
            CallbackRegistry:Trigger("Waypoint_DataProvider.NavFrameObtained", navFrame)
        end
    end

    getNavFrame()

    local EL = CreateFrame("Frame")
    EL:RegisterEvent("NAVIGATION_FRAME_CREATED")
    EL:RegisterEvent("NAVIGATION_FRAME_DESTROYED")
    EL:SetScript("OnEvent", function(self, event)
        if event == "NAVIGATION_FRAME_CREATED" then
            getNavFrame()
        elseif event == "NAVIGATION_FRAME_DESTROYED" then
            Waypoint_Cache.navFrame = nil
        end
    end)
end

function Waypoint_DataProvider:CacheSuperTrackingInfo()
    local valid                      = C_SuperTrack.IsSuperTrackingAnything()
    local pinType                    = C_SuperTrack.GetHighestPrioritySuperTrackingType()
    local icon                       = tostring(SuperTrackedFrame.Icon:GetTexture())
    local trackableType, trackableID = C_SuperTrack.GetSuperTrackedContent()
    local poiType, poiID             = C_SuperTrack.GetSuperTrackedMapPin()
    local poiInfo                    = poiID and C_AreaPoiInfo.GetAreaPOIInfo(nil, poiID)
    local pinName, pinDescription    = C_SuperTrack.GetSuperTrackedItemName()
    local redirectInfo               = getRedirectInfo()
    local redirectContextIcon        = Waypoint_DataProvider:GetContextIconTextureForRedirect()

    if MapPin.IsUserNavigation() then
        local info = MapPin.GetUserNavigation()
        pinName = info.name
        pinDescription = string.format("X: %.1f, Y: %.1f", info.x * 100, info.y * 100)
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
    Waypoint_Cache.Set("pinContextIcon", Waypoint_DataProvider:GetContextIconTextureForOtherPinType())

    CallbackRegistry:Trigger("Waypoint_DataProvider.CacheSuperTrackingInfo")
end

function Waypoint_DataProvider:CacheQuestInfo()
    local questID             = C_SuperTrack.GetSuperTrackedQuestID()
    local questClassification = questID and GetQuestClassification(questID)
    local questComplete       = questID and IsComplete(questID)
    local questIsWorldQuest   = questID and C_TaskQuest.GetQuestInfoByQuestID(questID) ~= nil
    local questObjectiveInfo  = questID and getObjectiveInfo(C_QuestLog.GetQuestObjectives(questID))
    local questName           = questID and C_QuestLog.GetTitleForQuestID(questID)
    local questContextIcon    = questID and Waypoint_DataProvider:GetContextIconTextureForQuest(questID)
    local questCompletionText = questID and getCompletionText(questID)

    Waypoint_Cache.Set("questID", questID)
    Waypoint_Cache.Set("questClassification", questClassification)
    Waypoint_Cache.Set("questComplete", questComplete)
    Waypoint_Cache.Set("questIsWorldQuest", questIsWorldQuest)
    Waypoint_Cache.Set("questObjectiveInfo", questObjectiveInfo)
    Waypoint_Cache.Set("questContextIcon", questContextIcon)
    Waypoint_Cache.Set("questName", questName)
    Waypoint_Cache.Set("questCompletionText", questCompletionText)

    CallbackRegistry:Trigger("Waypoint_DataProvider.CacheQuestInfo")
end

function Waypoint_DataProvider:CacheTrackingType()
    Waypoint_Cache.Set("trackingType", getTrackingType())
end

function Waypoint_DataProvider:CacheState()
    local state, stateChanged = getState()
    Waypoint_Cache.Set("state", state)
    if stateChanged then CallbackRegistry:Trigger("Waypoint_DataProvider.StateChanged") end
    CallbackRegistry:Trigger("Waypoint_DataProvider.CacheState")
end

function Waypoint_DataProvider:CacheRealtime()
    local clamped, clampChanged = isClamped()
    Waypoint_Cache.Set("distance", GetDistance())
    Waypoint_Cache.Set("clamped", clamped)
    if clampChanged then CallbackRegistry:Trigger("Waypoint_DataProvider.ClampChanged") end
    CallbackRegistry:Trigger("Waypoint_DataProvider.CacheRealtime")
end
