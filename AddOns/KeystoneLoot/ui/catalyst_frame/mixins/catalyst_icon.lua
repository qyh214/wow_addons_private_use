local AddonName, KeystoneLoot = ...;

local L = KeystoneLoot.L;

KeystoneLootCatalystIconMixin = {};

function KeystoneLootCatalystIconMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["The Catalyst"], HIGHLIGHT_FONT_COLOR:GetRGB());
    GameTooltip:Show();
end

function KeystoneLootCatalystIconMixin:OnLeave()
    GameTooltip:Hide();
end
