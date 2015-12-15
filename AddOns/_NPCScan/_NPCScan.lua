-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local next = _G.next
local pairs = _G.pairs
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type

-- Libraries
local string = _G.string
local table = _G.table


-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...

local Dialog = _G.LibStub("LibDialog-1.0")
local Toast = _G.LibStub("LibToast-1.0")

local L = private.L
_G._NPCScan = private

local debugger -- Only defined if needed.

-- Create a new Add-on object using AceAddon for Profile DB
private.Ace = LibStub("AceAddon-3.0"):NewAddon(FOLDER_NAME)

private.Frame = _G.CreateFrame("Frame")
private.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
private.Frame:RegisterEvent("PLAYER_LEAVING_WORLD")
private.Frame:RegisterEvent("PLAYER_UPDATE_RESTING")
private.Frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
private.Frame:RegisterEvent("LOOT_CLOSED")

private.Frame:SetScript("OnEvent", function(self, event_name, ...)
	if self[event_name] then
		return self[event_name](self, event_name, ...)
	end
end)

private.Updater = private.Frame:CreateAnimationGroup()
private.Updater.UpdateRate = 0.5
private.Updater:CreateAnimation("Animation"):SetDuration(private.Updater.UpdateRate)
private.Updater:SetLooping("REPEAT")


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------
local DB_VERSION = 3
local ISLE_OF_THUNDER_MAP_ID = 1064
local DARKMOON_ISLAND_MAP_ID = 947
local PLAYER_CLASS = _G.select(2, _G.UnitClass("player"))
local PLAYER_FACTION = _G.UnitFactionGroup("player")
local ANTI_SPAM_DELAY = 300

--[===[@debug@
ANTI_SPAM_DELAY  = 30
--@end-debug@]===]
private.ANTI_SPAM_DELAY = ANTI_SPAM_DELAY


-------------------------------------------------------------------------------
-- Variables.
-------------------------------------------------------------------------------
_NPCScanOptions = {}
private.CharacterOptions = {}

local GlobalOptionsDefault = {
	Version = DB_VERSION,
	AlertSound = nil, -- Default sound
	ChangeAlertShown = false, -- Has WoD changes alert been shown yet
	NPCs = {
		[50409] = private.L.NPCs["50409"], --"Mysterious Camel Figurine",
		[50410] = private.L.NPCs["50410"], --"Mysterious Camel Figurine",
		[64004] = private.L.NPCs["64004"], --"Ghostly Pandaren Fisherman",
		[64191] = private.L.NPCs["64191"], --"Ghostly Pandaren Craftsman",
	},
	NPCWorldIDs = {
		[50409] = private.ZONE_NAMES.KALIMDOR,
		[50410] = private.ZONE_NAMES.KALIMDOR,
		[64004] = private.ZONE_NAMES.PANDARIA,
		[64191] = private.ZONE_NAMES.PANDARIA,
	},
	IgnoreList = {
		NPCs = {},
		MapName = {},
		WorldID = {},
	},
	CacheWarnings = nil,
	ShowAlertAsToast = nil,
	PersistentToast = nil,
}


--Options table for AceConfig
local ProfileOptions = {
	["type"] = "group",
	["handler"] = private.Ace,
	["args"] = {
		["Profiles"] = nil,  -- Reserved for profile options
	},
};

--This replaces OptionsCharacterDefault
local ProfileDefaults = {
	profile = {
		Achievements = {
			[private.ACHIEVEMENT_IDS.BLOODY_RARE] = true,
			[private.ACHIEVEMENT_IDS.FROSTBITTEN] = true,
			[private.ACHIEVEMENT_IDS.ONE_MANY_ARMY] = true,
			[private.ACHIEVEMENT_IDS.GLORIOUS] = true,
			[private.ACHIEVEMENT_IDS.CHAMPIONS_OF_LEI_SHEN] = true,
			[private.ACHIEVEMENT_IDS.TIMELESS_CHAMPION] = true,
			[private.ACHIEVEMENT_IDS.GORGROND_MONSTER_HUNTER] = true,
			[private.ACHIEVEMENT_IDS.HIGH_VALUE_TARGETS_ASHRAN] = true,
			[private.ACHIEVEMENT_IDS.CUT_OFF_THE_HEAD] = true,
			[private.ACHIEVEMENT_IDS.HERALDS_OF_THE_LEGION] = true,
			[private.ACHIEVEMENT_IDS.FIGHT_THE_POWER] = true,
			[private.ACHIEVEMENT_IDS.ANCIENT_NO_MORE] = true,
			[private.ACHIEVEMENT_IDS.HELLBANE] = true,
			[private.ACHIEVEMENT_IDS.JUNGLE_STALKER] = true,
		},
		AchievementsAddFound = true,
		AlertScreenEdgeFlash = true,
		AlertSoundUnmute = false,
		CacheWarnings = false,
		FlightSupress = true,
		PersistentToast = false,
		ShowAlertAsToast = false,
		TargetIcon = 8, --Skull
		TrackBeasts = true,
		TrackRares = true,
		TrackNameplate = false,
		TrackVignettes = true,
		TrackMouseover = false,
		TrackHellbane = true,
	}
}

local antiSpamList = {}
local lastAntiSpam = 0
local active_tracking_quest_mobs = {}


-------------------------------------------------------------------------------
-- Dialogs and Toasts.
-------------------------------------------------------------------------------
Dialog:Register("NPCSCAN_AUTOADD_WARNING", {
	text = "You appear to be running _NPCScan.AutoAdd, which may prevent _NPCScan from working properly.\n\nIt is recommended that you disable _NPCScan.AutoAdd.",
	text_justify_h = "left",
	text_justify_v = "bottom",
	buttons = {
		{
			text = _G.OKAY,
		},
	},
	icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
	show_while_dead = true,
	hide_on_escape = true,
	width = 500,
})


Dialog:Register("NPCSCAN_WOD_CHANGES", {
	text = L.WOD_CHANGES,
	text_justify_h = "left",
	text_justify_v = "bottom",
	buttons = {
		{
			text = _G.OKAY,
		},
	},
	icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
	show_while_dead = true,
	hide_on_escape = true,
	width = 500,
})


Toast:Register("_NPCScanAlertToast", function(toast, ...)
	if private.CharacterOptions.PersistentToast then
		toast:MakePersistent()
	end
	toast:SetTitle(L.CONFIG_TITLE)
	toast:SetFormattedText("%s%s|r", _G.GREEN_FONT_COLOR_CODE, ...)
	toast:SetIconTexture([[Interface\LFGFRAME\BattlenetWorking0]])
end)


