---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
local config = addon.Config

-- Loaded before this file in TOC order (via Config.lua which runs after all Modules).
local rules = addon.Modules.Cooldowns.Rules
local fcdDisplay = addon.Modules.FriendlyCooldowns.Display
local fcdModule = addon.Modules.FriendlyCooldowns.Module

local growOptions = {
	"LEFT",
	"RIGHT",
	"CENTER",
	"DOWN",
}

local columns = 4
local columnWidth
local enabledColumnWidth

---@class FriendlyCooldownTrackerConfig
local M = {}

config.FriendlyCooldownTracker = M

---@param parent table
---@param anchorOptions FriendlyCooldownTrackerAnchorOptions
local function BuildInstance(parent, anchorOptions)
	local panel = CreateFrame("Frame", nil, parent)

	local excludeSelfChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Exclude self"],
		Tooltip = L["Excludes yourself from being tracked."],
		GetValue = function()
			return anchorOptions.ExcludeSelf
		end,
		SetValue = function(value)
			anchorOptions.ExcludeSelf = value
			config:Apply()
		end,
	})

	excludeSelfChk:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local showTooltipsChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Show tooltips"],
		Tooltip = L["Shows a spell tooltip when hovering over an icon."],
		GetValue = function()
			return anchorOptions.ShowTooltips
		end,
		SetValue = function(value)
			anchorOptions.ShowTooltips = value
			config:Apply()
		end,
	})

	showTooltipsChk:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
	showTooltipsChk:SetPoint("TOP", excludeSelfChk, "TOP", 0, 0)

	local reverseChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Reverse swipe"],
		Tooltip = L["Reverses the direction of the cooldown swipe animation."],
		GetValue = function()
			return anchorOptions.Icons.ReverseCooldown
		end,
		SetValue = function(value)
			anchorOptions.Icons.ReverseCooldown = value
			config:Apply()
		end,
	})

	reverseChk:SetPoint("LEFT", panel, "LEFT", columnWidth * 2, 0)
	reverseChk:SetPoint("TOP", excludeSelfChk, "TOP", 0, 0)

	local showTrinketChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Trinket"],
		Tooltip = L["Shows the trinket cooldown icon."],
		GetValue = function()
			return anchorOptions.ShowTrinket ~= false
		end,
		SetValue = function(value)
			anchorOptions.ShowTrinket = value
			config:Apply()
		end,
	})

	showTrinketChk:SetPoint("LEFT", panel, "LEFT", columnWidth * 3, 0)
	showTrinketChk:SetPoint("TOP", excludeSelfChk, "TOP", 0, 0)

	local desaturateChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Desaturate on cooldown"],
		Tooltip = L["Desaturates the icon while it is on cooldown."],
		GetValue = function()
			return anchorOptions.Icons.DesaturateOnCooldown
		end,
		SetValue = function(value)
			anchorOptions.Icons.DesaturateOnCooldown = value
			config:Apply()
		end,
	})

	desaturateChk:SetPoint("TOPLEFT", excludeSelfChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local predictiveChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Predictive"],
		Tooltip = L["While a cooldown buff is active, glows the icon and shows a countdown before the cooldown timer starts."],
		GetValue = function()
			return anchorOptions.Predictive ~= false
		end,
		SetValue = function(value)
			anchorOptions.Predictive = value
			config:Apply()
		end,
	})

	predictiveChk:SetPoint("LEFT", panel, "LEFT", columnWidth, 0)
	predictiveChk:SetPoint("TOP", desaturateChk, "TOP", 0, 0)

	local iconSizeSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Icon Size"],
		Min = 10,
		Max = 100,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Icons.Size
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 10, 100, 32)
			if anchorOptions.Icons.Size ~= newValue then
				anchorOptions.Icons.Size = newValue
				config:Apply()
			end
		end,
	})

	iconSizeSlider.Slider:SetPoint("TOPLEFT", desaturateChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local maxIconsSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Max Icons"],
		Min = 1,
		Max = 10,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Icons.MaxIcons
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 1, 10, 3)
			if anchorOptions.Icons.MaxIcons ~= newValue then
				anchorOptions.Icons.MaxIcons = newValue
				config:Apply()
			end
		end,
	})

	maxIconsSlider.Slider:SetPoint("LEFT", iconSizeSlider.Slider, "RIGHT", horizontalSpacing, 0)
	maxIconsSlider.Slider:SetPoint("TOP", iconSizeSlider.Slider, "TOP", 0, 0)

	local rowsSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Rows"],
		Min = 1,
		Max = 3,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Icons.Rows or 1
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 1, 3, 1)
			if anchorOptions.Icons.Rows ~= newValue then
				anchorOptions.Icons.Rows = newValue
				config:Apply()
			end
		end,
	})

	rowsSlider.Slider:SetPoint("TOPLEFT", iconSizeSlider.Slider, "BOTTOMLEFT", 0, -verticalSpacing * 2)

	local iconSpacingSlider = mini:Slider({
		Parent    = panel,
		LabelText = L["Icon Spacing"],
		Min       = 0,
		Max       = 20,
		Step      = 1,
		Width     = columnWidth * 2 - horizontalSpacing,
		GetValue  = function()
			return anchorOptions.IconSpacing or 2
		end,
		SetValue  = function(v)
			local newValue = mini:ClampInt(v, 0, 20, 2)
			if anchorOptions.IconSpacing ~= newValue then
				anchorOptions.IconSpacing = newValue
				config:Apply()
			end
		end,
	})

	iconSpacingSlider.Slider:SetPoint("LEFT", rowsSlider.Slider, "RIGHT", horizontalSpacing, 0)
	iconSpacingSlider.Slider:SetPoint("TOP", rowsSlider.Slider, "TOP", 0, 0)

	-- Shares the same position as rowsSlider; only one is shown at a time based on Grow direction.
	local columnsPerRowSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Columns"],
		Tooltip = L["When Grow is Down, sets how many icons appear per row before wrapping. Useful for horizontal party frames."],
		Min = 1,
		Max = 10,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Icons.Columns or 1
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, 1, 10, 1)
			if anchorOptions.Icons.Columns ~= newValue then
				anchorOptions.Icons.Columns = newValue
				config:Apply()
			end
		end,
	})

	columnsPerRowSlider.Slider:SetPoint("TOPLEFT", iconSizeSlider.Slider, "BOTTOMLEFT", 0, -verticalSpacing * 2)

	local function refreshRowControls()
		local isDown = anchorOptions.Grow == "DOWN"
		rowsSlider.Slider:SetShown(not isDown)
		rowsSlider.Label:SetShown(not isDown)
		columnsPerRowSlider.Slider:SetShown(isDown)
		columnsPerRowSlider.Label:SetShown(isDown)
	end

	local growLbl = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	growLbl:SetText(L["Grow"])

	local growDdl, modernDdl = mini:Dropdown({
		Parent = panel,
		Items = growOptions,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Grow
		end,
		SetValue = function(value)
			if anchorOptions.Grow ~= value then
				anchorOptions.Grow = value
				refreshRowControls()
				config:Apply()
			end
		end,
	})

	growLbl:SetPoint("TOPLEFT", rowsSlider.Slider, "BOTTOMLEFT", -4, -verticalSpacing * 2)
	growDdl:SetPoint("TOPLEFT", growLbl, "BOTTOMLEFT", modernDdl and 0 or -16, -8)

	refreshRowControls()

	local offsetX = mini:Slider({
		Parent = panel,
		LabelText = L["Offset X"],
		Min = -250,
		Max = 250,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Offset.X
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, -250, 250, 0)
			if anchorOptions.Offset.X ~= newValue then
				anchorOptions.Offset.X = newValue
				config:Apply()
			end
		end,
	})

	offsetX.Slider:SetPoint("TOPLEFT", growDdl, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local offsetY = mini:Slider({
		Parent = panel,
		LabelText = L["Offset Y"],
		Min = -250,
		Max = 250,
		Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue = function()
			return anchorOptions.Offset.Y
		end,
		SetValue = function(v)
			local newValue = mini:ClampInt(v, -250, 250, 0)
			if anchorOptions.Offset.Y ~= newValue then
				anchorOptions.Offset.Y = newValue
				config:Apply()
			end
		end,
	})

	offsetY.Slider:SetPoint("LEFT", offsetX.Slider, "RIGHT", horizontalSpacing, 0)
	offsetY.Slider:SetPoint("TOP", offsetX.Slider, "TOP", 0, 0)

	panel.BottomAnchor = offsetX.Slider

	return panel
end

-- Localized class display names keyed by class token.
local classDisplayNames = LocalizedClassList()

local classOrder = {
	"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER",
	"MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE",
	"SHAMAN", "WARLOCK", "WARRIOR",
}

-- Static spec ID -> class token mapping, matching the IDs declared in Rules.lua.
-- Using a hardcoded map avoids relying on GetSpecializationInfoByID at UI-build time,
-- which can return nil for newer or environment-dependent specs.
local specClass = {
	[250]  = "DEATHKNIGHT", [251]  = "DEATHKNIGHT", [252]  = "DEATHKNIGHT",
	[577]  = "DEMONHUNTER", [581]  = "DEMONHUNTER", [1480] = "DEMONHUNTER",
	[102]  = "DRUID",       [103]  = "DRUID",        [104]  = "DRUID",       [105] = "DRUID",
	[1467] = "EVOKER",      [1468] = "EVOKER",       [1473] = "EVOKER",
	[253]  = "HUNTER",      [254]  = "HUNTER",       [255]  = "HUNTER",
	[62]   = "MAGE",        [63]   = "MAGE",         [64]   = "MAGE",
	[268]  = "MONK",        [269]  = "MONK",         [270]  = "MONK",
	[65]   = "PALADIN",     [66]   = "PALADIN",      [70]   = "PALADIN",
	[256]  = "PRIEST",      [257]  = "PRIEST",       [258]  = "PRIEST",
	[259]  = "ROGUE",       [260]  = "ROGUE",        [261]  = "ROGUE",
	[262]  = "SHAMAN",      [263]  = "SHAMAN",       [264]  = "SHAMAN",
	[265]  = "WARLOCK",     [266]  = "WARLOCK",      [267]  = "WARLOCK",
	[71]   = "WARRIOR",     [72]   = "WARRIOR",      [73]   = "WARRIOR",
}

---Collects all unique spell IDs from rules, grouped by class token.
---@return table<string, number[]>  classToken -> ordered list of spell IDs
local function CollectSpellsByClass()
	local classSpells = {}
	local seen = {}

	local function addSpell(classToken, spellId)
		if not spellId or seen[spellId] then return end
		seen[spellId] = true
		classSpells[classToken] = classSpells[classToken] or {}
		table.insert(classSpells[classToken], spellId)
	end

	for specId, ruleList in pairs(rules.BySpec) do
		local classToken = specClass[specId]
		if classToken then
			for _, rule in ipairs(ruleList) do
				addSpell(classToken, rule.SpellId)
			end
		end
	end

	for classToken, ruleList in pairs(rules.ByClass) do
		for _, rule in ipairs(ruleList) do
			addSpell(classToken, rule.SpellId)
		end
	end

	return classSpells
end

---Builds the Spells tab content: a vertical class tab sidebar on the left,
---with the selected class's spell checkboxes displayed on the right.
---@param parent table  the spells sub-frame (already sized)
---@param disabledSpells table<number, boolean>  db.FcdDisabledSpells, modified in place
---@return number  total content height in pixels
local function BuildSpellsList(parent, disabledSpells)
	local sidebarW   = 120  -- width of the vertical class tab strip
	local sidebarSep = 8    -- gap between sidebar and spell content
	local classTabH  = 24   -- height of each class tab button
	local classTabGap = 1   -- gap between tab buttons
	local rowH   = 26
	local iconSz = 18

	local classSpells = CollectSpellsByClass()

	-- Disambiguation: spell names shared across any class get the spell ID appended.
	local nameCounts = {}
	for _, classToken in ipairs(classOrder) do
		local spells = classSpells[classToken]
		if spells then
			for _, spellId in ipairs(spells) do
				local name = C_Spell.GetSpellName(spellId)
				if name then nameCounts[name] = (nameCounts[name] or 0) + 1 end
			end
		end
	end

	-- Sidebar
	local sidebar = CreateFrame("Frame", nil, parent)
	sidebar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	sidebar:SetWidth(sidebarW)

	-- Build per-class spell panels (all parented to parent, shown/hidden on tab select)
	local classPanels = {}
	local maxContentH = 0
	local contentOffsetX = sidebarW + sidebarSep

	for _, classToken in ipairs(classOrder) do
		local spells = classSpells[classToken]
		if spells and #spells > 0 then
			local classPanel = CreateFrame("Frame", nil, parent)
			classPanel:SetPoint("TOPLEFT",  parent, "TOPLEFT",  contentOffsetX, 0)
			classPanel:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
			classPanel:Hide()
			classPanels[classToken] = classPanel

			local y = 0
			for _, spellId in ipairs(spells) do
				local spellName = C_Spell.GetSpellName(spellId) or ("Spell #" .. spellId)
				if nameCounts[spellName] and nameCounts[spellName] > 1 then
					spellName = spellName .. " (" .. spellId .. ")"
				end
				local texture = C_Spell.GetSpellTexture(spellId)

				local chk = mini:Checkbox({
					Parent    = classPanel,
					LabelText = spellName,
					GetValue  = function() return not disabledSpells[spellId] end,
					SetValue  = function(value)
						if value then
							disabledSpells[spellId] = nil
						else
							disabledSpells[spellId] = true
						end
						fcdDisplay:ResetStaticAbilitiesCache()
						fcdModule:RefreshDisplays()
					end,
				})
				chk:SetPoint("TOPLEFT", classPanel, "TOPLEFT", 26, y)

				if texture then
					local iconBtn = CreateFrame("Button", nil, classPanel)
					iconBtn:SetSize(iconSz, iconSz)
					iconBtn:SetPoint("RIGHT", chk, "LEFT", -2, 0)
					iconBtn:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetSpellByID(spellId)
						GameTooltip:Show()
					end)
					iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
					local icon = iconBtn:CreateTexture(nil, "ARTWORK")
					icon:SetAllPoints()
					icon:SetTexture(texture)
					icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				end

				y = y - rowH
			end

			local h = -y
			classPanel:SetHeight(h)
			maxContentH = math.max(maxContentH, h)
		end
	end

	-- Build vertical class tab buttons
	local classTabBtns = {}

	local function SetClassTabSelected(entry, selected)
		if selected then
			entry.btn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
			entry.accent:SetColorTexture(entry.r, entry.g, entry.b, 1)
		else
			entry.btn:SetBackdropColor(0, 0, 0, 0)
			entry.accent:SetColorTexture(entry.r, entry.g, entry.b, 0)
		end
	end

	local function SelectClass(classToken)
		for _, entry in ipairs(classTabBtns) do
			local isSelected = entry.classToken == classToken
			SetClassTabSelected(entry, isSelected)
			if classPanels[entry.classToken] then
				classPanels[entry.classToken]:SetShown(isSelected)
			end
		end
	end

	local tabY = 0
	local firstClass = nil
	for _, classToken in ipairs(classOrder) do
		local spells = classSpells[classToken]
		if spells and #spells > 0 then
			if not firstClass then firstClass = classToken end

			local cc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
			local r = cc and cc.r or 1
			local g = cc and cc.g or 1
			local b = cc and cc.b or 0.8

			local btn = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
			btn:SetHeight(classTabH)
			btn:SetPoint("TOPLEFT",  sidebar, "TOPLEFT",  0, tabY)
			btn:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, tabY)
			btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
			btn:SetBackdropColor(0, 0, 0, 0)

			local accent = btn:CreateTexture(nil, "OVERLAY")
			accent:SetWidth(2)
			accent:SetPoint("TOPLEFT",    btn, "TOPLEFT",    0, 0)
			accent:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
			accent:SetColorTexture(r, g, b, 0)

			local hl = btn:CreateTexture(nil, "HIGHLIGHT")
			hl:SetAllPoints()
			hl:SetColorTexture(1, 1, 1, 0.05)

			local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			fs:SetPoint("LEFT", btn, "LEFT", 8, 0)
			fs:SetText(classDisplayNames[classToken] or classToken)
			fs:SetTextColor(r, g, b, 1)

			local token = classToken
			btn:SetScript("OnClick", function() SelectClass(token) end)

			table.insert(classTabBtns, { btn = btn, accent = accent, classToken = classToken, r = r, g = g, b = b })
			tabY = tabY - classTabH - classTabGap
		end
	end

	local sidebarH = -tabY
	sidebar:SetHeight(sidebarH)

	if firstClass then SelectClass(firstClass) end

	parent.MiniRefresh = function()
		for _, cp in pairs(classPanels) do
			if cp.MiniRefresh then cp:MiniRefresh() end
		end
	end

	return math.max(sidebarH, maxContentH)
