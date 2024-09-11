--F
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local _

local Loc = LibStub("AceLocale-3.0"):GetLocale("Details_DeathGraphs")
local adlObject = Details:NewPluginObject("Details_DeathGraphs", DETAILSPLUGIN_ALWAYSENABLED)
table.insert(UISpecialFrames, "Details_DeathGraphs")
adlObject.version_string = "v3.8"

advancedDeathLogs.PluginAbsoluteName = "DETAILS_PLUGIN_DEATH_GRAPHICS"

local GetSpellDescription = C_Spell and C_Spell.GetSpellDescription or GetSpellDescription

---@alias ehash string

local GetNumGroupMembers = GetNumGroupMembers
local UnitName = UnitName
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local unpack = unpack
local GameCooltip = GameCooltip
local GetTime = GetTime
local C_Timer = C_Timer
local time = time
local GetUnitName = GetUnitName
local bitBand = bit.band

--main frame
local mainFrame = adlObject.Frame
detailsFramework:ApplyStandardBackdrop(mainFrame)
advancedDeathLogs.mainFrame = mainFrame
advancedDeathLogs.pluginObject = adlObject
advancedDeathLogs.tabFrameY = -25 --where the tab frames should be placed
advancedDeathLogs.dropdownWidth = 175 --width of the dropdowns
advancedDeathLogs.dropdownIconSize = {32, 20} --width of the dropdowns
advancedDeathLogs.dropdownIconCoords = {0, 1, 0, 0.9}
advancedDeathLogs.tutorialTextSize = 10
advancedDeathLogs.tutorialWidgetsAlpha = 0.6
advancedDeathLogs.defaultTextSize = 11

local wipe = table.wipe

local CONST_DBTYPE_ENDURANCE = "endurance"

advancedDeathLogs.debugMode = false
advancedDeathLogs.debugEncounter = false

local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo

if (detailsFramework.IsWarWow()) then
    GetSpellInfo = function(...)
        local result = C_Spell.GetSpellInfo(...)
        if result then
            return result.name, 1, result.iconID
        end
    end
end

adlObject:SetPluginDescription(Loc["STRING_PLUGIN_DESC"])

local cleuEventFrame = CreateFrame("frame")

