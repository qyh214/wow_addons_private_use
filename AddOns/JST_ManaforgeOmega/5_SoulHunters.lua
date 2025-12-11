local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["虚空"] = "虚空"
	L["复仇"] = "复仇"
	L["浩劫"] = "浩劫"
	L["转阶段位置分配"] = "转阶段位置分配"
	L["免疫无需分担"] = "%s[%d]%s使用%s，无需分担。"
	L["脆弱吃魂剩余数量"] = "%s吃魂剩余数量"
	L["注意吃魂"] = "注意吃魂"
	L["坍缩之星剩余数量"] = "%s剩余数量"
	L["交接"] = "交接"
elseif G.Client == "ruRU" then
	--L["虚空"] = "Void"
	--L["复仇"] = "Vengeance"
	--L["浩劫"] = "Havoc"
	--L["转阶段位置分配"] = "Intermission location assignment"
	--L["免疫无需分担"] = "%s[%d]%s used %s, no need to soak."
	--L["脆弱吃魂剩余数量"] = "%s spirit soak remain quantity"
	--L["注意吃魂"] = "soak spirit"
	--L["坍缩之星剩余数量"] = "%s’s remain quantity"
	--L["交接"] = "Handover"
else
	L["虚空"] = "Void"
	L["复仇"] = "Vengeance"
	L["浩劫"] = "Havoc"
	L["转阶段位置分配"] = "Intermission location assignment"
	L["免疫无需分担"] = "%s[%d]%s used %s, no need to soak."
	L["脆弱吃魂剩余数量"] = "%s spirit soak remain quantity"
	L["注意吃魂"] = "soak spirit"
	L["坍缩之星剩余数量"] = "%s’s remain quantity"
	L["交接"] = "Handover"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2688] = {
	engage_id = 3122,
	npc_id = {"237661", "237660", "237662"},
	alerts = {
		{ -- NPC
			npcs = {
				{32500},--【阿达拉斯·暮焰】
				{31792},--【维拉瑞安·血愤】
				{31791},--【伊利萨·悲夜】
			},
			options = {
				{ -- 首领模块 姓名板标记 阿达拉斯·暮焰
					category = "BossMod",
					spellID = 1232569,
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("237661"))..T.hex_str(L["虚空"], {.23, .35, .96}),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("npc237661")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						G.NameplateTextures["npc237661"] = {
							w = 70,
							h = 30,
							text = L["虚空"],
							fs = 16,
							fc = {.23, .35, .96},
						}
						
						frame.mobID = "237661"
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							local GUID = UnitGUID(unit)
							local npcID = select(6, strsplit("-", GUID))
							if npcID == frame.mobID then
								T.ShowNameplateExtraTex(unit, "npc237661")
							end
						elseif event == "ENCOUNTER_START" then
							for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
								local unit = namePlate.namePlateUnitToken
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID and npcID == frame.mobID then
									T.ShowNameplateExtraTex(unit, "npc237661")
								end
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
				{ -- 首领模块 姓名板标记 维拉瑞安·血愤
					category = "BossMod",
					spellID = 1231501,
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("237660"))..T.hex_str(L["浩劫"], {.72, .94, .19}),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("npc237660")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						G.NameplateTextures["npc237660"] = {
							w = 70,
							h = 30,
							text = L["浩劫"],
							fs = 16,
							fc = {.72, .94, .19},
						}
						
						frame.mobID = "237660"
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							local GUID = UnitGUID(unit)
							local npcID = select(6, strsplit("-", GUID))
							if npcID == frame.mobID then
								T.ShowNameplateExtraTex(unit, "npc237660")
							end
						elseif event == "ENCOUNTER_START" then
							for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
								local unit = namePlate.namePlateUnitToken
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID and npcID == frame.mobID then
									T.ShowNameplateExtraTex(unit, "npc237660")
								end
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
				{ -- 首领模块 姓名板标记 伊利萨·悲夜
					category = "BossMod",
					spellID = 1232568,
					name = string.format(L["NAME姓名板标记"], T.GetNameFromNpcID("237662"))..T.hex_str(L["复仇"], {.92, .62, .86}),
					points = {hide = true},
					events = {
						["NAME_PLATE_UNIT_ADDED"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("npc237662")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						G.NameplateTextures["npc237662"] = {
							w = 70,
							h = 30,
							text = L["复仇"],
							fs = 16,
							fc = {.92, .62, .86},
						}
						
						frame.mobID = "237662"
					end,
					update = function(frame, event, ...)
						if event == "NAME_PLATE_UNIT_ADDED" then
							local unit = ...
							local GUID = UnitGUID(unit)
							local npcID = select(6, strsplit("-", GUID))
							if npcID == frame.mobID then
								T.ShowNameplateExtraTex(unit, "npc237662")
							end
						elseif event == "ENCOUNTER_START" then
							for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
								local unit = namePlate.namePlateUnitToken
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID and npcID == frame.mobID then
									T.ShowNameplateExtraTex(unit, "npc237662")
								end
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
					end,
				},
			},
		},
		{ -- 吞噬者之怒
			npcs = {
				{32500},--【阿达拉斯·暮焰】
			},
			spells = {
				{1222232, "5,7"},--【吞噬者之怒】
				--{1234565},--【吞噬】
				--{1222310},--【无餍之饥】
			},
			options = {
				{ -- 图标 吞噬者之怒（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1222232,
					hl = "blu",
					ficon = "7",
				},
				{ -- 图标 吞噬（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1222307,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],
				},
				{ -- 首领模块 团队框架吸收治疗数值（✓）
					category = "BossMod",
					spellID = 1222307,
					ficon = "2",
					name = L["团队框架吸收治疗数值"],
					points = {hide = true},
					events = {
						["UNIT_HEAL_ABSORB_AMOUNT_CHANGED"] = true,
					},
					init = function(frame)
						T.InitRFHealAbsorbValues(frame)			
					end,
					update = function(frame, event, ...)
						T.UpdateRFHealAbsorbValues(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRFHealAbsorbValues(frame)
					end,
				},
				{ -- 首领模块 吞噬者之怒 分配及驱散（待测试）
					category = "BossMod",
					spellID = 1222232,
					enable_tag = "spell",
					name = T.GetIconLink(1222232)..L["分配"].."("..string.format(L["NAME驱散提示"], T.GetIconLink(1222232))..")",
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 350},
					events = {
						["JST_MACRO_PRESSED"] = true,
						["JST_DISPEL_EVENT"] = true,
						["JST_CUSTOM"] = true,
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn",
						},
						{
							key = "mrt_analysis_btn",
						},
						{
							key = "dur_sl",
							text = L["持续时间"],
							default = 10,
							min = 5,
							max = 15,
						},
					},
					init = function(frame)
						frame.GUIDToHealerGUID = {}
						frame.backupHealerGUIDs = {}
						frame.lastDispelAssignmentTime = {}
						frame.macroPressed = false	
						frame.Ire_spellID = 1222232
						frame.Hunger_spellID = 1222310						
						
						frame.assignment = {}
						frame.backups = {}
						frame.marks = {}
						frame.count = 0
						
						frame.dispelTime = {57.0, 35.0, 59.0, 39.0, 35.0, 57.0, 40.0, 34.0, 50.0}
						
						frame.text_frame_handover = T.CreateAlertTextShared("bossmod"..frame.config_id.."handover", 2)
						frame.text_frame_dispeler = T.CreateAlertTextShared("bossmod"..frame.config_id.."dispeler", 1)
						frame.text_frame_dispelee = T.CreateAlertTextShared("bossmod"..frame.config_id.."dispelee", 1)

						function frame:copy_mrt()
							local str = [[
								#%dstart%s
								{rt1} damager damager healer
								{rt4} damager damager healer
								{rt6} damager damager healer
								
								player player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(self.config_id))
						end
						
						function frame:ReadNote(display)
							self.GUIDToHealerGUID = table.wipe(self.GUIDToHealerGUID)
							self.backupHealerGUIDs = table.wipe(self.backupHealerGUIDs)
							self.marks = table.wipe(self.marks)
							self.assignment = table.wipe(self.assignment)
							self.backups = table.wipe(self.backups)
							
							local assignedHealerGUIDs = {}
							local set = 0
							
							for _, line in T.IterateNoteAssignment(self.config_id) do
								local GUIDs, containsPlayerGUID, mark = T.LineToGUIDArray(line)
								
								if next(GUIDs) then
									set = set + 1
									
									if set <= 3 then
										self.assignment[set] = {}
										
										local str = string.format("[%d]", set)
										
										if mark then
											self.marks[set] = mark
											str = str..T.FormatRaidMark(mark)
										end
										
										local healerGUID
										for _, GUID in ipairs(GUIDs) do
											str = str.." "..T.ColorNickNameByGUID(GUID)
											tInsertUnique(self.assignment[set], GUID)
											
											local unit = T.GUIDToUnit(GUID)
											local isHealer = UnitGroupRolesAssigned(unit) == "HEALER"
											
											if isHealer and not healerGUID then
												healerGUID = GUID
												tInsertUnique(assignedHealerGUIDs, healerGUID)
											end
										end
										
										-- Assign each GUID to be dispelled by the found healer
										if healerGUID then
											for _, GUID in pairs(GUIDs) do
												self.GUIDToHealerGUID[GUID] = healerGUID											
											end
											str = str..string.format("(%s:%s)", L["驱散"], T.ColorNickNameByGUID(healerGUID))
										end
										
										if display then
											T.msg(str)
										end
									elseif set == 4 then
										for _, GUID in pairs(GUIDs) do
											table.insert(self.backups, GUID)
										end
									end
								end
							end
							
							-- Find unassigned healer GUIDs, they are first prio in the backup list
							for unit in T.IterateGroupMembers() do
								local GUID = UnitGUID(unit)
								local isVisible = UnitIsVisible(unit)
								local isHealer = UnitGroupRolesAssigned(unit) == "HEALER"
								local isAssigned = tContains(assignedHealerGUIDs, GUID)
								
								if isVisible and isHealer and not isAssigned then
									table.insert(self.backupHealerGUIDs, GUID)
								end
							end
							
							table.sort(self.backupHealerGUIDs)
							table.sort(assignedHealerGUIDs)
							
							tAppendAll(self.backupHealerGUIDs, assignedHealerGUIDs)
							
							local str = L["替补驱散优先级"]
							for _, GUID in pairs(self.backupHealerGUIDs) do
								local healer_name = T.ColorNickNameByGUID(GUID)
								str = str.." "..healer_name
							end
							
							if display then
								T.msg(str)
							end 
						end
						
						function frame:GetDebuffSet()
							local debuffed_GUIDs = {}
							local set_GUIDs = {}
							
							for unit in T.IterateGroupMembers() do
								if AuraUtil.FindAuraBySpellID(self.Ire_spellID, unit, "HARMFUL") then
									local GUID = UnitGUID(unit)
									debuffed_GUIDs[GUID] = 0
								end
							end
							
							for set, GUIDs in pairs(self.assignment) do
								for _, GUID in pairs(GUIDs) do
									if debuffed_GUIDs[GUID] and debuffed_GUIDs[GUID] == 0 then
										set_GUIDs[set] = GUID
										debuffed_GUIDs[GUID] = set
									end
								end
							end
							
							for GUID, set in pairs(debuffed_GUIDs) do
								if debuffed_GUIDs[GUID] == 0 then
									for set = 1, 3 do
										if not set_GUIDs[set] then
											set_GUIDs[set] = GUID
											debuffed_GUIDs[GUID] = set
											break
										end
									end	
								end
							end
							
							return set_GUIDs
						end
						
						function frame:CheckPlayer(GUID)
							local unit = T.GUIDToUnit(GUID)
							local alive = not UnitIsDeadOrGhost(unit)
							local debuffed = AuraUtil.FindAuraBySpellID(self.Hunger_spellID, unit, "HARMFUL")
							
							if alive and not debuffed then
								return true
							end
						end
						
						function frame:GetNextPlayer()
							local set_GUIDs = self:GetDebuffSet()
							local backups = CopyTable(self.backups)
							
							for set = 1, 3 do
								local mark = self.marks[set]
								local GUIDs = {}
								
								if self.assignment[set] and next(self.assignment[set]) then
									for index, GUID in pairs(self.assignment[set]) do
										if self:CheckPlayer(GUID) then
											table.insert(GUIDs, {index = index, GUID = GUID})
										end
									end
								end
								
								if next(GUIDs) then
									table.sort(GUIDs, function(a, b)
										return a.index < b.index
									end)
									T.FireEvent("JST_CUSTOM", self.config_id, set, mark, set_GUIDs[set], GUIDs[1]["GUID"])
								else
									for index, backupGUID in pairs(backups) do
										if self:CheckPlayer(backupGUID) then
											table.remove(backups, index)
											T.FireEvent("JST_CUSTOM", self.config_id, set, mark, set_GUIDs[set], backupGUID, true)
											break
										end
									end
								end
							end
						end
						
						function frame:StartTimer()
							self.count = self.count + 1
							local next_dur = self.dispelTime[self.count]
							if next_dur then
								local ahead = C.DB["BossMod"][self.config_id]["dur_sl"]
								local wait = next_dur - ahead
								self.timer = C_Timer.NewTimer(wait, function()
									self:GetNextPlayer()
									self.timer_progress = C_Timer.NewTimer(ahead, function()
										self:StartTimer()
									end)
								end)
							end
						end
						
						function frame:AssignHealer(GUID, healerGUID)
							self.lastDispelAssignmentTime[healerGUID] = GetTime()
							
							if healerGUID == G.PlayerGUID then
								self.currentTarget = GUID
								
								local info = T.GetGroupInfobyGUID(GUID)
								T.GlowRaidFramebyUnit_Hide("pixel", "bm"..self.config_id, info.unit)
								T.GlowRaidFramebyUnit_Show("proc", "bm"..self.config_id, info.unit, {0, 1, 0})
								T.Start_Text_Timer(self.text_frame_dispeler, 5, L["驱散"]..info.format_name)
								
								T.PlaySound("dispel_now")
								C_Timer.After(1, function()
									local name = T.GetNameByGUID(GUID)
									if name then
										T.SpeakText(name)
									end
								end)
							elseif GUID == G.PlayerGUID then
								local healer_name = T.ColorNickNameByGUID(healerGUID)
								T.Start_Text_Timer(self.text_frame_dispelee, 5, healer_name..L["驱散你"])
							end
						end
					end,
					update = function(frame, event, ...)			
						if event == "JST_MACRO_PRESSED" then
							local arg = ...
							if arg == "DispelMe" and C_UnitAuras.GetPlayerAuraBySpellID(frame.Ire_spellID) and not frame.macroPressed then -- Devourer's Ire
								frame.macroPressed = true
								
								T.SendChatMsg(L["已按宏"], nil, "RAID")
								T.addon_msg("dispel_event,"..frame.Ire_spellID, "GROUP")
							end
						
						elseif event == "JST_DISPEL_EVENT" then
							local unit, GUID, spellID = ...
							
							if spellID ~= frame.Ire_spellID then return end
							
							local assignedHealerGUID = frame.GUIDToHealerGUID[GUID]
							
							-- If the player that pressed their macro has a healer assigned to them, assign them if possible
							if assignedHealerGUID then
								local assignedHealerUnit = T.GUIDToUnit(assignedHealerGUID)
								local isAlive = not UnitIsDeadOrGhost(assignedHealerUnit)
								
								if isAlive then
									frame:AssignHealer(GUID, assignedHealerGUID)
									return
								end
							end
							
							for _, healerGUID in ipairs(frame.backupHealerGUIDs) do
								local healerUnit = T.GUIDToUnit(healerGUID)
								local isAlive = not UnitIsDeadOrGhost(healerUnit)
								local lastDispelAssignmentTime = frame.lastDispelAssignmentTime[healerGUID] or 0
								local isAffected = AuraUtil.FindAuraBySpellID(frame.Ire_spellID, healerUnit, "HARMFUL")
								
								if isAlive and not isAffected and lastDispelAssignmentTime < GetTime() - 8 then
									frame:AssignHealer(GUID, healerGUID)
									return
								end
							end
							
							-- Assign the highest priority backup healer (first in the array) that is alive/not affected
							-- Basically the same as above, but don't check for last dispel assignment time
							-- This should practically ever happen
							for _, healerGUID in ipairs(frame.backupHealerGUIDs) do
								local healerUnit = T.GUIDToUnit(healerGUID)
								local isAlive = not UnitIsDeadOrGhost(healerUnit)
								local isAffected = AuraUtil.FindAuraBySpellID(frame.Ire_spellID, healerUnit, "HARMFUL")
								
								if isAlive and not isAffected then
									frame:AssignHealer(GUID, healerGUID)
									return
								end
							end
						
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if sub_event == "SPELL_AURA_APPLIED" and spellID == frame.Ire_spellID then
								if destGUID == G.PlayerGUID then
									frame.macroPressed = false
									T.Stop_Text_Timer(frame.text_frame_handover)
								end
								
								-- If we are the assigned healer to dispel the target, glow their frame red
								local assignedHealerGUID = frame.GUIDToHealerGUID[destGUID]
								if assignedHealerGUID == G.PlayerGUID then
									local unit = T.GUIDToUnit(destGUID)
									T.GlowRaidFramebyUnit_Show("pixel", "bm"..frame.config_id, unit, {1, 0, 0})
								end
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.Ire_spellID then
								if destGUID == G.PlayerGUID then
									T.Stop_Text_Timer(frame.text_frame_dispelee)
									T.Stop_Text_Timer(frame.text_frame_handover)
								end
								
								local assignedHealerGUID = frame.GUIDToHealerGUID[destGUID]
								if assignedHealerGUID == G.PlayerGUID or frame.currentTarget == destGUID then
									local unit = T.GUIDToUnit(destGUID)
									T.GlowRaidFramebyUnit_Hide("pixel", "bm"..frame.config_id, unit)
									T.GlowRaidFramebyUnit_Hide("proc", "bm"..frame.config_id, unit)
									T.Stop_Text_Timer(frame.text_frame_dispeler)
								end
							end
							
						elseif event == "JST_CUSTOM" then
							local id, set, mark, handover_GUID, takeover_GUID, backup = ...
							
							if id ~= frame.config_id then return end
							
							local mark_str = mark and T.FormatRaidMark(mark) or ""
							local name1 = T.ColorNickNameByGUID(handover_GUID)
							local name2 = T.ColorNickNameByGUID(takeover_GUID)
							
							if name1 and name2 then
								T.msg(string.format("[%d]%s %s→%s", set, mark_str, name1, name2))
								
								if handover_GUID == G.PlayerGUID or takeover_GUID == G.PlayerGUID then
									local name = handover_GUID == G.PlayerGUID and name2 or name1
									local dur = C.DB["BossMod"][frame.config_id]["dur_sl"]
									
									if mark then
										T.Start_Text_Timer(frame.text_frame_handover, dur, string.format("%s %s %s", mark_str, L["交接"], name), true)
										T.SendChatMsg(string.format("{rt%1$d}{rt%1$d}{rt%1$d} %2$s", mark, L["交接"]), dur, "YELL")
										T.PlaySound("1302\\handover", "mark\\mark"..mark)
									else
										T.Start_Text_Timer(frame.text_frame_handover, dur, string.format("%s %s", L["交接"], name), true)
										T.SendChatMsg(L["交接"], dur, "YELL")
										T.PlaySound("1302\\handover")
									end
								end
							end
							
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame:StartTimer()
							
							frame.macroPressed = false
							frame.lastDispelAssignmentTime = table.wipe(frame.lastDispelAssignmentTime)
							
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						frame.currentTarget = nil
						if frame.timer then
							frame.timer:Cancel()
						end
						if frame.timer_progress then
							frame.timer_progress:Cancel()
						end
						T.GlowRaidFrame_HideAll("pixel","bm"..frame.config_id)
						T.GlowRaidFrame_HideAll("proc","bm"..frame.config_id)
						T.Stop_Text_Timer(frame.text_frame_handover)
						T.Stop_Text_Timer(frame.text_frame_dispeler)
						T.Stop_Text_Timer(frame.text_frame_dispelee)
					end,
				},
				{ -- 图标 无餍之饥（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1222310,
					text = L["易伤"],
					hl = "",
				},
				{ -- 首领模块 无餍之饥 层数监控（待测试）
					category = "BossMod",
					spellID = 1222310,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1222310)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -30},
					events = {
						["UNIT_AURA"] = true,
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
					},
					init = function(frame)
						frame.bar_num = 2
						frame.Ire_spellID = 1222232
						frame.Hunger_spellID = 1222310	
						
						frame.spellIDs = {
							[1222310] = { -- 无餍之饥
								aura_type = "HARMFUL", 
								icon = 3163628,
								color = {0.95, .1, .05},
							},
						}
						
						function frame:filter(auraID, spellID, GUID)
							local unit = T.GUIDToUnit(GUID)
							if AuraUtil.FindAuraBySpellID(self.Ire_spellID, unit, "HARMFUL") then
								return true
							end
						end
						
						function frame:post_create_bar(bar, auraID, spellID, GUID)
							bar:SetMinMaxValues(0 , 1)
							bar:SetValue(1)
						end
						
						function frame:custom_update(bar, spellID, count, dur, exp_time, effect_value)
							local count = select(3, AuraUtil.FindAuraBySpellID(self.Hunger_spellID, bar.unit, "HARMFUL"))
							if count then
								bar.right:SetText((count > 0 and "|cffFFFF00["..count.."]|r " or ""))
							end
						end
						
						function frame:check(unit)
							local count = AuraUtil.FindAuraBySpellID(self.Hunger_spellID, unit, "HARMFUL")
							if count then
								local spellName = C_Spell.GetSpellName(self.Hunger_spellID)
								local auraData = C_UnitAuras.GetAuraDataBySpellName(unit, spellName, "HARMFUL")
								if auraData then
									local auraID = auraData.auraInstanceID
									local GUID = UnitGUID(unit)
									self:create_bar(auraID, self.Hunger_spellID, GUID)
									self:update_bar(auraID, self.Hunger_spellID, auraData.applications, auraData.duration, auraData.expirationTime, 0)
								end
							end
						end
						
						function frame:cancel(unit)
							for auraID, bar in pairs(frame.bars) do
								if UnitIsUnit(bar.unit, unit) then
									frame:remove_bar(auraID)
									break
								end
							end
						end
						
						T.InitUnitAuraBars(frame)			
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
						
						if event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == frame.Ire_spellID then
								frame:check(unit)
							end
							
						elseif event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if spellID == frame.Ire_spellID then
								frame:cancel(unit)
							end
							
						elseif event == "ENCOUNTER_START" then
							T.RegisterWatchAuraSpellID(frame.Ire_spellID)
						end
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
						T.UnregisterWatchAuraSpellID(frame.Ire_spellID)
					end,
				},
			},
		},
		{ -- 虚空瞬步
			npcs = {
				{32500},--【阿达拉斯·暮焰】
			},
			spells = {
				{1227355},--【虚空瞬步】
				--{1227685},--【饥渴斩击】
				--{1235045},--【湮灭逼近】
			},
			options = {
				{ -- 文字 虚空瞬步 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1227355)..L["倒计时"],
					data = {
						spellID = 1227355,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {33.0, 31.1, 28.1},
								[2] = {21.2, 31.1, 28.1},
								[3] = {21.2, 31.1, 28.1},
								[4] = {20.2, 31.1},
							},
							[16] = {
								[1] = {26.5, 33.7},
								[2] = {15.2, 33.7},
								[3] = {15.7, 33.7},
								[4] = {8.4},
							},	
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1227355, T.GetIconLink(1227355), self, event, ...)
					end,
				},
				{ -- 计时条 虚空瞬步（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227355,
					sound = "[mindstep]cast",
				},
				{ -- 图标 湮灭逼近（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1235045,
					tip = L["DOT"],
					hl = "pur",
				},
				{ -- 自保技能提示 湮灭逼近（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1235045,
					threshold = 65,
				},
			},
		},
		{ -- 根除
			npcs = {
				{32500},--【阿达拉斯·暮焰】
			},
			spells = {
				{1245743, "12,4"},--【根除】
			},
			options = {
				{ -- 计时条 根除（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1245726,
					text = L["躲地板"],
				},
			},
		},
		{ -- 坍缩之星
			npcs = {
				{32566},--【阿达拉斯·暮焰】
			},
			spells = {
				{1233093, "5"},--【坍缩之星】
				--{1233105},--【黑暗残渣】
				--{1233968, "4"},--【黑洞视界】
			},
			options = {
				{ -- 计时条 坍缩之星（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1233093,
					text = L["拉人"],
					sound = "[pull]cast",
				},
				{ -- 首领模块 坍缩之星 剩余数量（待测试）
					category = "BossMod",
					spellID = 1233968,
					enable_tag = "rl",
					name = string.format(L["坍缩之星剩余数量"], T.GetIconLink(1233093)),
					points = {a1 = "CENTER", a2 = "TOP", x = 0, y = -50, width = 80, height = 40},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)	
						frame.soaksPerPlayer = 2
						frame.maxHits = 0
						frame.count = 0
						frame.total_count = 0
						frame.hits = {}
						
						frame.text = T.createtext(frame, "OVERLAY", 40, "OUTLINE", "CENTER")
						frame.text:SetPoint("CENTER")
						frame.text:SetTextColor(.33, .2, 1)
						
						function frame:GetTotalNumber()
							local total = 0 -- Total number of soaks
							
							for unit in T.IterateGroupMembers() do
								local isAlive = not UnitIsDeadOrGhost(unit)
								local isVisible = UnitIsVisible(unit)
								
								if isAlive and isVisible then
									total = total + self.soaksPerPlayer
								end
							end
							
							total = math.ceil(total)
							
							return total
						end
						
						function frame:UpdateText(force_show)
							self.text:SetText(string.format("%s %d/%d", T.GetSpellIcon(1233093), self.count, self.total_count))
							if self.count > 0 or force_show then
								self.text:Show()
							else
								self.text:Hide()
							end
						end
						
						function frame:PreviewShow()
							local count = math.random(0, 40)
							self.text:SetText(string.format("%s %d/%d", T.GetSpellIcon(1233093), count, 40))
							self.text:Show()
						end
						
						function frame:PreviewHide()
							self.text:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE") and spellID == 1233093 then -- 坍缩之星 (boss)
								local total = frame:GetTotalNumber()
								frame.maxHits = 0
								frame.hits = table.wipe(frame.hits)
								frame.count = total
								frame.total_count = total
								
								frame:UpdateText(true)
								
							elseif sub_event == "SPELL_DAMAGE" or sub_event == "SPELL_MISSED" then
								if spellID == 1233104 then -- 坍缩之星 (球进中间)
									local hits = (frame.hits[destGUID] or 0) + 1
									frame.hits[destGUID] = hits
									
									if hits > frame.maxHits then
										frame.maxHits = hits
										frame.count = frame.count - 1
										frame:UpdateText()	
									end
								elseif spellID == 1233103 then -- 坍缩之星 (吃球)
									frame.count = frame.count - 1
									frame:UpdateText()
								end
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1233093 then -- 坍缩之星 (boss)
								frame.text:Hide()
								
							end
						elseif event == "ENCOUNTER_START" then
							local _, _, difficultyID = ...
							
							frame.soaksPerPlayer = difficultyID == 16 and 2.5 or 2
							frame.hits = table.wipe(frame.hits)
							frame.maxHits = 0
						end
					end,
					reset = function(frame, event)
						frame.text:Hide()
						frame:Hide()
					end,
				},
				{ -- 图标 黑暗残渣（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1233105,
					tip = L["DOT"],
					hl = "red",
				},
				{ -- 文字 黑暗残渣 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1233105)..L["倒计时"],
					data = {
						spellID = 1233105,
						events =  {
							["UNIT_AURA_ADD"] = true,
							["UNIT_AURA_UPDATE"] = true,
							["UNIT_AURA_REMOVED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "UNIT_AURA_ADD" or event == "UNIT_AURA_UPDATE" then
							local unit, spellID, auraID = ...
							if unit == "player" and spellID == self.data.spellID then
								local aura_data = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraID)
								if aura_data and aura_data.applications > 0 then
									local remain = aura_data.expirationTime - GetTime()
									T.Start_Text_Timer(self, remain, string.format("%s|cffff0000[%d]|r", T.GetSpellIcon(1233105), aura_data.applications), true)
									T.PlaySound("sound_water")
								else
									T.Stop_Text_Timer(self)
								end
							end
						elseif event == "UNIT_AURA_REMOVED" then
							local unit, spellID = ...
							if unit == "player" and spellID == self.data.spellID then
								T.Stop_Text_Timer(self)
							end
						end
					end,
				},
				{ -- 自保技能提示 黑暗残渣（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1233105,
					threshold = 65,
				},
				{ -- 图标 黑洞视界（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1233968,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 恶魔追击
			npcs = {
				{31792},--【维拉瑞安·血愤】
			},
			spells = {
				{1227809, "5"},--【恶魔追击】
				--{1247415, "12"},--【弱化猎物】
			},
			options = {
				{ -- 文字 恶魔追击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["冲锋"]..L["倒计时"],
					data = {
						spellID = 1227809,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							["all"] = {
								[1] = {42.6, 34.9},
								[2] = {31.0, 34.9},
								[3] = {31.0, 34.9},
								[4] = {8.0},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1227809, L["冲锋"], self, event, ...)
					end,
				},				
				{ -- 首领模块 恶魔追击 计时圆圈（✓）
					category = "BossMod",
					spellID = 1227847,
					name = T.GetIconLink(1227847)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1227847] = { -- 恶魔追击
								event = "SPELL_AURA_APPLIED",
								target_me = true,
								dur = 6,
								color = {1, 0, 0},
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
				{ -- 首领模块 计时条 恶魔追击（✓）
					category = "BossMod",
					spellID = 1227809,
					name = string.format(L["计时条%s"], T.GetIconLink(1227847)),
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_GROUP_CD_UPDATE"] = true,
					},
					custom = {
						{
							key = "raid_index_bool",
							text = L["团队序号"],
							default = true,
						},
					},
					init = function(frame)
						frame.bars = {}
						frame.count = 0
						frame.max_count = 3
						frame.trackedspellIDs = {}
						
						frame.immuse_class = {
							--DRUID = 22812, -- 树皮术
							MAGE = 45438, -- Ice Block
							DEMONHUNTER = 196555, -- Netherwalk
							HUNTER = 186265, -- Turtle
							PALADIN = 642, -- Divine Shield
							PRIEST = 47585, -- Dispersion
							ROGUE = 31224, -- Cloak of Shadows
						}
						
						for _, spellID in pairs(frame.immuse_class) do
							frame.trackedspellIDs[spellID] = true
						end
						
						function frame:UpdateImmuseBuff(GUID)
							local bar = self.bars[GUID]
							if not bar then return end
							
							local info = T.GetGroupInfobyGUID(GUID)
							local unit = info.unit
							local spellID = self.immuse_class[info.class]
							
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
							elseif bar.spell_icon then
								bar.spell_icon:Hide()
							end							
						end
						
						function frame:CreateBar(GUID)
							local bar = T.CreateAlertBarShared(2, "bossmod"..self.config_id..GUID, C_Spell.GetSpellTexture(1227847), L["冲锋"])
							self.bars[GUID] = bar
							
							return bar
						end
						
						function frame:start(set, GUID)
							local bar = self.bars[GUID] or self:CreateBar(GUID)
							
							local info = T.GetGroupInfobyGUID(GUID)
							bar.mid:SetText(info and info.format_name or "")
							
							self:UpdateImmuseBuff(GUID)
							T.StartTimerBar(bar, 6, true, true)
							
							if self.difficultyID == 16 then
								bar.ind_text:SetText(string.format("|cffFFFF00[%d]|r", set))
															
								if C.DB["BossMod"][self.config_id]["raid_index_bool"] then
									T.CreateRFIndex(GUID, string.format("|cffFF0000%d|r", set))
									C_Timer.After(6, function()
										T.HideRFIndexbyGUID(GUID)
									end)
								end
							else
								bar.ind_text:SetText("")
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1227847 then -- 恶魔追击
								frame.count = frame.count + 1
            
								if frame.count == (frame.max_count + 1) then
									frame.count = 1
								end
								
								frame:start(frame.count, destGUID)
								
							elseif sub_event == "SPELL_AURA_APPLIED" and frame.trackedspellIDs[spellID] then
								frame:UpdateImmuseBuff(destGUID)
								
							elseif sub_event == "SPELL_AURA_REMOVED" and frame.trackedspellIDs[spellID] then
								frame:UpdateImmuseBuff(destGUID)
								
							end
							
						elseif event == "JST_GROUP_CD_UPDATE" then
							for GUID, bar in pairs(frame.bars) do
								frame:UpdateImmuseBuff(GUID)
							end
							
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							
							frame.difficultyID = select(3, ...)
							
							if frame.difficultyID == 16 then
								frame.max_count = 3
							else
								frame.max_count = 2
							end
						end
					end,
					reset = function(frame, event)
						for _, bar in pairs(frame.bars) do
							T.StopTimerBar(bar, true, true)
						end
						frame.bars = table.wipe(frame.bars)
						T.HideAllRFIndex()
					end,
				},
				{ -- 首领模块 恶魔追击 分配（待测试）
					category = "BossMod",
					spellID = 1247415,
					ficon = "12",
					enable_tag = "spell",
					name = T.GetIconLink(1227847)..L["分配"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn",
						},
						{
							key = "mrt_analysis_btn",
						},
						{
							key = "sound_bool",
							text = L["音效"],
							default = true,
						},
					},
					init = function(frame)
						frame.assignment = {}
						frame.soakGUIDs = {}
						frame.count = 0
						frame.max_count = 3
						frame.trackedspellIDs = {}
						
						frame.immuse_class = {
							--DRUID = 22812, -- 树皮术
							MAGE = 45438, -- Ice Block
							DEMONHUNTER = 196555, -- Netherwalk
							HUNTER = 186265, -- Turtle
							PALADIN = 642, -- Divine Shield
							PRIEST = 47585, -- Dispersion
							ROGUE = 31224, -- Cloak of Shadows
						}
						
						for _, spellID in pairs(frame.immuse_class) do
							frame.trackedspellIDs[spellID] = true
						end
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:copy_mrt()
							local str = [[
								#%dstart%s
								player player player player player player
								player player player player player player
								player player player player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(1227847))
						end
						
						function frame:ReadNote(display)
							self.assignment = table.wipe(self.assignment)
							
							local set = 0
							
							for _, line in T.IterateNoteAssignment(self.config_id) do
								local GUIDs = T.LineToGUIDArray(line)
								
								if next(GUIDs) then
									set = set + 1
									
									if set <= 3 then
										self.assignment[set] = {}
										
										local str = string.format("[%d]", set)
										
										for _, GUID in ipairs(GUIDs) do
											str = str.." "..T.ColorNickNameByGUID(GUID)
											tInsertUnique(self.assignment[set], GUID)									
										end
										
										if display then
											T.msg(str)
										end
									end
								end
							end
						end
													
						function frame:PlayerCheck(GUID)
							local unit = T.GUIDToUnit(GUID)
							if unit then
								local alive = not UnitIsDeadOrGhost(unit)
								local debuffed1 = AuraUtil.FindAuraBySpellID(1222232, unit, "HARMFUL") -- 吞噬者之怒
								local debuffed2 = AuraUtil.FindAuraBySpellID(1247415, unit, "HARMFUL") -- 弱化猎物
								
								if alive and not debuffed1 and not debuffed2 then        
									return true
								end
							end
						end
						
						function frame:UpdateSoak(set, GUID)
							local soak_GUIDs = self.assignment[set]
							
							if soak_GUIDs then
								self.soakGUIDs[GUID] = set
								C_Timer.After(6, function()
									self.soakGUIDs[GUID] = nil
								end)
								
								local info = T.GetGroupInfobyGUID(GUID)
								local spellID = self.immuse_class[info.class]
								local ImmuseStr = ""
								if spellID then
									local ready, exp_time, duration, remain = T.GetGroupCooldown(GUID, spellID)
									if ready or (remain and remain <= 4) then
										ImmuseStr = T.GetSpellIcon(spellID)
									end
								end
								
								local str = string.format("%s %s [%d] %s%s : ", T.GetIconLink(1227847), L["分担伤害"], set, T.ColorNickNameByGUID(GUID), ImmuseStr)
								for _, soak_GUID in pairs(soak_GUIDs) do
									if self:PlayerCheck(soak_GUID) then
										str = str .. T.ColorNickNameByGUID(soak_GUID)
										if soak_GUID == G.PlayerGUID then
											T.Start_Text_Timer(self.text_frame, 6, string.format("%s %s|cffff0000[%d]|r %s", L["分担"], T.GetSpellIcon(1227847), set, ImmuseStr), true)
											if C.DB["BossMod"][self.config_id]["sound_bool"] then
												T.PlaySound("sharedmg")
											end
										end
									end
								end
								
								T.msg(str)
							end
						end
						
						function frame:UpdateImmuseUse(GUID, spellID)
							local set = self.soakGUIDs[GUID]
							local soak_GUIDs = set and self.assignment[set]
							if soak_GUIDs then
								T.msg(string.format(L["免疫无需分担"], T.GetIconLink(1227847), set, T.ColorNickNameByGUID(GUID), T.GetIconLink(spellID)))	
								if tContains(soak_GUIDs, G.PlayerGUID) then
									T.Stop_Text_Timer(self.text_frame)
									if C.DB["BossMod"][self.config_id]["sound_bool"] then
										T.PlaySound("dontsharedmg")
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1227847 then -- 恶魔追击
								frame.count = frame.count + 1
            
								if frame.count == (frame.max_count + 1) then
									frame.count = 1
								end
								
								frame:UpdateSoak(frame.count, destGUID)
								
							elseif sub_event == "SPELL_AURA_APPLIED" and frame.trackedspellIDs[spellID] then
								frame:UpdateImmuseUse(destGUID, spellID)
							end

						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						frame.soakGUIDs = table.wipe(frame.soakGUIDs)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},				
				{ -- 图标 弱化猎物（史诗待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1247415,
					tip = L["易伤"],
				},
			},
		},
		{ -- 刃舞
			npcs = {
				{31792},--【维拉瑞安·血愤】
			},
			spells = {
				{1241306},--【刃舞】
			},
			options = {
				{ -- 计时条 刃舞（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1241254,
					dur = 3,
					sound = "[mindstep]cast",
				},
			},
		},
		{ -- 眼棱
			npcs = {
				{31792},--【维拉瑞安·血愤】
			},
			spells = {
				{1218103, "0,12"},--【眼棱】
				--{1221490, "12"},--【邪能灼痕】
				--{1225127},--【邪能之刃】
			},
			options = {		
				{ -- 文字 眼棱 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(1218103)..L["倒计时"],
					data = {
						spellID = 1218103,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {19.7, 34.9, 34.9},
								[2] = {8.2, 34.9, 34.9},
								[3] = {8.2, 34.9, 34.9},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1218103, T.GetIconLink(1218103), self, event, ...)
					end,
				},
				{ -- 计时条 眼棱（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1218103,
					show_tar = true,
					sound = "[frontal]cast",
				},
				{ -- 嘲讽提示 邪能灼痕（✓）
					category = "BossMod",
					spellID = 1221490,
					ficon = "0",
					name = L["嘲讽提示"]..T.GetIconLink(1221490),
					points = {hide = true},
					events = {					
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_THREAT_SITUATION_UPDATE"] = true,
					},
					init = function(frame)
						frame.boss_npcID = "237660"
						frame.aura_spellIDs = {
							[1221490] = 1, -- 邪能灼痕
						}
						frame.cast_spellIDs = {
							[1218103] = true, -- 眼棱
						}
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
					end,
				},
				{ -- 换坦计时条 邪能灼痕（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1221490,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
				{ -- 图标 邪能之刃（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1225130,
					tip = L["DOT"],
				},
			},
		},
		{ -- 邪能地狱
			npcs = {
				{31792},--【维拉瑞安·血愤】
			},
			spells = {
				{1223725, "2"},--【邪能地狱】
			},
			options = {
				{ -- 计时条 邪能地狱（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1228238,
					dur = 22,
					text = L["全团AE"],
					tags = {5},
				},
				{ -- 图标 邪能地狱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1245384,
					tip = L["DOT"],
				},
				{ -- 图标 邪能地狱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1223725,
					tip = L["快走开"],
					sound = "[sound_dd]",
				},
			},
		},
		{ -- 邪能冲撞
			npcs = {
				{32552},--【维拉瑞安·血愤】
			},
			spells = {
				{1233863, "5"},--【邪能冲撞】
			},
			options = {
				{ -- 图标 邪能冲撞（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1223042,
					tip = L["射线"],
					sound = "[ray]",
					hl = "org_flash",
				},
			},
		},
		{ -- 破裂
			npcs = {
				{31791},--【伊利萨·悲夜】
			},
			spells = {
				{1241833, "0,5"},--【破裂】
				--{1226493},--【破碎之魂】
				{1241917},--【脆弱】
			},
			options = {
				{ -- 文字 破裂 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					ficon = "0",
					preview = T.GetIconLink(1241833)..L["倒计时"],
					data = {
						spellID = 1241833,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {15.3, 34.9, 34.9},
								[2] = {3.6, 34.9, 34.9},
								[3] = {3.6, 34.9, 34.9},
								[4] = {3.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1241833, T.GetIconLink(1241833), self, event, ...)
					end,
				},
				{ -- 计时条 破裂（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1241833,
					ficon = "0",
					show_tar = true,
					sound = soundfile("1241833cast", "cast"),
				},
				{ -- 嘲讽提示 破碎灵魂（✓）
					category = "BossMod",
					spellID = 1226493,
					ficon = "0",
					name = L["嘲讽提示"]..T.GetIconLink(1226493)..T.GetIconLink(1241917),
					points = {hide = true},
					events = {					
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_STOP"] = true,
						["UNIT_THREAT_SITUATION_UPDATE"] = true,
					},
					init = function(frame)
						frame.boss_npcID = "237662"
						frame.aura_spellIDs = {
							[1226493] = 1, -- 破碎灵魂
							[1241917] = 1, -- 脆弱
						}
						frame.cast_spellIDs = {
							[1241833] = true, -- 破裂
						}
						
						T.InitTauntAlert(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateTauntAlert(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetTauntAlert(frame)
					end,
				},
				{ -- 换坦计时条 破碎灵魂（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1226493,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
				{ -- 换坦计时条 脆弱（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1241917,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
				{ -- 嘲讽提示 脆弱吃魂剩余数量（✓）
					category = "BossMod",
					spellID = 1241917,
					name = string.format(L["脆弱吃魂剩余数量"], T.GetIconLink(1241917)),
					points = {hide = true},
					events = {					
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.vuln_spellID = 1241917
						frame.dot_spellID = 1241946
						frame.icon = T.GetSpellIcon(frame.vuln_spellID)
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:UpdateText(GUID)
							if AuraUtil.FindAuraBySpellID(self.dot_spellID, "player", "HARMFUL") then return end
							local unit = T.GUIDToUnit(GUID)
							if unit then
								local count = select(3, AuraUtil.FindAuraBySpellID(self.vuln_spellID, unit, "HARMFUL"))
								if count and self.exp_time then
									local remain = self.exp_time - GetTime()
									T.Start_Text_Timer(self.text_frame, remain, string.format("%s|cffffff00[%d]|r%s", self.icon, count, L["注意吃魂"]), true)
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if sub_event == "SPELL_CAST_SUCCESS" and spellID == 1241833 then -- 破裂
								frame.exp_time = GetTime() + 18
								
							elseif (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_APPLIED_DOSE") and spellID == frame.vuln_spellID then
								frame:UpdateText(destGUID)
								
							elseif sub_event == "SPELL_AURA_REMOVED_DOSE" and spellID == frame.vuln_spellID then
								frame:UpdateText(destGUID)
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.vuln_spellID then
								T.Stop_Text_Timer(frame.text_frame)
								
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == frame.dot_spellID and destGUID == G.PlayerGUID then
								T.Stop_Text_Timer(frame.text_frame)
							
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 图标 脆弱（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1241946,
					tip = L["DOT"],
					hl = "org",
				},
				{ -- 自保技能提示 脆弱（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1241946,
					threshold = 70,
					amount = 2,
				},
				{ -- 团队框架高亮 脆弱（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1241946,
					amount = 2,
				},
			},
		},
		{ -- 幽魂炸弹
			npcs = {
				{31791},--【伊利萨·悲夜】
			},
			spells = {
				{1242259},--【幽魂炸弹】
				--{1242284},--【灵魂重碾】
				--{1242304, "4"},--【驱逐灵魂】
			},
			options = {
				{ -- 文字 幽魂炸弹 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["吸收盾"]..L["倒计时"],
					data = {
						spellID = 1242259,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							["all"] = {
								[1] = {32.5, 34.9, 34.9},
								[2] = {21, 34.9, 34.9},
								[3] = {21, 34.9, 34.9},
								[4] = {14},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1242259, L["吸收盾"], self, event, ...)
					end,
				},
				{ -- 计时条 幽魂炸弹（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1242259,
					glow = true,
					group = 1,
				},
				{ -- 图标 灵魂重碾（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1242284,
					effect = 1,
					hl = "",
					tip = L["吸收治疗"],
				},
				{ -- 自保技能提示 灵魂重碾（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1242284,
					threshold = 65,
				},
				{ -- 图标 驱逐灵魂（待测试）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1242304,
					tip = L["DOT"],
					hl = "red",
				},				
			},
		},
		{ -- 锁链咒符
			npcs = {
				{31791},--【伊利萨·悲夜】
			},
			spells = {
				{1240891, "12"},--【锁链咒符】
			},
			options = {				
				{ -- 计时条 锁链咒符（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1240891,
					dur = 2.5,
				},
				{ -- 图标 锁链咒符（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1223624,
					tip = L["减速"].."40%",
				},
			},
		},
		{ -- 献祭光环
			npcs = {
				{31791},--【伊利萨·悲夜】
			},
			spells = {
				{1225154, "2"},--【献祭光环】
			},
			options = {
				
			},
		},		
		{ -- 地狱火撞击
			npcs = {
				{32545},--【伊利萨·悲夜】
			},
			spells = {
				{1227113, "5"},--【地狱火撞击】
			},
			options = {
				{ -- 文字 地狱火撞击 倒计时（✓）
					category = "TextAlert",
					type = "spell",
					preview = L["大圈"].."+"..L["冲击波"]..L["倒计时"],
					data = {
						spellID = 1233672,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},
						info = {
							["all"] = {
								[3.5] = {6.5, 9.0, 9.0},
							},
						},
						cd_args = {
							round = true,
							count_down_start = 5,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss", 1233672, L["大圈"].."+"..L["冲击波"], self, event, ...)
					end,
				},
				{ -- 计时条 地狱火撞击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1233672,
					dur = 2.3,
					sound = "[safe]cast",
					glow = true,
					group = 1,
				},			
			},
		},
		{ -- 邪能毁灭
			npcs = {
				{32545},--【伊利萨·悲夜】
			},
			spells = {
				{1227117, "5"},--【邪能毁灭】
				--{1233381},--【凋零烈焰】
			},
			options = {
				{ -- 首领模块 邪能毁灭 倒计时（待测试）
					category = "BossMod",
					spellID = 1227117,
					name = T.GetIconLink(1227117)..L["引头前"]..L["倒计时"],
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					init = function(frame)	
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)	
						frame.text_frame.round = true
						frame.text_frame.count_down_start = 5
						frame.text_frame.prepare_sound = "baitfront"
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, castGUID, spellID = ...
							
							if not string.find(unit, "boss") or not castGUID then return end
							
							if spellID == 1232568 then -- 恶魔变形 (伊利萨·悲夜)
								frame.metaCount = frame.metaCount + 1
								
								if frame.metaCount > 2 then
									T.Start_Text_DelayTimer(frame.text_frame, 5.6, L["引头前"], true)
								end
							elseif spellID == 1227117 then -- 邪能毁灭
								frame.felDevCount = frame.felDevCount + 1
								
								if frame.felDevCount ~= 3 then -- 3rd one is the last Fel Devastation in 3rd intermission
									T.Start_Text_DelayTimer(frame.text_frame, 8, L["引头前"], true)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.metaCount = 0
							frame.felDevCount = 0
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 计时条 邪能毁灭（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1227117,
					text = L["冲击波"],
					glow = true,
					group = 1,
				},
				{ -- 图标 凋零烈焰（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1233381,
					tip = L["减速"],
				},
			},
		},		
		{ -- 灵魂束缚
			spells = {
				{1245978, "12"},--【灵魂束缚】
			},
			options = {
				{ -- 图标 灵魂束缚（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1242883,
				},
				{ -- 首领模块 转阶段位置分配（✓）
					category = "BossMod",
					spellID = 1242883,
					ficon = "12",
					name = T.GetIconLink(1242883)..L["转阶段位置分配"].." "..string.format(L["使用标记%s"], T.FormatRaidMark("1,2,7,5,4,3,6")),
					enable_tag = "spell",
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					custom = {
						{
							key = "dur_sl",
							text = L["持续时间"],
							default = 30,
							min = 5,
							max = 30,
						},
					},
					init = function(frame)
						frame.intermissionCount = 0
						frame.affectedCount = 0
						frame.affected = {}
						frame.isWarlockOrShadowPriest = {}
						frame.isHealer = {}
						frame.indexToMark = {1, 2, 7, 5, 4, 3, 6}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:assign()
							self.intermissionCount = self.intermissionCount + 1
        
							-- Sort all subgroups
							for _, group in pairs(self.affected) do
								table.sort(group)
							end
							
							-- Sort groups
							-- Warlocks and Shadow Priests should be close to star
							table.sort(self.affected, function(groupA, groupB)
								if #groupA == 0 then return false end
								if #groupB == 0 then return true end
								
								-- Count warlocks/shadow priests in group A
								local countA = 0
								
								for _, GUID in pairs(groupA) do
									local isWarlockOrShadowPriest = self.isWarlockOrShadowPriest[GUID]
									
									if isWarlockOrShadowPriest then
										countA = countA + 1
									end
								end
								
								-- Count warlocks/shadow priests in group A
								local countB = 0
								
								for _, GUID in pairs(groupB) do
									local isWarlockOrShadowPriest = self.isWarlockOrShadowPriest[GUID]
									
									if isWarlockOrShadowPriest then
										countB = countB + 1
									end
								end
								
								if countA ~= countB then
									return countA > countB
								end
								
								-- Count healers in group A
								local healerCountA = 0
								
								for _, GUID in pairs(groupA) do
									local isHealer = self.isHealer[GUID]
									
									if isHealer then
										healerCountA = healerCountA + 1
									end
								end
								
								-- Count healers in group b
								local healerCountB = 0
								
								for _, GUID in pairs(groupB) do
									local isHealer = self.isHealer[GUID]
									
									if isHealer then
										healerCountB = healerCountB + 1
									end
								end
								
								if healerCountA ~= healerCountB then
									return healerCountA > healerCountB
								end
								
								return groupA[1] < groupB[1]
							end)
												
							for groupIndex, group in pairs(self.affected) do
								local markIndex = self.indexToMark[groupIndex]
								
								local str = ""
									
								for _, GUID in ipairs(group) do
									local info = T.GetGroupInfobyGUID(GUID)
									str = str.." "..info.format_name
								end
								
								T.msg(string.format("%s%s:%s", L["撞球"], T.FormatRaidMark(markIndex), str))
								
								if tContains(group, G.PlayerGUID) then
									local dur = C.DB["BossMod"][self.config_id]["dur_sl"]
									T.Start_Text_Timer(self.text_frame, dur, L["撞球"].." "..T.FormatRaidMark(markIndex))
									T.PlaySound("mark\\mark"..markIndex)
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1242883 then -- 灵魂束缚
								if frame.intermissionCount >= 2 then return end
            
								frame.affectedCount = frame.affectedCount + 1
								
								local groupIndex = math.floor((frame.affectedCount - 1) / 3) + 1
								
								if not frame.affected[groupIndex] then
									frame.affected[groupIndex] = {}
								end
								
								table.insert(frame.affected[groupIndex], destGUID)
								
								if frame.affectedCount == 1 then
									C_Timer.After(1, function()
										frame:assign()
									end)
								end
								
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1245978 then -- 灵魂束缚(BOSS) 转阶段之后才重置
								frame.affected = table.wipe(frame.affected)
								frame.affectedCount = 0
								
							end
						elseif event == "ENCOUNTER_START" then
							frame.intermissionCount = 0
							frame.isWarlockOrShadowPriest = table.wipe(frame.isWarlockOrShadowPriest)
							frame.isHealer = table.wipe(frame.isHealer)
							frame.affected = table.wipe(frame.affected)
							frame.affectedCount = 0
							
							 for unit in T.IterateGroupMembers() do
								local GUID = UnitGUID(unit)
								local role = UnitGroupRolesAssigned(unit)
								local class = UnitClassBase(unit)
								
								if class == "WARLOCK" or (class == "PRIEST" and role == "DAMAGER") then
									frame.isWarlockOrShadowPriest[GUID] = true
								end
								
								if role == "HEALER" then
									frame.isHealer[GUID] = true
								end
							end
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},			
			},
		},
		{ -- 动荡的灵魂
			spells = {
				{1249198, "4"},--【动荡的灵魂】
			},
			options = {
				{ -- 图标 痛苦光环（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HELPFUL",
					unit = "boss",
					spellID = 1227154,
					tip = L["DOT"],
				},
			},
		},
		{ -- 恶魔变形
			spells = {
				{1232569},--【恶魔变形】
			},
			options = {
				{ -- 计时条 恶魔变形（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1232569,
					text = L["阶段转换"],
					sound = "[phase]cast",
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
					spellID = 1232569, -- 恶魔变形
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1233093, -- 坍缩之星
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1232569, -- 恶魔变形
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 3,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1233863, -- 邪能冲撞
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1232569, -- 恶魔变形
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 4,					
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1227117, -- 邪能毁灭
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 4.5,					
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1232569, -- 恶魔变形
					count = 4,
				},
			},
		},
	},
}