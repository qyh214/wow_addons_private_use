-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- Add currency information
private.currencyIds["Honor"] = 1792
private.currencyIndexes[private.currencyIds.Honor] = true

-- Add preferences
private.Preferences.DefaultValues.profile.DisabledIntegrations.Honor = false;
private.Preferences.DisabledIntegrations.Honor = {
    type = "toggle",
    name = L["HONOR_UPGRADES"],
    order = 130,
    width = "double",
}

--[[
    ItemBonusListGroupEntry.ItemBonusListID
    ItemBonusListGroup.ItemLogicalCostGroupID
    ItemLogicalCost.ItemExtendedCostID
    ItemExtendedCost.CurrencyID_0 / ItemExtendedCost.CurrencyCount_0

    https://wago.tools/db2/ItemBonusListGroupEntry?filter[ItemBonusListID]=9421&page=1
    https://wago.tools/db2/ItemBonusListGroupEntry?filter[ItemBonusListID]=9422&page=1
    https://wago.tools/db2/ItemBonusListGroupEntry?filter[ItemBonusListID]=9423&page=1
    https://wago.tools/db2/ItemBonusListGroupEntry?filter[ItemBonusListID]=9424&page=1
    https://wago.tools/db2/ItemBonusListGroupEntry?filter[ItemBonusListID]=9425&page=1
    https://wago.tools/db2/ItemLogicalCost?filter[ItemLogicalCostGroupID]=exact%3A4&page=1&sort[ItemExtendedCostID]=asc
]]

---@type Array<HonorBonusData>
local honorBonusIds = {
    [9421] = { itemLevel = 366, upgradeLevel = 1, maxUpgradeLevel = 5},
    [9422] = { itemLevel = 372, upgradeLevel = 2, maxUpgradeLevel = 5},
    [9423] = { itemLevel = 379, upgradeLevel = 3, maxUpgradeLevel = 5},
    [9424] = { itemLevel = 385, upgradeLevel = 4, maxUpgradeLevel = 5},
    [9425] = { itemLevel = 392, upgradeLevel = 5, maxUpgradeLevel = 5},
}

---@type Array<number>
local itemExtendedCosts = {
    [7623] = 700,
    [7624] = 550,
    [7625] = 425,
    [7626] = 375,
    [7627] = 700,
    [7628] = 1425,
    [7629] = 1050,
    [7630] = 1425,
}

---@type Dictionary<integer>
local itemUpgradeCosts = {

    -- InventoryTypeSlotMask 1048738
    ["INVTYPE_HEAD"] = itemExtendedCosts[7623],
    ["INVTYPE_CHEST"] = itemExtendedCosts[7623],
    ["INVTYPE_LEGS"] = itemExtendedCosts[7623],
    ["INVTYPE_ROBE"] = itemExtendedCosts[7623],

    -- InventoryTypeSlotMask 5448
    ["INVTYPE_SHOULDER"] = itemExtendedCosts[7624],
    ["INVTYPE_WAIST"] = itemExtendedCosts[7624],
    ["INVTYPE_FEET"] = itemExtendedCosts[7624],
    ["INVTYPE_HAND"] = itemExtendedCosts[7624],
    ["INVTYPE_TRINKET"] = itemExtendedCosts[7624],

    -- InventoryTypeSlotMask 72196
    ["INVTYPE_NECK"] = itemExtendedCosts[7625],
    ["INVTYPE_WRIST"] = itemExtendedCosts[7625],
    ["INVTYPE_FINGER"] = itemExtendedCosts[7625],
    ["INVTYPE_CLOAK"] = itemExtendedCosts[7625],

    -- InventoryTypeSlotMask 8404992
    ["INVTYPE_HOLDABLE"] = itemExtendedCosts[7626],
    ["INVTYPE_SHIELD"] = itemExtendedCosts[7626],

    -- InventoryTypeSlotMask 8192
    ["INVTYPE_WEAPON"] = itemExtendedCosts[7627],

    -- InventoryTypeSlotMask 67272704
    ["INVTYPE_RANGED"] = itemExtendedCosts[7628],
    ["INVTYPE_2HWEAPON"] = itemExtendedCosts[7628],
    ["INVTYPE_RANGEDRIGHT"] = itemExtendedCosts[7628],
}

