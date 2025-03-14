---@class GUTIL-2.0
local GUTIL = LibStub:NewLibrary("GUTIL-2.0", 18)
if not GUTIL then return end

--- CLASSICS insert
local Object = {}
Object.__index = Object

GUTIL.Object = Object

function Object:new()
end

function Object:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Object:implement(...)
    for _, cls in pairs({ ... }) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function Object:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__tostring()
    return "Object"
end

function Object:__call(...)
    local obj = setmetatable({}, self)
    obj:new(...)
    return obj
end

--- CLASSICS END

if not GUTIL then return end

---Returns an item string from an item link if found
---@param itemLink string
---@return string? itemString
function GUTIL:GetItemStringFromLink(itemLink)
    return select(3, strfind(itemLink, "|H(.+)|h%["))
end

---Returns the quality of the item based on an item link if the item has a quality
---@param itemLink string
---@return number? qualityID
function GUTIL:GetQualityIDFromLink(itemLink)
    local qualityID = string.match(itemLink, "Quality%-Tier(%d+)")
    return tonumber(qualityID)
end

function GUTIL:StringStartsWith(mainString, prefix)
    return string.sub(mainString, 1, #prefix) == prefix
end

function GUTIL:GetItemTooltipText(itemLink)
    local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)

    if not tooltipData then
        return ""
    end

    local tooltipText = ""
    for _, line in pairs(tooltipData.lines) do
        local lineText = ""
        for _, arg in pairs(line.args) do
            if arg.stringVal then
                lineText = lineText .. arg.stringVal
            end
        end
        tooltipText = tooltipText .. lineText .. "\n"
    end

    return tooltipText
end

---Finds the first element in the table where findFunc(element) returns true
---@generic K
---@generic V
---@param t table<K, V>
---@param findFunc fun(value: V): boolean
---@return V? element
---@return K? key
function GUTIL:Find(t, findFunc)
    for k, v in pairs(t) do
        if findFunc(v) then
            return v, k
        end
    end

    return nil
end

--- to concat lists together (behaviour unpredictable with tables that have strings or not ordered numbers as indices)
---@generic V
---@param tableList V[]
---@return V
function GUTIL:Concat(tableList)
    local finalList = {}
    for _, currentTable in pairs(tableList) do
        for _, item in pairs(currentTable) do
            table.insert(finalList, item)
        end
    end
    return finalList
end

---makes a table unique
---@generic V
---@param t V[]
---@param compareFunc? fun(element: V): any return a value with that the elements should be compared with in uniqueness
---@return V[]
function GUTIL:ToSet(t, compareFunc)
    local set = {}
    local containedMap = {} -- to speed things up

    if not compareFunc then
        for _, element in pairs(t) do
            if not containedMap[element] then
                table.insert(set, element)
                containedMap[element] = true
            end
        end
    else
        for _, element in pairs(t) do
            local uniqueValue = compareFunc(element)
            if not containedMap[uniqueValue] then
                table.insert(set, element)
                containedMap[uniqueValue] = true
            end
        end
    end

    return set
end

---@class GUTIL.MapOptions
---@field subTable boolean a subproperty that is a table that is to be mapped instead of the table itself
---@field isTableList boolean if the table only consists of other tables, map each subTable instead

--- maps a table to another table by calling mapFunc for each element. If the mapFunc returns nil the element will be skipped
---@generic K
---@generic V
---@generic R
---@param t table<K, V>
---@param mapFunc fun(value:V, key:K): R
---@param options GUTIL.MapOptions?
---@return R[]
function GUTIL:Map(t, mapFunc, options)
    options = options or {}
    local mapped = {}
    if not options.subTable then
        for k, v in pairs(t) do
            if options.isTableList then
                if type(v) ~= "table" then
                    error("GUTIL.Map: t contains a nontable element")
                end
                for subK, subV in pairs(v) do
                    local mappedValue = mapFunc(subV, subK)
                    if not mappedValue then
                        error("GUTIL.Map: Did you forget to return in mapFunc?")
                    end
                    table.insert(mapped, mappedValue)
                end
            else
                local mappedValue = mapFunc(v, k)
                if mappedValue then
                    table.insert(mapped, mappedValue)
                end
            end
        end
        return mapped
    else
        for k, v in pairs(t) do
            if not v[options.subTable] or type(v[options.subTable]) ~= "table" then
                print("GUTIL.Map: given options.subTable is not existing or no table: " .. tostring(v[options.subTable]))
            else
                for subK, subV in pairs(v[options.subTable]) do
                    local mappedValue = mapFunc(subV, subK)
                    if not mappedValue then
                        error("GUTIL.Map: Did you forget to return in mapFunc?")
                    end
                    table.insert(mapped, mappedValue)
                end
            end
        end
        return mapped
    end
