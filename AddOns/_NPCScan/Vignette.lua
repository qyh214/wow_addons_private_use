--Code to handle triggering alerts off of Vignettes and map based icon events

-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local pairs = _G.pairs

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...
local L = private.L

local Debug = private.Debug
local Toast = _G.LibStub("LibToast-1.0")

-------------------------------------------------------------------------------
-- Variables.
-------------------------------------------------------------------------------
local EVENT_WARNING_SOUND = "Sound\\Spells\\PVPFlagTaken.ogg"
local ANTI_SPAM_DELAY  = 300
local TANAAN_ZONE_ID = 945
local VIGNETTE_MOB_ID = 41
local VIGNETTE_EVENT_MOB_ID = 45
local MAP_EVENT_ICON = 45  --Crossed Swords on Diamond

local lastVignetteId = 0
local vignetteDelay
local vignetteFoundCount = 0
local antiSpamList = {}
local lastAntiSpam = 0

private.VFrame = _G.CreateFrame("Frame")
private.VFrame:RegisterEvent("VIGNETTE_ADDED")
private.VFrame:RegisterEvent("VIGNETTE_REMOVED")
private.VFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
private.VFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
private.VFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

private.VFrame:SetScript("OnEvent", function(self, event_name, ...)
	if self[event_name] then
		return self[event_name](self, event_name, ...)
	end
end)

function private.VFrame:ZONE_CHANGED_NEW_AREA(event, ...)
	if vignetteDelay then
		Debug("Releasing Delay")
		private.VFrame:VIGNETTE_ADDED("VIGNETTE_ADDED", vignetteDelay)
		vignetteDelay = nil
	end

	local currentZone
	if WorldMapFrame:IsVisible() then--World Map is open
		local Z =_G.GetCurrentMapAreaID()
		_G.SetMapToCurrentZone()
		currentZone = _G.GetCurrentMapAreaID()
		if currentZone ~= Z then
			SetMapByID(Z)--Restore old map settings if they differed to what they were prior to forcing mapchange and user has map open.
		end
	else--Map is not open, no reason to go extra miles, just force map to right zone and get right info.
		_G.SetMapToCurrentZone()
		currentZone = GetCurrentMapAreaID()--Get right info after we set map to right place.
	end

	if currentZone == TANAAN_ZONE_ID then --tannan 
		self:RegisterEvent("WORLD_MAP_UPDATE")
	else
		self:UnregisterEvent("WORLD_MAP_UPDATE")
	end
end

--Clears the last found Vignette mob only after combat has ended.
function private.VFrame:PLAYER_REGEN_ENABLED(event, ...)
	if vignetteFoundCount == 0 then
		if not _G.InCombatLockdown() then
			lastVignetteId = 0
		end
	end
end

function private.VFrame:PLAYER_ENTERING_WORLD()
	private.VFrame:ZONE_CHANGED_NEW_AREA()
end

function private.VFrame:WORLD_MAP_UPDATE()
	local numLandmarks = GetNumMapLandmarks()
		for i= 1, numLandmarks do
			local name, _, textureIndex = GetMapLandmarkInfo(i)
			
			if textureIndex == MAP_EVENT_ICON then 
				local alertText = L.EVENT_ACTIVE:format(name)

				if private.AntiSpam(ANTI_SPAM_DELAY, name) then
					private.Print(alertText, _G.RED_FONT_COLOR)
					if private.Options.ShowAlertAsToast and alertText then
						Toast:Spawn("_NPCScanAlertToast", alertText)
					end
					_G.PlaySoundFile(EVENT_WARNING_SOUND, "master")
					_G.RaidNotice_AddMessage(RaidWarningFrame, alertText, ChatTypeInfo["RAID_WARNING"]);
				end
			end
		end
end

-- An anti spam function to throttle spammy events
-- @param time the time to wait between two events (optional, default 2.5 seconds)
-- @param id the id to distinguish different events (optional, only necessary if your mod keeps track of two different spam events at the same time)
function private.AntiSpam(time, id)
	if _G.GetTime() - (id and (antiSpamList["lastAntiSpam" .. tostring(id)] or 0) or lastAntiSpam or 0) > (time or 2.5) then
		if id then
			antiSpamList["lastAntiSpam" .. tostring(id)] = _G.GetTime()
		else
			lastAntiSpam = _G.GetTime()
		end
		return true
	else
		return false
	end
end

--Delays alerts on login untill the world so current zone can be properly detected
local function VignetteZoneCheck()
	local mapId = _G.GetCurrentMapAreaID()
	local zoneName = _G.GetMapNameByID(mapId)

	if not zoneName then
		vignetteDelay = true
		private.Debug("Build List Delayed")
		return false
	else
		return true
	end
end

