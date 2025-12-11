local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["即将出球"] = "即将出球"
	L["保持连线"] = "保持连线"
	L["拉断连线"] = "拉断连线"
	L["数量显示"] = "数量显示"
	L["小怪护甲"] = "小怪护甲 %d/7"
	L["吃球层数"] = "吃球层数 %d/5"
	L["蛛网"] = "蛛网"
	L["连线对象"] = "连线对象：%s"
	L["连线左右"] = "%s左右提示"
else
	L["即将出球"] = "Orb inc"
	L["保持连线"] = "Stay connected"
	L["拉断连线"] = "Break the connection"
	L["数量显示"] = "Quantity display"
	L["小怪护甲"] = "ADD Armor %d/7"
	L["吃球层数"] = "Orb %d/5"
	L["蛛网"] = "Web"
	L["连线对象"] = "Connected to:%s"
	L["连线左右"] = "%s Left/Right"
end

---------------------------------Notes--------------------------------

---------------------------------Notes--------------------------------
-- TO DO:小怪血量 光环

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2608] = {
	engage_id = 2921,
	npc_id = {"217489", "217491"}, -- 阿努巴拉什, 纺束者塔卡兹基
	alerts = {
		{ -- 流丝之庭的低语
			spells = {
				{455796, "12"},
			},
			options = {
				{ -- 图标 妄念印记（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 455849,
				},
				{ -- 图标 愠怒印记（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 455850,
				},
				{ -- 图标 虚空溃变（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 460359,
					hl = "red_flash",
					sound = "[sound_dong]stacksfx",
				},
				{ -- 图标 燃烧之怒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 460281,
					hl = "red_flash",
					sound = "[sound_dong]stacksfx",
				},		
				{ -- 全团虚空溃变/燃烧之怒层数监视（✓）
					category = "BossMod",
					spellID = 460281,
					enable_tag = "rl",
					ficon = "12",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(460359)..T.GetIconLink(460281)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -500},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.team_auras = {
							[455849] = { -- 妄念印记/燃烧之怒
								aura = 460281,
								icon = 136088,
								color = {1, 1, 1},
							},
							[455850] = { -- 愠怒印记/虚空溃变
								aura = 460359,
								icon = 4914670,
								color = {1, 1, 1},
							},
						},
						
						T.GetScaleCustomData(frame)
						
						frame.height, frame.width = 15, 100
						frame:SetSize(frame.width, (frame.height+2)*20-2)
						
						frame.unitframes = {}
						frame.lineup_cache = {}
						
						function frame:line_up()
							frame.lineup_cache = table.wipe(frame.lineup_cache)
							
							for _, bar in pairs(frame.unitframes) do
								table.insert(frame.lineup_cache, bar)
							end
							
							table.sort(frame.lineup_cache, function(a, b)
								if a.soak_spellID > b.soak_spellID then
									return true
								elseif a.soak_spellID == b.soak_spellID and a.count < b.count then
									return true
								elseif a.soak_spellID == b.soak_spellID and a.count == b.count and a.index < b.index then
									return true
								end
							end)
							
							local lastbar
							for i, bar in pairs(frame.lineup_cache) do
								bar:ClearAllPoints()
								if not lastbar then
									bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
								else
									bar:SetPoint("TOPLEFT", lastbar, "BOTTOMLEFT", 0, -2)	
								end
								lastbar = bar
							end
						end
						
						function frame:create_uf(GUID, unit, i)
							local format_name = T.GetGroupInfobyGUID(GUID)["format_name"]
							
							local bar = T.CreateTimerBar(self, 5383206, false, true, false, self.width, self.height)
							
							bar:SetMinMaxValues(0, 5)
							bar.left:SetText(format_name)
							bar.unit = unit
							bar.index = i
							
							self:cancel_team(bar)
							self:canel_soak(bar)
							
							self.unitframes[unit] = bar
						end
						
						function frame:cancel_team(bar)
							bar.icon:SetTexture(5383206)
							bar:SetStatusBarColor(.5, .5, .5)
							bar.sd:SetBackdropBorderColor(0, 0, 0)
							
							bar.team_auraID = nil							
							bar.soak_spellID = 0
						end
						
						function frame:update_team(bar, spellID, auraID)							
							bar.icon:SetTexture(self.team_auras[spellID].icon)
							bar:SetStatusBarColor(unpack(self.team_auras[spellID].color))
							bar.sd:SetBackdropBorderColor(unpack(self.team_auras[spellID].color))
							
							bar.team_auraID = auraID
							bar.soak_spellID = self.team_auras[spellID].aura
						end
						
						function frame:canel_soak(bar)
							bar.stack_auraID = nil
							bar.count = 0
							bar.exp_time = 0
							
							bar:SetValue(0)
							bar.right:SetText("")
							
							bar:SetScript("OnUpdate", nil)
							
							frame:line_up()
						end

						function frame:update_soak(bar, auraID, count, exp_time)
							bar.stack_auraID = auraID
							bar.count = count
							bar.exp_time = exp_time
							
							bar:SetValue(count)	
							bar.right:SetText(count)
							
							frame:line_up()
						end
						
						function frame:PreviewShow()
							for i = 1, 20 do
								self:create_uf(G.PlayerGUID, "raid"..i, i)
								self.unitframes["raid"..i]:SetValue(ceil(i/5))
							end
							self:line_up()
						end
						
						function frame:PreviewHide()
							for _, uf in pairs(frame.unitframes) do
								uf:Hide()
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_AURA" then
							local unit, updateInfo = ...
							local bar = frame.unitframes[unit]
							if not bar then return end
							if updateInfo == nil or updateInfo.isFullUpdate then
								frame:cancel_team(bar)
								frame:canel_soak(bar)
								AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(AuraData)
									if frame.team_auras[AuraData.spellId] then
										frame:update_team(bar, AuraData.spellId, AuraData.auraInstanceID)
									elseif AuraData.spellId == bar.soak_spellID then
										--print("isFullUpdate", AuraData.auraInstanceID, unit)
										frame:update_soak(bar, AuraData.auraInstanceID, AuraData.applications, AuraData.expirationTime)
									end	
								end, true)
							else
								if updateInfo.addedAuras ~= nil then
									for _, AuraData in pairs(updateInfo.addedAuras) do
										if frame.team_auras[AuraData.spellId] then
											frame:update_team(bar, AuraData.spellId, AuraData.auraInstanceID)
										elseif AuraData.spellId == bar.soak_spellID then
											--print("addedAuras", AuraData.auraInstanceID, unit)
											frame:update_soak(bar, AuraData.auraInstanceID, AuraData.applications, AuraData.expirationTime)
										end
									end
								end
								if updateInfo.updatedAuraInstanceIDs ~= nil then
									for _, auraID in pairs(updateInfo.updatedAuraInstanceIDs) do		
										if bar.team_auraID == auraID then
											local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
											if AuraData then
												frame:update_team(bar, AuraData.spellId, AuraData.auraInstanceID)
											else
												frame:cancel_team(bar)
											end
										elseif bar.stack_auraID == auraID then
											local AuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraID)
											if AuraData then
												--print("updatedAuraInstanceIDs update_soak", AuraData.auraInstanceID, unit)
												frame:update_soak(bar, AuraData.auraInstanceID, AuraData.applications, AuraData.expirationTime)
											else
												--print("updatedAuraInstanceIDs canel_soak", AuraData.auraInstanceID, unit)
												frame:canel_soak(bar)
											end
										end
									end
								end
								if updateInfo.removedAuraInstanceIDs ~= nil then
									for _, auraID in pairs(updateInfo.removedAuraInstanceIDs) do
										if bar.team_auraID == auraID then
											frame:cancel_team(bar)
										elseif bar.stack_auraID == auraID then
											--print("removedAuraInstanceIDs", auraID, unit)
											frame:canel_soak(bar)
										end
									end
								end
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if (unit == "boss1" and spellID == 455796) then
								C_Timer.After(1, function()
									frame:line_up()
								end)
							end						
						elseif event == "ENCOUNTER_START" then
							frame.unitframes = table.wipe(frame.unitframes)
							for i = 1, 20 do
								local unit = "raid"..i
								local GUID = UnitGUID(unit)
								if GUID then
									frame:create_uf(GUID, unit, i)
								end
							end
							frame:line_up()
						end
					end,
					reset = function(frame)
						for _, uf in pairs(frame.unitframes) do
							uf:Hide()
						end
						frame:Hide()
					end,
				},
				{ -- 首领模块 繁絮妄念微粒/无情愠怒微粒 计数（✓）
					category = "BossMod",
					spellID = 460357,
					enable_tag = "rl",
					ficon = "12",
					name = T.GetIconLink(460357)..T.GetIconLink(460263)..L["数量显示"],			
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 180, width = 200, height = 93},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.text = T.createtext(frame, "OVERLAY", 25, "OUTLINE", "LEFT")
						frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

						frame.bar1 = T.CreateTimerBar(frame, 4914670, false, false, true, 200, 30, {0, 0, 1})
						frame.bar1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -30)
						frame.bar1:SetMinMaxValues(0, 20)
						
						frame.bar2 = T.CreateTimerBar(frame, 136088, false, false, true, 200, 30, {1, 0, 0})
						frame.bar2:SetPoint("TOPLEFT", frame.bar1, "BOTTOMLEFT", 0, -2)
						frame.bar2:SetMinMaxValues(0, 20)
						
						frame.players_blue = {}
						frame.players_red = {}
						
						frame.num_blue = 0
						frame.num_red = 0
						
						frame.dmg_spells = {
							--[439992] = true, -- 缠网炸弹
							[438656] = true, -- 剧毒之雨
							[460600] = true, -- 熵能弹幕
							[450129] = true, -- 熵能废灭
							[441626] = true, -- 蛛网漩涡
							[441782] = true, -- 现实之束
							[460364] = true, -- 地震岩层
						}
						
						function frame:reset_num(tag)
							self[tag] = 0
							
							local bar = (tag == "num_blue" and self.bar1) or self.bar2
							
							bar.left:SetText(self[tag])
							bar:Hide()
							bar:SetScript("OnUpdate", nil)
							
							self.text:SetText(string.format("|cff0000FF%d|r / |cffFF0000%d|r", self.num_blue, self.num_red))
						end
						
						function frame:update_num(tag, change)
							self[tag] = self[tag] + change
							self[tag] = max(self[tag], 0) -- 修正负数
							
							local bar = (tag == "num_blue" and self.bar1) or self.bar2
							
							bar.left:SetText(self[tag])
							
							if self[tag] == 1 then
								bar:Show()
								bar.exp_time = GetTime() + 20
								bar:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > .05 then
										s.remain = s.exp_time - GetTime()
										if s.remain > 0 then
											s:SetValue(s.remain)
											s.right:SetText(string.format("%ds", s.remain))
										else
											self:reset_num(tag)
										end
									end
								end)
							elseif self[tag] == 0 then
								self:reset_num(tag)
							end
							
							self.text:SetText(string.format("|cff0000FF%d|r / |cffFF0000%d|r", self.num_blue, self.num_red))
						end
						
						function frame:PreviewShow()
							self:reset_num("num_blue")
							self:reset_num("num_red")
							
							self:update_num("num_blue", 1)
							self:update_num("num_red", 1)
						end
						
						function frame:PreviewHide()
							self:reset_num("num_blue")
							self:reset_num("num_red")
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, miss = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 455849 then -- 蓝印记
								frame.players_blue[destGUID] = true
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 455850 then -- 红印记
								frame.players_red[destGUID] = true
							elseif (sub_event == "SPELL_DAMAGE" or (subEvent == "SPELL_MISSED" and miss == "ABSORB")) and frame.dmg_spells[spellID] then -- 伤害出球
								if frame.players_blue[destGUID] then
									frame:update_num("num_blue", 1)
									
								elseif frame.players_red[destGUID] then
									frame:update_num("num_red", 1)
								end
							elseif sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_AURA_REFRESH" then -- 吃球
								if spellID == 460359 then -- 虚空溃变
									frame:update_num("num_blue", -1)
								elseif spellID == 460281 then -- 燃烧之怒
									frame:update_num("num_red", -1)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.num_blue = 0
							frame.num_red = 0
						end
					end,
					reset = function(frame, event)
						frame:Hide()
					end,
				},
				{ -- 文字 即将出球 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {1, .8, 0},
					preview = L["即将出球"]..L["倒计时"],
					data = {
						spellID = 460281, 
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if self.cast and unit == "boss1" and spellID == 450483 then-- 第一次虚空步伐
								T.Start_Text_DelayTimer(self, 4, L["即将出球"], true)
								self.cast = false
							elseif unit == "boss1" and spellID == 456174 then-- 钻地
								T.Start_Text_Timer(self, 3.5, L["即将出球"], true)
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" then 
								if spellID == 450980 then -- 存在瓦解
									T.Start_Text_RowTimer(self, {13, 13, 13, 13}, L["即将出球"], true)
								elseif spellID == 451277 then -- 尖刺风暴
									T.Start_Text_RowTimer(self, {20, 20}, L["即将出球"], true)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_REMOVED" and (spellID == 450980 or spellID == 451277) then
								T.Stop_Text_Timer(self)
							end
						elseif event == "ENCOUNTER_START" then
							self.cast = true						
						end
					end,
				},
				{ -- 首领模块 虚空溃变/燃烧之怒 计时圆圈（✓）
					category = "BossMod",
					spellID = 460359,
					enable_tag = "none",
					name = T.GetIconLink(460359)..T.GetIconLink(460281)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[460359] = { -- 虚空溃变
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
							},
							[460281] = { -- 燃烧之怒
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
							},
						}
						T.InitUnitAuraCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraCircleTimers(frame, event, ...)
						if event == "UNIT_AURA" then
							local unit = ...
							if unit == "player" then
								local stack
								if AuraUtil.FindAuraBySpellID(460359, "player", "HARMFUL") then
									stack = select(3, AuraUtil.FindAuraBySpellID(460359, "player", "HARMFUL"))
								elseif AuraUtil.FindAuraBySpellID(460281, "player", "HARMFUL") then
									stack = select(3, AuraUtil.FindAuraBySpellID(460281, "player", "HARMFUL"))
								end
								if stack then
									if stack <= 2 then
										for _, figure in pairs(frame.figures) do
											figure:SetColor(0, 1, 0)
										end
									elseif stack <= 3 then
										for _, figure in pairs(frame.figures) do
											figure:SetColor(1, 1, 0)
										end
									else
										for _, figure in pairs(frame.figures) do
											figure:SetColor(1, 0, 0)
										end
									end
								end
							end
						end
					end,
					reset = function(frame, event)
						T.ResetUnitAuraCircleTimers(frame)			
					end,				
				},
				{ -- 文字提示 虚空溃变/燃烧之怒层数（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 1},
					preview = string.format(L["吃球层数"], 1),
					data = {
						spellID = 460359,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						sound = "[1273\\no_orb]"
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and (spellID == 460359 or spellID == 460281) and destGUID == G.PlayerGUID then
								local text_frame = T.CreateAlertTextShared("text_"..spellID.."_1", 1)
								T.Start_Text_Timer(text_frame, 3, string.format(L["吃球层数"], 1))
								T.PlaySound("sound_water")
							elseif sub_event == "SPELL_AURA_APPLIED_DOSE" and (spellID == 460359 or spellID == 460281) and destGUID == G.PlayerGUID then
								local text_frame = T.CreateAlertTextShared("text_"..spellID.."_"..amount, 1)
								T.Start_Text_Timer(text_frame, 3, string.format(L["吃球层数"], amount))
								if amount == 4 then
									T.PlaySound("1273\\no_orb")
								else
									T.PlaySound("sound_water")
								end
							end
						end
					end,
				},		
			},
		},
		{ -- 存在瓦解 熵能弹幕
			spells = {
				{450980},
			},
			options = {
				{ -- 吸收盾 存在瓦解（✓）
					category = "BossMod",
					spellID = 450980,
					enable_tag = "none",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(450980)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 450980 -- 存在瓦解
						frame.aura_type = "HELPFUL"
						frame.effect = 2
						frame.time_limit = 52
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
				{ -- 分段计时条 存在瓦解（✓）
					category = "BossMod",
					spellID = 451016,
					enable_tag = "none",
					name = string.format(L["计时条%s"], T.GetIconLink(450980)),
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 360},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.default_bar_width = frame.default_bar_width or 260
						T.GetSingleBarCustomData(frame)
						
						local icon = C_Spell.GetSpellTexture(frame.config_id)
						
						frame.info = {
							["default"] = {
								dur = 16,
								div = {6, 9, 12, 15},
							},
							[14] = {
								dur = 14,
								div = {7, 9, 11, 13},
							},
							[15] = {
								dur = 13,
								div = {6.7, 8.5, 10.3, 12.1},
							},
							[16] = {
								dur = 13,
								div = {6.7, 8.5, 10.3, 12.1},
							},
						}
						
						frame.div = {}
						
						frame.updater = CreateFrame("Frame", nil, frame)
						frame.updater.t = 0
						
						frame.bar = T.CreateTimerBar(frame, icon, false, false, true)
						frame.bar:SetAllPoints(frame)
						
						T.CreateTagsforBar(frame.bar, 4)
						
						for i = 1, 4 do
							frame.bar.tag_indcators[i]:SetVertexColor(0, 0, 0)
							frame.bar["timer"..i] = T.createtext(frame.bar, "OVERLAY", 12, "OUTLINE", "LEFT")
							frame.bar["timer"..i]:SetPoint("BOTTOM", frame.bar.tag_indcators[i], "TOP", 0, 2)							
						end
						
						function frame:InitByDifficulty()
							if self.difficultyID ~= self.last_difficultyID then
								local info = self.info[self.difficultyID] or self.info["default"]
								self.dur = info.dur
								self.bar:SetMinMaxValues(0, self.dur)
								for i, v in pairs(info.div) do
									self.div[i] = v
									self.bar:pointtag(i, v/self.dur)
								end
								self.last_difficultyID = self.difficultyID
							end						
						end
						
						function frame:loop_init()
							self.bar:SetStatusBarColor(1, 1, 0)
							
							for i = 1, 4 do
								self.bar["timer"..i]:SetShown(i == 1)
							end
							
							self.index = 1
							self.exp_time = GetTime() + frame.dur
						end
						
						function frame:start()
							self:loop_init()
							self:SetScript("OnUpdate", function(s, e) 
								s.t = s.t + e
								if s.t > 0.05 then		
									s.remain = s.exp_time - GetTime()
									s.passed = s.dur - s.remain
									
									if s.remain > 0 then
										s.bar:SetValue(s.passed)
										
										if s.div[s.index] and s.passed > s.div[s.index] then											
											s.bar["timer"..s.index]:Hide()
											if s.bar["timer"..s.index+1] then
												s.bar["timer"..s.index+1]:Show()
											end
											if s.index == 1 then
												s.bar:SetStatusBarColor(1, 0, 0)
											elseif s.index == 4 then
												s.bar:SetStatusBarColor(1, 1, 0)
											end
											s.index = s.index + 1
										end
										
										for i = 1, 4 do
											if s.bar["timer"..i]:IsShown() then
												s.bar["timer"..i]:SetText(T.FormatTime(s.remain - (s.dur - s.div[i]), true))
											end
										end										
									else
										s:loop_init()
									end
									s.t = 0
								end
							end)
							self.bar:Show()
						end
						
						function frame:stop()						
							self:SetScript("OnUpdate", nil)
							self.bar:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 450980 then
								frame.updater.exp_time = GetTime() + .5
								frame.updater:SetScript("OnUpdate", function(self, e)
									self.t = self.t + e
									if self.t > .05 then
										if self.exp_time - GetTime() < 0 then
											self:SetScript("OnUpdate", nil)
											frame:start()
										end
									end
								end)
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 450980 then
								frame:stop()
							end
						elseif event == "ENCOUNTER_START" then
							frame.difficultyID = select(3, ...)
							frame:InitByDifficulty()
						end
					end,
					reset = function(frame, event)
						frame.updater:SetScript("OnUpdate", nil)
						frame:stop()
					end,
				},
				{ -- 图标 熵能之网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 451086,
					hl = "red",
					tip = L["DOT"].."+"..L["减速"],
				},
				{ -- 图标 熵能弹幕（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441775,
					hl = "red",
					tip = L["DOT"],
				},
				{ -- 图标 熵能脆弱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 463461,
					tip = L["易伤"],
				},
			},
		},
		{ -- 尖刺风暴 地震岩层
			spells = {
				{451277},
			},
			options = {				
				{ -- 吸收盾 尖刺风暴（✓）
					category = "BossMod",
					spellID = 451277,
					enable_tag = "none",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(451277)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 451277 -- 尖刺风暴
						frame.aura_type = "HELPFUL"
						frame.effect = 2
						frame.time_limit = 40
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
				{ -- 分段计时条 地震岩层（✓）
					category = "BossMod",
					spellID = 460364,
					enable_tag = "none",
					name = string.format(L["计时条%s"], T.GetIconLink(460364)),
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 360},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.default_bar_width = frame.default_bar_width or 260
						T.GetSingleBarCustomData(frame)
						
						local icon = C_Spell.GetSpellTexture(frame.config_id)
						
						frame.info = {
							["default"] = {
								dur = 27,
							},
							[14] = {
								dur = 24,
							},
							[15] = {
								dur = 20,
							},
							[16] = {
								dur = 20,
							},
						}
						
						frame.bar = T.CreateTimerBar(frame, icon, false, false, true)
						frame.bar:SetAllPoints(frame)
						
						function frame:InitByDifficulty()
							if self.difficultyID ~= self.last_difficultyID then
								local info = self.info[self.difficultyID] or self.info["default"]
								self.dur = info.dur
								self.bar:SetMinMaxValues(0, self.dur)
								self.last_difficultyID = self.difficultyID
							end						
						end
						
						function frame:start()
							self.exp_time = GetTime() + frame.dur
							self:SetScript("OnUpdate", function(s, e) 
								s.t = s.t + e
								if s.t > 0.05 then		
									s.remain = s.exp_time - GetTime()
									s.passed = s.dur - s.remain
									
									if s.remain > 0 then
										s.bar:SetValue(s.passed)
										s.bar.right:SetText(T.FormatTime(s.remain))
									else
										self.exp_time = GetTime() + self.dur
									end
									
									s.t = 0
								end
							end)
							self.bar:Show()
						end
						
						function frame:stop()						
							self:SetScript("OnUpdate", nil)
							self.bar:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 451277 then
								frame:start()
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 451277 then
								frame:stop()
							end
						elseif event == "ENCOUNTER_START" then
							frame.difficultyID = select(3, ...)
							frame:InitByDifficulty()
						end
					end,
					reset = function(frame, event)
						frame:stop()
					end,
				},
				{ -- 图标 地震岩层（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460364,
					hl = "",
					tip = L["DOT"],
				},
				{ -- 图标 地震脆弱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 463464,
					tip = L["易伤"],
				},
			},
		},

