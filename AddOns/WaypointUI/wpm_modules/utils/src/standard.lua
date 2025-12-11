local env            = select(2, ...)

local pairs          = pairs

local Utils_Standard = env.WPM:New("wpm_modules/utils/standard")


-- Shared
--------------------------------

local idCounter = 0


-- API
--------------------------------

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

function Utils_Standard.GenerateRandomID()
    idCounter = idCounter + 1
    return idCounter
end
