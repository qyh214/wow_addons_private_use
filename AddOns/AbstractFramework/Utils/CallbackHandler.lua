---@class AbstractFramework
local AF = _G.AbstractFramework

-- NOTE: for better performance, you might want to move these to your addon

local callbacks = {
    -- invoke priority
    high = {},
    medium = {},
    low = {},
}

---@param event string
---@param callback function
---@param priority string? "high"|"medium"|"low", default is "medium"
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

function AF.Fire(event, ...)
    if callbacks.high[event] then
        for fn in pairs(callbacks.high[event]) do
                fn(...)
            end
    end

    if callbacks.medium[event] then
        for fn in pairs(callbacks.medium[event]) do
            fn(...)
        end
    end

    if callbacks.low[event] then
        for fn in pairs(callbacks.low[event]) do
            fn(...)
        end
    end
end

function AF.GetFireFunc(event, ...)
    local args = {...}
    return function()
        AF.Fire(event, unpack(args))
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