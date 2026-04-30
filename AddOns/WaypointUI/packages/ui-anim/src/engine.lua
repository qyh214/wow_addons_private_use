local env = select(2, ...)

local CreateFrame = CreateFrame
local type = type
local setmetatable = setmetatable
local error = error
local math_pi = math.pi

local UIAnim_Processor = env.modules:Import("packages\\ui-anim\\processor")
local UIAnim_Enum = env.modules:Import("packages\\ui-anim\\enum")
local UIAnim_Engine = env.modules:New("packages\\ui-anim\\engine")


local MIN_TICK = 1 / 60
local STATE_WAIT = 0
local STATE_PLAY = 1
local STATE_LOOP_DELAY = 2

local APPLY_METHOD = 1
local APPLY_POS_X = 2
local APPLY_POS_Y = 3
local APPLY_ROTATION = 4

local LOOP_YOYO = UIAnim_Enum.Looping and UIAnim_Enum.Looping.Yoyo
local NIL_TARGET = {}

local Processor_Apply = UIAnim_Processor.Apply
local Processor_Read = UIAnim_Processor.Read
local Processor_GetEasing = UIAnim_Processor.GetEasing
local Processor_PrepareApply = UIAnim_Processor.PrepareApply
local Processor_ResolveTarget = UIAnim_Processor.ResolveTarget
local LINEAR_EASE = Processor_GetEasing(UIAnim_Enum.Easing.Linear)

local activeInstances = {}
local activeInstanceCount = 0
local instancePool = {}
local instancePoolCount = 0
local wrapperRegistry = setmetatable({}, { __mode = "k" })
local currentWrapper = nil
local currentWrapperIsAnimation = false
local currentAnimationName = nil
local currentRunId = 0
local currentWrapperInfo = nil
local lastPlayedWrapper = nil
local lastPlayedWrapperInfo = nil
local updateFrame = CreateFrame("Frame")
local isRunning = false
local nextDefId = 0



local function PushActive(instance)
    activeInstanceCount = activeInstanceCount + 1
    activeInstances[activeInstanceCount] = instance
    if not isRunning then
        updateFrame:SetScript("OnUpdate", UIAnim_Engine.OnUpdate)
        isRunning = true
    end
end

local function RemoveActive(index)
    local inst = activeInstances[index]
    if not inst then return end
    local lastIdx = activeInstanceCount
    if index ~= lastIdx then activeInstances[index] = activeInstances[lastIdx] end
    activeInstances[lastIdx] = nil
    activeInstanceCount = lastIdx - 1
    local info = inst.wrapperInfo
    if info and info.pendingCount > 0 then
        info.pendingCount = info.pendingCount - 1
        if info.pendingCount == 0 then NotifyFinish(info) end
    end
    if instancePoolCount < 100 then
        instancePoolCount = instancePoolCount + 1
        instancePool[instancePoolCount] = inst
    end
    if activeInstanceCount == 0 and isRunning then
        updateFrame:SetScript("OnUpdate", nil)
        isRunning = false
    end
end

function NotifyFinish(info)
    if not info then return end
    local pending = (info.pendingCount or 0) - 1
    info.pendingCount = pending > 0 and pending or 0
    if pending <= 0 and info.finishCallback then
        local cb = info.finishCallback
        info.finishCallback = nil
        cb()
    end
end

local function FastApply(inst, value)
    local method, kind = inst.applyMethod, inst.applyKind
    if not method then return end
    if kind == APPLY_METHOD then
        method(inst.target, value)
    elseif kind == APPLY_POS_X then
        inst.target:ClearAllPoints()
        inst.target:SetPoint(inst.applyPoint, inst.applyRelativeTo, inst.applyRelativePoint, value, inst.applyOffsetY)
    elseif kind == APPLY_POS_Y then
        inst.target:ClearAllPoints()
        inst.target:SetPoint(inst.applyPoint, inst.applyRelativeTo, inst.applyRelativePoint, inst.applyOffsetX, value)
    elseif kind == APPLY_ROTATION then
        method(inst.target, value * math_pi / 180)
    end
end