-------------------------------------------------------------------------------
-- Debugger.
-------------------------------------------------------------------------------
local function CreateDebugFrame()
	return _G.LibStub("LibTextDump-1.0"):New(("%s Debug Output"):format(FOLDER_NAME), 640, 480)
end


function private.Debug(...)
	--[===[@debug@
	debugger = debugger or CreateDebugFrame()
	debugger:AddLine(string.format(...))
	local frame = _G.LibStub("LibTextDump-1.0").frames[debugger]
	if frame:IsVisible() then debugger:Display() end
	--@end-debug@]===]
end


-------------------------------------------------------------------------------
-- Helpers.
-------------------------------------------------------------------------------
function private.Print(message, color)
	if not color then
		color = _G.NORMAL_FONT_COLOR
	end
	_G.DEFAULT_CHAT_FRAME:AddMessage(L.PRINT_FORMAT:format(private.CharacterOptions.PrintTime and _G.date(_G.CHAT_TIMESTAMP_FORMAT or L.TIME_FORMAT) or "", message), color.r, color.g, color.b)
end


do
	local tooltip = _G.CreateFrame("GameTooltip", "_NPCScanTooltip")
	local tooltip_text = tooltip:CreateFontString()
	tooltip:AddFontStrings(tooltip_text, tooltip:CreateFontString())

	--For players: Player-[server ID]-[player UID] (Example: "Player-976-0002FD64")
	--For creatures, pets, objects, and vehicles: [Unit type]-0-[server ID]-[instance ID]-[zone UID]-[ID]-[Spawn UID] (Example: "Creature-0-976-0-11-31146-000136DF91")
	--Unit Type Names: "Creature", "Pet", "GameObject", and "Vehicle"
	--For vignettes: Vignette-0-[server ID]-[instance ID]-[zone UID]-0-[spawn UID] (Example: "Vignette-0-970-1116-7-0-0017CAE465" for rare mob Sulfurious)

	--Disabling cache checking due to it nolonger working. will revisit
	function private.NPCNameFromCache(npc_id)
		tooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
		--tooltip:SetHyperlink(("unit:Creature-0-0-0-0-%d:0000000000"):format(npc_id))

		if tooltip:IsShown() then
			return tooltip_text:GetText()
		end
	end
end


