local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["接油罐"] = "接油罐"
	L["进度条"] = "进度条"
	L["不能接圈"] = "不能接圈"
elseif G.Client == "ruRU" then
	L["接油罐"] = "Сбор масла"
	L["进度条"] = "Полоса прогресса"
	L["不能接圈"] = "Нельзя собирать"
else
	L["接油罐"] = "Soak"
	L["进度条"] = "progress bar"
	L["不能接圈"] = "Can't soak"
end

---------------------------------Notes--------------------------------
-- "466615#防御护板#0#nameplate1#磨轮号", BUG FIX
---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2639] = {
	engage_id = 3009,
	npc_id = {"225821"},
	alerts = {
		{ -- 防御护板
			spells = {
				{466615, "5"},
			},
			options = {
				{ -- 图标 防御护板（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 466615,
				},
			},
		},
		{ -- 冷酷刹戮
			spells = {
				{471403, "4"},
			},
			options = {
				{ -- 计时条 冷酷刹戮（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 471403,
					color = {.96, .51, .13},
					glow = true,
					ficon = "4",
				},
			},
		},
		{ -- 召唤摩托
			spells = {
				{459943},
			},			
			options = {
				{ -- 文字 召唤摩托 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.31, .78, .12},
					preview = T.GetIconLink(459943)..L["倒计时"],
					data = {
						spellID = 459943,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {{20, 30, 36},{25, 28, 33, 31},{24, 28, 33, 31}},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 459943, T.GetIconLink(459943), self, event, ...)
					end,
				},
				{ -- 计时条 召唤摩托（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 459943,
					color = {.31, .78, .12},
					sound = "[add]cast",
				},
			},
		},
		{ -- 磨轮摩托
			npcs = {
				{30118},
			},
			options = {
				{ -- 图标 满身燃油（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 473507,
					hl = "",
					tip = L["易伤"].."500%",
				},
				{ -- 图标 正携带燃油（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 1216788,
					hl = "yel",
					sound = "[sound_dong]",
				},
				{ -- 首领模块 油罐 接圈计时条（✓）
					category = "BossMod",
					spellID = 1216731,
					ficon = "12",
					enable_tag = "none",
					name = T.GetIconLink(1216731)..L["接圈"]..L["计时条"],	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.bars = {}
						frame.spell_count = 0
						
						function frame:hide_all()
							for i, bar in pairs(frame.bars) do
								T.StopTimerBar(bar, true, true)
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "UNIT_DIED" then
								local npcID = select(6, string.split("-", destGUID)) -- 小怪死亡
								if npcID == "225804" then
									frame.spell_count = frame.spell_count + 1
									if not frame.bars[frame.spell_count] then
										frame.bars[frame.spell_count] = T.CreateAlertBarShared(2, "bossmod"..frame.config_id.."-"..frame.spell_count, 1131085, L["接圈"], {1, .8, .12})
									end
									T.StartTimerBar(frame.bars[frame.spell_count], 5, true, true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.spell_count = 0
						end
					end,
					reset = function(frame, event)
						frame:hide_all()
					end,
				},
				{ -- 文字 不能接圈提示
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {1, 1, 1},
					preview = L["不能接圈"]..L["文字提示"].."+"..L["喊话"],
					data = {
						spellID = 474159,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "UNIT_DIED" then
								local npcID = select(6, string.split("-", destGUID)) -- 小怪死亡
								if npcID == "225804" then
									local remain = 0
									if AuraUtil.FindAuraBySpellID(473507, "player", "HARMFUL") then -- 满身燃油
										local exp_time = select(6, AuraUtil.FindAuraBySpellID(473507, "player", "HARMFUL"))
										remain = exp_time - GetTime()
									end
									if remain > 5 then
										T.SendChatMsg(L["不能接圈"], 5, "SAY")
										T.Start_Text_Timer(self, 5, L["不能接圈"])
									else
										T.Stop_Text_Timer(self)
									end
								end	
							end
						end
					end,
				},
				{ -- 首领模块 满身燃油 多人光环（✓）
					category = "BossMod",
					spellID = 473507,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1216788)..T.GetIconLink(473507)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -330},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 3
						
						frame.spellIDs = {
							[1216788] = { -- 正携带燃油
								color = {1, .9, .1},
							},
							[473507] = { -- 满身燃油
								color = {.02, .41, 1},
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
		{ -- 喷油
			spells = {
				{459666},
			},
			options = {
				{ -- 文字 喷油 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.81, .92, .8},
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 459671,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {{11, 38, 40},{16, 21, 21, 21, 21, 21},{16, 21, 21, 21, 21, 21}},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 459671, L["大圈"], self, event, ...)
					end,
				},
				{ -- 计时条 喷油（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 459671,
					color = {.81, .92, .8},
					sound = "[spread]cast",
				},
				{ -- 声音 喷油[音效:喷油点你]（✓）
					category = "Sound",
					spellID = 459669,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("459669aura"),
				},
				{ -- 图标 喷油（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 459678,
					hl = "",
					tip = L["DOT"],
				},
				{ -- 图标 浮油（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 459683,
					hl = "",
					tip = L["DOT"].."+"..L["减速"],
				},
			},
		},
		{ -- 爆燃纵火
			spells = {
				{468207},
			},
			options = {				
				{ -- 文字 爆燃纵火 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.98, .07, .01},
					preview = L["跑圈"]..L["倒计时"],
					data = {
						spellID = 468487,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {{25, 20, 28},{34, 35, 37},{34, 35, 37}},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 468487, L["跑圈"], self, event, ...)
					end,
				},
				{ -- 计时条 爆燃纵火（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 468487,
					color = {.98, .07, .01},
					sound = "[mindstep]cast",
				},
				{ -- 声音 爆燃纵火（✓）
					category = "Sound",
					spellID = 468486,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[prepare_drop]",
				},
				{ -- 图标 爆燃纵火（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 468216,
					hl = "org_flash",
					tip = L["保持移动"],
					file = "[keepmoving]",
				},
			},
		},
		{ -- 爆炸之旅！
			spells = {
				{459974, "2"},
			},
			options = {
				{ -- 图标 爆炸之旅！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 459978,
					hl = "red",
					tip = L["强力DOT"],
				},
			},
		},
		{ -- 坦爆重击
			spells = {
				{459627, "0"},
			},
			options = {
				{ -- 计时条 坦爆重击[音效:坦爆重击]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 459627,
					color = {.88, .86, .84},
					show_tar = true,
					sound = soundfile("459627cast", "cast"),
					ficon = "0",
				},
				{ -- 图标 坦爆重击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 465865,
					tip = L["DOT"].."+"..L["易伤"],
					hl = "",
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 465865,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(465865)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[465865] = { -- 坦爆重击
								color = {.88, .86, .84},
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
				{ -- 图标 废气（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 468147,
					tip = L["DOT"],
					hl = "",
				},
			},
		},
		{ -- 机械故障
			spells = {
				{460603},
			},
			options = {
				{ -- 计时条 机械故障（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 460603,
					color = {.88, .32, .11},
					glow = true,
					sound = "[phase]cast",
				},				
			},
		},
		{ -- 整修
			spells = {
				{460116},
			},
			options = {
				{ -- 整修进度条
					category = "BossMod",
					spellID = 460116,
					enable_tag = "none",
					name = T.GetIconLink(460116)..L["进度条"],
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_POWER_FREQUENT"] = true,
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.default_bar_width = 300
						T.GetSingleBarCustomData(frame)
						
						local spellName = C_Spell.GetSpellName(460116)
						local spellIcon = C_Spell.GetSpellTexture(460116)
						frame.bar = T.CreateTimerBar(frame, spellIcon, false, false, true, nil, nil, {1, .8, 0})
						frame.bar:SetAllPoints(frame)
						frame.bar.left:SetText(spellName)
						frame.bar:SetMinMaxValues(0, 100)
						
						function frame:update_power()
							if self.buffed and self.power > 0 then
								self.bar:SetValue(self.power)
								self.bar.right:SetText(self.power)
								self.bar:Show()
							else
								self.bar:Hide()
							end
						end
						
						function frame:PreviewShow()
							self.power = 50
							self.buffed = true
							self:update_power()
						end
						
						function frame:PreviewHide()
							self.power = 0
							self.buffed = false
							self:update_power()
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_AURA" then
							local unit = ...
							if unit == "boss1" then
								if AuraUtil.FindAuraBySpellID(460603, "boss1", "HARMFUL") then -- 机械故障
									frame.buffed = true
								else
									frame.buffed = false
								end
								frame:update_power()
							end
						elseif event == "UNIT_POWER_FREQUENT" then
							local unit = ...
							if unit == "boss1" then
								frame.power = UnitPower("boss1", 10)
								frame:update_power()
							end
						elseif event == "ENCOUNTER_START" then
							frame.power = 0
							frame.buffed = false
						end
					end,
					reset = function(frame, event)
						frame:Hide()
					end,
				},
				{ -- 计时条 整修（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 460116,
					dur = 45,
					color = {.88, .32, .11},
					text = L["易伤"].."+100%",
				},			
				{ -- 姓名板高亮 支援装置（待测试）
					category = "PlateAlert",
					type = "PlateNpcID",
					mobID = "234557",
					ficon = "12",
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
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 460116, -- 整修
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 460603, -- 机械故障
				},
			},
		},
	},
}