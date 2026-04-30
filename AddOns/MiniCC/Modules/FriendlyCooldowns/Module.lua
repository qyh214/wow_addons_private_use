---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx
local iconSlotContainer = addon.Core.IconSlotContainer
local frames = addon.Core.Frames
local moduleUtil = addon.Utils.ModuleUtil
local moduleName = addon.Utils.ModuleName
local units = addon.Utils.Units
local inspector = addon.Core.Inspector
local trinketsTracker = addon.Core.TrinketsTracker
local instanceOptions = addon.Core.InstanceOptions

-- Loaded before this file in TOC order.
local fcdTalents = addon.Modules.Cooldowns.Talents
local observer = addon.Modules.FriendlyCooldowns.Observer
local brain = addon.Modules.Cooldowns.Brain
local display = addon.Modules.FriendlyCooldowns.Display
local rules = addon.Modules.Cooldowns.Rules

---@class FriendlyCooldownTrackerModule : IModule
local M = {}
addon.Modules.FriendlyCooldowns.Module = M
addon.Modules.FriendlyCooldownTrackerModule = M -- backward compat

local watchEntries = {} ---@type table<table, FcdWatchEntry>  keyed by anchor frame
local testModeActive = false
local editModeActive = false
local observersEnabled = false
local eventsFrame
---@type Db
local db

-- External API callbacks registered via M:RegisterPredictedCallback / M:RegisterMatchedCallback.
local predictedCallbacks = {}
local matchedCallbacks = {}

---Shows or hides an entry's container frame, suppressing display while edit mode is active.
local function ShowHideEntryContainer(frame, anchor)
	if editModeActive then
		frame:Hide()
		return
	end
	frames:ShowHideFrame(frame, anchor, testModeActive, false)
end

local function GetOptions()
	return db and db.Modules.FriendlyCooldownTrackerModule
end

local function GetAnchorOptions()
	local m = GetOptions()
	if not m then
		return nil
	end
	return instanceOptions:IsRaid() and m.Raid or m.Default
end

local SameUnit = function(unitA, unitB) return units:SameUnit(unitA, unitB) end

local function GetEntryForUnit(unit)
	local fallback = nil
	for _, entry in pairs(watchEntries) do
		if SameUnit(entry.Unit, unit) then
			if entry.Anchor:IsShown() then
				return entry
			end
			fallback = entry
		end
	end
	return fallback
end

---Creates or updates the watch entry for a given anchor frame.
---@param anchor table
---@param unit string?
---@return FcdWatchEntry?
local function EnsureEntry(anchor, unit)
	unit = unit or anchor.unit or anchor:GetAttribute("unit")
	if not unit then
		return nil
	end

	if units:IsPetOrMinion(unit) or units:IsCompoundUnit(unit) then
		return nil
	end

	-- Skip NPC units (friendly mobs, scenario NPCs, etc.).
	if not UnitIsPlayer(unit) then
		local existing = watchEntries[anchor]
		if existing then
			-- Cancel pending timers so their closures can't re-show the container later.
			for _, cd in pairs(existing.ActiveCooldowns) do
				if cd.CleanupTimer then cd.CleanupTimer:Cancel() end
				if cd.UsedCharges then
					for _, uc in ipairs(cd.UsedCharges) do
						if uc.Timer then uc.Timer:Cancel() end
					end
				end
			end
			observer:Forget(existing)
			existing.Container:ResetAllSlots()
			existing.Container.Frame:Hide()
			-- Remove from watchEntries so M:Refresh()'s loop and EnableAll don't re-show it.
			watchEntries[anchor] = nil
		end
		return nil
	end

	local options = GetOptions()
	local anchorOptions = GetAnchorOptions()
	if not options or not anchorOptions then
		return nil
	end

	-- ExcludeSelf: keep the watcher running so cast evidence and aura detection still work
	-- for externals cast by the player onto others. The container is hidden in M:Refresh.
	local entry = watchEntries[anchor]

	if not entry then
		local size = tonumber(anchorOptions.Icons.Size) or 32
		local maxIcons = tonumber(anchorOptions.Icons.MaxIcons) or 3
		-- noBorder = true: cooldown icons don't need debuff-style borders
		local container = iconSlotContainer:New(UIParent, maxIcons, size, (anchorOptions.IconSpacing or db.IconSpacing or 2), "Friendly CDs", true, "Friendly CDs")

		entry = {
			Anchor = anchor,
			Unit = unit,
			Container = container,
			TrackedAuras = {},
			ActiveCooldowns = {},
			PredictedGlows = {},
			PredictedGlowDurations = {},
			IsExcludedSelf = anchorOptions.ExcludeSelf and SameUnit(unit, "player") or false,
		}
		watchEntries[anchor] = entry
		observer:Watch(entry)
	elseif entry.Unit ~= unit then
		-- Unit token changed (e.g. frame reassigned after group change)
		entry.Unit = unit
		entry.IsExcludedSelf = anchorOptions.ExcludeSelf and SameUnit(unit, "player") or false
		entry.TrackedAuras = {}
		entry.ActiveCooldowns = {}
		entry.PredictedGlows = {}
		entry.PredictedGlowDurations = {}
		entry.Container:ResetAllSlots()
		observer:Rewatch(entry)
	end

	return entry
