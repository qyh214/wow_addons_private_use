local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1194\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2437] = {
	engage_id = 2425,
	npc_id = {"175616"},
	alerts = {
		{ -- 审讯
			spells = {
				{345598, "4,5"},
				{345990},
				{353424, "2"},
			},
			options = {
				{ -- 文字 审讯 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(348350)..L["倒计时"],
					data = {
						spellID = 348350,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {40.7, 40.1, 36.3, 36.5},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 348350, T.GetIconLink(348350), self, event, ...)
					end,
				},
				{ -- 计时条 审讯（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 348350,
				},
				{ -- 首领模块 计时条 审讯（✓）
					category = "BossMod",
					spellID = 347949,
					name = string.format(L["计时条%s"], T.GetIconLink(347949)),
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
						
						local icon = C_Spell.GetSpellTexture(347949)
						local spell = C_Spell.GetSpellName(347949)
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
							T.PlaySound("rescue")
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 347949 then -- 审讯
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
				{ -- 图标 审讯（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 347949,
					hl = "org",
				},
				{ -- 团队框架高亮 审讯（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 347949,
					color = "org",
				},
				{ -- 图标 监禁室（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 345990,
					tip = L["强力DOT"],
					hl = "red",
				},
				{ -- 团队框架高亮 监禁室（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 345990,				
					color = "red",
				},
			},
		},
		{ -- 武装安保
			spells = {
				{346204},
			},
			options = {
				{ -- 计时条 武装安保（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 346204,
					sound = "[dodge_circle]cast",
				},
				{ -- 图标 武装安保（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 348366,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 全副武装
			spells = {
				{348128},
			},
			options = {
				{ -- 文字 全副武装 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = L["增加伤害"]..L["倒计时"],
					data = {
						spellID = 348128,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {29.7, 40.2, 53.8, 37.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 348128, L["增加伤害"], self, event, ...)
					end,
				},
				{ -- 计时条 全副武装（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 348128,
					sound = "[buff_dmg]cast",
					ficon = "0",
				},
				{ -- 图标 全副武装（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 348128,
					hl = "yel",
					tip = L["增加伤害"].."25%",
					ficon = "0",
				},
			},
		},
		{ -- 扣押违禁品
			spells = {
				{345770},
				{353421},
			},
			options = {
				{ -- 文字 扣押违禁品 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["缴械"]..L["倒计时"],
					data = {
						spellID = 346006,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {20.0, 40.1, 27.9, 46.2, 37.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 346006, L["缴械"], self, event, ...)
					end,
				},
				{ -- 计时条 扣押违禁品（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 346006,
					text = L["缴械"],
				},
				{ -- 图标 扣押违禁品（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 345770,
					hl = "red",
					tip = L["缴械"],
					sound = "[disarm]",
				},
				{ -- 图标 精力（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 353421,
					hl = "gre",
					tip = L["加急速"],
				},
			},
		},
		{ -- 充能劈斩
			spells = {
				{1236348},
			},
			options = {
				{ -- 文字 充能劈斩 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["冲击波"]..L["倒计时"],
					data = {
						spellID = 1236348,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {12.4, 20.6, 19.4, 20.7, 19.4, 17.0, 17.0, 17.0, 20.6, 17.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1236348, L["冲击波"], self, event, ...)
					end,
				},
				{ -- 计时条 充能劈斩（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1236348,
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
	},
}