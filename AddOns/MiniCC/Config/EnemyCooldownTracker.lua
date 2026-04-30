---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
local config = addon.Config

local ecdModule = addon.Modules.EnemyCooldowns.Module
local rules = addon.Modules.Cooldowns.Rules

local growOptions = { "LEFT", "RIGHT", "CENTER" }
local displayModeOptions = { "ArenaFrames", "Linear" }
local displayModeText = {
	ArenaFrames = "Arena Frames",
	Linear      = "Linear Bar",
}

-- Class display name/ordering tables (identical to FriendlyCooldownTracker).
local classDisplayNames = LocalizedClassList()

local classOrder = {
	"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER",
	"MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE",
	"SHAMAN", "WARLOCK", "WARRIOR",
}

-- Static spec ID -> class token mapping, matching the IDs declared in Rules.lua.
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

local columns = 4
local columnWidth

---Collects all unique spell IDs from defensive/important rules, grouped by class token.
---Only includes rules that EnemyCooldowns can actually track (BigDefensive, ExternalDefensive, or Important).
---@return table<string, number[]>  classToken -> ordered list of spell IDs
local function CollectSpellsByClass()
	local classSpells = {}
	local seen = {}

	local function addSpell(classToken, spellId, rule)
		if not spellId or seen[spellId] then return end
		if not (rule.BigDefensive or rule.ExternalDefensive or rule.Important) then return end
		seen[spellId] = true
		classSpells[classToken] = classSpells[classToken] or {}
		table.insert(classSpells[classToken], spellId)
	end

	for specId, ruleList in pairs(rules.BySpec) do
		local classToken = specClass[specId]
		if classToken then
			for _, rule in ipairs(ruleList) do
				addSpell(classToken, rule.SpellId, rule)
			end
		end
	end

	for classToken, ruleList in pairs(rules.ByClass) do
		for _, rule in ipairs(ruleList) do
			addSpell(classToken, rule.SpellId, rule)
		end
	end

	return classSpells
end

---Builds the Spells tab content: a vertical class tab sidebar on the left,
---with the selected class's spell checkboxes on the right.
---@param parent table  the spells sub-frame (already sized)
---@param disabledSpells table<number, boolean>  db.EcdDisabledSpells, modified in place
---@return number  total content height in pixels
local function BuildSpellsList(parent, disabledSpells)
	local sidebarW    = 120
	local sidebarSep  = 8
	local classTabH   = 24
	local classTabGap = 1
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
						ecdModule:RefreshDisplays()
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

