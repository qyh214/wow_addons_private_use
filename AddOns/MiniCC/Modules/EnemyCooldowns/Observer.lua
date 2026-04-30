---@type string, Addon
local _, addon = ...
local unitAuraWatcher = addon.Core.UnitAuraWatcher

addon.Modules.EnemyCooldowns = addon.Modules.EnemyCooldowns or {}

---@class EnemyCooldownObserver
local O = {}
addon.Modules.EnemyCooldowns.Observer = O

-- entry -> { Watcher, UnitEventFrame }
local watched = {}
local testModeActive = false
local auraChangedCallbacks = {}
local unitFlagsCallbacks = {}
local debuffEvidenceCallbacks = {}
local castCallbacks = {}

local function FireAuraChanged(entry, watcher)
	for _, fn in ipairs(auraChangedCallbacks) do
		fn(entry, watcher)
	end
end

local function FireUnitFlags(unit)
	for _, fn in ipairs(unitFlagsCallbacks) do
		fn(unit)
	end
end

local function FireDebuffEvidence(unit, updateInfo)
	for _, fn in ipairs(debuffEvidenceCallbacks) do
		fn(unit, updateInfo)
	end
end

local function FireCast(unit)
	for _, fn in ipairs(castCallbacks) do
		fn(unit)
	end
end

local function CreateUnitEventFrame(entry)
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(_, event, ...)
		local u = entry.Unit
		if event == "UNIT_FLAGS" then
			FireUnitFlags(u)
		elseif event == "UNIT_AURA" then
			local _, updateInfo = ...
			FireDebuffEvidence(u, updateInfo)
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			-- Enemy spell IDs are always secret values; only record that a cast occurred.
			FireCast(u)
		end
	end)
	return frame
end

local function RegisterUnitEvents(frame, unit)
	-- UNIT_AURA must fire before the watcher's own handler so debuff evidence is
	-- recorded before FireAuraChanged runs. Callers must register events BEFORE
	-- creating/enabling the watcher to preserve this ordering.
	frame:RegisterUnitEvent("UNIT_FLAGS", unit)
	frame:RegisterUnitEvent("UNIT_AURA", unit)
end

local function MakeWatcher(entry)
	local watcher = unitAuraWatcher:New(entry.Unit, nil, { Defensives = true, Important = true })
	watcher:RegisterCallback(function(w)
		if testModeActive then
			return
		end
		if not UnitExists(entry.Unit) then
			return
		end
		FireAuraChanged(entry, w)
	end)
	return watcher
end

---Begins watching a new entry. entry.Unit must be set before calling.
---@param entry EcdWatchEntry
function O:Watch(entry)
	local unitEventFrame = CreateUnitEventFrame(entry)
	RegisterUnitEvents(unitEventFrame, entry.Unit)

	local watcher = MakeWatcher(entry)
	watched[entry] = { Watcher = watcher, UnitEventFrame = unitEventFrame }

	-- Seed: the watcher primed its state before our callback was registered; process it now.
	if not testModeActive then
		FireAuraChanged(entry, watcher)
	end
end

---Re-watches an entry after entry.Unit has changed.
---@param entry EcdWatchEntry
function O:Rewatch(entry)
	local state = watched[entry]
	if not state then
		return
	end

	-- Re-register events BEFORE creating the new watcher to preserve fire order.
	state.UnitEventFrame:UnregisterAllEvents()
	RegisterUnitEvents(state.UnitEventFrame, entry.Unit)

	state.Watcher:Dispose()
	state.Watcher = MakeWatcher(entry)

	if not testModeActive then
		FireAuraChanged(entry, state.Watcher)
	end
end

---Disables watching for an entry without releasing resources.
---@param entry EcdWatchEntry
function O:Disable(entry)
	local state = watched[entry]
	if not state then
		return
	end
	state.UnitEventFrame:UnregisterAllEvents()
	state.Watcher:Disable()
end

---Re-enables watching for an entry after Disable.
---@param entry EcdWatchEntry
function O:Enable(entry)
	local state = watched[entry]
	if not state then
		return
	end
	-- Register events before Watcher:Enable to preserve handler fire order.
	RegisterUnitEvents(state.UnitEventFrame, entry.Unit)
	state.Watcher:Enable()
	state.Watcher:ForceFullUpdate()
end

---@param active boolean
function O:SetTestMode(active)
	testModeActive = active
end

---Registers a callback fired when a watched enemy unit's aura state changes.
---fn(entry, watcher)
---@param fn fun(entry: EcdWatchEntry, watcher: Watcher)
function O:RegisterAuraChangedCallback(fn)
	auraChangedCallbacks[#auraChangedCallbacks + 1] = fn
end

---Registers a callback fired when a watched enemy unit's combat/immune flags change.
---@param fn fun(unit: string)
function O:RegisterUnitFlagsCallback(fn)
	unitFlagsCallbacks[#unitFlagsCallbacks + 1] = fn
end

---Registers a callback fired when a HARMFUL aura is added to a watched enemy unit.
---@param fn fun(unit: string, updateInfo: table?)
function O:RegisterDebuffEvidenceCallback(fn)
	debuffEvidenceCallbacks[#debuffEvidenceCallbacks + 1] = fn
end

---Registers a callback fired when a watched enemy unit casts a spell.
---Enemy spell IDs are always secret, so only the unit string is passed (no spell ID).
---@param fn fun(unit: string)
function O:RegisterCastCallback(fn)
	castCallbacks[#castCallbacks + 1] = fn
end