end

local function EnsureAllEntries()
	for _, anchor in ipairs(frames:GetAll(true, testModeActive)) do
		EnsureEntry(anchor)
	end
end

local function DisableAll()
	if not observersEnabled then
		return
	end
	observersEnabled = false
	for _, entry in pairs(watchEntries) do
		observer:Disable(entry)
		entry.Container:ResetAllSlots()
		entry.Container.Frame:Hide()
	end
end

local function EnableAll()
	if observersEnabled then
		return
	end
	observersEnabled = true
	for _, entry in pairs(watchEntries) do
		observer:Enable(entry)
	end
end

function M:Refresh()
	local options = GetOptions()
	local anchorOptions = GetAnchorOptions()
	if not options or not anchorOptions then
		return
	end

	local moduleEnabled = moduleUtil:IsModuleEnabled(moduleName.FriendlyCooldownTracker)

	if not moduleEnabled then
		DisableAll()
		return
	end

	EnsureAllEntries()
	EnableAll()

	for anchor, entry in pairs(watchEntries) do
		if anchorOptions.ExcludeSelf and SameUnit(entry.Unit, "player") then
			-- Hide the container but leave the watcher active: aura detection and cast evidence
			-- must still run so external defensives cast by the player are tracked correctly.
			entry.IsExcludedSelf = true
			entry.Container:ResetAllSlots()
			entry.Container.Frame:Hide()
		else
			entry.IsExcludedSelf = false
			local size = tonumber(anchorOptions.Icons.Size) or 32
			local maxIcons = tonumber(anchorOptions.Icons.MaxIcons) or 3
			local rows = math.max(1, tonumber(anchorOptions.Icons.Rows) or 1)
			entry.Container:SetIconSize(size)
			entry.Container:SetCount(maxIcons)
			entry.Container:SetSpacing(anchorOptions.IconSpacing or db.IconSpacing or 2)
			local isDown = anchorOptions.Grow == "DOWN"
			entry.Container:SetRows(isDown and nil or rows, isDown and "CENTER" or anchorOptions.Grow, not isDown and anchorOptions.Grow ~= "RIGHT")
			entry.Container:SetColumns(isDown and (tonumber(anchorOptions.Icons.Columns) or 1) or nil)
			display:AnchorContainer(entry)
			ShowHideEntryContainer(entry.Container.Frame, anchor)
			if entry.Container.Frame:IsShown() then
				display:UpdateDisplay(entry)
			end
		end
	end
end

function M:RefreshDisplays()
	for _, entry in pairs(watchEntries) do
		display:UpdateDisplay(entry)
	end
end

function M:StartTesting()
	testModeActive = true
	observer:SetTestMode(true)
	display:SetTestMode(true)
	M:Refresh()
end

function M:StopTesting()
	testModeActive = false
	observer:SetTestMode(false)
	display:SetTestMode(false)

	for _, entry in pairs(watchEntries) do
		entry.Container:ResetAllSlots()
		entry.Container.Frame:Hide()
	end

	M:Refresh()
