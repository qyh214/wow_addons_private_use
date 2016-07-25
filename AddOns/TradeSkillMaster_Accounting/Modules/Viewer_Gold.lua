-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Gold = TSM.modules.Viewer:NewModule("Gold")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {lineGraph=nil}
local SECONDS_PER_DAY = 24 * 60 * 60



-- ============================================================================
-- Module Functions
-- ============================================================================

function Gold:Draw(container)
	TSM.db.realm.goldGraphCharacter = TSM.db.realm.goldGraphCharacter or UnitName("player")
	local player = TSM.db.realm.goldGraphCharacter
	local data, minX, maxX, minY, maxY
	if player == "<ALL>" then
		data, minX, maxX, minY, maxY = private:GetGoldGraphSumData()
	else
		data, minX, maxX, minY, maxY = private:GetGoldGraphPoints(TSM.goldLog[player])
	end
	
	local dropdownList = {["<ALL>"]=L["Sum of All Characters/Guilds"]}
	for player in pairs(TSM.goldLog) do
		dropdownList[player] = player
	end
	
	local timeList = {[0]=L["All"]}
	for _, days in ipairs({1, 3, 7, 14, 30, 90, 180, 365}) do
		timeList[days] = format(L["Last %d Days"], days)
	end
	
	if not data then
		local page = {
			{
				type = "SimpleGroup",
				layout = "Flow",
				children = {
					{
						type = "Label",
						text = L["Accounting has not yet collected enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."],
						relativeWidth = 1,
					},
					{
						type = "Spacer",
					},
					{
						type = "Dropdown",
						label = L["Character/Guild to Graph"],
						settingInfo = {TSM.db.realm, "goldGraphCharacter"},
						relativeWidth = 0.5,
						list = dropdownList,
						callback = function() container:Reload() end,
						tooltip = "",
					},
					{
						type = "Dropdown",
						label = L["Timeframe Filter"],
						relativeWidth = 0.49,
						list = timeList,
						settingInfo = {TSM.db.realm, "goldGraphTimeframe"},
						callback = function() container:Reload() end,
					},
				},
			},
		}
		TSMAPI.GUI:BuildOptions(container, page)
		return
	end

	local startDate, endDate
	if TSM.db.global.timeFormat == "eudate" then
		startDate = date("%d/%m/%y %H:%M", minX * 60)
		endDate = date("%d/%m/%y %H:%M", maxX * 60)
	elseif TSM.db.global.timeFormat == "aidate" then
		startDate = date("%y/%m/%d %H:%M", minX * 60)
		endDate = date("%y/%m/%d %H:%M", maxX * 60)
	else
		startDate = date("%m/%d/%y %H:%M", minX * 60)
		endDate = date("%m/%d/%y %H:%M", maxX * 60)
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "Label",
					text = format(L["Below is a graph of the your character's gold on hand over time.\n\nThe x-axis is time and goes from %s to %s\nThe y-axis is thousands of gold."], startDate, endDate),
					relativeWidth = 1,
				},
				{
					type = "Spacer",
				},
				{
					type = "Dropdown",
					label = L["Character to Graph"],
					settingInfo = {TSM.db.realm, "goldGraphCharacter"},
					relativeWidth = 0.5,
					list = dropdownList,
					callback = function() container:Reload() end,
				},
				{
					type = "Dropdown",
					label = L["Timeframe Filter"],
					relativeWidth = 0.49,
					list = timeList,
					settingInfo = {TSM.db.realm, "goldGraphTimeframe"},
					callback = function() container:Reload() end,
				},
				{
					type = "HeadingLine"
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow",
					children = {},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)

	local parent = container.children[1].children[#container.children[1].children].frame

	if not private.lineGraph then
		local graph = LibStub("LibGraph-2.0"):CreateGraphLine(nil, parent, "CENTER", nil, nil, nil, parent:GetWidth(), parent:GetHeight())
		graph:SetGridColor({ 0.8, 0.8, 0.8, 0.6 })
		graph:SetYLabels(true)
		private.lineGraph = graph
	end
	private.lineGraph:Show()
	private.lineGraph:SetParent(parent)
	private.lineGraph:ClearAllPoints()
	private.lineGraph:SetAllPoints(parent)

	private.lineGraph:ResetData()
	local ySpacing = max(ceil((maxY - minY) / 20), 0.5)
	private.lineGraph:SetGridSpacing(nil, ySpacing)
	local xBuffer = (maxX-minX)*0.05
	local yBuffer = (maxY-minY)*0.03
	private.lineGraph:SetXAxis(minX-xBuffer, maxX)
	private.lineGraph:SetYAxis(minY-yBuffer, maxY+yBuffer)
	private.lineGraph:AddDataSeries(data, {1, 0.83, 0, 1})
	private.lineGraph:RefreshGraph()
end

function Gold:Hide()
	if private.lineGraph then
		private.lineGraph:Hide()
	end
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private:GetGoldGraphPoints(goldLog)
	if not goldLog or #goldLog < 3 then return end
	local minY, maxY = math.huge, 0
	local minX, maxX = math.huge, 0
	local data = {}
	local minMinute = 0
	if TSM.db.realm.goldGraphTimeframe ~= 0 then
		minMinute = floor(time() / 60) - (TSM.db.realm.goldGraphTimeframe * 24 * 60)
	end
	for i, info in ipairs(goldLog) do
		if info.startMinute > minMinute then
			if #data == 0 and i > 1 then
				-- add starting point
				local x1, x2 = minMinute, goldLog[i-1].endMinute
				local y = goldLog[i-1].copper / COPPER_PER_GOLD / 1000
				minX = min(minX, x1)
				maxX = max(maxX, x2)
				minY = min(minY, floor(y))
				maxY = max(maxY, ceil(y))
				tinsert(data, {x1, y})
				tinsert(data, {x2, y})
			end
			local x1, x2 = info.startMinute, info.endMinute
			local y = info.copper / COPPER_PER_GOLD / 1000
			minX = min(minX, x1)
			maxX = max(maxX, x2)
			minY = min(minY, floor(y))
			maxY = max(maxY, ceil(y))
			tinsert(data, {x1, y})
			tinsert(data, {x2, y})
		end
	end
	if #data > 0 then
		return data, minX, maxX, minY, maxY
	end
end

function private:GetGoldGraphSumData()
	local currentMinute = floor(time() / 60)
	local players = {}
	local starts = {}
	local minMinute = 0
	if TSM.db.realm.goldGraphTimeframe ~= 0 then
		minMinute = currentMinute - (TSM.db.realm.goldGraphTimeframe * 24 * 60)
	end
	for _, playerData in pairs(TSM.goldLog) do
		if #playerData > 2 then
			local temp = CopyTable(playerData)
			local data = {}
			for i=1, #temp do
				if i > 1 then
					temp[i].startMinute = temp[i-1].endMinute+1
				end
				temp[i].copper = TSMAPI.Util:Round(temp[i].copper, COPPER_PER_GOLD*1000)
				if temp[i].endMinute >= minMinute then
					tinsert(data, temp[i])
				end
			end
			if #data > 0 then
				tinsert(players, data)
				tinsert(starts, data[1].startMinute)
			end
		end
	end
	if #players == 0 then return end
	
	local indicies = {}
	local absStartMinute = min(unpack(starts))
	for i=1, #players do
		indicies[i] = 1
	end
	
	local temp = {}
	local staticCopper = 0
	for t=absStartMinute, currentMinute do
		local copper = staticCopper
		for i=#players, 1, -1 do
			if starts[i] <= t then
				local playerData = players[i]
				local index = indicies[i]
				while true do
					if index >= #playerData then
						index = #playerData
						tremove(players, i)
						staticCopper = staticCopper + playerData[index].copper
						copper = copper + playerData[index].copper
						break
					end
					if t > playerData[index].endMinute then
						-- move to the next datapoint for this player
						index = index + 1
					else
						-- we are in the range
						copper = copper + playerData[index].copper
						break
					end
				end
				indicies[i] = index
			end
		end
		local j = #temp+1
		if j > 1 and temp[j-1].copper == copper then
			temp[j-1].endMinute = t
		else
			tinsert(temp, {startMinute=t, endMinute=t, copper=copper})
		end
	end
	if #temp == 0 then return end
	return private:GetGoldGraphPoints(temp)
end