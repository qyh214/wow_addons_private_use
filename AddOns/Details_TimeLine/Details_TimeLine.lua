
local addonId, timeLine = ...
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details_TimeLine")
local Details = Details
local detailsFramework = _G.DetailsFramework

--create the plugin object
local TimeLine = Details:NewPluginObject("Details_TimeLine", _G.DETAILSPLUGIN_ALWAYSENABLED)
TimeLine:SetPluginDescription(Loc ["STRING_PLUGIN_DESC"])
TimeLine.version_string = "v109"
timeLine.PluginAbsoluteName = "DETAILS_PLUGIN_TIME_LINE"

local timeLineFrame = TimeLine.Frame
detailsFramework:ApplyStandardBackdrop(timeLineFrame)

local debugmode = false
local _

local wipe = table.wipe
local bitBand = bit.band
local CreateFrame = CreateFrame
local unpack = unpack

local _GetSpellInfo = Details.getspellinfo
local GetSpellInfo = GetSpellInfo

if (detailsFramework.IsWarWow() or (C_Spell and C_Spell.GetSpellInfo)) then
	GetSpellInfo = function(...)
		local result = C_Spell.GetSpellInfo(...)
		if result then
			return result.name, 1, result.iconID
		end
	end
end

local myName = UnitName("player")
local GameCooltip = GameCooltip
local date = date

local CONST_MENU_Y_POS = 24
local CONST_TIMELINE_LABELS_Y = 55
local CONST_LINE_START_Y = 52

--event frame
TimeLine.EventFrame = CreateFrame("frame")

--table.insert(UISpecialFrames, "Details_TimeLine")

local tabType_Cooldown = "cooldowns_timeline"
local tabType_Debuff = "debuff_timeline"
local tabType_EnemySpells = "spellcast_boss"
local tabType_BossSpells = "boss_spells"

local allDisplayTypes = {
	tabType_Cooldown,
	tabType_Debuff,
	tabType_EnemySpells,
	tabType_BossSpells
}

local red = {1, 0, 0, .25}
local green = {0, 1, 0, .25}

local class_icons_with_alpha = [[Interface\AddOns\Details\images\classes_small_alpha]]
local BUTTON_BACKGROUND_COLOR = {.5, .5, .5, .3}
local BUTTON_BACKGROUND_COLOR2 = {.4, .4, .4, .3}

local combatObject

--shortcut for current combat
local bIsInCombat = false

