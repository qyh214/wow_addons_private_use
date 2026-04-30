local _, Addon = ...;

function Addon:ShowTextFrame(title)
	Addon.isLocked = true;
	Addon:UpdatePanelButton();
	Addon.frame.TextPopupFrame.Header:Setup(title);
	Addon.frame.TextPopupFrame:Show();
end

function Addon:ShowDataImportFrame()
	Addon.frame.TextPopupFrame.Main.ScrollFrame.ScrollText:SetText("");
	Addon.frame.TextPopupFrame.Main.ImportButton:Show();
	Addon.frame.TextPopupFrame.Main.CancelButton:Show();
	Addon.frame.TextPopupFrame.Main.CloseButton:Hide();
	Addon:ShowTextFrame("Import");
end

function Addon:ShowDataExportFrame()
	Addon.frame.TextPopupFrame.Main.ImportButton:Hide();
	Addon.frame.TextPopupFrame.Main.CancelButton:Hide();
	Addon.frame.TextPopupFrame.Main.CloseButton:Show();

	local text = Addon:GetSpecDataText();
	Addon.frame.TextPopupFrame.Main.ScrollFrame.ScrollText:SetText(text);
	Addon.frame.TextPopupFrame.Main.ScrollFrame.ScrollText:HighlightText();
	Addon:ShowTextFrame("Export");
end

function Addon:ShowPresetFrame()
	Addon.isLocked = true;
	Addon:UpdatePanelButton();
	Addon.frame.PresetPopupFrame:Show();
end

function Addon:InitPanelButtons()
	Addon.frame.ImportButton:SetScript("OnClick", function() Addon:ShowDataImportFrame(); end);
	Addon.frame.ExportButton:SetScript("OnClick", function() Addon:ShowDataExportFrame(); end);
	Addon.frame.PresetButton:SetScript("OnClick", function() Addon:ShowPresetFrame(); end);
	Addon.frame.LoadButton:SetScript("OnClick", function() Addon:LoadConfig(); end);
	Addon.frame.SaveButton:SetScript("OnClick", function() Addon:ShowConfirmSavePopup(); end);
	Addon.frame.EditButton:SetScript("OnClick", function() Addon:ShowEditPopup(); end);
	Addon.frame.DeleteButton:SetScript("OnClick", function() Addon:ShowConfirmDeletePopup(); end);
	Addon.frame.UpButton:SetScript("OnClick", function() Addon:MoveUp(); end);
	Addon.frame.DownButton:SetScript("OnClick", function() Addon:MoveDown(); end);
end

function Addon:InitTextPopupFrame()
	Addon.frame.TextPopupFrame:SetScript(
		"OnHide",
		function()
			Addon.isLocked = false;
			Addon:UpdatePanelButton();
		end
	);

	Addon.frame.TextPopupFrame.Main.ImportButton:SetScript(
		"OnClick",
		function()
			local text = Addon.frame.TextPopupFrame.Main.ScrollFrame.ScrollText:GetText();
			Addon:ImportDataText(text);
			Addon:UpdateScrollBox(true);
			Addon.frame.TextPopupFrame:Hide();
		end
	);

	Addon.frame.TextPopupFrame.Main.ImportButton:SetEnabled(true);
	Addon.frame.TextPopupFrame.Main.CancelButton:SetEnabled(true);
	Addon.frame.TextPopupFrame.Main.CloseButton:SetEnabled(true);
end

function Addon:InitPresetPopupFrame()
	Addon.frame.PresetPopupFrame:SetScript(
		"OnHide",
		function()
			Addon.isLocked = false;
			Addon:UpdatePanelButton();
		end
	);

	local option = TalentLoadoutEx.Option.Preset;
	local mainFrame = Addon.frame.PresetPopupFrame.Main;

	local combineCheckButton = mainFrame.CombineCheckButton;
	combineCheckButton:SetChecked(option.isCombineGroups);
	combineCheckButton:SetScript(
		"OnClick",
		function(button)
			option.isCombineGroups = button:GetChecked();
			Addon:UpdateScrollBox(true);
		end
	);

	for _, presetFrame in ipairs(mainFrame.PresetAddons) do
		local presetAddonOptions = option[presetFrame.addonName];
		for _, checkButton in ipairs(presetFrame.CategoryCheckButtons) do
			local category = checkButton.category;
			checkButton:SetChecked(presetAddonOptions[category]);
			checkButton:SetScript(
				"OnClick",
				function(button)
					presetAddonOptions[category] = button:GetChecked();
					Addon:UpdateScrollBox(true);
				end
			);
		end
	end
end

