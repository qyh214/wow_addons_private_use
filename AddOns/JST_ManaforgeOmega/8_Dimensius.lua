local T, C, L, G = unpack(JST)

local function soundfile(filename, arg)
	return string.format("[1302\\%s]%s", filename, arg or "")
end

--------------------------------Locals--------------------------------
if G.Client == "zhCN" or G.Client == "zhTW" then
	L["易伤前喊话"] = "必须出击，就是现在！"
	L["捡球"] = "捡球"
	L["大小圈"] = "大小圈"
	L["超级新星生效计时条"] = "%s 生效计时条"
	L["补远程"]= "补远程"
	L["补近战"] = "补近战"
	L["活体物质"] = "物质"
	L["救人数量"] = "%s 需要救的数量"
	L["救人"] = "救人"
	L["完成"] = "完成"
	L["躲避"] = "躲避"
	L["P2图形旋转90度"] = "P2图形逆时针旋转90度"
	L["对抗"] = "对抗"
	L["不对抗"] = "不对抗"
elseif G.Client == "ruRU" then
	L["易伤前喊话"] = "Атакуем его! Сейчас!"
	--L["捡球"] = "Pickup"
	--L["大小圈"] = "Big/small circles"
	--L["超级新星生效计时条"] = "%s take effect timing bar"
	--L["补远程"]= "Ranged (backup)"
	--L["补近战"] = "Melee (backup)"
	--L["活体物质"] = "Mess"
	--L["救人数量"] = "%s Number of rescues needed"
	--L["救人"] = "Rescue"
	--L["完成"] = "Done"
	--L["躲避"] = "Hide"
	--L["P2图形旋转90度"] = "Phase 2 assignments rotate 90 degrees counterclockwise."
	--L["对抗"] = "Pull against"
	--L["不对抗"] = "Don't move"
else
	L["易伤前喊话"] = "We must strike--now!"
	L["捡球"] = "Pickup"
	L["大小圈"] = "Big/small circles"
	L["超级新星生效计时条"] = "%s take effect timing bar"
	L["补远程"]= "Ranged (backup)"
	L["补近战"] = "Melee (backup)"
	L["活体物质"] = "Mess"
	L["救人数量"] = "%s Number of rescues needed"
	L["救人"] = "Rescue"
	L["完成"] = "Done"
	L["躲避"] = "Hide"
	L["P2图形旋转90度"] = "Phase 2 assignments rotate 90 degrees counterclockwise."
	L["对抗"] = "Pull against"
	L["不对抗"] = "Don't move"
end
---------------------------------Notes--------------------------------

---------------------------------Data--------------------------------
-- engage_id = 1810, -- 测试用
-- npc_id = {"91784"}, -- 测试用

