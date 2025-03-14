---@diagnostic disable: duplicate-set-field

local UPGRADE_DATA_PROVIDER_LAYOUT = {
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_ITEM_LEVEL"],
        headerParameters = { "ilvl" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "ilvl" },
        width = 85,
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_UPGRADE_TRACK_ADVENTURER"],
        headerParameters = { "adventurerTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "adventurerTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_UPGRADE_TRACK_VETERAN"],
        headerParameters = { "veteranTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "veteranTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_UPGRADE_TRACK_CHAMPION"],
        headerParameters = { "championTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "championTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_UPGRADE_TRACK_HERO"],
        headerParameters = { "heroTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "heroTier" },
    },
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_UPGRADE_TRACK_MYTH"],
        headerParameters = { "mythTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "mythTier" },
    },
    --[[
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_UPGRADE_TRACK_AWAKENED"],
        headerParameters = { "awakenedTier" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "awakenedTier" },
    },
    ]]
    {
        headerTemplate = "ItemUpgradeTipStringColumnHeaderTemplate",
        headerText = _G["ITEMUPGRADETIP_L_CREST_TYPE"],
        headerParameters = { "crestType" },
        cellTemplate = "ItemUpgradeTipStringCellTemplate",
        cellParameters = { "crestType" },
        width = 150
    },
}

ItemUpgradeTipUpgradeDataProviderMixin = CreateFromMixins(ItemUpgradeTipDisplayDataProviderMixin)

function ItemUpgradeTipUpgradeDataProviderMixin:Refresh()
    self.onPreserveScroll()
    self:Reset()

    local results = {}
    local UPGRADE_TIER_FORMAT_STRING = "%d/%d"

    for index, upgradeTrack in ipairs(ItemUpgradeTip:GetUpgradeTrackInfo()) do
        local icon = upgradeTrack.currency.icon and CreateTextureMarkup(upgradeTrack.currency.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

        local rank1 = upgradeTrack.upgrade1.rank
        local rank2 = nil
        local rank3 = nil
        local rank4 = nil

        local upgradeTierString1 = UPGRADE_TIER_FORMAT_STRING:format(upgradeTrack.upgrade1.upgradeLevel, upgradeTrack.upgrade1.maxUpgradeLevel)
        local upgradeTierString2 = nil
        local upgradeTierString3 = nil
        local upgradeTierString4 = nil

        if upgradeTrack.upgrade2 ~= nil then
            rank2 = upgradeTrack.upgrade2.rank
            upgradeTierString2 = UPGRADE_TIER_FORMAT_STRING:format(upgradeTrack.upgrade2.upgradeLevel, upgradeTrack.upgrade2.maxUpgradeLevel)
        end

        if upgradeTrack.upgrade3 ~= nil then
            rank3 = upgradeTrack.upgrade3.rank
            upgradeTierString3 = UPGRADE_TIER_FORMAT_STRING:format(upgradeTrack.upgrade3.upgradeLevel, upgradeTrack.upgrade3.maxUpgradeLevel)
        end

        if upgradeTrack.upgrade4 ~= nil then
            rank4 = upgradeTrack.upgrade4.rank
            upgradeTierString4 = UPGRADE_TIER_FORMAT_STRING:format(upgradeTrack.upgrade4.upgradeLevel, upgradeTrack.upgrade4.maxUpgradeLevel)
        end

        local upgradeInfo = {
            ilvl = upgradeTrack.itemLevel,
            crestType = icon .. " " .. upgradeTrack.currency.color:WrapTextInColorCode(upgradeTrack.currency.name),
            adventurerTier = (rank1 == 2 and upgradeTierString1) or (rank2 == 2 and upgradeTierString2) or (rank3 == 2 and upgradeTierString3) or (rank4 == 2 and upgradeTierString4) or "",
            veteranTier = (rank1 == 3 and upgradeTierString1) or (rank2 == 3 and upgradeTierString2) or (rank3 == 3 and upgradeTierString3) or (rank4 == 3 and upgradeTierString4) or "",
            championTier = (rank1 == 4 and upgradeTierString1) or (rank2 == 4 and upgradeTierString2) or (rank3 == 4 and upgradeTierString3) or (rank4 == 4 and upgradeTierString4) or "",
            heroTier = (rank1 == 5 and upgradeTierString1) or (rank2 == 5 and upgradeTierString2) or (rank3 == 5 and upgradeTierString3) or (rank4 == 5 and upgradeTierString4) or "",
            mythTier = (rank1 == 6 and upgradeTierString1) or (rank2 == 6 and upgradeTierString2) or (rank3 == 6 and upgradeTierString3) or (rank4 == 6 and upgradeTierString4) or "",
            --awakenedTier = ((rank1 == 7 or rank1 == 8) and upgradeTierString1) or ((rank2 == 7 or rank2 == 8) and upgradeTierString2) or ((rank3 == 7 or rank3 == 8) and upgradeTierString3) or ((rank4 == 7 or rank4 == 8) and upgradeTierString4) or "",
            index = index,
            selected = self:IsSelected(index),
            crestTypeCurrencyId = upgradeTrack.currency.currencyId
        }

        table.insert(results, upgradeInfo)
    end

    self:AppendEntries(results)
end

function ItemUpgradeTipUpgradeDataProviderMixin:GetColumnHideStates()
    return {}
end

function ItemUpgradeTipUpgradeDataProviderMixin:GetTableLayout()
    return UPGRADE_DATA_PROVIDER_LAYOUT
end

function ItemUpgradeTipUpgradeDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipUpgradeRowTemplate"
end
