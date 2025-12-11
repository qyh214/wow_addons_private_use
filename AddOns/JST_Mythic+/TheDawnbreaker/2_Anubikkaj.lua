local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2581] = {
	engage_id = 2838,
	npc_id = {"211089"},
	alerts = {
		{ -- 恐惧猛击
			spells = {
				{427001, "0"},
			},
			options = {
				{ -- 文字 恐惧猛击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = L["击飞"]..L["倒计时"],
					data = {
						spellID = 427001,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {15.0, 34.6, 27.0, 23.6, 27.0, 34.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 427001, L["击飞"], self, event, ...)
					end,
				},
				{ -- 计时条 恐惧猛击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 427001,
					text = L["大圈"],
					sound = "[outcircle]cast,notank",
				},
				{ -- 首领模块 恐惧猛击 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 427001,
					name = T.GetIconLink(427001)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[427001] = {		
								color = {1, 1, 0},
							},
						}
						T.InitCircleCastTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleCastTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleCastTimers(frame)
					end,
				},
			},
		},
		{ -- 晦影腐朽
			spells = {
				{426787, "2"},
			},
			options = {
				{ -- 文字 晦影腐朽 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 426787,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {22.0, 34.6, 43.6, 41.6, 34.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 426787, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 晦影腐朽（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426787,
					group = 1,
					text = L["全团AE"],
					glow = true,
					sound = "[aoe]cast",
				},
				{ -- 自保技能提示 晦影腐朽（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 426787,
					event = "SPELL_CAST_START",
					dur = 7,
					threshold = 65,
				},
			},
		},
		{ -- 活化暗影
			spells = {
				{452127},
			},
			options = {
				{ -- 文字 活化暗影 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 452127,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {33.0, 43.6, 41.6, 50.6},		
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							mute_count_down = true,
							prepare_sound = "getnear",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 452127, L["召唤小怪"], self, event, ...)
					end,
				},
				{ -- 计时条 活化暗影（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 452127,
					text = L["召唤小怪"],
					sound = "[add]cast",
					show_tar = true,
				},
				{ -- 对我施法图标 活化暗影（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 452127,
					hl = "yel_flash",
					tip = L["召唤小怪"],
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
			},
		},
		{ -- 活化黑暗:凝结黑暗
			npcs = {
				{2975},
			},
			spells = {
				{452099},
			},
			options = {
				T.Temp_SubInterruptBar(452099, { -- 凝结暗影（✓）
					show_tar = true,
					ficon = "14",
				}),
				{ -- 对我施法图标 凝结暗影（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 452099,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 凝结暗影（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 452099,
				},
			},
		},
		{ -- 暗黑法球
			spells = {
				{426860},
			},
			options = {
				{ -- 文字 暗黑法球 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(426860)..L["倒计时"],
					data = {
						spellID = 426860,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {6.0, 34.6, 27.0, 23.6, 34.6, 27.0, 34.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 426860, T.GetIconLink(426860), self, event, ...)
					end,
				},
				{ -- 计时条 暗黑法球（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 426860,
					show_tar = true,
					sound = "[ball]cast",
				},
				{ -- 对我施法图标 暗黑法球（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 426860,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
					sound = "cd3",
				},
				{ -- 首领模块 暗黑法球 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 426860,
					name = T.GetIconLink(426860)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[426860] = {		
								color = {1, 1, 0},
							},
						}
						T.InitCircleCastTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleCastTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleCastTimers(frame)
					end,
				},
				{ -- 图标 黑暗伤痕（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 427378,
					tip = L["强力DOT"],
					sound = "[defense]",
				},
				{ -- 团队框架高亮 黑暗伤痕（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 427378,
					color = "red",
				},
			},
		},
	},
}