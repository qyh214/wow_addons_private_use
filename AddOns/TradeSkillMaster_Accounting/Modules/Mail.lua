-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Mail = TSM:NewModule("Mail", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}

local SECONDS_PER_DAY = 24 * 60 * 60
local EXPIRED_MATCH_TEXT = AUCTION_EXPIRED_MAIL_SUBJECT:gsub("%%s", "")
local CANCELLED_MATCH_TEXT = AUCTION_REMOVED_MAIL_SUBJECT:gsub("%%s", "")
local OUTBID_MATCH_TEXT = AUCTION_OUTBID_MAIL_SUBJECT:gsub("%%s", "(.+)")



-- ============================================================================
-- Module Functions
-- ============================================================================

function Mail:OnEnable()
	Mail:RawHook("TakeInboxItem", function(...) Mail:ScanCollectedMail("TakeInboxItem", 1, ...) end, true)
	Mail:RawHook("TakeInboxMoney", function(...) Mail:ScanCollectedMail("TakeInboxMoney", 1, ...) end, true)
	Mail:RawHook("AutoLootMailItem", function(...) Mail:ScanCollectedMail("AutoLootMailItem", 1, ...) end, true)
	Mail:RegisterEvent("MAIL_SHOW", function() TSMAPI.Delay:AfterTime("accountingGetSellers", 0.1, private.RequestSellerInfo, 0.1) end)
	Mail:RegisterEvent("MAIL_CLOSED", function() TSMAPI.Delay:Cancel("accountingGetSellers") end)
	Mail:RawHook("SendMail", private.CheckSendMail, true)
end



-- ============================================================================
-- Inbox Functions
-- ============================================================================

function private:RequestSellerInfo()
	local isDone = true
	for i=1, GetInboxNumItems() do
		local invoiceType, _, seller = GetInboxInvoiceInfo(i)
		if invoiceType and seller == "" then
			isDone = false
		end
	end
	if isDone and GetInboxNumItems() > 0 then
		TSMAPI.Delay:Cancel("accountingGetSellers")
	end
end

function private:CanLootMailIndex(index, copper)
	local MAX_COPPER = 99999999999
	local currentMoney = GetMoney()
	TSMAPI:Assert(currentMoney <= MAX_COPPER)
	-- check if this would put them over the gold cap
	if currentMoney + copper > MAX_COPPER then return end
	local hasItem = select(8, GetInboxHeaderInfo(index))
	if not hasItem or hasItem == 0 then return true end
	for j = 1, ATTACHMENTS_MAX_RECEIVE do
		local link = GetInboxItemLink(index, j)
		local itemString = TSMAPI.Item:ToItemString(link)
		local quantity = select(4, GetInboxItem(index, j)) or 0
		local space = 0
		if itemString then
			for bag = 0, NUM_BAG_SLOTS do
				if TSMAPI.Inventory:ItemWillGoInBag(link, bag) then
					for slot = 1, GetContainerNumSlots(bag) do
						local iString = TSMAPI.Item:ToItemString(GetContainerItemLink(bag, slot))
						if iString == itemString then
							local stackSize = select(2, GetContainerItemInfo(bag, slot))
							local maxStackSize = TSMAPI.Item:GetMaxStack(itemString) or 1
							if (maxStackSize - stackSize) >= quantity then
								return true
							end
						elseif not iString then
							return true
						end
					end
				end
			end
		end
	end
end