local function TriggerStart(inst)
    local info = inst.wrapperInfo
    if not info or info.startNotified then return end
    info.startNotified = true
    if info.startCallback then
        local cb = info.startCallback
        info.startCallback = nil
        cb()
    end
end


local function ResolveValue(value)
    if type(value) == "function" then
        return value()
    end

    return value
end

local function ResolveInstanceValues(inst)
    if inst.valuesResolved then
        return inst.to ~= nil
    end

    inst.valuesResolved = true

    local fromVal = inst.hasFrom and ResolveValue(inst.fromResolver) or nil
    local toVal = ResolveValue(inst.toResolver)
    inst.fromResolver, inst.toResolver = nil, nil

    if toVal == nil then
        return false
    end

    if fromVal == nil then
        fromVal = Processor_Read(inst.target, inst.property)
    end

    inst.from = fromVal
    inst.to = toVal
    inst.delta = toVal - fromVal
    return true
end


local function FinalizeInstance(inst)
    if not inst or inst.loopType then return end
    if not ResolveInstanceValues(inst) then return end
    local endVal = inst.dir == 1 and inst.to or inst.from
    if endVal ~= nil then FastApply(inst, endVal) end
end

local function ApplyAtElapsed(inst, elapsed)
    local ease = inst.easing
    local norm = elapsed * inst.invDuration
    local prog = ease == LINEAR_EASE and norm or ease(norm)
    local fromVal, toVal, dir = inst.from, inst.to, inst.dir
    local val = dir == 1 and (fromVal + inst.delta * prog) or (toVal - inst.delta * prog)
    FastApply(inst, val)
end



local DefProto = {}
DefProto.__index = DefProto

local function ResetDefinition(def)
    def.__property, def.__duration, def.__from, def.__to, def.__loopType = nil, nil, nil, nil, nil
    def.__easing, def.__hasFrom, def.__loopDelayStart, def.__loopDelayEnd, def.__waitStart, def.__startAt = "Linear", false, 0, 0, 0, 0
    return def
end

local function AllocateDefinition()
    nextDefId = nextDefId + 1
    local def = ResetDefinition({})
    def.__id = nextDefId
    return setmetatable(def, DefProto)
end

function DefProto:wait(s)
    self.__waitStart = s or 0; return self
end
function DefProto:startAt(s)
    self.__startAt = s or 0; return self
end
function DefProto:property(p)
    self.__property = p; return self
end
function DefProto:duration(s)
    self.__duration = s; return self
end
function DefProto:easing(e)
    self.__easing = e; return self
end
function DefProto:from(v)
    self.__from, self.__hasFrom = v, true; return self
end
function DefProto:to(v)
    self.__to = v; return self
end
function DefProto:loop(t)
    self.__loopType = t; return self
end
function DefProto:loopDelayStart(s)
    self.__loopDelayStart = s or 0; return self
end
function DefProto:loopDelayEnd(s)
    self.__loopDelayEnd = s or 0; return self
end
function DefProto:ignoreVisibility(v)
    self.__ignoreVisibility = v ~= false; return self
end

