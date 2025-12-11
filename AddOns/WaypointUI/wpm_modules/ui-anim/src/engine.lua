local env                          = select(2, ...)

local CreateFrame                  = CreateFrame
local type                         = type
local setmetatable                 = setmetatable
local error                        = error

local UIAnim_Processor             = env.WPM:Import("wpm_modules/ui-anim/processor")
local UIAnim_Enum                  = env.WPM:Import("wpm_modules/ui-anim/enum")
local UIAnim_Engine                = env.WPM:New("wpm_modules/ui-anim/engine")


-- Shared
--------------------------------

local MIN_TICK                     = 1 / 60
local STATE_WAIT                   = 0
local STATE_PLAY                   = 1
local STATE_LOOP_DELAY             = 2

local APPLY_METHOD                 = 1
local APPLY_POS_X                  = 2
local APPLY_POS_Y                  = 3

local LOOP_YOYO                    = UIAnim_Enum.Looping and UIAnim_Enum.Looping.Yoyo

local Processor_Apply              = UIAnim_Processor.Apply
local Processor_Read               = UIAnim_Processor.Read
local Processor_GetEasing          = UIAnim_Processor.GetEasing
local Processor_PrepareApply       = UIAnim_Processor.PrepareApply
local Processor_ResolveTarget      = UIAnim_Processor.ResolveTarget
local LINEAR_EASE                  = Processor_GetEasing(UIAnim_Enum.Easing.Linear)

local activeInstances              = {}
local activeInstanceCount          = 0
local instancePool                 = {}
local instancePoolCount            = 0
local definitionPool               = {}
local definitionPoolCount          = 0
local wrapperRegistry              = setmetatable({}, { __mode = "k" })
local currentWrapper               = nil
local currentRunId                 = 0
local lastPlayedWrapper            = nil
local updateFrame                  = CreateFrame("Frame")
local isRunning                    = false
local nextDefId                    = 0


-- Internal
--------------------------------

local function pushActive(instance)
    activeInstanceCount = activeInstanceCount + 1
    activeInstances[activeInstanceCount] = instance
    if not isRunning then
        updateFrame:SetScript("OnUpdate", UIAnim_Engine.OnUpdate)
        isRunning = true
    end
end

local function removeActive(index)
    local lastIndex = activeInstanceCount
    local instance = activeInstances[index]
    if not instance then return end

    if index ~= lastIndex then
        activeInstances[index] = activeInstances[lastIndex]
    end
    activeInstances[lastIndex] = nil
    activeInstanceCount = lastIndex - 1

    local wrapperInfo = instance.wrapperInfo
    if wrapperInfo then
        local pendingCount = wrapperInfo.pendingCount or 0
        if pendingCount > 0 then
            pendingCount = pendingCount - 1
            wrapperInfo.pendingCount = pendingCount
            if pendingCount == 0 then
                notifyFinish(wrapperInfo)
            end
        end
    end

    if instancePoolCount < 100 then
        instancePoolCount = instancePoolCount + 1
        instancePool[instancePoolCount] = instance
    end

    if activeInstanceCount == 0 and isRunning then
        updateFrame:SetScript("OnUpdate", nil)
        isRunning = false
    end
end

function notifyFinish(wrapperInfo)
    if not wrapperInfo then return end
    local pendingCount = (wrapperInfo.pendingCount or 0) - 1
    wrapperInfo.pendingCount = pendingCount > 0 and pendingCount or 0
    if pendingCount <= 0 and wrapperInfo.finishCallback then
        local finishCallback = wrapperInfo.finishCallback
        wrapperInfo.finishCallback = nil
        finishCallback()
    end
end

