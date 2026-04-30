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

---@class CrowdControlConfig
local M = {}

config.CrowdControl = M

---@param parent table
---@param options CrowdControlInstanceOptions|PetCrowdControlModuleOptions
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

	panel:SetHeight(containerX.Slider:GetHeight() + growDdl:GetHeight() + growDdlLbl:GetHeight() + verticalSpacing * 5)

	return panel
end

---@param panel table
---@param options CrowdControlInstanceOptions
local function BuildInstance(panel, options)
	local parent = CreateFrame("Frame", nil, panel)
	local anchorPanel = BuildAnchorSettings(parent, options)

	local excludePlayerChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Exclude self"],
		Tooltip = L["Exclude yourself from showing CC icons."],
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
		Tooltip = L["Show a glow around the CC icons."],
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
		Tooltip = L["Change the colour of the glow/border based on the type of debuff."],
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

	showTooltipsChk:SetPoint("TOPLEFT", excludePlayerChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local showMillisChk = mini:Checkbox({
		Parent = parent,
		LabelText = L["Milliseconds"],
		Tooltip = L["Show decimal milliseconds on the cooldown timer when below the configured threshold."],
		GetValue = function()
			return options.Icons.ShowMilliseconds == true
		end,
		SetValue = function(value)
			options.Icons.ShowMilliseconds = value
			config:Apply()
		end,
	})

	showMillisChk:SetPoint("LEFT", parent, "LEFT", columnWidth, 0)
	showMillisChk:SetPoint("TOP", showTooltipsChk, "TOP", 0, 0)

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

	iconSize.Slider:SetPoint("TOPLEFT", showTooltipsChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local maxIcons = mini:Slider({
		Parent = parent,
		Min = 1,
		Max = 5,
		Width = columnWidth * 2 - horizontalSpacing,
		Step = 1,
		LabelText = L["Max Icons"],
		GetValue = function()
			return options.Icons.Count or 5
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 1, 5, 3)
			if options.Icons.Count ~= newValue then
				options.Icons.Count = newValue
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
---@param options PetCrowdControlModuleOptions
local function BuildPetInstance(panel, options)
	local parent = CreateFrame("Frame", nil, panel)
	local anchorPanel = BuildAnchorSettings(parent, options)

	local petEnabledEverywhere = mini:Checkbox({
		Parent = parent,
		LabelText = L["World"],
		Tooltip = L["Enable pet frame CC in the open world."],
		GetValue = function()
			return options.Enabled.World
		end,
		SetValue = function(value)
			options.Enabled.World = value
			config:Apply()
		end,
	})

	petEnabledEverywhere:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

	local petEnabledArena = mini:Checkbox({
		Parent = parent,
		LabelText = L["Arena"],
		Tooltip = L["Enable pet frame CC in arena."],
		GetValue = function()
			return options.Enabled.Arena
		end,
		SetValue = function(value)
			options.Enabled.Arena = value
			config:Apply()
		end,
	})

	petEnabledArena:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth, 0)
	petEnabledArena:SetPoint("TOP", petEnabledEverywhere, "TOP", 0, 0)

	local petEnabledBattleGrounds = mini:Checkbox({
		Parent = parent,
		LabelText = L["Battlegrounds"],
		Tooltip = L["Enable pet frame CC in battlegrounds."],
		GetValue = function()
			return options.Enabled.BattleGrounds
		end,
		SetValue = function(value)
			options.Enabled.BattleGrounds = value
			config:Apply()
		end,
	})

	petEnabledBattleGrounds:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth * 2, 0)
	petEnabledBattleGrounds:SetPoint("TOP", petEnabledEverywhere, "TOP", 0, 0)

	local petEnabledDungeons = mini:Checkbox({
		Parent = parent,
		LabelText = L["Dungeons"],
		Tooltip = L["Enable pet frame CC in dungeons."],
		GetValue = function()
			return options.Enabled.Dungeons
		end,
		SetValue = function(value)
			options.Enabled.Dungeons = value
			config:Apply()
		end,
	})

	petEnabledDungeons:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth * 3, 0)
	petEnabledDungeons:SetPoint("TOP", petEnabledEverywhere, "TOP", 0, 0)

	local petEnabledRaid = mini:Checkbox({
		Parent = parent,
		LabelText = L["Raid"],
		Tooltip = L["Enable pet frame CC in raids."],
		GetValue = function()
			return options.Enabled.Raid
		end,
		SetValue = function(value)
			options.Enabled.Raid = value
			config:Apply()
		end,
	})

	petEnabledRaid:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth * 4, 0)
	petEnabledRaid:SetPoint("TOP", petEnabledEverywhere, "TOP", 0, 0)

	local glowChk = mini:Checkbox({
		Parent = parent,
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

	glowChk:SetPoint("TOPLEFT", petEnabledEverywhere, "BOTTOMLEFT", 0, -verticalSpacing)

	local dispelColoursChk = mini:Checkbox({
		Parent = parent,
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

	dispelColoursChk:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth, 0)
	dispelColoursChk:SetPoint("TOP", glowChk, "TOP", 0, 0)

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

	reverseChk:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth * 2, 0)
	reverseChk:SetPoint("TOP", glowChk, "TOP", 0, 0)

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

	showTooltipsChk:SetPoint("LEFT", parent, "LEFT", enabledColumnWidth * 3, 0)
	showTooltipsChk:SetPoint("TOP", glowChk, "TOP", 0, 0)

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
			local newValue = mini:ClampInt(v, 10, 100, 24)
			if options.Icons.Size ~= newValue then
				options.Icons.Size = newValue
				config:Apply()
			end
		end,
	})

	iconSize.Slider:SetPoint("TOPLEFT", glowChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local maxIcons = mini:Slider({
		Parent = parent,
		Min = 1,
		Max = 5,
		Width = columnWidth * 2 - horizontalSpacing,
		Step = 1,
		LabelText = L["Max Icons"],
		GetValue = function()
			return options.Icons.Count or 3
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 1, 5, 3)
			if options.Icons.Count ~= newValue then
				options.Icons.Count = newValue
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
---@param default CrowdControlInstanceOptions
---@param raid CrowdControlInstanceOptions
function M:Build(panel, default, raid)
	columnWidth = mini:ColumnWidth(columns, 0, 0)
	enabledColumnWidth = mini:ColumnWidth(5, 0, 0)
	local db = mini:GetSavedVars()

	local lines = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["Shows CC icons on party/raid frames."],
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
			return db.Modules.CCModule.Enabled.World
		end,
		SetValue = function(value)
			db.Modules.CCModule.Enabled.World = value
			config:Apply()
		end,
	})

	enabledEverywhere:SetPoint("TOPLEFT", enabledDivider, "BOTTOMLEFT", 0, -verticalSpacing)

	local enabledArena = mini:Checkbox({
		Parent = panel,
		LabelText = L["Arena"],
		Tooltip = L["Enable this module in arena."],
		GetValue = function()
			return db.Modules.CCModule.Enabled.Arena
		end,
		SetValue = function(value)
			db.Modules.CCModule.Enabled.Arena = value
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
			return db.Modules.CCModule.Enabled.BattleGrounds
		end,
		SetValue = function(value)
			db.Modules.CCModule.Enabled.BattleGrounds = value
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
			return db.Modules.CCModule.Enabled.Dungeons
		end,
		SetValue = function(value)
			db.Modules.CCModule.Enabled.Dungeons = value
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
			return db.Modules.CCModule.Enabled.Raid
		end,
		SetValue = function(value)
			db.Modules.CCModule.Enabled.Raid = value
			config:Apply()
		end,
	})

	enabledRaid:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 4, 0)
	enabledRaid:SetPoint("TOP", enabledEverywhere, "TOP", 0, 0)

	local subPanelHeight = 340
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
			{ Key = "pet",     Title = L["Pet Frames"] },
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

	local petContent = tabCtrl:GetContent("pet")
	local petPanel = BuildPetInstance(petContent, db.Modules.PetCCModule)
	petPanel:SetPoint("TOPLEFT",  petContent, "TOPLEFT",  0, 0)
	petPanel:SetPoint("TOPRIGHT", petContent, "TOPRIGHT", 0, 0)
	petPanel:SetHeight(subPanelHeight)

	panel.OnMiniRefresh = function()
		defaultPanel:MiniRefresh()
		raidPanel:MiniRefresh()
		petPanel:MiniRefresh()
	end
end
