local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["毒素"] = "毒素"
	L["触发"] = "触发"
	L["镣铐"] = "镣铐"
	L["白线"] = "白线"
	L["不能进门"] = "不能进门"
	L["不能吃球"] = "不能吃球"
	L["传送延迟"] = "传送延迟"
	L["精华数量"] = "精华数量：%d"
	L["进门左转"] = "进门→左转"
	L["进门右转"] = "进门→右转"
	L["进门"] = "进门"
	L["附近"] = "附近"
	L["捡精华"] = "捡%s的精华"
	L["穿环"] = "穿环"
	L["观察射线"] = "观察射线"
	L["进门语音提示提前时间"] = "进门语音提示提前时间"
	L["焦点施法条和吸收盾"] = "焦点施法条和吸收盾"
	L["我的打断序号"] = "我的打断序号"
	L["只显示坦克"] = "只显示坦克"
	L["团队框架符号"] = "团队框架符号"
else
	L["毒素"] = "Toxin"
	L["触发"] = "Tigger"
	L["镣铐"] = "Shackles"
	L["白线"] = "Blades"
	L["不能进门"] = "NO gate"
	L["不能吃球"] = "NO orb"
	L["传送延迟"] = "Entry delay time"
	L["精华数量"] = "Essence:%d"
	L["进门左转"] = "Enter Gate → Go LEFT"
	L["进门右转"] = "Enter Gate → Go Right"
	L["进门"] = "Enter Gate"
	L["附近"] = "nearby"
	L["捡精华"] = "Pick up essence %s"
	L["穿环"] = "Cross"
	L["观察射线"] = "Watch ray"
	L["进门语音提示提前时间"] = "Entrance voice prompt advance time"
	L["焦点施法条和吸收盾"] = "focus target cast bar and absorb value"
	L["我的打断序号"] = "my interrupt index"
	L["只显示坦克"] = "Only show tanks"
	L["团队框架符号"] = "Tags on raid frames"
end

---------------------------------Notes--------------------------------

