---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
---@type Db
local db
---@class PortraitsConfig
local M = {}

addon.Config.Portraits = M

function M:Build(panel)
	db = mini:GetSavedVars()

	local columns = 4
	local columnWidth = mini:ColumnWidth(columns, 0, 0)

	local lines = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["Shows CC, defensives, and other important spells on the player/target/focus portraits."],
		},
	})

	lines:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local enabled = mini:Checkbox({
		Parent = panel,
		LabelText = L["Enabled"],
		Tooltip = L["Enable this module everywhere."],
		GetValue = function()
			return db.Modules.PortraitModule.Enabled.Always
		end,
		SetValue = function(value)
			db.Modules.PortraitModule.Enabled.Always = value
			addon.Config:Apply()
		end,
	})

	enabled:SetPoint("TOPLEFT", lines, "BOTTOMLEFT", 0, -verticalSpacing)

	local reverseSweepChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Reverse swipe"],
		Tooltip = L["Reverses the direction of the cooldown swipe."],
		GetValue = function()
			return db.Modules.PortraitModule.ReverseCooldown
		end,
		SetValue = function(value)
			db.Modules.PortraitModule.ReverseCooldown = value
			addon.Config:Apply()
		end,
	})

	reverseSweepChk:SetPoint("TOP", enabled, "TOP", 0, 0)
	reverseSweepChk:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
end