local function CreateInstance(def, target, wrapper, wrapperInfo, runId)
    local inst
    if instancePoolCount > 0 then
        inst = instancePool[instancePoolCount]
        instancePool[instancePoolCount] = nil
        instancePoolCount = instancePoolCount - 1
    else
        inst = {}
    end
    local loopType = def.__loopType
    local duration = def.__duration or 0
    local startAt = def.__startAt or 0
    if startAt < 0 then startAt = 0 end
    if startAt > duration then startAt = duration end
    local info = wrapperInfo or (wrapper and wrapperRegistry[wrapper])
    local prop = def.__property
    inst.target, inst.property, inst.duration = target, prop, duration
    inst.easing = Processor_GetEasing(def.__easing)
    inst.from, inst.to, inst.delta, inst.loopType = nil, nil, 0, loopType
    inst.fromResolver, inst.toResolver = def.__from, def.__to
    inst.hasFrom, inst.valuesResolved = def.__hasFrom, false
    inst.loopDelayS, inst.loopDelayE = def.__loopDelayStart or 0, def.__loopDelayEnd or 0
    inst.dir, inst.t, inst.timer, inst.accum = 1, 0, 0, 0
    inst.startAt, inst.startAtPending = startAt, startAt > 0
    inst.wrapper, inst.wrapperInfo = wrapper, info
    inst.runId = runId or currentRunId
    inst.stateName = info and info.activeStateName or nil
    inst.defId = def.__id
    inst.hasBeenVisible = target.IsVisible and target:IsVisible() or false
    inst.invDuration = duration > 0 and (1 / duration) or 0
    if target then
        inst.applyKind, inst.applyMethod, inst.applyPoint, inst.applyRelativeTo, inst.applyRelativePoint, inst.applyOffsetX, inst.applyOffsetY = Processor_PrepareApply(target, prop)
    end
    local startDelay = (def.__waitStart or 0) + (loopType and (def.__loopDelayStart or 0) or 0)
    if startDelay > 0 then
        inst.state, inst.timer = STATE_WAIT, startDelay
    else
        inst.state = STATE_PLAY
        if not ResolveInstanceValues(inst) then return nil end
        if inst.startAtPending then
            inst.t = inst.startAt
            inst.startAtPending = false
        end
        TriggerStart(inst)
    end
    if inst.state == STATE_PLAY and inst.t > 0 then
        ApplyAtElapsed(inst, inst.t)
    end
    inst.ignoreVisibility = def.__ignoreVisibility or false
    return inst
end

local function StopExistingDefinitionInstance(wrapper, definitionId, target)
    if not (wrapper and definitionId) then return end
    local i = 1
    while i <= activeInstanceCount do
        local inst = activeInstances[i]
        if inst and inst.wrapper == wrapper and inst.defId == definitionId and ((not target) or inst.target == target) then
            RemoveActive(i)
            return
        end
        i = i + 1
    end
end

local function StopWrapperInstances(wrapper, target, stateName, includeAnimations)
    if not wrapper then return end
    local i = 1
    while i <= activeInstanceCount do
        local inst = activeInstances[i]
        if inst and inst.wrapper == wrapper
            and ((not target) or inst.target == target)
            and ((not stateName)
                or (inst.isAnimationState and inst.animName == stateName)
                or ((not inst.isAnimationState) and inst.stateName == stateName))
            and (includeAnimations or not inst.isAnimationState)
        then
            FinalizeInstance(inst)
            RemoveActive(i)
        else
            i = i + 1
        end
    end
end

function DefProto:Play(target)
    local prop, dur = self.__property, self.__duration
    if not (prop and dur and self.__to ~= nil) then return self end
    if target == nil then error("UIAnim.Animate:Play requires a target.", 2) end
    local resolved = Processor_ResolveTarget(target)
    if not resolved then return self end
    local wrapper = currentWrapper
    if wrapper and self.__id then StopExistingDefinitionInstance(wrapper, self.__id, resolved) end
    local isLooping = self.__loopType ~= nil
    local info = wrapper and (currentWrapperInfo or wrapperRegistry[wrapper])
    local isAnim = currentWrapperIsAnimation
    if not isLooping and info and not isAnim then info.pendingCount = info.pendingCount + 1 end
    if dur <= 0 then
        local toVal = ResolveValue(self.__to)
        if toVal == nil then
            if not isLooping and info and not isAnim then NotifyFinish(info) end
            return self
        end
        Processor_Apply(resolved, prop, toVal)
        if not isLooping and info and not isAnim then NotifyFinish(info) end
        return self
    end
    local inst = CreateInstance(self, resolved, wrapper, info, nil)
    if not inst or not inst.target then
        if not isLooping and info and not isAnim then NotifyFinish(info) end
        return self
    end
    if isAnim then inst.isAnimationState, inst.animName = true, currentAnimationName end
    PushActive(inst)
    return self
end



local WrapperProto = {}
WrapperProto.__index = WrapperProto

local function CancelAnimationsByName(wrapper, name, target)
    StopWrapperInstances(wrapper, target, name, true)
end

