---@class AbstractFramework
local AF = _G.AbstractFramework

local tonumber = tonumber
local format, gsub, strlower, strupper, strsplit, strtrim = string.format, string.gsub, string.lower, string.upper, string.split, string.trim
local tinsert, tconcat = table.insert, table.concat

---------------------------------------------------------------------
-- string
---------------------------------------------------------------------
function AF.UpperFirst(str, lowerOthers)
    if AF.IsBlank(str) then return str end

    if lowerOthers then
        str = strlower(str)
    end
    return (str:gsub("^%l", strupper))
end

local function CapitalizeWord(space, firstChar, rest)
    return space .. strupper(firstChar) .. rest
end

function AF.UpperEachWord(str, lowerOthers)
    if AF.IsBlank(str) then return str end

    if lowerOthers then
        str = strlower(str)
    end

    -- %s matches whitespace
    -- %w matches alphanumeric chars
    -- %w* matches zero or more alphanumeric chars
    return (str:gsub("(%s?)(%w)(%w*)", CapitalizeWord))
end

function AF.SplitString(sep, str)
    if not str then return end

    local ret = {strsplit(sep, str)}
    for i, v in ipairs(ret) do
        ret[i] = tonumber(v) or ret[i] -- keep non number
    end
    return unpack(ret)
end

function AF.StringToTable(str, sep, convertToNum)
    local t = {}
    if str == "" then return t end
    assert(sep, "separator is nil")

    if convertToNum then
        for i, v in pairs({string.split(sep, str)}) do
            v = strtrim(v)
            tinsert(t, tonumber(v) or v)
        end
    else
        for i, v in pairs({string.split(sep, str)}) do
            tinsert(t, strtrim(v))
        end
    end
    return t
end

---@param t table
---@param sep string
---@param useKey boolean
---@param useValue boolean
function AF.TableToString(t, sep, useKey, useValue)
    if useKey or useValue then
        local str = ""
        for k, v in pairs(t) do
            if useKey and useValue then
                str = str .. k .. "=" .. v .. sep
            elseif useKey then
                str = str .. k .. sep
            elseif useValue then
                str = str .. v .. sep
            end
        end
        return str:sub(1, -2)
    else
        return tconcat(t, sep)
    end
end

function AF.IsBlank(str)
    if type(str) ~= "string" then
        return true
    end
    return str == "" or strtrim(str) == ""
end

---------------------------------------------------------------------
-- number format
---------------------------------------------------------------------
local symbol_1K, symbol_10K, symbol_1B = "", "", ""
if LOCALE_zhCN then
    symbol_1K, symbol_10K, symbol_1B = "千", "万", "亿"
elseif LOCALE_zhTW then
    symbol_1K, symbol_10K, symbol_1B = "千", "萬", "億"
elseif LOCALE_koKR then
    symbol_1K, symbol_10K, symbol_1B = "천", "만", "억"
end

function AF.FormatNumber_Asian(n)
    if abs(n) >= 100000000 then
        return AF.RoundToDecimal(n / 100000000, 2) .. symbol_1B
    elseif abs(n) >= 10000 then
        return AF.RoundToDecimal(n / 10000, 1) .. symbol_10K
    else
        return n
    end
end

function AF.FormatNumber(n)
    if abs(n) >= 1000000000 then
        return AF.RoundToDecimal(n / 1000000000, 2) .. "B"
    elseif abs(n) >= 1000000 then
        return AF.RoundToDecimal(n / 1000000, 2) .. "M"
    elseif abs(n) >= 1000 then
        return AF.RoundToDecimal(n / 1000, 1) .. "K"
    else
        return n
    end
end

---------------------------------------------------------------------
-- money format
---------------------------------------------------------------------
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GOLD_SYMBOL, SILVER_SYMBOL, COPPER_SYMBOL
local GOLD_ICON, SILVER_ICON, COPPER_ICON

---@param style string? "icon"|"symbol"|"nosuffix", default is "icon".
---@param goldOnly boolean?
function AF.FormatMoney(copper, style, useCommas, goldOnly)
    local gold = floor(copper / 10000)
    local silver = floor(copper / 100 - gold * 100)
    local copper = copper - gold * 10000 - silver * 100

    if useCommas then
        gold = BreakUpLargeNumbers(gold)
    end

    if style == "symbol" then
        if not GOLD_SYMBOL then
            GOLD_SYMBOL = AF.WrapTextInColor(_G.GOLD_AMOUNT_SYMBOL, "coin_gold")
            SILVER_SYMBOL = AF.WrapTextInColor(_G.SILVER_AMOUNT_SYMBOL, "coin_silver")
            COPPER_SYMBOL = AF.WrapTextInColor(_G.COPPER_AMOUNT_SYMBOL, "coin_copper")
        end

        if goldOnly then
            return format("%s%s", gold, GOLD_SYMBOL)
        else
            return format("%s%s %d%s %d%s", gold, GOLD_SYMBOL, silver, SILVER_SYMBOL, copper, COPPER_SYMBOL)
        end

    elseif style == "nosuffix" then
        if goldOnly then
            return AF.WrapTextInColor(gold, "coin_gold")
        else
            return format("%s %s %s", AF.WrapTextInColor(gold, "coin_gold"), AF.WrapTextInColor(silver, "coin_silver"), AF.WrapTextInColor(copper, "coin_copper"))
        end

    else
        if not GOLD_ICON then
            GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0|t"
            SILVER_ICON = "|TInterface\\MoneyFrame\\UI-SilverIcon:0|t"
            COPPER_ICON = "|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
        end

        if goldOnly then
            return format("%s%s", gold, GOLD_ICON)
        else
            return format("%s%s %d%s %d%s", gold, GOLD_ICON, silver, SILVER_ICON, copper, COPPER_ICON)
        end
    end
end