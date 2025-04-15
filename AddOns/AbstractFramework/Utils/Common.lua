---@class AbstractFramework
local AF = _G.AbstractFramework
local L = AF.L

local select, type, tonumber = select, type, tonumber
local floor, ceil, abs, max, min, abs = math.floor, math.ceil, math.abs, math.max, math.min, math.abs
local format, gsub, strlower, strupper, strsplit, strtrim = string.format, string.gsub, string.lower, string.upper, string.split, string.trim
local next, pairs, ipairs = next, pairs, ipairs
local tinsert, tremove, tsort, tconcat = table.insert, table.remove, table.sort, table.concat
local date, time = date, time

---------------------------------------------------------------------
-- misc
---------------------------------------------------------------------
function AF.Unpack2(t)
    return t[1], t[2]
end

function AF.Unpack3(t)
    return t[1], t[2], t[3]
end

function AF.Unpack4(t)
    return t[1], t[2], t[3], t[4]
end

function AF.Unpack5(t)
    return t[1], t[2], t[3], t[4], t[5]
end

function AF.Unpack6(t)
    return t[1], t[2], t[3], t[4], t[5], t[6]
end

function AF.Unpack7(t)
    return t[1], t[2], t[3], t[4], t[5], t[6], t[7]
end

function AF.Unpack8(t)
    return t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8]
end

---------------------------------------------------------------------
-- number
---------------------------------------------------------------------
AF.epsilon = 0.00001

function AF.ApproxEqual(a, b, epsilon)
    return abs(a - b) <= (epsilon or AF.epsilon)
end

function AF.ApproxZero(n)
    return AF.ApproxEqual(n, 0)
end

function AF.Round(num)
    if num < 0.0 then
        return ceil(num - 0.5)
    end
    return floor(num + 0.5)
end

function AF.RoundToDecimal(num, numDecimalPlaces)
    local mult = 10 ^ numDecimalPlaces
    num = num * mult
    if num < 0.0 then
        return ceil(num - 0.5) / mult
    end
    return floor(num + 0.5) / mult
end

function AF.RoundToNearestMultiple(num, multiplier)
    return AF.Round(num / multiplier) * multiplier
end

function AF.Interpolate(start, stop, step, maxSteps)
    return start + (stop - start) * step / maxSteps
end

function AF.Clamp(value, minValue, maxValue)
    maxValue = max(minValue, maxValue) -- to ensure maxValue >= minValue
    if value > maxValue then
        return maxValue
    elseif value < minValue then
        return minValue
    end
    return value
end

function AF.PercentageBetween(value, startValue, endValue)
    if startValue == endValue then
        return 0.0
    end
    return (value - startValue) / (endValue - startValue)
end

function AF.ClampedPercentageBetween(value, startValue, endValue)
    return AF.Clamp(AF.PercentageBetween(value, startValue, endValue), 0.0, 1.0)
end

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
-- string
---------------------------------------------------------------------
function AF.UpperFirst(str, lowerOthers)
    if lowerOthers then
        str = strlower(str)
    end
    return (str:gsub("^%l", strupper))
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
-- table
---------------------------------------------------------------------

