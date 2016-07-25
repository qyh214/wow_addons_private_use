-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local ViewerUtil = TSM:NewModule("ViewerUtil", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}
local SECONDS_PER_DAY = 24 * 60 * 60



-- ============================================================================
-- Module Functions
-- ============================================================================

function ViewerUtil:IsItemFiltered(itemString, filters)
	local name = TSMAPI.Item:GetName(itemString) or TSM.items[itemString].name
	local quality = TSMAPI.Item:GetQuality(itemString) or 0
	if not name then return true end

	if filters.name and not strfind(strlower(name), strlower(filters.name)) then
		return true
	end

	if filters.rarity and quality ~= filters.rarity then
		return true
	end

	if not TSM.db.global.displayGreys and quality == 0 then
		return true
	end

	if filters.group then
		local groupPath = TSMAPI.Groups:GetPath(itemString) or TSMAPI.Groups:GetPath(TSMAPI.Item:ToBaseItemString(itemString))
		if not groupPath or not strfind(groupPath, "^"..TSMAPI.Util:StrEscape(filters.group)) then
			return true
		end
	end
end

function ViewerUtil:IsRecordFiltered(record, filters)
	if filters.player and record.player ~= filters.player then
		return true
	end
	if filters.otherPlayer and record.otherPlayer ~= filters.otherPlayer then
		return true
	end
	if not TSM.db.global.displayTransfers and record.key == "Transfer" then
		return true
	end
	if filters.time and floor(record.time/SECONDS_PER_DAY) < (floor(time()/SECONDS_PER_DAY) - filters.time) then
		return true
	end
	if not record.key or (filters.key and record.key ~= filters.key) then
		return true
	end
end

function ViewerUtil:PopulateDataCaches()
	ViewerUtil.playerListCache = {}

	for _, data in pairs(TSM.items) do
		for _, record in ipairs(data.buys) do
			ViewerUtil.playerListCache[record.player] = record.player
		end
		for _, record in ipairs(data.sales) do
			ViewerUtil.playerListCache[record.player] = record.player
		end
		for _, record in ipairs(data.auctions) do
			ViewerUtil.playerListCache[record.player] = record.player
		end
	end

	for _, record in pairs(TSM.money.income) do
		ViewerUtil.playerListCache[record.player] = record.player
	end
	for _, record in pairs(TSM.money.expense) do
		ViewerUtil.playerListCache[record.player] = record.player
	end
end

function ViewerUtil:RemoveOldData(daysOld)
	local cutOffTime = time() - daysOld * SECONDS_PER_DAY
	local numRecords, numItems = 0, 0

	for itemString, data in pairs(TSM.items) do
		local numLeft = 0
		for _, key in ipairs({"sales", "buys", "auctions"}) do
			for i=#data[key], 1, -1 do
				if data[key][i].time < cutOffTime then
					numRecords = numRecords + 1
					tremove(data[key], i)
				end
			end
			numLeft = numLeft + #data[key]
		end
		if numLeft == 0 then
			TSM.items[itemString] = nil
			numItems = numItems + 1
		end
	end
	for dataType, records in pairs(TSM.money) do
		for i=#records, 1, -1 do
			if records[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(records, i)
			end
		end
	end

	TSM:UpdateBaseItemLookup(true)
	TSM:Printf(L["Removed a total of %s old records and %s items with no remaining records."], numRecords, numItems)
end

-- returns a formatted time in the format that the user has selected
function ViewerUtil:GetFormattedTime(rTime)
	if TSM.db.global.timeFormat == "ago" then
		return format(L["%s ago"], SecondsToTime(time() - rTime) or "?")
	elseif TSM.db.global.timeFormat == "usdate" then
		return date("%m/%d/%y %H:%M", rTime)
	elseif TSM.db.global.timeFormat == "eudate" then
		return date("%d/%m/%y %H:%M", rTime)
	elseif TSM.db.global.timeFormat == "aidate" then
		return date("%y/%m/%d %H:%M", rTime)
	end
end
