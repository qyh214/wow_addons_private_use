local AddonName, KeystoneLoot           = ...;

KeystoneLootReminderEfficiencyIconMixin = {};

function KeystoneLootReminderEfficiencyIconMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_TOP");
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, 1, true);
    GameTooltip:Show();
end

function KeystoneLootReminderEfficiencyIconMixin:OnLeave()
    GameTooltip:Hide();
end
