local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[505] = {2580, 2581, 2593, "c505"}

local function soundfile(filename)
	return string.format("[c505\\%s]", filename)
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c505"] = {
	map_id = 2662,
	alerts = {
		{ -- 夜幕影法师:暗夜箭
			spells = {
				{431303},
			},
			options = {
				T.Temp_SubInterruptBar(431303, {
					show_tar = true,
					threat_ck = true,
				}),
				T.Temp_PlateInterrupt(431303, "213892", 2),
				T.Temp_ComIcon(431303),
				T.Temp_RaidCastIcon(431303),
			},
		},
		{ -- 夜幕影法师:诱捕暗影
			spells = {
				{431309},
			},
			options = {
				T.Temp_ImportantDebuffIcon(431309, "pur", L["减速"].."+"..L["DOT"], {
					ficon = "8",
				}),
				T.Temp_RaidAuraGlow(431309, "pur"),
				T.Temp_DispelDebuffSound(431309, "8"),
			},
		},
		{ -- 夜幕祭师:折磨光束
			spells = {
				{431364, "2"},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 折磨光束（✓）
					category = "BossMod",
					spellID = 431364,
					name = T.GetIconLink(431364)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["214761"] = {
								engage_cd = 1,
								cast_cd = 11.5,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 431364
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["注意治疗"]
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
				T.Temp_ImportantCLEUBar(431364, "SPELL_CAST_START", 2.5, {
					text = L["强力DOT"],
				}),
				T.Temp_BigDoTIcon(431365, nil, "red"),
				T.Temp_HPWatchAura(431365),
				T.Temp_RaidAuraGlow(431365, "red"),
			},
		},
		{ -- 夜幕祭师:冥河之种
			spells = {
				{432448},
			},
			options = {
				T.Temp_NormalCastBar(432448, {
					show_tar = true,
					ficon = "7",
				}),
				T.Temp_DispelDebuffCastSound(432448, "7"),
				T.Temp_RaidCastIcon(432448),
				T.Temp_ImportantDebuffIcon(432448, "org_flash", L["离开人群"], {
					ficon = "7",
					msg = {str_applied = "%name %spell"},
				}),
				T.Temp_RaidAuraGlow(432448, "blu"),
			},
		},
		{ -- 夜幕司令官:污邪斩击
			spells = {
				{431491},
			},
			options = {
				T.Temp_TankCastBar(431491, "[minddefense]cast"),
				T.Temp_DoTIcon(431491, "13"),
				T.Temp_DispelDebuffSound(431491, "13"),				
			},
		},
		{ -- 夜幕司令官:深渊嗥叫
			spells = {
				{450756},
			},
			options = {
				T.Temp_NormalCastBar(450756, {
					ficon = "7",
				}),
				T.Temp_PlateAura(450756),
			},
		},
		{ -- 苏雷吉网法师:迸发虫茧
			spells = {
				{451107},
			},
			options = {				
				T.Temp_ComIcon(451107),
				T.Temp_RaidCastIcon(451107),
				T.Temp_ImportantDebuffIcon(451107, "red", L["强力DOT"], {
					sound = "[defense]cd3",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
				}),				
				{ -- 首领模块 迸发虫茧 计时圆圈（✓）
					category = "BossMod",
					spellID = 451107,
					name = T.GetIconLink(451107)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[451107] = { -- 迸发虫茧
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
				T.Temp_HPWatchAura(451107),
				T.Temp_RaidAuraGlow(451107, "red"),
			},
		},
		{ -- 苏雷吉网法师:蛛网箭
			spells = {
				{451113},
			},
			options = {
				T.Temp_SubInterruptBar(451113, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(451113, "210966", 2),
				T.Temp_ComIcon(451113),
				T.Temp_RaidCastIcon(451113),
			},
		},
		{ -- 夜幕暗法师:折磨射线
			spells = {
				{431333},
			},
			options = {				
				T.Temp_NormalInterruptBar(431333, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(431333, "213893,228539", 2),
				T.Temp_BigDoTIcon(431333, nil, "red"),
				T.Temp_HPWatchAura(431333),
				T.Temp_RaidAuraGlow(431333, "red"),
			},
		},
		{ -- 夜幕暗法师:暗影屏障
			spells = {
				{432520},
			},
			options = {
				T.Temp_NormalInterruptBar(432520),
				T.Temp_PlateInterrupt(432520, "213893,228539", 1),
			},
		},
		{ -- 暗影具象:黑暗之霰
			spells = {
				{432565},
			},
			options = {
				{ -- 首领模块 黑暗之霰 对我施法计时圆圈（待测试）
					category = "BossMod",
					spellID = 432565,
					name = T.GetIconLink(432565)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_TARGET"] = true,
					},
					init = function(frame)
						frame.figure = T.CreateRingCD(frame, {1, 1, 0}, true)
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 2.5, 2.5)
						end
						
						function frame:PreviewHide()
							self.figure:stop()
						end
						
						function frame:ToggleText(value)
							self.figure.dur_text:SetShown(value)
						end

						T.GetFigureCustomData(frame)
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_TARGET" then
							local unit, cast_GUID, cast_spellID, GUID = ...
							if cast_spellID == 432565 and GUID == G.PlayerGUID and UnitGroupRolesAssigned("player") ~= "TANK" then -- 黑暗之霰
								if frame.figure:IsShown() then return end
								
								local endTimeMS = select(5, UnitCastingInfo(unit))
								if not endTimeMS then return end
								
								local exp_time = endTimeMS/1000
								frame.figure:begin(exp_time, 2.5)
								
								local spell = C_Spell.GetSpellName(cast_spellID)
								T.SendChatMsg(spell)
								T.PlaySound("getout")
							end
						end
					end,
					reset = function(frame, event)
						frame.figure:stop()
					end,
				},
			},
		},		
		{ -- 暗影具象:深渊朽烂
			spells = {
				{453345, "2"},
			},
			options = {
				T.Temp_BigDoTIcon(453345, nil, "red"),				
				T.Temp_HPWatchAura(453345, nil, 75),
				T.Temp_RaidAuraGlow(453345, "red"),
			},
		},
		{ -- 夜幕战略家:黑刃之锋
			spells = {
				{431494},
			},
			options = {
				T.Temp_NormalCastBar(431494, {
					sound = "[dodge]cast",
					text = L["冲击波"],
				}),
				T.Temp_ImportantDebuffIcon(431494, "blu", L["诱捕"], {
					ficon = "7",
				}),
				T.Temp_RaidAuraGlow(431494, "blu"),
			},
		},
		{ -- 夜幕战略家:战略家之怒
			spells = {
				{451112},
			},
			options = {
				T.Temp_PlateAura(451112),
				T.Temp_DispelBuffSound(451112, "11"),
			},
		},
		{ -- 夜幕影行者:暗影之刃
			spells = {
				{1242681},
			},
			options = {
				T.Temp_NormalDebuff(1242681, L["致死"].."%s1%"),
			},
		},		
		{ -- 扬升者维斯可里亚:深渊轰击（死亡尖啸者艾肯塔克 坚不可摧的伊克斯雷腾）
			spells = {
				{451119},
			},
			options = {				
				T.Temp_NormalCastBar(451119, {
					show_tar = true,
				}),
				T.Temp_ComIcon(451119, {
					sound = "[defense]",
				}),
				T.Temp_RaidCastIcon(451119),
				T.Temp_BigDoTIcon(451119, nil, "red"),
				T.Temp_HPWatchAura(451119, nil, 75),
				T.Temp_RaidAuraGlow(451119, "red"),
			},
		},
		{ -- 扬升者维斯可里亚:晦影腐朽
			spells = {
				{451102},
			},
			options = {				
				{ -- 首领模块 小怪技能倒计时 晦影腐朽（✓）
					category = "BossMod",
					spellID = 451102,
					name = T.GetIconLink(451102)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["211261"] = { -- 扬升者维斯可里亚
								engage_cd = 13,
								cast_cd = 28,
								cast_gap = 5,
							},							
						}
						
						frame.cast_spellID = 451102
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
				T.Temp_ImportantCastBar(451102, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(451102, "SPELL_CAST_START", 5),
			},
		},
		{ -- 死亡尖啸者艾肯塔克:暗黑法球
			spells = {
				{450854},
			},
			options = {
				T.Temp_ImportantCastBar(450854, {
					sound = "[ball]cast,cd3",
				}),
				T.Temp_ImportantDebuffIcon(460135, "red", L["强力DOT"], {
					sound = "[defense]",
				}),
				T.Temp_HPWatchAura(460135, nil, 85),
				T.Temp_RaidAuraGlow(460135, "red"),
			},
		},
		{ -- 坚不可摧的伊克斯雷腾:恐惧猛击
			spells = {
				{451117},
			},
			options = {
				T.Temp_NormalCastBar(451117, {
					text = L["大圈"],
					sound = "[outcircle]cast,notank",	
				}),
				{ -- 首领模块 恐惧猛击 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 451117,
					name = T.GetIconLink(451117)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[451117] = {		
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
		{ -- 夜幕筑暗师:折磨喷发
			spells = {
				{431350},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 折磨喷发（✓）
					category = "BossMod",
					spellID = 431349,
					name = T.GetIconLink(431349)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["213885"] = {
								engage_cd = 7,
								cast_cd = 14.5,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 431349
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["分散"].."+"..L["注意治疗"]
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
				T.Temp_ImportantCastBar(431349, {
					text = L["分散"].."+"..L["注意治疗"],
					sound = "[spread]cast",
				}),
				T.Temp_ImportantDebuffIcon(431350, "red", L["分散"].."+"..L["强力DOT"], {
					sound = "[defense]",
				}),
				{ -- 首领模块 折磨喷发 计时圆圈（✓）
					category = "BossMod",
					spellID = 431350,
					name = T.GetIconLink(431350)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[431350] = { -- 折磨喷发
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
				T.Temp_HPWatchAura(431350),
				T.Temp_RaidAuraGlow(431350, "red"),
			},
		},
		{ -- 夜幕筑暗师:招引增援
			spells = {
				{446615},
			},
			options = {				
				{ -- 首领模块 小怪技能倒计时 招引增援（✓）
					category = "BossMod",
					spellID = 446615,
					name = T.GetIconLink(446615)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["213885"] = {
								engage_cd = 15,
								cast_cd = 14.5,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 446615
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["召唤小怪"]
						frame.text_color = T.GetSpellColor(frame.cast_spellID)
						frame.count_voice = "en"
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
				T.Temp_NormalCastBar(446615, {
					text = L["召唤小怪"],
					sound = "[add]cast",
				}),
			},
		},		
		{ -- 渗透暗影
			spells = {
				{449332},
			},
			options = {
				T.Temp_ImportantDebuffIcon(449332, "yel"),
			},
		},
	},
}