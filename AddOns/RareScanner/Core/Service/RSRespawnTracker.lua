-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local RSRespawnTracker = private.NewLib("RareScannerRespawnTracker")

-- RareScanner database libraries
local RSNpcDB = private.ImportLib("RareScannerNpcDB")
local RSContainerDB = private.ImportLib("RareScannerContainerDB")
local RSEventDB = private.ImportLib("RareScannerEventDB")

-- RareScanner internal libraries
local RSConstants = private.ImportLib("RareScannerConstants")
local RSRoutines = private.ImportLib("RareScannerRoutines")
local RSLogger = private.ImportLib("RareScannerLogger")

-- RareScanner services
local RSEntityStateHandler = private.ImportLib("RareScannerEntityStateHandler")

-- Timers
local CHECK_RESPAWN_TIMER

---============================================================================
-- Tracks respawning
---============================================================================
		
local function CheckRespawnTimers(firstScan)
	local routines = {}

	local checkRespawnNpcsRoutine = RSRoutines.LoopRoutineNew()
	checkRespawnNpcsRoutine:Init(function() return RSNpcDB.GetAllNpcsKilledRespawnTimes() end, 20,
		function(context, npcID, respawnTime)
			local npcInfo = RSNpcDB.GetInternalNpcInfo(npcID)
		
			if (respawnTime > 0 and respawnTime < time()) then
				-- If the associated quest is completed it means that this rare NPC is still dead
				-- It's possible that the quest takes a little bit longer to reset, so check for this NPC later
				local hasRespawn = true
				if (npcInfo and npcInfo.questID) then
					if (firstScan or (not npcInfo.reset and not npcInfo.questReset and not npcInfo.weeklyReset)) then
						for _, questID in ipairs (npcInfo.questID) do
							if (C_QuestLog.IsQuestFlaggedCompleted(questID)) then
								-- Check this same NPC every 5 minutes during the next 15
								RSLogger:PrintDebugMessageEntityID(npcID, string.format("CheckRespawnTimers [NPC: %s], sigue muerto acorde a su quest [%s]", npcID, questID))
														
								--Check again until the threshold
								if (respawnTime + RSConstants.CHECK_RESPAWN_THRESHOLD < time()) then
									RSNpcDB.DeleteNpcKilled(npcID)
									RSEntityStateHandler.SetDeadNpc(npcID)
								end
								
								hasRespawn = false
								break
							-- If quest flagged as completed in the first scan, try again, the first time it could return wrong values
							elseif (firstScan) then
								hasRespawn = false
							end
						end
					end
				end
	
				if (hasRespawn) then
					RSLogger:PrintDebugMessageEntityID(npcID, string.format("CheckRespawnTimers [NPC: %s]. Respawn!", npcID))
					RSNpcDB.DeleteNpcKilled(npcID)
				end
			end
		end)
	tinsert(routines, checkRespawnNpcsRoutine)

	-- Look for containers that have already respawn
	local checkRespawnContainersRoutine = RSRoutines.LoopRoutineNew()
	checkRespawnContainersRoutine:Init(function() return RSContainerDB.GetAllContainersOpenedRespawnTimes() end, 20,
		function(context, containerID, respawnTime)
			local containerInfo = RSContainerDB.GetInternalContainerInfo(containerID)
				
			if (respawnTime > 0 and respawnTime < time()) then
				-- If the associated quest is completed it means that this container is still closed
				-- It's possible that the quest takes a little bit longer to reset, so check for this container later
				local hasRespawn = true
				if (containerInfo and containerInfo.questID) then
					if (firstScan or (not containerInfo.reset and not containerInfo.questReset and not containerInfo.weeklyReset)) then
						for _, questID in ipairs (containerInfo.questID) do
							if (C_QuestLog.IsQuestFlaggedCompleted(questID)) then
								RSLogger:PrintDebugMessage(string.format("CheckRespawnTimers [Contenedor: %s], sigue cerrado acorde a su quest [%s]", containerID, questID))
								
								--Check again until the threshold
								if (respawnTime + RSConstants.CHECK_RESPAWN_THRESHOLD < time()) then
									RSContainerDB.DeleteContainerOpened(containerID)
									RSEntityStateHandler.SetContainerOpen(containerID)
								end
								
								hasRespawn = false
								break
							-- If quest flagged as completed in the first scan, try again, the first time it could return wrong values
							elseif (firstScan) then
								hasRespawn = false
							end
						end
					end
				end
	
				if (hasRespawn) then
					RSLogger:PrintDebugMessage(string.format("CheckRespawnTimers [Contenedor: %s]. Respawn!", containerID))
					RSContainerDB.DeleteContainerOpened(containerID)
				end
			end
		end)
	tinsert(routines, checkRespawnContainersRoutine)

	-- Look for events that have already respawn
	local checkRespawnEventsRoutine = RSRoutines.LoopRoutineNew()
	checkRespawnEventsRoutine:Init(function() return RSEventDB.GetAllEventsCompletedRespawnTimes() end, 20,
		function(context, eventID, respawnTime)
			local eventInfo = RSEventDB.GetInternalEventInfo(eventID)
			
			local hasRespawn = true
			if (eventInfo and eventInfo.questID) then
				if (firstScan or (not eventInfo.reset and not eventInfo.questReset and not eventInfo.weeklyReset and not eventInfo.resetTimer)) then
					for _, questID in ipairs (eventInfo.questID) do
						if (C_QuestLog.IsQuestFlaggedCompleted(questID)) then
							RSLogger:PrintDebugMessage(string.format("CheckRespawnTimers [Evento: %s], sigue completo acorde a su quest [%s]", eventID, questID))
																			
							--Check again until the threshold
							if (respawnTime + RSConstants.CHECK_RESPAWN_THRESHOLD < time()) then
								RSEventDB.DeleteEventCompleted(eventID)
								RSEntityStateHandler.SetEventCompleted(eventID)
							end
							
							hasRespawn = false
							break
						-- If quest flagged as completed in the first scan, try again later, the first time it could return wrong values
						elseif (firstScan) then
							hasRespawn = false
						end
					end
				end
			end

			if (hasRespawn) then
				RSLogger:PrintDebugMessage(string.format("CheckRespawnTimers [Evento: %s]. Respawn!", eventID))
				RSEventDB.DeleteEventCompleted(eventID)
			end
		end)
	tinsert(routines, checkRespawnEventsRoutine)
	
	local chainRoutines = RSRoutines.ChainLoopRoutineNew()
	chainRoutines:Init(routines)
	chainRoutines:Run(function(context) end)
