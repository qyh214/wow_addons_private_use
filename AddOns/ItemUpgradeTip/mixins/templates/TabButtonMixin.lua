ItemUpgradeTipTabButtonMixin = {}

function ItemUpgradeTipTabButtonMixin:OnShow()
    PanelTemplates_TabResize(self, 30, nil, 20)
    PanelTemplates_DeselectTab(self)
end

function ItemUpgradeTipTabButtonMixin:OnClick()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
    CallMethodOnNearestAncestor(self, "SetDisplayMode", self.displayMode)
end