function Addon:UpdatePanelButton()
	Addon.frame.ImportButton:SetEnabled(false);
	Addon.frame.ExportButton:SetEnabled(false);
	Addon.frame.PresetButton:SetEnabled(false);
	Addon.frame.LoadButton:SetEnabled(false);
	Addon.frame.SaveButton:SetEnabled(false);
	Addon.frame.EditButton:SetEnabled(false);
	Addon.frame.DeleteButton:SetEnabled(false);
	Addon.frame.UpButton:SetEnabled(false);
	Addon.frame.DownButton:SetEnabled(false);

	if Addon.isLocked then
		return;
	end

	Addon.frame.ImportButton:SetEnabled(true);
	Addon.frame.ExportButton:SetEnabled(true);
	Addon.frame.PresetButton:SetEnabled(true);

	local data = Addon:GetData();
	if data then
		if not data.isPreset then
			Addon.frame.EditButton:SetEnabled(true);
			Addon.frame.DeleteButton:SetEnabled(true);
			Addon.frame.UpButton:SetEnabled(true);
			Addon.frame.DownButton:SetEnabled(true);
		end

		if data.text then
			Addon.frame.LoadButton:SetEnabled(true);
			if not data.isPreset then
				Addon.frame.SaveButton:SetEnabled(true);
			end
		end
	end
end

local function IsParentDragged()
	if Addon.isParentDragged then
		return Addon.isParentDragged;
	end

	if Addon:IsAddOnLoaded("BlizzMove") then
		local blizzMove = LibStub("AceAddon-3.0"):GetAddon("BlizzMove");
		local frameData = blizzMove and blizzMove["FrameData"] or {};
		for frame, data in pairs(frameData) do
			if frame == Addon.ParentFrame then
				local points = data.storage.points;
				Addon.isParentDragged = points and points.dragged or false;
				return Addon.isParentDragged;
			end
		end
	end
	
	return false;
end

local function SetMoveParentFrame()
	local parent = Addon.ParentFrame
	hooksecurefunc(
		parent,
		"Show",
		function(self)
			if not InCombatLockdown() and not IsParentDragged() then
				self:AdjustPointsOffset(Addon.frame:GetWidth() / -2, 0);
			end
		end
	);
end

local function InitPvpFrame()
	local checkButton = Addon.frame.PvpFrame.CheckButton;
	checkButton:SetChecked(TalentLoadoutEx.Option.IsEnabledPvp);
	checkButton:SetScript(
		"OnClick",
		function(self)
			TalentLoadoutEx.Option.IsEnabledPvp = self:GetChecked();
			Addon:UpdateScrollBox(true);
		end
	);
end

local function InitInspectImportButton()
	local parent = PlayerSpellsFrame.TalentsFrame;
	local copyButton = parent.InspectCopyButton;
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonNoTooltipTemplate");
	button:SetPoint("BOTTOM", copyButton, "TOP");
	button:SetTextToFit("Talent Loadout Ex: Import");
	button:SetWidth(copyButton:GetWidth());
	button:SetScript(
		"OnClick",
		function()
			Addon:InspectImport();
		end
	);

	button:Show();
	return button;
end

local function SetShown()
	local talentsFrame = Addon.TalentsFrame;
	local isShown = talentsFrame:IsShown() and talentsFrame.ApplyButton:IsShown();
	Addon.ApplyButton.isShown = isShown;

	if isShown then
		Addon:UpdateScrollBox();
	end

	Addon.frame:SetShown(isShown);
	Addon.InspectImportButton:SetShown(not isShown);
end

Addon.ApplyButton = {};
Addon.ApplyButton.isShown = false;
Addon.ApplyButton.isEnabled = false;
function Addon:InitFrame()
	Addon.ParentFrame = PlayerSpellsFrame;
	Addon.frame = CreateFrame("Frame", "TalentLoadoutExMainFrame", Addon.ParentFrame, "TalentLoadoutExMainFrameTemplate");
	Addon.InspectImportButton = InitInspectImportButton();
	SetMoveParentFrame();
	InitPvpFrame();

	Addon.TalentsFrame = Addon.ParentFrame.TalentsFrame;
	hooksecurefunc(Addon.TalentsFrame, "SetShown", SetShown);
	hooksecurefunc(Addon.TalentsFrame.ApplyButton, "SetShown", SetShown);

	hooksecurefunc(
		Addon.TalentsFrame.ApplyButton,
		"SetEnabled",
		function(_, enabled)
			Addon.ApplyButton.isEnabled = enabled;
		end
	);

	Addon:InitPanelButtons();
	Addon:InitTextPopupFrame();
	Addon:InitPresetPopupFrame();
	Addon:InitScrollBox();

	Addon:UpdateScrollBox(true);
	Addon:RegisterUpdateEvent();

	Addon:InitIconSelector();
	Addon:RegisterAddonLoad("LargerMacroIconSelection", false, "InitIconSearcher");
	Addon:RegisterAddonLoad("LargerMacroIconSelectionData", false, "AddIconSelectionData");
end
