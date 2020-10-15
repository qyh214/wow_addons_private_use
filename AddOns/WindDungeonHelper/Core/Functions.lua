local W, F, L, P, O = unpack(select(2, ...))

local format = format
local print = print
local select = select
local type = type

local GetClassColor = GetClassColor

local function RGBToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function F.CreateColorString(text, r, g, b)
    if not text or not type(text) == "string" then
        print("Cannot find the text.")
        return
    end

    local hex

    if r and g and b then
        hex = RGBToHex(r, g, b)
    else
        hex = RGBToHex(52 / 255, 152 / 255, 219 / 255)
    end

    return "|cff" .. hex .. text .. "|r"
end

function F.CreateClassColorString(text, englishClass)
    if not text or not type(text) == "string" then
        print("Cannot find the text.")
        return
    end
    if not englishClass or type(englishClass) ~= "string" then
        print("Cannot find the class text.")
        return
    end

    local r, g, b = GetClassColor(englishClass)
    return F.CreateColorString(text, r, g, b)
end

function F.Round(number, decimals)
    return format(format("%%.%df", decimals), number)
end