local function fastApply(instance, value)
    local applyKind = instance.applyKind
    if applyKind == APPLY_METHOD then
        instance.applyMethod(instance.target, value)
    elseif applyKind == APPLY_POS_X then
        local target = instance.target
        local point, relativeTo, relativePoint, _, offsetY = target:GetPoint()
        instance.applyMethod(target, point, relativeTo or UIParent, relativePoint or point, value, offsetY or 0)
    elseif applyKind == APPLY_POS_Y then
        local target = instance.target
        local point, relativeTo, relativePoint, offsetX = target:GetPoint()
        instance.applyMethod(target, point, relativeTo or UIParent, relativePoint or point, offsetX or 0, value)
    end
end


local function triggerStart(instance)
    local wrapperInfo = instance.wrapperInfo
    if not wrapperInfo or wrapperInfo.startNotified then return end
    wrapperInfo.startNotified = true
    local startCallback = wrapperInfo.startCallback
    if startCallback then
        wrapperInfo.startCallback = nil
        startCallback()
    end
end


local function finalizeInstance(instance)
    if not instance or instance.loopType then return end

    local endValue = instance.dir == 1 and instance.to or instance.from
    if endValue ~= nil then
        fastApply(instance, endValue)
    end
end


-- Definition Prototype
--------------------------------

local DefProto = {}
DefProto.__index = DefProto

local function resetDefinition(definition)
    definition.__property = nil
    definition.__duration = nil
    definition.__from = nil
    definition.__to = nil
    definition.__loopType = nil
    definition.__easing = "Linear"
    definition.__hasFrom = false
    definition.__loopDelayStart = 0
    definition.__loopDelayEnd = 0
    definition.__waitStart = 0
    return definition
end

local function allocateDefinition()
    local definition = nil
    if definitionPoolCount > 0 then
        definition = definitionPool[definitionPoolCount]
        definitionPool[definitionPoolCount] = nil
        definitionPoolCount = definitionPoolCount - 1
        resetDefinition(definition)
    else
        definition = resetDefinition({})
        nextDefId = nextDefId + 1
        definition.__id = nextDefId
        setmetatable(definition, DefProto)
    end
    return definition
end

local function releaseDefinition(definition)
    if definitionPoolCount < 100 then
        definitionPoolCount = definitionPoolCount + 1
        definitionPool[definitionPoolCount] = definition
    end
end

function DefProto:wait(seconds)
    self.__waitStart = seconds or 0
    return self
end

function DefProto:property(prop)
    self.__property = prop
    return self
end

function DefProto:duration(seconds)
    self.__duration = seconds
    return self
end

function DefProto:easing(ease)
    self.__easing = ease
    return self
end

function DefProto:from(value)
    self.__from = value
    self.__hasFrom = true
    return self
end

function DefProto:to(value)
    self.__to = value
    return self
end

function DefProto:loop(loopType)
    self.__loopType = loopType
    return self
end

function DefProto:loopDelayStart(seconds)
    self.__loopDelayStart = seconds or 0
    return self
end

function DefProto:loopDelayEnd(seconds)
    self.__loopDelayEnd = seconds or 0
    return self
end

local function createInstance(definition, target)
    local instance = nil
    if instancePoolCount > 0 then
        instance = instancePool[instancePoolCount]
        instancePool[instancePoolCount] = nil
        instancePoolCount = instancePoolCount - 1
    else
        instance = {}
    end

    local loopType = definition.__loopType
    local duration = definition.__duration or 0
    local wrapperInfo = currentWrapper and wrapperRegistry[currentWrapper] or nil
    local property = definition.__property

    instance.target = target
    instance.property = property
    instance.duration = duration
    instance.easing = Processor_GetEasing(definition.__easing)
    instance.from = definition.__hasFrom and definition.__from or nil
    instance.to = definition.__to
    instance.loopType = loopType
    instance.loopDelayS = definition.__loopDelayStart or 0
    instance.loopDelayE = definition.__loopDelayEnd or 0
    instance.dir = 1
    instance.t = 0
    instance.timer = 0
    instance.wrapper = currentWrapper
    instance.wrapperInfo = wrapperInfo
    instance.runId = currentRunId
    instance.stateName = wrapperInfo and wrapperInfo.activeStateName or nil
    instance.defId = definition.__id
    instance.hasBeenVisible = target.IsVisible and target:IsVisible() or false
    instance.invDuration = duration > 0 and (1 / duration) or 0
    instance.accum = 0

    if target then
        local applyKind, applyMethod = Processor_PrepareApply(target, property)
        instance.applyKind = applyKind
        instance.applyMethod = applyMethod
    end

    local startDelay = (definition.__waitStart or 0) + (loopType and (definition.__loopDelayStart or 0) or 0)
    if startDelay > 0 then
        instance.state = STATE_WAIT
        instance.timer = startDelay
    else
        instance.state = STATE_PLAY
        triggerStart(instance)
    end

    if not instance.from then
        instance.from = Processor_Read(target, property)
    end

    instance.delta = (instance.to or 0) - (instance.from or 0)

    return instance
