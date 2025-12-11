local env          = select(2, ...)

local pairs        = pairs
local tostring     = tostring
local tonumber     = tonumber
local table_sort   = table.sort
local string_lower = string.lower
local string_find  = string.find

local Utils_Sort   = env.WPM:New("wpm_modules/utils/sort")


-- Shared
--------------------------------

local decoratedPool = {}


-- Helpers
--------------------------------

local function resolveNestedPath(source, pathKeys, pathLength)
    if pathLength == 0 then return source end

    local current = source
    for i = 1, pathLength do
        if current == nil then return nil end
        current = current[pathKeys[i]]
    end
    return current
end

local function containsString(haystack, needle)
    if Utils_Sort.FindString then
        return Utils_Sort.FindString(haystack, needle)
    end
    return string_find(haystack, needle, 1, true) ~= nil
end

local function compareNumberDescending(valueA, valueB)
    if valueA == nil and valueB == nil then return false end
    if valueA == nil then return false end
    if valueB == nil then return true end
    local numA, numB = tonumber(valueA) or valueA, tonumber(valueB) or valueB
    return numA < numB
end

local function compareNumberAscending(valueA, valueB)
    if valueA == nil and valueB == nil then return false end
    if valueA == nil then return false end
    if valueB == nil then return true end
    local numA, numB = tonumber(valueA) or valueA, tonumber(valueB) or valueB
    return numA > numB
end

local function compareAlphaDescending(valueA, valueB)
    valueA = (valueA == nil) and "" or tostring(valueA)
    valueB = (valueB == nil) and "" or tostring(valueB)
    return string_lower(valueA) > string_lower(valueB)
end

local function compareAlphaAscending(valueA, valueB)
    valueA = (valueA == nil) and "" or tostring(valueA)
    valueB = (valueB == nil) and "" or tostring(valueB)
    return string_lower(valueA) < string_lower(valueB)
end

local function decorateSortAndUnwrap(list, pathKeys, comparator)
    if list == nil then return list end

    local listLength = #list
    if listLength <= 1 then return list end

    local pathLength = (pathKeys and #pathKeys) or 0
    local decorated = decoratedPool

    for i = 1, listLength do
        local entry = decorated[i]
        local value = list[i]
        local sortKey = resolveNestedPath(value, pathKeys, pathLength)
        if entry then
            entry.key = sortKey
            entry.val = value
        else
            decorated[i] = { key = sortKey, val = value }
        end
    end

    for i = listLength + 1, #decorated do
        decorated[i] = nil
    end

    table_sort(decorated, function(a, b)
        return comparator(a.key, b.key)
    end)

    for i = 1, listLength do
        list[i] = decorated[i].val
    end

    return list
end


-- API
--------------------------------

function Utils_Sort.FindKeyPositionInTable(tbl, targetKey)
    if tbl == nil then return nil end

    local position = 0
    for key in pairs(tbl) do
        position = position + 1
        if key == targetKey then return position end
    end
    return nil
end

function Utils_Sort.FindValuePositionInTable(tbl, targetValue)
    if tbl == nil then return nil end

    local position = 0
    for _, value in pairs(tbl) do
        position = position + 1
        if value == targetValue then return position end
    end
    return nil
end

function Utils_Sort.GetSubVariableFromList(list, pathKeys)
    local pathLength = (pathKeys and #pathKeys) or 0
    return resolveNestedPath(list, pathKeys, pathLength)
end

function Utils_Sort.FindVariableValuePositionInTable(tbl, pathKeys, targetValue)
    if tbl == nil then return nil end

    local pathLength = (pathKeys and #pathKeys) or 0
    for i = 1, #tbl do
        local resolved = resolveNestedPath(tbl[i], pathKeys, pathLength)
        if resolved == targetValue then return i end
    end
    return nil
end

function Utils_Sort.SortListByNumber(list, pathKeys, ascending)
    local comparator = ascending and compareNumberAscending or compareNumberDescending
    return decorateSortAndUnwrap(list, pathKeys, comparator)
end

function Utils_Sort.SortListByAlphabeticalOrder(list, pathKeys, descending)
    local comparator = descending and compareAlphaDescending or compareAlphaAscending
    return decorateSortAndUnwrap(list, pathKeys, comparator)
end

function Utils_Sort.FilterListByVariable(list, pathKeys, filterValue, roughMatch, caseSensitive, customCheck)
    if not list then return {} end

    local results = {}
    local resultCount = 0
    local isCaseSensitive = (caseSensitive == nil) and true or caseSensitive
    local isRoughMatch = not not roughMatch
    local pathLength = (pathKeys and #pathKeys) or 0

    local needle = filterValue
    if not isCaseSensitive and filterValue ~= nil then
        needle = string_lower(tostring(filterValue))
    end
    local needleString = tostring(needle)

    for i = 1, #list do
        local entry = list[i]

        if customCheck then
            if customCheck(entry) then
                resultCount = resultCount + 1
                results[resultCount] = entry
            end
        else
            local resolved = resolveNestedPath(entry, pathKeys, pathLength)
            if resolved ~= nil then
                if isRoughMatch then
                    local haystack = tostring(resolved)
                    if not isCaseSensitive then haystack = string_lower(haystack) end
                    if containsString(haystack, needleString) then
                        resultCount = resultCount + 1
                        results[resultCount] = entry
                    end
                elseif isCaseSensitive then
                    if resolved == needle then
                        resultCount = resultCount + 1
                        results[resultCount] = entry
                    end
                else
                    if string_lower(tostring(resolved)) == needleString then
                        resultCount = resultCount + 1
                        results[resultCount] = entry
                    end
                end
            end
        end
    end

    return results
end
