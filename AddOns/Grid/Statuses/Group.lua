--[[--------------------------------------------------------------------
	Grid
	Compact party and raid unit frames.
	Copyright (c) 2006-2014 Kyle Smith (Pastamancer), Phanx
	All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info5747-Grid.html
	http://www.wowace.com/addons/grid/
	http://www.curse.com/addons/wow/grid
------------------------------------------------------------------------
	Group.lua
	Grid status module for group leader, assistant, and master looter.
----------------------------------------------------------------------]]

local _, Grid = ...
local L = Grid.L
local Roster = Grid:GetModule("GridRoster")

local GetLootMethod, UnitAffectingCombat, UnitIsGroupAssistant, UnitIsGroupLeader, UnitIsUnit
    = GetLootMethod, UnitAffectingCombat, UnitIsGroupAssistant, UnitIsGroupLeader, UnitIsUnit

local GridStatusName = Grid:NewStatusModule("GridStatusGroup")
GridStatusName.menuName = L["Group"]
GridStatusName.options = false

GridStatusName.defaultDB = {
	leader = {
		enable = true,
		priority = 1,
		text = L["Group Leader ABBREVIATION"],
		color = { r = 0.65, g = 0.65, b = 1, a = 1, ignore = true },
		hideInCombat = true,
	},
	assistant = {
		enable = true,
		priority = 1,
		text = L["Group Assistant ABBREVIATION"],
		color = { r = 1, g = 0.75, b = 0.5, a = 1, ignore = true },
		hideInCombat = true,
	},
	master_looter = {
		enable = true,
		priority = 1,
		text = L["Master Looter ABBREVIATION"],
		color = { r = 1, g = 1, b = 0.4, a = 1, ignore = true },
		hideInCombat = true,
	},
}

function GridStatusName:PostInitialize()
	self:RegisterStatus("leader", L["Group Leader"])
	self:RegisterStatus("assistant", L["Group Assistant"])
	self:RegisterStatus("master_looter", L["Master Looter"])
end

function GridStatusName:OnStatusEnable(status)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateAllUnits")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateAllUnits")
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "UpdateAllUnits")

	for status, settings in pairs(self.db.profile) do
		if settings.hideInCombat then
			self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAllUnits")
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAllUnits")
			break
		end
	end

	self:UpdateAllUnits("OnStatusEnable")
end

function GridStatusName:OnStatusDisable(status)
	if not self.db.profile[status] then return end

	local enable, combat
	for status, settings in pairs(self.db.profile) do
		if settings.enable then
			enable = true
		end
		if settings.hideInCombat then
			enable = true
		end
	end

	if not combat then
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if not enable then
		self:UnregisterEvent("GROUP_ROSTER_UPDATE")
		self:UnregisterEvent("PARTY_LEADER_CHANGED")
		self:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
	end

	self.core:SendStatusLostAllUnits(status)
end

function GridStatusName:UpdateAllUnits()
	local inCombat = UnitAffectingCombat("player")

	local leaderDB = self.db.profile.leader
	local assistantDB = self.db.profile.assistant
	local looterDB = self.db.profile.master_looter

	local looter
	if looterDB.enable and not (inCombat and looterDB.hideInCombat) then
		local method, pID, rID = GetLootMethod()
		if method == "master" then
			if rID then
				looter = "raid"..rID
			elseif pID then
				looter = pID == 0 and "player" or "party"..pID
			end
		end
	end
	if not looter then
		self.core:SendStatusLostAllUnits("master_looter")
	end

	for guid, unit in Roster:IterateRoster() do
		local isLeader = UnitIsGroupLeader(unit)
		if isLeader and leaderDB.enable and not (inCombat and leaderDB.hideInCombat) then
			self.core:SendStatusGained(guid, "leader",
				leaderDB.priority,
				nil,
				leaderDB.color,
				leaderDB.text,
				nil,
				nil,
				"Interface\\GroupFrame\\UI-Group-LeaderIcon"
			)
		else
			self.core:SendStatusLost(guid, "leader")
		end

		if not isLeader and assistantDB.enable and UnitIsGroupAssistant(unit) and not (inCombat and assistantDB.hideInCombat) then
			self.core:SendStatusGained(guid, "assistant",
				assistantDB.priority,
				nil,
				assistantDB.color,
				assistantDB.text,
				nil,
				nil,
				"Interface\\GroupFrame\\UI-Group-AssistantIcon"
			)
		else
			self.core:SendStatusLost(guid, "assistant")
		end

		if looter and UnitIsUnit(unit, looter) then
			self.core:SendStatusGained(guid, "master_looter",
				looterDB.priority,
				nil,
				looterDB.color,
				looterDB.text,
				nil,
				nil,
				"Interface\\GroupFrame\\UI-Group-MasterLooter"
			)
		else
			self.core:SendStatusLost(guid, "master_looter")
		end
	end
end