end

---@generic V
---@param t V[]
---@param filterFunc fun(value: V): boolean
---@return V[]
function GUTIL:Filter(t, filterFunc)
    local filtered = {}
    for k, v in pairs(t) do
        if filterFunc(v) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

function GUTIL:CreateRegistreeForEvents(events)
    local registree = CreateFrame("Frame", nil)
    registree:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
    for _, event in pairs(events) do
        registree:RegisterEvent(event)
    end
    return registree
end

---Validate if a string is of format 100g50s10c
---@param moneyString string
---@return boolean valid
function GUTIL:ValidateMoneyString(moneyString)
    -- check if the string matches the pattern
    if not string.match(moneyString, "^%d*g?%d*s?%d*c?$") then
        return false
    end

    -- check if the string contains at least one of g, s, or c
    if not string.match(moneyString, "[gsc]") then
        return false
    end

    -- check if the string contains multiple g, s, or c
    if string.match(moneyString, "g.*g") then
        return false
    end
    if string.match(moneyString, "s.*s") then
        return false
    end
    if string.match(moneyString, "c.*c") then
        return false
    end

    -- check if it ends incorrectly
    if string.match(moneyString, "%d$") then
        return false
    end

    -- check if the string contains invalid characters
    if string.match(moneyString, "[^%dgsc]") then
        return false
    end

    -- all checks passed, the string is valid
    return true
end

---Returns the given copper value as gold, silver and copper seperated, as string formated or as numbers
---@param copperValue number
---@param formatString? boolean
---@return string | number
---@return number?
---@return number?
function GUTIL:GetMoneyValuesFromCopper(copperValue, formatString)
    local gold = math.floor(copperValue / 1e4)
    local silver = math.floor(copperValue / 100 % 100)
    local copper = math.floor(copperValue % 100)

    if not formatString then
        return gold, silver, copper
    else
        return gold .. "g " .. silver .. "s " .. copper .. "c"
    end
end

--- Singleton
---@type GUTIL.Formatter
GUTIL.Formatter = nil
--- returns a table with quick format functions to save visual coding space
---@return GUTIL.Formatter f
function GUTIL:GetFormatter()
    if GUTIL.Formatter then return GUTIL.Formatter end
    local b = GUTIL.COLORS.DARK_BLUE
    local bb = GUTIL.COLORS.BRIGHT_BLUE
    local g = GUTIL.COLORS.GREEN
    local grey = GUTIL.COLORS.GREY
    local r = GUTIL.COLORS.RED
    local l = GUTIL.COLORS.LEGENDARY
    local e = GUTIL.COLORS.EPIC
    local patreon = GUTIL.COLORS.PATREON
    local whisper = GUTIL.COLORS.WHISPER
    local white = GUTIL.COLORS.WHITE
    local gold = GUTIL.COLORS.GOLD
    local silver = GUTIL.COLORS.SILVER
    local copper = GUTIL.COLORS.COPPER

    local c = function(text, color)
        return GUTIL:ColorizeText(text, color)
    end
    local p = GUTIL:GetQualityIconString(1, 15, 15) .. " "
    local s = GUTIL:GetQualityIconString(2, 15, 15) .. " "
    local P = GUTIL:GetQualityIconString(3, 15, 15) .. " "
    local a = "     "

    ---@class GUTIL.Formatter
    local formatter = {}
    formatter.b = function(text)
        return c(text, b)
    end
    formatter.bb = function(text)
        return c(text, bb)
    end
    formatter.g = function(text)
        return c(text, g)
    end
    formatter.r = function(text)
        return c(text, r)
    end
    formatter.l = function(text)
        return c(text, l)
    end
    formatter.e = function(text)
        return c(text, e)
    end
    formatter.grey = function(text)
        return c(text, grey)
    end
    formatter.patreon = function(text)
        return c(text, patreon)
    end
    formatter.whisper = function(text)
        return c(text, whisper)
    end
    formatter.white = function(text)
        return c(text, white)
    end
    formatter.gold = function(text)
        return c(text, gold)
    end
    formatter.silver = function(text)
        return c(text, silver)
    end
    formatter.copper = function(text)
        return c(text, copper)
    end
    formatter.p = p
    formatter.s = s
    formatter.P = P
    formatter.a = a
    formatter.m = function(m)
        return GUTIL:FormatMoney(m, true)
    end
    formatter.mr = function(m, r)
        return GUTIL:FormatMoney(m, true, r)
    end
    formatter.mw = function(m)
        return GUTIL:FormatMoney(m)
    end

    formatter.i = function(i, h, w)
        return GUTIL:IconToText(i, h, w)
    end

    formatter.class = function(t, class)
        if not class then
            return t
        end
        return C_ClassColor.GetClassColor(class):WrapTextInColorCode(t)
    end

    GUTIL.Formatter = formatter

    return formatter
