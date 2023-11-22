
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local _

local CONST_BUTTON_WIDTH = 150
local CONST_BUTTON_XANCHOR = 2
local CONST_BUTTON_YANCHOR = -2
local mode_buttons_height = 20
local CreateFrame = CreateFrame

do
	local wipe = table.wipe
	local Loc = LibStub("AceLocale-3.0"):GetLocale("Details_DeathGraphs")

	advancedDeathLogs.pluginObject.DeathGraphsWindowBuilder = function(adlObject)
		local pluginFrame = advancedDeathLogs.mainFrame

		do --templates declarations
			detailsFramework.button_templates["ADL_BUTTON_TEMPLATE"] = {
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {.3, .3, .3, .9},
				onentercolor = {.6, .6, .6, .9},
				backdropbordercolor = {0, 0, 0, 1},
				onenterbordercolor = {0, 0, 0, 1},
			}

			detailsFramework:InstallTemplate("button", "ADL_MENUBUTTON_TEMPLATE", {width = 160}, "DETAILS_PLUGIN_BUTTON_TEMPLATE")
			detailsFramework:InstallTemplate("button", "ADL_MENUBUTTON_SELECTED_TEMPLATE", {width = 160}, "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE")
		end

		local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

		do --build the main frame
			pluginFrame:SetFrameStrata("HIGH")
			pluginFrame:SetToplevel(true)
			pluginFrame:SetPoint("center", UIParent, "center", 0, 0)
			pluginFrame:SetSize(925, 498)
			pluginFrame:EnableMouse(true)
			pluginFrame:SetResizable(false)
			pluginFrame:SetMovable(true)
			pluginFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "LeftButton") then
					if (self.isMoving) then
						return
					end
					self:StartMoving()
					self.isMoving = true

				elseif (button == "RightButton") then
					if (self.isMoving) then
						return
					end
					adlObject:CloseWindow()
				end
			end)

			pluginFrame:SetScript("OnMouseUp", function(self)
				if (self.isMoving) then
					self:StopMovingOrSizing()
					self.isMoving = false
				end
			end)

			local closeButton = CreateFrame("Button", nil, pluginFrame, "UIPanelCloseButton")
			closeButton:SetWidth(20)
			closeButton:SetHeight(20)
			closeButton:SetPoint("TOPRIGHT",  pluginFrame, "TOPRIGHT", -2, -3)
			closeButton:SetFrameLevel(pluginFrame:GetFrameLevel()+1)
			closeButton:GetNormalTexture():SetDesaturated(true)
			closeButton:SetAlpha(1)

			--title bar
			local titleBar = CreateFrame("frame", nil, pluginFrame, "BackdropTemplate")
			titleBar:SetPoint("topleft", pluginFrame, "topleft", 2, -3)
			titleBar:SetPoint("topright", pluginFrame, "topright", -2, -3)
			titleBar:SetHeight(20)
			titleBar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			titleBar:SetBackdropColor(.5, .5, .5, 1)
			titleBar:SetBackdropBorderColor(0, 0, 0, 1)

			--header background
			local headerFrame = CreateFrame("frame", "EncounterDetailsHeaderFrame", pluginFrame, "BackdropTemplate")
			headerFrame:EnableMouse(false)
			headerFrame:SetPoint("topleft", titleBar, "bottomleft", -1, -1)
			headerFrame:SetPoint("topright", titleBar, "bottomright", 1, -1)
			headerFrame:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			headerFrame:SetBackdropColor(.7, .7, .7, .4)
			headerFrame:SetHeight(48)
			pluginFrame.headerFrame = headerFrame

			local gradientTop = detailsFramework:CreateTexture(headerFrame,
			{gradient = "vertical", fromColor = {0, 0, 0, 0.5}, toColor = "transparent"}, 1, 48, "artwork", {0, 1, 0, 1})
			gradientTop:SetPoint("bottoms", 1, 1)
			pluginFrame.gradientTop = gradientTop

			--window title
			local titleLabel = detailsFramework:NewLabel(titleBar, titleBar, nil, "titulo", "Advanced Death Logs", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
			titleLabel:SetPoint("center", pluginFrame, "center")
			titleLabel:SetPoint("top", pluginFrame, "top", 0, -7)

			local nameBackgroundTexture = pluginFrame:CreateTexture(nil, "background")
			nameBackgroundTexture:SetTexture([[Interface\PetBattles\_PetBattleHorizTile]], true)
			nameBackgroundTexture:SetHorizTile(true)
			nameBackgroundTexture:SetTexCoord(0, 1, 126/256, 19/256)
			nameBackgroundTexture:SetPoint("topleft", pluginFrame, "topleft", 2, -22)
			nameBackgroundTexture:SetPoint("bottomright", pluginFrame, "bottomright")
			nameBackgroundTexture:SetHeight(54)
			nameBackgroundTexture:SetVertexColor(0, 0, 0, 0.2)

			adlObject.selectedTextureBoss = detailsFramework:NewImage(pluginFrame, "Interface\\SPELLBOOK\\Spellbook-Parts", 190, 50, "border", {0.31250000, 0.96484375, 0.37109375, 0.52343750})
			adlObject.selectedTextureBoss:SetBlendMode("ADD")

			adlObject.selectedTextureBoss2 = detailsFramework:NewImage(pluginFrame, "Interface\\SPELLBOOK\\Spellbook-Parts", 190, 50, "border", {0.31250000, 0.96484375, 0.37109375, 0.52343750})
			adlObject.selectedTextureBoss2:SetBlendMode("ADD")
			adlObject.selectedTextureBoss2:SetAllPoints(adlObject.selectedTextureBoss.widget)
		end

		function adlObject:HideAll()
			--endurance
			adlObject.enduranceFrame:Hide()

			--current
			adlObject.currentFrame:Hide()

			--timeline
			pluginFrame.timelineFrame:Hide()
		end

		function adlObject:ShowCurrent()
			adlObject.db.showing_type = 3
			adlObject.currentFrame:Show()
			adlObject.currentFrame.Refresh()
		end

		function adlObject:ShowTimeline()
			adlObject.db.showing_type = 4
			pluginFrame.timelineFrame:Show()
			pluginFrame.timelineFrame.Refresh()
		end

		--mode buttons:
		local BUTTON_INDEX_CURRENT = 1 --this should be 3, but maybe is getting the button index
		local BUTTON_INDEX_TIMELINE = 2
		local BUTTON_INDEX_ENDURANCE = 4

		local change_mode = function(self, button, selected_mode)
			adlObject:HideAll()

			if (selected_mode == BUTTON_INDEX_CURRENT) then
				adlObject:ShowCurrent() --internal index: 3

			elseif (selected_mode == BUTTON_INDEX_TIMELINE) then
				adlObject:ShowTimeline() --internal index: 4

			elseif (selected_mode == BUTTON_INDEX_ENDURANCE) then
				adlObject:ShowEndurance() --internal index: 2
			end

			adlObject:RefreshButtons()
		end

		--button: current encounter
		local localizedCurrentEncounterString = "Death Logs"
		local currentEncounterButton = detailsFramework:NewButton(pluginFrame, _, "$parentModeCurrentEncounterButton", "ModeCurrentEncounterButton", CONST_BUTTON_WIDTH, mode_buttons_height, change_mode, BUTTON_INDEX_CURRENT, nil, nil, localizedCurrentEncounterString, 1)
		currentEncounterButton:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
		currentEncounterButton:SetIcon([[Interface\WORLDSTATEFRAME\SkullBones]], nil, nil, nil, {4/64, 28/64, 4/64, 28/64}, "orange", nil, 2)
			--current encounter button for the breakdown window
			local currentEncounterButtonBreakdown = detailsFramework:NewButton(pluginFrame, _, "$parentModeCurrentEncounterButtonBreakdown", "ModeCurrentEncounterButton", CONST_BUTTON_WIDTH, mode_buttons_height, change_mode, BUTTON_INDEX_CURRENT, nil, nil, localizedCurrentEncounterString, 1)
			currentEncounterButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
			currentEncounterButtonBreakdown:SetIcon([[Interface\WORLDSTATEFRAME\SkullBones]], nil, nil, nil, {4/64, 28/64, 4/64, 28/64}, "orange", nil, 2)
			_G.DetailsBreakdownWindow.RegisterPluginButton(currentEncounterButtonBreakdown, advancedDeathLogs.pluginObject, advancedDeathLogs.PluginAbsoluteName)

		--button: timeline
		local localizedTimeLineString = "Death Timeline"
		local timelineButton = detailsFramework:NewButton(pluginFrame, _, "$parentModeTimelineButton", "ModeTimelineButton", CONST_BUTTON_WIDTH, mode_buttons_height, change_mode, BUTTON_INDEX_TIMELINE, nil, nil, localizedTimeLineString, 1, options_button_template)
		timelineButton:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
		timelineButton:SetIcon([[Interface\CHATFRAME\ChatFrameExpandArrow]], nil, nil, nil, {0, 1, 0, 1}, "orange", nil, 2)
			--timeline button for the breakdown window
			local timelineButtonBreakdown = detailsFramework:NewButton(pluginFrame, _, "$parentModeTimelineButtonBreakdown", "ModeTimelineButton", CONST_BUTTON_WIDTH, mode_buttons_height, change_mode, BUTTON_INDEX_TIMELINE, nil, nil, localizedTimeLineString, 1, options_button_template)
			timelineButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
			timelineButtonBreakdown:SetIcon([[Interface\CHATFRAME\ChatFrameExpandArrow]], nil, nil, nil, {0, 1, 0, 1}, "orange", nil, 2)
			_G.DetailsBreakdownWindow.RegisterPluginButton(timelineButtonBreakdown, advancedDeathLogs.pluginObject, advancedDeathLogs.PluginAbsoluteName)
			pluginFrame.timelineButtonBreakdown = timelineButtonBreakdown

		--button: endurance
		local localizedEnduranceString = "Player Endurance"
		local enduranceButton = detailsFramework:NewButton(pluginFrame, _, "$parentModeEnduranceButton", "ModeEnduranceButton", CONST_BUTTON_WIDTH, mode_buttons_height, change_mode, BUTTON_INDEX_ENDURANCE, nil, nil, localizedEnduranceString, 1, options_button_template)
		enduranceButton:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
		enduranceButton:SetIcon([[Interface\RAIDFRAME\Raid-Icon-Rez]], nil, nil, nil, {0, 1, 0, 1}, "orange", nil, 2)
			--endurance button for the breakdown window
			local enduranceButtonBreakdown = detailsFramework:NewButton(pluginFrame, _, "$parentModeEnduranceButtonBreakdown", "ModeEnduranceButton", CONST_BUTTON_WIDTH, mode_buttons_height, change_mode, BUTTON_INDEX_ENDURANCE, nil, nil, localizedEnduranceString, 1, options_button_template)
			enduranceButtonBreakdown:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
			enduranceButtonBreakdown:SetIcon([[Interface\RAIDFRAME\Raid-Icon-Rez]], nil, nil, nil, {0, 1, 0, 1}, "orange", nil, 2)
			_G.DetailsBreakdownWindow.RegisterPluginButton(enduranceButtonBreakdown, advancedDeathLogs.pluginObject, advancedDeathLogs.PluginAbsoluteName)

		enduranceButton:SetPoint("topleft", pluginFrame.headerFrame, "topleft", CONST_BUTTON_XANCHOR, CONST_BUTTON_YANCHOR)
		timelineButton:SetPoint("left", enduranceButton, "right", 5, 0)
		currentEncounterButton:SetPoint("left", timelineButton, "right", 5, 0)

		--highlight buttons when the mouse hoverover // change the color of button for the current selected module
		local allButtons = {currentEncounterButton, timelineButton, enduranceButton}

		local setButtonAsPressed = function(button)
			button:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_SELECTED_TEMPLATE"))
			button:SetWidth(CONST_BUTTON_WIDTH)
		end

		function adlObject:RefreshButtons()
			--reset all button
			for _, button in ipairs(allButtons) do
				button:SetTemplate(detailsFramework:GetTemplate("button", "ADL_MENUBUTTON_TEMPLATE"))
				button:SetWidth(CONST_BUTTON_WIDTH)
			end

			if (adlObject.db.showing_type == 2) then --endurance
				setButtonAsPressed(enduranceButton)

			elseif (adlObject.db.showing_type == 3) then --current
				setButtonAsPressed(currentEncounterButton)

			elseif (adlObject.db.showing_type == 4) then --timeline
				setButtonAsPressed(timelineButton)
			end
		end

		--erase data button
		local wipeData = function(self)
			wipe(adlObject.endurance_database)

			wipe(advancedDeathLogs.dataBase.enemySpellCasts)
			wipe(advancedDeathLogs.dataBase.deathsPerSegment)
			wipe(advancedDeathLogs.dataBase.deathsOccurrences)
			wipe(advancedDeathLogs.dataBase.spellIdCache)
			wipe(advancedDeathLogs.dataBase.encounterInfo)

			adlObject.db.last_player = false
			adlObject.db.last_segment = false
			adlObject.db.last_boss = false
			adlObject:Refresh()
			adlObject:CanShowIcon()

			adlObject.currentFrame.OnResetAllData()
			ADLTimelineFrame.OnResetAllData()

			if (adlObject.db.showing_type == 3) then --current
				adlObject:ShowCurrent()

			elseif (adlObject.db.showing_type == 4) then --timeline
				adlObject:ShowTimeline()
			end
		end

		local resetButton = detailsFramework:NewButton(pluginFrame, _, "$parentDeleteButton", "ResetButton", CONST_BUTTON_WIDTH - 10, mode_buttons_height, wipeData, nil, nil, nil, Loc ["STRING_RESET"], 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		resetButton:SetPoint("topright", pluginFrame.headerFrame, "topright", CONST_BUTTON_XANCHOR * -1, CONST_BUTTON_YANCHOR)
		resetButton:SetIcon([[Interface\Buttons\UI-StopButton]], nil, nil, nil, {0, 1, 0, 1}, nil, nil, 2)

		--configure threshold
		local optionsButton = detailsFramework:NewButton(pluginFrame, _, "$parentOptionsPanelButton", "OptionsPanelButton", CONST_BUTTON_WIDTH - 10, mode_buttons_height, adlObject.OpenOptionsPanel, nil, nil, nil, Loc ["STRING_OPTIONS"], 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
		optionsButton:SetPoint("right", resetButton, "left", -2, 0)
		optionsButton:SetIcon([[Interface\Buttons\UI-OptionsButton]], nil, nil, nil, {0, 1, 0, 1}, nil, nil, 2)

		--refresh on open
		function adlObject:Refresh()
			adlObject:RefreshBossScroll()
			adlObject:HideAll()

			if (adlObject.db.showing_type == 2) then --endurance
				adlObject:ShowEndurance()

			elseif (adlObject.db.showing_type == 3) then --current
				adlObject:ShowCurrent()

			elseif (adlObject.db.showing_type == 4) then --timeline
				adlObject:ShowTimeline()
			end

			adlObject:RefreshButtons()
		end

		advancedDeathLogs.mainFrame.BuildEnduranceFrames()
		advancedDeathLogs.mainFrame.BuildEncounterDeathsFrames()
		advancedDeathLogs.mainFrame.BuildTimelineFrames()
	end
end
