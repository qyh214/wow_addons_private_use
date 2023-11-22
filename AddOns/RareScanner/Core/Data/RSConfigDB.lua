-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local LibStub = _G.LibStub
local ADDON_NAME, private = ...

local RSConfigDB = private.NewLib("RareScannerConfigDB")


-- Locales
local AL = LibStub("AceLocale-3.0"):GetLocale("RareScanner");

-- RareScanner database libraries
local RSNpcDB = private.ImportLib("RareScannerNpcDB")
local RSContainerDB = private.ImportLib("RareScannerContainerDB")
local RSEventDB = private.ImportLib("RareScannerEventDB")

-- RareScanner internal libraries
local RSConstants = private.ImportLib("RareScannerConstants")
local RSLogger = private.ImportLib("RareScannerLogger")
local RSUtils = private.ImportLib("RareScannerUtils")
local RSRoutines = private.ImportLib("RareScannerRoutines")

---============================================================================
-- Timers options
---============================================================================

function RSConfigDB.GetRescanTimer()
	return private.db.general.rescanTimer
end

function RSConfigDB.SetRescanTimer(value)
	private.db.general.rescanTimer = value
end

function RSConfigDB.GetAutoHideButtonTime()
	return private.db.display.autoHideButton
end

function RSConfigDB.SetAutoHideButtonTime(value)
	private.db.display.autoHideButton = value
end

---============================================================================
-- Appearence options
---============================================================================

function RSConfigDB.GetButtonScale()
	return private.db.display.scale
end

function RSConfigDB.SetButtonScale(value)
	private.db.display.scale = value
end

function RSConfigDB.GetMarkerOnTarget()
	return private.db.general.marker
end

function RSConfigDB.IsLockingPosition()
	return private.db.display.lockPosition
end

function RSConfigDB.SetLockingPosition(value)
	private.db.display.lockPosition = value
end

---============================================================================
-- Sound options database
---============================================================================

function RSConfigDB.GetCustomSoundsFolder()
	return private.db.sound.soundCustomFolder
end

function RSConfigDB.SetCustomSoundsFolder(value)
	private.db.sound.soundCustomFolder = value
end

function RSConfigDB.AddCustomSound(name,file)
	if (not private.db.sound.custom) then
		private.db.sound.custom = {}
	end
	
	if (file) then
		private.db.sound.custom[name] = file
	end
end

function RSConfigDB.GetCustomSound(name)
	if (private.db.sound.custom and name and private.db.sound.custom[name]) then
		return private.db.sound.custom[name]
	end
	
	return nil
end

function RSConfigDB.GetCustomSounds()
	return private.db.sound.custom
end

function RSConfigDB.DeleteCustomSound(name)
	if (private.db.sound.custom and name and private.db.sound.custom[name]) then
		private.db.sound.custom[name] = nil
	
		-- Checks if selected audios match with the deleted, in that case restores default values
		if (RSConfigDB.GetSoundPlayedWithObjects() == name) then
			RSConfigDB.SetSoundPlayedWithObjects("PVP Horde")
		end
		if (RSConfigDB.GetSoundPlayedWithNpcs() == name) then
			RSConfigDB.SetSoundPlayedWithNpcs("Horn")
		end
	end
end

function RSConfigDB.GetSoundList()
	local defaultList = {} 
	
	-- Add internal sounds
	for name, file in pairs (RSConstants.DEFAULT_SOUNDS) do
		defaultList[name] = file
	end
	
	-- Add custom sounds
	if (RSConfigDB.GetCustomSounds()) then
		for name, file in pairs (RSConfigDB.GetCustomSounds()) do
			defaultList[name] = string.format(RSConstants.EXTERNAL_SOUND_FOLDER, RSConfigDB.GetCustomSoundsFolder(), file)
		end
	end
	return defaultList;
end

function RSConfigDB.IsPlayingSound()
	return private.db.sound.soundDisabled
end

function RSConfigDB.SetPlayingSound(value)
	private.db.sound.soundDisabled = value
end

function RSConfigDB.IsPlayingObjectsSound()
	return private.db.sound.soundObjectDisabled
end

function RSConfigDB.SetPlayingObjectsSound(value)
	private.db.sound.soundObjectDisabled = value
end

function RSConfigDB.GetSoundPlayedWithObjects()
	return private.db.sound.soundObjectPlayed
end

function RSConfigDB.SetSoundPlayedWithObjects(value)
	private.db.sound.soundObjectPlayed = value
end

function RSConfigDB.GetSoundPlayedWithNpcs()
	return private.db.sound.soundPlayed
end

function RSConfigDB.SetSoundPlayedWithNpcs(value)
	private.db.sound.soundPlayed = value
end

function RSConfigDB.GetSoundVolume()
	return private.db.sound.soundVolume
end

function RSConfigDB.SetSoundVolume(value)
	private.db.sound.soundVolume = value
end

function RSConfigDB.GetSoundChannel()
	return private.db.sound.soundChannel
end

function RSConfigDB.SetSoundChannel(value)
	private.db.sound.soundChannel = value
end

---============================================================================
-- Display options database
---============================================================================

function RSConfigDB.IsButtonDisplaying()
	return private.db.display.displayButton
end

function RSConfigDB.SetButtonDisplaying(value)
	private.db.display.displayButton = value
end

function RSConfigDB.IsButtonDisplayingForContainers()
	return private.db.display.displayButtonContainers
end

function RSConfigDB.SetButtonDisplayingForContainers(value)
	private.db.display.displayButtonContainers = value
end

function RSConfigDB.IsDisplayingNavigationArrows()
	return private.db.display.enableNavigation
end

function RSConfigDB.SetDisplayingNavigationArrows(value)
	private.db.display.enableNavigation = value
end

function RSConfigDB.IsDisplayingRaidWarning()
	return private.db.display.displayRaidWarning
end

function RSConfigDB.SetDisplayingRaidWarning(value)
	private.db.display.displayRaidWarning = value
end

function RSConfigDB.IsDisplayingChatMessages()
	return private.db.display.displayChatMessage
end

function RSConfigDB.SetDisplayingChatMessages(value)
	private.db.display.displayChatMessage = value
end

function RSConfigDB.IsDisplayingTimestampChatMessages()
	return private.db.display.displayTimestampChatMessage
end

function RSConfigDB.SetDisplayingTimestampChatMessages(value)
	private.db.display.displayTimestampChatMessage = value
end

function RSConfigDB.IsDisplayingLootBar()
	return private.db.loot.displayLoot
