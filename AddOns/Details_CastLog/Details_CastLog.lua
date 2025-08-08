--fazer o scroll na vertical ter um thumb maior
--adicionar uma lupa no scroll do "zoom'
--implementar no details o nome do boss e o tempo de luta

--spells_cast_timeline is saving within the combatObject

do
	local Details = Details
	if (not Details) then
		print ("Details! Not Found.")
		return
	end

	local _
	---@type detailsframework
	local detailsFramework = _G.DetailsFramework

	local UnitGUID = _G.UnitGUID
	local GetTime = _G.GetTime
	local tremove = _G.tremove
	local tinsert = _G.tinsert
	local UnitBuff = _G.UnitBuff
	local UnitIsPlayer = _G.UnitIsPlayer
	local UnitInParty = _G.UnitInParty
	local UnitInRaid = _G.UnitInRaid
	local UnitIsUnit = _G.UnitIsUnit
	local abs = _G.abs
	local wipe = _G.wipe
	local unpack = _G.unpack

	local GetSpellInfo = Details.GetSpellInfo

	--minimal details version required to run this plugin
	local MINIMAL_DETAILS_VERSION_REQUIRED = 136
	local CASTLOG_VERSION = "v2.1.0"

	local CONST_COOLDOWN_TYPE_OFFENSIVE = 1
	local CONST_COOLDOWN_TYPE_DEFENSIVE_PERSONAL = 2
	local CONST_COOLDOWN_TYPE_DEFENSIVE_TARGET = 3
	local CONST_COOLDOWN_TYPE_DEFENSIVE_RAID = 4

	--create a plugin object
	local castLog = Details:NewPluginObject("Details_CastLog", _G.DETAILSPLUGIN_ALWAYSENABLED)
	--set the description
	castLog:SetPluginDescription("Show a time line of casts of players")

	--spells cache
	local preCastCache = {}
	local auraCache = {}

	--when receiving an event from details, handle it here
	local onDetailsEvent = function(event, ...)
		if (event == "COMBAT_PLAYER_ENTER") then
			castLog.OnCombatStart(...)

		elseif (event == "COMBAT_PLAYER_LEAVE") then
			castLog.OnCombatEnd(...)

		elseif (event == "PLUGIN_DISABLED") then
			--plugin has been disabled at the details options panel

		elseif (event == "PLUGIN_ENABLED") then
			--plugin has been enabled at the details options panel

		elseif (event == "DETAILS_DATA_SEGMENTREMOVED") then
			--old segment got deleted by the segment limit

		elseif (event == "DETAILS_DATA_RESET") then
			--combat data got wiped

		end
	end

	function castLog.GetActorObjectFromGUID(combat, GUID)
		local damageActors = combat[1]._ActorTable
		for i = 1, #damageActors do
			local actor = damageActors[i]
			if (actor.serial == GUID) then
				return actor
			end
		end

		local healingActors = combat[2]._ActorTable
		for i = 1, #healingActors do
			local actor = healingActors[i]
			if (actor.serial == GUID) then
				return actor
			end
		end
	end

	function castLog.InstallTab()
		local tabName = "CastTimeline"
		local tabNameLoc = "Cast Log"

		local canShowTab = function(tabOBject, playerObject)

			do return true end

			local combatObject = Details:GetCombatFromBreakdownWindow()

			if (combatObject) then
				--get combat unique id
				local combatId = combatObject:GetCombatUID()
				local combatCastLogData = castLog.GetDataByCombatId(combatId)
				if (combatCastLogData) then
					if (combatCastLogData.spells_cast_timeline[playerObject.serial]) then
						return true
					end
				else
					--castLog:Msg("there's no data for this combat.")
				end
			end

			return false
		end

		local fillTab = function(tab, playerObject, combatObject)
			function castLog.UpdateTimelineFrame(importedScrollData)
				--enable the 4 buttons for cooldown, only auras, only attack cooldowns and only defense cooldowns
				tab.frame.showOnlyCooldownsButton:Enable()
				tab.frame.showOnlyAurasButton:Enable()
				tab.frame.showPlayersAttackCooldownsButton:Enable()
				tab.frame.showPlayersDefenseCooldownsButton:Enable()
				tab.frame.exportButton:Enable()
				tab.frame.saveDataButton:Enable()

				tab.bIsShowingImportedData = false

				if (importedScrollData) then
					local combatTime = 0
					--disable the 4 buttons for cooldown, only auras, only attack cooldowns and only defense cooldowns
					tab.frame.showOnlyCooldownsButton:Disable()
					tab.frame.showOnlyAurasButton:Disable()
					tab.frame.showPlayersAttackCooldownsButton:Disable()
					tab.frame.showPlayersDefenseCooldownsButton:Disable()
					tab.frame.exportButton:Disable()
					tab.frame.saveDataButton:Disable()

					tab.bIsShowingImportedData = true

					--find the combat time by the last spell casted
					for spellId, spellData in pairs(importedScrollData.lines) do
						local timeLine = spellData.timeline
						for i = 1, #timeLine do
							local spellCastTime = timeLine[i][1]
							if (spellCastTime > combatTime) then
								combatTime = spellCastTime
							end
						end
					end

					combatTime = combatTime + 10

					importedScrollData.length = combatTime
					local scrollData = importedScrollData

					castLog.currentData = scrollData
					--dumpt(scrollData)

					tab.frame.timeLineFrame:SetData(scrollData)
					local minValue, maxValue = tab.frame.timeLineFrame.scaleSlider:GetMinMaxValues()
					tab.frame.timeLineFrame.scaleSlider:SetValue(0.6)

					local ignoreSpell = function(self)
						local spellId = self:GetParent():GetParent().spellId
						if (spellId) then
							local ignoredSpells = castLog.db.ignored_spells
							local classTable = ignoredSpells[castLog.currentPlayerClass]

							if (classTable) then
								classTable[spellId] = true
								tab.frame.OpenOptions(1, true)
								castLog.UpdateTimelineFrame()
							else
								detailsFramework:Msg("this actor does not have a class.")
							end
						else
							detailsFramework:Msg("spellId not found for this button.")
						end
					end

					local allLines = tab.frame.timeLineFrame.lines
					for i = 1, #allLines do
						local lineHeader = allLines[i].lineHeader

						if (not lineHeader.ignoreButtton) then
							local ignoreButtton = detailsFramework:CreateButton(lineHeader, ignoreSpell, 20, 20, "X", _, _, _, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
							lineHeader.ignoreButtton = ignoreButtton
							ignoreButtton:SetPoint("right", lineHeader, "right", -2, 0)
							ignoreButtton:SetBackdropColor(.1, .1, .1, .7)
							ignoreButtton.onleave_backdrop = {.1, .1, .1, .7}
							ignoreButtton.onenter_backdrop = {.3, .3, .3, .7}
							ignoreButtton:SetBackdropBorderColor(0, 0, 0, 0)
							ignoreButtton.onenter_backdrop_border_color = {0, 0, 0, 0}
							ignoreButtton.onleave_backdrop_border_color = {0, 0, 0, 0}
						else
							lineHeader.ignoreButtton:SetClickFunction(ignoreSpell)
						end

						lineHeader.ignoreButtton:SetAlpha(1)
					end

					return

				elseif (castLog.db.only_players_attack_cooldowns or castLog.db.only_players_defensive_cooldowns) then
					local combatCastLogData = castLog.GetDataByCombatId(combatObject:GetCombatUID())
					if (not combatCastLogData) then
						--castLog:Msg("there's no data for this combat.")
						return
					end

					local combatTime = combatCastLogData.combatTime --seconds elapsed
					local combatStartTime = combatCastLogData.combatStartTime --gettime

					local onlyShowAttackCDs = castLog.db.only_players_attack_cooldowns
					local onlyShowDefensiveCDs = castLog.db.only_players_defensive_cooldowns
					local castData = combatCastLogData.spells_cast_timeline or {} --uses GUID has key

					local ignoredSpells = castLog.db.ignored_spells
					local ignoredSpellForAllClasses = ignoredSpells.ALL

					local playerData = {} --playerData[GUID] = {{time, 10, 0, 0 spellId}, {time, 10, 0, 0 spellId}, {time, 10, 0, 0 spellId}, {time, 10, 0, 0 spellId}}

					--iterate among all players and build a list of cooldown usage of offensive or defensive cooldowns
					for playerGUID, castTable in pairs(castData) do
						local actorObject = castLog.GetActorObjectFromGUID(combatObject, playerGUID)
						if (actorObject) then
							local playerClass = actorObject:Class()
							local ignoredSpellsForClass = ignoredSpells[playerClass]

							local thisPlayerData = {}
							playerData[playerGUID] = thisPlayerData

							--castTable is a indexed table with {time, spellId, target}
							for i = 1, #castTable do
								local castEvent = castTable[i]
								local atTime = castEvent[1]
								local spellId = castEvent[2]
								local payload = castEvent[3]

								--check if the spell isn't ignored
								if (not ignoredSpellsForClass[spellId] and not ignoredSpellForAllClasses[spellId]) then
									--get the cooldown type
									local cdType = LIB_OPEN_RAID_COOLDOWNS_INFO[spellId] and LIB_OPEN_RAID_COOLDOWNS_INFO[spellId].type
									if (cdType) then
										if (onlyShowAttackCDs and cdType == CONST_COOLDOWN_TYPE_OFFENSIVE) then
											thisPlayerData[#thisPlayerData+1] = {atTime - combatStartTime, 10, 0, 0, spellId, ["payload"] = payload} --has 5 indexes, the 5th is the spellId

										elseif (onlyShowDefensiveCDs and (cdType == CONST_COOLDOWN_TYPE_DEFENSIVE_PERSONAL or cdType == CONST_COOLDOWN_TYPE_DEFENSIVE_TARGET or cdType == CONST_COOLDOWN_TYPE_DEFENSIVE_RAID)) then
											thisPlayerData[#thisPlayerData+1] = {atTime - combatStartTime, 10, 0, 0, spellId, ["payload"] = payload} --has 5 indexes, the 5th is the spellId
										end
									end
								end
							end
						end
					end

					local scrollData = {
						length = combatTime,
						defaultColor = {1, 1, 1, 1},
						useIconOnBlocks = true,
						lines = {},
					}

					local resultTable = {}

					for playerGUID, playerCooldownUsage in pairs(playerData) do
						local actorObject = castLog.GetActorObjectFromGUID(combatObject, playerGUID)
						if (actorObject) then
							local useAlpha = false
							local specTexture, left, right, top, bottom = Details:GetSpecIcon(actorObject.spec, useAlpha)

							specTexture = specTexture or ""
							left = left or 0
							right = right or 1
							top = top or 0
							bottom = bottom or 1

							local playerNameNoRealm = actorObject:GetOnlyName() or "no player"

							local role = Details.specToRole[actorObject.spec] or "NONE"
							local roleId = 0

							if (castLog.db.only_players_attack_cooldowns) then
								roleId = role == "DAMAGER" and 1 or role == "HEALER" and 2 or role == "TANK" and 3 or "NONE" and 0

							elseif (castLog.db.only_players_defensive_cooldowns) then
								roleId = role == "DAMAGER" and 3 or role == "HEALER" and 2 or role == "TANK" and 1 or "NONE" and 0
							end

							roleId = roleId + (string.byte(playerNameNoRealm, 1) + (string.byte(playerNameNoRealm, 2)) / 4) / 1000

							--[1] icon [2] GUID [3] player name [4] cooldown usage [5] role
							resultTable[#resultTable+1] = {{specTexture, left, right, top, bottom}, playerGUID, playerNameNoRealm, playerCooldownUsage, role, roleId}
						end
					end

					table.sort(resultTable, function(t1, t2) return t1[6] < t2[6] end)

					for i, resultData in ipairs(resultTable) do
						--doing the sort thing and after add the tables inthe the scrollData
						--create the line information for this player
						local playerTable = {
							isPlayer = true,
							text = resultData[3],
							icon = resultData[1][1],
							coords = {resultData[1][2], resultData[1][3], resultData[1][4], resultData[1][5]},
							timeline = resultData[4],
						}

						--add a new line to the timeline frame
						tinsert(scrollData.lines, playerTable)
					end

					castLog.currentData = scrollData
					--dumpt(scrollData)

					tab.frame.timeLineFrame:SetData(scrollData)
					local minValue = tab.frame.timeLineFrame.scaleSlider:GetMinMaxValues()
					tab.frame.timeLineFrame.scaleSlider:SetValue(0.6)

					local ignoreSpell = function(self)
						return Details:Msg("Can't ignore this unit.")
					end

					local allLines = tab.frame.timeLineFrame.lines
					for i = 1, #allLines do
						local lineHeader = allLines[i].lineHeader

						if (not lineHeader.ignoreButtton) then
							local ignoreButtton = detailsFramework:CreateButton(lineHeader, ignoreSpell, 20, 20, "X", _, _, _, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
							lineHeader.ignoreButtton = ignoreButtton
							ignoreButtton:SetPoint("right", lineHeader, "right", -2, 0)
							ignoreButtton:SetBackdropColor(.1, .1, .1, .7)
							ignoreButtton.onleave_backdrop = {.1, .1, .1, .7}
							ignoreButtton.onenter_backdrop = {.3, .3, .3, .7}
							ignoreButtton:SetBackdropBorderColor(0, 0, 0, 0)
							ignoreButtton.onenter_backdrop_border_color = {0, 0, 0, 0}
							ignoreButtton.onleave_backdrop_border_color = {0, 0, 0, 0}
						else
							lineHeader.ignoreButtton:SetClickFunction(ignoreSpell)
						end

						lineHeader.ignoreButtton:SetAlpha(0.2)
					end

				else
					--get the player cast data

					local combatCastLogData = castLog.GetDataByCombatId(combatObject:GetCombatUID())
					if (not combatCastLogData) then
						castLog:Msg("there's no data for this combat.")
						return
					end

					local castData = combatCastLogData.spells_cast_timeline[playerObject and playerObject.serial]
					--if there at least one event?
					if (castData and castData[1]) then
						local spellData = {}

						local combatTime = combatCastLogData.combatTime --seconds elapsed
						local combatStartTime = combatCastLogData.combatStartTime --gettime
						if (not combatStartTime) then
							castLog:Msg("there's no data for this combat or the combat is not finish.")
							return
						end

						castLog.currentPlayerClass = playerObject.classe

						local auraData = combatCastLogData.aura_timeline[playerObject and playerObject.serial]

						--if the button to show only auras are pressed
						local onlyShowAuras = castLog.db.only_auras
						local onlyShowCooldowns = castLog.db.only_cooldowns

						--cast data
						for i = 1, #castData do
							local cast = castData[i]
							local atTime = cast[1] --when it was casted
							local spellId = cast[2] --the spellId of the spell
							local payload = cast[3] --contains the spell target

							local hasCooldownType = LIB_OPEN_RAID_COOLDOWNS_INFO[spellId] and LIB_OPEN_RAID_COOLDOWNS_INFO[spellId].type

							if (not onlyShowCooldowns or hasCooldownType) then
								local auraTimers = auraData[spellId]
								if (auraTimers) then
									auraTimers = auraTimers.data
									local foundAuraTimer = false

									for o = 1, #auraTimers do
										local auraTimer = auraTimers[o]

										if (detailsFramework:IsNearlyEqual(auraTimer[1], atTime, 0.650)) then --when it was applyed, using 650ms as latency compensation
											foundAuraTimer = true

											local auraActivationData = auraTimer
											local applied = auraActivationData[1]
											local wentOff = auraActivationData[2]
											local duration = wentOff - applied

											spellData[spellId] = spellData[spellId] or {}
											tinsert(spellData[spellId], {applied - combatStartTime, 10, duration, duration, ["payload"] = payload}) --has 4 indexes
											break
										end
									end

									--if this event does not have a duration (if the event has a duration, it has an aura applied)
									if (not foundAuraTimer) then
										--if not showing only auras this event can be shown
										if (not onlyShowAuras) then
											spellData[spellId] = spellData[spellId] or {}
											tinsert(spellData[spellId], {atTime - combatStartTime, 1, ["payload"] = payload}) --has 2 indexes
										end
									end
								else
									if (not onlyShowAuras) then
										spellData[spellId] = spellData[spellId] or {}
										tinsert(spellData[spellId], {atTime - combatStartTime, 1, ["payload"] = payload}) --has 2 indexes
									end
								end
							end
						end

						local scrollData = {
							length = combatTime,
							defaultColor = {1, 1, 1, 1},
							useIconOnBlocks = true,
							lines = {},
						}

						do
							local ignoredSpells = castLog.db.ignored_spells
							local playerClass = castLog.currentPlayerClass
							local ignoredSpellsForClass = ignoredSpells[playerClass]
							local ignoredSpellForAllClasses = ignoredSpells.ALL

							for spellId, spellTimers in pairs(spellData) do
								--check if the spell isn't ignored
								if (not ignoredSpellsForClass[spellId] and not ignoredSpellForAllClasses[spellId]) then
									local spellName, rank, spellIcon = GetSpellInfo(spellId)

									local spellTable = {
										text = spellName,
										icon = spellIcon,
										spellId = spellId,
										timeline = spellTimers, --each table inside has the .payload
									}
									tinsert(scrollData.lines, spellTable)
								end
							end
						end

						castLog.currentData = scrollData
						--dumpt(scrollData)

						tab.frame.timeLineFrame:SetData(scrollData)
						local minValue, maxValue = tab.frame.timeLineFrame.scaleSlider:GetMinMaxValues()
						tab.frame.timeLineFrame.scaleSlider:SetValue(0.6)

						local ignoreSpell = function(self)
							local spellId = self:GetParent():GetParent().spellId
							if (spellId) then
								local ignoredSpells = castLog.db.ignored_spells
								local classTable = ignoredSpells[castLog.currentPlayerClass]

								if (classTable) then
									classTable[spellId] = true
									tab.frame.OpenOptions(1, true)
									castLog.UpdateTimelineFrame()
								else
									detailsFramework:Msg("this actor does not have a class.")
								end
							else
								detailsFramework:Msg("spellId not found for this button.")
							end
						end

						local allLines = tab.frame.timeLineFrame:GetAllLines()
						for i = 1, #allLines do
							local lineHeader = allLines[i].lineHeader

							if (not lineHeader.ignoreButtton) then
								local ignoreButtton = detailsFramework:CreateButton(lineHeader, ignoreSpell, 20, 20, "X", _, _, _, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
								lineHeader.ignoreButtton = ignoreButtton
								ignoreButtton:SetPoint("right", lineHeader, "right", -2, 0)
								ignoreButtton:SetBackdropColor(.1, .1, .1, .7)
								ignoreButtton.onleave_backdrop = {.1, .1, .1, .7}
								ignoreButtton.onenter_backdrop = {.3, .3, .3, .7}
								ignoreButtton:SetBackdropBorderColor(0, 0, 0, 0)
								ignoreButtton.onenter_backdrop_border_color = {0, 0, 0, 0}
								ignoreButtton.onleave_backdrop_border_color = {0, 0, 0, 0}
							else
								lineHeader.ignoreButtton:SetClickFunction(ignoreSpell)
							end

							lineHeader.ignoreButtton:SetAlpha(1)
						end
					else
						--this player has no timeline data to show
						--clear the timeline frame, or unselect it and show the overall spells breakdown
						castLog:Msg("there's no data for player", playerObject and playerObject.nome)
					end
				end

				castLog.UpdateShowButtons()
			end

			castLog.UpdateTimelineFrame()
		end

		local onCreatedTab = function(tab, frame)
			frame:SetBackdrop(nil)
			local gameCooltip = _G.GameCooltip

			local timeLineFrame = detailsFramework:CreateTimeLineFrame(frame, "$parentTimeLine", { --general options
				width = 900, height = 465,

				backdrop_color = {1, 1, 1, .1}, --line backdrop
				backdrop_color_highlight = {1, 1, 1, .3},

				slider_backdrop_color = {.2, .2, .2, 0.3},
				slider_backdrop_border_color = {0.2, 0.2, 0.2, .3},

				on_enter = function(self)
					self:SetBackdropColor(unpack(self.backdrop_color_highlight))
				end,

				on_leave = function(self)
					if (self.dataIndex % 2 == 1) then
						self:SetBackdropColor(1, 1, 1, 0)
					else
						self:SetBackdropColor(1, 1, 1, .1)
					end
				end,

				header_on_enter = function(lineHeader)
					local line = lineHeader:GetParent()
					local spellId = line.spellId
					if (spellId) then
						GameTooltip:SetOwner(lineHeader, "ANCHOR_TOPLEFT")
						GameTooltip:SetSpellByID(spellId)
						GameTooltip:Show()
						lineHeader:SetBackdropColor(unpack(line.backdrop_color_highlight))
					end
				end,

				header_on_leave = function(lineHeader)
					GameTooltip:Hide()
					local line = lineHeader:GetParent()
					if (line.dataIndex % 2 == 1) then
						line:SetBackdropColor(1, 1, 1, 0)
						lineHeader:SetBackdropColor(1, 1, 1, 0)
					else
						line:SetBackdropColor(1, 1, 1, .1)
						lineHeader:SetBackdropColor(1, 1, 1, .1)
					end
				end,

				--on entering a spell icon
				block_on_enter = function(self)
					local info = self.info
					local spellName, rank, spellIcon = GetSpellInfo(info.spellId)

					local minutes = math.floor(info.time / 60)
					local seconds = info.time - (minutes * 60)
					seconds = detailsFramework:TruncateNumber(seconds, 1)

					--color the decimal part of the seconds in gray
					local secondsStr = tostring(seconds)
					local dotIndex = secondsStr:find("%.")
					if (dotIndex) then
						local decimals = secondsStr:sub(dotIndex)
						secondsStr = secondsStr:gsub(decimals, "|cff808080" .. decimals .. "|r")
					end

					local castAtTime
					if (info.time < -0.2) then
						castAtTime = "-0" .. secondsStr
					else
						if (seconds < 10) then
							secondsStr =  "0" .. secondsStr
						end
						castAtTime = minutes .. ":" .. secondsStr
					end

					gameCooltip:Reset()
					gameCooltip:SetOwner(self)
					gameCooltip:SetOption("TextSize", 10)
					gameCooltip:AddLine(spellName, castAtTime)
					gameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)

					if (info.duration) then
						gameCooltip:AddLine("Duration:", detailsFramework:IntegerToTimer(info.duration))
					end
					if (info.payload and type(info.payload) == "string" and info.payload ~= "") then
						gameCooltip:AddLine("Target:", info.payload)
					end

					--gameCooltip:AddLine("SpellId:", info.spellId)
					gameCooltip:Show()

					self.icon:SetBlendMode("ADD")
				end,

				block_on_leave = function(self)
					gameCooltip:Hide()
					self.icon:SetBlendMode("BLEND")
				end,
			},

			{ --timeline frame options
				draw_line_color = {1, 1, 1, 0.03},
			})

			local verticalSliderText = timeLineFrame.verticalSlider:CreateFontString(nil, "artwork", "GameFontNormal")
				verticalSliderText:SetPoint("center", timeLineFrame.verticalSlider, "center", 7, 0)
				verticalSliderText:SetText("shift + scroll")
				detailsFramework:SetFontColor(verticalSliderText, "silver")
				verticalSliderText:SetAlpha(1)

				local makeVerticalAnimHub = detailsFramework:CreateAnimationHub(verticalSliderText)
				local rotationAnimation = detailsFramework:CreateAnimation(makeVerticalAnimHub, "rotation", 1, 0, 270)
				rotationAnimation:SetEndDelay(99999999)
				rotationAnimation:SetSmoothProgress(1)
				makeVerticalAnimHub:Play()
				makeVerticalAnimHub:Pause()

			local horizontalSliderText = timeLineFrame.horizontalSlider:CreateFontString(nil, "artwork", "GameFontNormal")
				horizontalSliderText:SetPoint("center", timeLineFrame.horizontalSlider, "center", 0, 0)
				horizontalSliderText:SetText("scroll")
				detailsFramework:SetFontColor(horizontalSliderText, "silver")
				horizontalSliderText:SetAlpha(1)

			local scaleSliderText = timeLineFrame.scaleSlider:CreateFontString(nil, "artwork", "GameFontNormal")
				scaleSliderText:SetPoint("center", timeLineFrame.scaleSlider, "center", 0, 0)
				scaleSliderText:SetText("ctrl + scroll")
				detailsFramework:SetFontColor(scaleSliderText, "silver")
				scaleSliderText:SetAlpha(1)

			local scrollText = detailsFramework:CreateLabel(timeLineFrame.horizontalSlider, "scroll", 15, {.9, .9, .9, 1})
				scrollText:SetPoint("right", timeLineFrame.horizontalSlider, "right", -2, 0)

			local zoomText = detailsFramework:CreateLabel(timeLineFrame.scaleSlider, "zoom", 15, {.9, .9, .9, 1})
				zoomText:SetPoint("right", timeLineFrame.scaleSlider, "right", -2, 0)

			timeLineFrame:SetPoint("topleft", frame, "topleft", 0, 0)
			frame.timeLineFrame = timeLineFrame

			timeLineFrame.__background:SetAlpha(.8)

			function castLog.UpdateShowButtons()
				--the timeline is refreshed at creation and these buttons does not exists at that point
				if (not frame.showOnlyCooldownsButton) then
					return
				end

				--reset
				frame.showOnlyCooldownsButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
				frame.showOnlyAurasButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
				frame.showPlayersAttackCooldownsButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
				frame.showPlayersDefenseCooldownsButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")

				if (castLog.db.only_cooldowns) then
					frame.showOnlyCooldownsButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")

				elseif (castLog.db.only_auras) then
					frame.showOnlyAurasButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")

				elseif (castLog.db.only_players_attack_cooldowns) then
					frame.showPlayersAttackCooldownsButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")

				elseif (castLog.db.only_players_defensive_cooldowns) then
					frame.showPlayersDefenseCooldownsButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
				end

				local width = 120
				local height = 20
				frame.showOnlyCooldownsButton:SetSize(width, height)
				frame.showOnlyAurasButton:SetSize(width, height)
				frame.showPlayersAttackCooldownsButton:SetSize(width, height)
				frame.showPlayersDefenseCooldownsButton:SetSize(width, height)
			end

			--reset zoom button

			--ignored spells button
			local openOptions = function(sectionId, mustShow)
				if (not frame.optionsFrame) then
					local breakdownWindow = Details:GetBreakdownWindow()

					local optionsFrame = CreateFrame("frame", "$parentOptionsFrame", breakdownWindow, "BackdropTemplate")
					optionsFrame:SetWidth(200)
					optionsFrame:SetPoint("topleft", breakdownWindow, "topright", 0, 0)
					optionsFrame:SetPoint("bottomleft", breakdownWindow, "bottomright", 0, 0)
					frame.optionsFrame = optionsFrame

					--> create ignored spell frame
						local ignoredSpellFrame = CreateFrame("frame", "$parentIgnoredSpellsFrame", optionsFrame, "BackdropTemplate")
						ignoredSpellFrame:SetAllPoints()
						ignoredSpellFrame:Hide()
						optionsFrame.ignoredSpellFrame = ignoredSpellFrame

						--label in the bottom of the window saying 'ignored spells'
						local ignoredSpellLabel = detailsFramework:CreateLabel(ignoredSpellFrame, "ignored spells", 11, "white")
						ignoredSpellLabel:SetPoint("bottom-bottom", 0, 5)

						local refreshSpellsIgnoredScroll = function(self, data, offset, totalLines)
							local listOfIgnoredSpells = {}

							--get all spells for all classes and show in the panel
							local ignoredSpells = castLog.db.ignored_spells
							local playerClass = castLog.currentPlayerClass
							local ignoredSpellsForClass = ignoredSpells[playerClass]

							if (ignoredSpellsForClass) then
								for spellId in pairs(ignoredSpellsForClass) do
									listOfIgnoredSpells[#listOfIgnoredSpells+1] = spellId
								end

								for className, ignoredSpellsOfClass in pairs(ignoredSpells) do
									if (className ~= playerClass and className ~= "ALL") then
										for spellId in pairs(ignoredSpellsOfClass) do
											listOfIgnoredSpells[#listOfIgnoredSpells+1] = spellId
										end
									end
								end
							else
								for className, ignoredSpells in pairs(ignoredSpells) do
									if  (className ~= "ALL") then
										for spellId in pairs(ignoredSpells) do
											listOfIgnoredSpells[#listOfIgnoredSpells+1] = spellId
										end
									end
								end
							end

							local spellList = {}
							for index = 1, #listOfIgnoredSpells do
								local spellId = listOfIgnoredSpells[index]
								local spellName, rank, spellIcon = GetSpellInfo(spellId)
								if (spellName) then
									spellList[#spellList+1] = {spellName, spellIcon, spellId}
								end
							end

							for i = 1, totalLines do
								local index = i + offset
								local thisData = spellList[index]
								if (thisData) then
									local line = self:GetLine(i)
									local spellName, spellIcon, spellId = thisData[1], thisData[2], thisData[3]
									line.spellName:SetText(spellName)
									line.spellIcon:SetTexture(spellIcon)
									line.spellIcon:SetTexCoord(.1, .9, .1, .9)
									line.spellIdLabel:SetText(spellId)
									line.spellId = spellId
								end
							end
						end

						local spellsSelectionAmoutLines = 27
						local spellsSelectionLinesHeight = 20
						local scrollbox_line_backdrop_color = {0, 0, 0, 0.5}
						local scrollbox_line_backdrop_color_hightlight = {.4, .4, .4, 0.6}
						local scrollbox_line_backdrop_color_selected = {.7, .7, .7, 0.8}

						local spellsIgnoredScroll = detailsFramework:CreateScrollBox(ignoredSpellFrame, "$parentScroll", refreshSpellsIgnoredScroll, {}, ignoredSpellFrame:GetWidth() - 2, ignoredSpellFrame:GetHeight(), spellsSelectionAmoutLines, spellsSelectionLinesHeight)
						ignoredSpellFrame.spellsIgnoredScroll = spellsIgnoredScroll
						detailsFramework:ReskinSlider(spellsIgnoredScroll)
						spellsIgnoredScroll:SetPoint("topleft", ignoredSpellFrame, "topleft", 0, 0)
						spellsIgnoredScroll:SetPoint("bottomright", ignoredSpellFrame, "bottomright", -22, 0)

						local onEnterLine = function(self)
							self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_hightlight))
						end

						local onLeaveLine = function(self)
							self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
						end

						local removeIgnoredSpell = function(self)
							local parent = self:GetParent()
							local spellId = parent.spellId

							if (not spellId) then
								return
							end

							local ignoredSpells = castLog.db.ignored_spells
							local classTable = ignoredSpells[castLog.currentPlayerClass]
							if (classTable) then
								classTable[spellId] = nil
								spellsIgnoredScroll:Refresh()
								castLog.UpdateTimelineFrame()
							else
								detailsFramework:Msg("this actor does not have a class.")
							end
						end

						--create scroll lines
						local createIgnoredSpellLine = function(self, index)
							local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
							line:SetPoint("topleft", self, "topleft", 0, -((index - 1) * (spellsSelectionLinesHeight + 1)) - 1)
							line:SetSize(self:GetWidth(), spellsSelectionLinesHeight)

							line:RegisterForClicks("LeftButtonDown", "RightButtonDown")
							detailsFramework:ApplyStandardBackdrop(line)

							line:SetScript("OnEnter", onEnterLine)
							line:SetScript("OnLeave", onLeaveLine)

							line.index = index

							--spell icon
							local spellIcon = line:CreateTexture("$parentIcon", "overlay")
							spellIcon:SetSize(spellsSelectionLinesHeight-2, spellsSelectionLinesHeight-2)
							spellIcon:SetPoint("left", line, "left", 2, 0)
							line.spellIcon = spellIcon

							local spellName = line:CreateFontString(nil, "overlay", "GameFontNormal")
							spellName:SetPoint("left", spellIcon, "right", 3, 0)
							detailsFramework:SetFontSize(spellName, 10)

							local removeButton = detailsFramework:CreateButton(line, removeIgnoredSpell, 20, 20, "X", _, _, _, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
							removeButton:SetPoint("right", line, "right", -2, 0)

							local spellIdLabel = line:CreateFontString(nil, "overlay", "GameFontNormal")
							spellIdLabel:SetPoint("right", removeButton.widget, "left", -2, 0)
							detailsFramework:SetFontSize(spellIdLabel, 6)
							detailsFramework:SetFontColor(spellIdLabel, "gray")
							spellIdLabel:SetAlpha(.6)

							line.spellIcon = spellIcon
							line.spellName = spellName
							line.removeButton = removeButton
							line.spellIdLabel = spellIdLabel

							return line
						end

						--create the scrollbox lines
						for i = 1, spellsSelectionAmoutLines do
							spellsIgnoredScroll:CreateLine(createIgnoredSpellLine, i)
						end


					--> create merged spell frame
						local mergedSpellFrame = CreateFrame("frame", "$parentMergedSpellsFrame", optionsFrame, "BackdropTemplate")
						mergedSpellFrame:SetAllPoints()
						mergedSpellFrame:Hide()
						optionsFrame.mergedSpellFrame = mergedSpellFrame

						local refreshSpellsMergedScroll = function(self, data, offset, totalLines)
							local mergedSpells = castLog.db.merged_spells
							local classTable = mergedSpells[castLog.currentPlayerClass]
							if (not classTable) then
								return
							end

							local spellList = {}
							for spellId in pairs(classTable) do
								local spellName, rank, spellIcon = GetSpellInfo(spellId)
								if (spellName) then
									spellList[#spellList+1] = {spellName, spellIcon, spellId}
								end
							end

							table.sort(spellList, Details.Sort1)

							for i = 1, totalLines do
								local index = i + offset
								local thisData = spellList[index]
								if (thisData) then
									local line = self:GetLine(i)
									local spellName, spellIcon, spellId = thisData[1], thisData[2], thisData[3]
									line.spellName:SetText(spellName)
									line.spellIcon:SetTexture(spellIcon)
									line.spellIcon:SetTexCoord(.1, .9, .1, .9)
									line.spellId = spellId
								end
							end
						end

						local spellsMergedScroll = detailsFramework:CreateScrollBox(mergedSpellFrame, "$parentScroll", refreshSpellsMergedScroll, {}, mergedSpellFrame:GetWidth() - 2, mergedSpellFrame:GetHeight(), spellsSelectionAmoutLines, spellsSelectionLinesHeight)
						spellsMergedScroll.spellsMergedScroll = spellsMergedScroll
						detailsFramework:ReskinSlider(spellsMergedScroll)
						spellsMergedScroll:SetAllPoints()
						spellsMergedScroll:SetPoint("topleft", frame, "topleft", 0, -40)
						spellsMergedScroll:SetPoint("bottomright", frame, "bottomright", -22, 0)

						local onEnterLineMerged = function(self)
							self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_hightlight))
						end

						local onLeaveLineMerged = function(self)
							self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
						end

						local removeMergedSpell = function(self)
							local spellId = self.spellId
							local meergedSpells = castLog.db.merged_spells

							local classTable = meergedSpells[castLog.currentPlayerClass]
							if (classTable) then
								classTable[spellId] = nil
								spellsMergedScroll:Refresh()
							else
								detailsFramework:Msg("this actor does not have a class.")
							end
						end

						--create scroll lines
						local createSpellMergedLine = function(self, index)
							local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
							line:SetPoint("topleft", self, "topleft", 0, -((index - 1) * (spellsSelectionLinesHeight + 1)) - 1)
							line:SetSize(self:GetWidth(), spellsSelectionLinesHeight)

							line:RegisterForClicks("LeftButtonDown", "RightButtonDown")
							detailsFramework:ApplyStandardBackdrop(line)

							line:SetScript("OnEnter", onEnterLineMerged)
							line:SetScript("OnLeave", onLeaveLineMerged)

							line.index = index

							--spell icon
							local spellIcon = line:CreateTexture("$parentIcon", "overlay")
							spellIcon:SetSize(spellsSelectionLinesHeight, spellsSelectionLinesHeight)
							line.spellIcon = spellIcon

							local spellName = line:CreateFontString(nil, "overlay", "GameFontNormal")
							spellName:SetPoint("left", spellIcon, "right", 3, 0)
							detailsFramework:SetFontSize(spellName, 11)

							local removeButton = detailsFramework:CreateButton(line, removeMergedSpell, 20, 20, "X", _, _, _, _, _, _, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
							removeButton:SetPoint("right", self, "right", -2, 0)

							line.spellIcon = spellIcon
							line.spellName = spellName
							line.removeButton = removeButton

							return line
						end

						--create the scrollbox lines
						for i = 1, spellsSelectionAmoutLines do
							spellsMergedScroll:CreateLine(createSpellMergedLine, i)
						end
				end

				if (mustShow) then
					if (sectionId == 1) then
						frame.optionsFrame.ignoredSpellFrame:Show()
						frame.optionsFrame.mergedSpellFrame:Hide()
						frame.optionsFrame.ignoredSpellFrame.spellsIgnoredScroll:Refresh()

					elseif (sectionId == 2) then
						frame.optionsFrame.mergedSpellFrame:Show()
						frame.optionsFrame.ignoredSpellFrame:Hide()
					end

					return
				end

				if (frame.optionsFrame.ignoredSpellFrame:IsShown()) then
					if (sectionId == 1) then
						frame.optionsFrame.ignoredSpellFrame:Hide()
						frame.optionsFrame.mergedSpellFrame:Hide()
						return
					end
				end

				if (frame.optionsFrame.mergedSpellFrame:IsShown()) then
					if (sectionId == 2) then
						frame.optionsFrame.ignoredSpellFrame:Hide()
						frame.optionsFrame.mergedSpellFrame:Hide()
						return
					end
				end

				frame.optionsFrame.ignoredSpellFrame:Hide()
				frame.optionsFrame.mergedSpellFrame:Hide()

				if (sectionId == 1) then
					frame.optionsFrame.ignoredSpellFrame:Show()
					frame.optionsFrame.ignoredSpellFrame.spellsIgnoredScroll:Refresh()

				elseif (sectionId == 2) then
					frame.optionsFrame.mergedSpellFrame:Show()

				end

				castLog.UpdateShowButtons()
			end

			frame.OpenOptions = openOptions

			local ignoredSpellsButton = detailsFramework:CreateButton(frame, function() openOptions(1) end, 120, 20, "Ignored Spells", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPAQUE_DARK"))
				ignoredSpellsButton:SetPoint("topleft", frame, "topleft", 2, -2)
				ignoredSpellsButton:SetIcon([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])
				ignoredSpellsButton:SetSize(120, 18)
				ignoredSpellsButton:SetFrameLevel(frame.timeLineFrame:GetFrameLevel() + 5)
				ignoredSpellsButton:SetBackdropColor(.1, .1, .1, 1)

			--show only cooldowns
			local showOnlyCooldownsButton_Func = function()
				castLog.db.only_auras = false
				castLog.db.only_cooldowns = not castLog.db.only_cooldowns
				castLog.db.only_players_attack_cooldowns = false
				castLog.db.only_players_defensive_cooldowns = false
				castLog.UpdateTimelineFrame()
			end
			local showOnlyCooldownsButton = detailsFramework:CreateButton(frame, showOnlyCooldownsButton_Func, 120, 20, "Only Cooldowns", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
				--showOnlyCooldownsButton:SetPoint("left", ignoredSpellsButton, "right", 2, 0)
				showOnlyCooldownsButton:SetPoint("bottomleft", frame, "bottomleft", 0, 0)
				showOnlyCooldownsButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
				showOnlyCooldownsButton:SetIcon([[Interface\AddOns\Details\images\spec_icons_normal_alpha]], nil, nil, nil, {256/512, 320/512, 128/512, 192/512})
				frame.showOnlyCooldownsButton = showOnlyCooldownsButton

			--show only auras
			local showOnlyAurasButton_Func = function()
				castLog.db.only_auras = not castLog.db.only_auras
				castLog.db.only_cooldowns = false
				castLog.db.only_players_attack_cooldowns = false
				castLog.db.only_players_defensive_cooldowns = false
				castLog.UpdateTimelineFrame()
			end
			local showOnlyAurasButton = detailsFramework:CreateButton(frame, showOnlyAurasButton_Func, 120, 20, "Only Auras", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
				showOnlyAurasButton:SetPoint("left", showOnlyCooldownsButton, "right", 2, 0)
				showOnlyAurasButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
				showOnlyAurasButton:SetIcon([[Interface\AddOns\Details\images\spec_icons_normal_alpha]], nil, nil, nil, {320/512, 384/512, 128/512, 192/512})
				frame.showOnlyAurasButton = showOnlyAurasButton

			--players attack cooldowns usage
			local showPlayersAttackCooldownsButton_Func = function()
				castLog.db.only_auras = false
				castLog.db.only_cooldowns = false
				castLog.db.only_players_attack_cooldowns = not castLog.db.only_players_attack_cooldowns
				castLog.db.only_players_defensive_cooldowns = false
				castLog.UpdateTimelineFrame()
			end
			local showPlayersAttackCooldownsButton = detailsFramework:CreateButton(frame, showPlayersAttackCooldownsButton_Func, 120, 20, "A. Cooldowns", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
				showPlayersAttackCooldownsButton.tooltip = "Show only attack cooldowns usage."
				showPlayersAttackCooldownsButton:SetPoint("left", showOnlyAurasButton, "right", 2, 0)
				showPlayersAttackCooldownsButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
				showPlayersAttackCooldownsButton:SetIcon([[Interface\AddOns\Details\images\spec_icons_normal_alpha]], nil, nil, nil, {256/512, 320/512, 256/512, 320/512})
				frame.showPlayersAttackCooldownsButton = showPlayersAttackCooldownsButton

			--players defensive cooldowns usage
			local showPlayersDefensiveCooldownsButton_Func = function()
				castLog.db.only_auras = false
				castLog.db.only_cooldowns = false
				castLog.db.only_players_attack_cooldowns = false
				castLog.db.only_players_defensive_cooldowns = not castLog.db.only_players_defensive_cooldowns
				castLog.UpdateTimelineFrame()
			end
			local showPlayersDefenseCooldownsButton = detailsFramework:CreateButton(frame, showPlayersDefensiveCooldownsButton_Func, 120, 20, "D. Cooldowns", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			showPlayersDefenseCooldownsButton.tooltip = "Show only defensive cooldowns usage."
			showPlayersDefenseCooldownsButton:SetPoint("left", showPlayersAttackCooldownsButton, "right", 2, 0)
			showPlayersDefenseCooldownsButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
			showPlayersDefenseCooldownsButton:SetIcon([[Interface\AddOns\Details\images\spec_icons_normal_alpha]], nil, nil, nil, {64/512, 128/512, 256/512, 320/512})
			frame.showPlayersDefenseCooldownsButton = showPlayersDefenseCooldownsButton

			local exportTextEditor = detailsFramework:NewSpecialLuaEditorEntry(frame, 643, 402, "exportEditor", "$parentExportEditor", true)
			exportTextEditor:SetPoint("topleft", frame, "topleft", 0, 0)
			exportTextEditor:SetPoint("bottomright", frame, "bottomright", -24, 0)
			exportTextEditor:SetFrameLevel(frame:GetFrameLevel()+6)
			exportTextEditor:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,tile = 1, tileSize = 16})
			detailsFramework:ReskinSlider(exportTextEditor.scroll)
			exportTextEditor:SetBackdropColor(0.5, 0.5, 0.5, 0.95)
			exportTextEditor:SetBackdropBorderColor(0, 0, 0, 1)
			exportTextEditor:Hide()

			exportTextEditor:SetScript("OnShow", function()
				ignoredSpellsButton:Hide()
			end)

			exportTextEditor:SetScript("OnHide", function()
				ignoredSpellsButton:Show()
			end)

			local closeExportTextEditor_Func = function()
				exportTextEditor:ClearFocus()
				exportTextEditor:Hide()
			end

			local closeTextEditorButton = detailsFramework:CreateButton(exportTextEditor, closeExportTextEditor_Func, 120, 20, "Close", nil, nil, nil, "CloseExportButton", "$parentCloseButton", nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			closeTextEditorButton:SetPoint("bottomright", exportTextEditor, "bottomright", -2, 2)
			closeTextEditorButton:SetIcon([[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 24, 24)

			local importCastTimeline_Func = function(dataEncoded)
				if (dataEncoded == "") then
					castLog:Msg("failed to import: no data.")
					return
				end

				local dataDecoded = LibStub:GetLibrary("LibDeflate"):DecodeForPrint(dataEncoded)
				if (not dataDecoded) then
					castLog:Msg("failed to import: invalid data.")
					return
				end

				local dataDecompressed = LibStub:GetLibrary("LibDeflate"):DecompressDeflate(dataDecoded)
				if (not dataDecompressed) then
					castLog:Msg("failed to import: invalid data.")
					return
				end

				local dataUnpacked = detailsFramework.table.unpacksub(dataDecompressed)
				if (not dataUnpacked) then
					castLog:Msg("failed to import: invalid data.")
					return
				end

				local timelineData = {}
				local scrollData = {
					length = 0,
					defaultColor = {1, 1, 1, 1},
					useIconOnBlocks = true,
					lines = timelineData,
				}

				local playerInfo = table.remove(dataUnpacked, 1)
				local playerName = playerInfo[1]
				local playerSpec = playerInfo[2]

				for index, spellData in ipairs(dataUnpacked) do
					local spellId = spellData[1]
					local timeline = {}

					for i = 2, #spellData do
						local timeInSeconds = spellData[i]
						--seconds when the spell was casted, length of the block
						timeline[#timeline+1] = {timeInSeconds, 10}
					end

					local spellInfo = C_Spell.GetSpellInfo(spellId)

					timelineData[#timelineData+1] = {
						text = spellInfo and spellInfo.name or "Unknown",
						icon = spellInfo and spellInfo.iconID or 0,
						spellId = spellId,
						timeline = timeline
					}
				end

				---@class importedinfo : table
				---@field playerName string
				---@field spec number
				---@field data table
				---@field time number

				---@type importedinfo
				local importedInfo = {
					playerName = playerName,
					spec = playerSpec,
					data = scrollData,
					time = time(), --when the data was imported
				}

				castLog.db.imported_cast_logs[#castLog.db.imported_cast_logs+1] = importedInfo
				castLog.UpdateTimelineFrame(scrollData)
			end

			local comfirmImportCastTimeline_Func = function()
				local text = exportTextEditor:GetText()
				importCastTimeline_Func(text)
				closeExportTextEditor_Func()
			end

			--create a import button
			local confirmImportButton = detailsFramework:CreateButton(exportTextEditor, comfirmImportCastTimeline_Func, 120, 20, "Import", nil, nil, nil, "ConfirmImportButton", "$parentImportButton", nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			confirmImportButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 14, 14, "overlay", {0, 24/512, 332/512, 299/512}, {1, 0.85, 0, 1})
			confirmImportButton:SetPoint("right", closeTextEditorButton, "left", -5, 0)

			---@class spelldata : table
			---@field spellId number
			---@field text string
			---@field icon number
			---@field timeline table

			---@class blockinfo : table
			---@field [1] number timeInSeconds when used
			---@field [2] number length
			---@field [3] boolean isAura
			---@field [4] number auraDuration
			---@field [5] number spellId

			local exportCastTimeline_Func = function()
				--get the data currently shown in the timeline
				local scrollData = tab.frame.timeLineFrame.data
				local timelineData = scrollData.lines

				if (timelineData == nil) then
					castLog:Msg("no data to export.")
					return
				end

				--get the player object that is currently showing in the details! breakdown window
				local playerObject = Details:GetActorObjectFromBreakdownWindow()

				--prepare the data to pack
				local dataToPack = {{(playerObject:Name() or ""), (playerObject.spec or 0)}}

				--amount of fractions of a second to store
				local timeResolution = 0

				for index, spellData in ipairs(timelineData) do
					---@cast spellData spelldata
					local spellId = spellData.spellId
					local timeline = spellData.timeline

					local thisSpellPackData = {}
					thisSpellPackData[#thisSpellPackData+1] = spellId

					for i = 1, #timeline do
						---@type blockinfo
						local blockData = timeline[i]
						local timeInSeconds = blockData[1]
						local formattedNumber = detailsFramework.Math.Round(timeInSeconds, timeResolution)
						thisSpellPackData[#thisSpellPackData+1] = formattedNumber
					end

					dataToPack[#dataToPack+1] = thisSpellPackData
				end

				local packedData = detailsFramework.table.packsub(dataToPack)
				--compress the packed data
				local dataCompressed = LibStub:GetLibrary("LibDeflate"):CompressDeflate(packedData, {level = 9})
				local dataEncoded = LibStub:GetLibrary("LibDeflate"):EncodeForPrint(dataCompressed)

				closeTextEditorButton:Show()
				confirmImportButton:Hide()
				exportTextEditor:Show()
				exportTextEditor:SetText(dataEncoded)
				exportTextEditor.editbox:HighlightText()
				exportTextEditor.editbox:SetFocus(true)
			end

			local buttonWidth = 84

			---@type df_button
			local exportTimelineButton = detailsFramework:CreateButton(frame, exportCastTimeline_Func, buttonWidth, 20, "Export", nil, nil, nil, "exportButton", nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			exportTimelineButton:SetPoint("left", showPlayersDefenseCooldownsButton, "right", 5, 0)
			exportTimelineButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 14, 14, "overlay", {0, 24/512, 299/512, 332/512}, {1, 0.85, 0, 1})

			local openImportTextEditor_Func = function()
				exportTextEditor:Show()
				exportTextEditor:SetText("")
				exportTextEditor.editbox:SetFocus(true)
				closeTextEditorButton:Show()
				confirmImportButton:Show()
			end

			---@type df_button
			local importTimelineButton = detailsFramework:CreateButton(frame, openImportTextEditor_Func, buttonWidth, 20, "Import", nil, nil, nil, "importButton", nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			importTimelineButton:SetPoint("left", exportTimelineButton, "right", 2, 0)
			importTimelineButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 14, 14, "overlay", {0, 24/512, 332/512, 299/512}, {1, 0.85, 0, 1})

			local saveData_Func = function()
				local playerObject = Details:GetCombatFromBreakdownWindow()
				local combatUniqueId = playerObject:GetCombatUID()
				local data = castLog.GetDataByCombatId(combatUniqueId)

				if (data) then
					exportCastTimeline_Func()
					comfirmImportCastTimeline_Func()
				else
					castLog:Msg("no data to save.")
				end
			end

			---@type df_button
			local saveSaveDataButton = detailsFramework:CreateButton(frame, saveData_Func, buttonWidth, 20, "Save", nil, nil, nil, "saveDataButton", nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			saveSaveDataButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 14, 14, "overlay", {64/512, 90/512, 299/512, 325/512}, {1, 0.85, 0, 1})
			saveSaveDataButton:SetPoint("left", importTimelineButton, "right", 2, 0)

			local loadSavedImportedData = function(_, _, index)
				GameCooltip:Hide()
				---@type importedinfo
				local importedData = castLog.db.imported_cast_logs[index]
				if (importedData) then
					castLog.UpdateTimelineFrame(importedData.data)
				end
			end

			local showMenuWithAllImportedData = function(button)
				if (#castLog.db.imported_cast_logs == 0) then
					GameCooltip:Reset()
					GameCooltip:SetOwner(button)
					GameCooltip:AddLine("Select here logs that you have imported.")
					GameCooltip:AddLine("Logs are kept for 30 days.")
					GameCooltip:AddLine("You have zero logs imported.")
					GameCooltip:Show()
					return
				end

				GameCooltip:Reset()
				GameCooltip:SetOwner(button)

				for index, importedData in ipairs(castLog.db.imported_cast_logs) do
					local playerName = importedData.playerName
					local spec = importedData.spec
					local importedTime = importedData.time
					local importedDate = date("%d %b %Y", importedTime)

					local leftText = playerName
					local leftIcon, l, r, t, b = Details:GetSpecIcon(spec)

					GameCooltip:AddLine(leftText, importedDate, 1, "orange", "white")
					GameCooltip:AddIcon(leftIcon, 1, 1, 16, 16, l, r, t, b)
					GameCooltip:AddMenu(1, loadSavedImportedData, index)
				end

				GameCooltip:Show()
			end

			local loadImportedDataButton = detailsFramework:CreateButton(frame, showMenuWithAllImportedData, buttonWidth, 20, "Load", nil, nil, nil, "loadImportedDataButton", nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			loadImportedDataButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 14, 14, "overlay", {32/512, 56/512, 299/512, 332/512}, {1, 0.85, 0, 1})
			loadImportedDataButton:SetPoint("left", saveSaveDataButton, "right", 2, 0)

			local footerTexture = showOnlyCooldownsButton.widget:CreateTexture(nil, "overlay")
			footerTexture:SetPoint("topleft", showOnlyCooldownsButton.widget, "bottomleft", 0, 0)
			footerTexture:SetPoint("topright", loadImportedDataButton.widget, "bottomright", 0, 0)
			footerTexture:SetHeight(17)
			footerTexture:SetColorTexture(0.1, 0.1, 0.1, 0.985)

			--create a 'footer font string' which is attached to the left of the footer texture, it has silver color, size 10, text: "By Terciob"
			local footerText = showOnlyCooldownsButton.widget:CreateFontString(nil, "overlay", "GameFontNormal")
			footerText:SetPoint("left", footerTexture, "left", 2, -1)
			detailsFramework:SetFontColor(footerText, "silver")
			footerText:SetAlpha(0.6)
			footerText:SetText("An addon by Terciob")
			detailsFramework:SetFontSize(footerText, 12)

			--Play log
			--the idea of a play log is to show a timeline of spell casts in the screen, hence the player can follow the timeline casting the same spells as the timeline
			--this logFrame will have frames called 'lanes' where each lane represents a spell in the timeline. the lane will "slide" to the left as the time goes by.
			--create a frame in the uiparent to show the log
			local playFrame = CreateFrame("frame", "DetailsCastLogPlayFrame", UIParent, "BackdropTemplate")
			playFrame:SetSize(400, 200)
			playFrame:SetPoint("center", UIParent, "center", 400, 0)
			playFrame:EnableMouse(true)
			playFrame:Hide()

			detailsFramework:ApplyStandardBackdrop(playFrame)

			local LibWindow = LibStub("LibWindow-1.1")
			LibWindow.RegisterConfig(playFrame, castLog.db.frame_pos)
			LibWindow.MakeDraggable(playFrame)
			LibWindow.RestorePosition(playFrame)

			--create a button to close the playFrame, this button has 100x20 size and is located at the outside top right corner of the playFrame
			local closePlayFrameButton = detailsFramework:CreateButton(playFrame, function() playFrame:Hide() end, 70, 20, "Close", nil, nil, nil, "closePlayFrameButton", "$parentCloseButton", nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			closePlayFrameButton:SetPoint("bottomright", playFrame, "topright", 0, 0)
			closePlayFrameButton:SetIcon([[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 24, 24)

			--create a reset button with the same size and position as the close button, it is anchored to the left of the close button, when clicked it will reset the playFrame and start the timeline again
			local resetPlayFrameButton = detailsFramework:CreateButton(playFrame, function() castLog.PlayTimeline() end, 70, 20, "Reset", nil, nil, nil, "resetPlayFrameButton", "$parentResetButton", nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			resetPlayFrameButton:SetPoint("right", closePlayFrameButton, "left", -2, 0)
			resetPlayFrameButton:SetIcon([[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 24, 24)

			local amountOfLanes = 20
			local laneHeight = 20
			playFrame.Lanes = {}
			playFrame.bIsPlaying = false

			--create lines to be used as labes
			for i = 1, amountOfLanes do
				local lane = CreateFrame("frame", "$parentLane" .. i, playFrame, "BackdropTemplate")
				lane:SetHeight(laneHeight)
				lane:SetPoint("topleft", playFrame, "topleft", 0, (-i + 1) * 20)
				lane:SetPoint("topright", playFrame, "topright", 0, (-i + 1) * 20)

				detailsFramework:ApplyStandardBackdrop(lane, false, 0.5)

				if (i % 2 == 0) then
					lane:SetBackdropColor(0, 0, 0, 0.1)
				else
					lane:SetBackdropColor(0, 0, 0, 0.2)
				end

				function lane.CreateIcon()
					local icon = lane:CreateTexture(nil, "overlay")
					icon:SetSize(laneHeight-2, laneHeight-2)
					icon:SetTexCoord(.1, .9, .1, .9)

					local onShowAnimation = detailsFramework:CreateAnimationHub(icon)
					onShowAnimation:SetToFinalAlpha(true)
					local onShow1 = detailsFramework:CreateAnimation(onShowAnimation, "Alpha", 1, 4, 0, 1)
					icon.onShowAnimation = onShowAnimation

					local onHideAnimation = detailsFramework:CreateAnimationHub(icon, nil, function() icon:Hide() icon:SetAlpha(1) end)
					local onHideAlpha1 = detailsFramework:CreateAnimation(onHideAnimation, "Alpha", 1, 0.5, 1, 0)
					local onHideScale1 = detailsFramework:CreateAnimation(onHideAnimation, "Scale", 1, 0.5, 1, 1, 1.5, 1.5)
					icon.onHideAnimation = onHideAnimation

					return icon
				end

				lane.IconPool = detailsFramework:CreatePool(lane.CreateIcon, lane)
				lane.IconPool.onReset = function(icon)
					icon:Hide()
					icon.bIgnore = nil
				end

				playFrame.Lanes[i] = lane
			end

			function castLog.PlayTimeline()
				local data = playFrame.data

				if (not data) then
					castLog:Msg("No data available.")
					return
				end

				local lines = data.lines --data.lines is an indexed table with the spell data, each index has a subtable with the spell timeline data
				local lineAmount = lines and #lines or 0

				if (lineAmount == 0) then
					castLog:Msg("lineAmount is zero")
					return
				end

				--reset and hide all lanes
				for i = 1, amountOfLanes do
					local lane = playFrame.Lanes[i]
					if (lane) then
						lane:SetScript("OnUpdate", nil)
						lane.IconPool:ReleaseAll()
						lane:Hide()
					end
				end

				playFrame.amountOfLanes = 0
				playFrame.lanesFinished = 0

				--spell cast means when the spell was used
				--timeInSeconds is the time when the spell was used

				for i = 1, lineAmount do
					local lane = playFrame.Lanes[i]
					if (lane) then
						local thisData = lines[i]
						if (thisData) then
							---timeline table is an indexed table with sub tables with the timeInSeconds when the spell was casted in the first index of the subtable
							---example: { {timeInSeconds, 10}, {timeInSeconds, 10}, {timeInSeconds, 10}, {timeInSeconds, 10}, {timeInSeconds, 10} }
							---@type table<number, number[]>
							local timeline = thisData.timeline

							--a table that store timeInSeconds when each spell was casted
							---@class timeinsecondstable : table
							---@field when number when the spell was used
							---@field icon texture? if texture is not nil, it means the icon is already in the lane

							---@type timeinsecondstable[]
							local timeInSecondsTable = {}
							for o = 1, #timeline do
								local blockData = timeline[o]
								local timeInSeconds = blockData[1]
								timeInSecondsTable[#timeInSecondsTable+1] = {when = timeInSeconds + 5}
							end

							---@type number
							local spellId = thisData.spellId
							---@type number
							local icon = thisData.icon
							--the totalTimeLength is the total amount of seconds the timeline will play
							---@type number
							local totalTimeLength = data.length

							lane.timeline = timeInSecondsTable
							lane.totalEvents = #timeInSecondsTable
							lane.eventsFinished = 0
							lane.spellId = spellId
							lane.icon = icon
							lane.totalTimeLength = totalTimeLength
							lane.elapsedTime = 0

							--the lane will slide to the left as the time goes by, the speed is the amount of pixels the lane will move per second
							local timeDilatation = 1.0
							--timeWindow is the amount of seconds that a spell will be sliding in the lane
							--example: a spell was a timeInSeconds of 61, when the elapsed reaches 61 seconds the lane get an icon from lane.IconPool and the icon will slide to the left for timeWindow seconds
							local timeWindow = 20 * timeDilatation

							local laneWidth = playFrame:GetWidth()
							local pixelPerSecond = laneWidth / timeWindow

							lane:Show()
							playFrame.amountOfLanes = playFrame.amountOfLanes + 1

							playFrame:SetHeight(playFrame.amountOfLanes * laneHeight + 1)

							lane:SetScript("OnUpdate", function(self, deltaTime)
								local lane = self
								lane.elapsedTime = lane.elapsedTime + deltaTime

								--check if there is a timeInSeconds in the lane.timeline that is within the time window of (lane.elapsedTime > timeInSeconds - timeWindow)
								--if there is, check if the icon is already in the lane, if not, get an icon from the lane.IconPool and set the icon to the lane
								for o = 1, #lane.timeline do
									local thiTtimeInSecondsTable = lane.timeline[o]
									local timeInSeconds = thiTtimeInSecondsTable.when
									local timeInSecondsIcon = thiTtimeInSecondsTable.icon
									local thisIcon = timeInSecondsIcon

									if (lane.elapsedTime > timeInSeconds - timeWindow) then
										--this timeInSeconds is within the time window, need to check if an icon for this timeInSeconds is already in the lane
										if (not thisIcon) then
											local newIcon = lane.IconPool:Acquire()
											thiTtimeInSecondsTable.icon = newIcon
											newIcon:SetTexture(lane.icon)
											newIcon:ClearAllPoints()
											newIcon:Show()

											--at the first Update, all casts with less than timeWindow seconds will be shown at the same time at start
											--need to compensate the startTime to show the icon at the right time
											newIcon.elapsedTime = 0
											local currentPosition = 0

											if (timeInSeconds < timeWindow) then
												currentPosition = pixelPerSecond * timeInSeconds
											else
												currentPosition = laneWidth
												newIcon.onShowAnimation:Play()
											end

											newIcon.currentPosition = currentPosition

										elseif (thisIcon:IsShown() and not thisIcon.bIgnore) then
											thisIcon.elapsedTime = thisIcon.elapsedTime + deltaTime
											local pixelsToMove = pixelPerSecond * deltaTime
											thisIcon.currentPosition = thisIcon.currentPosition - pixelsToMove
											thisIcon:SetPoint("left", lane, "left", math.max(0, thisIcon.currentPosition), 0)

											--if this icon passed the timeWindow, release the icon
											if (thisIcon.currentPosition < 0) then
												thisIcon.onHideAnimation:Play()
												thisIcon.bIgnore = true
												--thisIcon:Hide()
												--lane.IconPool:Release(thisIcon)
												--thiTtimeInSecondsTable.icon = nil
												lane.eventsFinished = lane.eventsFinished + 1

												if (lane.eventsFinished == lane.totalEvents) then
													lane:SetScript("OnUpdate", nil)
													playFrame.lanesFinished = playFrame.lanesFinished + 1
													if (playFrame.lanesFinished == playFrame.amountOfLanes) then
														playFrame.playButton:Show()
													end
												end
											end
										end
									end
								end
							end)
						end
					end
				end
			end

			--create a button in the center of the frame which will play the timeline
			local playButton = detailsFramework:CreateButton(playFrame, function()
				playFrame.bIsPlaying = true
				castLog.PlayTimeline()
				playFrame.playButton:Hide()
			end, 128, 128, "", nil, nil, nil, "playButton", "$parentPlayButton")
			playButton:SetPoint("center", playFrame, "center", 0, 0)
			playFrame.playButton = playButton

			local playButtonPlayTexture = playButton:CreateTexture(nil, "overlay")
			playButtonPlayTexture:SetTexture([[Interface\AddOns\Details\images\icons2.png]])
			playButtonPlayTexture:SetSize(24*2, 33*2)
			playButtonPlayTexture:SetPoint("center", playButton.widget, "center", 0, 0)
			playButtonPlayTexture:SetTexCoord(128/512, 175/512, 288/512, 354/512)
			playButtonPlayTexture:SetVertexColor(1, 0.85, 0, 1)

			local playButtonCircleTexture = playButton:CreateTexture(nil, "artwork")
			playButtonCircleTexture:SetTexture([[Interface\CHARACTERFRAME\TempPortraitAlphaMask]])
			playButtonCircleTexture:SetSize(128, 128)
			playButtonCircleTexture:SetPoint("center", playButton.widget, "center", 0, 0)
			playButtonCircleTexture:SetVertexColor(.2, .2, .2, 0.923)

			playButton:SetHook("OnMouseDown", function()
				playButtonPlayTexture:SetPoint("center", playButton.widget, "center", 2, -2)
				playButtonCircleTexture:SetPoint("center", playButton.widget, "center", 2, -2)
			end)

			playButton:SetHook("OnMouseUp", function()
				playButtonPlayTexture:SetPoint("center", playButton.widget, "center", 0, 0)
				playButtonCircleTexture:SetPoint("center", playButton.widget, "center", 0, 0)
			end)

			function castLog.PrepareToPlay(data)
				playFrame.bIsPlaying = false
				playFrame.data = data
				playFrame:Show() --show the playframe with the play button
				playFrame.playButton:Show()
				Details:CloseBreakdownWindow()
			end

			playFrame:SetScript("OnHide", function()
				--reset and hide all lanes
				for i = 1, amountOfLanes do
					local lane = playFrame.Lanes[i]
					if (lane) then
						lane:SetScript("OnUpdate", nil)
						lane.IconPool:ReleaseAll()
						lane:Hide()
					end
				end
			end)

			local showPlayFrameButton = detailsFramework:CreateButton(frame, function() castLog.PrepareToPlay(castLog.currentData) end, buttonWidth, 20, "Play", nil, nil, nil, "loadImportedDataButton", nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			showPlayFrameButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 14, 14, "overlay", {96/512, 120/512, 299/512, 332/512}, {1, 0.85, 0, 1})
			showPlayFrameButton:SetPoint("left", loadImportedDataButton, "right", 2, 0)
		end

		local iconSettings = {
			texture = [[Interface\BUTTONS\UI-GuildButton-OfficerNote-Disabled]],
			coords = {0, 1, 0, 1},
			width = 16,
			height = 16,
		}

		Details:CreatePlayerDetailsTab(tabName, tabNameLoc, canShowTab, fillTab, nil, onCreatedTab, iconSettings)
	end

	--runs on each member in the group
	function castLog.BuildPlayerList(unitId, combatCastLogData)
		local GUID = UnitGUID(unitId)
		combatCastLogData.spells_cast_timeline[GUID] = {}
		combatCastLogData.aura_timeline[GUID] = {}
	end

	--runs on each member in the group
	--these are stored spells when out of combat to show pre-casts before a pull
	function castLog.CacheTransfer(unitId, combatCastLogData)
		local GUID = UnitGUID(unitId)
		local playerPreCastCache = preCastCache[GUID]
		local combatCastTable = combatCastLogData.spells_cast_timeline[GUID]

		if (playerPreCastCache and combatCastTable) then
			for i = #playerPreCastCache, 1, -1 do
				local thisPreCastEvent = playerPreCastCache[i]
				local spellCastedAt = thisPreCastEvent[1]
				local spellId = thisPreCastEvent[2]
				local targetName = thisPreCastEvent[3]

				if (spellCastedAt + 5 > GetTime()) then
					table.insert(combatCastTable, 1, thisPreCastEvent)
				end
			end

			table.wipe(playerPreCastCache)
		end

		--

		local cachedAuraTable = auraCache[GUID]
		local combatAuraTable = combatCastLogData.aura_timeline[GUID]

		if (cachedAuraTable and combatAuraTable) then
			for spellId, appliedAt in pairs(cachedAuraTable) do
				--check if the aura is still up
				local auraUp
				for i = 1, 40 do
					---@type aurainfo
					local auraInfo = C_UnitAuras.GetBuffDataByIndex(unitId, i)
					local name, auraSpellId = auraInfo.name, auraInfo.spellId

					if (not name) then
						break
					elseif (spellId == auraSpellId) then
						auraUp = true
						break
					end
				end

				if (auraUp) then
					combatAuraTable[spellId] = {
						enabled = true,
						appliedAt = appliedAt,
						data = {},
						spellId = spellId,
						auraType = "BUFF",
					}
				end
			end

			table.wipe(cachedAuraTable)
		end
	end

	function castLog.OnCombatStart(combatObject)
		--start
		castLog.inCombat = true
		castLog.currentCombat =  combatObject
		local uniqueCombatId = combatObject:GetCombatUID()
		castLog.currentCombatUniqueId = uniqueCombatId

		--this table will preplace the combatObject.spells_cast_timeline and combatObject.aura_timeline
		--doing this way the data won't be saved in the combatObject, but in the savedVariables for the castlog plugin
		local combatCastLogData = {
			combatId = castLog.currentCombatUniqueId, --unique identifier for the combat
			spells_cast_timeline = {},
			aura_timeline = {},
		}

		castLog.combatCastLogData = combatCastLogData
		castLog.db.castlog_data[uniqueCombatId] = combatCastLogData

		--built the table
		detailsFramework:GroupIterator(castLog.BuildPlayerList, combatCastLogData)
		--precasts
		detailsFramework:GroupIterator(castLog.CacheTransfer, combatCastLogData)
		--wipe sent cache
		wipe(castLog.sentSpellCache)

		castLog.UpdateSpellCache()
		--castLog.combatLogReader:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		castLog.UpdateSpellCache()
	end

	function castLog.OnCombatEnd(combatObject)
		castLog.inCombat = false
		---@cast combatObject combat

		--close aura timers
		if (castLog.currentCombat ~= combatObject) then
			return
		end

		if (combatObject) then
			local uniqueCombatId = combatObject:GetCombatUID()
			local currentCastLogData = castLog.combatCastLogData

			if (currentCastLogData and uniqueCombatId and uniqueCombatId == currentCastLogData.combatId) then
				local combatTime = combatObject:GetCombatTime() --seconds elapsed
				local combatStartTime = combatObject:GetStartTime() --gettime

				currentCastLogData.combatTime = combatTime
				currentCastLogData.combatStartTime = combatStartTime
				currentCastLogData.aura_timeline = currentCastLogData.aura_timeline or {}

				for GUID, playerAuraTable in pairs(currentCastLogData.aura_timeline) do
					for spellId, auraTable in pairs(playerAuraTable) do
						if (auraTable.enabled) then
							auraTable.enabled = false
							auraTable.amountUp = 0
							tinsert(auraTable.data, {auraTable.appliedAt, GetTime()}) --when it was applied and when it went off
						end
					end
				end
			end

			castLog.currentCombat = nil
		end

		wipe(castLog.sentSpellCache)
		--castLog.combatLogReader:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		castLog.UpdateSpellCache()
	end

	local isUnitInTheGroup = function(unitId)
		if (unitId) then
			if (UnitInRaid(unitId)) then
				return true

			elseif (UnitInParty(unitId)) then
				return true

			elseif (UnitIsUnit(unitId, "player")) then
				return true
			end
		end
	end

	function castLog:OnEvent(self, event, ...)
		if (event == "ADDON_LOADED") then
			local addonName = select(1, ...)
			if (addonName == "Details_CastLog") then
				CastLogDB = CastLogDB or {}
				CastLogDB = CastLogDB

				--every plugin must have a OnDetailsEvent function
				function castLog:OnDetailsEvent(event, ...)
					return onDetailsEvent(event, ...)
				end

				local default_options = {
					imported_cast_logs = {},
					---@type table<number, table> the number if the combat unique id, the table is the castlog data
					castlog_data = {},

					ignored_spells = {
						["DEMONHUNTER"] = {
						},
						["HUNTER"] = {
						},
						["WARRIOR"] = {
						},
						["ROGUE"] = {
						},
						["MAGE"] = {
							[382445] = true, --Shifting Power tick
						},
						["DRUID"] = {
						},
						["MONK"] = {
						},
						["DEATHKNIGHT"] = {
						},
						["PRIEST"] = {
						},
						["WARLOCK"] = {
						},
						["PALADIN"] = {
						},
						["SHAMAN"] = {
						},
						["EVOKER"] = {
						},
						["ALL"] = {
							[324748] = true, --celestial guidance (enchant)
							[196711] = true, --remorseless winter
							[75] = true, --auto shot
							[201428] = true, --annihilation
							[227518] = true, --annihilation
							[272790] = true, --Frenzy
							[228597] = true, --frostbolt
							[147193] = true, --shadowy apparition
							[341263] = true, --shadowy apparition
						},
					},

					merged_spells = {
						["DEMONHUNTER"] = {
							[222031] = 199547, --chaos strike
							[201453] = 191427, --metamorphosis
							[213243] = 213241, --felblade
							[232893] = 213241, --felblade
						},
						["HUNTER"] = {
							[308495] = 308491, --resonating arrow
							[308498] = 308491, --resonating arrow
						},
						["WARRIOR"] = {
							[184367] = 201363, --rampage
							[184709] = 201363,
							[199667] = 44949, --whirlwind
							[190411] = 44949,
							[85739] = 44949,
							[317488] = 317485, --condemn
							[126664] = 100, --charge
							[227847] = 50622, --bladestorm
							[147833] = 3411, --intervene
							[316531] = 3411, --intervene
							[52174] = 6544, --heroic leap
						},
						["ROGUE"] = {
							[199672] = 1943, --rupture
							[185313] = 185422, --shadow dance
						},
						["MAGE"] = {
							[7268] = 5143, --arcane missiles
						},
						["DRUID"] = {

						},
						["MONK"] = {
							[148187] = 116847, --rushing jade wing
							[124503] = 124506, --gift of the ox
						},
						["DEATHKNIGHT"] = {

						},
						["PRIEST"] = {
							[33076] = 41635, --prayer of mending
						},
						["WARLOCK"] = {
							[146739] = 172, --corruption
						},
						["PALADIN"] = {

						},
						["SHAMAN"] = {

						},

						["EVOKER"] = {

						},
					},

					user_blacklisted_spells = {},

					only_cooldowns = false,
					only_auras = false,
					only_players_attack_cooldowns = false,
					only_players_defensive_cooldowns = false,

					frame_pos = {scale = 1},
				}

				detailsFramework.table.deploy(CastLogDB, default_options)

				--install: install -> if successful installed; saveddata -> a table saved inside details db, used to save small amount of data like configs
				local install, saveddata = Details:InstallPlugin("RAID",
				"Cast Log",
				"Interface\\Icons\\Ability_Warrior_BattleShout",
				castLog,
				"DETAILS_PLUGIN_CAST_LOG",
				MINIMAL_DETAILS_VERSION_REQUIRED,
				"Terciob",
				CASTLOG_VERSION)

				if (type(install) == "table" and install.error) then
					print(install.error)
				end

				castLog.db = CastLogDB

				--registering details events we need
				Details:RegisterEvent(castLog, "COMBAT_PLAYER_ENTER") --when details creates a new segment, not necessary the player entering in combat.
				Details:RegisterEvent(castLog, "COMBAT_PLAYER_LEAVE") --when details finishs a segment, not necessary the player leaving the combat.
				Details:RegisterEvent(castLog, "DETAILS_DATA_RESET") --details combat data has been wiped

				castLog.sentSpellCache = {}
				castLog.InstallTab()

				--this plugin does not show in lists of plugins
				castLog.NoMenu = true

				--maintenance
				for uniqueCombatId in pairs(castLog.db.castlog_data) do
					local combatObject = Details:GetCombatByUID(uniqueCombatId)
					if (not combatObject) then
						--combat doesn't exists anymore, drop the combat data
						castLog.db.castlog_data[uniqueCombatId] = nil
					end
				end

				function castLog.GetDataByCombatId(combatId)
					return castLog.db.castlog_data[combatId]
				end

				CastLog = castLog --debug, place it in the global namespace
				-- /dump CastLog.db.castlog_data

				--combatlog parser
				local combatLogReader = CreateFrame("frame")
				combatLogReader:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
				castLog.combatLogReader = combatLogReader

				--cache
				local ignoredSpellsClass -- = {}
				local ignoredSpellsAll -- = {}
				local mergedSpells -- = {}

				function castLog.UpdateSpellCache()
					local _, playerClass = UnitClass("player")
					castLog.currentPlayerClass = playerClass
					ignoredSpellsClass = castLog.db.ignored_spells[playerClass]
					ignoredSpellsAll = castLog.db.ignored_spells.ALL
					mergedSpells = castLog.db.merged_spells
				end

				castLog.UpdateSpellCache()

				---@class caststartdata : table
				---@field time number
				---@field spellId number
				
				---@type table<guid, caststartdata>
				local playerCurrentCastingCache = {}

				local eventFunc = {
					["SPELL_AURA_APPLIED"] = function(timew, token, hidding, sourceSerial, sourceName, sourceFlag, sourceFlag2, targetSerial, targetName, targetFlag, targetFlag2, spellId, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
						local GUID = sourceSerial
						if (castLog.inCombat) then
							local playerAuraTable = castLog.combatCastLogData.aura_timeline[GUID]
							if (playerAuraTable) then

								--check the options for ignored or marged spells
								if (ignoredSpellsClass[spellId]) then
									return
								elseif (ignoredSpellsAll[spellId]) then
									return
								end
								spellId = mergedSpells[spellId] or spellId

								local auraTable = playerAuraTable[spellId]
								if (not auraTable) then
									playerAuraTable [spellId] = {
										enabled = true,
										amountUp = 1,
										appliedAt = GetTime(),
										data = {},
										spellId = spellId,
										--auraType = "BUFF",
									}
									auraTable = playerAuraTable [spellId]
								else
									if (not auraTable.enabled) then
										auraTable.enabled = true
										auraTable.amountUp = 1
										auraTable.appliedAt = GetTime()
									else
										auraTable.amountUp = auraTable.amountUp + 1
									end
								end
							end
						else
							--not in combat
						end
					end,

					["SPELL_AURA_REMOVED"] = function(timew, token, hidding, sourceSerial, sourceName, sourceFlag, sourceFlag2, targetSerial, targetName, targetFlag, targetFlag2, spellId, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
						local GUID = sourceSerial
						if (castLog.inCombat) then
							local playerAuraTable = castLog.combatCastLogData.aura_timeline and castLog.combatCastLogData.aura_timeline[GUID]
							if (playerAuraTable) then

								--check the options for ignored or marged spells
								if (ignoredSpellsClass[spellId]) then
									return
								elseif (ignoredSpellsAll[spellId]) then
									return
								end
								spellId = mergedSpells[spellId] or spellId

								local auraTable = playerAuraTable[spellId]
								if (auraTable) then
									if (auraTable.enabled) then
										auraTable.amountUp = auraTable.amountUp - 1
										if (auraTable.amountUp <= 0) then
											auraTable.enabled = false
											tinsert(auraTable.data, {auraTable.appliedAt, GetTime()}) --when it was applied and when it went off
										end
									end
								end
							end
						end
					end,

					["SPELL_CAST_START"] = function(timew, token, hidding, sourceSerial, sourceName, sourceFlag, sourceFlag2, targetSerial, targetName, targetFlag, targetFlag2, spellId, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
						playerCurrentCastingCache[sourceSerial] = {time = GetTime(), spellId = spellId}

					end,

					["SPELL_CAST_SUCCESS"] = function(timew, token, hidding, sourceSerial, sourceName, sourceFlag, sourceFlag2, targetSerial, targetName, targetFlag, targetFlag2, spellId, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
						--local unitId, castGUID, spellId = ...
						--local castSent = castLog.sentSpellCache[castGUID]
						--if (not castSent) then
							--return --if ending here, it won't register for other players since self doesn't receive spell cast sent
						--end
						--castLog.sentSpellCache[castGUID] = nil

						local target = targetName
						local caster = sourceName
						--local spellId = spellId

						local isUnitInGroup = isUnitInTheGroup(sourceName)

						if (caster and spellId and isUnitInGroup) then --need to check if this is passing
							local GUID = sourceSerial
							if (GUID) then
								--check the options for ignored or marged spells
								if (ignoredSpellsClass[spellId]) then
									return
								elseif (ignoredSpellsAll[spellId]) then
									return
								end

								spellId = mergedSpells[spellId] or spellId

								if (castLog.inCombat) then
									local playerCastTable = castLog.combatCastLogData.spells_cast_timeline[GUID]
									if (playerCastTable) then
										local currentCasting = playerCurrentCastingCache[GUID]
										if (currentCasting and currentCasting.spellId == spellId) then
											playerCurrentCastingCache[GUID] = nil
											tinsert(playerCastTable, {currentCasting.time, spellId, target})
										else
											tinsert(playerCastTable, {GetTime(), spellId, target})
										end
									end
								else
									local playerPreCastCache = preCastCache[GUID]

									if (not playerPreCastCache) then
										preCastCache[GUID] = {}
										playerPreCastCache = preCastCache[GUID]
									else
										table.remove(playerPreCastCache, 3)
									end

									---@type spellinfo
									local spellInfo = C_Spell.GetSpellInfo(spellId)
									local castTime = spellInfo.castTime or 0.00001
									castTime = castTime / 1000

									local castStartedAt = GetTime() - castTime
									table.insert(playerPreCastCache, 1, {castStartedAt, spellId, target})
								end
							end
						end
					end,
				}

				local unitCache = {}
				local bitBand = bit.band
				local OBJECT_TYPE_PLAYER =	0x00000400
				local Ambiguate = Ambiguate

				combatLogReader:SetScript("OnEvent", function(self)
					local timew, token, hidding, sourceSerial, sourceName, sourceFlags, sourceFlag2, targetSerial, targetName, targetFlags, targetFlag2, spellId, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()

					if (sourceName) then
						if (unitCache[sourceName]) then
							sourceName = unitCache[sourceName]
						else
							--detect if this is player by reading the flags
							if (bitBand(sourceFlags, OBJECT_TYPE_PLAYER) ~= 0) then
								sourceName = Ambiguate(sourceName, "none")
								unitCache[sourceName] = sourceName
							else
								unitCache[sourceName] = sourceName
							end
						end
					end

					if (targetName) then
						if (unitCache[targetName]) then
							targetName = unitCache[targetName]
						else
							--detect if this is player by reading the flags
							if (bitBand(targetFlags, OBJECT_TYPE_PLAYER) ~= 0) then
								targetName = Ambiguate(targetName, "none")
								unitCache[targetName] = targetName
							else
								unitCache[targetName] = targetName
							end
						end
					end

					local func = eventFunc[token]
					if (func) then
						--check if the event is from the player or from the group
						if (sourceName and spellId and isUnitInTheGroup(sourceName)) then --need to check this point if it is passing if others
							func(timew, token, hidding, sourceSerial, sourceName, sourceFlags, sourceFlag2, targetSerial, targetName, targetFlags, targetFlag2, spellId, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
						end
					end
				end)
			end
		end
	end
end