-- Override costs for Intellect items
---@type Dictionary<integer>
local itemUpgradeCostOverrides = {
    -- InventoryTypeSlotMask 131072
    ["INVTYPE_2HWEAPON"] = itemExtendedCosts[7630],
    
    -- InventoryTypeSlotMask 67117056
    ["INVTYPE_WEAPON"] = itemExtendedCosts[7629],
    ["INVTYPE_RANGEDRIGHT"] = itemExtendedCosts[7629],
}

-- Override costs for non-Gladiator trinkets
---@type { [number]: number } }
local trinketUpgradeCostOverrides = {
    [205779] = itemExtendedCosts[7625],
    [205782] = itemExtendedCosts[7625],
}

--- Parses the given upgrade costs to generate a table for use in tooltip
---@param upgradeCost number
local function ParseUpgradeCost(upgradeCost)
    local lines = {}

    ---@type CurrencyInfo
    local currencyInfo = private.currencyInfo[private.currencyIds.Honor];
    if currencyInfo == nil then
        private.Debug(private.currencyIds.Honor, "was not found in currency info table when parsing Honor upgrade costs");
        return lines
    end

    local icon = currencyInfo.iconFileID and CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

    -- Check currency against cap
    local itemCount = currencyInfo.quantity;
    local requiredColor = itemCount >= upgradeCost and GREEN_FONT_COLOR or ERROR_COLOR;
    local heldColor = (currencyInfo.maxQuantity and currencyInfo.quantity == currencyInfo.maxQuantity) and ERROR_COLOR or WHITE_FONT_COLOR

    if not private.DB.profile.CompactTooltips then
        local costLine = requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)) .. " / " .. heldColor:WrapTextInColorCode(BreakUpLargeNumbers(currencyInfo.quantity))

        table.insert(lines, {
            left = icon .. " " .. ColorManager.GetFormattedStringForItemQuality(currencyInfo.name, Enum.ItemQuality.Rare),
            right = costLine,
        })
    else
        table.insert(lines, {
            left = "",
            right = icon .. " " .. requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)),
        })
    end

    return lines;
end

