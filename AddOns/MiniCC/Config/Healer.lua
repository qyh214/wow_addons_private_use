---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
local columns = 4
local columnWidth
local enabledColumnWidth
local config = addon.Config

---@class HealerCrowdControlConfig
local M = {}

config.Healer = M

---@param panel table
---@param options HealerCrowdControlModuleOptions
function M:Build(panel, options)
	columnWidth = mini:ColumnWidth(columns, 0, 0)
	enabledColumnWidth = mini:ColumnWidth(5, 0, 0)
	local db = mini:GetSavedVars()

	local lines = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["A separate region for when your healer is CC'd."],
		},
	})

	lines:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local enabledDivider = mini:Divider({
		Parent = panel,
		Text = L["Enable in"],
	})
	enabledDivider:SetPoint("LEFT", panel, "LEFT")
	enabledDivider:SetPoint("RIGHT", panel, "RIGHT")
	enabledDivider:SetPoint("TOP", lines, "BOTTOM", 0, -verticalSpacing)

	local enabledEverywhere = mini:Checkbox({
		Parent = panel,
		LabelText = L["World"],
		Tooltip = L["Enable this module in the open world."],
		GetValue = function()
			return db.Modules.HealerCCModule.Enabled.World
		end,
		SetValue = function(value)
			db.Modules.HealerCCModule.Enabled.World = value
			config:Apply()
		end,
	})

	enabledEverywhere:SetPoint("TOPLEFT", enabledDivider, "BOTTOMLEFT", 0, -verticalSpacing)

	local enabledArena = mini:Checkbox({
		Parent = panel,
		LabelText = L["Arena"],
		Tooltip = L["Enable this module in arena."],
		GetValue = function()
			return db.Modules.HealerCCModule.Enabled.Arena
		end,
		SetValue = function(value)
			db.Modules.HealerCCModule.Enabled.Arena = value
			config:Apply()
		end,
	})

	enabledArena:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth, 0)
	enabledArena:SetPoint("TOP", enabledEverywhere, "TOP", 0, 0)

	local enabledBattleGrounds = mini:Checkbox({
		Parent = panel,
		LabelText = L["Battlegrounds"],
		Tooltip = L["Enable this module in battlegrounds."],
		GetValue = function()
			return db.Modules.HealerCCModule.Enabled.BattleGrounds
		end,
		SetValue = function(value)
			db.Modules.HealerCCModule.Enabled.BattleGrounds = value
			config:Apply()
		end,
	})

	enabledBattleGrounds:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 2, 0)
	enabledBattleGrounds:SetPoint("TOP", enabledEverywhere, "TOP", 0, 0)

	local enabledDungeons = mini:Checkbox({
		Parent = panel,
		LabelText = L["Dungeons"],
		Tooltip = L["Enable this module in dungeons."],
		GetValue = function()
			return db.Modules.HealerCCModule.Enabled.Dungeons
		end,
		SetValue = function(value)
			db.Modules.HealerCCModule.Enabled.Dungeons = value
			config:Apply()
		end,
	})

	enabledDungeons:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 3, 0)
	enabledDungeons:SetPoint("TOP", enabledEverywhere, "TOP", 0, 0)

	local enabledRaid = mini:Checkbox({
		Parent = panel,
		LabelText = L["Raid"],
		Tooltip = L["Enable this module in raids."],
		GetValue = function()
			return db.Modules.HealerCCModule.Enabled.Raid
		end,
		SetValue = function(value)
			db.Modules.HealerCCModule.Enabled.Raid = value
			config:Apply()
		end,
	})

	enabledRaid:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 4, 0)
	enabledRaid:SetPoint("TOP", enabledEverywhere, "TOP", 0, 0)

	local settingsDivider = mini:Divider({
		Parent = panel,
		Text = L["Settings"],
	})
	settingsDivider:SetPoint("LEFT", panel, "LEFT")
	settingsDivider:SetPoint("RIGHT", panel, "RIGHT")
	settingsDivider:SetPoint("TOP", enabledEverywhere, "BOTTOM", 0, -verticalSpacing)

	local showIconsChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Show icons"],
		Tooltip = L["Show CC icons when healer is CC'd."],
		GetValue = function()
			return options.Icons.Enabled
		end,
		SetValue = function(value)
			options.Icons.Enabled = value
			config:Apply()
		end,
	})

	showIconsChk:SetPoint("TOPLEFT", settingsDivider, "BOTTOMLEFT", 0, -verticalSpacing)

	local glowChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Glow icons"],
		Tooltip = L["Show a glow around the CC icons."],
		GetValue = function()
			return options.Icons.Glow
		end,
		SetValue = function(value)
			options.Icons.Glow = value
			config:Apply()
		end,
	})

	glowChk:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
	glowChk:SetPoint("TOP", showIconsChk, "TOP", 0, 0)

	local showTextChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Show warning text"],
		Tooltip = L["Show the 'Healer in CC!' text above the icons."],
		GetValue = function()
			return options.ShowWarningText
		end,
		SetValue = function(value)
			options.ShowWarningText = value
			config:Apply()
		end,
	})

	showTextChk:SetPoint("LEFT", panel, "LEFT", columnWidth * 2, 0)
	showTextChk:SetPoint("TOP", glowChk, "TOP", 0, 0)

	local reverseChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Reverse swipe"],
		Tooltip = L["Reverses the direction of the cooldown swipe animation."],
		GetValue = function()
			return options.Icons.ReverseCooldown
		end,
		SetValue = function(value)
			options.Icons.ReverseCooldown = value
			config:Apply()
		end,
	})

	reverseChk:SetPoint("LEFT", panel, "LEFT", columnWidth * 3, 0)
	reverseChk:SetPoint("TOP", glowChk, "TOP", 0, 0)

	local dispelColoursChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Dispel colours"],
		Tooltip = L["Change the colour of the glow/border based on the type of debuff."],
		GetValue = function()
			return options.Icons.ColorByDispelType
		end,
		SetValue = function(value)
			options.Icons.ColorByDispelType = value
			config:Apply()
		end,
	})

	dispelColoursChk:SetPoint("TOPLEFT", showIconsChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local showTooltipsChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Show tooltips"],
		Tooltip = L["Shows a spell tooltip when hovering over an icon."],
		GetValue = function()
			return options.ShowTooltips ~= false
		end,
		SetValue = function(value)
			options.ShowTooltips = value
			config:Apply()
		end,
	})

	showTooltipsChk:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
	showTooltipsChk:SetPoint("TOP", dispelColoursChk, "TOP", 0, 0)

	local soundChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Sound"],
		Tooltip = L["Play a sound when the healer is CC'd."],
		GetValue = function()
			return options.Sound.Enabled
		end,
		SetValue = function(value)
			options.Sound.Enabled = value
			if value then
				-- Play the sound when enabled
				local soundFileName = options.Sound.File or "Sonar.ogg"
				local soundFile = config.MediaLocation .. soundFileName
				PlaySoundFile(soundFile, options.Sound.Channel or "Master")
			end
			config:Apply()
		end,
	})

	soundChk:SetPoint("TOPLEFT", dispelColoursChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local soundFileDropdown = mini:Dropdown({
		Parent = panel,
		Items = config.SoundFiles,
		Width = 200,
		GetValue = function()
			return options.Sound.File or "Sonar.ogg"
		end,
		SetValue = function(value)
			options.Sound.File = value
			-- Play the selected sound
			local soundFile = config.MediaLocation .. value
			PlaySoundFile(soundFile, options.Sound.Channel or "Master")
			config:Apply()
		end,
		GetText = function(value)
			return value:gsub("%.ogg$", "")
		end,
	})

	soundFileDropdown:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
	soundFileDropdown:SetPoint("TOP", soundChk, "TOP", 0, -4)
	soundFileDropdown:SetWidth(200)

	local sliderWidth = (columnWidth * 2) - horizontalSpacing

	local iconSize = mini:Slider({
		Parent = panel,
		Min = 10,
		Max = 100,
		Width = sliderWidth,
		Step = 1,
		LabelText = L["Icon Size"],
		GetValue = function()
			return options.Icons.Size
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 10, 100, 50)
			if options.Icons.Size ~= newValue then
				options.Icons.Size = newValue
				config:Apply()
			end
		end,
	})

	iconSize.Slider:SetPoint("TOPLEFT", soundChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local fontSize = mini:Slider({
		Parent = panel,
		Min = 10,
		Max = 100,
		Width = sliderWidth,
		Step = 1,
		LabelText = L["Text Size"],
		GetValue = function()
			return options.Font.Size
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 10, 100, 32)
			if options.Font.Size ~= newValue then
				options.Font.Size = newValue
				config:Apply()
			end
		end,
	})

	fontSize.Slider:SetPoint("LEFT", panel, "LEFT", columnWidth * 2 + 4, 0)
	fontSize.Slider:SetPoint("TOP", iconSize.Slider, "TOP", 0, 0)

	panel:HookScript("OnShow", function()
		panel:MiniRefresh()
	end)
end
