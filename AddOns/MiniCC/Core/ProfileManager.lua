---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local scheduler = addon.Utils.Scheduler
local migrator  -- set in Init after Migrator is loaded

---@class ProfileManager
local M = {}
addon.Core.ProfileManager = M

-- Keys from the top-level db that constitute a profile payload.
-- Must stay in sync with the list in Config/Migrator.lua.
-- Exposed so Migrator.lua (loaded after this file) can reference it.
M.PayloadKeys = {
	"GlowType",
	"FontScale",
	"IconSpacing",
	"ConfigureBlizzardNameplates",
	"CCNativeOrder",
	"DisableSwipe",
	"Modules",
}

local onProfileChangedCallbacks = {}
local db

local function DeepCopy(src)
	if type(src) ~= "table" then return src end
	local t = {}
	for k, v in pairs(src) do
		t[k] = DeepCopy(v)
	end
	return t
end

-- Mutates `target` in-place so its contents match `source`.
-- Preserves existing table identities so upvalue references captured in
-- Config UI closures (e.g. options.Offset.X) remain valid after a switch.
local function MutateTableInPlace(target, source)
	for k in pairs(target) do
		if source[k] == nil then
			target[k] = nil
		end
	end
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			MutateTableInPlace(target[k], v)
		else
			target[k] = DeepCopy(v)
		end
	end
end

local function GetCharKey()
	local name = UnitName("player")
	local realm = GetRealmName()
	if not name or not realm then return nil end
	return name .. "-" .. realm
end

local function FireProfileChanged(name)
	for _, cb in pairs(onProfileChangedCallbacks) do
		cb(name)
	end
end

-- Saves the current live db payload into the active profile slot.
function M:SaveCurrentProfile()
	if not db then return end
	local name = db.ActiveProfile
	if not name then return end
	-- Ensure all default keys are present before snapshotting so the saved
	-- profile is always complete, even if some keys were never explicitly set.
	if migrator then migrator:FillDefaults() end
	db.Profiles = db.Profiles or {}
	local slot = db.Profiles[name] or {}
	for k in pairs(slot) do slot[k] = nil end
	for _, k in ipairs(M.PayloadKeys) do
		if db[k] ~= nil then
			slot[k] = DeepCopy(db[k])
		end
	end
	db.Profiles[name] = slot
end

---@return string[]
function M:GetProfileNames()
	if not db or not db.Profiles then return {} end
	local names = {}
	for name in pairs(db.Profiles) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

---@return string
function M:GetActiveProfile()
	return db and db.ActiveProfile or "Default"
end

---@param name string
---@param sourceName string? profile to copy from; nil = snapshot current live state
function M:CreateProfile(name, sourceName)
	if not db or not name or name == "" then return end
	db.Profiles = db.Profiles or {}
	if db.Profiles[name] then return end
	if sourceName and db.Profiles[sourceName] then
		db.Profiles[name] = DeepCopy(db.Profiles[sourceName])
	else
		local snapshot = {}
		for _, k in ipairs(M.PayloadKeys) do
			if db[k] ~= nil then snapshot[k] = DeepCopy(db[k]) end
		end
		db.Profiles[name] = snapshot
	end
end

---@param name string
function M:DeleteProfile(name)
	if not db or not db.Profiles then return end
	if not db.Profiles[name] then return end
	if #M:GetProfileNames() <= 1 then return end
	db.Profiles[name] = nil
	if db.AutoSwitch then
		for _, charRules in pairs(db.AutoSwitch) do
			if type(charRules) == "table" then
				for k, v in pairs(charRules) do
					if v == name then charRules[k] = nil end
				end
			end
		end
	end
	if db.ActiveProfile == name then
		local remaining = M:GetProfileNames()
		if remaining[1] then
			local payload = db.Profiles[remaining[1]]
			for _, k in ipairs(M.PayloadKeys) do
				if type(payload[k]) == "table" and type(db[k]) == "table" then
					MutateTableInPlace(db[k], payload[k])
				elseif payload[k] ~= nil then
					db[k] = DeepCopy(payload[k])
				else
					db[k] = nil
				end
			end
			db.ActiveProfile = remaining[1]
			FireProfileChanged(remaining[1])
			addon:Refresh()
		end
	end
end

