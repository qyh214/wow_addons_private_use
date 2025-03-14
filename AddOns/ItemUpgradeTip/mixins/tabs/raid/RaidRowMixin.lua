---@diagnostic disable: duplicate-set-field
ItemUpgradeTipRaidRowMixin = CreateFromMixins(ItemUpgradeTipResultsRowTemplateMixin)

ItemUpgradeTipRaidRowMixin.Populate = ItemUpgradeTipTableResultsRowMixin.Populate
ItemUpgradeTipRaidRowMixin.OnClick = ItemUpgradeTipTableResultsRowMixin.OnClick

function ItemUpgradeTipRaidRowMixin:OnHide()
end
