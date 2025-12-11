local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["踩雷"] = "踩雷"
	L["火箭"] = "火箭"
	L["吸人"] = "吸人"
	L["极性切换"] = "变"
	L["极性不变"] = "不变"
	L["获得极性"] = "获得极性"
	L["钻头没点你"] = "没点你"
	L["快去放圈"] = "放圈"
	L["引钻头"] = "引钻头"
	L["挡火箭"] = "挡火箭"
	L["补位"] = "补位"
	L["入口"] = "入口"
elseif G.Client == "ruRU" then
	L["踩雷"] = "Наступить на мину"
	L["火箭"] = "Ракета"
	L["吸人"] = "Магнит"
	L["极性切换"] = "Смена"
	L["极性不变"] = "Без изменений"
	L["获得极性"] = "Получена полярность"
	L["钻头没点你"] = "Безопасно"
	L["快去放圈"] = "Бур на вас"
	L["引钻头"] = "Приманка"
	L["挡火箭"] = "Перехватить ракету"
	L["补位"] = "Перераспределение"
	L["入口"] = "Вход"
else
	L["踩雷"] = "Trigger"
	L["火箭"] = "Rocket"
	L["吸人"] = "Magnet"
	L["极性切换"] = "Changed"
	L["极性不变"] = "Same"
	L["获得极性"] = "Polarity"
	L["钻头没点你"] = "Safe"
	L["快去放圈"] = "Drill On You"
	L["引钻头"] = "Bait"
	L["挡火箭"] = "Hit Rocket"
	L["补位"] = "Reassign"
	L["入口"] = "Entrance"
end

---------------------------------Notes--------------------------------

