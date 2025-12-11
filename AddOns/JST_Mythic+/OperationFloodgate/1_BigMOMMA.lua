local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1298\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2648] = {
	engage_id = 3020,
	npc_id = {"226398"},
	alerts = {
		{ -- 快速启动
			spells = {
				{460156},
			},
			options = {
				{ -- 计时条 快速启动（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 460156,
					text = L["全团AE"],
					sound = "[aoe]cast",
					glow = true,
					group = 1,
				},
				{ -- 自保技能提示 快速启动（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 460156,
					event = "SPELL_CAST_START",
					dur = 13.5,
					threshold = 65,
				},
				{ -- 图标 超量电化（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 473287,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 动员无人机			
			spells = {
				{471585},
			},
			options = {
				{ -- 计时条 动员无人机（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 471585,
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
				{ -- 首领模块 标记 暗锁无人机（✓）
					category = "BossMod",
					spellID = 471585,
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("228424"), T.FormatRaidMark("5,6,7,8")),
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
						frame.end_mark = 8
						frame.mob_npcID = "228424"
						
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
			},
		},
		{ -- 暗锁无人机:终极失真
			npcs = {
				{30316},
			},
			spells = {
				{1214780},
			},
			options = {				
				{ --首领模块 终极失真（✓）
					category = "BossMod",
					spellID = 1214780,
					ficon = "6",
					name = T.GetIconLink(1214780)..L["计时条"],
					points = {hide = true},
					events = {					
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
					},					
					init = function(frame)
						local icon = C_Spell.GetSpellTexture(1214780)
						local color = T.GetSpellColor(1214780)
						
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, "", color)
						
						function frame:UpdateInterruptBar(unit)
							local name, text, _, startTimeMS, endTimeMS = UnitCastingInfo(unit)
							local dur = (endTimeMS - startTimeMS)/1000
							local cast_expTime = GetTime() + dur
							local interrupt_spellID, spell_exp = T.GetInterruptSpell(cast_expTime)
							if interrupt_spellID then
								if spell_exp == 0 then
									self.bar.left:SetText(string.format("%s%s", T.GetFlagIconStr("6"), name))
								else
									local wait = spell_exp - GetTime()
									self.bar.left:SetText(string.format("%s%s |cffadd6ffCD:%.1f|r", T.GetFlagIconStr("6"), name, wait))
									C_Timer.After(wait, function()
										self.bar.left:SetText(string.format("%s%s |cff00ff00%s|r", T.GetFlagIconStr("6"), name, L["就绪"]))
									end)
								end
								
								T.StartTimerBar(self.bar, dur, true, true)
								T.PlaySound("interrupt")
								self.bar.GUID = UnitGUID(unit)
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, castGUID, spellID = ...
							
							if string.find(unit, "nameplate") and castGUID and spellID == 1214780 then -- 终极失真
								frame:UpdateInterruptBar(unit)
							end
						elseif event == "UNIT_SPELLCAST_STOP" then
							local unit, _, spellID = ...
							
							if string.find(unit, "nameplate") and spellID == 1214780 then -- 终极失真
								local GUID = UnitGUID(unit)
								if GUID == frame.bar.GUID then
									T.StopTimerBar(frame.bar, true, true)
								end
							end
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
				{ -- 姓名板施法图标 终极失真（✓）
					category = "PlateAlert",
					type = "PlateSpells",
					spellID = 1214780,
					hl_np = true,
				},
			},
		},
		{ -- 暗锁无人机:射击
			npcs = {
				{30316},
			},
			spells = {
				{460393},
			},
			options = {
				{ -- 对我施法图标 射击（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 460393,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 射击（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 460393,
				},
			},
		},
		{ -- 暗锁无人机:毁灭风暴
			npcs = {
				{30316},
			},
			spells = {
				{472452},
			},
			options = {
				{ -- 声音 毁灭风暴（✓）
					category = "Sound",
					sub_event = "SPELL_CAST_START",
					spellID = 472452,
					file = "[mindstep]",
				},
			},
		},
		{ -- 电气重碾
			spells = {
				{473351, "0"},
			},
			options = {
				{ -- 文字 电气重碾 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(473351)..L["倒计时"],
					data = {
						spellID = 473351,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							T.Start_Text_DelayTimer(self, 6, T.GetIconLink(473351), true)
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" then
								if spellID == 460156 then -- 快速启动
									T.Stop_Text_Timer(self)
									T.Start_Text_DelayTimer(self, 24, T.GetIconLink(473351), true)
								elseif spellID == 473351 then -- 电气重碾
									T.Start_Text_DelayTimer(self, 20, T.GetIconLink(473351), true)
								end
							end
						end
					end,
				},
				{ -- 打坦计时条 电气重碾（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473351,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 图标 电气重碾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 473836,
					tip = L["DOT"],
				},
			},
		},
		{ -- 音爆
			spells = {
				{473220},
			},
			options = {
				{ -- 计时条 音爆（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473220,
					show_tar = true,
					sound = "[away]cast",
				},
				{ -- 对我施法图标 音爆（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 473220,
					hl = "yel_flash",
					sound = "cd3",
					msg = {str_applied = "%name %spell", str_rep = "%dur"},
				},
				{ -- 首领模块 音爆 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 473220,
					name = T.GetIconLink(473220)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[473220] = {		
								color = {1, 1, 0},
							},
						}
						T.InitCircleCastTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleCastTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleCastTimers(frame)		
					end,
				},
				{ -- 图标 音爆（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 473224,
					hl = "red",
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 夺命封锁屏障
			spells = {
				{469981},
			},
			options = {
				{ -- 文字 夺命封锁屏障 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["BOSS减伤"]..L["倒计时"],
					data = {
						spellID = 469981,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" then
								if spellID == 460156 then -- 快速启动
									T.Start_Text_DelayTimer(self, 68, L["BOSS减伤"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 夺命封锁屏障（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 469981,
					sound = "[heal]cast",
					glow = true,
					group = 1,
				},
				{ -- 图标 夺命封锁屏障（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 469981,
					tip = L["BOSS减伤"].."80%",
				},
			},
		},
	},
}