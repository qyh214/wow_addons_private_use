local T, C, L, G = unpack(select(2, ...))

local addon_name = G.addon_name
local LCG = LibStub("LibCustomGlow-1.0")

G.TestMod = false
G.TestBossModFrames = {
	--[412761] = true,
}

----------------------------------------------------------
-----------------[[    Frame Holder    ]]-----------------
----------------------------------------------------------
local FrameHolder = CreateFrame("Frame", addon_name.."FrameHolder", UIParent)
G.FrameHolder = FrameHolder

local update_rate = .05

T.UpdateAll = function()
	if C.DB["GeneralOption"]["disable_all"] then
		FrameHolder:Hide()
	else
		FrameHolder:Show()
	end
	-- update
	T.EditIconAlertFrames("all")
	T.EditBarAlertFrames("all")
	T.EditTextAlertFrames("all")
	T.EditPlateIcons("all")
	T.EditSoundAlert("all")
	T.EditRFIconAlert("all")
	T.EditBossModsFrame("all")
	T.EditRMFrame("all")
	T.EditTimeline("all")
	T.EditASFrame("all")
	T.EditRaidPAFrame("all")
	T.UpdateAutoMarkState()
	T.EditGroupCCFrame("all")
	T.EditGroupSpellFrame("all")
	T.EditPersonalSpellFrame("all")
end

----------------------------------------------------------
----------------------[[    API    ]]---------------------
----------------------------------------------------------
local function CheckConditions(self, register_events, args, event, ...)
	if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" then
		if args.points and G.TestMod and G.TestBossModFrames[args.spellID] then -- 测试
			if not args.points.hide then
				self:Show()
			end
			T.RegisterEventAndCallbacks(self, register_events)
		else
			if self.enable and T.CheckRole(args.ficon) then
				if IsEncounterInProgress() then
					if self.npcID and T.CheckEncounter(self.npcID, args.ficon) then
						T.RegisterEventAndCallbacks(self, register_events)
						if args.points and not args.points.hide then
							self:Show()
						end
					end
				end
				
				if self.mapID then
					if T.CheckDungeon(self.mapID) then
						T.RegisterEventAndCallbacks(self, register_events)
						if args.points and not args.points.hide then
							self:Show()
						end
						if self.init_update then
							self:init_update(event, ...)
						end
					else
						T.UnregisterEventAndCallbacks(self, register_events)
						self:reset()
					end
				end
			else
				T.UnregisterEventAndCallbacks(self, register_events)
				self:reset()
			end
		end
	elseif event == "ENCOUNTER_START" then -- 进入战斗
		local encounterID, _, difficultyID = ...
		if self.enable and self.engageID and encounterID == self.engageID and T.CheckDifficulty(args.ficon, difficultyID) and T.CheckRole(args.ficon) then
			T.RegisterEventAndCallbacks(self, register_events)
			if args.points and not args.points.hide then
				self:Show()
			end
			if self.init_update then
				self:init_update(event, ...)
			end
		end
	elseif event == "ENCOUNTER_END" then -- 脱离战斗
		local encounterID = ...
		if self.enable and self.engageID and encounterID == self.engageID and T.CheckRole(args.ficon) then
			T.UnregisterEventAndCallbacks(self, register_events)
			self:reset(event)
		end
	end
end

local function CreateUpdater(CreateFunction, GroupFrame, GroupFrame2, GroupFrame3)
	local updater = CreateFrame("Frame")
		
	updater.actives_bytag = {}
	
	function updater:GetAvailableAlert(group, tag)
		local parent = (group == 2 and GroupFrame2) or (group == 3 and GroupFrame3) or GroupFrame
		for i, alert in pairs(parent.active_byindex) do
			if not alert.tag then		
				alert.tag = tag
				self.actives_bytag[alert.tag] = alert	
				return alert
			end
		end
	end
	
	function updater:GetAlert(group, tag)
		if self.actives_bytag[tag] then	
			return self.actives_bytag[tag]
		else
			local parent = (group == 2 and GroupFrame2) or (group == 3 and GroupFrame3) or GroupFrame
			local alert = self:GetAvailableAlert(group, tag) or CreateFunction(self, parent, tag)
			return alert
		end
	end

	function updater:RemoveAlert(tag)
		local alert = self.actives_bytag[tag]
		if alert then 
			alert:cancel()
			alert.tag = nil
			self.actives_bytag[tag] = nil
		end
	end
	
	return updater 
end
T.CreateUpdater = CreateUpdater

local function AddData(args, engageTag, mapTag, category, tag)
	if args.instance_alert then -- 首领标签页下但属于杂兵功能
		if G.Encounter_Data[mapTag][category][args.type][tag] then
			T.msg(category, args.type, tag, "标签重复")
		end
		G.Encounter_Data[mapTag][category][args.type][tag] = args
	elseif engageTag then -- 首领功能
		if G.Encounter_Data[engageTag][category][args.type][tag] then
			T.msg(category, args.type, tag, "标签重复")
		end
		G.Encounter_Data[engageTag][category][args.type][tag] = args
	else -- 杂兵功能
		if G.Encounter_Data[mapTag][category][args.type][tag] then
			T.msg(category, args.type, tag, "标签重复")
		end
		G.Encounter_Data[mapTag][category][args.type][tag] = args
	end
end
T.AddData = AddData

local aura_check_units = {"player", "boss1", "boss2", "boss3", "boss4", "boss5"}

local function CheckAuraType(aura_type, aura_data)
	if aura_type == "HELPFUL" then
		if aura_data.isHelpful then
			return true
		end
	elseif aura_type == "HARMFUL" then
		if aura_data.isHarmful then
			return true
		end
	end
end
T.CheckAuraType = CheckAuraType

T.CheckUnit = function(unit, alert_unit, roles)
	if alert_unit == "group" then
		if IsInRaid() then
			if string.find(unit, "raid") then
				if roles then
					for _, role in pairs(roles) do
						if UnitGroupRolesAssigned(unit) == role then
							return true
						end
					end
				else
					return true
				end
			end
		else
			if unit == "player" or string.find(unit, "party") then
				if roles then
					for _, role in pairs(roles) do
						if UnitGroupRolesAssigned(unit) == role then
							return true
						end
					end
				else
					return true
				end
			end
		end
	elseif alert_unit == "boss" then
		return string.find(unit, "boss") or string.find(unit, "arena")
	else
		return unit == alert_unit
	end
end

T.FilterAuraUnit = function(unit)
	if unit == "player" or string.find(unit, "raid") or string.find(unit, "party") or string.find(unit, "boss") or string.find(unit, "arena") then
		return true
	end
end

T.FilterGroupUnit = function(unit)
	if not unit then return end
	if IsInRaid() then
		return string.find(unit, "raid")
	elseif IsInGroup() then
		return string.find(unit, "party") or unit == "player"
	else
		return unit == "player"
	end
end

T.UnitInDynamicGroup = function(unit)
	if not unit then return end
	if IsInRaid() then
		return UnitInRaid(unit)
	elseif IsInGroup() then
		return UnitInParty(unit) or UnitIsUnit(unit, "player")
	else
		return UnitIsUnit(unit, "player")
	end
end

local function SoundStrFilter(str)
	local filter_tag = string.match(str, "no(.+)")
	if filter_tag then
		local role = T.GetMyRole()
		if filter_tag == string.lower(role) then
			return false
		else
			return true
		end			
	else
		return true
	end
end

local function FilterThreat(unit)
	if unit and UnitThreatSituation("player", unit) then	
		return true
	end
end


----------------------------------------------------------
------------------[[    计时条提示    ]]------------------
----------------------------------------------------------
local BarAlertGroupFrames = {}
G.BarAlertGroupFrames = BarAlertGroupFrames

local function CreateBarAlertGroupFrame(name, text, anchor, x, y, pa)
	local frame = CreateFrame("Frame", addon_name..name, FrameHolder)
	frame:SetSize(160, 16)
	
	frame.movingname = text
	frame.point = { a1 = anchor, a2 = "CENTER", x = x, y = y}
	T.CreateDragFrame(frame)
	
	frame.active_byindex = {}
	
	function frame:lineup()
		table.sort(self.active_byindex, function(a, b)
			local sub_groupA = a.sub_group or 1
			local sub_groupB = b.sub_group or 1
			if sub_groupA ~= sub_groupB then
				return sub_groupA < sub_groupB
			else
				local exp_timeA = a.exp_time or a.exp_time_old
				local exp_timeB = b.exp_time or b.exp_time_old
				if exp_timeA and exp_timeB then
					return exp_timeA < exp_timeB
				end
			end
		end)
		
		local lastgroup
		local lastframe
		for index, bar in pairs(self.active_byindex) do
			if bar:IsShown() then
				bar:ClearAllPoints()
				
				if not lastframe then
					bar:SetPoint("TOP", frame, "TOP")
				elseif bar.sub_group ~= lastgroup then
					local sub_group_gap = bar:GetHeight()
					bar:SetPoint("TOP", lastframe, "BOTTOM", 0, -4-sub_group_gap)
				else
					bar:SetPoint("TOP", lastframe, "BOTTOM", 0, -4)
				end
				
				lastframe = bar
				lastgroup = bar.sub_group
			end
		end
	end
	
	table.insert(BarAlertGroupFrames, frame)
	
	return frame
end

local BarFrame = CreateBarAlertGroupFrame("TimerbarFrame", L["计时条提示1"], "BOTTOM", 0, 200) -- 重要
local BarFrame2 = CreateBarAlertGroupFrame("TimerbarFrame2", L["计时条提示2"], "BOTTOMLEFT", 210, 200) -- 一般
local BarFrame3 = CreateBarAlertGroupFrame("TimerbarFrame3", L["换坦技能计时条"], "TOPLEFT", 210, 0) -- 换坦计时条

T.EditBarAlertFrames = function(option)
	if option == "all" or option == "bar_size" then
		for i, frame in pairs(BarAlertGroupFrames) do		
			frame:SetSize(C.DB["TimerbarOption"]["bar_width"], C.DB["TimerbarOption"]["bar_height"])
		end
	end
	for i, frame in pairs(BarAlertGroupFrames) do
		for _, bar in pairs(frame.active_byindex) do
			bar:update_onedit(option)
		end
	end
end

-- 获取计时条
local CreateAlertBar = function(updater, parent, tag)
	local bar = T.CreateTimerBar(parent, G.media.blank, true, true, true)

	function bar:update_onedit(option) -- 载入配置
		if option == "all" or option == "enable" then
			if self.path then
				if not T.ValueFromDB(self.path)["enable"] then
					self:cancel()
					self.tag = nil
					updater.actives_bytag[tag] = nil
				end
			end
		end
		
		if option == "all" or option == "bar_size" then
			self:SetSize(C.DB["TimerbarOption"]["bar_width"], C.DB["TimerbarOption"]["bar_height"])
		end
	end
		
	function bar:display(args)
		if args.type and args.spellID then
			self.edit_key = args.type.."_"..args.spellID
			
			if args.type ~= "test" then
				if not self.path then
					self.path = {}
					self.path[1] = "AlertTimerbar"
				end
				
				self.path[2] = args.type
				self.path[3] = args.spellID
			end
		end
		
		-- Init
		self.GUID = nil
		self.target_fixed = nil
		
		self:SetStatusBarColor(unpack(args.color))
		self.sub_group = args.sub_group or 1
		
		if args.glow then		
			self.glow:Show()
			self.glow:SetBackdropBorderColor(unpack(args.color))
		else
			self.glow:Hide()
		end
		
		if args.tags then
			T.CreateTagsforBar(self, #args.tags)			
		end
		
		if self.tag_indcators then
			self:hide_tags()
		end
		
		-- 重置文字
		self.left:SetText("")
		self.mid:SetText("")
		self.right:SetText("")
		self.ind_text:SetText("")
		self.value_text:SetText("")
		
		self:update_onedit("all")
	end
	
	function bar:cancel()
		self.edit_key = nil
		self.path = nil
		
		self:Hide()
		self:SetScript("OnUpdate", nil)
		self.anim:Stop()
	end
	
	bar:HookScript("OnShow", function(self)
		parent:lineup()
	end)
	
	bar:HookScript("OnHide", function(self)
		parent:lineup()
	end)
	
	table.insert(parent.active_byindex, bar)
	
	bar.tag = tag
	
	if updater then
		updater.actives_bytag[tag] = bar
	end
	
	return bar
end

-- 计时条：施法

local AlertBar_Cast_Updater = CreateUpdater(CreateAlertBar, BarFrame, BarFrame2, BarFrame3)

AlertBar_Cast_Updater.MultiSpellIDs = {}
AlertBar_Cast_Updater.count_data = {}

T.CreateCast = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if not args.group then
		args.group = 2
	end
	
	if not args.sub_group then
		args.sub_group = 1
	end
	
	if not args.color then
		args.color = T.GetSpellColor(args.spellID)
	end
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_Timerbar_Options(option_page, category, path, args, detail_options)

	if args.spellIDs then
		for _, spellID in pairs(args.spellIDs) do
			AlertBar_Cast_Updater.MultiSpellIDs[spellID] = args.spellID
		end
	end
	
	AddData(args, option_page.engageTag, option_page.mapTag, category, args.spellID)
end

function AlertBar_Cast_Updater:update_layout(event_type, tag, bar, args, cast_spellID, dur, exp_time)
	bar:display(args)
	
	local icon = args.icon_tex or C_Spell.GetSpellTexture(cast_spellID) or 134400
	local flagicons = args.ficon and T.GetFlagIconStr(args.ficon) or ""
	local text = args.text or C_Spell.GetSpellName(cast_spellID) or ""
	
	bar.icon:SetTexture(icon)
	bar.left:SetText(string.format("%s %s", flagicons, text))
	bar.mid:SetText("")	
	bar:SetMinMaxValues(0, dur)
		
	if (not args.tags or event_type == "cast") and bar.tag_indcators then
		bar:hide_tags()
	elseif args.tags then
		for i, each_dur in pairs(args.tags) do
			bar:pointtag(i, each_dur/dur)
		end
	end
	
	bar.dur = dur
	bar.exp_time = exp_time or GetTime() + dur
	
	bar:SetScript("OnUpdate", function(s, e)
		s.t = s.t + e
		if s.t > s.update_rate then
			s.remain = s.exp_time - GetTime()
			if s.remain > 0 then		
				s.right:SetText(T.FormatTime(s.remain))
				
				if event_type == "cast" then
					s:SetValue(s.dur - s.remain)
				else
					s:SetValue(s.remain)
				end
				
				local cd_tag = "voi_countdown_"..event_type
				if s[cd_tag] and s.inRange then -- 倒数
					s.remain_second = ceil(s.remain)
					
					if s.remain_second <= s[cd_tag] and s.remain_second > 0 then
						T.PlaySound("count\\"..s.remain_second) -- 3..2..1..
						s[cd_tag] = s[cd_tag] - 1
					end
				end
			else
				self:RemoveAlert(tag)
			end
			s.t = 0
		end
	end)

	if args.glow or (event_type == "cast" and args.glow_cast) or (event_type == "channel" and args.glow_channel) then
		bar.anim:Play()
	end
	
	bar:Show()
end

function AlertBar_Cast_Updater:update_index(event_type, bar, args)
	if args.count then
		if not self.count_data[args.spellID] then
			self.count_data[args.spellID].ind_cast = 0
			self.count_data[args.spellID].ind_channel = 0
		end
		
		local tag = "ind_"..event_type
		self.count_data[args.spellID][tag] = self.count_data[args.spellID][tag] + 1	
		
		bar.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.count_data[args.spellID][tag]))
	end
end

function AlertBar_Cast_Updater:update_range(bar, args, unit)
	if args.range_ck then
		if T.IsUnitInRange(unit) then
			bar:SetAlpha(1)
			bar.inRange = true
		else
			bar:SetAlpha(.2)
			bar.inRange = false
		end
	else
		bar:SetAlpha(1)
		bar.inRange = true
	end
end

function AlertBar_Cast_Updater:update_target(bar, args, unit)
	if args.show_tar and not bar.target_fixed then
		local target_unit = T.GetTarget(unit)
		if target_unit then
			local GUID = UnitGUID(target_unit)
			local name = GUID and T.ColorNickNameByGUID(GUID)
			bar.mid:SetText(name or "")
		else
			bar.mid:SetText("")
		end
	end
end

function AlertBar_Cast_Updater:update_raidmark(bar, args, unit)
	if args.show_rm then
		local rt = GetRaidTargetIndex(unit)
		bar.rm_text:SetText(rt and T.FormatRaidMark(rt) or "")
	else
		bar.rm_text:SetText("")
	end
end

function AlertBar_Cast_Updater:play_sound(event_type, bar, args, unit)
	if args.sound and string.find(args.sound, event_type) and T.ValueFromDB(bar.path)["sound_bool"] and bar.inRange and SoundStrFilter(args.sound) then
		T.PlaySound(string.match(args.sound, "%[(.+)%]"..event_type))
		
		if args.show_tar then -- 与朗读序号冲突
			C_Timer.After(1, function()
				local str = bar.mid:GetText()
				if str then
					local name = string.match(str, "|c%x%x%x%x%x%x%x%x([^|]+)|")
					if name then
						T.SpeakText(name)
					end
				end
			end)
		end
		
		if args.count then -- 与朗读目标冲突
			C_Timer.After(1, function()
				local tag = "ind_"..event_type
				local ind = self.count_data[args.spellID]["ind_"..event_type]
				T.PlaySound("count\\"..ind) -- 序数
			end)
		end
		
		local cd_tag = "voi_countdown_"..event_type
		if string.find(args.sound, "cd(%d+)") then
			bar[cd_tag] = tonumber(string.match(args.sound, "cd(%d+)"))
		else
			bar[cd_tag] = nil
		end
	end
end

function AlertBar_Cast_Updater:update(event_type, cast_Tag, bar, args, unit, cast_spellID, dur, exp_time)
	-- 外观
	self:update_layout(event_type, cast_Tag, bar, args, cast_spellID, dur, exp_time)

	-- 序号
	self:update_index(event_type, bar, args)
	
	-- 距离
	self:update_range(bar, args, unit)
	
	-- 目标
	self:update_target(bar, args, unit)
	
	-- 标记
	self:update_raidmark(bar, args, unit)
	
	-- 声音
	self:play_sound(event_type, bar, args, unit)
end

AlertBar_Cast_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_START" then
		local unit, cast_GUID, cast_spellID = ...
		if unit and cast_GUID and cast_spellID then
			local spellID = self.MultiSpellIDs[cast_spellID] or cast_spellID
			local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "cast", spellID})
			if args and not args.dur and (not args.threat_ck or FilterThreat(unit)) then
				local enable = T.ValueFromDB({"AlertTimerbar", "cast", spellID, "enable"})
				if enable then
					local startTimeMS, endTimeMS = select(4, UnitCastingInfo(unit))
					local cast_Tag = cast_GUID
					if startTimeMS and endTimeMS and not self.actives_bytag[cast_Tag] then
						local bar = self:GetAlert(args.group, cast_Tag)
						local dur = (endTimeMS - startTimeMS)/1000
						local exp_time = endTimeMS/1000
						self:update("cast", cast_Tag, bar, args, unit, cast_spellID, dur, exp_time)
						bar.target_fixed = false
					end
				end
			end
		end
		
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unit, cast_GUID, cast_spellID = ...
		local cast_Tag = cast_GUID
		if cast_Tag and self.actives_bytag[cast_Tag] then 
			self:RemoveAlert(cast_Tag)
		end
		
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
		local unit, _, cast_spellID = ...
		if unit and cast_spellID then
			local spellID = self.MultiSpellIDs[cast_spellID] or cast_spellID			
			local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "cast", spellID})
			if args and not args.dur and (not args.threat_ck or FilterThreat(unit)) then
				local enable = T.ValueFromDB({"AlertTimerbar", "cast", spellID, "enable"})
				if enable then
					local GUID = UnitGUID(unit)
					local cast_Tag = GUID and "Channel-"..GUID
					local startTimeMS, endTimeMS = select(4, UnitChannelInfo(unit))
					if startTimeMS and endTimeMS and cast_Tag and not self.actives_bytag[cast_Tag] then
						local bar = self:GetAlert(args.group or 2, cast_Tag)
						local dur = (endTimeMS - startTimeMS)/1000
						local exp_time = endTimeMS/1000
						self:update("channel", cast_Tag, bar, args, unit, cast_spellID, dur, exp_time)
						bar.target_fixed = true
					end
				end
			end
		end
		
	elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		local unit, _, cast_spellID = ...
		if unit then
			local GUID = UnitGUID(unit)
			local cast_Tag = GUID and "Channel-"..GUID
			if cast_Tag and self.actives_bytag[cast_Tag] then
				self:RemoveAlert(cast_Tag)
			end
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, cast_GUID, cast_spellID = ...
		if unit and cast_GUID and cast_spellID then
			local spellID = self.MultiSpellIDs[cast_spellID] or cast_spellID
			local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "cast", spellID})
			if args and args.dur and (not args.threat_ck or FilterThreat(unit)) then
				local enable = T.ValueFromDB({"AlertTimerbar", "cast", spellID, "enable"})
				if enable then
					local cast_Tag = "Succeeded-"..cast_GUID
					if not self.actives_bytag[cast_Tag] then
						local bar = self:GetAlert(args.group, cast_Tag)
						self:update("cast", cast_Tag, bar, args, unit, cast_spellID, args.dur)
						bar.target_fixed = true
					end
				end
			end
		end
		
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if unit and UnitCastingInfo(unit) then
			local startTimeMS, endTimeMS, _, cast_GUID, _, cast_spellID = select(4, UnitCastingInfo(unit))
			local cast_Tag = cast_GUID
			local bar = self.actives_bytag[cast_Tag]
			if bar then
				local spellID = self.MultiSpellIDs[cast_spellID] or cast_spellID
				local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "cast", spellID})
				if args then
					self:update_target(bar, args, unit)
					bar.target_fixed = true
				end
			end
		end

	elseif event == "DATA_REMOVED" then
		for _, bar in pairs(self.actives_bytag) do
			self:RemoveAlert(bar.tag)
		end
		
	elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_PHASE" then -- 战斗开始重置计数
		self.count_data = table.wipe(self.count_data)
			
	end
