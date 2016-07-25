-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local LibParse = LibStub("LibParse")
local private = {}

local SECONDS_PER_DAY = 24 * 60 * 60
local TIME_BUCKET = 300 -- group sales/buys within 5 minutes together

--[[
****************************** In-Memory Data Layout ***************************
TSM = {
	items = {
		[itemString] = {
			sales = {
				-- Possible keys: Auction, COD, Trade, Vendor
				{key="...", stackSize=#, quantity=#, time=#, copper=#, player="...", otherPlayer="..."},
				...
			},
			buys = {
				-- Possible keys: Auction, COD, Trade, Vendor
				{key="...", stackSize=#, quantity=#, time=#, copper=#, player="...", otherPlayer="..."},
				...
			},
			auctions = {
				-- Possible keys: Cancel, Expire
				{key="...", stackSize=#, quantity=#, time=#, player="..."},
				...
			},
		},
	},
	money = {
		income = {
			-- Possible keys: Transfer, Garrison
			{key="...", copper=#, time=#, player="...", otherPlayer="..."},
		},
		expense = {
			-- Possible keys: Postage, Repair, Transfer
			{key="...", copper=#, time=#, player="...", otherPlayer="..."},
		},
	},
}
]]

function private:CleanRecord(record)
	record.itemName = nil
	record.itemString = nil
	record.time = floor(record.time)
	record.type = nil
	record.otherPlayer = record.buyer or record.seller or record.destination or record.source or "?"
	record.copper = record.price or record.amount
	record.price = nil
	record.amount = nil
	record.buyer = nil
	record.seller = nil
	record.destination = nil
	record.source = nil
end
function private:LoadItemRecords(csvData, recordType, key)
	local saveTimeIndex = 1
	local saveTimes
	if recordType == "sales" then
		saveTimes = TSMAPI.Util:SafeStrSplit(TSM.db.realm.saveTimeSales, ",")
	elseif recordType == "buys" then
		saveTimes = TSMAPI.Util:SafeStrSplit(TSM.db.realm.saveTimeBuys, ",")
	elseif recordType == "auctions" and key == "Expire" then
		saveTimes = TSMAPI.Util:SafeStrSplit(TSM.db.realm.saveTimeExpires, ",")
	elseif recordType == "auctions" and key == "Cancel" then
		saveTimes = TSMAPI.Util:SafeStrSplit(TSM.db.realm.saveTimeCancels, ",")
	end
	for _, record in ipairs(select(2, LibParse:CSVDecode(csvData)) or {}) do
		local itemString = TSMAPI.Item:ToItemString(record.itemString)
		if itemString and type(record.time) == "number" then
			local itemName = TSM:GetItemName(itemString) or TSMAPI.Item:GetName(itemString) 
			record.key = key or record.source or "Auction"
			private:CleanRecord(record)
			if saveTimes and (record.key == "Auction" or record.key == "Expire" or record.key == "Cancel") then
				record.saveTime = tonumber(saveTimes[saveTimeIndex])
				saveTimeIndex = saveTimeIndex + 1
			end
			TSM.items[itemString] = TSM.items[itemString] or {sales={}, buys={}, auctions={}}
			TSM.items[itemString].name = TSM.items[itemString].name or itemName
			tinsert(TSM.items[itemString][recordType], record)
			TSM.cache[itemString] = TSMAPI.Util:WipeOrCreateTable(TSM.cache[itemString])
		end
	end
	for itemString in ipairs(TSM.items) do
		sort(TSM.items[itemString][recordType], function(a, b) return (a.time or 0) < (b.time or 0) end)
	end
end
function private:LoadMoneyRecords(csvData, recordType)
	TSM.money[recordType] = {}
	local typeTranslation = {}
	if recordType == "income" then
		typeTranslation = {["Money Transfer"]="Transfer", ["Garrison"]="Garrison"}
	elseif recordType == "expense" then
		typeTranslation = {["Money Transfer"]="Transfer", ["Postage"]="Postage", ["Repair Bill"]="Repair"}
	end
	for _, record in ipairs(select(2, LibParse:CSVDecode(csvData)) or {}) do
		record.key = typeTranslation[record.type] or "Transfer"
		if record.key and type(record.time) == "number" then
			private:CleanRecord(record)
			tinsert(TSM.money[recordType], record)
		end
	end
end
function Data:Load()
	-- Decode item records
	TSM.items = {}
	TSM.cache = {}
	TSM.goldLog = {}
	private:LoadItemRecords(TSM.db.realm.csvSales, "sales")
	private:LoadItemRecords(TSM.db.realm.csvBuys, "buys")
	private:LoadItemRecords(TSM.db.realm.csvCancelled, "auctions", "Cancel")
	private:LoadItemRecords(TSM.db.realm.csvExpired, "auctions", "Expire")

	-- Decode money records
	TSM.money = {}
	private:LoadMoneyRecords(TSM.db.realm.csvIncome, "income")
	private:LoadMoneyRecords(TSM.db.realm.csvExpense, "expense")

	-- Decode the gold log
	for player, data in pairs(TSM.db.realm.goldLog) do
		if type(data) == "string" then
			TSM.goldLog[player] = select(2, LibParse:CSVDecode(data))
		end
	end
	TSM.ViewerUtil:PopulateDataCaches()
end

function private:CanCombineRecords(recordA, recordB)
	local keys = {"key", "copper", "stackSize", "player", "otherPlayer"}
	for _, key in ipairs(keys) do
		if recordA[key] ~= recordB[key] then
			return false
		end
	end
	return abs(recordA.time-recordB.time) < TIME_BUCKET
end

function private:InsertItemRecord(itemString, dataType, newRecord)
	newRecord.time = floor(newRecord.time or time())
	newRecord.player = UnitName("player")
	TSM.items[itemString] = TSM.items[itemString] or {sales={}, buys={}, auctions={}}
	for _, record in ipairs(TSM.items[itemString][dataType]) do
		if private:CanCombineRecords(record, newRecord) then
			-- combine with existing record
			record.quantity = record.quantity + newRecord.stackSize -- this is total quantity, not number of stacks
			return
		end
	end
	tinsert(TSM.items[itemString][dataType], newRecord)
	TSM.cache[itemString] = TSMAPI.Util:WipeOrCreateTable(TSM.cache[itemString])
	-- keep the records sorted by time
	sort(TSM.items[itemString][dataType], function(a, b) return (a.time or 0) < (b.time or 0) end)
end
function Data:InsertItemSaleRecord(itemString, key, stackSize, copper, buyer, timeStamp)
	if not (itemString and key and stackSize and copper and buyer and copper > 0) then return end
	if key ~= "Auction" and key ~= "COD" and key ~= "Trade" and key ~= "Vendor" then return end
	private:InsertItemRecord(itemString, "sales", {key=key, stackSize=stackSize, quantity=stackSize, copper=copper, otherPlayer=buyer, time=timeStamp})
end
function Data:InsertItemBuyRecord(itemString, key, stackSize, copper, seller, timeStamp)
	if not (itemString and key and stackSize and copper and seller and copper > 0) then return end
	if key ~= "Auction" and key ~= "COD" and key ~= "Trade" and key ~= "Vendor" then return end
	private:InsertItemRecord(itemString, "buys", {key=key, stackSize=stackSize, quantity=stackSize, copper=copper, otherPlayer=seller, time=timeStamp})
end
function Data:InsertItemAuctionRecord(itemString, key, stackSize, timeStamp)
	if not (itemString and key and stackSize) then return end
	if key ~= "Cancel" and key ~= "Expire" then return end
	private:InsertItemRecord(itemString, "auctions", {key=key, stackSize=stackSize, quantity=stackSize, time=timeStamp})
end

function private:InsertMoneyRecord(dataType, newRecord)
	newRecord.time = floor(time())
	newRecord.player = UnitName("player")
	for _, record in ipairs(TSM.money[dataType]) do
		if private:CanCombineRecords(record, newRecord) then
			-- combine with existing record
			record.copper = record.copper + newRecord.copper
			return
		end
	end
	tinsert(TSM.money[dataType], newRecord)
end
function Data:InsertMoneyIncomeRecord(key, copper, destination, timeStamp)
	if not (key and copper and destination and copper > 0) then return end
	if key ~= "Transfer" and key ~= "Garrison" then return end
	private:InsertMoneyRecord("income", {key=key, copper=copper, otherPlayer=destination, time=timeStamp})
end
function Data:InsertMoneyExpenseRecord(key, copper, destination, timeStamp)
	if not (key and copper and destination and copper > 0) then return end
	if key ~= "Postage" and key ~= "Repair" and key ~= "Transfer" then return end
	private:InsertMoneyRecord("expense", {key=key, copper=copper, otherPlayer=destination, time=timeStamp})
end
