local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2585] = {
	engage_id = 2901,
	npc_id = {"215407"},
	alerts = {
		{ -- 血工
			npcs = {
				{28411},
			},
			options = {
				 { -- 图标 抓握之血（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 432031,
					hl = "yel",
					tip = L["定身"],
				},
			},
		},
		{ -- 宇宙奇点
			spells = {
				{432117, "4"},
			},
			options = {
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "215407",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(432117)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 宇宙奇点（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432117,
					text = L["拉人"],
					sound = "[pull]cast,cd3",
					glow = true,
					group = 1,
				},
				{ -- 图标 消隐（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 432119,
					hl = "red",
					tip = L["易伤"].."+"..L["降低伤害"],
				},
			},
		},
		{ -- 培植毒药
			spells = {
				{461487, "9"},
			},
			options = {
				{ -- 文字 培植毒药 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(461487)..L["倒计时"],
					data = {
						spellID = 461487,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {13.0,29.9,27.9,30.4,24.3,24.3,25.5,26.7,25.5,23.1,24.3,27.9,27.9},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 461487, T.GetIconLink(461487), self, event, ...)
					end,
				},
				{ -- 计时条 培植毒药（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 461487,
					text = L["分散"],
					sound = "[spread]cast",
				},	
				{ -- 图标 培植毒药（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 461487,
					hl = "gre",
					tip = L["DOT"],
					ficon = "9",
				},
				{ -- 自保技能提示 培植毒药（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 461487,
					threshold = 65,
				},
				{ -- 团队框架高亮 培植毒药（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 461487,
					color = "gre",
				},
				{ -- 驱散提示音 培植毒药（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 461487,
					file = "[dispel]",
					ficon = "9",
				},
				{ -- 图标 培植毒药（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 461507,
					tip = L["DOT"],
				},
				{ -- 自保技能提示 培植毒药（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 461507,
					threshold = 75,
				},
				{ -- 团队框架高亮 培植毒药（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 461507,
					color = "red",
				},
			},
		},
		{ -- 爆发蛛网
			spells = {
				{432130},
			},
			options = {		
				{ -- 文字 爆发蛛网 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 432130,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {7.0, 18.2, 19.9, 19.0, 20.7, 18.2, 18.7, 19.4, 18.1, 21.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 432130, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 爆发蛛网（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 432130,
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
	},
}