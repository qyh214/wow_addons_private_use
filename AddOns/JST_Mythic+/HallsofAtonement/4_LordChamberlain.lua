local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1185\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2413] = {
	engage_id = 2381,
	npc_id = {"164218"},
	alerts = {
		{ -- 宫务大臣的和声
			spells = {
				{341245},
			},
			options = {
				{ -- 血量（✓）
					category = "TextAlert",
					type = "hp",
					data = {
						npc_id = "164218",
						ranges = {
							{ ul = 75, ll = 70.5, tip = L["阶段转换"]..string.format(L["血量2"], 70)},
							{ ul = 45, ll = 40.5, tip = L["阶段转换"]..string.format(L["血量2"], 40)},
						},
					},	
				},
				{ -- 计时条 暗影之门（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 329104,
					sound = "[phase]cast",
				},
			},
		},
		{ -- 念力突袭
			spells = {
				{329113},
				{323129},
			},
			options = {
				{ -- 首领模块 分段计时条 念力突袭（✓）
					category = "BossMod",
					spellID = 329113,
					name = string.format(L["计时条%s"], T.GetIconLink(329113), T.GetIconLink(323129)),
					points = {a1 = "BOTTOM", a2 = "CENTER", x = 0, y = 300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spell_info = {
							["SPELL_CAST_SUCCESS"] = {
								[329113] = {
									dur = 6,
									color = {1, 1, 0},
									sound = "charge",
									divide_info = {
										dur = {2.5, 3, 3.5, 4},
										sound = "count",
									},
									prepare_sound = "charge",
									mute_count_down = true,
									count_down = 2,
								},
							},
						}
						
						function frame:post_update_show(sub_event, spellID)
							self.bar:SetStatusBarColor(1, 1, 0)
							self.state = 1
						end
						
						function frame:progress_update(sub_event, spellID, remain)
							if remain <= 3.5 then
								if self.state == 1 then
									self.state = 2
									self.bar:SetStatusBarColor(1, 0, 0)
								end
							elseif remain <= 1.5 then
								if self.state == 2 then
									self.state = 3
									self.bar:SetStatusBarColor(1, .3, .1)
								end
							end
						end
						
						T.InitSpellCastBar(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateSpellCastBar(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetSpellCastBar(frame)
					end,
				},
			},
		},
		{ -- 哀伤仪式
			spells = {
				{328791},
			},
			options = {
				{ -- 文字 哀伤仪式 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["连线"]..L["倒计时"],
					data = {
						spellID = 328791,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = { 
							["all"] = {
								[1.5] = {9.7},
								[2.5] = {10.9},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 328791, L["连线"], self, event, ...)
					end,
				},
				{ -- 计时条 哀伤仪式（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 328791,
					sound = "[soak_line]cast",
					glow = true,
					group = 1,
				},
				{ -- 图标 哀伤仪式（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 335338,
					hl = "red",
					tip = L["DOT"],
				},
				{ -- 团队框架高亮 哀伤仪式（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 335338,
					color = "red",
				},
				{ -- 自保技能提示 哀伤仪式（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 335338,
					threshold = 75,
				},
			},
		},
		{ -- 念力投掷
			spells = {
				{323143},
			},
			options = {
				{ -- 计时条 念力投掷（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_AURA_APPLIED",
					spellID = 323143,
					dur = 3.5,
					text = L["冲锋"],
					glow = true,
					group = 1,
					sound = "[charge]cast",
				},
			},
		},
		{ -- 释放苦痛
			spells = {
				{323236},
			},
			options = {
				{ -- 文字 释放苦痛 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["冲击波"]..L["倒计时"],
					data = {
						spellID = 323236,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {15.0, 21.8},
								[2] = {12.5, 24.2},
								[3] = {12.5, 24.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 323236, L["冲击波"], self, event, ...)
					end,
				},
				{ -- 计时条 释放苦痛（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 323236,
					text = L["冲击波"],
					sound = "[dodge]cast",
				},
			},
		},
		{ -- 痛苦爆发
			spells = {
				{1236964},
			},
			options = {
				{ -- 文字 痛苦爆发 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 1236973,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {24.3, 24.3, 24.3},
								[1.5] = {23.1},
								[2] = {24.3, 24.3, 24.3},
								[2.5] = {24.2},
								[2] = {24.3, 24.3, 24.3},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1236973, L["大圈"], self, event, ...)
					end,
				},
				{ -- 计时条 痛苦爆发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1236973,
					text = L["大圈"],
					sound = "[dodge_circle]cast",
				},
			},
		},
		{ -- 阶段转换
			title = L["阶段转换"],
			options = {
				{
					category = "PhaseChangeData",
					phase = 1.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 329104, -- 暗影之门
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 328791, -- 哀伤仪式
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,	
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 329104, -- 暗影之门
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 3,	
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 328791, -- 哀伤仪式
					count = 2,
				},
			},
		},
	},
}