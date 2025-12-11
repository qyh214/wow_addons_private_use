local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["C水墙"] = "|cffb4c231水墙|r"
	L["C白圈"] = "|cffe3dcba白圈|r"
	L["C小怪"] = "|cffff8549小怪|r"
	L["技能组合"] = "技能组合"
else
	L["C水墙"] = "|cffb4c231Wave|r"
	L["C白圈"] = "|cffe3dcbaCircle|r"
	L["C小怪"] = "|cffff8549ADD|r"
	L["技能组合"] = "Skill Combination "
end

---------------------------------Notes--------------------------------
-- 打断时间影响时间轴

-- 白圈 白箭头 Private Aura（439783）
-- 小怪 黄箭头 Private Aura （439815）
-- 水墙 绿箭头 Private Aura（439790）

-- P1 白圈——水墙+白圈——小怪+白圈
-- P2 水墙——小怪+水墙——白圈+水墙
-- P3 小怪——白圈+小怪——水墙+小怪
-- P4 同P1

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2609] = {
	engage_id = 2918,
	npc_id = {"214504"},
	alerts = {
		{ -- 野蛮突袭
			spells = {
				{444687, "0"},
			},
			options = {
				{ -- 计时条 野蛮突袭[音效:野蛮突袭]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 444687,
					color = {.56, .34, .17},
					ficon = "0",
					show_tar = true,
					sound = soundfile("444687cast", "cast"),
				},
				{ -- 图标 野蛮创伤（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 458067,
					hl = "",
					tip = L["DOT"],
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 458067,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(458067)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[458067] = { -- 野蛮创伤
								color = {.53, .51, .32},
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
		{ -- 酸液翻腾
			spells = {
				{439789, "5"},
			},
			options = {
				{ -- 文字 酸液翻腾 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {.71, .76, .19},
					preview = L["C水墙"]..L["倒计时"],
					data = {
						spellID = 439791,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[16] = {
								[1] = {35},
								[2] = {37},
								[3] = {13},
								--[4] = {},
								[5] = {17},
								--[6] = {},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 439791, L["C水墙"], self, event, ...)
					end,
				},
				{ -- 计时条 酸液翻腾（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439791,
					dur = 5,
					color = {.71, .76, .19},
					ficon = "5",					
				},
				{ -- 声音 酸液翻腾[音效:水墙点你]（✓）
					category = "Sound",
					spellID = 439790,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("439790aura"),
				},
				{ -- 图标 酸蚀昏迷（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439787,
					hl = "red_flash",
				},
				{ -- 图标 腐蚀（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 439785,					
					hl = "",
					tip = L["DOT"],
				},
				{ -- 图标 酸液翻腾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",				
					spellID = 439786,
					tip = L["快走开"],
					sound = "[sound_buzzer]",
				},
				{ -- 图标 酸液池（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 439776,					
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 被感染的子嗣
			npcs = {
				{28908},
			},
			options = {
				{ -- 文字 被感染的子嗣 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {1, .52, .29},
					preview = L["C小怪"]..L["倒计时"],
					data = {
						spellID = 455373,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[16] = {
								[1] = {18},
								[2] = {11},
								--[3] = {},
								[4] = {10, 20},
								[5] = {11, 25},
								[6] = {16},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 455373, L["C小怪"], self, event, ...)
					end,
				},
				{ -- 计时条 被感染的子嗣（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 455373,
					color = {1, .52, .29},
					sound = "[add]cast",
				},
				{ -- 声音 被感染的子嗣[音效:小怪点你]（✓）
					category = "Sound",
					spellID = 439815,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("439815aura"),
				},
				{ -- 图标 感染撕咬（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 455287,					
					hl = "",
					tip = L["减速"]..L["DOT"],
				},
			},
		},
		{ -- 喷射丝线
			spells = {
				{439784},
			},
			options = {
				{ -- 文字 喷射丝线 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {.89, .86, .73},
					preview = L["C白圈"]..L["倒计时"],
					data = {
						spellID = 439784,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[16] = {
								[1] = {14},
								[2] = {30},
								[3] = {15, 15},
								[4] = {14},
								--[5] = {},
								[6] = {10, 20},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 439784, L["C白圈"], self, event, ...)
					end,
				},
				{ -- 喷射丝线（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439784,
					color = {.89, .86, .73},
					count = true,
				},
				{ -- 声音 喷射丝线[音效:白圈点你]（✓）
					category = "Sound",
					spellID = 439783,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("439783aura"),
				},
				{ -- 图标 喷射丝线（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 456170,					
					hl = "org",
					tip = L["连线"],
				},
				{ -- 图标 粘性蛛网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439780,		
					tip = L["减速"],
				},
			},
		},
		{ -- 包围之网
			spells = {
				{454989, "12"},
			},
			options = {
				{ -- 文字 包围之网 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {0, .69, .94},
					preview = L["C白圈"]..L["倒计时"],
					data = {
						spellID = 454989,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[16] = {
								[1] = {38},
								[2] = {15},
								[3] = {35},
								[4] = {34},
								[5] = {30},
								[6] = {35},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 454989, L["C白圈"], self, event, ...)
					end,
				},
				{ -- 计时条 包围之网（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 454989,
					color = {0, .69, .94},
				},
				{ -- 图标 包围之网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 454989,
					hl = "red",
					tip = L["昏迷"],
				},
			},
		},
		{ -- 蛛网收掠
			spells = {
				{439795, "4"},
			},
			options = {
				{ -- 计时条 蛛网收掠（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439795,
					color = {1, 0, 0},
					ficon = "4",
					sound = "[sharedmg]cast",
				},		
			},
		},
		{ -- 侵蚀喷涌
			spells = {
				{439811, "2"},
			},
			options = {
				{ -- 文字 侵蚀喷涌 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.86, .89, .22},
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 439811,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							[15] = {
								[1] = {3, 30, 44},
								[2] = {25, 44},
								[3] = {25, 44},
								[4] = {25, 44},
								[5] = {25, 44},
								[6] = {25, 44},
							},
							[16] = {
								[1] = {8, 40},
								[2] = {20, 25},
								[3] = {20, 25},
								[4] = {20, 25},
								[5] = {20, 25},
								[6] = {20, 25},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 439811, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 侵蚀喷涌（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439811,
					color = {.86, .89, .22},
					ficon = "2",
					count = true,
					sound = "[aoe]cast",
				},
				{ -- 图标 萦绕侵蚀（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440193,	
					tip = L["DOT"],
				},
			},
		},
		{ -- 酸蚀喷发
			spells = {
				{452806, "6,5"},
			},
			options = {			
				{ -- 计时条 酸蚀喷发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 452806,
					color = {1, .9, 0},
					ficon = "6",
					sound = "[interrupt_cast]cast",
				},
				{ -- 图标 酸性甲壳（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 457877,					
					tip = L["BOSS免疫"],
				},
			},
		},
		{ -- 酸蚀之霰
			spells = {
				{444094},
			},
			options = {			
				{ -- 计时条 酸蚀之霰（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 456853,
					spellIDs = {456841, 456762},			
					color = {.92, .91, .29},
					sound = "[mindstep]cast",
				},
				{ -- 计时条 转阶段（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 456853,
					dur = 15,
					tags = {5.8},
					color = {1, 1, 0},
				},
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "214504",
						ranges = {
							{ ul = 99, ll = 95, tip = L["阶段转换"]..string.format(L["能量2"], 100)},
						},
					},
				},
			},
		},
		{ -- 粘稠迸发
			spells = {
				{439792, "0"},
			},
			options = {
				{ -- 图标 粘稠迸发（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 439792,					
					tip = L["DOT"],
				},
				{ -- 文字 粘稠迸发 近战位无人提示（✓）
					category = "TextAlert",
					ficon = "0",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(439792)..L["近战无人"],
					data = {
						spellID = 439792,
						events = {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 439792 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(439792)..L["近战无人"])
							end
						end
					end,
				},
			},
		},
		{ -- 喷射丝线 酸液翻腾 被感染的子嗣
			spells = {
				{439784},
				{439789, "5"},
				{455373},	
			},
			options = {
				{ -- 文字 喷射丝线 酸液翻腾 被感染的子嗣 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "3",
					color = {1, 1, 1},
					preview = T.GetIconLink(439784)..T.GetIconLink(439789)..T.GetIconLink(455373)..L["技能组合"]..L["倒计时"],
					data = {
						spellID = 439789,
						events =  {
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							{L["C白圈"], L["C水墙"].."+"..L["C白圈"], L["C小怪"].."+"..L["C白圈"]}, -- P1
							{L["C水墙"], L["C小怪"].."+"..L["C水墙"], L["C白圈"].."+"..L["C水墙"]}, -- P2
							{L["C小怪"], L["C白圈"].."+"..L["C小怪"], L["C水墙"].."+"..L["C小怪"]}, -- P3
							{L["C白圈"], L["C水墙"].."+"..L["C白圈"], L["C小怪"].."+"..L["C白圈"]}, -- P4
							{L["C水墙"], L["C小怪"].."+"..L["C水墙"], L["C白圈"].."+"..L["C水墙"]}, -- P5
							{L["C小怪"], L["C白圈"].."+"..L["C小怪"], L["C水墙"].."+"..L["C小怪"]}, -- P6
						},
						sound_info = {
							{"web",		"roll_web",		"infest_web"}, -- P1
							{"roll",	"infest_roll",	"web_roll"}, -- P2
							{"infest",	"web_infest",	"roll_infest"}, -- P3
							{"web",		"roll_web",		"infest_web"}, -- P4
							{"roll",	"infest_roll",	"web_roll"}, -- P5
							{"infest",	"web_infest",	"roll_infest"}, -- P6
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_PHASE" then
							self.phase = ...
							if self.data.info[self.phase] then
								self.prepare_sound = self.data.sound_info[self.phase]
								T.Start_Text_DelayRowTimer(self, {11.3, 25.4, 19.1}, self.data.info[self.phase], true)
							end
						elseif event == "ENCOUNTER_START" then
							if not self.timer_init then
								self.round = true
								self.show_time = 5
								self.count_down_start = 4
								self.mute_count_down = true
								
								self.timer_init = true
							end
							self.prepare_sound = self.data.sound_info[1]
							T.Start_Text_DelayRowTimer(self, {14.3, 24.2, 19.7}, self.data.info[1], true)
						end
					end,
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 439795,
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 439795,
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 4,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 439795,
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 439795,
					count = 4,
				},
				{
					category = "PhaseChangeData",
					phase = 6,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 439795,
					count = 5,
				},
			},
		},
	},
}