end

function RSConfigDB.SetDisplayingLootBar(value)
	private.db.loot.displayLoot = value
end

function RSConfigDB.IsDisplayingMarkerOnTarget()
	return private.db.general.showMaker
end

function RSConfigDB.SetDisplayingMarkerOnTarget(value)
	private.db.general.showMaker = value
end

function RSConfigDB.IsDisplayingModel()
	return private.db.display.displayMiniature
end

function RSConfigDB.SetDisplayingModel(value)
	private.db.display.displayMiniature = value
end

---============================================================================
-- Scanner filters database
---============================================================================

function RSConfigDB.IsScanningInInstances()
	return private.db.general.scanInstances
end

function RSConfigDB.SetScanningInInstance(value)
	private.db.general.scanInstances = value
end

function RSConfigDB.IsScanningWhileOnTaxi()
	return private.db.general.scanOnTaxi
end

function RSConfigDB.SetScanningWhileOnTaxi(value)
	private.db.general.scanOnTaxi = value
end

function RSConfigDB.IsScanningWhileOnRacingQuest()
	return private.db.general.scanOnRacingQuest
end

function RSConfigDB.SetScanningWhileOnRacingQuest(value)
	private.db.general.scanOnRacingQuest = value
end

function RSConfigDB.IsScanningWhileOnPetBattle()
	return private.db.general.scanOnPetBattle
end

function RSConfigDB.SetScanningWhileOnPetBattle(value)
	private.db.general.scanOnPetBattle = value
end

function RSConfigDB.IsScanningWorldMapVignettes()
	return private.db.general.scanWorldmapVignette
end

function RSConfigDB.SetScanningWorldMapVignettes(value)
	private.db.general.scanWorldmapVignette = value
end

function RSConfigDB.IsIgnoringCompletedEntities()
	return private.db.general.ignoreCompletedEntities
end

function RSConfigDB.SetIgnoringCompletedEntities(value)
	private.db.general.ignoreCompletedEntities = value
end

function RSConfigDB.IsScanningForNpcs()
	return private.db.general.scanRares
end

function RSConfigDB.SetScanningForNpcs(value)
	private.db.general.scanRares = value
end

function RSConfigDB.IsScanningForContainers()
	return private.db.general.scanContainers
end

function RSConfigDB.SetScanningForContainers(value)
	private.db.general.scanContainers = value
end

function RSConfigDB.IsScanningForEvents()
	return private.db.general.scanEvents
end

function RSConfigDB.SetScanningForEvents(value)
	private.db.general.scanEvents = value
end

function RSConfigDB.IsScanningChatAlerts()
	return private.db.general.scanChatAlerts
end

function RSConfigDB.SetScanningChatAlerts(value)
	private.db.general.scanChatAlerts = value
end

function RSConfigDB.IsScanningTargetUnit()
	return private.db.general.scanTargetUnit
end

function RSConfigDB.SetScanningTargetUnit(value)
	private.db.general.scanTargetUnit = value
end

---============================================================================
-- Not discovered filters database
---============================================================================

function RSConfigDB.IsShowingOldNotDiscoveredMapIcons()
	return private.db.map.displayOldNotDiscoveredMapIcons
end

function RSConfigDB.SetShowingOldNotDiscoveredMapIcons(value)
	private.db.map.displayOldNotDiscoveredMapIcons = value
end

---============================================================================
-- NPC filters database
---============================================================================

function RSConfigDB.IsShowingNpcs()
	return private.db.map.displayNpcIcons
end

function RSConfigDB.SetShowingNpcs(value)
	private.db.map.displayNpcIcons = value
end

function RSConfigDB.IsNpcFiltered(npcID)
	local filterType = RSConfigDB.GetNpcFiltered(npcID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALL) then
		return true
	end
	
	return false
end

function RSConfigDB.IsNpcFilteredOnlyWorldmap(npcID)
	local filterType = RSConfigDB.GetNpcFiltered(npcID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_WORLDMAP) then
		return true
	end
	
	return false
end

function RSConfigDB.IsNpcFilteredOnlyAlerts(npcID)
	local filterType = RSConfigDB.GetNpcFiltered(npcID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALERTS) then
		return true
	end
	
	return false
end

function RSConfigDB.GetNpcFiltered(npcID)
	if (npcID and private.db.rareFilters.filteredNpcs and private.db.rareFilters.filteredNpcs[npcID]) then
		return private.db.rareFilters.filteredNpcs[npcID]
	end
	
	return nil
end

function RSConfigDB.SetNpcFiltered(npcID, filterType)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.SetNpcFiltered [%s][%s]", npcID, filterType or ""))
	if (not private.db.rareFilters.filteredNpcs) then
		private.db.rareFilters.filteredNpcs = {}
	end
	
	if (npcID) then
		if (filterType) then
			private.db.rareFilters.filteredNpcs[npcID] = filterType
		else
			private.db.rareFilters.filteredNpcs[npcID] = RSConfigDB.GetDefaultNpcFilter()
		end
	end
end

function RSConfigDB.DeleteNpcFiltered(npcID)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.DeleteNpcFiltered [%s]", npcID))
	if (npcID and private.db.rareFilters.filteredNpcs and private.db.rareFilters.filteredNpcs[npcID]) then
		private.db.rareFilters.filteredNpcs[npcID] = nil
	end
	
	if (RSUtils.GetTableLength(private.db.rareFilters.filteredNpcs) == 0) then
		private.db.rareFilters.filteredNpcs = nil
	end
end

function RSConfigDB.SetDefaultNpcFilter(filterType)
	if (filterType) then
		private.db.rareFilters.defaultNpcFilterType = filterType
	end
end

function RSConfigDB.GetDefaultNpcFilter()
	return private.db.rareFilters.defaultNpcFilterType
end

function RSConfigDB.FilterAllNpcs(routines, routineTextOutput)
	local filterAllNpcsRoutine = RSRoutines.LoopRoutineNew()
	filterAllNpcsRoutine:Init(RSNpcDB.GetAllInternalNpcInfo, 500, 
		function(context, npcID, _)
			RSConfigDB.SetNpcFiltered(npcID)
		end,
		function(context)
			RSLogger:PrintDebugMessage("FilterAllNpcs. Filtrados todos los NPCs")
			
			if (routineTextOutput) then
				routineTextOutput:SetText(AL["EXPLORER_FILTERING_NPCS"])
			end
		end
	)
	table.insert(routines, filterAllNpcsRoutine)
end

