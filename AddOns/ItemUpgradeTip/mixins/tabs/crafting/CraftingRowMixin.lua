---@diagnostic disable: duplicate-set-field
ItemUpgradeTipCraftingRowMixin = CreateFromMixins(ItemUpgradeTipResultsRowTemplateMixin)

ItemUpgradeTipCraftingRowMixin.Populate = ItemUpgradeTipTableResultsRowMixin.Populate
ItemUpgradeTipCraftingRowMixin.OnClick = ItemUpgradeTipTableResultsRowMixin.OnClick

function ItemUpgradeTipCraftingRowMixin:OnHide()
end
