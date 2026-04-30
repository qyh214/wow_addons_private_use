---@type string, Addon
local _, addon = ...

addon.Modules.Cooldowns = addon.Modules.Cooldowns or {}

---@class PvPTalentSync
local M = {}
addon.Modules.Cooldowns.PvPTalentSync = M
addon.Utils.PvPTalentSync = M -- backward compat

local prefix = "MiniCC:Talents"
local throttleTimer = 3
local callbacks = {}
local frame = CreateFrame("Frame")
local pName = UnitNameUnmodified("player")
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local IsInGroup = IsInGroup
local CTimerNewTimer = C_Timer.NewTimer
local next, securecallfunction, tonumber = next, securecallfunction, tonumber
local Ambiguate = Ambiguate

-- 0=success, 1=duplicate, 2=invalid, 3=toomany; silently disabled on failure.
C_ChatInfo.RegisterAddonMessagePrefix(prefix)

local function GetLocalPvPTalentIds()
	if not (C_SpecializationInfo and C_SpecializationInfo.GetAllSelectedPvpTalentIDs) then
		return nil
	end
	local ids = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
	return (ids and #ids > 0) and ids or nil
end

local function IdsToMessage(ids)
	if not ids then
		return ""
	end
	local parts = {}
	for i, id in ipairs(ids) do
		parts[i] = tostring(id)
	end
	return table.concat(parts, ",")
end

local function MessageToIds(msg)
	if not msg or msg == "" then
		return nil
	end
	local ids = {}
	for part in msg:gmatch("[^,]+") do
		local id = tonumber(part)
		if id then
			ids[#ids + 1] = id
		end
	end
	return #ids > 0 and ids or nil
end

local function FireCallbacks(playerName, pvpTalentIds)
	for _, func in next, callbacks do
		securecallfunction(func, playerName, pvpTalentIds)
	end
end

-- Shared current message updated before either send function fires.
local currentMsg = ""

local PrepareForGroup, PrepareForInstance
do
	local timerGroup = nil
	local function SendToGroup()
		timerGroup = nil
		if IsInGroup(1) then
			local result = SendAddonMessage(prefix, currentMsg, "RAID") -- RAID auto-downgrades to PARTY
			if result == 9 then
				timerGroup = CTimerNewTimer(throttleTimer, SendToGroup)
			end
		end
	end
	function PrepareForGroup()
		currentMsg = IdsToMessage(GetLocalPvPTalentIds())
		if not timerGroup then
			timerGroup = CTimerNewTimer(throttleTimer, SendToGroup)
		end
	end
end

do
	local timerInstance = nil
	local function SendToInstance()
		timerInstance = nil
		if IsInGroup(2) then
			local result = SendAddonMessage(prefix, currentMsg, "INSTANCE_CHAT")
			if result == 9 then
				timerInstance = CTimerNewTimer(throttleTimer, SendToInstance)
			end
		end
	end
	function PrepareForInstance()
		currentMsg = IdsToMessage(GetLocalPvPTalentIds())
		if not timerInstance then
			timerInstance = CTimerNewTimer(throttleTimer, SendToInstance)
		end
	end
end

---Registers a callback that fires whenever a group member's PvP talents are received.
---@param func fun(playerName: string, pvpTalentIds: number[]|nil)
function M:RegisterCallback(func)
	callbacks[#callbacks + 1] = func
end

---Broadcasts own PvP talents and requests them from group members.
function M:RequestSync()
	-- Fire own data immediately for local use.
	FireCallbacks(pName, GetLocalPvPTalentIds())

	if IsInGroup() then
		if IsInGroup(2) then
			SendAddonMessage(prefix, "R", "INSTANCE_CHAT")
		end
		if IsInGroup(1) then
			SendAddonMessage(prefix, "R", "RAID")
		end
	end
end

frame:SetScript("OnEvent", function(_, event, p, msg, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if p == prefix and (channel == "RAID" or channel == "PARTY" or channel == "INSTANCE_CHAT") then
			if msg == "R" then
				if channel == "INSTANCE_CHAT" then
					PrepareForInstance()
				else
					PrepareForGroup()
				end
				return
			end
			local playerName = Ambiguate(sender, "none")
			FireCallbacks(playerName, MessageToIds(msg))
		end
	elseif event == "GROUP_FORMED" then
		M:RequestSync()
	elseif event == "PLAYER_PVP_TALENT_UPDATE" then
		-- Broadcast updated talents and notify local callbacks.
		FireCallbacks(pName, GetLocalPvPTalentIds())
		if IsInGroup() then
			if IsInGroup(2) then
				PrepareForInstance()
			end
			if IsInGroup(1) then
				PrepareForGroup()
			end
		end
	elseif event == "PLAYER_LOGIN" then
		M:RequestSync()
	end
end)

frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("GROUP_FORMED")
frame:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN")
