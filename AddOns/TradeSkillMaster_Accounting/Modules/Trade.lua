-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Trade = TSM:NewModule("Trade", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {tradeInfo=nil}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Trade:OnEnable()
	Trade:RegisterEvent("TRADE_ACCEPT_UPDATE", private.OnAcceptUpdate)
	Trade:RegisterEvent("UI_INFO_MESSAGE", private.OnChatMsg)
end



-- ============================================================================
-- Trade Functions
-- ============================================================================

function private.OnAcceptUpdate(_, player, target)
	if (player == 1 or target == 1) and not (GetTradePlayerItemLink(7) or GetTradeTargetItemLink(7)) then
		-- update tradeInfo
		private.tradeInfo = { player = {}, target = {} }
		private.tradeInfo.player.money = tonumber(GetPlayerTradeMoney())
		private.tradeInfo.target.money = tonumber(GetTargetTradeMoney())
		private.tradeInfo.target.name = UnitName("NPC")

		for i = 1, 6 do
			local link = GetTradeTargetItemLink(i)
			local count = select(3, GetTradeTargetItemInfo(i))
			if link then
				tinsert(private.tradeInfo.target, { itemString = TSMAPI.Item:ToItemString(link), count = count })
			end

			local link = GetTradePlayerItemLink(i)
			local count = select(3, GetTradePlayerItemInfo(i))
			if link then
				tinsert(private.tradeInfo.player, { itemString = TSMAPI.Item:ToItemString(link), count = count })
			end
		end
	else
		private.tradeInfo = nil
	end
end

function private.OnChatMsg(_, msg)
	if not TSM.db.global.trackTrades then return end
	if msg == ERR_TRADE_COMPLETE and private.tradeInfo then
		-- trade went through
		if private.tradeInfo.player.money > 0 and #private.tradeInfo.player == 0 and private.tradeInfo.target.money == 0 and #private.tradeInfo.target > 0 then
			-- player bought items
			local itemString, count
			for i = 1, #private.tradeInfo.target do
				local data = private.tradeInfo.target[i]
				if not itemString then
					itemString = data.itemString
					count = data.count
				elseif itemString == data.itemString then
					count = count + data.count
				else
					return
				end
			end
			if not itemString or not count then return
			end
			private.insertInfo = { type = "buys", itemString = itemString, count = count, price = private.tradeInfo.player.money / count }
			private.insertInfo.gotText = TSMAPI.Item:GetLink(itemString) .. "x" .. count
			private.insertInfo.gaveText = TSMAPI:MoneyToString(private.tradeInfo.player.money)
		elseif private.tradeInfo.player.money == 0 and #private.tradeInfo.player > 0 and private.tradeInfo.target.money > 0 and #private.tradeInfo.target == 0 then
			-- player sold items
			local itemString, count
			for i = 1, #private.tradeInfo.player do
				local data = private.tradeInfo.player[i]
				if not itemString then
					itemString = data.itemString
					count = data.count
				elseif itemString == data.itemString then
					count = count + data.count
				else
					return
				end
			end
			if not itemString or not count then return
			end
			private.insertInfo = { type = "sales", itemString = itemString, count = count, price = private.tradeInfo.target.money / count }
			private.insertInfo.gaveText = TSMAPI.Item:GetLink(itemString) .. "x" .. count
			private.insertInfo.gotText = TSMAPI:MoneyToString(private.tradeInfo.target.money)
		else
			private.insertInfo = nil
			return
		end

		if TSM.db.global.autoTrackTrades then
			private:DoInsert()
		else
			if not StaticPopupDialogs["TSMAccountingOnTrade"] then
				StaticPopupDialogs["TSMAccountingOnTrade"] = {
					button1 = YES,
					button2 = NO,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					OnAccept = private.DoInsert,
					OnCancel = function() end,
				}
			end
			StaticPopupDialogs["TSMAccountingOnTrade"].text = format(L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"], private.tradeInfo.target.name, private.insertInfo.gaveText, private.insertInfo.gotText)
			TSMAPI.Util:ShowStaticPopupDialog("TSMAccountingOnTrade")
		end
	end
end

function private:DoInsert()
	if not private.insertInfo then return end
	if private.insertInfo.type == "sales" then
		TSM.Data:InsertItemSaleRecord(private.insertInfo.itemString, "Trade", private.insertInfo.count, private.insertInfo.price, private.tradeInfo.target.name)
	elseif private.insertInfo.type == "buys" then
		TSM.Data:InsertItemBuyRecord(private.insertInfo.itemString, "Trade", private.insertInfo.count, private.insertInfo.price, private.tradeInfo.target.name)
	end
end