end)

T.RegisterEventAndCallbacks(AlertBar_Cast_Updater, {
	["ENCOUNTER_PHASE"] = true,
	["ENCOUNTER_START"] = true,
	["UNIT_SPELLCAST_START"] = true,
	["UNIT_SPELLCAST_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_START"] = true,
	["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
	["UNIT_SPELLCAST_SUCCEEDED"] = true,	
	["UNIT_TARGET"] = true,
	["DATA_REMOVED"] = true,
})

-- 计时条：CLEU

local AlertBar_CLEU_Updater = CreateUpdater(CreateAlertBar, BarFrame, BarFrame2, BarFrame3)

AlertBar_CLEU_Updater.MultiSpellIDs = {}
AlertBar_CLEU_Updater.count_data = {}

T.CreateCLEU = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if not args.group then
		args.group = 2
	end
	
	if not args.sub_group then
		args.sub_group = 1
	end
	
	if not args.color then
		args.color = T.GetSpellColor(args.spellID)
	end
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_Timerbar_Options(option_page, category, path, args, detail_options)
	
	if args.spellIDs then
		for _, spellID in pairs(args.spellIDs) do
			AlertBar_CLEU_Updater.MultiSpellIDs[spellID] = args.spellID
		end
	end
	
	AddData(args, option_page.engageTag, option_page.mapTag, category, args.spellID)
end

function AlertBar_CLEU_Updater:update_layout(cleuTag, bar, args, log_spellID)
	bar:display(args)
	
	local dur = args.dur
	local icon = args.icon_tex or C_Spell.GetSpellTexture(log_spellID) or 134400
	local flagicons = args.ficon and T.GetFlagIconStr(args.ficon) or ""
	local text = args.text or C_Spell.GetSpellName(log_spellID) or ""	
	
	bar.icon:SetTexture(icon)
	bar.left:SetText(string.format("%s %s", flagicons, text))
	bar.mid:SetText("")
	bar:SetMinMaxValues(0, dur)	
	
	if not args.tags and bar.tag_indcators then
		bar:hide_tags()
	elseif args.tags then
		for i, each_dur in pairs(args.tags) do
			bar:pointtag(i, each_dur/dur)
		end
	end
	
	bar.dur = dur
	bar.exp_time = GetTime() + dur
	
	bar:SetScript("OnUpdate", function(s, e)
		s.t = s.t + e
		if s.t > s.update_rate then
			s.remain = s.exp_time - GetTime()
			if s.remain > 0 then		
				s.right:SetText(T.FormatTime(s.remain))
				s:SetValue(s.dur - s.remain)
				
				if s.voi_countdown and s.inRange then -- 倒数
					s.remain_second = ceil(s.remain)
					
					if s.remain_second <= s.voi_countdown and s.remain_second > 0 then
						T.PlaySound("count\\"..s.remain_second) -- 3..2..1..
						s.voi_countdown = s.voi_countdown - 1
					end
				end
			else
				self:RemoveAlert(cleuTag)
			end
			s.t = 0
		end
	end)

	if args.glow then
		bar.anim:Play()
	end
	
	bar:Show()
end

function AlertBar_CLEU_Updater:update_index(bar, args)
	if args.count then
		bar.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.count_data[args.spellID]))
	end
end

function AlertBar_CLEU_Updater:update_range(bar, args, sourceGUID)
	if args.range_ck then
		local unit = UnitTokenFromGUID(sourceGUID)
		if unit and T.IsUnitInRange(unit) then
			bar:SetAlpha(1)
			bar.inRange = true
		else
			bar:SetAlpha(.2)
			bar.inRange = false
		end
	else
		bar:SetAlpha(1)
		bar.inRange = true
	end
end

function AlertBar_CLEU_Updater:update_target(bar, args, destGUID)
	if args.show_tar then
		if destGUID then
			bar.mid:SetText(T.ColorNickNameByGUID(destGUID))
		else
			bar.mid:SetText("")
		end
	end
end

function AlertBar_CLEU_Updater:update_raidmark(bar, args, sourceRaidFlags)
	if args.show_rm then
		local rt = T.GetRaidFlagsMark(sourceRaidFlags)
		bar.rm_text:SetText(rt and T.FormatRaidMark(rt) or "")
	else
		bar.rm_text:SetText("")
	end
end

function AlertBar_CLEU_Updater:play_sound(bar, args, destGUID)
	if args.sound and T.ValueFromDB(bar.path)["sound_bool"] and bar.inRange and SoundStrFilter(args.sound) then
		T.PlaySound(string.match(args.sound, "%[(.+)%]"))
		
		if args.show_tar and destGUID then -- 与朗读序号冲突
			C_Timer.After(1, function()
				local name = T.GetNameByGUID(destGUID)
				if name then
					T.SpeakText(name)
				end
			end)
		end
		
		if args.count then -- 与朗读目标冲突
			C_Timer.After(1, function()
				local ind = self.count_data[args.spellID]
				T.PlaySound("count\\"..ind) -- 序数
			end)
		end
		
		if string.find(args.sound, "cd(%d+)") then
			bar.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
		else
			bar.voi_countdown = nil
		end
	end
end

function AlertBar_CLEU_Updater:update(cleuTag, bar, args, sourceGUID, sourceRaidFlags, destGUID, destRaidFlags, log_spellID)
	-- 外观
	self:update_layout(cleuTag, bar, args, log_spellID)

	-- 序号
	self:update_index(bar, args)
	
	-- 距离
	self:update_range(bar, args, sourceGUID)
	
	-- 目标
	self:update_target(bar, args, destGUID)
	
	-- 标记
	self:update_raidmark(bar, args, sourceRaidFlags)
	
	-- 声音
	self:play_sound(bar, args, destGUID)
end

AlertBar_CLEU_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, sub_event, hide_caster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, log_spellID = CombatLogGetCurrentEventInfo()
		local spellID = self.MultiSpellIDs[log_spellID] or log_spellID
		local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "cleu", spellID})
		if args and args.event == sub_event and (not args.target_me or destGUID == G.PlayerGUID) and (not args.threat_ck or FilterThreat(UnitTokenFromGUID(sourceGUID))) then
			local enable = T.ValueFromDB({"AlertTimerbar", "cleu", spellID, "enable"})
			if enable then
				if not self.count_data[args.spellID] then
					self.count_data[args.spellID] = 0
				end
				
				self.count_data[args.spellID] = self.count_data[args.spellID] + 1

				local countTag = args.copy and ("-"..self.count_data[args.spellID]) or ""
				local cleuTag = "CLEU-"..sub_event.."-"..log_spellID..countTag

				local bar = self:GetAlert(args.group, cleuTag)
				self:update(cleuTag, bar, args, sourceGUID, sourceRaidFlags, destGUID, destRaidFlags, log_spellID)
			end
		end
		
	elseif event == "DATA_REMOVED" then
		for _, bar in pairs(self.actives_bytag) do
			self:RemoveAlert(bar.tag)
		end
		
	elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_PHASE" then -- 战斗开始重置计数
		self.count_data = table.wipe(self.count_data)
		
	end
end)

T.RegisterEventAndCallbacks(AlertBar_CLEU_Updater, {	
	["ENCOUNTER_PHASE"] = true,
	["ENCOUNTER_START"] = true,
	["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	["DATA_REMOVED"] = true,
})

-- 计时条：光环

local AlertBar_Aura_Updater = CreateUpdater(CreateAlertBar, BarFrame, BarFrame2, BarFrame3)

AlertBar_Aura_Updater.MultiSpellIDs = {}
AlertBar_Aura_Updater.count_data = {}

T.CreateAuraBar = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if not args.group then
		args.group = 2
	end
	
	if not args.sub_group then
		args.sub_group = 1
	end
	
	if not args.color then
		args.color = T.GetSpellColor(args.spellID)
	end
	
	if args.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.sound})
	end
	
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_Timerbar_Options(option_page, category, path, args, detail_options)
	
	if args.spellIDs then
		for _, spellID in pairs(args.spellIDs) do
			AlertBar_Aura_Updater.MultiSpellIDs[spellID] = args.spellID
		end
	end
	
	AddData(args, option_page.engageTag, option_page.mapTag, category, args.spellID)
end

function AlertBar_Aura_Updater:update_index(bar, args)
	if args.count then
		if not self.count_data[args.spellID] then
			self.count_data[args.spellID] = 0
		end
		
		self.count_data[args.spellID] = self.count_data[args.spellID] + 1
		
		bar.ind_text:SetText(string.format("|cffFFFF00[%d]|r", self.count_data[args.spellID]))
	end
end

function AlertBar_Aura_Updater:update_range(bar, args, unit)
	if args.range_ck then
		if T.IsUnitInRange(unit) then	
			bar:SetAlpha(1)
			bar.inRange = true
		else
			bar:SetAlpha(.2)
			bar.inRange = false
		end
	else
		bar:SetAlpha(1)
		bar.inRange = true
	end
end

function AlertBar_Aura_Updater:update_target(bar, args, GUID)
	if args.show_tar then
		if GUID then
			bar.mid:SetText(T.ColorNickNameByGUID(GUID))
		else
			bar.mid:SetText("")
		end
	end
end

function AlertBar_Aura_Updater:update_raidmark(bar, args, unit)
	if args.show_rm then
		local rt = GetRaidTargetIndex(unit)
		bar.rm_text:SetText(rt and T.FormatRaidMark(rt) or "")
	else
		bar.rm_text:SetText("")
	end
end

function AlertBar_Aura_Updater:play_sound(bar, args, GUID)
	if args.sound and T.ValueFromDB(bar.path)["sound_bool"] and bar.inRange and SoundStrFilter(args.sound) then
		T.PlaySound(string.match(args.sound, "%[(.+)%]"))
		
		if args.show_tar and GUID then -- 与朗读序号冲突
			C_Timer.After(1, function()
				local name = T.GetNameByGUID(GUID)
				if name then
					T.SpeakText(name)
				end
			end)
		end
		
		if args.count then -- 与朗读目标冲突
			C_Timer.After(1, function()
				local ind = self.count_data[args.spellID]
				T.PlaySound("count\\"..ind) -- 序数
			end)
		end
		
		if string.find(args.sound, "cd(%d+)") then
			bar.voi_countdown = tonumber(string.match(args.sound, "cd(%d+)"))
		else
			bar.voi_countdown = nil
		end
	end
end

function AlertBar_Aura_Updater:update(aura_tag, bar, args, unit, GUID, aura_data, applied) -- 待更新
	local name = aura_data.name
	local icon = aura_data.icon
	local count = aura_data.applications
	local amount = (args.effect and aura_data.points and aura_data.points[args.effect]) or 0
	local exp_time = aura_data.expirationTime	
	local duration = aura_data.duration	
	local flagicons = args.ficon and T.GetFlagIconStr(args.ficon) or ""
	
	if applied then
		bar:display(args)
		
		-- 序号
		self:update_index(bar, args)
		
		-- 距离
		self:update_range(bar, args, unit)
		
		-- 目标
		self:update_target(bar, args, GUID)
		
		-- 标记
		self:update_raidmark(bar, args, unit)
		
		-- 声音
		self:play_sound(bar, args, GUID)
		
		bar.GUID = GUID
		bar.count_old = nil
		bar.duration_old = nil
		bar.exp_time_old = nil
		
		if not args.tags and bar.tag_indcators then
			bar:hide_tags()
		elseif args.tags then
			for i, each_dur in pairs(args.tags) do
				bar:pointtag(i, each_dur/duration)
			end
		end
	end
	
	-- 图标
	bar.icon:SetTexture(args.icon_tex or icon or 134400)
	
	-- 层数或数量刷新
	if amount > 0 then
		bar.value_text:SetText(string.format("|cff00BFFF[%s]|r", T.ShortValue(amount)))
	else
		bar.value_text:SetText(count > 0 and string.format("|cffFFFF00[%s]|r", count) or "")
	end
	
	-- 文字刷新
	if bar.count_old ~= count then
		if args.text then
			if string.match(args.text, "%%s(%d+)") then -- 显示法术效果（如易伤20%，减速40%）
				local value = tonumber(string.match(args.text, "%%s(%d+)"))
				local new_text = args.text:gsub("(%d+)", ""):gsub("%%s", value*count)
				bar.left:SetText(flagicons.." "..new_text)
			else
				bar.left:SetText(flagicons.." "..args.text)
			end
		else
			bar.left:SetText(flagicons.." "..name)
		end	
	end

	-- 时间刷新
	if bar.duration_old ~= duration or bar.exp_time_old ~= exp_time then
		if args.force_full then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
			bar.right:SetText("")
			bar:SetScript("OnUpdate", nil)
		elseif duration > 0 and exp_time > 0 then
			bar:SetMinMaxValues(0, duration)
			bar:SetScript("OnUpdate", function(s, e)
				s.t = s.t + e
				if s.t > s.update_rate then
					s.remain = exp_time - GetTime()
					if s.remain > 0 then
						s.right:SetText(T.FormatTime(s.remain))
						s:SetValue(duration - s.remain)
						
						if s.voi_countdown and s.inRange then -- 倒数
							s.remain_second = ceil(s.remain)
							
							if s.remain_second <= s.voi_countdown and s.remain_second > 0 then
								T.PlaySound("count\\"..s.remain_second) -- 3..2..1..
								s.voi_countdown = s.voi_countdown - 1
							end
						end
					else
						self:RemoveAlert(aura_tag)
					end
					s.t = 0
				end
			end)
		else
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
			bar.right:SetText("∞")
			bar:SetScript("OnUpdate", nil)
		end
	end
	
	if args.glow then
		bar.anim:Play()
	end
	
	bar.count_old = count
	bar.duration_old = duration
	bar.exp_time_old = exp_time
	
	bar:Show()
end

function AlertBar_Aura_Updater:AuraFullCheck(unit, GUID)
	for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
		AuraUtil.ForEachAura(unit, auraType, nil, function(aura_data)
			local spellID = self.MultiSpellIDs[aura_data.spellId] or aura_data.spellId
			local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "aura", spellID})
			if args and T.CheckUnit(unit, args.unit, args.roles) and CheckAuraType(args.aura_type, aura_data) and (not args.threat_ck or FilterThreat(unit)) then
				local enable = T.ValueFromDB({"AlertTimerbar", "aura", spellID, "enable"})
				local aura_tag = GUID.."-"..aura_data.auraInstanceID
				if enable and not self.actives_bytag[aura_tag] then
					local bar = self:GetAlert(args.group, aura_tag)
					self:update(aura_tag, bar, args, unit, GUID, aura_data, true)
				end
			end
		end, true)
	end
end

AlertBar_Aura_Updater:SetScript("OnEvent", function(self, event, ...)	
	if event == "UNIT_AURA" then
		local unit, updateInfo = ...
		if unit and T.FilterAuraUnit(unit) then
			if updateInfo == nil or updateInfo.isFullUpdate then				
				local GUID = UnitGUID(unit)
				if not GUID then return end
				
				for _, bar in pairs(self.actives_bytag) do
					if bar.GUID == GUID then
						self:RemoveAlert(bar.tag)
					end
				end
				
				self:AuraFullCheck(unit, GUID)
			else
				if updateInfo.addedAuras ~= nil then
					for _, aura_data in pairs(updateInfo.addedAuras) do
						local spellID = self.MultiSpellIDs[aura_data.spellId] or aura_data.spellId
						local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "aura", spellID})
						if args and T.CheckUnit(unit, args.unit, args.roles) and CheckAuraType(args.aura_type, aura_data) and (not args.threat_ck or FilterThreat(unit)) then
							local enable = T.ValueFromDB({"AlertTimerbar", "aura", spellID, "enable"})
							local GUID = UnitGUID(unit)
							local aura_tag = GUID and GUID.."-"..aura_data.auraInstanceID
							if enable and aura_tag and not self.actives_bytag[aura_tag] then
								local bar = self:GetAlert(args.group, aura_tag)
								self:update(aura_tag, bar, args, unit, GUID, aura_data, true)
							end
						end
					end
				end
				if updateInfo.updatedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
						local GUID = UnitGUID(unit)
						local aura_tag = GUID and GUID.."-"..auraID
						local bar = aura_tag and self.actives_bytag[aura_tag]
						if bar then
							local aura_data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
							if aura_data then
								local spellID = self.MultiSpellIDs[aura_data.spellId] or aura_data.spellId
								local args = T.ValueFromPath(G.Current_Data, {"AlertTimerbar", "aura", spellID})
								if args then
									self:update(aura_tag, bar, args, unit, GUID, aura_data)
								end
							else
								self:RemoveAlert(bar.tag)
							end
						end
					end
				end
				if updateInfo.removedAuraInstanceIDs ~= nil then
					for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
						local GUID = UnitGUID(unit)
						local aura_tag = GUID and GUID.."-"..auraID
						local bar = aura_tag and self.actives_bytag[aura_tag]
						if bar then
							self:RemoveAlert(bar.tag)
						end
					end
				end
			end
		end
		
	elseif event == "ENCOUNTER_ENGAGE_UNIT" then
		local unit, GUID = ...
		if T.FilterAuraUnit(unit) then
			self:AuraFullCheck(unit, GUID)
		end
		
	elseif event == "DATA_ADDED" then
		for _, unit in pairs(aura_check_units) do			
			if UnitExists(unit) then
				local GUID = UnitGUID(unit)
				if not GUID then return end
				self:AuraFullCheck(unit, GUID)
			end
		end
		
	elseif event == "DATA_REMOVED" then
		for _, bar in pairs(self.actives_bytag) do
			self:RemoveAlert(bar.tag)
		end
		
	elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_PHASE" then -- 战斗开始重置计数
		self.count_data = table.wipe(self.count_data)
		
	end
end)

T.RegisterEventAndCallbacks(AlertBar_Aura_Updater, {
	["ENCOUNTER_PHASE"] = true,
	["ENCOUNTER_START"] = true,
	["UNIT_AURA"] = true,
	["ENCOUNTER_ENGAGE_UNIT"] = true,	
	["DATA_ADDED"] = true,	
	["DATA_REMOVED"] = true,
})

-- 计时条：测试

local AlertBar_Test_Updater = CreateUpdater(CreateAlertBar, BarFrame, BarFrame2, BarFrame3)

function AlertBar_Test_Updater:update(key, bar, args)
	local dur = args.dur
	
	bar:display(args)
	bar:SetMinMaxValues(0, dur)
	
	bar.icon:SetTexture(C_Spell.GetSpellTexture(args.spellID))
	bar.left:SetText(C_Spell.GetSpellName(args.spellID))
	
	if args.show_tar then
		bar.mid:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
	else
		bar.mid:SetText("")
	end
	
	if not args.tags and bar.tag_indcators then
		bar:hide_tags()
	elseif args.tags then
		for i, each_dur in pairs(args.tags) do
			bar:pointtag(i, each_dur/dur)
		end
	end
	
	bar.dur = dur
	bar.exp_time = GetTime() + dur
	
	bar:SetScript("OnUpdate", function(s, e)
		s.t = s.t + e
		if s.t > update_rate then	
			s.remain = s.exp_time - GetTime()
			if s.remain > 0 then
				s.right:SetText(T.FormatTime(s.remain))
				s:SetValue(s.dur - s.remain)
			else
				self:RemoveAlert(key)
			end
			s.t = 0
		end
	end)
	
	if args.glow then
		bar.anim:Play()
	end
	
	bar:Show()
end

local TestAlertBars = {
	{type = "test", spellID = 139, color = {.9, .5, 0}, dur = 6, group = 1, glow = true, tags = {2, 4}},
	{type = "test", spellID = 2908, color = {.2, .6, 1}, dur = 10},
	{type = "test", spellID = 58461, color = {1, .6, .2}, dur = 15, group = 3, show_tar = true, roles = {"TANK"}},
	{type = "test", spellID = 192517, color = {.02, .6, .83}, dur = 20, group = 3, show_tar = true, roles = {"TANK"}},
}

function BarFrame:PreviewShow()
	for i, args in pairs(TestAlertBars) do
		local bar = AlertBar_Test_Updater:GetAlert(args.group, args.spellID)
		AlertBar_Test_Updater:update(args.spellID, bar, args)
	end
end

function BarFrame:PreviewHide()
	for i, args in pairs(TestAlertBars) do		
		AlertBar_Test_Updater:RemoveAlert(args.spellID)
	end
end

local CreateAlertBarShared = function(group, tag, icon_tex, text, color, tags)
	local bar = AlertBar_Test_Updater:GetAlert(group, tag)
	
	bar:display({
		color = color or T.GetTexColor(icon_tex),
		tags = tags,
	})

	bar.icon:SetTexture(icon_tex or 134400)
	bar.left:SetText(text or "")
	bar.mid:SetText("")
	
	return bar
end
T.CreateAlertBarShared = CreateAlertBarShared

