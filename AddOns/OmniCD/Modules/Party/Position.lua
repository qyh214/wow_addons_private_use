local E = select(2, ...):unpack()
local P = E.Party

LibStub("AceHook-3.0"):Embed(P)

local isColdStartDC = true

local COMPACT_RAID = {
	"CompactRaidFrame1", "CompactRaidFrame2", "CompactRaidFrame3", "CompactRaidFrame4", "CompactRaidFrame5",
	"CompactRaidFrame6", "CompactRaidFrame7", "CompactRaidFrame8", "CompactRaidFrame9", "CompactRaidFrame10",
	"CompactRaidFrame11", "CompactRaidFrame12", "CompactRaidFrame13", "CompactRaidFrame14", "CompactRaidFrame15",
	"CompactRaidFrame16", "CompactRaidFrame17", "CompactRaidFrame18", "CompactRaidFrame19", "CompactRaidFrame20",
	"CompactRaidFrame21", "CompactRaidFrame22", "CompactRaidFrame23", "CompactRaidFrame24", "CompactRaidFrame25",
	"CompactRaidFrame26", "CompactRaidFrame27", "CompactRaidFrame28", "CompactRaidFrame29", "CompactRaidFrame30",
	"CompactRaidFrame31", "CompactRaidFrame32", "CompactRaidFrame33", "CompactRaidFrame34", "CompactRaidFrame35",
	"CompactRaidFrame36", "CompactRaidFrame37", "CompactRaidFrame38", "CompactRaidFrame39", "CompactRaidFrame40",
	"CompactRaidFrame41", "CompactRaidFrame42", "CompactRaidFrame43", "CompactRaidFrame44", "CompactRaidFrame45",
	"CompactRaidFrame46", "CompactRaidFrame47", "CompactRaidFrame48", "CompactRaidFrame49", "CompactRaidFrame50",
}

local COMPACT_RAID_KGT = {
	"CompactRaidGroup1Member1", "CompactRaidGroup1Member2", "CompactRaidGroup1Member3", "CompactRaidGroup1Member4", "CompactRaidGroup1Member5",
	"CompactRaidGroup2Member1", "CompactRaidGroup2Member2", "CompactRaidGroup2Member3", "CompactRaidGroup2Member4", "CompactRaidGroup2Member5",
	"CompactRaidGroup3Member1", "CompactRaidGroup3Member2", "CompactRaidGroup3Member3", "CompactRaidGroup3Member4", "CompactRaidGroup3Member5",
	"CompactRaidGroup4Member1", "CompactRaidGroup4Member2", "CompactRaidGroup4Member3", "CompactRaidGroup4Member4", "CompactRaidGroup4Member5",
	"CompactRaidGroup5Member1", "CompactRaidGroup5Member2", "CompactRaidGroup5Member3", "CompactRaidGroup5Member4", "CompactRaidGroup5Member5",
	"CompactRaidGroup6Member1", "CompactRaidGroup6Member2", "CompactRaidGroup6Member3", "CompactRaidGroup6Member4", "CompactRaidGroup6Member5",
	"CompactRaidGroup7Member1", "CompactRaidGroup7Member2", "CompactRaidGroup7Member3", "CompactRaidGroup7Member4", "CompactRaidGroup7Member5",
	"CompactRaidGroup8Member1", "CompactRaidGroup8Member2", "CompactRaidGroup8Member3", "CompactRaidGroup8Member4", "CompactRaidGroup8Member5",
}

local COMPACT_PARTY = {
	"CompactPartyFrameMember1", "CompactPartyFrameMember2", "CompactPartyFrameMember3", "CompactPartyFrameMember4", "CompactPartyFrameMember5",
}

local PARTY_FRAME = {
	"PartyMemberFrame1", "PartyMemberFrame2", "PartyMemberFrame3", "PartyMemberFrame4",
}

function P:CompactFrameIsActive(isInRaid)
	return (isInRaid or IsInRaid()) and not self.isInArena or self.useRaidStylePartyFrames
end

function P:ShouldShowCompactFrame()
	return GetNumGroupMembers() > 0 and self:CompactFrameIsActive()
end

function P:CompactFrameIsShown()
	return self.isCompactFrameSetShown and self:ShouldShowCompactFrame()
end

