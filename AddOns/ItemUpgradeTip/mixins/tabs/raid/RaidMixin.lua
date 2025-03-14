---@diagnostic disable: duplicate-set-field

local RAID_DATA_PROVIDER_LAYOUT = {
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_BOSS"],
        headerParameters = { "boss" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "boss" },
        width = 100,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_LFR"],
        headerParameters = { "lfrTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "lfrTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_NORMAL"],
        headerParameters = { "normalTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "normalTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_HEROIC"],
        headerParameters = { "heroicTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "heroicTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_MYTHIC"],
        headerParameters = { "mythicTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "mythicTier" },
    }
}

ItemUpgradeTipRaidDataProviderMixin = CreateFromMixins(ItemUpgradeTipDisplayDataProviderMixin)

function ItemUpgradeTipRaidDataProviderMixin:Refresh()
    self.onPreserveScroll()
    self:Reset()

    local results = {}
    local raidInfo = ItemUpgradeTip:GetRaidInfo();
    local raidCurrencyInfo = ItemUpgradeTip:GetRaidCurrencyInfo();

    for index, bossInfo in ipairs(raidInfo) do
        local bossData = {
            boss = bossInfo.boss,
            lfrTier = bossInfo.lfr,
            normalTier = bossInfo.normal,
            heroicTier = bossInfo.heroic,
            mythicTier = bossInfo.mythic,
            index = index,
            selected = self:IsSelected(index),
        }

        table.insert(results, bossData)
    end

    local lfrIcon = raidCurrencyInfo.lfrCurrency.icon and CreateTextureMarkup(raidCurrencyInfo.lfrCurrency.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""
    local normalIcon = raidCurrencyInfo.normalCurrency.icon and CreateTextureMarkup(raidCurrencyInfo.normalCurrency.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""
    local heroicIcon = raidCurrencyInfo.heroicCurrency.icon and CreateTextureMarkup(raidCurrencyInfo.heroicCurrency.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""
    local mythicIcon = raidCurrencyInfo.mythicCurrency.icon and CreateTextureMarkup(raidCurrencyInfo.mythicCurrency.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

    local raidCurrencyData = {
        boss = _G["ITEMUPGRADETIP_L_CREST_TYPE"],
        lfrTier = lfrIcon .. " " .. raidCurrencyInfo.lfrCurrency.color:WrapTextInColorCode(raidCurrencyInfo.lfrCurrency.shortName),
        normalTier = normalIcon .. " " .. raidCurrencyInfo.normalCurrency.color:WrapTextInColorCode(raidCurrencyInfo.normalCurrency.shortName),
        heroicTier = heroicIcon .. " " .. raidCurrencyInfo.heroicCurrency.color:WrapTextInColorCode(raidCurrencyInfo.heroicCurrency.shortName),
        mythicTier = mythicIcon .. " " .. raidCurrencyInfo.mythicCurrency.color:WrapTextInColorCode(raidCurrencyInfo.mythicCurrency.shortName),

        lfrTierCurrencyId = raidCurrencyInfo.lfrCurrency.currencyId,
        normalTierCurrencyId = raidCurrencyInfo.normalCurrency.currencyId,
        heroicTierCurrencyId = raidCurrencyInfo.heroicCurrency.currencyId,
        mythicTierCurrencyId = raidCurrencyInfo.mythicCurrency.currencyId,
    }

    table.insert(results, raidCurrencyData)

    self:AppendEntries(results)
end

function ItemUpgradeTipRaidDataProviderMixin:GetColumnHideStates()
    return {}
end

function ItemUpgradeTipRaidDataProviderMixin:GetTableLayout()
    return RAID_DATA_PROVIDER_LAYOUT
end

function ItemUpgradeTipRaidDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipRaidRowTemplate"
end
