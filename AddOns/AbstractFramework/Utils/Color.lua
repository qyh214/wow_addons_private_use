---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- color utils
---------------------------------------------------------------------

-- convert rgba 0-255 to 0-1
---@param r number
---@param g number
---@param b number
---@param a? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.ConvertToRGB(r, g, b, a, saturation)
    saturation = saturation or 1
    r = AF.RoundToDecimal(r / 255 * saturation, 5)
    g = AF.RoundToDecimal(g / 255 * saturation, 5)
    b = AF.RoundToDecimal(b / 255 * saturation, 5)
    a = a and AF.RoundToDecimal(a / 255, 5)
    return r, g, b, a
end

-- convert rgba 0-1 to 0-255
---@param r number
---@param g number
---@param b number
---@param a? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.ConvertToRGB256(r, g, b, a, saturation)
    saturation = saturation or 1
    r = floor(r * 255 * saturation)
    g = floor(g * 255 * saturation)
    b = floor(b * 255 * saturation)
    a = a and floor(a * 255 * saturation)
    return r, g, b, a
end

--  convert rgb 0-255 to hex
---@param r number
---@param g number
---@param b number
---@param a? number
---@return string hex rrggbb or aarrggbb
function AF.ConvertRGB256ToHEX(r, g, b, a)
    local result = ""

    local t = a and {a, r, g, b} or {r, g, b}

    for key, value in pairs(t) do
        local hex = ""

        while (value > 0) do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789abcdef", index, index) .. hex
        end

        if (string.len(hex) == 0) then
            hex = "00"
        elseif (string.len(hex) == 1) then
            hex = "0" .. hex
        end

        result = result .. hex
    end

    return result
end

-- convert rgb 0-1 to hex
---@param r number
---@param g number
---@param b number
---@param a? number
---@return string hex rrggbb or aarrggbb
function AF.ConvertRGBToHEX(r, g, b, a)
    return AF.ConvertRGB256ToHEX(AF.ConvertToRGB256(r, g, b, a))
end

-- convert hex to rgb 0-255
---@param hex string
---@return number r
---@return number g
---@return number b
---@return number? a
function AF.ConvertHEXToRGB256(hex)
    hex = hex:gsub("#", "")
    if strlen(hex) == 6 then
        return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
    else
        return tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)), tonumber("0x" .. hex:sub(7, 8)), tonumber("0x" .. hex:sub(1, 2))
    end
end

-- convert hex to rgb 0-1
---@param hex string
---@return number r
---@return number g
---@return number b
---@return number? a
function AF.ConvertHEXToRGB(hex)
    return AF.ConvertToRGB(AF.ConvertHEXToRGB256(hex))
end

-- https://warcraft.wiki.gg/wiki/ColorGradient
---@param perc number current percentage
---@param r1 number start r
---@param g1 number start g
---@param b1 number start b
---@param r2 number middle r
---@param g2 number middle g
---@param b2 number middle b
---@param r3 number end r
---@param g3 number end g
---@param b3 number end b
---@return number r
---@return number g
---@return number b
function AF.ColorGradient(perc, r1, g1, b1, r2, g2, b2, r3, g3, b3)
    perc = perc or 1
    if perc >= 1 then
        return r3, g3, b3
    elseif perc <= 0 then
        return r1, g1, b1
    end

    local segment, relperc = math.modf(perc * 2)
    -- local rr1, rg1, rb1, rr2, rg2, rb2 = select((segment * 3) + 1, r1, g1, b1, r2, g2, b2, r3, g3, b3)
    if segment == 0 then
        return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
    else
        return r2 + (r3 - r2) * relperc, g2 + (g3 - g2) * relperc, b2 + (b3 - b2) * relperc
    end
end

-- From ColorPickerAdvanced by Feyawen-Llane
---@param r number [0, 1]
---@param g number [0, 1]
---@param b number [0, 1]
---@return number h [0, 360] hue
---@return number s [0, 1] saturation
---@return number b [0, 1] brightness
function AF.ConvertRGBToHSB(r, g, b)
    local colorMax = max(r, g, b)
    local colorMin = min(r, g, b)
    local delta = colorMax - colorMin
    local H, S, B

    -- WoW's LUA doesn't handle floating point numbers very well (Somehow 1.000000 != 1.000000   WTF?)
    -- So we do this weird conversion of, Number to String back to Number, to make the IF..THEN work correctly!
    colorMax = tonumber(format("%f", colorMax))
    r = tonumber(format("%f", r))
    g = tonumber(format("%f", g))
    b = tonumber(format("%f", b))

    if delta > 0 then
        if (colorMax == r) then
            H = 60 * (((g - b) / delta) % 6)
        elseif (colorMax == g) then
            H = 60 * (((b - r) / delta) + 2)
        elseif (colorMax == b) then
            H = 60 * (((r - g) / delta) + 4)
        end

        if colorMax > 0 then
            S = delta / colorMax
        else
            S = 0
        end

        B = colorMax
    else
        H = 0
        S = 0
        B = colorMax
    end

    if H < 0 then
        H = H + 360
    end

    return H, S, B
