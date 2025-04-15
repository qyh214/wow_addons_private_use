---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local sharedEventHandler = CreateFrame("Frame", "AF_EVENT_HANDLER")
local _RegisterEvent = sharedEventHandler.RegisterEvent
local _RegisterUnitEvent = sharedEventHandler.RegisterUnitEvent
local _UnregisterEvent = sharedEventHandler.UnregisterEvent
local _UnregisterAllEvents = sharedEventHandler.UnregisterAllEvents


---------------------------------------------------------------------
-- CLEU
---------------------------------------------------------------------
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local cleuDispatcher = CreateFrame("Frame", "AF_CLEU_HANDLER")
cleuDispatcher.eventFuncs = {}

local function DispatchCLEU(_, subevent, ...)
    if cleuDispatcher.eventFuncs[subevent] then
        for fn, obj in pairs(cleuDispatcher.eventFuncs[subevent]) do
            fn(obj, subevent, ...)
        end
    end
end

cleuDispatcher:SetScript("OnEvent", function()
    DispatchCLEU(CombatLogGetCurrentEventInfo())
end)

local function RegisterCLEU(obj, subevent, ...)
    if not cleuDispatcher:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
        cleuDispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end

    if not cleuDispatcher.eventFuncs[subevent] then
        cleuDispatcher.eventFuncs[subevent] = {}
    end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        cleuDispatcher.eventFuncs[subevent][fn] = obj
    end
end

local function UnregisterCLEU(obj, subevent)
    if not cleuDispatcher.eventFuncs[subevent] then return end

    if subevent then
        for f, o in pairs(cleuDispatcher.eventFuncs[subevent]) do
            if obj == o then
                cleuDispatcher.eventFuncs[subevent][f] = nil
            end
        end
    else
        --! NOT IDEAL
        for _, sub in pairs(cleuDispatcher.eventFuncs) do
            for f, o in pairs(sub) do
                if obj == o then
                    sub[f] = nil
                end
            end
        end
    end

    if AF.IsEmpty(cleuDispatcher.eventFuncs[subevent]) then
        cleuDispatcher.eventFuncs[subevent] = nil
    end

    if AF.IsEmpty(cleuDispatcher.eventFuncs) and cleuDispatcher:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
        cleuDispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end


---------------------------------------------------------------------
-- register / unregister events
---------------------------------------------------------------------
local function RegisterEvent(self, event, ...)
    if not self._eventHandler.eventFuncs[event] then self._eventHandler.eventFuncs[event] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self._eventHandler.eventFuncs[event][fn] = true
    end

    _RegisterEvent(self._eventHandler, event)
end

local function RegisterUnitEvent(self, event, unit, ...)
    if not self._eventHandler.eventFuncs[event] then self._eventHandler.eventFuncs[event] = {} end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self._eventHandler.eventFuncs[event][fn] = true
    end

    if type(unit) == "table" then
        _RegisterUnitEvent(self._eventHandler, event, unpack(unit))
    else
        _RegisterUnitEvent(self._eventHandler, event, unit)
    end
end

local function UnregisterEvent(self, event, ...)
    if not self._eventHandler.eventFuncs[event] then return end

    if select("#", ...) == 0 then
        self._eventHandler.eventFuncs[event] = nil
        _UnregisterEvent(self._eventHandler, event)
        return
    end

    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        self._eventHandler.eventFuncs[event][fn] = nil
    end

    -- check if isEmpty
    if AF.IsEmpty(self._eventHandler.eventFuncs[event]) then
        self._eventHandler.eventFuncs[event] = nil
        _UnregisterEvent(self._eventHandler, event)
    end
end

local function UnregisterAllEvents(self)
    wipe(self._eventHandler.eventFuncs)
    _UnregisterAllEvents(self._eventHandler)
end


---------------------------------------------------------------------
-- process events
---------------------------------------------------------------------
local function HandleEvent(eventHandler, event, ...)
    if eventHandler.eventFuncs[event] then -- wipe on hide
        for fn in pairs(eventHandler.eventFuncs[event]) do
            fn(eventHandler.owner, event, ...)
        end
    end
end

---------------------------------------------------------------------
-- local UNIT_EVENT_PATTERN = "^UNIT_"
-- local function SquashAndHandleEvent(eventHandler, event, ...)
--     if event:match(UNIT_EVENT_PATTERN) then
--         local unit = ...
--         if not eventHandler.squashedUnitEvents[event] then
--             eventHandler.squashedUnitEvents[event] = {}
--         end
--         eventHandler.squashedUnitEvents[event][unit] = {select(2, ...)}
--     else
--         eventHandler.squashedEvents[event] = {...}
--     end

--     if not eventHandler.nextTickScheduled then
--         eventHandler.nextTickScheduled = true
--         C_Timer.After(0, eventHandler.nextTickHandler)
--     end
-- end
---------------------------------------------------------------------

---------------------------------------------------------------------
-- local function CoroutineProcessEvents()
--     while true do
--         -- print("CoroutineProcessEvents", coroutine.running())
--         HandleEvent(coroutine.yield())
--     end
-- end
-- NOTE: poor performance
-- local sharedCoroutine = coroutine.wrap(CoroutineProcessEvents)

