local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["限制移动"] = "限制移动"
	L["能量过高提示"] = "能量过高提示"
	L["别跑太快"] = "别跑太快"
	L["玩具数量监控"] = "玩具数量监控"
	L["剩余玩具"] = "剩余玩具 %d"
elseif G.Client == "ruRU" then
	L["限制移动"] = "Ограничение движения"
	L["能量过高提示"] = "Высокая энергия"
	L["别跑太快"] = "Не бегите быстро"
	L["玩具数量监控"] = "Мониторинг игрушек"
	L["剩余玩具"] = "Осталось игрушек %d"
else
	L["限制移动"] = "Limit Moving"
	L["能量过高提示"] = "High energy prompt"
	L["别跑太快"] = "Not So Fast"
	L["玩具数量监控"] = "Toy quantity monitoring"
	L["剩余玩具"] = "Remaining toys %d"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2640] = {
	engage_id = 3010,
	npc_id = {"229181", "229177"},
	alerts = {
		{ -- 巨械争斗
			spells = {
				{465833, "5"},
			},
			options = {
				{ -- 文字提示 能量（✓）
					category = "TextAlert",
					type = "pp",
					data = {
						npc_id = "229181",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(465833)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 巨械争斗（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465863,
					color = {.96, 1, .48},
				},
			},
		},
		{ -- 微械厮斗
			spells = {
				{1221826, "12"},
			},
			options = {
				{ -- 首领模块 玩具数量监控（待测试）
					category = "BossMod",
					spellID = 465872,
					ficon = "12",
					enable_tag = "spell",
					name = T.GetIconLink(1221826)..L["玩具数量监控"],	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.last_stack = 0  
						frame.last_time = 0 
						frame.bomb_num = 0
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:start()
							self.text_frame.exp_time = GetTime() + 75
							
							self.text_frame.text:SetText("")
							self.text_frame:Show()	
							
							self.text_frame:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > 0 and self.bomb_num > 0 then
										s.text:SetText(string.format(L["剩余玩具"], self.bomb_num))
									else
										s:Hide()
										s:SetScript("OnUpdate", nil)
									end
									s.t = 0
								end
							end)
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_REMOVED" and spellID == 465872 then -- 巨械争斗
								frame.bomb_num = 3
								frame:start()
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1221826 then -- 微械厮斗 
								if GetTime() - frame.last_time > 2.5 then
									frame.last_time = GetTime()
									frame.last_stack = 0
									frame.bomb_num = frame.bomb_num - 1
								end
							elseif sub_event == "SPELL_AURA_APPLIED_DOSE" and spellID == 1221826 then -- 微械厮斗 叠层
								if frame.last_stack ~= amount then
									frame.last_stack = amount
									frame.bomb_num = frame.bomb_num - 1
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.last_stack = 0
							frame.last_time = 0
							
							frame.bomb_num = 3
							frame:start()
						end
					end,
					reset = function(frame, event)
						frame.text_frame:Hide()
						frame.text_frame:SetScript("OnUpdate", nil)
						frame:Hide()
					end,
				},
				{ -- 首领模块 微械厮斗 计时圆圈（✓）
					category = "BossMod",
					spellID = 1221826,
					enable_tag = "spell",
					name = T.GetIconLink(1221826)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1221826] = { -- 微械厮斗
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .3, 0},
							},
						}
						T.InitUnitAuraCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraCircleTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraCircleTimers(frame)			
					end,
				},
				{ -- 图标 微械厮斗（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1221826,
					tip = L["DOT"],
					ficon = "12",
				},
			},
		},
		{ -- 加强戒备
			spells = {
				{471660},
			},
			options = {
				{ -- 图标 加强戒备（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 471660,
					tip = L["BOSS免疫"],
				},
			},
		},
		{ -- 血腥霸王
			spells = {
				{471557},
			},
			options = {
				{ -- 图标 血腥霸王（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 471557,
				},
			},
		},
		{ -- 酷热恨意
			spells = {
				{472220, "2"},
			},
			options = {
				{ -- 图标 酷热恨意（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 472222,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 废物炸弹
			spells = {
				{473650},
			},
			options = {
				{ -- 文字 废物炸弹 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.8, .18, .14},
					preview = L["炸弹"]..L["倒计时"],
					data = {
						spellID = 473650,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[1] = {9,23,24},
							},
							[16] = {
								[1] = {9,23,24},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 473650, L["炸弹"], self, event, ...)
					end,
				},
				{ -- 计时条 废物炸弹（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 473650,
					dur = 13,
					tags = {3},
					color = {.8, .18, .14},
				},
				{ -- 图标 熔火粘痰（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 1213690,
					hl = "yel",
					tip = L["分散"],
				},
				{ -- 首领模块 熔火粘痰 计时圆圈（✓）
					category = "BossMod",
					spellID = 1213690,
					enable_tag = "none",
					name = T.GetIconLink(1213690)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1213690] = { -- 熔火粘痰
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .53, .09},
							},
						}
						T.InitUnitAuraCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraCircleTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraCircleTimers(frame)			
					end,				
				},
				{ -- 图标 熔岩池（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1214039,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 首领模块 废物炸弹 MRT轮次分配（✓）
					category = "BossMod", 
					spellID = 473650,
					enable_tag = "spell",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(473650)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -270},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.sub_event = "SPELL_CAST_START"
						frame.cast_id = 473650
						
						frame.loop = true
						frame.assign_count = 6
						frame.alert_dur = 13
						
						frame.alert_text = L["分担伤害"]
						frame.send_msg = L["分担伤害"]
						frame.raid_glow = "pixel"
						
						T.InitSpellBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateSpellBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellBars(frame)
					end,
				},
			},
		},
		{ -- 轰焚啸焰炮
			spells = {
				{472231, "4"},
			},
			options = {
				{ -- 文字 轰焚啸焰炮 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.97, .78, .37},
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 472233,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[1] = {15, 24, 21},
							},
							[16] = {
								[1] = {15, 24, 21},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 472233, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 轰焚啸焰炮（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 472233,
					color = {.97, .78, .37},
					text = L["射线"],
					sound = "[ray]cast",
					range_ck = true,
				},
				{ -- 计时条 轰焚啸焰炮（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 472233,
					dur = 5,
					color = {.97, .78, .37},
					range_ck = true,
				},
			},
		},
		{ -- 喷发重踏
			spells = {
				{1214190, "0"},
			},
			options = {
				{ -- 文字 喷发重踏 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {.87, .33, .07},
					preview = T.GetIconLink(1214190)..L["躲波"]..L["倒计时"],
					data = {
						spellID = 1214190,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[1] = {26, 25},
							},
							[16] = {
								[1] = {26, 25},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1214190, L["躲波"], self, event, ...)
					end,
				},
				{ -- 计时条 喷发重踏[音效:喷发重踏]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1214190,
					color = {.87, .33, .07},
					ficon = "0",
					text = L["躲波"],
					sound = soundfile("1214190cast", "cast"),
					range_ck = true,
				},
			},
		},
		{ -- 镀电恨意
			spells = {
				{472223, "2"},
			},
			options = {
				{ -- 图标 镀电恨意（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 472225,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 静电充能
			spells = {
				{473951, "5"},
			},
			options = {
				{ -- 计时条 静电充能[音效:限制移动]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473994,
					color = {.35, .74, 1},
					text = L["限制移动"],
					sound = soundfile("473994cast", "cast"),
				},
				{ -- 图标 静电充能（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 474159,
					hl = "",
					text = L["限制移动"],
				},				
				{ -- 文字 静电充能 能量过高提示（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 1},
					preview = L["能量过高提示"]..string.format(" |cffFF0000%s %d|r", L["停止移动"], 85),
					data = {
						spellID = 474159,
						events =  {
							["UNIT_POWER_FREQUENT"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "UNIT_POWER_FREQUENT" then
							local unit = ...
							if unit == "player" then
								local value = UnitPower(unit, 10)
								if value and value >= 50 then
									if value >= 80 then
										self.text:SetText(string.format("|cffFF0000%s %d|r", L["停止移动"], value))
									else
										self.text:SetText(string.format("|cffffdb6b%s %d|r", L["别跑太快"], value))
									end
									self:Show()
								else
									self.text:SetText("")
									self:Hide()
								end
							end
						end
					end,
				},
			},
		},
		{ -- 雷鼓齐射
			spells = {
				{463840},
			},
			options = {
				{ -- 文字 雷鼓齐射 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.3, .84, .93},
					preview = L["跑圈"]..L["倒计时"],
					data = {
						spellID = 463900,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 463900, L["跑圈"], self, event, ...)
					end,
				},
				{ -- 计时条 雷鼓齐射（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 463900,
					dur = 8,
					color = {.3, .84, .93},
					sound = "[mindstep]cast",
					text = L["跑圈"],
					range_ck = true,
				},
			},
		},
		{ -- 流电镜像
			spells = {
				{1213994},
			},
			options = {
				{ -- 文字 流电镜像 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "4,12",
					color = {.69, .95, .99},
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 1214009,
						events =  {
							["ENCOUNTER_PHASE"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 1 then
								T.Start_Text_DelayTimer(self, 30, L["召唤小怪"], true)
							end
						elseif event == "ENCOUNTER_START" then
							T.Start_Text_DelayTimer(self, 30, L["召唤小怪"], true)
						end
					end,
				},
				{ -- 图标 流电镜像（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 1214009,
					hl = "red",
					ficon = "4,12",
				},
				{ -- 姓名板法术来源图标 流电镜像（✓）
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 1214009,
					hl_np = true,
					ficon = "4,12",
				},
				{ -- 图标 残存电流（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 463925,
					tip = L["快走开"],
					sound = "[sound_dd]",
					ficon = "4,12",
				},
				{ -- 首领模块 流电镜像 多人光环（✓）
					category = "BossMod",
					spellID = 1214009,
					enable_tag = "rl",
					ficon = "4,12",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1214009)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -330},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 3
						
						frame.spellIDs = {
							[1214009] = { -- 流电镜像
								color = {.02, .41, 1},
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
		{ -- 闪电重拳
			spells = {
				{466178, "0"},
			},
			options = {
				{ -- 计时条 闪电重拳[音效:闪电重拳]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466178,
					color = {.46, .63, .82},
					ficon = "0",
					sound = soundfile("466178cast", "cast"),
					range_ck = true,
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 465872,
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 465872,
				},
			},
		},
	},
}