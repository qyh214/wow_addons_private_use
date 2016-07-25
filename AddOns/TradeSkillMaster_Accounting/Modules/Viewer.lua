-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Viewer = TSM:NewModule("Viewer", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {}

local DEFAULT_FILTERS = {
	time = 30,
}


function Viewer:OnInitialize()
	for name, module in pairs(Viewer.modules) do
		Viewer[name] = module
	end
end

function Viewer:GetMultiLabelLine(description, data, key, isPerDay, isNumber, timeframe1, timeframe2)
	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")
	local total = data[key].total
	local month = data[key].month
	local week = data[key].week
	if isPerDay then
		total = TSMAPI.Util:Round(total/data.totalTime)
		month = TSMAPI.Util:Round(month/data.monthTime)
		week = TSMAPI.Util:Round(week/data.weekTime)
	end
	local lines
	if isNumber then
		lines = {
			{ text = color2 .. description, relativeWidth = 0.19 },
			{ text = color .. L["Total:"] .. " |r" .. (total or 0), relativeWidth = 0.22 },
			{ text = color .. format(L["Last %d Days"], timeframe1 or 30) .. " |r" .. (month or 0), relativeWidth = 0.29 },
			{ text = color .. format(L["Last %d Days"], timeframe2 or 7) .. " |r" .. (week or 0), relativeWidth = 0.29 }
		}
	else
		lines = {
			{ text = color2 .. description, relativeWidth = 0.19 },
			{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:MoneyToString(total) or "---"), relativeWidth = 0.22 },
			{ text = color .. format(L["Last %d Days"], timeframe1 or 30) .. ": |r" .. (TSMAPI:MoneyToString(month) or "---"), relativeWidth = 0.29 },
			{ text = color .. format(L["Last %d Days"], timeframe2 or 7) .. ": |r" .. (TSMAPI:MoneyToString(week) or "---"), relativeWidth = 0.29 }
		}
	end
	return lines
end

function Viewer:HideScrollingTables()
	Viewer.Gold:Hide()
end

function Viewer:Load(parent)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	parent:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Revenue"], value = 1 }, { text = L["Expenses"], value = 2 }, { text = L["Failed Auctions"], value = 3 }, { text = L["Items"], value = 4 }, { text = L["Summary"], value = 5 }, { text = L["Player Gold"], value = 6 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		Viewer:HideScrollingTables()
		if value == 1 then
			Viewer.Revenue:Draw(self)
		elseif value == 2 then
			Viewer.Expense:Draw(self)
		elseif value == 3 then
			Viewer.Auction:Draw(self)
		elseif value == 4 then
			Viewer.Item:DrawSummary(self)
		elseif value == 5 then
			Viewer.Summary:Draw(self)
		elseif value == 6 then
			Viewer.Gold:Draw(self)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.ViewerUtil:PopulateDataCaches()
	tabGroup:SelectTab(1)

	Viewer:HookScript(simpleGroup.frame, "OnHide", function()
		Viewer:UnhookAll()
		Viewer:HideScrollingTables()
	end)
end


