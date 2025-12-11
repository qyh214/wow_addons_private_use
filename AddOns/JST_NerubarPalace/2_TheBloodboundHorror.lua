local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["内场易伤"] = "内场易伤"
	L["异世之握移动计时条"] = "%s移动计时条"
else
	L["内场易伤"] = "Vulnerable"
	L["异世之握移动计时条"] = "%s timing bar"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2611] = {
	engage_id = 2917,
	npc_id = {"214502"},
	alerts = {
		{ -- 阴森呕吐
			spells = {
				{444363, "5,0"},
			},
			options = {
				{ -- 文字 阴森呕吐 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, .56, 1},
					preview = L["进入内场"]..L["倒计时"],
					data = {
						spellID = 444363,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							[15] = {
								[1] = {{16, 51},{16, 51},{16, 51},{16, 51}}
							},
							[16] = {
								[1] = {{19, 59},{19, 59},{19, 59},{19, 59}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 444363, L["进入内场"], self, event, ...)
					end,
				},
				{ -- 计时条 阴森呕吐（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 444363,
					color = {1, .56, 1},
					ficon = "0",
					text = L["进入内场"],
					count = true,
					sound = "[plane]cast",
				},
				{ -- 图标 阴森呕吐（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 443612,
					hl = "",
					tip = L["DOT"],
				},
				{ -- 首领模块 阴森呕吐 多人光环（✓）
					category = "BossMod",
					spellID = 443612,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(443612)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 10
						
						frame.spellIDs = {
							[443612] = { -- 阴森呕吐
								color = {1, .56, 1},
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
				{ -- 图标 无明凋零（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 445570,
					tip = L["内场易伤"],
				},
			},
		},
		{ -- 失落的观察者 被遗忘的末日使者 鲜血恐魔
			npcs = {
				{29072},
				{29075, "1"},
				{29077},
			},
			options = {
				{ -- 首领模块 小怪血量（✓）
					category = "BossMod",
					spellID = 462306,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("221667")..T.GetFomattedNameFromNpcID("221945")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["221667"] = {color = {.69, .45, .62}}, -- 失落的观察者
							["221945"] = {color = {.7, .56, .83}}, -- 被遗忘的末日使者
						}
 
						T.InitMobHealth(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobHealth(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobHealth(frame)
					end,
				},
				{ -- 姓名板施法图标 黑暗壁垒（✓）
					category = "PlateAlert",
					type = "PlateSpells",
					spellID = 451288,
					ficon = "6",
					hl_np = true,
				},
				{ -- 对我施法图标 幽灵猛击（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 445016,
					hl = "yel_flash",
				},
			},
		},
		{ -- 血液凝阻
			spells = {
				{452237, "12"},
			},
			options = {
				{ -- 文字 血液凝阻 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {.78, .03, .04},
					preview = L["分散"]..L["倒计时"],
					data = {
						spellID = 452237,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							[16] = {
								[1] = {{9, 32, 27, 32},{9, 32, 27, 32},{9, 32, 27, 32},{9, 32, 27, 32}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 452237, L["分散"], self, event, ...)
					end,
				},
				{ -- 计时条 血液凝阻（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 452237,
					color = {.78, .03, .04},
					ficon = "12",
					sound = "[spread]cast",
				},
				{ -- 图标 血液凝阻（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 452245,
					hl = "",
					tip = L["分散"],
				},
				{ -- 血液凝阻 计时圆圈（✓）
					category = "BossMod",
					spellID = 452245,
					enable_tag = "none",
					name = T.GetIconLink(452245)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[452245] = { -- 血液凝阻
								event = "SPELL_CAST_START",
								dur = 7,
								color = {.78, .03, .04},
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
			},
		},
		{ -- 呕吐出血
			spells = {
				{445936, "4"},
			},
			options = {
				{ -- 文字 呕吐出血 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.17, .04, .94},
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 445936,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							[15] = {
								[1] = {{32, 49},{32, 49},{32, 49},{32, 49}}
							},
							[16] = {
								[1] = {{37, 59},{37, 59},{37, 59},{37, 59}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 445936, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 呕吐出血（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445936,
					color = {.17, .04, .94},
					ficon = "4",
					text = L["射线"],
					sound = "[ray]cast",
					glow = true,
				},
				{ -- 计时条 呕吐出血（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 445936,
					dur = 21,
					color = {.17, .04, .94},
					text = L["射线"],
				},
			},
		},
		{ -- 瘀液喷撒
			spells = {
				{442530, "4,2"},
			},
			options = {
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "214502",
						ranges = {
							{ ul = 99, ll = 95, tip = L["阶段转换"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 瘀液喷撒（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 442530,
					color = {.5, .12, .97},
					ficon = "4",
					text = L["远离"],
					sound = "[away]cast,cd3",
					glow = true,
				},
				{ -- 图标 瘀液喷撒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 442604,
					hl = "",
					tip = L["DOT"],
				},
				{ -- 图标 黑血（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 445518,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 渗流灌注（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss1",					
					spellID = 461876,
					tip = L["BOSS强化"].."%s10%",
				},
			},
		},
		{ -- 猩红之雨
			spells = {
				{443305, "2"},
			},
			options = {
				{ -- 文字 猩红之雨 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "2",
					color = {.67, .23, .14},
					preview = L["吸收盾"]..L["倒计时"],
					data = {
						spellID = 443203,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							["all"] = {
								[1] = {{11},{11},{11},{11}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 443203, L["吸收盾"], self, event, ...)
					end,
				},
				{ -- 图标 猩红之雨（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443305,
					effect = 1,
					hl = "gre",
					tip = L["吸收治疗"],
				},
				{ -- 首领模块 团队吸收量计时条（✓）
					category = "BossMod",
					spellID = 443305,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环数值提示"], L["吸收治疗"]),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 8
						
						frame.spellIDs = {
							[443305] = { -- 猩红之雨 196w
								aura_type = "HARMFUL",
								color = {.67, .23, .14},
								effect = 1,
								progress_value = 2000000,
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
		{ -- 异世之握
			spells = {
				{443042},
			},
			options = {
				{ -- 图标 异世之握（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443042,
					hl = "org",
					tip = L["锁定"],
					msg = {str_applied = "%name %spell"},
				},
				{ -- 计时条 异世之握（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 443042,
					dur = 15,
					tags = {4},
					target_me = true,
					color = {1, 1, 0},					
					text = L["锁定"],
				},
				{ -- 首领模块 异世之握 分段计时条（?）
					category = "BossMod",
					spellID = 443042,
					enable_tag = "none",
					name = string.format(L["异世之握移动计时条"], T.GetIconLink(443042)),	
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = 50, width = 100, height = 20},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						local icon = C_Spell.GetSpellTexture(443042)
						frame.bar = T.CreateTimerBar(frame, icon, false, true, true)
						frame.bar:SetAllPoints(frame)
						frame.bar:Hide()
						
						function frame.bar:OnLoop()
							frame.ind = frame.ind + 1
							self.left:SetText(frame.ind.."/13")
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and destGUID == G.PlayerGUID and spellID == 443042 then
								frame.ind = 1
								frame.bar.left:SetText(frame.ind.."/13")
								frame.bar:SetStatusBarColor(1, .7, .1)
								T.StartTimerBar(frame.bar, 4, true, true)
								
								C_Timer.After(4, function()
									frame.ind = 2
									frame.bar.left:SetText(frame.ind.."/13")
									frame.bar:SetStatusBarColor(1, 0, 0)
									T.StartLoopBar(frame.bar, 1, 12, true, true)
								end)
							end
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
			},
		},
		{ -- 黑脓败血
			spells = {
				{438696, "4"},
			},
			options = {
				{ -- 文字 黑脓败血 近战位无人提示（✓）
					category = "TextAlert",
					ficon = "0",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(438679)..L["近战无人"],
					data = {
						spellID = 438679,
						events = {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 438679 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(438679)..L["近战无人"])
							end
						end
					end,
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
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 442530,
				},
			},
		},
	},
}