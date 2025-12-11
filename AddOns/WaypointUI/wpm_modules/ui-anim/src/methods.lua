local env            = select(2, ...)

local type           = type
local CreateFrame    = CreateFrame

local UIAnim_Easing  = env.WPM:Import("wpm_modules/ui-anim/easing")
local UIAnim_Methods = env.WPM:New("wpm_modules/ui-anim/methods")

local LINEAR_EASING  = UIAnim_Easing.Linear


-- Shared
--------------------------------

local activeInstances     = {}
local activeInstanceCount = 0
local instancePool        = {}
local instancePoolCount   = 0
local updateFrame         = CreateFrame("Frame")
local isRunning           = false

local noopHandle          = {}
function noopHandle:Stop() end


-- Internal
--------------------------------

local function stopAnimation(instance)
    if instance then
        instance.stopped = true
    end
end

local function removeAnimation(instanceIndex)
    local lastIndex = activeInstanceCount
    local instance = activeInstances[instanceIndex]

    if instanceIndex ~= lastIndex then
        local movedInstance = activeInstances[lastIndex]
        activeInstances[instanceIndex] = movedInstance
        if movedInstance then
            movedInstance.index = instanceIndex
        end
    end

    activeInstances[lastIndex] = nil
    activeInstanceCount = lastIndex - 1

    if instance then
        instance.index = nil
        if instancePoolCount < 100 then
            instancePoolCount = instancePoolCount + 1
            instancePool[instancePoolCount] = instance
        end
    end

    if activeInstanceCount == 0 and isRunning then
        updateFrame:SetScript("OnUpdate", nil)
        isRunning = false
    end
end

local function processAnimations(_, deltaTime)
    local instanceIndex = 1
    while instanceIndex <= activeInstanceCount do
        local instance = activeInstances[instanceIndex]

        if not instance or instance.stopped then
            removeAnimation(instanceIndex)
        else
            local elapsedTime = instance.elapsedTime + deltaTime
            instance.elapsedTime = elapsedTime

            local progress = elapsedTime * instance.inverseDuration
            if progress > 1 then progress = 1 end

            local easingFunction = instance.easingFunction
            local easedProgress = easingFunction == LINEAR_EASING and progress or easingFunction(progress)
            local interpolatedValue = instance.startValue + instance.valueDelta * easedProgress

            local updateCallback = instance.updateCallback
            if updateCallback then
                updateCallback(interpolatedValue)
            end

            if progress >= 1 then
                local finishCallback = instance.finishCallback
                if finishCallback then
                    finishCallback()
                end
                instance.stopped = true
            else
                instanceIndex = instanceIndex + 1
            end
        end
    end
end


-- API
--------------------------------

function UIAnim_Methods.AnimateNumber(startValue, endValue, duration, easing, onUpdate, onFinish)
    local easingFunction = type(easing) == "function" and easing or UIAnim_Easing[easing] or LINEAR_EASING

    if duration <= 0 then
        if onUpdate then onUpdate(endValue) end
        if onFinish then onFinish() end
        return noopHandle
    end

    local instance
    if instancePoolCount > 0 then
        instance = instancePool[instancePoolCount]
        instancePool[instancePoolCount] = nil
        instancePoolCount = instancePoolCount - 1
    else
        instance = { Stop = stopAnimation }
    end

    instance.startValue                  = startValue
    instance.valueDelta                  = endValue - startValue
    instance.inverseDuration             = 1 / duration
    instance.elapsedTime                 = 0
    instance.easingFunction              = easingFunction
    instance.updateCallback              = onUpdate
    instance.finishCallback              = onFinish
    instance.stopped                     = false

    activeInstanceCount                  = activeInstanceCount + 1
    instance.index                       = activeInstanceCount
    activeInstances[activeInstanceCount] = instance

    if not isRunning then
        updateFrame:SetScript("OnUpdate", processAnimations)
        isRunning = true
    end

    return instance
end


--[[
local value = 0
local UIAnim_Enum = env.WPM:Import("wpm_modules/ui-anim/enum")
UIAnim_Methods.AnimateNumber(0, 100, 5, UIAnim_Enum.Easing.ExpoIn, function(val)
    value = val
    print("Animated value:", value)
end)
]]
