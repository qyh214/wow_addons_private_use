local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1185\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2406] = {
	engage_id = 2401,
	npc_id = {"165408"},
	alerts = {
		{ -- 折射罪光
			spells = {
				{322913},
			},
			options = {
				{ -- 文字 折射罪光 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 438476,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {32.9, 49.8},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438476, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 折射罪光（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 322711,
					dur = 2,
					text = L["射线"],
					glow = true,
					group = 1,
					sound = "[ray]cast",
				},
				{ -- 首领模块 分段计时条 折射罪光（✓）
					category = "BossMod",
					spellID = 322711,
					name = string.format(L["计时条%s"], T.GetIconLink(322711)),
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spell_info = {
							["SPELL_AURA_APPLIED"] = {
								[322711] = {
									dur = 13,
									color = {1, 1, 0},
									divide_info = {
										dur = {5},
										sound = "changedirection",
									},
									count_down = 3,
								},
							},
						}						
						T.InitSpellCastBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateSpellCastBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellCastBar(frame)
					end,
				},			
			},
		},
		{ -- 粉碎砸击
			spells = {
				{322936, "0"},
			},
			options = {
				{ -- 文字 粉碎砸击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(322936)..L["倒计时"],
					data = {
						spellID = 322936,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {4.9, 13.4, 36.4, 13.4, 36.4, 13.4},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 322936, T.GetIconLink(322936), self, event, ...)
					end,
				},
				{ -- 计时条 粉碎砸击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 322936,
					text = L["大圈"],
					sound = "[outcircle]cast,notank",
				},
				{ -- 图标 玻璃裂片（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 323001,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 举起残骸
			spells = {
				{322943},
			},
			options = {
				{ -- 计时条 举起残骸（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 322943,
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 罪光幻象
			spells = {
				{322977, "7"},
			},
			options = {
				{ -- 图标 罪光幻象（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 322977,
					spellIDs = {339237},
					tip = L["恐惧"],
					ficon = "7",
				},
				{ -- 驱散提示音 罪光幻象（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 322977,
					spellIDs = {339237},
					file = "[dispel]",
					ficon = "7",
				},
				{ -- 团队框架高亮 罪光幻象（✓）
					category = "RFIcon",
					type = "Aura",
					spellIDs = {339237},
					spellID = 322977,
					color = "blu",
				},
			},
		},
	},
}