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
	Mouseover.lua
	Grid status module for mouseover units.
----------------------------------------------------------------------]]

local _, Grid = ...
local L = Grid.L
local GridFrame = Grid:GetModule("GridFrame")

local GridStatusMouseover = Grid:NewStatusModule("GridStatusMouseover")
GridStatusMouseover.menuName = L["Mouseover"]
GridStatusMouseover.options = false

GridStatusMouseover.defaultDB = {
	mouseover = {
		enable = true,
		priority = 50,
		color = { r = 1, g = 1, b = 1, a = 1 },
		text = L["Mouseover"],
	}
}

function GridStatusMouseover:PostInitialize()
	self:Debug("PostInitialize")
	self:RegisterStatus("mouseover", L["Mouseover"], nil, true)
end

function GridStatusMouseover:OnStatusEnable(status)
	self:Debug("OnStatusEnable", status)
	self:RegisterMessage("Grid_RosterUpdated", "UpdateAllUnits")
	self:RegisterMessage("Grid_UnitFrame_OnEnter", "UnitFrame_OnEnter")
	self:RegisterMessage("Grid_UnitFrame_OnLeave", "UnitFrame_OnLeave")
	self:UpdateAllUnits()
end

function GridStatusMouseover:OnStatusDisable(status)
	self:Debug("OnStatusDisable", status)
	self:UnregisterMessage("Grid_RosterUpdated")
	self:UnregisterMessage("Grid_UnitFrame_OnEnter")
	self:UnregisterMessage("Grid_UnitFrame_OnLeave")
	self:SendStatusLostAllUnits(status)
end

function GridStatusMouseover:UpdateAllUnits(event)
	local enabled = self.db.profile.mouseover.enable
	for i = 1, #GridFrame.registeredFrames do
		local frame = GridFrame.registeredFrames[i]
		if enabled and frame:IsMouseOver() then
			self:UnitFrame_OnEnter(frame.unit, frame.unitGUID)
		else
			self:UnitFrame_OnLeave(frame.unit, frame.unitGUID)
		end
	end
end

function GridStatusMouseover:UnitFrame_OnEnter(event, unit, guid)
	local profile = GridStatusMouseover.db.profile.mouseover
	if guid and profile.enable then
		self.core:SendStatusGained(guid, "mouseover",
			profile.priority,
			nil,
			profile.color,
			profile.text
		)
	end
end

function GridStatusMouseover:UnitFrame_OnLeave(event, unit, guid)
	if guid then
		self.core:SendStatusLost(guid, "mouseover")
	end
end
