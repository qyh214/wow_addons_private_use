-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Revenue = TSM.modules.Viewer:NewModule("Revenue")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {filters={}}



-- ============================================================================
-- ScrollingTable Columns
-- ============================================================================

local ITEM_SELL_BUY_ST_COLS = {
	{name=L["Item Name"], width=0.34, headAlign="LEFT"},
	{name=L["Player"], width=0.1, headAlign="LEFT"},
	{name=L["Type"], width=0.06, headAlign="LEFT"},
	{name=L["Stack"], width=0.05, headAlign="LEFT"},
	{name=L["Aucs"], width=0.05, headAlign="LEFT"},
	{name=L["Per Item"], width=0.12, headAlign="LEFT"},
	{name=L["Total Price"], width=0.13, headAlign="LEFT"},
	{name=L["Time"], width=0.14, headAlign="LEFT"},
	defaultSort = -8,
}
local ITEM_MONEY_ST_COLS = {
	{name=L["Type"], width=0.2, headAlign="LEFT"},
	{name=L["Player"], width=0.2, headAlign="LEFT"},
	{name=L["Other Player"], width=0.2, headAlign="LEFT"},
	{name=L["Amount"], width=0.15, headAlign="LEFT"},
	{name=L["Time"], width=0.15, headAlign="LEFT"},
	defaultSort = -5,
}
local ITEM_RESALE_ST_COLS_AVG = {
	{name=L["Item Name"], width=0.37, headAlign="LEFT"},
	{name=L["Sold"], width=0.06, headAlign="LEFT"},
	{name=L["Avg Sell Price"], width=0.14, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Avg Buy Price"], width=0.14, headAlign="LEFT"},
	{name=L["Avg Resale Profit"], width=0.21, headAlign="LEFT"},
	defaultSort = -6,
}
local ITEM_RESALE_ST_COLS_TOTAL = {
	{name=L["Item Name"], width=0.37, headAlign="LEFT"},
	{name=L["Sold"], width=0.06, headAlign="LEFT"},
	{name=L["Total Sale Price"], width=0.14, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Total Buy Price"], width=0.14, headAlign="LEFT"},
	{name=L["Avg Resale Profit"], width=0.21, headAlign="LEFT"},
	defaultSort = -6,
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Revenue:Draw(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Sales"], value = 1 }, { text = L["Other Income"], value = 2 }, { text = L["Resale"], value = 3 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		TSM.Viewer:HideScrollingTables()
		if value == 1 then
			TSM.Viewer:GetItemFiltersInfo(self, "sales", {"Auction", "COD", "Trade", "Vendor"}, private.GetSaleSTData, ITEM_SELL_BUY_ST_COLS, 1, value)
		elseif value == 2 then
			TSM.Viewer:GetMoneyFiltersInfo(self, "income", {"Transfer", "Garrison"}, private.GetIncomeSTData, ITEM_MONEY_ST_COLS, 1, value)
		elseif value == 3 then
			local stCols = TSM.db.global.priceFormat == "avg" and ITEM_RESALE_ST_COLS_AVG or ITEM_RESALE_ST_COLS_TOTAL
			TSM.Viewer:GetItemFiltersInfo(self, "resale", {"Auction", "COD", "Trade", "Vendor"}, private.GetResaleSTData, stCols, 1, value)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.ViewerUtil:PopulateDataCaches()
	tabGroup:SelectTab(1)
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private.GetSaleSTData(filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if #data.sales > 0 and not TSM.ViewerUtil:IsItemFiltered(itemString, filters) then
			for _, record in ipairs(data.sales) do
				if not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
					local row = {
						cols = {
							{
								value = TSMAPI.Item:GetLink(itemString) or data.name,
								sortArg = data.name or itemString,
							},
							{
								value = record.player,
								sortArg = record.player,
							},
							{
								value = record.key,
								sortArg = record.key,
							},
							{
								value = record.stackSize,
								sortArg = record.stackSize,
							},
							{
								value = floor(record.quantity / record.stackSize),
								sortArg = floor(record.quantity / record.stackSize),
							},
							{
								value = TSMAPI:MoneyToString(record.copper),
								sortArg = record.copper,
							},
							{
								value = TSMAPI:MoneyToString(record.copper*record.quantity),
								sortArg = record.copper*record.quantity,
							},
							{
								value = TSM.ViewerUtil:GetFormattedTime(record.time),
								sortArg = record.time,
							},
						},
						itemString = itemString,
						record = record,
					}
					tinsert(stData, row)
				end
			end
		end
	end
	return stData
end

function private.GetIncomeSTData(filters)
	local stData = {}
	for _, record in ipairs(TSM.money.income) do
		if not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
			local row = {
				cols = {
					{
						value = record.key,
						sortArg = record.key,
					},
					{
						value = record.player,
						sortArg = record.player,
					},
					{
						value = record.otherPlayer,
						sortArg = record.otherPlayer,
					},
					{
						value = TSMAPI:MoneyToString(record.copper),
						sortArg = record.copper,
					},
					{
						value = TSM.ViewerUtil:GetFormattedTime(record.time),
						sortArg = record.time,
					},
				},
			}
			tinsert(stData, row)
		end
	end
	return stData
end

function private.GetResaleSTData(filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if not TSM.ViewerUtil:IsItemFiltered(itemString, filters) then
			local sellTotal, sellNum = 0, 0
			for _, record in ipairs(data.sales) do
				if not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
					sellTotal = sellTotal + record.copper * record.quantity
					sellNum = sellNum + record.quantity
				end
			end
			local avgSell = TSMAPI.Util:Round(sellTotal / sellNum) or 0

			local buyTotal, buyNum = 0, 0
			for _, record in ipairs(data.buys) do
				if not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
					buyTotal = buyTotal + record.copper * record.quantity
					buyNum = buyNum + record.quantity
				end
			end
			local avgBuy = TSMAPI.Util:Round(buyTotal / buyNum) or 0

			local isValidItem
			local profit, profitText
			if buyNum > 0 and sellNum > 0 then
				profit = avgSell - avgBuy
				local profitPercent = TSMAPI.Util:Round(100 * profit / avgBuy)
				local color = profit > 0 and "|cff00ff00" or "|cffff0000"
				profitText = TSMAPI:MoneyToString(profit, color) .. " (" .. color .. profitPercent .. "%|r)"
				isValidItem = true
			end

			if isValidItem then
				if TSM.db.global.priceFormat == "total" then
					avgSell = sellNum > 0 and sellTotal or 0
					avgBuy = buyNum > 0 and buyTotal or 0
				else
					avgSell = sellNum > 0 and avgSell or 0
					avgBuy = buyNum > 0 and avgBuy or 0
				end
				local row = {
					cols = {
						{
							value = TSMAPI.Item:GetLink(itemString) or data.name,
							sortArg = data.name or itemString,
						},
						{
							value = sellNum,
							sortArg = sellNum,
						},
						{
							value = TSMAPI:MoneyToString(avgSell),
							sortArg = avgSell,
						},
						{
							value = buyNum,
							sortArg = buyNum,
						},
						{
							value = TSMAPI:MoneyToString(avgBuy),
							sortArg = avgBuy,
						},
						{
							value = profitText,
							sortArg = profit,
						},
					},
					itemString = itemString,
					totalNum = sellNum + buyNum,
				}
				tinsert(stData, row)
			end
		end
	end

	return stData
end
