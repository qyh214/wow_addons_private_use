
local addonId, addonTable = ...
local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_ChartViewer")

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local ipairs = ipairs

local detailsFramework = DetailsFramework
local Details = Details

local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local GetTime = GetTime
local wipe = wipe
local IsInRaid = IsInRaid
local UnitClass = UnitClass
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitName = UnitName
local GetInstanceInfo = GetInstanceInfo
local IsInGroup = IsInGroup
local C_Timer = C_Timer

--todo: transfer the chart to details framework charts
--todo: player damage done is using latest 5 segments, must guarantee that the chart is using the same boss segments

--Create the plugin Object
local ChartViewer = Details:NewPluginObject("Details_ChartViewer", DETAILSPLUGIN_ALWAYSENABLED)
--Main Frame
local CVF = ChartViewer.Frame

local ChartViewerWindowFrame = ChartViewerWindowFrame
detailsFramework:ApplyStandardBackdrop(ChartViewerWindowFrame)

addonTable.ChartViewer = ChartViewer

--desc
ChartViewer:SetPluginDescription(Loc ["STRING_PLUGIN_DESC"])

local plugin_version = "v4.00"

local function CreatePluginFrames(data)
	local closeButton = CreateFrame("Button", "ChartViewerWindowFrameCloseButton", ChartViewerWindowFrame, "UIPanelCloseButton")
	closeButton:SetWidth(20)
	closeButton:SetHeight(20)
	closeButton:SetPoint("TOPRIGHT", ChartViewerWindowFrame, "TOPRIGHT", -2, -3)
	closeButton:SetFrameLevel(ChartViewerWindowFrame:GetFrameLevel()+1)
	closeButton:GetNormalTexture():SetDesaturated(true)
	closeButton:SetAlpha(1)

	function ChartViewer:OnDetailsEvent(event, ...)
		if (event == "HIDE") then

		elseif (event == "SHOW") then
			if (not ChartViewerWindowFrame.OptionsButton) then
				local openOptionsButton = detailsFramework:NewButton(ChartViewerWindowFrame, nil, "$parentOptionsButton", "OptionsButton", 120, 20, ChartViewer.OpenOptionsPanel, nil, nil, nil, "Options")
				openOptionsButton:SetTextColor(1, 0.93, 0.74)
				openOptionsButton:SetIcon([[Interface\Buttons\UI-OptionsButton]], 14, 14, nil, {0, 1, 0, 1}, nil, 3)
				openOptionsButton:SetPoint("left", ChartViewer.NewTabButton, "right", 4, 0)
				openOptionsButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
				openOptionsButton:SetAlpha(0.8)
				openOptionsButton:SetFrameLevel(10)
			end
			ChartViewer:RefreshScale()

		elseif (event == "PLUGIN_DISABLED") then
			ChartViewer:HideButton()

		elseif (event == "PLUGIN_ENABLED") then
			ChartViewer:CanShowOrHideButton()
			if (ChartViewerWindowFrame and ChartViewerWindowFrame:IsShown()) then
				ChartViewer:RefreshScale()
			end

		elseif (event == "DETAILS_STARTED") then
			ChartViewer:CanShowOrHideButton()

		elseif (event == "DETAILS_DATA_RESET") then
			--drop the database
			for combatUniqueId in pairs(ChartViewerDB.chartData) do
				ChartViewerDB.chartData[combatUniqueId] = nil
			end

		elseif (event == "COMBAT_PLAYER_LEAVE") then
			local combatObject = select(1, ...)

			if (ChartViewer.ChartsCreated) then
				ChartViewer:TransferChartData(combatObject)
				ChartViewer.ChartsCreated = nil
			end

			ChartViewer:CheckFor_CreateNewTabForCombat()
			ChartViewer:CanShowOrHideButton()

		elseif (event == "COMBAT_PLAYER_ENTER") then --triggers after COMBAT_CHARTTABLES_CREATING and COMBAT_CHARTTABLES_CREATED
			ChartViewer:OnCombatEnter()

		elseif (event == "COMBAT_CHARTTABLES_CREATING") then
			---@alias chartname string
			---@type chartname[]
			ChartViewer.ChartsCreated = {}

			--tabs are the opened tabs in the plugin window
			for index, tab in ipairs(ChartViewer.tabs) do
				if (tab.data and tab.data:find("PRESET_")) then
					ChartViewer:BuildAndAddPresetFunction(tab.data)
				end
			end

		elseif (event == "COMBAT_CHARTTABLES_CREATED") then
			--erase data captures
			for i = #Details.savedTimeCaptures, 1, -1 do
				local t = Details.savedTimeCaptures[i]
				if (t[1]:find("PRESET_")) then
					Details:TimeDataUnregister(t[1])
				end
			end

		elseif (event == "DETAILS_INSTANCE_CHANGESEGMENT") then -- ... instance, segmentSlotId
			local instanceObject, segmentSlotId = ...
			if (instanceObject == Details:GetActiveWindowFromBreakdownWindow()) then
				ChartViewer:RefreshGraphic()
			end
		end
	end

	--check combat
	function ChartViewer:CheckFor_CreateNewTabForCombat()
		if (not ChartViewer.db.options.auto_create) then
			return
		end

		local combatObject = ChartViewer:GetCurrentCombat()
		if (combatObject) then
			--verifica se o comnate era arena, verifica se tem uma aba pra arena.
			if (combatObject.is_arena) then
				local has_arena_tab = false

				for _, tab in ChartViewer:GetAllTabs() do
					if (tab.iType and tab.iType:find("arena")) then
						has_arena_tab = true
						break
					end
				end

				if (not has_arena_tab) then
					--auto create an arena tab (two actually)
					local presets = ChartViewer:GetChartsForIType("arena", true)
					--print ("FOUND:", #presets, "presets.")
					for _, preset_name in ipairs(presets) do
						-- create chart for this preset
						local internal_options = ChartViewer:GetInternalOptionsForChart(preset_name)
						ChartViewer:CreateTab(internal_options.name, 1, preset_name, "line", internal_options, preset_name)
						--print ("Auto Created Arena Tab:", preset_name)
					end
				end

			elseif (combatObject.is_boss) then
				local has_raid_tab = false
				local role = UnitGroupRolesAssigned("player")
				local iType = "raid-" .. role

				for _, tab in ChartViewer:GetAllTabs() do
					if (tab.iType and tab.iType == iType) then
						has_raid_tab = true
						break
					end
				end

				if (not has_raid_tab) then
					local presets = ChartViewer:GetChartsForIType(iType)
					for _, preset_name in ipairs(presets) do
						-- create chart for this preset
						local internal_options = ChartViewer:GetInternalOptionsForChart(preset_name)
						ChartViewer:CreateTab(internal_options.name, 1, preset_name, "line", internal_options, preset_name)
						--print ("Auto Created Raid Tab:", preset_name)
					end
				end
			end
		end
	end

	--if is a boss encounter, force close the window
	local checkForBoss = function()
		local currentCombat = Details:GetCurrentCombat()
		local bossInfo = currentCombat:GetBossInfo()
		if (bossInfo) then
			if (CVF and CVF:IsShown()) then
				CVF:Hide()
			end
		end
	end

	function ChartViewer:OnCombatEnter()
		ChartViewer.current_on_combat = true
		ChartViewer.capturing_data = true
		C_Timer.After(1, checkForBoss)
	end

	--icon show functions
	function ChartViewer:ShowButton()
		if (not ChartViewer.ToolbarButton:IsShown()) then
			ChartViewer:ShowToolbarIcon (ChartViewer.ToolbarButton, "star")
		end
	end

	function ChartViewer:HideButton()
		if (ChartViewer.ToolbarButton:IsShown()) then
			ChartViewer:HideToolbarIcon(ChartViewer.ToolbarButton)
		end
	end

	function ChartViewer:RefreshScale()
		local scale = ChartViewer.options.window_scale
		if (ChartViewerWindowFrame) then
			ChartViewerWindowFrame:SetScale(scale)
		end
	end

	function ChartViewer:CanShowOrHideButton()
		if (not ChartViewer.__enabled) then
			return ChartViewer:HideButton()
		end

		if (self.options.show_method == 1) then --always show
			ChartViewer:ShowButton()

		elseif (self.options.show_method == 2) then --group
			if (IsInGroup() or IsInRaid()) then
				ChartViewer:ShowButton()
			else
				ChartViewer:HideButton()
			end

		elseif (self.options.show_method == 3) then --inside instances
			local _, instanceType = GetInstanceInfo()
			if (instanceType == "raid") then
				ChartViewer:ShowButton()
			else
				ChartViewer:HideButton()
			end

		elseif (self.options.show_method == 4) then --automatic
			local segmentsTable = Details:GetCombatSegments()
			for i = 1, #segmentsTable do
				local thisCombatObject = segmentsTable[i]
				if ( (not thisCombatObject.is_trash and thisCombatObject.is_boss and thisCombatObject.TimeData) or (thisCombatObject.is_arena)) then
					local charts = thisCombatObject.TimeData
					if (charts) then
						for id, chart in pairs(charts) do
							if (chart and chart[1] and chart[2]) then
								ChartViewer:ShowButton()
								return
							end
						end
					end
				end
			end

			ChartViewer:HideButton()
		end
	end

	ChartViewer.CanShowOrHideButtonEvents = {
		["GROUP_ROSTER_UPDATE"] = true,
		["ZONE_CHANGED_NEW_AREA"] = true,
		["PLAYER_ENTERING_WORLD"] = true,
	}

	function ChartViewer:CreateNewDataFeed(templateID)
		local name = ChartViewer.DataFeedTemplatesByIndex[templateID]
		local script = ChartViewer.DataFeedTemplates[name]

		if (script) then
			local result = ChartViewer:TimeDataRegister(name, script, nil, "Chart Viewer", "1.0", [[Interface\ICONS\TEMP]], true)
			if (type (result) == "string") then
				ChartViewer:Msg(result)
			else
				ChartViewer:Msg(Loc ["STRING_ADDEDOKAY"])
			end
		end
	end

    --window functions
	function ChartViewer.RefreshWindow()
		ChartViewer:TabRefresh()
	end

	--open window
	function ChartViewer:OpenWindow()
		ChartViewer.RefreshWindow()
		DetailsPluginContainerWindow.OpenPlugin(ChartViewer)
	end

    --create the icon
	local cooltipMenu = function()
		local gameCooltip = GameCooltip

		gameCooltip:Reset()
		gameCooltip:SetType("menu")

		gameCooltip:SetOption("TextSize", Details.font_sizes.menus)
		gameCooltip:SetOption("TextFont", Details.font_faces.menus)

		gameCooltip:SetOption("LineHeightSizeOffset", 3)
		gameCooltip:SetOption("VerticalOffset", 2)
		gameCooltip:SetOption("VerticalPadding", -4)
		gameCooltip:SetOption("FrameHeightSizeOffset", -3)

		Details:SetTooltipMinWidth()

		--> build the menu with the available tabs
			for index, tab in ipairs(ChartViewer.tabs) do
				gameCooltip:AddLine(tab.name .. " Graphic")
				gameCooltip:AddIcon([[Interface\Addons\Details_ChartViewer\icon]], 1, 1, 16, 16, 0, 1, 0, 1, "orange")

				gameCooltip:AddMenu(1, function()
					ChartViewer:OpenWindow()
					local tab = ChartViewer:TabGetButton(index)
					tab:Click()
					gameCooltip:Hide()
				end, "main")
			end

		--apply the backdrop settings to the menu
		Details:FormatCooltipBackdrop()
		gameCooltip:SetOwner(CHARTVIEWER_BUTTON, "bottom", "top", 0, 0)
		gameCooltip:ShowCooltip()
	end

	ChartViewer.ToolbarButton = Details.ToolBar:NewPluginToolbarButton(ChartViewer.OpenWindow, [[Interface\Addons\Details_ChartViewer\icon]], Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 14, 14, "CHARTVIEWER_BUTTON", cooltipMenu)
	ChartViewer.ToolbarButton.shadow = true
end

---when the combat is over, get from Details! the chart data created by ChartViewer and transfer it to the chart viewer database
function ChartViewer:TransferChartData(combatObject)
	local charts = {}

	for i = 1, #ChartViewer.ChartsCreated do
		local chartName = ChartViewer.ChartsCreated[i]
		local chartData = combatObject:GetTimeData(chartName)
		if (chartData) then
			charts[chartName] = chartData
			combatObject:EraseTimeData(chartName)
		end
	end

	local persistentCharts = {"Player Damage Done"}
	for i = 1, #persistentCharts do
		local chartName = persistentCharts[i]
		local chartData = combatObject:GetTimeData(chartName)
		if (chartData) then
			charts[chartName] = chartData
			--store when this chart was created to cleanup later
			chartData.__time = time()
			combatObject.TimeData[chartName] = nil
		end
	end

	local combatUniquieID = combatObject:GetCombatNumber()
	ChartViewerDB.chartData[combatUniquieID] = charts
end

function ChartViewer:OnEvent(_, event, ...)
	if (event == "ADDON_LOADED") then
		local AddonName = select(1, ...)
		if (AddonName == "Details_ChartViewer") then
			if (Details) then
				local version = 1

				---@class chartviewerdb : table
				---@field __version number
				---@field chartData table<number, table<string, number[]>>

				---@class chartviewertab : table
				---@field name string
				---@field segment_type number
				---@field version string
				---@field data string
				---@field texture string

				--savedvariables database
				if (not ChartViewerDB) then
					ChartViewerDB = {}
					ChartViewerDB.__version = version
					ChartViewerDB.chartData = {}
				else
					ChartViewerDB.chartData = ChartViewerDB.chartData or {}
				end

				--ChartViewerDB.chartData[combatUniquieID] = {[chartName1] = {number[]}, [chartName2] = {number[]}}

				--make a cleanup on saved charts
				local now = time()
				for combatUniqueId, charts in pairs(ChartViewerDB.chartData) do
					--check if details! still have a combat with the same id
					local bCombatExists = Details:DoesCombatWithUIDExists(combatUniqueId)
					if (not bCombatExists) then
						ChartViewerDB.chartData[combatUniqueId] = nil
					else
						--check if the data is already 48hrs old
						for chartName, chartData in pairs(charts) do
							if (chartData.__time) then
								if (now - chartData.__time > 60*60*24*2) then
									charts[chartName] = nil
								end
							end
						end
					end
				end

				--register player damage done chart data, this chart is persistent (recorded on all combats)
				ChartViewer:TimeDataRegister("Player Damage Done", ChartViewer.PlayerDamageDoneChartCode, nil, "Chart Viewer", "1.0", [[Interface\ICONS\Ability_MeleeDamage]], true)

				--create widgets
				CreatePluginFrames()

				--this is the minimal core version of Details! that this plugin need to work
				local MINIMAL_DETAILS_VERSION_REQUIRED = 153

				--install the plugin
				local install, saveddata, bIsEnabled = _G.Details:InstallPlugin(
					"TOOLBAR",
					Loc ["STRING_PLUGIN_NAME"],
					[[Interface\Addons\Details_ChartViewer\icon]],
					ChartViewer,
					"DETAILS_PLUGIN_CHART_VIEWER",
					MINIMAL_DETAILS_VERSION_REQUIRED,
					"Details! Team",
					plugin_version
				)

				if (type(install) == "table" and install.error) then
					print(Loc ["STRING_PLUGIN_NAME"], install.errortext)
					return
				end

				--C_Timer.After(3, function()dumpt (saveddata) end)

				--detect 1.x versions
				if (saveddata.tabs and saveddata.tabs[1] and saveddata.tabs[1].captures) then
					table.wipe(saveddata.tabs)
				end

				--build tab container
				saveddata.tabs = saveddata.tabs or {}
				saveddata.options = saveddata.options or {show_method = 4, window_scale = 1.0}
				if (saveddata.options.auto_create == nil) then
					saveddata.options.auto_create = true
				end

				ChartViewer.tabs = saveddata.tabs
				ChartViewer.options = saveddata.options

				ChartViewer.tabs.last_selected = ChartViewer.tabs.last_selected or 1

				ChartViewer.tab_container = {}

				if (#ChartViewer.tabs == 0) then
					ChartViewer.tabs[1] = {name = "Your Damage", segment_type = 2, data = "Player Damage Done", texture = "line", version = "v2.0"}
					ChartViewer.tabs[2] = {name = "Class Damage", segment_type = 1, data = "PRESET_DAMAGE_SAME_CLASS", texture = "line", version = "v2.0", iType = "raid-DAMAGER"}
					ChartViewer.tabs[3] = {name = "Raid Damage", segment_type = 2, data = "Raid Damage Done", texture = "line", version = "v2.0"}
				end

				--register wow events
				CVF:RegisterEvent("GROUP_ROSTER_UPDATE")
				CVF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
				CVF:RegisterEvent("PLAYER_ENTERING_WORLD")

				if (bIsEnabled) then
					ChartViewer:CanShowOrHideButton()
				else
					ChartViewer:HideButton()
				end

				--register details events
				Details:RegisterEvent(ChartViewer, "DETAILS_DATA_RESET")

				Details:RegisterEvent(ChartViewer, "COMBAT_PLAYER_LEAVE")
				Details:RegisterEvent(ChartViewer, "COMBAT_PLAYER_ENTER")

				Details:RegisterEvent(ChartViewer, "COMBAT_CHARTTABLES_CREATING")
				Details:RegisterEvent(ChartViewer, "COMBAT_CHARTTABLES_CREATED")

				Details:RegisterEvent(ChartViewer, "DETAILS_INSTANCE_CHANGESEGMENT")

				C_Timer.After(5, function()
					ChartViewer.CreateSegmentDropdown()
					ChartViewer.CreateAddTabPanel()
					ChartViewer.CreateAddTabButton()
					ChartViewer.NewTabPanel:Hide()
				end)

				ChartViewer.current_segment = 1

				--replace the built-in frame with the outside frame
				ChartViewer.Frame = _G.ChartViewerWindowFrame

				--summary for the breakdown window
				local onClickBreakdownButton = function()
					ChartViewer:OpenWindow()

				end
				local breakdownButton = detailsFramework:CreateButton(ChartViewer.Frame, onClickBreakdownButton, 1, 1, "Chart Viewer", "main")

				local texture = [[Interface\AddOns\Details_ChartViewer\charticon]]
				local textDistance = 1
				local leftPadding = 5
				local textHeight = 0
				local shortMethod = false
				breakdownButton:SetIcon(texture, 16, 16, "overlay", {0, 1, 0, 1}, {.5, .5, .5, 0.8}, textDistance, leftPadding, textHeight, shortMethod)

				_G.DetailsBreakdownWindow.RegisterPluginButton(breakdownButton, ChartViewer, "DETAILS_PLUGIN_CHART_VIEWER")

				C_Timer.After(5, function()
					ChartViewer:CreateTitleBarAndHeader()
				end)
			end
		end

	elseif (ChartViewer.CanShowOrHideButtonEvents[event]) then
		ChartViewer:CanShowOrHideButton()
	end
end

do
	local add_preset_player_healind_done = function()
		local code = [[
		local current_combat = Details:GetCombat ("current")
		local my_self = current_combat (2, Details.playername)
		return my_self and my_self.total or 0
		]]

		local chartName = "PRESET_PLAYER_HEAL~" .. Details.playername
		table.insert(ChartViewer.ChartsCreated, chartName)
		Details:TimeDataRegister(chartName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
	end

	local add_preset_raid_healind_done = function()
		local code = [[
		local current_combat = Details:GetCombat ("current")
		local total_healing = current_combat:GetTotal ( DETAILS_ATTRIBUTE_HEAL, nil, DETAILS_TOTALS_ONLYGROUP )
		return total_healing or 0]]

		local chartName = "PRESET_RAID_HEAL~Raid Healing Done"
		table.insert(ChartViewer.ChartsCreated, chartName)
		Details:TimeDataRegister (chartName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
	end

	local add_preset_damage_same_class = function()
		if (IsInRaid()) then
			local _, class = UnitClass ("player")
			for i = 1, GetNumGroupMembers() do
				local name, rank, subgroup, level, class2, class1, zone, online, isDead, _, isML, role = GetRaidRosterInfo (i)
				if (class == class1) then

					local playerName, realmName = UnitName ("raid" .. i)
					if (realmName and realmName ~= "") then
						playerName = playerName .. "-" .. realmName
					end

					--even my self
					local code = [[
					local current_combat = Details:GetCombat ("current")
					local my_self = current_combat (1, "PLAYERNAME")
					return my_self and my_self.total or 0]]
					code = code:gsub("PLAYERNAME", playerName)

					table.insert(ChartViewer.ChartsCreated, "PRESET_DAMAGE_SAME_CLASS~" .. playerName)
					Details:TimeDataRegister ("PRESET_DAMAGE_SAME_CLASS~" .. playerName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
				end
			end
		end
	end

	local add_preset_heal_same_class = function()
		if (IsInRaid()) then
			local _, class = UnitClass ("player")
			for i = 1, GetNumGroupMembers() do
				local name, rank, subgroup, level, class2, class1, zone, online, isDead, _, isML, role = GetRaidRosterInfo (i)
				if (class == class1) then
					local playerName, realmName = UnitName ("raid" .. i)
					if (realmName and realmName ~= "") then
						playerName = playerName .. "-" .. realmName
					end

					--even my self
					local code = [[
					local current_combat = Details:GetCombat ("current")
					local my_self = current_combat (2, "PLAYERNAME")
					return my_self and my_self.total or 0]]
					code = code:gsub("PLAYERNAME", playerName)

					table.insert(ChartViewer.ChartsCreated, "PRESET_HEAL_SAME_CLASS~" .. playerName)
					Details:TimeDataRegister ("PRESET_HEAL_SAME_CLASS~" .. playerName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
				end
			end
		end
	end

	local add_preset_all_damagers = function()
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				local name, rank, subgroup, level, class2, class1, zone, online, isDead, _, isML, role = GetRaidRosterInfo (i)
				if (role == "DAMAGER") then
					local playerName, realmName = UnitName ("raid" .. i)
					if (realmName and realmName ~= "") then
						playerName = playerName .. "-" .. realmName
					end

					--even my self
					local code = [[
					local current_combat = Details:GetCombat ("current")
					local my_self = current_combat (1, "PLAYERNAME")
					return my_self and my_self.total or 0]]
					code = code:gsub("PLAYERNAME", playerName)

					table.insert(ChartViewer.ChartsCreated, "PRESET_ALL_DAMAGERS~" .. playerName)
					Details:TimeDataRegister ("PRESET_ALL_DAMAGERS~" .. playerName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
				end
			end
		end
	end

	local add_preset_all_healers = function()
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				local name, rank, subgroup, level, class2, class1, zone, online, isDead, _, isML, role = GetRaidRosterInfo (i)
				if (role == "HEALER") then
					local playerName, realmName = UnitName ("raid" .. i)
					if (realmName and realmName ~= "") then
						playerName = playerName .. "-" .. realmName
					end

					--even my self
					local code = [[
					local current_combat = Details:GetCombat ("current")
					local my_self = current_combat (2, "PLAYERNAME")
					return my_self and my_self.total or 0]]
					code = code:gsub("PLAYERNAME", playerName)

					table.insert(ChartViewer.ChartsCreated, "PRESET_ALL_HEALERS~" .. playerName)
					Details:TimeDataRegister ("PRESET_ALL_HEALERS~" .. playerName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
				end
			end
		end
	end

	local add_preset_tank_damage_taken = function()
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				local name, rank, subgroup, level, class2, class1, zone, online, isDead, _, isML, role = GetRaidRosterInfo(i)

				if (role == "TANK") then
					local playerName, realmName = UnitName("raid" .. i)
					if (realmName and realmName ~= "") then
						playerName = playerName .. "-" .. realmName
					end

					--even my self
					local code = [[
					local current_combat = Details:GetCombat ("current")
					local my_self = current_combat (1, "PLAYERNAME")
					return my_self and my_self.damage_taken or 0]]
					code = code:gsub("PLAYERNAME", playerName)

					table.insert(ChartViewer.ChartsCreated, "PRESET_TANK_TAKEN~" .. playerName)
					Details:TimeDataRegister ("PRESET_TANK_TAKEN~" .. playerName, code, nil, "Chart Viewer 2.0", "v1.0", [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], true, true)
				end
			end
		end
	end

	function ChartViewer:BuildAndAddPresetFunction(presetName)
		if (presetName == "PRESET_PLAYER_HEAL") then
			add_preset_player_healind_done()

		elseif (presetName == "PRESET_RAID_HEAL") then
			add_preset_raid_healind_done()

		elseif (presetName == "PRESET_DAMAGE_SAME_CLASS") then
			add_preset_damage_same_class()

		elseif (presetName == "PRESET_HEAL_SAME_CLASS") then
			add_preset_heal_same_class()

		elseif (presetName == "PRESET_ALL_DAMAGERS") then
			add_preset_all_damagers()

		elseif (presetName == "PRESET_ALL_HEALERS") then
			add_preset_all_healers()

		elseif (presetName == "PRESET_TANK_TAKEN") then
			add_preset_tank_damage_taken()
		end
	end

	--player damage done chart code
	ChartViewer.PlayerDamageDoneChartCode = [[
		-- the goal of this script is get the current combat then get your character and extract your damage done.
		-- the first thing to do is get the combat, so, we use here the command "Details:GetCombat ( "overall" "current" or "segment number")"

		local current_combat = Details:GetCombat ("current") --getting the current combat

		-- the next step is request your character from the combat
		-- to do this, we take the combat which here we named "current_combat" and tells what we want inside parentheses.

		local my_self = current_combat (DETAILS_ATTRIBUTE_DAMAGE, Details.playername)

		-- Details.playername holds the name of your character.
		-- DETAILS_ATTRIBUTE_DAMAGE means we want the damage table, _HEAL _ENERGY _MISC is the other 3 tables.

		-- before we proceed, the result needs to be checked to make sure its a valid result.

		if (not my_self) then
			return 0 -- the combat doesnt have *you*, this happens when you didn't deal any damage in the combat yet.
		end

		-- now its time to get the total damage.

		local my_damage = my_self.total

		-- then finally return the amount to the capture.

		return my_damage
	]]

	ChartViewer.DataFeedTemplatesByIndex = {
		"Raid Damage Taken", "Raid Healing Done", "Raid Overheal"
	}

	ChartViewer.DataFeedTemplates = {
		["Raid Damage Taken"] = [[ -- this script takes the current combat and get the total of damage taken by the group.
		local damage_taken = 0

		--get the raid players on current combat
		local players = Details:GetActorsOnDamageCache()

		--add the damage taken from each player
		for _, player in ipairs(players) do
			damage_taken = damage_taken + player.damage_taken
		end

		--return the value
		return damage_taken
		]],

		["Raid Healing Done"] = [[ -- this script takes the current combat and request the total of healing done by the group.
		-- get the current combat
		local current_combat = Details:GetCombat ("current")

		-- get the total healing done from the combat
		local total_healing = current_combat:GetTotal ( DETAILS_ATTRIBUTE_HEAL, nil, DETAILS_TOTALS_ONLYGROUP )

		-- check if the result is valid
		if (not total_healing) then
			return 0
		else
			-- return the value
			return total_healing
		end
		]],

		["Raid Overheal"] = [[ -- this script get the total of overheal from the raid.
		local overheal = 0

		--get the raid players on current combat
		local players = Details:GetActorsOnHealingCache()

		--add the overheal from each player
		for _, player in ipairs(players) do
			overheal = overheal + player.totalover
		end

		--return the value
		return overheal
		]]
	}

	ChartViewer.PlayerIndividualChartCode = [[
		local current_combat = Details:GetCombat ("current") --getting the current combat
		local my_self = current_combat (DETAILS_ATTRIBUTE_DAMAGE, UnitName ("player"))
		if (not my_self) then
			return 0
		end
		local my_damage = my_self.total
		return my_damage or 0
	]]
end