function RSConfigDB.IsShowingFriendlyNpcs()
	return private.db.map.displayFriendlyNpcIcons
end

function RSConfigDB.SetShowingFriendlyNpcs(value)
	private.db.map.displayFriendlyNpcIcons = value
end

function RSConfigDB.IsShowingAlreadyKilledNpcs()
	return private.db.map.displayAlreadyKilledNpcIcons
end

function RSConfigDB.SetShowingAlreadyKilledNpcs(value)
	private.db.map.displayAlreadyKilledNpcIcons = value
end

function RSConfigDB.IsShowingNotDiscoveredNpcs()
	return private.db.map.displayNotDiscoveredNpcIcons
end

function RSConfigDB.SetShowingNotDiscoveredNpcs(value)
	private.db.map.displayNotDiscoveredNpcIcons = value
end

function RSConfigDB.IsShowingAlreadyKilledNpcsInReseteableZones()
	return private.db.map.displayAlreadyKilledNpcIconsReseteable
end

function RSConfigDB.SetShowingAlreadyKilledNpcsInReseteableZones(value)
	private.db.map.displayAlreadyKilledNpcIconsReseteable = value
end

function RSConfigDB.IsMaxSeenTimeFilterEnabled()
	return private.db.map.maxSeenTime ~= 0
end

function RSConfigDB.EnableMaxSeenTimeFilter()
	-- If while disabled they setted the time through the options panel
	if (RSConfigDB.GetMaxSeenTimeFilter() > 0) then
		RSLogger:PrintDebugMessage(string.format("EnableMaxSeenTimeFilter [maxSeenTime = %s]", RSConfigDB.GetMaxSeenTimeFilter()))
		return;
	end

	if (private.db.map.maxSeenTimeBak and private.db.map.maxSeenTimeBak > 0) then
		RSConfigDB.SetMaxSeenTimeFilter(private.db.map.maxSeenTimeBak)
		-- Its possible that they enabled it though the options panel
	else
		RSConfigDB.SetMaxSeenTimeFilter(5, false)
	end
	RSLogger:PrintDebugMessage(string.format("EnableMaxSeenTimeFilter [maxSeenTime = %s]", RSConfigDB.GetMaxSeenTimeFilter()))
end

function RSConfigDB.DisableMaxSeenTimeFilter()
	private.db.map.maxSeenTimeBak = RSConfigDB.GetMaxSeenTimeFilter()
	RSConfigDB.SetMaxSeenTimeFilter(0, false)
	RSLogger:PrintDebugMessage(string.format("DisableMaxSeenTimeFilter [maxSeenTime = %s]", RSConfigDB.GetMaxSeenTimeFilter()))
end

function RSConfigDB.GetMaxSeenTimeFilter()
	return private.db.map.maxSeenTime
end

function RSConfigDB.SetMaxSeenTimeFilter(value, clearBak)
	private.db.map.maxSeenTime = value
	RSLogger:PrintDebugMessage(string.format("SetMaxSeenTimeFilter [maxSeenTime = %s]", value))
	if (clearBak) then
		private.db.map.maxSeenTimeBak = nil
	end
end

function RSConfigDB.IsShowingAchievementRareNPCs()
	return private.db.map.displayAchievementRaresNpcIcons
end

function RSConfigDB.SetShowingAchievementRareNPCs(value)
	private.db.map.displayAchievementRaresNpcIcons = value
end

function RSConfigDB.IsShowingProfessionRareNPCs()
	return private.db.map.displayProfessionRaresNpcIcons
end

function RSConfigDB.SetShowingProfessionRareNPCs(value)
	private.db.map.displayProfessionRaresNpcIcons = value
end

function RSConfigDB.IsMinieventFiltered(minieventID)
	if (minieventID and private.db.map.displayMinieventsNpcIcons[minieventID]) then
		return private.db.map.displayMinieventsNpcIcons[minieventID]
	end
	
	return false
end

function RSConfigDB.SetMinieventFiltered(minieventID, filtered)
	if (minieventID) then
		private.db.map.displayMinieventsNpcIcons[minieventID] = filtered
	end
end

function RSConfigDB.IsShowingOtherRareNPCs()
	return private.db.map.displayOtherRaresNpcIcons
end

function RSConfigDB.SetShowingOtherRareNPCs(value)
	private.db.map.displayOtherRaresNpcIcons = value
end

---============================================================================
-- Container filters database
---============================================================================

function RSConfigDB.IsShowingContainers()
	return private.db.map.displayContainerIcons
end

function RSConfigDB.SetShowingContainers(value)
	private.db.map.displayContainerIcons = value
end

function RSConfigDB.IsContainerFiltered(containerID)
	local filterType = RSConfigDB.GetContainerFiltered(containerID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALL) then
		return true
	end
	
	return false
end

function RSConfigDB.IsContainerFilteredOnlyWorldmap(containerID)
	local filterType = RSConfigDB.GetContainerFiltered(containerID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_WORLDMAP) then
		return true
	end
	
	return false
end

function RSConfigDB.IsContainerFilteredOnlyAlerts(containerID)
	local filterType = RSConfigDB.GetContainerFiltered(containerID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALERTS) then
		return true
	end
	
	return false
end

function RSConfigDB.GetContainerFiltered(containerID)
	if (containerID and private.db.containerFilters.filteredContainers and private.db.containerFilters.filteredContainers[containerID]) then
		return private.db.containerFilters.filteredContainers[containerID]
	end
	
	return nil
end

function RSConfigDB.SetContainerFiltered(containerID, filterType)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.SetContainerFiltered [%s][%s]", containerID, filterType or ""))
	if (not private.db.containerFilters.filteredContainers) then
		private.db.containerFilters.filteredContainers = {}
	end
	
	if (containerID) then
		if (filterType) then
			private.db.containerFilters.filteredContainers[containerID] = filterType
		else
			private.db.containerFilters.filteredContainers[containerID] = RSConfigDB.GetDefaultContainerFilter()
		end
	end
end

function RSConfigDB.DeleteContainerFiltered(containerID)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.DeleteContainerFiltered [%s]", containerID))
	if (containerID and private.db.containerFilters.filteredContainers and private.db.containerFilters.filteredContainers[containerID]) then
		private.db.containerFilters.filteredContainers[containerID] = nil
	end
	
	if (RSUtils.GetTableLength(private.db.containerFilters.filteredContainers) == 0) then
		private.db.containerFilters.filteredContainers = nil
	end
end

