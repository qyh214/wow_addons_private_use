local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1298\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2651] = {
	engage_id = 3054,
	npc_id = {"226404"},
	alerts = {
		{ -- 涡轮增压
			spells = {
				{465456},
			},
			options = {
				{ -- 文字 涡轮增压 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["全团AE"].."+"..L["射线"]..L["倒计时"],
					data = {
						spellID = 465463,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {2, 64, 64, 64, 64},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 465463, L["全团AE"].."+"..L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 涡轮增压（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465463,
					text = L["全团AE"].."+"..L["射线"],
					sound = "[aoe]cast",
					glow = true,
					group = 1,
				},
				{ -- 自保技能提示 涡轮增压（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 465463,
					event = "SPELL_CAST_START",
					dur = 14,
					threshold = 65,
				},
			},
		},
		{ -- 水坝！
			spells = {
				{468276, "5"},
			},
			options = {
				{ -- 图标 激荡之水（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 468723,
					tip = L["强力DOT"],
					sound = "[defense]",
					hl = "red",
				},
				{ -- 自保技能提示 激荡之水（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 468723,
					threshold = 80,
				},
				{ -- 团队框架高亮 激荡之水（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 468723,
					color = "red",
				},
			},
		},
		{ -- 跃动火花
			spells = {
				{468846},
			},
			options = {
				{ -- 计时条 跃动火花（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 468841,
					sound = "[add]cast",
				},
				{ -- 图标 跃动火花（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 468616,
					tip = L["锁定"],
					hl = "red_flash",
				},
			},
		},
		{ -- 超力震击
			spells = {
				{468812, "2"},
			},
			options = {
				{ -- 文字 超力震击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 468813,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {28, 26, 34, 26, 34, 26, 34, 26, 34},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 468813, L["放圈"], self, event, ...)
					end,
				},
				{ -- 计时条 超力震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 468813,
					text = L["放圈"],
				},
				{ -- 声音 超力震击（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 468811,
					private_aura = true,
					file = "[dropnow]",
				},
				{ -- 图标 超力震击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 468815,
					tip = L["强力DOT"],
					sound = "[defense]",
					hl = "org",
				},
				{ -- 自保技能提示 超力震击（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 468815,
					threshold = 75,
				},
				{ -- 团队框架高亮 超力震击（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 468815,
					color = "org",
				},
			},
		},
		{ -- 雷霆重拳
			spells = {
				{466197, "0"},
			},
			options = {
				{ -- 文字 雷霆重拳 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(466190)..L["倒计时"],
					data = {
						spellID = 466190,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {24, 26, 34, 26, 34, 26, 34, 26, 34, 26, 34},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 466190, T.GetIconLink(466190), self, event, ...)
					end,
				},
				{ -- 打坦计时条 雷霆重拳（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466190,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 图标 雷霆重拳（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466188,
					tip = L["DOT"],
				},
			},
		},
	},
}