end

-- From ColorPickerAdvanced by Feyawen-Llane
---@param h number [0, 360] hue
---@param s number [0, 1] saturation
---@param b number [0, 1] brightness
---@return number r [0, 1]
---@return number g [0, 1]
---@return number b [0, 1]
function AF.ConvertHSBToRGB(h, s, b)
    local chroma = b * s
    local prime = (h / 60) % 6
    local X = chroma * (1 - abs((prime % 2) - 1))
    local M = b - chroma
    local R, G, B

    if prime < 1 then
        R, G, B = chroma, X, 0
    elseif prime < 2 then
        R, G, B = X, chroma, 0
    elseif prime < 3 then
        R, G, B = 0, chroma, X
    elseif prime < 4 then
        R, G, B = 0, X, chroma
    elseif prime < 5 then
        R, G, B = X, 0, chroma
    elseif prime < 6 then
        R, G, B = chroma, 0, X
    else
        R, G, B = 0, 0, 0
    end

    R = tonumber(format("%.3f", R + M))
    G = tonumber(format("%.3f", G + M))
    B = tonumber(format("%.3f", B + M))

    return R, G, B
end

---@param r number [0, 1]
---@param g number [0, 1]
---@param b number [0, 1]
---@param factor number [0, 1]
---@return number r [0, 1]
---@return number g [0, 1]
---@return number b [0, 1]
function AF.ScaleColor(r, g, b, factor)
    factor = factor or 1
    r = AF.Clamp(r * factor, 0, 1)
    g = AF.Clamp(g * factor, 0, 1)
    b = AF.Clamp(b * factor, 0, 1)
    return r, g, b
end

---@param color string hex color
---@param factor number [0, 1]
---@param alpha number|nil [0, 1]
---@return string hexColor aarrggbb
function AF.ScaleColorHex(color, factor, alpha)
    local r, g, b, a = AF.ConvertHEXToRGB(color)
    factor = factor or 1
    alpha = alpha or a or 1
    return AF.ConvertRGBToHEX(r * factor, g * factor, b * factor, alpha)
end

---@param r number [0, 1]
---@param g number [0, 1]
---@param b number [0, 1]
---@param a? number [0, 1]
---@return number r [0, 1]
---@return number g [0, 1]
---@return number b [0, 1]
---@return number? a [0, 1]
function AF.InvertColor(r, g, b, a)
    return 1 - r, 1 - g, 1 - b, a
end

---@param hex string hex color
---@return string hexColor inverted color
function AF.InvertColorHex(hex)
    local r, g, b, a = AF.ConvertHEXToRGB(hex)
    local invR, invG, invB = AF.InvertColor(r, g, b)
    return AF.ConvertRGBToHEX(invR, invG, invB, a)
end

---@param r number [0, 1]
---@param g number [0, 1]
---@param b number [0, 1]
---@param a? number [0, 1]
---@return number r [0, 1]
---@return number g [0, 1]
---@return number b [0, 1]
---@return number? a [0, 1]
function AF.GetComplementColor(r, g, b, a)
    local h, s, v = AF.ConvertRGBToHSB(r, g, b)
    h = (h + 180) % 360
    local cr, cg, cb = AF.ConvertHSBToRGB(h, s, v)
    return cr, cg, cb, a
end

---@param hex string
---@return string hexColor
function AF.GetComplementColorHex(hex)
    local r, g, b, a = AF.ConvertHEXToRGB(hex)
    local cr, cg, cb, ca = AF.GetComplementColor(r, g, b, a)
    return AF.ConvertRGBToHEX(cr, cg, cb, ca)
end

---@param r number [0, 1]
---@param g number [0, 1]
---@param b number [0, 1]
---@param saturation number [0, 1]
---@param brightness number [0, 1]
---@return number r [0, 1]
---@return number g [0, 1]
---@return number b [0, 1]
function AF.AdjustColorSaturationBrightness(r, g, b, saturation, brightness)
    local _h, _s, _b = AF.ConvertRGBToHSB(r, g, b)
    _s = AF.Clamp(_s * saturation, 0, 1)
    _b = AF.Clamp(_b * brightness, 0, 1)
    return AF.ConvertHSBToRGB(_h, _s, _b)
end

function AF.ConvertToGrayscale(r, g, b, a)
    local v = 0.299 * r + 0.587 * g + 0.114 * b
    return v, v, v, a
end