-- scans the mail that the player just attempted to collected (Pre-Hook)
function Mail:ScanCollectedMail(oFunc, attempt, index, subIndex)
	local invoiceType, itemName, buyer, bid, _, _, ahcut, _, _, _, quantity = GetInboxInvoiceInfo(index)
	local sender, subject, money, codAmount, _, itemCount = select(3, GetInboxHeaderInfo(index))
	if not subject then return end
	local success = true
	if attempt > 2 then
		if buyer == "" then
			buyer = "?"
		elseif sender == "" then
			sender = "?"
		end
	end

	if invoiceType == "seller" and buyer and buyer ~= "" then -- AH Sales
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local saleTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = TSMAPI.Item:GetLink(itemName)
		local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI.Item:ToItemString(link)
		if itemString and private:CanLootMailIndex(index, (bid - ahcut)) then
			local copper = floor((bid - ahcut) / quantity + 0.5)
			TSM.Data:InsertItemSaleRecord(itemString, "Auction", quantity, copper, buyer, saleTime)
		end
	elseif invoiceType == "buyer" and buyer and buyer ~= "" then -- AH Buys
		local link = (subIndex or 1) == 1 and private:GetFirstInboxItemLink(index) or GetInboxItemLink(index, subIndex or 1)
		local itemString = TSMAPI.Item:ToItemString(link)
		if itemString and private:CanLootMailIndex(index, 0) then
			--might as well grab the name for future lookups
			local name = TSMAPI.Item:GetName(link)
			TSM.db.global.itemStrings[name] = itemString

			local copper = floor(bid / quantity + 0.5)
			local daysLeft = select(7, GetInboxHeaderInfo(index))
			local buyTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
			TSM.Data:InsertItemBuyRecord(itemString, "Auction", quantity, copper, buyer, buyTime)
		end
	elseif codAmount > 0 then -- COD Buys (only if all attachments are same item)
		local link = (subIndex or 1) == 1 and private:GetFirstInboxItemLink(index) or GetInboxItemLink(index, subIndex or 1)
		local itemString = TSMAPI.Item:ToItemString(link)
		if itemString then
			--might as well grab the name for future lookups
			local name = TSMAPI.Item:GetName(link)
			TSM.db.global.itemStrings[name] = itemString

			local total = 0
			local stacks = 0
			local ignore = false
			for i = 1, ATTACHMENTS_MAX_RECEIVE do
				local nameCheck, _, _, count = GetInboxItem(index, i)
				if nameCheck and count then
					if nameCheck == name then
						total = total + count
						stacks = stacks + 1
					else
						ignore = true
					end
				end
			end

			if total ~= 0 and not ignore and private:CanLootMailIndex(index, codAmount) then
				local copper = floor(codAmount / total + 0.5)
				local daysLeft = select(7, GetInboxHeaderInfo(index))
				local buyTime = (time() + (daysLeft - 3) * SECONDS_PER_DAY)
				local maxStack = TSMAPI.Item:GetMaxStack(link)
				for i = 1, stacks do
					local stackSize = (total >= maxStack) and maxStack or total
					TSM.Data:InsertItemBuyRecord(itemString, "COD", stackSize, copper, sender, buyTime)
					total = total - stackSize
					if total <= 0 then break end
				end
			end
		end
	elseif money > 0 and invoiceType ~= "seller" and not strfind(subject, OUTBID_MATCH_TEXT) then
		local str
		if GetLocale() == "deDE" then
			str = gsub(subject, gsub(COD_PAYMENT, TSMAPI.Util:StrEscape("%1$s"), ""), "")
		else
			str = gsub(subject, gsub(COD_PAYMENT, TSMAPI.Util:StrEscape("%s"), ""), "")
		end
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local saleTime = (time() + (daysLeft - 31) * SECONDS_PER_DAY)
		if private:CanLootMailIndex(index, money) then
			if str and strfind(str, "TSM$") then -- payment for a COD the player sent
				local codName = strmatch(str, "([^\(]+)"):trim()
				local qty = strmatch(str, "\(([0-9]+)\)")
				qty = tonumber(qty)
				local itemString = TSM.db.global.itemStrings[codName]
				if itemString then
					local copper = floor(money / qty + 0.5)
					local maxStack = TSMAPI.Item:GetMaxStack(itemString) or 1
					local stacks = ceil(qty / maxStack)

					for i = 1, stacks do
						local stackSize = (qty >= maxStack) and maxStack or qty
						TSM.Data:InsertItemSaleRecord(itemString, "COD", stackSize, copper, sender, saleTime)
						qty = qty - stackSize
						if qty <= 0 then break end
					end
				end
			else -- record a money transfer
				TSM.Data:InsertMoneyIncomeRecord("Transfer", money, sender, saleTime)
			end
		end
	elseif strfind(subject, EXPIRED_MATCH_TEXT) then -- expired auction
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local expiredTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = (subIndex or 1) == 1 and private:GetFirstInboxItemLink(index) or GetInboxItemLink(index, subIndex or 1)
		local qty = select(4, GetInboxItem(index, subIndex or 1)) or 0
		local itemString = TSMAPI.Item:ToItemString(link)
		if private:CanLootMailIndex(index, 0) then
			TSM.Data:InsertItemAuctionRecord(itemString, "Expire", qty, expiredTime)
		end
	elseif strfind(subject, CANCELLED_MATCH_TEXT) then -- cancelled auction
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local cancelledTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = (subIndex or 1) == 1 and private:GetFirstInboxItemLink(index) or GetInboxItemLink(index, subIndex or 1)
		local qty = select(4, GetInboxItem(index, subIndex or 1)) or 0
		local itemString = TSMAPI.Item:ToItemString(link)
		if private:CanLootMailIndex(index, 0) then
			TSM.Data:InsertItemAuctionRecord(itemString, "Cancel", qty, cancelledTime)
		end
	else
		success = false
	end

	if success then
		Mail.hooks[oFunc](index, subIndex)
	elseif (not select(2, GetInboxHeaderInfo(index)) or (invoiceType and (not buyer or buyer == ""))) and attempt <= 5 then
		TSMAPI.Delay:AfterTime("accountingHookDelay", 0.2, function() Mail:ScanCollectedMail(oFunc, attempt + 1, index, subIndex) end)
	elseif attempt > 5 then
		Mail.hooks[oFunc](index, subIndex)
	else
		Mail.hooks[oFunc](index, subIndex)
	end
