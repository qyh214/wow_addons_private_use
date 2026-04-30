local env = select(2, ...)
local Config = env.Config
local SavedVariables = env.modules:Import("packages\\saved-variables")
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local Waypoint_Cache = env.modules:Import("@\\Waypoint\\Cache")
local Waypoint_DataProvider = env.modules:Import("@\\Waypoint\\DataProvider")
local Waypoint_Enum = env.modules:Import("@\\Waypoint\\Enum")
local Waypoint_Director = env.modules:New("@\\Waypoint\\Director")

local CreateFrame = CreateFrame
local GetTime = GetTime
local IsInInstance = IsInInstance
local IsPlayerMoving = IsPlayerMoving
local IsSuperTrackingAnything = C_SuperTrack.IsSuperTrackingAnything
local IsSuperTrackingUserWaypoint = C_SuperTrack.IsSuperTrackingUserWaypoint
local ipairs = ipairs

Waypoint_Director.isActive = false
Waypoint_Director.navigationMode = Waypoint_Enum.NavigationMode.Hidden

local lastName, lastDescription, lastType, lastQuestID, lastTrackableType, lastTrackableID, lastIsUserWaypoint, lastMapID, lastX, lastY

local function GetSuperTrackedState()
    local name, description = C_SuperTrack.GetSuperTrackedItemName()
    local type = C_SuperTrack.GetHighestPrioritySuperTrackingType()
    local questID = C_SuperTrack.GetSuperTrackedQuestID()
    local contentType, contentID = C_SuperTrack.GetSuperTrackedContent()
    local isUserWaypoint = C_SuperTrack.IsSuperTrackingUserWaypoint()

    local userWaypoint = C_Map.GetUserWaypoint()
    local mapID = userWaypoint and userWaypoint.uiMapID or nil
    local x, y = userWaypoint and userWaypoint.position.x or nil, userWaypoint and userWaypoint.position.y or nil

    return name, description, type, questID, contentType, contentID, isUserWaypoint, mapID, x, y
end

local function SaveSuperTrackedState()
    lastName, lastDescription, lastType, lastQuestID, lastTrackableType, lastTrackableID, lastIsUserWaypoint, lastMapID, lastX, lastY = GetSuperTrackedState()
end

local function IsNewSuperTrackedTarget()
    local newName, newDescription, newType, newQuestID, newContentType, newContentID, newIsUserWaypoint, newMapID, newX, newY = GetSuperTrackedState()
    local different = (newName ~= lastName)
        or (newDescription ~= lastDescription)
        or (newType ~= lastType)
        or (newQuestID ~= lastQuestID)
        or (newContentType ~= lastTrackableType)
        or (newContentID ~= lastTrackableID)
        or (newIsUserWaypoint ~= lastIsUserWaypoint)
        or (newMapID ~= lastMapID)
        or (newX ~= lastX)
        or (newY ~= lastY)

    return different
end

--[[
    Callback Events:
        Waypoint.SlowUpdate
        Waypoint.SecondUpdate

        Waypoint.ContextUpdate
        Waypoint.SuperTrackingChanged
        Waypoint.ActiveChanged
        Waypoint.NavigationModeChanged
        Waypoint.DistanceReady
]]

