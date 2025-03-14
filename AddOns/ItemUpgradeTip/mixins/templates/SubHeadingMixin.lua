ItemUpgradeTipSubHeadingMixin = {}

function ItemUpgradeTipSubHeadingMixin:InitializeSubHeading()
    if self.subHeadingText ~= nil then
        self.HeadingText:SetText(self.subHeadingText)
    end
end

function ItemUpgradeTipSubHeadingMixin:SetText(newHeading)
    self.subHeadingText = newHeading
    self:OnLoad()
end
