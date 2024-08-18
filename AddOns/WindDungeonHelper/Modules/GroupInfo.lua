local W, F, L = unpack(select(2, ...))
local GI = W:NewModule("GroupInfo", "AceHook-3.0")
local LFGPI = W.Utilities.LFGPlayerInfo

local _G = _G
local format = format
local ipairs = ipairs

local LibStub = LibStub

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local function CheckElvUIWindTools()
	if C_AddOns_IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.db.WT.tooltips.groupInfo.enable then
			return true
		end
	end
end

local RoleIconTextures = {
	TANK = W.Media.Icons.sunUITank,
	HEALER = W.Media.Icons.sunUIHealer,
	DAMAGER = W.Media.Icons.sunUIDPS
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

function GI:AddGroupInfo(tooltip, resultID)
	if not self.db or not self.db.enable or CheckElvUIWindTools() then
		return
	end

	LFGPI:SetClassIconStyle(self.db.classIconStyle)
	LFGPI:Update(resultID)

	-- split line
	if self.db.title then
		tooltip:AddLine(" ")
		tooltip:AddLine(W.AddonName .. " " .. L["Party Info"])
	end

	-- compact Mode
	if self.db.mode == "COMPACT" then
		tooltip:AddLine(" ")
	end

	-- add info
	local data = LFGPI:GetPartyInfo(self.db.template)

	for order, role in ipairs(LFGPI:GetRoleOrder()) do
		if #data[role] > 0 and self.db.mode == "NORMAL" then
			tooltip:AddLine(" ")
			tooltip:AddLine(GetIconString(role, "NORMAL") .. " " .. LFGPI.GetColoredRoleName(role))
		end

		for _, line in ipairs(data[role]) do
			local icon = self.db.mode == "COMPACT" and GetIconString(role, "COMPACT") or ""
			tooltip:AddLine(icon .. " " .. line)
		end
	end

	tooltip:Show()
end

function GI:ProfileUpdate()
	self.db = W.db.groupInfo

	if C_AddOns_IsAddOnLoaded("PremadeGroupsFilter") and self.db.enable then
		F.Print(
			format(
				L["%s detected, %s will be disabled automatically."],
				"|cffff3860" .. L["Premade Groups Filter"] .. "|r",
				"|cff00a8ff" .. L["Group Info"] .. "|r"
			)
		)

		self.db.enable = false
	end

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
