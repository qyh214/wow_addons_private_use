local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1271\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2583] = {
	engage_id = 2926,
	npc_id = {"213179"},
	alerts = {
		{ -- 贪得无厌
			spells = {
				{446788},
			},
			options = {
				{ -- 图标 贪得无厌（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 446794,
				},
			},
		},
		{ -- 警示尖鸣
			spells = {
				{438476},
			},
			npcs = {
				{28811},
			},
			options = {
				{ -- 文字 警示尖鸣 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 438476,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10.1, 40.2, 38.9, 40.1, 40, 40.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438476, L["召唤小怪"], self, event, ...)
					end,
				},
				{ -- 计时条 警示尖鸣（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438476,
					sound = "[add]cast",
				},
				{ -- 自保技能提示 警示尖鸣（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 438476,
					event = "SPELL_CAST_START",
					dur = 4.5,
					threshold = 65,
				},
				{ -- 图标 饥肠辘辘（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 439070,
					hl = "red",
					tip = L["锁定"],
				},
			},
		},
		{ -- 蛛纱强袭
			spells = {
				{438473},
			},
			options = {
				{ -- 文字 蛛纱强袭 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 438473,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {31.4, 39.2, 40.0, 40.1, 40.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438473, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 蛛纱强袭（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438473,
					sound = "[mindstep]cast",
				},
				{ -- 自保技能提示 蛛纱强袭（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 438473,
					event = "SPELL_CAST_START",
					dur = 9,
					threshold = 65,
				},
				{ -- 图标 邪恶缠网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434830,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 贪食撕咬
			spells = {
				{438471, "0"},
			},
			options = {
				{ -- 文字 贪食撕咬 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(438471)..L["倒计时"],
					data = {
						spellID = 438471,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {3.9, 14.7, 25.3, 14.2, 24.6, 14.6, 25.5, 14.6, 25.4, 14.6, 25.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438471, T.GetIconLink(438471), self, event, ...)
					end,
				},
				{ -- 打坦计时条 贪食撕咬（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438471,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 图标 贪食撕咬（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439200,
					tip = L["易伤"].."50%",
				},
			},
		},
	},
}