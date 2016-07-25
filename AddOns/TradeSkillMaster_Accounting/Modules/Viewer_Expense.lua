-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Expense = TSM.modules.Viewer:NewModule("Expense")
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



-- ============================================================================
-- Module Functions
-- ============================================================================

function Expense:Draw(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Purchases"], value = 1 }, { text = OTHER, value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		TSM.Viewer:HideScrollingTables()
		if value == 1 then
			TSM.Viewer:GetItemFiltersInfo(self, "buy", {"Auction", "COD", "Trade", "Vendor"}, private.GetBuySTData, ITEM_SELL_BUY_ST_COLS, 2, value)
		elseif value == 2 then
			TSM.Viewer:GetMoneyFiltersInfo(self, "expense", {"Postage", "Repair", "Transfer"}, private.GetExpenseSTData, ITEM_MONEY_ST_COLS, 2, value)
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

function private.GetBuySTData(filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if #data.buys > 0 and not TSM.ViewerUtil:IsItemFiltered(itemString, filters) then
			for _, record in ipairs(data.buys) do
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

function private.GetExpenseSTData(filters)
	local stData = {}
	for _, record in ipairs(TSM.money.expense) do
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
