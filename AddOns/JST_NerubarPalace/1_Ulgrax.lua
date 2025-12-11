local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["消网"] = "消网"
	L["准备喂食"] = "准备喂食"
	L["能量进度条"] = "能量进度条"
else
	L["消网"] = "Clear web"
	L["准备喂食"] = "Prepare to feed"
	L["能量进度条"] = "Power progress bar"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2607] = {
	engage_id = 2902,
	npc_id = {"215657"},
	alerts = {
		{ -- 噬肉角力
			spells = {
				{434776, "5"},
			},
			options = {
				{ -- 文字 噬肉角力 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.81, .47, .47},
					preview = L["分担伤害"]..L["倒计时"],
					data = {
						spellID = 434803,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							["all"] = {
								[1] = {{34, 36},{38, 36},{38, 36}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 434803, L["分担伤害"], self, event, ...)
					end,
				},
				{ -- 计时条 噬肉角力（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434803,
					color = {.81, .47, .47},
					ficon = "5",
					count = true,
					show_tar = true,			
				},
				{ -- 首领模块 噬肉角力 MRT轮次分配（?）
					category = "BossMod", 
					spellID = 434803,
					enable_tag = "spell",
					ficon = "12",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(434803)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -200},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.sub_event = "SPELL_CAST_START"
						frame.cast_id = 434803
						
						frame.loop = true
						frame.assign_count = 2
						frame.alert_dur = 7
						
						frame.alert_text = L["分担伤害"]
						frame.show_dur_text = true
						frame.sound = "sharedmg"
						frame.send_msg = L["分担"]
						frame.raid_glow = "pixel"
						frame.update_id = 455847 -- 伤痕累累
						
						function frame:filter(count, display_count)
							if not AuraUtil.FindAuraBySpellID(self.update_id, "player", "HARMFUL") then
								return true
							end							
						end
						
						function frame:override_player_text(GUID, index)
							local unit = T.GetGroupInfobyGUID(GUID)["unit"]
							if unit then
								if AuraUtil.FindAuraBySpellID(self.update_id, unit, G.TestMod and "HELPFUL" or "HARMFUL") then
									return "|cffff0000[X]|r"..T.ColorNickNameByGUID(GUID)
								else
									return T.ColorNickNameByGUID(GUID)
								end
							end
						end
						
						T.InitSpellBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateSpellBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellBars(frame)
					end,
				},
				{ -- 图标 噬肉角力（✓）
					category = "AlertIcon",
					type = "bmsg",
					spellID = 434776,
					event = "CHAT_MSG_RAID_BOSS_WHISPER",
					boss_msg = "434776",
					hl = "yel_flash",
					dur = 8,
					sound = "[sharedmg]",
				},
				{ -- 图标 伤痕累累（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 455847,
					hl = "red",
					tip = L["易伤"],
					ficon = "12",
				},
				{ -- 图标 轻慢之忿（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 440849,
					tip = L["BOSS狂暴"],
					ficon = "12",
				},
			},
		},
		{ -- 追踪者缠网
			spells = {
				{441451},
			},
			options = {
				{ -- 文字 追踪者缠网 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.55, .85, .9},
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 441452,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							["all"] = {
								[1] = {{9, 45},{13, 45},{13, 45}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 441452, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 追踪者缠网（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441452,
					color = {.55, .85, .9},
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 消化酸液
			spells = {
				{435138},
			},
			options = {
				{ -- 文字 消化酸液 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.22, .82, .46},
					preview = L["消网"]..L["倒计时"],
					data = {
						spellID = 435138,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							["all"] = {
								[1] = {{15, 47}, {19.5, 47}, {19.5, 47}},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 435138, L["消网"], self, event, ...)
					end,
				},
				{ -- 计时条 消化酸液（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 435138,
					color = {.22, .82, .46},
					text = L["消网"],
				},
				{ -- 图标 消化酸液（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 435138,
					hl = "org_flash",
					tip = L["消网"],
					sound = "[getout]cast,cd3",
					msg = {str_applied = "{rt4}%name", str_rep = "%dur"},
				},
				{ -- 首领模块 消化酸液 计时圆圈（✓）
					category = "BossMod",
					spellID = 435152,
					enable_tag = "none",
					name = T.GetIconLink(435138)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[435138] = { -- 消化酸液
								unit = "player",
								aura_type = "HARMFUL",
								color = {.22, .82, .46},
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
				{ -- 首领模块 消化酸液 多人光环（✓）
					category = "BossMod",
					spellID = 435138,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(435138)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -330},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 4
						
						frame.spellIDs = {
							[435138] = { -- 消化酸液
								color = {.22, .82, .46},
								hl_raid = "pixel",
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
		{ -- 剧毒鞭击
			spells = {
				{435136},
			},
			options = {
				{ -- 文字 剧毒鞭击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.8, .94, .71},
					preview = L["全团AE"].."+"..L["DOT"]..L["倒计时"],
					data = {
						spellID = 435136,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							[15] = {
								[1] = {{14, 33, 37},{18, 33, 37},{18, 33, 37}}
							},
							[16] = {
								[1] = {{5, 25, 28},{9, 25, 28},{9, 25, 28}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 435136, L["全团AE"].."+"..L["DOT"], self, event, ...)
					end,
				},
				{ -- 计时条 剧毒鞭击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 435136,
					color = {.8, .94, .71},
					count = true,
					text = L["全团AE"].."+"..L["DOT"],
				},
				{ -- 图标 剧毒鞭击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 435136,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 蛮力碾压
			spells = {
				{434697, "0"},
			},
			options = {
				{ -- 文字 蛮力碾压 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {.78, .23, .15},
					preview = T.GetIconLink(434697)..L["倒计时"],
					data = {
						spellID = 434697,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							["all"] = {
								[1] = {{3, 15, 15, 18, 15},{8, 15, 15, 18, 15},{8, 15, 15, 18, 15}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 434697, T.GetIconLink(434697), self, event, ...)
					end,
				},
				{ -- 计时条 蛮力碾压[音效:蛮力碾压]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434697,
					color = {.78, .23, .15},
					ficon = "0",
					show_tar = true,
					sound = soundfile("434697cast", "cast"),
				},
				{ -- 图标 暴捶（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 434705,
					hl = "",
					tip = L["致死"],
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 434705,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(434705)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[434705] = { -- 暴捶
								color = {.78, .23, .15},
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
		{ -- 泰山压顶
			spells = {
				{435341},
			},
			options = {
				{ -- 计时条 泰山压顶（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445123,
					color = {.87, .67, .53},
					text = L["击退"],
					sound = "[away]cast,cd3",
					glow = true,
				},
			},
		},
		{ -- 准备饕餮
			spells = {
				{440177, "5"},
			},
			options = {				
				{ -- 文字提示 能量（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = L["阶段转换"]..string.format(L["能量"], 5, 100),				
					data = {
						spellID = 440177,
						events = {
							["UNIT_POWER_UPDATE"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, arg1)
						if event == "UNIT_POWER_UPDATE" and arg1 == "boss1" then
							local cur = UnitPower("boss1")
							if self.phase == 1 then
								if cur > 0 and cur <= 10 then
									self.text:SetText(L["阶段转换"]..string.format(L["能量"], cur, 100))
									self:Show()
								else
									self:Hide()
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.phase = arg1
						elseif event == "ENCOUNTER_START" then
							self.phase = 1
						end
					end,
				},
				{ -- 图标 准备饕餮（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss1",					
					spellID = 440177,
					tip = L["BOSS免疫"],
				},
				{ -- 计时条 饥饿之嚎（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438012,
					color = {1, .44, .25},		
					text = L["全团AE"],
					count = true,
				},
				{ -- 图标 饥饿之嚎（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438012,
					hl = "",
					tip = L["DOT"],
				},
				{ -- 图标 怒不可遏（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss1",					
					spellID = 438041,
					tip = L["BOSS强化"].."%s20%",
				},
				{ -- 首领模块 准备饕餮 能量进度条（✓）
					category = "BossMod",
					spellID = 440177,
					enable_tag = "none",
					name = L["能量进度条"]..T.GetIconLink(440177),	
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 300, width = 300, height = 25},
					events = {
						["UNIT_POWER_UPDATE"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.aura_num = 0
						frame.power_value = 0
						
						local icon = C_Spell.GetSpellTexture(440177)
						frame.bar_simu = T.CreateTimerBar(frame, icon, false, false, true, nil, nil, {1, .8, 0})
						frame.bar_simu:SetAllPoints(frame)
						frame.bar_simu:SetMinMaxValues(0, 100)
						
						frame.bar = T.CreateTimerBar(frame, icon, false, false, true, nil, nil, {.26, .62, .91})
						frame.bar:SetAllPoints(frame)
						frame.bar:SetFrameLevel(frame.bar_simu:GetFrameLevel()+1)
						frame.bar:SetMinMaxValues(0, 100)
						
						function frame:update_bar()
							local simu = frame.power_value + frame.aura_num*4
							frame.bar:SetValue(frame.power_value)
							frame.bar_simu:SetValue(min(100, simu))
							frame.bar.right:SetText(string.format("%d(|cff73c8fd%d|r)", frame.power_value, simu))
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 438657 then -- 巨块脏器
								frame.aura_num = frame.aura_num + 1
								frame:update_bar()
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 438657 then -- 巨块脏器
								frame.aura_num = frame.aura_num - 1
								frame:update_bar()
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 440177 then -- 准备饕餮
								frame.bar:Show()
								frame.bar_simu:Show()
								frame:update_bar()
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 440177 then -- 准备饕餮
								frame.bar:Hide()
								frame.bar_simu:Hide()
							end
						elseif event == "UNIT_POWER_UPDATE" then
							local unit = ...
							if unit == "boss1" then
								frame.power_value = UnitPower("boss1")
								frame:update_bar()
							end
						end
					end,
					reset = function(frame, event)
						frame.aura_num = 0
						frame.power_value = 0
						frame.bar:Hide()
						frame.bar_simu:Hide()
					end,
				},
			},
		},
		{ -- 主宰冲锋
			spells = {
				{436255},
			},
			options = {
				{ -- 文字 主宰冲锋 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 1},
					preview = L["冲锋"]..L["倒计时"],
					data = {
						spellID = 436203,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						num = 0,
						sound = "[charge]",
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, cast_spellID = ...
							if unit == "raid1" then
								if cast_spellID == 436200 then
									self.data.num = 0
								elseif cast_spellID == 436203 then
									self.data.num = self.data.num + 1
									T.Start_Text_Timer(self, 3.7, string.format("|cffe32221%s %d/4|r", L["冲锋"], self.data.num), true)
								end
							end
						end
					end,
				},
				{ -- 计时条 主宰冲锋（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 436200,
					color = {.97, .52, 1},
					text = L["钻地"],
				},
				{ -- 计时条 主宰冲锋（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 436203,
					color = {.97, .52, 1},
					text = L["冲锋"].."+"..L["全团AE"],
					count = true,
					sound = "[charge]cast",
					glow = true,
				},
				{ -- 图标 主宰冲锋（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 436255,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 贪婪之裔
			npcs = {
				{28848, "0"},
			},
			options = {
				{ -- 文字 聒噪虫群 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, .86, .71},
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 445052,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},				
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_PHASE" then
							self.phase = ...
							if self.phase == 2 then
								T.Start_Text_DelayTimer(self, 7, L["召唤小怪"], true)
							end
						elseif event == "ENCOUNTER_START" then
							if not self.timer_init then
								self.round = true
								self.timer_init = true
							end
						end						
					end,
				},
				{ -- 计时条 聒噪虫群（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445052,
					color = {1, .86, .71},
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
				{ -- 图标 开膛破肚（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439037,
					hl = "",
					tip = L["DOT"],
					ficon = "13",
				},
				{ -- 图标 巨块脏器（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438657,
				},
				{ -- 首领模块 巨块脏器 多人光环（✓）
					category = "BossMod",
					spellID = 438657,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(438657)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -430},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 20
						
						frame.spellIDs = {
							[438657] = { -- 巨块脏器
								color = {.88, .58, .62},
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
		{ -- 浸透胆汁的子嗣
			npcs = {
				{30012, "12"},
			},
			options = {
				{ -- 姓名板高亮（✓）
					category = "PlateAlert",
					type = "PlateNpcID",
					mobID = "227300",
				},
			},
		},
		{ -- 噬灭黑暗
			spells = {
				{443842},
			},
			options = {
				{ -- 计时条 噬灭黑暗[音效:准备喂食]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 443842,
					color = {.46, .07, .75},
					text = L["准备喂食"],
					sound = soundfile("443842cast", "cast"),
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
					spellID = 440177,
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 445123,
				},
			},
		},
	},
}