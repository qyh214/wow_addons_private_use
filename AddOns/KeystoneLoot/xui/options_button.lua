local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;


local function OnClick(self)
	KeystoneLoot:ToggleDropDown(self);

	self.GlowArrow:Hide();
	KeystoneLootDB.showNewText = false;

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

local function OnMouseDown(self)
	self.GearTexture:SetPoint('CENTER', 1, -1);
	self.HighlightTexture:SetPoint('CENTER', 1, -1);
end

local function OnMouseUp(self)
	self.GearTexture:SetPoint('CENTER');
	self.HighlightTexture:SetPoint('CENTER');
end

local function OnShow(self)
	self.GlowArrow:SetShown(KeystoneLootDB.showNewText);
end

local OverviewFrame = KeystoneLoot:GetOverview();

local Button = CreateFrame('Button', nil, OverviewFrame);
OverviewFrame.OptionsButton = Button;
Button:SetSize(18, 18);
Button:SetFrameLevel(510);
Button:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
Button:SetPoint('TOPRIGHT', -28, -3);
Button:SetScript('OnShow', OnShow);
Button:SetScript('OnClick', OnClick);
Button:SetScript('OnMouseDown', OnMouseDown);
Button:SetScript('OnMouseUp', OnMouseUp);

local GearTexture = Button:CreateTexture(nil, 'ARTWORK');
Button.GearTexture = GearTexture;
GearTexture:SetPoint('CENTER');
GearTexture:SetAtlas('questlog-icon-setting', true);

local HighlightTexture = Button:CreateTexture(nil, 'HIGHLIGHT');
Button.HighlightTexture = HighlightTexture;
HighlightTexture:SetPoint('CENTER');
HighlightTexture:SetAtlas('questlog-icon-setting', true);
HighlightTexture:SetBlendMode('ADD');
HighlightTexture:SetAlpha(0.4);

local GlowArrow = CreateFrame('Frame', 'KeystoneLootGlowArrow', OverviewFrame, 'GlowBoxArrowTemplate');
Button.GlowArrow = GlowArrow;
GlowArrow:SetFrameLevel(510);
GlowArrow:SetPoint('TOP', Button,'BOTTOM', 7, -5);
GlowArrow.Arrow:SetSize(40, 16);
GlowArrow.Arrow:SetRotation(math.rad(180));
GlowArrow.Glow:Hide();
GlowArrow:Hide();

local NewText = GlowArrow:CreateFontString('ARTWORK', nil, 'GameFontNormal');
NewText:SetPoint('TOP', GlowArrow,'BOTTOM', -6, 0);
NewText:SetSize(40, 10);
NewText:SetJustifyH('CENTER');
NewText:SetText(NEW:upper());

function Button:GetList()
	local _list = {};

	local info = {};
	info.text = NORMAL_FONT_COLOR:WrapTextInColorCode(SETTINGS_TITLE);
	info.checked = false;
	info.notCheckable = true;
	info.disabled = true;
	table.insert(_list, info);

	local info = {};
	info.text = Translate['Enable Minimap Button'];
	info.checked = KeystoneLootDB.minimapButtonEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootDB.minimapButtonEnabled;
	info.func = function (enable)
		KeystoneLootDB.minimapButtonEnabled = enable;
		KeystoneLoot:UpdateMinimapButton();
	end;
	table.insert(_list, info);

	local info = {};
	info.text = Translate['Favorites Show All Specializations'];
	info.checked = KeystoneLootDB.favoritesShowAllSpecs;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootDB.favoritesShowAllSpecs;
	info.func = function (enable)
		KeystoneLootDB.favoritesShowAllSpecs = enable;

		KeystoneLoot:GetCurrentTab():Update();
	end;
	table.insert(_list, info);

	local info = {};
	info.text = Translate['Show Item Level In Keystone Tooltip'];
	info.checked = KeystoneLootDB.keystoneItemLevelEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootDB.keystoneItemLevelEnabled;
	info.func = function (enable)
		KeystoneLootDB.keystoneItemLevelEnabled = enable;
	end;
	table.insert(_list, info);

	local info = {};
	info.text = NORMAL_FONT_COLOR:WrapTextInColorCode(DUNGEONS);
	info.checked = false;
	info.notCheckable = true;
	info.disabled = true;
	table.insert(_list, info);

	local info = {};
	info.text = Translate['Enable Loot Reminder'];
	info.checked = KeystoneLootDB.lootReminderEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootDB.lootReminderEnabled;
	info.func = function (enable)
		KeystoneLootDB.lootReminderEnabled = enable;
	end;
	table.insert(_list, info);

	local info = {};
	info.text = NORMAL_FONT_COLOR:WrapTextInColorCode(RAIDS);
	info.checked = false;
	info.notCheckable = true;
	info.disabled = true;
	table.insert(_list, info);

	local info = {};
	info.text = Translate['Enable Loot Reminder'];
	info.checked = KeystoneLootDB.raidLootReminderEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootDB.raidLootReminderEnabled;
	info.func = function (enable)
		KeystoneLootDB.raidLootReminderEnabled = enable;
	end;
	table.insert(_list, info);

	local info = {};
	info.text = YELLOW_FONT_COLOR:WrapTextInColorCode(NEW:upper())..' '..NORMAL_FONT_COLOR:WrapTextInColorCode(Translate['Highlighting']); -- TODO: -NEU- Später wieder entfernen.
	info.checked = false;
	info.notCheckable = true;
	info.disabled = true;
	table.insert(_list, info);

	local info = {};
	info.text = ITEM_MOD_CRIT_RATING_SHORT;
	info.checked = KeystoneLootCharDB.statHighlightingCritEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootCharDB.statHighlightingCritEnabled;
	info.func = function (enable)
		KeystoneLootCharDB.statHighlightingCritEnabled = enable;

		KeystoneLoot:GetCurrentTab():Update();
	end;
	table.insert(_list, info);

	local info = {};
	info.text = ITEM_MOD_HASTE_RATING_SHORT;
	info.checked = KeystoneLootCharDB.statHighlightingHasteEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootCharDB.statHighlightingHasteEnabled;
	info.func = function (enable)
		KeystoneLootCharDB.statHighlightingHasteEnabled = enable;

		KeystoneLoot:GetCurrentTab():Update();
	end;
	table.insert(_list, info);

	local info = {};
	info.text = ITEM_MOD_MASTERY_RATING_SHORT;
	info.checked = KeystoneLootCharDB.statHighlightingMasteryEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootCharDB.statHighlightingMasteryEnabled;
	info.func = function (enable)
		KeystoneLootCharDB.statHighlightingMasteryEnabled = enable;

		KeystoneLoot:GetCurrentTab():Update();
	end;
	table.insert(_list, info);

	local info = {};
	info.text = ITEM_MOD_VERSATILITY;
	info.checked = KeystoneLootCharDB.statHighlightingVersatilityEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootCharDB.statHighlightingVersatilityEnabled;
	info.func = function (enable)
		KeystoneLootCharDB.statHighlightingVersatilityEnabled = enable;

		KeystoneLoot:GetCurrentTab():Update();
	end;
	table.insert(_list, info);

	local info = {};
	info.text = Translate['No Stats'];
	info.checked = KeystoneLootCharDB.statHighlightingNoStatsEnabled;
	info.keepShownOnClick = true;
	info.args = not KeystoneLootCharDB.statHighlightingNoStatsEnabled;
	info.func = function (enable)
		KeystoneLootCharDB.statHighlightingNoStatsEnabled = enable;

		KeystoneLoot:GetCurrentTab():Update();
	end;
	table.insert(_list, info);

	return _list;
end