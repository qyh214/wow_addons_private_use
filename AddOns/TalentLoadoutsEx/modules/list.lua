local _, Addon = ...;

Addon.addDataType = {
	AddConfig = "Add Config",
	AddGroup = "Add Group",
};

local function OnClickToggleButton(toggleButton)
	if not Addon.isLocked then
		local parent = toggleButton:GetParent();
		parent.data.isExpanded = not parent.data.isExpanded;
		Addon.selectedIndex = parent.index;
		Addon:RequestUpdate();
	end
end

local function OnClickListButton(self, button)
	if Addon.isLocked then
		return;
	end

	if not self.addDataType then
		Addon.selectedIndex = self.index;
	end

	Addon.frame.ScrollBox:ForEachFrame(
		function(linkButton)
			if Addon.selectedIndex and Addon.selectedIndex == linkButton.index then
				linkButton.SelectedBar:Show();
			else
				linkButton.SelectedBar:Hide();
			end
		end
	);

	Addon:UpdatePanelButton();

	if self.addDataType then
		Addon:ShowEditPopup(self.addDataType);
	elseif IsShiftKeyDown() then
		if button == "LeftButton" then
			Addon:PostLink();
		else
			Addon:CopyLink();
		end
	end
end

local function OnDoubleClickListButton(button, ...)
	if Addon.isLocked then
		return;
	end

	Addon.selectedIndex = button.index;
	if button.addDataType then
		return;
	elseif button.data.text then
		Addon:LoadConfig();
	else
		OnClickToggleButton(button.ToggleButton);
	end
end

local function InitListButton(button, elementData)
	button.index = elementData.index;
	button.data = elementData.data;
	button.addDataType = elementData.addDataType;

	-- Reset
	button.GroupStripe:Hide();
	button.PresetStripe:Hide();
	button.Check:Hide();
	button.WarningFrame:Hide();
	button.ToggleButton:Hide();
	button.SelectedBar:Hide();

	local talentsFrame = Addon.TalentsFrame;
	local treeInfo = talentsFrame:GetTreeInfo();
	local treeID = treeInfo and treeInfo.ID;
	if not treeID then
		return; -- Skip
	end

	local color = NORMAL_FONT_COLOR;
	if button.addDataType then
		-- Add Button
		button.Icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
		button.Icon:SetSize(30, 30);
		button.Icon:SetPoint("LEFT", 7, 0);
		color = GREEN_FONT_COLOR;
	else
		-- Config or Group
		button.Icon:SetSize(36, 36);
		button.Icon:SetPoint("LEFT", 4, 0);

		if type(button.data.icon) == "string" then
			button.Icon:SetTexture(Addon.HERO_TALENTS_ICON);
			button.Icon:SetAtlas(button.data.icon);
		else
			button.Icon:SetTexture(button.data.icon);
		end

		if not button.data.text then
			-- Group
			if button.data.isPreset then
				button.PresetStripe:Show();
			else
				button.GroupStripe:Show();
			end

			button.ToggleButton:SetScript("OnClick", OnClickToggleButton);
			button.ToggleButton.isExpanded = button.data.isExpanded;
			button.ToggleButton:Show();
			color = BLUE_FONT_COLOR;
		elseif button.data.isLegacy then
			-- Config (Legacy)
			button.WarningMessage = Addon.LegacyWarningMessage;
			button.WarningFrame:Show();
		else
			-- Config
			local importStream = ExportUtil.MakeImportDataStream(button.data.text);
			local errorMessage = Addon:GetValidationError(treeID, importStream);

			if button.data.isInGroup then
				button.Icon:AdjustPointsOffset(10, 0);
			end

			if errorMessage then
				button.WarningMessage = errorMessage;
				button.WarningFrame:Show();
			elseif Addon:IsDataLoaded(button.data) then
				button.Check:Show();
			end
		end
	end

	button.Text:SetText(button.addDataType or button.data.name);
	button.Text:SetTextColor(color.r, color.g, color.b);

	button:SetScript("OnClick", OnClickListButton);
	button:SetScript("OnDoubleClick", OnDoubleClickListButton);
	if Addon.selectedIndex and Addon.selectedIndex == button.index then
		button.SelectedBar:Show();
	end