-- local eventQueue = AF.NewQueue()
-- local eventsProcessed = 0
-- local tickEventsNum = 0
-- local MAX_EVENTS_PER_TICK = 1000
-- local before

-- local function ProcessEvents()
--     -- before = eventQueue.length

--     while eventQueue.length > 0 and eventsProcessed < MAX_EVENTS_PER_TICK do
--         eventsProcessed = eventsProcessed + 1
--         -- sharedCoroutine(AF.Unpack7(eventQueue:pop()))
--         HandleEvent(AF.Unpack7(eventQueue:pop()))
--     end

--     -- if eventQueue.length > 0 then
--     --     print(format("------------- START %s", GetTime()))
--     --     print("Before:", before)
--     --     print("Remains:", eventQueue.length)
--     --     print(" ")
--     -- end
-- end

-- local function MergeEvent(obj, event, arg1, arg2, arg3, arg4, arg5)
--     if tickEventsNum <= MAX_EVENTS_PER_TICK then
--         tickEventsNum = tickEventsNum + 1
--         HandleEvent(obj.owner or obj, event, arg1, arg2, arg3, arg4, arg5)
--     else
--         eventQueue:push({obj.owner or obj, event, arg1, arg2, arg3, arg4, arg5})
--     end
-- end

-- local ticker, OnTick
-- OnTick = function()
--     tickEventsNum = 0

--     if eventQueue.first > eventQueue.threshold then
--         ticker:Cancel()
--         eventQueue:shrink()
--         C_VoiceChat.SpeakText(0, "queue shrinked", Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
--         ticker = C_Timer.NewTicker(0, OnTick)
--     end

--     if eventQueue.length > 0 then
--         eventsProcessed = 0
--         ProcessEvents()
--     end
-- end
-- ticker = C_Timer.NewTicker(0, OnTick)
---------------------------------------------------------------------


---------------------------------------------------------------------
-- add event handler
---------------------------------------------------------------------
---@param obj table
--@param squashEvents boolean
function AF.AddEventHandler(obj)
    obj.RegisterCLEU = RegisterCLEU
    obj.UnregisterCLEU = UnregisterCLEU

    obj._eventHandler = CreateFrame("Frame")
    obj._eventHandler.owner = obj
    obj._eventHandler.eventFuncs = {}

    -- if squashEvents then
    --     obj._eventHandler.squashedEvents = {}
    --     obj._eventHandler.squashedUnitEvents = {}
    --     obj._eventHandler.nextTickHandler = function()
    --         obj._eventHandler.nextTickScheduled = false
    --         for e, params in pairs(obj._eventHandler.squashedEvents) do
    --             HandleEvent(obj._eventHandler, e, AF.Unpack5(params))
    --         end
    --         wipe(obj._eventHandler.squashedEvents)
    --         for e, paramsTable in pairs(obj._eventHandler.squashedUnitEvents) do
    --             local name = obj.GetName and obj:GetName() or ""
    --             for unit, params in pairs(paramsTable) do
    --                 HandleEvent(obj._eventHandler, e, unit, AF.Unpack4(params))
    --             end
    --         end
    --         wipe(obj._eventHandler.squashedUnitEvents)
    --     end
    --     obj._eventHandler:SetScript("OnEvent", SquashAndHandleEvent)
    -- else
        obj._eventHandler:SetScript("OnEvent", HandleEvent)
    -- end

    obj.RegisterEvent = RegisterEvent
    obj.RegisterUnitEvent = RegisterUnitEvent
    obj.UnregisterEvent = UnregisterEvent
    obj.UnregisterAllEvents = UnregisterAllEvents
end


---------------------------------------------------------------------
-- simple event handler
---------------------------------------------------------------------

---@class AF_BasicEventHandler
local AF_BasicEventHandlerMixin = {}

function AF_BasicEventHandlerMixin:RegisterEvent(...)
    for i = 1, select("#", ...) do
        local event = select(i, ...)
        _RegisterEvent(self, event)
    end
end

---@param frame Frame
function AF.AddSimpleEventHandler(frame)
    frame:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    Mixin(frame, AF_BasicEventHandlerMixin)
end


--[[
    Creates a simple event handler instance that you can extend with custom event functions.

    To add event handling functionality, define event methods on the handler using the colon syntax.
    For example, to handle an event called "EVENT":
        handler:RegisterEvent("EVENT")
        function handler:EVENT(...) end
--]]
---@param ... string events
---@return AF_BasicEventHandler handler
function AF.CreateSimpleEventHandler(...)
    local handler = CreateFrame("Frame")

    handler:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)

    Mixin(handler, AF_BasicEventHandlerMixin)
    if select("#", ...) > 0 then
        handler:RegisterEvent(...)
    end

    return handler
end


---@param onEventFunc function (self, event, ...)
---@param ... string events
---@return AF_BasicEventHandler handler
function AF.CreateBasicEventHandler(onEventFunc, ...)
    local handler = CreateFrame("Frame")
    handler:SetScript("OnEvent", onEventFunc)

    Mixin(handler, AF_BasicEventHandlerMixin)
    handler:RegisterEvent(...)

    return handler
end