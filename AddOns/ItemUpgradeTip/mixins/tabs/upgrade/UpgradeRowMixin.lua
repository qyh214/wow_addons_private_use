---@diagnostic disable: duplicate-set-field
ItemUpgradeTipUpgradeRowMixin = CreateFromMixins(ItemUpgradeTipResultsRowTemplateMixin)

ItemUpgradeTipUpgradeRowMixin.Populate = ItemUpgradeTipTableResultsRowMixin.Populate
ItemUpgradeTipUpgradeRowMixin.OnClick = ItemUpgradeTipTableResultsRowMixin.OnClick

function ItemUpgradeTipUpgradeRowMixin:OnHide()
end