----------------------------------------------------------
-------------------[[    文字提示    ]]-------------------
----------------------------------------------------------
local TextAlertGroupFrames = {}
G.TextAlertGroupFrames = TextAlertGroupFrames

local function CreateTextAlertGroupFrame(name, text, anchor, x, y, pa)
	local frame = CreateFrame("Frame", addon_name..name, FrameHolder)
	frame:SetSize(300, 30)
	
	frame.movingname = text
	frame.point = { a1 = anchor, a2 = "CENTER", x = x, y = y}
	T.CreateDragFrame(frame)
	
	frame.active_byindex = {}
	
	function frame:lineup()
		local lastframe
		for index, text_f in pairs(self.active_byindex) do
			if text_f:IsShown() then
				text_f:ClearAllPoints()
				if not text_f.collapse then
					if not lastframe then
						text_f:SetPoint("TOP", frame, "TOP")
					else
						text_f:SetPoint("TOP", lastframe, "BOTTOM", 0, -5)
					end
					lastframe = text_f
				end
			end
		end
	end
	
	table.insert(TextAlertGroupFrames, frame)
	
	return frame
end

local TextFrame = CreateTextAlertGroupFrame("Text_Alert", L["文字提示1"], "CENTER", 0, 170)
local TextFrame2 = CreateTextAlertGroupFrame("Text_Alert2", L["文字提示2"], "CENTER", 0, 300)

T.LineUpTexts = function(group)
	if group == 1 then
		TextFrame:lineup()
	else
		TextFrame2:lineup()
	end
end

T.EditTextAlertFrames = function(option)
	if option == "all" or option == "font_size" then
		for i, frame in pairs(TextAlertGroupFrames) do
			if i == 1 then
				frame:SetSize(C.DB["TextAlertOption"]["font_size"]*8, C.DB["TextAlertOption"]["font_size"])
			else
				frame:SetSize(C.DB["TextAlertOption"]["font_size_big"]*8, C.DB["TextAlertOption"]["font_size_big"])
			end
		end
	end
	for i, frame in pairs(TextAlertGroupFrames) do
		for _, text_f in pairs(frame.active_byindex) do
			text_f:update_onedit(option)
		end
	end
end

-- 获取文字提示
local CreateAlertText = function(updater, parent, tag)
	local text_f = CreateFrame("Frame", nil, parent)
	text_f:SetSize(160, 20)
	text_f:Hide()

	text_f.t = 0.1
	
	text_f.text = T.createtext(text_f, "OVERLAY", 20, "OUTLINE", "CENTER")
	text_f.text:SetPoint("CENTER", text_f, "CENTER", 0, 0)
	
	function text_f:update_onedit(option) -- 载入配置
		if option == "all" or option == "enable" then
			if self.path then
				if not T.ValueFromDB(self.path)["enable"] then
					self:cancel()
					self.tag = nil
					updater.actives_bytag[tag] = nil
				end
			end
		end
		
		if option == "all" or option == "font_size" then
			local fs = (self.group == 1) and C.DB["TextAlertOption"]["font_size"] or C.DB["TextAlertOption"]["font_size_big"]
			self:SetSize(fs*8, fs)
			self.text:SetFont(G.Font, fs, "OUTLINE")
		end
	end
	
	function text_f:display(args)
		if args.type == "spell" then
			self.edit_key = args.type.."_"..args.data.spellID

			if not self.path then
				self.path = {}
				self.path[1] = "TextAlert"
			end
			
			self.path[2] = args.type
			self.path[3] = args.data.spellID
			
		elseif args.type == "hp" or args.type == "pp" then
			self.edit_key = args.type.."_"..args.data.npc_id
			
			if not self.path then
				self.path = {}
				self.path[1] = "TextAlert"
			end
			
			self.path[2] = args.type
			self.path[3] = args.data.npc_id
		end
		
		-- Init
		self.show_time = 4
		self.round = nil
		self.count_down_start = nil
		self.mute_count_down = nil
		self.prepare_sound = nil
		self.show_ind = nil
		self.cur_text = nil
		self.collapse = nil
		
		if args.color then
			self.text:SetTextColor(unpack(args.color))
		end
		
		self:update_onedit("all")
	end
	
	function text_f:cancel()
		self.edit_key = nil
		self.path = nil
		
		self:Hide()
	end
	
	text_f:HookScript("OnShow", function(self)
		parent:lineup()
	end)
	
	text_f:HookScript("OnHide", function(self)
		parent:lineup()
	end)
	
	table.insert(parent.active_byindex, text_f)
	
	text_f.tag = tag
	
	if parent == TextFrame then
		text_f.group = 1
	else
		text_f.group = 2
	end
	
	if updater then
		updater.actives_bytag[tag] = text_f
	end
	
	return text_f
end

-- 文字：生命值
local AlertText_Health_Updater = CreateUpdater(CreateAlertText, TextFrame, TextFrame2)

T.CreateAlertTextHealth = function(option_page, category, args)
	local path = {category, args.type, args.data.npc_id}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_TextAlert_Options(option_page, category, path, args)
	
	if not args.color then
		args.color = {1, 0, 0}
	end
	
	AddData(args, option_page.engageTag, option_page.mapTag, category, args.data.npc_id)
end

function AlertText_Health_Updater:get_format(perc, args)
	if perc then
		for i, range in pairs(args.data.ranges) do
			if perc <= range["ul"] and perc >= range["ll"] then
				return range["tip"]
			end
		end
	end
end

function AlertText_Health_Updater:update(textTag, text_f, args, perc, text_format)
	text_f:display(args)
	
	text_f.text:SetText(string.format(text_format, perc))
	
	text_f:Show()
end

function AlertText_Health_Updater:check(unit)
	local npcID = T.GetUnitNpcID(unit)
	local args = T.ValueFromPath(G.Current_Data, {"TextAlert", "hp", npcID})
	if args then
		local enable = T.ValueFromDB({"TextAlert", "hp", npcID, "enable"})
		if enable then
			local textTag = "Text-hp-"..npcID
			if not args.data.phase or args.data.phase == self.phase then
				local hp = UnitHealth(unit)
				local hp_max = UnitHealthMax(unit)
				local perc = hp and hp_max and hp/hp_max*100
				local text_format = self:get_format(perc, args)					
				
				if text_format then	
					local text_f = self:GetAlert(1, textTag)
					self:update(textTag, text_f, args, perc, text_format)
				elseif self.actives_bytag[textTag] then
					self:RemoveAlert(textTag)
				end
			else
				self:RemoveAlert(textTag)
			end
		end
	end
end

AlertText_Health_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_HEALTH" then
		local unit = ...
		if unit then
			self:check(unit)
		end
	elseif event == "DATA_ADDED" then
		local additional_event = ...
		if additional_event == "ENCOUNTER_START" then
			self.phase = 1
		end
	elseif event == "ENCOUNTER_PHASE" then
		self.phase = ...
		for unit in T.IterateBoss() do
			self:check(unit)
		end
	elseif event == "ENCOUNTER_END" then
		for _, text in pairs(self.actives_bytag) do
			self:RemoveAlert(text.tag)
		end
	end
end)

T.RegisterEventAndCallbacks(AlertText_Health_Updater, {
	["UNIT_HEALTH"] = {"boss1", "boss2", "boss3", "boss4", "boss5"},
	["DATA_ADDED"] = true,
	["ENCOUNTER_PHASE"] = true,
	["ENCOUNTER_END"] = true,
})

-- 文字：能量值
local AlertText_Power_Updater = CreateUpdater(CreateAlertText, TextFrame, TextFrame2)

T.CreateAlertTextPower = function(option_page, category, args)
	local path = {category, args.type, args.data.npc_id}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_TextAlert_Options(option_page, category, path, args)
	
	if not args.color then
		args.color = {0, 1, 1}
	end

	AddData(args, option_page.engageTag, option_page.mapTag, category, args.data.npc_id)
end

function AlertText_Power_Updater:get_format(value, args)
	if value then
		for i, range in pairs(args.data.ranges) do
			if value <= range["ul"] and value >= range["ll"] then
				return range["tip"]
			end
		end
	end
end

function AlertText_Power_Updater:update(textTag, text_f, args, value, text_format)
	text_f:display(args)
	
	text_f.text:SetText(string.format(text_format, value))
	
	text_f:Show()
end

function AlertText_Power_Updater:check(unit)
	local npcID = T.GetUnitNpcID(unit)
	local args = T.ValueFromPath(G.Current_Data, {"TextAlert", "pp", npcID})
	if args then
		local enable = T.ValueFromDB({"TextAlert", "pp", npcID, "enable"})
		if enable then
			local textTag = "Text-pp-"..npcID
			if not args.data.phase or args.data.phase == self.phase then
				local value = UnitPower(unit)
				local text_format = self:get_format(value, args)	
				
				if text_format then	
					local text_f = self:GetAlert(1, textTag)
					self:update(textTag, text_f, args, value, text_format)
				elseif self.actives_bytag[textTag] then
					self:RemoveAlert(textTag)
				end
			else
				self:RemoveAlert(textTag)
			end
		end
	end
end

AlertText_Power_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_POWER_UPDATE" then
		local unit = ...
		if unit then
			self:check(unit)
		end
	elseif event == "DATA_ADDED" then
		local additional_event = ...
		if additional_event == "ENCOUNTER_START" then
			self.phase = 1
		end
	elseif event == "ENCOUNTER_PHASE" then
		self.phase = ...
		for unit in T.IterateBoss() do
			self:check(unit)
		end
	elseif event == "ENCOUNTER_END" then
		for _, text in pairs(self.actives_bytag) do
			self:RemoveAlert(text.tag)
		end
	end
end)

T.RegisterEventAndCallbacks(AlertText_Power_Updater, {
	["UNIT_POWER_UPDATE"] = {"boss1", "boss2", "boss3", "boss4", "boss5"},
	["DATA_ADDED"] = true,
	["ENCOUNTER_PHASE"] = true,
	["ENCOUNTER_END"] = true,
})

-- 文字：其他
local AlertText_Spell_Updater = CreateUpdater(CreateAlertText, TextFrame, TextFrame2)

T.CreateAlertTextSpell = function(option_page, category, args)
	local details = {}
	local detail_options = {}
	
	if not args.color then
		args.color = T.GetSpellColor(args.data.spellID)
	end
	
	if args.data.sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = args.data.sound})
	end
	
	if args.data.cd_args and args.data.cd_args.prepare_sound then
		details.sound_bool = true
		table.insert(detail_options, {key = "sound_bool", text = L["音效"], default = true, sound = string.format("[%s]",args.data.cd_args.prepare_sound)})
	end
	
	local path = {category, args.type, args.data.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_TextAlert_Options(option_page, category, path, args, detail_options)
		
	AddData(args, option_page.engageTag, option_page.mapTag, category, args.data.spellID)
end

function AlertText_Spell_Updater:update(textTag, text_f, args)	
	text_f:display(args)
	
	text_f.IsEncounter = args.IsEncounterData
	
	if text_f.data == nil then
		text_f.data = {}
	else
		text_f.data = table.wipe(text_f.data)
	end
	
	for k, v in pairs(args.data) do
		text_f.data[k] = v
	end
	
	text_f:SetScript("OnEvent", args.update)
	
	T.RegisterEventAndCallbacks(text_f, args.data.events, true)

	if args.data.events.UNIT_AURA_ADD then
		if args.data.spellIDs then
			for _, spellID in pairs(args.data.spellIDs) do
				T.RegisterWatchAuraSpellID(spellID)
			end
		else
			T.RegisterWatchAuraSpellID(args.data.spellID)
		end
	end
end

function AlertText_Spell_Updater:remove(text_f)
	T.UnregisterEventAndCallbacks(text_f, text_f.data.events)
	if text_f.data.events.UNIT_AURA_ADD then
		if text_f.data.spellIDs then
			for _, spellID in pairs(text_f.data.spellIDs) do
				T.UnregisterWatchAuraSpellID(spellID)
			end
		else
			T.UnregisterWatchAuraSpellID(text_f.data.spellID)
		end
	end
	
	text_f:SetScript("OnEvent", nil)
	text_f:SetScript("OnUpdate", nil)

	text_f.data = table.wipe(text_f.data)
	
	self:RemoveAlert(text_f.tag)
end

AlertText_Spell_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "DATA_ADDED" then
		local additional_event = ...
		for spellID, args in pairs(G.Current_Data["TextAlert"]["spell"]) do
			local enable = T.ValueFromDB({"TextAlert", "spell", spellID, "enable"})
			if enable then
				local textTag = "Text-spell-"..args.data.spellID
				if not self.actives_bytag[textTag] then
					local text_f = self:GetAlert(args.group or 1, textTag)
					self:update(textTag, text_f, args)
					if additional_event == "ENCOUNTER_START" then
						args.update(text_f, ...)
					else
						args.update(text_f, "DATA_ADDED")
					end
				end
			end
		end
	elseif event == "DATA_REMOVED" then
		local additional_event = ...
		for tag, text_f in pairs(self.actives_bytag) do
			if additional_event == "ENCOUNTER_END" then
				if text_f.IsEncounter then
					self:remove(text_f)
				end
			else
				self:remove(text_f)
			end
		end
	elseif event == "DB_UPDATE" then
		local ENCID, category, sub_type, spellID = ...
		local mapID = select(8, GetInstanceInfo())
		if G.mapIDtoENCIDs[mapID] and G.mapIDtoENCIDs[mapID][ENCID] then
			if category == "TextAlert" and sub_type == "spell" then				
				local textTag = "Text-spell-"..spellID
				local enable = T.ValueFromDB({"TextAlert", "spell", spellID, "enable"})
				if enable then
					if not self.actives_bytag[textTag] then
						local args = G.Current_Data["TextAlert"]["spell"][spellID]
						if args and not args.IsEncounterData then
							local text_f = self:GetAlert(args.group or 1, textTag)
							self:update(textTag, text_f, args)
						end
					end
				else
					local text_f = self.actives_bytag[textTag]
					if text_f then
						self:remove(text_f)
					end
				end
			end
		end
	end
end)

T.RegisterEventAndCallbacks(AlertText_Spell_Updater, {
	["DATA_ADDED"] = true,
	["DATA_REMOVED"] = true,
	["DB_UPDATE"] = true,
})

-- 文字：测试
local AlertText_Test_Updater = CreateUpdater(CreateAlertText, TextFrame, TextFrame2)

local TestAlertTexts = {
	{type = "test", group = 1, spellID = 139, text = L["文字提示1"], color = {0, 1, 0}, dur = 20},
	{type = "test", group = 2, spellID = 17, text = L["文字提示2"], color = {1, 1, 0}, dur = 20},
}

function TextFrame:PreviewShow()
	for i, args in pairs(TestAlertTexts) do
		local textTag = "Text-test-"..args.spellID
		local text_f = AlertText_Test_Updater:GetAlert(args.group, textTag)
		text_f:display(args)
		text_f.text:SetText(T.GetSpellIcon(args.spellID)..args.text)
		text_f:Show()	
	end
end

function TextFrame:PreviewHide()
	for i, args in pairs(TestAlertTexts) do		
		local textTag = "Text-test-"..args.spellID
		AlertText_Test_Updater:RemoveAlert(textTag)
	end
end

local CreateAlertTextShared = function(tag, group, color)
	local text_f = AlertText_Test_Updater:GetAlert(group, tag)
	
	text_f:display({
		color = color,
	})	
	return text_f
end
T.CreateAlertTextShared = CreateAlertTextShared

----------------------------------------------------------
------------------[[    姓名板提示    ]]------------------
----------------------------------------------------------
local PlateAlertFrames = {}
local PlateAlertMultiSpellData = {}
local PlateIconHolders = {}
local PlateAuraSourceFrames = {}
local CantInterruptPlayerGUIDs = {} -- 不能打断的人

local Npc = {} -- 打断npcID
local Npc_InterruptNum = {}
local InterruptMrtData = {} -- MRT打断人员信息
local InterruptMrtDataCount = {} -- MRT打断轮次信息
local InterruptData = {} -- 当前打断轮次
local Hidden_Interrupt_Npcs = {} -- 临时禁用的打断npcID
local Interrupt_GUIDs = {}
local Foucus_RaidTarget = {}
local AssignedBackups = {}
local last_focus_alert = 0
local last_cast_alert = 0
local my_interrupt_GUID
local auto_mark_npcs = {}

G.Npc = Npc
G.Npc_InterruptNum = Npc_InterruptNum
G.Hidden_Interrupt_Npcs = Hidden_Interrupt_Npcs
G.PlateIconHolders = PlateIconHolders
G.CantInterruptPlayerGUIDs = CantInterruptPlayerGUIDs
G.Textured_GUIDs = {} -- 带材质的怪

T.RegisterInitCallback(function()
	G.InterruptBar = CreateAlertBarShared(1, "interrupt", 132219, "", {1, .2, .6})
end)

local NamePlateAlertTrigger = CreateFrame("Frame", G.addon_name.."NamePlateAlertTrigger", UIParent)

----------------------------------------------------------
----------------[[    姓名板高亮API    ]]-----------------
----------------------------------------------------------
-- 显示姓名板高亮 unit
local function ShowPlateGlowByGUID(glow_key, unit, color, GUID)
	local GUID = GUID or UnitGUID(unit)
	if unit and GUID then
		local frame = T.GetUnitNameplate(unit)
		if frame then	
			local tag = string.format(":%s:%s", glow_key, GUID)
			LCG.PixelGlow_Start(frame, color, 12, .25, nil, 3, 3, 3, true, tag)
		end
	end
end
T.ShowPlateGlowByGUID = ShowPlateGlowByGUID

local function ShowPlateGlowbyTag(glow_key, unit, color, ID)
	if unit and ID then
		local frame = T.GetUnitNameplate(unit)
		if frame then	
			local tag = string.format(":%s:%s", glow_key, ID)
			LCG.PixelGlow_Start(frame, color, 12, .25, nil, 3, 3, 3, true, tag)
		end
	end
end
T.ShowPlateGlowbyTag = ShowPlateGlowbyTag

-- 隐藏像素高亮 完全一致
local function HidePlateGlowByTag(glow_key, ID)
	if not (glow_key and ID) then return end
	local tag = string.format("%s:%s:%s", "_PixelGlow", glow_key, ID)
	local current = LCG.GlowFramePool:GetNextActive()
	while current do
		if current.name == tag then
			LCG.GlowFramePool:Release(current)	
		end
		current = LCG.GlowFramePool:GetNextActive(current)
	end
end
T.HidePlateGlowByTag = HidePlateGlowByTag

-- 隐藏像素高亮 批量匹配
local function HidePlateGlowByKey(glow_key)
	if not glow_key then return end
	local tag = string.format("%s:%s:", "_PixelGlow", glow_key)
	local current = LCG.GlowFramePool:GetNextActive()
	while current do
		if string.find(current.name, tag) then
			LCG.GlowFramePool:Release(current)
		end
		current = LCG.GlowFramePool:GetNextActive(current)
	end
end
T.HidePlateGlowByKey = HidePlateGlowByKey

-- 隐藏姓名板上的像素高亮
local function HidePlateGlowByUnit(glow_key, unit)
	local frame = T.GetUnitNameplate(unit)
	if frame then		
		local tag
		if glow_key then
			tag = string.format("%s:%s:", "_PixelGlow", glow_key)
		else
			tag = "_PixelGlow"
		end
		
		for key, glow_f in pairs(frame) do
			if string.find(key, tag) then
				LCG.GlowFramePool:Release(glow_f)
			end
		end
	end
end
T.HidePlateGlowByUnit = HidePlateGlowByUnit

----------------------------------------------------------
----------------[[    姓名板打断API    ]]-----------------
----------------------------------------------------------
-- 预备打断音效
T.Play_interrupt_sound = function()
	if C.DB["PlateAlertOption"]["interrupt_sound"] ~= "none" then
		local now = GetTime()
		if now - last_cast_alert > 1 then
			if now - last_focus_alert < 2 then
				C_Timer.After(1.6, function()
					if GetTime() - last_cast_alert > 1 then
						T.PlaySound(C.DB["PlateAlertOption"]["interrupt_sound"])
					end
				end)
			else
				T.PlaySound(C.DB["PlateAlertOption"]["interrupt_sound"])
			end
		end
	end
end

-- 打断音效
T.Play_interrupt_sound_cast = function()	
	if C.DB["PlateAlertOption"]["interrupt_sound_cast"] ~= "none" then
		T.PlaySound(C.DB["PlateAlertOption"]["interrupt_sound_cast"])
	end
end

-- 更新打断序号
local function UpdateInterruptInd(GUID, mark)
	local npcID = select(6, string.split("-", GUID))
	local mark_ind = mark or 9

	local num
	if InterruptMrtDataCount[npcID] then
		if InterruptMrtDataCount[npcID][mark_ind] then -- 有mrt数据
			num = InterruptMrtDataCount[npcID][mark_ind]
		elseif InterruptMrtDataCount[npcID][9] then -- 有mrt数据(不区分标记)
			num = InterruptMrtDataCount[npcID][9]
		else -- 有mrt数据 但没有当前标记或无标记的
			num = Npc_InterruptNum[npcID]
		end
	else
		num = Npc_InterruptNum[npcID]
	end
	
	if num then
		if not InterruptData[GUID] or InterruptData[GUID] >= num then
			InterruptData[GUID] = 1
		else
			InterruptData[GUID] = InterruptData[GUID] + 1
		end
	end
end

