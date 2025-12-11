local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1185\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2411] = {
	engage_id = 2403,
	npc_id = {"165410"},
	alerts = {
		{ -- 赎罪容器
			spells = {
				{323848},
			},
			options = {
				{ -- 文字 赎罪容器 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = C_Spell.GetSpellName(323749)..L["倒计时"],
					data = {
						spellID = 323749,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 323749 then
								self.count = self.count + 1
								local dur = self.count == 2 and 41 or 21
								T.Start_Text_DelayTimer(self, dur, C_Spell.GetSpellName(323749), true)
							end
						elseif event == "ENCOUNTER_START" then
							self.round = true
							self.count = 1
							
							T.Start_Text_DelayTimer(self, 71, C_Spell.GetSpellName(323749), true)
						end
					end,
				},
				{ -- 文字 赎罪容器 出现提醒（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(323848),
					data = {
						spellID = 323848,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						sound = "tool",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 323749 then
								T.Start_Text_DelayTimer(self, 2, T.GetIconLink(323848))
								T.PlaySound("tool")
							end
						end
					end,
				},
			},	
		},
		{ -- 心能箭矢
			spells = {
				{323538, "0,6"},
			},
			options = {
				T.Temp_SubInterruptBar(323538, { -- 心能箭矢（✓）
					show_tar = true,
				}),
				{ -- 姓名板打断图标 心能箭矢（✓）
					category = "PlateAlert",
					type = "PlateInterrupt",
					spellID = 323538,
					mobID = "165410",
					interrupt = 2,
					ficon = "6",
				},
				{ -- 对我施法图标 心能箭矢（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 323538,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 心能箭矢（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 323538,
				},
			},
		},
		{ -- 不稳定的心能
			spells = {
				{1236512},
			},
			options = {
				{ -- 文字 不稳定的心能 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["DOT"].."+"..L["分散"]..L["倒计时"],
					data = {
						spellID = 1236512,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10.0, 17.8, 15.8, 16.2, 15.8, 15.8, 15.8, 17.0, 17.0, 17.0},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 4,
							prepare_sound = "spread",
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 1236512, L["DOT"].."+"..L["分散"], self, event, ...)
					end,
				},
				{ -- 图标 不稳定的心能（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1236513,
					ficon = "7",
					hl = "blu",
					tip = L["DOT"],
				},
				{ -- 自保技能提示 不稳定的心能（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1236513,
					threshold = 65,
				},
				{ -- 团队框架高亮 不稳定的心能（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1236513,
					color = "blu",
				},
				{ -- 文字 不稳定的心能 驱散提示（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["驱散"]..L["倒计时"],
					ficon = "2",
					data = {
						spellID = 1236513,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						count = 0,
						sound = "[dispel]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, extraSpellId = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 1236512 then
								C_Timer.After(12, function()
									T.Stop_Text_Timer(self)
								end)
							elseif sub_event == "SPELL_DISPEL" and extraSpellId == 1236513 and sourceGUID == G.PlayerGUID and self.count > 0 then
								T.Start_Text_DelayTimer(self, 8, L["驱散"], true)
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1236513 then
								self.count = self.count + 1
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1236513 then
								self.count = self.count - 1
								if self.count == 0 then
									T.Stop_Text_Timer(self)
								end
							end
						elseif event == "ENCOUNTER_START" then
							self.count = 0
							self.count_down_start = 1
							self.mute_count_down = true
							
							if C.DB["TextAlert"]["spell"][self.data.spellID]["sound_bool"] then
								self.prepare_sound = "dispel"
							else
								self.prepare_sound = nil								
							end
						end
					end,
				},
			},
		},
		{ -- 幽灵附身
			spells = {
				{323597},
			},
			options = {
				{ -- 文字 幽灵附身 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 323743,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {14.6, 20.7, 20.6, 20.6, 20.6, 20.7, 20.6, 21.9, 24.3},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 323743, L["召唤小怪"], self, event, ...)
					end,
				},
				{ -- 声音 幽灵附身（✓）
					category = "Sound",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 323743,
					file = "[add]",
				},
			},	
		},
		{ -- 阴森的教民:萦绕锁定
			npcs = {
				{21861},
			},
			spells = {
				{323650},
			},
			options = {
				{ -- 计时条 萦绕锁定（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 323650,
					show_tar = true,
					sound = "[focus]",
				},
				{ -- 图标 萦绕锁定（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 323650,
					hl = "red",
					tip = L["锁定"],
				},
			},
		},
		{ -- 心能喷泉
			spells = {
				{329340},
			},
			options = {
				{ -- 计时条 心能喷泉（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 329340,
					sound = "[dodge_circle]cast",
				},
			},
		},
	},
}