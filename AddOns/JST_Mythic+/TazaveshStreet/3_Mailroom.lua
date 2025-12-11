local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2436] = {
	engage_id = 2424,
	npc_id = {"175646"},
	alerts = {
		{ -- 不稳定的货物
			spells = {
				{346947, "5"},
			},
			options = {				
				{ -- 文字 不稳定的货物 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(346947)..L["倒计时"],
					data = {
						spellID = 346947,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {35.0, 43.7, 43.8},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 346947, T.GetIconLink(346947), self, event, ...)
					end,
				},
				{ -- 计时条 不稳定的货物（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 346947,
					sound = "[bomb]cast",
				},
				{ -- 图标 不稳定的货物（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 369133,
					hl = "yel",
					tip = L["减速"].."20%",
				},
				{ -- 文字 不稳定的货物 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["炸弹"]..L["倒计时"],
					data = {
						spellID = 346296,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 346947 then
								self.count = 5
								self.exp_time = GetTime() + 30
								
								self:Show()
								
								self:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > 0.05 then
										s.remain = s.exp_time - GetTime()
										if s.remain > 0 then
											s.text:SetText(string.format("%s%d/5 %.1f", L["炸弹"], s.count, s.remain))	
										else
											s:Hide()
											s:SetScript("OnUpdate", nil)
										end
										s.t = 0
									end
								end)
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 346296 then
								self.count = self.count - 1
								if self.count == 0 then
									self:Hide()
									self:SetScript("OnUpdate", nil)
									self.text:SetText("")
								end
							end
						end
					end,
				},
				{ -- 图标 动荡爆炸（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 346297,
					hl = "red",
					tip = L["强力DOT"],
				},
			},
		},
		{ -- 有害液体
			spells = {
				{438599},
			},
			options = {
				{ -- 文字 有害液体 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(346286)..L["倒计时"],
					data = {
						spellID = 346286,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {6.3, 42.0, 43.8, 43.7},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 346286, T.GetIconLink(346286), self, event, ...)
					end,
				},
				{ -- 计时条 有害液体（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 346286,
					sound = "[mindstep]cast",
				},
				{ -- 图标 炼金残渣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 346844,
					hl = "blu",
					tip = L["DOT"],
					ficon = "7",
				},
				{ -- 团队框架高亮 炼金残渣（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 346844,
					color = "blu",
					amount = 2,
				},
				{ -- 驱散提示音 炼金残渣（✓）
					category = "Sound",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 346844,
					file = "[dispel]",
					ficon = "7",
					amount = 2,
				},
				{ -- 自保技能提示 炼金残渣（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 346844,
					threshold = 65,
					amount = 2,
				},
				{ -- 图标 四溅液体（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 346329,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 邮件旋风
			spells = {
				{346742},
			},
			options = {
				{ -- 文字 邮件旋风 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(346742)..L["全团AE"]..L["倒计时"],
					data = {
						spellID = 346742,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {16.0, 42.0, 43.8, 43.7},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 346742, L["全团AE"], self, event, ...)
					end,
				},
				{ -- 计时条 邮件旋风（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 346742,
					text = L["全团AE"],
					sound = "[aoe]cast",
					glow = true,
					group = 1,
				},
			},
		},
		{ -- 现金汇款
			spells = {
				{346962},
			},
			options = {
				{ -- 文字 现金汇款 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(346962)..L["分担伤害"]..L["倒计时"],
					data = {
						spellID = 346962,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {23.3, 42.0, 43.8, 43.7},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss1", 346962, L["分担伤害"], self, event, ...)
					end,
				},
				{ -- 首领模块 计时条 现金汇款（✓）
					category = "BossMod",
					spellID = 346967,
					name = string.format(L["计时条%s"], T.GetIconLink(346962)),
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_GROUP_CD_UPDATE"] = true,
					},
					init = function(frame)
						frame.trackedspellIDs = {}
						
						frame.immuse_class = {
							MAGE = 45438, -- Ice Block
							DEMONHUNTER = 196555, -- Netherwalk
							HUNTER = 186265, -- Turtle
							PALADIN = 642, -- Divine Shield
							ROGUE = 31224, -- Cloak of Shadows
						}
						
						for _, spellID in pairs(frame.immuse_class) do
							frame.trackedspellIDs[spellID] = true
						end
						
						local icon = C_Spell.GetSpellTexture(346962)
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, L["分担伤害"])
						
						function frame:UpdateImmuseBuff()
							local bar = self.bar
							local GUID = bar.GUID
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							
							if not info then return end
							
							local unit = info.unit
							local spellID = self.immuse_class[info.class]
							
							if bar.spell_icon then
								bar.spell_icon:Hide()
							end
							
							if spellID then
								if not bar.spell_icon then
									local texture = C_Spell.GetSpellTexture(spellID)
									local size =  bar:GetHeight()
									bar.spell_icon = T.CreateIcon(bar, texture, size)
									bar.spell_icon:SetPoint("LEFT", bar, "RIGHT", 2, 0)	
								end
								
								local buffed = AuraUtil.FindAuraBySpellID(spellID, unit, "HELPFUL")
								
								if buffed then
									local exp_time = select(6, AuraUtil.FindAuraBySpellID(spellID, unit, "HELPFUL"))
									bar.spell_icon:stop_cooldown(true)
									bar.spell_icon:start(exp_time, true)
									bar.spell_icon:Show()
								else
									local ready, exp_time, duration, remain = T.GetGroupCooldown(GUID, spellID)
									if ready then
										bar.spell_icon:stop(true)
										bar.spell_icon:stop_cooldown(true)
										bar.spell_icon:Show()
									elseif remain and remain <= 5 then
										bar.spell_icon:stop(true)
										bar.spell_icon:start_cooldown(duration, exp_time, true)
										bar.spell_icon:Show()
									else
										bar.spell_icon:Hide()
									end
								end
							end
						end
					
						function frame:Start(GUID)
							local bar = self.bar
							bar.GUID = GUID
							
							local info = T.GetGroupInfobyGUID(GUID)
							bar.mid:SetText(info and info.format_name or "")
							
							self:UpdateImmuseBuff()
							T.StartTimerBar(bar, 7, true, true)
							T.PlaySound("sharedmg")
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 346962 then -- 现金汇款
								frame:Start(destGUID)
								
							elseif sub_event == "SPELL_AURA_APPLIED" and destGUID == frame.bar.GUID and frame.trackedspellIDs[spellID] then
								frame:UpdateImmuseBuff()
								
							elseif sub_event == "SPELL_AURA_REMOVED" and destGUID == frame.bar.GUID and frame.trackedspellIDs[spellID] then
								frame:UpdateImmuseBuff()
							end
							
						elseif event == "JST_GROUP_CD_UPDATE" then
							frame:UpdateImmuseBuff()
							
						elseif event == "ENCOUNTER_START" then
							frame.bar.GUID = nil
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
				{ -- 首领模块 现金汇款 计时圆圈（✓）
					category = "BossMod",
					spellID = 346962,
					name = T.GetIconLink(346962)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[346962] = { -- 现金汇款
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .3, 0},
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
				{ -- 自保技能提示 现金汇款（✓）
					category = "HPWatch",
					type = "CLEU",
					spellID = 346962,
					event = "SPELL_CAST_SUCCESS",
					dur = 7,
					threshold = 80,
				},
			},
		},
	},
}