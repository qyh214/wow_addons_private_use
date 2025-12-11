local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2455] = {
	engage_id = 2442,
	npc_id = {"177269"},
	alerts = {
		{ -- 凌光火花
			spells = {
				{350796},
			},
			options = {
				{ -- 文字 凌光火花 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 350796,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {11.7, 15.8, 15.8, 15.8, 15.8, 20.6, 15.8, 16.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 350796, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 凌光火花（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 350796,
					sound = "[aoe]cast",
				},
			},
		},
		{ -- 坍缩之星
			spells = {
				{350799, "2,5"},
			},
			options = {
				{ -- 文字 坍缩之星 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["宝珠"]..L["倒计时"],
					data = {
						spellID = 353635,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							["all"] = {
								[1] = {20.2, 60.7},
								[2.5] = {25.4},
								[3.5] = {25.4},
								[4.5] = {25.4},
								[5.5] = {25.4},
								[6.5] = {25.4},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 353635, L["宝珠"], self, event, ...)
					end,
				},
				{ -- 计时条 坍缩之星（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 353635,
					sound = "[orb]cast",
				},
				{ -- 图标 坍缩能量（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350804,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 首领模块 坍缩能量 计时圆圈（✓）
					category = "BossMod",
					spellID = 350804,
					name = T.GetIconLink(350804)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[350804] = { -- 坍缩能量
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 0, 0},
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
		{ -- 召唤刺客
			spells = {
				{351124, "1"},
			},
			options = {
				{ -- 文字 召唤刺客 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(351124)..L["倒计时"],
					data = {
						spellID = 351124,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							["all"] = {
								[1] = {5.7, 42.4, 41.3},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 351124, T.GetIconLink(351124), self, event, ...)
					end,
				},
				{ -- 计时条 召唤刺客（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 351124,
					sound = "[add]cast",
				},
			},
		},
		{ -- 索财团的刺客
			npcs = {
				{23360},
			},
			spells = {
				{351119, "6"}, -- 闪击手里剑
			},
			options = {
				{ -- 首领模块 标记 索财团的刺客（✓）
					category = "BossMod",
					spellID = 351119,
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("177716"), T.FormatRaidMark("5,6")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "only_rl_bool",
							text = L["当队长时标记"],
							default = true,
						},
					},
					init = function(frame)
						frame.start_mark = 5
						frame.end_mark = 6
						frame.mob_npcID = "177716"
						
						function frame:trigger(unit, GUID)
							if not C.DB["BossMod"][self.config_id]["only_rl_bool"] or UnitLeadsAnyGroup("player") then
								return true
							end
						end
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateRaidTarget(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				T.Temp_NormalInterruptBar(351119, { -- 闪击手里剑（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 闪击手里剑（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 351119,
					mobID = "177716",
					interrupt = 2,
					ficon = "6",
				},
			},
		},
		{ -- 势不可挡
			spells = {
				{351086, "5"},
			},
			options = {
				{ -- 文字 势不可挡 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(351086)..L["倒计时"],
					data = {
						spellID = 351086,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2.5] = {65.5},
								[3.5] = {65.5},
								[4.5] = {65.5},
								[5.5] = {65.5},
								[6.5] = {65.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 351086, T.GetIconLink(351086), self, event, ...)
					end,
				},
				{ -- 图标 势不可挡（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 351086,
					tip = L["BOSS免疫"],
				},
				{ -- 计时条 迁移（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 351057,
				},
			},
		},
		{ -- 凌光震荡
			spells = {
				{350885, "5"},
			},
			options = {				
				{ -- 计时条 凌光震荡（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 350875,
					sound = "[arrow]cast",
					glow = true,
					group = 1,
				},
				{ -- 图标 凌光震荡（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350885,
					tip = L["易伤"].."%s25%",
				},
			},
		},
		{ -- 能量裂片
			spells = {
				{351096},
			},
			options = {
				{ -- 文字 能量裂片 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(351096)..L["倒计时"],
					data = {
						spellID = 351096,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.count = 0
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 351057 then -- 迁移
								self.count = self.count + 1
								if mod(self.count, 2) == 1 then
									T.Start_Text_DelayTimer(self, 9, L["飞刀"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 能量裂片（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 351096,
					sound = "[knife]cast",
					text = L["飞刀"],
				},
				{ -- 首领模块 计时条 能量裂片（✓）
					category = "BossMod",
					spellID = 351098,
					name = string.format(L["计时条%s"], T.GetIconLink(351098)),
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.count = 0
						frame.bar = T.CreateAlertBarShared(2, "bossmod"..frame.config_id, C_Spell.GetSpellTexture(351098), "", T.GetSpellColor(351098), {1, 2, 3, 4})
						frame.bar:SetMinMaxValues(0, 5)
						
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 351096 then
								frame.count = 0
								frame.bar:SetValue(frame.count)
								frame.bar.right:SetText("")
								frame.bar:Show()
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 351098 then
								frame.count = frame.count + 1
								T.PlaySound("count\\"..frame.count)
								frame.bar:SetValue(frame.count)
								frame.bar.right:SetText(frame.count)
								T.PlaySound(frame.count)
								if frame.count == 5 then
									C_Timer.After(1, function()
										frame.bar:Hide()
									end)
								end
								
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
						end
					end,
					reset = function(frame, event)
						frame.bar:Hide()
					end,
				},
			},
		},
		{ -- 凌光新星
			spells = {
				{351646},
			},
			options = {
				{ -- 文字 凌光新星 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(351646)..L["倒计时"],
					data = {
						spellID = 351646,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.count = 0
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 351057 then -- 迁移
								self.count = self.count + 1
								if mod(self.count, 2) == 0 then
									T.Start_Text_DelayTimer(self, 9, L["大圈"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 凌光新星（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 351646,
					sound = "[dodge_circle]cast",
					text = L["大圈"],
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
					spellID = 351086, -- 势不可挡
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 351086, -- 势不可挡
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 351086, -- 势不可挡
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 3.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 351086, -- 势不可挡
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 4,	
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 351086, -- 势不可挡
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 4.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 351086, -- 势不可挡
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 351086, -- 势不可挡
					count = 4,
				},
				{
					category = "PhaseChangeData",
					phase = 5.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 351086, -- 势不可挡
					count = 4,
				},
				{
					category = "PhaseChangeData",
					phase = 6,	
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 351086, -- 势不可挡
					count = 5,
				},
				{
					category = "PhaseChangeData",
					phase = 6.5,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 351086, -- 势不可挡
					count = 5,
				},
			},
		},
	},
}