local EventListener = CreateFrame("Frame")
do
    local EVENTS_TO_REGISTER = {
        "QUEST_POI_UPDATE",
        "QUEST_LOG_UPDATE",
        "ZONE_CHANGED_NEW_AREA",
        "ZONE_CHANGED",
        "QUEST_ACCEPTED",
        "QUEST_COMPLETE",
        "QUEST_DETAIL",
        "QUEST_FINISHED",
        "USER_WAYPOINT_UPDATED",
        "SUPER_TRACKING_CHANGED",
        "PLAYER_STARTED_MOVING",
        "PLAYER_STOPPED_MOVING",
        "PLAYER_IS_GLIDING_CHANGED"
    }
    local isMoving = false



    local slowUpdateTimer = nil
    local clampUpdateTimer = nil
    local secondUpdateTimer = nil

    local function OnSlowUpdate()
        Waypoint_DataProvider.CacheState()

        if not isMoving then
            if Waypoint_Cache.Get("state") ~= Waypoint_Enum.State.InvalidRange then
                Waypoint_DataProvider.CacheRealtime()
            end
        end

        CallbackRegistry.Trigger("Waypoint.SlowUpdate")
    end

    local function OnSecondUpdate()
        CallbackRegistry.Trigger("Waypoint.SecondUpdate")
    end

    local function StartTimers()
        if slowUpdateTimer then slowUpdateTimer:Cancel() end
        if secondUpdateTimer then secondUpdateTimer:Cancel() end

        slowUpdateTimer = C_Timer.NewTicker(0.1, OnSlowUpdate)
        secondUpdateTimer = C_Timer.NewTicker(1, OnSecondUpdate)

        OnSlowUpdate()
        OnSecondUpdate()
    end

    local function StopTimers()
        if slowUpdateTimer then slowUpdateTimer:Cancel() end
        if clampUpdateTimer then clampUpdateTimer:Cancel() end
        if secondUpdateTimer then secondUpdateTimer:Cancel() end
    end



    local moveUpdater = CreateFrame("Frame")
    moveUpdater:SetScript("OnUpdate", function()
        Waypoint_DataProvider.CacheRealtime()
    end)

    function moveUpdater:Enable()
        isMoving = true
        moveUpdater:Show()
    end

    function moveUpdater:Disable()
        isMoving = false
        moveUpdater:Hide()
    end

    moveUpdater:Disable()



    local function OnPlayerMove(isMoveStart)
        if isMoveStart then
            moveUpdater:Enable()
            CallbackRegistry.Trigger("Waypoint.PlayerStartedMoving")
        else
            moveUpdater:Disable()
            CallbackRegistry.Trigger("Waypoint.PlayerStoppedMoving")
        end
    end

    local function OnContextChange()
        Waypoint_DataProvider.CacheRealtime()
        Waypoint_DataProvider.CacheSuperTrackingInfo()
        Waypoint_DataProvider.CacheQuestInfo()
        Waypoint_DataProvider.CacheTrackingType()
        Waypoint_DataProvider.CacheState()

        CallbackRegistry.Trigger("Waypoint.ContextUpdate")
    end

    local function OnSuperTrackingChange()
        CallbackRegistry.Trigger("Waypoint.SuperTrackingChanged")
        Waypoint_Director.AwaitDistance()
    end

    CallbackRegistry.Add("MapPin.NewUserNavigation", OnSuperTrackingChange)



    local distanceAwait = CreateFrame("Frame")
    distanceAwait:Hide()
    distanceAwait.runtimeDelay = 0.075 -- Short delay to allow C_Navigation.GetDistance to update after context changes
    distanceAwait.timeoutDelay = 3
    distanceAwait.timeWhenShown = nil
    distanceAwait:SetScript("OnShow", function(self)
        self.timeWhenShown = GetTime()
    end)
    distanceAwait:SetScript("OnUpdate", function(self)
        if not Waypoint_Director.isActive then
            self:Hide()
            return
        end
        if GetTime() - self.timeWhenShown < self.runtimeDelay then return end
        if GetTime() - self.timeWhenShown > self.timeoutDelay then
            self:Hide()
            return
        end

        -- Check if distance information is available
        local distance = C_Navigation.GetDistance()
        if distance == nil or distance <= 0 then return end

        -- Refresh cache information
        OnContextChange()

        self:Hide()
        CallbackRegistry.Trigger("Waypoint.DistanceReady")

    end)

    CallbackRegistry.Add("Waypoint.DistanceReady", OnContextChange)
    CallbackRegistry.Add("Waypoint_DataProvider.NavFrameObtained", function()
        if not distanceAwait:IsShown() then
            distanceAwait:Show()
        end
    end)

    function Waypoint_Director.AwaitDistance()
        distanceAwait.timeWhenShown = GetTime()
        distanceAwait:Show()
    end

    function Waypoint_Director.CancelDistanceAwait()
        distanceAwait:Hide()
    end



    local function HandleEvent(event)
        if not Waypoint_Director.isActive then return end

        -- Context
        if event == "QUEST_POI_UPDATE" or
            event == "QUEST_LOG_UPDATE" or
            event == "ZONE_CHANGED_NEW_AREA" or
            event == "ZONE_CHANGED" or
            event == "QUEST_ACCEPTED" or
            event == "QUEST_COMPLETE" or
            event == "QUEST_DETAIL" or
            event == "QUEST_FINISHED" then
            Waypoint_Director.AwaitDistance()
        end

        -- Super Tracking
        if event == "SUPER_TRACKING_CHANGED" or (event == "USER_WAYPOINT_UPDATED" and IsSuperTrackingUserWaypoint()) then
            if IsNewSuperTrackedTarget() then
                OnSuperTrackingChange()
                SaveSuperTrackedState()
            end
        end

        -- Movement
        if event == "PLAYER_STARTED_MOVING" or event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_IS_GLIDING_CHANGED" then
            OnPlayerMove(IsPlayerMoving())
        end
    end

    for i = 1, #EVENTS_TO_REGISTER do
        CallbackRegistry.Add(EVENTS_TO_REGISTER[i], HandleEvent)
    end

    EventListener:SetScript("OnEvent", function(self, event, ...)
        CallbackRegistry.Trigger(event, ...)
    end)



    function EventListener:Enable()
        for _, event in ipairs(EVENTS_TO_REGISTER) do
            EventListener:RegisterEvent(event)
        end

        -- Sync movement state with player
        if IsPlayerMoving() then
            moveUpdater:Enable()
        end

        StartTimers()
        Waypoint_Director.AwaitDistance()
    end

    function EventListener:Disable()
        EventListener:UnregisterAllEvents()
        moveUpdater:Disable()

        StopTimers()
    end



    local lastNavigationMode = nil
    local valueChecklistBeforeUpdating = { hasDistanceInfo = false, hasClampInfo = false }

    local function Reset()
        Waypoint_Director.navigationMode = Waypoint_Enum.NavigationMode.Hidden
        lastNavigationMode = Waypoint_Enum.NavigationMode.Hidden
        Waypoint_Director.HideAllFrames()

        valueChecklistBeforeUpdating.hasDistanceInfo = false
        valueChecklistBeforeUpdating.hasClampInfo = false

        Waypoint_Cache.Clear()
    end

    CallbackRegistry.Add("Waypoint.SuperTrackingChanged", Reset)
    CallbackRegistry.Add("Waypoint.ActiveChanged", Reset)

    local function IsValueChecklistFulfilled()
        local hasDistanceInfo = valueChecklistBeforeUpdating.hasDistanceInfo
        local hasClampInfo = valueChecklistBeforeUpdating.hasClampInfo

        return hasDistanceInfo and hasClampInfo
    end

    local function ResolveNavigationMode()
        local Settings_WaypointType = Config.DBGlobal:GetVariable("WaypointSystemType")

        local state = Waypoint_Cache.Get("state")
        local isClamped = Waypoint_Cache.Get("clamped")

        if state == Waypoint_Enum.State.Invalid or state == Waypoint_Enum.State.InvalidRange then
            return Waypoint_Enum.NavigationMode.Hidden
        elseif isClamped then
            return Waypoint_Enum.NavigationMode.Navigator
        elseif state == Waypoint_Enum.State.Proximity or state == Waypoint_Enum.State.QuestProximity then
            if Settings_WaypointType == Waypoint_Enum.WaypointSystemType.Pinpoint or Settings_WaypointType == Waypoint_Enum.WaypointSystemType.All then
                return Waypoint_Enum.NavigationMode.Pinpoint
            else
                return Waypoint_Enum.NavigationMode.Waypoint
            end
        else
            if Settings_WaypointType == Waypoint_Enum.WaypointSystemType.Waypoint or Settings_WaypointType == Waypoint_Enum.WaypointSystemType.All then
                return Waypoint_Enum.NavigationMode.Waypoint
            else
                return Waypoint_Enum.NavigationMode.Pinpoint
            end
        end
    end

    local function HasNavigationModeChanged(mode)
        local hasChanged = mode ~= lastNavigationMode
        local isHidden = mode == Waypoint_Enum.NavigationMode.Hidden -- Force update when hidden to prevent visibility issues during target changes

        return hasChanged or isHidden
    end

    local function TriggerAppropriateTransitionCallback(mode)
        if lastNavigationMode == Waypoint_Enum.NavigationMode.Waypoint and mode == Waypoint_Enum.NavigationMode.Pinpoint then
            CallbackRegistry.Trigger("WaypointAnimation.WaypointToPinpoint")
        elseif lastNavigationMode == Waypoint_Enum.NavigationMode.Pinpoint and mode == Waypoint_Enum.NavigationMode.Waypoint then
            CallbackRegistry.Trigger("WaypointAnimation.PinpointToWaypoint")
        elseif lastNavigationMode == Waypoint_Enum.NavigationMode.Hidden and mode ~= Waypoint_Enum.NavigationMode.Hidden then
            CallbackRegistry.Trigger("WaypointAnimation.New")
            SaveSuperTrackedState()
        end
    end

    local function UpdateNavigationMode()
        if not IsValueChecklistFulfilled() then return end
        local mode = ResolveNavigationMode()

        if HasNavigationModeChanged(mode) then
            TriggerAppropriateTransitionCallback(mode)
            Waypoint_Director.SetNavigationMode(mode)

            lastNavigationMode = mode
        end
    end

    CallbackRegistry.Add("Waypoint_DataProvider.StateChanged", function()
        if not Waypoint_Director.isActive then return end
        UpdateNavigationMode()
    end)

    CallbackRegistry.Add("Waypoint_DataProvider.ClampChanged", function()
        if not Waypoint_Director.isActive then return end
        valueChecklistBeforeUpdating.hasClampInfo = true
        UpdateNavigationMode()
    end)

    CallbackRegistry.Add("Waypoint.DistanceReady", function()
        if not Waypoint_Director.isActive then return end
        valueChecklistBeforeUpdating.hasDistanceInfo = true
        UpdateNavigationMode()
    end)

    SavedVariables.OnChange("WaypointDB_Global", "WaypointSystemType", UpdateNavigationMode)
    SavedVariables.OnChange("WaypointDB_Global", "DistanceThresholdHidden", UpdateNavigationMode)
