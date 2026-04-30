---@type string, Addon
local _, addon = ...

-- Dispel type color mapping
local dispelColours = {
	-- https://wago.tools/db2/SpellDispelType
	[0] = DEBUFF_TYPE_NONE_COLOR,
	[1] = DEBUFF_TYPE_MAGIC_COLOR,
	[2] = DEBUFF_TYPE_CURSE_COLOR,
	[3] = DEBUFF_TYPE_DISEASE_COLOR,
	[4] = DEBUFF_TYPE_POISON_COLOR,
	[11] = DEBUFF_TYPE_BLEED_COLOR,
}
local dispelColorCurve

local function InitColourCurve()
	if dispelColorCurve then
		return
	end

	dispelColorCurve = C_CurveUtil.CreateColorCurve()
	dispelColorCurve:SetType(Enum.LuaCurveType.Step)

	for type, colour in pairs(dispelColours) do
		dispelColorCurve:AddPoint(type, colour)
	end
end

---@class UnitAuraWatcher
local M = {}
addon.Core.UnitAuraWatcher = M

---@param watcher Watcher
local function NotifyCallbacks(watcher)
	local callbacks = watcher.State.Callbacks

	if not callbacks or #callbacks == 0 then
		return
	end

	for _, callback in ipairs(callbacks) do
		callback(watcher)
	end
end

---Quick check using updateInfo to avoid a full RebuildStates when nothing we care about changed.
---@param watcher Watcher
---@param updateInfo table?
---@return boolean
local function InterestedIn(watcher, updateInfo)
	if not updateInfo or updateInfo.isFullUpdate then
		return true
	end

	local state = watcher.State
	local unit = state.Unit
	local activeFilters = state.ActiveFilters

	if updateInfo.addedAuras then
		for _, aura in pairs(updateInfo.addedAuras) do
			local id = aura.auraInstanceID
			if id then
				for _, filter in ipairs(activeFilters) do
					if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, id, filter) then
						return true
					end
				end
			end
		end
	end

	if updateInfo.updatedAuraInstanceIDs then
		for _, id in pairs(updateInfo.updatedAuraInstanceIDs) do
			if id then
				for _, filter in ipairs(activeFilters) do
					if not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, id, filter) then
						return true
					end
				end
			end
		end
	end

	-- Removed auras are already gone, so the filter API can't be used.
	-- Instead check whether any removed ID matches one we were tracking.
	if updateInfo.removedAuraInstanceIDs and next(updateInfo.removedAuraInstanceIDs) ~= nil then
		local ccState = state.CcAuraState
		local defState = state.DefensiveState
		local impState = state.ImportantAuraState
		for _, id in pairs(updateInfo.removedAuraInstanceIDs) do
			for _, aura in ipairs(ccState) do
				if aura.AuraInstanceID == id then return true end
			end
			for _, aura in ipairs(defState) do
				if aura.AuraInstanceID == id then return true end
			end
			for _, aura in ipairs(impState) do
				if aura.AuraInstanceID == id then return true end
			end
		end
	end

	return false
end

local function WatcherFrameOnEvent(frame, event, ...)
	local watcher = frame.Watcher
	if not watcher then
		return
	end
	watcher:OnEvent(event, ...)
end

local Watcher = {}
Watcher.__index = Watcher

function Watcher:GetUnit()
	return self.State.Unit
end

