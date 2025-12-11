local T, C, L, G = unpack(select(2, ...))

----------------------------------------------------------
------------------[[    转阶段监控    ]]------------------
----------------------------------------------------------
local PhaseTrigger = CreateFrame("Frame", nil)

local phase_data = {} -- 所有首领的转阶段数据
local current_engageID -- 当前战斗
local current_difficultyID -- 当前难度
local current_phase -- 当前阶段
local current_phase_data = {} -- 当前战斗的转阶段计数
local engaged_npc = {} -- 转阶段监控：记录BOSS加入战斗
local spell_count = {} -- 转阶段监控：记录技能次数

function PhaseTrigger:outputMsg()
	if G.Timeline.time_offset == 0 then
		T.msg(string.format(L["阶段转换"].." P%s %s", current_phase, date("%M:%S", G.Timeline.passed)))
	else
		T.msg(string.format(L["阶段转换"].." P%s %s ["..L["运行时间"].." %s]", current_phase, date("%M:%S", G.Timeline.passed), date("%M:%S", G.Timeline.fake_passed)))
	end
end

local function AddCurrentData(tag, ...)
	if G.Encounter_Data[tag] then
		for category, data in pairs(G.Encounter_Data[tag]) do
			for alert_type, alert_data in pairs(data) do
				for key, args in pairs(alert_data) do
					if T.CheckRole(args.ficon) and not G.Current_Data[category][alert_type][key] then
						if string.find(tag, "engage") then -- 首领战斗
							if T.CheckDifficulty(args.ficon, current_difficultyID) then
								G.Current_Data[category][alert_type][key] = args
								G.Current_Data[category][alert_type][key].IsEncounterData = true
							end
						else -- 杂兵
							G.Current_Data[category][alert_type][key] = args
						end
					end
				end
			end
		end
		T.FireEvent("DATA_ADDED", ...)
	end
end

local function WipeCurrentData(event)
	for category, data in pairs(G.Current_Data) do
		for alert_type, alert_data in pairs(data) do
			for key, args in pairs(alert_data) do
				if event == "ENCOUNTER_END" then
					if args.IsEncounterData then
						G.Current_Data[category][alert_type][key] = nil
					end
				else
					G.Current_Data[category][alert_type][key] = nil
				end
			end
		end
	end
	T.FireEvent("DATA_REMOVED", event)
end

local function UpdateAllData()
	WipeCurrentData()
	
	local mapID = select(8, GetInstanceInfo())
	AddCurrentData("map"..mapID)
	
	if current_engageID and current_difficultyID then
		AddCurrentData("engage"..current_engageID)
	end
end
T.UpdateAllData = UpdateAllData

