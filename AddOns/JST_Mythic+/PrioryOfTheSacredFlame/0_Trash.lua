local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[499] = {2571, 2570, 2573, "c499"}

local function soundfile(filename, arg)
	return string.format("[c499\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c499"] = {
	map_id = 2649,
	alerts = {
		{ -- 阿拉希步兵:防御
			spells = {
				{427342},
			},
			options = {
				T.Temp_PlateAura(427342),
			},
		},
		{ -- 热诚的神射手:射击
			spells = {
				{427629},
			},
			options = {
				T.Temp_ComIcon(427629),
			},
		},
		{ -- 热诚的神射手:随意射击
			spells = {
				{462859},
			},
			options = {
				T.Temp_SubInterruptBar(462859, {
					show_tar = true,
					ficon = "14",
				}),
				T.Temp_ComIcon(462859),
				T.Temp_RaidCastIcon(462859),
			},
		},
		{ -- 热诚的神射手:铁蒺藜
			spells = {
				{453458},
			},
			options = {
				T.Temp_CLEUSound(453458, "SPELL_CAST_SUCCESS", "[mindstep]"),
				T.Temp_DoTIcon(453461, "13", "red"),
				T.Temp_HPWatchAura(453461),
				T.Temp_DispelDebuffSound(453461, "13"),
				T.Temp_RaidAuraGlow(453461, "red"),
			},
		},
		{ -- 阿拉希骑士:穿刺
			spells = {
				{444296},
			},
			options = {
				T.Temp_BigDoTIcon(427621, "13", "red"),
				T.Temp_HPWatchAura(427621),
				T.Temp_DispelDebuffSound(427621, "13"),
				T.Temp_RaidAuraGlow(427621, "red"),
			},
		},		
		{ -- 阿拉希骑士:瓦解怒吼
			spells = {
				{427609},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 瓦解怒吼（✓）
					category = "BossMod",
					spellID = 453810,
					name = T.GetIconLink(427609)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["206696"] = {
								engage_cd = 20.1,
								cast_cd = 21.8,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 427609
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
				{ -- 首领模块 计时条 瓦解怒吼（✓）
					category = "BossMod",
					spellID = 427609,
					name = string.format(L["计时条%s"], T.GetIconLink(427609)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_SPELLCAST_CHANNEL_START"] = true,
						["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
						["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
					},
					init = function(frame)
						local name = C_Spell.GetSpellName(427609)
						local icon = C_Spell.GetSpellTexture(427609)
						local color = T.GetSpellColor(427609)
						
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, name, color)
						frame.bar.glow:SetBackdropBorderColor(unpack(color))
						frame.bar.glow:Show()
						
						function frame:UpdateCastState(start)
							if self.cast_exp then
								if UnitCastingInfo("player") then
									local endTimeMS = select(5, UnitCastingInfo("player"))
									if endTimeMS < self.cast_exp then
										self.bar.mid:SetText(string.format("|cff00ff00%s|r", L["安全施法"]))
										T.PlaySound("safecasting")
									else
										self.bar.mid:SetText(string.format("|cffff0000%s|r", L["停止施法"]))
										T.PlaySound("stopcasting")
									end
								elseif UnitChannelInfo("player") then
									local endTimeMS = select(5, UnitChannelInfo("player"))
									if endTimeMS < self.cast_exp then
										self.bar.mid:SetText(string.format("|cff00ff00%s|r", L["安全施法"]))
										T.PlaySound("safecasting")
									else
										self.bar.mid:SetText(string.format("|cffff0000%s|r", L["停止施法"]))
										T.PlaySound("stopcasting")
									end
								else
									self.bar.mid:SetText("")
									if start then
										T.PlaySound("interruptcasting")
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit and cast_GUID and cast_spellID then
								if cast_spellID == 427609 and not frame.cast_exp then
									local startTimeMS, endTimeMS = select(4, UnitCastingInfo(unit))
									local cast_dur = (endTimeMS - startTimeMS)/1000
									T.StartTimerBar(frame.bar, cast_dur, true, true)
									frame.bar.anim:Play()
									frame.cast_exp = endTimeMS
									frame:UpdateCastState(true)
								elseif unit == "player" then
									frame:UpdateCastState()
								end
							end
						elseif event == "UNIT_SPELLCAST_STOP" then
							local unit, cast_GUID, cast_spellID = ...
							if unit and cast_GUID and cast_spellID then
								if cast_spellID == 427609 and frame.cast_exp then
									T.StopTimerBar(frame.bar, true, true)
									frame.bar.anim:Stop()
									frame.cast_exp = nil
								elseif unit == "player" then
									frame:UpdateCastState()
								end
							end
						elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
							local unit = ...
							if unit == "player" then
								frame:UpdateCastState()
							end
						elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
							local unit = ...
							if unit == "player" then
								frame:UpdateCastState()
							end
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
						frame.bar.anim:Stop()
						frame.cast_exp = nil
					end,
				},
				T.Temp_HPWatchCLEU(427609, "SPELL_CAST_START", 3, 75),
			},
		},
		{ -- 狂热的咒术师 亡灵法师 火球术
			spells = {
				{427469},
			},
			options = {
				T.Temp_SubInterruptBar(427469, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(427469, "206698,221760", 2),
				T.Temp_RaidCastIcon(427469),
			},
		},
		{ -- 狂热的咒术师:烈焰风暴
			spells = {
				{427484},
			},
			options = {
				T.Temp_NormalCastBar(427484, {
					sound = "[dodge_circle]cast",
				}),
			},
		},
		{ -- 虔诚的牧师:强效治疗术
			spells = {
				{427356},
			},
			options = {
				T.Temp_ImportantInterruptBar(427356),
				T.Temp_PlateInterrupt(427356, "206697", 1),
			},
		},
		{ -- 虔诚的牧师:神圣惩击
			spells = {
				{427357},
			},
			options = {
				T.Temp_SubInterruptBar(427357, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(427357, "206697,212827", 2),
				T.Temp_ComIcon(427357),
				T.Temp_RaidCastIcon(427357),				
			},
		},
		{ -- 作战山猫:飞扑 痛苦撕裂
			spells = {
				{446776},
				{427635},
			},
			options = {
				T.Temp_BigDoTIcon(427635, "13", "red"),
				T.Temp_HPWatchAura(427635),
				T.Temp_DispelDebuffSound(427635, "13"),
				T.Temp_RaidAuraGlow(427635, "red"),				
			},
		},	
		{ -- 高阶牧师艾姆雅:反射护盾
			spells = {
				{464240},
			},
			options = {
				T.Temp_ImportantCastBar(428150, {
					sound = "[reflect_shield]cast",
				}),
				T.Temp_PlateAura(428150),
			},
		},
		{ -- 守卫队长苏雷曼:盾牌猛击
			spells = {
				{448485},
			},
			options = {
				T.Temp_TankCastBar(448485, "[knockoff]cast"),
			},
		},
		{ -- 守卫队长苏雷曼:雷霆一击
			spells = {
				{448492},
			},
			options = {				
				{ -- 首领模块 小怪技能倒计时 雷霆一击（✓）
					category = "BossMod",
					spellID = 448492,
					name = T.GetIconLink(448492)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["212826"] = {
								engage_cd = 15.3,
								cast_cd = 15.8,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 448492
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
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
				T.Temp_NormalCastBar(448492, {
					sound = "[aoe]cast",
				}),
				T.Temp_NormalDebuff(448492, L["减速"].."50%"),				
			},
		},
		{ -- 铸炉大师达米安:烈焰圣印
			spells = {
				{427950},
			},
			options = {
				T.Temp_NormalCastBar(427950, {
					text = L["躲地板"],
					sound = "[mindstep]cast",
				}),
				T.Temp_OnFireIcon(427900),				
			},
		},
		{ -- 铸炉大师达米安:热浪
			spells = {
				{427897},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 热浪（✓）
					category = "BossMod",
					spellID = 427897,
					name = T.GetIconLink(427897)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["212831"] = {
								engage_cd = 5.6,
								cast_cd = 18.2,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 427897
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
				T.Temp_ImportantCastBar(427897, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(427897, "SPELL_CAST_START", 5, 75),
				T.Temp_NormalDebuff(427897, L["减速"].."70%", {
					ficon = "7",
					hl = "blu",
				}),
				T.Temp_RaidAuraGlow(427897, "blu"),
			},
		},
		{ -- 艾蕾娜·安博兰兹
			npcs = {
				{27828},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 圣光烁辉（✓）
					category = "BossMod",
					spellID = 424431,
					name = T.GetIconLink(424431)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ENCOUNTER_START"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["211290"] = {
								engage_cd = 25.2,
								cast_cd = 36.4,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 424431
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						frame.only_trash = true
						
						T.InitMobCooldownText(frame)						
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
			},
		},
		{ -- 歇尼麦尔中士
			npcs = {
				{27825},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 跃进打击（✓）
					category = "BossMod",
					spellID = 424423,
					name = T.GetIconLink(424423)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ENCOUNTER_START"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["239836"] = {
								engage_cd = 4.9,
								cast_cd = 12.1,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 424423
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						frame.only_trash = true
						
						T.InitMobCooldownText(frame)						
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
			},
		},
		{ -- 泰纳·杜尔玛
			npcs = {
				{27825},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 余烬风暴（✓）
					category = "BossMod",
					spellID =  424462,
					name = T.GetIconLink(424462)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["ENCOUNTER_START"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["239834"] = {
								engage_cd = 31.2,
								cast_cd = 33.7,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 424462
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						frame.only_trash = true
						
						T.InitMobCooldownText(frame)						
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
			},
		},
		{ -- 热切的圣骑士:奉献
			spells = {
				{424429},
			},
			options = {
				T.Temp_NormalCastBar(424429, {
					sound = "[outcircle]cast",
				}),
				T.Temp_OnFireIcon(424430),
			},
		},
		{ -- 热切的圣骑士:神圣鸣罪
			spells = {
				{448791},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 神圣鸣罪（✓）
					category = "BossMod",
					spellID = 448791,
					name = T.GetIconLink(448791)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["206704"] = {
								engage_cd = 15.4,
								cast_cd = 22.5,
								cast_gap = 3,
							},
						}
						
						frame.cast_spellID = 448791
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
				T.Temp_ImportantCastBar(448791, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(448791, "SPELL_CAST_START", 2.5, 75),
			},
		},
		{ -- 热心的圣殿骑士:圣殿骑士之怒
			spells = {
				{444728},
			},
			options = {
				T.Temp_PlateAura(444728),			
				T.Temp_DispelBuffSound(444728, "7"),
			},
		},		
		{ -- 光耀之子:纯净
			spells = {
				{448787},
			},
			options = {
				T.Temp_ComIcon(448787),
				T.Temp_RaidCastIcon(448787),
				T.Temp_BigDoTIcon(448787, nil, "red"),
				T.Temp_HPWatchAura(448787, nil, 80),
				T.Temp_RaidAuraGlow(448787, "red"),
			},
		},
		{ -- 光耀之子:强光迸发
			spells = {
				{427601},
			},
			options = {
				T.Temp_NormalCastBar(427601, {
					sound = "[outcircle]cast",
				}),
			},
		},
		{ -- 亡灵法师:连珠火球
			spells = {
				{444743},
			},
			options = {
				T.Temp_ImportantInterruptBar(444743),
				T.Temp_PlateInterrupt(444743, "221760", 1),
			},
		},
		{ -- 布朗派克爵士:辉耀烈焰
			spells = {
				{451763},
			},
			options = {
				T.Temp_CLEUSound(451763, "SPELL_CAST_SUCCESS", "[defense]"),
				T.Temp_DoTIcon(451764),
			},
		},
		{ -- 布朗派克爵士:炽热打击
			spells = {
				{435165},
			},
			options = {
				T.Temp_TankCastBar(435165, "[minddefense]cast"),
				T.Temp_DoTIcon(435165),
			},
		},
	},
}