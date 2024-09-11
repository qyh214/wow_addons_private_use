local AddonName, KeystoneLoot = ...;

local _tabs = {};


local function UpdateSize()
	local ChildrenFrame = KeystoneLoot:GetCurrentRaidTab();
	local TabFrame = ChildrenFrame.Tab;

	PanelTemplates_TabResize(TabFrame);

	local numTabs = #_tabs;
	local availableWidth = ChildrenFrame:GetWidth() - TabFrame:GetWidth() - 44;
	local widthPerTab = availableWidth / (numTabs - 1);

	for _, Tab in next, _tabs do
		if (Tab.id ~= TabFrame.id) then
			PanelTemplates_TabResize(Tab, 0, widthPerTab);
		end
	end
end

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
	local ChildrenFrame = KeystoneLoot:GetCurrentRaidTab();

	table.sort(_tabs, function (a, b)
		return a.order < b.order;
	end);

	for index, Tab in next, _tabs do
		if (index == 1) then
			Tab:SetPoint('TOPLEFT', ChildrenFrame, 18, -70);
		else
			Tab:SetPoint('TOPLEFT', _tabs[index - 1], 'TOPRIGHT', 3, 0);
		end
	end
end

local function OnClick(self, button)
	SetTab(self.id);

	KeystoneLoot:GetCurrentTab():Update();
	KeystoneLoot:GetOverview().TooltipFrame:Hide();

	UpdateSize();

	PlaySound(SOUNDKIT.UI_TOYBOX_TABS);
end

local function CreateTab(id, order, name)
	local ChildrenFrame = KeystoneLoot:GetCurrentTab();

	local Tab = CreateFrame('Button', nil, ChildrenFrame, 'PanelTopTabButtonTemplate');
	Tab.id = id;
	Tab.order = order;
	Tab:SetScript('OnClick', OnClick);
	Tab:SetText(name);
	Tab:SetScript('OnShow', nil);

	local Children = CreateFrame('Frame', nil, ChildrenFrame);
	Children.id = id;
	Children.Tab = Tab;
	Children.UpdateSize = UpdateSize;
	Children:SetAllPoints();
	Tab.Children = Children;

	function Children:SetSize(...)
		OverviewFrame:SetSize(...);
	end

	table.insert(_tabs, Tab);

	UpdateTabs();

	return Children;
end

function KeystoneLoot:CreateRaidTab(id, ...)
	for index, Tab in next, _tabs do
		if (Tab.id == id) then
			return;
		end
	end

	local Children = CreateTab(id, ...);
	SetTab(_tabs[1].id);

	return Children;
end

function KeystoneLoot:GetCurrentRaidTab()
	for index, Tab in next, _tabs do
		if (Tab.Children:IsShown()) then
			return Tab.Children;
		end
	end
end