function Viewer:GetItemFiltersInfo(container, dataType, types, dataFunc, stCols, tab, subTab)
	local rarityList = {[0]=L["None"]}
	for i = 1, 4 do
		rarityList[i] = _G[format("ITEM_QUALITY%d_DESC", i)]
	end
	
	local timeList = {[99]=L["All"], [0]=L["Today"], [1]=L["Yesterday"]}
	for _, days in ipairs({7, 14, 30, 60}) do
		timeList[days] = format(L["Last %d Days"], days)
	end

	local playerList = CopyTable(TSM.ViewerUtil.playerListCache)
	playerList["all"] = L["All"]
	
	local typeList = {["all"] = L["All"]}
	for _, dataType in ipairs(types) do
		typeList[dataType] = dataType
	end
	
	local filters = CopyTable(DEFAULT_FILTERS)
	
	local stHandlers = nil
	if tab then
		stHandlers = {
			OnClick = function(st, data, self)
				if not data then return end
				Viewer.Item:DrawLookup(container, data.itemString, tab, subTab)
				container.children[1]:DoLayout()
			end,
			OnEnter = function(_, data, self)
				if not data then return end
				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, 0.82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
	end
	
	local page = {
		{
			type = "SimpleGroup",
			layout = "TSMFillList",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "EditBox",
							label = L["Search"],
							relativeWidth = 0.18,
							onTextChanged = true,
							callback = function(_, _, value)
								value = value:trim()
								if value == "" then
									filters.name = nil
								else
									filters.name = TSMAPI.Util:StrEscape(value)
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "GroupBox",
							label = L["Group"],
							relativeWidth = 0.19,
							callback = function(_, _, value)
								filters.group = value
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Type"],
							relativeWidth = 0.13,
							list = typeList,
							value = "all",
							callback = function(_, _, key)
								if key == "all" then
									filters.key = nil
								else
									filters.key = key
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Rarity"],
							relativeWidth = 0.16,
							list = rarityList,
							value = 0,
							callback = function(_, _, key)
								if key > 0 then
									filters.rarity = key
								else
									filters.rarity = nil
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Player"],
							relativeWidth = 0.15,
							list = playerList,
							value = "all",
							callback = function(_, _, value)
								if value == "all" then
									filters.player = nil
								else
									filters.player = value
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Timeframe Filter"],
							relativeWidth = 0.18,
							list = timeList,
							value = filters.time or 99,
							callback = function(_, _, value)
								if value == 99 then
									filters.time = nil
								else
									filters.time = value
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
					},
				},
				{ 
					type = "ScrollingTable",
					tag = "TSM_ACCOUNTING_ST_"..dataType,
					colInfo = stCols,
					handlers = stHandlers,
					defaultSort = stCols.defaultSort or 1,
					selectionDisabled = true,
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
	TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
end

function Viewer:GetMoneyFiltersInfo(container, dataType, types, dataFunc, stCols, tab, subTab)
	local timeList = {[99]=L["All"], [0]=L["Today"], [1]=L["Yesterday"]}
	for _, days in ipairs({7, 14, 30, 60}) do
		timeList[days] = format(L["Last %d Days"], days)
	end

	local playerList = CopyTable(TSM.ViewerUtil.playerListCache)
	playerList["all"] = L["All"]
	
	local typeList = {["all"] = L["All"]}
	for _, dataType in ipairs(types) do
		typeList[dataType] = dataType
	end
	
	local filters = CopyTable(DEFAULT_FILTERS)
	
	local stHandlers = nil
	if tab then
		stHandlers = {
			OnEnter = function(_, data, self)
				if not data then return end
				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, 0.82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
	end
	
	local page = {
		{
			type = "SimpleGroup",
			layout = "TSMFillList",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "Dropdown",
							label = L["Type"],
							relativeWidth = 0.13,
							list = typeList,
							value = "all",
							callback = function(_, _, key)
								if key == "all" then
									filters.key = nil
								else
									filters.key = key
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Player"],
							relativeWidth = 0.15,
							list = playerList,
							value = "all",
							callback = function(_, _, value)
								if value == "all" then
									filters.player = nil
								else
									filters.player = value
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
						{
							type = "Dropdown",
							label = L["Timeframe Filter"],
							relativeWidth = 0.18,
							list = timeList,
							value = filters.time or 99,
							callback = function(_, _, value)
								if value == 99 then
									filters.time = nil
								else
									filters.time = value
								end
								TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
							end,
						},
					},
				},
				{ 
					type = "ScrollingTable",
					tag = "TSM_ACCOUNTING_ST_"..dataType,
					colInfo = stCols,
					handlers = stHandlers,
					defaultSort = stCols.defaultSort or 1,
					selectionDisabled = true,
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
	TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ST_"..dataType, dataFunc(filters))
end