end

local function stopExistingDefinitionInstance(wrapper, definitionId, target)
    if not (wrapper and definitionId) then return end

    local instanceIndex = 1
    while instanceIndex <= activeInstanceCount do
        local existingInstance = activeInstances[instanceIndex]
        if existingInstance and existingInstance.wrapper == wrapper and existingInstance.defId == definitionId then
            if (not target) or existingInstance.target == target then
                finalizeInstance(existingInstance)
                removeActive(instanceIndex)
                return
            end
        end
        instanceIndex = instanceIndex + 1
    end
end

function DefProto:Play(target)
    local property = self.__property
    local duration = self.__duration
    local toValue = self.__to
    if not (property and duration and toValue ~= nil) then
        return self
    end

    if target == nil then
        error("UIAnim.Animate:Play requires a target.", 2)
    end

    local resolvedTarget = Processor_ResolveTarget(target)
    if not resolvedTarget then
        return self
    end

    if currentWrapper and self.__id then
        stopExistingDefinitionInstance(currentWrapper, self.__id, resolvedTarget)
    end

    local isLooping = self.__loopType ~= nil
    local wrapperInfo = currentWrapper and wrapperRegistry[currentWrapper]

    if not isLooping and wrapperInfo then
        wrapperInfo.pendingCount = wrapperInfo.pendingCount + 1
    end

    if duration <= 0 then
        Processor_Apply(resolvedTarget, property, toValue)
        if not isLooping and wrapperInfo then notifyFinish(wrapperInfo) end
        return self
    end

    local instance = createInstance(self, resolvedTarget)
    if not instance.target then
        if not isLooping and wrapperInfo then notifyFinish(wrapperInfo) end
        return self
    end
    pushActive(instance)
    return self
end


-- Wrapper Prototype
--------------------------------

local WrapperProto = {}
WrapperProto.__index = WrapperProto

function WrapperProto:State(name, fn)
    if not name or type(fn) ~= "function" then return self end
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return self end
    wrapperInfo.states[name] = fn
    return self
end

function WrapperProto:Play(target, name)
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return self end

    local stateTarget = nil
    local stateName = nil
    if name == nil and type(target) == "string" then
        stateName = target
    else
        stateTarget = target
        stateName = name
    end

    if not stateName then return self end

    self:Stop()
    wrapperInfo.runId = wrapperInfo.runId + 1
    wrapperInfo.pendingCount = 0
    wrapperInfo.finishCallback = nil
    wrapperInfo.startCallback = nil
    wrapperInfo.startNotified = false

    local stateFunction = wrapperInfo.states[stateName]
    if stateFunction then
        currentWrapper = self
        currentRunId = wrapperInfo.runId
        wrapperInfo.activeStateName = stateName
        local definitionCache = wrapperInfo.defCache[stateName]
        if not definitionCache then
            definitionCache = { index = 0 }
            wrapperInfo.defCache[stateName] = definitionCache
        else
            definitionCache.index = 0
        end
        stateFunction(stateTarget)
        currentWrapper = nil
        currentRunId = 0
        wrapperInfo.activeStateName = nil
        lastPlayedWrapper = self
    end
    return self
