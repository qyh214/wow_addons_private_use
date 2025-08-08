---@class AbstractFramework
local AF = _G.AbstractFramework

-- NOTE: it's highly recommended to use a unique prefix for every event

local callbacks = {
    -- invoke priority
    high = {},
    medium = {},
    low = {},
}

---@param event string
---@param callback fun(event:string, ...:any) function to call when event is fired
---@param priority string? "high"|"medium"|"low", default is "medium".
---@param tag string? for Unregister/Get
function AF.RegisterCallback(event, callback, priority, tag)
    assert(not priority or priority == "high" or priority == "medium" or priority == "low", "Priority must be high, medium, low or nil.")
    local t = callbacks[priority or "medium"]
    if not t[event] then t[event] = {} end
    t[event][callback] = tag or true
end

---@param event string
---@param tag string
---@return table callbacks list of functions, can be empty
function AF.GetCallback(event, tag)
    local result = {}
    for _, t in pairs(callbacks) do
        if t[event] then
            for fn, v in pairs(t[event]) do
                if v == tag then
                    tinsert(result, fn)
                end
            end
        end
    end
    return result
end

---@param event string
---@param callback function|string function or tag
function AF.UnregisterCallback(event, callback)
    for _, t in pairs(callbacks) do
        if t[event] then
            if type(callback) == "function" then
                t[event][callback] = nil
            elseif type(callback) == "string" then
                for fn, tag in pairs(t[event]) do
                    if tag == callback then
                        t[event][fn] = nil
                        break
                    end
                end
            end
        end
    end
end

function AF.UnregisterAllCallbacks(event)
    for _, t in pairs(callbacks) do
        t[event] = nil
    end
end

AF.DEBUG_EVENTS = {
    AF_SCALE_CHANGED = "blazing_tangerine",
    AF_PIXEL_UPDATE_START = false,
    AF_PIXEL_UPDATE_END = false,
    AF_LOADED = "blazing_tangerine",
    AF_PLAYER_DATA_UPDATE = "lightblue",
    AF_INSTANCE_ENTER = "sand",
    AF_INSTANCE_LEAVE = "sand",
    AF_INSTANCE_STATE_CHANGE = "sand",
    AF_PLAYER_LOGIN = "gray",
    AF_PLAYER_ENTERING_WORLD = "gray",
    AF_COMBAT_ENTER = false,
    AF_COMBAT_LEAVE = false,
    AF_JOIN_TEMP_CHANNEL = "classicrose",
    AF_LEAVE_TEMP_CHANNEL = "classicrose",
}

function AF.Fire(event, ...)
    if AFConfig.debugMode then
        local e = event
        if AF.DEBUG_EVENTS[event] then
            e = AF.WrapTextInColor(event, AF.DEBUG_EVENTS[event])
        end
        if AF.DEBUG_EVENTS[event] ~= false then
            if select("#", ...) > 0 then
                print(AF.WrapTextInColor("[EVENT]", "hotpink"), e, AF.GetColorStr("gray") .. ":", ...)
            else
                print(AF.WrapTextInColor("[EVENT]", "hotpink"), e)
            end
        end
    end

    if callbacks.high[event] then
        for fn in pairs(callbacks.high[event]) do
                fn(event, ...)
            end
    end

    if callbacks.medium[event] then
        for fn in pairs(callbacks.medium[event]) do
            fn(event, ...)
        end
    end

    if callbacks.low[event] then
        for fn in pairs(callbacks.low[event]) do
            fn(event, ...)
        end
    end
end

function AF.GetFireFunc(event, ...)
    local a1, a2, a3 = ...
    local numArgs = select("#", ...)
    local args
    if numArgs > 3 then
        args = {...}
    end

    if numArgs == 0 then
        return function()
            AF.Fire(event)
        end
    elseif numArgs == 1 then
        return function()
            AF.Fire(event, a1)
        end
    elseif numArgs == 2 then
        return function()
            AF.Fire(event, a1, a2)
        end
    elseif numArgs == 3 then
        return function()
            AF.Fire(event, a1, a2, a3)
        end
    else
        return function()
            AF.Fire(event, unpack(args, 1, numArgs))
        end
    end
end

---------------------------------------------------------------------
-- addon loaded
---------------------------------------------------------------------
local addonCallbacks = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon, containsBindings)
    if addonCallbacks[addon] then
        for _, fn in pairs(addonCallbacks[addon]) do
            fn(addon, containsBindings)
        end
    end
end)

function AF.RegisterAddonLoaded(addon, func)
    if not addonCallbacks[addon] then addonCallbacks[addon] = {} end
    tinsert(addonCallbacks[addon], func)
end