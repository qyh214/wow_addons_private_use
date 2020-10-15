local W, F, L = unpack(select(2, ...))
local GI = W:NewModule("GroupInfo", "AceHook-3.0")

local _G = _G
local format = format
local pairs = pairs
local sort = sort
local wipe = wipe

local IsAddOnLoaded = IsAddOnLoaded
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetSearchResultMemberInfo = C_LFGList.GetSearchResultMemberInfo

local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE

local RoleIconTextures = {
	TANK = W.Media.Icons.sunUITank,
	HEALER = W.Media.Icons.sunUIHealer,
	DAMAGER = W.Media.Icons.sunUIDPS
}

local displayOrder = {
	[1] = "TANK",
	[2] = "HEALER",
	[3] = "DAMAGER"
}

local roleText = {
	TANK = "|cff00a8ff" .. L["Tank"] .. "|r",
	HEALER = "|cff2ecc71" .. L["Healer"] .. "|r",
	DAMAGER = "|cffe74c3c" .. L["DPS"] .. "|r"
}

local function GetIconString(role, mode)
	local template
	if mode == "NORMAL" then
		template = "|T%s:14:14:0:0:64:64:8:56:8:56|t"
	elseif mode == "COMPACT" then
		template = "|T%s:18:18:0:0:64:64:8:56:8:56|t"
	end

	return format(template, RoleIconTextures[role])
end

local function CheckElvUIWindTools()
	if IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.db.WT.tooltips.groupInfo.enable then
			return true
		end
	end
end

function GI:AddGroupInfo(tooltip, resultID)
	if not self.db or not self.db.enable or CheckElvUIWindTools() then
		return
	end

	local result = C_LFGList_GetSearchResultInfo(resultID)

	if not result then
		return
	end

	local cache = {
		TANK = {},
		HEALER = {},
		DAMAGER = {}
	}

	local display = {
		TANK = false,
		HEALER = false,
		DAMAGER = false
	}

	for i = 1, result.numMembers do
		local role, class = C_LFGList_GetSearchResultMemberInfo(resultID, i)

		if not display[role] then
			display[role] = true
		end

		if not cache[role][class] then
			cache[role][class] = 0
		end

		cache[role][class] = cache[role][class] + 1
	end

	sort(
		cache,
		function(a, b)
			return displayOrder[a] > displayOrder[b]
		end
	)

	if self.db.title then
		tooltip:AddLine(" ")
		tooltip:AddLine(L["Wind Dungeon Helper"] .. " " .. L["Group Info"])
	end

	if self.db.mode == "COMPACT" then
		tooltip:AddLine(" ")
	end

	for i = 1, #displayOrder do
		local role = displayOrder[i]
		local members = cache[role]
		if members and display[role] then
			if self.db.mode == "NORMAL" then
				tooltip:AddLine(" ")
				tooltip:AddLine(GetIconString(role, "NORMAL") .. " " .. roleText[role])
			end

			for class, counter in pairs(members) do
				local numberText = counter ~= 1 and format(" × %d", counter) or ""
				local icon = self.db.mode == "COMPACT" and GetIconString(role, "COMPACT") or ""
				local className = F.CreateClassColorString(LOCALIZED_CLASS_NAMES_MALE[class], class)
				tooltip:AddLine(icon .. className .. numberText)
			end
		end
	end

	wipe(cache)

	tooltip:ClearAllPoints()
	tooltip:SetPoint("TOPLEFT", _G.LFGListFrame, "TOPRIGHT", 10, 0)
	tooltip:Show()
end

function GI:ProfileUpdate()
	self.db = W.db.groupInfo

	if self.db and self.db.enable then
		if not self:IsHooked("LFGListUtil_SetSearchEntryTooltip") then
			self:SecureHook("LFGListUtil_SetSearchEntryTooltip", "AddGroupInfo")
		end
	else
		if self:IsHooked("LFGListUtil_SetSearchEntryTooltip") then
			self:Unhook("LFGListUtil_SetSearchEntryTooltip")
		end
	end
end

GI.OnInitialize = GI.ProfileUpdate