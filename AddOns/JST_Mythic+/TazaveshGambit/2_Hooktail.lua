local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2449] = {
	engage_id = 2419,
	npc_id = {"175546"},
	alerts = {
		{ -- 永恒吐息
			spells = {
				{347149, "0"},
			},
			options = {
				{ -- 文字 永恒吐息 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(347149)..L["倒计时"],
					data = {
						spellID = 347149,
						events =  {
							["UNIT_SPELLCAST_START"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							T.Start_Text_DelayTimer(self, 16, T.GetIconLink(347149), true)
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 347149 then -- 永恒吐息
								T.Start_Text_DelayTimer(self, 15, T.GetIconLink(347149), true)
							end
						end
					end,
				},
				{ -- 计时条 永恒吐息（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 347149,
					sound = "[breath]cast",
				},
				{ -- 图标 永恒吐息
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350134,
					hl = "org",
					sound = "[dodge]",
				},
				{ -- 团队框架高亮 永恒吐息
					category = "RFIcon",
					type = "Aura",
					spellID = 347149,
					color = "red",
				},
			},
		},
		{ -- 定时炸弹
			spells = {
				{1240097, "7"},
			},
			options = {
				{ -- 文字 定时炸弹 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1240102)..L["倒计时"],
					data = {
						spellID = 1240102,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {20.0, 28.1, 21.9, 25.0, 15.0, 20.0, 25.0, 15.0, 20.0, 25.1, 14.9, 20.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1240102, T.GetIconLink(1240102), self, event, ...)
					end,
				},
				{ -- 计时条 定时炸弹（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1240102,
					sound = "[bomb]cast",
					ficon = "7",
				},
				{ -- 图标 定时炸弹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1240097,
					ficon = "7",
					hl = "blu",
					sound = "[bombonyou]",
				},
				{ -- 自保技能提示 定时炸弹（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1240097,
					threshold = 65,
				},
				{ -- 团队框架高亮 定时炸弹（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1240097,
					color = "blu",
				},
				{ -- 文字 定时炸弹 驱散提示（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["驱散"]..L["倒计时"],
					ficon = "2",
					data = {
						spellID = 1240097,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						count = 0,
						sound = "[dispel]",
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, extraSpellId = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_DISPEL" and extraSpellId == 1240097 and sourceGUID == G.PlayerGUID and self.count > 0 then
								T.Start_Text_DelayTimer(self, 8, L["驱散"], true)
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1240097 then
								self.count = self.count + 1
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1240097 then
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
		{ -- 海盗船蛮兵:双倍速
			npcs = {
				{23833},
			},
			spells = {
				{1240214, "6"}, -- 双倍速
			},
			options = {
				{ -- 姓名板光环 双倍速（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1240214,
				},
			},
		},
		{ -- 海盗船炮手:火炮弹幕
			npcs = {
				{23027},
			},
			spells = {
				{347370}, -- 火炮弹幕
			},
			options = {
				{ -- 图标 燃烧沥青（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 358947,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 海盗船炮手:船锚射击
			npcs = {
				{23027},
			},
			spells = {
				{352345}, -- 船锚射击
			},
			options = {
				{ -- 文字 船锚射击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(352345)..L["倒计时"],
					data = {
						spellID = 352345,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							T.Start_Text_DelayTimer(self, 18, T.GetIconLink(352345), true)
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, extraSpellId = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and extraSpellId == 352345 then
								T.Start_Text_DelayTimer(self, 20, T.GetIconLink(352345), true)
							end
						end
					end,
				},
				{ -- 图标 船锚射击（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 352345,
					hl = "red",
				},
				{ -- 自保技能提示 船锚射击（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 352345,
					threshold = 65,
				},
				{ -- 团队框架高亮 船锚射击（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 352345,
					color = "red",
				},
			},
		},
		{ -- 致命海洋
			spells = {
				{347422, "4"},
			},
			options = {
				{ -- 图标 致命海洋（缺数据）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 354497,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},		
	},
}