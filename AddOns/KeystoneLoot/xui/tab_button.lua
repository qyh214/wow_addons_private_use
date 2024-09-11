local AddonName, KeystoneLoot = ...;

local _tabs = {};


local function SetTab(id)
	for index, Tab in next, _tabs do
		if (Tab.id == id) then
			Tab.Children:Show();
			PanelTemplates_SelectTab(Tab);
		else
			Tab.Children:Hide();
			PanelTemplates_DeselectTab(Tab);
		end
	end
end

local function UpdateTabs()
	local OverviewFrame = KeystoneLoot:GetOverview();

	table.sort(_tabs, function (a, b)
		return a.order < b.order;
	end);

	local numTabs = #_tabs;
	for index, Tab in next, _tabs do
		if (index == 1) then
			Tab:SetPoint('TOPLEFT', OverviewFrame, 'BOTTOMLEFT', 11, 2);
		else
			Tab:SetPoint('TOPLEFT', _tabs[index - 1], 'TOPRIGHT', 3, 0);
		end

		if (numTabs == 1) then
			Tab:Hide();
		else
			PanelTemplates_TabResize(Tab);
			Tab:Show();
		end
	end
end

local function OnClick(self, button)
	SetTab(self.id);

	KeystoneLoot:GetOverview().TooltipFrame:Hide();

	PlaySound(SOUNDKIT.UI_TOYBOX_TABS);
end

local function CreateTab(id, order, name)
	local OverviewFrame = KeystoneLoot:GetOverview();

	local Tab = CreateFrame('Button', nil, OverviewFrame, 'PanelTabButtonTemplate');
	Tab.id = id;
	Tab.order = order;
	Tab:SetScript('OnClick', OnClick);
	Tab:SetText(name);

	local Children = CreateFrame('Frame', nil, OverviewFrame);
	Children.id = id;
	Children.Tab = Tab;
	Children:SetAllPoints();
	Tab.Children = Children;

	function Children:SetSize(...)
		OverviewFrame:SetSize(...);
	end

	table.insert(_tabs, Tab);

	UpdateTabs();

	return Children;
end

function KeystoneLoot:CreateTab(id, ...)
	for index, Tab in next, _tabs do
		if (Tab.id == id) then
			return;
		end
	end

	local Children = CreateTab(id, ...);
	SetTab(_tabs[1].id);

	return Children;
end

function KeystoneLoot:GetCurrentTab()
	for index, Tab in next, _tabs do
		if (Tab.Children:IsShown()) then
			return Tab.Children;
		end
	end
end
