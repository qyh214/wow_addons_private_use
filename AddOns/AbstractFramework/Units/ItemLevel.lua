---@class AbstractFramework
---@field ItemLevel AF_ItemLevel
local AF = _G.AbstractFramework

AF.ItemLevel = {}

---@class AF_ItemLevel
local IL = AF.ItemLevel

local cache = {}

local CalcItemLevel
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local GetTime = GetTime
local CanInspect = CanInspect
local GetAverageItemLevel = GetAverageItemLevel
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = C_Item.GetItemInfo
local GetTooltipData = C_TooltipInfo and C_TooltipInfo.GetInventoryItem

---------------------------------------------------------------------
-- update
---------------------------------------------------------------------
if GetTooltipData then
    local SLOTS = {
        INVSLOT_HEAD,
        INVSLOT_NECK,
        INVSLOT_SHOULDER,
        INVSLOT_CHEST,
        INVSLOT_WAIST,
        INVSLOT_LEGS,
        INVSLOT_FEET,
        INVSLOT_WRIST,
        INVSLOT_HAND,
        INVSLOT_FINGER1,
        INVSLOT_FINGER2,
        INVSLOT_TRINKET1,
        INVSLOT_TRINKET2,
        INVSLOT_BACK,
        INVSLOT_MAINHAND,
        INVSLOT_OFFHAND,
    }

    local NUM_SLOTS = 16

    local TWO_HANDED = {
        INVTYPE_2HWEAPON = true,
        INVTYPE_RANGED = true,
        INVTYPE_RANGEDRIGHT = true,
    }

    local ITEM_LEVEL_PATTERN = ITEM_LEVEL:gsub("%%d", "(%%d+)")
    local ITEM_LEVEL_ALT_PATTERN = ITEM_LEVEL_ALT:gsub("%%d %(%%d%)", "%%d+ %%((%%d+)%%)")


    local function GetSlotInfo(unit, slot)
        local item = GetInventoryItemLink(unit, slot)
        if item then
            local _, _, quality, _, _, _, _, _, equipLoc, _, _, classId, subClassId = C_Item.GetItemInfo(item)
            return quality, equipLoc, classId, subClassId
        end
    end

    local function GetSlotLevel(data)
        if not data then
            return 0
        end

        local line = data.lines[1]
        local text = line and line.leftText
        if not text or text == RETRIEVING_ITEM_INFO then
            return nil
        end

        for i = 2, #data.lines do
            local line = data.lines[i]
            local text = line.leftText
            if text and text ~= "" then
                text = text:match(ITEM_LEVEL_PATTERN) or text:match(ITEM_LEVEL_ALT_PATTERN)
                if text then
                    return tonumber(text)
                end
            end
        end
    end

    local slotData = {}

    CalcItemLevel = function(unit, guid)
        if slotData[guid] then return end
        slotData[guid] = {}

        -- print("Calculating item level for", unit, guid)

        local spec = GetInspectSpecialization(unit)

        for _, slot in pairs(SLOTS) do
            slotData[guid][slot] = GetTooltipData(unit, slot)
        end

        local mainLevel = GetSlotLevel(slotData[guid][INVSLOT_MAINHAND])
        local offLevel = GetSlotLevel(slotData[guid][INVSLOT_OFFHAND])
        slotData[guid][INVSLOT_MAINHAND] = nil
        slotData[guid][INVSLOT_OFFHAND] = nil

        -- print(mainLevel, offLevel)
        if mainLevel and offLevel then
            local total = 0
            local mainQuality, mainEquipLoc, mainClassId, mainSubClassId = GetSlotInfo(unit, INVSLOT_MAINHAND)
            if spec ~= 72 and mainEquipLoc and (mainQuality == Enum.ItemQuality.Artifact or TWO_HANDED[mainEquipLoc])
                and not (mainClassId == 2 and mainSubClassId == 19) then -- 2:武器 19:魔杖
                total = total + max(mainLevel, offLevel) * 2
            else
                total = total + mainLevel + offLevel
            end

            for _, data in pairs(slotData[guid]) do
                local slot = GetSlotLevel(data)
                -- print(data.hyperlink, slot)
                if slot then
                    total = total + slot
                else
                    total = nil
                    break
                end
            end

            if total and total ~= 0 then
                cache[guid] = {
                    lastUpdate = GetTime(),
                    itemLevel = AF.RoundToDecimal(total / NUM_SLOTS, 1)
                }
                AF.Fire("AF_UNIT_ITEM_LEVEL_UPDATE", unit, guid)
            end
        end

        slotData[guid] = nil

        if not cache[guid] and UnitExists(unit) and UnitGUID(unit) == guid then
            -- print("RETRY", unit, guid)
            AF.DelayedInvoke(0.2, CalcItemLevel, unit, guid)
        end
    end