function WrapperProto:State(name, fn)
    if not name or type(fn) ~= "function" then return self end
    local info = wrapperRegistry[self]
    if info then info.states[name] = fn end
    return self
end

function WrapperProto:Animation(name, fn)
    local info = wrapperRegistry[self]
    if info and type(name) == "string" and type(fn) == "function" then
        info.animationStates = info.animationStates or {}
        info.animationStates[name] = fn
    end
    return self
end

local function WrapperPlay(self, target, name, isSecure, ...)
    local info = wrapperRegistry[self]
    if not info then return self end
    local stateTarget, stateName
    if type(name) == "string" then
        stateName, stateTarget = name, target
    elseif type(target) == "string" then
        stateName, stateTarget = target, name
    else
        stateTarget, stateName = target, name
    end
    if not stateName then return self end
    local resolvedTarget = nil
    if stateTarget ~= nil then
        resolvedTarget = Processor_ResolveTarget(stateTarget) or stateTarget
    end
    local targetKey = resolvedTarget or NIL_TARGET
    local animStates = info.animationStates
    local animFn = animStates and animStates[stateName]
    if animFn then
        local animTargets = info.animPlayInfos
        if not animTargets then
            animTargets = setmetatable({}, { __mode = "k" })
            info.animPlayInfos = animTargets
        end
        local perTarget = animTargets[targetKey]
        if not perTarget then
            perTarget = {}
            animTargets[targetKey] = perTarget
        end
        local animInfo = perTarget[stateName]
        if not animInfo then
            animInfo = { runId = 0, pendingCount = 0, startNotified = false }
            perTarget[stateName] = animInfo
        end
        CancelAnimationsByName(self, stateName, resolvedTarget)
        animInfo.runId = (animInfo.runId or 0) + 1
        animInfo.pendingCount, animInfo.finishCallback, animInfo.startCallback, animInfo.startNotified = 0, nil, nil, false
        local prevWrapper, prevRunId, prevIsAnim, prevAnimName, prevInfo = currentWrapper, currentRunId, currentWrapperIsAnimation, currentAnimationName, currentWrapperInfo
        currentWrapper, currentRunId, currentWrapperIsAnimation, currentAnimationName, currentWrapperInfo = self, animInfo.runId, true, stateName, animInfo
        animFn(stateTarget, ...)
        currentWrapper, currentRunId, currentWrapperIsAnimation, currentAnimationName, currentWrapperInfo = prevWrapper, prevRunId, prevIsAnim, prevAnimName, prevInfo
        lastPlayedWrapper = self
        lastPlayedWrapperInfo = animInfo
        return self
    end
    local stateInfo
    if isSecure then
        local stateTargets = info.secureStatePlayInfos
        if not stateTargets then
            stateTargets = setmetatable({}, { __mode = "k" })
            info.secureStatePlayInfos = stateTargets
        end
        local perTarget = stateTargets[targetKey]
        if not perTarget then
            perTarget = {}
            stateTargets[targetKey] = perTarget
        end
        stateInfo = perTarget[stateName]
        if not stateInfo then
            stateInfo = { runId = 0, pendingCount = 0, startNotified = false }
            perTarget[stateName] = stateInfo
        end
    else
        local stateTargets = info.statePlayInfos
        if not stateTargets then
            stateTargets = setmetatable({}, { __mode = "k" })
            info.statePlayInfos = stateTargets
        end
        stateInfo = stateTargets[targetKey]
        if not stateInfo then
            stateInfo = { runId = 0, pendingCount = 0, startNotified = false }
            stateTargets[targetKey] = stateInfo
        end
    end
    StopWrapperInstances(self, resolvedTarget, stateName, false)
    stateInfo.runId = (stateInfo.runId or 0) + 1
    stateInfo.pendingCount, stateInfo.finishCallback, stateInfo.startCallback, stateInfo.startNotified = 0, nil, nil, false
    local stateFn = info.states[stateName]
    if stateFn then
        stateInfo.activeStateName = stateName
        local prevWrapper, prevRunId, prevIsAnim, prevAnimName, prevInfo = currentWrapper, currentRunId, currentWrapperIsAnimation, currentAnimationName, currentWrapperInfo
        currentWrapper, currentRunId, currentWrapperIsAnimation, currentAnimationName, currentWrapperInfo = self, stateInfo.runId, false, nil, stateInfo
        local defCache = info.defCache[stateName]
        if not defCache then
            defCache = { idx = 0 }
            info.defCache[stateName] = defCache
        else
            defCache.idx = 0
        end
        stateFn(stateTarget, ...)
        currentWrapper, currentRunId, currentWrapperIsAnimation, currentAnimationName, currentWrapperInfo = prevWrapper, prevRunId, prevIsAnim, prevAnimName, prevInfo
        lastPlayedWrapper = self
        lastPlayedWrapperInfo = stateInfo
    end
    return self
