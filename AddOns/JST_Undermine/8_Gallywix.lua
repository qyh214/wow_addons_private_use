local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["炸弹数量"] = "|cffff0000小怪 %d|r |cffffff00地上 %d|r"
	L["倒计时和距离检测"] = "倒计时和距离检测"
	L["引远火"] = "引远火"
	L["五环"] = "五环"
elseif G.Client == "ruRU" then
	L["炸弹数量"] = "|cffff0000Мобы %d|r |cffffff00Пол %d|r"
	L["倒计时和距离检测"] = "Отсчет и обнаружение расстояния"
	L["引远火"] = "Приманка дальнего огня"
	L["五环"] = "Кольца"
else
	L["炸弹数量"] = "|cffff0000Mobs %d|r |cffffff00Floor %d|r"
	L["倒计时和距离检测"] = "Countdown and distance detection"
	L["引远火"] = "Bait Far Fire"
	L["五环"] = "Circles"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2646] = {
	engage_id = 3016,
	npc_id = {"231075"},
	alerts = {
		{ -- 裂破弹药筒
			spells = {
				{466340, "0,5"},
			},
			options = {
				{ -- 文字 裂破弹药筒/散射弹药筒 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "3,12",
					color = {1, .56, .18},
					preview = L["分担伤害"]..L["倒计时"],
					data = {
						spellID = 466340,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[15] = { -- 466340 裂破弹药筒
								[1] = {6, 17, 18, 19, 17, 21},
							},
							[16] = { -- 1218488 散射弹药筒
								[3.5] = {12, 42, 37, 35},
								[4.5] = {7, 37, 46},
							},
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["分担伤害"], true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["分担伤害"], true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if self.dif == 15 then -- H
								if sub_event == "SPELL_CAST_START" and spellID == 466340 then -- 裂破弹药筒
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["分担伤害"], true)
									end
								end
							elseif self.dif == 16 then -- M
								if sub_event == "SPELL_CAST_START" and spellID == 1218488 then -- 散射弹药筒
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["分担伤害"], true)
									end
								end
							end
						end
					end,
				},
				{ -- 首领模块 散射弹药筒 MRT轮次分配（✓）
					category = "BossMod", 
					spellID = 1218488,
					ficon = "12",
					enable_tag = "spell",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1218488)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -270},
					events = {
						["ENCOUNTER_PHASE"] = true,
						["JST_SPELL_ASSIGN"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.assign_count = 2
						frame.loop = true							
						frame.alert_text = L["分担"]
						frame.alert_dur = 6						
						frame.show_dur_text = true
						frame.sound = "sharedmg"
						frame.raid_glow = "pixel"
						
						frame.spell_count = 0
						frame.info = {
							[3.5] = {12, 42, 37, 35},
							[4.5] = {7, 37, 46},
						}						
						
						T.InitSpellBars(frame)
						
						frame.text_frame.prepare_sound = "sharedmg"
						
						function frame:override_action(count, display_count, GUIDs, my_index)
							local num = 0
							for i, GUID in pairs(GUIDs) do
								local info = T.GetGroupInfobyGUID(GUID)
								local unit = info and info.unit
								if unit then
									local alive = not UnitIsDeadOrGhost(unit)
									local debuffed = AuraUtil.FindAuraBySpellID(1218491, unit, "HARMFUL") -- 散射弹药筒
									if alive and not debuffed then
										num = num + 1
										if GUID == G.PlayerGUID then
											if num <= 5 then
												self.text_frame.count_down_start = 4
												T.Start_Text_Timer(self.text_frame, 5, string.format("|cff00ff00%s|r", L["分担"]), true)
											else
												self.text_frame.count_down_start = nil
												T.Start_Text_Timer(self.text_frame, 5, string.format("|cffff0000%s|r", L["不分担"]), true)
											end
										end
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.spell_count = 0
							frame.phase = 1
							
						elseif event == "ENCOUNTER_PHASE" then
							frame.spell_count = 0
							frame.phase = ...
							
							local next_count = frame.spell_count + 1
							local dur = frame.info[frame.phase] and frame.info[frame.phase][next_count]
							if dur then
								frame:start_countdown(dur-1.5)
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1218488 then -- 散射弹药筒
								frame.spell_count = frame.spell_count + 1
								local next_count = frame.spell_count + 1
								local dur = frame.info[frame.phase] and frame.info[frame.phase][next_count]
								if dur then
									frame:start_countdown(dur-1.5)
								end
							end
						end
						
						T.UpdateSpellBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellBars(frame)
					end,
				},
				{ -- 计时条 裂破弹药筒（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466340,
					spellIDs = {1218488},
					color = {1, .56, .18},
				},				
				{ -- 图标 裂破弹药筒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 471603,
					spellIDs = {1218491},
					tip = L["易伤"],
				},
				{ -- 图标 机械工程师的弹药筒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1220761,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],	
				},				
				{ -- 图标 机械大师的弹药筒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 474130,
					effect = 2,
					hl = "",
					tip = L["吸收治疗"],	
				},
				{ -- 首领模块 团队吸收量计时条（✓）
					category = "BossMod",
					spellID = 1220761,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环数值提示"], L["吸收治疗"]),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -280},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 8
						
						frame.spellIDs = {
							[1220761] = { -- 机械工程师的弹药筒 H 490w
								aura_type = "HARMFUL",
								color = {.8, .25, 1},
								effect = 1,
								progress_value = 5000000,
							},
							[474130] = { -- 机械大师的弹药筒 M 607w
								aura_type = "HARMFUL",
								color = {.8, .25, 1},
								effect = 2,
								progress_value = 6000000,
							},
						}
						
						T.InitUnitAuraBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
			},
		},
		{ -- 超大捆劣性炸药
			spells = {
				{465952},
			},
			options = {
				{ -- 文字 超大捆劣性炸药 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "3,12",
					color = {.54, .97, 1},
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 465952,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[15] = {
								[1] = {20, 35, 35}, -- 超大捆劣性炸药 465952
								[2] = {36}, -- 超大捆劣性炸药 465952
								[3] = {7, 36, 63, 67, 26}, -- 超大更猛炸弹轰击 1214607
							},
							[16] = {
								[2] = {7, 58, 57, 56}, -- 超大更猛炸弹轰击 1214607
								[3.5] = {37, 48, 54}, -- 超大特猛炸弹弹幕 1218546
								[4.5] = {30, 51}, -- 超大特猛炸弹弹幕 1218546
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["大圈"], true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["大圈"], true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if self.dif == 15 then -- H
								if sub_event == "SPELL_CAST_START" and (spellID == 465952 or spellID == 1214607) then -- 超大捆劣性炸药 超大更猛炸弹轰击
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["大圈"], true)
									end
								end
							elseif self.dif == 16 then -- M
								if sub_event == "SPELL_CAST_START" and (spellID == 1214607 or spellID == 1218546) then -- 超大更猛炸弹轰击 超大特猛炸弹弹幕
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["大圈"], true)
									end
								end
							end
						end
					end,
				},
				{ -- 计时条 超大捆劣性炸药（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465952,
					color = {.54, .97, 1},
					text = L["炸弹"],
				},
				{ -- 图标 爆破燃烧（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466154,
					tip = L["DOT"],
					hl = "",
				},
				{ -- 声音 工兵的背包（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 466155,
					private_aura = true,
					file = "[bombonyou]",
				},
				{ -- 图标 1500磅的-哑弹（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466185,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 首领模块 1500磅的-哑弹 计时条（✓）
					category = "BossMod",
					spellID = 466248,
					enable_tag = "role",
					ficon = "0",
					name = T.GetIconLink(466248)..L["爆炸"]..L["计时条"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.bars = {}
						
						function frame:hide_all()
							for i, bar in pairs(frame.bars) do
								T.StopTimerBar(bar, true, true)
							end
						end						
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 466248 then
								if not frame.bars[destGUID] then
									frame.bars[destGUID] = T.CreateAlertBarShared(1, "bossmod"..frame.config_id.."-"..destGUID, 133710, L["爆炸"], {1, .84, .07})
									T.StartTimerBar(frame.bars[destGUID], 15, true, true)
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 466248 then
								if frame.bars[destGUID] then
									T.StopTimerBar(frame.bars[destGUID], true, true)
								end
							end
						end
					end,
					reset = function(frame, event)
						frame:hide_all()
						frame.bars = table.wipe(frame.bars)
					end,
				},
				{ -- 图标 集中爆破（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466246,
					tip = L["强力DOT"],
					hl = "red",
				},			
				{ -- 图标 急转飞射火箭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466338,
					tip = L["DOT"],
					hl = "",
				},
			},
		},
		{ -- 压制
			spells = {
				{467182},
			},
			options = {
				{ -- 文字 压制 倒计时（P3 P4）（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {1, .35, .07},
					preview = L["引远火"]..L["倒计时"].."（P3 P4）",
					data = {
						spellID = 467182,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							[16] = {
								[3.5] = {23, 44, 45},
								[4.5] = {64, 34},
							},
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							local next_count = self.spell_count + 1
							local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
							if dur then
								T.Start_Text_DelayTimer(self, dur, L["引远火"], true)
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()

							if sub_event == "SPELL_CAST_START" and spellID == 467182 then -- 压制
								self.spell_count = self.spell_count + 1
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["引远火"], true)
								end
							end
						end
					end,
				},
				{ -- 图标 压制（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 467184,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 首领模块 压制 跑圈倒计时和距离检测（✓）
					category = "BossMod",
					spellID = 467182,
					enable_tag = "none",
					name = T.GetIconLink(467182)..L["倒计时和距离检测"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						frame.range_updater = CreateFrame("Frame")
						frame.range_updater.t = 0
						
						function frame.range_updater:update()
							self.exp_time = GetTime() + 6
							
							self:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > 0 then
										if C_Item.IsItemInRange(33069, "boss1") then -- 15码
											frame.text_frame.cur_text = string.format("|cffff0000%s|r", L["远离"])
										else
											frame.text_frame.cur_text = string.format("|cff00ff00%s|r", L["安全"])
										end
									else
										s:SetScript("OnUpdate", nil)
									end
									s.t = 0
								end
							end)
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 467182 then -- 压制
								T.Start_Text_Timer(frame.text_frame, 6, T.GetIconLink(467182), true)
								frame.range_updater:update()
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
						frame.range_updater:SetScript("OnUpdate", nil)
					end,
				},
			},
		},
		{ -- 排放热量
			spells = {
				{466751},
			},
			options = {
				{ -- 文字 排放热量 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "2,3,12",
					color = {.96, .52, .16},
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 466751,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[15] = {
								[1] = {12, 26, 28, 28},
								[2] = {20, 61},
								[3] = {18, 70, 37, 69},
							},
							[16] = {
								[2] = {38, 17, 23, 19, 22, 29, 12, 24},
								[3.5] = {9, 35, 19, 37, 21, 25},
								[4.5] = {19, 34, 20},
							},
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["全团AE"], true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["全团AE"], true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if self.dif == 15 or self.dif == 16 then
								if sub_event == "SPELL_CAST_START" and spellID == 466751 then -- 排放热量
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["全团AE"], true)
									end
								end
							end
						end
					end,
				},
				{ -- 计时条 排放热量（待测试）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 466751,
					dur = 5,
					color = {.96, .52, .16},
					tags = {4},
					text = L["全团AE"],
					glow = true,
					ficon = "2",
				},
				{ -- 图标 排放热量（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 466751,
					tip = L["DOT"],
					hl = "",
				},
			},
		},
		{ -- 连环机炮 技巧射击
			spells = {
				{471225, "0"},
				{1220290, "0"},
			},
			options = {
				{ -- 计时条 连环机炮
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1224669,
					color = {.6, .69, .8},
					ficon = "0",
					show_tar = true,
				},
				{ -- 图标 连环机炮
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1224669,
					ficon = "0",
					hl = "red",
				},
				{ -- 计时条 技巧射击
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1225925,
					color = {1, .81, .15},
					ficon = "0",
					show_tar = true,
				},
				{ -- 图标 技巧射击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 1220290,
					ficon = "0",
				},
				{ -- 图标 技巧射击
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1220375,
					ficon = "0",
					tip = L["DOT"],
					hl = "",
				},
				{ -- 首领模块 换坦光环
					category = "BossMod",
					spellID = 1224669,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(1224669)..T.GetIconLink(1220375)..T.GetIconLink(467064)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[1224669] = { -- 连环机炮
								color = {.6, .69, .8},
							},
							[1220375] = { -- 技巧射击
								color = {1, .81, .15},
							},
							[467064] = { -- 打压自尊
								color = {.93, .88, .84},
							},
						}
						T.InitUnitAuraBars(frame)			
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
			},
		},
		{ -- 极巨大线圈
			spells = {
				{469286},
			},
			options = {
				{ -- 文字 极巨大线圈 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "3,12",
					color = {.1, .7, 1},
					preview = T.GetIconLink(469293)..L["倒计时"],
					data = {
						spellID = 469293,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,			
						},					
						info = {							
							[15] = {
								--[1] = {120}, -- 极巨大线圈 buff 469293
								--[2] = {57}, -- 极巨大线圈 buff 469293
								[3] = {60, 79, 38}, -- 极巨大线圈 buff 469293
							},
							[16] = {
								--[2] = {24, 58, 58, 61}, -- 极巨大线圈 buff 469293
								[3.5] = {97}, -- 极巨大线圈 buff 469293
							},
						},	
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, T.GetIconLink(469293), true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, T.GetIconLink(469293), true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if self.dif == 15 or self.dif == 16 then
								if sub_event == "SPELL_AURA_APPLIED" and spellID == 469293 then -- 极巨大线圈
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, T.GetIconLink(469293), true)
									end
								end
							end
						end
					end,
				},
				{ -- 图标 极巨大线圈（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 469293,
					tip = L["DOT"],
					hl = "red",
				},
				{ -- 图标 破坏区域（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1215209,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},				
			},
		},
		{ -- 极巨大冲击
			spells = {
				{469327},
			},
			options = {
				{ -- 文字 极巨大冲击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					group = 2,
					ficon = "12",
					color = {.2, .8, 1},
					preview = L["头前"]..L["倒计时"],
					data = {
						spellID = 469327,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[16] = {
								[2] = {17, 56, 62, 52},
								[3.5] = {49, 57, 43},
								[4.5] = {56},
							},
						},
						cd_args = {
							show_time = 6,
							count_down_start = 5,
							prepare_sound = "baitfront",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 469327, L["头前"], self, event, ...)
					end,
				},
				{ -- 计时条 极巨大冲击（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 469327,
					dur = 5,
					color = {.56, .98, 1},
					tags = {3},
				},
				{ -- 图标 极巨大冲击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 471341,
					tip = L["增加伤害"].."%s20%",
				},
				{ -- 图标 极巨大冲击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469326,
					tip = L["DOT"],
				},
				{ -- 图标 极巨大冲击残渣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218513,
					tip = L["昏迷"],
					ficon = "12",
				},
			},
		},
		{ -- 引线弹药筒
			spells = {
				{466341, "5"},
			},
			options = {
				{ -- 文字 引线弹药筒 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "2,3",
					color = {1, .92, .09},
					preview = L["分担"]..L["倒计时"],
					data = {
						spellID = 466341,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,			
						},					
						info = {							
							[15] = {
								[2] = {10, 34},
							},
						},	
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							if self.dif == 15 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["分担"], true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 466341 then -- 引线弹药筒
								self.spell_count = self.spell_count + 1
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["分担"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 引线弹药筒（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466341,
					color = {1, .92, .09},
					glow = true,
					ficon = "2",
				},
				{ -- 声音 引线弹药筒（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 466344,
					private_aura = true,
					file = "[sharedmg]",
				},
			},
		},
		{ -- 暗索技师
			npcs = {
				{31482},
			},
			options = {
				{ -- 图标 充能的极巨大炸弹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469373,
					tip = L["炸弹"],
					hl = "org_flash",
				},
				{ -- 图标 充能的极巨大炸弹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469362,
					tip = L["炸弹"],
					hl = "org",
				},
				{ -- 图标 极巨大炸弹爆炸（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469795,
					tip = L["加速"].."30%",
				},
				{ -- 图标 极巨大爆破（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469404,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 首领模块 多人光环 充能的极巨大炸弹（✓）
					category = "BossMod",
					spellID = 469373,
					ficon = "3,12",
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(469362)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 250},
					events = {
						["UNIT_AURA"] = true,						
					},
					init = function(frame)
						frame.bar_num = 5
						
						frame.spellIDs = {
							[469362] = { -- 充能的极巨大炸弹
								color = {.19, .85, .91},
							},
						}
						
						T.InitUnitAuraBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)						
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
				{ -- 首领模块 充能的极巨大炸弹 计数（✓）
					category = "BossMod",
					spellID = 469362,
					ficon = "3",
					enable_tag = "none",
					name = T.GetIconLink(469362)..L["计数"],	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 300, width = 180, height = 25},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.mobs = {}
						frame.bombs = {}
						
						frame.bomb_mob = 0
						frame.bomb_floor = 0
						
						frame.text = T.createtext(frame, "OVERLAY", 25, "OUTLINE", "LEFT")
						frame.text:SetPoint("LEFT", frame, "LEFT", 0, 0)
						frame.text:Hide()
						
						function frame:update_text()
							self.text:SetText(string.format(L["炸弹数量"], self.bomb_mob, frame.bomb_floor))
							if self.bomb_mob == 0 and frame.bomb_floor == 0 then
								self.text:Hide()
							else
								self.text:Show()
							end
						end

						function frame:PreviewShow()
							self.text:SetText(string.format(L["炸弹数量"], 3, 5))
							self.text:Show()
						end
						
						function frame:PreviewHide()
							self.text:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 469387 then -- 充能的极巨大炸弹(小怪)
								if not frame.mobs[destGUID] then
									frame.mobs[destGUID] = true
									frame.bomb_mob = frame.bomb_mob + 1
									frame:update_text()
								end
							elseif sub_event == "UNIT_DIED" then
								local npcID = select(6, string.split("-", destGUID)) -- 小怪死亡
								if npcID == "231977" then
									frame.bomb_mob = frame.bomb_mob - 1
									frame.bomb_floor = frame.bomb_floor + 1
									frame:update_text()
								end	
							
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 469362 then -- 充能的极巨大炸弹(玩家)
								if not frame.bombs[sourceGUID] then
									frame.bombs[sourceGUID] = true
									frame.bomb_floor = frame.bomb_floor - 1
									frame:update_text()
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.mobs = table.wipe(frame.mobs)
							frame.bombs = table.wipe(frame.bombs)
						end
					end,
					reset = function(frame, event)
						frame.bomb_mob = 0
						frame.bomb_floor = 0
						frame:update_text()
					end,
				},
			},
		},
		{ -- 能量爆发的技师
			npcs = {
				{31029, "5,12"},
			},
			options = {
				{ -- 图标 电离反应（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1219039,
					ficon = "7",
					hl = "blu",
				},
				{ -- 首领模块 多人光环 电离反应（✓）
					category = "BossMod",
					spellID = 1219039,
					ficon = "2,12",
					enable_tag = "role",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1219039)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 130},
					events = {
						["UNIT_AURA"] = true,						
					},
					init = function(frame)
						frame.bar_num = 4
						
						frame.spellIDs = {
							[1219039] = { -- 电离反应
								color = {.1, .6, 1},
								hl_raid = "proc",
							},
						}
						
						T.InitUnitAuraBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)						
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
				{ -- 图标 被拆除的极巨大炸弹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218992,
					hl = "red",
					tip = L["强力DOT"],
				},
				{ -- 图标 自锁手铐炸弹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1220784,
					hl = "",
				},				
				{ -- 首领模块 姓名板标记 被拆除的极巨大炸弹（✓）
					category = "BossMod",
					spellID = 1218992,
					enable_tag = "none",
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("237967")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("bomb")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						frame.mobID = "237967"
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							local GUID = UnitGUID(unit)
							local npcID = select(6, strsplit("-", GUID))
							if npcID == frame.mobID then
								T.ShowNameplateExtraTex(unit, "bomb")
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
				{ -- 首领模块 标记 能量爆发的技师（✓）
					category = "BossMod",
					spellID = 1219041,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("237192"), T.FormatRaidMark("2,3")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.start_mark = 2
						frame.end_mark = 3
						frame.mob_npcID = "237192"
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 1224378 then -- 极巨大线圈
								frame.counter = frame.start_mark - 1
							end
						end
						T.UpdateRaidTarget(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				{ -- 姓名板打断图标 静电震击（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 1219041,
					mobID = "237192",
					interrupt = 4,
					ficon = "6",
					mrt_info = {"2,3"},
				},
			},
		},
		{ -- 神射哨卫
			npcs = {
				{31487},
			},
			options = {				
				{ -- 首领模块 标记 神射哨卫（✓）
					category = "BossMod",
					spellID = 466834,
					enable_tag = "spell",
					name = string.format(L["NAME焦点自动标记"], T.GetFomattedNameFromNpcID("231978")),
					points = {hide = true},
					events = {
						["PLAYER_FOCUS_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "mark_dd",
							text = L["标记"],
							default = 4,
							key_table = {
								{4, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t"},
								{5, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t"},
								{6, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t"},
								{7, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t"},
							},
						},
					},
					init = function(frame)
						frame.mob_npcID = "231978"
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
					end,
					update = function(frame, event, ...)
						if event == "PLAYER_FOCUS_CHANGED" then
							local GUID = UnitGUID("focus")
							if GUID then
								local npcID = select(6, strsplit("-", GUID))
								if npcID == frame.mob_npcID then
									local old_mark = GetRaidTargetIndex("focus") or 9
									local mark = C.DB["BossMod"][frame.config_id]["mark_dd"]
									
									if old_mark ~= mark then
										T.SetRaidTarget("focus", mark)
									end
									
									T.msg(string.format(L["已标记%s"], date("%H:%M:%S"), T.GetNameFromNpcID(npcID), T.FormatRaidMark(mark)))
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_AURA_APPLIED" and spellID == 1226891 then -- 线圈重启
								C_Timer.After(7, function()
									T.Start_Text_Timer(frame.text_frame, 3, L["设置焦点"])
									T.PlaySound("setfocus")
								end)
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},				
				{ -- 姓名板打断图标 震击弹幕（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 466834,
					mobID = "231978",
					interrupt = 1,
					ficon = "6",
					mrt_info = {"4,5,6,7"},
				},
				{ -- 图标 震击弹幕（?）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466834,
					tip = L["强力DOT"],
					hl = "red",
				},
			},
		},
		{ -- 暗索扳手狂人
			npcs = {
				{31489},
			},
			options = {
				{ -- 图标 扳手（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1216845,
					tip = L["易伤"].."%s50%",
				},
				{ -- 姓名板光环 笨拙狂怒（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1216852,
					ficon = "7,11"
				},
				{ -- 首领模块 标记 暗索扳手狂人（✓）
					category = "BossMod",
					spellID = 1216845,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("231939"), T.FormatRaidMark("4,5,6")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.start_mark = 4
						frame.end_mark = 6
						frame.mob_npcID = "231939"
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 1224378 then -- 极巨大线圈
								frame.counter = frame.start_mark - 1
							end
						end
						T.UpdateRaidTarget(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				{ -- 首领模块 驱散分配 笨拙狂怒（✓）
					category = "BossMod",
					spellID = 1216852,
					enable_tag = "spell",
					name = T.GetIconLink(1216852)..L["驱散"].." "..L["分配"],
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn", 
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:copy_mrt()
							local str, raidlist = "", "", ""

							for ind = 4, 6 do
								raidlist = raidlist..string.format("\n{rt%d}", ind) -- 换行
								local i = 0
								for unit in T.IterateGroupMembers() do
									i = i + 1
									if i <= 2 then
										local name = UnitName(unit)
										raidlist = raidlist.." "..T.ColorNameForMrt(name)
									end
								end
							end
							
							local name = C_Spell.GetSpellName(frame.config_id)
							str = string.format("#%sstart%s%s\nend\n", frame.config_id, name, raidlist)
							
							return str
						end
						
						function frame:GetMrtAssignment()
							self.my_index = nil
							
							if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
								local tag = string.format("#%dstart", self.config_id)
								local text = _G.VExRT.Note.Text1
								
								local betweenLine = false
								local tagmatched = false
								
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										line = T.gsubMarks(line) -- 读取本地化标记文本
										
										for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
											local info = T.GetGroupInfobyName(name)
											if info and info.GUID == G.PlayerGUID then
												self.my_index = string.match(line, "{rt(%d)}")
												self.my_index = tonumber(self.my_index)
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
										tagmatched = true
									end
								end
								
								if not tagmatched then -- 完全没写
									T.msg(string.format(L["MRT数据全部未找到"], T.GetIconLink(self.config_id), tag))
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit and cast_GUID and cast_spellID == 1216852 then
								local rt = GetRaidTargetIndex(unit)
								if rt and rt == frame.my_index then
									T.Start_Text_Timer(frame.text_frame, 3, string.format("%s %s", L["驱散"], T.FormatRaidMark(rt)))
									T.PlaySound("dispel", "mark\\mark"..rt)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame:GetMrtAssignment()
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
			},
		},
		{ -- 陷坑重击
			spells = {
				{1214226, "4"},
			},
			options = {
				
			},
		},
		{ -- 末日决战级护板
			spells = {
				{1214229},
			},
			options = {
				{ -- 血量（✓）
					category = "TextAlert", 
					type = "hp",
					ficon = "3",
					data = {
						npc_id = "231075",
						ranges = {
							{ ul = 54, ll = 50.2, tip = L["阶段转换"]..string.format(L["血量2"], 50)},
						},
					},
				},
				{ -- 吸收盾 末日决战级护板（✓）
					category = "BossMod",
					spellID = 1214229,
					enable_tag = "none",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(1214229)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 1214229 -- 末日决战级护板
						frame.aura_type = "HELPFUL"
						frame.effect = 2
						--frame.time_limit = 46
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
			},
		},
		{ -- 辐射电流
			spells = {
				{1219319},
			},
			options = {
				
			},
		},
		{ -- 毁灭一切！！！
			spells = {
				{1214369, "5,6"},
			},
			options = {
				{ -- 计时条 毁灭一切！！！（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1214369,
					color = {.93, .41, .27},
				},
				{ -- 图标 毁灭一切！！！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 1214369,
					tip = L["DOT"],
					hl = "",
				},
			},
		},
		{ -- 超大更猛炸弹轰击
			spells = {
				{1214607, "0"},
			},
			options = {				
				{ -- 计时条 超大更猛炸弹轰击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1214607,
					color = {.54, .97, 1},
					text = L["大圈"],
					show_tar = true,
				},
				{ -- 计时条 超大特猛炸弹弹幕（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1218546,
					color = {.54, .97, 1},
					text = L["五环"],
				},
				{ -- 声音 超大特猛炸弹弹幕（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1218546,
					private_aura = true,
					file = "[spread]",
				},
				{ -- 图标 过载火箭（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1214755,
					hl = "red",
					tip = L["强力DOT"],
					sound = "[defense]",
				},
				{ -- 声音 过载火箭（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1214760,
					spellIDs = {
						1214749, 1214750, 1214757, 1214758, 
						1214759, 1214761, 1214762, 1214763, 
						1214764, 1214765, 1214766, 1214767,
					},
					private_aura = true,
					file = "[fixate]",
				},
			},
		},
		{ -- 嘀嗒弹药筒
			spells = {
				{466342, "5"},
			},
			options = {
				{ -- 文字 嘀嗒弹药筒/组合式弹药桶 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "2,3,12",
					color = {1, .92, .09},
					preview = L["分担"]..L["倒计时"],
					data = {
						spellID = 466342,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,			
						},					
						info = {							
							[15] = {
								[3] = {21, 64, 35, 65, 61}, -- 嘀嗒弹药筒 466342
							},
							[16] = {
								[2] = {30, 28, 32, 38, 26, 39}, -- 组合式弹药桶 1217987
							},
						},	
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.phase = 1
							self.round = true
							self.dif = select(3, ...)
							
						elseif event == "ENCOUNTER_PHASE" then
							self.spell_count = 0
							self.phase = ...
							
							if self.dif == 15 or self.dif == 16 then
								local next_count = self.spell_count + 1
								local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
								if dur then
									T.Start_Text_DelayTimer(self, dur, L["分担"], true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if self.dif == 15 then -- H
								if sub_event == "SPELL_CAST_START" and spellID == 466342 then -- 引线弹药筒
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["分担"], true)
									end
								end
							elseif self.dif == 16 then -- M
								if sub_event == "SPELL_CAST_START" and spellID == 1217987 then -- 组合式弹药桶
									self.spell_count = self.spell_count + 1
									local next_count = self.spell_count + 1
									local dur = self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["分担"], true)
									end
								end
							end
						end
					end,
				},
				{ -- 计时条 嘀嗒弹药筒（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 466342,
					dur = 10.2,
					color = {.75, .79, .92},
					tags = {9, 9.6},
					text = L["分担"],
					ficon = "2",
				},
				{ -- 计时条 组合式弹药桶（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1217987,
					dur = 10.2,
					color = {.75, .79, .92},
					tags = {9, 9.4, 9.8},
					text = L["分担"],
					ficon = "2",
				},
			},
		},
		{ -- 打压自尊
			spells = {
				{466958, "0"},
			},
			options = {
				{ -- 文字 打压自尊 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {.93, .88, .84},
					preview = T.GetIconLink(466958)..L["倒计时"],
					data = {
						spellID = 466958,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[3] = {29.2, 13, 15, 8.1, 40.7, 13.4, 8, 10, 42, 8.1, 8.9, 26.1},
							},
							[16] = {
								[2] = {15, 21.6, 14.5, 20, 17, 12.4, 16.5, 29.7, 5.5, 23.8, 23.6},
								[3.5] = {21.1, 26.4, 28.6, 28, 20.5, 30.5},
								[4.5] = {23.1, 38.9, 26},
							},
						},
						cd_args = {
							round = true,
							show_time = 8,
							count_down_start = 5,
							prepare_sound = "minddefense",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 466958, T.GetIconLink(466958), self, event, ...)
					end,
				},
				{ -- 计时条 打压自尊（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466958,
					color = {.93, .88, .84},
					ficon = "0",
					show_tar = true,
				},
				{ -- 图标 自尊受挫（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 467064,
					hl = "",
					tip = L["DOT"],
					ficon = "0",
				},
			},
		},
		{ -- 加大头除虫器
			spells = {
				{1219279, "12"},
			},
			options = {
				{ -- 声音 加大头除虫器（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1219279,
					private_aura = true,
					file = "[chainonyou]",
				},
			},
		},
		{ -- 浩劫火箭
			spells = {
				{1218696, "12"},
			},
			options = {
				{ -- 计时条 浩劫火箭（待测试）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1218696,
					dur = 6,
					color = {1, .79, .2},
					tags = {5},
					text = L["躲地板"],
					sound = "cd3",
					copy = true,
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
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 469293, -- 极巨大线圈
					count = 1,
					ficon = "3",
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1214369, -- 毁灭一切！！！
					dif = 15,
					ficon = "3",
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1214369, -- 毁灭一切！！！
					ficon = "3",
				},
				-- M 转阶段
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1214369, -- 毁灭一切！！！ 0:29
					ficon = "12",
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1226891, -- 线圈重启 3:57
					count = 1,
					ficon = "12",
				},
				{
					category = "PhaseChangeData",
					phase = 3.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1226891, -- 线圈重启 4:31(34)
					count = 1,
					ficon = "12",
				},
				{
					category = "PhaseChangeData",
					phase = 4,	
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1226891, -- 线圈重启 7:18
					count = 2,
					ficon = "12",
				},
				{
					category = "PhaseChangeData",
					phase = 4.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1226891, -- 线圈重启 7:49(31)
					count = 2,
					ficon = "12",
				},
			},
		},
	},
}