local env                        = select(2, ...)
local Config                     = env.Config

local IsSuperTrackingAnything    = C_SuperTrack.IsSuperTrackingAnything
local IsInInstance               = IsInInstance
local CreateFrame                = CreateFrame
local IsPlayerMoving             = IsPlayerMoving
local ipairs                     = ipairs

local SavedVariables             = env.WPM:Import("wpm_modules/saved-variables")
local CallbackRegistry           = env.WPM:Import("wpm_modules/callback-registry")
local Waypoint_Cache             = env.WPM:Import("@/Waypoint/Cache")
local Waypoint_DataProvider      = env.WPM:Import("@/Waypoint/DataProvider")
local Waypoint_Enum              = env.WPM:Import("@/Waypoint/Enum")
local Waypoint_Director          = env.WPM:New("@/Waypoint/Director")

Waypoint_Director.isActive       = false
Waypoint_Director.navigationMode = Waypoint_Enum.NavigationMode.Hidden -- Enum.NavigationMode.Waypoint | Enum.NavigationMode.Pinpoint | Enum.NavigationMode.Navigator


-- Event Listener
--------------------------------

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

local Events = CreateFrame("Frame")

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
        "SUPER_TRACKING_CHANGED",
        "PLAYER_STARTED_MOVING",
        "PLAYER_STOPPED_MOVING",
        "PLAYER_IS_GLIDING_CHANGED"
    }
    local isMoving = false



    -- Timers
    --------------------------------

    local slowUpdateTimer = nil
    local clampUpdateTimer = nil
    local secondUpdateTimer = nil


    local function onSlowUpdate()
        Waypoint_DataProvider:CacheState()

        if not isMoving then
            if Waypoint_Cache.Get("state") ~= Waypoint_Enum.State.InvalidRange then
                Waypoint_DataProvider:CacheRealtime()
            end
        end

        CallbackRegistry:Trigger("Waypoint.SlowUpdate")
    end

    local function onSecondUpdate()
        CallbackRegistry:Trigger("Waypoint.SecondUpdate")
    end

    local function startTimers()
        if slowUpdateTimer then slowUpdateTimer:Cancel() end
        if secondUpdateTimer then secondUpdateTimer:Cancel() end

        slowUpdateTimer = C_Timer.NewTicker(.1, onSlowUpdate)
        secondUpdateTimer = C_Timer.NewTicker(1, onSecondUpdate)

        onSlowUpdate()
        onSecondUpdate()
    end

    local function stopTimers()
        if slowUpdateTimer then slowUpdateTimer:Cancel() end
        if clampUpdateTimer then clampUpdateTimer:Cancel() end
        if secondUpdateTimer then secondUpdateTimer:Cancel() end
    end



    -- When Moving Updater
    --------------------------------

    local moveUpdater = CreateFrame("Frame")
    moveUpdater:SetScript("OnUpdate", function()
        Waypoint_DataProvider:CacheRealtime()
    end)

    function moveUpdater:Enable()
        isMoving = true
        self:Show()
    end

    function moveUpdater:Disable()
        isMoving = false
        self:Hide()
    end

    moveUpdater:Disable()




    -- Event Handlers
    --------------------------------

    local function onPlayerMove(isMoveStart)
        if isMoveStart then
            moveUpdater:Enable()
            CallbackRegistry:Trigger("Waypoint.PlayerStartedMoving")
        else
            moveUpdater:Disable()
            CallbackRegistry:Trigger("Waypoint.PlayerStoppedMoving")
        end
    end

    local function onContextChange()
        Waypoint_DataProvider:CacheRealtime()
        Waypoint_DataProvider:CacheSuperTrackingInfo()
        Waypoint_DataProvider:CacheQuestInfo()
        Waypoint_DataProvider:CacheTrackingType()
        Waypoint_DataProvider:CacheState()

        CallbackRegistry:Trigger("Waypoint.ContextUpdate")
    end

    local function onSuperTrackingChange()
        CallbackRegistry:Trigger("Waypoint.SuperTrackingChanged")
        Waypoint_Director:AwaitDistance()
    end

    CallbackRegistry:Add("MapPin.NewUserNavigation", onSuperTrackingChange)


    -- Distance Await
    --------------------------------

    local distanceAwait = CreateFrame("Frame")
    distanceAwait:Hide()
    distanceAwait.runtimeDelay = .075 -- Wait before checking for distance. C_Navigation.GetDistance doesn't update immediately after `SUPER_TRACKING_CHANGED`
    distanceAwait.timeoutDelay = 3
    distanceAwait.timeWhenShown = nil

    distanceAwait:SetScript("OnShow", function(self)
        self.timeWhenShown = GetTime()
    end)

    distanceAwait:SetScript("OnUpdate", function(self)
        if not Waypoint_Director.isActive then self:Hide() return end
        if GetTime() - self.timeWhenShown < self.runtimeDelay then return end
        if GetTime() - self.timeWhenShown > self.timeoutDelay then self:Hide() return end

        -- Check if distance information is available
        local distance = C_Navigation.GetDistance()
        if distance == nil or distance <= 0 then return end

        -- Refresh cache information
        onContextChange()

        self:Hide()
        CallbackRegistry:Trigger("Waypoint.DistanceReady")

    end)

    CallbackRegistry:Add("Waypoint.DistanceReady", onContextChange)
    CallbackRegistry:Add("Waypoint_DataProvider.NavFrameObtained", function()
        if not distanceAwait:IsShown() then
            distanceAwait:Show()
        end
    end)


    function Waypoint_Director:AwaitDistance()
        self.timeWhenShown = GetTime()
        distanceAwait:Show()
    end

    function Waypoint_Director:CancelDistanceAwait()
        distanceAwait:Hide()
    end





    -- Hook Events
    --------------------------------

    local function handleEvent(event)
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
            -- event == "SUPER_TRACKING_PATH_UPDATED" -- temporarily disabled
            Waypoint_Director:AwaitDistance()
        end

        -- Movement
        if event == "PLAYER_STARTED_MOVING" or event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_IS_GLIDING_CHANGED" then
            onPlayerMove(IsPlayerMoving())
        end

        -- Super Tracking
        if event == "SUPER_TRACKING_CHANGED" then
            onSuperTrackingChange()
        end
    end

    for i = 1, #EVENTS_TO_REGISTER do
        CallbackRegistry:Add(EVENTS_TO_REGISTER[i], handleEvent)
    end

    Events:SetScript("OnEvent", function(self, event, ...)
        CallbackRegistry:Trigger(event, ...)
    end)





    -- Enable/Disable
    --------------------------------

    function Events:Enable()
        for _, event in ipairs(EVENTS_TO_REGISTER) do
            Events:RegisterEvent(event)
        end

        -- Sync movement state with actual player state
        if IsPlayerMoving() then
            moveUpdater:Enable()
        end

        startTimers()
        Waypoint_Director:AwaitDistance()
    end

    function Events:Disable()
        Events:UnregisterAllEvents()
        moveUpdater:Disable()

        stopTimers()
    end





    -- Navigation Mode
    --------------------------------

    local lastNavigationMode = nil
    local valueChecklistBeforeUpdating = { hasDistanceInfo = false, hasClampInfo = false }


    local function reset()
        Waypoint_Director.navigationMode = Waypoint_Enum.NavigationMode.Hidden
        lastNavigationMode = Waypoint_Enum.NavigationMode.Hidden
        Waypoint_Director:HideAllFrames()

        valueChecklistBeforeUpdating.hasDistanceInfo = false
        valueChecklistBeforeUpdating.hasClampInfo = false

        Waypoint_Cache.Clear()
        -- Waypoint_Director:CancelDistanceAwait()
    end

    CallbackRegistry:Add("Waypoint.SuperTrackingChanged", reset)
    CallbackRegistry:Add("Waypoint.ActiveChanged", reset)


    local function isValueChecklistFulfilled()
        local hasDistanceInfo = valueChecklistBeforeUpdating.hasDistanceInfo
        local hasClampInfo = valueChecklistBeforeUpdating.hasClampInfo

        return hasDistanceInfo and hasClampInfo
    end

    local function resolveNavigationMode()
        local Setting_WaypointType = Config.DBGlobal:GetVariable("WaypointSystemType")

        local state = Waypoint_Cache.Get("state")
        local isClamped = Waypoint_Cache.Get("clamped")

        if state == Waypoint_Enum.State.Invalid or state == Waypoint_Enum.State.InvalidRange then
            return Waypoint_Enum.NavigationMode.Hidden
        elseif isClamped then
            return Waypoint_Enum.NavigationMode.Navigator
        elseif state == Waypoint_Enum.State.Proximity or state == Waypoint_Enum.State.QuestProximity then
            if Setting_WaypointType == Waypoint_Enum.WaypointSystemType.Pinpoint or Setting_WaypointType == Waypoint_Enum.WaypointSystemType.All then
                return Waypoint_Enum.NavigationMode.Pinpoint
            else
                return Waypoint_Enum.NavigationMode.Waypoint
            end
        else
            if Setting_WaypointType == Waypoint_Enum.WaypointSystemType.Waypoint or Setting_WaypointType == Waypoint_Enum.WaypointSystemType.All then
                return Waypoint_Enum.NavigationMode.Waypoint
            else
                return Waypoint_Enum.NavigationMode.Pinpoint
            end
        end
    end

    local function hasNavigationModeChanged(mode)
        local hasChanged = mode ~= lastNavigationMode
        local isHidden = mode == Waypoint_Enum.NavigationMode.Hidden -- Force update when mode is hidden as without this, visibility issues sometimes occur while changing super track target inside quest blob

        return hasChanged or isHidden
    end

    local function triggerAppropriateTransitionCallback(mode)
        if lastNavigationMode == Waypoint_Enum.NavigationMode.Waypoint and mode == Waypoint_Enum.NavigationMode.Pinpoint then
            -- Waypoint > Pinpoint
            CallbackRegistry:Trigger("WaypointAnimation.WaypointToPinpoint")
        elseif lastNavigationMode == Waypoint_Enum.NavigationMode.Pinpoint and mode == Waypoint_Enum.NavigationMode.Waypoint then
            -- Pinpoint > Waypoint

            CallbackRegistry:Trigger("WaypointAnimation.PinpointToWaypoint")
        elseif lastNavigationMode == Waypoint_Enum.NavigationMode.Hidden and mode ~= Waypoint_Enum.NavigationMode.Hidden then
            -- Hidden > (Waypoint/Pinpoint/Navigator)
            CallbackRegistry:Trigger("WaypointAnimation.New")
        end
    end

    local function updateNavigationMode()
        if not isValueChecklistFulfilled() then return end
        local mode = resolveNavigationMode()

        if hasNavigationModeChanged(mode) then
            triggerAppropriateTransitionCallback(mode)
            Waypoint_Director:SetNavigationMode(mode)

            lastNavigationMode = mode
        end
    end

    CallbackRegistry:Add("Waypoint_DataProvider.StateChanged", function()
        if not Waypoint_Director.isActive then return end
        updateNavigationMode()
    end)

    CallbackRegistry:Add("Waypoint_DataProvider.ClampChanged", function()
        if not Waypoint_Director.isActive then return end
        valueChecklistBeforeUpdating.hasClampInfo = true
        updateNavigationMode()
    end)

    CallbackRegistry:Add("Waypoint.DistanceReady", function()
        if not Waypoint_Director.isActive then return end
        valueChecklistBeforeUpdating.hasDistanceInfo = true
        updateNavigationMode()
    end)

    SavedVariables.OnChange("WaypointDB_Global", "WaypointSystemType", updateNavigationMode)
    SavedVariables.OnChange("WaypointDB_Global", "DistanceThresholdHidden", updateNavigationMode)
