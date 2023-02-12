local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local next, unpack = next, unpack
local format, strjoin = format, strjoin
local sort, tinsert = sort, tinsert
local date, utf8sub = date, string.utf8sub

local ToggleFrame = ToggleFrame
local EJ_GetCurrentTier = EJ_GetCurrentTier
local EJ_GetInstanceByIndex = EJ_GetInstanceByIndex
local EJ_GetNumTiers = EJ_GetNumTiers
local EJ_SelectTier = EJ_SelectTier
local GetDifficultyInfo = GetDifficultyInfo
local GetNumSavedInstances = GetNumSavedInstances
local GetNumSavedWorldBosses = GetNumSavedWorldBosses
local GetNumWorldPVPAreas = GetNumWorldPVPAreas
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetSavedWorldBossInfo = GetSavedWorldBossInfo
local GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
local RequestRaidInfo = RequestRaidInfo
local SecondsToTime = SecondsToTime
local InCombatLockdown = InCombatLockdown

local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME
local VOICE_CHAT_BATTLEGROUND = VOICE_CHAT_BATTLEGROUND
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS
local WORLD_BOSSES_TEXT = RAID_INFO_WORLD_BOSS
local WEEKLY_RESET = format('%s %s', WEEKLY, RESET)

local C_Map_GetAreaInfo = C_Map.GetAreaInfo
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local C_DateAndTime_GetSecondsUntilDailyReset = C_DateAndTime.GetSecondsUntilDailyReset
local C_DateAndTime_GetSecondsUntilWeeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset

local APM = { _G.TIMEMANAGER_PM, _G.TIMEMANAGER_AM }
local ukDisplayFormat, europeDisplayFormat = '', ''
local europeDisplayFormat_nocolor = strjoin('', '%02d', ':|r%02d')
local ukDisplayFormat_nocolor = strjoin('', '', '%d', ':|r%02d', ' %s|r')
local lockoutInfoFormat = '%s%s %s |cffaaaaaa(%s, %s/%s)'
local lockoutInfoFormatNoEnc = '%s%s %s |cffaaaaaa(%s)'
local formatBattleGroundInfo = '%s: '
local lockoutColorExtended, lockoutColorNormal = { r=0.3,g=1,b=0.3 }, { r=.8,g=.8,b=.8 }
local enteredFrame = false

local OnUpdate, db

local function ToTime(start, seconds)
	return SecondsToTime(start, not seconds, nil, 3)
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	europeDisplayFormat = strjoin('', '%02d', hex, ':|r%02d')
	ukDisplayFormat = strjoin('', '', '%d', hex, ':|r%02d', hex, ' %s|r')

	OnUpdate(self, 20000)
end

local function ConvertTime(h, m)
	local AmPm
	if db.time24 == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end

	return h, m, AmPm
end

local function CalculateTimeValues(tooltip)
	if (tooltip and db.localTime) or (not tooltip and not db.localTime) then
		local dateTable = C_DateAndTime_GetCurrentCalendarTime()
		return ConvertTime(dateTable.hour, dateTable.minute)
	else
		local dateTable = date('*t')
		return ConvertTime(dateTable.hour, dateTable.min)
	end
end

local function OnClick(_, btn)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if btn == 'RightButton' then
		ToggleFrame(_G.TimeManagerFrame)
	elseif E.Retail or E.Wrath then
		_G.GameTimeFrame:Click()
	end
end

local function OnLeave()
	enteredFrame = false
end

local InstanceNameByID = {
	-- NOTE: for some reason the instanceID from EJ_GetInstanceByIndex doesn't match,
	-- the instanceID from GetInstanceInfo, so use the collectIDs to find the ID to add.
	[749] = C_Map_GetAreaInfo(3845) -- 'The Eye' -> 'Tempest Keep'
}