-- 更新打断文字
local function UpdateInterruptText(unitFrame)
	C_Timer.After(.05, function()
		if not unitFrame.GUID then return end
		local GUID = unitFrame.GUID
		local npcID = select(6, string.split("-", GUID))
		if Npc_InterruptNum[npcID] then -- 有打断信息
			local icon = unitFrame.icon_bg.interrupticon
			local ind = InterruptData[GUID]
			if icon and ind then
				icon.center_text:SetText(ind)
				-- 显示名字
				local mark = GetRaidTargetIndex(unitFrame.unit) or 9
				if InterruptMrtData[npcID] and InterruptMrtData[npcID][mark] then -- 在MRT中有该标记的打断信息
					if InterruptMrtData[npcID][mark][ind] then -- 本轮有信息
						local t = {}
						for i, player_GUID in pairs(InterruptMrtData[npcID][mark][ind]) do
							local info = T.GetGroupInfobyGUID(player_GUID)
							if info then
								local unit = info.unit
								if not UnitIsDeadOrGhost(unit) and not CantInterruptPlayerGUIDs[player_GUID] then
									if player_GUID == G.PlayerGUID then
										T.Play_interrupt_sound()
									end
									local color_name = T.ColorNickNameByGUID(player_GUID)
									table.insert(t, color_name)
								end
							end
						end
						if not next(t) and InterruptMrtData[npcID][mark]["backups"] then -- 使用替补
							for i, player_GUID in pairs(InterruptMrtData[npcID][mark]["backups"]) do
								local info = T.GetGroupInfobyGUID(player_GUID)
								if info then
									local unit = info.unit
									if not UnitIsDeadOrGhost(unit) and not CantInterruptPlayerGUIDs[player_GUID] then
										if not AssignedBackups[GUID] then
											AssignedBackups[GUID] = {}
										end
										if AssignedBackups[GUID][player_GUID] == nil then
											AssignedBackups[GUID][player_GUID] = ind
										end
										if AssignedBackups[GUID][player_GUID] == ind then
											if player_GUID == G.PlayerGUID then
												T.Play_interrupt_sound()
											end
											local color_name = T.ColorNickNameByGUID(player_GUID)
											table.insert(t, color_name.."|cffff0000*|r")
											break
										end
									end
								end
							end
						end
						icon.top:SetText(table.concat(t, " "))
					else -- 本轮无信息
						icon.top:SetText("--")
					end
				elseif InterruptMrtData[npcID] and InterruptMrtData[npcID][9] then -- 在MRT中有无标记打断信息（小怪有标记而打断讯息无标记）
					if InterruptMrtData[npcID][9][ind] then -- 本轮有信息
						local t = {}
						for i, GUID in pairs(InterruptMrtData[npcID][9][ind]) do
							local info = T.GetGroupInfobyGUID(GUID)
							if info then
								local unit = info.unit
								if not UnitIsDeadOrGhost(unit) and not CantInterruptPlayerGUIDs[GUID] then
									if GUID == G.PlayerGUID then
										T.Play_interrupt_sound()
									end
									local color_name = T.ColorNickNameByGUID(GUID)
									table.insert(t, color_name)
								end
							end
						end
						if not next(t) and InterruptMrtData[npcID][9]["backups"] then -- 使用替补
							for i, GUID in pairs(InterruptMrtData[npcID][9]["backups"]) do
								local info = T.GetGroupInfobyGUID(GUID)
								if info then
									local unit = info.unit
									if not UnitIsDeadOrGhost(unit) and not CantInterruptPlayerGUIDs[GUID] then
										if not AssignedBackups[GUID] then
											AssignedBackups[GUID] = {}
										end
										if AssignedBackups[GUID][player_GUID] == nil then
											AssignedBackups[GUID][player_GUID] = ind
										end
										if AssignedBackups[GUID][player_GUID] == ind then
											if GUID == G.PlayerGUID then
											T.Play_interrupt_sound()
											end
											local color_name = T.ColorNickNameByGUID(GUID)
											table.insert(t, color_name.."|cffff0000*|r")
											break
										end
									end
								end
							end
						end
						icon.top:SetText(table.concat(t, " "))
					else -- 本轮无信息
						icon.top:SetText("--")
					end
				else -- 在MRT中无打断信息
					icon.top:SetText("")
				end
			end
		end
	end)
end

-- 与我相关的打断
local function InterruptDataHasMine(npcID, mark)
	if InterruptMrtData[npcID] and InterruptMrtData[npcID][mark] then -- 在MRT中有该标记的打断信息
		for ind, t in pairs(InterruptMrtData[npcID][mark]) do
			for i, GUID in pairs(t) do
				if GUID == G.PlayerGUID then
					return true
				end
			end
		end
	elseif InterruptMrtData[npcID] and InterruptMrtData[npcID][9] then -- 在MRT中有无标记打断信息（小怪有标记而打断讯息无标记）
		for ind, t in pairs(InterruptMrtData[npcID][9]) do
			for i, GUID in pairs(t) do
				if GUID == G.PlayerGUID then
					return true
				end
			end
		end
	end
end

-- 隐藏打断图标
local function HideInterruptIcon(unitFrame)
	local icon = unitFrame.icon_bg.interrupticon
	if icon then
		icon:Hide()
		icon.top:SetText("")
		icon.center_text:SetText("")
		icon.animtex:Hide()
		icon:SetScript("OnUpdate", nil)
	end
end

-- 显示打断条
local function ShowInterruptBar(unit, GUID, spell_exp)
	if C.DB["PlateAlertOption"]["interrupt_bar"] then
		my_interrupt_GUID = GUID
		if UnitCastingInfo(unit) then
			local name, text, texture, startTimeMS, endTimeMS = UnitCastingInfo(unit)
			G.InterruptBar.icon:SetTexture(texture)
			if spell_exp == 0 then
				G.InterruptBar.left:SetText(string.format("|cffffff00%s|r %s", L["打断"], name))
			else
				local wait = spell_exp - GetTime()
				G.InterruptBar.left:SetText(string.format("|cffffff00%s|r %s |cffadd6ffCD:%.1f|r", L["打断"], name, wait))
				C_Timer.After(wait, function()
					G.InterruptBar.left:SetText(string.format("|cffffff00%s|r %s |cff00ff00%s|r", L["打断"], name, L["就绪"]))
				end)
			end
			local dur = (endTimeMS - startTimeMS)/1000
			T.StartTimerBar(G.InterruptBar, dur, true, true)
		elseif UnitChannelInfo(unit) then
			local name, text, texture, startTimeMS, endTimeMS = UnitChannelInfo(unit)
			G.InterruptBar.icon:SetTexture(texture)	
			G.InterruptBar.left:SetText(string.format("|cffffff00%s|r %s", L["打断"], name))
			local dur = (endTimeMS - startTimeMS)/1000
			T.StartTimerBar(G.InterruptBar, dur, true, true, true)
		end
	end
end

-- 隐藏打断条
local function HideInterruptBar(GUID)
	if C.DB["PlateAlertOption"]["interrupt_bar"] then
		if GUID == my_interrupt_GUID then
			T.StopTimerBar(G.InterruptBar, true, true, true)
			my_interrupt_GUID = nil
		end
	end
end

local InterruptSpells = {
	PRIEST = {
		15487, -- 沉默
	},
	DRUID = {
		78675, -- 日光术
		106839, -- 迎头痛击
	},
	SHAMAN = { 
		57994, -- 风剪
	},
	PALADIN = {
		96231, -- 责难
		31935, -- 复仇者之盾
	},
	WARRIOR = { 
		6552, -- 拳击
	},
	MAGE = { 
		2139, -- 法术反制
	},
	WARLOCK = { 
		19647, -- 法术封锁
	},
	HUNTER = { 
		147362, -- 反制射击		
	},
	ROGUE = { 
		1766, -- 脚踢
	},
	DEATHKNIGHT = {
		47528, -- 心灵冰冻
	},
	MONK = {
		116705, -- 切喉手
	},
	DEMONHUNTER = {
		183752, -- 瓦解
	},
	EVOKER = {
		351338, -- 镇压
	},
}

local function GetInterruptSpell(exp_time)
	if InterruptSpells[G.myClass] then
		for _, spellID in pairs(InterruptSpells[G.myClass]) do
			local learned = IsSpellKnown(spellID) or IsSpellKnown(spellID, true)
			if learned then
				local cd_info = C_Spell.GetSpellCooldown(spellID)
				local starttime, duration, enabled = cd_info.startTime, cd_info.duration, cd_info.isEnabled
				if starttime == 0 then
					return spellID, 0
				elseif exp_time then
					local spell_exp = starttime + duration
					if exp_time - spell_exp > .5 then
						return spellID, spell_exp
					end
				end
			end			
		end
	end
end
T.GetInterruptSpell = GetInterruptSpell

-- 打断声音
local function AlertMyInterruptCasting(icon, unit, GUID)
	if unit and GUID then
		local npcID = select(6, string.split("-", GUID))
		local mark = GetRaidTargetIndex(unit) or 9
		local ind = InterruptData[GUID]
		if ind then
			if InterruptMrtData[npcID]  then
				if InterruptMrtData[npcID][mark] and InterruptMrtData[npcID][mark][ind] then
					for i, player_GUID in pairs(InterruptMrtData[npcID][mark][ind]) do
						if player_GUID == G.PlayerGUID then
							if not UnitIsDeadOrGhost("player") and not CantInterruptPlayerGUIDs[player_GUID] then
								if player_GUID == G.PlayerGUID then
									last_cast_alert = GetTime()
									icon.anim:Play()
									T.Play_interrupt_sound_cast()
									ShowInterruptBar(unit, GUID, 0)
									break
								end
							end
						end
					end
					
					local my_backup_ind = AssignedBackups[GUID] and AssignedBackups[GUID][G.PlayerGUID]
					if my_backup_ind and my_backup_ind == ind then
						last_cast_alert = GetTime()
						icon.anim:Play()
						T.Play_interrupt_sound_cast()
						ShowInterruptBar(unit, GUID, 0)
					end
				end
			elseif UnitExists("focus") then
				local focus_GUID = UnitGUID("focus")
				if focus_GUID == GUID then
					if UnitCastingInfo(unit) then
						local _, _, _, startTimeMS, endTimeMS = UnitCastingInfo(unit)
						local cast_expTime = GetTime() + (endTimeMS/1000 - startTimeMS/1000)
						local interrupt_spellID, spell_exp = GetInterruptSpell(cast_expTime)
						if interrupt_spellID then
							last_cast_alert = GetTime()
							icon.anim:Play()
							T.Play_interrupt_sound_cast()
							ShowInterruptBar(unit, GUID, spell_exp)
						end
					elseif UnitChannelInfo(unit) then
						local interrupt_spellID, spell_exp = GetInterruptSpell()
						if interrupt_spellID and spell_exp == 0 then
							last_cast_alert = GetTime()
							icon.anim:Play()
							T.Play_interrupt_sound_cast()
							ShowInterruptBar(unit, GUID, spell_exp)
						end
					end
				end
			end
		end
	end
end

----------------------------------------------------------
----------------[[    姓名板提示模板    ]]----------------
----------------------------------------------------------

--0------------------------------------------------------------------
-- 刷新团队标记
local function UpdateRaidTarget(unitFrame)
	if not unitFrame or not unitFrame.unit then return end
	local frame = unitFrame.icon_bg
	local unit = unitFrame.unit
	local index = GetRaidTargetIndex(unit)
	if frame.spellicon then
		if index then
			SetRaidTargetIconTexture(frame.spellicon.raid_mark_icon, index)
			frame.spellicon.raid_mark_icon:Show()
		else
			frame.spellicon.raid_mark_icon:Hide()
		end
	end
	if frame.interrupticon then
		if index then
			SetRaidTargetIconTexture(frame.interrupticon.raid_mark_icon, index)
			frame.interrupticon.raid_mark_icon:Show()
		else
			frame.interrupticon.raid_mark_icon:Hide()
		end
		T.UpdateInterruptSpells(unitFrame, "INIT")
	end
	if frame.interrupticon_auto then
		if index then
			SetRaidTargetIconTexture(frame.interrupticon_auto.raid_mark_icon, index)
			frame.interrupticon_auto.raid_mark_icon:Show()
		else
			frame.interrupticon_auto.raid_mark_icon:Hide()
		end
	end
end

--1------------------------------------------------------------------
-- 能量小圆圈
local function CreateCircleIcon(parent)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(C.DB["PlateAlertOption"]["size"], C.DB["PlateAlertOption"]["size"])
	button:SetPoint("LEFT", parent:GetParent():GetParent(), "RIGHT", C.DB["PlateAlertOption"]["x"], 0)
	
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3) -- 材质
	button.icon:SetAllPoints()
	button.icon:SetTexture(G.media.circle)
	
	button.value = T.createtext(button, "OVERLAY", 14, "OUTLINE", "CENTER") -- 数值
	button.value:SetPoint("CENTER")
	
	button.anim = button:CreateAnimationGroup()
	button.anim:SetLooping("REPEAT")

	button.alpha = button.anim:CreateAnimation('Alpha')
	button.alpha:SetChildKey("icon")
	button.alpha:SetFromAlpha(1)
	button.alpha:SetToAlpha(.3)
	button.alpha:SetDuration(.5)

	button:Hide()
	
	return button
end

-- 刷新能量
local function UpdatePower(unitFrame)
	if not unitFrame.npcID or not unitFrame.unit or not T.ValueFromPath(PlateAlertFrames, {"PlatePower", unitFrame.npcID}) or not T.ValueFromDB({"PlateAlert", "PlatePower", unitFrame.npcID, "enable"}) then
		if unitFrame.icon_bg.powericon then
			unitFrame.icon_bg.powericon:Hide()
		end
		return
	end
	
	unitFrame.icon_bg.powericon = unitFrame.icon_bg.powericon or CreateCircleIcon(unitFrame.icon_bg)
	
	local pp = UnitPower(unitFrame.unit) -- 获取数值
	if pp >= 50 then
		unitFrame.icon_bg.powericon.icon:SetVertexColor(1, (200-pp*2)/100, 0, .5) -- 黄色到红色
	else
		unitFrame.icon_bg.powericon.icon:SetVertexColor(pp*2/100, 1, 0, .5) -- 绿色到黄色
	end
	unitFrame.icon_bg.powericon.value:SetText(pp)
	
	local info = T.ValueFromPath(PlateAlertFrames, {"PlatePower", unitFrame.npcID})
	
	if info.hl then
		if pp >= info.hl then			
			if not unitFrame.icon_bg.powericon.anim:IsPlaying() then
				unitFrame.icon_bg.powericon.anim:Play()
			end
		else	
			if unitFrame.icon_bg.powericon.anim:IsPlaying() then	
				unitFrame.icon_bg.powericon.anim:Stop()
			end
		end
	else
		if unitFrame.icon_bg.powericon.anim:IsPlaying() then	
			unitFrame.icon_bg.powericon.anim:Stop()
		end
	end
	
	unitFrame.icon_bg.powericon:Show()
end

--2------------------------------------------------------------------
-- 施法图标
local function CreatePlateSpellIcon(parent, tag)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(C.DB["PlateAlertOption"]["size"], C.DB["PlateAlertOption"]["size"])
	
	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 1, 1)
	
	-- 左上符号
	button.raid_mark_icon = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.raid_mark_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	button.raid_mark_icon:SetSize(10, 10)
	button.raid_mark_icon:SetPoint("TOPLEFT", button,"TOPLEFT", 0, 0)
	
	-- 冷却转圈
	button.cd_frame = CreateFrame("COOLDOWN", nil, button, "CooldownFrameTemplate")
	button.cd_frame:SetPoint("TOPLEFT", 1, -1)
	button.cd_frame:SetPoint("BOTTOMRIGHT", -1, 1)
	button.cd_frame:SetDrawEdge(false)
	button.cd_frame:SetAlpha(.7)
	
	button:Hide()
	
	parent.spellicon = button
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新施法图标
local function UpdatePlateSpellIcon(button, icon, duration, rm)
	button.icon:SetTexture(icon)
	button.cd_frame:SetCooldown(GetTime(), duration)	
	if rm then
		SetRaidTargetIconTexture(button.raid_mark_icon, rm)
	end	
	button:Show()
end

-- 刷新施法
local function UpdateSpells(unitFrame, event, spellID)
	local unit = unitFrame.unit
	local GUID = unitFrame.GUID
	
	if not unit or not GUID then return end
	
	if not (event and spellID) then
		HidePlateGlowByUnit("PlateSpells", unit)
	else
		local config_spellID = PlateAlertMultiSpellData[spellID] or spellID
		local info = T.ValueFromPath(PlateAlertFrames, {"PlateSpells", config_spellID})
		
		if info then
			local enable = T.ValueFromDB({"PlateAlert", "PlateSpells", config_spellID, "enable"})
			if enable then
				if event == "UNIT_SPELLCAST_START" then -- 开始施法
					local _, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible, cast_spellID = UnitCastingInfo(unit)
					if cast_spellID == spellID and texture then
						local rm = GetRaidTargetIndex(unit) or 0
						local icon = unitFrame.icon_bg.spellicon or CreatePlateSpellIcon(unitFrame.icon_bg, "PlateSpells")
						UpdatePlateSpellIcon(icon, texture, endTimeMS/1000 - startTimeMS/1000, rm)
						if info.hl_np then
							ShowPlateGlowByGUID("PlateSpells", unit, info.color, GUID)
						end
					end
				elseif event == "UNIT_SPELLCAST_CHANNEL_START" then -- 开始引导
					local _, _, texture, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
					if channel_spellID == spellID and texture then
						local rm = GetRaidTargetIndex(unit) or 0
						local icon = unitFrame.icon_bg.spellicon or CreatePlateSpellIcon(unitFrame.icon_bg, "PlateSpells")
						UpdatePlateSpellIcon(icon, texture, endTimeMS/1000 - startTimeMS/1000, rm)
						if info.hl_np then
							ShowPlateGlowByGUID("PlateSpells", unit, info.color, GUID)
						end
					end
				elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
					local _, _, texture, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
					if channel_spellID == spellID and texture then
						local icon = unitFrame.icon_bg.spellicon
						if icon then
							UpdatePlateSpellIcon(icon, texture, endTimeMS/1000 - startTimeMS/1000)
						end
					end
				elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
					if UnitCastingInfo(unit) or UnitChannelInfo(unit) then return end
					if unitFrame.icon_bg.ActiveIcons["PlateSpells"] then
						unitFrame.icon_bg.ActiveIcons["PlateSpells"]:Hide()
						HidePlateGlowByUnit("PlateSpells", unit)
					end
				end
			else
				if unitFrame.icon_bg.spellicon then
					unitFrame.icon_bg.spellicon:Hide()
				end
			end
		else
			if unitFrame.icon_bg.spellicon then
				unitFrame.icon_bg.spellicon:Hide()
			end
		end
	end
end

--3------------------------------------------------------------------
-- 打断图标
local function CreateInterruptSpellIcon(parent, tag)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(C.DB["PlateAlertOption"]["size"], C.DB["PlateAlertOption"]["size"])
	button.t = 0
	
	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
		
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
		
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 1, 1)
	
	-- 左上符号
	button.raid_mark_icon = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.raid_mark_icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	button.raid_mark_icon:SetSize(10, 10)
	button.raid_mark_icon:SetPoint("TOPLEFT", button,"TOPLEFT", 0, 0)
	
	-- 上方文字
	button.top = T.createtext(button, "OVERLAY", tag == "interrupticon_auto" and 10 or 14, "OUTLINE", "CENTER")
	button.top:SetPoint("BOTTOM", button, "TOP", 0, 5)
	
	-- 中间数字
	button.center_text = T.createtext(button, "OVERLAY", tag == "interrupticon_auto" and 14 or 21, "OUTLINE", "CENTER")
	button.center_text:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.center_text:SetTextColor(1, 0, 0)

	button.animtex = button:CreateTexture(nil, "OVERLAY", nil, 4)
	button.animtex:SetAllPoints(button)
	button.animtex:SetTexture(G.media.blank)
	button.animtex:SetVertexColor(0, 1, 0)
	button.animtex:Hide()
	
	button.anim = button:CreateAnimationGroup()
	button.anim:SetLooping("REPEAT")
	
	button.anim:SetScript("OnPlay", function(self)
		button.animtex:Show()
	end)
	
	button.anim:SetScript("OnStop", function(self)
		button.animtex:Hide()
		button.animtex:SetAlpha(1)
	end)
		
	button.timer = button.anim:CreateAnimation("Alpha")
	button.timer:SetDuration(.5)
	button.timer:SetChildKey("animtex")
	button.timer:SetFromAlpha(1)
	button.timer:SetToAlpha(.2)
	
	button:Hide()
	
	parent[tag] = button
	parent.QueueIcon(button, tag)
	
	return button
end

local function HasFocusforInterrupt()
	if UnitExists("focus") then
		local npcID = T.GetUnitNpcID("focus")
		if Npc_InterruptNum[npcID] then
			return true
		end
	end
end

