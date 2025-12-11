local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2454] = {
	engage_id = 2441,
	npc_id = {"176555", "176556", "176705"},
	alerts = {
		{ -- 阿尔克鲁克斯:暴食
			npcs = {
				{23159},
			},
			spells = {
				{349627},
			},
			options = {
				{ -- 计时条 暴食（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 349627,
					show_tar = true,
				},
				{ -- 图标 暴食（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 349627,
					msg = {str_applied = "{rt1}%spell %name"},
				},
				{ -- 首领模块 暴食 计时圆圈（✓）
					category = "BossMod",
					spellID = 349627,
					name = T.GetIconLink(349627)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[349627] = { -- 暴食
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
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
				{ -- 图标 暴食盛宴（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350013,
					tip = L["DOT"],
				},
			},
		},
		{ -- 阿尔克鲁克斯:饥饿之握
			npcs = {
				{23159},
			},
			spells = {
				{349663},
			},
			options = {
				{ -- 文字 饥饿之握 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 349663,
						events = {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {11.8, 23.1, 29.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 349663, L["拉人"], self, event, ...)
					end,
				},
				{ -- 计时条 饥饿之握（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 349663,
					sound = "[outcircle]cast,cd3",
					text = L["大圈"],
				},
			},
		},
		{ -- 阿尔克鲁克斯:饕餮吞噬
			npcs = {
				{23159},
			},
			spells = {
				{349797},
			},
			options = {		
				{ -- 计时条 饕餮吞噬（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 349797,
					sound = "[dodge_circle]cast",
				},
				{ -- 计时条 饕餮吞噬（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_SUCCESS",
					spellID = 349797,
					dur = 6,
					group = 1,
					tags = {4},
					glow = true,
				},
			},
		},
		{ -- 阿喀琉忒:排风协议
			npcs = {
				{23231},
			},
			spells = {
				{349987},
			},
			options = {
				{ -- 文字 排风协议 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["宝珠"]..L["倒计时"],
					data = {
						spellID = 349987,
						events = {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if cast_GUID and cast_spellID == 181089 then -- Encounter Event
								local npcID = T.GetUnitNpcID(unit)
								if npcID == "176555" then
									T.Start_Text_DelayTimer(self, 22, L["宝珠"], true)
								end
							end
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if cast_GUID and cast_spellID == 349987 then -- 排风协议
								T.Start_Text_DelayTimer(self, 26.7, L["宝珠"], true)
							end
						end
					end,
				},
				{ -- 计时条 排风协议（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 349987,
					sound = "[orb]cast",
				},
				{ -- 图标 心能引爆（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 349999,
					tip = L["降低伤害"].."%s5%",
				},
				{ -- 图标 被吞噬的心能（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350010,
					tip = L["增加伤害"].."%s5%",
				},
				{ -- 图标 腐蚀心能（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350045,
					hl = "red",
					tip = L["强力DOT"],
				},
				{ -- 团队框架高亮 腐蚀心能（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 350045,
					color = "red",
				},
			},
		},
		{ -- 阿喀琉忒:狂热鞭笞协议
			npcs = {
				{23231},
			},
			spells = {
				{349934},
			},
			options = {
				{ -- 文字 狂热鞭笞协议 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(349934)..L["倒计时"],
					data = {
						spellID = 349934,
						events = {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2] = {13.4, 23.1, 23.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 349934, T.GetIconLink(349934), self, event, ...)
					end,
				},
				{ -- 打坦计时条 狂热鞭笞协议（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 349934,
					group = 1,
					ficon = "0",
					sound = "[minddefense]cast",
				},
				{ -- 图标 狂热鞭笞协议（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 349934,
					hl = "red",
					tip = L["强力DOT"],
				},
			},
		},
		{ -- 阿喀琉忒:净化协议
			npcs = {
				{23231},
			},
			spells = {
				{349954},
			},
			options = {
				{ -- 文字 净化协议 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["分散"]..L["倒计时"],
					data = {
						spellID = 349954,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[2] = {4.7, 24.3, 26.7},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 349954, L["分散"], self, event, ...)
					end,
				},
				{ -- 计时条 净化协议（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 349954,
					sound = "[spread]cast",
					text = L["分散"],
				},
				{ -- 首领模块 净化协议 计时圆圈（✓）
					category = "BossMod",
					spellID = 349954,
					name = T.GetIconLink(349954)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[349954] = { -- 净化协议
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
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
				{ -- 自保技能提示 净化协议（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 349954,
					threshold = 65,
				},
				{ -- 团队框架高亮 净化协议（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 349954,
					color = "blu",
				},
				{ -- 驱散提示音 净化协议（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 349954,
					file = "[dispel]",
					ficon = "7",
				},
			},
		},
		{ -- 雯扎·金线:歼灭螺旋
			npcs = {
				{23241},
			},
			spells = {
				{350090, "4"},
			},
			options = {
				{ -- 文字 歼灭螺旋 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 350086,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[3] = {15.5, 30.3, 30.4},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 350086, L["拉人"], self, event, ...)
					end,
				},
				{ -- 计时条 歼灭螺旋（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 350086,
					sound = "[pull]cast",
					text = L["拉人"],
				},
			},
		},
		{ -- 雯扎·金线:诅咒锁链
			npcs = {
				{23241},
			},
			spells = {
				{350101},
			},
			options = {
				{ -- 文字 诅咒锁链 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["救人"]..L["倒计时"],
					data = {
						spellID = 350101,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[3] = {4.5, 21.9, 29.1, 30.4},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 350101, L["救人"], self, event, ...)
					end,
				},
				{ -- 计时条 诅咒锁链（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 350101,	
					text = L["定身"],
					show_tar = true,
					sound = "[rescue]cast",
				},
				{ -- 团队框架图标 诅咒锁链（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 350101,
				},
				{ -- 图标 诅咒锁链（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 350101,
					hl = "red",
					tip = L["定身"],
				},
				{ -- 团队框架高亮 诅咒锁链（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 350101,
					color = "red",
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
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 181089, -- Encounter Event
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_CAST_SUCCESS",
					spellID = 181089, -- Encounter Event
					count = 3,
				},				
			},
		},
	},	
}