--- Updates the tooltip parsing a Honor item
---@param tooltip GameTooltip
---@param upgradeCost number
---@param bonusId number
---@param bonusInfo HonorBonusData
local function HandleHonor(tooltip, upgradeCost, bonusId, bonusInfo)
    if not bonusId or not bonusInfo then
        private.Debug(bonusId, "or Honor bonus info table was not found");
        return
    end

    ---@type number
    local nextUpgradeCost = 0

    ---@type HonorBonusData?
    local nextUpgrade = nil

    ---@type HonorBonusData?
    local maxUpgrade = nil

    ---@type number
    local totalUpgradeCost = 0

    ---@type CurrencyInfo
    local currencyInfo = private.currencyInfo[private.currencyIds.Honor];

    for _, upgradeInfo in pairs(honorBonusIds) do
        if upgradeInfo.upgradeLevel > bonusInfo.upgradeLevel then
            if upgradeInfo.upgradeLevel == (bonusInfo.upgradeLevel + 1) then
                nextUpgrade = upgradeInfo

                nextUpgradeCost = upgradeCost
            end
            totalUpgradeCost = totalUpgradeCost + upgradeCost

            if not maxUpgrade or maxUpgrade.upgradeLevel < upgradeInfo.upgradeLevel then
                maxUpgrade = upgradeInfo
            end
        end
    end

    if nextUpgradeCost and nextUpgrade then
        local nextLevelLines = ParseUpgradeCost(nextUpgradeCost)
        local totalLines = ParseUpgradeCost(totalUpgradeCost)

        if #nextLevelLines > 0 or #totalLines > 0 then
            tooltip:AddLine("\n")
            tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["X_UPGRADES"]:format(currencyInfo.name), Enum.ItemQuality.Artifact))

            if nextLevelLines then
                if not private.DB.profile.CompactTooltips then
                    -- Standard tooltip
                    tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["COST_FOR_NEXT_LEVEL"] .. " (" .. nextUpgrade.itemLevel .. ")", Enum.ItemQuality.Heirloom))

                    for _, newLine in pairs(nextLevelLines) do
                        tooltip:AddDoubleLine(newLine.left, newLine.right)
                    end
                else
                    -- Compact tooltips
                    tooltip:AddDoubleLine(
                        WHITE_FONT_COLOR:WrapTextInColorCode(L["NEXT_UPGRADE_X"]:format(nextUpgrade.itemLevel)),
                        nextLevelLines[1].right
                    )
                end
            end

            if totalLines and maxUpgrade then
                if not private.DB.profile.CompactTooltips then
                    -- Standard tooltip
                    if nextLevelLines then
                        tooltip:AddLine("\n")
                    end

                    tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["COST_TO_UPGRADE_TO_MAX"] .. " (" .. maxUpgrade.itemLevel .. ")", Enum.ItemQuality.Heirloom))

                    for _, newLine in pairs(totalLines) do
                        tooltip:AddDoubleLine(newLine.left, newLine.right)
                    end
                else
                    -- Compact tooltips
                    tooltip:AddDoubleLine(
                        WHITE_FONT_COLOR:WrapTextInColorCode(L["MAX_UPGRADE_X"]:format(maxUpgrade.itemLevel)),
                        totalLines[1].right
                    )
                end
            end
        end
    else
        private.Debug("No next Honor upgrade cost could be found for provided item");
    end
end

--- Checks for Honor item and bonus IDs and chains call to HandleHonor if found
---@diagnostic disable: unused-local
---@param tooltip GameTooltip
---@param itemId number
---@param itemLink string
---@param currentUpgrade number
---@param maxUpgrade number
---@param bonusIds table<number, number>
---@return boolean
local function CheckHonorBonusIds(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds)
    if private.DB.profile.DisabledIntegrations.Honor then
        private.Debug("Honor integration is disabled");

        return false
    end

    local equipLoc = select(9, C_Item.GetItemInfo(itemLink))

    local upgradeCost = itemUpgradeCosts[equipLoc]
    if not upgradeCost then
        private.Debug(equipLoc, "was not found in the Honor upgrade cost table");
        return false
    end

    local upgradeCostOverride = itemUpgradeCostOverrides[equipLoc];
    if upgradeCostOverride then
        local stats = C_Item.GetItemStats(itemLink)
        if not stats then
            private.Debug("Could not extract Honor item stats from", itemLink);
            return false
        end
        local hasInt = (stats["ITEM_MOD_INTELLECT_SHORT"] and stats["ITEM_MOD_INTELLECT_SHORT"] > 0)
        if hasInt then
            upgradeCost = upgradeCostOverride
        end
    elseif equipLoc == "INVTYPE_TRINKET" then
        local trinketUpgradeCostOverride = trinketUpgradeCostOverrides[itemId];
        if trinketUpgradeCostOverride ~= nil then
            upgradeCost = trinketUpgradeCostOverride
        end
    end

    for i = 1, #bonusIds do
        private.Debug("Checking Honor bonus IDs for", bonusIds[i]);

        ---@type HonorBonusData?
        local bonusInfo = honorBonusIds[bonusIds[i]]
        if bonusInfo ~= nil then
            private.Debug(bonusIds[i], "matched an Honor bonus ID");
            HandleHonor(tooltip, upgradeCost, i, bonusInfo)
            return true
        end
    end

    private.Debug(itemId, "did not match an Honor bonus ID");
    return false
end

table.insert(private.upgradeHandlers, CheckHonorBonusIds)