-- 刷新打断
local function UpdateInterruptSpells(unitFrame, event, spellID)
	if not unitFrame.npcID or not unitFrame.unit or not PlateAlertFrames["PlateInterrupt"] then
		HideInterruptIcon(unitFrame)
		return
	end
	
	if event == "INIT" then -- 单位刷新类事件
		if Npc_InterruptNum[unitFrame.npcID] and not Hidden_Interrupt_Npcs[unitFrame.npcID] then -- 有单位且是需要监测的单位
			local unit = unitFrame.unit
			local GUID = unitFrame.GUID
			local icon = unitFrame.icon_bg.interrupticon or CreateInterruptSpellIcon(unitFrame.icon_bg, "interrupticon")
			
			local mark = GetRaidTargetIndex(unit) or 9
			if C.DB["PlateAlertOption"]["interrupt_only_mine"] or C.DB["PlateAlertOption"]["interrupt_focus_fliter"] then
				if InterruptDataHasMine(unitFrame.npcID, mark) then
					InterruptData[GUID] = InterruptData[GUID] or 1
					UpdateInterruptText(unitFrame)
					icon:Show()
				elseif C.DB["PlateAlertOption"]["interrupt_focus_fliter"] then
					if UnitIsUnit(unit, "focus") then
						InterruptData[GUID] = InterruptData[GUID] or 1
						UpdateInterruptText(unitFrame)
						icon:Show()
					else
						if not HasFocusforInterrupt() then
							InterruptData[GUID] = InterruptData[GUID] or 1
							UpdateInterruptText(unitFrame)
							icon:Show()
						else
							HideInterruptIcon(unitFrame)
						end
					end
				else
					HideInterruptIcon(unitFrame)
				end
			else
				InterruptData[GUID] = InterruptData[GUID] or 1
				UpdateInterruptText(unitFrame)
				icon:Show()
			end
		else -- 隐藏图标
			HideInterruptIcon(unitFrame)
		end
	elseif spellID then -- 施法类事件
		local unit = unitFrame.unit
		local GUID = unitFrame.GUID
		local icon = unitFrame.icon_bg.interrupticon
		if icon then
			local config_spellID = PlateAlertMultiSpellData[spellID] or spellID
			local info = T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", config_spellID})
			if info then
				local enable = T.ValueFromDB({"PlateAlert", "PlateInterrupt", config_spellID, "enable"})
				if enable then
					if event == "UNIT_SPELLCAST_START" then -- 开始施法
						local _, _, _, startTimeMS, endTimeMS, _, _, notInterruptible, cast_spellID = UnitCastingInfo(unit)
						if cast_spellID == spellID then					
							AlertMyInterruptCasting(icon, unit, GUID)
						end
					elseif event == "UNIT_SPELLCAST_CHANNEL_START" then -- 开始引导
						local _, _, _, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
						if channel_spellID == spellID then
							AlertMyInterruptCasting(icon, unit, GUID)
						end
					elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
						local _, _, _, startTimeMS, endTimeMS, _, notInterruptible, channel_spellID = UnitChannelInfo(unit)
						if channel_spellID == spellID then
							icon.exp = endTimeMS/1000
						end		
					elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
						if UnitCastingInfo(unit) or UnitChannelInfo(unit) then return end
						UpdateInterruptText(unitFrame)
						icon:SetScript("OnUpdate", nil)
						icon.anim:Stop()
						HideInterruptBar(GUID)
					end
				end
			end
		end
	end
end
T.UpdateInterruptSpells = UpdateInterruptSpells

--4------------------------------------------------------------------
-- 光环层数图标
local function CreatePlateStackAuraIcon(parent, tag) 
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(C.DB["PlateAlertOption"]["size"], C.DB["PlateAlertOption"]["size"])

	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 0, 0)
	
	-- 中间数字
	button.center_text = T.createtext(button, "OVERLAY", 21, "OUTLINE", "CENTER")
	button.center_text:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.center_text:SetTextColor(1, 0, 0)

	button:Hide()
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新光环层数图标
local aura_stack_color = {{1, 1, 1}, {0, 1, 0}, {1, 1, 0}, {1, 0, 0},}
local function UpdatePlateStackAuraIcon(button, count)
	button.icon:SetTexture(G.media.blank) -- 图标
	button.center_text:SetText(count > 0 and count or "")
	if count and count > 0 then -- 层数
		local color = aura_stack_color[count] or aura_stack_color[4]
		button.icon:SetVertexColor(unpack(color))
	else
		button.icon:SetVertexColor(1, 1, 1)
	end
	
	button:Show()
end

-- 刷新光环层数
local function UpdatePlateStackAuras(unitFrame, unit, updateInfo)
	if not PlateAlertFrames.PlateStackAuras then return end
	
	if updateInfo == nil or updateInfo.isFullUpdate then
		HidePlateGlowByUnit("PlateStackAuras", unit)
		
		for tag, icon in pairs(unitFrame.icon_bg.ActiveIcons) do
			if string.find(tag, "PlateStackAuras") then
				icon:Hide()
			end
		end
		
		for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
			AuraUtil.ForEachAura(unit, auraType, nil, function(AuraData)
				local config_spellID = PlateAlertMultiSpellData[AuraData.spellId] or AuraData.spellId				
				local info = PlateAlertFrames.PlateStackAuras[config_spellID]
				if info then
					local enable = T.ValueFromDB({"PlateAlert", "PlateStackAuras", config_spellID, "enable"})
					local aura_tag = "PlateStackAuras"..unitFrame.GUID.."-"..AuraData.auraInstanceID
					if enable and not unitFrame.icon_bg.ActiveIcons[aura_tag] then
						local icon = CreatePlateStackAuraIcon(unitFrame.icon_bg, aura_tag)
						UpdatePlateStackAuraIcon(icon, AuraData.applications)
						if info.hl_np then
							ShowPlateGlowByGUID("PlateStackAuras", unit, info.color)
						end
					end
				end
			end, true)
		end
	else
		if updateInfo.addedAuras ~= nil then
			for _, AuraData in pairs(updateInfo.addedAuras) do
				local config_spellID = PlateAlertMultiSpellData[AuraData.spellId] or AuraData.spellId
				local info = T.ValueFromPath(PlateAlertFrames, {"PlateStackAuras", config_spellID})				
				if info then
					local enable = T.ValueFromDB({"PlateAlert", "PlateStackAuras", config_spellID, "enable"})
					local aura_tag = "PlateStackAuras"..unitFrame.GUID.."-"..AuraData.auraInstanceID
					if enable and not unitFrame.icon_bg.ActiveIcons[aura_tag] then
						local icon = CreatePlateStackAuraIcon(unitFrame.icon_bg, aura_tag)		
						UpdatePlateStackAuraIcon(icon, AuraData.applications)
						if info.hl_np then
							ShowPlateGlowByGUID("PlateStackAuras", unit, info.color)
						end
					end
				end
			end
		end
		if updateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
				local aura_tag = "PlateStackAuras"..unitFrame.GUID.."-"..auraID
				local icon = unitFrame.icon_bg.ActiveIcons[aura_tag]
				if icon then
					local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
					if AuraData then
						UpdatePlateStackAuraIcon(icon, AuraData.applications)
					else
						icon:Hide()
						HidePlateGlowByUnit("PlateStackAuras", unit)
					end
				end			
			end
		end
		if updateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
				local aura_tag = "PlateStackAuras"..unitFrame.GUID.."-"..auraID
				local icon = unitFrame.icon_bg.ActiveIcons[aura_tag]
				if icon then
					icon:Hide()
					HidePlateGlowByUnit("PlateStackAuras", unit)
				end
			end
		end
	end
end

--5------------------------------------------------------------------
-- 光环图标
local function CreatePlateAuraIcon(parent, tag) 
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(C.DB["PlateAlertOption"]["size"], C.DB["PlateAlertOption"]["size"])

	-- 图标
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexture(G.media.blank)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	-- 外边框
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	-- 内边框
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(1, 0, 0)
	
	-- 魔法、激怒符号
	button.aura_type_icon = button:CreateTexture(nil, "OVERLAY", nil, 7)
	button.aura_type_icon:SetTexture([[Interface\EncounterJournal\UI-EJ-Icons]])
	button.aura_type_icon:SetSize(20, 20)
	button.aura_type_icon:SetPoint("TOPRIGHT", button,"TOPRIGHT", 6, 6)
	button.aura_type_icon:Hide()
	
	-- 冷却转圈
	button.cd_frame = CreateFrame("COOLDOWN", nil, button, "CooldownFrameTemplate")
	button.cd_frame:SetPoint("TOPLEFT", 1, -1)
	button.cd_frame:SetPoint("BOTTOMRIGHT", -1, 1)
	button.cd_frame:SetDrawEdge(false)
	button.cd_frame:SetAlpha(.7)
	
	-- 层数
	button.text = T.createtext(button, "OVERLAY", 7, "OUTLINE", "RIGHT")
	button.text:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, 2)
	button.text:SetTextColor(.4, .95, 1)
			
	button:Hide()
	parent.QueueIcon(button, tag)
	
	return button
end

-- 刷新光环图标
local function UpdatePlateAuraIcon(button, icon, count, duration, expirationTime, debuffType)
	local color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor.none -- 颜色
	
	button.overlay:SetVertexColor(color.r, color.g, color.b)
	button.icon:SetTexture(icon) -- 图标
	if count and count > 0 then
		button.text:SetText(count)
	else
		button.text:SetText("")
	end	
	button.cd_frame:SetCooldown(expirationTime - duration, duration) -- 冷却转圈
	
	if debuffType == "Magic" then
		T.EncounterJournal_SetFlagIcon(button.aura_type_icon, 7)
	elseif debuffType == "" then
		T.EncounterJournal_SetFlagIcon(button.aura_type_icon, 11)	
	else
		T.EncounterJournal_SetFlagIcon(button.aura_type_icon, 0)
	end
	
	button:Show()
end

-- 刷新光环
local function UpdatePlateAuras(unitFrame, unit, updateInfo)
	if not PlateAlertFrames.PlateAuras then return end
	
	if updateInfo == nil or updateInfo.isFullUpdate then
		HidePlateGlowByUnit("PlateAuras", unit)
		
		for tag, icon in pairs(unitFrame.icon_bg.ActiveIcons) do
			if string.find(tag, "PlateAuras") then
				icon:Hide()
			end
		end
		
		for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
			AuraUtil.ForEachAura(unit, auraType, nil, function(AuraData)
				local config_spellID = PlateAlertMultiSpellData[AuraData.spellId] or AuraData.spellId
				local info = PlateAlertFrames.PlateAuras[config_spellID]
				if info then
					local enable = T.ValueFromDB({"PlateAlert", "PlateAuras", config_spellID, "enable"})
					local aura_tag = "PlateAuras"..unitFrame.GUID.."-"..AuraData.auraInstanceID
					if enable and not unitFrame.icon_bg.ActiveIcons[aura_tag] then
						local icon = CreatePlateAuraIcon(unitFrame.icon_bg, aura_tag)
						UpdatePlateAuraIcon(icon, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime, AuraData.dispelName)
						if info.hl_np then
							ShowPlateGlowByGUID("PlateAuras", unit, info.color)
						end
					end
				end
			end, true)
		end
	else
		if updateInfo.addedAuras ~= nil then
			for _, AuraData in pairs(updateInfo.addedAuras) do
				local config_spellID = PlateAlertMultiSpellData[AuraData.spellId] or AuraData.spellId
				local info = T.ValueFromPath(PlateAlertFrames, {"PlateAuras", config_spellID})
				if info then
					local enable = T.ValueFromDB({"PlateAlert", "PlateAuras", config_spellID, "enable"})
					local aura_tag = "PlateAuras"..unitFrame.GUID.."-"..AuraData.auraInstanceID
					if enable and not unitFrame.icon_bg.ActiveIcons[aura_tag] then
						local icon = CreatePlateAuraIcon(unitFrame.icon_bg, aura_tag)
						UpdatePlateAuraIcon(icon, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime, AuraData.dispelName)
						if info.hl_np then
							ShowPlateGlowByGUID("PlateAuras", unit, info.color)
						end
					end
				end
			end
		end
		if updateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
				local aura_tag = "PlateAuras"..unitFrame.GUID.."-"..auraID
				local icon = unitFrame.icon_bg.ActiveIcons[aura_tag]
				if icon then
					local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
					if AuraData then
						UpdatePlateAuraIcon(icon, AuraData.icon, AuraData.applications, AuraData.duration, AuraData.expirationTime, AuraData.dispelName)
					else
						icon:Hide()
						HidePlateGlowByUnit("PlateAuras", unit)
					end
				end
			end
		end
		if updateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
				local aura_tag = "PlateAuras"..unitFrame.GUID.."-"..auraID
				local icon = unitFrame.icon_bg.ActiveIcons[aura_tag]
				if icon then
					icon:Hide()
					HidePlateGlowByUnit("PlateAuras", unit)
				end
			end
		end
	end
end

--6------------------------------------------------------------------
-- 刷新光环来源
local function UpdatePlateAuraSource(updateInfo)
	if not PlateAlertFrames.PlayerAuraSource then return end
	
	if updateInfo == nil or updateInfo.isFullUpdate then
		for auraID, tex_frame in pairs(PlateAuraSourceFrames) do
			tex_frame:Hide()
			HidePlateGlowByTag("PlayerAuraSource", auraID)
			PlateAuraSourceFrames[auraID] = nil
		end
		
		for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
			AuraUtil.ForEachAura("player", auraType, nil, function(AuraData)				
				local config_spellID = PlateAlertMultiSpellData[AuraData.spellId] or AuraData.spellId
				local info = T.ValueFromPath(PlateAlertFrames, {"PlayerAuraSource", config_spellID})
				if info then
					local enable = T.ValueFromDB({"PlateAlert", "PlayerAuraSource", config_spellID, "enable"})
					if enable then
						local source = AuraData.sourceUnit
						if source then -- 有需要找到来源的debuff
							local namePlate = C_NamePlate.GetNamePlateForUnit(source)						
							if namePlate and namePlate.jstuf then
								local auraID = AuraData.auraInstanceID
								if not PlateAuraSourceFrames[auraID] then
									PlateAuraSourceFrames[auraID] = namePlate.jstuf:GetAvailableTex()
									PlateAuraSourceFrames[auraID]:Show()
									if info.hl_np then
										ShowPlateGlowbyTag("PlayerAuraSource", source, info.color, auraID)
									end
								end
							end
						end
					end
				end
			end, true)
		end
	else
		if updateInfo.addedAuras ~= nil then
			for _, AuraData in pairs(updateInfo.addedAuras) do	
				local config_spellID = PlateAlertMultiSpellData[AuraData.spellId] or AuraData.spellId			
				local info = T.ValueFromPath(PlateAlertFrames, {"PlayerAuraSource", config_spellID})
				if info then
					local enable = T.ValueFromDB({"PlateAlert", "PlayerAuraSource", config_spellID, "enable"})
					local auraID = AuraData.auraInstanceID
					if enable and not PlateAuraSourceFrames[auraID] then
						local source = AuraData.sourceUnit
						if source then -- 有需要找到来源的debuff
							local namePlate = C_NamePlate.GetNamePlateForUnit(source)						
							if namePlate and namePlate.jstuf then
								PlateAuraSourceFrames[auraID] = namePlate.jstuf:GetAvailableTex()
								PlateAuraSourceFrames[auraID]:Show()
								if info.hl_np then
									ShowPlateGlowbyTag("PlayerAuraSource", source, info.color, auraID)
								end
							end
						end
					end
				end
			end
		end
		if updateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
				local tex_frame = PlateAuraSourceFrames[auraID]
				if tex_frame then
					local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraID)
					if not AuraData then
						tex_frame:Hide()
						HidePlateGlowByTag("PlayerAuraSource", auraID)
						PlateAuraSourceFrames[auraID] = nil
					end
				end		
			end
		end
		if updateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
				local tex_frame = PlateAuraSourceFrames[auraID]
				if tex_frame then
					tex_frame:Hide()	
					HidePlateGlowByTag("PlayerAuraSource", auraID)
					PlateAuraSourceFrames[auraID] = nil
				end
			end
		end
	end
end

--7------------------------------------------------------------------
-- 刷新姓名板高亮
local function UpdateNPCHighlight(unitFrame)
	if not unitFrame or not unitFrame.npcID then return end
	
	local info = T.ValueFromPath(PlateAlertFrames, {"PlateNpcID", unitFrame.npcID})
	if info then
		local enable = T.ValueFromDB({"PlateAlert", "PlateNpcID", unitFrame.npcID, "enable"})
		if enable then
			ShowPlateGlowByGUID("PlateNpcID", unitFrame.unit, info.color)
		else
			HidePlateGlowByUnit("PlateNpcID", unitFrame.unit)
		end
	else
		HidePlateGlowByUnit("PlateNpcID", unitFrame.unit)
	end
end

--------------------------------------------------------------------
-- 姓名板刷新事件
local function CreatePlateMark(parent)
	local tex_frame = CreateFrame("Frame", nil, parent)
	tex_frame:SetSize(35, 35)
	tex_frame:SetPoint("CENTER", parent, 0, 0)
	
	tex_frame.tex1 = tex_frame:CreateTexture(nil, "ARTWORK")
	tex_frame.tex1:SetAllPoints()
	tex_frame.tex1:SetAtlas("Ping_UnitMarker_BG_Warning")
	
	tex_frame.tex2 = tex_frame:CreateTexture(nil, "OVERLAY")
	tex_frame.tex2:SetSize(32, 32)
	tex_frame.tex2:SetPoint("CENTER")
	tex_frame.tex2:SetAtlas("Ping_SpotGlw_Warning_Out")
	
	tex_frame.tex3 = tex_frame:CreateTexture(nil, "OVERLAY")
	tex_frame.tex3:SetSize(21, 21)
	tex_frame.tex3:SetPoint("CENTER")
	tex_frame.tex3:SetAtlas("Ping_Marker_Icon_Warning")	
	
	tex_frame.tex4 = tex_frame:CreateTexture(nil, "ARTWORK")
	tex_frame.tex4:SetSize(5, 30)
	tex_frame.tex4:SetPoint("TOP", tex_frame, "CENTER", 0, -12)
	tex_frame.tex4:SetAtlas("Ping_GroundMarker_Pin_Warning")

	return tex_frame	
end

local function OnNamePlateCreated(namePlate)
	namePlate.jstuf = CreateFrame("Button", "$parent_JST_UnitFrame", namePlate)
	namePlate.jstuf:SetSize(1,1)
	namePlate.jstuf:SetPoint("BOTTOM", namePlate, "TOP", 0, C.DB["PlateAlertOption"]["y"])
	namePlate.jstuf:SetFrameLevel(namePlate:GetFrameLevel())
	namePlate.jstuf:EnableMouse(false)
		
	namePlate.jstuf.textures = {}

	function namePlate.jstuf:CreateTex()
		local ind = #self.textures + 1

		local tex_frame = CreatePlateMark(namePlate.jstuf)
		
		tex_frame:HookScript("OnHide", function(self)
			self.active = false
		end)
		
		self.textures[ind] = tex_frame
		
		return tex_frame
	end
	
	function namePlate.jstuf:GetAvailableTex()
		for _, tex_frame in pairs(self.textures) do
			if not tex_frame.active then
				tex_frame.active = true
				tex_frame:Show()
				return tex_frame
			end
		end
		local new_tex = self:CreateTex()
		new_tex.active = true
		return new_tex
	end
	
	namePlate.jstuf.plate_texture = namePlate.jstuf:CreateTexture(nil, "OVERLAY")
	namePlate.jstuf.plate_texture:SetPoint("TOP", namePlate.jstuf, "BOTTOM", 0, -50)
	namePlate.jstuf.plate_texture:Hide()
	
	namePlate.jstuf.plate_bgtex = namePlate.jstuf:CreateTexture(nil, "BORDER")
	namePlate.jstuf.plate_bgtex:SetPoint("CENTER", namePlate.jstuf.plate_texture, "CENTER")	
	namePlate.jstuf.plate_bgtex:Hide()
	
	namePlate.jstuf.plate_text = T.createtext(namePlate.jstuf, "OVERLAY", 20, "OUTLINE", "CENTER")
	namePlate.jstuf.plate_text:SetPoint("CENTER", namePlate.jstuf.plate_texture, "CENTER")	
	namePlate.jstuf.plate_text:Hide()
	
	namePlate.jstuf.icon_bg = CreateFrame("Frame", nil, namePlate.jstuf)
	namePlate.jstuf.icon_bg:SetAllPoints(namePlate.jstuf)
	namePlate.jstuf.icon_bg:SetFrameLevel(namePlate:GetFrameLevel()+1)

	table.insert(PlateIconHolders, namePlate.jstuf.icon_bg)
	
	if C.DB["GeneralOption"]["disable_all"] or C.DB["GeneralOption"]["disable_plate"] then
		namePlate.jstuf.icon_bg:SetAlpha(0)
	else
		namePlate.jstuf.icon_bg:SetAlpha(1)
	end
	
	namePlate.jstuf.icon_bg.ActiveIcons = {}
	namePlate.jstuf.icon_bg.LineUpIcons = function()
		local active_num = 0
		for _, bu in pairs(namePlate.jstuf.icon_bg.ActiveIcons) do
			active_num = active_num + 1
		end
		local offset = ((C.DB["PlateAlertOption"]["size"]+4)*active_num-4)/2
		
		local lastframe
		for _, bu in pairs(namePlate.jstuf.icon_bg.ActiveIcons) do			
			bu:ClearAllPoints()
			if not lastframe then
				bu:SetPoint("LEFT", namePlate.jstuf.icon_bg, "CENTER", -offset, 0) -- 根据图标数量定位第一个
			else
				bu:SetPoint("LEFT", lastframe, "RIGHT", 3, 0)
			end
			lastframe = bu
		end
	end
	
	namePlate.jstuf.icon_bg.QueueIcon = function(bu, tag)	
		bu:HookScript("OnShow", function()
			namePlate.jstuf.icon_bg.ActiveIcons[tag] = bu			
			namePlate.jstuf.icon_bg.LineUpIcons()
		end)
		
		bu:HookScript("OnHide", function()
			namePlate.jstuf.icon_bg.ActiveIcons[tag] = nil			
			namePlate.jstuf.icon_bg.LineUpIcons()
		end)
	end