end

---@param panel table
---@param default FriendlyCooldownTrackerAnchorOptions
---@param raid FriendlyCooldownTrackerAnchorOptions
function M:Build(panel, default, raid)
	local db = mini:GetSavedVars()
	local options = db.Modules.FriendlyCooldownTrackerModule
	columnWidth = mini:ColumnWidth(columns, 0, 0)
	enabledColumnWidth = mini:ColumnWidth(5, 0, 0)

	local subPanelHeight = 321

	local description = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["Shows PvP trinket and friendly defensive cooldowns on party/raid frames."],
		},
	})
	description:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local enabledDivider = mini:Divider({ Parent = panel, Text = L["Enable in"] })
	enabledDivider:SetPoint("LEFT",  panel, "LEFT")
	enabledDivider:SetPoint("RIGHT", panel, "RIGHT")
	enabledDivider:SetPoint("TOP",   description, "BOTTOM", 0, -verticalSpacing)

	local enabledWorld = mini:Checkbox({
		Parent    = panel,
		LabelText = L["World"],
		Tooltip   = L["Enable this module in the open world."],
		GetValue  = function() return options.Enabled.World end,
		SetValue  = function(value) options.Enabled.World = value; config:Apply() end,
	})
	enabledWorld:SetPoint("TOPLEFT", enabledDivider, "BOTTOMLEFT", 0, -verticalSpacing)

	local enabledArena = mini:Checkbox({
		Parent    = panel,
		LabelText = L["Arena"],
		Tooltip   = L["Enable this module in arena."],
		GetValue  = function() return options.Enabled.Arena end,
		SetValue  = function(value) options.Enabled.Arena = value; config:Apply() end,
	})
	enabledArena:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth, 0)
	enabledArena:SetPoint("TOP",  enabledWorld, "TOP", 0, 0)

	local enabledBattleGrounds = mini:Checkbox({
		Parent    = panel,
		LabelText = L["Battlegrounds"],
		Tooltip   = L["Enable this module in battlegrounds."],
		GetValue  = function() return options.Enabled.BattleGrounds end,
		SetValue  = function(value) options.Enabled.BattleGrounds = value; config:Apply() end,
	})
	enabledBattleGrounds:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 2, 0)
	enabledBattleGrounds:SetPoint("TOP",  enabledWorld, "TOP", 0, 0)

	local enabledDungeons = mini:Checkbox({
		Parent    = panel,
		LabelText = L["Dungeons"],
		Tooltip   = L["Enable this module in dungeons."],
		GetValue  = function() return options.Enabled.Dungeons end,
		SetValue  = function(value) options.Enabled.Dungeons = value; config:Apply() end,
	})
	enabledDungeons:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 3, 0)
	enabledDungeons:SetPoint("TOP",  enabledWorld, "TOP", 0, 0)

	local enabledRaid = mini:Checkbox({
		Parent    = panel,
		LabelText = L["Raid"],
		Tooltip   = L["Enable this module in raids."],
		GetValue  = function() return options.Enabled.Raid end,
		SetValue  = function(value) options.Enabled.Raid = value; config:Apply() end,
	})
	enabledRaid:SetPoint("LEFT", panel, "LEFT", enabledColumnWidth * 4, 0)
	enabledRaid:SetPoint("TOP",  enabledWorld, "TOP", 0, 0)

	local tabContainer = CreateFrame("Frame", nil, panel)
	tabContainer:SetPoint("TOPLEFT",  enabledWorld, "BOTTOMLEFT", 0, -verticalSpacing)
	tabContainer:SetPoint("TOPRIGHT", panel,        "TOPRIGHT",   0, 0)
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
			{ Key = "spells",  Title = L["Spells"] },
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

	local spellsContent = tabCtrl:GetContent("spells")
	local disabledSpells = db.Modules.FriendlyCooldownTrackerModule.DisabledSpells
	local spellsContentHeight = BuildSpellsList(spellsContent, disabledSpells)

	-- Size the container to whichever tab needs the most vertical space.
	tabContainer:SetHeight(math.max(subPanelHeight, spellsContentHeight) + 34)

	panel.OnMiniRefresh = function()
		defaultPanel:MiniRefresh()
		raidPanel:MiniRefresh()
		spellsContent:MiniRefresh()
	end
end