local createPluginFunctions = function()
	function adlObject:DebugMsg(msg, sec, ...)
		if (advancedDeathLogs.debugMode) then
			adlObject:Msg(msg, sec, ...)
		end
	end

	function adlObject.RefreshWindow()
		if (not adlObject.frames_built) then
			adlObject.DeathGraphsWindowBuilder(adlObject)
			adlObject.DeathGraphsWindowBuilder = nil
			adlObject.frames_built = true

			---@type combat
			local currentCombat = adlObject:GetCurrentCombat()
			if (currentCombat and currentCombat.is_boss and currentCombat.is_boss.diff and currentCombat.is_boss.id) then
				adlObject.db.last_boss = adlObject.last_encounter_hash or ("" .. currentCombat.is_boss.id .. currentCombat.is_boss.diff)
			end

			adlObject.db.showing_type = 3
		end

		adlObject:Refresh()
	end

	function adlObject:OpenWindow()
		if (not adlObject.frames_built) then
			adlObject.DeathGraphsWindowBuilder(adlObject)
			adlObject.DeathGraphsWindowBuilder = nil
			adlObject.frames_built = true

			---@type combat
			local currentCombat = adlObject:GetCurrentCombat()
			if (currentCombat and currentCombat.is_boss and currentCombat.is_boss.diff and currentCombat.is_boss.id) then
				adlObject.db.last_boss = adlObject.last_encounter_hash or ("" .. currentCombat.is_boss.id .. currentCombat.is_boss.diff)
			end

			adlObject.db.showing_type = 3
		end

		adlObject:Refresh()
		DetailsPluginContainerWindow.OpenPlugin(adlObject)
	end

	function adlObject:CloseWindow()
		mainFrame:Hide()
	end

	local onEnterIconCooltipMenu = function()
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

		--build the menu options
		--death log
		gameCooltip:AddLine("Advanced Death Log")
		gameCooltip:AddMenu(1, function()
			adlObject:OpenWindow()
			adlObject:HideAll()
			adlObject:ShowCurrent()
			adlObject:RefreshButtons()

			gameCooltip:Hide()
		end, "main")
		gameCooltip:AddIcon([[Interface\WORLDSTATEFRAME\SkullBones]], 1, 1, 16, 16, 4/64, 28/64, 4/64, 28/64, "orange")

		--enemy spell timeline
		gameCooltip:AddLine("Boss Ability Timeline")
		gameCooltip:AddMenu(1, function()
			adlObject:OpenWindow()
			adlObject:HideAll()
			adlObject:ShowTimeline()
			adlObject:RefreshButtons()

			gameCooltip:Hide()
		end, "main")
		gameCooltip:AddIcon([[Interface\Transmogrify\transmog-tooltip-arrow]], 1, 1, 16, 14, 0, 1, 0, 1, "orange")

		--player endurance
		gameCooltip:AddLine("Player Endurance")
		gameCooltip:AddMenu(1, function()
			adlObject:OpenWindow()
			adlObject:HideAll()
			adlObject:ShowEndurance()
			adlObject:RefreshButtons()

			gameCooltip:Hide()
		end, "main")
		gameCooltip:AddIcon([[Interface\RAIDFRAME\Raid-Icon-Rez]], 1, 1, 16, 16, 0.03, 0.97, 0, 1, "orange")

		--apply the backdrop settings to the menu
		Details:FormatCooltipBackdrop()
		gameCooltip:SetOwner(adlObject.ToolbarButton, "bottom", "top", 0, 0)
		gameCooltip:ShowCooltip()
	end

	adlObject.ToolbarButton = adlObject.ToolBar:NewPluginToolbarButton(adlObject.OpenWindow, "Interface\\AddOns\\Details_DeathGraphs\\icon", Loc["STRING_PLUGIN_NAME"], Loc["STRING_TOOLTIP"], 16, 16, "DEATHGRAPHICS_BUTTON", onEnterIconCooltipMenu)
	adlObject.ToolbarButton.shadow = true
	adlObject.GetSpellDescriptionFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")

	function adlObject:CanShowIcon()
		if (self.db.show_icon == 1) then
			local foundSomething = false

			if (not foundSomething) then
				for _, boss in pairs(adlObject.endurance_database) do
					if (boss) then
						foundSomething = true
						break
					end
				end
			end

			if (foundSomething) then
				adlObject:ShowToolbarIcon(adlObject.ToolbarButton, "star")
			else
				adlObject:HideToolbarIcon(adlObject.ToolbarButton)
			end
		end
	end

	function adlObject:HideIcon()
		adlObject:HideToolbarIcon(adlObject.ToolbarButton)
	end

	function adlObject:OnDetailsEvent(event, ...)
		if (event == "HIDE") then
			self.open = false

		elseif (event == "SHOW") then
			self.open = true

		elseif (event == "COMBAT_BOSS_FOUND") then

		elseif (event == "COMBAT_PLAYER_ENTER") then
			---@debug
			if (advancedDeathLogs.debugMode and advancedDeathLogs.debugEncounter) then
				adlObject.OnEncounterStart()
			end
			---@end-debug

		elseif (event == "COMBAT_PLAYER_LEAVE") then
			---@debug
			if (advancedDeathLogs.debugMode and advancedDeathLogs.debugEncounter) then
				adlObject.OnEncounterEnd()
			end
			---@end-debug

			adlObject:DebugMsg("combat finished -> calling CombatFinished()")
			adlObject:CombatFinished(...)
			cleuEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			---@type combat
			local combatObject = Details:GetCurrentCombat()
			if (combatObject) then
				local deathsTable = combatObject:GetDeaths()
				for i = 1, #deathsTable do
					local eventsBeforePlayerDeath = deathsTable[i][1]
					if (type(eventsBeforePlayerDeath) == "table") then
						for j = 1, #eventsBeforePlayerDeath do
							local eventTable = eventsBeforePlayerDeath[j]
							if (type(eventTable) == "table") then
								if (eventTable[1] == true) then --is damage
									local spellId = eventTable[2]
									if (spellId and GetSpellInfo(spellId)) then
										local desc = GetSpellDescription(spellId)
									end
								end
							end
						end
					end
				end
			end

		elseif (event == "PLUGIN_DISABLED") then
			adlObject:HideIcon()

		elseif (event == "PLUGIN_ENABLED") then
			adlObject:CanShowIcon()

			--when details finish his startup and are ready to work
		elseif (event == "DETAILS_STARTED") then
			adlObject:CanShowIcon()

			C_Timer.After(1, function()
				--Details.BreakdownWindowFrame:Show()
				--Details.BreakdownWindowFrame.ShowPluginOnBreakdown(adlObject, advancedDeathLogs.mainFrame.timelineButtonBreakdown)
			end)

		elseif (event == "DETAILS_INSTANCE_CHANGEATTRIBUTE") then
			local instanceObject, displayId, subDisplayId = ...
			if (displayId == 4 and subDisplayId == 5) then
				--user selected to show death log
				local combatObject = instanceObject:GetCombat()
				--get the table where all deaths are stored
				for deathIdx, deathTable in ipairs(combatObject:GetDeaths()) do
					local playerName, playerClass, deathUnixTime, deathCombatTime, deathStringTime, playerMaxHealth, deathEvents, lastCooldown = Details:UnpackDeathTable(deathTable)
					for i = 1, #deathEvents do
						local eventTable = deathEvents[i]
						if (eventTable[1] == true) then
							local spellId = eventTable[2]
							if (spellId and GetSpellInfo(spellId)) then
								--load the spell description, as the client async load them
								adlObject.GetSpellDescriptionFontString:SetText(GetSpellDescription(spellId))
							end
						end
					end
				end
			end
		end
	end
