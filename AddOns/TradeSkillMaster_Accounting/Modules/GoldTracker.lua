-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local GoldTracker = TSM:NewModule("GoldTracker", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {playerName=nil, guildVaultOpen=nil, guildName=nil}



-- ============================================================================
-- Module Functions
-- ============================================================================

function GoldTracker:OnEnable()
	GoldTracker:RegisterEvent("GUILDBANKFRAME_OPENED", function() private.guildVaultOpen = true end)
	GoldTracker:RegisterEvent("GUILDBANKFRAME_CLOSED", function() private.guildVaultOpen = nil end)
	TSMAPI.Threading:StartImmortal(private.TrackerThread, 0.3)
end

function GoldTracker:LoggingOut()
	private:LogPlayerGold()
	private:LogGuildGold()
end



-- ============================================================================
-- Tracker Thread
-- ============================================================================

function private.TrackerThread(self)
	self:SetThreadName("ACCOUNTING_GOLD_TRACKER")
	private.playerName = self:WaitForFunction(UnitName, "player")
	if not TSM.goldLog[private.playerName] then
		TSM.goldLog[private.playerName] = {}
	end

	while true do
		private.guildName = GetGuildInfo("player")
		if private.guildName and not TSM.goldLog[private.guildName] then
			TSM.goldLog[private.guildName] = {}
		end
		private:LogPlayerGold()
		private:LogGuildGold()
		self:Sleep(0.5)
	end
end



-- ============================================================================
-- Logging Functions
-- ============================================================================

function private:LogGold(goldLog, copper, minute)
	local prevRecord = #goldLog > 0 and goldLog[#goldLog]

	if prevRecord and copper == prevRecord.copper then
		-- amount of gold hasn't changed, so just update the end minute
		prevRecord.endMinute = minute
	elseif prevRecord and prevRecord.startMinute == minute then
		-- gold has changed and the previous record is for the current minute so just modify it
		prevRecord.copper = copper
	else
		-- amount of gold changed and we're in a new minute, so insert a new record
		while prevRecord and prevRecord.startMinute > minute - 1 do
			-- their clock may have changed - just delete everything that's too recent
			tremove(goldLog)
			prevRecord = #goldLog > 0 and goldLog[#goldLog]
		end
		if prevRecord then
			prevRecord.endMinute = minute - 1
		end
		tinsert(goldLog, {startMinute=minute, endMinute=minute, copper=copper})
	end
end

local lastTrackMinute = 0
local lastTrackCopper = -1
function private:LogPlayerGold()
	local currentMinute = floor(time() / 60)
	local currentCopper = TSMAPI.Util:Round(GetMoney(), COPPER_PER_GOLD * 1000)
	if currentMinute <= lastTrackMinute and currentCopper == lastTrackCopper then return end
	lastTrackMinute = currentMinute
	lastTrackCopper = currentCopper
	private:LogGold(TSM.goldLog[private.playerName], currentCopper, currentMinute)
end

local lastGuildTrackMinute = 0
local lastGuildTrackCopper = 0
function private:LogGuildGold()
	if not private.guildVaultOpen or not IsGuildLeader() or not private.guildName then return end
	local currentMinute = floor(time() / 60)
	local currentCopper = TSMAPI.Util:Round(GetGuildBankMoney(), COPPER_PER_GOLD * 1000)
	if currentMinute <= lastGuildTrackMinute and currentCopper == lastGuildTrackCopper then return end
	lastGuildTrackMinute = currentMinute
	lastGuildTrackCopper = currentCopper
	private:LogGold(TSM.goldLog[private.guildName], currentCopper, currentMinute)
end
