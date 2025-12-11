local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then

else

end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2599] = {
	engage_id = 2898,
	npc_id = {"214503"},
	alerts = {
		{ -- 相位之刃
			spells = {
				{433475},
			},
			options = {
				{ -- 文字 相位之刃 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.92, .22, .22},
					preview = L["冲锋"]..L["倒计时"],
					data = {
						spellID = 433475,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[15] = {
								[1] = {{15, 46},{14, 43},{14, 43},{14, 43}}
							},
							[16] = {
								[1] = {{13, 28, 28},{15, 28, 28},{15, 28, 28},{15, 28, 28}}
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "1273\\prepare_charge", -- [音效:准备冲锋]
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 433475, L["冲锋"], self, event, ...)
					end,
				},
				{ -- 计时条 相位之刃[音效:相位之刃]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 433475,
					dur = 6,
					color = {.92, .22, .22},
					text = L["冲锋"],
					count = true,
					sound = soundfile("433519cast", "cast"),
				},
				{ -- 声音 相位之刃[音效:冲锋点你]（✓）
					category = "Sound",
					spellID = 433517,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("433517aura"),
				},
				{ -- 图标 相位之刃（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434860,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 宇宙幻影
			spells = {
				{458272, "5"},
			},
			options = {
				{ -- 图标 宇宙碎片（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 459273,
					tip = L["DOT"],
				},
				{ -- 图标 宇宙残渣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 459785,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 诛灭
			spells = {
				{442428, "5"},
			},
			options = {
				{ -- 文字 诛灭 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {0, .8, 1},
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 442428,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {
							[15] = {
								[1] = {{39, 39},{39, 39},{39, 39},{39, 39}}
							},
							[16] = {
								[1] = {{48, 27},{52, 27},{52, 27},{52, 27}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 442428, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 诛灭（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 442428,
					color = {0, .8, 1},
					ficon = "5",
					text = L["射线"],
					count = true,
				},
				{ -- 声音 诛灭[音效:诛灭点你]（✓）
					category = "Sound",
					spellID = 439191,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("439191aura"),
				},
			},
		},
		{ -- 粉碎横扫
			spells = {
				{456420, "4"},
			},
			options = {				
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "214503",
						ranges = {
							{ ul = 99, ll = 95, tip = L["阶段转换"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 粉碎横扫（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456420,
					color = {1, .49, .16},
					ficon = "4",
					text = L["远离"],
					sound = "[away]cast,cd3",
					glow = true,
				},
				{ -- 图标 粉碎横扫（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464442,
					tip = L["易伤"].."200%",
				},
			},
		},
		{ -- 队长之百华斩
			spells = {
				{439511, "0"},
			},
			options = {
				{ -- 文字 队长之百华斩 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {1, 2.3, 4.1},
					preview = T.GetIconLink(439511)..L["倒计时"],
					data = {
						spellID = 439511,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {							
							[15] = {
								[1] = {{6.5,23,23,23},{6.5,23,23,23},{6.5,23,23,23},{6.5,23,23,23}}
							},
							[16] = {
								[1] = {{7,25,26,25},{7,26,27,27},{7,27,26,27},{7,27,27,26}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 432965, T.GetIconLink(439511), self, event, ...)
					end,
				},
				{ -- 计时条 队长之百华斩（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",					
					spellID = 432965,
					options_spellIDs = {439511},
					dur = 4.1,
					tags = {1, 2.3, 4.1},
					color = {.26, .85, 1},
					ficon = "0",
					icon_tex = 1398088,
					text = C_Spell.GetSpellName(439511),
					show_tar = true,
					sound = soundfile("432965cast", "cast"),
				},
				{ -- 图标 暴露（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438845,
					tip = L["易伤"].."%s500%",
					ficon = "0",
				},
				{ -- 图标 相位贯突（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 435410,
					tip = L["易伤"].."%s500%",
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 438845,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(438845)..T.GetIconLink(435410)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[438845] = { -- 暴露
								color = {.26, .85, 1},
							},
							[435410] = { -- 相位贯突
								color = {.64, .66, .85},
							},
						}						
						T.InitUnitAuraBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
			},
		},
		{ -- 箭雨
			spells = {
				{439559},
			},
			options = {
				{ -- 计时条 箭雨（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439559,
					color = {.79, .38, .71},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 456420,
				},
			},
		},
	},
}