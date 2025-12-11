local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["围墙"] = "围墙"
	L["开始挡线"] = "开始挡线"
elseif G.Client == "ruRU" then
	--L["围墙"] = "Wall"
	--L["开始挡线"] = "start soaking"
else
	L["围墙"] = "Wall"
	L["开始挡线"] = "start soaking"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2686] = {
	engage_id = 3131,
	npc_id = {"233815"},
	alerts = {
		{ -- 巢穴编织
			spells = {
				{1237272, "1,5"},--【巢穴编织】
				--{1238502, "0"},--【织造结界】
			},
			options = {
				{ -- 文字 巢穴编织 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["围墙"]..L["倒计时"],
					data = {
						spellID = 1237272,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
							self.next_count = 1
							self.difficultyID = select(3, ...)
							
							if self.difficultyID == 14 or self.difficultyID == 17 then
								T.Start_Text_DelayTimer(self, 44, L["围墙"], true)
							else
								T.Start_Text_DelayTimer(self, .5, L["围墙"], true)
							end
						elseif event == "ENCOUNTER_PHASE" then
							T.Stop_Text_Timer(self)
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1237272 then -- 巢穴编织
								self.next_count = self.next_count + 1
								
								local dur
								if self.difficultyID == 15 then
									dur = self.next_count % 2 == 1 and 41.5 or 43.5
								elseif self.difficultyID == 16 then
									dur = self.next_count % 2 == 1 and (self.next_count % 4 == 3 and 36.5 or 34.5)
								else
									dur = 85
								end
								
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["围墙"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 巢穴编织（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1237272,
					text = L["围墙"],
				},
				{ -- 图标 巢穴编织（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1237307,
					tip = L["定身"],
				},
				{ -- 团队框架高亮 巢穴编织（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1237307,
				},
				{ -- 首领模块 姓名板标记 织造结界（✓）
					category = "BossMod",
					spellID = 1238502,
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("245173")..T.GetIconLink(1238502)),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_AURA"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("check")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						frame.mobID = "245173"
						frame.auraID = 1238502
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							local GUID = UnitGUID(unit)
							local npcID = select(6, strsplit("-", GUID))
							if npcID == frame.mobID then
								if not AuraUtil.FindAuraBySpellID(frame.auraID, unit, "HELPFUL") then
									T.ShowNameplateExtraTex(unit, "check")
								else
									T.HideNameplateExtraTex(unit)
								end
							end
						elseif event == "UNIT_AURA" then
							local unit = ...
							if string.find(unit, "nameplate") then
								local unit = ...
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID == frame.mobID then
									if not AuraUtil.FindAuraBySpellID(frame.auraID, unit, "HELPFUL") then
										T.ShowNameplateExtraTex(unit, "check")
									else
										T.HideNameplateExtraTex(unit)
									end
								end
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
			},
		},		
		{ -- 注能晶塔
			spells = {
				{1247672, "12"},--【注能晶塔】
				--{1247029, "12"},--【超能新星】
				--{1247045, "12"},--【超能灌注】
			},
			options = {
				{ -- 图标 超能灌注（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1247045,
					tip = L["易伤"].."%s100%",
				},
				{ -- 首领模块 注能晶塔 队友状态监控（待测试）
					category = "BossMod",
					ficon = "12",
					spellID = 1247672,
					enable_tag = "spell",
					name = T.GetIconLink(1247672)..L["分配"]..string.format(L["使用标记%s"], T.FormatRaidMark("1,2,3,4")),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = 210, y = -40},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["CHAT_MSG_RAID_BOSS_WHISPER"] = true,
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 200,
							min = 150,
							max = 400,
							apply = function(value, alert)
								alert:SetWidth(value)
								for _, bar in pairs(alert.bars) do
									bar:SetWidth(value)
								end
								alert:line_up()
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 25,
							min = 16,
							max = 45,
							apply = function(value, alert)
								alert:SetHeight(value*2+4)
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)
								end
								alert:line_up()
							end
						},
						{
							key = "mrt_custom_btn", 
						},
						{
							key = "mrt_analysis_btn",
						},
					},
					init = function(frame)
						frame.bars = {}
						frame.sort_bars = {}
						frame.color = T.GetSpellColor(1247045)
						
						frame.assignments = {}
						frame.backups = {}
						frame.set = 0
						frame.PYLON_DURATION = 27 -- Time between the Pylons becoming visible (not active) and disappearing
						
						frame.text_frame_self_highstacks = T.CreateAlertTextShared("bossmod"..frame.config_id.."self_highstacks", 1)
						frame.text_frame_group_highstacks = T.CreateAlertTextShared("bossmod"..frame.config_id.."group_highstacks", 1)
						frame.text_frame_tether = T.CreateAlertTextShared("bossmod"..frame.config_id.."tether", 1)
						frame.text_frame_soak = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:line_up()
							self.sort_bars = table.wipe(self.sort_bars)
							
							for _, bar in pairs(self.bars) do
								table.insert(self.sort_bars, bar)
							end
							
							table.sort(self.sort_bars, function(a,b)
								if a.index < b.index then
									return true
								end
							end)
							
							for i, bar in pairs(self.sort_bars) do
								bar:ClearAllPoints()
								if i == 1 then
									bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
								else
									bar:SetPoint("TOPLEFT", self.sort_bars[i-1], "BOTTOMLEFT", 0, -4)
								end
							end
						end
						
						function frame:createbar(index, GUID)
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							local h = C.DB["BossMod"][self.config_id]["height_sl"]
							local w = C.DB["BossMod"][self.config_id]["width_sl"]
							
							local bar = T.CreateTimerBar(self, 1033914, true, false, false, w, h, {1,1,1})
							bar.glow:Hide()
							bar.glow:SetBackdropBorderColor(unpack(self.color))
							bar.index = index
							
							function bar:update(icon, color, text, status, value)
								bar.icon:SetTexture(icon)
								bar:SetStatusBarColor(unpack(color))
								
								if status == "time" then
									bar:SetMinMaxValues(0, 45)
									bar.exp_time = value
									bar:SetScript("OnUpdate", function(s, e)
										s.t = s.t + e
										if s.t > 0.05 then
											local remain = s.exp_time - GetTime()
											if remain > 43 then
												s.glow:Show()
											else
												s.glow:Hide()
											end
											
											if remain > 0 then
												s:SetValue(remain)
												bar.right:SetText(string.format("[%d]", text))
											else												
												s.right:SetText("|cff00ff00Ready|r")
												s:SetValue(0)
												s:SetScript("OnUpdate", nil)
											end
											s.t = 0
										end
									end)
								else
									bar:SetScript("OnUpdate", nil)
									bar:SetMinMaxValues(0, 1)
									bar:SetValue(value)
									bar.right:SetText(text)
									bar.glow:Hide()
								end
							end
							
							if GUID then
								bar.GUID = GUID
								bar.left:SetText(info.format_name)
								self.bars[GUID] = bar
							else
								bar.left:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
								self.bars[index] = bar
							end
						end
						
						function frame:SetStatus(GUID, status, stack, exp_time)
							local bar = self.bars[GUID]
							if bar then
								if status == "dead" then
									bar:update(132293, {.3, .3, .3}, "|cffff0000Dead|r", "value", 0)
								elseif status == "ready" then
									bar:update(1033914, self.color, "|cff00ff00Ready|r", "value", 0)
								elseif status == "tether" then
									bar:update(5764926, {.85, .85, .77}, L["连线"], "value", 1)
								elseif status == "debuff" then
									bar:update(1033914, self.color, stack, "time", exp_time)
								end
							end
						end
						
						function frame:UpdateUnitStatus(GUID)
							if self.bars[GUID] then
								local unit = T.GetGroupInfobyGUID(GUID).unit
								if UnitIsDeadOrGhost(unit) then
									self:SetStatus(GUID, "dead")
								elseif AuraUtil.FindAuraBySpellID(1226315, unit, "HARMFUL") then -- 注能束缚
									self:SetStatus(GUID, "tether")
								elseif AuraUtil.FindAuraBySpellID(1247045, unit, "HARMFUL") then -- 超能灌注
									local stack, _, dur, exp_time = select(3, AuraUtil.FindAuraBySpellID(1247045, unit, "HARMFUL"))
									self:SetStatus(GUID, "debuff", stack, exp_time)
								else
									self:SetStatus(GUID, "ready")
								end
							end
						end
						
						function frame:Assign(GUIDs, mark)
							if not tContains(GUIDs, G.PlayerGUID) then return end
							
							for i, GUID in pairs(GUIDs) do
								if T.GetGroupInfobyGUID(GUID) then
									self:createbar(i, GUID)
									self:UpdateUnitStatus(GUID)
								end
							end
							
							self:line_up()
							
							T.Start_Text_Timer(self.text_frame_soak, 8, L["挡线"]..T.FormatRaidMark(mark), true)
							T.PlaySound("mark\\mark"..mark)
						end
						
						function frame:EndAssign()
							for GUID, bar in pairs(self.bars) do
								bar:Hide()
								self.bars[GUID] = nil
							end
						end
						
						function frame:ReadNote(display)
							-- [1] = Players soaking the first set of pylons each phase
							-- [2] = Players soaking the second set of pylons each phase
							self.assignments = table.wipe(self.assignments)
							self.assignments[1] = {}
							self.assignments[2] = {}
							self.backups = table.wipe(self.backups)
							
							if display then
								T.divideline(self.config_name)
							end
							
							for lineCount, line in T.IterateNoteAssignment(self.config_id) do
								local GUIDs, _, mark = T.LineToGUIDArray(line)
								
								if next(GUIDs) then
									
									if lineCount <= 8 and mark then
										local setNumber = lineCount <= 4 and 1 or 2
										
										self.assignments[setNumber][mark] = GUIDs
										
										if display then
											local start_str = setNumber == 1 and L["奇数"] or L["偶数"]
											local str = T.GetColoredNameListByArray(GUIDs, start_str, mark)
											T.msg(str)
										end
									elseif lineCount == 9 then
										self.backups = GUIDs
										
										if display then
											local str = T.GetColoredNameListByArray(GUIDs, L["替补"])
											T.msg(str)
										end
									end
								end
							end
						end
						
						function frame:copy_mrt()
							local str = [[
								#%dstart%s
								{rt1} player player
								{rt2} player player
								{rt3} player player
								{rt4} player player
								
								{rt1} player player
								{rt2} player player
								{rt3} player player
								{rt4} player player
								
								player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(self.config_id))
						end
						
						function frame:PreviewShow()
							local preview_status = {"dead", "ready", "tether", "debuff"}
							for i = 1, 2 do
								local status = preview_status[random(4)]
								self:createbar(i, G.PlayerGUID)
								self:SetStatus(i, status, random(3), GetTime()+45)
							end
							self:line_up()
						end
						
						function frame:PreviewHide()
							for tag, bar in pairs(self.bars) do
								bar:Hide()
								self.bars[tag] = nil
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "CHAT_MSG_RAID_BOSS_WHISPER" then
							local text = ...
							if not text:match("spell:1246921") then return end
							
							frame.set = frame.set + 1
        
							if frame.set == 3 then
								frame.set = 1
							end
							
							local groups = CopyTable(frame.assignments[frame.set])
							local backups = CopyTable(frame.backups)
							
							for mark = 1, 8 do
								local GUIDs = groups[mark]
								
								if GUIDs then
									-- Count number of dead players in the group
									local deadCount = 0
									local str = ""
									
									for _, GUID in ipairs(GUIDs) do
										local info = T.GetGroupInfobyGUID(GUID)
										local unit = info.unit
										local isDead = UnitIsDeadOrGhost(unit)
										
										str = str.." "..info.format_name
										
										if isDead then
											deadCount = deadCount + 1
											str = str.."|cffff0000(X)|r"
										end
									end
									
									-- Replace dead people with backups
									for index, backupGUID in pairs(backups) do
										if deadCount > 0 then
											local info = T.GetGroupInfobyGUID(backupGUID)
											local unit = info.unit
											if not UnitIsDeadOrGhost(unit) then
												table.insert(GUIDs, backupGUID)
												table.remove(backups, index)
												str = str.." "..info.format_name
												deadCount = deadCount - 1
											end										
										end
									end
									
									frame:Assign(GUIDs, mark)
									T.msg(string.format("%s%s:%s", L["挡线"], T.FormatRaidMark(mark), str))
								end
							end
							
							C_Timer.After(frame.PYLON_DURATION, function()
								frame:EndAssign()
							end)
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_REMOVED") and spellID == 1247045 then -- 超能灌注
								frame:UpdateUnitStatus(destGUID)
							elseif sub_event == "SPELL_AURA_APPLIED_DOSE" and spellID == 1247045 then -- 超能灌注
								frame:UpdateUnitStatus(destGUID)
								if frame.bars[destGUID] and amount >= 9 then
									if destGUID == G.PlayerGUID then
										local str = string.format("%s%s |cffffc23a[%d]!|r", L["你的"], T.GetTextureStr(1033914), amount)
										T.Start_Text_Timer(frame.text_frame_self_highstacks, 2, str)
									else
										local str = string.format("%s%s |cffff0000[%d]!|r", T.ColorNickNameByGUID(destGUID), T.GetTextureStr(1033914), amount)
										T.Start_Text_Timer(frame.text_frame_group_highstacks, 2, str)
									end
								end
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1226315 then -- 注能束缚
								frame:UpdateUnitStatus(destGUID)
								if destGUID ~= G.PlayerGUID and T.ColorNickNameByGUID(destGUID) then
									T.Start_Text_Timer(frame.text_frame_tether, 2, T.ColorNickNameByGUID(destGUID).." "..T.GetTextureStr(5764926)..L["连线"])
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1226315 then -- 注能束缚
								frame:UpdateUnitStatus(destGUID)
							elseif sub_event == "UNIT_DIED" then
								frame:UpdateUnitStatus(destGUID)
							end
						elseif event == "ENCOUNTER_START" then
							frame.set = 0
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						for GUID, bar in pairs(frame.bars) do
							bar:Hide()
							bar:SetScript("OnUpdate", nil)
							frame.bars[GUID] = nil
						end
						frame:Hide()
						T.Stop_Text_Timer(frame.text_frame_self_highstacks)
						T.Stop_Text_Timer(frame.text_frame_group_highstacks)
						T.Stop_Text_Timer(frame.text_frame_tether)
						T.Stop_Text_Timer(frame.text_frame_soak)
					end,
				},
				{ -- 首领模块 注能晶塔 挡线时框架高亮（✓）
					category = "BossMod",
					ficon = "12",
					spellID = 1247045,
					name = T.GetIconLink(1247045)..L["团队框架高亮"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.GUIDs = {}
						frame.color = T.GetSpellColor(1247045)
						
						frame.updater = CreateFrame("Frame")
						frame.updater.t = 0
						
						function frame:StartCheck()
							if self.updater:GetScript("OnUpdate") then return end
	
							self.updater:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.1 then
									if T.GetTableNum(self.GUIDs) == 0 then
										s:SetScript("OnUpdate", nil)
									end
									for GUID, exp_time in pairs(self.GUIDs) do
										if exp_time - GetTime() < 0 then
											local unit = T.GetGroupInfobyGUID(GUID)["unit"]
											T.GlowRaidFramebyUnit_Hide("proc", "bm"..self.config_id, unit)
											self.GUIDs[GUID] = nil
										end
									end	
									s.t = 0
								end
							end)
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE") and spellID == 1247045 then -- 超能灌注
								if not frame.GUIDs[destGUID] then
									local info = T.GetGroupInfobyGUID(destGUID)
									if info then
										T.GlowRaidFramebyUnit_Show("proc", "bm"..frame.config_id, info.unit, frame.color)
									end
								end
								
								frame.GUIDs[destGUID] = GetTime() + 2
								frame:StartCheck()
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1247045 then -- 超能灌注
								if frame.GUIDs[destGUID] then
									frame.GUIDs[destGUID] = 0
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.GUIDs = table.wipe(frame.GUIDs)
						end
					end,
					reset = function(frame, event)
						frame.updater:SetScript("OnUpdate", nil)
						T.GlowRaidFrame_HideAll("proc", "bm"..frame.config_id)
					end,
				},
			},
		},
		{ -- 注能束缚
			spells = {
				{1226315, "5"},--【注能束缚】
				--{1226366, "5"},--【活体流丝】
				--{1226721},--【缠丝陷阱】
			},
			options = {
				{ -- 文字 注能束缚 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "2",
					preview = L["连线"]..L["倒计时"],
					data = {
						spellID = 1226311,
						events =  {
							["UNIT_AURA_ADD"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
							self.next_count = 1
							self.last_cast = 0	
							
							T.Start_Text_DelayTimer(self, 22, L["连线"], true)
						elseif event == "ENCOUNTER_PHASE" then
							T.Stop_Text_Timer(self)
							
						elseif event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == 1226311 and GetTime() - self.last_cast > 2 then
								self.last_cast = GetTime()
								self.next_count = self.next_count + 1
								
								local dur = self.next_count % 2 == 1 and 41 or 44
								T.Start_Text_DelayTimer(self, dur, L["连线"], true)
							end
						end
					end,
				},
				{ -- 图标 注能束缚（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1226311,
					tip = L["连线"],
					hl = "org",
					sound = "[defense]",
				},
				{ -- 文字 注能束缚（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["拉断连线"],
					data = {
						spellID = 1226315,
						events =  {
							["UNIT_AURA_ADD"] = true,
							["UNIT_AURA_REMOVED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if unit == "player" and spellID == self.data.spellID then
								self.text:SetText(L["拉断连线"])
								self:Show()
								T.PlaySound("break")
							end
						elseif event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if unit == "player" and spellID == self.data.spellID then
								self:Hide()
							end
						end
					end,
				},
				{ -- 自保技能提示 注能束缚（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1226311,
					threshold = 65,
				},
				{ -- 团队框架高亮 注能束缚（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1226311,
				},
				{ -- 首领模块 注能束缚 整体排序（✓）
					category = "BossMod",
					spellID = 1226366,
					enable_tag = "spell",
					name = string.format(L["NAME点名排序"], T.GetIconLink(1226311)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 65},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1226311
						frame.element_type = "bar"
						frame.color = T.GetSpellColor(1226311)
						frame.raid_index = true
						frame.disable_copy_mrt = true
						frame.support_spells = 10
						
						frame.info = {
							{text = "[1]", msg_applied = "1 %name", msg = "111", sound = "[1302\\pull1]"},
							{text = "[2]", msg_applied = "2 %name", msg = "222", sound = "[1302\\pull2]"},
							{text = "[3]", msg_applied = "3 %name", msg = "333", sound = "[1302\\pull3]"},
							{text = "[4]", msg_applied = "4 %name", msg = "444", sound = "[1302\\pull4]"},
						}
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
					end,
				},
				{ -- 图标 活体流丝（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1226366,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 缠丝陷阱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1226721,
					tip = L["昏迷"],
				},
			},
		},		
		{ -- 过量输能爆发
			spells = {
				{1226395, "4"},--【过量输能爆发】
			},
			options = {
				{ -- 文字 过量输能爆发 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["全团AE"].."+"..L["远离"]..L["倒计时"],
					data = {
						spellID = 1226395,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {
							["all"] = {
								[1] = {76.0, 85.0, 85.0, 85.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 1226395, L["全团AE"].."+"..L["远离"], self, event, ...)
					end,
				},
				{ -- 计时条 过量输能爆发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1226395,
					sound = "[aoe]cast",
					text = L["全团AE"].."+"..L["远离"],
					glow = true,
					group = 1,
				},
				{ -- 图标 过量输能爆发（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1226395,
					tip = L["DOT"],
				},
			},
		},
		{ -- 原始法术风暴
			spells = {
				{1226867},--【原始法术风暴】
			},
			options = {
				{ -- 文字 原始法术风暴 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					preview = T.GetIconLink(1226867)..L["引水"],
					data = {
						spellID = 1226867,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["JST_CUSTOM"] = true,
						},
						info = {14, 12, 15, 13, 15, 16, 14},
						sound = "bait",
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
							self.show_time = 4
							
							if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
								self.count_down_start = 4
								self.prepare_sound = "bait"
								self.count_down_english = true
							end
							
							self.next_count = 1
							
							C_Timer.After(14, function()
								T.FireEvent("JST_CUSTOM", "textalert1226867")
							end)
						elseif event == "ENCOUNTER_PHASE" then
							T.Stop_Text_Timer(self)
							
						elseif event == "JST_CUSTOM" then
							local tag = ...
							if tag == "textalert1226867" then
								self.next_count = self.next_count + 1
								
								local dur = self.data.info[self.next_count]
								
								if dur then
									C_Timer.After(dur, function()
										T.FireEvent("JST_CUSTOM", "textalert1226867")
									end)
									
									if T.GetCurrentPhase() == 1 then
										if self.next_count % 3 == 2 then
											T.Start_Text_DelayTimer(self, dur, L["引水"], true)
										end
									end
								end
							end
						end
					end,
				},
			},
		},
		{ -- 奥术满溢
			spells = {
				{1231408, "2"},--【奥术满溢】
			},
			options = {
				
			},
		},
		{ -- 贯体束丝
			spells = {
				{1227263, "0"},--【贯体束丝】
			},
			options = {
				{ -- 文字 贯体束丝 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 1227263,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then	
							self.round = true
							self.next_count = 1
							self.difficultyID = select(3, ...)
							
							local count = mod(self.next_count, 2) == 1 and "(1)" or "(2)"
							if self.difficultyID == 16 then
								T.Start_Text_DelayTimer(self, 12.7, L["射线"].." "..count, true)
							else
								T.Start_Text_DelayTimer(self, 9.5, L["射线"].." "..count, true)
							end
							
						elseif event == "ENCOUNTER_PHASE" then
							T.Stop_Text_Timer(self)
							
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1227263 then
								self.next_count = self.next_count + 1
								
								local count = mod(self.next_count, 2) == 1 and "(1)" or "(2)"
								local dur
								if self.next_count % 2 == 0 then
									dur = self.difficultyID == 16 and 4 or 7
								elseif self.next_count % 4 == 3 then
									dur = 39.5
								else
									dur = self.difficultyID == 16 and 36.5 or 33.5
								end
								
								T.Start_Text_DelayTimer(self, dur, L["射线"].." "..count, true)
							end
						end
					end,
				},
				{ -- 计时条 贯体束丝（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227263,
					show_tar = true,
					sound = soundfile("1227263cast", "cast"),
					text = L["射线"],
				},
				{ -- 嘲讽提示 贯体束丝（待测试）
					category = "BossMod",
					spellID = 1237212,
					ficon = "0",				
					name = L["嘲讽提示"]..T.GetIconLink(1237212),
					points = {hide = true},
					events = {					
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_THREAT_SITUATION_UPDATE"] = true,
					},
					init = function(frame)
						frame.aura_spellIDs = {
							[1237212] = 1, -- 贯体束丝
						}
						frame.cast_spellIDs = {
							[1227263] = true, -- 贯体束丝
						}
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
					end,
				},
				{ -- 换坦计时条 贯体束丝（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1237212,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
			},
		},
		{ -- 流丝冲击
			spells = {
				{1231403, "0"},--【流丝冲击】
			},
			options = {
				
			},
		},
		{ -- 无缚狂怒
			spells = {
				{1228059, "1"},--【无缚狂怒】
				--{1243771, "1"},--【奥能黏液】
			},
			options = {
				{ -- 图标 奥能黏液（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1243771,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 奥术暴怒
			spells = {
				{1227782},--【奥术暴怒】
			},
			options = {
				{ -- 文字 奥术暴怒 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["推人"]..L["倒计时"],
					data = {
						spellID = 1227782,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
							self.count_down_start = 5						
						elseif event == "ENCOUNTER_PHASE" then
							T.Start_Text_DelayTimer(self, 17.2, L["推人"], true)
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1227782 then
								T.Start_Text_DelayTimer(self, 20, L["推人"], true)
							end
						end
					end,
				},
				{ -- 计时条 奥术暴怒（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227782, -- 施法
					spellIDs = {1227784}, -- 引导
					sound = "[push]cast",
					text = L["推人"],
					glow = true,
					group = 1,
				},
				{ -- 自保技能提示 奥术暴怒（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 1227782,
					event = "SPELL_CAST_START",
					dur = 6,
					threshold = 65,
				},
			},
		},
		{ -- 蠕行波
			spells = {
				{1227226, "0"},--【蠕行波】
				--{1242303, "12"},--【蠕行缠裹】
			},
			options = {
				{ -- 文字 蠕行波 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["头前"]..L["倒计时"],
					data = {
						spellID = 1227226,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
						elseif event == "ENCOUNTER_PHASE" then							
							T.Start_Text_DelayTimer(self, 10, L["头前"], true)
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1227226 then
								T.Start_Text_DelayTimer(self, 20, L["头前"], true)
							end
						end
					end,
				},
				{ -- 计时条 蠕行波（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227226,
					text = L["头前"],
					glow = true,
					group = 1,
				},
				{ -- 嘲讽提示 蠕行波（待测试）
					category = "BossMod",
					spellID = 1227163,
					ficon = "0",			
					name = L["嘲讽提示"]..T.GetIconLink(1227163),
					points = {hide = true},
					events = {					
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_THREAT_SITUATION_UPDATE"] = true,
					},
					init = function(frame)
						frame.aura_spellIDs = {
							[1227163] = 1, -- 蠕行波
						}
						frame.cast_spellIDs = {
							[1227226] = true, -- 蠕行波
						}
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
					end,
				},
				{ -- 换坦计时条 蠕行波（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1227163,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
				{ -- 图标 蠕行波（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227163,
					tip = L["DOT"],
				},
				{ -- 首领模块 蠕行波 MRT轮次分配（✓）
					category = "BossMod", 
					spellID = 1227226,
					ficon = "3,12",
					enable_tag = "spell",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1227226)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -270},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "hp_perc_sl",
							text = L["血量阈值百分比"],
							default = 65,
							min = 20,
							max = 100,
						},
					},
					init = function(frame)
						frame.sub_event = "SPELL_CAST_START"
						frame.cast_id = 1227226
						
						frame.loop = true
						frame.assign_count = 2
						frame.alert_dur = 4
						frame.raid_glow = "pixel"
						
						function frame:override_action(count, display_count)
							T.PlaySound("sharedmg")
							T.Start_Text_Timer(self.text_frame, self.alert_dur, string.format("|cff00ff00%s|r", L["分担"]), true)
							
							T.AddPersonalSpellCheckTag("bossmod"..self.config_id, C.DB["BossMod"][self.config_id]["hp_perc_sl"], {"TANK"})
							C_Timer.After(self.alert_dur, function()
								T.RemovePersonalSpellCheckTag("bossmod"..self.config_id)
							end)
						end
						
						function frame:override_action_inactive(count, display_count)
							if UnitGroupRolesAssigned(unit) ~= "TANK" then
								T.PlaySound("dontsharedmg")
								T.Start_Text_Timer(self.text_frame, self.alert_dur, string.format("|cffff0000%s|r", L["不分担"]), true)
							end
						end
						
						function frame:AutoSplit()
							if not next(self.assignment) then
								self.assignment = table.wipe(self.assignment)
								self.assignment[1] = {}
								self.assignment[2] = {}
								
								local GUIDs = {}
								
								for unit in T.IterateGroupMembers() do
									local visible = UnitIsVisible(unit)
									local online = UnitIsConnected(unit)

									if visible and online and UnitGroupRolesAssigned(unit) ~= "TANK" then
										local GUID = UnitGUID(unit)
										table.insert(GUIDs, GUID)
									end
								end
								
								T.SortTable(GUIDs)
								
								for i, GUID in ipairs(GUIDs) do
									if i <= #GUIDs / 2 then
										table.insert(self.assignment[1], GUID)
									else
										table.insert(self.assignment[2], GUID)
									end
								end
							end
						end
						
						T.InitSpellBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateSpellBars(frame, event, ...)
						
						if event == "ENCOUNTER_START" then
							 frame:AutoSplit()
						end
					end,
					reset = function(frame, event)
						T.ResetSpellBars(frame)
					end,
				},
				{ -- 图标 蠕行缠裹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss",
					spellID = 1242303,
					tip = L["BOSS吸收"],
				},
			},
		},		
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1228070, -- 无缚狂怒（✓）
					count = 1,
				},
			},
		},
	},
}