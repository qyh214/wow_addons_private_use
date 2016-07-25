-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- loads the localization table --
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing")

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local data = TSM:NewModule("data", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI librarie
local private = {
	petSpeciesCache={},
}

----------------------------------
-- Generates the Bagstate table --
----------------------------------
function data:getEmptyRestoreGroup(container, isGuildBank)
	TSM.util:setSrcBagFunctions("bags")
	local tmp = {}
	local grp = {}
	local restore = {}

	for i, bagid in ipairs(container) do
		for slotid = 1, TSM.util.getContainerNumSlotsSrc(bagid) do
			local id, quan = TSM.util.getContainerItemIDSrc(bagid, slotid)
			if id then
				if not isGuildBank or not TSMAPI.Item:IsSoulbound(bagid, slotid) then
					if not tmp[id] then tmp[id] = 0 end
					tmp[id] = tmp[id] + quan
				end --end if
			end --end if id
		end --end for slots
	end --end for bags

	for i, q in pairs(tmp) do
		grp[i] = q * -1 -- convert to negative number for TSMAPI:MoveItems
		restore[i] = q -- for the restore bagstate
	end
	TSM.db.factionrealm.BagState = restore
	return grp
end

function data:unIndexMoveGroupTree(grpInfo, src, dest)
	local newgrp = {}
	local totalItems = data:getTotalItems(src, dest)
	for groupName, info in pairs(grpInfo) do
		groupName = TSMAPI.Groups:FormatPath(groupName, true)
		for _, opName in ipairs(info.operations) do
			TSMAPI.Operations:Update("Warehousing", opName)
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Warehousing
				TSM:Printf(L["'%s' has a Warehousing operation of '%s' which no longer exists."], groupName, opName)
			else
				-- it's a valid operation
				for itemString in pairs(info.items) do
					itemString = TSMAPI.Item:ToItemString(itemString)
					local totalq = 0
					if totalItems then
						totalq = totalItems[itemString] or 0
					end

					if src == "bags" then -- if moving from bags to bank/gbank
						if opSettings.moveQtyEnabled and opSettings.keepBagQtyEnabled then -- move specified quantity but keep x in bags
							local q = (totalq - opSettings.keepBagQuantity)
							if q > 0 then
								newgrp[itemString] = max(tonumber(q * -1), tonumber(opSettings.moveQuantity * -1))
							end
						elseif opSettings.moveQtyEnabled then -- move specified quantity
							newgrp[itemString] = tonumber(opSettings.moveQuantity * -1)
						elseif opSettings.keepBagQtyEnabled then -- move all but keep x in bags
							local q = totalq - opSettings.keepBagQuantity
							if q > 0 then
								newgrp[itemString] = tonumber(q * -1)
							end
						else -- move everything
							if totalq > 0 then
								newgrp[itemString] = tonumber(totalq * -1)
							end
						end
					else -- move from bank/gbank to bags
						local stacksize = 1
						if opSettings.stackSizeEnabled and opSettings.stackSize then -- only move in multiples of the stack size set
							stacksize = opSettings.stackSize
						end
						if opSettings.moveQtyEnabled and opSettings.keepBankQtyEnabled then -- move specified quantity but keep x in bank
							local q = (totalq - opSettings.keepBankQuantity)
							if q > 0 then
								newgrp[itemString] = floor(min(tonumber(q), tonumber(opSettings.moveQuantity)) / tonumber(stacksize)) * tonumber(stacksize)
							end
						elseif opSettings.moveQtyEnabled then -- move specified quantity
							newgrp[itemString] = floor(tonumber(opSettings.moveQuantity) / tonumber(stacksize)) * tonumber(stacksize)
						elseif opSettings.keepBankQtyEnabled then -- move all but keep x in bank
							local q = totalq - opSettings.keepBankQuantity
							if q > 0 then
								newgrp[itemString] = floor(tonumber(q) / tonumber(stacksize)) * tonumber(stacksize)
							end
						else -- move everything
							if totalq > 0 then
								newgrp[itemString] = floor(tonumber(totalq) / tonumber(stacksize)) * tonumber(stacksize)
							end
						end
					end
				end
			end
		end
	end
	return newgrp
end

function data:unIndexRestockGroupTree(grpInfo, src)
	local newgrp = {}
	local totalItems = data:getTotalItems(src)
	local bagItems = data:getTotalItems("bags")
	for groupName, info in pairs(grpInfo) do
		groupName = TSMAPI.Groups:FormatPath(groupName, true)
		for _, opName in ipairs(info.operations) do
			TSMAPI.Operations:Update("Warehousing", opName)
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Crafting
				TSM:Printf(L["'%s' has a Warehousing operation of '%s' which no longer exists."], groupName, opName)
			else
				-- it's a valid operation
				for itemString in pairs(info.items) do
					local totalq = 0
					if totalItems then
						totalq = totalItems[itemString] or 0
					end
					if opSettings.restockQtyEnabled then -- work out qty to add or remove from bags
						local q
						if opSettings.restockKeepBankQtyEnabled then
							q = min(opSettings.restockQuantity, totalq - opSettings.restockKeepBankQuantity)
						else
							q = opSettings.restockQuantity - (bagItems[itemString] or 0)
						end
						if opSettings.restockStackSizeEnabled and opSettings.restockStackSize then -- only move in multiples of the stack size set
							q = floor(tonumber(q) / tonumber(opSettings.restockStackSize)) * tonumber(opSettings.restockStackSize)
						end
						if q ~= 0 then
							newgrp[itemString] = tonumber(q)
						end
					end
				end
			end
		end
	end
	return newgrp
end

function data:unIndexItem(searchString, src, quantity)
	local newgrp = {}
	local totalItems = data:getTotalItems(src) -- table of itemstrings and total qty in source

	if totalItems then
		local matchedString = TSMAPI.Item:ToBaseItemString(TSMAPI.Item:ToItemString(searchString))
		if matchedString then
			for itemString, totalQty in pairs(totalItems) do
				if TSMAPI.Item:ToBaseItemString(itemString) == matchedString then
					if quantity then
						if src == "bags" then
							newgrp[itemString] = tonumber(quantity * -1)
						else
							newgrp[itemString] = tonumber(quantity)
						end
					else
						if src == "bags" then
							newgrp[itemString] = tonumber(totalQty * -1)
						else
							newgrp[itemString] = tonumber(totalQty)
						end
					end
				end
			end
		else
			for itemString, totalQty in pairs(totalItems) do
				local name = strlower(TSMAPI.Item:GetName(itemString))
				if strfind(name, strlower(searchString)) then
					if quantity then
						if src == "bags" then
							newgrp[itemString] = tonumber(quantity * -1)
						else
							newgrp[itemString] = tonumber(quantity)
						end
					else
						if src == "bags" then
							newgrp[itemString] = tonumber(totalQty * -1)
						else
							newgrp[itemString] = tonumber(totalQty)
						end
					end
				end
			end
		end
	end
	return newgrp
end

function data:getTotalItems(src, dest)
	local results = {}
	if src == "bank" then
		local function ScanBankBag(bag)
			for slot = 1, GetContainerNumSlots(bag) do
				local itemString = TSMAPI.Item:ToBaseItemString(GetContainerItemLink(bag, slot), true)
				if itemString then
					local quantity = select(2, GetContainerItemInfo(bag, slot))
					results[itemString] = (results[itemString] or 0) + quantity
				end
			end
		end

		for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			ScanBankBag(bag)
		end
		ScanBankBag(-1)
		if IsReagentBankUnlocked() then
			ScanBankBag(-3)
		end

		return results
	elseif src == "guildbank" then
		for tab = 1, GetNumGuildBankTabs() do
			if select(5, GetGuildBankTabInfo(tab)) > 0 or IsGuildLeader(UnitName("player")) then
				for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
					local link = GetGuildBankItemLink(tab, slot)
					local itemString = TSMAPI.Item:ToBaseItemString(link, true)
					if itemString then
						if itemString == "i:82800" then
							if not private.petSpeciesCache[link] then
								private.petSpeciesCache[link] = GameTooltip:SetGuildBankItem(tab, slot)
							end
							itemString = private.petSpeciesCache[link] and ("p:" .. private.petSpeciesCache[link])
						end
						local quantity = select(2, GetGuildBankItemInfo(tab, slot))
						results[itemString] = (results[itemString] or 0) + quantity
					end
				end
			end
		end

		return results
	elseif src == "bags" then
		for bag, slot, itemString, quantity in TSMAPI.Inventory:BagIterator(true, true, true) do
			if dest == "bank" or not TSMAPI.Item:IsSoulbound(bag, slot) then
				results[itemString] = (results[itemString] or 0) + quantity
			end
		end

		return results
	end
end
