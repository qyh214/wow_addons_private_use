local addonName, DF = ...

-- ============================================================
-- ROSTER UNIT EVENT DISPATCHER
-- ============================================================
--
-- Provides a Grid2-style dispatcher for UNIT_* events that need to fire only
-- for the player's current roster (player + party1-4, or player + raid1-40).
--
-- The problem this solves:
--   * `frame:RegisterEvent("UNIT_AURA")` is global — fires for every unit
--     token in the game (nameplates, targettarget, focus, mouseover, pets,
--     etc.) which is wasteful and, after the 2026-04-07 UnitIsUnit hotfix,
--     causes secret-boolean taint issues in handlers that compare units.
--   * `frame:RegisterUnitEvent("UNIT_AURA", unit1, unit2, ...)` accepts up
--     to 8 unit tokens but each call REPLACES the previous registration on
--     that frame. So a per-unit loop silently drops all but the last unit.
--   * Even with varargs, you'd need multiple frames to cover a 40-man raid.
--
-- The dispatcher works around all of this by maintaining ONE hidden frame
-- per roster unit, each with a single permanent `RegisterUnitEvent(event, unit)`
-- call. The metatable lazily creates frames as units enter the roster, and
-- a control frame listens for `GROUP_ROSTER_UPDATE` to add/remove
-- registrations as the player joins / leaves / changes group composition.
--
-- Consumer API:
--   DF:RegisterRosterUnitEvent(object, event[, method])
--      Subscribe `object` to `event` for all current and future roster units.
--      When the event fires for any roster unit, calls
--      `object:method(event, unit, ...)`. If `method` is omitted, defaults
--      to the event name itself (e.g. `object:UNIT_AURA(event, unit, info)`).
--
--   DF:UnregisterRosterUnitEvent(object, event)
--      Remove this object's subscription for this event. If no other
--      subscribers remain, the event is unregistered from the per-unit
--      frames entirely.
--
--   DF:UnregisterAllRosterUnitEvents(object)
--      Convenience for module shutdown — removes all of this object's
--      subscriptions across every event.
--
-- Test mode boundary:
--   Test mode uses fake unit tokens like "testparty1" which the WoW engine
--   doesn't recognize for `RegisterUnitEvent`. The dispatcher does NOT and
--   CAN NOT fire for test units. Test mode populates frame data via direct
--   function calls (DF:UpdateAllTestFrames etc.), bypassing the event system.
--   This is intentional and pre-existing behavior.
--
-- Pet / vehicle support:
--   The roster set is player + party1-4 OR player + raid1-40. Pets, vehicles,
--   target, focus, mouseover, and nameplates are deliberately excluded. No
--   current consumer needs them. If a future feature does, the architecture
--   can be extended without breaking the existing API.
--
-- Reference: Grid2's GridRosterUnitEvents.lua. We're not copying their code,
-- but the architectural pattern (lazy per-unit frame pool with shared
-- dispatch table) is the same and has been battle-tested for years.
-- ============================================================

local pairs, next, type = pairs, next, type
local CreateFrame = CreateFrame
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitExists = UnitExists
local GetNumGroupMembers = GetNumGroupMembers

-- ============================================================
-- INTERNAL STATE
-- ============================================================

-- frames[unit] = hidden Frame (lazy via metatable __index)
local frames

-- events[eventName] = { [object] = handler_function, ... }
-- Multiple consumers can subscribe to the same event; we route to all of them.
local events = {}

-- rosterUnits[unit] = true for every unit token currently in the roster.
-- Used as the diff baseline when GROUP_ROSTER_UPDATE fires so we know which
-- units joined and which left.
local rosterUnits = {}

-- ============================================================
-- ROSTER COMPUTATION
-- ============================================================

-- Returns a fresh set of unit tokens that count as "the player's roster":
--   * "player" always
--   * party1..N when in a party (and not in raid)
--   * raid1..N when in a raid
--
-- Returns a NEW table each call so the caller can diff against the previous
-- state without aliasing issues.
local function BuildRosterSet()
    local set = { player = true }

    if IsInRaid() then
        local n = GetNumGroupMembers() or 0
        for i = 1, n do
            set["raid" .. i] = true
        end
    elseif IsInGroup() then
        local n = GetNumGroupMembers() or 0
        -- GetNumGroupMembers includes the player; party1..(n-1) are the others
        for i = 1, n - 1 do
            set["party" .. i] = true
        end
    end

    return set
