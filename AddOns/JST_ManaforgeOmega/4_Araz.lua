local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["单躲球"] = "单躲球"
	L["双躲球"] = "双躲球"
	L["三躲球"] = "三躲球"
	L["标注能量最高的目标"] = "为能量最高的%s显示姓名板标记"
	L["收集装置"] = "收集装置"
	L["血量及击杀倒计时"] = "%s的血量及击杀倒计时"
	L["目标血量低于多少时开始对比"] = "目标血量低于多少时开始对比（百分比）"
	L["血量领先"] = "血量领先 %d%%"
elseif G.Client == "ruRU" then
	--L["标注能量最高的目标"] = "Highest energy collector nameplate mark"
	--L["收集装置"] = "collector"
	--L["血量及击杀倒计时"] = "%s's hp bar and time limit indicator"
	--L["目标血量低于多少时开始对比"] = "Compare when target health is below (percentage)"
	--L["血量领先"] = "Gap: %d%%"
	--L["单躲球"] = "Single dodges"
	--L["双躲球"] = "Double dodges"
	--L["三躲球"] = "Triple dodges"
else
	L["标注能量最高的目标"] = "Highest energy collector nameplate mark"
	L["收集装置"] = "collector"
	L["血量及击杀倒计时"] = "%s's hp bar and time limit indicator"
	L["目标血量低于多少时开始对比"] = "Compare when target health is below (percentage)"
	L["血量领先"] = "Gap: %d%%"
	L["单躲球"] = "Single dodges"
	L["双躲球"] = "Double dodges"
	L["三躲球"] = "Triple dodges"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2687] = {
	engage_id = 3132,
	npc_id = {"233817"},
	alerts = {
		{ -- 唤动收集者
			spells = {
				{1231720, "5"},--【唤动收集者】
			},
			options = {
				{ -- 文字 召唤奥术收集者 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1231720)..L["倒计时"],
					data = {
						spellID = 1231720,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
					},					
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" then
								if spellID == 1231720 then
									self.count = self.count + 1
									if self.count < 3 then
										local str = self.count == 1 and L["单躲球"] or self.count == 2 and L["双躲球"] or L["三躲球"]
										T.Start_Text_Timer(self, 5, str, true)
									end
								elseif spellID == 1254321 then
									T.Start_Text_Timer(self, 4, L["三躲球"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.round = true
							self.count = 0
						end
					end,
				},
				{ -- 计时条 召唤奥术收集者（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1231720,
					spellIDs = {1254321},
					sound = soundfile("1231720cast", "cast"),
				},
			},
		},
		{ -- 星界收割
			spells = {
				{1228214, "5"},--【星界收割】
			},
			options = {				
				{ -- 文字 星界收割 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1228213)..L["倒计时"],
					data = {
						spellID = 1228213,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[1] = {20.0, 46.0, 8.0, 36.0, 8.0, 8.0},
								[1.1] = {34.7, 8.0, 8.0},
								[1.2] = {},
							},
							[16] = {
								[1] = {23.5, 46.0, 15.0, 29.5, 15.0, 15.0},
								[1.1] = {38.7, 15.0, 15.0},
								[1.2] = {},
							},
						},
						cd_args = {
							round = true,
							show_time = 3,
						},
					},					
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1228213, T.GetIconLink(1228213), self, event, ...)
					end,
				},
				{ -- 文字 星界收割出小怪 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 1233979,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},					
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1228213 then
								T.Start_Text_Timer(self, 7, L["召唤小怪"], true)
							end
						elseif event == "ENCOUNTER_START" then
							self.round = true
							self.count_down_start = 4
							self.prepare_sound = "add"
						end
					end,
				},
				{ -- 计时条 星界收割（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1228213,
					text = L["小怪"],
					dur = 7,
					tags = {3},
					sound = soundfile("1228213cast"),
				},
				{ -- 首领模块 星界收割 计时圆圈 （✓）
					category = "BossMod",
					spellID = 1228214,
					name = T.GetIconLink(1233979)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.figure = T.CreateRingCD(frame, {1, 1, 1})
						
						function frame:StartCD(cd_type, wait, preview)
							if cd_type == 3 then
								self.figure.color = {1, 0, 0}
								self.figure:begin(GetTime() + 7, 7, {
									{dur = 2, color = {0, 1, 0}},
								})
								if not preview then
									T.StartCountDown("bossmod"..self.config_id, GetTime()+4.7, 4, "prepare_gather", "in")
								end
							elseif cd_type == 2 then
								self.figure.color = {1, 0, 0}
								self.figure:begin(GetTime() + 7, 7, {
									{dur = 7 - wait, color = {0, 1, 0}},
								})
								if not preview then
									local voice_dur = wait - .3
									local count_down = min(4, floor(voice_dur))
									T.StartCountDown("bossmod"..self.config_id, GetTime()+voice_dur, count_down, "drop_gather", "in")
								end
							else
								self.figure.color = {0, 1, 0}
								self.figure:begin(GetTime() + 7, 7)
							end
						end
						
						function frame:PreviewShow()
							local cd_type = math.random(3)
							local wait = math.random(3, 5)
							self:StartCD(cd_type, wait, true)
						end
						
						function frame:PreviewHide()
							self.figure:stop()
						end
						
						function frame:ToggleText(value)
							self.figure.dur_text:SetShown(value)
						end
						
						T.GetFigureCustomData(frame)
					end,	
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1233979 then -- 星界收割
								local currentTime = GetTime()
								
								if currentTime - frame.last_cast > 3 then
									frame.count = frame.count + 1
								end
								
								frame.last_cast = currentTime
								
								if destGUID == G.PlayerGUID then
									if frame.count == 5 or frame.count == 9 then
										frame:StartCD(3)
									else
										local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(1228188) or C_UnitAuras.GetPlayerAuraBySpellID(1238874)
										if auraInfo then
											local expirationTime = auraInfo.expirationTime
											local remainingTime = expirationTime - currentTime
											frame:StartCD(2, remainingTime)
										else
											frame:StartCD(1)
										end
									end
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame.last_cast = 0
						end
					end,
					reset = function(frame, event)
						frame.figure:stop()
						T.StopCountDown("bossmod"..frame.config_id)
					end,
				},
				{ -- 自保技能提示 星界收割（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1233979,
					spellIDs = {1228214},
					threshold = 65,
				},
				{ -- 首领模块 星界收割 点名统计 整体排序 （✓）
					category = "BossMod",
					spellID = 1233979,
					enable_tag = "spell",
					name = string.format(L["NAME点名排序"], T.GetIconLink(1233979)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1233979
						frame.element_type = "bar"
						frame.color = T.GetSpellColor(1233979)
						frame.raid_index = true
						frame.disable_copy_mrt = true
						frame.support_spells = 10
						
						frame.info = {
							{text = "1"},
							{text = "2"},
							{text = "3"},
							{text = "4"},
						}
						
						function frame:post_remove(element, index, unit, GUID)
							if C.DB["BossMod"][frame.config_id]["raid_index_bool"] then			
								T.CreateRFIndex(GUID, index)
								C_Timer.After(4, function()
									T.HideRFIndexbyGUID(GUID)
								end)
							end
						end
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
					end,
				},
			},
		},
		{ -- 虚空裂缝
			spells = {
				{1248171, "12"},--【虚空裂缝】
			},
			options = {
				
			},
		},
		{ -- 奥术具象
			npcs = {
				{33122, "12"},--【奥术具象】
			},
			spells = {
				--{1242952},--【黑暗恩赐】
				--{1236207},--【星界涌动】
			},
			options = {	
				{ -- 姓名板光环 黑暗恩赐（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1242952,
				},
				{ -- 文字 黑暗恩赐 免疫提醒（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 0},
					preview = T.GetIconLink(1242952)..L["免疫"],
					data = {
						spellID = 1242952,
						events =  {
							["PLAYER_TARGET_CHANGED"] = true,
							["UNIT_AURA_ADD"] = true,
							["UNIT_AURA_REMOVED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.text:SetText(L["免疫"])
						elseif event == "PLAYER_TARGET_CHANGED" then
							if UnitExists("target") and AuraUtil.FindAuraBySpellID(1242952, "target", "HELPFUL") then
								self:Show()	
							else
								self:Hide()
							end
						elseif event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == 1242952 and UnitIsUnit(unit, "target") then
								self:Show()
							end
						elseif event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if spellID == 1242952 and UnitIsUnit(unit, "target") then
								self:Hide()
							end
						end
					end,
				},
				{ -- 首领模块 奥术具象 控制链（✓）
					category = "BossMod",
					spellID = 1236207,
					enable_tag = "spell",
					name = T.GetFomattedNameFromNpcID("242586")..L["控制链"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn",
						},
						{
							key = "mrt_analysis_btn",
						},
					},
					init = function(frame)
					
						function frame:copy_mrt()
							local str = T.GenerateGroupCCNote(self.config_id, self.config_name, 4, true)
							return str
						end
						
						function frame:ReadNote(display)
							T.ReadGroupCCNote(self.config_id, display, self.config_name)
							T.GroupSpellForceUpdate()
						end
						
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and (spellID == 1233979 or spellID == 1243873) then -- 星界收割/虚空收割
								local currentTime = GetTime()
								
								if currentTime - frame.last_cast > 3 then
									frame.count = frame.count + 1
									T.DisplayGroupCCFrame(frame.count)
									
									frame.timer = C_Timer.NewTimer(12, function()
										T.HideGroupCCFrame()
									end)
								end
								
								frame.last_cast = currentTime
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame.last_cast = 0
							
							frame:ReadNote()							
						end
					end,
					reset = function(frame, event)
						if frame.timer then
							frame.timer:Cancel()
						end
						T.HideGroupCCFrame()
					end,
				},
			},
		},		
		{ -- 首要序列
			spells = {
				{1237322},--【首要序列】
			},
			options = {
				
			},
		},
		{ -- 奥术虹吸
			spells = {
				{1228103},--【奥术虹吸】
			},
			options = {
				
			},
		},
		{ -- 奥术屏障
			spells = {
				{1231726},--【奥术屏障】
			},
			options = {
				
			},
		},
		{ -- 奥术抹消
			spells = {
				{1228218, "4"},--【奥术抹消】
			},
			options = {
				{ -- 文字 奥术抹消 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["分担"].."+"..L["大怪"]..L["倒计时"],
					data = {
						spellID = 1228216,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {31, 45},
								[1.1] = {46},
								[1.2] = {},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1228216, L["分担"].."+"..L["大怪"], self, event, ...)
					end,
				},
				{ -- 计时条 奥术抹消（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1228216,
					text = L["分担伤害"],
					show_tar = true,
				},				
				{ -- 首领模块 奥术抹消 MRT轮次分配（✓）
					category = "BossMod",
					spellID = 1228216,
					ficon = "3,12",
					enable_tag = "spell",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1228216)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -230},
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
						frame.cast_id = 1228216
						
						frame.loop = true
						frame.assign_count = 2
						frame.alert_dur = 6
						frame.raid_glow = "pixel"
						
						function frame:override_action(count, display_count)
							T.PlaySound("sharedmg")
							T.Start_Text_Timer(self.text_frame, 6, string.format("|cff00ff00%s|r", L["分担"]), true)
						
							T.AddPersonalSpellCheckTag("bossmod"..self.config_id, C.DB["BossMod"][self.config_id]["hp_perc_sl"], {"TANK"})
							C_Timer.After(self.alert_dur, function()
								T.RemovePersonalSpellCheckTag("bossmod"..self.config_id)
							end)
						end
						
						function frame:override_action_inactive(count, display_count)
							if UnitGroupRolesAssigned(unit) ~= "TANK" then
								T.PlaySound("dontsharedmg")
								T.Start_Text_Timer(self.text_frame, 6, string.format("|cffff0000%s|r", L["不分担"]), true)
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
								
								T.SortTable(GUIDs, true)
								
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
				{ -- 图标 奥术抹消（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1232775,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],
				},
				{ -- 首领模块 奥术抹消 团队框架吸收治疗数值（✓）
					category = "BossMod",
					spellID = 1232775,
					ficon = "2",
					name = L["团队框架吸收治疗数值"],
					points = {hide = true},
					events = {
						["UNIT_HEAL_ABSORB_AMOUNT_CHANGED"] = true,
					},
					init = function(frame)
						T.InitRFHealAbsorbValues(frame)			
					end,
					update = function(frame, event, ...)
						T.UpdateRFHealAbsorbValues(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRFHealAbsorbValues(frame)
					end,
				},
			},
		},
		{ -- 奥能回响
			npcs = {
				{32392},--【奥能回响】
			},
			spells = {
				--{1228454, "4"},--【能量印记】
				--{1238867},--【回音祈咒】
				--{1238874, "7"},--【回音风暴】
			},
			options = {
				{ -- 姓名板光环 能量印记（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1228454,
				},
				{ -- 奥能回响 血量及击杀倒计时 （✓）
					category = "BossMod",
					spellID = 1238867,
					name = string.format(L["血量及击杀倒计时"], T.GetFomattedNameFromNpcID("241923")),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["ENCOUNTER_ENGAGE_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.default_bar_width = frame.default_bar_width or 300
						T.GetSingleBarCustomData(frame)
						
						frame.bar = T.CreateTimerBar(frame, nil, false, false, true, nil, nil, {1, .8, 0})
						
						T.CreateTagsforBar(frame.bar, 1)					
						frame.bar.tag_indcators[1]:SetVertexColor(1, 0, 0)
						frame.bar.tag_indcators[1]:SetWidth(4)
						frame.bar:SetAllPoints(frame)
						
						frame.count = 0
						frame.mob_npcID = "241923"
						frame.time_limit = 40
						
						function frame:update_health(unit)
							local hp, hp_max = UnitHealth(unit), UnitHealthMax(unit)
							self.bar:SetMinMaxValues(0, hp_max)
							self.bar:SetValue(hp)
							self.bar.right:SetText(T.ShortValue(hp))
						end
						
						function frame:update_time()
							self.bar.exp_time = GetTime() + self.time_limit	
							self.bar.left:SetText("")
							self.bar.tag_indcators[1]:Show()
								
							self.bar:SetScript('OnUpdate', function(s, e)
								s.t = s.t + e
								if s.t > 0.05 then
									local remain = s.exp_time - GetTime()
									if remain > 0 then
										s.left:SetText(T.FormatTime(remain))
										s:pointtag(1, remain/self.time_limit)
									else
										s:Hide()
										s.tag_indcators[1]:Hide()
										s:SetScript("OnUpdate", nil)
									end
									s.t = 0
								end
							end)
							
							self.bar:Show()
						end
						
						function frame:stop_bar()
							self.bar:Hide()
							self.bar.tag_indcators[1]:Hide()
							self.bar:SetScript("OnUpdate", nil)
						end
						
						function frame:PreviewShow()
							self.bar:SetMinMaxValues(0, 1)
							self.bar:SetValue(1)
							self.bar.right:SetText(T.ShortValue(1000000))
							self:update_time()
						end
						
						function frame:PreviewHide()
							self:stop_bar()
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_ENGAGE_UNIT" then
							local unit, GUID = ...
							local npcID = select(6, strsplit("-", GUID))
							
							if npcID and npcID == frame.mob_npcID and GUID ~= frame.current_mob then
								frame.count = frame.count + 1
								if frame.count == 1 then
									frame.current_mob = GUID
									frame:update_time()
									frame:update_health(unit)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
							if sub_event == "UNIT_DIED" and destGUID == frame.current_mob then
								frame:stop_bar()
							end
						elseif event == "UNIT_HEALTH" then
							local unit = ...
							if string.find(unit, "boss") and frame.current_mob and UnitGUID(unit) == frame.current_mob then
								frame:update_health(unit)
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
						end
					end,
					reset = function(frame, event)
						frame.current_mob = nil
						frame:stop_bar()
					end,
				},
			},
		},
		{ -- 星界印记
			spells = {
				{1228219},--【星界印记】
			},
			options = {
				{ -- 嘲讽提示 奥术抹消（待测试）
					category = "BossMod",
					spellID = 1228219,
					ficon = "0",				
					name = L["嘲讽提示"]..T.GetIconLink(1228219),
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
							[1228219] = 1, -- 星界印记
						}
						frame.cast_spellIDs = {
							[1228216] = true, -- 奥术抹消
						}
						
						function frame:override_check_boss()
							local pass
							local phase = T.GetCurrentPhase()
							
							for unit in T.IterateBoss() do
								spellID = select(9, UnitCastingInfo(unit))
								if spellID and self.cast_spellIDs[spellID] then
									pass = true
									return
								end
							end

							if not pass and phase == 1 then
								return true
							end
						end
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
					end,
				},
				{ -- 换坦计时条 星界印记（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1228219,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
				{ -- 图标 星界印记（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1228219,
					text = L["不分担"],
				},
			},
		},
		{ -- 沉默风暴
			spells = {
				{1228188, "7"},--【沉默风暴】
			},
			options = {
				{ -- 文字 沉默风暴 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["跑圈"]..L["倒计时"],
					data = {
						spellID = 1228161,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {63.0, 44.0, 23.0},
								[1.1] = {68},
								[1.2] = {},
								[2] = {41.4, 21.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1228161, L["跑圈"], self, event, ...)
					end,
				},
				{ -- 计时条 沉默风暴（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1228161,
					text = L["跑圈"],
				},
				{ -- 文字 沉默风暴（✓）
					category = "TextAlert",
					type = "spell",
					color = {0, 1, 1},
					preview = L["保持移动"],
					data = {
						spellID = 1228188,
						spellIDs = {1228188, 1238874},
						events =  {
							["UNIT_AURA_ADD"] = true,
							["UNIT_AURA_REMOVED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if unit == "player" and (spellID == 1228188 or spellID == 1238874) then
								T.Start_Text_Timer(self, 6, L["保持移动"], true)
								T.PlaySound("keepmoving")
							end
						elseif event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if unit == "player" and (spellID == 1228188 or spellID == 1238874) then
								self:Hide()
							end
						elseif event == "ENCOUNTER_START" then
							
						end
					end,
				},
				{ -- 图标 沉默风暴/回音风暴（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1228168,
					spellIDs = {1238878},
					ficon = "7",
					text = L["平静"],
					hl = "blu",
				},
				{ -- 团队框架高亮 沉默风暴/回音风暴（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1228168,
					spellIDs = {1238878},
					color = "blu",
				},
				{ -- 驱散提示音 沉默风暴/回音风暴（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1228168,
					spellIDs = {1238878},
					file = "[dispel]",
					ficon = "7",
				},
			},
		},
		{ -- 非凡力量
			spells = {
				{1228502, "0"},--【非凡力量】
			},
			options = {
				{ -- 文字 非凡力量 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(1228502)..L["倒计时"],
					data = {
						spellID = 1228502,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {4.0, 22.0, 22.0, 22.0, 22.0},
								[1.1] = {19.2, 22.0, 22.0},
								[1.2] = {},
								[2] = {9.4, 22.0, 22.0, 22.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1228502, T.GetIconLink(1228502), self, event, ...)
					end,
				},
				{ -- 计时条 非凡力量（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1228502,
					ficon = "0",
					show_tar = true,
					sound = soundfile("1228502cast", "cast"),
				},
				{ -- 嘲讽提示 非凡力量（待测试）
					category = "BossMod",
					spellID = 1228506,
					ficon = "0",
					name = L["嘲讽提示"]..T.GetIconLink(1228506),
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
							[1228506] = 2, -- 非凡力量
						}
						frame.cast_spellIDs = {
							[1228502] = true, -- 非凡力量
						}
						
						function frame:override_check_boss()
							if T.GetCurrentPhase() == 2 then
								return true
							end
						end
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
					end,
				},
				{ -- 换坦计时条 非凡力量（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1228506,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
			},
		},
		{ -- 奥术驱除
			spells = {
				{1227631},--【奥术驱除】
			},
			options = {
				{ -- 文字 奥术驱除 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["击退"]..L["倒计时"],
					data = {
						spellID = 1227631,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {155},
								[1.1] = {80.5},
								[1.2] = {},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1227631, L["击退"], self, event, ...)
					end,
				},
				{ -- 计时条 奥术驱除（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227631,
					text = L["击退"],
					sound = "[knockback]cast",
				},
				{ -- 自保技能提示 奥术驱除（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 1227631,
					event = "SPELL_CAST_START",
					dur = 5,
					threshold = 65,
				},
			},
		},
		{ -- 黑暗终界
			spells = {
				{1248009},--【黑暗终界】
			},
			options = {
				{ -- 血量（✓）
					category = "TextAlert", 
					type = "hp",
					data = {
						npc_id = "233817",
						ranges = {
							{ ul = 20, ll = 15.1, tip = L["阶段转换"]..string.format(L["血量2"], 15)},
						},
					},
				},
				{ -- 计时条 黑暗终界（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1248009,
				},
			},
		},
		{ -- 星界灼烧
			spells = {
				{1240705},--【星界灼烧】
			},
			options = {
				{ -- 图标 星界灼烧（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1240705,
					tip = L["DOT"],
				},
			},
		},
		{ -- 不稳定激涌
			spells = {
				{1232409},--【不稳定激涌】
			},
			options = {
				
			},
		},
		{ -- 奥术收集装置
			npcs = {
				{33707},--【奥术收集装置】
			},
			options = {
				{ -- 首领模块 标记 奥术收集装置（✓）
					category = "BossMod",
					spellID = 1254321,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("240905"), T.FormatRaidMark("5,6,7")),
					points = {hide = true},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					init = function(frame)
						frame.start_mark = 5
						frame.end_mark = 7
						frame.mob_npcID = "240905"
						frame.ignore_combat = true
						frame.use_stored_mark = true
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateRaidTarget(frame, event, ...)
						
						if event == "ENCOUNTER_PHASE" then
							frame.marked = table.wipe(frame.marked)
						end
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				{ -- 首领模块 BOSS血量和能量 奥术收集装置（✓）
					category = "BossMod",
					spellID = 1248171,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量和能量"], T.GetFomattedNameFromNpcID("240905")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["UNIT_POWER_UPDATE"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["240905"] = { -- 奥术收集装置
								n = L["收集装置"],
								color = {.5, .5, .5},
								color2 = {1, 1, 0},
							},
						}
						
						T.InitMobUF(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobUF(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobUF(frame)
					end,
				},				
				{ -- 首领模块 奥术收集装置 标注能量最高的目标（✓）
					category = "BossMod",
					spellID = 1231720,
					ficon = "3",
					name = string.format(L["标注能量最高的目标"], T.GetFomattedNameFromNpcID("240905")),	
					points = {hide = true},
					events = {
						["UNIT_POWER_UPDATE"] = true,
					},
					init = function(frame)
						frame.mob_npcID = "240905"
						frame.old_target = 0
						
						function frame:GetHighestPowerUnit()
							local highestPower = 0
							local highestUnit
							local highestGUID
							
							for unit in T.IterateBoss() do
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								local power = UnitPower(unit)
								
								if npcID == self.mob_npcID and power > highestPower then -- 奥术收集装置
									highestPower = power
									highestUnit = unit
									highestGUID = GUID
								end
							end
							
							return highestGUID, highestUnit
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_POWER_UPDATE" then
							local unit = ...
							if string.find(unit, "boss") then
								local highestGUID, highestUnit = frame:GetHighestPowerUnit()
								if highestGUID then
									if frame.old_target ~= highestGUID then
										T.ShowNameplateExtraTex(highestUnit, "check", highestGUID)
										frame.old_target = highestGUID
									end
								else
									if frame.old_target ~= 0 then
										T.HideAllNameplateExtraTex()
										frame.old_target = 0
									end
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.old_target = 0
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
				{ -- 首领模块 奥术收集装置血量对比（✓）
					category = "BossMod",
					ficon = "12",
					spellID = 1226260,
					name = string.format("%s %s (%s)", T.GetFomattedNameFromNpcID("240905"), L["NAME血量对比"], L["姓名板标记"]),
					points = {hide = true},
					events = {
						["UNIT_HEALTH"] = true,
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("value")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						frame.mob_npcID = "240905"
						frame.GUIDs = {}
						frame.update_rate = .1
						frame.last_update = 0
						
						function frame:UpdateAverageHealth()
							local MobCount = 0
							local averageHealth = 0
							local averageHealthFraction, totalHealth
							
							for unit in T.IterateBoss() do
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								local isArcaneCollector = npcID == self.mob_npcID
								
								if isArcaneCollector then
									MobCount = MobCount + 1
									averageHealth = averageHealth + UnitHealth(unit)
									totalHealth = UnitHealthMax(unit)
								end
							end
							
							if MobCount == 0 then return true end
							
							averageHealth = averageHealth / MobCount
							averageHealthFraction = averageHealth / totalHealth
							
							for _, GUID in pairs(self.GUIDs) do
								local unit = T.GetBossUnitbyGUID(GUID)
								local jstuf = unit and T.GetNameplateFrame(unit, GUID)
								if jstuf and unit then
									local currentHealth = UnitHealth(unit)
									local differenceFromAverage = currentHealth - averageHealth
									local percentage = (differenceFromAverage / totalHealth) * 100
									
									if percentage and averageHealthFraction then
										local redValue = -10 * averageHealthFraction
										local colorPercentage = Clamp(percentage, redValue, 0)
										local fraction = colorPercentage / redValue
										local hueDifference = 0.33 * fraction
										local h = 0.33 - hueDifference
										local r, g, b = T.hsvToRgb(h, 0.9, 1)
										jstuf.plate_texture:SetVertexColor(r, g, b)
										jstuf.plate_text:SetText(string.format("%d%%", percentage))
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_HEALTH" then
							if GetTime() - frame.last_update > frame.update_rate then
								frame.last_update = GetTime()
								frame:UpdateAverageHealth()
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if not cast_GUID then return end
							if unit == "boss1" and cast_spellID == 1227631 then -- 奥术驱除
								for unit in T.IterateBoss() do
									local GUID = UnitGUID(unit)
									local npcID = select(6, strsplit("-", GUID))
									local isArcaneCollector = npcID == frame.mob_npcID
									
									if isArcaneCollector then
										table.insert(frame.GUIDs, GUID)
										T.ShowNameplateExtraTex(unit, "value")
									end
								end
							elseif unit == "boss1" and cast_spellID == 1230529 then -- 法力牺牲
								T.HideAllNameplateExtraTex()
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
						frame.GUIDs = table.wipe(frame.GUIDs)
					end,
				},
				{ -- 首领模块 奥术收集装置血量对比 文字提示（✓）
					category = "BossMod",
					spellID = 1228103,
					name = string.format("%s %s (%s)", T.GetFomattedNameFromNpcID("240905"), L["NAME血量对比"], L["文字提示"]),
					points = {hide = true},
					events = {
						["UNIT_HEALTH"] = true,
						["PLAYER_TARGET_CHANGED"] = true,
					},
					custom = {
						{
							key = "hp_perc_sl",
							text = L["目标血量低于多少时开始对比"],
							default = 25,
							min = 5,
							max = 50,
						},
					},
					init = function(frame)						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.update_rate = .1
						frame.last_update = 0
						frame.mob_npcID = "240905"
						
						function frame:UpdateHighestHealth()
							local highestHealth = 0
							local totalHealth
							local highestUnit
							local targetHealth
							
							for unit in T.IterateBoss() do
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								local isArcaneCollector = npcID == self.mob_npcID
								
								if isArcaneCollector then
									local health = UnitHealth(unit)
									
									if UnitIsUnit(unit, "target") then
										targetHealth = health
									end
									
									if health >= highestHealth then
										highestHealth = health
										highestUnit = unit
									end
									
									highestHealth = math.max(highestHealth, health)
									totalHealth = UnitHealthMax(unit)
								end
							end
							
							-- If we are not targeting a collector, or we are targeting the highest HP collector, hide states
							if not targetHealth or UnitIsUnit("target", highestUnit) or targetHealth/totalHealth*100 > C.DB["BossMod"][self.config_id]["hp_perc_sl"] then
								if self.text_frame:IsShown() then
									self.text_frame:Hide()
								end
							else
								local difference = highestHealth - targetHealth
								local differencePercent = (difference / totalHealth) * 100
								
								self.text_frame.text:SetText(string.format(L["血量领先"], differencePercent))
								
								if not self.text_frame:IsShown() then
									self.text_frame:Show()
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_HEALTH" then
							if GetTime() - frame.last_update > frame.update_rate then
								frame.last_update = GetTime()
								frame:UpdateHighestHealth()
							end
						elseif event == "PLAYER_TARGET_CHANGED" then
							frame:UpdateHighestHealth()
						end
					end,
					reset = function(frame, event)
						frame.text_frame:Hide()
					end,
				},				
			},
		},
		{ -- 光子轰击
			spells = {
				{1234328},--【光子轰击】
			},
			options = {
				{ -- 首领模块 光子轰击 倒计时 （✓）
					category = "BossMod",
					spellID = 1234328,
					ficon = "12",
					name = T.GetIconLink(1234328)..L["倒计时"],	
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_POWER_UPDATE"] = true,
						["ENCOUNTER_ENGAGE_UNIT"] = true,
						["PLAYER_TARGET_CHANGED"] = true,
						["JST_CUSTOM"] = true,
					},
					init = function(frame)
						frame.GUIDToCastCount = {}  -- 施法计数
						frame.GUIDToNextCast = {} -- 下一次施法的时间点
						
						local icon = C_Spell.GetSpellTexture(1234328)
						local color = T.GetSpellColor(1234328)						
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, L["射线"], color)
						frame.bar.glow:SetBackdropBorderColor(unpack(color))
						frame.bar.glow:Show()
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.text_frame.count_down_start = 3
						frame.text_frame.text:SetTextColor(unpack(color))
						
						function frame:display()
							local GUID = UnitGUID("target")
							
							if GUID then
								local nextCast = self.GUIDToNextCast[GUID]
								if nextCast and nextCast ~= 0 then
									local timeToNextCast = nextCast - GetTime()
									if timeToNextCast < 4.2 then
										T.Start_Text_Timer(self.text_frame, timeToNextCast, L["射线"], true)
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "JST_CUSTOM" then
							local id = ...
							if id == frame.config_id then
								frame:display()
							end
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if not string.find(unit, "boss") then return end
							if spellID == 1227631 then -- 奥术驱除
								for GUID in pairs(frame.GUIDToCastCount) do
									frame.GUIDToCastCount[GUID] = 0
								end
								for GUID in pairs(frame.GUIDToNextCast) do
									frame.GUIDToNextCast[GUID] = 0
								end
							elseif spellID == 1234328 then -- 光子轰击
								local GUID = UnitGUID(unit)
								if frame.GUIDToCastCount[GUID] then 
									frame.GUIDToCastCount[GUID] = frame.GUIDToCastCount[GUID] + 1
									if frame.GUIDToCastCount[GUID] < 4 then
										frame.GUIDToNextCast[GUID] = GetTime() + 4
									else
										frame.GUIDToNextCast[GUID] = GetTime() + 19
										frame.GUIDToCastCount[GUID] = 0
										C_Timer.After(15, function()
											T.FireEvent("JST_CUSTOM", frame.config_id)
										end)
									end
									T.FireEvent("JST_CUSTOM", frame.config_id)
								end
								
								if UnitIsUnit(unit, "target") then
									T.StartTimerBar(frame.bar, 2, true, true)
									T.PlaySound("ray")
								end
							end
						elseif event == "UNIT_POWER_UPDATE" then
							local unit = ...							
							if not string.find(unit, "boss") then return end							
							local GUID = UnitGUID(unit)						
							if frame.GUIDToNextCast[GUID] == 0 and UnitPower(unit) > 0 then -- 奥术收集装置第一次获得能量
								frame.GUIDToNextCast[GUID] = GetTime() + 3
								T.FireEvent("JST_CUSTOM", frame.config_id)
							end
						elseif event == "PLAYER_TARGET_CHANGED" then
							T.FireEvent("JST_CUSTOM", frame.config_id)
						elseif event == "ENCOUNTER_ENGAGE_UNIT" then
							local unit, GUID = ...
							local npcID = select(6, strsplit("-", GUID))
							if npcID == "240905" and not frame.GUIDToNextCast[GUID] then
								frame.GUIDToCastCount[GUID] = 0
								frame.GUIDToNextCast[GUID] = 0
							end
						elseif event == "ENCOUNTER_START" then
							frame.GUIDToCastCount = table.wipe(frame.GUIDToCastCount)
							frame.GUIDToNextCast = table.wipe(frame.GUIDToNextCast)
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
				{ -- 图标 光子轰击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1234324,
					tip = L["DOT"],
				},
				{ -- 团队框架高亮 光子轰击（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1234324,
				},
			},
		},
		{ -- 奥术汇流
			spells = {
				{1226260},--【奥术汇流】
			},
			options = {
				{ -- 计时条 奥术汇流（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1232590,
				},
				{ -- 自保技能提示 奥术汇流（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 1232590,
					event = "SPELL_CAST_SUCCESS",
					dur = 4,
					threshold = 65,
				},
			},
		},
		{ -- 庇护的侍从
			npcs = {
				{32596, "0"},--【庇护的侍从】
			},
			spells = {
				--{1232738, "1"},--【硬化之壳】
				--{1238266},--【能量渐增】
			},
			options = {
				{ -- 姓名板光环 硬化之壳（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1232738,
				},
			},
		},
		{ -- 法力裂片
			spells = {
				{1233415, "1"},--【法力裂片】
			},
			options = {
				{ -- 首领模块 法力牺牲 倒计时 （✓）
					category = "BossMod",
					spellID = 1230529,
					name = T.GetIconLink(1230529)..L["倒计时"],	
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,						
					},
					init = function(frame)
						frame.intermission = false
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.text_frame.text:SetTextColor(unpack(T.GetSpellColor(1230529)))
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...							
							if string.find(unit, "boss") and spellID == 1227631 then -- 奥术驱逐
								frame.intermission = true
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and (spellID == 1233415 or spellID == 1233076) then -- 法力裂片/黑暗奇点
								T.Stop_Text_Timer(frame.text_frame)
								frame.intermission = false
							end
						elseif event == "ENCOUNTER_HIDE_BOSS_UNIT" then
							if frame.intermission then
								local collector = false
								
								for unit in T.IterateBoss() do
									local npcID = T.GetUnitNpcID(unit)
									if npcID == "240905" then -- 奥术收集者
										collector = true
										break
									end
								end
								
								if not collector then
									T.Start_Text_Timer(frame.text_frame, 8.3, L["BOSS易伤"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.intermission = false
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 计时条 法力牺牲（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1230529,
				},
				{ -- 计时条 法力牺牲（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss",
					spellID = 1230529,
				},
				{ -- 计时条 法力裂片（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss",
					spellID = 1233415,
					text = L["易伤"].."100%",
				},
			},
		},
		{ -- 聚焦之虹
			spells = {
				{1232412},--【聚焦之虹】
			},
			options = {
				{ -- 图标 聚焦之虹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1232412,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},	
		{ -- 黑暗奇点
			spells = {
				{1233076, "5"},--【黑暗奇点】
			},
			options = {
				{ -- 图标 黑暗奇点（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1233076,
					tip = L["DOT"],
				},
			},
		},
		{ -- 沉重黑暗
			spells = {		
				{1233074, "4"},--【沉重黑暗】
			},
			options = {
				{ -- 图标 沉重黑暗（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1233074,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 虚空收割
			spells = {						
				{1243901, "12"},--【虚空收割】
			},
			options = {
				{ -- 文字 虚空收割 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1243887)..L["倒计时"],
					data = {
						spellID = 1243887,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},					
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1243887 then
								self.next_count = self.next_count + 1
								
								local dur
								if self.difficultyID == 15 then
									dur = self.next_count % 2 == 1 and 36 or 8
								elseif self.difficultyID == 16 then
									dur = self.next_count % 3 == 1 and 28 or 8
								end
								
								if dur then
									T.Start_Text_DelayTimer(self, dur, T.GetIconLink(1243887), true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 2 then
								self.next_count = 1
								T.Start_Text_Timer(self, 13.5, T.GetIconLink(1243887), true)
							end
						elseif event == "ENCOUNTER_START" then
							self.round = true
							self.difficultyID = select(3, ...)
						end
					end,
				},
				{ -- 文字 虚空收割出小怪 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 1243873,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},					
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1243887 then
								T.Start_Text_Timer(self, 7, L["召唤小怪"], true)
							end
						elseif event == "ENCOUNTER_START" then
							self.round = true
							self.count_down_start = 4
							self.prepare_sound = "add"
						end
					end,
				},
				{ -- 计时条 虚空收割（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1243887,
					text = L["小怪"],
					dur = 7,
					tags = {3},
					sound = soundfile("1243887cast"),
				},
				{ -- 首领模块 虚空收割 计时圆圈（✓）
					category = "BossMod",
					spellID = 1243887,
					name = T.GetIconLink(1243873)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1243873] = { -- 虚空收割
								event = "SPELL_AURA_APPLIED",
								target_me = true,
								dur = 7,
								color = {.07, 1, 1},
							},
						}
						T.InitCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleTimers(frame)
					end,
				},
				{ -- 自保技能提示 虚空收割（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1243873,
					spellIDs = {1243901},
					threshold = 65,
				},
				{ -- 首领模块 虚空收割 点名统计 整体排序 （✓）
					category = "BossMod",
					spellID = 1243873,
					name = string.format(L["NAME点名排序"], T.GetIconLink(1243873)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 150},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1243873
						frame.element_type = "bar"
						frame.color = T.GetSpellColor(1243873)
						frame.raid_index = true
						frame.disable_copy_mrt = true
						frame.support_spells = 10
						
						frame.info = {
							{text = "1"},
							{text = "2"},
							{text = "3"},
							{text = "4"},
							{text = "5"},
							{text = "6"},
						}
						
						function frame:post_remove(element, index, unit, GUID)
							if C.DB["BossMod"][frame.config_id]["raid_index_bool"] then
								T.CreateRFIndex(GUID, index)
								C_Timer.After(4, function()
									T.HideRFIndexbyGUID(GUID)
								end)
							end
						end
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
					end,
				},
			},
		},
		{ -- 虚空具象
			spells = {
				{1243641},--【虚空涌动】
			},
			options = {
				{ -- 图标 虚空涌动（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1243641,
					tip = L["DOT"],
				},
			},
		},
		{ -- 死亡挣扎
			spells = {
				{1232221, "12"},--【死亡挣扎】
			},
			options = {
				{ -- 计时条 死亡挣扎（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1232221,
					text = L["击退"],
					sound = "[knockoff]cast,cd3",
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1.1,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1230529, -- 法力牺牲
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 1.2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1230529, -- 法力牺牲
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 2,		
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1233076, -- 黑暗奇点
					count = 1,
				},
			},
		},
	},
}