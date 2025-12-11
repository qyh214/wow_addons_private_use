local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1185\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2387] = {
	engage_id = 2380,
	npc_id = {"164185"},
	alerts = {
		{ -- 唤石
			spells = {
				{319733},
			},
			options = {
				{ -- 文字 唤石 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 319733,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {9.6, 52.6, 42.4},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 319733, L["召唤小怪"], self, event, ...)
					end,
				},
				{ -- 计时条 唤石（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 319733,
					sound = "[add]cast",
				},
			},
		},
		{ -- 不死石精
			npcs = {
				{21508},
			},
			options = {
				{ -- 文字 不死石精 数量（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["小怪"]..L["数量"],
					data = {
						spellID = 328124,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 328124 then -- 不死之石
								if not tContains(self.GUIDs, destGUID) then
									table.insert(self.GUIDs, destGUID)
									self.count = #self.GUIDs
								end
								
								if self.count > 0 then
									self:Show()
									self.text:SetText(string.format("%s %d", L["小怪"], self.count))
								end
							elseif sub_event == "UNIT_DIED" then
								if tContains(self.GUIDs, destGUID) then
									tDeleteItem(self.GUIDs, destGUID)
									self.count = #self.GUIDs
								end
								
								if self.count > 0 then
									self.text:SetText(string.format("%s %d", L["小怪"], self.count))
								else
									self:Hide()
									self.text:SetText("")
								end
							end
						
						elseif event == "ENCOUNTER_START" then
							if not self.GUIDs then
								self.GUIDs = {}
							else
								self.GUIDs = table.wipe(self.GUIDs)
							end
						end
					end,
				},
				{ -- 对我施法图标 罪邪箭（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 328322,
					hl = "yel_flash",
				},
				{ -- 团队框架图标 罪邪箭（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 328322,
				},
			},
		},
		{ -- 石化血肉
			spells = {
				{328206},
			},
			options = {
				{ -- 文字 石化血肉 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(328206)..L["倒计时"],
					data = {
						spellID = 328206,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {20.5, 31.6, 29.1, 29.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 328206, T.GetIconLink(328206), self, event, ...)
					end,
				},
				{ -- 计时条 石化血肉（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 328206,
					glow = true,
					group = 1,
				},
				{ -- 首领模块 石化血肉 点名计时条（✓）
					category = "BossMod",
					spellID = 319603,
					name = string.format(L["计时条%s"], T.GetIconLink(319603).."(Debuff)"),
					points = {hide = true},
					events = {
						["UNIT_AURA_ADD"] = true,
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
						
						local icon = C_Spell.GetSpellTexture(319603)
						local spell = C_Spell.GetSpellName(319603)
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, spell)
						
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
									elseif remain and remain <= 4 then
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
							T.StartTimerBar(bar, 5, true, true)
						end
						
						frame.aura_spellID = 319603
					end,
					update = function(frame, event, ...)
						if event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == 319603 then -- 石化血肉
								local GUID = UnitGUID(unit)
							end
						elseif event == "ENCOUNTER_START" then
							T.RegisterWatchAuraSpellID(319603)
						end
					end,
					reset = function(frame, event)
						T.UnregisterWatchAuraSpellID(319603)
					end,
				},
				{ -- 首领模块 石化血肉 对我施法计时圆圈（✓）
					category = "BossMod",
					spellID = 328206,
					name = T.GetIconLink(328206)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
						["UNIT_TARGET"] = true,
						["UNIT_AURA_ADD"] = true,
					},
					custom = {
						{
							key = "hp_perc_sl",
							text = L["血量阈值百分比"],
							default = 80,
							min = 20,
							max = 100,
						},
					},
					init = function(frame)
						frame.aura_spellID = 319603 -- 石化血肉
						frame.watched = false
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.figure = T.CreateRingCD(frame, {1, 1, 0})

						function frame:TargetCheck(unit)
							if not unit then return end
							
							
							if UnitIsUnit(unit, "player") then
								self.figure:begin(self.exp_time, 6, {
									{dur = 2, color = {0, 1, 1}},
								})
								
								T.AddPersonalSpellCheckTag("bossmod"..self.config_id, C.DB["BossMod"][self.config_id]["hp_perc_sl"], {"TANK"})
								local remain = self.exp_time - GetTime()
								C_Timer.After(remain, function()
									T.RemovePersonalSpellCheckTag("bossmod"..self.config_id)
								end)
							else
								T.Start_Text_Timer(self.text_frame, 2, L["没点你"])
							end
						end
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 6.5, 6.5, {
								{dur = 2, color = {0, 1, 1}},
							})
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
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_spellID == 328206 then -- 石化血肉
								frame.watched = true
								frame.exp_time = GetTime() + 6.5
							end
						elseif event == "UNIT_TARGET" then
							local unit = ...
							if unit == "boss1" and frame.watched then
								frame.watched = false
								local target_unit = T.GetTarget(unit)
								frame:TargetCheck(target_unit)
							end
						elseif event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == frame.aura_spellID and frame.watched then
								frame.watched = false
								frame:TargetCheck(unit)
							end
						elseif event == "ENCOUNTER_START" then
							T.RegisterWatchAuraSpellID(frame.aura_spellID)
						end
					end,
					reset = function(frame, event)
						T.UnregisterWatchAuraSpellID(frame.aura_spellID)
						frame.figure:stop()
					end,
				},
				{ -- 图标 变成石头（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 319611,
					hl = "yel",
				},
				{ -- 团队框架高亮 变成石头（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 319611,
					color = "yel",
				},
			},
		},
		{ -- 碎石之跃
			spells = {
				{319592},
			},
			options = {
				{ -- 计时条 碎石之跃（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 319941,
					show_tar = true,
				},
				{ -- 对我施法图标 碎石之跃（✓）
					category = "AlertIcon",
					type = "com",
					spellID = 319941,
					hl = "yel_flash",
					msg = {str_applied = "%name %spell", str_rep = "%spell %dur"},
					sound = "cd3",
				},
				{ -- 团队框架图标 碎石之跃（✓）
					category = "RFIcon",
					type = "Cast",
					spellID = 319941,
				},
				{ -- 图标 粉碎（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 344874,
					hl = "red",
					tip = L["DOT"],
				},
				{ -- 团队框架高亮 粉碎（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 344874,
					color = "red",
				},
			},
		},
		{ -- 鲜血洪流
			spells = {
				{319702},
			},
			options = {
				{ -- 文字 鲜血洪流 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 326389,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {4.7, 25.5, 17.0, 20.7, 23.0, 29.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 326389, L["放圈"], self, event, ...)
					end,
				},
				{ -- 计时条 鲜血洪流（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 326389,
					sound = "[dodge_circle]cast",
				},
				{ -- 图标 鲜血洪流（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 319703,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
	},	
}