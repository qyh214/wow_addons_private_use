local ADDON, Addon = ...
local Mod = Addon:NewModule('Splits')

local splits
local splitNames
local affixes

local function timeFormat(seconds)
	local hours = floor(seconds / 3600)
	local minutes = floor((seconds / 60) - (hours * 60))
	seconds = seconds - hours * 3600 - minutes * 60

	if hours == 0 then
		return format("%d:%.2d", minutes, seconds)
	else
		return format("%d:%.2d:%.2d", hours, minutes, seconds)
	end
end

local function GetElapsedTime()
	for i = 1, select("#", GetWorldElapsedTimers()) do
		local timerID = select(i, GetWorldElapsedTimers())
		local _, elapsedTime, type = GetWorldElapsedTime(timerID)
		if type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
			return elapsedTime
		end
	end
end

local function UpdateSplits(self, numCriteria, block)
	local scenarioType = select(10, C_Scenario.GetInfo())
	if not self:ShouldShowCriteria() or not splits or scenarioType ~= LE_SCENARIO_TYPE_CHALLENGE_MODE then return end

	for index, elapsed in pairs(splits) do
		local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, _, _, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(index)
		if elapsed and elapsed ~= true and criteriaString then

			if Addon.Config.splitsFormat == 2 then
				local prev = 0
				for i, e in pairs(splits) do
					if e and e ~= true and e < elapsed and e > prev then
						prev = e
					end
				end

				local split = elapsed - prev
				criteriaString = string.format("%d/%d %s, +%s", quantity, totalQuantity, criteriaString, timeFormat(split))
			elseif Addon.Config.splitsFormat == 1 then
				criteriaString = string.format("%d/%d %s, %s", quantity, totalQuantity, criteriaString, timeFormat(elapsed))
			else
				criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString)
			end

			local line = block.lines[index]
			if line then
				local height = SCENARIO_TRACKER_MODULE:SetStringText(line.Text, criteriaString, nil, OBJECTIVE_TRACKER_COLOR["Complete"], block.isHighlighted)
				line:SetHeight(height)
			end
		end
	end
end

function Mod:SplitOutput()
	if Addon.Config.splitsFormat == 0 then return end

	local splitStrs = {}
	for index, elapsed in pairs(splits) do
		if elapsed and elapsed ~= true then
			if Addon.Config.splitsFormat == 2 then
				local prev = 0
				for i, e in pairs(splits) do
					if e and e ~= true and e < elapsed and e > prev then
						prev = e
					end
				end
				local split = elapsed - prev
				table.insert(splitStrs, string.format("%s +%s", splitNames[index], timeFormat(split)))
			elseif Addon.Config.splitsFormat == 1 then
				table.insert(splitStrs, string.format("%s %s", splitNames[index], timeFormat(elapsed)))
			end
		end
	end
	return table.concat(splitStrs, ", ")
end

function Mod:CHALLENGE_MODE_RESET()
	affixes = select(2, C_ChallengeMode.GetActiveKeystoneInfo())
	splits = nil
	splitNames = nil
	Mod.splits = nil
	Mod.splitNames = nil
end

function Mod:CHALLENGE_MODE_COMPLETED()
	local mapID, level, timeElapsed, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
	local name, _, timeLimit = C_ChallengeMode.GetMapInfo(mapID)

	local missingCount = 0
	for index,elapsed in pairs(splits) do
		if elapsed == false then
			splits[index] = floor(timeElapsed / 1000)
			missingCount = missingCount + 1
		elseif elapse == true then
			missingCount = missingCount + 1
		end
	end

	if false and missingCount <= 1 then
		splits.date = time()
		splits.level = level
		splits.mapID = mapID
		splits.timeElapsed = timeElapsed / 1000
		splits.timeLimit = timeLimit
		splits.affixes = affixes

		table.insert(AngryKeystones_Data.splits, splits)
	end
	affixes = nil
	splits = nil
	Mod.splits = nil
end

function Mod:SCENARIO_CRITERIA_UPDATE()
	local scenarioType = select(10, C_Scenario.GetInfo())
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local fresh = false
		if not splits then
			splits = {}
			Mod.splits = splits
			splitNames = {}
			Mod.splitNames = splitNames
			fresh = true
		end
		local numCriteria = select(3, C_Scenario.GetStepInfo())
		for criteriaIndex = 1, numCriteria do
			local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, _, quantityString, criteriaID, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)
			if not splitNames[criteriaIndex] then
				splitNames[criteriaIndex] = criteriaString
			end
			if not isWeightedProgress then
				if splits[criteriaIndex] == nil then splits[criteriaIndex] = false end

				if completed and not splits[criteriaIndex] then
					splits[criteriaIndex] = fresh or GetElapsedTime()
				end
			end
		end
		UpdateSplits(SCENARIO_CONTENT_TRACKER_MODULE, numCriteria, ScenarioObjectiveBlock)
	end
end

function Mod:Startup()
	if not AngryKeystones_Data then AngryKeystones_Data = {} end
	if not AngryKeystones_Data.splits then AngryKeystones_Data.splits = {} end
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
	self:RegisterEvent("CHALLENGE_MODE_RESET")
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "UpdateCriteria", UpdateSplits)
	Addon.Config:RegisterCallback('splitsFormat', function()
		UpdateSplits(SCENARIO_CONTENT_TRACKER_MODULE, nil, ScenarioObjectiveBlock)
	end)
end
