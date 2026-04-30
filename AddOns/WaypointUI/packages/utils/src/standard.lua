local env = select(2, ...)
local Utils_Standard = env.modules:New("packages\\utils\\standard")

local pairs = pairs

function Utils_Standard.GetTableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function Utils_Standard.ReverseTable(tbl)
    local reversed = {}
    local length = #tbl
    for i = length, 1, -1 do
        reversed[length - i + 1] = tbl[i]
    end
    return reversed
end

local nextUniqueID = 0

function Utils_Standard.GetUniqueID()
    nextUniqueID = nextUniqueID + 1
    return nextUniqueID
end
