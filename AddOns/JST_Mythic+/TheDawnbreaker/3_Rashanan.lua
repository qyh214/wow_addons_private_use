local T, C, L, G = unpack(JST)

local function soundfile(filename)
	return string.format("[1270\\%s]", filename)
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["已扔炸弹"] = "已扔炸弹 %d/%d"
	L["扔炸弹"] = "扔炸弹！"
	L["走近一点"] = "走近一点"
else
	L["已扔炸弹"] = "Throw Arathi Bomb %d/%d"
	L["扔炸弹"] = "Throw!"
	L["走近一点"] = "Get closer"
end

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2593] = {
	engage_id = 2839,
	npc_id = {"213937"},
	alerts = {
		{ -- 阿拉希炸弹
			spells = {
				{434655, "5"},
			},
			options = {
				{ -- 文字 阿拉希炸弹 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["炸弹"],
					data = {
						spellID = 434655,
						events =  {
							["CHAT_MSG_RAID_BOSS_EMOTE"] = true,
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
						count = 0,
						total_count = 0,
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then							
							local _, _, dif = ...
							if dif == 1 then
								self.data.total_count = 3
							elseif dif == 2 then
								self.data.total_count = 5
							else
								self.data.total_count = 6
							end
							self.data.count = 0
							
							T.Start_Text_DelayTimer(self, 13.5, L["炸弹"], true)							
						elseif event == "CHAT_MSG_RAID_BOSS_EMOTE" then
							local msg = ...
							if string.find(msg, "434655") then
								T.Start_Text_DelayTimer(self, 33.5, L["炸弹"], true)
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 449042 then -- 光芒四射
								T.Stop_Text_Timer(self)							
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 438875 then -- 扔炸弹
								self.data.count = self.data.count + 1
								local tag = "text"..self.data.count
								if not self[tag] then
									self[tag] = T.CreateAlertTextShared("text_"..spellID.."_"..self.data.count, 1)
								end
								T.Start_Text_Timer(self[tag], 2, string.format(L["已扔炸弹"], self.data.count, self.data.total_count))
							end
						end
					end,
				},
				{ -- 图标 火花四射的阿拉希炸弹（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",					
					spellID = 434668,
					tip = L["DOT"],
				},
				{ -- 自保技能提示 火花四射的阿拉希炸弹（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 434668,
					threshold = 65,
				},
				{ -- 团队框架高亮 火花四射的阿拉希炸弹（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 434668,
					color = "org",
				},
			},
		},
		{ -- 酸液翻腾
			spells = {
				{434407},
			},
			options = {
				{ -- 文字 酸液翻腾 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(434407)..L["倒计时"],
					data = {
						spellID = 434407,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {10.8, 20.0, 23.9},
								[2] = {4.4, 37.1, 42.9, 37.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 434407, T.GetIconLink(434407), self, event, ...)
					end,
				},
				{ -- 计时条 酸液翻腾（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434407,
				},
				{ -- 声音 酸液翻腾（✓）
					category = "Sound",
					spellID = 434406,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[1273\\439790aura]"
				},
				{ -- 图标 酸液翻腾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434441,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
				{ -- 图标 腐蚀（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434579,
					tip = L["强力DOT"],
					sound = "[defense]",
				},
				{ -- 团队框架高亮 腐蚀（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 434579,
					color = "red",
				},
				{ -- 图标 酸液池（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 438957,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 缠网喷吐
			spells = {
				{448213},
			},
			options = {
				{ -- 计时条 缠网喷吐（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448213,
					text = L["躲地板"],
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 侵蚀喷涌
			spells = {
				{448888, "2"},
			},
			options = {
				{ -- 文字 侵蚀喷涌 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["全团AE"]..L["倒计时"],
					data = {
						spellID = 448888,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {							
							["all"] = {
								[1] = {20.1, 27.9},
								[2] = {32.6, 31.1, 31.9, 32.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 448888, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 侵蚀喷涌（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 448888,
					group = 1,
					text = L["全团AE"],
					glow = true,
					sound = "[aoe]cast",
				},
				{ -- 图标 萦绕侵蚀（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 463428,	
					tip = L["DOT"],
				},
				{ -- 自保技能提示 侵蚀喷涌（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 448888,
					event = "SPELL_CAST_START",
					dur = 11.5,
					threshold = 65,
				},
			},
		},
		{ -- 酸蚀喷发
			spells = {
				{449734, "5,6"},
			},
			options = {
				{ -- 计时条 酸蚀喷发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 449734,
					ficon = "6",
					sound = "[interrupt_cast]cast",
				},
			},
		},
		{ -- 喷射丝线
			spells = {
				{434089},
			},
			options = {
				{ -- 文字 喷射丝线 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 434089,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							["all"] = {
								[2] = {13.3, 34.9, 30.3, 32.6, 32.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 434089, L["放圈"], self, event, ...)
					end,
				},
				{ -- 计时条 喷射丝线（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 434089,
					text = L["放圈"],
				},
				{ -- 声音 喷射丝线（✓）
					category = "Sound",
					spellID = 434090,
					sub_event = "SPELL_AURA_APPLIED",
					private_aura = true,
					file = "[1273\\439783aura]"
				},
				{ -- 图标 喷射丝线（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434113,	
					tip = L["DOT"],
					sound = "[move]",
				},
				{ -- 图标 粘性蛛网（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 434096,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 粘稠迸发
			spells = {
				{435793, "0"},
			},
			options = {
				{ -- 文字 粘稠迸发 近战位无人提示（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(435793)..L["近战无人"],
					data = {
						spellID = 435793,
						events = {
							["UNIT_SPELLCAST_SUCCEEDED"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 435793 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(435793)..L["近战无人"])
							end
						end
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
					sub_event = "SPELL_INTERRUPT",
					extraSpellID = 449734, -- 酸蚀喷发
				},				
			},
		},
	},
}