---------------------------------Notes--------------------------------
-- TO DO:小怪血量 光环

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2602] = {
	engage_id = 2922,
	npc_id = {"218370"},
	alerts = {
		{ -- 活性毒素
			spells = {
				{437592},
			},
			options = {
				{ -- 文字 活性毒素 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.59, .83, .44},
					preview = L["毒素"]..L["倒计时"],
					data = {
						spellID = 437592,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[1] = {18, 56, 56},
							},
							[16] = {
								[1] = {19, 56, 53},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 437592, L["毒素"], self, event, ...)
					end,
				},
				{ -- 计时条 活性毒素（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 437592,
					color = {.59, .83, .44},
					ficon = "5",
				},
				{ -- 图标 活性毒素（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 437586,
					hl = "red_flash",
				},
				{ -- 图标 浓缩毒素（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 451278,
					hl = "org",
				},						
				{ -- 图标 泛沫毒素（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464638,
					hl = "yel",
				},
				{ -- 图标 反应创伤（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464628,
					tip = L["易伤"].."2000%",
				},
				{ -- 图标 残存毒素（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 464643,
					hl = "",
					tip = L["DOT"],
					ficon = "12",
				},
				{ -- 图标 酸池（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 437078,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 毒性反应（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460133,
					tip = L["易伤"].."1000%",
					ficon = "12",
				},
				{ -- 首领模块 计时圆圈 活性毒素 浓缩毒素（✓）
					category = "BossMod",
					spellID = 464640,
					enable_tag = "none",
					name = T.GetIconLink(437586)..T.GetIconLink(451278)..T.GetIconLink(460133)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[437586] = { -- 活性毒素
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 0, 0},
							},
							[451278] = { -- 浓缩毒素
								unit = "player",
								aura_type = "HARMFUL",
								color = {0, 1, 1},
							},
							[460133] = { -- 毒性反应
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .3, .1},
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
				{ -- 首领模块 活性毒素 点名统计 整体排序（✓）
					category = "BossMod",
					spellID = 437586,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(437586)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 437586
						frame.element_type = "bar"
						frame.color = {.77, .88, .62}
						frame.raid_glow = "pixel"
						frame.raid_index = true
						frame.support_spells = 3
						
						frame.diffculty_num = {
							[14] = 1, -- PT
							[15] = 2, -- H
							[16] = 3, -- M
						}
						
						frame.info = {
							{text = "1"..T.FormatRaidMark("1"), msg_applied = "{rt1}1 %name", msg = "{rt1}1", sound = "[count\\1]"},
							{text = "2"..T.FormatRaidMark("2"), msg_applied = "{rt2}2 %name", msg = "{rt2}2", sound = "[count\\2]"},
							{text = "3"..T.FormatRaidMark("3"), msg_applied = "{rt3}3 %name", msg = "{rt3}3", sound = "[count\\3]"},
						}

						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 6, self.info[index]["text"], true)
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
						if frame.difficultyID == 16 then
							if event == "COMBAT_LOG_EVENT_UNFILTERED" then
								local _, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
								if sub_event == "SPELL_CAST_START" and spellID == 437592 then
									if frame.total_aura_num then
										frame.total_aura_num = min(3, frame.total_aura_num + 1)
									else
										frame.total_aura_num = 3
									end
								end
							elseif event == "ENCOUNTER_START" then
								frame.total_aura_num = 1
							end
						end
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
					end,
				},
				{ -- 首领模块 活性毒素 MRT轮次分配（✓）
					category = "BossMod", 
					spellID = 437592,
					ficon = "12",
					enable_tag = "everyone",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(437592)),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_SPELL_ASSIGN"] = true,
					},
					init = function(frame)
						frame.custom_trigger = true
						frame.cast_id = 437592
						frame.assign_count = 3
						frame.raid_glow = "pixel"
						frame.raid_glow_color = {1, .3, 0}
						frame.share_dmg_assignment = {}

						function frame:override_action(count, display_count, GUIDs, my_index)
							T.PlaySound("mark\\mark"..my_index)
							T.Start_Text_Timer(frame.text_frame, 10, L["触发"]..T.FormatRaidMark(my_index))
						end
						
						function frame:post_update_count_up(assign_count, display_count)
							if frame.assignment[assign_count] and not tContains(frame.assignment[assign_count], G.PlayerGUID) then
								local my_share_index
								local count = 0
								for i, GUID in pairs(frame.share_dmg_assignment) do
									if not tContains(frame.assignment[assign_count], GUID) then
										count = count + 1
										if GUID == G.PlayerGUID then
											my_share_index = count
										end
									end
								end
								if my_share_index then
									local aura_num = min(assign_count + 1, 3)
									local share_group_num = ceil((20 - aura_num)/aura_num)
									local my_group_index = ceil(my_share_index/share_group_num)
	
									T.PlaySound("mark\\mark"..my_group_index)
									T.Start_Text_Timer(frame.text_frame, 10, L["分担"]..T.FormatRaidMark(my_group_index))
								end
							end
						end
						
						T.InitSpellBars(frame)
						
						function frame:copy_mrt()
							local str, spelllist, raidlist = "", "", ""

							for ind = 1, 3 do
								str = str..string.format("\n[%d]", ind) -- 换行
								
								local i = 0
								for unit in T.IterateGroupMembers() do
									i = i + 1
									if i <= 3 and i <= ind + 1 then
										local name = UnitName(unit)
										str = str.." "..T.ColorNameForMrt(name)
									end
								end
							end
							
							spelllist = string.format("#%sstart%s%s\nend", frame.config_id, frame.spell, str)
							
							for unit in T.IterateGroupMembers() do
								local name = UnitName(unit)
								raidlist = raidlist..T.ColorNameForMrt(name).." "
							end
							
							raidlist = string.format("\n#%dshare_dmg_start%s\n%s\nend", frame.config_id, C_Spell.GetSpellName(frame.config_id)..L["分担"], raidlist).."\n"
							
							return spelllist..raidlist
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local timestamp, sub_event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == frame.cast_id then -- 活性毒素
								C_Timer.After(6, function()
									T.FireEvent("JST_SPELL_ASSIGN", frame.cast_id)
								end)
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 451278 then -- 浓缩毒素
								if destGUID == G.PlayerGUID then
									T.Stop_Text_Timer(frame.text_frame)
								end
								local unit_id = T.GetGroupInfobyGUID(destGUID)["unit"]
								if unit_id then
									T.GlowRaidFramebyUnit_Hide(frame.raid_glow, "debuff"..frame.config_id, unit_id)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.share_dmg_assignment = table.wipe(frame.share_dmg_assignment)
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							
							if text then
								local betweenLine
								local tag = string.format("#%dshare_dmg_start", frame.config_id)
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
											local info = T.GetGroupInfobyName(name)
											if info then		
												table.insert(frame.share_dmg_assignment, info.GUID)
											else
												T.test_msg(string.format(L["昵称错误"], name))
											end
										end
									end
									if line:match(tag) then
										betweenLine = true
									end
								end
							end
						end
						
						T.UpdateSpellBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellBars(frame)
					end,
				},
			},
		},
		{ -- 剧毒新星
			spells = {
				{437417, "4"},
			},
			options = {
				{ -- 计时条 剧毒新星（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 437417,
					color = {.87, .96, .6},
					ficon = "4",
					text = L["圆环"],
					sound = "[ring]cast",
					glow = true,
				},
			},
		},
		{ -- 流丝之墓
			spells = {
				{439814, "1"},
			},
			options = {
				{ -- 计时条 流丝之墓（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439814,
					color = {.91, .89, .83},
				},
				{ -- 图标 勒握流丝（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441958,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 流丝之墓 计时圆圈（✓）
					category = "BossMod",
					spellID = 439814,
					enable_tag = "none",
					name = T.GetIconLink(439814)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[439814] = { -- 流丝之墓
								event = "SPELL_CAST_START",
								dur = 4,
								color = {.91, .89, .83},
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
		{ -- 液化
			spells = {
				{440899, "0"},
			},
			options = {
				{ -- 文字 液化 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, .61, .78},
					preview = L["准备"]..L["引水"]..L["倒计时"],
					data = {
						spellID = 440899,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
						info = {
							[15] = {
								[1] = {9.5, 40, 52},
							},
							[16] = {
								[1] = {7.5, 40, 54},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 440899, L["引水"], self, event, ...)
					end,
				},
				{ -- 文字 液化引水 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = L["引水"]..L["生效"]..L["倒计时"],
					data = {
						spellID = 436800,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, castID, spellID = ...
							if unit == "boss1" and spellID == 440899 then
								T.Start_Text_Timer(self, 2, L["引水"], true)
							end
						end
					end,
				},
				{ -- 计时条 液化[音效:液化]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 440899,
					color = {1, .61, .78},
					show_tar = true,
					sound = soundfile("440899cast", "cast"),
				},
				{ -- 图标 液化（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 436800,
					hl = "",
					tip = L["易伤"].."+"..L["DOT"],
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 436800,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(436800)..T.GetIconLink(455404)..T.GetIconLink(462558)..T.GetIconLink(443656)..T.GetIconLink(443342)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[436800] = { -- 液化（✓）
								color = {1, .92, .26},
							},
							[455404] = { -- 盛宴（✓）
								color = {.98, .63, .45},
							},
							[449236] = { -- 腐蚀锐牙（✓）
								color = {.22, .6, .05},
							},
							[443656] = { -- 感染（✓）
								color = {.87, .67, .97},
							},
							[443342] = { -- 啃噬（✓）
								color = {.61, .46, 1},
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
		{ -- 盛宴
			spells = {
				{437093},
			},
			options = {
				{ -- 计时条 盛宴[音效:盛宴]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 437093,
					color = {.98, .63, .45},
					show_tar = true,
					sound = soundfile("437093cast", "cast"),
					ficon = "0",
				},
				{ -- 图标 盛宴（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 455404,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],
				},
			},
		},
		{ -- 网刃
			spells = {
				{439299},
			},
			options = {
				{ -- 文字 网刃 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "3,12",
					color = {1, .9, .78},
					preview = L["白线"]..L["倒计时"],
					data = {
						spellID = 439536,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[1] = {20, 47, 47, 25},
								[3] = {66, 39, 41, 19},
							},
							[16] = {
								[1] = {20, 40, 13, 25, 19, 20},
								[3] = {29, 37, 19, 17, 42, 21, 19},
							}
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.dif = select(3, ...)
							self.phase = 1
							self.spell_count = 0
							self.next = 1
							
							local next_dur = self.data.info[self.dif] and self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][self.next]
							
							if next_dur then
								T.Start_Text_DelayTimer(self, next_dur, L["白线"], true)
							end
							
						elseif event == "ENCOUNTER_PHASE" then
							self.phase = ...
							if self.phase == 3 then
								self.spell_count = 0
								self.next = 1
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 439299 then -- 网刃
								self.spell_count = self.spell_count + 1
								if mod(self.spell_count, 4) == 1 then              
									self.next = self.next + 1
									
									local next_dur = self.data.info[self.dif] and self.data.info[self.dif][self.phase] and self.data.info[self.dif][self.phase][self.next]
									
									if next_dur then
										T.Start_Text_DelayTimer(self, next_dur, L["白线"], true)
									end
								end
							end
						end
					end,
				},
				{ -- 图标 网刃（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 439536,
					hl = "",
					tip = L["减速"].."95%",
				},
				{ -- 首领模块 分段计时条 网刃（✓）
					category = "BossMod",
					spellID = 439536,
					name = string.format(L["计时条%s"], T.GetIconLink(439536)),
					enable_tag = "none",
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)					
						frame.spell_info = {
							["SPELL_CAST_SUCCESS"] = {
								[439299] = {
									dur = 4,
									color = {0, 1, 0},
									divide_info = {
										dur = {.5, 1, 3, 3.5},
									},
								},
							},
						}
						
						function frame:filter(sub_event, spellID)
							local count = frame.spell_counts[sub_event][spellID]
							if mod(count, 4) == 1 then
								return true
							end
						end
						
						function frame:post_update_show(sub_event, spellID)
							self.bar:SetStatusBarColor(0,1,0)
							self.state = 1
						end
						
						function frame:progress_update(sub_event, spellID, remain)
							if remain <= 1.5 then
								if self.state == 2 then
									self.state = 3
									self.bar:SetStatusBarColor(1,0,0)
								end
							elseif remain <= 2.5 then
								if self.state == 1 then
									self.state = 2
									self.bar:SetStatusBarColor(1,.8,0)
								end
							end
						end
						
						T.InitSpellCastBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateSpellCastBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellCastBar(frame)
					end,
				},
			},
		},
		{ -- 掠食
			spells = {
				{447076},
			},
			options = {
				{ -- 计时条 掠食（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 447076,
					color = {.79, .48, .59},
					text = L["分散"].."+"..L["拉人"],
					sound = "[pull]cast,cd3"
				},
				{ -- 吸收盾 掠食（✓）
					category = "BossMod",
					spellID = 447207,
					enable_tag = "none",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(447207)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 447207 -- 掠食
						frame.aura_type = "HELPFUL"
						frame.effect = 1
						frame.time_limit = 46
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)		
					end,
				},
				{ -- 计时条 麻痹毒液[音效:出波]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 447456,
					color = {.34, .56, .07},
					count = true,
					sound = soundfile("447456cast", "cast"),
				},
				{ -- 图标 麻痹毒液（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 447532,
					hl = "",
					tip = L["易伤"].."%s20%".."+"..L["减速"].."%s6%",
				},
				{ -- 计时条 强征（✓）
					category = "BossMod",
					spellID = 447411,
					enable_tag = "none",
					name = string.format(L["计时条%s"], T.GetIconLink(447411)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spell_count1 = 0
						frame.spell_count2 = 0
						
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, 1603014, L["拉人"], {1, .7, .42})
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame.round = true
						frame.text_frame.show_time = 3
						frame.text_frame.count_down_start = 3
						
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, castID, spellID = ...
							if unit == "boss1" and castID then
								if spellID == 447411 then
									frame.spell_count1 = frame.spell_count1 + 1
									local str = string.format("%s [%d]", L["拉人"], frame.spell_count1)
									frame.bar.left:SetText(str)
									T.StartTimerBar(frame.bar, 6, true, true)
									T.Start_Text_DelayTimer(frame.text_frame, 6, str, true)
									T.PlaySound("1273\\pre_pull")
								elseif spellID == 450191 then
									frame.casting = true
								end
							end
						elseif event == "UNIT_SPELLCAST_STOP" then
							local unit, _, spellID = ...
							if unit == "boss1" then
								if spellID == 447411 then
									T.StopTimerBar(frame.bar, true, true)
									T.Stop_Text_Timer(frame.text_frame)
								end
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" then
								if spellID == 450191 then
									frame.casting = nil
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 447170 and destGUID == G.PlayerGUID then
								if frame.casting then
									frame.spell_count2 = frame.spell_count2 + 1
									local str = string.format("%s [%d]", L["拉人"], frame.spell_count2)
									frame.bar.left:SetText(str)
									T.StartTimerBar(frame.bar, 5, true, true)
									T.Start_Text_DelayTimer(frame.text_frame, 5, str, true)
									T.PlaySound("1273\\pre_pull")
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 447170 and destGUID == G.PlayerGUID then
								T.StopTimerBar(frame.bar, true, true)
								T.Stop_Text_Timer(frame.text_frame)
							end
						elseif event == "ENCOUNTER_START" then
							frame.spell_count1 = 0
							frame.spell_count2 = 0
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
						T.Stop_Text_Timer(frame.text_frame)
						frame.casting = nil
					end,
				},
				{ -- 首领模块 强征 多人光环（?）
					category = "BossMod",
					spellID = 450191,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(450191)),			
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -350},
					events = {
						["UNIT_AURA"] = true,
					},
					custom = {
						{
							key = "only_tank_bool",
							text = L["只显示坦克"],
							default = true,
						},
					},
					init = function(frame)
						frame.bar_num = 2
						
						frame.spellIDs = {
							[447170] = { -- 掠食之丝
								aura_type = "HARMFUL",
								color = {1, .7, .42},
							},
						}
						
						function frame:filter(auraID, spellID, GUID)
							local role = T.GetGroupInfobyGUID(GUID)["role"]
							if not C.DB["BossMod"][self.config_id]["only_tank_bool"] or (role and role == "TANK") then
								return true
							end
						end
						
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
		{ -- 幽影之门
			spells = {
				{460366, "12"},
			},
			options = {			
				{ -- 图标 暗影扭曲（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 460218,
					tip = L["不能进门"],
					ficon = "12",
				},
				{ -- 首领模块 幽影之门（✓）
					category = "BossMod",
					spellID = 460369,
					ficon = "12",
					enable_tag = "everyone",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(460369)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 30},
					events = {	
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
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)	
								end
								alert:line_up()
							end
						},
						{
							key = "sound_sl",
							text = L["进门语音提示提前时间"],
							default = 2,
							min = 1,
							max = 5,
							apply = function(value, alert)
								alert.text_frame.count_down_start = value
							end
						},
						{
							key = "mrt_custom_btn", 
							text = L["粘贴MRT模板"],
						},
					},
					init = function(frame)
						frame.spell = C_Spell.GetSpellName(frame.config_id)
						frame.icon = C_Spell.GetSpellTexture(frame.config_id)
						frame.assignment = {}
						frame.gates = {}
						frame.bars = {}
						frame.gate_num = 0
						frame.dead_add = 0
						
						frame.text_info = {
							L["进门左转"],
							L["进门左转"],
							L["进门右转"],
							L["进门左转"],
							L["进门右转"], 
							L["进门"], 
							L["进门"],
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						frame.text_frame.count_down_start = 2
						frame.text_frame.mute_count_down = true
						frame.text_frame.prepare_sound = "1273\\gate_now"
						
						function frame:copy_mrt()
							local str, raidlist = "", ""

							for ind = 1, 2 do
								raidlist = raidlist..string.format('\n[%d]', ind) -- 换行
								local i = 0
								for unit in T.IterateGroupMembers() do
									i = i + 1
									if i <= 7 then
										local name = UnitName(unit)
										raidlist = raidlist.." "..T.ColorNameForMrt(name)
									end
								end
							end
							
							str = string.format("#%sstart%s%s\nend\n", self.config_id, self.spell, raidlist)
							
							return str
						end
						
						function frame:line_up()
							table.sort(self.bars, function(a, b)
								if a.groupInd < b.groupInd then
									return true
								elseif a.groupInd == b.groupInd and a.exp_time < b.exp_time then
									return true
								end
							end)
							
							local count = 0
							for _, bar in pairs(self.bars) do
								if bar:IsShown() then
									bar:ClearAllPoints()
									bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -count*(C.DB["BossMod"][self.config_id]["height_sl"]+2))
									count = count + 1
								end
							end
						end
						
						function frame:CreateNewBar(groupInd, index, unit, format_name)
							local bar = T.CreateTimerBar(self, self.icon, false, false, false, C.DB["BossMod"][self.config_id]["width_sl"], C.DB["BossMod"][self.config_id]["height_sl"], {.67, .36, 1})
							
							local name = format_name or ""
							local str = index and frame.text_info[index] or ""
							
							bar:SetMinMaxValues(0, 12)
							bar.left:SetText(groupInd..". "..name)
							bar.exp_time = GetTime() + 12
							bar.unit = unit
							bar.groupInd = groupInd
							bar.index = index
							
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
							
							if UnitIsUnit(unit, "player") and not T.IsInPreview() then
								T.Start_Text_Timer(self.text_frame, 12, str, true)
								T.PlaySound("1273\\gate")
							end
							
							table.insert(self.bars, bar)
							
							self:line_up()
						end
						
						function frame:PreviewShow()
							self:CreateNewBar(1, 1, "player", T.ColorNameText(G.PlayerName, "player"))
							self:CreateNewBar(2, 1, "player", T.ColorNameText(G.PlayerName, "player"))
						end
						
						function frame:PreviewHide()
							for _, bar in pairs(self.bars) do
								bar:Hide()
								bar:SetScript("OnUpdate", nil)
							end
							self.bars = table.wipe(self.bars)
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.assignment = table.wipe(frame.assignment)
							frame.gates = table.wipe(frame.gates)							
							frame.gate_num = 0
							frame.dead_add = 0
							
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
							
							if text then
								local tag = string.format("#%dstart", frame.config_id)
		
								local betweenLine = false
								local tagmatched = false
								local count = 0
								
								for line in text:gmatch('[^\r\n]+') do
									if line == "end" then
										betweenLine = false
									end
									if betweenLine then
										count = count + 1
										frame.assignment[count] = {}
										for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
											local info = T.GetGroupInfobyName(name)
											if info then					
												table.insert(frame.assignment[count], {GUID = info.GUID, used = false})
											else
												T.test_msg(string.format(L["昵称错误"], name))
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
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_CAST_START" and spellID == 460369 then
								if not frame.gates[sourceGUID] then
									frame.gate_num = frame.gate_num + 1
									if mod(frame.gate_num, 2) == 1 then
										frame.gates[sourceGUID] = 1
									else
										frame.gates[sourceGUID] = 2
									end
								end
								
								local groupInd = frame.gates[sourceGUID]
								
								local index, unit, target_name, target_GUID
								
								if frame.assignment[groupInd] then
									for i, v in pairs(frame.assignment[groupInd]) do
										if not v.used then
											local info = T.GetGroupInfobyGUID(v.GUID)
											if info and info.unit and not UnitIsDeadOrGhost(info.unit) then
												local name, _, count, _, dur, exp_time = AuraUtil.FindAuraBySpellID(460218, info.unit, "HARMFUL")
												if (not name) or (exp_time and exp_time - GetTime() < 10) then -- 无debuff 或 debuff时间小于10秒
													index = i
													unit = info.unit
													target_name = info.format_name
													target_GUID = v.GUID
													break
												end
											end
										end
									end
								end
								
								if index and unit and target_name and target_GUID then
									frame:CreateNewBar(groupInd, index, unit, target_name)	
								end
							elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 460218 then	
								local dest_unit = UnitTokenFromGUID(destGUID)
								
								if dest_unit then
									for _, bar in pairs(frame.bars) do
										if bar:IsShown() and bar.unit and UnitIsUnit(bar.unit, dest_unit) then
											frame.gates[sourceGUID] = bar.groupInd
											
											if frame.assignment[bar.groupInd] and frame.assignment[bar.groupInd][bar.index] then
												frame.assignment[bar.groupInd][bar.index]["used"] = true
											end
											
											bar:Hide()
											bar:SetScript("OnUpdate", nil)
											if UnitIsUnit(bar.unit, "player") then
												T.Stop_Text_Timer(frame.text_frame)
											end
										end
									end
								end
							elseif subEvent == "SPELL_AURA_REMOVED" and spellID == 448300 then -- 扬升者
								for _, bar in pairs(frame.bars) do
									if bar:IsShown() then
										bar:Hide()
										bar:SetScript("OnUpdate", nil)
										if bar.unit and UnitIsUnit(bar.unit, "player") then
											T.Stop_Text_Timer(frame.text_frame)
										end
									end
								end
							elseif subEvent == "SPELL_AURA_REMOVED" and (spellID == 462692 or spellID == 462693) then -- 卫士、驱逐者
								frame.dead_add = frame.dead_add + 1
								if frame.dead_add == 4 then
									for _, bar in pairs(frame.bars) do
										if bar:IsShown() then
											bar:Hide()
											bar:SetScript("OnUpdate", nil)
											if bar.unit and UnitIsUnit(bar.unit, "player") then
												T.Stop_Text_Timer(frame.text_frame)
											end
										end										
									end
								end
							end
						end
					end,
					reset = function(frame, event)
						for _, bar in pairs(frame.bars) do
							bar:Hide()
							bar:SetScript("OnUpdate", nil)
						end
						frame.bars = table.wipe(frame.bars)
						T.Stop_Text_Timer(frame.text_frame)
					end,				
				},
			},
		},
		{ -- 酸蚀箭
			spells = {
				{448660, "2"},
			},
			options = {
				{ -- 图标 酸蚀箭（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 448660,
					hl = "",
					tip = L["DOT"],
				},
			},
		},		
		{ -- 扬升虚空语者
			npcs = {
				{29633},
			},
			options = {
				{ -- 姓名板打断图标 暗影冲击（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 447950,
					mobID = "223150",
					interrupt = 5,
					ficon = "6",
					mrt_info = {"1,2,3,4", true},
				},
				{ -- 计时条 晦暗喷薄（✓） 
					category = "AlertTimerbar",
					type = "cleu",
					spellID = 447999,
					options_spellIDs = {448046},
					event = "SPELL_AURA_REMOVED",
					dur = 5.2,
					color = {.12, .52, .81},
					icon_tex = 4067372,
					text = C_Spell.GetSpellName(448046),
					text = L["击飞"],
				},
				{ -- 图标 阴霾（✓） 
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443403,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 首领模块 扬升虚空语者 自动标记（✓） 
					category = "BossMod", 
					spellID = 447950,
					enable_tag = "spell",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("223150"), T.FormatRaidMark("1,2,3,4")),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
					},
					custom = {
						{
							key = "use_mark_dd",
							text = L["标记"],
							default = "3",
							key_table = {
								{"1", T.FormatRaidMark("1,2")},
								{"3", T.FormatRaidMark("3,4")},
							},
							apply = function(value, frame)
								frame.start_mark = tonumber(value)
								frame.end_mark = tonumber(value)+1
							end,
						},
					},
					init = function(frame)
						frame.start_mark = 1
						frame.end_mark = 2
						frame.mob_npcID = "223150"

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
		{ -- 虔诚的敬奉者
			npcs = {
				{29639},
			},
			options = {
				{ -- 图标 晦暗之触（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 447967,
					spellIDs = {464056},
					hl = "blu",
					tip = L["DOT"],
					ficon = "7",
				},
				{ -- 首领模块 晦暗之触 多人光环（✓）
					category = "BossMod",
					spellID = 447967,
					enable_tag = "role",
					ficon = "2",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(447967)),	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 110},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 3
						
						frame.spellIDs = {
							[447967] = { -- 晦暗之触
								color = {.79, .53, .95},
								hl_raid = "pixel",
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
				{ -- 首领模块 晦暗之触 驱散提示 团队框架高亮（✓）
					category = "BossMod",
					spellID = 464056,
					enable_tag = "role",
					ficon = "2",
					name = string.format(L["NAME驱散提示"], T.GetSpellIcon(464056)),
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ADDON_MSG"] = true,
					},
					init = function(frame)
						frame.spellID = 464056
					end,
					update = function(frame, event, ...)
						if event == "ADDON_MSG" then
							local channel, sender, GUID, message = ...
							if message == "DispelMe" then
								local info = T.GetGroupInfobyGUID(GUID)
								if info then
									if AuraUtil.FindAuraBySpellID(frame.spellID, info.unit, G.TestMod and "HELPFUL" or "HARMFUL") then
										T.GlowRaidFramebyUnit_Show("proc", "bm"..frame.config_id, info.unit, {.1, 1, 1})
										T.msg(string.format(L["驱散讯息有光环"], info.format_name, T.GetIconLink(frame.spellID)))
									else
										T.msg(string.format(L["驱散讯息无光环"], info.format_name, T.GetIconLink(frame.spellID)))
									end
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_REMOVED" and spellID == frame.spellID then
								local unit_id = T.GetGroupInfobyGUID(destGUID)["unit"]
								T.GlowRaidFramebyUnit_Hide("proc", "bm464056", unit_id)
							end
						end
					end,
					reset = function(frame, event)
						T.GlowRaidFrame_HideAll("proc", "bm464056")
					end,
				},
				{ -- 吸收盾 崇拜者的保护
					category = "BossMod",
					spellID = 448488,
					enable_tag = "none",
					name = string.format(L["NAME吸收盾"], T.GetIconLink(448488)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					init = function(frame)
						frame.spell_id = 448488 -- 崇拜者的保护
						frame.time_limit = 80

						function frame:GetBossUnit(unit)
							for i = 1, 5 do
								local boss_unit = "boss"..i
								if UnitIsUnit(unit, boss_unit) then
									return boss_unit
								end
							end
						end
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							if unit and not frame.unit then
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID == "223318" then
									frame.unit = frame:GetBossUnit(unit)
									frame.GUID = GUID
									if AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, "HELPFUL") then
										local value = select(16, AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, "HELPFUL"))
										frame.absorb = value
										frame.absorb_max = value		
										frame.update_absorb(true)
										
										if frame.exp_time then
											frame.time_limit = frame.exp_time - GetTime()
										else
											frame.time_limit = nil  
										end
										frame.update_time()
									end
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_AURA_REMOVED" and spellID == frame.spell_id and destGUID == frame.GUID then
								frame.stop_bar()
							elseif subEvent == "SPELL_CAST_START" and spellID == 448458 then
								frame.exp_time = GetTime() + 80
							end
						elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
							local unit = ...
							if unit and frame.unit and unit == frame.unit then
								local GUID = UnitGUID(unit)
								if GUID == frame.GUID and AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, "HELPFUL") then
									local value = select(16, AuraUtil.FindAuraBySpellID(frame.spell_id, frame.unit, "HELPFUL"))
									frame.absorb = value
									frame.update_absorb()
								end
							end	
						elseif event == "ENCOUNTER_START" then
							frame.absorb = 0
							frame.absorb_max = 0
							frame.unit = nil
						end
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)
					end,
				},				
			},
		},
		{ -- 内室卫士
			npcs = {
				{29642},
			},
			options = {
				{ -- 对我施法图标 发配（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 448147,
					hl = "yel_flash",
					sound = "[knockback]",
				},
			},
		},
		{ -- 内室驱逐者
			npcs = {
				{29744},
			},
			options = {
				{ -- 文字 引射线 倒计时
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 1},
					preview = L["引射线"].."/"..L["观察射线"]..L["倒计时"],
					data = {
						spellID = 451600,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_AURA_APPLIED" and spellID == 462693 then -- 回响联结
								local unit = UnitTokenFromGUID(destGUID)
								if unit then
									self.text:SetTextColor(1, 1, 1)
									T.Start_Text_DelayTimer(self, 5, L["引射线"], true)
								end
							elseif subEvent == "SPELL_AURA_REMOVED" and spellID == 462693 then -- 回响联结
								local unit = UnitTokenFromGUID(destGUID)
								if unit then
									T.Stop_Text_Timer(self)
								end
							elseif subEvent == "SPELL_CAST_START" and spellID == 451600 then -- 斥逐光束
								local unit = UnitTokenFromGUID(sourceGUID)
								if unit then
									self.text:SetTextColor(.64, .76, 1)
									T.Start_Text_DelayTimer(self, 3, L["观察射线"], true)
								end	
							elseif subEvent == "SPELL_CAST_SUCCESS" and spellID == 451600 then -- 斥逐光束
								local unit = UnitTokenFromGUID(sourceGUID)
								if unit then
									self.text:SetTextColor(1, 1, 1)
									T.Start_Text_DelayTimer(self, 6, L["引射线"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 斥逐光束（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 451600,
					color = {.64, .76, 1},
					text = L["射线"],
					sound = "[ray]",
				},
			},
		},
		{ -- 内室助祭
			npcs = {
				{29945, "12"},
			},
			options = {
				{ -- 首领模块 标记 内室助祭
					category = "BossMod",
					spellID = 455374,
					enable_tag = "spell",
					name = string.format(L["NAME焦点自动标记"], T.GetFomattedNameFromNpcID("226200")),
					points = {hide = true},
					events = {
						["PLAYER_FOCUS_CHANGED"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					custom = {
						{
							key = "mark_dd",
							text = L["标记"],
							default = 5,
							key_table = {
								{5, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t"},
								{6, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t"},
							},
						},
					},
					init = function(frame)
						frame.mob_npcID = "226200"
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
					end,
					update = function(frame, event, ...)
						if event == "PLAYER_FOCUS_CHANGED" then
							local GUID = UnitGUID("focus")
							if GUID then
								local npcID = select(6, strsplit("-", GUID))
								if npcID == frame.mob_npcID then
									local old_mark = GetRaidTargetIndex("focus") or 9
									local mark = C.DB["BossMod"][frame.config_id]["mark_dd"]
									
									if old_mark ~= mark then
										T.SetRaidTarget("focus", mark)
									end
									
									T.msg(string.format(L["已标记%s"], date("%H:%M:%S"), T.GetNameFromNpcID(npcID), T.FormatRaidMark(mark)))
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 2.2 then
								T.Start_Text_Timer(frame.text_frame, 3, L["设置焦点"])
								T.PlaySound("setfocus")
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 姓名板打断图标 黑暗爆破（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 455374,
					mobID = "226200",
					interrupt = 2,
					ficon = "6",
					mrt_info = {"5,6", true},
				},
			},
		},
		{ -- 腐蚀掠行者
			npcs = {
				{29985},
			},
			options = {
				{ -- 图标 腐蚀锐牙（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 449236,
					hl = "",
					tip = L["易伤"].."%s2%",
					ficon = "0",
				},
			},
		},
		{ -- 深渊倾注
			spells = {
				{443888, "5"},
			},
			options = {
				{ -- 计时条 深渊倾注（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 443888,
					color = {.12, .87, .93},
					ficon = "5",
				},
				{ -- 图标 深渊倾注（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443903,
					hl = "org_flash",
				},
				{ -- 图标 深渊回响（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 455387,
					hl = "red_flash",
					text = L["炸弹"],
				},
				{ -- 首领模块 计时圆圈 深渊回响（✓）
					category = "BossMod",
					spellID = 455387,
					enable_tag = "none",
					name = T.GetIconLink(455387)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[455387] = { -- 深渊回响
								unit = "player",
								aura_type = "HARMFUL",
								color = {.73, .73, 1},
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
				{ -- 首领模块 深渊倾注 点名统计 整体排序（✓）
					category = "BossMod",
					spellID = 443903,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(443903)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 230},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "tag_dd",
							text = L["团队框架符号"],
							default = "number",
							key_table = {
								{"number", "1,2"},
								{"raidmark", T.FormatRaidMark("7")..","..T.FormatRaidMark("4")},
								{"pos", L["近战"]..","..L["远程"]},
								{"none", L["无"]},
							},
						},
					},
					init = function(frame)
						frame.aura_id = 443903
						frame.element_type = "bar"
						frame.color = {.12, .87, .93}
						frame.raid_glow = "pixel"
						frame.support_spells = 3
						
						frame.tag_info = {
							number = {1, 2},
							raidmark = {T.FormatRaidMark("7"),T.FormatRaidMark("4")},
							pos = {L["近战"],L["远程"]},
						}
						
						frame.info = {
							{text = T.FormatRaidMark("7"), msg_applied = "{rt7}%name", msg = "{rt7}", sound = "[mark\\7]"},
							{text = T.FormatRaidMark("4"), msg_applied = "{rt4}%name", msg = "{rt4}", sound = "[mark\\4]"},
						}						
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:post_display(element, index, unit, GUID)
							local tag_type = C.DB["BossMod"][self.config_id]["tag_dd"]
							
							if tag_type ~= "none" then
								local tag = self.tag_info[tag_type][index]
								T.CreateRFIndex(GUID, tag)
							end
							
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 6, self.info[index]["text"], true)
							end						
						end
						
						function frame:post_remove(element, index, unit, GUID)
							local tag_type = C.DB["BossMod"][self.config_id]["tag_dd"]
							
							if tag_type ~= "none" then
								local unit_frame = T.GetUnitFrame(unit)
								if unit_frame then	
									T.HideRFIndexbyParent(unit_frame)
								end
							end
							
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
						T.HideAllRFIndex()
						T.ResetAuraMods_ByMrt(frame)	
					end,
				},			
			},
		},
		{ -- 吐沫的饕餮者
			spells = {
				{445422, "4"},
			},
			options = {
				{ -- 文字 吐沫的饕餮者 倒计时（?）
					category = "TextAlert",
					type = "spell",
					color = {.23, 1, .36},
					preview = L["穿环"]..L["倒计时"],
					data = {
						spellID = 445422,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_CAST_SUCCESS" and spellID == 445422 then -- 吐沫的饕餮者
								self.count = self.count + 1
								self.last_start = GetTime()
								
								if self.count == 1 then
									T.Start_Text_Timer(self, 4, L["穿环"], true)
								elseif AuraUtil.FindAuraBySpellID(445152, "player", "HARMFUL") then
									T.Start_Text_Timer(self, 6, L["穿环"], true)
								else
									local dur = (self.pos == "MELEE") and 4.5 or 5.5
									T.Start_Text_Timer(self, dur, L["穿环"], true)
								end
							elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 445152 and destGUID == G.PlayerGUID then -- 侍僧精华
								if self.count ~= 1 and self:IsShown() and self.last_start then
									local dur = self.last_start + 6 - GetTime()
									T.Start_Text_Timer(self, dur, L["穿环"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.pos = T.GetGroupInfobyGUID(G.PlayerGUID)["pos"]
							self.count = 0
							self.count_down_start = 5
						end
					end,
				},
				{ -- 计时条 吐沫的饕餮者（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 445422,
					color = {.59, .01, 1},
					ficon = "4",
					text = L["圆环"].."+"..L["拉人"],
				},
				{ -- 图标 暴食之丝（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 445623,
					hl = "yel",
					tip = L["拉人"],
				},
			},
		},
		{ -- 女王的应诏者
			npcs = {
				{29765},
			},
			options = {
				{ -- 计时条 女王的应诏者（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 444829,
					color = {.93, .98, 1},
					text = L["召唤小怪"].."+"..L["全团AE"],
					sound = "[add]cast",
				},
				{ -- 图标 侍僧精华（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 445152,
					hl = "org_flash",
					sound = soundfile("445152aura"),
					msg = {str_cd = "%durs", cd = 5, channel = "YELL"},
				},
				{ -- 图标 精华创裂（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 446012,
					hl = "",
					tip = L["不能吃球"],
				},
				{ -- 首领模块 侍僧精华 多人光环（✓）
					category = "BossMod",
					spellID = 444829,
					enable_tag = "rl",
					ficon = "3,12",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(445152)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -480},
					events = {
						["UNIT_AURA"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.bar_num = 3
						frame.orb_num = 0
						
						frame.text = T.createtext(frame, "OVERLAY", 25, "OUTLINE", "LEFT")
						frame.text:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 5)
						frame.text:Hide()
						
						function frame:update_text()
							self.text:SetText(string.format(L["精华数量"], self.orb_num))
						end
						
						frame.spellIDs = {
							[445152] = { -- 侍僧精华
								color = {.93, .98, 1},
								hl_raid = "pixel",
							},
						}
						
						T.InitUnitAuraBars(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID ==  444829 then -- 女王的应诏者
								frame:update_text()		
								frame.text:Show()
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 445152 then -- 侍僧精华 DOT
								frame.orb_num = frame.orb_num - 1
								frame:update_text()
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 445152 and frame.difficultyID == 16 then -- 侍僧精华 DOT
								frame.orb_num = frame.orb_num + 1
								frame:update_text()
							elseif sub_event == "UNIT_DIED" then
								local npcID = select(6, string.split("-", destGUID))
								if npcID == "221863" then
									frame.orb_num = frame.orb_num + 1
									frame:update_text()
								end	
							end
						elseif event == "ENCOUNTER_START" then
							frame.text:Hide()
							frame.orb_num = 0
							frame.difficultyID = select(3, ...)
						end
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
				{ -- 首领模块 侍僧精华 技能轮次安排（?）
					category = "BossMod",
					spellID = 445152,
					enable_tag = "everyone",
					ficon = "3,12",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(445152)),	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn", 
							text = L["粘贴MRT模板"],
						}
					},
					init = function(frame)
						frame.spell = C_Spell.GetSpellName(frame.config_id)
						frame.tag = string.format("#%s", frame.spell)
						frame.spell_count = 1
						
						frame.info = {}						
						frame.dur = {48, 80, 88}
						frame.wm_info = {
							{"{rt5}", "{rt1}", "{rt6}"},
							{"{rt6}", "{rt2}", "{rt8}", "{rt3}", "{rt6}"..L["附近"]},
							{"{rt2}", "{rt8}", "{rt3}", "{rt5}", "{rt8}"..L["附近"]},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.text_frame.show_time = 10
						frame.text_frame.count_down_start = 10
						frame.text_frame.mute_count_down = true
						
						function frame:copy_mrt()
							local str = ""
							local name = T.ColorNameForMrt(G.PlayerName)
							
							for index, info in pairs(frame.wm_info) do
								for i, tag in pairs(info) do
									if string.find(tag, L["附近"]) then
										if index == 2 then
											str = str..frame.tag..index..tag..string.rep(name, 3).."\n"
										else
											str = str..frame.tag..index..tag..string.rep(name, 7).."\n"
										end
									else
										str = str..frame.tag..index..tag..name.."\n"
									end
								end
								if index < 3 then
									str = str.."\n"
								end
							end
							
							return str
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.info = table.wipe(frame.info)
							local text = C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note and _G.VExRT.Note.Text1
        
							if text then
								for line in text:gmatch('[^\r\n]+') do
									if string.match(line, frame.tag.."(%d)") then
										local index = string.match(line, frame.tag.."(%d)")
										local mark = string.match(line, "({rt%d})")
										local tag = string.match(line, "}([^|]+)") or ""
										
										index = tonumber(index)
										
										for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
											local info = T.GetGroupInfobyName(name)
											if info and info.GUID == G.PlayerGUID then
												frame.info[index] = mark..tag
											end
										end
									end
								end
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_CAST_SUCCESS" and spellID == 449986 then -- 溟光沟通
								frame.spell_count = 1
								if frame.info[frame.spell_count] and frame.dur[frame.spell_count] then
									local mark_index = string.match(frame.info[frame.spell_count], "{rt(%d)}")
									local str = string.format(L["捡精华"], gsub(frame.info[frame.spell_count], "{rt%d}", T.FormatRaidMark(mark_index)))
									local dur = frame.dur[frame.spell_count]
									
									frame.text_frame.prepare_sound = "mark\\mark"..mark_index
									
									T.Start_Text_DelayTimer(frame.text_frame, dur, str, true)
								end
							elseif subEvent == "SPELL_CAST_START" and spellID == 445422 then -- 吐沫的饕餮者
								frame.spell_count = frame.spell_count + 1
								
								if frame.info[frame.spell_count] and frame.dur[frame.spell_count] then
									local mark_index = string.match(frame.info[frame.spell_count], "{rt(%d)}")
									local str = string.format(L["捡精华"], gsub(frame.info[frame.spell_count], "{rt%d}", T.FormatRaidMark(mark_index)))
									local dur = frame.dur[frame.spell_count]
									
									frame.text_frame.prepare_sound = "mark\\mark"..mark_index
									
									T.Start_Text_DelayTimer(frame.text_frame, dur, str, true)
								end
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 首领模块 虚无爆破 焦点施法（?）
					category = "BossMod",
					spellID = 445021,
					enable_tag = "everyone",
					ficon = "3,12",
					name = L["焦点施法条和吸收盾"],	
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 100},
					events = {
						["PLAYER_FOCUS_CHANGED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = true,
						["UNIT_SPELLCAST_INTERRUPTIBLE"] = true,
						["UNIT_ABSORB_AMOUNT_CHANGED"] = true,
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
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 50,
							min = 30,
							max = 70,
							apply = function(value, alert)
								alert:SetHeight(value)
							end
						},
						{
							key = "interrupt_sl",
							text = L["我的打断序号"],
							default = 1,
							min = 1,
							max = 3,
						},
					},
					init = function(frame)
						frame.bar = T.CreateTimerBar(frame, 425958, false, true, true, nil, nil, {1, 1, 1})
						frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
						frame.bar:SetPoint("BOTTOMRIGHT", frame, "RIGHT", 0, 1)
						
						frame.bar2 = T.CreateTimerBar(frame, 132886, false, false, true, nil, nil, {.69, .49, .91})
						frame.bar2:SetPoint("TOPLEFT", frame, "LEFT", 0, -1)
						frame.bar2:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
						frame.bar2.left:SetText(L["吸收盾"])
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:UpdateAbsorb(update_max)
							if AuraUtil.FindAuraBySpellID(445013, "focus", "HELPFUL") then
								local value = select(16, AuraUtil.FindAuraBySpellID(445013, "focus", "HELPFUL"))
								
								if update_max then
									frame.bar2:SetMinMaxValues(0, value)
									frame.bar2:Show()
								end
								
								frame.bar2:SetValue(value)
								frame.bar2.right:SetText(T.ShortValue(value))
							else
								frame.bar2:Hide()
							end
						end
						
						function frame:InitBar(GUID)
							self.focus_GUID = GUID
							self.cast_index = 0
							
							self:UpdateAbsorb(true)
						end
						
						function frame:UpdateInterruptable(Interruptible)
							if Interruptible then
								if self.cast_index == 3 then
									self.cast_index = 1
								else
									self.cast_index = self.cast_index + 1
								end
								
								if self.cast_index == C.DB["BossMod"][self.config_id]["interrupt_sl"] then
									T.PlaySound("interrupt")
								end
								
								self.bar.mid:SetText(string.format("[%d]", self.cast_index))
								self.bar:SetStatusBarColor(0, 1, 0)
							else
								self.bar.mid:SetText("")
								self.bar:SetStatusBarColor(1, .3, .1)
							end
						end
						
						function frame:UpdateCast()
							local name, _, _, startTimeMS, endTimeMS, _, _, notInterruptible = UnitCastingInfo("focus")
							
							if name then
								self.bar.dur = (endTimeMS - startTimeMS)/1000
								self.bar.exp_time = endTimeMS/1000
								
								self.bar.left:SetText(name)
								self.bar:SetMinMaxValues(0, self.bar.dur)
								
								self.bar:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > s.update_rate then		
										s.remain = s.exp_time - GetTime()
										if s.remain > 0 then										
											s.right:SetText(T.FormatTime(s.remain))
											s:SetValue(s.dur - s.remain)
										end
										s.t = 0
									end
								end)
								
								self.bar:Show()
								
								if notInterruptible then
									self:UpdateInterruptable(false)
								else
									self:UpdateInterruptable(true)
								end
							end
						end
						
						function frame:StopBar()
							self.bar:SetScript("OnUpdate", nil)
							self.bar:Hide()
							self.bar.right:SetText("")
							self.bar:SetValue(0)
						end
					
						function frame:PreviewShow()
							self.bar:Show()
							self.bar:SetMinMaxValues(0, 1)
							self.bar:SetValue(1)
							
							self.bar2:Show()
							self.bar2:SetMinMaxValues(0, 1)
							self.bar2:SetValue(1)
						end
						
						function frame:PreviewHide()
							self.bar:Hide()
							self.bar2:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "PLAYER_FOCUS_CHANGED" then
							local GUID = UnitGUID("focus")
							if GUID then
								local npcID = select(6, string.split("-", GUID))
								if npcID == "221863" then -- 应召者焦点
									if frame.focus_GUID ~= GUID then -- 非当前监控怪
										frame:InitBar(GUID)
										frame:UpdateCast()
									end
								else -- 不是应召者的焦点
									frame.focus_GUID = nil
									frame:StopBar()
								end
							else -- 无焦点
								frame.focus_GUID = nil
								frame:StopBar()
							end
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, castID, spellID = ...
							if unit == "boss1" and spellID == 444829 then
								T.Start_Text_Timer(frame.text_frame, 3, L["设置焦点"])
								T.PlaySound("setfocus")
							elseif frame.focus_GUID and unit == "focus" then
								local GUID = UnitGUID(unit)
								if GUID and GUID == frame.focus_GUID then
									frame:UpdateCast()
								end
							end
						elseif event == "UNIT_SPELLCAST_STOP" then
							local unit, castID, spellID = ...
							if frame.focus_GUID and unit == "focus" then
								local GUID = UnitGUID(unit)
								if GUID and GUID == frame.focus_GUID then
									frame:StopBar()
								end
							end
						elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
							local unit, castID, spellID = ...
							if frame.focus_GUID and unit == "focus" then
								local GUID = UnitGUID(unit)
								if GUID and GUID == frame.focus_GUID then
									frame:UpdateInterruptable(true)
								end
							end
						elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
							local unit = ...
							if unit and unit == "focus" then
								frame:UpdateAbsorb()
							end
						elseif event == "ENCOUNTER_START" then
							frame.focus_GUID = nil							
						end
					end,
					reset = function(frame, event)
						frame:StopBar()
					end,
				},
			},
		},
		{ -- 皇谕责罚
			spells = {
				{438976},
			},
			options = {
				{ -- 计时条 皇谕责罚（✓） 
					category = "AlertTimerbar",
					type = "cleu",
					spellID = 438974,
					event = "SPELL_AURA_APPLIED",
					dur = 6.2,
					color = {.8, .77, .76},
					text = L["全团AE"],
				},
				{ -- 图标 皇谕责罚（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438974,
					hl = "org_flash",
				},
				{ -- 图标 皇家镣铐（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 441865,
					hl = "yel",
					tip = L["DOT"].."+"..L["减速"],
				},
				{ -- 首领模块 皇谕责罚 点名统计 整体排序（✓）
					category = "BossMod",
					spellID = 438974,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(438974)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 180},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					init = function(frame)
						frame.aura_id = 438974
						frame.element_type = "bar"
						frame.color = {.8, .77, .76}
						frame.raid_glow = "pixel"
						frame.raid_index = true
						frame.support_spells = 3
						frame.disable_copy_mrt = true
						frame.spell_count = 1

						frame.diffculty_num = {
							[15] = 2, -- H
							[16] = 3, -- M
						}
						
						frame.info_tag = {
							{T.FormatRaidMark("2"), "{rt2}"},
							{T.FormatRaidMark("3"), "{rt3}"},
						}
						
						frame.info_pos = {
							{text = L["左上"], msg_applied = L["左上"], msg = L["左上"]},
							{text = L["右上"], msg_applied = L["右上"], msg = L["右上"]},
							{text = L["后"], msg_applied = L["后"], msg = L["后"]},
						}
						
						frame.info = {
							{sound = "[frontleft]"},
							{sound = "[frontright]"},
							{sound = "[back]"},
						}						
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 6, self.info[index]["text"], true)
							end						
						end
						
						function frame:post_remove(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Stop_Text_Timer(self.text_frame)
							end
						end
						
						function frame:update_info()
							local tag_info = self.info_tag[self.spell_count]
							if tag_info then
								for i, v in pairs(frame.info) do
									v.text = tag_info[1]..self.info_pos[i].text
									v.msg_applied = tag_info[2]..self.info_pos[i].msg_applied
									v.msg = tag_info[2]..self.info_pos[i].msg
								end
							end
						end
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 3 then
								frame.spell_count = 1
								frame:update_info()
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 438976 then -- 皇谕责罚
								frame.spell_count = frame.spell_count + 1
								frame:update_info()
							end
						end
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)	
					end,
				},
				{ -- 首领模块 计时圆圈 皇谕责罚（✓）
					category = "BossMod",
					spellID = 441865,
					enable_tag = "none",
					name = T.GetIconLink(438974)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[438974] = { -- 皇谕责罚
								event = "SPELL_AURA_APPLIED",
								target_me = true,
								dur = 6.2,
								color = {.8, .77, .76},
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
		{ -- 感染
			spells = {
				{443325, "0"},
			},
			options = {
				{ -- 计时条 感染[音效:感染]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 443325,
					color = {.87, .67, .97},
					show_tar = true,
					sound = soundfile("443325cast", "cast"),
					ficon = "0",
				},
				{ -- 计时条 感染（✓）
					category = "AlertTimerbar",
					type = "cleu",
					spellID = 443656,
					event = "SPELL_AURA_APPLIED",
					dur = 4,
					color = {.87, .67, .97},
					ficon = "1",
					text = L["召唤小怪"],
				},
				{ -- 图标 感染（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443656,
					hl = "org_flash",
					tip = L["炸弹"].."+"..L["小怪"],
				},
				
			},
		},
		{ -- 啃噬
			spells = {
				{443336, "0"},
			},
			options = {
				{ -- 文字 啃噬 倒计时（x）
					category = "TextAlert",
					type = "spell",
					color = {.61, .46, 1},
					preview = L["引水"]..L["倒计时"],
					data = {
						spellID = 443336,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							[15] = {
								[3] = {13, 66, 80},
							},
							[16] = {
								[3] = {12, 66, 80},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 443336, L["引水"], self, event, ...)
					end,
				},
				{ -- 文字 啃噬引水 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = L["引水"]..L["生效"]..L["倒计时"],
					data = {
						spellID = 443342,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, castID, spellID = ...
							if unit == "boss1" and spellID == 443336 then
								T.Start_Text_Timer(self, 2.5, L["引水"], true)
							end
						end
					end,
				},
				{ -- 计时条 啃噬[音效:啃噬]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 443336,
					color = {.61, .46, 1},
					show_tar = true,
					sound = soundfile("443336cast", "cast"),
				},
				{ -- 图标 啃噬（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 443342,
					hl = "",
					tip = L["易伤"].."%s50%",
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
					spellID = 447076, -- 掠食
				},
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 447207, -- 掠食
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU", -- 溟光沟通
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 449986,
				},
			},
		},
	},
}