end



-- ============================================================================
-- Sending Functions
-- ============================================================================

-- scans the mail that the player just attempted to send (Pre-Hook) to see if COD
function private.CheckSendMail(destination, currentSubject, ...)
	local codAmount = GetSendMailCOD()
	local moneyAmount = GetSendMailMoney()
	local mailCost = GetSendMailPrice()
	local subject
	local total = 0
	local ignore = false

	if codAmount ~= 0 then
		for i = 1, 12 do
			local itemName, _, _, count = GetSendMailItem(i)
			if itemName and count then
				if not subject then
					subject = itemName
				end

				if subject == itemName then
					total = total + count
				else
					ignore = true
				end
			end
		end
	else
		ignore = true
	end

	if moneyAmount > 0 then -- add a record for the money transfer
		TSM.Data:InsertMoneyExpenseRecord("Transfer", moneyAmount, destination)
		TSM.Data:InsertMoneyExpenseRecord("Postage", mailCost - moneyAmount, destination)
	else
		-- add a record for the mail cost
		TSM.Data:InsertMoneyExpenseRecord("Postage", mailCost, destination)
	end

	if not ignore then
		Mail.hooks.SendMail(destination, subject .. " (" .. total .. ") TSM", ...)
	else
		Mail.hooks.SendMail(destination, currentSubject, ...)
	end
end

function private:GetFirstInboxItemLink(index)
	if not TSMAccountingMailTooltip then
		CreateFrame("GameTooltip", "TSMAccountingMailTooltip", UIParent, "GameTooltipTemplate")
	end
	TSMAccountingMailTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	TSMAccountingMailTooltip:ClearLines()
	local _, speciesId, level, breedQuality, maxHealth, power, speed, name = TSMAccountingMailTooltip:SetInboxItem(index)
	local link = nil
	if (speciesId or 0) > 0 then
		link = TSMAPI.Item:GetLink(strjoin(":", "p", speciesId, level, breedQuality, maxHealth, power, speed))
	else
		link = GetInboxItemLink(index, 1)
	end
	TSMAccountingMailTooltip:Hide()
	return link
end
