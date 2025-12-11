local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1273\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["准备奇袭"] = "准备奇袭"
	L["抱去"] = "抱%s去%s"
	L["被抱去"] = "被%s抱去%s"
	L["自己去"] = "去%s"
	L["然后"] = "然后"
	L["红影子"] = "红影子"
	L["准备屠戮"] = "准备屠戮"
	L["光柱冲锋"] = "光柱冲锋"
	L["对角线冲锋"] = "对角线冲锋"
	L["NAME奇袭位置分配"] = "分配%s站位及龙人抱，使用光柱%s"
else
	L["准备奇袭"] = "Assassination soon"
	L["抱去"] = "carry %s to %s"
	L["被抱去"] = "carried to %2$s by %1$s"
	L["自己去"] = "go to %s"
	L["然后"] = "then "
	L["红影子"] = "Red"
	L["准备屠戮"] = "Massacre soon"
	L["光柱冲锋"] = "WM Charge"
	L["对角线冲锋"] = "Diagonal Charge"
	L["NAME奇袭位置分配"] = "Assign world mark and evoker for %s, use world marks :%s"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2601] = {
	engage_id = 2920,
	npc_id = {"217748"},
	alerts = {
		{ -- 奇袭
			spells = {
				{436867, "5"},
			},
			npcs = {
				{28797},
			},
			options = {
				{ -- 文字 奇袭 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.75, .29, .85},
					preview = L["准备奇袭"]..L["倒计时"],
					data = {
						spellID = 436867,
						events =  {
							["ENCOUNTER_PHASE"] = true,
						},
						info = {						
							[15] = {
								[1] = {8},
								[2] = {13},
								[3] = {13},
							},
							[16] = {
								[1] = {9},
								[2] = {15},
								[3] = {15},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "1273\\assassin", -- [音效:准备奇袭]
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 436867, L["准备奇袭"], self, event, ...)
					end,
				},
				{ -- 计时条 奇袭（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 440650,
					dur = 8,
					color = {.75, .29, .85},
					ficon = "12",
				},
				{ -- 声音 奇袭[音效:奇袭点你]（✓）
					category = "Sound",
					spellID = 436870,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("436870aura"),
				},
				{ -- 图标 女王之灾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 437343,
					hl = "org_flash",
					tip = L["炸弹"],
					sound = "cd3",
				},
				{ -- 女王之灾 计时圆圈（✓）
					category = "BossMod",
					spellID = 437342,
					enable_tag = "none",
					name = T.GetIconLink(437343)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[437343] = { -- 女王之灾
								unit = "player",
								aura_type = "HARMFUL",
								color = {.84, .74, 1},
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
				{ -- 首领模块 点名统计 女王之灾（✓）
					category = "BossMod",
					spellID = 437343,
					enable_tag = "everyone",
					name = string.format(L["NAME点名排序"], T.GetIconLink(437343)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						frame.aura_id = 437343 -- 女王之灾
						frame.element_type = "bar"
						frame.color = {.65, 0, .89}
						frame.role = true
						frame.raid_glow = "pixel"
						frame.raid_index = true
						frame.support_spells = 9
						frame.bar_num = 5
						
						frame.info = {
							{text = "[1]", msg_applied = "1 %name", msg = "1"},
							{text = "[2]", msg_applied = "2 %name", msg = "2"},
							{text = "[3]", msg_applied = "3 %name", msg = "3"},
							{text = "[4]", msg_applied = "4 %name", msg = "4"},
							{text = "[5]", msg_applied = "5 %name", msg = "5"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								if mod(frame.count, 3) == 1 then
									T.Start_Text_Timer(self.text_frame, 9, self.info[index]["text"].." "..L["拉人"], true)
								else
									T.Start_Text_Timer(self.text_frame, 9, self.info[index]["text"].." "..L["射线"], true)
								end
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
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByTime(frame)
					end,
				},
			},
		},
		{ -- 死亡蒙纱
			spells = {
				{448364, "12"},
			},
			options = {
				{ -- 文字 死亡蒙纱 计数（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "12",
					color = {1, .27, .26},
					preview = string.format("|cffe32221%s|r %d/%d", L["红影子"], 2, 3),
					data = {
						spellID = 447169,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						num = 0,
						total_num = 3,
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 447169 then
								self.data.num = self.data.num + 1
								T.Start_Text_Timer(self, 3, string.format("|cffe32221%s|r %d/%d", L["红影子"], self.data.num, self.data.total_num))
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 447169 then
								self.data.num = self.data.num - 1
								T.Start_Text_Timer(self, 3, string.format("|cffe32221%s|r %d/%d", L["红影子"], self.data.num, self.data.total_num))
							end
						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 2 then
								self.data.num = 0
								self.data.total_num = 4
							elseif phase == 3 then
								self.data.num = 0
								self.data.total_num = 5
							end
						elseif event == "ENCOUNTER_START" then
							self.data.num = 0
							self.data.total_num = 3
						end
					end,
				},
				{ -- 图标 死亡蒙纱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 447169,
					hl = "yel",
					tip = L["BOSS强化"].."%s10%",
				},
			},
		},
		{ -- 暮光屠戮
			spells = {
				{438245},
			},
			options = {
				{ -- 文字 暮光屠戮 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.96, .42, 1},
					preview = L["准备屠戮"]..L["倒计时"],
					data = {
						spellID = 438245,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							["all"] = {
								[1] = {33, 30},
								[2] = {39, 30},
								[3] = {39, 30},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							if self.difficultyID == 16 then
								self.prepare_sound = "1273\\diagonal_charge" -- [音效:对角线冲锋]
								T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438245, L["对角线冲锋"], self, event, ...)
							else
								self.prepare_sound = "1273\\massacre" -- [音效:准备屠戮]
								T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438245, L["准备屠戮"], self, event, ...)
							end
						elseif event == "ENCOUNTER_PHASE" then						
							if self.difficultyID == 16 then
								self.prepare_sound = "1273\\wm_charge" -- [音效:光柱冲锋]
								T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438245, L["光柱冲锋"], self, event, ...)
							else
								self.prepare_sound = "1273\\massacre" -- [音效:准备屠戮]
								T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438245, L["准备屠戮"], self, event, ...)
							end
						elseif event == "ENCOUNTER_START" then
							if self.difficultyID == 16 then
								self.prepare_sound = "1273\\wm_charge" -- [音效:光柱冲锋]
								T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438245, L["光柱冲锋"], self, event, ...)
							else
								self.prepare_sound = "1273\\massacre" -- [音效:准备屠戮]
								T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 438245, L["准备屠戮"], self, event, ...)
							end
							self.difficultyID = select(3, ...)
						end
					end,
				},
				{ -- 暮光屠戮（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 438245,
					color = {.96, .42, 1},
					text = L["箭头"],
				},
				{ -- 暮光屠戮生效（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 438245,
					dur = 6,
					color = {.96, .42, 1},
					text = L["冲锋"],
				},
				{ -- 声音 暮光屠戮[音效:屠戮点你]（✓）
					category = "Sound",
					spellID = 438141,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = soundfile("438141aura"),
				},
			},
		},
		{ -- 虚空裂隙
			spells = {
				{437620},
			},
			options = {
				{ -- 文字 虚空裂隙 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.26, .14, .72},
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 437620,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							["all"] = {
								[1] = {22, 30, 30},
								[2] = {27, 30, 30},
								[3] = {27, 30, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 437620, L["拉人"], self, event, ...)
					end,
				},
				{ -- 虚空裂隙 影子法术ID相同（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 437620,
					dur = 10,
					tags = {4},
					color = {.26, .14, .72},
					text = L["拉人"],
				},
			},
		},
		{ -- 节点匕首
			spells = {
				{439576},
			},
			options = {
				{ -- 文字 节点匕首 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					color = {.8, .64, 1},
					preview = L["飞刀"]..L["倒计时"],
					data = {
						spellID = 439576,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
						info = {
							["all"] = {
								[1] = {45, 30},
								[2] = {50, 30},
								[3] = {50, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 439576, L["飞刀"], self, event, ...)						
					end,
				},
				{ -- 节点匕首（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 439576,
					color = {.8, .64, 1},
				},
			},
		},
		{ -- 虚空溃灭
			spells = {
				{440377, "0"},
			},
			options = {
				{ -- 文字 虚空溃灭 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					color = {.42, .19, .35},
					preview = T.GetIconLink(440377)..L["倒计时"],
					data = {
						spellID = 440377,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
							["ENCOUNTER_PHASE"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10, 30, 30},
								[2] = {15, 30, 30},
								[3] = {15, 30, 30},
							},
						},
						cd_args = {
							round = true,							
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 440377, T.GetIconLink(440377), self, event, ...)
					end,
				},
				{ -- 计时条 虚空溃灭[音效:虚空溃灭]（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 440377,
					color = {.42, .19, .35},
					ficon = "0",
					show_tar = true,
					sound = soundfile("440377cast", "cast"),
				},
				{ -- 图标 深凿重创（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 440576,
					hl = "",
					tip = L["易伤"],
					ficon = "0",
				},
				{ -- 首领模块 换坦光环（✓）
					category = "BossMod",
					spellID = 440576,
					enable_tag = "role",
					ficon = "0",
					name = string.format(L["NAME换坦技能提示"], T.GetIconLink(440576)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)
						frame.spellIDs = {
							[440576] = { -- 深凿重创
								color = {.42, .19, .35},
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
		{ -- 喑星之夜
			spells = {
				{435414, "5"},
			},
			options = {
				{ -- 文字提示 能量（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = L["阶段转换"]..string.format(L["能量"], 95, 100),				
					data = {
						spellID = 435405,
						events = {
							["UNIT_POWER_UPDATE"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, arg1)
						if event == "UNIT_POWER_UPDATE" and arg1 == "boss1" then
							local cur = UnitPower("boss1")
							if mod(self.phase, 1) ~= 0 then
								self:Hide()
							else
								if cur >= 95 and cur < 100 then
									self.text:SetText(L["阶段转换"]..string.format(L["能量"], cur, 100))
									self:Show()
								else
									self:Hide()
								end
							end
						elseif event == "ENCOUNTER_PHASE" then
							self.phase = arg1
							if mod(self.phase, 1) ~= 0 then
								self:Hide()
							end
						elseif event == "ENCOUNTER_START" then
							self.phase = 1
						end
					end,
				},
				{ -- 喑星之夜（✓）
					category = "AlertTimerbar",
					type = "cleu",
					spellID = 435405,
					event = "SPELL_CAST_START",
					spellIDs = {442277}, -- 无尽长夜
					dur = 5,
					color = {.17, .3, .78},
					text = L["阶段转换"],
					sound = "[phase]cast",
				},
			},
		},
		{ -- 冷血弑君
			spells = {
				{435486},
			},
			options = {
				{ -- 声音 冷血弑君（✓）
					category = "Sound",
					spellID = 435534,
					spellIDs = {436663, 436664, 436665, 436666, 436671, 436677},
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[fixate]",
				},
			},
		},
		{ -- 蚀盛
			spells = {
				{434645},
			},
			options = {
				{ -- 蚀盛 计时条（✓）
					category = "BossMod",
					spellID = 434645,
					enable_tag = "none",
					name = string.format(L["计时条%s"], T.GetIconLink(434645)),
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 200, width = 250, height = 53},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,	
					},
					init = function(frame)
						local icon = C_Spell.GetSpellTexture(434645)
						frame.bar = T.CreateTimerBar(frame, icon, false, true, true, 250, 25, {0, .53, .98})
						frame.bar:SetPoint("TOP", frame, "TOP", 0, 0)
						
						local icon2 = C_Spell.GetSpellTexture(435414)
						frame.bar2 = T.CreateTimerBar(frame, icon2, false, true, true, 250, 25, {.4, 0, .8})
						frame.bar2:SetPoint("TOP", frame.bar, "BOTTOM", 0, -3)
						
						function frame.bar:OnStartLoop()
							frame.ind = frame.total_num
							self.left:SetText(frame.ind.."/"..frame.total_num)
							self:SetStatusBarColor(0, .53, .98)
						end
	
						function frame.bar:OnLoop()
							frame.ind = frame.ind - 1
							self.left:SetText(frame.ind.."/"..frame.total_num)
							if frame.difficultyID == 16 then
								if frame.ind == 2 then
									self:SetStatusBarColor(1, 1, 0)
									self.mid:SetText(L["最强一波"])
								elseif frame.ind == 1 then
									self:SetStatusBarColor(1, 0, 0)
									self.mid:SetText(L["注意自保"])
								end
							end
						end
						
						function frame:PreviewShow()
							self.bar:Show()
							self.bar2:Show()
						end
						
						function frame:PreviewHide()
							self.bar:Hide()
							self.bar2:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" then
								if spellID == 435405 then
									if frame.difficultyID == 16 then
										frame.total_num = 12
										T.StartLoopBar(frame.bar, 2, 12, true, true)
									else
										frame.total_num = 8
										T.StartLoopBar(frame.bar, 3, 8, true, true)
									end
									T.StartTimerBar(frame.bar2, 24, true, true)
								elseif spellID == 442277 then
									if frame.difficultyID == 16 then
										frame.total_num = 15
										T.StartLoopBar(frame.bar, 2, 15, true, true)
									else
										frame.total_num = 10
										T.StartLoopBar(frame.bar, 3, 10, true, true)
									end
									T.StartTimerBar(frame.bar2, 30, true, true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.difficultyID = select(3, ...)
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
						T.StopTimerBar(frame.bar2, true, true)
					end,
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
					spellID = 435405,
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 435405,
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 435405,
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 435405,
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 3.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 442277,
				},
			},
		},
	},
}