local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1267\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2573] = {
	engage_id = 2848,
	npc_id = {"207940"},
	alerts = {
		{ -- 圣光屏障
			spells = {
				{423588, "5"},
			},
			options = {				
				{ -- 吸收盾 圣光屏障（✓）
					category = "BossMod",
					spellID = 423588,
					name = string.format(L["NAME吸收盾"], T.GetIconLink(423588)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 423588 -- 圣光屏障
						frame.aura_type = "HELPFUL"
						frame.effect = 1
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
				{ -- 图标 拥抱圣光（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 423665,
					tip = L["BOSS强化"],
				},
			},
		},
		{ -- 净涤
			spells = {
				{444546},
			},
			options = {
				{ -- 计时条 净涤（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 444546,
					text = L["射线"],
					sound = "[ray]cast",
				},
				{ -- 团队框架图标 纯洁圣光（✓）
					category = "RFIcon",
					type = "Msg",
					spellID = 425556,
					boss_msg = "425556",
					dur = 7,
				},
				{ -- BOSS喊话 纯洁圣光（✓）
					category = "AlertIcon",
					type = "bmsg",
					spellID = 425556,
					event = "CHAT_MSG_RAID_BOSS_WHISPER",
					boss_msg = "425556",
					hl = "org_flash",
					dur = 7,
					sound = "[run]cd3",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				},
				{ -- 首领模块 纯洁圣光 点名密语计时圆圈（✓）
					category = "BossMod",
					spellID = 425556,
					name = T.GetIconLink(425556)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["CHAT_MSG_RAID_BOSS_WHISPER"] = true,
					},
					init = function(frame)
						frame.keywords = {
							["425556"] = {
								color = {1, 1, 0},
								dur = 7,
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
				{ -- 图标 神圣之地（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 425556,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 盲目之光
			spells = {
				{428169},
			},
			options = {
				{ -- 计时条 盲目之光（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 428169,
					text = L["背对BOSS"],
					sound = "[backto]cast,cd3",
					glow = true,
					group = 1,
				},
				{ -- 自保技能提示 盲目之光（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 428169,
					event = "SPELL_CAST_START",
					dur = 4,
					threshold = 75,
				},
				{ -- 图标 盲目之光（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 428170,
					hl = "blu",
					tip = L["强力DOT"],
					ficon = "7",
				},
				{ -- 驱散提示音 盲目之光（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 428170,
					file = "[dispel]",
					ficon = "7",
				},
				{ -- 团队框架高亮 盲目之光（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 428170,
					color = "blu",
				},
			},
		},
		{ -- 心灵之火
			spells = {
				{423539, "2"},
			},
			options = {
				{ -- 计时条 心灵之火（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 444608,
					text = L["BOSS强化"],
					sound = "[heal]cast",
				},
				{ -- 图标 心灵之火（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 444608,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 神圣烈焰
			spells = {
				{451606, "7"},
			},
			options = {
				{ -- 计时条 神圣烈焰（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451605,
					sound = "[outcircle]cast",
				},
				{ -- 图标 神圣烈焰（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451606,
					hl = "blu",
					tip = L["强力DOT"],
					ficon = "7",
				},
				{ -- 驱散提示音 神圣烈焰（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 451606,
					file = "[dispel]",
					ficon = "7",
				},
				{ -- 团队框架高亮 神圣烈焰（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 451606,
					color = "blu",
				},
			},
		},
		{ -- 神圣惩击
			spells = {
				{423536, "6"},
			},
			options = {
				T.Temp_NormalInterruptBar(423536, { -- 神圣惩击（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 神圣惩击（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 423536,
					mobID = "207940",
					interrupt = 3,
					ficon = "6",
				},
				{ -- 团队框架图标 神圣惩击（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 423536,
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {				
				{
					category = "PhaseChangeData",
					phase = 1.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 423588, -- 圣光屏障
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 423588, -- 圣光屏障
				},
			},
		},
	},
}