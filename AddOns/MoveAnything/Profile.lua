local _G = _G
local pairs = pairs
local string = string
local table = table
local type = type

local MovAny = _G.MovAny
local MOVANY = _G.MOVANY

StaticPopupDialogs["MOVEANYTHING_PROFILE_RESET_CONFIRM"] = {
	text = MOVANY.PROFILE_RESET_CONFIRM,
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		MovAny:ResetProfile()
	end,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["MOVEANYTHING_PROFILE_ADD"] = {
	text = MOVANY.PROFILE_ADD_TEXT,
	button1 = TEXT(MOVANY.ADD),
	button2 = TEXT(CANCEL),
	OnShow = function(self)
		self.editBox:SetScript("OnEnterPressed", function()
			if MovAny:AddProfile(self.editBox:GetText()) then
				StaticPopup_Hide("MOVEANYTHING_PROFILE_ADD")
			end
		end)
		self.editBox:SetScript("OnEscapePressed", function()
			StaticPopup_Hide("MOVEANYTHING_PROFILE_ADD")
		end)
	end,
	OnAccept = function(self)
		if not MovAny:AddProfile(self.editBox:GetText()) then
			StaticPopup_Show("MOVEANYTHING_PROFILE_ADD")
		end
	end,
	hasEditBox = true,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["MOVEANYTHING_PROFILE_RENAME"] = {
	text = MOVANY.PROFILE_RENAME_TEXT,
	button1 = TEXT(MOVANY.RENAME),
	button2 = TEXT(CANCEL),
	OnShow = function(self)
		self.pn = MovAny:GetProfileName()
		self.editBox:SetScript("OnEnterPressed", function()
			if self.pn == self.editBox:GetText() or MovAny:RenameProfile(self.pn, self.editBox:GetText()) then
				StaticPopup_Hide("MOVEANYTHING_PROFILE_RENAME")
			end
		end)
		self.editBox:SetScript("OnEscapePressed", function()
			StaticPopup_Hide("MOVEANYTHING_PROFILE_RENAME")
		end)
	end,
	OnAccept = function(self)
		if self.pn ~= self.editBox:GetText() and not MovAny:RenameProfile(self.pn, self.editBox:GetText()) then
			StaticPopup_Show("MOVEANYTHING_PROFILE_RENAME")
		end
	end,
	hasEditBox = true,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["MOVEANYTHING_PROFILE_SAVE_AS"] = {
	text = MOVANY.PROFILE_SAVE_AS_TEXT,
	button1 = TEXT(MOVANY.SAVE),
	button2 = TEXT(CANCEL),
	OnShow = function(self)
		self.pn = MovAny:GetProfileName()
		self.editBox:SetScript("OnEnterPressed", function()
			if MovAny:CopyProfile(self.pn, self.editBox:GetText()) then
				StaticPopup_Hide("MOVEANYTHING_PROFILE_SAVE_AS")
			end
		end)
		self.editBox:SetScript("OnEscapePressed", function()
			StaticPopup_Hide("MOVEANYTHING_PROFILE_SAVE_AS")
		end)
	end,
	OnAccept = function(self)
		if not MovAny:CopyProfile(self.pn, self.editBox:GetText()) then
			StaticPopup_Show("MOVEANYTHING_PROFILE_SAVE_AS")
		end
	end,
	hasEditBox = true,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["MOVEANYTHING_PROFILE_DELETE"] = {
	text = MOVANY.PROFILE_DELETE_TEXT,
	button1 = TEXT(MOVANY.DELETE),
	button2 = TEXT(CANCEL),
	OnAccept = function(self)
		MovAny:DeleteProfile(MovAny:GetProfileName())
	end,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

function MovAny:ResetProfile(readOnly)
	local f
	for i, v in pairs(self.userData) do
		f = _G[i]
		if f and f.MAHooked then
			self:ResetFrame(i, true, true)
		end
	end
	self.API:ClearElementsUserData()
	self:ReanchorRelatives()
	if not readOnly then
		table.wipe(self.userData)
		MADB.profiles[self:GetProfileName()].frames = self.userData
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:GetProfileName()
	local char = MADB.characters[self:GetCharacterIndex()]
	if char and char.profile then
		return char.profile
	else
		return "default"
	end
end

function MovAny:CopyProfile(fromName, toName)
	if fromName == toName then
		return
	end
	if MADB.profiles[toName] == nil then
		self:AddProfile(toName, true)
	end
	local l, vm, e
	local curProfileName = self:GetProfileName()
	for i, val in pairs(MADB.profiles[fromName].frames) do
		l = MA_tcopy(val)
		l.cat = nil
		data = self.lVirtualMovers[i]
		if data and data.excludes then
			MADB.profiles[toName].frames[data.excludes] = nil
		end

		if toName == curProfileName then
			e = self.API:GetElement(i)
			if e then
				e:SetUserData(l)
			end
		end

		MADB.profiles[toName].frames[i] = l
	end
	return true
end

function MovAny:AddProfile(pn, silent, dontUpdate)
	if MADB.profiles[pn] then
		if not silent then
			maPrint(string.format(MOVANY.PROFILE_ALREADY_EXISTS, pn))
		end
		return
	end
	MADB.profiles[pn] = {name = pn, frames = {}}

	if not dontUpdate then
		MovAny_OptionsOnShow()
	end
	return true
end

function MovAny:DeleteProfile(pn)
	if pn == "default" then
		maPrint(string.format(MOVANY.PROFILE_CANT_DELETE_DEFAULT, pn))
		return
	end
	local current
	if self:GetProfileName() == pn then
		self:ResetProfile()
		current = true
	end

	MADB.profiles[pn] = nil
	for name, char in pairs(MADB.characters) do
		if char and char.profile == pn then
			char.profile = nil
		end
	end
	if current then
		self.userData = MADB.profiles[self:GetProfileName()].frames

		local e
		for i, v in pairs(self.userData) do
			e = self.API:GetElement(i)
			if e then
				e:SetUserData(v)
			end
		end

		self:SyncAllFrames(true)
		self:UpdateGUIIfShown(true)
	end
	MovAny_OptionsOnShow()
	return true
end

function MovAny:RenameProfile(pn, nn)
	if pn == nn or nn == "default" or nn == "" then
		return
	end
	local p = MADB.profiles[pn]
	if type(p) ~= "table" then
		return
	end
	p.name = nn
	MADB.profiles[nn] = p
	MADB.profiles[pn] = nil
	for i, v in pairs(MADB.characters) do
		if v.profile == pn then
			v.profile = nn
		end
	end
	MovAny_OptionsOnShow()
	return true
end

function MovAny:UpdateProfile()
	if self.userData then
		self:ResetProfile(true)
		self.API:ClearElementsUserData()
	end
	self.userData = MADB.profiles[self:GetProfileName()].frames

	local e
	for i, v in pairs(self.userData) do
		e = self.API:GetElement(i)
		if e then
			e:SetUserData(v)
		end
	end
	self:SyncAllFrames(true)
	self:UpdateGUIIfShown(true)
end

function MovAny:ChangeProfile(profile)
	self:ResetProfile(true)
	local char = MADB.characters[self:GetCharacterIndex()]
	if not char then
		char = { }
		MADB.characters[self:GetCharacterIndex()] = char
	end
	char.profile = profile ~= "default" and profile or nil
	self.userData = MADB.profiles[self:GetProfileName()].frames
	local e, f
	for i, v in pairs(self.userData) do
		e = self.API:GetElement(i)
		if e then
			e.SetUserData(v)
		else
			e = self.API:AddElementIfNew(i)
		end
	end
	self:SyncAllFrames(true)
	self:UpdateGUIIfShown(true)
end

function MovAny:CleanProfile(pn)
	local p = MADB.profiles[pn]
	if type(p) == "table" and type(p.frames) == "table" then
		local f
		for i, v in pairs(p.frames) do
			f = _G[i]
			if f and f.IsUserPlaced and f:IsUserPlaced() and (f:IsMovable() or f:IsResizable()) then
				if f:IsUserPlaced() then
					if not f.MAWasUserPlaced then
						f:SetUserPlaced(nil)
					else
						f.MAWasUserPlaced = nil
					end
				end
				if f:IsMovable() then
					if not f.MAWasMovable then
						f:SetMovable(nil)
					else
						f.MAWasMovable = nil
					end
				end
				if f:IsResizable() then
					if not f.MAWasResizable then
						f:SetResizable(nil)
					else
						f.MAWasResizable = nil
					end
				end
			end
			v.ignoreFramePositionManager = nil
			v.cat = nil
			v.orgScale = nil
			v.orgAlpha = nil
			v.orgPos = nil
			v.MANAGED_FRAME = nil
			v.UIPanelWindows = nil
		end
	end
end