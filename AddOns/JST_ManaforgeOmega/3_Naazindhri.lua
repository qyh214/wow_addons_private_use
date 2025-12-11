local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then

elseif G.Client == "ruRU" then

else

end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2685] = {
	engage_id = 3130,
	npc_id = {"233816"},
	alerts = {
		{ -- 灵魂召唤
			spells = {
				{1225582, "5"},--【灵魂召唤】
				{1239988},--【魂织】
			},
			options = {
				{ -- 计时条 灵魂召唤（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1225582,
					sound = "[phase]cast",
				},
			},
		},
		{ -- 无缚刺客
			npcs = {
				{32044},--【影卫刺客】
			},
			spells = {
				--{1227048},--【虚空剑士奇袭】
			},
			options = {
				{ -- 图标 虚空剑士奇袭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227049,
					text = L["分散"],
					hl = "org",
				},
				{ -- 图标 虚空剑士奇袭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227051,
					tip = L["DOT"],
				},
				{ -- 首领模块 虚空剑士奇袭 计时圆圈（✓）
					category = "BossMod",
					spellID = 1227049,
					name = T.GetIconLink(1227049)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1227049] = { -- 虚空剑士奇袭
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .15, .35},
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
			},
		},
		{ -- 无缚法师
			npcs = {
				{32710},--【影卫法师】
			},
			spells = {
				--{1227052},--【虚空爆炸】
			},
			options = {
				{ -- 图标 虚空爆炸（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227052,
					ficon = "7",
					tip = L["DOT"],
					hl = "blu",
				},
				{ -- 团队框架高亮 虚空爆炸（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1227052,
					color = "blu",
					amount = 2,
				},
				{ -- 驱散提示音 虚空爆炸（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1227052,
					file = "[dispel]",
					ficon = "7",
					amount = 2,
				},
				{ -- 自保技能提示 虚空爆炸（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1227052,
					threshold = 65,
					amount = 3,
				},				
			},
		},
		{ -- 无缚相位剑士
			npcs = {
				{32045},--【影卫相位剑士】
			},
			spells = {
				--{1242018, "12"},--【虚空共鸣】
				--{1235576, "1"},--【相位之刃】
			},
			options = {
				{ -- 姓名板光环 虚空共鸣（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1242021,
				},
			},
		},
		{ -- 精华内爆
			spells = {
				{1227848, "2"},--【精华内爆】
			},
			options = {
				{ -- 文字 精华内爆 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1227848)..L["倒计时"],
					data = {
						spellID = 1227848,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},	
						info = {19.7, 37.3, 37.0, 12.1},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true							
							self.last_cast = 0
						elseif event == "ENCOUNTER_PHASE" then	
							self.next_count = 1
							local dur = self.data.info[self.next_count]
							if dur then
								T.Start_Text_DelayTimer(self, dur, L["全团AE"], true)
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 1227848 then
								if GetTime() - self.last_cast > 3 then
									self.last_cast = GetTime()
									self.next_count = self.next_count + 1
									local dur = self.data.info[self.next_count]
									if dur then
										T.Start_Text_DelayTimer(self, dur, L["全团AE"], true)
									end
								end
							end
						end
					end,
				},
			},
		},		
		{ -- 笞魂歼灭
			spells = {
				{1227276, "4"},--【笞魂歼灭】
			},
			options = {
				{ -- 计时条 笞魂歼灭（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 1227276,
					dur = 6,
					text = L["射线"],
				},
				{ -- 首领模块 笞魂歼灭 计时圆圈（✓）
					category = "BossMod",
					spellID = 1227276,
					name = T.GetIconLink(1227276)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1227276] = { -- 笞魂歼灭
								unit = "player",
								aura_type = "HARMFUL",
								color = {.9, .31, 1},
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
				{ -- 首领模块 笞魂歼灭 点名统计 整体排序（待测试）
					category = "BossMod",
					spellID = 1227277,
					enable_tag = "spell",
					name = string.format(L["NAME点名排序"], T.GetIconLink(1227276)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1227276
						frame.element_type = "bar"
						frame.color = {.9, .31, 1}
						frame.raid_glow = "pixel"
						frame.disable_copy_mrt = true
						
						frame.info = {
							{text = L["左"], msg_applied = L["左"].."%name", msg = L["左"]},
							{text = L["右"], msg_applied = L["右"].."%name", msg = L["右"]},
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
				{ -- 图标 笞魂歼灭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227277,
					tip = L["易伤"].."15%",
				},
			},
		},
		{ -- 奥术符印
			spells = {
				{1246530, "12"},--【奥术符印】
				--{1246775},--【碎裂脉冲】
			},
			options = {
				{ -- 图标 碎裂脉冲（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1250008,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],
				},
				{ -- 首领模块 碎裂脉冲 团队框架吸收治疗数值（✓）
					category = "BossMod",
					spellID = 1250008,
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
		{ -- 奥术驱除
			spells = {
				{1242088},--【奥术驱除】
				--{1242086},--【奥术能量】
			},
			options = {
				{ -- 文字 奥术驱除 倒计时（史诗待测试）
					category = "TextAlert",
					type = "spell",
					preview = L["击飞"]..L["倒计时"],
					data = {
						spellID = 1242088,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[2] = {37, 40, 64},
								[3] = {37, 40, 64},
								[4] = {37, 40, 64},
							},
							[16] = {
								[2] = {28.0, 38.0, 67.0},
								[3] = {28.0, 38.0, 67.1},
								[4] = {28.1, 37.9, 67.4},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 5,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1242088, L["击飞"], self, event, ...)
					end,
				},
				{ -- 计时条 奥术驱除（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1242088,
					text = L["击飞"],
					glow = true,
					group = 1,
					sound = "[knockoff]cast",
				},
				{ -- 图标 奥术驱除（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1242088,
					tip = L["DOT"],
					hl = "org",
				},
				{ -- 图标 奥术驱除（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1242071,
					tip = L["DOT"],
				},
				{ -- 自保技能提示 奥术驱除（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 1242088,
					event = "SPELL_CAST_START",
					dur = 6,
					threshold = 65,
				},
				{ -- 图标 奥术能量（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1242086,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 魂火汇聚
			spells = {
				{1225616},--【魂火汇聚】
				{1226827},--【碎魂法球】
			},
			options = {
				{ -- 计时条 魂火汇聚（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1225616,
				},
				{ -- 计时条 魂火汇聚（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 1225616,
					dur = 9,
					tags = {6, 7, 8},
					text = L["宝珠"],
				},
				{ -- 首领模块 魂火汇聚 点名统计 逐个填坑（待测试）
					category = "BossMod",
					spellID = 1225616,
					enable_tag = "spell",
					name = string.format(L["NAME点名排序"], T.GetIconLink(1249065)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1249065
						frame.element_type = "bar"
						frame.color = T.GetSpellColor(1249065)
						frame.role = true
						frame.raid_index = true
						frame.disable_copy_mrt = true							
						
						frame.info = {
							{text = L["左"], msg_applied = L["左"].."%name"},
							{text = L["左"], msg_applied = L["左"].."%name"},
							{text = L["右"], msg_applied = L["右"].."%name"},
							{text = L["右"], msg_applied = L["右"].."%name"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 9, self.info[index].text)
								C_Timer.After(4, function()
									if index <= 2 then
										T.SendChatMsg(L["左"], 4)
									else
										T.SendChatMsg(L["右"], 4)
									end
								end)
							end
						end
						
						function frame:post_remove(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Stop_Text_Timer(self.text_frame)
							end
						end
						
						T.InitAuraMods_ByTime(frame)
					end,
					update = function(frame, event, ...)			
						T.UpdateAuraMods_ByTime(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByTime(frame)
					end,
				},
				{ -- 首领模块 魂火汇聚 计时圆圈（待测试）
					category = "BossMod",
					spellID = 1249065,
					name = T.GetIconLink(1249065)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1249065] = { -- 魂火汇聚
								unit = "player",
								aura_type = "HARMFUL",
								color = {.07, 1, 1},
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
				{ -- 团队框架高亮 魂火汇聚（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1249065,
				},
				{ -- 图标 碎魂法球（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1226827,
					tip = L["减速"],
				},
				{ -- 团队框架高亮 碎魂法球（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1226827,
				},
			},
		},
		{ -- 法术燃烧
			spells = {
				{1240754, "2"},--【法术燃烧】
			},
			options = {
				
			},
		},
		{ -- 秘法鞭笞
			spells = {
				{1241100, "0"},--【秘法鞭笞】
			},
			options = {
				{ -- 计时条 秘法鞭笞（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1241100,
					ficon = "0",
					show_tar = true,
					sound = soundfile("1241100cast", "cast"),
				},
				{ -- 嘲讽提示 秘法鞭笞（待测试）
					category = "BossMod",
					spellID = 1237607,
					ficon = "0",				
					name = L["嘲讽提示"]..T.GetIconLink(1237607),
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
							[1237607] = 6, -- 秘法鞭笞
						}
						frame.cast_spellIDs = {
							[1241100] = true, -- 秘法鞭笞
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
				{ -- 换坦计时条 秘法鞭笞（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1237607,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
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
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1225582, -- 灵魂召唤
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1225582, -- 灵魂召唤
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 4,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1225582, -- 灵魂召唤
					count = 3,
				},
			},
		},
	},
}