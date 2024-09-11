local AddonName, KeystoneLoot = ...;

local _buttons = {};
local _lastParent;


local OverviewFrame = KeystoneLoot:GetOverview();

local TooltipFrame = CreateFrame('Frame', nil, OverviewFrame);
OverviewFrame.TooltipFrame = TooltipFrame;
TooltipFrame:Hide();
TooltipFrame:SetToplevel(true);
TooltipFrame:SetFrameStrata('FULLSCREEN_DIALOG');

local Background = TooltipFrame:CreateTexture(nil, 'BACKGROUND');
Background:SetAtlas('common-dropdown-bg');
Background:SetPoint('TOPLEFT', -1, 1);
Background:SetPoint('BOTTOMRIGHT', 1, -7);
Background:SetAlpha(0.925);


local function ListButton_OnEnter(self)
	self.Background:Show();
end

local function ListButton_OnLeave(self)
	self.Background:Hide();
end

local function ListButton_OnClick(self)
	local info = self.info;

	if (type(info.args) == 'table') then
		info.func(unpack(info.args));
	else
		info.func(info.args);
	end

	TooltipFrame:Hide();

	if (info.keepShownOnClick) then
		local _, parent = TooltipFrame:GetPoint();
		KeystoneLoot:ToggleDropDown(parent);
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

local function CreateListButton(i)
	local Button = CreateFrame('Button', nil, TooltipFrame);
	Button:SetSize(180, 18);
	Button:SetScript('OnEnter', ListButton_OnEnter);
	Button:SetScript('OnLeave', ListButton_OnLeave);
	Button:SetScript('OnClick', ListButton_OnClick);

	if (i == 1) then
		Button:SetPoint('TOPLEFT', 15, -10);
		Button:SetPoint('TOPRIGHT', -15, -10);
	else
		Button:SetPoint('TOPLEFT', _buttons[i - 1], 'BOTTOMLEFT');
		Button:SetPoint('TOPRIGHT', _buttons[i - 1], 'BOTTOMRIGHT');
	end

	local Background = Button:CreateTexture(nil, 'BACKGROUND');
	Button.Background = Background;
	Background:Hide();
	Background:SetAllPoints();
	Background:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight');
	Background:SetBlendMode('ADD');
	Background:SetVertexColor(0.8, 0.6, 0, 1);

	local Ticksquare = Button:CreateTexture(nil, 'ARTWORK', nil, 0);
	Button.Ticksquare = Ticksquare;
	Ticksquare:SetSize(13, 13);
	Ticksquare:SetPoint('LEFT');
	Ticksquare:SetAtlas('common-dropdown-ticksquare');

	local Checkmark = Button:CreateTexture(nil, 'ARTWORK', nil, 1);
	Button.Checkmark = Checkmark;
	Checkmark:SetSize(13, 13);
	Checkmark:SetPoint('CENTER', Ticksquare, 2, 1);
	Checkmark:SetAtlas('common-dropdown-icon-checkmark-yellow');

	local Divider = Button:CreateTexture(nil, 'BACKGROUND');
	Button.Divider = Divider;
	Divider:SetAllPoints();
	Divider:SetTexture('Interface\\Common\\UI-TooltipDivider-Transparent');

	local Text = Button:CreateFontString('ARTWORK', nil, 'GameFontHighlightSmallLeft');
	Button.Text = Text;
	Text:SetWordWrap(false);
	Text:SetPoint('LEFT', Ticksquare, 'RIGHT', 4, -1);

	table.insert(_buttons, Button);

	return Button;
end


function KeystoneLoot:ToggleDropDown(parent)
	if (TooltipFrame:IsShown()) then
		if (parent ~= _lastParent) then
			_lastParent = parent;

			TooltipFrame:Hide();
			self:ToggleDropDown(parent);
			return;
		end

		TooltipFrame:Hide();
	else
		_lastParent = parent;

		local numButtons = 0;
		local dropdownWidth = 0;
		local dropdownHeight = 0;
		local _list = parent:GetList() or {};

		if (#_list == 0) then
			_list = {{
				text = EMPTY,
				checked = false,
				notCheckable = true,
				hasGrayColor = true,
				disabled = true
			}};
		end

		for i, info in next, _list do
			if (info.disabled == nil) then
				info.disabled = false;
			end
			if (info.hasGrayColor == nil) then
				info.hasGrayColor = false;
			end

			local Button = _buttons[i] or CreateListButton(i);
			Button:Show();

			local Ticksquare = Button.Ticksquare;
			local Checkmark = Button.Checkmark;
			local Divider = Button.Divider;
			local Text = Button.Text;

			local leftPadding = 0;

			if (info.divider) then
				Button:Disable();
				Button:SetHeight(8);
				Ticksquare:Hide();
				Checkmark:Hide();
				Divider:Show();
				Text:SetText('');

				dropdownHeight = dropdownHeight + 8;
			else
				Button:SetHeight(18);
				Ticksquare:Show();
				Divider:Hide();
				Text:SetText(info.text);

				Button:SetEnabled(not info.disabled);

				if (info.hasGrayColor) then
					Button.Text:SetFontObject('GameFontDisableSmallLeft');
				else
					Button.Text:SetFontObject('GameFontHighlightSmallLeft');
				end

				if (info.checked) then
					Checkmark:Show();
				else
					Checkmark:Hide();
				end

				if (info.notCheckable) then
					Ticksquare:SetAlpha(0);
					leftPadding = leftPadding - 17;
					Checkmark:Hide();
				else
					Ticksquare:SetAlpha(1);
				end

				if (info.leftPadding) then
					leftPadding = leftPadding + info.leftPadding;
				end

				Ticksquare:SetPoint('LEFT', leftPadding, 0);

				dropdownHeight = dropdownHeight + 18;
			end

			Button.info = info;

			dropdownWidth = math.max(dropdownWidth, Button.Text:GetWidth() + leftPadding);
			numButtons = numButtons + 1;
		end

		for i=(numButtons + 1), #_buttons do
			local Button = _buttons[i];
			Button:Hide();
		end

		TooltipFrame:SetSize(dropdownWidth + 50, dropdownHeight + 20);
		TooltipFrame:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', -10, 2);
		TooltipFrame:Show();
	end
end