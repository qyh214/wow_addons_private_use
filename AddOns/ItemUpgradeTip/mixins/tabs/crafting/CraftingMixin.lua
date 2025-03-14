---@diagnostic disable: duplicate-set-field

local CRAFTING_DATA_PROVIDER_LAYOUT = {
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_ITEM_LEVEL"],
        headerParameters = { "itemLevel" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "itemLevel" },
        width = 85,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_RANK"],
        headerParameters = { "rank" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "rank" },
        width = 50,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_REQUIRED_ITEM"],
        headerParameters = { "itemNamePretty" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "itemNamePretty" },
    }
}

ItemUpgradeTipCraftingDataProviderMixin = CreateFromMixins(ItemUpgradeTipDisplayDataProviderMixin)

function ItemUpgradeTipCraftingDataProviderMixin:Refresh()
    self.onPreserveScroll()
    self:Reset()

    local results = {}
    local UPGRADE_TIER_FORMAT_STRING = "%d/%d"

    for index, craftingInfo in ipairs(ItemUpgradeTip:GetCraftingInfo()) do
        local crafting = {}
        if craftingInfo.itemLevel > 0 then
            local icon = craftingInfo.iconPath and CreateAtlasMarkupWithAtlasSize(craftingInfo.iconPath, 0, 0, nil, nil, nil, 0.66) or ""

            crafting = {
                itemLevel = craftingInfo.itemLevel,
                rank = icon or UPGRADE_TIER_FORMAT_STRING:format(craftingInfo.rank, 5),
                index = index,
                selected = self:IsSelected(index),
                itemId = craftingInfo.itemId,
                itemNamePrettyItemId = craftingInfo.itemId,
            }
        else
            crafting = {
                itemLevel = "",
                rank = "",
                index = index,
                selected = self:IsSelected(index),
            }
        end

        table.insert(results, crafting)
    end
    self:AppendEntries(results)
end

function ItemUpgradeTipCraftingDataProviderMixin:GetColumnHideStates()
    return {}
end

function ItemUpgradeTipCraftingDataProviderMixin:GetTableLayout()
    return CRAFTING_DATA_PROVIDER_LAYOUT
end

function ItemUpgradeTipCraftingDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipCraftingRowTemplate"
end
