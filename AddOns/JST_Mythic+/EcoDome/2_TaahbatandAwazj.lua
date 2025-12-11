local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1303\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2676] = {
	engage_id = 3108,
	npc_id = {"237514", "234933"},
	alerts = {
		{ -- 奥术突袭
			spells = {
				{1219700, "5"},
			},
			options = {
				{ -- 文字 奥术突袭 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["阶段转换"]..L["倒计时"],
					data = {
						spellID = 1219700,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{33.9},
									{78.4},
									{78.4},
									{78.4},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1219700, L["阶段转换"], self, event, ...)
					end,
				},
				{ -- 计时条 奥术突袭（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1219700,
					text = L["阶段转换"],
				},
			},
		},
		{ -- 塔尔·巴特:虚体
			npcs = {
				{31231},
			},
			spells = {
				{1219457},
				{1219731},
			},
			options = {
				{ -- 图标 虚体（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss",
					spellID = 1219457,
					tip = L["BOSS免疫"],
				},
				{ -- 文字 虚体 层数提示（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetSpellIcon(1219457).."1/5",
					data = {
						spellID = 1219457,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_REMOVED" and spellID == 1219457 then
								T.Start_Text_Timer(self, 2, L["阶段转换"])
							elseif sub_event == "SPELL_AURA_REMOVED_DOSE" and spellID == 1219457 then
								T.Start_Text_Timer(self, 2, T.GetSpellIcon(1219457)..string.format(" %d/5", amount))
							end
						end
					end,
				},
				{ -- 计时条 动荡能量（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss1",
					spellID = 1219731,
					text = L["昏迷"],
				},
			},
		},
		{ -- 塔尔·巴特:奥术超载
			npcs = {
				{31231},
			},
			spells = {
				{1220497, "2"},
			},
			options = {
				{ -- 计时条 奥术超载（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1220511,
					text = L["全团AE"],
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 阿瓦兹吉:迁跃打击
			npcs = {
				{31585},
			},
			spells = {
				{1227137, "2"},
			},
			options = {
				{ -- 计时条 迁跃打击（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227142,
					text = L["冲锋"],
					sound = "[chargetoyou]cast,cd3",
				},
				{ -- 首领模块 迁跃打击 计时圆圈（✓）
					category = "BossMod",
					spellID = 1227142,
					name = T.GetIconLink(1227142)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1227142] = { -- 迁跃打击
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
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
				{ -- 图标 迁跃打击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227152,
					tip = L["DOT"],
					hl = "red",
				},
				{ -- 自保技能提示 迁跃打击（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1227152,
					threshold = 65,
					amount = 2,
				},
				{ -- 文字 迁跃打击 层数提示（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetSpellIcon(1227152).." 2 "..L["注意自保"],
					data = {
						spellID = 1227152,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APLLIED_DOSE" and spellID == 1227152 and destGUID == G.PlayerGUID then
								T.Start_Text_Timer(self, 2, T.GetSpellIcon(1227152).." "..amount.." "..L["注意自保"])
								T.PlaySound("count\\"..amount)
							end
						end
					end,
				},
				{ -- 团队框架高亮 迁跃打击（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1227152,
					color = "red",
					amount = 2,
				},
			},
		},
		{ -- 束缚的标枪
			spells = {
				{1219536, "1"},
			},
			options = {
				{ -- 文字 束缚的标枪 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1236130)..L["倒计时"],
					data = {
						spellID = 1236130,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{10.8},
									{30.0, 26.6},
									{30.4, 26.2},
									{30.4, 26.2},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1236130, T.GetIconLink(1236130), self, event, ...)
					end,
				},
				{ -- 计时条 束缚的标枪（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1236130,
					sound = "[rescue]cast",
				},
				{ -- 首领模块 束缚的标枪 计时圆圈（✓）
					category = "BossMod",
					spellID = 1236126,
					name = T.GetIconLink(1236126)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1236126] = { -- 束缚的标枪
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
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
				{ -- 团队框架高亮 束缚的标枪（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1236126,
					color = "yel",
				},
				{ -- 图标 束缚的标枪（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1220671,
					tip = L["DOT"].."+"..L["减速"].."50%",
					hl = "org",
				},
				{ -- 自保技能提示 束缚的标枪（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1220671,
					threshold = 65,
				},
				{ -- 团队框架高亮 束缚的标枪（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1220671,
					color = "org",
				},
			},
		},
		{ -- 迁跃打击
			spells = {
				{1220386, "2"},
			},
			options = {
				{ -- 计时条 迁跃打击（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1220427,
					text = L["冲锋"],
					show_tar = true,
					sound = "[mindcharge]cast,cd3",
				},
				{ -- 首领模块 迁跃打击 计时圆圈（✓）
					category = "BossMod",
					spellID = 1220427,
					name = T.GetIconLink(1220427)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1220427] = { -- 迁跃打击
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
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
				{ -- 图标 迁跃打击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1220390,
					tip = L["DOT"],
					hl = "red",
				},
				{ -- 团队框架高亮 迁跃打击（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1220390,
					color = "red",
				},
			},
		},
		{ -- 裂隙利爪
			spells = {
				{1219482, "0"},
			},
			options = {
				{ -- 文字 裂隙利爪 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(1219482)..L["倒计时"],
					data = {
						spellID = 1219482,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{5.1, 23.9},
									{23.9, 24.3, 26.7},
									{23.9, 24.2, 26.7},
									{23.9, 24.2, 26.7},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1219482, T.GetIconLink(1219482), self, event, ...)
					end,
				},
				{ -- 打坦计时条 裂隙利爪（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1219482,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 图标 裂隙利爪（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1219535,
					tip = L["DOT"],
					hl = "red",
					ficon = "13",
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
					spellID = 1219700, -- 奥术突袭
				},
				{
					category = "PhaseChangeData",
					phase = 1,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1220511, -- 奥术超载
				},
			},
		},
	},
}