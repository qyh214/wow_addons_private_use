
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local C_Timer = _G.C_Timer
local unpack = table.unpack or _G.unpack
local GetTime = GetTime

--make a namespace for schedules
detailsFramework.Schedules = detailsFramework.Schedules or {}

detailsFramework.Schedules.AfterCombatSchedules = {
    withId = {},
    withoutId = {},
}

---@class df_schedule : table
---@field NewTicker fun(time: number, callback: function, ...: any): timer
---@field NewLooper fun(time: number, callback: function, loopAmount: number, loopEndCallback: function?, checkPointCallback: function?, ...: any): timer
---@field NewTimer fun(time: number, callback: function, ...: any): timer
---@field Cancel fun(ticker: timer)
---@field After fun(time: number, callback: function)
---@field SetName fun(object: timer, name: string)
---@field RunNextTick fun(callback: function)
---@field AfterCombat fun(callback:function, id:any, ...: any)
---@field CancelAfterCombat fun(id: any)
---@field CancelAllAfterCombat fun()
---@field IsAfterCombatScheduled fun(id: any): boolean
---@field LazyExecute fun(callback: function, payload: table?, maxIterations: number?, onEndCallback: function?): table
---@field AfterById fun(time: number, callback: function, id: any, ...: any): timer

---@class df_looper : table
---@field payload table
---@field callback function
---@field loopEndCallback function?
---@field checkPointCallback function?
---@field nextCheckPoint number
---@field lastLoop number
---@field currentLoop number
---@field Cancel fun()
---@field IsCancelled fun(): boolean

local eventFrame = CreateFrame("frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(self, event)
    if (event == "PLAYER_REGEN_ENABLED") then
        for _, schedule in ipairs(detailsFramework.Schedules.AfterCombatSchedules.withoutId) do
            xpcall(schedule.callback, geterrorhandler(), unpack(schedule.payload))
        end

        for _, schedule in pairs(detailsFramework.Schedules.AfterCombatSchedules.withId) do
            xpcall(schedule.callback, geterrorhandler(), unpack(schedule.payload))
        end

        table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withoutId)
        table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withId)
    end
end)

local triggerScheduledLoop = function(tickerObject)
    if (tickerObject:IsCancelled()) then
        return
    end

    local payload = tickerObject.payload
    local callback = tickerObject.callback

    local result, errortext = pcall(callback, unpack(payload))
    if (not result) then
        detailsFramework:Msg("error on scheduler: ",tickerObject.path , tickerObject.name, errortext)
    end

    local checkPointCallback = tickerObject.checkPointCallback
    if (checkPointCallback) then
        if (GetTime() >= tickerObject.nextCheckPoint) then
            local checkPointResult = checkPointCallback(unpack(payload))
            if (not checkPointResult) then
                tickerObject:Cancel()
                if (tickerObject.loopEndCallback) then
                    tickerObject.loopEndCallback()
                end
                return
            end
            tickerObject.nextCheckPoint = GetTime() + 1
        end
    end

    tickerObject.currentLoop = tickerObject.currentLoop + 1

    if (tickerObject.currentLoop == tickerObject.lastLoop) then
        tickerObject:Cancel()
        if (tickerObject.loopEndCallback) then
            tickerObject.loopEndCallback()
        end
    end

    return result
end

---start a loop which will tick @loopAmount of times, then call @loopEndCallback if exists
---checkPointCallback will be called every time the loop ticks, if it returns false, the loop will be cancelled
---@param time number
---@param callback function
---@param loopAmount number
---@param loopEndCallback function?
---@param checkPointCallback function?
---@vararg any
---@return df_looper
function detailsFramework.Schedules.NewLooper(time, callback, loopAmount, loopEndCallback, checkPointCallback, ...)
    local payload = {...}
    ---@type df_looper
    local newLooper = C_Timer.NewTicker(time, triggerScheduledLoop, loopAmount)
    newLooper.payload = payload
    newLooper.callback = callback
    newLooper.loopEndCallback = loopEndCallback
    newLooper.checkPointCallback = checkPointCallback
    newLooper.nextCheckPoint = GetTime() + 1
    newLooper.lastLoop = loopAmount
    newLooper.currentLoop = 1
    return newLooper
end