function P:FindRelativeFrame(guid)
	if E.customUF.active then
		if E.db.position.uf == "HealBot" then
			local f = HealBot_Panel_RaidButton(guid)
			return f and f.gref.Back
		elseif E.db.position.uf ~= "auto" then
			local frames, unitKey = E.customUF.frames, E.customUF.unit
			local n = #frames
			for i = 1, n do
				local name = frames[i]
				local f = _G[name]
				local unit = f and (f[unitKey] or f:GetAttribute("unit"))
				if E.UNIT_TO_PET[unit] and UnitGUID(unit) == guid then
					return f:IsVisible() and f
				end
			end
			return
		end
		for addon, data in pairs(E.customUF.enabledList) do
			if addon == "HealBot" then
				local f = HealBot_Panel_RaidButton(guid)
				f = f and f.gref.Back
				if f and f:IsVisible() then
					return f
				end
			else
				local frames, unitKey = data.frames, data.unit
				local n = #frames
				for i = 1, n do
					local name = frames[i]
					local f = _G[name]
					local unit = f and (f[unitKey] or f:GetAttribute("unit"))
					if E.UNIT_TO_PET[unit] and UnitGUID(unit) == guid and f:IsVisible() then
						return f
					end
				end
			end
		end
	end

	local isInRaid = IsInRaid()
	if E.isDF then

		local compactFrame = nil
		if isInRaid and not self.isInArena then
			compactFrame = self.isCompactFrameSetShown and (self.keepGroupsTogether and COMPACT_RAID_KGT or COMPACT_RAID)
		elseif GetNumGroupMembers() > 0 then
			compactFrame = self.useRaidStylePartyFrames and COMPACT_PARTY or false
		elseif EditModeManagerFrame:AreRaidFramesForcedShown() then
			compactFrame = self.isCompactFrameSetShown and (self.keepGroupsTogether and COMPACT_RAID_KGT or COMPACT_RAID)
		elseif EditModeManagerFrame:ArePartyFramesForcedShown() then
			compactFrame = EditModeManagerFrame:UseRaidStylePartyFrames() and COMPACT_PARTY or false
		end

		if compactFrame then
			local n = #compactFrame
			for i = 1, n do
				local name = compactFrame[i]
				local f = _G[name]
				local unit = f and f.unit
				if unit and UnitGUID(unit) == guid then
					return f:IsVisible() and f
				end
			end
		elseif compactFrame == false and (self.isInTestMode or guid ~= E.userGUID) then
			for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
				local unit = memberFrame.unit
				if unit and UnitGUID(unit) == guid then
					return memberFrame:IsVisible() and memberFrame
				end
			end
		end
	else
		if self:CompactFrameIsActive(isInRaid) or self.isInTestMode then
			if not self.isCompactFrameSetShown then return end

			local compactFrame = not self.keepGroupsTogether and COMPACT_RAID or (isInRaid and COMPACT_RAID_KGT or COMPACT_PARTY)
			local n = #compactFrame
			for i = 1, n do
				local name = compactFrame[i]
				local f = _G[name]
				local unit = f and f.unit
				if unit and UnitGUID(unit) == guid then
					return f:IsVisible() and f
				end
			end
		elseif guid ~= E.userGUID then
			for i = 1, 4 do
				local name = PARTY_FRAME[i]
				local f = _G[name]
				local unit = f and f.unit
				if unit and UnitGUID(unit) == guid then
					return f:IsVisible() and f
				end
			end
		end
	end
end

local function SetUnitBarPosition(frame, relFrame, showRange)
	for raidBarIndex, unitBar in pairs(frame.activeUnitBars) do
		if ( showRange ) then
			unitBar:SetParent(relFrame)
			unitBar:SetFrameLevel(10)
		else
			unitBar:SetParent(UIParent)
		end
		unitBar:ClearAllPoints()
		local f = P.extraBars["raidBar" .. raidBarIndex]
		unitBar:SetPoint(f.point, relFrame, f.relativePoint, f.containerOfsX, f.containerOfsY)
	end
end

function P:UpdatePosition(isRefreshMembers)
	if self.disabled then
		return
	end

	if isColdStartDC then
		isColdStartDC = nil
		if C_AddOns.IsAddOnLoaded("Blizzard_CompactRaidFrames") and C_AddOns.IsAddOnLoaded("Blizzard_CUFProfiles") then
			self:UpdateCompactFrameSystemSettings()
		end
	end

	self:HideBars()

	local showRange = E.db.general.showRange
	local point, relPoint = self.point, self.relativePoint
	for guid, info in pairs(self.groupInfo) do
		local frame = info.bar
		if E.db.position.detached then
			frame:SetParent(UIParent)
			E.LoadPosition(frame)
			frame:Show()
		else
			local relFrame = P:FindRelativeFrame(guid)
			if relFrame then
				if showRange then
					frame:SetParent(relFrame)
					frame:SetFrameLevel(10)
				else
					frame:SetParent(UIParent)
				end
				frame:ClearAllPoints()
				frame:SetPoint(point, relFrame, relPoint)
				SetUnitBarPosition(frame, relFrame, showRange)
				frame:Show()
			end
		end
		if not isRefreshMembers then
			frame:SetContainerOffset()
			frame:SetAnchorPosition()
		end
	end
end

function P:UpdateCompactFrameSystemSettings()
	if E.isDF then
		self.useRaidStylePartyFrames = EditModeManagerFrame:UseRaidStylePartyFrames()
		self.keepGroupsTogether = EditModeManagerFrame:ShouldRaidFrameShowSeparateGroups()
	else
		self.useRaidStylePartyFrames = C_CVar and C_CVar.GetCVarBool("useCompactPartyFrames") or GetCVarBool("useCompactPartyFrames")
		self.keepGroupsTogether = CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
	end
	self.isCompactFrameSetShown = CompactRaidFrameManager_GetSetting("IsShown")
