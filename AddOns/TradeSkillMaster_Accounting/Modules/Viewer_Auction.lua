-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Auction = TSM.modules.Viewer:NewModule("Auction")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {filters={}}



-- ============================================================================
-- ScrollingTable Columns
-- ============================================================================

local ITEM_AUCTION_ST_COLS = {
	{name=L["Item Name"], width=0.5, headAlign="LEFT"},
	{name=L["Player"], width=0.15, headAlign="LEFT"},
	{name=L["Stack"], width=0.1, headAlign="LEFT"},
	{name=L["Aucs"], width=0.1, headAlign="LEFT"},
	{name=L["Time"], width=0.15, headAlign="LEFT"},
	defaultSort = -5,
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Auction:Draw(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Expired"], value = 1 }, { text = L["Cancelled"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		TSM.Viewer:HideScrollingTables()
		if value == 1 then
			TSM.Viewer:GetItemFiltersInfo(self, "expired", {}, private.GetExpireSTData, ITEM_AUCTION_ST_COLS, 3, value)
		elseif value == 2 then
			TSM.Viewer:GetItemFiltersInfo(self, "cancelled", {}, private.GetCancelSTData, ITEM_AUCTION_ST_COLS, 3, value)
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

function private.GetExpireSTData(filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if #data.auctions > 0 and not TSM.ViewerUtil:IsItemFiltered(itemString, filters) then
			for _, record in ipairs(data.auctions) do
				if record.key == "Expire" and not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
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
								value = record.stackSize,
								sortArg = record.stackSize,
							},
							{
								value = record.quantity / record.stackSize,
								sortArg = record.quantity / record.stackSize,
							},
							{
								value = TSM.ViewerUtil:GetFormattedTime(record.time),
								sortArg = record.time,
							},
						},
						itemString = itemString,
					}
					tinsert(stData, row)
				end
			end
		end
	end
	return stData
end

function private.GetCancelSTData(filters)
	local stData = {}
	for itemString, data in pairs(TSM.items) do
		if #data.auctions > 0 and not TSM.ViewerUtil:IsItemFiltered(itemString, filters) then
			for _, record in ipairs(data.auctions) do
				if record.key == "Cancel" and not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
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
								value = record.stackSize,
								sortArg = record.stackSize,
							},
							{
								value = record.quantity / record.stackSize,
								sortArg = record.quantity / record.stackSize,
							},
							{
								value = TSM.ViewerUtil:GetFormattedTime(record.time),
								sortArg = record.time,
							},
						},
						itemString = itemString,
					}
					tinsert(stData, row)
				end
			end
		end
	end
	return stData
end
