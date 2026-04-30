---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
---@class MiscellaneousConfig
local M = {}
addon.Config.Miscellaneous = M

function M:Build(panel)
	local db = mini:GetSavedVars()
	local columns = 2
	local columnWidth = mini:ColumnWidth(columns, 0, 0)

	-- Language override
	local languageLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	languageLabel:SetText(L["Language override"])
	languageLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local availableLocales = L:GetAvailableLocales()
	local autoLabel = L["Auto (client language)"] .. " (" .. L:GetDisplayName(GetLocale()) .. ")"
	local dropdownItems = { autoLabel }
	local localeKeyMap = { [autoLabel] = false }

	for _, loc in ipairs(availableLocales) do
		local label = loc.Name .. " (" .. loc.Key .. ")"
		table.insert(dropdownItems, label)
		localeKeyMap[label] = loc.Key
	end

	local function GetCurrentLabel()
		local override = db.LocaleOverride
		if not override or override == false then
			return autoLabel
		end
		for _, item in ipairs(dropdownItems) do
			if localeKeyMap[item] == override then
				return item
			end
		end
		return autoLabel
	end

	local languageDropdown = mini:Dropdown({
		Parent = panel,
		Items = dropdownItems,
		GetValue = GetCurrentLabel,
		SetValue = function(value)
			local newKey = localeKeyMap[value]
			if newKey == db.LocaleOverride then
				return
			end
			db.LocaleOverride = newKey
			StaticPopup_Show("MINICC_RELOAD_CONFIRM")
		end,
	})

	languageDropdown:SetPoint("TOPLEFT", languageLabel, "BOTTOMLEFT", 0, -4)
	languageDropdown:SetWidth(columnWidth)

	-- Glow Type
	local glowTypeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	glowTypeLabel:SetText(L["Glow Type"])
	glowTypeLabel:SetPoint("TOPLEFT", languageDropdown, "BOTTOMLEFT", 0, -verticalSpacing * 2)

	local glowTypeDropdown = mini:Dropdown({
		Parent = panel,
		Items = { "Proc Glow", "Rotation Assist", "Pixel Glow", "Autocast Shine" },
		GetValue = function()
			return db.GlowType or "Proc Glow"
		end,
		SetValue = function(value)
			db.GlowType = value
			addon:Refresh()
		end,
	})

	glowTypeDropdown:SetPoint("TOPLEFT", glowTypeLabel, "BOTTOMLEFT", 0, -4)
	glowTypeDropdown:SetWidth(columnWidth)

	local glowNote = mini:TextBlock({
		Parent = panel,
		Lines = {
			L["The Proc Glow uses the least CPU."],
			L["The others seem to use a non-trivial amount of CPU."],
		},
	})

	glowNote:SetPoint("TOPLEFT", glowTypeDropdown, "BOTTOMLEFT", 0, -verticalSpacing)

	local fontScaleSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Font Scale"],
		Min = 0.5,
		Max = 1.5,
		Step = 0.05,
		GetValue = function()
			return db.FontScale or 1.0
		end,
		SetValue = function(value)
			local newValue = mini:ClampFloat(value, 0.5, 1.5, 1.0)
			if db.FontScale ~= newValue then
				db.FontScale = newValue
				addon:Refresh()
			end
		end,
		Width = columnWidth - horizontalSpacing,
	})

	fontScaleSlider.Slider:SetPoint("TOPLEFT", glowNote, "BOTTOMLEFT", 4, -verticalSpacing * 3)

	local iconSpacingSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Icon Padding"],
		Min = 0,
		Max = 20,
		Step = 1,
		GetValue = function()
			return db.IconSpacing or 2
		end,
		SetValue = function(value)
			local newValue = mini:ClampInt(value, 0, 20, 2)
			if db.IconSpacing ~= newValue then
				db.IconSpacing = newValue
				addon:Refresh()
			end
		end,
		Width = columnWidth - horizontalSpacing,
	})

	iconSpacingSlider.Slider:SetPoint("LEFT", fontScaleSlider.Slider, "RIGHT", horizontalSpacing, 0)
	iconSpacingSlider.Slider:SetPoint("TOP", fontScaleSlider.Slider, "TOP", 0, 0)

	local configureBlizzardNameplatesChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Configure Blizzard Nameplates"],
		Tooltip = L["Disables CC and BigDebuffs on Blizzard nameplates if using MiniCC nameplates."],
		GetValue = function()
			if db.ConfigureBlizzardNameplates == nil then
				return true
			end
			return db.ConfigureBlizzardNameplates
		end,
		SetValue = function(value)
			db.ConfigureBlizzardNameplates = value
			addon:Refresh()
		end,
	})

	configureBlizzardNameplatesChk:SetPoint("TOPLEFT", fontScaleSlider.Slider, "BOTTOMLEFT", -4, -verticalSpacing * 2)

	local ccNativeOrderChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["CC Native Order"],
		Tooltip = L["Instead of showing the latest CC applied (MiniCC behaviour), use Blizzard's default CC priority which usually shows the first CC applied (with some exceptions)."],
		GetValue = function()
			return db.CCNativeOrder or false
		end,
		SetValue = function(value)
			db.CCNativeOrder = value
			addon:Refresh()
		end,
	})

	ccNativeOrderChk:SetPoint("TOPLEFT", configureBlizzardNameplatesChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local disableSwipeChk = mini:Checkbox({
		Parent = panel,
		LabelText = L["Disable Swipe Animation"],
		Tooltip = L["Disables the cooldown swipe (pie chart) animation on all icons. The countdown timer text will still be shown."],
		GetValue = function()
			return db.DisableSwipe or false
		end,
		SetValue = function(value)
			db.DisableSwipe = value
			addon:Refresh()
		end,
	})

	disableSwipeChk:SetPoint("TOPLEFT", ccNativeOrderChk, "BOTTOMLEFT", 0, -verticalSpacing)

	local millisThresholdSlider = mini:Slider({
		Parent = panel,
		LabelText = L["Milliseconds Threshold"],
		Min = 1,
		Max = 6,
		Step = 1,
		GetValue = function()
			return db.MillisecondsThreshold or 5
		end,
		SetValue = function(value)
			local newValue = mini:ClampInt(value, 1, 6, 5)
			if db.MillisecondsThreshold ~= newValue then
				db.MillisecondsThreshold = newValue
				addon:Refresh()
			end
		end,
		Width = columnWidth - horizontalSpacing,
	})

	millisThresholdSlider.Slider:SetPoint("TOPLEFT", disableSwipeChk, "BOTTOMLEFT", 4, -verticalSpacing * 3)
end
