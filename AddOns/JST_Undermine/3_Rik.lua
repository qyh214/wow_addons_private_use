local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["引柱子"] = "引柱子"
	L["召唤柱子"] = "召唤柱子"
	L["点柱子"] = "点柱子"
	L["点柱子时提示出波"] = "点柱子时提示出波"
	L["增幅器能量和队友DEBUFF监控"] = "%s能量和队友%s监控"
	L["设置增幅器为焦点"] = "设置%s为焦点"
	L["能量过高"] = "能量过高 %d %d"
	L["有盾"] = "|cff37a0ff有盾|r"	
elseif G.Client == "ruRU" then
	L["引柱子"] = "Приманка для усилителя"
	L["召唤柱子"] = "Усилитель"
	L["点柱子"] = "Нажать усилитель"
	L["点柱子时提示出波"] = "Предупреждение о волне при сборе энергии"
	L["增幅器能量和队友DEBUFF监控"] = "Энергия %s и монитор %s игроков"
	L["设置增幅器为焦点"] = "Установить %s как цель фокуса"
	L["能量过高"] = "Высокая энергия %d %d"
	L["有盾"] = "|cff37a0ffЩит|r"
else
	L["引柱子"] = "Bait Amplifier"
	L["召唤柱子"] = "Amplifier"
	L["点柱子"] = "Click Amplifier"
	L["点柱子时提示出波"] = "Alert echo incoming when soaking energy"
	L["增幅器能量和队友DEBUFF监控"] = "%s Energy and player %s monitor"
	L["设置增幅器为焦点"] = "Set %s as focus target"
	L["能量过高"] = "High Power %d %d"
	L["有盾"] = "|cff37a0ffSheild|r"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2641] = {
	engage_id = 3011,
	npc_id = {"228648"},
	alerts = {
		{ -- 增效
			spells = {
				{473748, "5"},
			},
			options = {
				{ -- 文字 增效 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.67, .72, .72},
					preview = L["引柱子"]..L["倒计时"],
					data = {
						spellID = 473748,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[1] = {{11, 38, 38},{11, 38, 38},{11, 38, 38}}
							},
							[16] = {
								[1] = {{11, 38, 38},{11, 38, 38},{11, 38, 38}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 473748, L["引柱子"], self, event, ...)
					end,
				},
				{ -- 计时条 增效（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473748,
					color = {.67, .72, .72},
					text = L["召唤柱子"],
				},
			},
		},
		{ -- 增幅器
			npcs = {
				{31087},
			},
			options = {
				{ -- 图标 残存电伏（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217122,
					tip = L["易伤"].."75%",
					hl = "red",
					msg = {str_applied = "%name %spell", str_stack = "%stack"},
				},
				{ -- 图标 共振回声（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 468119,
					tip = L["强力DOT"],
				},
				{ -- 首领模块 共振回声 多人光环（✓）
					category = "BossMod",
					spellID = 468119,
					enable_tag = "role",
					ficon = "2",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(468119)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 4
						
						frame.spellIDs = {
							[468119] = { -- 共振回声
								color = {.67, .71, .95},
								hl_raid = "proc",
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
				{ -- 首领模块 残存电伏施法 团队框架高亮（待测试）
					category = "BossMod",
					spellID = 1216966,
					enable_tag = "role",
					ficon = "2",
					name = string.format(L["团队框架高亮%s"], T.GetIconLink(1216966)),	
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_CHANNEL_START"] = true,
						["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
					},
					init = function(frame)
						frame.cast_ID = 1216966
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_CHANNEL_START" then
							local unit, _, cast_spellID = ...
							if string.find(unit, "raid") and cast_spellID == frame.cast_ID then
								T.GlowRaidFramebyUnit_Show("proc", "bm"..frame.config_id, unit, {0, 1, 1})
							end
						elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
							local unit, _, cast_spellID = ...
							if string.find(unit, "raid") and cast_spellID == frame.cast_ID then
								T.GlowRaidFramebyUnit_Hide("proc", "bm"..frame.config_id, unit)
							end						
						end
					end,
					reset = function(frame, event)
						T.GlowRaidFrame_HideAll("proc", "bm"..frame.config_id)
					end,
				},
				{ -- 首领模块 增幅器 能量和队友DEBUFF监控（待测试）
					category = "BossMod",
					spellID = 473748,
					enable_tag = "everyone",
					name = string.format(L["增幅器能量和队友DEBUFF监控"], T.GetFomattedNameFromNpcID("230197"), T.GetIconLink(1217122)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 150},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_HEALTH"] = true,
						["RAID_TARGET_UPDATE"] = true,
						["PLAYER_FOCUS_CHANGED"] = true,
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 200,
							min = 150,
							max = 400,
							apply = function(value, alert)
								alert:SetWidth(value)
								alert.bar:SetWidth(value)
								for _, bar in pairs(alert.bars) do
									bar:SetWidth(value)
								end
								alert:line_up()
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 25,
							min = 16,
							max = 45,
							apply = function(value, alert)
								alert:SetHeight(value*3+4)
								alert.bar:SetHeight(value)
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)
								end
								alert:line_up()
							end
						},
						{
							key = "mrt_custom_btn", 
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.assignment = {}
						frame.bars = {}
						frame.sort_bars = {}
						frame.amp_npcID = "230197"
						frame.aura_id = 1217122
						frame.icon = C_Spell.GetSpellTexture(frame.aura_id)
						
						frame.bar = T.CreateTimerBar(frame, 133014, false, false, false, nil, nil, {1, .65, .12})
						frame.bar:SetPoint("TOPLEFT", 0, 0)
						frame.bar:SetMinMaxValues(0, 100)
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
												
						function frame:update_hp()
							local npcID = T.GetUnitNpcID("focus")
							if npcID == self.amp_npcID then
								local hp = UnitHealth("focus")
								local hp_max = UnitHealthMax("focus")
								local perc = hp and hp_max and hp/hp_max*100
								
								self.bar:SetValue(perc)
								self.bar.right:SetText(string.format("%d", perc))
									
								if perc >= 60 and not AuraUtil.FindAuraBySpellID(1213817, "boss1", "HELPFUL") then
									local buff = AuraUtil.FindAuraBySpellID(1214829, "focus", "HELPFUL") and L["有盾"] or ""
									self.text_frame.text:SetText(string.format(L["能量过高"], perc, buff))
									self.bar:SetStatusBarColor(1, 0, 0)
								else
									self.text_frame:Hide()
									self.bar:SetStatusBarColor(1, .65, .12)
								end
							else
								self.bar:SetValue(0)
								self.bar.right:SetText(string.format(L["设置增幅器为焦点"], T.GetFomattedNameFromNpcID("230197")))
								self.text_frame:Hide()
							end
						end
						
						function frame:update_rm()
							local npcID = T.GetUnitNpcID("focus")
							if npcID == self.amp_npcID then
								local mark = GetRaidTargetIndex("focus")
								if mark then
									self.bar.left:SetText(T.FormatRaidMark(mark))
								else
									self.bar.left:SetText("")
								end
							else
								self.bar.left:SetText("")	
							end
						end
						
						function frame:set_rm()
							local npcID = T.GetUnitNpcID("focus")
							if npcID == self.amp_npcID then
								local old_mark = GetRaidTargetIndex("focus") or 9
								if frame.my_index and old_mark ~= frame.my_index then
									SetRaidTarget("focus", frame.my_index)
								end
							end
						end
						
						function frame:line_up()
							self.sort_bars = table.wipe(self.sort_bars)
							
							for _, bar in pairs(self.bars) do
								table.insert(self.sort_bars, bar)
							end
							
							table.sort(self.sort_bars, function(a,b)
								if a.index < b.index then
									return true
								end
							end)
							
							for i, bar in pairs(self.sort_bars) do
								bar:ClearAllPoints()
								if i == 1 then
									bar:SetPoint("TOPLEFT", self.bar, "BOTTOMLEFT", 0, -2)
								else
									bar:SetPoint("TOPLEFT", self.sort_bars[i-1], "BOTTOMLEFT", 0, -2)
								end
							end
						end
						
						function frame:createbar(index, GUID)
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							local h = C.DB["BossMod"][self.config_id]["height_sl"]
							local w = C.DB["BossMod"][self.config_id]["width_sl"]
							
							local bar = T.CreateTimerBar(self, self.icon, false, false, false, w, h, {.24, .37, 1})
							bar.index = index
							
							function bar:stop()
								bar.right:SetText("|cff00ff00Ready|r")
								bar:SetScript("OnUpdate", nil)
							end
							
							function bar:update(stack, exp_time)
								if stack == 0 then
									bar:stop()
								else
									bar.exp_time = exp_time
									bar.stack = stack
									bar:SetScript("OnUpdate", function(s, e)
										s.t = s.t + e
										if s.t > 0.05 then
											s.remain = s.exp_time - GetTime()
											if s.remain > 0 then		
												s.right:SetText(string.format("[%d] %ds", s.stack, s.remain))			
											else
												s:stop()
											end
											s.t = 0
										end
									end)
								end
							end
							
							if GUID then
								bar.GUID = GUID
								bar.left:SetText(info.format_name)
								self.bars[GUID] = bar
							else
								bar.left:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
								self.bars[index] = bar
							end
						end

						function frame:GetMrtAssignment()
							frame.my_index = nil
							
							if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
								local tag = string.format("#%dstart", frame.config_id)
								local text = _G.VExRT.Note.Text1
								
								local betweenLine = false
								local tagmatched = false
								
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										line = T.gsubMarks(line) -- 读取本地化标记文本
										for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
											local info = T.GetGroupInfobyName(name)
											if info and info.GUID == G.PlayerGUID then
												frame.my_index = string.match(line, "{rt(%d)}")
											end
										end
										
										if frame.my_index and string.find(line, string.format("{rt%s}", frame.my_index)) then
											local idx = 0
											for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
												local info = T.GetGroupInfobyName(name)
												if info then
													idx = idx + 1
													frame:createbar(idx, info.GUID)
												else
													T.msg(string.format(L["昵称错误"], name))
												end
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
										tagmatched = true
									end
								end
								
								if not tagmatched then -- 完全没写
									T.msg(string.format(L["MRT数据全部未找到"], T.GetIconLink(frame.config_id), tag))
								end
							end
							
							if frame.my_index then
								frame.my_index = tonumber(frame.my_index)
							end
						end
						
						function frame:copy_mrt()
							local str, raidlist = "", "", ""

							for ind = 1, 8 do
								raidlist = raidlist..string.format("\n{rt%d}", ind) -- 换行
								local i = 0
								for unit in T.IterateGroupMembers() do
									i = i + 1
									if i <= 2 then
										local name = UnitName(unit)
										raidlist = raidlist.." "..T.ColorNameForMrt(name)
									end
								end
							end
							
							local name = C_Spell.GetSpellName(frame.config_id)
							str = string.format("#%sstart%s%s\nend\n", frame.config_id, name, raidlist)
							
							return str
						end
						
						function frame:PreviewShow()
							self:update_hp()
							self:createbar(1)
							self.bars[1]:update(0)
							self:createbar(2)
							self.bars[2]:update(0)
							frame:line_up()
						end
						
						function frame:PreviewHide()
							self.bars[1]:Hide()
							self.bars[1] = nil
							self.bars[2]:Hide()
							self.bars[2] = nil
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE") and spellID == frame.aura_id then
								local bar = frame.bars[destGUID]
								if bar then
									bar:update(amount or 1, GetTime()+45)
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_id then
								local bar = frame.bars[destGUID]
								if bar then
									bar:stop()
								end
							elseif (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_REMOVED") and spellID == 1213817 then -- 声波之云
								frame:update_hp()
							elseif (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_REMOVED") and spellID == 1214829 then -- 反噬抵消器
								frame:update_hp()
							end
						elseif event == "UNIT_HEALTH" then
							local unit = ...
							if unit then
								local npcID = T.GetUnitNpcID(unit)
								if npcID == frame.amp_npcID then
									frame:update_hp()
								end
							end
						elseif event == "RAID_TARGET_UPDATE" then
							frame:update_rm()
						elseif event == "PLAYER_FOCUS_CHANGED" then
							frame:set_rm()
							frame:update_rm()
							frame:update_hp()
						elseif event == "ENCOUNTER_START" then
							frame.assignment = table.wipe(frame.assignment)
							frame:GetMrtAssignment()
							frame:update_rm()
							frame:update_hp()
							
							frame:line_up()
							for GUID, bar in pairs(frame.bars) do
								bar:update(0)
							end
						end
					end,
					reset = function(frame, event)
						for GUID, bar in pairs(frame.bars) do
							bar:Hide()
							bar:SetScript("OnUpdate", nil)
							frame.bars[GUID] = nil
						end
						frame:Hide()
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},				
				{ -- 首领模块 残存电伏 多人光环
					category = "BossMod",
					spellID = 1217122,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1217122)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -500},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 10
						
						frame.spellIDs = {
							[1217122] = { -- 残存电伏
								color = {1, .65, .12},
								progress_stack = 10,
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
				{ -- 首领模块 小怪血量 增幅器（✓）
					category = "BossMod",
					spellID = 1214829,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("233623")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["UNIT_AURA"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.format = "value"
						
						function frame:post_update_health(bar, unit)
							if AuraUtil.FindAuraBySpellID(1214829, unit, "HELPFUL") then
								bar:SetStatusBarColor(0, .45, .88)
							else
								bar:SetStatusBarColor(.52, .52, .52)
							end
						end
						
						frame.npcIDs = {
							["230197"] = {color = {.52, .52, .52}}, -- 增幅器
						}
						
						frame.auras = {
							[1214829] = { -- 反噬抵消器
								aura_type = "HELPFUL",
								color = {0, .6, 1},
							},
						}
						
						T.InitMobHealth(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobHealth(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobHealth(frame)
					end,
				},
			},
		},
		{ -- 回响之歌
			spells = {
				{466866},
			},
			options = {
				{ -- 计时条 回响之歌（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466866,
					color = {1, .67, .47},
					text = L["注意躲波"],
					sound = "[wave]cast",
				},
				{ -- 计时条 回响之歌（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 466866,
					dur = 4,
					color = {1, .67, .47},
				},
			},
		},
		{ -- 音波大炮
			spells = {
				{467606},
			},
			options = {
				{ -- 文字 音波大炮 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.47, .26, .94},
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 467606,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {{32, 34},{32, 34},{32, 34}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 467606, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 音波大炮（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 467606,
					color = {.47, .26, .94},
				},
				{ -- 图标 音波大炮（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 469380,
					hl = "org_flash",
				},
				{ -- 首领模块 音波大炮 计时圆圈（✓）
					category = "BossMod",
					spellID = 469380,
					enable_tag = "none",
					name = T.GetIconLink(469380)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[469380] = { -- 音波大炮
								unit = "player",
								aura_type = "HARMFUL",
								color = {.47, .26, .94},
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
		{ -- 故障震击
			spells = {
				{466961},
			},
			options = {
				{ -- 文字 故障震击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {0, .45, 1},
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 466979,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[1] = {{43, 31, 26},{43, 31, 26},{43, 31, 26}}
							},
							[16] = {
								[1] = {{43, 31, 26},{43, 31, 26},{43, 31, 26}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 466979, L["放圈"], self, event, ...)
					end,
				},
				{ -- 计时条 故障震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466979,
					color = {0, .45, 1},
					text = L["放圈"],
				},
				{ -- 图标 故障震击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 467108,
					hl = "org_flash",
					tip = L["放圈"],
				},
				{ -- 图标 故障震击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 467044,
					hl = "org",
					tip = L["DOT"],
				},
				{ -- 首领模块 故障震击 计时圆圈（✓）
					category = "BossMod",
					spellID = 467108,
					enable_tag = "none",
					name = T.GetIconLink(467108)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[467108] = { -- 故障震击
								unit = "player",
								aura_type = "HARMFUL",
								color = {0, .45, 1},
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
				{ -- 首领模块 故障震击 点名统计 整体排序（✓）
					category = "BossMod",
					spellID = 466961,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(467108)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 467108
						frame.element_type = "bar"
						frame.color = {0, .45, 1}
						frame.raid_glow = "pixel"
						frame.raid_index = true						
						
						function frame:custom_sort(cache)
							T.SortTable(cache)
						end
						
						frame.info = {
							{text = L["近战"], msg_applied = L["近战"]},
							{text = L["近战"], msg_applied = L["近战"]},
							{text = L["远程"], msg_applied = L["远程"]},
							{text = L["远程"], msg_applied = L["远程"]},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 9, frame.info[index].text)
							end
						end
						
						function frame:post_remove(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Stop_Text_Timer(self.text_frame)
							end
						end
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
					end,
				},
			},
		},
		{ -- 电轰点火
			spells = {
				{472306},
			},
			options = {
				{ -- 文字 电轰点火 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, .12, .46},
					preview = L["小怪"]..L["倒计时"],
					data = {
						spellID = 472306,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if cast_spellID == 472306 and cast_GUID and cast_GUID ~= self.last_cast_GUID then -- 电轰点火	
								self.last_cast_GUID = cast_GUID
								self.spell_count = self.spell_count + 1
								if self.spell_count == 1 then
									T.Start_Text_DelayTimer(self, 58, L["召唤小怪"], true)
								elseif self.spell_count == 2 then
									T.Start_Text_DelayTimer(self, 22, L["召唤小怪"], true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 1 then
								self.spell_count = 0
								T.Start_Text_DelayTimer(self, 20, L["召唤小怪"], true)
							end	
						elseif event == "ENCOUNTER_START" then
							self.spell_count = 0
							self.last_cast_GUID = 0
							T.Start_Text_DelayTimer(self, 20, L["召唤小怪"], true)
						end
					end,
				},
				{ -- 计时条 电轰点火（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 472306,
					dur = 4.5,
					color = {1, .12, .46},
					sound = "[add]cast",
					text = L["小怪"],
				},				
				{ -- 首领模块 小怪血量 烟火之术（✓）
					category = "BossMod",
					spellID = 472306,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("233623")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["233623"] = {color = {.39, .58, .96}}, -- 烟火之术
						}
						
						T.InitMobHealth(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobHealth(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobHealth(frame)
					end,
				},
				{ -- 图标 刺激（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1214164,
					tip = L["加速"].."%s10%",
				},
			},
		},
		{ -- 音波冲击
			spells = {
				{464488, "0"},
			},
			options = {
				{ -- 图标 耳鸣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464518,
					tip = L["易伤"].."%s100%",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 464518,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(464518)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[464518] = { -- 耳鸣
								color = {1, .79, .55},
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
		{ -- 声波之云
			spells = {
				{1213817},
			},
			options = {
				{ -- 文字 声波之云 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.48, 1, .21},
					preview = L["阶段转换"]..L["倒计时"],
					data = {
						spellID = 464584,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {{115},{115},{115}}
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 464584, L["阶段转换"], self, event, ...)
					end,
				},
				{ -- 计时条 声波之云（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464584,
					color = {.48, 1, .21},
					sound = "[phase]cast",
				},
				{ -- 图标 声波之云（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 1213817,
					tip = L["BOSS免疫"],
				},
			},
		},
		{ -- 高音骤降
			spells = {
				{467991, "4"},
				{466722, "5"},
			},
			options = {
				{ -- 计时条 高音骤降（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473260,
					color = {.16, .32, 1},
					glow = true,
				},
			},
		},
		{ -- 劲音狂热！
			spells = {
				{473655, "4"},
			},
			options = {
				{ -- 计时条 劲音狂热！（待测试）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 473655,
					color = {.88, .14, .07},
					glow = true,
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
					spellID = 1213817, -- 声波之云
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 464584, -- 声波之云
				},
			},
		},
	},
}