local CacheListBuild
do
	local build_list = {}
	local id_registry = {}


	--- Compiles a cache list into a printable list string.
	-- @param Relist True to relist NPC names that have already been printed.
	-- @return List string, or nil if the list was empty.
	function CacheListBuild(source_data, should_relist)
		if not next(source_data) then
			return
		end
		table.wipe(build_list)

		for npc_id, npc_name in pairs(source_data) do
			if should_relist or not id_registry[npc_id] then
				if not should_relist then
					id_registry[npc_id] = true
				end
				build_list[#build_list + 1] = L.CACHELIST_ENTRY_FORMAT:format(npc_name)
			end
		end
		table.wipe(source_data)
 
		if #build_list > 0 then
			table.sort(build_list)
			return table.concat(build_list, L.CACHELIST_SEPARATOR)
		end
	end
end


local CacheList = {}
do
	-- Fills a cache list with all added NPCs, active or not.
	local function CacheListPopulate(self)
		for npc_id in pairs(private.GlobalOptions.NPCs) do
			self[npc_id] = private.NPCNameFromCache(npc_id)
		end

		if private.CharacterOptions.TrackBeasts then
			for npc_id in pairs(private.TAMABLE_ID_TO_NAME) do
				self[npc_id] = private.NPCNameFromCache(npc_id)
			end
		end

		if private.CharacterOptions.TrackRares then
			for npc_id in pairs(private.UNTAMABLE_ID_TO_NAME) do
				self[npc_id] = private.NPCNameFromCache(npc_id)
			end
		end

		for achievement_id in pairs(private.CharacterOptions.Achievements) do
			for criteria_id, npc_id in pairs(private.ACHIEVEMENTS[achievement_id].Criteria) do
				-- Not completed
				if private.CharacterOptions.AchievementsAddFound or not select(3, GetAchievementCriteriaInfoByID(achievement_id, criteria_id)) then
					self[npc_id] = private.NPCNameFromCache(npc_id)
				end
			end
		end
	end


	local FirstPrint = true


	--- Prints a standard message listing cached mobs.
	-- Will also print details about the cache the first time it's called.
	-- @param force_print Overrides the user's option to not print cache warnings.
	-- @param FullListing Adds all cached NPCs before printing, active or not.
	-- @return True if list printed.
	function private.CacheListPrint(force_print, full_listing)
		if force_print or private.CharacterOptions.CacheWarnings then
			if full_listing then
				CacheListPopulate(CacheList)
			end
			local ListString = CacheListBuild(CacheList, force_print or full_listing) -- Allow printing an NPC a second time if forced or full listing

			if ListString then
				private.Print(L[FirstPrint and "CACHED_LONG_FORMAT" or "CACHED_FORMAT"]:format(ListString), force_print and _G.RED_FONT_COLOR)
				FirstPrint = false
				return true
			end
		else
			table.wipe(CacheList)
		end
	end
end


private.ScanIDs = {} -- [ NpcID ] = Number of concurrent scans for this ID


-- Begins searching for an NPC.
local function ScanAdd(npc_id)
	local name = private.NPCNameFromCache(npc_id)

	if name then
		CacheList[npc_id] = name
	else
		if private.ScanIDs[npc_id] then
			private.ScanIDs[npc_id] = private.ScanIDs[npc_id] + 1
		else
			-- First
			if not next(private.ScanIDs) then
				private.Updater:Play()
			end
			private.ScanIDs[npc_id] = 1
			private.Overlays.Add(npc_id)
		end
		return true
	end
end


-- Stops searching for an NPC when nothing is searching for it.
local function ScanRemove(npc_id)
	local count = assert(private.ScanIDs[npc_id], "Attempt to remove inactive scan. " .. npc_id)

	if count > 1 then
		private.ScanIDs[npc_id] = count - 1
	else
		private.ScanIDs[npc_id] = nil
		private.Overlays.Remove(npc_id)

		-- Last
		if not next(private.ScanIDs) then
			private.Updater:Stop()
		end
	end
end


local function IsWorldIDActive(world_id)
	return not world_id or world_id == private.WorldID
end


local NPCActivate, NPCDeactivate
do
	local NPCsActive = {}

	-- Starts actual scan for NPC if on the right world.
	function NPCActivate(npc_id, world_id)
		if NPCsActive[npc_id] or not IsWorldIDActive(world_id) or not ScanAdd(npc_id) then
			return
		end
		NPCsActive[npc_id] = true
		private.Config.Search.UpdateTab("NPC")
		return true
	end


	-- Ends actual scan for NPC.
	function NPCDeactivate(npc_id)
		if not NPCsActive[npc_id] then
			--private.Debug(npc_id.. " not active")
			return
		end
		NPCsActive[npc_id] = nil
		ScanRemove(npc_id)
		private.Config.Search.UpdateTab("NPC")
		return true -- Successfully deactivated
	end


	function private.NPCIsActive(npc_id)
		return NPCsActive[npc_id]
	end

	function private.ClearActiveList()
		table.wipe(NPCsActive)
	end
	
end


-- Adds an NPC name and ID to settings and begins searching.
-- @param npc_id Numeric ID of the NPC (See Wowhead.com).
-- @param Name Temporary name to identify this NPC by in the search table.
-- @param WorldID Number or localized string WorldID to limit this search to.
-- @return True if custom NPC added.
function private.NPCAdd(npc_id, npc_name, world_id)
	local options = private.GlobalOptions
	npc_id = assert(tonumber(npc_id), "NpcID must be numeric.")

	if options.NPCs[npc_id] then
		return
	end
	assert(type(npc_name) == "string", "Name must be a string.")
	assert(world_id == nil or type(world_id) == "string" or type(world_id) == "number", "Invalid WorldID.")
	options.NPCs[npc_id] = npc_name
	options.NPCWorldIDs[npc_id] = world_id

	private.CUSTOM_NPC_ID_TO_NAME[npc_id] = npc_name
	private.CUSTOM_NPC_ID_TO_WORLD_NAME[npc_id] = world_id
	private.CUSTOM_NPC_NAME_TO_ID[npc_name] = npc_id

	if not NPCActivate(npc_id, world_id) then
		-- Didn't activate; Just add row
		private.Config.Search.UpdateTab("NPC")
	end

	return true
end


-- Removes an NPC from settings and stops searching for it.
-- @param NpcID Numeric ID of the NPC.
-- @return True if custom NPC removed.
function private.NPCRemove(npc_id)
	local options = private.GlobalOptions
	npc_id = tonumber(npc_id)

	if not options.NPCs[npc_id] then
		return
	end
	options.NPCs[npc_id] = nil
	options.NPCWorldIDs[npc_id] = nil

	local npc_name = private.CUSTOM_NPC_ID_TO_NAME[npc_id]
	private.CUSTOM_NPC_ID_TO_NAME[npc_id] = nil
	private.CUSTOM_NPC_ID_TO_WORLD_NAME[npc_id] = nil
	private.CUSTOM_NPC_NAME_TO_ID[npc_name] = nil

	if not NPCDeactivate(npc_id) then
		private.Config.Search.UpdateTab("NPC")
	end
	return true
end


-- Starts searching for an achievement's NPC if it meets all settings.
local function AchievementNPCActivate(achievement, npc_id, criteria_id)
	if (achievement.Active and not achievement.NPCsActive[npc_id]
		and (private.CharacterOptions.AchievementsAddFound or not select(3, GetAchievementCriteriaInfoByID(achievement.ID, criteria_id))) -- Not completed
		and ScanAdd(npc_id)) then
		achievement.NPCsActive[npc_id] = criteria_id
		private.Config.Search.UpdateTab(achievement.ID)
		return true
	end
end


-- Stops searching for an achievement's NPC.
local function AchievementNPCDeactivate(achievement, npc_id)
	if not achievement.NPCsActive[npc_id] then
		return
	end
	achievement.NPCsActive[npc_id] = nil
	ScanRemove(npc_id)
	private.Config.Search.UpdateTab(achievement.ID)
	return true
end


-- Starts actual scans for achievement NPCs if on the right world.
local function AchievementActivate(achievement)
	if achievement.Active or not IsWorldIDActive(achievement.WorldID) then
		return
	end
	achievement.Active = true

	for criteria_id, npc_id in pairs(achievement.Criteria) do
		if not _G._NPCScanOptions.IgnoreList.NPCs[npc_id] and not private.NPCQuestIsComplete(npc_id) then
			AchievementNPCActivate(achievement, npc_id, criteria_id)
		end
	end
	return true
end


-- Ends actual scans for achievement NPCs.
local function AchievementDeactivate(achievement)
	if not achievement.Active then
		return
	end
	achievement.Active = nil

	for npc_id in pairs(achievement.NPCsActive) do
		AchievementNPCDeactivate(achievement, npc_id)
	end
	return true
end


-- @param achievement Achievement data table from NS.Achievements.
-- @return True if the achievement NPC is being searched for.
function private.AchievementNPCIsActive(achievement, npc_id)
	return achievement.NPCsActive[npc_id] ~= nil
end


-- Checks to see if any associated kill quests have been complted
-- @param NPC Id of mob .
-- @return True if the quest has been completed.
function private.NPCQuestIsComplete(npc_id)
	local quest_id = private.NPC_ID_TO_QUEST_ID[npc_id]

	if quest_id then
		return IsQuestFlaggedCompleted(quest_id)
	else 
		return false 
	end
end


-- Adds a kill-related achievement to track.
-- @param achievement_id Numeric ID of achievement.
-- @return True if achievement added.
function private.AchievementAdd(achievement_id)
	achievement_id = assert(tonumber(achievement_id), "AchievementID must be numeric.")
	local achievement = private.ACHIEVEMENTS[achievement_id]

	if not achievement then return false end

	if not next(private.CharacterOptions.Achievements) then -- First
	private.Frame:RegisterEvent("ACHIEVEMENT_EARNED")
	private.Frame:RegisterEvent("CRITERIA_UPDATE")
	end

	private.CharacterOptions.Achievements[achievement_id] = true
	private.Config.Search.AchievementSetEnabled(achievement_id, true)
	AchievementActivate(achievement)
	return true
end


-- Removes an achievement from settings and stops tracking it.
-- @param achievement_id Numeric ID of achievement.
-- @return True if achievement removed.
function private.AchievementRemove(achievement_id)
	if not private.CharacterOptions.Achievements[achievement_id] then
		return
	end
	AchievementDeactivate(private.ACHIEVEMENTS[achievement_id])
	private.CharacterOptions.Achievements[achievement_id] = false

	if not next(private.CharacterOptions.Achievements) then -- Last
	private.Frame:UnregisterEvent("ACHIEVEMENT_EARNED")
	private.Frame:UnregisterEvent("CRITERIA_UPDATE")
	end
	private.Config.Search.AchievementSetEnabled(achievement_id, false)
	return true
end


-- Adds a previously ignored Mob to be tracked.
-- @param Mob Id & World ID .
function private.ReavtivateIgnoreMob(npc_id, world_id)
	NPCActivate(npc_id, world_id)
end


-- Removes an ignored Mob from being tracked.
-- @param Mob Id 
function private.DeavtivateIgnoreMob(npc_id)
	NPCDeactivate(npc_id)
end


-- Toggles a Mob type to track.
-- @param Identifier of Type and Toggle State.
function private.RareMobToggle(identifier, enable)
	local npc_list

	if identifier == "BEASTS" then
		private.CharacterOptions.TrackBeasts = enable
		private.Config.Search.AchievementSetEnabled(identifier, enable)
		npc_list = private.TAMABLE_ID_TO_NAME
	elseif identifier == "RARENPC" then
		private.CharacterOptions.TrackRares = enable
		private.Config.Search.AchievementSetEnabled(identifier, enable)
		npc_list = private.UNTAMABLE_ID_TO_NAME
	end

	if npc_list and enable then
		for npc_id, _ in pairs(npc_list) do
			if not _G._NPCScanOptions.IgnoreList.NPCs[npc_id] then
				NPCActivate(npc_id, private.NPC_ID_TO_WORLD_NAME[npc_id])
			end
		end
	elseif npc_list and not enable then
		for npc_id, _ in pairs(npc_list) do
			if private.NPCIsActive(npc_id) then
				NPCDeactivate(npc_id)
			end
		end
	end
end


-------------------------------------------------------------------------------
-- Config Menu Toggles.
-------------------------------------------------------------------------------
-- Enables printing cache lists on login.
function private.SetCacheWarnings(enable)
	private.CharacterOptions.CacheWarnings = enable
	private.Config.cache_warnings_checkbox:SetChecked(enable)
end


-- Enables adding a timestamp to printed messages.
function private.SetPrintTime(enable)
	private.CharacterOptions.PrintTime = enable
	private.Config.print_time_checkbox:SetChecked(enable)
end


-- Enables tracking of unneeded achievement NPCs.
function private.SetAchievementsAddFound(enable)
	private.CharacterOptions.AchievementsAddFound = enable
	private.Config.Search.add_found_checkbox:SetChecked(enable)

	for _, achievement in pairs(private.ACHIEVEMENTS) do
		-- Was active
		if AchievementDeactivate(achievement) then
			AchievementActivate(achievement)
		end
	end
end


-- Enables alerts to be displayed as toast display.
function private.SetShowAsToast(enable)
	private.CharacterOptions.ShowAlertAsToast = enable
	private.Config.show_as_toast_checkbox:SetChecked(enable)
end


-- Enables displayed toasts to be shown untill closed by the user.
function private.SetPersistentToast(enable)
	private.CharacterOptions.PersistentToast = enable
	private.Config.persistent_toast_checkbox:SetChecked(enable)
end


-- Enables unmuting sound to play found alerts.
function private.SetAlertSoundUnmute(enable)
	private.CharacterOptions.AlertSoundUnmute = enable
	private.Config.alert_unmute_checkbox:SetChecked(enable)
end


-- Enables screen edge flash to show on found alerts.
function private.SetAlertScreenEdgeFlash(enable)
	private.CharacterOptions.AlertScreenEdgeFlash = enable
	private.Config.screen_edge_flash_checkbox:SetChecked(enable)
end


-- Sets the sound to play when NPCs are found.
function private.SetAlertSound(alert_sound)
	assert(alert_sound == nil or type(alert_sound) == "string", "AlertSound must be a string or nil.")
	private.GlobalOptions.AlertSound = alert_sound
	_G.UIDropDownMenu_SetText(private.Config.alert_sound_dropdown, alert_sound == nil and L.CONFIG_ALERT_SOUND_DEFAULT or alert_sound)
end


-- Sets the icon to display over found NPC.
function private.SetTargetIcon(icon_id)
	icon_id = icon_id or private.NUM_RAID_ICONS
	private.CharacterOptions.TargetIcon = icon_id

	local icon_info = _G.UnitPopupButtons["RAID_TARGET_" .. icon_id]
	local colorCode = ("|cFF%02x%02x%02x"):format(icon_info.color.r * 255, icon_info.color.g * 255, icon_info.color.b * 255)
	_G.UIDropDownMenu_SetText(private.Config.alert_icon_dropdown, colorCode .. icon_info.text)
end


-- Enables Blocking alerts while on taxi.
function private.SetBlockFlightScan(enable)
	private.CharacterOptions.FlightSupress = enable
	private.Config.block_flight_scan_checkbox:SetChecked(enable)
	return enable
end


-- Enables Hellbane mob tracking when their icons appear on the world map.
function private.SetHellbaneScan(enable)
	private.CharacterOptions.TrackHellbane = enable
	private.Config.hellbane_scan_checkbox:SetChecked(enable)
	return enable
end


-- Enables tracking of mobs by Nameplate.
function private.SetNameplateScan(enable)
	private.CharacterOptions.TrackNameplate = enable
	private.Config.nameplate_scan_checkbox:SetChecked(enable)
	return enable
end


-- Enables tracking of mobs by Vignette.
function private.SetVignetteScan(enable)
	private.CharacterOptions.TrackVignettes = enable
	private.Config.viginette_scan_checkbox:SetChecked(enable)
	return enable
end

-- Enables Mouseover tracking.
function private.SetMouseoverScan(enable)
	private.CharacterOptions.TrackMouseover = enable
	private.Config.mouseover_scan_checkbox:SetChecked(enable)
	return enable
end

local IsDefaultNPCValid
do
	local TAMABLE_EXCEPTIONS = {
		[49822] = true -- Jadefang drops a pet
	}

	local NPC_FACTION = {
		[51071] = "Horde", -- Captain Florence
		[51079] = "Alliance", -- Captain Foulwind
		[68317] = "Horde", -- Mavis Harms
		[68318] = "Horde", -- Dalan Nightbreaker
		[68319] = "Horde", -- Disha Fearwarden
		[68320] = "Alliance", -- Ubunti the Shade
		[68321] = "Alliance", -- Kar Warmaker
		[68322] = "Alliance", -- Muerta
	}

	-- @return True if NpcID should be a default for this character.
	function IsDefaultNPCValid(npc_id)
		return (PLAYER_CLASS == "HUNTER" or not private.TAMABLE_ID_TO_NAME[npc_id] or TAMABLE_EXCEPTIONS[npc_id]) and (not NPC_FACTION[npc_id] or NPC_FACTION[npc_id] == PLAYER_FACTION)
	end
end


-- Resets the scanning list and reloads it from saved settings.
function private.Synchronize()
	for var, value in pairs(GlobalOptionsDefault) do
		private.GlobalOptions[var] = private.GlobalOptions[var] == nil and value or private.GlobalOptions[var]
	end

	local options = private.GlobalOptions
	local character_options = private.CharacterOptions

	assert(not next(private.ScanIDs), "Orphan NpcIDs in scan pool!")

	private.SetCacheWarnings(character_options.CacheWarnings)
	private.SetPrintTime(character_options.PrintTime)
	private.SetAchievementsAddFound(character_options.AchievementsAddFound)
	private.SetShowAsToast(character_options.ShowAlertAsToast)
	private.SetPersistentToast(character_options.PersistentToast)
	private.SetAlertSoundUnmute(character_options.AlertSoundUnmute)
	private.SetAlertScreenEdgeFlash(character_options.AlertScreenEdgeFlash)
	private.SetTargetIcon(character_options.TargetIcon)
	private.SetAlertSound(options.AlertSound)
	private.SetNameplateScan(character_options.TrackNameplate)
	private.SetVignetteScan(character_options.TrackVignettes)
	private.SetHellbaneScan(character_options.TrackHellbane)
	private.SetMouseoverScan(character_options.TrackMouseover)
	private.SetBlockFlightScan(character_options.FlightSupress)
	private.RareMobToggle("BEASTS", character_options.TrackBeasts)
	private.RareMobToggle("RARENPC", character_options.TrackRares)

	for achievement_id, achievement in pairs(private.ACHIEVEMENTS) do
		-- If defaults, don't enable completed achievements unless explicitly allowed
		if character_options.Achievements[achievement_id] then
			private.AchievementAdd(achievement_id)
		else
			private.AchievementRemove(achievement_id)
			private.Config.Search.AchievementSetEnabled(achievement_id, false)
		end
	end

	--Builds custom NPC lookup tables
	for npc_id, npc_name in pairs(private.GlobalOptions.NPCs) do
		private.CUSTOM_NPC_ID_TO_NAME[npc_id] = npc_name
		private.CUSTOM_NPC_ID_TO_WORLD_NAME[npc_id] = private.GlobalOptions.NPCWorldIDs[npc_id]
		private.CUSTOM_NPC_NAME_TO_ID[npc_name] = npc_id
	end

	private.CacheListPrint(false, true) -- Populates cache list with inactive mobs too before printing
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
		private.Debug("Anti-Spam triggered for: "..tostring(id))
		return false
	end
end


do
	local PetList = {}

	-- Prints the list of cached pets when leaving a city or inn.
	function private.Frame:PLAYER_UPDATE_RESTING()
		if _G.IsResting() or not next(PetList) then
			return
		end

		if private.CharacterOptions.CacheWarnings then
			local ListString = CacheListBuild(PetList)
			if ListString then
				private.Print(L.CACHED_PET_RESTING_FORMAT:format(ListString), _G.RED_FONT_COLOR)
			end
		else
			table.wipe(PetList)
		end
	end


	-- @return True if the tamable mob is in its correct zone, else false with an optional reason string.
	local function OnFoundTamable(npc_id, npc_name)
		local tamable_zone_name = private.TAMABLE_ID_TO_MAP_NAME[npc_id]
		local expected_zone_id = tamable_zone_name and private.ZONE_IDS[private.ZONE_NAME_TO_LABEL[tamable_zone_name]]
		local current_zone_id = _G.GetCurrentMapAreaID()

		_G.SetMapToCurrentZone()
		local in_correct_zone = expected_zone_id == _G.GetCurrentMapAreaID()
		local invalid_reason

		if not in_correct_zone then
			if _G.IsResting() then
				PetList[npc_id] = npc_name -- Suppress error message until the player stops resting
			else
				-- GetMapNameByID returns nil for continent maps
				local expected_zone_name = expected_zone_id and _G.GetMapNameByID(expected_zone_id) or nil
				if not expected_zone_name then
					_G.SetMapByID(expected_zone_id)

					local map_continent = _G.GetCurrentMapContinent()
					if map_continent >= 1 then
						expected_zone_name = select(map_continent * 2, _G.GetMapContinents())
					end
				end
				invalid_reason = L.FOUND_TAMABLE_WRONGZONE_FORMAT:format(npc_name, _G.GetRealZoneText(), expected_zone_name or _G.UNKNOWN, expected_zone_id)
			end
		end
		_G.SetMapByID(current_zone_id)

		return in_correct_zone, invalid_reason
	end


	local function GetScanSource(npc_id)
		local custom_name = private.GlobalOptions.NPCs[npc_id]

		if custom_name then
			return custom_name
		end

		for achievement_id in pairs(private.CharacterOptions.Achievements) do
			if private.ACHIEVEMENTS[achievement_id].NPCsActive[npc_id] then
				return _G.GetAchievementLink(achievement_id)
			end
		end
	end

	-- Validates found mobs before showing alerts.
	function private.OnFound(npc_id, npc_name)
		--[[  No need to deactivate mobs as cache scanning is deactivated. Re-enable if cache scanning works again.
				NPCDeactivate(npc_id)

				for achievement_id in pairs(private.CharacterOptions.Achievements) do
					AchievementNPCDeactivate(private.ACHIEVEMENTS[achievement_id], npc_id)
				end
		--]]
		local is_valid = true
		local is_tamable = private.TAMABLE_ID_TO_NAME[npc_id]
		local invalid_reason

		if is_tamable then
			is_valid, invalid_reason = OnFoundTamable(npc_id, npc_name)
		end

		-- Checks to see if player is on flightpath, this will block possible cross realm alerts
		if private.CharacterOptions.FlightSupress and _G.UnitOnTaxi("player") then
			is_valid = false
			_G.SetMapToCurrentZone()
			_G.PlaySound("TellMessage", "master")

			local x, y = _G.GetPlayerMapPosition("player")
			invalid_reason = L.FOUND_UNIT_TAXI:format(npc_name, x * 100, y * 100, _G.GetZoneText())
		end

		-- Checks to see if alert for mob has allready been displayed recently
		is_valid = private.AntiSpam(private.ANTI_SPAM_DELAY, npc_name)

		if is_valid then
			local alert_text = L[is_tamable and "FOUND_TAMABLE_FORMAT" or "FOUND_FORMAT"]:format(npc_name)

			if private.CharacterOptions.ShowAlertAsToast then
				Toast:Spawn("_NPCScanAlertToast", alert_text)
			else
				private.Print(alert_text, _G.GREEN_FONT_COLOR)
			end
			private.Button:SetNPC(npc_id, npc_name, GetScanSource(npc_id)) -- Sends added and found overlay messages
		elseif invalid_reason then
			private.Print(invalid_reason)
		end
	end


	local criteria_updated_bucket


	function private.Frame:CRITERIA_UPDATE()
		criteria_updated_bucket = true
	end


	-- Scans all NPCs on a timer and alerts if any are found.
	function private.Updater:OnLoop()
		if criteria_updated_bucket then
			criteria_updated_bucket = false

			if not private.CharacterOptions.AchievementsAddFound then
				for achievement_id in pairs(private.CharacterOptions.Achievements) do
					local achievement = private.ACHIEVEMENTS[achievement_id]

					for npc_id, criteria_id in pairs(achievement.NPCsActive) do
						local _, _, is_completed = _G.GetAchievementCriteriaInfoByID(achievement_id, criteria_id)

						if is_completed then
							AchievementNPCDeactivate(achievement, npc_id)
						end
					end
				end
			end
		end

		for npc_id in pairs(private.ScanIDs) do
			local npc_name = private.NPCNameFromCache(npc_id)
			if npc_name then
				private.OnFound(npc_id, npc_name)
			end
		end
	end
end


if PLAYER_CLASS == "HUNTER" then
	local StableUpdater = _G.CreateFrame("Frame")
	local stabled_list = {}

	-- Stops scans for stabled hunter pets before a bogus alert can fire.
	function private.Frame:PET_STABLE_UPDATE()
		for npc_id in pairs(private.ScanIDs) do
			local npc_name = private.NPCNameFromCache(npc_id)
			if npc_name then
				stabled_list[npc_id] = npc_name
				NPCDeactivate(npc_id)

				for achievement_id in pairs(private.CharacterOptions.Achievements) do
					AchievementNPCDeactivate(private.ACHIEVEMENTS[achievement_id], npc_id)
				end
			end
		end
		StableUpdater:Show()
	end


	-- Bucket to print cached stabled pets on one line.
	function StableUpdater:OnUpdate()
		self:Hide()

		if private.CharacterOptions.CacheWarnings then
			local list_string = CacheListBuild(stabled_list)
			if list_string then
				private.Print(L.CACHED_STABLED_FORMAT:format(list_string))
			end
		else
			table.wipe(stabled_list)
		end
	end

	StableUpdater:Hide()
	StableUpdater:SetScript("OnUpdate", StableUpdater.OnUpdate)
	private.Frame:RegisterEvent("PET_STABLE_UPDATE")


	-- Prevents the pet UI from querying (and caching) stabled pets until actually viewing the stables.
	-- @param is_override Forces a normal query even if the stables aren't open.
	local Original_GetStablePetInfo = _G.GetStablePetInfo
	function _G.GetStablePetInfo(stable_slot, is_override, ...)
		if is_override or stable_slot <= _G.NUM_PET_ACTIVE_SLOTS or _G.IsAtStableMaster() then
			return Original_GetStablePetInfo(stable_slot, is_override, ...)
		end
	end
end


--Initializes Ace Database for profile & adds profile menu to Blizzard menu
function private.Ace:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("_NPCScanProfiles", ProfileDefaults, true)
	ProfileOptions.args.Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(FOLDER_NAME, ProfileOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(FOLDER_NAME, "Profiles", L.CONFIG_TITLE, "Profiles")

	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

--Save any old setting to character profile
	local charName = _G.UnitName("player").." - ".._G.GetRealmName()
	if _G._NPCScanOptionsCharacter then
		if not _G._NPCScanProfiles.profiles then _G._NPCScanProfiles.profiles = {} end
		_G._NPCScanProfiles.profiles[charName] = {}
		for var, value in pairs(_G._NPCScanOptionsCharacter) do
			_NPCScanProfiles.profiles[charName][var] = value
		end

	end

end


--Called whenever profile is changed to reload new settings
function private.Ace:RefreshProfile()
	for npc_id , _ in pairs(private.ScanIDs) do
		NPCDeactivate(npc_id)
	end

	private.CharacterOptions = private.Ace.db.profile
	private.Frame:PLAYER_LEAVING_WORLD()

	table.wipe(private.ScanIDs)
	private.ClearActiveList()

	private.Synchronize()
	private.Frame:PLAYER_ENTERING_WORLD()
end


-- Loads defaults, validates settings, and starts scan.
-- Used instead of ADDON_LOADED to give overlay mods a chance to load and register for messages.
function private.Frame:PLAYER_LOGIN(event_name)
	if _G.IsAddOnLoaded("_NPCScan.AutoAdd") then
		if _G.GetAddOnMetadata("_NPCScan.AutoAdd", "Version"):match("^([%d.]+)") <= "2.2" then
			Dialog:Spawn("NPCSCAN_AUTOADD_WARNING")
		end
	end

	private.GlobalOptions = _G._NPCScanOptions
	private.CharacterOptions = private.Ace.db.profile
	private.Overlays.Register()
	private.Synchronize()

	self[event_name] = nil

	if not private.GlobalOptions.ChangeAlertShown then
		Dialog:Spawn("NPCSCAN_WOD_CHANGES")
		private.GlobalOptions.ChangeAlertShown = true
	end
end


do
	local has_initialized = false

	function private.Frame:PLAYER_ENTERING_WORLD()
		self:PLAYER_UPDATE_RESTING()

		-- Since real MapIDs aren't available to addons, a "WorldID" is a universal ContinentID or the map's localized name.
		local map_name, _, _, _, _, _, _, map_id = _G.GetInstanceInfo()
		local map_continent = _G.GetCurrentMapContinent()

		-- Fix for Deepholm
		if map_continent == private.CONTINENT_IDS.THE_MAELSTROM then
			private.WorldID = private.ZONE_NAMES.DEEPHOLM
		elseif map_continent == -1 and map_id == DARKMOON_ISLAND_MAP_ID then --Darkmoon Island which doesn't have a continent location
			private.WorldID = map_name

		else
			private.WorldID = private.LOCALIZED_CONTINENT_NAMES[map_continent]
		end 
		private.Debug(private.WorldID  or "No World")
private.Debug(map_name or "no map")
private.Debug(map_continent or "no cont")

		if private.CharacterOptions.TrackRares then
			for npc_id, world_name in pairs(private.UNTAMABLE_ID_TO_WORLD_NAME) do
				if not private.GlobalOptions.IgnoreList.NPCs[npc_id] then
					NPCActivate(npc_id, world_name)
				end
			end
		end

		if private.CharacterOptions.TrackBeasts then
			for npc_id, world_name in pairs(private.TAMABLE_ID_TO_WORLD_NAME) do
				if not private.GlobalOptions.IgnoreList.NPCs[npc_id] then
					NPCActivate(npc_id, world_name)
				end
			end
		end

		for achievement_id, enable in pairs(private.CharacterOptions.Achievements) do
			local achievement = private.ACHIEVEMENTS[achievement_id]
			if achievement.WorldID and enable then
				AchievementActivate(achievement)
			end
		end

		--Removes any one time kill / daily kill rares that have been completed
		for npc_id, quest_id in pairs(private.NPC_ID_TO_QUEST_ID) do
			if private.NPCQuestIsComplete(npc_id) then 
				NPCDeactivate(npc_id)
			else
				active_tracking_quest_mobs[npc_id] =  quest_id
			end
		end

		--Adds any custom mobs
		for npc_id, _ in pairs(private.GlobalOptions.NPCs) do
			NPCActivate(npc_id, private.GlobalOptions.NPCWorldIDs[npc_id])
		end

		if not has_initialized or not private.CharacterOptions.CacheWarnings then
			-- Full listing of cached mobs gets printed on login
			has_initialized = true
			table.wipe(CacheList)
		else
			-- Print list of cached mobs specific to new world
			local list_string = CacheListBuild(CacheList)
			if list_string then
				private.Print(L.CACHED_WORLD_FORMAT:format(list_string, map_name))
			end
		end
		private.Config.Search:UpdateTabNames()
	end
end


function private.Frame:PLAYER_LEAVING_WORLD()
	if private.GlobalOptions.NPCWorldIDs then 
		for npc_id in pairs(private.GlobalOptions.NPCWorldIDs) do
			NPCDeactivate(npc_id)
		end
	end

	for npc_id, world_id in pairs(private.TAMABLE_ID_TO_WORLD_NAME) do
		if world_id == private.WorldID then
			NPCDeactivate(npc_id)
		end
	end

	for npc_id, world_id in pairs(private.UNTAMABLE_ID_TO_WORLD_NAME) do
		if world_id == private.WorldID then
			NPCDeactivate(npc_id)
		end
	end

	for achievement_id in pairs(private.CharacterOptions.Achievements) do
		local achievement = private.ACHIEVEMENTS[achievement_id]
		if achievement.WorldID then
			AchievementDeactivate(achievement)
		end
	end
	private.WorldID = nil
end


function private.Frame:ACHIEVEMENT_EARNED(_, achievement_id)
	if not private.ACHIEVEMENTS[achievement_id] then
		return
	end
	private.ACHIEVEMENTS[achievement_id].is_completed = true

	if not private.CharacterOptions.AchievementsAddFound then
		private.AchievementRemove(achievement_id)
	end
end


--Using this to check for kill track quests as they only complete after looting
function private.Frame:LOOT_CLOSED(event_name)
	--Removes any one time kill / daily kill rares that have been completed
	for npc_id, quest_id in pairs(active_tracking_quest_mobs) do
		if private.NPCQuestIsComplete(npc_id) then 
			NPCDeactivate(npc_id)
			active_tracking_quest_mobs[npc_id] = nil
		end
	end
end


function private.Frame:ZONE_CHANGED_NEW_AREA(event_name)
	self:UnregisterEvent(event_name)
	self[event_name] = nil

	private.Updater:SetScript("OnLoop", private.Updater.OnLoop)
end


do
	local SUBCOMMAND_FUNCS = {
		[L.CMD_ADD] = function(arguments)
			local id, name = arguments:match("^(%d+)%s+(.+)$")
			id = tonumber(id)

			if not id then
				return
			end
			private.NPCRemove(id)

			if private.NPCAdd(id, name) then
				private.CacheListPrint(true)
			end
		end,
		[L.CMD_REMOVE] = function(arguments)
			local id = tonumber(arguments)

			if not id then
				for npc_id, npc_name in pairs(private.GlobalOptions.NPCs) do
					if npc_name == arguments then
						id = npc_id
						break
					end
				end
			end

			if not private.NPCRemove(id) then
				private.Print(L.CMD_REMOVENOTFOUND_FORMAT:format(arguments), _G.RED_FONT_COLOR)
			end
		end,
		[L.CMD_CACHE] = function(arguments)
			if not private.CacheListPrint(true, true) then
				private.Print(L.CMD_CACHE_EMPTY, _G.GREEN_FONT_COLOR)
			end
		end,
		--[===[@debug@
		DEBUG = function()
			debugger = debugger or CreateDebugFrame()

			if debugger:Lines() == 0 then
				debugger:AddLine("Nothing to report.")
				debugger:Display()
				debugger:Clear()
				return
			end
			debugger:Display()
		end,
		DUMP = function()
			private.TextDump = private.TextDump or _G.LibStub("LibTextDump-1.0"):New(FOLDER_NAME)
			private.DumpNPCData()
		end,
		--@end-debug@]===]
	}


	_G.SlashCmdList["_NPCSCAN"] = function(input)
		local subcommand, arguments = input:match("^(%S+)%s*(.-)%s*$")
		if subcommand then
			local func = SUBCOMMAND_FUNCS[subcommand:upper()]
			if func then
				func(arguments)
			else
				private.Print(L.CMD_HELP)
			end
		else
			_G.InterfaceOptionsFrame_OpenToCategory(private.Config.Search)
		end
	end
end -- do-block


if _G.IsLoggedIn() then
	private.Frame:PLAYER_LOGIN("PLAYER_LOGIN")
else
	private.Frame:RegisterEvent("PLAYER_LOGIN")
end


if _G.GetZoneText() == "" then
	private.Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
else
	private.Frame:ZONE_CHANGED_NEW_AREA("ZONE_CHANGED_NEW_AREA")
end


-------------------------------------------------------------------------------
-- Mouseover Trigger Functions
-------------------------------------------------------------------------------
function private.Frame:UPDATE_MOUSEOVER_UNIT()
	if not private.CharacterOptions.TrackMouseover then
		private.Debug("Not Tracking Mobs by Mouseover")
		return
	end
	local unit_token = "mouseover"

	if _G.UnitClassification(unit_token) ~= ("rare" or "rareelite") or _G.UnitIsDead(unit_token) then
		return
	end

	--[Unit type]-0-[server ID]-[instance ID]-[zone UID]-[ID]-[Spawn UID] (Example: "Creature-0-976-0-11-31146-000136DF91")
	local mouseover_guid = _G.UnitGUID(unit_token)
	local _, _, _, _, _, _, _, mouseover_id = string.find(mouseover_guid, "(%a+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
	local target_guid = _G.UnitGUID("target")
	local target_id
	local npc_id = tonumber(mouseover_id)

	if target_guid then
		_, _, _, _, _, _, _, target_id = string.find(target_guid, "(%a+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
	end


	--if (private.NPC_ID_TO_NAME[tonumber(mouseover_id)] or private.GlobalOptions.NPCs[tonumber(mouseover_id)]) and mouseover_id ~= target_id then
	if (private.ScanIDs[npc_id]) and mouseover_id ~= target_id then
		private.Debug("Mob Found via Mouseover")
		private.OnFound(mouseover_id, _G.UnitName(unit_token))
	end
end


-------------------------------------------------------------------------------
-- Dynamic Target Macro Functions
-------------------------------------------------------------------------------
local MacroDelay = false
local target_button = _G.CreateFrame("Button", "_NPCScan_Search_Button", _G.UIParent, "SecureActionButtonTemplate,SecureHandlerShowHideTemplate")
target_button:Hide()

target_button:SetAttribute("type", "macro")
target_button:SetAttribute("macrotext", private.macrotext)
target_button:RegisterEvent("PLAYER_ENTERING_WORLD")
target_button:RegisterEvent("ZONE_CHANGED_NEW_AREA")
target_button:RegisterEvent("VARIABLES_LOADED")
target_button:RegisterEvent("PLAYER_REGEN_ENABLED")
target_button:SetScript("OnEvent", function(self, event_name, ...)
	if event_name == "PLAYER_REGEN_ENABLED" then
		-- Only needs to trigger after combat if a delay was set
		if not MacroDelay then
			return
		end
		MacroDelay = false
	end
	private.GenerateTargetMacro()
end)


function private.GenerateTargetMacro(instanceid)
	if _G.InCombatLockdown() then
		MacroDelay = true
		return
	end

	_G.SetMapToCurrentZone()
	local map_id = _G.GetCurrentMapAreaID()
	local zone_name = _G.GetMapNameByID(map_id)
	local continent_id = _G.GetCurrentMapContinent()

	private.macrotext = "/cleartarget"

	-- Generate target macro with tracked mobs in zone
	for npc_id, map_zone_name in pairs(private.NPC_ID_TO_MAP_NAME) do
		if zone_name == map_zone_name and not _G._NPCScanOptions.IgnoreList.NPCs[npc_id] and private.ScanIDs[npc_id] then
			private.macrotext = private.MACRO_FORMAT:format(private.macrotext, private.NPC_ID_TO_NAME[npc_id])
		end
	end

	--Checks for custom mobs and then add them
	if _G._NPCScanOptions.NPCs then
		for npc_id, npc_name in pairs(_G._NPCScanOptions.NPCs) do
			if not _G._NPCScanOptions.IgnoreList.NPCs[npc_id] and _G._NPCScanOptions.NPCWorldIDs[npc_id] == private.LOCALIZED_CONTINENT_NAMES[continent_id] then
				private.macrotext = private.MACRO_FORMAT_CUSTOM_MOB:format(private.macrotext, npc_name)
			end
		end
	end

	--Add Zandalari Warscout & Warbringer due to them appearing in multiple zones but in only one in the data file.
	--Ignore if not in Pandaria or on the Timeless Isle
	if continent_id == private.CONTINENT_IDS.PANDARIA and map_id ~= private.ZONE_IDS.TIMELESS_ISLE then
		for index = 1, #private.MANUAL_PANDARIA_ADDITIONS do
			if last_vignette_id ~= private.MANUAL_PANDARIA_ADDITIONS[index] then
				private.macrotext = private.MACRO_FORMAT:format(private.macrotext, private.NPC_ID_TO_NAME[private.MANUAL_PANDARIA_ADDITIONS[index]])
			end
		end
	end

	if instanceid then
		private.macrotext = private.macrotext .. "\n/run _G._NPCScan.SetVignetteTarget()"
	else
		private.macrotext = private.macrotext .. "\n/run _G._NPCScan.CheckMacroTarget()"
	end

	target_button:SetAttribute("macrotext", private.macrotext)
	return true
end


--Checks target found by macro and triggers NPCScan alert for tracked mobs
function private.CheckMacroTarget()
	local target_guid = UnitGUID("target")
	if target_guid then
		local _, _, _, _, _, _, _, target_id = string.find(target_guid, "(%a+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
		target_id = tonumber(target_id)
		if (private.NPC_ID_TO_NAME[target_id] or private.GlobalOptions.NPCs[target_id]) and not UnitIsDeadOrGhost("target") then
			private.Debug("Mob Found Via Macro")
			private.OnFound(target_id, _G.UnitName("target"))

			if _G.GetRaidTargetIndex("target") ~= private.CharacterOptions.TargetIcon and (not _G.IsInRaid() or (_G.UnitIsGroupAssistant("player") or _G.UnitIsGroupLeader("player"))) then
				_G.SetRaidTarget("target", private.CharacterOptions.TargetIcon)
			end
		end
	end
end