--Checks to see if achievement mobs are being tracked and filters by zone if an achievement is disabled.
local function VignetteFilterByAchievement()
	local currentZone = _G.GetCurrentMapAreaID()

	if not private.OptionsCharacter.Achievements[private.ACHIEVEMENT_IDS.ONE_MANY_ARMY] and currentZone == private.ZONE_IDS.VALE_OF_ETERNAL_BLOSSOMS then
		Debug("ONE_MANY_ARMY not tracked")
		return false
	elseif not private.OptionsCharacter.Achievements[private.ACHIEVEMENT_IDS.CHAMPIONS_OF_LEI_SHEN] and currentZone == private.ZONE_IDS.ISLE_OF_THUNDER then
		Debug("CHAMPIONS_OF_LEI_SHEN not tracked")
		return false
	elseif not private.OptionsCharacter.Achievements[private.ACHIEVEMENT_IDS.TIMELESS_CHAMPION] and currentZone == private.ZONE_IDS.TIMELESS_ISLE then
		Debug("TIMELESS_CHAMPION not tracked")
		return false
	elseif not private.OptionsCharacter.Achievements[private.ACHIEVEMENT_IDS.GLORIOUS] and (currentZone ~= private.ZONE_IDS.VALE_OF_ETERNAL_BLOSSOMS and currentZone ~= private.ZONE_IDS.TIMELESS_ISLE and currentZone ~= private.ZONE_IDS.ISLE_OF_THUNDER) then
		Debug("GLORIOUS not tracked")
		return false
	else
		Debug("Tracking Mob")
		return true
	end
end

--Updates button to display actual target info
function private.SetVignetteTarget()
	local npcName = _G.GetUnitName("target")
	local npcId = private.NPC_NAME_TO_ID[npcName]

	if _G.UnitIsDead("target") and vignetteFoundCount > 1 then
		lastVignetteId = npcId
		private.GenerateTargetMacro(npcId)
		private.Button:Update(npcId, "Vignette Mob", "Unknown Vignette")
		Debug("Mob Dead")
		return
	end

	if npcId then
		if _G.InCombatLockdown() then
			Debug("Combat LockDown")
			private.Button.PendingID, private.Button.PendingName, private.Button.PendingSource = npcId, npcName, "Vignette Mob"
		else
			private.Button:Update(npcId, npcName, "Vignette Mob")
		end
		lastVignetteId = npcId
	end

	Debug("Last ID: " .. lastVignetteId)
end

-- Vignette alert, Appears to be Fixed in WoD will need to monitor
-- Refrence: http://wowpedia.org/API_C_Vignettes.GetVignetteInfoFromInstanceID
function private.VFrame:VIGNETTE_ADDED(event, instanceId, ...)
	vignetteFoundCount = vignetteFoundCount + 1
	Debug("Found: %d  Last ID: %d", vignetteFoundCount, lastVignetteId)

	if not private.OptionsCharacter.TrackVignettes or
		not instanceId or
		not VignetteFilterByAchievement() or
		-- private.Button:IsShown() or
		_G.GetUnitName("target") == lastVignetteId or
		not VignetteZoneCheck or
		_G.UnitIsDeadOrGhost("player")  or
		not private.AntiSpam(ANTI_SPAM_DELAY, instanceId) then
		return
	end

	-- iconId seems to be 40:chests, 41:mobs, 45: Tannan special rares
	local x, y, name, iconId = _G.C_Vignettes.GetVignetteInfoFromInstanceID(instanceId)
	local npcId = private.NPC_NAME_TO_ID[name]
	local alertText = nil

	if not iconId then --Use case for broken or unknown Mob Info 
		Debug("Null Mob Data Returned")
		alertText = L["FOUND_FORMAT"]:format("Vignette Mob")
		private.Button:SetNPC(29147, "Vignette Mob", "Unknown Vignette")
	elseif iconId == VIGNETTE_MOB_ID  or iconId == VIGNETTE_EVENT_MOB_ID then  --Use Case if API returns Mob Info
		Debug("Correct Mob Data Returned")
		--Check to see if mob is on the ignore list
		if _G._NPCScanOptions.IgnoreList.NPCs[npcId] then
			Debug("Ignored Mob")
			return
		end
		--Check for Vignette mobs that dont exist in our DB
		if npcId then
			private.Button:SetNPC(npcId, name, "Vignette Mob")
		else
			private.Button:SetNPC(29147, name, "Unknown Vignette")
		end
		alertText = L["FOUND_FORMAT"]:format("Vignette Mob: "..name)
		--private.Button:SetNPC(private.NPC_NAME_TO_ID[name], name, "Vignette Mob")
	else -- All other cases
		Debug("Untracked Vigenette")
	end

	if private.Options.ShowAlertAsToast and alertText then
		Toast:Spawn("_NPCScanAlertToast", alertText)
	elseif alertText then
		private.Print(alertText, _G.GREEN_FONT_COLOR)
	end
end

--Clears last seen mob when vignette is removed from map
function private.VFrame:VIGNETTE_REMOVED(event, instanceId, ...)
	vignetteFoundCount = vignetteFoundCount - 1
	if vignetteFoundCount == 0 then
		if not _G.InCombatLockdown() then
			lastVignetteId = 0
		end
	end
end