end

function WrapperProto:IsPlaying(target, name)
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return false end

    local queryTarget = nil
    local queryState = nil
    if name == nil and type(target) == "string" then
        queryState = target
    else
        queryTarget = target
        queryState = name
    end

    local resolvedTarget = queryTarget and Processor_ResolveTarget(queryTarget) or nil

    for index = 1, activeInstanceCount do
        local instance = activeInstances[index]
        if instance and instance.wrapper == self then
            if instance.runId == (wrapperInfo.runId or 0) then
                if (not queryState or instance.stateName == queryState) and (not resolvedTarget or instance.target == resolvedTarget) then
                    return true
                end
            end
        end
    end

    return false
end

function WrapperProto.onFinish(callback)
    local wrapper = lastPlayedWrapper
    if not wrapper then return WrapperProto end
    local wrapperInfo = wrapperRegistry[wrapper]
    if not wrapperInfo then
        lastPlayedWrapper = nil
        return WrapperProto
    end
    if callback then
        if (wrapperInfo.pendingCount or 0) == 0 then
            callback()
        else
            wrapperInfo.finishCallback = callback
        end
    end
    lastPlayedWrapper = nil
    return wrapper
end

function WrapperProto.onStart(callback)
    local wrapper = lastPlayedWrapper
    if not wrapper then return WrapperProto end
    local wrapperInfo = wrapperRegistry[wrapper]
    if not wrapperInfo then
        lastPlayedWrapper = nil
        return WrapperProto
    end
    if callback then
        if wrapperInfo.startNotified then
            callback()
        else
            wrapperInfo.startCallback = callback
        end
    end
    return wrapper
end

function WrapperProto:Stop()
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return self end

    wrapperInfo.runId = wrapperInfo.runId + 1
    wrapperInfo.pendingCount = 0
    wrapperInfo.finishCallback = nil
    wrapperInfo.startCallback = nil
    wrapperInfo.startNotified = false

    local instanceIndex = 1
    while instanceIndex <= activeInstanceCount do
        local animationInstance = activeInstances[instanceIndex]
        if animationInstance and animationInstance.wrapper == self then
            finalizeInstance(animationInstance)
            removeActive(instanceIndex)
        else
            instanceIndex = instanceIndex + 1
        end
    end

    return self
end


-- Engine Update
--------------------------------

