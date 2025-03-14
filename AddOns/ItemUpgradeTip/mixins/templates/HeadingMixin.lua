ItemUpgradeTipHeadingMixin = {}

function ItemUpgradeTipHeadingMixin:OnLoad()
    if self.headingText ~= nil then
        self.HeadingText:SetText(self.headingText)
    end
end
