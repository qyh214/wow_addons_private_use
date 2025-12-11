local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1298\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2649] = {
	engage_id = 3019,
	npc_id = {"226403", "226402"},
	alerts = {
		{ -- 齐扎:天降神雷
			spells = {
				{460867},
			},
			options = {				
				{ -- 计时条 天降神雷（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 460867,
					sound = "[bomb]cast",
				},
				{ -- 文字 天降神雷 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["炸弹"]..L["倒计时"],
					data = {
						spellID = 460867,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 460867 then -- 天降神雷
								if not self.GUIDs then
									self.GUIDs = {}
								else
									self.GUIDs = table.wipe(self.GUIDs)
								end
								
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 460781 then -- 天降神雷
								if not tContains(self.GUIDs, destGUID) then
									table.insert(self.GUIDs, destGUID)
									self.count = #self.GUIDs
								end
								
								if self.count == 1 then
									self:Show()
									self.exp_time = GetTime() + 30
								
									self:SetScript("OnUpdate", function(s, e)
										s.t = s.t + e
										if s.t > 0.05 then
											s.remain = s.exp_time - GetTime()
											if s.remain > 0 then
												s.text:SetText(string.format("%s%d/6 %.1f", L["炸弹"], s.count, s.remain))	
											else
												s:Hide()
												s:SetScript("OnUpdate", nil)
											end
											s.t = 0
										end
									end)
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 460781 then -- 天降神雷
								if tContains(self.GUIDs, destGUID) then
									tDeleteItem(self.GUIDs, destGUID)
									self.count = #self.GUIDs
								end
								
								if self.count == 0 then
									self:Hide()
									self:SetScript("OnUpdate", nil)
									self.text:SetText("")
								end
							end
						end
					end,
				},	
				{ -- 图标 爆燃（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 461994,
					tip = L["强力DOT"],
					ficon = "4",
				},
				{ -- 自保技能提示 爆燃（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 461994,
					threshold = 65,
				},
			},
		},
		{ -- 齐扎:B.B.B.F.G.
			spells = {
				{1217653},
			},
			options = {
				{ -- 计时条 B.B.B.F.G.（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1217653,
					sound = "[ray]cast",
				},
			},
		},
		{ -- 齐扎:快速射击
			spells = {
				{460602},
			},
			options = {
				{ -- 对我施法图标 快速射击（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 460602,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 快速射击（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 460602,
				},
			},
		},
		{ -- 齐扎:动能胶质炸药
			spells = {
				{473690},
			},
			options = {
				{ -- 计时条 动能胶质炸药（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473690,
					show_tar = true,
					sound = "[boom_dispose]cast",
				},
				{ -- 图标 动能胶质炸药（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 473713,
					hl = "org_flash",
					ficon = "7",
					msg = {str_applied = "{rt7}%spell %name", str_rep = "{rt7}"},
				},
				{ -- 自保技能提示 动能胶质炸药（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 473713,
					threshold = 80,
				},
				{ -- 团队框架高亮 动能胶质炸药（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 473713,
					color = "blu",
				},
			},
		},
		{ -- 布隆特:滚桶冲锋
			spells = {
				{459779},
			},
			options = {
				{ -- 计时条 滚桶冲锋（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 470022,
					dur = 3.5,
					text = L["冲锋"],
					show_tar = true,
					sound = "[charge]cd3",
					glow = true,
					group = 1,
				},
				{ -- 图标 滚桶冲锋（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 470022,
					hl = "org_flash",
					tip = L["冲锋"],
					msg = {str_applied = "%name %spell"},
				},
				{ -- 首领模块 滚桶冲锋 计时圆圈（✓）
					category = "BossMod",
					spellID = 470022,
					name = T.GetIconLink(470022)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[470022] = { -- 滚桶冲锋
								event = "SPELL_AURA_APPLIED",
								target_me = true,
								dur = 3.5,
								color = {1, 1, 0},
								reverse = true,
							},
						}
						T.InitCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleTimers(frame)
					end,
				},
			},
		},
		{ -- 布隆特:重击
			spells = {
				{459799, "0"},
			},
			options = {
				{ -- 文字 重击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = L["击飞"]..L["倒计时"],
					data = {
						spellID = 459799,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						info = {6, 38, 33, 36, 33, 17, 19}
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.enrage = false
							self.spell_count = 1
							
							T.Start_Text_DelayTimer(self, self.data.info[self.spell_count], L["击飞"], true)
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, extraSpellId = CombatLogGetCurrentEventInfo()
							if not self.enrage and sub_event == "SPELL_CAST_START" and spellID == 459799 then
								self.spell_count = self.spell_count + 1
								if self.data.info[self.spell_count] then
									T.Start_Text_DelayTimer(self, self.data.info[self.spell_count], L["击飞"], true)
								end
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 470090 then -- 天人永隔
								self.enrage = true
								T.Stop_Text_Timer(self)
							end
						end
					end,
				},
				{ -- 打坦计时条 重击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 459799,
					group = 1,
					ficon = "0",
					sound = "[knockoff]cast",
				},
			},
		},
		{ -- 天人永隔
			spells = {
				{470090},
			},
			options = {
				{ -- 血量对比（✓）
					category = "BossMod",
					spellID = 470090,
					name = L["技能提示"].." "..L["NAME血量对比"],
					points = {hide = true},
					events = {
						["UNIT_HEALTH"] = true,
						["PLAYER_TARGET_CHANGED"] = true,
					},
					init = function(frame)						
						frame.units = {
							["boss1"] = 0,
							["boss2"] = 0,
						}
						
						frame.max = 0
						frame.min = 0
						frame.avr = 0		
						frame.targetboss = false
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
		
						function frame:GetAverage()
							self.max = math.max(self.units["boss1"], self.units["boss2"])
							self.min = math.min(self.units["boss1"], self.units["boss2"])
							self.avr = (self.units["boss1"]+self.units["boss2"])/2
						end
											
						function frame:UpdateTarget()
							self.targetboss = false
							for unit in pairs(self.units) do
								if UnitIsUnit("target", unit) then
									self.targetboss = true
									return
								end
							end
						end
						
						function frame:UpdateText()					
							if UnitExists("target") and self.targetboss then
								local target_hp = UnitHealth("target")
								local cap_hp = UnitHealthMax("target")*0.1
								local text, value
								
								if target_hp > self.avr then
									text = L["落后"]
									value = target_hp - self.min
								else
									text = L["领先"]
									value = self.max - target_hp
								end
								
								if value > cap_hp then
									self.text_frame.text:SetText(string.format(text, T.ShortValue(value)))
									if not self.text_frame:IsShown() then
										self.text_frame:Show()
									end
								else
									if self.text_frame:IsShown() then
										self.text_frame:Hide()
									end
								end
							else
								if self.text_frame:IsShown() then
									self.text_frame:Hide()
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_HEALTH" then
							local unit = ...
							if unit and frame.units[unit] then
								frame.units[unit] = UnitHealth(unit)
								frame:GetAverage()
								frame:UpdateText()
							end
						elseif event == "PLAYER_TARGET_CHANGED" then
							frame:UpdateTarget()
							frame:UpdateText()
						elseif event == "ENCOUNTER_START" then			
							for _, v in pairs(frame.units) do
								v = 0
							end
							
							frame:GetAverage()
							
							C_Timer.After(1, function() -- 等单位出现
								frame:UpdateTarget()
								frame:UpdateText()
							end)
						end
					end,
					reset = function(frame, event)
						frame.text_frame:Hide()
					end,
				},
			},
		},
	},	
}