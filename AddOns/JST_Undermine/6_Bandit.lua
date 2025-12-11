local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1296\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["线圈"] = "线圈"
	L["可选"] = "可选"
	L["新组合"] = "新组合"
	L["组合顺序"] = "组合顺序"
	L["丢硬币瞄准辅助线"] = "丢硬币瞄准辅助线"
	L["引硬币"] = "引硬币"
	L["准备交奖券"] = "准备交奖券"
	L["快交奖券"] = "快交奖券"
	L["技能组合排序和击杀提示"] = "技能组合排序和击杀提示"
elseif G.Client == "ruRU" then
	L["线圈"] = "Катушка"
	L["可选"] = "Доступно"
	L["新组合"] = "Новая комбинация"
	L["组合顺序"] = "Порядок комбинации"
	L["丢硬币瞄准辅助线"] = "Линии прицеливания"
	L["引硬币"] = "Приманка для монеты"
	L["准备交奖券"] = "Готовность к использованию жетона"
	L["快交奖券"] = "Используйте жетон сейчас!"
	L["技能组合排序和击杀提示"] = "Сортировка комбинаций и подсказки"
else
	L["线圈"] = "coil"
	L["可选"] = "available"
	L["新组合"] = "New Combination"
	L["组合顺序"] = "Combination Order"
	L["丢硬币瞄准辅助线"] = "aim lines"
	L["引硬币"] = "Bait Coin"
	L["准备交奖券"] = "use token"
	L["快交奖券"] = "use token now!"
	L["技能组合排序和击杀提示"] = "Spell combination sorting and target prompt"
end

---------------------------------Notes--------------------------------

