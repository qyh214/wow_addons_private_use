local E = select(2, ...):unpack()
local P, CM, CD = E.Party, E.Comm, E.Cooldowns

local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local UnitExists, UnitGUID, UnitClass, UnitIsDeadOrGhost, UnitIsConnected, GetRaidRosterInfo = UnitExists, UnitGUID, UnitClass, UnitIsDeadOrGhost, UnitIsConnected, GetRaidRosterInfo
local UnitRace, GetUnitName, UnitLevel = UnitRace, GetUnitName, UnitLevel
local C_PvP_IsRatedSoloShuffle = E.isDF and C_PvP and C_PvP.IsRatedSoloShuffle or E.Noop

local UPDATE_ROSTER_DELAY = 2
local MSG_INFO_REQUEST_DELAY = UPDATE_ROSTER_DELAY + 1

P.groupInfo = {}
P.pendingQueue = {}
P.loginsessionData = {}
P.callbackTimers = {}

P.userInfo = {}
P.userInfo.guid = E.userGUID
P.userInfo.class = E.userClass
P.userInfo.raceID = E.userRaceID
P.userInfo.name = E.userName
P.userInfo.nameWithoutRealm = E.userName
P.userInfo.level = E.userLevel
P.userInfo.preactiveIcons = {}
P.userInfo.spellIcons = {}
P.userInfo.glowIcons = {}
P.userInfo.active = {}
P.userInfo.auras = {}
P.userInfo.itemData = {}
P.userInfo.talentData = {}
P.userInfo.shadowlandsData = {}
P.userInfo.callbackTimers = {}
P.userInfo.spellModRates = {}
P.userInfo.sessionItemData = {}

local RAID_UNIT = {
	"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
	"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
	"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
	"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40",
}

local PARTY_UNIT = {
	"party1", "party2", "party3", "party4", "player"
}

local INSTANCETYPE_EVENTS = {
	party = {
		'CHALLENGE_MODE_START' 
	},
	raid = {
		'ENCOUNTER_END' 
	},
	none = {
		'PLAYER_FLAGS_CHANGED' 
	},
	arena = {
		'UPDATE_UI_WIDGET'
	},
	pvp = {
		'CHAT_MSG_BG_SYSTEM_NEUTRAL', 
		'UPDATE_UI_WIDGET'
	}
}

if E.preMoP then
	if E.preWOTLKC then
		INSTANCETYPE_EVENTS.raid = nil
	end
	INSTANCETYPE_EVENTS.party = nil
	INSTANCETYPE_EVENTS.none = nil
end

function P:UnregisterZoneEvents()
	if self.currentZoneEvents then
		for _, event in ipairs(self.currentZoneEvents) do
			self:UnregisterEvent(event)
		end
		self.currentZoneEvents = nil
	end
end

function P:RegisterZoneEvents()
	self:UnregisterZoneEvents()

	local currentZoneEvents = INSTANCETYPE_EVENTS[self.zone]
	if currentZoneEvents then
		for _, event in ipairs(currentZoneEvents) do
			self:RegisterEvent(event)
		end
		self.currentZoneEvents = currentZoneEvents
	end
end

local function AnchorFix()
	P:UpdatePosition()
	P.callbackTimers.anchorBackup = nil
end

local function SendRequestSync()
	local success = CM:InspectUser()
	if success then
		CM:RequestSync()
		P.callbackTimers.syncDelay = nil
	else
		P.callbackTimers.syncDelay = C_Timer.NewTimer(2, SendRequestSync)
	end
end

