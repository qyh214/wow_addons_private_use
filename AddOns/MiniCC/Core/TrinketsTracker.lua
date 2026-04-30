---@type string, Addon
local _, addon = ...

---@class TrinketsTracker : IModule
local M = {}
addon.Core.TrinketsTracker = M

local defaultSpellId = 336126
local defaultIcon
local callbacks = {}

local function FireCallbacks(unit)
	for _, fn in ipairs(callbacks) do
		fn(unit)
	end
end

---Returns C_PvP arena cooldown duration data for a unit, or nil if not available.
---@param unit string
---@return table?
function M:GetUnitDuration(unit)
	return C_PvP.GetArenaCrowdControlDuration(unit)
end

---Returns the default trinket icon texture.
---@return string
function M:GetDefaultIcon()
	return defaultIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

---Registers a callback fired when trinket cooldown data changes.
---@param fn fun(unit: string|nil)  nil means all units should be refreshed
function M:RegisterCallback(fn)
	callbacks[#callbacks + 1] = fn
end

function M:Refresh() end

function M:Init()
	defaultIcon = C_Spell.GetSpellTexture(defaultSpellId)

	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(_, event, ...)
		if event == "PVP_MATCH_STATE_CHANGED" then
			local matchState = C_PvP.GetActiveMatchState()
			if matchState == Enum.PvPMatchState.StartUp or matchState == Enum.PvPMatchState.Engaged then
				FireCallbacks(nil)
			end
		elseif event == "ARENA_COOLDOWNS_UPDATE" then
			local unit = ...
			FireCallbacks((unit and unit ~= "") and unit or nil)
		elseif event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
			FireCallbacks(nil)
		end
	end)
	frame:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
	frame:RegisterEvent("PVP_MATCH_STATE_CHANGED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
end

---@class TrinketsTracker
---@field Init fun(self: TrinketsTracker)
---@field Refresh fun(self: TrinketsTracker)
---@field GetUnitDuration fun(self: TrinketsTracker, unit: string): table?
---@field GetDefaultIcon fun(self: TrinketsTracker): string
---@field RegisterCallback fun(self: TrinketsTracker, fn: fun(unit: string|nil))