end

function WrapperProto:Play(target, name, ...)
    return WrapperPlay(self, target, name, false, ...)
end

function WrapperProto:SecurePlay(target, name, ...)
    return WrapperPlay(self, target, name, true, ...)
end

function WrapperProto:IsPlaying(target, name)
    local info = wrapperRegistry[self]
    if not info then return false end
    local queryTarget, queryState
    if name == nil and type(target) == "string" then
        queryState = target
    else
        queryTarget, queryState = target, name
    end
    local resolved = queryTarget and Processor_ResolveTarget(queryTarget)
    for i = 1, activeInstanceCount do
        local inst = activeInstances[i]
        if inst and inst.wrapper == self then
            local matchesState = (not queryState)
                or (inst.isAnimationState and inst.animName == queryState)
                or ((not inst.isAnimationState) and inst.stateName == queryState)
            if matchesState and (not resolved or inst.target == resolved) then
                return true
            end
        end
    end
    return false
end

function WrapperProto:onFinish(cb)
    if lastPlayedWrapper ~= self then return self end

    local info = lastPlayedWrapperInfo
    if not info then
        lastPlayedWrapper = nil
        return self
    end

    if cb then
        if (info.pendingCount or 0) == 0 then cb() else info.finishCallback = cb end
    end

    lastPlayedWrapper = nil
    lastPlayedWrapperInfo = nil
    return self
end

function WrapperProto:onStart(cb)
    if lastPlayedWrapper ~= self then return self end

    local info = lastPlayedWrapperInfo
    if not info then
        lastPlayedWrapper = nil
        return self
    end

    if cb then
        if info.startNotified then cb() else info.startCallback = cb end
    end

    return self
end

function WrapperProto:Stop(target, cancelAnims)
    local resolvedTarget
    if type(target) == "boolean" then
        cancelAnims, resolvedTarget = target, nil
    elseif target then
        resolvedTarget = Processor_ResolveTarget(target)
    end
    local cancelFlag = cancelAnims ~= false
    local info = wrapperRegistry[self]
    if not info then return self end
    if not resolvedTarget then
        info.runId = info.runId + 1
        info.pendingCount, info.finishCallback, info.startCallback, info.startNotified = 0, nil, nil, false
    end
    local stopMark = (info.stopMark or 0) + 1
    info.stopMark = stopMark
    local i = 1
    while i <= activeInstanceCount do
        local inst = activeInstances[i]
        if inst and inst.wrapper == self and (cancelFlag or not inst.isAnimationState) and (not resolvedTarget or inst.target == resolvedTarget) then
            local wInfo = inst.wrapperInfo
            if wInfo and wInfo._stopMark ~= stopMark then
                wInfo.pendingCount, wInfo.finishCallback, wInfo.startCallback, wInfo.startNotified = 0, nil, nil, false
                wInfo._stopMark = stopMark
            end
            FinalizeInstance(inst)
            RemoveActive(i)
        else
            i = i + 1
        end
    end
    return self
end



