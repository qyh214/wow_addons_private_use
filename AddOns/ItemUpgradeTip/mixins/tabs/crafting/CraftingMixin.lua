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
        headerText = _G["ITEMUPGRADETIP_L_CREST_TYPE"],
        headerParameters = { "crestsRequired" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "crestsRequired" }
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
            local itemIcon = craftingInfo.iconPath and CreateAtlasMarkupWithAtlasSize(craftingInfo.iconPath, 0, 0, nil, nil, nil, 0.66) or ""

            local currencyInfo = ItemUpgradeTip:GetCurrencyInfo(craftingInfo.currency.currencyId)
            local currencyIcon = currencyInfo.iconFileID and CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""
            local crestsRequired = _G["ITEMUPGRADETIP_L_X_REQUIRED_Y"]:format(
                craftingInfo.currencyAmount,
                currencyIcon .. " " .. craftingInfo.currency.colorData.color:WrapTextInColorCode(currencyInfo.name)
            )

            crafting = {
                itemLevel = craftingInfo.itemLevel,
                rank = itemIcon or UPGRADE_TIER_FORMAT_STRING:format(craftingInfo.rank, 5),
                index = index,
                selected = self:IsSelected(index),
                crestsRequired = crestsRequired,
                crestsRequiredCurrencyId = craftingInfo.currency and craftingInfo.currency.currencyId or nil,
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