---@param callback fun(self: Watcher)
function Watcher:RegisterCallback(callback)
	if not callback then
		return
	end
	self.State.Callbacks[#self.State.Callbacks + 1] = callback
end

function Watcher:IsEnabled()
	return self.State.Enabled
end

function Watcher:Enable()
	if self.State.Enabled then
		return
	end

	local frame = self.Frame
	if not frame then
		return
	end

	frame:RegisterUnitEvent("UNIT_AURA", self.State.Unit)

	if self.State.Events then
		for _, event in ipairs(self.State.Events) do
			frame:RegisterEvent(event)
		end
	end

	self.State.Enabled = true
end

function Watcher:Disable()
	if not self.State.Enabled then
		return
	end

	local frame = self.Frame
	if frame then
		frame:UnregisterAllEvents()
	end

	self.State.Enabled = false
end

---@param notify boolean?
function Watcher:ClearState(notify)
	local state = self.State
	state.CcAuraState = {}
	state.ImportantAuraState = {}
	state.DefensiveState = {}

	if notify then
		NotifyCallbacks(self)
	end
end

function Watcher:ForceFullUpdate()
	-- force a rebuild immediately
	self:OnEvent("UNIT_AURA", self.State.Unit, { isFullUpdate = true })
end

---@param sortRule number
---@param sortDirection number
function Watcher:SetSort(sortRule, sortDirection)
	if self.State.SortRule == sortRule and self.State.SortDirection == sortDirection then
		return
	end
	self.State.SortRule = sortRule
	self.State.SortDirection = sortDirection
	self:ForceFullUpdate()
end

function Watcher:Dispose()
	local frame = self.Frame
	if frame then
		frame:UnregisterAllEvents()
		frame:SetScript("OnEvent", nil)
		frame.Watcher = nil
	end
	self.Frame = nil

	-- ensure we don't keep references alive
	self.State.Callbacks = {}
	self:ClearState(false)
end

---@return AuraInfo[]
function Watcher:GetCcState()
	local unit = self.State.Unit
	if not unit or not UnitExists(unit) or UnitIsDeadOrGhost(unit) then
		return {}
	end

	return self.State.CcAuraState
end

---@return AuraInfo[]
function Watcher:GetImportantState()
	local unit = self.State.Unit
	if not unit or not UnitExists(unit) or UnitIsDeadOrGhost(unit) then
		return {}
	end

	return self.State.ImportantAuraState
end

---@return AuraInfo[]
function Watcher:GetDefensiveState()
	local unit = self.State.Unit
	if not unit or not UnitExists(unit) or UnitIsDeadOrGhost(unit) then
		return {}
	end

	return self.State.DefensiveState
end

---@param unit string
---@param filter string
---@param sortRule number?
---@param sortDirection number?
---@param callback fun(auraData: table, start: number, duration: number, dispelColor: table)
local function IterateAuras(unit, filter, sortRule, sortDirection, callback)
	local auras = C_UnitAuras.GetUnitAuras(unit, filter, nil, sortRule, sortDirection)

	for _, auraData in ipairs(auras) do
		local durationInfo = C_UnitAuras.GetAuraDuration(unit, auraData.auraInstanceID)

		if durationInfo then
			local dispelColor = C_UnitAuras.GetAuraDispelTypeColor(unit, auraData.auraInstanceID, dispelColorCurve)
			callback(auraData, durationInfo, dispelColor)
		end
	end
end

function Watcher:RebuildStates()
	local unit = self.State.Unit

	if not unit then
		return
	end

	if not UnitExists(unit) or UnitIsDeadOrGhost(unit) then
		local state = self.State
		local hasState = next(state.CcAuraState) ~= nil
			or next(state.ImportantAuraState) ~= nil
			or next(state.DefensiveState) ~= nil
		if hasState then
			self:ClearState(true)
		end
		return
	end

	---@type AuraTypeFilter?
	local interestedIn = self.State.InterestedIn
	local interestedInDefensives = not interestedIn or (interestedIn and interestedIn.Defensives)
	local interestedInCC = not interestedIn or (interestedIn and interestedIn.CC)
	local interestedInImportant = not interestedIn or (interestedIn and interestedIn.Important)

	---@type AuraInfo[]
	local ccSpellData = {}
	---@type AuraInfo[]
	local importantSpellData = {}
	---@type AuraInfo[]
	local defensivesSpellData = {}
	local seen = {}

	local sortRule = self.State.SortRule
	local sortDirection = self.State.SortDirection

	-- process big defensives first so we can exclude duplicates from important
	if interestedInDefensives then
		IterateAuras(unit, "HELPFUL|BIG_DEFENSIVE", sortRule, sortDirection, function(auraData, durationInfo, dispelColor)
			-- units out of range produce garbage data, so double check
			local isDefensive = C_UnitAuras.AuraIsBigDefensive(auraData.spellId)

			if issecretvalue(isDefensive) or isDefensive then
				defensivesSpellData[#defensivesSpellData + 1] = {
					IsDefensive = isDefensive,
					SpellId = auraData.spellId,
					SpellName = auraData.name,
					SpellIcon = auraData.icon,
					DurationObject = durationInfo,
					DispelColor = dispelColor,
					AuraInstanceID = auraData.auraInstanceID,
				}
			end

			seen[auraData.auraInstanceID] = true
		end)

		IterateAuras(unit, "HELPFUL|EXTERNAL_DEFENSIVE", sortRule, sortDirection, function(auraData, durationInfo, dispelColor)
			if not seen[auraData.auraInstanceID] then
				defensivesSpellData[#defensivesSpellData + 1] = {
					IsDefensive = true,
					SpellId = auraData.spellId,
					SpellName = auraData.name,
					SpellIcon = auraData.icon,
					DurationObject = durationInfo,
					DispelColor = dispelColor,
					AuraInstanceID = auraData.auraInstanceID,
				}

				seen[auraData.auraInstanceID] = true
			end
		end)
	end

	if interestedInCC then
		IterateAuras(unit, "HARMFUL|CROWD_CONTROL", sortRule, sortDirection, function(auraData, durationInfo, dispelColor)
			-- protect against garbage data
			local isCC = C_Spell.IsSpellCrowdControl(auraData.spellId)

			if issecretvalue(isCC) or isCC then
				ccSpellData[#ccSpellData + 1] = {
					IsCC = isCC,
					SpellId = auraData.spellId,
					SpellName = auraData.name,
					SpellIcon = auraData.icon,
					DurationObject = durationInfo,
					DispelColor = dispelColor,
					AuraInstanceID = auraData.auraInstanceID,
				}
			end

			seen[auraData.auraInstanceID] = true
		end)
	end

	if interestedInImportant then
		local importantFilter = (interestedIn and interestedIn.ImportantFilter) or "HELPFUL|IMPORTANT"

		IterateAuras(unit, importantFilter, sortRule, sortDirection, function(auraData, durationInfo, dispelColor)
			if not seen[auraData.auraInstanceID] then
				-- protect against garbage data
				local isImportant = C_Spell.IsSpellImportant(auraData.spellId)

				if issecretvalue(isImportant) or isImportant then
					importantSpellData[#importantSpellData + 1] = {
						IsImportant = isImportant,
						SpellId = auraData.spellId,
						SpellName = auraData.name,
						SpellIcon = auraData.icon,
						DurationObject = durationInfo,
						DispelColor = dispelColor,
						AuraInstanceID = auraData.auraInstanceID,
					}
				end

				seen[auraData.auraInstanceID] = true
			end
		end)
	end

	-- When unsorted, the API may return auras in a non-deterministic order (observed on Chinese clients).
	-- Sort by AuraInstanceID to ensure a consistent order, respecting the requested direction.
	if sortRule == Enum.UnitAuraSortRule.Unsorted then
		local reversed = sortDirection == Enum.UnitAuraSortDirection.Reverse
		local byInstanceId = reversed
			and function(a, b) return a.AuraInstanceID > b.AuraInstanceID end
			or  function(a, b) return a.AuraInstanceID < b.AuraInstanceID end
		table.sort(ccSpellData, byInstanceId)
		table.sort(importantSpellData, byInstanceId)
		table.sort(defensivesSpellData, byInstanceId)
	end

	local state = self.State
	state.CcAuraState = ccSpellData
	state.ImportantAuraState = importantSpellData
	state.DefensiveState = defensivesSpellData
end

function Watcher:OnEvent(event, ...)
	local state = self.State

	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if unit and unit ~= state.Unit then
			return
		end
		if not InterestedIn(self, updateInfo) then
			return
		end
	elseif event == "ARENA_OPPONENT_UPDATE" then
		local unit = ...
		if unit ~= state.Unit then
			return
		end
	end

	if not state.Unit then
		return
	end

	self:RebuildStates()
	NotifyCallbacks(self)
end

---@param unit string
---@param events string[]?
---@param interestedIn AuraTypeFilter?
---@param sortRule number? -- Enum.UnitAuraSortRule value, defaults to Enum.UnitAuraSortRule.Unsorted
---@param sortDirection number? -- Enum.UnitAuraSortDirection value, defaults to Enum.UnitAuraSortDirection.Normal
---@return Watcher
function M:New(unit, events, interestedIn, sortRule, sortDirection)
	if not unit then
		error("unit must not be nil")
	end

	-- Pre-compute which filters this watcher will query, so InterestedIn
	-- doesn't have to rebuild this list on every UNIT_AURA event.
	local all = not interestedIn
	local activeFilters = {}
	if all or interestedIn.Defensives then
		activeFilters[#activeFilters + 1] = "HELPFUL|BIG_DEFENSIVE"
		activeFilters[#activeFilters + 1] = "HELPFUL|EXTERNAL_DEFENSIVE"
	end
	if all or interestedIn.CC then
		activeFilters[#activeFilters + 1] = "HARMFUL|CROWD_CONTROL"
	end
	if all or interestedIn.Important then
		activeFilters[#activeFilters + 1] = (interestedIn and interestedIn.ImportantFilter) or "HELPFUL|IMPORTANT"
	end

	---@type Watcher
	local watcher = setmetatable({
		Frame = nil,
		State = {
			Unit = unit,
			Events = events,
			Enabled = false,
			Callbacks = {},
			CcAuraState = {},
			ImportantAuraState = {},
			DefensiveState = {},
			InterestedIn = interestedIn,
			ActiveFilters = activeFilters,
			SortRule = sortRule or Enum.UnitAuraSortRule.Unsorted,
			SortDirection = sortDirection or Enum.UnitAuraSortDirection.Normal,
		},
	}, Watcher)

	local frame = CreateFrame("Frame")
	frame.Watcher = watcher
	frame:SetScript("OnEvent", WatcherFrameOnEvent)

	watcher.Frame = frame
	watcher:Enable()

	-- Prime once so state is immediately available to callers that read it
	-- synchronously or via a deferred callback after registering.
	watcher:ForceFullUpdate()

	return watcher
end

InitColourCurve()

---@class AuraTypeFilter
---@field CC boolean?
---@field Important boolean?
---@field Defensives boolean?
---@field ImportantFilter string?  -- overrides the default "HELPFUL|IMPORTANT" filter string

---@class AuraInfo
---@field IsImportant? boolean
---@field IsCC? boolean
---@field IsDefensive? boolean
---@field SpellId number?
---@field SpellIcon string?
---@field SpellName string?
---@field DurationObject table?
---@field DispelColor table?
---@field AuraInstanceID number?

---@class WatcherState
---@field Unit string
---@field Events string[]?
---@field Enabled boolean
---@field Callbacks (fun(self: Watcher))[]
---@field CcAuraState AuraInfo[]
---@field ImportantAuraState AuraInfo[]
---@field DefensiveState AuraInfo[]
---@field InterestedIn AuraTypeFilter
---@field ActiveFilters string[]
---@field SortRule number
---@field SortDirection number

---@class Watcher
---@field Frame table?
---@field State WatcherState
---@field GetCcState fun(self: Watcher): AuraInfo[]
---@field GetImportantState fun(self: Watcher): AuraInfo[]
---@field GetDefensiveState fun(self: Watcher): AuraInfo[]
---@field RegisterCallback fun(self: Watcher, callback: fun(self: Watcher))
---@field GetUnit fun(self: Watcher): string
---@field IsEnabled fun(self: Watcher): boolean
---@field Enable fun(self: Watcher)
---@field Disable fun(self: Watcher)
---@field ClearState fun(self: Watcher, notify: boolean?)
---@field ForceFullUpdate fun(self: Watcher)
---@field SetSort fun(self: Watcher, sortRule: number, sortDirection: number)
---@field Dispose fun(self: Watcher)
