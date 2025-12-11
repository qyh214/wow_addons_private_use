---@class AbstractFramework
local AF = _G.AbstractFramework
local L = AF.L

local format = string.format
local date, time = date, time

-- _G.CALENDAR_WEEKDAY_NAMES
local weekdays = {
    _G.WEEKDAY_SUNDAY, _G.WEEKDAY_MONDAY, _G.WEEKDAY_TUESDAY, _G.WEEKDAY_WEDNESDAY, _G.WEEKDAY_THURSDAY, _G.WEEKDAY_FRIDAY, _G.WEEKDAY_SATURDAY
}

-- _G.CALENDAR_FULLDATE_MONTH_NAMES
local months = {
    _G.MONTH_JANUARY, _G.MONTH_FEBRUARY, _G.MONTH_MARCH, _G.MONTH_APRIL, _G.MONTH_MAY, _G.MONTH_JUNE,
    _G.MONTH_JULY, _G.MONTH_AUGUST, _G.MONTH_SEPTEMBER, _G.MONTH_OCTOBER, _G.MONTH_NOVEMBER, _G.MONTH_DECEMBER
}

---------------------------------------------------------------------
-- date & time
---------------------------------------------------------------------

-- https://strftime.net
-- https://warcraft.wiki.gg/wiki/API_date
---@param sec number?
---@param format string? default: "%Y/%m/%d %H:%M:%S"
function AF.FormatTime(sec, format)
    format = format or "%Y/%m/%d %H:%M:%S"
    -- date() is equivalent to date("%c")
    return date(format, sec)
end

---@param sec number?
---@return string YYYYMMDD
function AF.GetDateString(sec)
    return date("%Y%m%d", sec)
end

---@param dateStr string YYYYMMDD
---@return number? seconds
function AF.GetDateSeconds(dateStr)
    if type(dateStr) ~= "string" then return end

    local year, month, day = dateStr:match("(%d%d%d%d)(%d%d)(%d%d)")
    if not (year and month and day) then return end
    return time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
end

---@param sec number?
---@return table dateTable date("*t") with localized weekdayName and monthName
function AF.GetDateTable(sec)
    local t = date("*t", sec)
    t.weekdayName = weekdays[t.wday]
    t.monthName = months[t.month]
    return t
end

---@param asRemaining boolean if true, return seconds remaining until next day 00:00:00, else return the timestamp of next day 00:00:00
---@return number seconds
function AF.GetNextDaySeconds(asRemaining)
    local now = time()

    local tomorrow = date("*t", now)
    tomorrow.day = tomorrow.day + 1
    tomorrow.hour = 0
    tomorrow.min = 0
    tomorrow.sec = 0

    if asRemaining then
        return time(tomorrow) - now
    else
        return time(tomorrow)
    end
end

---@param sec number
---@param useServerTime boolean
---@return boolean
function AF.IsToday(sec, useServerTime)
    if type(sec) ~= "number" then
        return false
    end
    local today = date("%Y%m%d", useServerTime and time() or GetServerTime())
    local dateStr = date("%Y%m%d", sec)
    return today == dateStr
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