local function StepInstance(inst, dt)
    local info = inst.wrapperInfo
    if info then
        if inst.runId ~= (info.runId or 0) then return true end
    elseif inst.wrapper then
        info = wrapperRegistry[inst.wrapper]
        if not info or inst.runId ~= info.runId then return true end
        inst.wrapperInfo = info
    end
    local accum = inst.accum + dt
    if accum < MIN_TICK then
        inst.accum = accum; return false
    end
    inst.accum = 0
    local remain = accum
    while remain > 0 do
        local state = inst.state
        if state == STATE_WAIT then
            local timer = inst.timer
            if remain < timer then
                inst.timer = timer - remain; return false
            end
            remain = remain - timer
            inst.state, inst.t, inst.timer = STATE_PLAY, 0, 0
            if not ResolveInstanceValues(inst) then
                if info then NotifyFinish(info) end
                return true
            end
            if inst.startAtPending then
                inst.t = inst.startAt
                inst.startAtPending = false
                ApplyAtElapsed(inst, inst.t)
            end
            TriggerStart(inst)
        elseif state == STATE_PLAY then
            if not ResolveInstanceValues(inst) then
                if info then NotifyFinish(info) end
                return true
            end
            local dur, elapsed = inst.duration, inst.t
            local timeLeft = dur - elapsed
            if remain < timeLeft then
                elapsed = elapsed + remain
                inst.t, remain = elapsed, 0
            else
                elapsed, inst.t = dur, dur
                remain = remain - timeLeft
            end
            ApplyAtElapsed(inst, elapsed)
            local fromVal, toVal, dir = inst.from, inst.to, inst.dir
            local tgt = inst.target
            if tgt.IsVisible and not tgt:IsVisible() then
                if inst.hasBeenVisible and not inst.ignoreVisibility then
                    if not inst.loopType and toVal ~= nil then FastApply(inst, toVal) end
                    if info and not inst.isAnimationState then NotifyFinish(info) end
                    return true
                end
            else
                inst.hasBeenVisible = true
            end
            if elapsed >= dur then
                local loop = inst.loopType
                if not loop then
                    FastApply(inst, dir == 1 and toVal or fromVal)
                    if info then NotifyFinish(info) end
                    return true
                end
                if loop == LOOP_YOYO then inst.dir = -dir end
                local delayE = inst.loopDelayE
                if delayE > 0 then
                    inst.state, inst.timer = STATE_LOOP_DELAY, delayE
                else
                    inst.state, inst.t, inst.timer = STATE_PLAY, 0, 0
                    TriggerStart(inst)
                    local delayS = inst.loopDelayS
                    if delayS > 0 then inst.state, inst.timer = STATE_WAIT, delayS end
                end
            else
                return false
            end
        elseif state == STATE_LOOP_DELAY then
            local timer = inst.timer
            if remain < timer then
                inst.timer = timer - remain; return false
            end
            remain = remain - timer
            inst.state, inst.t, inst.timer = STATE_PLAY, 0, 0
            TriggerStart(inst)
            local delayS = inst.loopDelayS
            if delayS > 0 then inst.state, inst.timer = STATE_WAIT, delayS end
        else
            return true
        end
    end
    return false
end

function UIAnim_Engine.OnUpdate(_, dt)
    if activeInstanceCount == 0 or not dt or dt <= 0 then return end
    local i = 1
    while i <= activeInstanceCount do
        local inst = activeInstances[i]
        if not inst or StepInstance(inst, dt) then RemoveActive(i) else i = i + 1 end
    end
end



function UIAnim_Engine.New()
    local wrapper = {}
    wrapperRegistry[wrapper] = { states = {}, runId = 0, pendingCount = 0, defCache = {}, startNotified = false }
    return setmetatable(wrapper, WrapperProto)
end

function UIAnim_Engine.Animate()
    if currentWrapper then
        local info = wrapperRegistry[currentWrapper]
        local stateName = currentWrapperInfo and currentWrapperInfo.activeStateName or (info and info.activeStateName)
        if info and stateName then
            local cache = info.defCache
            local defs = cache[stateName]
            if not defs then
                defs = { idx = 0 }; cache[stateName] = defs
            end
            local idx = defs.idx + 1
            defs.idx = idx
            local cached = defs[idx]
            if cached then
                ResetDefinition(cached); return cached
            end
            local new = AllocateDefinition()
            defs[idx] = new
            return new
        end
    end
    return AllocateDefinition()
end
