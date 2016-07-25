-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Item = TSM.modules.Viewer:NewModule("Item")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {filters={}}
local SECONDS_PER_DAY = 24 * 60 * 60



-- ============================================================================
-- ScrollingTable Columns
-- ============================================================================

local ITEM_SUMMARY_ST_COLS_AVG = {
	{name=L["Item Name"], width=0.30, headAlign="LEFT"},
	{name=L["Market Value"], width=0.12, headAlign="LEFT"},
	{name=L["Sold"], width=0.07, headAlign="LEFT"},
	{name=L["Avg Sale"], width=0.12, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Avg Buy"], width=0.12, headAlign="LEFT"},
	{name=L["Failed Since Last Sale"], width=0.20, headAlign="LEFT"},
	defaultSort = 1,
}
local ITEM_SUMMARY_ST_COLS_TOTAL = {
	{name=L["Item Name"], width=0.30, headAlign="LEFT"},
	{name=L["Market Value"], width=0.12, headAlign="LEFT"},
	{name=L["Sold"], width=0.07, headAlign="LEFT"},
	{name=L["Total Sale"], width=0.12, headAlign="LEFT"},
	{name=L["Bought"], width=0.07, headAlign="LEFT"},
	{name=L["Total Buy"], width=0.12, headAlign="LEFT"},
	{name=L["Failed Since Last Sale"], width=0.20, headAlign="LEFT"},
	defaultSort = 1,
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Item:DrawSummary(container)
	local stCols = TSM.db.global.priceFormat == "avg" and ITEM_SUMMARY_ST_COLS_AVG or ITEM_SUMMARY_ST_COLS_TOTAL
	TSM.Viewer:GetItemFiltersInfo(container, "itemSummary", {"Auction", "COD", "Trade", "Vendor"}, private.GetItemSummarySTData, stCols, 4)
end

function Item:DrawLookup(container, itemString, returnTab, returnSubTab)
	container:ReleaseChildren()
	local link = TSMAPI.Item:GetLink(itemString)
	local itemData = private:GetItemDetailData(itemString)

	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")

	local buyers, sellers = {}, {}
	for name, quantity in pairs(itemData.sales.players) do
		tinsert(buyers, { name = name, quantity = quantity })
	end
	for name, quantity in pairs(itemData.buys.players) do
		tinsert(sellers, { name = name, quantity = quantity })
	end
	sort(buyers, function(a, b) return a.quantity > b.quantity end)
	sort(sellers, function(a, b) return a.quantity > b.quantity end)

	local buyersText, sellersText = "", ""
	for i = 1, min(#buyers, 5) do
		buyersText = buyersText .. "|cffffffff" .. buyers[i].name .. "|r" .. color .. "(" .. buyers[i].quantity .. ")|r, "
	end
	for i = 1, min(#sellers, 5) do
		sellersText = sellersText .. "|cffffffff" .. sellers[i].name .. "|r" .. color .. "(" .. sellers[i].quantity .. ")|r, "
	end

	local stCols = {
		{
			name = L["Activity Type"],
			width = 0.15,
			align = "LEFT",
			headAlign = "LEFT",
		},
		{
			name = L["Source"],
			width = 0.14,
			align = "LEFT",
			headAlign = "LEFT",
		},
		{
			name = L["Buyer/Seller"],
			width = 0.15,
			align = "LEFT",
			headAlign = "LEFT",
		},
		{
			name = L["Quantity"],
			width = 0.1,
			align = "LEFT",
			headAlign = "LEFT",
		},
		{
			name = L["Per Item"],
			width = 0.15,
			align = "LEFT",
			headAlign = "LEFT",
		},
		{
			name = L["Total Price"],
			width = 0.15,
			align = "LEFT",
			headAlign = "LEFT",
		},
		{
			name = L["Time"],
			width = 0.15,
			align = "LEFT",
			headAlign = "LEFT",
		},
	}
	local stHandlers = {
		OnClick = function(_, data, self, button)
			if not data then return end
			if button == "RightButton" and IsShiftKeyDown() then
				if data.recordType == "Sale" then
					for i, v in ipairs(TSM.items[itemString].sales) do
						if v == data.record then
							tremove(TSM.items[itemString].sales, i)
							break
						end
					end
				elseif data.recordType == "Purchase" then
					for i, v in ipairs(TSM.items[itemString].buys) do
						if v == data.record then
							tremove(TSM.items[itemString].buys, i)
							break
						end
					end
				end
				for i, v in ipairs(itemData.stData) do
					if v == data then
						tremove(itemData.stData, i)
						break
					end
				end
				TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ITEM", itemData.stData)
				TSM:Print(L["Removed record."])
			end
		end,
		OnEnter = function(_, data, self)
			if not data then return end

			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(L["Shift-Right-Click to delete this record."], 1, .82, 0, 1)
			GameTooltip:Show()
		end,
		OnLeave = function()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end
	}

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
							type = "Label",
							relativeWidth = 0.1,
						},
						{
							type = "InteractiveLabel",
							text = link,
							fontObject = GameFontNormalLarge,
							relativeWidth = 0.4,
							callback = function() TSMAPI.Util:SafeItemRef(link) end,
							tooltip = itemString,
						},
						{
							type = "Label",
							relativeWidth = 0.1,
						},
						{
							type = "Button",
							text = L["Back to Previous Page"],
							relativeWidth = 0.29,
							callback = function()
								if returnSubTab then
									local topTabGroup = container.parent.parent
									-- not sure why, but sometimes the details get displayed within the top tabgroup, rather than the sub-tabgroup
									if topTabGroup.type == "TSMMainFrame" then
										topTabGroup = container
									end
									if topTabGroup.localstatus.selected ~= returnTab then
										topTabGroup:SelectTab(returnTab)
									end
									TSMAPI.Delay:AfterTime(0, function() container:SelectTab(returnSubTab) end)
								else
									container:SelectTab(returnTab)
								end
							end,
						},
					},
				},
				{
					type = "HeadingLine",
				},
				{
					type = "InlineGroup",
					title = L["Sale Data"],
					layout = "Flow",
					backdrop = true,
					children = {},
				},
				{
					type = "InlineGroup",
					title = L["Purchase Data"],
					layout = "Flow",
					backdrop = true,
					children = {},
				},
				{
					type = "ScrollingTable",
					tag = "TSM_ACCOUNTING_ITEM",
					colInfo = stCols,
					handlers = stHandlers,
					defaultSort = -7,
					selectionDisabled = true,
				},
			},
		},
	}

	local sellWidgets, buyWidgets
	if itemData.sales.hasData then
		sellWidgets = {
			{
				type = "MultiLabel",
				labelInfo = TSM.Viewer:GetMultiLabelLine(L["Average Prices:"], itemData.sales, "avg"),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = TSM.Viewer:GetMultiLabelLine(L["Quantity Sold:"], itemData.sales, "num", nil, true),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = TSM.Viewer:GetMultiLabelLine(L["Gold Earned:"], itemData.sales, "price"),
				relativeWidth = 1,
			},
			{
				type = "Label",
				relativeWidth = 1,
				text = color2 .. L["Top Buyers:"] .. " |r" .. buyersText,
			},
		}
	else
		sellWidgets = {
			{
				type = "Label",
				relativeWidth = 1,
				text = "|cffffffff" .. L["There is no sale data for this item."] .. "|r",
			},
		}
	end

	if itemData.buys.hasData then
		buyWidgets = {
			{
				type = "MultiLabel",
				labelInfo = TSM.Viewer:GetMultiLabelLine(L["Average Prices:"], itemData.buys, "avg"),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = TSM.Viewer:GetMultiLabelLine(L["Quantity Bought:"], itemData.buys, "num", nil, true),
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = TSM.Viewer:GetMultiLabelLine(L["Total Spent:"], itemData.buys, "price"),
				relativeWidth = 1,
			},
			{
				type = "Label",
				relativeWidth = 1,
				text = color2 .. L["Top Sellers:"] .. " |r" .. sellersText,
			},
		}
	else
		buyWidgets = {
			{
				type = "Label",
				relativeWidth = 1,
				text = "|cffffffff" .. L["There is no purchase data for this item."] .. "|r",
			},
		}
	end

	local index
	for i = 2, #page[1].children do
		if page[1].children[i].type == "InlineGroup" then
			index = i
			break
		end
	end

	for i = 1, #sellWidgets do
		tinsert(page[1].children[index].children, sellWidgets[i])
	end
	for i = 1, #buyWidgets do
		tinsert(page[1].children[index + 1].children, buyWidgets[i])
	end

	TSMAPI.GUI:BuildOptions(container, page)
	TSMAPI.GUI:UpdateTSMScrollingTableData("TSM_ACCOUNTING_ITEM", itemData.stData)
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private.GetItemSummarySTData(filters)
	local stData = {}

	for itemString, data in pairs(TSM.items) do
		if not TSM.ViewerUtil:IsItemFiltered(itemString, filters) then
			local sellTotal, sellNum = 0, 0
			local lastSold = 0
			for _, record in ipairs(data.sales) do
				if not TSM.ViewerUtil:IsRecordFiltered(record, filters) then
					sellTotal = sellTotal + record.copper * record.quantity
					sellNum = sellNum + record.quantity
				end
				if record.key ~= "Vendor" then
					lastSold = max(lastSold, record.time)
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

			local failedSinceLastSold = 0
			for _, record in ipairs(data.auctions) do
				if record.key == "Cancel" and record.time > lastSold then
					failedSinceLastSold = failedSinceLastSold + record.quantity
				elseif record.key == "Expire" and record.time > lastSold then
					failedSinceLastSold = failedSinceLastSold + record.quantity
				end
			end

			if buyNum > 0 or sellNum > 0 then
				if TSM.db.global.priceFormat == "total" then
					avgSell = sellNum > 0 and sellTotal or 0
					avgBuy = buyNum > 0 and buyTotal or 0
				else
					avgSell = sellNum > 0 and avgSell or 0
					avgBuy = buyNum > 0 and avgBuy or 0
				end
				local marketValue = TSMAPI:GetItemValue(itemString, TSM.db.global.mvSource)
				local row = {
					cols = {
						{
							value = TSMAPI.Item:GetLink(itemString) or data.name,
							sortArg = data.name or itemString,
						},
						{
							value = TSMAPI:MoneyToString(marketValue) or "|cff999999---|r",
							sortArg = marketValue or 0,
						},
						{
							value = sellNum,
							sortArg = sellNum,
						},
						{
							value = avgSell > 0 and TSMAPI:MoneyToString(avgSell) or "|cff999999---|r",
							sortArg = avgSell,
						},
						{
							value = buyNum,
							sortArg = buyNum,
						},
						{
							value = avgBuy > 0 and TSMAPI:MoneyToString(avgBuy) or "|cff999999---|r",
							sortArg = avgBuy,
						},
						{
							value = failedSinceLastSold,
							sortArg = failedSinceLastSold,
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

function private:GetItemDetailData(itemString)
	if not TSM.items[itemString] then return end

	local data = {activity={}, buys={players={}, price={}, num={}, avg={}}, sales={players={}, price={}, num={}, avg={}}, stData={}}

	private:ProcessItemActivity(itemString, data, "buys", "Purchase")
	private:ProcessItemActivity(itemString, data, "sales", "Sale")

	for _, stRecord in ipairs(data.activity) do
		local activityType = stRecord.activityType
		local record = stRecord.record
		local row = {
			cols = {
				{
					value = activityType,
					sortArg = activityType,
				},
				{
					value = record.key,
					sortArg = record.key or "",
				},
				{
					value = record.otherPlayer,
					sortArg = record.otherPlayer,
				},
				{
					value = record.quantity,
					sortArg = record.quantity,
				},
				{
					value = TSMAPI:MoneyToString(record.copper),
					sortArg = record.copper,
				},
				{
					value = TSMAPI:MoneyToString(record.copper * record.quantity),
					sortArg = record.copper * record.quantity,
				},
				{
					value = TSM.ViewerUtil:GetFormattedTime(record.time),
					sortArg = record.time,
				},
			},
			record = record,
			recordType = activityType,
		}
		tinsert(data.stData, row)
	end

	return data
end

function private:ProcessItemActivity(itemString, resultTbl, key, activityType)
	local totalPrice, totalNum = 0, 0
	local monthPrice, monthNum = 0, 0
	local weekPrice, weekNum = 0, 0

	for i, record in ipairs(TSM.items[itemString][key]) do
		resultTbl[key].players[record.otherPlayer] = (resultTbl[key].players[record.otherPlayer] or 0) + record.quantity
		tinsert(resultTbl.activity, {activityType=activityType, record=record})

		totalPrice = totalPrice + record.copper * record.quantity
		totalNum = totalNum + record.quantity
		local timeDiff = time() - record.time
		if timeDiff < (SECONDS_PER_DAY * 30) then
			monthPrice = monthPrice + record.copper * record.quantity
			monthNum = monthNum + record.quantity
		end
		if timeDiff < (SECONDS_PER_DAY * 7) then
			weekPrice = weekPrice + record.copper * record.quantity
			weekNum = weekNum + record.quantity
		end
	end

	resultTbl[key].price.total = totalPrice
	resultTbl[key].price.month = monthPrice
	resultTbl[key].price.week = weekPrice

	resultTbl[key].num.total = totalNum
	resultTbl[key].num.month = monthNum
	resultTbl[key].num.week = weekNum

	resultTbl[key].avg.total = totalNum > 0 and TSMAPI.Util:Round(totalPrice / totalNum) or 0
	resultTbl[key].avg.month = monthNum > 0 and TSMAPI.Util:Round(monthPrice / monthNum) or 0
	resultTbl[key].avg.week = weekNum > 0 and TSMAPI.Util:Round(weekPrice / weekNum) or 0

	if totalNum > 0 then
		resultTbl[key].hasData = true
	end
end
