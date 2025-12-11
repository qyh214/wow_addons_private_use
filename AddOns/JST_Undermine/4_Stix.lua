local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["螃蟹"] = "螃蟹"
	L["撞炸弹"] = "炸弹"
	L["撞BOSS"] = "BOSS"
	L["分散躲垃圾"] = "分散躲垃圾"
	L["小球"] = "小球"
	L["中球"] = "中球"
	L["大球"] = "大球"
elseif G.Client == "ruRU" then
	L["螃蟹"] = "Краб"
	L["撞炸弹"] = "Бомба"
	L["撞BOSS"] = "БОСС"
	L["分散躲垃圾"] = "Разбежаться и избегать мусора"
	L["小球"] = "Малый"
	L["中球"] = "Средний"
	L["大球"] = "Большой"
else
	L["螃蟹"] = "Bombshell"
	L["撞炸弹"] = "Bomb"
	L["撞BOSS"] = "BOSS"
	L["分散躲垃圾"] = "Spread and avoid garbage"
	L["小球"] = "S"
	L["中球"] = "M"
	L["大球"] = "L"
end

---------------------------------Notes--------------------------------
-- 特殊能量测试

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2642] = {
	engage_id = 3012,
	npc_id = {"230322"},
	alerts = {
		{ -- 电磁分拣
			spells = {
				{464399, "2,5"},
			},
			options = {
				{ -- 文字提示 能量（✓）
					category = "TextAlert",
					type = "pp",
					data = {
						npc_id = "230322",
						ranges = {
							{ ul = 99, ll = 90, tip = T.GetIconLink(464399)..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 电磁分拣（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464399,
					color = {.45, .9, .82},
					glow = true,
				},
				{ -- 图标 被分拣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 465346,
					hl = "red_flash",
				},
				{ -- 首领模块 被分拣 计时圆圈（✓）
					category = "BossMod",
					spellID = 464399,
					enable_tag = "none",
					name = T.GetIconLink(465346)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[465346] = { -- 被分拣
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
				{ -- 首领模块 被分拣 整体排序（✓）
					category = "BossMod",
					spellID = 465346,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(465346)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 465346
						frame.element_type = "bar"
						frame.color = {1, .2, .2}
						frame.textures = {}
						frame.mrt_copy_custom = true
						frame.count = 0
						frame.role = true
						
						frame.diffculty_num = {
							[14] = 5, -- PT
							[15] = 5, -- H
							[16] = 4, -- M
						}
						
						frame.info = {
							{text = "1"..T.FormatRaidMark("1"), msg_applied = "{rt1} %name", msg = "{rt1}"},
							{text = "2"..T.FormatRaidMark("2"), msg_applied = "{rt2} %name", msg = "{rt2}"},
							{text = "3"..T.FormatRaidMark("3"), msg_applied = "{rt3} %name", msg = "{rt3}"},
							{text = "4"..T.FormatRaidMark("4"), msg_applied = "{rt4} %name", msg = "{rt4}"},
							{text = "5"..T.FormatRaidMark("5"), msg_applied = "{rt5} %name", msg = "{rt5}"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:post_display(element, index, unit, GUID)
							G.CantInterruptPlayerGUIDs[GUID] = true -- 不能打断
							if index == 2 or (index == 3 and self.count > 1) then
								T.FireEvent("JST_CUSTOM", self.config_id, GUID, index, "to_bomb")
								if GUID == G.PlayerGUID then
									T.PlaySound("1296\\to_bomb")
									T.Start_Text_Timer(frame.text_frame, 5, string.format("%s %s", T.FormatRaidMark(index), L["撞炸弹"]))
								end
							else
								T.FireEvent("JST_CUSTOM", self.config_id, GUID, index, "to_boss")
								if GUID == G.PlayerGUID then
									T.PlaySound("1296\\to_boss")
									T.Start_Text_Timer(frame.text_frame, 5, string.format("%s %s", T.FormatRaidMark(index), L["撞BOSS"]))
								end
							end
						end
						
						function frame:post_remove(element, index, unit, GUID)
							G.CantInterruptPlayerGUIDs[GUID] = nil -- 可以打断
							T.Stop_Text_Timer(self.text_frame)
						end
						
						T.InitAuraMods_ByMrt(frame)					
					end,
					update = function(frame, event, ...)						
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},				
			},
		},
		{ -- 滚动的垃圾
			spells = {
				{461536},
			},
			options = {
				{ -- 图标 滚动的垃圾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 461536,
					hl = "",
				},
				{ -- 首领模块 滚动的垃圾 多人光环（待测试）
					category = "BossMod",
					spellID = 461536,
					enable_tag = "everyone",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(461536)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 230},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_CUSTOM"] = true,
						["CHAT_MSG_MONSTER_EMOTE"] = true,
						["UNIT_POWER_FREQUENT"] = true,
						["ADDON_MSG"] = true,	
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 180,
							min = 150,
							max = 400,
							apply = function(value, alert)
								alert:SetWidth(value)
								alert.bar1:SetWidth(value)
								alert.bar2:SetWidth(value)
								for _, bar in pairs(alert.bars) do
									bar:SetWidth(value)
								end
								alert:line_up()
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 20,
							min = 16,
							max = 45,
							apply = function(value, alert)
								alert:SetHeight(value*7+12)
								alert.bar1:SetHeight(value)
								alert.bar2:SetHeight(value)
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)
								end
								alert:line_up()
							end
						},
						{
							key = "my_width_sl",
							text = L["能量提示"]..L["长度"],
							default = 300,
							min = 200,
							max = 600,
							apply = function(value, alert)
								alert.bar_frame:SetWidth(value)
							end
						},
						{
							key = "my_height_sl",
							text = L["能量提示"]..L["高度"],
							default = 20,
							min = 16,
							max = 45,
							apply = function(value, alert)
								alert.bar_frame:SetHeight(value)
							end
						},
					},
					init = function(frame)
						frame.aura_spellID = 461536
						
						frame.spell = C_Spell.GetSpellName(frame.aura_spellID)
						frame.icon = C_Spell.GetSpellTexture(frame.aura_spellID)
						frame.bomb_name = T.GetNameFromNpcID("230863")
						frame.bomb_count = 0
						
						frame.bars = {}
						frame.barsbyGUID = {}
						frame.assigns = {}
						frame.targetsbyName = {}
						
						frame.direction = {
							"1"..T.FormatRaidMark("1"),
							"2"..T.FormatRaidMark("2"),
							"3"..T.FormatRaidMark("3"),
							"4"..T.FormatRaidMark("4"),
							"5"..T.FormatRaidMark("5"),
						}
						
						frame.destination = {
							to_bomb = L["撞炸弹"], 
							to_boss = L["撞BOSS"],
						}
						
						frame.garbage_size = {
							{L["小球"], {1, 0, 0}},
							{L["中球"], {1, 1, 0}},
							{L["大球"], {0, 1, 0}},
						}
						
						frame.targets = {
							{"231531", L["螃蟹"], 5874200, {1, 0, 0}},
							{"230322", "BOSS", 6392627, {0, 1, 0}},
							{"230863", L["炸弹"], 2115301, {1, 1, 0}},
						}
						
						for index, info in pairs(frame.targets) do
							local name = T.GetNameFromNpcID(info[1])
							frame.targetsbyName[name] = info
						end
						
						function frame:GetAssignStr(index, target)
							if index and target then
								local direction = index and frame.direction[index] or ""
								local destination = target and frame.destination[target] or ""
								return direction.." "..destination
							else
								return "?"
							end
						end
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.text_frame.count_down_start = 6
						frame.text_frame.prepare_sound = "end_soon" --[音效:即将结束]
						
						T.CreateMovableFrame(frame, "bar_frame", 300, 30, {a1 = "CENTER", a2 = "CENTER", x = 0, y = 300}, "_Powerbar", frame.spell..L["进度"])
						frame.bar = T.CreateTimerBar(frame.bar_frame, frame.icon, false, false, true, nil, nil, {1, 0, 0})
						frame.bar:SetAllPoints(frame.bar_frame)
						frame.bar:SetMinMaxValues(0, 200)
						
						T.CreateTagsforBar(frame.bar, 1)
						frame.bar:pointtag(1, .5)
						
						frame.bar1 = T.CreateTimerBar(frame, 2115301, false, false, true, nil, nil, {1, 0, 0})
						frame.bar1:SetPoint("TOPLEFT", 0, 0)
						frame.bar1:SetMinMaxValues(0, 24.5)
						frame.bar1.left:SetText(L["炸弹"])
						
						frame.bar2 = T.CreateTimerBar(frame, 2115301, false, false, true, nil, nil, {1, 0, 0})
						frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -2)
						frame.bar2:SetMinMaxValues(0, 24.5)
						frame.bar2.left:SetText(L["炸弹"])
						
						function frame:start_bomb_timer(bar)							
							bar.right:SetText("")
							bar.exp_time = GetTime() + 24.5
					
							bar:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > .05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > 0 then
										s:SetValue(s.remain)
										s.right:SetText(string.format("%.1fs", s.remain))
									else
										s:SetScript("OnUpdate", nil)
										s:Hide()
									end
								end
							end)
							
							bar:Show()
						end
						
						function frame:stop_bomb_timer(bar)
							bar:SetScript("OnUpdate", nil)
							bar:Hide()
						end
						
						function frame:line_up()
							table.sort(self.bars, function(a, b)
								if a.index < b.index then
									return true
								end
							end)
							
							local count = 1
							for _, bar in pairs(self.bars) do
								if bar:IsShown() then
									bar:ClearAllPoints()
									bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(count+1)*(C.DB["BossMod"][self.config_id]["height_sl"]+2))
									count = count + 1
								end
							end
						end
						
						function frame:CreateNewBar(GUID, index, str, format_name)
							local bar = T.CreateTimerBar(self, self.icon, false, true, false, C.DB["BossMod"][self.config_id]["width_sl"], C.DB["BossMod"][self.config_id]["height_sl"], {.67, .36, 1})
							
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							local role_tag = info and T.UpdateRoleTag(info.role, info.pos) or ""
							
							bar:SetMinMaxValues(0, 24)
							
							bar.left:SetText(str.." "..role_tag..format_name)
							bar.mid:ClearAllPoints()
							bar.mid:SetPoint("LEFT", bar, "RIGHT", 2, 0)
							bar.mid:SetText("")

							bar.exp_time = GetTime() + 24
							bar.index = index or 0
							
							bar:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > .05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > 0 then
										s:SetValue(s.remain)
										s.right:SetText(string.format("%.1fs", s.remain))
									else
										s:SetScript("OnUpdate", nil)
										s:Hide()
									end
								end
							end)
							
							bar:SetScript("OnHide", function()
								self:line_up()
							end)
							
							table.insert(self.bars, bar)
							
							if GUID then
								self.barsbyGUID[GUID] = bar
							end
							
							self:line_up()
						end
						
						function frame:CreateCrashBar(GUID, index, format_name, target)							
							local info = frame.targetsbyName[target]
							
							if info then
								local bar = T.CreateTimerBar(self, self.icon, false, true, false, C.DB["BossMod"][self.config_id]["width_sl"], C.DB["BossMod"][self.config_id]["height_sl"], info[4])

								bar.left:SetText(format_name)
								bar.right:SetText(info[2])
								bar.icon:SetTexture(info[3])
								
								bar.exp_time = GetTime() + 3
								bar.index = index or 0
								
								bar:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > .05 then
										s.remain = s.exp_time - GetTime()
										if s.remain <= 0 then
											s:SetScript("OnUpdate", nil)
											s:Hide()
										end
									end
								end)
								
								bar:SetScript("OnHide", function()
									self:line_up()
								end)
								
								table.insert(self.bars, bar)
								
								self:line_up()
							end
						end
						
						function frame:CancelBar(GUID)
							local bar = self.barsbyGUID[GUID]
							if bar then
								bar:Hide()
								bar:SetScript("OnUpdate", nil)
								self.barsbyGUID[GUID] = nil
							end
						end
						
						function frame:update_my_status(start)
							self.text_frame.cur_text = string.format("%s [%s]", self.my_str, self.garbage_size[self.my_size][1])
							self.bar:SetStatusBarColor(unpack(self.garbage_size[self.my_size][2]))
							
							self.bar:SetValue(self.my_value)
							self.bar.left:SetText(self.my_str)
							self.bar.right:SetText(self.my_value)
							
							if start then
								T.Start_Text_Timer(self.text_frame, 24, self.text_frame.cur_text, true)
								self.bar:Show()
							end
						end
						
						function frame:hide_my_status()
							T.Stop_Text_Timer(self.text_frame)
							self.bar:Hide()
						end
						
						function frame:PreviewShow()
							self:start_bomb_timer(self.bar1)
							self:start_bomb_timer(self.bar2)
							for index = 1, 5 do
								local str = self:GetAssignStr(index, index == 2 and "to_bomb" or "to_boss")
								self:CreateNewBar(nil, index, str, T.ColorNickNameByGUID(G.PlayerGUID))
							end
							
							self.bar:SetStatusBarColor(unpack(self.garbage_size[2][2]))
							self.bar:SetValue(120)
							self.bar.left:SetText(self:GetAssignStr(1, "to_boss"))
							self.bar.right:SetText(120)
							self.bar:Show()
						end
						
						function frame:PreviewHide()
							self:stop_bomb_timer(self.bar1)
							self:stop_bomb_timer(self.bar2)
							for _, bar in pairs(self.bars) do
								bar:Hide()
								bar:SetScript("OnUpdate", nil)
							end
							self.bars = table.wipe(self.bars)
							self.bar:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_spellID then
								local index = frame.assigns[destGUID] and frame.assigns[destGUID].index
								local target = frame.assigns[destGUID] and frame.assigns[destGUID].target
								local str = frame:GetAssignStr(index, target)
								
								G.CantInterruptPlayerGUIDs[destGUID] = true -- 不能打断
								frame:CreateNewBar(destGUID, index, str, T.ColorNickNameByGUID(destGUID))
								
								if destGUID == G.PlayerGUID then
									frame.my_size = 1
									frame.my_value = 0
									frame.my_str = str
									frame:update_my_status(true)
									T.addon_msg("ShareCollectSize,"..frame.my_size, "GROUP")
								end	
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_spellID then
								G.CantInterruptPlayerGUIDs[destGUID] = nil -- 可以打断
								frame:CancelBar(destGUID)
								
								if destGUID == G.PlayerGUID then
									frame.my_str = nil
									frame:hide_my_status()
								end								
								
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 464399 then -- 电磁分拣
								if AuraUtil.FindAuraBySpellID(473227, "boss1", "HELPFUL") then
									frame.bomb_count = 2
									frame:start_bomb_timer(frame.bar1)
									frame:start_bomb_timer(frame.bar2)
								else
									frame.bomb_count = 1
									frame:start_bomb_timer(frame.bar1)
								end
							end
						elseif event == "CHAT_MSG_MONSTER_EMOTE" then
							local text, playerName, _, _, playerName2, _, _, _, _, _, _, GUID = ...
							if string.find(text, frame.spell) then
								local index = frame.assigns[GUID] and frame.assigns[GUID].index or 0
								frame:CreateCrashBar(GUID, index, T.ColorNickNameByGUID(GUID), playerName2)
								
								if playerName2 == frame.bomb_name then
									frame.bomb_count = frame.bomb_count - 1
									if frame.bomb_count == 1 then
										frame:stop_bomb_timer(frame.bar2)
									else
										frame:stop_bomb_timer(frame.bar1)
									end
								end
							end
						elseif event == "UNIT_POWER_FREQUENT" then
							local unit = ...
							if unit == "player" and frame.my_str then
								local value = UnitPower(unit, 10)
								local cur_size = (value == 200 and 3) or (value >= 100 and 2) or 1

								if cur_size ~= frame.my_size then
									frame.my_size = cur_size
									T.addon_msg("ShareCollectSize,"..frame.my_size, "GROUP")
									
									if cur_size == 2 then
										T.PlaySound("1296\\size_mid")
									elseif cur_size == 3 then
										T.PlaySound("1296\\size_big")										
									end
								end
								
								frame.my_value = value
								frame:update_my_status()
							end
						elseif event == "ADDON_MSG" then
							local channel, sender, GUID, message, size_text = ...
							if message == "ShareCollectSize" then
								local size = tonumber(size_text)
								local bar = frame.barsbyGUID[GUID]
								if size and bar then
									bar.mid:SetText(frame.garbage_size[size][1])
								end
							end
						elseif event == "JST_CUSTOM" then
							local spellID, GUID, index, target = ...
							if spellID == 465346 then
								frame.assigns[GUID] = {index = index, target = target}
							end
						elseif event == "ENCOUNTER_START" then
							frame.assigns = table.wipe(frame.assigns)
						end
					end,
					reset = function(frame, event)	
						frame:stop_bomb_timer(frame.bar1)
						frame:stop_bomb_timer(frame.bar2)
						for _, bar in pairs(frame.bars) do
							bar:Hide()
							bar:SetScript("OnUpdate", nil)
						end
						frame.bars = table.wipe(frame.bars)
						frame.barsbyGUID = table.wipe(frame.barsbyGUID)
						frame:hide_my_status()
					end,
				},
			},
		},
		{ -- 垃圾堆
			spells = {
				{464854},
			},
			options = {
				{ -- 图标 垃圾堆（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464854,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 丢弃的毁灭炸弹
			spells = {
				{464865},
			},
			options = {
				{ -- 首领模块 丢弃的毁灭炸弹 计时条
					category = "BossMod",
					spellID = 464865,
					enable_tag = "none",
					name = T.GetIconLink(464865)..L["计时条"],
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = 210, y = 175},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["CHAT_MSG_MONSTER_EMOTE"] = true,
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 250,
							min = 200,
							max = 400,
							apply = function(value, alert)
								alert:SetWidth(value)
								alert.bar1:SetWidth(value)
								alert.bar2:SetWidth(value)
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 30,
							min = 20,
							max = 45,
							apply = function(value, alert)
								alert:SetHeight(value*2+2)
								alert.bar1:SetHeight(value)
								alert.bar2:SetHeight(value)
							end
						},
					},
					init = function(frame)
						frame.aura_spellID = 461536
						frame.spell = C_Spell.GetSpellName(frame.aura_spellID)
						frame.icon = C_Spell.GetSpellTexture(frame.aura_spellID)
						frame.bomb_name = T.GetNameFromNpcID("230863")
						frame.bomb_count = 0

						frame.bar1 = T.CreateTimerBar(frame, 2115301, false, false, true, nil, nil, {1, 0, 0})
						frame.bar1:SetPoint("TOPLEFT", 0, 0)
						frame.bar1:SetMinMaxValues(0, 24.5)
						frame.bar1.left:SetText(L["炸弹"])
						
						frame.bar2 = T.CreateTimerBar(frame, 2115301, false, false, true, nil, nil, {1, 0, 0})
						frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -2)
						frame.bar2:SetMinMaxValues(0, 24.5)
						frame.bar2.left:SetText(L["炸弹"])
						
						function frame:start_bomb_timer(bar)							
							bar.right:SetText("")
							bar.exp_time = GetTime() + 24.5
					
							bar:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > .05 then
									s.remain = s.exp_time - GetTime()
									if s.remain > 0 then
										s:SetValue(s.remain)
										s.right:SetText(string.format("%.1fs", s.remain))
									else
										s:SetScript("OnUpdate", nil)
										s:Hide()
									end
								end
							end)
							
							bar:Show()
						end
						
						function frame:stop_bomb_timer(bar)
							bar:SetScript("OnUpdate", nil)
							bar:Hide()
						end
						
						function frame:PreviewShow()
							self:start_bomb_timer(self.bar1)
							self:start_bomb_timer(self.bar2)
						end
						
						function frame:PreviewHide()
							self:stop_bomb_timer(self.bar1)
							self:stop_bomb_timer(self.bar2)
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 464399 then -- 电磁分拣
								if AuraUtil.FindAuraBySpellID(473227, "boss1", "HELPFUL") then
									frame.bomb_count = 2
									frame:start_bomb_timer(frame.bar1)
									frame:start_bomb_timer(frame.bar2)
								else
									frame.bomb_count = 1
									frame:start_bomb_timer(frame.bar1)
								end
							end
						elseif event == "CHAT_MSG_MONSTER_EMOTE" then
							local text, playerName, _, _, playerName2, _, _, _, _, _, _, GUID = ...
							if string.find(text, frame.spell) then
								if playerName2 == frame.bomb_name then
									frame.bomb_count = frame.bomb_count - 1
									if frame.bomb_count == 1 then
										frame:stop_bomb_timer(frame.bar2)
									else
										frame:stop_bomb_timer(frame.bar1)
									end
								end
							end
						end
					end,
					reset = function(frame, event)
						frame:stop_bomb_timer(frame.bar1)
						frame:stop_bomb_timer(frame.bar2)
					end,
				},
				{ -- 图标 毁灭爆破（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 1217975,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 领地爆壳蟹
			npcs = {
				{30451},
			},
			options = {
				{ -- 首领模块 小怪血量 领地爆壳蟹（✓）
					category = "BossMod",
					spellID = 473066,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("231531")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -300},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["231531"] = {color = {.39, .58, .96}}, -- 领地爆壳蟹
						}
						
						frame.auras = {
							[473066] = { -- 捍卫领地
								aura_type = "HELPFUL",
								color = {1, .3, 0},
							},
							[473115] = { -- 超短引线
								aura_type = "HELPFUL",
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
				{ -- 图标 超短引线（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 473119,
					tip = L["DOT"],
				},
				{ -- 姓名板NPC高亮 领地爆壳蟹
					category = "PlateAlert",
					type = "PlateNpcID",
					mobID = "231531",
					hl_np = true,
				},	
				{ -- 首领模块 姓名板标记 领地爆壳蟹
					category = "BossMod",
					spellID = 473119,
					enable_tag = "none",
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("231531")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_AURA"] = true,
					},
					custom = {
						{
							key = "always_bool", 
							text = L["总是显示标记"],
							default = false,
						},
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("avoid")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						frame.mobID = "231531"
						frame.debuffed = false
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							if frame.debuffed or C.DB["BossMod"][frame.config_id]["always_bool"] then
								local unit = ...
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID == frame.mobID then
									T.ShowNameplateExtraTex(unit, "avoid")
								end
							end
						elseif event == "UNIT_AURA" then
							local unit = ...
							if unit == "player" and not C.DB["BossMod"][frame.config_id]["always_bool"] then
								if AuraUtil.FindAuraBySpellID(461536, "player", "HARMFUL") then -- 滚动的垃圾
									if not frame.debuffed then
										frame.debuffed = true
										for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
											local unit = namePlate.jstuf and namePlate.jstuf.unit
											if unit then
												local npcID = T.GetUnitNpcID(unit)
												if npcID and npcID == frame.mobID then
													T.ShowNameplateExtraTex(unit, "avoid")
												end
											end
										end
									end
								else
									if frame.debuffed then
										frame.debuffed = false
										T.HideAllNameplateExtraTex()
									end
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.debuffed = false
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
			},
		},
		{ -- 原型能源线圈
			spells = {
				{1218706, "12,1"},
			},
			options = {
				{ -- 文字 原型能源线圈 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {.24, .89, .87},
					preview = T.GetIconLink(1218704)..L["倒计时"],
					data = {
						spellID = 1218704,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 237945 then -- 原型能源线圈
								if GetTime() - self.last_update > 5 then
									self.last_update = GetTime()
									T.Start_Text_DelayTimer(self, 52, L["强力DOT"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then       
							self.last_update = 0
							T.Start_Text_DelayTimer(self, 33, L["强力DOT"], true)
						end
					end,
				},
				{ -- 文字提示 超能过载 层数
					category = "TextAlert", 
					type = "spell",
					ficon = "12",
					color = {.11, .26, .95},
					preview = T.GetIconLink(1218708),
					data = {
						spellID = 1218708,
						events = {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
						},
						sound = "[defense]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1218708 and destGUID == G.PlayerGUID then
								self.text:SetText(L["强力DOT"])
								self:Show()
							elseif sub_event == "SPELL_AURA_APPLIED_DOSE" and spellID == 1218708 and destGUID == G.PlayerGUID then
								self.text:SetText(string.format("%s [%d]", L["强力DOT"], amount))
								self:Show()
								if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] and amount == 10 then
									T.PlaySound("defense")
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1218708 and destGUID == G.PlayerGUID then
								self:Hide()
							end
						end
					end,
				},
				{ -- 图标 原型能源线圈
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218704,
					tip = L["DOT"],
					ficon = "12",
					hl = "org",
				},				
				{ -- 图标 超能过载
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218708,
					tip = L["易伤"].."%s30%",
					ficon = "12",
					msg = {str_applied = "%name %spell", str_stack = "%stack"},
					hl = "",
				},
				{ -- 首领模块 原型能源线圈 点名统计 整体排序
					category = "BossMod",
					spellID = 1218704,
					enable_tag = "spell",
					ficon = "12",
					name = string.format(L["NAME点名排序"], T.GetIconLink(1218704)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 65},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1218704
						frame.element_type = "bar"
						frame.color = {.24, .89, .87}
						frame.raid_glow = "pixel"
						frame.raid_index = true
						frame.disable_copy_mrt = true
						frame.support_spells = 10
						frame.bar_num = 3
						
						function frame:custom_sort(cache)
							T.SortTable(cache)
						end		
						
						frame.info = {
							{text = "1"},
							{text = "2"},
							{text = "3"},
						}
						
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
		{ -- 废铁大师
			npcs = {
				{31645},
			},
			options = {
				{ -- 首领模块 小怪血量 废铁大师（✓）
					category = "BossMod",
					spellID = 1220648,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("231839")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -400},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["231839"] = {color = {.92, .88, .33}}, -- 废铁大师
						}
						
						frame.auras = {
							[1217685] = { -- 惨痛经历
								aura_type = "HELPFUL",
								color = {0, 1, 0},
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
				{ -- 首领模块 标记 废铁大师（待测试）
					category = "BossMod",
					spellID = 1219384,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("231839"), T.FormatRaidMark("5,6,7,8")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.start_mark = 5
						frame.end_mark = 8
						frame.mob_npcID = "231839"
						
						function frame:trigger(unit, GUID)
							if AuraUtil.FindAuraBySpellID(1217685, unit, "HELPFUL") then
								return true
							end
						end
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateRaidTarget(frame, event, ...)
						
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1217685 then -- 惨痛经历
								local unit = UnitTokenFromGUID(destGUID)
								if unit and not frame.marked[destGUID] then
									frame:Mark(unit, destGUID)
								end
							end
						end
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				{ -- 姓名板打断图标 废铁火箭（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 1219384,
					mobID = "231839",
					interrupt = 2,
					ficon = "6",
					mrt_info = {"5,6,7,8", true},
				},
				{ -- 图标 废铁火箭（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1219384,
					tip = L["锁定"],
					hl = "",
					ficon = "12",
				},
				{ -- 图标 你已被标记为“回收”的对象。（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1220648,
					tip = L["锁定"],
					hl = "",
					ficon = "12",
				},
			},
		},
		{ -- 垃圾场土狼
			npcs = {
				{30553},
			},
			options = {
				{ -- 图标 感染撕咬（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466748,
					tip = L["DOT"].."+"..L["致死"].."25%",
					hl = "",
					ficon = "10",
				},
				{ -- 首领模块 感染撕咬 多人光环（✓）
					category = "BossMod",
					spellID = 466748,
					enable_tag = "rl",
					ficon = "10",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(466748)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = -10},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 3
						
						frame.spellIDs = {
							[466748] = { -- 感染撕咬
								color = {.02, .8, .2},
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
			},
		},
		{ -- 焚烧
			spells = {
				{464149},
			},
			options = {
				{ -- 文字 焚烧 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.94, .76, .13},
					preview = L["分散躲垃圾"]..L["倒计时"],
					data = {
						spellID = 464149,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 464149 then -- 焚烧
								T.Start_Text_DelayTimer(self, 26, L["分散躲垃圾"], true)
							end
						elseif event == "ENCOUNTER_START" then       
							T.Start_Text_DelayTimer(self, 11, L["分散躲垃圾"], true)
						end
					end,
				},
				{ -- 计时条 焚烧（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464149,
					color = {.94, .76, .13},
					sound = "[spread]channel",
				},
				{ -- 图标 焚化（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472893,
					tip = L["DOT"],
					hl = "org_flash",
				},
				{ -- 首领模块 焚化 计时圆圈（✓）
					category = "BossMod",
					spellID = 472893,
					enable_tag = "none",
					name = T.GetIconLink(472893)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[472893] = { -- 焚化
								unit = "player",
								aura_type = "HARMFUL",
								color = {.94, .76, .13},
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
				{ -- 图标 滚烫垃圾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464248,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 剧毒烟雾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218343,
					tip = L["DOT"],
				},			
			},
		},
		{ -- 崩摧
			spells = {
				{464112, "0"},
			},
			options = {
				{ -- 计时条 崩摧[音效:崩摧]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464112,
					color = {.43, .65, 1},
					ficon = "0",
					show_tar = true,
					sound = soundfile("464112cast", "cast"),
				},
				{ -- 图标 崩摧（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464112,
					tip = L["易伤"].."100%",
					hl = "",
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 464112,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(464112)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[464112] = { -- 崩摧
								color = {.43, .65, 1},
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
		{ -- 熔毁
			spells = {
				{1217954, "0"},
			},
			options = {
				{ -- 计时条 熔毁[音效:熔毁]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1217954,
					color = {.67, 1, .88},
					ficon = "0",
					show_tar = true,
					sound = soundfile("1217954cast", "cast"),
				},
				{ -- 图标 熔毁（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217954,
					tip = L["强力DOT"],
					hl = "red_flash",
					ficon = "0",
				},
			},
		},
		{ -- 过载
			spells = {
				{467117},
			},
			options = {
				{ -- 文字 过载 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.16, .56, .91},
					preview = L["BOSS强化"]..L["倒计时"],
					data = {
						spellID = 467117,
						events =  {},					
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then       
							T.Start_Text_DelayTimer(self, 67, L["BOSS强化"], true)
						end
					end,
				},
				{ -- 计时条 过载（待测试）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 467117,
					dur = 10,
					color = {.16, .56, .91},
					text = L["BOSS免疫"],
				},
				{ -- 计时条 压缩垃圾（待测试）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 467109,
					color = {.16, .56, .91},
					text = L["击退"],
				},
				{ -- 图标 极限出力（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 473227,
					tip = L["BOSS强化"],
				},
			},
		},
	},
}