function RSConfigDB.SetDefaultContainerFilter(filterType)
	if (filterType) then
		private.db.containerFilters.defaultContainerFilterType = filterType
	end
end

function RSConfigDB.GetDefaultContainerFilter()
	return private.db.containerFilters.defaultContainerFilterType
end

function RSConfigDB.FilterAllContainers(routines, routineTextOutput)
	local filterAllContainersRoutine = RSRoutines.LoopRoutineNew()
	filterAllContainersRoutine:Init(RSContainerDB.GetAllInternalContainerInfo, 500, 
		function(context, containerID, _)
			RSConfigDB.SetContainerFiltered(containerID)
		end,
		function(context)
			RSLogger:PrintDebugMessage("FilterAllContainers. Filtrados todos los contenedores")
			
			if (routineTextOutput) then
				routineTextOutput:SetText(AL["EXPLORER_FILTERING_CONTAINERS"])
			end
		end
	)
	table.insert(routines, filterAllContainersRoutine)
end

function RSConfigDB.IsShowingGarrisonCache()
	return private.db.general.scanGarrison
end

function RSConfigDB.SetShowingGarrisonCache(value)
	private.db.general.scanGarrison = value
end

function RSConfigDB.IsShowingAlreadyOpenedContainers()
	return private.db.map.displayAlreadyOpenedContainersIcons
end

function RSConfigDB.SetShowingAlreadyOpenedContainers(value)
	private.db.map.displayAlreadyOpenedContainersIcons = value
end

function RSConfigDB.IsShowingNotDiscoveredContainers()
	return private.db.map.displayNotDiscoveredContainerIcons
end

function RSConfigDB.SetShowingNotDiscoveredContainers(value)
	private.db.map.displayNotDiscoveredContainerIcons = value
end

function RSConfigDB.IsMaxSeenTimeContainerFilterEnabled()
	return private.db.map.maxSeenTimeContainer ~= 0
end

function RSConfigDB.EnableMaxSeenContainerTimeFilter()
	-- If while disabled they setted the time through the options panel
	if (RSConfigDB.GetMaxSeenContainerTimeFilter() > 0) then
		RSLogger:PrintDebugMessage(string.format("EnableMaxSeenContainerTimeFilter [maxSeenTimeContainer = %s]", RSConfigDB.GetMaxSeenContainerTimeFilter()))
		return;
	end

	if (private.db.map.maxSeenContainerTimeBak and private.db.map.maxSeenContainerTimeBak > 0) then
		RSConfigDB.SetMaxSeenContainerTimeFilter(private.db.map.maxSeenContainerTimeBak)
		-- Its possible that they enabled it though the options panel
	else
		RSConfigDB.SetMaxSeenContainerTimeFilter(5, false)
	end
	RSLogger:PrintDebugMessage(string.format("EnableMaxSeenContainerTimeFilter [maxSeenTimeContainer = %s]", RSConfigDB.GetMaxSeenContainerTimeFilter()))
end

function RSConfigDB.DisableMaxSeenContainerTimeFilter()
	private.db.map.maxSeenContainerTimeBak = RSConfigDB.GetMaxSeenContainerTimeFilter()
	RSConfigDB.SetMaxSeenContainerTimeFilter(0, false)
	RSLogger:PrintDebugMessage(string.format("DisableMaxSeenContainerTimeFilter [maxSeenTimeContainer = %s]", RSConfigDB.GetMaxSeenContainerTimeFilter()))
end

function RSConfigDB.GetMaxSeenContainerTimeFilter()
	return private.db.map.maxSeenTimeContainer
end

function RSConfigDB.SetMaxSeenContainerTimeFilter(value, clearBak)
	private.db.map.maxSeenTimeContainer = value
	RSLogger:PrintDebugMessage(string.format("SetMaxSeenContainerTimeFilter [maxSeenTimeContainer = %s]", value))
	if (clearBak) then
		private.db.map.maxSeenContainerTimeBak = nil
	end
end

function RSConfigDB.IsShowingNotTrackeableContainers()
	return private.db.map.displayNotTrackeableContainerIcons
end

function RSConfigDB.SetShowingNotTrackeableContainers(value)
	private.db.map.displayNotTrackeableContainerIcons = value
end

function RSConfigDB.IsShowingAchievementContainers()
	return private.db.map.displayAchievementContainerIcons
end

function RSConfigDB.SetShowingAchievementContainers(value)
	private.db.map.displayAchievementContainerIcons = value
end

function RSConfigDB.IsShowingProfessionContainers()
	return private.db.map.displayProfessionContainerIcons
end

function RSConfigDB.SetShowingProfessionContainers(value)
	private.db.map.displayProfessionContainerIcons = value
end

function RSConfigDB.IsShowingOtherContainers()
	return private.db.map.displayOtherContainerIcons
end

function RSConfigDB.SetShowingOtherContainers(value)
	private.db.map.displayOtherContainerIcons = value
end

---============================================================================
-- Event filters database
---============================================================================

function RSConfigDB.IsShowingEvents()
	return private.db.map.displayEventIcons
end

function RSConfigDB.SetShowingEvents(value)
	private.db.map.displayEventIcons = value
end

function RSConfigDB.IsShowingCompletedEvents()
	return private.db.map.displayAlreadyCompletedEventIcons
end

function RSConfigDB.SetShowingCompletedEvents(value)
	private.db.map.displayAlreadyCompletedEventIcons = value
end

function RSConfigDB.IsShowingNotDiscoveredEvents()
	return private.db.map.displayNotDiscoveredEventIcons
end

function RSConfigDB.SetShowingNotDiscoveredEvents(value)
	private.db.map.displayNotDiscoveredEventIcons = value
end

function RSConfigDB.IsMaxSeenTimeEventFilterEnabled()
	return private.db.map.maxSeenTimeEvent ~= 0
end

function RSConfigDB.EnableMaxSeenEventTimeFilter()
	-- If while disabled they setted the time through the options panel
	if (RSConfigDB.GetMaxSeenEventTimeFilter() > 0) then
		RSLogger:PrintDebugMessage(string.format("EnableMaxSeenEventTimeFilter [maxSeenTimeEvent = %s]", RSConfigDB.GetMaxSeenEventTimeFilter()))
		return;
	end

	if (private.db.map.maxSeenEventTimeBak and private.db.map.maxSeenEventTimeBak > 0) then
		RSConfigDB.SetMaxSeenEventTimeFilter(private.db.map.maxSeenEventTimeBak)
		-- Its possible that they enabled it though the options panel
	else
		RSConfigDB.SetMaxSeenEventTimeFilter(RSConstants.PROFILE_DEFAULTS.profile.map.maxSeenTimeEvent, false)
	end
	RSLogger:PrintDebugMessage(string.format("EnableMaxSeenEventTimeFilter [maxSeenTimeEvent = %s]", RSConfigDB.GetMaxSeenEventTimeFilter()))
