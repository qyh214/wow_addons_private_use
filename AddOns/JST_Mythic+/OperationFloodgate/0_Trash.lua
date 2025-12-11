local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[525] = {2648, 2649, 2650, 2651, "c525"}

local function soundfile(filename, arg)
	return string.format("[c525\\%s]%s", filename, arg or "")
end
--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c525"] = {
	map_id = 2773,
	alerts = {
		{ -- 幽暗爬行者:昏睡毒液 
			spells = {
				{465813},
			},
			options = {
				T.Temp_ImportantDebuffIcon(465813, "gre", L["减速"].."40%", {
					ficon = "9",
				}),
				T.Temp_RaidAuraGlow(465813, "gre"),
				T.Temp_DispelDebuffSound(465813, "9"),
			},
		},
		{ -- 暗索士兵:黑血创伤
			spells = {
				{462737},
			},
			options = {
				T.Temp_DoTIcon(462737, "7", "blu"),
				T.Temp_DispelDebuffSound(462737, "7", 5),
				T.Temp_RaidAuraGlow(462737, "blu", 5),
			},
		},
		{ -- 无人机狙击手:狙击
			spells = {
				{464655},
			},
			options = {
				T.Temp_SubInterruptBar(464655, {
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_ComIcon(464655),
				T.Temp_RaidCastIcon(464655),
			},
		},
		{ -- 无人机狙击手:特技射击
			spells = {
				{1214468},
			},
			options = {
				T.Temp_SubInterruptBar(1214468, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(1214468, "229069", 2),
				T.Temp_RaidCastIcon(1214468),
			},
		},
		{ -- 撕碎王3000型:碎切
			spells = {
				{474337},
			},
			options = {
				T.Temp_ImportantCastBar(474337, {
					sound = "[change_pos]cast,cd2",
				}),
				T.Temp_OnFireIcon(474351),
			},
		},
		{ -- 撕碎王3000型:火焰喷射器
			spells = {
				{465754},
			},
			options = {
				T.Temp_NormalCastBar(465754, {
					sound = "[avoidfront]cast",
				}),
				T.Temp_OnFireIcon(474388),
			},
		},
		{ -- 载货机器人:上紧发条
			spells = {
				{465120},
			},
			options = {
				T.Temp_NormalInterruptBar(465120, {
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_ImportantDebuffIcon(465120, "red_flash", L["锁定"], {
					sound = "[focusyou]",
				}),
				T.Temp_PlateAuraSourceGlow(465120),
			},
		},
		{ -- 风险投资公司勘探员:“易投”炸弹 III
			spells = {
				{463169},
			},
			options = {
				T.Temp_SubInterruptBar(463169, {
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_ComIcon(463169),
				T.Temp_RaidCastIcon(463169),
			},
		},
		{ -- 风险投资公司勘探员:勘测光束
			spells = {
				{462771},
			},
			options = {
				T.Temp_NormalInterruptBar(462771, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(462771, "229686", 2),
				T.Temp_RaidCastIcon(462771),
				T.Temp_BigDoTIcon(462771, nil, "red"),
				T.Temp_HPWatchAura(462771, nil, 70),
				T.Temp_RaidAuraGlow(462771, "red"),
				T.Temp_OnFireIcon(472338),
			},
		},
		{ -- 风险投资公司建筑师:射钉枪
			spells = {
				{1213805},
			},
			options = {
				T.Temp_SubInterruptBar(1213805, {
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_ComIcon(1213805),
				T.Temp_RaidCastIcon(1213805),
				T.Temp_DoTIcon(1213803, "13", "red"),
				T.Temp_HPWatchAura(1213803),
				T.Temp_RaidAuraGlow(1213803, "red"),
			},
		},
		{ -- 风险管理公司潜水员:鱼叉
			spells = {
				{468631},
			},
			options = {
				T.Temp_NormalInterruptBar(468631, {
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_BigDoTIcon(468631, "13", "red"),
				T.Temp_HPWatchAura(468631, nil, 75),
				T.Temp_RaidAuraGlow(468631, "red"),
			},
		},
		{ -- 风险管理公司潜水员:安放爆盐炸弹
			spells = {
				{468726},
			},
			options = {
				T.Temp_NormalCastBar(468726, {
					sound = "[bomb]cast",
				}),
			},
		},
		{ -- 暗索爆破手:R.P.G.G.
			spells = {
				{1216039},
				{461796},
			},
			options = {
				T.Temp_NormalCastBar(1216039, {
					sound = "[dodge_circle]cast",
				}),
				T.Temp_NormalInterruptBar(461796, { -- 重新装填
					ficon = "14",
				}),
			},
		},
		{ -- 暗索扭血者:鲜血冲击
			spells = {
				{465871},
			},
			options = {
				T.Temp_SubInterruptBar(465871, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(465871, "230748", 3),
				T.Temp_RaidCastIcon(465871),
			},
		},
		{ -- 暗索扭血者:扭曲精华
			spells = {
				{465827},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 扭曲精华（✓）
					category = "BossMod",
					spellID = 465827,
					name = T.GetIconLink(465827)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["230748"] = {
								engage_cd = 5.9,
								cast_cd = 19.4,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 465827
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
				T.Temp_ImportantCastBar(465827, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(465827, "SPELL_CAST_START", 8.5),
				T.Temp_DoTIcon(465830),				
			},
		},
		{ -- 爆壳螃蟹:钳夹
			spells = {
				{468672},
			},
			options = {
				T.Temp_ComIcon(468672),
				T.Temp_NormalDebuff(468672, L["减速"].."%s10%", {
					hl = "",
				}),
			},
		},
		{ -- 爆壳螃蟹:炸蟹
			spells = {
				{468680},
			},
			options = {
				T.Temp_DoTIcon(468680, nil, "red_flash"),
				T.Temp_HPWatchAura(468680, 2),				
			},
		},
		{ -- 被惊扰的海藻:回春水藻
			spells = {
				{471733},
			},
			options = {
				T.Temp_SubInterruptBar(471733),
				T.Temp_PlateInterrupt(471733, "231223", 2),
			},
		},
		{ -- 被惊扰的海藻:投弃海藻
			spells = {
				{471736},
			},
			options = {
				T.Temp_NormalInterruptBar(471736, {
					ficon = "14",
				}),
			},
		},
		{ -- 暗索调查员:突击调查
			spells = {
				{465682},
			},
			options = {
				T.Temp_NormalCastBar(465682, {
					sound = "[dodge]cast",
				}),
			},
		},
		{ -- 风险投资公司电工:闪电箭
			spells = {
				{465595},
			},
			options = {
				T.Temp_SubInterruptBar(465595, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(465595, "231312", 3),
				T.Temp_ComIcon(465595),				
				T.Temp_RaidCastIcon(465595),
			},
		},
		{ -- 风险投资公司电工:过载
			spells = {
				{469799},
			},
			options = {				
				T.Temp_DoTIcon(469799, "7", "blu"),
				T.Temp_DispelDebuffSound(469799, "7"),
				T.Temp_RaidAuraGlow(469799, "blu"),
			},
		},
		{ -- 暗索接线者:火花猛击
			spells = {
				{465666},
			},
			options = {
				T.Temp_TankCastBar(465666, "[minddefense]cast"),
			},
		},
		{ -- 暗索接线者:电池释能
			spells = {
				{465603},
			},
			options = {
				{ -- 首领模块 计时条 电池释能（✓）
					category = "BossMod",
					spellID = 465603,
					name = string.format(L["计时条%s"], T.GetIconLink(465603)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,	
					},
					init = function(frame)
						frame.bars = {}
						
						function frame:hide_all()
							for i, bar in pairs(frame.bars) do
								T.StopTimerBar(bar, true, true)
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if unit and cast_GUID and cast_spellID and cast_spellID == 465603 then -- 电池释能
								local GUID = UnitGUID(unit)
								if not frame.bars[GUID] then
									
									frame.bars[GUID] = T.CreateAlertBarShared(2, "bossmod"..frame.config_id.."-"..GUID, C_Spell.GetSpellTexture(465603), L["躲圈"], T.GetSpellColor(465603))
									frame.bars[GUID].prepare_sound = "dodge_circle"
									frame.bars[GUID].count_down_start = 3
								end
								if not frame.bars[GUID]["exp_time"] or frame.bars[GUID]["exp_time"] - GetTime() < 2 then
									T.StartTimerBar(frame.bars[GUID], 3, true, true)
								end
							end
						end
					end,
					reset = function(frame, event)
						frame:hide_all()
					end,
				},
			},
		},
	},
}