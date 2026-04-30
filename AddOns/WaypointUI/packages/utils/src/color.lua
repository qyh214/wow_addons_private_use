local env = select(2, ...)
local Utils_Color = env.modules:New("packages\\utils\\color")

local assert = assert
local tonumber = tonumber
local min = math.min
local gsub = string.gsub
local sub = string.sub

function Utils_Color.StripColorCodes(text)
    if text == nil then return "" end

    local stripped = gsub(text, "|cff%x%x%x%x%x%x%x%x", "")
    stripped = gsub(stripped, "|r", "")
    stripped = gsub(stripped, "|cn.-:", "")
    return stripped
end

function Utils_Color.ParseRGBA(obj)
    obj.r = min(obj.r / 255, 1)
    obj.g = min(obj.g / 255, 1)
    obj.b = min(obj.b / 255, 1)
    obj.a = min(obj.a or 1, 1)
    return obj
end

function Utils_Color.ParseHex(obj)
    assert(obj and obj.hex, "Invalid `hex` format!")

    local hex = gsub(obj.hex, "^#?%s*", "")
    if #hex == 6 then hex = hex .. "FF" end

    obj.a = tonumber(sub(hex, 1, 2), 16) / 255
    obj.r = tonumber(sub(hex, 3, 4), 16) / 255
    obj.g = tonumber(sub(hex, 5, 6), 16) / 255
    obj.b = tonumber(sub(hex, 7, 8), 16) / 255

    return obj
end