end

---Colorizes a Text based on a color in GUTIL.COLORS (hex with alpha prefix)
---@param text string
---@param color string
---@return string colorizedText
function GUTIL:ColorizeText(text, color)
    local startLine = "\124c"
    local endLine = "\124r"
    return startLine .. color .. text .. endLine
end

---@enum GUTIL.COLORS
GUTIL.COLORS = {
    GREEN = "ff00FF00",
    RED = "ffFF0000",
    DARK_BLUE = "ff2596be",
    BRIGHT_BLUE = "ff00ccff",
    LEGENDARY = "ffff8000",
    EPIC = "ffa335ee",
    RARE = "ff0070dd",
    UNCOMMON = "ff1eff00",
    GREY = "ff9d9d9d",
    ARTIFACT = "ffe6cc80",
    GOLD = "FFFFD000",
    SILVER = "FFE4E4E4",
    COPPER = "FFCA8A4E",
    PATREON = "ffff424D",
    WHISPER = "ffff80ff",
    WHITE = "ffffffff",
}

---@param value number
---@return string
function GUTIL:SeperateThousands(value)
    local formatted = tostring(value)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Thanks to arkinventory
function GUTIL:StripColor(text)
    local text = text or ""
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
    text = string.gsub(text, "|r", "")
    return text
end

---@param value number
---@param hundredPercentValue number
function GUTIL:GetPercentRelativeTo(value, hundredPercentValue)
    if hundredPercentValue == 0 then
        return 100
    end
    local oneP = hundredPercentValue / 100
    local percent = GUTIL:Round(value / oneP, 0)

    if oneP == 0 then
        percent = 0
    end
    return percent
end

--- formats the given copper value as gold, silver and copper display with icons
---@param copperValue number
---@param useColor? boolean -- colors the numbers green if positive and red if negative
---@param percentRelativeTo number? if included: will be treated as 100% and a % value in relation to the coppervalue will be added
---@param separateThousands? boolean
---@param useTextures? boolean
function GUTIL:FormatMoney(copperValue, useColor, percentRelativeTo, separateThousands, useTextures)
    copperValue = GUTIL:Round(copperValue) -- there is no such thing as decimal coppers (we no fuel station here)
    local absValue = abs(copperValue) or 0
    local minusText = ""
    local color = GUTIL.COLORS.GREEN
    local percentageText = ""

    if percentRelativeTo then
        percentageText = " (" .. GUTIL:GetPercentRelativeTo(copperValue, percentRelativeTo) .. "%)"
    end

    if copperValue < 0 then
        minusText = "-"
        color = GUTIL.COLORS.RED
    end

    local moneyText
    local gValue, sValue, cValue = self:GetMoneyValuesFromCopper(absValue)
    local gString, sString, cString = tostring(gValue or 0), tostring(sValue or 0), tostring(cValue or 0)
    if separateThousands then
        gString = GUTIL:SeperateThousands(gValue or 0)
        sString = GUTIL:SeperateThousands(sValue or 0)
        cString = GUTIL:SeperateThousands(cValue or 0)
    end
    local f = self:GetFormatter()
    local gSep
    local sSep
    local cSep
    if useTextures then
        -- there is a format money api but its a bit less flexible and it changes the font
        local coinIconSize = 11
        gSep = CreateAtlasMarkup("auctionhouse-icon-coin-gold", coinIconSize, coinIconSize)
        sSep = CreateAtlasMarkup("auctionhouse-icon-coin-silver", coinIconSize, coinIconSize)
        cSep = CreateAtlasMarkup("auctionhouse-icon-coin-copper", coinIconSize, coinIconSize)
    else
        gSep = f.gold("g")
        sSep = f.silver("s")
        cSep = f.copper("c")
    end

    moneyText = cString .. cSep

    if sValue > 0 or gValue > 0 then
        moneyText = sString .. sSep .. moneyText
    end

    if gValue > 0 then
        moneyText = gString .. gSep .. moneyText
    end

    if useColor then
        return GUTIL:ColorizeText(minusText .. moneyText .. percentageText, color)
    else
        return minusText .. moneyText .. percentageText
    end