G.Encounters[2691] = {
	engage_id = 3135,
	npc_id = {"233824", "241517", "234478"},
	alerts = {
		{ -- 湮灭	
			spells = {
				{1229327, "4"},--【湮灭】
			},
			options = {
				
			},
		},
		{ -- 千钧猛击
			spells = {
				{1230087, "0"},--【千钧猛击】
			},
			options = {
				{ -- 文字 千钧猛击 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1230087)..L["倒计时"],
					data = {
						spellID = 1230087,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {23.5, 47.1, 47.1, 47.1},
							},
							[16] = {
								[1] = {21, 42, 42, 42},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1230087, T.GetIconLink(1230087), self, event, ...)
					end,
				},
				{ -- 计时条 千钧猛击（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1230087,
					sound = "[knockoff]cast,cd3",
				},
			},
		},
		{ -- 活体物质
			npcs = {
				{33480, "1"},--【活体物质】 
			},
			spells = {
				{1231005},--【裂变】
				--{1248240, "1,12"},--【无限可能】
			},
			options = {
				{ -- 首领模块 标记 活体物质（✓）
					category = "BossMod",
					spellID = 1230087,
					enable_tag = "rl",
					name = string.format(L["NAME小怪标记"], T.GetFomattedNameFromNpcID("242587"), T.FormatRaidMark("1,2,3,4")),
					points = {hide = true},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_PHASE"] = true,
					},
					init = function(frame)
						frame.start_mark = 1
						frame.end_mark = 4
						frame.mob_npcID = "242587"
						
						T.InitRaidTarget(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateRaidTarget(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetRaidTarget(frame)
					end,
				},
				{ -- 首领模块 BOSS血量 活体物质（✓）
					category = "BossMod",
					spellID = 1248240,
					enable_tag = "rl",
					name = string.format(L["NAME小怪血量和能量"], T.GetFomattedNameFromNpcID("242587")),
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -300},
					events = {
						["ENCOUNTER_SHOW_BOSS_UNIT"] = true,
						["ENCOUNTER_HIDE_BOSS_UNIT"] = true,
						["UNIT_HEALTH"] = true,
						["RAID_TARGET_UPDATE"] = true,
					},
					init = function(frame)
						frame.npcIDs = {
							["242587"] = { -- 活体物质
								n = L["活体物质"],
								color = {.5, .5, .5},
							},
						}
						
						T.InitMobHealth(frame)
						
						function frame:sort()
							for _, bar in pairs(self.sort_bars) do
								local unit = bar.GUID and UnitTokenFromGUID(bar.GUID)
								if unit and T.IsUnitInRange(unit) then	
									bar.group = 1
									bar:SetStatusBarColor(.7, .7, 1)
								else
									bar.group = 2
									bar:SetStatusBarColor(.5, .5, .5)
								end
							end
							
							table.sort(self.sort_bars, function(a, b)
								if a.group < b.group then
									return true
								elseif a.group == b.group and a.GUID and b.GUID and a.GUID < b.GUID then
									return true
								end
							end)
						end
					end,
					update = function(frame, event, ...)
						T.UpdateMobHealth(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetMobHealth(frame)
					end,
				},
				{ -- 首领模块 活体物质血量对比 姓名板标记（✓）
					category = "BossMod",
					ficon = "12",
					spellID = 1248244,
					name = string.format("%s %s (%s)", T.GetFomattedNameFromNpcID("242587"), L["NAME血量对比"], L["姓名板标记"]),
					points = {hide = true},
					events = {
						["UNIT_HEALTH"] = true,
						["ENCOUNTER_ENGAGE_UNIT"] = true,
						["UNIT_SPELLCAST_START"] = true,
					},
					custom = {
						{
							key = "test_btn", 
							text = L["测试姓名板标记"],
							onclick = function(alert)
								T.ShowAllNameplateExtraTex("value")
								C_Timer.After(3, function()
									T.HideAllNameplateExtraTex()
								end)
							end
						},
					},
					init = function(frame)
						frame.mob_npcID = "242587"
						frame.GUIDs = {}
						frame.update_rate = .1
						frame.last_update = 0
						
						function frame:UpdateAverageHealth()
							local MobCount = 0
							local averageHealth = 0
							local averageHealthFraction, totalHealth
							
							for unit in T.IterateBoss() do
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								local isArcaneCollector = npcID == self.mob_npcID
								
								if isArcaneCollector then
									MobCount = MobCount + 1
									averageHealth = averageHealth + UnitHealth(unit)
									totalHealth = UnitHealthMax(unit)
								end
							end
							
							if MobCount == 0 then return true end
							
							averageHealth = averageHealth / MobCount
							averageHealthFraction = averageHealth / totalHealth
							
							for _, GUID in pairs(self.GUIDs) do
								local unit = T.GetBossUnitbyGUID(GUID)
								local jstuf = unit and T.GetNameplateFrame(unit, GUID)
								if jstuf and unit then
									local currentHealth = UnitHealth(unit)
									local differenceFromAverage = currentHealth - averageHealth
									local percentage = (differenceFromAverage / totalHealth) * 100
									
									if percentage and averageHealthFraction then
										local redValue = -10 * averageHealthFraction
										local colorPercentage = Clamp(percentage, redValue, 0)
										local fraction = colorPercentage / redValue
										local hueDifference = 0.33 * fraction
										local h = 0.33 - hueDifference
										local r, g, b = T.hsvToRgb(h, 0.9, 1)
										jstuf.plate_texture:SetVertexColor(r, g, b)
										jstuf.plate_text:SetText(string.format("%d%%", percentage))
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_HEALTH" then
							if GetTime() - frame.last_update > frame.update_rate then
								frame.last_update = GetTime()
								frame:UpdateAverageHealth()
							end
						elseif event == "ENCOUNTER_ENGAGE_UNIT" then
							local unit, GUID = ...
							local npcID = select(6, strsplit("-", GUID))
							if npcID and npcID == frame.mob_npcID then
								table.insert(frame.GUIDs, GUID)
								T.ShowNameplateExtraTex(unit, "value")
							end
						elseif event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if not cast_GUID then return end
							if unit == "boss1" and cast_spellID == 1234898 then -- 黑洞视界
								T.HideAllNameplateExtraTex()
							end
						elseif event == "ENCOUNTER_START" then
							for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
								local unit = namePlate.namePlateUnitToken
								local GUID = UnitGUID(unit)
								local npcID = select(6, strsplit("-", GUID))
								if npcID and npcID == frame.mob_npcID then
									table.insert(frame.GUIDs, GUID)
									T.ShowNameplateExtraTex(unit, "value")
								end
							end
						end
					end,
					reset = function(frame, event)
						T.HideAllNameplateExtraTex()
						frame.GUIDs = table.wipe(frame.GUIDs)
					end,
				},				
				{ -- 首领模块 裂变 玩家自保技能提示（✓）
					category = "BossMod",
					spellID = 1231005,
					name = T.GetIconLink(1231005)..L["玩家自保技能提示"],	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,	
					},
					init = function(frame)
						T.CreatePersonalSpellAlertBase(frame)
						frame.mobs = {}
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1231005 then -- 裂变
								table.insert(frame.mobs, destGUID)
								frame:ActiveCheck()
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == 1231005 then -- 裂变
								tDeleteItem(frame.mobs, destGUID)
								if #frame.mobs == 0 then
									frame:RemoveCheck()
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.mobs = table.wipe(frame.mobs)
							frame.check = false
						end
					end,
					reset = function(frame, event)
						T.ResetPersonalSpellAlertBase(frame)
					end,
				},
			},
		},
		{ -- 过量物质
			spells = {
				{1228206},--【过量物质】
			},
			options = {				
				{ -- 图标 过量物质（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1228206,
					hl = "yel",
				},				
				{ -- 首领模块 过量物质分配（待测试）
					category = "BossMod",
					ficon = "12",
					spellID = 1227866,
					enable_tag = "spell",
					name = T.GetIconLink(1228206)..L["分配"],	
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 190},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["JST_CUSTOM"] = true,
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 180,
							min = 100,
							max = 300,
							apply = function(value, alert)
								alert:SetWidth(value)
								for _, bar in pairs(alert.bars) do
									bar:SetWidth(value)
								end
							end,
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 20,
							min = 16,
							max = 30,
							apply = function(value, alert)
								alert:SetHeight(value*6+36)
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)	
								end
							end,
						},
						{
							key = "mrt_custom_btn",
						},
						{
							key = "mrt_analysis_btn",
						},
					},
					init = function(frame)
						frame.bars = {}
						frame.sort_bars = {}
						frame.backup_assignments = {}
						frame.assignments = {}
						frame.pre_assigned = {}
						frame.count = 0
						frame.last_cast = 0
						frame.my_set = 0
						frame.debuff1 = 1243577
						frame.debuff2 = 1243609
						frame.debuff3 = 1228206
						frame.phase2 = false
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						local strs = {L["近战"], L["补近战"], L["远程"], L["补远程"]}
						frame.str_order = {}
						for i, str in pairs(strs) do
							frame.str_order[str] = i
						end
						
						function frame:lineup()
							self.sort_bars = table.wipe(self.sort_bars)
							
							for _, bar in pairs(self.bars) do
								table.insert(self.sort_bars, bar)
							end
							
							table.sort(self.sort_bars, function(a,b)
								if a.assigned and not b.assigned then
									return true
								elseif a.set and b.set and a.set ~= b.set then
									return  a.set < b.set
								elseif a.str and b.str and a.str ~= b.str then
									local a_order = self.str_order[a.str]
									local b_order = self.str_order[b.str]
									
									if a_order and b_order and a_order ~= b_order then
										return  a_order < b_order
									end
								elseif a.GUID and b.GUID then
									return a.GUID < b.GUID
								end
							end)
							
							local last_set = 1
							local last_bar
							for i, bar in pairs(self.sort_bars) do
								if bar:IsShown() then
									bar:ClearAllPoints()
									if not last_bar then
										bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
									else
										bar:SetPoint("TOPLEFT", last_bar, "BOTTOMLEFT", 0, bar.set ~= last_set and -15 or -2)
									end
									last_bar = bar
									last_set = bar.set
								end
							end
						end
						
						function frame:createbar(GUID)
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							local h = C.DB["BossMod"][self.config_id]["height_sl"]
							local w = C.DB["BossMod"][self.config_id]["width_sl"]
							
							local icon = C_Spell.GetSpellTexture(frame.debuff3)
							local bar = T.CreateTimerBar(self, icon, false, false, false, w, h, {1,1,1})
							
							bar.spell_icon = T.CreateIcon(bar, nil, h)
							bar.spell_icon:SetPoint("LEFT", bar, "RIGHT", 2, 0)
							bar.spell_icon:Hide()
							
							function bar:update_status(tag)
								if tag == "assigned" then
									bar:SetStatusBarColor(0, 1, 1)
								elseif tag == "pickup" then
									bar:SetStatusBarColor(0, 0, 1)
								end
							end
							
							function bar:SetAssignment(assigned, set)
								bar.assigned = assigned
								bar.set = set
							end
							
							function bar:SetText(str)
								bar.right:SetText(str)
								bar.str = str
							end
							
							if GUID then
								bar.GUID = GUID
								bar.left:SetText(info.format_name)
								self.bars[GUID] = bar
							end
							
							return bar
						end
						
						function frame:updatedebuffs(GUID)
							local bar = frame.bars[GUID]
							if not bar then return end
							
							local unit = T.GUIDToUnit(GUID)
							if unit then
								if AuraUtil.FindAuraBySpellID(frame.debuff1, unit, "HARMFUL") then  -- 引力倒逆
									bar.spell_icon.tex:SetTexture(C_Spell.GetSpellTexture(frame.debuff1))
									bar.spell_icon:Show()
								elseif AuraUtil.FindAuraBySpellID(frame.debuff2, unit, "HARMFUL") then -- 浮空
									bar.spell_icon.tex:SetTexture(C_Spell.GetSpellTexture(frame.debuff2))
									bar.spell_icon:Show()
								else
									bar.spell_icon:Hide()
								end
							end
						end
						
						function frame:copy_mrt()
							local str = [[
								#%1$dBackupstart%2$s
								L player player player player player player player player player
								R player player player player player player player player player
								end
								
								#%1$dstart%2$s
								L player player
								R player player
								
								L player player
								R player player
								
								L player player
								R player player
								
								L player player
								R player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(self.config_id))
						end
						
						function frame:GetBackupArray(tag, line, set, display)
							local GUIDs, containsPlayerGUID = T.LineToGUIDArray(line)
							
							if next(GUIDs) then
								local str = string.format("%s %s ", L["替补"], tag)
								
								for _, GUID in pairs(GUIDs) do
									table.insert(self.backup_assignments[set], GUID)
									local name = T.ColorNickNameByGUID(GUID)
									str = str.." "..name
								end
								
								if display then
									T.msg(str)
								end
								
								if containsPlayerGUID then
									self.my_set = set
								end
							end
						end
						
						function frame:GetPriorityArray(tag, line, set, display)
							local GUIDs = T.LineToGUIDArray(line)
									
							if next(GUIDs) then
								local count
								
								if set == 1 then
									self.count_left = self.count_left + 1
									count = self.count_left
								else
									self.count_right = self.count_right + 1
									count = self.count_right
								end
								
								self.assignments[set][count] = {}
								
								local str = string.format("[%d] %s ", count, tag)
								
								for index, GUID in pairs(GUIDs) do
									if index <= 2 then
										self.assignments[set][count][index] = GUID
										local name = T.ColorNickNameByGUID(GUID)
										str = str.." "..name
									end
								end
								
								if display then
									T.msg(str)
								end
							end
						end
						
						function frame:ReadNote(display)
							self.backup_assignments = table.wipe(self.backup_assignments)
							self.backup_assignments[1] = {}
							self.backup_assignments[2] = {}
							
							self.assignments = table.wipe(self.assignments)
							self.assignments[1] = {}
							self.assignments[2] = {}
							
							self.my_set = 0
							
							if display then
								T.msg("--------------")
							end
							
							for _, line in T.IterateNoteAssignment(self.config_id.."Backup") do
								local assignmentType = line:match("^[L%R%-]")
								if assignmentType == "L" then
									self:GetBackupArray(L["左"], line, 1, display)
								elseif assignmentType == "R" then
									self:GetBackupArray(L["右"], line, 2, display)
								end
							end
							
							self.count_left, self.count_right = 0, 0
							
							for _, line in T.IterateNoteAssignment(self.config_id) do
								local assignmentType = line:match("^[L%R%-]")
								if assignmentType == "L" then
									self:GetPriorityArray(L["左"], line, 1, display)
								elseif assignmentType == "R" then
									self:GetPriorityArray(L["右"], line, 2, display)
								end
							end
						end
						
						function frame:GetActiveNum(set)
							local num = 0
							
							local GUIDs = self.backup_assignments[set]
							if not GUIDs then return end
							
							for _, GUID in pairs(GUIDs) do    
								local unit = T.GUIDToUnit(GUID)
								if unit and AuraUtil.FindAuraBySpellID(self.debuff3, unit, "HARMFUL") then -- 过量物质
									num = num + 1
								end
							end
							
							return num
						end
						
						function frame:PlayerCheck(GUID)
							local unit = T.GUIDToUnit(GUID)
							if unit then
								local alive = not UnitIsDeadOrGhost(unit)
								local debuffed1 = AuraUtil.FindAuraBySpellID(self.debuff1, unit, "HARMFUL") -- 引力倒逆
								local debuffed2 = AuraUtil.FindAuraBySpellID(self.debuff2, unit, "HARMFUL") -- 浮空
								local debuffed3 = AuraUtil.FindAuraBySpellID(self.debuff3, unit, "HARMFUL") -- 过量物质
								
								if alive and not debuffed1 and not debuffed2 and not debuffed3 then        
									return true
								end
							end
						end
						
						function frame:GetBackup(set, rev)
							local GUIDs = self.backup_assignments[set]
							if not GUIDs then return end
							
							if rev then
								for i = #GUIDs, 1, -1 do
									local GUID = GUIDs[i]
									if self:PlayerCheck(GUID) and not tContains(self.pre_assigned[set], GUID) then
										return GUID
									end
								end
							else
								for i = 1, #GUIDs, 1 do
									local GUID = GUIDs[i]
									if self:PlayerCheck(GUID) and not tContains(self.pre_assigned[set], GUID) then
										return GUID
									end
								end
							end
						end
						
						function frame:GetAvailable(set)
							local melee_result, ranged_result
							
							local count = self.count
							local GUIDs = self.assignments[set][count]
							
							local melee_GUID = GUIDs and GUIDs[1]
							
							if melee_GUID and self:PlayerCheck(melee_GUID) then
								melee_result = melee_GUID
							else
								melee_result = self:GetBackup(set, false)
							end
							
							local ranged_GUID = GUIDs and GUIDs[2]
							
							if ranged_GUID and self:PlayerCheck(ranged_GUID) then
								ranged_result = ranged_GUID
							else
								ranged_result = self:GetBackup(set, true)
							end
							
							return melee_result, ranged_result
						end
						
						function frame:Display(set, GUID, text, sound, backup)
							if not self.bars[GUID] then
								frame:createbar(GUID)
							end
							
							local bar = self.bars[GUID]
							bar:update_status("assigned")
							bar:SetAssignment(true, set)
							bar:SetText(text)
							self:lineup()
							
							if GUID == G.PlayerGUID then
								if backup then
									self.text_frame.text:SetTextColor(1, .3, 0)
								else
									self.text_frame.text:SetTextColor(1, 1, 1)
								end
								
								self.text_frame.text:SetText(L["捡球"].." "..text)
								self.text_frame:Show()
								
								T.PlaySound(sound)
								T.StartMsgTicker(self, text)
							end
						end
						
						function frame:InitAssignment()
							if frame.phase2 then return end
							for unit in T.IterateGroupMembers() do
								if AuraUtil.FindAuraBySpellID(self.debuff3, unit, "HARMFUL") then
									local GUID = UnitGUID(unit)
									if not self.bars[GUID] then
										frame:createbar(GUID)
									end
									local bar = self.bars[GUID]
									bar:update_status("pickup")
									bar:SetAssignment(false, 3)
									bar:SetText("")
								end
							end
							self:lineup()
						end
						
						function frame:ClearAssignments()
							for GUID, bar in pairs(self.bars) do
								bar:Hide()
							end
							self.bars = table.wipe(self.bars)
							self:lineup()
						end
						
						function frame:Remove()
							self.text_frame:Hide()
							T.StopMsgTicker(self)
						end
												
						function frame:PreAssign()
							self.pre_assigned = table.wipe(self.pre_assigned)
							
							if frame.phase2 then return end
							for set = 1, 2 do
								self.pre_assigned[set] = {}
								
								local set_name = set == 1 and L["左"] or L["右"]
								local melee_result, ranged_result = self:GetAvailable(set)
								
								if melee_result then
									self.pre_assigned[set][1] = melee_result
									self:Display(set, melee_result, L["近战"], "meleegroup")
									local name = T.ColorNickNameByGUID(melee_result)
									T.msg(string.format("%s %s %s", set_name, L["近战"], name))
								end
								
								if ranged_result then
									self.pre_assigned[set][2] = ranged_result
									self:Display(set, ranged_result, L["远程"], "rangegroup")
									local name = T.ColorNickNameByGUID(ranged_result)
									T.msg(string.format("%s %s %s", set_name, L["远程"], name))
								end
							end
						end
						
						function frame:CheckforBackUp(set, rev, GUID, text, sound)
							local name = T.ColorNickNameByGUID(GUID)
							local unit = T.GUIDToUnit(GUID)
							local set_name = set == 1 and L["左"] or L["右"]
							
							if unit and not AuraUtil.FindAuraBySpellID(self.debuff3, unit, "HARMFUL") and not self:PlayerCheck(GUID) then -- 需要替补
								local backup_GUID = self:GetBackup(set, rev)
								if backup_GUID then
									local backup_name = T.ColorNickNameByGUID(backup_GUID)
									self:Display(set, backup_GUID, text, sound, true)
									T.msg(string.format("%s %s %s", set_name, text, backup_name))
								end
							end
						end
						
						function frame:BackupAssign()
							if frame.phase2 then return end
							for set = 1, 2 do
								local need = self.count%2 == 1 and 2 or 4
								local current = self:GetActiveNum(set)
								local lack = need - current
								local PreAssigned = self.pre_assigned[set]
								if lack > 0 and PreAssigned and next(PreAssigned) then    
									local melee_GUID = PreAssigned[1]
									if melee_GUID then
										self:CheckforBackUp(set, false, melee_GUID, L["补近战"], "meleegroup")
									end
									
									local ranged_GUID = PreAssigned[2]
									if ranged_GUID then
										self:CheckforBackUp(set, true, ranged_GUID, L["补远程"], "rangegroup")
									end									
								end
							end
						end
					
						function frame:PreviewShow()
							for set = 1, 3 do
								for index = 1, 2 do
									local bar = frame:createbar()
									bar.left:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
									
									if set ~= 3 then
										bar:update_status("assigned")
										bar:SetAssignment(true, set)
										if index == 1 then
											bar:SetText(L["近战"])
										elseif index == 2 then
											bar:SetText(L["远程"])
										end
									else
										bar:update_status("pickup")
										bar:SetAssignment(false, set)
										bar:SetText("")
									end
									
									table.insert(self.bars, bar)
								end
							end
							
							self:lineup()
						end
						
						function frame:PreviewHide()
							for _, bar in pairs(frame.bars) do
								bar:Hide()
							end
							frame.bars = table.wipe(frame.bars)
						end
					end,
					update = function(frame, event, ...)
						if event == "JST_CUSTOM" then
							local id = ...
							
							if id == frame.config_id then
								frame:InitAssignment()
								frame:PreAssign() -- 第一次分配
							end
							
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()							
							if sub_event == "SPELL_CAST_START" and spellID == 1230087 then -- 千钧猛击
								frame.count = frame.count + 1
								frame:ClearAssignments()
								frame:Remove()
								
								C_Timer.After(12, function()
									T.FireEvent("JST_CUSTOM", frame.config_id)
								end)
								
							elseif sub_event == "SPELL_CAST_START" and spellID == 1234898 then -- 黑洞视界
								frame.phase2 = true
								frame:ClearAssignments()
								frame:Remove()
							
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == frame.debuff1 then -- 引力倒逆 补分配
								if GetTime() - frame.last_cast > 3 then
									frame.last_cast = GetTime()
									
									C_Timer.After(.2, function()
										frame:BackupAssign()
									end)
								end
								
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == frame.debuff3 then -- 过量物质
								if frame.bars[destGUID] then
									local bar = frame.bars[destGUID]
									bar:update_status("pickup")
								else
									frame:createbar(destGUID)
									local bar = frame.bars[destGUID]
									bar:SetAssignment(false, 3)
									bar:SetText("")
									bar:update_status("pickup")
									frame:lineup()
								end
								
								if destGUID == G.PlayerGUID then
									frame:Remove()
								elseif frame.my_set > 0 and tContains(frame.backup_assignments[frame.my_set], destGUID) then
									local need = frame.count%2 == 1 and 2 or 4
									local current = frame:GetActiveNum(frame.my_set)
									local lack = need - current
									if lack == 0 then
										frame:Remove()
									end
								end
							elseif sub_event == "SPELL_AURA_REMOVED" and spellID == frame.debuff3 then -- 过量物质
								if frame.bars[destGUID] then
									local bar = frame.bars[destGUID]
									if bar.assigned then
										bar:update_status("assigned")
									else
										bar:Hide()
									end
								end
							end
							
							if (sub_event == "SPELL_AURA_APPLIED" or sub_event == "SPELL_AURA_REMOVED") and (spellID == frame.debuff1 or spellID == frame.debuff2) then -- 引力倒逆/浮空
								frame:updatedebuffs(destGUID)
							end
							
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame.last_cast = 0
							frame.my_set = 0
							frame.phase2 = false
							frame.bars = table.wipe(frame.bars)
							
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						frame:ClearAssignments()
						frame:Remove()
						frame:Hide()
					end,
				},
				{ -- 首领模块 浮空救人数量（✓）
					category = "BossMod",
					spellID = 1228206,
					name = string.format(L["救人数量"], T.GetIconLink(1243609)),	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.count = 0
						frame.sound_enable = false
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:UpdateCount()
							if AuraUtil.FindAuraBySpellID(1228206, "player", "HARMFUL") then
								if self.count == 3 then
									self.sound_enable = true
								end
								
								if self.count > 0 then
									self.text_frame.text:SetText(string.format("%s |cffffff00%d|r", L["救人"], self.count))
									self.text_frame:Show()
									if self.sound_enable then
										T.PlaySound("count\\"..self.count)
									end
								else
									T.Start_Text_Timer(self.text_frame, 1, string.format("%s |cff00ff00%s|r", L["救人"], L["完成"]))
									T.PlaySound("1302\\done")
									self.sound_enable = false
								end
							elseif self.text_frame:IsShown() then
								self.sound_enable = false
								self.text_frame:Hide()
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_REMOVED" and spellID == 1243609 then -- 浮空
								local unit = T.GUIDToUnit(destGUID)
								local inRange = T.UnitInRange(unit)
								
								if inRange then
									frame.count = frame.count - 1
									frame:UpdateCount()
								end
							elseif sub_event == "SPELL_AURA_APPLIED" and spellID == 1243609 then -- 浮空
								local unit = T.GUIDToUnit(destGUID)
								local inRange = T.UnitInRange(unit)
								
								if inRange then
									frame.count = frame.count + 1
									
									if frame.count == 1 then
										C_Timer.After(0.2, function()
											frame:UpdateCount()
										end)
									end
								end
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 1230979 then -- 暗物质
								T.Stop_Text_Timer(frame.text_frame)
								frame.sound_enable = false
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame.sound_enable = false
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
			},
		},
		{ -- 凡躯的脆弱
			spells = {
				{1230168},--【凡躯的脆弱】受到的物理伤害提高100%。该效果可叠加。
			},
			options = {
				{ -- 换坦计时条 凡躯的脆弱（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1230168,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
			},
		},
		{ -- 吞噬
			spells = {
				{1229038, "4,5"},--【吞噬】
				--{1229674},--【吞食饥饿】
			},
			options = {
				{ -- 文字 吞噬 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1229038)..L["倒计时"],
					data = {
						spellID = 1229038,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {11.8, 94.1},
							},
							[16] = {
								[1] = {10.5, 84.2},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1229038, T.GetIconLink(1229038), self, event, ...)
					end,
				},
				{ -- 计时条 吞噬（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1229038,
					sound = "channel,cd3"
				},
				{ -- 首领模块 吞噬生效倒计时（✓）
					category = "BossMod",
					spellID = 1229038,
					name = T.GetIconLink(1229038)..L["生效倒计时"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_AURA_ADD"] = true,
						["UNIT_AURA_REMOVED"] = true,
						["UNIT_AURA_UPDATE"] = true,
					},
					init = function(frame)
						frame.boss_buff = 0
						frame.player_debuff1 = 0
						frame.player_debuff2 = false
						frame.channeling = false

						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						
						function frame:UpdateText()
							if not frame.channeling then
								self.text_frame.text:SetTextColor(1, 1, 1)
								self.text_frame.cur_text = string.format("%s%s", T.GetSpellIcon(1229038), L["准备"])
							else
								local phase = T.GetCurrentPhase()
								if phase == 1 then
									if self.player_debuff1 >= self.boss_buff then
										self.text_frame.text:SetTextColor(0, 1, 0)
										self.text_frame.cur_text = string.format("%s%s", T.GetSpellIcon(1229038), L["安全"])
									else
										self.text_frame.text:SetTextColor(1, 0, 0)
										self.text_frame.cur_text = string.format("%s%s", T.GetSpellIcon(1229038), L["躲避"])
									end
								else
									if self.player_debuff2 then
										self.text_frame.text:SetTextColor(0, 1, 0)
										self.text_frame.cur_text = string.format("%s%s", T.GetSpellIcon(1229038), L["安全"])
									else
										self.text_frame.text:SetTextColor(1, 0, 0)
										self.text_frame.cur_text = string.format("%s%s", T.GetSpellIcon(1229038), L["躲避"])
									end
								end
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and (spellID == 1229038 or spellID == 1233539) then -- 吞噬读条
								frame.channeling = false
								frame:UpdateText()
								T.Start_Text_Timer(frame.text_frame, 2, "", true)
								
							elseif sub_event == "SPELL_CAST_SUCCESS" and (spellID == 1229038 or spellID == 1233539) then -- 吞噬引导
								frame.channeling = true
								frame:UpdateText()
								T.Start_Text_Timer(frame.text_frame, 5, "", true)
								
							end
						elseif event == "UNIT_AURA_ADD" or event == "UNIT_AURA_REMOVED" or event == "UNIT_AURA_UPDATE" then
							local unit, spellID = ...
							if unit == "player" and spellID == 1228207 then -- 集体引力
								if AuraUtil.FindAuraBySpellID(1228207, "player", "HARMFUL") then
									frame.player_debuff1 = select(3,  AuraUtil.FindAuraBySpellID(1228207, "player", "HARMFUL"))
								else
									frame.player_debuff1 = 0
								end
								frame:UpdateText()
								
							elseif string.find(unit, "boss") and spellID == 1229674 then -- 吞食饥饿
								if AuraUtil.FindAuraBySpellID(1229674, unit, "HELPFUL") then
									frame.boss_buff = select(3,  AuraUtil.FindAuraBySpellID(1229674, unit, "HELPFUL"))
								else
									frame.boss_buff = 0
								end
								frame:UpdateText()
								
							elseif unit == "player" and spellID == 1232394 then -- 重力井
								if AuraUtil.FindAuraBySpellID(1232394, "player", "HARMFUL") then
									frame.player_debuff2 = true
								else
									frame.player_debuff2 = false
								end
								frame:UpdateText()
								
							end
						elseif event == "ENCOUNTER_START" then
							frame.boss_buff = 0
							frame.player_debuff1 = 0
							frame.player_debuff2 = false
							frame.channeling = false
							
							T.RegisterWatchAuraSpellID(1228207) -- 集体引力
							T.RegisterWatchAuraSpellID(1229674) --  吞食饥饿
							T.RegisterWatchAuraSpellID(1232394) --  重力井
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
						
						T.UnregisterWatchAuraSpellID(1228207) -- 集体引力
						T.UnregisterWatchAuraSpellID(1229674) --  吞食饥饿
						T.UnregisterWatchAuraSpellID(1232394) --  重力井
					end,
				},
			},
		},
		{ -- 暗物质
			spells = {
				{1230999, "2"},--【暗物质】
				--{1231002},--【黑暗能量】
			},
			options = {
				{ -- 文字 暗物质 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["分散"]..L["倒计时"],
					data = {
						spellID = 1230979,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {35.3, 43.6, 50.5},
							},
							[16] = {
								[1] = {31.6, 38.9, 45.3, 38.9},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1230979, L["分散"], self, event, ...)
					end,
				},
				{ -- 计时条 暗物质（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1230979,
					sound = "[spread]cast",
					text = L["分散"],
				},
				{ -- 首领模块 暗物质 计时圆圈（✓）
					category = "BossMod",
					spellID = 1230979,
					name = T.GetIconLink(1230979)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.count = 0
						frame.figure = T.CreateRingCD(frame, {1, .5, .1}, true)
						
						function frame:Start()
							local difficultyID = T.GetCurrentDifficultyID()
							local key = string.format("dur%d_%d_sl", difficultyID, frame.count)
							local dur = C.DB["BossMod"][self.config_id][key] or 3
							self.figure:begin(GetTime() + dur, dur)
						end
						
						function frame:UpdateDuration(dur)
							local difficultyID = T.GetCurrentDifficultyID()
							local key = string.format("dur%d_%d_sl", difficultyID, frame.count)
							C.DB["BossMod"][self.config_id][key] = dur
						end
						
						function frame:GetNumDeadPlayers()
							local number = 0
							for unit in T.IterateGroupMembers() do
								if UnitIsDeadOrGhost(unit) then
									number = number + 1
								end
							end
							return number
						end
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 3, 3)
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
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1230979 then -- 暗物质
								frame.count = frame.count + 1
								frame.castStart = GetTime()
								
								frame:Start()
								
							elseif sub_event == "SPELL_DAMAGE" and destGUID == G.PlayerGUID and spellID == 1230999 then -- 暗物质
								
								local timeSinceCastStart = GetTime() - frame.castStart
								
								if timeSinceCastStart < 2 then return end
								
								frame.figure:stop()
								T.PlaySound("sound_water")
								
								if frame:GetNumDeadPlayers() >= 4 then return true end
								
								frame:UpdateDuration(timeSinceCastStart)
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
						end
					end,
					reset = function(frame, event)
						frame.figure:stop()
					end,
				},
				{ -- 图标 黑暗能量（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1231002,
					tip = L["DOT"].."+"..L["减速"],
				},
			},
		},
		{ -- 破碎空间
			spells = {
				{1243690, "2"},--【破碎空间】
				--{1243704, "4,5"},--【反物质】
				--{1243699},--【空间碎片】
			},
			options = {
				{ -- 文字 破碎空间 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["大球"]..L["倒计时"],
					data = {
						spellID = 1243690,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[1] = {44.5, 47, 47, 47},
							},
							[16] = {
								[1] = {39.9, 42.1, 42.1, 42.1},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1243690, L["大球"], self, event, ...)
					end,
				},
				{ -- 首领模块 计时条 破碎空间（✓）
					category = "BossMod",
					spellID = 1243690,
					name = string.format(L["计时条%s"], T.GetIconLink(1243690)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,	
					},
					init = function(frame)
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, C_Spell.GetSpellTexture(1243690), L["大球"], T.GetSpellColor(1243690))
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_spellID == 1243690 then -- 破碎空间
								T.StartTimerBar(frame.bar, 4, true, true)
								T.StartCountDown(nil, GetTime() + 4, 4, "prepare_incircle")
							end
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
				{ -- 首领模块 反物质 计时条（✓）
					category = "BossMod",
					spellID = 1243702,
					name = string.format(L["计时条%s"], T.GetIconLink(1243702)),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 300},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					init = function(frame)
						frame.default_bar_width = 300
						T.GetSingleBarCustomData(frame)
						
						frame.time_limit = 10
						frame.spell_id = 1243702
						
						frame.spellName = C_Spell.GetSpellName(frame.spell_id)
						frame.spellIcon = C_Spell.GetSpellTexture(frame.spell_id)
						frame.bar = T.CreateTimerBar(frame, frame.spellIcon, false, false, true, nil, nil, {1, .8, 0})
						
						T.CreateTagsforBar(frame.bar, 1)
						
						frame.bar.tag_indcators[1]:SetVertexColor(1, 0, 0)
						frame.bar.tag_indcators[1]:SetWidth(4)
						frame.bar:SetAllPoints(frame)
						
						frame.absorb = 0
						frame.absorb_max = 80
						frame.bar:SetMinMaxValues(0, frame.absorb_max)
						
						function frame:update_absorb()
							if self.absorb == 0 then
								self:stop_bar()
							end
							self.bar:SetValue(self.absorb)
							self.bar.right:SetText(self.absorb)							
						end
						
						function frame:update_time()
							if self.time_limit then
								local exp_time = GetTime() + self.time_limit
								
								self.bar.left:SetText("")
								self.bar.tag_indcators[1]:Show()
								
								self.bar:SetScript('OnUpdate', function(s, e)
									s.t = s.t + e
									if s.t > 0.05 then
										local remain = exp_time - GetTime()
										if remain > 0 then
											s.left:SetText(T.FormatTime(remain))
											s:pointtag(1, remain/self.time_limit)
										else
											self:stop_bar()
										end
										s.t = 0
									end
								end)
							end
							self.bar:Show()
						end
						
						function frame:stop_bar()
							self.bar:Hide()
							self.bar.tag_indcators[1]:Hide()
							self.bar:SetScript("OnUpdate", nil)
						end

						function frame:PreviewShow()
							self.absorb = math.random(1, 80)	
							self:update_absorb()
							self:update_time()
						end
						
						function frame:PreviewHide()
							self:stop_bar()
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, cast_GUID, cast_spellID = ...
							if unit == "boss1" and cast_spellID == 1243690 then -- 破碎空间
								frame.absorb = 80
								frame:update_absorb()
								frame:update_time()
							end
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if (sub_event == "SPELL_DAMAGE" or sub_event == "SPELL_MISSED") and spellID == 1243702 then -- 反物质
								local unit = T.GUIDToUnit(destGUID)
								local inRange = T.UnitInRange(unit)
								
								if inRange then
									frame.absorb = frame.absorb - 1
									frame:update_absorb()
								end
							end
						end
					end,
					reset = function(frame, event)
						frame:stop_bar()
					end,
				},
			},
		},
		{ -- 引力倒逆
			spells = {
				{1243577, "5"},--【引力倒逆】
				{1243609},--【浮空】
				--{1250614, "12"},--【畸变之力】
			},
			options = {
				{ -- 文字 引力倒逆 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1243577)..L["倒计时"],
					data = {
						spellID = 1243577,
						events =  {
							["UNIT_AURA_ADD"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true							
							self.last_cast = 0
							self.next_count = 1
							self.difficultyID = select(3, ...)
							
							if self.difficultyID == 15 then
								T.Start_Text_DelayTimer(self, 52.9, T.GetIconLink(1243577), true)
							elseif self.difficultyID == 16 then
								T.Start_Text_DelayTimer(self, 43, T.GetIconLink(1243577), true)
							end
						
						elseif event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == 1243577 and GetTime() - self.last_cast > 1 then
								self.last_cast = GetTime()
								self.next_count = self.next_count + 1
								
								if self.next_count > 4 then return end
								
								if self.difficultyID == 15 then
									local cd = self.next_count % 2 == 1 and 51.7 or 42.3
									T.Start_Text_DelayTimer(self, cd, T.GetIconLink(1243577), true)
								elseif self.difficultyID == 16 then
									cd = 42.1
									T.Start_Text_DelayTimer(self, 42.1, T.GetIconLink(1243577), true)
								end
							end
							
						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 1.5 then
								T.Stop_Text_Timer(self)
							end
						end
					end,
				},
				{ -- 首领模块 引力倒逆 计时圆圈（✓）
					category = "BossMod",
					spellID = 1243577,
					name = T.GetIconLink(1243577)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1243577] = { -- 引力倒逆
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
				{ -- 首领模块 引力倒逆分配（✓）
					category = "BossMod",
					enable_tag = "spell",
					ficon = "12",
					spellID = 1243581,
					name = T.GetIconLink(1243577)..L["分配"],
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.affected = {}
						frame.info = {
							{ str = L["前"], sound = "front"},
							{ str = L["后"], sound = "back"},
							{ str = L["标记"], sound = "worldmark"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:Assign()
							 table.sort(self.affected, function (GUID1, GUID2)
								if not GUID1 then return false end
								if not GUID2 then return true end
								
								local info1 = T.GetGroupInfobyGUID(GUID1)
								local info2 = T.GetGroupInfobyGUID(GUID2)
								
								local class1, role1 = info1.class, info1.role
								local class2, role2 = info2.class, info2.role
								
								local mobility1 = G.classMobility[class1]
								local mobility2 = G.classMobility[class2]
								
								if role1 ~= role2 then
									return role1 > role2 -- T H D
								elseif mobility1 ~= mobility2 then
									return mobility1 < mobility2
								else
									return GUID1 < GUID2
								end
							end)
							
							for index, GUID in pairs(self.affected) do
								local data = self.info[index]
								local name = T.ColorNickNameByGUID(GUID)
								if data and name then
									T.msg(string.format("%s %s %s", T.GetIconLink(1243577), data.str, name))
								end
							end
							
							local myAssignmentIndex = tIndexOf(self.affected, G.PlayerGUID)
							
							if myAssignmentIndex and self.info[myAssignmentIndex] then
								local data = self.info[myAssignmentIndex]
								T.Start_Text_Timer(self.text_frame, 4.8, data.str, true)
								T.StartMsgTicker(self, data.str, 5)
								T.PlaySound(data.sound)
							end
							
							self.affected = table.wipe(self.affected)
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1243577 then -- 引力倒逆
								local unit = T.GUIDToUnit(destGUID)
								local inRange = T.UnitInRange(unit)
								
								if not inRange then return end
								
								table.insert(frame.affected, destGUID)
								
								if #frame.affected == 1 then
									C_Timer.After(0.2, function()
										frame:Assign()
									end)
								end
							end
						elseif event == "ENCOUNTER_START" then
							frame.affected = table.wipe(frame.affected)
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
						T.StopMsgTicker(frame)
					end,
				},
				{ -- 图标 浮空（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1243609,
					hl = "yel",
				},
				{ -- 首领模块 浮空 多人光环（✓）
					category = "BossMod",
					spellID = 1243609,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1243577)..T.GetIconLink(1243609)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -400},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)						
						frame.spellIDs = {
							[1243577] = {},-- 引力倒逆
							[1243609] = {},-- 浮空
						}
						
						T.InitUnitAuraBars(frame)			
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
			},
		},
		{ -- 虚空领主之拳
			spells = {
				{1227665, "0"},--【虚空领主之拳】
			},
			options = {
				
			},
		},
		{ -- 宇宙辐射
			spells = {
				{1228367},--【宇宙辐射】
			},
			options = {
				
			},
		},
		{ -- 翔空雷什
			spells = {
				{1235114},--【翔空雷什】
				--{1235467, "5"},--【晦暗之门】
				--{1241188, "4"},--【无尽黑暗】
				--{1237080, "4"},--【破碎世界】
				--{1235490, "4"},--【天体物理射流】
				--{1232987, "4"},--【黑洞】
			},
			options = {
				{ -- 首领模块 翔空雷什 倒计时（✓）
					category = "BossMod",
					spellID = 1235114,
					name = L["起飞"]..L["倒计时"],	
					points = {hide = true},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_SPELLCAST_START"] = true
					},
					init = function(frame)						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 1)
						frame.text_frame.round = true	
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if not string.find(unit, "boss") then return end
							if cast_spellID == 1238765 then -- 灭绝
								frame.lastIntermissionCast = "extinction"
								frame.lastIntermissionCastTime = GetTime()
							elseif cast_spellID == 1237319 then -- 伽马爆发
								frame.lastIntermissionCast = "gamma"
								frame.lastIntermissionCastTime = GetTime()
							end
							
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_AURA_APPLIED" and spellID == 1234243 then -- 倾压引力
								frame.lastIntermissionCast = "gravity"
								frame.lastIntermissionCastTime = GetTime()
								
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 1234898 then -- 黑洞视界
								T.Start_Text_Timer(frame.text_frame, 9.8, L["起飞"], true)
								
							elseif sub_event == "UNIT_DIED" then
								local npcID = select(6, strsplit("-", destGUID))
								if npcID == "245255" then -- 阿托席恩
									local cd = 5.5
									if frame.lastIntermissionCast == "gamma" then
										-- gamma applied + 11
										cd = math.max(cd, 11 + (4 - (GetTime() - frame.lastIntermissionCastTime)))
									elseif frame.lastIntermissionCast == "extinction" then
										-- extinction success + 9.8
										cd = math.max(cd, 9.8 + (5 - (GetTime() - frame.lastIntermissionCastTime)))
									elseif frame.lastIntermissionCast == "gravity" then
										-- gravity removed + 8
										cd = math.max(cd, 8 + (5 - (GetTime() - frame.lastIntermissionCastTime)))
									end
									T.Start_Text_Timer(frame.text_frame, cd, L["起飞"], true)
								end
							end
							
						elseif event == "ENCOUNTER_START" then						
							frame.lastIntermissionCast = nil
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 图标 翔空雷什（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1235114,
				},
			},
		},
		{ -- 星辰之核
			spells = {
				{1246930},--【星辰之核】
				--{1246948},--【迸射流星】
			},
			options = {
				{ -- 图标 星辰之核（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1246930,
					hl = "yel",
				},
				{ -- 首领模块 星辰之核 多人光环（✓）
					category = "BossMod",
					spellID = 1246930,
					enable_tag = "rl",
					name = string.format(L["NAME多人光环提示"], T.GetIconLink(1246930)),	
					points = {a1 = "TOPLEFT", a2 = "TOPLEFT", x = 30, y = -500},
					events = {
						["UNIT_AURA"] = true,	
					},
					init = function(frame)						
						frame.spellIDs = {
							[1246930] = {},-- 星辰之核
						}
						
						T.InitUnitAuraBars(frame)			
					end,
					update = function(frame, event, ...)
						T.UpdateUnitAuraBars(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetUnitAuraBars(frame)
					end,
				},
			},
		},
		{ -- 灭绝
			spells = {
				{1238765, "4"},--【灭绝】
			},
			options = {
				{ -- 文字 灭绝 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["躲地板"]..L["倒计时"],
					data = {
						spellID = 1238765,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[2] = {11.8, 35.3, 35.3},
								[3] = {11.8, 35.3, 35.3},
							},
							[16] = {
								[2] = {10.5, 31.6},
								[3] = {10.5, 31.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1238765, L["躲地板"], self, event, ...)
					end,
				},
				{ -- 计时条 灭绝（✓）
					category = "AlertTimerbar",
					type = "cleu",
					event = "SPELL_CAST_START",
					spellID = 1238765,
					icon_tex = 132153,
					dur = 8.5,
					text = L["躲地板"],
					glow = true,
					group = 1,
				},
				{ -- 图标 灭绝（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1238773,
					tip = L["昏迷"],
				},
			},
		},
		{ -- 伽马爆发
			spells = {
				{1237319, "2,5"},--【伽马爆发】
			},
			options = {
				{ -- 文字 伽马爆发 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["推人"]..L["倒计时"],
					data = {
						spellID = 1237319,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_SUCCEEDED"] = true,
						},					
						info = {
							[15] = {
								[2] = {25.9, 35.4},
								[3] = {25.9, 35.4},
							},
							[16] = {
								[2] = {21.1, 31.6},
								[3] = {21.1, 31.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_SUCCEEDED", "boss", 1237319, L["推人"], self, event, ...)
					end,
				},
				{ -- 计时条 伽马爆发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1237319,
					text = L["推人"],
					sound = "[push]cast,cd3",
					glow = true,
					group = 1,
				},
				{ -- 首领模块 伽马爆发 计时圆圈（✓）
					category = "BossMod",
					spellID = 1237319,
					name = T.GetIconLink(1237319)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					init = function(frame)
						frame.figure = T.CreateRingCD(frame, {1, 0, 0}, true)
						
						function frame:PreviewShow()
							self.figure:begin(GetTime() + 4, 4)
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
							if string.find(unit, "boss") and cast_GUID and cast_spellID == 1237319 then -- 伽马爆发
								frame.figure:begin(GetTime() + 4, 4)
							end
						end
					end,
					reset = function(frame, event)
						frame.figure:stop()
					end,
				},
			},
		},
		{ -- 倾压引力/引力倒转
			spells = {				
				{1234243},--【倾压引力】
				{1234244},--【引力倒转】
			},
			options = {
				{ -- 文字 引力倒转 倒计时（?）
					category = "TextAlert",
					ficon = "12",
					type = "spell",
					preview = string.format("%s%s %s %s", T.GetIconLink(1234243), T.GetIconLink(1234244), L["大小圈"], L["倒计时"]),
					data = {
						spellID = 1234244,
						events =  {
							["UNIT_AURA_ADD"] = true,
							["ENCOUNTER_PHASE"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
							self.count_down_start = 3
							self.mute_count_down = true
							self.prepare_sound = "1302\\preparecircles"
							self.last_cast = 0

						elseif event == "ENCOUNTER_PHASE" then
							local phase = ...
							if phase == 2 or phase == 3 then
								self.next_count = 1
								T.Start_Text_DelayTimer(self, 12.6, L["大小圈"], true)
							elseif phase == 4 then
								self.next_count = 1
								T.Start_Text_DelayTimer(self, 59.4, L["大小圈"], true)
							end
							
						elseif event == "UNIT_AURA_ADD" then
							local unit, spellID = ...
							if spellID == 1234244 and GetTime() - self.last_cast > 1 then
								self.last_cast = GetTime()
								self.next_count = self.next_count + 1
								
								local cd = 0
								local phase = T.GetCurrentPhase()
								if phase == 4 and self.next_count < 6 then
									cd = self.next_count % 2 == 0 and 26.0 or 32.0 
								elseif self.next_count < 3 then
									cd = 31.5
								end
								
								T.Start_Text_DelayTimer(self, cd, L["大小圈"], true)
							end
						end
					end,
				},
				{ -- 首领模块 倾压引力 计时圆圈（✓）
					category = "BossMod",
					ficon = "12",
					spellID = 1234243,
					name = T.GetIconLink(1234243)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1234243] = { -- 倾压引力
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, .29, .98},
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
				{ -- 首领模块 引力倒转 计时圆圈（✓）
					category = "BossMod",
					ficon = "12",
					spellID = 1234244,
					name = T.GetIconLink(1234244)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1234244] = { -- 引力倒转
								unit = "player",
								aura_type = "HARMFUL",
								color = {0, 1, 0},
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
				{ -- 首领模块 大小圈分配（待测试）
					category = "BossMod",
					enable_tag = "spell",
					ficon = "12",
					spellID = 1234249,
					name = string.format("%s%s %s %s", T.GetIconLink(1234243), T.GetIconLink(1234244), L["大小圈"], L["分配"]),
					points = {a1 = "BOTTOMLEFT", a2 = "CENTER", x = 210, y = 250, width = 240, height = 160},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					custom = {
						{
							key = "preview_phase_dd",
							text = L["预览阶段"],
							default = 2,
							key_table = {
								{2, "P2"},
								{3, "P3"},
							},
							apply = function(value, alert)
								alert:UpdatePreviewInfo()
							end,
						},
						{
							key = "preview_index_dd",
							text = L["预览轮次"],
							default = 1,
							key_table = {
								{1, "1"},
								{2, "2"},
								{3, "3"},
								{4, "4"},
								{5, "5"},
							},
							apply = function(value, alert)
								alert:UpdatePreviewInfo()
							end,
						},
						{
							key = "mrt_custom_btn",
						},
						{
							key = "mrt_analysis_btn",
						},
						{
							key = "scale_sl",
							text = L["尺寸"],
							default = 100,
							min = 60,
							max = 140,
							apply = function(value, alert)
								alert:SetScale(value/100)
							end,
						},
						{
							key = "rotate_bool",
							text = L["P2图形旋转90度"],
							default = false,
							apply = function(value, alert)
								alert:UpdatePreviewInfo()
							end,
						},
					},
					init = function(frame)
						frame.affected = {}
						frame.phase = 1
						frame.set = 1
						
						frame.info = {
							{tag = "M", str = L["近战"], sound1 = "1302\\bigcirclemelee", sound2 = "1302\\soakmelee"},
							{tag = "H", str = L["治疗"], sound1 = "1302\\bigcirclehealer", sound2 = "1302\\soakhealer"},
							{tag = "R", str = L["远程"], sound1 = "1302\\bigcircleranged", sound2 = "1302\\soakranged"},
						}
						
						local INVERSE_SIZE = 50
						local INVERSE_POSITIONS = { -- M H R
							[2] = {
								{ -- 1
									M = {0 , 1.1},
									H = {0 , 0},
									R = {0 , -1.1},
									bg = {-.6, 1.6, .6, -1.6},
								},
								{ -- 2
									M = {0.55, 0.55},
									H = {-0.55, 0.55},
									R = {0.55, -0.55},
									bg = {-1.2, 1.2, 1.2, -1.2},
								},    
								{ -- 3
									M = {0.45, 0.6},
									H = {-0.45, 0},
									R = {0.45, -0.6},
									bg = {-1.1, 1.5, 1.1, -1.5},
								},
								{ -- 4
									M = {0 , 1.1},
									H = {0 , 0},
									R = {0 , -1.1},
									bg = {-.6, 1.6, .6, -1.6},
								},
							},
							[3] = {
								{ -- 1
									M = {-1.1 , 0.3},
									H = {0, -0.3},
									R = {1.1 , 0.3},
									bg = {-1.7, 1, 1.7, -1},
								},
								{ -- 2
									M = {1.2 , 0.6},
									H = {1.2, -0.6},
									R = {0, -0.6},
									arrow = {-1.3, 0, 270},
									bg = {-2, 1.2, 2, -1.2},
								},
								{ -- 3
									M = {1.2 , 0.6},
									H = {1.2, -0.6},
									R = {0 , -0.6},
									arrow = {-1.3, 0, 270},
									bg = {-2, 1.2, 2, -1.2},
								},
								{ -- 4
									M = {1.8 , 0.4},
									H = {0, -0.4},
									R = {-1.8, 0.4},
									arrow = {.3, .9, 150},
									circle1 = {-.9, .1},
									circle2 = {.9, .1},
									bg = {-2.4, 1.5, 2.4, -1.1},
								},
								{ -- 5
									M = {1.8 , 0.4},
									H = {0, -0.4},
									R = {-1.8 , 0.4},
									arrow = {.3, .9, 150},
									circle1 = {-.9, .1},
									circle2 = {.9, .1},
									bg = {-2.4, 1.5, 2.4, -1.1},
								},
							},
						}
						
						local INVERSE_POSITIONS_ROTATE = {
							[2] = {
								{ -- 1
									M = {-1.1 , 0},
									H = {0 , 0},
									R = {1.1 , 0},
									bg = {-1.6, .6, 1.6, -.6},
								},
								{ -- 2
									M = {-0.55, 0.55},
									H = {-0.55, -0.55},
									R = {0.55, 0.55},
									bg = {-1.2, 1.2, 1.2, -1.2},
								},    
								{ -- 3
									M = {-0.6, 0.45},
									H = {0, -0.45},
									R = {0.6, 0.45},
									bg = {-1.5, 1.1, 1.5, -1.1},
								},
								{ -- 4
									M = {-1.1, 0},
									H = {0, 0},
									R = {1.1, 0},
									bg = {-1.6, 0.6, 1.6, -0.6},
								},
							},
							[3] = {
								{ -- 1
									M = {1.1 , 0.3},
									H = {0, -0.3},
									R = {-1.1 , 0.3},
									bg = {-1.7, 1, 1.7, -1},
								},
								{ -- 2
									M = {1.2 , 0.6},
									H = {0, -0.6},
									R = {0 , 0.6},
									arrow = {-1.3, 0, 270},
									bg = {-2, 1.2, 2, -1.2},
								},
								{ -- 3
									M = {1.2 , 0.6},
									H = {0, -0.6},
									R = {0 , 0.6},
									arrow = {-1.3, 0, 270},
									bg = {-2, 1.2, 2, -1.2},
								},
								{ -- 4
									M = {1.8 , 0.4},
									H = {0, -0.4},
									R = {-1.8, 0.4},
									arrow = {.3, .9, 150},
									circle1 = {-.9, .1},
									circle2 = {.9, .1},
									bg = {-2.4, 1.5, 2.4, -1.1},
								},
								{ -- 5
									M = {1.8 , 0.4},
									H = {0, -0.4},
									R = {-1.8 , 0.4},
									arrow = {.3, .9, 150},
									circle1 = {-.9, .1},
									circle2 = {.9, .1},
									bg = {-2.4, 1.5, 2.4, -1.1},
								},
							},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						frame.graph_bg = CreateFrame("Frame", nil, frame)
						frame.graph_bg:SetAllPoints(frame)
						frame.graph_bg:Hide()
						
						frame.graphs = {}
						for i, data in pairs(frame.info) do
							local f = CreateFrame("Frame", nil, frame.graph_bg)
							f:SetSize(INVERSE_SIZE, INVERSE_SIZE)
							
							f.tex = f:CreateTexture(nil, "ARTWORK")
							f.tex:SetAllPoints(f)
							f.tex:SetTexture(G.media.circle)
							f.tex:SetVertexColor(1, 1, 1)
							
							f.tagtext = T.createtext(f, "OVERLAY", 20, "OUTLINE", "CENTER")
							f.tagtext:SetPoint("CENTER", f, "CENTER")
							f.tagtext:SetText(data.str)
							
							frame.graphs[data.tag] = f
						end
						
						frame.graph_bg_info = {
							arrow = {layer = "ARTWORK",tex = G.media.arrow, w = 70, h = 70, color = {1, 1, 1}},
							circle1 = {layer = "ARTWORK",tex = G.media.circle, w = 30, h = 30, color = {.2, .2, .6}},
							circle2 = {layer = "ARTWORK",tex = G.media.circle, w = 30, h = 30, color = {.2, .2, .6}},
							bg = {layer = "BACKGROUND", tex = G.media.blank, w = 30, h = 30, color = {.05, .05, .05, .6}},
						}
						
						for k, info in pairs(frame.graph_bg_info) do
							local tex = frame.graph_bg:CreateTexture(nil, info.layer)
							tex:SetSize(info.w, info.h)
							tex:SetVertexColor(unpack(info.color))
							tex:SetTexture(info.tex)
							frame.graphs[k] = tex
						end
						
						frame.tip_text = T.createtext(frame.graph_bg, "OVERLAY", 26, "OUTLINE", "CENTER")
						frame.tip_text:SetPoint("TOP", frame.graphs.bg, "BOTTOM", 0, 0)
						
						function frame:ReadPhaseNote(tag, display)
							local indexNumber = 0
							
							for _, line in T.IterateNoteAssignment(self.config_id..tag) do
								local GUIDs, containsPlayerGUID = T.LineToGUIDArray(line)
								
								if next(GUIDs) then
									indexNumber = indexNumber + 1 
									
									if display then
										local str = T.GetColoredNameListByArray(GUIDs, string.format("%s[%d]", tag, indexNumber))
										T.msg(str)
									end
									
									if containsPlayerGUID then
										return indexNumber
									end
								end
							end
						end
						
						function frame:ReadNote(display)
							if display then
								T.divideline(self.config_name)
							end
							
							self.assignmentsP2 = self:ReadPhaseNote("P2", display)
							self.assignmentsP3 = self:ReadPhaseNote("P3", display)							
						end
						
						function frame:copy_mrt()
							local str = [[
								#%1$dP2start%2$s
								[%3$s] player player player
								[%4$s] player player player
								[%5$s] player player player
								end
								
								#%1$dP3start%2$s
								[%3$s] player player player
								[%4$s] player player player
								[%5$s] player player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(self.config_id), L["近战"], L["治疗"], L["远程"])
						end
						
						function frame:GetMyIndexbyRole()
							local myIndex = 2 -- Healers
							local info = T.GetGroupInfobyGUID(G.PlayerGUID)
							local rangeType = info.pos
							local isHealer = info.role == "HEALER"
							
							if not isHealer then
								if rangeType == "MELEE" then -- Melee
									myIndex = 1
								elseif rangeType == "RANGED" then -- Ranged
									myIndex = 3
								end
							end
							
							return myIndex
						end
						
						function frame:GetMyIndexbyAssignment(phase)
							if phase == 3 then
								return self.assignmentsP3
							elseif phase == 2 then
								return self.assignmentsP2
							end
						end
						
						function frame:Display(isInverse, phase, set, myIndex, preview)
							local inversePositions
							
							if C.DB["BossMod"][self.config_id]["rotate_bool"] then
								inversePositions = INVERSE_POSITIONS_ROTATE[phase][set]
							else
								inversePositions = INVERSE_POSITIONS[phase][set]
							end
							
							if inversePositions then
								for index, data in ipairs(self.info) do
									local tag = data.tag
									local f = self.graphs[tag]
									local assigned = index == myIndex
									local x = inversePositions[tag][1]*INVERSE_SIZE
									local y = inversePositions[tag][2]*INVERSE_SIZE
									
									f:SetPoint("CENTER", self.graph_bg, "CENTER", x, y)
									
									if assigned then
										if isInverse then
											f.tex:SetVertexColor(0, 1, 0)
											if not preview then
												T.Start_Text_Timer(self.text_frame, 4.8, data.str, true)
												T.PlaySound(data.sound1)
												T.StartMsgTicker(self, data.str, 5)
											end
										else
											f.tex:SetVertexColor(1, .29, .98)
											if not preview then
												T.Start_Text_Timer(self.text_frame, 4.8, data.str, true)
												T.PlaySound(data.sound2)
											end
										end
									else
										f.tex:SetVertexColor(.5, .5, .5)
									end
								end
								
								for k, info in pairs(self.graph_bg_info) do
									local info = inversePositions[k]
									local tex = self.graphs[k]
									if info then
										if k ~= "bg" then
											local x = info[1]*INVERSE_SIZE
											local y = info[2]*INVERSE_SIZE
											tex:SetPoint("CENTER", self.graph_bg, "CENTER", x, y)
											
											local rotation = info[3]
											if rotation then
												tex:SetRotation(rotation/180*math.pi)
											end
											
											tex:Show()
										else
											local x1 = info[1]*INVERSE_SIZE
											local y1 = info[2]*INVERSE_SIZE
											local x2 = info[3]*INVERSE_SIZE
											local y2 = info[4]*INVERSE_SIZE
											
											tex:ClearAllPoints()
											tex:SetPoint("TOPLEFT", self.graph_bg, "CENTER", x1, y1)
											tex:SetPoint("BOTTOMRIGHT", self.graph_bg, "CENTER", x2, y2)
										end
										
										tex:Show()
									else
										tex:Hide()
									end
								end
								
								local action
								
								if phase == 3 then
									if set == 1 then
										if myIndex == 3 then
											action = "dontmove" -- 远程
										else
											action = "pullagainst" -- 近战 治疗
										end
									elseif set == 2 or set == 3 then
										action = "dontmove"
									elseif set == 4 or set == 5 then
										action = "pullagainst"
									end
								end
								
								if action then
									frame.tip_text:SetText(action == "dontmove" and L["不对抗"] or L["对抗"])
									frame.tip_text:Show()
									
									if not preview then
										C_Timer.After(.8, function()
											T.PlaySound("1302\\"..action)
										end)
									end
								else
									frame.tip_text:Hide()
								end
								
								return true
							else
								return
							end
						end
						
						function frame:Start()
							self.graph_bg:Show()
							C_Timer.After(5, function()
								self.graph_bg:Hide()
							end)
						end
						
						function frame:UpdatePreviewInfo()
							local isInverse = math.random(2) == 1
							local phase = C.DB["BossMod"][self.config_id]["preview_phase_dd"]
							local set = C.DB["BossMod"][self.config_id]["preview_index_dd"]
							local myIndex = self:GetMyIndexbyRole()
							
							local shouldShow = self:Display(isInverse, phase, set, myIndex, true)
							
							if T.IsInPreview() then
								if shouldShow then
									self.graph_bg:Show()
								else
									self.graph_bg:Hide()
								end
							end
						end
						
						function frame:PreviewShow()
							self:UpdatePreviewInfo()
						end
						
						function frame:PreviewHide()
							self.graph_bg:Hide()
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							
							if sub_event == "SPELL_AURA_APPLIED" then
								if spellID == 1234244 then -- 引力倒转
									table.insert(frame.affected, destGUID)
									
									if destGUID == G.PlayerGUID then
										local phase = frame.phase
										local set = frame.set
										local my_index = frame.my_index
										frame:Display(true, phase, set, my_index)
										frame:Start()
										--print("大圈", "phase", phase, "set", set, "my_index", my_index)
									end
									
									if #frame.affected == 1 then
										C_Timer.After(0.2, function()
											local should_assign = not tContains(frame.affected, G.PlayerGUID)
											--print("should_assign", should_assign)
											
											if should_assign then
												local phase = frame.phase
												local set = frame.set
												local my_index = frame:GetMyIndexbyAssignment(phase)
												frame:Display(false, phase, set, my_index)
												frame:Start()
												--print("小圈", "phase", phase, "set", set, "my_index", my_index)
											end
											
											frame.set = frame.set + 1
											frame.affected = table.wipe(frame.affected)
										end)
									end
									
								elseif spellID == 1246143 then -- 湮灭之触
									if frame.phase == 1 then
										frame.phase = 2
										frame.set = 1
										--print("frame.phase", frame.phase, "frame.set", frame.set)
									elseif frame.phase == 2 then -- 轮次校准
										frame.set = 3
										--print("frame.phase", frame.phase, "frame.set", frame.set)
									end
								end
							end
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, castGUID, spellID = ...
							
							if not castGUID then return end
							if unit == "boss1" and spellID == 1231716 then  -- 熄灭众星
								frame.phase = 3
								frame.set = 1
								--print("frame.phase", frame.phase)
							end
							
						elseif event == "ENCOUNTER_START" then
							frame.affected = table.wipe(frame.affected)
							frame.phase = 1
							frame.set = 1
							
							frame.my_index = frame:GetMyIndexbyRole()
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						T.Stop_Text_Timer(frame.text_frame)
						T.StopMsgTicker(frame)
						frame.graph_bg:Hide()
						frame:Hide()
					end,
				},
			},
		},
		{ -- 蚀盛
			spells = {
				{1237690, "4"},--【蚀盛】
			},
			options = {
				{ -- 计时条 蚀盛（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1237690,
				},
			},
		},		
		{ -- 阿托席恩:物质喷发/物质破坏
			npcs = {
				{32741},--【阿托席恩】 
			},
			spells = {
				{1237694, "3"},--【物质喷发】
				{1249423, "12"},--【物质破坏】
			},
			options = {
				{ -- 文字 物质喷发 倒计时（✓）
					category = "TextAlert",
					ficon = "3",
					type = "spell",
					preview = L["头前"]..L["倒计时"],
					data = {
						spellID = 1237694,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[2] = {7, 17.7, 17.7, 17.7},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1237694, L["头前"], self, event, ...)
					end,
				},
				{ -- 计时条 物质喷发（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1237694,
					text = L["头前"],
				},
				{ -- 文字 物质破坏 倒计时（?）
					category = "TextAlert",
					ficon = "12",
					type = "spell",
					preview = L["射线"]..L["倒计时"],
					data = {
						spellID = 1249423,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[16] = {
								[2] = {3, 15.8, 15.8},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1249423, L["射线"], self, event, ...)
					end,
				},
				{ -- 计时条 物质破坏（待测试）
					category = "AlertTimerbar",
					ficon = "12",
					type = "cast",
					spellID = 1249423,
					text = L["射线"],
				},
				{ -- 首领模块 物质破坏 点名统计 整体排序（✓） 
					category = "BossMod",
					ficon = "12",
					spellID = 1249423,
					enable_tag = "spell",
					name = string.format(L["NAME点名排序"], T.GetIconLink(1249425)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 285},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.aura_id = 1249425
						frame.element_type = "bar"
						frame.color = T.GetSpellColor(frame.aura_id)
						frame.raid_index = true
						frame.support_spells = 3
						frame.bar_num = 4
					
						frame.info = {
							{text = "[1]", msg_applied = "1 %name", msg = "1"},
							{text = "[2]", msg_applied = "2 %name", msg = "2"},
							{text = "[3]", msg_applied = "3 %name", msg = "3"},
							{text = "[4]", msg_applied = "4 %name", msg = "4"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:post_display(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Start_Text_Timer(self.text_frame, 5, frame.info[index].text)
							end
						end
						
						function frame:post_remove(element, index, unit, GUID)
							if GUID == G.PlayerGUID then
								T.Stop_Text_Timer(self.text_frame)
							end
						end
						
						T.InitAuraMods_ByMrt(frame)
					end,
					update = function(frame, event, ...)
						T.UpdateAuraMods_ByMrt(frame, event, ...)
					end,
					reset = function(frame, event)
						T.ResetAuraMods_ByMrt(frame)
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 首领模块 物质破坏 计时圆圈（✓）
					category = "BossMod",
					ficon = "12",
					spellID = 1249425,
					name = T.GetIconLink(1249425)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1249425] = { -- 物质破坏
								unit = "player",
								aura_type = "HARMFUL",
								color = {0, 1, 1},
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
				{ -- 图标 碎片地带（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1237696,
					tip = L["DOT"].."+"..L["减速"],
				},
			},
		},
		{ -- 帕哥斯:星尘新星/星辰碎片冲击
			npcs = {
				{32745},--【帕哥斯】
			},
			spells = {
				{1237695, "3"}, --【星尘新星】
				{1249454, "12"},--【星辰碎片冲击】
			},
			options = {
				{ -- 文字 星尘新星 倒计时（✓）
					category = "TextAlert",
					ficon = "3",
					type = "spell",
					preview = L["大圈"]..L["倒计时"],
					data = {
						spellID = 1237695,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[3] = {7, 35.3},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1237695, L["大圈"], self, event, ...)
					end,
				},
				{ -- 计时条 星尘新星（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1237695,
				},
				{ -- 文字 星辰碎片冲击 倒计时（?）
					category = "TextAlert",
					ficon = "12",
					type = "spell",
					preview = L["引头前"]..L["倒计时"],
					data = {
						spellID = 1251619,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[16] = {
								[3] = {3.2, 31.6},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1251619, L["引头前"], self, event, ...)
					end,
				},
				{ -- 首领模块 星辰碎片冲击 MRT轮次分配（待测试）
					category = "BossMod", 
					spellID = 1251619,
					ficon = "12",
					enable_tag = "spell",
					name = string.format(L["NAME技能轮次安排"], T.GetIconLink(1251619)),
					points = {a1 = "TOPLEFT", a2 = "CENTER", x = -700, y = 20},
					events = {
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					custom = {
						{
							key = "width_sl",
							text = L["长度"],
							default = 180,
							min = 150,
							max = 400,
							apply = function(value, alert)
								alert:SetWidth(value)
								for _, bar in pairs(alert.bars) do
									bar:SetWidth(value)
								end
								alert:line_up()
							end
						},
						{
							key = "height_sl",
							text = L["高度"],
							default = 20,
							min = 16,
							max = 45,
							apply = function(value, alert)
								alert:SetHeight(value*3+4)
								for _, bar in pairs(alert.bars) do
									bar:SetHeight(value)
								end
								alert:line_up()
							end
						},
						{
							key = "mrt_custom_btn", 
						},
						{
							key = "mrt_analysis_btn",
						},
					},
					init = function(frame)
						frame.bars = {}
						frame.sort_bars = {}
						frame.color = T.GetSpellColor(1247045)
						
						frame.assignments = {}
						frame.backup_assignments = {}
						frame.assigned = {}
						frame.count = 0
						frame.info = {
							{str = L["左"], sound = "left"},
							{str = L["中"], sound = "mid"}, 
							{str = L["右"], sound = "right"},
						}
						
						frame.text_frame = T.CreateAlertTextShared("bossmod"..frame.config_id, 2)
						
						function frame:line_up()
							self.sort_bars = table.wipe(self.sort_bars)
							
							for _, bar in pairs(self.bars) do
								table.insert(self.sort_bars, bar)
							end
							
							table.sort(self.sort_bars, function(a,b)
								if a.index < b.index then
									return true
								end
							end)
							
							for i, bar in pairs(self.sort_bars) do
								bar:ClearAllPoints()
								if i == 1 then
									bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
								else
									bar:SetPoint("TOPLEFT", self.sort_bars[i-1], "BOTTOMLEFT", 0, -2)
								end
							end
						end
						
						function frame:createbar(index, GUID)
							local info = GUID and T.GetGroupInfobyGUID(GUID)
							local h = C.DB["BossMod"][self.config_id]["height_sl"]
							local w = C.DB["BossMod"][self.config_id]["width_sl"]
							
							local bar = T.CreateTimerBar(self, 4914669, false, false, false, w, h, self.color)
							local str = self.info[index].str
							bar.ficon_text:SetText(str)
							bar:SetMinMaxValues(0, 5)
							bar.index = index
							
							function bar:cancel()
								bar:SetScript("OnUpdate", nil)
								bar:Hide()
								frame.bars[bar.tag] = nil
							end
							
							function bar:start()
								bar.exp_time = GetTime() + 5
								bar:SetScript("OnUpdate", function(s, e)
									s.t = s.t + e
									if s.t > 0.05 then
										local remain = s.exp_time - GetTime()
										if remain > 0 then
											s:SetValue(remain)
											s.right:SetText(T.FormatTime(remain))
										else
											s:cancel()
										end
										s.t = 0
									end
								end)
							end
							
							if GUID then
								bar.tag = GUID
								bar.left:SetText(info.format_name)
								self.bars[GUID] = bar
							else
								bar.tag = index
								bar.left:SetText(T.ColorNickNameByGUID(G.PlayerGUID))
								self.bars[index] = bar
							end
							
							return bar
						end
						
						function frame:ReadNote(display)
							self.assignments = table.wipe(self.assignments)
							self.backup_assignments = table.wipe(self.backup_assignments)
							
							if display then
								T.divideline(self.config_name)
							end
							
							local count = 0
							for _, line in T.IterateNoteAssignment(self.config_id) do
								local GUIDs = T.LineToGUIDArray(line)
								if next(GUIDs) then
									count = count + 1
									if count <= 2 then
										self.assignments[count] = GUIDs
										if display then
											local str = T.GetColoredNameListByArray(GUIDs, string.format("%s[%d]", L["撞球"], count))
											T.msg(str)
										end
									else
										self.backup_assignments = GUIDs
										if display then
											local str = T.GetColoredNameListByArray(GUIDs, L["替补"])
											T.msg(str)
										end
									end
								end
							end
						end
						
						function frame:copy_mrt()
							local str = [[
								#%dstart%s
								[1] player player player
								[2] player player player
								
								backup:player player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(self.config_id))
						end
						
						function frame:PlayerCheck(GUID)
							local unit = T.GUIDToUnit(GUID)
							if unit then
								local alive = not UnitIsDeadOrGhost(unit)
								local debuffed = AuraUtil.FindAuraBySpellID(1254385, unit, "HARMFUL") -- 星辰碎片
								local assigned = tContains(self.assigned, GUID)
								if alive and not debuffed and not self.assigned[GUID] then
									return true
								end
							end
						end
						
						function frame:GetBackup()
							local GUIDs = self.backup_assignments
							if not next(GUIDs) then return end
							
							for i = 1, #GUIDs do
								local GUID = GUIDs[i]
								if self:PlayerCheck(GUID) then
									return GUID
								end
							end
						end
						
						function frame:Assign()
							self.assigned = table.wipe(self.assigned)
							
							local count = self.count
							local GUIDs = self.assignments[count]
							
							for i = 1, 3 do
								local assigned_GUID = GUIDs and GUIDs[i]
							
								if assigned_GUID and self:PlayerCheck(assigned_GUID) then
									self.assigned[i] = assigned_GUID
								else
									self.assigned[i] = self:GetBackup()
								end
								
								if self.assigned[i] then
									local bar = self:createbar(i, self.assigned[i])
									bar:start()
								end
							end
							
							self:line_up()
							
							for i, GUID in pairs(self.assigned) do
								if GUID == G.PlayerGUID then
									local str = self.info[i].str
									local sound = self.info[i].sound
									T.Start_Text_Timer(self.text_frame, 5, string.format("%s %s", L["撞球"], str), true)
									T.PlaySound(sound)
									break
								end
							end
						end
						
						function frame:PreviewShow()
							for i = 1, 3 do
								self:createbar(i)
							end
							self:line_up()
						end
						
						function frame:PreviewHide()
							for _, bar in pairs(self.bars) do
								bar:cancel()
							end
						end
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1251619 then -- 星辰碎片冲击
								frame.count = frame.count + 1
								frame:Assign()
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						for _, bar in pairs(frame.bars) do
							bar:cancel()
						end
						T.Stop_Text_Timer(frame.text_frame)
					end,
				},
				{ -- 计时条 星辰碎片冲击（待测试）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1251619,
					text = L["头前"],
					ficon = "12",
				},
			},
		},
		{ -- 阿托席恩 帕哥斯:征服者的十字
			npcs = {
				{32741},--【阿托席恩】
				{32745},--【帕哥斯】
			},
			spells = {
				{1239262, "1,12"},--【征服者的十字】虚空领主召唤虚空守卫方阵来争夺领地，并限制玩家移动。
			},
			options = {
				{ -- 文字 征服者的十字 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["召唤小怪"]..L["倒计时"],
					data = {
						spellID = 1239262,
						events =  {
							["COMBAT_LOG_EVENT_UNFILTERED"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "ENCOUNTER_START" then
							self.round = true
							self.voidlordKilled = 0
							self.difficultyID = select(3, ...)
							
						elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "UNIT_DIED" then
								local npcID = select(6, strsplit("-", destGUID))
								if npcID == "245255" or npcID == "245222" then
									T.Stop_Text_Timer(self)
									self.voidlordKilled = self.voidlordKilled + 1
								end
								
							elseif sub_event == "SPELL_CAST_SUCCESS" and spellID == 1237102 then -- 世界之魂吞噬
								if self.voidlordKilled == 0 then
									if self.difficultyID == 16 then
										T.Start_Text_DelayTimer(self, 10.1, L["召唤小怪"], true)
									else
										T.Start_Text_DelayTimer(self, 15.2, L["召唤小怪"], true)
									end
								else
									if self.difficultyID == 16 then
										T.Start_Text_DelayTimer(self, 13.9, L["召唤小怪"], true)
									else
										T.Start_Text_DelayTimer(self, 18.8, L["召唤小怪"], true)
									end
								end
								
							elseif sub_event == "SPELL_CAST_START" and spellID == 1239262 then -- 征服者的十字
								if self.difficultyID == 16 then
									T.Start_Text_DelayTimer(self, 31.6, L["召唤小怪"], true)
								else
									T.Start_Text_DelayTimer(self, 35.3, L["召唤小怪"], true)
								end
							end
						end
					end,
				},
				{ -- 计时条 征服者的十字（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1239262,
					text = L["召唤小怪"],
					sound = "[add]cast",
				},
				{ -- 首领模块 征服者的十字 控制链（✓）
					category = "BossMod",
					ficon = "12",
					enable_tag = "spell",
					spellID = 1239262,					
					name = T.GetFomattedNameFromNpcID("248589")..L["控制链"],
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
					},
					init = function(frame)
					
						function frame:copy_mrt()
							local str = T.GenerateGroupCCNote(self.config_id, self.config_name, 4)
							return str
						end
						
						function frame:ReadNote(display)
							T.ReadGroupCCNote(self.config_id, display, self.config_name)
							T.GroupSpellForceUpdate()
						end
						
					end,
					update = function(frame, event, ...)
						if event == "COMBAT_LOG_EVENT_UNFILTERED" then
							local _, sub_event, _, _, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
							if sub_event == "SPELL_CAST_START" and spellID == 1239262 then -- 征服者的十字		
								frame.count = frame.count + 1
								T.DisplayGroupCCFrame(frame.count)
								
								frame.timer = C_Timer.NewTimer(20, function()
									T.HideGroupCCFrame()
								end)
							end
						elseif event == "ENCOUNTER_START" then
							frame.count = 0
							frame:ReadNote()							
						end
					end,
					reset = function(frame, event)
						if frame.timer then
							frame.timer:Cancel()
						end
						T.HideGroupCCFrame()
					end,
				},
			},
		},
		{ -- 虚空守卫
			npcs = {
				{33583},--【虚空守卫】 
			},
			spells = {
				--{1239270},--【虚空守护】
				--{1246537},--【熵能统合】
			},
			options = {
				{ -- 图标 虚空守护（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1239270,
					hl = "red",
					tip = L["强力DOT"],
				},
				{ -- 团队框架高亮 虚空守护（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1239270,
					color = "org",
				},
			},
		},
		{ -- 虚无束缚者
			npcs = {
				{33586},--【虚无束缚者】 
			},
			spells = {
				--{1246541},--【虚无缠缚】
				--{1249248, "12"},--【无边无界】
			},
			options = {
				{ -- 计时条 虚无缠缚（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1246541,
				},
				{ -- 图标 虚无缠缚（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1246542,
					tip = L["DOT"].."+"..L["减速"],
					hl = "org",
					sound = "[defense]",
				},
				{ -- 自保技能提示 虚无缠缚（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1246542,
					threshold = 65,
				},
			},
		},
		{ -- 阿托席恩 帕哥斯:湮灭之触
			npcs = {
				{32741},--【阿托席恩】
				{32745},--【帕哥斯】
			},
			spells = {
				{1246143, "0,4"},--【湮灭之触】
			},
			options = {
				{ -- 换坦计时条 湮灭之触（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1246143,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
			},
		},
		{ -- 动荡能量
			spells = {
				{1245292, "1"},--【动荡能量】
			},
			options = {
				{ -- 文字 动荡能量 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["BOSS易伤"]..L["倒计时"],
					data = {
						spellID = 1245292,
						events =  {
							["CHAT_MSG_MONSTER_YELL"] = true,
						},
					},
					update = function(self, event, ...)
						if event == "CHAT_MSG_MONSTER_YELL" then
							local msg = ...
							if msg == L["易伤前喊话"] then
								T.Start_Text_Timer(self, 8.7, L["BOSS易伤"], true)
							end
						end
					end,
				},
				{ -- 计时条 动荡能量（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "boss",
					spellID = 1245292,
					text = L["BOSS易伤"],
				},
			},
		},
		{ -- 吸积盘
			spells = {
				{1233292},--【吸积盘】
			},
			options = {
				
			},
		},		
		{ -- 熄灭众星
			spells = {
				{1231716, "2"},--【熄灭众星】
				--{1232394},--【重力井】
				--{1248479, "4,12"},--【星辰过载】
			},
			options = {
				{ -- 文字 熄灭众星 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1231716)..L["倒计时"],
					data = {
						spellID = 1231716,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							["all"] = {
								[4] = {16.5},
							},
						},
						cd_args = {
							show_time = 3,
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1231716, T.GetIconLink(1231716), self, event, ...)
					end,
				},
				{ -- 计时条 熄灭众星（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1231716,
				},
				{ -- 图标 重力井（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1232394,
					hl = "gre",
				},
			},
		},
		{ -- 吞噬
			spells = {
				{1233539, "4,5,12"},--【吞噬】
				--{1233557, "5"},--【密度】
				{1232973},--【超级新星】
			},
			options = {				
				{ -- 文字 吞噬 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = T.GetIconLink(1233539)..L["倒计时"],
					data = {
						spellID = 1233539,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[4] = {47.5, 100},
							},
							[16] = {
								[4] = {47.5, 80, 80},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1233539, T.GetIconLink(1233539), self, event, ...)
					end,
				},
				{ -- 计时条 吞噬（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1233539,
					sound = "channel,cd3"
				},
				{ -- 首领模块 吞噬分配（✓）
					category = "BossMod",
					enable_tag = "spell",
					ficon = "12",
					spellID = 1233539,
					name = string.format("%s %s (%s)", T.GetIconLink(1233539), L["分配"], L["喊话"]),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
					},
					custom = {
						{
							key = "mrt_custom_btn", 
						},
						{
							key = "mrt_analysis_btn",
						},
					},
					init = function(frame)
						frame.assignment = {}
						
						function frame:ReadNote(display)
							self.assignment = table.wipe(self.assignment)
							self.mark = nil
							
							if display then
								T.divideline(self.config_name)
							end
							
							for _, line in T.IterateNoteAssignment(self.config_id) do
								local GUIDs, containsPlayerGUID, mark = T.LineToGUIDArray(line)
								
								if next(GUIDs) and mark then
									local str = string.format("[%s]", T.FormatRaidMark(mark))
									
									if not self.assignment[mark] then
										self.assignment[mark] = {}
									end
									
									for _, GUID in ipairs(GUIDs) do
										str = str.." "..T.ColorNickNameByGUID(GUID)
										tInsertUnique(self.assignment[mark], GUID)
									end
									
									if display then
										T.msg(str)
									end
									
									if containsPlayerGUID then
										self.mark = mark
									end
								end
							end
						end
						
						function frame:copy_mrt()
							local str = [[
								#%dstart%s
								{rt1} player player player player player
								{rt2} player player player player player
								{rt3} player player player player player
								{rt4} player player player player player
								end
							]]
							
							str = gsub(str, "	", "")
							return string.format(str, self.config_id, C_Spell.GetSpellName(self.config_id))
						end
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, cast_GUID, cast_spellID = ...
							if not cast_GUID then return end
							if unit == "boss1" and cast_spellID == 1233539 then -- 吞噬
								if frame.mark then
									local msg = string.format("{rt%d}", frame.mark)
									T.StartMsgTicker(frame, msg, 7, "SAY")
									T.PlaySound("mark\\mark"..frame.mark)
								end
							end
							
						elseif event == "ENCOUNTER_START" then
							frame:ReadNote()
						end
					end,
					reset = function(frame, event)
						T.StopMsgTicker(frame)
					end,
				},
				{ -- 文字 超级新星 倒计时（✓）
					category = "TextAlert",
					ficon = "3",
					type = "spell",
					preview = T.GetIconLink(1232973)..L["倒计时"],
					data = {
						spellID = 1232973,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[4] = {56.4, 14.5, 33.3, 33.3, 18.9, 14.4},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1232973, T.GetIconLink(1232973), self, event, ...)
					end,
				},
				{ -- 首领模块 超级新星生效计时条 （✓）
					category = "BossMod",
					spellID = 1232973,
					name = string.format(L["超级新星生效计时条"], T.GetIconLink(1232973)),
					points = {hide = true},
					events = {
						["UNIT_SPELLCAST_START"] = true,
						["UNIT_SPELLCAST_SUCCEEDED"] = true,
					},
					init = function(frame)
						frame.count = 0
						
						local icon = C_Spell.GetSpellTexture(1232973)
						local color = T.GetSpellColor(1232973)
						
						frame.bar = T.CreateAlertBarShared(1, "bossmod"..frame.config_id, icon, L["全团AE"], color)
						frame.bar.glow:SetBackdropBorderColor(unpack(color))
						frame.bar.glow:Show()
					end,
					update = function(frame, event, ...)
						if event == "UNIT_SPELLCAST_START" then
							local unit, _, spellID = ...
							
							if frame.difficultyID ~= 16 and string.find(unit, "boss") and spellID == 1232973 then -- 超级新星
								T.StartTimerBar(frame.bar, 6.5, true, true)
								T.PlaySound("1302\\1232973cast")
							end
							
						elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
							local unit, _, spellID = ...
							
							if frame.difficultyID == 16 and string.find(unit, "boss") and spellID == 1233539 then -- 吞噬 P3
								frame.count = frame.count + 1
								
								if frame.count < 3 then
									T.StartTimerBar(frame.bar, 7, true, true)
									T.PlaySound("1302\\1232973cast")
								end
							end
						
						elseif event == "ENCOUNTER_START" then
							frame.difficultyID = select(3, ...)
							frame.count = 0 
						end
					end,
					reset = function(frame, event)
						T.StopTimerBar(frame.bar, true, true)
					end,
				},
			},
		},	
		{ -- 昏天黑地
			spells = {
				{1234052, "4"},--【昏天黑地】
				{1234054},--【暗影震荡】
			},
			options = {
				{ -- 文字 昏天暗地 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["圆环"]..L["倒计时"],
					data = {
						spellID = 1234044,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},
						info = {
							[15] = {
								[4] = {80.8, 33.3, 66.6},
							},
							[16] = {
								[4] = {72.4, 30, 50, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1234044, L["圆环"], self, event, ...)
					end,
				},
				{ -- 计时条 昏天暗地（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1234044,
					text = L["圆环"],
					sound = "[ring]cast",
				},
				{ -- 图标 暗影震荡（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1234054,
					tip = L["易伤"].."400%",
					hl = "red",
					sound = "[sound_water]cd3",
				},
				{ -- 首领模块 暗影震荡 计时圆圈（✓）
					category = "BossMod",
					spellID = 1234054,
					name = T.GetIconLink(1234054)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {
						["UNIT_AURA"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1234054] = { -- 暗影震荡
								unit = "player",
								aura_type = "HARMFUL",
								color = {1, 0, 0},
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
		{ -- 寰宇崩塌
			spells = {
				{1234263, "0"},--【寰宇崩塌】
				{1234266, "0"},--【寰宇脆弱】
			},
			options = {
				{ -- 文字 寰宇崩塌 倒计时（?）
					category = "TextAlert",
					type = "spell",
					preview = L["拉人"]..L["倒计时"],
					data = {
						spellID = 1234263,
						events =  {
							["ENCOUNTER_PHASE"] = true,
							["UNIT_SPELLCAST_START"] = true,
						},					
						info = {
							[15] = {
								[4] = {65.3, 33.3, 33.3, 33.3},
							},
							[16] = {
								[4] = {57.4, 30, 30, 30, 30},
							},
						},
						cd_args = {
							round = true,
						},
					},
					update = function(self, event, ...)
						T.UpdateCooldownTimer("UNIT_SPELLCAST_START", "boss", 1234263, L["拉人"], self, event, ...)
					end,
				},
				{ -- 计时条 寰宇崩塌（✓）
					category = "AlertTimerbar",
					type = "cast",
					spellID = 1234263,
					show_tar = true,
					sound = "[pull]cast,cd3"
				},
				{ -- 换坦计时条 寰宇脆弱（✓）
					category = "AlertTimerbar",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "group",
					spellID = 1234266,
					ficon = "0",
					group = 3,
					show_tar = true,
					roles = {"TANK"},
				},
				{ -- 首领模块 寰宇崩塌 计时圆圈（✓）
					category = "BossMod",
					spellID = 1234263,
					name = T.GetIconLink(1234263)..L["计时圆圈"],
					points = {a1 = "CENTER", a2 = "CENTER", x = 0, y = -25},
					events = {	
						["COMBAT_LOG_EVENT_UNFILTERED"] = true,
					},
					init = function(frame)
						frame.spellIDs = {
							[1234263] = { -- 寰宇崩塌
								event = "SPELL_CAST_START",
								dur = 4,
								color = {0, 1, 1},
								reverse = true,
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
		{ -- 虚空之握
			spells = {
				{1250055, "3"},--【虚空之握】
			},
			options = {
				{ -- 图标 虚空之握（✓）
					category = "AlertIcon",
					type = "aura",
					aura_type = "HARMFUL",
					unit = "player",
					spellID = 1250055,
					tip = L["强力DOT"].."+"..L["减速"],
					hl = "red",
					sound = "[defense]",
				},
				{ -- 自保技能提示 虚空之握（✓）
					category = "HPWatch",
					type = "Aura",
					spellID = 1250055,
					threshold = 65,
				},
				{ -- 团队框架高亮 虚空之握（✓）
					category = "RFIcon",
					type = "Aura",
					spellID = 1250055,
					color = "red",
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
					spellID = 1234898, -- 黑洞视界
				},
				{
					category = "PhaseChangeData",
					phase = 2,
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1239262, -- 征服者的十字
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 2.5,
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1246143, -- 湮灭之触
					count = 1,
				},
				{
					category = "PhaseChangeData",
					phase = 3,
					type = "CLEU",
					sub_event = "SPELL_CAST_START",
					spellID = 1239262, -- 征服者的十字
					count = 3,
				},
				{
					category = "PhaseChangeData",
					phase = 3.5,
					type = "CLEU",
					sub_event = "SPELL_AURA_REMOVED",
					spellID = 1246143, -- 湮灭之触
					count = 2,
				},
				{
					category = "PhaseChangeData",
					phase = 4,
					type = "CLEU",
					sub_event = "SPELL_AURA_APPLIED",
					spellID = 1245292, -- 动荡能量
				},
			},
		},
	},
}