local env = select(2, ...)
local Utils_LazyTable = env.modules:Import("packages\\utils\\lazy-table")
local UIKit_FrameCache = env.modules:New("packages\\ui-kit\\frame-cache")

local LazyTable_Length = Utils_LazyTable.Length
local LazyTable_Get = Utils_LazyTable.Get

local cache = {}
local cacheVersion = 0

function UIKit_FrameCache.Add(id, frame)
    cache[id] = frame
    cacheVersion = cacheVersion + 1
end

function UIKit_FrameCache.Remove(id)
    cache[id] = nil
    cacheVersion = cacheVersion + 1
end

function UIKit_FrameCache.MarkChildrenDirty(frame)
    frame.__frameCacheVersion = nil
end

function UIKit_FrameCache.Get(id)
    return cache[id]
end

function UIKit_FrameCache.GetFramesInLazyTable(frame, name)
    local numChildren = LazyTable_Length(frame, name)
    if not numChildren then return end

    -- Fast path: skip rebuild if cache is still valid
    local storedVersion = frame.__frameCacheVersion
    local storedLength = frame.__frameCacheLength
    if storedVersion == cacheVersion and storedLength == numChildren and frame.__frameCache then
        return frame.__frameCache
    end

    -- Store children results in a temporary Lazy table to prevent creating new tables per call
    frame.__frameCache = frame.__frameCache or {}

    local result = frame.__frameCache
    local previousLength = storedLength or 0
    for i = 1, numChildren do
        -- Parse each children and add to results
        local currentFrame = LazyTable_Get(frame, name, i)
        if currentFrame ~= nil then
            result[i] = cache[currentFrame]
        else
            result[i] = nil
        end
    end

    if previousLength > numChildren then
        for i = numChildren + 1, previousLength do
            result[i] = nil
        end
    end

    frame.__frameCacheLength = numChildren
    frame.__frameCacheVersion = cacheVersion

    return result
end
