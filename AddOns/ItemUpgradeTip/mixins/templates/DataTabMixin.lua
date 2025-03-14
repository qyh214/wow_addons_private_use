ItemUpgradeTipDataTabDisplayMixin = {}

function ItemUpgradeTipDataTabDisplayMixin:OnLoad()
    self.ResultsListing:Init(self.DataProvider)

    ItemUpgradeTip:AddSkinnableFrame("InsetFrame", self.ResultsListingInset)
end
