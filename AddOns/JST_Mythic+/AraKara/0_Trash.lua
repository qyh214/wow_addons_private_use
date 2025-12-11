local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[503] = {2583, 2584, 2585, "c503"}

local function soundfile(filename)
	return string.format("[c503\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c503"] = {
	map_id = 2660,
	alerts = {
		{ -- 啊呃！
			spells = {
				{436401},
			},
			options = {
				T.Temp_DoTIcon(436401, "13", "red"),
				T.Temp_RaidAuraGlow(436401, "red", 3),
			},
		},
		{ -- 戳刺飞虫:放血戳刺
			spells = {
				{438599},
			},
			options = {
				T.Temp_DoTIcon(438599, "13", "red"),
				T.Temp_RaidAuraGlow(438599, "red", 2),
			},
		},
		{ -- 颤声侍从:蛛网箭（纳克特 伊克辛 沾血的网法师）
			spells = {
				{434786},
			},
			options = {				
				T.Temp_SubInterruptBar(434786, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(434786, "216293,218324,217531,223253", 2),
				T.Temp_ComIcon(434786),
				T.Temp_RaidCastIcon(434786),
			},
		},
		{ -- 颤声侍从:共振弹幕
			spells = {
				{434793},
			},
			options = {
				T.Temp_NormalInterruptBar(434793, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(434793, "216293", 1),
			},
		},
		{ -- 充血的爬行者:毒性喷吐
			spells = {
				{438618},
			},
			options = {				
				T.Temp_DoTIcon(438618, "9", "gre"),
				T.Temp_RaidAuraGlow(438618, "gre", 2),
				T.Temp_DispelDebuffSound(438618, "9", 2),				
			},
		},
		{ -- 阿提克:蛛网喷射（纳克特 伊克辛）
			spells = {
				{434824},
			},
			options = {				
				T.Temp_NormalCastBar(434824, {	
					sound = "[dodge]cast",
				}),
			},
		},
		{ -- 阿提克:毒液箭
			spells = {
				{436322},
			},
			options = {				
				T.Temp_ImportantInterruptBar(436322, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(436322, "217533", 2),
				T.Temp_BigDoTIcon(436322, "9", "gre"),
				T.Temp_RaidAuraGlow(436322, "gre"),
			},
		},
		{ -- 阿提克:毒云
			spells = {
				{438826},
			},
			options = {				
				T.Temp_NormalCastBar(438826, {	
					sound = "[dodge_circle]cast",
				}),
				T.Temp_OnFireIcon(438825),
			},
		},
		{ -- 纳克特:巢穴的召唤
			spells = {
				{438877},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 巢穴的召唤（✓）
					category = "BossMod",
					spellID = 438877,
					name = T.GetIconLink(438877)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["218324"] = {
								engage_cd = 9,
								cast_cd = 23,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 438877
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
				T.Temp_ImportantCastBar(438877, {
					text = L["全团AE"],
					sound = "[aoe]cast",
					spellIDs = {438883},
				}),
				T.Temp_HPWatchCLEU(438877, "SPELL_CAST_START", 4, 75),
			},
		},
		{ -- 伊克辛:惊惧尖鸣
			spells = {
				{434802},
			},
			options = {
				T.Temp_ImportantInterruptBar(434802),
				T.Temp_PlateInterrupt(434802, "217531", 1),
			},
		},
		{ -- 沾血的助手:深掘打击
			spells = {
				{433002},
			},
			options = {			
				T.Temp_ComIcon(433002),
			},
		},
		{ -- 沾血的网法师:恶臭齐射
			spells = {
				{448248},
			},
			options = {				
				T.Temp_ImportantInterruptBar(448248),
				T.Temp_PlateInterrupt(448248, "223253", 2),
				T.Temp_BigDoTIcon(448248, "9", "gre"),
				T.Temp_DispelDebuffSound(448248, "9"),
			},
		},
		{ -- 魁梧的血卫:穿刺
			spells = {
				{453161},
			},
			options = {
				T.Temp_NormalCastBar(453161, {	
					sound = "[dodge]cast",
				}),
			},
		},
		{ -- 魁梧的血卫:虫群风暴
			spells = {
				{1241693},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 虫群风暴（✓）
					category = "BossMod",
					spellID = 1241693,
					name = T.GetIconLink(1241693)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["216338"] = {
								engage_cd = 5,
								cast_cd = 30.2,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 1241693
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
				T.Temp_ImportantCastBar(1241693, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(1241693, "SPELL_CAST_START", 10),
				T.Temp_DoTIcon(1241694),
			},
		},		
		{ -- 哨兵鹿壳虫:预警尖鸣
			spells = {
				{432967},
			},
			options = {
				T.Temp_ImportantInterruptBar(432967, { -- 预警尖鸣（✓）
					ficon = "14",
				}),
				T.Temp_PlateCastGlow(432967),
			},
		},
		{ -- 鲜血监督者:爆发蛛网
			spells = {
				{433845},
			},
			options = {
				T.Temp_NormalCastBar(433845, {	
					sound = "[mindstep]cast",
				}),
			},
		},
		{ -- 鲜血监督者:毒液箭雨
			spells = {
				{433841},
			},
			options = {
				T.Temp_ImportantInterruptBar(433841),
				T.Temp_PlateInterrupt(433841, "216364", 2),
				T.Temp_BigDoTIcon(433841, "9", "gre"),
				T.Temp_DispelDebuffSound(433841, "9"),
			},
		},
		{ -- 强化雄虫:污血
			spells = {
				{1241785},
			},
			options = {
				T.Temp_DoTIcon(1241785, "7", "blu"),
				T.Temp_RaidAuraGlow(1241785, "blu", 10),
				T.Temp_DispelDebuffSound(1241785, "7", 10),
			},
		},
		{ -- 血腥迷瘴
			spells = {
				{439832},
			},
			options = {
				T.Temp_OnFireIcon(439832),
			},
		},	
	},
}