-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local RSTargetUnitTracker = private.NewLib("RareScannerTargetUnitTracker")

-- RareScanner database libraries
local RSNpcDB = private.ImportLib("RareScannerNpcDB")
local RSConfigDB = private.ImportLib("RareScannerConfigDB")
local RSMapDB = private.ImportLib("RareScannerMapDB")

-- RareScanner internal libraries
local RSConstants = private.ImportLib("RareScannerConstants")
local RSLogger = private.ImportLib("RareScannerLogger")
local RSRoutines = private.ImportLib("RareScannerRoutines")
local RSUtils = private.ImportLib("RareScannerUtils")

-- Timers
local CHECK_TARGETS_TIMER

---============================================================================
-- Get NPC IDs
---============================================================================

local previousMapID
local cachedNpcIDs
local recentlySeen = {}

local function GetMapNpcs()
	-- Disable alerts for rare NPCs
	if (not RSConfigDB.IsScanningForNpcs()) then
		RSLogger:PrintDebugMessage("Desactivado TargetUnit por haber deshabilitado alertas de NPCs")
		return nil
	end
			
	-- Gets MAPID from players position
	local mapID = C_Map.GetBestMapForUnit("player")
	if (not mapID or mapID == 0) then
		return nil
	end
	
	-- Disable alerts for filtered zones
	if (RSConfigDB.IsZoneFiltered(mapID) or RSConfigDB.IsZoneFilteredOnlyAlerts(mapID)) then
		RSLogger:PrintDebugMessage(string.format("Desactivado TargetUnit en esta zona [%s]", mapID))
		return nil
	end

	-- If same zone return already cached
	if (cachedNpcIDs and previousMapID and previousMapID == mapID) then
		return cachedNpcIDs, mapID, false
	end
	
	-- Otherwise refresh cache
	cachedNpcIDs = {}
	previousMapID = mapID
	
	-- Gets NPCs in the map
	RSLogger:PrintDebugMessage("TargetUnit refrescando lista")
	if (RSMapDB.IsZoneWithoutVignette(mapID)) then
		cachedNpcIDs = RSNpcDB.GetNpcIDsByMapID(mapID, false)
	else
		cachedNpcIDs = RSNpcDB.GetNpcIDsByMapID(mapID, true)
	end
	
	return cachedNpcIDs, mapID, true
end

---============================================================================
-- Event: ADDON_ACTION_FORBIDDEN
-- Fired when TargetUnit actually tries to target a NPC
---============================================================================

local npcFound = false
local function OnAddonActionForbidden(addonName, functionName)
	if (addonName == 'RareScanner' and functionName == 'TargetUnit()') then
		npcFound = true
	end
end

---============================================================================
-- Routine to track NPCs
---============================================================================

local checkUnitsRoutine
local unitTargetFrame = CreateFrame("FRAME");

local function CloseErrorPopUp()
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if (frame:IsShown()) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if (standardDialog) then
				local OnCancel = standardDialog.OnCancel;
				local noCancelOnEscape = standardDialog.noCancelOnEscape;
				if ( OnCancel and not noCancelOnEscape) then
					OnCancel(frame, frame.data, "clicked");
				end
				frame:Hide();
			else
				StaticPopupSpecial_Hide(frame);
			end
		end
	end
end

local function KeepRunningRoutine(rareScannerButton, npcIDs, mapID)
	checkUnitsRoutine:Run(function(context, index)
		local npcID = npcIDs[index]
		
		-- If NPC is filtered
		if (RSConfigDB.IsNpcFiltered(npcID)) then
			RSLogger:PrintDebugMessage(string.format("Desactivado TargetUnit para este NPC [%s] por estar filtrando (completo)", npcID))
		-- If NPC zone is filtered
		elseif (RSConfigDB.IsEntityZoneFilteredOnlyAlerts(npcID, RSConstants.NPC_VIGNETTE)) then
			RSLogger:PrintDebugMessage(string.format("Desactivado TargetUnit para este NPC [%s] por estar filtrando su zona [%s]", npcID, mapID))
		-- If NPC is recently seen
		elseif (recentlySeen[npcID]) then
			RSLogger:PrintDebugMessage(string.format("Desactivado TargetUnit para este NPC [%s] por haberse encontrado recientemente", npcID))
		-- Otherwise try to find it
		else
			local npcName = RSNpcDB.GetNpcName(npcIDs[index])
			if (npcName) then
				TargetUnit(npcName)
				if (npcFound) then
					-- Hide error message
					-- WATCH OUT! This might produce taint
					CloseErrorPopUp()
					
					local x, y = RSNpcDB.GetBestInternalNpcCoordinates(npcID, mapID)
					rareScannerButton:SimulateRareFound(npcID, nil, RSNpcDB.GetNpcName(npcID), x, y, RSConstants.NPC_VIGNETTE)
					recentlySeen[npcID] = time() + RSConstants.RECENTLY_SEEN_RESET_TIMER
					npcFound = false
				end
			end
		end
	end)
end

local function CheckUnits(rareScannerButton)
	-- If tracker disabled
	if (not RSConfigDB.IsScanningTargetUnit()) then
		return
	end

	-- Gets NPCs in the current map
	local npcIDs, mapID, newMap = GetMapNpcs()
	if (not npcIDs) then
		return
	end
	
	if (checkUnitsRoutine and checkUnitsRoutine:IsRunning()) then
		KeepRunningRoutine(rareScannerButton, npcIDs, mapID)
		return
	end
	
	-- Gets MAPID from players position
	-- Launches new routine
	if (newMap) then
		if (not checkUnitsRoutine) then
			checkUnitsRoutine = RSRoutines.LoopIndexRoutineNew()
		end
		checkUnitsRoutine:Init(function() return npcIDs end, 10)
	end
	
	checkUnitsRoutine:Reset()
end

---============================================================================
-- Initialize ticker
---============================================================================

function RSTargetUnitTracker.Init(rareScannerButton)	
	unitTargetFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	unitTargetFrame:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_ACTION_FORBIDDEN") then
			OnAddonActionForbidden(...)
		end
	end)
	
	C_Timer.NewTicker(RSConstants.CHECK_TARGETS_TIMER, function()
		CheckUnits(rareScannerButton)
	end)
	
	C_Timer.NewTicker(RSConstants.CHECK_RESET_RECENTLY_SEEN_TIMER, function()
		for npcID, timer in pairs(recentlySeen) do
			if (time() > timer) then
				recentlySeen[npcID] = nil
			end
		end
	end)
end

---============================================================================
-- Refresh
---============================================================================

function RSTargetUnitTracker.Refresh()
	previousMapID = nil
end
