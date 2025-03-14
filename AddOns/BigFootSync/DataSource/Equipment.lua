---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.equipment = {}

---@class Equipment
local E = BigFootSync.equipment

---------------------------------------------------------------------
-- 保存玩家自己的装备信息
---------------------------------------------------------------------
-- https://warcraft.wiki.gg/wiki/InventorySlotId
local INV_SLOT_NAME = {
    [INVSLOT_HEAD] = "head",
    [INVSLOT_NECK] = "neck",
    [INVSLOT_SHOULDER] = "shoulders",
    [INVSLOT_BODY] = "shirt",
    [INVSLOT_CHEST] = "chest",
    [INVSLOT_WAIST] = "waist",
    [INVSLOT_LEGS] = "legs",
    [INVSLOT_FEET] = "feet",
    [INVSLOT_WRIST] = "wrist",
    [INVSLOT_HAND] = "hands",
    [INVSLOT_FINGER1] = "finger1",
    [INVSLOT_FINGER2] = "finger2",
    [INVSLOT_TRINKET1] = "trinket1",
    [INVSLOT_TRINKET2] = "trinket2",
    [INVSLOT_BACK] = "back",
    [INVSLOT_MAINHAND] = "main_hand",
    [INVSLOT_OFFHAND] = "off_hand",
    [INVSLOT_TABARD] = "tabard",
}

if BigFootSync.isVanilla or BigFootSync.isWrath then
    INV_SLOT_NAME[INVSLOT_AMMO] = "ammo"
    INV_SLOT_NAME[INVSLOT_RANGED] = "ranged"
end

local GetInventoryItemLink = GetInventoryItemLink
local GetItemName = C_Item.GetItemName
local GetItemCraftedQualityByItemInfo = C_TradeSkillUI and C_TradeSkillUI.GetItemCraftedQualityByItemInfo
local GetItemStats = GetItemStats or C_Item.GetItemStats
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo or C_Item.GetDetailedItemLevelInfo

local ID_INDEX = 1
local ENCHANT_INDEX = 2
local GEM_INDEX_START, GEM_INDEX_END = 3, 6
local SUFFIX_INDEX = 7
-- local SPEC_INDEX = 10
local CONTEXT_INDEX = 12
local BONUS_INDEX = 13
local CRAFTING_STAT_1 = Enum.ItemModification.ChangeModifiedCraftingStat_1
local CRAFTING_STAT_2 = Enum.ItemModification.ChangeModifiedCraftingStat_2

local function ExtractEquipmentData(slot)
    local data = {}
    local link = GetInventoryItemLink("player", slot)

    if link then
        -- print(string.gsub(link, "\124", "\124\124"))
        -- print(string.match(link, "item[%-?%d:]+"))

        local str = strmatch(link, "|Hitem:(.+)|h.+|h")
        -- local str, name = strmatch(link, "|Hitem:(.+)|h%[([^|]+).*%]|h")
        -- data.name = strtrim(name) -- not always available

        local t = {strsplit(":", str)}
        for k, v in pairs(t) do
            if v == "" then
                t[k] = nil
            else
                t[k] = tonumber(v)
            end
        end

        -- slot
        data.slot = INV_SLOT_NAME[slot]

        -- id
        data.id = t[ID_INDEX]

        -- enchant
        data.enchant = t[ENCHANT_INDEX]

        -- gems
        local gems = {}
        for k = GEM_INDEX_START, GEM_INDEX_END do
            if t[k] then
                tinsert(gems, t[k])
            end
        end
        data.gems = table.concat(gems, ",")

        -- suffix
        data.suffix = t[SUFFIX_INDEX]

        -- context (source)
        data.context = t[CONTEXT_INDEX]

        -- bonuses
        local bonuses = {}
        local numBonusIDs = t[BONUS_INDEX]
        if numBonusIDs then
            local bonusIndex = BONUS_INDEX + 1
            for i = 1, numBonusIDs do
                tinsert(bonuses, t[bonusIndex])
                bonusIndex = bonusIndex + 1
            end
        end
        data.bonuses = table.concat(bonuses, ",")

        -- modifiers
        data.modifiers = {}
        local modifierIndex = BONUS_INDEX + (numBonusIDs or 0) + 1
        local numModifiers = t[modifierIndex]
        if numModifiers then
            local modifierKeyIndex = modifierIndex + 1
            for i = 1, numModifiers do
                data.modifiers[t[modifierKeyIndex]] = t[modifierKeyIndex + 1]
                modifierKeyIndex = modifierKeyIndex + 2
            end
        end

        -- simc
        data.simc = data.slot .. "=,id=" .. data.id
        if data.enchant then
            data.simc = data.simc .. ",enchant_id=" .. data.enchant
        end
        if #gems ~= 0 then
            data.simc = data.simc .. ",gem_id=" .. table.concat(gems, "/")
        end
        if #bonuses ~= 0 then
            data.simc = data.simc .. ",bonus_id=" .. table.concat(bonuses, "/")
        end

        if BigFootSync.isRetail then
            -- craftedStats
            local craftedStats = {}
            if data.modifiers[CRAFTING_STAT_1] then
                tinsert(craftedStats, data.modifiers[CRAFTING_STAT_1])
            end
            if data.modifiers[CRAFTING_STAT_2] then
                tinsert(craftedStats, data.modifiers[CRAFTING_STAT_2])
            end
            data.craftedStats = table.concat(craftedStats, ",")

            -- crafted quality
            data.craftedQuality = GetItemCraftedQualityByItemInfo(link)

            -- simc
            if #craftedStats ~= 0 then
                data.simc = data.simc .. ",crafted_stats=" .. table.concat(craftedStats, "/")
            end
            if data.craftedQuality then
                data.simc = data.simc .. ",crafting_quality=" .. data.craftedQuality
            end
        end

        -- stats
        data.stats = GetItemStats(link)

        -- level
        data.level = GetDetailedItemLevelInfo(link)

        if not data.level then
            return data, false
        end
    end
    return data, true
