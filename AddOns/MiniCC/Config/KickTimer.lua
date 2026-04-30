---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local config = addon.Config

---@class KickTimerConfig
local M = {}

config.KickTimer = M

function M:Build(panel)
	local db = mini:GetSavedVars()
	local columns = 3
	local columnWidth = mini:ColumnWidth(columns, 0, 0)
	local horizontalSpacing = mini.HorizontalSpacing
	local description = mini:TextLine({
		Parent = panel,
		Text = L["Shows enemy kick cooldowns in arena."],
	})

	description:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local text = mini:TextLine({
		Parent = panel,
		Text = L["Enable if you are:"],
	})

	text:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)

	local healerEnabled = mini:Checkbox({
		Parent = panel,
		LabelText = L["Healer"],
		Tooltip = L["Whether to enable or disable this module if you are a healer."],
		GetValue = function()
			return db.Modules.KickTimerModule.Enabled.Healer
		end,
		SetValue = function(value)
			db.Modules.KickTimerModule.Enabled.Healer = value
			config:Apply()
		end,
	})

	healerEnabled:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -verticalSpacing)

	local casterEnabled = mini:Checkbox({
		Parent = panel,
		LabelText = L["Caster"],
		Tooltip = L["Whether to enable or disable this module if you are a caster."],
		GetValue = function()
			return db.Modules.KickTimerModule.Enabled.Caster
		end,
		SetValue = function(value)
			db.Modules.KickTimerModule.Enabled.Caster = value
			config:Apply()
		end,
	})

	casterEnabled:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
	casterEnabled:SetPoint("TOP", healerEnabled, "TOP", 0, 0)

	local allEnabled = mini:Checkbox({
		Parent = panel,
		LabelText = L["Any"],
		Tooltip = L["Whether to enable or disable this module regardless of what spec you are."],
		GetValue = function()
			return db.Modules.KickTimerModule.Enabled.Always
		end,
		SetValue = function(value)
			db.Modules.KickTimerModule.Enabled.Always = value
			config:Apply()
		end,
	})

	allEnabled:SetPoint("LEFT", panel, "LEFT", columnWidth * 2, 0)
	allEnabled:SetPoint("TOP", healerEnabled, "TOP", 0, 0)

	local iconSizeSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Icon Size"],
		GetValue = function()
			return db.Modules.KickTimerModule.Icons.Size
		end,
		SetValue = function(value)
			local newValue = mini:ClampInt(value, 20, 120, 50)
			if db.Modules.KickTimerModule.Icons.Size ~= newValue then
				db.Modules.KickTimerModule.Icons.Size = newValue
				config:Apply()
			end
		end,
		Width = columns * columnWidth - horizontalSpacing,
		Min = 20,
		Max = 120,
		Step = 1,
	})

	iconSizeSlider.Slider:SetPoint("TOPLEFT", healerEnabled, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local important = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	important:SetPoint("TOPLEFT", iconSizeSlider.Slider, "BOTTOMLEFT", 0, -verticalSpacing * 2)
	important:SetText(L["Important Notes"])

	local lines = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["As of 12.0.5, the caster of an interrupt can no longer be identified. This module now just displays a generic icon using the shortest known enemy kick cooldown."],
		},
	})

	lines:SetPoint("TOPLEFT", important, "BOTTOMLEFT", 0, -verticalSpacing)

	M.Panel = panel
end