end

local INSTANCE_ALLOW_LIST = {
    [2352] = true, -- Founder's Point
    [2351] = true -- Razorwind Shores
}

local function ShouldSetActive()
    local mapID = C_Map.GetBestMapForUnit("player")
    local force = false
    local isInInstance, instanceType = IsInInstance()

    if mapID and INSTANCE_ALLOW_LIST[mapID] then
        force = true
    end

    local shouldShow = IsSuperTrackingAnything() and (force or (not isInInstance and instanceType == "none"))
    return shouldShow
end

function Waypoint_Director.UpdateActive()
    local active = ShouldSetActive()

    if active ~= Waypoint_Director.isActive then
        Waypoint_Director.isActive = active
        if active then
            EventListener:Enable()
        else
            EventListener:Disable()
            Waypoint_Director.SetNavigationMode(Waypoint_Enum.NavigationMode.Hidden)
        end

        CallbackRegistry.Trigger("Waypoint.ActiveChanged", active)
    end
end

function Waypoint_Director.GetNavigationMode()
    return Waypoint_Director.navigationMode
end

function Waypoint_Director.SetNavigationMode(mode)
    Waypoint_Director.navigationMode = mode
    CallbackRegistry.Trigger("Waypoint.NavigationModeChanged", mode)
end

function Waypoint_Director.HideAllFrames()
    CallbackRegistry.Trigger("Waypoint.HideAllFrames")
end

local function OnAddonLoad()
    Waypoint_Director.UpdateActive()
    Waypoint_Director.AwaitDistance()
    SaveSuperTrackedState()

    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(self, event, ...)
        Waypoint_Director.UpdateActive()
    end)
    f:RegisterEvent("SUPER_TRACKING_CHANGED")
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

CallbackRegistry.Add("Preload.AddonReady", OnAddonLoad)