---Builds the Settings tab content (display options, layout mode, arena frames anchoring).
---@param parent table
---@param options table  db.Modules.EnemyCooldownTrackerModule
---@return number  content height in pixels
local function AddSliderTooltip(slider, title, body)
	slider:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(title, 1, 0.82, 0)
		GameTooltip:AddLine(body, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	slider:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function AddDropdownTooltip(ddl, title, body)
	ddl:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(title, 1, 0.82, 0)
		GameTooltip:AddLine(body, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	ddl:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function BuildSettings(parent, options)
	local enabledChk = mini:Checkbox({
		Parent    = parent,
		LabelText = L["Enabled"],
		Tooltip   = L["Enable enemy cooldown tracking in arena."],
		GetValue  = function() return options.Enabled.Arena end,
		SetValue  = function(v) options.Enabled.Arena = v; config:Apply() end,
	})
	enabledChk:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

	local showTooltipsChk = mini:Checkbox({
		Parent    = parent,
		LabelText = L["Show tooltips"],
		Tooltip   = L["Show spell tooltips when hovering over cooldown icons."],
		GetValue  = function() return options.ShowTooltips end,
		SetValue  = function(v) options.ShowTooltips = v; config:Apply() end,
	})
	showTooltipsChk:SetPoint("LEFT", parent, "LEFT", columnWidth, 0)
	showTooltipsChk:SetPoint("TOP",  enabledChk, "TOP", 0, 0)

	local reverseChk = mini:Checkbox({
		Parent    = parent,
		LabelText = L["Reverse swipe"],
		Tooltip   = L["Reverse the cooldown swipe animation direction on icons."],
		GetValue  = function() return options.Icons.ReverseCooldown end,
		SetValue  = function(v) options.Icons.ReverseCooldown = v; config:Apply() end,
	})
	reverseChk:SetPoint("LEFT", parent, "LEFT", columnWidth * 2, 0)
	reverseChk:SetPoint("TOP",  enabledChk, "TOP", 0, 0)

	local iconSizeSlider = mini:Slider({
		Parent    = parent,
		LabelText = L["Icon Size"],
		Min = 10, Max = 100, Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue  = function() return options.Icons.Size end,
		SetValue  = function(v)
			local n = mini:ClampInt(v, 10, 100, 24)
			if options.Icons.Size ~= n then options.Icons.Size = n; config:Apply() end
		end,
	})
	iconSizeSlider.Slider:SetPoint("TOPLEFT", enabledChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)
	AddSliderTooltip(iconSizeSlider.Slider, L["Icon Size"], L["The display size of each cooldown icon in pixels."])

	local iconSpacingSlider = mini:Slider({
		Parent    = parent,
		LabelText = L["Icon Spacing"],
		Min = 0, Max = 20, Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue  = function() return options.IconSpacing end,
		SetValue  = function(v)
			local n = mini:ClampInt(v, 0, 20, 2)
			if options.IconSpacing ~= n then options.IconSpacing = n; config:Apply() end
		end,
	})
	iconSpacingSlider.Slider:SetPoint("LEFT", iconSizeSlider.Slider, "RIGHT", horizontalSpacing, 0)
	iconSpacingSlider.Slider:SetPoint("TOP",  iconSizeSlider.Slider, "TOP", 0, 0)
	AddSliderTooltip(iconSpacingSlider.Slider, L["Icon Spacing"], L["The spacing in pixels between each cooldown icon."])

	-- Display mode

	local modeLbl = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	modeLbl:SetText(L["Layout Mode"])
	modeLbl:SetPoint("TOPLEFT", iconSizeSlider.Slider, "BOTTOMLEFT", -4, -verticalSpacing * 2)

	-- Forward-declare so the modeDdl SetValue closure can reference it before creation.
	local setAfShown

	local modeDdl, modernModeDdl = mini:Dropdown({
		Parent   = parent,
		Items    = displayModeOptions,
		GetText  = function(v) return displayModeText[v] or v end,
		Width    = columnWidth * 2 - horizontalSpacing,
		GetValue = function() return options.DisplayMode end,
		SetValue = function(v)
			if options.DisplayMode ~= v then
				options.DisplayMode = v
				local isAf = v == "ArenaFrames"
				if setAfShown then setAfShown(isAf) end
				config:Apply()
			end
		end,
	})
	modeDdl:SetPoint("TOPLEFT", modeLbl, "BOTTOMLEFT", modernModeDdl and 0 or -16, -8)
	AddDropdownTooltip(modeDdl, L["Layout Mode"],
		L["Arena Frames: anchors icons next to each enemy's arena frame. Linear Bar: displays all cooldowns in a single combined bar."])

	-- Arena Frames layout options (hidden when Linear mode is selected).
	-- All controls are parented directly to parent and toggled individually to avoid
	-- WoW container-frame visibility propagation issues.

	local isArena = options.DisplayMode == "ArenaFrames"

	local afDivider = mini:Divider({ Parent = parent, Text = L["Arena Frames Anchoring"] })
	afDivider:SetPoint("LEFT",  parent, "LEFT")
	afDivider:SetPoint("RIGHT", parent, "RIGHT")
	afDivider:SetPoint("TOP",   modeDdl, "BOTTOM", 0, -verticalSpacing * 2)
	afDivider:SetShown(isArena)

	local afGrowLbl = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	afGrowLbl:SetText(L["Grow"])
	afGrowLbl:SetPoint("TOPLEFT", afDivider, "BOTTOMLEFT", 0, -verticalSpacing)
	afGrowLbl:SetShown(isArena)

	local afGrowDdl, modernAfGrow = mini:Dropdown({
		Parent = parent,
		Items  = growOptions,
		Width  = columnWidth * 2 - horizontalSpacing,
		GetValue = function() return options.ArenaFrames.Grow end,
		SetValue = function(v)
			if options.ArenaFrames.Grow ~= v then
				options.ArenaFrames.Grow = v
				config:Apply()
			end
		end,
	})
	afGrowDdl:SetPoint("TOPLEFT", afGrowLbl, "BOTTOMLEFT", modernAfGrow and 0 or -16, -8)
	afGrowDdl:SetShown(isArena)
	AddDropdownTooltip(afGrowDdl, L["Grow"], L["The direction cooldown icons grow from the arena frame anchor point."])

	local afOffsetXSlider = mini:Slider({
		Parent    = parent,
		LabelText = L["Offset X"],
		Min = -200, Max = 200, Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue  = function() return options.ArenaFrames.Offset.X end,
		SetValue  = function(v)
			local n = mini:ClampInt(v, -200, 200, 0)
			if options.ArenaFrames.Offset.X ~= n then options.ArenaFrames.Offset.X = n; config:Apply() end
		end,
	})
	afOffsetXSlider.Slider:SetPoint("TOPLEFT", afGrowDdl, "BOTTOMLEFT", 4, -verticalSpacing * 3)
	afOffsetXSlider.Slider:SetShown(isArena)
	afOffsetXSlider.EditBox:SetShown(isArena)
	AddSliderTooltip(afOffsetXSlider.Slider, L["Offset X"], L["Horizontal pixel offset from the arena frame anchor point."])

	local afOffsetYSlider = mini:Slider({
		Parent    = parent,
		LabelText = L["Offset Y"],
		Min = -200, Max = 200, Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue  = function() return options.ArenaFrames.Offset.Y end,
		SetValue  = function(v)
			local n = mini:ClampInt(v, -200, 200, 0)
			if options.ArenaFrames.Offset.Y ~= n then options.ArenaFrames.Offset.Y = n; config:Apply() end
		end,
	})
	afOffsetYSlider.Slider:SetPoint("LEFT", afOffsetXSlider.Slider, "RIGHT", horizontalSpacing, 0)
	afOffsetYSlider.Slider:SetPoint("TOP",  afOffsetXSlider.Slider, "TOP", 0, 0)
	afOffsetYSlider.Slider:SetShown(isArena)
	afOffsetYSlider.EditBox:SetShown(isArena)
	AddSliderTooltip(afOffsetYSlider.Slider, L["Offset Y"], L["Vertical pixel offset from the arena frame anchor point."])

	local entrySpacingSlider = mini:Slider({
		Parent    = parent,
		LabelText = L["Entry Spacing"],
		Min = 0, Max = 50, Step = 1,
		Width = columnWidth * 2 - horizontalSpacing,
		GetValue  = function() return options.EntrySpacing end,
		SetValue  = function(v)
			local n = mini:ClampInt(v, 0, 50, 4)
			if options.EntrySpacing ~= n then options.EntrySpacing = n; config:Apply() end
		end,
	})
	entrySpacingSlider.Slider:SetPoint("TOPLEFT", afOffsetXSlider.Slider, "BOTTOMLEFT", 0, -verticalSpacing * 3)
	entrySpacingSlider.Slider:SetShown(isArena)
	entrySpacingSlider.EditBox:SetShown(isArena)
	AddSliderTooltip(entrySpacingSlider.Slider, L["Entry Spacing"], L["Vertical spacing in pixels between each enemy's cooldown row."])

	setAfShown = function(shown)
		afDivider:SetShown(shown)
		afGrowLbl:SetShown(shown)
		afGrowDdl:SetShown(shown)
		afOffsetXSlider.Slider:SetShown(shown)
		afOffsetXSlider.EditBox:SetShown(shown)
		afOffsetYSlider.Slider:SetShown(shown)
		afOffsetYSlider.EditBox:SetShown(shown)
		entrySpacingSlider.Slider:SetShown(shown)
		entrySpacingSlider.EditBox:SetShown(shown)
	end

	-- Return the approximate height of all content.
	return 380
end

---@class EnemyCooldownTrackerConfig
local M = {}
config.EnemyCooldownTracker = M

---@param panel table
---@param options table  db.Modules.EnemyCooldownTrackerModule
function M:Build(panel, options)
	columnWidth = mini:ColumnWidth(columns, 0, 0)

	local description = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["Shows enemy arena opponent defensive and offensive cooldowns after their buffs expire."],
		},
	})
	description:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	-- Tab control

	local tabContainer = CreateFrame("Frame", nil, panel)
	tabContainer:SetPoint("TOPLEFT",  description, "BOTTOMLEFT", 0, -verticalSpacing)
	tabContainer:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)

	local tabCtrl = mini:CreateTabs({
		Parent = tabContainer,
		TabHeight = 28,
		StripHeight = 34,
		TabFitToParent = true,
		ContentInsets = { Top = verticalSpacing },
		Tabs = {
			{ Key = "settings", Title = L["Settings"] },
			{ Key = "spells",   Title = L["Spells"]   },
		},
	})

	local settingsContent = tabCtrl:GetContent("settings")
	local settingsHeight = BuildSettings(settingsContent, options)

	local spellsContent = tabCtrl:GetContent("spells")
	local spellsHeight = BuildSpellsList(spellsContent, options.DisabledSpells)

	tabContainer:SetHeight(math.max(settingsHeight, spellsHeight) + 34)

	panel.MiniRefresh = function()
		settingsContent:MiniRefresh()
		spellsContent:MiniRefresh()
	end
end