end

local debugModeEncounterData = detailsFramework.table.copy({}, advancedDeathLogs.testBossTable)

local encounterEventFrame = CreateFrame("frame")
encounterEventFrame:RegisterEvent("ENCOUNTER_END")
encounterEventFrame:RegisterEvent("ENCOUNTER_START")

function adlObject.OnEncounterStart(...)
	local encounterId, encounterName, difficultyId, raidSize = select(1, ...)

	if (advancedDeathLogs.debugMode and advancedDeathLogs.debugEncounter) then
		if (not encounterId) then
			--make data for testing
			encounterId = debugModeEncounterData.encounterId
			encounterName = debugModeEncounterData.encounterName
			difficultyId = debugModeEncounterData.difficultyId
			raidSize = debugModeEncounterData.raidSize
		end
	end

	adlObject.currentEncounterHash = encounterId .. "-" .. difficultyId

	adlObject.currentEncounterInfo = {
		encounterId = encounterId,
		encounterName = encounterName,
		difficultyId = difficultyId,
		raidSize = raidSize,
		hash = adlObject.currentEncounterHash,
	}

	adlObject.BossEncounterStartAt = GetTime()

	--store casts of enemy spells
	---@type {key1: combattime, key2: spellid, key3: spellname}
	adlObject.EnemySkillTable = {}

	--store when the last spell by the enemy was casted, this to prevent the same spell to be logged twice in the same second
	---@type table<spellid, combattime>
	adlObject.EnemySkillTableDelay = {}

	--store when the combat has started
	cleuEventFrame.combatStartTime = time()

	--start logging cleu events
	cleuEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function adlObject.OnEncounterEnd(...)
	local encounterId, encounterName, difficultyId, raidSize, endStatus = select(1, ...)

	if (advancedDeathLogs.debugMode and advancedDeathLogs.debugEncounter) then
		if (not encounterId) then
			--make data for testing
			encounterId = debugModeEncounterData.encounterId
			encounterName = debugModeEncounterData.encounterName
			difficultyId = debugModeEncounterData.difficultyId
			raidSize = debugModeEncounterData.raidSize
			endStatus = debugModeEncounterData.endStatus
		end
	end

	adlObject.currentEncounterInfo = {
		encounterId = encounterId,
		encounterName = encounterName,
		difficultyId = difficultyId,
		raidSize = raidSize,
		hash = adlObject.currentEncounterHash,
		killed = endStatus,
	}
end

encounterEventFrame:SetScript("OnEvent", function(self, event, ...)
	if (event == "ENCOUNTER_START") then
		adlObject.OnEncounterStart(...)

	elseif (event == "ENCOUNTER_END") then
		adlObject.OnEncounterEnd(...)
	end
end)

mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function adlObject:GetEncounterDiffString(diffInteger)
	if (diffInteger == 17) then
		return "Raid Finder"

	elseif (diffInteger == 16) then
		return "Mythic"

	elseif (diffInteger == 15) then
		return "Heroic"

	elseif (diffInteger == 14) then
		return "Normal"
	end
end

