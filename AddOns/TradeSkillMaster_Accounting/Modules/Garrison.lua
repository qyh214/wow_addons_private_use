-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Garrison = TSM:NewModule("Garrison", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}
local GOLD_TRAIT_ID = 256 -- traitId for the treasure hunter trait which increases gold from missions



-- ============================================================================
-- Module Functions
-- ============================================================================

function Garrison:OnEnable()
	Garrison:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE", private.MissionComplete)
end



-- ============================================================================
-- Misson Reward Tracking
-- ============================================================================

function private.MissionComplete(_, missionId)
	local moneyAward = 0
	local info = C_Garrison.GetBasicMissionInfo(missionId)
	if not info then return end
	for _, reward in pairs(info.rewards) do
		if reward.title == GARRISON_REWARD_MONEY and reward.currencyID == 0 then
			moneyAward = moneyAward + reward.quantity
		end
	end
	if moneyAward > 0 then
		-- check for followers which give bonus gold
		local multiplier = 1
		for _, followerId in ipairs(info.followers) do
			for _, trait in ipairs(C_Garrison.GetFollowerAbilities(followerId)) do
				if trait.id == GOLD_TRAIT_ID then
					multiplier = multiplier + 1
				end
			end
		end
		moneyAward = moneyAward * multiplier
		TSM.Data:InsertMoneyIncomeRecord("Garrison", moneyAward, "Mission", time())
	end
end