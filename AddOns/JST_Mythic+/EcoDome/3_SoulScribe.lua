local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1303\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2677] = {
	engage_id = 3109,
	npc_id = {"234935"},
	alerts = {
		{ -- 命运低语
			spells = {
				{1224793, "5"},
				{1224865},
			},
			options = {
				{ -- 计时条 命运低语（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1224793,
					text = L["影子"],
					sound = "[shadow]cast",
				},
				{ -- 自保技能提示 命运低语（✓） 
					category = "HPWatch",
					type = "CLEU",
					spellID = 1224793,
					event = "SPELL_CAST_START",
					dur = 3,
					threshold = 70,
				},
				{ -- 图标 命缚者（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1224865,
					tip = L["增加伤害/治疗"].."%s10%",
					sound = "[sound_water]stacksfx"
				},
			},
		},
		{ -- 永恒织缕
			spells = {
				{1236703},
			},
			options = {
				{ -- 文字 永恒织缕 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 1236703,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{56.8},
									{58.4},
									{58.4},
									{58.4},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1236703, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 永恒织缕（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1236703,
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 自保技能提示 永恒织缕（✓） 
					category = "HPWatch",
					type = "CLEU",
					spellID = 1236703,
					event = "SPELL_CAST_START",
					dur = 5,
					threshold = 80,
				},
				{ -- 首领模块 计时条 永恒织缕（✓）
					category = "BossMod",
					spellID = 1236703,
					name = string.format(L["计时条%s"], T.GetIconLink(1236703)),
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						local tex = C_Spell.GetSpellTexture(1236703)
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, tex, L["躲地板"], T.GetSpellColor(1236703))
						frame.bar.count_down_start = 3
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 1236703 then
								T.StartLoopBar(frame.bar, 6, 4, true, true)
								frame.sourceGUID = sourceGUID
							elseif sub_event == "UNIT_DIED" and frame.sourceGUID == destGUID then
								T.StopTimerBar(frame.bar, true, true)
							end
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
			},
		},
		{ -- 对未知的畏惧
			spells = {
				{1225218},
			},
			options = {
				{ -- 文字 对未知的畏惧 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 1225218,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{28.7},
									{30.3},
									{30.3},
									{30.3},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1225218, L["大圈"], self, event, ...)
					end,
				},
				{ -- 计时条 对未知的畏惧（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1225218,
					text = L["分散"],
					sound = "cast,cd3",
				},
				{ -- 首领模块 对未知的畏惧 计时圆圈（✓）
					category = "BossMod",
					spellID = 1225221,
					name = T.GetIconLink(1225221)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1225221] = { -- 对未知的畏惧
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
			},
		},
		{ -- 仪式匕首
			spells = {
				{1225162},
			},
			options = {
				{ -- 文字 仪式匕首 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 1225174,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {
									{10.5, 36.5},
									{12.1, 36.5, 9.8},
									{12.1, 36.5, 9.8},
									{12.1, 36.5, 9.8},
								},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1225174, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 仪式匕首（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1225174,
					text = L["射线"],
					sound = "cast,cd3",
				},
			},
		},
		{ -- 重伤的命运
			spells = {
				{1226444},
			},
			options = {
				{ -- 图标 重伤的命运（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1226444,
					tip = L["DOT"],
				},
				{ -- 团队框架高亮 重伤的命运（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1226444,
					color = "red",
				},
			},
		},
		{ -- 命运的回响
			spells = {
				{1242000, "2"},
			},
			options = {
				
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
					spellID = 1236703, -- 永恒织缕
				},
				{
					category = "PhaseChangeData",
					phase = 1,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1236703, -- 永恒织缕
				},
			},
		},
	},
}