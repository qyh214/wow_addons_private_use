local env = select(2, ...)
local Utils_Conversion = env.modules:New("packages\\utils\\conversion")

function Utils_Conversion.ConvertYardsToMetric(yards)
    local meters = yards * 0.9144
    local km = meters / 1000
    local m = meters % 1000
    return km, m
end