end

function GUTIL:Round(number, decimals)
    return tonumber((("%%.%df"):format(decimals)):format(number))
end

function GUTIL:GetItemIDByLink(hyperlink)
    local _, _, foundID = string.find(hyperlink, "item:(%d+)")
    return tonumber(foundID)
end

--- returns an ItemLocationMixin if found in the players bags or optional also bank
---@param itemID number
---@param includeBank boolean?
---@return ItemLocationMixin | nil itemLocation
function GUTIL:GetItemLocationFromItemID(itemID, includeBank)
    includeBank = includeBank or false
    local function FindBagAndSlot(itemID)
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local slotItemID = C_Container.GetContainerItemID(bag, slot)
                if slotItemID == itemID then
                    return bag, slot
                end
            end
        end
        if includeBank then
            -- +6 to include warbank
            for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS + 6 do
                for slot = 1, C_Container.GetContainerNumSlots(bag) do
                    local slotItemID = C_Container.GetContainerItemID(bag, slot)
                    if slotItemID == itemID then
                        return bag, slot
                    end
                end
            end
        end
    end
    local bag, slot = FindBagAndSlot(itemID)

    if bag and slot then
        return ItemLocation:CreateFromBagAndSlot(bag, slot)
    end
    return nil -- Return nil if not found
end

---@param itemList ItemMixin[]
---@param callback function
function GUTIL:ContinueOnAllItemsLoaded(itemList, callback)
    local itemsToLoad = #itemList
    if itemsToLoad == 0 then
        callback()
    end
    local itemLoaded = function()
        itemsToLoad = itemsToLoad - 1

        if itemsToLoad <= 0 then
            callback()
        end
    end

    if itemsToLoad >= 1 then
        for _, itemToLoad in pairs(itemList) do
            itemToLoad:ContinueOnItemLoad(itemLoaded)
        end
    end
end

---@param conditionCallback fun(): boolean
---@param callback function will be executed as soon as the condition is fulfilled
---@param checkInterval number? Seconds - Default: 0 (once per frame).
---@param maxWaitSeconds number? Maximum Seconds to wait, default: 10. No callback called when timeout triggered
function GUTIL:WaitFor(conditionCallback, callback, checkInterval, maxWaitSeconds)
    maxWaitSeconds = maxWaitSeconds or 10
    local startTime = GetTimePreciseSec()
    local function checkCondition()
        local secondsElapsed = GetTimePreciseSec() - startTime
        if secondsElapsed >= maxWaitSeconds then
            return
        end
        if conditionCallback() then
            callback()
        else
            C_Timer.After(checkInterval or 0, checkCondition)
        end
    end

    checkCondition()
end

GUTIL.eventWaitFrame = nil

local function initEventWaitFrame()
    GUTIL.eventWaitFrame = CreateFrame("frame")

    ---@type table<WowEvent, function[]>
    GUTIL.eventWaitFrame.callbackMap = {}

    function GUTIL.eventWaitFrame:UnregisterCallback(event, callback)
        if GUTIL.eventWaitFrame.callbackMap[event] then
            local _, index = GUTIL:Find(GUTIL.eventWaitFrame.callbackMap[event], function(fun)
                return fun == callback
            end)
            if index then
                tremove(GUTIL.eventWaitFrame.callbackMap[event], index)
            end
        end

        if GUTIL.eventWaitFrame.callbackMap[event] and GUTIL:Count(GUTIL.eventWaitFrame.callbackMap[event]) == 0 then
            GUTIL.eventWaitFrame.callbackMap[event] = nil
            GUTIL.eventWaitFrame:UnregisterEvent(event)
        end
    end

    ---@param event WowEvent
    ---@param callback function
    function GUTIL.eventWaitFrame:RegisterCallback(event, callback)
        if not GUTIL.eventWaitFrame.callbackMap[event] then
            GUTIL.eventWaitFrame.callbackMap[event] = { callback }
            GUTIL.eventWaitFrame:RegisterEvent(event)
        else
            if not tContains(GUTIL.eventWaitFrame.callbackMap[event], callback) then
                tinsert(GUTIL.eventWaitFrame.callbackMap[event], callback)
            end
        end
    end

    GUTIL.eventWaitFrame:SetScript("OnEvent", function(event, ...)
        if not GUTIL.eventWaitFrame.callbackMap[event] then return end
        local callbacks = GUTIL.eventWaitFrame.callbackMap[event]
        for _, callback in ipairs(callbacks) do
            xpcall(callback, function()
                print(debugstack("Error in Callback for GUTIL:WaitForEvent"))
            end, ...)
        end
        GUTIL.eventWaitFrame.callbackMap[event] = nil
        GUTIL.eventWaitFrame:UnregisterEvent(event)
    end)

    return GUTIL.eventWaitFrame
