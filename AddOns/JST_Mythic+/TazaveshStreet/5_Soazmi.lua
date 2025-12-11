local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2451] = {
	engage_id = 2437,
	npc_id = {"175806"},
	alerts = {
		{ -- 奥能手里波
			spells = {
				{347481, "4"},
			},
			options = {
				{ -- 文字 奥能手里波 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["圆环"]..L["倒计时"],
					data = {
						spellID = 1245579,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {12.3, 20.6}, 
								[2] = {27.1, 20.2}, 
								[3] = {6.1, 20.7, 26.7, 20.7},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1245579, L["圆环"], self, event, ...)
					end,
				},
				{ -- 计时条 奥能手里波（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1245579,	
					text = L["圆环"],
					sound = "[ring]cast",
				},
				{ -- 图标 奥能手里波（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 347481,
					hl = "red",
					tip = L["强力DOT"],
				},
				{ -- 团队框架高亮 奥能手里波（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 347481,
					color = "red",
				},
				{ -- 自保技能提示 奥能手里波（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 347481,
					threshold = 85,
				},
			},
		},
		{ -- 设置移形信标
			spells = {
				{347392, "5"},
			},
			options = {
				
			},
		},
		{ -- 分隔术
			spells = {
				{1245634},
			},
			options = {
				{ -- 血量（✓）
					category = "TextAlert",
					type = "hp",
					data = {
						npc_id = "175806",
						ranges = {
							{ ul = 75, ll = 70.5, tip = T.GetIconLink(1245634)..string.format(L["血量2"], 70)},
							{ ul = 45, ll = 40.5, tip = T.GetIconLink(1245634)..string.format(L["血量2"], 40)},
						},
					},	
				},
				{ -- 计时条 分隔术（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1245634,
				},
			},
		},
		{ -- 双重秘术
			spells = {
				{357188, "4,6"},
			},
			options = {
				{ -- 计时条 双重秘术（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1245669,
					group = 1,
					ficon = "6",
					glow = true,
					sound = "[interrupt_cast]cast",
				},
			},
		},
		{ -- 相位斩
			spells = {
				{1248209, "13"},
			},
			options = {
				{ -- 文字 相位斩 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["DOT"]..L["倒计时"],
					data = {
						spellID = 1248211,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {8.6, 17.0}, 
								[2] = {5.2, 17.8, 17.0, 17.0}, 
								[3] = {2.8, 16.7, 17.0, 13.4, 17.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1248211, L["DOT"], self, event, ...)
					end,
				},
				{ -- 图标 相位斩（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1248211,
					hl = "org",
					tip = L["DOT"],
					ficon = "13",
				},
				{ -- 团队框架高亮 相位斩（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1248211,
					color = "org",
				},
				{ -- 自保技能提示 相位斩（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1248211,
					threshold = 65,
				},
			},
		},
		{ -- 分隔术
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1245634, -- 分隔术
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1245634, -- 分隔术
					count = 2,
				},				
			},
		},
	},
}