end

function RSConfigDB.DisableMaxSeenEventTimeFilter()
	private.db.map.maxSeenEventTimeBak = RSConfigDB.GetMaxSeenEventTimeFilter()
	RSConfigDB.SetMaxSeenEventTimeFilter(0, false)
	RSLogger:PrintDebugMessage(string.format("DisableMaxSeenEventTimeFilter [maxSeenTimeEvent = %s]", RSConfigDB.GetMaxSeenEventTimeFilter()))
end

function RSConfigDB.GetMaxSeenEventTimeFilter()
	return private.db.map.maxSeenTimeEvent
end

function RSConfigDB.SetMaxSeenEventTimeFilter(value, clearBak)
	private.db.map.maxSeenTimeEvent = value
	RSLogger:PrintDebugMessage(string.format("SetMaxSeenEventTimeFilter [maxSeenTimeEvent = %s]", value))
	if (clearBak) then
		private.db.map.maxSeenEventTimeBak = nil
	end
end

function RSConfigDB.IsEventFiltered(eventID)
	local filterType = RSConfigDB.GetEventFiltered(eventID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALL) then
		return true
	end
	
	return false
end

function RSConfigDB.IsEventFilteredOnlyWorldmap(eventID)
	local filterType = RSConfigDB.GetEventFiltered(eventID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_WORLDMAP) then
		return true
	end
	
	return false
end

function RSConfigDB.IsEventFilteredOnlyAlerts(eventID)
	local filterType = RSConfigDB.GetEventFiltered(eventID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALERTS) then
		return true
	end
	
	return false
end

function RSConfigDB.GetEventFiltered(eventID)
	if (eventID and private.db.eventFilters.filteredEvents and private.db.eventFilters.filteredEvents[eventID]) then
		return private.db.eventFilters.filteredEvents[eventID]
	end
	
	return nil
end

function RSConfigDB.SetEventFiltered(eventID, filterType)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.SetEventFiltered [%s][%s]", eventID, filterType or ""))
	if (not private.db.eventFilters.filteredEvents) then
		private.db.eventFilters.filteredEvents = {}
	end
	
	if (eventID) then
		if (filterType) then
			private.db.eventFilters.filteredEvents[eventID] = filterType
		else
			private.db.eventFilters.filteredEvents[eventID] = RSConfigDB.GetDefaultEventFilter()
		end
	end
end

function RSConfigDB.DeleteEventFiltered(eventID)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.DeleteEventFiltered [%s]", eventID))
	if (eventID and private.db.eventFilters.filteredEvents and private.db.eventFilters.filteredEvents[eventID]) then
		private.db.eventFilters.filteredEvents[eventID] = nil
	end
	
	if (RSUtils.GetTableLength(private.db.eventFilters.filteredEvents) == 0) then
		private.db.eventFilters.filteredEvents = nil
	end
end

function RSConfigDB.SetDefaultEventFilter(filterType)
	if (filterType) then
		private.db.eventFilters.defaultEventFilterType = filterType
	end
end

function RSConfigDB.GetDefaultEventFilter()
	return private.db.eventFilters.defaultEventFilterType
end

---============================================================================
-- Zone filters database
---============================================================================

function RSConfigDB.IsZoneFiltered(zoneID)
	local filterType = RSConfigDB.GetZoneFiltered(zoneID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALL) then
		return true
	end
	
	return false
end

function RSConfigDB.IsZoneFilteredOnlyWorldmap(zoneID)
	local filterType = RSConfigDB.GetZoneFiltered(zoneID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_WORLDMAP) then
		return true
	end
	
	return false
end

function RSConfigDB.IsZoneFilteredOnlyAlerts(zoneID)
	local filterType = RSConfigDB.GetZoneFiltered(zoneID)
	if (filterType and filterType == RSConstants.ENTITY_FILTER_ALERTS) then
		return true
	end
	
	return false
end

function RSConfigDB.IsEntityZoneFilteredOnlyAlerts(entityID, atlasName)
	if (entityID and atlasName) then
		-- If npc
		if (RSConstants.IsNpcAtlas(atlasName)) then
			local npcInfo = RSNpcDB.GetInternalNpcInfo(entityID)
			if (npcInfo) then
				if (RSNpcDB.IsInternalNpcMultiZone(entityID)) then
					for mapID, _ in pairs (npcInfo.zoneID) do
						if (RSConfigDB.GetZoneFiltered(mapID)) then
							return RSConfigDB.IsZoneFilteredOnlyAlerts(mapID)
						end
					end
				elseif (RSNpcDB.IsInternalNpcMonoZone(entityID)) then
					return RSConfigDB.IsZoneFilteredOnlyAlerts(npcInfo.zoneID)
				end
			end
		-- If container
		elseif (RSConstants.IsContainerAtlas(atlasName)) then
			local containerInfo = RSContainerDB.GetInternalContainerInfo(entityID)
			if (containerInfo) then
				if (RSContainerDB.IsInternalContainerMultiZone(entityID)) then
					for mapID, _ in pairs (containerInfo.zoneID) do
						if (RSConfigDB.GetZoneFiltered(mapID)) then
							return RSConfigDB.IsZoneFilteredOnlyAlerts(mapID)
						end
					end
				elseif (RSContainerDB.IsInternalContainerMonoZone(entityID)) then
					return RSConfigDB.IsZoneFilteredOnlyAlerts(containerInfo.zoneID)
				end
			end
		-- If event
		elseif (RSConstants.IsEventAtlas(atlasName)) then
			local eventInfo = RSEventDB.GetInternalEventInfo(entityID)
			if (eventInfo) then
				return RSConfigDB.IsZoneFilteredOnlyAlerts(eventInfo.zoneID)
			end
		end
	end

	return false
end

function RSConfigDB.GetZoneFiltered(zoneID)
	if (zoneID and private.db.zoneFilters.filteredZones and private.db.zoneFilters.filteredZones[zoneID]) then
		return private.db.zoneFilters.filteredZones[zoneID]
	end
	
	return nil
end

