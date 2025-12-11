local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2580] = {
	engage_id = 2837,
	npc_id = {"211087"},
	alerts = {
		{ -- 黑暗降临
			spells = {
				{451026, "4"},
			},
			options = {
				{ -- 血量（✓）
					category = "TextAlert",
					type = "hp",
					data = {
						npc_id = "211087",
						ranges = {
							{ ul = 55, ll = 51, tip = L["阶段转换"]..string.format(L["血量2"], 50)},
						},
					},	
				},
				{ -- 计时条 黑暗降临（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451026,
					color = {1, 0, 0},
					text = L["远离"],
					sound = "[away]cast,cd3",
				},
				{ -- 图标 光芒四射（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449042,	
					tip = L["可以飞"],
				},
			},
		},
		{ -- 黑曜光束
			spells = {
				{453212},
			},
			options = {
				{ -- 文字 黑曜光束 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 453212,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {9.5, 32.4, 25.4},
								[2] = {32.9, 25.5, 25.3, 25.4},					
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 453212, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 黑曜光束（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 453212,
					text = L["射线"],
					sound = "[ray]cast,cd3",
					glow = true,
					group = 1,
				},
			},
		},
		{ -- 塌缩之夜
			spells = {
				{453140},
			},
			options = {
				{ -- 文字 塌缩之夜 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 453140,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {25.7, 28.3, 25.4},
								[2] = {23.7, 29.1, 25.3, 25.4},						
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							mute_count_down = true,
							prepare_sound = "spread",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 453140, L["大圈"], self, event, ...)
					end,
				},
				{ -- 计时条 塌缩之夜（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 453140,
					sound = "[mindstep]cast",
					glow = true,
					group = 1,
				},
				{ -- 图标 塌缩之夜（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 453173,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 燃烧之影
			spells = {
				{426734, "2,7"},
			},
			options = {				
				{ -- 文字 燃烧之影 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "2",
					preview = L["驱散"]..L["倒计时"],
					data = {
						spellID = 426734,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {21.5, 16.3, 22.4},
								[2] = {29.3, 19.8, 22.6, 22.8},							
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 426734, L["驱散"], self, event, ...)
					end,
				},
				{ -- 计时条 燃烧之影（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426734,
					ficon = "7",
				},
				{ -- 驱散提示音 燃烧之影（✓）
					category = "Sound",
					sub_event = "SPELL_CAST_START",
					spellID = 426734,
					file = "[prepare_dispel]",
					ficon = "7",
				},
				{ -- 图标 燃烧之影（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426735,
					hl = "blu",
					tip = L["减速"].."+"..L["DOT"],
					ficon = "7",
				},
				{ -- 团队框架高亮 燃烧之影（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 426735,
					color = "blu",
				},
				{ -- 图标 暗影之幕（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 426736,
					effect = 1,
					tip = L["吸收治疗"],
				},
				{ -- 首领模块 暗影之幕 团队框架吸收治疗数值（✓）
					category = "BossMod",
					spellID = 426736,
					ficon = "2",
					enable_tag = "role",
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
		{ -- 暗影箭
			spells = {
				{428086, "6"},
			},
			options = {
				T.Temp_NormalInterruptBar(428086, { -- 暗影箭（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 暗影箭（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 428086,
					mobID = "211087",
					interrupt = 3,
					ficon = "6",
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
					spellID = 451026, -- 黑暗降临
				},				
			},
		},
	},
}