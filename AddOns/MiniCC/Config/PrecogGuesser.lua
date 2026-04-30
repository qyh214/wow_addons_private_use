---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
local config = addon.Config

---@class PrecogGuesserConfig
local M = {}

config.PrecogGuesser = M

function M:Build(panel)
	local db = mini:GetSavedVars()
	local columns = 3
	local columnWidth = mini:ColumnWidth(columns, 0, 0)
	local description = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["This isn't precision perfect but it should be close enough."],
			L["It works by taking any 4 second 'important' self buff and showing that icon."],
			L["So if by chance you happen to have some other 4 second important self buff then it would also show that icon sorry."],
			L["Note that you can't simply filter by spell id these days."],
		},
	})

	description:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local enabled = mini:Checkbox({
		Parent = panel,
		LabelText = L["Enabled"],
		Tooltip = L["Whether to enable or disable this module."],
		GetValue = function()
			return db.Modules.PrecogGuesserModule.Enabled.Always
		end,
		SetValue = function(value)
			db.Modules.PrecogGuesserModule.Enabled.Always = value
			config:Apply()
		end,
	})

	enabled:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)

	local glowChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Glow icons"],
		GetValue = function()
			return db.Modules.PrecogGuesserModule.Icons.Glow
		end,
		SetValue = function(value)
			db.Modules.PrecogGuesserModule.Icons.Glow = value
			config:Apply()
		end,
	})

	glowChk:SetPoint("TOP", enabled, "TOP", 0, 0)
	glowChk:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)

	local iconSizeSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Icon Size"],
		GetValue = function()
			return db.Modules.PrecogGuesserModule.Icons.Size
		end,
		SetValue = function(value)
			local newValue = mini:ClampInt(value, 20, 120, 70)
			if db.Modules.PrecogGuesserModule.Icons.Size ~= newValue then
				db.Modules.PrecogGuesserModule.Icons.Size = newValue
				config:Apply()
			end
		end,
		Width = columns * columnWidth - horizontalSpacing,
		Min = 20,
		Max = 120,
		Step = 1,
	})

	iconSizeSlider.Slider:SetPoint("TOPLEFT", enabled, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	M.Panel = panel
end