end

function Addon:InitScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("TalentLoadoutExListButtonTemplate", InitListButton)
	view:SetPadding(0,0,3,0,2);
	ScrollUtil.InitScrollBoxListWithScrollBar(Addon.frame.ScrollBox, Addon.frame.ScrollBar, view);
end

local function InitDataProvider()
	local dataProvider = CreateDataProvider();

	local isVisible = true;
	local isInGroup = false;
	for index, data in ipairs(Addon:MergeTables(Addon:GetSpecTable(), Addon:GetPresetData())) do
		if data.text then
			-- Config
			if isVisible then
				data.isInGroup = isInGroup;
				dataProvider:Insert({index = index, data = data});
			elseif Addon.selectedIndex and Addon.selectedIndex == index then
				Addon.selectedIndex = nil;
			end
		else
			-- Group
			dataProvider:Insert({index = index, data = data});
			isVisible = data.isExpanded;
			isInGroup = true;
		end
	end

	dataProvider:Insert({addDataType = Addon.addDataType.AddConfig});
	dataProvider:Insert({addDataType = Addon.addDataType.AddGroup});

	return dataProvider;
end

local function UpdateDataProvider()
	local scrollBox = Addon.frame.ScrollBox;

	local newDataProvider = InitDataProvider();

	local oldDataProvider = scrollBox:GetDataProvider();
	if not oldDataProvider then
		scrollBox:SetDataProvider(newDataProvider);
		return;
	end

	local scrollPercentage = 0;
	local indexDiff = scrollBox:GetDataIndexEnd() - scrollBox:GetDataIndexBegin();
	scrollPercentage = scrollBox:GetScrollPercentage() * (#oldDataProvider.collection - indexDiff) / (#newDataProvider.collection - indexDiff);

	local scrollTarget = scrollBox:GetScrollTarget();
	local scrollTargetOffset = select(5, scrollTarget:GetPoint(1));

	scrollBox:SetDataProvider(newDataProvider);

	if scrollPercentage > 0 then
		scrollBox:SetScrollPercentage(scrollPercentage);
	end

	if scrollTargetOffset > 0 then
		scrollBox:SetScrollTargetOffset(scrollTargetOffset);
	end
end

function Addon:UpdateScrollBox()
	UpdateDataProvider();
	Addon:UpdatePanelButton();
	Addon:SendUpdateMessage();
end

local updateDelay = 0.1;
local lastRequestTime = nil;
function Addon:RequestUpdate()
	local now = GetTime();
	if lastRequestTime and now - lastRequestTime < updateDelay then
		return; -- Skip
	end

	lastRequestTime = now;
	C_Timer.After(
		updateDelay,
		function()
			Addon:UpdateScrollBox();
		end
	);
end

function Addon:RegisterUpdateEvent()
	Addon.frame:RegisterEvent("PLAYER_REGEN_ENABLED");
	Addon.frame:RegisterEvent("PLAYER_REGEN_DISABLED");
	Addon.frame:RegisterEvent("TRAIT_NODE_CHANGED");
	Addon.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	Addon.frame:SetScript(
		"OnEvent",
		function(_, event)
			if event == "PLAYER_REGEN_ENABLED" then
				Addon:Unlock();
			elseif event == "PLAYER_REGEN_DISABLED" then
				Addon:Lock();
				Addon:HideAllPopup();
				Addon:HideEditPopup();
			else
				Addon:RequestUpdate();
			end
		end
	);

	local parent = Addon.frame:GetParent();
	Addon.frame:GetParent():HookScript(
		"OnShow",
		function()
			Addon:RequestUpdate();
		end
	);
end
