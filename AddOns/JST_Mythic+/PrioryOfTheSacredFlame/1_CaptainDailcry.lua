local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1267\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2571] = {
	engage_id = 2847,
	npc_id = {"207946"},
	alerts = {
		{ -- 野蛮重殴
			spells = {
				{447439, "5"},
			},
			options = {
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "207946",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(447439)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 吸收盾 野蛮重殴（✓）
					category = "BossMod",
					spellID = 447443,
					name = string.format(L["NAME吸收盾"], T.GetIconLink(447443)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 447443 -- 野蛮重殴
						frame.aura_type = "HARMFUL"
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
				{ -- 图标 野蛮重殴（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 447439,
					hl = "org",
					tip = L["强力DOT"],
					ficon = "13",
				},
				{ -- 自保技能提示 野蛮重殴（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 447439,
					threshold = 75,
				},
				{ -- 团队框架高亮 野蛮重殴（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 447439,
					color = "org",
				},
			},
		},
		{ -- 战斗狂啸
			spells = {
				{424419, "6,11"},
			},
			options = {
				T.Temp_ImportantInterruptBar(424419), -- 战斗狂啸（✓）
				{ -- 姓名板打断图标 战斗狂啸（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 424419,				
					mobID = "207946",
					interrupt = 2,
					ficon = "6",
				},
			},
		},
		{ -- 碎地之矛
			spells = {
				{1238779},
			},
			options = {
				{ -- 计时条 碎地之矛（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1238780,
					text = L["大圈"],
					sound = "[outcircle]cast",
				},
				{ -- 图标 碎地之矛（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1238782,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 贯穿护甲
			spells = {
				{424414, "0,13"},
			},
			options = {
				{ -- 打坦计时条 贯穿护甲（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424414,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 驱散提示音 贯穿护甲（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 424414,
					file = "[dispel]",
					ficon = "13",
				},
				{ -- 图标 贯穿护甲（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424414,
					hl = "red",
					ficon = "13",
				},			
			},
		},
		{ -- 艾蕾娜·安博兰兹
			npcs = {
				{27828},
			},
			spells = {
				{424431},
			},
			options = {
				{ -- 能量（✓）
					category = "TextAlert",
					color = {.2, 1, 1},
					type = "pp",
					data = {
						npc_id = "211290",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(424431)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 圣光烁辉（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424431,
					ficon = "2",
					text = L["全团AE"],
					sound = "[aoe]cast",
					glow = true,
					group = 1,
					instance_alert = true,
				},
				{ -- 自保技能提示 圣光烁辉（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 424431,
					event = "SPELL_CAST_START",
					dur = 10,
					threshold = 65,
					instance_alert = true,
				},
			},
		},
		{ -- 艾蕾娜·安博兰兹
			npcs = {
				{27828},
			},
			spells = {
				{448515},
			},
			options = {
				{ -- 计时条 神圣审判（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448515,
					show_tar = true,
					ficon = "7",
					instance_alert = true,
				},
				{ -- 驱散提示音 神圣审判（✓）
					category = "Sound",
					sub_event = "SPELL_CAST_START",
					spellID = 448515,
					file = "[prepare_dispel]",
					ficon = "7",
					instance_alert = true,
				},
				{ -- 图标 神圣审判（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 448515,
					hl = "blu",
					tip = L["易伤"].."25%",
					ficon = "7",
					instance_alert = true,
				},
				{ -- 团队框架高亮 神圣审判（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 448515,
					color = "blu",
					instance_alert = true,
				},
			},
		},
		{ -- 歇尼麦尔中士
			npcs = {
				{27825},
			},
			spells = {
				{424621},
			},
			options = {
				{ -- 计时条 蛮力重击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424621,
					sound = "[outcircle]cast",
					instance_alert = true,
				},			
			},
		},
		{ -- 歇尼麦尔中士
			npcs = {
				{27825},
			},
			spells = {
				{424423},
			},
			options = {
				{ -- 计时条 跃进打击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424423,
					sound = "[spread]cast",
					instance_alert = true,
				},
				{ -- 图标 跃进打击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 424426,
					hl = "red",
					tip = L["强力DOT"],
					ficon = "13",
					sound = "[defense]",
					instance_alert = true,
				},
				{ -- 自保技能提示 跃进打击（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 424426,
					threshold = 65,
					instance_alert = true,
				},
				{ -- 驱散提示音 跃进打击（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 424426,
					file = "[dispel]",
					ficon = "13",
					instance_alert = true,
				},
				{ -- 团队框架高亮 跃进打击（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 424426,
					color = "red",
					instance_alert = true,
				},
			},
		},
		{ -- 泰纳·杜尔玛
			npcs = {
				{27831},
			},
			spells = {
				{424462},
			},
			options = {				
				{ -- 计时条 余烬风暴（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 424462,
					text = L["躲地板"],
					sound = "[mindstep]cast",
					instance_alert = true,
				},				
			},
		},		
		{ -- 泰纳·杜尔玛
			npcs = {
				{27831},
			},
			spells = {
				{424421},
			},
			options = {				
				T.Temp_NormalInterruptBar(424421, { -- 火球术（✓）
					show_tar = true,
					instance_alert = true,
				}),
				{ -- 姓名板打断图标 火球术（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 424421,
					mobID = "239834,211289",
					interrupt = 2,
					ficon = "6",
					instance_alert = true,
				},
				{ -- 团队框架图标 火球术（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 424421,
					instance_alert = true,
				},
			},
		},
	},
}