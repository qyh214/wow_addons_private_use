-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Summary = TSM.modules.Viewer:NewModule("Summary")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {filters={}}
local SECONDS_PER_DAY = 24 * 60 * 60



-- ============================================================================
-- Module Functions
-- ============================================================================

function Summary:Draw(container)
	if private.filters.isReloading then
		private.filters.isReloading = nil
	else
		wipe(private.filters) -- reset options on fresh update
		private.filters.timeframe = 1
	end

	-- get all the data
	local goldData = {
		sales = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		income = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		buys = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		expense = {total=0, month=0, week=0, topGold={}, topQuantity={}},
		profit = {total=0, month=0, week=0},
		totalTime = 0,
		monthTime = 0,
		weekTime = 0,
	}

	-- determine current time frame
	local timeframes = {"30/7", "90/7", "90/14", "7/1", "7/3"}
	local timeframe1, timeframe2 = ("/"):split(timeframes[private.filters.timeframe])
	timeframe1 = tonumber(timeframe1)
	timeframe2 = tonumber(timeframe2)

	for itemString, data in pairs(TSM.items) do
		if not TSM.ViewerUtil:IsItemFiltered(itemString, private.filters) then
			private:ProcessSummaryItemData(data.sales, goldData.sales, itemString, goldData, timeframe1, timeframe2)
			private:ProcessSummaryItemData(data.buys, goldData.buys, itemString, goldData, timeframe1, timeframe2)
		end
	end

	private:ProcessSummaryMoneyData(TSM.money.income, goldData.income, goldData, timeframe1, timeframe2)
	private:ProcessSummaryMoneyData(TSM.money.expense, goldData.expense, goldData, timeframe1, timeframe2)

	goldData.sales.topGold.link = private:GetItemDisplayLink(goldData.sales.topGold.itemString)
	goldData.sales.topQuantity.link = private:GetItemDisplayLink(goldData.sales.topQuantity.itemString)
	goldData.buys.topGold.link = private:GetItemDisplayLink(goldData.buys.topGold.itemString)
	goldData.buys.topQuantity.link = private:GetItemDisplayLink(goldData.buys.topQuantity.itemString)

	goldData.profit.total = ((goldData.sales.total + goldData.income.total) - (goldData.buys.total + goldData.expense.total))
	goldData.profit.month = ((goldData.sales.month + goldData.income.month) - (goldData.buys.month + goldData.expense.month))
	goldData.profit.week = ((goldData.sales.week + goldData.income.week) - (goldData.buys.week + goldData.expense.week))

	if goldData.totalTime > (SECONDS_PER_DAY * timeframe1 or 30) then
		goldData.monthTime = SECONDS_PER_DAY * timeframe1 or 30
	end
	if goldData.totalTime > (SECONDS_PER_DAY * timeframe2 or 7) then
		goldData.weekTime = SECONDS_PER_DAY * timeframe2 or 7
	end
	goldData.totalTime = ceil(goldData.totalTime / SECONDS_PER_DAY)
	goldData.monthTime = ceil(goldData.monthTime / SECONDS_PER_DAY)
	goldData.weekTime = ceil(goldData.weekTime / SECONDS_PER_DAY)

	local playerList = CopyTable(TSM.ViewerUtil.playerListCache)
	playerList["all"] = L["All"]

	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "GroupBox",
							label = L["Group"],
							relativeWidth = 0.5,
							value = TSMAPI.Groups:FormatPath(private.filters.group),
							callback = function(_, _, value)
								private.filters.group = value
								private.filters.isReloading = true
								container:Reload()
							end,
						},
						{
							type = "Dropdown",
							label = L["Player"],
							relativeWidth = 0.2,
							list = playerList,
							value = private.filters.player or "all",
							callback = function(_, _, value)
								if value == "all" then
									private.filters.player = nil
								else
									private.filters.player = value
								end
								private.filters.isReloading = true
								container:Reload()
							end,
						},
						{
							type = "Dropdown",
							label = L["Timeframe (Days)"],
							relativeWidth = 0.29,
							list = timeframes,
							value = private.filters.timeframe,
							callback = function(_, _, value)
								private.filters.timeframe = value
								private.filters.isReloading = true
								container:Reload()
							end,
						},
					},
				},
				{
					type = "HeadingLine",
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Sales"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Gold Earned:"], goldData, "sales", nil, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Earned Per Day:"], goldData, "sales", true, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Item by Gold / Quantity:"] .. "|r",
						},
						{
							type = "InteractiveLabel",
							text = goldData.sales.topGold.link .. " (" .. (TSMAPI:MoneyToString(goldData.sales.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() TSMAPI.Util:SafeItemRef(goldData.sales.topGold.link) end,
							tooltip = goldData.sales.topGold.itemID,
						},
						{
							type = "InteractiveLabel",
							text = goldData.sales.topQuantity.link .. " (" .. (goldData.sales.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() TSMAPI.Util:SafeItemRef(goldData.sales.topQuantity.link) end,
							tooltip = goldData.sales.topQuantity.itemID,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Other Income"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Gold Earned:"], goldData, "income", nil, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Earned Per Day:"], goldData, "income", true, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Income by Gold / Quantity:"] .. "|r",
						},
						{
							type = "Label",
							text = (goldData.income.topGold.key or L["none"]) .. " (" .. (TSMAPI:MoneyToString(goldData.income.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
						},
						{
							type = "Label",
							text = (goldData.income.topQuantity.key or L["none"]) .. " (" .. (goldData.income.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Purchases"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Gold Spent:"], goldData, "buys", nil, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Spent Per Day:"], goldData, "buys", true, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Item by Gold / Quantity:"] .. "|r",
						},
						{
							type = "InteractiveLabel",
							text = goldData.buys.topGold.link .. " (" .. (TSMAPI:MoneyToString(goldData.buys.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() TSMAPI.Util:SafeItemRef(goldData.buys.topGold.link) end,
							tooltip = goldData.buys.topGold.itemID,
						},
						{
							type = "InteractiveLabel",
							text = goldData.buys.topQuantity.link .. " (" .. (goldData.buys.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() TSMAPI.Util:SafeItemRef(goldData.buys.topQuantity.link) end,
							tooltip = goldData.buys.topQuantity.itemID,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Expenses"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Gold Spent:"], goldData, "expense", nil, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Spent Per Day:"], goldData, "expense", true, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Expense by Gold / Quantity:"] .. "|r",
						},
						{
							type = "Label",
							text = (goldData.expense.topGold.key or L["none"]) .. " (" .. (TSMAPI:MoneyToString(goldData.expense.topGold.copper) or "---") .. ")",
							relativeWidth = 0.36,
						},
						{
							type = "Label",
							text = (goldData.expense.topQuantity.key or L["none"]) .. " (" .. (goldData.expense.topQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Balance"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Profit:"], goldData, "profit", nil, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = TSM.Viewer:GetMultiLabelLine(L["Profit Per Day:"], goldData, "profit", true, nil, timeframe1, timeframe2),
							relativeWidth = 1,
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private:ProcessSummaryItemData(itemData, resultTbl, itemString, goldData, timeframe1, timeframe2)
	local itemTotal, itemNum = 0, 0
	for _, record in ipairs(itemData) do
		if not TSM.ViewerUtil:IsRecordFiltered(record, private.filters) then
			local timeDiff = time() - record.time

			-- update local variables
			itemNum = itemNum + record.quantity
			itemTotal = itemTotal + record.copper * record.quantity

			-- update total data
			resultTbl.total = resultTbl.total + record.copper * record.quantity
			goldData.totalTime = max(goldData.totalTime, timeDiff)
			if timeDiff <= (SECONDS_PER_DAY * timeframe1) then
				-- update month data
				resultTbl.month = resultTbl.month + record.copper * record.quantity
				goldData.monthTime = max(goldData.monthTime, timeDiff)
			end
			if timeDiff <= (SECONDS_PER_DAY * timeframe2) then
				-- update week data
				resultTbl.week = resultTbl.week + record.copper * record.quantity
				goldData.weekTime = max(goldData.weekTime, timeDiff)
			end
		end
	end

	-- check if this is a top item by gold and/or quantity
	if itemTotal > (resultTbl.topGold.copper or 0) then
		resultTbl.topGold = {itemString=itemString, copper=itemTotal, itemID=TSMAPI.Item:ToItemID(itemString)}
	end
	if itemNum > (resultTbl.topQuantity.num or 0) then
		resultTbl.topQuantity = {itemString=itemString, num=itemNum, itemID=TSMAPI.Item:ToItemID(itemString)}
	end
end

function private:ProcessSummaryMoneyData(moneyData, resultTbl, goldData, timeframe1, timeframe2)
	local moneyKeyNum, moneyKeyGold = {}, {}
	for _, record in ipairs(moneyData) do
		if not TSM.ViewerUtil:IsRecordFiltered(record, private.filters) then
			local timeDiff = time() - record.time

			-- update local variables
			moneyKeyNum[record.key] = (moneyKeyNum[record.key] or 0) + 1
			moneyKeyGold[record.key] = (moneyKeyGold[record.key] or 0) + record.copper

			-- update total data
			resultTbl.total = resultTbl.total + record.copper
			goldData.totalTime = max(goldData.totalTime, timeDiff)
			if timeDiff < (SECONDS_PER_DAY * timeframe1) then
				-- update month data
				resultTbl.month = resultTbl.month + record.copper
				goldData.monthTime = max(goldData.monthTime, timeDiff)
			end
			if timeDiff < (SECONDS_PER_DAY * timeframe2) then
				-- update week data
				resultTbl.week = resultTbl.week + record.copper
				goldData.weekTime = max(goldData.weekTime, timeDiff)
			end
		end
	end
	for key, total in pairs(moneyKeyNum) do
		if total > (resultTbl.topQuantity.num or 0) then
			resultTbl.topQuantity = {key=key, num=total}
		end
	end
	for key, total in pairs(moneyKeyGold) do
		if total > (resultTbl.topGold.copper or 0) then
			resultTbl.topGold = {key=key, copper=total}
		end
	end
end

function private:GetItemDisplayLink(itemString)
	if not itemString then return L["none"] end
	return TSMAPI.Item:GetLink(itemString) or (TSM.items[itemString] and TSM.items[itemString].name) or L["none"]
end