end

function M:Init()
	db = mini:GetSavedVars()

	fcdTalents:Init()
	display:Init()

	brain:RegisterWithObserver(observer)

	-- Provide Brain with a way to look up a unit's active cooldowns so PredictSpellIdForUnit
	-- can skip rules whose spell is already on cooldown (e.g. BoF on CD when AW is cast).
	brain:RegisterActiveCooldownsLookup(function(unit)
		local e = GetEntryForUnit(unit)
		return e and e.ActiveCooldowns
	end)

	-- When Brain detects that a buff ended and a rule matched, store the cooldown entry and
	-- schedule a cleanup timer so the icon disappears once the cooldown expires.
	brain:RegisterCooldownCallback(function(ruleUnit, cdKey, cdData, detectedFromEntry)
		-- Store the cooldown in every entry whose unit matches the caster (e.g. a player
		-- tracked by both a party frame and a player frame), falling back to the detecting
		-- entry if no caster entry exists.
		local casterEntries = {}
		for _, e in pairs(watchEntries) do
			if SameUnit(e.Unit, ruleUnit) then
				casterEntries[#casterEntries + 1] = e
			end
		end
		if #casterEntries == 0 then
			casterEntries[1] = detectedFromEntry
		end

		local maxCharges = cdData.MaxCharges
		if maxCharges and maxCharges > 1 then
			-- Multi-charge: check if we can append this use to an existing entry that still
			-- has room (i.e. a previous charge is already recharging for the same spell).
			local existingCd = nil
			for _, e in ipairs(casterEntries) do
				local ex = e.ActiveCooldowns[cdKey]
				if ex and ex.MaxCharges == maxCharges and ex.UsedCharges
					and #ex.UsedCharges < ex.MaxCharges then
					existingCd = ex
					break
				end
			end

			if existingCd then
				-- Append new charge to existing entry without disturbing earlier charge timers.
				-- Charges recharge sequentially: the new charge cannot come back until the previous
				-- one has fully recharged, so its expiry is max(prevExpiry + cooldown, usedAt + cooldown).
				local prevCharge = existingCd.UsedCharges[#existingCd.UsedCharges]
				local newExpiry = math.max(
					prevCharge.Expiry + cdData.Cooldown,
					cdData.StartTime + cdData.Cooldown
				)
				local newCharge = { Expiry = newExpiry }
				for _, e in ipairs(casterEntries) do
					local ex = e.ActiveCooldowns[cdKey]
					if ex and ex.UsedCharges and #ex.UsedCharges < ex.MaxCharges then
						ex.UsedCharges[#ex.UsedCharges + 1] = newCharge
					end
				end
				newCharge.Timer = C_Timer.NewTimer(math.max(0, newExpiry - GetTime()), function()
					for _, e in ipairs(casterEntries) do
						local ex = e.ActiveCooldowns[cdKey]
						if ex and ex.UsedCharges then
							for i, uc in ipairs(ex.UsedCharges) do
								if uc == newCharge then
									table.remove(ex.UsedCharges, i)
									break
								end
							end
							if #ex.UsedCharges == 0 and e.ActiveCooldowns[cdKey] == ex then
								e.ActiveCooldowns[cdKey] = nil
							end
						end
						display:UpdateDisplay(e)
						ShowHideEntryContainer(e.Container.Frame, e.Anchor)
					end
				end)
				-- Update CleanupTimer alias on the shared entry so external code sees the latest timer.
				existingCd.CleanupTimer = newCharge.Timer
			else
				-- No existing entry with room: cancel stale timers and create a fresh entry.
				for _, e in ipairs(casterEntries) do
					local existing = e.ActiveCooldowns[cdKey]
					if existing then
						if existing.CleanupTimer then
							existing.CleanupTimer:Cancel()
						end
						if existing.UsedCharges then
							for _, uc in ipairs(existing.UsedCharges) do
								if uc.Timer then
									uc.Timer:Cancel()
								end
							end
						end
					end
					e.ActiveCooldowns[cdKey] = cdData
				end
				local firstExpiry = cdData.StartTime + cdData.Cooldown
				local firstCharge = { Expiry = firstExpiry }
				cdData.UsedCharges = { firstCharge }
				firstCharge.Timer = C_Timer.NewTimer(math.max(0, firstExpiry - GetTime()), function()
					for _, e in ipairs(casterEntries) do
						local ex = e.ActiveCooldowns[cdKey]
						if ex and ex.UsedCharges then
							for i, uc in ipairs(ex.UsedCharges) do
								if uc == firstCharge then
									table.remove(ex.UsedCharges, i)
									break
								end
							end
							if #ex.UsedCharges == 0 and e.ActiveCooldowns[cdKey] == ex then
								e.ActiveCooldowns[cdKey] = nil
							end
						end
						display:UpdateDisplay(e)
						ShowHideEntryContainer(e.Container.Frame, e.Anchor)
					end
				end)
				cdData.CleanupTimer = firstCharge.Timer
			end
		else
			-- Single charge: cancel any existing timer and replace the entry.
			for _, e in ipairs(casterEntries) do
				local existing = e.ActiveCooldowns[cdKey]
				if existing and existing.CleanupTimer then
					existing.CleanupTimer:Cancel()
				end
				e.ActiveCooldowns[cdKey] = cdData
			end

			-- Schedule a single cleanup timer shared across all caster entries.
			cdData.CleanupTimer = C_Timer.NewTimer(math.max(0, cdData.Remaining), function()
				for _, e in ipairs(casterEntries) do
					if e.ActiveCooldowns[cdKey] == cdData then
						e.ActiveCooldowns[cdKey] = nil
					end
					display:UpdateDisplay(e)
					ShowHideEntryContainer(e.Container.Frame, e.Anchor)
				end
			end)
		end

		-- Update all caster entries immediately. The detected entry's display is handled
		-- by the displayCallback fired at the end of OnWatcherChanged.
		for _, e in ipairs(casterEntries) do
			display:UpdateDisplay(e)
			if e ~= detectedFromEntry then
				ShowHideEntryContainer(e.Container.Frame, e.Anchor)
			end
		end

		-- Notify external API subscribers.
		if next(matchedCallbacks) then
			local unit = casterEntries[1] and casterEntries[1].Unit or detectedFromEntry.Unit
			local spellType = rules.GetSpellType(cdData.SpellId)
			for _, fn in ipairs(matchedCallbacks) do
				securecallfunction(fn, unit, cdData.SpellId, spellType)
			end
		end
	end)

	-- After each watcher update, refresh the detected entry's display.
	brain:RegisterDisplayCallback(function(entry)
		display:UpdateDisplay(entry)
	end)

	-- When a new aura is matched to a predicted spell, glow that icon and drive its countdown
	-- from the aura's own duration so the icon counts down while the buff is active.
	-- For externals, casterUnit is provided and we glow the caster's entries instead of the target's.
	brain:RegisterPredictiveGlowCallback(function(entry, spellId, casterUnit, durationObject)
		local glowEntries
		if casterUnit then
			glowEntries = {}
			for _, e in pairs(watchEntries) do
				if SameUnit(e.Unit, casterUnit) then
					glowEntries[#glowEntries + 1] = e
				end
			end
		end
		if not glowEntries or #glowEntries == 0 then
			glowEntries = { entry }
		end
		for _, e in ipairs(glowEntries) do
			e.PredictedGlows[spellId] = (e.PredictedGlows[spellId] or 0) + 1
			e.PredictedGlowDurations[spellId] = durationObject
			display:UpdateDisplay(e)
			ShowHideEntryContainer(e.Container.Frame, e.Anchor)
		end

		-- Notify external API subscribers.
		if next(predictedCallbacks) then
			local unit = casterUnit or entry.Unit
			local spellType = rules.GetSpellType(spellId)
			for _, fn in ipairs(predictedCallbacks) do
				securecallfunction(fn, unit, spellId, spellType)
			end
		end
	end)

	-- When the aura ends, stop glowing and clear the duration, then refresh the display.
	brain:RegisterPredictiveGlowEndCallback(function(entry, spellId, casterUnit)
		local glowEntries
		if casterUnit then
			glowEntries = {}
			for _, e in pairs(watchEntries) do
				if SameUnit(e.Unit, casterUnit) then
					glowEntries[#glowEntries + 1] = e
				end
			end
		end
		if not glowEntries or #glowEntries == 0 then
			glowEntries = { entry }
		end
		for _, e in ipairs(glowEntries) do
			local count = e.PredictedGlows[spellId]
			if count then
				if count <= 1 then
					e.PredictedGlows[spellId] = nil
					e.PredictedGlowDurations[spellId] = nil
				else
					e.PredictedGlows[spellId] = count - 1
				end
			end
			display:UpdateDisplay(e)
		end
	end)

	-- When a predicted-glow aura's duration is extended (e.g. Combustion, Avatar procs),
	-- refresh PredictedGlowDurations so the icon countdown stays accurate.
	brain:RegisterPredictiveGlowDurationChangedCallback(function(entry, spellId, casterUnit, durationObject)
		local glowEntries
		if casterUnit then
			glowEntries = {}
			for _, e in pairs(watchEntries) do
				if SameUnit(e.Unit, casterUnit) then
					glowEntries[#glowEntries + 1] = e
				end
			end
		end
		if not glowEntries or #glowEntries == 0 then
			glowEntries = { entry }
		end
		for _, e in ipairs(glowEntries) do
			if e.PredictedGlows[spellId] then
				e.PredictedGlowDurations[spellId] = durationObject
				display:UpdateDisplay(e)
			end
		end
	end)

	-- Cancels all active cooldown timers and wipes per-entry state.
	-- Called on PLAYER_ENTERING_WORLD (arena exit) and PVP_MATCH_STATE_CHANGED/StartUp (new match).
	local function ClearAllCooldownState()
		-- Reset the static abilities cache so the next UpdateDisplay rebuilds it with the
		-- correct instanceType (e.g. "raid" or "pvp"), applying hideExternalDefensives if needed.
		display:ResetStaticAbilitiesCache()
		for _, entry in pairs(watchEntries) do
			for _, cd in pairs(entry.ActiveCooldowns) do
				if cd.CleanupTimer then cd.CleanupTimer:Cancel() end
				if cd.UsedCharges then
					for _, uc in ipairs(cd.UsedCharges) do
						if uc.Timer then uc.Timer:Cancel() end
					end
				end
			end
			entry.ActiveCooldowns        = {}
			entry.TrackedAuras           = {}
			entry.PredictedGlows         = {}
			entry.PredictedGlowDurations = {}
			display:UpdateDisplay(entry)
		end
	end

	eventsFrame = CreateFrame("Frame")
	eventsFrame:SetScript("OnEvent", function(_, event)
		if event == "GROUP_ROSTER_UPDATE" then
			C_Timer.After(0, function()
				-- Reset cache so the next UpdateDisplay picks up any instanceType change
				-- (e.g. party -> raid conversion) for hideExternalDefensives.
				display:ResetStaticAbilitiesCache()
				M:Refresh()
			end)
		elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
			-- Defer so Talents updates spec/talent data first.
			C_Timer.After(0, function()
				display:ResetStaticAbilitiesCache()
				M:RefreshDisplays()
			end)
		elseif event == "UNIT_FACTION" then
			M:RefreshDisplays()
		elseif event == "PVP_MATCH_STATE_CHANGED" then
			if C_PvP.GetActiveMatchState() == Enum.PvPMatchState.StartUp then
				-- Arena match is starting: clear all tracked state so the previous match's
				-- cooldowns don't bleed into the new one.
				ClearAllCooldownState()
			end
		elseif event == "PLAYER_ENTERING_WORLD" then
			-- Fired after every loading screen, including when leaving an arena.
			-- Ensures stale cooldowns from the previous match are cleared before
			-- the next arena begins (PVP_MATCH_STATE_CHANGED/StartUp also fires,
			-- but PLAYER_ENTERING_WORLD covers the case where a match ends without
			-- a new StartUp following immediately).
			ClearAllCooldownState()
		end
	end)
	eventsFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	eventsFrame:RegisterEvent("PVP_MATCH_STATE_CHANGED")
	eventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventsFrame:RegisterEvent("UNIT_FACTION")

	EventRegistry:RegisterCallback("EditMode.Enter", function()
		editModeActive = true
		for _, entry in pairs(watchEntries) do
			entry.Container.Frame:Hide()
		end
	end)
	EventRegistry:RegisterCallback("EditMode.Exit", function()
		editModeActive = false
		M:Refresh()
	end)

	-- Refresh trinket slot whenever arena cooldown data changes.
	trinketsTracker:RegisterCallback(function(unit)
		if unit then
			local entry = GetEntryForUnit(unit)
			if entry then
				display:UpdateDisplay(entry)
			end
		else
			M:RefreshDisplays()
		end
	end)

	fcdTalents:RegisterTalentCallback(function(playerName)
		-- Reset the entire static-abilities cache whenever any unit's talent data arrives.
		-- We previously tried to match by unit name, but UnitNameUnmodified can return a secret
		-- value intermittently, silently skipping the invalidation and leaving stale icons.
		-- A full reset is safe: GetStaticAbilities rebuilds only on cache miss, and talent
		-- callbacks are rare events (LibSpec + PvP sync, not per-frame).
		display:ResetStaticAbilitiesCache()
		M:RefreshDisplays()
	end)

	observer:Init()

	if not wowEx:IsDandersEnabled() then
		if CompactUnitFrame_SetUnit then
			hooksecurefunc("CompactUnitFrame_SetUnit", function(frame, unit)
				if not frames:IsFriendlyCuf(frame) then
					return
				end
				if not moduleUtil:IsModuleEnabled(moduleName.FriendlyCooldownTracker) then
					return
				end
				EnsureEntry(frame, unit)
			end)
		end

		if CompactUnitFrame_UpdateVisible then
			hooksecurefunc("CompactUnitFrame_UpdateVisible", function(frame)
				if not frames:IsFriendlyCuf(frame) then
					return
				end
				local entry = watchEntries[frame]
				if not entry then
					return
				end
				if not moduleUtil:IsModuleEnabled(moduleName.FriendlyCooldownTracker) then
					entry.Container.Frame:Hide()
					return
				end
				local options = GetOptions()
				if options then
					ShowHideEntryContainer(entry.Container.Frame, frame)
				end
			end)
		end
	end

	local fs = FrameSortApi and FrameSortApi.v3

	-- When the inspector asynchronously resolves a unit's spec (e.g. cross-realm player whose
	-- spec was nil on first render), rebuild static abilities so the correct spec-specific
	-- defaults are used (e.g. AC vs AW for Holy Paladin before LibSpec delivers real data).
	local function OnInspectorSpecChanged()
		-- GetStaticAbilities caches per unit keyed by specId. When spec was previously nil
		-- and is now resolved, the per-entry cache comparison (cached.specId == specId) will
		-- miss only for the affected unit and rebuild just that entry's ability list.
		C_Timer.After(0, function()
			M:RefreshDisplays()
		end)
	end

	-- Use FrameSort's inspector if available; otherwise start our own.
	if fs and fs.Inspector then
		fs.Inspector:RegisterCallback(OnInspectorSpecChanged)
	else
		inspector:Init()
		inspector:RegisterCallback(OnInspectorSpecChanged)
	end

	if fs and fs.Sorting and fs.Sorting.RegisterPostSortCallback then
		fs.Sorting:RegisterPostSortCallback(function()
			M:Refresh()
		end)
	end

	if DandersFrames and DandersFrames.RegisterCallback then
		DandersFrames.RegisterCallback(eventsFrame, "OnFramesSorted", function()
			M:Refresh()
		end)
	end

	if moduleUtil:IsModuleEnabled(moduleName.FriendlyCooldownTracker) then
		EnsureAllEntries()
	end

	frames:HookCellSpotlightVisibility(function()
		if moduleUtil:IsModuleEnabled(moduleName.FriendlyCooldownTracker) then
			EnsureAllEntries()
		end
	end)

	frames:HookNDuiVisibility(function()
		if moduleUtil:IsModuleEnabled(moduleName.FriendlyCooldownTracker) then
			EnsureAllEntries()
		end
	end)
end

---Registers a callback invoked when a buff is matched to a predicted spell (glow starts).
---Signature: function(unit, spellId, spellType) where spellType is "Offensive", "Defensive", or "Important"
---@param fn function
function M:RegisterPredictedCallback(fn)
	predictedCallbacks[#predictedCallbacks + 1] = fn
end

---Registers a callback invoked when an aura ends and a cooldown rule is committed.
---Signature: function(unit, spellId, spellType) where spellType is "Offensive", "Defensive", or "Important"
---@param fn function
function M:RegisterMatchedCallback(fn)
	matchedCallbacks[#matchedCallbacks + 1] = fn
end

---@class FriendlyCooldownTrackerModule
---@field Init fun(self: FriendlyCooldownTrackerModule)
---@field Refresh fun(self: FriendlyCooldownTrackerModule)
---@field RefreshDisplays fun(self: FriendlyCooldownTrackerModule)
---@field StartTesting fun(self: FriendlyCooldownTrackerModule)
---@field StopTesting fun(self: FriendlyCooldownTrackerModule)
---@field RegisterPredictedCallback fun(self: FriendlyCooldownTrackerModule, fn: function)
---@field RegisterMatchedCallback fun(self: FriendlyCooldownTrackerModule, fn: function)

---@class FcdTrackedAura
---@field StartTime        number                  GetTime() when the aura was first detected
---@field AuraTypes        table<string,boolean>   set of applicable types: "BIG_DEFENSIVE", "IMPORTANT", "EXTERNAL_DEFENSIVE"
---@field SpellId          number                  aura.spellId (may be a secret value)
---@field Evidence         EvidenceSet?            evidence types collected at detection time; nil if none found
---@field CastSnapshot         table<string,number>                     snapshot of lastCastTime at detection; used by OnAuraRemoved to attribute the cooldown to the correct caster
---@field CastSpellIdSnapshot  table<string,{SpellId:number,Time:number}[]>  snapshot of recent non-secret cast spell IDs at detection (list per unit); handles multiple UNIT_SPELLCAST_SUCCEEDED per keypress
---@field PredictedSpellId   number?                SpellId predicted by PredictRule after the backfill window; nil if no match was found
---@field PredictedCasterUnit string?               Unit string of the predicted caster; nil when the caster is the target itself (self-cast)

---@class FcdCooldownEntry
---@field StartTime     number       GetTime() when the defensive was cast (buff start)
---@field Cooldown      number       Total cooldown duration in seconds
---@field Remaining     number       Seconds until the cooldown expires (Cooldown - measuredDuration)
---@field SpellId       number       aura.spellId used for icon lookup (may be a secret value)
---@field IsOffensive   boolean      Whether the spell is treated as offensive
---@field CleanupTimer  table?       C_Timer handle; cancelled and replaced on re-cast

---@class FcdWatchEntry
---@field Anchor          table
---@field Unit            string
---@field Container       IconSlotContainer
---@field TrackedAuras    table<number, FcdTrackedAura>              keyed by auraInstanceID
---@field ActiveCooldowns table<number|string, FcdCooldownEntry>     keyed by rule.SpellId or primaryAuraType_buffDuration_cooldown
---@field PredictedGlows  table<number, number>                      spellId -> active instance count; non-zero means the buff is up and the icon should glow
---@field IsExcludedSelf  boolean                                    set by Module; bypasses Brain's container-visibility guard when true

---@class MatchRuleContext
---@field Evidence EvidenceSet? evidence types present when the aura was detected; nil if none
---@field ActiveCooldowns table? active cooldowns keyed by SpellId; used to deprioritise already-cooling rules
---@field KnownSpellIds number[]? non-secret spell IDs from UNIT_SPELLCAST_SUCCEEDED within the cast window; fast-path checks each in order, falls through on no match
