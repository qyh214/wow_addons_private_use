local env              = select(2, ...)

local math_floor       = math.floor

local Utils_Formatting = env.WPM:New("wpm_modules/utils/formatting")


-- API
--------------------------------

function Utils_Formatting.FormatMoney(copperTotal)
    local gold   = math_floor(copperTotal / 10000)
    local silver = math_floor((copperTotal % 10000) / 100)
    local copper = copperTotal % 100
    return gold, silver, copper
end

function Utils_Formatting.FormatTime(seconds)
    local hours   = math_floor(seconds / 3600)
    local minutes = math_floor((seconds % 3600) / 60)
    local secs    = seconds % 60

    local strHours   = hours > 0 and hours .. "h " or ""
    local strMinutes = minutes > 0 and minutes .. "m " or ""
    local strSeconds = secs > 0 and secs .. "s" or ""

    return hours, minutes, secs, strHours, strMinutes, strSeconds
end
