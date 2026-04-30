local _, Addon = ...;

local StaticPopupDialogs = _G["StaticPopupDialogs"];

function Addon:HideAllPopup()
	StaticPopup_Hide("TalentLoadoutEx_COPY");
	StaticPopup_Hide("TalentLoadoutEx_CONFIRM_SAVE");
	StaticPopup_Hide("TalentLoadoutEx_CONFIRM_DELETE");
end

StaticPopupDialogs["TalentLoadoutEx_COPY"] = {
	text = "CTRL-C to copy",
	button1 = "Close",
	OnShow = function(dialog, data)
		local function HidePopup()
			dialog:Hide();
		end

		local editBox = dialog.EditBox;
		editBox:SetScript("OnEscapePressed", HidePopup);
		editBox:SetScript("OnEnterPressed", HidePopup);
		editBox:SetScript("OnKeyUp", function(_, key)
			if IsControlKeyDown() and key == "C" then
				HidePopup();
			end
		end);
		editBox:SetMaxLetters(0);
		editBox:SetText(data);
		editBox:HighlightText();
	end,
	hasEditBox = true,
	editBoxWidth = 240,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

function Addon:ShowCopyPopup(text)
	StaticPopup_Show("TalentLoadoutEx_COPY", nil, nil, text);
end

StaticPopupDialogs["TalentLoadoutEx_CONFIRM_SAVE"] = {
	text = 'Would you like to save the talent set "%s"?',
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		Addon:SaveConfig();
		Addon:UpdateScrollBox(true);
	end,
	OnShow = function() Addon:Lock() end,
	OnHide = function() Addon:Unlock() end,
};

function Addon:ShowConfirmSavePopup()
	local data = Addon:GetData();
	local name = data and data.name;
	if name then
		StaticPopup_Show("TalentLoadoutEx_CONFIRM_SAVE", name);
	end
end

StaticPopupDialogs["TalentLoadoutEx_CONFIRM_DELETE"] = {
	text = 'Are you sure you want to delete the %s "%s"?';
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		Addon:Unlock();
		Addon:DeleteData();
		Addon:UpdateScrollBox(true);
	end,
	OnShow = function() Addon:Lock() end,
	OnHide = function() Addon:Unlock() end,
};

function Addon:ShowConfirmDeletePopup()
	local data = Addon:GetData();
	local name = data and data.name;
	if name then
		StaticPopup_Show("TalentLoadoutEx_CONFIRM_DELETE", data.text and "talent set" or "group", name);
	end
end
