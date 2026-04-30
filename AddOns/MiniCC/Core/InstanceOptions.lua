---@type string, Addon
local _, addon = ...
local testIsRaid = nil

---@class InstanceOptions
local M = {}

addon.Core.InstanceOptions = M

---Returns true if the current context is a raid.
---Returns false in arena (which reports as a raid group but is not a raid).
---During test mode, returns the overridden value if one was set.
---@return boolean
function M:IsRaid()
	if testIsRaid ~= nil then
		return testIsRaid
	end
	local _, instanceType = IsInInstance()
	if instanceType == "arena" then
		return false
	end
	return IsInRaid()
end

---@param isRaid boolean?
function M:SetTestIsRaid(isRaid)
	testIsRaid = isRaid
end
