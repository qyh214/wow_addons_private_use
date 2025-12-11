local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2584] = {
	engage_id = 2906,
	npc_id = {"215405"},
	alerts = {
		{ -- 虫群之眼
			spells = {
				{433766, "5"},
			},
			options = {
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "215405",
						ranges = {
							{ ul = 99, ll = 90, tip = L["去安全点"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 虫群之眼（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 433766,
					text = L["去安全点"],
					sound = "[gosafe]cast",
				},
			},
		},
		{ -- 沾血的网法师
			npcs = {
				{28975},
			},
			options = {
				T.Temp_ImportantInterruptBar(442210, { -- 流丝束缚（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 流丝束缚（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 442210,
					mobID = "220599",
					interrupt = 2,
					ficon = "6",
				},
				{ -- 图标 流丝束缚（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 442210,
					tip = L["DOT"].."+"..L["定身"],
					hl = "red",
				},
				{ -- 团队框架高亮 流丝束缚（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 442210,
					color = "org",
				},
			},
		},
		{ -- 感染
			spells = {
				{433740, "2"},
				{433747},
			},
			options = {
				{ -- 图标 感染（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 433740,
					hl = "gre",
					tip = L["强力DOT"],
					sound = "[defense]",
				},
				{ -- 自保技能提示 感染（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 433740,
					threshold = 65,
				},
				{ -- 团队框架高亮 感染（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 433740,
					color = "red",
				},
				{ -- 图标 无休虫群（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 433781,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 自保技能提示 无休虫群（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 433781,
					threshold = 75,
				},
				{ -- 团队框架高亮 无休虫群（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 433781,
					color = "yel",
				},
			},
		},
		{ -- 钻地冲击
			spells = {
				{433677},
			},
			options = {
				{ -- 计时条 钻地冲击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439506,
					show_tar = true,
					sound = "[charge]cast",
				},
				{ -- 对我施法图标 钻地冲击（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 439506,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
					sound = "cd3",
				},
				{ -- 首领模块 钻地冲击 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 439506,
					name = T.GetIconLink(439506)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[439506] = {		
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
				{ -- 团队框架图标 钻地冲击（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 439506,
				},
			},
		},
		{ -- 穿刺
			spells = {
				{433425},
			},
			options = {
				{ -- 计时条 穿刺（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 435012,
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
	},
}