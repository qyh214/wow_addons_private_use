---@type string, Addon
local _, addon = ...
---@type Db
local db

---@class ModuleName
local ModuleName = {
	CrowdControl = "CCModule",
	PetCC = "PetCCModule",
	HealerCrowdControl = "HealerCCModule",
	Portrait = "PortraitModule",
	Alerts = "AlertsModule",
	Nameplates = "NameplatesModule",
	KickTimer = "KickTimerModule",
	Trinkets = "TrinketsModule",
	FriendlyIndicator = "FriendlyIndicatorModule",
	PrecogGuesser = "PrecogGuesserModule",
	FriendlyCooldownTracker = "FriendlyCooldownTrackerModule",
	EnemyCooldownTracker    = "EnemyCooldownTrackerModule",
}

---@class ModuleUtil
local M = {}

addon.Utils.ModuleUtil = M
addon.Utils.ModuleName = ModuleName

function M:Init()
	db = addon.Core.Framework:GetSavedVars()
end

---@param moduleName string The module key (e.g., "AlertsModule", "CcModule")
---@return boolean
function M:IsModuleEnabled(moduleName)
	if not db or not db.Modules or not db.Modules[moduleName] then
		return true -- Default to enabled if settings don't exist
	end

	local settings = db.Modules[moduleName].Enabled
	if not settings then
		return true
	end

	if settings.Always then
		-- this module is set to always enabled, so we can skip the instance check
		return true
	end

	local inInstance, instanceType = IsInInstance()

	if not inInstance then
		if IsInRaid() then
			return settings.Raid
		end
		return settings.World or false
	end

	-- Check specific instance types
	if instanceType == "arena" then
		return settings.Arena
	elseif instanceType == "pvp" then
		return settings.BattleGrounds
	end

	if IsInRaid() then
		return settings.Raid
	end

	return settings.Dungeons
end
