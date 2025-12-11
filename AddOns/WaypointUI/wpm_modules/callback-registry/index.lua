local env              = select(2, ...)

local tinsert     = table.insert
local floor       = math.floor

local CallbackRegistry = env.WPM:New("wpm_modules/callback-registry")
local db               = {}


-- Helpers
--------------------------------

local function insertCallback(callbacks, entry)
    local low, high = 1, #callbacks

    while low <= high do
        local mid = floor((low + high) * 0.5)
        if entry.priority < callbacks[mid].priority then
            high = mid - 1
        else
            low = mid + 1
        end
    end

    tinsert(callbacks, low, entry)
end


-- API
--------------------------------

function CallbackRegistry:Add(id, func, priority)
    local callbacks = db[id]
    if not callbacks then
        callbacks = {}
        db[id] = callbacks
    end

    insertCallback(callbacks, {
        func     = func,
        priority = priority or 0
    })
end

function CallbackRegistry:Trigger(id, ...)
    local callbacks = db[id]
    if not callbacks then return end

    for i = 1, #callbacks do
        callbacks[i].func(id, ...)
    end
end
