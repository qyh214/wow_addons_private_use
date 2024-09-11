local AddonName, KeystoneLoot = ...;




local function OnClick(self, button)
	KeystoneLoot:ToggleDropDown(self);

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function KeystoneLoot:CreateDropdownButton(parent)
	local Button = CreateFrame('Button', nil, parent, 'UIMenuButtonStretchTemplate');
	Button:SetSize(110, 24);
	Button:SetScript('OnClick', OnClick);

	local Icon = Button:CreateTexture(nil, 'ARTWORK');
	Button.Icon = Icon;
	Icon:SetSize(10, 12);
	Icon:SetPoint('RIGHT', -5, 0);
	Icon:SetTexture('Interface\\ChatFrame\\ChatFrameExpandArrow');

	local Text = Button.Text;
	Text:SetWordWrap(false);
	Text:SetJustifyH('LEFT');
	Text:SetPoint('LEFT', 8, 0);
	Text:SetPoint('RIGHT', Icon, 'LEFT', -2, 0);

	return Button;
end