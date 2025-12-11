local env         = select(2, ...)

local type        = type
local assert      = assert
local tonumber    = tonumber
local math_min    = math.min
local string_gsub = string.gsub
local string_sub  = string.sub

local Utils_Color = env.WPM:New("wpm_modules/utils/color")


-- API
--------------------------------

function Utils_Color.StripColorCodes(text)
    if text == nil then return "" end

    local stripped = string_gsub(text, "|cff%x%x%x%x%x%x%x%x", "")
    stripped = string_gsub(stripped, "|r", "")
    stripped = string_gsub(stripped, "|cn.-:", "")
    return stripped
end

function Utils_Color.ParseRGBA(rgba)
    rgba.r = math_min(rgba.r / 255, 1)
    rgba.g = math_min(rgba.g / 255, 1)
    rgba.b = math_min(rgba.b / 255, 1)
    rgba.a = math_min(rgba.a or 1, 1)
    return rgba
end

function Utils_Color.ParseHex(hex)
    assert(type(hex) == "string", "`hex` must be a string")

    hex = string_gsub(hex, "^#?%s*", "")
    if #hex == 6 then hex = hex .. "FF" end

    return {
        r = tonumber(string_sub(hex, 1, 2), 16) / 255,
        g = tonumber(string_sub(hex, 3, 4), 16) / 255,
        b = tonumber(string_sub(hex, 5, 6), 16) / 255,
        a = tonumber(string_sub(hex, 7, 8), 16) / 255
    }
end