function RSConfigDB.SetZoneFiltered(zoneID, filterType)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.SetZoneFiltered [%s][%s]", eventID, filterType or ""))
	if (not private.db.zoneFilters.filteredZones) then
		private.db.zoneFilters.filteredZones = {}
	end
	
	if (zoneID) then
		if (filterType) then
			private.db.zoneFilters.filteredZones[zoneID] = filterType
		else
			private.db.zoneFilters.filteredZones[zoneID] = RSConfigDB.GetDefaultZoneFilter()
		end
	end
end

function RSConfigDB.DeleteZoneFiltered(zoneID)
	--RSLogger:PrintDebugMessage(string.format("RSConfigDB.DeleteZoneFiltered [%s]", zoneID))
	if (zoneID and private.db.zoneFilters.filteredZones and private.db.zoneFilters.filteredZones[zoneID]) then
		private.db.zoneFilters.filteredZones[zoneID] = nil
	end
	
	if (RSUtils.GetTableLength(private.db.zoneFilters.filteredZones) == 0) then
		private.db.zoneFilters.filteredZones = nil
	end
end

function RSConfigDB.SetDefaultZoneFilter(filterType)
	if (filterType) then
		private.db.zoneFilters.defaultZoneFilterType = filterType
	end
end

function RSConfigDB.GetDefaultZoneFilter()
	return private.db.zoneFilters.defaultZoneFilterType
end

---============================================================================
-- Dragon glyphs filters
---============================================================================

function RSConfigDB.IsShowingDragonGlyphs()
	return private.db.map.displayDragonGlyphsIcons
end

function RSConfigDB.SetShowingDragonGlyphs(value)
	private.db.map.displayDragonGlyphsIcons = value
end

---============================================================================
-- Minimap
---============================================================================

function RSConfigDB.IsShowingMinimapIcons()
	return private.db.map.displayMinimapIcons
end

function RSConfigDB.SetShowingMinimapIcons(value)
	private.db.map.displayMinimapIcons = value
end

function RSConfigDB.GetIconsMinimapScale()
	return private.db.map.minimapscale
end

function RSConfigDB.IsShowingMinimapButton()
	return not private.db.display.minimapButton.hide
end

function RSConfigDB.SetShowingMinimapButton(value)
	private.db.display.minimapButton.hide = not value
end

function RSConfigDB.GetMMinimapButtonDB()
	return private.db.display.minimapButton
end

function RSConfigDB.IsShowingWorldmapButton()
	return private.db.display.worldmapButton
end

function RSConfigDB.SetShowingWorldmapButton(value)
	private.db.display.worldmapButton = value
end

---============================================================================
-- Loot in general
---============================================================================

function RSConfigDB.GetMaxNumItemsToShow()
	return private.db.loot.numItems
end

function RSConfigDB.SetMaxNumItemsToShow(value)
	private.db.loot.numItems = value
end

function RSConfigDB.GetNumItemsPerRow()
	return private.db.loot.numItemsPerRow
end

function RSConfigDB.SetNumItemsPerRow(value)
	private.db.loot.numItemsPerRow = value
end

function RSConfigDB:GetLootTooltipPosition()
	return private.db.loot.lootTooltipPosition
end

function RSConfigDB:SetLootTooltipPosition(value)
	private.db.loot.lootTooltipPosition = value
end

---============================================================================
-- Loot filters
---============================================================================

function RSConfigDB.IsItemFiltered(itemID)
	if (itemID) then
		return private.db.loot.filteredItems[itemID] == true
	end

	return false
end

function RSConfigDB.GetItemFiltered(itemID)
	if (itemID) then
		return private.db.loot.filteredItems[itemID]
	end
end

function RSConfigDB.GetAllFilteredItems()
	return private.db.loot.filteredItems
end

function RSConfigDB.SetItemFiltered(itemID, value)
	if (itemID) then
		if (value) then
			private.db.loot.filteredItems[itemID] = true
		else
			private.db.loot.filteredItems[itemID] = nil
		end
	end
end

function RSConfigDB.GetLootFilterMinQuality()
	return private.db.loot.lootMinQuality
end

function RSConfigDB.SetLootFilterMinQuality(value)
	private.db.loot.lootMinQuality = value
end

function RSConfigDB.SetLootFilterByCategory(itemClassID, itemSubClassID, value)
	if (itemClassID and itemSubClassID and private.db.loot.filteredLootCategories[itemClassID]) then
		private.db.loot.filteredLootCategories[itemClassID][itemSubClassID] = value
	end
end

function RSConfigDB.GetLootFilterByCategory(itemClassID, itemSubClassID)
	if (itemClassID and itemSubClassID and private.db.loot.filteredLootCategories[itemClassID]) then
		return private.db.loot.filteredLootCategories[itemClassID][itemSubClassID]
	end

	return nil
end

function RSConfigDB.IsFilteringLootByCompletedQuest()
	return private.db.loot.filterItemsCompletedQuest
end

function RSConfigDB.SetFilteringLootByCompletedQuest(value)
	private.db.loot.filterItemsCompletedQuest = value
end

function RSConfigDB.IsFilteringLootByNotMatchingClass()
	return private.db.loot.filterNotMatchingClass
end

function RSConfigDB.SetFilteringLootByNotMatchingClass(value)
	private.db.loot.filterNotMatchingClass = value
end

function RSConfigDB.IsFilteringLootByNotMatchingFaction()
	return private.db.loot.filterNotMatchingFaction
end

function RSConfigDB.SetFilteringLootByNotMatchingFaction(value)
	private.db.loot.filterNotMatchingFaction = value
end

function RSConfigDB.IsFilteringAnimaItems()
	return private.db.loot.filterAnimaItems
end

function RSConfigDB.SetFilteringAnimaItems(value)
	private.db.loot.filterAnimaItems = value
end

function RSConfigDB.IsFilteringConduitItems()
	return private.db.loot.filterConduitItems
end

function RSConfigDB.SetFilteringConduitItems(value)
	private.db.loot.filterConduitItems = value
end

function RSConfigDB.IsFilteringByExplorerResults()
	return private.db.loot.filterByExplorerResults
end

function RSConfigDB.SetFilteringByExplorerResults(value)
	private.db.loot.filterByExplorerResults = value
end

function RSConfigDB.IsShowingMissingMounts()
	return private.db.loot.showingMissingMounts
end

function RSConfigDB.SetShowingMissingMounts(value)
	private.db.loot.showingMissingMounts = value
end

function RSConfigDB.IsShowingMissingPets()
	return private.db.loot.showingMissingPets
end

