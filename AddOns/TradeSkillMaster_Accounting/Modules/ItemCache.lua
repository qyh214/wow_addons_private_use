-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local ItemCache = TSM:NewModule("ItemCache", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function ItemCache:OnEnable()
	ItemCache:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", private.ScanAuctionItems)
	ItemCache:RegisterEvent("BAG_UPDATE", function() TSMAPI.Delay:AfterTime("accountingItemCacheBagUpdate", 0.1, private.OnBagChange) end)
end



-- ============================================================================
-- Scan Functions
-- ============================================================================

-- scans the bags to help build the name -> itemString lookup table
function private.OnBagChange()
	for bag=0, NUM_BAG_SLOTS do
		for slot=1, GetContainerNumSlots(bag) do
			local itemString = TSMAPI.Item:ToItemString(GetContainerItemLink(bag, slot))
			local name = TSMAPI.Item:GetName(itemString)
			if name then
				TSM.db.global.itemStrings[name] = itemString
			end
		end
	end
end

-- scans the player's current auctions to build up the name -> itemString lookup table
function private:ScanAuctionItems()
	for i=1, GetNumAuctionItems("owner") do
		local name = GetAuctionItemInfo("owner", i)
		if name then
			TSM.db.global.itemStrings[name] = TSMAPI.Item:ToItemString(GetAuctionItemLink("owner", i))
		end
	end
end
