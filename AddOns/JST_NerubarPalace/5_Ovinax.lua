local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["准备炸蛋"] = "准备炸蛋"
	L["治疗坦克"] = "治疗坦克"
else
	L["准备炸蛋"] = "hatch eggs soon"
	L["治疗坦克"] = "Heal Tank"
end

---------------------------------Notes--------------------------------
-- 以摄食黑血读条开始为锚点划分阶段，技能时间轴固定

-- 紫圈 红箭头 试验性剂量 Private Aura 4 - Default 8 - Mythic
-- 白圈 粘性之网 光环 4 - Mythic 3 - Heroic 2 - Default

-- TO DO:蛋示意图更新

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2612] = {
	engage_id = 2919,
	npc_id = {"214506"},
	alerts = {
		{ -- 试验性剂量
			spells = {
				{442526, "5"},
			},
			options = {
				{ -- 文字 试验性剂量 倒计时[音效:准备炸蛋]（✓）
					category = "TextAlert",
					type = "spell",
					color = {.73, .3, .94},
					preview = L["准备炸蛋"]..L["倒计时"],
					data = {
						spellID = 442526,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							["all"] = {
								[2] = {16, 50, 50},
								[3] = {16, 50, 50},
								[4] = {16, 50, 50},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "1273\\442526cast",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 442526, L["准备炸蛋"], self, event, ...)
					end,
				},
				{ -- 计时条 试验性剂量（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 442526,
					color = {.73, .3, .94},
				},
				{ -- 计时条 试验性剂量 生效（✓） 
					category = "AlertTimerbar",
					type = "cleu",
					spellID = 442526,
					event = "SPELL_CAST_SUCCESS",
					dur = 8,
					color = {.73, .3, .94},
					text = L["小怪出现"],
				},
				{ -- 图标 试验性剂量（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 440421,
					hl = "org_flash",
					sound = "[bombonyou]",
				},
				{ -- 光环统计 试验性剂量（✓）
					category = "BossMod", 
					spellID = 440421,
					name = string.format(L["NAME点名排序"], T.GetIconLink(440421)),
					enable_tag = "everyone",
					ficon = "3,12",
					points = {a1 = "TOPLEFT", a2 = "LEFT", x = 400, y = 180},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					custom = {
						{
							key = "show_name_dd",
							text = L["显示名字方式"],
							default = "mine",
							key_table = {
								{"none", L["不显示"]},
								{"mine", L["只显示我的名字"]},
								{"all", L["全部显示"]},
							},
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
							default = 2,
							key_table = {
								{2, "P1"},
								{3, "P2"},
								{4, "P3"},
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
								{0, "1"},
								{1, "2"},
								{2, "3"},
							},
							apply = function(value, frame)
								frame:UpdatePreviewInfo()
							end,
						},					
					},
					init = function(frame)
						frame.aura_id = 440421
						frame.element_type = "circle"
						frame.color = {.73, .3, .94}
						frame.frame_width = 400
						frame.frame_height = 180
						frame.cast_spellID = 442526
						frame.phase = 2
						frame.mrt_copy_custom = true
						
						frame.diffculty_num = {
							[15] = 4, -- H
							[16] = 8, -- M
						}
						
						frame.egg_data_h = {
							{ -- 大蛋区
								{index = 1, eggType = "大", x = 180, y = -20}, -- 2
								{index = 1, eggType = "中", x = 260, y = -20}, -- 3
								{index = 1, eggType = "大", x = 220, y = -60}, -- 6
								{index = 1, eggType = "大", x = 330, y = -60}, -- 7
								
								{index = 2, eggType = "中", x = 100, y = -20}, -- 1
								{index = 2, eggType = "小", x = 80, y = -90}, -- 8
								{index = 2, eggType = "大", x = 140, y = -60}, -- 5
								{index = 2, eggType = "大", x = 30, y = -60}, -- 4
								
								{index = 3, eggType = "中", x = 220, y = -110}, -- 10
								{index = 3, eggType = "小", x = 280, y = -90}, -- 11
								{index = 3, eggType = "大", x = 140, y = -110}, -- 9
							},
							{ -- 中蛋区	
								{index = 1, eggType = "中", x = 180, y = -20}, -- 2
								{index = 1, eggType = "小", x = 140, y = -60}, -- 5
								{index = 1, eggType = "中", x = 100, y = -20}, -- 1
								{index = 1, eggType = "中", x = 30, y = -60}, -- 4

								{index = 2, eggType = "中", x = 260, y = -20}, -- 3
								{index = 2, eggType = "小", x = 220, y = -60}, -- 6
								{index = 2, eggType = "大", x = 280, y = -90}, -- 11								
								{index = 2, eggType = "中", x = 330, y = -60}, -- 7	

								{index = 3, eggType = "中", x = 140, y = -110}, -- 9								
								{index = 3, eggType = "大", x = 80, y = -90}, -- 8
								{index = 3, eggType = "小", x = 220, y = -110}, -- 10

							},
							{ -- 小蛋区
								{index = 1, eggType = "小", x = 180, y = -20}, -- 2
								{index = 1, eggType = "小", x = 140, y = -60}, -- 5
								{index = 1, eggType = "大", x = 100, y = -20}, -- 1
								{index = 1, eggType = "小", x = 30, y = -60}, -- 4
								
								{index = 2, eggType = "大", x = 260, y = -20}, -- 3
								{index = 2, eggType = "小", x = 220, y = -60}, -- 6
								{index = 2, eggType = "小", x = 280, y = -90}, -- 11
								{index = 2, eggType = "中", x = 330, y = -60}, -- 7
								
								{index = 3, eggType = "小", x = 140, y = -110}, -- 9
								{index = 3, eggType = "中", x = 80, y = -90}, -- 8
								{index = 3, eggType = "大", x = 220, y = -110}, -- 10
							},
						}
						
						frame.egg_data_m = {
							{ -- 小蛋区
								{index = 1, eggType = "大小", x = 105, y = -30}, -- 2
								{index = 1, eggType = "大中", x = 180, y = -65}, -- 3
								{index = 1, eggType = "小", x = 185, y = -20}, -- 1
								{index = 1, eggType = "中小", x = 25, y = -60}, -- 6
								
								{index = 2, eggType = "中小", x = 265, y = -30}, -- 4	
								{index = 2, eggType = "大中", x = 340, y = -65}, -- 11
								{index = 2, eggType = "小", x = 330, y = -25}, -- 5
								{index = 2, eggType = "大小", x = 270, y = -85}, -- 10
								
								{index = 3, eggType = "小", x = 170, y = -100}, -- 8
								{index = 3, eggType = "小", x = 200, y = -140}, -- 12
								{index = 3, eggType = "中", x = 225, y = -95}, -- 9
								{index = 3, eggType = "大", x = 100, y = -85}, -- 7							
							},                     
							{ -- 大蛋区
								{index = 1, eggType = "大小", x = 105, y = -25}, -- 2
								{index = 1, eggType = "大中", x = 175, y = -65}, -- 3
								{index = 1, eggType = "大", x = 185, y = -20}, -- 1
								{index = 1, eggType = "中小", x = 25, y = -60}, -- 5
								                     
								{index = 2, eggType = "中小", x = 275, y = -30}, -- 4
								{index = 2, eggType = "大中", x = 320, y = -45}, -- 11
								{index = 2, eggType = "中", x = 350, y = -75}, -- 10
								{index = 2, eggType = "大小", x = 270, y = -95}, -- 9
								
								{index = 3, eggType = "大", x = 240, y = -140}, -- 12
								{index = 3, eggType = "大", x = 225, y = -95}, -- 8
								{index = 3, eggType = "小", x = 170, y = -105}, -- 7
								{index = 3, eggType = "大", x = 100, y = -85}, -- 6			
							},                     
							{ -- 中蛋区
								
								{index = 1, eggType = "中", x = 185, y = -20}, -- 1
								{index = 1, eggType = "大中", x = 105, y = -10}, -- 2
								{index = 1, eggType = "大小", x = 170, y = -60}, -- 3
								{index = 1, eggType = "中小", x = 35, y = -50}, -- 5
								
								{index = 2, eggType = "中小", x = 265, y = -30}, -- 4
								{index = 2, eggType = "大中", x = 300, y = -65}, -- 10
								{index = 2, eggType = "小", x = 340, y = -45}, -- 11
								{index = 2, eggType = "大小", x = 260, y = -90}, -- 9
								
								{index = 3, eggType = "大", x = 160, y = -100}, -- 7
								{index = 3, eggType = "中", x = 190, y = -140}, -- 12
								{index = 3, eggType = "中", x = 215, y = -95}, -- 8
								{index = 3, eggType = "中", x = 95, y = -85}, -- 6								
							},
						}
						
						frame.graph_tex_info = {}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						frame.updater = CreateFrame("Frame", nil, frame)
						frame.updater.t = 0
						
						function frame:InitByDifficulty()
							for index = 1, 8 do
								local element = self.elements[index]
								
								element:SetSize(15, 15)
								element.text:SetSize(40, 20)
								element.text:SetText("")
								
								if self.difficultyID == 16 then
									local egg_ind = ceil(index/2)
									
									element:Show()
									
									element.text:ClearAllPoints()
									if mod(index, 2) == 1 then
										element.text:SetPoint("RIGHT", element, "RIGHT")
									else
										element.text:SetPoint("LEFT", element, "LEFT")
									end
									
									self.info[index].egg_ind = egg_ind
									self.info[index].sound = string.format("[mark\\mark%d]", egg_ind) -- 光柱
									self.info[index].msg_applied = string.format("{rt%d}", egg_ind).." %name" -- 光柱
									self.info[index].msg = string.format("{rt%d}", egg_ind)	 -- 光柱
								else
									if index <= 4 then
										element:Show()
									else
										element:Hide()
									end
									
									element.text:SetPoint("CENTER", element, "CENTER")
									
									self.info[index].egg_ind = index	
									self.info[index].sound = string.format("[mark\\mark"..index.."]") -- 光柱
									self.info[index].msg_applied = string.format("{rt%d}", index).." %name" -- 光柱
									self.info[index].msg = string.format("{rt%d}", index) -- 光柱
								end
							end
						end
						
						function frame:UpdateGraghs()							
							for name, info in pairs(self.graph_tex_info) do
								if string.match(name, "egg(%d+)") then
									self.graph_tex_info[name] = nil
								end
							end
							
							local tag = (self.difficultyID == 16 and "egg_data_m") or "egg_data_h"
							
							for i, info in pairs(self[tag][self.phase-1]) do
								if not self.graph_tex_info["egg"..i] then
									self.graph_tex_info["egg"..i] = {layer = "BACKGROUND", points = {"TOPLEFT"}}
								end
								
								self.graph_tex_info["egg"..i].tag = info.eggType -- 蛋上文字
								self.graph_tex_info["egg"..i].rm = mod(i-1,4)+1
								self.graph_tex_info["egg"..i].tex = G.media.ring
								self.graph_tex_info["egg"..i].points[2] = info.x
								self.graph_tex_info["egg"..i].points[3] = info.y
							end
							
							T.UpdateGraphTextures(self, self.graph_bg)
						end
						
						function frame:PointForEgg(index)
							local tag = (self.difficultyID == 16 and "egg_data_m") or "egg_data_h"
							for i, info in pairs(self[tag][self.phase-1]) do
								if info.index == index + 1 then
									self.graphs["egg"..i].tagtext:Show()
									self.graphs["egg"..i].rm_tex:Show()
									self.graphs["egg"..i].tex:SetVertexColor(0, 1, 0)
								else
									self.graphs["egg"..i].tagtext:Hide()
									self.graphs["egg"..i].rm_tex:Hide()
									self.graphs["egg"..i].tex:SetVertexColor(.7, .7, .7)
								end
							end
							
							if self.difficultyID == 16 then
								for i = 1, 8 do							
									self.elements[i]:ClearAllPoints()
									self.elements[i]:SetPoint("CENTER", self.graphs["egg"..index*4+ceil(i/2)], "CENTER", mod(i, 2) == 1 and -15 or 15, 0)
								end
							else
								for i = 1, 4 do
									self.elements[i]:ClearAllPoints()
									if self.graphs["egg"..index*4+i] then	
										self.elements[i]:SetPoint("CENTER", self.graphs["egg"..index*4+i], "BOTTOM", 0, 0)
									end
								end
							end
						end
						
						function frame:UpdateForNext()
							local index = mod(self.spell_count, 3)
							--print("UpdateForNext", self.spell_count, (index == 0) and 11 or 45)
							self.updater.exp_time = GetTime() + ((index == 0) and 6 or 40)
							self.updater:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > .2 then
									if s.exp_time - GetTime() < 0 then
										s:SetScript("OnUpdate", nil)
										self:PointForEgg(index)		
										self.graph_bg:Show()
										self.spell_count = self.spell_count + 1
									end
								end
							end)
						end
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 8, string.rep(T.FormatRaidMark(self.info[index]["egg_ind"]), 3), true)  -- 文字
								T.ProcGlow_Start(element, {key = "bossmod"..frame.config_id})
							end
							
							if C.DB["BossMod"][self.config_id]["show_name_dd"] == "none" then
								element.text:SetText("")
							elseif C.DB["BossMod"][self.config_id]["show_name_dd"] == "mine" and GUID ~= G.PlayerGUID then
								element.text:SetText("")
							end
						end
						
						function frame:post_remove(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Stop_Text_Timer(self.text_frame)
								T.ProcGlow_Stop(element, "bossmod"..frame.config_id)
							end
							element.text:SetText("")
						end
						
						frame.info = {}
						
						for i = 1, 8 do
							table.insert(frame.info, {sound = "", msg_applied = "", x = 0, y = 0})
						end

						T.InitAuraMods_ByMrt(frame)
						
						function frame:UpdatePreviewInfo()
							if not InCombatLockdown() then
								frame.difficultyID = C.DB["BossMod"][self.config_id]["preview_diff_dd"]
								frame.phase = C.DB["BossMod"][self.config_id]["preview_phase_dd"]
								frame:InitByDifficulty()
								frame:UpdateGraghs()
								frame:PointForEgg(C.DB["BossMod"][self.config_id]["preview_index_dd"])
							end
						end
						
						function frame:PreviewShow()
							self:UpdatePreviewInfo()
							self.graph_bg:Show()
						end
					end,
					update = function(frame, event, ...)
						if event == "ENCOUNTER_START" then
							frame.difficultyID = select(3, ...)
							frame:InitByDifficulty()
						elseif event == "ENCOUNTER_PHASE" then		
							frame.phase = ...
							frame.spell_count = 0
							frame:UpdateGraghs()
							frame:UpdateForNext()
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if (G.TestMod and unit == "player" or string.find(unit, "boss")) and spellID == frame.cast_spellID then	
								if mod(frame.spell_count, 3) ~= 0 then
									frame:UpdateForNext()
								end
							end
						end
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
						frame.updater:SetScript("OnUpdate", nil)
					end,
				},
				{ -- 试验性剂量 计时圆圈（✓）
					category = "BossMod",
					spellID = 442526,
					enable_tag = "none",
					name = T.GetIconLink(440421)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[440421] = { -- 试验性剂量
								unit = "player",
								aura_type = "HARMFUL",
								color = {.88, .32, .94},
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
				{ -- 图标 试验性剂量（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 442660,
					effect = 3,
					hl = "gre",
					tip = L["吸收治疗"],
				},
			},
		},
		{ -- 巨型蜘蛛
			npcs = {
				{30241},
				{28996},
			},
			options = {
				{ -- 首领模块 小怪血量 巨型蜘蛛 暴食蠕虫（✓）
					category = "BossMod",
					spellID = 446694,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量"], T.GetFomattedNameFromNpcID("219045").." "..T.GetFomattedNameFromNpcID("219046")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 20, y = -300},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
						["UNIT_TARGET"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["219045"] = {color = {.65, .77, 1}}, -- 巨型蜘蛛
							["219046"] = {color = {.48, .44, .61}}, -- 暴食蠕虫
						}
						
						frame.auras = {
							[446694] = { -- 变异：死疽
								aura_type = "HELPFUL",
								color = {1, 0, 0},
							},
							[446694] = { -- 恶毒之咬
								aura_type = "HELPFUL",
							},
							[446690] = { -- 变异：暴食
								aura_type = "HELPFUL",
								color = {1, 0, 0},
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
				{ -- 图标 死疽伤口（?）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 458212,
					hl = "red",
					tip = L["致死"],
					ficon = "0",
				},
			},
		},
		{ -- 暴食蠕虫
			npcs = {
				{30242},
				{28999},
			},
			options = {
				{ -- 首领模块 标记 暴食蠕虫（✓）
					category = "BossMod",
					spellID = 446700,
					enable_tag = "spell",
					name = string.format(L["NAME焦点自动标记"], T.GetFomattedNameFromNpcID("219046")),
					points = {hide = true},
					events = {
						["PLAYER_FOCUS_CHANGED"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "mark_dd",
							text = L["标记"],
							default = 5,
							key_table = {
								{5, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t"},
								{6, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t"},
								{7, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t"},
							},
						},
					},
					init = function(frame)
						frame.mob_npcID = "219046"
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
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, subEvent, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if subEvent == "SPELL_CAST_SUCCESS" and spellID == 442526 then
								C_Timer.After(4, function()
									T.Start_Text_Timer(frame.text_frame, 3, L["设置焦点"])  -- 文字
									T.PlaySound("setfocus")
								end)
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 姓名板打断图标 毒药爆发（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 446700,
					mobID = "219046",
					interrupt = 3,
					ficon = "6",
					mrt_info = {"5,6,7", true},
				},
			},
		},
		{ -- 鲜血寄生虫
			npcs = {
				{30243},
				{29003},
			},
			options = {
				{ -- 图标 锁定（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 442250,
					hl = "red",
				},
				{ -- 姓名板法术来源图标（✓）
					category = "PlateAlert",
					type = "PlayerAuraSource",
					aura_type = "HARMFUL",
					spellID = 442250,
					hl_np = true,
				},
				{ -- 图标 感染[音效:你被感染]（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 442257,
					hl = "red_flash",
					sound = soundfile("442257aura"),
				},
				{ -- 首领模块 感染 多人光环（✓）
					category = "BossMod",
					spellID = 442257,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(442257)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 2
						
						frame.spellIDs = {
							[442257] = { -- 感染
								color = {.74, .71, .93},
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
		{ -- 摄食黑血
			spells = {
				{442430},
			},
			options = {
				{ -- 文字提示 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "214506",
						ranges = {
							{ ul = 99, ll = 95, tip = L["阶段转换"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 首领模块 分段计时条 摄食黑血（✓）
					category = "BossMod",
					spellID = 442432,
					name = string.format(L["计时条%s"], T.GetIconLink(442432)),
					enable_tag = "none",
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 360},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)					
						frame.spell_info = {
							["SPELL_CAST_START"] = {
								[442432] = {
									dur = 16,
									color = {.56, .54, .7},
									sound = "phase",
									divide_info = {
										dur = {1, 6, 11, 16},
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
				{ -- 图标 摄食黑血（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 442437,
					effect = 2,
					hl = "",
					tip = L["吸收治疗"],
				},
				{ -- 首领模块 团队吸收量计时条（✓）
					category = "BossMod",
					spellID = 442437,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环数值提示"], L["吸收治疗"]),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -450},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.bar_num = 8
						
						frame.spellIDs = {
							[442437] = { -- 摄食黑血 147w
								aura_type = "HARMFUL",
								color = {.46, .12, .46},
								effect = 2,
								progress_value = 3000000,
							},
							[442660] = { -- 试验性剂量 294w
								aura_type = "HARMFUL",
								color = {.46, .12, .46},
								effect = 3,
								progress_value = 3000000,
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
		{ -- 腥红溢流
			spells = {
				{442799},
			},
			options = {
				{ -- 图标 腥红溢流（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 442799,
					effect = 2,
					tip = L["吸收治疗"],
					sound = "[move]",
				},
				{ -- 图标 腐灼反应（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 450661,
					hl = "red",
					tip = L["强力DOT"],
					sound = "[sound_buzzer]",
					ficon = "4",
				},
			},
		},
		{ -- 灌输
			spells = {
				{450362, "2"},
			},
			options = {
				{ -- 图标 不稳定的灌能（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 443274,
					effect = 2,
					tip = L["吸收治疗"],
				},				
				{ -- 文字 出血 文字倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 1, 0},
					preview = T.GetIconLink(441612)..L["倒计时"],
					data = {
						spellID = 443273,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 443273 then -- 不稳定的灌能
								T.Start_Text_DelayLoopTimer(self, 7.5, L["躲圈"], true)
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 443273 then -- 不稳定的灌能
								T.Stop_Text_Timer(self)
							end
						elseif event == "ENCOUNTER_START" then
							if not self.timer_init then
								self.show_time = 3
								self.round = true
								self.timer_init = true
							end
						end
					end,
				},
			},
		},
		{ -- 催生变异
			spells = {
				{452802, "12"},
			},
			options = {
				{ -- 计时条 催生变异[音效:催生变异]（?）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 453960,
					color = {.85, .75, .97},
					ficon = "12",
					sound = soundfile("453960cast", "cast"),					
				},
			},
		},
		{ -- 粘性之网
			spells = {
				{446349, "7"},
			},
			options = {
				{ -- 文字 粘性之网 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "3,12",
					color = {.95, .88, .76},
					preview = T.GetFlagIconStr("7")..L["分散"]..L["倒计时"],
					data = {
						spellID = 446349,
						events =  {
							["ENCOUNTER_PHASE"] = true,
						},
						sound = "[spread]",
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_PHASE" then
							T.Start_Text_DelayRowTimer(self, {31.1, 30, 30, 30, 30}, L["分散"], true)
						elseif event == "ENCOUNTER_START" then
							if not self.timer_init then
								self.round = true
								self.count_down_start = 3
								self.mute_count_down = true
								if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
									self.prepare_sound = string.match(self.data.sound, "%[(.+)%]")
								else
									self.prepare_sound = nil
								end
								self.timer_init = true
							end
							T.Start_Text_DelayTimer(self, 15, L["分散"], true)
						end
					end,
				},
				{ -- 图标 粘性之网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 446349,
					hl = "blu",
					ficon = "3,12,7",
					msg = {str_applied = "%name %spell"},
				},
				{ -- 图标 蛛网喷发（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 446351,
					tip = L["定身"],
					ficon = "3,12",
				},
				{ -- 首领模块 粘性之网 点名统计 整体排序（✓）
					category = "BossMod",
					spellID = 446349,
					enable_tag = "everyone",
					ficon = "3,12",
					name = string.format(L["NAME点名排序"], T.GetIconLink(446349)).." "..string.format(L["NAME驱散提示2"], T.GetSpellIcon(446349)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ADDON_MSG"] = true,
					},
					custom = {
						{
							key = "use_delay_bool",
							text = L["自动提示驱散"],
							default = true,
						},
						{
							key = "delay_sl",
							text = L["自动提示驱散延迟"],
							default = 3,
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
							key = "dispel_index4_bool",
							text = L["接受驱散的序号"].."4",
							default = true,
						},
					},
					init = function(frame)
						frame.aura_id = 446349
						frame.element_type = "bar"
						frame.color = {.95, .88, .76}
						frame.role = true
						frame.raid_index = true
						frame.disable_copy_mrt = true
						
						frame.diffculty_num = {
							[15] = 3, -- H
							[16] = 4, -- M
						}		
						
						frame.info = {
							{msg_applied = "{rt6}1 %name", msg = "{rt6}1"},
							{msg_applied = "{rt6}2 %name", msg = "{rt6}2"},
							{msg_applied = "{rt6}3 %name", msg = "{rt6}3"},
							{msg_applied = "{rt6}4 %name", msg = "{rt6}4"},
						}
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)			
						T.UpdateAuraMods_ByMrt(frame, event, ...)
						
						if event == "ADDON_MSG" then
							local channel, sender, GUID, message = ...
							if message == "DispelMe" then
								if frame.actives[GUID] then
									local tag = string.format("dispel_index%d_bool", frame.actives[GUID].index)
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
							if sub_event == "SPELL_AURA_APPLIED" and aura_id == frame.aura_id then
								if C.DB["BossMod"][frame.config_id]["use_delay_bool"] then
									if destGUID == G.PlayerGUID then
										local delay = C.DB["BossMod"][frame.config_id]["delay_sl"]
										C_Timer.After(delay, function()
											if AuraUtil.FindAuraBySpellID(frame.aura_id, "player", G.TestMod and "HELPFUL" or "HARMFUL") then
												T.addon_msg("DispelMe", "GROUP")
											end
										end)
									end
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and aura_id == frame.aura_id then
								local unit_id = T.GetGroupInfobyGUID(destGUID)["unit"]
								T.GlowRaidFramebyUnit_Hide("proc", "bm446349", unit_id)
							end
						end
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
						T.GlowRaidFrame_HideAll("proc", "bm446349")
					end,
				},
			},
		},
		{ -- 不稳定的混合物
			spells = {
				{441362, "0,2"},
			},
			options = {
				{ -- 文字 不稳定的混合物 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {.57, .89, .04},
					preview = L["治疗坦克"]..L["倒计时"],
					data = {
						spellID = 443003,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {2},
								[2] = {18, 20, 20, 20, 20, 20, 20, 20},
								[3] = {18, 20, 20, 20, 20, 20, 20, 20},
								[4] = {18, 20, 20, 20, 20, 20, 20, 20},
							},
						},
						cd_args = {
							round = true,							
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 443003, L["治疗坦克"], self, event, ...)
					end,
				},
				{ -- 计时条 不稳定的混合物[音效:治疗坦克]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 443003,
					color = {.57, .89, .04},
					ficon = "0,2",
					show_tar = true,
					sound = soundfile("443003cast", "cast"),
				},
				{ -- 图标 不稳定的混合物（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 441362,
					hl = "",
					tip = L["需要加满"],
					ficon = "0",
				},
				{ -- 图标 不稳定的混合物（易伤）（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 441368,
					tip = L["易伤"],
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 441362,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(441362)..T.GetIconLink(441368)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[441362] = { -- 不稳定的混合物
								color = {0, 1, 0},
								hl_raid = "pixel",
							},
							[441368] = { -- 不稳定的混合物（易伤）
								color = {.5, .51, .89},
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
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 442432,
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 442432,
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 4,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 442432,
					count = 3,
				},					
			},
		},
	},
}
