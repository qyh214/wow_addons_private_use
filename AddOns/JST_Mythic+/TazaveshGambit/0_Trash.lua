local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[392] = {2448, 2449, 2455, "c392"}

local function soundfile(filename, arg)
	return string.format("[c392\\%s]%s", filename, arg or "")
end
--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c392"] = {
	map_id = 2441,
	alerts = {
		{ -- 浊盐碎壳者:破壳猛击
			spells = {
				{355048},
			},
			options = {				
				T.Temp_TankCastBar(355048, "[knockback]cast"),
			},
		},
		{ -- 浊盐碎壳者:鱼人战吼
			spells = {
				{355057},
			},
			options = {
				T.Temp_ImportantInterruptBar(355057),
				T.Temp_PlateInterrupt(355057, "178139", 2),
			},
		},
		{ -- 浊盐缚鳞者:活力鱼串
			spells = {
				{355132},
			},
			options = {
				T.Temp_PlateNpcGlow("179733"),
			},
		},
		{ -- 浊盐鱼术师:不稳定的河豚
			spells = {
				{355234},
			},
			options = {
				T.Temp_CLEUSound(355234, "SPELL_CAST_SUCCESS", "[outcircle]"),
			},
		},
		{ -- 浊盐鱼术师:水箭
			spells = {
				{355225},
			},
			options = {
				T.Temp_SubInterruptBar(355225, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(355225, "178142", 2),
				T.Temp_ComIcon(355225),
				T.Temp_RaidCastIcon(355225),
			},
		},
		{ -- 踏滨巨人:投掷巨石
			spells = {
				{355464},
			},
			options = {
				T.Temp_NormalCastBar(355464, {
					sound = "[mindstep]cast",
				}),
			},
		},
		{ -- 踏滨巨人:海潮践踏
			spells = {
				{355429},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 海潮践踏（✓）
					category = "BossMod",
					spellID = 355429,
					name = T.GetIconLink(355429)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["178165"] = {
								engage_cd = 12,
								cast_cd = 22.7,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 355429
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
				T.Temp_ImportantCastBar(355429, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(355429, "SPELL_CAST_START", 2, 80),
			},
		},
		{ -- 雷铸守护者:充能脉冲
			spells = {
				{355584},
			},
			options = {
				T.Temp_NormalCastBar(355584, {
					sound = "[outcircle]cast",
				}),
			},
		},
		{ -- 雷铸守护者:连环爆裂
			spells = {
				{355577},
			},
			options = {
				T.Temp_NormalCastBar(355577, {
					sound = "[mindstep]cast",
				}),
				T.Temp_OnFireIcon(355581),
			},
		},
		{ -- 时沙号海潮贤者:盐渍飞弹
			spells = {
				{356843},
			},
			options = {
				T.Temp_NormalInterruptBar(356843, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(356843, "179388", 2),
				T.Temp_ComIcon(356843),
				T.Temp_RaidCastIcon(356843),
			},
		},
		{ -- 肌肉虬结的水手:超级塞松啤酒
			spells = {
				{356133},
			},
			options = {
				T.Temp_NormalInterruptBar(356133, {
					ficon = "14",
				}),
				T.Temp_PlateAura(356133),
			},
		},
		{ -- 专心的祭师:不稳定的裂隙
			spells = {
				{357260},
			},
			options = {
				T.Temp_ImportantInterruptBar(357260),
				T.Temp_PlateInterrupt(357260, "180431", 1),
			},
		},
		{ -- 盛装的星辰先知:游移之星
			spells = {
				{357226},
			},
			options = {
				T.Temp_NormalCastBar(357226, {
					sound = "[frontal]cast",
				}),
			},
		},
		{ -- 盛装的星辰先知:流浪的脉冲星
			spells = {
				{357238},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 流浪的脉冲星（✓）
					category = "BossMod",
					spellID = 357238,
					name = T.GetIconLink(357238)..L["召唤小怪"]..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["180429"] = {
								engage_cd = 13.1,
								cast_cd = 26.6,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 357238
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["召唤小怪"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						frame.sound_default = false
						
						T.InitMobCooldownText(frame)						
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
				T.Temp_NormalCastBar(357238, {
					sound = "[add]cast",
				}),
				T.Temp_PlateNpcGlow("180433"),
				{ -- 首领模块 流浪的脉冲星 玩家自保技能提示（✓）
					category = "BossMod",
					spellID = 357256,
					name = T.GetIconLink(357238)..L["玩家自保技能提示"],	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
						["GROUP_LEAVING_COMBAT"] = true
					},
					custom = {
						{
							key = "hp_perc_sl",
							text = L["血量阈值百分比"],
							default = 50,
							min = 10,
							max = 90,
						},
					},
					init = function(frame)
						frame.mobs = {}
						frame.mobsbyGUID = {}
						frame.check = false
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_SUMMON" and spellID == 357238 then -- 流浪的脉冲星
								table.insert(frame.mobs, destGUID)
								frame.mobsbyGUID[destGUID] = true
								if not frame.check then
									frame.check = true
									T.AddPersonalSpellCheckTag("bossmod"..frame.config_id, C.DB["BossMod"][frame.config_id]["hp_perc_sl"], {"TANK"})
								end
							elseif sub_event == "UNIT_DIED" and frame.mobsbyGUID[destGUID] then -- 裂变
								frame.mobsbyGUID[destGUID] = nil
								tDeleteItem(frame.mobs, destGUID)
								if #frame.mobs == 0 and frame.check then
									frame.check = false
									T.RemovePersonalSpellCheckTag("bossmod"..frame.config_id)
								end
							end
						elseif event == "GROUP_LEAVING_COMBAT" then
							frame.mobs = table.wipe(frame.mobs)
							frame.mobsbyGUID = table.wipe(frame.mobsbyGUID)
							frame.check = false
							T.RemovePersonalSpellCheckTag("bossmod"..frame.config_id)
						end
					end,
					reset = function(frame, event)
						frame.mobs = table.wipe(frame.mobs)
						frame.mobsbyGUID = table.wipe(frame.mobsbyGUID)
						frame.check = false
						T.RemovePersonalSpellCheckTag("bossmod"..frame.config_id)
					end,
				},
			},
		},
	},
}