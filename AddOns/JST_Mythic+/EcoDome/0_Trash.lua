local T, C, L, G = unpack(JST)

G.ChallengeMap_Order[542] = {2675, 2676, 2677, "c542"}

local function soundfile(filename, arg)
	return string.format("[c542\\%s]%s", filename, arg or "")
end
--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["奥尔达尼沙地滤镜"] = "在%s中自动添加深色滤镜"
	
elseif G.Client == "ruRU" then
	--L["奥尔达尼沙地滤镜"] = "Automatically add dark filters in %s"
	
else
	L["奥尔达尼沙地滤镜"] = "Automatically add dark filters in %s"

end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters["c542"] = {
	map_id = 2830,
	alerts = {
		{ -- 吃撑的幼虫:啃噬 
			spells = {
				{1229474},
			},
			options = {
				T.Temp_SubInterruptBar(1229474, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(1229474, "242209", 1),				
			},
		},
		{ -- 吃撑的幼虫:吃撑爆发
			spells = {
				{1231497},
				{1231494},
			},
			options = {
				T.Temp_DoTIcon(1231494),
			},
		},
		{ -- 肆虐的食腐者:饥饿狂怒
			spells = {
				{1221133},
			},
			options = {
				T.Temp_PlateAura(1221133),
				T.Temp_DispelBuffSound(1221133, "11"),		
			},
		},
		{ -- 贪婪的毁灭者:不稳定的喷发
			spells = {
				{1226111},
			},
			options = {
				T.Temp_NormalGroupAuraBar(1226110),
				T.Temp_HPWatchAura(1226110),
				{ -- 首领模块 不稳定的喷发 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 1226110,
					name = T.GetIconLink(1226110)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1226110] = {		
								color = {0, 1, 1},
								sound = "ray",
								msg = "%name %spell",
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
		{ -- 贪婪的毁灭者:暴食瘴气
			spells = {
				{1221190},
			},
			options = {				
				T.Temp_NormalCastBar(1221190, {	
					show_tar = true,
				}),
				T.Temp_ComIcon(1221190),
				T.Temp_RaidCastIcon(1221190),				
				{ -- 首领模块 暴食瘴气 计时圆圈（✓）
					category = "BossMod",
					spellID = 1221190,
					name = T.GetIconLink(1221190)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1221190] = { -- 暴食瘴气
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
				T.Temp_HPWatchAura(1221190),
				T.Temp_RaidAuraGlow(1221190, "red"),
			},
		},
		{ -- 贪食的饕餮者:暴食猛击
			spells = {
				{1221152},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 暴食猛击（✓）
					category = "BossMod",
					spellID = 1221152,
					name = T.GetIconLink(1221152)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["234883"] = {
								engage_cd = 6.2,
								cast_cd = 18.2,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 1221152
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
				T.Temp_ImportantCastBar(1221152, {	
					text = L["全团AE"].."+"..L["躲圈"],
					sound = "[mindstep]cast",
				}),	
			},
		},
		{ -- 过载的哨兵:不稳定的核心
			spells = {
				{1231244},
			},
			options = {
				T.Temp_PlateAura(1231244),
				T.Temp_CLEUSound(1231244, "SPELL_AURA_APPLIED", "[mindstep]"),
			},
		},
		{ -- 过载的哨兵:奥术猛袭
			spells = {
				{1235368},
			},
			options = {
				T.Temp_NormalCastBar(1231224, {	
					sound = "[avoidfront]cast,notank",
				}),
				T.Temp_DoTIcon(1231224),
			},
		},
		{ -- 过载的哨兵:奥术燃烧
			spells = {
				{1222202},
			},
			options = {
				T.Temp_OnFireIcon(1222202),
			},
		},
		{ -- 驯服的废墟追猎者:迁跃
			spells = {
				{1222356},
			},
			options = {
				T.Temp_NormalCastBar(1222356, {	
					sound = "[ray]cast",
				}),
			},
		},
		{ -- 废土遗民远遁者:弧光震击
			spells = {
				{1229510},
			},
			options = {
				T.Temp_NormalInterruptBar(1229510),
				T.Temp_PlateInterrupt(1229510, "234962", 6),
			},
		},
		{ -- 废土遗民相位剑士:敏锐
			spells = {
				{1231608},
			},
			options = {
				T.Temp_PlateAura(1231608),
				T.Temp_DispelBuffSound(1231608, "7")
			},
		},
		{ -- 废土遗民祭师:奥术箭(废土遗民诉契者)
			spells = {
				{1222815},
			},
			options = {
				T.Temp_SubInterruptBar(1222815, {
					show_tar = true,
				}),
				T.Temp_PlateInterrupt(1222815, "234957,234955", 2),
				T.Temp_ComIcon(1222815),
				T.Temp_RaidCastIcon(1222815),
			},
		},
		{ -- 废土遗民祭师:电弧能量
			spells = {
				{1221483},
			},
			options = {
				T.Temp_ComIcon(1221483),
				T.Temp_RaidCastIcon(1221483),
				T.Temp_DoTIcon(1221483, "7", "blu"),
				T.Temp_DispelDebuffSound(1221483, "7"),
				T.Temp_RaidAuraGlow(1221483, "blu"),
			},
		},
		{ -- 废土遗民诉契者:异变仪式
			spells = {
				{1221532},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 异变仪式（✓）
					category = "BossMod",
					spellID = 1221532,
					name = T.GetIconLink(1221532)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["234955"] = {
								engage_cd = 7.7,
								cast_cd = 21.4,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 1221532
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
				T.Temp_ImportantCastBar(1221532, {	
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(1221532, "SPELL_CAST_START", 8.5),
			},
		},
		{ -- 废土遗民诉契者:吞噬灵魂
			spells = {
				{1248701},
			},
			options = {
				T.Temp_NormalCastBar(1248699, {	
					text = L["转火"],
					sound = "[target]cast",
				}),
				T.Temp_PlateAura(1248702), -- 灵魂防护
				T.Temp_PlateNpcGlow("240952"),
				T.Temp_PlateAuraWithGlow(1226492), -- 干扰仪式
			},
		},
		{ -- 卡雷什元素:卡雷什之拥
			spells = {
				{1223000},
			},
			options = {
				T.Temp_PlateAura(1223000),
				T.Temp_DispelBuffSound(1223000, "7"),
			},
		},
		{ -- 废土蠕行者:幽暗之咬
			spells = {
				{1222341},
			},
			options = {
				T.Temp_ComIcon(1222341),
				T.Temp_DoTIcon(1222341),				
			},
		},
		{ -- 废土蠕行者:掘进喷发
			spells = {
				{1223007},
			},
			options = {
				T.Temp_NormalCastBar(1223007, {		
					sound = "[dodge_circle]cast",
				}),
			},
		},
		{ -- 掘地蠕行者:碾地猛击
			spells = {
				{1215850},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 碾地猛击（✓）
					category = "BossMod",
					spellID = 1215850,
					name = T.GetIconLink(1215850)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["245092"] = {
								engage_cd = 20,
								cast_cd = 31.5,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 1215850
						frame.cast_str = T.GetSpellIcon(frame.cast_spellID)..L["全团AE"].."+"..L["躲圈"]
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
				T.Temp_ImportantCastBar(1215850, {
					text = L["全团AE"].."+"..L["躲圈"],
					sound = "[mindstep]cast",
				}),
			},
		},
		{ -- 掘地蠕行者:钻地冲击
			spells = {
				{1237195},
			},
			options = {
				T.Temp_NormalCastBar(1237195, {	
					show_tar = true,
					sound = "[getout]cast",
				}),
				T.Temp_RaidCastIcon(1237195),
				{ -- 首领模块 钻地冲击 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 1237195,
					name = T.GetIconLink(1237195)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_TARGET"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1237195] = {		
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
		{ -- 掘地蠕行者:猛烈沙暴
			spells = {
				{1237220},
			},
			options = {
				{ -- 首领模块 小怪技能倒计时 猛烈沙暴（✓）
					category = "BossMod",
					spellID = 1237220,
					name = T.GetIconLink(1237220)..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_ENTERING_COMBAT"] = true,
						["GROUP_LEAVING_COMBAT"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.cast_npcID = {
							["245092"] = {
								engage_cd = 13.8,
								cast_cd = 26.8,
								cast_gap = 5,
							},
						}
						
						frame.cast_spellID = 1237220
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
				T.Temp_ImportantCastBar(1237220, {
					text = L["全团AE"],
					sound = "[aoe]cast",
				}),
				T.Temp_HPWatchCLEU(1237220, "SPELL_CAST_START", 4),
			},
		},
		{ -- 卡雷什涌动
			spells = {
				{1239229},
			},
			options = {
				T.Temp_PositiveIcon(1239229, L["加速"].."+"..L["加急速"]),
				{ -- 首领模块 奥尔达尼沙地滤镜（✓）
					category = "BossMod",
					spellID = 1239229,
					name = string.format(L["奥尔达尼沙地滤镜"], C_Map.GetAreaInfo(16422)),
					points = {hide = true},
					events = {	
						["ZONE_CHANGED"] = true,
					},
					custom = {
						{
							key = "alpha_sl",
							text = L["透明度"],
							default = 10,
							min = 5,
							max = 50,
							apply = function(value, alert)
								alert.filter:SetAlpha(value/100)
							end
						},
					},
					init = function(frame)					
						frame.areaNames = {
							[C_Map.GetAreaInfo(16422)] = true,
							[C_Map.GetAreaInfo(16569)] = true,	
						}
						
						frame.bg = CreateFrame("Frame", nil, UIParent)
						frame.bg:SetAllPoints()
						frame.bg:SetFrameStrata("BACKGROUND")
						frame.bg:Hide()
						
						frame.filter = frame.bg:CreateTexture(nil, "BACKGROUND")
						frame.filter:SetAllPoints()
						frame.filter:SetTexture(G.media.blank)
						frame.filter:SetVertexColor(.05, .05, .05)
						frame.filter:SetAlpha(0)
					end,
					update = function(frame, event, ...)
						if event == "ZONE_CHANGED" or event == "OPTION_EDIT" then
							local area = GetSubZoneText()
							if frame.areaNames[area] then
								frame.bg:Show()
							else
								frame.bg:Hide()
							end
						end
					end,
					reset = function(frame, event)
						frame.bg:Hide()
					end,
				},
			},
		},
	},
}

