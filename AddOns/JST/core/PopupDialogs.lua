local T, C, L, G = unpack(select(2, ...))

StaticPopupDialogs[G.addon_name.."Reset Positions Confirm"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Import Confirm"] = {
	text = L["导入确认"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Cannot Import"] = {
	text = L["无法导入"],
	button1 = ACCEPT,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Nickname Input"] = {
	text = L["输入昵称"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 5,
	hasEditBox = true,
}

StaticPopupDialogs[G.addon_name.."Reload Alert"] = {
	text = L["重载界面后生效"],
	button1 = RELOADUI,
	button2 = L["稍后重载"],
	OnAccept = ReloadUI,
	showAlert = 1,
}

StaticPopupDialogs[G.addon_name.."Reset Confirm"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Accept Settings Confirm"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[G.addon_name.."Group Nickname Input"] = {
	text = L["输入队友昵称"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 5,
	hasEditBox = true,
}