---@param t table
---@return number
function AF.Getn(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function AF.GetIndex(t, e)
    for i, v in pairs(t) do
        if e == v then
            return i
        end
    end
    return nil
end

function AF.GetKeys(t)
    local keys = {}
    for k in pairs(t) do
        tinsert(keys, k)
    end
    return keys
end

---@param ... table
---@return table newTbl
function AF.Copy(...)
    local newTbl = {}
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        for k, v in pairs(t) do
            if type(v) == "table" then
                newTbl[k] = AF.Copy(v)
            else
                newTbl[k] = v
            end
        end
    end
    return newTbl
end

function AF.Contains(t, v)
    for _, value in pairs(t) do
        if value == v then return true end
    end
    return false
end

-- insert into the first empty slot
function AF.Insert(t, v)
    local i, done = 1
    repeat
        if not t[i] then
            t[i] = v
            done = true
        end
        i = i + 1
    until done
end

function AF.Remove(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            tremove(t, i)
        end
    end
end

-- merge into the first table
---@param t table
---@param ... table
function AF.Merge(t, ...)
    for i = 1, select("#", ...) do
        local _t = select(i, ...)
        for k, v in pairs(_t) do
            if type(v) == "table" then
                t[k] = AF.Copy(v)
            else
                t[k] = v
            end
        end
    end
end

function AF.IsEmpty(t)
    if not t or type(t) ~= "table" then
        return true
    end

    if next(t) then
        return false
    end
    return true
end

function AF.RemoveElementsExceptKeys(tbl, ...)
    local keys = {}

    for i = 1, select("#", ...) do
        local k = select(i, ...)
        keys[k] = true
    end

    for k in pairs(tbl) do
        if not keys[k] then
            tbl[k] = nil
        end
    end
end

function AF.RemoveElementsByKeys(tbl, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        tbl[k] = nil
    end
end

-- transposes a table, swapping its keys and values
---@param t table the table to transpose
---@param value? any the value to assign to the transposed keys
---@return table
function AF.TransposeTable(t, value)
    local temp = {}
    for k, v in ipairs(t) do
        temp[v] = value or k
    end
    return temp
end

-- converts a table using a processor function
---@param t table the table to convert
---@param processor function the processor function to use, returns newKey, newValue
function AF.ConvertTable(t, processor)
    local temp = {}
    for k, v in ipairs(t) do
        local newKey, newValue = processor(k, v)
        temp[newKey] = newValue
    end
    return temp
end

-- transposes the given spell table.
---@param t table
---@param convertIdToName boolean?
---@return table
function AF.TransposeSpellTable(t, convertIdToName)
    if not convertIdToName then
        return AF.TransposeTable(t)
    end

    local temp = {}
    for k, v in ipairs(t) do
        local name = AF.GetSpellInfo(v)
        if name then
            temp[name] = k
        end
    end
    return temp
end

---------------------------------------------------------------------
-- table sort
---------------------------------------------------------------------
local function CompareField(a, b, key, order)
    if a[key] ~= b[key] then
        if order == "ascending" then
            return a[key] < b[key]
        else  -- "descending"
            return a[key] > b[key]
        end
    end
    return nil
end

local function SortComparator(criteria)
    return function(a, b)
        for _, criterion in ipairs(criteria) do
            local result = CompareField(a, b, criterion.key, criterion.order)
            if result ~= nil then
                return result
            end
        end
        return false
    end
end

-- order: "ascending" or "descending"
---@param t table
---@param ...: key1, order1, key2, order2, ...
function AF.Sort(t, ...)
    local criteria = {}
    for i = 1, select("#", ...), 2 do
        local key = select(i, ...)
        local order = select(i + 1, ...)
        if key and order then
            tinsert(criteria, {key = key, order = order})
        end
    end
    tsort(t, SortComparator(criteria))
end

---------------------------------------------------------------------
-- time
---------------------------------------------------------------------
-- https://strftime.net
-- https://warcraft.wiki.gg/wiki/API_date
function AF.FormatTime(sec, format)
    format = format or "%Y/%m/%d %H:%M:%S"
    -- date() is equivalent to date("%c")
    return date("%Y/%m/%d %H:%M:%S", sec)
end

local SEC = gsub(_G.SPELL_DURATION_SEC, "%%%.%df", "%%s")
local MIN = gsub(_G.SPELL_DURATION_MIN, "%%%.%df", "%%s")

function AF.GetLocalizedSeconds(sec)
    if sec > 60 then
        return format(MIN, AF.Round(sec / 60, 1))
    else
        return format(SEC, AF.Round(sec, 1))
    end
end

function AF.FormatRelativeTime(sec)
    sec = time() - sec

    local suffix = sec < 0 and L["%s from now"] or L["%s ago"]
    sec = abs(sec)

    if sec == 0 then
        sec = L["just now"]
    elseif sec < 60 then
        sec = suffix:format(L["%d seconds"]:format(sec))
    elseif sec < 3600 then
        sec = suffix:format(L["%d minutes"]:format(sec / 60))
    elseif sec < 86400 then
        sec = suffix:format(L["%d hours"]:format(sec / 3600))
    elseif sec < 604800 then
        sec = suffix:format(L["%d days"]:format(sec / 86400))
    elseif sec < 2419200 then
        sec = suffix:format(L["%d weeks"]:format(sec / 604800))
    elseif sec < 29030400 then
        sec = suffix:format(L["%d months"]:format(sec / 2419200))
    else
        sec = suffix:format(L["%d years"]:format(sec / 29030400))
    end
    return sec
end

---------------------------------------------------------------------
-- compress and serialize
---------------------------------------------------------------------
local LibDeflate = AF.Libs.LibDeflate
local deflateConfig = {level = 9}
local LibSerialize = AF.Libs.LibSerialize

function AF.Serialize(data)
    local serialized = LibSerialize:Serialize(data) -- serialize
    local compressed = LibDeflate:CompressDeflate(serialized, deflateConfig) -- compress
    return LibDeflate:EncodeForPrint(compressed) -- encode
end

function AF.Deserialize(encoded)
    local decoded = LibDeflate:DecodeForPrint(encoded) -- decode
    local decompressed = LibDeflate:DecompressDeflate(decoded) -- decompress
    if not decompressed then
        AF.Debug("Error decompressing")
        return
    end
    local success, data = LibSerialize:Deserialize(decompressed) -- deserialize
    if not success then
        AF.Debug("Error deserializing")
        return
    end
    return data
end

---------------------------------------------------------------------
-- delayed invoke
---------------------------------------------------------------------
local delayed = {}

function AF.DelayedInvoke(delay, func, ...)
    assert(type(delay) == "number", "delay must be a number")
    assert(type(func) == "function", "func must be a function")

    -- cancel existing timer
    if delayed[func] then
        delayed[func]:Cancel()
        delayed[func] = nil
    end

    -- save arguments directly to local variables to reduce closure overhead
    local a1, a2, a3, a4, a5, a6, a7, a8 = ...
    local numArgs = select("#", ...)
    local args
    if numArgs > 8 then
        args = {...}
    end

    delayed[func] = C_Timer.NewTimer(delay, function()
        delayed[func] = nil
        -- call function based on number of arguments, avoid creating temporary tables
        if numArgs == 0 then
            func()
        elseif numArgs == 1 then
            func(a1)
        elseif numArgs == 2 then
            func(a1, a2)
        elseif numArgs == 3 then
            func(a1, a2, a3)
        elseif numArgs == 4 then
            func(a1, a2, a3, a4)
        elseif numArgs == 5 then
            func(a1, a2, a3, a4, a5)
        elseif numArgs == 6 then
            func(a1, a2, a3, a4, a5, a6)
        elseif numArgs == 7 then
            func(a1, a2, a3, a4, a5, a6, a7)
        elseif numArgs == 8 then
            func(a1, a2, a3, a4, a5, a6, a7, a8)
        else
            func(unpack(args, 1, numArgs))
        end
    end)
end

function AF.GetDelayedInvoker(delay, func)
    assert(type(delay) == "number", "delay must be a number")
    assert(type(func) == "function", "func must be a function")

    return function(...)
        AF.DelayedInvoke(delay, func, ...)
    end
end