end

local PlateCastingEvents = {
	["UNIT_SPELLCAST_START"] = true,
	["UNIT_SPELLCAST_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_START"] = true,
	["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
	["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
}

local function OnNamePlateAdded(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.jstuf
	local GUID = UnitGUID(unit)
	
	unitFrame.unit = unit
	unitFrame.GUID = GUID
	unitFrame.npcID = select(6, strsplit("-", GUID))
	
	-- 更新打勾材质
	if G.Textured_GUIDs[GUID] then
		T.ShowNameplateExtraTex(unit, G.Textured_GUIDs[GUID], GUID)
	else
		T.HideNameplateExtraTex(unit, GUID)
	end
	
	-- 状态刷新
	UpdateSpells(unitFrame)
	UpdateInterruptSpells(unitFrame, "INIT")
	UpdatePower(unitFrame)
	UpdateNPCHighlight(unitFrame)
	UpdateRaidTarget(unitFrame)	
	UpdatePlateStackAuras(unitFrame, unit)
	UpdatePlateAuras(unitFrame, unit)
	UpdatePlateAuraSource()

	-- 注册事件，按事件刷新
	unitFrame:RegisterUnitEvent("UNIT_AURA", unitFrame.unit)
	unitFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", unitFrame.unit)
	for event, v in pairs(PlateCastingEvents) do
		unitFrame:RegisterUnitEvent(event, unitFrame.unit)
	end
	unitFrame:SetScript("OnEvent", function(self, event, unit, ...)
		if event == "UNIT_AURA" and unit == self.unit then	
			UpdatePlateStackAuras(self, unit, ...)
			UpdatePlateAuras(self, unit, ...)
		elseif event == "UNIT_POWER_UPDATE" and unit and unit == self.unit then
			UpdatePower(self)
		elseif PlateCastingEvents[event] and unit and unit == self.unit then
			local _, spellID = ...
			UpdateSpells(self, event, spellID)
			UpdateInterruptSpells(self, event, spellID)
		end
	end)
end

local function OnNamePlateRemoved(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.jstuf
	
	-- 隐藏高亮
	HidePlateGlowByUnit(nil, unitFrame.unit)
	
	unitFrame.unit = nil
	unitFrame.npcID = nil
	unitFrame.GUID = nil

	-- 隐藏残余图标
	for k, icon in pairs(unitFrame.icon_bg.ActiveIcons) do
		icon:Hide()
	end
	
	-- 隐藏残余材质
	for k, tex_frame in pairs(unitFrame.textures) do
		tex_frame:Hide()
	end
	
	unitFrame.plate_texture:Hide()
	unitFrame.plate_bgtex:Hide()
	unitFrame.plate_text:Hide()
	
	-- 状态刷新
	UpdateInterruptSpells(unitFrame, "INIT")
	UpdatePower(unitFrame)

	-- 取消事件，停止刷新
	unitFrame:UnregisterAllEvents()
	unitFrame:SetScript("OnEvent", nil)
end

local function InterruptFocusAlert(unitFrame, text, ...)
	local focus_GUID = UnitGUID("focus")
	if focus_GUID and focus_GUID == unitFrame.GUID then return end
	
	if C.DB["PlateAlertOption"]["interrupt_focus_textalert"] then
		T.Start_Text_Timer(NamePlateAlertTrigger.rt_alert_text, 3, text)
	end
	
	if C.DB["PlateAlertOption"]["interrupt_focus_soundalert"] then
		local icon = unitFrame.icon_bg.interrupticon
		local unit = unitFrame.unit
		local GUID = unitFrame.GUID
		
		if UnitCastingInfo(unit) then
			local notInterruptible, spellID = select(8, UnitCastingInfo(unit))
			if notInterruptible then
				T.PlaySound(...)
				last_focus_alert = GetTime()
			else
				local config_spellID = PlateAlertMultiSpellData[spellID] or spellID
				local info = T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", config_spellID})
				if info then
					AlertMyInterruptCasting(icon, unit, GUID)
				else	
					T.PlaySound(...)
					last_focus_alert = GetTime()
				end
			end
		elseif UnitChannelInfo(unit) then
			local notInterruptible, spellID = select(8, UnitChannelInfo(unit))
			if notInterruptible then
				T.PlaySound(...)
				last_focus_alert = GetTime()
			else
				local config_spellID = PlateAlertMultiSpellData[spellID] or spellID
				local info = T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", config_spellID})
				if info then
					AlertMyInterruptCasting(icon, unit, GUID)
				else	
					T.PlaySound(...)
					last_focus_alert = GetTime()
				end
			end
		else
			T.PlaySound(...)
			last_focus_alert = GetTime()
		end
	end
end

local function NamePlates_OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then -- 刷新所有姓名板状态
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			local unitFrame = namePlate.jstuf
			UpdateInterruptSpells(unitFrame, "INIT")
			UpdatePower(unitFrame)
			UpdateNPCHighlight(unitFrame)
			UpdateRaidTarget(unitFrame)
		end
	elseif event == "NAME_PLATE_CREATED" then -- 姓名板创建
		local namePlate = ...
		OnNamePlateCreated(namePlate)
	elseif event == "NAME_PLATE_UNIT_ADDED" then -- 姓名板单位添加
		local unit = ...
		OnNamePlateAdded(unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then -- 姓名板单位删除
		local unit = ...
		OnNamePlateRemoved(unit)
	elseif event == "UNIT_AURA" then -- 刷新来源光环图标		
		local unit, updateInfo = ...
		if unit == "player" then
			UpdatePlateAuraSource(updateInfo)
		end
	elseif event == "RAID_TARGET_UPDATE" then -- 刷新团队标记和打断讯息
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			local unitFrame = namePlate.jstuf
			UpdateInterruptText(unitFrame)
			UpdateRaidTarget(unitFrame)
			
			if unitFrame.unit and unitFrame.npcID then
				local index = GetRaidTargetIndex(unitFrame.unit)
				if Foucus_RaidTarget[unitFrame.npcID] and Foucus_RaidTarget[unitFrame.npcID][index] then
					if index == 9 then
						InterruptFocusAlert(unitFrame, L["设置焦点"], "setfocus")
					else
						InterruptFocusAlert(unitFrame, L["设置焦点"]..T.FormatRaidMark(index), "setfocus", "mark\\mark"..index)
					end
				end
			end
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			UpdateInterruptSpells(namePlate.jstuf, "INIT")
		end
		-- 发送打断聊天信息
		local _, instanceType = GetInstanceInfo()
		if not IsInGroup() or not C.DB["PlateAlertOption"]["interrupt_focus_msg"] or (instanceType ~= "party" and C.DB["PlateAlertOption"]["interrupt_focus_msg_dungeon"]) then
			return
		end
		if UnitExists("focus") then
			local GUID = UnitGUID("focus")
			local npcID = GUID and select(6, string.split("-", GUID))
			if npcID and auto_mark_npcs[npcID] then
				local rm = GetRaidTargetIndex("focus")
				local rm_str = rm and string.format("{rt%d}", rm) or ""
				local name = UnitName("focus")
				local msg = string.format(L["我打断%s"], rm_str..name)
				T.SendChatMsg(msg)
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then -- 刷新打断的轮次
		if PlateAlertFrames.PlateInterrupt then
			local _, sub_event, _, sourceGUID, _, _, sourceRaidFlags, destGUID, _, _, destRaidFlags, spellID, _, _, extraSpellID = CombatLogGetCurrentEventInfo()
			if sub_event == "SPELL_CAST_START" then
				local config_spellID = PlateAlertMultiSpellData[spellID] or spellID
				if config_spellID and T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", config_spellID}) then	
					local NpcID = select(6, string.split("-", sourceGUID))
					if Npc_InterruptNum[NpcID] then
						Interrupt_GUIDs[sourceGUID] = true
					end
				end
			elseif sub_event == "SPELL_INTERRUPT" then
				local config_spellID = PlateAlertMultiSpellData[extraSpellID] or extraSpellID
				if config_spellID and T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", config_spellID}) then
					local NpcID = select(6, string.split("-", destGUID))
					if Npc_InterruptNum[NpcID] and Interrupt_GUIDs[destGUID] then
						local rt = T.GetRaidFlagsMark(destRaidFlags)
						UpdateInterruptInd(destGUID, rt)
						Interrupt_GUIDs[destGUID] = nil
					end
				end
			elseif sub_event == "SPELL_CAST_SUCCESS" then
				local config_spellID = PlateAlertMultiSpellData[spellID] or spellID
				if config_spellID and T.ValueFromPath(PlateAlertFrames, {"PlateInterrupt", config_spellID}) then
					local NpcID = select(6, string.split("-", sourceGUID))
					if Npc_InterruptNum[NpcID] then
						local rt = T.GetRaidFlagsMark(sourceRaidFlags)
						UpdateInterruptInd(sourceGUID, rt)	
						Interrupt_GUIDs[sourceGUID] = nil
					end
				end
			end
		end
	elseif event == "ENCOUNTER_START" then -- 获取MRT打断讯息 格式：#打断xx-npcID-轮次-{rt1} (名字) (名字 名字)
		AssignedBackups = table.wipe(AssignedBackups)
		InterruptMrtData = table.wipe(InterruptMrtData)
		Foucus_RaidTarget = table.wipe(Foucus_RaidTarget)
		CantInterruptPlayerGUIDs = table.wipe(CantInterruptPlayerGUIDs)
		
		if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
			local text = _G.VExRT.Note.Text1
			for line in text:gmatch('#打断[^\r\n]+') do
				line = T.gsubMarks(line) -- 读取本地化标记文本
				
				local npcID, num = select(2, string.split("-",line))
				
				if npcID and Npc_InterruptNum[npcID] and num and tonumber(num) and tonumber(num) > 0 then
					-- 打断轮数
					local interrupt_count = tonumber(num)
					
					-- 团队标记
					local markstr, mark = line:match("{rt(%d)}")
					
					if markstr and tonumber(markstr) and tonumber(markstr) < 9 then
						mark = tonumber(markstr) -- 有标记
					else
						mark = 9 -- 无标记
					end
					
					-- 打断轮数数据整理
					if not InterruptMrtDataCount[npcID] then
						InterruptMrtDataCount[npcID] = {}
					end
					InterruptMrtDataCount[npcID][mark] = interrupt_count
					
					-- 打断人员数据整理
					if not InterruptMrtData[npcID] then
						InterruptMrtData[npcID] = {}
					end
					
					InterruptMrtData[npcID][mark] = {}
					
					local count = 0
					for players in line:gmatch("%(([^)]*)%)") do
						if string.find(players, L["替补"]) then
							if not InterruptMrtData[npcID][mark]["backups"] then
								InterruptMrtData[npcID][mark]["backups"] = {}
							end
							local containsMe = T.InsertGUIDtoArray(players, InterruptMrtData[npcID][mark]["backups"])
							if containsMe then
								if not Foucus_RaidTarget[npcID] then
									Foucus_RaidTarget[npcID] = {}
								end
								Foucus_RaidTarget[npcID][mark] = true
							end
						else
							count = count + 1
							if not InterruptMrtData[npcID][mark][count] then
								InterruptMrtData[npcID][mark][count] = {}
							end
							local containsMe = T.InsertGUIDtoArray(players, InterruptMrtData[npcID][mark][count])
							if containsMe then
								if not Foucus_RaidTarget[npcID] then
									Foucus_RaidTarget[npcID] = {}
								end
								Foucus_RaidTarget[npcID][mark] = true
							end
						end
					end
				end	
			end
		end
	end
end

local plate_events = {
	["VARIABLES_LOADED"] = true,
	["NAME_PLATE_CREATED"] = true,
	["NAME_PLATE_UNIT_ADDED"] = true,
	["NAME_PLATE_UNIT_REMOVED"] = true,
	["COMBAT_LOG_EVENT_UNFILTERED"] = true,
	["UNIT_AURA"] = true,
	["ENCOUNTER_START"] = true,
	["RAID_TARGET_UPDATE"] = true,
	["PLAYER_FOCUS_CHANGED"] = true,
}

NamePlateAlertTrigger:SetScript("OnEvent", NamePlates_OnEvent)

T.RegisterEventAndCallbacks(NamePlateAlertTrigger, plate_events)

--------------------------------------------------------------------
local PlateAlertColor = {
	PlatePower = {1,1,0,1},
	PlateNpcID = {1,0,0,1},
	PlateAuras = {0,1,0,1},
	PlateStackAuras = {0,1,0,1},
	PlayerAuraSource = {1,0,0,1},
	PlateSpells = {0,1,1,1},
	PlateInterrupt = {1,0,0,1},
}

T.CreatePlateAlert = function(option_page, category, args)
	local frame_key
	if args.type == "PlatePower" or args.type == "PlateNpcID" then
		frame_key = args.mobID
	else
		frame_key = args.spellID
		if args.spellIDs then
			for _, spellID in pairs(args.spellIDs) do
				PlateAlertMultiSpellData[spellID] = args.spellID
			end
		end	
	end
	
	local path = {category, args.type, frame_key}
	local details = {}
	local detail_options = {}
	
	if args.type == "PlateInterrupt" then
		details.interrupt_sl = args.interrupt
		
		table.insert(detail_options, {key = "interrupt_sl", text = L["无MRT设置的循环次数"], default = args.interrupt, min = 1, max = 5, apply = function(value, alert, button)
			local enable = T.ValueFromDB(path)["enable"]
			local npcIDs = {string.split(",", args.mobID)}
			for i, npcID in pairs(npcIDs) do
				if not Npc[npcID] then
					Npc[npcID] = {}
				end
				if enable then
					Npc[npcID][args.spellID] = value
				else
					Npc[npcID][args.spellID] = nil
				end
				
				local num = 0
				for spellID, interrupt_num in pairs(Npc[npcID]) do
					num = num + interrupt_num
				end
				if num > 0 then
					Npc_InterruptNum[npcID] = num
				else
					Npc_InterruptNum[npcID] = nil
				end
			end
		end})
		
		table.insert(detail_options, {key = "copy_interrupt_btn", text = L["粘贴MRT模板"], mobID = args.mobID, spellID = args.spellID})
		
		if not option_page.engageTag or args.instance_alert then -- 杂兵
			local npcIDs = {string.split(",", args.mobID)}
			for i, npcID in pairs(npcIDs) do
				auto_mark_npcs[npcID] = true
			end
		end
	end
	
	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_PlateAlert_Options(option_page, category, path, args, detail_options)
	
	if not PlateAlertFrames[args.type] then
		PlateAlertFrames[args.type] = {}
	end
	
	if PlateAlertFrames[args.type][frame_key] then
		T.msg("PlateAlert", args.type, frame_key, "标签重复")
	end
	
	PlateAlertFrames[args.type][frame_key] = {
		hl = args.hl,
		hl_np = args.hl_np,
		aura_type = args.aura_type,
		color = {1,1,1,1},
	}
	
	if args.color then
		for k, v in pairs(args.color) do
			PlateAlertFrames[args.type][frame_key].color[k] = v
		end
	else
		for k, v in pairs(PlateAlertColor[args.type]) do
			PlateAlertFrames[args.type][frame_key].color[k] = v
		end
	end
	
	for i, info in pairs(detail_options) do
		if info.apply then
			local value = T.ValueFromDB(path)[info.key]
			info.apply(value)
		end
	end
end

-- 姓名板设置
T.EditPlateIcons = function(tag)
	if tag == "enable" or tag == "all" then
		if C.DB["GeneralOption"]["disable_all"] or C.DB["GeneralOption"]["disable_plate"] then
			for k, frame in pairs(PlateIconHolders) do frame:SetAlpha(0) end
		else
			for k, frame in pairs(PlateIconHolders) do frame:SetAlpha(1) end
		end
	end
	
	if tag == "icon_size" or tag == "all" then
		local size = C.DB["PlateAlertOption"]["size"]
		for k, frame in pairs(PlateIconHolders) do
			for _, icon in pairs{frame:GetChildren()} do
				if icon:IsObjectType("Frame") then
					icon:SetSize(size, size)				
				end
			end
			frame.LineUpIcons()
		end
	end
	
	if tag == "x" or tag == "y" or tag == "all" then
		local x, y = C.DB["PlateAlertOption"]["x"], C.DB["PlateAlertOption"]["y"]
		for k, frame in pairs(PlateIconHolders) do
			local unitFrame = frame:GetParent()
			local namePlate = unitFrame:GetParent()
			unitFrame:SetPoint("BOTTOM", namePlate, "TOP", 0, C.DB["PlateAlertOption"]["y"])	
			if frame.powericon then
				frame.powericon:SetPoint("LEFT", namePlate, "RIGHT", x, 0)
			end
		end
	end
	
	if tag == "interrupt" or tag == "all" then
		for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
			UpdateInterruptSpells(namePlate.jstuf, "INIT")
		end
	end
	
	if not NamePlateAlertTrigger.rt_alert_text then
		NamePlateAlertTrigger.rt_alert_text = T.CreateAlertTextShared("NameplateRadiTargetAlert", 1)
	end
end

----------------------------------------------------------
-----------------[[    自动打断标记    ]]-----------------
----------------------------------------------------------
local guidToMark = {}
local marksUsed = {}

local FIX_UNIT_DEATH_ENCOUNTER = false
local FIX_NOT_UNIT_DEATH_ENCOUNTER = false
local FIX_RANGE_LIMIT = false
local FIX_CN_GENERALS = false

local function GetAvailableMark()
	for i = 1, 8 do
		if C.DB["PlateAlertOption"]["interrupt_auto_marks"][i] and not marksUsed[i] then
			return i
		end
	end
	return 0
end

local function placeOnTargetOrMouseover(unit)
	if C.DB["PlateAlertOption"]["interrupt_auto_mark_leader"] and not UnitLeadsAnyGroup("player") then
		return
	end
	
	local GUID = UnitGUID(unit)
	if GUID and not guidToMark[GUID] then
		local npcID = select(6, string.split("-", GUID))
		if (npcID and auto_mark_npcs[npcID]) then
			if FIX_RANGE_LIMIT and not UnitInRange(unit) then
				return
			end			
			local mark = GetAvailableMark()
			if mark > 0 then
				guidToMark[GUID] = mark
				if GetRaidTargetIndex(unit) ~= mark then 
					T.SetRaidTarget(unit, mark)
					if C.DB["PlateAlertOption"]["interrupt_auto_mark_msg"] then
						T.msg(string.format(L["已标记%s"], L["打断标记"], UnitName(unit), T.FormatRaidMark(mark)))
					end
				end
				marksUsed[mark] = true
				if FIX_UNIT_DEATH_ENCOUNTER then
					C_Timer.After(20,function()
						marksUsed[mark] = nil
					end)
				end
			end
		end
	end
end

local RM_Updater = CreateFrame("Frame")

RM_Updater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_TARGET" then
		local unit = ...
		if T.FilterGroupUnit(unit) then
			local target_unit = T.GetTarget(unit)
			if target_unit and not UnitIsDeadOrGhost(target_unit) then
				placeOnTargetOrMouseover(target_unit)
			end
		end
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		placeOnTargetOrMouseover("mouseover")
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		placeOnTargetOrMouseover(unit)
	elseif event == "ENCOUNTER_ENGAGE_UNIT" then
		local unit = ...
		placeOnTargetOrMouseover(unit)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, destFlags = CombatLogGetCurrentEventInfo()
		if sub_event == "UNIT_DIED" and destFlags and destFlags > 0 then
			local rm = T.GetRaidFlagsMark(destFlags)
			if rm and not FIX_NOT_UNIT_DEATH_ENCOUNTER then
				marksUsed[rm] = nil
			end
		end
	elseif event == "ENCOUNTER_START" then
		local encounterID = ...
		if encounterID == 2051 then
			FIX_UNIT_DEATH_ENCOUNTER = true
		elseif encounterID == 2008 then
			--FIX_UNIT_DEATH_ENCOUNTER = true
		elseif encounterID == 2269 then
			FIX_UNIT_DEATH_ENCOUNTER = true
		elseif encounterID == 2328 then
			FIX_NOT_UNIT_DEATH_ENCOUNTER = true
		elseif encounterID == 2417 then
			--FIX_RANGE_LIMIT = true	
		elseif encounterID == 2422 then
			FIX_UNIT_DEATH_ENCOUNTER = true
		end
	elseif event == "ENCOUNTER_END" then
		table.wipe(marksUsed)
		FIX_UNIT_DEATH_ENCOUNTER = false
		FIX_RANGE_LIMIT = false
	elseif event == "RAID_TARGET_UPDATE" then
		if GetRaidTargetIndex("player") == 8 then
			SetRaidTarget("player", 0)
			self:UnregisterEvent("RAID_TARGET_UPDATE")
			for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
				placeOnTargetOrMouseover(namePlate.namePlateUnitToken)
			end
		end
	end
end)

RM_Updater:RegisterEvent("ENCOUNTER_START")
RM_Updater:RegisterEvent("ENCOUNTER_END")

T.UpdateAutoMarkState = function()
	local events = {
		["UNIT_TARGET"] = true,
		["UPDATE_MOUSEOVER_UNIT"] = true,
		["NAME_PLATE_UNIT_ADDED"] = true,
		["ENCOUNTER_ENGAGE_UNIT"] = true,
		["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
	}
	
	if C.DB["PlateAlertOption"]["interrupt_auto_mark"] then
		T.RegisterEventAndCallbacks(RM_Updater, events)	
	else
		T.UnregisterEventAndCallbacks(RM_Updater, events)
	end
end

T.ResetMarks = function()
	if C.DB["PlateAlertOption"]["interrupt_auto_mark"] then
		RM_Updater:RegisterEvent('RAID_TARGET_UPDATE')
		for i = 1, 8 do
			SetRaidTarget("player", i) 
		end		
		table.wipe(marksUsed)
		table.wipe(guidToMark)
	end
end

----------------------------------------------------------
------------------[[    焦点快捷键    ]]------------------
----------------------------------------------------------
local JSTFocuserButton = CreateFrame("CheckButton", "JSTFocuserButton", UIParent, "SecureActionButtonTemplate") 
JSTFocuserButton:SetAttribute("type1", "macro") 
JSTFocuserButton:SetAttribute("macrotext", "/focus mouseover")
JSTFocuserButton:RegisterForClicks("LeftButtonUp", "LeftButtonDown")

JSTFocuserButton:RegisterEvent("PLAYER_REGEN_DISABLED")
JSTFocuserButton:RegisterEvent("PLAYER_REGEN_ENABLED")

JSTFocuserButton:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_ENABLED" then
		JSTinterruptScrollAnchor.focus_key_bind:Enable()
	elseif event == "PLAYER_REGEN_DISABLED" then
		JSTinterruptScrollAnchor.focus_key_bind:Disable()
	end
end)

T.UpdateFocusBindingClick = function()
	ClearOverrideBindings(JSTFocuserButton)
	if C.DB["PlateAlertOption"]["focus_key_bind"] then
		local modifier = C.DB["PlateAlertOption"]["focus_key_bind_modifier"] --- "shift" "alt" "ctrl"
		local mouseButton = "1" --- 1 = leftbutton, 2 = tightbutton, 3 = middle button(mouse wheel)
		SetOverrideBindingClick(JSTFocuserButton, true, modifier.."-BUTTON"..mouseButton, "JSTFocuserButton")
	end
end

T.RegisterInitCallback(T.UpdateFocusBindingClick)
----------------------------------------------------------
-------------------[[    声音提示    ]]-------------------
----------------------------------------------------------
local SoundFrames = {}
local PASoundTiggerFrames = {}
local SoundAlertMultiSpellData = {}

local MyDispelState = {}

-- 7 魔法 8 诅咒 9 中毒 10 诅咒 11 激怒 13 流血

local Dispel_Data = {
	PRIEST = {
		["HARMFUL"] = {
			[7] = {
				[527] = {spellID = 527}, -- 纯净术
				[32375] = {spellID = 32375}, -- 群体驱散
			},
			[10] = {
				[390632] = {spellID = 527}, -- 强化纯净术
				[213634] = {spellID = 213634}, -- 净化疾病
			},
		},
		["HELPFUL"] = {
			[7] = {
				[528] = {spellID = 528}, -- 驱散魔法
				[32375] = {spellID = 32375}, -- 群体驱散
			},
		},
	},
	DRUID = {
		["HARMFUL"] = {
			[7] = {
				[88423] = {spellID = 88423}, -- 自然之愈
			},
			[8] = {
				[392378] = {spellID = 88423}, -- 强化自然之愈
				[2782] = {spellID = 2782}, -- 清除腐蚀
			},
			[9] = {
				[392378] = {spellID = 88423}, -- 强化自然之愈
				[2782] = {spellID = 2782}, -- 清除腐蚀
			},
		},
		["HELPFUL"] = {
			[11] = {
				[2908] = {spellID = 2908}, -- 安抚
			},
		},
	},
	SHAMAN = { 
		["HARMFUL"] = {
			[7] = {
				[77130] = {spellID = 77130}, -- 净化灵魂
			},
			[8] = {
				[51886] = {spellID = 51886}, -- 净化灵魂
				[383016] = {spellID = 77130}, -- 强化净化灵魂
			},
			--[9] = {
			--	[383013] = {spellID = 383013}, -- 清毒图腾
			--},
		},
		["HELPFUL"] = {
			[7] = {
				[370] = {spellID = 370}, -- 净化术
				[378773] = {spellID = 378773}, -- 强效净化术
			},
		},
	},
	PALADIN = {
		["HARMFUL"] = {
			[7] = {
				[4987] = {spellID = 4987}, -- 清洁术
			},
			[9] = {
				[213644] = {spellID = 213644}, -- 清毒术
				[393024] = {spellID = 4987}, -- 强化清洁术
			},
			[10] = {
				[213644] = {spellID = 213644}, -- 清毒术
				[393024] = {spellID = 4987}, -- 强化清洁术
			},
		},
	},
	WARRIOR = { 
		-- 无
	},
	MAGE = { 
		["HARMFUL"] = {
			[8] = {
				[475] = {spellID = 475}, -- 解除诅咒
			},
		},
	},
	WARLOCK = { 
		["HARMFUL"] = {
			[7] = {
				[89808] = {spellID = 89808, isPet = true}, -- 烧灼驱魔(宠物)
			},
		},
	},
	HUNTER = { 
		["HELPFUL"] = {
			[7] = {
				[19801] = {spellID = 19801}, -- 宁神射击
			},
			[11] = {
				[19801] = {spellID = 19801}, -- 宁神射击
			},
		},
	},
	ROGUE = { 
		["HELPFUL"] = {
			--[11] = {
			--	[5938] = {spellID = 5938}, -- 毒刃
			--},
		},
	},
	DEATHKNIGHT = {
		-- 无
	},
	MONK = {
		["HARMFUL"] = {
			[7] = {
				[115450] = {spellID = 115450}, -- 清创生血（治疗）
			},
			[9] = {
				[218164] = {spellID = 218164}, -- 清创生血
				[388874] = {spellID = 115450}, -- 强化清创生血
			},
			[10] = {
				[218164] = {spellID = 218164}, -- 清创生血
				[388874] = {spellID = 115450}, -- 强化清创生血
			},
		},
	},
	DEMONHUNTER = {
		["HELPFUL"] = {
			[7] = {
				[278326] = {spellID = 278326}, -- 吞噬魔法
			},
		},
	},
	EVOKER = {
		["HARMFUL"] = {
			[7] = {
				[360823] = {spellID = 360823}, -- 自然平衡
			},
			[8] = {
				[374251] = {spellID = 374251}, -- 灼烧之焰
			},
			[9] = {
				[365585] = {spellID = 365585}, -- 净除
				[374251] = {spellID = 374251}, -- 灼烧之焰
			},
			[10] = {
				[374251] = {spellID = 374251}, -- 灼烧之焰
			},
			[13] = {
				[374251] = {spellID = 374251}, -- 灼烧之焰
			},
		},
		["HELPFUL"] = {
			--[11] = {
			--	[374346] = {spellID = 406971}, -- 震魂摄魄
			--},
		},
	},
}

local function UpdateMyDispelState()	
	MyDispelState = table.wipe(MyDispelState)
	
	for aura_type, info in pairs(Dispel_Data[G.myClass]) do
		if not MyDispelState[aura_type] then
			MyDispelState[aura_type] = {}
		end
		
		for tag, spellIDs in pairs(info) do
		
			if not MyDispelState[aura_type][tag] then
				MyDispelState[aura_type][tag] = {}
			end
			
			for spellID, info in pairs(spellIDs) do
				if not info.isPet then
					if IsPlayerSpell(spellID) then			
						MyDispelState[aura_type][tag][spellID] = info
					end
				else
					if C_SpellBook.IsSpellKnown(spellID, 1) then
						MyDispelState[aura_type][tag][spellID] = info
					end
				end
			end
		end
	end
end

G.PASoundTiggerFrames = PASoundTiggerFrames

local SoundTrigger = CreateFrame("Frame", addon_name.."SoundTrigger", FrameHolder)
SoundTrigger.last_dispel_played = 0

local function IsDispelUsable(aura_type, dispel_type)
	if GetTime() - SoundTrigger.last_dispel_played < 5 then return end	
	local spells = MyDispelState[aura_type] and MyDispelState[aura_type][dispel_type]
	if spells then
		for spellID, info in pairs(spells) do
			if T.MySpellCheck(info.spellID, info.isPet) then
				return true
			end
		end
	end
end

SoundTrigger:SetScript("OnEvent", function(self, event, ...)	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
		if G.sound_suffix[sub_event] then		
			if sub_event == "SPELL_AURA_APPLIED_DOSE" then-- 事件转换
				sub_event = "SPELL_AURA_APPLIED"
			end
			
			local sound_type = G.sound_suffix[sub_event][1]
			local config_spellID = SoundAlertMultiSpellData[spellID] or spellID
			local info = T.ValueFromPath(SoundFrames, {sound_type, config_spellID})
			if info and (not info.target_me or destGUID == G.PlayerGUID) then
				local enable = T.ValueFromDB({"Sound", sound_type, config_spellID, "enable"})
				if enable then
					if info.dispel_type then
						if IsDispelUsable(info.aura_type, info.dispel_type) then -- 我可以驱散
							if info.amount then
								if amount and amount >= info.amount then
									T.PlaySound(info.file)
									SoundTrigger.last_dispel_played = GetTime()
								end
							else
								T.PlaySound(info.file)
								SoundTrigger.last_dispel_played = GetTime()
							end
							--print("驱散提示音", spellID, C_Spell.GetSpellName(spellID))
						end
					else
						T.PlaySound(info.file)
					end
				end
			end
		end
	elseif event == "SPELLS_CHANGED" then
		UpdateMyDispelState()
	elseif event == "PLAYER_ENTERING_WORLD" then
		if select(2, GetInstanceInfo()) == "none" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end)

local EnablePrivateAuraSound = function(frame, spellID, sound)
	if not frame.auraSoundIDs[spellID] then	
		frame.auraSoundIDs[spellID] = C_UnitAuras.AddPrivateAuraAppliedSound({
			unitToken = "player",
			spellID = spellID,
			soundFileName = C.DB["GeneralOption"]["sound_file"]..sound..".ogg",
			outputChannel = C.DB["GeneralOption"]["sound_channel"],
		})
	end
end

local DisablePrivateAuraSound = function(frame)
	for spellID, auraSoundID in pairs(frame.auraSoundIDs) do
		C_UnitAuras.RemovePrivateAuraAppliedSound(auraSoundID)
		frame.auraSoundIDs[spellID] = nil
	end
end

local CreatePrivateAuraSound = function(spellID, sound, MultiSpellIDs)
	local frame = CreateFrame("Frame", nil, SoundTrigger)
	frame.auraSoundIDs = {}
	
	function frame:update_onedit()
		local enable = T.ValueFromDB({"Sound", "aura", spellID, "enable"})
		if enable and not C.DB["GeneralOption"]["disable_sound"] and not C.DB["GeneralOption"]["disable_all"] then
			EnablePrivateAuraSound(frame, spellID, sound)
			if MultiSpellIDs then
				for _, sub_spellID in pairs(MultiSpellIDs) do
					EnablePrivateAuraSound(frame, sub_spellID, sound)
				end
			end
		else
			DisablePrivateAuraSound(frame)
		end
	end
	
	PASoundTiggerFrames[spellID] = frame
end

T.EditSoundAlert = function(option)
	if option == "enable" or option == "all" then	
		if not C.DB["GeneralOption"]["disable_sound"] and not C.DB["GeneralOption"]["disable_all"] then
			SoundTrigger:RegisterEvent("PLAYER_ENTERING_WORLD")
			SoundTrigger:RegisterEvent("SPELLS_CHANGED")			
			if select(2, GetInstanceInfo()) ~= "none" then
				SoundTrigger:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			end
			UpdateMyDispelState()
		else
			SoundTrigger:UnregisterEvent("PLAYER_ENTERING_WORLD")
			SoundTrigger:UnregisterEvent("SPELLS_CHANGED")
			SoundTrigger:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		
		for spellID, frame in pairs(PASoundTiggerFrames) do
			frame:update_onedit()
		end
	end
end

T.CreateSoundAlert = function(option_page, category, args)
	local sound_type = G.sound_suffix[args.sub_event][1]
	local path = {category, sound_type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_Sound_Options(option_page, category, path, args)
	
	if not SoundFrames[sound_type] then
		SoundFrames[sound_type] = {}
	end
	
	if SoundFrames[sound_type][args.spellID] then
		T.msg("Sound", sound_type, args.spellID, "标签重复")
	end
	
	SoundFrames[sound_type][args.spellID] = {
		target_me = args.target_me,
		file = string.match(args.file, "%[(.+)%]"),
		amount = args.amount,
	}
	
	if args.ficon then
		local dispel_type

		for _, i in pairs({7, 8, 9, 10, 11, 13}) do
			local tag = tostring(i)
			if string.find(args.ficon, tag) then
				dispel_type = i
				break
			end
		end
		
		if dispel_type then
			SoundFrames[sound_type][args.spellID].dispel_type = dispel_type
			
			local aura_type
			
			if dispel_type == 11 then
				aura_type = "HELPFUL"
			elseif dispel_type == 7 then
				aura_type = args.aura_type or "HARMFUL"
			else
				aura_type = "HARMFUL"
			end
			
			SoundFrames[sound_type][args.spellID].aura_type = aura_type
		end
	end
	
	if args.private_aura then
		CreatePrivateAuraSound(args.spellID, string.match(args.file, "%[(.+)%]"), args.spellIDs)
	else
		if args.spellIDs then
			for _, spellID in pairs(args.spellIDs) do
				SoundAlertMultiSpellData[spellID] = args.spellID
			end
		end
	end
end

----------------------------------------------------------
-------------------[[    团队框架图标    ]]-----------------
----------------------------------------------------------
local RFIconFrames = {}
local RFIconMultiSpellIDs = {} -- 转换技能ID
local RFIconHolders = {}
local RFIcons = {}
local RFIndex = {}
local RFValue = {}
local RFGlowAuraIDs = {}
local RFWatchedWhispers = {}

local GetTextJustifyHbyPoint = function(anchor)
	if string.find(anchor, "LEFT") then
		return "LEFT"
	elseif string.find(anchor, "RIGHT") then
		return "RIGHT"
	else
		return "CENTER"
	end
end

local RFTrigger = CreateFrame("Frame", addon_name.."RFTrigger", FrameHolder)

-- 团队框架序号
local CreateRFIndex = function(GUID, index)
	if C.DB["GeneralOption"]["disable_all"] or C.DB["GeneralOption"]["disable_rf"] then return end
	
	local unit = T.GUIDToUnit(GUID)
	local parent = unit and T.GetUnitFrame(unit)
	
	if not parent then return end
	
	if not parent.RFIndex then
		local f = CreateFrame("Frame", nil, parent)
		f._parent = parent
		
		local size = C.DB["RFIconOption"]["RFIndex_size"]
		local anchor = C.DB["RFIconOption"]["RFIndex_anchor"]
		local x, y = C.DB["RFIconOption"]["RFIndex_x_offset"], C.DB["RFIconOption"]["RFIndex_y_offset"]
		local justifyh = GetTextJustifyHbyPoint(anchor)
		
		f:SetFrameStrata("FULLSCREEN")
		f:SetSize(size, size)
		f:SetPoint(anchor, parent, anchor, x, y)
		f:SetFrameLevel(parent:GetFrameLevel()+3)
		
		f.text = T.createtext(f, "OVERLAY", size, "OUTLINE", justifyh)
		f.text:SetPoint(justifyh, f, justifyh, 0, 0)
		f.text:SetShadowOffset(2, -2)
		f.text:SetTextColor(C.DB["RFIconOption"]["RFIndex_color"]["r"], C.DB["RFIconOption"]["RFIndex_color"]["g"], C.DB["RFIconOption"]["RFIndex_color"]["b"])
		
		function f:UpdateSize()			
			local size = C.DB["RFIconOption"]["RFIndex_size"]
			local anchor = C.DB["RFIconOption"]["RFIndex_anchor"]
			local x, y = C.DB["RFIconOption"]["RFIndex_x_offset"], C.DB["RFIconOption"]["RFIndex_y_offset"]
			local justifyh = GetTextJustifyHbyPoint(anchor)
			
			f:ClearAllPoints()			
			f:SetSize(size, size)
			f:SetPoint(anchor, f._parent, anchor, x, y)
			
			f.text:ClearAllPoints()
			f.text:SetPoint(justifyh, f, justifyh, 0, 0)
			
			f.text:SetFont(G.Font,size, "OUTLINE")
			f.text:SetJustifyH(justifyh)
			f.text:SetTextColor(C.DB["RFIconOption"]["RFIndex_color"]["r"], C.DB["RFIconOption"]["RFIndex_color"]["g"], C.DB["RFIconOption"]["RFIndex_color"]["b"])
		end
		
		table.insert(RFIndex, f)	
		parent.RFIndex = f		
	end
	
	parent.RFIndex:UpdateSize()
	parent.RFIndex.text:SetText(index)
	parent.RFIndex.ind = index
	parent.RFIndex.GUID = GUID
	parent.RFIndex:Show()
end
T.CreateRFIndex = CreateRFIndex

local HideRFIndexbyParent = function(parent)
	if parent.RFIndex then
		parent.RFIndex:Hide()
	end
end
T.HideRFIndexbyParent = HideRFIndexbyParent

local HideRFIndexbyGUID = function(GUID)
	for k, f in pairs(RFIndex) do
		if f.GUID == GUID  then
			f:Hide()
		end
	end
end
T.HideRFIndexbyGUID = HideRFIndexbyGUID

local HideRFIndexbyIndex = function(index)
	for k, f in pairs(RFIndex) do
		if f.ind == index then
			f:Hide()
		end
	end
end
T.HideRFIndexbyIndex = HideRFIndexbyIndex

local HideAllRFIndex = function()
	for k, f in pairs(RFIndex) do
		f:Hide()
	end
end
T.HideAllRFIndex = HideAllRFIndex

-- 团队框架数值
local CreateRFValue = function(parent, value)
	if C.DB["GeneralOption"]["disable_all"] or C.DB["GeneralOption"]["disable_rf"] then return end
	
	if not parent.RFValue then
		local f = CreateFrame("Frame", nil, parent)
		f._parent = parent
		
		local size = C.DB["RFIconOption"]["RFValue_size"]
		local anchor = C.DB["RFIconOption"]["RFValue_anchor"]
		local x, y = C.DB["RFIconOption"]["RFValue_x_offset"], C.DB["RFIconOption"]["RFValue_y_offset"]
		local justifyh = GetTextJustifyHbyPoint(anchor)
		
		f:SetFrameStrata("FULLSCREEN")
		f:SetSize(size, size)
		f:SetPoint(anchor, parent, anchor, x, y)
		f:SetFrameLevel(parent:GetFrameLevel()+3)
		
		f.text = T.createtext(f, "OVERLAY", size, "OUTLINE", justifyh)
		f.text:SetPoint(justifyh, f, justifyh, 0, 0)
		f.text:SetShadowOffset(1, -1)
		f.text:SetTextColor(C.DB["RFIconOption"]["RFValue_color"]["r"], C.DB["RFIconOption"]["RFValue_color"]["g"], C.DB["RFIconOption"]["RFValue_color"]["b"])
		
		function f:UpdateSize()
			local size = C.DB["RFIconOption"]["RFValue_size"]
			local anchor = C.DB["RFIconOption"]["RFValue_anchor"]
			local x, y = C.DB["RFIconOption"]["RFValue_x_offset"], C.DB["RFIconOption"]["RFValue_y_offset"]
			local justifyh = GetTextJustifyHbyPoint(anchor)
			
			f:ClearAllPoints()			
			f:SetSize(size, size)
			f:SetPoint(anchor, f._parent, anchor, x, y)
			
			f.text:ClearAllPoints()
			f.text:SetPoint(justifyh, f, justifyh, 0, 0)
			
			f.text:SetFont(G.Font,size, "OUTLINE")
			f.text:SetJustifyH(justifyh)
			f.text:SetTextColor(C.DB["RFIconOption"]["RFValue_color"]["r"], C.DB["RFIconOption"]["RFValue_color"]["g"], C.DB["RFIconOption"]["RFValue_color"]["b"])
		end
		
		table.insert(RFValue, f)	
		parent.RFValue = f		
	end
	
	parent.RFValue:UpdateSize()
	parent.RFValue.text:SetText(value)
	parent.RFValue:Show()
end
T.CreateRFValue = CreateRFValue

local HideRFValuebyParent = function(parent)
	if parent.RFValue then
		parent.RFValue:Hide()
	end
end
T.HideRFValuebyParent = HideRFValuebyParent

local HideAllRFValue = function()
	for k, f in pairs(RFValue) do
		f:Hide()
	end
end
T.HideAllRFValue = HideAllRFValue

-- 团队框架法术图标
local function CreateRFIcon(frame)
	local icon = CreateFrame("Frame", nil, frame)
	icon:SetSize(C.DB["RFIconOption"]["RFIcon_size"], C.DB["RFIconOption"]["RFIcon_size"])
	icon:SetFrameLevel(frame.parent:GetFrameLevel()+3)
	icon:Hide()
	icon.t = 0
	
	icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cd:SetAllPoints(icon)
	icon.cd:SetDrawBling(false)
	icon.cd:SetDrawEdge(false)
	icon.cd:SetHideCountdownNumbers(true)
	
	icon.texture = icon:CreateTexture(nil, "ARTWORK")
	icon.texture:SetTexCoord( .1, .9, .1, .9)
	icon.texture:SetAllPoints()
	
	function icon:SetUpdateCooldown(dur, expiration)
		icon.cd:SetCooldown(expiration-dur, dur)
		icon.exp = expiration
		icon:SetScript("OnUpdate", function(self, e)
			self.t = self.t + e
			if self.t > .05 then
				self.remain = self.exp - GetTime()
				if self.remain <= 0 then
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end
				self.t = 0
			end
		end)
		icon:Show()
	end
	
	icon:SetScript("OnShow", function()
		LCG.ButtonGlow_Start(icon)
		frame:lineup()
	end)
	
	icon:SetScript("OnHide", function()
		LCG.ButtonGlow_Stop(icon)
		frame:lineup()
	end)
	
	table.insert(frame.actives, icon)
	
	icon.holder = frame
	icon.last_update = 0
	
	return icon
end

local function CreateRFIconHolders(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("CENTER", parent, "CENTER")
	frame:SetSize(C.DB["RFIconOption"]["RFIcon_size"], C.DB["RFIconOption"]["RFIcon_size"])
	frame.parent = parent
	frame.actives = {}
	
	function frame:updatesize()
		local size = C.DB["RFIconOption"]["RFIcon_size"]
		frame:SetSize(size, size)
		for i, icon in pairs(frame.actives) do
			icon:SetSize(size, size)
		end
		frame:lineup()
	end
	
	function frame:lineup()
		table.sort(frame.actives, function(a, b)
			return a.last_update < b.last_update
		end)
		
		local x_offset = C.DB["RFIconOption"]["RFIcon_x_offset"]
		local y_offset = C.DB["RFIconOption"]["RFIcon_y_offset"]
		local index = 0
		
		for _, icon in pairs(frame.actives) do
			if icon:IsShown() then
				icon:ClearAllPoints()
				icon:SetPoint("LEFT", frame, "CENTER", -(C.DB["RFIconOption"]["RFIcon_size"]+2)*(index*2-1)/2+x_offset, y_offset) -- 根据图标数量定位第一个
				index = index + 1
			end
		end
	end
	
	function frame:get_icon(cast_GUID)
		for i, icon in pairs(self.actives) do
			if not icon.tag then
				icon.tag = cast_GUID
				RFIcons[icon.tag] = icon
				return icon
			end
		end
		
		local icon = CreateRFIcon(self)
		icon.tag = cast_GUID
		RFIcons[icon.tag] = icon
		return icon
	end	
		
	table.insert(RFIconHolders, frame)	
	
	parent.iconholder = frame
	
	return frame
end

local function UpdateRFIcon(cast_GUID, frame, spell_icon, startTimeMS, endTimeMS)
	local icon = frame:get_icon(cast_GUID)
	if GetTime() - icon.last_update > .5 then
		local dur = (endTimeMS - startTimeMS)/1000
		local expiration = endTimeMS/1000
		icon:SetUpdateCooldown(dur, expiration)	
		icon.texture:SetTexture(spell_icon)	
		icon.last_update = GetTime()
	end
end

local function CancelRFIcon(cast_GUID)
	local icon = cast_GUID and RFIcons[cast_GUID]
	if icon then
		RFIcons[icon.tag] = nil
		
		icon.cd:Clear()
		icon:SetScript("OnUpdate", nil)	
		icon:Hide()
		icon.tag = nil
	end
end

-- 团队框架高亮
local function ShowRFAuraGlow(frame, auraID, spellID, color, unit)
	if frame then
		local glow_type = C.DB["RFIconOption"]["glow_type"]
		local glow_key = string.format("RFAura:%s:%s", auraID, spellID)
		if glow_type == "proc" then
			local x_offset = C.DB["RFIconOption"]["x_offset"]
			local y_offset = C.DB["RFIconOption"]["y_offset"]
			LCG.ProcGlow_Start(frame, {key = glow_key, color = color, xOffset = x_offset, yOffset = y_offset})
			-- 触发高亮标签
			local glow_f = frame["_ProcGlow"..glow_key]
			if glow_f then
				glow_f.name = "_ProcGlow"..glow_key
			end
			if unit then
				local GUID = UnitGUID(unit)
				local name = T.ColorNickNameByGUID(GUID)
				--print("|cff00ff00+|r proc", name, spellID, "标签", glow_key)
			end
		else
			LCG.PixelGlow_Start(frame, color, 12, .25, nil, 3, 0, 0, true, glow_key)
			if unit then
				local GUID = UnitGUID(unit)
				local name = T.ColorNickNameByGUID(GUID)
				--print("|cff00ff00+|r pixel", name, spellID, "标签", glow_key)
			end
		end
	end
end
T.ShowRFAuraGlow = ShowRFAuraGlow

local function HideRFAuraGlow(frame, extra_match, unit)
	if frame then
		local glow_type = C.DB["RFIconOption"]["glow_type"]
		for key, glow_f in pairs(frame) do
			if string.find(key, "RFAura") and (not extra_match or string.find(key, extra_match)) then
				if glow_type == "proc" then
					LCG.ProcGlow_Stop(frame, gsub(key, "_ProcGlow", ""))
					if unit then
						local GUID = UnitGUID(unit)
						local name = T.ColorNickNameByGUID(GUID)
						--print("|cffff0000-|r proc", name, "标签", extra_match)
					end
				else
					LCG.PixelGlow_Stop(frame, gsub(key, "_PixelGlow", ""))
					if unit then
						local GUID = UnitGUID(unit)
						local name = T.ColorNickNameByGUID(GUID)
						--print("|cffff0000-|r pixel", name, "标签", extra_match)
					end
				end
			end
		end
	end
end
T.HideRFAuraGlow = HideRFAuraGlow

local function HideAllRFAuraGlow()
	local glow_type = C.DB["RFIconOption"]["glow_type"]
	if glow_type == "proc" then
		local current = LCG.GlowFramePool:GetNextActive()
		while current do
			if current.name and string.find(current.name, "RFAura") then
				LCG.GlowFramePool:Release(current)
			end
			current = LCG.GlowFramePool:GetNextActive(current)
		end
	else
		local current = LCG.ProcGlowPool:GetNextActive()
		while current do
			if current.name and string.find(current.name, "RFAura") then
				LCG.ProcGlowPool:Release(current)
			end
			current = LCG.ProcGlowPool:GetNextActive(current)
		end
	end
end
T.HideAllRFAuraGlow = HideAllRFAuraGlow

T.CreateSharedRFIcon = function(unit, tag, icon, start, exp_time)
	local frame = T.GetUnitFrame(unit)
	if frame then
		local iconholder = frame.iconholder or CreateRFIconHolders(frame)
		if tag and not RFIcons[tag] then
			UpdateRFIcon(tag, iconholder, icon, start, exp_time)
		end
	end								
end

RFTrigger:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_SPELLCAST_START" then
		local unit, cast_GUID, cast_spellID = ...
		if unit and cast_GUID and cast_spellID then
			local spellID = RFIconMultiSpellIDs[cast_spellID] or cast_spellID
			local info = T.ValueFromPath(RFIconFrames, {"Cast", spellID})
			if info then
				local enable = T.ValueFromDB({"RFIcon", "Cast", spellID, "enable"})
				if enable then
					C_Timer.After(.2, function()
						local target_unit = T.GetTarget(unit)
						if target_unit then
							local frame = T.GetUnitFrame(target_unit)
							if frame then
								local iconholder = frame.iconholder or CreateRFIconHolders(frame)
								local spell_icon, startTimeMS, endTimeMS, _, cast_GUID = select(3, UnitCastingInfo(unit))
								if cast_GUID and not RFIcons[cast_GUID] and spell_icon and startTimeMS and endTimeMS then
									UpdateRFIcon(cast_GUID, iconholder, spell_icon, startTimeMS, endTimeMS)
								end
							end
						end
					end)
				end
			end
		end
	elseif event == "UNIT_SPELLCAST_STOP" then
		local unit, cast_GUID, cast_spellID = ...
		if cast_GUID then
			CancelRFIcon(cast_GUID)
		end
	elseif event == "UNIT_TARGET" then
		local unit = ...
		if unit and UnitCastingInfo(unit) then
			local spell_icon, startTimeMS, endTimeMS, _, cast_GUID, _, cast_spellID = select(3, UnitCastingInfo(unit))
			if cast_GUID and spell_icon and startTimeMS and endTimeMS then
				local old_icon = RFIcons[cast_GUID]
				local target_unit = T.GetTarget(unit)
				if target_unit then
					local frame = T.GetUnitFrame(target_unit)
					if frame then
						if old_icon then
							if old_icon.holder.parent ~= frame then
								CancelRFIcon(cast_GUID)
								if frame then
									local iconholder = frame.iconholder or CreateRFIconHolders(frame)
									UpdateRFIcon(cast_GUID, iconholder, spell_icon, startTimeMS, endTimeMS)
								end
							end
						else
							local spellID = RFIconMultiSpellIDs[cast_spellID] or cast_spellID
							local info = T.ValueFromPath(RFIconFrames, {"Cast", spellID})
							if info then
								local enable = T.ValueFromDB({"RFIcon", "Cast", spellID, "enable"})
								if enable then
									if frame then
										local iconholder = frame.iconholder or CreateRFIconHolders(frame)
										UpdateRFIcon(cast_GUID, iconholder, spell_icon, startTimeMS, endTimeMS)
									end
								end
							end
						end
					end
				end
			end
		end
	elseif event == "UNIT_AURA" then
		local unit, updateInfo = ...
		
		if not unit or not T.FilterGroupUnit(unit) then return end
		
		if updateInfo == nil or updateInfo.isFullUpdate then
			local frame = T.GetUnitFrame(unit)
			
			if frame then
				HideRFAuraGlow(frame, nil, unit)
				
				for _, auraType in pairs({"HELPFUL", "HARMFUL"}) do
					AuraUtil.ForEachAura(unit, auraType, nil, function(aura_data)
						local spellID = RFIconMultiSpellIDs[aura_data.spellId] or aura_data.spellId
						local info = T.ValueFromPath(RFIconFrames, {"Aura", spellID})
						if info then							
							local enable = T.ValueFromDB({"RFIcon", "Aura", spellID, "enable"})
							if enable then
								local auraID = aura_data.auraInstanceID								
								RFGlowAuraIDs[auraID] = true
								
								if info.amount then
									if aura_data.applications and aura_data.applications >= info.amount then
										ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
									end
								else
									ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
								end
							end
						end
					end, true)
				end
			end
		else
			if updateInfo.addedAuras ~= nil then
				for _, aura_data in pairs(updateInfo.addedAuras) do
					local spellID = RFIconMultiSpellIDs[aura_data.spellId] or aura_data.spellId
					local info = T.ValueFromPath(RFIconFrames, {"Aura", spellID})
					if info then
						local enable = T.ValueFromDB({"RFIcon", "Aura", spellID, "enable"})
						if enable then							
							local frame = T.GetUnitFrame(unit) 
							if frame then
								local auraID = aura_data.auraInstanceID
								RFGlowAuraIDs[auraID] = true
								
								if info.amount then
									if aura_data.applications and aura_data.applications >= info.amount then
										ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
									end
								else
									ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
								end
							end
						end
					end
				end
			end
			if updateInfo.updatedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do
					if RFGlowAuraIDs[auraID] then
						local aura_data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
						if aura_data then
							local spellID = RFIconMultiSpellIDs[aura_data.spellId] or aura_data.spellId
							local info = T.ValueFromPath(RFIconFrames, {"Aura", spellID})
							if info then
								local enable = T.ValueFromDB({"RFIcon", "Aura", spellID, "enable"})
								if enable then
									local frame = T.GetUnitFrame(unit) 
									if frame then
										if info.amount then
											if aura_data.applications and aura_data.applications >= info.amount then										
												ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
											end
										end
									end
								end
							end
						else
							HideRFAuraGlow(T.GetUnitFrame(unit), auraID, unit)
							RFGlowAuraIDs[auraID] = nil
						end
					end
				end
			end
			if updateInfo.removedAuraInstanceIDs ~= nil then
				for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
					if RFGlowAuraIDs[auraID] then
						HideRFAuraGlow(T.GetUnitFrame(unit), auraID, unit)
						RFGlowAuraIDs[auraID] = nil
					end
				end
			end
		end
	elseif event == "ENCOUNTER_END" then
		for unit in T.IterateGroupMembers() do
			local frame = T.GetUnitFrame(unit)
			if frame then
				HideRFAuraGlow(frame, nil, unit)
				AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(aura_data)
					local spellID = RFIconMultiSpellIDs[aura_data.spellId] or aura_data.spellId
					local info = T.ValueFromPath(RFIconFrames, {"Aura", spellID})
					if info then							
						local enable = T.ValueFromDB({"RFIcon", "Aura", spellID, "enable"})
						if enable then
							local auraID = aura_data.auraInstanceID								
							RFGlowAuraIDs[auraID] = true
							
							if info.amount then
								if aura_data.applications and aura_data.applications >= info.amount then
									ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
								end
							else
								ShowRFAuraGlow(frame, auraID, spellID, info.color, unit)
							end
						end
					end
				end, true)
			end
		end
	elseif event == "UNIT_RAID_BOSS_WHISPER" then
		local unit, GUID, msg = ...
		if not RFIconFrames.Msg then return end
		for spellID, info in pairs(RFIconFrames.Msg) do
			if string.find(msg, info.msg) then
				local enable = T.ValueFromDB({"RFIcon", "Msg", spellID, "enable"})
				if enable then
					local unit_frame = T.GetUnitFrame(unit)
					if unit_frame then
						local iconholder = unit_frame.iconholder or CreateRFIconHolders(unit_frame)
						local tag = info.msg.."-"..GUID
						local spell_icon = C_Spell.GetSpellTexture(spellID)
						local startTimeMS = GetTime()*1000
						local endTimeMS = startTimeMS + RFIconFrames["Msg"][spellID]["dur"]*1000
						UpdateRFIcon(tag, iconholder, spell_icon, startTimeMS, endTimeMS)
					end
				end
				break
			end
		end
	end
end)

T.CreateRFIconAlert = function(option_page, category, args)
	local path = {category, args.type, args.spellID}
	T.InitSettings(path, args.enable_tag, args.ficon)
	T.Create_RFIcon_Options(option_page, category, path, args)
	
	if not RFIconFrames[args.type] then
		RFIconFrames[args.type] = {}
	end
	
	if RFIconFrames[args.type][args.spellID] then
		T.msg("RFIcon", args.type, args.spellID, "标签重复")
	end
	
	RFIconFrames[args.type][args.spellID] = {}
	
	if args.type == "Aura" then
		if not args.color then
			RFIconFrames[args.type][args.spellID].color = T.GetSpellColor(args.spellID)
		elseif args.color and type(args.color) == "table" then
			RFIconFrames[args.type][args.spellID].color = args.color
		elseif args.color and G.hl_colors[args.color] then
			RFIconFrames[args.type][args.spellID].color = G.hl_colors[args.color]
		else
			T.msg("RFIcon", args.type, args.spellID, "颜色错误")
			RFIconFrames[args.type][args.spellID].color = T.GetSpellColor(args.spellID)
		end
		
		RFIconFrames[args.type][args.spellID].amount = args.amount
	elseif args.type == "Msg" then
		RFIconFrames[args.type][args.spellID].msg = args.boss_msg
		RFIconFrames[args.type][args.spellID].dur = args.dur
	end
	
	if args.spellIDs then
		for _, spellID in pairs(args.spellIDs) do
			RFIconMultiSpellIDs[spellID] = args.spellID
		end
	end
end

RFTrigger.events = {
	["UNIT_SPELLCAST_START"] = true,
	["UNIT_SPELLCAST_STOP"] = true,
	["UNIT_TARGET"] = true,
	["UNIT_AURA"] = true,
	["ENCOUNTER_END"] = true,
	["UNIT_RAID_BOSS_WHISPER"] = true,
}

T.EditRFIconAlert = function(option)
	if option == "enable" or option == "all" then	
		if C.DB["GeneralOption"]["disable_all"] or C.DB["GeneralOption"]["disable_rf"] then
			T.UnregisterEventAndCallbacks(RFTrigger, RFTrigger.events)
			
			for tag, icon in pairs(RFIcons) do
				CancelRFIcon(tag)
			end
			
			HideAllRFAuraGlow()
			HideAllRFIndex()
		else
			T.RegisterEventAndCallbacks(RFTrigger, RFTrigger.events)
		end
	end
	
	if option == "icon_layout" or option == "all" then
		for i, frame in pairs(RFIconHolders) do
			frame:updatesize()
		end
	end
	
	if option == "index_layout" or option == "all" then
		for i, frame in pairs(RFIndex) do
			frame:UpdateSize()
		end
	end
	
	if option == "value_layout" or option == "all" then
		for i, frame in pairs(RFValue) do
			frame:UpdateSize()
		end
	end
end

----------------------------------------------------------
-------------------[[    首领模块    ]]-------------------
----------------------------------------------------------
G.BossModFrames = {}

local EditAlertBossMod = function(frame, path, option, detail_options)
	if option == "all" or option == "enable" then
		frame.enable = T.ValueFromDB(path)["enable"]
		
		for i, info in pairs(detail_options) do
			if info.apply and not string.find(info.key, "_blank") then
				local value = T.ValueFromDB(path)[info.key]
				info.apply(value, frame)
			end
		end
		
		if frame.enable then
			if frame.engageID then
				frame:RegisterEvent("ENCOUNTER_START")
				frame:RegisterEvent("ENCOUNTER_END")
			elseif frame.mapID then
				frame:RegisterEvent("PLAYER_ENTERING_WORLD")
			end
			T.RestoreDragFrame(frame)		
			if frame.sub_frames then
				for i, f in pairs(frame.sub_frames) do
					if f.enable then
						T.RestoreDragFrame(f)
					end
				end
			end
		else
			if frame.engageID then
				frame:UnregisterEvent("ENCOUNTER_START")
				frame:UnregisterEvent("ENCOUNTER_END")
			elseif frame.mapID then
				frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end
			T.ReleaseDragFrame(frame)
			if frame.sub_frames then
				for i, f in pairs(frame.sub_frames) do	
					T.ReleaseDragFrame(f)
				end
			end
		end

		frame:GetScript("OnEvent")(frame, "OPTION_EDIT")
	end
end

T.EditBossModsFrame = function(option)
	for k, frame in pairs(G.BossModFrames) do
		frame:update_onedit(option)
	end
end

T.CreateBossMod = function(option_page, category, args)	
	local path = {category, args.spellID}
	local frame = CreateFrame("Frame", addon_name.."_"..args.spellID.."_Mods", FrameHolder)
	
	if G.BossModFrames[args.spellID] then
		T.msg("BossMod", args.spellID, "标签重复")
	end
	
	G.BossModFrames[args.spellID] = frame
	
	local ENCID = option_page.ENCID
	
	frame.config_id = args.spellID
	frame.config_name = args.name
	frame.enable_tag = args.enable_tag
	frame.ficon = args.ficon
	frame.events = args.events
	frame.reset = args.reset
	frame.update = args.update
	frame.encounterID = ENCID
	
	if option_page.engageTag and not args.instance_alert then -- 首领战斗
		frame.npcID = G.Encounters[ENCID]["npc_id"]
		frame.engageID = G.Encounters[ENCID]["engage_id"]
	elseif string.find(ENCID, "c") or string.find(ENCID, "r") then
		frame.mapID = G.Encounters[ENCID]["map_id"]
	end
	
	-- 位置
	frame.movingtag = ENCID
	frame.movingname = option_page.movingTag..(args.name or string.format("%s %s", T.GetIconLink(args.spellID), L["首领模块"]))
	
	if args.points.hide then
		frame:SetPoint("CENTER", UIParent, "CENTER")	
	else
		frame.point = { a1 = args.points.a1, a2 = args.points.a2, x = args.points.x, y = args.points.y}
		if args.points.width and args.points.height then
			frame:SetSize(args.points.width, args.points.height)
		end
		T.CreateDragFrame(frame)	
	end
	
	frame.t = 0	
	frame:Hide()
	
	-- 初始化
	args.init(frame)
	
	local details = {}
	local detail_options = {}
	
	if args.custom then
		for i, t in pairs(args.custom) do -- 细节选项
			if not string.find(t.key, "_blank") then
				details[t.key] = t.default
			end
		end
		for i, info in pairs(args.custom) do
			table.insert(detail_options, info)
		end
	end

	for i, info in pairs(detail_options) do
		if info.key == "mrt_custom_btn" then
			info.text = L["粘贴MRT模板"]
			info.onclick = function(alert, button, self)
				T.DisplayCopyString(self, alert:copy_mrt(), L["复制粘贴"])
			end
		elseif info.key == "mrt_analysis_btn" then
			info.text = L["MRT战术板解析"]
			info.onclick = function(alert)
				alert:ReadNote(true)
			end
		elseif info.key == "option_list_btn" then
			info.onclick = function(alert, button, self)
				T.Toggle_opFrame(self, alert)
			end
		end
	end

	T.InitSettings(path, args.enable_tag, args.ficon, details)
	T.Create_BossMod_Options(option_page, category, path, args, detail_options)
	
	function frame:update_onedit(option) -- 载入配置
		EditAlertBossMod(self, path, option, detail_options)
	end

	function frame:init_update(event, ...)
		self:update(event, ...)
	end
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "OPTION_EDIT" or event == "PLAYER_ENTERING_WORLD" or event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
			CheckConditions(self, frame.events, args, event, ...) -- 显示框体、注册事件
		elseif self.events[event] then
			if self.enable then
				self.update(self, event, ...)
			end
		end
	end)
end