end

-- ============================================================
-- EVENT ROUTING
-- ============================================================

-- Called by the per-unit frame's OnEvent handler when one of the registered
-- events fires for that frame's unit. Routes the event to all consumers that
-- subscribed via DF:RegisterRosterUnitEvent.
--
-- A broken consumer handler must NOT prevent dispatch to other consumers.
-- We pcall each handler call individually so a single bad subscriber can't
-- starve the others. Errors are logged via DF:DebugError but otherwise
-- swallowed at this layer.
local function RouteEvent(self, event, ...)
    local subscribers = events[event]
    if not subscribers then return end

    for object, handler in pairs(subscribers) do
        local ok, err = pcall(handler, object, event, ...)
        if not ok and DF.DebugError then
            DF:DebugError("ROSTER", "Handler error for %s: %s", event, tostring(err))
        end
    end
end

-- Expose the dispatcher indirectly so the profiler can swap it for an
-- instrumented version. The trampoline below routes per-unit frame events
-- through DF._RouteRosterEvent rather than calling RouteEvent directly,
-- which means re-binding DF._RouteRosterEvent at runtime takes effect
-- immediately for every roster frame without re-running SetScript.
-- The cost when the profiler is off is one extra hash lookup + closure
-- call per dispatch — sub-microsecond and dwarfed by the handlers.
DF._RouteRosterEvent = RouteEvent

local function DispatchTrampoline(self, event, ...)
    return DF._RouteRosterEvent(self, event, ...)
end

-- ============================================================
-- LAZY FRAME POOL
-- ============================================================
--
-- One hidden Frame per unit token, created on first access via the metatable
-- __index. Each frame's OnEvent is set to RouteEvent, and once created, the
-- frame is cached for the lifetime of the addon (cheap to keep around — a
-- hidden frame with one event registered is ~200 bytes).

frames = setmetatable({}, {
    __index = function(t, unit)
        local f = CreateFrame("Frame")
        f:Hide()
        f:SetScript("OnEvent", DispatchTrampoline)
        t[unit] = f
        return f
    end,
})

-- ============================================================
-- ROSTER CHANGE HANDLING
-- ============================================================

-- Called on GROUP_ROSTER_UPDATE / PLAYER_LOGIN / PLAYER_ENTERING_WORLD.
-- Diffs the current roster against `rosterUnits` and adjusts the per-unit
-- frame registrations accordingly.
local function RebuildRoster()
    local newRoster = BuildRosterSet()

    -- Find removed units: in old set but not new set.
    -- For each removed unit, unregister every tracked event from its frame.
    -- We keep the frame itself in the pool for cheap reuse if the unit comes
    -- back later (e.g. raid → party → raid).
    for unit in pairs(rosterUnits) do
        if not newRoster[unit] then
            local frame = rawget(frames, unit)
            if frame then
                for event in pairs(events) do
                    frame:UnregisterEvent(event)
                end
            end
        end
    end

    -- Find added units: in new set but not old set.
    -- For each added unit, register every tracked event on its frame.
    -- Accessing frames[unit] via the metatable creates the frame if needed.
    for unit in pairs(newRoster) do
        if not rosterUnits[unit] then
            local frame = frames[unit]
            for event in pairs(events) do
                frame:RegisterUnitEvent(event, unit)
            end
        end
    end

    rosterUnits = newRoster
end

-- Single control frame listening for roster-change events. This is the only
-- `RegisterEvent` call in this module — everything else uses `RegisterUnitEvent`
-- on the per-unit frames.
local controlFrame = CreateFrame("Frame")
controlFrame:Hide()
controlFrame:SetScript("OnEvent", function(self, event)
    RebuildRoster()
end)
controlFrame:RegisterEvent("PLAYER_LOGIN")
controlFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
controlFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

-- ============================================================
-- PUBLIC API
-- ============================================================