------------------------------阿努巴拉什-----------------------------
		{ -- 穿刺打击
			spells = {
				{438218, "0"},
			},
			options = {
				{ -- 计时条 穿刺打击[音效:穿刺打击]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438218,
					color = {.87, .85, .88},
					ficon = "0",
					show_tar = true,
				},
				{ -- 图标 穿刺打击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 438218,
					hl = "",
					tip = L["易伤"],
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 438218,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(438218)..T.GetIconLink(438200)..T.GetIconLink(441772)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[438218] = { -- 穿刺打击
								color = {.87, .85, .88},
							},							
							[438200] = { -- 毒液箭
								color = {.51, .92, .23},
							},
							[441772] = { -- 虚空箭
								color = {.13, .37, .81},
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
		{ -- 虫群的召唤
			spells = {
				{438801},
			},
			npcs = {
				{30198},
			},
			options = {
				{ -- 文字 虫群的召唤 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.79, .05, .57},
					preview = L["小怪"]..L["倒计时"],
					data = {
						spellID = 438801,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[1] = {12, 54},
								[2] = {20, 54},
							},
							[16] = {
								[1] = {23, 52},
								[2] = {28, 59},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438801, L["召唤小怪"], self, event, ...)
					end,
				},
				{ -- 计时条 虫群的召唤（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438801,
					color = {.79, .05, .57},
					sound = "[add]cast",
				},				
				{ -- 图标 甲虫锁定（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 438749,
					hl = "red",
				},
				{ -- 姓名板法术来源图标 甲虫锁定（✓）
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 438749,
					hl_np = true,
				},
				{ -- 图标 破碎护壳（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 438773,
					hl = "",
					tip = L["易伤"],
				},
				{ -- 首领模块 标记 碎壳甲虫（✓）
					category = "BossMod",
					spellID = 438749,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("218884"), T.FormatRaidMark("6,7,8")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.start_mark = 6
						frame.end_mark = 8
						frame.mob_npcID = "218884"
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateRaidTarget(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				{ -- 首领模块 小怪血量 碎壳甲虫（✓）
					category = "BossMod",
					spellID = 438801,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("218884")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -400},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["218884"] = {n = L["小怪"], color = {1, .74, 1}}, -- 碎壳甲虫
						}
						
						frame.auras = {
							[438706] = { -- 硬化甲壳
								aura_type = "HELPFUL",
							},							
							[455080] = { -- 甲虫领主的坚毅
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
				{ -- 文字提示 硬化甲壳层数（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "1",
					color = {1, .74, 1},
					preview = string.format(L["小怪护甲"], 3),
					data = {
						spellID = 438706,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_REMOVED" and spellID == 438706 then
								local text_frame = T.CreateAlertTextShared("text_"..spellID.."_0", 1)
								T.Start_Text_Timer(text_frame, 1, string.format(L["小怪护甲"], 0))
							elseif sub_event == "SPELL_AURA_REMOVED_DOSE" and spellID == 438706 and amount <= 2 then
								local text_frame = T.CreateAlertTextShared("text_"..spellID.."_"..amount, 1)
								T.Start_Text_Timer(text_frame, 1, string.format(L["小怪护甲"], amount))
							end
						end
					end,
				},
			},
		},		
		{ -- 鲁莽冲锋
			spells = {
				{440158, "4"},
			},
			options = {
				{ -- 文字提示 能量（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetFlagIconStr("4")..L["冲锋"]..string.format(L["能量"], 90, 100),				
					data = {
						spellID = 440246,
						events = {
							["UNIT_POWER_UPDATE"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, arg1)
						if event == "UNIT_POWER_UPDATE" and arg1 == "boss2" then
							if self.phase == 1 or self.phase == 3 then
								local cur = UnitPower("boss2")
								if cur >= 90 and cur < 100 then
									self.text:SetText(T.GetFlagIconStr("4")..L["冲锋"]..string.format(L["能量"], cur, 100))
									self:Show()
								else
									self:Hide()
								end
							else
								self:Hide()
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.phase = arg1
						elseif event == "ENCOUNTER_START" then
							self.phase = 1
						end
					end,
				},
				{ -- 计时条 鲁莽冲锋（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 440246,
					color = {1, 0, 0},
					ficon = "4",
					glow = true,
				},
			},
		},
		{ -- 穿刺喷发 尖刺爆发
			spells = {
				{440504},
				{443092},
			},
			options = {
				{ -- 计时条 穿刺喷发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 440504,
					color = {.9, .65, .36},
					sound = "[mindstep]cast",
				},
				{ -- 文字 尖刺爆发 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.91, .29, .01},
					preview = T.GetIconLink(443068)..L["倒计时"],
					data = {
						spellID = 443068,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[3] = {40, 31, 64},
							},
							[16] = {
								[3] = {40, 31, 64},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss2", 443068, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 尖刺爆发（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 443068,
					dur = 12,
					tags = {3, 6, 9 ,12},
					color = {.91, .29, .01},
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
				{ -- 首领模块 被刺穿 多人光环（✓）
					category = "BossMod",
					spellID = 449857,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(449857)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 210},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 2
						
						frame.spellIDs = {
							[449857] = { -- 被刺穿
								color = {1, .83, .58},
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
		{ -- 针刺虫群 钉刺爆裂
			spells = {
				{438677, "5,7"},
			},
			options = {
				{ -- 文字 针刺虫群 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, .3, .0},
					preview = L["驱散"]..L["倒计时"],
					data = {
						spellID = 438677,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[2] = {25, 58},
								[3] = {81, 57},
							},
							[16] = {
								[2] = {25, 58},
								[3] = {81, 57},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "prepare_dispel",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss2", 438677, L["驱散"], self, event, ...)						
					end,
				},
				{ -- 计时条 针刺虫群（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438677,
					color = {1, .3, .0},
					ficon = "5,7",					
					glow = true,
				},
				{ -- 图标 针刺虫群（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438708,
					hl = "yel",
					ficon = "7",
				},
				{ -- 首领模块 针刺虫群 点名统计 整体排序（✓）
					category = "BossMod",
					spellID = 438708,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(438708)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ADDON_MSG"] = true,
					},
					custom = {
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
					},
					init = function(frame)
						frame.aura_id = 438708
						frame.element_type = "bar"
						frame.color = {1, .3, 0}
						frame.raid_index = true
						frame.healers = {}
						frame.debuffed_list = {}
						frame.priority = {}
						frame.spell_count = 0
						
						frame.diffculty_num = {
							[14] = 3, -- PT
							[15] = 3, -- H
							[16] = 4, -- M
							[17] = 2, -- 随机
						}
						
						frame.jump_dur = {11.7, 11.6, 6.5, 8.7}
						
						frame.info = {
							{text = "1"..T.FormatRaidMark("1"), msg_applied = "{rt1}111 %name", msg = "{rt1}111", y_offset = -44},
							{text = "2"..T.FormatRaidMark("2"), msg_applied = "{rt2}222 %name", msg = "{rt2}222"},
							{text = "3"..T.FormatRaidMark("3"), msg_applied = "{rt3}333 %name", msg = "{rt3}333"},
							{text = "4"..T.FormatRaidMark("4"), msg_applied = "{rt4}444 %name", msg = "{rt4}444"},
						}
						
						T.InitAuraMods_ByMrt(frame)
						
						for i, element in pairs(frame.elements) do
							element.right:Hide()
							
							element.range_text = T.createtext(element, "OVERLAY", 16, "OUTLINE", "RIGHT")
							element.range_text:SetPoint("RIGHT", element, "RIGHT", -5, 0)
							
							element:HookScript("OnSizeChanged", function(s, w, h)
								s.range_text:SetFont(G.Font, h*.6, "OUTLINE")
							end)
						end
						
						-- 文字提示
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame_healer = T.CreateAlertTextShared("bossmod"..frame.config_id.."healer", 1)
						
						-- 计时圆圈
						T.CreateMovableFrame(frame, "circle_frame", 60, 60, {a1 = "CENTER", a2 = "CENTER", x = 0, y = 0}, "_Circle", L["计时圆圈"])
						
						frame.cd_tex = T.CreateRingCD(frame.circle_frame, frame.color, nil, true)
						frame.cd_tex.action_text = T.createtext(frame.cd_tex, "OVERLAY", 20, "OUTLINE", "CENTER")
						frame.cd_tex.action_text:SetPoint("TOP", frame.cd_tex, "CENTER", 0, 0)
						
						-- 计时条
						frame.bar = T.CreateTimerBar(frame.graph_bg, 538518, false, false, true, nil, nil, {.91, .82, .46})
						frame.bar:SetPoint("TOPLEFT", frame.graph_bg, "TOPLEFT")
						frame.bar:SetPoint("TOPRIGHT", frame.graph_bg, "TOPRIGHT")
						frame.bar:SetHeight(20)
						
						-- 施法计时条
						frame.bar2 = T.CreateTimerBar(frame.graph_bg, 4914671, false, false, true, nil, nil, {.55, .29, 1})
						frame.bar2:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 0, -2)
						frame.bar2:SetPoint("TOPRIGHT", frame.bar, "BOTTOMRIGHT", 0, -2)
						frame.bar2:SetHeight(20)
						
						-- 跳跃倒计时
						frame.bar3 = T.CreateTimerBar(frame.graph_bg, 1022950, false, false, true, nil, nil, {.41, .24, .78})
						frame.bar3:SetPoint("TOPLEFT", frame.bar, "BOTTOMLEFT", 0, -2)
						frame.bar3:SetPoint("TOPRIGHT", frame.bar, "BOTTOMRIGHT", 0, -2)
						frame.bar3:SetHeight(20)
						
						-- 距离刷新
						frame.range_updater = CreateFrame("Frame")
						frame.range_updater.t = 0
						
						function frame:UpdateRange_Start()
							self.range_updater:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.2 then
									local minRange, maxRange = T.GetRange("boss1")
									if maxRange then
										T.addon_msg("ShareMyRange,"..maxRange, "GROUP")
									end
									s.t = 0
								end
							end)
						end
						
						function frame:UpdateRange_Stop()
							self.range_updater:SetScript("OnUpdate", nil)
						end
						
						function frame:filter(GUID)
							local info = T.GetGroupInfobyGUID(GUID)
							if info and not self.display_finished then
								local color_pro = (AuraUtil.FindAuraBySpellID(455849, info.unit, "HARMFUL") and 2) or (AuraUtil.FindAuraBySpellID(455850, info.unit, "HARMFUL") and 1) or 0
								local index_pro = UnitInRaid(info.unit)
								
								table.insert(self.priority, {
									GUID = GUID,
									color_pro = color_pro,
									index_pro = index_pro,
								})
								
								return true
							end
						end
						
						function frame:Display()						
							table.sort(self.priority, function(a, b)
								if a.color_pro > b.color_pro then
									return true
								elseif a.color_pro == b.color_pro and a.index_pro < b.index_pro then
									return true
								end
							end)
							
							for index, info in pairs(self.priority) do
								if self.backups[info.GUID] then
									local element = self.elements[index]
									if element then
										element.color_pro = info.color_pro
										element:display(info.GUID)
										self:Update(info.GUID)
										self:RemoveBackup(info.GUID)
									end
								end
							end
						end
						
						function frame:SetAlert(str, dur, tex_value, color)
							local tag = string.format("%s [%d]", T.GetSpellIcon(438708), self.my_index)
							self.text_frame.text:SetText(tag..str.." "..dur)
							self.cd_tex.action_text:SetText(tag..str)
							self.cd_tex.dur_text:SetText(dur)
							if color == "gre" then
								self.cd_tex:SetColor(0, 1, 0)
							elseif color == "yel" then
								self.cd_tex:SetColor(1, 1, 0)
							elseif color == "red" then
								self.cd_tex:SetColor(1, 0, 0)
							end
							self.cd_tex:SetValueOnTexture(tex_value)
						end
						
						function frame:GetNumBeforeMe()
							local before_me = 0
							for i = 1, self.total do
								local GUID = self.debuffed_list[i]
								if GUID ~= "" then
									if GUID == G.PlayerGUID then
										break
									else
										before_me = before_me + 1
									end
								end
							end
							return before_me
						end
						
						function frame:UpdateDispelIndex()
							local index
							for i = 1, self.total do
								local GUID = self.debuffed_list[i]
								if GUID ~= "" then
									index = i
									break
								end
							end
							
							if index then
								for i = index, self.total do
									local GUID = self.debuffed_list[i]
									if GUID == G.PlayerGUID then -- 被点的人是我
										if i == index then
											if GUID ~= self.my_dispel_target then
												self:SetAlert(L["到位后点宏"], "", 0, "yel")
												T.PlaySound("macro_ready")
											else
												self:SetAlert(L["到位后驱自己"], "", 0, "gre")
												T.PlaySound("self_dispel_ready")
											end
										else
											local before_me = self:GetNumBeforeMe()
											self:SetAlert("", before_me, before_me/self.total, "red")
										end
									end
								end
							end
						end
						
						function frame:Dispel(GUID)
							local info = T.GetGroupInfobyGUID(GUID)
							T.msg(string.format("%s %s", L["收到驱散请求"], info.format_name))
							if GUID == G.PlayerGUID then -- 我是按宏的
								self:SetAlert(L["即将被驱散"], "", 0, "gre")
							end
							if GUID == self.my_dispel_target then -- 我是负责驱散的	
								T.GlowRaidFramebyUnit_Hide("pixel", "bossmod"..self.config_id, info.unit)
								T.GlowRaidFramebyUnit_Show("proc", "bossmod"..self.config_id, info.unit, {0, 1, 0})
								self.text_frame_healer.text:Show()
								self.text_frame_healer.text:SetText(L["快驱散"]..info.format_name)
								T.PlaySound("dispel_now")
							end
						end
						
						function frame:pre_update_auras()
							self.debuffed_list = table.wipe(self.debuffed_list)
							self.priority = table.wipe(self.priority)
							
							self.my_index = 0
							self.my_dispel_target = ""
						end
						
						function frame:post_display(element, index, unit, GUID)
							self.debuffed_list[index] = GUID
							
							-- 被点的人是我
							if GUID == G.PlayerGUID then
								self.my_index = index
								self.text_frame:Show()
								self.cd_tex:Show()
								self:UpdateRange_Start()
							end
							
							-- 这个人我驱散
							if self.healers[index] == G.PlayerGUID then
								self.my_dispel_target = GUID
								if GUID ~= G.PlayerGUID then
									T.GlowRaidFramebyUnit_Show("pixel", "bossmod"..self.config_id, unit, {1, 1, 0}) -- 黄色发光(预备)
								else
									T.GlowRaidFramebyUnit_Show("proc", "bossmod"..self.config_id, unit, {0, 1, 0}) -- 绿色发光
								end
							end
							
							element.range_text:SetText("-")
							element.right:Hide()
							
							if element.color_pro == 2 then
								element:SetStatusBarColor(0, 0, 1)
							elseif element.color_pro == 1 then
								element:SetStatusBarColor(1, 0, 0)
							else
								element:SetStatusBarColor(1, .3, 0)
							end
						end
						
						function frame:post_update_auras(total)
							self.total = total
							self:UpdateDispelIndex()
							self.display_finished = true
						end											
						
						function frame:post_remove(element, index, unit, GUID)
							self.debuffed_list[index] = ""
							
							-- 被点的人是我
							if GUID == G.PlayerGUID then
								self.text_frame:Hide()
								self.cd_tex:Hide()
								self:UpdateRange_Stop()
								T.PlaySound("sound_water")
							end
							
							-- 这个人我驱散
							if GUID == self.my_dispel_target then
								self.text_frame_healer:Hide()
								T.GlowRaidFramebyUnit_Hide("proc", "bossmod"..self.config_id, unit)
								T.GlowRaidFramebyUnit_Hide("pixel", "bossmod"..self.config_id, unit)
								self.my_dispel_target = nil
							end
							
							self.timer = C_Timer.NewTimer(.5, function()
								self:UpdateDispelIndex()
							end)
						end
						
						function frame:copy_mrt()
							return string.format("#%dhealers%s-%s", self.config_id, C_Spell.GetSpellName(self.config_id), T.ColorNameForMrt(G.PlayerName)).."\n"
						end
						
						function frame:PreviewShow()
							self.graph_bg:Show()
							self.bar:Show()
							self.bar2:Show()
							for i, element in pairs(self.elements) do
								element:display(G.PlayerGUID)
							end
							self:SetAlert("", 2, 2/5, "red")
							self.cd_tex:Show()
						end
						
						function frame:PreviewHide()
							self.graph_bg:Hide()
							self.bar:Hide()
							self.bar2:Hide()
							for i, element in pairs(self.elements) do
								element:remove()
							end
							self.cd_tex:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "ADDON_MSG" then
							local channel, sender, GUID, message, range = ...		
							if message == "DispelMe" then
								frame:Dispel(GUID)
							elseif message == "ShareMyRange" then
								local element = frame.actives[GUID]
								if element then
									element.range_text:SetText("R:"..range)
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local time_stamp, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_AURA_REFRESH") and spellID == 456252 then -- 针刺虫群
								local count = select(3, AuraUtil.FindAuraBySpellID(456252, "boss1", "HARMFUL"))
								frame.bar.left:SetText(string.format("[%d]", count))
								T.StartTimerBar(frame.bar, 10, true, true, true)
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 456252 then -- 针刺虫群 消失
								T.StopTimerBar(frame.bar, true, true, true)
							elseif sub_event == "SPELL_CAST_START" and spellID == 438355 then -- 灾变熵能
								T.StartTimerBar(frame.bar2, 10, true, true, true)
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 456245 then -- 刺痛谵妄
								T.StopTimerBar(frame.bar2, true, true, true)
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 438677 then -- 针刺虫群 施法计时条
								if frame.difficultyID == 16 then
									frame.spell_count = frame.spell_count + 1
									local dur = frame.jump_dur[frame.spell_count]
									if dur then
										T.StartTimerBar(frame.bar3, dur, true, true, true)
									end
								end
								
								frame.display_finished = false
								frame.extra_index = frame.diffculty_num[frame.difficultyID] or 4
								
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == frame.aura_id then -- 额外的针刺虫群 玩家
								if frame.display_finished then
									frame.extra_index = frame.extra_index + 1
									local unit_id = UnitTokenFromGUID(destGUID)
									if unit_id then			
										T.CreateRFIndex(destGUID, frame.extra_index)
										if UnitIsUnit(unit_id, "player") then
											frame.text_frame.text:SetText(string.format("%s [%d]", T.GetSpellIcon(438708), frame.extra_index))
											frame.text_frame:Show()
										end
									end
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.aura_id then -- 额外的针刺虫群 玩家
								local unit_id = UnitTokenFromGUID(destGUID)
								if unit_id then
									local unit_frame = T.GetUnitFrame(unit_id)
									if unit_frame then	
										T.HideRFIndexbyParent(unit_frame)
									end
									if UnitIsUnit(unit_id, "player") then
										frame.text_frame:Hide()
									end
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.spell_count = 0
							frame.healers = table.wipe(frame.healers)
							
							if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1 then
								local text = _G.VExRT.Note.Text1
								local healer_tag = string.format("#%dhealers", frame.config_id)
								for line in text:gmatch(healer_tag..'[^\r\n]+') do
									for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
										local info = T.GetGroupInfobyName(name)
										if info then
											table.insert(frame.healers, info.GUID)
										else
											T.msg(string.format(L["昵称错误"], name))
										end
									end
								end
							end
						end					
						
						T.UpdateAuraMods_ByMrt(frame, event, ...)												
					end,
					reset = function(frame, event)
						if frame.timer then
							frame.timer:Cancel()
						end
						frame.bar:Hide()
						frame.bar2:Hide()
						frame.text_frame:Hide()
						frame.text_frame_healer:Hide()
						frame.cd_tex:Hide()
						T.GlowRaidFrame_HideAll("proc", "bossmod"..frame.config_id)
						T.GlowRaidFrame_HideAll("pixel", "bossmod"..frame.config_id)
						T.ResetAuraMods_ByMrt(frame)
					end,
				},
				{ -- 计时条 刺痛谵妄（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 456245,
					dur = 12,
					color = {1, .7, 0},					
					text = L["易伤"].."+100%",
					glow = true,
				},
			},
		},
		{ -- 肆虐虫群
			spells = {
				{443063, "4"},
			},
			options = {
				{ -- 文字 肆虐虫群 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.79, .87, .47},
					preview = T.GetIconLink(442994)..L["倒计时"],
					data = {
						spellID = 442994,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[3] = {23, 75, 70},
							},
							[16] = {
								[3] = {23, 75, 71},
							},
						},
						cd_args = {
							round = true,							
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss2", 442994, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 肆虐虫群（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 442994,
					color = {.73, .96, .36},
					ficon = "4",
					sound = "[defense]cast",
				},
			},
		},
		{ -- 掘进喷发
			spells = {
				{441791},
			},
			options = {
				{ -- 计时条 掘进喷发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441791,
					color = {.58, .67, .43},
					text = L["钻地"].."+"..L["全团AE"],
				},
				{ -- 计时条 钻地（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451160,
					spellIDs = {456174},
					color = {.3, .49, .2},
					text = L["钻地"],
				},
				{ -- 图标 掘进喷发（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460360,
					hl = "",
					tip = L["DOT"],
				},
			},
		},
		
----------------------------纺束者塔卡兹基---------------------------
		{ -- 毒液箭
			spells = {
				{438200, "0"},
				{441772, "0"},
			},
			options = {
				{ -- 图标 毒液箭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438200,
					hl = "",
					tip = L["DOT"],
					ficon = "0",
				},
				{ -- 图标 虚空箭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441772,
					hl = "",
					tip = L["DOT"],
					ficon = "0",
				},
			},
		},		
		{ -- 剧毒之雨
			spells = {
				{438656},
			},
			options = {
				{ -- 文字 剧毒之雨 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.17, .8, .47},
					preview = L["分散"]..L["倒计时"],
					data = {
						spellID = 438343,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[1] = {6, 38, 37, 36},
							},
							[16] = {
								[1] = {18, 33, 27},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "spread",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438343, L["分散"], self, event, ...)
					end,
				},
				{ -- 计时条 剧毒之雨（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",	
					spellID = 438343,
					dur = 5,
					tags = {1.5},
					color = {.17, .8, .47},
				},
				{ -- 剧毒之雨 计时圆圈（✓）
					category = "BossMod",
					spellID = 438343,
					enable_tag = "none",
					name = T.GetIconLink(438343)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[438343] = { -- 剧毒之雨
								event = "SPELL_CAST_SUCCESS",					
								dur = 3.5,
								color = {.17, .8, .47},
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
				{ -- 图标 剧毒之雨（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 438656,
					hl = "",
					tip = L["DOT"],
				},
			},
		},		
		{ -- 缠网炸弹
			spells = {
				{439992, "5"},				
			},
			options = {
				{ -- 文字 缠网炸弹 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, .3, 0},
					preview = T.GetIconLink(439838)..L["倒计时"],
					data = {
						spellID = 439838,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[1] = {16, 56},
							},
							[16] = {
								[1] = {15, 70},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 442526, L["蛛网"], self, event, ...)
					end,
				},
				{ -- 计时条 缠网炸弹（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 439838,
					dur = 6,
					tags = {3},
					color = {.82, .82, .76},
					ficon = "5",
					text = L["蛛网"],
				},			
				{ -- 图标 倒钩之网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 454311,
					hl = "red",
					tip = L["DOT"].."+"..L["减速"],
				},
				{ -- 图标 束缚之网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440001,
					hl = "yel",
					tip = L["连线"],
				},				
				{ -- 首领模块 束缚之网 多人光环（✓）
					category = "BossMod",
					spellID = 439992,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(440001)),			
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["UNIT_AURA"] = true,
						["ENCOUNTER_PHASE"] = true
					},
					init = function(frame)
						frame.bar_num = 4
						
						frame.spellIDs = {
							[440001] = { -- 束缚之网
								aura_type = "HARMFUL",
								color = {.99, .4, 1},
							},
						}
						
						function frame:filter(auraID, spellID, GUID)
							local info = T.GetGroupInfobyGUID(GUID)
							if info then
								local unitCaster = select(7, AuraUtil.FindAuraBySpellID(spellID, info.unit, "HARMFUL"))
								if unitCaster then
									local found
									for _, bar in pairs(self.bars) do
										if bar.destGUID == GUID or bar.castGUID == GUID then
											found = true
											return false
										end
									end
									if not found then
										return true
									end
								end
							end
						end
						
						function frame:post_create_bar(bar, auraID, spellID, GUID)
							local info = T.GetGroupInfobyGUID(GUID)
							if info then
								local unitCaster = select(7, AuraUtil.FindAuraBySpellID(spellID, info.unit, "HARMFUL"))
								if unitCaster then
									local caster_GUID = UnitGUID(unitCaster)
									local caster_info = T.GetGroupInfobyGUID(caster_GUID)
									
									bar.right:Hide()
									
									bar.destGUID = GUID
									bar.castGUID = caster_GUID
									
									bar.caster_text = T.createtext(bar, "OVERLAY", C.DB["BossMod"][self.config_id]["height_sl"]*.6, "OUTLINE", "RIGHT")
									bar.caster_text:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
									bar.caster_text:SetText(caster_info.format_name)
									
									bar.left_tex = bar:CreateTexture(nil, "OVERLAY")
									bar.left_tex:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
									bar.left_tex:SetPoint("TOPRIGHT", bar, "TOP", 0, 0)
									bar.left_tex:SetTexture(G.media.blank)
									
									bar.right_tex = bar:CreateTexture(nil, "OVERLAY")
									bar.right_tex:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
									bar.right_tex:SetPoint("BOTTOMLEFT", bar, "BOTTOM", 0, 0)
									bar.right_tex:SetTexture(G.media.blank)
									
									bar.colorPro1 = (AuraUtil.FindAuraBySpellID(455849, info.unit, "HARMFUL") and 2) or (AuraUtil.FindAuraBySpellID(455850, info.unit, "HARMFUL") and 1) or 0 -- 妄念印记/愠怒印记
									bar.colorPro2 = (AuraUtil.FindAuraBySpellID(455849, caster_info.unit, "HARMFUL") and 2) or (AuraUtil.FindAuraBySpellID(455850, caster_info.unit, "HARMFUL") and 1) or 0 -- 妄念印记/愠怒印记
									bar.colorPro = bar.colorPro1 + bar.colorPro2
									
									if bar.colorPro1 == 2 then
										bar.left_tex:SetVertexColor(0,0,1,1)
									elseif bar.colorPro1 == 1 then
										bar.left_tex:SetVertexColor(1,0,0,1)
									else
										bar.left_tex:SetVertexColor(0,0,0,0)
									end
									
									if bar.colorPro2 == 2 then
										bar.right_tex:SetVertexColor(0,0,1,1)
									elseif bar.colorPro2 == 1 then
										bar.right_tex:SetVertexColor(1,0,0,1)
									else
										bar.right_tex:SetVertexColor(0,0,0,0)
									end
								end
							end
						end
						
						T.InitUnitAuraBars(frame)
						
						function frame:lineup()
							self.cache = table.wipe(self.cache)
							
							for auraID, bar in pairs(self.bars) do
								table.insert(self.cache, bar)					
							end
							
							if #self.cache > 1 and not T.IsInPreview() then
								table.sort(self.cache, function(a, b) 
									if a.colorPro > b.colorPro then
										return true
									elseif a.colorPro == b.colorPro and a.auraID < b.auraID then	
										return true
									end
								end)
							end
					
							local lastbar
							for i, bar in pairs(self.cache) do			
								bar:ClearAllPoints()
								if not lastbar then
									bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
								else
									bar:SetPoint("TOPLEFT", lastbar, "BOTTOMLEFT", 0, -2)	
								end
								lastbar = bar
							end
						end
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
				{ -- 计时条 缠绕（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 440179,
					dur = 12,
					color = {1, .7, 0},					
					text = L["易伤"].."+100%",
					glow = true,
				},
			},
		},
		{ -- 蛛网漩涡
			spells = {
				{441634},
			},
			options = {
				{ -- 文字 蛛网漩涡 1/2（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {.99, .4, 1},
					preview = L["拉人"].."1/2",
					data = {
						spellID = 441634,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						sound = "[1273\\pull1]",
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, castID, spellID = ...
							if unit == "boss1" and castID and spellID == 441626 then
								self.cast_count = self.cast_count + 1
								if mod(self.cast_count, 2) == 1 then
									T.Start_Text_Timer(self, 2, L["拉人"].."1")
									T.PlaySound("1273\\pull1")
								else
									T.Start_Text_Timer(self, 2, L["拉人"].."2")
									T.PlaySound("1273\\pull2")
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.cast_count = 0
						end
						
					end,
				},
				{ -- 文字 蛛网漩涡 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.99, .4, 1},
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 441626,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[2] = {20, 55},
								[3] = {33, 97, 82},
							},
							[16] = {
								[2] = {20, 56},
								[3] = {33, 34, 64},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "pull",
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, castID, spellID = ...
							if unit == "boss1" and castID and spellID == 441626 then
								self.cast_count = self.cast_count + 1
								if mod(self.cast_count, 2) == 1 then
									T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 441626, L["拉人"], self, event, ...)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.cast_count = 1
							T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 441626, L["拉人"], self, event, ...)
						end
						
					end,
				},
				{ -- 计时条 蛛网漩涡（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441626,
					color = {.99, .4, 1},
					text = L["拉人"],
				},
				{ -- 图标 蛛网漩涡（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441788,
					hl = "yel",
					tip = L["拉人"]..L["生效"],
				},
				{ -- 图标 蛛网漩涡（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441626,
					tip = L["DOT"],
				},
				{ -- 首领模块 束缚之网 连线左右（✓）
					category = "BossMod",
					spellID = 464748,
					enable_tag = "everyone",
					name = string.format(L["连线左右"], T.GetIconLink(440001)),			
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = 100, width = 300, height = 100},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spell_count = 0
						
						frame.keep_info = {
							[5] = true,
							[6] = true,
							[9] = true,
							[10] = true,
						}
						
						frame.arrow_left = CreateFrame("Frame", nil, frame)
						frame.arrow_left:SetPoint("RIGHT", frame, "CENTER", -100, 0)
						frame.arrow_left:Hide()
						T.CreateAnimArrow(frame.arrow_left)
						frame.arrow_left:SetArrowDirection("left", 0, 1, 0)
						
						frame.arrow_right = CreateFrame("Frame", nil, frame)
						frame.arrow_right:SetPoint("LEFT", frame, "CENTER", 100, 0)
						frame.arrow_right:Hide()
						T.CreateAnimArrow(frame.arrow_right)
						frame.arrow_right:SetArrowDirection("right", 0, 1, 0)
						
						frame.text = T.createtext(frame, "OVERLAY", 20, "OUTLINE", "CENTER")
						frame.text:SetPoint("BOTTOM", frame, "CENTER", 0, 2)
						
						frame.text2 = T.createtext(frame, "OVERLAY", 20, "OUTLINE", "CENTER")
						frame.text2:SetPoint("TOP", frame, "CENTER", 0, -2)
						
						function frame:PreviewShow()
							frame.arrow_left:Show()
							frame.arrow_right:Show()
							frame.text:SetText(string.format(L["连线对象"], T.ColorNameText(G.PlayerName, "player")))
							frame.text2:SetTextColor(0, 1, 0)
							frame.text2:SetText(L["拉断连线"])
							frame.text:Show()
							frame.text2:Show()
						end
						
						function frame:PreviewHide()
							frame.arrow_left:Hide()
							frame.arrow_right:Hide()
							frame.text:Hide()
							frame.text2:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 441626 then
								frame.spell_count = frame.spell_count + 1
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 440001 and destGUID == G.PlayerGUID then
								local unitCaster = select(7, AuraUtil.FindAuraBySpellID(440001, "player", "HARMFUL"))
								if frame.spell_count > 0 and unitCaster then
									local isRed = AuraUtil.FindAuraBySpellID(455850, "player", "HARMFUL")
									local caster_GUID = UnitGUID(unitCaster)
									local caster_info = T.GetGroupInfobyGUID(caster_GUID)

									local my_index = UnitInRaid("player")
									local other_index = UnitInRaid(caster_info.unit)
									
									if isRed and frame.keep_info[frame.spell_count] then
										frame.text2:SetTextColor(1, 1, 0)
										frame.text2:SetText(L["保持连线"])
										frame.text2:Show()
										T.PlaySound("1273\\wait")
									else
										frame.text2:SetTextColor(0, 1, 0)
										frame.text2:SetText(L["拉断连线"])
										frame.text2:Show()
										T.PlaySound("break")
										
										if my_index and other_index and mod(frame.spell_count, 2) == 1 then
											if my_index < other_index then
												frame.arrow_left:Show()
											else
												frame.arrow_right:Show()
											end
										end
									end
									
									if caster_info.format_name then
										frame.text:SetText(string.format(L["连线对象"], caster_info.format_name))
										frame.text:Show()
									end
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 440001 and destGUID == G.PlayerGUID then
								frame.arrow_left:Hide()
								frame.arrow_right:Hide()
								frame.text:Hide()
								frame.text2:Hide()
							end
						elseif event == "ENCOUNTER_START" then
							frame.spell_count = 0
						end
					end,
					reset = function(frame, event)
						frame:Hide()
						frame.arrow_left:Hide()
						frame.arrow_right:Hide()
						frame.text:Hide()
						frame.text2:Hide()
					end,
				},
			},
		},
		{ -- 熵能废灭
			spells = {
				{450129},
			},
			options = {
				{ -- 计时条 熵能废灭（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450129,
					color = {.1, .93, 1},
					text = L["远离"],
					sound = "[away]cast",
					glow = true,
				},
				{ -- 图标 熵能废灭
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 450129,
					hl = "org",
					tip = L["强力DOT"],					
				},
			},
		},
		{ -- 现实之束
			spells = {
				{441782},
			},
			options = {
				{ -- 计时条 现实之束（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 441782,
					color = {.74, .3, .82},
					text = L["冲击波"],
					sound = "[dodge]cast",
					glow = true,
				},
			},
		},
		{ -- 灾变熵能
			spells = {
				{438355, "4"},
			},
			options = {
				{ -- 文字提示 能量（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetFlagIconStr("4")..L["强力AE"]..string.format(L["能量"], 90, 100),				
					data = {
						spellID = 438355,
						events = {
							["UNIT_POWER_UPDATE"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, arg1)
						if event == "UNIT_POWER_UPDATE" and arg1 == "boss1" then
							if self.phase == 2 or self.phase == 3 then
								local cur = UnitPower("boss1")
								if cur >= 90 and cur < 100 then
									self.text:SetText(T.GetFlagIconStr("4")..L["强力AE"]..string.format(L["能量"], cur, 100))
									self:Show()
								else
									self:Hide()
								end
							else
								self:Hide()
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.phase = arg1	
						elseif event == "ENCOUNTER_START" then
							self.phase = 1
						end
					end,
				},
				{ -- 计时条 灾变熵能（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438355,
					color = {1, 0, 0},
					ficon = "4",
					glow = true,
				},
			},
		},	
		{ -- 掠行飞跃 虚空步伐
			spells = {
				{450045},
				{450483},
			},
			options = {
				{ -- 计时条 掠行飞跃（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450045,
					color = {.93, .74, .6},
					text = L["传送"],
				},
				{ -- 计时条 虚空步伐（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 450483,
					color = {.41, .24, .78},
					text = L["传送"],
				},
			},
		},	
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 450483, -- 虚空步伐
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 450980, -- 存在瓦解
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 451327, -- 狂热之怒
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU", -- 尖刺风暴
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 451277,
				},
			},
		},
	},
}