---@param oldName string
---@param newName string
function M:RenameProfile(oldName, newName)
	if not db or not db.Profiles then return end
	if oldName == newName or not newName or newName == "" then return end
	if db.Profiles[newName] then return end
	db.Profiles[newName] = db.Profiles[oldName]
	db.Profiles[oldName] = nil
	if db.ActiveProfile == oldName then
		db.ActiveProfile = newName
	end
	if db.AutoSwitch then
		for _, charRules in pairs(db.AutoSwitch) do
			if type(charRules) == "table" then
				for k, v in pairs(charRules) do
					if v == oldName then charRules[k] = newName end
				end
			end
		end
	end
	FireProfileChanged(db.ActiveProfile)
end

---@param name string
function M:SwitchProfile(name)
	if not db then return end
	if InCombatLockdown() then
		scheduler:RunWhenCombatEnds(function() M:SwitchProfile(name) end, "ProfileSwitch")
		return
	end
	if not db.Profiles or not db.Profiles[name] then return end
	if db.ActiveProfile == name then return end
	M:SaveCurrentProfile()
	local payload = db.Profiles[name]
	for _, k in ipairs(M.PayloadKeys) do
		if type(payload[k]) == "table" and type(db[k]) == "table" then
			MutateTableInPlace(db[k], payload[k])
		elseif payload[k] ~= nil then
			db[k] = DeepCopy(payload[k])
		else
			db[k] = nil
		end
	end
	db.ActiveProfile = name
	-- Fill any keys that were missing from the snapshot (e.g. added in later migrations).
	migrator:FillDefaults()
	FireProfileChanged(name)
	addon:Refresh()
end

---@param specId number
---@return string?
function M:GetAutoSwitchRule(specId)
	if not db or not db.AutoSwitch then return nil end
	local charKey = GetCharKey()
	if not charKey then return nil end
	local charRules = db.AutoSwitch[charKey]
	if not charRules then return nil end
	return charRules[specId]
end

---@param specId number
---@param profileName string? nil to clear the rule
function M:SetAutoSwitchRule(specId, profileName)
	if not db then return end
	local charKey = GetCharKey()
	if not charKey then return end
	db.AutoSwitch = db.AutoSwitch or {}
	db.AutoSwitch[charKey] = db.AutoSwitch[charKey] or {}
	db.AutoSwitch[charKey][specId] = profileName
end

---Resets the current profile to factory defaults.
---Uses MutateTableInPlace on db.Modules so table references captured by Config UI
---closures at Build time remain valid - controls keep working after the reset.
function M:ResetCurrentProfileToDefaults()
	if not db or not migrator then return end
	-- Reset primitive payload keys; FillDefaults will restore them from dbDefaults.
	for _, k in ipairs(M.PayloadKeys) do
		if k ~= "Modules" then
			db[k] = nil
		end
	end
	-- Reset Modules in-place to preserve table identities held by closures.
	if db.Modules then
		MutateTableInPlace(db.Modules, migrator:GetModuleDefaults())
	end
	migrator:FillDefaults()
	M:SaveCurrentProfile()
end

---@param key string
---@param callback fun(name: string)
function M:RegisterOnProfileChanged(key, callback)
	onProfileChangedCallbacks[key] = callback
end

---@param key string
function M:UnregisterOnProfileChanged(key)
	onProfileChangedCallbacks[key] = nil
end

local function TryAutoSwitch()
	if not db or not db.AutoSwitch then return end
	local charKey = GetCharKey()
	if not charKey then return end
	local charRules = db.AutoSwitch[charKey]
	if not charRules then return end
	local specIdx = GetSpecialization and GetSpecialization()
	if not specIdx then return end
	local specId = GetSpecializationInfo(specIdx)
	if not specId then return end
	local target = charRules[specId]
	if target and db.Profiles and db.Profiles[target] and target ~= db.ActiveProfile then
		M:SwitchProfile(target)
	end
end

function M:Init()
	migrator = addon.Config.Migrator
	db = mini:GetSavedVars()
	-- Ensure at least one profile slot exists. Handles first-time setup where
	-- dbDefaults seeds Profiles = {} (empty), and any unexpected empty state.
	if not db.Profiles or not next(db.Profiles) then
		db.Profiles = db.Profiles or {}
		db.ActiveProfile = db.ActiveProfile or "Default"
		M:CreateProfile("Default", nil)
	end

	local eventsFrame = CreateFrame("Frame")
	eventsFrame:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_SPECIALIZATION_CHANGED"
			or event == "PLAYER_ENTERING_WORLD" then
			TryAutoSwitch()
		end
	end)
	eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	eventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function M:Refresh() end
