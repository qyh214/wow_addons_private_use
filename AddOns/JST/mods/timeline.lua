local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name
local FrameHolder = G.FrameHolder

local update_rate = .05
local tl_update_rate = .5

----------------------------------------------------------
-------------------[[    动态战术板    ]]-----------------
----------------------------------------------------------
Mrt_Class = {}
for classID = 1, GetNumClasses() do
	local className, class = GetClassInfo(classID)
	Mrt_Class[class] = className
end

Mrt_Roles = {
	HEALER = L["治疗"],
	DAMAGER = L["输出"],
	TANK = L["坦克"],
}

Mrt_Positions = {
	RANGED = L["远程"],
	MELEE = L["近战"],
}

local function FormatSec(remain)
	local str
	if remain < 0 then
		str = string.format("|cffC0C0C0------|r")
	elseif remain < 3 then
		str = string.format("|cffFF0000%.1f|r", remain)
	elseif remain < 5 then
		str = string.format("|cffFFD700%d|r", remain)
	elseif remain < 10 then 
		str = string.format("|cff00FF00%d|r", remain)
	else
		str = date("|cff40E0D0%M:%S|r", remain)
	end
	return str
end

local function TargetToGUID(word)
	local word = word:gsub("|c%x%x%x%x%x%x%x%x([^|]+)|r", "%1") -- 去掉颜色
	local GUID = T.GetGroupGUIDbyName(word)
	return string.format("{target:%s}", GUID or word)
end

local function UpdateMyInfo(frame, str)
    local my_str, my_script = "", ""	
	local org_str = str:gsub("%d+:%d+", "")

	org_str = org_str:gsub("@(%S+)", TargetToGUID) -- 剔除目标
	org_str = org_str:gsub("|c%x%x%x%x%x%x%x%x([^|]+)|r", " %1 ") -- 去掉颜色
	
	for word in org_str:gmatch("%S+") do
        if T.GetGroupGUIDbyName(word) then
			org_str = org_str:gsub(word, "|cffff0000%1|r") -- 名字	
		end
    end
	
	org_str = org_str:gsub(" ", "") -- 去掉空格
	
	local my_roleID = T.GetMyRole()
	local my_posID = T.GetMyPos()
    local my_class = string.format("{%s}", G.myClassLocal)
    local my_role = string.format("{%s}", Mrt_Roles[my_roleID])	
	local my_pos = string.format("{%s}", Mrt_Positions[my_posID])
    local all = string.format("{%s}", L["所有人"])	
	local party = string.format("{%s}", L["队伍"])
	
    org_str = gsub(org_str, my_class, "|cffffffffFS_CLASS|r") -- 添加职业
    org_str = gsub(org_str, my_role, "|cffffffffFS_ROLE|r") -- 添加职责
    org_str = gsub(org_str, my_pos, "|cffffffffFS_POS|r") -- 添加站位
	org_str = gsub(org_str, all, "|cffffffffFS_ALL|r") -- 添加所有人
    org_str = gsub(org_str, party, function(a) return string.format("|cffffffffPARTY_%d|r", a) end) -- 添加小队
	for _, tag in pairs(Mrt_Class) do
		org_str = gsub(org_str, string.format("{%s}", tag), "|cffffffffFS_OTHER|r") -- 添加其他职业
	end
	for _, tag in pairs(Mrt_Roles) do
		org_str = gsub(org_str, string.format("{%s}", tag), "|cffffffffFS_OTHER|r") -- 添加职责职业
	end
	for _, tag in pairs(Mrt_Positions) do
		org_str = gsub(org_str, string.format("{%s}", tag), "|cffffffffFS_OTHER|r") -- 添加站位职业
	end
	
    local info = {}
    local filtered_str = ""
    
    for name, str in org_str:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|r([^|]+)") do
        table.insert(info, {n = name, str = str})
    end
    
    for index, v in pairs(info) do
        if T.GetGroupGUIDbyName(v.n) == G.PlayerGUID then
            filtered_str = filtered_str..v.str
        elseif C.DB["GeneralOption"]["tl_filter_class"] and v.n == "FS_CLASS" then
            filtered_str = filtered_str..v.str
        elseif C.DB["GeneralOption"]["tl_filter_role"] and v.n == "FS_ROLE" then
            filtered_str = filtered_str..v.str
		elseif C.DB["GeneralOption"]["tl_filter_pos"] and v.n == "FS_POS" then
            filtered_str = filtered_str..v.str	
        elseif C.DB["GeneralOption"]["tl_filter_all"] and v.n == "FS_ALL" then
            filtered_str = filtered_str..v.str
		elseif C.DB["GeneralOption"]["tl_filter_party"] and string.find(v.n, "PARTY_") and UnitInRaid("player") then
			local sub_group = select(3, GetRaidRosterInfo(UnitInRaid("player")))
			if string.find(v.n, sub_group) then
				filtered_str = filtered_str..v.str
			end
        end
    end
	
    my_str = filtered_str
    my_str = my_str:gsub("{spell:(%d+)}", T.GetSpellIcon)
	my_str = my_str:gsub("{target:(%S+)}", function(a) return T.ColorNickNameByGUID(a) or a end)
	my_str = my_str:gsub("%[#([^%]]+)%]", "%1")
	
	my_script = filtered_str
    my_script = my_script:gsub("{spell:(%d+)}", function(a) return C_Spell.GetSpellName(tonumber(a)) end)
	my_script = my_script:gsub("{target:(%S+)}", function(a) return T.GetNameByGUID(a) or a end)

    frame.my_str = my_str
	frame.my_script = my_script
