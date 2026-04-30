---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local dropdownWidth = 200
local growOptions = {
	"LEFT",
	"RIGHT",
	"CENTER",
	"DOWN",
}
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
local columns = 4
local columnWidth
local enabledColumnWidth
local config = addon.Config

---@class FriendlyIndicatorConfig
local M = {}

config.FriendlyIndicator = M

---@param parent table
---@param options FriendlyIndicatorInstanceOptions
local function BuildAnchorSettings(parent, options)
	local panel = CreateFrame("Frame", nil, parent)

	local growDdlLbl = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	growDdlLbl:SetText(L["Grow"])

	local growDdl, modernDdl = mini:Dropdown({
		Parent = panel,
		Items = growOptions,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return options.Grow
		end,
		SetValue = function(value)
			if options.Grow ~= value then
				options.Grow = value
				config:Apply()
			end
		end,
	})

	growDdl:SetWidth(dropdownWidth)
	growDdlLbl:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
	growDdl:SetPoint("TOPLEFT", growDdlLbl, "BOTTOMLEFT", modernDdl and 0 or -16, -8)

	local containerX = mini:Slider({
		Parent = panel,
		Min = -250,
		Max = 250,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		LabelText = L["Offset X"],
		GetValue = function()
			return options.Offset.X
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, -250, 250, 0)
			if options.Offset.X ~= newValue then
				options.Offset.X = newValue
				config:Apply()
			end
		end,
	})

	containerX.Slider:SetPoint("TOPLEFT", growDdl, "BOTTOMLEFT", 0, -verticalSpacing * 3)

	local containerY = mini:Slider({
		Parent = panel,
		Min = -250,
		Max = 250,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		LabelText = L["Offset Y"],
		GetValue = function()
			return options.Offset.Y
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, -250, 250, 0)
			if options.Offset.Y ~= newValue then
				options.Offset.Y = newValue
				config:Apply()
			end
		end,
	})

	containerY.Slider:SetPoint("LEFT", containerX.Slider, "RIGHT", horizontalSpacing, 0)

	panel:SetHeight(containerX.Slider:GetHeight() + growDdl:GetHeight() + growDdlLbl:GetHeight() + verticalSpacing * 3 + 8)

	return panel
end

