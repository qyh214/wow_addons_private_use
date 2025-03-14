ItemUpgradeTipInfoDisplayMixin = {}

function ItemUpgradeTipInfoDisplayMixin:OnLoad()
    ItemUpgradeTip:AddSkinnableFrame("InsetFrame", self.Inset)
end

function ItemUpgradeTipInfoDisplayMixin:OnShow()
end

function ItemUpgradeTipInfoDisplayMixin:OnHide()
end
