local AddonName, KeystoneLoot = ...;

KeystoneLootTeleportButtonMixin = {};

function KeystoneLootTeleportButtonMixin:OnLoad()
    self:Disable();
    self:RegisterForClicks("AnyUp", "AnyDown");
end

function KeystoneLootTeleportButtonMixin:Init(dungeon, texture)
    local teleportSpellId = dungeon.teleportSpellId;
    if (not teleportSpellId) then
        self.Icon:SetTexture(texture);
        self.Cooldown:Hide();
        self:Disable();
        return;
    end

    self.teleportSpellId = teleportSpellId;

    local spellInfo = C_Spell.GetSpellInfo(teleportSpellId);
    self.Icon:SetTexture(spellInfo.iconID);
    self:UpdateCooldown();

    if (InCombatLockdown()) then
        self:RegisterEvent("PLAYER_REGEN_ENABLED");
        return;
    end

    self:SetAttribute("type", "spell");
    self:SetAttribute("spell", teleportSpellId);
    self:Enable();
end

function KeystoneLootTeleportButtonMixin:OnEnter()
    if (not self:IsEnabled()) then
        return;
    end

    local teleportSpellId = self.teleportSpellId;

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetSpellByID(teleportSpellId);

    if (not IsSpellKnown(teleportSpellId)) then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(UNAVAILABLE, RED_FONT_COLOR:GetRGB());
    elseif (InCombatLockdown()) then
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(ERR_NOT_IN_COMBAT, RED_FONT_COLOR:GetRGB());
    end

    GameTooltip:Show();
    self.UpdateTooltip = self.OnEnter;
end

function KeystoneLootTeleportButtonMixin:OnLeave()
    if (not self:IsEnabled()) then
        return;
    end

    GameTooltip:Hide();
    self.UpdateTooltip = nil;
end

function KeystoneLootTeleportButtonMixin:PreClick(button, isDown)
    if (not self:IsEnabled()) then
        return;
    end

    if (isDown and InCombatLockdown()) then
        print(RED_FONT_COLOR:WrapTextInColorCode(ERR_NOT_IN_COMBAT));
    end
end

function KeystoneLootTeleportButtonMixin:OnEvent()
    self:UnregisterAllEvents();
    self:SetAttribute("type", "spell");
    self:SetAttribute("spell", self.teleportSpellId);
end

function KeystoneLootTeleportButtonMixin:UpdateCooldown()
    if (not self:IsEnabled()) then
        return;
    end

    local teleportSpellId = self.teleportSpellId;

    local isTeleportKnown = C_SpellBook.IsSpellInSpellBook(teleportSpellId);
    self.Error:SetShown(not isTeleportKnown);
    self.Icon:SetDesaturated(not isTeleportKnown);

    if (isTeleportKnown) then
        local spellCooldownInfo = C_Spell.GetSpellCooldown(teleportSpellId) or { startTime = 0, duration = 0, modRate = 0 };
        self.Cooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.modRate);
        self.Cooldown:Show();
    end
end
