local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1303\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------

---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用


G.Encounters[2675] = {
	engage_id = 3107,
	npc_id = {"234893"},
	alerts = {
		{ -- 吞噬
			spells = {
				{1217232, "5"},
				{1217241, "4"},
			},
			options = {
				{ -- 文字 吞噬 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 1217232,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {60.8, 86.2, 86.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1217232, L["拉人"], self, event, ...)
					end,
				},
				{ -- 计时条 吞噬（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1217232,
					text = L["拉人"],
					sound = "[pull]cast",
					glow = true,
					group = 1,
				},
				{ -- 图标 盛宴（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss1",
					spellID = 1217247,
					tip = L["BOSS强化"].."%s30%",
				},
			},
		},
		{ -- 入侵尖啸
			spells = {
				{1217327},
			},
			options = {
				{ -- 文字 入侵尖啸 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 1217327,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {6.2, 37.6, 48.6, 37.6, 48.6, 37.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1217327, L["召唤小怪"], self, event, ...)
					end,
				},
				{ -- 计时条 入侵尖啸（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1217327,
					text = L["召唤小怪"],
					sound = "[getnear]cast",
				},
			},
		},
		{ -- 疯狂的幼虫
			npcs = {
				{31407, "1"},
			},
			spells = {
				{1217381},
			},
			options = {
				{ -- 姓名板光环 入侵尖啸（✓）
					category = "PlateAlert",
					type = "PlateAuras",
					aura_type = "HELPFUL",
					spellID = 1217383,
				},
			},
		},
		{ -- 毒性反刍
			spells = {
				{1217436, "2"},
				{1217446},
			},
			options = {
				{ -- 文字 毒性反刍 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["放圈"]..L["倒计时"],
					data = {
						spellID = 1227745,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {							
							["all"] = {
								[1] = {15.4, 18.2, 68.0, 18.2, 68.0, 18.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss1", 1227745, L["放圈"], self, event, ...)
					end,
				},
				{ -- 计时条 毒性反刍（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227745,
					text = L["放圈"],
				},
				{ -- 图标 毒性反刍（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1227748,
					tip = L["放圈"],
					hl = "org",
					sound = "[prepare_drop]cd3",
				},
				{ -- 首领模块 毒性反刍 计时圆圈（✓）
					category = "BossMod",
					spellID = 1227748,
					name = T.GetIconLink(1227748)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1227748] = { -- 毒性反刍
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
				{ -- 自保技能提示 毒性反刍（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1227748,
					threshold = 75,
				},
				{ -- 团队框架高亮 毒性反刍（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1227748,
					color = "org",
				},
				{ -- 图标 毒性反刍（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217439,
					tip = L["DOT"],
					hl = "red",
					sound = "[sound_water]",
				},
				{ -- 团队框架高亮 毒性反刍（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1217439,
					color = "red",
				},
				{ -- 图标 消化唾沫（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1217446,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 痛击
			spells = {
				{1217664},
			},
			options = {
				{ -- 文字 痛击 近战位无人提示（✓）
					category = "TextAlert",
					type = "spell",
					color = {1, 0, 0},
					preview = T.GetSpellIcon(1217664)..L["近战无人"],
					data = {
						spellID = 1217664,
						events = {
							["UNIT_SPELLCAST_START"] = true,	
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							if unit == "boss1" and spellID == 1217664 then
								T.Start_Text_Timer(self, 3, T.GetSpellIcon(1217664)..L["近战无人"])
							end
						end
					end,
				},
			},
		},		
	},
}