-- 30%强制转阶段
-- 隐藏光环：热火朝天
---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2644] = {
	engage_id = 3014,
	npc_id = {"228458"},
	alerts = {
		{ -- 转向胜利
			spells = {
				{461060},
			},
			options = {
				{ -- 文字 转向胜利/转阶段 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.42, .87, .85},
					preview = L["新组合"]..L["倒计时"],
					data = {
						spellID = 461060,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[16] = {
								[1] = {14},
								[1.2] = {21},
								[1.3] = {21},
								[1.4] = {21},
								[1.5] = {21},
								[1.6] = {21},
							},
							[15] = {
								[1] = {19},
								[1.2] = {36},
								[1.3] = {36},
								[1.4] = {36},
								[1.5] = {36},
								[1.6] = {36},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						if self.phase == 1.6 then
							self.data.text = L["阶段转换"]
						else
							self.data.text = L["新组合"]
						end
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 461060, self.data.text, self, event, ...)				
					end,
				},
				{ -- 计时条 转向胜利（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 461060,
					color = {.42, .87, .85},
				},
				{ -- 首领模块 转向胜利（待测试）
					category = "BossMod",
					spellID = 461060,
					enable_tag = "everyone",
					name = T.GetIconLink(461060)..L["技能组合排序和击杀提示"],
					points = {a1 = "BOTTOMLEFT", a2 = "BOTTOMLEFT", x = 50, y = 580},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
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
								alert:SetHeight(value*7+12)
								alert.bar:SetHeight(value)
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)
								end
								alert:line_up()
							end
						},
						{
							key = "countdown_bool", 
							text = L["准备交奖券"]..L["倒计时"],
							default = true,
						},
						{
							key = "1_blank",
						},
						{
							key = "mrt_custom_btn", 
							text = L["粘贴MRT模板"],
						},
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("check")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)					
						frame.bars = {}
						frame.sort_bars = {}
						frame.cast_spellID = 461060 -- 转向胜利

						frame.boss_unit = {
							["boss2"] = L["左"],
							["boss3"] = L["中"],
							["boss4"] = L["右"],
						}
						
						frame.tokens = {
							[472828] = true,
							[472783] = true,
							[472832] = true,
							[472837] = true,
						}
						
						frame.sortedTokenOrder = {
							["震击烈焰"] = 464772,
							["烈焰震击"] = 464772,
							
							["炸弹震击"] = 464801,
							["震击炸弹"] = 464801,
							
							["炸弹烈焰"] = 464804,
							["烈焰炸弹"] = 464804,
							
							["硬币烈焰"] = 464806,
							["烈焰硬币"] = 464806,
							
							["硬币震击"] = 464809,
							["震击硬币"] = 464809,
							
							["炸弹硬币"] = 464810,
							["硬币炸弹"] = 464810,
						}
						
						frame.spell_info = {
							[464772] = { index = 1, tags = {"|cff0ba7f9震击|r", "|cffff8617烈焰|r"}, text = "躲球", spellIDs = {464476, 464475}},
							[464801] = { index = 2, tags = {"|cff0ba7f9震击|r", "|cff8000ff炸弹|r"}, text = "炸弹", spellIDs = {464476, 464484}},
							[464804] = { index = 3, tags = {"|cffff8617烈焰|r", "|cff8000ff炸弹|r"}, text = "炸弹+躲球", spellIDs = {464475, 464484}},
							[464806] = { index = 4, tags = {"|cffff8617烈焰|r", "|cffffff00硬币|r"}, text = "AOE", spellIDs = {464475, 464482}},
							[464809] = { index = 5, tags = {"|cff0ba7f9震击|r", "|cffffff00硬币|r"}, text = "拉人", spellIDs = {464476, 464482}},
							[464810] = { index = 6, tags = {"|cff8000ff炸弹|r", "|cffffff00硬币|r"}, text = "强化炸弹", spellIDs = {464484, 464482}},
						}

						frame.bar = T.CreateTimerBar(frame, 629485, false, false, true, nil, nil, {1, .3, 0})
						frame.bar:SetPoint("TOPLEFT", 0, 0)
						frame.bar:SetMinMaxValues(0, 30)
						frame.bar.left:SetText(L["倒计时"])
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame2 = T.CreateAlertTextShared("bossmod"..frame.config_id.."-pos", 1)
						frame.text_frame3 = T.CreateAlertTextShared("bossmod"..frame.config_id.."-countdown", 1)
						frame.text_frame3.show_time = 5
						frame.text_frame3.floor_num = true
						frame.text_frame3.prepare_sound = "1296\\token"
						
						frame.shared_bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, 629485, L["倒计时"], {1, .3, 0})
						
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
						
						for spellID, info in pairs(frame.spell_info) do              
							local icon = C_Spell.GetSpellTexture(spellID)
							local bar = T.CreateTimerBar(frame, icon)
							bar.left:SetText(string.format("%s  (%s)", strjoin(" ", unpack(info.tags)), info.text))
							bar.right:SetText(L["可选"])
							bar.passed = 1
							bar.active = 0
							bar.index = info.index
							bar.str = strjoin(" ", unpack(info.tags))
							
							function bar:update()
								if bar.passed == 1 then
									bar:SetStatusBarColor(.7, .7, .7)
									if bar.active == 1 then
										bar.right:Show()
									else
										bar.right:Hide()
									end
								else
									bar:SetStatusBarColor(.3, .3, .3)
									bar.right:Hide()
								end
								frame:line_up()
							end
							
							bar:update()
							
							frame.bars[spellID] = bar
						end
						
						function frame:UpdateMrtOrder()
							local tokenPriorities = {}
							local order = {}
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							
							if text then
								for line in text:gmatch('[^\r\n]+') do
									if string.match(line, "#"..L["组合顺序"]) then
										for tag in line:gmatch("%(([^)]*)%)") do
											local key = frame.sortedTokenOrder[tag]
											local validTokenCombination = key and not tContains(tokenPriorities, key)
											if validTokenCombination then
												table.insert(tokenPriorities, key)
											end
										end
									end
								end
							end
							
							for index, spellID in ipairs(tokenPriorities) do
								local bar = frame.bars[spellID]
								bar.index = index
							end
						end
						
						function frame:copy_mrt()
							return string.format("#"..L["组合顺序"]..string.format("(%s)(%s)(%s)(%s)(%s)(%s)", "硬币震击", "炸弹硬币", "炸弹烈焰", "硬币烈焰", "炸弹震击", "震击烈焰"))
						end
						
						function frame:PreviewShow()
							T.StartTimerBar(self.bar, 10, true, true, true)
							self:UpdateMrtOrder()
							self:line_up()
						end
						
						function frame:PreviewHide()
							T.StopTimerBar(self.bar, true, true, true)
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.spell_count = 0
							frame:UpdateMrtOrder()
							frame:line_up()
							
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and frame.bars[cast_spellID] then
								local bar = frame.bars[cast_spellID]
								bar.passed = 0
								bar:update()
								
								T.StopTimerBar(frame.shared_bar, true, true, true)
								T.StopTimerBar(frame.bar, true, true, true)
								
								if C.DB["BossMod"][frame.config_id]["countdown_bool"] then
									T.Stop_Text_Timer(frame.text_frame3)
								end
							elseif unit == "boss1" and cast_spellID == frame.cast_spellID then
								frame.spell_count = frame.spell_count + 1
								
								for spellID, info in pairs(frame.spell_info) do
									info.mob1 = false
									info.mob2 = false
								end
								
								for spellID, bar in pairs(frame.bars) do
									bar.active = 0
									bar:update()
									if bar.index == frame.spell_count then
										T.Start_Text_Timer(frame.text_frame, 4, bar.str)
									end
								end
								
								T.StartTimerBar(frame.shared_bar, 32, true, true, true)
								T.StartTimerBar(frame.bar, 32, true, true, true)
								
								frame.next_exp = GetTime() + 32
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_spellID == frame.cast_spellID then
								C_Timer.After(.2, function()
									for unit, pos in pairs(frame.boss_unit) do
										for spellID, info in pairs(frame.spell_info) do
											if AuraUtil.FindAuraBySpellID(info.spellIDs[1], unit, "HELPFUL") then
												info.mob1 = unit
											elseif AuraUtil.FindAuraBySpellID(info.spellIDs[2], unit, "HELPFUL") then
												info.mob2 = unit
											end
										end
									end
									
									for spellID, bar in pairs(frame.bars) do
										if frame.spell_info[spellID].mob1 and frame.spell_info[spellID].mob2 then
											bar.active = 1
											bar:update()
											if bar.index == frame.spell_count then
												local str = ""
												local t = {frame.spell_info[spellID].mob1, frame.spell_info[spellID].mob2}
												table.sort(t)
												for i, unit in pairs(t) do
													str = str..frame.boss_unit[unit] 
													if i == 1 then
														str = str.." + "
													end
													T.ShowNameplateExtraTex(unit, "check")
												end 
	
												T.Start_Text_Timer(frame.text_frame2, 10, str)
											end
										end
									end
								end)
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and frame.tokens[spellID] and destGUID == G.PlayerGUID then
								if C.DB["BossMod"][frame.config_id]["countdown_bool"] then
									local remain = frame.next_exp - GetTime()
									if remain >= 2 then
										frame.text_frame3.count_down_start = 5
										T.Start_Text_DelayTimer(frame.text_frame3, remain, L["准备交奖券"], true)
									else
										frame.text_frame3.count_down_start = nil
										T.Start_Text_DelayTimer(frame.text_frame3, remain, L["快交奖券"], true)
										T.PlaySound("1296\\token_now")
									end
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and frame.tokens[spellID] and destGUID == G.PlayerGUID then
								if C.DB["BossMod"][frame.config_id]["countdown_bool"] then
									T.Stop_Text_Timer(frame.text_frame3)
								end
							end
						end
					end,
					reset = function(frame, event)
						for spellID, bar in pairs(frame.bars) do
							bar.passed = 1
							bar.active = 0
							bar:update()
						end
						T.Stop_Text_Timer(frame.text_frame)
						T.Stop_Text_Timer(frame.text_frame2)
						T.Stop_Text_Timer(frame.text_frame3)
						T.StopTimerBar(frame.shared_bar, true, true, true)
						T.StopTimerBar(frame.bar, true, true, true)
						T.HideAllNameplateExtraTex()
						frame:Hide()
					end,
				},
				{ -- 图标 有人耍诈！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 461068,
					hl = "red",
					tip = L["BOSS狂暴"],
				},
				{ -- 图标 金色奖券（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 464705,
					tip = L["BOSS强化"].."%s5%",
				},
				{ -- 图标 礼券：炸弹（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 472837,
					spellIDs = {472828, 472832, 472783},
					options_spellIDs = {472837, 472828, 472832, 472783},
					hl = "gre_flash",
				},
				{ -- 计时条 礼券：炸弹（待测试）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 472837,
					spellIDs = {472828, 472832, 472783},
					options_spellIDs = {472837, 472828, 472832, 472783},
					color = {.5, 0, 1},
					show_tar = true,
				},
			},
		},
		{ -- 奖励：震击与烈焰
			spells = {
				{464772},
			},
			options = {
				{ -- 计时条 奖励：震击与烈焰（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464772,
					color = {.98, .51, .02},
					sound = "[wave]cast",
					text = L["线圈"].."+"..L["躲球"],
				},
			}
		},
		{ -- 奖励：震击与炸弹
			spells = {
				{464801},
			},
			options = {
				{ -- 计时条 奖励：震击与炸弹（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464801,
					color = {.25, .25, .91},
					sound = "[bomb]cast",
					text = L["线圈"].."+"..L["炸弹"],
				},
				{ -- 图标 易爆凝视（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 465009,
					hl = "red",
					sound = "[bombonyou]",
				},
				{ -- 姓名板法术来源图标 易爆凝视（✓）
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 465009,
					hl_np = true,
				},
			}
		},
		{ -- 奖励：烈焰与炸弹
			spells = {
				{464804},
			},
			options = {
				{ -- 计时条 奖励：烈焰与炸弹（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464804,
					color = {.71, .51, .53},
					sound = "[bomb]cast",
					text = L["炸弹"].."+"..L["躲球"],
				},
				{ -- 图标 易爆凝视（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 465010,
					hl = "red",
					sound = "[bombonyou]",
				},
				{ -- 姓名板法术来源图标 易爆凝视（待测试）
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 465010,
					hl_np = true,
				},
			}
		},
		{ -- 奖励：烈焰与硬币
			spells = {
				{464806},
			},
			options = {
				{ -- 计时条 奖励：烈焰与硬币（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464806,
					spellIDs = {461389},
					color = {1, .58, .1},
					sound = "[aoe]cast",
					text = L["全团AE"],
				},
				{ -- 图标 烈焰与硬币（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 461390,
					tip = L["DOT"],
				},
			}
		},
		{ -- 奖励：硬币与震击
			spells = {
				{464809},
			},
			options = {
				{ -- 计时条 奖励：硬币与震击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464809,
					color = {1, .78, .42},
					sound = "[pull]cast",
					text = L["线圈"].."+"..L["拉人"],
				},
				{ -- 首领模块 硬币磁铁 计时条（待测试）
					category = "BossMod",
					spellID = 474665,
					enable_tag = "none",
					name = string.format(L["计时条%s"], T.GetIconLink(474665)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id.."-dur", 961622, L["吸人"], {1, .92, .63})
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.coil = false
							frame.lastStart = 0						
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if cast_GUID and cast_spellID == 464809 then -- 硬币与震击
								frame.coil = true
								C_Timer.After(1.5, function()
									T.StartTimerBar(frame.bar, 5, true, true, true)
									frame.lastStart = GetTime()
								end)
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_DAMAGE" and spellID == 474665 then -- 硬币磁铁
								local currentTime = GetTime()
								if currentTime > frame.lastStart + 5.2 then
									frame.lastStart = GetTime() - 1
									T.StartTimerBar(frame.bar, 4, true, true, true)
								end
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 461060 then -- 转向胜利
								if frame.coil then
									T.StartTimerBar(frame.bar, 5, true, true, true)
									frame.lastStart = GetTime()
								end
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.bar)
					end,
				},
				
			}
		},
		{ -- 奖励：硬币与炸弹
			spells = {
				{464810},
			},
			options = {
				{ -- 计时条 奖励：硬币与炸弹（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 464810,
					color = {.97, .91, .34},
					sound = "[bomb]cast",
					text = L["免控"].."+"..L["炸弹"],
				},
			}
		},
		{ -- 转轮助理
			npcs = {
				{30085},
			},
			options = {
				{ -- 首领模块 小怪血量 转轮助理（✓）
					category = "BossMod",
					spellID = 460973,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("228463")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -300},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["UNIT_AURA"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["228463"] = {color = {.39, .58, .96}}, -- 转轮助理
						}
						
						frame.auras = {
							[460973] = { -- 扩增型胸甲
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
				{ -- 姓名板光环 扩增型胸甲
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 460973,
				},
				{ -- 首领模块 标记 转轮助理
					category = "BossMod",
					spellID = 460582,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("228463"), T.FormatRaidMark("6,7,8")),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					init = function(frame)
						
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 461060 then -- 转向胜利
								C_Timer.After(.2, function()
									SetRaidTarget("boss2", 6)
									SetRaidTarget("boss3", 7)
									SetRaidTarget("boss4", 8)
								end)
							end
						end
					end,
					reset = function(frame, event)
						
					end,
				},
				{ -- 姓名板打断图标 超载！（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 460582,
					mobID = "228463",
					interrupt = 3,
					ficon = "6",
					mrt_info = {"6,7,8", true},
				},
				{ -- 图标 凋零烈焰（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 471927,
					tip = L["炸弹"],
					hl = "org_flash",
					ficon = "7",
				},
				{ -- 首领模块 凋零烈焰 点名统计 逐个填坑
					category = "BossMod",
					spellID = 471927,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(471927)).." "..string.format(L["NAME驱散提示2"], T.GetSpellIcon(471927)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ADDON_MSG"] = true,
					},
					custom = {
						{
							key = "use_delay_bool",
							text = L["自动提示驱散"],
							default = false,
						},
						{
							key = "delay_sl",
							text = L["自动提示驱散延迟"],
							default = 2,
							min = 1,
							max = 7,
						},
						{
							key = "dispel_index1_bool",
							text = L["接受驱散的序号"].."1",
							default = true,
						},
						{
							key = "dispel_index2_bool",
							text = L["接受驱散的序号"].."2",
							default = true,
						},
						{
							key = "dispel_index3_bool",
							text = L["接受驱散的序号"].."3",
							default = true,
						},
						{
							key = "1_blank",
						},
					},
					init = function(frame)
						frame.aura_id = 471927
						frame.element_type = "bar"
						frame.color = {1, 0, 0}
						frame.role = true
						frame.raid_glow = "pixel"
						frame.raid_index = true
						frame.disable_copy_mrt = true
						frame.bar_num = 3
						frame.reset_index = 3
						
						frame.info = {
							{text = "[1]", msg_applied = "{rt7}%name", msg = "{rt7}%name"},
							{text = "[2]", msg_applied = "{rt7}%name", msg = "{rt7}%name"},
							{text = "[3]", msg_applied = "{rt7}%name", msg = "{rt7}%name"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:post_display(element, index, unit, GUID)
							if not element.extra_text then
								local h = element:GetHeight()
								element.extra_text = T.createtext(element, "OVERLAY", floor(h*.6), "OUTLINE", "LEFT")
								element.extra_text:SetPoint("LEFT", element, "RIGHT", 5, 0)
								element:HookScript("OnSizeChanged", function(self, width, height)
									self.extra_text:SetFont(G.Font, floor(height*.6), "OUTLINE")
								end)
							end
							
							element.extra_text:SetText(L["未按宏"])
							
							if GUID == G.PlayerGUID then
								T.PlaySound("macro_ready")
								T.Start_Text_Timer(self.text_frame, 20, T.GetIconLink(471927)..L["点宏"])
							end
						end
						
						function frame:post_remove(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Stop_Text_Timer(self.text_frame)
							end
						end
						
						T.InitAuraMods_ByTime(frame)
					end,
					update = function(frame, event, ...)			
						T.UpdateAuraMods_ByTime(frame, event, ...)
						
						if event == "ADDON_MSG" then
							local channel, sender, GUID, message = ...
							if message == "DispelMe" then							
								if GUID == G.PlayerGUID then
									T.Stop_Text_Timer(frame.text_frame)
								end
								
								local bar = frame.actives[GUID]
								if bar then
									bar.extra_text:SetText(L["已按宏"])
									local tag = string.format("dispel_index%d_bool", bar.index)
									local info = T.GetGroupInfobyGUID(GUID)
									if info then
										if C.DB["BossMod"][frame.config_id][tag] then
											T.GlowRaidFramebyUnit_Show("proc", "bm"..frame.config_id, info.unit, {.1, 1, 1})
											T.msg(string.format(L["驱散讯息有光环"], info.format_name, T.GetIconLink(frame.aura_id)))
										else
											T.msg(string.format(L["驱散讯息序号过滤"], info.format_name, T.GetIconLink(frame.aura_id)))
										end
									end
								else
									local info = T.GetGroupInfobyGUID(GUID)
									if info then
										T.msg(string.format(L["驱散讯息无光环"], info.format_name, T.GetIconLink(frame.aura_id)))
									end
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, aura_id = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and aura_id == frame.aura_id and destGUID == G.PlayerGUID then
								if C.DB["BossMod"][frame.config_id]["use_delay_bool"] then
									local delay = C.DB["BossMod"][frame.config_id]["delay_sl"]
									C_Timer.After(delay, function()
										if AuraUtil.FindAuraBySpellID(frame.aura_id, "player", G.TestMod and "HELPFUL" or "HARMFUL") then
											T.addon_msg("DispelMe", "GROUP")
										end
									end)
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and aura_id == frame.aura_id then
								local unit_id = T.GetGroupInfobyGUID(destGUID)["unit"]
								T.GlowRaidFramebyUnit_Hide("proc", "bm471927", unit_id)
							end
						end
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByTime(frame)
						T.GlowRaidFrame_HideAll("proc", "bm471927")
					end,
				},
				{ -- 图标 电波冲击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460847,
					tip = L["全团AE"],
				},
				{ -- 首领模块 电波冲击 多人光环（✓）
					category = "BossMod",
					spellID = 460847,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(460847)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 275},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 3
						
						frame.spellIDs = {
							[460847] = { -- 电波冲击
								color = {.02, .08, 1},
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
		{ -- 奖励路线
			spells = {
				{460181},
			},
			options = {
				{ -- 文字 奖励路线 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 1},
					preview = T.GetIconLink(460181)..L["倒计时"],
					data = {
						spellID = 460181,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[464806] = 11.5, -- 奖励：烈焰与硬币
							[464810] = 5.3, -- 奖励：硬币与炸弹
							[464804] = 4.8, -- 奖励：烈焰与炸弹
							[464809] = 4.8, -- 奖励：硬币与震击
							[464801] = 4.8, -- 奖励：震击与炸弹
							[464772] = 4.8, -- 奖励：震击与烈焰
						},
						sound = "1296\\baitcoin",
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_GUID then
								if self.data.info[cast_spellID] then -- 特殊技能
									local dur = self.data.info[cast_spellID]
									T.Start_Text_DelayTimer(self, dur, L["引硬币"], true)
								elseif cast_spellID == 460181 then -- 奖励路线
									self.count = self.count + 1
									if self.phase ~= 2 then
										if mod(self.count, 2) == 1 then
											T.Start_Text_DelayTimer(self, 26.8, L["引硬币"], true)
										end
									else
										T.Start_Text_DelayTimer(self, 36.4, L["引硬币"], true)
									end
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.phase = ...
							T.Start_Text_DelayTimer(self, 24.5, L["引硬币"], true)
						elseif event == "ENCOUNTER_START" then
							self.show_time = 4							
							self.round = true
							
							if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
								self.prepare_sound = self.data.sound
								self.count_down_start = 3
							end
							
							self.phase = 1
							self.count = 0
							T.Start_Text_DelayTimer(self, 3, L["引硬币"], true)
						end
					end,
				},
				{ -- 计时条 奖励路线[音效:硬币滚出]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 460181,
					color = {1, .84, .07},
					sound = soundfile("460181cast", "cast"),
				},
				{ -- 计时条 奖励路线[音效:硬币滚回]（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 460674,
					dur = 1,
					color = {1, .84, .07},
					sound = soundfile("460674cast", "cast"),
					copy = true,
				},
				{ -- 图标 碾碎！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460430,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 图标 豪客！（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460444,
					tip = L["Buff"],
					hl = "gre",
				},
				{ -- 图标 渐入佳境（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 472718,
					icon_tex = 4638725,
					tip = L["BOSS强化"].."%s10%",
				},
				{ -- 首领模块 丢硬币瞄准辅助线
					category = "BossMod",
					spellID = 460181,
					enable_tag = "none",
					name = L["丢硬币瞄准辅助线"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = 0, width = 1, height = 1},
					events = {
						["UPDATE_EXTRA_ACTIONBAR"] = true,
					},
					init = function(frame)						
						frame.tex = frame:CreateTexture(nil, "OVERLAY")
						frame.tex:SetTexture(G.media.blank)
						frame.tex:SetVertexColor(0, 1, 0)
						frame.tex:SetSize(5, 2000)
						frame.tex:SetPoint("CENTER")
						frame.tex:Hide()
						
						function frame:ShowTex()
							frame.tex:Show()
						end
						
						function frame:HideTex()
							frame.tex:Hide()
						end
						
						function frame:PreviewShow()
							self:ShowTex()
						end
						
						function frame:PreviewHide()
							self:HideTex()
						end
					end,
					update = function(frame, event, ...)
						if event == "UPDATE_EXTRA_ACTIONBAR" then
							if HasExtraActionBar() then
								local extraPage = GetExtraBarIndex()
								local slot = extraPage * 12 - 11
								local _, spellID = GetActionInfo(slot)
								
								if spellID == 460674 then -- 奖励路线
									frame:ShowTex()
								end
							else
								frame:HideTex()
							end
						end
					end,
					reset = function(frame, event)
						frame:HideTex()
						frame:Hide()
					end,
				},
			},
		},
		{ -- 污秽排放
			spells = {
				{460164, "2"},
			},
			options = {
				{ -- 计时条 污秽排放（待测试）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 469993,
					color = {.29, .32, 1},
					sound = "[heal]cast",
					text = L["全团AE"],
				},
				{ -- 图标 污秽排放（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460164,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"].."+"..L["减速"],
				},
				{ -- 首领模块 污秽排放 团队吸收量计时条
					category = "BossMod",
					spellID = 460164,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环数值提示"], L["吸收治疗"]),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 200},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 8
						
						frame.spellIDs = {
							[460164] = { -- 污秽排放 M 142*3w
								aura_type = "HARMFUL",
								color = {.85, .03, 1},
								effect = 1,
								progress_value = 4260000,
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
		{ -- 重棒登场
			spells = {
				{460472, "0"},
			},
			options = {
				{ -- 文字 重棒登场 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.09, .39, 1},
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 460472,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							[15] = {
								[1] = {15.4, 19.4},
								[1.2] = {22.7, 15.3},
								[1.3] = {22.7, 15.3},
								[1.4] = {22.7, 15.3},
								[1.5] = {22.7, 15.3},
								[1.6] = {22.7, 15.3},
								[2] = {21.5, 20.7, 18, 18},
							},
							[16] = {
								[1] = {18.6, 18.3},
								[1.2] = {16, 20.7},
								[1.3] = {16, 20.7},
								[1.4] = {16, 20.7},
								[1.5] = {16, 20.7},
								[1.6] = {16, 20.7},
								[2] = {23, 23, 18, 18},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 5,
							prepare_sound = "prepare_drop",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 460472, L["大圈"], self, event, ...)				
					end,
				},
				{ -- 计时条 重棒登场（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 460472,
					color = {.2, .82, .87},
					text = L["大圈"],
					glow = true,
				},
				{ -- 图标 重棒登场（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460472,
					tip = L["易伤"].."750%",
					hl = "",
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 460472,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(460472)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[460472] = { -- 重棒登场
								color = {.82, .82, .87},
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
				{ -- 图标 震撼力场（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460576,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 操盘妙手！
			spells = {
				{465765, "5"},
			},
			options = {				
				{ -- 血量
					category = "TextAlert", 
					type = "hp",
					data = {
						npc_id = "228458",
						ranges = {
							{ ul = 34, ll = 30.2, tip = L["阶段转换"]..string.format(L["血量2"], 30)},
						},
					},
				},
				{ -- 声音 维修循环（待测试）
					category = "Sound",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 465765,
					file = "[phase]",
				},
			},
		},
		{ -- 机器联通
			spells = {
				{465432},
			},
			options = {
				{ -- 文字 线圈 倒计时（待测试）
					category = "TextAlert",
					type = "spell",
					color = {.4, .78, .88},
					preview = L["线圈"]..L["倒计时"],
					data = {
						spellID = 465432,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 465432 then -- 机器联通
								T.Start_Text_DelayTimer(self, 5, L["线圈"], true)
							elseif (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_REFRESH") and spellID == 473195 then -- 机器联通
								T.Start_Text_DelayTimer(self, 18, L["线圈"], true)
							end
						end
					end,
				},
				{ -- 计时条 机器联通（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465432,
					color = {.4, .78, .88},
					sound = "[ray]cast"
				},
			},
		},
		{ -- 热火朝天
			spells = {
				{465322},
			},
			options = {
				{ -- 计时条 热火朝天（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465322,
					color = {.91, .37, .01},
				},
				{ -- 声音 热火朝天（✓）
					category = "Sound",
					spellID = 465325,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[spread]",
				},
			},
		},
		{ -- 赏钱满天飞
			spells = {
				{465580},
			},
			options = {
				{ -- 计时条 赏钱满天飞（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465580,
					color = {1, .82, .16},
					text = L["DOT"],
				},
				{ -- 图标 赏钱满天飞（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",					
					spellID = 465580,
					tip = L["DOT"],
				},
			},
		},
		{ -- 爆破大奖
			spells = {
				{465587},
			},
			options = {
				{ -- 计时条 爆破大奖（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 465587,
					color = {1, 0, 0},
					text = L["倒计时"],
					glow = true,
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1.1,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 461060, -- 转向胜利
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 1.2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 461060, -- 转向胜利
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 1.3,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 461060, -- 转向胜利
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 1.4,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 461060, -- 转向胜利
					count = 4,
				},
				{
					category = "PhaseChangeData",
					phase = 1.5,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 461060, -- 转向胜利
					count = 5,
				},
				{
					category = "PhaseChangeData",
					phase = 1.6,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 461060, -- 转向胜利
					count = 6,
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 465765, -- 维修循环
				},
			},
		},
	},
}