-- Subscribe `object` to `event` for all current and future roster units.
-- When the event fires for any roster unit, calls
-- `object:method(event, unit, ...)`.
--
-- If `method` is omitted, defaults to the event name itself, e.g.:
--   DF:RegisterRosterUnitEvent(myModule, "UNIT_AURA")
--   -- calls myModule:UNIT_AURA(event, unit, updateInfo)
function DF:RegisterRosterUnitEvent(object, event, method)
    if type(object) ~= "table" then
        if DF.DebugError then
            DF:DebugError("ROSTER", "RegisterRosterUnitEvent: object must be a table")
        end
        return
    end
    if type(event) ~= "string" then
        if DF.DebugError then
            DF:DebugError("ROSTER", "RegisterRosterUnitEvent: event must be a string")
        end
        return
    end

    local methodName = method or event
    local handler = object[methodName]
    if type(handler) ~= "function" then
        if DF.DebugError then
            DF:DebugError("ROSTER", "RegisterRosterUnitEvent: %s.%s is not a function", tostring(object), tostring(methodName))
        end
        return
    end

    -- First subscriber for this event: register it on every roster frame.
    if not events[event] then
        events[event] = {}
        -- If we somehow get here before PLAYER_LOGIN has fired, rosterUnits
        -- will be empty. The first PLAYER_LOGIN / PLAYER_ENTERING_WORLD will
        -- populate rosterUnits and call RebuildRoster, which iterates `events`
        -- and registers everything. So this works correctly either way.
        for unit in pairs(rosterUnits) do
            frames[unit]:RegisterUnitEvent(event, unit)
        end
    end

    events[event][object] = handler
end

-- Remove `object`'s subscription for `event`. If no subscribers remain for
-- this event, fully unregister it from the per-unit frames.
function DF:UnregisterRosterUnitEvent(object, event)
    local subscribers = events[event]
    if not subscribers then return end

    subscribers[object] = nil

    -- Last subscriber gone: tear down the underlying frame registrations.
    if next(subscribers) == nil then
        events[event] = nil
        for unit in pairs(rosterUnits) do
            local frame = rawget(frames, unit)
            if frame then
                frame:UnregisterEvent(event)
            end
        end
    end
end

-- Convenience for module shutdown / disable. Removes all of `object`'s
-- subscriptions across every tracked event.
function DF:UnregisterAllRosterUnitEvents(object)
    -- Iterate a snapshot of event names so we don't mutate `events` during
    -- iteration (UnregisterRosterUnitEvent may delete keys from it).
    local toRemove = {}
    for event, subscribers in pairs(events) do
        if subscribers[object] then
            toRemove[#toRemove + 1] = event
        end
    end
    for i = 1, #toRemove do
        DF:UnregisterRosterUnitEvent(object, toRemove[i])
    end
end

-- ============================================================
-- SELF-TEST (Phase 1 verification)
-- ============================================================
--
-- Runtime-toggleable probe handler that logs every UNIT_AURA event the
-- dispatcher routes. Use it to verify in-game that:
--   * The dispatcher fires for player and roster units only
--   * It does NOT fire for nameplate / targettarget / focus / mouseover units
--   * Roster transitions (party<->raid, joins, leaves) work correctly
--
-- Usage (no /reload required):
--   /run DandersFrames:EnableRosterEventsSelfTest()
--   -- ... do stuff, watch /df console ROSTER category ...
--   /run DandersFrames:DisableRosterEventsSelfTest()
--
-- The probe is a single shared object so calling Enable twice is idempotent.

local selfTestProbe = {}
function selfTestProbe:UNIT_AURA(event, unit, info)
    if DF.Debug then
        DF:Debug("ROSTER", "Self-test: %s on %s", event, tostring(unit))
    end
end

function DF:EnableRosterEventsSelfTest()
    DF:RegisterRosterUnitEvent(selfTestProbe, "UNIT_AURA")
    if DF.Debug then
        DF:Debug("ROSTER", "Self-test ENABLED. Watch /df console ROSTER category for UNIT_AURA events.")
    end
end

function DF:DisableRosterEventsSelfTest()
    DF:UnregisterRosterUnitEvent(selfTestProbe, "UNIT_AURA")
    if DF.Debug then
        DF:Debug("ROSTER", "Self-test DISABLED.")
    end
end
