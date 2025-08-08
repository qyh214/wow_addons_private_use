local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
local IsMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC

if not IsRetail and not IsClassic and not IsWrath and not IsCata and not IsMists then
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
Private.IsMists = IsMists

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

---@class SavedVariablesSettings
---@field ShowTooltipInCombat boolean
---@field AllowShiftExpansionInCombat boolean
---@field ShowRank boolean
---@field ShowAsp boolean
---@field ShowShiftHint boolean
---@field MenuDropdownIntegration boolean

---@class SavedVariables
---@field Settings SavedVariablesSettings

---@class ArchonTooltip
ArchonTooltip = {}

local function OnAddonLoaded()
	---@type SavedVariables
	ArchonTooltipSaved = ArchonTooltipSaved or {}
	ArchonTooltipSaved.Settings = ArchonTooltipSaved.Settings or {}

	if ArchonTooltipSaved.Settings.ShowTooltipInCombat == nil then
		ArchonTooltipSaved.Settings.ShowTooltipInCombat = false
	end

	if ArchonTooltipSaved.Settings.AllowShiftExpansionInCombat == nil then
		ArchonTooltipSaved.Settings.AllowShiftExpansionInCombat = false
	end

	if ArchonTooltipSaved.Settings.ShowRank == nil then
		ArchonTooltipSaved.Settings.ShowRank = false
	end

	if ArchonTooltipSaved.Settings.ShowAsp == nil then
		ArchonTooltipSaved.Settings.ShowAsp = false
	end

	if ArchonTooltipSaved.Settings.ShowShiftHint == nil then
		ArchonTooltipSaved.Settings.ShowShiftHint = true
	end

	if ArchonTooltipSaved.Settings.MenuDropdownIntegration == nil then
		ArchonTooltipSaved.Settings.MenuDropdownIntegration = true
	end

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

local function OnRaiderIoLoaded()
	Private.AddOnUtils.RaiderIoLoaded = true
end

if EventUtil and EventUtil.ContinueOnAddOnLoaded then
	EventUtil.ContinueOnAddOnLoaded(AddonName, OnAddonLoaded)
	EventUtil.ContinueOnAddOnLoaded("RaiderIO", OnRaiderIoLoaded)
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
		"ADDON_LOADED",
		---@param ownerId number
		---@param loadedAddonName string
		function(ownerId, loadedAddonName)
			if loadedAddonName == "RaiderIO" then
				EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", ownerId)
				OnRaiderIoLoaded()
			end
		end
	)
end

if EventUtil and EventUtil.RegisterOnceFrameEventAndCallback then
	EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_LOGIN", OnPlayerLogin)
else
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
---@field hasMultipleDifficulties boolean
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