PhaseTrigger:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_SPECIALIZATION_CHANGED" then
		UpdateAllData()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		if IsEncounterInProgress() then
			for unit in T.IterateBoss() do
				local npcID = T.GetUnitNpcID(unit)
				local engageID = G.npcIDtoengageID[npcID]
				if engageID then
					current_engageID = engageID
					break
				end
			end
			
			current_difficultyID = select(3, GetInstanceInfo())
		end
		
		UpdateAllData()
		
	elseif event == "ENCOUNTER_START" then
		local engageID, _, difficultyID = ...
		
		current_engageID = engageID
		current_difficultyID = difficultyID
		current_phase = 1
		
		AddCurrentData("engage"..current_engageID, event, ...)
		
		if phase_data[engageID] then
			if phase_data[engageID].CLEU then
				for i, data in pairs(phase_data[engageID].CLEU) do
					if not data.ficon or T.CheckDifficulty(data.ficon, difficultyID) then
						current_phase_data[data.phase] = 0
					end
				end
			end
			if phase_data[engageID].UNIT then
				for i, data in pairs(phase_data[engageID].UNIT) do
					if not data.ficon or T.CheckDifficulty(data.ficon, difficultyID) then
						current_phase_data[data.phase] = 0
					end
				end
			end
		end
		
	elseif event == "ENCOUNTER_END" then
		WipeCurrentData(event)
		
		current_engageID = nil
		current_difficultyID = nil
		current_phase = nil
		
		engaged_npc = table.wipe(engaged_npc)
		spell_count = table.wipe(spell_count)
		current_phase_data = table.wipe(current_phase_data)
		
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then		
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, extraSpellID = CombatLogGetCurrentEventInfo()
		
		if not current_engageID or not phase_data[current_engageID] or not phase_data[current_engageID].CLEU then return end
		
		for i, data in pairs(phase_data[current_engageID].CLEU) do
			if sub_event == data.sub_event and data.count and (not data.ficon or T.CheckDifficulty(data.ficon, current_difficultyID)) then -- 记录次数
				if data.spellID then
					if data.spellID == spellID then
						local tag = string.format("%s:%s", sub_event, spellID)
						if not spell_count[tag] then
							spell_count[tag] = 1
						else
							spell_count[tag] = spell_count[tag] + 1
						end
						break
					end
				elseif data.extraSpellID then
					if data.extraSpellID == extraSpellID then
						local tag = string.format("%s:%s", sub_event, extraSpellID)
						if not spell_count[tag] then
							spell_count[tag] = 1
						else
							spell_count[tag] = spell_count[tag] + 1
						end
						break
					end
				end
			end
		end
		
		for i, data in pairs(phase_data[current_engageID].CLEU) do
			if sub_event == data.sub_event and (not data.ficon or T.CheckDifficulty(data.ficon, current_difficultyID)) then
				if data.spellID then
					if data.spellID == spellID then
						if data.count then
							local tag = string.format("%s:%s", sub_event, spellID)
							if spell_count[tag] == data.count then
								current_phase = data.phase
								current_phase_data[current_phase] = current_phase_data[current_phase] + 1
								T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
								self:outputMsg()
							end
						else
							current_phase = data.phase
							current_phase_data[current_phase] = current_phase_data[current_phase] + 1
							T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
							self:outputMsg()
						end
					end
				elseif data.extraSpellID then
					if data.extraSpellID == extraSpellID then
						if data.count then
							local tag = string.format("%s:%s", sub_event, extraSpellID)
							if spell_count[tag] == data.count then
								current_phase = data.phase
								current_phase_data[current_phase] = current_phase_data[current_phase] + 1
								T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
								self:outputMsg()
							end
						else
							current_phase = data.phase
							current_phase_data[current_phase] = current_phase_data[current_phase] + 1
							T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
							self:outputMsg()
						end
					end
				end
			end
		end
	elseif event == "ENCOUNTER_ENGAGE_UNIT" then
		if not current_engageID or not phase_data[current_engageID] or not phase_data[current_engageID].UNIT then return end
		local unit = ...
		local npcID = T.GetUnitNpcID(unit)
		if not engaged_npc[npcID] then -- 有新的NPC加入战斗
			engaged_npc[npcID] = true
			
			for i, data in pairs(phase_data[current_engageID].UNIT) do
				if data.npcID == npcID and (not data.ficon or T.CheckDifficulty(data.ficon, current_difficultyID)) then
					current_phase = data.phase
					current_phase_data[current_phase] = current_phase_data[current_phase] + 1
					T.FireEvent("ENCOUNTER_PHASE", current_phase, current_phase_data[current_phase])
					self:outputMsg()
				end
			end
		end
	elseif event == "ADDON_LOADED" then
		local addon = ...
		if C_AddOns.GetAddOnMetadata(addon, "X-JST-InstanceType") then
			for _, data in pairs(G.Encounters) do
				if data.engage_id and not phase_data[data.engage_id] then -- 只针对首领战斗
					for _, section_data in pairs(data.alerts) do
						if section_data.title and section_data.title == L["阶段转换"] then
							phase_data[data.engage_id] = {}
							for _, args in pairs(section_data.options) do
								if not phase_data[data.engage_id][args.type] then
									phase_data[data.engage_id][args.type] = {}
								end
								if args.type == "CLEU" then
									table.insert(phase_data[data.engage_id][args.type], {
										phase = args.phase,
										sub_event = args.sub_event,
										spellID = args.spellID,
										extraSpellID = args.extraSpellID,
										count = args.count,
										ficon = args.ficon,
									})
								elseif args.type == "UNIT" then
									table.insert(phase_data[data.engage_id][args.type], {
										phase = args.phase,
										npcID = args.npcID,
										ficon = args.ficon,
									})
								end	
							end
							break
						end
					end
				end
			end
		end
	end
end)

T.RegisterEventAndCallbacks(PhaseTrigger, {
	["PLAYER_SPECIALIZATION_CHANGED"] = true,
	["PLAYER_ENTERING_WORLD"] = true,
	["ENCOUNTER_START"] = true,
	["ENCOUNTER_END"] = true,
	["ENCOUNTER_ENGAGE_UNIT"] = true,
	["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	["ADDON_LOADED"] = true,
})

----------------------------------------------------------
----------------[[    转阶段监控 API   ]]-----------------
----------------------------------------------------------

T.GetCurrentEngageID = function()
	return current_engageID
end

T.GetCurrentDifficultyID = function()
	if current_difficultyID then
		return current_difficultyID
	else
		local difficultyID = select(3, GetInstanceInfo())
		return difficultyID
	end
end

T.GetCurrentPhase = function()
	return current_phase
end


