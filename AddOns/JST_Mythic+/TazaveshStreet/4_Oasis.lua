local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["音符"] = "音符"
elseif G.Client == "ruRU" then
	--L["音符"] = "Notes"
else
	L["音符"] = "Notes"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2452] = {
	engage_id = 2440,
	npc_id = {"176563"},
	alerts = {
		{ -- 爵士乐
			spells = {
				{348567, "5"},
			},
			options = {
				{ -- 图标 爵士乐（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 348567,
					hl = "gre",
					tip = L["加急速"].."%s1%",
				},
				{ -- 图标 快拍提速！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 359019,
					hl = "gre",
					tip = L["加急速"].."25%",
				},
				{ -- 文字 音符 倒计时
					category = "TextAlert",
					type = "spell",
					preview = L["音符"]..L["倒计时"],
					data = {
						spellID = 359019,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						sound = "[note]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 355438 then -- 压制冲击
								T.Start_Text_Timer(self, 5, L["音符"], true)
							elseif sub_event == "SPELL_CAST_START" and spellID == 1241032 then -- 最终警告
								T.Start_Text_Timer(self, 5, L["音符"], true)
							end
						elseif event == "ENCOUNTER_START" then
							self.round = true
							
							if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
								self.prepare_sound = "note"
								self.count_down_start = 4
							else
								self.prepare_sound = nil		
								self.count_down_start = nil								
							end
						end
					end,
				},
			},
		},		
		{ -- 腐败的食品
			spells = {
				{359222},
			},
			options = {
				{ -- 驱散提示音 腐败的食品（✓）
					category = "Sound",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 359222,
					file = "[dodge_circle]",
				},
			},
		},
		{ -- 打架的顾客:投掷饮料
			npcs = {
				{23522},
			},
			spells = {
				{348566},
			},
			options = {
				{ -- 对我施法图标 投掷饮料（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 348566,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 投掷饮料（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 348566,
				},
			},
		},
		{ -- 捣乱的顾客:凌光箭
			npcs = {
				{23328},
			},
			spells = {
				{353836},
			},
			options = {
				T.Temp_SubInterruptBar(353836, { -- 凌光箭（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 凌光箭（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 353836,
					mobID = "176565",
					interrupt = 2,
					ficon = "6",
				},				
				{ -- 对我施法图标 凌光箭（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 353836,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 凌光箭（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 353836,
				},
			},
		},
		{ -- 捣乱的顾客:传送
			npcs = {
				{23328},
			},
			spells = {
				{438599},
			},
			options = {
				T.Temp_SubInterruptBar(353783, { -- 传送（✓）
					ficon = "14",
				}),
			},
		},
		{ -- 绿洲保安:安保猛击
			npcs = {
				{23523},
			},
			spells = {
				{350916, "0"},
			},
			options = {
				{ -- 打坦计时条 安保猛击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 350916,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
			},
		},
		{ -- 绿洲保安:威吓怒吼(佐·格伦)
			npcs = {
				{23523},
				{23098},
			},
			spells = {
				{350922},
			},
			options = {
				T.Temp_ImportantInterruptBar(350922), -- 威吓怒吼（✓）
				{ -- 姓名板打断图标 威吓怒吼（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 350922,
					mobID = "179269,176563",
					interrupt = 2,
					ficon = "6",
				},
			},
		},
		{ -- 佐·格伦:最终警告
			npcs = {
				{23098},
			},
			spells = {
				{1241032, "5"},
			},
			options = {
				{ -- 吸收盾 最终警告（✓）
					category = "BossMod",
					spellID = 1241023,
					name = string.format(L["NAME吸收盾"], T.GetIconLink(1241023)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 1241023 -- 最终警告
						frame.aura_type = "HELPFUL"
						frame.effect = 1
						frame.time_limit = 20
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
			},
		},
		{ -- 佐·格伦:压制冲击
			npcs = {
				{23098},
			},
			spells = {
				{355438},
			},
			options = {
				{ -- 文字 压制冲击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 355438,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2] = {19.8, 56.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 355438, L["拉人"], self, event, ...)
					end,
				},
				{ -- 计时条 压制冲击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 355438,
					sound = "[spread]cast,cd3",
					text = L["分散"],
				},
				{ -- 首领模块 压制冲击 计时圆圈（✓）
					category = "BossMod",
					spellID = 355439,
					name = T.GetIconLink(355439)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[355439] = { -- 压制冲击
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
							},
						}
						T.InitUnitAuraCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraCircleTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraCircleTimers(frame)			
					end,
				},
			},
		},
		{ -- 佐·格伦:群体控制
			npcs = {
				{23098},
			},
			spells = {
				{350919},
			},
			options = {
				{ -- 文字 群体控制 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["冲击波"]..L["倒计时"],
					data = {
						spellID = 350919,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2] = {41, 42.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 350919, L["冲击波"], self, event, ...)
					end,
				},
				{ -- 计时条 群体控制（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 350919,
					sound = "[dodge]cast",
					text = L["冲击波"],
				},
			},
		},
		{ -- 佐·格伦:安保猛击
			npcs = {
				{23098},
			},
			spells = {
				{359028, "0"},
			},
			options = {
				{ -- 文字 安保猛击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(359028)..L["倒计时"],
					data = {
						spellID = 359028,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2] = {10.4, 44.5, 42.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 359028, T.GetIconLink(359028), self, event, ...)
					end,
				},
				{ -- 打坦计时条 安保猛击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 359028,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
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
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 181089, -- Encounter Event
				},
			},
		},
	},
}