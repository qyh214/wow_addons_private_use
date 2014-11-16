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
	GridStatusVoiceComm.lua
	GridStatus module for showing who's speaking over the in-game voice comm system.
	Based on code from Halgrimm
	http://www.wowace.com/forums/index.php?topic=2525.msg143457#msg143457
----------------------------------------------------------------------]]

local _, Grid = ...
local L = Grid.L
local Roster = Grid:GetModule("GridRoster")

local GridStatusVoiceComm = Grid:NewStatusModule("GridStatusVoiceComm")
GridStatusVoiceComm.menuName = L["Voice Chat"]
GridStatusVoiceComm.options = false

GridStatusVoiceComm.defaultDB = {
	alert_voice = {
		text =  L["Talking"],
		enable = false,
		color = { r = 0.5, g = 1.0, b = 0.5, a = 1.0 },
		priority = 50,
		range = false,
	},
}

function GridStatusVoiceComm:PostInitialize()
	self:RegisterStatus("alert_voice", L["Voice Chat"], nil, true)
end

function GridStatusVoiceComm:OnStatusEnable(status)
	if status == "alert_voice" then
		self:RegisterEvent("VOICE_START")
		self:RegisterEvent("VOICE_STOP")
		self:RegisterMessage("Grid_RosterUpdated", "UpdateAllUnits")
	end
end

function GridStatusVoiceComm:OnStatusDisable(status)
	if stats == "alert_voice" then
		self:UnregisterEvent("VOICE_START")
		self:UnregisterEvent("VOICE_STOP")
		self:UnregisterMessage("Grid_RosterUpdated")
		self.core:SendStatusLostAllUnits("alert_voice")
	end
end

function GridStatusVoiceComm:UpdateAllUnits(event)
	for guid, unit in Roster:IterateRoster() do
		if UnitIsTalking(unit) then
			self:VOICE_START("UpdateAllUnits", unit)
		else
			self:VOICE_STOP("UpdateAllUnits", unit)
		end
	end
end

function GridStatusVoiceComm:VOICE_START(event, unit)
	local settings = self.db.profile.alert_voice

	self.core:SendStatusGained(
		UnitGUID(unit),
		"alert_voice",
		settings.priority,
		settings.range,
		settings.color,
		settings.text,
		nil,
		nil,
		settings.icon)
end

function GridStatusVoiceComm:VOICE_STOP(event, unit)
	self.core:SendStatusLost(UnitGUID(unit), "alert_voice")
end
