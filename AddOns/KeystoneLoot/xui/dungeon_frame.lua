local AddonName, KeystoneLoot = ...;

local function Teleport_OnEnter(self)
	local teleportSpellId = self:GetParent().teleportSpellId;

	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
	GameTooltip:SetSpellByID(teleportSpellId);

	if (not IsSpellKnown(teleportSpellId)) then
		GameTooltip:AddLine(' ');
		GameTooltip:AddLine(UNAVAILABLE, RED_FONT_COLOR:GetRGB());
	end

	GameTooltip:Show();
end

local function Teleport_OnLeave(self)
	GameTooltip:Hide();
end

local function Teleport_PreCast(self, key, isDown)
	if (isDown and InCombatLockdown()) then
		print(RED_FONT_COLOR:WrapTextInColorCode(ERR_NOT_IN_COMBAT));
	end
end

local function CreateTeleportButton(parent)
	local TeleportButton = CreateFrame('Button', nil, parent, 'InsecureActionButtonTemplate');
	parent.TeleportButton = TeleportButton;
	TeleportButton:Hide();
	TeleportButton:RegisterForClicks('AnyUp', 'AnyDown');
	TeleportButton:SetSize(19, 19);
	TeleportButton:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', 0, 3);
	TeleportButton.UpdateTooltip = Teleport_OnEnter;
	TeleportButton:SetScript('OnEnter', Teleport_OnEnter);
	TeleportButton:SetScript('OnLeave', Teleport_OnLeave);
	TeleportButton:SetScript('PreClick', Teleport_PreCast);
	TeleportButton:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress');
	TeleportButton:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square', 'ADD');

	local TeleportCooldown = CreateFrame('Cooldown', nil, TeleportButton, 'CooldownFrameTemplate');
	TeleportButton.Cooldown = TeleportCooldown;
	TeleportCooldown:SetAllPoints();

	local Icon = TeleportButton:CreateTexture(nil, 'ARTWORK', nil, 1);
	TeleportButton.Icon = Icon;
	Icon:SetAllPoints();
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);

	local IconBorder = TeleportButton:CreateTexture(nil, 'ARTWORK', nil, 2);
	IconBorder:SetSize(34, 34);
	IconBorder:SetPoint('CENTER', Icon);
	IconBorder:SetTexture('Interface\\Buttons\\UI-Quickslot2');

	local NoTeleportTexture = TeleportButton:CreateTexture(nil, 'ARTWORK', nil, 3);
	TeleportButton.NoTeleportTexture = NoTeleportTexture;
	NoTeleportTexture:SetSize(22, 22);
	NoTeleportTexture:SetPoint('CENTER');
	NoTeleportTexture:SetTexture('Interface\\Buttons\\UI-GroupLoot-Pass-Up');

	return TeleportButton;
end

function KeystoneLoot:CreateDungeonFrame(parent)
	local Frame = CreateFrame('Frame', nil, parent, 'InsetFrameTemplate');
	Frame:SetSize(180, 90);

	local FrameBg = Frame.Bg;
	FrameBg:SetHorizTile(false);
	FrameBg:SetVertTile(false);
	FrameBg:SetTexCoord(5/256, 169/256, 5/128, 91/128);

	local Title = Frame:CreateFontString('ARTWORK', nil, 'GameFontDisableLarge');
	Frame.Title = Title;
	Title:SetMaxLines(1);
	Title:SetWidth(156);
	Title:SetJustifyH('LEFT');
	Title:SetPoint('BOTTOMLEFT', Frame, 'TOPLEFT', 0, 5);
	Title = Mixin(Title, AutoScalingFontStringMixin);

	Frame.itemFrames = {};
	for index=1, 8 do
		local ItemButton = self:CreateItemButton(Frame);

		if (index == 1) then
			ItemButton:SetPoint('TOPLEFT', 11, -10);
		elseif (mod(index, 4) == 1) then
			ItemButton:SetPoint('TOP', Frame.itemFrames[index - 4], 'BOTTOM', 0, -8);
		else
			ItemButton:SetPoint('LEFT', Frame.itemFrames[index - 1], 'RIGHT', 10, 0);
		end

		table.insert(Frame.itemFrames, ItemButton);
	end

	function Frame:SetDisabled(isDisabled)
		self.Title:SetTextColor((isDisabled and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR):GetRGB());
		self.Bg:SetDesaturated(isDisabled);
		self:SetAlpha(isDisabled and 0.8 or 1);
	end

	function Frame:UpdateTeleport()
		if (InCombatLockdown()) then
			return;
		end

		local TeleportButton = self.TeleportButton or CreateTeleportButton(self);
		local teleportSpellId = self.teleportSpellId;

		if (not self.initTeleport) then
			local spellInfo = C_Spell.GetSpellInfo(teleportSpellId);
			TeleportButton.Icon:SetTexture(spellInfo.iconID);

			TeleportButton:SetAttribute('type', 'spell');
			TeleportButton:SetAttribute('spell', teleportSpellId);
			TeleportButton:Show();
			self.initTeleport = true;
		end

		local isTeleportKnown = IsSpellKnown(teleportSpellId);
		TeleportButton.NoTeleportTexture:SetShown(not isTeleportKnown);
		TeleportButton.Icon:SetShown(isTeleportKnown);
		TeleportButton:SetAlpha(isTeleportKnown and 1 or 0.7);

		if (isTeleportKnown) then
			local spellCooldownInfo = C_Spell.GetSpellCooldown(teleportSpellId) or { startTime = 0, duration = 0, isEnabled = false, modRate = 0 };
			local start, duration, enable, modRate = spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;

			TeleportButton.Cooldown:SetCooldown(start, duration, modRate);
		end
	end

	function Frame:SetItems(itemList)
		for index, ItemButton in next, self.itemFrames do
			local itemInfo = itemList[index];
			if (itemInfo) then
				ItemButton.itemId = itemInfo.itemId;
				ItemButton.specId = itemInfo.specId;

				ItemButton.Icon:SetTexture(itemInfo.icon);
				ItemButton:UpdateFavoriteStarIcon();
				ItemButton:UpdateOtherSpecIcon();
				ItemButton:UpdateStatVisibility();
				ItemButton:Show();
			else
				ItemButton:Hide();
			end
		end

		self:SetDisabled(#itemList == 0);
	end

	return Frame;
end