function adlObject:GetPlayerTable(bossTable, playerName)
	local playerTable = bossTable.player_db[playerName]
	if (playerTable) then
		return playerTable
	end

	if (bossTable.type == CONST_DBTYPE_ENDURANCE) then
		local _, class = UnitClass(playerName)
		local newPlayerTable = {
			points = 0,
			encounters = 0,
			deaths = {},
			class = class or "PRIEST"
		}

		bossTable.player_db[playerName] = newPlayerTable
		return newPlayerTable
	end
end

function adlObject:GetEnduranceDataForBossHash(bossHash)
	local dbTable = adlObject.endurance_database

	local bossTable = dbTable[bossHash]
	if (bossTable) then
		return bossTable
	end

	local newBossTable = {
		player_db = {},
		id = bossHash,
		name = adlObject.currentEncounterInfo.encounterName,
		diff = adlObject.currentEncounterInfo.difficultyId,
		hash = bossHash,
	}

	newBossTable.type = CONST_DBTYPE_ENDURANCE
	adlObject.endurance_database[bossHash] = newBossTable

	return newBossTable
end

function adlObject:GetDifficultyName(difficultyId)
	if (difficultyId == 14) then
		return "Normal"

	elseif (difficultyId == 15) then
		return "Heroic"

	elseif (difficultyId == 17) then
		return "Raid Finder"

	elseif (difficultyId == 16) then
		return "Mythic"
	end
end

function adlObject:CanRecordOnDifficulty(difficultyId)
	--normal mode
	if (difficultyId == 14) then
		if (not adlObject.db.captures[2]) then
			adlObject:DebugMsg("Normal mode isn't active, not recording this segment.")
			return
		end
		return true

	--heroic mode
	elseif (difficultyId == 15) then
		if (not adlObject.db.captures[3]) then
			adlObject:DebugMsg("Heroic mode isn't active, not recording this segment.")
			return
		end
		return true

	--raid finder
	elseif (difficultyId == 17) then
		if (not adlObject.db.captures[1]) then
			adlObject:DebugMsg("Raid Finder mode isn't active, not recording this segment.")
			return
		end
		return true

	--mythic
	elseif (difficultyId == 16) then
		if (not adlObject.db.captures[4]) then
			adlObject:DebugMsg("Mythic mode isn't active, not recording this segment.")
			return
		end
		return true
	else
		return
	end
end

function adlObject:GetBossInformation(encounterId)
	return advancedDeathLogs.dataBase.encounterInfo[encounterId]
end