local function CreatePluginFrames()
	local DetailsPluginContainerWindow = DetailsPluginContainerWindow

	TimeLine.combat_data = {} --temp avoid errors on initialization

	if (not Details) then
		return
	end

	--templates
	local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

	detailsFramework.button_templates ["ADL_BUTTON_TEMPLATE"] = {
		backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
		backdropcolor = {.3, .3, .3, .9},
		onentercolor = {.6, .6, .6, .9},
		backdropbordercolor = {0, 0, 0, 1},
		onenterbordercolor = {0, 0, 0, 1},
	}

	options_button_template = detailsFramework:GetTemplate("button", "ADL_BUTTON_TEMPLATE")

	local currentSelectedType = allDisplayTypes[2]
	local currentSegment = 1

	local closeButton = detailsFramework:CreateCloseButton(timeLineFrame)
	closeButton:SetPoint("topright", timeLineFrame, "topright", -4, -6)

	--title bar
	local titleBar = CreateFrame("frame", nil, timeLineFrame, "BackdropTemplate")
	titleBar:SetPoint("topleft", timeLineFrame, "topleft", 2, -3)
	titleBar:SetPoint("topright", timeLineFrame, "topright", -2, -3)
	titleBar:SetHeight(20)
	titleBar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
	titleBar:SetBackdropColor(.5, .5, .5, 1)
	titleBar:SetBackdropBorderColor(0, 0, 0, 1)

	local nameBackgroundTexture = timeLineFrame:CreateTexture(nil, "background")
	nameBackgroundTexture:SetTexture([[Interface\PetBattles\_PetBattleHorizTile]], true)
	nameBackgroundTexture:SetHorizTile(true)
	nameBackgroundTexture:SetTexCoord(0, 1, 126/256, 19/256)
	nameBackgroundTexture:SetPoint("topleft", timeLineFrame, "topleft", 2, -22)
	nameBackgroundTexture:SetPoint("bottomright", timeLineFrame, "bottomright")
	nameBackgroundTexture:SetHeight(54)
	nameBackgroundTexture:SetVertexColor(0, 0, 0, 0.2)

	--window title
	local titleLabel = detailsFramework:NewLabel(titleBar, titleBar, nil, "titulo", "Details! Time Line", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	titleLabel:SetPoint("center", timeLineFrame, "center")
	titleLabel:SetPoint("top", timeLineFrame, "top", 0, -7)

	local search

	TimeLine.debuff_temp_table = {}
	TimeLine.current_enemy_spells = {}
	TimeLine.current_spells_individual = {}

	--record if button is shown
	TimeLine.showing = false
	TimeLine.open = false

	--record if boss window is open or not
	TimeLine.window_open = false
	TimeLine.rows = {}

	--new combat
	TimeLine.current_battle_cooldowns_timeline = {}

	--called on "COMBAT_PLAYER_ENTER" details event
	function TimeLine:NewCombat()
		TimeLine.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		TimeLine.current_battle_cooldowns_timeline = {}
		TimeLine.debuff_temp_table = {}
		TimeLine.current_enemy_spells = {}
		TimeLine.current_spells_individual = {}
	end

	function TimeLine:CanShowIcon()
		if (#TimeLine.combat_data > 0) then
			TimeLine:ShowIcon()
		else
			TimeLine:HideIcon()
		end
	end

	function TimeLine:FinishCombat(bIsCombatValid)
		TimeLine.EventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		if (not bIsCombatValid) then
			wipe(TimeLine.current_battle_cooldowns_timeline or {})
			wipe(TimeLine.debuff_temp_table or {})
			wipe(TimeLine.current_enemy_spells or {})
			wipe(TimeLine.current_spells_individual or {})
			return
		end

		--is in debug mode?
		if (debugmode and combatObject and not combatObject.is_boss) then
			combatObject.is_boss = {
				index = 1,
				name = Details:GetBossName(1098, 1),
				zone = "Throne of Thunder",
				mapid = 1098,
				encounter = "Jin'Rohk the Breaker"
			}
		end

		--is a boss encounter
		if (combatObject and combatObject.is_boss) then
			--combat information
			table.insert(TimeLine.combat_data, 1, {})

			--save the encounter elapsed time
			TimeLine.combat_data[1].total_time = combatObject:GetCombatTime()

			--save the encounter name
			local boss = combatObject.is_boss
			if (boss) then
				TimeLine.combat_data[1].name = boss.name
			else
				TimeLine.combat_data[1].name = combatObject.enemy
			end

			--save the date
			local startDate, endDate = combatObject:GetDate()
			TimeLine.combat_data[1].date_start = startDate or date("%H:%M:%S")
			TimeLine.combat_data[1].date_end = endDate or date("%H:%M:%S")

			--cooldowns
			table.insert(TimeLine.cooldowns_timeline, 1, TimeLine.current_battle_cooldowns_timeline)

			--debuffs - close opened debuffs
			for playerName, playerTable in pairs(TimeLine.debuff_temp_table) do
				for spellId, spellTable in pairs(playerTable) do
					if (spellTable.active) then
						spellTable.active = false
						table.insert(spellTable, combatObject:GetCombatTime())
					end
				end
			end

			--debufs - store debuff data
			table.insert(TimeLine.debuff_timeline, 1, TimeLine.debuff_temp_table)

			--boss spells
			table.insert(TimeLine.spellcast_boss, 1, TimeLine.current_enemy_spells)
			table.insert(TimeLine.boss_spells, 1, TimeLine.current_spells_individual)

			--deaths
			local deaths = {}
			local deathList = combatObject:GetDeaths()

			for i, deathTable in ipairs(deathList) do
				local thisDeath = {}
				local timeOfDeath = deathTable[2]
				local playerName = deathTable[3]
				local lastEvents = {}

				for eventIndex = #deathTable[1], 1, -1 do
					local damageEvent = deathTable[1][eventIndex]
					if (type(damageEvent[1]) == "boolean" and damageEvent[1]) then
						local time = damageEvent[4]
						if (time + 8 > timeOfDeath) then
							table.insert(lastEvents, 1, damageEvent)
							if (#lastEvents >= 3) then
								break
							end
						end
					end
				end

				thisDeath.time = deathTable.dead_at
				thisDeath.events = lastEvents

				if (not deaths[playerName]) then
					deaths[playerName] = {}
				end
				table.insert(deaths[playerName], thisDeath)
			end

			table.insert(TimeLine.deaths_data, 1, deaths)

			--limit segments
			if (#TimeLine.cooldowns_timeline > TimeLine.db.max_segments) then
				table.remove(TimeLine.cooldowns_timeline, TimeLine.db.max_segments+1)
				table.remove(TimeLine.debuff_timeline, TimeLine.db.max_segments+1)
				table.remove(TimeLine.combat_data, TimeLine.db.max_segments+1)
				table.remove(TimeLine.deaths_data, TimeLine.db.max_segments+1)
				table.remove(TimeLine.spellcast_boss, TimeLine.db.max_segments+1)
			end

			--show icon
			if (TimeLine.open) then
				TimeLine:Refresh()
			end

			TimeLine:ShowIcon()
		else
			--discart cooldown table
			wipe(TimeLine.current_battle_cooldowns_timeline or {})
			wipe(TimeLine.debuff_temp_table or {})
			wipe(TimeLine.current_enemy_spells or {})
			wipe(TimeLine.current_spells_individual or {})
		end
	end

	function TimeLine:OnDetailsEvent(event, ...)
		if (event == "HIDE") then --plugin hidded, disabled
			self.open = false

		elseif (event == "SHOW") then --plugin hidded, disabled
			self.open = true
			TimeLine:RefreshScale()

		elseif (event == "COMBAT_PLAYER_ENTER") then --combat started
			combatObject = select(1, ...)
			if (not combatObject and Details) then
				combatObject = Details:GetCurrentCombat()
				if (not combatObject) then
					return
				end
			end

			--create the tables to store the data of this combat
			TimeLine:NewCombat()
			bIsInCombat = true

		elseif (event == "COMBAT_INVALID") then
			--when a combat got invalidated for some reason, when it happen, this event is guaranteed to be called before COMBAT_PLAYER_LEAVE
			local bIsCombatValid = false
			TimeLine:FinishCombat(bIsCombatValid)
			bIsInCombat = false

		elseif (event == "COMBAT_PLAYER_LEAVE") then
			if (bIsInCombat) then
				local bIsCombatValid = true
				TimeLine:FinishCombat(bIsCombatValid)
				bIsInCombat = false
			end

		elseif (event == "DETAILS_DATA_RESET") then
			wipe(TimeLine.cooldowns_timeline)
			wipe(TimeLine.combat_data)
			wipe(TimeLine.debuff_timeline)
			wipe(TimeLine.deaths_data)

			TimeLine:Refresh()
			TimeLine:CloseWindow()
			TimeLine:HideIcon()

		elseif (event == "DETAILS_STARTED") then
			TimeLine:CanShowIcon()

		elseif (event == "PLUGIN_DISABLED") then
			TimeLine:HideIcon()
			TimeLine:CloseWindow()
			timeLineFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		elseif (event == "PLUGIN_ENABLED") then
			timeLineFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			TimeLine:CanShowIcon()
		end
	end

	--show icon on toolbar
	function TimeLine:ShowIcon()
		TimeLine.showing = true
		--[1] button to show [2] button animation: "star", "blink" or true(blink)
		TimeLine:ShowToolbarIcon(TimeLine.ToolbarButton, "star")
	end

	-- hide icon on toolbar
	function TimeLine:HideIcon()
		TimeLine.showing = false
		TimeLine:HideToolbarIcon(TimeLine.ToolbarButton)
	end

	function TimeLine:DelaySegmentRefresh()
		for index, combat in ipairs(TimeLine.combat_data) do
			if (combat.name) then
				return Details_TimeLineSegmentDropdown.MyObject:Select(currentSegment, true)
			end
		end
	end

	function TimeLine.RefreshWindow()
		--refresh it
		TimeLine:Refresh()

		--refresh segments dropdown
		TimeLine:ScheduleTimer("DelaySegmentRefresh", 1)

		return true
	end

	--user clicked on button, need open or close window
	function TimeLine:OpenWindow()
		if (TimeLine.Frame:IsShown()) then
			return TimeLine:CloseWindow()
		else
			TimeLine.open = true
		end

		--build all window data
		TimeLine:Refresh()

		TimeLine:ScheduleTimer("DelaySegmentRefresh", 0.5)

		DetailsPluginContainerWindow.OpenPlugin(TimeLine)

		--hide cooltip
		GameCooltip:Hide()

		return true
	end

	function TimeLine:CloseWindow()
		--TimeLineFrame:Hide()
		DetailsPluginContainerWindow.ClosePlugin()
		TimeLine.open = false
		return true
	end

	local cooltip_menu = function()
		GameCooltip:Reset()
		GameCooltip:SetType("menu")

		GameCooltip:SetOption("TextSize", Details.font_sizes.menus)
		GameCooltip:SetOption("TextFont", Details.font_faces.menus)

		GameCooltip:SetOption("LineHeightSizeOffset", 3)
		GameCooltip:SetOption("VerticalOffset", 2)
		GameCooltip:SetOption("VerticalPadding", -4)
		GameCooltip:SetOption("FrameHeightSizeOffset", -3)

		Details:SetTooltipMinWidth()

		--build the menu options
			--debuffs
			GameCooltip:AddLine("Enemy Debuff Timeline")
			GameCooltip:AddMenu(1, function()
				DetailsPluginContainerWindow.OpenPlugin(TimeLine)
				currentSelectedType = tabType_Debuff
				TimeLine:Refresh()
				TimeLine:RefreshButtons()
				TimeLine:ScheduleTimer("DelaySegmentRefresh", 0.5)
				GameCooltip:Hide()
			end, "main")
			GameCooltip:AddIcon([[Interface\ICONS\Spell_Shadow_ShadowWordPain]], 1, 1, 16, 16, 5/64, 59/64, 5/64, 59/64)

			--cooldowns
			GameCooltip:AddLine("Raid Cooldown Timeline")
			GameCooltip:AddMenu(1, function()
				DetailsPluginContainerWindow.OpenPlugin(TimeLine)
				currentSelectedType = tabType_Cooldown
				TimeLine:Refresh()
				TimeLine:RefreshButtons()
				TimeLine:ScheduleTimer("DelaySegmentRefresh", 0.5)
				GameCooltip:Hide()
			end, "graph")
			GameCooltip:AddIcon([[Interface\ICONS\Spell_Holy_GuardianSpirit]], 1, 1, 16, 16, 5/64, 59/64, 5/64, 59/64)

			--enemy spells
			GameCooltip:AddLine("Enemy Cast Timeline")
			GameCooltip:AddMenu(1, function()
				DetailsPluginContainerWindow.OpenPlugin(TimeLine)
				currentSelectedType = tabType_EnemySpells
				TimeLine:Refresh()
				TimeLine:RefreshButtons()
				TimeLine:ScheduleTimer("DelaySegmentRefresh", 0.5)
				GameCooltip:Hide()
			end, "graph")
			GameCooltip:AddIcon([[Interface\ICONS\Spell_Shadow_SummonVoidWalker]], 1, 1, 16, 16, 5/64, 59/64, 5/64, 59/64)

			--spell individual
			GameCooltip:AddLine("Enemy Spells Timeline")
			GameCooltip:AddMenu(1, function()
				DetailsPluginContainerWindow.OpenPlugin(TimeLine)
				currentSelectedType = tabType_BossSpells
				TimeLine:Refresh()
				TimeLine:RefreshButtons()
				TimeLine:ScheduleTimer("DelaySegmentRefresh", 0.5)
				GameCooltip:Hide()
			end, "graph")
			GameCooltip:AddIcon([[Interface\ICONS\Spell_Shadow_Requiem]], 1, 1, 16, 16, 5/64, 59/64, 5/64, 59/64)

		--apply the backdrop settings to the menu
		Details:FormatCooltipBackdrop()
		GameCooltip:SetOwner(TIMELINE_BUTTON, "bottom", "top", 0, 0)
		GameCooltip:ShowCooltip()
	end

	--create the button to show on toolbar [1] function OnClick [2] texture [3] tooltip [4] width or 14 [5] height or 14 [6] frame name or nil
	TimeLine.ToolbarButton = Details.ToolBar:NewPluginToolbarButton(TimeLine.OpenWindow, [[Interface\Addons\Details_TimeLine\icon]], Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 12, 12, "TIMELINE_BUTTON", cooltip_menu)
	TimeLine.ToolbarButton.shadow = true

	--setpoint anchors mod if needed
	TimeLine.ToolbarButton.y = 0
	TimeLine.ToolbarButton.x = 0

	--build main frame
	timeLineFrame:SetFrameStrata("HIGH")
	timeLineFrame:SetToplevel(true)

	timeLineFrame:SetPoint("center", UIParent, "center", 0, 0)

	timeLineFrame.Width = 925
	timeLineFrame.Height = 575

	local CONST_TOTAL_TIMELINES = 21 --timers shown in the top of the window
	local CONST_ROW_HEIGHT = 18
	local CONST_VALID_WIDHT = 784
	local CONST_PLAYERFIELD_SIZE = 96
	local CONST_VALID_HEIGHT = 528

	local mode_buttons_width = 120
	local mode_buttons_height = 20

	timeLineFrame:SetSize(timeLineFrame.Width, timeLineFrame.Height)

	--[=
	timeLineFrame:EnableMouse(true)
	timeLineFrame:SetResizable(false)
	timeLineFrame:SetMovable(true)
	timeLineFrame:SetScript("OnMouseDown",
					function(self, botao)
						if (botao == "LeftButton") then
							if (self.isMoving) then
								return
							end
							self:StartMoving()
							self.isMoving = true

						elseif (botao == "RightButton") then
							if (self.isMoving) then
								return
							end
							TimeLine:CloseWindow()
						end
					end)

	timeLineFrame:SetScript("OnMouseUp",
					function(self)
						if (self.isMoving) then
							self:StopMovingOrSizing()
							self.isMoving = false
						end
					end)

	--
	--]=]

	timeLineFrame:SetBackdrop(Details.PluginDefaults and Details.PluginDefaults.Backdrop or {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
	insets = {left = 1, right = 1, top = 1, bottom = 1}})

	timeLineFrame:SetBackdropColor(unpack(Details.PluginDefaults and Details.PluginDefaults.BackdropColor or {0, 0, 0, .6}))
	timeLineFrame:SetBackdropBorderColor(unpack(Details.PluginDefaults and Details.PluginDefaults.BackdropBorderColor or {0, 0, 0, 1}))

	timeLineFrame.bg1 = timeLineFrame:CreateTexture(nil, "background")
	timeLineFrame.bg1:SetTexture([[Interface\AddOns\Details\images\background]], true)
	timeLineFrame.bg1:SetAlpha(0.7)
	timeLineFrame.bg1:SetVertexColor(0.27, 0.27, 0.27)
	timeLineFrame.bg1:SetVertTile(true)
	timeLineFrame.bg1:SetHorizTile(true)
	timeLineFrame.bg1:SetAllPoints()

	local gradientBelowTheLine = detailsFramework:CreateTexture(timeLineFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.2}, toColor = "transparent"}, 1, 95, "artwork", {0, 1, 0, 1}, "gradientBelowTheLine")
	gradientBelowTheLine:SetPoint("bottoms")

	-- statusbar below the timeline chart
	TimeLine.Times = {}
	for i = 1, CONST_TOTAL_TIMELINES do
		local timeLabel = detailsFramework:NewLabel(timeLineFrame, nil, "$parentTime"..i, nil, "00:00")
		timeLabel:SetPoint("topleft", timeLineFrame, "topleft", (CONST_PLAYERFIELD_SIZE - 29) + (i * 39), -CONST_TIMELINE_LABELS_Y)
		TimeLine.Times[i] = timeLabel
		timeLabel.fontsize = 10
		timeLabel.fontcolor = "white"
		timeLabel.alpha = 1

		local line = detailsFramework:NewImage(timeLineFrame, nil, 1, CONST_VALID_HEIGHT, "border", nil, nil, "$parentTime"..i.."Bar")
		line:SetColorTexture(1, 1, 1, .15)
		line:SetPoint("topleft", timeLabel, "topleft", 0, -10)
	end

	function TimeLine:UpdateTimeLine(totalTime)
		local linha = TimeLine.Times[CONST_TOTAL_TIMELINES]
		local minutes, seconds = math.floor(totalTime / 60), math.floor(totalTime % 60)
		local secondsString = tostring(seconds)
		local minutesString = tostring(minutes)

		if (seconds < 10) then
			secondsString = "0" .. seconds
		end

		if (minutes > 0) then
			if (minutes < 10) then
				minutesString = "0" .. minutes
			end
			linha:SetText(minutesString .. ":" .. secondsString)
		else
			linha:SetText("00:" .. secondsString)
		end

		local timeDivision = totalTime /(CONST_TOTAL_TIMELINES - 1) --786 -- 49.125

		for i = 2, CONST_TOTAL_TIMELINES -1 do
			local line = TimeLine.Times[i]
			local thisTime = timeDivision *(i-1)
			local amountMinutes, amountSeconds = math.floor(thisTime / 60), math.floor(thisTime % 60)

			if (amountSeconds < 10) then
				amountSeconds = "0" .. amountSeconds
			end

			if (amountMinutes > 0) then
				if (amountMinutes < 10) then
					amountMinutes = "0" .. amountMinutes
				end
				line:SetText(amountMinutes .. ":" .. amountSeconds)
			else
				line:SetText("00:" .. amountSeconds)
			end
		end
	end

	--dropdown select type(label)
		local select_type_label = detailsFramework:NewLabel(timeLineFrame, nil, "$parentTypeLabel", nil, Loc ["STRING_TYPE"])
	--dropdown select type(dropdown)
		local selectTypeOption = function(_, _, selected)
			currentSelectedType = selected
			TimeLine:Refresh()
		end

		local type_menu = {
			{value = tabType_Cooldown, label = Loc ["STRING_TYPE_COOLDOWN"], onclick = selectTypeOption, icon = [[Interface\ICONS\Spell_Holy_GuardianSpirit]]},
			{value = tabType_Debuff, label = Loc ["STRING_TYPE_DEBUFF"], onclick = selectTypeOption, icon = [[Interface\ICONS\Spell_Shadow_ShadowWordPain]]}
		}
		local buildTypeMenu = function()
			return type_menu
		end

		local select_type_dropdown = detailsFramework:NewDropDown(timeLineFrame, nil, "$parentTypeDropdown", nil, 120, 20, buildTypeMenu, 1, options_dropdown_template)

	--dropdown select combat(dropdown)
		local selectCombatOption = function(_, _, segment)
			currentSegment = segment
			TimeLine:Refresh()
		end

		local buildCombatMenu = function()
			local t = {}
			for index, combat in ipairs(TimeLine.combat_data) do
				--[=[
					combat:
					["date_end"] = "22:50:45",
					["date_start"] = "22:45:04",
					["name"] = "Echo of Neltharion",
					["total_time"] = 340.691,
					--]=]
				if (combat.name) then
					local amountMinutes, amountSeconds = math.floor(combat.total_time/60), math.floor(combat.total_time%60)
					local bossIcon = Details:GetBossEncounterTexture(combat.name) or ""
					t [#t+1] = {value = index, label = combat.name, onclick = selectCombatOption, icon = bossIcon, iconsize = {32, 20}, texcoord = {0, 1, 0, 0.9}, desc = amountMinutes .. "m " .. amountSeconds .. "s " .. "(" ..(combat.date_start or "") .. " - " ..(combat.date_end or "") .. ")"}
				end
			end
			return t
		end
		local selectSegmentDropdown = detailsFramework:NewDropDown(timeLineFrame, nil, "$parentSegmentDropdown", nil, 150, 20, buildCombatMenu, nil, options_dropdown_template)

	--select which tab is shown (cooldowns, debuffs, enemy cast, enemy spells)
		local selectWhatToShow = function(_, _, mode)
			currentSelectedType = mode
			TimeLine:Refresh()
			TimeLine:RefreshButtons()
		end

	--select Cooldowns button
		local iconSize = 14
		local leftPadding = 0
		local textDistance = 4

		--header background
		local headerFrame = CreateFrame("frame", "EncounterDetailsHeaderFrame", timeLineFrame, "BackdropTemplate")
		headerFrame:EnableMouse(false)
		headerFrame:SetPoint("topleft", titleBar, "bottomleft", -1, -1)
		headerFrame:SetPoint("topright", titleBar, "bottomright", 1, -1)
		headerFrame:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
		headerFrame:SetBackdropColor(.7, .7, .7, .4)
		headerFrame:SetHeight(46)

		local gradientTop = detailsFramework:CreateTexture(headerFrame,
		{gradient = "vertical", fromColor = {0, 0, 0, 0.5}, toColor = "transparent"}, 1, 48, "artwork", {0, 1, 0, 1})
		gradientTop:SetPoint("bottoms", 1, 1)
		timeLineFrame.gradientTop = gradientTop

		local showCooldownsButton = detailsFramework:NewButton(timeLineFrame, _, "$parentModeCooldownsButton", "ModeCooldownsButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_Cooldown, nil, nil, "Cooldowns", 1)
		showCooldownsButton:SetPoint("topleft", timeLineFrame, "topleft", 2, -CONST_MENU_Y_POS)
		showCooldownsButton:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		showCooldownsButton:SetIcon([[Interface\ICONS\Spell_Holy_GuardianSpirit]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
		showCooldownsButton.icon:SetSize(iconSize, iconSize)
			--cooldown button for the breakdown window
			local showCooldownsButtonBreakdown = detailsFramework:NewButton(timeLineFrame, _, "$parentModeCooldownsButtonBreakdown", "ModeCooldownsButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_Cooldown, nil, nil, "Cooldowns", 1)
			showCooldownsButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			showCooldownsButtonBreakdown:SetIcon([[Interface\ICONS\Spell_Holy_GuardianSpirit]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
			showCooldownsButtonBreakdown.icon:SetSize(iconSize, iconSize)
			_G.DetailsBreakdownWindow.RegisterPluginButton(showCooldownsButtonBreakdown, TimeLine, timeLine.PluginAbsoluteName)

		local showDebuffsButton = detailsFramework:NewButton(timeLineFrame, _, "$parentModeDebuffsButton", "ModeDebuffsButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_Debuff, nil, nil, "Debuffs", 1, options_button_template)
		showDebuffsButton:SetPoint("bottomleft", showCooldownsButton, "bottomright", 2, 0)
		showDebuffsButton:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		showDebuffsButton:SetIcon([[Interface\ICONS\Spell_Shadow_ShadowWordPain]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
		showDebuffsButton.icon:SetSize(iconSize, iconSize)
			--debuffs button for the breakdown window
			local showDebuffsButtonBreakdown = detailsFramework:NewButton(timeLineFrame, _, "$parentModeDebuffsButtonBreakdown", "ModeDebuffsButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_Debuff, nil, nil, "Debuffs", 1, options_button_template)
			showDebuffsButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			showDebuffsButtonBreakdown:SetIcon([[Interface\ICONS\Spell_Shadow_ShadowWordPain]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
			showDebuffsButtonBreakdown.icon:SetSize(iconSize, iconSize)
			_G.DetailsBreakdownWindow.RegisterPluginButton(showDebuffsButtonBreakdown, TimeLine, timeLine.PluginAbsoluteName)

		local showEnemyspellsButton = detailsFramework:NewButton(timeLineFrame, _, "$parentModeEnemyCastButton", "ModeEnemyCastButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_EnemySpells, nil, nil, "Enemy Cast", 1, options_button_template)
		showEnemyspellsButton:SetPoint("bottomleft", showDebuffsButton, "bottomright", 2, 0)
		showEnemyspellsButton:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		showEnemyspellsButton:SetIcon([[Interface\ICONS\Spell_Shadow_SummonVoidWalker]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
		showEnemyspellsButton.icon:SetSize(iconSize, iconSize)
			--enemies button for the breakdown window
			local showEnemyspellsButtonBreakdown = detailsFramework:NewButton(timeLineFrame, _, "$parentModeEnemyCastButtonBreakdown", "ModeEnemyCastButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_EnemySpells, nil, nil, "Enemy Cast", 1, options_button_template)
			showEnemyspellsButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			showEnemyspellsButtonBreakdown:SetIcon([[Interface\ICONS\Spell_Shadow_SummonVoidWalker]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
			showEnemyspellsButtonBreakdown.icon:SetSize(iconSize, iconSize)
			_G.DetailsBreakdownWindow.RegisterPluginButton(showEnemyspellsButtonBreakdown, TimeLine, timeLine.PluginAbsoluteName)

		local showSpellsIndividualButton = detailsFramework:NewButton(timeLineFrame, _, "$parentModeEnemySpellsButton", "ModeEnemySpellsButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_BossSpells, nil, nil, "Enemy Spells", 1, options_button_template)
		showSpellsIndividualButton:SetPoint("bottomleft", showEnemyspellsButton, "bottomright", 2, 0)
		showSpellsIndividualButton:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		showSpellsIndividualButton:SetIcon([[Interface\ICONS\Spell_Shadow_Requiem]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
		showSpellsIndividualButton.icon:SetSize(iconSize, iconSize)
			--spells button for the breakdown window
			local showSpellsIndividualButtonBreakdown = detailsFramework:NewButton(timeLineFrame, _, "$parentModeEnemySpellsButtonBreakdown", "ModeEnemySpellsButton", mode_buttons_width, mode_buttons_height, selectWhatToShow, tabType_BossSpells, nil, nil, "Enemy Spells", 1, options_button_template)
			showSpellsIndividualButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			showSpellsIndividualButtonBreakdown:SetIcon([[Interface\ICONS\Spell_Shadow_Requiem]], nil, nil, nil, {.1, .9, .1, .9}, nil, textDistance, leftPadding)
			showSpellsIndividualButtonBreakdown.icon:SetSize(iconSize, iconSize)
			_G.DetailsBreakdownWindow.RegisterPluginButton(showSpellsIndividualButtonBreakdown, TimeLine, timeLine.PluginAbsoluteName)

		local allButtons = {showCooldownsButton, showDebuffsButton, showEnemyspellsButton, showSpellsIndividualButton}

		local setButtonAsPressed = function(button)
			button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"))
		end

		function TimeLine:RefreshButtons()
			for _, button in ipairs(allButtons) do
				button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			end

			if (currentSelectedType == tabType_Cooldown) then
				setButtonAsPressed(showCooldownsButton)

			elseif (currentSelectedType == tabType_Debuff) then
				setButtonAsPressed(showDebuffsButton)

			elseif (currentSelectedType == tabType_EnemySpells) then
				setButtonAsPressed(showEnemyspellsButton)

			elseif (currentSelectedType == tabType_BossSpells) then
				setButtonAsPressed(showSpellsIndividualButton)
			end
		end

		TimeLine:RefreshButtons()

	--erase data button
		local eraseDataButton_Callback = function()
			wipe(TimeLine.cooldowns_timeline)
			wipe(TimeLine.combat_data)
			wipe(TimeLine.debuff_timeline)
			wipe(TimeLine.deaths_data)

			TimeLine:Refresh()

			if (TimeLine.open) then
				TimeLine:HideIcon()
				TimeLine:CloseWindow()
			end
		end

		local eraseDataButton = detailsFramework:NewButton(timeLineFrame, _, "$parentDeleteButton", "DeleteButton", 100, 20, eraseDataButton_Callback, nil, nil, nil, Loc ["STRING_RESET"], 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		eraseDataButton:SetPoint("topright", timeLineFrame, "topright", -2, -CONST_MENU_Y_POS)
		eraseDataButton:SetIcon([[Interface\Buttons\UI-StopButton]], nil, nil, nil, {0, 1, 0, 1}, nil, nil, 2)

		local optionsButton = detailsFramework:NewButton(timeLineFrame, _, "$parentOptionsPanelButton", "OptionsPanelButton", 100, 20, TimeLine.OpenOptionsPanel, nil, nil, nil, Loc ["STRING_OPTIONS"], 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		optionsButton:SetPoint("right", eraseDataButton, "left", 2, 0)
		optionsButton:SetIcon([[Interface\Buttons\UI-OptionsButton]], nil, nil, nil, {0, 1, 0, 1}, nil, nil, 2)

		eraseDataButton:SetWidth(75)
		optionsButton:SetWidth(75)

		do
			local useIconsFunc = function()
				TimeLine.db.useicons = not TimeLine.db.useicons
				TimeLine:Refresh()
			end

			local useIconsText = detailsFramework:CreateLabel(timeLineFrame, Loc ["STRING_SPELLICONS"], 9, "orange", "GameFontNormal", "UseIconsLabel", nil, "overlay")
			useIconsText:SetPoint("right", optionsButton, "left", -4, 0)

			local useIconsCheckbox = detailsFramework:CreateSwitch(timeLineFrame, useIconsFunc, false)
			useIconsCheckbox:SetTemplate(detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE"))
			useIconsCheckbox:SetAsCheckBox()
			useIconsCheckbox:SetSize(16, 16)
			useIconsCheckbox:SetPoint("right", useIconsText, "left", -2, 0)
			timeLineFrame.useIconsCheckbox = useIconsCheckbox

			useIconsText:Hide()
			useIconsCheckbox:Hide()
		end

		function TimeLine:UpdateShowSpellIconState()
			timeLineFrame.useIconsCheckbox:SetValue(TimeLine.db.useicons)
		end

	--search field ~search
		local onPressEnter = function(_, _, text)
			if (type(text) == "string") then
				search = string.lower(text)
				TimeLine:Refresh()
			end
		end

		local searchTextEntry = detailsFramework:NewTextEntry(timeLineFrame, _, "$parentSearch", "searchbox", 120, 20, onPressEnter, nil, nil, nil, nil, options_button_template)
		searchTextEntry:SetAsSearchBox()
		searchTextEntry:SetHook("OnEscapePressed", function() search = nil; searchTextEntry:SetText(""); searchTextEntry:ClearFocus(); TimeLine:Refresh() end)
		searchTextEntry:SetHook("OnEditFocusLost", function()
			if (searchTextEntry:GetText() == "") then
				search = nil
				TimeLine:Refresh()
			end
		end)
		searchTextEntry:SetHook("OnTextChanged", function()
			if (searchTextEntry:GetText() ~= "") then
				search = string.lower(searchTextEntry:GetText())
				TimeLine:Refresh()
			else
				search = nil
				TimeLine:Refresh()
			end
		end)


	--set the point on the segment box and search box
		searchTextEntry:SetPoint("right", selectSegmentDropdown, "left", -8, 0)
		selectSegmentDropdown:SetPoint("right", optionsButton, "left", -2, 0)

	local backdrop_row = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}}

	function TimeLine:HideRows()
		for i = 1, #TimeLine.rows do
			local row = TimeLine.rows[i]
			row:Hide()
		end
	end

	local topBar = detailsFramework:NewImage(timeLineFrame, nil, CONST_VALID_WIDHT + CONST_PLAYERFIELD_SIZE, 1, "overlay", nil, nil, "$parentRowTopLine")
	topBar:SetColorTexture(1, 1, 1, .4)

	local bottomBar = detailsFramework:NewImage(timeLineFrame, nil, CONST_VALID_WIDHT + CONST_PLAYERFIELD_SIZE, 1, "overlay", nil, nil, "$parentRowBottomLine")
	bottomBar:SetColorTexture(1, 1, 1, .4)

	local row_on_enter = function(self)
		topBar:Show()
		bottomBar:Show()
		topBar:SetPoint("bottomleft", self, "topleft")
		topBar:SetPoint("bottomright", self, "topright")
		bottomBar:SetPoint("topleft", self, "bottomleft")
		bottomBar:SetPoint("topright", self, "bottomright")
		self:SetBackdropColor(0.8, 0.8, 0.8, 0.4)
	end
	local row_on_leave = function(self)
		topBar:Hide()
		bottomBar:Hide()
		self:SetBackdropColor(unpack(self.backdropColor))
	end

	local block_backdrop_onenter = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 8,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}

	local block_on_enter = function(self)
		self:SetBackdrop(block_backdrop_onenter)
		self:SetBackdropBorderColor(0, 0, 0, .9)
		self.texture:SetBlendMode("ADD")

		local parent = self:GetParent()
		topBar:SetPoint("bottomleft", parent, "topleft")
		topBar:SetPoint("bottomright", parent, "topright")
		bottomBar:SetPoint("topleft", parent, "bottomleft")
		bottomBar:SetPoint("topright", parent, "bottomright")

		self:GetParent():SetBackdropColor(0.8, 0.8, 0.8, 0.4)
		topBar:Show()
		bottomBar:Show()

		local spell = self.spell
		local spell_name, _, spell_icon = GetSpellInfo(spell[1])

		GameCooltip:Reset()
		Details:CooltipPreset(2)
		GameCooltip:SetOption("TextSize", 10)
		Details:SetCooltipForPlugins()

		local playerName = spell[4]
		local playerTable = TimeLine[currentSelectedType][currentSegment][playerName]

		local time = spell[2]
		local duration = spell[5]

		if (currentSelectedType == tabType_Cooldown) then
			GameCooltip:AddLine(spell_name, nil, 1, "white")
			GameCooltip:AddIcon(spell_icon, 1, 1, 14, 14, .1, .9, .1, .9)

			local amountMinutes, amountSeconds = math.floor(spell[2]/60), math.floor(spell[2]%60)
			GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s |r")

			local class = TimeLine:GetClass(spell[3] or "")
			local formatedTargetName = detailsFramework:AddClassColorToText(spell[3] or "", class)
			GameCooltip:AddLine(Loc ["STRING_TARGET"] .. ": |cFFFFFFFF" .. formatedTargetName .. "|r")

			for index, spellused in ipairs(playerTable) do
				if (spellused[3] ~= spell[1]) then --spellids diferentes
					--tempo de luta que o cooldown foi usado
					-- se ele foi usado antes		          e se foi usado a 8 seg de diferen�a
					if ((spellused[1] <= time and spellused[1] + 8 >= time) or(spellused[1] >= time and spellused[1] - 8 <= time) ) then
						local spellName, _, spellIcon = GetSpellInfo(spellused[3])
						GameCooltip:AddLine(spellName, nil, 1, "silver")
						GameCooltip:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)

						local amountMinutes, amountSeconds = math.floor(spellused[1]/60), math.floor(spellused[1]%60)
						GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": " .. amountMinutes .. "m " .. amountSeconds .. "s ", nil, 1, "silver")

						local class = TimeLine:GetClass(spellused[2] or "")
						local formatedTargetName = detailsFramework:AddClassColorToText(spellused[2] or "", class)
						GameCooltip:AddLine(Loc ["STRING_TARGET"] .. ": |cFFFFFFFF" .. formatedTargetName .. "|r")
						GameCooltip:AddLine(" ")
					end
				end
			end

		elseif (currentSelectedType == tabType_Debuff) then
			GameCooltip:AddLine(spell_name, nil, 1, "white")
			GameCooltip:AddIcon(spell_icon, 1, 1, 14, 14, .1, .9, .1, .9)

			local amountMinutes, amountSeconds = math.floor(spell[2]/60), math.floor(spell[2]%60)
			GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s |r")
			GameCooltip:AddLine(Loc ["STRING_SOURCE"] .. ": |cFFFFFFFF" ..(spell[6].source or Loc ["STRING_UNKNOWN"]) .. "|r")
			GameCooltip:AddLine(Loc ["STRING_ELAPSED"] .. ": |cFFFFFFFF" .. string.format("%.1f", duration) .. " " .. Loc ["STRING_SECONDS"] .. "|r")

			local blocks = self:GetParent().blocks
			for _, block in ipairs(blocks) do
				if (block.debuff_start and block:IsShown() and block ~= self and((block.debuff_start <= time and block.debuff_start + 8 >= time) or(block.debuff_start >= time and block.debuff_start - 8 <= time))) then
					GameCooltip:AddLine(" ")
					local spellName, _, spellIcon = GetSpellInfo(block.spell [1])
					GameCooltip:AddLine(spellName)
					GameCooltip:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)

					local amountMinutes, amountSeconds = math.floor(block.debuff_start / 60), math.floor(block.debuff_start % 60)
					GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s ")
					GameCooltip:AddLine(Loc ["STRING_SOURCE"] .. ": |cFFFFFFFF" ..(block.spell [6].source or Loc ["STRING_UNKNOWN"]))
					GameCooltip:AddLine(Loc ["STRING_ELAPSED"] .. ": |cFFFFFFFF" .. string.format("%.1f", block.spell [5]) .. " " .. Loc ["STRING_SECONDS"])
				end
			end

			GameCooltip:AddLine(" ")

		elseif (currentSelectedType == tabType_EnemySpells) then
			GameCooltip:AddLine(spell_name, nil, 1, "white")
			GameCooltip:AddIcon(spell_icon, 1, 1, 14, 14, .1, .9, .1, .9)

			local amountMinutes, amountSeconds = math.floor(spell [2]/60), math.floor(spell [2]%60)
			GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s |r")
			GameCooltip:AddLine(Loc ["STRING_SOURCE"] .. ": |cFFFFFFFF" ..(spell [6].source or Loc ["STRING_UNKNOWN"]) .. "|r")

			local class = TimeLine:GetClass(self.TargetName or "")
			local formatedTargetName = detailsFramework:AddClassColorToText(self.TargetName or "", class)
			GameCooltip:AddLine(Loc ["STRING_TARGET"] .. ": |cFFFFFFFF" .. formatedTargetName .. "|r")

			local blocks = self:GetParent().blocks
			for _, block in ipairs(blocks) do
				if (block.cast_start and block:IsShown() and block ~= self and((block.cast_start <= time and block.cast_start + 8 >= time) or(block.cast_start >= time and block.cast_start - 8 <= time))) then
					GameCooltip:AddLine("")
					local spell_name, _, spell_icon = GetSpellInfo(block.spell [1])
					GameCooltip:AddLine(spell_name)
					GameCooltip:AddIcon(spell_icon, 1, 1, 14, 14, .1, .9, .1, .9)

					local amountMinutes, amountSeconds = math.floor(block.cast_start / 60), math.floor(block.cast_start % 60)
					GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s ")
					GameCooltip:AddLine(Loc ["STRING_SOURCE"] .. ": |cFFFFFFFF" ..(block.SourceName or Loc ["STRING_UNKNOWN"]))

					local targetName = block.TargetName or ""
					local class = TimeLine:GetClass(targetName)
					local formatedTargetName = detailsFramework:AddClassColorToText(targetName, class)
					GameCooltip:AddLine(Loc ["STRING_TARGET"] .. ": |cFFFFFFFF" .. formatedTargetName .. "|r")
				end
			end

		elseif (currentSelectedType == tabType_BossSpells) then
			GameCooltip:AddLine(spell_name, nil, 1, "white")
			GameCooltip:AddIcon(spell_icon, 1, 1, 14, 14, .1, .9, .1, .9)

			local amountMinutes, amountSeconds = math.floor(spell [2]/60), math.floor(spell [2]%60)
			GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s |r")
			GameCooltip:AddLine(Loc ["STRING_SOURCE"] .. ": |cFFFFFFFF" ..(spell [6].source or Loc ["STRING_UNKNOWN"]) .. "|r")

			local class = TimeLine:GetClass(self.TargetName or "")
			local formatedTargetName = detailsFramework:AddClassColorToText(self.TargetName or "", class)
			GameCooltip:AddLine(Loc ["STRING_TARGET"] .. ": |cFFFFFFFF" .. formatedTargetName .. "|r")

			local blocks = self:GetParent().blocks
			for _, block in ipairs(blocks) do
				if (block.cast_start and block:IsShown() and block ~= self and((block.cast_start <= time and block.cast_start + 8 >= time) or(block.cast_start >= time and block.cast_start - 8 <= time))) then
					GameCooltip:AddLine("")
					local spell_name, _, spell_icon = GetSpellInfo(block.spell [1])
					GameCooltip:AddLine(spell_name)
					GameCooltip:AddIcon(spell_icon, 1, 1, 14, 14, .1, .9, .1, .9)

					local amountMinutes, amountSeconds = math.floor(block.cast_start / 60), math.floor(block.cast_start % 60)
					GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": |cFFFFFFFF" .. amountMinutes .. "m " .. amountSeconds .. "s ")
					GameCooltip:AddLine(Loc ["STRING_SOURCE"] .. ": |cFFFFFFFF" ..(block.SourceName or Loc ["STRING_UNKNOWN"]))

					local targetName = block.TargetName or ""
					local class = TimeLine:GetClass(targetName)
					local formatedTargetName = detailsFramework:AddClassColorToText(targetName, class)
					GameCooltip:AddLine(Loc ["STRING_TARGET"] .. ": |cFFFFFFFF" .. formatedTargetName .. "|r")
				end
			end

		end

		GameCooltip:ShowCooltip(self, "tooltip")
	end

	local block_on_leave = function(self)
		self:SetBackdrop(nil)
		self:SetBackdropBorderColor(0, 0, 0, 0)
		self.texture:SetBlendMode("BLEND")

		topBar:Hide()
		bottomBar:Hide()

		self:GetParent():SetBackdropColor(unpack(self:GetParent().backdropColor))

		GameCooltip:Hide()
	end

	function TimeLine:CreateSpellBlock(row)
		local block = CreateFrame("frame", nil, row, "BackdropTemplate")
		row.block_frame_level = row.block_frame_level + 1
		if (row.block_frame_level > 9) then
			row.block_frame_level = 3
		end

		block.spell = {0, 0, "", "", 0} -- [1] spellid [2] used at [3] target name [4] playername [5] effect time

		block:SetHeight(CONST_ROW_HEIGHT-2)
		block:SetScript("OnEnter", block_on_enter)
		block:SetScript("OnLeave", block_on_leave)

		local texture = block:CreateTexture(nil, "background")
		texture:SetAllPoints(block)
		texture:SetColorTexture(0, 1, 0, .2)
		block.texture = texture

		local icon = block:CreateTexture(nil, "border")
		icon:SetPoint("topleft", texture, "topleft", 0, 0)
		icon:SetPoint("bottomleft", texture, "bottomleft", 0, 0)
		icon:SetWidth(16)
		block.spellicon = icon

		return block
	end

	local SetSpellBlock = function(row, block, time_used, spellid, effect_time, target, total_time, pixel_per_sec, player_name, player_table, color, block_index)
		block.spell[1] = spellid
		block.spell[2] = time_used
		block.spell[3] = target
		block.spell[4] = player_name
		block.spell[5] = effect_time
		block.spell[6] = player_table

		local where = pixel_per_sec * time_used

		block:ClearAllPoints()
		block:SetPoint("left", row, "left", where + CONST_PLAYERFIELD_SIZE, 0)

		if (effect_time < 5) then
			effect_time = 5
		elseif (effect_time > 20) then
			effect_time = 20
		end
		block:SetWidth(effect_time * pixel_per_sec)

		block.texture:SetColorTexture(unpack(color))

		if (TimeLine.db.useicons) then
			local _, _, icon = GetSpellInfo(spellid)
			block.spellicon:SetTexture(icon)
			block.spellicon:SetTexCoord(.1, .9, .1, .9)
			block.spellicon:SetWidth(block:GetHeight())
			block.spellicon:SetAlpha(0.834)

			--remove the background texture is using the icon of the spell
			block.texture:SetColorTexture(0, 0, 0, 0)
		else
			block.spellicon:SetTexture(nil)
		end

		if (search) then
			local spellname = GetSpellInfo(spellid)
			spellname = string.lower(spellname)
			if (spellname:find(search)) then
				block:Show()
			else
				block:Hide()
			end
		else
			block:Show()
		end
	end

	local pin_on_enter = function(self)
		self:SetBackdrop(block_backdrop_onenter)
		self:SetBackdropBorderColor(0, 0, 0, .9)
		self.texture:SetBlendMode("ADD")

		topBar:SetPoint("bottom", self:GetParent(), "top")
		bottomBar:SetPoint("top", self:GetParent(), "bottom")
		self:GetParent():SetBackdropColor(0.8, 0.8, 0.8, 0.4)
		topBar:Show()
		bottomBar:Show()

		GameCooltip:Reset()
		Details:CooltipPreset(2)
		GameCooltip:SetOption("TextSize", 10)

		for i = 1, #self.table do
			local spellname, _, spellicon = _GetSpellInfo(self.table[i][2])
			GameCooltip:AddLine(spellname, TimeLine:ToK2(self.table[i][3]), 1, "silver", "orange")
			GameCooltip:AddIcon(spellicon, 1, 1, 14, 14)
		end

		GameCooltip:AddLine("")

		local amountMinutes, amountSeconds = math.floor(self.time/60), math.floor(self.time%60)
		GameCooltip:AddLine(Loc ["STRING_TIME"] .. ": " .. amountMinutes .. "m " .. amountSeconds .. "s ")
		GameCooltip:ShowCooltip(self, "tooltip")
	end

	local pin_on_leave = function(self)
		GameCooltip:Hide()
	end

	local PlaceDeathPins = function(row, i, death, total_time, pixel_per_sec)
		local pin = row.pins [i]
		if (not pin) then
			pin = CreateFrame("frame", nil, row, "BackdropTemplate")
			pin:SetFrameLevel(12)
			pin:SetFrameStrata("DIALOG")
			pin:SetScript("OnEnter", pin_on_enter)
			pin:SetScript("OnLeave", pin_on_leave)
			local texture = pin:CreateTexture(nil, "overlay")
			texture:SetAllPoints()
			texture:SetColorTexture(1, 1, 1, 0.4)
			pin.texture = texture
			pin:SetSize(4, 14)
			pin.table = {}
			row.pins [i] = pin
		end

		local where = pixel_per_sec * death.time
		pin:ClearAllPoints()
		pin:SetPoint("left", row, "left", where + CONST_PLAYERFIELD_SIZE, 0)
		pin.time = death.time

		for event = 1, #death.events do
			local ev = death.events[event]
			pin.table [event] = {ev[4], ev[2], ev[3]} --time spellid amount
		end

		pin:Show()
	end

	--player_table: [1] time [2] target [3] spellid
	local SetPlayer = function(row, playerName, playerDataTable, elapsedTime, pixelPerSecond, deaths)
		local spec
		--set name and class color
		if (type(playerName) == "string" and playerName:find("-")) then
			row.name.text = playerName:gsub(("-.*"), "")
			spec = Details:GetSpecFromActorName(playerName)
		else
			if (type(playerName) == "number") then
				row.name.text = GetSpellInfo(playerName)
			else
				row.name.text = playerName
				spec = Details:GetSpecFromActorName(playerName)
			end
		end

		local class = TimeLine:GetClass(playerName)

		if (spec) then
			row.name.color = TimeLine.class_colors[class or "PRIEST"]
			row.icon.texture = [[Interface\AddOns\Details\images\spec_icons_normal]]
			row.icon.texcoord = Details.class_specs_coords[spec]

		elseif (class) then
			if (class == "UNKNOW") then
				if (currentSelectedType == tabType_BossSpells) then
					--use the icon spell icon as the class icon
					local spellName, _, spellIcon = GetSpellInfo(playerName)
					row.icon.texture = spellIcon
					row.icon.texcoord = {.1, .9, .1, .9}
					row.name.color = "white"

				elseif (currentSelectedType == tabType_EnemySpells) then
					row.name.color = "white"
					row.icon.texture = nil

				else
					row.name.color = "white"
					row.icon.texture = nil
				end
			else
				row.name.color = TimeLine.class_colors [class]
				row.icon.texture = class_icons_with_alpha
				row.icon.texcoord = TimeLine.class_coords [class]
			end

		else
			if (currentSelectedType == tabType_BossSpells) then
				--use the icon spell icon as the class icon
				local _, _, spellIcon = GetSpellInfo(playerDataTable [3])
				row.icon.texture = spellIcon
				row.icon.texcoord = {.1, .9, .1, .9}
			else
				row.name.color = "white"
				row.icon.texture = nil
			end
		end

		--clear all blocks
		for _, block in ipairs(row.blocks) do
			block:Hide()
		end

		--clear all pins
		for index, pin in ipairs(row.pins) do
			pin:Hide()
			wipe(pin.table)
		end

		--place death pins
		if (deaths) then
			for index, death in ipairs(deaths) do
				PlaceDeathPins(row, index, death, elapsedTime, pixelPerSecond)
			end
		end

		--if showing cooldowns:
		if (currentSelectedType == tabType_Cooldown and playerDataTable) then

			for spell_index, spell_table in ipairs(playerDataTable) do

				local time_used = spell_table [1]
				local target = spell_table [2]
				local spellid = spell_table [3]

				local spellInfo = detailsFramework.CooldownsInfo [spellid]
				local cooldown, effectTime
				if (spellInfo) then
					cooldown, effectTime = spellInfo.cooldown, spellInfo.duration
				else
					cooldown, effectTime = 8, 8
				end

				effectTime = effectTime or 6

				local block = row.blocks [spell_index]
				if (not block) then
					row.blocks [spell_index] = TimeLine:CreateSpellBlock(row)
					block = row.blocks [spell_index]
				end

				SetSpellBlock(row, block, time_used, spellid, effectTime, target, elapsedTime, pixelPerSecond, playerName, playerDataTable, green)
			end

		--showing debuffs
		elseif (currentSelectedType == tabType_Debuff and playerDataTable) then

			local o = 1

			for spell_id, debuff_timers in pairs(playerDataTable) do

				local start = true
				local i = 1

				for index, time in ipairs(debuff_timers) do
					if (start) then
						local start_time = time
						local end_time = debuff_timers [i+1]

						local block = row.blocks [o]
						if (not block) then
							row.blocks [o] = TimeLine:CreateSpellBlock(row)
							block = row.blocks [o]
						end

						local debuff_elapsed = (end_time or 0) -(start_time or 0)

						block.debuff_start = start_time
						block.debuff_end = end_time
						SetSpellBlock(row, block, start_time, spell_id, debuff_elapsed, myName, elapsedTime, pixelPerSecond, playerName, debuff_timers, red, o)

						o = o + 1
					end
					start = not start
					i = i + 1
				end

			end


		elseif (currentSelectedType == tabType_EnemySpells and playerDataTable) then
			local o = 1
			for index, spellTable in ipairs(playerDataTable) do
				local combatTime, sourceName, spellID, token, targetName = unpack(spellTable)

				local block = row.blocks [o]
				if (not block) then
					row.blocks [o] = TimeLine:CreateSpellBlock(row)
					block = row.blocks [o]
				end

				block.cast_start = combatTime
				block.cast_end = combatTime + 8

				local spellName, _, spellIcon = GetSpellInfo(spellID)

				playerDataTable.source = sourceName or ""
				playerDataTable.target = targetName or ""
				block.SourceName = sourceName or ""
				block.TargetName = targetName or ""

				SetSpellBlock(row, block, combatTime, spellID, 8, spellName, elapsedTime, pixelPerSecond, playerName, playerDataTable, red, o)
				o = o + 1
			end


		elseif (currentSelectedType == tabType_BossSpells and playerDataTable) then
			local o = 1
			for index, spellTable in ipairs(playerDataTable) do
				local combatTime, sourceName, spellID, token, targetName = unpack(spellTable)

				local block = row.blocks [o]
				if (not block) then
					row.blocks [o] = TimeLine:CreateSpellBlock(row)
					block = row.blocks [o]
				end

				block.cast_start = combatTime
				block.cast_end = combatTime + 8

				local spellName, _, spellIcon = GetSpellInfo(spellID)

				playerDataTable.source = sourceName or ""
				playerDataTable.target = targetName or ""
				block.SourceName = sourceName or ""
				block.TargetName = targetName or ""

				SetSpellBlock(row, block, combatTime, spellID, 8, spellName, elapsedTime, pixelPerSecond, playerName, playerDataTable, red, o)
				o = o + 1
			end

		end

	end

	local on_row_mousedown = function(self, button)
		if (button == "LeftButton") then
			self:GetParent():StartMoving()
			self:GetParent().isMoving = true
		end
	end
	local on_row_mouseup = function(self)
		if (self:GetParent().isMoving) then
			self:GetParent():StopMovingOrSizing()
			self:GetParent().isMoving = false
		end
	end

	function TimeLine:CreateRow()
		local index = #TimeLine.rows+1

		-- cria as labels e mouse overs e da o set point
		local newRow = CreateFrame("frame", "DetailsTimeTimeRow" .. index, timeLineFrame, "BackdropTemplate")
		newRow:SetSize(timeLineFrame.Width - 4, CONST_ROW_HEIGHT)

		local height = (index * CONST_ROW_HEIGHT) + CONST_LINE_START_Y
		newRow:SetPoint("topleft", timeLineFrame, "topleft", 2, -height)

		newRow:SetScript("OnEnter", row_on_enter)
		newRow:SetScript("OnLeave", row_on_leave)

		newRow.block_frame_level = 3

		newRow.icon = detailsFramework:NewImage(newRow, nil, CONST_ROW_HEIGHT, CONST_ROW_HEIGHT, "overlay", nil, nil, "$parentIcon")
		newRow.icon:SetPoint("left", newRow, "left", 2, 0)

		newRow.name = detailsFramework:NewLabel(newRow, nil, "$parentName", nil)
		newRow.name:SetPoint("left", newRow.icon, "right", 2, 0)
		newRow.name.fontsize = 11

		newRow.nameBackground = detailsFramework:NewImage(newRow, nil, 1, CONST_ROW_HEIGHT, "overlay", nil, nil, "$parentNameBackground")
		newRow.nameBackground:SetPoint("left", newRow.icon, "right", 0, 0)
		newRow.nameBackground:SetPoint("right", newRow.icon, "right", 100, 0)
		newRow.nameBackground.color = {.1, .1, .1, 0.7}

		newRow:SetBackdrop(backdrop_row)
		if (index%2 == 0) then
			newRow.backdropColor = BUTTON_BACKGROUND_COLOR
			newRow:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLOR))
		else
			newRow.backdropColor = BUTTON_BACKGROUND_COLOR2
			newRow:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLOR2))
		end

		newRow.blocks = {}
		newRow.pins = {}

		TimeLine.rows[index] = newRow

		return newRow
	end

	local sort = function(a, b)
		return a[2] < b[2]
	end

	function TimeLine:Refresh()
		TimeLine:HideRows()

		if (not TimeLine.combat_data [1]) then
			return
		end

		local _table_to_use = TimeLine [currentSelectedType] [currentSegment]
		local total_time = TimeLine.combat_data [currentSegment].total_time
		local pixel_per_sec = CONST_VALID_WIDHT / total_time

		local i = 0

		if (not _table_to_use) then
			TimeLine:Msg(Loc ["STRING_DATAINVALID"])
			return
		end

		local sorted = {}
		for player_name, player_table in pairs(_table_to_use) do
			sorted [#sorted+1] = {player_table, player_name}
		end
		table.sort(sorted, sort)

		local deaths = TimeLine.deaths_data
		local segment_deaths = deaths [currentSegment]
		local has_something = {}

		for index, t in ipairs(sorted) do
			local player_table, player_name = t [1], t [2]

			i = i + 1

			local row = TimeLine.rows [i]
			if (not row) then
				row = TimeLine:CreateRow()
			end

			local deaths = segment_deaths [player_name]

			SetPlayer(row, player_name, player_table, total_time, pixel_per_sec, deaths)
			has_something [player_name] = true

			row:Show()
		end

		if (currentSelectedType ~= tabType_BossSpells and currentSelectedType ~= tabType_EnemySpells) then
			local sorted = {}
			for player_name, t in pairs(segment_deaths) do
				if (not has_something [player_name]) then
					sorted [#sorted+1] = {t, player_name}
				end
			end
			table.sort(sorted, sort)

			for index, t in ipairs(sorted) do
				i = i + 1
				local row = TimeLine.rows [i]
				if (not row) then
					row = TimeLine:CreateRow()
				end

				local death, player_name = t [1], t [2]

				SetPlayer(row, player_name, nil, total_time, pixel_per_sec, death)
				row:Show()
			end
		end

		TimeLine:UpdateTimeLine(total_time)
	end
end


function TimeLine:ArrangeCooldownsInOrder(auraType, auraList)
	local newTable = {}
	for auraIndex, spellId in ipairs(auraList) do
		table.insert(newTable, {spellId, GetSpellInfo(spellId)})
	end
	table.sort(newTable, function(a, b) return a[2] < b[2] end)
	return newTable
end

function TimeLine:OnCooldown(token, time, sourceGUID, sourceName, sourceFlag, targetGUID, targetName, targetFlag, spellID, spellName)
	--hooks run inside parser and do not check if the plugin is enabled or not
	--we need to check this here before continue
	if (not TimeLine.__enabled) then
		return

	elseif (not bIsInCombat) then
		return
	end

	local data = {combatObject:GetCombatTime(), targetName, spellID}
	local playerTable = TimeLine.current_battle_cooldowns_timeline[sourceName]

	if (not playerTable) then
		TimeLine.current_battle_cooldowns_timeline[sourceName] = {}
		playerTable = TimeLine.current_battle_cooldowns_timeline[sourceName]
	end

	table.insert(playerTable, data)
end

function TimeLine:EnemySpellCast(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
	if (sourceFlag) then
		if (bitBand(sourceFlag, 0x00000060) ~= 0) then --is enemy
			if (bitBand(sourceFlag, 0x00000400) == 0) then --is not player
				local petInfo = Details:GetPetInfo(sourceGUID)
				if (not petInfo or bitBand(petInfo.ownerFlags, 0x00000400) == 0) then --isn't a pet or owner isn't a player
					sourceName = sourceName or select(1, GetSpellInfo(spellID or 0)) or "--x--x--"

					do
						--spells cast by enemy
						local data = {combatObject:GetCombatTime(), sourceName, spellID, token, targetName}
						local enemyTable = TimeLine.current_enemy_spells[sourceName]
						if (not enemyTable) then
							enemyTable = {}
							TimeLine.current_enemy_spells[sourceName] = enemyTable
						end
						table.insert(enemyTable, data)
					end

					do
						--individual spells cast
						local data = {combatObject:GetCombatTime(), sourceName, spellID, token, targetName}
						local spellsTable = TimeLine.current_spells_individual[spellID]
						if (not spellsTable) then
							spellsTable = {}
							TimeLine.current_spells_individual[spellID] = spellsTable
						end
						table.insert(spellsTable, data)
					end
				end
			end
		end
	end
end

function TimeLine:AuraOn(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spelltype, auraType, amount)
	if (auraType == "DEBUFF") then
		--is the target a player?
		if (bitBand(targetFlag, 0x00000400) ~= 0) then
			--is the source an enemy?
			if (bitBand(sourceFlag, 0x00000060) ~= 0 or(not sourceGUID or not sourceName)) then
				local playerTable = TimeLine.debuff_temp_table[targetName]
				if (not playerTable) then
					playerTable = {}
					TimeLine.debuff_temp_table[targetName] = playerTable
				end

				local spellTable = playerTable[spellID]
				if (not spellTable) then
					spellTable = {}
					spellTable.source = sourceName or("[*] " .. spellName)
					spellTable.stacks = {}
					playerTable[spellID] = spellTable
				end

				--was a refresh
				if (spellTable.active) then
					return
				end

				--array
				table.insert(spellTable, combatObject:GetCombatTime())

				--hash
				spellTable.active = true
			end
		end
	end
end

function TimeLine:AuraOff(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellId, spellName, spellType, auraType, amount)
	if (auraType == "DEBUFF") then
		if (combatObject.__destroyed) then
			return
		end
		--is the target a player?
		if (bitBand(targetFlag, 0x00000400) ~= 0) then
			--is the source an enemy?
			if (bitBand(sourceFlag, 0x00000060) ~= 0 or(not sourceGUID or not sourceName)) then
				local playerTable = TimeLine.debuff_temp_table[targetName]
				if (not playerTable) then
					return
				end

				local spellTable = playerTable[spellId]
				if (not spellTable) then
					return
				end

				if (not spellTable.active) then
					return
				end

				--array
				table.insert(spellTable, combatObject:GetCombatTime())
				--hash
				spellTable.active = false
			end
		end
	end
end

local build_options_panel = function()
	local optionsFrame = TimeLine:CreatePluginOptionsFrame("TimeLineOptionsWindow", Loc ["STRING_OPTIONS_TITLE"], 1)

	local menu = {
		{
			type = "range",
			get = function() return TimeLine.db.max_segments end,
			set = function(self, fixedparam, value) TimeLine.db.max_segments = value end,
			min = 3,
			max = 25,
			step = 1,
			desc = Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"],
			name = Loc ["STRING_OPTIONS_MAXSEGMENTS"]
		},
		{
			type = "color",
			get = function() return TimeLine.db.backdrop_color end,
			set = function(self, r, g, b, a)
				local current = TimeLine.db.backdrop_color
				current[1], current[2], current[3], current[4] = r, g, b, a
				TimeLine:RefreshBackgroundColor()
			end,
			desc = Loc ["STRING_OPTIONS_BGCOLOR_DESC"],
			name = Loc ["STRING_OPTIONS_BGCOLOR"]
		},
		{
			type = "range",
			get = function() return TimeLine.db.window_scale end,
			set = function(self, fixedparam, value) TimeLine.db.window_scale = value; TimeLine:RefreshScale() end,
			min = 0.65,
			max = 1.50,
			step = 0.1,
			desc = Loc ["STRING_OPTIONS_WINDOWCOLOR_DESC"],
			name = Loc ["STRING_OPTIONS_WINDOWCOLOR"],
			usedecimals = true,
		},

	}

	local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

	detailsFramework:BuildMenu(optionsFrame, menu, 15, -65, 260, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
	optionsFrame:SetBackdropColor(0, 0, 0, .9)

end
TimeLine.OpenOptionsPanel = function()
	if (not _G.TimeLineOptionsWindow) then
		build_options_panel()
	end
	_G.TimeLineOptionsWindow:Show()
end

function TimeLine:RefreshBackgroundColor()
	timeLineFrame:SetBackdropColor(unpack(TimeLine.db.backdrop_color))
end

function TimeLine:RefreshScale()
	local scale = TimeLine.db.window_scale
	if (timeLineFrame) then
		timeLineFrame:SetScale(scale)
	end
end

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

--filter the combat log events which we need to track
local interestEvents = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
	["SPELL_AURA_REMOVED"] = true,
	["SPELL_CAST_SUCCESS"] = true,
}

TimeLine.EventFrame:SetScript("OnEvent", function()
	local time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
	if (interestEvents[token]) then
		if (token == "SPELL_AURA_APPLIED" or token == "SPELL_AURA_REFRESH") then
			TimeLine:AuraOn(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill)

		elseif (token == "SPELL_AURA_REMOVED") then
			TimeLine:AuraOff(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill)

		elseif (token == "SPELL_CAST_SUCCESS") then
			TimeLine:EnemySpellCast(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill)
		end
	end
end)

function TimeLine:OnEvent(_, event, ...)
	if (event == "ADDON_LOADED") then
		local AddonName = select(1, ...)
		if (AddonName == "Details_TimeLine") then
			if (_G.Details) then
				CreatePluginFrames()
				local MINIMAL_DETAILS_VERSION_REQUIRED = 158
				local db = DetailsTimeLineDB

				--install plugin
				local install, saveddata, is_enabled = _G.Details:InstallPlugin("TOOLBAR", Loc ["STRING_PLUGIN_NAME"], [[Interface\CHATFRAME\ChatFrameExpandArrow]], TimeLine, "DETAILS_PLUGIN_TIME_LINE", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", TimeLine.version_string)
				if (type(install) == "table" and install.error) then
					print(install.error)
					return
				end

				if (not db) then
					db = {}
					DetailsTimeLineDB = db

					db.hide_on_combat = false
					db.useicons = true
					db.max_segments = 4
					db.backdrop_color = {0, 0, 0, .4}
					db.window_scale = 1

					db.cooldowns_timeline = {}
					db.debuff_timeline = {}
					db.combat_data = {}
					db.deaths_data = {}

					if (saveddata) then
						saveddata.cooldowns_timeline = nil
						saveddata.debuff_timeline = nil
						saveddata.combat_data = nil
						saveddata.deaths_data = nil
						saveddata.hide_on_combat = nil
						saveddata.max_segments = nil
						saveddata.backdrop_color = nil
						saveddata.window_scale = nil
					end
				end

				TimeLine.db = db
				TimeLine.saveddata = db

				TimeLine.cooldowns_timeline = db.cooldowns_timeline
				TimeLine.debuff_timeline = db.debuff_timeline
				TimeLine.combat_data = db.combat_data
				TimeLine.deaths_data = db.deaths_data

				--store which spells are active per boss
				db.BossSpellCast = db.BossSpellCast or {}
				TimeLine.spellcast_boss = db.BossSpellCast

				--store individual spells
				db.IndividualSpells = db.IndividualSpells or {}
				TimeLine.boss_spells = db.IndividualSpells

				--register needed events
				Details:RegisterEvent(TimeLine, "COMBAT_PLAYER_ENTER")
				Details:RegisterEvent(TimeLine, "COMBAT_PLAYER_LEAVE")
				Details:RegisterEvent(TimeLine, "COMBAT_INVALID")
				Details:RegisterEvent(TimeLine, "DETAILS_DATA_RESET")
				Details:InstallHook(DETAILS_HOOK_COOLDOWN, TimeLine.OnCooldown)

				--Register slash commands
				SLASH_DETAILS_TIMELINE1 = "/timeline"

				function SlashCmdList.DETAILS_TIMELINE(msg, editbox)
					TimeLine:OpenWindow()
				end

				TimeLine:RefreshBackgroundColor()
				TimeLine:UpdateShowSpellIconState()
			end
		end
	end
end
