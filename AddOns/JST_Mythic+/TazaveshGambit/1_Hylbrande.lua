local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2448] = {
	engage_id = 2426,
	npc_id = {"175663"},
	alerts = {
		{ -- 净化爆发
			spells = {
				{353312},
			},
			options = {
				{ -- 计时条 净化爆发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 353312,
					group = 1,
					glow = true,
					sound = "[minddefense]cast,notank",
				},
				{ -- 自保技能提示 净化爆发（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 353312,
					event = "SPELL_CAST_START",
					dur = 3,
					threshold = 65,
				},
			},
		},
		{ -- 剪切挥舞
			spells = {
				{346116, "0"},
			},
			options = {
				{ -- 文字 剪切挥舞 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(346116)..L["倒计时"],
					data = {
						spellID = 346116,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{9.6, 10.9, 12.1},
									{15.9, 11.0, 12.1, 11.0, 12.1},
									{16.5, 10.9, 10.9, 11.0, 10.9},
									{16.1, 10.9, 10.9, 11.0, 10.9},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 346116, T.GetIconLink(346116), self, event, ...)
					end,
				},
				{ -- 打坦计时条 剪切挥舞（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 346116,
					group = 1,
					ficon = "0",
					sound = "[minddefense]channel",
				},
			},
		},
		{ -- 泰坦粉碎
			spells = {
				{347094},
			},
			options = {
				{ -- 计时条 泰坦粉碎（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 347094,
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 火焰净除
			spells = {
				{346959},
			},
			options = {
				{ -- 团队框架图标 火焰净除（✓）
					category = "RFIcon",
					type = "Msg",
					spellID = 346959,
					boss_msg = "346959",
					dur = 9,
				},
				{ -- BOSS喊话 火焰净除（✓）
					category = "AlertIcon",
					type = "bmsg",
					spellID = 346959,
					event = "CHAT_MSG_RAID_BOSS_WHISPER",
					boss_msg = "346959",
					hl = "org_flash",
					dur = 9,
					sound = "[fixate]cd3",
					msg = {str_applied = "%name %spell", str_rep = "{rt1}%dur"},
				},
				{ -- 首领模块 火焰净除 点名密语计时圆圈（✓）
					category = "BossMod",
					spellID = 346959,
					name = T.GetIconLink(346959)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["CHAT_MSG_RAID_BOSS_WHISPER"] = true,
					},
					init = function(frame)
						frame.keywords = {
							["346959"] = {
								color = {1, 1, 0},
								dur = 9,
							},
						}
						
						T.InitCircleMsgTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleMsgTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleMsgTimers(frame)
					end,
				},
				{ -- 图标 净化之地（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 346961,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 定期消毒
			spells = {
				{346766},
			},
			options = {
				{ -- 文字 定期消毒 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["阶段转换"]..L["倒计时"],
					data = {
						spellID = 346766,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{37.8},
									{69.6},
									{70.1},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 346766, L["阶段转换"], self, event, ...)
					end,
				},
				{ -- 计时条 定期消毒（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 346766,
					dur = 2,
					sound = "[phase]cast",
				},
				{ -- 图标 消毒区域（缺数据）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 346828,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 文字提示 泰坦洞察（✓）
					category = "TextAlert", 
					type = "spell",
					preview = T.GetIconLink(346427),
					data = {
						spellID = 346427,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
						},
						sound = "transport",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 346427 then
								local name = T.ColorNickNameByGUID(sourceGUID) or sourceName
								T.Start_Text_Timer(self, 3, name.." "..T.GetIconLink(346427))
								
								if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
									T.PlaySound("transport")
								end
							end
						end
					end,
				},
				{ -- 图标 旁路代码：摩尔科 福莱瑟 赫尔威提 里斯（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 348451,
					spellIDs = {348450, 348437, 348447},
					options_spellIDs = {348451, 348450, 348437, 348447},
				},
				{ -- 计时条 旁路代码：摩尔科 福莱瑟 赫尔威提 里斯（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 348451,
					spellIDs = {348450, 348437, 348447},
					show_tar = true,
					text = L["符文"],
					force_full = true,
					options_spellIDs = {348451, 348450, 348437, 348447},
					color = {1, 1, 1},
				},
			},
		},
		{ -- 宝库净化者:强化防御
			npcs = {
				{23004, "1"},
			},
			spells = {
				{347015},
			},
			options = {
				{ -- 图标 强化防御（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 347015,
					tip = L["BOSS减伤"].."%s25%"
				},
			},
		},
		{ -- 宝库净化者:守护者防御
			npcs = {
				{23004, "1"},
			},
			spells = {
				{347958},
			},
			options = {
				
			},
		},
		{ -- 宝库净化者:英勇冲击
			npcs = {
				{23004, "1"},
			},
			spells = {
				{352347},
			},
			options = {
				{ -- 首领模块 标记 宝库净化者（✓）
					category = "BossMod",
					spellID = 352347,
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("176551"), T.FormatRaidMark("5,6")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "only_rl_bool", 
							text = L["当队长时标记"],
							default = true,
						},
					},
					init = function(frame)
						frame.start_mark = 5
						frame.end_mark = 6
						frame.mob_npcID = "176551"
						
						function frame:trigger(unit, GUID)
							if not C.DB["BossMod"][self.config_id]["only_rl_bool"] or UnitLeadsAnyGroup("player") then
								return true
							end
						end
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateRaidTarget(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				T.Temp_NormalInterruptBar(352347, { -- 英勇冲击（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 英勇冲击（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 352347,
					mobID = "176551",
					interrupt = 2,
					ficon = "6",
				},
				{ -- 对我施法图标 英勇冲击（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 352347,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 英勇冲击（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 352347,
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
					sub_event = "SPELL_CAST_START",
					spellID = 346766, -- 定期消毒
				},
				{
					category = "PhaseChangeData",
					phase = 1,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 346766, -- 定期消毒 
				},
			},
		},
	},
}