local function UpdateRosterInfo(force, clearSession)
	local size = P:GetEffectiveNumGroupMembers()
	P.disabled = not P.isInTestMode and (P.disabledZone or size == 0 or E.isInPetBattle
		or (size == 1 and P.isUserDisabled)
		or (GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) == 0 and not E.profile.Party.visibility.finder)
		or (size > E.profile.Party.groupSize[P.zone]))

	if P.disabled then
		P:ResetModule()
		return
	end

	CM:Enable()
	CD:Enable()

	E.Libs.CBH:Fire("OnStartup")

	for guid, info in pairs(P.groupInfo) do
		if not UnitExists(info.name) or (guid == E.userGUID and P.isUserDisabled) then
			local minionGUID = info.auras.capTotemGUID
			if minionGUID then
				CD.totemGUIDS[minionGUID] = nil
			end
			minionGUID = info.petGUID
			if minionGUID then
				CD.petGUIDS[minionGUID] = nil
			end

			CM.syncedGroupMembers[guid] = nil
			CM:DequeueInspect(guid)

			for _, timer in pairs(info.callbackTimers) do
				if type(timer) == "userdata" then
					timer:Cancel()
				end
			end
			info.bar:Release()

			P.groupInfo[guid] = nil
		elseif clearSession then
			wipe(info.sessionItemData)
		end
	end

	local isInRaid = IsInRaid()
	for i = 1, size do
		local index = not isInRaid and i == size and 5 or i
		local unit = isInRaid and RAID_UNIT[index] or PARTY_UNIT[index]
		local guid = UnitGUID(unit)
		local info = P.groupInfo[guid]
		local _, class = UnitClass(unit)
		local isDead = UnitIsDeadOrGhost(unit)
		local isOffline = not UnitIsConnected(unit)
		local isDeadOrOffline = isDead or isOffline
		local isUser = guid == E.userGUID

		local isAdminObsForMDI
		if P.zone == "party" then
			
			local _,_, subgroup = GetRaidRosterInfo(i)
			isAdminObsForMDI = subgroup and subgroup > 1
		end

		local isWarlock = class == "WARLOCK"
		local pet = (class == "HUNTER" or isWarlock) and E.UNIT_TO_PET[unit]
		if pet then
			local petGUID = UnitGUID(pet)
			if petGUID then
				pet = petGUID
				CD.petGUIDS[petGUID] = guid
			end
		end

		if info then
			local frame = info.bar
			local unitIdChanged = info.unit ~= unit
			if unitIdChanged then
				info.index, info.unit = index, unit
				frame.key, frame.unit = index, unit
				frame.anchor.text:SetText(index)
			end

			
			
			
			if force or not info.spec or (info.isAdminObsForMDI ~= isAdminObsForMDI) then
				info.isAdminObsForMDI = isAdminObsForMDI
				if not isUser then
					P.pendingQueue[#P.pendingQueue + 1] = guid
				end
				P:UpdateUnitBar(guid, true)
			elseif unitIdChanged and not isAdminObsForMDI then
				frame:UnregisterAllEvents()
				if not E.preMoP and not isUser then
					frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
				end
				if E.isBFA then
					if P.isInArena then
						frame:RegisterUnitEvent('UNIT_AURA', unit)
					end
				else
					if info.glowIcons[125174] or info.preactiveIcons[5384] then
						frame:RegisterUnitEvent('UNIT_AURA', unit)
					end
				end
				if isDead then
					frame:RegisterUnitEvent('UNIT_HEALTH', unit)
				end
				frame:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', unit, E.UNIT_TO_PET[unit])
				frame:RegisterUnitEvent('UNIT_CONNECTION', unit)
			end
		elseif isUser then
			if not P.isUserDisabled then
				P.groupInfo[guid] = P.userInfo
				P.groupInfo[guid].index = index
				P.groupInfo[guid].unit = unit
				P.groupInfo[guid].petGUID = pet
				P.groupInfo[guid].isDead = isDead
				P.groupInfo[guid].isDeadOrOffline = isDeadOrOffline
				P.groupInfo[guid].isAdminObsForMDI = isAdminObsForMDI
				info = P.groupInfo[guid]
				P:UpdateUnitBar(guid, true)
			end
		elseif class then
			local _,_, race = UnitRace(unit)
			local name1 = GetUnitName(unit, true) 
			local name2 = UnitName(unit)
			local level = UnitLevel(unit)
			level = level > 0 and level or 200
			info = {
				guid = guid,
				class = class,
				raceID = race,
				name = name1,
				nameWithoutRealm = name2,
				level = level,
				index = index,
				unit = unit,
				petGUID = pet,
				isDead = isDead,
				isDeadOrOffline = isDeadOrOffline,
				isAdminObsForMDI = isAdminObsForMDI,
				preactiveIcons = {},
				spellIcons = {},
				glowIcons = {},
				active = {},
				auras = {},
				itemData = {},
				talentData = {},
				shadowlandsData = {},
				callbackTimers = {},
				spellModRates = {},
				sessionItemData = {},
			}
			P.groupInfo[guid] = info

			P.pendingQueue[#P.pendingQueue + 1] = guid
			P:UpdateUnitBar(guid, true)
		elseif not isOffline then
			C_Timer.After(UPDATE_ROSTER_DELAY, function() UpdateRosterInfo(true) end)
		end

		if info then
			info.isDeadOrOffline = isDeadOrOffline
			if isDeadOrOffline then
				P:SetDisabledColorScheme(info)
			else
				P:SetEnabledColorScheme(info)
			end
		end
	end

	P:UpdatePosition()
	P:UpdateExBars()
	CM:EnqueueInspect()
	CM:ToggleCooldownSync()

	if not force then
		P.callbackTimers.rosterDelay = nil
	end

	if P.joinedNewGroup or force then
		if P.callbackTimers.syncDelay then
			P.callbackTimers.syncDelay:Cancel()
		end
		P.callbackTimers.syncDelay = C_Timer.NewTimer(size == 1 and 0 or MSG_INFO_REQUEST_DELAY, SendRequestSync)
		P.joinedNewGroup = nil
	end

	if P.callbackTimers.anchorBackup then
		P.callbackTimers.anchorBackup:Cancel()
	end
	P.callbackTimers.anchorBackup = C_Timer.NewTicker(6, AnchorFix, (E.customUF.active == "VuhDo" or E.customUF.active == "HealBot") and 2 or 1)
end

function P:IsInShadowlands()
	local mapID = C_Map and C_Map.GetBestMapForUnit("player")
	if mapID then
		local mapInfo = C_Map.GetMapInfo(mapID)
		while mapInfo do
			if mapInfo.mapType == Enum.UIMapType.Continent then
				return mapInfo.mapID == 1550
			end
			mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
		end
	end
end

function P:GROUP_ROSTER_UPDATE(isPEW, isRefresh) 
	if self.callbackTimers.rosterDelay then
		self.callbackTimers.rosterDelay:Cancel()
		self.callbackTimers.rosterDelay = nil
	end

	if isRefresh or GetNumGroupMembers() == 0 then
		
		UpdateRosterInfo(true)
	elseif isPEW then
		
		C_Timer.After(E.customUF.delay or 0.5, function()
			
			self.isInShadowlands = E.isSL or (E.postBFA and not self.isInPvPInstance and self:IsInShadowlands())
			UpdateRosterInfo(true, true)
		end)
	else
		
		self.callbackTimers.rosterDelay = C_Timer.NewTimer(E.customUF.delay or 0.5, function()
			UpdateRosterInfo()
		end)
	end
end

local inspectAllGroupMembers = function()
	CM:EnqueueInspect(true)
end


function P:GROUP_JOINED()
	if self.disabled then
		return
	end

	self.joinedNewGroup = true
	if self.isInArena and C_PvP_IsRatedSoloShuffle() then
		self:ResetAllIcons("joinedPvP", true)
		if not self.callbackTimers.arenaTicker then
			self.callbackTimers.arenaTicker = C_Timer.NewTicker(6, inspectAllGroupMembers, 5)
		end
	end
end

local function IsExtraBarDisabled()
	for _, frame in pairs(P.extraBars) do
		if frame.db.enabled then
			return false
		end
	end
	return true
end

function P:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi, isRefresh)
	local _, instanceType = IsInInstance()
	self.zone = instanceType
	self.isInArena = instanceType == "arena"
	self.isInPvPInstance = self.isInArena or instanceType == "pvp"
	self.disabledZone = not self.isInTestMode and not E.profile.Party.visibility[instanceType]
	if self.disabledZone then
		if not self.disabled then
			self:ResetModule()
		end
		return
	end

	if not isRefresh and self.isInTestMode then
		self:Test()
	end

	
	local zone = self.isInTestMode and self.testZone or instanceType
	E.db = E:GetCurrentZoneSettings(zone)
	for key, frame in pairs(self.extraBars) do
		frame.db = E.db.extraBars[key]
	end

	self.isUserHidden = not self.isInTestMode and not E.db.general.showPlayer
	self.isUserDisabled = self.isUserHidden and (not E.db.general.showPlayerEx or IsExtraBarDisabled())
	self.isHighlightEnabled = E.db.highlight.glowBuffs
	self.isPvP = E.preMoP or self.isInPvPInstance or (instanceType == "none" and C_PvP.IsWarModeDesired())
	self.effectivePixelMult = nil

	E:SetActiveUnitFrameData()
	self:UpdateEnabledSpells()
	self:UpdatePositionValues()
	self:UpdateExBarPositionValues()
	self:RegisterZoneEvents()
	self:UpdateZoneHooks()

	if self.isInPvPInstance then
		self:ResetAllIcons("joinedPvP")
	end
	if self.isInArena then
		if not self.callbackTimers.arenaTicker then
			self.callbackTimers.arenaTicker = C_Timer.NewTicker(12, inspectAllGroupMembers, 6)
		end
	else
		if self.callbackTimers.arenaTicker then
			self.callbackTimers.arenaTicker:Cancel()
			self.callbackTimers.arenaTicker = nil
		end
	end
	
	self:GROUP_ROSTER_UPDATE(true, isRefresh)
end

P.ZONE_CHANGED_NEW_AREA = P.PLAYER_ENTERING_WORLD

function P:CHAT_MSG_BG_SYSTEM_NEUTRAL(arg1)
	if strfind(arg1, "!$") then
		CM:EnqueueInspect(true)
	end
end

function P:UPDATE_UI_WIDGET(widgetInfo)
	if widgetInfo.widgetSetID == 1 and widgetInfo.widgetType == 0 then
		local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(widgetInfo.widgetID)
		if info and info.state == 1 and info.hasTimer then
			self:UnregisterZoneEvents()
			C_Timer.After(.5, inspectAllGroupMembers)
		end
	end
end

function P:PLAYER_FLAGS_CHANGED(unitTarget)
	if unitTarget ~= "player" or self.inLockdown then
		return
	end
	local oldpvp = self.isPvP
	self.isPvP = C_PvP.IsWarModeDesired()
	if oldpvp ~= self.isPvP then
		self:UpdateAllBars()
		CM:EnqueueInspect(true)
	end
end

function P:CHALLENGE_MODE_START()
	CM:EnqueueInspect(true)
	self:ResetAllIcons()
	self:UnregisterZoneEvents()
end

function P:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
	if groupSize > 5 then
		self:ResetAllIcons("encounterEnd")
	end
end
