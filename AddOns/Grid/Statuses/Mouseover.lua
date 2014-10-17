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
local GridFrame

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

	GridFrame = Grid:GetModule("GridFrame")
	hooksecurefunc(GridFrame.prototype, "OnEnter", self.OnEnter)
	hooksecurefunc(GridFrame.prototype, "OnLeave", self.OnLeave)
end

function GridStatusMouseover:OnStatusEnable(status)
	self:Debug("OnStatusEnable", status)
	self:RegisterMessage("Grid_RosterUpdated", "UpdateAllUnits")
end

function GridStatusMouseover:OnStatusDisable(status)
	self:Debug("OnStatusDisable", status)
	self:UnregisterMessage("Grid_RosterUpdated")
	self:SendStatusLostAllUnits(status)
end

function GridStatusMouseover:UpdateAllUnits(event, ...)
	self:Debug("UpdateAllUnits", event, ...)
	local enabled = self.db.profile.mouseover.enable
	for i = 1, #GridFrame.registeredFrames do
		local frame = GridFrame.registeredFrames[i]
		if enabled and frame:IsMouseOver() then
			self.OnEnter(frame)
		else
			self.OnLeave(frame)
		end
	end
end

function GridStatusMouseover.OnEnter(frame)
	local guid = frame.unitGUID
	local profile = GridStatusMouseover.db.profile.mouseover
	if guid and profile.enable then
		GridStatusMouseover:SendStatusGained("mouseover", guid,
			profile.priority,
			nil,
			profile.color,
			profile.text
		)
	end
end

function GridStatusMouseover.OnLeave(frame)
	local guid = frame.unitGUID
	if guid then
		GridStatusMouseover:SendStatusLost("mouseover", guid)
	end
end
