local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[391] = {2437, 2454, 2436, 2452, 2451, "c391"}

local function soundfile(filename, arg)
	return string.format("[c391\\%s]%s", filename, arg or "")
end
--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c391"] = {
	map_id = 2441,
	alerts = {
		{ -- 海关保安:干扰手雷
			spells = {
				{355900},
			},
			options = {
				T.Temp_CLEUSound(355900, "SPELL_CAST_SUCCESS", "[dodge_circle]"),
			},
		},
		{ -- 大门看护者佐·马兹:代理打击(装甲监工)
			spells = {
				{351047},
			},
			options = {
				T.Temp_TankCastBar(352796, "[minddefense]cast"),
			},
		},
		{ -- 大门看护者佐·马兹:辐射脉冲(传送门操控师佐·霍恩)
			spells = {
				{438599},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 辐射脉冲（✓）
					category = "BossMod",
					spellID = 356548,
					name = T.GetIconLink(356548)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["178392"] = {
								engage_cd = 13.3,
								cast_cd = 25.5,
								cast_gap = 5,
							},
							["179334"] = {
								engage_cd = 27.1,
								cast_cd = 27.1,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 356548
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						
						T.InitMobCooldownText(frame)						
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
				T.Temp_ImportantCastBar(356548, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_DoTIcon(356548),
			},
		},
		{ -- 传送门操控师佐·霍恩:裂隙冲击
			spells = {
				{352390},
			},
			options = {
				T.Temp_NormalCastBar(352390, {
					text = L["射线"],
					sound = "[ray]cast",
				}),
			},
		},
		{ -- 传送门操控师佐·霍恩:强化约束雕文
			spells = {
				{356537},
			},
			options = {
				T.Temp_ImportantInterruptBar(356537),
				T.Temp_PlateInterrupt(356537, "179334", 1),
				T.Temp_ImportantDebuffIcon(356324, "blu", L["减速"].."+"..L["强力DOT"], {
					ficon = "7",
				}),
				T.Temp_RaidAuraGlow(356324, "blu"),
				T.Temp_DispelDebuffSound(356324, "7"),
			},
		},
		{ -- 审讯专员:约束雕文
			spells = {
				{355915},
			},
			options = {			
				T.Temp_ImportantDebuffIcon(355915, "blu", L["减速"].."+"..L["强力DOT"], {
					ficon = "7",
				}),
				T.Temp_RaidAuraGlow(355915, "blu"),
				T.Temp_DispelDebuffSound(355915, "7"),
			},
		},
		{ -- 支援警官:凌光箭(专心的祭师，宏图)
			spells = {
				{354297},
			},
			options = {
				T.Temp_SubInterruptBar(354297, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(354297, "177817,180431", 2),
				T.Temp_ComIcon(354297),
				T.Temp_RaidCastIcon(354297),
			},
		},
		{ -- 支援警官:强光屏障
			spells = {
				{355934},
			},
			options = {		
				T.Temp_ImportantInterruptBar(355934),
				T.Temp_PlateInterrupt(355934, "177817", 1),
				T.Temp_PlateAura(355980),
				T.Temp_DispelBuffSound(355980, "7"),
			},
		},
		{ -- 装甲监工:光线切分者(追踪者佐·刻斯)
			spells = {
				{356001},
			},
			options = {
				T.Temp_NormalCastBar(356001, {
					text = L["陷阱"],
					sound = "[mindstep]cast",
				}),
				T.Temp_ImportantDebuffIcon(356011, "red", L["强力DOT"], {
					sound = "[defense]",
				}),
				T.Temp_RaidAuraGlow(356011, "red"),
				T.Temp_HPWatchAura(356011, nil, 75),
			},
		},		
		{ -- 追踪者佐·刻斯:封锁
			spells = {
				{356942},
			},
			options = {
				T.Temp_RaidCastIcon(356942),
				T.Temp_DispelDebuffCastSound(356942, "7"),
				T.Temp_ImportantDebuffIcon(356943, "blu", L["定身"].."+"..L["强力DOT"], {
					ficon = "7",
				}),
				T.Temp_RaidAuraGlow(356943, "blu"),
			},
		},
		{ -- 上古熔火恶犬:熔岩吐息
			spells = {
				{356404},
			},
			options = {
				T.Temp_NormalCastBar(356404, {
					sound = "[dodge]cast",
				}),				
			},
		},
		{ -- 上古熔火恶犬:上古恐慌
			spells = {
				{356407},
			},
			options = {
				T.Temp_NormalInterruptBar(356407),
				T.Temp_PlateInterrupt(356407, "180091", 1),
			},
		},
		{ -- 狂乱的夜爪豹:狂乱割裂
			spells = {
				{357827},
			},
			options = {
				T.Temp_BigDoTIcon(357827, "13", "red"),
				T.Temp_DispelDebuffSound(357827, "13"),
				T.Temp_RaidAuraGlow(357827, "red"),
			},
		},
		{ -- 暴怒的恐角龙:狂暴冲锋
			spells = {
				{357512},
			},
			options = {	
				T.Temp_ImportantCastBar(357512, {
					show_tar = true,
					sound = "[mindcharge]cast",
				}),
				T.Temp_ComIcon(357512, {
					msg = {str_applied = "%name %spell"},
					sound = "[spread]cast",
				}),
				{ -- 首领模块 狂暴冲锋 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 357512,
					name = T.GetIconLink(357512)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[357512] = {		
								color = {1, 1, 0},
							},
						}
						T.InitCircleCastTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleCastTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleCastTimers(frame)
					end,
				},
			},
		},
		{ -- 暴怒的恐角龙:狂野鞭笞 
			spells = {
				{357508},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 狂野鞭笞（✓）
					category = "BossMod",
					spellID = 357508,
					name = T.GetIconLink(357508)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["180495"] = {
								engage_cd = 17,
								cast_cd = 26.5,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 357508
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["近战AOE"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						
						T.InitMobCooldownText(frame)						
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
				T.Temp_ImportantCastBar(357508, {
					sound = "[meleeaoe]cast",
				}),
			},
		},
		{ -- 集市维和者:重装方阵
			spells = {
				{355640},
			},
			options = {
				T.Temp_PlateAura(355640),
			},
		},
		{ -- 贸易执行者:强力脚踢(指挥官佐·法)
			spells = {
				{355477},
			},
			options = {	
				T.Temp_TankCastBar(355477, "[knockback]cast"),
			},
		},
		{ -- 贸易执行者:力量增幅器
			spells = {
				{1244443},
			},
			options = {	
				T.Temp_NormalCastBar(1244443),
			},
		},
		{ -- 老练的火花法师:凌光齐射
			spells = {
				{355642},
			},
			options = {	
				T.Temp_ImportantInterruptBar(355642),
				T.Temp_PlateInterrupt(355642, "179841", 1),
			},
		},
		{ -- 老练的火花法师:闪烁
			spells = {
				{355641},
			},
			options = {	
				T.Temp_ImportantDebuffIcon(355641, "blu", L["易伤"], {
					ficon = "7",
				}),
				T.Temp_RaidAuraGlow(355641, "blu"),
				T.Temp_DispelDebuffSound(355641, "7"),
			},
		},		
		{ -- 指挥官佐·法:致命武力
			spells = {
				{355479},
			},
			options = {
				T.Temp_ImportantCastBar(355479, {
					text = L["连线"],
					sound = "[chain]cast",
				}),
				{ -- 首领模块 致命武力 计时圆圈（✓）
					category = "BossMod",
					spellID = 355480,
					name = T.GetIconLink(355480)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[355480] = { -- 致命武力
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 1, 0},
								sound = "chainonyou",
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
				T.Temp_BigDoTIcon(355487, "7", "red"),
				T.Temp_RaidAuraGlow(355487, "red"),
			},
		},
		{ -- 指挥官佐·法:震荡地雷
			spells = {
				{355473},
			},
			options = {			
				T.Temp_NormalCastBar(355473, {
					sound = "[mindstep]cast",
				}),
			},
		},
		{ -- 财团打手:凌光反打
			spells = {
				{356967},
			},
			options = {				
				T.Temp_TankCastBar(356967, "[knockback]cast"),
			},
		},
		{ -- 财团打手:时空光线强化器
			spells = {
				{357229},
			},
			options = {
				T.Temp_NormalCastBar(357229, {
					ficon = "7",
					text = L["增加伤害"],
				}),
				T.Temp_PlateAura(357229),
			},
		},
		{ -- 财团智囊:光尘闪回
			spells = {
				{357197},
			},
			options = {
				T.Temp_CLEUSound(357197, "SPELL_CAST_SUCCESS", "[outcircle]"),			
			},
		},
		{ -- 财团智囊:凌光箭
			spells = {
				{357196},
			},
			options = {
				T.Temp_SubInterruptBar(357196, { -- 凌光箭（✓）
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(357196, "180336", 2),
				T.Temp_ComIcon(357196),
				T.Temp_RaidCastIcon(357196),
			},
		},
		{ -- 财团潜伏者:迅斩
			spells = {
				{355830},
			},
			options = {
				T.Temp_ComIcon(355830, {
					msg = {str_applied = "%name %spell"},
				}),
				T.Temp_RaidCastIcon(355830),
				T.Temp_BigDoTIcon(355832, "13", "red"),
				T.Temp_DispelDebuffSound(355832, "13"),
				T.Temp_RaidAuraGlow(355832, "red"),
				T.Temp_HPWatchAura(355832),
			},
		},
		{ -- 财团走私者:凌光炸弹
			spells = {
				{357029},
			},
			options = {
				T.Temp_ImportantDebuffIcon(357029, "blu", L["炸弹"], {
					ficon = "7",
				}),
				T.Temp_DispelDebuffSound(357029, "7"),
				T.Temp_RaidAuraGlow(357029, "blu"),
			},
		},
		{ -- P.O.S.T.工人:开信刀
			spells = {
				{347716},
			},
			options = {
				T.Temp_TankCastBar(347716, "[minddefense]cast"),
				T.Temp_DoTIcon(347716, "13", "red"),
				T.Temp_DispelDebuffSound(347716, "13", 2, "[dispel]"),
				T.Temp_RaidAuraGlow(347716, "red", 2),
			},
		},
		{ -- 损坏的分拣机:打开牢笼
			spells = {
				{347721},
			},
			options = {
				T.Temp_NormalCastBar(347721),
			},
		},
		{ -- 过载的邮件元素:垃圾信息过滤
			spells = {
				{347775},
			},
			options = {				
				T.Temp_NormalInterruptBar(347775), -- 垃圾信息过滤（✓）
				T.Temp_PlateInterrupt(347775, "176395", 2),
				T.Temp_PlateAura(347775),
				T.Temp_DispelBuffSound(347775, "7"),
			},
		},
		{ -- 过载的邮件元素:垃圾邮件
			spells = {
				{347903},
			},
			options = {
				T.Temp_NormalInterruptBar(347903, { -- 垃圾邮件（✓）
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_ComIcon(347903),
				T.Temp_RaidCastIcon(347903),
			},
		},
		{ -- 卖场铁腕战士:静电之锤
			spells = {
				{358919},
			},
			options = {
				T.Temp_ImportantDebuffIcon(351960, "blu", L["减速"].."%s10%", {
					ficon = "7",
				}),
				T.Temp_RaidAuraGlow(351960, "blu", 3),
				T.Temp_DispelDebuffSound(351960, "7", 3),
			},
		},
		{ -- 集市监督者:充能猛击 
			spells = {
				{1240821},
			},
			options = {
				T.Temp_NormalCastBar(1240821, {
					sound = "[spread]cast",
				}),
				{ -- 首领模块 充能猛击 计时圆圈（✓）
					category = "BossMod",
					spellID = 1240820,
					name = T.GetIconLink(1240820)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1240820] = { -- 充能猛击
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
			},
		},
		{ -- 集市监督者:穿刺
			spells = {
				{1240912},
			},
			options = {
				T.Temp_TankCastBar(1240912, "[minddefense]cast"),
				T.Temp_ImportantDebuffIcon(1240912, "red", L["易伤"].."20%"),
			},
		},
	},
}