end

function RSRespawnTracker.Init()
	CheckRespawnTimers(true)

	if (not CHECK_RESPAWN_TIMER) then
		CHECK_RESPAWN_TIMER = C_Timer.NewTicker(RSConstants.CHECK_RESPAWN_TIMER, function()
			CheckRespawnTimers()
		end)
	end
	
	-- Check again just in case some NPCs were tagged as killed for ever and they 
	for npcID, respawnTime in pairs (RSNpcDB.GetAllNpcsKilledRespawnTimes()) do
		local npcInfo = RSNpcDB.GetInternalNpcInfo(npcID)
		
		-- If it has a quest check again just in case it was tagged as dead by mistake
		if (respawnTime == RSConstants.ETERNAL_DEATH) then
			if (npcInfo and npcInfo.questID) then
				for _, questID in ipairs (npcInfo.questID) do
					if (not C_QuestLog.IsQuestFlaggedCompleted(questID)) then
						RSNpcDB.DeleteNpcKilled(npcID)
						RSEntityStateHandler.SetDeadNpc(npcID)
						RSLogger:PrintDebugMessageEntityID(npcID, string.format("CheckRespawnTimers [NPC: %s]. Respawn!", npcID))
					end
				end
			end
		end
	end
	
	for containerID, respawnTime in pairs (RSContainerDB.GetAllContainersOpenedRespawnTimes()) do
		local containerInfo = RSContainerDB.GetInternalContainerInfo(containerID)
		
		-- If it has a quest check again just in case it was tagged as opened by mistake
		if (respawnTime == RSConstants.ETERNAL_OPENED) then
			if (containerInfo and containerInfo.questID) then
				for _, questID in ipairs (containerInfo.questID) do
					if (not C_QuestLog.IsQuestFlaggedCompleted(questID)) then
						RSContainerDB.DeleteContainerOpened(containerID)
						RSEntityStateHandler.SetContainerOpen(containerID)
						RSLogger:PrintDebugMessage(string.format("CheckRespawnTimers [Contenedor: %s]. Respawn!", containerID))
					end
				end
			end
		end
	end	
end