end

local function UpdateGlowTargets(frame, str)
	frame.targets = table.wipe(frame.targets)
	for word in str:gmatch("@(%S+)") do
        word = word:gsub("|c%x%x%x%x%x%x%x%x([^|]+)|r", "%1") -- 去掉颜色
		local GUID = T.GetGroupGUIDbyName(word)
		if GUID then
			table.insert(frame.targets, GUID)
		end
    end
end

local TTS_failed_type = {
	"无效的朗读引擎类型", -- 1
	"朗读引擎分配失败", -- 2
	"不支持", -- 3
	"超过最大字符数", -- 4
	"持续时间过短", -- 5
	"进入朗读等候队列", -- 6
	"SDK未初始化", -- 7
	"朗读等候队列满", -- 8
	"无需加入朗读队列", -- 9
	"未找到语音", -- 10
	"未找到发音人", -- 11
	"无效的参数", -- 12
	"内部错误", -- 13
}

local Timeline = CreateFrame("Frame", addon_name.."TLFrame", FrameHolder)
Timeline:SetSize(600,100)
Timeline:Hide()

Timeline.title = CreateFrame("Frame", nil, Timeline) 
Timeline.title:SetSize(100, 40)
Timeline.title:SetPoint("TOPLEFT", Timeline, "TOPLEFT", 0, 0)

Timeline.clock = T.createtext(Timeline.title, "OVERLAY", 20, "OUTLINE", "LEFT")
Timeline.clock:SetPoint("LEFT", Timeline.title, "LEFT", 5, 0)	

Timeline.movingname = L["动态战术板"]
Timeline.point = { a1 = "TOPLEFT", a2 = "TOPLEFT", x = 225, y = -20}
T.CreateDragFrame(Timeline)

G.Timeline = Timeline

local timeicon = "|T134376:12:12:0:0:64:64:4:60:4:60|t"
local tl_test

Timeline.t = 0
Timeline.tl_dur = 5 -- 到时间点后保留显示的时间
Timeline.start = 0 -- 战斗开始时间
Timeline.time_offset = 0 -- 校准时间偏移量
Timeline.assignment_cd = {} -- 当前战斗战术板条目
Timeline.phase_cd = {} -- 当前战斗战术板转阶段条目

Timeline.Lines = {} -- 条目
Timeline.ActiveLines = {} -- 活跃条目

