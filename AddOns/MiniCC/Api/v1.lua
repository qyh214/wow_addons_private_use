-- MiniCC External API v1
-- Exposes a stable global (MiniCCApi.v1) for other addons to register callbacks.
---@type string, Addon
local _, addon = ...

local fcdModule = addon.Modules.FriendlyCooldowns.Module

---@class MiniCCApiV1
local v1 = {}

---Registers a callback invoked when MiniCC predicts a friendly cooldown is about to start
---(i.e. the associated buff has been detected on the unit).
---The callback receives: unit (string), spellId (number), spellType ("Offensive"|"Defensive").
---@param fn fun(unit: string, spellId: number, spellType: "Offensive"|"Defensive"|"Important")
function v1:RegisterPredictedCallback(fn)
	fcdModule:RegisterPredictedCallback(fn)
end

---Registers a callback invoked when MiniCC commits a matched cooldown rule
---(i.e. the aura has ended and the cooldown timer has started).
---The callback receives: unit (string), spellId (number), spellType ("Offensive"|"Defensive").
---@param fn fun(unit: string, spellId: number, spellType: "Offensive"|"Defensive"|"Important")
function v1:RegisterMatchedCallback(fn)
	fcdModule:RegisterMatchedCallback(fn)
end

MiniCCApi = MiniCCApi or {}
MiniCCApi.v1 = v1
