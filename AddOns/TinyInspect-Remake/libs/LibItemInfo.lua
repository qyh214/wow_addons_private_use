
---------------------------------
-- 物品信息庫 Author: M
---------------------------------

local MAJOR, MINOR = "LibItemInfo.7000", 8
local lib = LibStub:NewLibrary(MAJOR, MINOR)

-- local GetItemInfo = GetItemInfo
local GetItemStats = C_Item and C_Item.GetItemStats
local GetDetailedItemLevelInfoAPI = C_Item and C_Item.GetDetailedItemLevelInfo

local function GetContainerItemLink(bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    return info and info.hyperlink
end

if not lib then return end

local StatTokenToName = {
    ITEM_MOD_STRENGTH_SHORT = ITEM_MOD_STRENGTH_SHORT,
    ITEM_MOD_AGILITY_SHORT = ITEM_MOD_AGILITY_SHORT,
    ITEM_MOD_INTELLECT_SHORT = ITEM_MOD_INTELLECT_SHORT,
    ITEM_MOD_STAMINA_SHORT = ITEM_MOD_STAMINA_SHORT,
    ITEM_MOD_CRIT_RATING_SHORT = STAT_CRITICAL_STRIKE,
    ITEM_MOD_HASTE_RATING_SHORT = STAT_HASTE,
    ITEM_MOD_MASTERY_RATING_SHORT = STAT_MASTERY,
    ITEM_MOD_VERSATILITY = STAT_VERSATILITY,
    ITEM_MOD_VERSATILITY_RATING_SHORT = STAT_VERSATILITY,
    ITEM_MOD_CR_AVOIDANCE_SHORT = STAT_AVOIDANCE,
    ITEM_MOD_CR_SPEED_SHORT = STAT_SPEED,
    ITEM_MOD_CR_LIFESTEAL_SHORT = STAT_LIFESTEAL,
}

local function GetItemLevelViaAPI(link)
    local level = GetDetailedItemLevelInfoAPI(link)
    if (type(level) == "number") then
        return level
    end
    return nil
end

function lib:GetStatsViaAPI(link, stats)
    if (type(stats) ~= "table") then
        return stats
    end
    if (type(GetItemStats) ~= "function") then
        return stats
    end
    local itemStats = GetItemStats(link)
    if (type(itemStats) ~= "table") then
        return stats
    end
    for token, statValue in pairs(itemStats) do
        if (type(statValue) == "number" and statValue ~= 0) then
            local statName = StatTokenToName[token] or _G[token] or token
            if (not stats[statName]) then
                stats[statName] = { value = statValue, r = 0, g = 1, b = 0.2 }
            else
                stats[statName].value = stats[statName].value + statValue
            end
        end
    end
    return stats
end

--物品是否已經本地化
-- checkGems=true keeps legacy behavior; false speeds up ilevel/stat reads.
function lib:HasLocalCached(item, checkGems)
    if (checkGems == nil) then
        checkGems = true
    end
    if (not item or item == "" or item == "0") then return true end
    if (tonumber(item)) then
        return select(10, GetItemInfo(tonumber(item)))
    else
        local id, gem1, gem2, gem3 = string.match(item, "item:(%d+):[^:]*:(%d-):(%d-):(%d-):")
        if (not id) then
            return true
        end
        if (not checkGems) then
            return self:HasLocalCached(id, false)
        end
        return self:HasLocalCached(id, false) and self:HasLocalCached(gem1, false) and self:HasLocalCached(gem2, false) and self:HasLocalCached(gem3, false)
    end
end

--獲取物品實際等級信息
function lib:GetItemInfo(link, stats, withoutExtra)
    return self:GetItemInfoViaAPI(link, stats, withoutExtra)
end

--獲取物品實際等級信息通過API
function lib:GetItemInfoViaAPI(link, stats, withoutExtra)
    if (not link or link == "") then
        return 0, 0
    end
    if (not string.match(link, "item:%d+:")) then
        return 1, -1
    end
    if (not self:HasLocalCached(link, false)) then
        return 1, 0
    end
    local level = GetItemLevelViaAPI(link)
    if (not level) then
        return 1, 0
    end
    self:GetStatsViaAPI(link, stats)
    if (withoutExtra) then
        return 0, level
    else
        return 0, level, GetItemInfo(link)
    end
end

--兼容舊接口：不再使用Tooltip，直接走API
function lib:GetItemInfoViaTooltip(link, stats, withoutExtra)
    return self:GetItemInfoViaAPI(link, stats, withoutExtra)
end

--獲取容器裏物品裝備等級
function lib:GetContainerItemLevel(pid, id)
    local link
    if (pid and id) then
        link = GetContainerItemLink(pid, id)
    end
    if (link) then
        return self:GetItemInfo(link)
    end
    return 1, 0
end

--獲取UNIT物品實際等級信息（API）
function lib:GetUnitItemInfo(unit, index, stats)
    if (not UnitExists(unit)) then return 1, -1 end
    local link = GetInventoryItemLink(unit, index)
    if (not link or link == "") then
        -- 檢視同步邊界可能暫時沒有link，標記為未知以便重試
        if (GetInventoryItemID(unit, index)) then
            return 1, 0
        end
        return 0, 0
    end
    if (not self:HasLocalCached(link, false)) then
        return 1, 0
    end
    local level = GetItemLevelViaAPI(link)
    if (not level) then
        return 1, 0
    end
    self:GetStatsViaAPI(link, stats)
    if (string.match(link, "item:(%d+):")) then
        return 0, level, GetItemInfo(link)
    else
        return 0, level, link
    end
end

--獲取UNIT的裝備等級
--@return unknownCount, 平均装等, 装等总和, 最大武器等级, 是否神器, 最大装等
function lib:GetUnitItemLevel(unit, stats)
    local total, counts, maxlevel = 0, 0, 0
    local _, count, level
    for i = 1, 15 do
        if (i ~= 4) then
            count, level = self:GetUnitItemInfo(unit, i, stats)
            total = total + level
            counts = counts + count
            maxlevel = max(maxlevel, level)
        end
    end
    local mcount, mlevel, mquality, mslot, ocount, olevel, oquality, oslot
    mcount, mlevel, _, _, mquality, _, _, _, _, _, mslot = self:GetUnitItemInfo(unit, 16, stats)
    ocount, olevel, _, _, oquality, _, _, _, _, _, oslot = self:GetUnitItemInfo(unit, 17, stats)
    counts = counts + mcount + ocount
    if (mquality == 6 or oquality == 6) then
        total = total + max(mlevel, olevel) * 2
    elseif (oslot == "INVTYPE_2HWEAPON" or mslot == "INVTYPE_2HWEAPON" or mslot == "INVTYPE_RANGED" or mslot == "INVTYPE_RANGEDRIGHT") then 
        total = total + max(mlevel, olevel) * 2
    else
        total = total + mlevel + olevel
    end
    maxlevel = max(maxlevel, mlevel, olevel)
    return counts, total/max(16-counts,1), total, max(mlevel,olevel), (mquality == 6 or oquality == 6), maxlevel
end

--獲取任务物品實際link（12.x API only，無Tooltip）
function lib:GetQuestItemlink(questType, id)
    return GetQuestLogItemLink(questType, id) or GetQuestItemLink(questType, id)
end