--run a scheduled function with its payload
local triggerScheduledTick = function(tickerObject)
    local payload = tickerObject.payload
    local callback = tickerObject.callback

    local result, errortext = pcall(callback, unpack(payload))
    if (not result) then
        detailsFramework:Msg("error on scheduler: ",tickerObject.path , tickerObject.name, errortext)
    end
    return result
end

--schedule to repeat a task with an interval of @time, keep ticking until cancelled
function detailsFramework.Schedules.NewTicker(time, callback, ...)
    local payload = {...}
    local newTicker = C_Timer.NewTicker(time, triggerScheduledTick)
    newTicker.payload = payload
    newTicker.callback = callback

    --debug
    newTicker.path = debugstack()
    --
    return newTicker
end

--schedule a task with an interval of @time
function detailsFramework.Schedules.NewTimer(time, callback, ...)
    local payload = {...}
    local newTimer = C_Timer.NewTimer(time, triggerScheduledTick)
    newTimer.payload = payload
    newTimer.callback = callback
    newTimer.expireAt = GetTime() + time

    --debug
    newTimer.path = debugstack()
    --

    return newTimer
end

--cancel an ongoing ticker, the native call tickerObject:Cancel() also works with no problem
function detailsFramework.Schedules.Cancel(tickerObject)
    --ignore if there's no ticker object
    if (tickerObject) then
        return tickerObject:Cancel()
    end
end

--schedule a task to be executed when the player leaves combat
function detailsFramework.Schedules.AfterCombat(callback, id, ...)
    local bInCombatLockdown = UnitAffectingCombat("player") or InCombatLockdown()

    if (not bInCombatLockdown) then
        xpcall(callback, geterrorhandler(), ...)
        return
    end

    local payload = {...}

    if (id) then
        detailsFramework.Schedules.AfterCombatSchedules.withId[id] = {
            callback = callback,
            payload = payload,
            id = id,
        }
    else
        table.insert(detailsFramework.Schedules.AfterCombatSchedules.withoutId, {
            callback = callback,
            payload = payload,
        })
    end
end

function detailsFramework.Schedules.CancelAfterCombat(id)
    detailsFramework.Schedules.AfterCombatSchedules.withId[id] = nil
end

function detailsFramework.Schedules.CancelAllAfterCombat()
    table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withId)
    table.wipe(detailsFramework.Schedules.AfterCombatSchedules.withoutId)
end

function detailsFramework.Schedules.IsAfterCombatScheduled(id)
    return detailsFramework.Schedules.AfterCombatSchedules.withId[id] ~= nil
end

---execute each frame a small portion of a big task
---the callback function receives a payload, the current iteration index and the max iterations
---if the callback function return true, the task is finished
---@param callback function
---@param payload table?
---@param maxIterations number?
---@param onEndCallback function?
function detailsFramework.Schedules.LazyExecute(callback, payload, maxIterations, onEndCallback)
    assert(type(callback) == "function", "DetailsFramework.Schedules.LazyExecute() param #1 'callback' must be a function.")
    maxIterations = maxIterations or 100000
    payload = payload or {}
    local iterationIndex = 1

    local function wrapFunc()
        local bIsFinished = callback(payload, iterationIndex, maxIterations)
        if (not bIsFinished) then
            iterationIndex = iterationIndex + 1
            if (iterationIndex > maxIterations) then
                detailsFramework:QuickDispatch(onEndCallback, payload)
                return
            end
            C_Timer.After(0, function() wrapFunc() end)
        else
            detailsFramework:QuickDispatch(onEndCallback, payload)
            return
        end
    end

    wrapFunc()

    return payload
end

function detailsFramework.Schedules.AfterById(time, callback, id, ...)
    if (not detailsFramework.Schedules.ExecuteTimerTable) then
        detailsFramework.Schedules.ExecuteTimerTable = {}
    end

    local alreadyHaveTimer = detailsFramework.Schedules.ExecuteTimerTable[id]
    if (alreadyHaveTimer) then
        alreadyHaveTimer:Cancel()
    end

    local newTimer = detailsFramework.Schedules.NewTimer(time, callback, ...)
    detailsFramework.Schedules.ExecuteTimerTable[id] = newTimer

    return newTimer
end


--schedule a task with an interval of @time without payload
function detailsFramework.Schedules.After(time, callback)
    C_Timer.After(time, callback)
end

function detailsFramework.Schedules.SetName(object, name)
    object.name = name
end

function detailsFramework.Schedules.RunNextTick(callback)
    return detailsFramework.Schedules.After(0, callback)
end