-- 红蓝DEBUFF列表

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2653] = {
	engage_id = 3013,
	npc_id = {"230583"},
	alerts = {
		{ -- 激活发明！
			spells = {
				{473276},
			},
			options = {
				{ -- 首领模块 激活发明！ 倒计时（待测试）
					category = "BossMod",
					spellID = 473276,
					enable_tag = "none",
					name = T.GetIconLink(473276)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					init = function(frame)
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.bar = T.CreateAlertBarShared(2, "bm"..frame.config_id, 4548853, "", {.76, .98, .99})
						
						frame.spell_count = 0
						
						frame.spell_info_h = {
							{ text = T.GetSpellIcon(1216414)..L["射线"], sound = "ray"},
							{ text = T.GetSpellIcon(1216525)..L["火箭"]},
							{ text = T.GetSpellIcon(1215858)..L["吸人"]},
							
							{ text = T.GetSpellIcon(1216674)..L["射线"]},
							{ text = T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1216525)..L["火箭"], sound = "ray"},
							{ text = T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1215858)..L["吸人"], sound = "ray"},
							
							{ text = T.GetSpellIcon(1216674)..L["射线"], sound = "ray"},
							{ text = T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1217673)..L["火箭"], sound = "ray"},
							{ text = T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1217673)..L["火箭"].."+"..T.GetSpellIcon(1215858)..L["吸人"], sound = "ray"},
						}
						
						frame.spell_info_m = {
							{ text = T.GetSpellIcon(1216414)..L["射线"], sound = "ray"},
							{ text = T.GetSpellIcon(1216414)..L["射线"].."+"..T.GetSpellIcon(1216525)..L["火箭"], sound = "ray"},
							{ text = T.GetSpellIcon(1216414)..L["射线"].."+"..T.GetSpellIcon(1216525)..L["火箭"].."+"..T.GetSpellIcon(1215858)..L["吸人"], sound = "ray"},
							
							{ text = T.GetSpellIcon(1216674)..L["射线"], sound = "ray"},
							{ text = T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1216525)..L["火箭"], sound = "ray"},
							{ text = T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1216525)..L["火箭"].."+"..T.GetSpellIcon(1215858)..L["吸人"], sound = "ray"},
							
							{ text = T.GetSpellIcon(1216699)..L["躲球"], sound = "dodge_ball"},
							{ text = T.GetSpellIcon(1216699)..L["躲球"].."+"..T.GetSpellIcon(1215858)..L["吸人"], sound = "dodge_ball"},
							{ text = T.GetSpellIcon(1216699)..L["躲球"].."+"..T.GetSpellIcon(1216674)..L["射线"].."+"..T.GetSpellIcon(1215858)..L["吸人"], sound = "dodge_ball"},
						}
						
						function frame:GetText(count)
							local tag = "spell_info_"..(self.is_mythic and "m" or "h")
							if self[tag] and self[tag][count] then
								return self[tag][count]["text"]
							end
						end
						
						function frame:GetSound(count)
							local tag = "spell_info_"..(self.is_mythic and "m" or "h")
							if self[tag] and self[tag][count] then
								return self[tag][count]["sound"]
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, cast_spellID = ...
							if unit == "boss1" and cast_spellID == 473276 then -- 激活发明
								frame.spell_count = frame.spell_count + 1								

								frame.bar.left:SetText(frame:GetText(frame.spell_count))
								T.StartTimerBar(frame.bar, 3.5, true, true)
								
								local sound = frame:GetSound(frame.spell_count)
								if sound then
									T.PlaySound(sound)
								end
								
								C_Timer.After(3.5 ,function()
									local dur = frame.spell_count <= 3 and 5 or 6.5
									T.StartTimerBar(frame.bar, dur, true, true, true)
								end)
								
								if mod(frame.spell_count, 3) ~= 0 then
									local str = frame:GetText(frame.spell_count + 1)
									T.Start_Text_DelayTimer(frame.text_frame, 30, str, true)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							local str = frame:GetText(frame.spell_count + 1)
							T.Start_Text_DelayTimer(frame.text_frame, 55, str, true)
						elseif event == "ENCOUNTER_START" then
							local _, _, difficultyID = ...
							
							frame.spell_count = 0
							frame.is_mythic = (difficultyID == 16)
							
							local str = frame:GetText(frame.spell_count + 1)
							T.Start_Text_DelayTimer(frame.text_frame, 29, str, true)
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
						T.StopTimerBar(frame.bar, true, true, true)
					end,
				},
				{ -- 首领模块 挡火箭 分配（待测试）
					category = "BossMod",
					spellID = 1216525,
					enable_tag = "everyone",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1216525)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["ENCOUNTER_PHASE"] = true,
						["JST_CUSTOM"] = true,						
						["ADDON_MSG"] = true,						
					},
					custom = {
						{
							key = "rl_bool",
							text = L["RL加载"],
							default = false,
						},
						{
							key = "mrt_custom_btn",
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.spell_count = 0
						frame.assignment = {}
						frame.spell_ready = {}						
						
						frame.count = {
							[2] = true,
							[3] = true,
							[4] = true,
							[5] = true,
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.text_frame_rl = T.CreateAlertTextShared("bossmod"..frame.config_id.."rl", 1)
						
						function frame:CheckCooldown(GUID)
							for spellID, charge in pairs(self.spell_ready[GUID]) do
								if charge > 0 then
									return true
								end
							end
						end
						
						function frame:CheckColor(unit)
							if AuraUtil.FindAuraBySpellID(1217358, unit, "HARMFUL") or AuraUtil.FindAuraBySpellID(1216934, unit, "HARMFUL") then
								return true
							end
						end
						
						function frame:CheckPlayer(GUID, CD)
							local info = T.GetGroupInfobyGUID(GUID)
							local unit = info.unit
							local alive = not UnitIsDeadOrGhost(unit)
							local connected = UnitIsConnected(unit)
							local visible = UnitIsVisible(unit)
							local color_check = self:CheckColor(unit)
							local cd_check = not CD or self:CheckCooldown(GUID)
							if alive and connected and visible and color_check and cd_check then
								return true
							end
						end
						
						function frame:GetAliveTarget(sourceGUID)
							for i = 1, #self.assignment, 1 do
								local GUID = self.assignment[i]
								if GUID ~= sourceGUID and self:CheckPlayer(GUID) then
									return GUID
								end
							end
						end
						
						function frame:GetTarget()
							for i = 1, #self.assignment, 1 do
								local GUID = self.assignment[i]
								if self:CheckPlayer(GUID, true) then
									if self.spell_ready[GUID][204018] > 0 then -- 破咒祝福需要目标
										local destGUID = self:GetAliveTarget(GUID)
										if destGUID then
											return GUID, destGUID
										end
									else
										return GUID
									end
								end
							end
						end
						
						function frame:GetAssignment()
							local GUID, destGUID = self:GetTarget()	
							if GUID then
								if destGUID then
									if GUID == G.PlayerGUID then
										T.FormatAskedSpell(destGUID, 204018, 4)										
									end
									
									if destGUID == G.PlayerGUID then
										T.Start_Text_Timer(self.text_frame, 6, L["挡火箭"]..T.GetIconLink(204018))
										T.SendChatMsg(L["挡火箭"], 5, "SAY")
										T.PlaySound("1296\\rocket")
									end
			
									if C.DB["BossMod"][self.config_id]["rl_bool"] then
										local name = T.ColorNickNameByGUID(GUID)
										T.Start_Text_Timer(self.text_frame_rl, 6, L["挡火箭"]..":"..name..T.GetIconLink(204018))
									end
								else
									if GUID == G.PlayerGUID then
										T.Start_Text_Timer(self.text_frame, 6, L["挡火箭"])
										T.SendChatMsg(L["挡火箭"], 5, "SAY")
										T.PlaySound("1296\\rocket")
									end
		
									if C.DB["BossMod"][self.config_id]["rl_bool"] then
										local name = T.ColorNickNameByGUID(GUID)
										T.Start_Text_Timer(self.text_frame_rl, 6, L["挡火箭"]..":"..name)
									end
								end
							end
						end

						function frame:StartCount(dur)
							self.exp_time = GetTime() + dur
							self:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.5 then
									local remain = self.exp_time - GetTime()
									if remain <= 0 then
										T.FireEvent("JST_CUSTOM", s.config_id, "UPDATE")
										self:SetScript("OnUpdate", nil)
									end
									self.t = 0
								end
							end)
						end
						
						function frame:StopCount()
							self:SetScript("OnUpdate", nil)
						end
						
						function frame:copy_mrt()
							return T.Copy_Mrt_Raidlist(self, false, self.mrt_copy_custom)
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_GUID and cast_spellID == 473276 then -- 激活发明
								frame.spell_count = frame.spell_count + 1
								if mod(frame.spell_count, 3) ~= 0 then
									frame:StartCount(25)
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							frame:StartCount(50)
						elseif event == "JST_CUSTOM" then
							local id, key = ...
							if id == frame.config_id then
								local next_count = frame.spell_count + 1
								if frame.count[next_count] then
									frame:GetAssignment()
								end
							end
						elseif event == "ADDON_MSG" then
							local channel, sender, GUID, message = ...
							if message == "ShareSpellState" then
								local spellID, charge = select(5, ...)
								spellID = tonumber(spellID)
								charge = tonumber(charge)
								if frame.spell_ready[GUID] and frame.spell_ready[GUID][spellID] then
									frame.spell_ready[GUID][spellID] = charge
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.spell_count = 0						
							frame.assignment = table.wipe(frame.assignment)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							local tagmatched
							
							if text then
								local betweenLine
								local tag = string.format("#%dstart", frame.config_id)
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
											local info = T.GetGroupInfobyName(name)
											if info then
												if not frame.spell_ready[info.GUID] then
													table.insert(frame.assignment, info.GUID)
													frame.spell_ready[info.GUID] = {}
													local class = select(2, UnitClass(info.unit))
													
													for spellID, cd_type in pairs(G.ClassShareSpellData[class]) do
														if cd_type == "immunity" then
															if spellID == 642 then
																if info.role ~= "TANK" then -- 排除坦克的无敌
																	frame.spell_ready[info.GUID][spellID] = 1
																end
															elseif spellID == 204018 then
																if info.role == "TANK" then -- 排除惩戒和奶骑的破咒
																	frame.spell_ready[info.GUID][spellID] = 1
																end
															else
																frame.spell_ready[info.GUID][spellID] = 1
															end
														end
													end
												end
											else
												T.msg(string.format(L["昵称错误"], name))
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
										tagmatched = true
									end
								end
							end
						end
					end,
					reset = function(frame, event)
						frame:StopCount()
						frame.spell_ready = table.wipe(frame.spell_ready)
						T.Stop_Text_Timer(frame.text_frame)
						T.Stop_Text_Timer(frame.text_frame_rl)
					end,
				},
			},
		},
		{ -- 极性发生器
			spells = {
				{1216802, "12"},
			},
			options = {
				{ -- 文字 极性发生器 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {.47, .88, .97},
					preview = L["正负极"]..L["倒计时"],
					data = {
						spellID = 1217355,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[16] = {
								[1] = {4, 66, 46},
								[2] = {30, 66, 46},
								[3] = {30, 66, 46},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 5,
							prepare_sound = "1296\\new_color",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1217355, L["正负极"], self, event, ...)
					end,
				},
				{ -- 计时条 极性发生器（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 1217355,
					dur = 3,
					color = {.47, .88, .97},					
					text = L["极性切换"],
					glow = true,
					ficon = "12",
				},
				{ -- 图标 极性发生器（正极化）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217357,
					hl = "org_flash",
					ficon = "12",
				},
				{ -- 图标 正极化
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1216911,
					hl = "",
					ficon = "12",
				},				
				{ -- 图标 极性发生器（负极化）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217358,
					hl = "org_flash",
					ficon = "12",
				},		
				{ -- 图标 负极化
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1216934,
					hl = "",
					ficon = "12",
				},
				{ -- 文字 极性切换 文字提示（待测试）
					category = "TextAlert",
					ficon = "12",
					type = "spell",
					color = {1, 1, 1},
					group = 2,
					preview = T.GetIconLink(1217358)..T.GetIconLink(1217357)..L["文字提示"],
					data = {
						spellID = 1217357,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						sound = "[bluePolarity]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and destGUID == G.PlayerGUID then
								if spellID == 1217358 or spellID == 1217357 then -- Polarization Generator
									if self.previousPolarity then
										local newPolarity = spellID == 1217357 and "blue" or "red"
										local samePolarity = newPolarity == self.previousPolarity
										
										local textColor = spellID == 1217357 and "ff36a5f5" or "fff0264b"
										local text = samePolarity and L["极性不变"] or L["极性切换"]
										
										T.Start_Text_Timer(self, 4, string.format("|c%s%s|r", textColor, text), true)

										if samePolarity then
											T.PlaySound("samePolarity")
										else
											if spellID == 1217357 then
												T.PlaySound("bluePolarity")
											else
												T.PlaySound("redPolarity")
											end
										end
									else -- First polarity of the fight
										local textColor = spellID == 1217357 and "ff36a5f5" or "fff0264b"
										local text = L["获得极性"]
										
										T.Start_Text_Timer(self, 4, string.format("|c%s%s|r", textColor, text), true)
										
										if spellID == 1217357 then
											T.PlaySound("bluePolarity")
										else
											T.PlaySound("redPolarity")
										end
									end
								elseif spellID == 1216911 or spellID == 1216934 then
									self.previousPolarity = spellID == 1216911 and "blue" or "red"
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.previousPolarity = nil
						end
					end,
				},
				{ -- 首领模块 计时圆圈 极性发生器
					category = "BossMod",
					spellID = 1217357,
					ficon = "12",
					enable_tag = "none",
					name = T.GetIconLink(1217357)..T.GetIconLink(1217358)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1217357] = { -- 极性发生器（正极化）
								unit = "player",
								aura_type = "HARMFUL",
								color = {.1, .55, 1},
							},
							[1217358] = { -- 极性发生器（负极化）
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .12, .28},
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
		{ -- 炸脚地雷
			spells = {
				{1217083, "3,12"},
			},
			options = {
				{ -- 文字 炸脚地雷 倒计时
					category = "TextAlert",
					type = "spell",
					ficon = "3,12",
					color = {.85, .33, .09},
					preview = L["踩雷"]..L["倒计时"],
					data = {
						spellID = 1217231,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {12, 64},
								[1] = {38, 64},
								[1] = {38, 64},
							},
							[16] = {
								[1] = {12, 34, 30},
								[1] = {38, 34, 30},
								[1] = {38, 34, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1217231, L["踩雷"], self, event, ...)
					end,
				},
				{ -- 计时条 炸脚地雷（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1217231,
					color = {.85, .33, .09},
				},
				{ -- 图标 动荡爆炸（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1216406,
					hl = "red_flash",
					tip = L["易伤"].."200%",
				},				
				{ -- 图标 不稳定的碎片（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218342,
					tip = L["易伤"].."1000%",
					soudn = "[sound_dong]",
				},
				{ -- 首领模块 炸脚地雷 MRT轮次分配（待测试）
					category = "BossMod",
					ficon = "3,12",
					spellID = 1217231,
					enable_tag = "everyone",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1217231)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_CUSTOM"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					custom = {
						{
							key = "direction_dd",
							text = L["示意图方向"],
							default = "vertical",
							key_table = {
								{"horizontal", "水平"},
								{"vertical", "垂直"},
							},
							apply = function(value, frame)
								frame:UpdateDirection()
							end,
						},
						{
							key = "preview_diff_dd",
							text = L["预览难度"],
							default = 15,
							key_table = {
								{15, "H"},
								{16, "M"},
							},
							apply = function(value, frame)
								frame:UpdatePreviewInfo()
							end,
						},
						{
							key = "preview_phase_dd",
							text = L["预览阶段"],
							default = 1,
							key_table = {
								{1, "P1"},
								{2, "P2"},
								{3, "P3"},
							},
							apply = function(value, frame)
								frame:UpdatePreviewInfo()
							end,
						},
						{
							key = "preview_index_dd",
							text = L["预览轮次"],
							default = 1,
							key_table = {
								{1, "1"},
								{2, "2"},
								{3, "3"},
							},
							apply = function(value, frame)
								frame:UpdatePreviewInfo()
							end,
						},
						{
							key = "alert_type_dd",
							text = L["提示方式"],
							default = "both",
							key_table = {
								{"text_alert", L["文字提示"]},
								{"circle", L["计时圆圈"]},
								{"both", L["文字提示"].."+"..L["计时圆圈"]},
							},
							apply = function(value, frame)
								if value == "circle" then -- 圆圈
									frame.circle_frame.enable = true
									T.RestoreDragFrame(frame.circle_frame, frame)
									frame.text_frame:SetAlpha(0)
									frame.text_frame.collapse = true
								elseif value == "text_alert" then -- 文字
									frame.circle_frame.enable = false
									frame.circle_frame:Hide()
									T.ReleaseDragFrame(frame.circle_frame)
									frame.text_frame:SetAlpha(1)
									frame.text_frame.collapse = false
								else -- 全部显示
									frame.circle_frame.enable = true
									T.RestoreDragFrame(frame.circle_frame, frame)
									frame.text_frame:SetAlpha(1)
									frame.text_frame.collapse = false
								end
							end,
						},
						{
							key = "option_list_btn",
							text = L["支援技能设置"],
							default = {},
						}
					},
					init = function(frame)
						frame:SetSize(180, 350)
						frame.cast_id = 1217231 -- 炸脚地雷
						frame.debuff_id = 1218342 -- 不稳定的碎片					
						frame.copy_mrt = true
						frame.support_spells = 9
						frame.supprot_index = 4
						frame.spell_count = 0
						frame.last_trigger = 0
						
						frame.graphs = {}
						frame.elements = {}
						frame.assignment_general = {}
						frame.assignment_index = {}
						frame.assigned_cache = {}
						frame.assigned_players = {}
						frame.pos_order_cache = {}
						
						frame.graph_bg = CreateFrame("Frame", nil, frame)
						frame.graph_bg:SetAllPoints(frame)
						frame.graph_bg:Hide()
						
						-- 文字提示
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)

						-- 计时圆圈
						T.CreateMovableFrame(frame, "circle_frame", 60, 60, {a1 = "CENTER", a2 = "CENTER", x = 0, y = 0}, "_Circle", L["计时圆圈"])
						
						frame.cd_tex = T.CreateRingCD(frame.circle_frame, {1, 1, 1}, nil, .3)
						frame.cd_tex.mark_text = T.createtext(frame.cd_tex, "OVERLAY", 30, "OUTLINE", "CENTER")
						frame.cd_tex.mark_text:SetPoint("BOTTOM", frame.cd_tex, "TOP", 0, 5)				
						frame.cd_tex.action_text = T.createtext(frame.cd_tex, "OVERLAY", 20, "OUTLINE", "CENTER")
						frame.cd_tex.action_text:SetPoint("TOP", frame.cd_tex, "CENTER", 0, 0)
						
						frame.pos_local_tag = {
							[L["近战"]] = "M",
							[L["远程"]] = "R",
						}
						
						frame.time_data = {
							h = {
								{dur = 12, alert_advance = 6},
								{dur = 64, alert_advance = 5},
								
								{dur = 38, alert_advance = 6},
								{dur = 64, alert_advance = 5},
								
								{dur = 38, alert_advance = 6},
								{dur = 64, alert_advance = 5},
							},
							m = {
								{dur = 12, alert_advance = 6},
								{dur = 34, alert_advance = 7},
								{dur = 30, alert_advance = 4},
								
								{dur = 38, alert_advance = 6},
								{dur = 34, alert_advance = 7},
								{dur = 30, alert_advance = 4},
								
								{dur = 38, alert_advance = 6},
								{dur = 34, alert_advance = 7},
								{dur = 30, alert_advance = 4},
							}
						}

						frame.graph_tex_info = {
							str = {
								layer = "OVERLAY",
								text = L["入口"],
								fs = 12,
								w = 30,
								h = 30,
								color = {1, 1, 1},
								pos_v = {"BOTTOM", 0, 0},
								pos_h = {"RIGHT", 0, 0},
							},
							bg_v = {
								layer = "BACKGROUND",
								tex = G.media.blank,
								color = {.13, .13, .13},
								w = 180,
								h = 350,
								pos = {"TOPLEFT", 0, 0},
							},
							bg_left = {
								layer = "BACKGROUND",
								sub_layer = 1,
								tex = G.media.blank,
								color = {.53, .53, .53},
								w = 60,
								h = 350,
								pos_v = {"TOPLEFT", 20, 0},
								pos_h = {"BOTTOMLEFT", 0, 20},
							},
							bg_right = {
								layer = "BACKGROUND",
								sub_layer = 1,
								tex = G.media.blank,
								color = {.53, .53, .53},
								w = 60,
								h = 350,
								pos_v = {"TOPRIGHT", -20, 0},
								pos_h = {"TOPLEFT", 0, -20},
							},
							bg_mid_l = {
								layer = "BACKGROUND",
								sub_layer = 2,
								tex = G.media.blank,
								color = {.13, .13, .13},
								w = 40,
								h = 20,
								pos_v = {"RIGHT", frame, "CENTER", -20, 0},
								pos_h = {"TOP", frame, "CENTER", 0, -20},
							},
							bg_mid_r = {
								layer = "BACKGROUND",
								sub_layer = 2,
								tex = G.media.blank,
								color = {.13, .13, .13},
								w = 40,
								h = 20,
								pos_v = {"LEFT", frame, "CENTER", 20, 0},
								pos_h = {"BOTTOM", frame, "CENTER", 0, 20},
							},							
							floor_tl = {
								layer = "BORDER",
								tex = G.media.blank,
								color = {.58, .94, .94},
								w = 60,
								h = 165,
								pos_v = {"TOPLEFT", 20, 0},
								pos_h = {"BOTTOMLEFT", 0, 20},
							},
							floor_tr = {
								layer = "BORDER",
								tex = G.media.blank,
								color = {.58, .94, .94},
								w = 60,
								h = 165,
								pos_v = {"TOPRIGHT", -20, 0},
								pos_h = {"TOPLEFT", 0, -20},
							},
							floor_bl = {
								layer = "BORDER",
								tex = G.media.blank,
								color = {.58, .94, .94},
								w = 60,
								h = 165,
								pos_v = {"BOTTOMLEFT", 20, 0},
								pos_h = {"BOTTOMRIGHT", 0, 20},
							},
							floor_br = {
								layer = "BORDER",
								tex = G.media.blank,
								color = {.58, .94, .94},
								w = 60,
								h = 165,
								pos_v = {"BOTTOMRIGHT", -20, 0},
								pos_h = {"TOPRIGHT", 0, -20},
							},
							mark1 = {
								layer = "ARTWORK",
								rm = 1,
								pos_v = {"BOTTOMLEFT", 35, 70},
								pos_h = {"BOTTOMRIGHT", -70, 35},
							},
							mark2 = {
								layer = "ARTWORK",
								rm = 2,
								pos_v = {"BOTTOMRIGHT", -35, 70},
								pos_h = {"TOPRIGHT", -70, -35},
							},
							mark3 = {
								layer = "ARTWORK",
								rm = 3,
								pos_v = {"TOPRIGHT", -35, -60},
								pos_h = {"TOPLEFT", 60, -35},
							},
							mark4 = {
								layer = "ARTWORK",
								rm = 4,
								pos_v = {"TOPLEFT", 35, -60},
								pos_h = {"BOTTOMLEFT", 60, 35},
							},
						}
						
						T.UpdateGraphTextures(frame, frame.graph_bg)
						
						frame.map_info = {
							{
								color = "red", 
								mark = 1,
								pos_v = {"BOTTOM", frame.graphs.bg_left, "BOTTOM", 0, 25},
								pos_h = {"RIGHT", frame.graphs.bg_left, "RIGHT", -25, 0},
							},
							{
								color = "blue",
								mark = 1,
								pos_v = {"BOTTOM", frame.graphs.bg_left, "BOTTOM", 0, 105},
								pos_h = {"RIGHT", frame.graphs.bg_left, "RIGHT", -105, 0},
							},	
							{
								color = "blue",
								mark = 4,
								pos_v = {"TOP", frame.graphs.bg_left, "TOP", 0, -95},
								pos_h = {"LEFT", frame.graphs.bg_left, "LEFT", 95, 0},
							},							
							{
								color = "red",
								mark = 4,
								pos_v = {"TOP", frame.graphs.bg_left, "TOP", 0, -15},
								pos_h = {"LEFT", frame.graphs.bg_left, "LEFT", 15, 0},
							},
							{
								color = "red",
								mark = 2,
								pos_v = {"BOTTOM", frame.graphs.bg_right, "BOTTOM", 0, 25},
								pos_h = {"RIGHT", frame.graphs.bg_right, "RIGHT", -25, 0},
							},
							{
								color = "blue",
								mark = 2,
								pos_v = {"BOTTOM", frame.graphs.bg_right, "BOTTOM", 0, 105},
								pos_h = {"RIGHT", frame.graphs.bg_right, "RIGHT", -105, 0},
							},
							{
								color = "blue",
								mark = 3,
								pos_v = {"TOP", frame.graphs.bg_right, "TOP", 0, -95},
								pos_h = {"LEFT", frame.graphs.bg_right, "LEFT", 95, 0},
							},							
							{
								color = "red",
								mark = 3,
								pos_v = {"TOP", frame.graphs.bg_right, "TOP", 0, -15},
								pos_h = {"LEFT", frame.graphs.bg_right, "LEFT", 15, 0},
							},
						}
						
						frame.floor_info = {
							h = {
								{false, false, true, true}, -- 1
								{false, false, false, false}, -- 2
								
								{true, false, true, false}, -- 3
								{false, false, false, false}, -- 4
								
								{false, false, true, true}, -- 5
								{false, false, false, false}, -- 6
							},
							m = {
								{false, false, true, true}, -- 1
								{true, true, false, false}, -- 2
								{false, false, false, false}, -- 3
								
								{true, false, true, false}, -- 4
								{false, true, true, false}, -- 5
								{false, false, false, false}, -- 6
								
								{false, true, true, false}, -- 7
								{true, false, true, false}, -- 8
								{false, false, false, false}, -- 9
							},
						}
						
						frame.assign_info = {
							h = {
								{ -- 1-1
									{pos = "M", index = 3},
									{pos = "M", index = 4},
									{pos = "R", index = 7},
									{pos = "R", index = 8},
								},
								{ -- 1-2
									{pos = "M", index = 1},
									{pos = "M", index = 2},
									{pos = "R", index = 5},
									{pos = "R", index = 6},
								},
								
								{ -- 2-1
									{pos = "R", index = 5},
									{pos = "R", index = 6},
									{pos = "M", index = 7},
									{pos = "M", index = 8},
								},
								{ -- 2-2
									{pos = "R", index = 1},
									{pos = "R", index = 2},
									{pos = "M", index = 3},
									{pos = "M", index = 4},
								},
								
								{ -- 3-1
									{pos = "M", index = 3},
									{pos = "M", index = 4},
									{pos = "R", index = 7},
									{pos = "R", index = 8},
								},
								{ -- 3-2
									{pos = "R", index = 3},
									{pos = "R", index = 4},
									{pos = "M", index = 5},
									{pos = "M", index = 6},
								},
							},	
							m = {
								{ -- 1-1
									{pos = "M", index = 3},
									{pos = "M", index = 4},
									{pos = "R", index = 7},
									{pos = "R", index = 8},
								},
								{ -- 1-2
									{pos = "M", index = 2},
									{pos = "M", index = 1},
									{pos = "R", index = 6},
									{pos = "R", index = 5},
								},
								{ -- 1-3
									{pos = "R", index = 7},
									{pos = "R", index = 8},
									{pos = "M", index = 2},
									{pos = "M", index = 1},
								},
								
								{ -- 2-1
									{pos = "M", index = 7},
									{pos = "M", index = 8},
									{pos = "R", index = 6},
									{pos = "R", index = 5},
								},
								{ -- 2-2
									{pos = "R", index = 3},
									{pos = "R", index = 4},
									{pos = "M", index = 6},
									{pos = "M", index = 5},
								},
								{ -- 2-3
									{pos = "R", index = 6},
									{pos = "R", index = 5},
									{pos = "M", index = 2},
									{pos = "M", index = 1},
								},
								
								{ -- 3-1
									{pos = "M", index = 3},
									{pos = "M", index = 4},
									{pos = "R", index = 6},
									{pos = "R", index = 5},
								},
								{ -- 3-2
									{pos = "M", index = 8},
									{pos = "M", index = 7},
									{pos = "R", index = 6},
									{pos = "R", index = 5},
								},
								{ -- 3-3
									{pos = "R", index = 7},
									{pos = "R", index = 8},
									{pos = "M", index = 2},
									{pos = "M", index = 1},
								},
							},
						}
						
						function frame:CreateButton(i, info)
							local bu = CreateFrame("Frame", nil, self.graph_bg)
							bu:SetSize(40, 40)
							bu:SetFrameLevel(self.graph_bg:GetFrameLevel()+2)
							bu:Hide()
							
							bu.ring = bu:CreateTexture(nil, "OVERLAY")
							bu.ring:SetAllPoints(bu)
							bu.ring:SetTexture(G.media.ring)
							bu.ring:SetVertexColor(.45, 1, .67)
							
							bu.bg = bu:CreateTexture(nil, "ARTWORK")
							bu.bg:SetAllPoints(bu)
							bu.bg:SetTexture(G.media.circle)

							bu.top = T.createtext(bu, "OVERLAY", 20, "OUTLINE", "CENTER")
							bu.top:SetPoint("BOTTOM", bu, "CENTER", 0, 2)
							
							bu.bottom = T.createtext(bu, "OVERLAY", 16, "OUTLINE", "CENTER")
							bu.bottom:SetPoint("TOP", bu, "CENTER", 0, -2)
							
							function bu:remove()
								bu.index = nil
								bu.GUID = nil
								bu.top:SetText("")
								bu.bottom:SetText("")
								bu:Hide()
							end
							
							function bu:display(index, GUID, pos_tag)
								bu.index = index
								bu.GUID = GUID
								bu.top:SetText((bu.index or "?")..(pos_tag or ""))
								bu.bottom:SetText(bu.GUID and T.ColorNickNameByGUID(GUID) or "?")
								bu:Show()
							end
							
							bu.rt_index = i
							self.elements[i] = bu
						end
						
						for i, bomb_info in pairs(frame.map_info) do
							frame:CreateButton(i, bomb_info)
						end
						
						function frame:UpdateColor()
							for i, bu in pairs(self.elements) do
								if self.is_mythic then
									if frame.map_info[i].color == "red" then
										bu.bg:SetVertexColor(1, .28, .3)
									else
										bu.bg:SetVertexColor(.37, .71, 1)
									end
								else
									bu.bg:SetVertexColor(1, .8, 0)
								end
							end
						end
						
						function frame:SetFloor(arg1, arg2, arg3, arg4)
							self.graphs.floor_tl:SetShown(arg1)
							self.graphs.floor_tr:SetShown(arg2)
							self.graphs.floor_bl:SetShown(arg3)
							self.graphs.floor_br:SetShown(arg4)
						end
						
						function frame:SetSupportSpells(i, GUID, info)
							for _, v in pairs(C.DB["BossMod"][self.config_id]["option_list_btn"]) do
								if v.spell_count == self.assigned_index and v.spell_ind == i then
									local dif_tag = self.is_mythic and "m" or "h"
									local delay = self.time_data[dif_tag][self.assigned_index]["alert_advance"] - 1.5
									C_Timer.After(delay, function()
										if UnitExists("boss1") then
											if v.all_spec then
												T.FormatAskedSpell(GUID, v.support_spellID, 10)
												T.msg(string.format(L["需要给技能%s"], "", self.assigned_index, i, info.format_name, T.GetIconLink(v.support_spellID)))
											else
												if info.spec_id and v.spec_info[info.spec_id] then
													T.FormatAskedSpell(GUID, v.support_spellID, 10)
													T.msg(string.format(L["需要给技能%s"], "", self.assigned_index, i, info.format_name, T.GetIconLink(v.support_spellID)))
												end
											end
										end
									end)
								end
							end
						end
						
						function frame:SetOrder(assigned_cache, preview)
							for _, bu in pairs(self.elements) do
								bu:Hide()
							end
							for i, trigger_info in pairs(assigned_cache) do
								local GUID = trigger_info.GUID
								local bomb_index = trigger_info.index
								local pos_tag = trigger_info.pos_tag
								local bomb_rt = self.map_info[bomb_index].mark
								
								self.elements[bomb_index]:display(i, GUID, pos_tag)
								
								if not preview then
									local info = T.GetGroupInfobyGUID(GUID)
									
									if info then
										T.msg(string.format("%s %d%s %s", T.GetIconLink(self.config_id), i, T.FormatRaidMark(bomb_rt), info.format_name))
										
										self:SetSupportSpells(i, GUID, info)
										
										T.CreateRFIndex(GUID, i)
									end
									
									if GUID == G.PlayerGUID then
										self.my_rt = bomb_rt
										self.my_index = i
										self.before_me = self.my_index - 1
										self.my_turn = (i == 1)
										T.FireEvent("JST_CUSTOM", self.config_id, "ALERT")
									end
								end
							end
						end
						
						function frame:SetGlowIndex(index)
							for _, bu in pairs(self.elements) do
								if bu.rt_index == index then
									bu.ring:Show()
								else
									bu.ring:Hide()
								end
							end
						end
						
						function frame:copy_mrt()
							local players = {}
							local melee_players = {}
							local range_players = {}
							local raidlist = ""
							
							for unit in T.IterateGroupMembers() do
								local name = UnitName(unit)
								local GUID = UnitGUID(unit)
								
								table.insert(players, T.ColorNameForMrt(name))	
								local info = T.GetGroupInfobyGUID(GUID)
								if info.pos == "MELEE" then
									if #melee_players <= 4 then
										table.insert(melee_players, T.ColorNameForMrt(name))
									end
								else
									if #range_players <= 4 then
										table.insert(range_players, T.ColorNameForMrt(name))
									end
								end
							end
							
							raidlist = table.concat(players, " ").."\n"
							for i = 1, 9 do
								local melee_str = string.format("[%d:%s] %s", i, L["近战"], table.concat(melee_players, " "))
								local range_str = string.format("[%d:%s] %s", i, L["远程"], table.concat(range_players, " "))
								raidlist = raidlist.."\n"..melee_str.."\n"..range_str
							end
							
							local spellName = C_Spell.GetSpellName(self.config_id)
							raidlist = string.format("#%dstart%s\n%s\nend", self.config_id, spellName, raidlist).."\n"
							
							return raidlist
						end
						
						function frame:GetAssignmentByMrt()
							self.assignment_general = table.wipe(self.assignment_general)
							self.assignment_index = table.wipe(self.assignment_index)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							local tag = string.format("#%dstart", self.config_id)
							local tagmatched
							
							if text then
								local betweenLine
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										local index, pos = string.match(line, "%[(%d):(.+)%]")
										if index and pos and self.pos_local_tag[pos] then
											index = tonumber(index)
											if not self.assignment_index[index] then
												self.assignment_index[index] = {}
											end
											local pos_tag = self.pos_local_tag[pos]
											if not self.assignment_index[index][pos_tag] then
												self.assignment_index[index][pos_tag] = {}
											end
											for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
												local info = T.GetGroupInfobyName(name)
												if info then
													table.insert(self.assignment_index[index][pos_tag], info.GUID)
												else
													T.msg(string.format(L["昵称错误"], name))
												end
											end
										else
											for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
												local info = T.GetGroupInfobyName(name)
												if info then
													table.insert(self.assignment_general, info.GUID)
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
							end
							
							if not tagmatched then
								self.pos_order_cache = table.wipe(self.pos_order_cache)
								for unit in T.IterateGroupMembers() do
									local GUID = UnitGUID(unit)
									local info = T.GetGroupInfobyGUID(GUID)
									if info and info.role == "DAMAGER" then
										table.insert(self.pos_order_cache, info)
									end
								end
								table.sort(self.pos_order_cache, function(a, b)
									if a.pos and b.pos and a.pos ~= b.pos then
										return a.pos == "MELEE"
									elseif UnitInRaid(a.unit) and UnitInRaid(b.unit) then
										return UnitInRaid(a.unit) < UnitInRaid(b.unit)
									end
								end)
								for i, info in pairs(self.pos_order_cache) do
									table.insert(self.assignment_general, info.GUID)
								end
							end
						end
						
						function frame:CheckColor(unit, bomb_color)
							if self.is_mythic then
								local color = ""
								if AuraUtil.FindAuraBySpellID(1217358, unit, "HARMFUL") or AuraUtil.FindAuraBySpellID(1216934, unit, "HARMFUL") then
									color =  "red"
								elseif AuraUtil.FindAuraBySpellID(1217357, unit, "HARMFUL") or AuraUtil.FindAuraBySpellID(1216911, unit, "HARMFUL") then
									color = "blue"
								end
								return color == bomb_color
							else
								return true
							end
						end
						
						function frame:CheckPlayer(GUID, bomb_color)
							if not self.assigned_players[GUID] then
								local info = T.GetGroupInfobyGUID(GUID)
								local unit = info.unit
								local alive = not UnitIsDeadOrGhost(unit)
								local connected = UnitIsConnected(unit)
								local visible = UnitIsVisible(unit)
								local color_check = frame:CheckColor(unit, bomb_color)
								local debuffed = AuraUtil.FindAuraBySpellID(self.debuff_id, unit, "HARMFUL")
								--print(info.format_name, "存活", alive, "在线", connected, "可见", visible, "极性", color_check, "易伤", debuffed)
								if alive and connected and visible and color_check and not debuffed then
									return true
								end
							end
						end
						
						function frame:GetTarget(index, pos_tag, bomb_color)
							local order = self.assignment_index[index] and self.assignment_index[index][pos_tag]
							
							if order then
								--print("开始检查优先列表")
								for i, GUID in pairs(order) do -- 从优先列表中找
									if self:CheckPlayer(GUID, bomb_color) then
										return GUID
									end
								end
							end
							
							-- 从备用列表中找
							if pos_tag == "M" then
								--print("开始检查备用列表，从前往后")
								for i = 1, #self.assignment_general, 1 do -- 近战 从前往后
									local GUID = self.assignment_general[i]
									if self:CheckPlayer(GUID, bomb_color) then
										return GUID
									end
								end
							else
								--print("开始检查备用列表，从后往前")
								for i = #self.assignment_general, 1, -1 do -- 远程 从后往前
									local GUID = self.assignment_general[i]
									if self:CheckPlayer(GUID, bomb_color) then
										return GUID
									end
								end
							end
						end
						
						function frame:GetAssignment()
							self.assigned_index = self.spell_count + 1
							self.assigned_players = table.wipe(self.assigned_players)
							self.assigned_cache = table.wipe(self.assigned_cache)
							
							T.msg(string.format("%s [%d]", T.GetIconLink(self.config_id), self.assigned_index))

							local dif_tag = self.is_mythic and "m" or "h"
							local index = self.assigned_index
							
							for trigger_i, trigger_info in pairs(self.assign_info[dif_tag][index]) do
								local pos_tag = trigger_info.pos
								local bomb_index = trigger_info.index
								local bomb_color = self.map_info[bomb_index].color
								
								if not self.assigned_cache[trigger_i] then
									self.assigned_cache[trigger_i] = {}
									self.assigned_cache[trigger_i].index = bomb_index
								end
								
								local target = self:GetTarget(index, pos_tag, bomb_color)	
								if target then
									self.assigned_players[target] = trigger_i
									self.assigned_cache[trigger_i].GUID = target
								end
							end
						end
						
						function frame:Display()
							local index = self.assigned_index
							local dif_tag = self.is_mythic and "m" or "h"
							self:SetFloor(unpack(self.floor_info[dif_tag][index]))
							self:SetOrder(self.assigned_cache)							
							self.graph_bg:Show()
						end
						
						function frame:Reassign(trigger_i)
							--print("踩雷分配", "只分配 assigned_index", self.assigned_index, "的", trigger_i)
							
							local dif_tag = self.is_mythic and "m" or "h"
							local index = self.assigned_index
							
							local trigger_info = self.assign_info[dif_tag][index][trigger_i]
							local pos_tag = trigger_info.pos
							local bomb_index = trigger_info.index
							local bomb_color = self.map_info[bomb_index].color
							local bomb_rt = self.map_info[bomb_index].mark
							
							local GUID = self:GetTarget(index, pos_tag, bomb_color)	
							if GUID then
								self.assigned_players[GUID] = trigger_i
								self.elements[bomb_index]:display(trigger_i, GUID)
								
								local info = T.GetGroupInfobyGUID(GUID)
								if info then
									T.msg(string.format("%s %d%s %s%s", T.GetIconLink(self.config_id), trigger_i, T.FormatRaidMark(bomb_rt), info.format_name, L["补位"]))
									
									self:SetSupportSpells(trigger_i, GUID, info)
									
									T.CreateRFIndex(GUID, trigger_i)
								end
								
								if GUID == G.PlayerGUID then
									local cur_index
								
									for i, trigger_info in pairs(self.assign_info[dif_tag][index]) do
										local bomb_index = trigger_info.index
										local bu = self.elements[bomb_index]
										if bu:IsShown() then
											cur_index = i
											break
										end
									end
									
									self.my_rt = bomb_rt
									self.my_index = trigger_i
									self.before_me = self.my_index - cur_index
									self.my_turn = self.before_me == 0 and not AuraUtil.FindAuraBySpellID(1216406, "player", "HARMFUL")
									
									T.FireEvent("JST_CUSTOM", self.config_id, "ALERT", true)
								end
							end
						end
						
						function frame:UpdateGlowIndex()
							local dif_tag = self.is_mythic and "m" or "h"
							local index = self.assigned_index
							
							if self.assign_info[dif_tag][index] then
								for i, trigger_info in pairs(self.assign_info[dif_tag][index]) do
									local bomb_index = trigger_info.index
									local bu = self.elements[bomb_index]
									if bu:IsShown() then
										self:SetGlowIndex(bomb_index)
										break
									end
								end
							end
						end
						
						function frame:Remove()
							local dif_tag = self.is_mythic and "m" or "h"
							local index = self.assigned_index
							
							if self.assign_info[dif_tag][index] then
								local next_index
								
								for i, trigger_info in pairs(self.assign_info[dif_tag][index]) do
									local bomb_index = trigger_info.index
									local bu = self.elements[bomb_index]
									
									if bu:IsShown() then
										local GUID = bu.GUID
										
										if GUID == G.PlayerGUID then
											self:HideAlert()
											self.my_index = nil
										end
										
										local info = T.GetGroupInfobyGUID(GUID)
										if info then
											local unit_frame = T.GetUnitFrame(info.unit)
											if unit_frame then	
												T.HideRFIndexbyParent(unit_frame)
											end
										end
										
										bu:Hide()
										next_index = i + 1
										break
									end
								end
								
								if not next_index or next_index == 5 then
									self:RemoveAll()
									self.graph_bg:Hide()
									self:HideAlert()
									self.my_index = nil
								elseif self.my_index then
									self.before_me = self.my_index - next_index
									T.FireEvent("JST_CUSTOM", self.config_id, "ALERT")
								end
							end
						end
						
						function frame:RemoveAll()
							for i, bu in pairs(self.elements) do
								bu:Hide()
							end
							T.HideAllRFIndex()
						end
											
						function frame:StartCount()
							local dif_tag = self.is_mythic and "m" or "h"
							local next_count = self.spell_count + 1 
							local spell_dur = self.time_data[dif_tag][next_count]["dur"]
							local advance = self.time_data[dif_tag][next_count]["alert_advance"]
							local dur = spell_dur - advance

							self.exp_time = GetTime() + dur
							self:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.5 then
									local remain = self.exp_time - GetTime()
									if remain <= 0 then
										T.FireEvent("JST_CUSTOM", s.config_id, "UPDATE")
										self:SetScript("OnUpdate", nil)
									end
									self.t = 0
								end
							end)
						end
						
						function frame:StopCount()
							self:SetScript("OnUpdate", nil)
						end
						
						function frame:update_cd_tex(r, g, b)
							self.cd_tex:SetColor(r, g, b)
							self.cd_tex:SetValueOnTexture(1)
							self.cd_tex:Show()
						end
						
						function frame:ShowAlert()
							local rt = T.FormatRaidMark(self.my_rt)
							local wait_str
							
							if self.my_index == 1 then
								wait_str = L["第一个"]
								T.PlaySound("mark\\mark"..self.my_rt, "first")
								self:update_cd_tex(0, 1, 0)
							elseif self.my_turn then
								wait_str = L["上！"]
								T.PlaySound("go")
								self:update_cd_tex(0, 1, 0)							
							elseif self.before_me == 0 then
								wait_str = L["准备"]
								T.PlaySound("prepare")
								self:update_cd_tex(1, 1, .13)
								self.cd_tex:begin(GetTime() + 2, 2)
								C_Timer.After(2.2, function()
									self.my_turn = true
									T.FireEvent("JST_CUSTOM", self.config_id, "ALERT")
								end)
							elseif self.before_me == 1 then
								wait_str = L["下一个"]
								T.PlaySound("next")
								self:update_cd_tex(.41, .29, 1)
							else
								wait_str = string.format("%s %d", L["等待"], self.before_me)
								self:update_cd_tex(.41, .29, 1)
								T.PlaySound("mark\\mark"..self.my_rt)
							end						

							self.text_frame.text:SetText(self.my_index..rt.." "..wait_str)
							self.cd_tex.mark_text:SetText(rt)
							self.cd_tex.action_text:SetText(wait_str)
							
							self.cd_tex:Show()
							self.text_frame:Show()
						end
						
						function frame:HideAlert()
							self.cd_tex:Hide()
							self.text_frame:Hide()
						end
												
						T.GetScaleCustomData(frame)
											
						function frame:UpdateDirection()
							local dir = C.DB["BossMod"][self.config_id]["direction_dd"]
							
							if dir == "vertical" then
								self:SetSize(180, 350)
							else
								self:SetSize(350, 180)
							end
									
							for name, data in pairs(self.graph_tex_info) do
								local f = self.graphs[name]
								
								if data.w and data.h then
									if dir == "vertical" then
										f:SetSize(data.w, data.h)
									else
										f:SetSize(data.h, data.w)
									end
								end
								
								if not data.pos then
									f:ClearAllPoints()
									if dir == "vertical" then
										f:SetPoint(unpack(data.pos_v))
									else
										f:SetPoint(unpack(data.pos_h))
									end
								end
							end
							
							for i, bomb_info in pairs(self.map_info) do
								self.elements[i]:ClearAllPoints()
								if dir == "vertical" then
									self.elements[i]:SetPoint(unpack(bomb_info.pos_v))
								else
									self.elements[i]:SetPoint(unpack(bomb_info.pos_h))
								end
							end
						end
						
						function frame:UpdatePreviewInfo()
							self.is_mythic = C.DB["BossMod"][self.config_id]["preview_diff_dd"] == 16
							self:UpdateColor()
							
							local dif_tag = self.is_mythic and "m" or "h"
							local phase = C.DB["BossMod"][self.config_id]["preview_phase_dd"]
							local count = C.DB["BossMod"][self.config_id]["preview_index_dd"]
							local phase_count = self.is_mythic and 3 or 2
							
							if self.is_mythic or count < 3 then
								local index = phase_count*(phase-1) + count
								
								self:SetFloor(unpack(self.floor_info[dif_tag][index]))
								
								local assigned_cache = {}
								for i = 1, 4 do
									local trigger_info = self.assign_info[dif_tag][index][i]
									assigned_cache[i] = {}
									assigned_cache[i].index = trigger_info.index
									assigned_cache[i].GUID = G.PlayerGUID
									assigned_cache[i].pos_tag = trigger_info.pos == "M" and L["近"] or L["远"]
								end
								
								self:SetOrder(assigned_cache, true)
							else
								self:RemoveAll()
							end
						end
						
						function frame:PreviewShow()
							self:UpdatePreviewInfo()
							self.graph_bg:Show()
							self.cd_tex:Show()
							
							self:update_cd_tex(1, 1, .13)
							self.cd_tex.action_text:SetText(L["准备"])
							self.cd_tex:begin(GetTime() + 2, 2)
							
							C_Timer.After(2.2, function()
								self:update_cd_tex(0, 1, 0)
								self.cd_tex.action_text:SetText(L["上"])
							end)
						end
						
						function frame:PreviewHide()
							self:RemoveAll()
							self.graph_bg:Hide()
							self.cd_tex:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE") and spellID == 1216406 then -- 动荡爆炸
								if GetTime() - frame.last_trigger > .2 then
									frame.last_trigger = GetTime()
									frame:Remove()
									frame:UpdateGlowIndex()
								end
							elseif sub_event == "SPELL_CAST_START" and spellID == frame.cast_id then -- 炸脚地雷
								frame.spell_count = frame.spell_count + 1
								if mod(frame.spell_count, frame.is_mythic and 3 or 2) ~= 0 then
									frame:StartCount()
								end								
							elseif sub_event == "UNIT_DIED" and frame.assigned_players[destGUID] then
								local info = T.GetGroupInfobyGUID(destGUID)
								if info then
									local unit_frame = T.GetUnitFrame(info.unit)
									if unit_frame then	
										T.HideRFIndexbyParent(unit_frame)
									end
								end

								if destGUID == G.PlayerGUID then
									frame:HideAlert()
								end
								
								if frame.graph_bg:IsShown() then
									local dif_tag = frame.is_mythic and "m" or "h"
									local index = frame.assigned_index
									local trigger_i = frame.assigned_players[destGUID]
									local trigger_info = frame.assign_info[dif_tag][index][trigger_i]
									local bomb_index = trigger_info.index
									local bu = frame.elements[bomb_index]
									
									if bu:IsShown() then -- 需要重新分配
										frame.assigned_players[destGUID] = nil
										T.FireEvent("JST_CUSTOM", frame.config_id, "REASSIGN", trigger_i)
									end
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							frame:StopCount()
							frame:StartCount()
						elseif event == "JST_CUSTOM" then
							local id, key = ...
							if id == frame.config_id then
								if key == "UPDATE" then
									frame:GetAssignment()
									frame:Display()
									frame:UpdateGlowIndex()
								elseif key == "REASSIGN" then
									local trigger_i = select(3, ...)
									frame:Reassign(trigger_i)
								elseif key == "ALERT" then
									if frame.assigned_players[G.PlayerGUID] then
										frame:ShowAlert()
									end
								end
							end
						elseif event == "ENCOUNTER_START" then
							local _, _, difficultyID = ...
							
							frame.is_mythic = difficultyID == 16
							frame.assigned_index = 0
							frame.spell_count = 0
							
							frame:UpdateColor()
							frame:GetAssignmentByMrt()
							
							frame:StartCount()
						end
					end,
					reset = function(frame, event)
						frame:StopCount()
						frame:RemoveAll()
						frame.graph_bg:Hide()
						frame:HideAlert()
						
						frame:Hide()
					end,
				},
			},		
		},
		{ -- 缆线输电
			spells = {
				{466235},
			},
			options = {
				{ -- 计时条 缆线输电（待测试）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1218418,
					color = {.45, .72, .89},
				},
				{ -- 图标 缆线输电（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 466235,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 起钻
			spells = {
				{1216508},
			},
			options = {
				{ -- 文字 起钻 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.9, .53, .07},
					preview = L["引钻头"]..L["倒计时"],
					data = {
						spellID = 1216508,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},					
						info = {
							[15] = {
								[1] = {47, 33, 32},
								[2] = {72, 34, 42},
								[3] = {72, 34, 42},
							},
							[16] = {
								[1] = {18, 34, 33},
								[2] = {44, 34, 33},
								[3] = {44, 34, 33},
							},
						},
						cd_args = {
							show_time = 10,
							round = true,
							count_down_start = 5,
							prepare_sound = "1296\\baitdrill",
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1216508 then -- 起钻
								self.count = self.count + 1
								self.total_count = self.total_count + 1
								
								local next_count = self.total_count + 1
								self.spell_tag = (next_count <= self.safe_count) and string.format("|cff00ff00%s|r", L["不会点你"]) or ""
								self.cur_text = L["引钻头"]..self.spell_tag
								
								local cd = T.GetCooldownData(self)
								if cd and self.pos == "RANGED" then
									T.Start_Text_DelayTimer(self, cd, self.cur_text, true)
								end
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1216509 and destGUID == G.PlayerGUID then -- 起钻
								if mod(self.total_count, 3) == 1 then
									self.safe_count = self.total_count + 2
								else
									self.safe_count = self.total_count + 1
								end
								
								local next_count = self.total_count + 1
								self.spell_tag = (next_count <= self.safe_count) and string.format("|cff00ff00%s|r", L["不会点你"]) or ""
								self.cur_text = L["引钻头"]..self.spell_tag
							end
						elseif event == "ENCOUNTER_PHASE" then
							T.Stop_Text_Timer(self)
							
							self.phase = ...
							self.count = 1
							
							local next_count = self.total_count + 1
							self.spell_tag = (next_count <= self.safe_count) and string.format("|cff00ff00%s|r", L["不会点你"]) or ""
							self.cur_text = L["引钻头"]..self.spell_tag
								
							local cd = T.GetCooldownData(self)
							if cd and self.pos == "RANGED" then
								T.Start_Text_DelayTimer(self, cd, self.cur_text, true)
							end
						elseif event == "ENCOUNTER_START" then
							self.pos = T.GetMyPos()
							self.dif = select(3, ...)

							self.phase = 1
							self.count = 1
							self.total_count = 0
							self.safe_count = 0
							self.spell_tag = ""
							
							if self.data.cd_args then
								for k, v in pairs(self.data.cd_args) do
									self[k] = v
								end
							end
							
							local cd = T.GetCooldownData(self)
							
							if cd and self.pos == "RANGED" then
								T.Start_Text_DelayTimer(self, cd, L["引钻头"], true)
							end
						end
					end,
				},
				{ -- 计时条 起钻（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1216508,
					color = {.9, .53, .07},
				},
				{ -- 图标 起钻（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1216509,
					hl = "org_flash",
					tip = L["锁定"],
				},
				{ -- 图标 钻透！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217261,
					hl = "",
					tip = L["DOT"],
				},
				{ -- 文字 起钻 文字提示（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.9, .53, .07},
					group = 2,
					preview = T.GetIconLink(1216509)..L["文字提示"],
					data = {
						spellID = 1216509,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1216509 then
								if destGUID == G.PlayerGUID then
									T.PlaySound("dropnow")
									T.Start_Text_Timer(self, 3, L["快去放圈"])
								end
								C_Timer.After(.2, function()
									local info = T.GetGroupInfobyGUID(G.PlayerGUID)
									if info.pos == "RANGED" then
										if not AuraUtil.FindAuraBySpellID(1216509, "player", "HARMFUL") then
											T.PlaySound("safe")
											T.Start_Text_Timer(self, 3, L["钻头没点你"])
										end
									end
								end)
							end
						end
					end,
				},
				{ -- 首领模块 起钻 计时圆圈
					category = "BossMod",
					spellID = 1217261,
					enable_tag = "none",
					name = T.GetIconLink(1216509)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_spellID = 1216509
						frame.figure = T.CreateRingCD(frame, {.9, .53, .07})
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 4.5, 4.5, {
								{dur = 3, color = {0, 1, 1}},
								{dur = 1.5, color = {.9, .53, .07}},
							})
						end
						
						function frame:PreviewHide()
							self.figure:stop()
						end
						
						function frame:ToggleText(value)
							self.figure.dur_text:SetShown(value)
						end
						
						T.GetFigureCustomData(frame)
					end,	
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_spellID and destGUID == G.PlayerGUID then -- 起钻
								frame.figure:begin(GetTime() + 4.5, 4.5, {
									{dur = 3, color = {0, 1, 1}},
									{dur = 1.5, color = {.9, .53, .07}},
								})
								frame.count_down = 3
								frame.cacheTimer = C_Timer.NewTicker(1.5, function()
									T.PlaySound("count\\"..frame.count_down)
									frame.count_down = frame.count_down - 1
								end, 3)
							end
						end
					end,
					reset = function(frame, event)
						frame.figure:stop()
						if frame.cacheTimer and not frame.cacheTimer:IsCancelled() then
							frame.cacheTimer:Cancel()
						end
					end,
				},
				{ -- 首领模块 点名监控 起钻（待测试）
					category = "BossMod",
					spellID = 1216508,
					enable_tag = "rl",
					name = string.format(L["NAME点名监控"], T.GetIconLink(1216508)).." "..string.format(L["需要大于n人"], L["远程"], 9),
					points = {a1 = "LEFT", a2 = "CENTER", x = -700, y = 250},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.bar_num = 9
						T.GetBarsCustomData(frame)
						
						frame.aura_spellID = 1216509
						frame.spell = C_Spell.GetSpellName(frame.aura_spellID)
						frame.icon = C_Spell.GetSpellTexture(frame.aura_spellID)
						
						frame.spell_count = 0
						frame.bars = {}
						frame.barsbyGUID = {}
						frame.safe_count = {}
						
						function frame:line_up()
							table.sort(self.bars, function(a, b)
								if a.role and b.role and a.role ~= b.role then
									return a.role < b.role
								elseif a.GUID and b.GUID then
									return a.GUID < b.GUID
								end
							end)
							
							local count = 1
							for _, bar in pairs(self.bars) do
								if bar:IsShown() then
									bar:ClearAllPoints()
									bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(count-1)*(C.DB["BossMod"][self.config_id]["height_sl"]+2))
									count = count + 1
								end
							end
						end
						
						function frame:CreateNewBar(GUID)
							local bar = T.CreateTimerBar(self, self.icon, false, true, false, C.DB["BossMod"][self.config_id]["width_sl"], C.DB["BossMod"][self.config_id]["height_sl"], {.9, .53, .07})
							
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							
							bar:SetMinMaxValues(0, 4.5)
							bar:SetValue(4.5)
							bar.mid:ClearAllPoints()
							bar.mid:SetPoint("LEFT", bar, "RIGHT", 2, 0)
							bar.mid:SetText("")
							
							bar:SetScript("OnHide", function()
								self:line_up()
							end)
							
							function bar:start()
								bar:SetStatusBarColor(1, 1, 0)
								bar.exp_time = GetTime() + 4.5
								
								bar:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > .05 then
										s.remain = s.exp_time - GetTime()
										if s.remain > 0 then
											s:SetValue(s.remain)
											s.right:SetText(string.format("%.1fs", s.remain))
										else
											s:SetScript("OnUpdate", nil)
											S.right:SetText("")
										end
									end
								end)
							end
							
							function bar:update_status()
								if bar.unit and UnitIsDeadOrGhost(bar.unit) then
									bar:SetScript("OnUpdate", nil)
									bar.right:SetText("")
									bar:SetValue(4.5)
									bar:SetStatusBarColor(.5, .5, .5)
									
									bar.mid:SetText("|cffff0000Dead|r")
								elseif frame.safe_count[bar.GUID] and frame.spell_count + 1 <= frame.safe_count[bar.GUID] then
									bar:SetScript("OnUpdate", nil)
									bar.right:SetText("")
									bar:SetValue(4.5)
									bar:SetStatusBarColor(.5, .5, .5)
									
									bar.mid:SetText("")
								else
									bar:SetScript("OnUpdate", nil)
									bar.right:SetText("")
									bar:SetValue(4.5)
									bar:SetStatusBarColor(.9, .53, .07)
									
									bar.mid:SetText("")
								end
							end
							
							table.insert(self.bars, bar)
							
							if info then
								bar.unit = info.unit
								bar.role = info.role
								bar.GUID = GUID
								local role_tag = T.UpdateRoleTag(info.role, info.pos) or ""
								bar.left:SetText(role_tag..info.format_name)
								self.barsbyGUID[GUID] = bar
							else
								bar.left:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
							end
							
							self:line_up()
						end
						
						function frame:PreviewShow()
							for index = 1, 9 do
								self:CreateNewBar()
							end
						end
						
						function frame:PreviewHide()
							for _, bar in pairs(self.bars) do
								bar:Hide()
								bar:SetScript("OnUpdate", nil)
								bar.right:SetText("")
							end
							
							self.bars = table.wipe(self.bars)
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1216508 then -- 起钻 
								frame.spell_count = frame.spell_count + 1
								C_Timer.After(7, function()
									for _, bar in pairs(frame.bars) do
										bar:update_status()
									end
								end)
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1216509 then -- 起钻 
								if mod(frame.spell_count, 3) == 1 then
									frame.safe_count[destGUID] = frame.spell_count + 2
								else
									frame.safe_count[destGUID] = frame.spell_count + 1
								end
								
								local bar = frame.barsbyGUID[destGUID]
								if bar then
									bar:start()
								end
							elseif sub_event == "UNIT_DIED" then
								local bar = frame.barsbyGUID[destGUID]
								if bar then
									bar:update_status()
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.spell_count = 0							
							
							for unit in T.IterateGroupMembers() do
								local GUID = UnitGUID(unit)
								local info = T.GetGroupInfobyGUID(GUID)
								
								if info.pos == "RANGED" then
									frame:CreateNewBar(GUID)
									frame.safe_count[GUID] = 0
								end
							end
						end
					end,
					reset = function(frame, event)						
						for _, bar in pairs(frame.bars) do
							bar:Hide()
							bar:SetScript("OnUpdate", nil)
							bar.right:SetText("")
						end			
						
						frame.bars = table.wipe(frame.bars)
						frame.barsbyGUID = table.wipe(frame.barsbyGUID)
						frame.safe_count = table.wipe(frame.safe_count)
					end,
				},
			},
		},
		{ -- 声波爆轰
			spells = {
				{465232, "2"},
			},
			options = {
				{ -- 文字 声波爆轰 倒计时
					category = "TextAlert",
					type = "spell",
					color = {.62, .65, .9},
					ficon = "2",
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 465232,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[16] = {
								[1] = {18, 34, 33},
								[2] = {46, 34, 33},
								[3] = {46, 34, 33},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 465232, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 声波爆轰（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465232,
					color = {.62, .65, .9},
					sound = "[AOE]cast",
					text = L["全团AE"],
				},
				{ -- 图标 声波爆轰（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 465232,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		{ -- 爆竹陷阱
			spells = {
				{471308},
			},
			options = {
				{ -- 图标 爆竹陷阱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 471308,
					hl = "yel",
					tip = L["击飞"].."+"..L["DOT"],
				},
			},
		},
		{ -- 纵火派对包
			spells = {
				{1214872, "0"},
			},
			options = {
				{ -- 计时条 纵火派对包（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1214872,
					color = {.84, .27, .98},
					show_tar = true,
					sound = "[stay_away]cast",
					ficon = "0",
				},
				{ -- 计时条 纵火派对包 debuff（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 1214878,
					dur = 6,
					color = {.84, .27, .98},
					show_tar = true,
					text = L["全团AE"],
				},
				{ -- 图标 纵火派对包（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1214878,
					hl = "org_flash",
					tip = L["远离"],
				},
				{ -- 首领模块 计时圆圈 纵火派对包（✓）
					category = "BossMod",
					spellID = 1214878,
					enable_tag = "none",
					name = T.GetIconLink(1214878)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1214878] = { -- 纵火派对包
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .12, .93},
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
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 465917,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(1214878)..T.GetIconLink(465917)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[1214878] = { -- 纵火派对包
								color = {.84, .27, .98},
							},
							[465917] = { -- 重力停滞
								color = {.56, .69, 1},
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
		{ -- 重力停滞
			spells = {
				{465917, "0"},
			},
			options = {
				{ -- 图标 重力停滞（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 465917,
					tip = L["易伤"].."%s20%",
				},				
			},
		},
		{ -- 二次投放
			spells = {
				{466765},
			},
			options = {
				{ -- 计时条 二次投放（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 466765,
					color = {.97, .64, 1},
					text = L["击飞"],
					sound = "[knockoff]cast",
					glow = true,
				},
			},
		},
		{ -- 滴血锋刃
			spells = {
				{466860, "5"},
			},
			options = {
				{ -- 首领模块 分段计时条 滴血锋刃（待测试）
					category = "BossMod",
					spellID = 466860,
					name = string.format(L["计时条%s"], T.GetIconLink(466860)),
					enable_tag = "none",
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 250},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)					
						frame.spell_info = {
							["SPELL_CAST_SUCCESS"] = {
								[466860] = {
									dur = 20,
									color = {.97, .64, 1},
									sound = "aoe",
									divide_info = {
										dur = {5, 10, 15, 20},
										time = true, -- 分段时间
										sound = "count",
									},
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
				{ -- 图标 虚空爆炸（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218319,
					effect = 2,
					hl = "",
					tip = L["吸收治疗"],
				},
			},
		},
		{ -- 升级版驭血科技
			spells = {
				{1218344},
			},
			options = {
				{ -- 图标 升级版驭血科技（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 1218344,
					tip = L["BOSS强化"],
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
					spellID = 466765, -- 二次投放
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 466765, -- 二次投放
					count = 2,
				},
			},
		},
	},
}