if E.locale == 'deDE' then -- O.O
	InstanceNameByID[1023] = 'Belagerung von Boralus'	-- 'Die Belagerung von Boralus'
	InstanceNameByID[1041] = 'Königsruh'				-- 'Die Königsruh'
	InstanceNameByID[1021] = 'Kronsteiganwesen'			-- 'Das Kronsteiganwesen'
	InstanceNameByID[1186] = 'Spitzen des Aufstiegs'	-- 'Die Spitzen des Aufstiegs'
	InstanceNameByID[1198] = 'Angriff der Nokhud'		-- 'Der Angriff der Nokhud'
	InstanceNameByID[1203] = 'Azurblaues Gewölbe'		-- 'Das Azurblaue Gewölbe'
end

local instanceIconByName = {}
local collectIDs, collectedIDs = false -- for testing; mouse over the dt to show the tinspect table (@Merathilis :x)
local function GetInstanceImages(index, raid)
	local instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
	while instanceID do
		if collectIDs then
			if not collectedIDs then
				collectedIDs = {}
			end

			collectedIDs[instanceID] = name
		end

		instanceIconByName[InstanceNameByID[instanceID] or name] = buttonImage
		index = index + 1
		instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
	end
end

local krcntw = E.locale == 'koKR' or E.locale == 'zhCN' or E.locale == 'zhTW'
local difficultyTag = { -- Raid Finder, Normal, Heroic, Mythic
	(krcntw and _G.PLAYER_DIFFICULTY3) or utf8sub(_G.PLAYER_DIFFICULTY3, 1, 1),	-- R
	(krcntw and _G.PLAYER_DIFFICULTY1) or utf8sub(_G.PLAYER_DIFFICULTY1, 1, 1),	-- N
	(krcntw and _G.PLAYER_DIFFICULTY2) or utf8sub(_G.PLAYER_DIFFICULTY2, 1, 1),	-- H
	(krcntw and _G.PLAYER_DIFFICULTY6) or utf8sub(_G.PLAYER_DIFFICULTY6, 1, 1)	-- M
}

local function sortFunc(a,b) return a[1] < b[1] end