function RSConfigDB.SetShowingMissingPets(value)
	private.db.loot.showingMissingPets = value
end

function RSConfigDB.IsShowingMissingToys()
	return private.db.loot.showingMissingToys
end

function RSConfigDB.SetShowingMissingToys(value)
	private.db.loot.showingMissingToys = value
end

function RSConfigDB.IsShowingMissingAppearances()
	return private.db.loot.showingMissingAppearances
end

function RSConfigDB.SetShowingMissingAppearances(value)
	private.db.loot.showingMissingAppearances = value
end

function RSConfigDB.IsShowingMissingDrakewatcher()
	return private.db.loot.showingMissingDrakewatcher
end

function RSConfigDB.SetShowingMissingDrakewatcher(value)
	private.db.loot.showingMissingDrakewatcher = value
end

---============================================================================
-- Collection filters
---============================================================================

function RSConfigDB.SetAutoFilteringOnCollect(value)
	private.db.collections.autoFilteringOnCollect = value
end

function RSConfigDB.IsAutoFilteringOnCollect()
	return private.db.collections.autoFilteringOnCollect
end

function RSConfigDB.SetCreateProfileBackup(value)
	private.db.collections.createProfileBackup = value
end

function RSConfigDB.IsCreateProfileBackup()
	return private.db.collections.createProfileBackup
end

function RSConfigDB.SetSearchingPets(value)
	private.db.collections.searchingPets = value
end

function RSConfigDB.IsSearchingPets()
	return private.db.collections.searchingPets
end

function RSConfigDB.SetSearchingMounts(value)
	private.db.collections.searchingMounts = value
end

function RSConfigDB.IsSearchingMounts()
	return private.db.collections.searchingMounts
end

function RSConfigDB.SetSearchingToys(value)
	private.db.collections.searchingToys = value
end

function RSConfigDB.IsSearchingToys()
	return private.db.collections.searchingToys
end

function RSConfigDB.SetSearchingAppearances(value)
	private.db.collections.searchingAppearances = value
end

function RSConfigDB.IsSearchingAppearances()
	return private.db.collections.searchingAppearances
end

function RSConfigDB.SetSearchingDrakewatcher(value)
	private.db.collections.searchingDrakewatcher = value
end

function RSConfigDB.IsSearchingDrakewatcher()
	return private.db.collections.searchingDrakewatcher
end

function RSConfigDB.SetShowFiltered(value)
	private.db.collections.showFiltered = value
end

function RSConfigDB.IsShowFiltered()
	return private.db.collections.showFiltered
end

function RSConfigDB.SetShowWithoutCollectibles(value)
	private.db.collections.showWithoutCollectibles = value
end

function RSConfigDB.IsShowWithoutCollectibles()
	return private.db.collections.showWithoutCollectibles
end

function RSConfigDB.SetShowDead(value)
	private.db.collections.showDead = value
end

function RSConfigDB.IsShowDead()
	return private.db.collections.showDead
end

function RSConfigDB.SetExplorerContinentMapID(value)
	private.db.collections.continentMapID = value
end

function RSConfigDB.GetExplorerContinenMapID()
	return private.db.collections.continentMapID
end

function RSConfigDB.SetExplorerMapID(value)
	private.db.collections.mapID = value
end

function RSConfigDB.GetExplorerMapID()
	return private.db.collections.mapID
end

function RSConfigDB.SetLockingCurrentMap(value)
	private.db.collections.lockingMap = value
end

function RSConfigDB.IsLockingCurrentMap()
	return private.db.collections.lockingMap
end

function RSConfigDB.ResetLootFilters()
	-- Quality Uncommon and supperior
	RSConfigDB.SetLootFilterMinQuality(Enum.ItemQuality.Poor)
	
	-- Type/Subtype
	for mainTypeID, subtypesIDs in pairs(private.ITEM_CLASSES) do
		for _, typeID in pairs (subtypesIDs) do
			RSConfigDB.SetLootFilterByCategory(mainTypeID, typeID, true)
		end
	end
	
	-- Custom filters
	RSConfigDB.SetFilteringByExplorerResults(false)
	RSConfigDB.SetFilteringLootByNotMatchingClass(false)
	RSConfigDB.SetFilteringLootByNotMatchingFaction(true)
	RSConfigDB.SetFilteringByExplorerResults(false)
end

---============================================================================
-- Loot tooltips
---============================================================================

function RSConfigDB.IsShowingLootTooltipsCommands()
	return private.db.loot.tooltipsCommands
end

function RSConfigDB.SetShowingLootTooltipsCommands(value)
	private.db.loot.tooltipsCommands = value
end

function RSConfigDB.IsShowingLootCanimogitTooltip()
	return private.db.loot.tooltipsCanImogit
end

function RSConfigDB.SetShowingLootCanimogitTooltip(value)
	private.db.loot.tooltipsCanImogit = value
end

function RSConfigDB.IsShowingCovenantRequirement()
	return private.db.loot.covenantRequirement
end

function RSConfigDB.SetShowingCovenantRequirement(value)
	private.db.loot.covenantRequirement = value
end

---============================================================================
-- Navigator options
---============================================================================

function RSConfigDB.IsNavigationLockEnabled()
	return private.db.display.navigationLockEntity
end

function RSConfigDB.SetNavigationLockEnabled(value)
	private.db.display.navigationLockEntity = value
end

---============================================================================
-- Waypoints
---============================================================================

function RSConfigDB.IsWaypointsSupportEnabled()
	return private.db.general.enableWaypointsSupport
end

function RSConfigDB.SetWaypointsSupportEnabled(value)
	private.db.general.enableWaypointsSupport = value
end

function RSConfigDB.IsAddingWaypointsAutomatically()
	return private.db.general.autoWaypoints
end

function RSConfigDB.SetAddingWaypointsAutomatically(value)
	private.db.general.autoWaypoints = value
end

function RSConfigDB.IsTomtomSupportEnabled()
	return TomTom and private.db.general.enableTomtomSupport
end

function RSConfigDB.SetTomtomSupportEnabled(value)
	private.db.general.enableTomtomSupport = TomTom and value
end

function RSConfigDB.IsAddingTomtomWaypointsAutomatically()
	return TomTom and private.db.general.autoTomtomWaypoints
end

function RSConfigDB.SetAddingTomtomWaypointsAutomatically(value)
	private.db.general.autoTomtomWaypoints = TomTom and value
end

---============================================================================
-- Worldmap searcher
---============================================================================