---@param panel table
---@param options FriendlyIndicatorInstanceOptions
local function BuildInstance(panel, options)
	local parent = CreateFrame("Frame", nil, panel)
	local anchorPanel = BuildAnchorSettings(parent, options)

	local excludePlayerChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Exclude self"],
		Tooltip = L["Exclude yourself from showing trinket icons."],
		GetValue = function()
			return options.ExcludePlayer
		end,
		SetValue = function(value)
			options.ExcludePlayer = value
			addon:Refresh()
		end,
	})

	excludePlayerChk:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

	local glowChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Glow icons"],
		Tooltip = L["Show a glow around the icons."],
		GetValue = function()
			return options.Icons.Glow
		end,
		SetValue = function(value)
			options.Icons.Glow = value
			config:Apply()
		end,
	})

	glowChk:SetPoint("LEFT", parent, "LEFT", columnWidth, 0)
	glowChk:SetPoint("TOP", excludePlayerChk, "TOP", 0, 0)

	local dispelColoursChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Dispel colours"],
		Tooltip = L["Change the colour of the glow/border based on dispel type (e.g., blue for magic, red for physical). This only applies to CC icons."],
		GetValue = function()
			return options.Icons.ColorByDispelType
		end,
		SetValue = function(value)
			options.Icons.ColorByDispelType = value
			config:Apply()
		end,
	})

	dispelColoursChk:SetPoint("LEFT", parent, "LEFT", columnWidth * 2, 0)
	dispelColoursChk:SetPoint("TOP", excludePlayerChk, "TOP", 0, 0)

	local reverseChk = mini:Checkbox({
		Parent = parent,
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

	reverseChk:SetPoint("LEFT", parent, "LEFT", columnWidth * 3, 0)
	reverseChk:SetPoint("TOP", excludePlayerChk, "TOP", 0, 0)

	local showDefensivesChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Show Defensives"],
		Tooltip = L["Show defensive spell icons."],
		GetValue = function()
			return options.ShowDefensives
		end,
		SetValue = function(value)
			options.ShowDefensives = value
			config:Apply()
		end,
	})

	showDefensivesChk:SetPoint("TOPLEFT", excludePlayerChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local showImportantChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Show Important"],
		Tooltip = L["Show important spell icons."],
		GetValue = function()
			return options.ShowImportant
		end,
		SetValue = function(value)
			options.ShowImportant = value
			config:Apply()
		end,
	})

	showImportantChk:SetPoint("LEFT", parent, "LEFT", columnWidth, 0)
	showImportantChk:SetPoint("TOP", showDefensivesChk, "TOP", 0, 0)

	local showCCChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Show CC"],
		Tooltip = L["Show CC icons."],
		GetValue = function()
			return options.ShowCC
		end,
		SetValue = function(value)
			options.ShowCC = value
			config:Apply()
		end,
	})

	showCCChk:SetPoint("LEFT", parent, "LEFT", columnWidth * 2, 0)
	showCCChk:SetPoint("TOP", showDefensivesChk, "TOP", 0, 0)

	local showTooltipsChk = mini:Checkbox({
		Parent = parent,
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

	showTooltipsChk:SetPoint("LEFT", parent, "LEFT", columnWidth * 3, 0)
	showTooltipsChk:SetPoint("TOP", showDefensivesChk, "TOP", 0, 0)

	local iconSize = mini:Slider({
		Parent = parent,
		Min = 10,
		Max = 100,
		Width = columnWidth * 2 - horizontalSpacing,
		Step = 1,
		LabelText = L["Icon Size"],
		GetValue = function()
			return options.Icons.Size
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 10, 100, 32)
			if options.Icons.Size ~= newValue then
				options.Icons.Size = newValue
				config:Apply()
			end
		end,
	})

	iconSize.Slider:SetPoint("TOPLEFT", showDefensivesChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local maxIcons = mini:Slider({
		Parent = parent,
		Min = 1,
		Max = 5,
		Width = columnWidth * 2 - horizontalSpacing,
		Step = 1,
		LabelText = L["Max Icons"],
		GetValue = function()
			return options.Icons.MaxIcons
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 1, 5, 1)
			if options.Icons.MaxIcons ~= newValue then
				options.Icons.MaxIcons = newValue
				config:Apply()
			end
		end,
	})

	maxIcons.Slider:SetPoint("LEFT", iconSize.Slider, "RIGHT", horizontalSpacing, 0)

	anchorPanel:SetPoint("TOPLEFT", iconSize.Slider, "BOTTOMLEFT", 0, -verticalSpacing * 2)
	anchorPanel:SetPoint("TOPRIGHT", iconSize.Slider, "BOTTOMRIGHT", 0, -verticalSpacing * 2)

	parent.OnMiniRefresh = function()
		anchorPanel:MiniRefresh()
	end

	return parent
end

---@param panel table
---@param default FriendlyIndicatorInstanceOptions
---@param raid FriendlyIndicatorInstanceOptions
function M:Build(panel, default, raid)
	columnWidth = mini:ColumnWidth(columns, 0, 0)
	enabledColumnWidth = mini:ColumnWidth(5, 0, 0)
	local db = mini:GetSavedVars()

	local lines = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["Shows CC, defensives, and important auras as one set of icons on party/raid frames."],
			L["Tip: Disable the CC module for BGs and enable CC within this module."],
			L["Don't forget to disable the Blizzard 'center big defensives' option when using this."],
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
			return db.Modules.FriendlyIndicatorModule.Enabled.World
		end,
		SetValue = function(value)
			db.Modules.FriendlyIndicatorModule.Enabled.World = value
			config:Apply()
		end,
	})

	enabledEverywhere:SetPoint("TOPLEFT", enabledDivider, "BOTTOMLEFT", 0, -verticalSpacing)

	local enabledArena = mini:Checkbox({
		Parent = panel,
		LabelText = L["Arena"],
		Tooltip = L["Enable this module in arena."],
		GetValue = function()
			return db.Modules.FriendlyIndicatorModule.Enabled.Arena
		end,
		SetValue = function(value)
			db.Modules.FriendlyIndicatorModule.Enabled.Arena = value
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
			return db.Modules.FriendlyIndicatorModule.Enabled.BattleGrounds
		end,
		SetValue = function(value)
			db.Modules.FriendlyIndicatorModule.Enabled.BattleGrounds = value
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
			return db.Modules.FriendlyIndicatorModule.Enabled.Dungeons
		end,
		SetValue = function(value)
			db.Modules.FriendlyIndicatorModule.Enabled.Dungeons = value
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
			return db.Modules.FriendlyIndicatorModule.Enabled.Raid
		end,
		SetValue = function(value)
			db.Modules.FriendlyIndicatorModule.Enabled.Raid = value
			config:Apply()
		end,
	})

	enabledRaid:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 4, 0)
	enabledRaid:SetPoint("TOP", enabledEverywhere, "TOP", 0, 0)

	local subPanelHeight = 316
	local tabContainer = CreateFrame("Frame", nil, panel)
	tabContainer:SetPoint("TOPLEFT",  enabledEverywhere, "BOTTOMLEFT",  0, -verticalSpacing)
	tabContainer:SetPoint("TOPRIGHT", panel,             "TOPRIGHT",    0, 0)
	tabContainer:SetHeight(subPanelHeight + 34)

	local tabIsRaid = { default = false, raid = true }

	local tabCtrl = mini:CreateTabs({
		Parent = tabContainer,
		TabHeight = 28,
		StripHeight = 34,
		TabFitToParent = true,
		ContentInsets = { Top = verticalSpacing },
		Tabs = {
			{ Key = "default", Title = L["World/Arena/Dungeons"] },
			{ Key = "raid",    Title = L["Raids/Battlegrounds"] },
		},
		OnTabChanged = function(key)
			local isRaid = tabIsRaid[key]
			if isRaid ~= nil then
				addon.CurrentTestIsRaid = isRaid
				if addon:IsTestActive() then
					addon:TestWithOptions(isRaid)
				end
			end
		end,
	})

	local defaultContent = tabCtrl:GetContent("default")
	local defaultPanel = BuildInstance(defaultContent, default)
	defaultPanel:SetPoint("TOPLEFT",  defaultContent, "TOPLEFT",  0, 0)
	defaultPanel:SetPoint("TOPRIGHT", defaultContent, "TOPRIGHT", 0, 0)
	defaultPanel:SetHeight(subPanelHeight)

	local raidContent = tabCtrl:GetContent("raid")
	local raidPanel = BuildInstance(raidContent, raid)
	raidPanel:SetPoint("TOPLEFT",  raidContent, "TOPLEFT",  0, 0)
	raidPanel:SetPoint("TOPRIGHT", raidContent, "TOPRIGHT", 0, 0)
	raidPanel:SetHeight(subPanelHeight)

	panel.OnMiniRefresh = function()
		defaultPanel:MiniRefresh()
		raidPanel:MiniRefresh()
	end
end
