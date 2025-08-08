
local addonId, addonTable = ...
local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_ChartViewer")
local Details = Details
local detailsFramework = DetailsFramework
local ChartViewer = addonTable.ChartViewer
local ChartViewerWindowFrame = ChartViewerWindowFrame

local buildOptionsPanel = function()
	local pluginIcon = [[Interface\HELPFRAME\ReportLagIcon-Spells]]
	local pluginIconCoords = {0.15, 0.85, 0.15, 0.85}
	local optionsFrame = ChartViewer:CreatePluginOptionsFrame("ChartViewerOptionsWindow", Loc ["STRING_OPTIONS"], 3, pluginIcon, pluginIconCoords)

	local set = function (_, _, value)
		ChartViewer.options.show_method = value
		ChartViewer:CanShowOrHideButton()
	end

	local on_show_menu = {
		{value = 1, label = "Always", onclick = set, desc = "Always show the icon."},
		{value = 2, label = "In Group", onclick = set, desc = "Only show the icon while in group."},
		{value = 3, label = "Inside Raid", onclick = set, desc = "Only show the icon while inside a raid."},
		{value = 4, label = "Auto", onclick = set, desc = "The plugin decides when the icon needs to be shown."},
	}

	local menu = {
		{
			type = "select",
			get = function() return ChartViewer.options.show_method end,
			values = function() return on_show_menu end,
			desc = "When the icon is shown over Details! toolbar.",
			name = Loc ["STRING_OPTIONS_SHOWICON"]
		},
		{
			type = "range",
			get = function() return ChartViewer.options.window_scale end,
			set = function (self, fixedparam, value) ChartViewer.options.window_scale = value; ChartViewer:RefreshScale() end,
			min = 0.65,
			max = 1.50,
			step = 0.1,
			desc = "Set the window size",
			name = Loc ["STRING_OPTIONS_WINDOWSCALE"],
			usedecimals = true,
		},
	}

	local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

	detailsFramework:BuildMenu(optionsFrame, menu, 15, -75, 260, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
end

ChartViewer.OpenOptionsPanel = function()
	if (not ChartViewerOptionsWindow) then
		buildOptionsPanel()
		ChartViewerOptionsWindow:SetFrameStrata("FULLSCREEN")
	end

	ChartViewerOptionsWindow:Show()
end