end

function E.UpdateEquipments(t, slot)
    local success
    if slot then
        t[INV_SLOT_NAME[slot]], success = ExtractEquipmentData(slot)
        if not success then
            C_Timer.After(5, function()
                E.UpdateEquipments(t, slot)
            end)
        end
    else
        for id in pairs(INV_SLOT_NAME) do
            t[INV_SLOT_NAME[id]], success = ExtractEquipmentData(id)
            if not success then
                C_Timer.After(5, function()
                    E.UpdateEquipments(t, id)
                end)
            end
        end
    end
end

---------------------------------------------------------------------
-- 平均装等
---------------------------------------------------------------------
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo or C_Item.GetDetailedItemLevelInfo

local cached = {}
BigFootSync.cachedItemLevels = cached

function E.ShouldUpdateUnitItemLevel(guid)
    return not cached[guid]
end

if BigFootSync.isRetail then
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

    local GetTooltipData = C_TooltipInfo.GetInventoryItem
    -- local scanner = CreateFrame("GameTooltip", "BigFootScanner", UIParent, "GameTooltipTemplate")
    -- if not GetTooltipData then
    --     GetTooltipData = function(unit, slot)
    --         scanner:SetOwner(UIParent, "ANCHOR_NONE")
    --         local hasItem = scanner:SetInventoryItem(unit, slot)
    --         if hasItem then
    --             scanner:Show()
    --             return scanner:GetTooltipData()
    --         end
    --     end
    -- end

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

    -- local function GetSlotLevel(link)
    --     if not link then
    --         return 0
    --     end
    --     return GetDetailedItemLevelInfo(link)
    -- end

    local slotData = {}

    function E.SaveUnitItemLevel(t, unit, guid)
        if not slotData[guid] then slotData[guid] = {} end

        local spec = GetInspectSpecialization(unit)

        for _, slot in pairs(SLOTS) do
            slotData[guid][slot] = GetTooltipData(unit, slot)
            -- slotData[guid][slot] = GetInventoryItemLink(unit, slot)
        end

        C_Timer.After(0.1, function()
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
                    t["itemLevel"] = max(Round(total / NUM_SLOTS), 1)
                    cached[guid] = GetTime()
                    -- print(t["itemLevel"])
                end

            end

            slotData[guid] = nil
        end)
    end

else
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

    local NUM_SLOTS = 17

    local function GetSlotLevel(unit, slot)
        local link = GetInventoryItemLink(unit, slot)
        local level = 0
        if link then
            -- level = select(4, GetItemInfo(link))
            level = GetDetailedItemLevelInfo(link)
        end
        return level
    end

    function E.SaveUnitItemLevel(t, unit, guid)
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
                    t["itemLevel"] = max(Round(total / NUM_SLOTS), 1)
                    cached[guid] = GetTime()
                    -- print(t["itemLevel"])
                end

            end
        end)
    end
end