local collectedInstanceImages = false
local function OnEnter()
	DT.tooltip:ClearLines()

	if not enteredFrame then
		enteredFrame = true
		RequestRaidInfo()
	end

	if E.Retail then
		if not collectedInstanceImages then
			local numTiers = (EJ_GetNumTiers() or 0)
			if numTiers > 0 then
				local currentTier = EJ_GetCurrentTier()

				-- Loop through the expansions to collect the textures
				for i=1, numTiers do
					EJ_SelectTier(i)
					GetInstanceImages(1, false) -- Populate for dungeon icons
					GetInstanceImages(1, true) -- Populate for raid icons
				end

				if collectIDs then
					E:Dump(collectedIDs, true)
				end

				-- Set it back to the previous tier
				if currentTier then
					EJ_SelectTier(currentTier)
				end

				collectedInstanceImages = true
			end
		end

		local addedHeader = false
		for i = 1, GetNumWorldPVPAreas() do
			local _, localizedName, isActive, _, startTime, canEnter = GetWorldPVPAreaInfo(i)

			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif not startTime then
				startTime = QUEUE_TIME_UNAVAILABLE
			elseif startTime ~= 0 then
				startTime = ToTime(startTime)
			end

			if canEnter and startTime ~= 0 then
				if not addedHeader then
					DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND)
					addedHeader = true
				end

				DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
			end
		end
	end

	local lockedInstances = {raids = {}, dungeons = {}}

	for i = 1, GetNumSavedInstances() do
		local name, _, _, difficulty, locked, extended, _, isRaid = GetSavedInstanceInfo(i)
		if (locked or extended) and name then
			local isLFR, isHeroicOrMythicDungeon = (difficulty == 7 or difficulty == 17), (difficulty == 2 or difficulty == 23 or difficulty == 174)
			local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficulty)
			local sortName = name .. (displayMythic and 4 or (isHeroic or displayHeroic) and 3 or isLFR and 1 or 2)
			local difficultyLetter = (displayMythic and difficultyTag[4] or (isHeroic or displayHeroic) and difficultyTag[3] or isLFR and difficultyTag[1] or difficultyTag[2])
			local buttonImg = instanceIconByName[name] and format('|T%s:16:16:0:0:96:96:0:64:0:64|t ', instanceIconByName[name]) or ''

			if isRaid then
				tinsert(lockedInstances.raids, {sortName, difficultyLetter, buttonImg, {GetSavedInstanceInfo(i)}})
			elseif isHeroicOrMythicDungeon then
				tinsert(lockedInstances.dungeons, {sortName, difficultyLetter, buttonImg, {GetSavedInstanceInfo(i)}})
			end
		end
	end

	if next(lockedInstances.raids) then
		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(' ')
		end
		DT.tooltip:AddLine(L["Saved Raid(s)"])

		sort(lockedInstances.raids, sortFunc)

		for i = 1, #lockedInstances.raids do
			local difficultyLetter = lockedInstances.raids[i][2]
			local buttonImg = lockedInstances.raids[i][3]
			local name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(lockedInstances.raids[i][4])

			local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			if numEncounters and numEncounters > 0 and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end
		end
	end

	if next(lockedInstances.dungeons) then
		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(' ')
		end
		DT.tooltip:AddLine(L["Saved Dungeon(s)"])

		sort(lockedInstances.dungeons, sortFunc)

		for i = 1,#lockedInstances.dungeons do
			local difficultyLetter = lockedInstances.dungeons[i][2]
			local buttonImg = lockedInstances.dungeons[i][3]
			local name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(lockedInstances.dungeons[i][4])

			local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			if numEncounters and numEncounters > 0 and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end
		end
	end

	if E.Retail then
		local addedLine = false
		local worldbossLockoutList = {}
		for i = 1, GetNumSavedWorldBosses() do
			local name, _, reset = GetSavedWorldBossInfo(i)
			tinsert(worldbossLockoutList, {name, reset})
		end
		sort(worldbossLockoutList, sortFunc)
		for i = 1, #worldbossLockoutList do
			local name, reset = unpack(worldbossLockoutList[i])
			if reset then
				if not addedLine then
					if DT.tooltip:NumLines() > 0 then
						DT.tooltip:AddLine(' ')
					end
					DT.tooltip:AddLine(WORLD_BOSSES_TEXT)
					addedLine = true
				end
				DT.tooltip:AddDoubleLine(name, ToTime(reset), 1, 1, 1, 0.8, 0.8, 0.8)
			end
		end
	end

	local Hr, Min, AmPm = CalculateTimeValues(true)
	if DT.tooltip:NumLines() > 0 then
		DT.tooltip:AddLine(' ')
	end

	local dailyReset = C_DateAndTime_GetSecondsUntilDailyReset()
	if dailyReset then
		DT.tooltip:AddDoubleLine(L["Daily Reset"], ToTime(dailyReset), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	local weeklyReset = C_DateAndTime_GetSecondsUntilWeeklyReset()
	if weeklyReset then
		DT.tooltip:AddDoubleLine(WEEKLY_RESET, ToTime(weeklyReset), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	if AmPm == -1 then
		DT.tooltip:AddDoubleLine(db.localTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
		DT.tooltip:AddDoubleLine(db.localTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == 'LOADING_SCREEN_ENABLED' and enteredFrame then
		OnLeave()
	elseif event == 'UPDATE_INSTANCE_INFO' and enteredFrame then
		OnEnter(self)
	end
end

function OnUpdate(self, t)
	self.timeElapsed = (self.timeElapsed or 5) - t
	if self.timeElapsed > 0 then return end
	self.timeElapsed = 5

	if E.Retail then
		if db.flashInvite and _G.GameTimeFrame.flashInvite then
			E:Flash(self, 0.53, true)
		else
			E:StopFlash(self)
		end
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues()

	if AmPm == -1 then
		self.text:SetFormattedText(europeDisplayFormat, Hr, Min)
	else
		self.text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm])
	end
end

DT:RegisterDatatext('Time', nil, { 'UPDATE_INSTANCE_INFO', 'LOADING_SCREEN_ENABLED' }, OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, nil, nil, ApplySettings)
