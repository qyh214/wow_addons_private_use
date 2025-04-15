local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

if not IsRetail and not IsClassic and not IsWrath and not IsCata then
	return
end

---@class Difficulty
---@field name string
---@field abbreviation string

---@type string
local AddonName = ...

---@class Private
local Private = select(2, ...)

Private.L = {}
Private.IsRetail = IsRetail
Private.IsClassicEra = IsClassic
Private.IsWrath = IsWrath
Private.IsCata = IsCata

---@type table<number, function>
Private.LoginFnQueue = {}
Private.IsInitialized = false

---@class Realm
---@field name string
---@field slug string
---@field database number|string
---@field region string

---@type table<number, Realm>
Private.Realms = {}

---@class ArchonTooltip
ArchonTooltip = {}

local function OnAddonLoaded()
	ArchonTooltipSaved = ArchonTooltipSaved or {}
	Private.db = ArchonTooltipSaved
end

local function OnPlayerLogin()
	for i = 1, #Private.LoginFnQueue do
		local fn = Private.LoginFnQueue[i]
		fn()
	end

	table.wipe(Private.LoginFnQueue)

	Private.IsInitialized = Private.LoadAddOn(Private.CurrentRealm.database, Private.CurrentRealm.name)
end

if IsRetail then
	EventUtil.ContinueOnAddOnLoaded(AddonName, OnAddonLoaded)
	EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_LOGIN", OnPlayerLogin)
else
	EventRegistry:RegisterFrameEventAndCallback(
		"ADDON_LOADED",
		---@param ownerId number
		---@param loadedAddonName string
		function(ownerId, loadedAddonName)
			if loadedAddonName == AddonName then
				EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", ownerId)
				OnAddonLoaded()
			end
		end
	)
	EventRegistry:RegisterFrameEventAndCallback(
		"PLAYER_LOGIN",
		---@param ownerId number
		function(ownerId)
			EventRegistry:UnregisterFrameEventAndCallback("PLAYER_LOGIN", ownerId)
			OnPlayerLogin()
		end
	)
end

---@class Encounter
---@field id number

---@class Zone
---@field id number
---@field name string
---@field encounters table<number, Encounter>
---@field hasMultipleSizes boolean
---@field difficultyIconMap table<number, number|string>|nil

---@type table<number, Zone>
Private.Zones = {}

---@type table<number, number>
Private.EncounterZoneIdMap = {}

---@param encounterId number
---@return Zone|nil
function Private.GetZoneForEncounterId(encounterId)
	local zoneId = Private.EncounterZoneIdMap[encounterId]

	return zoneId and Private.Zones[zoneId]
end

---@param zoneId number
---@return Zone|nil
function Private.GetZoneById(zoneId)
	return Private.Zones[zoneId]
end