local function stepInstance(instance, deltaTime)
    local wrapperInfo = instance.wrapperInfo
    if wrapperInfo then
        if instance.runId ~= wrapperInfo.runId then
            return true
        end
    elseif instance.wrapper then
        wrapperInfo = wrapperRegistry[instance.wrapper]
        if not wrapperInfo or instance.runId ~= wrapperInfo.runId then
            return true
        end
        instance.wrapperInfo = wrapperInfo
    end

    local accumulatedTime = instance.accum + deltaTime
    if accumulatedTime < MIN_TICK then
        instance.accum = accumulatedTime
        return false
    end
    instance.accum = 0

    local remainingTime = accumulatedTime
    while remainingTime > 0 do
        local instanceState = instance.state

        if instanceState == STATE_WAIT then
            local timerValue = instance.timer
            if remainingTime < timerValue then
                instance.timer = timerValue - remainingTime
                return false
            end
            remainingTime = remainingTime - timerValue
            instance.state = STATE_PLAY
            instance.t = 0
            instance.timer = 0
            triggerStart(instance)

        elseif instanceState == STATE_PLAY then
            local duration = instance.duration
            local elapsedTime = instance.t
            local timeRemaining = duration - elapsedTime

            if remainingTime < timeRemaining then
                elapsedTime = elapsedTime + remainingTime
                instance.t = elapsedTime
                remainingTime = 0
            else
                elapsedTime = duration
                instance.t = elapsedTime
                remainingTime = remainingTime - timeRemaining
            end

            local easingFunction = instance.easing
            local normalizedTime = elapsedTime * instance.invDuration
            local easedProgress = easingFunction == LINEAR_EASE and normalizedTime or easingFunction(normalizedTime)
            local fromValue = instance.from
            local toValue = instance.to
            local direction = instance.dir
            local interpolatedValue = direction == 1 and (fromValue + instance.delta * easedProgress) or (toValue - instance.delta * easedProgress)
            fastApply(instance, interpolatedValue)

            local target = instance.target
            if target.IsVisible and not target:IsVisible() then
                if instance.hasBeenVisible then
                    if not instance.loopType and toValue ~= nil then
                        fastApply(instance, toValue)
                    end
                    if wrapperInfo then notifyFinish(wrapperInfo) end
                    return true
                end
            else
                instance.hasBeenVisible = true
            end

            if elapsedTime >= duration then
                local loopType = instance.loopType
                if not loopType then
                    local endValue = direction == 1 and toValue or fromValue
                    fastApply(instance, endValue)
                    if wrapperInfo then notifyFinish(wrapperInfo) end
                    return true
                end

                if loopType == LOOP_YOYO then
                    instance.dir = -direction
                end

                local loopEndDelay = instance.loopDelayE
                if loopEndDelay > 0 then
                    instance.state = STATE_LOOP_DELAY
                    instance.timer = loopEndDelay
                else
                    instance.state = STATE_PLAY
                    instance.t = 0
                    instance.timer = 0
                    triggerStart(instance)
                    local loopStartDelay = instance.loopDelayS
                    if loopStartDelay > 0 then
                        instance.state = STATE_WAIT
                        instance.timer = loopStartDelay
                    end
                end
            else
                return false
            end

        elseif instanceState == STATE_LOOP_DELAY then
            local timerValue = instance.timer
            if remainingTime < timerValue then
                instance.timer = timerValue - remainingTime
                return false
            end
            remainingTime = remainingTime - timerValue
            instance.state = STATE_PLAY
            instance.t = 0
            instance.timer = 0
            triggerStart(instance)
            local loopStartDelay = instance.loopDelayS
            if loopStartDelay > 0 then
                instance.state = STATE_WAIT
                instance.timer = loopStartDelay
            end
        else
            return true
        end
    end

    return false
end

function UIAnim_Engine.OnUpdate(self, deltaTime)
    if activeInstanceCount == 0 or (not deltaTime) or deltaTime <= 0 then return end
    local instanceIndex = 1
    while instanceIndex <= activeInstanceCount do
        local instance = activeInstances[instanceIndex]
        if not instance or stepInstance(instance, deltaTime) then
            removeActive(instanceIndex)
        else
            instanceIndex = instanceIndex + 1
        end
    end
end


-- API
--------------------------------

function UIAnim_Engine.New()
    local wrapper = {}
    wrapperRegistry[wrapper] = {
        states        = {},
        runId         = 0,
        pendingCount  = 0,
        defCache      = {},
        startNotified = false
    }
    return setmetatable(wrapper, WrapperProto)
end

function UIAnim_Engine.Animate()
    if currentWrapper then
        local wrapperInfo = wrapperRegistry[currentWrapper]
        if wrapperInfo then
            local stateName = wrapperInfo.activeStateName
            if stateName then
                local definitionCache = wrapperInfo.defCache
                local stateDefinitions = definitionCache[stateName]
                if not stateDefinitions then
                    stateDefinitions = { idx = 0 }
                    definitionCache[stateName] = stateDefinitions
                end
                local definitionIndex = stateDefinitions.idx + 1
                stateDefinitions.idx = definitionIndex
                local cachedDefinition = stateDefinitions[definitionIndex]
                if cachedDefinition then
                    resetDefinition(cachedDefinition)
                    return cachedDefinition
                end
                local newDefinition = allocateDefinition()
                stateDefinitions[definitionIndex] = newDefinition
                return newDefinition
            end
        end
    end

    return allocateDefinition()
end
