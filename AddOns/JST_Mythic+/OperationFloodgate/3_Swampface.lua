local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1298\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2650] = {
	engage_id = 3053,
	npc_id = {"226396"},
	alerts = {
		{ -- 割喉藤蔓
			spells = {
				{470039},
			},
			options = {
				{ -- 图标 割喉藤蔓（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 470038,
					tip = L["连线"],
					hl = "org_flash",
				},
				{ -- 图标 割喉藤蔓（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472819,
					tip = L["连线"].."+"..L["DOT"],
				},
			},
		},
		{ -- 唤醒沼泽
			spells = {
				{473070, "5"},
			},
			options = {
				{ -- 文字 唤醒沼泽 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 473070,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {19, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "aoe",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 473070, L["全团AE"].."+"..L["躲波"], self, event, ...)
					end,
				},
				{ -- 计时条 唤醒沼泽（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473070,					
					text = L["全团AE"].."+"..L["躲波"],
					sound = "[wave]cast,cd3",
					glow = true,
					group = 1,
				},
				{ -- 自保技能提示 唤醒沼泽（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 473070,
					event = "SPELL_CAST_START",
					dur = 8,
					threshold = 65,
				},
				{ -- 图标 汹涌怒涛（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 473051,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 泥石流
			spells = {
				{473112, "4"},
			},
			options = {
				{ -- 文字 泥石流 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["冲击波"]..L["倒计时"],
					data = {
						spellID = 473114,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {9, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 473114, L["冲击波"], self, event, ...)
					end,
				},
				{ -- 计时条 泥石流（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473114,
					sound = "[dodge]cast",
					glow = true,
					group = 1,
				},
			},
		},
		{ -- 淤泥之爪
			spells = {
				{469478, "0"},
			},
			options = {
				{ -- 文字 淤泥之爪 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(469478)..L["倒计时"],
					data = {
						spellID = 469478,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {2, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30},
							},
						},
						cd_args = {
							round = true,							
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 469478, T.GetIconLink(469478), self, event, ...)
					end,
				},
				{ -- 打坦计时条 淤泥之爪（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 469478,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 图标 淤泥之爪（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472878,
					effect = 1,
					tip = L["吸收治疗"],
				},
			},
		},
	},
}