function RSConfigDB.SetShowingWorldMapSearcher(value)
	private.db.map.showingWorldMapSearcher = value
end

function RSConfigDB.IsShowingWorldMapSearcher()
	return private.db.map.showingWorldMapSearcher
end

function RSConfigDB.SetClearingWorldMapSearcher(value)
	private.db.map.cleanWorldMapSearcherOnChange = value
end

function RSConfigDB.IsClearingWorldMapSearcher()
	return private.db.map.cleanWorldMapSearcherOnChange
end

---============================================================================
-- Worldmap waypoints
---============================================================================

function RSConfigDB.IsAddingWorldMapTomtomWaypoints()
	return TomTom and private.db.map.waypointTomtom
end

function RSConfigDB.SetAddingWorldMapTomtomWaypoints(value)
	private.db.map.waypointTomtom = TomTom and value
end

function RSConfigDB.IsAddingWorldMapIngameWaypoints()
	return private.db.map.waypointIngame
end

function RSConfigDB.SetAddingWorldMapIngameWaypoints(value)
	private.db.map.waypointIngame = value
end

---============================================================================
-- WorldMap icons scale
---============================================================================

function RSConfigDB.GetIconsWorldMapScale()
	return private.db.map.scale
end

function RSConfigDB.SetIconsWorldMapScale(value)
	private.db.map.scale = value
end

---============================================================================
-- Worldmap tooltips
---============================================================================

function RSConfigDB.GetWorldMapTooltipsScale()
	return private.db.map.tooltipsScale
end

function RSConfigDB.SetWorldMapTooltipsScale(value)
	private.db.map.tooltipsScale = value
end

function RSConfigDB.IsShowingTooltipsOnIngameIcons()
	return private.db.map.tooltipsOnIngameIcons
end

function RSConfigDB.SetShowingTooltipsOnIngameIcons(value)
	private.db.map.tooltipsOnIngameIcons = value
end

function RSConfigDB.IsShowingTooltipsAchievements()
	return private.db.map.tooltipsAchievements
end

function RSConfigDB.SetShowingTooltipsAchievements(value)
	private.db.map.tooltipsAchievements = value
end

function RSConfigDB.IsShowingTooltipsNotes()
	return private.db.map.tooltipsNotes
end

function RSConfigDB.SetShowingTooltipsNotes(value)
	private.db.map.tooltipsNotes = value
end

function RSConfigDB.IsShowingTooltipsLoot()
	return private.db.map.tooltipsLoot
end

function RSConfigDB.SetShowingTooltipsLoot(value)
	private.db.map.tooltipsLoot = value
end

function RSConfigDB.IsShowingLootOnWorldMap()
	return private.db.loot.displayLootOnMap
end

function RSConfigDB.SetShowingLootOnWorldMap(value)
	private.db.loot.displayLootOnMap = value
end

function RSConfigDB.IsShowingTooltipsSeen()
	return private.db.map.tooltipsSeen
end

function RSConfigDB.SetShowingTooltipsSeen(value)
	private.db.map.tooltipsSeen = value
end

function RSConfigDB.IsShowingTooltipsState()
	return private.db.map.tooltipsState
end

function RSConfigDB.SetShowingTooltipsState(value)
	private.db.map.tooltipsState = value
end

function RSConfigDB.IsShowingTooltipsCommands()
	return private.db.map.tooltipsCommands
end

function RSConfigDB.SetShowingTooltipsCommands(value)
	private.db.map.tooltipsCommands = value
end

---============================================================================
-- Worldmap loot tooltips
---============================================================================

function RSConfigDB.GetWorldMapLootAchievTooltipsScale()
	if (private.db.map.lootAchievTooltipsScale) then
		return private.db.map.lootAchievTooltipsScale
	end
	return RSConfigDB.GetWorldMapTooltipsScale()
end

function RSConfigDB.SetWorldMapLootAchievTooltipsScale(value)
	private.db.map.lootAchievTooltipsScale = value
end

function RSConfigDB.GetWorldMapLootAchievTooltipPosition()
	return private.db.map.lootAchievementsPosition
end 

function RSConfigDB.SetWorldMapLootAchievTooltipPosition(value)
	private.db.map.lootAchievementsPosition = value
end 

---============================================================================
-- Worldmap overlay
---============================================================================

function RSConfigDB.SetWorldMapOverlayColour(id, r, g, b)
	if (not private.db.map["overlayColour"..id]) then
		private.db.map["overlayColour"..id] = {}
	end
	
	private.db.map["overlayColour"..id] = { r, g, b }
end

function RSConfigDB.GetWorldMapOverlayColour(id)
	if (id and private.db.map["overlayColour"..id]) then
		return unpack(private.db.map["overlayColour"..id])
	end
	
	return nil
end

---============================================================================
-- Worldmap animations
---============================================================================

function RSConfigDB.IsShowingAnimationForNpcs()
	return private.db.map.animationNpcs
end

function RSConfigDB.SetShowingAnimationForNpcs(value)
	private.db.map.animationNpcs = value
end

function RSConfigDB.GetAnimationForNpcs()
	return private.db.map.animationNpcsType
end

function RSConfigDB.SetAnimationForNpcs(value)
	private.db.map.animationNpcsType = value
end

function RSConfigDB.IsShowingAnimationForContainers()
	return private.db.map.animationContainers
end

function RSConfigDB.SetShowingAnimationForContainers(value)
	private.db.map.animationContainers = value
end

function RSConfigDB.GetAnimationForContainers()
	return private.db.map.animationContainersType
end

function RSConfigDB.SetAnimationForContainers(value)
	private.db.map.animationContainersType = value
end

function RSConfigDB.IsShowingAnimationForEvents()
	return private.db.map.animationEvents
end

function RSConfigDB.SetShowingAnimationForEvents(value)
	private.db.map.animationEvents = value
end

function RSConfigDB.GetAnimationForEvents()
	return private.db.map.animationEventsType
end

function RSConfigDB.SetAnimationForEvents(value)
	private.db.map.animationEventsType = value
end

function RSConfigDB.IsShowingAnimationForVignettes()
	return private.db.map.animationVignettes
end

function RSConfigDB.SetShowingAnimationForVignettes(value)
	private.db.map.animationVignettes = value
end

---============================================================================
-- Worldmap reputation
---============================================================================

function RSConfigDB.IsHighlightingReputation()
	return private.db.map.highlightReputation
end

function RSConfigDB.SetHighlightingReputation(value)
	private.db.map.highlightReputation = value
end