end

---@param event WowEvent
---@param callback function
---@param maxWaitSeconds number?
function GUTIL:WaitForEvent(event, callback, maxWaitSeconds)
    GUTIL.eventWaitFrame = GUTIL.eventWaitFrame or initEventWaitFrame()

    GUTIL.eventWaitFrame:RegisterCallback(event, callback)

    if maxWaitSeconds then
        C_Timer.After(maxWaitSeconds, function()
            GUTIL.eventWaitFrame:UnregisterCallback(event, callback)
        end)
    end
end

--- Runs the callback in the next frame when condition is true, otherwise it runs in the same frame
---@param condition boolean
---@param callback function
function GUTIL:NextFrameIF(condition, callback)
    if condition then
        RunNextFrame(callback)
    else
        callback()
    end
end

function GUTIL:EquipItemByLink(link)
    for bag = BANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemLink(bag, slot)
            if item and item == link then
                if CursorHasItem() or CursorHasMoney() or CursorHasSpell() then ClearCursor() end
                C_Container.PickupContainerItem(bag, slot)
                AutoEquipCursorItem()
                return true
            end
        end
    end
end

function GUTIL:isItemSoulbound(itemID)
    return select(14, C_Item.GetItemInfo(itemID)) == Enum.ItemBind.OnAcquire
end

--> GGUI or keep here?
function GUTIL:GetQualityIconString(qualityID, sizeX, sizeY, offsetX, offsetY)
    return CreateAtlasMarkup("Professions-Icon-Quality-Tier" .. qualityID, sizeX, sizeY, offsetX, offsetY)
end

--- Counts the number of items that return true for the given function
---@generic K
---@generic V
---@param t table<K, V>
---@param func? fun(value: V): boolean
---@return number count
function GUTIL:Count(t, func)
    local count = 0
    for _, v in pairs(t) do
        if func and func(v) then
            count = count + 1
        elseif not func then
            count = count + 1
        end
    end

    return count
end

--- Returns true if any of the table's items resolves to true for the given function
---@generic K
---@generic V
---@param t table<K, V>
---@param func fun(value: V): boolean
---@return boolean
function GUTIL:Some(t, func)
    return self:Count(t, func) > 0
end

--- Returns true if all of the table's items resolve to true for the given function
---@generic V
---@param t V[]
---@param func fun(element: V):boolean
---@return boolean
function GUTIL:Every(t, func)
    local tableCount = self:Count(t)
    return self:Count(t, func) == tableCount
end

--- Variant of table.sort that does not sort it in place
---comment
---@generic V
---@param t V[]
---@param compFunc fun(a: V, b: V):boolean true: A > B - false: A <= B
---@return V[] sorted sorted copy of given table
function GUTIL:Sort(t, compFunc)
    local sorted = {}
    for _, e in pairs(t) do
        table.insert(sorted, e)
    end

    table.sort(sorted, compFunc) -- more performant but in place

    return sorted
end