end

do
	local hookTimer

	local UpdatePosition_OnTimerEnd = function()
		P:UpdatePosition()
		hookTimer = nil
	end

	function P:HookFunc()
		if self.enabled and not self.disabled and not E.db.position.detached then
			if not hookTimer then
				hookTimer = C_Timer.NewTimer(0.5, UpdatePosition_OnTimerEnd)
			end
			if E.isDF and self.isInTestMode and not E.customUF.active and not self.isInEditMode then
				self:Test()
				E:ACR_NotifyChange()
			end
		end
	end

	function P:CVAR_UPDATE(cvar, value)
		if cvar == "USE_RAID_STYLE_PARTY_FRAMES"
			or cvar == "useCompactPartyFrames" then
			self.useRaidStylePartyFrames = value == "1"
			self:HookFunc()
		end
	end

	local pauseTimer

	local function ResetPause()
		pauseTimer = nil
	end

	local function UpdatePosition_OnRefreshMembers()
		P:UpdatePosition(true)
		pauseTimer = C_Timer.NewTimer(6, ResetPause)
	end

	local function OnRefreshMemebers()
		if not pauseTimer and not P.disabled and not E.db.position.detached
			and EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party, Enum.EditModeUnitFrameSetting.SortPlayersBy) ~= 1 then
			UpdatePosition_OnRefreshMembers()
		end
	end

	function P:UpdateZoneHooks(disable)
		if not E.isDF or not C_AddOns.IsAddOnLoaded("Blizzard_CompactRaidFrames") or not C_AddOns.IsAddOnLoaded("Blizzard_CUFProfiles") then
			return
		end
		local isHooked = self:IsHooked(CompactPartyFrame, "RefreshMembers")
		if not isHooked and self.isInArena and not disable then
			if CompactPartyFrame_RefreshMembers then
				self:SecureHook("CompactPartyFrame_RefreshMembers", OnRefreshMemebers)
			else
				self:SecureHook(CompactPartyFrame, "RefreshMembers", OnRefreshMemebers)
			end
		elseif isHooked and (disable or not self.isInArena) then
			self:Unhook(CompactPartyFrame, "RefreshMembers")
		end
	end

	function P:SetHooks()
		if self.hooked then
			return
		end

		if not C_AddOns.IsAddOnLoaded("Blizzard_CompactRaidFrames") or not C_AddOns.IsAddOnLoaded("Blizzard_CUFProfiles") then
			return
		end


		self:UpdateCompactFrameSystemSettings()

		if E.isDF then

			self:SecureHook("CompactRaidFrameManager_SetSetting", function(arg)
				if arg == "IsShown" then
					local isShown = CompactRaidFrameManager_GetSetting("IsShown")
					if self.isCompactFrameSetShown ~= isShown then
						self.isCompactFrameSetShown = isShown
						self:HookFunc()
					end
				end
			end)


			self:SecureHook(EditModeManagerFrame, "UpdateRaidContainerFlow", function()
				if self.isInEditMode then
					self.keepGroupsTogether = EditModeManagerFrame:ShouldRaidFrameShowSeparateGroups()
					self:HookFunc()
				end
			end)


			self:SecureHook("UpdateRaidAndPartyFrames", function()
				if self.isInEditMode then
					self.useRaidStylePartyFrames = EditModeManagerFrame:UseRaidStylePartyFrames()
					self:HookFunc()
				end
			end)



















			--[[
			if CompactPartyFrame_RefreshMembers then
				self:SecureHook("CompactPartyFrame_RefreshMembers", OnRefreshMemebers)
			else
				self:SecureHook(CompactPartyFrame, "RefreshMembers", OnRefreshMemebers)
			end
			]]


			EventRegistry:RegisterCallback("EditMode.Exit", function()
				self.isInEditMode = nil
				if self.isInTestMode then
					self:Test()
					E:ACR_NotifyChange()
				end
			end)

			EventRegistry:RegisterCallback("EditMode.Enter", function()
				self.isInEditMode = true
			end)
		else
			self:SecureHook("CompactUnitFrameProfiles_ApplyProfile", function(profile)
				if self:CompactFrameIsActive() then
					self:HookFunc()
				end
			end)

			self:SecureHook("CompactRaidFrameManager_SetSetting", function(arg)
				if arg == "IsShown" then
					local isShown = CompactRaidFrameManager_GetSetting("IsShown")
					if self.isCompactFrameSetShown ~= isShown then
						self.isCompactFrameSetShown = isShown
						self:HookFunc()
					end
				elseif arg == "KeepGroupsTogether" then
					self.keepGroupsTogether = CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
				end
			end)
		end

		self.hooked = true
	end
end
