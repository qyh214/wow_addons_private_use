local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1267\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2570] = {
	engage_id = 2835,
	npc_id = {"207939"},
	alerts = {
		{ -- 报偿之怒
			spells = {
				{422969, "5"},
			},
			options = {				
				{ -- 能量（✓）
					category = "TextAlert", 
					type = "pp",
					data = {
						npc_id = "207939",
						ranges = {
							{ ul = 99, ll = 90, tip = L["BOSS强化"]..string.format(L["能量2"], 100)},
						},
					},
				},
				{ -- 计时条 报偿之怒（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 422969,
					text = L["BOSS强化"],
				},
				{ -- 图标 报偿之怒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 422969,
					tip = L["BOSS强化"],
				},
			},
		},
		{ -- 谴罚者之盾
			spells = {
				{423015},
			},
			options = {				
				{ -- 计时条 谴罚者之盾（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423015,
					spellIDs = {446649},
					text = L["减速"].."+"..L["大圈"],
					group = 1,
					glow = true,
				},
				{ -- 图标 谴罚者之盾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 423015,
					spellIDs = {446649},
					tip = L["减速"].."50%",
					hl = "yel",
				},
			},
		},
		{ -- 灼烧之光
			spells = {
				{423051, "6"},
			},
			options = {
				T.Temp_ImportantInterruptBar(423051, { -- 灼烧之光（✓）
					spellIDs = {446657},
				}),
				{ -- 姓名板打断图标 灼烧之光（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 423051,
					spellIDs = {446657},
					mobID = "207939",
					interrupt = 3,
					ficon = "6",
				},
			},
		},
		{ -- 纯洁之锤
			spells = {
				{423062},
			},
			options = {
				{ -- 文字 纯洁之锤 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 423062,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {7, 35, 35, 35, 35, 35, 35},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 423062, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 纯洁之锤（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 423062,
					sound = "[run]cast",
					glow = true,
					group = 1,
				},
			},
		},
		{ -- 献祭葬火
			spells = {
				{446368},
			},
			options = {
				{ -- 文字 献祭葬火 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(446368)..L["倒计时"],
					data = {
						spellID = 446368,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {16, 38, 38, 38, 38, 38},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 446368, T.GetIconLink(446368), self, event, ...)
					end,
				},
				{ -- 文字 献祭葬火 计数（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(446368)..L["计数"],
					data = {
						spellID = 446403,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 446368 then
								if AuraUtil.FindAuraBySpellID(422969, "boss1", "HELPFUL") then -- 报偿之怒
									self.count = 5
								else
									self.count = 3
								end
								
								self.exp_time = GetTime() + 30
								self.count_down = 5
								self.prepare = "prepare_drop"
								self.text:SetText("")
								self:Show()
								
								self:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > 0.05 then
										s.remain = s.exp_time - GetTime()
										if s.remain > 0 then
											if s.count == 0 then
												s.text:SetText(string.format("|cff00ff00%s %s|r", L["撞球"], L["结束"]))
											elseif s.remain > 21.7 then
												s.text:SetText(string.format("|cffff0000%s[%d] %.1fs|r", L["大圈"], s.count, s.remain-21.7))
												s.remain_second = ceil(s.remain-21.7)
												if s.remain_second <= s.count_down then
													if s.prepare then
														T.PlaySound(s.prepare)	
														s.prepare = nil
													else
														T.PlaySound("count\\"..s.remain_second)
													end
													s.count_down = s.remain_second - 1
												end
											elseif s.remain > 16.7 then
												s.text:SetText(string.format("|cfff88825%s[%d] %.1fs|r", L["集合"], s.count, s.remain-16.7))
												s.remain_second = ceil(s.remain-16.7)
												if s.remain_second == 5 and s.count_down == 0 then -- 重置
													s.count_down = 5
													s.prepare = "soak_orb"
												end
												if s.remain_second <= s.count_down then
													if s.prepare then
														T.PlaySound(s.prepare)	
														s.prepare = nil
													else
														T.PlaySound("count_en\\"..s.remain_second)
													end
													s.count_down = s.remain_second - 1
												end
											else
												s.text:SetText(string.format("|cffffff00%s[%d] %ds|r", L["撞球"], s.count, s.remain))
											end
										else
											s:Hide()
											s:SetScript("OnUpdate", nil)
										end
										s.t = 0
									end
								end)
								
							elseif (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE" or sub_event == "SPELL_MISSED") and spellID == 446403 then
								self.count = self.count - 1
								if self.count == 0 then
									self.exp_time = GetTime() + 2
								end
							end
						end
					end,
				},
				{ -- 计时条 献祭葬火（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 446368,
				},
				{ -- 图标 牺牲烈焰（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 446403,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 自保技能提示 牺牲烈焰（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 446403,
					threshold = 65,
				},
				{ -- 团队框架高亮 牺牲烈焰（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 446403,
					color = "red",
				},
			},
		},
	},
}