else
    local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo or C_Item.GetDetailedItemLevelInfo

    local SLOTS = {
        INVSLOT_HEAD,
        INVSLOT_NECK,
        INVSLOT_SHOULDER,
        INVSLOT_CHEST,
        INVSLOT_WAIST,
        INVSLOT_LEGS,
        INVSLOT_FEET,
        INVSLOT_WRIST,
        INVSLOT_HAND,
        INVSLOT_FINGER1,
        INVSLOT_FINGER2,
        INVSLOT_TRINKET1,
        INVSLOT_TRINKET2,
        INVSLOT_BACK,
        INVSLOT_RANGED,
    }

    local NUM_SLOTS

    if AF.isMists then
        NUM_SLOTS = 16
    else
        tinsert(SLOTS, INVSLOT_RANGED)
        NUM_SLOTS = 17
    end

    local function GetSlotLevel(unit, slot)
        local link = GetInventoryItemLink(unit, slot)
        local level = 0
        if link then
            level = GetDetailedItemLevelInfo(link)
        end
        return level
    end

    -- REVIEW:
    CalcItemLevel = function(unit, guid)
        C_Timer.After(0.1, function()
            local mainLevel, offLevel = 0, 0
            local mainEquipLoc

            local mainLink = GetInventoryItemLink(unit, INVSLOT_MAINHAND)
            if mainLink then
                mainLevel = GetDetailedItemLevelInfo(mainLink)
                mainEquipLoc = select(9, GetItemInfo(mainLink))
            end

            local offLink = GetInventoryItemLink(unit, INVSLOT_OFFHAND)
            if offLink then
                offLevel = GetDetailedItemLevelInfo(offLink)
            end

            if mainLevel and offLevel then
                local total = 0
                if mainEquipLoc and mainEquipLoc == INVTYPE_2HWEAPON then
                    total = total + mainLevel * 2
                else
                    total = total + mainLevel + offLevel
                end

                for _, slot in pairs(SLOTS) do
                    slot = GetSlotLevel(unit, slot)
                    total = total + slot
                end

                if total and total ~= 0 then
                    cache[guid] = {
                        lastUpdate = GetTime(),
                        itemLevel = AF.RoundToDecimal(total / NUM_SLOTS, 1)
                    }
                    AF.Fire("AF_UNIT_ITEM_LEVEL_UPDATE", unit, guid)
                end
            end
        end)
    end
end

---------------------------------------------------------------------
-- inspect
---------------------------------------------------------------------
local queue = {}

local function INSPECT_READY(_, _, guid)
    local unit = queue[guid] and queue[guid].unit
    if not unit then return end

    -- print("Inspect ready for", unit, guid)

    local correct_guid = UnitGUID(unit)
    if correct_guid == guid then
        CalcItemLevel(unit, guid)
    end

    queue[guid] = nil
end
AF:RegisterEvent("INSPECT_READY", INSPECT_READY)

-- will fire "AF_UNIT_ITEM_LEVEL_UPDATE(unit, guid)" when item level is updated
---@param unit string
function IL.UpdateCache(unit)
    if not UnitIsPlayer(unit) then return end

    if UnitIsUnit(unit, "player") then
        cache[AF.player.guid] = {
            lastUpdate = GetTime(),
            itemLevel = AF.RoundToDecimal(select(2, GetAverageItemLevel()), 1)
        }
        AF.Fire("AF_UNIT_ITEM_LEVEL_UPDATE", unit, AF.player.guid)
        return
    end

    local guid = UnitGUID(unit)
    if not guid then return end

    if CanInspect(unit) and not (queue[guid] and GetTime() - queue[guid].requested < 2) then
        queue[guid] = {
            unit = unit,
            requested = GetTime(),
        }
        -- print("Requesting inspect for", unit, guid)
        NotifyInspect(unit)
    end
end

---@param guid string
---@return number? itemLevel
---@return number? timeSinceLastUpdate
function IL.GetCache(guid)
    if not guid then return end

    if guid == AF.player.guid then
        cache[AF.player.guid] = {
            lastUpdate = GetTime(),
            itemLevel = AF.RoundToDecimal(select(2, GetAverageItemLevel()), 1)
        }
        return cache[AF.player.guid].itemLevel, 0
    end

    if cache[guid] then
        return cache[guid].itemLevel, GetTime() - cache[guid].lastUpdate
    end
end

-- function IL.ClearCache()
--     wipe(cache)
--     wipe(queue)
-- end
