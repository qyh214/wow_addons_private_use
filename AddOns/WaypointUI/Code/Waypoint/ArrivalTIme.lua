local env                  = select(2, ...)
local CallbackRegistry     = env.WPM:Import("wpm_modules/callback-registry")
local Waypoint_Cache       = env.WPM:Import("@/Waypoint/Cache")
local Waypoint_ArrivalTime = env.WPM:New("@/Waypoint/ArrivalTime")


-- Shared
--------------------------------

local ALPHA              = 0.2
local MIN_DELTA_TIME     = 0.05
local MIN_SPEED          = 0.5
local MIN_DELTA_DISTANCE = 0.25
local MAX_SECONDS        = 86400
local seconds            = -1
local lastDistance       = nil
local lastTime           = nil
local averageSpeed       = nil


-- Calculation
--------------------------------

function Waypoint_ArrivalTime:ResetArrivalTime()
    lastDistance, lastTime, averageSpeed = nil, nil, nil
    seconds = -1
end
CallbackRegistry:Add("Waypoint.ActiveChanged", Waypoint_ArrivalTime.ResetArrivalTime)
CallbackRegistry:Add("Waypoint.SuperTrackingChanged", Waypoint_ArrivalTime.ResetArrivalTime)

function Waypoint_ArrivalTime:CalculateArrivalTime()
    local distance = Waypoint_Cache.Get("distance")
    if not distance then return end

    if distance <= 0 then
        seconds = 0
        lastDistance, lastTime, averageSpeed = nil, nil, nil
        return
    end

    local now = GetTime()
    if not lastDistance then
        lastDistance, lastTime = distance, now
        return
    end

    local deltaTime = now - lastTime
    if deltaTime < MIN_DELTA_TIME then return end

    local deltaDistance = lastDistance - distance
    lastDistance, lastTime = distance, now

    if deltaDistance <= 0 then
        seconds = -1
        return
    end

    if deltaDistance < MIN_DELTA_DISTANCE then return end

    local instSpeed = deltaDistance / deltaTime
    averageSpeed = averageSpeed and (averageSpeed + ALPHA * (instSpeed - averageSpeed)) or instSpeed

    if averageSpeed > MIN_SPEED then
        seconds = math.floor(distance / averageSpeed + 0.5)
        if seconds > MAX_SECONDS then seconds = -1 end
    else
        seconds = -1
    end
end

CallbackRegistry:Add("Waypoint.SecondUpdate", Waypoint_ArrivalTime.CalculateArrivalTime)


-- Get
--------------------------------

function Waypoint_ArrivalTime:GetSeconds()
    return seconds
end


-- Setup
--------------------------------

Waypoint_ArrivalTime:ResetArrivalTime()