end


-- Enable/Disable
--------------------------------

local INSTANCE_ALLOW_LIST = {
    [2352] = true, -- Founder's Point
    [2351] = true -- Razorwind Shores
}

local function shouldSetActive()
    local mapID                      = C_Map.GetBestMapForUnit("player")
    local force                      = false
    local isInInstance, instanceType = IsInInstance()

    if mapID and INSTANCE_ALLOW_LIST[mapID] then
        force = true
    end

    local shouldShow = IsSuperTrackingAnything() and (force or (not isInInstance and instanceType == "none"))
    return shouldShow
end

function Waypoint_Director:UpdateActive()
    local active = shouldSetActive()

    if active ~= Waypoint_Director.isActive then
        Waypoint_Director.isActive = active
        if active then
            Events:Enable()
        else
            Events:Disable()
            Waypoint_Director:SetNavigationMode(Waypoint_Enum.NavigationMode.Hidden)
        end

        CallbackRegistry:Trigger("Waypoint.ActiveChanged", active)
    end
end


-- Navigation Mode
--------------------------------

function Waypoint_Director:GetNavigationMode()
    return Waypoint_Director.navigationMode
end

function Waypoint_Director:SetNavigationMode(mode)
    Waypoint_Director.navigationMode = mode
    CallbackRegistry:Trigger("Waypoint.NavigationModeChanged", mode)
end

function Waypoint_Director:HideAllFrames()
    CallbackRegistry:Trigger("Waypoint.HideAllFrames")
end



-- Setup
--------------------------------

local function OnAddonLoad()
    Waypoint_Director:UpdateActive()
    Waypoint_Director:AwaitDistance()

    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(self, event, ...)
        Waypoint_Director:UpdateActive()
    end)
    f:RegisterEvent("SUPER_TRACKING_CHANGED")
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
end

CallbackRegistry:Add("Preload.AddonReady", OnAddonLoad)
