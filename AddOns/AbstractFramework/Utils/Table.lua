---@class AbstractFramework
local AF = _G.AbstractFramework

local select, type, tonumber = select, type, tonumber
local next, pairs, ipairs = next, pairs, ipairs
local tinsert, tremove, tsort, tconcat = table.insert, table.remove, table.sort, table.concat

---------------------------------------------------------------------
-- table
---------------------------------------------------------------------

---@param t table
---@return number
function AF.Getn(t)
    local count = 0
    for k, v in next, t do
        count = count + 1
    end
    return count
end

function AF.GetIndex(t, e)
    for i, v in next, t do
        if e == v then
            return i
        end
    end
    return nil
end

function AF.GetKeys(t)
    local keys = {}
    for k in next, t do
        tinsert(keys, k)
    end
    return keys
end

---@param t table
---@return number? maxKey
---@return any? maxValue value of maxKey
function AF.GetMaxKeyValue(t)
    local maxKey = nil
    for k in next, t do
        local kn = tonumber(k)
        if not maxKey or (kn and kn > tonumber(maxKey)) then
            maxKey = k
        end
    end

    if maxKey then
        return maxKey, t[maxKey]
    end
end

---@param ... table
---@return table newTbl
function AF.Copy(...)
    local newTbl = {}
    for i = 1, select("#", ...) do
        local t = select(i, ...)
        for k, v in next, t do
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
    for _, value in next, t do
        if value == v then return true end
    end
    return false
end

function AF.IndexOf(t, v)
    for i, value in next, t do
        if value == v then return i end
    end
    return nil
end

function AF.LastIndexOf(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then return i end
    end
    return nil
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

-- remove all occurrences of a value from a table
---@param t table
---@param v any the value to remove
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
        for k, v in next, _t do
            if type(v) == "table" then
                t[k] = AF.Copy(v)
            else
                t[k] = v
            end
        end
    end
end

-- merge into the first table, but only if the key already exists
---@param t table
---@param ... table
function AF.MergeExistingKeys(t, ...)
    for i = 1, select("#", ...) do
        local _t = select(i, ...)
        for k, v in next, _t do
            if type(t[k]) ~= "nil" then
                if type(v) == "table" then
                    t[k] = AF.Copy(v)
                else
                    t[k] = v
                end
            end
        end
    end
end

-- for plain tables only
---@param t table
---@param ... table
function AF.InsertAll(t, ...)
    for i = 1, select("#", ...) do
        local _t = select(i, ...)
        for _, v in next, _t do
            tinsert(t, v)
        end
    end
end

-- for plain tables only
---@param t table
---@param ... any simple values or tables
function AF.InsertIfNotExists(t, ...)
    local exists = AF.TransposeTable(t, true)

    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "table" then
            for _, vv in ipairs(v) do
                if not exists[vv] then
                    tinsert(t, vv)
                    exists[vv] = true
                end
            end
        else
            if not exists[v] then
                tinsert(t, v)
                exists[v] = true
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

    for k in next, tbl do
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

function AF.MoveElementToEnd(t, index)
    if not index or index < 1 or index > #t then
        return
    end

    local element = tremove(t, index)
    tinsert(t, element)
end

function AF.MoveElementToIndex(t, fromIndex, toIndex)
    if not fromIndex or not toIndex or fromIndex < 1 or fromIndex > #t or toIndex < 1 or toIndex > #t then
        return
    end

    local element = tremove(t, fromIndex)
    tinsert(t, toIndex, element)
end

-- transposes a table, swapping its keys and values
---@param t table the table to transpose
---@param value? any the value to assign to the transposed keys
---@return table
function AF.TransposeTable(t, value)
    local temp = {}
    for k, v in next, t do
        temp[v] = value or k
    end
    return temp
end

---@param t table
---@return table temp a new table with the keys and values swapped
function AF.SwapKeyValue(t)
    local temp = {}
    for k, v in next, t do
        temp[v] = k
    end
    return temp
end

-- converts a table using a processor function
---@param t table the table to convert
---@param processor fun(key: any, value: any): (any, any) the processor function that takes a key and value and returns a new key and value
function AF.ConvertTable(t, processor)
    local temp = {}
    local newKey, newValue
    for k, v in next, t do
        newKey, newValue = processor(k, v)
        if newKey and newValue then
            temp[newKey] = newValue
        end
    end
    return temp
end

---@param t table
---@param key any the key to look for in the sub-tables
---@return table temp a new table containing the values of the specified key from each sub-table
function AF.ExtractSubTableValues(t, key)
    local temp = {}
    for k, v in next, t do
        if type(v) == "table" and v[key] then
            tinsert(temp, v[key])
        end
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
        for _, criterion in next, criteria do
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
-- unpacker
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