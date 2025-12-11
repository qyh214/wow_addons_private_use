local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[378] = {2406, 2387, 2411, 2413, "c378"}

local function soundfile(filename, arg)
	return string.format("[c378\\%s]%s", filename, arg or "")
end
--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c378"] = {
	map_id = 2287,
	alerts = {
		{ -- 堕落的黑暗剑士:心能蚀甲
			spells = {
				{1235060},
			},
			options = {
				T.Temp_DoTIcon(1235060, "7", "blu"),
				T.Temp_RaidAuraGlow(1235060, "blu", 7),
				T.Temp_DispelDebuffSound(1235060, "7", 7),
			},
		},
		{ -- 堕落的驯犬者:射击
			spells = {
				{325535},
			},
			options = {
				T.Temp_ComIcon(325535),
				T.Temp_RaidCastIcon(325535),
			},
		},
		{ -- 堕落的驯犬者:忠心的野兽
			spells = {
				{326450},
			},
			options = {
				T.Temp_ImportantInterruptBar(326450),
				T.Temp_PlateInterrupt(326450, "164562", 2),
			},
		},
		{ -- 邪恶的加尔贡:龟裂创伤
			spells = {
				{1237602},
			},
			options = {
				T.Temp_DoTIcon(1237602, "13", "red"),
				T.Temp_DispelDebuffSound(1237602, "13", 3),
			},
		},
		{ -- 劳苦的管理员:快逃！
			spells = {
				{1235121},
			},
			options = {
				T.Temp_PlateAura(1235121),
			},
		},
		{ -- 哈尔吉亚斯的碎片:痛击
			spells = {
				{326409},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 痛击（✓）
					category = "BossMod",
					spellID = 326409,
					name = T.GetIconLink(326409)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["164557"] = {
								engage_cd = 8.2,
								cast_cd = 23,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 326409
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
				T.Temp_ImportantCastBar(326409, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(326409, "SPELL_CAST_START", 10),
			},
		},
		{ -- 哈尔吉亚斯的碎片:罪孽震击
			spells = {
				{326441},
			},
			options = {
				T.Temp_NormalCastBar(326441, {	
					sound = "[dodge_circle]cast",
				}),
			},
		},		
		{ -- 堕落的搜集者:生命虹吸
			spells = {
				{325701},
			},
			options = {
				T.Temp_SubInterruptBar(325701, {
					show_tar = true,
				}),	
				T.Temp_PlateInterrupt(325701, "165529", 2),
				T.Temp_BigDoTIcon(325701, nil, "red"),
				T.Temp_RaidAuraGlow(325701, "red"),
				T.Temp_HPWatchAura(325701),
			},
		},
		{ -- 堕落的歼灭者:邪恶箭矢
			spells = {
				{338003},
			},
			options = {
				T.Temp_SubInterruptBar(338003, {
					show_tar = true,
				}),	
				T.Temp_PlateInterrupt(338003, "165414", 2),
				T.Temp_ComIcon(338003),
				T.Temp_RaidCastIcon(338003),
			},
		},
		{ -- 堕落的歼灭者:湮灭诅咒
			spells = {
				{325876},
			},
			options = {
				T.Temp_DoTIcon(325876, "7", "blu"),
				T.Temp_DispelDebuffSound(325876, "7"),
				T.Temp_RaidAuraGlow(325876, "blu"),
			},
		},
		{ -- 石裔切割者:岩石监视者
			spells = {
				{1235808},
			},
			options = {
				T.Temp_PlateAura(1235809),
			},
		},
		{ -- 石裔切割者:猛力横扫
			spells = {
				{326997},
			},
			options = {
				T.Temp_NormalCastBar(326997, {	
					sound = "[dodge]cast",
				}),
			},
		},
		{ -- 石裔切割者:瓦解尖叫
			spells = {
				{1235326},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 瓦解尖叫（✓）
					category = "BossMod",
					spellID = 1235326,
					name = T.GetIconLink(1235326)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["167607"] = {
								engage_cd = 15.8,
								cast_cd = 32.8,
								cast_gap = 5,
							},
						}

						frame.cast_spellID = 1235326
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						frame.count_voice = "en"
						
						T.InitMobCooldownText(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateMobCooldownText(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobCooldownText(frame)
					end,
				},
				{ -- 首领模块 计时条 瓦解尖叫（✓）
					category = "BossMod",
					spellID = 1235808,
					name = string.format(L["计时条%s"], T.GetIconLink(1235326)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_SPELLCAST_CHANNEL_START"] = true,
						["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true,
						["UNIT_SPELLCAST_CHANNEL_STOP"] = true,
					},
					init = function(frame)
						local name = C_Spell.GetSpellName(1235326)
						local icon = C_Spell.GetSpellTexture(1235326)
						local color = T.GetSpellColor(1235326)
						
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, name, color)
						frame.bar.glow:SetBackdropBorderColor(unpack(color))
						frame.bar.glow:Show()
						
						function frame:UpdateCastState(start)
							if self.cast_exp then
								if UnitCastingInfo("player") then
									local startTimeMS, endTimeMS = select(4, UnitCastingInfo("player"))
									if startTimeMS > self.cast_exp then return end
									if endTimeMS < self.cast_exp then
										self.bar.mid:SetText(string.format("|cff00ff00%s|r", L["安全施法"]))
										T.PlaySound("safecasting")
									else
										self.bar.mid:SetText(string.format("|cffff0000%s|r", L["停止施法"]))
										T.PlaySound("stopcasting")
									end
								elseif UnitChannelInfo("player") then
									local startTimeMS, endTimeMS = select(4, UnitChannelInfo("player"))
									if startTimeMS > self.cast_exp then return end
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
								if cast_spellID == 1235326 and not frame.cast_exp then
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
								if cast_spellID == 1235326 and frame.cast_exp then
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
			},
		},
		{ -- 石裔切割者:石拳
			spells = {
				{1237071},
			},
			options = {
				T.Temp_TankCastBar(1237071, "[knockback]cast"),
			},
		},
		{ -- 石精噬踝者:脚踝撕咬
			spells = {
				{1235245},
			},
			options = {
				T.Temp_NormalDebuff(1235245, L["DOT"].."+"..L["减速"].."%s20%"),
				T.Temp_RaidAuraGlow(1235245, "red", 5),
				T.Temp_HPWatchAura(1235245, 3, 75),
			},
		},		
		{ -- 石裔剔骨者:投掷战刃
			spells = {
				{326638},
			},
			options = {
				T.Temp_NormalCLEUBar(326638, "SPELL_CAST_SUCCESS", 1, {
					show_tar = true,
				}),
				{ -- 首领模块 投掷战刃 计时圆圈（✓）
					category = "BossMod",
					spellID = 326638,
					name = T.GetIconLink(326638)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[326638] = { -- 投掷战刃
								event = "SPELL_CAST_SUCCESS",
								target_me = true,
								dur = 1,
								color = {1, 1, 0},
								reverse = true,
								sound = "[getout]",
							},
						}
						T.InitCircleTimers(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateCircleTimers(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetCircleTimers(frame)
					end,
				},
			},
		},
		{ -- 石裔掠夺者:变为石头
			spells = {
				{1235762},
			},
			options = {
				T.Temp_NormalCastBar(1235762, {
					sound = "[outcircle]cast",
				}),
			},
		},
		{ -- 石裔掠夺者:致死打击
			spells = {
				{1235766},
			},
			options = {
				T.Temp_TankCastBar(1235766, "[minddefense]cast"),
				T.Temp_ImportantDebuffIcon(1235766, "red", L["致死"].."50%"),
				T.Temp_RaidAuraGlow(1235766, "red"),
			},
		},
		{ -- 审判官西加尔:耀武扬威
			spells = {
				{1236614},
			},
			options = {
				T.Temp_NormalCastBar(1236614, {
					text = L["增加伤害/治疗"],
				}),
				T.Temp_ImportantDebuffIcon(1236614, "gre", L["增加伤害/治疗"].."30%", {
					sound = "[spread]",
				}),
				{ -- 首领模块 耀武扬威 计时圆圈（✓）
					category = "BossMod",
					spellID = 1236614,
					name = T.GetIconLink(1236614)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1236614] = { -- 耀武扬威
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
		{ -- 审判官西加尔:邪恶箭矢
			spells = {
				{326829},
			},
			options = {
				T.Temp_SubInterruptBar(326829, {
					show_tar = true,
				}),	
				T.Temp_PlateInterrupt(326829, "167876", 3),
				T.Temp_ComIcon(326829),
				T.Temp_RaidCastIcon(326829),
			},
		},
		{ -- 审判官西加尔:驱散罪孽
			spells = {
				{326847},
			},
			options = {
				T.Temp_NormalCastBar(326847, {
					sound = "[dodge_circle]cast",
				}),
				T.Temp_OnFireIcon(326891),
			},
		},
		{ -- 审判官西加尔:黑暗圣餐
			spells = {
				{326794},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 黑暗圣餐（✓）
					category = "BossMod",
					spellID = 326794,
					name = T.GetIconLink(326794)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["167876"] = {
								engage_cd = 3.8,
								cast_cd = 31.3,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 326794
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["召唤小怪"]
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
				T.Temp_NormalCastBar(326794, {
					text = L["召唤小怪"],
					sound = "[add]cast",
				}),
			},
		},
		{ -- 嫉妒具象:嫉妒之印
			spells = {
				{340446},
			},
			options = {				
				T.Temp_ImportantDebuffIcon(340446, "red", L["锁定"], {
					sound = "[focusyou]",
				}),
				T.Temp_RaidAuraGlow(340446, "red"),
				T.Temp_HPWatchAura(340446, 75),
			},
		},
	},
}