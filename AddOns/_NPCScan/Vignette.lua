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
local TANAAN_ZONE_ID = 945
local VIGNETTE_MOB_ID = 41
local VIGNETTE_EVENT_MOB_ID = 45
local MAP_EVENT_ICON = 45  --Crossed Swords on Diamond
local BLOODMOON = private.L.NPCs["91200"]

local last_vignette_id = 0
local vignette_delay
local vignette_found_count = 0


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
	if vignette_delay then
		Debug("Releasing Delay")
		private.VFrame:VIGNETTE_ADDED("VIGNETTE_ADDED", vignette_delay)
		vignette_delay = nil
	end

	local current_zone
	if WorldMapFrame:IsVisible() then--World Map is open
		local Z =_G.GetCurrentMapAreaID()
		_G.SetMapToCurrentZone()
		current_zone = _G.GetCurrentMapAreaID()
		if current_zone ~= Z then
			SetMapByID(Z)--Restore old map settings if they differed to what they were prior to forcing mapchange and user has map open.
		end
	else--Map is not open, no reason to go extra miles, just force map to right zone and get right info.
		_G.SetMapToCurrentZone()
		current_zone = GetCurrentMapAreaID()--Get right info after we set map to right place.
	end

	if current_zone == TANAAN_ZONE_ID then
		self:RegisterEvent("WORLD_MAP_UPDATE")
	else
		self:UnregisterEvent("WORLD_MAP_UPDATE")
	end
end


--Clears the last found Vignette mob only after combat has ended.
function private.VFrame:PLAYER_REGEN_ENABLED(event, ...)
	if vignette_found_count == 0 then
		if not _G.InCombatLockdown() then
			last_vignette_id = 0
		end
	end
end


function private.VFrame:PLAYER_ENTERING_WORLD()
	private.VFrame:ZONE_CHANGED_NEW_AREA()
end

--Scans world map and looks at POI icons that relate to Hellbane mob events
function private.VFrame:WORLD_MAP_UPDATE()

	if not private.CharacterOptions.TrackHellbane then return end

	--Finds all POI landmarks on map
	local number_landmarks = GetNumMapLandmarks()
	for i = 1, number_landmarks do
		local name, _, textureIndex = GetMapLandmarkInfo(i)

		--Check to see if POI icon matches Hellbane event
		if textureIndex == MAP_EVENT_ICON then
			local alert_text = L.EVENT_ACTIVE:format(name)
			
			local BloodMoonEvent = string.find(name, BLOODMOON) --Determine if event has localized Blood Moon in name

			--Check spam delay and if event is not the Bloodmoon
			if private.AntiSpam(private.ANTI_SPAM_DELAY, name.."MapAlert") and not BloodMoonEvent then
				private.Print(alert_text, _G.RED_FONT_COLOR)
				if private.CharacterOptions.ShowAlertAsToast and alert_text then
					Toast:Spawn("_NPCScanAlertToast", alert_text)
				end
				_G.PlaySoundFile(EVENT_WARNING_SOUND, "master")
				_G.RaidNotice_AddMessage(RaidWarningFrame, alert_text, ChatTypeInfo["RAID_WARNING"])
			end
		end
	end
end


--Delays alerts on login untill the world so current zone can be properly detected
local function VignetteZoneCheck()
	local map_id = _G.GetCurrentMapAreaID()
	local zone_name = _G.GetMapNameByID(map_id)

	if not zone_name then
		vignette_delay = true
		private.Debug("Build List Delayed")
		return false
	else
		return true
	end
end


--Updates button to display actual target info
function private.SetVignetteTarget()
	local npc_name = _G.GetUnitName("target")
	local npc_id = private.NPC_NAME_TO_ID[npc_name]

	if _G.UnitIsDead("target") and vignette_found_count > 1 then
		last_vignette_id = npc_id
		private.GenerateTargetMacro(npc_id)
		private.Button:Update(npc_id, "Vignette Mob", "Unknown Vignette")
		Debug("Mob Dead")
		return
	end

	if npc_id then
		if _G.InCombatLockdown() then
			Debug("Combat LockDown")
			private.Button.PendingID, private.Button.PendingName, private.Button.PendingSource = npc_id, npc_name, "Vignette Mob"
		else
			private.Button:Update(npc_id, npc_name, "Vignette Mob")
		end
		last_vignette_id = npc_id
	end

	Debug("Last ID: " .. last_vignette_id)
end


-- Vignette alert, Appears to be Fixed in WoD will need to monitor
-- Refrence: http://wowpedia.org/API_C_Vignettes.GetVignetteInfoFromInstanceID
function private.VFrame:VIGNETTE_ADDED(event, instanceId, ...)
	vignette_found_count = vignette_found_count + 1
	Debug("Found: %d  Last ID: %d", vignette_found_count, last_vignette_id)
	local x, y, name, iconId = _G.C_Vignettes.GetVignetteInfoFromInstanceID(instanceId)

	if not private.CharacterOptions.TrackVignettes or
		not instanceId or
		_G.GetUnitName("target") == last_vignette_id or
		not VignetteZoneCheck or
		_G.UnitIsDeadOrGhost("player") or
		not private.AntiSpam(private.ANTI_SPAM_DELAY, name) then
		return false
	end

	-- iconId seems to be 40:chests, 41:mobs, 45: Tannan special rares
	local npc_id = private.NPC_NAME_TO_ID[name]
	local alert_text = nil

	if not iconId then --Use case for broken or unknown Mob Info
		Debug("Unknown Mob Data Returned")
		alert_text = L["FOUND_FORMAT"]:format("Vignette Mob")
		private.Button:SetNPC(29147, "Vignette Mob", "Unknown Vignette")
	elseif iconId == VIGNETTE_MOB_ID  or iconId == VIGNETTE_EVENT_MOB_ID then  --Use Case if API returns Mob Info
		Debug("Correct Mob Data Returned for "..name)

		--Check for Vignette mobs that dont exist in our DB
		if npc_id then
			Debug("ID found for "..private.NPC_NAME_TO_ID[name])
			--Check to see if mob is on the ignore list or not being currently tracked
			if _G._NPCScanOptions.IgnoreList.NPCs[npc_id] or not private.ScanIDs[npc_id] then
				Debug("Ignored Mob")
				return
			end
			private.Button:SetNPC(npc_id, name, "Vignette Mob")
		else
			Debug("No MobID found for "..name)
			private.Button:SetNPC(29147, name, "Unknown Vignette")
		end
		alert_text = L["FOUND_FORMAT"]:format("Vignette Mob: "..name)
		--private.Button:SetNPC(private.NPC_NAME_TO_ID[name], name, "Vignette Mob")
	else -- All other cases
		Debug("Untracked Vigenette")
	end

	if private.CharacterOptions.ShowAlertAsToast and alert_text then
		Toast:Spawn("_NPCScanAlertToast", alert_text)
	elseif alert_text then
		private.Print(alert_text, _G.GREEN_FONT_COLOR)
	end
end


--Clears last seen mob when vignette is removed from map
function private.VFrame:VIGNETTE_REMOVED(event, instanceId, ...)
	vignette_found_count = vignette_found_count - 1
	if vignette_found_count == 0 then
		if not _G.InCombatLockdown() then
			last_vignette_id = 0
		end
	end
end