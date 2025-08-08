---@diagnostic disable: duplicate-set-field

local DELVES_DATA_PROVIDER_LAYOUT = {
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_TIER"],
        headerParameters = { "tier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "tier" },
        width = 100,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_LOOT_DROPS"],
        headerParameters = { "lootDrops" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "lootDrops" },
        width = 150,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_VAULT_REWARD"],
        headerParameters = { "vaultReward" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "vaultReward" },
        width = 150,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_CREST_TYPE"],
        headerParameters = { "crestReward" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "crestReward" }
    }
}

ItemUpgradeTipBountifulDelvesDataProviderMixin = CreateFromMixins(ItemUpgradeTipDisplayDataProviderMixin)

function ItemUpgradeTipBountifulDelvesDataProviderMixin:Refresh()
    self.onPreserveScroll()
    self:Reset()

    local results = {}

    for index, delveTier in ipairs(ItemUpgradeTip:GetBountifulDelvesInfo()) do
        local currencyInfo = ItemUpgradeTip:GetCurrencyInfo(delveTier.currency.currencyId)
        local icon = currencyInfo.iconFileID and CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

        local keyRange = {
            tier = delveTier.tier,
            lootDrops = _G["ITEMUPGRADETIP_L_DELVE_REWARD_X_Y"]:format(delveTier.loot.itemLevel, delveTier.loot.upgradeTrack),
            vaultReward = _G["ITEMUPGRADETIP_L_DELVE_REWARD_X_Y"]:format(delveTier.vault.itemLevel, delveTier.vault.upgradeTrack),
            crestReward = icon .. " " .. delveTier.currency.colorData.color:WrapTextInColorCode(currencyInfo.name),
            index = index,
            selected = self:IsSelected(index),
            crestRewardCurrencyId = delveTier.currency.currencyId
        }

        table.insert(results, keyRange)
    end
    self:AppendEntries(results)
end

function ItemUpgradeTipBountifulDelvesDataProviderMixin:GetColumnHideStates()
    return {}
end

function ItemUpgradeTipBountifulDelvesDataProviderMixin:GetTableLayout()
    return DELVES_DATA_PROVIDER_LAYOUT
end

function ItemUpgradeTipBountifulDelvesDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipBountifulDelvesRowTemplate"
end