Timeline.events = {
	["ENCOUNTER_START"] = true,
	["ENCOUNTER_END"] = true,
	["ENCOUNTER_PHASE"] = true,
	["TIMELINE_START"] = true,
	["TIMELINE_STOP"] = true,
	["TIMELINE_PASSED"] = true,
	["VOICE_CHAT_TTS_PLAYBACK_STARTED"] = true,
	["VOICE_CHAT_TTS_PLAYBACK_FINISHED"] = true,
	["VOICE_CHAT_TTS_PLAYBACK_FAILED"] = true,
	["VOICE_CHAT_TTS_SPEAK_TEXT_UPDATE"] = true,
}

T.EditTimeline = function(option)
	if option == "all" or option == "enable" then
		if C.DB["GeneralOption"]["tl"] then			
			T.RegisterEventAndCallbacks(Timeline, Timeline.events)
			T.RestoreDragFrame(Timeline)
		else
			T.UnregisterEventAndCallbacks(Timeline, Timeline.events)
			T.ReleaseDragFrame(Timeline)
			Timeline:Hide()
		end
	end
	
	if option == "all" or option == "enable" or option == "bar" then
		if not (C.DB["GeneralOption"]["tl"] and C.DB["GeneralOption"]["tl_bar"]) then
			for key, line in pairs(Timeline.Lines) do
				line.bar:Hide()
			end
		end
	end
	
	if option == "all" or option == "enable" or option == "text" then	
		if not (C.DB["GeneralOption"]["tl"] and C.DB["GeneralOption"]["tl_text"]) then
			for key, line in pairs(Timeline.Lines) do
				line.text_frame:Hide()
			end
		end
	end
	
	if option == "all" or option == "font_size" then
		Timeline.title:SetSize(10*C.DB["GeneralOption"]["tl_font_size"], C.DB["GeneralOption"]["tl_font_size"]+6)
		Timeline.clock:SetFont(G.Font, C.DB["GeneralOption"]["tl_font_size"], "OUTLINE")	
	end
	
	for k, line in pairs(Timeline.Lines) do
		line:update_onedit(option)
	end
end

local function Timeline_LineUpLines()
	local t = {}
	for i, line in pairs(Timeline.ActiveLines) do
		if line and line:IsVisible() then
			table.insert(t, line)
		end
	end
	if #t > 1 then
		table.sort(t, function(a, b) 
			if a.row_time < b.row_time then
				return true
			elseif a.row_time == b.row_time and a.ind < b.ind then
				return true
			end
		end)
	end
	local lastline
	for i, line in pairs(t) do
		line:ClearAllPoints()
		if line:IsVisible() then
			if not lastline then
				line:SetPoint("TOPLEFT", Timeline.title, "BOTTOMLEFT", 0, -5)
				lastline = line
			else
				line:SetPoint("TOPLEFT", lastline, "BOTTOMLEFT", 0, -5)
				lastline = line
			end
		end
	end
end

local function Timeline_QueueLine(frame)	
	frame:HookScript("OnShow", function(self)
		Timeline.ActiveLines[self.frame_key] = self
		Timeline_LineUpLines()
	end)
	
	frame:HookScript("OnHide", function(self)
		Timeline.ActiveLines[self.frame_key] = nil
		Timeline_LineUpLines()
	end)
end