function adlObject:CombatFinished(combatObject)
	--does the encounter fight saved a list of enemy skills used?
	if (not adlObject.EnemySkillTable) then
		adlObject:DebugMsg("nil value: DeathGraphs.EnemySkillTable")
		return
	end

	--get the difficulty
	local difficult = adlObject.currentEncounterInfo.difficultyId
	--does the user selected to record this difficulty?
	if (not adlObject:CanRecordOnDifficulty(difficult)) then
		adlObject:DebugMsg("Raid difficulty is too low, not recording this segment.")
		return
	end

	--read all deaths
	local bossInfoTable = combatObject:GetBossInfo() --return the is_boss table
	adlObject:DebugMsg("bossinfo: ", bossInfoTable and "exists" or "nil")

	---@debug this will add the bossinfo into the combatObject for tests purposes
		if (not bossInfoTable and advancedDeathLogs.debugMode) then
			bossInfoTable = {
				index = 1,
				name = debugModeEncounterData.encounterName,
				encounter = debugModeEncounterData.encounterName,
				zone = debugModeEncounterData.zoneName,
				mapid = debugModeEncounterData.zoneId,
				diff = debugModeEncounterData.difficultyId,
				diff_string = debugModeEncounterData.difficultyName,
				ej_instance_id = debugModeEncounterData.ejid,
				id = debugModeEncounterData.encounterId,
			}

			combatObject.is_boss = bossInfoTable
			combatObject:SetStartTime(time() - 180)
			combatObject:SetEndTime(time())

			adlObject.EnemySkillTable = detailsFramework.table.copy({}, advancedDeathLogs.testEnemySkillTable)
		end
	---@end-debug

	if (not bossInfoTable) then
		return
	end

	--get the table containing bosses information from the database
	--the information this table store is informed below where it creates a new table if it doesn't exist
	local encounterInfo = advancedDeathLogs.dataBase.encounterInfo[bossInfoTable.id]
	if (not encounterInfo) then
		--if the boss info for this encounter isn't yet recorded, then record it
		---@type adl_encounterinfo
		local newEncounterInfo = {
			bossIcon = Details:GetBossEncounterTexture(bossInfoTable.name or "Unknown Boss") or [[Interface\ICONS\INV_Misc_QuestionMark]],
			encounterName = bossInfoTable.name or "Unknown Boss",
			zoneName = bossInfoTable.zone or "",
			zoneId = bossInfoTable.mapid or 0,
			encounterId = bossInfoTable.id or 0,
		}
		advancedDeathLogs.dataBase.encounterInfo[bossInfoTable.id] = newEncounterInfo
	end

	if (bossInfoTable) then
		adlObject:DebugMsg("boss found", bossInfoTable.name)
		adlObject:DebugMsg("adlObject.last_encounter_hash:", adlObject.currentEncounterInfo.hash)
		adlObject.last_encounter_hash = adlObject.currentEncounterInfo.hash

		--iterate beetween deaths occured in latest encounter
		local deathList = combatObject:GetDeaths()
		if ((not deathList or not deathList[1]) and advancedDeathLogs.debugMode) then
			deathList = advancedDeathLogs.testDeathLogs
		end

		local enduranceTable = adlObject:GetEnduranceDataForBossHash(adlObject.currentEncounterInfo.hash)

		--register the latest time the endurance table was updated, use to check if the table is outdated and sort order
		enduranceTable.unixtime = time()

		---@type table<actorname, boolean> player names that failed the endurance check
		local enduranceFailed = {}

		adlObject:DebugMsg("deaths amount (#deathList): " .. #deathList)
		adlObject:DebugMsg("combat time: " .. combatObject:GetCombatTime())

		if (#deathList > 0) then
			--only record if the encounter had more than 40 seconds
			if (combatObject:GetCombatTime() > 40) then
				--create a table to store the deaths of this segment
				local deathsOccurredOnThisEncounter = {
					bossname = adlObject.currentEncounterInfo.encounterName,
					timeelapsed = combatObject:GetCombatTime(),
					bossicon = {0, 1, 0, 1, Details:GetBossEncounterTexture(adlObject.currentEncounterInfo.encounterName or "Unknown Boss")},
					date = combatObject:GetEndTime(),
					deaths = {} --store all deaths in this encounter
				}
				--add the table into the database, the member 'deaths' if filled below when iterating the deaths
				table.insert(advancedDeathLogs.dataBase.deathsPerSegment, 1, deathsOccurredOnThisEncounter)

				--check if there is too much segments
				if (#advancedDeathLogs.dataBase.deathsPerSegment > adlObject.db.max_segments_for_current) then
					table.remove(advancedDeathLogs.dataBase.deathsPerSegment)
				end

				--timeline stuff, spellcast - build the sub tables to store the deaths, spells and spellIds

				local encounterHash = adlObject.last_encounter_hash

				--store how many deaths occurred in the same second during all tries on the same encounter
				--example: [45] = {unixtime, unixtime, unixtime, unixtime}, [80] = {unixtime, unixtime, unixtime, unixtime}
				--the unixtime is in case need to clean up deaths after a while

				local deathsOnSeconds = advancedDeathLogs.dataBase.deathsOccurrences
				---@type table<number, unixtime[]>
				local encounterDeathsOnSeconds = deathsOnSeconds[encounterHash]
				if (not encounterDeathsOnSeconds) then
					encounterDeathsOnSeconds = {}
					deathsOnSeconds[encounterHash] = encounterDeathsOnSeconds
				end

				local enemySpellCasts = advancedDeathLogs.dataBase.enemySpellCasts
				local encounterSpellCasts = enemySpellCasts[encounterHash]
				if (not encounterSpellCasts) then
					encounterSpellCasts = {}
					enemySpellCasts[encounterHash] = encounterSpellCasts
				end

				local spellIdCache = advancedDeathLogs.dataBase.spellIdCache
				local timeNow = time()

				adlObject:DebugMsg("#adlObject.EnemySkillTable: " .. #adlObject.EnemySkillTable)

				---@type {key1: combattime, key2: spellid, key3: spellname}
				local allCastsOnThisEncounter = adlObject.EnemySkillTable

				--iterate among spells captured in the combatlgo and fill the tables created above
				for index, spellInfo in ipairs(allCastsOnThisEncounter) do
					--get the values
					local combatTime, spellId, spellName = unpack(spellInfo)

					--create the table for this spell if needed
					encounterSpellCasts[spellName] = encounterSpellCasts[spellName] or {}

					--the timeNow is used to clear old spell casts
					table.insert(encounterSpellCasts[spellName], {combatTime, timeNow})

					--save the spellId for this spell
					spellIdCache[spellName] = spellId
				end

				wipe(allCastsOnThisEncounter) --unload from memory

				--max current segment deaths to record
				local maxDeathsForCurrent = adlObject.db.max_deaths_for_current
				--max timeline deaths to record
				local maxTimelineDeaths = adlObject.db.max_deaths_for_timeline
				--max endurance deaths to record
				local maxEndurance = adlObject.db.endurance_threshold

				--iterate amoung deaths
				for deathIndex, thisDeathTable in ipairs(deathList) do
					--record for 'last try' 'current segment' deaths stuff
					local playerName, playerClass, deathUnixTime, deathCombatTime, deathStringTime, playerMaxHealth, deathEvents, lastCooldown = adlObject:UnpackDeathTable(thisDeathTable)
					if (#deathsOccurredOnThisEncounter.deaths < maxDeathsForCurrent) then
						--deathsOccurredOnThisEncounter.deaths is an indexed entry on advancedDeathLogs.dataBase.deathsPerSegment
						table.insert(deathsOccurredOnThisEncounter.deaths, {
							name = playerName,
							class = playerClass,
							time = deathUnixTime,
							timestring = deathStringTime,
							timeofdeath = deathCombatTime,
							events = deathEvents,
							maxhealth = playerMaxHealth
						})
					end

					--record endurance
					if (deathIndex <= maxEndurance) then
						local playerTable = adlObject:GetPlayerTable(enduranceTable, playerName)

						if (enduranceFailed[playerName]) then
							playerTable.points = playerTable.points + 80
						else
							playerTable.points = playerTable.points + 90
						end

						playerTable.encounters = playerTable.encounters + 1

						local lastHit = adlObject:GetLastHit(deathEvents)
						table.insert(playerTable.deaths, {combatObject.is_boss.try_number or 0, deathCombatTime, lastHit})
						enduranceFailed[playerName] = true

						adlObject:DebugMsg("Added an endurance entry.")
					end

					--record for timeline deaths
					if (deathIndex <= maxTimelineDeaths) then
						--combat time
						local combatTime = math.floor(deathCombatTime)
						--add to the table
						encounterDeathsOnSeconds[combatTime] = encounterDeathsOnSeconds[combatTime] or {}
						table.insert(encounterDeathsOnSeconds[combatTime], timeNow)
					end

					--everything is on max
					if (deathIndex > maxEndurance and deathIndex > maxTimelineDeaths and deathIndex > maxDeathsForCurrent) then
						break
					end
				end --loop
			end --combat time > 40
		else
			adlObject:DebugMsg("no deaths found on this encounter.")
		end --#death_list > 0

		--close the rest of endurance
		if (combatObject:GetCombatTime() > 40) then
			for i = 1, GetNumGroupMembers(), 1 do
				local playerName = GetUnitName("raid" .. i, true)

				if (not enduranceFailed[playerName]) then
					---@type actordamage
					local damageActor = combatObject(DETAILS_ATTRIBUTE_DAMAGE, playerName)
					---@type actorheal
					local healingActor = combatObject(DETAILS_ATTRIBUTE_HEAL, playerName)

					if ((damageActor and damageActor.total > 0) or (healingActor and healingActor.total > 0)) then
						local playerTable = adlObject:GetPlayerTable(enduranceTable, playerName)
						playerTable.points = playerTable.points + 100
						playerTable.encounters = playerTable.encounters + 1
					end
				end
			end
		end

		adlObject:CanShowIcon()
	end
end

function adlObject:GetLastHit(deathlog)
	for i = #deathlog, 1, -1 do
		local hit = deathlog[i]
		--[1] boolean (true)
		--added a check for index 6 which stores info about the source, it won't pass if there's no source of the damage
		if (type (hit[1]) == "boolean" and hit[1] and hit[6]) then
			local spellName = adlObject.getspellinfo(hit[2]) or ""
			return spellName .. " |cFFFF3333" .. adlObject:comma_value(hit[3]) .. "|r"
		end
	end
	return ""
end

local buildOptionsPanel = function()
	local options_frame = adlObject:CreatePluginOptionsFrame("DeathGraphsOptionsWindow", Loc["STRING_OPTIONS"], 1)
	options_frame:SetHeight(260)

	local menu = {
		{
			type = "range",
			get = function() return adlObject.db.endurance_threshold end,
			set = function(self, fixedparam, value) adlObject.db.endurance_threshold = value end,
			min = 1,
			max = 30,
			step = 1,
			desc = Loc["STRING_ENDURANCE_DEATHS_THRESHOLD_DESC"],
			name = Loc["STRING_ENDURANCE_DEATHS_THRESHOLD"],
		},
		{
			type = "range",
			get = function() return adlObject.db.max_deaths_for_timeline end,
			set = function(self, fixedparam, value) adlObject.db.max_deaths_for_timeline = value end,
			min = 1,
			max = 30,
			step = 1,
			desc = Loc["STRING_TIMELINE_DEATHS_THRESHOLD_DESC"],
			name = Loc["STRING_TIMELINE_DEATHS_THRESHOLD"],
		},
		{
			type = "range",
			get = function() return adlObject.db.max_segments_for_current end,
			set = function(self, fixedparam, value) adlObject.db.max_segments_for_current = value end,
			min = 1,
			max = 10,
			step = 1,
			desc = Loc["STRING_ENCOUNTER_MAXSEGMENTS_DESC"],
			name = Loc["STRING_ENCOUNTER_MAXSEGMENTS"],
		},

		{type = "blank"},
		{
			type = "toggle",
			name = Loc["STRING_RAIDFINDER"],
			desc = Loc["STRING_RAIDFINDER_DESC"],
			order = 1,
			get = function() return adlObject.db.captures[1] end,
			set = function(self, val)
				adlObject.db.captures[1] = not adlObject.db.captures[1]
			end,
		},
		{
			type = "toggle",
			name = Loc["STRING_NORMAL"],
			desc = Loc["STRING_NORMAL_DESC"],
			order = 1,
			get = function() return adlObject.db.captures[2] end,
			set = function(self, val)
				adlObject.db.captures[2] = not adlObject.db.captures[2]
			end,
		},
		{
			type = "toggle",
			name = Loc["STRING_HEROIC"],
			desc = Loc["STRING_HEROIC_DESC"],
			order = 1,
			get = function() return adlObject.db.captures[4] end,
			set = function(self, val)
				adlObject.db.captures[3] = not adlObject.db.captures[3]
			end,
		},
		{
			type = "toggle",
			name = Loc["STRING_MYTHIC"],
			desc = Loc["STRING_MYTHIC_DESC"],
			order = 1,
			get = function() return adlObject.db.captures[4] end,
			set = function(self, val)
				adlObject.db.captures[4] = not adlObject.db.captures[4]
			end,
		},

	}

	local options_text_template = DetailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DetailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DetailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = DetailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

	DetailsFramework:BuildMenu(options_frame, menu, 15, -75, 360, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
	options_frame:SetBackdropColor(0, 0, 0, .9)
end

adlObject.OpenOptionsPanel = function()
	if (not DeathGraphsOptionsWindow) then
		buildOptionsPanel()
	end
	DeathGraphsOptionsWindow:Show()
end

cleuEventFrame:SetScript("OnEvent", function (self, event)
	local time, token, hidding, sourceSerial, sourceName, sourceFlags, sourceFlags2, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName = CombatLogGetCurrentEventInfo()
	if (token == "SPELL_CAST_SUCCESS") then --if an actor successful casted a spell
		if (bitBand(sourceFlags, 0x00000040) ~= 0) then --check if the actor is a enemy        DeathGraphs.BossEncounterStartAt
			local thisTime = math.floor(time - cleuEventFrame.combatStartTime) --get the combat elapsed time
			if (adlObject.EnemySkillTableDelay[spellId] ~= thisTime) then --avoid a spell be recorded more than once per second
				table.insert(adlObject.EnemySkillTable, {thisTime, spellId, spellName}) --add the spell
				adlObject.EnemySkillTableDelay[spellId] = thisTime
			end
		end
	end
end)

function adlObject:OnEvent(_, event, ...)
	if (event == "ADDON_LOADED") then
		local AddonName = select(1, ...)
		if (AddonName == "Details_DeathGraphs") then
			if (Details) then
				--saved variables
				local currentDatabaseVersion = 1

				if (not AdvancedDeathLogsDB) then
					---@class adl_encounterinfo : table
					---@field encounterName encountername
					---@field encounterId encounterid
					---@field bossIcon textureid|texturepath|nil
					---@field zoneName string
					---@field zoneId number

					---@class adl_deathtable : table
					---@field name actorname
					---@field class class
					---@field time unixtime
					---@field timestring timestring
					---@field timeofdeath combattime
					---@field events table[]
					---@field maxhealth health

					---@class adl_segmentdeaths : table
					---@field encounterName encountername
					---@field bossIcon textureid|texturepath|nil
					---@field date unixtime
					---@field timeelapsed combattime
					---@field deaths adl_deathtable[]

					---@class adl_deathoccurrences : table
					---@field combattime unixtime[]

					---@class adl_spellcasts : table
					---@field spellname {key1: combattime, key2: unixtime}[]

					---@class adl_database : table
					---@field __version number
					---@field encounterInfo table<encounterid, adl_encounterinfo>
					---@field deathsPerSegment adl_segmentdeaths[]
					---@field deathsOccurrences table<ehash, table<number, unixtime[]>>
					---@field enemySpellCasts table<ehash, adl_spellcasts>
					---@field spellIdCache table<spellname, spellid>

					---@type adl_database
					local newDatabaseTable = {
						__version = currentDatabaseVersion,
						encounterInfo = {}, --store information about an encounter

						deathsPerSegment = {}, --replace: DeathGraphs.current_database | store all deaths per encounter
						deathsOccurrences = {}, --replace: graph_database[EncounterHash].deaths | store deaths per second of all encounters: [encounter-hash][second] = {unixtime, unixtime, unixtime}
						enemySpellCasts = {}, --replace: graph_database[EncounterHash].spells | store all enemy spell casts for all encounters
						spellIdCache = {}, --replace: graph_database[EncounterHash].ids | store [spellName] = spellId
					}

					AdvancedDeathLogsDB = newDatabaseTable
				end

				---@type adl_database
				local database = AdvancedDeathLogsDB

				advancedDeathLogs.dataBase = database

				DeathGraphsDBEndurance = DeathGraphsDBEndurance or {}

				--old database
				DeathGraphsDBDeaths = nil
				DeathGraphsDBCurrent = nil
				DeathGraphsDBGraph = nil

				--all the four are in use
				adlObject.endurance_database = DeathGraphsDBEndurance

				--DeathGraphs.endurance_database -> hashboss, bosstable -> player_db -> playername, playertable -> encounters

				--create widgets
				createPluginFunctions()

				--core version required
				local MINIMAL_DETAILS_VERSION_REQUIRED = 128

				local defaults = {
					show_icon = 1,
					last_boss = false,
					last_player = false,
					last_segment = false,
					last_encounter_hash = false,
					showing_type = 4,
					captures = {false, true, true, true},
					--deaths_threshold = 10,
					endurance_threshold = 3,
					max_segments_for_current = 2,
					max_deaths_for_current = 20,
					max_deaths_for_timeline = 5,
					timeline_cutoff_time = 3,
					timeline_cutoff_delete_time = 3,
				}

				--install
				local pluginName = Loc["STRING_PLUGIN_NAME"]
				local install, saveddata = _G.Details:InstallPlugin("TOOLBAR", "Advanced Death Logs", "Interface\\AddOns\\Details_DeathGraphs\\icon", adlObject, "DETAILS_PLUGIN_DEATH_GRAPHICS", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", adlObject.version_string, defaults)
				if (type (install) == "table" and install.error) then
					print (install.error)
				end

				--Register needed events
				Details:RegisterEvent(adlObject, "COMBAT_BOSS_FOUND")
				Details:RegisterEvent(adlObject, "DETAILS_DATA_RESET")
				Details:RegisterEvent(adlObject, "COMBAT_PLAYER_LEAVE")
				Details:RegisterEvent(adlObject, "COMBAT_PLAYER_ENTER")
				Details:RegisterEvent(adlObject, "DETAILS_STARTED")
				Details:RegisterEvent(adlObject, "DETAILS_INSTANCE_CHANGEATTRIBUTE")

				advancedDeathLogs.pluginObject.DeathGraphsWindowBuilder(adlObject)
				advancedDeathLogs.pluginObject.DeathGraphsWindowBuilder = nil
				adlObject.frames_built = true

				--store the install time for deactive tutorials by time
				adlObject.db.InstalledAt = adlObject.db.InstalledAt or time()

				advancedDeathLogs.RegisterDetailsHook()
			end
		end
	end
end
