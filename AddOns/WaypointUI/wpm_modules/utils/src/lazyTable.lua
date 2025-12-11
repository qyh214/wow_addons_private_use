local env             = select(2, ...)

local rawset          = rawset
local rawget          = rawget
local setmetatable    = setmetatable

local Utils_LazyTable = env.WPM:New("wpm_modules/utils/lazy-table")


-- Shared
--------------------------------

local prefixCache = setmetatable({}, {
    __index = function(self, name)
        local prefix = "LT_" .. name
        rawset(self, name, prefix)
        return prefix
    end
})

local indexKeyCache = {}


-- Helpers
--------------------------------

local function getIndexKey(prefix, index)
    local cache = indexKeyCache[prefix]
    if not cache then
        cache = {}
        indexKeyCache[prefix] = cache
    end

    local key = cache[index]
    if not key then
        key = prefix .. index
        cache[index] = key
    end
    return key
end


-- API
--------------------------------

function Utils_LazyTable.New(parent, name)
    rawset(parent, prefixCache[name], 0)
end

function Utils_LazyTable.Length(parent, name)
    return rawget(parent, prefixCache[name])
end

function Utils_LazyTable.Insert(parent, name, value)
    local prefix = prefixCache[name]
    local length = rawget(parent, prefix) or 0
    length = length + 1
    rawset(parent, prefix, length)
    rawset(parent, getIndexKey(prefix, length), value)
end

function Utils_LazyTable.Set(parent, name, index, value)
    rawset(parent, getIndexKey(prefixCache[name], index), value)
end

function Utils_LazyTable.Remove(parent, name, index)
    local prefix = prefixCache[name]
    rawset(parent, getIndexKey(prefix, index), nil)
    rawset(parent, prefix, rawget(parent, prefix) - 1)
end

function Utils_LazyTable.Get(parent, name, index)
    return rawget(parent, getIndexKey(prefixCache[name], index))
end