local function Timeline_CreateLine(ind)
	local frame = CreateFrame("Frame", nil, Timeline)
	frame:SetSize(1000, C.DB["GeneralOption"]["tl_font_size"])
	frame:Hide()
	
	local fs = C.DB["GeneralOption"]["tl_font_size"] - 5
	
	frame.left = T.createtext(frame, "OVERLAY", fs, "OUTLINE", "LEFT")
	frame.left:SetPoint("LEFT", frame, "LEFT", 0, 0)
	frame.left:SetSize(60, fs)
	
	frame.right = T.createtext(frame, "OVERLAY", fs, "OUTLINE", "LEFT")
	frame.right:SetPoint("LEFT", frame.left, "RIGHT", 0, 0)
	frame.right:SetSize(940, fs)
	
	frame:HookScript("OnSizeChanged", function(self, width, height)
		self.left:SetFont(G.Font, height-5, "OUTLINE")
		self.right:SetFont(G.Font, height-5, "OUTLINE")
	end)
	
	frame.t = 0
	frame.ind = ind
	frame.frame_key = "timeline"..ind	
	frame.target_glow_enabled = true
	frame.script_play_enabled = true
	frame.sounds = {}
	frame.targets = {}
	
	frame.bar = T.CreateAlertBarShared(1, "timeline"..ind, 134376, "", {0, 1, .7})
	frame.text_frame = T.CreateAlertTextShared("timeline"..ind, 2)
	
	function frame:update_onedit(option)
		if option == "all" or option == "font_size" then
			self:SetHeight(C.DB["GeneralOption"]["tl_font_size"])
		end
	end
	
	function frame:reset()
		self:Hide()
		self:SetScript("OnUpdate", nil)
		
		self.bar:Hide()
		self.text_frame:Hide()
		
		self.target_glow_enabled = nil
		self.script_play_enabled = nil
	end	
	
	function frame:glow_target()
		if self.target_glow_enabled then
			if next(self.targets) then
				for _, GUID in pairs(self.targets) do
					local unit = T.GUIDToUnit(GUID)
					if unit then
						T.GlowRaidFramebyUnit_Show("proc", "timelinetarget", unit, {1, 1, 1}, 3)
					end
				end
			end
			self.target_glow_enabled = nil
		end
	end
	
	function frame:play_script()
		if self.script_play_enabled then
			self.sounds = table.wipe(self.sounds)
			
			for v in self.my_script:gmatch("%[#([^%]]+)%]") do -- 识别语音文件
				table.insert(self.sounds, v)
			end
			
			if #self.sounds > 0 then -- 用语音文件
				local ticker = C_Timer.NewTicker(0.5, function(s)
					s.ind = s.ind + 1
					T.PlaySound("custom\\"..self.sounds[s.ind]) 
				end, #self.sounds)
				ticker.ind = 0
			else
				T.SpeakText(self.my_script)
			end
			
			self.script_play_enabled = nil
		end
	end
	
	Timeline.Lines[frame.frame_key] = frame
	
	Timeline_QueueLine(frame)
end

local function Timeline_UpdateLine(frame, str, row_time, exp_time)
	frame.row_time = row_time
	frame.exp_time = exp_time
	
	frame.right:SetText(str:gsub("%d+:%d+", ""):gsub("{spell:(%d+)}", T.GetSpellIcon):gsub("%[#([^%]]+)%]", "%1"))
	
	UpdateMyInfo(frame, str)
	UpdateGlowTargets(frame, str)
	
	if frame.my_str ~= "" then
		frame.text_frame.text:SetText(frame.my_str)
		
		frame.bar.left:SetText(frame.my_str)
		frame.bar:SetMinMaxValues(0, C.DB["GeneralOption"]["tl_bar_dur"])
		frame.bar:SetValue(0)
		
		frame.target_glow_enabled = true
		frame.script_play_enabled = true
	end
	
	frame:SetScript("OnUpdate", function(self, e)
		self.t = self.t + e
		if self.t > update_rate then
			self.remain = self.exp_time - GetTime()
			if self.remain > 0 then
				self.event_remain = self.remain - Timeline.tl_dur
				self.left:SetText(FormatSec(self.event_remain))
				
				if self.my_str ~= "" then
					if self.event_remain > 0 then
						if C.DB["GeneralOption"]["tl_glowtarget"] and self.event_remain < 3 then
							self:glow_target()  -- 团队框架动画
						end
						
						if C.DB["GeneralOption"]["tl_sound"] and self.event_remain < C.DB["GeneralOption"]["tl_sound_dur"] then
							self:play_script() -- 声音提示
						end
						
						if C.DB["GeneralOption"]["tl_text"] and self.event_remain < C.DB["GeneralOption"]["tl_text_dur"] then
							if not self.text_frame:IsShown() then
								self.text_frame:Show() -- 文字提示
							end
							if C.DB["GeneralOption"]["tl_text_show_dur"] then
								self.text_frame.text:SetText(string.format("%s %.1f", self.my_str, self.event_remain))
							end
						end
						
						if C.DB["GeneralOption"]["tl_bar"] and self.event_remain < C.DB["GeneralOption"]["tl_bar_dur"] then
							if not self.bar:IsShown() then
								self.bar:Show() -- 计时条提示
							end
							self.bar.right:SetText(T.FormatTime(self.event_remain))
							self.bar:SetValue(C.DB["GeneralOption"]["tl_bar_dur"] - self.event_remain)
						end
					else
						if C.DB["GeneralOption"]["tl_text"] and self.text_frame:IsShown() then
							self.text_frame:Hide()
						end
						if C.DB["GeneralOption"]["tl_bar"] and self.bar:IsShown() then
							self.bar:Hide()
						end
					end
				end
			else
				self:reset()
			end
			self.t = 0
		end
	end)
	
	frame:Show()
end

local ToggleTimelineTest = function()
	if not tl_test then
		if Timeline.start == 0 then
			tl_test = true
			T.FireEvent("TIMELINE_START")		
			JSTtimelineScrollAnchor.tl_test:SetText(L["动态战术板测试"].." "..L["停止"])
			T.msg(L["动态战术板测试"].." "..L["开始"])
		else
			T.msg(L["战斗中无法开始测试"])
		end
	else
		tl_test = false
		T.FireEvent("TIMELINE_STOP")
		JSTtimelineScrollAnchor.tl_test:SetText(L["动态战术板测试"].." "..L["开始"])
		T.msg(L["动态战术板测试"].." "..L["停止"])
	end
end
T.ToggleTimelineTest = ToggleTimelineTest

local StopTimelineTest = function()
	Timeline.time_offset = 0
	Timeline.assignment_cd = table.wipe(Timeline.assignment_cd)
	Timeline.phase_cd = table.wipe(Timeline.phase_cd)
	
	if C.DB["GeneralOption"]["tl_glowtarget"] then -- 隐藏高亮
		T.GlowRaidFrame_HideAll("proc", "timelinetarget")
	end
	
	for _, line in pairs(Timeline.ActiveLines) do  
		line:reset()
	end

	tl_test = false
	JSTtimelineScrollAnchor.tl_test:SetText(L["动态战术板测试"].." "..L["开始"])
	T.msg(L["动态战术板测试"].." "..L["停止"])
end

Timeline:SetScript("OnUpdate", function(self, e)
	self.t = self.t + e
	if self.t > tl_update_rate then
		self.dur = GetTime() - self.start
		self.passed = floor(self.dur)
		self.fake_passed = floor(self.dur + self.time_offset) 
		if self.last ~= self.passed then	
			T.FireEvent("TIMELINE_PASSED", self.fake_passed)
			self.last = self.passed
		end
		
		if self.time_offset == 0 then
			self.clock:SetText(string.format("%s %s", timeicon, date("%M:%S", self.passed)))
		else
			self.clock:SetText(string.format("%s %s [%s %s]", timeicon, date("%M:%S", self.passed), L["运行时间"], date("%M:%S", self.fake_passed)))
		end
		
		if tl_test and GetTime() > self.test_exp then
			ToggleTimelineTest()
		end
		
		self.t = 0
	end
end)

local function GetPhaseInfo(str)
	local phase_str, reset_m_str, reset_s_str = string.match(str, "P(.+) (%d+):(%d+)")
	if not (phase_str and reset_m_str and reset_s_str) then return end
	
	local phase = tonumber(phase_str)
	local minute = tonumber(reset_m_str)
	local second = tonumber(reset_s_str)
	
	if phase and minute and second then
		local dur = 60*minute + second
		return phase, dur
	end
end

local function filterDiffculty(line, engageID, difficultyID)
	local ID = string.match(line, "JST(%d+)")
	if tonumber(ID) == engageID then
		local difficultyTag = string.match(line, "JST"..ID.."(%a)")
		if difficultyTag then
			if string.lower(difficultyTag) == "h" then
				return difficultyID == 15
			elseif string.lower(difficultyTag) == "m" then
				return difficultyID == 16
			else
				return true
			end
		else
			return true
		end
	end
end

Timeline:SetScript("OnEvent", function(self, event, ...)
	if event == "ENCOUNTER_START" or event == "TIMELINE_START" then		
		
		if event == "ENCOUNTER_START" and tl_test then
			StopTimelineTest()
		end

		self.test_dur = 10
		self.start = GetTime()
		self:Show()
		
        if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note then
			if C.DB["GeneralOption"]["tl_use_raid"] and _G.VExRT.Note.Text1 then
				local text = _G.VExRT.Note.Text1
				local betweenLine = false
				for line in text:gmatch('[^\r\n]+') do
					if line:match(L["战斗结束"]) then
						betweenLine = false
					end
					
					if betweenLine then                
						local str = line:gsub("||", "|")					
						if string.match(str, "P(.+) (%d+):(%d+)") then
							local phase, dur = GetPhaseInfo(str)
							if phase and dur then								
								if not self.phase_cd[phase] then
									self.phase_cd[phase] = {}
								end
								table.insert(self.phase_cd[phase], dur)
							end
						else
							local m, s = string.match(str, "(%d+):(%d+)")
							if m and s then
								local r = tonumber(m)*60+tonumber(s)
								local t = max(r - C.DB["GeneralOption"]["tl_advance"], 0)
								local exp_time = r + self.tl_dur
								local info = {
									cd_str = str,
									row_time = r,
									show_time = t,
									hide_time = exp_time,
								}
								table.insert(self.assignment_cd, info)
								self.test_dur = max(self.test_dur, exp_time)
							end
						end
					end
					
					if event == "TIMELINE_START" then
						if line:match(L["时间轴"]) then
							betweenLine = true
						end
					elseif event == "ENCOUNTER_START" then
						local engageID, _, difficultyID = ...
						if string.find(line, L["时间轴"]) and filterDiffculty(line, engageID, difficultyID) then	
							betweenLine = true
						end
					end
				end    
			end
			if C.DB["GeneralOption"]["tl_use_self"] and _G.VExRT.Note.SelfText then		
				local text = _G.VExRT.Note.SelfText
				local betweenLine = false
				local phase_cd_cache = {}
				
				for line in text:gmatch('[^\r\n]+') do
					if line:match(L["战斗结束"]) then
						betweenLine = false
					end
					
					if betweenLine then                
						local str = line:gsub("||", "|")
						if string.match(str, "P(.+) (%d+):(%d+)") then
							local phase, dur = GetPhaseInfo(str)
							if phase and dur then
								if not phase_cd_cache[phase] then
									phase_cd_cache[phase] = {}
								end
								table.insert(phase_cd_cache[phase], dur)		
							end
						else
							local m, s = string.match(str, "(%d+):(%d+)")
							if m and s then
								local r = tonumber(m)*60+tonumber(s)
								local t = max(r - C.DB["GeneralOption"]["tl_advance"], 0)
								local exp_time = r + self.tl_dur
								local info = {
									cd_str = str,
									row_time = r,
									show_time = t,
									hide_time = exp_time,
								}
								table.insert(self.assignment_cd, info)
								self.test_dur = max(self.test_dur, exp_time)
							end
						end
					end
					
					if event == "TIMELINE_START" then
						if line:match(L["时间轴"]) then
							betweenLine = true
						end
					elseif event == "ENCOUNTER_START" then
						local engageID, _, difficultyID = ...
						if string.find(line, L["时间轴"]) and filterDiffculty(line, engageID, difficultyID) then	
							betweenLine = true
						end
					end
				end
				-- 覆盖转阶段信息
				for phase, info in pairs(phase_cd_cache) do
					if not self.phase_cd[phase] then
						self.phase_cd[phase] = {}
					end
					for index, dur in pairs(phase_cd_cache[phase]) do
						self.phase_cd[phase][index] = dur
					end
				end
			end
		end
		
		self.test_exp = GetTime() + self.test_dur
    elseif event == "ENCOUNTER_END" or event == "TIMELINE_STOP" then
		self.start = 0
		self.time_offset = 0
		self.assignment_cd = table.wipe(self.assignment_cd)
		self.phase_cd = table.wipe(self.phase_cd)
		
		if C.DB["GeneralOption"]["tl_glowtarget"] then -- 隐藏高亮
			T.GlowRaidFrame_HideAll("proc", "timelinetarget")
		end
		
		for _, line in pairs(self.ActiveLines) do  
			line:reset()
		end
		
		self:Hide()
	elseif event == "TIMELINE_PASSED" then
		local fake_passed = ...
		for i, t in pairs (self.assignment_cd) do
			if t.show_time <= fake_passed and t.hide_time > fake_passed then
				if not Timeline.Lines["timeline"..i] then
					Timeline_CreateLine(i)
				end
				if not Timeline.Lines["timeline"..i]:IsShown() then
					Timeline_UpdateLine(Timeline.Lines["timeline"..i], t.cd_str, t.row_time, self.start + t.row_time + self.tl_dur - self.time_offset)
				end
			elseif Timeline.Lines["timeline"..i] and Timeline.Lines["timeline"..i]:IsShown() then
				Timeline.Lines["timeline"..i]:reset()
			end			
		end	
	elseif event == "ENCOUNTER_PHASE" then
		local phase, count = ...
		local to_time = self.phase_cd[phase] and self.phase_cd[phase][count]
		if to_time then			
			self.time_offset = to_time - (GetTime() - self.start)
		
			for _, frame in pairs(self.ActiveLines) do
				frame.exp_time = self.start + frame.row_time + self.tl_dur - self.time_offset
			end
		end
	elseif string.find(event, "VOICE_CHAT") then
		if event == "VOICE_CHAT_TTS_PLAYBACK_FAILED" or event == "VOICE_CHAT_TTS_SPEAK_TEXT_UPDATE" then
			local status, utteranceID = ...
			if TTS_failed_type[status] then
				T.msg(string.format(L["朗读失败"], TTS_failed_type[status]))
			end
		end
    end
end)

T.CopyTimeline = function()
	local button = JSTtimelineScrollAnchor.tl_copy
	local title = string.format(L["粘贴%sMRT模板"], L["时间轴"])
	
	local my_roleID = T.GetMyRole()
	local my_posID = T.GetMyPos()
	local my_name = G.PlayerName
	local my_nickname = T.GetNameByGUID(G.PlayerGUID)
    local my_class = string.format("{%s}", G.myClassLocal)
    local my_role = string.format("{%s}", Mrt_Roles[my_roleID])	
	local my_pos = string.format("{%s}", Mrt_Positions[my_posID])
    local all = string.format("{%s}", L["所有人"])	
	local party = string.format("{%s}", gsub(L["队伍"], "[\(](.+)[\)]", "1"))
	
	local testlines = {
		string.format("0:10 %s %s", my_name, "{spell:31884}"),
		string.format("0:15 %s %s@%s", my_nickname, "{spell:33206}", my_nickname),
		string.format("0:20 %s %s", my_class, L["注意自保"]),
		string.format("0:25 %s %s", my_role, L["注意治疗"]),
		string.format("0:30 %s %s", my_pos, L["分散"]),
		string.format("0:40 %s %s", all, L["引头前"]),
		string.format("0:50 %s %s", party, L["分散"]),
	}
	
	local str = string.format("%s\n\n%s\n%s\n%s", L["时间轴标题注意"], L["时间轴"], table.concat(testlines, "\n"), L["战斗结束"])
	
	T.DisplayCopyString(button, str, title)
end
