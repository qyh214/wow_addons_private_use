local env            = select(2, ...)
local Waypoint_Cache = env.modules:New("@\\Waypoint\\Cache")

Waypoint_Cache.navFrame = nil
local Cache = {}

function Waypoint_Cache.Set(k, v)
    Cache[k] = v
end

function Waypoint_Cache.Get(k)
    return Cache[k]
end

function Waypoint_Cache.Clear()
    for k, _ in pairs(Cache) do
        Cache[k] = nil
    end
end
