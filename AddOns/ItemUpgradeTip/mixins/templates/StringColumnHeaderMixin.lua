ItemUpgradeTipStringColumnHeaderTemplateMixin = CreateFromMixins(TableBuilderElementMixin)

function ItemUpgradeTipStringColumnHeaderTemplateMixin:Init(name, tooltipText)
    self.tooltipText = tooltipText
    self:SetText(name)
end

function ItemUpgradeTipStringColumnHeaderTemplateMixin:OnLoad()
    ItemUpgradeTip:AddSkinnableFrame("NavBarButton", self)
end

function ItemUpgradeTipStringColumnHeaderTemplateMixin:OnMouseUp(button, ...)
end

-- Implementing mouse events for tooltip
function ItemUpgradeTipStringColumnHeaderTemplateMixin:OnEnter()
    if self.tooltipText then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_AddColoredLine(GameTooltip, self.tooltipText, WHITE_FONT_COLOR, true)
        GameTooltip:Show()
    end
end

function ItemUpgradeTipStringColumnHeaderTemplateMixin:OnLeave()
    GameTooltip:Hide()
end