---Trims the table to a specific amount of elements.
---@param t table<number, any>
---@param amount number
---@param front boolean? if true table will be trimmed from front, otherwise from back
function GUTIL:TrimTable(t, amount, front)
    if #t == 0 then
        return t
    end
    if front then
        while (#t > amount) do
            table.remove(t, 1)
        end
    else
        while (#t > amount) do
            table.remove(t, #t)
        end
    end
end

--- Thank you https://github.com/Larsj02
--- compares versions like "7.8.10" and "10.8.9" (would say right is greater then left)
---@param versionA string
---@param versionB string
---@return number result 0 if same 1 if left is greater, -1 if left is smaller
function GUTIL:CompareVersionStrings(versionA, versionB)
    local segmentsA, segmentsB = {}, {}
    for segment in versionA:gmatch("[^.]+") do
        tinsert(segmentsA, tonumber(segment))
    end
    for segment in versionB:gmatch("[^.]+") do
        tinsert(segmentsB, tonumber(segment))
    end
    local maxLength = math.max(#segmentsA, #segmentsB)
    for i = 1, maxLength do
        local segA = segmentsA[i] or 0
        local segB = segmentsB[i] or 0

        if segA < segB then
            return -1
        elseif segA > segB then
            return 1
        end
    end
    return 0
end

---@generic K
---@generic V
---@param t table<K, V>
---@param initialValue any
---@param foldFunction fun(foldValue: any, nextElement: V, key: K): any
function GUTIL:Fold(t, initialValue, foldFunction)
    local accumulator = initialValue
    for key, value in pairs(t) do
        accumulator = foldFunction(accumulator, value, key)
    end

    return accumulator
end

--- splits a table into two tables, elements that resolve into true for the given function will be put into the first table
---@generic V
---@param t V[]
---@param splitFunc fun(v: V):boolean
---@return V[] filtered
---@return V[] rest
function GUTIL:Split(t, splitFunc)
    local tableA = {}
    local tableB = {}
    for _, element in pairs(t) do
        if splitFunc(element) then
            table.insert(tableA, element)
        else
            table.insert(tableB, element)
        end
    end
    return tableA, tableB
end

---@param iconPath string|number
---@param height number
---@param width number?
---@param offsetX number?
---@param offsetY number?
---@param originalX number? for textures to scale better
---@param originalY number? for textures to scale better
function GUTIL:IconToText(iconPath, height, width, offsetX, offsetY, originalX, originalY)
    width = width or height
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    if not originalX then
        return ("|T%s:%d:%d:%d:%d|t"):format(
            iconPath,
            height or width,
            width,
            offsetX,
            offsetY
        );
    else
        return ("|T%s:%d:%d:%d:%d:%d:%d|t"):format(
            iconPath,
            height or width,
            width,
            offsetX,
            offsetY,
            originalX,
            originalY
        );
    end
end

function GUTIL:ValidateNumberString(str, min, max, allowDecimals)
    local num = tonumber(str)
    if num == nil then
        return false -- Not a valid number
    end
    if not allowDecimals and num ~= math.floor(num) then
        return false -- Decimals not allowed
    end
    if (min and num < min) or (max and num > max) then
        return false -- Outside specified range
    end
    return true      -- Valid number within range
end

---@param timestampHigher number unix seconds
---@param timestampBLower number unix seconds
---@return integer dayDiff
function GUTIL:GetDaysBetweenTimestamps(timestampHigher, timestampBLower)
    -- Calculate the difference in seconds
    local differenceInSeconds = math.abs(timestampHigher - timestampBLower)

    -- Convert seconds to days
    local secondsInADay = 24 * 60 * 60 -- 24 hours * 60 minutes * 60 seconds
    local differenceInDays = differenceInSeconds / secondsInADay

    -- Round to the nearest whole number of days
    differenceInDays = math.floor(differenceInDays + 0.5)

    return differenceInDays
end

--- used by GUTIL:OrderedPairs function
---@generic K
---@generic V
---@param t table<K, V>
---@return K, V
function GUTIL.OrderedNext(t)
    local key = t[t.__next]
    if not key then return end
    t.__next = t.__next + 1
    return key, t.__source[key]
end

---based on [OrderedPairs User-Function](https://warcraft.wiki.gg/wiki/Orderedpairs)
---@generic K
---@generic V
---@param t table<K, V>
---@param compFunc? fun(a: V, b: V):boolean
---@return fun(t: table<K, V>): K, V orderedNext
---@return K[] keys
function GUTIL:OrderedPairs(t, compFunc)
    local keys, kn = { __source = t, __next = 1 }, 1
    for k in pairs(t) do
        keys[kn], kn = k, kn + 1
    end
    table.sort(keys, compFunc)
    return GUTIL.OrderedNext, keys
end

---@deprecated use FrameDistributor
--- spreads the iteration (unsorted random) of a given function over multiple frames (one frame per iteration) to reduce game lag for heavy processing.
--- Use the finallyCallback to continue after the iteration ends
---@async
---@generic K
---@generic V
---@param t table<K, V> the table to be iterated on
---@param iterationFunction fun(key:K, value:V, counter:number):boolean|nil called for each iteration of the given table, if the function returns false iteration will be stopped
---@param finallyCallback? function called after the iteration ends
---@param maxIterations? integer maximum number of iterations. Default is nil meaning no maximum
---@param maxMS? number maximum time in ms after the iteration is canceled
function GUTIL:FrameDistributedIteration(t, iterationFunction, finallyCallback, maxIterations, maxMS)
    --- map the keys of the table to indexes
    local iterationCounter = 1
    local startMS = GetTime() * 1000
    local currentIterationKey = nil
    local currentTableValue = nil
    local function iterate()
        currentIterationKey, currentTableValue = next(t, currentIterationKey)

        if not currentIterationKey then
            -- no more elements - end iterations
            if finallyCallback then
                finallyCallback()
            end
            return
        end

        local result = iterationFunction(currentIterationKey, currentTableValue, iterationCounter)
        local stopIteration = result ~= nil and result == false
        iterationCounter = iterationCounter + 1
        local elapsedMS = (GetTime() * 1000) - startMS
        local secondsReached = maxMS and (maxMS <= elapsedMS)
        local iterationsReached = maxIterations and (iterationCounter > maxIterations)

        if stopIteration or iterationsReached or secondsReached then
            if finallyCallback then
                finallyCallback()
            end
            return
        else
            RunNextFrame(iterate)
        end
    end

    iterate()
end

---@class GUTIL.TooltipContainsOptions
---@field tooltipFrame GameTooltip? default: global GameTooltip
---@field text string? if set searches for left or right text to contain given string
---@field textLeft string? if set searches for left text to contain given string
---@field textRight string? if set searches for right text to contain given string
---@field lineIterationCap? number default: 200

---@param options GUTIL.TooltipContainsOptions
---@return boolean containsText
function GUTIL:TooltipContains(options)
    local tooltip = options.tooltipFrame or GameTooltip
    local lineIterationCap = options.lineIterationCap or 200
    local text = options.text
    local textLeft = options.textLeft
    local textRight = options.textRight

    if not text and not textLeft and not textRight then
        return false
    end

    for lineIndex = 1, lineIterationCap do
        local lineLeft = _G[tooltip:GetName() .. 'TextLeft' .. lineIndex] --[[@as FontString?]]
        local lineRight = _G[tooltip:GetName() .. 'TextRight' .. lineIndex] --[[@as FontString?]]

        if not lineLeft and not lineRight then
            return false
        end

        if text then
            if (lineLeft and string.find(lineLeft:GetText() or "", text)) or
                (lineRight and string.find(lineRight:GetText() or "", text)) then
                return true
            end
        elseif textLeft then
            if (lineLeft and string.find(lineLeft:GetText() or "", textLeft)) then
                return true
            end
        elseif textRight then
            if (lineRight and string.find(lineRight:GetText() or "", textRight)) then
                return true
            end
        end
    end

    return false
end

---@class GUTIL.TooltipUpdateDoubleLineByIDOptions
---@field tooltipFrame GameTooltip? default: global GameTooltip
---@field updateLine? fun(leftLine: FontString, rightLine: FontString?)
---@field lineIterationCap? number default: 200
---@field gutilID any

---@param options GUTIL.TooltipUpdateDoubleLineByIDOptions
---@return string? updatedText
function GUTIL:TooltipUpdateDoubleLineByID(options)
    local tooltip = options.tooltipFrame or GameTooltip
    local lineIterationCap = options.lineIterationCap or 200
    local updateLine = options.updateLine
    local gutilID = options.gutilID


    if not updateLine or not gutilID then
        return
    end

    for lineIndex = 1, lineIterationCap do
        local lineLeft = _G[tooltip:GetName() .. 'TextLeft' .. lineIndex] --[[@as FontString?]]
        local lineRight = _G[tooltip:GetName() .. 'TextRight' .. lineIndex] --[[@as FontString?]]

        if not lineLeft then
            break
        end

        if lineLeft.gutilID == gutilID then
            options.updateLine(lineLeft, lineRight)
            -- TODO: remove property afterwards?
        end
    end
end

---@class GUTIL.TooltipAddDoubleLineWithIDOptions
---@field tooltipFrame GameTooltip? default: global GameTooltip
---@field gutilID any
---@field textLeft? string
---@field textRight? string
---@field leftTextRGB? table<number>
---@field rightTextRGB? table<number>

---@param options GUTIL.TooltipAddDoubleLineWithIDOptions
---@return FontString? lineLeft
---@return FontString? lineRight
function GUTIL:TooltipAddDoubleLineWithID(options)
    local tooltip = options.tooltipFrame or GameTooltip
    local textLeft = options.textLeft or ""
    local textRight = options.textRight or ""
    local leftRGB = options.leftTextRGB or {}
    local rightRGB = options.rightTextRGB or {}
    local gutilID = options.gutilID

    if not gutilID then
        error("GUTIL Error: Tooltip Double Line needs unique gutilID")
    end

    local tempUID = tostring(GetTimePreciseSec())

    tooltip:AddDoubleLine(tempUID, textRight, leftRGB[1], leftRGB[2], leftRGB[3], rightRGB[1], rightRGB[2],
        rightRGB[3])

    -- now update the double line and give it the gutilID
    for lineIndex = 1, 200 do
        local lineLeft = _G[tooltip:GetName() .. 'TextLeft' .. lineIndex] --[[@as FontString?]]
        local lineRight = _G[tooltip:GetName() .. 'TextRight' .. lineIndex] --[[@as FontString?]]

        if not lineLeft then
            break
        end

        if lineLeft:GetText() == tempUID then
            lineLeft.gutilID = gutilID
            lineLeft:SetText(textLeft)

            return lineLeft, lineRight
        end
    end
end

--- GUTIL.FrameDistributor

---@class GUTIL.FrameDistributor
---@overload fun(options:GUTIL.FrameDistributor.ConstructorOptions): GUTIL.FrameDistributor
GUTIL.FrameDistributor = GUTIL.Object:extend()

---@class GUTIL.FrameDistributor.ConstructorOptions
---@field iterationsPerFrame number? default: 1
---@field maxIterations number?
---@field iterationTable table? if null iterates til maxIterations or cancelled
---@field continue fun(frameDistributor: GUTIL.FrameDistributor, key: any?, value: any?, currentIteration: number, progress: number) called each iteration, has to call Continue
---@field cancel? fun(): boolean -- used to check for cancel between iterations
---@field finally? fun()  -- ran when finished and on cancel

---@param options GUTIL.FrameDistributor.ConstructorOptions
function GUTIL.FrameDistributor:new(options)
    self.iterationsPerFrame = options.iterationsPerFrame or 1
    self.maxIterations = options.maxIterations

    self.iterationTable = options.iterationTable
    self:Reset()
    self.continue = options.continue or function() end
    self.cancel = options.cancel or function() return false end
    self.finally = options.finally or function() end
end

function GUTIL.FrameDistributor:Continue()
    self.currentIteration = self.currentIteration + 1

    if self.maxIterations then
        if self.currentIteration >= self.maxIterations then
            self.finally()
            return
        end
    end

    local runInFrame = self.iterationsPerFrame <= 0 or (mod(self.currentIteration, self.iterationsPerFrame) > 0)

    if self.cancel() then
        self.finally()
        return
    end
    local key, value
    if self.iterationTable then
        key, value = next(self.iterationTable, self.currentIterationKey)
        self.currentIterationKey = key
    end

    local currentProgress = self.currentIteration / self.iterationProgressStep

    if self.iterationTable and not key then
        self.finally()
        return
    end

    if runInFrame then
        self.continue(self, key, value, self.currentIteration, currentProgress)
    else
        RunNextFrame(function()
            self.continue(self, key, value, self.currentIteration, currentProgress)
        end)
    end
end

--- Stops iteration and calls finally callback
function GUTIL.FrameDistributor:Break()
    self.finally()
end

---@param newTable table
function GUTIL.FrameDistributor:SetIterationTable(newTable)
    self.iterationTable = newTable
    self:Reset()
end

function GUTIL.FrameDistributor:Reset()
    self.tableSize = GUTIL:Count(self.iterationTable or {})
    if self.iterationTable then
        self.iterationProgressStep = (self.tableSize / 100)
    else
        self.iterationProgressStep = 1
    end
    self.currentIterationKey = nil
    self.breakActive = false
    self.currentIteration = 0
end

--- Reuseable MenuUtil Context Menu Frames Utility
---@param initCallback fun(frame: Frame)
---@param sizeX number
---@param sizeY number
---@param frameID string
function GUTIL:CreateReuseableMenuUtilContextMenuFrame(descriptionElement, initCallback, sizeX, sizeY, frameID)
    self.contextMenuFrames = self.contextMenuFrames or {}

    local contextMenuFrame = descriptionElement:CreateTemplate("Frame")
    contextMenuFrame:AddInitializer(function(frame, elementDescription, menu)
        frame = frame --[[@as Frame]]
        frame:SetSize(sizeX, sizeY)
        local customFrame = self.contextMenuFrames[frameID]
        if not customFrame then
            customFrame = CreateFrame("Frame")
            initCallback(customFrame)
            self.contextMenuFrames[frameID] = customFrame
        end
        customFrame:SetParent(frame)
        customFrame:SetAllPoints(frame)
        customFrame:Show()

        -- to not make it appear in reuseable frames of other context menus
        customFrame:SetScript("OnHide", function()
            customFrame:Hide()
        end)
    end)
end
