---@diagnostic disable: duplicate-set-field

local MYTHICPLUS_DATA_PROVIDER_LAYOUT = {
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_KEY_LEVEL"],
        headerParameters = { "keyLevel" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "keyLevel" },
        width = 100,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_LOOT_DROPS"],
        headerParameters = { "lootDrops" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "lootDrops" },
        width = 100,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_VAULT_REWARD"],
        headerParameters = { "vaultReward" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "vaultReward" },
        width = 100,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_CREST_TYPE"],
        headerParameters = { "crestReward" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "crestReward" }
    }
}

ItemUpgradeTipMythicPlusDataProviderMixin = CreateFromMixins(ItemUpgradeTipDisplayDataProviderMixin)

function ItemUpgradeTipMythicPlusDataProviderMixin:Refresh()
    self.onPreserveScroll()
    self:Reset()

    local results = {}

    for index, mPlusKey in ipairs(ItemUpgradeTip:GetMythicPlusInfo()) do
        local currencyInfo = ItemUpgradeTip:GetCurrencyInfo(mPlusKey.currency.currencyId)
        local icon = currencyInfo.iconFileID and CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

        local keyRange = {
            keyLevel = mPlusKey.keyLevel,
            lootDrops = mPlusKey.lootDrops,
            vaultReward = mPlusKey.vaultReward,
            crestReward = icon .. " " .. mPlusKey.currency.colorData.color:WrapTextInColorCode(currencyInfo.name),
            index = index,
            selected = self:IsSelected(index),
            crestRewardCurrencyId = mPlusKey.currency.currencyId
        }

        table.insert(results, keyRange)
    end
    self:AppendEntries(results)
end

function ItemUpgradeTipMythicPlusDataProviderMixin:GetColumnHideStates()
    return {}
end

function ItemUpgradeTipMythicPlusDataProviderMixin:GetTableLayout()
    return MYTHICPLUS_DATA_PROVIDER_LAYOUT
end

function ItemUpgradeTipMythicPlusDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipMythicPlusRowTemplate"
end
