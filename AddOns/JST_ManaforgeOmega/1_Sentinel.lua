local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then

elseif G.Client == "ruRU" then

else

end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2684] = {
	engage_id = 3129,
	npc_id = {"233814"},
	alerts = {
		{ -- 相位闪现
			spells = {
				{1218148, "5"},--【相位闪现】
			},
			options = {
				{ -- 图标 相位闪现（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "player",
					spellID = 1220679,
					tip = L["免疫"],
					hl = "gre",
				},
			},
		},
		{ -- 奥能矩阵湮灭器
			spells = {
				{1217649, "4"},--【奥能矩阵湮灭器】
				--{1219223},--【灰飞烟灭】
				--{1219248},--【奥术辐射】
			},
			options = {
				{ -- 图标 奥术辐射（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1219248,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 奥术闪电
			spells = {
				{1227794},-- 【奥术闪电】
			},
			options = {
				{ -- 文字 奥术闪电 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1234699)..L["倒计时"],
					data = {
						spellID = 1234699,
						events =  {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.show_time = 3
							T.Start_Text_DelayTimer(self, 8.5, L["躲地板"], true)		
						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if mod(phase, 1) == 0 then
								T.Start_Text_DelayTimer(self, 8.5, L["躲地板"], true)
							else
								T.Stop_Text_Timer(self)
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1234699 then -- 奥术闪电
								T.Start_Text_DelayTimer(self, 8.5, L["躲地板"], true)
							end
						end
					end,
				},
				{ -- 声音 奥术闪电（✓）
					category = "Sound",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1234699,
					file = "[mindstep]",
				},
			},
		},
		{ -- 净化内室
			spells = {
				{1234733, "4,12"},-- 【净化内室】
			},
			options = {
				{ -- 计时条 净化内室（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1234733,
				},
			},
		},
		{ -- 根除齐射
			spells = {
				{1229762, "5"},-- 【根除齐射】
			},
			options = {				
				{ -- 文字 根除齐射 倒计时（史诗待测试）
					category = "TextAlert",
					type = "spell",
					preview = L["分担"]..L["倒计时"],
					data = {
						spellID = 1219531,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {30.2},
								[2] = {27.0, 34.2},
								[3] = {26.8, 34.1},
								[4] = {26.8, 37.8, 36.5, 35.2},
							},
							[16] = {
								[1] = {39.8},
								[2] = {18.3, 31.6, 35.1},
								[3] = {18.3, 31.7, 33.7},
								[4] = {18.3, 31.7},
							},				
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1219531, L["分担"], self, event, ...)
					end,
				},
				{ -- 计时条 根除齐射（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 1219607,
					dur = 7.5,
					tags = {5.7},
					show_tar = true,
				},
				{ -- 首领模块 根除齐射分担分组（待测试）
					category = "BossMod",
					spellID = 1219607,
					enable_tag = "spell",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1219607)),
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = 200, width = 320, height = 32},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 320,
							min = 200,
							max = 500,
							apply = function(value, alert)
								alert:SetWidth(value)
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 32,
							min = 20,
							max = 50,
							apply = function(value, alert)
								alert:SetHeight(value)
							end
						},
						{
							key = "mrt_custom_btn", 
						},
						{
							key = "hp_perc_sl",
							text = L["血量阈值百分比"],
							default = 65,
							min = 20,
							max = 100,
						},
					},
					init = function(frame)
						frame.assignment = {}
						frame.my_index = 0
						
						local bar = T.CreateTimerBar(frame, nil, false, false, true, 320, 32)
						frame.bar = bar
						
						bar:SetAllPoints(frame)
						bar:SetMinMaxValues(0, 7)
						bar:SetValue(5.2)
						
						bar.bg_tex = bar:CreateTexture(nil, "BORDER")
						bar.bg_tex:SetAllPoints(bar)
						bar.bg_tex:SetTexture(G.media.blank)
						
						T.CreateTagsforBar(bar, 1)
						bar.tag_indcators[1]:SetWidth(4)
						
						function frame:CreateTag(key, x)
							local tag = self.bar:CreateTexture(nil, "OVERLAY")
							tag:SetSize(32, 32)
							tag:SetTexture(G.media.triangle)
							tag:SetVertexColor(1, 1, 1)
							tag:SetPoint("TOP", self.bar, "BOTTOMLEFT", 208, -2)
							
							local text = T.createtext(self.bar, "OVERLAY", 20, "OUTLINE", "CENTER")
							text:SetPoint("TOP", tag, "BOTTOM", 0, -2)
							text:SetText(L["分担"])
							
							self.bar[key] = tag
						end
						
						frame:CreateTag("tag1", 208)
						frame:CreateTag("tag1", 290)
						
						function frame:UpdateBarStatus(i, preview)
							T.AddPersonalSpellCheckTag("bossmod"..self.config_id, C.DB["BossMod"][self.config_id]["hp_perc_sl"], {"TANK"})
							C_Timer.After(7, function()
								T.RemovePersonalSpellCheckTag("bossmod"..self.config_id)
							end)
							
							local sound
							if i == 1 then
								self.bar:SetStatusBarColor(.13, .81, .25)
								self.bar.bg_tex:SetVertexColor(.89, .1, .22)
								sound = "1302\\soak1"
							else
								self.bar:SetStatusBarColor(.89, .1, .22)
								self.bar.bg_tex:SetVertexColor(.13, .81, .25)
								sound = "1302\\soak2"
							end
							
							if not preview then
								T.StartCountDown("bossmod"..self.config_id, GetTime()+5.2, 4, sound)
							end
								
							self.bar.start = GetTime()
							self.bar:SetScript("OnUpdate", function(s, e)
								s.t = s.t + e
								if s.t > 0.01 then
									local passed = GetTime() - s.start
									if passed < 7 then
										s:pointtag(1, passed/7)
									else													
										s:SetScript("OnUpdate", nil)
										s:Hide()
									end
									s.t = 0
								end
							end)
							
							self.bar:Show()
						end
						
						function frame:AutoSplit()
							if not next(self.assignment) then
								self.assignment = table.wipe(self.assignment)
								self.assignment[1] = {}
								self.assignment[2] = {}
								
								local GUIDs = {}
								
								for unit in T.IterateGroupMembers() do
									local visible = UnitIsVisible(unit)
									local online = UnitIsConnected(unit)

									if visible and online and UnitGroupRolesAssigned(unit) ~= "TANK" then
										local GUID = UnitGUID(unit)
										table.insert(GUIDs, GUID)
									end
								end
								
								T.SortTable(GUIDs)
								
								for i, GUID in ipairs(GUIDs) do
									if i <= #GUIDs / 2 then
										table.insert(self.assignment[1], GUID)
										if GUID == G.PlayerGUID then
											self.my_index = 1
										end
									else
										table.insert(self.assignment[2], GUID)
										if GUID == G.PlayerGUID then
											self.my_index = 2
										end
									end
								end
							end
						end
						
						function frame:GetMrtAssignment()
							self.assignment = table.wipe(self.assignment)
							self.my_index = 0
							
							for lineCount, line in T.IterateNoteAssignment(self.config_id) do
								if lineCount > 2 then return end
								
								local GUIDs, containsPlayerGUID = T.LineToGUIDArray(line)
								
								self.assignment[lineCount] = GUIDs
								
								if containsPlayerGUID then
									self.my_index = lineCount
								end
							end
							
							self:AutoSplit()
						end
						
						function frame:copy_mrt()
							local str, raidlist = "", ""

							for ind = 1, 2 do
								raidlist = raidlist.."\n"
								local i = 0
								for unit in T.IterateGroupMembers() do
									i = i + 1
									if i <= 10 then
										local name = UnitName(unit)
										if name then
											raidlist = raidlist.." "..name
										end
									end
								end
							end
							
							local spell = C_Spell.GetSpellName(self.config_id)
							str = string.format("#%dstart%s%s\nend\n", self.config_id, spell, raidlist)
							
							return str
						end
						
						function frame:PreviewShow()
							local status = random(2)
							self:UpdateBarStatus(status, true)
						end
						
						function frame:PreviewHide()
							self.bar:SetScript("OnUpdate", nil)
							self.bar:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1219531 then
								frame.first_soak = true
								
								if frame.my_index > 0 then
									frame:UpdateBarStatus(frame.my_index)
								end
									
								for group_index, GUIDs in pairs(frame.assignment) do
									if next(GUIDs) then
										local str = ""
										for i, GUID in pairs(GUIDs) do
											local name = T.GetNameByGUID(GUID)
											if name then
												str = str.." "..name
											end
										end
										T.msg(string.format("%s[%d] %s", T.GetIconLink(1219531), group_index, str))
									end
								end
							elseif sub_event == "SPELL_DAMAGE" and spellID == 1219611 then
								if frame.first_soak then
									frame.first_soak = nil
									if frame.my_index == 1 then
										T.PlaySound("out")
									elseif frame.my_index == 2 then
										T.PlaySound("in")
									end
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame:GetMrtAssignment()
						end
					end,
					reset = function(frame, event)
						frame.bar:SetScript("OnUpdate", nil)
						frame.bar:Hide()
						T.StopCountDown("bossmod"..frame.config_id)
					end,
				},
			},
		},
		{ -- 具现矩阵
			spells = {
				{1219450},--【具现矩阵】
				--{1218626},--【错位矩阵】
				--{1219354},--【潜能法力残渣】
			},
			options = {				
				{ -- 计时条 具现矩阵（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 1219450,
					dur = 6,
				},
				{ -- 文字 具现矩阵 倒计时（史诗待测试）
					category = "TextAlert",
					type = "spell",
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 1219450,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {10.6, 33.3},
								[2] = {4.9, 35.5, 35.5},
								[3] = {4.9, 35.5, 35.5},
								[4] = {4.9, 36.7, 36.4},
							},
							[16] = {							
								[1] = {8.5, 28.1},
								[2] = {3.7, 26.8, 28.0, 23.2},
								[3] = {3.7, 26.8, 26.8, 23.2},
								[4] = {3.6, 23.2, 32.9},
							},							
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1219450, L["放圈"], self, event, ...)
					end,
				},
				{ -- 首领模块 具现矩阵 计时圆圈（✓）
					category = "BossMod",
					spellID = 1219459,
					name = T.GetIconLink(1219459)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1219459] = { -- 具现矩阵
								unit = "player",
								aura_type = "HARMFUL",
								color = {0, 1, 1},
								sound = "dropnow",
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
				{ -- 团队框架高亮 具现矩阵（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1219459,
				},			
				{ -- 图标 错位矩阵（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1218625,
					tip = L["昏迷"],
				},
				{ -- 图标 潜能法力残渣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1219354,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 湮灭奥能重炮
			spells = {
				{1219263, "0"},--【湮灭奥能重炮】
			},
			options = {
				{ -- 文字 湮灭奥能重炮 倒计时（史诗待测试）
					category = "TextAlert",
					type = "spell",
					preview = L["坦克"]..L["炸弹"]..L["倒计时"],
					data = {
						spellID = 1219263,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[1] = {21.9, 33.2},
								[2] = {16.1, 34.1, 34.0},
								[3] = {17.1, 34.0, 34.2},
								[4] = {18.3, 34.0, 36.7, 36.4},
							},
							[16] = {
								[1] = {21.9, 30.5},
								[2] = {12.2, 29.2, 28.0},
								[3] = {12.2, 29.3, 29.2},
								[4] = {12.2, 28.0, 28.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1219263, L["坦克"]..L["炸弹"], self, event, ...)
					end,
				},
				{ -- 嘲讽提示 湮灭奥能重炮（待测试）
					category = "BossMod",
					spellID = 1233999,
					ficon = "0",
					name = L["嘲讽提示"]..T.GetIconLink(1233999),
					points = {hide = true},
					events = {					
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_THREAT_SITUATION_UPDATE"] = true,
					},
					init = function(frame)	
						frame.aura_spellIDs = {
							[1233999] = 1, -- 湮灭奥能重炮
						}
						
						frame.cast_spellIDs = {
							[1219263] = true, -- 湮灭奥能重炮
							[1220489] = true, -- 协议：净化
							[1220553] = true, -- 协议：净化
							[1220555] = true, -- 协议：净化
						}
						
						frame.boss_aura_spellIDs = {
							[1220618] = true, -- 协议：净化
							[1220981] = true, -- 协议：净化
							[1220982] = true, -- 协议：净化
						}
						
						function frame:override_check_boss()
							local pass
							
							for unit in T.IterateBoss() do
								local cast_spellID = select(9, UnitCastingInfo(unit))
								if cast_spellID and self.cast_spellIDs[cast_spellID] then
									pass = true
									return
								end
								
								for buff_spellID in pairs(frame.boss_aura_spellIDs) do
									if AuraUtil.FindAuraBySpellID(buff_spellID, unit, "HELPFUL") then -- 协议：净化
										pass = true
										return
									end
								end
							end

							if not pass then
								return true
							end
						end
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
						
						if event == "ENCOUNTER_START" then
							for spellID in pairs(frame.boss_aura_spellIDs) do
								T.RegisterWatchAuraSpellID(spellID)
							end
						end
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
						
						for spellID in pairs(frame.boss_aura_spellIDs) do
							T.UnregisterWatchAuraSpellID(spellID)
						end
					end,
				},
				{ -- 计时条 湮灭奥能重炮（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1219439,
					text = L["全团AE"],
					show_tar = true,
				},			
				{ -- 换坦计时条 湮灭奥能重炮（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1233999,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
			},
		},
		{ -- 活跃的自动机
			spells = {
				{1223364, "2"},--【活跃的自动机】
			},
			options = {
				
			},
		},
		{ -- 协议：净化
			spells = {
				{1220489, "1,5"},--【协议：净化】
			},
			options = {
				{ -- 计时条 协议：净化（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1220553,
					spellIDs = {1220555, 1220489},
					sound = soundfile("1220553cast", "cast"),
				},
				{ -- 文字 协议：净化 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1220553)..L["倒计时"],
					data = {
						spellID = 1220553,
						events = {
							["UNIT_SPELLCAST_START"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and (spellID == 1220553 or spellID == 1220555 or spellID == 1220489) then
								T.Start_Text_Timer(self, 5, T.GetIconLink(1220553), true)
							end
						end
					end,
				},
				{ -- 吸收盾 协议：净化（✓）
					category = "BossMod",
					spellID = 1241303,
					name = string.format(L["NAME吸收盾"], T.GetIconLink(1241303)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.unit = "boss1"
						frame.spell_id = 1241303 -- 协议：净化
						frame.aura_type = "HELPFUL"
						frame.effect = 1
						
						T.InitAbsorbBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAbsorbBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAbsorbBar(frame)
					end,
				},
			},
		},
		{ -- 能量切割者
			spells = {
				{1218669},--【能量切割者】
			},
			options = {
				
			},
		},
		{ -- 净化闪电
			spells = {
				{1233110, "2"},--【净化闪电】
			},
			options = {
				
			},
		},
		{ -- 驱逐领域
			spells = {
				{1219471},--【驱逐领域】
			},
			options = {
				
			},
		},
		{ -- 无常具象
			npcs = {
				{32680, "1,12"},--【无常具象】
			},
			spells = {
				{1235816},--【能量过载】
			},
			options = {
				
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1.5,
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1220489, -- 协议：净化（✓）
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1223364, -- 活跃的自动机（✓）
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1220553, -- 协议：净化（✓）
				},
				{
					category = "PhaseChangeData",
					phase = 3,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1223364, -- 活跃的自动机（✓）
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 3.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1220555, -- 协议：净化（✓）
				},
				{
					category = "PhaseChangeData",
					phase = 4,					
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 1223364, -- 活跃的自动机（✓）
					count = 4,
				},
			},
		},
	},
}