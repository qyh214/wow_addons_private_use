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
local RSLogger = private.ImportLib("RareScannerLogger")

-- RareScanner services
local RSEntityStateHandler = private.ImportLib("RareScannerEntityStateHandler")

-- Timers
local CHECK_RESPAWN_TIMER

---============================================================================
-- Tracks respawning
---============================================================================

local function CheckRespawnTimers(firstScan)
	-- Look for NPCs that have already respawn
	for npcID, respawnTime in pairs (RSNpcDB.GetAllNpcsKilledRespawnTimes()) do
		if (respawnTime > 0 and respawnTime < time()) then
			-- If the associated quest is completed it means that this rare NPC is still dead
			-- It's possible that the quest takes a little bit longer to reset, so check for this NPC later
			local npcInfo = RSNpcDB.GetInternalNpcInfo(npcID)
			local hasRespawn = true
			if (npcInfo and npcInfo.questID) then
				if (firstScan or (not npcInfo.reset and not npcInfo.questReset and not npcInfo.weeklyReset and not npcInfo.resetTimer)) then
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
	end

	-- Look for containers that have already respawn
	for containerID, respawnTime in pairs (RSContainerDB.GetAllContainersOpenedRespawnTimes()) do
		if (respawnTime > 0 and respawnTime < time()) then
			-- If the associated quest is completed it means that this container is still closed
			-- It's possible that the quest takes a little bit longer to reset, so check for this container later
			local containerInfo = RSContainerDB.GetInternalContainerInfo(containerID)
			local hasRespawn = true
			if (containerInfo and containerInfo.questID) then
				if (firstScan or (not containerInfo.reset and not containerInfo.questReset and not containerInfo.weeklyReset and not containerInfo.resetTimer)) then
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
	end

	-- Look for events that have already respawn
	for eventID, respawnTime in pairs (RSEventDB.GetAllEventsCompletedRespawnTimes()) do
		if (respawnTime > 0 and respawnTime < time()) then
			-- If the associated quest is completed it means that this event is still completed
			-- It's possible that the quest takes a little bit longer to reset, so check for this event later
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
		end
	end
end

function RSRespawnTracker.Init()
	CheckRespawnTimers(true)

	if (not CHECK_RESPAWN_TIMER) then
		CHECK_RESPAWN_TIMER = C_Timer.NewTicker(RSConstants.CHECK_RESPAWN_TIMER, function()
			CheckRespawnTimers()
		end)
	end
end
